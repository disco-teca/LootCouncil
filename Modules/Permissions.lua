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

    LootCouncil.MessageBus:Register(

        "ROLE_ASSIGN",

        self,

        self.ReceiveRoleAssignment

    )

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

---------------------------------------------------
-- Get Role
---------------------------------------------------

function permissions:GetRole(playerName)

    if not playerName then
        return self.Role.RAIDER
    end

    ---------------------------------------------------
    -- Active Session
    ---------------------------------------------------

    if LootCouncil.Session:IsActive() then

        local sessionRole =
            LootCouncil.Session:GetRole(
                playerName
            )

        if sessionRole then
            return sessionRole
        end

    end

    ---------------------------------------------------
    -- Pre-Session Role
    ---------------------------------------------------

    local players =
        LootCouncilDB.Permissions.Players

    local player =
        players[playerName]

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

    if not playerName then
        return
    end

    if role ~= self.Role.RAIDER
    and role ~= self.Role.COUNCIL then

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

        return true

    end

    ---------------------------------------------------
    -- Other Tabs
    ---------------------------------------------------

    if tabName == "Attendance"
    or tabName == "History"
    or tabName == "BiS" then

        return true

    end

    ---------------------------------------------------
    -- Unknown Tabs
    ---------------------------------------------------

    return false

end

---------------------------------------------------
-- Can Assign Roles
---------------------------------------------------

function permissions:CanAssignRoles(playerName)

    if not playerName then
        return false
    end

    return self:IsCouncil(playerName)

end

---------------------------------------------------
-- Can Manage Session
---------------------------------------------------

function permissions:CanManageSession(playerName)

    if not playerName then
        return false
    end

    return self:IsCouncil(playerName)

end

---------------------------------------------------
-- Can Manage Roles
---------------------------------------------------

function permissions:CanManageRoles(playerName)

    if not playerName then
        return false
    end

    ---------------------------------------------------
    -- Roles Are Locked During Session
    ---------------------------------------------------

    if LootCouncil.Session:IsActive() then
        return false
    end

    ---------------------------------------------------
    -- Before Session
    ---------------------------------------------------

    return playerName == UnitName("player")

end

---------------------------------------------------
-- Toggle Council Role
---------------------------------------------------

function permissions:ToggleCouncil(playerName)

    if not playerName then
        return false
    end

    ---------------------------------------------------
    -- Permission
    ---------------------------------------------------

    if not self:CanManageRoles(
        UnitName("player")
    ) then

        return false

    end

    ---------------------------------------------------
    -- Toggle
    ---------------------------------------------------

    local currentRole =
        self:GetRole(playerName)

    if currentRole == self.Role.COUNCIL then

        self:SetRole(
            playerName,
            self.Role.RAIDER
        )

    else

        self:SetRole(
            playerName,
            self.Role.COUNCIL
        )

    end

    ---------------------------------------------------
    -- Save
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    return true

end

---------------------------------------------------
-- Can Submit Responses
---------------------------------------------------

function permissions:CanSubmitResponses(playerName)

    if not playerName then
        return false
    end

    return self:IsRaider(playerName)
        or self:IsCouncil(playerName)

end