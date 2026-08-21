LootCouncil.UI.Widgets.ScrollFrame = {}

local widget = LootCouncil.UI.Widgets.ScrollFrame

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local scrollFrame = CreateFrame(
        "ScrollFrame",
        "LootCouncilScrollFrame",
        parent,
        "UIPanelScrollFrameTemplate"
    )

    local content = CreateFrame(
        "Frame",
        nil,
        scrollFrame
    )

    content:SetWidth(
        options.contentWidth or 900
    )

    content:SetHeight(
        options.contentHeight or 1200
    )

    scrollFrame:SetScrollChild(
        content
    )

    scrollFrame.content = content

    return scrollFrame

end