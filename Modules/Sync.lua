LootCouncil.Sync = {}

local module = LootCouncil.Sync

local syncInProgress = false
local syncStartTime = nil
local SYNC_TIMEOUT = 10  -- seconds

---------------------------------------------------
-- Message Types
---------------------------------------------------

local REQUEST_RAIDER = "REQUEST_RAIDER_SYNC"
local RESPONSE_RAIDER = "RESPONSE_RAIDER_SYNC"
local REQUEST_COUNCIL = "REQUEST_COUNCIL_SYNC"
local RESPONSE_COUNCIL = "RESPONSE_COUNCIL_SYNC"
local QUERY = "SESSION_QUERY"
local ANNOUNCE = "SESSION_ANNOUNCE"

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()
    LootCouncil.MessageBus:Register(
        REQUEST_RAIDER,
        self,
        self.OnRaiderSyncRequest
    )

    LootCouncil.MessageBus:Register(
        RESPONSE_RAIDER,
        self,
        self.OnRaiderSyncResponse
    )

    -- LootCouncil.MessageBus:Register(
    --    REQUEST_COUNCIL,
    --    self,
    --    self.OnCouncilSyncRequest
    --)

    -- LootCouncil.MessageBus:Register(
    --    RESPONSE_COUNCIL,
    --    self,
    --    self.OnCouncilSyncResponse
    --)

    LootCouncil.MessageBus:Register(
        QUERY,
        self,
        self.OnSessionQuery
    )

    LootCouncil.MessageBus:Register(
        ANNOUNCE,
        self,
        self.OnSessionAnnounce
    )

end

---------------------------------------------------
-- Utility
---------------------------------------------------

function module:IsSyncStale()
    if not syncInProgress then
        return false
    end
    if not syncStartTime then
        return true
    end
    return (time() - syncStartTime) > SYNC_TIMEOUT
end

function module:ClearSyncLock()
    syncInProgress = false
    syncStartTime = nil
end

---------------------------------------------------
-- Session Query (Discovery)
---------------------------------------------------

function module:RequestSessionQuery()
    if LootCouncil.Session:IsActive() then
        LootCouncil:Print("You already have an active session.")
        return
    end

    local message = LootCouncil.Message:New(
        QUERY,
        {
            requester = UnitName("player"),
            timestamp = time(),
        }
    )

    LootCouncil.MessageBus:Route(message, UnitName("player"))
    LootCouncil:Print("Checking for active loot session...")
end

function module:OnSessionQuery(message, sender)
    -- Only the session owner responds
    if not LootCouncil.Session:IsOwner() then
        return
    end

    if not LootCouncil.Session:IsActive() then
        return
    end

    if sender == UnitName("player") then
        return
    end

    local announce = LootCouncil.Message:New(
        ANNOUNCE,
        {
            owner = LootCouncil.Session:GetOwner(),
            timestamp = time(),
        }
    )

    LootCouncil.MessageBus:Route(announce, sender)
    LootCouncil:Print("Announced session existence to " .. sender)
end

function module:OnSessionAnnounce(message, sender)
    local payload = message:GetPayload()
    if not payload or not payload.owner then
        return
    end

    -- Ignore if we already have a local session
    if LootCouncil.Session:IsActive() then
        syncInProgress = false
        return
    end

    -- Ignore if we're the owner (shouldn't happen)
    if payload.owner == UnitName("player") then
        syncInProgress = false
        return
    end

    -- If sync is already in progress, this is a continuation, not a duplicate
    if syncInProgress then
        -- Don't return! Continue to the sync request below.
    else
        -- First time we're hearing about this session
        syncInProgress = true
        syncStartTime = time()
    end

    LootCouncil:Print("Session exists! Owner: " .. payload.owner)
    LootCouncil:Print("Requesting sync...")

    -- No roles anymore — everyone gets raider sync
    module:RequestRaiderSync()
end

---------------------------------------------------
-- Manual Sync Entry Point
---------------------------------------------------

