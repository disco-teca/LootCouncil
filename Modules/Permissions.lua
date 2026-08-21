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

    LootCouncilDB.Permissions.Initialized =
        LootCouncilDB.Permissions.Initialized or false

    LootCouncil.MessageBus:Register(

        "ROLE_ASSIGN",

        self,

        self.ReceiveRoleAssignment

    )

end

---------------------------------------------------
-- Bootstrap Council
---------------------------------------------------

function permissions:BootstrapCouncil(owner)

    if not owner then
        return false
    end

    ---------------------------------------------------
    -- Only Session Owner Can Bootstrap
    ---------------------------------------------------

    if owner ~= UnitName("player") then
        return false
    end

    local permissionsDB =
        LootCouncilDB.Permissions

    ---------------------------------------------------
    -- Already Initialized
    ---------------------------------------------------

    if permissionsDB.Initialized then
        return false
    end

    ---------------------------------------------------
    -- Establish Council
    ---------------------------------------------------

    self:SetRole(
        owner,
        self.Role.COUNCIL
    )

    permissionsDB.Initialized = true

    ---------------------------------------------------
    -- Broadcast Bootstrap
    ---------------------------------------------------

    local message =
        LootCouncil.Message:New(

            "ROLE_ASSIGN",

            {

                playerName = owner,

                role = self.Role.COUNCIL,

                bootstrap = true,

            }

        )

    LootCouncil:Print(
        "Broadcasting ROLE_ASSIGN for " ..
        owner
    )

    LootCouncil.MessageBus:Route(

        message,

        owner

    )

    return true

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
-- Assign Role
---------------------------------------------------

function permissions:AssignRole(
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

    ---------------------------------------------------
    -- Only Council Can Assign Roles
    ---------------------------------------------------

    local localPlayer =
        UnitName("player")

    if not self:IsCouncil(localPlayer) then

        LootCouncil:Print(
            "You do not have permission to assign roles."
        )

        return false

    end

    ---------------------------------------------------
    -- Apply Locally
    ---------------------------------------------------

    self:SetRole(
        playerName,
        role
    )

    ---------------------------------------------------
    -- Create Message
    ---------------------------------------------------

    local message =
        LootCouncil.Message:New(

            "ROLE_ASSIGN",

            {

                playerName = playerName,

                role = role,

            }

        )

    ---------------------------------------------------
    -- Broadcast
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(

        message,

        localPlayer

    )

    return true

end

---------------------------------------------------
-- Receive Role Assignment
---------------------------------------------------

function permissions:ReceiveRoleAssignment(
    message,
    sender
)

    LootCouncil:Print(
        "ROLE_ASSIGN received from " ..
        tostring(sender)
    )

    local payload =
        message:GetPayload()

    local playerName =
        payload.playerName

    local role =
        payload.role

    local bootstrap =
        payload.bootstrap

    if not playerName then
        return
    end

    if role ~= self.Role.RAIDER
    and role ~= self.Role.COUNCIL then

        return

    end

    ---------------------------------------------------
    -- Bootstrap Assignment
    ---------------------------------------------------

    if bootstrap then

        local permissionsDB =
            LootCouncilDB.Permissions

        if permissionsDB.Initialized then
            return
        end

        self:RegisterPlayer(
            playerName
        )

        self:SetRole(
            playerName,
            role
        )

        return

    end

    ---------------------------------------------------
    -- Normal Assignment
    ---------------------------------------------------

    if not self:IsCouncil(sender) then

        LootCouncil:Print(
            "Rejected role assignment from " ..
            tostring(sender)
        )

        return

    end

    self:RegisterPlayer(
        playerName
    )

    self:SetRole(
        playerName,
        role
    )

    LootCouncil:Print(
        "Role updated: " ..
        playerName ..
        " -> " ..
        role
    )

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