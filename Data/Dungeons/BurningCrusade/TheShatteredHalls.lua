-------------------------------------------------------------------------------
-- RetroRuns Data -- The Shattered Halls
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 540  |  journalInstanceID: 259
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[259] = {
    kind              = "dungeon",
    instanceID        = 540,
    journalInstanceID = 259,
    name              = "The Shattered Halls",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "2.0.3",
    timewalking       = true,

    entrance = {
        mapID = 100,
        x     = 0.4740,
        y     = 0.5202,
    },

    bosses = {
        {
            index              = 1,
            name               = "Grand Warlock Nethekurse",
            journalEncounterID = 566,
            achievements       = {
            },
            loot = {
                { id = 27519, slot = "Back", name = "Cloak of Malice", sources = { [14]=11950, [15]=11950 }, twSource = 69441 },
                { id = 27520, slot = "Head", name = "Greathelm of the Unbreakable", sources = { [14]=11951, [15]=11951 }, twSource = 69442 },
                { id = 27534, slot = "Off-hand", name = "Hortus' Seal of Brilliance", sources = { [14]=11962, [15]=11962 }, twSource = 69452 },
                { id = 27521, slot = "Waist", name = "Telaari Hunting Girdle", sources = { [14]=11952, [15]=11952 }, twSource = 69443 },
                { id = 27517, slot = "Wrist", name = "Bands of Nethekurse", sources = { [14]=11949, [15]=11949 }, twSource = 69440 },
            },
        },
        {
            index              = 2,
            name               = "Blood Guard Porung",
            journalEncounterID = 728,
            achievements       = {
            },
            loot = {
                { id = 30707, slot = "Feet", name = "Nimble-Foot Treads", sources = { [14]=13860, [15]=13860 }, twSource = 69461 },
                { id = 27474, slot = "Hands", name = "Beast Lord Handguards", sources = { [14]=11922, [15]=11922 } },
                { id = 27536, slot = "Hands", name = "Hallowed Handwraps", sources = { [14]=11964, [15]=11964 }, twSource = 69454 },
                { id = 30709, slot = "Legs", name = "Pantaloons of Flaming Wrath", sources = { [14]=13862, [15]=13862 }, twSource = 69463 },
                { id = 124000, slot = "Shoulder", name = "Justice Bearer's Pauldrons", sources = { [24]=69457 } },
                { id = 30705, slot = "Shoulder", name = "Spaulders of Slaughter", sources = { [14]=13859, [15]=13859 }, twSource = 69460 },
                { id = 30708, slot = "Waist", name = "Belt of Flowing Thought", sources = { [14]=13861, [15]=13861 }, twSource = 69462 },
            },
        },
        {
            index              = 3,
            name               = "Warbringer O'mrogg",
            journalEncounterID = 568,
            achievements       = {
            },
            loot = {
                { id = 29254, slot = "Feet", name = "Boots of the Righteous Path", sources = { [14]=13049, [15]=13049 }, twSource = 69465 },
                { id = 27525, slot = "Feet", name = "Jeweled Boots of Sanctification", sources = { [14]=11955, [15]=11955 }, twSource = 69446 },
                { id = 27526, slot = "Ranged", name = "Skyfire Hawk-Bow", sources = { [14]=11956, [15]=11956 }, twSource = 69447 },
                { id = 27524, slot = "Two-Hand", name = "Firemaul of Destruction", sources = { [14]=11954, [15]=11954 }, twSource = 69445 },
                { id = 27868, slot = "Weapon", name = "Runesong Dagger", sources = { [14]=12115, [15]=12115 }, twSource = 69459 },
                { id = 29263, slot = "Wrist", name = "Forestheart Bracers", sources = { [14]=13056, [15]=13056 }, twSource = 69467 },
                { id = 27522, slot = "Wrist", name = "World's End Bracers", sources = { [14]=11953, [15]=11953 }, twSource = 69444 },
            },
        },
        {
            index              = 4,
            name               = "Warchief Kargath Bladefist",
            journalEncounterID = 569,
            achievements       = {
            },
            loot = {
                { id = 27528, slot = "Hands", name = "Gauntlets of Desolation", sources = { [14]=11958, [15]=11958 }, twSource = 69449 },
                { id = 27535, slot = "Hands", name = "Gauntlets of the Righteous", sources = { [14]=11963, [15]=11963 }, twSource = 69453 },
                { id = 27537, slot = "Hands", name = "Gloves of Oblivion", sources = { [14]=11965, [15]=11965 }, twSource = 69455 },
                { id = 27531, slot = "Hands", name = "Wastewalker Gloves", sources = { [14]=11960, [15]=11960 }, twSource = 69450 },
                { id = 27527, slot = "Legs", name = "Greaves of the Shatterer", sources = { [14]=11957, [15]=11957 }, twSource = 69448 },
                { id = 27540, slot = "Ranged", name = "Nexus Torch", sources = { [14]=11968, [15]=11968 }, twSource = 69458 },
                { id = 27802, slot = "Shoulder", name = "Tidefury Shoulderguards", sources = { [14]=12077, [15]=12077 } },
                { id = 27533, slot = "Weapon", name = "Demonblood Eviscerator", sources = { [14]=11961, [15]=11961 }, twSource = 69451 },
                { id = 27538, slot = "Weapon", name = "Lightsworn Hammer", sources = { [14]=11966, [15]=11966 }, twSource = 69456 },
                { id = 29348, slot = "Weapon", name = "The Bladefist", sources = { [14]=13094, [15]=13094 }, twSource = 69468 },
                { id = 29255, slot = "Wrist", name = "Bands of Rarefied Magic", sources = { [14]=13050, [15]=13050 }, twSource = 69466 },
            },
        },
    },
}
