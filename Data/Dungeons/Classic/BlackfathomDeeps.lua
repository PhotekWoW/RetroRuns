-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackfathom Deeps
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 48  |  journalInstanceID: 227
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[227] = {
    kind              = "dungeon",
    instanceID        = 48,
    journalInstanceID = 227,
    name              = "Blackfathom Deeps",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 63,
        x     = 0.1635,
        y     = 0.1092,
    },

    trashLoot = {
        { id = 3416, slot = "Chest", name = "Martyr's Chain", sources = { [14]=1245 }, bind = "BoE" },
        { id = 2034, slot = "Chest", name = "Scholarly Robes", sources = { [14]=552 }, bind = "BoE" },
        { id = 1486, slot = "Chest", name = "Tree Bark Jacket", sources = { [14]=309 }, bind = "BoE" },
        { id = 3417, slot = "Two-Hand", name = "Onyx Claymore", sources = { [14]=1246 }, bind = "BoE" },
        { id = 2271, slot = "Two-Hand", name = "Staff of the Blessed Seer", sources = { [14]=716 }, bind = "BoE" },
        { id = 3415, slot = "Two-Hand", name = "Staff of the Friar", sources = { [14]=1244 }, bind = "BoE" },
        { id = 1454, slot = "Weapon", name = "Axe of the Enforcer", sources = { [14]=292 }, bind = "BoE" },
        { id = 3414, slot = "Weapon", name = "Crested Scepter", sources = { [14]=1243 }, bind = "BoE" },
        { id = 3413, slot = "Weapon", name = "Doomspike", sources = { [14]=1242 }, bind = "BoE" },
        { id = 2567, slot = "Weapon", name = "Evocator's Blade", sources = { [14]=871 }, bind = "BoE" },
        { id = 1481, slot = "Weapon", name = "Grimclaw", sources = { [14]=304 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Ghamoo-Ra",
            journalEncounterID = 368,
            dungeonEncounterID = 1667,
            -- Criterion prose reads "Defeat Ghamoo-ra", which the lockout
            -- table spells with a lower-case r and the journal does not.
            scenarioCriteriaID = 24409,
            achievements       = {
            },
            loot = {
                { id = 6907, slot = "Chest", name = "Tortoise Armor", sources = { [14]=2647 } },
                { id = 151432, slot = "Legs", name = "Twilight Turtleskin Leggings", sources = { [14]=89433 } },
                { id = 151433, slot = "Shoulder", name = "Thick Shellplate Shoulders", sources = { [14]=89434 } },
                { id = 6908, slot = "Waist", name = "Ghamoo-Ra's Bind", sources = { [14]=2648 } },
            },
        },
        {
            index              = 2,
            name               = "Domina",
            journalEncounterID = 436,
            dungeonEncounterID = 1668,
            achievements       = {
            },
            loot = {
                { id = 151434, slot = "Feet", name = "Foul Shadowsleet Slippers", sources = { [14]=89435 } },
                { id = 132554, slot = "Hands", name = "Deadly Serpentine Grips", sources = { [14]=76389 } },
                { id = 888, slot = "Hands", name = "Naga Battle Gloves", sources = { [14]=142 } },
                { id = 151435, slot = "Legs", name = "Domina's Deathmaw Greaves", sources = { [14]=89436 } },
                { id = 3078, slot = "Ranged", name = "Naga Heartpiercer", sources = { [14]=1096 } },
                { id = 11121, slot = "Weapon", name = "Darkwater Talwar", sources = { [14]=4135 } },
            },
        },
        {
            index              = 3,
            name               = "Subjugator Kor'ul",
            journalEncounterID = 426,
            dungeonEncounterID = 1669,
            achievements       = {
            },
            loot = {
                { id = 6906, slot = "Hands", name = "Algae Fists", sources = { [14]=2646 } },
                { id = 6905, slot = "Two-Hand", name = "Reef Axe", sources = { [14]=2645 } },
            },
        },
        {
            index              = 4,
            name               = "Thruk",
            journalEncounterID = 1145,
            dungeonEncounterID = 1675,
            achievements       = {
            },
            loot = {
                { id = 120164, slot = "Two-Hand", name = "Thruk's Heavy Duty Fishing Pole", sources = { [14]=67919 } },
                { id = 120165, slot = "Weapon", name = "Thruk's Fillet Knife", sources = { [14]=67920 } },
                { id = 120163, slot = "invtype 29", name = "Thruk's Fishing Rod", sources = { [14]=67918 } },
            },
        },
        {
            index              = 5,
            name               = "Guardian of the Deep",
            journalEncounterID = 447,
            dungeonEncounterID = 1676,
            achievements       = {
            },
            loot = {
                { id = 6901, slot = "Back", name = "Glowing Thresher Cape", sources = { [14]=2641 } },
                { id = 6904, slot = "Weapon", name = "Bite of Serra'kis", sources = { [14]=2644 } },
                { id = 6902, slot = "Wrist", name = "Bands of Serra'kis", sources = { [14]=2642 } },
                { id = 132555, slot = "Wrist", name = "Serra'kis Scale Wraps", sources = { [14]=76390 } },
            },
        },
        {
            index              = 6,
            name               = "Executioner Gore",
            journalEncounterID = 1144,
            dungeonEncounterID = 1670,
            achievements       = {
            },
            loot = {
                { id = 120167, slot = "Back", name = "Bloody Twilight Cloak", sources = { [14]=67922 } },
                { id = 120166, slot = "Chest", name = "Gorestained Garb", sources = { [14]=67921 } },
            },
        },
        {
            index              = 7,
            name               = "Twilight Lord Bathiel",
            journalEncounterID = 437,
            dungeonEncounterID = 1671,
            achievements       = {
            },
            loot = {
                { id = 151438, slot = "Feet", name = "Hungering Deepwater Treads", sources = { [14]=89437 } },
                { id = 151440, slot = "Head", name = "Blackfathom Ascendant's Helm", sources = { [14]=89439 } },
                { id = 6903, slot = "Legs", name = "Gaze Dreamer Pants", sources = { [14]=2643 } },
                { id = 151439, slot = "Shoulder", name = "Bathiel's Scale Spaulders", sources = { [14]=89438 } },
                { id = 1155, slot = "Two-Hand", name = "Rod of the Sleepwalker", sources = { [14]=181 } },
            },
        },
        {
            index              = 8,
            name               = "Aku'mai",
            journalEncounterID = 444,
            dungeonEncounterID = 1672,
            achievements       = {
            },
            loot = {
                { id = 151441, slot = "Feet", name = "Aku'mai Worshipper's Greatboots", sources = { [14]=89440 } },
                { id = 6910, slot = "Legs", name = "Leech Pants", sources = { [14]=2650 } },
                { id = 6909, slot = "Two-Hand", name = "Strike of the Hydra", sources = { [14]=2649 } },
                { id = 132553, slot = "Waist", name = "Algae-Twined Waistcord", sources = { [14]=76388 } },
                { id = 6911, slot = "Waist", name = "Moss Cinch", sources = { [14]=2651 } },
            },
        },
    },

    routing = {

        -- 1. Ghamoo-Ra (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Ghamoo-Ra",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 221 },
                    kind    = "path",
                    note    = "After zoning in, swim across to the south side of the pond and platform your way across to the western shore. Continue south until you reach ^Ghamoo-Ra^.",
                    minNote = "Across the pond, then south",
                    points  = {
                        { 0.487, 0.132 },
                        { 0.513, 0.181 },
                        { 0.537, 0.278 },
                        { 0.553, 0.328 },
                        { 0.567, 0.389 },
                        { 0.564, 0.438 },
                        { 0.537, 0.457 },
                        { 0.526, 0.407 },
                        { 0.512, 0.374 },
                        { 0.476, 0.353 },
                        { 0.443, 0.359 },
                        { 0.427, 0.399 },
                        { 0.425, 0.456 },
                        { 0.355, 0.578 },
                    },
                },
            },
        },

        -- 2. Domina (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Domina",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 221 },
                    kind    = "path",
                    note    = "After killing ^Ghamoo-Ra^, go northwest through an underwater passage to reach ^Domina^.",
                    minNote = "Underwater path to Domina",
                    points  = {
                        { 0.317, 0.571 },
                        { 0.237, 0.454 },
                        { 0.157, 0.436 },
                        { 0.136, 0.418 },
                    },
                },
            },
        },


        -- 3. Subjugator Kor'ul (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Subjugator Kor'ul",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 221 },
                    kind    = "path",
                    note    = "After defeating ^Domina^, backtrack underwater and follow the southern path all the way to ^Subjugator Kor'ul^.",
                    minNote = "Southern path to Kor'ul",
                    points  = {
                        { 0.153, 0.437 },
                        { 0.225, 0.433 },
                        { 0.256, 0.492 },
                        { 0.302, 0.594 },
                        { 0.322, 0.749 },
                        { 0.309, 0.899 },
                        { 0.341, 0.905 },
                        { 0.358, 0.899 },
                        { 0.394, 0.936 },
                        { 0.459, 0.925 },
                        { 0.546, 0.843 },
                        { 0.575, 0.719 },
                        { 0.570, 0.670 },
                        { 0.553, 0.602 },
                    },
                },
            },
        },

        -- 4. Thruk (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Thruk",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 221 },
                    kind    = "path",
                    note    = "After killing ^Subjugator Kor'ul^, take the southeast path into the next area.",
                    minNote = "Southeast to next area",
                    points  = {
                        { 0.552, 0.612 },
                        { 0.566, 0.656 },
                        { 0.575, 0.719 },
                        { 0.619, 0.717 },
                        { 0.617, 0.757 },
                    },
                },
                {
                    when    = { mapID = 222 },
                    kind    = "path",
                    note    = "Continue straight ahead on the southern path and you will run right into ^Thruk^.",
                    minNote = "South to Thruk",
                    points  = {
                        { 0.390, 0.364 },
                        { 0.386, 0.437 },
                        { 0.360, 0.535 },
                        { 0.310, 0.584 },
                        { 0.301, 0.643 },
                        { 0.315, 0.679 },
                        { 0.341, 0.706 },
                    },
                },
            },
        },

        -- 5. Executioner Gore (boss 6)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 6,
            title     = "Executioner Gore",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 222 },
                    kind    = "path",
                    note    = "After defeating ^Thruk^, enter the water walkway east. Follow it around and you will run into ^Executioner Gore^.",
                    minNote = "Water walkway to Executioner Gore",
                    points  = {
                        { 0.338, 0.698 },
                        { 0.337, 0.647 },
                        { 0.410, 0.650 },
                        { 0.409, 0.720 },
                    },
                },
            },
        },

        -- 6. Guardian of the Deep (boss 5)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 5,
            title     = "Guardian of the Deep",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 222 },
                    kind    = "path",
                    note    = "After killing ^Executioner Gore^, continue south along the path. Jump in the water and swim under the ^Moonshrine Sanctum^ to arrive in ^The Forgotten Pool^.",
                    minNote = "Swim under Moonshrine Sanctum",
                    points  = {
                        { 0.404, 0.743 },
                        { 0.429, 0.760 },
                        { 0.449, 0.776 },
                        { 0.482, 0.796 },
                    },
                },
                {
                    when    = { mapID = 223 },
                    kind    = "path",
                    note    = "Continue ahead in ^The Forgotten Pool^ until you reach ^Guardian of the Deep^.",
                    minNote = "Swim ahead into Guardian of the Deep",
                    points  = {
                        { 0.538, 0.577 },
                        { 0.580, 0.522 },
                        { 0.572, 0.351 },
                    },
                },
            },
        },

        -- 7. Twilight Lord Bathiel (boss 7)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Twilight Lord Bathiel",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 222 },
                    kind    = "path",
                    note    = "Exit the water, and walk back through the water channel until you reach ^Twilight Lord Bathiel^.",
                    minNote = "Follow path to Bathiel",
                    points  = {
                        { 0.456, 0.771 },
                        { 0.356, 0.740 },
                        { 0.331, 0.706 },
                        { 0.329, 0.652 },
                        { 0.408, 0.650 },
                        { 0.407, 0.813 },
                        { 0.502, 0.811 },
                    },
                },
            },
        },

        -- 8. Aku'mai (boss 8)
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Aku'mai",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 222 },
                    kind        = "poi",
                    note        = "After killing ^Twilight Lord Bathiel^, click the ^Fire of Aku'mai^ to spawn the final boss.",
                    minNote     = "Click Fire of Aku'mai",
                    mapLabel    = "Click Fire",
                    mapLabelPos = "above",
                    completionCheck = true,
                    triggeredBy = { dialog = { npc = "The Old Gods", match = "arises from the depths" } },
                    points      = {
                        { 0.498, 0.808 },
                    },
                },
                {
                    when    = { mapID = 222 },
                    kind    = "path",
                    note    = "After clicking the fire, follow the path east until you reach ^Aku'mai^.",
                    minNote = "East to Aku'mai",
                    points  = {
                        { 0.549, 0.834 },
                        { 0.563, 0.814 },
                        { 0.615, 0.812 },
                        { 0.639, 0.855 },
                        { 0.712, 0.857 },
                        { 0.831, 0.860 },
                    },
                },
            },
        },

    },
}
