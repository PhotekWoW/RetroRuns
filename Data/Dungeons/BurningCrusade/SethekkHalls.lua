-------------------------------------------------------------------------------
-- RetroRuns Data -- Sethekk Halls
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 556  |  journalInstanceID: 252
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[252] = {
    kind              = "dungeon",
    instanceID        = 556,
    journalInstanceID = 252,
    name              = "Sethekk Halls",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Darkweaver Syth",
            journalEncounterID = 541,
            achievements       = {
            },
            loot = {
                { id = 27919, slot = "Feet", name = "Light-Woven Slippers", sources = { [14]=12156 } },
                { id = 27914, slot = "Feet", name = "Moonstrider Boots", sources = { [14]=12152 } },
                { id = 27915, slot = "Feet", name = "Sky-Hunter Swift Boots", sources = { [14]=12153 } },
                { id = 27918, slot = "Wrist", name = "Bands of Syth", sources = { [14]=12155 } },
            },
        },
        {
            index              = 2,
            name               = "Anzu",
            journalEncounterID = 542,
            achievements       = {
            },
            loot = {
                { id = 32778, slot = "Feet", name = "Boots of Righteous Fortitude", sources = { [14]=15089 } },
                { id = 27936, slot = "Legs", name = "Greaves of Desolation", sources = { [14]=12162 } },
                { id = 32780, slot = "Ranged", name = "The Boomstick", sources = { [14]=15090 } },
                { id = 32769, slot = "Waist", name = "Belt of the Raven Lord", sources = { [14]=15087 } },
                { id = 32781, slot = "Weapon", name = "Talon of Anzu", sources = { [14]=15091 } },
            },
            specialLoot = {
                { id = 32768, kind = "mount", name = "Reins of the Raven Lord" },
            },
        },
        {
            index              = 3,
            name               = "Talon King Ikiss",
            journalEncounterID = 543,
            achievements       = {
                { id = 653, name = "Sethekk Halls" },
                { id = 674, name = "Heroic: Sethekk Halls" },
            },
            loot = {
                { id = 27946, slot = "Back", name = "Avian Cloak of Feathers", sources = { [14]=12167 } },
                { id = 27981, slot = "Back", name = "Sethekk Oracle Cloak", sources = { [14]=12193 } },
                { id = 27875, slot = "Legs", name = "Hallowed Trousers", sources = { [14]=12120 } },
                { id = 27838, slot = "Legs", name = "Incanter's Trousers", sources = { [14]=12097 } },
                { id = 27948, slot = "Legs", name = "Trousers of Oblivion", sources = { [14]=12168 } },
                { id = 27776, slot = "Shoulder", name = "Shoulderpads of Assassination", sources = { [14]=12059 } },
                { id = 32073, slot = "Shoulder", name = "Spaulders of Dementia", sources = { [14]=14750 } },
                { id = 27986, slot = "Two-Hand", name = "Crow Wing Reaper", sources = { [14]=12195 } },
                { id = 29355, slot = "Two-Hand", name = "Terokk's Shadowstaff", sources = { [14]=13099 } },
                { id = 27985, slot = "Waist", name = "Deathforge Girdle", sources = { [14]=12194 } },
                { id = 27980, slot = "Weapon", name = "Terokk's Nightmace", sources = { [14]=12192 } },
                { id = 29249, slot = "Wrist", name = "Bands of the Benevolent", sources = { [14]=13044 } },
                { id = 29259, slot = "Wrist", name = "Bracers of the Hunt", sources = { [14]=13053 } },
            },
        },
    },
}
