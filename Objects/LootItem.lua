local LootItem = {}
LootItem.__index = LootItem

---------------------------------------------------
-- Construction
---------------------------------------------------

function LootItem:New(data)

    local item =
        setmetatable(
            {},
            LootItem
        )

    item.id =
        data.id

    item.number =
        data.number

    item.link =
        data.link

    item.name =
        data.name

    item.ilvl =
        data.ilvl

    item.equipSlot = data.equipSlot 

    item.icon = nil
    item.quality = nil
    item.itemType = nil
    item.itemSubType = nil
    item.equipSlot = nil

    item.applicants = {}
    item.winner = nil
    item.awarded = false
    item.locked = false

    return item

end

---------------------------------------------------
-- Identity
---------------------------------------------------

function LootItem:GetID()

    return self.id

end

---------------------------------------------------
-- Session Number
---------------------------------------------------

function LootItem:GetNumber()

    return self.number

end

function LootItem:SetNumber(number)

    self.number = number

end

function LootItem:GetName()

    return self.name

end

function LootItem:GetLink()

    return self.link

end

function LootItem:GetQuality()

    return self.quality

end

function LootItem:GetEquipSlot()
    if self.equipSlot then
        return self.equipSlot
    end
    
    -- If not stored, try to fetch it
    local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(self.id)
    self.equipSlot = equipSlot
    return equipSlot
end

function LootItem:SetMetadata(metadata)

    if not metadata then
        return
    end

    self.name =
        metadata.name

    self.link =
        metadata.link

    self.icon =
        metadata.icon

    self.quality =
        metadata.quality

    self.itemType =
        metadata.itemType

    self.itemSubType =
        metadata.itemSubType

    self.equipSlot =
        metadata.equipSlot

    if metadata.itemLevel then

        self.ilvl =
            metadata.itemLevel

    end

end

function LootItem:GetItemType()

    return self.itemType

end

function LootItem:GetItemSubType()

    return self.itemSubType

end

function LootItem:GetIcon()
    if self.icon then
        return self.icon
    end
    
    if self.id then
        local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(self.id)
        if icon then
            self.icon = icon
            return icon
        end
    end
    
    -- If we have a link, use it to force the icon to load
    if self.link then
        -- Create a temporary tooltip to force the item to cache
        local tooltip = CreateFrame("GameTooltip", "LootCouncilIconTooltip", nil, "GameTooltipTemplate")
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetHyperlink(self.link)
        tooltip:Hide()
        
        -- Try again after forcing
        if self.id then
            local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(self.id)
            if icon then
                self.icon = icon
                return icon
            end
        end
    end
    
    return nil
end

function LootItem:GetItemLevel()

    return self.ilvl

end

---------------------------------------------------
-- Relationships
---------------------------------------------------

function LootItem:FindApplicant(player)

    if not player then
        return nil
    end

    local playerName

    if type(player) == "string" then

        playerName = player

    else

        playerName = player:GetName()

    end

    for _, applicant in ipairs(self.applicants) do

        local applicantPlayer =
            applicant:GetPlayer()

        if applicantPlayer and
           applicantPlayer:GetName() ==
           playerName then

            return applicant

        end

    end

    return nil

end

function LootItem:GetApplicants()

    return self.applicants

end

function LootItem:GetApplicantCount()

    return #self.applicants

end

---------------------------------------------------
-- Behavior
---------------------------------------------------

---------------------------------------------------
-- Applicants
---------------------------------------------------

function LootItem:AddApplicant(player)

    local existing =
        self:FindApplicant(player)

    if existing then

        existing:SetPlayer(player)

        return existing

    end

    local applicant =
        LootCouncil.Applicant:New(player)

    table.insert(
        self.applicants,
        applicant
    )

    return applicant

end

---------------------------------------------------
-- Awarding
---------------------------------------------------

function LootItem:IsAwarded()

    return self.awarded

end

function LootItem:SetAwarded(awarded)

    self.awarded = awarded

end

LootCouncil.LootItem = LootItem

---------------------------------------------------
-- Winner
---------------------------------------------------

function LootItem:GetWinner()

    return self.winner

end

function LootItem:SetWinner(playerName)

    self.winner = playerName

end

function LootItem:ClearWinner()

    self.winner = nil

end

function LootItem:HasWinner()

    return self.winner ~= nil

end

function LootItem:Award(playerName)

    self:SetWinner(
        playerName
    )

    self:SetAwarded(
        true
    )

end

function LootItem:ClearAward()

    self:SetWinner(nil)

    self:SetAwarded(false)

end