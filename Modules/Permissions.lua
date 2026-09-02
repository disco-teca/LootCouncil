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

end

---------------------------------------------------
-- Can View Tab
---------------------------------------------------

function permissions:CanViewTab(playerName, tabName)
    -- Everyone can view all tabs for now
    return true
end

---------------------------------------------------
-- Can Manage Session
---------------------------------------------------

function permissions:CanManageSession(playerName)
    if not playerName then
        return false
    end
    -- Only the session owner can manage the session
    return LootCouncil.Session:IsOwner()
end