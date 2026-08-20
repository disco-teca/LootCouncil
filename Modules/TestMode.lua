LootCouncil.TestMode = {}

local active = false

function LootCouncil.TestMode:IsActive()

    return active

end

function LootCouncil.TestMode:Start()

    active = true

    LootCouncil.Session:Create()

    LootCouncil.Session:Start()

    ---------------------------------------------------
    -- Test Applicants
    ---------------------------------------------------

    local testClasses = {

        "DEATHKNIGHT",
        "DRUID",
        "HUNTER",
        "MAGE",
        "PALADIN",
        "PRIEST",
        "ROGUE",
        "SHAMAN",
        "WARLOCK",
        "WARRIOR",

    }

    for i = 1, 38 do

        local class =
            testClasses[
                ((i - 1) % #testClasses) + 1
            ]

        local player =
            LootCouncil.Player:New(

                "TestPlayer" .. i,

                class

            )

        LootCouncil.Session:AddPlayer(
            player
        )

    end

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.UI:Show()

    LootCouncil:Print(
        "Developer test session started."
    )

end

function LootCouncil.TestMode:Stop()

    active = false

    LootCouncil.Session:Destroy()

    LootCouncil:Print("Developer test session ended.")

end

function LootCouncil.TestMode:Toggle()

    if active then
        self:Stop()
    else
        self:Start()
    end

end

---------------------------------------------------
-- Test MessageBus
---------------------------------------------------

function LootCouncil.TestMode:TestMessageBus()

    LootCouncil:Print(
        "Beginning MessageBus test..."
    )

    ---------------------------------------------------
    -- Clean Previous Tests
    ---------------------------------------------------

    LootCouncil.MessageBus:Unregister(

        "PLAYER_DATA_UPDATED",

        self

    )

    ---------------------------------------------------
    -- Register Local Listener
    ---------------------------------------------------

    LootCouncil.MessageBus:Register(

        "PLAYER_DATA_UPDATED",

        self,

        function(owner, message, sender)

            LootCouncil:Print(

                "LOCAL: PLAYER_DATA_UPDATED from " ..
                tostring(sender)

            )

        end

    )

    LootCouncil.MessageBus:Register(

        "PLAYER_DATA_APPLIED",

        self,

        function(owner, message, sender)

            LootCouncil:Print(

                "LOCAL: PLAYER_DATA_APPLIED from " ..
                tostring(sender)

            )

        end

    )

    ---------------------------------------------------
    -- Register Transport Listener
    ---------------------------------------------------

    LootCouncil.MessageBus:RegisterTransport(

        self,

        function(owner, message, sender)

            LootCouncil:Print(

                "TRANSPORT: " ..
                message:GetCommand() ..
                " from " ..
                tostring(sender)

            )

        end

    )

    ---------------------------------------------------
    -- Create Message
    ---------------------------------------------------

    local message =

        LootCouncil.Message:New(

            "PLAYER_DATA_UPDATED",

            {

                player = UnitName("player")

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
-- Configure Test Applicants
---------------------------------------------------

function LootCouncil.TestMode:ConfigureApplicants()

    LootCouncil:Print(
        "Configuring test applicants..."
    )

    local item =
        LootCouncil.Session:GetSelectedItem()

    if not item then

        LootCouncil:Print(
            "No test item found."
        )

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

    LootCouncil:Print(
        "Configured " ..
        tostring(#applicants) ..
        " test applicants."
    )

end