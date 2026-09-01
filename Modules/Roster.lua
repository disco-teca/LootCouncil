LootCouncil.Roster = {}

local module = LootCouncil.Roster

module.players = {}

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()
    self.players = {}
    
    -- Register for roster updates
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("RAID_ROSTER_UPDATE")
    frame:SetScript("OnEvent", function(self, event, ...)
        module:OnEvent(event, ...)
    end)
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

---------------------------------------------------
-- Event Handler
---------------------------------------------------

function module:OnEvent(event, ...)
    if event == "RAID_ROSTER_UPDATE" then
        self:Refresh()
        
        -- If there's an active session, update session.players too
        if LootCouncil.Session:IsActive() then
            local session = LootCouncil.Session:Get()
            if session then
                -- Rebuild session players from the updated roster
                session.players = {}
                for _, player in ipairs(self:GetPlayers()) do
                    table.insert(session.players, player)
                end
                
                -- Rebuild applicants for all items
                for _, item in ipairs(session.items or {}) do
                    LootCouncil.Session:InitializeApplicants(item)
                end
                
                -- Refresh UI
                LootCouncil.UI.TabManager:Refresh()
                LootCouncil.UI.VotingTab:Refresh()
                LootCouncil.UI.LootTab:Refresh()
            end
        end
    end
end