-------------------------------------------------------------------------------
-- RetroRuns Data -- Dire Maul - Warpwood Quarter
-- Classic dungeon, Patch 1.3  |  instanceID: 429  |  journalInstanceID: 1276
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1276] = {
    kind              = "dungeon",
    instanceID        = 429,
    journalInstanceID = 1276,
    name              = "Dire Maul - Warpwood Quarter",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.3",

    bosses = {
        {
            index              = 1,
            name               = "Lethtendris",
            journalEncounterID = 404,
            achievements       = {
            },
            loot = {
                { id = 18325, slot = "Head", name = "Felhide Cap", sources = { [14]=7272 } },
                { id = 18301, slot = "Ranged", name = "Lethtendris' Wand", sources = { [14]=7252 } },
                { id = 18311, slot = "Two-Hand", name = "Quel'dorei Channeling Rod", sources = { [14]=7261 } },
            },
        },
        {
            index              = 2,
            name               = "Hydrospawn",
            journalEncounterID = 403,
            achievements       = {
            },
            loot = {
                { id = 18307, slot = "Feet", name = "Riptide Shoes", sources = { [14]=7257 } },
                { id = 18322, slot = "Feet", name = "Waterspout Boots", sources = { [14]=7269 } },
                { id = 18305, slot = "Legs", name = "Breakwater Legguards", sources = { [14]=7255 } },
                { id = 18324, slot = "Two-Hand", name = "Waveslicer", sources = { [14]=7271 } },
            },
        },
        {
            index              = 3,
            name               = "Zevrim Thornhoof",
            journalEncounterID = 402,
            achievements       = {
            },
            loot = {
                { id = 18306, slot = "Hands", name = "Gloves of Shadowy Mist", sources = { [14]=7256 } },
                { id = 18308, slot = "Head", name = "Clever Hat", sources = { [14]=7258 } },
                { id = 18319, slot = "Head", name = "Fervent Helm", sources = { [14]=7266 } },
                { id = 18313, slot = "Head", name = "Helm of Awareness", sources = { [14]=7263 } },
                { id = 18323, slot = "Ranged", name = "Satyr's Bow", sources = { [14]=7270 } },
            },
        },
        {
            index              = 4,
            name               = "Alzzin the Wildshaper",
            journalEncounterID = 405,
            achievements       = {
                { id = 644, name = "King of Dire Maul" },
            },
            loot = {
                { id = 18328, slot = "Back", name = "Shadewood Cloak", sources = { [14]=7275 } },
                { id = 18312, slot = "Chest", name = "Energized Chestplate", sources = { [14]=7262 } },
                { id = 18318, slot = "Feet", name = "Merciful Greaves", sources = { [14]=7265 } },
                { id = 18309, slot = "Hands", name = "Gloves of Restoration", sources = { [14]=7259 } },
                { id = 18326, slot = "Hands", name = "Razor Gauntlets", sources = { [14]=7273 } },
                { id = 18327, slot = "Waist", name = "Whipvine Cord", sources = { [14]=7274 } },
                { id = 18321, slot = "Weapon", name = "Energetic Rod", sources = { [14]=7268 } },
                { id = 18310, slot = "Weapon", name = "Fiendish Machete", sources = { [14]=7260 } },
            },
        },
    },
}
