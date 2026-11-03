-------------------------------------------------------------------------------
-- RetroRuns Data -- Vault of the Wardens
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1493  |  journalInstanceID: 707
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[707] = {
    kind              = "dungeon",
    instanceID        = 1493,
    journalInstanceID = 707,
    name              = "Vault of the Wardens",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "7.0.3",
    timewalking       = true,
    routedIn          = "3.5.0",

    entrance = {
        mapID = 630,
        x     = 0.4829,
        y     = 0.8010,
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
        { id = 10707, name = "A Specter, Illuminated", meta = true, soloable = "yes" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Tirathon Saltheril",
            journalEncounterID = 1467,
            dungeonEncounterID = 1815,
            achievements       = {
            },
            loot = {
                { id = 134390, slot = "Chest", name = "Mardum Chain Vest", sources = { [14]=77644, [15]=77644, [16]=77644 } },
                { id = 134369, slot = "Feet", name = "Felbat Leather Boots", sources = { [14]=77630, [15]=77630, [16]=77630 } },
                { id = 137517, slot = "Feet", name = "Striders of Furious Flight", sources = { [14]=79094, [15]=80168, [16]=79094 } },
                { id = 137509, slot = "Hands", name = "Glaivemaster's Studded Grips", sources = { [14]=79086, [15]=80107, [16]=79086 } },
                { id = 137502, slot = "Head", name = "Hood of Indignation", sources = { [14]=79079, [15]=80047, [16]=79079 } },
                { id = 137524, slot = "Shoulder", name = "Mortar Guard Shoulderplates", sources = { [14]=79101, [15]=79988, [16]=79101 } },
                { id = 134398, slot = "Wrist", name = "Netherwhisper Wristguard", sources = { [14]=77652, [15]=77652, [16]=77652 } },
                { id = 134362, slot = "Wrist", name = "Portalguard Wristguard", sources = { [14]=77626, [15]=77626, [16]=77626 } },
            },
        },
        {
            index              = 2,
            name               = "Inquisitor Tormentorum",
            journalEncounterID = 1695,
            dungeonEncounterID = 1850,
            achievements       = {
            },
            loot = {
                { id = 137530, slot = "Back", name = "Drape of Vile Misfortune", sources = { [14]=79107, [15]=80819, [16]=79107 } },
                { id = 137525, slot = "Hands", name = "Blood-Spattered Gauntlets", sources = { [14]=79102, [15]=79989, [16]=79102 } },
                { id = 137511, slot = "Head", name = "Hood of the Blind Executioner", sources = { [14]=79088, [15]=80109, [16]=79088 } },
                { id = 137518, slot = "Legs", name = "Leggings of Biting Links", sources = { [14]=79095, [15]=80169, [16]=79095 } },
                { id = 137503, slot = "Shoulder", name = "Amice of Cruel Laughter", sources = { [14]=79080, [15]=80048, [16]=79080 } },
            },
        },
        {
            index              = 3,
            name               = "Ash'golm",
            journalEncounterID = 1468,
            dungeonEncounterID = 1816,
            aliases            = { "Ash'Golm" },
            scenarioCriteriaID = 29370,
            achievements       = {
            },
            loot = {
                { id = 137504, slot = "Chest", name = "Flameheart Vestment", sources = { [14]=79081, [15]=80049, [16]=79081 } },
                { id = 137519, slot = "Hands", name = "Lavabreaker Gauntlets", sources = { [14]=79096, [15]=80170, [16]=79096 } },
                { id = 137526, slot = "Head", name = "Crown of Ash", sources = { [14]=79103, [15]=79990, [16]=79103 } },
                { id = 137505, slot = "Legs", name = "Leggings of the Third Degree", sources = { [14]=79082, [15]=80050, [16]=79082 } },
                { id = 137510, slot = "Shoulder", name = "Charskin Mantle", sources = { [14]=79087, [15]=80108, [16]=79087 } },
                { id = 137523, slot = "Waist", name = "Magmacrusher Girdle", sources = { [14]=79100, [15]=79987, [16]=79100 } },
                { id = 137520, slot = "Waist", name = "Permafrost Waistband", sources = { [14]=79097, [15]=80171, [16]=79097 } },
                { id = 137512, slot = "Wrist", name = "Flame Juggler's Armbands", sources = { [14]=79089, [15]=80110, [16]=79089 } },
            },
        },
        {
            index              = 4,
            name               = "Glazer",
            journalEncounterID = 1469,
            dungeonEncounterID = 1817,
            achievements       = {
            },
            loot = {
                { id = 137527, slot = "Chest", name = "Polished Jade Chestguard", sources = { [14]=79104, [15]=79991, [16]=79104 } },
                { id = 137506, slot = "Hands", name = "Gloves of Unseen Evil", sources = { [14]=79083, [15]=80051, [16]=79083 } },
                { id = 137516, slot = "Head", name = "Collar of Blindsight", sources = { [14]=79093, [15]=80167, [16]=79093 } },
                { id = 137513, slot = "Waist", name = "Girdle of Lidless Sight", sources = { [14]=79090, [15]=80111, [16]=79090 } },
            },
        },
        {
            index              = 5,
            name               = "Cordana Felsong",
            journalEncounterID = 1470,
            dungeonEncounterID = 1818,
            scenarioCriteriaID = 34462,
            achievements       = {
                { id = 10680, name = "Who's Afraid of the Dark?", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 137531, slot = "Back", name = "Cloak of Enthralling Darkness", sources = { [14]=79108, [15]=80820, [16]=79108 } },
                { id = 137514, slot = "Chest", name = "Chestguard of Insidious Desire", sources = { [14]=79091, [15]=80112, [16]=79091 } },
                { id = 134386, slot = "Feet", name = "Mardum Chain Boots", sources = { [14]=77640, [15]=77640, [16]=77640 } },
                { id = 137529, slot = "Feet", name = "Pathfinders of Dark Omens", sources = { [14]=79106, [15]=79993, [16]=79106 } },
                { id = 137508, slot = "Feet", name = "Shadewalker Footwraps", sources = { [14]=79085, [15]=80053, [16]=79085 } },
                { id = 134371, slot = "Hands", name = "Felbat Leather Gloves", sources = { [14]=77632, [15]=77632, [16]=77632 } },
                { id = 134356, slot = "Hands", name = "Portalguard Gauntlets", sources = { [14]=77620, [15]=77620, [16]=77620 } },
                { id = 134392, slot = "Head", name = "Netherwhisper Hood", sources = { [14]=77646, [15]=77646, [16]=77646 } },
                { id = 137528, slot = "Legs", name = "Legguards of Illusory Burdens", sources = { [14]=79105, [15]=79992, [16]=79105 } },
                { id = 137515, slot = "Legs", name = "Warden's Martial Greaves", sources = { [14]=79092, [15]=80113, [16]=79092 } },
                { id = 137521, slot = "Shoulder", name = "Shoulderguards of Shunned Duty", sources = { [14]=79098, [15]=80172, [16]=79098 } },
                { id = 137507, slot = "Waist", name = "Waistband of Spiritual Doom", sources = { [14]=79084, [15]=80052, [16]=79084 } },
                { id = 137522, slot = "Wrist", name = "Bracers of Twisted Revelation", sources = { [14]=79099, [15]=80173, [16]=79099 } },
            },
        },
    },

    exitNote    = "After the dialog, talk to ^Drelanim Whisperwind^ to exit the instance.",
    minExitNote = "Talk to Drelanim to exit",

    routing = {
        -- 1. Tirathon Saltheril (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Tirathon Saltheril",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 710 },
                    kind    = "path",
                    note    = "After zoning in, follow the path west all the way to ^Tirathon Saltheril^. The boss will activate after the dialog completes.",
                    minNote = "West to Tirathon",
                    points  = {
                        { 0.664, 0.774 },
                        { 0.607, 0.774 },
                        { 0.603, 0.729 },
                        { 0.572, 0.702 },
                        { 0.433, 0.702 },
                        { 0.399, 0.727 },
                        { 0.354, 0.777 },
                        { 0.243, 0.777 },
                        { 0.243, 0.605 },
                    },
                },
            },
        },
        -- 2. Inquisitor Tormentorum (boss 2), on the floor below.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Inquisitor Tormentorum",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 710 },
                    kind    = "path",
                    note    = "After killing ^Tirathon Saltheril^, continue north and take down ^Foul Mother^ to open the locked door and ride the elevator down.",
                    minNote = "North to ride elevator down",
                    points  = {
                        { 0.245, 0.509 },
                        { 0.296, 0.446 },
                        { 0.294, 0.328 },
                        { 0.245, 0.293 },
                        { 0.244, 0.242 },
                    },
                },
                {
                    -- Noteless, so the leg above keeps the pane.
                    when            = { mapID = 710 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Ride elevator down",
                    mapLabelPos     = "above",
                    points          = {
                        { 0.243, 0.123 },
                    },
                },
                {
                    when    = { mapID = 711 },
                    kind    = "path",
                    note    = "After you ride the elevator down, you will find ^Inquisitor Tormentorum^ to your west.",
                    minNote = "Inquisitor to west after elevator ride",
                    points  = {
                        { 0.437, 0.483 },
                        { 0.372, 0.484 },
                    },
                },
            },
        },
        -- 3. Ash'golm (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Ash'golm",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 711 },
                    kind    = "path",
                    note    = "After defeating ^Inquisitor Tormentorum^, go south, killing ^Dreadlord Mendacius^ to open the locked door. Continue through the door to reach ^Ash'golm^.",
                    minNote = "South to Ash'golm",
                    points  = {
                        { 0.468, 0.571 },
                        { 0.468, 0.758 },
                    },
                },
            },
        },
        -- 4. Glazer (boss 4).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Glazer",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 711 },
                    kind    = "path",
                    note    = "After killing ^Ash'golm^, take the path to the east to reach ^Glazer^.",
                    minNote = "East to Glazer",
                    points  = {
                        { 0.469, 0.735 },
                        { 0.469, 0.635 },
                        { 0.494, 0.635 },
                        { 0.572, 0.522 },
                        { 0.571, 0.480 },
                        { 0.661, 0.483 },
                    },
                },
            },
        },
        -- 5. Cordana Felsong (boss 5), on the lowest floor.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Cordana Felsong",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 711 },
                    kind    = "path",
                    note    = "After killing ^Glazer^, go all the way west and take the elevator down.",
                    minNote = "West to ride elevator down",
                    points  = {
                        { 0.637, 0.482 },
                        { 0.366, 0.483 },
                    },
                },
                {
                    -- Noteless, so the leg above keeps the pane.
                    when            = { mapID = 711 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Take elevator down",
                    mapLabelPos     = "above",
                    points          = {
                        { 0.325, 0.484 },
                    },
                },
                {
                    when    = { mapID = 712 },
                    kind    = "path",
                    note    = "When you reach the bottom of the elevator, grab the ^Glowing Sentry^ and head south to reach ^Cordana Felsong^.",
                    minNote = "Pick up Glowing Sentry and south to Cordana",
                    points  = {
                        { 0.529, 0.235 },
                        { 0.549, 0.257 },
                        { 0.552, 0.279 },
                        { 0.534, 0.299 },
                        { 0.503, 0.315 },
                        { 0.507, 0.377 },
                        { 0.511, 0.427 },
                        { 0.501, 0.461 },
                        { 0.502, 0.734 },
                    },
                },
            },
        },
    },
}
