-------------------------------------------------------------------------------
-- RetroRuns Data -- Throne of the Tides
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 643  |  journalInstanceID: 65
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[65] = {
    kind              = "dungeon",
    instanceID        = 643,
    journalInstanceID = 65,
    name              = "Throne of the Tides",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "4.0.3",
    timewalking       = true,
    routedIn          = "3.3.1",

    entrance = {
        mapID = 204,
        x     = 0.6961,
        y     = 0.2488,
    },

    trashLoot = {
        { id = 55260, slot = "Legs", name = "Alpheus Legguards", sources = { [14]=26888, [15]=26888 }, bind = "BoE", twSource = 76584 },
    },

    bosses = {
        {
            index              = 1,
            name               = "Lady Naz'jar",
            journalEncounterID = 101,
            dungeonEncounterID = 1045,
            achievements       = {
            },
            loot = {
                { id = 56267, slot = "Back", name = "Periwinkle Cloak", sources = { [14]=27623, [15]=27623 }, twSource = 76568 },
                { id = 56268, slot = "Hands", name = "Wrasse Handwraps", sources = { [14]=27624, [15]=27624 }, twSource = 76569 },
                { id = 56269, slot = "Head", name = "Aurelian Miter", sources = { [14]=27625, [15]=27625 }, twSource = 76570 },
                { id = 157587, slot = "Head", name = "Old One Eye's Cowl", sources = { [14]=93779, [15]=93779 }, twSource = 76682 },
                { id = 133367, slot = "Off-hand", name = "Barnacled Shell Buckler", sources = { [24]=76687 } },
                { id = 56266, slot = "Weapon", name = "Lightning Whelk Axe", sources = { [14]=27622, [15]=27622 }, twSource = 76567 },
            },
        },
        {
            index              = 2,
            name               = "Commander Ulthok, the Festering Prince",
            journalEncounterID = 102,
            dungeonEncounterID = 1044,
            aliases            = { "Commander Ulthok" },
            scenarioCriteriaID = 24799,
            achievements       = {
            },
            loot = {
                { id = 56275, slot = "Back", name = "Eagle Ray Cloak", sources = { [14]=27630, [15]=27630 }, twSource = 76575 },
                { id = 56274, slot = "Chest", name = "Chromis Chestpiece", sources = { [14]=27629, [15]=27629 }, twSource = 76574 },
                { id = 56273, slot = "Shoulder", name = "Caridean Epaulets", sources = { [14]=27628, [15]=27628 }, twSource = 76573 },
                { id = 56272, slot = "Shoulder", name = "Harp Shell Pauldrons", sources = { [14]=27627, [15]=27627 }, twSource = 76572 },
                { id = 56271, slot = "Two-Hand", name = "Cerith Spire Staff", sources = { [14]=27626, [15]=27626 }, twSource = 76571 },
            },
        },
        {
            index              = 3,
            name               = "Mindbender Ghur'sha",
            journalEncounterID = 103,
            dungeonEncounterID = 1046,
            achievements       = {
            },
            loot = {
                { id = 56277, slot = "Feet", name = "Decapod Slippers", sources = { [14]=27631, [15]=27631 }, twSource = 76576 },
                { id = 56278, slot = "Head", name = "Anomuran Helm", sources = { [14]=27632, [15]=27632 }, twSource = 76577 },
                { id = 133200, slot = "Off-hand", name = "Bioluminescent Lamp", sources = { [24]=76582 } },
                { id = 157586, slot = "Waist", name = "Stonespeaker's Spare Cinch", sources = { [14]=93778, [15]=93778 }, twSource = 76683 },
            },
        },
        {
            index              = 4,
            name               = "Ozumat",
            journalEncounterID = 104,
            dungeonEncounterID = 1047,
            achievements       = {
            },
            loot = {
                { id = 56291, slot = "Chest", name = "Abalone Plate Armor", sources = { [14]=27638, [15]=27638 }, twSource = 76583 },
                { id = 56281, slot = "Chest", name = "Wentletrap Vest", sources = { [14]=27633, [15]=27633 }, twSource = 76578 },
                { id = 56286, slot = "Hands", name = "Mnemiopsis Gloves", sources = { [14]=27636, [15]=27636 }, twSource = 76581 },
                { id = 56283, slot = "Legs", name = "Triton Legplates", sources = { [14]=27634, [15]=27634 }, twSource = 76579 },
                { id = 56289, slot = "Off-hand", name = "Bioluminescent Lamp", sources = { [14]=27637, [15]=27637 } },
                { id = 56284, slot = "Two-Hand", name = "Whitefin Axe", sources = { [14]=27635, [15]=27635 }, twSource = 76580 },
                { id = 157589, slot = "Waist", name = "Salty Shell-Studded Girdle", sources = { [14]=93780, [15]=93780 }, twSource = 76688 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Lady Naz'jar (boss 1). The Bubble Generator lifts the player to
        -- the upper level.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Lady Naz'jar",
            requires  = { },
            segments  = {
                {
                    when          = { mapID = 322 },
                    kind          = "poi",
                    note          = "After zoning in, go straight ahead through the crossroads and click on the ^Bubble Generator^ to be lifted up a long underwater channel.",
                    minNote       = "Straight ahead to Bubble Generator",
                    mapLabel      = "Click Bubble Generator",
                    mapLabelPos   = "above",
                    mapLabelPulse = true,
                    points        = {
                        { 0.500, 0.340 },
                    },
                },
                {
                    when    = { mapID = 322 },
                    kind    = "path",
                    note    = "After zoning in, go straight ahead through the crossroads and click on the ^Bubble Generator^ to be lifted up a long underwater channel.",
                    minNote = "Straight ahead to Bubble Generator",
                    points  = {
                        { 0.501, 0.780 },
                        { 0.501, 0.367 },
                    },
                },
                {
                    when    = { mapID = 323 },
                    kind    = "path",
                    note    = "Continue ahead until you run into ^Lady Naz'jar^.",
                    minNote = "Ahead to Lady Naz'jar",
                    points  = {
                        { 0.505, 0.788 },
                        { 0.505, 0.254 },
                    },
                },
            },
        },

        -- 2. Commander Ulthok (boss 2). The Defense System's cutscene opens
        -- the note south to him.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Commander Ulthok",
            requires  = { },
            segments  = {
                {
                    when           = { mapID = 323 },
                    kind           = "poi",
                    note           = "After killing ^Lady Naz'jar^, click the ^Throne of the Tides Defense System^ at the exit door.",
                    minNote        = "Click the Defense System",
                    mapLabel       = "Click Defense System",
                    mapLabelPos    = "above",
                    completionCheck = true,
                    points         = {
                        { 0.512, 0.330 },
                    },
                },
                {
                    when         = { mapID = 323 },
                    kind         = "path",
                    note         = "After clicking the ^Throne of the Tides Defense System^, go south to engage ^Commander Ulthok^ in the previous room.",
                    minNote      = "South to Ulthok",
                    triggeredBy  = { cinematic = true },
                    drawWhenOpen = true,
                    points       = {
                        { 0.504, 0.256 },
                        { 0.506, 0.392 },
                    },
                },
            },
        },

        -- 3. Mindbender Ghur'sha (boss 3). Left out once his appearances are
        -- all collected; step 5 then takes the Bubble Generator straight to
        -- Ozumat.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Mindbender Ghur'sha",
            requires  = { },
            skipWhenCollected = true,
            segments  = {
                {
                    when          = { mapID = 323 },
                    kind          = "poi",
                    note          = "After defeating ^Commander Ulthok^, backtrack south and click on the ^Bubble Generator^ to be returned to the lower level.",
                    minNote       = "South to Bubble Generator",
                    mapLabel      = "Click Bubble Generator",
                    mapLabelPos   = "below",
                    mapLabelPulse = true,
                    points        = {
                        { 0.505, 0.801 },
                    },
                },
                {
                    when    = { mapID = 323 },
                    kind    = "path",
                    note    = "After defeating ^Commander Ulthok^, backtrack south and click on the ^Bubble Generator^ to be returned to the lower level.",
                    minNote = "South to Bubble Generator",
                    points  = {
                        { 0.506, 0.482 },
                        { 0.506, 0.770 },
                    },
                },
                {
                    when    = { mapID = 322 },
                    kind    = "path",
                    note    = "At the bottom, go east to reach ^Mindbender Ghur'sha^.",
                    minNote = "East to Mindbender",
                    points  = {
                        { 0.500, 0.355 },
                        { 0.501, 0.444 },
                        { 0.624, 0.441 },
                        { 0.655, 0.407 },
                        { 0.671, 0.348 },
                        { 0.675, 0.236 },
                    },
                },
            },
        },

        -- 4. Ozumat (boss 4), from Mindbender Ghur'sha. Opens only once he
        -- is dead; a run that left him out takes step 5.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Ozumat",
            requires  = { 3 },
            segments  = {
                {
                    when    = { mapID = 322 },
                    kind    = "path",
                    note    = "After killing ^Mindbender Ghur'sha^, backtrack and go all the way west to reach ^Ozumat^.",
                    minNote = "Backtrack west to Ozumat",
                    points  = {
                        { 0.673, 0.261 },
                        { 0.671, 0.341 },
                        { 0.653, 0.406 },
                        { 0.625, 0.446 },
                        { 0.427, 0.447 },
                        { 0.371, 0.436 },
                        { 0.338, 0.406 },
                        { 0.325, 0.341 },
                        { 0.325, 0.230 },
                    },
                },
            },
        },

        -- 5. Ozumat (boss 4), straight from Commander Ulthok when Mindbender
        -- Ghur'sha is left out.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 4,
            title     = "Ozumat",
            requires  = { },
            segments  = {
                {
                    when          = { mapID = 323 },
                    kind          = "poi",
                    note          = "After defeating ^Commander Ulthok^, backtrack south and click on the ^Bubble Generator^ to be returned to the lower level.",
                    minNote       = "South to Bubble Generator",
                    mapLabel      = "Click Bubble Generator",
                    mapLabelPos   = "below",
                    mapLabelPulse = true,
                    points        = {
                        { 0.505, 0.801 },
                    },
                },
                {
                    when    = { mapID = 323 },
                    kind    = "path",
                    note    = "After defeating ^Commander Ulthok^, backtrack south and click on the ^Bubble Generator^ to be returned to the lower level.",
                    minNote = "South to Bubble Generator",
                    points  = {
                        { 0.506, 0.482 },
                        { 0.506, 0.770 },
                    },
                },
                {
                    when    = { mapID = 322 },
                    kind    = "path",
                    note    = "At the bottom, go west to reach ^Ozumat^.",
                    minNote = "West to Ozumat",
                    points  = {
                        { 0.500, 0.394 },
                        { 0.500, 0.446 },
                        { 0.384, 0.443 },
                        { 0.339, 0.407 },
                        { 0.327, 0.356 },
                        { 0.325, 0.226 },
                    },
                },
            },
        },
    },
}
