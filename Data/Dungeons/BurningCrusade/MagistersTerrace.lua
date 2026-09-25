-------------------------------------------------------------------------------
-- RetroRuns Data -- Magisters' Terrace
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.4.0  |  instanceID: 585  |  journalInstanceID: 249
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[249] = {
    kind              = "dungeon",
    instanceID        = 585,
    journalInstanceID = 249,
    name              = "Magisters' Terrace",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "2.4.0",
    routedIn          = "3.2.0",
    timewalking       = true,

    entrance = {
        mapID = 122,
        x     = 0.6152,
        y     = 0.3110,
    },

    bosses = {
        {
            index              = 1,
            name               = "Selin Fireheart",
            journalEncounterID = 530,
            dungeonEncounterID = 1897,
            achievements       = {
            },
            loot = {
                { id = 34702, slot = "Back", name = "Cloak of Swift Mending", sources = { [14]=16120, [15]=16120 }, twSource = 76739 },
                { id = 34700, slot = "Hands", name = "Gauntlets of Divine Blessings", sources = { [14]=16118, [15]=16118 }, twSource = 76737 },
                { id = 133457, slot = "Hands", name = "Gloves of Arcane Acuity", sources = { [24]=76757 } },
                { id = 34701, slot = "Legs", name = "Leggings of the Betrayed", sources = { [14]=16119, [15]=16119 }, twSource = 76738 },
                { id = 34601, slot = "Shoulder", name = "Shoulderplates of Everlasting Pain", sources = { [14]=16065, [15]=16065 }, twSource = 76761 },
                { id = 34604, slot = "Weapon", name = "Jaded Crystal Dagger", sources = { [14]=16068, [15]=16068 }, twSource = 76763 },
                { id = 34699, slot = "Weapon", name = "Sun-Forged Cleaver", sources = { [14]=16117, [15]=16117 }, twSource = 76736 },
                { id = 34697, slot = "Wrist", name = "Bindings of Raging Fire", sources = { [14]=16115, [15]=16115 }, twSource = 76734 },
                { id = 34698, slot = "Wrist", name = "Bracers of the Forest Stalker", sources = { [14]=16116, [15]=16116 }, twSource = 76735 },
                { id = 34602, slot = "Wrist", name = "Eversong Cuffs", sources = { [14]=16066, [15]=16066 }, twSource = 76762 },
            },
        },
        {
            index              = 2,
            name               = "Vexallus",
            journalEncounterID = 531,
            dungeonEncounterID = 1898,
            achievements       = {
            },
            loot = {
                { id = 34708, slot = "Back", name = "Cloak of the Coming Night", sources = { [14]=16124, [15]=16124 }, twSource = 76743 },
                { id = 34605, slot = "Chest", name = "Breastplate of Fierce Survival", sources = { [14]=16069, [15]=16069 }, twSource = 76764 },
                { id = 133478, slot = "Chest", name = "Netherforce Chestplate", sources = { [24]=76774 } },
                { id = 34707, slot = "Feet", name = "Boots of Resuscitation", sources = { [14]=16123, [15]=16123 }, twSource = 76742 },
                { id = 34607, slot = "Shoulder", name = "Fel-Tinged Mantle", sources = { [14]=16071, [15]=16071 }, twSource = 76766 },
                { id = 34608, slot = "Two-Hand", name = "Rod of the Blazing Light", sources = { [14]=16072, [15]=16072 }, twSource = 76767 },
                { id = 34606, slot = "Weapon", name = "Edge of Oppression", sources = { [14]=16070, [15]=16070 }, twSource = 76765 },
                { id = 34703, slot = "Weapon", name = "Latro's Dancing Blade", sources = { [14]=16121, [15]=16121 }, twSource = 76740 },
                { id = 34705, slot = "Wrist", name = "Bracers of Divine Infusion", sources = { [14]=16122, [15]=16122 }, twSource = 76741 },
            },
        },
        {
            index              = 3,
            name               = "Priestess Delrissa",
            journalEncounterID = 532,
            dungeonEncounterID = 1895,
            achievements       = {
            },
            loot = {
                { id = 34792, slot = "Back", name = "Cloak of the Betrayed", sources = { [14]=16136, [15]=16136 }, twSource = 76749 },
                { id = 133458, slot = "Feet", name = "Sunrage Treads", sources = { [24]=76758 } },
                { id = 133456, slot = "Feet", name = "Sunstrider Warboots", sources = { [24]=76756 } },
                { id = 34791, slot = "Hands", name = "Gauntlets of the Tranquil Waves", sources = { [14]=16135, [15]=16135 }, twSource = 76748 },
                { id = 34788, slot = "Shoulder", name = "Duskhallow Mantle", sources = { [14]=16132, [15]=16132 }, twSource = 76745 },
                { id = 34790, slot = "Weapon", name = "Battle-Mace of the High Priestess", sources = { [14]=16134, [15]=16134 }, twSource = 76747 },
                { id = 34789, slot = "Wrist", name = "Bracers of Slaughter", sources = { [14]=16133, [15]=16133 }, twSource = 76746 },
            },
        },
        {
            index              = 4,
            name               = "Kael'thas Sunstrider",
            journalEncounterID = 533,
            dungeonEncounterID = 1894,
            achievements       = {
            },
            loot = {
                { id = 34810, slot = "Back", name = "Cloak of Blade Turning", sources = { [14]=16146, [15]=16146 }, twSource = 76759 },
                { id = 34799, slot = "Chest", name = "Hauberk of the War Bringer", sources = { [14]=16142, [15]=16142 }, twSource = 76755 },
                { id = 34615, slot = "Chest", name = "Netherforce Chestplate", sources = { [14]=16079, [15]=16079 } },
                { id = 34796, slot = "Chest", name = "Robes of Summer Flame", sources = { [14]=16140, [15]=16140 }, twSource = 76753 },
                { id = 34610, slot = "Chest", name = "Scarlet Sin'dorei Robes", sources = { [14]=16074, [15]=16074 }, twSource = 76769 },
                { id = 34614, slot = "Chest", name = "Tunic of the Ranger Lord", sources = { [14]=16078, [15]=16078 }, twSource = 76773 },
                { id = 34612, slot = "Feet", name = "Greaves of the Penitent Knight", sources = { [14]=16076, [15]=16076 }, twSource = 76771 },
                { id = 34809, slot = "Feet", name = "Sunrage Treads", sources = { [14]=16145, [15]=16145 } },
                { id = 34807, slot = "Feet", name = "Sunstrider Warboots", sources = { [14]=16143, [15]=16143 } },
                { id = 34808, slot = "Hands", name = "Gloves of Arcane Acuity", sources = { [14]=16144, [15]=16144 } },
                { id = 34795, slot = "Head", name = "Helm of Sanctification", sources = { [14]=16139, [15]=16139 }, twSource = 76752 },
                { id = 34613, slot = "Shoulder", name = "Shoulderpads of the Silvermoon Retainer", sources = { [14]=16077, [15]=16077 }, twSource = 76772 },
                { id = 34794, slot = "Two-Hand", name = "Axe of Shattered Dreams", sources = { [14]=16138, [15]=16138 }, twSource = 76751 },
                { id = 34797, slot = "Two-Hand", name = "Sun-Infused Focus Staff", sources = { [14]=16141, [15]=16141 }, twSource = 76754 },
                { id = 34793, slot = "Waist", name = "Cord of Reconstruction", sources = { [14]=16137, [15]=16137 }, twSource = 76750 },
                { id = 34616, slot = "Weapon", name = "Breeching Comet", sources = { [14]=16080, [15]=16080 }, twSource = 76775 },
                { id = 34611, slot = "Weapon", name = "Cudgel of Consecration", sources = { [14]=16075, [15]=16075 }, twSource = 76770 },
                { id = 34609, slot = "Weapon", name = "Quickening Blade of the Prince", sources = { [14]=16073, [15]=16073 }, twSource = 76768 },
            },
            specialLoot = {
                { id = 35513, kind = "mount", name = "Swift White Hawkstrider", heroicOnly = true },
                { id = 35504, kind = "pet", name = "Phoenix Hatchling", heroicOnly = true },
                { id = 35275, kind = "toy", name = "Orb of the Sin'dorei", heroicOnly = true },
            },
        },
    },

    exitNote    = "Use the orb on the platform behind ^Kael'thas^ to teleport to the exit",
    minExitNote = "Exit via teleport orb on platform",

    routing = {
        -- 1. Selin Fireheart (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Selin Fireheart",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 349 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path north until you reach ^Selin Fireheart^.",
                    minNote = "North to Selin Fireheart",
                    points  = {
                        { 0.426, 0.902 },
                        { 0.425, 0.855 },
                        { 0.394, 0.854 },
                        { 0.394, 0.825 },
                        { 0.425, 0.824 },
                        { 0.425, 0.599 },
                        { 0.400, 0.582 },
                        { 0.400, 0.541 },
                        { 0.426, 0.514 },
                        { 0.425, 0.356 },
                        { 0.396, 0.356 },
                        { 0.396, 0.326 },
                        { 0.425, 0.326 },
                        { 0.425, 0.263 },
                    },
                },
            },
        },
        -- 2. Vexallus (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Vexallus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 349 },
                    kind    = "path",
                    note    = "After defeating ^Selin Fireheart^, exit the room to the east and follow the linear path to ^Vexallus^.",
                    minNote = "East to Vexallus",
                    points  = {
                        { 0.467, 0.200 },
                        { 0.567, 0.200 },
                        { 0.568, 0.266 },
                        { 0.810, 0.265 },
                    },
                },
            },
        },
        -- 3. Priestess Delrissa (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Priestess Delrissa",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 349 },
                    kind    = "path",
                    note    = "After killing ^Vexallus^, continue past him to the east and follow the linear path.",
                    minNote = "Exit east and follow the path",
                    points  = {
                        { 0.859, 0.267 },
                        { 0.877, 0.267 },
                        { 0.877, 0.236 },
                        { 0.889, 0.236 },
                        { 0.890, 0.268 },
                        { 0.922, 0.268 },
                        { 0.938, 0.326 },
                        { 0.933, 0.373 },
                        { 0.909, 0.402 },
                        { 0.887, 0.402 },
                        { 0.886, 0.350 },
                        { 0.832, 0.350 },
                        { 0.832, 0.485 },
                    },
                },
                {
                    when    = { mapID = 348 },
                    kind    = "path",
                    note    = "Continue following the linear path until you reach ^Priestess Delrissa^.",
                    minNote = "Follow path to Delrissa",
                    points  = {
                        { 0.831, 0.564 },
                        { 0.715, 0.565 },
                        { 0.694, 0.504 },
                        { 0.638, 0.503 },
                        { 0.615, 0.563 },
                        { 0.421, 0.562 },
                    },
                },
            },
        },
        -- 4. Kael'thas Sunstrider (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Kael'thas Sunstrider",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 348 },
                    kind    = "path",
                    note    = "After killing ^Priestess Delrissa^, continue west until you reach ^Kael'thas Sunstrider^.",
                    minNote = "West to Kael'thas",
                    points  = {
                        { 0.349, 0.562 },
                        { 0.279, 0.563 },
                        { 0.279, 0.496 },
                        { 0.109, 0.499 },
                    },
                },
            },
        },
    },
}
