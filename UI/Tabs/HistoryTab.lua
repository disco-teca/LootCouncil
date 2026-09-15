LootCouncil.UI.HistoryTab = {}

local view = LootCouncil.UI.HistoryTab

view.initialized = false
view.groups = {}

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

    self:CreateWidgets()

    self.initialized = true

end

---------------------------------------------------
-- Create Widgets
---------------------------------------------------

function view:CreateWidgets()

    ---------------------------------------------------
    -- Empty State Label
    ---------------------------------------------------

    self.emptyLabel =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                font = "GameFontNormal",
                point = "TOPLEFT",
                relativeTo = self.panel,
                relativePoint = "TOPLEFT",
                x = 15,
                y = -15,
                text = "No loot history.",
            }
        )

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
                current - (delta * step)

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

end

---------------------------------------------------
-- Clear Groups
---------------------------------------------------

function view:ClearGroups()

    for _, group in ipairs(self.groups) do
        group:Hide()
    end

    self.groups = {}

end

---------------------------------------------------
-- Group Entries By Session
---------------------------------------------------

function view:GroupBySession(history)

    local sessionMap = {}

    for index, record in ipairs(history) do

        local sessionID = record.sessionID

        if sessionID then

            if not sessionMap[sessionID] then

                sessionMap[sessionID] = {
                    sessionID = sessionID,
                    entries = {},
                    earliestTimestamp = record.timestamp,
                }

            end

            local sessionData = sessionMap[sessionID]

            ---------------------------------------------------
            -- Track Earliest Timestamp For Session Date
            ---------------------------------------------------

            if record.timestamp
            and record.timestamp < sessionData.earliestTimestamp then
                sessionData.earliestTimestamp = record.timestamp
            end

            ---------------------------------------------------
            -- Store Entry With Original Index
            ---------------------------------------------------

            table.insert(sessionData.entries, {
                originalIndex = index,
                timestamp = record.timestamp,
                itemLink = record.itemLink,
                awardedTo = record.awardedTo,
            })

        end

    end

    ---------------------------------------------------
    -- Sort Sessions By ID (Newest First)
    ---------------------------------------------------

    local sortedSessions = {}

    for _, sessionData in pairs(sessionMap) do
        table.insert(sortedSessions, sessionData)
    end

    table.sort(sortedSessions, function(a, b)
        return tonumber(a.sessionID) > tonumber(b.sessionID)
    end)

    ---------------------------------------------------
    -- Sort Entries Within Each Session (Newest First)
    ---------------------------------------------------

    for _, sessionData in ipairs(sortedSessions) do

        table.sort(sessionData.entries, function(a, b)
            return (a.timestamp or 0) > (b.timestamp or 0)
        end)

    end

    return sortedSessions

end

---------------------------------------------------
-- Format Session Header
---------------------------------------------------

function view:FormatHeader(sessionData)

    local count = #sessionData.entries

    local dateText = "Unknown Date"

    if sessionData.earliestTimestamp then

        dateText = date(
            "%Y-%m-%d",
            sessionData.earliestTimestamp
        )

    end

    return sessionData.sessionID ..
        " - " ..
        dateText ..
        " (" ..
        count ..
        ")"

end

---------------------------------------------------
-- Create Row
---------------------------------------------------

function view:CreateRow(group, entry)

    local row = CreateFrame(
        "Frame",
        nil,
        self.content
    )

    row:SetHeight(group.rowHeight)

    ---------------------------------------------------
    -- Timestamp
    ---------------------------------------------------

    local timeText = "--:--"

    if entry.timestamp then

        timeText = date(
            "%H:%M",
            entry.timestamp
        )

    end

    local timeLabel =
        LootCouncil.UI.Widgets:CreateLabel(
            row,
            {
                font = "GameFontNormal",
                point = "LEFT",
                relativeTo = row,
                relativePoint = "LEFT",
                x = 4,
                y = 0,
                text = timeText,
            }
        )

    ---------------------------------------------------
    -- Item Link
    ---------------------------------------------------

    local itemLabel =
        LootCouncil.UI.Widgets:CreateLabel(
            row,
            {
                font = "GameFontNormal",
                point = "LEFT",
                relativeTo = row,
                relativePoint = "LEFT",
                x = 60,
                y = 0,
                text = tostring(entry.itemLink or "Unknown Item"),
            }
        )

    ---------------------------------------------------
    -- Awarded To
    ---------------------------------------------------

    local awardedLabel =
        LootCouncil.UI.Widgets:CreateLabel(
            row,
            {
                font = "GameFontNormal",
                point = "LEFT",
                relativeTo = row,
                relativePoint = "LEFT",
                x = 400,
                y = 0,
                text = tostring(entry.awardedTo or "Unknown"),
            }
        )

    ---------------------------------------------------
    -- Delete Button
    ---------------------------------------------------

    local deleteButton =
        LootCouncil.UI.Widgets.Button:Create(
            row,
            {
                width = 60,
                height = 18,
                text = "Delete",
            }
        )

    deleteButton:SetPoint(
        "LEFT",
        row,
        "LEFT",
        560,
        0
    )

    deleteButton:SetScript(
        "OnClick",
        function()

            LootCouncil.History:Delete(
                entry.originalIndex
            )

            view:Refresh()

        end
    )

    return row
end

---------------------------------------------------
-- Render Groups
---------------------------------------------------

function view:RenderGroups()

    self:ClearGroups()

    local history =
        LootCouncil.History:GetAll()

    if not history or #history == 0 then

        self.emptyLabel:Show()
        self.content:SetHeight(
            self.scrollFrame:GetHeight()
        )
        return

    end

    self.emptyLabel:Hide()

    local sessions =
        self:GroupBySession(history)

    local previous = nil

    for _, sessionData in ipairs(sessions) do

        local headerText =
            self:FormatHeader(sessionData)

        local group =
            LootCouncil.UI.Widgets.CollapsibleGroup:Create(
                self.content,
                {
                    header = headerText,
                }
            )

        if previous then

            group:SetPoint(
                "TOPLEFT",
                previous,
                "BOTTOMLEFT",
                0,
                -4
            )

            group:SetPoint(
                "TOPRIGHT",
                previous,
                "BOTTOMRIGHT",
                0,
                0
            )

        else

            group:SetPoint(
                "TOPLEFT",
                self.content,
                "TOPLEFT",
                0,
                0
            )

            group:SetPoint(
                "TOPRIGHT",
                self.content,
                "TOPRIGHT",
                0,
                0
            )

        end

        for _, entry in ipairs(sessionData.entries) do

            local row =
                self:CreateRow(group, entry)

            group:AddRow(row)

        end

        table.insert(self.groups, group)

        previous = group

    end

    ---------------------------------------------------
    -- Update Content Height
    ---------------------------------------------------

    local totalHeight = 0

    for _, group in ipairs(self.groups) do
        totalHeight = totalHeight + group:GetHeight() + 4
    end

    totalHeight = math.max(
        totalHeight,
        self.scrollFrame:GetHeight()
    )

    self.content:SetHeight(totalHeight)

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function view:Refresh()

    self:Initialize()

    if not self.initialized then
        return
    end

    self:RenderGroups()

end