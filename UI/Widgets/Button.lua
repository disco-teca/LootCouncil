LootCouncil.UI.Widgets.Button = {}

local widget = LootCouncil.UI.Widgets.Button

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local button = CreateFrame(

        "Button",

        nil,

        parent,

        "UIPanelButtonTemplate"

    )

    button:SetWidth(
        options.width or 60
    )

    button:SetHeight(
        options.height or 20
    )

    button:SetText(
        options.text or ""
    )

    if options.onClick then

        button:SetScript(

            "OnClick",

            options.onClick

        )

    end

    return button

end

---------------------------------------------------
-- Set Text
---------------------------------------------------

function widget:SetText(button, text)

    button:SetText(
        text or ""
    )

end

---------------------------------------------------
-- Enable
---------------------------------------------------

function widget:Enable(button)

    button:Enable()

end

---------------------------------------------------
-- Disable
---------------------------------------------------

function widget:Disable(button)

    button:Disable()

end