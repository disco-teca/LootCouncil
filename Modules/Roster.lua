LootCouncil.Roster = {}

local module = LootCouncil.Roster

module.players = {}

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

    self.players = {}

end

---------------------------------------------------
-- Get Players
---------------------------------------------------

function module:GetPlayers()

    return self.players

end

---------------------------------------------------
-- Refresh
---------------------------------------------------

function module:Refresh()

    LootCouncil:Print("Refreshing roster...")

    ---------------------------------------------------
    -- Reset Roster
    ---------------------------------------------------

    self.players = {}

    ---------------------------------------------------
    -- Raid
    ---------------------------------------------------

    if GetNumRaidMembers() > 0 then

        for i = 1, GetNumRaidMembers() do

            local
                name,
                _,
                _,
                _,
                class =
                GetRaidRosterInfo(i)

            table.insert(
                self.players,
                LootCouncil.Player:New(
                    name,
                    class
                )
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

        table.insert(
            self.players,
            LootCouncil.Player:New(
                playerName,
                playerClass
            )
        )

        for i = 1, GetNumPartyMembers() do

            local unit =
                "party" .. i

            local
                name,
                class =
                UnitName(unit),
                select(2, UnitClass(unit))

            table.insert(
                self.players,
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

        table.insert(
            self.players,
            LootCouncil.Player:New(
                playerName,
                playerClass
            )
        )

    end

end