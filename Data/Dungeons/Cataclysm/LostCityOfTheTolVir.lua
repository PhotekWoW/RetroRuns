-------------------------------------------------------------------------------
-- RetroRuns Data -- Lost City of the Tol'vir
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 755  |  journalInstanceID: 69
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[69] = {
    kind              = "dungeon",
    instanceID        = 755,
    journalInstanceID = 69,
    name              = "Lost City of the Tol'vir",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "4.0.3",
    timewalking       = true,
    routedIn          = "3.3.3",

    entrance = {
        mapID = 249,
        x     = 0.6056,
        y     = 0.6439,
    },

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    trashLoot = {
        { id = 55882, slot = "Wrist", name = "Oasis Bracers", sources = { [14]=27442, [15]=27442 }, bind = "BoP", twSource = 76636 },
    },

    bosses = {
        {
            index              = 1,
            name               = "General Husam",
            journalEncounterID = 117,
            dungeonEncounterID = 1052,
            achievements       = {
            },
            loot = {
                { id = 56379, slot = "Back", name = "Kaleki Cloak", sources = { [14]=27698, [15]=27698 }, twSource = 76619 },
                { id = 56381, slot = "Feet", name = "Greaves of Wu the Elder", sources = { [14]=27699, [15]=27699 }, twSource = 76620 },
                { id = 56383, slot = "Hands", name = "Ionic Gloves", sources = { [14]=27701, [15]=27701 }, twSource = 76622 },
                { id = 56382, slot = "Two-Hand", name = "Seliza's Spear", sources = { [14]=27700, [15]=27700 }, twSource = 76621 },
            },
        },
        {
            index              = 2,
            name               = "Lockmaw",
            journalEncounterID = 118,
            dungeonEncounterID = 1054,
            achievements       = {
                { id = 5291, name = "Acrocalypse Now", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56387, slot = "Feet", name = "Greaves of Wu the Younger", sources = { [14]=27704, [15]=27704 }, twSource = 76625 },
                { id = 56386, slot = "Legs", name = "Balkar's Waders", sources = { [14]=27703, [15]=27703 }, twSource = 76624 },
                { id = 133278, slot = "Waist", name = "Evelyn's Belt", sources = { [24]=76635 } },
                { id = 56384, slot = "Weapon", name = "Resonant Kris", sources = { [14]=27702, [15]=27702 }, twSource = 76623 },
            },
        },
        {
            index              = 3,
            name               = "High Prophet Barim",
            journalEncounterID = 119,
            dungeonEncounterID = 1053,
            achievements       = {
                { id = 5290, name = "Kill It With Fire!", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 133276, slot = "Legs", name = "Leggings of the Path", sources = { [24]=76633 } },
                { id = 133277, slot = "Off-hand", name = "Zora's Ward", sources = { [24]=76634 } },
                { id = 56392, slot = "Waist", name = "Sand Dune Belt", sources = { [14]=27707, [15]=27707 }, twSource = 76628 },
                { id = 56390, slot = "Weapon", name = "Barim's Main Gauche", sources = { [14]=27706, [15]=27706 }, twSource = 76627 },
                { id = 56389, slot = "Wrist", name = "Sand Silk Wristband", sources = { [14]=27705, [15]=27705 }, twSource = 76626 },
            },
        },
        {
            index              = 4,
            name               = "Siamat",
            journalEncounterID = 122,
            dungeonEncounterID = 1055,
            achievements       = {
                { id = 5292, name = "Headed South", meta = true, soloable = "yes" },
                { id = 5294, name = "Straw That Broke the Camel's Back", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56397, slot = "Back", name = "Geordan's Cloak", sources = { [14]=27710, [15]=27710 }, twSource = 76631 },
                { id = 56395, slot = "Feet", name = "Crafty's Gaiters", sources = { [14]=27708, [15]=27708 }, twSource = 76629 },
                { id = 56401, slot = "Legs", name = "Leggings of the Path", sources = { [14]=27712, [15]=27712 } },
                { id = 56402, slot = "Off-hand", name = "Zora's Ward", sources = { [14]=27713, [15]=27713 } },
                { id = 56399, slot = "Shoulder", name = "Mantle of Master Cho", sources = { [14]=27711, [15]=27711 }, twSource = 76632 },
                { id = 56403, slot = "Waist", name = "Evelyn's Belt", sources = { [14]=27714, [15]=27714 } },
                { id = 56396, slot = "Weapon", name = "Hammer of Sparks", sources = { [14]=27709, [15]=27709 }, twSource = 76630 },
                { id = 157599, slot = "Weapon", name = "Sceptre of Swirling Winds", sources = { [14]=93788, [15]=93788 }, twSource = 76693 },
            },
        },
    },

    exitNote    = "Jump off the north side of the platform for a short walk to the entrance",
    minExitNote = "Jump off north side to entrance",

    routing = {
        -- 1. General Husam (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "General Husam",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 277 },
                    kind    = "path",
                    note    = "After zoning in, follow the path ahead to find ^General Husam^.",
                    minNote = "Follow path to General Husam",
                    points  = {
                        { 0.328, 0.228 },
                        { 0.339, 0.275 },
                        { 0.387, 0.258 },
                        { 0.420, 0.312 },
                        { 0.427, 0.353 },
                        { 0.400, 0.406 },
                    },
                },
            },
        },

        -- 2. Lockmaw (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Lockmaw",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 277 },
                    kind    = "path",
                    note    = "After defeating ^General Husam^, exit to the east and follow the path to ^Lockmaw^.",
                    minNote = "Go east to Lockmaw",
                    points  = {
                        { 0.420, 0.412 },
                        { 0.511, 0.429 },
                        { 0.511, 0.484 },
                        { 0.505, 0.575 },
                        { 0.588, 0.572 },
                        { 0.652, 0.688 },
                    },
                },
            },
        },

        -- 3. High Prophet Barim (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "High Prophet Barim",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 277 },
                    kind    = "path",
                    note    = "After killing ^Lockmaw^, backtrack to the main corridor and follow the path to the southwest to reach ^High Prophet Barim^.",
                    minNote = "Backtrack then southwest to Barim",
                    points  = {
                        { 0.588, 0.567 },
                        { 0.507, 0.573 },
                        { 0.497, 0.668 },
                        { 0.507, 0.752 },
                        { 0.439, 0.813 },
                        { 0.412, 0.794 },
                        { 0.384, 0.641 },
                        { 0.349, 0.618 },
                        { 0.297, 0.642 },
                    },
                },
            },
        },

        -- 4. Siamat (boss 4). The Wind Tunnel lifts the player to his platform.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Siamat",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 277 },
                    kind        = "poi",
                    note        = "After defeating ^High Prophet Barim^, go slightly east and click the ^Wind Tunnel^ to be lifted up to the platform above. Once you land, kill ^Siamat^.",
                    minNote     = "Click Wind Tunnel to reach Siamat",
                    mapLabel    = "Click Wind Tunnel",
                    mapLabelPos = "above",
                    points      = {
                        { 0.368, 0.628 },
                    },
                },
            },
        },
    },
}
