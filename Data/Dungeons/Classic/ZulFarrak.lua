-------------------------------------------------------------------------------
-- RetroRuns Data -- Zul'Farrak
-- Classic dungeon, Patch 1.0  |  instanceID: 209  |  journalInstanceID: 241
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[241] = {
    kind              = "dungeon",
    instanceID        = 209,
    journalInstanceID = 241,
    name              = "Zul'Farrak",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Theka the Martyr",
            journalEncounterID = 485,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 2,
            name               = "Hydromancer Velratha",
            journalEncounterID = 482,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 3,
            name               = "Antu'sul",
            journalEncounterID = 484,
            achievements       = {
            },
            loot = {
                { id = 9640, slot = "Hands", name = "Vice Grips", sources = { [14]=3368 } },
                { id = 9379, slot = "Weapon", name = "Sang'thraze the Deflector", sources = { [14]=3231 } },
                { id = 9639, slot = "Weapon", name = "The Hand of Antu'sul", sources = { [14]=3367 } },
            },
        },
        {
            index              = 4,
            name               = "Witch Doctor Zum'rah",
            journalEncounterID = 486,
            achievements       = {
            },
            loot = {
                { id = 18083, slot = "Hands", name = "Jumanza Grips", sources = { [14]=7227 } },
                { id = 18082, slot = "Two-Hand", name = "Zum'rah's Vexing Cane", sources = { [14]=7226 } },
            },
        },
        {
            index              = 5,
            name               = "Gahz'rilla",
            journalEncounterID = 483,
            achievements       = {
            },
            loot = {
                { id = 151455, slot = "Back", name = "Gahz'rilla Scale Cloak", sources = { [14]=89451 } },
                { id = 9469, slot = "Chest", name = "Gahz'rilla Scale Armor", sources = { [14]=3301 } },
                { id = 9467, slot = "Weapon", name = "Gahz'rilla Fang", sources = { [14]=3300 } },
            },
        },
        {
            index              = 6,
            name               = "Nekrum & Sezz'ziz",
            journalEncounterID = 487,
            achievements       = {
            },
            loot = {
                { id = 9473, slot = "Chest", name = "Jinxed Hoodoo Skin", sources = { [14]=3303 } },
                { id = 151458, slot = "Feet", name = "Sezz'ziz's Captive Kickers", sources = { [14]=89452 } },
                { id = 9470, slot = "Head", name = "Bad Mojo Mask", sources = { [14]=3302 } },
                { id = 9474, slot = "Legs", name = "Jinxed Hoodoo Kilt", sources = { [14]=3304 } },
                { id = 9475, slot = "Two-Hand", name = "Diabolic Skiver", sources = { [14]=3305 } },
                { id = 151459, slot = "Waist", name = "Nekrum's Witherguard", sources = { [14]=89453 } },
            },
        },
        {
            index              = 7,
            name               = "Chief Ukorz Sandscalp",
            journalEncounterID = 489,
            achievements       = {
                { id = 639, name = "Zul'Farrak" },
            },
            loot = {
                { id = 151460, slot = "Chest", name = "Farraki Ceremonial Robes", sources = { [14]=89454 } },
                { id = 9479, slot = "Head", name = "Embrace of the Lycan", sources = { [14]=3309 } },
                { id = 151461, slot = "Legs", name = "Ukorz's Chain Leggings", sources = { [14]=89455 } },
                { id = 9476, slot = "Shoulder", name = "Big Bad Pauldrons", sources = { [14]=3306 } },
                { id = 232904, slot = "Two-Hand", name = "Sul'thraze the Lasher", sources = { [14]=230433 }, timewalkingOnly = true },
                { id = 9477, slot = "Two-Hand", name = "The Chief's Enforcer", sources = { [14]=3307 } },
                { id = 11086, slot = "Weapon", name = "Jang'thraze the Protector", sources = { [14]=4132 } },
                { id = 9478, slot = "Weapon", name = "Ripsaw", sources = { [14]=3308 } },
            },
        },
    },
}
