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
-- GROUP_ROSTER_UPDATE
---------------------------------------------------

handlers.GROUP_ROSTER_UPDATE = function()

    LootCouncil.Roster:Refresh()

    if not LootCouncil.Session:IsActive() then

        LootCouncil.UI.SettingsTab:Refresh()

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
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("CHAT_MSG_WHISPER")

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