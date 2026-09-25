-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackrock Caverns
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 645  |  journalInstanceID: 66
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[66] = {
    kind              = "dungeon",
    instanceID        = 645,
    journalInstanceID = 66,
    name              = "Blackrock Caverns",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.0.3",
    timewalking       = true,

    entrance = {
        mapID = 34,
        x     = 0.7220,
        y     = 0.5320,
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
            name               = "Rom'ogg Bonecrusher",
            journalEncounterID = 105,
            dungeonEncounterID = 1040,
            achievements       = {
                { id = 5281, name = "Crushing Bones and Cracking Skulls", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 56311, slot = "Chest", name = "Inquisition Robes", sources = { [14]=27651, [15]=27651 }, twSource = 165807 },
                { id = 157608, slot = "Feet", name = "Groundrumble Boots", sources = { [14]=93794, [15]=93794 }, twSource = 165819 },
                { id = 56314, slot = "Off-hand", name = "Shield of the Iron Maiden", sources = { [14]=27654, [15]=27654 }, twSource = 165810 },
                { id = 56312, slot = "Weapon", name = "Torturer's Mercy", sources = { [14]=27652, [15]=27652 }, twSource = 165808 },
                { id = 56313, slot = "Wrist", name = "Manacles of Pain", sources = { [14]=27653, [15]=27653 }, twSource = 165809 },
            },
        },
        {
            index              = 2,
            name               = "Corla, Herald of Twilight",
            journalEncounterID = 106,
            dungeonEncounterID = 1038,
            achievements       = {
            },
            loot = {
                { id = 56298, slot = "Head", name = "Renouncer's Cowl", sources = { [14]=27642, [15]=27642 }, twSource = 165798 },
                { id = 56296, slot = "Ranged", name = "Corla's Baton", sources = { [14]=27640, [15]=27640 }, twSource = 165796 },
                { id = 56297, slot = "Wrist", name = "Armbands of Change", sources = { [14]=27641, [15]=27641 }, twSource = 165797 },
            },
        },
        {
            index              = 3,
            name               = "Karsh Steelbender",
            journalEncounterID = 107,
            dungeonEncounterID = 1039,
            achievements       = {
                { id = 5283, name = "Too Hot to Handle", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56304, slot = "Back", name = "Burned Gatherings", sources = { [14]=27646, [15]=27646 }, twSource = 165802 },
                { id = 157610, slot = "Chest", name = "Heat-Shielded Tunic", sources = { [14]=93796, [15]=93796 }, twSource = 165820 },
                { id = 56303, slot = "Legs", name = "Heat Wave Leggings", sources = { [14]=27645, [15]=27645 }, twSource = 165801 },
                { id = 56302, slot = "Weapon", name = "Steelbender's Masterpiece", sources = { [14]=27644, [15]=27644 }, twSource = 165800 },
                { id = 56301, slot = "Wrist", name = "Bracers of Cooled Anger", sources = { [14]=27643, [15]=27643 }, twSource = 165799 },
            },
        },
        {
            index              = 4,
            name               = "Beauty",
            journalEncounterID = 108,
            dungeonEncounterID = 1037,
            achievements       = {
            },
            loot = {
                { id = 56308, slot = "Chest", name = "Beauty's Plate", sources = { [14]=27649, [15]=27649 }, twSource = 165805 },
                { id = 157607, slot = "Chest", name = "Gently Gnawed Hauberk", sources = { [14]=93793, [15]=93793 }, twSource = 165818 },
                { id = 56309, slot = "Legs", name = "Beauty's Chew Toy", sources = { [14]=27650, [15]=27650 }, twSource = 165806 },
                { id = 56306, slot = "Off-hand", name = "Beauty's Favorite Bone", sources = { [14]=27648, [15]=27648 }, twSource = 165804 },
                { id = 56305, slot = "Waist", name = "Beauty's Silken Ribbon", sources = { [14]=27647, [15]=27647 }, twSource = 165803 },
            },
        },
        {
            index              = 5,
            name               = "Ascendant Lord Obsidius",
            journalEncounterID = 109,
            dungeonEncounterID = 1036,
            achievements       = {
                { id = 5284, name = "Ascendant Descending", meta = true, soloable = "yes" },
                { id = 5282, name = "Arrested Development", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56315, slot = "Back", name = "Twitching Shadows", sources = { [14]=27655, [15]=27655 }, twSource = 165811 },
                { id = 56323, slot = "Hands", name = "Clutches of Dying Light", sources = { [14]=27660, [15]=27660 }, twSource = 165816 },
                { id = 56321, slot = "Head", name = "Willowy Crown", sources = { [14]=27658, [15]=27658 }, twSource = 165814 },
                { id = 56322, slot = "Off-hand", name = "Crepuscular Shield", sources = { [14]=27659, [15]=27659 }, twSource = 165815 },
                { id = 56317, slot = "Ranged", name = "Amber Messenger", sources = { [14]=27656, [15]=27656 }, twSource = 165812 },
                { id = 56324, slot = "Shoulder", name = "Kyrstel Mantle", sources = { [14]=27661, [15]=27661 }, twSource = 165817 },
                { id = 56318, slot = "Shoulder", name = "Raz's Pauldrons", sources = { [14]=27657, [15]=27657 }, twSource = 165813 },
            },
        },
    },
}
