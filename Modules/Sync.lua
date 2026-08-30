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

---------------------------------------------------
-- Request Handler
---------------------------------------------------

function module:OnSyncRequest(

    message,

    sender

)

    -- Intentionally empty for now.

end

---------------------------------------------------
-- Response Handler
---------------------------------------------------

function module:OnSyncResponse(

    message,

    sender

)

    -- Intentionally empty for now.

end