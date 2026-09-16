LootCouncil.UI.SettingsTab = {}

local view = LootCouncil.UI.SettingsTab

view.initialized = false
view.rows = {}

---------------------------------------------------
-- Sub-Tab Manager (merged from SettingsTabManager)
---------------------------------------------------

local manager = {}

manager.tabs = {}
manager.selected = "Roster"

---------------------------------------------------
-- Initialize Sub-Tabs
---------------------------------------------------

function manager:Initialize(parent)
    self.parent = parent
    self:CreateTabs()
end

---------------------------------------------------
-- Create Sub-Tabs
---------------------------------------------------

function manager:CreateTabs()

    local names = {
        "Roster",
        "Guild",
        "Loot",
        "UI",
    }

    local previous

    for _, name in ipairs(names) do

        local tab =
            LootCouncil.UI.Widgets:CreateTab(
                self.parent,
                {
                    text = name
                }
            )

        if previous then

            tab:SetPoint(
                "LEFT",
                previous,
                "RIGHT",
                4,
                0
            )

        else

            tab:SetPoint(
                "LEFT",
                self.parent,
                "LEFT",
                0,
                0
            )

        end

        tab:SetScript(
            "OnClick",
            function()
                manager:Select(name)
            end
        )

        self.tabs[name] = tab

        previous = tab

    end

    self:Refresh()

end

---------------------------------------------------
-- Select Sub-Tab
---------------------------------------------------

function manager:Select(name)

    self.selected = name
    self:Refresh()

end

---------------------------------------------------
-- Refresh Sub-Tabs
---------------------------------------------------

function manager:Refresh()

    ---------------------------------------------------
    -- Show All Tabs
    ---------------------------------------------------

    for name, tab in pairs(self.tabs) do

        tab:Show()

        tab:SetSelected(
            name == self.selected
        )

    end

    ---------------------------------------------------
    -- Hide All Panels
    ---------------------------------------------------

    local panels = {
        "rosterPanel",
        "guildPanel",
        "lootPanel",
        "uiPanel",
    }

    for _, panelName in ipairs(panels) do

        local panel = view[panelName]

        if panel then
            panel:Hide()
        end

    end

    ---------------------------------------------------
    -- Show Selected Panel
    ---------------------------------------------------

    if self.selected == "Roster" then

        if view.rosterPanel then
            view.rosterPanel:Show()
        end

        view:RefreshRoster()

    elseif self.selected == "Guild" then

        if view.guildPanel then
            view.guildPanel:Show()
        end

        LootCouncil.UI.GuildTab:Refresh()    

    elseif self.selected == "Loot" then

        if view.lootPanel then
            view.lootPanel:Show()
        end

        elseif self.selected == "UI" then

        if view.uiPanel then
            view.uiPanel:Show()
        end

    end

end

---------------------------------------------------
-- Get Selected Sub-Tab
---------------------------------------------------

function manager:GetSelected()
    return self.selected
end

---------------------------------------------------
-- Attach Manager to SettingsTab
---------------------------------------------------

view.tabManager = manager

---------------------------------------------------
-- Initialize SettingsTab
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

    ---------------------------------------------------
    -- Title
    ---------------------------------------------------

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

    ---------------------------------------------------
    -- Sub-Tab Bar
    ---------------------------------------------------

    self.tabBar =
        CreateFrame("Frame", nil, self.panel)

    self.tabBar:SetPoint(
        "TOPLEFT",
        self.title,
        "BOTTOMLEFT",
        0,
        -10
    )

    self.tabBar:SetPoint(
        "TOPRIGHT",
        self.panel,
        "TOPRIGHT",
        -15,
        0
    )

    self.tabBar:SetHeight(28)

    ---------------------------------------------------
    -- Content Area
    ---------------------------------------------------

    self.contentArea =
        CreateFrame("Frame", nil, self.panel)

    self.contentArea:SetPoint(
        "TOPLEFT",
        self.tabBar,
        "BOTTOMLEFT",
        0,
        -10
    )

    self.contentArea:SetPoint(
        "BOTTOMRIGHT",
        self.panel,
        "BOTTOMRIGHT",
        -15,
        15
    )

    ---------------------------------------------------
    -- Roster Panel
    ---------------------------------------------------

    self.rosterPanel =
        LootCouncil.UI.Widgets:CreatePanel(
            self.contentArea
        )

    self.rosterPanel:SetAllPoints()

    self:CreateRosterPanel()

    ---------------------------------------------------
    -- Guild Panel
    ---------------------------------------------------

    self.guildPanel =
        LootCouncil.UI.Widgets:CreatePanel(
            self.contentArea
        )

    self.guildPanel:SetAllPoints()
    self.guildPanel:Hide()

    ---------------------------------------------------
    -- Loot Panel (placeholder)
    ---------------------------------------------------

    self.lootPanel =
        LootCouncil.UI.Widgets:CreatePanel(
            self.contentArea
        )

    self.lootPanel:SetAllPoints()
    self.lootPanel:Hide()

    ---------------------------------------------------
    -- UI Panel
    ---------------------------------------------------

    self.uiPanel =
        LootCouncil.UI.Widgets:CreatePanel(
            self.contentArea
        )

    self.uiPanel:SetAllPoints()
    self.uiPanel:Hide()

    self:CreateUIPanel()

    ---------------------------------------------------
    -- Initialize Sub-Tab Manager
    ---------------------------------------------------

    self.tabManager:Initialize(self.tabBar)

