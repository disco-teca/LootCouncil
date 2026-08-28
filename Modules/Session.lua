LootCouncil.Session = {}

local session = nil

---------------------------------------------------
-- State
---------------------------------------------------

function LootCouncil.Session:IsActive()
    return session ~= nil
end

function LootCouncil.Session:Serialize()

    if not session then

        return {

            active = false,

            id = nil,

            owner = nil,

            players = {},

            items = {},

            roles = {},

            selectedItem = nil,

            nextItemNumber = nil,

        }

    end

    return {

        active = true,

        id = session.id,

        owner = self:GetOwner(),

        players =
            self:SerializePlayers(),

        items =
            self:SerializeItems(),

        selectedItem =
            self:GetSelectedIndex(),

        responses =
            self:SerializeResponses(),

        votes =
            self:SerializeVotes(),

        gear =
            self:SerializeGear(),

        roles =
            self:SerializeRoles(),

        nextItemNumber =
            session.nextItemNumber,

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

function LootCouncil.Session:SerializeRoles()

    if not session then
        return {}
    end

    local roles = {}

    for playerName, role in pairs(
        session.roles or {}
    ) do

        roles[playerName] =
            role

    end

    return roles

end

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

function LootCouncil.Session:DeserializeRoles(data)

    if not session then
        return
    end

    session.roles = {}

    if not data then
        return
    end

    for playerName, role in pairs(data) do

        if role ==
            LootCouncil.Permissions.Role.COUNCIL
        or role ==
            LootCouncil.Permissions.Role.RAIDER then

            session.roles[playerName] =
                role

        end

    end

end

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
    -- Restore Roles
    ---------------------------------------------------

    self:DeserializeRoles(
        data.roles
    )

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
    -- Apply Owner Roles
    ---------------------------------------------------

    if roles then

        session.roles = {}

        for playerName, role in pairs(
            roles
        ) do

            session.roles[playerName] =
                role

        end

    end

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
    -- Initialize Roles
    ---------------------------------------------------

    self:InitializeRoles()

    self:BroadcastState()

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.UI.NavigationTabManager:Refresh()

    LootCouncil.Persistence:Save()

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

function LootCouncil.Session:ClearPlayers()

    if not session then
        return
    end

    session.players = {}

end

---------------------------------------------------
-- Initialize Roles
---------------------------------------------------

function LootCouncil.Session:InitializeRoles()

    if not session then
        return
    end

    ---------------------------------------------------
    -- Clear Existing Roles
    ---------------------------------------------------

    session.roles = {}

    ---------------------------------------------------
    -- Initialize From Pre-Session Assignments
    ---------------------------------------------------

    local permissionsDB =
        LootCouncilDB.Permissions

    local players =
        permissionsDB.Players

    for _, player in ipairs(session.players) do

        local playerName =
            player:GetName()

        local role =
            LootCouncil.Permissions.Role.RAIDER

        local permissionPlayer =
            players[playerName]

        if permissionPlayer
        and permissionPlayer.role then

            role =
                permissionPlayer.role

        end

        session.roles[playerName] =
            role

    end

    ---------------------------------------------------
    -- Session Owner Is Always Council
    ---------------------------------------------------

    local owner =
        self:GetOwner()

    if owner then

        session.roles[owner] =
            LootCouncil.Permissions.Role.COUNCIL

        LootCouncil.Permissions:SetRole(
            owner,
            LootCouncil.Permissions.Role.COUNCIL
        )

    end

end

---------------------------------------------------
-- Get Role
---------------------------------------------------

function LootCouncil.Session:GetRole(playerName)

    if not session then
        return nil
    end

    if not session.roles then
        return nil
    end

    return session.roles[playerName]

end

---------------------------------------------------
-- Get Roles
---------------------------------------------------

function LootCouncil.Session:GetRoles()

    if not session then
        return {}
    end

    return session.roles or {}

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

    LootCouncil:Print(
        "Added item: " ..
        item:GetName()
    )

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

        LootCouncil:Print(
            "GEAR_RESPONSE: Item not found. Index: " ..
            tostring(payload.itemIndex)
        )

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

        LootCouncil:Print(
            "GEAR_RESPONSE: Applicant not found: " ..
            tostring(payload.player)
        )

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

    LootCouncil.MessageBus:Register(

        "SESSION_STATE",

        self,

        self.OnSessionStateMessage

    )

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
                roles = self:GetRoles(),
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

function LootCouncil.Session:OnSessionStateMessage(

    message,

    sender

)

    if not session then
        return
    end

    local payload =
        message:GetPayload()

    if not payload then
        return
    end

    ---------------------------------------------------
    -- Authority
    ---------------------------------------------------

    if payload.owner ~= sender then
        return
    end

    if sender ~= self:GetOwner() then
        return
    end

    ---------------------------------------------------
    -- Apply Owner Roles
    ---------------------------------------------------

    if payload.roles then

        session.roles = {}

        for playerName, role in pairs(
            payload.roles
        ) do

            session.roles[playerName] =
                role

        end

    end

    ---------------------------------------------------
    -- Persist Corrected Session
    ---------------------------------------------------

    LootCouncil.Persistence:Save()

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.NavigationTabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.UI.SettingsTab:Refresh()

end