function module:RequestSync()
    local playerName = UnitName("player")

    if syncInProgress then
        if module:IsSyncStale() then
            module:ClearSyncLock()
            LootCouncil:Print("Cleared stale sync lock.")
        else
            LootCouncil:Print("Sync already in progress. Please wait.")
            return
        end
    end

    if LootCouncil.Session:IsOwner() then
        LootCouncil:Print("You are the session owner. No sync needed.")
        return
    end

    if not LootCouncil.Session:IsActive() then
        syncInProgress = true
        syncStartTime = time()
        LootCouncil:Print("No local session. Checking for active session...")
        module:RequestSessionQuery()
        return
    end

    -- No roles anymore — everyone gets raider sync
    module:RequestRaiderSync()
end

---------------------------------------------------
-- Raider Sync
---------------------------------------------------

function module:RequestRaiderSync()
    if LootCouncil.Session:IsOwner() then
        return
    end

    local message = LootCouncil.Message:New(
        REQUEST_RAIDER,
        {
            requester = UnitName("player"),
            timestamp = time(),
        }
    )

    LootCouncil.MessageBus:Route(message, UnitName("player"))
    LootCouncil:Print("Requesting raider sync...")
end

function module:OnRaiderSyncRequest(message, sender)
    if not LootCouncil.Session:IsOwner() then
        return
    end

    if not LootCouncil.Session:IsActive() then
        return
    end

    if sender == UnitName("player") then
        return
    end

    LootCouncil:Print("Generating raider snapshot for " .. sender)

    local snapshot = LootCouncil.Session:SerializeRaiderSnapshot(sender)
    if not snapshot then
        LootCouncil:Print("Failed to generate raider snapshot for " .. sender)
        return
    end

    local response = LootCouncil.Message:New(
        RESPONSE_RAIDER,
        {
            target = sender,
            responder = UnitName("player"),
            snapshot = snapshot,
        }
    )

    LootCouncil.MessageBus:Route(response, UnitName("player"))
    LootCouncil:Print("Sent raider sync to " .. sender)
end

function module:OnRaiderSyncResponse(message, sender)

    local payload = message:GetPayload()
    if not payload then
        module:ClearSyncLock()
        return
    end

    if payload.target and payload.target ~= UnitName("player") then
        return
    end

    if not payload.snapshot then
        module:ClearSyncLock()
        return
    end

    if LootCouncil.Session:IsOwner() then
        module:ClearSyncLock()
        return
    end

    LootCouncil:Print("Applying raider snapshot...")

        local success = LootCouncil.Session:DeserializeRaiderSnapshot(
        payload.snapshot,
        UnitName("player")
    )

    if success then
        LootCouncil:Print("Raider sync complete from " .. sender)
        
        -- Tell the owner that we've joined the session
        local announceMessage = LootCouncil.Message:New(
            "PLAYER_JOINED",
            {
                player = UnitName("player"),
                timestamp = time(),
            }
        )
        LootCouncil.MessageBus:Route(announceMessage, UnitName("player"))
    else
        LootCouncil:Print("Failed to apply raider sync from " .. sender)
    end

    module:ClearSyncLock()
end

---------------------------------------------------
-- Gear Request Helper
---------------------------------------------------

function module:RequestGearForAllItems()
    if not LootCouncil.Session:IsActive() then
        return
    end

    local sessionItems = LootCouncil.Session:GetItems()

    for itemIndex, item in ipairs(sessionItems) do
        local comparisonSlots = LootCouncil.Comparison:GetComparisonSlots(item)

        for _, applicant in ipairs(item:GetApplicants()) do
            local playerName = applicant:GetPlayer():GetName()
            local message = LootCouncil.Message:New(
                "GEAR_REQUEST",
                {
                    target = playerName,
                    itemIndex = itemIndex,
                    slots = comparisonSlots,
                }
            )
            LootCouncil.MessageBus:Route(message, UnitName("player"))
        end
    end
end