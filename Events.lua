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