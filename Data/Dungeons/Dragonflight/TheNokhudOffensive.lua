-------------------------------------------------------------------------------
-- RetroRuns Data -- The Nokhud Offensive
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2516  |  journalInstanceID: 1198
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1198] = {
    kind              = "dungeon",
    instanceID        = 2516,
    journalInstanceID = 1198,
    name              = "The Nokhud Offensive",
    expansion         = "Dragonflight",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "10.0.2",

    entrance = {
        mapID = 2023,
        x     = 0.6085,
        y     = 0.3896,
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
            name               = "Granyth",
            journalEncounterID = 2498,
            dungeonEncounterID = 2637,
            achievements       = {
            },
            loot = {
                { id = 193692, slot = "Head", name = "Stoneroot Headdress", sources = { [14]=180812, [15]=180812, [16]=180812 } },
                { id = 193694, slot = "Legs", name = "Drake Hunter's Greaves", sources = { [14]=180814, [15]=180814, [16]=180814 } },
                { id = 193690, slot = "Shoulder", name = "Drake Hunter Shoulderpads", sources = { [14]=180810, [15]=180810, [16]=180810 } },
                { id = 193695, slot = "Two-Hand", name = "Quarryslayer Glaive", sources = { [14]=180815, [15]=180815, [16]=180815 } },
                { id = 193693, slot = "Wrist", name = "Shikaar Ranger Bracers", sources = { [14]=180813, [15]=180813, [16]=180813 } },
            },
        },
        {
            index              = 2,
            name               = "The Raging Tempest",
            journalEncounterID = 2497,
            dungeonEncounterID = 2636,
            achievements       = {
                { id = 16447, name = "What Are The Chances...", meta = true, soloable = "no" },
            },
            loot = {
                { id = 193699, slot = "Two-Hand", name = "Staff of Violent Storms", sources = { [14]=180817, [15]=180817, [16]=180817 } },
                { id = 193700, slot = "Weapon", name = "Strike Twice", sources = { [14]=180818, [15]=180818, [16]=180818 } },
                { id = 193698, slot = "Wrist", name = "Thrashing Wind Vambraces", sources = { [14]=180816, [15]=180816, [16]=180816 } },
            },
        },
        {
            index              = 3,
            name               = "Teera and Maruuk",
            journalEncounterID = 2478,
            dungeonEncounterID = 2581,
            achievements       = {
                { id = 16456, name = "Weapons of the Maruukai", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 193680, slot = "Chest", name = "Tunic of the Eternal Hunt", sources = { [14]=180802, [15]=180802, [16]=180802 } },
                { id = 193681, slot = "Ranged", name = "Bow of the First Khanam", sources = { [14]=180803, [15]=180803, [16]=180803 } },
            },
        },
        {
            index              = 4,
            name               = "Balakar Khan",
            journalEncounterID = 2477,
            dungeonEncounterID = 2580,
            achievements       = {
                { id = 16602, name = "Nokhud Deed Goes Unnoticed", meta = true, soloable = "kinda" },
                { id = 16620, name = "Ohuna Incubation", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 193683, slot = "Chest", name = "Blessed Ohn'ir Robes", sources = { [14]=180804, [15]=180804, [16]=180804 } },
                { id = 193685, slot = "Feet", name = "Lightning-Charged Striders", sources = { [14]=180806, [15]=180806, [16]=180806 } },
                { id = 193684, slot = "Legs", name = "Legguards of Adamant Rule", sources = { [14]=180805, [15]=180805, [16]=180805 } },
                { id = 193686, slot = "Shoulder", name = "Nokhud Traditionalist's Pauldrons", sources = { [14]=180807, [15]=180807, [16]=180807 } },
                { id = 193687, slot = "Weapon", name = "Koroleth's Crackling Dagger", sources = { [14]=180808, [15]=180808, [16]=180808 } },
                { id = 193688, slot = "Weapon", name = "Stormslash", sources = { [14]=180809, [15]=180809, [16]=180809 } },
            },
            specialLoot = {
                { id = 197625, kind = "manuscript", name = "Windborne Velocidrake: Feathery Tail", questID = 69829 },
                { id = 197635, kind = "manuscript", name = "Windborne Velocidrake: Reaver Pattern", questID = 69846 },
            },
        },
    },
}
