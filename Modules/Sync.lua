LootCouncil.Sync = {}

local module = LootCouncil.Sync

local syncInProgress = false
local syncStartTime = nil
local SYNC_TIMEOUT = 10  -- seconds

---------------------------------------------------
-- Trigger State
---------------------------------------------------

local lastTriggerTime = nil
local TRIGGER_COOLDOWN = 10  -- seconds

local STAGGER_RAID = 2      -- seconds (max)
local STAGGER_COUNCIL = 3   -- seconds (max)

---------------------------------------------------
-- Auto-Sync State
---------------------------------------------------

local wasInRaid = false
local lastQueryTime = nil
local QUERY_DEBOUNCE = 2    -- seconds

---------------------------------------------------
-- Message Types
---------------------------------------------------

local REQUEST_RAIDER = "REQUEST_RAIDER_SYNC"
local RESPONSE_RAIDER = "RESPONSE_RAIDER_SYNC"
local QUERY = "SESSION_QUERY"
local ANNOUNCE = "SESSION_ANNOUNCE"

---------------------------------------------------
-- Trigger Message Types
---------------------------------------------------

local TRIGGER_RAID = "SYNC_RAID_TRIGGER"
local TRIGGER_COUNCIL = "SYNC_COUNCIL_TRIGGER"
local TRIGGER_PLAYER = "SYNC_PLAYER_TRIGGER"

---------------------------------------------------
-- Helper: Cooldown
---------------------------------------------------

function module:IsOnCooldown()

    if not lastTriggerTime then
        return false
    end

    return (time() - lastTriggerTime) < TRIGGER_COOLDOWN

end

function module:StampCooldown()

    lastTriggerTime = time()

end

---------------------------------------------------
-- Helper: Should Ignore Trigger
---------------------------------------------------

function module:ShouldIgnoreTrigger(isTargeted)

    ---------------------------------------------------
    -- Targeted triggers bypass the cooldown
    ---------------------------------------------------

    if not isTargeted and self:IsOnCooldown() then
        return true
    end

    ---------------------------------------------------
    -- Any trigger is ignored if a sync is already running
    ---------------------------------------------------

    if syncInProgress and not self:IsSyncStale() then
        return true
    end

    return false

end

---------------------------------------------------
-- Helper: Stagger
---------------------------------------------------

function module:StaggerThen(maxDelay, callback)

    local delay = math.random() * maxDelay

    C_Timer.After(delay, callback)

end

---------------------------------------------------
-- Helper: Council Sync Wrapper
---------------------------------------------------

function module:PerformCouncilSync()

    self:RequestResponses()
    self:RequestVotes()
    self:RequestSyncGear()

end

---------------------------------------------------
-- Trigger Senders
---------------------------------------------------

function module:TriggerRaidSync()

    if not LootCouncil.Session:IsOwner() then
        return
    end

    if not LootCouncil.Session:IsActive() then
        LootCouncil:Print("No active session.")
        return
    end

    local message = LootCouncil.Message:New(TRIGGER_RAID, {})

    LootCouncil.MessageBus:Route(message, UnitName("player"))

    LootCouncil:Print("Raid sync trigger sent.")

end

function module:TriggerCouncilSync()

    if not LootCouncil.Session:IsOwner() then
        return
    end

    if not LootCouncil.Session:IsActive() then
        LootCouncil:Print("No active session.")
        return
    end

    local owner = UnitName("player")

    local councilMembers = LootCouncil.Session:GetCouncilMembers()

    local sentCount = 0

    for _, memberName in ipairs(councilMembers) do

        if memberName ~= owner then

            local message = LootCouncil.Message:New(TRIGGER_COUNCIL, {
                target = memberName,
            })

            LootCouncil.MessageBus:Route(message, owner)

            sentCount = sentCount + 1

        end

    end

    LootCouncil:Print("Council sync trigger sent to " .. sentCount .. " member(s).")

end

function module:TriggerPlayerSync(playerName)

    if not LootCouncil.Session:IsOwner() then
        return
    end

    if not LootCouncil.Session:IsActive() then
        LootCouncil:Print("No active session.")
        return
    end

    if not playerName or playerName == "" then
        LootCouncil:Print("Usage: player name required.")
        return
    end

    local owner = UnitName("player")

    local raidMessage = LootCouncil.Message:New(TRIGGER_RAID, {
        target = playerName,
    })

    LootCouncil.MessageBus:Route(raidMessage, owner)

    local councilMessage = LootCouncil.Message:New(TRIGGER_COUNCIL, {
        target = playerName,
    })

    LootCouncil.MessageBus:Route(councilMessage, owner)

    LootCouncil:Print("Player sync trigger sent to " .. playerName .. ".")

