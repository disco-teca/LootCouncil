---------------------------------------------------
-- Local Variables
---------------------------------------------------

local commands = {}

---------------------------------------------------
-- Command Handlers
---------------------------------------------------

local function ToggleWindow()

    LootCouncil.UI:Toggle()

end

local function ToggleTest(arguments)

    arguments = string.lower(arguments or "")

    if arguments == "bus" then

        LootCouncil.TestMode:TestMessageBus()

        return

    end

    LootCouncil.TestMode:Toggle()

end

---------------------------------------------------
-- Start Session
---------------------------------------------------

local function StartSession()

    if LootCouncil.Session:IsActive() then

        LootCouncil:Print(

            "A session is already active."

        )

        return

    end

    ---------------------------------------------------
    -- Create Message
    ---------------------------------------------------

    local message =
        LootCouncil.Message:New(
            "START",
            {
                owner = UnitName("player"),
                roles = LootCouncil.Session:GetRoles()
            }
        )

    ---------------------------------------------------
    -- Route Message
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    LootCouncil:Print(

        "Loot session started."

    )

end

---------------------------------------------------
-- End Session
---------------------------------------------------

local function EndSession()

    if not LootCouncil.Session:IsActive() then

        LootCouncil:Print(
            "No active session."
        )

        return

    end

    ---------------------------------------------------
    -- Only Session Owner Can End
    ---------------------------------------------------

    if not LootCouncil.Session:IsOwner() then

        LootCouncil:Print(
            "Only the session owner can end the session."
        )

        return

    end

    ---------------------------------------------------
    -- Create Message
    ---------------------------------------------------

    local message =
        LootCouncil.Message:New(
            "END"
        )

    ---------------------------------------------------
    -- Route Message
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(
        message,
        UnitName("player")
    )

end

---------------------------------------------------
-- Ping
---------------------------------------------------

local function Ping()

    local message =

        LootCouncil.Message:New(

            "PING"

        )

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    LootCouncil:Print(

        "Sent PING."

    )

end

---------------------------------------------------
-- Test Add Packet
---------------------------------------------------

local function TestAddPacket()

    LootCouncil:Print(

        "Testing ADD_ITEM packet..."

    )

    local message =

        LootCouncil.Message:New(

            "ADD_ITEM",

            {

                itemID = 45558

            }

        )

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    LootCouncil.TestMode:ConfigureApplicants()

    LootCouncil.UI.VotingTab:Refresh()

end

local function ConfigureTestApplicants()

    LootCouncil:Print(
        "Configuring test applicants..."
    )

    local item =
        LootCouncil.Session:GetSelectedItem()

    if not item then
        return
    end

    local applicants =
        item:GetApplicants()

    local responses = {

        LootCouncil.Constants.Response.OS,
        LootCouncil.Constants.Response.BIS,
        LootCouncil.Constants.Response.PASS,
        LootCouncil.Constants.Response.MS,
        LootCouncil.Constants.Response.BIS,
        LootCouncil.Constants.Response.PENDING,
        LootCouncil.Constants.Response.OS,
        LootCouncil.Constants.Response.PASS,
        LootCouncil.Constants.Response.MS,
        LootCouncil.Constants.Response.BIS,

        LootCouncil.Constants.Response.PASS,
        LootCouncil.Constants.Response.OS,
        LootCouncil.Constants.Response.MS,
        LootCouncil.Constants.Response.BIS,
        LootCouncil.Constants.Response.PENDING,
        LootCouncil.Constants.Response.PASS,
        LootCouncil.Constants.Response.OS,
        LootCouncil.Constants.Response.BIS,
        LootCouncil.Constants.Response.MS,
        LootCouncil.Constants.Response.PASS,

        LootCouncil.Constants.Response.OS,
        LootCouncil.Constants.Response.PENDING,
        LootCouncil.Constants.Response.BIS,
        LootCouncil.Constants.Response.MS,
        LootCouncil.Constants.Response.PASS,
        LootCouncil.Constants.Response.OS,
        LootCouncil.Constants.Response.BIS,
        LootCouncil.Constants.Response.PENDING,
        LootCouncil.Constants.Response.MS,
        LootCouncil.Constants.Response.PASS,

        LootCouncil.Constants.Response.BIS,
        LootCouncil.Constants.Response.OS,

        LootCouncil.Constants.Response.PENDING,
        LootCouncil.Constants.Response.MS,
        LootCouncil.Constants.Response.PASS,
        LootCouncil.Constants.Response.BIS,

        LootCouncil.Constants.Response.OS,
        LootCouncil.Constants.Response.MS,

    }

    for i, applicant in ipairs(applicants) do

        applicant:SetResponse(
            responses[i]
        )

    end

