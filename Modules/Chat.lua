LootCouncil.Chat = {}

local module = LootCouncil.Chat

---------------------------------------------------
-- Whisper
---------------------------------------------------

function module:OnWhisper(sender, message)

    ---------------------------------------------------
    -- Ignore Addon Messages
    ---------------------------------------------------

    if string.find(message, "^LootCouncil:") then
        return
    end

    ---------------------------------------------------
    -- Permission
    ---------------------------------------------------
    
    if not LootCouncil.Session:CanAcceptResponses() then
        return
    end

    local result =
        LootCouncil.ResponseParser:ParseMessage(
            message
        )

    ---------------------------------------------------
    -- Ignore
    ---------------------------------------------------

    if result.status == "IGNORE" then
        return
    end

    local recorded = {}
    local updated = {}
    local unchanged = {}

    ---------------------------------------------------
    -- Process Responses
    ---------------------------------------------------

    for _, response in ipairs(result.responses) do

        local outcome =
            LootCouncil.Session:SubmitApplicantResponse(

                sender,

                response.itemIndex,

                response.response

            )

        local text =
            "#" ..
            response.itemIndex ..
            " " ..
            response.response

        if outcome == "RECORDED" then

            table.insert(recorded, text)

            LootCouncil:Print(
                sender ..
                " -> " ..
                text
            )

        elseif outcome == "CHANGED" then

            table.insert(updated, text)

            LootCouncil:Print(
                sender ..
                " updated " ..
                text
            )

        elseif outcome == "UNCHANGED" then

            table.insert(unchanged, text)

        else

            LootCouncil:Print(
                "Unable to record response from " ..
                sender
            )

        end

    end

    ---------------------------------------------------
    -- Build Confirmation
    ---------------------------------------------------

    local parts = {}

    if #recorded > 0 then

        table.insert(

            parts,

            "Response recorded: " ..
            table.concat(recorded, ", ")

        )

    end

    if #updated > 0 then

        table.insert(

            parts,

            "Response updated: " ..
            table.concat(updated, ", ")

        )

    end

    if #unchanged > 0 then

        table.insert(

            parts,

            "Response already set: " ..
            table.concat(unchanged, ", ")

        )

    end

    if result.invalidItems
    and #result.invalidItems > 0 then

        if #result.invalidItems == 1 then

            table.insert(

                parts,

                "Invalid response for item #" ..
                result.invalidItems[1] .. "."

            )

        else

            local items = {}

            for _, itemIndex in ipairs(
                result.invalidItems
            ) do

                table.insert(
                    items,
                    "#" .. itemIndex
                )

            end

            table.insert(

                parts,

                "Invalid responses for items " ..
                table.concat(items, ", ") .. "."

            )

        end

    end

    ---------------------------------------------------
    -- Whisper Confirmation
    ---------------------------------------------------

    if #parts > 0 then

        SendChatMessage(

            "LootCouncil: " ..
            table.concat(parts, ". "),

            "WHISPER",

            nil,

            sender

        )

    end

end