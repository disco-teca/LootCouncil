LootCouncil.UI.SettingsTab = {}

local view = LootCouncil.UI.SettingsTab

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
        LootCouncil.UI.MainWindow.settingsPanel

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

    self.title =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                font = "GameFontNormalLarge",

                point = "TOPLEFT",
                relativeTo = self.panel,
                relativePoint = "TOPLEFT",

                x = 15,
                y = -15,

                text = "Settings"
            }
        )

    self.playerTitle =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.title,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -20,

                text = "Player Roles"
            }
        )

    self.councilTitle =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.playerTitle,
                relativePoint = "BOTTOMLEFT",

                x = 210,
                y = -2,

                text = "Council"
            }
        )

    self.refreshRoster =
        LootCouncil.UI.Widgets.Button:Create(
            self.panel,
            {
                width = 100,
                height = 20,
                text = "Refresh Roster"
            }
        )

    self.refreshRoster:SetPoint(
        "LEFT",
        self.councilTitle,
        "RIGHT",
        20,
        0
    )

    self.refreshRoster:SetScript(
        "OnClick",
        function()

            LootCouncil.Roster:Refresh()

            view:Refresh()

        end
    )
    ---------------------------------------------------
    -- Roster Scroll Frame
    ---------------------------------------------------

    self.scrollFrame =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.panel,
            {
                contentWidth = 500,
                contentHeight = 1200
            }
        )

    self.scrollFrame:SetPoint(
        "TOPLEFT",
        self.playerTitle,
        "BOTTOMLEFT",
        0,
        -5
    )

    self.scrollFrame:SetPoint(
        "BOTTOMRIGHT",
        self.panel,
        "BOTTOMRIGHT",
        -25,
        10
    )

    self.scrollContent =
        self.scrollFrame.content

    self.scrollContent:SetPoint(
        "TOPLEFT",
        self.scrollFrame,
        "TOPLEFT",
        0,
        0
    )

end

---------------------------------------------------
-- Clear Rows
---------------------------------------------------

function view:ClearRows()

    for _, row in ipairs(self.rows) do

        if row.name then
            row.name:Hide()
        end

        if row.role then
            row.role:Hide()
        end

        if row.council then
            row.council:Hide()
        end

    end

    self.rows = {}

end

---------------------------------------------------
-- Create Row
---------------------------------------------------

function view:CreateRow(
    playerName,
    role,
    index
)

    local row = {}

    ---------------------------------------------------
    -- Player Name
    ---------------------------------------------------

    row.name =
        LootCouncil.UI.Widgets:CreateLabel(
            self.scrollContent,
            {
                point = "TOPLEFT",
                relativeTo = self.scrollContent,
                relativePoint = "TOPLEFT",

                x = 0,
                y = -(
                    index * 25
                ),

                text = playerName
            }
        )

    ---------------------------------------------------
    -- Active Role
    ---------------------------------------------------

    row.role =
        LootCouncil.UI.Widgets:CreateLabel(
            self.scrollContent,
            {
                point = "LEFT",
                relativeTo = row.name,
                relativePoint = "RIGHT",

                x = 30,
                y = 0,

                text = role
            }
        )

    ---------------------------------------------------
    -- Council Toggle
    ---------------------------------------------------

    row.council =
        LootCouncil.UI.Widgets.Button:Create(
            self.scrollContent,
            {
                width = 20,
                height = 20,
                text = ""
            }
        )

    row.council:SetPoint(
        "TOPLEFT",
        self.scrollContent,
        "TOPLEFT",
        220,
        -(
            index * 25
        )
    )

    ---------------------------------------------------
    -- Current State
    ---------------------------------------------------

    local isCouncil =
        role ==
        LootCouncil.Permissions.Role.COUNCIL

    if isCouncil then

        row.council:SetText(
            "✓"
        )

    else

        row.council:SetText(
            ""
        )

    end

    ---------------------------------------------------
    -- Permission
    ---------------------------------------------------

    local canManage =
        LootCouncil.Permissions:CanManageRoles(
            UnitName("player")
        )

    ---------------------------------------------------
    -- Owner Lock
    ---------------------------------------------------

    local isOwner =
        playerName ==
        UnitName("player")

    if isOwner then

        row.council:SetText(
            "✓"
        )

        row.council:Disable()

        LootCouncil.Permissions:SetRole(
            playerName,
            LootCouncil.Permissions.Role.COUNCIL
        )

    elseif canManage then

        row.council:Enable()

        row.council:SetScript(
            "OnClick",
            function()

                local success =
                    LootCouncil.Permissions:ToggleCouncil(
                        playerName
                    )

                if success then

                    view:Refresh()

                end

            end
        )

    else

        row.council:Disable()

    end

    return row

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

    ---------------------------------------------------
    -- Select Roster
    ---------------------------------------------------

    local players

    if LootCouncil.Session:IsActive() then

        players =
            LootCouncil.Session:GetPlayers()

    else

        players =
            LootCouncil.Roster:GetPlayers()

    end

    ---------------------------------------------------
    -- Sort Names
    ---------------------------------------------------

    local names = {}

    for _, player in ipairs(players) do

        table.insert(
            names,
            player:GetName()
        )

    end

    table.sort(names)

    ---------------------------------------------------
    -- Create Rows
    ---------------------------------------------------

    for index, playerName in ipairs(names) do

        local role =
            LootCouncil.Permissions:GetRole(
                playerName
            )

        local row =
            self:CreateRow(
                playerName,
                role or LootCouncil.Permissions.Role.RAIDER,
                index
            )

        table.insert(
            self.rows,
            row
        )

    end

    ---------------------------------------------------
    -- Update Content Height
    ---------------------------------------------------

    local rowHeight = 25

    local contentHeight =
        math.max(
            1,
            (#names + 1) * rowHeight
        )

    self.scrollContent:SetHeight(
        contentHeight
    )

end