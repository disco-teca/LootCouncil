LootCouncil.Session = {}

local session = nil

local pendingOwnershipTransfer = nil
local pendingManualOwnershipTransfer = nil

---------------------------------------------------
-- Role Assignment Reminder Popup
---------------------------------------------------

StaticPopupDialogs["LOOTCOUNCIL_ASSIGN_ROLES"] = {
    text = "Session Started!\n\nDon't forget to assign roles to your Council.\n\nYou can do this in the Settings tab.",
    button1 = "Open Settings",
    button2 = "Dismiss",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = function()
        LootCouncil.UI:Show()
        LootCouncil.UI.NavigationTabManager:Select("Settings")
    end,
    OnCancel = function()
        -- Dismissed, user can reopen with /lc roles
    end,
}

---------------------------------------------------
-- Ownership Transfer Popup
---------------------------------------------------

StaticPopupDialogs["LOOTCOUNCIL_OWNERSHIP_TRANSFER"] = {

    text =
        "Raid leadership changed to %s.\n\n" ..
        "Transfer session ownership to the new raid leader?",

    button1 = "Yes",

    button2 = "No",

    OnAccept = function()

        if LootCouncil.Session:AcceptOwnershipTransfer() then

            LootCouncil:Print(
                "Ownership transferred."
            )

        else

            LootCouncil:Print(
                "No ownership transfer can be accepted."
            )

        end

    end,

    OnCancel = function()

        if LootCouncil.Session:RejectOwnershipTransfer() then

            LootCouncil:Print(
                "Ownership retained."
            )

        else

            LootCouncil:Print(
                "No ownership transfer can be rejected."
            )

        end

    end,

    timeout = 0,

    whileDead = true,

    hideOnEscape = true,

}

---------------------------------------------------
-- Manual Ownership Transfer Popup
---------------------------------------------------

StaticPopupDialogs["LOOTCOUNCIL_MANUAL_OWNERSHIP_TRANSFER"] = {

    text =
        "Transfer session ownership to %s?",

    button1 = "Yes",

    button2 = "No",

    OnAccept = function()

        if LootCouncil.Session:AcceptManualOwnershipTransfer() then

            LootCouncil:Print(
                "Ownership transferred."
            )

        else

            LootCouncil:Print(
                "No manual ownership transfer can be accepted."
            )

        end

    end,

    OnCancel = function()

        LootCouncil.Session:RejectManualOwnershipTransfer()

    end,

    timeout = 0,

    whileDead = true,

    hideOnEscape = true,

}

---------------------------------------------------
-- State
---------------------------------------------------

function LootCouncil.Session:IsActive()
    return session ~= nil
end

---------------------------------------------------
-- Raid Leadership
---------------------------------------------------

function LootCouncil.Session:GetRaidLeader()

    if GetNumRaidMembers() == 0 then
        return nil
    end

    for i = 1, GetNumRaidMembers() do

        local name, rank =
            GetRaidRosterInfo(i)

        if rank == 2 then
            return name
        end

    end

    return nil

end

function LootCouncil.Session:IsRaidLeader(
    playerName
)

    if not playerName then
        return false
    end

    return playerName ==
        self:GetRaidLeader()

end

---------------------------------------------------
-- Session Owner
---------------------------------------------------

function LootCouncil.Session:GetAuthority()

    if not session then
        return nil
    end

    return session.owner

end

---------------------------------------------------
-- Pending Ownership Transfer
---------------------------------------------------

function LootCouncil.Session:GetPendingOwnershipTransfer()

    return pendingOwnershipTransfer

end

function LootCouncil.Session:AcceptOwnershipTransfer()

    if not session then
        return false
    end

    if self:GetOwner() ~= UnitName("player") then
        return false
    end

    local newOwner =
        pendingOwnershipTransfer

    if not newOwner then
        return false
    end

    ---------------------------------------------------
    -- Create Message
    ---------------------------------------------------

    local message =
        LootCouncil.Message:New(

            "SESSION_OWNER_CHANGED",

            {

                owner = newOwner,

                reason = "TRANSFER",

            }

        )

    ---------------------------------------------------
    -- Clear Pending Transfer
    ---------------------------------------------------

    pendingOwnershipTransfer = nil

    ---------------------------------------------------
    -- Route
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    return true

end

---------------------------------------------------
-- Accept Manual Ownership Transfer
---------------------------------------------------

function LootCouncil.Session:AcceptManualOwnershipTransfer()

    if not session then
        return false
    end

    if self:GetOwner() ~= UnitName("player") then
        return false
    end

    local newOwner =
        pendingManualOwnershipTransfer

    if not newOwner then
        return false
    end

    ---------------------------------------------------
    -- Create Message
    ---------------------------------------------------

    local message =
        LootCouncil.Message:New(

            "SESSION_OWNER_CHANGED",

            {

                owner = newOwner,

                reason = "TRANSFER",

            }

        )

    ---------------------------------------------------
    -- Clear Pending Transfer
    ---------------------------------------------------

    pendingManualOwnershipTransfer = nil

    ---------------------------------------------------
    -- Route
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    return true

end

---------------------------------------------------
-- Reject Ownership Transfer
---------------------------------------------------

function LootCouncil.Session:RejectOwnershipTransfer()

    if not session then
        return false
    end

    local owner =
        self:GetOwner()

    if owner ~= UnitName("player") then
        return false
    end

    if not pendingOwnershipTransfer then
        return false
    end

    ---------------------------------------------------
    -- Keep Current Owner
    ---------------------------------------------------

    pendingOwnershipTransfer = nil

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    return true

end

---------------------------------------------------
-- Reject Manual Ownership Transfer
---------------------------------------------------

function LootCouncil.Session:RejectManualOwnershipTransfer()

    pendingManualOwnershipTransfer = nil

end

---------------------------------------------------
-- Manual Ownership Transfer
---------------------------------------------------

function LootCouncil.Session:TransferOwnership(newOwner)

    if not session then
        return false
    end

    ---------------------------------------------------
    -- Current Owner Only
    ---------------------------------------------------

    if self:GetOwner() ~= UnitName("player") then
        return false
    end

    if not newOwner or newOwner == "" then
        return false
    end

    ---------------------------------------------------
    -- Verify Player Is In Raid
    ---------------------------------------------------

    local found = false

    for i = 1, GetNumRaidMembers() do

        local name =
            GetRaidRosterInfo(i)

        if string.lower(name) ==
            string.lower(newOwner) then

            newOwner = name

            found = true

            break

        end

    end

    if not found then
        return false
    end

    ---------------------------------------------------
    -- Pending Manual Transfer
    ---------------------------------------------------

    pendingManualOwnershipTransfer =
        newOwner

    ---------------------------------------------------
    -- Show Confirmation
    ---------------------------------------------------

    StaticPopup_Show(
        "LOOTCOUNCIL_MANUAL_OWNERSHIP_TRANSFER",
        newOwner
    )

    return true

end

---------------------------------------------------
-- Owner Presence
---------------------------------------------------

function LootCouncil.Session:IsOwnerPresent()

    if not session then
        return false
    end

    local owner =
        self:GetOwner()

    if not owner then
        return false
    end

    local numRaid =
        GetNumRaidMembers()

    if numRaid == 0 then
        return false
    end

    for i = 1, numRaid do

        local name =
            GetRaidRosterInfo(i)

        if name == owner then
            return true
        end

    end

    return false

