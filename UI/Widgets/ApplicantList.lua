LootCouncil.UI.Widgets.ApplicantList = {}

local widget = LootCouncil.UI.Widgets.ApplicantList

---------------------------------------------------
-- Sorting
---------------------------------------------------

local responseOrder = {

    [LootCouncil.Constants.Response.BIS] = 1,
    [LootCouncil.Constants.Response.MS] = 2,
    [LootCouncil.Constants.Response.OS] = 3,
    [LootCouncil.Constants.Response.PASS] = 4,
    [LootCouncil.Constants.Response.PENDING] = 5,
    [LootCouncil.Constants.Response.AUTO_PASS] = 6,

}

local function SortApplicants(applicants)

    local sorted = {}

    for i, applicant in ipairs(applicants) do
        sorted[i] = applicant
    end

    table.sort(sorted, function(a, b)

        local aResponse

            if a:IsAutoPassed() then

                aResponse =
                    LootCouncil.Constants.Response.AUTO_PASS

            else

                aResponse =
                    a:GetResponse()

            end

            local bResponse

            if b:IsAutoPassed() then

                bResponse =
                    LootCouncil.Constants.Response.AUTO_PASS

            else

                bResponse =
                    b:GetResponse()

            end

            local aOrder =
                responseOrder[aResponse] or 99

            local bOrder =
                responseOrder[bResponse] or 99

        ---------------------------------------------------
        -- Response
        ---------------------------------------------------

        if aOrder ~= bOrder then

            return aOrder < bOrder

        end

        ---------------------------------------------------
        -- Online Status
        ---------------------------------------------------

        if aOrder >= 5 then

            local aOnline =
                a:GetPlayer():IsOnline()

            local bOnline =
                b:GetPlayer():IsOnline()

            if aOnline ~= bOnline then

                return aOnline

            end

        end

        ---------------------------------------------------
        -- Class
        ---------------------------------------------------

        local aClass =
            a:GetPlayer():GetClass()

        local bClass =
            b:GetPlayer():GetClass()

        local aClassOrder =
            LootCouncil.Constants.ClassOrder[aClass]
            or 99

        local bClassOrder =
            LootCouncil.Constants.ClassOrder[bClass]
            or 99

        if aClassOrder ~= bClassOrder then

            return aClassOrder < bClassOrder

        end

        ---------------------------------------------------
        -- Player Name
        ---------------------------------------------------

        return a:GetPlayer():GetName() <
               b:GetPlayer():GetName()

    end)

    return sorted

end

---------------------------------------------------
-- Create
---------------------------------------------------

function widget:Create(parent)

    local frame = CreateFrame("Frame", nil, parent)

    frame:SetWidth(900)
    frame:SetHeight(1200)

    ---------------------------------------------------
    -- Columns
    ---------------------------------------------------

    frame.columns = {

        Player = {
            x = 0,
            width = 180,
            header = "Player",
        },

        Equipped = {
            x = 190,
            width = 90,
            header = "Equipped",
        },

        Response = {
            x = 290,
            width = 90,
            header = "Response",
        },

        ItemLevel = {
            x = 390,
            width = 110,
            header = "iLvl",
        },

        BiS = {
            x = 510,
            width = 50,
            header = "BiS",
        },

        Votes = {
            x = 570,
            width = 120,
            header = "Votes",
        },

        Award = {
            x = 700,
            width = 70,
            header = "Award",
        },

    }

    ---------------------------------------------------
    -- Header
    ---------------------------------------------------

    frame.header = {}
    frame.header.cells = {}

    local order = {
        "Player",
        "Equipped",
        "Response",
        "ItemLevel",
        "BiS",
        "Votes",
        "Award",
    }

    for _, column in ipairs(order) do

        local info = frame.columns[column]

        frame.header.cells[column] =
            LootCouncil.UI.Widgets:CreateLabel(frame, {

                font = "GameFontNormal",

                point = "TOPLEFT",
                relativeTo = frame,
                relativePoint = "TOPLEFT",

                x = info.x,
                y = 0,

                text = info.header,

            })

    end

    ---------------------------------------------------
    -- Rows
    ---------------------------------------------------

    frame.rows = {}

    local previous = frame.header.cells.Player

    for i = 1, 40 do

        local row = {}

        ---------------------------------------------------
        -- State
        ---------------------------------------------------

        row.applicant = nil
        row.selected = false
        row.highlighted = false

        ---------------------------------------------------
        -- Player Cell
        ---------------------------------------------------

        local playerCell =
            LootCouncil.UI.Widgets:CreateLabel(frame, {

                point = "TOPLEFT",

                relativeTo = previous,
                relativePoint = "BOTTOMLEFT",

                x = frame.columns.Player.x,
                y = -6,

            })

        ---------------------------------------------------
        -- Equipped Icon
        ---------------------------------------------------

        row.icon =
            LootCouncil.UI.Widgets.Icon:Create(
                frame,
                20
            )

        row.icon:SetPoint(

            "LEFT",

            playerCell,

            "LEFT",

            frame.columns.Equipped.x -
            frame.columns.Player.x,

            0

        )

        ---------------------------------------------------
        -- Text Cells
        ---------------------------------------------------

        row.cells = {}

        row.cells.Player = playerCell

        local textColumns = {

            "Response",
            "ItemLevel",
            "BiS",
            "Votes",

        }

        for _, column in ipairs(textColumns) do

            row.cells[column] =
                LootCouncil.UI.Widgets:CreateLabel(frame, {

                    point = "TOPLEFT",

                    relativeTo = playerCell,
                    relativePoint = "TOPLEFT",

                    x = frame.columns[column].x -
                        frame.columns.Player.x,

                    y = 0,

                })

        end

        ---------------------------------------------------
        -- Award Button
        ---------------------------------------------------

        row.cells.Award =
            LootCouncil.UI.Widgets.Button:Create(

                frame,

                {

                    width = 60,
                    height = 18,
                    text = "Award",

                }

            )

        row.cells.Award:SetPoint(

            "LEFT",

            playerCell,

            "LEFT",

            frame.columns.Award.x -
            frame.columns.Player.x,

            0

        )

        frame.rows[i] = row

        previous = playerCell

    end

    return frame

