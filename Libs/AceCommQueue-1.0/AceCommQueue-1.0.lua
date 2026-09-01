--- AceCommQueue-1.0
-- Transparently wraps AceComm-3.0's SendCommMessage on embedded addon objects to
-- serialize sends on a per-(prefix, distribution, target) queue, preventing
-- ChatThrottleLib chunk interleaving that causes CRC errors on receivers.
--
-- Background: AceComm splits large messages into FIRST/NEXT/LAST chunks and submits
-- them all to ChatThrottleLib (CTL) in sequence. If a second message is submitted on
-- the same prefix before CTL drains the first message's chunks, and the two messages
-- use different CTL priorities (e.g. BULK then NORMAL), CTL drains the NORMAL chunks
-- ahead of remaining BULK chunks — corrupting the receiver's spool and causing CRC errors.
---@diagnostic disable: undefined-global
--
-- This library ensures only one message per (prefix, distribution, target) is in-flight
-- in CTL at a time. The next queued message is not submitted until the previous one's
-- final chunk has been confirmed via CTL's callback.
--
-- Priority order within the app-level queue (highest first): ALERT > NORMAL > BULK.
-- Between messages, higher-priority items drain first.
--
-- Usage:
--   1. Embed AceComm-3.0 as normal (and define any SendCommMessage wrappers you need).
--   2. THEN embed AceCommQueue-1.0 LAST so it wraps the complete wrapper chain:
--        local ACQ = LibStub("AceCommQueue-1.0")
--        ACQ:Embed(myAddon)   -- must be called after AceComm:Embed(myAddon)
--   3. Use myAddon:SendCommMessage(...) as normal — queueing is fully transparent.
--
-- Suppression: If your SendCommMessage wrapper suppresses a send (e.g. an in-raid guard),
-- it MUST call callbackFn(callbackArg, 0, 0, nil) to unblock the queue.
-- The condition (0 >= 0) satisfies last-chunk detection and drains the next item.
--
-- Callback contract: every accepted call ends in exactly one terminal callback —
-- (arg, total, total, sendResult) when the final chunk goes out, or (arg, 0, 0, nil)
-- when the message is suppressed, rejected for a bad argument, or the send raises.
-- Callers chain their next send on that callback, so no path may end in silence.

local MAJOR, MINOR = "AceCommQueue-1.0", 6
local AceCommQueue, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not AceCommQueue then return end  -- newer or same version already loaded

-- ALERT drains before NORMAL before BULK. This strict ordering is THIS library's,
-- not a mirror of ChatThrottleLib's: CTL splits bandwidth EQUALLY among whichever
-- priorities have something to send (`avail / nSendablePrios`), with no weighting
-- and no preemption, so an ALERT gets a third of the budget when all three are
-- backlogged rather than going first. Serialising here is what actually makes
-- priority mean anything between messages.
local PRIO_ORDER = { "ALERT", "NORMAL", "BULK" }

-- Per-(prefix, dist, target) queue tables. Preserved across LibStub upgrades.
AceCommQueue.queues = AceCommQueue.queues or {}

-- Debug flag. Off by default. Toggle at runtime with AceCommQueue:SetDebug(true).
-- When standalone, read your SavedVariables in ADDON_LOADED and call SetDebug accordingly.
AceCommQueue.debug = AceCommQueue.debug or false

-- Retry policy for a send the CLIENT REFUSED. Explicit nil checks rather than
-- `or 3`, so a host that deliberately set 0 does not silently get the default
-- back on the next LibStub upgrade.
if AceCommQueue.retryAttempts == nil then AceCommQueue.retryAttempts = 3 end
if AceCommQueue.retryDelay == nil then AceCommQueue.retryDelay = 1 end

-- Seconds of NO PROGRESS on an in-flight send before the queue is called stalled.
-- 0 disables the check. See checkStall.
--
-- 300 rather than the 60 this shipped with: a WHISPER the client throttles sits
-- in ChatThrottleLib being retried, callback-less, for well over a minute on a
-- busy realm, and 60s reported that ordinary condition as a fault. Five minutes
-- is deliberately far past any plausible throttle, because this report accuses a
-- host addon of a bug — the cost of saying so late is nil, and of saying so
-- wrongly is a maintainer auditing the wrong codebase.
if AceCommQueue.stallTimeout == nil then AceCommQueue.stallTimeout = 300 end

--- Enable or disable debug output at runtime.
-- @param flag  boolean
function AceCommQueue:SetDebug(flag)
	self.debug = flag and true or false