end

function LootCouncil.Session:Serialize()
    if not session then
        return {
            active = false,
            id = nil,
            owner = nil,
            players = {},
            items = {},
            selectedItem = nil,
            nextItemNumber = nil,
        }
    end

    -- Prepare roll data for saving (store item number, not the full item object)
    local activeRoll = LootCouncil.Roll:GetActiveRoll()
    local rollData = nil
    if activeRoll then
        rollData = {
            itemNumber = activeRoll.item and activeRoll.item:GetNumber() or nil,
            rollType = activeRoll.rollType,
            isActive = activeRoll.isActive,
            isClosed = activeRoll.isClosed,
            rolls = activeRoll.rolls,
            startTime = activeRoll.startTime,
            winner = activeRoll.winner,
            timerStarted = activeRoll.timerStarted,
            remainingTime = activeRoll.remainingTime,
        }
    end

    return {
        active = true,
        id = session.id,
        owner = self:GetOwner(),
        players = self:SerializePlayers(),
        items = self:SerializeItems(),
        selectedItem = self:GetSelectedIndex(),
        responses = self:SerializeResponses(),
        votes = self:SerializeVotes(),
        gear = self:SerializeGear(),
        nextItemNumber = session.nextItemNumber,
        councilMembers = session.councilMembers or {},
    }
end

function LootCouncil.Session:SerializePlayers()

    local players = {}

    for _, player in ipairs(
        self:GetPlayers()
    ) do

        table.insert(

            players,

            {

                name =
                    player:GetName(),

                class =
                    player:GetClass(),

            }

        )

    end

    return players

end

---------------------------------------------------
-- Role Persistence
---------------------------------------------------

function LootCouncil.Session:SerializeItems()

    local items = {}

    for _, item in ipairs(
        self:GetItems()
    ) do

        table.insert(
            items,
            {

                id =
                    item:GetID(),

                number =
                    item:GetNumber(),

                name =
                    item:GetName(),

                link =
                    item:GetLink(),

                ilvl =
                    item:GetItemLevel(),

                winner =
                    item:GetWinner(),

                awarded =
                    item:IsAwarded(),

            }
        )

    end

    return items

end

function LootCouncil.Session:SerializeResponses()

    local responses = {}

    for itemIndex, item in ipairs(
        self:GetItems()
    ) do

        responses[itemIndex] = {}

        for _, applicant in ipairs(
            item:GetApplicants()
        ) do

            responses[itemIndex][
                applicant:GetPlayer():GetName()
            ] = applicant:GetResponse()

        end

    end

    return responses

end

---------------------------------------------------
-- Vote Persistence
---------------------------------------------------

function LootCouncil.Session:SerializeVotes()

    local votes = {}

    for itemIndex, item in ipairs(
        self:GetItems()
    ) do

        votes[itemIndex] = {}

        for _, applicant in ipairs(
            item:GetApplicants()
        ) do

            votes[itemIndex][
                applicant:GetPlayer():GetName()
            ] = {}

            for _, voter in ipairs(
                applicant:GetVotes()
            ) do

                table.insert(

                    votes[itemIndex][
                        applicant:GetPlayer():GetName()
                    ],

                    voter

                )

            end

        end

    end

    return votes

end

---------------------------------------------------
-- Deserialize Votes
---------------------------------------------------

function LootCouncil.Session:DeserializeVotes(data)

    if not data then
        return
    end

    for itemIndex, itemVotes in pairs(data) do

        local item =
            self:GetItem(itemIndex)

        if item then

            for playerName, voters in pairs(itemVotes) do

                local player =
                    self:FindPlayer(playerName)

                if player then

                    local applicant =
                        item:FindApplicant(player)

                    if applicant then

                        for _, voter in ipairs(voters) do

                            applicant:AddVote(
                                voter
                            )

                        end

                    end

                end

            end

        end

    end

end

---------------------------------------------------
-- Gear Persistence
---------------------------------------------------

function LootCouncil.Session:SerializeGear()

    local gear = {}

    for itemIndex, item in ipairs(
        self:GetItems()
    ) do

        gear[itemIndex] = {}

        for _, applicant in ipairs(
            item:GetApplicants()
        ) do

            local playerName =
                applicant:GetPlayer():GetName()

            gear[itemIndex][playerName] = {}

            for slotID, slotGear in pairs(
                applicant.gear
            ) do

                gear[itemIndex][playerName][slotID] = {

                    itemID =
                        slotGear.itemID,

                    link =
                        slotGear.link,

                }

            end

        end

    end

    return gear

end

---------------------------------------------------
-- Deserialize Gear
---------------------------------------------------

function LootCouncil.Session:DeserializeGear(data)

    if not data then
        return
    end

    for itemIndex, itemGear in pairs(data) do

        local item =
            self:GetItem(itemIndex)

        if item then

            for playerName, gearData in pairs(itemGear) do

                local player =
                    self:FindPlayer(playerName)

                if player then

                    local applicant =
                        item:FindApplicant(player)

                    if applicant then

                        applicant.gear = {}

                        for slotID, slotGear in pairs(
                            gearData
                        ) do

                            applicant.gear[slotID] = {

                                itemID =
                                    slotGear.itemID,

                                link =
                                    slotGear.link,

                            }

                        end

                    end

                end

            end

        end

    end

end

---------------------------------------------------
-- Deserialize Roles
---------------------------------------------------

---------------------------------------------------
-- Loading
---------------------------------------------------

function LootCouncil.Session:Deserialize(data)

    if not data then
        return
    end

    if not data.active then
        return
    end

    ---------------------------------------------------
    -- Create Session
    ---------------------------------------------------

    self:Create(
        true,
        data.id
    )

    if data.nextItemNumber then

        session.nextItemNumber =
            data.nextItemNumber

    end

    if data.owner then

        self:SetOwner(
            data.owner
        )

    end

    ---------------------------------------------------
    -- Restore Players
    ---------------------------------------------------

    if data.players then

        for _, playerData in ipairs(data.players) do

            local playerName
            local playerClass

            ---------------------------------------------------
            -- New Format
            ---------------------------------------------------

            if type(playerData) == "table" then

                playerName =
                    playerData.name

                playerClass =
                    playerData.class

            ---------------------------------------------------
            -- Legacy Format
            ---------------------------------------------------

            else

                playerName =
                    playerData

                playerClass =
                    "UNKNOWN"

            end

            if playerName then

                local player =
                    LootCouncil.Player:New(

                        playerName,

                        playerClass

                    )

                self:AddPlayer(player)

            end

        end

    end

    ---------------------------------------------------
    -- Restore Council Members
    ---------------------------------------------------

    if data.councilMembers then
        session.councilMembers = data.councilMembers
    else
        session.councilMembers = {}
    end

    ---------------------------------------------------
    -- Refresh UI After Restoring Council
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.UI.SettingsTab:Refresh()

    ---------------------------------------------------
    -- Restore Items
    ---------------------------------------------------

    if data.items then

        for _, itemData in ipairs(data.items) do

            local item =
                LootCouncil.LootItem:New(
                    itemData
                )

            ---------------------------------------------------
            -- Restore Award Information
            ---------------------------------------------------

            if itemData.winner then

                item:SetWinner(
                    itemData.winner
                )

            end

            if itemData.awarded then

                item:SetAwarded(
                    itemData.awarded
                )

            end

            self:AddRestoredItem(item)

        end

    end

    ---------------------------------------------------
    -- Restore Applicants
    ---------------------------------------------------

    for _, item in ipairs(self:GetItems()) do

        self:InitializeApplicants(item)

    end

    ---------------------------------------------------
    -- Restore Responses
    ---------------------------------------------------

    self:DeserializeResponses(
        data.responses
    )

    self:DeserializeVotes(
        data.votes
    )

    self:DeserializeGear(
        data.gear
    )
    ---------------------------------------------------
    -- Restore Selected Item
    ---------------------------------------------------

    if data.selectedItem then

        self:SetSelectedIndex(
            data.selectedItem
        )

    end

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    ---------------------------------------------------
    -- Update Persistence
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

