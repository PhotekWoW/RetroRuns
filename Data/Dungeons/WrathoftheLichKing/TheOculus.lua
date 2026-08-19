-------------------------------------------------------------------------------
-- RetroRuns Data -- The Oculus
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 578  |  journalInstanceID: 282
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[282] = {
    kind              = "dungeon",
    instanceID        = 578,
    journalInstanceID = 282,
    name              = "The Oculus",
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
            name               = "Drakos the Interrogator",
            journalEncounterID = 622,
            achievements       = {
                { id = 1868, name = "Make It Count", meta = true },
            },
            loot = {
                { id = 37258, slot = "Chest", name = "Drakewing Raiments", sources = { [14]=17697 } },
                { id = 36946, slot = "Chest", name = "Runic Cage Chestpiece", sources = { [14]=17493 } },
                { id = 37256, slot = "Chest", name = "Scaled Armor of Drakos", sources = { [14]=17696 } },
                { id = 157562, slot = "Two-Hand", name = "Rod of Aggressive Questioning", sources = { [14]=93757 } },
                { id = 36944, slot = "Weapon", name = "Lifeblade of Belgaristrasz", sources = { [14]=17491 } },
                { id = 37255, slot = "Weapon", name = "The Interrogator", sources = { [14]=17695 } },
                { id = 36945, slot = "Wrist", name = "Verdisa's Cuffs of Dreaming", sources = { [14]=17492 } },
            },
        },
        {
            index              = 2,
            name               = "Varos Cloudstrider",
            journalEncounterID = 623,
            achievements       = {
            },
            loot = {
                { id = 36947, slot = "Back", name = "Centrifuge Core Cloak", sources = { [14]=17494 } },
                { id = 36950, slot = "Chest", name = "Wing Commander's Breastplate", sources = { [14]=17497 } },
                { id = 37261, slot = "Hands", name = "Gloves of Radiant Light", sources = { [14]=17699 } },
                { id = 36949, slot = "Hands", name = "Gloves of the Azure-Lord", sources = { [14]=17496 } },
                { id = 36948, slot = "Head", name = "Horned Helm of Varos", sources = { [14]=17495 } },
                { id = 37262, slot = "Legs", name = "Azure Ringmail Leggings", sources = { [14]=17700 } },
                { id = 37263, slot = "Legs", name = "Legplates of the Oculus Guardian", sources = { [14]=17701 } },
                { id = 37260, slot = "Weapon", name = "Cloudstrider's Waraxe", sources = { [14]=17698 } },
            },
        },
        {
            index              = 3,
            name               = "Mage-Lord Urom",
            journalEncounterID = 624,
            achievements       = {
            },
            loot = {
                { id = 36954, slot = "Feet", name = "The Conjurer's Slippers", sources = { [14]=17501 } },
                { id = 36951, slot = "Hands", name = "Sidestepping Handguards", sources = { [14]=17498 } },
                { id = 36953, slot = "Shoulder", name = "Spaulders of Skillful Maneuvers", sources = { [14]=17500 } },
                { id = 36952, slot = "Waist", name = "Girdle of Obscuring", sources = { [14]=17499 } },
                { id = 37289, slot = "Waist", name = "Sash of Phantasmal Images", sources = { [14]=17721 } },
                { id = 37288, slot = "Wrist", name = "Catalytic Bands", sources = { [14]=17720 } },
            },
        },
        {
            index              = 4,
            name               = "Ley-Guardian Eregos",
            journalEncounterID = 625,
            achievements       = {
                { id = 1871, name = "Experienced Drake Rider", meta = true },
                { id = 2044, name = "Ruby Void", meta = true },
                { id = 2045, name = "Emerald Void", meta = true },
                { id = 2046, name = "Amber Void", meta = true },
                { id = 487, name = "The Oculus" },
                { id = 498, name = "Heroic: The Oculus" },
                { id = 39933, name = "The Oculus (char specific hidden copy)" },
            },
            loot = {
                { id = 37291, slot = "Back", name = "Ancient Dragon Spirit Cape", sources = { [14]=17722 } },
                { id = 36974, slot = "Chest", name = "Eregos' Ornamented Chestguard", sources = { [14]=17506 } },
                { id = 36973, slot = "Chest", name = "Vestments of the Scholar", sources = { [14]=17505 } },
                { id = 37363, slot = "Hands", name = "Gauntlets of Dragon Wrath", sources = { [14]=17752 } },
                { id = 37294, slot = "Head", name = "Crown of Unbridled Magic", sources = { [14]=17725 } },
                { id = 36971, slot = "Head", name = "Headguard of Westrift", sources = { [14]=17504 } },
                { id = 36969, slot = "Head", name = "Helm of the Ley-Guardian", sources = { [14]=17503 } },
                { id = 37293, slot = "Head", name = "Mask of the Watcher", sources = { [14]=17724 } },
                { id = 37362, slot = "Legs", name = "Leggings of Protective Auras", sources = { [14]=17751 } },
                { id = 37292, slot = "Legs", name = "Ley-Guardian's Legguards", sources = { [14]=17723 } },
                { id = 36975, slot = "Two-Hand", name = "Malygos' Favor", sources = { [14]=17507 } },
                { id = 37360, slot = "Two-Hand", name = "Staff of Draconic Combat", sources = { [14]=17749 } },
                { id = 36962, slot = "Two-Hand", name = "Wyrmclaw Battleaxe", sources = { [14]=17502 } },
                { id = 37361, slot = "Wrist", name = "Cuffs of Winged Levitation", sources = { [14]=17750 } },
            },
        },
    },
}
