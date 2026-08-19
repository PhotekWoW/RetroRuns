-------------------------------------------------------------------------------
-- RetroRuns Data -- The Slave Pens
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 547  |  journalInstanceID: 260
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[260] = {
    kind              = "dungeon",
    instanceID        = 547,
    journalInstanceID = 260,
    name              = "The Slave Pens",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Mennu the Betrayer",
            journalEncounterID = 570,
            achievements       = {
            },
            loot = {
                { id = 24357, slot = "Chest", name = "Vest of Living Lightning", sources = { [14]=9514 } },
                { id = 27545, slot = "Legs", name = "Mennu's Scaled Leggings", sources = { [14]=11972 } },
                { id = 24359, slot = "Legs", name = "Princely Reign Leggings", sources = { [14]=9515 } },
                { id = 27541, slot = "Waist", name = "Archery Belt of the Broken", sources = { [14]=11969 } },
                { id = 27542, slot = "Waist", name = "Cord of Belief", sources = { [14]=11970 } },
                { id = 24360, slot = "Waist", name = "Tracker's Belt", sources = { [14]=9516 } },
                { id = 24361, slot = "Weapon", name = "Spellfire Longsword", sources = { [14]=9517 } },
                { id = 27543, slot = "Weapon", name = "Starlight Dagger", sources = { [14]=11971 } },
                { id = 24356, slot = "Weapon", name = "Wastewalker Shiv", sources = { [14]=9513 } },
            },
        },
        {
            index              = 2,
            name               = "Rokmar the Crackler",
            journalEncounterID = 571,
            achievements       = {
            },
            loot = {
                { id = 24379, slot = "Back", name = "Bogstrok Scale Cloak", sources = { [14]=9524 } },
                { id = 27550, slot = "Back", name = "Ironscale War Cloak", sources = { [14]=11976 } },
                { id = 27549, slot = "Feet", name = "Wavefury Boots", sources = { [14]=11975 } },
                { id = 24380, slot = "Ranged", name = "Calming Spore Reed", sources = { [14]=9525 } },
                { id = 24381, slot = "Ranged", name = "Coilfang Needler", sources = { [14]=9526 } },
                { id = 27547, slot = "Waist", name = "Coldwhisper Cord", sources = { [14]=11973 } },
                { id = 27548, slot = "Waist", name = "Girdle of Many Blessings", sources = { [14]=11974 } },
                { id = 28124, slot = "Waist", name = "Liar's Cord", sources = { [14]=12252 } },
                { id = 24378, slot = "Weapon", name = "Coilfang Hammer of Renewal", sources = { [14]=9523 } },
            },
        },
        {
            index              = 3,
            name               = "Quagmirran",
            journalEncounterID = 572,
            achievements       = {
                { id = 649, name = "The Slave Pens" },
                { id = 669, name = "Heroic: The Slave Pens" },
            },
            loot = {
                { id = 24362, slot = "Back", name = "Spore-Soaked Vaneer", sources = { [14]=9518 } },
                { id = 28337, slot = "Chest", name = "Breastplate of Righteous Fury", sources = { [14]=12406 } },
                { id = 24363, slot = "Chest", name = "Unscarred Breastplate", sources = { [14]=9519 } },
                { id = 29242, slot = "Feet", name = "Boots of Blasphemy", sources = { [14]=13037 } },
                { id = 24365, slot = "Hands", name = "Deft Handguards", sources = { [14]=9521 } },
                { id = 24364, slot = "Legs", name = "Azureplate Greaves", sources = { [14]=9520 } },
                { id = 27800, slot = "Legs", name = "Earthsoul Britches", sources = { [14]=12075 } },
                { id = 30538, slot = "Legs", name = "Midnight Legguards", sources = { [14]=13810 } },
                { id = 27714, slot = "Off-hand", name = "Swamplight Lantern", sources = { [14]=12010 } },
                { id = 27796, slot = "Shoulder", name = "Mana-Etched Spaulders", sources = { [14]=12071 } },
                { id = 27713, slot = "Shoulder", name = "Pauldrons of Desolation", sources = { [14]=12009 } },
                { id = 32078, slot = "Shoulder", name = "Pauldrons of Wild Magic", sources = { [14]=14753 } },
                { id = 24366, slot = "Shoulder", name = "Scorpid-Sting Mantle", sources = { [14]=9522 } },
                { id = 27672, slot = "Waist", name = "Girdle of the Immovable", sources = { [14]=11995 } },
                { id = 27742, slot = "Waist", name = "Mage-Fury Girdle", sources = { [14]=12032 } },
                { id = 27741, slot = "Weapon", name = "Bleeding Hollow Warhammer", sources = { [14]=12031 } },
                { id = 27673, slot = "Weapon", name = "Phosphorescent Blade", sources = { [14]=11996 } },
                { id = 27712, slot = "Wrist", name = "Shackles of Quagmirran", sources = { [14]=12008 } },
            },
        },
    },
}
