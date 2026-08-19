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

            players = {},

            items = {},

            selectedItem = nil,

        }

    end

    return {

        active = true,

        players = self:SerializePlayers(),

        items = self:SerializeItems(),

        selectedItem = self:GetSelectedIndex(),

        responses = self:SerializeResponses(),

    }

end

function LootCouncil.Session:SerializePlayers()

    local players = {}

    for _, player in ipairs(self:GetPlayers()) do

        table.insert(

            players,

            player:GetName()

        )

    end

    return players

end

function LootCouncil.Session:SerializeItems()

    local items = {}

    for _, item in ipairs(self:GetItems()) do

        table.insert(

            items,

            {

                id = item:GetID(),

                name = item:GetName(),

                link = item:GetLink(),

                ilvl = item:GetItemLevel(),

                winner = item:GetWinner(),

                awarded = item:IsAwarded(),

            }

        )

    end

    return items

end

function LootCouncil.Session:SerializeResponses()

    local responses = {}

    for itemIndex, item in ipairs(self:GetItems()) do

        responses[itemIndex] = {}

        for _, applicant in ipairs(item:GetApplicants()) do

            responses[itemIndex][

                applicant:GetPlayer():GetName()

            ] = applicant:GetResponse()

        end

    end

    return responses

end

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

    self:Create(true)

    ---------------------------------------------------
    -- Restore Players
    ---------------------------------------------------

    if data.players then

        for _, playerName in ipairs(data.players) do

            local player =
                LootCouncil.Player:New(
                    playerName
                )

            self:AddPlayer(player)

        end

    end

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

    self:DeserializeResponses(data.responses)

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

function LootCouncil.Session:Create(restoring)

    if session then
        return
    end

    session = {

        started = time(),

        owner = UnitName("player"),

        players = {},

        items = {},

        selectedItem = nil,

    }

    if not restoring then

    end

end

---------------------------------------------------
-- Begin
---------------------------------------------------

function LootCouncil.Session:Begin(owner)

    self:Create()

    if owner then

        self:SetOwner(owner)

    end

    self:Start()

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
    -- Queue Inspections
    ---------------------------------------------------

    if self:IsOwner() then

        LootCouncil:Print(
            "I am the session owner."
        )

        for _, player in ipairs(self:GetPlayers()) do

            LootCouncil.Inspect:QueuePlayer(
                player:GetName()
            )

        end

    else

        LootCouncil:Print(
            "Not session owner. Skipping inspection queue."
        )

    end

    ---------------------------------------------------
    -- Refresh UI
    ---------------------------------------------------

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

    LootCouncil.Persistence:Save()

end

---------------------------------------------------
-- End
---------------------------------------------------

function LootCouncil.Session:End()

    if not session then
        return
    end

    session = nil

    LootCouncil:Print(
        "Session ended."
    )

    LootCouncil.Persistence:Save()

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

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

    table.insert(session.players, player)

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

    table.insert(session.items, item)

    LootCouncil.Persistence:Save()

    self:InitializeApplicants(item)

    if not session.selectedItem then
        session.selectedItem = 1
    end

    LootCouncil:Print(
        "Added item: " ..
        item:GetName()
    )

    LootCouncil.UI.TabManager:Refresh()

    LootCouncil.UI.VotingTab:Refresh()

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

    table.insert(session.items, item)

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
-- Applicant Responses
---------------------------------------------------

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

    local item = self:GetItem(itemIndex)

    if not item then
        return nil
    end

    item:Award(playerName)

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

        item:AddApplicant(player)

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

    self:Begin(

        payload.owner

    )

end

---------------------------------------------------

function LootCouncil.Session:OnEndMessage(

    message,

    sender

)

    self:End()

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
-- GEAR_REQUEST Message
---------------------------------------------------

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

            table.insert(
                responseItems,
                tostring(slotID) ..
                "=" ..
                tostring(itemID)
            )

            LootCouncil:Print(
                "GEAR_REQUEST slot " ..
                tostring(slotID) ..
                ": item ID " ..
                tostring(itemID)
            )

        else

            LootCouncil:Print(
                "GEAR_REQUEST slot " ..
                tostring(slotID) ..
                ": empty"
            )

        end

    end

    LootCouncil:Print(
        "GEAR_REQUEST received. Target: " ..
        tostring(payload.target) ..
        ". Item index: " ..
        tostring(payload.itemIndex) ..
        ". Slots: " ..
        table.concat(slots, ", ")
    )

    local response =

        LootCouncil.Message:New(

            "GEAR_RESPONSE",

            {

                player = UnitName("player"),

                itemIndex = payload.itemIndex,

                items = items

            }

        )

    LootCouncil:Print(
        "GEAR_RESPONSE sending. Player: " ..
        UnitName("player") ..
        ". Item index: " ..
        tostring(payload.itemIndex) ..
        ". Items: " ..
        table.concat(responseItems, ", ")
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

    local item =
        self:GetItem(payload.itemIndex)

    if not item then
        return
    end

    local applicant =
        item:FindApplicant(payload.player)

    if not applicant then
        return
    end

    LootCouncil:Print(
        "GEAR_RESPONSE received. Player: " ..
        tostring(payload.player) ..
        ". Item index: " ..
        tostring(payload.itemIndex)
    )

    for slotID, itemID in pairs(payload.items or {}) do

        if itemID then
            applicant.gear[slotID] = itemID
        end

        LootCouncil:Print(
            "GEAR_RESPONSE slot " ..
            tostring(slotID) ..
            ": item ID " ..
            tostring(itemID)
        )

    end

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

    self:SetApplicantResponse(

        payload.player,

        payload.itemIndex,

        payload.response

    )

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

        "AWARD",

        self,

        self.OnAwardMessage

    )

    LootCouncil:Print(

        "Session message handlers registered."

    )

end
