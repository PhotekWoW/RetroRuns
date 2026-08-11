-------------------------------------------------------------------------------
-- RetroRuns Data -- Magtheridon's Lair
-- Burning Crusade, Patch 2.0.3  |  instanceID: 544  |  journalInstanceID: 747
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[544] = {
    instanceID        = 544,
    journalInstanceID = 747,
    name              = "Magtheridon's Lair",
    expansion         = "Burning Crusade",
    patch             = "2.0.3",

    exitNote          = "None available",

    -- The raid runs at 25-player only. One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Hellfire Peninsula, the lower west face of Hellfire Citadel.
        mapID = 100, x = 0.4764, y = 0.5201,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [331] = "Magtheridon's Lair",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [29753] = 1,   -- Chestguard of the Fallen Defender
            [29754] = 1,   -- Chestguard of the Fallen Champion
            [29755] = 1,   -- Chestguard of the Fallen Hero
        },
    },

    bosses = {
        {
            index              = 1,
            name               = "Magtheridon",
            journalEncounterID = 1566,
            achievements       = {},
            loot               = {
                { id = 28777, slot = "Back", name = "Cloak of the Pit Stalker", sources = { [14]=12723 } },
                { id = 29096, slot = "Chest", name = "Breastplate of Malorne", sources = { [14]=12972 }, classes = { 11 } },
                { id = 29087, slot = "Chest", name = "Chestguard of Malorne", sources = { [14]=12963 }, classes = { 11 } },
                { id = 29091, slot = "Chest", name = "Chestpiece of Malorne", sources = { [14]=12967 }, classes = { 11 } },
                { id = 29038, slot = "Chest", name = "Cyclone Breastplate", sources = { [14]=12917 }, classes = { 7 } },
                { id = 29033, slot = "Chest", name = "Cyclone Chestguard", sources = { [14]=12912 }, classes = { 7 } },
                { id = 29029, slot = "Chest", name = "Cyclone Hauberk", sources = { [14]=12908 }, classes = { 7 } },
                { id = 29082, slot = "Chest", name = "Demon Stalker Harness", sources = { [14]=12958 }, classes = { 3 } },
                { id = 29071, slot = "Chest", name = "Justicar Breastplate", sources = { [14]=12947 }, classes = { 2 } },
                { id = 29066, slot = "Chest", name = "Justicar Chestguard", sources = { [14]=12942 }, classes = { 2 } },
                { id = 29062, slot = "Chest", name = "Justicar Chestpiece", sources = { [14]=12938 }, classes = { 2 } },
                { id = 29045, slot = "Chest", name = "Netherblade Chestpiece", sources = { [14]=12923 }, classes = { 4 } },
                { id = 29050, slot = "Chest", name = "Robes of the Incarnate", sources = { [14]=12928 }, classes = { 5 } },
                { id = 29056, slot = "Chest", name = "Shroud of the Incarnate", sources = { [14]=12932 }, classes = { 5 } },
                { id = 29077, slot = "Chest", name = "Vestments of the Aldor", sources = { [14]=12953 }, classes = { 8 } },
                { id = 28964, slot = "Chest", name = "Voidheart Robe", sources = { [14]=12851 }, classes = { 9 } },
                { id = 29019, slot = "Chest", name = "Warbringer Breastplate", sources = { [14]=12902 }, classes = { 1 } },
                { id = 29012, slot = "Chest", name = "Warbringer Chestguard", sources = { [14]=12896 }, classes = { 1 } },
                { id = 28776, slot = "Hands", name = "Liar's Tongue Gloves", sources = { [14]=12722 } },
                { id = 28780, slot = "Hands", name = "Soul-Eater's Handwraps", sources = { [14]=12726 } },
                { id = 28775, slot = "Head", name = "Thundering Greathelm", sources = { [14]=12721 } },
                { id = 28781, slot = "Held In Off-hand", name = "Karaborian Talisman", sources = { [14]=12727 } },
                { id = 29458, slot = "Off-hand", name = "Aegis of the Vindicator", sources = { [14]=13154 } },
                { id = 28783, slot = "Ranged", name = "Eredar Wand of Obliteration", sources = { [14]=12729 } },
                { id = 28782, slot = "Two-Hand", name = "Crystalheart Pulse-Staff", sources = { [14]=12728 } },
                { id = 28774, slot = "Two-Hand", name = "Glaive of the Pit", sources = { [14]=12720 } },
                { id = 28779, slot = "Waist", name = "Girdle of the Endless Pit", sources = { [14]=12725 } },
                { id = 28778, slot = "Waist", name = "Terror Pit Girdle", sources = { [14]=12724 } },
            },
        },
    },

    routing = {

        -- 1. Magtheridon
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Magtheridon",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 331 },
                    kind    = "path",
                    note    = "After zoning in, follow the southern path to reach ^Magtheridon^.",
                    minNote = "South to Magtheridon",
                    points  = {
                        { 0.651, 0.183 },
                        { 0.688, 0.254 },
                        { 0.686, 0.562 },
                        { 0.572, 0.669 },
                        { 0.571, 0.769 },
                        { 0.587, 0.838 },
                        { 0.618, 0.903 },
                        { 0.690, 0.936 },
                        { 0.690, 0.783 },
                    },
                },
            },
        },
    },
}
