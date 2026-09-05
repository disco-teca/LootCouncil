LootCouncil.UI.RollPopup = {}

local popup = LootCouncil.UI.RollPopup

local frame = nil
local titleText = nil
local rollsTable = nil
local timerLabel = nil
local rowCache = {}

---------------------------------------------------
-- Create the Popup Window
---------------------------------------------------

function popup:Create()
    if frame then
        frame:Show()
        return frame
    end

    -- Main frame
    frame = CreateFrame("Frame", "LootCouncilRollPopup", UIParent)
    frame:SetSize(350, 250)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    -- Set frame level to appear on top
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)

    -- Backdrop (solid black, fully opaque)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 1.0)      -- Solid black background
    frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1.0)  -- Gray border

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetSize(350, 28)
    titleBar:SetPoint("TOPLEFT")
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    -- Title text
    titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("CENTER")
    titleText:SetText("Rolls")
    titleText:SetTextColor(1, 1, 1)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeText:SetPoint("CENTER")
    closeText:SetText("X")
    closeText:SetTextColor(1, 1, 1)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Rolls table header
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", 15, -40)
    header:SetText("Player          Roll          Type")
    header:SetTextColor(0.8, 0.8, 0.8)

    -- Rolls list container
    rollsTable = CreateFrame("Frame", nil, frame)
    rollsTable:SetPoint("TOPLEFT", 15, -65)
    rollsTable:SetPoint("BOTTOMRIGHT", -15, -50)

    -- Timer label
    timerLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    timerLabel:SetPoint("BOTTOMLEFT", 15, 10)
    timerLabel:SetText("⏱ Time remaining: --")
    timerLabel:SetTextColor(0.8, 0.8, 0)

    frame:Hide()
    return frame
end

---------------------------------------------------
-- Refresh the Popup
---------------------------------------------------

function popup:Refresh()
    if not frame then
        return
    end

    local activeRoll = LootCouncil.Roll:GetActiveRoll()
    local rollHistory = LootCouncil.Roll:GetHistory()
    
    if not activeRoll and #rollHistory == 0 then
        -- If no roll data, show a message
        if titleText then
            titleText:SetText("No rolls found")
        end
        return
    end

    if activeRoll then
        -- Update with active roll data
        if titleText then
            local itemName = activeRoll.item and activeRoll.item:GetName() or "Unknown"
            local rollType = activeRoll.rollType or "MS"
            titleText:SetText("Rolls for " .. itemName .. " (" .. rollType .. ")")
        end
        self:UpdateRollsList(activeRoll)
        self:UpdateTimer(activeRoll.remainingTime or "--")
    else
        -- Show history or a message
        if titleText then
            titleText:SetText("Roll History")
        end
        -- Optionally show the last roll's data
        if #rollHistory > 0 then
            local lastRoll = rollHistory[#rollHistory]
            self:UpdateRollsList(lastRoll)
        end
    end
end

---------------------------------------------------
-- Update Rolls List
---------------------------------------------------

function popup:UpdateRollsList(activeRoll)
    if not rollsTable then
        return
    end

    if activeRoll then
        if activeRoll.rolls then
            local count = 0
            for _ in pairs(activeRoll.rolls) do
                count = count + 1
            end
        end
    end

    -- Clear existing roll entries
    if popup.rowCache then
        for _, row in ipairs(popup.rowCache) do
            row:SetText("")
            row:Hide()
        end
    else
        popup.rowCache = {}
    end

    if not activeRoll or not activeRoll.rolls then
        return
    end

    -- Build sorted list
    local sortedRolls = {}
    for playerName, data in pairs(activeRoll.rolls) do
        if type(data) == "table" and data.roll and data.type then
            table.insert(sortedRolls, { name = playerName, roll = data.roll, type = data.type })
        end
    end

    if #sortedRolls == 0 then
        return
    end

    -- Sort: MS first, then OS, highest to lowest
    table.sort(sortedRolls, function(a, b)
        if a.type ~= b.type then
            return a.type == "MS" and b.type == "OS"
        end
        return a.roll > b.roll
    end)

    -- Display rolls
    for i, data in ipairs(sortedRolls) do
        local row = popup.rowCache[i]
        if not row then
            row = rollsTable:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row:SetPoint("TOPLEFT", 0, -((i - 1) * 20))
            row:SetWidth(320)
            popup.rowCache[i] = row
        end
        row:SetText(string.format("%-16s %-6d      %s", data.name, data.roll, data.type))
        row:SetTextColor(1, 1, 1)
        row:Show()
    end
end

---------------------------------------------------
-- Update Timer
---------------------------------------------------

function popup:UpdateTimer(remaining)
    if not timerLabel then
        return
    end

    -- Check if remaining is a number
    if type(remaining) == "number" and remaining > 0 then
        timerLabel:SetText("Time remaining: " .. remaining .. "s")
        timerLabel:SetTextColor(0.8, 0.8, 0)
    else
        timerLabel:SetText("Time remaining: --")
        timerLabel:SetTextColor(0.5, 0.5, 0.5)
    end
end

---------------------------------------------------
-- Show the Popup
---------------------------------------------------

function popup:Show()
    if not frame then
        self:Create()
    end
    frame:Show()
end

---------------------------------------------------
-- Hide the Popup
---------------------------------------------------

function popup:Hide()
    if frame then
        frame:Hide()
    end
end