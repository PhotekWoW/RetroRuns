-------------------------------------------------------------------------------
-- RetroRuns Data -- Auchenai Crypts
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 558  |  journalInstanceID: 247
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[247] = {
    kind              = "dungeon",
    instanceID        = 558,
    journalInstanceID = 247,
    name              = "Auchenai Crypts",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Shirrak the Dead Watcher",
            journalEncounterID = 523,
            achievements       = {
            },
            loot = {
                { id = 27845, slot = "Feet", name = "Magma Plume Boots", sources = { [14]=12103 } },
                { id = 27493, slot = "Hands", name = "Gloves of the Deadwatcher", sources = { [14]=11935 } },
                { id = 27410, slot = "Head", name = "Collar of Command", sources = { [14]=11881 } },
                { id = 27408, slot = "Head", name = "Hope Bearer Helm", sources = { [14]=11879 } },
                { id = 27409, slot = "Head", name = "Raven-Heart Headdress", sources = { [14]=11880 } },
                { id = 27866, slot = "Head", name = "Scintillating Headdress of Second Sight", sources = { [14]=12113 } },
                { id = 27847, slot = "Shoulder", name = "Fanblade Pauldrons", sources = { [14]=12105 } },
                { id = 27846, slot = "Weapon", name = "Claw of the Watcher", sources = { [14]=12104 } },
                { id = 25964, slot = "Weapon", name = "Shaarde the Lesser", sources = { [14]=10673 } },
                { id = 27865, slot = "Wrist", name = "Bracers of Shirrak", sources = { [14]=12112 } },
            },
        },
        {
            index              = 2,
            name               = "Exarch Maladaar",
            journalEncounterID = 524,
            achievements       = {
                { id = 666, name = "Auchenai Crypts" },
                { id = 672, name = "Heroic: Auchenai Crypts" },
            },
            loot = {
                { id = 29354, slot = "Back", name = "Light-Touched Stole of Altruism", sources = { [14]=13098 } },
                { id = 27867, slot = "Feet", name = "Boots of the Unjust", sources = { [14]=12114 } },
                { id = 27411, slot = "Feet", name = "Slippers of Serenity", sources = { [14]=11882 } },
                { id = 27415, slot = "Head", name = "Darkguard Face Mask", sources = { [14]=11885 } },
                { id = 27414, slot = "Head", name = "Mok'Nathal Beast-Mask", sources = { [14]=11884 } },
                { id = 27870, slot = "Legs", name = "Doomplate Legguards", sources = { [14]=12116 } },
                { id = 27412, slot = "Two-Hand", name = "Ironstaff of Regeneration", sources = { [14]=11883 } },
                { id = 29257, slot = "Waist", name = "Sash of Arcane Visions", sources = { [14]=13051 } },
                { id = 29244, slot = "Waist", name = "Wave-Song Girdle", sources = { [14]=13039 } },
                { id = 27872, slot = "Weapon", name = "The Harvester of Souls", sources = { [14]=12117 } },
            },
        },
    },
}
