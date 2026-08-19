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
    -- Register Listeners
    ---------------------------------------------------

    LootCouncil.MessageBus:Register(

        "PLAYER_DATA_UPDATED",

        self,

        self.OnPlayerDataUpdated

    )

    LootCouncil.MessageBus:Register(

        "PLAYER_DATA_SYNC",

        self,

        self.OnPlayerDataSync

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

        LootCouncil:Print("--------------------------------")
        LootCouncil:Print("DESERIALIZE FAILED")
        LootCouncil:Print("Sender: " .. tostring(sender))
        LootCouncil:Print("Channel: " .. tostring(channel))
        LootCouncil:Print("Prefix: " .. tostring(prefix))
        LootCouncil:Print("Payload:")
        LootCouncil:Print(tostring(serialized))

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

---------------------------------------------------
-- Player Data Updated
---------------------------------------------------

function module:OnPlayerDataUpdated(

    message,

    sender

)

    local playerName =

        message:GetPayload().player

    local exportedData =

        LootCouncil.PlayerData:CreateSyncPacket(

            playerName

        )

    local sync =

        LootCouncil.Message:New(

            "PLAYER_DATA_SYNC",

            {

                player = playerName,

                data = exportedData,

            }

        )

    LootCouncil.MessageBus:Transport(

        sync,

        sender

    )

end

---------------------------------------------------
-- Player Data Sync
---------------------------------------------------

function module:OnPlayerDataSync(

    message,

    sender

)

    LootCouncil.PlayerData:ApplySyncPacket(

        message:GetPayload()

    )

end