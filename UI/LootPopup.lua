LootCouncil.UI.LootPopup = {}

local popup = LootCouncil.UI.LootPopup

local frame = nil
popup.frame = frame

---------------------------------------------------
-- Create the Loot Popup
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
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Roll Buttons
    local rollMS = LootCouncil.UI.Widgets.Button:Create(
        frame,
        {
            width = 70,
            height = 22,
            text = "Roll MS",
        }
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
        {
            width = 70,
            height = 22,
            text = "Roll OS",
        }
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
    local scrollFrame = LootCouncil.UI.Widgets.ScrollFrame:Create(
        frame,
        {
            contentWidth = 310,
            contentHeight = 100,
        }
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

    local content = scrollFrame.content
    popup.content = content
    popup.scrollFrame = scrollFrame

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

---------------------------------------------------
-- Refresh the Loot Popup
---------------------------------------------------

function popup:Refresh()
    if not frame or not frame:IsShown() then
        return
    end
    
    -- Make sure content exists
    if not popup.content then
        return
    end
    
    -- Clear the popup content
    local children = {popup.content:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
    end
    
    -- Render the Loot tab content into the popup's content panel
    local lootTab = LootCouncil.UI.LootTab
    if lootTab then
        lootTab:Initialize()
        lootTab:RenderInPanel(popup.content)
    end
end