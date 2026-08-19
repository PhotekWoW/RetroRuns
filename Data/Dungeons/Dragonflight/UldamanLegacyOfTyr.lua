-------------------------------------------------------------------------------
-- RetroRuns Data -- Uldaman: Legacy of Tyr
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2451  |  journalInstanceID: 1197
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1197] = {
    kind              = "dungeon",
    instanceID        = 2451,
    journalInstanceID = 1197,
    name              = "Uldaman: Legacy of Tyr",
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
            name               = "The Lost Dwarves",
            journalEncounterID = 2475,
            achievements       = {
            },
            loot = {
                { id = 193817, slot = "Feet", name = "Treads of the Swift", sources = { [14]=180911, [15]=180911, [16]=180911 } },
                { id = 193819, slot = "Head", name = "Old Seafarer's Headpiece", sources = { [14]=180912, [15]=180912, [16]=180912 } },
                { id = 193820, slot = "Off-hand", name = "Stout Shield", sources = { [14]=180913, [15]=180913, [16]=180913 } },
                { id = 193816, slot = "Waist", name = "Lost Hero's Waist Wrap", sources = { [14]=180910, [15]=180910, [16]=180910 } },
                { id = 193812, slot = "Wrist", name = "Fierce Boreal Armguards", sources = { [14]=180875, [15]=180875, [16]=180875 } },
            },
        },
        {
            index              = 2,
            name               = "Bromach",
            journalEncounterID = 2487,
            achievements       = {
                { id = 16337, name = "It's a Trogg Eat Trogg World", meta = true },
            },
            loot = {
                { id = 193818, slot = "Hands", name = "Rock Shovelers", sources = { [14]=180874, [15]=180874, [16]=180874 } },
                { id = 193810, slot = "Legs", name = "Miner's Sturdy Trousers", sources = { [14]=180907, [15]=180907, [16]=180907 } },
                { id = 193668, slot = "Waist", name = "Troggskin Waistband", sources = { [14]=180797, [15]=180797, [16]=180797 } },
                { id = 193814, slot = "Weapon", name = "Unearthed Trogglodicer", sources = { [14]=180909, [15]=180909, [16]=180909 } },
                { id = 193813, slot = "Wrist", name = "Excavated Earthen Wristslabs", sources = { [14]=180908, [15]=180908, [16]=180908 } },
            },
        },
        {
            index              = 3,
            name               = "Sentinel Talondras",
            journalEncounterID = 2484,
            achievements       = {
                { id = 16282, name = "No, You're Stunning!", meta = true },
            },
            loot = {
                { id = 193806, slot = "Feet", name = "Ancient Crosswrapped Sandals", sources = { [14]=180904, [15]=180904, [16]=180904 } },
                { id = 193807, slot = "Shoulder", name = "Shoulders of Animated Stone", sources = { [14]=180905, [15]=180905, [16]=180905 } },
                { id = 193808, slot = "Two-Hand", name = "Sentinel's Battle Lance", sources = { [14]=180906, [15]=180906, [16]=180906 } },
            },
        },
        {
            index              = 4,
            name               = "Emberon",
            journalEncounterID = 2476,
            achievements       = {
            },
            loot = {
                { id = 193795, slot = "Hands", name = "Keeper's Iron Grips", sources = { [14]=180896, [15]=180896, [16]=180896 } },
                { id = 193811, slot = "Legs", name = "Annora's Punctured Leggings", sources = { [14]=180876, [15]=180876, [16]=180876 } },
                { id = 193796, slot = "Ranged", name = "Vault Piercer", sources = { [14]=180897, [15]=180897, [16]=180897 } },
                { id = 193794, slot = "Waist", name = "Gatekeeper's Girdle", sources = { [14]=180895, [15]=180895, [16]=180895 } },
                { id = 193797, slot = "Weapon", name = "Bouldersplitter", sources = { [14]=180898, [15]=180898, [16]=180898 } },
                { id = 193792, slot = "Wrist", name = "Animated Shackles", sources = { [14]=180894, [15]=180894, [16]=180894 } },
            },
        },
        {
            index              = 5,
            name               = "Chrono-Lord Deios",
            journalEncounterID = 2479,
            achievements       = {
                { id = 16278, name = "Uldaman: Legacy of Tyr" },
                { id = 16279, name = "Heroic: Uldaman: Legacy of Tyr" },
                { id = 16280, name = "Mythic: Uldaman: Legacy of Tyr" },
                { id = 16281, name = "Like Sands Through the Hourglass", meta = true },
            },
            loot = {
                { id = 193801, slot = "Chest", name = "Fatebound Chainmail", sources = { [14]=180901, [15]=180901, [16]=180901 } },
                { id = 193800, slot = "Head", name = "Vision of Foreshadowed Ends", sources = { [14]=180900, [15]=180900, [16]=180900 } },
                { id = 193799, slot = "Legs", name = "Crazed Traveler's Legwraps", sources = { [14]=180899, [15]=180899, [16]=180899 } },
                { id = 193802, slot = "Shoulder", name = "Pauldrons of Immutable Truth", sources = { [14]=180902, [15]=180902, [16]=180902 } },
                { id = 193803, slot = "Two-Hand", name = "Infinite Dragonspire", sources = { [14]=180903, [15]=180903, [16]=180903 } },
            },
        },
    },
}
