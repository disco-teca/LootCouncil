LootCouncil.UI.LootWindow = {}

local window = LootCouncil.UI.LootWindow

local frame = nil
local initialized = false
local rows = {}
local content = nil
local scrollFrame = nil
local itemQueue = {}

local ROW_HEIGHT = 35

---------------------------------------------------
-- Initialize
---------------------------------------------------

function window:Initialize()
    if initialized then
        return
    end
    initialized = true
end

---------------------------------------------------
-- Clear Rows
---------------------------------------------------

function window:ClearRows()
    for _, row in ipairs(rows) do
        if row.number then row.number:Hide() end
        if row.icon then row.icon:Hide() end
        if row.name then row.name:Hide() end
        if row.itemLevel then row.itemLevel:Hide() end
        if row.response then row.response:Hide() end
        if row.removeBtn then row.removeBtn:Hide() end
    end
    rows = {}
end

---------------------------------------------------
-- Create Item Row
---------------------------------------------------

function window:CreateItemRow(itemData, displayIndex)
    local row = {}

    local yOffset = -(15 + ((displayIndex - 1) * ROW_HEIGHT))

    -- Item Number (smaller font)
    row.number = LootCouncil.UI.Widgets:CreateLabel(
        content,
        {
            font = "GameFontNormal",
            point = "TOPLEFT",
            relativeTo = content,
            relativePoint = "TOPLEFT",
            x = 2,
            y = yOffset - 4,
            text = tostring(displayIndex) .. "."
        }
    )

    -- Icon (smaller)
    local iconSize = 28
    row.icon = LootCouncil.UI.Widgets.Icon:Create(content, iconSize)
    row.icon:SetPoint("TOPLEFT", content, "TOPLEFT", 30, yOffset)
    
    local icon = itemData.icon
    if not icon and itemData.id then
        local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemData.id)
        icon = itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
    elseif not icon then
        icon = "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    LootCouncil.UI.Widgets.Icon:SetTexture(row.icon, icon)
    LootCouncil.UI.Widgets.Icon:SetItem(row.icon, itemData.link or "")

    -- Name (smaller font, tighter spacing)
    row.name = LootCouncil.UI.Widgets:CreateLabel(
        content,
        {
            font = "GameFontNormal",
            point = "TOPLEFT",
            relativeTo = row.icon,
            relativePoint = "TOPRIGHT",
            x = 8,
            y = -2,
            text = itemData.name or "Unknown Item"
        }
    )

    -- Item Level (tighter spacing)
    row.itemLevel = LootCouncil.UI.Widgets:CreateLabel(
        content,
        {
            point = "TOPLEFT",
            relativeTo = row.name,
            relativePoint = "BOTTOMLEFT",
            x = 0,
            y = -2,
            text = "Item Level: " .. tostring(itemData.ilvl or 0)
        }
    )

    -- Remove Button (X) - aligned with the row
    row.removeBtn = LootCouncil.UI.Widgets.Button:Create(
        content,
        { width = 30, height = 20, text = "X" }
    )
    row.removeBtn:SetPoint("LEFT", row.name, "RIGHT", 30, 0)
    row.removeBtn:SetScript("OnClick", function()
        for i, data in ipairs(itemQueue) do
            if data == itemData then
                table.remove(itemQueue, i)
                break
            end
        end
        window:Refresh()
    end)

    return row
end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function window:Refresh()
    if not frame or not frame:IsShown() then
        return
    end

    self:ClearRows()

    if #itemQueue == 0 then
        return
    end

    for displayIndex, itemData in ipairs(itemQueue) do
        local row = self:CreateItemRow(itemData, displayIndex)
        table.insert(rows, row)
    end

    local contentHeight = 15 + (#itemQueue * ROW_HEIGHT) + 15
    content:SetHeight(math.max(contentHeight, scrollFrame:GetHeight()))
end

---------------------------------------------------
-- Add Item to Queue
---------------------------------------------------

function window:AddItem(itemData)
    if not itemData then
        return
    end
    table.insert(itemQueue, itemData)
end

---------------------------------------------------
-- Clear Queue
---------------------------------------------------

function window:ClearQueue()
    itemQueue = {}
end

---------------------------------------------------
-- Create the Loot Window Frame
---------------------------------------------------

function window:Create()
    if frame then
        frame:Show()
        return frame
    end

    frame = CreateFrame("Frame", "LootCouncilLootWindow", UIParent)
    frame:SetSize(350, 430)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)

    LootCouncil.UI.Widgets:ApplyThemeBackdrop(frame, false)

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
    title:SetText("Add Loot")

    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeText:SetPoint("CENTER")
    closeText:SetText("X")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

        -- Scroll Frame (same as LootPopup)
    scrollFrame = LootCouncil.UI.Widgets.ScrollFrame:Create(
        frame,
        { contentWidth = 310, contentHeight = 100 }
    )
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -10, -10)

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local range = self:GetVerticalScrollRange()
        local step = 40
        local newPos = current - (delta * step)
        if newPos < 0 then newPos = 0 end
        if newPos > range then newPos = range end
        self:SetVerticalScroll(newPos)
    end)

    content = scrollFrame.content

    -- Accept and Cancel Buttons
    local acceptBtn = LootCouncil.UI.Widgets.Button:Create(
        frame,
        { width = 80, height = 22, text = "Accept" }
    )
    acceptBtn:SetPoint("BOTTOMLEFT", 15, 10)
    acceptBtn:SetScript("OnClick", function()
        if #itemQueue == 0 then
            LootCouncil:Print("No items to add.")
            return
        end
        for _, itemData in ipairs(itemQueue) do
            LootCouncil.Session:AddItem(itemData)
        end
        window:ClearQueue()
        frame:Hide()
    end)

    local cancelBtn = LootCouncil.UI.Widgets.Button:Create(
        frame,
        { width = 80, height = 22, text = "Cancel" }
    )
    cancelBtn:SetPoint("LEFT", acceptBtn, "RIGHT", 10, 0)
    cancelBtn:SetPoint("BOTTOM", acceptBtn, "BOTTOM", 0, 0)
    cancelBtn:SetScript("OnClick", function()
        window:ClearQueue()
        frame:Hide()
    end)

    frame:Hide()
    return frame
end

---------------------------------------------------
-- Show / Hide / Toggle
---------------------------------------------------

function window:Show()
    if not frame then
        self:Create()
    end
    frame:Show()
    self:Refresh()
end

function window:Hide()
    if frame then
        frame:Hide()
    end
end

function window:Toggle()
    if frame and frame:IsShown() then
        frame:Hide()
    else
        self:Show()
    end
end