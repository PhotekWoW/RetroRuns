-------------------------------------------------------------------------------
-- RetroRuns Data -- Drak'Tharon Keep
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 600  |  journalInstanceID: 273
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[273] = {
    kind              = "dungeon",
    instanceID        = 600,
    journalInstanceID = 273,
    name              = "Drak'Tharon Keep",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    routedIn          = "3.3.0",

    entrance = {
        mapID = 121,
        x     = 0.2838,
        y     = 0.8691,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37799, slot = "Back", name = "Reanimator's Cloak", sources = { [14]=18030, [15]=18030 }, bind = "BoE" },
        { id = 37800, slot = "Chest", name = "Aviary Guardsman's Hauberk", sources = { [14]=18031, [15]=18031 }, bind = "BoE" },
        { id = 35641, slot = "Feet", name = "Scytheclaw Boots", sources = { [14]=16565 }, bind = "BoE" },
        { id = 35639, slot = "Head", name = "Brighthelm of Guarding", sources = { [14]=16563 }, bind = "BoE" },
        { id = 37801, slot = "Waist", name = "Waistguard of the Risen Knight", sources = { [14]=18032, [15]=18032 }, bind = "BoE" },
        { id = 35640, slot = "Wrist", name = "Darkweb Bindings", sources = { [14]=16564 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Trollgore",
            journalEncounterID = 588,
            dungeonEncounterID = 1974,
            achievements       = {
                { id = 2151, name = "Consumption Junction", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37712, slot = "Feet", name = "Terrace Defence Boots", sources = { [14]=17962, [15]=17962 } },
                { id = 35620, slot = "Head", name = "Berserker's Horns", sources = { [14]=16554, [15]=16554 } },
                { id = 37715, slot = "Head", name = "Cowl of the Dire Troll", sources = { [14]=17964, [15]=17964 } },
                { id = 35619, slot = "Legs", name = "Infection Resistant Legguards", sources = { [14]=16553, [15]=16553 } },
                { id = 37717, slot = "Legs", name = "Legs of Physical Regeneration", sources = { [14]=17965, [15]=17965 } },
                { id = 35618, slot = "Two-Hand", name = "Troll Butcherer", sources = { [14]=16552, [15]=16552 } },
                { id = 37714, slot = "Waist", name = "Batrider's Cord", sources = { [14]=17963, [15]=17963 } },
            },
        },
        {
            index              = 2,
            name               = "Novos the Summoner",
            journalEncounterID = 589,
            dungeonEncounterID = 1976,
            achievements       = {
                { id = 2057, name = "Oh Novos!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37722, slot = "Chest", name = "Breastplate of Undeath", sources = { [14]=17968, [15]=17968 } },
                { id = 35632, slot = "Chest", name = "Robes of Novos", sources = { [14]=16556, [15]=16556 } },
                { id = 37718, slot = "Off-hand", name = "Temple Crystal Fragment", sources = { [14]=17966, [15]=17966 } },
                { id = 157558, slot = "Shoulder", name = "Shoddily Stitched Shoulderguards", sources = { [14]=93753, [15]=93753 } },
                { id = 37721, slot = "Weapon", name = "Cursed Lich Blade", sources = { [14]=17967, [15]=17967 } },
                { id = 35630, slot = "Weapon", name = "Summoner's Stone Gavel", sources = { [14]=16555, [15]=16555 } },
                { id = 40490, slot = "Wrist", name = "Necromantic Wristguards", sources = { [14]=19465, [15]=19465 } },
            },
        },
        {
            index              = 3,
            name               = "King Dred",
            journalEncounterID = 590,
            dungeonEncounterID = 1977,
            achievements       = {
                { id = 2039, name = "Better Off Dred", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37726, slot = "Head", name = "King Dred's Helm", sources = { [14]=17971, [15]=17971 } },
                { id = 35634, slot = "Head", name = "Scabrous-Hide Helm", sources = { [14]=16558, [15]=16558 } },
                { id = 35635, slot = "Legs", name = "Stable Master's Breeches", sources = { [14]=16559, [15]=16559 } },
                { id = 35633, slot = "Two-Hand", name = "Staff of the Great Reptile", sources = { [14]=16557, [15]=16557 } },
                { id = 157561, slot = "Waist", name = "Dino-Toothed Waistguard", sources = { [14]=93756, [15]=93756 } },
                { id = 37724, slot = "Wrist", name = "Handler's Arm Strap", sources = { [14]=17969, [15]=17969 } },
                { id = 37725, slot = "Wrist", name = "Savage Wound Wrap", sources = { [14]=17970, [15]=17970 } },
            },
        },
        {
            index              = 4,
            name               = "The Prophet Tharon'ja",
            journalEncounterID = 591,
            dungeonEncounterID = 1975,
            achievements       = {
            },
            loot = {
                { id = 37735, slot = "Chest", name = "Ziggurat Imprinted Chestguard", sources = { [14]=17977, [15]=17977 } },
                { id = 37798, slot = "Hands", name = "Overlook Handguards", sources = { [14]=18029, [15]=18029 } },
                { id = 35638, slot = "Head", name = "Helmet of Living Flesh", sources = { [14]=16562, [15]=16562 } },
                { id = 37791, slot = "Legs", name = "Leggings of the Winged Serpent", sources = { [14]=18023, [15]=18023 } },
                { id = 35637, slot = "Legs", name = "Muradin's Lost Greaves", sources = { [14]=16561, [15]=16561 } },
                { id = 35636, slot = "Off-hand", name = "Tharon'ja's Aegis", sources = { [14]=16560, [15]=16560 } },
                { id = 37733, slot = "Two-Hand", name = "Mojo Masked Crusher", sources = { [14]=17976, [15]=17976 } },
                { id = 37788, slot = "Wrist", name = "Limb Regeneration Bracers", sources = { [14]=18020, [15]=18020 } },
            },
        },
    },

    exitNote    = "Behind the boss there are a series of jumps that eventually lead to the entrance",
    minExitNote = "Path to entrance behind boss",

    routing = {
        -- 1. Trollgore (boss 1). North from the door, right at the fork.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Trollgore",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 160 },
                    kind    = "path",
                    note    = "After zoning in, follow the path north. At the fork, go right to locate ^Trollgore^.",
                    minNote = "Follow path to Trollgore",
                    points  = {
                        { 0.310, 0.802 },
                        { 0.336, 0.790 },
                        { 0.397, 0.868 },
                        { 0.444, 0.868 },
                        { 0.473, 0.822 },
                        { 0.473, 0.447 },
                        { 0.570, 0.316 },
                        { 0.568, 0.216 },
                    },
                },
            },
        },

        -- 2. Novos the Summoner (boss 2). East from Trollgore, one linear path.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Novos the Summoner",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 160 },
                    kind    = "path",
                    note    = "After killing ^Trollgore^, go east and follow the linear path until you reach ^Novos the Summoner^.",
                    minNote = "Follow path to Novos",
                    points  = {
                        { 0.602, 0.174 },
                        { 0.663, 0.175 },
                        { 0.663, 0.263 },
                        { 0.637, 0.299 },
                        { 0.638, 0.320 },
                        { 0.675, 0.385 },
                        { 0.689, 0.446 },
                    },
                },
            },
        },

        -- 3. King Dred (boss 3). Southwest out of Novos's room.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "King Dred",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 160 },
                    kind    = "path",
                    note    = "After defeating ^Novos the Summoner^, exit to the southwest and follow the path to ^King Dred^.",
                    minNote = "Southwest path to King Dred",
                    points  = {
                        { 0.692, 0.536 },
                        { 0.660, 0.583 },
                        { 0.559, 0.582 },
                        { 0.558, 0.776 },
                        { 0.658, 0.776 },
                        { 0.658, 0.828 },
                        { 0.641, 0.839 },
                    },
                },
            },
        },

        -- 4. The Prophet Tharon'ja (boss 4). Stairs north of Dred up to the
        -- Overlook, then one linear path.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "The Prophet Tharon'ja",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 160 },
                    kind    = "path",
                    note    = "After killing ^King Dred^, take the stairs just north of the boss.",
                    minNote = "Take stairs to north",
                    points  = {
                        { 0.642, 0.850 },
                        { 0.669, 0.804 },
                        { 0.669, 0.727 },
                        { 0.656, 0.721 },
                        { 0.613, 0.721 },
                    },
                },
                {
                    when    = { mapID = 161 },
                    kind    = "path",
                    note    = "Continue following the linear path until you reach the final boss, ^The Prophet Tharon'ja^.",
                    minNote = "Follow path to Tharon'ja",
                    points  = {
                        { 0.478, 0.718 },
                        { 0.393, 0.719 },
                        { 0.366, 0.676 },
                        { 0.369, 0.285 },
                        { 0.483, 0.285 },
                        { 0.511, 0.236 },
                        { 0.566, 0.236 },
                        { 0.565, 0.133 },
                        { 0.500, 0.132 },
                    },
                },
            },
        },
    },
}
