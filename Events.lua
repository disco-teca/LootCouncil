LootCouncil.Events = {}

local frame = CreateFrame("Frame")

---------------------------------------------------
-- Event Handlers
---------------------------------------------------

local handlers = {}

---------------------------------------------------
-- PLAYER_LOGIN
---------------------------------------------------

handlers.PLAYER_LOGIN = function()
    LootCouncil:Initialize()
    LootCouncil.Roster:Refresh()
end

---------------------------------------------------
-- RAID_ROSTER_UPDATE
---------------------------------------------------

handlers.RAID_ROSTER_UPDATE = function()
    LootCouncil.Roster:Refresh()

    if not LootCouncil.Session:IsActive() then
        LootCouncil.UI.SettingsTab:Refresh()
        return
    end

    if LootCouncil.Session:IsOwnerPresent() then
        return
    end

    local raidLeader = LootCouncil.Session:GetRaidLeader()
    if not raidLeader then
        return
    end

    local playerName = UnitName("player")
    if raidLeader ~= playerName then
        return
    end

    local message = LootCouncil.Message:New(
        "SESSION_OWNER_CHANGED",
        {
            owner = raidLeader,
            reason = "FALLBACK",
        }
    )
    LootCouncil.MessageBus:Route(message, playerName)
end

---------------------------------------------------
-- PARTY_LEADER_CHANGED
---------------------------------------------------

handlers.PARTY_LEADER_CHANGED = function()
    LootCouncil.Session:OnRaidLeaderChanged()
end

---------------------------------------------------
-- CHAT_MSG_WHISPER
---------------------------------------------------

handlers.CHAT_MSG_WHISPER = function(message, sender, ...)
    LootCouncil.Chat:OnWhisper(sender, message)
end

---------------------------------------------------
-- CHAT_MSG_RAID
---------------------------------------------------

handlers.CHAT_MSG_RAID = function(message, sender, ...)
    LootCouncil.Events:OnChatMessage("RAID", message, sender)
end

---------------------------------------------------
-- CHAT_MSG_RAID_WARNING
---------------------------------------------------

handlers.CHAT_MSG_RAID_WARNING = function(message, sender, ...)
    LootCouncil.Events:OnChatMessage("RAID_WARNING", message, sender)
end

---------------------------------------------------
-- CHAT_MSG_PARTY
---------------------------------------------------

handlers.CHAT_MSG_PARTY = function(message, sender, ...)
    LootCouncil.Events:OnChatMessage("PARTY", message, sender)
end

---------------------------------------------------
-- CHAT_MSG_PARTY_LEADER
---------------------------------------------------

handlers.CHAT_MSG_PARTY_LEADER = function(message, sender, ...)
    LootCouncil.Events:OnChatMessage("PARTY_LEADER", message, sender)
end

---------------------------------------------------
-- CHAT_MSG_SYSTEM
---------------------------------------------------

handlers.CHAT_MSG_SYSTEM = function(message, ...)
    LootCouncil.Events:OnChatMessage("SYSTEM", message, nil)
end

---------------------------------------------------
-- OnChatMessage
---------------------------------------------------

function LootCouncil.Events:OnChatMessage(event, message, sender)
    -- Pattern: "Discoo rolls 86 (1-100)"
    local rollPattern = "(%S+) rolls (%d+) %((%d+)%-?(%d+)%)"
    local name, roll, minRoll, maxRoll = string.match(message, rollPattern)
    
    if name and roll then
        LootCouncil.Roll:TrackRoll(name, tonumber(roll), tonumber(maxRoll))
    end
end

---------------------------------------------------
-- Dispatcher
---------------------------------------------------

frame:SetScript("OnEvent", function(self, event, ...)
    local handler = handlers[event]
    if handler then
        handler(...)
    end
end)

---------------------------------------------------
-- Registration
---------------------------------------------------

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("PARTY_LEADER_CHANGED")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_RAID_WARNING")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
frame:RegisterEvent("CHAT_MSG_SYSTEM")