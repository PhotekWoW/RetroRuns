-------------------------------------------------------------------------------
-- RetroRuns Data -- Temple of the Jade Serpent
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 960  |  journalInstanceID: 313
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[313] = {
    kind              = "dungeon",
    instanceID        = 960,
    journalInstanceID = 313,
    name              = "Temple of the Jade Serpent",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    patch             = "5.0.4",

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Wise Mari",
            journalEncounterID = 672,
            achievements       = {
                { id = 6460, name = "Hydrophobia", meta = true },
            },
            loot = {
                { id = 144111, slot = "Back", name = "Wind-Soaked Drape", sources = { [14]=84416 } },
                { id = 143960, slot = "Chest", name = "Riverbed Chestguard", sources = { [14]=84295 } },
                { id = 143973, slot = "Feet", name = "Treads of Corrupted Water", sources = { [14]=84308 } },
                { id = 144017, slot = "Head", name = "Waterburst Helm", sources = { [14]=84352 } },
            },
        },
        {
            index              = 2,
            name               = "Lorewalker Stonestep",
            journalEncounterID = 664,
            achievements       = {
            },
            loot = {
                { id = 143974, slot = "Feet", name = "Stonestep Boots", sources = { [14]=84309 } },
                { id = 143987, slot = "Legs", name = "Leggings of Whispered Dreams", sources = { [14]=84322 } },
                { id = 144081, slot = "Waist", name = "Girdle of Endemic Anger", sources = { [14]=84387 } },
                { id = 144083, slot = "Waist", name = "Sunheart Waistband", sources = { [14]=84389 } },
            },
        },
        {
            index              = 3,
            name               = "Liu Flameheart",
            journalEncounterID = 658,
            achievements       = {
            },
            loot = {
                { id = 144094, slot = "Back", name = "Cape of Entanglement", sources = { [14]=84400 } },
                { id = 143988, slot = "Feet", name = "Flameheart Sandals", sources = { [14]=84323 } },
                { id = 144090, slot = "Ranged", name = "Firebelcher Hand Cannon", sources = { [14]=84396 } },
                { id = 143971, slot = "Shoulder", name = "Serpentstrike Shoulderpads", sources = { [14]=84306 } },
            },
        },
        {
            index              = 4,
            name               = "Sha of Doubt",
            journalEncounterID = 335,
            achievements       = {
                { id = 6475, name = "Cleaning Up", meta = true },
                { id = 6671, name = "Seeds of Doubt", meta = true },
                { id = 6757, name = "Temple of the Jade Serpent" },
                { id = 6758, name = "Heroic: Temple of the Jade Serpent" },
                { id = 6884, name = "Temple of the Jade Serpent Challenger" },
                { id = 6885, name = "Temple of the Jade Serpent: Bronze" },
                { id = 6886, name = "Temple of the Jade Serpent: Silver" },
                { id = 6887, name = "Temple of the Jade Serpent: Gold" },
                { id = 19894, name = "Temple of the Jade Serpent" },
                { id = 19895, name = "Heroic: Temple of the Jade Serpent" },
            },
            loot = {
                { id = 144115, slot = "Back", name = "Cloak of Failing Will", sources = { [14]=84417 } },
                { id = 143959, slot = "Chest", name = "Chestguard of Despair", sources = { [14]=84294 } },
                { id = 144091, slot = "Hands", name = "Hopecrusher Gauntlets", sources = { [14]=84397 } },
                { id = 144118, slot = "Hands", name = "Paralyzing Gloves", sources = { [14]=84419 } },
                { id = 143972, slot = "Shoulder", name = "Doubtridden Shoulderguards", sources = { [14]=84307 } },
                { id = 143970, slot = "Shoulder", name = "Neverdare Shoulders", sources = { [14]=84305 } },
                { id = 144093, slot = "Two-Hand", name = "Staff of Trembling Will", sources = { [14]=84399 } },
                { id = 144116, slot = "Waist", name = "Binding of Broken Dreams", sources = { [14]=84418 } },
                { id = 144086, slot = "Weapon", name = "Dubious Handaxe", sources = { [14]=84392 } },
                { id = 144216, slot = "Weapon", name = "Je'lyu, Spirit of the Serpent", sources = { [14]=84484 } },
            },
            specialLoot = {
                { id = 246846, kind = "decor", name = "Tome of Pandaren Wisdom", decorID = 2512 },
            },
        },
    },
}
