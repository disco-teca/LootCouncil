LootCouncil.Equipability = {}

local module =
    LootCouncil.Equipability

---------------------------------------------------
-- Armor Rules
---------------------------------------------------

local armorTypes = {

    DEATHKNIGHT = {
        Cloth = true,
        Leather = true,
        Mail = true,
        Plate = true,
    },

    DRUID = {
        Cloth = true,
        Leather = true,
    },

    HUNTER = {
        Cloth = true,
        Leather = true,
        Mail = true,
    },

    MAGE = {
        Cloth = true,
    },

    PALADIN = {
        Cloth = true,
        Leather = true,
        Mail = true,
        Plate = true,
    },

    PRIEST = {
        Cloth = true,
    },

    ROGUE = {
        Cloth = true,
        Leather = true,
    },

    SHAMAN = {
        Cloth = true,
        Leather = true,
        Mail = true,
    },

    WARLOCK = {
        Cloth = true,
    },

    WARRIOR = {
        Cloth = true,
        Leather = true,
        Mail = true,
        Plate = true,
    },

}

---------------------------------------------------
-- Can Equip
---------------------------------------------------

function module:CanEquip(

    playerClass,

    item

)

    if not playerClass then
        return true
    end

    if not item then
        return true
    end

    ---------------------------------------------------
    -- Only Armor For Now
    ---------------------------------------------------

    if item:GetItemType() ~= "Armor" then

        return true

    end

    local class =
        string.upper(
            playerClass
        )

    local rules =
        armorTypes[class]

    if not rules then
        return true
    end

    local armorType =
        item:GetItemSubType()

    if not armorType then
        return true
    end

    ---------------------------------------------------
    -- Non-Armor Equipment
    ---------------------------------------------------

    if armorType == "Miscellaneous" then
        return true
    end

    return rules[armorType] == true

end