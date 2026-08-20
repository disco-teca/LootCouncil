LootCouncil.UI.LootTab = {}

local view = LootCouncil.UI.LootTab

view.initialized = false

---------------------------------------------------
-- Initialize
---------------------------------------------------

function view:Initialize()

    if self.initialized then
        return
    end

    self.panel =
        LootCouncil.UI.MainWindow.lootPanel

    if not self.panel then
        return
    end

    self.placeholder =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                font = "GameFontNormalLarge",
                point = "CENTER",
                relativeTo = self.panel,
                relativePoint = "CENTER",
                text = "Loot"
            }
        )

    self.initialized = true

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