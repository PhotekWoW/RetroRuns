-------------------------------------------------------------------------------
-- RetroRuns Data -- Gnomeregan
-- Classic dungeon, Patch 1.0  |  instanceID: 90  |  journalInstanceID: 231
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[231] = {
    kind              = "dungeon",
    instanceID        = 90,
    journalInstanceID = 231,
    name              = "Gnomeregan",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Grubbis",
            journalEncounterID = 419,
            achievements       = {
            },
            loot = {
                { id = 9445, slot = "Hands", name = "Grubbis Paws", sources = { [14]=3286 } },
                { id = 151080, slot = "Head", name = "Grubbis' Protective Pail", sources = { [14]=89287 } },
                { id = 151078, slot = "Legs", name = "Shabby Trogg Britches", sources = { [14]=89285 } },
                { id = 151079, slot = "Waist", name = "Chomper-Hide Belt", sources = { [14]=89286 } },
            },
        },
        {
            index              = 2,
            name               = "Viscous Fallout",
            journalEncounterID = 420,
            achievements       = {
            },
            loot = {
                { id = 151082, slot = "Chest", name = "Lead Apron", sources = { [14]=89292 } },
                { id = 9454, slot = "Feet", name = "Acidic Walkers", sources = { [14]=3293 } },
                { id = 151083, slot = "Feet", name = "Hazmat Galoshes", sources = { [14]=89289 } },
                { id = 151081, slot = "Head", name = "Gnomish Rebreather", sources = { [14]=89288 } },
                { id = 9452, slot = "Two-Hand", name = "Hydrocane", sources = { [14]=3291 } },
                { id = 9453, slot = "Weapon", name = "Toxic Revenger", sources = { [14]=3292 } },
            },
        },
        {
            index              = 3,
            name               = "Electrocutioner 6000",
            journalEncounterID = 421,
            achievements       = {
            },
            loot = {
                { id = 9446, slot = "Weapon", name = "Electrocutioner Leg", sources = { [14]=3287 } },
                { id = 9448, slot = "Wrist", name = "Spidertank Oilrag", sources = { [14]=3288 } },
            },
        },
        {
            index              = 4,
            name               = "Crowd Pummeler 9-60",
            journalEncounterID = 418,
            achievements       = {
            },
            loot = {
                { id = 132558, slot = "Feet", name = "Bot Operator's Treads", sources = { [14]=76393 } },
                { id = 9450, slot = "Feet", name = "Gnomebot Operating Boots", sources = { [14]=3290 } },
                { id = 151085, slot = "Head", name = "Glitchbot Helm", sources = { [14]=89291 } },
                { id = 9449, slot = "Two-Hand", name = "Manual Crowd Pummeler", sources = { [14]=3289 } },
                { id = 151084, slot = "Waist", name = "Grease-Smudged Sash", sources = { [14]=89290 } },
            },
        },
        {
            index              = 5,
            name               = "Mekgineer Thermaplugg",
            journalEncounterID = 422,
            achievements       = {
                { id = 634, name = "Gnomeregan" },
            },
            loot = {
                { id = 9492, slot = "Head", name = "Electromagnetic Gigaflux Reactivator", sources = { [14]=3322 } },
                { id = 9458, slot = "Off-hand", name = "Thermaplugg's Central Core", sources = { [14]=3297 } },
                { id = 9459, slot = "Two-Hand", name = "Thermaplugg's Left Arm", sources = { [14]=3298 } },
            },
        },
    },
}
