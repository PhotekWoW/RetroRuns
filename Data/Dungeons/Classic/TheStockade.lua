-------------------------------------------------------------------------------
-- RetroRuns Data -- The Stockade
-- Classic dungeon, Patch 1.0  |  instanceID: 34  |  journalInstanceID: 238
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[238] = {
    kind              = "dungeon",
    instanceID        = 34,
    journalInstanceID = 238,
    name              = "The Stockade",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Hogger",
            journalEncounterID = 464,
            achievements       = {
                { id = 633, name = "Stormwind Stockade" },
            },
            loot = {
                { id = 2168, slot = "Feet", name = "Corpse Rompers", sources = { [14]=641 } },
                { id = 1934, slot = "Legs", name = "Hogger's Trousers", sources = { [14]=499 } },
                { id = 132569, slot = "Legs", name = "Stolen Jailer's Greaves", sources = { [14]=76402 } },
                { id = 151074, slot = "Shoulder", name = "Turnkey's Pauldrons", sources = { [14]=89260 } },
                { id = 1959, slot = "Two-Hand", name = "Cold Iron Pick", sources = { [14]=511 } },
            },
        },
        {
            index              = 2,
            name               = "Lord Overheat",
            journalEncounterID = 465,
            achievements       = {
            },
            loot = {
                { id = 151075, slot = "Chest", name = "Cinderstitch Tunic", sources = { [14]=89261 } },
                { id = 4676, slot = "Hands", name = "Skeletal Gauntlets", sources = { [14]=1787 } },
                { id = 1929, slot = "Legs", name = "Silk-Threaded Trousers", sources = { [14]=496 } },
                { id = 5967, slot = "Waist", name = "Girdle of Nobility", sources = { [14]=2222 } },
                { id = 151076, slot = "Wrist", name = "Fire-Hardened Shackles", sources = { [14]=89284 } },
            },
        },
        {
            index              = 3,
            name               = "Randolph Moloch",
            journalEncounterID = 466,
            achievements       = {
            },
            loot = {
                { id = 63345, slot = "Chest", name = "Noble's Robe", sources = { [14]=31791 } },
                { id = 63344, slot = "Feet", name = "Standard Issue Prisoner Shoes", sources = { [14]=31790 } },
                { id = 132570, slot = "Feet", name = "Stolen Guards Chain Boots", sources = { [14]=76403 } },
                { id = 151077, slot = "Waist", name = "Cast Iron Waistplate", sources = { [14]=89302 } },
                { id = 63346, slot = "Weapon", name = "Wicked Dagger", sources = { [14]=31792 } },
            },
        },
    },
}