end

---------------------------------------------------
-- Trigger Receivers
---------------------------------------------------

function module:OnSyncRaidTrigger(message, sender)

    ---------------------------------------------------
    -- Ignore if we sent it (we're the owner)
    ---------------------------------------------------

    if sender == UnitName("player") then
        return
    end

    ---------------------------------------------------
    -- If targeted, only act if it's for me
    ---------------------------------------------------

    local payload = message:GetPayload()

    if payload and payload.target
    and payload.target ~= UnitName("player") then
        return
    end

    ---------------------------------------------------
    -- Drop if on cooldown or mid-sync
    ---------------------------------------------------

    if self:ShouldIgnoreTrigger(false) then
        return
    end

    ---------------------------------------------------
    -- Stamp cooldown and stagger
    ---------------------------------------------------

    self:StampCooldown()

    self:StaggerThen(STAGGER_RAID, function()
        self:RequestRaiderSync()
    end)

end

function module:OnSyncCouncilTrigger(message, sender)

    ---------------------------------------------------
    -- Ignore if we sent it
    ---------------------------------------------------

    if sender == UnitName("player") then
        return
    end

    ---------------------------------------------------
    -- Only council members act on this
    ---------------------------------------------------

    if not LootCouncil.Session:IsCouncil(UnitName("player")) then
        return
    end

    ---------------------------------------------------
    -- If targeted, only act if it's for me
    ---------------------------------------------------

    local payload = message:GetPayload()

    if payload and payload.target
    and payload.target ~= UnitName("player") then
        return
    end

    ---------------------------------------------------
    -- Drop if on cooldown or mid-sync
    ---------------------------------------------------

    if self:ShouldIgnoreTrigger(false) then
        return
    end

    ---------------------------------------------------
    -- Stamp cooldown and stagger
    ---------------------------------------------------

    self:StampCooldown()

    self:StaggerThen(STAGGER_COUNCIL, function()
        self:PerformCouncilSync()
    end)

end

function module:OnSyncPlayerTrigger(message, sender)

    ---------------------------------------------------
    -- Ignore if we sent it
    ---------------------------------------------------

    if sender == UnitName("player") then
        return
    end

    ---------------------------------------------------
    -- Must be targeted at me
    ---------------------------------------------------

    local payload = message:GetPayload()

    if not payload or not payload.target then
        return
    end

    if payload.target ~= UnitName("player") then
        return
    end

    ---------------------------------------------------
    -- Targeted sync bypasses cooldown but respects lock
    ---------------------------------------------------

    if self:ShouldIgnoreTrigger(true) then
        return
    end

    ---------------------------------------------------
    -- Stamp cooldown and sync immediately
    ---------------------------------------------------

    self:StampCooldown()

    self:RequestRaiderSync()

    if LootCouncil.Session:IsCouncil(UnitName("player")) then
        self:PerformCouncilSync()
    end

end

---------------------------------------------------
-- Auto-Sync On Join
---------------------------------------------------

function module:ConsiderAutoSync()

    ---------------------------------------------------
    -- Am I in a raid?
    ---------------------------------------------------

    local amIInRaid = GetNumRaidMembers() > 0
        and UnitInRaid("player") ~= nil

    ---------------------------------------------------
    -- If not in a raid, reset and bail
    ---------------------------------------------------

    if not amIInRaid then
        wasInRaid = false
        return
    end

    ---------------------------------------------------
    -- If I was already in the raid, nothing changed
    ---------------------------------------------------

    if wasInRaid then
        return
    end

    ---------------------------------------------------
    -- I just joined a raid
    ---------------------------------------------------

    wasInRaid = true

    ---------------------------------------------------
    -- Reload carve-out: if I already have a session,
    -- Persistence:Load restored it. Nothing to sync.
    ---------------------------------------------------

    if LootCouncil.Session:IsActive() then
        return
    end

    ---------------------------------------------------
    -- Double-fire safety
    ---------------------------------------------------

    if lastQueryTime
    and (time() - lastQueryTime) < QUERY_DEBOUNCE then
        return
    end

    ---------------------------------------------------
    -- Query for an active session
    ---------------------------------------------------

    lastQueryTime = time()

    self:RequestSessionQuery()

end

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()
    LootCouncil.MessageBus:Register(
        REQUEST_RAIDER,
        self,
        self.OnRaiderSyncRequest
    )

    LootCouncil.MessageBus:Register(
        RESPONSE_RAIDER,
        self,
        self.OnRaiderSyncResponse
    )

    LootCouncil.MessageBus:Register(
        QUERY,
        self,
        self.OnSessionQuery
    )

    LootCouncil.MessageBus:Register(
        ANNOUNCE,
        self,
        self.OnSessionAnnounce
    )

    ---------------------------------------------------
    -- Trigger Handlers
    ---------------------------------------------------

    LootCouncil.MessageBus:Register(
        TRIGGER_RAID,
        self,
        self.OnSyncRaidTrigger
    )

    LootCouncil.MessageBus:Register(
        TRIGGER_COUNCIL,
        self,
        self.OnSyncCouncilTrigger
    )

    LootCouncil.MessageBus:Register(
        TRIGGER_PLAYER,
        self,
        self.OnSyncPlayerTrigger
    )
end

---------------------------------------------------
-- Utility
---------------------------------------------------

function module:IsSyncStale()
    if not syncInProgress then
        return false
    end
    if not syncStartTime then
        return true
    end
    return (time() - syncStartTime) > SYNC_TIMEOUT
end

function module:ClearSyncLock()
    syncInProgress = false
    syncStartTime = nil
end

---------------------------------------------------
-- Session Query (Discovery)
---------------------------------------------------

function module:RequestSessionQuery()
    if LootCouncil.Session:IsActive() then
        LootCouncil:Print("You already have an active session.")
        return
    end

    local message = LootCouncil.Message:New(
        QUERY,
        {
            requester = UnitName("player"),
            timestamp = time(),
        }
    )

    LootCouncil.MessageBus:Route(message, UnitName("player"))
end

function module:OnSessionQuery(message, sender)
    -- Only the session owner responds
    if not LootCouncil.Session:IsOwner() then
        return
    end

    if not LootCouncil.Session:IsActive() then
        return
    end

    if sender == UnitName("player") then
        return
    end

    local announce = LootCouncil.Message:New(
        ANNOUNCE,
        {
            owner = LootCouncil.Session:GetOwner(),
            timestamp = time(),
        }
    )

    LootCouncil.MessageBus:Route(announce, sender)
end

function module:OnSessionAnnounce(message, sender)
    local payload = message:GetPayload()
    if not payload or not payload.owner then
        return
    end

    -- Ignore if we already have a local session
    if LootCouncil.Session:IsActive() then
        syncInProgress = false
        return
    end

    -- Ignore if we're the owner (shouldn't happen)
    if payload.owner == UnitName("player") then
        syncInProgress = false
        return
    end

    -- If sync is already in progress, this is a continuation, not a duplicate
    if syncInProgress then
        -- Don't return! Continue to the sync request below.
    else
        -- First time we're hearing about this session
        syncInProgress = true
        syncStartTime = time()
    end

    -- No roles anymore — everyone gets raider sync
    module:RequestRaiderSync()
