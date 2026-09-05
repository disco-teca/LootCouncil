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
    -- Roll Controls (Right of item info, adjusted)
    ---------------------------------------------------

    -- Roll MS Button
    self.rollMSButton = LootCouncil.UI.Widgets.Button:Create(
        self.panel,
        {
            width = 70,
            height = 22,
            text = "Roll MS",
        }
    )
    self.rollMSButton:SetPoint("LEFT", self.applicants, "RIGHT", 150, 10)
    self.rollMSButton:SetScript("OnClick", function()
        local item = LootCouncil.Session:GetSelectedItem()
        if item then
            LootCouncil.Roll:StartRoll(item, "MS")
        end
    end)

    -- Roll OS Button
    self.rollOSButton = LootCouncil.UI.Widgets.Button:Create(
        self.panel,
        {
            width = 70,
            height = 22,
            text = "Roll OS",
        }
    )
    self.rollOSButton:SetPoint("LEFT", self.rollMSButton, "RIGHT", 5, 0)
    self.rollOSButton:SetScript("OnClick", function()
        local item = LootCouncil.Session:GetSelectedItem()
        if item then
            LootCouncil.Roll:StartRoll(item, "OS")
        end
    end)

    -- Timer Button (no icon)
    self.timerButton = LootCouncil.UI.Widgets.Button:Create(
        self.panel,
        {
            width = 100,
            height = 22,
            text = "Start 15s",
        }
    )
    self.timerButton:SetPoint("LEFT", self.rollOSButton, "RIGHT", 10, 0)
    self.timerButton:SetScript("OnClick", function()
        if not LootCouncil.Roll:IsActive() then
            return
        end
        
        local activeRoll = LootCouncil.Roll:GetActiveRoll()
        if activeRoll and activeRoll.timerStarted then
            LootCouncil.Roll:CloseRoll()
            self.timerButton:SetText("Start 15s")
        else
            LootCouncil.Roll:StartTimer()
            self.timerButton:SetText("15s")
        end
    end)

    -- Winner Label
    self.winnerLabel = LootCouncil.UI.Widgets:CreateLabel(
        self.panel,
        {
            point = "LEFT",
            relativeTo = self.timerButton,
            relativePoint = "RIGHT",
            x = 15,
            y = 0,
            text = "Winner: —",
        }
    )

    -- Hide roll controls initially (visibility handled in Refresh)
    self.rollMSButton:Hide()
    self.rollOSButton:Hide()
    self.timerButton:Hide()
    self.winnerLabel:Hide()
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
        -15,
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

        ---------------------------------------------------
        -- Hide Roll Controls
        ---------------------------------------------------

        self.rollMSButton:Hide()
        self.rollOSButton:Hide()
        self.timerButton:Hide()
        self.winnerLabel:Hide()

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
    -- Update Roll Controls Visibility
    ---------------------------------------------------

    local playerName = UnitName("player")
    local isCouncil = LootCouncil.Session:IsCouncil(playerName)
    local isAwarded = item:IsAwarded()

    if isCouncil and not isAwarded then
        self.rollMSButton:Show()
        self.rollOSButton:Show()
        self.timerButton:Show()
        self.winnerLabel:Show()
    else
        self.rollMSButton:Hide()
        self.rollOSButton:Hide()
        self.timerButton:Hide()
        self.winnerLabel:Hide()
    end

    -- Update timer and winner if a roll is active
    local activeRoll = LootCouncil.Roll:GetActiveRoll()
    if activeRoll then
        if activeRoll.isClosed then
            self:UpdateWinner(activeRoll.winner)
            self.timerButton:SetText("▶ Start 15s Timer")
        elseif activeRoll.timerStarted then
            -- Timer is running, button shows remaining time
            -- The timer update will be called from Roll:StartTimer
        end
    else
        self:UpdateWinner(nil)
        self.timerButton:SetText("▶ Start 15s Timer")
    end

    ---------------------------------------------------
    -- Update Applicant List
    ---------------------------------------------------

    LootCouncil.UI.Widgets.ApplicantList:Refresh(
        self.applicantList,
        item:GetApplicants()
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
            self.timerButton:SetText("▶ Start 15s Timer")
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