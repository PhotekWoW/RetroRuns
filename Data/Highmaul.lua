-------------------------------------------------------------------------------
-- RetroRuns Data -- Highmaul
-- Warlords of Draenor, Patch 6.0.3  |  instanceID: 1228  |  journalInstanceID: 477
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1228] = {
    instanceID        = 1228,
    journalInstanceID = 477,
    name              = "Highmaul",
    expansion         = "Warlords of Draenor",
    patch             = "6.0.3",

    useStrictActiveSegPicker = false,

    entrance = {
        mapID = 550,
        x     = 0.3290,
        y     = 0.3830,
    },

    maps = {
        [610] = "Highmaul",
        [611] = "Gladiator's Rest",
        [612] = "The Coliseum",
        [613] = "Chamber of Nullification",
        [614] = "Imperator's Rise",
        [615] = "Throne of the Imperator",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    gloryMeta = {
        id   = 8985,
        name = "Glory of the Draenor Raider",
        rewardItemID       = 116383,
        rewardMountSpellID = 171436,
        rewardName         = "Gorestrider Gronnling",
    },

    bosses = {
        {
            index              = 1,
            name               = "Kargath Bladefist",
            journalEncounterID = 1721,
            aliases            = {},
            achievements       = {
                { id = 8948, name = "Flame On!", meta = true },
            },
            loot = {},
        },
        {
            index              = 2,
            name               = "The Butcher",
            journalEncounterID = 1706,
            aliases            = {},
            achievements       = {
                { id = 8947, name = "Hurry Up, Maggot!", meta = true },
            },
            loot = {},
        },
        {
            index              = 3,
            name               = "Tectus",
            journalEncounterID = 1722,
            aliases            = {},
            achievements       = {
                { id = 8974, name = "More Like Wrecked-us", meta = true },
            },
            loot = {},
        },
        {
            index              = 4,
            name               = "Brackenspore",
            journalEncounterID = 1720,
            aliases            = {},
            achievements       = {
                { id = 8975, name = "A Fungus Among Us", meta = true },
            },
            loot = {},
        },
        {
            index              = 5,
            name               = "Twin Ogron",
            journalEncounterID = 1719,
            aliases            = {},
            achievements       = {
                { id = 8958, name = "Brothers in Arms", meta = true },
            },
            loot = {},
        },
        {
            index              = 6,
            name               = "Ko'ragh",
            journalEncounterID = 1723,
            aliases            = {},
            achievements       = {
                { id = 8976, name = "Pair Annihilation", meta = true },
            },
            loot = {},
        },
        {
            index              = 7,
            name               = "Imperator Mar'gok",
            journalEncounterID = 1705,
            aliases            = {},
            achievements       = {
                { id = 8977, name = "Lineage of Power", meta = true },
            },
            loot = {},
        },
    },

    routing = {},
}
