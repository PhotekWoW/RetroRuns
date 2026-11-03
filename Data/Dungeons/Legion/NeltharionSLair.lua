-------------------------------------------------------------------------------
-- RetroRuns Data -- Neltharion's Lair
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1458  |  journalInstanceID: 767
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[767] = {
    kind              = "dungeon",
    instanceID        = 1458,
    journalInstanceID = 767,
    name              = "Neltharion's Lair",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "7.0.3",
    timewalking       = true,
    routedIn          = "3.5.0",

    entrance = {
        mapID = 650,
        x     = 0.4956,
        y     = 0.6888,
    },

    gloryMeta = {
        id   = 11163,
        name = "Glory of the Legion Hero",
        rewardItemID       = 141217,
        rewardMountSpellID = 225765,
        rewardName         = "Leyfeather Hippogryph",
    },

    -- Instance-wide achievements with no single boss; every boss lists them.
    raidAchievements = {
        { id = 10996, name = "Got to Ketchum All", meta = true, soloable = "kinda" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Rokmora",
            journalEncounterID = 1662,
            dungeonEncounterID = 1790,
            achievements       = {
            },
            loot = {
                { id = 137336, slot = "Chest", name = "Vest of Rupturing Diamonds", sources = { [14]=78936, [15]=80092, [16]=78936 } },
                { id = 139105, slot = "Feet", name = "Rivermane Sandals", sources = { [14]=80444, [15]=80444, [16]=80444 } },
                { id = 134427, slot = "Legs", name = "Riverrider Legwraps", sources = { [14]=78935, [15]=80016, [16]=78935 } },
                { id = 205973, slot = "Ranged", name = "Rod of Crystalline Energies", sources = { [14]=187745, [15]=187745, [16]=187745 } },
                { id = 139121, slot = "Shoulder", name = "Skyhorn Mantle", sources = { [14]=80457, [15]=80457, [16]=80457 } },
                { id = 134481, slot = "Waist", name = "Boulderbuckle Strap", sources = { [14]=78941, [15]=80141, [16]=78941 } },
                { id = 139095, slot = "Waist", name = "Greystone Belt", sources = { [14]=80437, [15]=80437, [16]=80437 } },
                { id = 137337, slot = "Wrist", name = "Deepfurrow Bracers", sources = { [14]=78938, [15]=79972, [16]=78938 } },
                { id = 139130, slot = "Wrist", name = "Sunfrost Wristwraps", sources = { [14]=80466, [15]=80466, [16]=80466 } },
            },
        },
        {
            index              = 2,
            name               = "Ularogg Cragshaper",
            journalEncounterID = 1665,
            dungeonEncounterID = 1791,
            achievements       = {
            },
            loot = {
                { id = 137354, slot = "Chest", name = "Tunic of Screaming Earth", sources = { [14]=78953, [15]=80154, [16]=78953 } },
                { id = 134141, slot = "Feet", name = "Rockbound Sabatons", sources = { [14]=77455, [15]=77455, [16]=77455 } },
                { id = 134443, slot = "Hands", name = "Gravelworn Handguards", sources = { [14]=78940, [15]=80068, [16]=78940 } },
                { id = 137341, slot = "Head", name = "Cragshaper's Fitted Hood", sources = { [14]=78939, [15]=80033, [16]=78939 } },
                { id = 134152, slot = "Head", name = "Steelgazer Hide Hood", sources = { [14]=77463, [15]=77463, [16]=77463 } },
                { id = 137342, slot = "Legs", name = "Rock Solid Legplates", sources = { [14]=78942, [15]=79973, [16]=78942 } },
                { id = 134177, slot = "Shoulder", name = "Roggthread Mantle", sources = { [14]=77481, [15]=77481, [16]=77481 } },
                { id = 134164, slot = "Wrist", name = "Bitestone Wristwrap", sources = { [14]=77468, [15]=77468, [16]=77468 } },
            },
        },
        {
            index              = 3,
            name               = "Naraxas",
            journalEncounterID = 1673,
            dungeonEncounterID = 1792,
            achievements       = {
                { id = 10875, name = "Can't Eat Just One", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 134408, slot = "Back", name = "Putrid Carapace", sources = { [14]=78947, [15]=80812, [16]=78947 } },
                { id = 134416, slot = "Feet", name = "Offal Galoshes", sources = { [14]=78943, [15]=80005, [16]=78943 } },
                { id = 137348, slot = "Hands", name = "Gauntlets of Innumerable Barbs", sources = { [14]=78945, [15]=80153, [16]=78945 } },
                { id = 134511, slot = "Head", name = "Subterranean Horror Faceguard", sources = { [14]=78946, [15]=79953, [16]=78946 } },
                { id = 205974, slot = "Off-hand", name = "Monstrous Gluttony", sources = { [14]=187746, [15]=187746, [16]=187746 } },
                { id = 134458, slot = "Wrist", name = "Wristbands of Rousing Violence", sources = { [14]=78944, [15]=80083, [16]=78944 } },
            },
        },
        {
            index              = 4,
            name               = "Dargrul the Underking",
            journalEncounterID = 1687,
            dungeonEncounterID = 1793,
            scenarioCriteriaID = 31405,
            achievements       = {
            },
            loot = {
                { id = 134135, slot = "Chest", name = "Rockbound Chestguard", sources = { [14]=77449, [15]=77449, [16]=77449 } },
                { id = 137352, slot = "Chest", name = "Tunic of Smoldering Ire", sources = { [14]=78949, [15]=80034, [16]=78949 } },
                { id = 134166, slot = "Feet", name = "Bitestone Boots", sources = { [14]=77470, [15]=77470, [16]=77470 } },
                { id = 134420, slot = "Hands", name = "Gloves of the Mountain Conquest", sources = { [14]=78948, [15]=80009, [16]=78948 } },
                { id = 137355, slot = "Hands", name = "Rumblestone Gauntlets", sources = { [14]=78955, [15]=79974, [16]=78955 } },
                { id = 134470, slot = "Head", name = "Mountain Throne Coif", sources = { [14]=78937, [15]=80130, [16]=78937 } },
                { id = 137353, slot = "Legs", name = "Charskin Legguards", sources = { [14]=78951, [15]=80093, [16]=78951 } },
                { id = 134474, slot = "Legs", name = "Faultline Leggings", sources = { [14]=78952, [15]=80134, [16]=78952 } },
                { id = 134154, slot = "Shoulder", name = "Steelgazer Hide Mantle", sources = { [14]=77465, [15]=77465, [16]=77465 } },
                { id = 134517, slot = "Shoulder", name = "Tremorguard Pauldrons", sources = { [14]=78954, [15]=79959, [16]=78954 } },
                { id = 205975, slot = "Two-Hand", name = "Hate-Sculpted Magma", sources = { [14]=187747, [15]=187747, [16]=187747 } },
                { id = 134171, slot = "Waist", name = "Roggthread Cord", sources = { [14]=77475, [15]=77475, [16]=77475 } },
                { id = 134455, slot = "Waist", name = "Sinister Ashfall Cord", sources = { [14]=78950, [15]=80080, [16]=78950 } },
            },
            specialLoot = {
                { id = 245451, kind = "decor", name = "Thunder Totem Brazier", decorID = 1232 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Rokmora (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Rokmora",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 731 },
                    kind    = "path",
                    note    = "After zoning in, jump into the hole. When you reach land, follow the linear path ahead until you reach ^Rokmora^.",
                    minNote = "Follow linear path to Rokmora",
                    points  = {
                        { 0.849, 0.481 },
                        { 0.831, 0.445 },
                        { 0.798, 0.434 },
                        { 0.724, 0.421 },
                        { 0.724, 0.454 },
                        { 0.702, 0.459 },
                        { 0.679, 0.466 },
                    },
                },
            },
        },
        -- 2. Ularogg Cragshaper (boss 2), down the river by barrel. Both legs
        -- share one map, so the subzone tells them apart.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Ularogg Cragshaper",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 731, subZone = "The Lost Road" },
                    kind        = "poi",
                    note        = "After defeating ^Rokmora^, continue past him and click the ^Empty Barrel^ to be sent down the river.",
                    minNote     = "Click Empty Barrel to reach next area",
                    mapLabel    = "Click Empty Barrel",
                    mapLabelPos = "above",
                    points      = {
                        { 0.706, 0.568 },
                    },
                },
                {
                    when    = { mapID = 731, subZone = "Broken Teeth" },
                    kind    = "path",
                    note    = "When you reach the other side, follow the path north until you reach ^Ularogg Cragshaper^.",
                    minNote = "North to Ularogg",
                    points  = {
                        { 0.591, 0.847 },
                        { 0.571, 0.814 },
                        { 0.559, 0.791 },
                        { 0.529, 0.770 },
                        { 0.504, 0.743 },
                        { 0.511, 0.723 },
                        { 0.499, 0.695 },
                        { 0.494, 0.625 },
                        { 0.492, 0.600 },
                        { 0.466, 0.626 },
                        { 0.451, 0.625 },
                        { 0.450, 0.591 },
                    },
                },
            },
        },
        -- 3. Naraxas (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Naraxas",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 731 },
                    kind    = "path",
                    note    = "After killing ^Ularogg Cragshaper^, continue north on the linear path to reach ^Naraxas^.",
                    minNote = "North to Naraxas",
                    points  = {
                        { 0.427, 0.529 },
                        { 0.427, 0.492 },
                        { 0.447, 0.444 },
                        { 0.456, 0.450 },
                        { 0.465, 0.433 },
                        { 0.467, 0.406 },
                        { 0.460, 0.382 },
                        { 0.468, 0.351 },
                        { 0.440, 0.315 },
                        { 0.413, 0.308 },
                        { 0.336, 0.379 },
                    },
                },
            },
        },
        -- 4. Dargrul the Underking (boss 4), down the hole past Naraxas.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Dargrul the Underking",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 731 },
                    kind    = "path",
                    note    = "After defeating ^Naraxas^, jump in the hole to find his loot and to reach the next area. Continue ahead to reach the final boss, ^Dargrul the Underking^.",
                    minNote = "Jump in hole and proceed to Dargrul",
                    points  = {
                        { 0.286, 0.435 },
                        { 0.267, 0.482 },
                        { 0.239, 0.505 },
                        { 0.172, 0.631 },
                    },
                },
            },
        },
    },
}
