-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackrock Caverns
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
    patch             = "4.0.3",

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
            achievements       = {
                { id = 5281, name = "Crushing Bones and Cracking Skulls", meta = true },
            },
            loot = {
                { id = 56311, slot = "Chest", name = "Inquisition Robes", sources = { [14]=27651 } },
                { id = 157608, slot = "Feet", name = "Groundrumble Boots", sources = { [14]=93794 } },
                { id = 56314, slot = "Off-hand", name = "Shield of the Iron Maiden", sources = { [14]=27654 } },
                { id = 56312, slot = "Weapon", name = "Torturer's Mercy", sources = { [14]=27652 } },
                { id = 56313, slot = "Wrist", name = "Manacles of Pain", sources = { [14]=27653 } },
            },
        },
        {
            index              = 2,
            name               = "Corla, Herald of Twilight",
            journalEncounterID = 106,
            achievements       = {
            },
            loot = {
                { id = 56298, slot = "Head", name = "Renouncer's Cowl", sources = { [14]=27642 } },
                { id = 56296, slot = "Ranged", name = "Corla's Baton", sources = { [14]=27640 } },
                { id = 56297, slot = "Wrist", name = "Armbands of Change", sources = { [14]=27641 } },
            },
        },
        {
            index              = 3,
            name               = "Karsh Steelbender",
            journalEncounterID = 107,
            achievements       = {
                { id = 5283, name = "Too Hot to Handle", meta = true },
            },
            loot = {
                { id = 56304, slot = "Back", name = "Burned Gatherings", sources = { [14]=27646 } },
                { id = 157610, slot = "Chest", name = "Heat-Shielded Tunic", sources = { [14]=93796 } },
                { id = 56303, slot = "Legs", name = "Heat Wave Leggings", sources = { [14]=27645 } },
                { id = 56302, slot = "Weapon", name = "Steelbender's Masterpiece", sources = { [14]=27644 } },
                { id = 56301, slot = "Wrist", name = "Bracers of Cooled Anger", sources = { [14]=27643 } },
            },
        },
        {
            index              = 4,
            name               = "Beauty",
            journalEncounterID = 108,
            achievements       = {
            },
            loot = {
                { id = 56308, slot = "Chest", name = "Beauty's Plate", sources = { [14]=27649 } },
                { id = 157607, slot = "Chest", name = "Gently Gnawed Hauberk", sources = { [14]=93793 } },
                { id = 56309, slot = "Legs", name = "Beauty's Chew Toy", sources = { [14]=27650 } },
                { id = 56306, slot = "Off-hand", name = "Beauty's Favorite Bone", sources = { [14]=27648 } },
                { id = 56305, slot = "Waist", name = "Beauty's Silken Ribbon", sources = { [14]=27647 } },
            },
        },
        {
            index              = 5,
            name               = "Ascendant Lord Obsidius",
            journalEncounterID = 109,
            achievements       = {
                { id = 4833, name = "Blackrock Caverns" },
                { id = 5060, name = "Heroic: Blackrock Caverns" },
                { id = 5284, name = "Ascendant Descending", meta = true },
                { id = 5282, name = "Arrested Development", meta = true },
            },
            loot = {
                { id = 56315, slot = "Back", name = "Twitching Shadows", sources = { [14]=27655 } },
                { id = 56323, slot = "Hands", name = "Clutches of Dying Light", sources = { [14]=27660 } },
                { id = 56321, slot = "Head", name = "Willowy Crown", sources = { [14]=27658 } },
                { id = 56322, slot = "Off-hand", name = "Crepuscular Shield", sources = { [14]=27659 } },
                { id = 56317, slot = "Ranged", name = "Amber Messenger", sources = { [14]=27656 } },
                { id = 56324, slot = "Shoulder", name = "Kyrstel Mantle", sources = { [14]=27661 } },
                { id = 56318, slot = "Shoulder", name = "Raz's Pauldrons", sources = { [14]=27657 } },
            },
        },
    },
}
