LootCouncil.UI.SettingsTab = {}

local view = LootCouncil.UI.SettingsTab

view.initialized = false

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

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function view:Refresh()

    self:Initialize()

    if not self.initialized then
        return
    end

end