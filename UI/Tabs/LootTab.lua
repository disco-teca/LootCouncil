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

    self.panel = LootCouncil.UI.MainWindow.workspace

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

    self.title = LootCouncil.UI.Widgets:CreateLabel(self.panel, {
        font = "GameFontNormalLarge",
        point = "TOPLEFT",
        relativeTo = self.panel,
        relativePoint = "TOPLEFT",
        x = 15,
        y = -15,
    })

    self.itemLevel = LootCouncil.UI.Widgets:CreateLabel(self.panel, {
        point = "TOPLEFT",
        relativeTo = self.title,
        relativePoint = "BOTTOMLEFT",
        y = -15,
    })

    self.applicants = LootCouncil.UI.Widgets:CreateLabel(self.panel, {
        point = "TOPLEFT",
        relativeTo = self.itemLevel,
        relativePoint = "BOTTOMLEFT",
        y = -10,
    })

    self.awarded = LootCouncil.UI.Widgets:CreateLabel(self.panel, {
        point = "TOPLEFT",
        relativeTo = self.applicants,
        relativePoint = "BOTTOMLEFT",
        y = -10,
    })

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function view:Refresh()

    self:Initialize()

    if not self.initialized then
        return
    end

    local item = LootCouncil.Session:GetSelectedItem()

    if not item then

        self.title:SetText("No loot item selected.")
        self.itemLevel:SetText("")
        self.applicants:SetText("")
        self.awarded:SetText("")

        return

    end

    self.title:SetText(item:GetName())

    self.itemLevel:SetText(
        "Item Level: " .. item:GetItemLevel()
    )

    self.applicants:SetText(
        "Applicants: " .. item:GetApplicantCount()
    )

    self.awarded:SetText(
        "Awarded: " ..
        (item:IsAwarded() and "Yes" or "No")
    )

end