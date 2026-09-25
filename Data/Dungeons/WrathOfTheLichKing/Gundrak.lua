-------------------------------------------------------------------------------
-- RetroRuns Data -- Gundrak
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 604  |  journalInstanceID: 274
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[274] = {
    kind              = "dungeon",
    instanceID        = 604,
    journalInstanceID = 274,
    name              = "Gundrak",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "3.0.2",
    timewalking       = true,
    routedIn          = "3.3.0",

    entrance = {
        mapID = 121,
        x     = 0.7602,
        y     = 0.2079,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37647, slot = "Back", name = "Cloak of Bloodied Waters", sources = { [14]=17923, [15]=17923 }, bind = "BoE" },
        { id = 37648, slot = "Waist", name = "Belt of Tasseled Lanterns", sources = { [14]=17924, [15]=17924 }, bind = "BoE" },
        { id = 35594, slot = "Waist", name = "Snowmelt Silken Cinch", sources = { [14]=16530 }, bind = "BoE" },
        { id = 35593, slot = "Wrist", name = "Steel Bear Trap Bracers", sources = { [14]=16529 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Slad'ran",
            journalEncounterID = 592,
            dungeonEncounterID = 1978,
            achievements       = {
                { id = 2058, name = "Snakes. Why'd It Have To Be Snakes?", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 35584, slot = "Chest", name = "Embroidered Gown of Zul'Drak", sources = { [14]=16522, [15]=16522 }, twSource = 72644 },
                { id = 37629, slot = "Feet", name = "Slithering Slippers", sources = { [14]=17908, [15]=17908 }, twSource = 72656 },
                { id = 127548, slot = "Head", name = "Helm of Cheated Fate", sources = { [24]=72663 } },
                { id = 35585, slot = "Legs", name = "Cannibal's Legguards", sources = { [14]=16523, [15]=16523 }, twSource = 72645 },
                { id = 37626, slot = "Ranged", name = "Wand of Sseratus", sources = { [14]=17905, [15]=17905 }, twSource = 72653 },
                { id = 37627, slot = "Shoulder", name = "Snake Den Spaulders", sources = { [14]=17906, [15]=17906 }, twSource = 72654 },
                { id = 35583, slot = "Two-Hand", name = "Witch Doctor's Wildstaff", sources = { [14]=16521, [15]=16521 }, twSource = 72643 },
                { id = 157578, slot = "Waist", name = "Belt of Vile Concoctions", sources = { [14]=93769, [15]=93769 } },
                { id = 37628, slot = "Waist", name = "Slad'ran's Coiled Cord", sources = { [14]=17907, [15]=17907 }, twSource = 72655 },
            },
        },
        {
            index              = 2,
            name               = "Drakkari Colossus",
            journalEncounterID = 593,
            dungeonEncounterID = 1983,
            achievements       = {
            },
            loot = {
                { id = 35592, slot = "Chest", name = "Hauberk of Totemic Mastery", sources = { [14]=16528, [15]=16528 }, twSource = 72650 },
                { id = 37636, slot = "Head", name = "Helm of Cheated Fate", sources = { [14]=17915, [15]=17915 } },
                { id = 35590, slot = "Ranged", name = "Drakkari Hunting Bow", sources = { [14]=16526, [15]=16526 }, twSource = 72648 },
                { id = 37635, slot = "Shoulder", name = "Pauldrons of the Colossus", sources = { [14]=17914, [15]=17914 }, twSource = 72662 },
                { id = 35591, slot = "Shoulder", name = "Shoulderguards of the Ice Troll", sources = { [14]=16527, [15]=16527 }, twSource = 72649 },
                { id = 37637, slot = "Waist", name = "Living Mojo Belt", sources = { [14]=17916, [15]=17916 }, twSource = 72664 },
                { id = 127537, slot = "Waist", name = "Snowmelt Silken Cinch", sources = { [24]=72652 } },
                { id = 37634, slot = "Wrist", name = "Bracers of the Divine Elemental", sources = { [14]=17913, [15]=17913 }, twSource = 72661 },
            },
        },
        {
            index              = 3,
            name               = "Moorabi",
            journalEncounterID = 594,
            dungeonEncounterID = 1980,
            achievements       = {
                { id = 2040, name = "Less-rabi", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 157584, slot = "Back", name = "Drape of Moorabi", sources = { [14]=93776, [15]=93776 } },
                { id = 37630, slot = "Back", name = "Shroud of Moorabi", sources = { [14]=17909, [15]=17909 }, twSource = 72657 },
                { id = 35588, slot = "Chest", name = "Forlorn Breastplate of War", sources = { [14]=16525, [15]=16525 }, twSource = 72647 },
                { id = 37632, slot = "Feet", name = "Mojo Frenzy Greaves", sources = { [14]=17911, [15]=17911 }, twSource = 72659 },
                { id = 37633, slot = "Head", name = "Ground Tremor Helm", sources = { [14]=17912, [15]=17912 }, twSource = 72660 },
                { id = 127560, slot = "Waist", name = "Belt of Tasseled Lanterns", sources = { [24]=72672 } },
                { id = 37631, slot = "Weapon", name = "Fist of the Deity", sources = { [14]=17910, [15]=17910 }, twSource = 72658 },
                { id = 35587, slot = "Weapon", name = "Frozen Scepter of Necromancy", sources = { [14]=16524, [15]=16524 }, twSource = 72646 },
            },
        },
        {
            index              = 4,
            name               = "Eck the Ferocious",
            journalEncounterID = 595,
            dungeonEncounterID = 1988,
            availableDifficulties = { 15, 24 },
            achievements       = {
            },
            loot = {
                { id = 43310, slot = "Chest", name = "Engraved Chestplate of Eck", sources = { [15]=20956 }, twSource = 72674 },
                { id = 43312, slot = "Feet", name = "Gorloc Muddy Footwraps", sources = { [15]=20958 }, twSource = 72676 },
                { id = 43311, slot = "Head", name = "Helmet of the Shrine", sources = { [15]=20957 }, twSource = 72675 },
                { id = 43313, slot = "Legs", name = "Leggings of the Ruins Dweller", sources = { [15]=20959 }, twSource = 72677 },
            },
        },
        {
            index              = 5,
            name               = "Gal'darah",
            journalEncounterID = 596,
            dungeonEncounterID = 1981,
            achievements       = {
                { id = 1864, name = "What the Eck?", meta = true, soloable = "kinda" },
                { id = 2152, name = "Share The Love", soloable = "kinda" },
            },
            loot = {
                { id = 127559, slot = "Back", name = "Cloak of Bloodied Waters", sources = { [24]=72671 } },
                { id = 43305, slot = "Back", name = "Shroud of Akali", sources = { [14]=20955, [15]=20955 }, twSource = 72673 },
                { id = 37641, slot = "Chest", name = "Arcane Flame Altar-Garb", sources = { [14]=17919, [15]=17919 }, twSource = 72667 },
                { id = 37640, slot = "Feet", name = "Boots of Transformation", sources = { [14]=17918, [15]=17918 }, twSource = 72666 },
                { id = 37639, slot = "Hands", name = "Grips of the Beast God", sources = { [14]=17917, [15]=17917 }, twSource = 72665 },
                { id = 37645, slot = "Hands", name = "Horn-Tipped Gauntlets", sources = { [14]=17922, [15]=17922 }, twSource = 72670 },
                { id = 37644, slot = "Legs", name = "Gored Hide Legguards", sources = { [14]=17921, [15]=17921 }, twSource = 72669 },
                { id = 37643, slot = "Waist", name = "Sash of Blood Removal", sources = { [14]=17920, [15]=17920 }, twSource = 72668 },
                { id = 127536, slot = "Wrist", name = "Steel Bear Trap Bracers", sources = { [24]=72651 } },
            },
        },
    },

    exitNote    = "There is an exit portal to the west of the boss",
    minExitNote = "Exit portal west of boss",

    routing = {
        -- 1. Slad'ran (boss 1). Down into the water from the entrance, then south.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Slad'ran",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 154 },
                    kind    = "path",
                    note    = "After zoning in, jump down into the water below and continue south to reach ^Slad'ran^.",
                    minNote = "Jump in, go south for Slad'ran",
                    points  = {
                        { 0.562, 0.282 },
                        { 0.588, 0.303 },
                        { 0.587, 0.490 },
                        { 0.562, 0.489 },
                    },
                },
            },
        },

        -- 2. Drakkari Colossus (boss 2). Slad'ran's altar, then south.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Drakkari Colossus",
            requires  = { },
            segments  = {
                {
                    when          = { mapID = 154 },
                    kind          = "poi",
                    note          = "After killing ^Slad'ran^, click the ^Altar of Slad'ran^ behind him then continue south to ^Drakkari Colossus^.",
                    minNote       = "Click Altar then south to Colossus",
                    mapLabel      = "Click Altar",
                    mapLabelPos   = "above",
                    mapLabelPulse = true,
                    points        = {
                        { 0.531, 0.485 },
                    },
                },
                {
                    when    = { mapID = 154 },
                    kind    = "path",
                    note    = "After killing ^Slad'ran^, click the ^Altar of Slad'ran^ behind him then continue south to ^Drakkari Colossus^.",
                    minNote = "Click Altar then south to Colossus",
                    points  = {
                        { 0.568, 0.489 },
                        { 0.589, 0.547 },
                        { 0.589, 0.671 },
                        { 0.532, 0.740 },
                        { 0.464, 0.740 },
                        { 0.464, 0.695 },
                    },
                },
            },
        },

        -- 3. Moorabi (boss 3). The Colossus altar, then west.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Moorabi",
            requires  = { },
            segments  = {
                {
                    when          = { mapID = 154 },
                    kind          = "poi",
                    note          = "After defeating ^Drakkari Colossus^, click the ^Altar of the Drakkari Colossus^ nearby then follow the path west to reach ^Moorabi^. Swim across for a shortcut.",
                    minNote       = "Click Altar then west to Moorabi",
                    mapLabel      = "Click Altar",
                    mapLabelPos   = "above",
                    mapLabelPulse = true,
                    points        = {
                        { 0.464, 0.612 },
                    },
                },
                {
                    when    = { mapID = 154 },
                    kind    = "path",
                    note    = "After defeating ^Drakkari Colossus^, click the ^Altar of the Drakkari Colossus^ nearby then follow the path west to reach ^Moorabi^. Swim across for a shortcut.",
                    minNote = "Click Altar then west to Moorabi",
                    points  = {
                        { 0.462, 0.710 },
                        { 0.436, 0.735 },
                        { 0.408, 0.736 },
                        { 0.362, 0.598 },
                        { 0.342, 0.599 },
                        { 0.344, 0.548 },
                        { 0.368, 0.513 },
                    },
                },
            },
        },

        -- 4. Eck the Ferocious (boss 4, Heroic only). Moorabi's altar, then
        -- the west tunnel down to his den.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Eck the Ferocious",
            requires  = { },
            -- Left out once his appearances are all collected; step 6 then
            -- takes the swim to Gal'darah.
            skipWhenCollected = true,
            segments  = {
                {
                    when          = { mapID = 154 },
                    kind          = "poi",
                    note          = "After killing ^Moorabi^, click the ^Altar of Moorabi^ behind him then enter the tunnel to the west and follow it down to ^Eck the Ferocious^.",
                    minNote       = "Click Altar then west tunnel to Eck",
                    mapLabel      = "Click Altar",
                    mapLabelPos   = "above",
                    mapLabelPulse = true,
                    points        = {
                        { 0.404, 0.491 },
                    },
                },
                {
                    when    = { mapID = 154 },
                    kind    = "path",
                    note    = "After killing ^Moorabi^, click the ^Altar of Moorabi^ behind him then enter the tunnel to the west and follow it down to ^Eck the Ferocious^.",
                    minNote = "Click Altar then west tunnel to Eck",
                    points  = {
                        { 0.368, 0.492 },
                        { 0.313, 0.492 },
                        { 0.286, 0.476 },
                        { 0.274, 0.479 },
                        { 0.251, 0.513 },
                        { 0.252, 0.672 },
                    },
                },
            },
        },

        -- 5. Gal'darah (boss 5), Heroic: from Eck's den. Opens only once he
        -- is dead; Normal runs take step 6.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Gal'darah",
            requires  = { 4 },
            segments  = {
                {
                    when    = { mapID = 154 },
                    kind    = "path",
                    note    = "After killing ^Eck the Ferocious^, swim underwater to the east, passing through a grate and jumping over a small waterfall on your way to ^Gal'darah^.",
                    minNote = "Swim east, follow path to Gal'darah",
                    points  = {
                        { 0.275, 0.729 },
                        { 0.321, 0.729 },
                        { 0.464, 0.551 },
                        { 0.466, 0.325 },
                    },
                },
            },
        },

        -- 6. Gal'darah (boss 5). Moorabi's altar, swim to the middle path,
        -- then north. The Normal route; Heroic takes step 5.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 5,
            title     = "Gal'darah",
            requires  = { },
            segments  = {
                {
                    when          = { mapID = 154 },
                    kind          = "poi",
                    note          = "After killing ^Moorabi^, click the ^Altar of Moorabi^ behind him then jump in the water and swim across to the middle path. Go north to reach ^Gal'darah^.",
                    minNote       = "Click Altar then swim to path for Gal'darah",
                    mapLabel      = "Click Altar",
                    mapLabelPos   = "above",
                    mapLabelPulse = true,
                    points        = {
                        { 0.404, 0.491 },
                    },
                },
                {
                    when    = { mapID = 154 },
                    kind    = "path",
                    note    = "After killing ^Moorabi^, click the ^Altar of Moorabi^ behind him then jump in the water and swim across to the middle path. Go north to reach ^Gal'darah^.",
                    minNote = "Click Altar then swim to path for Gal'darah",
                    points  = {
                        { 0.418, 0.505 },
                        { 0.456, 0.551 },
                        { 0.466, 0.551 },
                        { 0.465, 0.310 },
                    },
                },
            },
        },
    },
}
