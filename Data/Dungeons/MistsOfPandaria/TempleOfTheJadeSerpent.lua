-------------------------------------------------------------------------------
-- RetroRuns Data -- Temple of the Jade Serpent
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 960  |  journalInstanceID: 313
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[313] = {
    kind              = "dungeon",
    instanceID        = 960,
    journalInstanceID = 313,
    name              = "Temple of the Jade Serpent",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",
    timewalking       = true,

    entrance = {
        mapID = 371,
        x     = 0.5625,
        y     = 0.5790,
    },

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Wise Mari",
            journalEncounterID = 672,
            achievements       = {
                { id = 6460, name = "Hydrophobia", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144111, slot = "Back", name = "Wind-Soaked Drape", sources = { [14]=84416, [15]=84416 } },
                { id = 143960, slot = "Chest", name = "Riverbed Chestguard", sources = { [14]=84295, [15]=84295 } },
                { id = 143973, slot = "Feet", name = "Treads of Corrupted Water", sources = { [14]=84308, [15]=84308 } },
                { id = 144017, slot = "Head", name = "Waterburst Helm", sources = { [14]=84352, [15]=84352 } },
            },
        },
        {
            index              = 2,
            name               = "Lorewalker Stonestep",
            journalEncounterID = 664,
            achievements       = {
            },
            loot = {
                { id = 143974, slot = "Feet", name = "Stonestep Boots", sources = { [14]=84309, [15]=84309 } },
                { id = 143987, slot = "Legs", name = "Leggings of Whispered Dreams", sources = { [14]=84322, [15]=84322 } },
                { id = 144081, slot = "Waist", name = "Girdle of Endemic Anger", sources = { [14]=84387, [15]=84387 } },
                { id = 144083, slot = "Waist", name = "Sunheart Waistband", sources = { [14]=84389, [15]=84389 } },
            },
        },
        {
            index              = 3,
            name               = "Liu Flameheart",
            journalEncounterID = 658,
            achievements       = {
                { id = 6715, name = "Polyformic Acid Science", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144094, slot = "Back", name = "Cape of Entanglement", sources = { [14]=84400, [15]=84400 } },
                { id = 143988, slot = "Feet", name = "Flameheart Sandals", sources = { [14]=84323, [15]=84323 } },
                { id = 144090, slot = "Ranged", name = "Firebelcher Hand Cannon", sources = { [14]=84396, [15]=84396 } },
                { id = 143971, slot = "Shoulder", name = "Serpentstrike Shoulderpads", sources = { [14]=84306, [15]=84306 } },
            },
        },
        {
            index              = 4,
            name               = "Sha of Doubt",
            journalEncounterID = 335,
            achievements       = {
                { id = 6475, name = "Cleaning Up", meta = true, soloable = "yes" },
                { id = 6671, name = "Seeds of Doubt", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144115, slot = "Back", name = "Cloak of Failing Will", sources = { [14]=84417, [15]=84417 } },
                { id = 143959, slot = "Chest", name = "Chestguard of Despair", sources = { [14]=84294, [15]=84294 } },
                { id = 144091, slot = "Hands", name = "Hopecrusher Gauntlets", sources = { [14]=84397, [15]=84397 } },
                { id = 144118, slot = "Hands", name = "Paralyzing Gloves", sources = { [14]=84419, [15]=84419 } },
                { id = 143972, slot = "Shoulder", name = "Doubtridden Shoulderguards", sources = { [14]=84307, [15]=84307 } },
                { id = 143970, slot = "Shoulder", name = "Neverdare Shoulders", sources = { [14]=84305, [15]=84305 } },
                { id = 144093, slot = "Two-Hand", name = "Staff of Trembling Will", sources = { [14]=84399, [15]=84399 } },
                { id = 144116, slot = "Waist", name = "Binding of Broken Dreams", sources = { [14]=84418, [15]=84418 } },
                { id = 144086, slot = "Weapon", name = "Dubious Handaxe", sources = { [14]=84392, [15]=84392 } },
                { id = 144216, slot = "Weapon", name = "Je'lyu, Spirit of the Serpent", sources = { [14]=84484, [15]=84484 } },
            },
            specialLoot = {
                { id = 246846, kind = "decor", name = "Tome of Pandaren Wisdom", decorID = 2512 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Wise Mari (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Wise Mari",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 429 },
                    kind    = "path",
                    note    = "After zoning in, go left and follow the path to reach ^Wise Mari^.",
                    minNote = "Left path to Wise Mari",
                    points  = {
                        { 0.338, 0.458 },
                        { 0.371, 0.295 },
                        { 0.315, 0.263 },
                        { 0.338, 0.139 },
                        { 0.420, 0.177 },
                    },
                },
            },
        },
        -- 2. Liu Flameheart (boss 3)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 3,
            title     = "Liu Flameheart",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 429 },
                    kind    = "path",
                    note    = "After defeating ^Wise Mari^, continue on the path behind him until you reach ^Terrace of the Twin Dragons^. Clear trash to start the fight with ^Liu Flameheart^.",
                    minNote = "Clear trash for Liu Flameheart",
                    points  = {
                        { 0.485, 0.211 },
                        { 0.578, 0.254 },
                        { 0.600, 0.231 },
                        { 0.617, 0.236 },
                        { 0.627, 0.257 },
                        { 0.630, 0.285 },
                        { 0.660, 0.300 },
                        { 0.645, 0.342 },
                        { 0.625, 0.375 },
                        { 0.600, 0.388 },
                        { 0.563, 0.380 },
                        { 0.531, 0.365 },
                        { 0.516, 0.431 },
                        { 0.468, 0.486 },
                    },
                },
            },
        },
        -- 3. Lorewalker Stonestep (boss 2)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 2,
            title     = "Lorewalker Stonestep",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 429 },
                    kind    = "path",
                    note    = "After killing ^Liu Flameheart^, take the southeast exit and follow it around to reach ^Lorewalker Stonestep^. Kill the ^Corrupted Scroll^ to trigger the roleplay event which leads to the boss fight.",
                    minNote = "Southeast to Lorewalker Stonestep",
                    points  = {
                        { 0.468, 0.578 },
                        { 0.472, 0.637 },
                        { 0.455, 0.707 },
                        { 0.518, 0.750 },
                        { 0.537, 0.799 },
                        { 0.537, 0.879 },
                        { 0.504, 0.859 },
                        { 0.487, 0.891 },
                        { 0.459, 0.891 },
                        { 0.439, 0.829 },
                        { 0.290, 0.756 },
                    },
                },
            },
        },
        -- 4. Sha of Doubt (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Sha of Doubt",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 429 },
                    kind    = "path",
                    note    = "After defeating the ^Lorewalker Stonestep^ encounter, backtrack to ^Liu Flameheart^'s room and go east to find ^Sha of Doubt^.",
                    minNote = "Path to Sha of Doubt",
                    points  = {
                        { 0.324, 0.776 },
                        { 0.448, 0.834 },
                        { 0.472, 0.804 },
                        { 0.496, 0.818 },
                        { 0.508, 0.868 },
                        { 0.536, 0.880 },
                        { 0.539, 0.834 },
                        { 0.535, 0.792 },
                        { 0.526, 0.755 },
                        { 0.497, 0.727 },
                        { 0.455, 0.702 },
                        { 0.483, 0.572 },
                        { 0.539, 0.561 },
                        { 0.582, 0.580 },
                    },
                },
            },
        },
    },
}
