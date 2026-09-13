-------------------------------------------------------------------------------
-- RetroRuns Data -- Utgarde Keep
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 574  |  journalInstanceID: 285
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[285] = {
    kind              = "dungeon",
    instanceID        = 574,
    journalInstanceID = 285,
    name              = "Utgarde Keep",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    timewalking       = true,

    entrance = {
        mapID = 117,
        x     = 0.5717,
        y     = 0.4613,
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
            name               = "Prince Keleseth",
            journalEncounterID = 638,
            achievements       = {
                { id = 1919, name = "On The Rocks", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 35571, slot = "Hands", name = "Dragon Stabler's Gauntlets", sources = { [14]=16510, [15]=16510 }, twSource = 165743 },
                { id = 37180, slot = "Head", name = "Battlemap Hide Helm", sources = { [14]=17643, [15]=17643 }, twSource = 165754 },
                { id = 35572, slot = "Head", name = "Reinforced Velvet Helm", sources = { [14]=16511, [15]=16511 }, twSource = 165744 },
                { id = 37177, slot = "Ranged", name = "Wand of the San'layn", sources = { [14]=17640, [15]=17640 }, twSource = 165751 },
                { id = 37178, slot = "Waist", name = "Strategist's Belt", sources = { [14]=17641, [15]=17641 }, twSource = 165752 },
                { id = 37179, slot = "Weapon", name = "Infantry Assault Blade", sources = { [14]=17642, [15]=17642 }, twSource = 165753 },
                { id = 35570, slot = "Weapon", name = "Keleseth's Blade of Evocation", sources = { [14]=16509, [15]=16509 }, twSource = 165742 },
            },
        },
        {
            index              = 2,
            name               = "Skarvald & Dalronn",
            journalEncounterID = 639,
            aliases            = { "Skarvold & Dalronn" },
            scenarioCriteriaID = 27890,
            achievements       = {
            },
            loot = {
                { id = 35574, slot = "Chest", name = "Chestplate of the Northern Lights", sources = { [14]=16513, [15]=16513 }, twSource = 165746 },
                { id = 37184, slot = "Chest", name = "Dalronn's Jerkin", sources = { [14]=17647, [15]=17647 }, twSource = 165758 },
                { id = 35575, slot = "Chest", name = "Skarvald's Dragonskin Habergeon", sources = { [14]=16514, [15]=16514 }, twSource = 165747 },
                { id = 37182, slot = "Head", name = "Helmet of the Constructor", sources = { [14]=17645, [15]=17645 }, twSource = 165756 },
                { id = 157555, slot = "Ranged", name = "Constructor's Worklight", sources = { [14]=93751, [15]=93751 }, twSource = 165765 },
                { id = 35573, slot = "Weapon", name = "Arm Blade of Augelmir", sources = { [14]=16512, [15]=16512 }, twSource = 165745 },
                { id = 37181, slot = "Weapon", name = "Dagger of Betrayal", sources = { [14]=17644, [15]=17644 }, twSource = 165755 },
                { id = 37183, slot = "Wrist", name = "Bindings of the Tunneler", sources = { [14]=17646, [15]=17646 }, twSource = 165757 },
            },
        },
        {
            index              = 3,
            name               = "Ingvar the Plunderer",
            journalEncounterID = 640,
            achievements       = {
            },
            loot = {
                { id = 37188, slot = "Head", name = "Plunderer's Helmet", sources = { [14]=17648, [15]=17648 }, twSource = 165759 },
                { id = 37189, slot = "Legs", name = "Breeches of the Caller", sources = { [14]=17649, [15]=17649 }, twSource = 165760 },
                { id = 35577, slot = "Legs", name = "Holistic Patchwork Breeches", sources = { [14]=16516, [15]=16516 }, twSource = 165749 },
                { id = 37193, slot = "Legs", name = "Staggering Legplates", sources = { [14]=17652, [15]=17652 }, twSource = 165763 },
                { id = 37191, slot = "Ranged", name = "Drake-Mounted Crossbow", sources = { [14]=17651, [15]=17651 }, twSource = 165762 },
                { id = 35578, slot = "Shoulder", name = "Overlaid Chain Spaulders", sources = { [14]=16517, [15]=16517 }, twSource = 165750 },
                { id = 37190, slot = "Two-Hand", name = "Enraged Feral Staff", sources = { [14]=17650, [15]=17650 }, twSource = 165761 },
                { id = 35576, slot = "Two-Hand", name = "Ingvar's Monolithic Cleaver", sources = { [14]=16515, [15]=16515 }, twSource = 165748 },
                { id = 37194, slot = "Waist", name = "Sharp-Barbed Leather Belt", sources = { [14]=17653, [15]=17653 }, twSource = 165764 },
            },
        },
    },
}
