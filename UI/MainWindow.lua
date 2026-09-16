LootCouncil.UI.MainWindow = {}

---------------------------------------------------
-- Refresh
---------------------------------------------------

function LootCouncil.UI.MainWindow:Refresh()

    if LootCouncil.UI.TabManager then
        LootCouncil.UI.TabManager:Refresh()
    end

    if LootCouncil.UI.NavigationTabManager then
        LootCouncil.UI.NavigationTabManager:Refresh()
    end

    if LootCouncil.UI.VotingTab then
        LootCouncil.UI.VotingTab:Refresh()
    end

    if LootCouncil.UI.SettingsTab then
        LootCouncil.UI.SettingsTab:Refresh()
    end

    if LootCouncil.UI.HistoryTab then
        LootCouncil.UI.HistoryTab:Refresh()
    end

    if LootCouncil.UI.LootPopup then
        LootCouncil.UI.LootPopup:Refresh()
    end

    if self.sessionInfoBox then
        self.sessionInfoBox:Refresh()
    end

    self:RefreshSyncButtons()

end

---------------------------------------------------
-- Refresh Sync Buttons
---------------------------------------------------

function LootCouncil.UI.MainWindow:RefreshSyncButtons()

    if not self.syncRaidButton or not self.syncCouncilButton then
        return
    end

    local showButtons = LootCouncil.Session:IsActive()
        and LootCouncil.Session:IsOwner()

    if showButtons then
        self.syncRaidButton:Show()
        self.syncCouncilButton:Show()
    else
        self.syncRaidButton:Hide()
        self.syncCouncilButton:Hide()
    end

end

---------------------------------------------------
-- Main Window
---------------------------------------------------

local frame = CreateFrame("Frame", "LootCouncilMainWindow", UIParent)

frame:SetSize(800, 560)
frame:SetPoint("CENTER")

frame:SetScale(LootCouncilDB.MainWindowScale or 1.0)

LootCouncil.UI.Widgets:ApplyThemeBackdrop(frame, false)

frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)

---------------------------------------------------
-- Title Bar
---------------------------------------------------

local titleBar = CreateFrame("Frame", nil, frame)

titleBar:SetHeight(28)
titleBar:SetPoint("TOPLEFT")
titleBar:SetPoint("TOPRIGHT", -28, 0)

titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")

titleBar:SetScript("OnDragStart", function()
    frame:StartMoving()
end)

titleBar:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
end)

---------------------------------------------------
-- Title (Centered)
---------------------------------------------------

local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")

title:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
title:SetText("Loot Council")

---------------------------------------------------
-- Refresh Button
---------------------------------------------------

local refreshButton = LootCouncil.UI.Widgets.Button:Create(
    titleBar,
    {
        width = 70,
        height = 22,
        text = "Refresh",
    }
)

refreshButton:SetPoint("RIGHT", titleBar, "RIGHT", -30, 0)

refreshButton:SetScript("OnClick", function()

    LootCouncil.UI.MainWindow:Refresh()

    LootCouncil:Print("UI refreshed.")

end)

---------------------------------------------------
-- Sync Raid Button
---------------------------------------------------

local syncRaidButton = LootCouncil.UI.Widgets.Button:Create(
    titleBar,
    {
        width = 80,
        height = 22,
        text = "Sync Raid",
    }
)

syncRaidButton:SetPoint("RIGHT", refreshButton, "LEFT", -5, 0)

syncRaidButton:SetScript("OnClick", function()
    LootCouncil.Sync:TriggerRaidSync()
end)

LootCouncil.UI.MainWindow.syncRaidButton = syncRaidButton

---------------------------------------------------
-- Sync Council Button
---------------------------------------------------

local syncCouncilButton = LootCouncil.UI.Widgets.Button:Create(
    titleBar,
    {
        width = 90,
        height = 22,
        text = "Sync Council",
    }
)

syncCouncilButton:SetPoint("RIGHT", syncRaidButton, "LEFT", -5, 0)

syncCouncilButton:SetScript("OnClick", function()
    LootCouncil.Sync:TriggerCouncilSync()
end)

LootCouncil.UI.MainWindow.syncCouncilButton = syncCouncilButton

syncRaidButton:Hide()
syncCouncilButton:Hide()

---------------------------------------------------
-- Close Button
---------------------------------------------------

local closeButton = CreateFrame("Button", nil, frame)

closeButton:SetSize(24, 24)
closeButton:SetPoint("TOPRIGHT", -2, -2)
closeButton:EnableMouse(true)

local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
closeText:SetPoint("CENTER")
closeText:SetText("X")

closeButton:SetScript("OnClick", function()
    frame:Hide()
end)

closeButton:SetScript("OnEnter", function()
    closeText:SetTextColor(1, 0.2, 0.2)
end)

closeButton:SetScript("OnLeave", function()
    closeText:SetTextColor(1, 1, 1)
end)

---------------------------------------------------
-- Version
---------------------------------------------------

local version = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")

version:SetPoint("BOTTOMRIGHT", -10, 8)
version:SetText("Version " .. LootCouncil.version)