end

--- Set how a send the client REFUSED is retried.
--
-- ChatThrottleLib retries only its own AddonMessageThrottle result; every other
-- refusal (GeneralError, NotInGroup, ChannelThrottle) is dequeued and destroyed
-- with no retry, so without this the message is simply gone. Retrying is safe
-- because a refused chunk leaves the receiver's spool incomplete — a retry's
-- fresh FIRST replaces the aborted stream rather than duplicating a delivered
-- message.
--
-- It must stay BOUNDED: AceComm-3.0 discards ChatThrottleLib's result enum and
-- passes only a boolean, so the queue can never tell "throttled, try again" from
-- "not in that group, never going to work".
--
-- @param retries    number of retries after the first attempt. 0 disables. Default 3.
-- @param baseDelay  seconds before the first retry, doubling each time. Default 1.
function AceCommQueue:SetRetryPolicy(retries, baseDelay)
	if type(retries) == "number" and retries >= 0 then
		self.retryAttempts = math.floor(retries)
	end
	if type(baseDelay) == "number" and baseDelay > 0 then
		self.retryDelay = baseDelay
	end
end

--- Set how long an in-flight send may go without progress before the queue is
--- reported as stalled.
--
-- A stalled queue means a send's callback never arrived — in practice a
-- SendCommMessage wrapper that suppressed a send without calling
-- callbackFn(callbackArg, 0, 0, nil). The queue cannot recover from it (it does
-- not know whether that message reached anyone, so it can neither abandon nor
-- re-send it safely) but it can say so instead of going quiet forever.
--
-- Measured from the last chunk, not the send's start, so a slow-but-progressing
-- multipart send under bandwidth pressure never trips it. Checked lazily, when a
-- caller finds the queue busy — there is no timer.
--
-- A send ChatThrottleLib is still holding is never reported, however long it has
-- been quiet — see ctlStillQueued.
--
-- @param seconds  seconds without progress. 0 disables the check. Default 300.
--                 Floored at twice the total retry backoff, so a retry in
--                 progress is never mistaken for a stall.
function AceCommQueue:SetStallTimeout(seconds)
	if type(seconds) == "number" and seconds >= 0 then
		self.stallTimeout = seconds
	end
end

local function dbg(...)
	if AceCommQueue.debug then
		print("|cff88aaff[AceCommQueue-1.0]|r", string.format(...))
	end
end

--- Register a slash command to toggle debug mode at runtime.
-- Only call this once — either from an addon's OnInitialize, or from a
-- standalone wrapper's ADDON_LOADED handler.
--
-- Supported commands (replace "/acq" with your chosen cmd):
--   /acq on       — enable debug output
--   /acq off      — disable debug output
--   /acq status   — print current state of all queues
--   /acq unstick  — release every stuck queue and re-send what was stuck
--   /acq          — toggle
--
-- @param cmd  Slash command string, e.g. "/acq" (include the slash)
function AceCommQueue:RegisterSlashCommand(cmd)
	if type(cmd) ~= "string" or cmd:sub(1,1) ~= "/" then
		dbg("RegisterSlashCommand: cmd must be a slash command string, e.g. '/acq' — skipped")
		return
	end

	local name = "ACECOMMQUEUE_" .. cmd:upper():gsub("[^A-Z0-9]", "_")
	_G["SLASH_" .. name .. "1"] = cmd
	SlashCmdList[name] = function(arg)
		arg = arg and arg:lower():match("^%s*(.-)%s*$") or ""
		if arg == "on" then
			AceCommQueue:SetDebug(true)
			print("|cff88aaff[AceCommQueue-1.0]|r Debug ON")
		elseif arg == "off" then
			AceCommQueue:SetDebug(false)
			print("|cff88aaff[AceCommQueue-1.0]|r Debug OFF")
		elseif arg == "unstick" then
			local released, held = AceCommQueue:Unstick()
			print(string.format(
				"|cff88aaff[AceCommQueue-1.0]|r Unstick: %d queue(s) released and re-sending, "
				.. "%d left alone (ChatThrottleLib still has the message).", released, held))
		elseif arg == "status" then
			print("|cff88aaff[AceCommQueue-1.0]|r Queue status:")
			local any = false
			for key, q in pairs(AceCommQueue.queues) do
				any = true
				local displayKey = key:gsub("\031", "|")
				-- Idle time on an in-flight send is the number a maintainer needs:
				-- a queue busy for minutes is a stall, not a slow send.
				local idle = ""
				if q.inFlight and q.progressAt and GetTime then
					idle = string.format(" idle=%.0fs", GetTime() - q.progressAt)
				end
				print(string.format("  %s — inFlight=%s A=%d N=%d B=%d refused=%d stalls=%d%s",
					displayKey, tostring(q.inFlight), #q.ALERT, #q.NORMAL, #q.BULK,
					q.refused or 0, q.stalls or 0, idle))
			end
			if not any then print("  (no queues registered)") end
		else
			AceCommQueue:SetDebug(not AceCommQueue.debug)
			print("|cff88aaff[AceCommQueue-1.0]|r Debug " .. (AceCommQueue.debug and "ON" or "OFF"))
		end
	end