end

function LootCouncil.Session:DeserializeResponses(data)

    if not data then
        return
    end

    for itemIndex, itemResponses in pairs(data) do

        local item = self:GetItem(itemIndex)

        if item then

            for playerName, response in pairs(itemResponses) do

                local player =
                    self:FindPlayer(playerName)

                if player then

                    local applicant =
                        item:FindApplicant(player)

                    if applicant then

                        applicant:SetResponse(response)

                    end

                end

            end

        end

    end

end

function LootCouncil.Session:Get()

    return session

end

---------------------------------------------------
-- Session ID
---------------------------------------------------

function LootCouncil.Session:GetID()

    if not session then
        return nil
    end

    return session.id

end

---------------------------------------------------
-- Owner
---------------------------------------------------

function LootCouncil.Session:GetOwner()

    if not session then
        return nil
    end

    return session.owner

end

function LootCouncil.Session:SetOwner(name)

    if not session then
        return
    end

    session.owner = name

end

function LootCouncil.Session:IsOwner()

    return self:GetOwner() == UnitName("player")

end

---------------------------------------------------
-- Permissions
---------------------------------------------------

function LootCouncil.Session:CanAcceptResponses()

    return self:IsOwner()

end

---------------------------------------------------
-- Lifecycle
---------------------------------------------------

function LootCouncil.Session:Create(
    restoring,
    sessionID
)

    if session then
        return
    end

    session = {

        id = sessionID,

        started = time(),

        owner = UnitName("player"),

        players = {},

        roles = {},

        items = {},

        selectedItem = nil,

        nextItemNumber = 1,

        councilMembers = {},

    }

    if not restoring then

        session.id =
            LootCouncil.Persistence:GetNextSessionID()

    end

end

---------------------------------------------------
-- Begin
---------------------------------------------------

function LootCouncil.Session:Begin(
    owner,
    roles
)

    self:Create()

    if owner then

        self:SetOwner(owner)

    end

    self:Start()

    ---------------------------------------------------
    -- Persist Authoritative State
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    LootCouncil.UI:Show()

end

---------------------------------------------------
-- Start
---------------------------------------------------

function LootCouncil.Session:Start()
    if not session then
        return
    end

    ---------------------------------------------------
    -- Build Roster
    ---------------------------------------------------

    LootCouncil.Roster:Refresh()

    ---------------------------------------------------
    -- Copy Roster Into Session
    ---------------------------------------------------

    self:ClearPlayers()

    for _, player in ipairs(
        LootCouncil.Roster:GetPlayers()
    ) do

        self:AddPlayer(player)

    end

    ---------------------------------------------------
    -- Ensure the owner is in the council roster
    ---------------------------------------------------

    -- Ensure the owner is in the council roster
    local owner = self:GetOwner()
    if owner then
        if not session.councilMembers then
            session.councilMembers = {}
        end
    
    -- Check if owner is already in the list
        local ownerInList = false
        for _, name in ipairs(session.councilMembers) do
            if name == owner then
                ownerInList = true
                break
            end
        end
    
        if not ownerInList then
            table.insert(session.councilMembers, owner)
        end
    end

    ---------------------------------------------------
    -- Initialize Roles
    ---------------------------------------------------

    self:BroadcastState()

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.UI.NavigationTabManager:Refresh()

    LootCouncil.Persistence:Save()

    -- Show role assignment reminder to the owner
    if self:IsOwner() then
        StaticPopup_Show("LOOTCOUNCIL_ASSIGN_ROLES")
    end
end

---------------------------------------------------
-- End
---------------------------------------------------

function LootCouncil.Session:End(remote)

    if not session then
        return false
    end

    ---------------------------------------------------
    -- Only Session Owner Can End Locally
    ---------------------------------------------------

    if not remote
    and not self:IsOwner() then

        LootCouncil:Print(
            "Only the session owner can end the session."
        )

        return false

    end

    ---------------------------------------------------
    -- End Session
    ---------------------------------------------------

    session = nil

    LootCouncil:Print(
        "Session ended."
    )

    LootCouncil.Persistence:Save()

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    return true

end

function LootCouncil.Session:Toggle()

    if self:IsActive() then
        self:Destroy()
    else
        self:Create()
    end

end

---------------------------------------------------
-- Players
---------------------------------------------------

function LootCouncil.Session:AddPlayer(player)

    if not session then
        return
    end

    table.insert(
        session.players,
        player
    )

end

function LootCouncil.Session:FindPlayer(name)

    if not session then
        return nil
    end

    for _, player in ipairs(session.players) do

        if player:GetName() == name then
            return player
        end

    end

    return nil

end

function LootCouncil.Session:GetPlayers()

    if not session then
        return {}
    end

    return session.players

end

function LootCouncil.Session:GetPlayer(name)

    if not session then
        return nil
    end

    for _, player in ipairs(session.players) do

        if string.lower(player:GetName()) ==
            string.lower(name) then

            return player

        end

    end

    return nil

end

function LootCouncil.Session:HasPlayer(name)

    return self:GetPlayer(name) ~= nil

end

---------------------------------------------------
-- Get Council Members
---------------------------------------------------

function LootCouncil.Session:GetCouncilMembers()
    if not session then
        return {}
    end
    return session.councilMembers or {}
end

function LootCouncil.Session:ClearPlayers()

    if not session then
        return
    end

    session.players = {}

end

---------------------------------------------------
-- Initialize Roles
---------------------------------------------------

---------------------------------------------------
-- Get Role
---------------------------------------------------

function LootCouncil.Session:GetRole(playerName)
    -- Roles are temporarily disabled. Everyone is RAIDER.
    return LootCouncil.Permissions.Role.RAIDER
end

---------------------------------------------------
-- Get Roles
---------------------------------------------------

function LootCouncil.Session:GetRoles()
    -- Roles are temporarily disabled
    return {}
end

---------------------------------------------------
-- Council Check
---------------------------------------------------

function LootCouncil.Session:IsCouncil(playerName)
    if not session then
        return false
    end
    
    -- Owner is always council
    if playerName == self:GetOwner() then
        return true
    end
    
    if not session.councilMembers then
        return false
    end
    
    for _, name in ipairs(session.councilMembers) do
        if name == playerName then
            return true
        end
    end
    return false
