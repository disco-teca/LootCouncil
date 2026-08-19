LootCouncil.UI.Widgets.ItemSummary = {}

local widget = LootCouncil.UI.Widgets.ItemSummary

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent)

    local frame = CreateFrame("Frame", nil, parent)

    frame:SetWidth(500)
    frame:SetHeight(90)

    return frame

end

---------------------------------------------------
-- Position
---------------------------------------------------

function widget:SetPoint(frame, ...)

    frame:SetPoint(...)

end

---------------------------------------------------
-- Set Item
---------------------------------------------------

function widget:SetItem(frame, item)

    -- Placeholder

end

---------------------------------------------------
-- Clear
---------------------------------------------------

function widget:Clear(frame)

    -- Placeholder

end