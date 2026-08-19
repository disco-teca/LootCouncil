---------------------------------------------------
-- Message Object
---------------------------------------------------

LootCouncil.Message = {}

local Message = {}
Message.__index = Message

LootCouncil.Message = Message

---------------------------------------------------
-- Constants
---------------------------------------------------

Message.VERSION = 1

---------------------------------------------------
-- Constructor
---------------------------------------------------

function Message:New(

    command,

    payload

)

    local message = {

        command = command,

        version = Message.VERSION,

        payload = payload or {}

    }

    setmetatable(

        message,

        Message

    )

    return message

end

---------------------------------------------------
-- Command
---------------------------------------------------

function Message:GetCommand()

    return self.command

end

---------------------------------------------------
-- Version
---------------------------------------------------

function Message:GetVersion()

    return self.version

end

---------------------------------------------------
-- Payload
---------------------------------------------------

function Message:GetPayload()

    return self.payload

end

---------------------------------------------------
-- Export
---------------------------------------------------

function Message:Export()

    return {

        command = self.command,

        version = self.version,

        payload = self.payload

    }

end

---------------------------------------------------
-- Import
---------------------------------------------------

function Message.Import(data)

    if type(data) ~= "table" then
        return nil
    end

    local message = Message:New(

        data.command,

        data.payload

    )

    if data.version then

        message.version = data.version

    end

    return message

end

---------------------------------------------------
-- Validation
---------------------------------------------------

function Message:IsValid()

    if type(self.command) ~= "string" then
        return false
    end

    if type(self.version) ~= "number" then
        return false
    end

    if type(self.payload) ~= "table" then
        return false
    end

    return true

end