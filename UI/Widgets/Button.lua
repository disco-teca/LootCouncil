LootCouncil.UI.Widgets.Button = {}

local widget = LootCouncil.UI.Widgets.Button

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent, options)

    options = options or {}

    local theme = LootCouncil.Constants.Theme

    ---------------------------------------------------
    -- Button Frame
    ---------------------------------------------------

    local button = CreateFrame("Button", nil, parent)

    button:SetWidth(options.width or 60)
    button:SetHeight(options.height or 20)

    ---------------------------------------------------
    -- Background
    ---------------------------------------------------

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetTexture(
        theme.TabBackground[1],
        theme.TabBackground[2],
        theme.TabBackground[3],
        theme.TabBackground[4]
    )

    button.Background = background

    ---------------------------------------------------
    -- Border
    ---------------------------------------------------

    local border = CreateFrame("Frame", nil, button)
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = theme.BorderSize,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    border:SetBackdropBorderColor(
        theme.BorderColor[1],
        theme.BorderColor[2],
        theme.BorderColor[3],
        theme.BorderColor[4]
    )

    button.Border = border

    ---------------------------------------------------
    -- Text
    ---------------------------------------------------

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(options.text or "")
    text:SetTextColor(
        theme.TextPrimary[1],
        theme.TextPrimary[2],
        theme.TextPrimary[3],
        theme.TextPrimary[4]
    )

    button.Text = text

    ---------------------------------------------------
    -- Hover
    ---------------------------------------------------

    button:SetScript("OnEnter", function()
        if not button:IsEnabled() then
            return
        end
        background:SetTexture(
            theme.TabSelected[1],
            theme.TabSelected[2],
            theme.TabSelected[3],
            theme.TabSelected[4]
        )
    end)

    button:SetScript("OnLeave", function()
        if not button:IsEnabled() then
            return
        end
        background:SetTexture(
            theme.TabBackground[1],
            theme.TabBackground[2],
            theme.TabBackground[3],
            theme.TabBackground[4]
        )
    end)

    ---------------------------------------------------
    -- Disabled State
    ---------------------------------------------------

    button:SetScript("OnDisable", function()
        background:SetTexture(
            theme.TextDisabled[1],
            theme.TextDisabled[2],
            theme.TextDisabled[3],
            theme.TextDisabled[4]
        )
        text:SetTextColor(
            theme.TextDisabled[1],
            theme.TextDisabled[2],
            theme.TextDisabled[3],
            theme.TextDisabled[4]
        )
    end)

    button:SetScript("OnEnable", function()
        background:SetTexture(
            theme.TabBackground[1],
            theme.TabBackground[2],
            theme.TabBackground[3],
            theme.TabBackground[4]
        )
        text:SetTextColor(
            theme.TextPrimary[1],
            theme.TextPrimary[2],
            theme.TextPrimary[3],
            theme.TextPrimary[4]
        )
    end)

    ---------------------------------------------------
    -- Click
    ---------------------------------------------------

    if options.onClick then
        button:SetScript("OnClick", options.onClick)
    end

        -- Hook SetText so direct calls work
    button.SetText = function(self, text)
        widget:SetText(self, text)
    end

    return button
end

---------------------------------------------------
-- Set Text
---------------------------------------------------

function widget:SetText(button, text)
    if button.Text then
        button.Text:SetText(text or "")
    end
end

---------------------------------------------------
-- Enable
---------------------------------------------------

function widget:Enable(button)
    button:Enable()
end

---------------------------------------------------
-- Disable
---------------------------------------------------

function widget:Disable(button)
    button:Disable()
end

---------------------------------------------------
-- Set Text (Direct)
---------------------------------------------------

function widget:SetText(button, text)
    if button.Text then
        button.Text:SetText(text or "")
    end
end

---------------------------------------------------
-- Hook SetText for Direct Calls
---------------------------------------------------

local function HookButtonText(button)
    button.SetText = function(self, text)
        widget:SetText(self, text)
    end
end