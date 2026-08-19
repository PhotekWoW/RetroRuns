-------------------------------------------------------------------------------
-- RetroRuns Data -- Azjol-Nerub
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 601  |  journalInstanceID: 272
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[272] = {
    kind              = "dungeon",
    instanceID        = 601,
    journalInstanceID = 272,
    name              = "Azjol-Nerub",
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
            name               = "Krik'thir the Gatewatcher",
            journalEncounterID = 585,
            achievements       = {
                { id = 1296, name = "Watch Him Die", meta = true },
            },
            loot = {
                { id = 37219, slot = "Chest", name = "Custodian's Chestpiece", sources = { [14]=17672 } },
                { id = 35657, slot = "Feet", name = "Exquisite Spider-Silk Footwraps", sources = { [14]=16580 } },
                { id = 37218, slot = "Feet", name = "Stone-Worn Footwraps", sources = { [14]=17671 } },
                { id = 35656, slot = "Hands", name = "Aura Focused Gauntlets", sources = { [14]=16579 } },
                { id = 37216, slot = "Off-hand", name = "Facade Shield of Glyphs", sources = { [14]=17669 } },
                { id = 157582, slot = "Shoulder", name = "Nerubian Mantle", sources = { [14]=93773 } },
                { id = 35655, slot = "Weapon", name = "Cobweb Machete", sources = { [14]=16578 } },
                { id = 37217, slot = "Wrist", name = "Golden Limb Bands", sources = { [14]=17670 } },
            },
        },
        {
            index              = 2,
            name               = "Hadronox",
            journalEncounterID = 586,
            achievements       = {
                { id = 1297, name = "Hadronox Denied", meta = true },
            },
            loot = {
                { id = 37222, slot = "Chest", name = "Egg Sac Robes", sources = { [14]=17674 } },
                { id = 35659, slot = "Feet", name = "Treads of Aspiring Heights", sources = { [14]=16582 } },
                { id = 37230, slot = "Hands", name = "Grotto Mist Gloves", sources = { [14]=17681 } },
                { id = 157581, slot = "Hands", name = "Skittering Gauntlets", sources = { [14]=93772 } },
                { id = 37221, slot = "Legs", name = "Hollowed Mandible Legplates", sources = { [14]=17673 } },
                { id = 35660, slot = "Shoulder", name = "Spinneret Epaulets", sources = { [14]=16583 } },
                { id = 35658, slot = "Two-Hand", name = "Life-Staff of the Web Lair", sources = { [14]=16581 } },
            },
        },
        {
            index              = 3,
            name               = "Anub'arak",
            journalEncounterID = 587,
            achievements       = {
                { id = 1860, name = "Gotta Go!", meta = true },
                { id = 480, name = "Azjol-Nerub" },
                { id = 491, name = "Heroic: Azjol-Nerub" },
                { id = 39927, name = "Azjol-Nerub (char specific hidden copy)" },
            },
            loot = {
                { id = 37236, slot = "Chest", name = "Insect Vestments", sources = { [14]=17684 } },
                { id = 37237, slot = "Head", name = "Chitin Shell Greathelm", sources = { [14]=17685 } },
                { id = 37238, slot = "Ranged", name = "Rod of the Fallen Monarch", sources = { [14]=17686 } },
                { id = 37241, slot = "Waist", name = "Ancient Aligned Girdle", sources = { [14]=17689 } },
                { id = 35663, slot = "Waist", name = "Charmed Silken Cord", sources = { [14]=16585 } },
                { id = 37242, slot = "Waist", name = "Sash of the Servant", sources = { [14]=17690 } },
                { id = 35662, slot = "Waist", name = "Wing Cover Girdle", sources = { [14]=16584 } },
                { id = 37235, slot = "Weapon", name = "Crypt Lord's Deft Blade", sources = { [14]=17683 } },
                { id = 37240, slot = "Wrist", name = "Flamebeard's Bracers", sources = { [14]=17688 } },
            },
        },
    },
}
