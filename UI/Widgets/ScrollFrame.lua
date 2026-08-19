LootCouncil.UI.Widgets.ScrollFrame = {}

local widget = LootCouncil.UI.Widgets.ScrollFrame

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent)

    local scrollFrame = CreateFrame(
        "ScrollFrame",
        "LootCouncilApplicantScrollFrame",
        parent,
        "UIPanelScrollFrameTemplate"
    )

    local content = CreateFrame(
        "Frame",
        nil,
        scrollFrame
    )

    content:SetWidth(900)
    content:SetHeight(1200)

    scrollFrame:SetScrollChild(content)

    scrollFrame.content = content

    return scrollFrame

end