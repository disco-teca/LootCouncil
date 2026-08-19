function LootCouncil.UI.Widgets:AddTooltip(frame, text)

    frame:SetScript("OnEnter", function(self)

        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        GameTooltip:SetText(text)

        GameTooltip:Show()

    end)

    frame:SetScript("OnLeave", function()

        GameTooltip:Hide()

    end)

end