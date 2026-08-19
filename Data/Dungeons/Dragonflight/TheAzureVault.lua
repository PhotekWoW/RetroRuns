-------------------------------------------------------------------------------
-- RetroRuns Data -- The Azure Vault
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2515  |  journalInstanceID: 1203
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1203] = {
    kind              = "dungeon",
    instanceID        = 2515,
    journalInstanceID = 1203,
    name              = "The Azure Vault",
    expansion         = "Dragonflight",
    difficultyModel   = "dungeonTiered",
    patch             = "10.0.2",

    gloryMeta = {
        id   = 16295,
        name = "Glory of the Dragonflight Hero",
        rewardItemID       = 192784,
        rewardMountSpellID = 374155,
        rewardName         = "Shellack",
    },

    bosses = {
        {
            index              = 1,
            name               = "Leymor",
            journalEncounterID = 2492,
            achievements       = {
            },
            loot = {
                { id = 193637, slot = "Shoulder", name = "Spaulders of Wild Growth", sources = { [14]=180764, [15]=180764, [16]=180764 } },
                { id = 193638, slot = "Two-Hand", name = "Ley-Line Tracer", sources = { [14]=180766, [15]=180766, [16]=180766 } },
                { id = 193636, slot = "Waist", name = "Cinch of Forgotten Duty", sources = { [14]=180763, [15]=180763, [16]=180763 } },
                { id = 193635, slot = "Wrist", name = "Infused Elemental Bands", sources = { [14]=180762, [15]=180762, [16]=180762 } },
            },
        },
        {
            index              = 2,
            name               = "Azureblade",
            journalEncounterID = 2505,
            achievements       = {
            },
            loot = {
                { id = 193629, slot = "Back", name = "Cloak of Lost Devotion", sources = { [14]=180758, [15]=180758, [16]=180758 } },
                { id = 193630, slot = "Feet", name = "Twenty-Two-League Striders", sources = { [14]=180759, [15]=180759, [16]=180759 } },
                { id = 193631, slot = "Weapon", name = "Horizon Splitter", sources = { [14]=180760, [15]=180760, [16]=180760 } },
                { id = 193632, slot = "Weapon", name = "Tz'onna, Fear-Striker", sources = { [14]=180761, [15]=180761, [16]=180761 } },
            },
        },
        {
            index              = 3,
            name               = "Telash Greywing",
            journalEncounterID = 2483,
            achievements       = {
                { id = 16445, name = "Icy What You Did There", meta = true },
            },
            loot = {
                { id = 193648, slot = "Hands", name = "Azureblade's Work Gloves", sources = { [14]=180780, [15]=180780, [16]=180780 } },
                { id = 193651, slot = "Two-Hand", name = "Golden-Winged Rod", sources = { [14]=180783, [15]=180783, [16]=180783 } },
                { id = 193650, slot = "Waist", name = "Illusion Breaker's Waistguard", sources = { [14]=180782, [15]=180782, [16]=180782 } },
                { id = 193649, slot = "Wrist", name = "Mirage Bindings", sources = { [14]=180781, [15]=180781, [16]=180781 } },
            },
        },
        {
            index              = 4,
            name               = "Umbrelskul",
            journalEncounterID = 2508,
            achievements       = {
                { id = 16272, name = "The Azure Vault" },
                { id = 16273, name = "Heroic: The Azure Vault" },
                { id = 16274, name = "Mythic: The Azure Vault" },
                { id = 16330, name = "You Must Be Made of Hide", meta = true },
                { id = 16331, name = "The Cracked Crystal", meta = true },
            },
            loot = {
                { id = 193644, slot = "Chest", name = "Cuirass of Irreparable Madness", sources = { [14]=180770, [15]=180770, [16]=180770 } },
                { id = 193641, slot = "Head", name = "Headwrap of the Abandoned", sources = { [14]=180767, [15]=180767, [16]=180767 } },
                { id = 193643, slot = "Legs", name = "Stasis-Freed Leggings", sources = { [14]=180769, [15]=180769, [16]=180769 } },
                { id = 193645, slot = "Off-hand", name = "Crystalized Bulwark", sources = { [14]=180778, [15]=180778, [16]=180778 } },
                { id = 193642, slot = "Shoulder", name = "Mantle of Yearned Freedom", sources = { [14]=180768, [15]=180768, [16]=180768 } },
                { id = 193646, slot = "Weapon", name = "Refraction's Edge", sources = { [14]=180779, [15]=180779, [16]=180779 } },
            },
        },
    },
}
