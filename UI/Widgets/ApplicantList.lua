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

-- Create the dropdown menu frame once
local responseMenu = CreateFrame("Frame", "LootCouncilResponseMenu", UIParent, "UIDropDownMenuTemplate")

local function SortApplicants(applicants)

    local sorted = {}

    for i, applicant in ipairs(applicants) do

        sorted[i] = applicant

    end

    table.sort(

        sorted,

        function(a, b)

            local aResponse =
                a:GetResponse()

            local bResponse =
                b:GetResponse()

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

        end

    )

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
    Player    = { x = 26,  width = 160, header = "Player" },
    Equipped  = { x = 130, width = 90,  header = "Equipped" },
    Response  = { x = 190, width = 90,  header = "Response" },
    ItemLevel = { x = 260, width = 130, header = "iLvl" },
    Votes     = { x = 370, width = 120, header = "Votes" },
    Award     = { x = 450, width = 70,  header = "Award" },
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
        "Votes",
        "Award",
    }

    for _, column in ipairs(order) do

        local info = frame.columns[column]

        frame.header.cells[column] =
            LootCouncil.UI.Widgets:CreateLabel(frame, {

                font = "GameFontHighlight",
                fontSize = 13,
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

        -- Initialize cells table
        row.cells = {}

        ---------------------------------------------------
        -- Player Cell
        ---------------------------------------------------

        local playerCell =
            LootCouncil.UI.Widgets:CreateLabel(frame, {

                font = "GameFontHighlight",
                fontSize = 13,
                point = "TOPLEFT",
                relativeTo = previous,
                relativePoint = "BOTTOMLEFT",

                x = frame.columns.Player.x,
                x = 0,
                y = -6,

            })

        row.cells.Player = playerCell

        ---------------------------------------------------
        -- Class Icon
        ---------------------------------------------------

        row.classIcon = frame:CreateTexture(nil, "ARTWORK")
        row.classIcon:SetSize(16, 16)
        row.classIcon:SetPoint(
            "LEFT",
            playerCell,
            "LEFT",
            -20,
            0
        )
        row.classIcon:Hide()

        ---------------------------------------------------
        -- Equipped Icons
        ---------------------------------------------------

        row.icons = {}

        for iconIndex = 1, 2 do

            local icon =
                LootCouncil.UI.Widgets.Icon:Create(
                    frame,
                    20
                )

            icon:SetPoint(

                "LEFT",

                playerCell,

                "LEFT",

                frame.columns.Equipped.x -
                frame.columns.Player.x +
                ((iconIndex - 1) * 24),

                0

            )

            icon:Hide()

            row.icons[iconIndex] = icon

        end

        ---------------------------------------------------
        -- Text Cells
        ---------------------------------------------------

        local textColumns = {

            "Response",
            "ItemLevel",

        }

        for _, column in ipairs(textColumns) do

            row.cells[column] =
                LootCouncil.UI.Widgets:CreateLabel(frame, {

                    font = "GameFontHighlight",
                    fontSize = 13,
                    point = "TOPLEFT",

                    relativeTo = playerCell,
                    relativePoint = "TOPLEFT",

                    x = frame.columns[column].x -
                        frame.columns.Player.x,

                    y = 0,

                })

        end

        ---------------------------------------------------
        -- Vote Button
        ---------------------------------------------------

        row.cells.Vote =
            LootCouncil.UI.Widgets.Button:Create(

                frame,

                {

                    width = 50,
                    height = 18,
                    text = "Vote",

                }

            )

        row.cells.Vote:SetPoint(

            "LEFT",

            playerCell,

            "LEFT",

            frame.columns.Votes.x -
            frame.columns.Player.x,

            0

        )

        row.cells.Vote:Hide()

        ---------------------------------------------------
        -- Vote Count
        ---------------------------------------------------

        row.cells.Votes =
            LootCouncil.UI.Widgets:CreateLabel(frame, {

                font = "GameFontHighlight",
                fontSize = 13,
                point = "LEFT",
                relativeTo = row.cells.Vote,
                relativePoint = "RIGHT",

                x = 6,
                y = 0,

            })

        ---------------------------------------------------
        -- Vote Count Tooltip Target
        ---------------------------------------------------

        row.cells.VotesTooltip =
            CreateFrame(
                "Button",
                nil,
                frame
            )

        row.cells.VotesTooltip:SetWidth(30)
        row.cells.VotesTooltip:SetHeight(18)

        row.cells.VotesTooltip:SetPoint(

            "LEFT",

            row.cells.Votes,

            "LEFT",

            -3,
            0

        )

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
-- Refresh
---------------------------------------------------

function widget:Refresh(frame, applicants)

    applicants = SortApplicants(applicants or {})

    local item =
        LootCouncil.Session:GetSelectedItem()

    for i = 1, #frame.rows do

        local row = frame.rows[i]

        -- Safety check: skip rows that aren't properly initialized
        if row and row.cells then

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
                    LootCouncil.Constants.ClassColors[
                        string.upper(class)
                    ]

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
                -- Class Icon
                ---------------------------------------------------

                local classToken = string.upper(class)
                local coords = CLASS_ICON_TCOORDS
                    and CLASS_ICON_TCOORDS[classToken]

                if coords then
                    row.classIcon:SetTexture(
                        "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
                    )
                    row.classIcon:SetTexCoord(
                        coords[1],
                        coords[2],
                        coords[3],
                        coords[4]
                    )
                    row.classIcon:Show()
                else
                    row.classIcon:Hide()
                end

                -- Right-click button over the player name
                if not row.playerButton then
                    row.playerButton = LootCouncil.UI.Widgets.Button:Create(
                        frame,
                        {
                            width = 80,
                            height = 20,
                            text = "",
                        }
                    )
                    row.playerButton:SetPoint("TOPLEFT", row.cells.Player, "TOPLEFT", -2, 2)
                    row.playerButton:SetPoint("BOTTOMRIGHT", row.cells.Player, "BOTTOMRIGHT", 2, -2)
                    row.playerButton:SetAlpha(0)  -- Transparent
                    
                    -- Use OnMouseDown to detect right-click
                    row.playerButton:SetScript("OnMouseDown", function(button, mouseButton)
                        if mouseButton == "RightButton" then
                            if not LootCouncil.Session:IsCouncil(UnitName("player")) then
                                return
                            end
                            
                            if not row.applicant then
                                return
                            end
                            
                            local playerName = row.applicant:GetPlayer():GetName()
                            local item = LootCouncil.Session:GetSelectedItem()
                            if not item then
                                return
                            end
                            
                            local itemNumber = item:GetNumber()
                            
                            -- Create right-click menu using EasyMenu
                            local menuItems = {}
                            
                            local responses = {"BIS", "MS", "OS", "PASS", "DISENCHANT"}
                            for _, response in ipairs(responses) do
                                table.insert(menuItems, {
                                    text = response,
                                    func = function()
                                        LootCouncil.Session:SetPlayerResponse(playerName, itemNumber, response)
                                    end
                                })
                            end
                            
                            -- Add a separator and cancel option
                            table.insert(menuItems, {
                                text = "Cancel",
                                func = function() end
                            })
                            
                            -- Show the dropdown menu at cursor position
                            EasyMenu(menuItems, LootCouncilResponseMenu, "cursor", 0, 0, "MENU")
                        end
                    end)
                end

                ---------------------------------------------------
                -- Equipped Icons
                ---------------------------------------------------

                local comparisonSlots = {}

                if item then

                    comparisonSlots =
                        LootCouncil.Comparison:GetComparisonSlots(
                            item
                        )

                end

                for iconIndex = 1, 2 do

                    local icon =
                        row.icons[iconIndex]

                    local slotID =
                        comparisonSlots[iconIndex]

                    if slotID then

                        local iconTexture =
                            row.applicant:GetEquippedIconForSlot(
                                slotID
                            )

                        local iconLink =
                            row.applicant:GetEquippedLinkForSlot(
                                slotID
                            )

                        if iconTexture then

                            LootCouncil.UI.Widgets.Icon:SetTexture(
                                icon,
                                iconTexture
                            )

                            LootCouncil.UI.Widgets.Icon:SetItem(
                                icon,
                                iconLink
                            )

                            icon:Show()

                        else

                            LootCouncil.UI.Widgets.Icon:SetTexture(
                                icon,
                                nil
                            )

                            LootCouncil.UI.Widgets.Icon:SetItem(
                                icon,
                                nil
                            )

                            icon:Hide()

                        end

                    else

                        LootCouncil.UI.Widgets.Icon:SetTexture(
                            icon,
                            nil
                        )

                        LootCouncil.UI.Widgets.Icon:SetItem(
                            icon,
                            nil
                        )

                        icon:Hide()

                    end

                end

                ---------------------------------------------------
                -- Response
                ---------------------------------------------------

                local response = row.applicant:GetResponse()
                row.cells.Response:SetText(response)

                -- Color coding
                if response == "BIS" then
                    row.cells.Response:SetTextColor(0.2, 1, 0.2)
                elseif response == "MS" then
                    row.cells.Response:SetTextColor(0.3, 0.5, 1)
                elseif response == "OS" then
                    row.cells.Response:SetTextColor(1, 0.6, 0.1)
                elseif response == "PENDING" then
                    row.cells.Response:SetTextColor(1, 1, 1)
                elseif response == "PASS" or response == "AUTO_PASS" then
                    row.cells.Response:SetTextColor(0.5, 0.5, 0.5)
                else
                    row.cells.Response:SetTextColor(1, 1, 1)
                end

                ---------------------------------------------------
                -- Item Level
                ---------------------------------------------------

                row.cells.ItemLevel:SetText(
                    row.applicant:GetItemLevelComparison()
                )

                ---------------------------------------------------
                -- Vote
                ---------------------------------------------------

                local councilMember =
                    UnitName("player")

                local hasVoted = false

                for _, voter in ipairs(
                    row.applicant:GetVotes()
                ) do

                    if voter == councilMember then

                        hasVoted = true
                        break

                    end

                end

                if hasVoted then

                    row.cells.Vote:SetText(
                        "Voted"
                    )

                else

                    row.cells.Vote:SetText(
                        "Vote"
                    )

                end

                ---------------------------------------------------
                -- Vote Count
                ---------------------------------------------------

                row.cells.Votes:SetText(
                    tostring(
                        row.applicant:GetVoteCount()
                    )
                )

                ---------------------------------------------------
                -- Vote Tooltip
                ---------------------------------------------------

                row.cells.VotesTooltip:SetScript(

                    "OnEnter",

                    function()

                        local votes =
                            row.applicant:GetVotes()

                        if #votes == 0 then
                            return
                        end

                        GameTooltip:SetOwner(

                            row.cells.VotesTooltip,

                            "ANCHOR_RIGHT"

                        )

                        GameTooltip:SetText(
                            "Votes"
                        )

                        for _, voter in ipairs(votes) do

                            GameTooltip:AddLine(
                                voter
                            )

                        end

                        GameTooltip:Show()

                    end

                )

                row.cells.VotesTooltip:SetScript(

                    "OnLeave",

                    function()

                        GameTooltip:Hide()

                    end

                )

                row.cells.Vote:Show()

                ---------------------------------------------------
                -- Vote Button
                ---------------------------------------------------

                row.cells.Vote:SetScript(

                    "OnClick",

                    function()

                        if not item or not row.applicant then
                            return
                        end

                        LootCouncil.Session:ToggleVote(

                            UnitName("player"),

                            row.applicant:GetPlayer():GetName(),

                            item:GetNumber()

                        )

                    end

                )

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

                        if not item or not row.applicant then
                            return
                        end

                        local playerName =
                            row.applicant:GetPlayer():GetName()

                        local response =
                            row.applicant:GetResponse()

                        local itemLink =
                            item:GetLink()

                        ---------------------------------------------------
                        -- Confirmation
                        ---------------------------------------------------

                        StaticPopupDialogs[
                            "LOOTCOUNCIL_CONFIRM_AWARD"
                        ] = {

                            text =
                                "Award " ..
                                itemLink ..
                                " to " ..
                                playerName ..
                                " for " ..
                                response ..
                                "?",

                            button1 = "Award",

                            button2 = "Cancel",

                            OnAccept = function()

                                LootCouncil.Session:SubmitAward(
                                    playerName,
                                    item:GetNumber()
                                )

                            end,

                            timeout = 0,

                            whileDead = true,

                            hideOnEscape = true,

                            preferredIndex = 3,

                        }

                        StaticPopup_Show(
                            "LOOTCOUNCIL_CONFIRM_AWARD"
                        )

                    end
                )

            else

                ---------------------------------------------------
                -- Clear Icons
                ---------------------------------------------------

                for iconIndex = 1, 2 do

                    local icon =
                        row.icons[iconIndex]

                    LootCouncil.UI.Widgets.Icon:SetTexture(
                        icon,
                        nil
                    )

                    LootCouncil.UI.Widgets.Icon:SetItem(
                        icon,
                        nil
                    )

                    icon:Hide()

                end

                ---------------------------------------------------
                -- Clear Text
                ---------------------------------------------------

                for key, cell in pairs(row.cells) do

                    if key ~= "Award" and
                       key ~= "Vote" then

                        cell:SetText("")

                    end

                end

                row.classIcon:Hide()

                ---------------------------------------------------
                -- Clear Vote Tooltip
                ---------------------------------------------------

                row.cells.VotesTooltip:SetScript(
                    "OnEnter",
                    nil
                )

                row.cells.VotesTooltip:SetScript(
                    "OnLeave",
                    nil
                )

                ---------------------------------------------------
                -- Hide Buttons
                ---------------------------------------------------

                row.cells.Vote:Hide()

                row.cells.Award:Hide()

            end

        else
            -- Row not initialized, skip it
            if row then
                row.applicant = nil
            end
        end

    end

end

---------------------------------------------------
-- Clear
---------------------------------------------------

function widget:Clear(frame)

    for i = 1, #frame.rows do

        local row = frame.rows[i]

        -- Safety check
        if not row or not row.icons then
            return
        end

        for iconIndex = 1, 2 do

            local icon = row.icons[iconIndex]

            if icon then
                LootCouncil.UI.Widgets.Icon:SetTexture(
                    icon,
                    nil
                )

                LootCouncil.UI.Widgets.Icon:SetItem(
                    icon,
                    nil
                )

                icon:Hide()
            end

        end

        -- Clear text cells
        if row.cells then
            for key, cell in pairs(row.cells) do
                if key ~= "Award" and key ~= "Vote" then
                    if cell and cell.SetText then
                        cell:SetText("")
                    end
                end
            end
        end

        -- Hide buttons
        if row.cells then
            if row.cells.Vote then
                row.cells.Vote:Hide()
            end
            if row.cells.Award then
                row.cells.Award:Hide()
            end
        end

        -- Clear vote tooltip
        if row.cells and row.cells.VotesTooltip then
            row.cells.VotesTooltip:SetScript("OnEnter", nil)
            row.cells.VotesTooltip:SetScript("OnLeave", nil)
        end

        row.applicant = nil

    end

end