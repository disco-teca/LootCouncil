LootCouncil.UI.VotingTab = {}

local view = LootCouncil.UI.VotingTab

view.initialized = false

---------------------------------------------------
-- Initialize
---------------------------------------------------

function view:Initialize()

    if self.initialized then
        return
    end

    self.panel =
        LootCouncil.UI.MainWindow.votingPanel

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
    -- Item Icon
    ---------------------------------------------------

    self.icon =
        LootCouncil.UI.Widgets.Icon:Create(
            self.panel,
            40
        )

    self.icon:SetPoint(
        "TOPLEFT",
        self.panel,
        "TOPLEFT",
        15,
        -15
    )

    ---------------------------------------------------
    -- Item Information
    ---------------------------------------------------

    self.title =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                font = "GameFontNormalLarge",

                point = "TOPLEFT",
                relativeTo = self.icon,
                relativePoint = "TOPRIGHT",

                x = 10,
                y = 0,
            }
        )

    self.itemLevel =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.title,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -4,
            }
        )

    self.applicants =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.itemLevel,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -4,
            }
        )

    ---------------------------------------------------
    -- Your Response
    ---------------------------------------------------

    self.response =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "TOPLEFT",
                relativeTo = self.applicants,
                relativePoint = "BOTTOMLEFT",

                x = 0,
                y = -4,

                text = "Your Response: None"
            }
        )

    ---------------------------------------------------
    -- Awarded
    ---------------------------------------------------

    self.awarded =
        LootCouncil.UI.Widgets:CreateLabel(
            self.panel,
            {
                point = "LEFT",
                relativeTo = self.response,
                relativePoint = "RIGHT",

                x = 30,
                y = 0,
            }
        )

    ---------------------------------------------------
    -- Pass Toggle Button
    ---------------------------------------------------

    self.passToggle = LootCouncil.UI.Widgets.Button:Create(
        self.panel,
        {
            width = 100,
            height = 22,
            text = "Show Pass",
        }
    )
    self.passToggle:SetPoint("TOPRIGHT", self.panel, "TOPRIGHT", -15, -60)
    self.passToggle:SetScript("OnClick", function()
        self:TogglePassVisibility()
    end)
    self.passToggle:Hide()  -- Hidden by default

    ---------------------------------------------------
    -- Applicant Scroll Frame
    ---------------------------------------------------

    self.applicantScroll =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.panel
        )

    self.applicantScroll:SetPoint(
        "TOPLEFT",
        self.response,
        "BOTTOMLEFT",
        -50,
        -15
    )

    self.applicantScroll:SetPoint(
        "BOTTOMRIGHT",
        self.panel,
        "BOTTOMRIGHT",
        -30,
        10
    )

    ---------------------------------------------------
    -- Applicant List
    ---------------------------------------------------

    self.applicantList =
        LootCouncil.UI.Widgets.ApplicantList:Create(
            self.applicantScroll.content
        )

    self.applicantList:SetPoint(
        "TOPLEFT",
        self.applicantScroll.content,
        "TOPLEFT",
        0,
        0
    )

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function view:Refresh()

    self:Initialize()

    if not self.initialized then
        return
    end

    local item =
        LootCouncil.Session:GetSelectedItem()

    if not item then

        ---------------------------------------------------
        -- Clear Item Information
        ---------------------------------------------------

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

        self.itemLevel:SetText("")

        ---------------------------------------------------
        -- Clear Item Summary
        ---------------------------------------------------

        self.applicants:SetText("")

        self.response:SetText(
            "Your Response: None"
        )

        self.awarded:SetText("")

        ---------------------------------------------------
        -- Clear Applicant List
        ---------------------------------------------------

        LootCouncil.UI.Widgets.ApplicantList:Clear(
            self.applicantList
        )

        -- Hide pass toggle
        self.passToggle:Hide()

        return

    end

    ---------------------------------------------------
    -- Update Item Information
    ---------------------------------------------------

    LootCouncil.UI.Widgets.Icon:SetTexture(
        self.icon,
        item:GetIcon()
    )

    LootCouncil.UI.Widgets.Icon:SetItem(
        self.icon,
        item:GetLink()
    )

    self.title:SetText(
        item:GetName()
    )

    self.itemLevel:SetText(
        "Item Level: " ..
        item:GetItemLevel()
    )

    ---------------------------------------------------
    -- Update Item Summary
    ---------------------------------------------------

    self.applicants:SetText(
        "Applicants: " ..
        item:GetApplicantCount()
    )

    ---------------------------------------------------
    -- Your Response
    ---------------------------------------------------

    local applicant =
        item:FindApplicant(
            UnitName("player")
        )

    if applicant then

        self.response:SetText(
            "Your Response: " ..
            applicant:GetResponse()
        )

    else

        self.response:SetText(
            "Your Response: None"
        )

    end

    ---------------------------------------------------
    -- Awarded
    ---------------------------------------------------

    if item:IsAwarded() then

        self.awarded:SetText(
            "Awarded: " ..
            tostring(
                item:GetWinner()
            )
        )

    else

        self.awarded:SetText(
            "Awarded: None"
        )

    end

    ---------------------------------------------------
    -- Update Applicant List
    ---------------------------------------------------

    local applicants = item:GetApplicants()
    local itemNumber = item:GetNumber()

    -- Check if pass responses should be hidden
    local hidePass = false
    local sessionData = LootCouncil.Session:Get()
    if sessionData and sessionData._passVisibility and sessionData._passVisibility[itemNumber] == true then
        hidePass = true
    else
    end

    if hidePass then
        local filteredApplicants = {}
        for _, applicant in ipairs(applicants) do
            local response = applicant:GetResponse()
            local upperResponse = string.upper(response)
            if upperResponse ~= "PASS" and upperResponse ~= "AUTO_PASS" and upperResponse ~= "AUTO_PASS" then
                table.insert(filteredApplicants, applicant)
            end
        end
        applicants = filteredApplicants
    end

    LootCouncil.UI.Widgets.ApplicantList:Refresh(
        self.applicantList,
        applicants
    )

end

---------------------------------------------------
-- Update Timer Display
---------------------------------------------------

function view:UpdateTimer(remaining)
    if self.timerButton then
        if remaining and remaining > 0 then
            self.timerButton:SetText("⏱ " .. remaining .. "s remaining")
        else
            self.timerButton:SetText("Start 15s Timer")
        end
    end
end

---------------------------------------------------
-- Update Winner Display
---------------------------------------------------

function view:UpdateWinner(winnerName)
    if self.winnerLabel then
        if winnerName then
            self.winnerLabel:SetText("Winner: " .. winnerName)
        else
            self.winnerLabel:SetText("Winner: —")
        end
    end
end

---------------------------------------------------
-- Toggle Pass Visibility
---------------------------------------------------

function view:TogglePassVisibility()
    
    local item = LootCouncil.Session:GetSelectedItem()
    if not item then
        return
    end

    local itemNumber = item:GetNumber()
    
    local sessionData = LootCouncil.Session:Get()
    if not sessionData then
        return
    end

    if not sessionData._passVisibility then
        sessionData._passVisibility = {}
    end

    local currentState = sessionData._passVisibility[itemNumber] or false
    
    sessionData._passVisibility[itemNumber] = not currentState

    if sessionData._passVisibility[itemNumber] then
        self.passToggle:SetText("Show Pass")
    else
        self.passToggle:SetText("Hide Pass")
    end

    self:Refresh()
end