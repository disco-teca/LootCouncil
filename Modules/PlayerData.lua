LootCouncil.PlayerData = {}

local module = LootCouncil.PlayerData

---------------------------------------------------
-- State
---------------------------------------------------

local cache = {}

---------------------------------------------------
-- Cache Construction
---------------------------------------------------

local function CreateItemCache()

    return {

        itemID = nil,

        link = nil,

        name = nil,

        icon = nil,

        quality = nil,

        itemLevel = nil,

        equipSlot = nil,

    }

end

local function CreatePlayerCache()

    local equipped = {}

    for slotName in pairs(LootCouncil.Constants.InventorySlot) do

        equipped[slotName] = CreateItemCache()

    end

    return {

        equipped = equipped,

        averageItemLevel = nil,

        lastInspect = nil,

    }

end

function module:CreatePlayerData()

    return CreatePlayerCache()

end

---------------------------------------------------
-- Cache Management
---------------------------------------------------

function module:UpdatePlayerData(

    playerName,

    data

)

    if not playerName then
        return
    end

    if not data then
        return
    end

    cache[playerName] = data

end

function module:SetPlayerData(playerName, data)

    local waist = data.equipped.Waist

    cache[playerName] = data

    local stored = cache[playerName].equipped.Waist

    local message =

        LootCouncil.Message:New(

            "PLAYER_DATA_UPDATED",

            {

                player = playerName

            }

        )

    LootCouncil.MessageBus:Route(

        message,

        playerName

    )

end

function module:GetPlayerData(playerName)

    for name, data in pairs(cache) do

        if data and data.equipped then

            for slotName, item in pairs(data.equipped) do

                if item and item.itemLevel then

                end

            end

        end

    end

    local playerData = cache[playerName]

    if playerData and playerData.equipped then

        for slotName, item in pairs(playerData.equipped) do

            if item and item.itemLevel then

            end

        end

    end

    return playerData

end

function module:HasPlayerData(playerName)

    return cache[playerName] ~= nil

end

function module:ClearPlayerData(playerName)

    cache[playerName] = nil

end

function module:ClearCache()

    cache = {}

end

function module:GetEquipment(player)

    if not player then
        return nil
    end

    local playerName

    if type(player) == "string" then
        playerName = player
    else
        playerName = player:GetName()
    end

    local playerData = self:GetPlayerData(playerName)

    if not playerData then
        return nil
    end

    return playerData.equipped

end

---------------------------------------------------
-- Synchronization
---------------------------------------------------

function module:CreateSyncPacket(playerName)

    local data = cache[playerName]

    if not data then
        return nil
    end

    local equipment = {}

    for slotName in pairs(LootCouncil.Constants.InventorySlot) do

        local item = data.equipped[slotName]

        equipment[slotName] = {

            itemID = item.itemID,
            itemLevel = item.itemLevel,

        }

    end

    return {

        version = 1,

        player = playerName,

        averageItemLevel = data.averageItemLevel,

        equipment = equipment,

    }

end

function module:ApplySyncPacket(data)

    if not data then
        return
    end

    if not data.player then
        return
    end

    if not data.data then
        return
    end

    local packet = data.data

    local playerData = cache[data.player]

    if not playerData then

        playerData = module:CreatePlayerData()

        cache[data.player] = playerData

    end

    playerData.averageItemLevel = packet.averageItemLevel

    for slot, itemData in pairs(packet.equipment or {}) do

        if playerData.equipped[slot] then

            playerData.equipped[slot].itemID = itemData.itemID
            playerData.equipped[slot].itemLevel = itemData.itemLevel

        end

    end

    ---------------------------------------------------
    -- Notify Local Systems
    ---------------------------------------------------

    local message =

        LootCouncil.Message:New(

            "PLAYER_DATA_APPLIED",

            {

                player = data.player

            }

        )

    LootCouncil.MessageBus:Publish(

        message,

        data.player

    )

end

function module:PrintCache()

    for playerName, playerData in pairs(cache) do

        for slot, item in pairs(playerData.equipped) do

            if item.itemID then

            end

        end

    end

end

function module:RestoreFromInspectCache()

    cache = {}

    for playerName, data in pairs(LootCouncilDB.InspectCache or {}) do

        cache[playerName] = data

    end

end