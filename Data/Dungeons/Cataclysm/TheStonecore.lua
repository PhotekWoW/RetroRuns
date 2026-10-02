-------------------------------------------------------------------------------
-- RetroRuns Data -- The Stonecore
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
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
    availableDifficulties = { 14, 15 },
    patch             = "4.0.3",
    timewalking       = true,
    routedIn          = "3.3.3",

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

    trashLoot = {
        { id = 55824, slot = "Back", name = "Skin of Stone", sources = { [14]=27407, [15]=27407 }, bind = "BoE", twSource = 76602 },
        { id = 55823, slot = "Ranged", name = "Wand of Dark Worship", sources = { [14]=27406, [15]=27406 }, bind = "BoE", twSource = 76601 },
        { id = 55822, slot = "Weapon", name = "Heavy Geode Mace", sources = { [14]=27405, [15]=27405 }, bind = "BoE", twSource = 76600 },
    },

    bosses = {
        {
            index              = 1,
            name               = "Corborus",
            journalEncounterID = 110,
            dungeonEncounterID = 1056,
            achievements       = {
            },
            loot = {
                { id = 56331, slot = "Hands", name = "Dolomite Adorned Gloves", sources = { [14]=27666, [15]=27666 }, twSource = 76587 },
                { id = 56330, slot = "Shoulder", name = "Cinnabar Shoulders", sources = { [14]=27665, [15]=27665 }, twSource = 76586 },
                { id = 157592, slot = "Weapon", name = "Crackling Geode Mace", sources = { [14]=93782, [15]=93782 }, twSource = 76692 },
                { id = 56329, slot = "Weapon", name = "Fist of Pained Senses", sources = { [14]=27664, [15]=27664 }, twSource = 76585 },
                { id = 157590, slot = "Wrist", name = "Crystalgrinder Bracers", sources = { [14]=93781, [15]=93781 }, twSource = 76680 },
            },
        },
        {
            index              = 2,
            name               = "Slabhide",
            journalEncounterID = 111,
            dungeonEncounterID = 1059,
            achievements       = {
            },
            loot = {
                { id = 56334, slot = "Hands", name = "Deep Delving Gloves", sources = { [14]=27667, [15]=27667 }, twSource = 76588 },
                { id = 56336, slot = "Hands", name = "Hematite Plate Gloves", sources = { [14]=27669, [15]=27669 }, twSource = 76590 },
                { id = 157594, slot = "Legs", name = "Earth-Strength Legguards", sources = { [14]=93784, [15]=93784 }, twSource = 76681 },
                { id = 157593, slot = "Shoulder", name = "Crystalpowder Amice", sources = { [14]=93783, [15]=93783 }, twSource = 76686 },
                { id = 56335, slot = "Weapon", name = "Quicksilver Blade", sources = { [14]=27668, [15]=27668 }, twSource = 76589 },
            },
            specialLoot = {
                { id = 63043, kind = "mount", name = "Reins of the Vitreous Stone Drake" },
            },
        },
        {
            index              = 3,
            name               = "Ozruk",
            journalEncounterID = 112,
            dungeonEncounterID = 1058,
            achievements       = {
            },
            loot = {
                { id = 56342, slot = "Two-Hand", name = "Sword of the Bottomless Pit", sources = { [14]=27672, [15]=27672 }, twSource = 76593 },
                { id = 56341, slot = "Waist", name = "Belt of the Ringworm", sources = { [14]=27671, [15]=27671 }, twSource = 76592 },
                { id = 56340, slot = "Wrist", name = "Elementium Scale Bracers", sources = { [14]=27670, [15]=27670 }, twSource = 76591 },
            },
        },
        {
            index              = 4,
            name               = "High Priestess Azil",
            journalEncounterID = 113,
            dungeonEncounterID = 1057,
            achievements       = {
                { id = 5287, name = "Rotten to the Core", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56348, slot = "Feet", name = "Slippers of the Twilight Prophet", sources = { [14]=27676, [15]=27676 }, twSource = 76597 },
                { id = 56352, slot = "Head", name = "Cowl of the Unseen World", sources = { [14]=27678, [15]=27678 }, twSource = 76599 },
                { id = 56344, slot = "Head", name = "Helm of Numberless Shadows", sources = { [14]=27674, [15]=27674 }, twSource = 76595 },
                { id = 56349, slot = "Off-hand", name = "Prophet's Scepter", sources = { [14]=27677, [15]=27677 }, twSource = 76598 },
                { id = 56343, slot = "Two-Hand", name = "Darkling Staff", sources = { [14]=27673, [15]=27673 }, twSource = 76594 },
                { id = 56346, slot = "Weapon", name = "Elementium Fang", sources = { [14]=27675, [15]=27675 }, twSource = 76596 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Corborus (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Corborus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 324 },
                    kind    = "path",
                    note    = "After zoning in, follow the path ahead until you reach ^Corborus^.",
                    minNote = "Follow path to Corborus",
                    points  = {
                        { 0.544, 0.907 },
                        { 0.559, 0.844 },
                        { 0.630, 0.775 },
                        { 0.630, 0.633 },
                    },
                },
            },
        },

        -- 2. Slabhide (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Slabhide",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 324 },
                    kind    = "path",
                    note    = "After killing ^Corborus^, continue west on the linear path until you reach ^Slabhide^.",
                    minNote = "Follow path west to Slabhide",
                    points  = {
                        { 0.596, 0.592 },
                        { 0.566, 0.604 },
                        { 0.543, 0.579 },
                        { 0.517, 0.588 },
                        { 0.497, 0.596 },
                        { 0.481, 0.563 },
                        { 0.450, 0.559 },
                        { 0.435, 0.519 },
                        { 0.405, 0.521 },
                        { 0.379, 0.485 },
                    },
                },
            },
        },

        -- 3. Ozruk (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Ozruk",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 324 },
                    kind    = "path",
                    note    = "After defeating ^Slabhide^, follow the linear path north and loop around to find ^Ozruk^.",
                    minNote = "Follow path north to reach Ozruk",
                    points  = {
                        { 0.370, 0.401 },
                        { 0.383, 0.358 },
                        { 0.400, 0.331 },
                        { 0.400, 0.282 },
                        { 0.380, 0.257 },
                        { 0.395, 0.141 },
                        { 0.432, 0.141 },
                        { 0.462, 0.157 },
                        { 0.480, 0.197 },
                    },
                },
            },
        },

        -- 4. High Priestess Azil (boss 4).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "High Priestess Azil",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 324 },
                    kind    = "path",
                    note    = "After killing ^Ozruk^, continue on the path until you reach the final boss, ^High Priestess Azil^.",
                    minNote = "Follow path to Azil",
                    points  = {
                        { 0.495, 0.269 },
                        { 0.480, 0.348 },
                        { 0.481, 0.460 },
                        { 0.511, 0.450 },
                        { 0.552, 0.404 },
                    },
                },
            },
        },
    },
}
