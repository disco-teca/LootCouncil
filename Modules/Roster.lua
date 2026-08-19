LootCouncil.Roster = {}

local module = LootCouncil.Roster

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function module:Refresh()

    LootCouncil:Print("Refreshing roster...")

    ---------------------------------------------------
    -- Reset Session Roster
    ---------------------------------------------------

    LootCouncil.Session:ClearPlayers()

    ---------------------------------------------------
    -- Raid
    ---------------------------------------------------

    if GetNumRaidMembers() > 0 then

        LootCouncil:Print(
            "Raid Members: " ..
            GetNumRaidMembers()
        )

        for i = 1, GetNumRaidMembers() do

            local
                name,
                _,
                _,
                _,
                class =
                GetRaidRosterInfo(i)

            LootCouncil.Session:AddPlayer(
                LootCouncil.Player:New(
                    name,
                    class
                )
            )

            LootCouncil:Print(
                tostring(i) ..
                ". " ..
                tostring(name)
            )

        end

    ---------------------------------------------------
    -- Party
    ---------------------------------------------------

    elseif GetNumPartyMembers() > 0 then

        local
            playerName,
            playerClass =
            UnitName("player"),
            select(2, UnitClass("player"))

        LootCouncil.Session:AddPlayer(
            LootCouncil.Player:New(
                playerName,
                playerClass
            )
        )

        for i = 1, GetNumPartyMembers() do

            local unit = "party" .. i

            local
                name,
                class =
                UnitName(unit),
                select(2, UnitClass(unit))

            LootCouncil.Session:AddPlayer(
                LootCouncil.Player:New(
                    name,
                    class
                )
            )

        end

    ---------------------------------------------------
    -- Solo
    ---------------------------------------------------

    else

        local
            playerName,
            playerClass =
            UnitName("player"),
            select(2, UnitClass("player"))

        LootCouncil.Session:AddPlayer(
            LootCouncil.Player:New(
                playerName,
                playerClass
            )
        )

        LootCouncil:Print(
            "Solo: " .. playerName
        )

    end

    ---------------------------------------------------
    -- Initialize Existing Items
    ---------------------------------------------------

    for _, item in ipairs(
        LootCouncil.Session:GetItems()
    ) do

        LootCouncil.Session:InitializeApplicants(
            item
        )

    end

    LootCouncil.UI.VotingTab:Refresh()

end