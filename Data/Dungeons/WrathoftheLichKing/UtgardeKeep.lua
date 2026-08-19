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
            name               = "Prince Keleseth",
            journalEncounterID = 638,
            achievements       = {
                { id = 1919, name = "On The Rocks", meta = true },
            },
            loot = {
                { id = 35571, slot = "Hands", name = "Dragon Stabler's Gauntlets", sources = { [14]=16510 } },
                { id = 37180, slot = "Head", name = "Battlemap Hide Helm", sources = { [14]=17643 } },
                { id = 35572, slot = "Head", name = "Reinforced Velvet Helm", sources = { [14]=16511 } },
                { id = 37177, slot = "Ranged", name = "Wand of the San'layn", sources = { [14]=17640 } },
                { id = 37178, slot = "Waist", name = "Strategist's Belt", sources = { [14]=17641 } },
                { id = 37179, slot = "Weapon", name = "Infantry Assault Blade", sources = { [14]=17642 } },
                { id = 35570, slot = "Weapon", name = "Keleseth's Blade of Evocation", sources = { [14]=16509 } },
            },
        },
        {
            index              = 2,
            name               = "Skarvald & Dalronn",
            journalEncounterID = 639,
            achievements       = {
            },
            loot = {
                { id = 35574, slot = "Chest", name = "Chestplate of the Northern Lights", sources = { [14]=16513 } },
                { id = 37184, slot = "Chest", name = "Dalronn's Jerkin", sources = { [14]=17647 } },
                { id = 35575, slot = "Chest", name = "Skarvald's Dragonskin Habergeon", sources = { [14]=16514 } },
                { id = 37182, slot = "Head", name = "Helmet of the Constructor", sources = { [14]=17645 } },
                { id = 157555, slot = "Ranged", name = "Constructor's Worklight", sources = { [14]=93751 } },
                { id = 35573, slot = "Weapon", name = "Arm Blade of Augelmir", sources = { [14]=16512 } },
                { id = 37181, slot = "Weapon", name = "Dagger of Betrayal", sources = { [14]=17644 } },
                { id = 37183, slot = "Wrist", name = "Bindings of the Tunneler", sources = { [14]=17646 } },
            },
        },
        {
            index              = 3,
            name               = "Ingvar the Plunderer",
            journalEncounterID = 640,
            achievements       = {
                { id = 477, name = "Utgarde Keep" },
                { id = 489, name = "Heroic: Utgarde Keep" },
                { id = 39924, name = "Utgarde Keep (char specific hidden copy)" },
            },
            loot = {
                { id = 37188, slot = "Head", name = "Plunderer's Helmet", sources = { [14]=17648 } },
                { id = 37189, slot = "Legs", name = "Breeches of the Caller", sources = { [14]=17649 } },
                { id = 35577, slot = "Legs", name = "Holistic Patchwork Breeches", sources = { [14]=16516 } },
                { id = 37193, slot = "Legs", name = "Staggering Legplates", sources = { [14]=17652 } },
                { id = 37191, slot = "Ranged", name = "Drake-Mounted Crossbow", sources = { [14]=17651 } },
                { id = 35578, slot = "Shoulder", name = "Overlaid Chain Spaulders", sources = { [14]=16517 } },
                { id = 37190, slot = "Two-Hand", name = "Enraged Feral Staff", sources = { [14]=17650 } },
                { id = 35576, slot = "Two-Hand", name = "Ingvar's Monolithic Cleaver", sources = { [14]=16515 } },
                { id = 37194, slot = "Waist", name = "Sharp-Barbed Leather Belt", sources = { [14]=17653 } },
            },
        },
    },
}
