LootCouncil.UI.Widgets = LootCouncil.UI.Widgets or {}

---------------------------------------------------
-- Apply Theme Backdrop
---------------------------------------------------

function LootCouncil.UI.Widgets:CreatePanel(parent)

    local panel = CreateFrame("Frame", nil, parent)

    self:ApplyThemeBackdrop(panel, true)

    return panel

end