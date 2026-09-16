LootCouncil.UI.Widgets.SessionInfoBox = {}

local widget = LootCouncil.UI.Widgets.SessionInfoBox

---------------------------------------------------
-- Duration Formatting
---------------------------------------------------

local function FormatDuration(seconds)

    if not seconds or seconds < 0 then
        seconds = 0
    end

    local hours =
        math.floor(seconds / 3600)

    local minutes =
        math.floor((seconds % 3600) / 60)

    local secs =
        math.floor(seconds % 60)

    return string.format(
        "%02d:%02d:%02d",
        hours,
        minutes,
        secs
    )

end

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local theme = LootCouncil.Constants.Theme

    ---------------------------------------------------
    -- Frame
    ---------------------------------------------------

    local box = CreateFrame("Frame", nil, parent)

    box:SetSize(
        options.width or 200,
        options.height or 130
    )

    box:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = theme.BorderSize,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })

    box:SetBackdropColor(
        theme.PanelBackground[1],
        theme.PanelBackground[2],
        theme.PanelBackground[3],
        theme.PanelBackground[4]
    )

    box:SetBackdropBorderColor(
        theme.BorderColor[1],
        theme.BorderColor[2],
        theme.BorderColor[3],
        theme.BorderColor[4]
    )

    ---------------------------------------------------
    -- Line 1 - Session ID and Duration
    ---------------------------------------------------

    local line1 =
        box:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    line1:SetPoint("TOPLEFT", box, "TOPLEFT", 10, -10)
    line1:SetJustifyH("LEFT")
    line1:SetText("No active session")

    box.Line1 = line1

    ---------------------------------------------------
    -- Line 2 - Owner and Item Count
    ---------------------------------------------------

    local line2 =
        box:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    line2:SetPoint("TOPLEFT", line1, "BOTTOMLEFT", 0, -6)
    line2:SetJustifyH("LEFT")
    line2:SetText("")

    box.Line2 = line2

    ---------------------------------------------------
    -- Line 3 - Council and Player Count
    ---------------------------------------------------

    local line3 =
        box:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    line3:SetPoint("TOPLEFT", line2, "BOTTOMLEFT", 0, -6)
    line3:SetJustifyH("LEFT")
    line3:SetText("")

    box.Line3 = line3

    ---------------------------------------------------
    -- Ticker State
    ---------------------------------------------------

    box.lastTick = 0

    ---------------------------------------------------
    -- Refresh
    ---------------------------------------------------

    function box:Refresh()

        ---------------------------------------------------
        -- No Session
        ---------------------------------------------------

        if not LootCouncil.Session:IsActive() then

            self.Line1:SetText("No active session")
            self.Line2:SetText("")
            self.Line3:SetText("")

            return

        end

        ---------------------------------------------------
        -- Session State
        ---------------------------------------------------

        local session = LootCouncil.Session:Get()

        if not session then
            return
        end

        local id =
            LootCouncil.Session:GetID() or "???"

        local started =
            session.started or time()

        local duration =
            FormatDuration(time() - started)

        local owner =
            LootCouncil.Session:GetOwner() or "Unknown"

        local itemCount =
            #LootCouncil.Session:GetItems()

        local councilCount =
            #LootCouncil.Session:GetCouncilMembers()

        local playerCount =
            #LootCouncil.Session:GetPlayers()

        ---------------------------------------------------
        -- Line 1
        ---------------------------------------------------

        self.Line1:SetText(
            "Session " .. id ..
            " - " .. duration
        )

        ---------------------------------------------------
        -- Line 2
        ---------------------------------------------------

        self.Line2:SetText(
            "Owner: " .. owner ..
            " - " .. itemCount .. " items"
        )

        ---------------------------------------------------
        -- Line 3
        ---------------------------------------------------

        self.Line3:SetText(
            "Council: " .. councilCount ..
            " - Players: " .. playerCount
        )

    end

    ---------------------------------------------------
    -- OnUpdate Ticker
    ---------------------------------------------------

    box:SetScript("OnUpdate", function(self, elapsed)

        if not LootCouncil.Session:IsActive() then
            return
        end

        self.lastTick = self.lastTick + elapsed

        if self.lastTick < 1 then
            return
        end

        self.lastTick = 0

        self:Refresh()

    end)

    ---------------------------------------------------
    -- Initial State
    ---------------------------------------------------

    box:Refresh()

    return box

end

---------------------------------------------------
-- Update Theme
---------------------------------------------------

function widget:UpdateTheme(box)

    if not box then
        return
    end

    local theme = LootCouncil.Constants.Theme

    box:SetBackdropColor(
        theme.PanelBackground[1],
        theme.PanelBackground[2],
        theme.PanelBackground[3],
        theme.PanelBackground[4]
    )

    box:SetBackdropBorderColor(
        theme.BorderColor[1],
        theme.BorderColor[2],
        theme.BorderColor[3],
        theme.BorderColor[4]
    )

end