end

-- Normalize the queue key so case variants ("Guild" vs "GUILD") share the same slot.
-- Both parts are stringified first: AceComm accepts a NUMBER as the target (a
-- channel index), and indexing that directly would error out of SendCommMessage.
local function makeKey(prefix, dist, target)
	local d = dist ~= nil and tostring(dist):upper() or ""
	local t = target ~= nil and tostring(target):lower() or ""
	return prefix .. "\031" .. d .. "\031" .. t
end

-- Tell a caller its message is not going to be sent. Callers routinely chain the
-- next send on this callback, so every message the queue accepts or refuses has
-- to terminate somewhere — (0, 0, nil) is the same signal a suppressing wrapper
-- is required to send.
--
-- `reason` is the 5th callback argument and exists because `nil` alone is
-- ambiguous: it covers a deliberate suppression (where saying nothing is the
-- CORRECT behaviour) as well as a rejected call and a raised send (where a
-- message was genuinely lost). A consumer counting delivery failures has to be
-- able to tell those apart.
local function reportUnsent(callbackFn, callbackArg, reason)
	if callbackFn then callbackFn(callbackArg, 0, 0, nil, reason) end
end

-- Report a message's final outcome to whoever sent it.
--
-- `result` false means the client refused it and it did not go out. If the caller
-- supplied no callback there is nobody to tell, and a dropped comm with nobody
-- told is exactly the silent failure this library exists to prevent — so the
-- library reports it itself rather than letting it disappear.
local function reportOutcome(item, sent, total, result, key, reason)
	local userFn = item.callbackFn
	if userFn then
		-- A broken caller callback must not take the queue down with it.
		local ok, err = pcall(userFn, item.callbackArg, sent, total, result, reason)
		if not ok then geterrorhandler()(err) end
		return
	end
	if result ~= false then return end

	-- Loud ONCE per queue per session, then counted.
	--
	-- Every current consumer sends with no callback, so without this a player in a
	-- state the client refuses (no guild, not grouped) would get one error per
	-- message for as long as that state lasts. That trains people to ignore the
	-- error, which is the same silent failure by a slower route. The running count
	-- stays visible in the slash command's `status` output, so the scale of a
	-- repeat problem is one command away rather than absent.
	local q = AceCommQueue.queues[key]
	local n = ((q and q.refused) or 0) + 1
	if q then q.refused = n end

	if n == 1 then
		geterrorhandler()(string.format(
			"%s: message NOT delivered — the client refused the send and no callbackFn was "
			.. "supplied to report it (prefix=%s queue=%s). Pass a callbackFn and check its 4th "
			.. "argument. Further refusals on this queue are counted in /acq status, not repeated here.",
			MAJOR, tostring(item.prefix), tostring(key)))
	else
		dbg("drain(%s): NOT delivered (prefix=%s) — refusal #%d on this queue, already reported once",
			key, item.prefix, n)
	end
end

-- Report a queue whose in-flight send has gone quiet.
--
-- `inFlight` is cleared only by the completion callback, so a send whose callback
-- NEVER arrives leaves that (prefix, dist, target) dead for the rest of the
-- session, silently, with every later message stuck behind it. In practice that
-- means a wrapper which suppressed a send without firing
-- callbackFn(arg, 0, 0, nil) — the one contract this library asks of its hosts.
--
-- DELIBERATELY LAZY: no timer, no OnUpdate. The check runs when a caller tries to
-- use the queue and finds it busy, which is exactly the moment the stall starts
-- costing something. A queue that stalls and is never used again is never
-- reported, and that is correct — nothing is being held up by it. Adding a timer
-- per in-flight message would mean one timer object per chunk on the hot path of
-- a library that is otherwise purely callback-driven.
--
-- Measured from the LAST CHUNK, not from the send's start: ChatThrottleLib's
-- 800 bytes/sec is shared across every addon on the client, so a large multipart
-- send under raid load legitimately takes a long time. A slow-but-progressing
-- send keeps resetting the clock and can never trip this; only a genuinely dead
-- one can.
--
-- Forward-declared so the stall recovery below can reach them; both are defined
-- further down, where the send path they belong to lives.
local drain
local scheduleRetry

