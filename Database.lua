LootCouncil.Database = {}

LootCouncilDB = LootCouncilDB or {}

function LootCouncil.Database:Initialize()

    LootCouncilDB.window = LootCouncilDB.window or {}

    LootCouncilDB.window.x = LootCouncilDB.window.x or 0
    LootCouncilDB.window.y = LootCouncilDB.window.y or 0

    LootCouncilDB.InspectCache =
        LootCouncilDB.InspectCache or {}

    LootCouncil:Print("Database initialized.")

end