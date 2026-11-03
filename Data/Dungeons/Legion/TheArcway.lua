-------------------------------------------------------------------------------
-- RetroRuns Data -- The Arcway
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1516  |  journalInstanceID: 726
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

-- The east door's route: General Xakal first.
local eastRoute = {
    -- 1. General Xakal (boss 3).
    {
        step      = 1,
        priority  = 1,
        bossIndex = 3,
        title     = "General Xakal",
        requires  = { },
        segments  = {
            {
                when    = { mapID = 749 },
                kind    = "path",
                note    = "After zoning in, follow the eastern path to ^General Xakal^.",
                minNote = "Eastern path to Xakal",
                points  = {
                    { 0.481, 0.269 },
                    { 0.482, 0.323 },
                    { 0.510, 0.339 },
                    { 0.534, 0.361 },
                    { 0.634, 0.360 },
                    { 0.648, 0.285 },
                    { 0.730, 0.286 },
                    { 0.732, 0.468 },
                },
            },
        },
    },
    -- 2. Nal'tira (boss 4).
    {
        step      = 2,
        priority  = 1,
        bossIndex = 4,
        title     = "Nal'tira",
        requires  = { },
        segments  = {
            {
                when    = { mapID = 749 },
                kind    = "path",
                note    = "After defeating ^General Xakal^, backtrack north and follow the path around and south to ^Nal'tira^. Kill several waves of spiders and the boss will eventually drop from the ceiling.",
                minNote = "Around and south to Nal'tira",
                points  = {
                    { 0.731, 0.451 },
                    { 0.732, 0.286 },
                    { 0.673, 0.285 },
                    { 0.653, 0.293 },
                    { 0.670, 0.348 },
                    { 0.671, 0.447 },
                    { 0.671, 0.536 },
                    { 0.652, 0.616 },
                    { 0.627, 0.692 },
                },
            },
        },
    },
    -- 3. Corstilax (boss 2).
    {
        step      = 3,
        priority  = 1,
        bossIndex = 2,
        title     = "Corstilax",
        requires  = { },
        segments  = {
            {
                when    = { mapID = 749 },
                kind    = "path",
                note    = "After defeating ^Nal'tira^, follow the path west to reach ^Corstilax^.",
                minNote = "West to Corstilax",
                points  = {
                    { 0.592, 0.755 },
                    { 0.481, 0.755 },
                    { 0.480, 0.650 },
                    { 0.438, 0.627 },
                    { 0.402, 0.738 },
                },
            },
        },
    },
    -- 4. Ivanyr (boss 1).
    {
        step      = 4,
        priority  = 1,
        bossIndex = 1,
        title     = "Ivanyr",
        requires  = { },
        segments  = {
            {
                when    = { mapID = 749 },
                kind    = "path",
                note    = "After killing ^Corstilax^, exit northwest and follow the western path to ^Ivanyr^.",
                minNote = "Exit northwest, follow path to Ivanyr",
                points  = {
                    { 0.386, 0.742 },
                    { 0.381, 0.678 },
                    { 0.355, 0.604 },
                    { 0.191, 0.736 },
                },
            },
        },
    },
    -- 5. Advisor Vandros (boss 5), once the first four are dead.
    {
        step      = 5,
        priority  = 1,
        bossIndex = 5,
        title     = "Advisor Vandros",
        requires  = { },
        segments  = {
            {
                when    = { mapID = 749 },
                kind    = "path",
                note    = "After killing ^Ivanyr^, backtrack to the main hallway and go north. Follow the path to ^Advisor Vandros^.",
                minNote = "Backtrack to main hallway, north to Vandros",
                points  = {
                    { 0.225, 0.707 },
                    { 0.355, 0.604 },
                    { 0.330, 0.534 },
                    { 0.330, 0.501 },
                    { 0.332, 0.361 },
                    { 0.431, 0.361 },
                    { 0.449, 0.362 },
                },
            },
        },
    },
}

