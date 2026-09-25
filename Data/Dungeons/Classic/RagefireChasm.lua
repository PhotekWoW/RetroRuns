-------------------------------------------------------------------------------
-- RetroRuns Data -- Ragefire Chasm
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 389  |  journalInstanceID: 226
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[226] = {
    kind              = "dungeon",
    instanceID        = 389,
    journalInstanceID = 226,
    name              = "Ragefire Chasm",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 86,
        x     = 0.6900,
        y     = 0.5030,
    },

    bosses = {
        {
            index              = 1,
            name               = "Adarogg",
            journalEncounterID = 694,
            dungeonEncounterID = 1443,
            achievements       = {
            },
            loot = {
                { id = 151421, slot = "Feet", name = "Scorched Blazehound Boots", sources = { [14]=89425 } },
                { id = 82772, slot = "Legs", name = "Snarlmouth Leggings", sources = { [14]=42093 } },
                { id = 151422, slot = "Waist", name = "Bonecoal Waistguard", sources = { [14]=89426 } },
                { id = 82880, slot = "Weapon", name = "Fang of Adarogg", sources = { [14]=42162 } },
                { id = 82879, slot = "Wrist", name = "Collarspike Bracers", sources = { [14]=42161 } },
            },
        },
        {
            index              = 2,
            name               = "Dark Shaman Koranthal",
            journalEncounterID = 695,
            dungeonEncounterID = 1444,
            achievements       = {
            },
            loot = {
                { id = 82882, slot = "Back", name = "Dark Ritual Cape", sources = { [14]=42164 } },
                { id = 132551, slot = "Chest", name = "Dark Shaman's Jerkin", sources = { [14]=76386 } },
                { id = 82877, slot = "Chest", name = "Grasp of the Broken Totem", sources = { [14]=42159 } },
                { id = 82881, slot = "Wrist", name = "Cuffs of Black Elements", sources = { [14]=42163 } },
            },
        },
        {
            index              = 3,
            name               = "Slagmaw",
            journalEncounterID = 696,
            dungeonEncounterID = 1445,
            achievements       = {
            },
            loot = {
                { id = 82878, slot = "Chest", name = "Fireworm Robes", sources = { [14]=42160 } },
                { id = 82885, slot = "Chest", name = "Flameseared Carapace", sources = { [14]=42167 } },
                { id = 132552, slot = "Wrist", name = "Chitonous Bindings", sources = { [14]=76387 } },
                { id = 82884, slot = "Wrist", name = "Chitonous Bracers", sources = { [14]=42166 } },
            },
        },
        {
            index              = 4,
            name               = "Lava Guard Gordoth",
            journalEncounterID = 697,
            dungeonEncounterID = 1446,
            achievements       = {
            },
            loot = {
                { id = 82886, slot = "Feet", name = "Gorewalker Treads", sources = { [14]=42168 } },
                { id = 151425, slot = "Hands", name = "Gordoth's Crushers", sources = { [14]=89428 } },
                { id = 82888, slot = "Two-Hand", name = "Heartboiler Staff", sources = { [14]=42169 } },
                { id = 151424, slot = "Waist", name = "Belt of Boundless Fury", sources = { [14]=89427 } },
                { id = 82883, slot = "Weapon", name = "Bloodcursed Felblade", sources = { [14]=42165 } },
            },
        },
    },

    exitNote    = "You can jump in the lava near Slagmaw to kill yourself for a respawn at the entrance.",
    minExitNote = "Death by lava near Slagmaw",

    routing = {

        -- 1. Adarogg (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Adarogg",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 213 },
                    kind    = "path",
                    note    = "After zoning in, head straight south until you reach ^Adarogg^.",
                    minNote = "South to Adarogg",
                    points  = {
                        { 0.659, 0.085 },
                        { 0.685, 0.112 },
                        { 0.664, 0.201 },
                        { 0.661, 0.352 },
                        { 0.652, 0.417 },
                        { 0.673, 0.616 },
                    },
                },
            },
        },

        -- 2. Dark Shaman Koranthal (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Dark Shaman Koranthal",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 213 },
                    kind    = "path",
                    note    = "After killing ^Adarogg^, loop around to the north and continue until you reach ^Dark Shaman Koranthal^.",
                    minNote = "Loop north to Koranthal",
                    points  = {
                        { 0.668, 0.688 },
                        { 0.634, 0.701 },
                        { 0.600, 0.678 },
                        { 0.605, 0.512 },
                        { 0.592, 0.419 },
                        { 0.604, 0.353 },
                        { 0.589, 0.310 },
                        { 0.567, 0.299 },
                    },
                },
            },
        },

        -- 3. Slagmaw (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Slagmaw",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 213 },
                    kind    = "path",
                    note    = "After killing ^Dark Shaman Koranthal^, continue on the path south and find ^Slagmaw^.",
                    minNote = "South to Slagmaw",
                    points  = {
                        { 0.516, 0.360 },
                        { 0.524, 0.468 },
                        { 0.490, 0.497 },
                        { 0.398, 0.458 },
                        { 0.404, 0.533 },
                    },
                },
            },
        },

        -- 4. Lava Guard Gordoth (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Lava Guard Gordoth",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 213 },
                    kind    = "path",
                    note    = "After you take down ^Slagmaw^, continue southwest to reach the final boss, ^Lava Guard Gordoth^.",
                    minNote = "Southwest to Gordoth",
                    points  = {
                        { 0.412, 0.616 },
                        { 0.415, 0.683 },
                        { 0.336, 0.676 },
                        { 0.314, 0.695 },
                        { 0.313, 0.742 },
                        { 0.325, 0.783 },
                    },
                },
            },
        },
    },
}
