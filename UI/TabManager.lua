LootCouncil.UI.TabManager = {}

local manager = LootCouncil.UI.TabManager

manager.entries = {}
manager.initialized = false

---------------------------------------------------
-- Initialize
---------------------------------------------------

function manager:Initialize(parent)

    self.parent = parent
    self.initialized = true

end

---------------------------------------------------
-- Clear
---------------------------------------------------

function manager:Clear()

    for _, entry in ipairs(self.entries) do
        entry:Hide()
    end

    self.entries = {}

end

---------------------------------------------------
-- Add Item
---------------------------------------------------

function manager:AddItem(item, index)

    local text =
        tostring(item:GetNumber()) ..
        ". " ..
        tostring(item:GetName() or "Unknown Item")

    local entry =
        LootCouncil.UI.Widgets.ListItem:Create(
            self.parent,
            {
                width = 185,
                height = 22,
                text = text,
            }
        )

    local previous = self.entries[#self.entries]

    if previous then
        entry:SetPoint(
            "TOPLEFT",
            previous,
            "BOTTOMLEFT",
            0,
            -2
        )
    else
        entry:SetPoint(
            "TOPLEFT",
            self.parent,
            "TOPLEFT",
            0,
            0
        )
    end

    entry:SetScript("OnClick", function()

        LootCouncil.Session:SetSelectedIndex(
            item:GetNumber()
        )

        manager:Refresh()

    end)

    table.insert(self.entries, entry)

    return entry

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function manager:Refresh()

    self:Clear()

    if not self.initialized then
        return
    end

    if not LootCouncil.Session:IsActive() then
        return
    end

    ---------------------------------------------------
    -- Find Valid Selected Item
    ---------------------------------------------------

    local items =
        LootCouncil.Session:GetItems()

    local selected =
        LootCouncil.Session:GetSelectedIndex()

    local selectedItem

    if selected then
        selectedItem = LootCouncil.Session:GetItem(selected)
    end

    ---------------------------------------------------
    -- If Selected Was Awarded Or Removed, Pick Next
    ---------------------------------------------------

    if not selectedItem or selectedItem:IsAwarded() then

        selected = nil

        ---------------------------------------------------
        -- Prefer Next Unawarded Item
        ---------------------------------------------------

        local previousSelection =
            LootCouncil.Session:GetSelectedIndex()

        for index, item in ipairs(items) do
            if index > (previousSelection or 0)
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

        LootCouncil.Session:SetSelectedIndex(selected)

    end

    ---------------------------------------------------
    -- Build Item List
    ---------------------------------------------------

    for index, item in ipairs(items) do

        if not item:IsAwarded() then

            local entry =
                self:AddItem(item, index)

            entry:SetSelected(index == selected)

        end

    end

    ---------------------------------------------------
    -- Update Content Height
    ---------------------------------------------------

    local contentHeight =
        0

    for _, entry in ipairs(self.entries) do
        contentHeight = contentHeight + entry:GetHeight() + 2
    end

    self.parent:SetHeight(
        math.max(
            contentHeight,
            LootCouncil.UI.MainWindow.itemScroll:GetHeight()
        )
    )

    ---------------------------------------------------
    -- Refresh Voting Workspace
    ---------------------------------------------------

    LootCouncil.UI.VotingTab:Refresh()

end