-------------------------------------------------------------------------------
-- RetroRuns Data -- The Vortex Pinnacle
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 657  |  journalInstanceID: 68
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[68] = {
    kind              = "dungeon",
    instanceID        = 657,
    journalInstanceID = 68,
    name              = "The Vortex Pinnacle",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "4.0.3",
    timewalking       = true,

    entrance = {
        mapID = 249,
        x     = 0.7684,
        y     = 0.8459,
    },

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    trashLoot = {
        { id = 55855, slot = "Feet", name = "Darksky Treads", sources = { [14]=27424, [15]=27424 }, bind = "BoE", twSource = 76618 },
    },

    bosses = {
        {
            index              = 1,
            name               = "Grand Vizier Ertan",
            journalEncounterID = 114,
            dungeonEncounterID = 1043,
            achievements       = {
            },
            loot = {
                { id = 56358, slot = "Head", name = "Headcover of Fog", sources = { [14]=27684, [15]=27684 }, twSource = 76605 },
                { id = 56359, slot = "Shoulder", name = "Fallen Snow Shoulderguards", sources = { [14]=27685, [15]=27685 }, twSource = 76606 },
                { id = 157603, slot = "Two-Hand", name = "Thundercleaver Axe", sources = { [14]=93789, [15]=93789 } },
                { id = 56356, slot = "Waist", name = "Stratosphere Belt", sources = { [14]=27682, [15]=27682 }, twSource = 76603 },
                { id = 56357, slot = "Weapon", name = "Biting Wind", sources = { [14]=27683, [15]=27683 }, twSource = 76604 },
            },
        },
        {
            index              = 2,
            name               = "Altairus",
            journalEncounterID = 115,
            dungeonEncounterID = 1041,
            achievements       = {
            },
            loot = {
                { id = 157604, slot = "Back", name = "Billowing Skydrape", sources = { [14]=93790, [15]=93790 }, twSource = 76684 },
                { id = 157605, slot = "Feet", name = "Sandals of the West Wind", sources = { [14]=93791, [15]=93791 }, twSource = 76689 },
                { id = 133251, slot = "Ranged", name = "Thundercall", sources = { [24]=76617 } },
                { id = 56361, slot = "Shoulder", name = "Mantle of Bestilled Winds", sources = { [14]=27686, [15]=27686 }, twSource = 76607 },
                { id = 133371, slot = "Two-Hand", name = "Thundercleaver Axe", sources = { [24]=76690 } },
                { id = 56363, slot = "Waist", name = "Hail-Strung Belt", sources = { [14]=27687, [15]=27687 }, twSource = 76608 },
                { id = 56364, slot = "Weapon", name = "Axe of the Eclipse", sources = { [14]=27688, [15]=27688 }, twSource = 76609 },
            },
            specialLoot = {
                { id = 63040, kind = "mount", name = "Reins of the Drake of the North Wind" },
            },
        },
        {
            index              = 3,
            name               = "Asaad, Caliph of Zephyrs",
            journalEncounterID = 116,
            dungeonEncounterID = 1042,
            aliases            = { "Asaad" },
            achievements       = {
                { id = 5288, name = "No Static at All", meta = true, soloable = "yes" },
                { id = 5289, name = "Extra Credit Bonus Stage", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56369, slot = "Back", name = "Billowing Cape", sources = { [14]=27692, [15]=27692 }, twSource = 76613 },
                { id = 56371, slot = "Back", name = "Shadow of Perfect Bliss", sources = { [14]=27693, [15]=27693 }, twSource = 76614 },
                { id = 56368, slot = "Hands", name = "Gloves of Haze", sources = { [14]=27691, [15]=27691 }, twSource = 76612 },
                { id = 56374, slot = "Head", name = "Lunar Halo", sources = { [14]=27694, [15]=27694 }, twSource = 76615 },
                { id = 56375, slot = "Legs", name = "Leggings of Iridescent Clouds", sources = { [14]=27695, [15]=27695 }, twSource = 76616 },
                { id = 56367, slot = "Legs", name = "Legguards of Winnowing Wind", sources = { [14]=27690, [15]=27690 }, twSource = 76611 },
                { id = 56366, slot = "Ranged", name = "Lightningflash", sources = { [14]=27689, [15]=27689 }, twSource = 76610 },
                { id = 56376, slot = "Ranged", name = "Thundercall", sources = { [14]=27696, [15]=27696 } },
            },
        },
    },
}
