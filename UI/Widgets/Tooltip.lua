function LootCouncil.UI.Widgets:AddTooltip(frame, text)
    local originalEnter = frame:GetScript("OnEnter")
    local originalLeave = frame:GetScript("OnLeave")

    frame:SetScript("OnEnter", function(self, ...)
        if originalEnter then
            originalEnter(self, ...)
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(text)
        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function(self, ...)
        if originalLeave then
            originalLeave(self, ...)
        end
        GameTooltip:Hide()
    end)
end