-------------------------------------------------------------------------------
-- RetroRuns Data -- Stratholme - Main Gate
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 329  |  journalInstanceID: 236
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[236] = {
    kind              = "dungeon",
    instanceID        = 329,
    journalInstanceID = 236,
    name              = "Stratholme - Main Gate",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",
    timewalking       = true,
    -- Both doors report instanceID 329, so the wing is picked from the
    -- uiMap the player enters on. Crusader's Square is the front gate.
    uiMaps = { 317 },

    entrance = {
        mapID = 23,
        x     = 0.2733,
        y     = 0.1160,
    },

    pois = {
        { mapID = 317, poiKind = "rare", rareNpc = "Skul", mapLabelPos = "above", points = { { 0.558, 0.702 }, { 0.576, 0.642 }, { 0.720, 0.566 }, { 0.786, 0.222 }, { 0.786, 0.460 }, { 0.812, 0.342 } } },
    },

    trashLoot = {
        { id = 18743, slot = "Back", name = "Gracious Cape", sources = { [14]=7470 }, bind = "BoE" },
        { id = 17061, slot = "Back", name = "Juno's Shadow", sources = { [14]=7074 }, bind = "BoE" },
        { id = 13394, slot = "Chest", name = "Skul's Cold Embrace", sources = { [14]=4872 }, bind = "BoP", rareNpc = "Skul" },
        { id = 18744, slot = "Hands", name = "Plaguebat Fur Gloves", sources = { [14]=7471 }, bind = "BoE" },
        { id = 13395, slot = "Hands", name = "Skul's Fingerbone Claws", sources = { [14]=4873 }, bind = "BoP", rareNpc = "Skul" },
        { id = 18736, slot = "Legs", name = "Plaguehound Leggings", sources = { [14]=7463 }, bind = "BoE" },
        { id = 18745, slot = "Legs", name = "Sacred Cloth Leggings", sources = { [14]=7472 }, bind = "BoE" },
        { id = 13396, slot = "Ranged", name = "Skul's Ghastly Touch", sources = { [14]=4874 }, bind = "BoP", rareNpc = "Skul" },
        { id = 18742, slot = "Shoulder", name = "Stratholme Militia Shoulderguard", sources = { [14]=7469 }, bind = "BoE" },
        { id = 16723, slot = "Waist", name = "Lightforge Belt", sources = { [14]=6854 }, bind = "BoE" },
        { id = 16681, slot = "Wrist", name = "Beaststalker's Bindings", sources = { [14]=6812 }, bind = "BoE" },
        { id = 16671, slot = "Wrist", name = "Bindings of Elements", sources = { [14]=6802 }, bind = "BoE" },
        { id = 16697, slot = "Wrist", name = "Devout Bracers", sources = { [14]=6828 }, bind = "BoE" },
        { id = 18741, slot = "Wrist", name = "Morlune's Bracer", sources = { [14]=7468 }, bind = "BoE" },
        { id = 16714, slot = "Wrist", name = "Wildheart Bracers", sources = { [14]=6845 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Hearthsinger Forresten",
            journalEncounterID = 443,
            dungeonEncounterID = 473,
            achievements       = {
            },
            loot = {
                { id = 13378, slot = "Chest", name = "Songbird Blouse", sources = { [14]=4859 } },
                { id = 13383, slot = "Legs", name = "Woollies of the Prancing Minstrel", sources = { [14]=4862 } },
                { id = 13384, slot = "Waist", name = "Rainbow Girdle", sources = { [14]=4863 } },
            },
            specialLoot = {
                { id = 13379, kind = "toy", name = "Piccolo of the Flaming Fire" },
            },
        },
        {
            index              = 2,
            name               = "The Unforgiven",
            journalEncounterID = 450,
            dungeonEncounterID = 472,
            achievements       = {
            },
            loot = {
                { id = 151404, slot = "Hands", name = "Gauntlets of Purged Sanity", sources = { [14]=89410 } },
                { id = 13404, slot = "Head", name = "Mask of the Unforgiven", sources = { [14]=4882 } },
                { id = 13405, slot = "Shoulder", name = "Wailing Nightbane Pauldrons", sources = { [14]=4883 } },
                { id = 22406, slot = "Two-Hand", name = "Redemption", sources = { [14]=8815 } },
                { id = 13408, slot = "Weapon", name = "Soul Breaker", sources = { [14]=4886 } },
                { id = 13409, slot = "Wrist", name = "Tearfall Bracers", sources = { [14]=4887 } },
            },
        },
        {
            index              = 3,
            name               = "Postmaster Malown",
            journalEncounterID = 2633,
            dungeonEncounterID = 1885,
            achievements       = {
            },
            loot = {
                { id = 13388, slot = "Chest", name = "The Postmaster's Tunic", sources = { [14]=4867 } },
                { id = 13391, slot = "Feet", name = "The Postmaster's Treads", sources = { [14]=4870 } },
                { id = 13390, slot = "Head", name = "The Postmaster's Band", sources = { [14]=4869 } },
                { id = 13389, slot = "Legs", name = "The Postmaster's Trousers", sources = { [14]=4868 } },
                { id = 13393, slot = "Two-Hand", name = "Malown's Slam", sources = { [14]=4871 } },
            },
        },
        {
            index              = 4,
            name               = "Timmy the Cruel",
            journalEncounterID = 445,
            dungeonEncounterID = 474,
            achievements       = {
            },
            loot = {
                { id = 13402, slot = "Feet", name = "Timmy's Galoshes", sources = { [14]=4880 } },
                { id = 151403, slot = "Hands", name = "Fetid Stranglers", sources = { [14]=89409 } },
                { id = 13403, slot = "Waist", name = "Grimgore Noose", sources = { [14]=4881 } },
                { id = 13401, slot = "Weapon", name = "The Cruel Hand of Timmy", sources = { [14]=4879 } },
                { id = 13400, slot = "Wrist", name = "Vambraces of the Sadist", sources = { [14]=4878 } },
            },
        },
        {
            index              = 5,
            name               = "Commander Malor",
            journalEncounterID = 749,
            dungeonEncounterID = 476,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 6,
            name               = "Willey Hopebreaker",
            journalEncounterID = 446,
            dungeonEncounterID = 475,
            achievements       = {
            },
            loot = {
                { id = 13381, slot = "Feet", name = "Master Cannoneer Boots", sources = { [14]=4861 } },
                { id = 22407, slot = "Head", name = "Helm of the New Moon", sources = { [14]=8816 } },
                { id = 13380, slot = "Ranged", name = "Willey's Portable Howitzer", sources = { [14]=4860 } },
                { id = 22405, slot = "Shoulder", name = "Mantle of the Scarlet Crusade", sources = { [14]=8814 } },
                { id = 18721, slot = "Waist", name = "Barrage Girdle", sources = { [14]=7454 } },
                { id = 22404, slot = "Weapon", name = "Willey's Back Scratcher", sources = { [14]=8813 } },
            },
        },
        {
            index              = 7,
            name               = "Instructor Galford",
            journalEncounterID = 448,
            dungeonEncounterID = 477,
            achievements       = {
            },
            loot = {
                { id = 13386, slot = "Back", name = "Archivist Cape", sources = { [14]=4865 } },
                { id = 18716, slot = "Feet", name = "Ash Covered Boots", sources = { [14]=7450 } },
                { id = 13385, slot = "Off-hand", name = "Tome of Knowledge", sources = { [14]=4864 } },
                { id = 13387, slot = "Waist", name = "Foresight Girdle", sources = { [14]=4866 } },
            },
        },
        {
            index              = 8,
            name               = "Balnazzar",
            journalEncounterID = 449,
            dungeonEncounterID = 478,
            achievements       = {
            },
            loot = {
                { id = 13369, slot = "Feet", name = "Fire Striders", sources = { [14]=4852 } },
                { id = 13359, slot = "Head", name = "Crown of Tyranny", sources = { [14]=4848 } },
                { id = 18718, slot = "Head", name = "Grand Crusader's Helm", sources = { [14]=7452 } },
                { id = 13353, slot = "Off-hand", name = "Book of the Dead", sources = { [14]=4846 } },
                { id = 18720, slot = "Shoulder", name = "Shroud of the Nathrezim", sources = { [14]=7453 } },
                { id = 13358, slot = "Shoulder", name = "Wyrmtongue Shoulders", sources = { [14]=4847 } },
                { id = 13348, slot = "Two-Hand", name = "Demonshear", sources = { [14]=4844 } },
                { id = 18717, slot = "Two-Hand", name = "Hammer of the Grand Crusader", sources = { [14]=7451 } },
                { id = 13360, slot = "Weapon", name = "Gift of the Elven Magi", sources = { [14]=4849 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {

        -- 1. The Unforgiven (boss 2)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 2,
            title     = "The Unforgiven",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 317 },
                    kind    = "path",
                    note    = "After zoning in, move ahead then go right into the loop. Circle through a couple gates and loop around until you reach ^The Unforgiven^.",
                    minNote = "Right to The Unforgiven",
                    points  = {
                        { 0.663, 0.692 },
                        { 0.679, 0.575 },
                        { 0.740, 0.543 },
                        { 0.814, 0.446 },
                        { 0.837, 0.366 },
                        { 0.820, 0.295 },
                        { 0.815, 0.229 },
                        { 0.804, 0.184 },
                        { 0.764, 0.193 },
                    },
                },
            },
        },

        -- 2. Hearthsinger Forresten (boss 1)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 1,
            title     = "Hearthsinger Forresten",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 317 },
                    kind        = "poi",
                    note        = "After killing ^The Unforgiven^, continue counter-clockwise. Click the nearby ^Market Row Postbox^ on your way to ^Hearthsinger Forresten^.",
                    minNote     = "Click Postbox then Hearthsinger",
                    mapLabel    = "Click Postbox",
                    mapLabelPos = "below",
                    completionCheck = true,
                    triggeredBy = { dialog = { npc = "Undead Postman", match = "No tampering with the mail" } },
                    points      = {
                        { 0.705, 0.249 },
                    },
                },
                {
                    -- Noteless: takes its travel text from the POI segment
                    -- above, the Razorfen Downs gong shape.
                    when    = { mapID = 317 },
                    kind    = "path",
                    points  = {
                        { 0.665, 0.266 },
                        { 0.619, 0.292 },
                    },
                },
            },
        },

        -- 3. Postmaster Malown (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Postmaster Malown",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 317 },
                    kind    = "path",
                    note    = "After defeating ^Hearthsinger Forresten^, go south and click ^King's Square Postbox^ followed by ^Ezra Grimm's Postbox^, both marked on the map. ^Postmaster Malown^ should spawn right near you if you've clicked three post boxes.",
                    minNote = "Click marked post boxes to spawn boss",
                    points  = {
                        { 0.605, 0.269 },
                        { 0.601, 0.393 },
                        { 0.601, 0.497 },
                    },
                },
                {
                    -- Noteless: both boxes are covered by the path segment's
                    -- note above, the Razorfen Downs gong shape.
                    when        = { mapID = 317 },
                    kind        = "poi",
                    mapLabel    = "Click Postbox (1)",
                    mapLabelPos = "below",
                    points      = {
                        { 0.631, 0.516 },
                    },
                },
                {
                    when        = { mapID = 317 },
                    kind        = "poi",
                    mapLabel    = "Click Postbox (2)",
                    mapLabelPos = "below",
                    points      = {
                        { 0.541, 0.717 },
                    },
                },
            },
        },

        -- 4. Timmy the Cruel (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Timmy the Cruel",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 317 },
                    kind    = "path",
                    note    = "After defeating ^Postmaster Malown^, go northwest until you reach ^Timmy the Cruel^.",
                    minNote = "Northwest to Timmy",
                    points  = {
                        { 0.580, 0.620 },
                        { 0.602, 0.496 },
                        { 0.601, 0.368 },
                        { 0.581, 0.299 },
                        { 0.504, 0.250 },
                        { 0.497, 0.218 },
                    },
                },
            },
        },

        -- 5. Commander Malor (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Commander Malor",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 317 },
                    kind    = "path",
                    note    = "After killing ^Timmy the Cruel^, go west and enter the building. Loop around the hallway until you reach ^Commander Malor^.",
                    minNote = "West into building for Malor",
                    points  = {
                        { 0.494, 0.216 },
                        { 0.483, 0.243 },
                        { 0.359, 0.317 },
                        { 0.308, 0.358 },
                        { 0.294, 0.339 },
                        { 0.276, 0.350 },
                        { 0.259, 0.337 },
                        { 0.239, 0.352 },
                        { 0.271, 0.437 },
                        { 0.277, 0.428 },
                    },
                },
            },
        },

        -- 6. Willey Hopebreaker (boss 6)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Willey Hopebreaker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 317 },
                    kind    = "path",
                    note    = "After defeating ^Commander Malor^, continue southwest through the halls towards ^The Hoard^ and you will eventually reach ^Willey Hopebreaker^.",
                    minNote = "Southwest to Willey",
                    points  = {
                        { 0.277, 0.433 },
                        { 0.152, 0.558 },
                        { 0.119, 0.483 },
                        { 0.087, 0.513 },
                        { 0.105, 0.556 },
                        { 0.076, 0.587 },
                        { 0.059, 0.544 },
                    },
                },
            },
        },

        -- 7. Instructor Galford (boss 7)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Instructor Galford",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 317 },
                    kind    = "path",
                    note    = "After killing ^Willey Hopebreaker^, work your way south through the hallways to reach ^Instructor Galford^.",
                    minNote = "South to Galford",
                    points  = {
                        { 0.061, 0.552 },
                        { 0.074, 0.585 },
                        { 0.105, 0.557 },
                        { 0.085, 0.510 },
                        { 0.118, 0.481 },
                        { 0.153, 0.560 },
                        { 0.207, 0.507 },
                        { 0.232, 0.562 },
                        { 0.199, 0.588 },
                        { 0.238, 0.669 },
                        { 0.211, 0.695 },
                        { 0.246, 0.773 },
                    },
                },
            },
        },

        -- 8. Balnazzar (boss 8)
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Balnazzar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 317 },
                    kind    = "path",
                    note    = "After killing ^Instructor Galford^, go directly across the hall to find the final boss, ^Balnazzar^.",
                    minNote = "Across hall to Balnazzar",
                    points  = {
                        { 0.250, 0.774 },
                        { 0.228, 0.798 },
                    },
                },
            },
        },

    },
}
