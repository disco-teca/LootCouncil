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
    if tabName == "Voting" then
        return LootCouncil.Session:IsCouncil(playerName)
    end
    -- All other tabs are visible to everyone
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