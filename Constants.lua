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
-- Themes
---------------------------------------------------

LootCouncil.Constants.Themes = {

    ---------------------------------------------------
    -- Dark (default)
    ---------------------------------------------------

    Dark = {

        WindowBackground = {0.04, 0.04, 0.04, 0.95},
        PanelBackground = {0.07, 0.07, 0.07, 0.92},
        TabBackground = {0.12, 0.12, 0.12, 1},
        TabSelected = {0.18, 0.38, 0.70, 1},

        BorderColor = {0.20, 0.20, 0.20, 1},
        BorderSize = 1,

        TextPrimary = {1, 1, 1, 1},
        TextMuted = {0.55, 0.55, 0.55, 1},
        TextDisabled = {0.35, 0.35, 0.35, 1},

        DividerColor = {0.20, 0.20, 0.20, 0.6},

        WindowPadding = 16,
        PanelPadding = 12,
        RowHeight = 28,
        TabHeight = 28,
        IconSizeSmall = 16,
        IconSizeMedium = 20,
        IconSizeLarge = 24,

    },

    ---------------------------------------------------
    -- Light
    ---------------------------------------------------

    Light = {

        WindowBackground = {0.92, 0.92, 0.92, 0.95},  -- Off-white
        PanelBackground = {0.82, 0.82, 0.82, 0.92},   -- Light gray
        TabBackground = {0.95, 0.95, 0.95, 1},        -- Near-white (buttons)
        TabSelected = {0.18, 0.38, 0.70, 1},          -- Light blue

        BorderColor = {0.45, 0.45, 0.45, 1},          -- Medium gray border
        BorderSize = 1,

        TextPrimary = {0.0, 0.0, 0.0, 1},             -- Black text
        TextMuted = {0.35, 0.35, 0.35, 1},            -- Dark gray
        TextDisabled = {0.55, 0.55, 0.55, 1},         -- Light gray

        DividerColor = {0.45, 0.45, 0.45, 0.6},

        WindowPadding = 16,
        PanelPadding = 12,
        RowHeight = 28,
        TabHeight = 28,
        IconSizeSmall = 16,
        IconSizeMedium = 20,
        IconSizeLarge = 24,

    },

    ---------------------------------------------------
    -- Warm (ElvUI gold-style)
    ---------------------------------------------------

    Warm = {

        WindowBackground = {0.10, 0.08, 0.05, 0.95},
        PanelBackground = {0.15, 0.12, 0.08, 0.92},
        TabBackground = {0.18, 0.15, 0.10, 1},
        TabSelected = {0.80, 0.65, 0.20, 1},

        BorderColor = {0.50, 0.40, 0.20, 1},
        BorderSize = 1,

        TextPrimary = {1.0, 0.9, 0.7, 1},
        TextMuted = {0.70, 0.60, 0.40, 1},
        TextDisabled = {0.40, 0.35, 0.25, 1},

        DividerColor = {0.50, 0.40, 0.20, 0.6},

        WindowPadding = 16,
        PanelPadding = 12,
        RowHeight = 28,
        TabHeight = 28,
        IconSizeSmall = 16,
        IconSizeMedium = 20,
        IconSizeLarge = 24,

    },

    ---------------------------------------------------
    -- Cool (blue/cyan accent)
    ---------------------------------------------------

    Cool = {

        WindowBackground = {0.04, 0.06, 0.09, 0.95},
        PanelBackground = {0.06, 0.09, 0.13, 0.92},
        TabBackground = {0.08, 0.12, 0.18, 1},
        TabSelected = {0.20, 0.60, 0.80, 1},

        BorderColor = {0.15, 0.30, 0.45, 1},
        BorderSize = 1,

        TextPrimary = {0.85, 0.95, 1.0, 1},
        TextMuted = {0.50, 0.65, 0.80, 1},
        TextDisabled = {0.30, 0.40, 0.50, 1},

        DividerColor = {0.15, 0.30, 0.45, 0.6},

        WindowPadding = 16,
        PanelPadding = 12,
        RowHeight = 28,
        TabHeight = 28,
        IconSizeSmall = 16,
        IconSizeMedium = 20,
        IconSizeLarge = 24,

    },

}

---------------------------------------------------
-- Active Theme (default)
---------------------------------------------------

LootCouncil.Constants.Theme = LootCouncil.Constants.Themes.Dark