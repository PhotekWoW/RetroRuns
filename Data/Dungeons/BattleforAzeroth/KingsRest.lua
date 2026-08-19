-------------------------------------------------------------------------------
-- RetroRuns Data -- Kings' Rest
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
    patch             = "8.0.1",

    bosses = {
        {
            index              = 1,
            name               = "The Golden Serpent",
            journalEncounterID = 2165,
            achievements       = {
            },
            loot = {
                { id = 159412, slot = "Feet", name = "Auric Puddle Stompers", sources = { [16]=95633 } },
                { id = 159304, slot = "Feet", name = "Goldfeather Boots", sources = { [16]=95595 } },
                { id = 159413, slot = "Hands", name = "Gauntlets of the Avian Sentinel", sources = { [16]=95635 } },
                { id = 159313, slot = "Legs", name = "Breeches of the Sacred Hall", sources = { [16]=98460 } },
                { id = 159234, slot = "Legs", name = "Down-Lined Breeches", sources = { [16]=95555 } },
                { id = 159369, slot = "Waist", name = "Belt of the Consecrated Tomb", sources = { [16]=98407 } },
                { id = 159137, slot = "Weapon", name = "Gilded Serpent's Tooth", sources = { [16]=95475 } },
            },
        },
        {
            index              = 2,
            name               = "Mchimba the Embalmer",
            journalEncounterID = 2171,
            achievements       = {
            },
            loot = {
                { id = 159312, slot = "Hands", name = "Desiccator's Blessed Gloves", sources = { [16]=95601 } },
                { id = 160213, slot = "Hands", name = "Sepulchral Construct's Gloves", sources = { [16]=98430 } },
                { id = 159667, slot = "Off-hand", name = "Vessel of Last Rites", sources = { [16]=95530 } },
                { id = 159642, slot = "Two-Hand", name = "Royal Purifier's Spade", sources = { [16]=95504 } },
                { id = 159409, slot = "Wrist", name = "Embalmer's Steadying Bracers", sources = { [16]=95629 } },
            },
        },
        {
            index              = 3,
            name               = "The Council of Tribes",
            journalEncounterID = 2170,
            achievements       = {
            },
            loot = {
                { id = 159288, slot = "Back", name = "Cloak of the Restless Tribes", sources = { [16]=97058 } },
                { id = 159371, slot = "Feet", name = "Boots of the Headlong Conqueror", sources = { [16]=95854 } },
                { id = 159243, slot = "Feet", name = "Sandals of Wise Voodoo", sources = { [16]=95561 } },
                { id = 159643, slot = "Ranged", name = "Crossbow of Forgotten Majesty", sources = { [16]=95428 } },
                { id = 159418, slot = "Waist", name = "Girdle of Pestilent Purification", sources = { [16]=95640 } },
                { id = 160216, slot = "Weapon", name = "Crackling Jade Kilij", sources = { [16]=96228 } },
                { id = 159136, slot = "Weapon", name = "Jeweled Dagger of Subjugation", sources = { [16]=95473 } },
                { id = 159300, slot = "Wrist", name = "Kula's Butchering Wristwraps", sources = { [16]=95590 } },
            },
        },
        {
            index              = 4,
            name               = "Dazar, The First King",
            journalEncounterID = 2172,
            achievements       = {
                { id = 12848, name = "Kings' Rest" },
            },
            loot = {
                { id = 158355, slot = "Chest", name = "Loa-Blessed Chestguard", sources = { [16]=98390 } },
                { id = 159303, slot = "Chest", name = "Vest of Reverent Adoration", sources = { [16]=95593 } },
                { id = 159236, slot = "Head", name = "Headdress of the First Empire", sources = { [16]=95558 } },
                { id = 159422, slot = "Head", name = "Helm of the Raptor King", sources = { [16]=95642 } },
                { id = 158344, slot = "Shoulder", name = "Mantle of Ceremonial Ascension", sources = { [16]=95747 } },
                { id = 159423, slot = "Shoulder", name = "Pauldrons of the Great Unifier", sources = { [16]=95644 } },
                { id = 159368, slot = "Shoulder", name = "Spaulders of Prime Emperor", sources = { [16]=98405 } },
                { id = 159644, slot = "Two-Hand", name = "Geti'ikku, Cut of Death", sources = { [16]=95458 } },
                { id = 159301, slot = "Waist", name = "Primal Dinomancer's Belt", sources = { [16]=95591 } },
                { id = 159645, slot = "Weapon", name = "Headcracker of Supplication", sources = { [16]=95495 } },
            },
            specialLoot = {
                { id = 278245, kind = "decor", name = "Royal Attendant's Coffin", decorID = 26208 },
                { id = 159921, kind = "mount", name = "Mummified Raptor Skull", mythicOnly = true },
            },
        },
    },
}
