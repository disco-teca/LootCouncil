function LootCouncil.UI.Widgets:CreateTab(parent, data)

    local constants = LootCouncil.Constants.UI.Tab
    local colors = LootCouncil.Constants.Colors

    local button = CreateFrame("Button", nil, parent)

    button:SetHeight(constants.Height)

    ---------------------------------------------------
    -- Background
    ---------------------------------------------------

    local background = button:CreateTexture(nil, "BACKGROUND")

    background:SetAllPoints()

    background:SetTexture(
        colors.Background[1],
        colors.Background[2],
        colors.Background[3],
        colors.Background[4]
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
                colors.Selected[1],
                colors.Selected[2],
                colors.Selected[3],
                colors.Selected[4]
            )

        else

            self.Background:SetTexture(
                colors.Background[1],
                colors.Background[2],
                colors.Background[3],
                colors.Background[4]
            )

        end

    end

    LootCouncil.UI.Widgets:AddTooltip(
    button,
    data.text or ""
)

    button:SetSelected(false)

    return button

end