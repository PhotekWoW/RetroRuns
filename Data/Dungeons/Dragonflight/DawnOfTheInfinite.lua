-------------------------------------------------------------------------------
-- RetroRuns Data -- Dawn of the Infinite
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Dragonflight dungeon, Patch 10.1.5  |  instanceID: 2579  |  journalInstanceID: 1209
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1209] = {
    kind              = "dungeon",
    instanceID        = 2579,
    journalInstanceID = 1209,
    name              = "Dawn of the Infinite",
    expansion         = "Dragonflight",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 15, 16 },
    patch             = "10.1.5",

    entrance = {
        mapID = 2025,
        x     = 0.6110,
        y     = 0.8440,
    },

    bosses = {
        {
            index              = 1,
            name               = "Chronikar",
            journalEncounterID = 2521,
            dungeonEncounterID = 2666,
            achievements       = {
                { id = 18589, name = "Crunch Time", soloable = "yes" },
            },
            loot = {
                { id = 207828, slot = "Chest", name = "Bronze Defender's Vesture", sources = { [15]=188912, [16]=188912 } },
                { id = 207838, slot = "Feet", name = "Vigorous Sandstompers", sources = { [15]=188922, [16]=188922 } },
                { id = 207819, slot = "Legs", name = "Timeways Intruder's Greaves", sources = { [15]=188906, [16]=188906 } },
                { id = 207995, slot = "Weapon", name = "Chronikar's Ceremonial Saber", sources = { [15]=189063, [16]=189063 } },
                { id = 207991, slot = "Weapon", name = "Double Time", sources = { [15]=189059, [16]=189059 } },
                { id = 207923, slot = "Wrist", name = "Zealous Commander's Cuffs", sources = { [15]=189007, [16]=189007 } },
            },
        },
        {
            index              = 2,
            name               = "Manifested Timeways",
            journalEncounterID = 2528,
            dungeonEncounterID = 2667,
            achievements       = {
                { id = 18556, name = "Chaotic Time", soloable = "yes" },
            },
            loot = {
                { id = 207903, slot = "Hands", name = "Fading Chronogrips", sources = { [15]=188987, [16]=188987 } },
                { id = 207898, slot = "Waist", name = "Mobius Strap", sources = { [15]=188982, [16]=188982 } },
                { id = 207858, slot = "Waist", name = "Unwinding Eon Girdle", sources = { [15]=188942, [16]=188942 } },
                { id = 207999, slot = "Weapon", name = "Conflux Caller's Baton", sources = { [15]=189067, [16]=189067 } },
                { id = 207996, slot = "Weapon", name = "Nick of Time", sources = { [15]=189064, [16]=189064 } },
                { id = 207851, slot = "Wrist", name = "Timeway Sojourner's Bracelet", sources = { [15]=188935, [16]=188935 } },
            },
        },
        {
            index              = 3,
            name               = "Blight of Galakrond",
            journalEncounterID = 2535,
            dungeonEncounterID = 2668,
            achievements       = {
                { id = 18612, name = "A Slime in Need", soloable = "yes" },
            },
            loot = {
                { id = 207836, slot = "Chest", name = "Ahnzon's Corroded Carapace", sources = { [15]=188920, [16]=188920 } },
                { id = 207817, slot = "Feet", name = "Imbued Frostweave Slippers", sources = { [15]=188904, [16]=188904 } },
                { id = 207912, slot = "Head", name = "Loszkeleth's Blighted Skullhelm", sources = { [15]=188996, [16]=188996 } },
                { id = 207983, slot = "Off-hand", name = "Ancestor's Necromantic Focus", sources = { [15]=189051, [16]=189051 } },
                { id = 207921, slot = "Shoulder", name = "Dazhak's Desiccated Wingbones", sources = { [15]=189005, [16]=189005 } },
                { id = 207992, slot = "Weapon", name = "Fallen Drake's Bonesplitter", sources = { [15]=189060, [16]=189060 } },
            },
        },
        {
            index              = 4,
            name               = "Iridikron the Stonescaled",
            journalEncounterID = 2537,
            dungeonEncounterID = 2669,
            aliases            = { "Iridikron" },
            scenarioCriteriaID = 60679,
            achievements       = {
            },
            loot = {
                { id = 207911, slot = "Hands", name = "Stonecracker Knuckles", sources = { [15]=188995, [16]=188995 } },
                { id = 207920, slot = "Head", name = "Incarnate's Perceptive Casque", sources = { [15]=189004, [16]=189004 } },
                { id = 207820, slot = "Legs", name = "Galakrond's Voracious Hide", sources = { [15]=188907, [16]=188907 } },
                { id = 207897, slot = "Shoulder", name = "Mantle of Meticulous Plans", sources = { [15]=188981, [16]=188981 } },
                { id = 208321, slot = "Two-Hand", name = "Iridal, the Earth's Master", sources = { [15]=189654, [16]=189654 } },
            },
        },
        {
            index              = 5,
            name               = "Tyr, the Infinite Keeper",
            journalEncounterID = 2526,
            dungeonEncounterID = 2670,
            achievements       = {
                { id = 18539, name = "Back En-masse", soloable = "yes" },
            },
            loot = {
                { id = 207876, slot = "Chest", name = "Temple Acolyte's Uniform", sources = { [15]=188960, [16]=188960 } },
                { id = 207950, slot = "Feet", name = "Marbled Oathstone Greatboots", sources = { [15]=189034, [16]=189034 } },
                { id = 207927, slot = "Head", name = "Crown of the Infinite Lord", sources = { [14]=189011, [15]=189011, [16]=189011 } },
                { id = 207873, slot = "Shoulder", name = "Titanic Shouldersparks", sources = { [15]=188957, [16]=188957 } },
                { id = 208391, slot = "Two-Hand", name = "The Infinite Hand", sources = { [15]=189716, [16]=189716 } },
            },
        },
        {
            index              = 6,
            name               = "Morchie",
            journalEncounterID = 2536,
            dungeonEncounterID = 2671,
            achievements       = {
            },
            loot = {
                { id = 207862, slot = "Hands", name = "Familiar's Frayed Gloves", sources = { [15]=188946, [16]=188946 } },
                { id = 207824, slot = "Legs", name = "Greaves of Parallel Lives", sources = { [15]=188910, [16]=188910 } },
                { id = 207986, slot = "Ranged", name = "Traveler's Timesplitter", sources = { [15]=189054, [16]=189054 } },
                { id = 207946, slot = "Waist", name = "Reality-Warping Waistband", sources = { [15]=189030, [16]=189030 } },
                { id = 207997, slot = "Weapon", name = "Morchie's Distorted Spellblade", sources = { [15]=189065, [16]=189065 } },
                { id = 207939, slot = "Wrist", name = "Chronomancer's Stasis Shackles", sources = { [15]=189023, [16]=189023 } },
            },
        },
        {
            index              = 7,
            name               = "Time-Lost Battlefield",
            journalEncounterID = 2533,
            dungeonEncounterID = 2672,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
            },
            loot = {
                { id = 207884, slot = "Chest", name = "Unceasing Footman's Breastplate", sources = { [15]=188968, [16]=188968 } },
                { id = 207878, slot = "Feet", name = "Grunt's Eternal Treads", sources = { [15]=188962, [16]=188962 } },
                { id = 207936, slot = "Head", name = "Hood of Perpetual Conflict", sources = { [14]=189020, [15]=189020, [16]=189020 } },
                { id = 208193, slot = "Two-Hand", name = "Gorehowl, Might of the Warchief", sources = { [15]=189606, [16]=189606 } },
                { id = 208000, slot = "Weapon", name = "Cudgel of Bygone Victories", sources = { [15]=189068, [16]=189068 } },
                { id = 207994, slot = "Weapon", name = "Quel'Zaram, High Blade of the Lion", sources = { [15]=189062, [16]=189062 } },
                { id = 207867, slot = "Wrist", name = "Arathi Field Bandages", sources = { [15]=188951, [16]=188951 } },
            },
        },
        {
            index              = 8,
            name               = "Chrono-Lord Deios",
            journalEncounterID = 2538,
            dungeonEncounterID = 2673,
            achievements       = {
                { id = 18706, name = "Put That Thing Back Where It Came From", soloable = "no" },
            },
            loot = {
                { id = 207951, slot = "Hands", name = "Displaced Trooper's Gauntlets", sources = { [15]=189035, [16]=189035 } },
                { id = 207928, slot = "Legs", name = "Leggings of the New Dawn", sources = { [15]=189012, [16]=189012 } },
                { id = 207978, slot = "Off-hand", name = "Murozond's Timeless Scale", sources = { [15]=189046, [16]=189046 } },
                { id = 207945, slot = "Shoulder", name = "Chrono-Lord's Wingspan", sources = { [14]=189029, [15]=189029, [16]=189029 } },
                { id = 207987, slot = "Two-Hand", name = "Borrowed Time", sources = { [15]=189055, [16]=189055 } },
                { id = 207874, slot = "Waist", name = "Belt of the Eternal Struggle", sources = { [15]=188958, [16]=188958 } },
            },
            specialLoot = {
                { id = 208102, kind = "manuscript", name = "Cliffside Wylderdrake: Visage of the Infinite", questID = 77258 },
                { id = 208103, kind = "manuscript", name = "Highland Drake: Visage of the Infinite", questID = 77257 },
                { id = 208104, kind = "manuscript", name = "Renewed Proto-Drake: Visage of the Infinite", questID = 77255 },
                { id = 208105, kind = "manuscript", name = "Windborne Velocidrake: Visage of the Infinite", questID = 77256 },
                { id = 208106, kind = "manuscript", name = "Winding Slitherdrake: Visage of the Infinite", questID = 77259 },
                { id = 208216, kind = "mount", name = "Reins of the Quantum Courser", mythicOnly = true },
            },
        },
    },
}
