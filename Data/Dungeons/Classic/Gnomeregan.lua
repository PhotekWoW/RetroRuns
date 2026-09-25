-------------------------------------------------------------------------------
-- RetroRuns Data -- Gnomeregan
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 90  |  journalInstanceID: 231
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[231] = {
    kind              = "dungeon",
    instanceID        = 90,
    journalInstanceID = 231,
    name              = "Gnomeregan",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 30,
        x     = 0.3010,
        y     = 0.7470,
    },

    pois = {
        { mapID = 226, poiKind = "rare", rareNpc = "Dark Iron Ambassador", mapLabelPos = "above", points = { { 0.254, 0.574 }, { 0.282, 0.488 }, { 0.296, 0.420 }, { 0.308, 0.626 }, { 0.312, 0.680 }, { 0.404, 0.662 }, { 0.438, 0.598 } } },
    },

    trashLoot = {
        { id = 9508, slot = "Chest", name = "Mechbuilder's Overalls", sources = { [14]=3323 }, bind = "BoE" },
        { id = 9510, slot = "Feet", name = "Caverndeep Trudgers", sources = { [14]=3325 }, bind = "BoE" },
        { id = 9491, slot = "Hands", name = "Hotshot Pilot's Gloves", sources = { [14]=3321 }, bind = "BoE" },
        { id = 9509, slot = "Legs", name = "Petrolspill Leggings", sources = { [14]=3324 }, bind = "BoE" },
        { id = 9456, slot = "Ranged", name = "Glass Shooter", sources = { [14]=3295 }, bind = "BoP", rareNpc = "Dark Iron Ambassador" },
        { id = 9489, slot = "Ranged", name = "Gyromatic Icemaker", sources = { [14]=3319 }, bind = "BoP" },
        { id = 9487, slot = "Ranged", name = "Hi-Tech Supergun", sources = { [14]=3317 }, bind = "BoE" },
        { id = 9490, slot = "Two-Hand", name = "Gizmotron Megachopper", sources = { [14]=3320 }, bind = "BoE" },
        { id = 9486, slot = "Two-Hand", name = "Supercharger Battle Axe", sources = { [14]=3316 }, bind = "BoE" },
        { id = 9488, slot = "Weapon", name = "Oscillating Power Hammer", sources = { [14]=3318 }, bind = "BoE" },
        { id = 9457, slot = "Weapon", name = "Royal Diplomatic Scepter", sources = { [14]=3296 }, bind = "BoP", rareNpc = "Dark Iron Ambassador" },
        { id = 9485, slot = "Weapon", name = "Vibroblade", sources = { [14]=3315 }, bind = "BoE" },
        { id = 9455, slot = "Wrist", name = "Emissary Cuffs", sources = { [14]=3294 }, bind = "BoP", rareNpc = "Dark Iron Ambassador" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Grubbis",
            journalEncounterID = 419,
            dungeonEncounterID = 379,
            soloTip            = "This is a very long escort-style encounter. If you don't need anything off him, you can {skip} this boss.",
            achievements       = {
            },
            loot = {
                { id = 9445, slot = "Hands", name = "Grubbis Paws", sources = { [14]=3286 } },
                { id = 151080, slot = "Head", name = "Grubbis' Protective Pail", sources = { [14]=89287 } },
                { id = 151078, slot = "Legs", name = "Shabby Trogg Britches", sources = { [14]=89285 } },
                { id = 151079, slot = "Waist", name = "Chomper-Hide Belt", sources = { [14]=89286 } },
            },
        },
        {
            index              = 2,
            name               = "Viscous Fallout",
            journalEncounterID = 420,
            dungeonEncounterID = 378,
            achievements       = {
            },
            loot = {
                { id = 151082, slot = "Chest", name = "Lead Apron", sources = { [14]=89292 } },
                { id = 9454, slot = "Feet", name = "Acidic Walkers", sources = { [14]=3293 } },
                { id = 151083, slot = "Feet", name = "Hazmat Galoshes", sources = { [14]=89289 } },
                { id = 151081, slot = "Head", name = "Gnomish Rebreather", sources = { [14]=89288 } },
                { id = 9452, slot = "Two-Hand", name = "Hydrocane", sources = { [14]=3291 } },
                { id = 9453, slot = "Weapon", name = "Toxic Revenger", sources = { [14]=3292 } },
            },
        },
        {
            index              = 3,
            name               = "Electrocutioner 6000",
            journalEncounterID = 421,
            dungeonEncounterID = 380,
            achievements       = {
            },
            loot = {
                { id = 9446, slot = "Weapon", name = "Electrocutioner Leg", sources = { [14]=3287 } },
                { id = 9448, slot = "Wrist", name = "Spidertank Oilrag", sources = { [14]=3288 } },
            },
        },
        {
            index              = 4,
            name               = "Crowd Pummeler 9-60",
            journalEncounterID = 418,
            dungeonEncounterID = 381,
            achievements       = {
            },
            loot = {
                { id = 132558, slot = "Feet", name = "Bot Operator's Treads", sources = { [14]=76393 } },
                { id = 9450, slot = "Feet", name = "Gnomebot Operating Boots", sources = { [14]=3290 } },
                { id = 151085, slot = "Head", name = "Glitchbot Helm", sources = { [14]=89291 } },
                { id = 9449, slot = "Two-Hand", name = "Manual Crowd Pummeler", sources = { [14]=3289 } },
                { id = 151084, slot = "Waist", name = "Grease-Smudged Sash", sources = { [14]=89290 } },
            },
        },
        {
            index              = 5,
            name               = "Mekgineer Thermaplugg",
            journalEncounterID = 422,
            dungeonEncounterID = 382,
            achievements       = {
            },
            loot = {
                { id = 9492, slot = "Head", name = "Electromagnetic Gigaflux Reactivator", sources = { [14]=3322 } },
                { id = 9458, slot = "Off-hand", name = "Thermaplugg's Central Core", sources = { [14]=3297 } },
                { id = 9459, slot = "Two-Hand", name = "Thermaplugg's Left Arm", sources = { [14]=3298 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {

        -- 1. Grubbis (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            optional  = true,
            title     = "Grubbis",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 226 },
                    kind    = "path",
                    note    = "After zoning in, follow the southeast path to ^Grubbis^. Talk to ^Blastmaster Emi Shortfuse^ to start the encounter. You can {skip} if you want.",
                    minNote = "Southeast path to Grubbis",
                    points  = {
                        { 0.630, 0.329 },
                        { 0.578, 0.414 },
                        { 0.587, 0.441 },
                        { 0.589, 0.551 },
                        { 0.564, 0.601 },
                        { 0.645, 0.713 },
                        { 0.717, 0.706 },
                        { 0.754, 0.684 },
                    },
                },
                {
                    -- Noteless: takes its travel text from the path segment
                    -- above, the Razorfen Downs gong shape.
                    when        = { mapID = 226 },
                    kind        = "poi",
                    mapLabel    = "Talk to Blastmaster",
                    mapLabelPos = "above",
                    points      = {
                        { 0.825, 0.654 },
                    },
                },
            },
        },

        -- 2. Viscous Fallout (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Viscous Fallout",
            requires  = { },
            segments  = {
                {
                    when         = { mapID = 226 },
                    kind         = "path",
                    note         = "After killing ^Grubbis^, backtrack to the center ring and jump down below to engage ^Viscous Fallout^. Use the provided slow fall item if you need to.",
                    minNote      = "Jump below for Viscous Fallout",
                    skipWhenBoss = 1,
                    skipNote     = "Jump down to the lower middle section of the map to reach ^Viscous Fallout^. You can collect more parachutes in the small box by the ledge.",
                    skipMinNote  = "Jump down to Viscous Fallout",
                    points       = {
                        { 0.754, 0.687 },
                        { 0.705, 0.710 },
                        { 0.642, 0.711 },
                        { 0.603, 0.667 },
                        { 0.530, 0.557 },
                    },
                    skipPoints   = {
                        { 0.630, 0.332 },
                        { 0.577, 0.414 },
                        { 0.536, 0.453 },
                    },
                },
            },
        },

        -- 3. Electrocutioner 6000 (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Electrocutioner 6000",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 227 },
                    kind    = "path",
                    note    = "After defeating ^Viscous Fallout^, exit to the west and follow the path until you reach ^Electrocutioner 6000^.",
                    minNote = "West to Electrocutioner 6000",
                    points  = {
                        { 0.667, 0.453 },
                        { 0.582, 0.461 },
                        { 0.547, 0.495 },
                        { 0.541, 0.635 },
                        { 0.500, 0.686 },
                        { 0.365, 0.684 },
                        { 0.352, 0.581 },
                        { 0.286, 0.509 },
                        { 0.205, 0.501 },
                        { 0.150, 0.562 },
                        { 0.117, 0.638 },
                        { 0.210, 0.666 },
                    },
                },
            },
        },

        -- 4. Crowd Pummeler 9-60 (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Crowd Pummeler 9-60",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 227 },
                    kind        = "poi",
                    note        = "After killing ^Electrocutioner 6000^, slow fall into the area below.",
                    minNote     = "Slow fall into the area below",
                    mapLabel    = "Slowfall down",
                    mapLabelPos = "above",
                    points      = {
                        { 0.239, 0.761 },
                    },
                },
                {
                    when    = { mapID = 228 },
                    kind    = "path",
                    note    = "After landing in the ^Launch Bay^, take the southeast exit and follow the path until you reach ^Crowd Pummeler 9-60^.",
                    minNote = "Southeast to Crowd Pummeler 9-60",
                    points  = {
                        { 0.326, 0.385 },
                        { 0.385, 0.501 },
                        { 0.334, 0.558 },
                        { 0.380, 0.641 },
                        { 0.357, 0.856 },
                        { 0.402, 0.881 },
                    },
                },
            },
        },

        -- 5. Mekgineer Thermaplugg (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Mekgineer Thermaplugg",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 228 },
                    kind    = "path",
                    note    = "After defeating ^Crowd Pummeler 9-60^, follow the path counter-clockwise until you reach the elevator. Take it down into the ^Engineering Labs^.",
                    minNote = "Take elevator down",
                    points  = {
                        { 0.461, 0.891 },
                        { 0.491, 0.895 },
                        { 0.511, 0.886 },
                        { 0.516, 0.843 },
                        { 0.523, 0.783 },
                        { 0.529, 0.674 },
                        { 0.501, 0.701 },
                    },
                },
                {
                    when    = { mapID = 229 },
                    kind    = "path",
                    note    = "After you reach the bottom of the elevator, follow the western path all the way to ^Mekgineer Thermaplugg^.",
                    minNote = "West to Thermaplugg",
                    points  = {
                        { 0.644, 0.853 },
                        { 0.609, 0.885 },
                        { 0.563, 0.795 },
                        { 0.548, 0.790 },
                        { 0.512, 0.819 },
                        { 0.489, 0.807 },
                        { 0.433, 0.689 },
                        { 0.268, 0.634 },
                        { 0.306, 0.340 },
                    },
                },
            },
        },

    },
}
