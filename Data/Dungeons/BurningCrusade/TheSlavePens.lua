-------------------------------------------------------------------------------
-- RetroRuns Data -- The Slave Pens
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 547  |  journalInstanceID: 260
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[260] = {
    kind              = "dungeon",
    instanceID        = 547,
    journalInstanceID = 260,
    name              = "The Slave Pens",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.1.1",

    entrance = {
        mapID = 102,
        x     = 0.4893,
        y     = 0.3549,
    },

    bosses = {
        {
            index              = 1,
            name               = "Mennu the Betrayer",
            journalEncounterID = 570,
            achievements       = {
            },
            loot = {
                { id = 24357, slot = "Chest", name = "Vest of Living Lightning", sources = { [14]=9514, [15]=9514 } },
                { id = 27545, slot = "Legs", name = "Mennu's Scaled Leggings", sources = { [14]=11972, [15]=11972 } },
                { id = 24359, slot = "Legs", name = "Princely Reign Leggings", sources = { [14]=9515, [15]=9515 } },
                { id = 27541, slot = "Waist", name = "Archery Belt of the Broken", sources = { [14]=11969, [15]=11969 } },
                { id = 27542, slot = "Waist", name = "Cord of Belief", sources = { [14]=11970, [15]=11970 } },
                { id = 24360, slot = "Waist", name = "Tracker's Belt", sources = { [14]=9516, [15]=9516 } },
                { id = 24361, slot = "Weapon", name = "Spellfire Longsword", sources = { [14]=9517, [15]=9517 } },
                { id = 27543, slot = "Weapon", name = "Starlight Dagger", sources = { [14]=11971, [15]=11971 } },
                { id = 24356, slot = "Weapon", name = "Wastewalker Shiv", sources = { [14]=9513, [15]=9513 } },
            },
        },
        {
            index              = 2,
            name               = "Rokmar the Crackler",
            journalEncounterID = 571,
            achievements       = {
            },
            loot = {
                { id = 24379, slot = "Back", name = "Bogstrok Scale Cloak", sources = { [14]=9524, [15]=9524 } },
                { id = 27550, slot = "Back", name = "Ironscale War Cloak", sources = { [14]=11976, [15]=11976 } },
                { id = 27549, slot = "Feet", name = "Wavefury Boots", sources = { [14]=11975, [15]=11975 } },
                { id = 24380, slot = "Ranged", name = "Calming Spore Reed", sources = { [14]=9525, [15]=9525 } },
                { id = 24381, slot = "Ranged", name = "Coilfang Needler", sources = { [14]=9526, [15]=9526 } },
                { id = 27547, slot = "Waist", name = "Coldwhisper Cord", sources = { [14]=11973, [15]=11973 } },
                { id = 27548, slot = "Waist", name = "Girdle of Many Blessings", sources = { [14]=11974, [15]=11974 } },
                { id = 28124, slot = "Waist", name = "Liar's Cord", sources = { [14]=12252, [15]=12252 } },
                { id = 24378, slot = "Weapon", name = "Coilfang Hammer of Renewal", sources = { [14]=9523, [15]=9523 } },
            },
        },
        {
            index              = 3,
            name               = "Quagmirran",
            journalEncounterID = 572,
            achievements       = {
            },
            loot = {
                { id = 24362, slot = "Back", name = "Spore-Soaked Vaneer", sources = { [14]=9518, [15]=9518 } },
                { id = 28337, slot = "Chest", name = "Breastplate of Righteous Fury", sources = { [14]=12406, [15]=12406 } },
                { id = 24363, slot = "Chest", name = "Unscarred Breastplate", sources = { [14]=9519, [15]=9519 } },
                { id = 29242, slot = "Feet", name = "Boots of Blasphemy", sources = { [14]=13037, [15]=13037 } },
                { id = 24365, slot = "Hands", name = "Deft Handguards", sources = { [14]=9521, [15]=9521 } },
                { id = 24364, slot = "Legs", name = "Azureplate Greaves", sources = { [14]=9520, [15]=9520 } },
                { id = 27800, slot = "Legs", name = "Earthsoul Britches", sources = { [14]=12075, [15]=12075 } },
                { id = 30538, slot = "Legs", name = "Midnight Legguards", sources = { [14]=13810, [15]=13810 } },
                { id = 27714, slot = "Off-hand", name = "Swamplight Lantern", sources = { [14]=12010, [15]=12010 } },
                { id = 27796, slot = "Shoulder", name = "Mana-Etched Spaulders", sources = { [14]=12071, [15]=12071 } },
                { id = 27713, slot = "Shoulder", name = "Pauldrons of Desolation", sources = { [14]=12009, [15]=12009 } },
                { id = 32078, slot = "Shoulder", name = "Pauldrons of Wild Magic", sources = { [14]=14753, [15]=14753 } },
                { id = 24366, slot = "Shoulder", name = "Scorpid-Sting Mantle", sources = { [14]=9522, [15]=9522 } },
                { id = 27672, slot = "Waist", name = "Girdle of the Immovable", sources = { [14]=11995, [15]=11995 } },
                { id = 27742, slot = "Waist", name = "Mage-Fury Girdle", sources = { [14]=12032, [15]=12032 } },
                { id = 27741, slot = "Weapon", name = "Bleeding Hollow Warhammer", sources = { [14]=12031, [15]=12031 } },
                { id = 27673, slot = "Weapon", name = "Phosphorescent Blade", sources = { [14]=11996, [15]=11996 } },
                { id = 27712, slot = "Wrist", name = "Shackles of Quagmirran", sources = { [14]=12008, [15]=12008 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Mennu the Betrayer (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Mennu the Betrayer",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 265 },
                    kind    = "path",
                    note    = "After zoning in, follow the path to the east and you will eventually find ^Mennu the Betrayer^ patrolling up and down a long ramp.",
                    minNote = "East to Mennu the Betrayer",
                    points  = {
                        { 0.178, 0.132 },
                        { 0.163, 0.187 },
                        { 0.154, 0.282 },
                        { 0.111, 0.386 },
                        { 0.062, 0.473 },
                        { 0.082, 0.536 },
                        { 0.203, 0.500 },
                        { 0.353, 0.477 },
                        { 0.368, 0.399 },
                        { 0.404, 0.358 },
                        { 0.435, 0.179 },
                        { 0.450, 0.189 },
                        { 0.466, 0.237 },
                    },
                },
            },
        },
        -- 2. Rokmar the Crackler (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Rokmar the Crackler",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 265 },
                    kind    = "path",
                    note    = "After killing ^Mennu the Betrayer^, work your way up a series of ramps and jump into the water. Climb out and take a sharp left, then follow the path ahead until you reach ^Rokmar the Crackler^.",
                    minNote = "Path to Rokmar",
                    points  = {
                        { 0.488, 0.230 },
                        { 0.490, 0.131 },
                        { 0.501, 0.139 },
                        { 0.516, 0.192 },
                        { 0.527, 0.269 },
                        { 0.527, 0.339 },
                        { 0.516, 0.394 },
                        { 0.490, 0.442 },
                        { 0.490, 0.540 },
                        { 0.505, 0.539 },
                        { 0.517, 0.569 },
                        { 0.524, 0.604 },
                        { 0.527, 0.645 },
                        { 0.490, 0.696 },
                        { 0.490, 0.725 },
                        { 0.543, 0.773 },
                        { 0.574, 0.618 },
                        { 0.604, 0.565 },
                        { 0.581, 0.439 },
                    },
                },
            },
        },
        -- 3. Quagmirran (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Quagmirran",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 265 },
                    kind    = "path",
                    note    = "After defeating ^Rokmar the Crackler^, follow the path to the east until you reach ^Quagmirran^ in the water.",
                    minNote = "Path east to Quagmirran",
                    points  = {
                        { 0.582, 0.453 },
                        { 0.604, 0.504 },
                        { 0.633, 0.498 },
                        { 0.685, 0.458 },
                        { 0.709, 0.474 },
                        { 0.810, 0.514 },
                        { 0.874, 0.480 },
                        { 0.909, 0.502 },
                        { 0.909, 0.545 },
                        { 0.838, 0.730 },
                    },
                },
            },
        },
    },
}
