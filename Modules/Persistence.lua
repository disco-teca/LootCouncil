LootCouncil.Persistence = {}

local module = LootCouncil.Persistence

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

    LootCouncilDB = LootCouncilDB or {}

    LootCouncilDB.Persistence =
        LootCouncilDB.Persistence or {}

end

---------------------------------------------------
-- Session ID
---------------------------------------------------

function module:GetNextSessionID()

    local nextID =
        LootCouncilDB.Persistence.NextSessionID

    if not nextID then

        nextID = 1

    end

    LootCouncilDB.Persistence.NextSessionID =
        nextID + 1

    return string.format(
        "%03d",
        nextID
    )

end

---------------------------------------------------
-- Save
---------------------------------------------------

function module:Save()

    local data =
        LootCouncil.Session:Serialize()

    LootCouncilDB.Persistence.Session = data

end

---------------------------------------------------
-- Load
---------------------------------------------------

function module:Load()

    local data =
        LootCouncilDB.Persistence.Session

    if not data then

        return

    end

    LootCouncil.Session:Deserialize(data)

end