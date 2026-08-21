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

    self.title = LootCouncil.UI.Widgets:CreateLabel(self.panel, {

        font = "GameFontNormalLarge",

        point = "TOPLEFT",
        relativeTo = self.icon,
        relativePoint = "TOPRIGHT",

        x = 10,
        y = 0,

    })

    self.itemLevel = LootCouncil.UI.Widgets:CreateLabel(self.panel, {

        point = "TOPLEFT",
        relativeTo = self.title,
        relativePoint = "BOTTOMLEFT",

        x = 0,
        y = -4,

    })

    self.applicants = LootCouncil.UI.Widgets:CreateLabel(self.panel, {

        point = "TOPLEFT",
        relativeTo = self.itemLevel,
        relativePoint = "BOTTOMLEFT",

        x = 0,
        y = -4,

    })

    self.awarded = LootCouncil.UI.Widgets:CreateLabel(self.panel, {

        point = "LEFT",
        relativeTo = self.applicants,
        relativePoint = "RIGHT",

        x = 30,
        y = 0,

    })

    ---------------------------------------------------
    -- Applicant Scroll Frame
    ---------------------------------------------------

    self.applicantScroll =
        LootCouncil.UI.Widgets.ScrollFrame:Create(
            self.panel
        )

    self.applicantScroll:SetPoint(
        "TOPLEFT",
        self.icon,
        "BOTTOMLEFT",
        0,
        -20
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
        self.awarded:SetText("")

        ---------------------------------------------------
        -- Clear Applicant List
        ---------------------------------------------------

        LootCouncil.UI.Widgets.ApplicantList:Clear(
            self.applicantList
        )

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

    if item:IsAwarded() then

        self.awarded:SetText(
            "Awarded: " ..
            tostring(item:GetWinner())
        )

    else

        self.awarded:SetText(
            "Awarded: None"
        )

    end

    ---------------------------------------------------
    -- Update Applicant List
    ---------------------------------------------------

    LootCouncil.UI.Widgets.ApplicantList:Refresh(
        self.applicantList,
        item:GetApplicants()
    )

end