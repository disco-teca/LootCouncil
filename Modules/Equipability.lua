LootCouncil.Equipability =
    LootCouncil.Equipability or {}

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
-- Cloth Rules
---------------------------------------------------

local clothExcludedClasses = {

    DEATHKNIGHT = true,
    HUNTER = true,
    ROGUE = true,
    WARRIOR = true,

}

---------------------------------------------------
-- Relic Rules
---------------------------------------------------

local relicTypes = {

    Librams = {
        PALADIN = true,
    },

    Idols = {
        DRUID = true,
    },

    Totems = {
        SHAMAN = true,
    },

    Sigils = {
        DEATHKNIGHT = true,
    },

}

---------------------------------------------------
-- Ranged Weapon Rules
---------------------------------------------------

local rangedWeaponTypes = {

    Wands = {
        PRIEST = true,
        MAGE = true,
        WARLOCK = true,
    },

    Bows = {
        HUNTER = true,
        ROGUE = true,
        WARRIOR = true,
    },

    Crossbows = {
        HUNTER = true,
        ROGUE = true,
        WARRIOR = true,
    },

    Guns = {
        HUNTER = true,
        ROGUE = true,
        WARRIOR = true,
    },

    Thrown = {
        HUNTER = true,
        ROGUE = true,
        WARRIOR = true,
    },

}

---------------------------------------------------
-- Melee Weapon Rules
---------------------------------------------------

local meleeWeaponTypes = {

    ["One-Handed Axes"] = {
        DEATHKNIGHT = true,
        PALADIN = true,
        WARRIOR = true,
        HUNTER = true,
        ROGUE = true,
        SHAMAN = true,
    },

    ["Two-Handed Axes"] = {
        DEATHKNIGHT = true,
        PALADIN = true,
        WARRIOR = true,
        HUNTER = true,
        SHAMAN = true,
    },

    ["One-Handed Maces"] = {
        DEATHKNIGHT = true,
        PALADIN = true,
        WARRIOR = true,
        HUNTER = true,
        ROGUE = true,
        SHAMAN = true,
        DRUID = true,
        PRIEST = true,
    },

    ["Two-Handed Maces"] = {
        DEATHKNIGHT = true,
        PALADIN = true,
        WARRIOR = true,
        HUNTER = true,
        SHAMAN = true,
        DRUID = true,
    },

    ["One-Handed Swords"] = {
        DEATHKNIGHT = true,
        PALADIN = true,
        WARRIOR = true,
        HUNTER = true,
        ROGUE = true,
        MAGE = true,
        WARLOCK = true,
    },

    ["Two-Handed Swords"] = {
        DEATHKNIGHT = true,
        PALADIN = true,
        WARRIOR = true,
        HUNTER = true,
    },

    Daggers = {
        WARRIOR = true,
        HUNTER = true,
        ROGUE = true,
        SHAMAN = true,
        DRUID = true,
        PRIEST = true,
        MAGE = true,
        WARLOCK = true,
    },

    Polearms = {
        DEATHKNIGHT = true,
        PALADIN = true,
        WARRIOR = true,
        HUNTER = true,
        DRUID = true,
    },

    Staves = {
        WARRIOR = true,
        HUNTER = true,
        SHAMAN = true,
        DRUID = true,
        PRIEST = true,
        MAGE = true,
        WARLOCK = true,
    },

    ["Fist Weapons"] = {
        WARRIOR = true,
        HUNTER = true,
        ROGUE = true,
        SHAMAN = true,
        DRUID = true,
    },

}

---------------------------------------------------
-- Class
---------------------------------------------------

local function NormalizeClass(playerClass)

    if not playerClass then
        return nil
    end

    return string.upper(
        playerClass
    )

end

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

    local class =
        NormalizeClass(
            playerClass
        )

    if not class then
        return true
    end

    local itemType =
        item:GetItemType()

    local itemSubType =
        item:GetItemSubType()

    local equipSlot =
        item:GetEquipSlot()

    if not itemType then
        return true
    end

    ---------------------------------------------------
    -- Cloaks
    ---------------------------------------------------

    if equipSlot == "INVTYPE_CLOAK" then
        return true
    end

    ---------------------------------------------------
    -- Armor
    ---------------------------------------------------

    if itemType == "Armor" then

        ---------------------------------------------------
        -- Relics
        ---------------------------------------------------

        if equipSlot == "INVTYPE_RELIC" then

            local rules =
                relicTypes[itemSubType]

            if not rules then
                return true
            end

            return rules[class] == true

        end

        ---------------------------------------------------
        -- Miscellaneous
        ---------------------------------------------------

        if itemSubType == "Miscellaneous" then
            return true
        end

        ---------------------------------------------------
        -- Cloth
        ---------------------------------------------------

        if itemSubType == "Cloth"
        and clothExcludedClasses[class] then

            return false

        end

        ---------------------------------------------------
        -- Armor Proficiency
        ---------------------------------------------------

        local rules =
            armorTypes[class]

        if not rules then
            return true
        end

        if not itemSubType then
            return true
        end

        return rules[itemSubType] == true

    end

    ---------------------------------------------------
    -- Weapons
    ---------------------------------------------------

    if itemType == "Weapon" then

        ---------------------------------------------------
        -- Ranged / Wand
        ---------------------------------------------------

        local rangedRules =
            rangedWeaponTypes[itemSubType]

        if rangedRules then
            return rangedRules[class] == true
        end

        ---------------------------------------------------
        -- Melee
        ---------------------------------------------------

        local meleeRules =
            meleeWeaponTypes[itemSubType]

        if meleeRules then
            return meleeRules[class] == true
        end

        ---------------------------------------------------
        -- Unknown Weapon
        ---------------------------------------------------

        return true

    end

    ---------------------------------------------------
    -- Unknown Item Type
    ---------------------------------------------------

    return true

end