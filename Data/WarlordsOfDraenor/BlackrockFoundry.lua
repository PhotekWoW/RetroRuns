-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackrock Foundry
-- Warlords of Draenor, Patch 6.0.3  |  instanceID: 1205  |  journalInstanceID: 457
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1205] = {
    instanceID        = 1205,
    journalInstanceID = 457,
    name              = "Blackrock Foundry",
    expansion         = "Warlords of Draenor",
    patch             = "6.0.3",

    entrance = {
        mapID = 543,
        x     = 0.5155,
        y     = 0.2723,
    },

    maps = {
        [596] = "The Black Forge",
        [597] = "Slagworks",
        [598] = "The Workshop",
        [599] = "Iron Assembly",
        [600] = "The Crucible",
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
            name               = "Oregorger",
            journalEncounterID = 1696,
            aliases            = {},
            achievements       = {
                { id = 8979, name = "He Shoots, He Ores", meta = true },
            },
            loot = {},
        },
        {
            index              = 2,
            name               = "Hans'gar and Franzok",
            journalEncounterID = 1693,
            aliases            = {},
            achievements       = {
                { id = 8980, name = "Stamp Stamp Revolution", meta = true },
            },
            loot = {},
        },
        {
            index              = 3,
            name               = "Beastlord Darmac",
            journalEncounterID = 1694,
            aliases            = {},
            achievements       = {
                { id = 8981, name = "Fain Would Lie Down", meta = true },
            },
            loot = {},
        },
        {
            index              = 4,
            name               = "Gruul",
            journalEncounterID = 1691,
            aliases            = {},
            achievements       = {
                { id = 8978, name = "The Iron Price", meta = true },
            },
            loot = {},
        },
        {
            index              = 5,
            name               = "Flamebender Ka'graz",
            journalEncounterID = 1689,
            aliases            = {},
            achievements       = {
                { id = 8929, name = "The Steel Has Been Brought", meta = true },
            },
            loot = {},
        },
        {
            index              = 6,
            name               = "Operator Thogar",
            journalEncounterID = 1692,
            aliases            = {},
            achievements       = {
                { id = 8982, name = "There's Always a Bigger Train", meta = true },
            },
            loot = {},
        },
        {
            index              = 7,
            name               = "The Blast Furnace",
            journalEncounterID = 1690,
            aliases            = {},
            achievements       = {
                { id = 8930, name = "Ya, We've Got Time...", meta = true },
            },
            loot = {},
        },
        {
            index              = 8,
            name               = "Kromog",
            journalEncounterID = 1713,
            aliases            = {},
            achievements       = {
                { id = 8983, name = "Would You Give Me a Hand?", meta = true },
            },
            loot = {},
        },
        {
            index              = 9,
            name               = "The Iron Maidens",
            journalEncounterID = 1695,
            aliases            = {},
            achievements       = {
                { id = 8984, name = "Be Quick or Be Dead", meta = true },
            },
            loot = {},
        },
        {
            index              = 10,
            name               = "Blackhand",
            journalEncounterID = 1704,
            aliases            = {},
            achievements       = {
                { id = 8952, name = "Ashes, Ashes...", meta = true },
            },
            loot = {},
        },
    },

    routing = {},
}
