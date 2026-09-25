-------------------------------------------------------------------------------
-- RetroRuns Data -- Wailing Caverns
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 43  |  journalInstanceID: 240
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[240] = {
    kind              = "dungeon",
    instanceID        = 43,
    journalInstanceID = 240,
    name              = "Wailing Caverns",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 11,
        x     = 0.5444,
        y     = 0.6937,
    },

    trashLoot = {
        { id = 6632, slot = "Back", name = "Feyscale Cloak", sources = { [14]=2547 }, bind = "BoP", rareNpc = "Deviate Faerie Dragon" },
        { id = 10413, slot = "Hands", name = "Gloves of the Fang", sources = { [14]=3965 }, bind = "BoE" },
        { id = 132743, slot = "Hands", name = "Slither-Scale Gauntlets", sources = { [14]=76419 }, bind = "BoE" },
        { id = 5243, slot = "Ranged", name = "Firebelcher", sources = { [14]=2011 }, bind = "BoP", rareNpc = "Deviate Faerie Dragon" },
        { id = 208019, slot = "Feet", name = "Quagmire Trudgers", sources = { [14]=189071 }, bind = "BoE", tag = "Stuffed Deviate Scale Pouch" },
        { id = 208020, slot = "Hands", name = "Dagmire Gloves", sources = { [14]=189072 }, bind = "BoE", tag = "Stuffed Deviate Scale Pouch" },
        { id = 208021, slot = "Ranged", name = "Sizzling Stick", sources = { [14]=189073 }, bind = "BoE", tag = "Stuffed Deviate Scale Pouch" },
        { id = 208018, slot = "Weapon", name = "Fangblade", sources = { [14]=189070 }, bind = "BoE", tag = "Stuffed Deviate Scale Pouch" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Lady Anacondra",
            journalEncounterID = 474,
            dungeonEncounterID = 585,
            achievements       = {
            },
            loot = {
                { id = 151427, slot = "Head", name = "Snake-Charmer's Casque", sources = { [14]=89430 } },
                { id = 132737, slot = "Shoulder", name = "Cavern Slitherer Pauldrons", sources = { [14]=76414 } },
                { id = 5404, slot = "Shoulder", name = "Serpent's Shoulders", sources = { [14]=2095 } },
                { id = 10412, slot = "Waist", name = "Belt of the Fang", sources = { [14]=3964 } },
                { id = 132740, slot = "Waist", name = "Slither-Scale Cord", sources = { [14]=76416 } },
                { id = 151426, slot = "Wrist", name = "Lady Anacondra's Satin Cuffs", sources = { [14]=89429 } },
            },
        },
        {
            index              = 2,
            name               = "Lord Pythas",
            journalEncounterID = 476,
            dungeonEncounterID = 588,
            achievements       = {
            },
            loot = {
                { id = 6473, slot = "Chest", name = "Armor of the Fang", sources = { [14]=2429 } },
                { id = 132739, slot = "Chest", name = "Slither-Scale Hauberk", sources = { [14]=76415 } },
                { id = 151429, slot = "Shoulder", name = "Lord Pythas' Pauldrons", sources = { [14]=89432 } },
                { id = 151428, slot = "Waist", name = "Slumbersilk Waistcord", sources = { [14]=89431 } },
                { id = 6472, slot = "Weapon", name = "Stinging Viper", sources = { [14]=2428 } },
            },
        },
        {
            index              = 3,
            name               = "Lord Cobrahn",
            journalEncounterID = 475,
            dungeonEncounterID = 586,
            achievements       = {
            },
            loot = {
                { id = 6465, slot = "Chest", name = "Robe of the Moccasin", sources = { [14]=2423 } },
                { id = 10410, slot = "Legs", name = "Leggings of the Fang", sources = { [14]=3962 } },
                { id = 132742, slot = "Legs", name = "Slither-Scale Britches", sources = { [14]=76418 } },
                { id = 6460, slot = "Waist", name = "Cobrahn's Grasp", sources = { [14]=2421 } },
            },
        },
        {
            index              = 4,
            name               = "Kresh",
            journalEncounterID = 477,
            dungeonEncounterID = 587,
            achievements       = {
            },
            loot = {
                { id = 13245, slot = "Off-hand", name = "Kresh's Back", sources = { [14]=4807 } },
                { id = 6447, slot = "Off-hand", name = "Worn Turtle Shell Shield", sources = { [14]=2417 } },
            },
        },
        {
            index              = 5,
            name               = "Skum",
            journalEncounterID = 478,
            dungeonEncounterID = 589,
            achievements       = {
            },
            loot = {
                { id = 6449, slot = "Back", name = "Glowing Lizardscale Cloak", sources = { [14]=2419 } },
                { id = 6448, slot = "Weapon", name = "Tail Spike", sources = { [14]=2418 } },
            },
        },
        {
            index              = 6,
            name               = "Lord Serpentis",
            journalEncounterID = 479,
            dungeonEncounterID = 590,
            achievements       = {
            },
            loot = {
                { id = 10411, slot = "Feet", name = "Footpads of the Fang", sources = { [14]=3963 } },
                { id = 6459, slot = "Feet", name = "Savage Trodders", sources = { [14]=2420 } },
                { id = 132741, slot = "Feet", name = "Slither-Scale Boots", sources = { [14]=76417 } },
                { id = 5970, slot = "Hands", name = "Serpent Gloves", sources = { [14]=2225 } },
                { id = 6469, slot = "Ranged", name = "Venomstrike", sources = { [14]=2427 } },
            },
        },
        {
            index              = 7,
            name               = "Verdan the Everliving",
            journalEncounterID = 480,
            dungeonEncounterID = 591,
            achievements       = {
            },
            loot = {
                { id = 6629, slot = "Back", name = "Sporid Cape", sources = { [14]=2544 } },
                { id = 6630, slot = "Off-hand", name = "Seedcloud Buckler", sources = { [14]=2545 } },
                { id = 6631, slot = "Two-Hand", name = "Living Root", sources = { [14]=2546 } },
            },
        },
        {
            index              = 8,
            name               = "Mutanus the Devourer",
            journalEncounterID = 481,
            dungeonEncounterID = 592,
            achievements       = {
            },
            loot = {
                { id = 6627, slot = "Chest", name = "Mutant Breastplate", sources = { [14]=2542 } },
                { id = 6461, slot = "Shoulder", name = "Slime-Encrusted Pads", sources = { [14]=2422 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    pois = {
        -- Rare spawn point.
        { mapID = 279, poiKind = "rare", rareNpc = "Deviate Faerie Dragon",
          mapLabelPos = "legend-bottomleft", points = { { 0.728, 0.718 } } },
        -- Druid of the Fang spawns; the pouch drops from any of them.
        { mapID = 279, poiKind = "chest", tag = "Stuffed Deviate Scale Pouch",
          hintNote = "Drops from Druid of the Fang",
          mapLabelPos = "legend-bottomleft", navPoint = { 0.288, 0.335 },
          points = {
            { 0.310, 0.412 }, { 0.032, 0.303 }, { 0.050, 0.315 }, { 0.083, 0.388 },
            { 0.090, 0.395 }, { 0.094, 0.279 }, { 0.109, 0.525 }, { 0.122, 0.513 },
            { 0.150, 0.353 }, { 0.160, 0.547 }, { 0.200, 0.410 }, { 0.288, 0.335 },
            { 0.393, 0.325 }, { 0.535, 0.650 }, { 0.549, 0.690 }, { 0.552, 0.769 },
            { 0.552, 0.908 }, { 0.574, 0.908 }, { 0.608, 0.507 }, { 0.653, 0.577 },
            { 0.696, 0.627 },
          } },
    },

    routing = {
        -- 1. Lady Anacondra (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Lady Anacondra",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 279 },
                    kind    = "path",
                    note    = "After zoning in, follow the path ahead and go left at the fork to reach ^Lady Anacondra^.",
                    minNote = "Left at fork for Anacondra",
                    points  = {
                        { 0.461, 0.554 },
                        { 0.451, 0.522 },
                        { 0.421, 0.516 },
                        { 0.389, 0.513 },
                        { 0.356, 0.519 },
                        { 0.346, 0.502 },
                        { 0.356, 0.473 },
                        { 0.381, 0.463 },
                        { 0.375, 0.405 },
                        { 0.351, 0.394 },
                        { 0.329, 0.404 },
                    },
                },
            },
        },

        -- 2. Lord Pythas (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Lord Pythas",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 279 },
                    kind    = "path",
                    note    = "After defeating ^Lady Anacondra^, jump over the ledge into the water and head west. Loop around to the right until you reach ^Lord Pythas^.",
                    minNote = "Jump in water, west to Pythas",
                    points  = {
                        { 0.280, 0.427 },
                        { 0.264, 0.434 },
                        { 0.254, 0.455 },
                        { 0.237, 0.457 },
                        { 0.200, 0.456 },
                        { 0.158, 0.465 },
                        { 0.136, 0.427 },
                        { 0.114, 0.387 },
                        { 0.095, 0.350 },
                        { 0.092, 0.327 },
                        { 0.104, 0.302 },
                        { 0.125, 0.292 },
                        { 0.141, 0.302 },
                        { 0.133, 0.325 },
                        { 0.139, 0.337 },
                        { 0.153, 0.371 },
                        { 0.166, 0.386 },
                    },
                },
            },
        },

        -- 3. Lord Cobrahn (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Lord Cobrahn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 279 },
                    kind    = "path",
                    note    = "After defeating ^Lord Pythas^, go north and follow the path all the way around to ^Lord Cobrahn^.",
                    minNote = "North path to Cobrahn",
                    points  = {
                        { 0.176, 0.339 },
                        { 0.172, 0.278 },
                        { 0.156, 0.240 },
                        { 0.128, 0.239 },
                        { 0.099, 0.265 },
                        { 0.050, 0.297 },
                        { 0.055, 0.330 },
                        { 0.073, 0.375 },
                        { 0.087, 0.406 },
                        { 0.086, 0.457 },
                        { 0.096, 0.480 },
                        { 0.117, 0.522 },
                        { 0.150, 0.534 },
                    },
                },
            },
        },

        -- 4. Kresh (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Kresh",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 279 },
                    kind    = "path",
                    note    = "After defeating ^Lord Cobrahn^, jump over the cliff just north of you. Go east back into the waterway until you find ^Kresh^ patrolling.",
                    minNote = "East to Kresh",
                    points  = {
                        { 0.153, 0.517 },
                        { 0.163, 0.470 },
                        { 0.197, 0.456 },
                        { 0.222, 0.453 },
                        { 0.238, 0.462 },
                        { 0.256, 0.456 },
                        { 0.267, 0.426 },
                        { 0.309, 0.362 },
                        { 0.358, 0.348 },
                    },
                },
            },
        },

        -- 5. Skum (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Skum",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 279 },
                    kind    = "path",
                    note    = "After killing ^Kresh^, continue southeast through the waterway all the way until ^Skum^.",
                    minNote = "Southeast to Skum",
                    points  = {
                        { 0.415, 0.356 },
                        { 0.443, 0.370 },
                        { 0.470, 0.394 },
                        { 0.520, 0.444 },
                        { 0.527, 0.475 },
                        { 0.523, 0.508 },
                        { 0.524, 0.565 },
                        { 0.566, 0.641 },
                        { 0.601, 0.709 },
                    },
                },
            },
        },

        -- 6. Lord Serpentis (boss 6)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Lord Serpentis",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 279 },
                    kind    = "path",
                    note    = "After killing ^Skum^, weave around the long upward path until you reach ^Lord Serpentis^.",
                    minNote = "Long upward path to Serpentis",
                    points  = {
                        { 0.611, 0.788 },
                        { 0.595, 0.814 },
                        { 0.584, 0.848 },
                        { 0.570, 0.880 },
                        { 0.549, 0.885 },
                        { 0.531, 0.855 },
                        { 0.549, 0.798 },
                        { 0.540, 0.764 },
                        { 0.529, 0.721 },
                        { 0.520, 0.675 },
                        { 0.500, 0.635 },
                        { 0.510, 0.600 },
                        { 0.542, 0.574 },
                        { 0.573, 0.561 },
                        { 0.618, 0.610 },
                        { 0.639, 0.603 },
                        { 0.656, 0.613 },
                        { 0.675, 0.625 },
                        { 0.708, 0.628 },
                        { 0.721, 0.656 },
                        { 0.730, 0.698 },
                        { 0.722, 0.770 },
                        { 0.695, 0.824 },
                        { 0.667, 0.841 },
                        { 0.625, 0.831 },
                        { 0.585, 0.786 },
                        { 0.567, 0.757 },
                        { 0.551, 0.706 },
                        { 0.542, 0.643 },
                        { 0.542, 0.611 },
                        { 0.559, 0.597 },
                        { 0.588, 0.534 },
                    },
                },
            },
        },

        -- 7. Verdan the Everliving (boss 7)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Verdan the Everliving",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 279 },
                    kind    = "path",
                    note    = "After killing ^Lord Serpentis^, you will find ^Verdan the Everliving^ nearby to the northwest.",
                    minNote = "Northwest to Verdan",
                    points  = {
                        { 0.597, 0.506 },
                        { 0.579, 0.492 },
                    },
                },
            },
        },

        -- 8. Mutanus the Devourer (boss 8)
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Mutanus the Devourer",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 279, subZone = "Crag of the Everliving" },
                    kind        = "poi",
                    mapLabel    = "Jump in hole",
                    mapLabelPos = "above",
                    note        = "After defeating ^Verdan the Everliving^, run north past him and jump into the hole.",
                    minNote     = "Jump in hole behind boss",
                    points      = {
                        { 0.547, 0.413 },
                    },
                },
                {
                    when        = { mapID = 279, subZone = "Screaming Gully" },
                    kind        = "poi",
                    mapLabel    = "Escort Muyoh",
                    mapLabelPos = "above",
                    note        = "After you land in the hole, follow the path back to the entrance to begin an escort with ^Muyoh^.",
                    minNote     = "Start Escort at Entrance",
                    points      = {
                        { 0.459, 0.538 },
                    },
                },
                {
                    when        = { mapID = 279 },
                    kind        = "path",
                    triggeredBy = { dialog = { npc = "Muyoh", match = "awakening ritual" } },
                    note        = "Escort ^Muyoh^, stopping two times on the way to the final boss, ^Mutanus the Devourer^. Kill several waves of trash and the boss will spawn.",
                    minNote     = "Escort Muyoh to Mutanus",
                    points      = {
                        { 0.439, 0.516 },
                        { 0.388, 0.515 },
                        { 0.348, 0.515 },
                        { 0.351, 0.479 },
                        { 0.370, 0.463 },
                        { 0.378, 0.440 },
                        { 0.375, 0.400 },
                        { 0.347, 0.394 },
                        { 0.328, 0.406 },
                        { 0.281, 0.427 },
                        { 0.260, 0.387 },
                        { 0.263, 0.335 },
                        { 0.313, 0.300 },
                        { 0.338, 0.290 },
                        { 0.347, 0.267 },
                        { 0.378, 0.261 },
                        { 0.378, 0.222 },
                        { 0.340, 0.196 },
                        { 0.340, 0.176 },
                    },
                },
            },
        },
    },
}
