LootCouncil.UI.TabManager = {}

local manager = LootCouncil.UI.TabManager

manager.tabs = {}
manager.initialized = false
manager.visible = true

---------------------------------------------------
-- Initialize
---------------------------------------------------

function manager:Initialize(parent)

    self.parent = parent
    self.initialized = true

end

---------------------------------------------------
-- Set Visible
---------------------------------------------------

function manager:SetVisible(visible)

    self.visible = visible

    if not self.initialized then
        return
    end

    self:Refresh()

end

---------------------------------------------------
-- Clear
---------------------------------------------------

function manager:Clear()

    for _, tab in ipairs(self.tabs) do

        tab:Hide()

    end

    self.tabs = {}

end

---------------------------------------------------
-- Add Tab
---------------------------------------------------

function manager:AddTab(text, index)

    local tab =
        LootCouncil.UI.Widgets:CreateTab(
            self.parent,
            {
                text = text
            }
        )

    local spacing =
        LootCouncil.Constants.UI.Tab.Spacing

    local tabWidth =
        tab:GetWidth()

    local parentWidth =
        self.parent:GetWidth()

    local previous =
        self.tabs[#self.tabs]

    if not previous then

        self.currentRow = 1

        tab:SetPoint(
            "TOPLEFT",
            self.parent,
            "TOPLEFT"
        )

    else

        local previousRight =
            previous:GetRight()

        local parentRight =
            self.parent:GetRight()

        if previousRight + spacing + tabWidth >
           parentRight then

            self.currentRow =
                self.currentRow + 1

            tab:SetPoint(
                "TOPLEFT",
                self.parent,
                "TOPLEFT",
                0,
                -(
                    (self.currentRow - 1) *
                    (tab:GetHeight() + spacing)
                )
            )

        else

            tab:SetPoint(
                "LEFT",
                previous,
                "RIGHT",
                spacing,
                0
            )

        end

    end

    tab:SetScript(
        "OnClick",
        function()

            LootCouncil.Session:SetSelectedIndex(
                index
            )

            manager:Refresh()

        end
    )

    table.insert(
        self.tabs,
        tab
    )

    return tab

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function manager:Refresh()

    self:Clear()

    if not self.initialized then
        return
    end

    if not self.visible then
        return
    end

    if not LootCouncil.Session:IsActive() then
        return
    end

    ---------------------------------------------------
    -- Voting Permission
    ---------------------------------------------------

    local playerName =
        UnitName("player")

    local items =
        LootCouncil.Session:GetItems()

    ---------------------------------------------------
    -- Find Valid Selected Item
    ---------------------------------------------------

    local selected =
        LootCouncil.Session:GetSelectedIndex()

    local selectedItem

    if selected then

        selectedItem =
            LootCouncil.Session:GetItem(
                selected
            )

    end

    if selectedItem and selectedItem:IsAwarded() then

        selected = nil

        ---------------------------------------------------
        -- Prefer Next Unawarded Item
        ---------------------------------------------------

        for index, item in ipairs(items) do

            if index > LootCouncil.Session:GetSelectedIndex()
            and not item:IsAwarded() then

                selected = index

                break

            end

        end

        ---------------------------------------------------
        -- Otherwise Find Any Unawarded Item
        ---------------------------------------------------

        if not selected then

            for index, item in ipairs(items) do

                if not item:IsAwarded() then

                    selected = index

                    break

                end

            end

        end

        LootCouncil.Session:SetSelectedIndex(
            selected
        )

    end

    ---------------------------------------------------
    -- Create Voting Tabs
    ---------------------------------------------------

    for index, item in ipairs(items) do

        if not item:IsAwarded() then

            local tabName =
                tostring(
                    item:GetNumber()
                ) ..
                ". " ..
                item:GetName()

            local tab =
                self:AddTab(
                    tabName,
                    index
                )

            tab:SetSelected(
                index == selected
            )

        end

    end

    ---------------------------------------------------
    -- Refresh Voting Workspace
    ---------------------------------------------------

    LootCouncil.UI.VotingTab:Refresh()

end