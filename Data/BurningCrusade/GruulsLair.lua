-------------------------------------------------------------------------------
-- RetroRuns Data -- Gruul's Lair
-- Burning Crusade, Patch 2.0.3  |  instanceID: 565  |  journalInstanceID: 746
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[565] = {
    instanceID        = 565,
    journalInstanceID = 746,
    name              = "Gruul's Lair",
    expansion         = "Burning Crusade",
    patch             = "2.0.3",

    exitNote          = "None available",

    -- The raid runs at 25-player only. One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Blade's Edge Mountains, north of Mok'Nathal Village.
        mapID = 105, x = 0.6935, y = 0.2354,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [330] = "Gruul's Lair",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [29762] = 1,   -- Pauldrons of the Fallen Hero
            [29763] = 1,   -- Pauldrons of the Fallen Champion
            [29764] = 1,   -- Pauldrons of the Fallen Defender
            [29765] = 2,   -- Leggings of the Fallen Hero
            [29766] = 2,   -- Leggings of the Fallen Champion
            [29767] = 2,   -- Leggings of the Fallen Defender
        },
    },

    bosses = {
        {
            index              = 1,
            name               = "High King Maulgar",
            journalEncounterID = 1564,
            achievements       = {},
            loot = {
                { id = 28797, slot = "Back", name = "Brute Cloak of the Ogre-Magi", sources = { [14]=12734 } },
                { id = 28796, slot = "Head", name = "Malefic Mask of the Shadows", sources = { [14]=12733 } },
                { id = 28801, slot = "Head", name = "Maulgar's Warhelm", sources = { [14]=12737 } },
                { id = 29037, slot = "Shoulder", name = "Cyclone Shoulderguards", sources = { [14]=12916 }, classes = { 7 } },
                { id = 29031, slot = "Shoulder", name = "Cyclone Shoulderpads", sources = { [14]=12910 }, classes = { 7 } },
                { id = 29043, slot = "Shoulder", name = "Cyclone Shoulderplates", sources = { [14]=12921 }, classes = { 7 } },
                { id = 29084, slot = "Shoulder", name = "Demon Stalker Shoulderguards", sources = { [14]=12960 }, classes = { 3 } },
                { id = 29064, slot = "Shoulder", name = "Justicar Pauldrons", sources = { [14]=12940 }, classes = { 2 } },
                { id = 29070, slot = "Shoulder", name = "Justicar Shoulderguards", sources = { [14]=12946 }, classes = { 2 } },
                { id = 29075, slot = "Shoulder", name = "Justicar Shoulderplates", sources = { [14]=12951 }, classes = { 2 } },
                { id = 29054, slot = "Shoulder", name = "Light-Mantle of the Incarnate", sources = { [14]=12930 }, classes = { 5 } },
                { id = 29100, slot = "Shoulder", name = "Mantle of Malorne", sources = { [14]=12976 }, classes = { 11 } },
                { id = 29047, slot = "Shoulder", name = "Netherblade Shoulderpads", sources = { [14]=12925 }, classes = { 4 } },
                { id = 29095, slot = "Shoulder", name = "Pauldrons of Malorne", sources = { [14]=12971 }, classes = { 11 } },
                { id = 29079, slot = "Shoulder", name = "Pauldrons of the Aldor", sources = { [14]=12955 }, classes = { 8 } },
                { id = 29089, slot = "Shoulder", name = "Shoulderguards of Malorne", sources = { [14]=12965 }, classes = { 11 } },
                { id = 29060, slot = "Shoulder", name = "Soul-Mantle of the Incarnate", sources = { [14]=12936 }, classes = { 5 } },
                { id = 28967, slot = "Shoulder", name = "Voidheart Mantle", sources = { [14]=12854 }, classes = { 9 } },
                { id = 29016, slot = "Shoulder", name = "Warbringer Shoulderguards", sources = { [14]=12900 }, classes = { 1 } },
                { id = 29023, slot = "Shoulder", name = "Warbringer Shoulderplates", sources = { [14]=12906 }, classes = { 1 } },
                { id = 28800, slot = "Two-Hand", name = "Hammer of the Naaru", sources = { [14]=12736 } },
                { id = 28799, slot = "Waist", name = "Belt of Divine Inspiration", sources = { [14]=12735 } },
                { id = 28795, slot = "Wrist", name = "Bladespire Warbands", sources = { [14]=12732 } },
            },
        },
        {
            index              = 2,
            name               = "Gruul the Dragonkiller",
            journalEncounterID = 1565,
            achievements       = {},
            loot = {
                { id = 28810, slot = "Feet", name = "Windshear Boots", sources = { [14]=12746 } },
                { id = 28824, slot = "Hands", name = "Gauntlets of Martial Perfection", sources = { [14]=12757 } },
                { id = 28827, slot = "Hands", name = "Gauntlets of the Dragonslayer", sources = { [14]=12760 } },
                { id = 28804, slot = "Head", name = "Collar of Cho'gall", sources = { [14]=12740 } },
                { id = 28803, slot = "Head", name = "Cowl of Nature's Breath", sources = { [14]=12739 } },
                { id = 29094, slot = "Legs", name = "Britches of Malorne", sources = { [14]=12970 }, classes = { 11 } },
                { id = 29030, slot = "Legs", name = "Cyclone Kilt", sources = { [14]=12909 }, classes = { 7 } },
                { id = 29036, slot = "Legs", name = "Cyclone Legguards", sources = { [14]=12915 }, classes = { 7 } },
                { id = 29042, slot = "Legs", name = "Cyclone War-Kilt", sources = { [14]=12920 }, classes = { 7 } },
                { id = 29083, slot = "Legs", name = "Demon Stalker Greaves", sources = { [14]=12959 }, classes = { 3 } },
                { id = 29099, slot = "Legs", name = "Greaves of Malorne", sources = { [14]=12975 }, classes = { 11 } },
                { id = 29074, slot = "Legs", name = "Justicar Greaves", sources = { [14]=12950 }, classes = { 2 } },
                { id = 29063, slot = "Legs", name = "Justicar Leggings", sources = { [14]=12939 }, classes = { 2 } },
                { id = 29069, slot = "Legs", name = "Justicar Legguards", sources = { [14]=12945 }, classes = { 2 } },
                { id = 29059, slot = "Legs", name = "Leggings of the Incarnate", sources = { [14]=12935 }, classes = { 5 } },
                { id = 29088, slot = "Legs", name = "Legguards of Malorne", sources = { [14]=12964 }, classes = { 11 } },
                { id = 29078, slot = "Legs", name = "Legwraps of the Aldor", sources = { [14]=12954 }, classes = { 8 } },
                { id = 29046, slot = "Legs", name = "Netherblade Breeches", sources = { [14]=12924 }, classes = { 4 } },
                { id = 29053, slot = "Legs", name = "Trousers of the Incarnate", sources = { [14]=12929 }, classes = { 5 } },
                { id = 28966, slot = "Legs", name = "Voidheart Leggings", sources = { [14]=12853 }, classes = { 9 } },
                { id = 29022, slot = "Legs", name = "Warbringer Greaves", sources = { [14]=12905 }, classes = { 1 } },
                { id = 29015, slot = "Legs", name = "Warbringer Legguards", sources = { [14]=12899 }, classes = { 1 } },
                { id = 28825, slot = "Off-hand", name = "Aldori Legacy Defender", sources = { [14]=12758 } },
                { id = 28794, slot = "Two-Hand", name = "Axe of the Gronn Lords", sources = { [14]=12731 } },
                { id = 28828, slot = "Waist", name = "Gronn-Stitched Girdle", sources = { [14]=12761 } },
                { id = 28802, slot = "Weapon", name = "Bloodmaw Magus-Blade", sources = { [14]=12738 } },
            },
        },
    },

    routing = {

        -- 1. High King Maulgar
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "High King Maulgar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 330 },
                    kind    = "path",
                    note    = "After zoning in, proceed ahead to ^High King Maulgar^.",
                    minNote = "Ahead to High King Maulgar",
                    points  = {
                        { 0.767, 0.777 },
                        { 0.692, 0.773 },
                        { 0.617, 0.720 },
                        { 0.548, 0.610 },
                    },
                },
            },
        },

        -- 2. Gruul the Dragonkiller
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Gruul the Dragonkiller",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 330 },
                    kind    = "path",
                    note    = "After defeating ^High King Maulgar^, continue up the path to ^Gruul the Dragonkiller^.",
                    minNote = "Continue to Gruul",
                    points  = {
                        { 0.507, 0.649 },
                        { 0.427, 0.690 },
                        { 0.297, 0.651 },
                        { 0.219, 0.619 },
                        { 0.206, 0.541 },
                        { 0.200, 0.324 },
                    },
                },
            },
        },
    },
}
