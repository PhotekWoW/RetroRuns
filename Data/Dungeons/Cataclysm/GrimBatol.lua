-------------------------------------------------------------------------------
-- RetroRuns Data -- Grim Batol
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 670  |  journalInstanceID: 71
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[71] = {
    kind              = "dungeon",
    instanceID        = 670,
    journalInstanceID = 71,
    name              = "Grim Batol",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.0.3",
    routedIn          = "3.3.4",

    entrance = {
        mapID = 56,
        x     = 0.7387,
        y     = 0.6873,
    },

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    trashLoot = {
        { id = 56219, slot = "Back", name = "Shroud of Dark Memories", sources = { [14]=27609, [15]=27609 }, bind = "BoE" },
        { id = 56218, slot = "Legs", name = "Curse-Tainted Leggings", sources = { [14]=27608, [15]=27608 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "General Umbriss",
            journalEncounterID = 2617,
            dungeonEncounterID = 1051,
            achievements       = {
            },
            loot = {
                { id = 56442, slot = "Chest", name = "Cursed Skardyn Vest", sources = { [14]=27737, [15]=27737 } },
                { id = 56443, slot = "Head", name = "Wildhammer Riding Helm", sources = { [14]=27738, [15]=27738 } },
                { id = 157596, slot = "Legs", name = "Glimmerthread Pantaloons", sources = { [14]=93785, [15]=93785 } },
                { id = 157612, slot = "Off-hand", name = "Dragonkin Ward", sources = { [14]=93798, [15]=93798 } },
                { id = 56441, slot = "Weapon", name = "Modgud's Blade", sources = { [14]=27736 } },
            },
        },
        {
            index              = 2,
            name               = "Forgemaster Throngus",
            journalEncounterID = 2627,
            dungeonEncounterID = 1050,
            achievements       = {
            },
            loot = {
                { id = 157597, slot = "Back", name = "Troggstitched Drape", sources = { [14]=93786, [15]=93786 } },
                { id = 56448, slot = "Feet", name = "Dark Iron Chain Boots", sources = { [14]=27741, [15]=27741 } },
                { id = 56446, slot = "Ranged", name = "Wand of Untainted Power", sources = { [14]=27739, [15]=27739 } },
                { id = 56447, slot = "Waist", name = "Belt of the Forgemaster", sources = { [14]=27740, [15]=27740 } },
                { id = 157613, slot = "Weapon", name = "Geomancy Slicer", sources = { [14]=93799, [15]=93799 } },
            },
        },
        {
            index              = 3,
            name               = "Drahga Shadowburner",
            journalEncounterID = 2618,
            dungeonEncounterID = 1048,
            achievements       = {
            },
            loot = {
                { id = 56450, slot = "Back", name = "Azureborne Cloak", sources = { [14]=27742, [15]=27742 } },
                { id = 157614, slot = "Feet", name = "Flame Invoker's Treads", sources = { [14]=93800, [15]=93800 } },
                { id = 56451, slot = "Feet", name = "Red Scale Boots", sources = { [14]=27743, [15]=27743 } },
                { id = 157598, slot = "Shoulder", name = "Courier's Dragonriding Spaulders", sources = { [14]=93787, [15]=93787 } },
                { id = 56452, slot = "Shoulder", name = "Earthshape Pauldrons", sources = { [14]=27744, [15]=27744 } },
                { id = 56454, slot = "Weapon", name = "Windwalker Blade", sources = { [14]=27746, [15]=27746 } },
                { id = 56453, slot = "Wrist", name = "Crimsonborne Bracers", sources = { [14]=27745, [15]=27745 } },
            },
        },
        {
            index              = 4,
            name               = "Erudax, the Duke of Below",
            journalEncounterID = 2619,
            dungeonEncounterID = 1049,
            aliases            = { "Erudax" },
            achievements       = {
                { id = 5298, name = "Don't Need to Break Eggs to Make an Omelet", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56455, slot = "Chest", name = "Vest of Misshapen Hides", sources = { [14]=27747, [15]=27747 } },
                { id = 56460, slot = "Head", name = "Crown of Enfeebled Bodies", sources = { [14]=27750, [15]=27750 } },
                { id = 157615, slot = "Legs", name = "Flamescale Chain Leggings", sources = { [14]=93801, [15]=93801 } },
                { id = 56461, slot = "Two-Hand", name = "Staff of Siphoned Essences", sources = { [14]=27751, [15]=27751 } },
                { id = 56456, slot = "Two-Hand", name = "Wild Hammer", sources = { [14]=27748, [15]=27748 } },
                { id = 56459, slot = "Weapon", name = "Mace of Transformed Bone", sources = { [14]=27749, [15]=27749 } },
                { id = 56464, slot = "Wrist", name = "Bracers of Umbral Mending", sources = { [14]=27752, [15]=27752 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. General Umbriss (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "General Umbriss",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 293 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path until you reach ^General Umbriss^.",
                    minNote = "Follow path to Umbriss",
                    points  = {
                        { 0.149, 0.547 },
                        { 0.177, 0.536 },
                        { 0.182, 0.499 },
                        { 0.174, 0.459 },
                        { 0.200, 0.399 },
                        { 0.264, 0.399 },
                        { 0.266, 0.335 },
                        { 0.282, 0.263 },
                        { 0.330, 0.284 },
                        { 0.325, 0.318 },
                        { 0.318, 0.361 },
                        { 0.319, 0.420 },
                        { 0.326, 0.481 },
                        { 0.346, 0.546 },
                        { 0.298, 0.588 },
                        { 0.315, 0.621 },
                        { 0.354, 0.684 },
                        { 0.383, 0.684 },
                    },
                },
            },
        },

        -- 2. Forgemaster Throngus (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Forgemaster Throngus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 293 },
                    kind    = "path",
                    note    = "After defeating ^General Umbriss^, continue on the path northeast to reach ^Forgemaster Throngus^.",
                    minNote = "Continue northeast to Throngus",
                    points  = {
                        { 0.429, 0.615 },
                        { 0.444, 0.585 },
                        { 0.421, 0.540 },
                        { 0.456, 0.492 },
                        { 0.466, 0.460 },
                        { 0.450, 0.414 },
                        { 0.454, 0.361 },
                        { 0.483, 0.316 },
                    },
                },
            },
        },

        -- 3. Drahga Shadowburner (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Drahga Shadowburner",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 293 },
                    kind    = "path",
                    note    = "After killing ^Forgemaster Throngus^, continue southeast then follow the linear path to ^Drahga Shadowburner^.",
                    minNote = "Follow path to Drahga",
                    points  = {
                        { 0.553, 0.327 },
                        { 0.575, 0.364 },
                        { 0.577, 0.425 },
                        { 0.575, 0.490 },
                        { 0.607, 0.537 },
                        { 0.586, 0.575 },
                        { 0.623, 0.669 },
                        { 0.676, 0.685 },
                        { 0.725, 0.578 },
                        { 0.684, 0.545 },
                        { 0.703, 0.491 },
                        { 0.710, 0.427 },
                        { 0.709, 0.353 },
                        { 0.698, 0.292 },
                        { 0.693, 0.209 },
                    },
                },
            },
        },

        -- 4. Erudax, the Duke of Below (boss 4).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Erudax, the Duke of Below",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 293 },
                    kind    = "path",
                    note    = "After defeating ^Drahga Shadowburner^, follow the path to the south until you reach the final boss, ^Erudax, the Duke of Below^.",
                    minNote = "South to Erudax",
                    points  = {
                        { 0.716, 0.193 },
                        { 0.749, 0.268 },
                        { 0.765, 0.399 },
                        { 0.857, 0.400 },
                        { 0.855, 0.714 },
                    },
                },
            },
        },
    },
}
