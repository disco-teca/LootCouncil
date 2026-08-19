---------------------------------------------------
-- Inspection Subsystem
--
-- This module coordinates the inspection system.
-- It owns the public inspection API and delegates
-- queue management and cached data storage to the
-- InspectQueue and InspectCache modules.
---------------------------------------------------

LootCouncil.Inspect = {}

local module = LootCouncil.Inspect

---------------------------------------------------
-- State
---------------------------------------------------

module.state =
    LootCouncil.Constants.InspectModuleState.IDLE

---------------------------------------------------
-- Initialize
---------------------------------------------------

function module:Initialize()

    LootCouncil.InspectQueue:Initialize()

    self.state =
        LootCouncil.Constants.InspectModuleState.IDLE

    self:InitializeEvents()

end

---------------------------------------------------
-- Requests
---------------------------------------------------

function module:CreateRequest(player)

    if not player then
        return nil
    end

    local request =
        LootCouncil.InspectRequest:New(player)

    return request

end

---------------------------------------------------
-- Unit Lookup
---------------------------------------------------

function module:GetUnitID(playerName)

    if not playerName then
        return nil
    end

    local searchName = string.lower(playerName)

    local localPlayer = UnitName("player")

    if localPlayer and string.lower(localPlayer) == searchName then
        return "player"
    end

    if GetNumRaidMembers() > 0 then

        for i = 1, GetNumRaidMembers() do

            local unit = "raid" .. i
            local name = UnitName(unit)

            if name and string.lower(name) == searchName then
                return unit
            end

        end

    end

    if GetNumPartyMembers() > 0 then

        for i = 1, GetNumPartyMembers() do

            local unit = "party" .. i
            local name = UnitName(unit)

            if name and string.lower(name) == searchName then
                return unit
            end

        end

    end

    return nil

end

---------------------------------------------------
-- Queue
---------------------------------------------------

---------------------------------------------------
-- Public API
---------------------------------------------------

function module:GetEquipment(player)

    if not player then
        return nil
    end

    local data =
        LootCouncil.PlayerData:GetPlayerData(

            player:GetName()

        )

    if not data then
        return nil
    end

    return data.equipped

end

function module:QueuePlayer(playerName)

    if not playerName then
        return
    end

    local player =
        LootCouncil.Session:GetPlayer(playerName)

    if not player then

        LootCouncil:Print(
            "Unable to find player: " .. playerName
        )

        return

    end

    local request =
        self:CreateRequest(player)

    self:QueueRequest(request)

end

function module:InspectPlayer(playerName)

    if not playerName or playerName == "" then
        return
    end

    ---------------------------------------------------
    -- Existing Request
    ---------------------------------------------------

    local request =
        LootCouncil.InspectQueue:FindRequest(playerName)

    if request then

        LootCouncil:Print(
            "Updating inspection request: " .. playerName
        )

        return

    end

    ---------------------------------------------------
    -- New Request
    ---------------------------------------------------

    local player = LootCouncil.Player:New(playerName)

    request = self:CreateRequest(player)

    self:QueueRequest(request)

end

function module:QueueRequest(request)

    if not request then
        return
    end

    LootCouncil.InspectQueue:AddRequest(request)

    if self:IsIdle() then

        self:ProcessQueue()

    else

        print("Inspect module is busy.")

    end

end

---------------------------------------------------
-- Queue Management
---------------------------------------------------

function module:GetNextRequest()

    ---------------------------------------------------
    -- Normal Queue
    ---------------------------------------------------

    if #self.queue > 0 then
        return self.queue[1]
    end

    ---------------------------------------------------
    -- Deferred Queue
    ---------------------------------------------------

    -- Retry policy intentionally disabled for now.
    -- Deferred requests remain stored until they become
    -- eligible for retry.

    return nil

end

function module:PopNextRequest()

    ---------------------------------------------------
    -- Normal Queue
    ---------------------------------------------------

    if #self.queue > 0 then
        return table.remove(self.queue, 1)
    end

    ---------------------------------------------------
    -- Deferred Queue
    ---------------------------------------------------

    -- Retry policy intentionally disabled for now.

    return nil

end

function module:IsQueueEmpty()

    return LootCouncil.InspectQueue:IsQueueEmpty()

end

function module:ClearQueue()

    LootCouncil.InspectQueue:ClearQueue()

end

function module:GetQueueSize()

    return LootCouncil.InspectQueue:GetQueueSize()

end

function module:GetActiveRequest()

    return self:GetCurrentRequest()

end

---------------------------------------------------
-- Queue State
---------------------------------------------------

function module:GetQueue()

    return LootCouncil.InspectQueue:GetQueue()

end

function module:GetCurrentRequest()

    return LootCouncil.InspectQueue:GetCurrentRequest()

