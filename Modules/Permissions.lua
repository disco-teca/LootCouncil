LootCouncil.Permissions = {}

local permissions = LootCouncil.Permissions

---------------------------------------------------
-- Roles
---------------------------------------------------

permissions.Role = {

    RAIDER = "RAIDER",

    COUNCIL = "COUNCIL",

}

---------------------------------------------------
-- Initialize
---------------------------------------------------

function permissions:Initialize()

    LootCouncilDB.Permissions =
        LootCouncilDB.Permissions or {}

    LootCouncilDB.Permissions.Players =
        LootCouncilDB.Permissions.Players or {}

end

---------------------------------------------------
-- Register Player
---------------------------------------------------

function permissions:RegisterPlayer(playerName)

    if not playerName then
        return
    end

    local players =
        LootCouncilDB.Permissions.Players

    if players[playerName] then
        return
    end

    players[playerName] = {}

end

---------------------------------------------------
-- Get Players
---------------------------------------------------

function permissions:GetPlayers()

    return LootCouncilDB.Permissions.Players

end

---------------------------------------------------
-- Get Role
---------------------------------------------------

function permissions:GetRole(playerName)

    if not playerName then
        return self.Role.RAIDER
    end

    local players =
        LootCouncilDB.Permissions.Players

    local player =
        players[playerName]

    ---------------------------------------------------
    -- Saved Role
    ---------------------------------------------------

    if player and player.role then

        return player.role

    end

    ---------------------------------------------------
    -- Session Owner
    ---------------------------------------------------

    if playerName == UnitName("player")
    and LootCouncil.Session:IsOwner() then

        return self.Role.COUNCIL

    end

    ---------------------------------------------------
    -- Default
    ---------------------------------------------------

    return self.Role.RAIDER

end

---------------------------------------------------
-- Set Role
---------------------------------------------------

function permissions:SetRole(
    playerName,
    role
)

    if not playerName then
        return false
    end

    if role ~= self.Role.RAIDER
    and role ~= self.Role.COUNCIL then

        return false

    end

    self:RegisterPlayer(playerName)

    LootCouncilDB.Permissions.Players[playerName].role =
        role

    return true

end

---------------------------------------------------
-- Is Council
---------------------------------------------------

function permissions:IsCouncil(playerName)

    return self:GetRole(playerName) ==
        self.Role.COUNCIL

end

---------------------------------------------------
-- Is Raider
---------------------------------------------------

function permissions:IsRaider(playerName)

    return self:GetRole(playerName) ==
        self.Role.RAIDER

end

---------------------------------------------------
-- Can View Tab
---------------------------------------------------

function permissions:CanViewTab(
    playerName,
    tabName
)

    local role =
        self:GetRole(playerName)

    ---------------------------------------------------
    -- Loot
    ---------------------------------------------------

    if tabName == "Loot" then

        return true

    end

    ---------------------------------------------------
    -- Voting
    ---------------------------------------------------

    if tabName == "Voting" then

        return role == self.Role.COUNCIL

    end

    ---------------------------------------------------
    -- Settings
    ---------------------------------------------------

    if tabName == "Settings" then

        return role == self.Role.COUNCIL

    end

    ---------------------------------------------------
    -- Future / Unrestricted
    ---------------------------------------------------

    return true

end