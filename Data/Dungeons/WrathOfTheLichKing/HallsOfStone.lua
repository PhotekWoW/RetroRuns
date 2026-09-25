-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Stone
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 599  |  journalInstanceID: 277
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[277] = {
    kind              = "dungeon",
    instanceID        = 599,
    journalInstanceID = 277,
    name              = "Halls of Stone",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    routedIn          = "3.3.0",

    entrance = {
        mapID = 120,
        x     = 0.3944,
        y     = 0.2691,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37672, slot = "Chest", name = "Patina-Coated Breastplate", sources = { [15]=17940 }, bind = "BoE" },
        { id = 36999, slot = "Feet", name = "Boots of the Terrestrial Guardian", sources = { [14]=17527 }, bind = "BoE" },
        { id = 37671, slot = "Hands", name = "Refined Ore Gloves", sources = { [15]=17939 }, bind = "BoE" },
        { id = 37673, slot = "Shoulder", name = "Dark Runic Mantle", sources = { [15]=17941 }, bind = "BoE" },
        { id = 36997, slot = "Waist", name = "Sash of the Hardened Watcher", sources = { [14]=17525 }, bind = "BoE" },
        { id = 35681, slot = "Weapon", name = "Unrelenting Blade", sources = { [14]=16597 }, bind = "BoE" },
        { id = 35682, slot = "Wrist", name = "Rune Giant Bindings", sources = { [14]=16598 }, bind = "BoE" },
        { id = 37000, slot = "Wrist", name = "Storming Vortex Bracers", sources = { [14]=17528 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Krystallus",
            journalEncounterID = 604,
            dungeonEncounterID = 1994,
            achievements       = {
            },
            loot = {
                { id = 35670, slot = "Head", name = "Brann's Lost Mining Helmet", sources = { [14]=16588, [15]=16588 } },
                { id = 35672, slot = "Head", name = "Hollow Geode Helm", sources = { [14]=16589, [15]=16589 } },
                { id = 35673, slot = "Legs", name = "Leggings of Burning Gleam", sources = { [14]=16590, [15]=16590 } },
                { id = 37650, slot = "Legs", name = "Shardling Legguards", sources = { [14]=17926, [15]=17926 } },
                { id = 37652, slot = "Shoulder", name = "Spaulders of Krystallus", sources = { [14]=17927, [15]=17927 } },
                { id = 37649, slot = "Weapon", name = "Quarry Chisel", sources = { [14]=17925, [15]=17925 } },
            },
        },
        {
            index              = 2,
            name               = "Maiden of Grief",
            journalEncounterID = 605,
            dungeonEncounterID = 1996,
            achievements       = {
                { id = 1866, name = "Good Grief", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 38614, slot = "Back", name = "Embrace of Sorrow", sources = { [14]=18493, [15]=18493 } },
                { id = 38615, slot = "Hands", name = "Lightning-Charged Gloves", sources = { [14]=18494, [15]=18494 } },
                { id = 38618, slot = "Two-Hand", name = "Hammer of Grief", sources = { [14]=18496, [15]=18496 } },
                { id = 38616, slot = "Waist", name = "Maiden's Girdle", sources = { [14]=18495, [15]=18495 } },
            },
        },
        {
            index              = 3,
            name               = "Tribunal of Ages",
            journalEncounterID = 606,
            dungeonEncounterID = 1995,
            soloTip            = "This fight is all about protecting Brann from multiple waves of enemies. The fight takes approximately 5 minutes, so be patient!",
            achievements       = {
                { id = 2154, name = "Brann Spankin' New", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 35677, slot = "Chest", name = "Cosmos Vestments", sources = { [14]=16594, [15]=16594 } },
                { id = 35675, slot = "Chest", name = "Linked Armor of the Sphere", sources = { [14]=16592, [15]=16592 } },
                { id = 37654, slot = "Feet", name = "Sabatons of the Ages", sources = { [14]=17929, [15]=17929 } },
                { id = 35676, slot = "Legs", name = "Constellation Leggings", sources = { [14]=16593, [15]=16593 } },
                { id = 37655, slot = "Shoulder", name = "Mantle of the Tribunal", sources = { [14]=17930, [15]=17930 } },
                { id = 37653, slot = "Two-Hand", name = "Sword of Justice", sources = { [14]=17928, [15]=17928 } },
                { id = 157564, slot = "Wrist", name = "Marbled Bracers", sources = { [14]=93759, [15]=93759 } },
                { id = 37656, slot = "Wrist", name = "Raging Construct Bands", sources = { [14]=17931, [15]=17931 } },
            },
        },
        {
            index              = 4,
            name               = "Sjonnir the Ironshaper",
            journalEncounterID = 607,
            dungeonEncounterID = 1998,
            achievements       = {
                { id = 2155, name = "Abuse the Ooze", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 37658, slot = "Chest", name = "Sun-Emblazoned Chestplate", sources = { [14]=17932, [15]=17932 } },
                { id = 37666, slot = "Feet", name = "Boots of the Whirling Mist", sources = { [14]=17934, [15]=17934 } },
                { id = 35679, slot = "Head", name = "Static Cowl", sources = { [14]=16596, [15]=16596 } },
                { id = 35678, slot = "Legs", name = "Ironshaper's Legplates", sources = { [14]=16595, [15]=16595 } },
                { id = 37669, slot = "Legs", name = "Leggings of the Stone Halls", sources = { [14]=17937, [15]=17937 } },
                { id = 37670, slot = "Waist", name = "Sjonnir's Girdle", sources = { [14]=17938, [15]=17938 } },
                { id = 37667, slot = "Weapon", name = "The Fleshshaper", sources = { [14]=17935, [15]=17935 } },
                { id = 37668, slot = "Wrist", name = "Bands of the Stoneforge", sources = { [14]=17936, [15]=17936 } },
            },
        },
    },

    exitNote    = "The exit is a short run to the southwest",
    minExitNote = "Exit to the southwest",

    routing = {
        -- 1. Krystallus (boss 1). South, then west and around.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Krystallus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 140 },
                    kind    = "path",
                    note    = "After zoning in, move ahead and take the southern path. At the next crossroad, go west and loop around until you reach ^Krystallus^.",
                    minNote = "Follow path to Krystallus",
                    points  = {
                        { 0.375, 0.360 },
                        { 0.459, 0.360 },
                        { 0.472, 0.399 },
                        { 0.500, 0.428 },
                        { 0.501, 0.533 },
                        { 0.436, 0.541 },
                        { 0.396, 0.542 },
                        { 0.373, 0.507 },
                        { 0.330, 0.508 },
                        { 0.314, 0.530 },
                        { 0.311, 0.574 },
                        { 0.299, 0.611 },
                        { 0.314, 0.644 },
                        { 0.346, 0.674 },
                        { 0.379, 0.639 },
                    },
                },
            },
        },

        -- 2. Maiden of Grief (boss 2). Down the hole, back to the crossroad,
        -- then south.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Maiden of Grief",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 140 },
                    kind    = "path",
                    note    = "After defeating ^Krystallus^, jump into the hole behind him. Backtrack to the main crossroad and go south this time to reach ^Maiden of Grief^.",
                    minNote = "Backtrack then south to Maiden",
                    points  = {
                        { 0.408, 0.571 },
                        { 0.422, 0.548 },
                        { 0.453, 0.538 },
                        { 0.500, 0.537 },
                        { 0.501, 0.830 },
                    },
                },
            },
        },

        -- 3. Tribunal of Ages (boss 3). Back to the crossroad and east to
        -- Brann, then behind him once he sets off.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Tribunal of Ages",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 140 },
                    kind    = "path",
                    note    = "After killing ^Maiden of Grief^, backtrack to the main crossroad and go east this time. Talk to ^Brann Bronzebeard^ and he will start moving towards the next boss.",
                    minNote = "Backtrack then east to Brann",
                    points  = {
                        { 0.501, 0.818 },
                        { 0.499, 0.534 },
                        { 0.664, 0.533 },
                        { 0.698, 0.503 },
                    },
                },
                {
                    -- Noteless, so the note above stands until he sets off;
                    -- his yell moves the route past it and ticks the label.
                    when            = { mapID = 140 },
                    kind            = "poi",
                    mapLabel        = "Talk to Brann",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    points          = {
                        { 0.710, 0.474 },
                    },
                },
                {
                    when        = { mapID = 140 },
                    kind        = "path",
                    note        = "After talking to ^Brann^, follow him southeast, clearing enemies on the way. When he stops, talk to him one more time to start the fight with ^Tribunal of Ages^.",
                    minNote     = "Follow Brann southeast",
                    triggeredBy = { dialog = { npc = "Brann Bronzebeard", match = "Time to get some answers! Let's get this show on the road!" } },
                    drawWhenOpen = true,
                    points      = {
                        { 0.717, 0.525 },
                        { 0.721, 0.567 },
                        { 0.770, 0.642 },
                        { 0.764, 0.668 },
                        { 0.767, 0.689 },
                        { 0.779, 0.706 },
                        { 0.807, 0.701 },
                    },
                },
                {
                    -- Where he stops. Same yell as the walk, so it appears
                    -- with it; noteless, so the walk's note stays up.
                    when         = { mapID = 140 },
                    kind         = "poi",
                    mapLabel     = "Talk to Brann",
                    mapLabelPos  = "left",
                    triggeredBy  = { dialog = { npc = "Brann Bronzebeard", match = "Time to get some answers! Let's get this show on the road!" } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.824, 0.725 },
                    },
                },
            },
        },

        -- 4. Sjonnir the Ironshaper (boss 4). Brann again after the
        -- Tribunal, then back north to the door he opens.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Sjonnir the Ironshaper",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 140 },
                    kind        = "poi",
                    note        = "After defeating ^Tribunal of Ages^, talk to ^Brann^ to advance.",
                    minNote     = "Talk to Brann",
                    mapLabel    = "Talk to Brann",
                    mapLabelPos = "above",
                    completionCheck = true,
                    points      = {
                        { 0.840, 0.754 },
                    },
                },
                {
                    when         = { mapID = 140 },
                    kind         = "path",
                    note         = "Backtrack all the way towards the north end of the map. Talk to ^Brann^ to open the door to the final boss, ^Sjonnir the Ironshaper^.",
                    minNote      = "Backtrack north, talk to Brann",
                    triggeredBy  = { dialog = { npc = "Brann Bronzebeard", match = "You're right, I can come back to this later." } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.804, 0.699 },
                        { 0.814, 0.683 },
                        { 0.813, 0.659 },
                        { 0.802, 0.634 },
                        { 0.781, 0.631 },
                        { 0.768, 0.639 },
                        { 0.696, 0.535 },
                        { 0.500, 0.537 },
                        { 0.500, 0.414 },
                        { 0.519, 0.406 },
                        { 0.537, 0.377 },
                        { 0.534, 0.344 },
                        { 0.514, 0.314 },
                    },
                },
                {
                    -- The door. Same line as the walk, so it appears with
                    -- it; noteless, so the walk's note stays up.
                    when         = { mapID = 140 },
                    kind         = "poi",
                    mapLabel     = "Talk to Brann",
                    mapLabelPos  = "right",
                    triggeredBy  = { dialog = { npc = "Brann Bronzebeard", match = "You're right, I can come back to this later." } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.498, 0.276 },
                    },
                },
            },
        },
    },
}
