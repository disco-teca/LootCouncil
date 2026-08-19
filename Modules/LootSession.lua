LootCouncil.Session = {}

LootCouncil.Session.active = false
LootCouncil.Session.items = {}
LootCouncil.Session.players = {}
LootCouncil.Session.locked = false

function LootCouncil.Session:Start()
    self.active = true
    self.items = {}
    self.players = {}
    self.locked = false

    LootCouncil:Print("Loot session started.")
end

function LootCouncil.Session:End()
    self.active = false
    self.items = {}
    self.players = {}
    self.locked = false

    LootCouncil:Print("Loot session ended.")
end

function LootCouncil.Session:IsActive()
    return self.active
end