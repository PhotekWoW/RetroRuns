-------------------------------------------------------------------------------
-- RetroRuns Data -- Mogu'shan Palace
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 994  |  journalInstanceID: 321
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[321] = {
    kind              = "dungeon",
    instanceID        = 994,
    journalInstanceID = 321,
    name              = "Mogu'shan Palace",
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
            name               = "Trial of the King",
            journalEncounterID = 708,
            achievements       = {
            },
            loot = {
                { id = 144145, slot = "Hands", name = "Conflagrating Gloves", sources = { [14]=84432 } },
                { id = 144020, slot = "Head", name = "Crest of the Clan Lords", sources = { [14]=84355 } },
                { id = 144021, slot = "Head", name = "Meteoric Greathelm", sources = { [14]=84356 } },
                { id = 144143, slot = "Waist", name = "Hurricane Belt", sources = { [14]=84431 } },
            },
        },
        {
            index              = 2,
            name               = "Gekkan",
            journalEncounterID = 690,
            achievements       = {
                { id = 6478, name = "Glintrok N' Roll", meta = true },
            },
            loot = {
                { id = 144147, slot = "Back", name = "Cloak of Cleansing Flame", sources = { [14]=84433 } },
                { id = 143992, slot = "Feet", name = "Glintrok Sollerets", sources = { [14]=84327 } },
                { id = 144149, slot = "Hands", name = "Hexxer's Lethargic Gloves", sources = { [14]=84435 } },
                { id = 144148, slot = "Weapon", name = "Claws of Gekkan", sources = { [14]=84434 } },
            },
        },
        {
            index              = 3,
            name               = "Xin the Weaponmaster",
            journalEncounterID = 698,
            achievements       = {
                { id = 6736, name = "What Does This Button Do?", meta = true },
                { id = 6755, name = "Mogu'shan Palace" },
                { id = 6756, name = "Heroic: Mogu'shan Palace" },
                { id = 6713, name = "Quarrelsome Quilen Quintet", meta = true },
                { id = 6892, name = "Mogu'shan Palace Challenger" },
                { id = 6899, name = "Mogu'shan Palace: Bronze" },
                { id = 6900, name = "Mogu'shan Palace: Silver" },
                { id = 6901, name = "Mogu'shan Palace: Gold" },
                { id = 19904, name = "Mogu'shan Palace" },
                { id = 19905, name = "Heroic: Mogu'shan Palace" },
            },
            loot = {
                { id = 143956, slot = "Chest", name = "Mind's Eye Breastplate", sources = { [14]=84291 } },
                { id = 143993, slot = "Feet", name = "Boots of Plummeting Death", sources = { [14]=84328 } },
                { id = 143994, slot = "Feet", name = "Soulbinder Treads", sources = { [14]=84329 } },
                { id = 144151, slot = "Hands", name = "Axebreaker Gauntlets", sources = { [14]=84437 } },
                { id = 143995, slot = "Shoulder", name = "Regal Silk Shoulderpads", sources = { [14]=84330 } },
                { id = 144150, slot = "Two-Hand", name = "Ghostheart", sources = { [14]=84436 } },
                { id = 144214, slot = "Two-Hand", name = "Mogu'Dar, Blade of the Thousand Slaves", sources = { [14]=84482 } },
                { id = 144154, slot = "Weapon", name = "Firescribe Dagger", sources = { [14]=84439 } },
                { id = 144153, slot = "Wrist", name = "Groundshaker Bracers", sources = { [14]=84438 } },
            },
        },
    },
}
