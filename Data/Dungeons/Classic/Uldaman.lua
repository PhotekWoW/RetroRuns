-------------------------------------------------------------------------------
-- RetroRuns Data -- Uldaman
-- Classic dungeon, Patch 1.0  |  instanceID: 70  |  journalInstanceID: 239
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[239] = {
    kind              = "dungeon",
    instanceID        = 70,
    journalInstanceID = 239,
    name              = "Uldaman",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Revelosh",
            journalEncounterID = 467,
            achievements       = {
            },
            loot = {
                { id = 9387, slot = "Feet", name = "Revelosh's Boots", sources = { [14]=3238 } },
                { id = 9390, slot = "Hands", name = "Revelosh's Gloves", sources = { [14]=3241 } },
                { id = 132736, slot = "Shoulder", name = "Revelosh's Pauldrons", sources = { [14]=76413 } },
                { id = 9389, slot = "Shoulder", name = "Revelosh's Spaulders", sources = { [14]=3240 } },
                { id = 151395, slot = "Waist", name = "Revelosh's Girdle", sources = { [14]=89402 } },
                { id = 9388, slot = "Wrist", name = "Revelosh's Armguards", sources = { [14]=3239 } },
            },
        },
        {
            index              = 2,
            name               = "The Lost Dwarves",
            journalEncounterID = 468,
            achievements       = {
            },
            loot = {
                { id = 132734, slot = "Feet", name = "Viking Chain Boots", sources = { [14]=76411 } },
                { id = 9398, slot = "Feet", name = "Worn Running Boots", sources = { [14]=3249 } },
                { id = 9394, slot = "Head", name = "Horned Viking Helmet", sources = { [14]=3245 } },
                { id = 9403, slot = "Off-hand", name = "Battered Viking Shield", sources = { [14]=3254 } },
                { id = 9404, slot = "Off-hand", name = "Olaf's All Purpose Shield", sources = { [14]=3255 } },
                { id = 9400, slot = "Ranged", name = "Baelog's Shortbow", sources = { [14]=3251 } },
                { id = 9401, slot = "Weapon", name = "Nordic Longshank", sources = { [14]=3252 } },
                { id = 151396, slot = "Wrist", name = "Erik's High-Performance Armbands", sources = { [14]=89403 } },
            },
        },
        {
            index              = 3,
            name               = "Ironaya",
            journalEncounterID = 469,
            achievements       = {
            },
            loot = {
                { id = 151420, slot = "Chest", name = "Vault-Watcher's Breastplate", sources = { [14]=89424 } },
                { id = 151398, slot = "Head", name = "Hood of the Idle Architect", sources = { [14]=89405 } },
                { id = 9407, slot = "Legs", name = "Stoneweaver Leggings", sources = { [14]=3258 } },
                { id = 9408, slot = "Two-Hand", name = "Ironshod Bludgeon", sources = { [14]=3259 } },
                { id = 9409, slot = "Wrist", name = "Ironaya's Bracers", sources = { [14]=3260 } },
            },
        },
        {
            index              = 4,
            name               = "Obsidian Sentinel",
            journalEncounterID = 748,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 5,
            name               = "Ancient Stone Keeper",
            journalEncounterID = 470,
            achievements       = {
            },
            loot = {
                { id = 151400, slot = "Feet", name = "Sand-Scoured Treads", sources = { [14]=89406 } },
                { id = 9410, slot = "Hands", name = "Cragfists", sources = { [14]=3261 } },
                { id = 151401, slot = "Legs", name = "Titanic Stone Legguards", sources = { [14]=89407 } },
                { id = 9411, slot = "Shoulder", name = "Rockshard Pauldrons", sources = { [14]=3262 } },
                { id = 132733, slot = "Shoulder", name = "Stone Keeper's Mantle", sources = { [14]=76410 } },
            },
        },
        {
            index              = 6,
            name               = "Galgann Firehammer",
            journalEncounterID = 471,
            achievements       = {
            },
            loot = {
                { id = 11311, slot = "Back", name = "Emberscale Cape", sources = { [14]=4167 } },
                { id = 9412, slot = "Ranged", name = "Galgann's Fireblaster", sources = { [14]=3263 } },
                { id = 11310, slot = "Shoulder", name = "Flameseer Mantle", sources = { [14]=4166 } },
                { id = 9419, slot = "Weapon", name = "Galgann's Firehammer", sources = { [14]=3269 } },
            },
        },
        {
            index              = 7,
            name               = "Grimlok",
            journalEncounterID = 472,
            achievements       = {
            },
            loot = {
                { id = 9415, slot = "Chest", name = "Grimlok's Tribal Vestments", sources = { [14]=3266 } },
                { id = 132735, slot = "Legs", name = "Grimlok's Chain Chaps", sources = { [14]=76412 } },
                { id = 9414, slot = "Legs", name = "Oilskin Leggings", sources = { [14]=3265 } },
                { id = 9416, slot = "Two-Hand", name = "Grimlok's Charge", sources = { [14]=3267 } },
                { id = 151402, slot = "Wrist", name = "Grimlok's Jagged Wristguards", sources = { [14]=89408 } },
            },
        },
        {
            index              = 8,
            name               = "Archaedas",
            journalEncounterID = 473,
            achievements       = {
                { id = 638, name = "Uldaman" },
            },
            loot = {
                { id = 9418, slot = "Two-Hand", name = "Stoneslayer", sources = { [14]=3268 } },
                { id = 9413, slot = "Two-Hand", name = "The Rockpounder", sources = { [14]=3264 } },
            },
        },
    },
}
