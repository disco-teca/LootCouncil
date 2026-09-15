LootCouncil.UI.GuildTab = {}

local view = LootCouncil.UI.GuildTab

view.initialized = false
view.groups = {}

---------------------------------------------------
-- Initialize
---------------------------------------------------

function view:Initialize()

    if self.initialized then
        return
    end

    self.panel = LootCouncil.UI.SettingsTab.guildPanel

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
    -- Load Button
    ---------------------------------------------------

    self.loadButton =
        LootCouncil.UI.Widgets.Button:Create(
            self.panel,
            {
                width = 160,
                height = 22,
                text = "Load Guild Roster",
            }
        )

    self.loadButton:SetPoint(
        "TOPLEFT",
        self.panel,
        "TOPLEFT",
        10,
        -10
    )

    self.loadButton:SetScript("OnClick", function()

        LootCouncil.Guild:RequestRoster()

        C_Timer.After(0.5, function()
            view:Refresh()
        end)

    end)

    ---------------------------------------------------
    -- Groups Scroll Frame
    ---------------------------------------------------

    self.groupScroll =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.panel,
            {
                contentWidth = 400,
                contentHeight = 100,
            }
        )

    self.groupScroll:SetPoint(
        "TOPLEFT",
        self.loadButton,
        "BOTTOMLEFT",
        0,
        -10
    )

    self.groupScroll:SetPoint(
        "BOTTOMRIGHT",
        self.panel,
        "BOTTOMRIGHT",
        0.37,
        10
    )

    self.groupScroll:EnableMouseWheel(true)

    self.groupScroll:SetScript(
        "OnMouseWheel",
        function(frame, delta)

            local current = frame:GetVerticalScroll()
            local range = frame:GetVerticalScrollRange()
            local step = 40

            local newPosition = current - (delta * step)

            if newPosition < 0 then
                newPosition = 0
            end

            if newPosition > range then
                newPosition = range
            end

            frame:SetVerticalScroll(newPosition)

        end
    )

    self.groupContent = self.groupScroll.content

    ---------------------------------------------------
    -- Summary Scroll Frame
    ---------------------------------------------------

    self.summaryScroll =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.panel,
            {
                contentWidth = 230,
                contentHeight = 100,
            }
        )

    self.summaryScroll:SetPoint(
        "TOPRIGHT",
        self.panel,
        "TOPRIGHT",
        -10,
        -42
    )

    self.summaryScroll:SetPoint(
        "BOTTOMRIGHT",
        self.panel,
        "BOTTOMRIGHT",
        -10,
        10
    )

    self.summaryScroll:SetWidth(250)

    self.summaryScroll:EnableMouseWheel(true)

    self.summaryScroll:SetScript(
        "OnMouseWheel",
        function(frame, delta)

            local current = frame:GetVerticalScroll()
            local range = frame:GetVerticalScrollRange()
            local step = 40

            local newPosition = current - (delta * step)

            if newPosition < 0 then
                newPosition = 0
            end

            if newPosition > range then
                newPosition = range
            end

            frame:SetVerticalScroll(newPosition)

        end
    )

    self.summaryContent = self.summaryScroll.content

    ---------------------------------------------------
    -- Summary Header
    ---------------------------------------------------

    self.summaryHeader =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                font = "GameFontNormal",
                point = "TOPRIGHT",
                relativeTo = self.panel,
                relativePoint = "TOPRIGHT",
                x = -10,
                y = -20,
                text = "Designated Council",
            }
        )

    ---------------------------------------------------
    -- Empty State Label (groups side)
    ---------------------------------------------------

    self.emptyGroups =
        LootCouncil.UI.Widgets:CreateLabel(
            self.groupContent,
            {
                font = "GameFontNormal",
                point = "TOPLEFT",
                relativeTo = self.groupContent,
                relativePoint = "TOPLEFT",
                x = 10,
                y = -10,
                text = "No guild roster loaded.\nClick Load Guild Roster to fetch it.",
            }
        )

    ---------------------------------------------------
    -- Empty State Label (summary side)
    ---------------------------------------------------

    self.emptySummary =
        LootCouncil.UI.Widgets:CreateLabel(
            self.summaryContent,
            {
                font = "GameFontNormal",
                point = "TOPLEFT",
                relativeTo = self.summaryContent,
                relativePoint = "TOPLEFT",
                x = 10,
                y = -10,
                text = "No council designated.",
            }
        )

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
-- Group Members By Rank
---------------------------------------------------

