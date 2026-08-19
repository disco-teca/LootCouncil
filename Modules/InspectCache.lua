LootCouncil = LootCouncil or {}

LootCouncil.InspectCache = {}

local module = LootCouncil.InspectCache

local cache

function module:Initialize()

    cache = LootCouncilDB.InspectCache

end

function module:DebugPrint()

    LootCouncil:Print("Inspect Cache")

    for name in pairs(cache) do
        LootCouncil:Print(" - " .. name)
    end

end

function module:HasPlayerData(name)

    return cache[name] ~= nil

end

function module:GetPlayerData(name)

    return cache[name]

end

function module:UpdatePlayerData(name, playerData)

    cache[name] = playerData

end