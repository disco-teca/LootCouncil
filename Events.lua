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

    if LootCouncil.Session:IsActive() then

        local owner =
            LootCouncil.Session:GetOwner()

        local present =
            LootCouncil.Session:IsOwnerPresent()

        LootCouncil:Print(
            "Session owner: " ..
            tostring(owner)
        )

        LootCouncil:Print(
            "Owner present: " ..
            tostring(present)
        )

    else

        LootCouncil.UI.SettingsTab:Refresh()

    end

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

---------------------------------------------------
-- CHAT_MSG_WHISPER
---------------------------------------------------

handlers.CHAT_MSG_WHISPER = function(

    message,

    sender,

    ...

)

    LootCouncil.Chat:OnWhisper(

        sender,

        message

    )

end