end

---------------------------------------------------
-- Council Management
---------------------------------------------------

function LootCouncil.Session:AddCouncilMember(playerName)
    if not session then
        LootCouncil:Print("No active session.")
        return false
    end
    
    if not playerName or playerName == "" then
        return false
    end
    
    if not session.councilMembers then
        session.councilMembers = {}
    end
    
    if self:IsCouncil(playerName) then
        LootCouncil:Print(playerName .. " is already council.")
        return false
    end
    
    table.insert(session.councilMembers, playerName)
    LootCouncil.Persistence:Save()
    self:BroadcastCouncilRoster()
    LootCouncil:Print(playerName .. " is now council.")
    return true
end

function LootCouncil.Session:RemoveCouncilMember(playerName)
    if not session then
        LootCouncil:Print("No active session.")
        return false
    end
    
    if not playerName or playerName == "" then
        return false
    end
    
    -- Owner cannot be removed
    if playerName == self:GetOwner() then
        LootCouncil:Print("Cannot remove the session owner from council.")
        return false
    end
    
    if not session.councilMembers then
        return false
    end
    
    for i, name in ipairs(session.councilMembers) do
        if name == playerName then
            table.remove(session.councilMembers, i)
            LootCouncil.Persistence:Save()
            self:BroadcastCouncilRoster()
            LootCouncil:Print(playerName .. " is no longer council.")
            return true
        end
    end
    
    LootCouncil:Print(playerName .. " is not council.")
    return false
end

---------------------------------------------------
-- Broadcast Council Roster
---------------------------------------------------

function LootCouncil.Session:BroadcastCouncilRoster()
    if not session then
        return
    end
    
    local message = LootCouncil.Message:New(
        "COUNCIL_ROSTER_UPDATE",
        {
            councilMembers = session.councilMembers or {},
        }
    )
    LootCouncil.MessageBus:Route(message, UnitName("player"))
end

---------------------------------------------------
-- Receive Council Roster Update
---------------------------------------------------

function LootCouncil.Session:OnCouncilRosterUpdate(message, sender)
    local payload = message:GetPayload()
    if not payload or not payload.councilMembers then
        return
    end
    
    if not session then
        return
    end
    
    -- Update the local council roster
    session.councilMembers = payload.councilMembers

    LootCouncil.Persistence:Save()
    
    -- Refresh UI
    LootCouncil.UI.TabManager:Refresh()
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.UI.SettingsTab:Refresh()
end

---------------------------------------------------
-- Loot Items
---------------------------------------------------

function LootCouncil.Session:AddItem(data)

    if not session then
        return
    end

    local item =
        LootCouncil.Loot:CreateItem(data)

    if not item then
        return
    end

    ---------------------------------------------------
    -- Assign Static Session Number
    ---------------------------------------------------

    item:SetNumber(
        session.nextItemNumber
    )

    session.nextItemNumber =
        session.nextItemNumber + 1

    ---------------------------------------------------
    -- Add Item
    ---------------------------------------------------

    table.insert(
        session.items,
        item
    )

    LootCouncil.Persistence:Save()

    self:InitializeApplicants(item)

    if self:IsOwner() then

        local itemIndex =
            #session.items

        local comparisonSlots =
            LootCouncil.Comparison:GetComparisonSlots(
                item
            )

        for _, applicant in ipairs(
            item:GetApplicants()
        ) do

            local playerName =
                applicant:GetPlayer():GetName()

            local message =
                LootCouncil.Message:New(
                    "GEAR_REQUEST",
                    {
                        target = playerName,

                        itemIndex =
                            itemIndex,

                        slots =
                            comparisonSlots,
                    }
                )

            LootCouncil.MessageBus:Route(
                message,
                UnitName("player")
            )

        end

    end

    if not session.selectedItem then

        session.selectedItem = 1

    end

    -- Only the session owner announces the item
    if self:IsOwner() then
        -- Send raid warning with item number and link
        local msg = string.format(
            "Item #%d added: %s",
            item:GetNumber(),
            item:GetLink()
        )
        SendChatMessage(msg, "RAID")
        
        -- Auto-show the main window
        LootCouncil.UI:Show()
    end

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.UI.LootTab:Refresh()

    return item

end

function LootCouncil.Session:AddRestoredItem(item)

    if not session then
        return
    end

    ---------------------------------------------------
    -- Restore Item Metadata
    ---------------------------------------------------

    item:SetMetadata(

        LootCouncil.Loot:GetItemMetadata(
            item:GetID()
        )

    )

    ---------------------------------------------------
    -- Legacy Number Support
    ---------------------------------------------------

    if not item:GetNumber() then

        item:SetNumber(
            session.nextItemNumber
        )

        session.nextItemNumber =
            session.nextItemNumber + 1

    elseif item:GetNumber()
    >= session.nextItemNumber then

        session.nextItemNumber =
            item:GetNumber() + 1

    end

    table.insert(
        session.items,
        item
    )

    return item

end

function LootCouncil.Session:GetItems()

    if not session then
        return {}
    end

    return session.items

end

function LootCouncil.Session:GetItem(index)

    if not session then
        return nil
    end

    return session.items[index]

end

---------------------------------------------------
-- Get Item By Number
---------------------------------------------------

function LootCouncil.Session:GetItemByNumber(number)

    if not session then
        return nil
    end

    if not number then
        return nil
    end

    number = tonumber(number)

    if not number then
        return nil
    end

    for _, item in ipairs(
        session.items
    ) do

        if item:GetNumber() == number then

            return item

        end

    end

    return nil

end

---------------------------------------------------
-- Remove Item
---------------------------------------------------

function LootCouncil.Session:RemoveItem(number)

    if not session then
        return false
    end

    local item =
        self:GetItemByNumber(number)

    if not item then
        return false
    end

    ---------------------------------------------------
    -- Find Current Array Index
    ---------------------------------------------------

    local index

    for currentIndex, currentItem in ipairs(
        session.items
    ) do

        if currentItem == item then

            index = currentIndex

            break

        end

    end

    if not index then
        return false
    end

    ---------------------------------------------------
    -- Remove Item
    ---------------------------------------------------

    table.remove(
        session.items,
        index
    )

    ---------------------------------------------------
    -- Selected Item
    ---------------------------------------------------

    if #session.items == 0 then

        session.selectedItem = nil

    elseif session.selectedItem == index then

        if index > #session.items then

            session.selectedItem =
                #session.items

        else

            session.selectedItem =
                index

        end

    elseif session.selectedItem > index then

        session.selectedItem =
            session.selectedItem - 1

    end

    ---------------------------------------------------
    -- Save
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.UI.LootTab:Refresh()

    return true

end

---------------------------------------------------
-- Submit Applicant Response
---------------------------------------------------

