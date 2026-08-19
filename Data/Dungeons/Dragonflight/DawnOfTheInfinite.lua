-------------------------------------------------------------------------------
-- RetroRuns Data -- Dawn of the Infinite
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
    patch             = "10.1.5",

    bosses = {
        {
            index              = 1,
            name               = "Chronikar",
            journalEncounterID = 2521,
            achievements       = {
                { id = 18589, name = "Crunch Time" },
            },
            loot = {
                { id = 207828, slot = "Chest", name = "Bronze Defender's Vesture", sources = { [14]=188912, [15]=188912, [16]=188912 } },
                { id = 207838, slot = "Feet", name = "Vigorous Sandstompers", sources = { [14]=188922, [15]=188922, [16]=188922 } },
                { id = 207819, slot = "Legs", name = "Timeways Intruder's Greaves", sources = { [14]=188906, [15]=188906, [16]=188906 } },
                { id = 207995, slot = "Weapon", name = "Chronikar's Ceremonial Saber", sources = { [14]=189063, [15]=189063, [16]=189063 } },
                { id = 207991, slot = "Weapon", name = "Double Time", sources = { [14]=189059, [15]=189059, [16]=189059 } },
                { id = 207923, slot = "Wrist", name = "Zealous Commander's Cuffs", sources = { [14]=189007, [15]=189007, [16]=189007 } },
            },
        },
        {
            index              = 2,
            name               = "Manifested Timeways",
            journalEncounterID = 2528,
            achievements       = {
                { id = 18556, name = "Chaotic Time" },
            },
            loot = {
                { id = 207903, slot = "Hands", name = "Fading Chronogrips", sources = { [14]=188987, [15]=188987, [16]=188987 } },
                { id = 207898, slot = "Waist", name = "Mobius Strap", sources = { [14]=188982, [15]=188982, [16]=188982 } },
                { id = 207858, slot = "Waist", name = "Unwinding Eon Girdle", sources = { [14]=188942, [15]=188942, [16]=188942 } },
                { id = 207999, slot = "Weapon", name = "Conflux Caller's Baton", sources = { [14]=189067, [15]=189067, [16]=189067 } },
                { id = 207996, slot = "Weapon", name = "Nick of Time", sources = { [14]=189064, [15]=189064, [16]=189064 } },
                { id = 207851, slot = "Wrist", name = "Timeway Sojourner's Bracelet", sources = { [14]=188935, [15]=188935, [16]=188935 } },
            },
        },
        {
            index              = 3,
            name               = "Blight of Galakrond",
            journalEncounterID = 2535,
            achievements       = {
                { id = 18612, name = "A Slime in Need" },
            },
            loot = {
                { id = 207836, slot = "Chest", name = "Ahnzon's Corroded Carapace", sources = { [14]=188920, [15]=188920, [16]=188920 } },
                { id = 207817, slot = "Feet", name = "Imbued Frostweave Slippers", sources = { [14]=188904, [15]=188904, [16]=188904 } },
                { id = 207912, slot = "Head", name = "Loszkeleth's Blighted Skullhelm", sources = { [14]=188996, [15]=188996, [16]=188996 } },
                { id = 207983, slot = "Off-hand", name = "Ancestor's Necromantic Focus", sources = { [14]=189051, [15]=189051, [16]=189051 } },
                { id = 207921, slot = "Shoulder", name = "Dazhak's Desiccated Wingbones", sources = { [14]=189005, [15]=189005, [16]=189005 } },
                { id = 207992, slot = "Weapon", name = "Fallen Drake's Bonesplitter", sources = { [14]=189060, [15]=189060, [16]=189060 } },
            },
        },
        {
            index              = 4,
            name               = "Iridikron the Stonescaled",
            journalEncounterID = 2537,
            achievements       = {
                { id = 18703, name = "Dawn of the Infinite: Galakrond's Fall" },
            },
            loot = {
                { id = 207911, slot = "Hands", name = "Stonecracker Knuckles", sources = { [14]=188995, [15]=188995, [16]=188995 } },
                { id = 207920, slot = "Head", name = "Incarnate's Perceptive Casque", sources = { [14]=189004, [15]=189004, [16]=189004 } },
                { id = 207820, slot = "Legs", name = "Galakrond's Voracious Hide", sources = { [14]=188907, [15]=188907, [16]=188907 } },
                { id = 207897, slot = "Shoulder", name = "Mantle of Meticulous Plans", sources = { [14]=188981, [15]=188981, [16]=188981 } },
                { id = 208321, slot = "Two-Hand", name = "Iridal, the Earth's Master", sources = { [14]=189654, [15]=189654, [16]=189654 } },
            },
        },
        {
            index              = 5,
            name               = "Tyr, the Infinite Keeper",
            journalEncounterID = 2526,
            achievements       = {
                { id = 18539, name = "Back En-masse" },
            },
            loot = {
                { id = 207876, slot = "Chest", name = "Temple Acolyte's Uniform", sources = { [14]=188960, [15]=188960, [16]=188960 } },
                { id = 207950, slot = "Feet", name = "Marbled Oathstone Greatboots", sources = { [14]=189034, [15]=189034, [16]=189034 } },
                { id = 207927, slot = "Head", name = "Crown of the Infinite Lord", sources = { [14]=189011, [15]=189011, [16]=189011 } },
                { id = 207873, slot = "Shoulder", name = "Titanic Shouldersparks", sources = { [14]=188957, [15]=188957, [16]=188957 } },
                { id = 208391, slot = "Two-Hand", name = "The Infinite Hand", sources = { [14]=189716, [15]=189716, [16]=189716 } },
            },
        },
        {
            index              = 6,
            name               = "Morchie",
            journalEncounterID = 2536,
            achievements       = {
            },
            loot = {
                { id = 207862, slot = "Hands", name = "Familiar's Frayed Gloves", sources = { [14]=188946, [15]=188946, [16]=188946 } },
                { id = 207824, slot = "Legs", name = "Greaves of Parallel Lives", sources = { [14]=188910, [15]=188910, [16]=188910 } },
                { id = 207986, slot = "Ranged", name = "Traveler's Timesplitter", sources = { [14]=189054, [15]=189054, [16]=189054 } },
                { id = 207946, slot = "Waist", name = "Reality-Warping Waistband", sources = { [14]=189030, [15]=189030, [16]=189030 } },
                { id = 207997, slot = "Weapon", name = "Morchie's Distorted Spellblade", sources = { [14]=189065, [15]=189065, [16]=189065 } },
                { id = 207939, slot = "Wrist", name = "Chronomancer's Stasis Shackles", sources = { [14]=189023, [15]=189023, [16]=189023 } },
            },
        },
        {
            index              = 7,
            name               = "Time-Lost Battlefield",
            journalEncounterID = 2533,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
            },
            loot = {
                { id = 207884, slot = "Chest", name = "Unceasing Footman's Breastplate", sources = { [14]=188968, [15]=188968, [16]=188968 } },
                { id = 207878, slot = "Feet", name = "Grunt's Eternal Treads", sources = { [14]=188962, [15]=188962, [16]=188962 } },
                { id = 207936, slot = "Head", name = "Hood of Perpetual Conflict", sources = { [14]=189020, [15]=189020, [16]=189020 } },
                { id = 208193, slot = "Two-Hand", name = "Gorehowl, Might of the Warchief", sources = { [14]=189606, [15]=189606, [16]=189606 } },
                { id = 208000, slot = "Weapon", name = "Cudgel of Bygone Victories", sources = { [14]=189068, [15]=189068, [16]=189068 } },
                { id = 207994, slot = "Weapon", name = "Quel'Zaram, High Blade of the Lion", sources = { [14]=189062, [15]=189062, [16]=189062 } },
                { id = 207867, slot = "Wrist", name = "Arathi Field Bandages", sources = { [14]=188951, [15]=188951, [16]=188951 } },
            },
        },
        {
            index              = 8,
            name               = "Chrono-Lord Deios",
            journalEncounterID = 2538,
            achievements       = {
                { id = 18704, name = "Dawn of the Infinite: Murozond's Rise" },
                { id = 18705, name = "Defender of the Timeways" },
                { id = 18706, name = "Put That Thing Back Where It Came From" },
            },
            loot = {
                { id = 207951, slot = "Hands", name = "Displaced Trooper's Gauntlets", sources = { [14]=189035, [15]=189035, [16]=189035 } },
                { id = 207928, slot = "Legs", name = "Leggings of the New Dawn", sources = { [14]=189012, [15]=189012, [16]=189012 } },
                { id = 207978, slot = "Off-hand", name = "Murozond's Timeless Scale", sources = { [14]=189046, [15]=189046, [16]=189046 } },
                { id = 207945, slot = "Shoulder", name = "Chrono-Lord's Wingspan", sources = { [14]=189029, [15]=189029, [16]=189029 } },
                { id = 207987, slot = "Two-Hand", name = "Borrowed Time", sources = { [14]=189055, [15]=189055, [16]=189055 } },
                { id = 207874, slot = "Waist", name = "Belt of the Eternal Struggle", sources = { [14]=188958, [15]=188958, [16]=188958 } },
            },
            specialLoot = {
                { id = 208216, kind = "mount", name = "Reins of the Quantum Courser", mythicOnly = true },
            },
        },
    },
}
