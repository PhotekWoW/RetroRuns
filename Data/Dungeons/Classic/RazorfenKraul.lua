-------------------------------------------------------------------------------
-- RetroRuns Data -- Razorfen Kraul
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 47  |  journalInstanceID: 234
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[234] = {
    kind              = "dungeon",
    instanceID        = 47,
    journalInstanceID = 234,
    name              = "Razorfen Kraul",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 199,
        x     = 0.4062,
        y     = 0.9429,
    },

    trashLoot = {
        { id = 1488, slot = "Chest", name = "Avenger's Armor", sources = { [14]=310 }, bind = "BoE" },
        { id = 3569, slot = "Chest", name = "Vicar's Robe", sources = { [14]=1330 }, bind = "BoE" },
        { id = 1978, slot = "Hands", name = "Wolfclaw Gloves", sources = { [14]=517 }, bind = "BoE" },
        { id = 2264, slot = "Shoulder", name = "Mantle of Thieves", sources = { [14]=711 }, bind = "BoE" },
        { id = 1975, slot = "Two-Hand", name = "Pysan's Old Greatsword", sources = { [14]=515 }, bind = "BoE" },
        { id = 1976, slot = "Two-Hand", name = "Slaghammer", sources = { [14]=516 }, bind = "BoE" },
        { id = 2549, slot = "Two-Hand", name = "Staff of the Shade", sources = { [14]=860 }, bind = "BoE" },
        { id = 1727, slot = "Weapon", name = "Sword of Decay", sources = { [14]=364 }, bind = "BoE" },
        { id = 12974, slot = "Weapon", name = "The Black Knight", sources = { [14]=4619 }, bind = "BoE", rareNpc = "Enormous Bullfrog" },
        { id = 776, slot = "Weapon", name = "Vendetta", sources = { [14]=84 }, bind = "BoE" },
        { id = 4438, slot = "Wrist", name = "Pugilist Bracers", sources = { [14]=1722 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Hunter Bonetusk",
            journalEncounterID = 896,
            dungeonEncounterID = 1656,
            achievements       = {
            },
            loot = {
                { id = 151442, slot = "Back", name = "Bonetusk Greatcloak", sources = { [14]=89441 } },
                { id = 6689, slot = "Two-Hand", name = "Wind Spirit Staff", sources = { [14]=2574 } },
                { id = 6681, slot = "Weapon", name = "Thornspike", sources = { [14]=2568 } },
            },
        },
        {
            index              = 2,
            name               = "Roogug",
            journalEncounterID = 895,
            dungeonEncounterID = 438,
            achievements       = {
            },
            loot = {
                { id = 132565, slot = "Legs", name = "Carnal Britches", sources = { [14]=76398 } },
                { id = 6690, slot = "Legs", name = "Ferine Leggings", sources = { [14]=2575 } },
                { id = 6691, slot = "Weapon", name = "Swinetusk Shank", sources = { [14]=2576 } },
                { id = 151443, slot = "Waist", name = "Roogug's Swinesteel Girdle", sources = { [14]=89442 } },
            },
        },
        {
            index              = 3,
            name               = "Warlord Ramtusk",
            journalEncounterID = 899,
            dungeonEncounterID = 1659,
            achievements       = {
            },
            loot = {
                { id = 6686, slot = "Head", name = "Tusken Helm", sources = { [14]=2571 } },
                { id = 6688, slot = "Head", name = "Whisperwind Headdress", sources = { [14]=2573 } },
                { id = 151445, slot = "Legs", name = "Porcine-Warlord's Legplates", sources = { [14]=89443 } },
                { id = 6685, slot = "Shoulder", name = "Death Speaker Mantle", sources = { [14]=2570 } },
                { id = 6687, slot = "Two-Hand", name = "Corpsemaker", sources = { [14]=2572 } },
            },
        },
        {
            index              = 4,
            name               = "Groyat, the Blind Hunter",
            journalEncounterID = 900,
            dungeonEncounterID = 1660,
            achievements       = {
            },
            loot = {
                { id = 6696, slot = "Ranged", name = "Nightstalker Bow", sources = { [14]=2579 } },
                { id = 6697, slot = "Shoulder", name = "Batwing Mantle", sources = { [14]=2580 } },
            },
        },
        {
            index              = 5,
            name               = "Charlga Razorflank",
            journalEncounterID = 901,
            dungeonEncounterID = 1661,
            achievements       = {
            },
            loot = {
                { id = 6694, slot = "Off-hand", name = "Heart of Agamaggan", sources = { [14]=2578 } },
                { id = 6692, slot = "Weapon", name = "Pronged Reaver", sources = { [14]=2577 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    pois = {
        -- Rare spawn points; the first is his in-game capture.
        { mapID = 301, poiKind = "rare", rareNpc = "Enormous Bullfrog",
          mapLabelPos = "lower-right", points = { { 0.113, 0.330 }, { 0.120, 0.380 }, { 0.218, 0.322 } } },
    },
    -- Step order matches journal order here, and step number matches
    -- boss index throughout.
    routing = {
        -- 1. Hunter Bonetusk (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Hunter Bonetusk",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 301 },
                    kind    = "path",
                    note    = "After zoning in, take a right at the fork and follow the path to ^Hunter Bonetusk^.",
                    minNote = "Right at fork for Bonetusk",
                    points  = {
                        { 0.657, 0.814 },
                        { 0.636, 0.809 },
                        { 0.624, 0.778 },
                        { 0.623, 0.715 },
                        { 0.660, 0.707 },
                        { 0.700, 0.683 },
                        { 0.766, 0.664 },
                        { 0.823, 0.576 },
                        { 0.842, 0.552 },
                        { 0.851, 0.494 },
                        { 0.823, 0.447 },
                        { 0.800, 0.414 },
                        { 0.780, 0.391 },
                        { 0.760, 0.393 },
                        { 0.740, 0.355 },
                        { 0.700, 0.348 },
                        { 0.693, 0.380 },
                        { 0.711, 0.399 },
                        { 0.744, 0.426 },
                        { 0.786, 0.450 },
                        { 0.797, 0.481 },
                    },
                },
            },
        },

        -- 2. Roogug (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Roogug",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 301 },
                    kind    = "path",
                    note    = "After killing ^Hunter Bonetusk^, backtrack then go northeast to reach ^Roogug^.",
                    minNote = "Northeast to Roogug",
                    points  = {
                        { 0.796, 0.475 },
                        { 0.765, 0.434 },
                        { 0.725, 0.404 },
                        { 0.692, 0.382 },
                        { 0.686, 0.350 },
                        { 0.733, 0.304 },
                        { 0.774, 0.337 },
                        { 0.803, 0.371 },
                        { 0.849, 0.403 },
                    },
                },
            },
        },

        -- 3. Warlord Ramtusk (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Warlord Ramtusk",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 301 },
                    kind    = "path",
                    note    = "After defeating ^Roogug^, go west to reach ^Warlord Ramtusk^.",
                    minNote = "West to Warlord Ramtusk",
                    points  = {
                        { 0.844, 0.398 },
                        { 0.792, 0.366 },
                        { 0.751, 0.319 },
                        { 0.722, 0.314 },
                        { 0.684, 0.351 },
                        { 0.628, 0.343 },
                        { 0.623, 0.292 },
                        { 0.597, 0.285 },
                    },
                },
            },
        },

        -- 4. Groyat, the Blind Hunter (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Groyat, the Blind Hunter",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 301 },
                    kind    = "path",
                    note    = "After defeating ^Warlord Ramtusk^, take the long path west, crossing over several bridges on the way to ^Groyat, the Blind Hunter^.",
                    minNote = "West to Groyat",
                    points  = {
                        { 0.575, 0.359 },
                        { 0.586, 0.420 },
                        { 0.562, 0.439 },
                        { 0.508, 0.455 },
                        { 0.468, 0.485 },
                        { 0.417, 0.541 },
                        { 0.392, 0.521 },
                        { 0.320, 0.489 },
                        { 0.225, 0.481 },
                        { 0.196, 0.558 },
                        { 0.119, 0.551 },
                    },
                },
            },
        },

        -- 5. Charlga Razorflank (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Charlga Razorflank",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 301 },
                    kind    = "path",
                    note    = "After killing ^Groyat^, continue northeast to the final boss, ^Charlga Razorflank^. Stop and kill ^Enormous Bullfrog^ for BoE rares on the way.",
                    minNote = "Northeast to Charlga",
                    points  = {
                        { 0.088, 0.512 },
                        { 0.092, 0.444 },
                        { 0.134, 0.368 },
                        { 0.180, 0.381 },
                        { 0.201, 0.344 },
                    },
                },
            },
        },
    },
}
