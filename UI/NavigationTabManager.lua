LootCouncil.UI.NavigationTabManager = {}

local manager =
    LootCouncil.UI.NavigationTabManager

manager.tabs = {}
manager.selected = "Loot"

---------------------------------------------------
-- Initialize
---------------------------------------------------

function manager:Initialize(parent)

    self.parent = parent

    self:CreateTabs()

end

---------------------------------------------------
-- Create Tabs
---------------------------------------------------

function manager:CreateTabs()

    local names = {

        "Voting",
        "Loot",
        "Attendance",
        "History",
        "BiS",
        "Settings"

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
-- Select
---------------------------------------------------

function manager:Select(name)

    local playerName =
        UnitName("player")

    ---------------------------------------------------
    -- Permission
    ---------------------------------------------------

    if not LootCouncil.Permissions:CanViewTab(
        playerName,
        name
    ) then

        return

    end

    self.selected = name

    self:Refresh()

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function manager:Refresh()

    local playerName =
        UnitName("player")

    ---------------------------------------------------
    -- Show All Tabs
    ---------------------------------------------------

    for name, tab in pairs(
        self.tabs
    ) do

        tab:Show()

        tab:SetSelected(
            name == self.selected
        )

    end

    ---------------------------------------------------
    -- Hide Workspace Panels
    ---------------------------------------------------

    local votingPanel =
        LootCouncil.UI.MainWindow.votingPanel

    local lootPanel =
        LootCouncil.UI.MainWindow.lootPanel

    local settingsPanel =
        LootCouncil.UI.MainWindow.settingsPanel

    if votingPanel then
        votingPanel:Hide()
    end

    if lootPanel then
        lootPanel:Hide()
    end

    if settingsPanel then
        settingsPanel:Hide()
    end

    ---------------------------------------------------
    -- Item Tab Visibility
    ---------------------------------------------------

    LootCouncil.UI.TabManager:SetVisible(
        self.selected == "Voting"
    )

    ---------------------------------------------------
    -- Show Selected Panel
    ---------------------------------------------------

    if self.selected == "Voting" then

        if votingPanel then
            votingPanel:Show()
        end

        LootCouncil.UI.VotingTab:Refresh()

    elseif self.selected == "Loot" then

        if lootPanel then
            lootPanel:Show()
        end

        LootCouncil.UI.LootTab:Refresh()

    elseif self.selected == "Settings" then

        if settingsPanel then
            settingsPanel:Show()
        end

        LootCouncil.UI.SettingsTab:Refresh()

    end

end

---------------------------------------------------
-- Active Tab
---------------------------------------------------

function manager:GetSelected()

    return self.selected

end