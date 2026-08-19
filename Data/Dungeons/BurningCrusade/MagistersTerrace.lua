-------------------------------------------------------------------------------
-- RetroRuns Data -- Magisters' Terrace
-- Burning Crusade dungeon, Patch 2.4.0  |  instanceID: 585  |  journalInstanceID: 249
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[249] = {
    kind              = "dungeon",
    instanceID        = 585,
    journalInstanceID = 249,
    name              = "Magisters' Terrace",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.4.0",

    bosses = {
        {
            index              = 1,
            name               = "Selin Fireheart",
            journalEncounterID = 530,
            achievements       = {
            },
            loot = {
                { id = 34702, slot = "Back", name = "Cloak of Swift Mending", sources = { [14]=16120 } },
                { id = 34700, slot = "Hands", name = "Gauntlets of Divine Blessings", sources = { [14]=16118 } },
                { id = 34701, slot = "Legs", name = "Leggings of the Betrayed", sources = { [14]=16119 } },
                { id = 34601, slot = "Shoulder", name = "Shoulderplates of Everlasting Pain", sources = { [14]=16065 } },
                { id = 34604, slot = "Weapon", name = "Jaded Crystal Dagger", sources = { [14]=16068 } },
                { id = 34699, slot = "Weapon", name = "Sun-Forged Cleaver", sources = { [14]=16117 } },
                { id = 34697, slot = "Wrist", name = "Bindings of Raging Fire", sources = { [14]=16115 } },
                { id = 34698, slot = "Wrist", name = "Bracers of the Forest Stalker", sources = { [14]=16116 } },
                { id = 34602, slot = "Wrist", name = "Eversong Cuffs", sources = { [14]=16066 } },
            },
        },
        {
            index              = 2,
            name               = "Vexallus",
            journalEncounterID = 531,
            achievements       = {
            },
            loot = {
                { id = 34708, slot = "Back", name = "Cloak of the Coming Night", sources = { [14]=16124 } },
                { id = 34605, slot = "Chest", name = "Breastplate of Fierce Survival", sources = { [14]=16069 } },
                { id = 34707, slot = "Feet", name = "Boots of Resuscitation", sources = { [14]=16123 } },
                { id = 34607, slot = "Shoulder", name = "Fel-Tinged Mantle", sources = { [14]=16071 } },
                { id = 34608, slot = "Two-Hand", name = "Rod of the Blazing Light", sources = { [14]=16072 } },
                { id = 34606, slot = "Weapon", name = "Edge of Oppression", sources = { [14]=16070 } },
                { id = 34703, slot = "Weapon", name = "Latro's Dancing Blade", sources = { [14]=16121 } },
                { id = 34705, slot = "Wrist", name = "Bracers of Divine Infusion", sources = { [14]=16122 } },
            },
        },
        {
            index              = 3,
            name               = "Priestess Delrissa",
            journalEncounterID = 532,
            achievements       = {
            },
            loot = {
                { id = 34792, slot = "Back", name = "Cloak of the Betrayed", sources = { [14]=16136 } },
                { id = 34791, slot = "Hands", name = "Gauntlets of the Tranquil Waves", sources = { [14]=16135 } },
                { id = 34788, slot = "Shoulder", name = "Duskhallow Mantle", sources = { [14]=16132 } },
                { id = 34790, slot = "Weapon", name = "Battle-Mace of the High Priestess", sources = { [14]=16134 } },
                { id = 34789, slot = "Wrist", name = "Bracers of Slaughter", sources = { [14]=16133 } },
            },
        },
        {
            index              = 4,
            name               = "Kael'thas Sunstrider",
            journalEncounterID = 533,
            achievements       = {
                { id = 682, name = "Heroic: Magister's Terrace" },
            },
            loot = {
                { id = 34810, slot = "Back", name = "Cloak of Blade Turning", sources = { [14]=16146 } },
                { id = 34799, slot = "Chest", name = "Hauberk of the War Bringer", sources = { [14]=16142 } },
                { id = 34615, slot = "Chest", name = "Netherforce Chestplate", sources = { [14]=16079 } },
                { id = 34796, slot = "Chest", name = "Robes of Summer Flame", sources = { [14]=16140 } },
                { id = 34610, slot = "Chest", name = "Scarlet Sin'dorei Robes", sources = { [14]=16074 } },
                { id = 34614, slot = "Chest", name = "Tunic of the Ranger Lord", sources = { [14]=16078 } },
                { id = 34612, slot = "Feet", name = "Greaves of the Penitent Knight", sources = { [14]=16076 } },
                { id = 34809, slot = "Feet", name = "Sunrage Treads", sources = { [14]=16145 } },
                { id = 34807, slot = "Feet", name = "Sunstrider Warboots", sources = { [14]=16143 } },
                { id = 34808, slot = "Hands", name = "Gloves of Arcane Acuity", sources = { [14]=16144 } },
                { id = 34795, slot = "Head", name = "Helm of Sanctification", sources = { [14]=16139 } },
                { id = 34613, slot = "Shoulder", name = "Shoulderpads of the Silvermoon Retainer", sources = { [14]=16077 } },
                { id = 34794, slot = "Two-Hand", name = "Axe of Shattered Dreams", sources = { [14]=16138 } },
                { id = 34797, slot = "Two-Hand", name = "Sun-Infused Focus Staff", sources = { [14]=16141 } },
                { id = 34793, slot = "Waist", name = "Cord of Reconstruction", sources = { [14]=16137 } },
                { id = 34616, slot = "Weapon", name = "Breeching Comet", sources = { [14]=16080 } },
                { id = 34611, slot = "Weapon", name = "Cudgel of Consecration", sources = { [14]=16075 } },
                { id = 34609, slot = "Weapon", name = "Quickening Blade of the Prince", sources = { [14]=16073 } },
            },
            specialLoot = {
                { id = 35513, kind = "mount", name = "Swift White Hawkstrider" },
                { id = 35504, kind = "pet", name = "Phoenix Hatchling" },
                { id = 35275, kind = "toy", name = "Orb of the Sin'dorei" },
            },
        },
    },
}
