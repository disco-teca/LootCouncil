LootCouncil.Database = {}

LootCouncilDB = LootCouncilDB or {}

function LootCouncil.Database:Initialize()

    LootCouncilDB.window = LootCouncilDB.window or {}

    LootCouncilDB.window.x = LootCouncilDB.window.x or 0
    LootCouncilDB.window.y = LootCouncilDB.window.y or 0

    LootCouncilDB.Theme = LootCouncilDB.Theme or "Dark"

    LootCouncilDB.DevMode = LootCouncilDB.DevMode or false

    LootCouncilDB.GuildRoster = LootCouncilDB.GuildRoster or {}
    LootCouncilDB.PreSessionCouncil = LootCouncilDB.PreSessionCouncil or {}

    LootCouncilDB.MainWindowScale = LootCouncilDB.MainWindowScale or 1.0
    LootCouncilDB.LootPopupScale = LootCouncilDB.LootPopupScale or 1.0

    LootCouncil:Print("Database initialized.")

end