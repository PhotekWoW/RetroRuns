-------------------------------------------------------------------------------
-- RetroRuns Data -- Wailing Caverns
-- Classic dungeon, Patch 1.0  |  instanceID: 43  |  journalInstanceID: 240
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[240] = {
    kind              = "dungeon",
    instanceID        = 43,
    journalInstanceID = 240,
    name              = "Wailing Caverns",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Lady Anacondra",
            journalEncounterID = 474,
            achievements       = {
            },
            loot = {
                { id = 151427, slot = "Head", name = "Snake-Charmer's Casque", sources = { [14]=89430 } },
                { id = 132737, slot = "Shoulder", name = "Cavern Slitherer Pauldrons", sources = { [14]=76414 } },
                { id = 5404, slot = "Shoulder", name = "Serpent's Shoulders", sources = { [14]=2095 } },
                { id = 10412, slot = "Waist", name = "Belt of the Fang", sources = { [14]=3964 } },
                { id = 132740, slot = "Waist", name = "Slither-Scale Cord", sources = { [14]=76416 } },
                { id = 151426, slot = "Wrist", name = "Lady Anacondra's Satin Cuffs", sources = { [14]=89429 } },
            },
        },
        {
            index              = 2,
            name               = "Lord Pythas",
            journalEncounterID = 476,
            achievements       = {
            },
            loot = {
                { id = 6473, slot = "Chest", name = "Armor of the Fang", sources = { [14]=2429 } },
                { id = 132739, slot = "Chest", name = "Slither-Scale Hauberk", sources = { [14]=76415 } },
                { id = 151429, slot = "Shoulder", name = "Lord Pythas' Pauldrons", sources = { [14]=89432 } },
                { id = 151428, slot = "Waist", name = "Slumbersilk Waistcord", sources = { [14]=89431 } },
                { id = 6472, slot = "Weapon", name = "Stinging Viper", sources = { [14]=2428 } },
            },
        },
        {
            index              = 3,
            name               = "Lord Cobrahn",
            journalEncounterID = 475,
            achievements       = {
            },
            loot = {
                { id = 6465, slot = "Chest", name = "Robe of the Moccasin", sources = { [14]=2423 } },
                { id = 10410, slot = "Legs", name = "Leggings of the Fang", sources = { [14]=3962 } },
                { id = 132742, slot = "Legs", name = "Slither-Scale Britches", sources = { [14]=76418 } },
                { id = 6460, slot = "Waist", name = "Cobrahn's Grasp", sources = { [14]=2421 } },
            },
        },
        {
            index              = 4,
            name               = "Kresh",
            journalEncounterID = 477,
            achievements       = {
            },
            loot = {
                { id = 13245, slot = "Off-hand", name = "Kresh's Back", sources = { [14]=4807 } },
                { id = 6447, slot = "Off-hand", name = "Worn Turtle Shell Shield", sources = { [14]=2417 } },
            },
        },
        {
            index              = 5,
            name               = "Skum",
            journalEncounterID = 478,
            achievements       = {
            },
            loot = {
                { id = 6449, slot = "Back", name = "Glowing Lizardscale Cloak", sources = { [14]=2419 } },
                { id = 6448, slot = "Weapon", name = "Tail Spike", sources = { [14]=2418 } },
            },
        },
        {
            index              = 6,
            name               = "Lord Serpentis",
            journalEncounterID = 479,
            achievements       = {
            },
            loot = {
                { id = 10411, slot = "Feet", name = "Footpads of the Fang", sources = { [14]=3963 } },
                { id = 6459, slot = "Feet", name = "Savage Trodders", sources = { [14]=2420 } },
                { id = 132741, slot = "Feet", name = "Slither-Scale Boots", sources = { [14]=76417 } },
                { id = 5970, slot = "Hands", name = "Serpent Gloves", sources = { [14]=2225 } },
                { id = 6469, slot = "Ranged", name = "Venomstrike", sources = { [14]=2427 } },
            },
        },
        {
            index              = 7,
            name               = "Verdan the Everliving",
            journalEncounterID = 480,
            achievements       = {
            },
            loot = {
                { id = 6629, slot = "Back", name = "Sporid Cape", sources = { [14]=2544 } },
                { id = 6630, slot = "Off-hand", name = "Seedcloud Buckler", sources = { [14]=2545 } },
                { id = 6631, slot = "Two-Hand", name = "Living Root", sources = { [14]=2546 } },
            },
        },
        {
            index              = 8,
            name               = "Mutanus the Devourer",
            journalEncounterID = 481,
            achievements       = {
                { id = 630, name = "Wailing Caverns" },
            },
            loot = {
                { id = 6627, slot = "Chest", name = "Mutant Breastplate", sources = { [14]=2542 } },
                { id = 6461, slot = "Shoulder", name = "Slime-Encrusted Pads", sources = { [14]=2422 } },
            },
        },
    },
}
