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

end

---------------------------------------------------
-- Clear Rows
---------------------------------------------------

function view:ClearRows()

    for _, row in ipairs(self.rows) do

        row.name:Hide()
        row.role:Hide()

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

    row.name =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.playerTitle,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -(
                    index * 25
                ),

                text = playerName
            }
        )

    row.role =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "LEFT",
                relativeTo = row.name,
                relativePoint = "RIGHT",

                x = 30,
                y = 0,

                text = role
            }
        )

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

    local players =
        LootCouncil.Permissions:GetPlayers()

    local names = {}

    for playerName in pairs(players) do

        table.insert(
            names,
            playerName
        )

    end

    table.sort(names)

    for index, playerName in ipairs(names) do

        local role =
            LootCouncil.Permissions:GetRole(
                playerName
            )

        local row =
            self:CreateRow(
                playerName,
                role or "RAIDER",
                index
            )

        table.insert(
            self.rows,
            row
        )

    end

end