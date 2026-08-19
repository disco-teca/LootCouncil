local Applicant = {}
Applicant.__index = Applicant

function Applicant:New(player)

    local applicant = setmetatable({}, Applicant)

    applicant.player = player

    applicant.response =
        LootCouncil.Constants.Response.PENDING

    applicant.autoPass = false

    applicant.votes = {}

    applicant.awarded = false

    applicant.gear = {}

    applicant.responseTime = nil

    return applicant

end

function Applicant:GetPlayer()
    return self.player
end

function Applicant:SetPlayer(player)

    self.player = player

end

function Applicant:GetResponse()
    return self.response
end

---------------------------------------------------
-- Item Level Comparison
---------------------------------------------------

function Applicant:GetItemLevelComparison()

    return LootCouncil.Inspect:GetItemLevelComparison(self)

end

function Applicant:SetResponse(response)

    self.response = response

    self.responseTime = time()

end

function Applicant:IsAutoPassed()
    return self.autoPass
end

function Applicant:SetAutoPass(autoPass)
    self.autoPass = autoPass
end

function Applicant:GetVotes()
    return self.votes
end

function Applicant:AddVote(councilMember)

    for _, voter in ipairs(self.votes) do

        if voter == councilMember then
            return false
        end

    end

    table.insert(

        self.votes,

        councilMember

    )

    return true

end

function Applicant:GetVoteCount()

    return #self.votes

end

LootCouncil.Applicant = Applicant

function Applicant:GetEquippedIcon()

    local comparison =
        LootCouncil.Inspect:GetComparisonSlot(
            LootCouncil.Session:GetSelectedItem():GetLink()
        )

    if not comparison then
        return nil
    end

    local playerData =
        LootCouncil.PlayerData:GetPlayerData(
            self.player:GetName()
        )

    if not playerData then
        return nil
    end

    local equipped =
        playerData.equipped[comparison]

    if not equipped then
        return nil
    end

    return equipped.icon

end

function Applicant:GetEquippedLink()

    local item =
        LootCouncil.Session:GetSelectedItem()

    if not item then
        return nil
    end

    local slots =
        LootCouncil.Comparison:GetComparisonSlots(item)

    if #slots == 0 then
        return nil
    end

    local playerData =
        LootCouncil.PlayerData:GetPlayerData(
            self.player:GetName()
        )

    if not playerData then
        return nil
    end

    ---------------------------------------------------
    -- Return First Matching Slot
    ---------------------------------------------------

    for _, slotID in ipairs(slots) do

        local slotName

        for name, id in pairs(
            LootCouncil.Constants.InventorySlot
        ) do

            if id == slotID then
                slotName = name
                break
            end

        end

        if slotName then

            local equipped =
                playerData.equipped[slotName]

            if equipped and equipped.link then
                return equipped.link
            end

        end

    end

    return nil

end