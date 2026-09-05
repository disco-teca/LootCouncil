LootCouncil.UI.LootTab = {}

LootCouncil:Print("LOOTTAB FILE LOADED")

local view = LootCouncil.UI.LootTab

view.initialized = false
view.rows = {}

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

    ---------------------------------------------------
    -- Scroll Frame
    ---------------------------------------------------

    self.scrollFrame =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.panel,
            {
                contentWidth = 750,
                contentHeight = 100,
            }
        )

    self.scrollFrame:SetPoint(
        "TOPLEFT",
        self.panel,
        "TOPLEFT",
        5,
        -5
    )

    self.scrollFrame:SetPoint(
        "BOTTOMRIGHT",
        self.panel,
        "BOTTOMRIGHT",
        -25,
        5
    )

    ---------------------------------------------------
    -- Mouse Wheel
    ---------------------------------------------------

    self.scrollFrame:EnableMouseWheel(true)

    self.scrollFrame:SetScript(
        "OnMouseWheel",
        function(frame, delta)

            local current =
                frame:GetVerticalScroll()

            local range =
                frame:GetVerticalScrollRange()

            local step = 40

            local newPosition =
                current - (
                    delta * step
                )

            if newPosition < 0 then
                newPosition = 0
            end

            if newPosition > range then
                newPosition = range
            end

            frame:SetVerticalScroll(
                newPosition
            )

        end
    )

    self.content =
        self.scrollFrame.content

    ---------------------------------------------------
    -- Row Settings
    ---------------------------------------------------

    self.rowHeight = 85

    ---------------------------------------------------
    -- Widgets
    ---------------------------------------------------

    self:CreateWidgets()

    self.initialized = true

end

---------------------------------------------------
-- Create Widgets
---------------------------------------------------

function view:CreateWidgets()

    ---------------------------------------------------
    -- Item Icon
    ---------------------------------------------------

    self.icon =
        LootCouncil.UI.Widgets.Icon:Create(
            self.panel,
            48
        )

    self.icon:SetPoint(
        "TOPLEFT",
        self.panel,
        "TOPLEFT",
        20,
        -20
    )

    ---------------------------------------------------
    -- Item Name
    ---------------------------------------------------

    self.title =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                font = "GameFontNormalLarge",

                point = "TOPLEFT",
                relativeTo = self.icon,
                relativePoint = "TOPRIGHT",

                x = 12,
                y = 2,
            }
        )

    ---------------------------------------------------
    -- Item Level
    ---------------------------------------------------

    self.itemLevel =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.title,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -5,
            }
        )

    ---------------------------------------------------
    -- Status
    ---------------------------------------------------

    self.status =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.currentResponse,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -10,

                text = "Waiting for loot."
            }
        )

end

---------------------------------------------------
-- Clear Item
---------------------------------------------------

function view:ClearItem()

    LootCouncil.UI.Widgets.Icon:SetTexture(
        self.icon,
        nil
    )

    LootCouncil.UI.Widgets.Icon:SetItem(
        self.icon,
        nil
    )

    self.title:SetText(
        "No loot item selected."
    )

    self.itemLevel:SetText(
        ""
    )

    self.currentResponse:SetText(
        "Current Response: None"
    )

    self.status:SetText(
        "Waiting for loot."
    )

end

---------------------------------------------------
-- Clear Rows
---------------------------------------------------

function view:ClearRows()

    for _, row in ipairs(self.rows) do

        if row.number then
            row.number:Hide()
        end
        
        if row.icon then
            row.icon:Hide()
        end

        if row.name then
            row.name:Hide()
        end

        if row.itemLevel then
            row.itemLevel:Hide()
        end

        if row.response then
            row.response:Hide()
        end

        if row.buttons then

            for _, button in pairs(
                row.buttons
            ) do

                button:Hide()

            end

        end

    end

    self.rows = {}

end

---------------------------------------------------
-- Create Item Row
---------------------------------------------------

