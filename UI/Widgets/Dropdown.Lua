LootCouncil.UI.Widgets.Dropdown = {}

local widget = LootCouncil.UI.Widgets.Dropdown

local openMenus = {}

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local theme = LootCouncil.Constants.Theme

    ---------------------------------------------------
    -- Button
    ---------------------------------------------------

    local button = CreateFrame("Button", nil, parent)
    button:SetSize(options.width or 150, options.height or 22)

    -- Background
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(
        theme.TabBackground[1],
        theme.TabBackground[2],
        theme.TabBackground[3],
        theme.TabBackground[4]
    )

    -- Border
    local border = CreateFrame("Frame", nil, button)
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = theme.BorderSize,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    border:SetBackdropBorderColor(
        theme.BorderColor[1],
        theme.BorderColor[2],
        theme.BorderColor[3],
        theme.BorderColor[4]
    )

    -- Text
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", 8, 0)
    text:SetText(options.text or "Select...")
    text:SetTextColor(
        theme.TextPrimary[1],
        theme.TextPrimary[2],
        theme.TextPrimary[3],
        theme.TextPrimary[4]
    )

    button.Text = text
    button.Background = bg
    button.Border = border

    ---------------------------------------------------
    -- Hover
    ---------------------------------------------------

    button:SetScript("OnEnter", function()
        bg:SetTexture(
            theme.TabSelected[1],
            theme.TabSelected[2],
            theme.TabSelected[3],
            theme.TabSelected[4]
        )
    end)

    button:SetScript("OnLeave", function()
        if not button.Menu or not button.Menu:IsShown() then
            bg:SetTexture(
                theme.TabBackground[1],
                theme.TabBackground[2],
                theme.TabBackground[3],
                theme.TabBackground[4]
            )
        end
    end)

    ---------------------------------------------------
    -- Options Storage
    ---------------------------------------------------

    button.options = options.items or {}
    button.selected = options.default
    button.onSelect = options.func

    ---------------------------------------------------
    -- Click Handler
    ---------------------------------------------------

    button:SetScript("OnClick", function()
        widget:ToggleMenu(button)
    end)

    ---------------------------------------------------
    -- Set Selected
    ---------------------------------------------------

    function button:SetSelected(value)

        self.selected = value

        -- Find the display text
        for _, item in ipairs(self.options) do
            if item.value == value then
                self.Text:SetText(item.text)
                return
            end
        end

        self.Text:SetText(value or "Select...")

    end

    -- Apply default
    if options.default then
        button:SetSelected(options.default)
    elseif #button.options > 0 then
        button:SetSelected(button.options[1].value)
    end

    return button
end

---------------------------------------------------
-- Toggle Menu
---------------------------------------------------

function widget:ToggleMenu(button)

    if button.Menu and button.Menu:IsShown() then
        button.Menu:Hide()
        return
    end

    -- Close any open menus
    for _, m in ipairs(openMenus) do
        if m:IsShown() then
            m:Hide()
        end
    end

    -- Create menu if needed
    if not button.Menu then
        widget:CreateMenu(button)
    end

    button.Menu:Show()

    -- Add to open list
    table.insert(openMenus, button.Menu)

end

---------------------------------------------------
-- Create Menu
---------------------------------------------------

function widget:CreateMenu(button)

    local theme = LootCouncil.Constants.Theme

    local menu = CreateFrame("Frame", nil, UIParent)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(100)
    menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
    menu:SetSize(button:GetWidth(), #button.options * 22 + 10)

    -- Background
    menu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = theme.BorderSize,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    menu:SetBackdropColor(
        theme.PanelBackground[1],
        theme.PanelBackground[2],
        theme.PanelBackground[3],
        theme.PanelBackground[4]
    )
    menu:SetBackdropBorderColor(
        theme.BorderColor[1],
        theme.BorderColor[2],
        theme.BorderColor[3],
        theme.BorderColor[4]
    )

    menu:EnableMouse(true)

    -- Create option buttons
    local previous

    for i, item in ipairs(button.options) do

        local option = CreateFrame("Button", nil, menu)
        option:SetPoint("TOPLEFT", 4, -4 - ((i - 1) * 22))
        option:SetPoint("TOPRIGHT", -4, -4 - ((i - 1) * 22))
        option:SetHeight(22)

        local optionText = option:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        optionText:SetPoint("LEFT", 4, 0)
        optionText:SetText(item.text)
        optionText:SetTextColor(
            theme.TextPrimary[1],
            theme.TextPrimary[2],
            theme.TextPrimary[3],
            theme.TextPrimary[4]
        )

        option.Text = optionText

        option:SetScript("OnEnter", function()
            optionText:SetTextColor(
                theme.TabSelected[1],
                theme.TabSelected[2],
                theme.TabSelected[3],
                1
            )
        end)

        option:SetScript("OnLeave", function()
            optionText:SetTextColor(
                theme.TextPrimary[1],
                theme.TextPrimary[2],
                theme.TextPrimary[3],
                theme.TextPrimary[4]
            )
        end)

        option:SetScript("OnClick", function()

            button:SetSelected(item.value)
            menu:Hide()

            if button.onSelect then
                button.onSelect(item.value)
            end

            if item.func then
                item.func(item.value)
            end

        end)

        previous = option

    end

    -- Hide menu when clicking elsewhere
    menu:SetScript("OnHide", function()
        button.Background:SetTexture(
            theme.TabBackground[1],
            theme.TabBackground[2],
            theme.TabBackground[3],
            theme.TabBackground[4]
        )
    end)

    button.Menu = menu

end