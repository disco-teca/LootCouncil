function LootCouncil.UI.Widgets:CreateTab(parent, data)

    local theme = LootCouncil.Constants.Theme
    local constants = LootCouncil.Constants.UI.Tab

    local button = CreateFrame("Button", nil, parent)

    button:SetHeight(constants.Height)

    ---------------------------------------------------
    -- Background
    ---------------------------------------------------

    local background = button:CreateTexture(nil, "BACKGROUND")

    background:SetAllPoints()

    background:SetTexture(
        theme.TabBackground[1],
        theme.TabBackground[2],
        theme.TabBackground[3],
        theme.TabBackground[4]
    )

    button.Background = background

    ---------------------------------------------------
    -- Text
    ---------------------------------------------------

    local text = button:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    text:SetPoint("CENTER")

    text:SetText(data.text or "")

    button.Text = text

    ---------------------------------------------------
    -- Automatic Width
    ---------------------------------------------------

    local width = text:GetStringWidth() + constants.Padding

    if width < constants.MinWidth then
        width = constants.MinWidth
    end

    if width > constants.MaxWidth then
        width = constants.MaxWidth
    end

    button:SetWidth(width)

    ---------------------------------------------------
    -- Selected
    ---------------------------------------------------

    function button:SetSelected(selected)

        if selected then

            self.Background:SetTexture(
                theme.TabSelected[1],
                theme.TabSelected[2],
                theme.TabSelected[3],
                theme.TabSelected[4]
            )

        else

            self.Background:SetTexture(
                theme.TabBackground[1],
                theme.TabBackground[2],
                theme.TabBackground[3],
                theme.TabBackground[4]
            )

        end

    end

    LootCouncil.UI.Widgets:AddTooltip(button, data.text or "")

    button:SetSelected(false)

    return button

end