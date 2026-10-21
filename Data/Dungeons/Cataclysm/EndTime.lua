-------------------------------------------------------------------------------
-- RetroRuns Data -- End Time
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.3.0  |  instanceID: 938  |  journalInstanceID: 184
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[184] = {
    kind              = "dungeon",
    instanceID        = 938,
    journalInstanceID = 184,
    name              = "End Time",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 15, 24 },
    patch             = "4.3.0",
    routedIn          = "3.3.7",
    timewalking       = true,
    spawnChoice = {
        1, 2, 3, 4, label = "Echoes", picks = 2,
        -- The Time Transit Device's one destination, by gossip option id. A
        -- shrine has one option as the first echo and another as the second.
        gossip = {
            [40857] = 3,   -- Ruby Dragonshrine, first echo
            [40859] = 2,   -- Azure Dragonshrine, first echo
            [40860] = 1,   -- Obsidian Dragonshrine, first echo
            [40862] = 4,   -- Emerald Dragonshrine, second echo
            [40863] = 2,   -- Azure Dragonshrine, second echo
        },
        -- Each echo's shrine. The device option that names a shrine, or
        -- arriving there, names its echo.
        shrines = {
            ["Obsidian Dragonshrine"] = 1,
            ["Azure Dragonshrine"]    = 2,
            ["Ruby Dragonshrine"]     = 3,
            ["Emerald Dragonshrine"]  = 4,
        },
    },

    entrance = {
        mapID = 75,
        x     = 0.5736,
        y     = 0.2808,
    },

    trashLoot = {
        { id = 76154, slot = "Chest", name = "Breastplate of Despair", sources = { [15]=38412 }, bind = "BoE", twSource = 76730 },
        { id = 76156, slot = "Wrist", name = "Bindings of the End Times", sources = { [15]=38414 }, bind = "BoE", twSource = 76732 },
    },

    bosses = {
        {
            index              = 1,
            name               = "Echo of Baine",
            journalEncounterID = 340,
            dungeonEncounterID = 1881,
            -- The Heroic lockout can mark an echo defeated on another echo's kill.
            lockoutUnreliable  = true,
            achievements       = {
            },
            loot = {
                { id = 72801, slot = "Chest", name = "Breastplate of Sorrow", sources = { [15]=37281 }, twSource = 76697 },
                { id = 133418, slot = "Feet", name = "Boots of the Forked Road", sources = { [24]=76727 } },
                { id = 72799, slot = "Feet", name = "Dead End Boots", sources = { [15]=37279 }, twSource = 76695 },
                { id = 133414, slot = "Hands", name = "Archivist's Gloves", sources = { [24]=76723 } },
                { id = 72800, slot = "Hands", name = "Gauntlets of Temporal Interference", sources = { [15]=37280 }, twSource = 76696 },
                { id = 72805, slot = "Hands", name = "Gloves of the Hollow", sources = { [15]=37285 }, twSource = 76701 },
                { id = 133416, slot = "Hands", name = "Time Strand Gauntlets", sources = { [24]=76725 } },
                { id = 72806, slot = "Head", name = "Echoing Headguard", sources = { [15]=37286 }, twSource = 76702 },
                { id = 72815, slot = "Legs", name = "Bloodhoof Legguards", sources = { [15]=37295 }, twSource = 76711 },
                { id = 72802, slot = "Legs", name = "Time Traveler's Leggings", sources = { [15]=37282 }, twSource = 76698 },
                { id = 133415, slot = "Ranged", name = "Crescent Wand", sources = { [24]=76724 } },
                { id = 72814, slot = "Two-Hand", name = "Axe of the Tauren Chieftains", sources = { [15]=37294 }, twSource = 76710 },
                { id = 72798, slot = "Waist", name = "Cord of Lost Hope", sources = { [15]=37278 }, twSource = 76694 },
                { id = 72803, slot = "Waist", name = "Girdle of Lost Heroes", sources = { [15]=37283 }, twSource = 76699 },
                { id = 157606, slot = "Waist", name = "Time-Desiccated Girdle", sources = { [15]=93792 }, twSource = 76733 },
                { id = 72807, slot = "Waist", name = "Waistguard of Lost Time", sources = { [15]=37287 }, twSource = 76703 },
                { id = 72804, slot = "Weapon", name = "Dragonshrine Scepter", sources = { [15]=37284 }, twSource = 76700 },
            },
        },
        {
            index              = 2,
            name               = "Echo of Jaina",
            journalEncounterID = 285,
            dungeonEncounterID = 1883,
            -- The Heroic lockout can mark an echo defeated on another echo's kill.
            lockoutUnreliable  = true,
            achievements       = {
            },
            loot = {
                { id = 72801, slot = "Chest", name = "Breastplate of Sorrow", sources = { [15]=37281 }, twSource = 76697 },
                { id = 133418, slot = "Feet", name = "Boots of the Forked Road", sources = { [24]=76727 } },
                { id = 72799, slot = "Feet", name = "Dead End Boots", sources = { [15]=37279 }, twSource = 76695 },
                { id = 133414, slot = "Hands", name = "Archivist's Gloves", sources = { [24]=76723 } },
                { id = 72800, slot = "Hands", name = "Gauntlets of Temporal Interference", sources = { [15]=37280 }, twSource = 76696 },
                { id = 72805, slot = "Hands", name = "Gloves of the Hollow", sources = { [15]=37285 }, twSource = 76701 },
                { id = 133416, slot = "Hands", name = "Time Strand Gauntlets", sources = { [24]=76725 } },
                { id = 72806, slot = "Head", name = "Echoing Headguard", sources = { [15]=37286 }, twSource = 76702 },
                { id = 72802, slot = "Legs", name = "Time Traveler's Leggings", sources = { [15]=37282 }, twSource = 76698 },
                { id = 72809, slot = "Off-hand", name = "Ward of Incantations", sources = { [15]=37289 }, twSource = 76705 },
                { id = 133415, slot = "Ranged", name = "Crescent Wand", sources = { [24]=76724 } },
                { id = 72808, slot = "Two-Hand", name = "Jaina's Staff", sources = { [15]=37288 }, twSource = 76704 },
                { id = 72798, slot = "Waist", name = "Cord of Lost Hope", sources = { [15]=37278 }, twSource = 76694 },
                { id = 72803, slot = "Waist", name = "Girdle of Lost Heroes", sources = { [15]=37283 }, twSource = 76699 },
                { id = 157606, slot = "Waist", name = "Time-Desiccated Girdle", sources = { [15]=93792 }, twSource = 76733 },
                { id = 72807, slot = "Waist", name = "Waistguard of Lost Time", sources = { [15]=37287 }, twSource = 76703 },
                { id = 72804, slot = "Weapon", name = "Dragonshrine Scepter", sources = { [15]=37284 }, twSource = 76700 },
            },
        },
        {
            index              = 3,
            name               = "Echo of Sylvanas",
            journalEncounterID = 323,
            dungeonEncounterID = 1882,
            -- The Heroic lockout can mark an echo defeated on another echo's kill.
            lockoutUnreliable  = true,
            achievements       = {
                { id = 6130, name = "Severed Ties", soloable = "yes" },
            },
            loot = {
                { id = 72811, slot = "Back", name = "Cloak of the Banshee Queen", sources = { [15]=37291 }, twSource = 76707 },
                { id = 72801, slot = "Chest", name = "Breastplate of Sorrow", sources = { [15]=37281 }, twSource = 76697 },
                { id = 133418, slot = "Feet", name = "Boots of the Forked Road", sources = { [24]=76727 } },
                { id = 72799, slot = "Feet", name = "Dead End Boots", sources = { [15]=37279 }, twSource = 76695 },
                { id = 133414, slot = "Hands", name = "Archivist's Gloves", sources = { [24]=76723 } },
                { id = 72800, slot = "Hands", name = "Gauntlets of Temporal Interference", sources = { [15]=37280 }, twSource = 76696 },
                { id = 72805, slot = "Hands", name = "Gloves of the Hollow", sources = { [15]=37285 }, twSource = 76701 },
                { id = 133416, slot = "Hands", name = "Time Strand Gauntlets", sources = { [24]=76725 } },
                { id = 72806, slot = "Head", name = "Echoing Headguard", sources = { [15]=37286 }, twSource = 76702 },
                { id = 72802, slot = "Legs", name = "Time Traveler's Leggings", sources = { [15]=37282 }, twSource = 76698 },
                { id = 133415, slot = "Ranged", name = "Crescent Wand", sources = { [24]=76724 } },
                { id = 72810, slot = "Ranged", name = "Windrunner's Bow", sources = { [15]=37290 }, twSource = 76706 },
                { id = 72798, slot = "Waist", name = "Cord of Lost Hope", sources = { [15]=37278 }, twSource = 76694 },
                { id = 72803, slot = "Waist", name = "Girdle of Lost Heroes", sources = { [15]=37283 }, twSource = 76699 },
                { id = 157606, slot = "Waist", name = "Time-Desiccated Girdle", sources = { [15]=93792 }, twSource = 76733 },
                { id = 72807, slot = "Waist", name = "Waistguard of Lost Time", sources = { [15]=37287 }, twSource = 76703 },
                { id = 72804, slot = "Weapon", name = "Dragonshrine Scepter", sources = { [15]=37284 }, twSource = 76700 },
            },
        },
        {
            index              = 4,
            name               = "Echo of Tyrande",
            journalEncounterID = 283,
            dungeonEncounterID = 1884,
            -- The Heroic lockout can mark an echo defeated on another echo's kill.
            lockoutUnreliable  = true,
            achievements       = {
                { id = 5995, name = "Moon Guard", soloable = "yes" },
            },
            loot = {
                { id = 72801, slot = "Chest", name = "Breastplate of Sorrow", sources = { [15]=37281 }, twSource = 76697 },
                { id = 72813, slot = "Chest", name = "Whisperwind Robes", sources = { [15]=37293 }, twSource = 76709 },
                { id = 133418, slot = "Feet", name = "Boots of the Forked Road", sources = { [24]=76727 } },
                { id = 72799, slot = "Feet", name = "Dead End Boots", sources = { [15]=37279 }, twSource = 76695 },
                { id = 133414, slot = "Hands", name = "Archivist's Gloves", sources = { [24]=76723 } },
                { id = 72800, slot = "Hands", name = "Gauntlets of Temporal Interference", sources = { [15]=37280 }, twSource = 76696 },
                { id = 72805, slot = "Hands", name = "Gloves of the Hollow", sources = { [15]=37285 }, twSource = 76701 },
                { id = 133416, slot = "Hands", name = "Time Strand Gauntlets", sources = { [24]=76725 } },
                { id = 72806, slot = "Head", name = "Echoing Headguard", sources = { [15]=37286 }, twSource = 76702 },
                { id = 72802, slot = "Legs", name = "Time Traveler's Leggings", sources = { [15]=37282 }, twSource = 76698 },
                { id = 133415, slot = "Ranged", name = "Crescent Wand", sources = { [24]=76724 } },
                { id = 72798, slot = "Waist", name = "Cord of Lost Hope", sources = { [15]=37278 }, twSource = 76694 },
                { id = 72803, slot = "Waist", name = "Girdle of Lost Heroes", sources = { [15]=37283 }, twSource = 76699 },
                { id = 157606, slot = "Waist", name = "Time-Desiccated Girdle", sources = { [15]=93792 }, twSource = 76733 },
                { id = 72807, slot = "Waist", name = "Waistguard of Lost Time", sources = { [15]=37287 }, twSource = 76703 },
                { id = 72812, slot = "Weapon", name = "Crescent Moon", sources = { [15]=37292 }, twSource = 76708 },
                { id = 72804, slot = "Weapon", name = "Dragonshrine Scepter", sources = { [15]=37284 }, twSource = 76700 },
            },
        },
        {
            index              = 5,
            name               = "Murozond",
            journalEncounterID = 289,
            dungeonEncounterID = 1271,
            achievements       = {
            },
            loot = {
                { id = 72818, slot = "Chest", name = "Breastplate of Tarnished Bronze", sources = { [15]=37298 }, twSource = 76714 },
                { id = 72826, slot = "Chest", name = "Robes of Fate", sources = { [15]=37306 }, twSource = 76722 },
                { id = 72824, slot = "Chest", name = "Time Twisted Tunic", sources = { [15]=37304 }, twSource = 76720 },
                { id = 72819, slot = "Feet", name = "Chrono Boots", sources = { [15]=37299 }, twSource = 76715 },
                { id = 133419, slot = "Hands", name = "Time Twister's Gauntlets", sources = { [24]=76728 } },
                { id = 133421, slot = "Head", name = "Cowl of Destiny", sources = { [24]=76729 } },
                { id = 72820, slot = "Head", name = "Crown of Epochs", sources = { [15]=37300 }, twSource = 76716 },
                { id = 72823, slot = "Head", name = "Timeway Headgear", sources = { [15]=37303 }, twSource = 76719 },
                { id = 72816, slot = "Legs", name = "Distortion Greaves", sources = { [15]=37296 }, twSource = 76712 },
                { id = 72817, slot = "Legs", name = "Time Altered Legguards", sources = { [15]=37297 }, twSource = 76713 },
                { id = 133417, slot = "Ranged", name = "Bronze Blaster", sources = { [24]=76726 } },
                { id = 72825, slot = "Shoulder", name = "Mantle of Time", sources = { [15]=37305 }, twSource = 76721 },
                { id = 72821, slot = "Shoulder", name = "Temporal Pauldrons", sources = { [15]=37301 }, twSource = 76717 },
                { id = 72822, slot = "Weapon", name = "Jagged Edge of Time", sources = { [15]=37302 }, twSource = 76718 },
            },
        },
    },

    exitNote    = "The teleporter to the southwest will send you back to the entrance.",
    minExitNote = "Southwest to portal",

    routing = {
        -- 1-4. Two of the four echoes, one after the other, at whichever
        -- shrines the device sends you to.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Echo of Baine",
            requires  = { },
            drawCurrentSegOnly = true,
            skipToLocation     = true,
            segments  = {
                {
                    when     = { mapID = 401, subZone = "Entryway of Time" },
                    kind     = "poi",
                    note     = "After zoning in, interact with the ^Time Transit Device^ and select {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.794, 0.464 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Ruby Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    mapLabelPos = "above",
                    points   = {
                        { 0.396, 0.403 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Emerald Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.657, 0.794 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Azure Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.512, 0.787 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Obsidian Dragonshrine" },
                    kind     = "poi",
                    note     = "After arriving in ^Obsidian Dragonshrine^, go west to ^Echo of Baine^.",
                    minNote  = "West to Baine",
                    mapLabel = "Baine",
                    poiIcon  = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
                    poiSize  = 26,
                    hintBoss = 1,
                    points   = {
                        { 0.231, 0.132 },
                    },
                },
            },
        },
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Echo of Jaina",
            requires  = { },
            drawCurrentSegOnly = true,
            skipToLocation     = true,
            segments  = {
                {
                    when     = { mapID = 401, subZone = "Entryway of Time" },
                    kind     = "poi",
                    note     = "After zoning in, interact with the ^Time Transit Device^ and select {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.794, 0.464 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Ruby Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    mapLabelPos = "above",
                    points   = {
                        { 0.396, 0.403 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Emerald Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.657, 0.794 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Obsidian Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.301, 0.163 },
                    },
                },
                {
                    when    = { mapID = 401, subZone = "Azure Dragonshrine" },
                    kind    = "path",
                    note    = "After arriving in ^Azure Dragonshrine^, collect all 16 ^Fragments of Jaina's Staff^ around the area.",
                    minNote = "Collect 16 staff fragments",
                    points  = { },
                },
                {
                    when        = { mapID = 401, subZone = "Azure Dragonshrine" },
                    kind        = "poi",
                    triggeredBy = { dialog = { npc = "Echo of Jaina", match = "defend this shrine with my life" } },
                    note        = "With the staff fragments collected, go kill ^Echo of Jaina^.",
                    minNote     = "Fragments done, kill Jaina",
                    mapLabel    = "Jaina",
                    poiIcon     = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
                    poiSize     = 26,
                    hintBoss    = 2,
                    points      = {
                        { 0.529, 0.748 },
                    },
                },
            },
        },
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Echo of Sylvanas",
            requires  = { },
            drawCurrentSegOnly = true,
            skipToLocation     = true,
            segments  = {
                {
                    when     = { mapID = 401, subZone = "Entryway of Time" },
                    kind     = "poi",
                    note     = "After zoning in, interact with the ^Time Transit Device^ and select {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.794, 0.464 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Emerald Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.657, 0.794 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Azure Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.512, 0.787 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Obsidian Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.301, 0.163 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Ruby Dragonshrine" },
                    kind     = "poi",
                    note     = "After arriving in ^Ruby Dragonshrine^, go east all the way to ^Echo of Sylvanas^.",
                    minNote  = "East to Sylvanas",
                    mapLabel = "Sylvanas",
                    mapLabelPos = "above",
                    poiIcon  = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
                    poiSize  = 26,
                    hintBoss = 3,
                    points   = {
                        { 0.419, 0.389 },
                    },
                },
            },
        },
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Echo of Tyrande",
            requires  = { },
            drawCurrentSegOnly = true,
            skipToLocation     = true,
            segments  = {
                {
                    when     = { mapID = 401, subZone = "Entryway of Time" },
                    kind     = "poi",
                    note     = "After zoning in, interact with the ^Time Transit Device^ and select {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.794, 0.464 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Ruby Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    mapLabelPos = "above",
                    points   = {
                        { 0.396, 0.403 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Azure Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.512, 0.787 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Obsidian Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose {option}.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.301, 0.163 },
                    },
                },
                {
                    when    = { mapID = 401, subZone = "Emerald Dragonshrine" },
                    kind    = "path",
                    note    = "After arriving in ^Emerald Dragonshrine^, start killing trash. A series of 5 moonlight pools need to be eliminated. You don't need to stand in them anymore, but you need to kill trash near them.",
                    minNote = "Kill trash near moonlight pools",
                    points  = { },
                },
                {
                    when        = { mapID = 401, subZone = "Emerald Dragonshrine" },
                    kind        = "poi",
                    triggeredBy = { dialog = { npc = "Echo of Tyrande", match = "A pool of dark moonlight appears nearby" } },
                    note        = "After eliminating the fifth moonlight pool, ^Echo of Tyrande^ will activate.",
                    minNote     = "Moonlight done, kill Tyrande",
                    mapLabel    = "Tyrande",
                    poiIcon     = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
                    poiSize     = 26,
                    hintBoss    = 4,
                    points      = {
                        { 0.662, 0.844 },
                    },
                },
            },
        },
        -- 5. Murozond (boss 5), from the shrine where the second echo fell.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Murozond",
            requires  = { },
            drawCurrentSegOnly = true,
            skipToLocation     = true,
            segments  = {
                {
                    when     = { mapID = 401, subZone = "Ruby Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose ^Bronze Dragonshrine^.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    mapLabelPos = "above",
                    points   = {
                        { 0.396, 0.403 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Emerald Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose ^Bronze Dragonshrine^.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.657, 0.794 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Azure Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose ^Bronze Dragonshrine^.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.512, 0.787 },
                    },
                },
                {
                    when     = { mapID = 401, subZone = "Obsidian Dragonshrine" },
                    kind     = "poi",
                    note     = "Click the nearby ^Time Transit Device^ and choose ^Bronze Dragonshrine^.",
                    minNote  = "Use teleporter",
                    mapLabel = "Teleporter",
                    points   = {
                        { 0.301, 0.163 },
                    },
                },
                {
                    when    = { mapID = 401, subZone = "Bronze Dragonshrine" },
                    kind    = "path",
                    note    = "After landing in ^Bronze Dragonshrine^, move ahead to engage ^Murozond^. Clear trash to activate the encounter.",
                    minNote = "Clear trash for Murozond",
                    points  = { },
                },
            },
        },
    },
}
