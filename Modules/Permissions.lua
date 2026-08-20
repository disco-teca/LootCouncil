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

    LootCouncilDB.Permissions.Roles =
        LootCouncilDB.Permissions.Roles or {}

end

---------------------------------------------------
-- Get Role
---------------------------------------------------

function permissions:GetRole(playerName)

    if not playerName then
        return self.Role.RAIDER
    end

    local roles =
        LootCouncilDB.Permissions.Roles

    local role =
        roles[playerName]

    if role then
        return role
    end

    ---------------------------------------------------
    -- Session Owner
    ---------------------------------------------------

    if LootCouncil.Session:IsOwner(playerName) then

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

    LootCouncilDB.Permissions.Roles[playerName] =
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