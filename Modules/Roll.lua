LootCouncil.Roll = {}

local module = LootCouncil.Roll

---------------------------------------------------
-- State
---------------------------------------------------

local activeRoll = nil        -- Current active roll session
local rollHistory = {}        -- History of completed rolls

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()
    -- Register chat event to capture rolls
    -- We'll hook this in Events.lua
end

---------------------------------------------------
-- Start a Roll
---------------------------------------------------

function module:StartRoll(item, rollType)
    if not item or not rollType then
        return
    end

    -- Cancel any existing roll
    if activeRoll then
        self:CancelRoll()
    end

    -- Create new roll session
    activeRoll = {
        item = item,
        rollType = rollType,
        isActive = true,
        isClosed = false,
        timer = nil,
        rolls = {},
        startTime = time(),
        winner = nil,
        timerStarted = false,
        remainingTime = nil,
    }

    -- Send raid warning
    local message = string.format(
        "Roll %s for %s!",
        rollType,
        item:GetLink()
    )
    SendChatMessage(message, "RAID_WARNING")

    -- Refresh the Loot tab
    LootCouncil.UI.LootTab:Refresh()

    -- Update Voting tab
    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.Persistence:Save()
    LootCouncil:Print("Roll started for " .. item:GetName() .. " (" .. rollType .. ")")
end

---------------------------------------------------
-- Track a Roll
---------------------------------------------------

function module:TrackRoll(playerName, rollNumber, maxRoll)
    
    if not activeRoll or not activeRoll.isActive or activeRoll.isClosed then
        return
    end

    -- Determine roll type based on maxRoll
    local rollType = nil
    if maxRoll == 100 then
        rollType = "MS"
    elseif maxRoll == 99 then
        rollType = "OS"
    else
        return
    end

    if activeRoll.rolls[playerName] then
        return
    end

    activeRoll.rolls[playerName] = {
        roll = rollNumber,
        type = rollType,
    }

    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.Persistence:Save()
end

---------------------------------------------------
-- Start Timer
---------------------------------------------------

function module:StartTimer()
    if not activeRoll or activeRoll.isClosed then
        return
    end

    if activeRoll.timerStarted then
        return
    end

    activeRoll.timerStarted = true
    local remaining = 15
    activeRoll.remainingTime = remaining  -- <-- Store as number

    -- Update Voting tab with timer
    LootCouncil.UI.VotingTab:UpdateTimer(remaining)

    local function countdown()
        if not activeRoll or activeRoll.isClosed then
            return
        end

        remaining = remaining - 1
        activeRoll.remainingTime = remaining  -- <-- Update the number

        if remaining <= 0 then
            self:CloseRoll()
            return
        end

        -- Announce at specific intervals
        if remaining == 10 then
            SendChatMessage("10 seconds left to roll!", "RAID")
        elseif remaining == 5 then
            SendChatMessage("5 seconds left to roll!", "RAID")
        end

        -- Update UI
        LootCouncil.UI.VotingTab:UpdateTimer(remaining)
        self:UpdatePopupTimer(remaining)

        activeRoll.timer = C_Timer.After(1, countdown)
    end

    activeRoll.timer = C_Timer.After(1, countdown)
    LootCouncil:Print("Timer started! 15 seconds remaining.")
end

---------------------------------------------------
-- Close Roll
---------------------------------------------------

function module:CloseRoll()
    if not activeRoll or activeRoll.isClosed then
        return
    end

    activeRoll.isClosed = true

    if activeRoll.timer then
        activeRoll.timer:Cancel()
        activeRoll.timer = nil
    end

    -- Determine winner
    local winner = nil
    local highestRoll = 0

    for playerName, data in pairs(activeRoll.rolls) do
        if data.roll > highestRoll then
            highestRoll = data.roll
            winner = playerName
        end
    end

    activeRoll.winner = winner

    -- Store in history
    table.insert(rollHistory, {
        itemNumber = activeRoll.item:GetNumber(),
        itemName = activeRoll.item:GetName(),
        itemLink = activeRoll.item:GetLink(),
        rollType = activeRoll.rollType,
        winner = winner,
        rolls = activeRoll.rolls,
        timestamp = time(),
    })

    -- Announce winner
    if winner then
        SendChatMessage(string.format(
            "%s won %s with a roll of %d!",
            winner,
            activeRoll.item:GetLink(),
            highestRoll
        ), "RAID")
    else
        SendChatMessage(string.format(
            "No rolls for %s. Skipping.",
            activeRoll.item:GetLink()
        ), "RAID")
    end

    -- DO NOT lock buttons here — the item will be removed when awarded

    -- Update UI
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.Persistence:Save()
    LootCouncil:Print("Roll closed. Winner: " .. (winner or "None"))
end

---------------------------------------------------
-- Cancel Roll
---------------------------------------------------

function module:CancelRoll()
    if not activeRoll then
        return
    end

    if activeRoll.timer then
        activeRoll.timer:Cancel()
        activeRoll.timer = nil
    end

    -- DO NOT lock buttons here

    activeRoll = nil
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.Persistence:Save()
    LootCouncil:Print("Roll cancelled.")
end

---------------------------------------------------
-- Is Roll Active?
---------------------------------------------------

function module:IsActive()
    return activeRoll ~= nil and activeRoll.isActive and not activeRoll.isClosed
end

---------------------------------------------------
-- Get Active Roll
---------------------------------------------------

function module:GetActiveRoll()
    return activeRoll
end

---------------------------------------------------
-- Get Roll History
---------------------------------------------------

function module:GetHistory()
    return rollHistory
end

---------------------------------------------------
-- Get Roll History for a Specific Item
---------------------------------------------------

function module:GetHistoryForItem(itemNumber)
    local history = {}
    for _, entry in ipairs(rollHistory) do
        if entry.itemNumber == itemNumber then
            table.insert(history, entry)
        end
    end
    return history
end