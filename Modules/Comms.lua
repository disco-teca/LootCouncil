LootCouncil.Comms = {}

local module = LootCouncil.Comms

---------------------------------------------------
-- Constants
---------------------------------------------------

local PREFIX = "LC_DEBUG_01"

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

    ---------------------------------------------------
    -- Libraries
    ---------------------------------------------------

    local AceComm =
        LibStub("AceComm-3.0")

    self.Serializer =
        LibStub("AceSerializer-3.0")

    ---------------------------------------------------
    -- Embed AceComm
    ---------------------------------------------------

    AceComm:Embed(self)

    ---------------------------------------------------
    -- Register Prefix
    ---------------------------------------------------

    self:RegisterComm(

        PREFIX,

        "Receive"

    )

    ---------------------------------------------------
    -- Register Transport
    ---------------------------------------------------

    LootCouncil.MessageBus:RegisterTransport(

        self,

        self.Route

    )

    ---------------------------------------------------
    -- Ready
    ---------------------------------------------------

    LootCouncil:Print(
        "Comms initialized."
    )

end

---------------------------------------------------
-- Route
---------------------------------------------------

function module:Route(

    message,

    sender

)

    ---------------------------------------------------
    -- Validation
    ---------------------------------------------------

    if not message or not message:IsValid() then

        LootCouncil:Print(

            "Attempted to route an invalid message."

        )

        return

    end

    ---------------------------------------------------
    -- Determine Channel
    ---------------------------------------------------

    local channel

    if GetNumRaidMembers() > 0 then

        channel = "RAID"

    elseif GetNumPartyMembers() > 0 then

        channel = "PARTY"

    else

        LootCouncil:Print(

            "No party or raid."

        )

        return

    end

    ---------------------------------------------------
    -- Serialize
    ---------------------------------------------------

    local serialized =

        self.Serializer:Serialize(

            message:Export()

        )

    if message:GetCommand() == "SESSION_SYNC_RESPONSE" then

        LootCouncil:Print(
            "SYNC SEND: " ..
            tostring(string.len(serialized)) ..
            " bytes"
        )

    end
    ---------------------------------------------------
    -- Send
    ---------------------------------------------------
    
    self:SendCommMessage(

        PREFIX,

        serialized,

        channel

    )

end

function module:Receive(

    prefix,

    serialized,

    channel,

    sender

)

    ---------------------------------------------------
    -- Prefix
    ---------------------------------------------------

    if prefix ~= PREFIX then

        LootCouncil:Print(
            "Incorrect prefix."
        )

        return

    end

    ---------------------------------------------------
    -- Ignore Ourselves
    ---------------------------------------------------

    if sender == UnitName("player") then

        return

    end

    ---------------------------------------------------
    -- Deserialize
    ---------------------------------------------------

    local success, data =

        self.Serializer:Deserialize(

            serialized

        )

    if not success then

        LootCouncil:Print(
            "Failed to deserialize message from " ..
            tostring(sender)
        )

        return

    end

    ---------------------------------------------------
    -- Import Message
    ---------------------------------------------------

    local message =

        LootCouncil.Message.Import(

            data

        )

    if not message then

        LootCouncil:Print("--------------------------------")
        LootCouncil:Print("INVALID MESSAGE")
        LootCouncil:Print("Sender: " .. tostring(sender))
        LootCouncil:Print("Channel: " .. tostring(channel))
        LootCouncil:Print("Type: " .. tostring(data.type))

        return

    end

    ---------------------------------------------------
    -- Publish
    ---------------------------------------------------

    LootCouncil.MessageBus:Publish(

        message,

        sender

    )

end