end

---------------------------------------------------
-- Manual Sync Entry Point
---------------------------------------------------

function module:RequestSync()
    local playerName = UnitName("player")

    if syncInProgress then
        if module:IsSyncStale() then
            module:ClearSyncLock()
            LootCouncil:Print("Cleared stale sync lock.")
        else
            LootCouncil:Print("Sync already in progress. Please wait.")
            return
        end
    end

    if LootCouncil.Session:IsOwner() then
        LootCouncil:Print("You are the session owner. No sync needed.")
        return
    end

    if not LootCouncil.Session:IsActive() then
        syncInProgress = true
        syncStartTime = time()
        module:RequestSessionQuery()
        return
    end

    -- No roles anymore — everyone gets raider sync
    module:RequestRaiderSync()
end

---------------------------------------------------
-- Raider Sync
---------------------------------------------------

function module:RequestRaiderSync()
    if LootCouncil.Session:IsOwner() then
        return
    end

    local message = LootCouncil.Message:New(
        REQUEST_RAIDER,
        {
            requester = UnitName("player"),
            timestamp = time(),
        }
    )

    LootCouncil.MessageBus:Route(message, UnitName("player"))
end

function module:OnRaiderSyncRequest(message, sender)
    if not LootCouncil.Session:IsOwner() then
        return
    end

    if not LootCouncil.Session:IsActive() then
        return
    end

    if sender == UnitName("player") then
        return
    end

    local snapshot = LootCouncil.Session:SerializeRaiderSnapshot(sender)
    if not snapshot then
        LootCouncil:Print("Failed to generate raider snapshot for " .. sender)
        return
    end

    local response = LootCouncil.Message:New(
        RESPONSE_RAIDER,
        {
            target = sender,
            responder = UnitName("player"),
            snapshot = snapshot,
        }
    )

    LootCouncil.MessageBus:Route(response, UnitName("player"))
