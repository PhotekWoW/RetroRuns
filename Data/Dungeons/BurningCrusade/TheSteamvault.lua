-------------------------------------------------------------------------------
-- RetroRuns Data -- The Steamvault
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 545  |  journalInstanceID: 261
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[261] = {
    kind              = "dungeon",
    instanceID        = 545,
    journalInstanceID = 261,
    name              = "The Steamvault",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.1.1",

    entrance = {
        mapID = 102,
        x     = 0.5020,
        y     = 0.3332,
    },

    bosses = {
        {
            index              = 1,
            name               = "Hydromancer Thespia",
            journalEncounterID = 573,
            dungeonEncounterID = 1942,
            achievements       = {
            },
            loot = {
                { id = 27789, slot = "Back", name = "Cloak of Whispering Shells", sources = { [14]=12065, [15]=12065 } },
                { id = 27806, slot = "Hands", name = "Fathomheart Gauntlets", sources = { [14]=12080, [15]=12080 } },
                { id = 27475, slot = "Hands", name = "Gauntlets of the Bold", sources = { [14]=11923, [15]=11923 }, setName = "Bold Armor", dungeonSet = 3 },
                { id = 27508, slot = "Hands", name = "Incanter's Gloves", sources = { [14]=11942, [15]=11942 }, setName = "Incanter's Regalia", dungeonSet = 3 },
                { id = 27783, slot = "Waist", name = "Moonrage Girdle", sources = { [14]=12062, [15]=12062 } },
            },
        },
        {
            index              = 2,
            name               = "Mekgineer Steamrigger",
            journalEncounterID = 574,
            dungeonEncounterID = 1943,
            achievements       = {
            },
            loot = {
                { id = 27787, slot = "Chest", name = "Chestguard of No Remorse", sources = { [14]=12063, [15]=12063 } },
                { id = 27793, slot = "Hands", name = "Earth Mantle Handwraps", sources = { [14]=12068, [15]=12068 } },
                { id = 27790, slot = "Head", name = "Mask of Penance", sources = { [14]=12066, [15]=12066 } },
                { id = 27794, slot = "Ranged", name = "Recoilless Rocket Ripper X-54", sources = { [14]=12069, [15]=12069 } },
                { id = 27791, slot = "Two-Hand", name = "Serpentcrest Life-Staff", sources = { [14]=12067, [15]=12067 } },
                { id = 27795, slot = "Waist", name = "Sash of Serpentra", sources = { [14]=12070, [15]=12070 } },
            },
        },
        {
            index              = 3,
            name               = "Warlord Kalithresh",
            journalEncounterID = 575,
            dungeonEncounterID = 1944,
            achievements       = {
            },
            loot = {
                { id = 27804, slot = "Back", name = "Devilshark Cape", sources = { [14]=12079, [15]=12079 } },
                { id = 28203, slot = "Chest", name = "Breastplate of the Righteous", sources = { [14]=12325, [15]=12325 }, setName = "Righteous Armor", dungeonSet = 3 },
                { id = 27799, slot = "Chest", name = "Vermillion Robes of the Dominant", sources = { [14]=12074, [15]=12074 } },
                { id = 27510, slot = "Hands", name = "Tidefury Gauntlets", sources = { [14]=11944, [15]=11944 }, setName = "Tidefury Raiment", dungeonSet = 3 },
                { id = 27874, slot = "Legs", name = "Beast Lord Leggings", sources = { [14]=12119, [15]=12119 }, setName = "Beast Lord Armor", dungeonSet = 3 },
                { id = 30543, slot = "Legs", name = "Pontifex Kilt", sources = { [14]=13812, [15]=13812 } },
                { id = 29351, slot = "Ranged", name = "Wrathtide Longbow", sources = { [14]=13096, [15]=13096 } },
                { id = 27801, slot = "Shoulder", name = "Beast Lord Mantle", sources = { [14]=12076, [15]=12076 }, setName = "Beast Lord Armor", dungeonSet = 3 },
                { id = 27738, slot = "Shoulder", name = "Incanter's Pauldrons", sources = { [14]=12029, [15]=12029 }, setName = "Incanter's Regalia", dungeonSet = 3 },
                { id = 27737, slot = "Shoulder", name = "Moonglade Shoulders", sources = { [14]=12028, [15]=12028 } },
                { id = 29463, slot = "Wrist", name = "Amber Bands of the Aggressor", sources = { [14]=13156, [15]=13156 } },
                { id = 29243, slot = "Wrist", name = "Wave-Fury Vambraces", sources = { [14]=13038, [15]=13038 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Hydromancer Thespia (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Hydromancer Thespia",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 263 },
                    kind    = "path",
                    note    = "After zoning in, proceed east through the room, climbing a short ramp to the north which leads to ^Hydromancer Thespia^.",
                    minNote = "East to Hydromancer",
                    points  = {
                        { 0.200, 0.280 },
                        { 0.262, 0.284 },
                        { 0.301, 0.276 },
                        { 0.338, 0.233 },
                        { 0.496, 0.230 },
                        { 0.530, 0.189 },
                    },
                },
            },
        },
        -- 2. Mekgineer Steamrigger (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Mekgineer Steamrigger",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 263 },
                    kind        = "poi",
                    note        = "After killing ^Hydromancer Thespia^, click the ^Main Chambers Access Panel^ behind her.",
                    minNote     = "Click access panel",
                    mapLabel    = "Click Access Panel",
                    mapLabelPos = "right",
                    completionCheck = true,
                    triggeredBy = { dialog = { npc = "Coilfang Door Controller", match = "faint echo" } },
                    points      = {
                        { 0.541, 0.096 },
                    },
                },
                {
                    when    = { mapID = 263 },
                    kind    = "path",
                    note    = "After clicking the access panel, follow the long path south all the way to ^Mekgineer Steamrigger^.",
                    minNote = "Path south to Steamrigger",
                    points  = {
                        { 0.530, 0.186 },
                        { 0.424, 0.318 },
                        { 0.442, 0.398 },
                        { 0.481, 0.425 },
                        { 0.560, 0.443 },
                        { 0.530, 0.551 },
                        { 0.479, 0.557 },
                        { 0.480, 0.671 },
                        { 0.401, 0.671 },
                        { 0.392, 0.702 },
                        { 0.375, 0.716 },
                        { 0.356, 0.755 },
                        { 0.349, 0.785 },
                    },
                },
            },
        },
        -- 3. Warlord Kalithresh (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Warlord Kalithresh",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 263 },
                    kind        = "poi",
                    note        = "After defeating ^Mekgineer Steamrigger^, click the ^Main Chambers Access Panel^ behind him.",
                    minNote     = "Click access chamber",
                    mapLabel    = "Click Access Chamber",
                    mapLabelPos = "below",
                    completionCheck = true,
                    triggeredBy = { dialog = { npc = "Coilfang Door Controller", match = "loud rumble" } },
                    points      = {
                        { 0.313, 0.839 },
                    },
                },
                {
                    when    = { mapID = 263 },
                    kind    = "path",
                    note    = "After clicking the access panel, the door to the final boss will open. Backtrack northeast and follow the path east to ^Warlord Kalithresh^.",
                    minNote = "Northeast to Kalithresh",
                    points  = {
                        { 0.344, 0.772 },
                        { 0.382, 0.708 },
                        { 0.406, 0.675 },
                        { 0.474, 0.668 },
                        { 0.489, 0.556 },
                        { 0.536, 0.549 },
                        { 0.571, 0.417 },
                        { 0.663, 0.434 },
                        { 0.737, 0.434 },
                    },
                },
            },
        },
    },
}