-- Ask ChatThrottleLib whether the in-flight send is still sitting in its queue.
--
-- CTL retries a THROTTLED send out of its "blocked ring" roughly 2.5 times a
-- second and fires NO callback while it does: ChatThrottleLib:Despool moves the
-- pipe to Prio.Blocked with the message still on it, and only the non-throttled
-- branch below reaches the callback. A send being retried is therefore
-- indistinguishable, from this side, from a callback that was lost — and the two
-- want opposite responses. Reporting the first as a fault is what the 60-second
-- default did: it accused hosts of breaking the suppression contract while the
-- message was in fact still on its way, and sent maintainers to audit the wrong
-- addon entirely.
--
-- EVERY pipe in EVERY priority is scanned, and the match is on the message's own
-- (prefix, distribution, target) rather than on where it was filed.
--
-- The obvious implementation — index CTL.Prio[prio].ByName[prefix] — assumes the
-- host's send path named its CTL queue after the prefix and used the priority we
-- handed it. That is true of AceComm-3.0 (`queueName = prefix`) and of nothing
-- else. CTL takes queueName as a free parameter, and its author's own model is
-- extension+chattype+destination; a host calling CTL directly, or a wrapper that
-- rewrites the priority, files the message somewhere the keyed lookup cannot see.
-- This library ships standalone, so its hosts are not all Ace3-shaped.
--
-- The two error directions are NOT symmetric, which is what settles the design:
--
--   * A false POSITIVE (deciding CTL still has it when it does not) costs
--     silence — the stall goes unreported until the next check.
--   * A false NEGATIVE (deciding CTL lost it when it is still queued) costs a
--     spurious stall report AND a re-send of a message that is about to go out
--     on its own. A duplicate on the wire is the failure this library exists to
--     prevent, arrived at from the other end.
--
-- So the scan is deliberately biased toward matching. Widening it from one pipe
-- to all pipes strictly reduces false negatives and can only add false positives,
-- which is the direction that is safe to be wrong in.
--
-- Cost is irrelevant: this runs only after stallTimeout seconds of silence on a
-- queue, or from an explicit Unstick — never on the send path.
--
-- Every read is nil-safe and CTL is feature-detected: the .toc spans six client
-- flavors and this must degrade to "cannot tell" rather than erroring inside an
-- error report. Cannot-tell means false, so a client without CTL keeps the old
-- timeout-only behaviour instead of going silent.
--
-- @return true only if a message matching this send is still queued in CTL.
local function ctlStillQueued(q)
	local CTL = _G.ChatThrottleLib
	if not (CTL and type(CTL.Prio) == "table") then return false end

	local prefix, dist, target = q.inFlightPrefix, q.inFlightDist, q.inFlightTarget
	for _, Prio in pairs(CTL.Prio) do
		local byName = type(Prio) == "table" and Prio.ByName or nil
		if type(byName) == "table" then
			for _, pipe in pairs(byName) do
				if type(pipe) == "table" then
					-- CTL stores the raw SendAddonMessage arguments positionally:
					-- [1] prefix, [2] text, [3] chattype (the distribution),
					-- [4] target. Blocked pipes stay in ByName — Despool moves them
					-- between rings without unregistering them — so a throttled
					-- message is still found here.
					for i = 1, #pipe do
						local msg = pipe[i]
						if type(msg) == "table" and msg[1] == prefix
							and msg[3] == dist and msg[4] == target then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

