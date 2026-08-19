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
