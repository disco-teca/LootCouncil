LootCouncil.TestData = {}

---------------------------------------------------
-- Players
---------------------------------------------------

LootCouncil.TestData.Players = {

    { name = "Alex",   class = "PALADIN" },
    { name = "Brian",  class = "WARRIOR" },
    { name = "Chris",  class = "DEATHKNIGHT" },
    { name = "David",  class = "MAGE" },
    { name = "Emily",  class = "PRIEST" },
    { name = "Frank",  class = "ROGUE" },
    { name = "Grace",  class = "SHAMAN" },
    { name = "Henry",  class = "HUNTER" },
    { name = "Isaac",  class = "WARLOCK" },
    { name = "James",  class = "DRUID" },

}

---------------------------------------------------
-- Loot Items
---------------------------------------------------

LootCouncil.TestData.Items = {

    {
        id = 45612,

        applicants = {

            { player = "Alex",  response = "BIS" },
            { player = "Brian", response = "MS" },
            { player = "Chris", response = "BIS" },
            { player = "David", response = "OS" },
            { player = "Emily", response = "PASS" },

        },

    },

    {
        id = 45929,
    },

    {
        id = 45446,
    },

}