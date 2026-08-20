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

---------------------------------------------------
-- Equipment Lookup
---------------------------------------------------

function module:GetComparedItems(player, lootItem)

    if not player or not lootItem then
        return {}
    end

    local equipment =
        LootCouncil.PlayerData:GetEquipment(player)

    if not equipment then
        return {}
    end

    local comparedItems = {}

    local slots =
        self:GetComparisonSlots(lootItem)

    for _, slotID in ipairs(slots) do

        local slotName =
            LootCouncil.Constants:GetInventorySlotName(
                slotID
            )

        if slotName then

            table.insert(
                comparedItems,
                equipment[slotName]
            )

        end

    end

    return comparedItems

end

---------------------------------------------------
-- Item Level Comparison
---------------------------------------------------

function module:GetComparedItemLevels(player, lootItem)

    local comparedItems =
        self:GetComparedItems(
            player,
            lootItem
        )

    local itemLevels = {}

    for _, item in ipairs(comparedItems) do

        table.insert(
            itemLevels,
            item.itemLevel or 0
        )

    end

    return itemLevels

end

function module:GetComparisonText(player, lootItem)

    print("----------------------------------------")
    print("GetComparisonText")

    if player then
        print("Player:", player:GetName())
    else
        print("Player: nil")
    end

    if lootItem then
        print("Loot:", lootItem:GetName())
        print("EquipSlot:", tostring(lootItem:GetEquipSlot()))
    else
        print("Loot: nil")
    end

    local itemLevels =
        self:GetComparedItemLevels(
            player,
            lootItem
        )

    print("Compared item count:", #itemLevels)

    if #itemLevels == 0 then
        print("Returning empty comparison")
        return ""
    end

    local text = ""

    for i, itemLevel in ipairs(itemLevels) do

        print("Compared item level:", itemLevel)

        if i > 1 then
            text = text .. " / "
        end

        text = text .. tostring(itemLevel)

    end

    text = text ..
        " -> " ..
        tostring(
            lootItem:GetItemLevel()
        )

    print("Comparison text:", text)

    return text

end