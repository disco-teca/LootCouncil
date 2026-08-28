LootCouncil.UI.HistoryTab = {}

local view = LootCouncil.UI.HistoryTab

view.initialized = false
view.rows = {}

---------------------------------------------------
-- Initialize
---------------------------------------------------

function view:Initialize()

    if self.initialized then
        return
    end

    self.panel =
        LootCouncil.UI.MainWindow.historyPanel

    if not self.panel then
        return
    end

    ---------------------------------------------------
    -- Scroll Frame
    ---------------------------------------------------

    self.scrollFrame =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.panel,
            {
                contentWidth = 750,
                contentHeight = 100,
            }
        )

    self.scrollFrame:SetPoint(
        "TOPLEFT",
        self.panel,
        "TOPLEFT",
        5,
        -5
    )

    self.scrollFrame:SetPoint(
        "BOTTOMRIGHT",
        self.panel,
        "BOTTOMRIGHT",
        -25,
        5
    )

    ---------------------------------------------------
    -- Mouse Wheel
    ---------------------------------------------------

    self.scrollFrame:EnableMouseWheel(true)

    self.scrollFrame:SetScript(
        "OnMouseWheel",
        function(frame, delta)

            local current =
                frame:GetVerticalScroll()

            local range =
                frame:GetVerticalScrollRange()

            local step = 40

            local newPosition =
                current - (
                    delta * step
                )

            if newPosition < 0 then
                newPosition = 0
            end

            if newPosition > range then
                newPosition = range
            end

            frame:SetVerticalScroll(
                newPosition
            )

        end
    )

    self.content =
        self.scrollFrame.content

    self.rowHeight = 30

    self:CreateHeader()

    self.initialized = true

end

---------------------------------------------------
-- Header
---------------------------------------------------

function view:CreateHeader()

    self.header =
        LootCouncil.UI.Widgets:CreateLabel(
            self.content,
            {
                font = "GameFontNormal",

                point = "TOPLEFT",
                relativeTo = self.content,
                relativePoint = "TOPLEFT",

                x = 10,
                y = -5,

                text =
                    "Session        Date / Time              Item                         Awarded To"
            }
        )

end

---------------------------------------------------
-- Clear Rows
---------------------------------------------------

function view:ClearRows()

    for _, row in ipairs(self.rows) do

        if row.text then
            row.text:Hide()
        end

    end

    self.rows = {}

end

---------------------------------------------------
-- Create Row
---------------------------------------------------

function view:CreateRow(
    record,
    index
)

    local row = {}

    local yOffset =
        -(
            30 +
            (
                (index - 1) *
                self.rowHeight
            )
        )

    local dateText =
        date(
            "%m/%d/%y %H:%M",
            record.timestamp
        )

    local text =
        string.format(

            "%-14s %-23s %-35s %s",

            tostring(
                record.sessionID
            ),

            dateText,

            tostring(
                record.itemLink
            ),

            tostring(
                record.awardedTo
            )

        )

    row.text =
        LootCouncil.UI.Widgets:CreateLabel(
            self.content,
            {
                point = "TOPLEFT",
                relativeTo = self.content,
                relativePoint = "TOPLEFT",

                x = 10,
                y = yOffset,

                text = text
            }
        )

    table.insert(
        self.rows,
        row
    )

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function view:Refresh()

    self:Initialize()

    if not self.initialized then
        return
    end

    self:ClearRows()

    local history =
        LootCouncil.History:GetAll()

    if not history
    or #history == 0 then

        self.header:SetText(
            "No loot history."
        )

        self.content:SetHeight(
            self.scrollFrame:GetHeight()
        )

        self.scrollFrame:SetVerticalScroll(
            0
        )

        return

    end

    self.header:SetText(
        "Session        Date / Time              Item                         Awarded To"
    )

    ---------------------------------------------------
    -- Create Rows
    ---------------------------------------------------

    for index, record in ipairs(history) do

        self:CreateRow(
            record,
            index
        )

    end

    ---------------------------------------------------
    -- Content Height
    ---------------------------------------------------

    local contentHeight =
        30 +
        (
            #history *
            self.rowHeight
        ) +
        15

    self.content:SetHeight(
        math.max(
            contentHeight,
            self.scrollFrame:GetHeight()
        )
    )

    ---------------------------------------------------
    -- Clamp Scroll
    ---------------------------------------------------

    local current =
        self.scrollFrame:GetVerticalScroll()

    local range =
        self.scrollFrame:GetVerticalScrollRange()

    if current > range then

        self.scrollFrame:SetVerticalScroll(
            range
        )

    end

end