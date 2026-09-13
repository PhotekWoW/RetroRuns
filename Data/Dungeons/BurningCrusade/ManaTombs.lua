-------------------------------------------------------------------------------
-- RetroRuns Data -- Mana-Tombs
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 557  |  journalInstanceID: 250
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[250] = {
    kind              = "dungeon",
    instanceID        = 557,
    journalInstanceID = 250,
    name              = "Mana-Tombs",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    timewalking       = true,

    entrance = {
        mapID = 108,
        x     = 0.3964,
        y     = 0.5745,
    },

    bosses = {
        {
            index              = 1,
            name               = "Pandemonius",
            journalEncounterID = 534,
            achievements       = {
            },
            loot = {
                { id = 27818, slot = "Chest", name = "Starry Robes of the Crescent", sources = { [14]=12085, [15]=12085 }, twSource = 72452 },
                { id = 27813, slot = "Feet", name = "Boots of the Colossus", sources = { [14]=12081, [15]=12081 }, twSource = 72448 },
                { id = 25941, slot = "Feet", name = "Boots of the Outlander", sources = { [14]=10653, [15]=10653 }, twSource = 72434 },
                { id = 25942, slot = "Hands", name = "Faith Bearer's Gauntlets", sources = { [14]=10654, [15]=10654 }, twSource = 72435 },
                { id = 28166, slot = "Off-hand", name = "Shield of the Void", sources = { [14]=12290, [15]=12290 }, twSource = 72467 },
                { id = 27817, slot = "Ranged", name = "Starbolt Longbow", sources = { [14]=12084, [15]=12084 }, twSource = 72451 },
                { id = 25939, slot = "Ranged", name = "Voidfire Wand", sources = { [14]=10652, [15]=10652 }, twSource = 72433 },
                { id = 27816, slot = "Shoulder", name = "Mindrage Pauldrons", sources = { [14]=12083, [15]=12083 }, twSource = 72450 },
                { id = 25943, slot = "Weapon", name = "Creepjacker", sources = { [14]=10655, [15]=10655 }, twSource = 72436 },
                { id = 27814, slot = "Weapon", name = "Twinblade of Mastery", sources = { [14]=12082, [15]=12082 }, twSource = 72449 },
            },
        },
        {
            index              = 2,
            name               = "Tavarok",
            journalEncounterID = 535,
            achievements       = {
            },
            loot = {
                { id = 25945, slot = "Back", name = "Cloak of Revival", sources = { [14]=10657, [15]=10657 }, twSource = 72438 },
                { id = 27824, slot = "Chest", name = "Robe of the Great Dark Beyond", sources = { [14]=12088, [15]=12088 }, twSource = 72455 },
                { id = 27823, slot = "Chest", name = "Shard Encrusted Breastplate", sources = { [14]=12087, [15]=12087 }, twSource = 72454 },
                { id = 27821, slot = "Feet", name = "Extravagant Boots of Malice", sources = { [14]=12086, [15]=12086 }, twSource = 72453 },
                { id = 25946, slot = "Feet", name = "Nethershade Boots", sources = { [14]=10658, [15]=10658 }, twSource = 72439 },
                { id = 27825, slot = "Hands", name = "Predatory Gloves", sources = { [14]=12089, [15]=12089 }, twSource = 72456 },
                { id = 25947, slot = "Shoulder", name = "Lightning-Rod Pauldrons", sources = { [14]=10659, [15]=10659 }, twSource = 72440 },
                { id = 27826, slot = "Shoulder", name = "Mantle of the Sea Wolf", sources = { [14]=12090, [15]=12090 }, twSource = 72457 },
                { id = 25944, slot = "Two-Hand", name = "Shaarde the Greater", sources = { [14]=10656, [15]=10656 }, twSource = 72437 },
                { id = 25950, slot = "Two-Hand", name = "Staff of Polarities", sources = { [14]=10662, [15]=10662 }, twSource = 72441 },
                { id = 25952, slot = "Weapon", name = "Scimitar of the Nexus-Stalkers", sources = { [14]=10664, [15]=10664 }, twSource = 72442 },
            },
        },
        {
            index              = 3,
            name               = "Yor",
            journalEncounterID = 536,
            achievements       = {
            },
            loot = {
                { id = 31570, slot = "Chest", name = "Mistshroud Tunic", sources = { [15]=14481 }, twSource = 72554 },
                { id = 31562, slot = "Chest", name = "Skystalker's Tunic", sources = { [15]=14473 }, twSource = 72553 },
                { id = 31578, slot = "Chest", name = "Slatesteel Breastplate", sources = { [15]=14489 }, twSource = 72555 },
                { id = 31554, slot = "Chest", name = "Windchanneller's Tunic", sources = { [15]=14465 }, twSource = 72552 },
            },
        },
        {
            index              = 4,
            name               = "Nexus-Prince Shaffar",
            journalEncounterID = 537,
            achievements       = {
            },
            loot = {
                { id = 25957, slot = "Feet", name = "Ethereal Boots of the Skystrider", sources = { [14]=10668, [15]=10668 }, twSource = 72446 },
                { id = 27798, slot = "Hands", name = "Gauntlets of Vindication", sources = { [14]=12073, [15]=12073 }, twSource = 72447 },
                { id = 25955, slot = "Head", name = "Mask of the Howling Storm", sources = { [14]=10666, [15]=10666 }, twSource = 72444 },
                { id = 30535, slot = "Legs", name = "Forestwalker Kilt", sources = { [14]=13808, [15]=13808 }, twSource = 72470 },
                { id = 27837, slot = "Legs", name = "Wastewalker Leggings", sources = { [14]=12096, [15]=12096 }, twSource = 72462 },
                { id = 32082, slot = "Off-hand", name = "The Fel Barrier", sources = { [14]=14755, [15]=14755 }, twSource = 72471 },
                { id = 25953, slot = "Ranged", name = "Ethereal Warp-Bow", sources = { [14]=10665, [15]=10665 }, twSource = 72443 },
                { id = 27831, slot = "Shoulder", name = "Mantle of the Unforgiven", sources = { [14]=12093, [15]=12093 }, twSource = 72460 },
                { id = 27844, slot = "Shoulder", name = "Pauldrons of Swift Retribution", sources = { [14]=12102, [15]=12102 }, twSource = 72466 },
                { id = 27829, slot = "Two-Hand", name = "Axe of the Nexus-Kings", sources = { [14]=12092, [15]=12092 }, twSource = 72459 },
                { id = 27842, slot = "Two-Hand", name = "Grand Scepter of the Nexus-Kings", sources = { [14]=12100, [15]=12100 }, twSource = 72464 },
                { id = 27840, slot = "Two-Hand", name = "Scepter of Sha'tar", sources = { [14]=12099, [15]=12099 }, twSource = 72463 },
                { id = 27843, slot = "Waist", name = "Glyph-Lined Sash", sources = { [14]=12101, [15]=12101 }, twSource = 72465 },
                { id = 27835, slot = "Waist", name = "Stillwater Girdle", sources = { [14]=12094, [15]=12094 }, twSource = 72461 },
                { id = 28400, slot = "Weapon", name = "Warp-Storm Warblade", sources = { [14]=12445, [15]=12445 }, twSource = 72468 },
                { id = 29240, slot = "Wrist", name = "Bands of Negation", sources = { [14]=13035, [15]=13035 }, twSource = 72469 },
                { id = 27827, slot = "Wrist", name = "Lucid Dream Bracers", sources = { [14]=12091, [15]=12091 }, twSource = 72458 },
                { id = 25956, slot = "Wrist", name = "Nexus-Bracers of Vigor", sources = { [14]=10667, [15]=10667 }, twSource = 72445 },
            },
        },
    },
}
