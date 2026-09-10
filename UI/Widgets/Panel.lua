LootCouncil.UI.Widgets = LootCouncil.UI.Widgets or {}

---------------------------------------------------
-- Apply Theme Backdrop
---------------------------------------------------

function LootCouncil.UI.Widgets:ApplyThemeBackdrop(frame, isPanel)
    local theme = LootCouncil.Constants.Theme

    local bgColor = isPanel and theme.PanelBackground or theme.WindowBackground
    local borderColor = theme.BorderColor

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = theme.BorderSize,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })

    frame:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
end

function LootCouncil.UI.Widgets:CreatePanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    self:ApplyThemeBackdrop(panel, true)
    return panel
end