-------------------------------------------------------------------------------
-- RetroRuns Data -- Hellfire Citadel
-- Warlords of Draenor, Patch 6.2.0  |  instanceID: 1448  |  journalInstanceID: 669
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1448] = {
    instanceID        = 1448,
    journalInstanceID = 669,
    name              = "Hellfire Citadel",
    expansion         = "Warlords of Draenor",
    patch             = "6.2.0",

    useStrictActiveSegPicker = false,

    entrance = {
        mapID = 534,
        x     = 0.4556,
        y     = 0.5361,
    },

    maps = {
        [661] = "Hellfire Citadel",
        [662] = "Hellfire Antechamber",
        [663] = "Hellfire Passage",
        [664] = "Pits of Mannoroth",
        [665] = "Court of Blood",
        [666] = "Grommash's Torment",
        [667] = "The Felborne Breach",
        [668] = "Halls of the Sargerei",
        [669] = "Destructor's Rise",
        [670] = "The Black Gate",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    gloryMeta = {
        id   = 10149,
        name = "Glory of the Hellfire Raider",
        rewardItemID       = 127140,
        rewardMountSpellID = 186305,
        rewardName         = "Infernal Direwolf",
    },

    bosses = {
        {
            index              = 1,
            name               = "Hellfire Assault",
            journalEncounterID = 1778,
            aliases            = {},
            achievements       = {
                { id = 10026, name = "Nearly Indestructible", meta = true },
            },
            loot = {},
        },
        {
            index              = 2,
            name               = "Iron Reaver",
            journalEncounterID = 1785,
            aliases            = {},
            achievements       = {
                { id = 10057, name = "Turning the Tide", meta = true },
            },
            loot = {},
        },
        {
            index              = 3,
            name               = "Kormrok",
            journalEncounterID = 1787,
            aliases            = {},
            achievements       = {
                { id = 10013, name = "Waves Came Crashing Down All Around", meta = true },
            },
            loot = {},
        },
        {
            index              = 4,
            name               = "Hellfire High Council",
            journalEncounterID = 1798,
            aliases            = {},
            achievements       = {
                { id = 10054, name = "Don't Fear the Reaper", meta = true },
            },
            loot = {},
        },
        {
            index              = 5,
            name               = "Kilrogg Deadeye",
            journalEncounterID = 1786,
            aliases            = {},
            achievements       = {
                { id = 9972, name = "A Race Against Slime", meta = true },
            },
            loot = {},
        },
        {
            index              = 6,
            name               = "Gorefiend",
            journalEncounterID = 1783,
            aliases            = {},
            achievements       = {
                { id = 9979, name = "Get In My Belly!", meta = true },
            },
            loot = {},
        },
        {
            index              = 7,
            name               = "Shadow-Lord Iskar",
            journalEncounterID = 1788,
            aliases            = {},
            achievements       = {
                { id = 9988, name = "Pro Toss", meta = true },
            },
            loot = {},
        },
        {
            index              = 8,
            name               = "Socrethar the Eternal",
            journalEncounterID = 1794,
            aliases            = {},
            achievements       = {
                { id = 10086, name = "I'm a Soul Man", meta = true },
            },
            loot = {},
        },
        {
            index              = 9,
            name               = "Fel Lord Zakuun",
            journalEncounterID = 1777,
            aliases            = {},
            achievements       = {
                { id = 10012, name = "This Land Was Green and Good Until...", meta = true },
            },
            loot = {},
        },
        {
            index              = 10,
            name               = "Xhul'horac",
            journalEncounterID = 1800,
            aliases            = {},
            achievements       = {
                { id = 10087, name = "You Gotta Keep 'em Separated", meta = true },
            },
            loot = {},
        },
        {
            index              = 11,
            name               = "Tyrant Velhari",
            journalEncounterID = 1784,
            aliases            = {},
            achievements       = {
                { id = 9989, name = "Non-Lethal Enforcer", meta = true },
            },
            loot = {},
        },
        {
            index              = 12,
            name               = "Mannoroth",
            journalEncounterID = 1795,
            aliases            = {},
            achievements       = {
                { id = 10030, name = "Bad Manner(oth)", meta = true },
            },
            loot = {},
        },
        {
            index              = 13,
            name               = "Archimonde",
            journalEncounterID = 1799,
            aliases            = {},
            achievements       = {
                { id = 10073, name = "Echoes of Doomfire", meta = true },
            },
            loot = {},
        },
    },

    routing = {},
}
