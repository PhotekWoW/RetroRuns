-------------------------------------------------------------------------------
-- RetroRuns Data -- Brackenhide Hollow
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2520  |  journalInstanceID: 1196
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1196] = {
    kind              = "dungeon",
    instanceID        = 2520,
    journalInstanceID = 1196,
    name              = "Brackenhide Hollow",
    expansion         = "Dragonflight",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "10.0.2",
    timewalking       = true,

    entrance = {
        mapID = 2024,
        x     = 0.1147,
        y     = 0.4893,
    },

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
            name               = "Hackclaw's War-Band",
            journalEncounterID = 2471,
            dungeonEncounterID = 2570,
            achievements       = {
                { id = 16296, name = "Growlbossify", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 193673, slot = "Feet", name = "Ravenous Pursuer's Footwraps", sources = { [14]=180799, [15]=180799, [16]=180799 } },
                { id = 193674, slot = "Two-Hand", name = "Ancestral Stoneshaper", sources = { [14]=180800, [15]=180800, [16]=180800 } },
                { id = 193675, slot = "Two-Hand", name = "Poached Kalu'ak Spear", sources = { [14]=180801, [15]=180801, [16]=180801 } },
            },
        },
        {
            index              = 2,
            name               = "Treemouth",
            journalEncounterID = 2473,
            dungeonEncounterID = 2568,
            achievements       = {
                { id = 16430, name = "All Bark, All Bite", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 193654, slot = "Feet", name = "Ancient Rotwalkers", sources = { [14]=180785, [15]=180785, [16]=180785 } },
                { id = 193653, slot = "Head", name = "Mask of Imperishable Leaves", sources = { [14]=180784, [15]=180784, [16]=180784 } },
                { id = 193655, slot = "Shoulder", name = "Rooted Shoulders of Putrefaction", sources = { [14]=180786, [15]=180786, [16]=180786 } },
                { id = 193658, slot = "Two-Hand", name = "Bough of Deterioration", sources = { [14]=180789, [15]=180789, [16]=180789 } },
                { id = 193656, slot = "Waist", name = "Swollen Bark Clasp", sources = { [14]=180787, [15]=180787, [16]=180787 } },
                { id = 193657, slot = "Wrist", name = "Binders of the Moldering", sources = { [14]=180788, [15]=180788, [16]=180788 } },
            },
        },
        {
            index              = 3,
            name               = "Gutshot",
            journalEncounterID = 2472,
            dungeonEncounterID = 2567,
            achievements       = {
            },
            loot = {
                { id = 193670, slot = "Ranged", name = "Gutshot's Trophy Hunter", sources = { [14]=180791, [15]=180791, [16]=180791 } },
                { id = 193667, slot = "Shoulder", name = "Boastful Stalker's Epaulets", sources = { [14]=180796, [15]=180796, [16]=180796 } },
                { id = 193669, slot = "Waist", name = "Trapmaster's Utility Belt", sources = { [14]=180798, [15]=180798, [16]=180798 } },
                { id = 193793, slot = "Wrist", name = "Ferocious Hyena Hidebinders", sources = { [14]=180873, [15]=180873, [16]=180873 } },
            },
        },
        {
            index              = 4,
            name               = "Decatriarch Wratheye",
            journalEncounterID = 2474,
            dungeonEncounterID = 2569,
            achievements       = {
                { id = 16404, name = "So You Can Kill This in a Way That Matters...", meta = true, soloable = "kinda" },
                { id = 16110, name = "Subscribed to Hyena Facts", soloable = "yes" },
                { id = 16762, name = "The Vegetarian Diet", soloable = "yes" },
            },
            loot = {
                { id = 193661, slot = "Hands", name = "Blightweaver's Clutches", sources = { [14]=180792, [15]=180792, [16]=180792 } },
                { id = 193663, slot = "Head", name = "Decay Mother's Wrathful Gaze", sources = { [14]=180794, [15]=180794, [16]=180794 } },
                { id = 193662, slot = "Legs", name = "Tassets of Densified Ooze", sources = { [14]=180793, [15]=180793, [16]=180793 } },
                { id = 193665, slot = "Weapon", name = "Decatriarch's Bone Pestle", sources = { [14]=180790, [15]=180790, [16]=180790 } },
                { id = 193664, slot = "Weapon", name = "Rot-Carved Totemic Shank", sources = { [14]=180795, [15]=180795, [16]=180795 } },
            },
            specialLoot = {
                { id = 197396, kind = "manuscript", name = "Renewed Proto-Drake: Skyterror Pattern", questID = 69597 },
                { id = 197598, kind = "manuscript", name = "Windborne Velocidrake: Gray Hair", questID = 69802 },
            },
        },
    },
}