end

function module:SetCurrentRequest(request)

    LootCouncil.InspectQueue:SetCurrentRequest(request)

end

function module:ClearCurrentRequest()

    LootCouncil.InspectQueue:ClearCurrentRequest()

end

---------------------------------------------------
-- Queue Processing
---------------------------------------------------

function module:ProcessQueue()

    if self:IsBusy() then
        return
    end

    local request = LootCouncil.InspectQueue:PopNextRequest()

    if request then

        self:StartInspection(request)

        return

    end

    self:SetState(
        LootCouncil.Constants.InspectModuleState.IDLE
    )

end

function module:StartInspection(request)

    self:SetCurrentRequest(request)

    local player = request:GetPlayer()
    local playerName = player:GetName()

    self:SetState(
        LootCouncil.Constants.InspectModuleState.INSPECTING
    )

    request:SetState(
        LootCouncil.Constants.InspectRequestState.INSPECTING
    )

    local unit = self:GetUnitID(playerName)

    ---------------------------------------------------
    -- Unable to find unit
    ---------------------------------------------------

    if not unit then

        print("No unit found.")

        request:SetState(
            LootCouncil.Constants.InspectRequestState.FAILED
        )

        LootCouncil:Print(
            "Unable to inspect " .. playerName
        )

        self:ClearCurrentRequest()

        self:SetState(
            LootCouncil.Constants.InspectModuleState.IDLE
        )

        self:ProcessQueue()

        return

    end

    ---------------------------------------------------
    -- Local Player
    ---------------------------------------------------

    if unit == "player" then

        self:FinishInspection(request, unit)

        return

    end

    ---------------------------------------------------
    -- Remote Validation
    ---------------------------------------------------

    if not UnitExists(unit) then

        print("Unit no longer exists.")

        request:SetState(
            LootCouncil.Constants.InspectRequestState.FAILED
        )

        LootCouncil:Print(
            "Unable to inspect " .. playerName
        )

    elseif not UnitIsConnected(unit) then

        print("Player is offline.")

        request:SetState(
            LootCouncil.Constants.InspectRequestState.DEFERRED
        )

        LootCouncil.InspectQueue:AddDeferredRequest(request)

    elseif not CanInspect(unit) then

        print("Player cannot be inspected.")

        request:SetState(
            LootCouncil.Constants.InspectRequestState.DEFERRED
        )

        LootCouncil.InspectQueue:AddDeferredRequest(request)

    else

        print("Remote inspection")

        NotifyInspect(unit)

        return

    end

    self:ClearCurrentRequest()

    self:SetState(
        LootCouncil.Constants.InspectModuleState.IDLE
    )

    self:ProcessQueue()

end

function module:FinishInspection(request, unit)

    local player = request:GetPlayer()
    local playerName = player:GetName()

    local data = self:ReadEquipment(
        playerName,
        unit
    )

    self:CompleteRequest(request, data)

    if unit ~= "player" then
        ClearInspectPlayer()
    end

end

---------------------------------------------------
-- Request Completion
---------------------------------------------------

function module:CompleteRequest(request, data)

    request:SetResult(data)

    request:SetState(
        LootCouncil.Constants.InspectRequestState.COMPLETED
    )

    local player = request:GetPlayer()

    ---------------------------------------------------
    -- Store inspection data
    ---------------------------------------------------

    LootCouncil.PlayerData:SetPlayerData(
        player:GetName(),
        data
    )

    LootCouncil.InspectCache:UpdatePlayerData(
        player:GetName(),
        data
    )

    self:ClearCurrentRequest()

    self:SetState(
        LootCouncil.Constants.InspectModuleState.IDLE
    )

    self:ProcessQueue()

end

function module:ResumeDeferredRequest(playerName)

    if not playerName then
        return
    end

    local request =
        LootCouncil.InspectQueue:FindRequest(playerName)

    if not request then
        return
    end

    if request:GetState() ~=
        LootCouncil.Constants.InspectRequestState.DEFERRED
    then
        return
    end

    LootCouncil.InspectQueue:RemoveDeferredRequest(
        request
    )

    request:SetState(
        LootCouncil.Constants.InspectRequestState.QUEUED
    )

    self:QueueRequest(request)

end

