-------------------------------------------------------------------------------
-- RetroRuns Data -- Hellfire Ramparts
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 543  |  journalInstanceID: 248
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[248] = {
    kind              = "dungeon",
    instanceID        = 543,
    journalInstanceID = 248,
    name              = "Hellfire Ramparts",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Watchkeeper Gargolmar",
            journalEncounterID = 527,
            achievements       = {
            },
            loot = {
                { id = 27448, slot = "Back", name = "Cloak of the Everliving", sources = { [14]=11899 } },
                { id = 24021, slot = "Chest", name = "Light-Touched Breastplate", sources = { [14]=9420 } },
                { id = 27451, slot = "Feet", name = "Boots of the Darkwalker", sources = { [14]=11902 } },
                { id = 27450, slot = "Feet", name = "Wild Stalker Boots", sources = { [14]=11901 } },
                { id = 24022, slot = "Legs", name = "Scale Leggings of the Skirmisher", sources = { [14]=9421 } },
                { id = 27449, slot = "Off-hand", name = "Blood Knight Defender", sources = { [14]=11900 } },
                { id = 24024, slot = "Shoulder", name = "Pauldrons of Arcane Rage", sources = { [14]=9423 } },
                { id = 24020, slot = "Weapon", name = "Shadowrend Longblade", sources = { [14]=9419 } },
                { id = 24023, slot = "Wrist", name = "Bracers of Finesse", sources = { [14]=9422 } },
                { id = 27447, slot = "Wrist", name = "Bracers of Just Rewards", sources = { [14]=11898 } },
            },
        },
        {
            index              = 2,
            name               = "Omor the Unscarred",
            journalEncounterID = 528,
            achievements       = {
                { id = 647, name = "Hellfire Ramparts" },
            },
            loot = {
                { id = 27906, slot = "Chest", name = "Crimsonforge Breastplate", sources = { [14]=12144 } },
                { id = 27467, slot = "Feet", name = "Silent-Strider Kneeboots", sources = { [14]=11915 } },
                { id = 24090, slot = "Hands", name = "Bloodstained Ravager Gauntlets", sources = { [14]=9433 } },
                { id = 27465, slot = "Hands", name = "Mana-Etched Gloves", sources = { [14]=11913 } },
                { id = 27466, slot = "Head", name = "Headdress of Alacrity", sources = { [14]=11914 } },
                { id = 27477, slot = "Off-hand", name = "Faol's Signet of Cleansing", sources = { [14]=11925 } },
                { id = 27539, slot = "Shoulder", name = "Justice Bearer's Pauldrons", sources = { [14]=11967 } },
                { id = 24069, slot = "Two-Hand", name = "Crystalfire Staff", sources = { [14]=9430 } },
                { id = 24094, slot = "Two-Hand", name = "Heart Fire Warhammer", sources = { [14]=9435 } },
                { id = 27478, slot = "Waist", name = "Girdle of the Blasted Reaches", sources = { [14]=11926 } },
                { id = 24091, slot = "Waist", name = "Tenacious Defender", sources = { [14]=9434 } },
                { id = 27463, slot = "Weapon", name = "Terror Flame Dagger", sources = { [14]=11912 } },
                { id = 27476, slot = "Weapon", name = "Truncheon of Five Hells", sources = { [14]=11924 } },
                { id = 27462, slot = "Wrist", name = "Crimson Bracers of Gloom", sources = { [14]=11911 } },
            },
        },
        {
            index              = 3,
            name               = "Vazruden the Herald",
            journalEncounterID = 529,
            achievements       = {
                { id = 667, name = "Heroic: Hellfire Ramparts" },
            },
            loot = {
                { id = 24150, slot = "Back", name = "Mok'Nathal Wildercloak", sources = { [14]=9462 } },
                { id = 27461, slot = "Chest", name = "Chestguard of the Prowler", sources = { [14]=11910 } },
                { id = 27456, slot = "Chest", name = "Raiments of Nature's Breath", sources = { [14]=11906 } },
                { id = 24064, slot = "Feet", name = "Ironsole Clompers", sources = { [14]=9429 } },
                { id = 27457, slot = "Hands", name = "Life Bearer's Gauntlets", sources = { [14]=11907 } },
                { id = 32077, slot = "Hands", name = "Wrath-Infused Gauntlets", sources = { [14]=14752 } },
                { id = 27455, slot = "Head", name = "Irondrake Faceguard", sources = { [14]=11905 } },
                { id = 24046, slot = "Legs", name = "Kilt of Rolling Thunders", sources = { [14]=9427 } },
                { id = 24083, slot = "Legs", name = "Lifegiver Britches", sources = { [14]=9432 } },
                { id = 27458, slot = "Legs", name = "Oceansong Kilt", sources = { [14]=11908 } },
                { id = 27454, slot = "Shoulder", name = "Volcanic Pauldrons", sources = { [14]=11904 } },
                { id = 24044, slot = "Two-Hand", name = "Hellreaver", sources = { [14]=9426 } },
                { id = 24155, slot = "Two-Hand", name = "Ursol's Claw", sources = { [14]=9463 } },
                { id = 29238, slot = "Waist", name = "Lion's Heart Girdle", sources = { [14]=13033 } },
                { id = 24063, slot = "Waist", name = "Shifting Sash of Midnight", sources = { [14]=9428 } },
                { id = 29264, slot = "Waist", name = "Tree-Mender's Belt", sources = { [14]=13057 } },
                { id = 29346, slot = "Weapon", name = "Feltooth Eviscerator", sources = { [14]=13093 } },
                { id = 27452, slot = "Wrist", name = "Light Scribe Bands", sources = { [14]=11903 } },
                { id = 27459, slot = "Wrist", name = "Vambraces of Daring", sources = { [14]=11909 } },
            },
        },
    },
}
