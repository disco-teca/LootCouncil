---------------------------------------------------
-- Utils
---------------------------------------------------

LootCouncil.Utils = {}

local module = LootCouncil.Utils

---------------------------------------------------
-- Deep Copy
---------------------------------------------------

function module:DeepCopy(object)

    if type(object) ~= "table" then
        return object
    end

    local copy = {}

    for key, value in pairs(object) do

        copy[key] = self:DeepCopy(value)

    end

    return copy

end