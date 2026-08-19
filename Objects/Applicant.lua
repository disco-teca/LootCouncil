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

function Applicant:RemoveVote(councilMember)

    for i, voter in ipairs(self.votes) do

        if voter == councilMember then

            table.remove(
                self.votes,
                i
            )

            return true

        end

    end

    return false

end

function Applicant:GetVoteCount()

    return #self.votes

end

LootCouncil.Applicant = Applicant

function Applicant:GetEquippedIcon(item)

    if not item then
        return nil
    end

    local slots =
        LootCouncil.Comparison:GetComparisonSlots(
            item
        )

    if #slots == 0 then
        return nil
    end

    ---------------------------------------------------
    -- Return First Matching Slot
    ---------------------------------------------------

    for _, slotID in ipairs(slots) do

        local gear =
            self.gear[slotID]

        if gear and gear.itemID then

            local name,
                  link,
                  quality,
                  itemLevel,
                  requiredLevel,
                  itemType,
                  itemSubType,
                  itemStackCount,
                  itemEquipLoc,
                  itemTexture =
                GetItemInfo(
                    gear.itemID
                )

            if itemTexture then
                return itemTexture
            end

        end

    end

    return nil

end

function Applicant:GetEquippedLink(item)

    if not item then
        return nil
    end

    local slots =
        LootCouncil.Comparison:GetComparisonSlots(
            item
        )

    if #slots == 0 then
        return nil
    end

    ---------------------------------------------------
    -- Return First Matching Slot
    ---------------------------------------------------

    for _, slotID in ipairs(slots) do

        local gear =
            self.gear[slotID]

        if gear and gear.link then
            return gear.link
        end

    end

    return nil

end