-------------------------------------------------------------------------------
-- RetroRuns Data -- Return to Karazhan
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.1.0  |  instanceID: 1651  |  journalInstanceID: 860
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[860] = {
    kind              = "dungeon",
    instanceID        = 1651,
    journalInstanceID = 860,
    name              = "Return to Karazhan",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 15, 16 },
    unsavedDifficulties = { 15 },
    patch             = "7.1.0",
    routedIn          = "3.5.4",

    -- One of the three Opera Hall plays runs each week; Barnes's opening
    -- lines name it.
    spawnChoice = {
        1, 2, 3, label = "Opera Hall",
        announce = {
            { member = 1, dialog = { npc = "Barnes", match = "ladies and gentlemen, to our" } },
            { member = 2, dialog = { npc = "Barnes", match = "Sentinel Hill" } },
            { member = 3, dialog = { npc = "Barnes", match = "skin deep" } },
        },
    },

    entrance = {
        mapID = 42,
        x     = 0.4637,
        y     = 0.7066,
    },

    -- Instance-wide achievements with no single boss; every boss lists them.
    raidAchievements = {
        { id = 11433, name = "Burn After Reading", soloable = "yes" },
    },

    pois = {
        -- Always on: the vendor in the Livery Stables.
        { mapID = 809, poiKind = "vendor", mapLabel = "Vendor NPC",
          mapLabelPos = "below",
          points = { { 0.422, 0.721 } } },
        -- Nightbane's Soul Fragments in click order, Mythic only, gone once
        -- he is dead or out of the run, and checked off as Medivh's Echo
        -- reaches each one's stack. The first appears once the Opera Hall
        -- ends, each later one once the one before it is clicked; the fifth
        -- drops from The Curator.
        { mapID = 812, poiKind = "quest", mapLabel = "Soul Fragment 1", availableDifficulties = { 16 },
          requires = { 1 }, summonFor = 11, summonOrder = 1,
          points = { { 0.260, 0.357 } } },
        { mapID = 812, poiKind = "quest", mapLabel = "Soul Fragment 2", availableDifficulties = { 16 },
          summonFor = 11, summonOrder = 2,
          points = { { 0.814, 0.217 } } },
        { mapID = 811, poiKind = "quest", mapLabel = "Soul Fragment 3", mapLabelPos = "above",
          availableDifficulties = { 16 }, summonFor = 11, summonOrder = 3,
          points = { { 0.220, 0.627 } } },
        { mapID = 809, poiKind = "quest", mapLabel = "Soul Fragment 4", availableDifficulties = { 16 },
          summonFor = 11, summonOrder = 4,
          points = { { 0.734, 0.206 } } },
    },

    bosses = {
        {
            index              = 1,
            name               = "Opera Hall: Wikket",
            journalEncounterID = 1820,
            dungeonEncounterID = 1957,
            aliases            = { "Opera Hall" },
            scenarioCriteriaID = 35483,
            achievements       = {
                { id = 11335, name = "Season Tickets", soloable = "kinda" },
            },
            loot = {
                { id = 142298, slot = "Feet", name = "Astonishingly Scarlet Slippers", sources = { [15]=83079, [16]=83079 } },
                { id = 142204, slot = "Feet", name = "Boots of False Promises", sources = { [15]=83068, [16]=83068 } },
                { id = 142299, slot = "Hands", name = "Horkin' Stuff-Lobbers", sources = { [15]=83080, [16]=83080 } },
                { id = 142205, slot = "Hands", name = "Jabber Grookin' Gauntlets", sources = { [15]=83069, [16]=83069 } },
                { id = 142296, slot = "Head", name = "Wikket Witch's Hat", sources = { [15]=83077, [16]=83077 } },
                { id = 142300, slot = "Legs", name = "Greaves of Miraculous Magnificence", sources = { [15]=83081, [16]=83081 } },
                { id = 142137, slot = "Waist", name = "Short Jibbet Waistguard", sources = { [15]=83047, [16]=83047 } },
                { id = 142198, slot = "Wrist", name = "Inordinately Wondrous Wristguards", sources = { [15]=83061, [16]=83061 } },
            },
        },
        {
            index              = 2,
            name               = "Opera Hall: Westfall Story",
            journalEncounterID = 1826,
            dungeonEncounterID = 1957,
            aliases            = { "Opera Hall" },
            achievements       = {
                { id = 11335, name = "Season Tickets", soloable = "kinda" },
            },
            loot = {
                { id = 142201, slot = "Shoulder", name = "Mantle of Conflicted Loyalties", sources = { [15]=83065, [16]=83065 } },
                { id = 142302, slot = "Wrist", name = "Armguards of Burning Passion", sources = { [15]=83083, [16]=83083 } },
                { id = 142146, slot = "Wrist", name = "Blackfin Wristband", sources = { [15]=83040, [16]=83040 } },
                { id = 142154, slot = "Wrist", name = "Bracelets of the Sorrowful Bride", sources = { [15]=83032, [16]=83032 } },
            },
        },
        {
            index              = 3,
            name               = "Opera Hall: Beautiful Beast",
            journalEncounterID = 1827,
            dungeonEncounterID = 1957,
            aliases            = { "Opera Hall" },
            achievements       = {
                { id = 11335, name = "Season Tickets", soloable = "kinda" },
            },
            loot = {
                { id = 142206, slot = "Back", name = "Cloak of Sweltering Flame", sources = { [15]=83070, [16]=83070 } },
                { id = 142304, slot = "Head", name = "Visage of Brutish Iron", sources = { [15]=83085, [16]=83085 } },
                { id = 142197, slot = "Legs", name = "Legguards of Imprisonment", sources = { [15]=83060, [16]=83060 } },
                { id = 142202, slot = "Legs", name = "Trousers of Royal Vanity", sources = { [15]=83066, [16]=83066 } },
                { id = 142196, slot = "Waist", name = "Cinch of Improbable Desire", sources = { [15]=83059, [16]=83059 } },
            },
        },
        {
            index              = 4,
            name               = "Maiden of Virtue",
            journalEncounterID = 1825,
            dungeonEncounterID = 1954,
            achievements       = {
            },
            loot = {
                { id = 142170, slot = "Back", name = "Drape of Shame", sources = { [15]=83057, [16]=83057 } },
                { id = 142139, slot = "Chest", name = "Vest of Wanton Deeds", sources = { [15]=83033, [16]=83033 } },
                { id = 142124, slot = "Feet", name = "Treads of the Depraved", sources = { [15]=83050, [16]=83050 } },
                { id = 142153, slot = "Waist", name = "Cord of the Penitent", sources = { [15]=83031, [16]=83031 } },
                { id = 142138, slot = "Wrist", name = "Confiscated Manacles", sources = { [15]=83048, [16]=83048 } },
            },
        },
        {
            index              = 5,
            name               = "Attumen the Huntsman",
            journalEncounterID = 1835,
            dungeonEncounterID = 1960,
            achievements       = {
            },
            loot = {
                { id = 142140, slot = "Feet", name = "Calliard's Galoshes", sources = { [15]=83034, [16]=83034 } },
                { id = 142148, slot = "Feet", name = "Wilderness Stalker's Softsoles", sources = { [15]=83026, [16]=83026 } },
                { id = 142126, slot = "Head", name = "Helm of Phantasmal Scars", sources = { [15]=83052, [16]=83052 } },
                { id = 142136, slot = "Shoulder", name = "Mantle of Hideous Trophies", sources = { [15]=83046, [16]=83046 } },
            },
            specialLoot = {
                { id = 142236, kind = "mount", name = "Midnight's Eternal Reins", mythicOnly = true },
            },
        },
        {
            index              = 6,
            name               = "Moroes",
            journalEncounterID = 1837,
            dungeonEncounterID = 1961,
            achievements       = {
                { id = 11338, name = "Dine and Bash", soloable = "yes" },
            },
            loot = {
                { id = 142123, slot = "Chest", name = "Breastplate of Obligation", sources = { [15]=83049, [16]=83049 } },
                { id = 142147, slot = "Chest", name = "Robes of Wicked Modesty", sources = { [15]=83025, [16]=83025 } },
                { id = 142134, slot = "Head", name = "Castellan's Blinders", sources = { [15]=83044, [16]=83044 } },
                { id = 142143, slot = "Legs", name = "Willbreaker Legguards", sources = { [15]=83037, [16]=83037 } },
            },
            specialLoot = {
                { id = 138797, kind = "illusion", name = "Illusion: Mongoose", sourceID = 2673 },
            },
        },
        {
            index              = 7,
            name               = "The Curator",
            journalEncounterID = 1836,
            dungeonEncounterID = 1964,
            achievements       = {
            },
            loot = {
                { id = 142141, slot = "Hands", name = "Custodian's Soothing Touch", sources = { [15]=83035, [16]=83035 } },
                { id = 142133, slot = "Hands", name = "Gauntlets of Confinement", sources = { [15]=83043, [16]=83043 } },
                { id = 142149, slot = "Hands", name = "Gloves of Arcane Confluence", sources = { [15]=83027, [16]=83027 } },
                { id = 142125, slot = "Hands", name = "Repurposed Golem Grips", sources = { [15]=83051, [16]=83051 } },
                { id = 142130, slot = "Wrist", name = "Bite-Marked Wristplates", sources = { [15]=83056, [16]=83056 } },
            },
        },
        {
            index              = 8,
            name               = "Shade of Medivh",
            journalEncounterID = 1817,
            dungeonEncounterID = 1965,
            achievements       = {
                { id = 11432, name = "Scared Straight", soloable = "no" },
            },
            loot = {
                { id = 142131, slot = "Chest", name = "Frozen-Link Chestguard", sources = { [15]=83041, [16]=83041 } },
                { id = 142152, slot = "Shoulder", name = "Shoulderpads of Chaotic Thought", sources = { [15]=83030, [16]=83030 } },
                { id = 142145, slot = "Waist", name = "Girdle of Ghostly Exclusion", sources = { [15]=83039, [16]=83039 } },
                { id = 142129, slot = "Waist", name = "Spellwarding Waistguard", sources = { [15]=83055, [16]=83055 } },
            },
            specialLoot = {
                { id = 138798, kind = "illusion", name = "Illusion: Sunfire", sourceID = 5865 },
            },
        },
        {
            index              = 9,
            name               = "Mana Devourer",
            journalEncounterID = 1818,
            dungeonEncounterID = 1959,
            achievements       = {
                { id = 11431, name = "The Rat Pack", soloable = "no" },
            },
            loot = {
                { id = 142215, slot = "Back", name = "Wine-Stained Mantle", sources = { [15]=83072, [16]=83072 } },
                { id = 142150, slot = "Head", name = "Hood of Uncanny Perspectives", sources = { [15]=83028, [16]=83028 } },
                { id = 142135, slot = "Legs", name = "Legguards of Countless Hours", sources = { [15]=83045, [16]=83045 } },
                { id = 142128, slot = "Shoulder", name = "Pauldrons of Encroaching Limits", sources = { [15]=83054, [16]=83054 } },
                { id = 142144, slot = "Shoulder", name = "Unending Horizon Spaulders", sources = { [15]=83038, [16]=83038 } },
            },
        },
        {
            index              = 10,
            name               = "Viz'aduum the Watcher",
            journalEncounterID = 1838,
            dungeonEncounterID = 2017,
            achievements       = {
            },
            loot = {
                { id = 142132, slot = "Feet", name = "Doomstride Footguards", sources = { [15]=83042, [16]=83042 } },
                { id = 142142, slot = "Head", name = "Unbound Reality Mask", sources = { [15]=83036, [16]=83036 } },
                { id = 142151, slot = "Legs", name = "Leggings of Countless Worlds", sources = { [15]=83029, [16]=83029 } },
                { id = 142127, slot = "Legs", name = "Tassets of Perpetual Despair", sources = { [15]=83053, [16]=83053 } },
            },
            specialLoot = {
                { id = 246865, kind = "decor", name = "Tome of Reliquary Insights", decorID = 2531 },
            },
        },
        {
            -- Not a journal boss. Mythic only, summoned at Medivh's image on
            -- Master's Terrace once all five Soul Fragments are clicked in time.
            index              = 11,
            name               = "Nightbane",
            npcID              = 114895,
            dungeonEncounterID = 2031,
            availableDifficulties = { 16 },
            -- The first door opens an 8-minute window to click the first
            -- Soul Fragment; Medivh's image calls both ends. The click puts
            -- Medivh's Echo on the player, and its time takes over. The fifth
            -- fragment swaps it for Medivh's Presence, the time left to talk
            -- to the image. Either buff running out ends the attempt.
            summonWindow = {
                seconds   = 480,
                aura      = 229074,
                readyAura = 229077,
                opens     = { dialog = { npc = "Image of Medivh", match = "The strange chill of a dark presence" } },
                fails     = { dialog = { npc = "Image of Medivh", match = "The air grows slightly warmer" } },
                summoned  = { dialog = { npc = "Image of Arcanagos", match = "An ancient being awakens" } },
            },
            achievements       = {
                { id = 11430, name = "One Night in Karazhan", soloable = "yes" },
            },
            loot = {
                { id = 142303, slot = "Chest", name = "Chestplate of Impenetrable Darkness", sources = { [16]=83084 }, mythicOnly = true },
                { id = 142203, slot = "Chest", name = "Harness of Smoldering Betrayal", sources = { [16]=83067 }, mythicOnly = true },
                { id = 142301, slot = "Chest", name = "Hauberk of Warped Intuition", sources = { [16]=83082 }, mythicOnly = true },
                { id = 142297, slot = "Chest", name = "Robes of the Ancient Chronicle", sources = { [16]=83078 }, mythicOnly = true },
            },
            specialLoot = {
                { id = 142552, kind = "mount", name = "Smoldering Ember Wyrm", mythicOnly = true },
            },
        },
    },

    exitNote    = "The portal leads to a nearby ship, which has a portal to Dalaran. If you jump off that ship, you will respawn in the Karazhan library.",
    minExitNote = "Portal leads to Dalaran",

    routing = {
        -- 1. Opera Hall (bosses 1-3), whichever play is on this week.
        {
            step      = 1,
            priority  = 1,
            bossIndex = { 1, 2, 3 },
            title     = "Opera Hall",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 814 },
                    kind    = "path",
                    note    = "After zoning in, go right to climb some stairs. In ^The Opera Hall^, take another right and go down the ramp at the map exit labeled ^Opera Hall Balcony^.",
                    minNote = "Right to Opera Hall Balcony, Down Ramp",
                    points  = {
                        { 0.615, 0.638 },
                        { 0.572, 0.617 },
                        { 0.516, 0.508 },
                        { 0.515, 0.467 },
                        { 0.537, 0.441 },
                        { 0.526, 0.426 },
                        { 0.488, 0.465 },
                        { 0.421, 0.335 },
                        { 0.439, 0.291 },
                        { 0.442, 0.225 },
                        { 0.412, 0.166 },
                        { 0.392, 0.150 },
                        { 0.398, 0.140 },
                    },
                },
                {
                    when    = { mapID = 813 },
                    kind    = "path",
                    note    = "At the bottom of the ramp, go left and work your way around the middle balcony. Go down the ramp at the end of the path and find ^Barnes^ on the stage. Talk to him to start the ^Opera Hall^ encounter.",
                    minNote = "Left path, talk to Barnes for Opera",
                    points  = {
                        { 0.639, 0.296 },
                        { 0.752, 0.399 },
                        { 0.788, 0.565 },
                        { 0.752, 0.734 },
                        { 0.633, 0.833 },
                        { 0.454, 0.844 },
                    },
                },
                {
                    when    = { mapID = 812 },
                    kind    = "path",
                    points  = {
                        { 0.213, 0.500 },
                        { 0.192, 0.474 },
                        { 0.194, 0.440 },
                        { 0.209, 0.389 },
                    },
                },
                {
                    when        = { mapID = 812 },
                    kind        = "poi",
                    poiKind     = "talk",
                    mapLabel    = "Talk to Barnes",
                    mapLabelPos = "right",
                    points      = {
                        { 0.218, 0.344 },
                    },
                },
            },
        },

        -- 2. Maiden of Virtue (boss 4).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 4,
            title     = "Maiden of Virtue",
            requires  = { },
            segments  = {
                -- With Nightbane: the first Soul Fragment, in the audience.
                -- Without him this leg reads as the way to Maiden.
                {
                    when    = { mapID = 812 },
                    kind    = "path",
                    note    = "After defeating the ^Opera Hall^, exit the stage to the north. Follow the linear path to the first ^Soul Fragment^ in the audience across from the stage.",
                    minNote = "Path to first Soul Fragment in audience",
                    points  = {
                        { 0.210, 0.262 },
                        { 0.121, 0.257 },
                        { 0.110, 0.422 },
                        { 0.203, 0.430 },
                        { 0.261, 0.189 },
                        { 0.234, 0.187 },
                        { 0.232, 0.229 },
                        { 0.296, 0.235 },
                        { 0.280, 0.331 },
                    },
                    skipWhenBoss = 11,
                    skipNote     = "After defeating the ^Opera Hall^, exit the stage to the north. Follow the linear path behind the stage and down the ramp below the stage. From the bottom floor of the ^Opera Hall^, continue on the path to eventually reach ^Maiden of Virtue^.",
                    skipMinNote  = "Follow path to Maiden",
                    skipPoints   = {
                        { 0.211, 0.264 },
                        { 0.121, 0.256 },
                        { 0.113, 0.418 },
                        { 0.207, 0.430 },
                        { 0.244, 0.254 },
                        { 0.254, 0.235 },
                        { 0.257, 0.189 },
                        { 0.237, 0.187 },
                        { 0.236, 0.224 },
                        { 0.326, 0.242 },
                        { 0.379, 0.279 },
                        { 0.404, 0.341 },
                        { 0.405, 0.389 },
                        { 0.525, 0.404 },
                        { 0.564, 0.370 },
                        { 0.569, 0.307 },
                        { 0.657, 0.325 },
                        { 0.712, 0.359 },
                        { 0.811, 0.470 },
                    },
                },
                -- The second Soul Fragment, once the first's Medivh's Echo lands.
                {
                    when    = { mapID = 812 },
                    kind    = "path",
                    triggeredBy = { aura = 229074 },
                    drawWhenOpen = true,
                    note    = "From the first ^Soul Fragment^, continue on the path out of the ^Opera Hall^ toward ^The Guest Chambers^. Before reaching ^Maiden of Virtue^, turn north into the bedroom to find the second ^Soul Fragment^.",
                    minNote = "Path to second Soul Fragment in bedroom",
                    points  = {
                        { 0.285, 0.361 },
                        { 0.520, 0.405 },
                        { 0.565, 0.363 },
                        { 0.567, 0.306 },
                        { 0.650, 0.324 },
                        { 0.717, 0.367 },
                        { 0.747, 0.399 },
                        { 0.810, 0.267 },
                    },
                    -- Lost after the first fragment: straight on to Maiden.
                    skipWhenBoss = 11,
                    skipNote     = "Continue on the path out of the ^Opera Hall^ toward ^The Guest Chambers^ to reach ^Maiden of Virtue^.",
                    skipMinNote  = "Follow path to Maiden",
                    skipPoints   = {
                        { 0.285, 0.361 },
                        { 0.520, 0.405 },
                        { 0.565, 0.363 },
                        { 0.567, 0.306 },
                        { 0.650, 0.324 },
                        { 0.717, 0.367 },
                        { 0.747, 0.399 },
                        { 0.802, 0.459 },
                    },
                },
                -- On to Maiden once the second fragment's stack lands.
                {
                    when    = { mapID = 812 },
                    kind    = "path",
                    triggeredBy = { aura = 229074, stacks = 2 },
                    drawWhenOpen = true,
                    note    ="After collecting the second ^Soul Fragment^, exit the bedroom and take a left to reach ^Maiden of Virtue^.",
                    minNote = "Exit bedroom, left to Maiden",
                    points  = {
                        { 0.809, 0.268 },
                        { 0.750, 0.399 },
                        { 0.802, 0.459 },
                    },
                },
            },
        },

        -- 3. Moroes (boss 6).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 6,
            title     = "Moroes",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 812 },
                    kind    = "path",
                    note    = "After defeating ^Maiden of Virtue^, backtrack out of her room down the hall. Go left back into the ^Banquet Hall^, and jump over the ledge to reach ^Moroes^.",
                    minNote = "Back to Banquet Hall, Jump down to Moroes",
                    points  = {
                        { 0.779, 0.428 },
                        { 0.669, 0.328 },
                        { 0.570, 0.309 },
                        { 0.564, 0.371 },
                        { 0.482, 0.503 },
                        { 0.440, 0.605 },
                    },
                },
            },
        },

        -- 4. Attumen the Huntsman (boss 5).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 5,
            title     = "Attumen the Huntsman",
            requires  = { },
            segments  = {
                -- With Nightbane: the third Soul Fragment, behind Moroes. Its
                -- map marker already names it.
                {
                    when    = { mapID = 811 },
                    kind    = "path",
                    note    = "After killing ^Moroes^, click the third ^Soul Fragment^ right behind him.",
                    minNote = "Click third soul fragment behind Moroes",
                    points  = {},
                },
                -- Once the third fragment's stack lands, or straight away in
                -- a run without Nightbane.
                {
                    when    = { mapID = 811 },
                    kind    = "path",
                    triggeredBy = { aura = 229074, stacks = 3, openWithoutBoss = 11 },
                    drawWhenOpen = true,
                    note    ="Collect the ^Rusty Keys^ on the floor near ^Moroes^. Exit northeast into ^The Grand Ballroom^ and go down the south stairwell into ^Servants' Quarters^.",
                    minNote = "Collect Rusty Keys then path to Servants' Quarters",
                    points  = {
                        { 0.323, 0.639 },
                        { 0.458, 0.555 },
                        { 0.504, 0.560 },
                        { 0.545, 0.656 },
                        { 0.526, 0.900 },
                    },
                },
                {
                    -- The stairwell down to the Servants' Quarters, ringed.
                    when            = { mapID = 811 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    points          = {
                        { 0.523, 0.939 },
                    },
                },
                {
                    when    = { mapID = 809 },
                    kind    = "path",
                    note    = "Once you reach the bottom of the stairs, take a right into the stables to reach ^Attumen the Huntsman^.",
                    minNote = "Right into stables for Attumen",
                    points  = {
                        { 0.532, 0.655 },
                        { 0.501, 0.725 },
                        { 0.434, 0.771 },
                        { 0.444, 0.792 },
                    },
                },
            },
        },

        -- 5. The Curator (boss 7).
        {
            step      = 5,
            priority  = 1,
            bossIndex = 7,
            title     = "The Curator",
            requires  = { },
            segments  = {
                -- With Nightbane: the fourth Soul Fragment, beside the portal.
                {
                    when    = { mapID = 809 },
                    kind    = "path",
                    note    = "After killing ^Attumen^, follow the path to the far northeast section of the map to locate the fourth ^Soul Fragment^.",
                    minNote = "Northeast to fourth Soul Fragment",
                    skipWhenBoss = 11,
                    skipNote     = "After killing ^Attumen the Huntsman^, go north through the ^Servants' Quarters^ to the far northeast section of the map. Take the ^Portal to Karazhan Entrance^. Kill any spiders that you encounter to avoid getting stuck in combat.",
                    skipMinNote  = "Northeast to portal",
                    points  = {
                        { 0.478, 0.747 },
                        { 0.509, 0.711 },
                        { 0.589, 0.700 },
                        { 0.604, 0.679 },
                        { 0.579, 0.595 },
                        { 0.580, 0.553 },
                        { 0.560, 0.503 },
                        { 0.590, 0.419 },
                        { 0.609, 0.184 },
                        { 0.714, 0.204 },
                    },
                },
                -- The portal once the fourth fragment's stack lands. A run
                -- without Nightbane starts here, on the whole way to it.
                {
                    when    = { mapID = 809 },
                    kind    = "path",
                    triggeredBy = { aura = 229074, stacks = 4, openWithoutBoss = 11 },
                    note    = "Kill all spiders around the portal and drop combat before clicking the ^Portal to Karazhan Entrance^.",
                    minNote = "Clear spiders, then click portal",
                    points  = {},
                    skipWhenBoss = 11,
                    skipNote     = "After killing ^Attumen the Huntsman^, go north through the ^Servants' Quarters^ to the far northeast section of the map. Take the ^Portal to Karazhan Entrance^. Kill any spiders that you encounter to avoid getting stuck in combat.",
                    skipMinNote  = "Northeast to portal",
                    skipPoints   = {
                        { 0.478, 0.747 },
                        { 0.509, 0.711 },
                        { 0.589, 0.700 },
                        { 0.604, 0.679 },
                        { 0.579, 0.595 },
                        { 0.580, 0.553 },
                        { 0.560, 0.503 },
                        { 0.590, 0.419 },
                        { 0.609, 0.184 },
                        { 0.714, 0.204 },
                    },
                },
                {
                    when    = { mapID = 814 },
                    kind    = "path",
                    note    = "After teleporting, go left down the ramp. Loop around to climb the ramp above towards ^Lower Broken Stair^.",
                    minNote = "Climb ramp to Lower Broken Stair",
                    points  = {
                        { 0.610, 0.637 },
                        { 0.621, 0.710 },
                        { 0.603, 0.730 },
                        { 0.578, 0.721 },
                        { 0.556, 0.737 },
                        { 0.574, 0.764 },
                        { 0.608, 0.761 },
                        { 0.626, 0.745 },
                        { 0.644, 0.715 },
                    },
                },
                {
                    when    = { mapID = 815 },
                    kind    = "path",
                    note    = "Follow the linear path as you climb your way to the ^Upper Broken Stair^.",
                    minNote = "Climb to Upper Broken Stair",
                    points  = {
                        { 0.719, 0.606 },
                        { 0.715, 0.512 },
                        { 0.685, 0.398 },
                        { 0.608, 0.299 },
                        { 0.579, 0.289 },
                        { 0.561, 0.341 },
                        { 0.526, 0.367 },
                        { 0.464, 0.544 },
                        { 0.469, 0.631 },
                        { 0.516, 0.545 },
                        { 0.539, 0.566 },
                        { 0.501, 0.656 },
                        { 0.516, 0.668 },
                        { 0.531, 0.635 },
                    },
                },
                {
                    when    = { mapID = 816 },
                    kind    = "path",
                    note    = "Continue on the path into ^The Menagerie^.",
                    minNote = "Continue into The Menagerie",
                    points  = {
                        { 0.485, 0.411 },
                        { 0.432, 0.423 },
                        { 0.323, 0.517 },
                        { 0.292, 0.607 },
                        { 0.463, 0.739 },
                        { 0.557, 0.478 },
                        { 0.476, 0.317 },
                    },
                },
                {
                    when    = { mapID = 817 },
                    kind    = "path",
                    note    = "Continue into ^The Menagerie^ to reach ^The Curator^.",
                    minNote = "Continue to The Curator",
                    points  = {
                        { 0.584, 0.285 },
                        { 0.467, 0.266 },
                        { 0.439, 0.293 },
                        { 0.403, 0.299 },
                        { 0.323, 0.387 },
                        { 0.469, 0.669 },
                    },
                },
            },
        },

        -- 6. Nightbane (boss 11), Mythic only. Optional: the question on
        -- arrival keeps him on the route or leaves him out.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 11,
            optional  = true,
            skipWhenCollected = true,
            -- Once Medivh's Echo runs out he cannot be summoned this lockout.
            skipIrreversible = true,
            title     = "Nightbane",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 817 },
                    kind    = "path",
                    note    = "After defeating ^The Curator^, click the last ^Soul Fragment^ he drops, then backtrack to the ^Upper Broken Stair^.",
                    minNote = "Click his fragment, backtrack",
                    points  = {
                        { 0.465, 0.667 },
                        { 0.320, 0.382 },
                        { 0.401, 0.301 },
                        { 0.479, 0.265 },
                        { 0.573, 0.285 },
                        { 0.621, 0.308 },
                    },
                },
                {
                    when    = { mapID = 816 },
                    kind    = "path",
                    note    = "Jump down or descend the stairs into the ^Lower Broken Stair^.",
                    minNote = "Jump down into Lower Broken Stair",
                    points  = {
                        { 0.473, 0.321 },
                        { 0.505, 0.434 },
                        { 0.463, 0.536 },
                    },
                },
                {
                    when    = { mapID = 815 },
                    kind    = "path",
                    note    = "Continue jumping down or descending until you reach the area near the entrance. Head south to go outside on ^The Master's Terrace^ and talk to ^Image of Medivh^ to start the encounter with ^Nightbane^.",
                    minNote = "Jump down to entrance, outside to Medivh",
                    points  = {
                        { 0.469, 0.626 },
                        { 0.444, 0.529 },
                        { 0.529, 0.330 },
                        { 0.477, 0.231 },
                    },
                },
                {
                    when    = { mapID = 814 },
                    kind    = "path",
                    points  = {
                        { 0.596, 0.611 },
                        { 0.621, 0.703 },
                        { 0.590, 0.743 },
                        { 0.590, 0.828 },
                        { 0.586, 0.898 },
                        { 0.542, 0.936 },
                    },
                },
                {
                    when        = { mapID = 814 },
                    kind        = "poi",
                    poiKind     = "talk",
                    mapLabel    = "Talk to Medivh",
                    mapLabelPos = "right",
                    points      = {
                        { 0.447, 0.860 },
                    },
                },
            },
        },

        -- 7. Shade of Medivh (boss 8).
        {
            step      = 7,
            priority  = 1,
            bossIndex = 8,
            title     = "Shade of Medivh",
            requires  = { },
            segments  = {
                -- After Nightbane, the climb back up to the portal. A player
                -- who skipped him starts on the portal ring; one back down
                -- here without him climbs from the entrance.
                {
                    when    = { mapID = 814 },
                    kind    = "path",
                    note    = "After defeating ^Nightbane^, go back inside from ^Master's Terrace^ and loop around to climb the ramp above you towards ^Lower Broken Stair^.",
                    minNote = "Climb ramp to Lower Broken Stair",
                    points  = {
                        { 0.587, 0.811 },
                        { 0.593, 0.726 },
                        { 0.571, 0.723 },
                        { 0.554, 0.737 },
                        { 0.567, 0.757 },
                        { 0.579, 0.765 },
                        { 0.606, 0.763 },
                        { 0.627, 0.746 },
                        { 0.644, 0.715 },
                    },
                    skipWhenBoss = 11,
                    skipNote     = "Climb the ramp towards ^Lower Broken Stair^.",
                    skipPoints   = {
                        { 0.610, 0.637 },
                        { 0.621, 0.710 },
                        { 0.603, 0.730 },
                        { 0.578, 0.721 },
                        { 0.556, 0.737 },
                        { 0.574, 0.764 },
                        { 0.608, 0.761 },
                        { 0.626, 0.745 },
                        { 0.644, 0.715 },
                    },
                },
                {
                    when    = { mapID = 815 },
                    kind    = "path",
                    note    = "Follow the linear path as you climb your way to the ^Upper Broken Stair^.",
                    minNote = "Climb to Upper Broken Stair",
                    points  = {
                        { 0.719, 0.606 },
                        { 0.715, 0.512 },
                        { 0.685, 0.398 },
                        { 0.608, 0.299 },
                        { 0.579, 0.289 },
                        { 0.561, 0.341 },
                        { 0.526, 0.367 },
                        { 0.464, 0.544 },
                        { 0.469, 0.631 },
                        { 0.516, 0.545 },
                        { 0.539, 0.566 },
                        { 0.501, 0.656 },
                        { 0.516, 0.668 },
                        { 0.531, 0.635 },
                    },
                },
                {
                    when    = { mapID = 816 },
                    kind    = "path",
                    note    = "Continue on the path into ^The Menagerie^.",
                    minNote = "Continue into The Menagerie",
                    points  = {
                        { 0.485, 0.411 },
                        { 0.432, 0.423 },
                        { 0.323, 0.517 },
                        { 0.292, 0.607 },
                        { 0.463, 0.739 },
                        { 0.557, 0.478 },
                        { 0.476, 0.317 },
                    },
                },
                {
                    -- The portal to the Guardian's Library, ringed.
                    when            = { mapID = 817 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    note            = "Walk into the portal at the end of ^The Curator^'s hallway.",
                    minNote         = "Walk into portal",
                    points          = {
                        { 0.516, 0.758 },
                    },
                },
                {
                    when    = { mapID = 818 },
                    kind    = "path",
                    note    = "After teleporting to the ^Guardian's Library^, follow the linear path until you reach ^Shade of Medivh^.",
                    minNote = "Follow path to Shade of Medivh",
                    points  = {
                        { 0.230, 0.180 },
                        { 0.231, 0.414 },
                        { 0.250, 0.424 },
                        { 0.264, 0.466 },
                        { 0.703, 0.467 },
                    },
                },
            },
        },

        -- 8. Mana Devourer (boss 9).
        {
            step      = 8,
            priority  = 1,
            bossIndex = 9,
            title     = "Mana Devourer",
            requires  = { },
            segments  = {
                {
                    -- The drop to the Library Floor, ringed.
                    when            = { mapID = 818 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    note            = "After defeating ^Shade of Medivh^, exit south and jump off the ledge.",
                    minNote         = "South to jump off ledge",
                    points          = {
                        { 0.731, 0.585 },
                    },
                },
                {
                    when    = { mapID = 819 },
                    kind    = "path",
                    note    = "After you land, jump down to the floor to find ^Mana Devourer^ patrolling around.",
                    minNote = "Jump down to Mana Devourer",
                    points  = {
                        { 0.477, 0.700 },
                        { 0.517, 0.676 },
                        { 0.552, 0.566 },
                    },
                },
            },
        },

        -- 9. Viz'aduum the Watcher (boss 10).
        {
            step      = 9,
            priority  = 1,
            bossIndex = 10,
            title     = "Viz'aduum the Watcher",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 820 },
                    kind    = "path",
                    note    = "After defeating ^Mana Devourer^, grab the chest nearby and follow the linear path to ^Gamesman's Hall^.",
                    minNote = "Path to Gamesman's Hall",
                    points  = {
                        { 0.225, 0.261 },
                        { 0.599, 0.260 },
                        { 0.598, 0.441 },
                        { 0.583, 0.521 },
                        { 0.580, 0.614 },
                        { 0.568, 0.787 },
                    },
                },
                {
                    when    = { mapID = 821 },
                    kind    = "path",
                    note    = "Inside the chess room, kill the enemies to unblock the path, then continue on the path to ^Netherspace^. The NPCs will open the door after a brief dialog. Enter the room to face the final boss, ^Viz'aduum the Watcher^.",
                    minNote = "Chess Room then Viz'aduum",
                    points  = {
                        { 0.491, 0.161 },
                        { 0.495, 0.861 },
                        { 0.477, 0.903 },
                        { 0.446, 0.903 },
                    },
                },
            },
        },
    },
}
