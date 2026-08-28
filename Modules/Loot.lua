LootCouncil.Loot = {}

local module = LootCouncil.Loot

---------------------------------------------------
-- Local Variables
---------------------------------------------------

---------------------------------------------------
-- State
---------------------------------------------------

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

end

---------------------------------------------------
-- Public API
---------------------------------------------------

---------------------------------------------------
-- Create Item Data
---------------------------------------------------

function module:CreateItemData(item)

    if not item then
        return nil
    end

    ---------------------------------------------------
    -- Item ID
    ---------------------------------------------------

    local itemID

    if type(item) == "number" then

        itemID = item

    elseif tonumber(item) then

        itemID = tonumber(item)

    else

        local link =
            select(2, GetItemInfo(item))

        if not link then
            return nil
        end

        itemID =
            tonumber(
                string.match(
                    link,
                    "item:(%d+)"
                )
            )

    end

    if not itemID then
        return nil
    end

    ---------------------------------------------------
    -- Item Information
    ---------------------------------------------------

    local
        name,
        itemLink,
        _,
        itemLevel =
        GetItemInfo(itemID)

    if not itemLink then
        return nil
    end

    ---------------------------------------------------
    -- Success
    ---------------------------------------------------

    return {

        id = itemID,

        link = itemLink,

        name = name,

        ilvl = itemLevel,

    }

end

function module:CreateItem(data)

    if not data then
        return nil
    end

    local lootItem =
        LootCouncil.LootItem:New(data)

    ---------------------------------------------------
    -- Populate Metadata
    ---------------------------------------------------

    local metadata =
        self:GetItemMetadata(lootItem:GetID())

    lootItem:SetMetadata(metadata)

    return lootItem

end

function module:GetItemMetadata(itemID)

    if not itemID then
        return nil
    end

    local
        name,
        link,
        quality,
        itemLevel,
        requiredLevel,
        itemType,
        itemSubType,
        _,
        equipSlot,
        icon =
        GetItemInfo(itemID)

    if not link then
        return nil
    end

    return {

        name = name,

        link = link,

        icon = icon,

        quality = quality,

        itemLevel = itemLevel,

        itemType = itemType,

        itemSubType = itemSubType,

        equipSlot = equipSlot,

    }

end

---------------------------------------------------
-- Private Helpers
---------------------------------------------------

---------------------------------------------------
-- Event Handlers
---------------------------------------------------

---------------------------------------------------
-- Debug
---------------------------------------------------