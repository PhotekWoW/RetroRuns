-------------------------------------------------------------------------------
-- RetroRuns Data -- The Botanica
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 553  |  journalInstanceID: 257
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[257] = {
    kind              = "dungeon",
    instanceID        = 553,
    journalInstanceID = 257,
    name              = "The Botanica",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.1.2",
    timewalking       = true,

    entrance = {
        mapID = 109,
        x     = 0.7183,
        y     = 0.5482,
    },

    bosses = {
        {
            index              = 1,
            name               = "Commander Sarannis",
            journalEncounterID = 558,
            dungeonEncounterID = 1925,
            achievements       = {
            },
            loot = {
                { id = 28301, slot = "Back", name = "Sarannis' Mystic Sheen", sources = { [14]=12378, [15]=12378 }, twSource = 165690 },
                { id = 28304, slot = "Hands", name = "Prismatic Mittens of Mending", sources = { [14]=12380, [15]=12380 }, twSource = 165691 },
                { id = 28350, slot = "Head", name = "Warhelm of the Bold", sources = { [14]=12418, [15]=12418 }, twSource = 165711, setName = "Bold Armor", dungeonSet = 3 },
                { id = 28347, slot = "Legs", name = "Warpscale Leggings", sources = { [14]=12415, [15]=12415 }, twSource = 165708 },
                { id = 28306, slot = "Shoulder", name = "Towering Mantle of the Hunt", sources = { [14]=12382, [15]=12382 }, twSource = 165692 },
                { id = 28311, slot = "Weapon", name = "Revenger", sources = { [14]=12387, [15]=12387 }, twSource = 165693 },
            },
        },
        {
            index              = 2,
            name               = "High Botanist Freywinn",
            journalEncounterID = 559,
            dungeonEncounterID = 1926,
            achievements       = {
            },
            loot = {
                { id = 28228, slot = "Chest", name = "Beast Lord Cuirass", sources = { [14]=12345, [15]=12345 }, twSource = 165688, setName = "Beast Lord Armor", dungeonSet = 3 },
                { id = 28318, slot = "Feet", name = "Obsidian Clodstompers", sources = { [14]=12394, [15]=12394 }, twSource = 165697 },
                { id = 28317, slot = "Hands", name = "Energis Armwraps", sources = { [14]=12393, [15]=12393 }, twSource = 165696 },
                { id = 28348, slot = "Head", name = "Moonglade Cowl", sources = { [14]=12416, [15]=12416 }, twSource = 165709 },
                { id = 28316, slot = "Off-hand", name = "Aegis of the Sunbird", sources = { [14]=12392, [15]=12392 }, twSource = 165695 },
                { id = 28315, slot = "Weapon", name = "Stormreaver Warblades", sources = { [14]=12391, [15]=12391 }, twSource = 165694 },
            },
        },
        {
            index              = 3,
            name               = "Thorngrin the Tender",
            journalEncounterID = 560,
            dungeonEncounterID = 1928,
            achievements       = {
            },
            loot = {
                { id = 28324, slot = "Hands", name = "Gauntlets of Cruel Intention", sources = { [14]=12398, [15]=12398 }, twSource = 165699 },
                { id = 28325, slot = "Two-Hand", name = "Dreamer's Dragonstaff", sources = { [14]=12399, [15]=12399 }, twSource = 165700 },
                { id = 28322, slot = "Weapon", name = "Runed Dagger of Solace", sources = { [14]=12397, [15]=12397 }, twSource = 165698 },
            },
        },
        {
            index              = 4,
            name               = "Laj",
            journalEncounterID = 561,
            dungeonEncounterID = 1927,
            achievements       = {
            },
            loot = {
                { id = 28328, slot = "Back", name = "Mithril-Bark Cloak", sources = { [14]=12400, [15]=12400 }, twSource = 165701 },
                { id = 28339, slot = "Feet", name = "Boots of the Shifting Sands", sources = { [14]=12408, [15]=12408 }, twSource = 165703 },
                { id = 28349, slot = "Head", name = "Tidefury Helm", sources = { [14]=12417, [15]=12417 }, twSource = 165710, setName = "Tidefury Raiment", dungeonSet = 3 },
                { id = 28338, slot = "Legs", name = "Devil-Stitched Leggings", sources = { [14]=12407, [15]=12407 }, twSource = 165702 },
                { id = 28340, slot = "Shoulder", name = "Mantle of Autumn", sources = { [14]=12409, [15]=12409 }, twSource = 165704 },
                { id = 27739, slot = "Shoulder", name = "Spaulders of the Righteous", sources = { [14]=12030, [15]=12030 }, twSource = 165687, setName = "Righteous Armor", dungeonSet = 3 },
            },
        },
        {
            index              = 5,
            name               = "Warp Splinter",
            journalEncounterID = 562,
            dungeonEncounterID = 1929,
            achievements       = {
            },
            loot = {
                { id = 28371, slot = "Back", name = "Netherfury Cape", sources = { [14]=12424, [15]=12424 }, twSource = 165713 },
                { id = 28229, slot = "Chest", name = "Incanter's Robe", sources = { [14]=12346, [15]=12346 }, twSource = 165689, setName = "Incanter's Regalia", dungeonSet = 3 },
                { id = 28342, slot = "Chest", name = "Warp-Infused Drape", sources = { [14]=12411, [15]=12411 }, twSource = 165706 },
                { id = 29258, slot = "Feet", name = "Boots of Ethereal Manipulation", sources = { [14]=13052, [15]=13052 }, twSource = 165714 },
                { id = 29262, slot = "Feet", name = "Boots of the Endless Hunt", sources = { [14]=13055, [15]=13055 }, twSource = 165715 },
                { id = 32072, slot = "Hands", name = "Gauntlets of Dissension", sources = { [14]=14749, [15]=14749 }, twSource = 165717 },
                { id = 29359, slot = "Two-Hand", name = "Feral Staff of Lashing", sources = { [14]=13102, [15]=13102 }, twSource = 165716 },
                { id = 28367, slot = "Two-Hand", name = "Greatsword of Forlorn Visions", sources = { [14]=12423, [15]=12423 }, twSource = 165712 },
                { id = 28341, slot = "Two-Hand", name = "Warpstaff of Arcanum", sources = { [14]=12410, [15]=12410 }, twSource = 165705 },
                { id = 28345, slot = "Weapon", name = "Warp Splinter's Thorn", sources = { [14]=12413, [15]=12413 }, twSource = 165707 },
            },
        },
    },

    exitNote    = "There is an exit portal through the tunnel to the north",
    minExitNote = "Exit portal through north tunnel",

    routing = {
        -- 1. Commander Sarannis (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Commander Sarannis",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 266 },
                    kind    = "path",
                    note    = "After zoning in, follow the long, linear path all the way to ^Commander Sarannis^.",
                    minNote = "Follow path to Sarannis",
                    points  = {
                        { 0.871, 0.446 },
                        { 0.842, 0.491 },
                        { 0.649, 0.492 },
                        { 0.638, 0.459 },
                        { 0.599, 0.460 },
                        { 0.589, 0.493 },
                        { 0.528, 0.493 },
                        { 0.525, 0.536 },
                        { 0.506, 0.558 },
                        { 0.478, 0.559 },
                        { 0.480, 0.312 },
                        { 0.492, 0.224 },
                        { 0.496, 0.187 },
                        { 0.471, 0.187 },
                        { 0.461, 0.200 },
                    },
                },
            },
        },
        -- 2. High Botanist Freywinn (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "High Botanist Freywinn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 266 },
                    kind    = "path",
                    note    = "After defeating ^Commander Sarannis^, follow the linear path to the west until you reach ^High Botanist Freywinn^.",
                    minNote = "West to Freywinn",
                    points  = {
                        { 0.462, 0.201 },
                        { 0.482, 0.174 },
                        { 0.462, 0.150 },
                        { 0.416, 0.172 },
                        { 0.260, 0.173 },
                        { 0.217, 0.149 },
                        { 0.211, 0.183 },
                        { 0.219, 0.194 },
                    },
                },
            },
        },
        -- 3. Thorngrin the Tender (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Thorngrin the Tender",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 266 },
                    kind    = "path",
                    note    = "After killing ^High Botanist Freywinn^, continue south on the linear path until you reach ^Thorngrin the Tender^.",
                    minNote = "South to Thorngrin",
                    points  = {
                        { 0.219, 0.193 },
                        { 0.204, 0.187 },
                        { 0.188, 0.199 },
                        { 0.198, 0.232 },
                        { 0.208, 0.344 },
                        { 0.206, 0.438 },
                        { 0.190, 0.510 },
                        { 0.175, 0.509 },
                        { 0.173, 0.477 },
                        { 0.155, 0.446 },
                        { 0.136, 0.441 },
                        { 0.097, 0.482 },
                    },
                },
            },
        },
        -- 4. Laj (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Laj",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 266 },
                    kind    = "path",
                    note    = "After defeating ^Thorngrin the Tender^, continue south on the linear path until you reach ^Laj^.",
                    minNote = "South to Laj",
                    points  = {
                        { 0.095, 0.517 },
                        { 0.146, 0.717 },
                        { 0.217, 0.807 },
                        { 0.283, 0.819 },
                        { 0.300, 0.870 },
                        { 0.318, 0.885 },
                    },
                },
            },
        },
        -- 5. Warp Splinter (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Warp Splinter",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 266 },
                    kind    = "path",
                    note    = "After killing ^Laj^, take the path north and you will run right into ^Warp Splinter^.",
                    minNote = "North to Warp Splinter",
                    points  = {
                        { 0.339, 0.805 },
                        { 0.341, 0.404 },
                    },
                },
            },
        },
    },
}
