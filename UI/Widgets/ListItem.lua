LootCouncil.UI.Widgets.ListItem = {}

local widget = LootCouncil.UI.Widgets.ListItem

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local theme = LootCouncil.Constants.Theme

    ---------------------------------------------------
    -- Button Frame
    ---------------------------------------------------

    local entry = CreateFrame("Button", nil, parent)

    entry:SetSize(
        options.width or 200,
        options.height or 22
    )

    ---------------------------------------------------
    -- Background
    ---------------------------------------------------

    local background = entry:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()

    entry.Background = background
    entry.selected = options.selected or false

    ---------------------------------------------------
    -- Text
    ---------------------------------------------------

    local text = entry:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    text:SetPoint("LEFT", entry, "LEFT", 6, 0)
    text:SetJustifyH("LEFT")
    text:SetText(options.text or "")

    entry.Text = text

    ---------------------------------------------------
    -- Visual Update
    ---------------------------------------------------

    function entry:UpdateVisual()

        if self.selected then

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

    ---------------------------------------------------
    -- Public API
    ---------------------------------------------------

    function entry:SetText(newText)

        self.Text:SetText(newText or "")

    end

    function entry:SetSelected(selected)

        self.selected = selected and true or false

        self:UpdateVisual()

    end

    function entry:GetSelected()

        return self.selected

    end

    ---------------------------------------------------
    -- Click
    ---------------------------------------------------

    if options.onClick then
        entry:SetScript("OnClick", options.onClick)
    end

    ---------------------------------------------------
    -- Hover
    ---------------------------------------------------

    entry:SetScript("OnEnter", function(self)

        if not self.selected then

            self.Background:SetTexture(
                theme.TabSelected[1],
                theme.TabSelected[2],
                theme.TabSelected[3],
                0.4
            )

        end

    end)

    entry:SetScript("OnLeave", function(self)

        self:UpdateVisual()

    end)

    ---------------------------------------------------
    -- Initial State
    ---------------------------------------------------

    entry:UpdateVisual()

    return entry

end

---------------------------------------------------
-- Update Theme
---------------------------------------------------

function widget:UpdateTheme(entry)

    if not entry or not entry.Background then
        return
    end

    entry:UpdateVisual()

end