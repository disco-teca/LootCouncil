LootCouncil.Comparison = {}

local module = LootCouncil.Comparison
local Slot = LootCouncil.Constants.InventorySlot

---------------------------------------------------
-- Slot Resolution
---------------------------------------------------

function module:GetComparisonSlots(lootItem)

    if not lootItem then
        return {}
    end

    local equipSlot =
        lootItem:GetEquipSlot()

    ---------------------------------------------------
    -- Single Slot Items
    ---------------------------------------------------

    local singleSlots = {

        INVTYPE_HEAD = {
            Slot.Head,
        },

        INVTYPE_NECK = {
            Slot.Neck,
        },

        INVTYPE_SHOULDER = {
            Slot.Shoulder,
        },

        INVTYPE_CLOAK = {
            Slot.Back,
        },

        INVTYPE_CHEST = {
            Slot.Chest,
        },

        INVTYPE_ROBE = {
            Slot.Chest,
        },

        INVTYPE_WRIST = {
            Slot.Wrist,
        },

        INVTYPE_HAND = {
            Slot.Hands,
        },

        INVTYPE_WAIST = {
            Slot.Waist,
        },

        INVTYPE_LEGS = {
            Slot.Legs,
        },

        INVTYPE_FEET = {
            Slot.Feet,
        },

        INVTYPE_RANGED = {
            Slot.RangedSlot,
        },

        INVTYPE_RANGEDRIGHT = {
            Slot.RangedSlot,
        },

        INVTYPE_RELIC = {
            Slot.RangedSlot,
        },

        INVTYPE_2HWEAPON = {
            Slot.MainHand,
            Slot.OffHand,
        },

    }

    if singleSlots[equipSlot] then

        return singleSlots[equipSlot]

    end

    ---------------------------------------------------
    -- Rings
    ---------------------------------------------------

    if equipSlot == "INVTYPE_FINGER" then

        return {

            Slot.Finger1,
            Slot.Finger2,

        }

    end

    ---------------------------------------------------
    -- Trinkets
    ---------------------------------------------------

    if equipSlot == "INVTYPE_TRINKET" then

        return {

            Slot.Trinket1,
            Slot.Trinket2,

        }

    end

    ---------------------------------------------------
    -- Weapons / Offhands
    ---------------------------------------------------

    if equipSlot == "INVTYPE_WEAPON"
    or equipSlot == "INVTYPE_WEAPONMAINHAND"
    or equipSlot == "INVTYPE_WEAPONOFFHAND"
    or equipSlot == "INVTYPE_SHIELD"
    or equipSlot == "INVTYPE_HOLDABLE" then

        return {

            Slot.MainHand,
            Slot.OffHand,

        }

    end

    return {}

end