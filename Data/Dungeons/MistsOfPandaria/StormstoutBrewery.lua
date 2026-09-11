-------------------------------------------------------------------------------
-- RetroRuns Data -- Stormstout Brewery
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 961  |  journalInstanceID: 302
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[302] = {
    kind              = "dungeon",
    instanceID        = 961,
    journalInstanceID = 302,
    name              = "Stormstout Brewery",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",
    timewalking       = true,

    entrance = {
        mapID = 376,
        x     = 0.3612,
        y     = 0.6940,
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
            name               = "Ook-Ook",
            journalEncounterID = 668,
            -- Criterion prose reads "Ook-ook" and spells the name differently.
            scenarioCriteriaID = 19236,
            achievements       = {
                { id = 6089, name = "Keep Rollin' Rollin' Rollin'", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 143957, slot = "Chest", name = "Nimbletoe Chestguard", sources = { [14]=84292, [15]=84292 } },
                { id = 143989, slot = "Feet", name = "Barreldodger Boots", sources = { [14]=84324, [15]=84324 } },
                { id = 144084, slot = "Weapon", name = "Ook's Hozen Slicer", sources = { [14]=84390, [15]=84390 } },
                { id = 144087, slot = "Wrist", name = "Bracers of Displaced Air", sources = { [14]=84393, [15]=84393 } },
            },
        },
        {
            index              = 2,
            name               = "Hoptallus",
            journalEncounterID = 669,
            achievements       = {
            },
            loot = {
                { id = 144121, slot = "Back", name = "Cloak of Hidden Flasks", sources = { [14]=84421, [15]=84421 } },
                { id = 143975, slot = "Legs", name = "Hopping Mad Leggings", sources = { [14]=84310, [15]=84310 } },
                { id = 144092, slot = "Off-hand", name = "Bottle of Potent Potables", sources = { [14]=84398, [15]=84398 } },
                { id = 144120, slot = "Waist", name = "Belt of Brazen Inebriation", sources = { [14]=84420, [15]=84420 } },
                { id = 144088, slot = "Wrist", name = "Bubble-Breaker Bracers", sources = { [14]=84394, [15]=84394 } },
            },
        },
        {
            index              = 3,
            name               = "Yan-Zhu the Uncasked",
            journalEncounterID = 670,
            achievements       = {
                { id = 6715, name = "Polyformic Acid Science", meta = true, soloable = "yes" },
                { id = 6400, name = "How Did He Get Up There?", meta = true, soloable = "yes" },
                { id = 6402, name = "Ling-Ting's Herbal Journey", meta = true, soloable = "yes" },
                { id = 6420, name = "Hopocalypse Now!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 143958, slot = "Chest", name = "Uncasked Chestguard", sources = { [14]=84293, [15]=84293 } },
                { id = 143976, slot = "Legs", name = "Sudsy Legplates", sources = { [14]=84311, [15]=84311 } },
                { id = 144089, slot = "Ranged", name = "Yan-Zhu's Pressure Valve", sources = { [14]=84395, [15]=84395 } },
                { id = 143969, slot = "Shoulder", name = "Fizzy Spaulders", sources = { [14]=84304, [15]=84304 } },
                { id = 144124, slot = "Two-Hand", name = "Wort Stirring Rod", sources = { [14]=84422, [15]=84422 } },
                { id = 144082, slot = "Waist", name = "Fermenting Belt", sources = { [14]=84388, [15]=84388 } },
                { id = 144085, slot = "Weapon", name = "Gao's Keg Tapper", sources = { [14]=84391, [15]=84391 } },
                { id = 144217, slot = "Weapon", name = "Inelava, Spirit of Inebriation", sources = { [14]=84485, [15]=84485 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    -- Always-on map markers, shown regardless of the current step.
    pois = {
        -- Auntie Stormstout, general goods.
        { mapID = 439, poiKind = "vendor", mapLabel = "Vendor NPC",
          mapLabelPos = "below",
          points = { { 0.770, 0.353 } } },
    },

    routing = {
        -- 1. Ook-Ook (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Ook-Ook",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 439 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path through several rooms. Kill monkeys on the way, as you will need the counter to hit 40 to spawn the boss.",
                    minNote = "Kill monkeys along path",
                    points  = {
                        { 0.790, 0.401 },
                        { 0.514, 0.511 },
                        { 0.512, 0.565 },
                        { 0.477, 0.615 },
                        { 0.443, 0.653 },
                        { 0.344, 0.692 },
                        { 0.322, 0.837 },
                        { 0.236, 0.875 },
                        { 0.208, 0.724 },
                        { 0.229, 0.632 },
                        { 0.304, 0.598 },
                    },
                },
                {
                    when    = { mapID = 440 },
                    kind    = "poi",
                    noMarker = true,
                    note    = "Once you reach the large room with the monkeys, kill monkeys until the counter reaches 40/40 to spawn ^Ook-Ook^.",
                    minNote = "Kill monkeys to spawn Ook-Ook",
                    points  = {
                        { 0.377, 0.560 },
                    },
                },
            },
        },
        -- 2. Hoptallus (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Hoptallus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 440 },
                    kind    = "path",
                    note    = "After defeating ^Ook-Ook^, exit the room to the southeast. Follow the linear path up some ramps to reach the next area.",
                    minNote = "Southeast exit to next area",
                    points  = {
                        { 0.635, 0.558 },
                        { 0.737, 0.700 },
                        { 0.748, 0.759 },
                        { 0.809, 0.818 },
                        { 0.867, 0.794 },
                        { 0.897, 0.718 },
                        { 0.880, 0.634 },
                        { 0.815, 0.583 },
                        { 0.791, 0.594 },
                    },
                },
                {
                    when    = { mapID = 441 },
                    kind    = "path",
                    note    = "Continue following the path through the waves of ^Hoplings^ until you reach ^Hoptallus^. Clear the trash to spawn the boss.",
                    minNote = "Follow path to Hoptallus",
                    points  = {
                        { 0.320, 0.791 },
                        { 0.226, 0.727 },
                        { 0.210, 0.613 },
                        { 0.280, 0.498 },
                        { 0.360, 0.465 },
                    },
                },
            },
        },
        -- 3. Yan-Zhu the Uncasked (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Yan-Zhu the Uncasked",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 441 },
                    kind    = "path",
                    note    = "After killing ^Hoptallus^, go down the ramp into the building. Continue following the path until you reach ^The Tasting Room^.",
                    minNote = "Path to The Tasting Room",
                    points  = {
                        { 0.398, 0.396 },
                        { 0.385, 0.333 },
                        { 0.408, 0.275 },
                        { 0.538, 0.224 },
                        { 0.591, 0.295 },
                        { 0.598, 0.339 },
                        { 0.700, 0.422 },
                        { 0.731, 0.569 },
                        { 0.887, 0.508 },
                        { 0.909, 0.459 },
                        { 0.885, 0.328 },
                        { 0.846, 0.295 },
                        { 0.737, 0.341 },
                    },
                },
                {
                    when    = { mapID = 442 },
                    kind    = "path",
                    note    = "Once you reach ^The Tasting Room^, kill the two large elementals in the middle of the room to start the encounter with ^Yan-Zhu the Uncasked^.",
                    minNote = "Kill elementals to start Yan-Zhu",
                    points  = {
                        { 0.572, 0.307 },
                        { 0.510, 0.478 },
                    },
                },
            },
        },
    },
}
