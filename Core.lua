LootCouncil = LootCouncil or {}

LootCouncil.Modules = LootCouncil.Modules or {}
LootCouncil.UI = LootCouncil.UI or {}

LootCouncil.name = "LootCouncil"
LootCouncil.version = "0.6.5"

function LootCouncil:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99LootCouncil:|r " .. tostring(message))
end

function LootCouncil:Initialize()

    self.Database:Initialize()

    self.MessageBus:Initialize()

    self.Session:Initialize()

    self.Persistence:Initialize()

    self.Permissions:Initialize()

    self.Comms:Initialize()

    ---------------------------------------------------
    -- Restore Persistent State
    ---------------------------------------------------

    self.Persistence:Load()

    self:Print(
        "Initialized v" ..
        self.version
    )

end