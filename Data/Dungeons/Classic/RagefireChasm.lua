-------------------------------------------------------------------------------
-- RetroRuns Data -- Ragefire Chasm
-- Classic dungeon, Patch 1.0  |  instanceID: 389  |  journalInstanceID: 226
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[226] = {
    kind              = "dungeon",
    instanceID        = 389,
    journalInstanceID = 226,
    name              = "Ragefire Chasm",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Adarogg",
            journalEncounterID = 694,
            achievements       = {
            },
            loot = {
                { id = 151421, slot = "Feet", name = "Scorched Blazehound Boots", sources = { [14]=89425 } },
                { id = 82772, slot = "Legs", name = "Snarlmouth Leggings", sources = { [14]=42093 } },
                { id = 151422, slot = "Waist", name = "Bonecoal Waistguard", sources = { [14]=89426 } },
                { id = 82880, slot = "Weapon", name = "Fang of Adarogg", sources = { [14]=42162 } },
                { id = 82879, slot = "Wrist", name = "Collarspike Bracers", sources = { [14]=42161 } },
            },
        },
        {
            index              = 2,
            name               = "Dark Shaman Koranthal",
            journalEncounterID = 695,
            achievements       = {
            },
            loot = {
                { id = 82882, slot = "Back", name = "Dark Ritual Cape", sources = { [14]=42164 } },
                { id = 132551, slot = "Chest", name = "Dark Shaman's Jerkin", sources = { [14]=76386 } },
                { id = 82877, slot = "Chest", name = "Grasp of the Broken Totem", sources = { [14]=42159 } },
                { id = 82881, slot = "Wrist", name = "Cuffs of Black Elements", sources = { [14]=42163 } },
            },
        },
        {
            index              = 3,
            name               = "Slagmaw",
            journalEncounterID = 696,
            achievements       = {
            },
            loot = {
                { id = 82878, slot = "Chest", name = "Fireworm Robes", sources = { [14]=42160 } },
                { id = 82885, slot = "Chest", name = "Flameseared Carapace", sources = { [14]=42167 } },
                { id = 132552, slot = "Wrist", name = "Chitonous Bindings", sources = { [14]=76387 } },
                { id = 82884, slot = "Wrist", name = "Chitonous Bracers", sources = { [14]=42166 } },
            },
        },
        {
            index              = 4,
            name               = "Lava Guard Gordoth",
            journalEncounterID = 697,
            achievements       = {
                { id = 629, name = "Ragefire Chasm" },
            },
            loot = {
                { id = 82886, slot = "Feet", name = "Gorewalker Treads", sources = { [14]=42168 } },
                { id = 151425, slot = "Hands", name = "Gordoth's Crushers", sources = { [14]=89428 } },
                { id = 82888, slot = "Two-Hand", name = "Heartboiler Staff", sources = { [14]=42169 } },
                { id = 151424, slot = "Waist", name = "Belt of Boundless Fury", sources = { [14]=89427 } },
                { id = 82883, slot = "Weapon", name = "Bloodcursed Felblade", sources = { [14]=42165 } },
            },
        },
    },
}