end

---------------------------------------------------
-- Create Roster Panel Content
---------------------------------------------------

function view:CreateRosterPanel()

    ---------------------------------------------------
    -- Refresh Roster Button
    ---------------------------------------------------

    self.refreshRoster =
        LootCouncil.UI.Widgets.Button:Create(
            self.rosterPanel,
            {
                width = 100,
                height = 20,
                text = "Refresh Roster"
            }
        )

    self.refreshRoster:SetPoint(
        "TOPLEFT",
        10,
        -10
    )

    self.refreshRoster:SetScript(
        "OnClick",
        function()
            LootCouncil.Roster:Refresh()
            view:RefreshRoster()
        end
    )

    ---------------------------------------------------
    -- Roster Scroll Frame
    ---------------------------------------------------

    self.scrollFrame =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.rosterPanel,
            {
                contentWidth = 500,
                contentHeight = 1200
            }
        )

    self.scrollFrame:SetPoint(
        "TOPLEFT",
        self.refreshRoster,
        "BOTTOMLEFT",
        0,
        -10
    )

    self.scrollFrame:SetPoint(
        "BOTTOMRIGHT",
        self.rosterPanel,
        "BOTTOMRIGHT",
        -10,
        10
    )

    self.scrollContent =
        self.scrollFrame.content

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

        if row.councilToggle then
            row.councilToggle:Hide()
        end

        if row.gearButton then
            row.gearButton:Hide()
        end

        if row.syncButton then
            row.syncButton:Hide()
        end

    end

    self.rows = {}

end

---------------------------------------------------
-- Create Row
---------------------------------------------------

function view:CreateRow(playerName, index)
    local row = {}

    ---------------------------------------------------
    -- Player Name
    ---------------------------------------------------

    row.name = LootCouncil.UI.Widgets:CreateLabel(
        self.scrollContent,
        {
            point = "TOPLEFT",
            relativeTo = self.scrollContent,
            relativePoint = "TOPLEFT",
            x = 0,
            y = -(index * 25),
            text = playerName
        }
    )

    ---------------------------------------------------
    -- Role Display
    ---------------------------------------------------

    local displayText = LootCouncil.Session:IsCouncil(playerName) and "COUNCIL" or "RAIDER"
    
    row.role = LootCouncil.UI.Widgets:CreateLabel(
        self.scrollContent,
        {
            point = "LEFT",
            relativeTo = row.name,
            relativePoint = "RIGHT",
            x = 30,
            y = 0,
            text = displayText
        }
    )

    ---------------------------------------------------
    -- Council Toggle Button
    ---------------------------------------------------

    local isCouncil = LootCouncil.Session:IsCouncil(playerName)
    local isOwner = playerName == LootCouncil.Session:GetOwner()
    
    row.councilToggle = LootCouncil.UI.Widgets.Button:Create(
        self.scrollContent,
        {
            width = 20,
            height = 20,
            text = isCouncil and "★" or "",
        }
    )
    
    row.councilToggle:SetPoint(
        "TOPLEFT",
        self.scrollContent,
        "TOPLEFT",
        220,
        -(index * 25)
    )
    
    -- Only the session owner can toggle others
    -- The owner can't be demoted
    if LootCouncil.Session:IsOwner() and not isOwner then
        row.councilToggle:Enable()
        row.councilToggle:SetScript("OnClick", function()
            if LootCouncil.Session:IsCouncil(playerName) then
                LootCouncil.Session:RemoveCouncilMember(playerName)
            else
                LootCouncil.Session:AddCouncilMember(playerName)
            end
            self:RefreshRoster()
        end)
    else
        row.councilToggle:Disable()
        if isOwner then
            row.councilToggle:SetText("★")
        end
    end

    ---------------------------------------------------
    -- Gear Request Button (Council + Owner only)
    ---------------------------------------------------

    row.gearButton = LootCouncil.UI.Widgets.Button:Create(
        self.scrollContent,
        {
            width = 25,
            height = 20,
            text = "G",
        }
    )
    row.gearButton:SetPoint(
        "LEFT",
        row.councilToggle,
        "RIGHT",
        5,
        0
    )

    -- Only council and owner can request gear
    local canRequestGear = LootCouncil.Session:IsCouncil(UnitName("player"))

    if canRequestGear and playerName ~= UnitName("player") then
        row.gearButton:Enable()
        row.gearButton:SetScript("OnClick", function()
            LootCouncil.Sync:RequestGearFromPlayer(playerName)
            LootCouncil:Print("Requesting gear from " .. playerName)
        end)
    else
        row.gearButton:Disable()
        row.gearButton:SetText("")
    end

    ---------------------------------------------------
    -- Sync Button (Owner only)
    ---------------------------------------------------

    row.syncButton = LootCouncil.UI.Widgets.Button:Create(
        self.scrollContent,
        {
            width = 25,
            height = 20,
            text = "S",
        }
    )
    row.syncButton:SetPoint(
        "LEFT",
        row.gearButton,
        "RIGHT",
        5,
        0
    )

    -- Only the session owner can sync others
    -- The owner can't sync themselves (no-op)
    local canSync = LootCouncil.Session:IsOwner()
        and playerName ~= UnitName("player")

    if canSync then
        row.syncButton:Enable()
        row.syncButton:SetScript("OnClick", function()
            LootCouncil.Sync:TriggerPlayerSync(playerName)
        end)
    else
        row.syncButton:Disable()
        row.syncButton:SetText("")
    end

    return row