end

---------------------------------------------------
-- Test Gear Request Packet
---------------------------------------------------

local function TestGearRequestPacket()

    local item =
        LootCouncil.Session:GetSelectedItem()

    if not item then

        LootCouncil:Print(
            "No selected item."
        )

        return

    end

    local slots =
        LootCouncil.Comparison:GetComparisonSlots(
            item
        )

    local message =

        LootCouncil.Message:New(

            "GEAR_REQUEST",

            {

                target = UnitName("player"),

                slots = slots,

                itemIndex = LootCouncil.Session:GetSelectedIndex(),

            }

        )

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

end

local function TestItemInfo()

    local itemID = 45929

    local name,
          link,
          quality,
          itemLevel,
          requiredLevel,
          itemType,
          itemSubType,
          itemStackCount,
          itemEquipLoc,
          itemTexture =
        GetItemInfo(itemID)

    LootCouncil:Print(
        "GetItemInfo test:"
    )

    LootCouncil:Print(
        "Name: " ..
        tostring(name)
    )

    LootCouncil:Print(
        "Link: " ..
        tostring(link)
    )

    LootCouncil:Print(
        "Texture: " ..
        tostring(itemTexture)
    )

end

---------------------------------------------------
-- Test Hello Packet
---------------------------------------------------

local function TestHelloPacket()

    LootCouncil:Print(

        "Testing HELLO packet..."

    )

    local message =

        LootCouncil.Message:New(

            "HELLO",

            {

                itemID = 45558

            }

        )

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    TestGearRequestPacket()

end

---------------------------------------------------
-- Debug Session
---------------------------------------------------

local function DebugSession()

    if not LootCouncil.Session:IsActive() then

        LootCouncil:Print("No active session.")

        return

    end

    local session = LootCouncil.Session:Get()

    LootCouncil:Print(
        "Players: " ..
        #session.players
    )

    LootCouncil:Print(
        "Items: " ..
        #session.items
    )

    for i, item in ipairs(session.items) do

        LootCouncil:Print(
            i .. ". " ..
            item:GetName()
        )

        LootCouncil:Print(
            "   Applicants: " ..
            item:GetApplicantCount()
        )

        LootCouncil:Print(
            "   Winner: " ..
            tostring(item:GetWinner())
        )

        LootCouncil:Print(
            "   Awarded: " ..
            tostring(item:IsAwarded())
        )

    end

end

local function SaveSession()

    LootCouncil.Persistence:Save()

end

local function PrintHelp()

    LootCouncil:Print("LootCouncil Commands:")
    LootCouncil:Print("/lc - Open the LootCouncil window")
    LootCouncil:Print("/lc test - Toggle developer test mode")
    LootCouncil:Print("/lc debug - Print session information")
    LootCouncil:Print("/lc item <itemID> - Display Blizzard item information")
    LootCouncil:Print("/lc roster - Print the current party/raid roster")
    LootCouncil:Print("Cache command registered.")

end

---------------------------------------------------
-- Compare Item
---------------------------------------------------

local function CompareItem(index)

    index = tonumber(index)

    if not index then

        LootCouncil:Print(
            "Usage: /lc compare <item number>"
        )

        return

    end

    if not LootCouncil.Session:IsActive() then

        LootCouncil:Print(
            "No active session."
        )

        return

    end

    local session = LootCouncil.Session:Get()

    local lootItem = session.items[index]

    if not lootItem then

        LootCouncil:Print(
            "Invalid item number."
        )

        return

    end

    LootCouncil:Print(
        "Comparing: " ..
        lootItem:GetName()
    )

    for _, player in ipairs(session.players) do

        LootCouncil:Print(

            player:GetName() ..
            ": " ..

            LootCouncil.Comparison:GetComparisonText(
                player,
                lootItem
            )

        )

    end

end

---------------------------------------------------
-- Add Item
---------------------------------------------------

local function AddItem(arguments)

    if not LootCouncil.Session:IsActive() then

        LootCouncil:Print(
            "No active session."
        )

        return

    end

    ---------------------------------------------------
    -- Permission
    ---------------------------------------------------

    if not LootCouncil.Permissions:CanManageSession(
        UnitName("player")
    ) then

        LootCouncil:Print(
            "You do not have permission to add loot."
        )

        return

    end

    if not arguments or arguments == "" then

        LootCouncil:Print(
            "Usage: /lc add <item link>"
        )

        return

    end

    local data =
        LootCouncil.Loot:CreateItemData(
            arguments
        )

    if not data then

        LootCouncil:Print(
            "Invalid item link."
        )

        return

    end

    ---------------------------------------------------
    -- Create Message
    ---------------------------------------------------

    local message =

        LootCouncil.Message:New(

            "ADD_ITEM",

            {

                itemID = data.id

            }

        )

    ---------------------------------------------------
    -- Route Message
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

