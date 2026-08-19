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

    local equipSlot = lootItem:GetEquipSlot()

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

        INVTYPE_RELIC = {
            Slot.RangedSlot,
        },

        INVTYPE_SHIELD = {
            Slot.OffHand,
        },

        INVTYPE_HOLDABLE = {
            Slot.OffHand,
        },

        INVTYPE_2HWEAPON = {
            Slot.MainHand,
        },

    }

    if singleSlots[equipSlot] then
        return singleSlots[equipSlot]
    end

    ---------------------------------------------------
    -- Multi Slot Items
    ---------------------------------------------------

    if equipSlot == "INVTYPE_FINGER" then

        return {
            Slot.Finger1,
            Slot.Finger2,
        }

    end

    if equipSlot == "INVTYPE_TRINKET" then

        return {
            Slot.Trinket1,
            Slot.Trinket2,
        }

    end

    if equipSlot == "INVTYPE_WEAPON" then

        return {
            Slot.MainHand,
            Slot.OffHand,
        }

    end

    if equipSlot == "INVTYPE_WEAPONMAINHAND" then

        return {
            Slot.MainHand,
        }

    end

    if equipSlot == "INVTYPE_WEAPONOFFHAND" then

        return {
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