-- Release a stuck in-flight send and RE-SEND it, so a lost callback costs a delay
-- rather than a message.
--
-- ONLY safe once ctlStillQueued has answered false. The slot is held for exactly
-- one reason — to keep a second message's chunks out of ChatThrottleLib while the
-- first one's are still in it — so when CTL has nothing of this send left, there
-- is nothing to interleave with and nothing left to protect.
--
-- RE-SENDING, not abandoning. A lost callback has two possible histories: every
-- chunk reached the wire and only the notification was lost, or the send never
-- reached CTL at all. Only the second is actually reachable in practice —
-- ChatThrottleLib fires its callback unconditionally as a message leaves the pipe
-- (Despool), so a message it has no record of and never reported on is one it
-- never accepted. That is exactly the documented suppression case: nothing was
-- delivered, and a re-send is the correct response rather than a duplicate.
--
-- Bounded by the same SetRetryPolicy budget as a refusal, and sharing one budget
-- per message, so a permanently-suppressing wrapper cannot make the queue loop
-- forever. When the budget is spent the message is reported `reason = "lost"` and
-- the queue moves on rather than blocking behind it.
--
-- @return true if the message was re-queued for another attempt.
local function releaseStuck(q, key, since)
	local item = q.inFlightItem
	local pri  = q.inFlightPrio

	q.inFlightItem = nil
	-- Retires the in-flight send's identity, so a callback that arrives after the
	-- release belongs to a send nobody is waiting for and cannot advance the queue
	-- a second time. See sendNext.
	q.epoch  = (q.epoch or 0) + 1
	q.stalls = (q.stalls or 0) + 1
	-- Restart the no-progress clock: acting on the stall IS progress. Without
	-- this, every message enqueued during the retry backoff re-trips checkStall on
	-- the same stale timestamp, and the second pass — finding inFlightItem already
	-- taken — would release the slot mid-backoff and let the retry race whatever
	-- drained behind it.
	q.progressAt = GetTime and GetTime() or q.progressAt

	if scheduleRetry(key, pri, item) then
		-- The slot stays held through the backoff exactly as the refusal path does:
		-- the retry must keep its place ahead of everything queued behind it.
		dbg("drain(%s): stuck for %.0fs — re-sending", key, since or 0)
		return true
	end

	q.inFlight = false
	dbg("drain(%s): stuck for %.0fs and out of retries — abandoned, queue moving again",
		key, since or 0)
	-- Ordered before the drain so the host learns this message's fate BEFORE the
	-- next one goes out, which is the order a caller chaining sends expects.
	reportOutcome(item, 0, 0, nil, key, "lost")
	drain(key)
	return false
end

