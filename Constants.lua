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

    AUTO_PASS = "AUTO PASS",

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
        1.0,
        0.1,
        0.1,
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

---------------------------------------------------
-- Theme
---------------------------------------------------

LootCouncil.Constants.Theme = {

    ---------------------------------------------------
    -- Backgrounds
    ---------------------------------------------------

    WindowBackground = {0.04, 0.04, 0.04, 0.95},

    PanelBackground = {0.05, 0.05, 0.05, 0.92},

    TabBackground = {0.12, 0.12, 0.12, 1},

    TabSelected = {0.18, 0.38, 0.70, 1},

    ---------------------------------------------------
    -- Borders
    ---------------------------------------------------

    BorderColor = {0.20, 0.20, 0.20, 1},
    BorderSize = 1,

    ---------------------------------------------------
    -- Text
    ---------------------------------------------------

    TextPrimary = {1, 1, 1, 1},
    TextMuted = {0.55, 0.55, 0.55, 1},
    TextDisabled = {0.35, 0.35, 0.35, 1},

    ---------------------------------------------------
    -- Dividers
    ---------------------------------------------------

    DividerColor = {0.20, 0.20, 0.20, 0.6},

    ---------------------------------------------------
    -- Spacing
    ---------------------------------------------------

    WindowPadding = 16,
    PanelPadding = 12,
    RowHeight = 28,
    TabHeight = 28,
    IconSizeSmall = 16,
    IconSizeMedium = 20,
    IconSizeLarge = 24,

}