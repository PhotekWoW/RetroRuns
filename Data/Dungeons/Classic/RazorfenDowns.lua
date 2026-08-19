-------------------------------------------------------------------------------
-- RetroRuns Data -- Razorfen Downs
-- Classic dungeon, Patch 1.0  |  instanceID: 129  |  journalInstanceID: 233
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[233] = {
    kind              = "dungeon",
    instanceID        = 129,
    journalInstanceID = 233,
    name              = "Razorfen Downs",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Aarux",
            journalEncounterID = 1142,
            achievements       = {
            },
            loot = {
                { id = 10776, slot = "Back", name = "Silky Spider Cape", sources = { [14]=4083 } },
                { id = 10775, slot = "Chest", name = "Carapace of Tuten'kash", sources = { [14]=4082 } },
                { id = 10777, slot = "Hands", name = "Arachnid Gloves", sources = { [14]=4084 } },
            },
        },
        {
            index              = 2,
            name               = "Mordresh Fire Eye",
            journalEncounterID = 433,
            achievements       = {
            },
            loot = {
                { id = 10770, slot = "Off-hand", name = "Mordresh's Lifeless Skull", sources = { [14]=4078 } },
                { id = 10771, slot = "Waist", name = "Deathmage Sash", sources = { [14]=4079 } },
            },
        },
        {
            index              = 3,
            name               = "Mushlump",
            journalEncounterID = 1143,
            achievements       = {
            },
            loot = {
                { id = 10774, slot = "Shoulder", name = "Fleshhide Shoulders", sources = { [14]=4081 } },
                { id = 10772, slot = "Weapon", name = "Glutton's Cleaver", sources = { [14]=4080 } },
            },
        },
        {
            index              = 4,
            name               = "Death Speaker Blackthorn",
            journalEncounterID = 1146,
            achievements       = {
            },
            loot = {
                { id = 151454, slot = "Feet", name = "Splinterbone Sabatons", sources = { [14]=89450 } },
                { id = 10760, slot = "Hands", name = "Swine Fists", sources = { [14]=4069 } },
                { id = 10767, slot = "Off-hand", name = "Savage Boar's Guard", sources = { [14]=4076 } },
                { id = 10766, slot = "Ranged", name = "Plaguerot Sprig", sources = { [14]=4075 } },
                { id = 10758, slot = "Two-Hand", name = "X'caliboar", sources = { [14]=4068 } },
                { id = 10768, slot = "Waist", name = "Boar Champion's Belt", sources = { [14]=4077 } },
            },
        },
        {
            index              = 5,
            name               = "Amnennar the Coldbringer",
            journalEncounterID = 1141,
            achievements       = {
                { id = 636, name = "Razorfen Downs" },
            },
            loot = {
                { id = 10764, slot = "Chest", name = "Deathchill Armor", sources = { [14]=4073 } },
                { id = 10762, slot = "Chest", name = "Robes of the Lich", sources = { [14]=4071 } },
                { id = 10765, slot = "Hands", name = "Bonefingers", sources = { [14]=4074 } },
                { id = 10763, slot = "Head", name = "Icemetal Barbute", sources = { [14]=4072 } },
                { id = 10761, slot = "Weapon", name = "Coldrage Dagger", sources = { [14]=4070 } },
            },
        },
    },
}