function view:GroupByRank(members)

    local rankMap = {}
    local orderedRanks = {}

    for _, member in ipairs(members) do

        local rankIndex = member.rankIndex or 99

        if not rankMap[rankIndex] then

            rankMap[rankIndex] = {
                rankName = member.rankName or "Unknown",
                rankIndex = rankIndex,
                members = {},
            }

            table.insert(orderedRanks, rankIndex)

        end

        table.insert(rankMap[rankIndex].members, member)

    end

    table.sort(orderedRanks)

    local result = {}

    for _, rankIndex in ipairs(orderedRanks) do

        local group = rankMap[rankIndex]

        table.sort(group.members, function(a, b)
            return a.name < b.name
        end)

        table.insert(result, group)

    end

    return result

end

---------------------------------------------------
-- Render Groups
---------------------------------------------------

function view:RenderGroups()

    self:ClearGroups()

    local members = LootCouncil.Guild:GetMembers()

    if not members or #members == 0 then
        self.emptyGroups:Show()
        return
    end

    self.emptyGroups:Hide()

    local ranks = self:GroupByRank(members)

    local previous = nil

    for _, rankGroup in ipairs(ranks) do

        local headerText =
            rankGroup.rankName ..
            " (" ..
            #rankGroup.members ..
            ")"

        local group =
            LootCouncil.UI.Widgets.CollapsibleGroup:Create(
                self.groupContent,
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
                self.groupContent,
                "TOPLEFT",
                0,
                0
            )

            group:SetPoint(
                "TOPRIGHT",
                self.groupContent,
                "TOPRIGHT",
                0,
                0
            )

        end

        for _, member in ipairs(rankGroup.members) do

            local row = CreateFrame(
                "Frame",
                nil,
                self.groupContent
            )

            row:SetHeight(group.rowHeight)

            local checkbox =
                LootCouncil.UI.Widgets.Checkbox:Create(
                    row,
                    {
                        checked = LootCouncil.Guild:IsDesignated(
                            member.name
                        ),
                        onToggle = function(checked)

                            LootCouncil.Guild:ToggleDesignation(
                                member.name
                            )

                            view:RenderSummary()

                        end,
                    }
                )

            checkbox:SetPoint(
                "LEFT",
                row,
                "LEFT",
                4,
                0
            )

            local nameLabel =
                LootCouncil.UI.Widgets:CreateLabel(
                    row,
                    {
                        font = "GameFontNormal",
                        point = "LEFT",
                        relativeTo = checkbox,
                        relativePoint = "RIGHT",
                        x = 8,
                        y = 0,
                        text = member.name,
                    }
                )

            group:AddRow(row)

        end

        table.insert(self.groups, group)

        previous = group

    end

    local totalHeight = 0

    for _, group in ipairs(self.groups) do
        totalHeight = totalHeight + group:GetHeight() + 4
    end

    totalHeight = math.max(
        totalHeight,
        self.groupScroll:GetHeight()
    )

    self.groupContent:SetHeight(totalHeight)

end

---------------------------------------------------
-- Render Summary
---------------------------------------------------

function view:RenderSummary()

    local designations = LootCouncil.Guild:GetDesignations()

    if not designations or #designations == 0 then
        self.emptySummary:Show()
        self.summaryContent:SetHeight(
            self.summaryScroll:GetHeight()
        )
        return
    end

    self.emptySummary:Hide()

    ---------------------------------------------------
    -- Hide Previous Labels
    ---------------------------------------------------

    if self.summaryLabels then
        for _, label in ipairs(self.summaryLabels) do
            label:Hide()
        end
    end

    self.summaryLabels = {}

    ---------------------------------------------------
    -- Sort Names
    ---------------------------------------------------

    local sortedNames = {}

    for _, name in ipairs(designations) do
        table.insert(sortedNames, name)
    end

    table.sort(sortedNames)

    ---------------------------------------------------
    -- Render One Per Line
    ---------------------------------------------------

    for index, name in ipairs(sortedNames) do

        local label =
            LootCouncil.UI.Widgets:CreateLabel(
                self.summaryContent,
                {
                    font = "GameFontNormal",
                    point = "TOPLEFT",
                    relativeTo = self.summaryContent,
                    relativePoint = "TOPLEFT",
                    x = 6,
                    y = -((index - 1) * 20) - 4,
                    text = name,
                }
            )

        table.insert(self.summaryLabels, label)

    end

    local contentHeight =
        (#sortedNames * 20) + 20

    self.summaryContent:SetHeight(
        math.max(
            contentHeight,
            self.summaryScroll:GetHeight()
        )
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

    self:RenderGroups()
    self:RenderSummary()

end