end

function module:OnRaiderSyncResponse(message, sender)
    local payload = message:GetPayload()
    if not payload then
        module:ClearSyncLock()
        return
    end

    if payload.target and payload.target ~= UnitName("player") then
        return
    end

    if not payload.snapshot then
        module:ClearSyncLock()
        return
    end

    if LootCouncil.Session:IsOwner() then
        module:ClearSyncLock()
        return
    end

    local success = LootCouncil.Session:DeserializeRaiderSnapshot(
        payload.snapshot,
        UnitName("player")
    )

    if success then
        -- Tell the owner that we've joined the session
        local announceMessage = LootCouncil.Message:New(
            "PLAYER_JOINED",
            {
                player = UnitName("player"),
                timestamp = time(),
            }
        )
        LootCouncil.MessageBus:Route(announceMessage, UnitName("player"))
    end

    module:ClearSyncLock()
end

---------------------------------------------------
-- Gear Request (specific player)
---------------------------------------------------

function module:RequestGearFromPlayer(playerName)
    local items = LootCouncil.Session:GetItems() or {}

    for _, item in ipairs(items) do
        local comparisonSlots = LootCouncil.Comparison:GetComparisonSlots(item) or {}

        local gearRequest = LootCouncil.Message:New(
            "OWNER_GEAR_REQUEST",
            {
                target = playerName,
                itemNumber = item:GetNumber(),
                slots = comparisonSlots,
            }
        )

        LootCouncil.MessageBus:Route(gearRequest, UnitName("player"))
    end
end

---------------------------------------------------
-- Council Data Sync Helpers
---------------------------------------------------

function module:RequestResponses()
    local players = LootCouncil.Session:GetPlayers() or {}

    for _, player in ipairs(players) do
        local playerName = player:GetName()

        if playerName and playerName ~= UnitName("player") then
            local message = LootCouncil.Message:New(
                "REQUEST_RESPONSES",
                {
                    target = playerName,
                }
            )
            LootCouncil.MessageBus:Route(message, UnitName("player"))
        end
    end
end

function module:RequestVotes()
    local councilMembers = LootCouncil.Session:GetCouncilMembers() or {}

    for _, member in ipairs(councilMembers) do
        if member ~= UnitName("player") then
            local message = LootCouncil.Message:New(
                "REQUEST_VOTES",
                {
                    target = member,
                }
            )
            LootCouncil.MessageBus:Route(message, UnitName("player"))
        end
    end
end

function module:RequestSyncGear()
    local players = LootCouncil.Session:GetPlayers() or {}
    local items = LootCouncil.Session:GetItems() or {}

    -- Request gear from all players
    for _, item in ipairs(items) do
        local comparisonSlots = LootCouncil.Comparison:GetComparisonSlots(item) or {}

        for _, player in ipairs(players) do
            local playerName = player:GetName()

            if playerName and playerName ~= UnitName("player") then
                local message = LootCouncil.Message:New(
                    "SYNC_GEAR_REQUEST",
                    {
                        target = playerName,
                        itemNumber = item:GetNumber(),
                        slots = comparisonSlots,
                    }
                )
                LootCouncil.MessageBus:Route(message, UnitName("player"))
            end
        end
    end

    -- Also request own gear locally
    local myName = UnitName("player")

    for _, item in ipairs(items) do
        local comparisonSlots = LootCouncil.Comparison:GetComparisonSlots(item) or {}

        local payload = {
            target = myName,
            itemNumber = item:GetNumber(),
            slots = comparisonSlots,
        }

        LootCouncil.Session:OnSyncGearRequest(
            { GetPayload = function() return payload end },
            myName
        )
    end
end