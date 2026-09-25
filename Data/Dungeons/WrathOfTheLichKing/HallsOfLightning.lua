-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Lightning
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 602  |  journalInstanceID: 275
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[275] = {
    kind              = "dungeon",
    instanceID        = 602,
    journalInstanceID = 275,
    name              = "Halls of Lightning",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "3.0.2",
    routedIn          = "3.3.0",
    timewalking       = true,

    entrance = {
        mapID = 120,
        x     = 0.4544,
        y     = 0.2128,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 36999, slot = "Feet", name = "Boots of the Terrestrial Guardian", sources = { [14]=17527 }, bind = "BoE" },
        { id = 37858, slot = "Hands", name = "Awakened Handguards", sources = { [15]=18069 }, bind = "BoE" },
        { id = 37857, slot = "Head", name = "Helm of the Lightning Halls", sources = { [15]=18068 }, bind = "BoE" },
        { id = 36997, slot = "Waist", name = "Sash of the Hardened Watcher", sources = { [14]=17525 }, bind = "BoE" },
        { id = 37856, slot = "Weapon", name = "Librarian's Paper Cutter", sources = { [15]=18067 }, bind = "BoE" },
        { id = 37000, slot = "Wrist", name = "Storming Vortex Bracers", sources = { [14]=17528 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "General Bjarngrim",
            journalEncounterID = 597,
            dungeonEncounterID = 1987,
            achievements       = {
                { id = 1834, name = "Lightning Struck", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37825, slot = "Hands", name = "Traditionally Dyed Handguards", sources = { [14]=18049, [15]=18049 }, twSource = 72623 },
                { id = 37818, slot = "Legs", name = "Patroller's War-Kilt", sources = { [14]=18047, [15]=18047 }, twSource = 72622 },
                { id = 157580, slot = "Off-hand", name = "Spark of the Forge", sources = { [14]=93771, [15]=93771 } },
                { id = 37814, slot = "Shoulder", name = "Iron Dwarf Smith Pauldrons", sources = { [14]=18045, [15]=18045 }, twSource = 72621 },
                { id = 36982, slot = "Shoulder", name = "Mantle of Electrical Charges", sources = { [14]=17513, [15]=17513 } },
                { id = 36980, slot = "Two-Hand", name = "Hewn Sparring Quarterstaff", sources = { [14]=17511, [15]=17511 } },
                { id = 37826, slot = "Waist", name = "The General's Steel Girdle", sources = { [14]=18050, [15]=18050 }, twSource = 72624 },
            },
        },
        {
            index              = 2,
            name               = "Volkhan",
            journalEncounterID = 598,
            dungeonEncounterID = 1985,
            achievements       = {
                { id = 2042, name = "Shatter Resistant", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 36983, slot = "Back", name = "Cape of Seething Steam", sources = { [14]=17514, [15]=17514 } },
                { id = 37840, slot = "Back", name = "Shroud of Reverberation", sources = { [14]=18052, [15]=18052 }, twSource = 72625 },
                { id = 37841, slot = "Feet", name = "Slag Footguards", sources = { [14]=18053, [15]=18053 }, twSource = 72626 },
                { id = 37843, slot = "Hands", name = "Giant-Hair Woven Gloves", sources = { [14]=18055, [15]=18055 }, twSource = 72628 },
                { id = 127525, slot = "Head", name = "Helm of the Lightning Halls", sources = { [24]=72641 } },
                { id = 36985, slot = "Head", name = "Volkhan's Hood", sources = { [14]=17516, [15]=17516 } },
                { id = 36986, slot = "Legs", name = "Kilt of Molten Golems", sources = { [14]=17517, [15]=17517 } },
                { id = 157579, slot = "Legs", name = "Slag-Stained Legplates", sources = { [14]=93770, [15]=93770 } },
                { id = 37842, slot = "Waist", name = "Belt of Vivacity", sources = { [14]=18054, [15]=18054 }, twSource = 72627 },
                { id = 127507, slot = "Waist", name = "The General's Steel Girdle", sources = { [24]=72624 } },
                { id = 36984, slot = "Weapon", name = "Eternally Folded Blade", sources = { [14]=17515, [15]=17515 } },
            },
        },
        {
            index              = 3,
            name               = "Ionar",
            journalEncounterID = 599,
            dungeonEncounterID = 1984,
            achievements       = {
            },
            loot = {
                { id = 127519, slot = "Chest", name = "Ornate Woolen Stola", sources = { [24]=72635 } },
                { id = 37847, slot = "Feet", name = "Skywall Striders", sources = { [14]=18058, [15]=18058 }, twSource = 72631 },
                { id = 37846, slot = "Hands", name = "Charged-Bolt Grips", sources = { [14]=18057, [15]=18057 }, twSource = 72630 },
                { id = 39536, slot = "Hands", name = "Thundercloud Grasps", sources = { [14]=18942, [15]=18942 } },
                { id = 39534, slot = "Shoulder", name = "Pauldrons of the Lightning Revenant", sources = { [14]=18940, [15]=18940 } },
                { id = 37845, slot = "Waist", name = "Cord of Swirling Winds", sources = { [14]=18056, [15]=18056 }, twSource = 72629 },
                { id = 39535, slot = "Waist", name = "Ionar's Girdle", sources = { [14]=18941, [15]=18941 } },
                { id = 39657, slot = "Wrist", name = "Tornado Cuffs", sources = { [14]=19018, [15]=19018 } },
            },
        },
        {
            index              = 4,
            name               = "Loken",
            journalEncounterID = 600,
            dungeonEncounterID = 1986,
            achievements       = {
                { id = 1867, name = "Timely Death", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37851, slot = "Chest", name = "Ornate Woolen Stola", sources = { [14]=18062, [15]=18062 } },
                { id = 36991, slot = "Chest", name = "Raiments of the Titans", sources = { [14]=17520, [15]=17520 } },
                { id = 36995, slot = "Hands", name = "Fists of Loken", sources = { [14]=17523, [15]=17523 } },
                { id = 36996, slot = "Head", name = "Hood of the Furtive Assassin", sources = { [14]=17524, [15]=17524 } },
                { id = 37849, slot = "Head", name = "Planetary Helm", sources = { [14]=18060, [15]=18060 }, twSource = 72633 },
                { id = 36992, slot = "Legs", name = "Leather-Braced Chain Leggings", sources = { [14]=17521, [15]=17521 } },
                { id = 37854, slot = "Legs", name = "Woven Bracae Leggings", sources = { [14]=18065, [15]=18065 }, twSource = 72638 },
                { id = 36989, slot = "Ranged", name = "Ancient Measuring Rod", sources = { [14]=17518, [15]=17518 } },
                { id = 36994, slot = "Ranged", name = "Projectile Activator", sources = { [14]=17522, [15]=17522 } },
                { id = 37852, slot = "Two-Hand", name = "Colossal Skull-Clad Cleaver", sources = { [14]=18063, [15]=18063 }, twSource = 72636 },
                { id = 37848, slot = "Two-Hand", name = "Lightning Giant Staff", sources = { [14]=18059, [15]=18059 }, twSource = 72632 },
                { id = 37850, slot = "Waist", name = "Flowing Sash of Order", sources = { [14]=18061, [15]=18061 }, twSource = 72634 },
                { id = 37855, slot = "Waist", name = "Mail Girdle of the Audient Earth", sources = { [14]=18066, [15]=18066 }, twSource = 72639 },
                { id = 127524, slot = "Weapon", name = "Librarian's Paper Cutter", sources = { [24]=72640 } },
                { id = 37853, slot = "Wrist", name = "Advanced Tooled-Leather Bands", sources = { [14]=18064, [15]=18064 }, twSource = 72637 },
            },
            specialLoot = {
                { id = 122237, kind = "musicroll", name = "Music Roll: Mountains of Thunder", questID = 38098 },
            },
        },
    },

    exitNote    = "You can jump off the ledge behind Loken for a shortcut to the entrance",
    minExitNote = "Ledge behind Loken leads to entrance",

    routing = {
        -- 1. General Bjarngrim (boss 1). Right at the fork, then along the
        -- walkway he patrols.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "General Bjarngrim",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 138 },
                    kind    = "path",
                    note    = "After zoning in, take a right at the fork and find ^General Bjarngrim^ patrolling the walkway.",
                    minNote = "Take a right to Bjarngrim",
                    points  = {
                        { 0.120, 0.532 },
                        { 0.325, 0.531 },
                        { 0.325, 0.722 },
                        { 0.547, 0.722 },
                        { 0.546, 0.635 },
                    },
                },
            },
        },

        -- 2. Volkhan (boss 2). East up the stairs to the second floor, then
        -- west.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Volkhan",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 138 },
                    kind    = "path",
                    note    = "After taking down ^General Bjarngrim^, go east through the earth elementals and up the stairs into the next area.",
                    minNote = "East up the stairs",
                    points  = {
                        { 0.717, 0.535 },
                        { 0.918, 0.536 },
                        { 0.918, 0.592 },
                    },
                },
                {
                    when    = { mapID = 139 },
                    kind    = "path",
                    note    = "Once you reach the top of the stairs, move ahead to the west and you will run into ^Volkhan^.",
                    minNote = "Go west to reach Volkhan",
                    points  = {
                        { 0.551, 0.258 },
                        { 0.440, 0.258 },
                        { 0.401, 0.217 },
                    },
                },
            },
        },

        -- 3. Ionar (boss 3). South out of Volkhan's room.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Ionar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 139 },
                    kind    = "path",
                    note    = "After killing ^Volkhan^, exit this room to the south and follow the path to ^Ionar^.",
                    minNote = "Exit south and follow path to Ionar",
                    points  = {
                        { 0.426, 0.215 },
                        { 0.472, 0.311 },
                        { 0.472, 0.539 },
                        { 0.612, 0.538 },
                        { 0.612, 0.740 },
                    },
                },
            },
        },

        -- 4. Loken (boss 4). West out of Ionar's room to the end.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Loken",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 139 },
                    kind    = "path",
                    note    = "After killing ^Ionar^, exit to the west and follow the linear path all the way to ^Loken^.",
                    minNote = "Follow path to Loken",
                    points  = {
                        { 0.561, 0.757 },
                        { 0.517, 0.759 },
                        { 0.489, 0.722 },
                        { 0.345, 0.722 },
                        { 0.318, 0.760 },
                        { 0.264, 0.762 },
                        { 0.253, 0.804 },
                        { 0.227, 0.835 },
                        { 0.194, 0.834 },
                        { 0.194, 0.792 },
                        { 0.225, 0.778 },
                        { 0.236, 0.746 },
                        { 0.236, 0.713 },
                        { 0.218, 0.694 },
                        { 0.194, 0.686 },
                        { 0.192, 0.565 },
                    },
                },
            },
        },
    },
}