---------------------------------------------------
-- Content
---------------------------------------------------

local content = CreateFrame("Frame", nil, frame)

content:SetPoint("TOPLEFT", 10, -40)
content:SetPoint("BOTTOMRIGHT", -10, 30)

LootCouncil.UI.MainWindow.content = content

---------------------------------------------------
-- Navigation Bar
---------------------------------------------------

local navigationBar = CreateFrame("Frame", nil, content)

navigationBar:SetPoint("TOPLEFT")
navigationBar:SetPoint("TOPRIGHT")
navigationBar:SetHeight(30)

LootCouncil.UI.MainWindow.navigationBar = navigationBar

---------------------------------------------------
-- Workspace
---------------------------------------------------

local workspace =
    LootCouncil.UI.Widgets:CreatePanel(content)

workspace:SetPoint(
    "TOPLEFT",
    navigationBar,
    "BOTTOMLEFT",
    0,
    -5
)

workspace:SetPoint(
    "TOPRIGHT",
    navigationBar,
    "BOTTOMRIGHT",
    0,
    -5
)

workspace:SetPoint(
    "BOTTOMLEFT",
    content,
    "BOTTOMLEFT",
    0,
    0
)

workspace:SetPoint(
    "BOTTOMRIGHT",
    content,
    "BOTTOMRIGHT",
    0,
    0
)

LootCouncil.UI.MainWindow.workspace =
    workspace

---------------------------------------------------
-- Sidebar
---------------------------------------------------

local sidebar = CreateFrame("Frame", nil, workspace)

sidebar:SetWidth(180)
sidebar:SetPoint("TOPLEFT", workspace, "TOPLEFT", 0, 0)
sidebar:SetPoint("BOTTOMLEFT", workspace, "BOTTOMLEFT", 0, 0)

LootCouncil.UI.MainWindow.sidebar = sidebar

---------------------------------------------------
-- Session Info Box
---------------------------------------------------

local sessionInfoBox =
    LootCouncil.UI.Widgets.SessionInfoBox:Create(
        sidebar,
        {
            width = 200,
            height = 70,
        }
    )

sessionInfoBox:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, 0)
sessionInfoBox:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, 0)

LootCouncil.UI.MainWindow.sessionInfoBox = sessionInfoBox

---------------------------------------------------
-- Item List Scroll Frame
---------------------------------------------------

local itemScroll =
    LootCouncil.UI.Widgets.ScrollFrame:Create(
        sidebar,
        {
            contentWidth = 185,
            contentHeight = 100,
        }
    )

itemScroll:SetPoint("TOPLEFT", sessionInfoBox, "BOTTOMLEFT", 0, -5)
itemScroll:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", 0, 0)

itemScroll:EnableMouseWheel(true)

itemScroll:SetScript(
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

LootCouncil.UI.MainWindow.itemScroll = itemScroll
LootCouncil.UI.MainWindow.itemContent = itemScroll.content

---------------------------------------------------
-- Voting Panel
---------------------------------------------------

local votingPanel =
    LootCouncil.UI.Widgets:CreatePanel(
        workspace
    )

votingPanel:SetPoint(
    "TOPLEFT",
    sidebar,
    "TOPRIGHT",
    5,
    0
)

votingPanel:SetPoint(
    "BOTTOMRIGHT",
    workspace,
    "BOTTOMRIGHT"
)

LootCouncil.UI.MainWindow.votingPanel =
    votingPanel

---------------------------------------------------
-- Settings Panel
---------------------------------------------------

local settingsPanel =
    LootCouncil.UI.Widgets:CreatePanel(
        workspace
    )

settingsPanel:SetPoint(
    "TOPLEFT",
    workspace,
    "TOPLEFT"
)

settingsPanel:SetPoint(
    "BOTTOMRIGHT",
    workspace,
    "BOTTOMRIGHT"
)

LootCouncil.UI.MainWindow.settingsPanel =
    settingsPanel

---------------------------------------------------
-- History Panel
---------------------------------------------------

local historyPanel =
    LootCouncil.UI.Widgets:CreatePanel(
        workspace
    )

historyPanel:SetPoint(
    "TOPLEFT",
    workspace,
    "TOPLEFT"
)

historyPanel:SetPoint(
    "BOTTOMRIGHT",
    workspace,
    "BOTTOMRIGHT"
)

LootCouncil.UI.MainWindow.historyPanel =
    historyPanel

---------------------------------------------------
-- Placeholder Workspace
---------------------------------------------------

local placeholder = workspace:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalLarge"
)

placeholder:SetPoint("CENTER")

---------------------------------------------------
-- Finish
---------------------------------------------------

LootCouncil.UI.MainWindow.frame = frame

LootCouncil.UI.NavigationTabManager:Initialize(
    navigationBar
)

LootCouncil.UI.TabManager:Initialize(
    LootCouncil.UI.MainWindow.itemContent
)

LootCouncil.UI.MainWindow:Refresh()

frame:Hide()

LootCouncil.UI.frame = frame

LootCouncil:Print(
    "DEBUG UI.frame = " ..
    tostring(LootCouncil.UI.frame)
)