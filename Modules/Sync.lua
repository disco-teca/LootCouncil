LootCouncil.Sync = {}

local module = LootCouncil.Sync

---------------------------------------------------
-- Constants
---------------------------------------------------

local REQUEST =
    "SESSION_SYNC_REQUEST"

local RESPONSE =
    "SESSION_SYNC_RESPONSE"

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

    LootCouncil.MessageBus:Register(

        REQUEST,

        self,

        self.OnSyncRequest

    )

    LootCouncil.MessageBus:Register(

        RESPONSE,

        self,

        self.OnSyncResponse

    )

end

---------------------------------------------------
-- Request
---------------------------------------------------

function module:RequestSessionSync()

    local message =
        LootCouncil.Message:New(

            REQUEST,

            {

                requester =
                    UnitName("player"),

            }

        )

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

end

function module:OnSyncRequest(

    message,

    sender

)

    LootCouncil:Print(
        "Sync request received from " ..
        tostring(sender)
    )

    ---------------------------------------------------
    -- Only Session Owner Responds
    ---------------------------------------------------

    if not LootCouncil.Session:IsOwner() then

        LootCouncil:Print(
            "Sync response rejected: local client is not owner."
        )

        return

    end

    ---------------------------------------------------
    -- Snapshot
    ---------------------------------------------------

    local snapshot =
        LootCouncil.Session:Serialize()

    LootCouncil:Print(
        "Sync snapshot serialized."
    )

    ---------------------------------------------------
    -- Create Response
    ---------------------------------------------------

    local response =
        LootCouncil.Message:New(

            RESPONSE,

            {

                responder =
                    UnitName("player"),

                snapshot =
                    snapshot,

            }

        )

    LootCouncil:Print(
        "Sync response broadcasting to " ..
        tostring(sender)
    )

    ---------------------------------------------------
    -- Broadcast
    ---------------------------------------------------

    LootCouncil.MessageBus:Broadcast(

        response,

        UnitName("player")

    )

end

function module:OnSyncResponse(

    message,

    sender

)

    LootCouncil:Print(
        "Sync response received from " ..
        tostring(sender)
    )

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    if not payload.snapshot then
        return
    end

    ---------------------------------------------------
    -- Apply Snapshot
    ---------------------------------------------------

    LootCouncil.Session:Deserialize(
        payload.snapshot
    )

    LootCouncil:Print(
        "Sync snapshot applied from " ..
        tostring(sender)
    )

end