-------------------------------------------------------------------------------
-- RetroRuns Data -- Eye of Azshara
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1456  |  journalInstanceID: 716
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[716] = {
    kind              = "dungeon",
    instanceID        = 1456,
    journalInstanceID = 716,
    name              = "Eye of Azshara",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "7.0.3",
    routedIn          = "3.5.1",
    timewalking       = true,

    entrance = {
        mapID = 630,
        x     = 0.6100,
        y     = 0.4111,
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
            name               = "Warlord Parjesh",
            journalEncounterID = 1480,
            dungeonEncounterID = 1810,
            achievements       = {
                { id = 10456, name = "But You Say He's Just a Friend", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 134223, slot = "Chest", name = "Coralplate Chestguard", sources = { [14]=77517, [15]=77517, [16]=77517 } },
                { id = 134441, slot = "Feet", name = "Shellshock Footguards", sources = { [14]=78958, [15]=80066, [16]=78958 } },
                { id = 134261, slot = "Hands", name = "Seawitch Gloves", sources = { [14]=77545, [15]=77545, [16]=77545 } },
                { id = 134240, slot = "Head", name = "Brinewashed Leather Cowl", sources = { [14]=77531, [15]=77531, [16]=77531 } },
                { id = 137360, slot = "Shoulder", name = "Shoulderpads of Crashing Waves", sources = { [14]=78957, [15]=80035, [16]=78957 } },
                { id = 137361, slot = "Waist", name = "Roaring Shellbreaker Greatbelt", sources = { [14]=78961, [15]=79975, [16]=78961 } },
                { id = 134251, slot = "Waist", name = "Sea Stalker's Cinch", sources = { [14]=77535, [15]=77535, [16]=77535 } },
                { id = 134484, slot = "Wrist", name = "Crestrider Conduit Bracers", sources = { [14]=78959, [15]=80144, [16]=78959 } },
            },
        },
        {
            index              = 2,
            name               = "Lady Hatecoil",
            journalEncounterID = 1490,
            dungeonEncounterID = 1811,
            achievements       = {
                { id = 10457, name = "Stay Salty", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 134263, slot = "Chest", name = "Seawitch Robes", sources = { [14]=77547, [15]=77547, [16]=77547 } },
                { id = 134505, slot = "Feet", name = "Horizon Line Warboots", sources = { [14]=78960, [15]=79947, [16]=78960 } },
                { id = 134253, slot = "Hands", name = "Sea Stalker's Gloves", sources = { [14]=77537, [15]=77537, [16]=77537 } },
                { id = 134471, slot = "Head", name = "Helm of Endless Dunes", sources = { [14]=78964, [15]=80131, [16]=78964 } },
                { id = 134238, slot = "Legs", name = "Brinewashed Leather Pants", sources = { [14]=77529, [15]=77529, [16]=77529 } },
                { id = 137364, slot = "Shoulder", name = "Crashing Oceantide Mantle", sources = { [14]=78963, [15]=80094, [16]=78963 } },
                { id = 134433, slot = "Waist", name = "Cord of the Sea-Caller", sources = { [14]=78962, [15]=80021, [16]=78962 } },
                { id = 134230, slot = "Wrist", name = "Coralplate Wristguard", sources = { [14]=77524, [15]=77524, [16]=77524 } },
            },
        },
        {
            index              = 3,
            name               = "King Deepbeard",
            journalEncounterID = 1491,
            dungeonEncounterID = 1812,
            achievements       = {
            },
            loot = {
                { id = 134406, slot = "Back", name = "Mainsail Cloak", sources = { [14]=78969, [15]=80810, [16]=78969 } },
                { id = 137368, slot = "Chest", name = "Breastplate of Ten Lashes", sources = { [14]=78967, [15]=80155, [16]=78967 } },
                { id = 134514, slot = "Legs", name = "Keelhauler Legplates", sources = { [14]=78968, [15]=79956, [16]=78968 } },
                { id = 134428, slot = "Legs", name = "Rising Ocean Legwraps", sources = { [14]=78965, [15]=80017, [16]=78965 } },
                { id = 134456, slot = "Waist", name = "Taut Halyard Waistband", sources = { [14]=78966, [15]=80081, [16]=78966 } },
            },
        },
        {
            index              = 4,
            name               = "Serpentrix",
            journalEncounterID = 1479,
            dungeonEncounterID = 1813,
            achievements       = {
            },
            loot = {
                { id = 134438, slot = "Chest", name = "Tunic of the Pitiless Monstrosity", sources = { [14]=78971, [15]=80063, [16]=78971 } },
                { id = 134465, slot = "Feet", name = "Hydra Scale Sabatons", sources = { [14]=78972, [15]=80125, [16]=78972 } },
                { id = 134239, slot = "Hands", name = "Brinewashed Leather Grips", sources = { [14]=77530, [15]=77530, [16]=77530 } },
                { id = 134508, slot = "Hands", name = "Stormwake Handguards", sources = { [14]=78973, [15]=79950, [16]=78973 } },
                { id = 134260, slot = "Head", name = "Seawitch Hood", sources = { [14]=77544, [15]=77544, [16]=77544 } },
                { id = 134256, slot = "Legs", name = "Sea Stalker's Leggings", sources = { [14]=77540, [15]=77540, [16]=77540 } },
                { id = 134228, slot = "Shoulder", name = "Coralplate Pauldrons", sources = { [14]=77522, [15]=77522, [16]=77522 } },
                { id = 137372, slot = "Wrist", name = "Wristbands of the Swirling Deeps", sources = { [14]=78970, [15]=80036, [16]=78970 } },
            },
        },
        {
            index              = 5,
            name               = "Wrath of Azshara",
            journalEncounterID = 1492,
            dungeonEncounterID = 1814,
            achievements       = {
                { id = 10458, name = "Ready for Raiding V", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 134237, slot = "Feet", name = "Brinewashed Leather Boots", sources = { [14]=77528, [15]=77528, [16]=77528 } },
                { id = 134417, slot = "Feet", name = "Slippers of Martyrdom", sources = { [14]=78974, [15]=80006, [16]=78974 } },
                { id = 134512, slot = "Head", name = "Casque of the Deep", sources = { [14]=78977, [15]=79954, [16]=78977 } },
                { id = 134255, slot = "Head", name = "Sea Stalker's Hood", sources = { [14]=77539, [15]=77539, [16]=77539 } },
                { id = 134478, slot = "Shoulder", name = "Thundercrush Pauldrons", sources = { [14]=78976, [15]=80138, [16]=78976 } },
                { id = 134225, slot = "Waist", name = "Coralplate Girdle", sources = { [14]=77519, [15]=77519, [16]=77519 } },
                { id = 134259, slot = "Waist", name = "Seawitch Cinch", sources = { [14]=77543, [15]=77543, [16]=77543 } },
                { id = 134459, slot = "Wrist", name = "Cuffs of the Arcane Storm", sources = { [14]=78975, [15]=80084, [16]=78975 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Warlord Parjesh (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Warlord Parjesh",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 713 },
                    kind    = "path",
                    note    = "After zoning in, follow the path straight ahead to reach ^Warlord Parjesh^.",
                    minNote = "Straight ahead to Warlord Parjesh",
                    points  = {
                        { 0.498, 0.858 },
                        { 0.510, 0.832 },
                        { 0.509, 0.808 },
                        { 0.530, 0.764 },
                        { 0.542, 0.749 },
                        { 0.545, 0.720 },
                    },
                },
            },
        },
        -- 2. Lady Hatecoil (boss 2), shielded until both arcanists fall.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Lady Hatecoil",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 713 },
                    kind    = "path",
                    note    = "After defeating ^Warlord Parjesh^, backtrack to the west. Kill two shielded ^Hatecoil Arcanist^ to remove the shield from ^Lady Hatecoil^.",
                    minNote = "Go west, kill Hatecoil Arcanists",
                    points  = {
                        { 0.544, 0.728 },
                        { 0.539, 0.751 },
                        { 0.523, 0.754 },
                        { 0.506, 0.741 },
                        { 0.464, 0.744 },
                        { 0.448, 0.725 },
                        { 0.448, 0.690 },
                        { 0.436, 0.656 },
                        { 0.417, 0.633 },
                        { 0.405, 0.595 },
                    },
                },
                {
                    when            = { mapID = 713 },
                    kind            = "poi",
                    note            = "With ^Lady Hatecoil^ vulnerable, wade out into the shallow water and kill her.",
                    minNote         = "Find Lady Hatecoil in the water",
                    triggeredBy     = { dialog = { npc = "Hatecoil Arcanist", match = "Lady Hatecoil is vulnerable" } },
                    drawWhenOpen    = true,
                    noMarker        = true,
                    highlightCircle = true,
                    points          = {
                        { 0.460, 0.500 },
                    },
                },
            },
        },
        -- 3. Serpentrix (boss 4), before King Deepbeard on the way through.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 4,
            title     = "Serpentrix",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 713 },
                    kind    = "path",
                    note    = "After killing ^Lady Hatecoil^, go northeast to kill ^Serpentrix^.",
                    minNote = "Northeast to Serpentrix",
                    points  = {
                        { 0.465, 0.457 },
                        { 0.541, 0.382 },
                    },
                },
            },
        },
        -- 4. King Deepbeard (boss 3).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 3,
            title     = "King Deepbeard",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 713 },
                    kind    = "path",
                    note    = "After defeating ^Serpentrix^, go east through the caves. After you reach the other side, work your way up the path until you reach ^King Deepbeard^.",
                    minNote = "East through caves, path to Deepbeard",
                    points  = {
                        { 0.594, 0.339 },
                        { 0.651, 0.357 },
                        { 0.678, 0.349 },
                        { 0.696, 0.363 },
                        { 0.736, 0.359 },
                        { 0.789, 0.421 },
                        { 0.788, 0.445 },
                        { 0.747, 0.477 },
                        { 0.706, 0.498 },
                    },
                },
            },
        },
        -- 5. Wrath of Azshara (boss 5).
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Wrath of Azshara",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 713 },
                    kind    = "path",
                    note    = "After killing ^King Deepbeard^, exit north and jump down to reach the final boss, ^Wrath of Azshara^. Kill the four channeling enemies to start the encounter.",
                    minNote = "Exit north, jump down to Wrath",
                    points  = {
                        { 0.697, 0.479 },
                        { 0.701, 0.456 },
                        { 0.682, 0.446 },
                        { 0.642, 0.453 },
                        { 0.600, 0.512 },
                    },
                },
            },
        },
    },
}
