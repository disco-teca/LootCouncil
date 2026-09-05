LootCouncil.UI.MainWindow = {}

---------------------------------------------------
-- Main Window
---------------------------------------------------

local frame = CreateFrame("Frame", "LootCouncilMainWindow", UIParent)

frame:SetSize(1000, 650)
frame:SetPoint("CENTER")

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})

frame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

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
title:SetText("LootCouncil v" .. LootCouncil.version)

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
-- Loot Item Bar
---------------------------------------------------

local itemBar = CreateFrame("Frame", nil, content)

itemBar:SetPoint("TOPLEFT", navigationBar, "BOTTOMLEFT", 0, -5)
itemBar:SetPoint("TOPRIGHT", navigationBar, "BOTTOMRIGHT", 0, -5)
itemBar:SetHeight(30)

LootCouncil.UI.MainWindow.itemBar = itemBar

---------------------------------------------------
-- Action Toolbar
---------------------------------------------------

local toolbar = CreateFrame("Frame", nil, content)

toolbar:SetPoint("TOPLEFT", itemBar, "BOTTOMLEFT", 0, -5)
toolbar:SetPoint("TOPRIGHT", itemBar, "BOTTOMRIGHT", 0, -5)
toolbar:SetHeight(30)

LootCouncil.UI.MainWindow.toolbar = toolbar

---------------------------------------------------
-- Workspace
---------------------------------------------------

local workspace =
    LootCouncil.UI.Widgets:CreatePanel(content)

workspace:SetPoint(
    "TOPLEFT",
    toolbar,
    "BOTTOMLEFT",
    0,
    -5
)

workspace:SetPoint(
    "TOPRIGHT",
    toolbar,
    "BOTTOMRIGHT",
    0,
    -5
)

workspace:SetPoint(
    "BOTTOMLEFT",
    content,
    "BOTTOMLEFT",
    0,
    25
)

workspace:SetPoint(
    "BOTTOMRIGHT",
    content,
    "BOTTOMRIGHT",
    0,
    25
)

LootCouncil.UI.MainWindow.workspace =
    workspace

---------------------------------------------------
-- Voting Panel
---------------------------------------------------

local votingPanel =
    LootCouncil.UI.Widgets:CreatePanel(
        workspace
    )

votingPanel:SetPoint(
    "TOPLEFT",
    workspace,
    "TOPLEFT"
)

votingPanel:SetPoint(
    "BOTTOMRIGHT",
    workspace,
    "BOTTOMRIGHT"
)

LootCouncil.UI.MainWindow.votingPanel =
    votingPanel

---------------------------------------------------
-- Loot Panel
---------------------------------------------------

local lootPanel =
    LootCouncil.UI.Widgets:CreatePanel(
        workspace
    )

lootPanel:SetPoint(
    "TOPLEFT",
    workspace,
    "TOPLEFT"
)

lootPanel:SetPoint(
    "BOTTOMRIGHT",
    workspace,
    "BOTTOMRIGHT"
)

LootCouncil.UI.MainWindow.lootPanel =
    lootPanel

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
-- Status Bar
---------------------------------------------------

local statusBar = LootCouncil.UI.Widgets:CreatePanel(content)

statusBar:SetPoint("BOTTOMLEFT")
statusBar:SetPoint("BOTTOMRIGHT")
statusBar:SetHeight(22)

LootCouncil.UI.MainWindow.statusBar = statusBar

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
    itemBar
)

LootCouncil.UI.VotingTab:Refresh()

LootCouncil.UI.TabManager:Refresh()

frame:Hide()

LootCouncil.UI.frame = frame

LootCouncil:Print(
    "DEBUG UI.frame = " ..
    tostring(LootCouncil.UI.frame)
)