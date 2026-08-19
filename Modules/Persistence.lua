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