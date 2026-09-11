-------------------------------------------------------------------------------
-- RetroRuns Data -- The Stonecore
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 725  |  journalInstanceID: 67
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[67] = {
    kind              = "dungeon",
    instanceID        = 725,
    journalInstanceID = 67,
    name              = "The Stonecore",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "4.0.3",
    timewalking       = true,

    entrance = {
        mapID = 207,
        x     = 0.4783,
        y     = 0.5190,
    },

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Corborus",
            journalEncounterID = 110,
            achievements       = {
            },
            loot = {
                { id = 56331, slot = "Hands", name = "Dolomite Adorned Gloves", sources = { [14]=27666, [15]=27666 } },
                { id = 56330, slot = "Shoulder", name = "Cinnabar Shoulders", sources = { [14]=27665, [15]=27665 } },
                { id = 157592, slot = "Weapon", name = "Crackling Geode Mace", sources = { [14]=93782, [15]=93782 } },
                { id = 56329, slot = "Weapon", name = "Fist of Pained Senses", sources = { [14]=27664, [15]=27664 } },
                { id = 157590, slot = "Wrist", name = "Crystalgrinder Bracers", sources = { [14]=93781, [15]=93781 } },
            },
        },
        {
            index              = 2,
            name               = "Slabhide",
            journalEncounterID = 111,
            achievements       = {
            },
            loot = {
                { id = 133231, slot = "Back", name = "Skin of Stone", sources = { [24]=76602 } },
                { id = 56334, slot = "Hands", name = "Deep Delving Gloves", sources = { [14]=27667, [15]=27667 } },
                { id = 56336, slot = "Hands", name = "Hematite Plate Gloves", sources = { [14]=27669, [15]=27669 } },
                { id = 157594, slot = "Legs", name = "Earth-Strength Legguards", sources = { [14]=93784, [15]=93784 } },
                { id = 133230, slot = "Ranged", name = "Wand of Dark Worship", sources = { [24]=76601 } },
                { id = 157593, slot = "Shoulder", name = "Crystalpowder Amice", sources = { [14]=93783, [15]=93783 } },
                { id = 56335, slot = "Weapon", name = "Quicksilver Blade", sources = { [14]=27668, [15]=27668 } },
            },
            specialLoot = {
                { id = 63043, kind = "mount", name = "Reins of the Vitreous Stone Drake" },
            },
        },
        {
            index              = 3,
            name               = "Ozruk",
            journalEncounterID = 112,
            achievements       = {
            },
            loot = {
                { id = 56342, slot = "Two-Hand", name = "Sword of the Bottomless Pit", sources = { [14]=27672, [15]=27672 } },
                { id = 56341, slot = "Waist", name = "Belt of the Ringworm", sources = { [14]=27671, [15]=27671 } },
                { id = 133229, slot = "Weapon", name = "Heavy Geode Mace", sources = { [24]=76600 } },
                { id = 56340, slot = "Wrist", name = "Elementium Scale Bracers", sources = { [14]=27670, [15]=27670 } },
            },
        },
        {
            index              = 4,
            name               = "High Priestess Azil",
            journalEncounterID = 113,
            achievements       = {
                { id = 5287, name = "Rotten to the Core", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56348, slot = "Feet", name = "Slippers of the Twilight Prophet", sources = { [14]=27676, [15]=27676 } },
                { id = 56352, slot = "Head", name = "Cowl of the Unseen World", sources = { [14]=27678, [15]=27678 } },
                { id = 56344, slot = "Head", name = "Helm of Numberless Shadows", sources = { [14]=27674, [15]=27674 } },
                { id = 56349, slot = "Off-hand", name = "Prophet's Scepter", sources = { [14]=27677, [15]=27677 } },
                { id = 56343, slot = "Two-Hand", name = "Darkling Staff", sources = { [14]=27673, [15]=27673 } },
                { id = 56346, slot = "Weapon", name = "Elementium Fang", sources = { [14]=27675, [15]=27675 } },
            },
        },
    },
}
