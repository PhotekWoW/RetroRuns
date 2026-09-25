-------------------------------------------------------------------------------
-- RetroRuns Data -- Kings' Rest
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1762  |  journalInstanceID: 1041
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1041] = {
    kind              = "dungeon",
    instanceID        = 1762,
    journalInstanceID = 1041,
    name              = "Kings' Rest",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 15, 16 },
    patch             = "8.0.1",
    timewalking       = true,

    entrance = {
        mapID = 862,
        x     = 0.3731,
        y     = 0.3950,
    },

    bosses = {
        {
            index              = 1,
            name               = "The Golden Serpent",
            journalEncounterID = 2165,
            dungeonEncounterID = 2139,
            achievements       = {
            },
            loot = {
                { id = 159412, slot = "Feet", name = "Auric Puddle Stompers", sources = { [15]=95633, [16]=95633 } },
                { id = 159304, slot = "Feet", name = "Goldfeather Boots", sources = { [15]=95595, [16]=95595 } },
                { id = 159413, slot = "Hands", name = "Gauntlets of the Avian Sentinel", sources = { [15]=95635, [16]=95635 } },
                { id = 159313, slot = "Legs", name = "Breeches of the Sacred Hall", sources = { [15]=98460, [16]=98460 } },
                { id = 159234, slot = "Legs", name = "Down-Lined Breeches", sources = { [15]=95555, [16]=95555 } },
                { id = 159369, slot = "Waist", name = "Belt of the Consecrated Tomb", sources = { [15]=98407, [16]=98407 } },
                { id = 159137, slot = "Weapon", name = "Gilded Serpent's Tooth", sources = { [15]=95475, [16]=95475 } },
            },
        },
        {
            index              = 2,
            name               = "Mchimba the Embalmer",
            journalEncounterID = 2171,
            dungeonEncounterID = 2142,
            achievements       = {
            },
            loot = {
                { id = 159312, slot = "Hands", name = "Desiccator's Blessed Gloves", sources = { [15]=95601, [16]=95601 } },
                { id = 160213, slot = "Hands", name = "Sepulchral Construct's Gloves", sources = { [15]=98430, [16]=98430 } },
                { id = 159667, slot = "Off-hand", name = "Vessel of Last Rites", sources = { [15]=95530, [16]=95530 } },
                { id = 159642, slot = "Two-Hand", name = "Royal Purifier's Spade", sources = { [15]=95504, [16]=95504 } },
                { id = 159409, slot = "Wrist", name = "Embalmer's Steadying Bracers", sources = { [15]=95629, [16]=95629 } },
            },
        },
        {
            index              = 3,
            name               = "The Council of Tribes",
            journalEncounterID = 2170,
            dungeonEncounterID = 2140,
            achievements       = {
            },
            loot = {
                { id = 159288, slot = "Back", name = "Cloak of the Restless Tribes", sources = { [15]=97058, [16]=97058 } },
                { id = 159371, slot = "Feet", name = "Boots of the Headlong Conqueror", sources = { [15]=95854, [16]=95854 } },
                { id = 159243, slot = "Feet", name = "Sandals of Wise Voodoo", sources = { [15]=95561, [16]=95561 } },
                { id = 159643, slot = "Ranged", name = "Crossbow of Forgotten Majesty", sources = { [15]=95428, [16]=95428 } },
                { id = 159418, slot = "Waist", name = "Girdle of Pestilent Purification", sources = { [15]=95640, [16]=95640 } },
                { id = 160216, slot = "Weapon", name = "Crackling Jade Kilij", sources = { [15]=96228, [16]=96228 } },
                { id = 159136, slot = "Weapon", name = "Jeweled Dagger of Subjugation", sources = { [15]=95473, [16]=95473 } },
                { id = 159300, slot = "Wrist", name = "Kula's Butchering Wristwraps", sources = { [15]=95590, [16]=95590 } },
            },
        },
        {
            index              = 4,
            name               = "Dazar, The First King",
            journalEncounterID = 2172,
            dungeonEncounterID = 2143,
            aliases            = { "King Dazar" },
            achievements       = {
            },
            loot = {
                { id = 158355, slot = "Chest", name = "Loa-Blessed Chestguard", sources = { [15]=98390, [16]=98390 } },
                { id = 239046, slot = "Chest", name = "Loa-Blessed Chestguard", sources = { [15]=287952, [16]=287952 } },
                { id = 159303, slot = "Chest", name = "Vest of Reverent Adoration", sources = { [15]=95593, [16]=95593 } },
                { id = 239048, slot = "Chest", name = "Vest of Reverent Adoration", sources = { [15]=287954, [16]=287954 } },
                { id = 159236, slot = "Head", name = "Headdress of the First Empire", sources = { [15]=95558, [16]=95558 } },
                { id = 239047, slot = "Head", name = "Headdress of the First Empire", sources = { [15]=287953, [16]=287953 } },
                { id = 159422, slot = "Head", name = "Helm of the Raptor King", sources = { [15]=95642, [16]=95642 } },
                { id = 239050, slot = "Head", name = "Helm of the Raptor King", sources = { [15]=287956, [16]=287956 } },
                { id = 158344, slot = "Shoulder", name = "Mantle of Ceremonial Ascension", sources = { [15]=95747, [16]=95747 } },
                { id = 239045, slot = "Shoulder", name = "Mantle of Ceremonial Ascension", sources = { [15]=287951, [16]=287951 } },
                { id = 159423, slot = "Shoulder", name = "Pauldrons of the Great Unifier", sources = { [15]=95644, [16]=95644 } },
                { id = 239051, slot = "Shoulder", name = "Pauldrons of the Great Unifier", sources = { [15]=287957, [16]=287957 } },
                { id = 159368, slot = "Shoulder", name = "Spaulders of Prime Emperor", sources = { [15]=98405, [16]=98405 } },
                { id = 239049, slot = "Shoulder", name = "Spaulders of Prime Emperor", sources = { [15]=287955, [16]=287955 } },
                { id = 159644, slot = "Two-Hand", name = "Geti'ikku, Cut of Death", sources = { [15]=95458, [16]=95458 } },
                { id = 159301, slot = "Waist", name = "Primal Dinomancer's Belt", sources = { [15]=95591, [16]=95591 } },
                { id = 159645, slot = "Weapon", name = "Headcracker of Supplication", sources = { [15]=95495, [16]=95495 } },
            },
            specialLoot = {
                { id = 278245, kind = "decor", name = "Royal Attendant's Coffin", decorID = 26208 },
                { id = 159921, kind = "mount", name = "Mummified Raptor Skull", mythicOnly = true },
            },
        },
    },
}
