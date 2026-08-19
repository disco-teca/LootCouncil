LootCouncil.UI.Widgets = {}

function LootCouncil.UI.Widgets:CreatePanel(parent)

    local panel = CreateFrame("Frame", nil, parent)

    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3
        }
    })

    panel:SetBackdropColor(0.08, 0.08, 0.08, 0.95)

    return panel

end