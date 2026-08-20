LootCouncil.Constants = {}

---------------------------------------------------
-- UI
---------------------------------------------------

LootCouncil.Constants.UI = {}

LootCouncil.Constants.UI.Tab = {

    Height = 24,

    MinWidth = 120,
    MaxWidth = 220,

    Padding = 20,
    Spacing = 4,

}

---------------------------------------------------
-- Colors
---------------------------------------------------

LootCouncil.Constants.Colors = {

    Background = {
        0.12,
        0.12,
        0.12,
        1,
    },

    Selected = {
        0.18,
        0.38,
        0.70,
        1,
    },

}

---------------------------------------------------
-- Responses
---------------------------------------------------

LootCouncil.Constants.Response = {

    PENDING = "PENDING",

    BIS = "BIS",

    MS = "MS",

    OS = "OS",

    PASS = "PASS",

    AUTO_PASS = "AUTO_PASS",

}

---------------------------------------------------
-- Class Order
---------------------------------------------------

LootCouncil.Constants.ClassOrder = {

    DEATHKNIGHT = 1,
    DRUID       = 2,
    HUNTER      = 3,
    MAGE        = 4,
    PALADIN     = 5,
    PRIEST      = 6,
    ROGUE       = 7,
    SHAMAN      = 8,
    WARLOCK     = 9,
    WARRIOR     = 10,

}

---------------------------------------------------
-- Class Colors
---------------------------------------------------

LootCouncil.Constants.ClassColors = {

    DEATHKNIGHT = {
        0.77,
        0.12,
        0.23,
    },

    DRUID = {
        1.00,
        0.49,
        0.04,
    },

    HUNTER = {
        0.67,
        0.83,
        0.45,
    },

    MAGE = {
        0.25,
        0.78,
        0.92,
    },

    PALADIN = {
        0.96,
        0.55,
        0.73,
    },

    PRIEST = {
        1.00,
        1.00,
        1.00,
    },

    ROGUE = {
        1.00,
        0.96,
        0.41,
    },

    SHAMAN = {
        0.00,
        0.44,
        0.87,
    },

    WARLOCK = {
        0.53,
        0.53,
        0.93,
    },

    WARRIOR = {
        0.78,
        0.61,
        0.43,
    },

}

---------------------------------------------------
-- Inventory Slots
---------------------------------------------------

LootCouncil.Constants.InventorySlot = {

    Head = 1,
    Neck = 2,
    Shoulder = 3,
    Shirt = 4,
    Chest = 5,
    Waist = 6,
    Legs = 7,
    Feet = 8,
    Wrist = 9,
    Hands = 10,

    Finger1 = 11,
    Finger2 = 12,

    Trinket1 = 13,
    Trinket2 = 14,

    Back = 15,

    MainHand = 16,
    OffHand = 17,
    RangedSlot = 18,

}

---------------------------------------------------
-- Helpers
---------------------------------------------------

function LootCouncil.Constants:GetInventorySlotName(slotID)

    for slotName, id in pairs(
        self.InventorySlot
    ) do

        if id == slotID then
            return slotName
        end

    end

    return nil

end