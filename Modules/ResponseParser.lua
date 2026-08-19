LootCouncil.ResponseParser = {}

local module = LootCouncil.ResponseParser

local Response =
    LootCouncil.Constants.Response

---------------------------------------------------
-- Response Aliases
---------------------------------------------------

local aliases = {

    ---------------------------------------------------
    -- Best in Slot
    ---------------------------------------------------

    bis = Response.BIS,

    bestinslot = Response.BIS,

    ["best in slot"] = Response.BIS,

    ---------------------------------------------------
    -- Main Spec
    ---------------------------------------------------

    ms = Response.MS,

    mainspec = Response.MS,

    ["main spec"] = Response.MS,

    ---------------------------------------------------
    -- Off Spec
    ---------------------------------------------------

    os = Response.OS,

    offspec = Response.OS,

    ["off spec"] = Response.OS,

    ---------------------------------------------------
    -- Pass
    ---------------------------------------------------

    pass = Response.PASS,

}

---------------------------------------------------
-- Normalize Response
---------------------------------------------------

function module:NormalizeResponse(response)

    if not response then
        return nil
    end

    response =
        string.lower(response)

    return aliases[response]

end

---------------------------------------------------
-- Parse Message
---------------------------------------------------

function module:ParseMessage(message)

    if not message then

        return {

            status = "IGNORE",

            responses = {},

        }

    end

    local responses = {}
    local invalidItems = {}

    ---------------------------------------------------
    -- Parse Responses
    ---------------------------------------------------

    for itemIndex, responseText in
        message:gmatch("#(%d+)%s+([^#]+)") do

        responseText =
            responseText:gsub("^%s+", "")
                        :gsub("%s+$", "")

        local response =
            self:NormalizeResponse(responseText)

        if response then

            table.insert(

                responses,

                {

                    itemIndex = tonumber(itemIndex),

                    response = response,

                }

            )

        else

            table.insert(

                invalidItems,

                tonumber(itemIndex)

            )

        end

    end

    ---------------------------------------------------
    -- No Responses Found
    ---------------------------------------------------

    if #responses == 0 and #invalidItems == 0 then

        return {

            status = "IGNORE",

            responses = {},

            invalidItems = {},

        }

    end

    ---------------------------------------------------
    -- Success
    ---------------------------------------------------

    for _, itemIndex in ipairs(invalidItems) do

        LootCouncil:Print(
            "Invalid item: #" .. itemIndex
        )

    end

    return {

        status = "SUCCESS",

        responses = responses,

        invalidItems = invalidItems,

    }

end