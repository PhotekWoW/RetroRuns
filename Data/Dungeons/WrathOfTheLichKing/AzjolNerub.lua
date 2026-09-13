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
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    timewalking       = true,

    entrance = {
        mapID = 115,
        x     = 0.2590,
        y     = 0.5099,
    },

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
                { id = 1296, name = "Watch Him Die", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37219, slot = "Chest", name = "Custodian's Chestpiece", sources = { [14]=17672, [15]=17672 }, twSource = 165729 },
                { id = 35657, slot = "Feet", name = "Exquisite Spider-Silk Footwraps", sources = { [14]=16580, [15]=16580 }, twSource = 165720 },
                { id = 37218, slot = "Feet", name = "Stone-Worn Footwraps", sources = { [14]=17671, [15]=17671 }, twSource = 165728 },
                { id = 35656, slot = "Hands", name = "Aura Focused Gauntlets", sources = { [14]=16579, [15]=16579 }, twSource = 165719 },
                { id = 37216, slot = "Off-hand", name = "Facade Shield of Glyphs", sources = { [14]=17669, [15]=17669 }, twSource = 165726 },
                { id = 157582, slot = "Shoulder", name = "Nerubian Mantle", sources = { [14]=93773, [15]=93773 }, twSource = 165741 },
                { id = 35655, slot = "Weapon", name = "Cobweb Machete", sources = { [14]=16578, [15]=16578 }, twSource = 165718 },
                { id = 37217, slot = "Wrist", name = "Golden Limb Bands", sources = { [14]=17670, [15]=17670 }, twSource = 165727 },
            },
        },
        {
            index              = 2,
            name               = "Hadronox",
            journalEncounterID = 586,
            achievements       = {
                { id = 1297, name = "Hadronox Denied", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37222, slot = "Chest", name = "Egg Sac Robes", sources = { [14]=17674, [15]=17674 }, twSource = 165731 },
                { id = 35659, slot = "Feet", name = "Treads of Aspiring Heights", sources = { [14]=16582, [15]=16582 }, twSource = 165722 },
                { id = 37230, slot = "Hands", name = "Grotto Mist Gloves", sources = { [14]=17681, [15]=17681 }, twSource = 165732 },
                { id = 157581, slot = "Hands", name = "Skittering Gauntlets", sources = { [14]=93772, [15]=93772 }, twSource = 165740 },
                { id = 37221, slot = "Legs", name = "Hollowed Mandible Legplates", sources = { [14]=17673, [15]=17673 }, twSource = 165730 },
                { id = 35660, slot = "Shoulder", name = "Spinneret Epaulets", sources = { [14]=16583, [15]=16583 }, twSource = 165723 },
                { id = 35658, slot = "Two-Hand", name = "Life-Staff of the Web Lair", sources = { [14]=16581, [15]=16581 }, twSource = 165721 },
            },
        },
        {
            index              = 3,
            name               = "Anub'arak",
            journalEncounterID = 587,
            achievements       = {
                { id = 1860, name = "Gotta Go!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37236, slot = "Chest", name = "Insect Vestments", sources = { [14]=17684, [15]=17684 }, twSource = 165734 },
                { id = 37237, slot = "Head", name = "Chitin Shell Greathelm", sources = { [14]=17685, [15]=17685 }, twSource = 165735 },
                { id = 37238, slot = "Ranged", name = "Rod of the Fallen Monarch", sources = { [14]=17686, [15]=17686 }, twSource = 165736 },
                { id = 37241, slot = "Waist", name = "Ancient Aligned Girdle", sources = { [14]=17689, [15]=17689 }, twSource = 165738 },
                { id = 35663, slot = "Waist", name = "Charmed Silken Cord", sources = { [14]=16585, [15]=16585 }, twSource = 165725 },
                { id = 37242, slot = "Waist", name = "Sash of the Servant", sources = { [14]=17690, [15]=17690 }, twSource = 165739 },
                { id = 35662, slot = "Waist", name = "Wing Cover Girdle", sources = { [14]=16584, [15]=16584 }, twSource = 165724 },
                { id = 37235, slot = "Weapon", name = "Crypt Lord's Deft Blade", sources = { [14]=17683, [15]=17683 }, twSource = 165733 },
                { id = 37240, slot = "Wrist", name = "Flamebeard's Bracers", sources = { [14]=17688, [15]=17688 }, twSource = 165737 },
            },
        },
    },
}
