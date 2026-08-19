local Player = {}
Player.__index = Player

function Player:New(name, class)

    local player = setmetatable({}, Player)

    player.name = name or "Unknown"
    player.class = class or "UNKNOWN"

    player.online = true
    player.hasAddon = false

    player.attendance = 0

    player.lootHistory = {}

    player.gear = {}

    return player

end

function Player:GetName()
    return self.name
end

function Player:GetClass()
    return self.class
end

function Player:IsOnline()
    return self.online
end

function Player:SetOnline(online)
    self.online = online
end

function Player:HasAddon()
    return self.hasAddon
end

function Player:SetAddonInstalled(installed)
    self.hasAddon = installed
end

LootCouncil.Player = Player