LootCouncil.Guild = {}

local module = LootCouncil.Guild

---------------------------------------------------
-- State
---------------------------------------------------

local loadingRoster = false

local rosterFrame = nil

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

    rosterFrame = CreateFrame("Frame")

    rosterFrame:SetScript("OnEvent", function(self, event, ...)
        module:OnEvent(event, ...)
    end)

end

---------------------------------------------------
-- Event Handler
---------------------------------------------------

function module:OnEvent(event)

    if event == "GUILD_ROSTER_UPDATE" then

        module:CaptureRoster()

        rosterFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")

        loadingRoster = false

    end

end

---------------------------------------------------
-- Roster Loading
---------------------------------------------------

function module:RequestRoster()

    ---------------------------------------------------
    -- Drop if already loading
    ---------------------------------------------------

    if loadingRoster then
        return
    end

    ---------------------------------------------------
    -- Begin load
    ---------------------------------------------------

    loadingRoster = true

    rosterFrame:RegisterEvent("GUILD_ROSTER_UPDATE")

    GuildRoster()

    C_Timer.After(5, function()

        if loadingRoster then

            loadingRoster = false

            rosterFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")

            LootCouncil:Print("Guild roster load timed out.")

        end

    end)

    LootCouncil:Print("Loading guild roster...")

end

function module:CaptureRoster()

    local members = {}

    local count = GetNumGuildMembers()

    for i = 1, count do

        local name,
              rankName,
              rankIndex =
            GetGuildRosterInfo(i)

        if name then

            table.insert(members, {
                name = name,
                rankName = rankName,
                rankIndex = rankIndex,
            })

        end

    end

    LootCouncilDB.GuildRoster = members

    LootCouncil:Print("Guild roster loaded: " .. #members .. " member(s).")

end

---------------------------------------------------
-- Accessors
---------------------------------------------------

function module:GetMembers()

    return LootCouncilDB.GuildRoster or {}

end

function module:GetDesignations()

    return LootCouncilDB.PreSessionCouncil or {}

end

function module:IsDesignated(name)

    if not name then
        return false
    end

    for _, designatedName in ipairs(LootCouncilDB.PreSessionCouncil or {}) do

        if designatedName == name then
            return true
        end

    end

    return false

end

---------------------------------------------------
-- Designation Toggle
---------------------------------------------------

function module:ToggleDesignation(name)

    if not name then
        return
    end

    if not LootCouncilDB.PreSessionCouncil then
        LootCouncilDB.PreSessionCouncil = {}
    end

    ---------------------------------------------------
    -- Remove if present
    ---------------------------------------------------

    for i, designatedName in ipairs(LootCouncilDB.PreSessionCouncil) do

        if designatedName == name then

            table.remove(LootCouncilDB.PreSessionCouncil, i)

            return

        end

    end

    ---------------------------------------------------
    -- Otherwise add
    ---------------------------------------------------

    table.insert(LootCouncilDB.PreSessionCouncil, name)

end