local InspectRequest = {}
InspectRequest.__index = InspectRequest

---------------------------------------------------
-- Constructor
---------------------------------------------------

function InspectRequest:New(player)

    local request = setmetatable({}, InspectRequest)

    ---------------------------------------------------
    -- Identity
    ---------------------------------------------------

    request.player = player

    ---------------------------------------------------
    -- State
    ---------------------------------------------------

    request.state =
        LootCouncil.Constants.InspectRequestState.QUEUED

    ---------------------------------------------------
    -- Result
    ---------------------------------------------------

    request.result = nil

    return request

end

---------------------------------------------------
-- Identity
---------------------------------------------------

function InspectRequest:GetPlayer()

    return self.player

end

---------------------------------------------------
-- State
---------------------------------------------------

function InspectRequest:GetState()

    return self.state

end

function InspectRequest:SetState(state)

    self.state = state

end

---------------------------------------------------
-- Result
---------------------------------------------------

function InspectRequest:GetResult()

    return self.result

end

function InspectRequest:SetResult(result)

    self.result = result

end

LootCouncil.InspectRequest = InspectRequest