LootCouncil.UI.LootPopup = {}

local popup = LootCouncil.UI.LootPopup

local frame = nil
local initialized = false
local rows = {}
local rowHeight = 85
local content = nil
local scrollFrame = nil

---------------------------------------------------
-- Initialize
---------------------------------------------------

function popup:Initialize()
    if initialized then
        return
    end
    initialized = true
end

---------------------------------------------------
-- Clear Rows
---------------------------------------------------

function popup:ClearRows()
    for _, row in ipairs(rows) do
        if row.number then row.number:Hide() end
        if row.icon then row.icon:Hide() end
        if row.name then row.name:Hide() end
        if row.itemLevel then row.itemLevel:Hide() end
        if row.response then row.response:Hide() end
        if row.buttons then
            for _, button in pairs(row.buttons) do
                button:Hide()
            end
        end
    end
    rows = {}
end

---------------------------------------------------
-- Create Item Row
---------------------------------------------------

function popup:CreateItemRow(item, itemIndex, displayIndex)
    local row = {}
    row.itemNumber = item:GetNumber()

    local yOffset = -(15 + ((displayIndex - 1) * rowHeight))

    -- Item Number
    row.number = LootCouncil.UI.Widgets:CreateLabel(
        content,
        {
            font = "GameFontNormal",
            point = "TOPLEFT",
            relativeTo = content,
            relativePoint = "TOPLEFT",
            x = 2,
            y = yOffset - 8,
            text = tostring(item:GetNumber()) .. "."
        }
    )

    -- Icon
    row.icon = LootCouncil.UI.Widgets.Icon:Create(content, 40)
    row.icon:SetPoint("TOPLEFT", content, "TOPLEFT", 30, yOffset)
    row.icon.item = item
    LootCouncil.UI.Widgets.Icon:SetTexture(row.icon, item:GetIcon())
    LootCouncil.UI.Widgets.Icon:SetItem(row.icon, item:GetLink())

    -- Name
    row.name = LootCouncil.UI.Widgets:CreateLabel(
        content,
        {
            font = "GameFontNormal",
            point = "TOPLEFT",
            relativeTo = row.icon,
            relativePoint = "TOPRIGHT",
            x = 10,
            y = -2,
            text = item:GetName()
        }
    )

    -- Item Level
    row.itemLevel = LootCouncil.UI.Widgets:CreateLabel(
        content,
        {
            point = "TOPLEFT",
            relativeTo = row.name,
            relativePoint = "BOTTOMLEFT",
            x = 0,
            y = -4,
            text = "Item Level: " .. tostring(item:GetItemLevel())
        }
    )

    -- Current Response
    local applicant = item:FindApplicant(UnitName("player"))
    local currentResponse = applicant and "Your Response: " .. applicant:GetResponse() or "Your Response: None"

    row.response = LootCouncil.UI.Widgets:CreateLabel(
        content,
        {
            point = "TOPLEFT",
            relativeTo = row.itemLevel,
            relativePoint = "BOTTOMLEFT",
            x = 0,
            y = -4,
            text = currentResponse
        }
    )

    -- Response Buttons
    row.buttons = {}
    local responses = {"BIS", "MS", "OS", "PASS"}
    local previous

    for _, response in ipairs(responses) do
        local button = LootCouncil.UI.Widgets.Button:Create(
            content,
            { width = 55, height = 20, text = response }
        )

        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 5, 0)
        else
            button:SetPoint("TOPLEFT", row.response, "BOTTOMLEFT", 0, -4)
        end

        row.buttons[response] = button

        button:SetScript("OnClick", function()
            local playerName = UnitName("player")
            local outcome = LootCouncil.Session:SubmitApplicantResponse(playerName, itemIndex, response)

            if outcome == "RECORDED" or outcome == "CHANGED" then
                popup:Refresh()
            end
        end)

        previous = button
    end

    -- Button 4 (hidden)
    row.button4 = LootCouncil.UI.Widgets.Button:Create(
        content,
        { width = 55, height = 20, text = "Button 4" }
    )
    row.button4:SetPoint("LEFT", previous, "RIGHT", 5, 0)
    row.button4:SetAlpha(0.01)

    return row
end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function popup:Refresh()
    if not frame or not frame:IsShown() then
        return
    end

    self:ClearRows()

    local items = LootCouncil.Session:GetItems()
    if not items or #items == 0 then
        return
    end

    local activeItems = {}
    for itemIndex, item in ipairs(items) do
        if not item:IsAwarded() then
            table.insert(activeItems, { item = item, index = itemIndex })
        end
    end

    if #activeItems == 0 then
        return
    end

    for displayIndex, entry in ipairs(activeItems) do
        local row = self:CreateItemRow(entry.item, entry.index, displayIndex)
        table.insert(rows, row)
    end

    local contentHeight = 15 + (#activeItems * rowHeight) + 15
    content:SetHeight(math.max(contentHeight, scrollFrame:GetHeight()))
end

---------------------------------------------------
-- Create the Loot Popup Frame
---------------------------------------------------

function popup:Create()
    if frame then
        frame:Show()
        return frame
    end

    frame = CreateFrame("Frame", "LootCouncilLootPopup", UIParent)
    frame:SetSize(350, 400)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)

    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

    -- Title Bar
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetSize(350, 28)
    titleBar:SetPoint("TOPLEFT")
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER")
    title:SetText("Loot")

    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeText:SetPoint("CENTER")
    closeText:SetText("X")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Roll Buttons
    local rollMS = LootCouncil.UI.Widgets.Button:Create(
        frame,
        { width = 70, height = 22, text = "Roll MS" }
    )
    rollMS:SetPoint("TOP", frame, "TOP", -40, -40)
    rollMS:SetScript("OnClick", function()
        local editBox = ChatEdit_GetLastActiveWindow()
        if editBox then
            editBox:SetText("/roll 100")
            ChatEdit_SendText(editBox)
        end
    end)

    local rollOS = LootCouncil.UI.Widgets.Button:Create(
        frame,
        { width = 70, height = 22, text = "Roll OS" }
    )
    rollOS:SetPoint("LEFT", rollMS, "RIGHT", 5, 0)
    rollOS:SetScript("OnClick", function()
        local editBox = ChatEdit_GetLastActiveWindow()
        if editBox then
            editBox:SetText("/roll 99")
            ChatEdit_SendText(editBox)
        end
    end)

    -- Scroll Frame
    scrollFrame = LootCouncil.UI.Widgets.ScrollFrame:Create(
        frame,
        { contentWidth = 310, contentHeight = 100 }
    )
    scrollFrame:SetPoint("TOPLEFT", 10, -75)
    scrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(scroll, delta)
        local current = scroll:GetVerticalScroll()
        local range = scroll:GetVerticalScrollRange()
        local step = 40
        local newPos = current - (delta * step)
        if newPos < 0 then newPos = 0 end
        if newPos > range then newPos = range end
        scroll:SetVerticalScroll(newPos)
    end)

    content = scrollFrame.content

    frame:Hide()
    return frame
end

---------------------------------------------------
-- Show / Hide / Toggle
---------------------------------------------------

function popup:Show()
    if not frame then
        self:Create()
    end
    frame:Show()
    self:Refresh()
end

function popup:Hide()
    if frame then
        frame:Hide()
    end
end

function popup:Toggle()
    if frame and frame:IsShown() then
        frame:Hide()
    else
        self:Show()
    end
end