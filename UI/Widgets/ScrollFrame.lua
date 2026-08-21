LootCouncil.UI.Widgets.ScrollFrame = {}

local widget = LootCouncil.UI.Widgets.ScrollFrame

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    ---------------------------------------------------
    -- Unique Frame Name
    ---------------------------------------------------

    widget.counter =
        (widget.counter or 0) + 1

    local frameName =
        "LootCouncilScrollFrame" ..
        tostring(widget.counter)

    ---------------------------------------------------
    -- Scroll Frame
    ---------------------------------------------------

    local scrollFrame = CreateFrame(
        "ScrollFrame",
        frameName,
        parent,
        "UIPanelScrollFrameTemplate"
    )

    ---------------------------------------------------
    -- Content
    ---------------------------------------------------

    local content = CreateFrame(
        "Frame",
        nil,
        scrollFrame
    )

    content:SetWidth(
        options.contentWidth or 500
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