function LootCouncil.Session:SubmitApplicantResponse(

    playerName,

    itemIndex,

    response

)

    ---------------------------------------------------
    -- Apply Locally
    ---------------------------------------------------

    local outcome =

        self:SetApplicantResponse(

            playerName,

            itemIndex,

            response

        )

    if not outcome then
        return nil
    end

    ---------------------------------------------------
    -- Save Session
    ---------------------------------------------------

    if outcome == "RECORDED"
    or outcome == "CHANGED" then

        LootCouncil.Persistence:Save()

    end

    ---------------------------------------------------
    -- Build Message
    ---------------------------------------------------

    local message = LootCouncil.Message:New(

        "RESPONSE",

        {

            player = playerName,

            itemIndex = itemIndex,

            response = response

        }

    )

    ---------------------------------------------------
    -- Route
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    return outcome

end

function LootCouncil.Session:SubmitAward(

    playerName,

    itemIndex

)

    ---------------------------------------------------
    -- Get Item
    ---------------------------------------------------

    local item =
        self:GetItem(itemIndex)

    if not item then
        return nil
    end

    ---------------------------------------------------
    -- Get Applicant Response
    ---------------------------------------------------

    local applicant =
        item:FindApplicant(
            playerName
        )

    local response =
        "UNKNOWN"

    if applicant then

        response =
            applicant:GetResponse()

    end

    ---------------------------------------------------
    -- Apply Locally
    ---------------------------------------------------

    local outcome =

        self:SetAward(

            playerName,

            itemIndex

        )

    if not outcome then
        return nil
    end

    ---------------------------------------------------
    -- Save Session
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    ---------------------------------------------------
    -- Announce Award
    ---------------------------------------------------

    SendChatMessage(

        item:GetLink() ..
        " was awarded to " ..
        playerName ..
        " for " ..
        response,

        "RAID_WARNING"

    )

    ---------------------------------------------------
    -- Build Message
    ---------------------------------------------------

    local message = LootCouncil.Message:New(

        "AWARD",

        {

            player = playerName,

            itemIndex = itemIndex,

        }

    )

    ---------------------------------------------------
    -- Route
    ---------------------------------------------------

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    return outcome

end

function LootCouncil.Session:SetApplicantResponse(
    playerName,
    itemIndex,
    response
)

    local item = self:GetItem(itemIndex)

    if not item then
        return false
    end

    local player = self:GetPlayer(playerName)

    if not player then
        return false
    end

    local applicant = item:FindApplicant(player)

    if not applicant then
        return false
    end

    local previousResponse =
        applicant:GetResponse()

    applicant:SetResponse(response)

    LootCouncil.UI.VotingTab:Refresh()

    if previousResponse ==
        LootCouncil.Constants.Response.PENDING then

        return "RECORDED"

    end

    if previousResponse == response then

        return "UNCHANGED"

    end

    return "CHANGED"

end

function LootCouncil.Session:SetAward(
    playerName,
    itemIndex
)

    local item =
        self:GetItem(itemIndex)

    if not item then
        return nil
    end

    ---------------------------------------------------
    -- Prevent Duplicate History
    ---------------------------------------------------

    local wasAwarded =
        item:IsAwarded()

    ---------------------------------------------------
    -- Apply Award
    ---------------------------------------------------

    item:Award(
        playerName
    )

    ---------------------------------------------------
    -- Record History
    ---------------------------------------------------

    if not wasAwarded
    and self:IsOwner() then

        LootCouncil.History:Add(

            time(),

            self:GetID(),

            item:GetLink(),

            playerName

        )

    end

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    return true

end

function LootCouncil.Session:SetVote(

    councilMember,

    playerName,

    itemIndex

)

    local item = self:GetItem(itemIndex)

    if not item then
        return nil
    end

    local applicant =
        item:FindApplicant(playerName)

    if not applicant then
        return nil
    end

    local added =
        applicant:AddVote(councilMember)

    if added then
        LootCouncil.UI.TabManager:Refresh()
    end

    return added

end

function LootCouncil.Session:ToggleVote(

    councilMember,

    playerName,

    itemIndex

)

    local item =
        self:GetItem(itemIndex)

    if not item then
        return nil
    end

    local applicant =
        item:FindApplicant(playerName)

    if not applicant then
        return nil
    end

    ---------------------------------------------------
    -- Check Existing Vote
    ---------------------------------------------------

    for _, voter in ipairs(
        applicant:GetVotes()
    ) do

        if voter == councilMember then

            local removed =
                applicant:RemoveVote(
                    councilMember
                )

            if not removed then
                return nil
            end

            ---------------------------------------------------
            -- Save Persistence
            ---------------------------------------------------

            LootCouncil.Persistence:Save()

            ---------------------------------------------------
            -- Refresh Local UI
            ---------------------------------------------------

            LootCouncil.UI.TabManager:Refresh()

            ---------------------------------------------------
            -- Broadcast Vote Removal
            ---------------------------------------------------

            local message =
                LootCouncil.Message:New(

                    "VOTE",

                    {

                        councilMember = councilMember,

                        player = playerName,

                        itemIndex = itemIndex,

                        action = "REMOVE",

                    }

                )

            LootCouncil.MessageBus:Route(

                message,

                UnitName("player")

            )

            return false

        end

    end

    ---------------------------------------------------
    -- Add Vote
    ---------------------------------------------------

    local added =
        applicant:AddVote(
            councilMember
        )

    if not added then
        return nil
    end

    ---------------------------------------------------
    -- Save Persistence
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    ---------------------------------------------------
    -- Refresh Local UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    ---------------------------------------------------
    -- Broadcast Vote Addition
    ---------------------------------------------------

    local message =
        LootCouncil.Message:New(

            "VOTE",

            {

                councilMember = councilMember,

                player = playerName,

                itemIndex = itemIndex,

                action = "ADD",

            }

        )

    LootCouncil.MessageBus:Route(

        message,

        UnitName("player")

    )

    return true

end

---------------------------------------------------
-- Selected Item
---------------------------------------------------

function LootCouncil.Session:GetSelectedIndex()

    if not session then
        return nil
    end

    return session.selectedItem

end

function LootCouncil.Session:SetSelectedIndex(index)

    if not session then
        return
    end

    if not index then
        session.selectedItem = nil
        return
    end

    if index < 1 or index > #session.items then
        return
    end

    session.selectedItem = index

end

function LootCouncil.Session:GetSelectedItem()

    if not session then
        return nil
    end

    if not session.selectedItem then
        return nil
    end

    return session.items[session.selectedItem]

end

---------------------------------------------------
-- Loading
---------------------------------------------------

