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
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Grand Warlock Nethekurse",
            journalEncounterID = 566,
            achievements       = {
            },
            loot = {
                { id = 27519, slot = "Back", name = "Cloak of Malice", sources = { [14]=11950 } },
                { id = 27520, slot = "Head", name = "Greathelm of the Unbreakable", sources = { [14]=11951 } },
                { id = 27534, slot = "Off-hand", name = "Hortus' Seal of Brilliance", sources = { [14]=11962 } },
                { id = 27521, slot = "Waist", name = "Telaari Hunting Girdle", sources = { [14]=11952 } },
                { id = 27517, slot = "Wrist", name = "Bands of Nethekurse", sources = { [14]=11949 } },
            },
        },
        {
            index              = 2,
            name               = "Blood Guard Porung",
            journalEncounterID = 728,
            achievements       = {
            },
            loot = {
                { id = 30707, slot = "Feet", name = "Nimble-Foot Treads", sources = { [14]=13860 } },
                { id = 27474, slot = "Hands", name = "Beast Lord Handguards", sources = { [14]=11922 } },
                { id = 27536, slot = "Hands", name = "Hallowed Handwraps", sources = { [14]=11964 } },
                { id = 30709, slot = "Legs", name = "Pantaloons of Flaming Wrath", sources = { [14]=13862 } },
                { id = 124000, slot = "Shoulder", name = "Justice Bearer's Pauldrons", sources = { [14]=69457 }, timewalkingOnly = true },
                { id = 30705, slot = "Shoulder", name = "Spaulders of Slaughter", sources = { [14]=13859 } },
                { id = 30708, slot = "Waist", name = "Belt of Flowing Thought", sources = { [14]=13861 } },
            },
        },
        {
            index              = 3,
            name               = "Warbringer O'mrogg",
            journalEncounterID = 568,
            achievements       = {
            },
            loot = {
                { id = 29254, slot = "Feet", name = "Boots of the Righteous Path", sources = { [14]=13049 } },
                { id = 27525, slot = "Feet", name = "Jeweled Boots of Sanctification", sources = { [14]=11955 } },
                { id = 27526, slot = "Ranged", name = "Skyfire Hawk-Bow", sources = { [14]=11956 } },
                { id = 27524, slot = "Two-Hand", name = "Firemaul of Destruction", sources = { [14]=11954 } },
                { id = 27868, slot = "Weapon", name = "Runesong Dagger", sources = { [14]=12115 } },
                { id = 29263, slot = "Wrist", name = "Forestheart Bracers", sources = { [14]=13056 } },
                { id = 27522, slot = "Wrist", name = "World's End Bracers", sources = { [14]=11953 } },
            },
        },
        {
            index              = 4,
            name               = "Warchief Kargath Bladefist",
            journalEncounterID = 569,
            achievements       = {
                { id = 657, name = "The Shattered Halls" },
                { id = 678, name = "Heroic: The Shattered Halls" },
            },
            loot = {
                { id = 27528, slot = "Hands", name = "Gauntlets of Desolation", sources = { [14]=11958 } },
                { id = 27535, slot = "Hands", name = "Gauntlets of the Righteous", sources = { [14]=11963 } },
                { id = 27537, slot = "Hands", name = "Gloves of Oblivion", sources = { [14]=11965 } },
                { id = 27531, slot = "Hands", name = "Wastewalker Gloves", sources = { [14]=11960 } },
                { id = 27527, slot = "Legs", name = "Greaves of the Shatterer", sources = { [14]=11957 } },
                { id = 27540, slot = "Ranged", name = "Nexus Torch", sources = { [14]=11968 } },
                { id = 27802, slot = "Shoulder", name = "Tidefury Shoulderguards", sources = { [14]=12077 } },
                { id = 27533, slot = "Weapon", name = "Demonblood Eviscerator", sources = { [14]=11961 } },
                { id = 27538, slot = "Weapon", name = "Lightsworn Hammer", sources = { [14]=11966 } },
                { id = 29348, slot = "Weapon", name = "The Bladefist", sources = { [14]=13094 } },
                { id = 29255, slot = "Wrist", name = "Bands of Rarefied Magic", sources = { [14]=13050 } },
            },
        },
    },
}
