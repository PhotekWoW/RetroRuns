-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Valor
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1477  |  journalInstanceID: 721
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[721] = {
    kind              = "dungeon",
    instanceID        = 1477,
    journalInstanceID = 721,
    name              = "Halls of Valor",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "7.0.3",
    routedIn          = "3.5.0",

    entrance = {
        mapID = 634,
        x     = 0.7275,
        y     = 0.7036,
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
        { id = 10544, name = "Stag Party", meta = true, soloable = "yes" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Hymdall",
            journalEncounterID = 1485,
            dungeonEncounterID = 1805,
            achievements       = {
            },
            loot = {
                { id = 134179, slot = "Chest", name = "Skoldiir Breastplate", sources = { [14]=77483, [15]=77483, [16]=77483 } },
                { id = 136774, slot = "Feet", name = "Cushioned Treads of Glory", sources = { [14]=78629, [15]=80026, [16]=78629 } },
                { id = 133628, slot = "Hands", name = "Battleborne Sentinel Gauntlets", sources = { [14]=76866, [15]=79935, [16]=76866 } },
                { id = 134216, slot = "Head", name = "Bonespeaker Cowl", sources = { [14]=77510, [15]=77510, [16]=77510 } },
                { id = 134194, slot = "Legs", name = "Biornskin Leggings", sources = { [14]=77495, [15]=77495, [16]=77495 } },
                { id = 134213, slot = "Shoulder", name = "Tideskorn Mantle", sources = { [14]=77507, [15]=77507, [16]=77507 } },
                { id = 133805, slot = "Waist", name = "Thundercaller's Chain", sources = { [14]=76928, [15]=80121, [16]=76928 } },
                { id = 201997, slot = "Weapon", name = "Key to the Halls", sources = { [14]=184051, [15]=184051, [16]=184051 } },
                { id = 133621, slot = "Wrist", name = "Adorned Guardian's Bracers", sources = { [14]=76859, [15]=80060, [16]=76859 } },
            },
        },
        {
            index              = 2,
            name               = "Hyrja",
            journalEncounterID = 1486,
            dungeonEncounterID = 1806,
            achievements       = {
            },
            loot = {
                { id = 134219, slot = "Chest", name = "Bonespeaker Robes", sources = { [14]=77513, [15]=77513, [16]=77513 } },
                { id = 133622, slot = "Chest", name = "Thunderfused Val'kyr Hauberk", sources = { [14]=76860, [15]=80114, [16]=76860 } },
                { id = 136772, slot = "Feet", name = "Valkyra Protector Greatboots", sources = { [14]=78627, [15]=79966, [16]=78627 } },
                { id = 134209, slot = "Hands", name = "Tideskorn Gauntlets", sources = { [14]=77503, [15]=77503, [16]=77503 } },
                { id = 134196, slot = "Head", name = "Biornskin Hood", sources = { [14]=77497, [15]=77497, [16]=77497 } },
                { id = 133620, slot = "Shoulder", name = "Amice of the Enlightened", sources = { [14]=76858, [15]=80059, [16]=76858 } },
                { id = 133613, slot = "Waist", name = "Solsten's Arcing Runecord", sources = { [14]=76851, [15]=79999, [16]=76851 } },
                { id = 134186, slot = "Wrist", name = "Skoldiir Bracers", sources = { [14]=77490, [15]=77490, [16]=77490 } },
            },
        },
        {
            index              = 3,
            name               = "Fenryr",
            journalEncounterID = 1487,
            dungeonEncounterID = 1807,
            achievements       = {
            },
            loot = {
                { id = 133639, slot = "Back", name = "Goldscar Pelt", sources = { [14]=76872, [15]=80804, [16]=76872 } },
                { id = 133615, slot = "Chest", name = "Hide of Fenryr", sources = { [14]=76853, [15]=80054, [16]=76853 } },
                { id = 133609, slot = "Hands", name = "Silken Bloodscent Gloves", sources = { [14]=76847, [15]=79995, [16]=76847 } },
                { id = 136773, slot = "Waist", name = "Greatbelt of Alpha Dominance", sources = { [14]=78628, [15]=79967, [16]=78628 } },
                { id = 201998, slot = "Weapon", name = "Fenryr's Bloodstained Fang", sources = { [14]=184052, [15]=184052, [16]=184052 } },
                { id = 133626, slot = "Wrist", name = "Runebands of the Worthy", sources = { [14]=76864, [15]=80118, [16]=76864 } },
            },
        },
        {
            index              = 4,
            name               = "God-King Skovald",
            journalEncounterID = 1488,
            dungeonEncounterID = 1808,
            achievements       = {
            },
            loot = {
                { id = 134193, slot = "Feet", name = "Biornskin Moccasins", sources = { [14]=77494, [15]=77494, [16]=77494 } },
                { id = 133623, slot = "Feet", name = "Felstep Footguards", sources = { [14]=76861, [15]=80115, [16]=76861 } },
                { id = 133617, slot = "Hands", name = "Cruel Vice Grips", sources = { [14]=76855, [15]=80056, [16]=76855 } },
                { id = 134182, slot = "Head", name = "Skoldiir Helm", sources = { [14]=77486, [15]=77486, [16]=77486 } },
                { id = 133630, slot = "Legs", name = "Greaves of the God-King", sources = { [14]=76868, [15]=79937, [16]=76868 } },
                { id = 134212, slot = "Legs", name = "Tideskorn Leggings", sources = { [14]=77506, [15]=77506, [16]=77506 } },
                { id = 201999, slot = "Off-hand", name = "Skovald's Resolve", sources = { [14]=184053, [15]=184053, [16]=184053 } },
                { id = 136775, slot = "Shoulder", name = "Infernal Mantle of Conquest", sources = { [14]=78630, [15]=80027, [16]=78630 } },
                { id = 134222, slot = "Wrist", name = "Bonespeaker Bracers", sources = { [14]=77516, [15]=77516, [16]=77516 } },
            },
        },
        {
            index              = 5,
            name               = "Odyn",
            journalEncounterID = 1489,
            dungeonEncounterID = 1809,
            achievements       = {
                { id = 10542, name = "I Got What You Mead", meta = true, soloable = "yes" },
                { id = 10543, name = "Surge Protector", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 133765, slot = "Back", name = "Cape of Valarjar Courage", sources = { [14]=76910, [15]=80805, [16]=76910 } },
                { id = 139280, slot = "Feet", name = "Treads of Light", sources = { [14]=80577, [15]=80578, [16]=80577 } },
                { id = 134217, slot = "Hands", name = "Bonespeaker Gloves", sources = { [14]=77511, [15]=77511, [16]=77511 } },
                { id = 134180, slot = "Hands", name = "Skoldiir Gauntlets", sources = { [14]=77484, [15]=77484, [16]=77484 } },
                { id = 136777, slot = "Head", name = "Collar of Honorable Exultation", sources = { [14]=78632, [15]=80147, [16]=78632 } },
                { id = 139281, slot = "Head", name = "Glory Seeker's Helm", sources = { [14]=80579, [15]=80580, [16]=80579 } },
                { id = 133610, slot = "Legs", name = "Leggings of Swirling Runes", sources = { [14]=76848, [15]=79996, [16]=76848 } },
                { id = 133631, slot = "Shoulder", name = "Pauldrons of the All-Father", sources = { [14]=76869, [15]=79938, [16]=76869 } },
                { id = 136776, slot = "Waist", name = "Bjorn's Hunting Strap", sources = { [14]=78631, [15]=80087, [16]=78631 } },
                { id = 134207, slot = "Waist", name = "Tideskorn Cinch", sources = { [14]=77501, [15]=77501, [16]=77501 } },
                { id = 134192, slot = "Wrist", name = "Biornskin Bracer", sources = { [14]=77493, [15]=77493, [16]=77493 } },
                { id = 139282, slot = "Wrist", name = "Solid Gold Bracelets", sources = { [14]=80581, [15]=80582, [16]=80581 } },
                { id = 139283, slot = "Wrist", name = "Wristbands of Magnificent Splendor", sources = { [14]=80583, [15]=80584, [16]=80583 } },
            },
        },
    },

    exitNote    = "Talk to Odyn to exit",
    minExitNote = "Talk to Odyn to exit",

    routing = {
        -- 1. Hymdall (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Hymdall",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 704 },
                    kind    = "path",
                    note    = "After zoning in, proceed straight ahead to reach ^Hymdall^.",
                    minNote = "Straight ahead to Hymdall",
                    points  = {
                        { 0.477, 0.137 },
                        { 0.478, 0.221 },
                        { 0.489, 0.236 },
                        { 0.490, 0.259 },
                        { 0.478, 0.356 },
                    },
                },
            },
        },
        -- 2. Hyrja (boss 2): up the stairs past Hymdall, left at the fork.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Hyrja",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 704 },
                    kind    = "path",
                    note    = "After defeating ^Hymdall^, continue past him up the stairs. Go left at the fork to eventually reach ^Hyrja^.",
                    minNote = "Upstairs, left to Hyrja",
                    points  = {
                        { 0.478, 0.436 },
                        { 0.479, 0.484 },
                        { 0.499, 0.506 },
                        { 0.502, 0.535 },
                        { 0.481, 0.571 },
                        { 0.484, 0.665 },
                        { 0.519, 0.679 },
                        { 0.546, 0.715 },
                        { 0.609, 0.813 },
                    },
                },
            },
        },
        -- 3. Fenryr (boss 3): back west to the Field of the Eternal Hunt exit,
        -- then after him to where he makes his stand.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Fenryr",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 704 },
                    kind    = "path",
                    note    = "After defeating ^Hyrja^, backtrack west to the map exit labeled ^Field of the Eternal Hunt^.",
                    minNote = "West to Field of the Eternal Hunt",
                    points  = {
                        { 0.603, 0.802 },
                        { 0.521, 0.676 },
                        { 0.434, 0.677 },
                        { 0.408, 0.718 },
                    },
                },
                {
                    -- Noteless, so the leg above keeps the pane.
                    when            = { mapID = 704 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    points          = {
                        { 0.394, 0.736 },
                    },
                },
                {
                    when    = { mapID = 703 },
                    kind    = "path",
                    note    = "In the fields, follow the path to the northwest to reach ^Fenryr^. When he runs, follow him southwest to his boss icon to finish him off.",
                    minNote = "Northwest to Fenryr",
                    points  = {
                        { 0.628, 0.316 },
                        { 0.597, 0.363 },
                        { 0.558, 0.381 },
                        { 0.533, 0.420 },
                        { 0.502, 0.455 },
                        { 0.462, 0.476 },
                        { 0.439, 0.439 },
                        { 0.412, 0.415 },
                    },
                },
                {
                    -- Noteless, so the leg above keeps the pane.
                    when        = { mapID = 703 },
                    kind        = "poi",
                    mapLabel    = "Fenryr",
                    mapLabelPos = "above",
                    points      = {
                        { 0.366, 0.360 },
                    },
                },
            },
        },
        -- 4. God-King Skovald (boss 4): back northeast to the main hall.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "God-King Skovald",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 703 },
                    kind    = "path",
                    note    = "After killing ^Fenryr^, backtrack northeast to return to the main hall.",
                    minNote = "Backtrack northeast to portal",
                    points  = {
                        { 0.296, 0.639 },
                        { 0.304, 0.508 },
                        { 0.319, 0.432 },
                        { 0.369, 0.407 },
                        { 0.426, 0.427 },
                        { 0.477, 0.482 },
                        { 0.515, 0.448 },
                        { 0.546, 0.390 },
                        { 0.595, 0.362 },
                        { 0.632, 0.316 },
                        { 0.658, 0.293 },
                    },
                },
                {
                    when    = { mapID = 704 },
                    kind    = "path",
                    note    = "Back in the main hall, go slightly east and go up the ramp at the map exit labeled ^Halls of Valor^.",
                    minNote = "East to ramp, Halls of Valor",
                    points  = {
                        { 0.412, 0.712 },
                        { 0.429, 0.683 },
                        { 0.455, 0.682 },
                        { 0.473, 0.704 },
                    },
                },
                {
                    -- Noteless, so the leg above keeps the pane.
                    when            = { mapID = 704 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    points          = {
                        { 0.477, 0.723 },
                    },
                },
                {
                    when    = { mapID = 705 },
                    kind    = "path",
                    note    = "Once you reach the ^Halls of Valor^, talk to each NPC and defeat them in combat.",
                    minNote = "Defeat each NPC",
                    points  = {
                        { 0.514, 0.097 },
                        { 0.514, 0.783 },
                        { 0.540, 0.872 },
                    },
                },
                {
                    -- Hidden until Odyn hands over the Aegis.
                    when         = { mapID = 705 },
                    kind         = "poi",
                    note         = "Pick up the ^Aegis of Aggramar^ to trigger encounter with ^God-King Skovald^.",
                    minNote      = "Pick up Aegis for Skovald",
                    mapLabel     = "Pick up Aegis",
                    mapLabelPos  = "above",
                    triggeredBy  = { dialog = { npc = "Odyn", match = "The Aegis of Aggramar is yours for the taking." } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.515, 0.895 },
                    },
                },
            },
        },
        -- 5. Odyn (boss 5), in the same hall once he jumps down.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Odyn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 705 },
                    kind    = "path",
                    note    = "After killing ^God-King Skovald^, you will witness a brief dialog from ^Odyn^. When he jumps down, talk to him to begin the final encounter.",
                    minNote = "Talk to Odyn",
                    points  = { },
                },
            },
        },
    },
}
