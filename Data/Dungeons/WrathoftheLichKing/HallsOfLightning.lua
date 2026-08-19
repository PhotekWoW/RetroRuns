-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Lightning
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 602  |  journalInstanceID: 275
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[275] = {
    kind              = "dungeon",
    instanceID        = 602,
    journalInstanceID = 275,
    name              = "Halls of Lightning",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.0.2",

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "General Bjarngrim",
            journalEncounterID = 597,
            achievements       = {
                { id = 1834, name = "Lightning Struck", meta = true },
            },
            loot = {
                { id = 37825, slot = "Hands", name = "Traditionally Dyed Handguards", sources = { [14]=18049 } },
                { id = 37818, slot = "Legs", name = "Patroller's War-Kilt", sources = { [14]=18047 } },
                { id = 157580, slot = "Off-hand", name = "Spark of the Forge", sources = { [14]=93771 } },
                { id = 37814, slot = "Shoulder", name = "Iron Dwarf Smith Pauldrons", sources = { [14]=18045 } },
                { id = 36982, slot = "Shoulder", name = "Mantle of Electrical Charges", sources = { [14]=17513 } },
                { id = 36980, slot = "Two-Hand", name = "Hewn Sparring Quarterstaff", sources = { [14]=17511 } },
                { id = 37826, slot = "Waist", name = "The General's Steel Girdle", sources = { [14]=18050 } },
            },
        },
        {
            index              = 2,
            name               = "Volkhan",
            journalEncounterID = 598,
            achievements       = {
                { id = 2042, name = "Shatter Resistant", meta = true },
            },
            loot = {
                { id = 36983, slot = "Back", name = "Cape of Seething Steam", sources = { [14]=17514 } },
                { id = 37840, slot = "Back", name = "Shroud of Reverberation", sources = { [14]=18052 } },
                { id = 37841, slot = "Feet", name = "Slag Footguards", sources = { [14]=18053 } },
                { id = 37843, slot = "Hands", name = "Giant-Hair Woven Gloves", sources = { [14]=18055 } },
                { id = 127525, slot = "Head", name = "Helm of the Lightning Halls", sources = { [14]=72641 }, timewalkingOnly = true },
                { id = 36985, slot = "Head", name = "Volkhan's Hood", sources = { [14]=17516 } },
                { id = 36986, slot = "Legs", name = "Kilt of Molten Golems", sources = { [14]=17517 } },
                { id = 157579, slot = "Legs", name = "Slag-Stained Legplates", sources = { [14]=93770 } },
                { id = 37842, slot = "Waist", name = "Belt of Vivacity", sources = { [14]=18054 } },
                { id = 36984, slot = "Weapon", name = "Eternally Folded Blade", sources = { [14]=17515 } },
            },
        },
        {
            index              = 3,
            name               = "Ionar",
            journalEncounterID = 599,
            achievements       = {
            },
            loot = {
                { id = 37847, slot = "Feet", name = "Skywall Striders", sources = { [14]=18058 } },
                { id = 37846, slot = "Hands", name = "Charged-Bolt Grips", sources = { [14]=18057 } },
                { id = 39536, slot = "Hands", name = "Thundercloud Grasps", sources = { [14]=18942 } },
                { id = 39534, slot = "Shoulder", name = "Pauldrons of the Lightning Revenant", sources = { [14]=18940 } },
                { id = 37845, slot = "Waist", name = "Cord of Swirling Winds", sources = { [14]=18056 } },
                { id = 39535, slot = "Waist", name = "Ionar's Girdle", sources = { [14]=18941 } },
                { id = 39657, slot = "Wrist", name = "Tornado Cuffs", sources = { [14]=19018 } },
            },
        },
        {
            index              = 4,
            name               = "Loken",
            journalEncounterID = 600,
            achievements       = {
                { id = 1867, name = "Timely Death", meta = true },
                { id = 486, name = "Halls of Lightning" },
                { id = 497, name = "Heroic: Halls of Lightning" },
                { id = 39932, name = "Halls of Lightning (char specific hidden copy)" },
            },
            loot = {
                { id = 37851, slot = "Chest", name = "Ornate Woolen Stola", sources = { [14]=18062 } },
                { id = 36991, slot = "Chest", name = "Raiments of the Titans", sources = { [14]=17520 } },
                { id = 36995, slot = "Hands", name = "Fists of Loken", sources = { [14]=17523 } },
                { id = 36996, slot = "Head", name = "Hood of the Furtive Assassin", sources = { [14]=17524 } },
                { id = 37849, slot = "Head", name = "Planetary Helm", sources = { [14]=18060 } },
                { id = 36992, slot = "Legs", name = "Leather-Braced Chain Leggings", sources = { [14]=17521 } },
                { id = 37854, slot = "Legs", name = "Woven Bracae Leggings", sources = { [14]=18065 } },
                { id = 36989, slot = "Ranged", name = "Ancient Measuring Rod", sources = { [14]=17518 } },
                { id = 36994, slot = "Ranged", name = "Projectile Activator", sources = { [14]=17522 } },
                { id = 37852, slot = "Two-Hand", name = "Colossal Skull-Clad Cleaver", sources = { [14]=18063 } },
                { id = 37848, slot = "Two-Hand", name = "Lightning Giant Staff", sources = { [14]=18059 } },
                { id = 37850, slot = "Waist", name = "Flowing Sash of Order", sources = { [14]=18061 } },
                { id = 37855, slot = "Waist", name = "Mail Girdle of the Audient Earth", sources = { [14]=18066 } },
                { id = 127524, slot = "Weapon", name = "Librarian's Paper Cutter", sources = { [14]=72640 }, timewalkingOnly = true },
                { id = 37853, slot = "Wrist", name = "Advanced Tooled-Leather Bands", sources = { [14]=18064 } },
            },
        },
    },
}
