-------------------------------------------------------------------------------
-- RetroRuns Data -- Shadow Labyrinth
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 555  |  journalInstanceID: 253
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[253] = {
    kind              = "dungeon",
    instanceID        = 555,
    journalInstanceID = 253,
    name              = "Shadow Labyrinth",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Ambassador Hellmaw",
            journalEncounterID = 544,
            achievements       = {
            },
            loot = {
                { id = 27884, slot = "Feet", name = "Ornate Boots of the Sanctified", sources = { [14]=12129 } },
                { id = 27889, slot = "Hands", name = "Jaedenfire Gloves of Annihilation", sources = { [14]=12133 } },
                { id = 27888, slot = "Head", name = "Dream-Wing Helm", sources = { [14]=12132 } },
                { id = 27908, slot = "Legs", name = "Leggings of Assassination", sources = { [14]=12146 } },
                { id = 27887, slot = "Off-hand", name = "Platinum Shield of the Valorous", sources = { [14]=12131 } },
                { id = 27885, slot = "Ranged", name = "Soul-Wand of the Aldor", sources = { [14]=12130 } },
            },
        },
        {
            index              = 2,
            name               = "Blackheart the Inciter",
            journalEncounterID = 545,
            achievements       = {
            },
            loot = {
                { id = 27892, slot = "Back", name = "Cloak of the Inciter", sources = { [14]=12135 } },
                { id = 27893, slot = "Legs", name = "Ornate Leggings of the Venerated", sources = { [14]=12136 } },
                { id = 27890, slot = "Ranged", name = "Wand of the Netherwing", sources = { [14]=12134 } },
            },
        },
        {
            index              = 3,
            name               = "Grandmaster Vorpil",
            journalEncounterID = 546,
            achievements       = {
            },
            loot = {
                { id = 27897, slot = "Chest", name = "Breastplate of Many Graces", sources = { [14]=12137 } },
                { id = 27468, slot = "Hands", name = "Moonglade Handwraps", sources = { [14]=11916 } },
                { id = 27909, slot = "Legs", name = "Tidefury Kilt", sources = { [14]=12147 } },
                { id = 27898, slot = "Ranged", name = "Wrathfire Hand-Cannon", sources = { [14]=12138 } },
                { id = 27775, slot = "Shoulder", name = "Hallowed Pauldrons", sources = { [14]=12058 } },
                { id = 27901, slot = "Weapon", name = "Blackout Truncheon", sources = { [14]=12140 } },
            },
        },
        {
            index              = 4,
            name               = "Murmur",
            journalEncounterID = 547,
            achievements       = {
                { id = 654, name = "Shadow Labyrinth" },
                { id = 675, name = "Heroic: Shadow Labyrinth" },
            },
            loot = {
                { id = 28230, slot = "Chest", name = "Hallowed Garments", sources = { [14]=12347 } },
                { id = 27912, slot = "Chest", name = "Harness of the Deep Currents", sources = { [14]=12150 } },
                { id = 28232, slot = "Chest", name = "Robe of Oblivion", sources = { [14]=12349 } },
                { id = 27902, slot = "Feet", name = "Silent Slippers of Meditation", sources = { [14]=12141 } },
                { id = 29357, slot = "Hands", name = "Master Thief's Gloves", sources = { [14]=13101 } },
                { id = 30532, slot = "Legs", name = "Kirin Tor Master's Trousers", sources = { [14]=13805 } },
                { id = 27910, slot = "Off-hand", name = "Silvermoon Crest Shield", sources = { [14]=12148 } },
                { id = 27803, slot = "Shoulder", name = "Shoulderguards of the Bold", sources = { [14]=12078 } },
                { id = 27778, slot = "Shoulder", name = "Spaulders of Oblivion", sources = { [14]=12060 } },
                { id = 27903, slot = "Two-Hand", name = "Sonic Spear", sources = { [14]=12142 } },
                { id = 29261, slot = "Waist", name = "Girdle of Ferocity", sources = { [14]=13054 } },
                { id = 27905, slot = "Weapon", name = "Greatsword of Horrid Dreams", sources = { [14]=12143 } },
                { id = 29353, slot = "Weapon", name = "Shockwave Truncheon", sources = { [14]=13097 } },
                { id = 27913, slot = "Weapon", name = "Whispering Blade of Slaying", sources = { [14]=12151 } },
            },
        },
    },
}