RetroRuns_DungeonData[726] = {
    kind              = "dungeon",
    instanceID        = 1516,
    journalInstanceID = 726,
    name              = "The Arcway",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 15, 16 },
    unsavedDifficulties = { 15 },
    patch             = "7.0.3",
    routedIn          = "3.5.0",

    entrance = {
        mapID = 680,
        x     = 0.4103,
        y     = 0.6192,
    },

    gloryMeta = {
        id   = 11163,
        name = "Glory of the Legion Hero",
        rewardItemID       = 141217,
        rewardMountSpellID = 225765,
        rewardName         = "Leyfeather Hippogryph",
    },

    bosses = {
        {
            index              = 1,
            name               = "Ivanyr",
            journalEncounterID = 1497,
            dungeonEncounterID = 1827,
            achievements       = {
                { id = 10773, name = "Arcanic Cling", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 134501, slot = "Chest", name = "Crackling Overcharge Chestguard", sources = { [14]=78986, [15]=79943, [16]=78986 } },
                { id = 134298, slot = "Feet", name = "Ley Dragoon's Stompers", sources = { [15]=77572, [16]=77572 } },
                { id = 137397, slot = "Feet", name = "Tunnel Trudger Footguards", sources = { [14]=78983, [15]=80095, [16]=78983 } },
                { id = 134421, slot = "Hands", name = "Ink-Smudged Handwraps", sources = { [14]=78981, [15]=80010, [16]=78981 } },
                { id = 134467, slot = "Hands", name = "Nether Mindsnappers", sources = { [14]=78984, [15]=80127, [16]=78984 } },
                { id = 134309, slot = "Shoulder", name = "Manawracker Shoulders", sources = { [15]=77583, [16]=77583 } },
                { id = 134269, slot = "Waist", name = "Arcane Defender's Belt", sources = { [15]=77553, [16]=77553 } },
                { id = 134280, slot = "Wrist", name = "Swordsinger's Wristguards", sources = { [15]=77561, [16]=77561 } },
            },
        },
        {
            index              = 2,
            name               = "Corstilax",
            journalEncounterID = 1498,
            dungeonEncounterID = 1825,
            achievements       = {
                { id = 10775, name = "Clean House", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 134402, slot = "Back", name = "Cape of Rigid Order", sources = { [14]=78989, [15]=80807, [16]=78989 } },
                { id = 134463, slot = "Chest", name = "Decontaminated Chain Tunic", sources = { [14]=78985, [15]=80123, [16]=78985 } },
                { id = 134424, slot = "Head", name = "Collar of Enclosure", sources = { [14]=78987, [15]=80013, [16]=78987 } },
                { id = 134453, slot = "Shoulder", name = "Spaulders of Aberrant Inhibition", sources = { [14]=78982, [15]=80078, [16]=78982 } },
                { id = 134522, slot = "Wrist", name = "Detention Wristclamps", sources = { [14]=78988, [15]=79964, [16]=78988 } },
            },
        },
        {
            index              = 3,
            name               = "General Xakal",
            journalEncounterID = 1499,
            dungeonEncounterID = 1828,
            achievements       = {
            },
            loot = {
                { id = 134373, slot = "Chest", name = "Felbat Leather Vest", sources = { [15]=77634, [16]=77634 } },
                { id = 134396, slot = "Feet", name = "Netherwhisper Slippers", sources = { [15]=77650, [16]=77650 } },
                { id = 134509, slot = "Hands", name = "Fists of the Legion", sources = { [14]=78993, [15]=79951, [16]=78993 } },
                { id = 134387, slot = "Head", name = "Mardum Chain Helm", sources = { [15]=77641, [16]=77641 } },
                { id = 134449, slot = "Legs", name = "Bloodclaw Leggings", sources = { [14]=78991, [15]=80074, [16]=78991 } },
                { id = 137404, slot = "Legs", name = "Legwraps of Reverberating Shadows", sources = { [14]=78990, [15]=80037, [16]=78990 } },
                { id = 134359, slot = "Legs", name = "Portalguard Legplates", sources = { [15]=77623, [16]=77623 } },
                { id = 137405, slot = "Wrist", name = "Remorseless Chain Armbands", sources = { [14]=78992, [15]=80156, [16]=78992 } },
            },
        },
        {
            index              = 4,
            name               = "Nal'tira",
            journalEncounterID = 1500,
            dungeonEncounterID = 1826,
            achievements       = {
            },
            loot = {
                { id = 134410, slot = "Back", name = "Cloak of Mana-Spun Silk", sources = { [14]=78998, [15]=80813, [16]=78998 } },
                { id = 137410, slot = "Head", name = "Greathelm of Barbed Chelicerae", sources = { [14]=78997, [15]=79976, [16]=78997 } },
                { id = 134472, slot = "Shoulder", name = "Arcane Exterminator's Shoulderguards", sources = { [14]=78996, [15]=80132, [16]=78996 } },
                { id = 137409, slot = "Waist", name = "Manafang Waistguard", sources = { [14]=78995, [15]=80096, [16]=78995 } },
                { id = 134435, slot = "Wrist", name = "Tunnel Fiend Bracers", sources = { [14]=78994, [15]=80023, [16]=78994 } },
            },
        },
        {
            index              = 5,
            name               = "Advisor Vandros",
            journalEncounterID = 1501,
            dungeonEncounterID = 1829,
            achievements       = {
                { id = 10776, name = "No Time to Waste", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 134267, slot = "Chest", name = "Arcane Defender's Breastplate", sources = { [15]=77551, [16]=77551 } },
                { id = 134413, slot = "Chest", name = "Fluxflow Robes", sources = { [14]=78999, [15]=80002, [16]=78999 } },
                { id = 137417, slot = "Feet", name = "Treads of Fates Entwined", sources = { [14]=79006, [15]=79977, [16]=79006 } },
                { id = 134297, slot = "Hands", name = "Ley Dragoon's Gloves", sources = { [15]=77571, [16]=77571 } },
                { id = 134444, slot = "Hands", name = "Mana-Lanced Gloves", sources = { [14]=79001, [15]=80069, [16]=79001 } },
                { id = 137415, slot = "Head", name = "Gaze of Fleeting Hours", sources = { [14]=79002, [15]=80097, [16]=79002 } },
                { id = 134304, slot = "Head", name = "Manawracker Crown", sources = { [15]=77578, [16]=77578 } },
                { id = 134475, slot = "Legs", name = "Mute Erasure Legguards", sources = { [14]=79003, [15]=80135, [16]=79003 } },
                { id = 134518, slot = "Shoulder", name = "Frozen Pendulum Shoulderguards", sources = { [14]=79005, [15]=79960, [16]=79005 } },
                { id = 134286, slot = "Shoulder", name = "Swordsinger's Shoulders", sources = { [15]=77567, [16]=77567 } },
                { id = 137416, slot = "Waist", name = "Chain of Causal Links", sources = { [14]=79004, [15]=80157, [16]=79004 } },
                { id = 137413, slot = "Waist", name = "Time-Breached Waistband", sources = { [14]=79000, [15]=80038, [16]=79000 } },
            },
        },
    },

    exitNote    = "Exit portal to the north",
    minExitNote = "Exit portal to the north",

    -- The open door picks the route: each layout is named by the locked-door
    -- markers only it shows. A layout without its own routing runs this file's.
    layoutMap = 749,
    layouts = {
        { key = "west", areaPois = { 5069, 5082, 5086, 5089 } },
        { key = "east", areaPois = { 5071, 5072, 5081, 5085, 5088 }, routing = eastRoute },
    },

    routing = {
        -- 1. Ivanyr (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Ivanyr",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 749 },
                    kind    = "path",
                    note    = "After zoning in, follow the western path to ^Ivanyr^.",
                    minNote = "Western path to Ivanyr",
                    points  = {
                        { 0.481, 0.269 },
                        { 0.482, 0.323 },
                        { 0.454, 0.339 },
                        { 0.431, 0.361 },
                        { 0.332, 0.361 },
                        { 0.330, 0.501 },
                        { 0.330, 0.534 },
                        { 0.355, 0.604 },
                        { 0.191, 0.736 },
                    },
                },
            },
        },
        -- 2. Corstilax (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Corstilax",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 749 },
                    kind    = "path",
                    note    = "After killing ^Ivanyr^, backtrack to the main hallway and go south to reach ^Corstilax^.",
                    minNote = "Backtrack then south to Corstilax",
                    points  = {
                        { 0.225, 0.707 },
                        { 0.355, 0.604 },
                        { 0.381, 0.678 },
                        { 0.386, 0.742 },
                    },
                },
            },
        },
        -- 3. Nal'tira (boss 4).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 4,
            title     = "Nal'tira",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 749 },
                    kind    = "path",
                    note    = "After defeating ^Corstilax^, follow the path east to reach ^Nal'tira^. Kill several waves of spiders and the boss will eventually drop from the ceiling.",
                    minNote = "East to Nal'tira",
                    points  = {
                        { 0.402, 0.738 },
                        { 0.438, 0.627 },
                        { 0.480, 0.650 },
                        { 0.481, 0.755 },
                        { 0.592, 0.755 },
                    },
                },
            },
        },
        -- 4. General Xakal (boss 3).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 3,
            title     = "General Xakal",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 749 },
                    kind    = "path",
                    note    = "After defeating ^Nal'tira^, go north and follow the path around to ^General Xakal^.",
                    minNote = "North path, around to Xakal",
                    points  = {
                        { 0.627, 0.692 },
                        { 0.652, 0.616 },
                        { 0.671, 0.536 },
                        { 0.671, 0.447 },
                        { 0.670, 0.348 },
                        { 0.653, 0.293 },
                        { 0.673, 0.285 },
                        { 0.732, 0.286 },
                        { 0.732, 0.468 },
                    },
                },
            },
        },
        -- 5. Advisor Vandros (boss 5), once the first four are dead.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Advisor Vandros",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 749 },
                    kind    = "path",
                    note    = "After defeating ^General Xakal^, backtrack north then go west to reach the final boss, ^Advisor Vandros^.",
                    minNote = "Backtrack north then west to Vandros",
                    points  = {
                        { 0.731, 0.451 },
                        { 0.730, 0.286 },
                        { 0.648, 0.285 },
                        { 0.634, 0.360 },
                        { 0.519, 0.362 },
                    },
                },
            },
        },
    },
}
