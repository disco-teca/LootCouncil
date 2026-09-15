LootCouncil.UI = {}

---------------------------------------------------
-- Show
---------------------------------------------------

function LootCouncil.UI:Show()

    if LootCouncil.Session:IsActive()
    and not LootCouncil.Session:IsCouncil(UnitName("player")) then
        LootCouncil:Print("This window is only available to council.")
        return
    end

    if LootCouncil.UI.frame then
        LootCouncil.UI.frame:Show()
    end

end

---------------------------------------------------
-- Hide
---------------------------------------------------

function LootCouncil.UI:Hide()

    if LootCouncil.UI.frame then
        LootCouncil.UI.frame:Hide()
    end

end

---------------------------------------------------
-- Toggle
---------------------------------------------------

function LootCouncil.UI:Toggle()

    if LootCouncil.UI.frame and LootCouncil.UI.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end

end