LootCouncil.UI = LootCouncil.UI or {}

function LootCouncil.UI:Show()
    if not LootCouncil.UI.frame then
        return
    end
    LootCouncil.UI.frame:Show()
end

function LootCouncil.UI:Hide()
    self.frame:Hide()
end

function LootCouncil.UI:Toggle()

    if self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end

end