end

---------------------------------------------------
-- Refresh Roster
---------------------------------------------------

function view:RefreshRoster()

    if not self.initialized then
        return
    end

    self:ClearRows()

    ---------------------------------------------------
    -- Select Roster
    ---------------------------------------------------

    local players

    if LootCouncil.Session:IsActive() then
        players = LootCouncil.Session:GetPlayers()
    else
        players = LootCouncil.Roster:GetPlayers()
    end

    ---------------------------------------------------
    -- Sort Names
    ---------------------------------------------------

    local names = {}

    for _, player in ipairs(players) do
        table.insert(names, player:GetName())
    end

    table.sort(names)

    ---------------------------------------------------
    -- Create Rows
    ---------------------------------------------------

    for index, playerName in ipairs(names) do
        local row = self:CreateRow(playerName, index)
        table.insert(self.rows, row)
    end

    ---------------------------------------------------
    -- Update Content Height
    ---------------------------------------------------

    local rowHeight = 25
    local contentHeight = math.max(1, (#names + 1) * rowHeight)
    self.scrollContent:SetHeight(contentHeight)

end

---------------------------------------------------
-- Refresh (Legacy — calls RefreshRoster)
---------------------------------------------------

function view:Refresh()

    if not self.initialized then
        self:Initialize()
    end

    if not self.initialized then
        return
    end

    self:RefreshRoster()

end

---------------------------------------------------
-- Create UI Panel
---------------------------------------------------

function view:CreateUIPanel()

    ---------------------------------------------------
    -- Theme Label
    ---------------------------------------------------

    self.themeLabel =
        LootCouncil.UI.Widgets:CreateLabel(
            self.uiPanel,
            {
                font = "GameFontNormalLarge",
                point = "TOPLEFT",
                relativeTo = self.uiPanel,
                relativePoint = "TOPLEFT",
                x = 15,
                y = -15,
                text = "Theme"
            }
        )

    ---------------------------------------------------
    -- Theme Dropdown
    ---------------------------------------------------

    self.themeDropdown =
        LootCouncil.UI.Widgets.Dropdown:Create(
            self.uiPanel,
            {
                width = 150,
                height = 22,
                items = {
                    { text = "Dark", value = "Dark" },
                    { text = "Light", value = "Light" },
                    { text = "Warm", value = "Warm" },
                    { text = "Cool", value = "Cool" },
                },
                default = LootCouncilDB.Theme or "Dark",
                func = function(value)
                    LootCouncil.UI.SettingsTab:SetTheme(value)
                end,
            }
        )

    self.themeDropdown:SetPoint(
        "TOPLEFT",
        self.themeLabel,
        "BOTTOMLEFT",
        0,
        -10
    )

    ---------------------------------------------------
    -- Scale Label
    ---------------------------------------------------

    self.scaleLabel =
        LootCouncil.UI.Widgets:CreateLabel(
            self.uiPanel,
            {
                font = "GameFontNormalLarge",
                point = "TOPLEFT",
                relativeTo = self.themeDropdown,
                relativePoint = "BOTTOMLEFT",
                x = 0,
                y = -20,
                text = "Window Scale"
            }
        )

    ---------------------------------------------------
    -- Scale Dropdown
    ---------------------------------------------------

    self.scaleDropdown =
        LootCouncil.UI.Widgets.Dropdown:Create(
            self.uiPanel,
            {
                width = 150,
                height = 22,
                items = {
                    { text = "80%",  value = 0.8 },
                    { text = "90%",  value = 0.9 },
                    { text = "100%", value = 1.0 },
                    { text = "110%", value = 1.1 },
                    { text = "120%", value = 1.2 },
                    { text = "130%", value = 1.3 },
                },
                default = LootCouncilDB.MainWindowScale or 1.0,
                func = function(value)
                    LootCouncil.UI.SettingsTab:SetScale(value)
                end,
            }
        )

    self.scaleDropdown:SetPoint(
        "TOPLEFT",
        self.scaleLabel,
        "BOTTOMLEFT",
        0,
        -10
    )

end

---------------------------------------------------
-- Set Theme
---------------------------------------------------

function view:SetTheme(themeName)

    if not themeName then
        return
    end

    if not LootCouncil.Constants.Themes[themeName] then
        return
    end

    LootCouncilDB.Theme = themeName
    LootCouncil.Constants.Theme = LootCouncil.Constants.Themes[themeName]

    LootCouncil:Print("Theme changed to: " .. themeName)
    LootCouncil.UI.TabManager:Refresh()
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.UI.SettingsTab:Refresh()

    self:ApplyThemeToAllUI()

end

---------------------------------------------------
-- Set Scale
---------------------------------------------------

function view:SetScale(scale)

    if not scale then
        return
    end

    LootCouncilDB.MainWindowScale = scale

    if LootCouncil.UI.frame then
        LootCouncil.UI.frame:SetScale(scale)
    end

    LootCouncil:Print("Window scale set to " .. tostring(scale) .. ".")

end

---------------------------------------------------
-- Apply Theme to All UI
---------------------------------------------------

function view:ApplyThemeToAllUI()

    local theme = LootCouncil.Constants.Theme

    ---------------------------------------------------
    -- Main Window
    ---------------------------------------------------

    if LootCouncil.UI.MainWindow.frame then
        LootCouncil.UI.Widgets:ApplyThemeBackdrop(
            LootCouncil.UI.MainWindow.frame,
            false
        )
    end

    ---------------------------------------------------
    -- Loot Popup
    ---------------------------------------------------

    if LootCouncil.UI.LootPopup.frame then
        LootCouncil.UI.Widgets:ApplyThemeBackdrop(
            LootCouncil.UI.LootPopup.frame,
            false
        )
    end

    ---------------------------------------------------
    -- Loot Window
    ---------------------------------------------------

    if LootCouncil.UI.LootWindow.frame then
        LootCouncil.UI.Widgets:ApplyThemeBackdrop(
            LootCouncil.UI.LootWindow.frame,
            false
        )
    end

    ---------------------------------------------------
    -- Panels
    ---------------------------------------------------

    if LootCouncil.UI.MainWindow.votingPanel then
        LootCouncil.UI.Widgets:ApplyThemeBackdrop(
            LootCouncil.UI.MainWindow.votingPanel,
            true
        )
    end

    if LootCouncil.UI.MainWindow.settingsPanel then
        LootCouncil.UI.Widgets:ApplyThemeBackdrop(
            LootCouncil.UI.MainWindow.settingsPanel,
            true
        )
    end

    if LootCouncil.UI.MainWindow.historyPanel then
        LootCouncil.UI.Widgets:ApplyThemeBackdrop(
            LootCouncil.UI.MainWindow.historyPanel,
            true
        )
    end

    ---------------------------------------------------
    -- Update All Buttons
    ---------------------------------------------------

    -- Settings tab buttons
    if LootCouncil.UI.SettingsTab.rows then
        for _, row in ipairs(LootCouncil.UI.SettingsTab.rows) do
            if row.councilToggle then
                LootCouncil.UI.Widgets.Button:UpdateTheme(row.councilToggle)
            end
            if row.gearButton then
                LootCouncil.UI.Widgets.Button:UpdateTheme(row.gearButton)
            end
        end
    end

    ---------------------------------------------------
    -- Refresh All Tabs
    ---------------------------------------------------

    LootCouncil.UI.NavigationTabManager:Refresh()
    LootCouncil.UI.TabManager:Refresh()
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.UI.SettingsTab:RefreshRoster()

end