function module:InitializeEvents()

    self.eventFrame = CreateFrame("Frame")

    self.eventFrame:RegisterEvent("INSPECT_TALENT_READY")
    self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")

    self.eventFrame:SetScript("OnEvent", function(frame, event, ...)

        ---------------------------------------------------
        -- Target Changed
        ---------------------------------------------------

        if event == "PLAYER_TARGET_CHANGED" then

            self:ResumeDeferredRequest(
                UnitName("target")
            )

            return

        end

        ---------------------------------------------------
        -- Inventory Changed
        ---------------------------------------------------

        if event == "UNIT_INVENTORY_CHANGED" then

            local unit = ...

            if unit then

                self:ResumeDeferredRequest(
                    UnitName(unit)
                )

            end

            return

        end

        ---------------------------------------------------
        -- Inspect Complete
        ---------------------------------------------------

        local request = self:GetCurrentRequest()

        if not request then
            return
        end

        local player = request:GetPlayer()

        print("Active request:", player:GetName())

        local unit = self:GetUnitID(player:GetName())

        print("Resolved unit:", tostring(unit))

        if not unit then
            return
        end

        self:FinishInspection(request, unit)

    end)

end

---------------------------------------------------
-- Developer Inspection
---------------------------------------------------

---------------------------------------------------
-- Events
---------------------------------------------------

---------------------------------------------------
-- State
---------------------------------------------------

function module:GetState()

    return self.state

end

function module:SetState(state)

    self.state = state

end

function module:IsIdle()

    return self.state ==
        LootCouncil.Constants.InspectModuleState.IDLE

end

function module:IsBusy()

    return not self:IsIdle()

end

---------------------------------------------------
-- Equipment
---------------------------------------------------

function module:ReadEquipment(playerName, unit)

    local data =
        LootCouncil.PlayerData:CreatePlayerData()

    for slotName, slotID in pairs(
        LootCouncil.Constants.InventorySlot
    ) do

        local itemLink =
            GetInventoryItemLink(unit, slotID)

        local cacheItem =
            data.equipped[slotName]

        cacheItem.link = itemLink

        if itemLink then

            cacheItem.itemID =
                GetInventoryItemID(unit, slotID)

            local _, _, quality, itemLevel, _, _, _, _, equipSlot, icon =
                GetItemInfo(itemLink)

            cacheItem.quality = quality
            cacheItem.itemLevel = itemLevel
            cacheItem.equipSlot = equipSlot
            cacheItem.icon = icon

        else

            cacheItem.itemID = nil
            cacheItem.quality = nil
            cacheItem.itemLevel = nil
            cacheItem.equipSlot = nil
            cacheItem.icon = nil

        end

    end

    return data

end

---------------------------------------------------
-- Slot Lookup
---------------------------------------------------

function module:GetComparisonSlot(itemLink)

    if not itemLink then
        return nil
    end

    local _, _, _, _, _, _, _, _, equipSlot =
        GetItemInfo(itemLink)

    if equipSlot == "INVTYPE_HEAD" then
        return "Head"
    elseif equipSlot == "INVTYPE_NECK" then
        return "Neck"
    elseif equipSlot == "INVTYPE_SHOULDER" then
        return "Shoulder"
    elseif equipSlot == "INVTYPE_CLOAK" then
        return "Back"
    elseif equipSlot == "INVTYPE_CHEST" then
        return "Chest"
    elseif equipSlot == "INVTYPE_ROBE" then
        return "Chest"
    elseif equipSlot == "INVTYPE_WRIST" then
        return "Wrist"
    elseif equipSlot == "INVTYPE_HAND" then
        return "Hands"
    elseif equipSlot == "INVTYPE_WAIST" then
        return "Waist"
    elseif equipSlot == "INVTYPE_LEGS" then
        return "Legs"
    elseif equipSlot == "INVTYPE_FEET" then
        return "Feet"
    end

    return nil

end

---------------------------------------------------
-- TODO
--
-- Support multi-slot comparisons:
--
--  * Rings
--  * Trinkets
--  * One-handed weapons
--  * Two-handed weapons
--  * Ranged / Relic / Wand
--
-- This function currently only supports
-- single-slot armor comparisons.
---------------------------------------------------

---------------------------------------------------
-- Item Level Comparison
---------------------------------------------------

function module:GetItemLevelComparison(applicant)

    if not applicant then
        return "--"
    end

    local player = applicant:GetPlayer()

    if not player then
        return "--"
    end

    local item = LootCouncil.Session:GetSelectedItem()

    if not item then
        return "--"
    end

    local playerData =
        LootCouncil.PlayerData:GetPlayerData(
            player:GetName()
        )

    if not playerData then

        return "--"

    end
    local slotName =
        self:GetComparisonSlot(
            item:GetLink()
        )

    if not slotName then
        return "--"
    end

    local equipped =
        playerData.equipped[slotName]

    if not equipped then

        return "--"

    end

    if not equipped.itemLevel then
        return "--"
    end

    local sessionItemLevel =
        item:GetItemLevel()

    if not sessionItemLevel then
        return tostring(equipped.itemLevel) .. " -> ?"
    end

    return tostring(equipped.itemLevel)
        .. " -> "
        .. tostring(sessionItemLevel)

end