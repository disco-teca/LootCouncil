LootCouncil.History = {}

local module = LootCouncil.History

---------------------------------------------------
-- State
---------------------------------------------------

local history = {}

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize(data)

    history = data or {}

end

---------------------------------------------------
-- Add
---------------------------------------------------

function module:Add(
    timestamp,
    sessionID,
    itemLink,
    awardedTo
)

    if not sessionID then
        return
    end

    if not itemLink then
        return
    end

    if not awardedTo then
        return
    end

    table.insert(
        history,
        {
            timestamp = timestamp or time(),
            sessionID = sessionID,
            itemLink = itemLink,
            awardedTo = awardedTo,
        }
    )

end

---------------------------------------------------
-- Get All
---------------------------------------------------

function module:GetAll()

    return history

end