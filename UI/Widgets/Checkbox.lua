LootCouncil.UI.Widgets.Checkbox = {}

local widget = LootCouncil.UI.Widgets.Checkbox

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local theme = LootCouncil.Constants.Theme

    ---------------------------------------------------
    -- Button Frame
    ---------------------------------------------------

    local checkbox = CreateFrame("Button", nil, parent)

    local size = options.size or 18

    checkbox:SetSize(size, size)

    ---------------------------------------------------
    -- Background
    ---------------------------------------------------

    local background = checkbox:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()

    checkbox.Background = background

    ---------------------------------------------------
    -- Border
    ---------------------------------------------------

    local border = CreateFrame("Frame", nil, checkbox)
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    border:SetBackdropBorderColor(
        theme.BorderColor[1],
        theme.BorderColor[2],
        theme.BorderColor[3],
        theme.BorderColor[4]
    )

    checkbox.Border = border

    ---------------------------------------------------
    -- State
    ---------------------------------------------------

    checkbox.checked = options.checked or false
    checkbox.onToggle = options.onToggle

    ---------------------------------------------------
    -- Visual Update
    ---------------------------------------------------

    function checkbox:UpdateVisual()

        if self.checked then

            self.Background:SetTexture(
                theme.TabSelected[1],
                theme.TabSelected[2],
                theme.TabSelected[3],
                theme.TabSelected[4]
            )

        else

            self.Background:SetTexture(
                theme.PanelBackground[1],
                theme.PanelBackground[2],
                theme.PanelBackground[3],
                theme.PanelBackground[4]
            )

        end

    end

    ---------------------------------------------------
    -- Public API
    ---------------------------------------------------

    function checkbox:GetChecked()

        return self.checked

    end

    function checkbox:SetChecked(checked, silent)

        self.checked = checked and true or false

        self:UpdateVisual()

        if not silent and self.onToggle then
            self.onToggle(self.checked)
        end

    end

    function checkbox:Toggle()

        self:SetChecked(not self.checked)

    end

    ---------------------------------------------------
    -- Click
    ---------------------------------------------------

    checkbox:SetScript("OnClick", function(self)

        self:Toggle()

    end)

    ---------------------------------------------------
    -- Hover
    ---------------------------------------------------

    checkbox:SetScript("OnEnter", function(self)

        if not self.checked then

            self.Background:SetTexture(
                theme.TabSelected[1],
                theme.TabSelected[2],
                theme.TabSelected[3],
                0.4
            )

        end

    end)

    checkbox:SetScript("OnLeave", function(self)

        self:UpdateVisual()

    end)

    ---------------------------------------------------
    -- Initial State
    ---------------------------------------------------

    checkbox:UpdateVisual()

    return checkbox

end

---------------------------------------------------
-- Update Theme
---------------------------------------------------

function widget:UpdateTheme(checkbox)

    if not checkbox or not checkbox.Background then
        return
    end

    local theme = LootCouncil.Constants.Theme

    checkbox:UpdateVisual()

    if checkbox.Border then
        checkbox.Border:SetBackdropBorderColor(
            theme.BorderColor[1],
            theme.BorderColor[2],
            theme.BorderColor[3],
            theme.BorderColor[4]
        )
    end

end