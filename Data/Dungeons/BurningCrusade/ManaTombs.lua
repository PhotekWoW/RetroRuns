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
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Pandemonius",
            journalEncounterID = 534,
            achievements       = {
            },
            loot = {
                { id = 27818, slot = "Chest", name = "Starry Robes of the Crescent", sources = { [14]=12085 } },
                { id = 27813, slot = "Feet", name = "Boots of the Colossus", sources = { [14]=12081 } },
                { id = 25941, slot = "Feet", name = "Boots of the Outlander", sources = { [14]=10653 } },
                { id = 25942, slot = "Hands", name = "Faith Bearer's Gauntlets", sources = { [14]=10654 } },
                { id = 28166, slot = "Off-hand", name = "Shield of the Void", sources = { [14]=12290 } },
                { id = 27817, slot = "Ranged", name = "Starbolt Longbow", sources = { [14]=12084 } },
                { id = 25939, slot = "Ranged", name = "Voidfire Wand", sources = { [14]=10652 } },
                { id = 27816, slot = "Shoulder", name = "Mindrage Pauldrons", sources = { [14]=12083 } },
                { id = 25943, slot = "Weapon", name = "Creepjacker", sources = { [14]=10655 } },
                { id = 27814, slot = "Weapon", name = "Twinblade of Mastery", sources = { [14]=12082 } },
            },
        },
        {
            index              = 2,
            name               = "Tavarok",
            journalEncounterID = 535,
            achievements       = {
            },
            loot = {
                { id = 25945, slot = "Back", name = "Cloak of Revival", sources = { [14]=10657 } },
                { id = 27824, slot = "Chest", name = "Robe of the Great Dark Beyond", sources = { [14]=12088 } },
                { id = 27823, slot = "Chest", name = "Shard Encrusted Breastplate", sources = { [14]=12087 } },
                { id = 27821, slot = "Feet", name = "Extravagant Boots of Malice", sources = { [14]=12086 } },
                { id = 25946, slot = "Feet", name = "Nethershade Boots", sources = { [14]=10658 } },
                { id = 27825, slot = "Hands", name = "Predatory Gloves", sources = { [14]=12089 } },
                { id = 25947, slot = "Shoulder", name = "Lightning-Rod Pauldrons", sources = { [14]=10659 } },
                { id = 27826, slot = "Shoulder", name = "Mantle of the Sea Wolf", sources = { [14]=12090 } },
                { id = 25944, slot = "Two-Hand", name = "Shaarde the Greater", sources = { [14]=10656 } },
                { id = 25950, slot = "Two-Hand", name = "Staff of Polarities", sources = { [14]=10662 } },
                { id = 25952, slot = "Weapon", name = "Scimitar of the Nexus-Stalkers", sources = { [14]=10664 } },
            },
        },
        {
            index              = 3,
            name               = "Yor",
            journalEncounterID = 536,
            achievements       = {
            },
            loot = {
                { id = 31570, slot = "Chest", name = "Mistshroud Tunic", sources = { [14]=14481 } },
                { id = 31562, slot = "Chest", name = "Skystalker's Tunic", sources = { [14]=14473 } },
                { id = 31578, slot = "Chest", name = "Slatesteel Breastplate", sources = { [14]=14489 } },
                { id = 31554, slot = "Chest", name = "Windchanneller's Tunic", sources = { [14]=14465 } },
            },
        },
        {
            index              = 4,
            name               = "Nexus-Prince Shaffar",
            journalEncounterID = 537,
            achievements       = {
                { id = 651, name = "Mana-Tombs" },
                { id = 671, name = "Heroic: Mana-Tombs" },
            },
            loot = {
                { id = 25957, slot = "Feet", name = "Ethereal Boots of the Skystrider", sources = { [14]=10668 } },
                { id = 27798, slot = "Hands", name = "Gauntlets of Vindication", sources = { [14]=12073 } },
                { id = 25955, slot = "Head", name = "Mask of the Howling Storm", sources = { [14]=10666 } },
                { id = 30535, slot = "Legs", name = "Forestwalker Kilt", sources = { [14]=13808 } },
                { id = 27837, slot = "Legs", name = "Wastewalker Leggings", sources = { [14]=12096 } },
                { id = 32082, slot = "Off-hand", name = "The Fel Barrier", sources = { [14]=14755 } },
                { id = 25953, slot = "Ranged", name = "Ethereal Warp-Bow", sources = { [14]=10665 } },
                { id = 27831, slot = "Shoulder", name = "Mantle of the Unforgiven", sources = { [14]=12093 } },
                { id = 27844, slot = "Shoulder", name = "Pauldrons of Swift Retribution", sources = { [14]=12102 } },
                { id = 27829, slot = "Two-Hand", name = "Axe of the Nexus-Kings", sources = { [14]=12092 } },
                { id = 27842, slot = "Two-Hand", name = "Grand Scepter of the Nexus-Kings", sources = { [14]=12100 } },
                { id = 27840, slot = "Two-Hand", name = "Scepter of Sha'tar", sources = { [14]=12099 } },
                { id = 27843, slot = "Waist", name = "Glyph-Lined Sash", sources = { [14]=12101 } },
                { id = 27835, slot = "Waist", name = "Stillwater Girdle", sources = { [14]=12094 } },
                { id = 28400, slot = "Weapon", name = "Warp-Storm Warblade", sources = { [14]=12445 } },
                { id = 29240, slot = "Wrist", name = "Bands of Negation", sources = { [14]=13035 } },
                { id = 27827, slot = "Wrist", name = "Lucid Dream Bracers", sources = { [14]=12091 } },
                { id = 25956, slot = "Wrist", name = "Nexus-Bracers of Vigor", sources = { [14]=10667 } },
            },
        },
    },
}