-- This detects and then RELEASES; it never re-sends. Releasing became safe once
-- the check could ask ChatThrottleLib whether the send still exists — before
-- that, clearing inFlight risked interleaving a new message's chunks with the
-- stuck one's, which is the corruption this library exists to prevent.
local function checkStall(q, key)
	local timeout = AceCommQueue.stallTimeout or 0
	if timeout <= 0 or not GetTime or not q.progressAt then return end

	-- Never trip inside a legitimate retry backoff: the queue is meant to be held
	-- there. Floor the threshold at twice the total backoff a full retry cycle can
	-- take, so a host that sets a long retryDelay cannot make every retry look
	-- like a stall.
	local attempts = AceCommQueue.retryAttempts or 0
	local backoff  = (AceCommQueue.retryDelay or 0) * ((2 ^ attempts) - 1)
	if timeout < backoff * 2 then timeout = backoff * 2 end

	local since = GetTime() - q.progressAt
	if since < timeout then return end

	-- Quiet is not the same as dead. A send CTL still holds is being retried and
	-- will report when it resolves, so there is nothing to tell anyone — and
	-- stallReported is deliberately NOT set, so if CTL later loses it the real
	-- stall is still reported.
	if ctlStillQueued(q) then
		dbg("drain(%s): %.0fs without progress, but ChatThrottleLib still holds the message "
			.. "— throttled, not stalled", key, since)
		return
	end

	-- inFlight with no message recorded means a retry for this queue is already
	-- backing off; it resumes on its own when the timer fires. Releasing the slot
	-- here would let the next message drain immediately and then get raced by that
	-- retry, putting two sends into CTL at once.
	if not q.inFlightItem then
		dbg("drain(%s): quiet for %.0fs but a retry is already pending — left alone",
			key, since)
		return
	end

	-- Loud ONCE per queue per session, then counted. A wrapper that suppresses
	-- every send would otherwise produce one error per message for as long as it
	-- lasts, and that trains people to ignore the error — the same silent failure
	-- by a slower route. The running total stays visible in /acq status.
	if (q.stalls or 0) == 0 then
		geterrorhandler()(string.format(
			"%s: queue STALLED — %.0fs with no progress on an in-flight send (queue=%s, "
			.. "%d message(s) waiting). ChatThrottleLib has no record of this message, so "
			.. "its callback was LOST rather than merely delayed. The usual cause is a "
			.. "SendCommMessage wrapper that suppressed a send without calling "
			.. "callbackFn(callbackArg, 0, 0, nil) to release the queue. The message is "
			.. "being re-sent and the queue released, so nothing is dropped and nothing "
			.. "stays blocked; further stalls here are counted in /acq status, not "
			.. "repeated.",
			MAJOR, since, tostring(key), #q.ALERT + #q.NORMAL + #q.BULK))
	else
		dbg("drain(%s): stalled again after %.0fs — stall #%d on this queue",
			key, since, (q.stalls or 0) + 1)
	end

	releaseStuck(q, key, since)
end

--- Force a stuck queue to let go of its in-flight send and carry on.
--
-- checkStall does this on its own after `stallTimeout` seconds. This is the
-- manual escape hatch for a queue that is stuck RIGHT NOW, so a player does not
-- have to sit out the timeout — `/acq unstick` calls exactly this.
--
-- Applies the SAME safety test as the automatic path: a queue whose message
-- ChatThrottleLib is still holding is left strictly alone, because releasing it
-- would let the next message's chunks interleave with the ones CTL has yet to
-- send. That is the corruption this library exists to prevent, and a manual
-- command is not a reason to bypass it. Released messages are re-sent under the
-- usual SetRetryPolicy budget, so this recovers the queue without dropping mail.
--
-- @param key  OPTIONAL queue key (as shown by /acq status, separators included).
--             Omit to sweep every stuck queue.
-- @return number of queues released, number skipped because CTL still had them.
function AceCommQueue:Unstick(key)
	-- Snapshot first: releasing runs host callbacks, and a host that sends from
	-- one can create a new queue — mutating self.queues mid-`pairs` is undefined.
	local stuck = {}
	for k, q in pairs(self.queues) do
		-- inFlightItem nil means a retry is already backing off for this queue —
		-- not stuck, and releasing it would let the retry race the next send.
		if (key == nil or k == key) and q.inFlight and q.inFlightItem then
			stuck[#stuck + 1] = k
		end
	end

	local released, held = 0, 0
	for _, k in ipairs(stuck) do
		local q = self.queues[k]
		if q and q.inFlight then
			if ctlStillQueued(q) then
				held = held + 1
				dbg("Unstick(%s): skipped — ChatThrottleLib still holds the message", k)
			else
				local since = (GetTime and q.progressAt) and (GetTime() - q.progressAt) or 0
				releaseStuck(q, k, since)
				released = released + 1
			end
		end
	end
	return released, held
end

-- Re-queue a refused message for another attempt, after a backoff.
-- @return true if a retry was scheduled (the caller must leave the queue blocked).
scheduleRetry = function(key, pri, item)
	local attempts = AceCommQueue.retryAttempts or 0
	if attempts <= 0 then return false end

	-- Fire-and-forget by design, so C_Timer.After is the right call and not a
	-- LibStub-consumer timer-discipline violation: nothing ever cancels this.
	-- Feature-detected because the .toc spans six client flavors, and retrying
	-- with no delay at all would hammer a channel the client just refused.
	if not (C_Timer and C_Timer.After) then
		dbg("drain(%s): send refused — no C_Timer, cannot back off, reporting instead", key)
		return false
	end

	item.retries = (item.retries or 0) + 1
	if item.retries > attempts then
		dbg("drain(%s): send refused — %d/%d retries exhausted, giving up (prefix=%s)",
			key, item.retries - 1, attempts, item.prefix)
		return false
	end

	local delay = (AceCommQueue.retryDelay or 1) * (2 ^ (item.retries - 1))
	dbg("drain(%s): send refused — retry %d/%d in %.1fs (prefix=%s)",
		key, item.retries, attempts, delay, item.prefix)

	C_Timer.After(delay, function()
		local q = AceCommQueue.queues[key]
		if not q then return end
		-- Back at the HEAD of its own priority bucket: a retry must not lose its
		-- place to messages queued behind it while it was backing off.
		table.insert(q[pri], 1, item)
		q.inFlight = false
		drain(key)
	end)
	return true
end

-- Submit the highest-priority queued message for `key`.
-- @return true if a message was submitted, false if every bucket was empty.
local function sendNext(q, key)
	for _, pri in ipairs(PRIO_ORDER) do
		local bucket = q[pri]
		if bucket and #bucket > 0 then
			local item = table.remove(bucket, 1)
			q.inFlight = true
			-- Start the no-progress clock. Reset on every chunk below.
			q.progressAt    = GetTime and GetTime() or nil
			-- Identify this send inside ChatThrottleLib's own queue, so a stall
			-- check can tell "CTL is still retrying it" from "its callback was
			-- lost". Recorded per send rather than derived from `key`, which is
			-- case-folded and cannot reproduce the exact arguments CTL stored.
			q.inFlightPrio   = pri
			q.inFlightPrefix = item.prefix
			q.inFlightDist   = item.dist
			q.inFlightTarget = item.target
			q.inFlightItem   = item
			-- Stamps THIS send. Stall recovery and Unstick both retire the stamp,
			-- so a callback that turns up afterwards — the late arrival that
			-- caused the stall in the first place — is recognised as belonging to
			-- a send nobody is waiting for, and cannot advance the queue a second
			-- time on top of whatever is running by then.
			q.epoch          = (q.epoch or 0) + 1
			local myEpoch  = q.epoch
			local userFn   = item.callbackFn
			local userArg  = item.callbackArg
			local finished = false

			dbg("drain(%s): sending prefix=%s dist=%s prio=%s qlen(A/N/B)=%d/%d/%d",
				key, item.prefix, item.dist or "GUILD", pri,
				#q.ALERT, #q.NORMAL, #q.BULK)

			-- AceComm fires callbackFn(callbackArg, bytesSentSoFar, totalBytes, sendResult)
			-- once per chunk. We detect the final chunk when sent >= total.
			-- Suppression signals (0, 0) satisfy 0 >= 0, unblocking stalled queues.
			--
			-- sendResult is ChatThrottleLib's didSend BOOLEAN for that chunk (AceComm
			-- drops CTL's result enum). It is watched on EVERY chunk, not just the
			-- last: a refused chunk in the middle of a multipart message still lets
			-- the final chunk report true, and forwarding that as the message's
			-- verdict claims a delivery that demonstrably did not happen — the
			-- receiver reassembles a corrupt payload from the chunks that survived.
			local refused = false
			local internalCb = function(_, sent, total, sendResult)
				-- A callback for a send this queue has already given up on: the
				-- stall recovery (or Unstick) released the slot and something else
				-- is running now. Acting on it would advance the queue on the wrong
				-- message's behalf and let two sends into CTL at once — the exact
				-- interleaving this library exists to prevent. The retry it
				-- triggered stands; this late arrival is simply ignored.
				if q.epoch ~= myEpoch then
					dbg("drain(%s): late callback for a released send — ignored", key)
					return
				end

				-- Only an explicit false is a refusal. A suppressing wrapper reports
				-- (0, 0, nil), and nil must never be read as failure.
				if sendResult == false then refused = true end

				-- Any chunk callback is progress, which is what the stall check
				-- measures against — a slow send must never look like a dead one.
				q.progressAt = GetTime and GetTime() or q.progressAt

				if sent and total and sent >= total then
					finished = true
					local delivered = not refused
					dbg("drain(%s): complete sent=%d total=%d delivered=%s suppressed=%s",
						key, sent, total, tostring(delivered),
						tostring(sent == 0 and total == 0))

					if not delivered and scheduleRetry(key, pri, item) then
						-- The queue stays inFlight through the backoff on purpose: a
						-- channel the client just refused is the last thing to pile
						-- more traffic onto, and holding the slot keeps this message
						-- ahead of everything queued behind it.
						return
					end

					-- Not `delivered and sendResult or false`: a suppressed send is
					-- delivered==true with sendResult==nil, and that idiom would
					-- turn its nil into a false.
					local verdict, reason = sendResult, nil
					if not delivered then
						verdict, reason = false, "refused"
					elseif verdict == nil then
						-- The documented suppression signal: a wrapper dropped this
						-- deliberately. Naming it keeps it distinguishable from the
						-- other nil outcomes, where a message was genuinely lost.
						reason = "suppressed"
					end

					q.inFlight     = false
					q.inFlightItem = nil
					reportOutcome(item, sent, total, verdict, key, reason)
					drain(key)
				end
			end

			-- Call the original SendCommMessage captured at Embed time directly,
			-- bypassing the queued dispatcher to prevent recursive re-queueing.
			-- pcall so a send error resets inFlight instead of stalling the queue.
			local ok, err = pcall(item.originalSend, item.commObj, item.prefix, item.text, item.dist, item.target, pri, internalCb)
			if not ok then
				dbg("drain(%s): send error (prefix=%s prio=%s): %s", key, item.prefix, pri, tostring(err))
				-- Keep the queue moving, but do not swallow the error: a send path
				-- that raises is a bug, and it belongs in the error handler — the
				-- same place it would land with no queue in the way.
				geterrorhandler()(err)
				-- Only report the message unsent if its callback has not already
				-- fired; an error raised AFTER the final chunk (by the caller's own
				-- callback, say) must not turn a delivered message into a failed one.
				if not finished then
					q.inFlight     = false
					q.inFlightItem = nil
					reportUnsent(userFn, userArg, "error")
					drain(key)
				end
			end
			return true
		end
	end
	-- All priority buckets empty — queue is idle.
	dbg("drain(%s): idle — all buckets empty", key)
	return false
end

drain = function(key)
	local q = AceCommQueue.queues[key]
	if not q or q.inFlight then
		dbg("drain(%s): skipped — %s", key, not q and "no queue" or "in-flight")
		-- Reached only when a caller enqueued behind an outstanding send, i.e. the
		-- moment a stall actually starts costing someone something.
		if q then checkStall(q, key) end
		return
	end

	if q.draining then
		-- Re-entrant call from a send that completed synchronously (CTL sends
		-- straight out whenever bandwidth allows, so this is the common case).
		-- Hand the work back to the loop below instead of recursing: recursing
		-- nests one pcall per queued message, and a large backlog then exhausts
		-- the interpreter's stack — at which point the pcall in sendNext swallows
		-- the overflow and messages disappear with no error at all.
		q.pending = true
		return
	end

	q.draining = true
	repeat
		q.pending = false
		local submitted = sendNext(q, key)
	until not (submitted and q.pending)
	q.draining = false
end

--- Embed AceCommQueue into an AceComm-3.0-enabled addon object.
--
-- Wraps the object's existing SendCommMessage with a queued dispatcher.
-- The original SendCommMessage (AceComm's, or any wrapper already on the object)
-- is called internally by the drain — all existing send paths continue to work.
--
-- Must be called AFTER AceComm-3.0 (and any SendCommMessage wrappers) have already
-- been set up, so the queue wraps the complete wrapper chain.
--
-- @param target  The addon table to embed into. Must already have SendCommMessage.
-- @return target (for chaining)
function AceCommQueue:Embed(target)
	if not (target and target.SendCommMessage) then
		dbg("Embed: target must have AceComm-3.0 embedded before AceCommQueue — skipped")
		return
	end
	if target.__AceCommQueue_embedded then
		dbg("Embed: AceCommQueue already embedded in this object — skipped")
		return
	end

	local originalSend = target.SendCommMessage
	local ACQ          = AceCommQueue  -- upvalue; avoids global lookup in hot path

	-- Replace SendCommMessage with the queued dispatcher.
	-- Signature matches AceComm-3.0's SendCommMessage exactly.
	target.SendCommMessage = function(commObj, prefix, text, dist, target_name, prio, callbackFn, callbackArg)
		prio = prio or "NORMAL"

		-- Input validation. A rejected message is still reported to the caller's
		-- callback as unsent, so a caller that chains its next send on that
		-- callback is not stranded by one bad argument.
		if type(prefix) ~= "string" or prefix == "" then
			dbg("enqueue: dropped — prefix must be a non-empty string, got %s", tostring(prefix))
			return reportUnsent(callbackFn, callbackArg, "rejected")
		end
		if text == nil then
			dbg("enqueue: dropped — text is nil (prefix=%s)", prefix)
			return reportUnsent(callbackFn, callbackArg, "rejected")
		end
		if prio ~= "ALERT" and prio ~= "NORMAL" and prio ~= "BULK" then
			dbg("enqueue: dropped — invalid priority '%s', must be ALERT/NORMAL/BULK (prefix=%s)", tostring(prio), prefix)
			return reportUnsent(callbackFn, callbackArg, "rejected")
		end

		local key = makeKey(prefix, dist, target_name)

		if not ACQ.queues[key] then
			ACQ.queues[key] = {
				inFlight = false,
				ALERT    = {},
				NORMAL   = {},
				BULK     = {},
			}
		end

		local q = ACQ.queues[key]
		dbg("enqueue: prefix=%s dist=%s prio=%s inFlight=%s qlen(A/N/B)=%d/%d/%d",
			prefix, dist or "GUILD", prio, tostring(q.inFlight),
			#q.ALERT, #q.NORMAL, #q.BULK)

		table.insert(q[prio], {
			prefix       = prefix,
			text         = text,
			dist         = dist,
			target       = target_name,
			callbackFn   = callbackFn,
			callbackArg  = callbackArg,
			commObj      = commObj,
			originalSend = originalSend,
		})

		drain(key)
	end

	target.__AceCommQueue_embedded = true
	return target
end