function LootCouncil.Session:Load(data)

    ---------------------------------------------------
    -- Loot Items
    ---------------------------------------------------

    for _, itemData in ipairs(data.Items) do

        self:AddItem(itemData)

        local item = session.items[#session.items]

        if itemData.applicants then

        for _, applicantData in ipairs(itemData.applicants) do

            for _, player in ipairs(session.players) do

                if player:GetName() == applicantData.player then

local applicant = item:AddApplicant(player)

applicant:SetResponse(
    applicantData.response
)

                    break

                end

            end

        end

    end

end

    LootCouncil.UI.TabManager:Refresh()

end

---------------------------------------------------
-- Applicant Initialization
---------------------------------------------------

function LootCouncil.Session:InitializeApplicants(item)

    if not session then
        return
    end

    if not item then
        return
    end

    for _, player in ipairs(session.players) do

        local applicant =
            item:AddApplicant(player)

        if applicant then

            local playerClass =
                player:GetClass()

            local canEquip =
                LootCouncil.Equipability:CanEquip(
                    playerClass,
                    item
                )

            if not canEquip then

                applicant:SetResponse(
                    LootCouncil.Constants.Response.AUTO_PASS
                )

            end

        end

    end

end

---------------------------------------------------
-- Message Handlers
---------------------------------------------------

---------------------------------------------------
-- START Message
---------------------------------------------------

function LootCouncil.Session:OnStartMessage(

    message,

    sender

)

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    self:Begin(
        payload.owner,
        payload.roles
    )

end

---------------------------------------------------

function LootCouncil.Session:OnEndMessage(

    message,

    sender

)

    ---------------------------------------------------
    -- Apply Authoritative Session End
    ---------------------------------------------------

    if not self:IsActive() then
        return
    end

    self:End(true)

end

---------------------------------------------------
-- SESSION_OWNER_CHANGED Message
---------------------------------------------------

function LootCouncil.Session:OnOwnerChangedMessage(

    message,

    sender

)

    if not self:IsActive() then
        return
    end

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    local newOwner =
        payload.owner

    local reason =
        payload.reason

    if not newOwner then
        return
    end

    ---------------------------------------------------
    -- Authority
    ---------------------------------------------------

    if reason == "TRANSFER" then

        if sender ~= self:GetOwner() then

            LootCouncil:Print(
                "Rejected ownership change from " ..
                tostring(sender)
            )

            return

        end

    elseif reason == "FALLBACK" then

        if sender ~= self:GetRaidLeader() then

            LootCouncil:Print(
                "Rejected ownership fallback from " ..
                tostring(sender)
            )

            return

        end

        if self:IsOwnerPresent() then

            LootCouncil:Print(
                "Rejected ownership fallback: owner is still present."
            )

            return

        end

    else

        LootCouncil:Print(
            "Rejected ownership change: invalid reason."
        )

        return

    end

    ---------------------------------------------------
    -- Apply
    ---------------------------------------------------

    self:SetOwner(
        newOwner
    )

    if reason == "FALLBACK"
    and newOwner == UnitName("player") then

        LootCouncil:Print(
            "You are now the session owner because the previous owner left."
        )

    end

    pendingOwnershipTransfer = nil

    ---------------------------------------------------
    -- Persist
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

end

---------------------------------------------------

function LootCouncil.Session:OnAddItemMessage(

    message,

    sender

)

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    local data =
        LootCouncil.Loot:CreateItemData(

            tostring(payload.itemID)

        )

    if not data then

        LootCouncil:Print(
            "Unable to create item data."
        )

        return

    end

    self:AddItem(data)

end

---------------------------------------------------
-- Remove Item Message
---------------------------------------------------

function LootCouncil.Session:OnRemoveItemMessage(

    message,

    sender

)

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    local number =
        payload.number

    if not number then
        return
    end

    self:RemoveItem(
        number
    )

end

---------------------------------------------------
-- Raid Leadership Changed
---------------------------------------------------

function LootCouncil.Session:OnRaidLeaderChanged()

    if not self:IsActive() then
        return
    end

    local raidLeader =
        self:GetRaidLeader()

    local owner =
        self:GetOwner()

    if not raidLeader then
        return
    end

    ---------------------------------------------------
    -- Owner Is Already Raid Leader
    ---------------------------------------------------

    if raidLeader == owner then
        return
    end

    ---------------------------------------------------
    -- Only Owner Decides
    ---------------------------------------------------

    if owner ~= UnitName("player") then
        return
    end

    ---------------------------------------------------
    -- Pending Transfer
    ---------------------------------------------------

    pendingOwnershipTransfer =
        raidLeader

    StaticPopup_Show(
        "LOOTCOUNCIL_OWNERSHIP_TRANSFER",
        raidLeader
    )

end

---------------------------------------------------
-- GEAR_REQUEST Message
---------------------------------------------------

local function EncodeGearLink(link)

    if not link then
        return nil
    end

    local encoded = {}

    for i = 1, string.len(link) do

        encoded[i] =
            string.format(
                "%02X",
                string.byte(link, i)
            )

    end

    return table.concat(encoded)

end

local function DecodeGearLink(encoded)

    if not encoded then
        return nil
    end

    local decoded = {}

    for i = 1, string.len(encoded), 2 do

        local byte =
            tonumber(
                string.sub(
                    encoded,
                    i,
                    i + 1
                ),
                16
            )

        if not byte then
            return nil
        end

        decoded[#decoded + 1] =
            string.char(byte)

    end

    return table.concat(decoded)

end

function LootCouncil.Session:OnGearRequestMessage(

    message,

    sender

)

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    if payload.target ~= UnitName("player") then
        return
    end

    local slots = {}

    local items = {}

    local links = {}

    local responseItems = {}

    for _, slotID in ipairs(payload.slots or {}) do

        local itemID =
            GetInventoryItemID(
                "player",
                slotID
            )

        table.insert(
            slots,
            tostring(slotID)
        )

        if itemID then

            items[slotID] = itemID

            ---------------------------------------------------
            -- Encode Live Item Link
            ---------------------------------------------------

            local link =
                GetInventoryItemLink(
                    "player",
                    slotID
                )

            if link then

                links[slotID] =
                    EncodeGearLink(link)

            end

            table.insert(
                responseItems,
                tostring(slotID) ..
                "=" ..
                tostring(itemID)
            )

        else

        end

    end

    local response =

        LootCouncil.Message:New(

            "GEAR_RESPONSE",

            {

                player = UnitName("player"),

                itemIndex = payload.itemIndex,

                slots = payload.slots,

                items = items,

                links = links

            }

        )

    LootCouncil.MessageBus:Route(

        response,

        UnitName("player")

    )

end

---------------------------------------------------
-- GEAR_RESPONSE Message
---------------------------------------------------

function LootCouncil.Session:OnGearResponseMessage(

    message,

    sender

)

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    ---------------------------------------------------
    -- Find Loot Item
    ---------------------------------------------------

    local item =
        self:GetItem(
            payload.itemIndex
        )

    if not item then


        return

    end

    ---------------------------------------------------
    -- Find Applicant
    ---------------------------------------------------

    local applicant =
        item:FindApplicant(
            payload.player
        )

    if not applicant then


        return

    end

    ---------------------------------------------------
    -- Clear Requested Gear
    ---------------------------------------------------

    for _, slotID in ipairs(
        payload.slots or {}
    ) do

        applicant.gear[slotID] = nil

    end

    ---------------------------------------------------
    -- Store Current Gear
    ---------------------------------------------------

    for slotID, itemID in pairs(
        payload.items or {}
    ) do

        applicant.gear[slotID] = {

            itemID = itemID,

            link =
                payload.links and
                DecodeGearLink(
                    payload.links[slotID]
                )    

        }

    end

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.VotingTab:Refresh()

    ---------------------------------------------------
    -- Debug
    ---------------------------------------------------

end

---------------------------------------------------
-- RESPONSE Message
---------------------------------------------------

function LootCouncil.Session:OnResponseMessage(

    message,

    sender

)

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    local outcome =
        self:SetApplicantResponse(

            payload.player,

            payload.itemIndex,

            payload.response

        )

    if not outcome then
        return
    end

    ---------------------------------------------------
    -- Save Persistence
    ---------------------------------------------------

    if outcome == "RECORDED"
    or outcome == "CHANGED" then

        LootCouncil.Persistence:Save()

    end

end

function LootCouncil.Session:OnAwardMessage(

    message,

    sender

)

    local payload =

        message:GetPayload()

    if not payload then
        return
    end

    self:SetAward(

        payload.player,

        payload.itemIndex

    )

end

---------------------------------------------------
-- Initialize
---------------------------------------------------

function LootCouncil.Session:Initialize()

    LootCouncil.MessageBus:Register(

        "START",

        self,

        self.OnStartMessage

    )

    -- LootCouncil.MessageBus:Register(

    --    "SESSION_STATE",

    --   self,

    --    self.OnSessionStateMessage

    --)

    LootCouncil.MessageBus:Register(

        "END",

        self,

        self.OnEndMessage

    )

    LootCouncil.MessageBus:Register(

        "ADD_ITEM",

        self,

        self.OnAddItemMessage

    )

    LootCouncil.MessageBus:Register(

        "GEAR_REQUEST",

        self,

        self.OnGearRequestMessage

    )

    LootCouncil.MessageBus:Register(

        "GEAR_RESPONSE",

        self,

        self.OnGearResponseMessage

    )

    LootCouncil.MessageBus:Register(

        "RESPONSE",

        self,

        self.OnResponseMessage

    )

    LootCouncil.MessageBus:Register(

        "VOTE",

        self,

        self.OnVoteMessage

    )

    LootCouncil.MessageBus:Register(

        "AWARD",

        self,

        self.OnAwardMessage

    )

    LootCouncil.MessageBus:Register(

        "REMOVE_ITEM",

        self,

        self.OnRemoveItemMessage

    )

    LootCouncil.MessageBus:Register(

        "SESSION_OWNER_CHANGED",

        self,

        self.OnOwnerChangedMessage

    )

    LootCouncil.MessageBus:Register(

        "PLAYER_JOINED",

        self,

        self.OnPlayerJoinedMessage

    )

    LootCouncil.MessageBus:Register(
        "COUNCIL_ROSTER_UPDATE",

        self,

        self.OnCouncilRosterUpdate
        
    )

    LootCouncil.MessageBus:Register(
        "REQUEST_RESPONSES",
        self,
        self.OnRequestResponses
    )

    LootCouncil.MessageBus:Register(
        "RESPONSES_DATA",
        self,
        self.OnResponsesData
    )

    LootCouncil.MessageBus:Register(
        "REQUEST_VOTES",
        self,
        self.OnRequestVotes
    )

    LootCouncil.MessageBus:Register(
        "VOTES_DATA",
        self,
        self.OnVotesData
    )

    LootCouncil.MessageBus:Register(
        "SYNC_GEAR_REQUEST",
        self,
        self.OnSyncGearRequest
    )

    LootCouncil.MessageBus:Register(
        "SYNC_GEAR_RESPONSE",
        self,
        self.OnSyncGearResponse
    )

    LootCouncil.MessageBus:Register(
        "OWNER_GEAR_REQUEST",
        self,
        self.OnOwnerGearRequest
    )

    LootCouncil.MessageBus:Register(
        "OWNER_GEAR_RESPONSE",
        self,
        self.OnOwnerGearResponse
    )

end

function LootCouncil.Session:OnVoteMessage(

    message,

    sender

)

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    local item =
        self:GetItem(
            payload.itemIndex
        )

    if not item then
        return
    end

    local applicant =
        item:FindApplicant(
            payload.player
        )

    if not applicant then
        return
    end

    ---------------------------------------------------
    -- Apply Vote
    ---------------------------------------------------

    if payload.action == "ADD" then

        applicant:AddVote(
            payload.councilMember
        )

    elseif payload.action == "REMOVE" then

        applicant:RemoveVote(
            payload.councilMember
        )

    else

        return

    end

    ---------------------------------------------------
    -- Save Persistence
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

end

function LootCouncil.Session:OnRequestVotes(message, sender)
    local payload = message:GetPayload()
    if not payload or payload.target ~= UnitName("player") then
        return
    end

    local items = self:GetItems()
    local votes = {}
    
    for _, item in ipairs(items) do
        local itemNumber = item:GetNumber()
        votes[itemNumber] = {}
        
        -- Loop through all applicants for this item
        local applicants = item:GetApplicants()
        for _, applicant in ipairs(applicants) do
            local playerName = applicant:GetPlayer():GetName()
            local voterList = applicant:GetVotes()
            if #voterList > 0 then
                votes[itemNumber][playerName] = voterList
            end
        end
    end

    local response = LootCouncil.Message:New(
        "VOTES_DATA",
        {
            target = sender,
            councilMember = UnitName("player"),
            votes = votes,
        }
    )
    LootCouncil.MessageBus:Route(response, UnitName("player"))
end

function LootCouncil.Session:OnVotesData(message, sender)
    local payload = message:GetPayload()
    if not payload or payload.target ~= UnitName("player") then
        return
    end

    for itemNumber, applicantVotes in pairs(payload.votes) do
        local item = self:GetItemByNumber(itemNumber)
        if item then
            for playerName, voterList in pairs(applicantVotes) do
                local applicant = item:FindApplicant(playerName)
                if applicant then
                    -- Clear existing votes and add the new ones
                    for _, voter in ipairs(voterList) do
                        applicant:AddVote(voter)
                    end
                end
            end
        end
    end

    LootCouncil.UI.VotingTab:Refresh()
end

function LootCouncil.Session:OnRequestResponses(message, sender)
    local payload = message:GetPayload()
    if not payload or payload.target ~= UnitName("player") then
        return
    end

    
    -- Build responses for all items
    local items = self:GetItems()
    local responses = {}
    for _, item in ipairs(items) do
        local applicant = item:FindApplicant(UnitName("player"))
        responses[item:GetNumber()] = applicant and applicant:GetResponse() or "PENDING"
    end
    
    -- Send responses back to the requester
    local response = LootCouncil.Message:New(
        "RESPONSES_DATA",
        {
            target = sender,
            player = UnitName("player"),
            responses = responses,
        }
    )
    LootCouncil.MessageBus:Route(response, UnitName("player"))

end

function LootCouncil.Session:OnResponsesData(message, sender)
    local payload = message:GetPayload()
    if not payload or payload.target ~= UnitName("player") then
        return
    end
    
    for itemNumber, response in pairs(payload.responses) do
        local item = self:GetItemByNumber(itemNumber)
        if item then
            local applicant = item:FindApplicant(payload.player)
            if applicant then
                applicant:SetResponse(response)
            end
        end
    end
    
    LootCouncil.UI.VotingTab:Refresh()
end

function LootCouncil.Session:OnSyncGearRequest(message, sender)
    local payload = message:GetPayload()
    if not payload then
        return
    end

    if payload.target ~= UnitName("player") then
        return
    end

    local items = {}
    local links = {}

    for _, slotID in ipairs(payload.slots or {}) do
        local itemID = GetInventoryItemID("player", slotID)
        if itemID then
            items[slotID] = itemID
            local link = GetInventoryItemLink("player", slotID)
            if link then
                links[slotID] = EncodeGearLink(link)
            end
        end
    end

    local response = LootCouncil.Message:New(
        "SYNC_GEAR_RESPONSE",
        {
            target = sender,
            player = UnitName("player"),
            itemNumber = payload.itemNumber,
            slots = payload.slots,
            items = items,
            links = links,
        }
    )
    LootCouncil.MessageBus:Route(response, UnitName("player"))
end

function LootCouncil.Session:OnSyncGearResponse(message, sender)
    local payload = message:GetPayload()
    if not payload then
        return
    end

    if payload.target and payload.target ~= UnitName("player") then
        return
    end

    local item = self:GetItemByNumber(payload.itemNumber)
    if not item then
        return
    end

    local applicant = item:FindApplicant(payload.player)
    if not applicant then
        return
    end

    -- Clear and store gear
    for _, slotID in ipairs(payload.slots or {}) do
        applicant.gear[slotID] = nil
    end

    for slotID, itemID in pairs(payload.items or {}) do
        applicant.gear[slotID] = {
            itemID = itemID,
            link = payload.links and DecodeGearLink(payload.links[slotID]) or nil,
        }
    end

    -- Force a full UI refresh
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.UI.Widgets.ApplicantList:Refresh(
        LootCouncil.UI.VotingTab.applicantList,
        item:GetApplicants()
    )

end

function LootCouncil.Session:OnOwnerGearRequest(message, sender)
    local payload = message:GetPayload()
    if not payload then
        return
    end

    if payload.target ~= UnitName("player") then
        return
    end

    local items = {}
    local links = {}

    for _, slotID in ipairs(payload.slots or {}) do
        local itemID = GetInventoryItemID("player", slotID)
        if itemID then
            items[slotID] = itemID
            local link = GetInventoryItemLink("player", slotID)
            if link then
                links[slotID] = EncodeGearLink(link)
            end
        end
    end

    local response = LootCouncil.Message:New(
        "OWNER_GEAR_RESPONSE",
        {
            target = sender,
            player = UnitName("player"),
            itemNumber = payload.itemNumber,
            slots = payload.slots,
            items = items,
            links = links,
        }
    )
    LootCouncil.MessageBus:Route(response, UnitName("player"))
    
end

function LootCouncil.Session:OnOwnerGearResponse(message, sender)
    local payload = message:GetPayload()
    if not payload then
        return
    end

    if payload.target and payload.target ~= UnitName("player") then
        return
    end

    local item = self:GetItemByNumber(payload.itemNumber)
    if not item then
        return
    end

    local applicant = item:FindApplicant(payload.player)
    if not applicant then
        return
    end

    for _, slotID in ipairs(payload.slots or {}) do
        applicant.gear[slotID] = nil
    end

    for slotID, itemID in pairs(payload.items or {}) do
        applicant.gear[slotID] = {
            itemID = itemID,
            link = payload.links and DecodeGearLink(payload.links[slotID]) or nil,
        }
    end

    LootCouncil.UI.VotingTab:Refresh()
end

---------------------------------------------------
-- Broadcast Session State
---------------------------------------------------

function LootCouncil.Session:BroadcastState()

    if not session then
        return
    end

    if not self:IsOwner() then
        return
    end

    local message =
        LootCouncil.Message:New(
            "SESSION_STATE",
            {
                owner = self:GetOwner(),
            }
        )

    LootCouncil.MessageBus:Route(
        message,
        UnitName("player")
    )

end

---------------------------------------------------
-- Session State Message
---------------------------------------------------

function LootCouncil.Session:OnPlayerJoinedMessage(message, sender)
    if not self:IsOwner() then
        return
    end
    
    if not self:IsActive() then
        return
    end
    
    local payload = message:GetPayload()
    if not payload or not payload.player then
        return
    end
    
    local playerName = payload.player
    
    -- Check if player is already in the session
    if self:FindPlayer(playerName) then
        return
    end
    
    -- Add the player to the session
    local player = LootCouncil.Player:New(playerName, "UNKNOWN")
    self:AddPlayer(player)
    
    -- Add them as an applicant to all items
    for _, item in ipairs(self:GetItems()) do
        self:InitializeApplicants(item)
    end
    
    -- Save and refresh
    LootCouncil.Persistence:Save()
    LootCouncil.UI.TabManager:Refresh()
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.UI.LootTab:Refresh()
    
    LootCouncil:Print(playerName .. " joined the session")
end

---------------------------------------------------
-- Sync Snapshots
---------------------------------------------------

function LootCouncil.Session:SerializeRaiderSnapshot(requester)
    if not session then
        return nil
    end

    local snapshot = {
        version = 1,
        owner = self:GetOwner(),
        selectedItem = self:GetSelectedIndex(),
        items = {},
        councilMembers = session.councilMembers or {},
    }

        -- Items: minimal data only (stripped for network size)
    for _, item in ipairs(self:GetItems()) do
        table.insert(snapshot.items, {
            number = item:GetNumber(),
            id = item:GetID(),
        })
    end

    return snapshot
end

function LootCouncil.Session:DeserializeRaiderSnapshot(snapshot, requester)
    if not snapshot then
        return false
    end

    -- Clear existing session
    session = nil

    -- Create new session with minimal data
    self:Create(true, "RAIDER_SYNC_" .. time())

    session.owner = snapshot.owner
    session.started = time()
    session.nextItemNumber = #snapshot.items + 1

        -- Restore council roster from snapshot
    session.councilMembers = snapshot.councilMembers or {}

    -- Restore roster from local raid data
    LootCouncil.Roster:Refresh()
    session.players = {}
    for _, player in ipairs(LootCouncil.Roster:GetPlayers()) do
        table.insert(session.players, player)
    end
    
    -- Ensure the requester is in the roster (safety net)
    if requester and not self:FindPlayer(requester) then
        local player = LootCouncil.Player:New(requester, "UNKNOWN")
        table.insert(session.players, player)
    end

    -- NO ROLES — Everyone is equal

    -- Restore items
    session.items = {}
    for _, itemData in ipairs(snapshot.items or {}) do
        local name, link, _, ilvl = GetItemInfo(itemData.id)
        local item = LootCouncil.LootItem:New({
            id = itemData.id,
            number = itemData.number,
            name = name or "Unknown Item",
            link = link or "",
            ilvl = ilvl or 0,
            equipSlot = equipSlot,
        })
        table.insert(session.items, item)
    end

    -- Rebuild applicants from roster
    for _, item in ipairs(session.items) do
        self:InitializeApplicants(item)
    end

    -- Set selected item
    if snapshot.selectedItem then
        self:SetSelectedIndex(snapshot.selectedItem)
    elseif #session.items > 0 then
        self:SetSelectedIndex(1)
    end

    -- Save and refresh
    LootCouncil.Persistence:Save()
    LootCouncil.UI.TabManager:Refresh()
    LootCouncil.UI.VotingTab:Refresh()
    LootCouncil.UI.LootTab:Refresh()

    -- Schedule a UI refresh to load icons
    C_Timer.After(0.5, function()
        LootCouncil.UI.LootTab:Refresh()
        LootCouncil.UI.VotingTab:Refresh()
        LootCouncil.UI.TabManager:Refresh()
    end)

    return true
end