end

---------------------------------------------------
-- Layout
---------------------------------------------------

function widget:Layout(frame, ...)

    frame:SetPoint(...)

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function widget:Refresh(frame, applicants)

    applicants = SortApplicants(applicants or {})

    local item =
        LootCouncil.Session:GetSelectedItem()

    for i = 1, #frame.rows do

        local row = frame.rows[i]

        row.applicant = applicants[i]

        if row.applicant then

            ---------------------------------------------------
            -- Player
            ---------------------------------------------------

            local player =
                row.applicant:GetPlayer()

            local class =
                player:GetClass()

            local color =
                LootCouncil.Constants.ClassColors[class]

            if color then

                row.cells.Player:SetTextColor(
                    color[1],
                    color[2],
                    color[3]
                )

            else

                row.cells.Player:SetTextColor(
                    1,
                    1,
                    1
                )

            end

            row.cells.Player:SetText(
                player:GetName()
            )

            ---------------------------------------------------
            -- Equipped Icon
            ---------------------------------------------------

            LootCouncil.UI.Widgets.Icon:SetTexture(

                row.icon,

                row.applicant:GetEquippedIcon(item)

            )

            LootCouncil.UI.Widgets.Icon:SetItem(

                row.icon,

                row.applicant:GetEquippedLink(item)

            )

            ---------------------------------------------------
            -- Response
            ---------------------------------------------------

            row.cells.Response:SetText(
                row.applicant:GetResponse()
            )

            ---------------------------------------------------
            -- Item Level
            ---------------------------------------------------

            row.cells.ItemLevel:SetText(
                row.applicant:GetItemLevelComparison()
            )

            ---------------------------------------------------
            -- Placeholders
            ---------------------------------------------------

            row.cells.BiS:SetText("")
            row.cells.Votes:SetText("")

            ---------------------------------------------------
            -- Award Button
            ---------------------------------------------------

            if item and
               item:GetWinner() ==
               row.applicant:GetPlayer():GetName() then

                row.cells.Award:SetText(
                    "Awarded"
                )

            else

                row.cells.Award:SetText(
                    "Award"
                )

            end

            row.cells.Award:Show()

            row.cells.Award:SetScript(

                "OnClick",

                function()

                    if not item then
                        return
                    end

                    LootCouncil.Session:SubmitAward(

                        row.applicant:GetPlayer():GetName(),

                        LootCouncil.Session:GetSelectedIndex()

                    )

                end

            )

        else

            ---------------------------------------------------
            -- Clear Icon
            ---------------------------------------------------

            LootCouncil.UI.Widgets.Icon:SetTexture(

                row.icon,

                nil

            )

            LootCouncil.UI.Widgets.Icon:SetItem(

                row.icon,

                nil

            )

            ---------------------------------------------------
            -- Clear Text
            ---------------------------------------------------

            for key, cell in pairs(row.cells) do

                if key ~= "Award" then
                    cell:SetText("")
                end

            end

            ---------------------------------------------------
            -- Hide Award Button
            ---------------------------------------------------

            row.cells.Award:Hide()

        end

    end

end

---------------------------------------------------
-- Clear
---------------------------------------------------

function widget:Clear(frame)

    for i = 1, #frame.rows do

        local row = frame.rows[i]

        row.applicant = nil

        ---------------------------------------------------
        -- Clear Equipped Icon
        ---------------------------------------------------

        LootCouncil.UI.Widgets.Icon:SetTexture(

            row.icon,

            nil

        )

        LootCouncil.UI.Widgets.Icon:SetItem(

            row.icon,

            nil

        )

        ---------------------------------------------------
        -- Clear Text
        ---------------------------------------------------

        for key, cell in pairs(row.cells) do

            if key ~= "Award" then
                cell:SetText("")
            end

        end

        ---------------------------------------------------
        -- Hide Award Button
        ---------------------------------------------------

        row.cells.Award:Hide()

    end

end