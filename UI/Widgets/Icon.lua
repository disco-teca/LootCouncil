LootCouncil.UI.Widgets.Icon = {}

local widget = LootCouncil.UI.Widgets.Icon

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, size)

    local button = CreateFrame(
        "Button",
        nil,
        parent
    )

    button:SetSize(size or 20, size or 20)

    button.texture =
        button:CreateTexture(nil, "ARTWORK")

    button.texture:SetAllPoints(button)

    button.itemLink = nil

    return button

end

---------------------------------------------------
-- Set Texture
---------------------------------------------------

function widget:SetTexture(button, texture)

    button.texture:SetTexture(texture)

end

---------------------------------------------------
-- Set Item
---------------------------------------------------

function widget:SetItem(button, itemLink)

    button.itemLink = itemLink

    button:SetScript("OnEnter", function(self)

        if not self.itemLink then
            return
        end

        GameTooltip:SetOwner(
            self,
            "ANCHOR_RIGHT"
        )

        GameTooltip:SetHyperlink(
            self.itemLink
        )

        GameTooltip:Show()

    end)

    button:SetScript("OnLeave", function()

        GameTooltip:Hide()

    end)

end