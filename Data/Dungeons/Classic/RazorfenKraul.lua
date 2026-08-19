-------------------------------------------------------------------------------
-- RetroRuns Data -- Razorfen Kraul
-- Classic dungeon, Patch 1.0  |  instanceID: 47  |  journalInstanceID: 234
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[234] = {
    kind              = "dungeon",
    instanceID        = 47,
    journalInstanceID = 234,
    name              = "Razorfen Kraul",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Hunter Bonetusk",
            journalEncounterID = 896,
            achievements       = {
            },
            loot = {
                { id = 151442, slot = "Back", name = "Bonetusk Greatcloak", sources = { [14]=89441 } },
                { id = 6689, slot = "Two-Hand", name = "Wind Spirit Staff", sources = { [14]=2574 } },
                { id = 6681, slot = "Weapon", name = "Thornspike", sources = { [14]=2568 } },
            },
        },
        {
            index              = 2,
            name               = "Roogug",
            journalEncounterID = 895,
            achievements       = {
            },
            loot = {
                { id = 132565, slot = "Legs", name = "Carnal Britches", sources = { [14]=76398 } },
                { id = 6690, slot = "Legs", name = "Ferine Leggings", sources = { [14]=2575 } },
                { id = 6691, slot = "Weapon", name = "Swinetusk Shank", sources = { [14]=2576 } },
            },
        },
        {
            index              = 3,
            name               = "Warlord Ramtusk",
            journalEncounterID = 899,
            achievements       = {
            },
            loot = {
                { id = 6686, slot = "Head", name = "Tusken Helm", sources = { [14]=2571 } },
                { id = 6688, slot = "Head", name = "Whisperwind Headdress", sources = { [14]=2573 } },
                { id = 151445, slot = "Legs", name = "Porcine-Warlord's Legplates", sources = { [14]=89443 } },
                { id = 6685, slot = "Shoulder", name = "Death Speaker Mantle", sources = { [14]=2570 } },
                { id = 6687, slot = "Two-Hand", name = "Corpsemaker", sources = { [14]=2572 } },
            },
        },
        {
            index              = 4,
            name               = "Groyat, the Blind Hunter",
            journalEncounterID = 900,
            achievements       = {
            },
            loot = {
                { id = 6696, slot = "Ranged", name = "Nightstalker Bow", sources = { [14]=2579 } },
                { id = 6697, slot = "Shoulder", name = "Batwing Mantle", sources = { [14]=2580 } },
            },
        },
        {
            index              = 5,
            name               = "Charlga Razorflank",
            journalEncounterID = 901,
            achievements       = {
                { id = 635, name = "Razorfen Kraul" },
            },
            loot = {
                { id = 6694, slot = "Off-hand", name = "Heart of Agamaggan", sources = { [14]=2578 } },
                { id = 6692, slot = "Weapon", name = "Pronged Reaver", sources = { [14]=2577 } },
            },
        },
    },
}
