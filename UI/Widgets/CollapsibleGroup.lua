LootCouncil.UI.Widgets.CollapsibleGroup = {}

local widget = LootCouncil.UI.Widgets.CollapsibleGroup

local HEADER_HEIGHT = 24

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local theme = LootCouncil.Constants.Theme

    ---------------------------------------------------
    -- Group Frame
    ---------------------------------------------------

    local group = CreateFrame("Frame", nil, parent)

    group:SetHeight(HEADER_HEIGHT)

    ---------------------------------------------------
    -- Header
    ---------------------------------------------------

    local header = CreateFrame("Button", nil, group)
    header:SetPoint("TOPLEFT", group, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", group, "TOPRIGHT", 0, 0)
    header:SetHeight(HEADER_HEIGHT)

    ---------------------------------------------------
    -- Header Background
    ---------------------------------------------------

    local headerBackground = header:CreateTexture(nil, "BACKGROUND")
    headerBackground:SetAllPoints()
    headerBackground:SetTexture(
        theme.TabBackground[1],
        theme.TabBackground[2],
        theme.TabBackground[3],
        theme.TabBackground[4]
    )

    ---------------------------------------------------
    -- Toggle Icon
    ---------------------------------------------------

    local toggleIcon = header:CreateTexture(nil, "ARTWORK")
    toggleIcon:SetSize(14, 14)
    toggleIcon:SetPoint("LEFT", header, "LEFT", 6, 0)
    toggleIcon:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")

    ---------------------------------------------------
    -- Header Text
    ---------------------------------------------------

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerText:SetPoint("LEFT", toggleIcon, "RIGHT", 6, 0)
    headerText:SetText(options.header or "")

    ---------------------------------------------------
    -- Hover Effect
    ---------------------------------------------------

    header:SetScript("OnEnter", function()
        headerBackground:SetTexture(
            theme.TabSelected[1],
            theme.TabSelected[2],
            theme.TabSelected[3],
            0.5
        )
    end)

    header:SetScript("OnLeave", function()
        headerBackground:SetTexture(
            theme.TabBackground[1],
            theme.TabBackground[2],
            theme.TabBackground[3],
            theme.TabBackground[4]
        )
    end)

    ---------------------------------------------------
    -- Content Frame
    ---------------------------------------------------

    local content = CreateFrame("Frame", nil, group)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
    content:SetHeight(0)

    ---------------------------------------------------
    -- State
    ---------------------------------------------------

    group.expanded = options.expanded or false
    group.rowHeight = options.rowHeight or 22
    group.rows = {}
    group.content = content
    group.header = header
    group.headerText = headerText
    group.toggleIcon = toggleIcon

    ---------------------------------------------------
    -- Expand / Collapse
    ---------------------------------------------------

    function group:SetExpanded(expanded)

        self.expanded = expanded

        if expanded then
            self.toggleIcon:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
            self.content:Show()
        else
            self.toggleIcon:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
            self.content:Hide()
        end

        self:UpdateHeight()

    end

    function group:Toggle()

        self:SetExpanded(not self.expanded)

    end

    function group:IsExpanded()

        return self.expanded

    end

    ---------------------------------------------------
    -- Height
    ---------------------------------------------------

    function group:UpdateHeight()

        if self.expanded then

            local contentHeight = self.rowHeight * #self.rows

            self.content:SetHeight(contentHeight)

            self:SetHeight(HEADER_HEIGHT + contentHeight)

        else

            self:SetHeight(HEADER_HEIGHT)

        end

    end

    ---------------------------------------------------
    -- Rows
    ---------------------------------------------------

    function group:ClearRows()

        for _, row in ipairs(self.rows) do
            row:Hide()
        end

        self.rows = {}

        self:UpdateHeight()

    end

    function group:AddRow(row)

        local index = #self.rows + 1

        row:SetParent(self.content)

        row:ClearAllPoints()

        row:SetPoint(
            "TOPLEFT",
            self.content,
            "TOPLEFT",
            0,
            -((index - 1) * self.rowHeight)
        )

        row:SetPoint(
            "TOPRIGHT",
            self.content,
            "TOPRIGHT",
            0,
            -((index - 1) * self.rowHeight)
        )

        table.insert(self.rows, row)

        self:UpdateHeight()

        return row

    end

    ---------------------------------------------------
    -- Header Text Update
    ---------------------------------------------------

    function group:SetHeaderText(text)

        self.headerText:SetText(text)

    end

    ---------------------------------------------------
    -- Wire Header Click
    ---------------------------------------------------

    header:SetScript("OnClick", function()
        group:Toggle()
    end)

    ---------------------------------------------------
    -- Apply Initial State
    ---------------------------------------------------

    group:SetExpanded(group.expanded)

    return group

end