function view:CreateItemRow(
    item,
    itemIndex,
    displayIndex
)

    local row = {}

    row.itemNumber = item:GetNumber()

    local yOffset =
        -(
            15 +
            (
                (displayIndex - 1) *
                self.rowHeight
            )
        )

    ---------------------------------------------------
    -- Item Number
    ---------------------------------------------------

    row.number =
        LootCouncil.UI.Widgets:CreateLabel(
            self.content,
            {
                font = "GameFontNormal",

                point = "TOPLEFT",
                relativeTo = self.content,
                relativePoint = "TOPLEFT",

                x = 2,
                y = yOffset - 8,

                text =
                    tostring(
                        item:GetNumber()
                    ) ..
                    "."
            }
        )

    ---------------------------------------------------
    -- Icon
    ---------------------------------------------------

    row.icon =
        LootCouncil.UI.Widgets.Icon:Create(
            self.content,
            40
        )

    row.icon:SetPoint(
        "TOPLEFT",
        self.content,
        "TOPLEFT",
        30,
        yOffset
    )

    row.icon.item = item

    LootCouncil.UI.Widgets.Icon:SetTexture(
        row.icon,
        item:GetIcon()
    )

    LootCouncil.UI.Widgets.Icon:SetItem(
        row.icon,
        item:GetLink()
    )

    ---------------------------------------------------
    -- Name
    ---------------------------------------------------

    row.name =
        LootCouncil.UI.Widgets:CreateLabel(
            self.content,
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

    ---------------------------------------------------
    -- Item Level
    ---------------------------------------------------

    row.itemLevel =
        LootCouncil.UI.Widgets:CreateLabel(
            self.content,
            {
                point = "TOPLEFT",
                relativeTo = row.name,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -4,

                text =
                    "Item Level: " ..
                    tostring(
                        item:GetItemLevel()
                    )
            }
        )

    ---------------------------------------------------
    -- Current Response (Moved UP before buttons)
    ---------------------------------------------------

    local applicant =
        item:FindApplicant(
            UnitName("player")
        )

    local currentResponse

    if applicant then
        currentResponse =
            "Your Response: " ..
            applicant:GetResponse()
    else
        currentResponse =
            "Your Response: None"
    end

    row.response =
        LootCouncil.UI.Widgets:CreateLabel(
            self.content,
            {
                point = "TOPLEFT",
                relativeTo = row.itemLevel,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -4,

                text = currentResponse
            }
        )

    ---------------------------------------------------
    -- Response Buttons (Moved DOWN under the response label)
    ---------------------------------------------------

    row.buttons = {}

    local responses = {
        "BIS",
        "MS",
        "OS",
        "PASS",
    }

    local previous

    for _, response in ipairs(responses) do

        local button =
            LootCouncil.UI.Widgets.Button:Create(
                self.content,
                {
                    width = 55,
                    height = 20,
                    text = response,
                }
            )

        if previous then
            button:SetPoint(
                "LEFT",
                previous,
                "RIGHT",
                5,
                0
            )
        else
            button:SetPoint(
                "TOPLEFT",
                row.response,
                "BOTTOMLEFT",
                0,
                -4
            )
        end

        row.buttons[response] = button

        button:SetScript(
            "OnClick",
            function()
                local playerName = UnitName("player")
                local outcome = LootCouncil.Session:SubmitApplicantResponse(
                    playerName,
                    itemIndex,
                    response
                )

                if outcome == "RECORDED" or outcome == "CHANGED" then
                    LootCouncil.UI.LootTab:Refresh()
                    LootCouncil.UI.VotingTab:Refresh()
                    if LootCouncil.UI.LootPopup then
                        LootCouncil.UI.LootPopup:Refresh()
                    end
                end
            end
        )

        previous = button

    end

    ---------------------------------------------------
    -- Button 4 (Hidden)
    ---------------------------------------------------

    row.button4 =
        LootCouncil.UI.Widgets.Button:Create(
            self.content,
            {
                width = 55,
                height = 20,
                text = "Button 4",
            }
        )

    row.button4:SetPoint(
        "LEFT",
        previous,
        "RIGHT",
        5,
        0
    )

    row.button4:SetAlpha(0.01)

    row.button4:SetScript(
        "OnClick",
        function()
            row.response:SetText(
                "Your Response: Troll"
            )
            DEFAULT_CHAT_FRAME:AddMessage(
                "No."
            )
        end
    )

    return row

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function view:Refresh()

    self:Initialize()

    if not self.initialized then
        return
    end

    self:ClearRows()

    local items =
        LootCouncil.Session:GetItems()

    if not items or #items == 0 then

        self.status:SetText(
            "Waiting for loot."
        )

        self.content:SetHeight(
            self.scrollFrame:GetHeight()
        )

        self.scrollFrame:SetVerticalScroll(
            0
        )

        return

    end

    ---------------------------------------------------
    -- Create Active Item List
    ---------------------------------------------------

    local activeItems = {}

    for itemIndex, item in ipairs(items) do

        if not item:IsAwarded() then

            table.insert(
                activeItems,
                {
                    item = item,
                    index = itemIndex,
                }
            )

        end

    end

    ---------------------------------------------------
    -- No Active Items
    ---------------------------------------------------

    if #activeItems == 0 then

        self.status:SetText(
            "Waiting for loot."
        )

        self.content:SetHeight(
            self.scrollFrame:GetHeight()
        )

        self.scrollFrame:SetVerticalScroll(
            0
        )

        return

    end

    self.status:SetText(
        ""
    )

    ---------------------------------------------------
    -- Create Rows
    ---------------------------------------------------

    for displayIndex, entry in ipairs(
        activeItems
    ) do

        local row =
            self:CreateItemRow(

                entry.item,

                entry.index,

                displayIndex

            )

        table.insert(
            self.rows,
            row
        )

    end

    ---------------------------------------------------
    -- Content Height
    ---------------------------------------------------

    local contentHeight =
        15 +
        (
            #activeItems *
            self.rowHeight
        ) +
        15

    self.content:SetHeight(
        math.max(
            contentHeight,
            self.scrollFrame:GetHeight()
        )
    )

    ---------------------------------------------------
    -- Clamp Scroll Position
    ---------------------------------------------------

    local current =
        self.scrollFrame:GetVerticalScroll()

    local range =
        self.scrollFrame:GetVerticalScrollRange()

    if current > range then

        self.scrollFrame:SetVerticalScroll(
            range
        )

    end

    ---------------------------------------------------
    -- Delayed Icon Refresh
    ---------------------------------------------------

    C_Timer.After(0.5, function()
        self:RefreshIcons()
    end)
end

---------------------------------------------------
-- Refresh Icons
---------------------------------------------------

function view:RefreshIcons()
    for _, row in ipairs(self.rows) do
        if row.icon and row.icon.item then
            local icon = row.icon.item:GetIcon()
            if icon then
                LootCouncil.UI.Widgets.Icon:SetTexture(row.icon, icon)
            else
                -- If still nil, try again later
                C_Timer.After(0.5, function()
                    local retryIcon = row.icon.item:GetIcon()
                    if retryIcon then
                        LootCouncil.UI.Widgets.Icon:SetTexture(row.icon, retryIcon)
                    end
                end)
            end
        end
    end
end

---------------------------------------------------
-- Render in Custom Panel (for popup)
---------------------------------------------------

function view:RenderInPanel(panel)
    local oldPanel = self.panel
    local oldContent = self.content
    
    self.panel = panel
    self.content = panel
    
    -- Reset the rows table so Refresh rebuilds everything
    self.rows = {}
    
    self:Refresh()
    
    self.panel = oldPanel
    self.content = oldContent
end