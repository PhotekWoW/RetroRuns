-------------------------------------------------------------------------------
-- RetroRuns Data -- The Stockade
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 34  |  journalInstanceID: 238
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[238] = {
    kind              = "dungeon",
    instanceID        = 34,
    journalInstanceID = 238,
    name              = "The Stockade",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 84,
        x     = 0.5032,
        y     = 0.6613,
    },

    bosses = {
        {
            index              = 1,
            name               = "Hogger",
            journalEncounterID = 464,
            dungeonEncounterID = 1144,
            achievements       = {
            },
            loot = {
                { id = 2168, slot = "Feet", name = "Corpse Rompers", sources = { [14]=641 } },
                { id = 1934, slot = "Legs", name = "Hogger's Trousers", sources = { [14]=499 } },
                { id = 132569, slot = "Legs", name = "Stolen Jailer's Greaves", sources = { [14]=76402 } },
                { id = 151074, slot = "Shoulder", name = "Turnkey's Pauldrons", sources = { [14]=89260 } },
                { id = 1959, slot = "Two-Hand", name = "Cold Iron Pick", sources = { [14]=511 } },
            },
        },
        {
            index              = 2,
            name               = "Lord Overheat",
            journalEncounterID = 465,
            dungeonEncounterID = 1145,
            achievements       = {
            },
            loot = {
                { id = 151075, slot = "Chest", name = "Cinderstitch Tunic", sources = { [14]=89261 } },
                { id = 4676, slot = "Hands", name = "Skeletal Gauntlets", sources = { [14]=1787 } },
                { id = 1929, slot = "Legs", name = "Silk-Threaded Trousers", sources = { [14]=496 } },
                { id = 5967, slot = "Waist", name = "Girdle of Nobility", sources = { [14]=2222 } },
                { id = 151076, slot = "Wrist", name = "Fire-Hardened Shackles", sources = { [14]=89284 } },
            },
        },
        {
            index              = 3,
            name               = "Randolph Moloch",
            journalEncounterID = 466,
            dungeonEncounterID = 1146,
            achievements       = {
            },
            loot = {
                { id = 63345, slot = "Chest", name = "Noble's Robe", sources = { [14]=31791 } },
                { id = 63344, slot = "Feet", name = "Standard Issue Prisoner Shoes", sources = { [14]=31790 } },
                { id = 132570, slot = "Feet", name = "Stolen Guards Chain Boots", sources = { [14]=76403 } },
                { id = 151077, slot = "Waist", name = "Cast Iron Waistplate", sources = { [14]=89302 } },
                { id = 63346, slot = "Weapon", name = "Wicked Dagger", sources = { [14]=31792 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Hogger (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Hogger",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 225 },
                    kind    = "path",
                    note    = "After zoning in, take the main pathway to the left to reach ^Hogger^.",
                    minNote = "Left path to Hogger",
                    points  = {
                        { 0.500, 0.594 },
                        { 0.500, 0.360 },
                        { 0.417, 0.363 },
                        { 0.341, 0.348 },
                        { 0.244, 0.286 },
                    },
                },
            },
        },

        -- 2. Lord Overheat (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Lord Overheat",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 225 },
                    kind    = "path",
                    note    = "After defeating ^Hogger^, take the path all the way to the right and you'll eventually reach ^Lord Overheat^.",
                    minNote = "Far path right to Lord Overheat",
                    points  = {
                        { 0.248, 0.295 },
                        { 0.315, 0.335 },
                        { 0.404, 0.363 },
                        { 0.503, 0.365 },
                        { 0.618, 0.368 },
                        { 0.676, 0.387 },
                        { 0.735, 0.420 },
                        { 0.760, 0.443 },
                    },
                },
            },
        },

        -- 3. Randolph Moloch (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Randolph Moloch",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 225 },
                    kind    = "path",
                    note    = "After killing ^Lord Overheat^, backtrack to the main path and go north to engage ^Randolph Moloch^.",
                    minNote = "North path to Randolph",
                    points  = {
                        { 0.740, 0.421 },
                        { 0.655, 0.373 },
                        { 0.570, 0.360 },
                        { 0.500, 0.360 },
                        { 0.498, 0.258 },
                    },
                },
            },
        },
    },
}
