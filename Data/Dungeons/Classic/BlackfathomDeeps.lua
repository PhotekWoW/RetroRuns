-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackfathom Deeps
-- Classic dungeon, Patch 1.0  |  instanceID: 48  |  journalInstanceID: 227
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[227] = {
    kind              = "dungeon",
    instanceID        = 48,
    journalInstanceID = 227,
    name              = "Blackfathom Deeps",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Ghamoo-Ra",
            journalEncounterID = 368,
            achievements       = {
            },
            loot = {
                { id = 6907, slot = "Chest", name = "Tortoise Armor", sources = { [14]=2647 } },
                { id = 151432, slot = "Legs", name = "Twilight Turtleskin Leggings", sources = { [14]=89433 } },
                { id = 151433, slot = "Shoulder", name = "Thick Shellplate Shoulders", sources = { [14]=89434 } },
                { id = 6908, slot = "Waist", name = "Ghamoo-Ra's Bind", sources = { [14]=2648 } },
            },
        },
        {
            index              = 2,
            name               = "Domina",
            journalEncounterID = 436,
            achievements       = {
            },
            loot = {
                { id = 151434, slot = "Feet", name = "Foul Shadowsleet Slippers", sources = { [14]=89435 } },
                { id = 132554, slot = "Hands", name = "Deadly Serpentine Grips", sources = { [14]=76389 } },
                { id = 888, slot = "Hands", name = "Naga Battle Gloves", sources = { [14]=142 } },
                { id = 151435, slot = "Legs", name = "Domina's Deathmaw Greaves", sources = { [14]=89436 } },
                { id = 3078, slot = "Ranged", name = "Naga Heartpiercer", sources = { [14]=1096 } },
                { id = 11121, slot = "Weapon", name = "Darkwater Talwar", sources = { [14]=4135 } },
            },
        },
        {
            index              = 3,
            name               = "Subjugator Kor'ul",
            journalEncounterID = 426,
            achievements       = {
            },
            loot = {
                { id = 6906, slot = "Hands", name = "Algae Fists", sources = { [14]=2646 } },
                { id = 6905, slot = "Two-Hand", name = "Reef Axe", sources = { [14]=2645 } },
            },
        },
        {
            index              = 4,
            name               = "Thruk",
            journalEncounterID = 1145,
            achievements       = {
            },
            loot = {
                { id = 120164, slot = "Two-Hand", name = "Thruk's Heavy Duty Fishing Pole", sources = { [14]=67919 } },
                { id = 120165, slot = "Weapon", name = "Thruk's Fillet Knife", sources = { [14]=67920 } },
                { id = 120163, slot = "invtype 29", name = "Thruk's Fishing Rod", sources = { [14]=67918 } },
            },
        },
        {
            index              = 5,
            name               = "Guardian of the Deep",
            journalEncounterID = 447,
            achievements       = {
            },
            loot = {
                { id = 6901, slot = "Back", name = "Glowing Thresher Cape", sources = { [14]=2641 } },
                { id = 6904, slot = "Weapon", name = "Bite of Serra'kis", sources = { [14]=2644 } },
                { id = 6902, slot = "Wrist", name = "Bands of Serra'kis", sources = { [14]=2642 } },
                { id = 132555, slot = "Wrist", name = "Serra'kis Scale Wraps", sources = { [14]=76390 } },
            },
        },
        {
            index              = 6,
            name               = "Executioner Gore",
            journalEncounterID = 1144,
            achievements       = {
            },
            loot = {
                { id = 120167, slot = "Back", name = "Bloody Twilight Cloak", sources = { [14]=67922 } },
                { id = 120166, slot = "Chest", name = "Gorestained Garb", sources = { [14]=67921 } },
            },
        },
        {
            index              = 7,
            name               = "Twilight Lord Bathiel",
            journalEncounterID = 437,
            achievements       = {
            },
            loot = {
                { id = 151438, slot = "Feet", name = "Hungering Deepwater Treads", sources = { [14]=89437 } },
                { id = 151440, slot = "Head", name = "Blackfathom Ascendant's Helm", sources = { [14]=89439 } },
                { id = 6903, slot = "Legs", name = "Gaze Dreamer Pants", sources = { [14]=2643 } },
                { id = 151439, slot = "Shoulder", name = "Bathiel's Scale Spaulders", sources = { [14]=89438 } },
                { id = 1155, slot = "Two-Hand", name = "Rod of the Sleepwalker", sources = { [14]=181 } },
            },
        },
        {
            index              = 8,
            name               = "Aku'mai",
            journalEncounterID = 444,
            achievements       = {
                { id = 632, name = "Blackfathom Deeps" },
            },
            loot = {
                { id = 151441, slot = "Feet", name = "Aku'mai Worshipper's Greatboots", sources = { [14]=89440 } },
                { id = 6910, slot = "Legs", name = "Leech Pants", sources = { [14]=2650 } },
                { id = 6909, slot = "Two-Hand", name = "Strike of the Hydra", sources = { [14]=2649 } },
                { id = 132553, slot = "Waist", name = "Algae-Twined Waistcord", sources = { [14]=76388 } },
                { id = 6911, slot = "Waist", name = "Moss Cinch", sources = { [14]=2651 } },
            },
        },
    },
}