end

---------------------------------------------------
-- Remove Item
---------------------------------------------------

local function RemoveItem(arguments)

    if not LootCouncil.Session:IsActive() then

        LootCouncil:Print(
            "No active session."
        )

        return

    end

    ---------------------------------------------------
    -- Permission
    ---------------------------------------------------

    if not LootCouncil.Permissions:CanManageSession(
        UnitName("player")
    ) then

        LootCouncil:Print(
            "You do not have permission to remove loot."
        )

        return

    end

    ---------------------------------------------------
    -- Item Number
    ---------------------------------------------------

    local number =
        tonumber(arguments)

    if not number then

        LootCouncil:Print(
            "Usage: /lc remove <item number>"
        )

        return

    end

    ---------------------------------------------------
    -- Find Item
    ---------------------------------------------------

    local item =
        LootCouncil.Session:GetItemByNumber(
            number
        )

    if not item then

        LootCouncil:Print(
            "No active item with number " ..
            tostring(number) ..
            "."
        )

        return

    end

    ---------------------------------------------------
    -- Remove
    ---------------------------------------------------

    local removed =
        LootCouncil.Session:RemoveItem(
            number
        )

    if not removed then

        LootCouncil:Print(
            "Unable to remove item."
        )

        return

    end

    LootCouncil:Print(
        "Removed item " ..
        tostring(number) ..
        ": " ..
        item:GetName()
    )

end

---------------------------------------------------
-- Response
---------------------------------------------------

local function ResponsePlayer(arguments)

    local playerName, response =
        arguments:match("^(%S+)%s+(.+)$")

    if not playerName or not response then

        LootCouncil:Print(
            "Usage: /lc response <player> <response>"
        )

        return

    end

    response =
        LootCouncil.ResponseParser:NormalizeResponse(
            response
        )

    if not response then

        LootCouncil:Print(
            "Unknown response."
        )

        return

    end

    local success =
        LootCouncil.Session:SubmitApplicantResponse(

            playerName,

            LootCouncil.Session:GetSelectedIndex(),

            response

        )

    if not success then

        LootCouncil:Print(
            "Unable to update response."
        )

        return

    end

    LootCouncil:Print(

        playerName ..
        " -> " ..
        response

    )

end

---------------------------------------------------
-- Award
---------------------------------------------------

local function AwardItem()

    if not LootCouncil.Session:IsActive() then

        LootCouncil:Print(
            "No active session."
        )

        return

    end

    local item =
        LootCouncil.Session:GetSelectedItem()

    if not item then

        LootCouncil:Print(
            "No selected item."
        )

        return

    end

    local applicants =
        item:GetApplicants()

    if #applicants == 0 then

        LootCouncil:Print(
            "No applicants."
        )

        return

    end

    local winner =
        applicants[1]:GetPlayer():GetName()

    item:Award(winner)

    LootCouncil.Persistence:Save()

    LootCouncil:Print(
        "Awarded to " .. winner
    )

end

---------------------------------------------------
-- Command Table
---------------------------------------------------

commands["test"] = ToggleTest
commands["start"] = StartSession
commands["end"] = EndSession
commands["save"] = SaveSession
commands["debug"] = DebugSession
commands["help"] = PrintHelp
commands["compare"] = CompareItem
commands["response"] = ResponsePlayer
commands["award"] = AwardItem
commands["roster"] = RefreshRoster
commands["add"] = AddItem
commands["remove"] = RemoveItem
commands["ping"] = Ping
commands["testadd"] = TestAddPacket
commands["testhello"] = TestHelloPacket
commands["testiteminfo"] = TestItemInfo

---------------------------------------------------
-- Slash Command
---------------------------------------------------

SLASH_LOOTCOUNCIL1 = "/lc"

SlashCmdList["LOOTCOUNCIL"] = function(msg)

    msg = msg or ""

    local command, arguments =
        msg:match("^(%S*)%s*(.-)$")

    command = string.lower(command or "")

    if command == "" then
        ToggleWindow()
        return
    end

    local handler = commands[command]

    if handler then
        handler(arguments)
    else
        LootCouncil:Print("Unknown command: " .. command)
        PrintHelp()
    end

end