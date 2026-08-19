LootCouncil.InspectQueue = {}

local module = LootCouncil.InspectQueue

---------------------------------------------------
-- State
---------------------------------------------------

module.queue = {}

module.deferredQueue = {}

module.currentRequest = nil

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

    self.queue = {}

    self.deferredQueue = {}

    self.currentRequest = nil

end

---------------------------------------------------
-- Normal Queue
---------------------------------------------------

function module:GetQueue()

    return self.queue

end

function module:GetNextRequest()

    return self.queue[1]

end

function module:PopNextRequest()

    if #self.queue == 0 then
        return nil
    end

    return table.remove(self.queue, 1)

end

function module:IsQueueEmpty()

    return #self.queue == 0

end

function module:GetQueueSize()

    return #self.queue

end

function module:ClearQueue()

    self.queue = {}

end

---------------------------------------------------
-- Deferred Queue
---------------------------------------------------

function module:AddDeferredRequest(request)

    if not request then
        return
    end

    table.insert(self.deferredQueue, request)

end

function module:RemoveDeferredRequest(request)

    if not request then
        return false
    end

    for index, queuedRequest in ipairs(self.deferredQueue) do

        if queuedRequest == request then

            table.remove(
                self.deferredQueue,
                index
            )

            return true

        end

    end

    return false

end

function module:GetNextDeferredRequest()

    return self.deferredQueue[1]

end

function module:PopNextDeferredRequest()

    if #self.deferredQueue == 0 then
        return nil
    end

    return table.remove(self.deferredQueue, 1)

end

function module:HasDeferredRequests()

    return #self.deferredQueue > 0

end

function module:GetDeferredQueueSize()

    return #self.deferredQueue

end

function module:ClearDeferredQueue()

    self.deferredQueue = {}

end

---------------------------------------------------
-- Active Request
---------------------------------------------------

function module:GetCurrentRequest()

    return self.currentRequest

end

function module:SetCurrentRequest(request)

    self.currentRequest = request

end

function module:ClearCurrentRequest()

    self.currentRequest = nil

end

---------------------------------------------------
-- Debug
---------------------------------------------------

function module:DebugPrint()

    LootCouncil:Print("--------------------------------")
    LootCouncil:Print("Inspect Queue")

    LootCouncil:Print(
        "Normal Queue: " .. self:GetQueueSize()
    )

    LootCouncil:Print(
        "Deferred Queue: " .. self:GetDeferredQueueSize()
    )

    local current = self:GetCurrentRequest()

    if current then

        LootCouncil:Print(
            "Current Request: " ..
            current:GetPlayer():GetName()
        )

    else

        LootCouncil:Print(
            "Current Request: none"
        )

    end

    if self:GetQueueSize() > 0 then

        LootCouncil:Print("")

        LootCouncil:Print("Normal Queue:")

        for _, request in ipairs(self.queue) do

            LootCouncil:Print(
                " - " ..
                request:GetPlayer():GetName() ..
                " (" ..
                request:GetState() ..
                ")"
            )

        end

    end

    if self:GetDeferredQueueSize() > 0 then

        LootCouncil:Print("")

        LootCouncil:Print("Deferred Queue:")

        for _, request in ipairs(self.deferredQueue) do

            LootCouncil:Print(
                " - " ..
                request:GetPlayer():GetName() ..
                " (" ..
                request:GetState() ..
                ")"
            )

        end

    end

end

---------------------------------------------------
-- Lookup
---------------------------------------------------

function module:FindRequest(playerName)

    ---------------------------------------------------
    -- Active Request
    ---------------------------------------------------

    if self.currentRequest then

        if self.currentRequest:GetPlayer():GetName() == playerName then
            return self.currentRequest
        end

    end

    ---------------------------------------------------
    -- Normal Queue
    ---------------------------------------------------

    for _, request in ipairs(self.queue) do

        if request:GetPlayer():GetName() == playerName then
            return request
        end

    end

    ---------------------------------------------------
    -- Deferred Queue
    ---------------------------------------------------

    for _, request in ipairs(self.deferredQueue) do

        if request:GetPlayer():GetName() == playerName then
            return request
        end

    end

    return nil

end

---------------------------------------------------
-- Normal Queue
---------------------------------------------------

function module:AddRequest(request)

    if not request then
        return
    end

    table.insert(self.queue, request)

end