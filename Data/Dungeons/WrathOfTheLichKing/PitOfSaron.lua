-------------------------------------------------------------------------------
-- RetroRuns Data -- Pit of Saron
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.3.0  |  instanceID: 658  |  journalInstanceID: 278
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[278] = {
    kind              = "dungeon",
    instanceID        = 658,
    journalInstanceID = 278,
    name              = "Pit of Saron",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "3.3.0",
    timewalking       = true,

    entrance = {
        mapID = 123,
        x     = 0.7819,
        y     = 0.0668,
    },

    trashLoot = {
        { id = 49855, slot = "Hands", name = "Plated Grips of Korth'azz", sources = { [14]=24428 }, bind = "BoP" },
        { id = 49852, slot = "Ranged", name = "Coffin Nail", sources = { [14]=24425 }, bind = "BoP" },
        { id = 49854, slot = "Shoulder", name = "Mantle of Tattered Feathers", sources = { [14]=24427 }, bind = "BoP" },
        { id = 49853, slot = "Waist", name = "Titanium Links of Lore", sources = { [14]=24426 }, bind = "BoP" },
        { id = 50315, slot = "Weapon", name = "Seven-Fingered Claws", sources = { [15]=24688 }, bind = "BoP" },
        { id = 50319, slot = "Weapon", name = "Unsharpened Ice Razor", sources = { [15]=24690 }, bind = "BoP" },
        { id = 50318, slot = "Wrist", name = "Ghostly Wristwraps", sources = { [15]=24689 }, bind = "BoP" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Forgemaster Garfrost",
            journalEncounterID = 608,
            dungeonEncounterID = 1999,
            achievements       = {
            },
            loot = {
                { id = 133508, slot = "Chest", name = "Shroud of Rime", sources = { [24]=76799 } },
                { id = 49805, slot = "Feet", name = "Ice-Steeped Sandals", sources = { [14]=24382, [15]=24382 }, twSource = 76782 },
                { id = 49804, slot = "Head", name = "Polished Mirror Helm", sources = { [14]=24381, [15]=24381 }, twSource = 76781 },
                { id = 133501, slot = "Head", name = "Skeleton Lord's Cranium", sources = { [24]=76792 } },
                { id = 50229, slot = "Legs", name = "Legguards of the Frosty Depths", sources = { [14]=24632, [15]=24632 } },
                { id = 50234, slot = "Shoulder", name = "Shoulderplates of Frozen Blood", sources = { [14]=24635, [15]=24635 } },
                { id = 50233, slot = "Shoulder", name = "Spurned Val'kyr Shoulderguards", sources = { [14]=24634, [15]=24634 } },
                { id = 49802, slot = "Two-Hand", name = "Garfrost's Two-Ton Hammer", sources = { [14]=24380, [15]=24380 }, twSource = 76780 },
                { id = 49801, slot = "Two-Hand", name = "Unspeakable Secret", sources = { [14]=24379, [15]=24379 }, twSource = 76779 },
                { id = 49806, slot = "Waist", name = "Flayer's Black Belt", sources = { [14]=24383, [15]=24383 }, twSource = 76783 },
                { id = 50227, slot = "Weapon", name = "Surgeon's Needle", sources = { [14]=24631, [15]=24631 } },
                { id = 50230, slot = "Wrist", name = "Malykriss Vambraces", sources = { [14]=24633, [15]=24633 } },
            },
        },
        {
            index              = 2,
            name               = "Ick and Krick",
            journalEncounterID = 609,
            dungeonEncounterID = 2001,
            scenarioCriteriaID = 27938,
            achievements       = {
            },
            loot = {
                { id = 50266, slot = "Chest", name = "Ancient Polar Bear Hide", sources = { [14]=24651, [15]=24651 } },
                { id = 49811, slot = "Legs", name = "Black Dragonskin Breeches", sources = { [14]=24388, [15]=24388 }, twSource = 76788 },
                { id = 50265, slot = "Legs", name = "Blackened Ghoul Skin Leggings", sources = { [14]=24650, [15]=24650 } },
                { id = 133504, slot = "Legs", name = "Rimewoven Silks", sources = { [24]=76795 } },
                { id = 50262, slot = "Ranged", name = "Felglacier Bolter", sources = { [14]=24647, [15]=24647 } },
                { id = 133517, slot = "Shoulder", name = "Saronite-Studded Shoulderguards", sources = { [24]=76800 } },
                { id = 49808, slot = "Waist", name = "Bent Gold Belt", sources = { [14]=24385, [15]=24385 }, twSource = 76785 },
                { id = 50263, slot = "Waist", name = "Braid of Salt and Fire", sources = { [14]=24648, [15]=24648 } },
                { id = 49810, slot = "Waist", name = "Scabrous Zombie Belt", sources = { [14]=24387, [15]=24387 }, twSource = 76787 },
                { id = 49807, slot = "Weapon", name = "Krick's Beetle Stabber", sources = { [14]=24384, [15]=24384 }, twSource = 76784 },
                { id = 50264, slot = "Wrist", name = "Chewed Leather Wristguards", sources = { [14]=24649, [15]=24649 } },
                { id = 49809, slot = "Wrist", name = "Wristguards of Subterranean Moss", sources = { [14]=24386, [15]=24386 }, twSource = 76786 },
            },
        },
        {
            index              = 3,
            name               = "Scourgelord Tyrannus",
            journalEncounterID = 610,
            dungeonEncounterID = 2000,
            achievements       = {
            },
            loot = {
                { id = 49823, slot = "Back", name = "Cloak of the Fallen Cardinal", sources = { [14]=24397, [15]=24397 }, twSource = 76796 },
                { id = 50272, slot = "Chest", name = "Frost Wyrm Ribcage", sources = { [14]=24656, [15]=24656 } },
                { id = 50285, slot = "Chest", name = "Icebound Bronze Cuirass", sources = { [14]=24665, [15]=24665 } },
                { id = 49825, slot = "Chest", name = "Palebone Robes", sources = { [14]=24399, [15]=24399 }, twSource = 76798 },
                { id = 49816, slot = "Chest", name = "Scourgelord's Frigid Chestplate", sources = { [14]=24391, [15]=24391 }, twSource = 76790 },
                { id = 49826, slot = "Chest", name = "Shroud of Rime", sources = { [14]=24400, [15]=24400 } },
                { id = 50283, slot = "Feet", name = "Mudslide Boots", sources = { [14]=24663, [15]=24663 } },
                { id = 50286, slot = "Feet", name = "Prelate's Snowshoes", sources = { [14]=24666, [15]=24666 } },
                { id = 50284, slot = "Hands", name = "Rusty Frozen Fingerguards", sources = { [14]=24664, [15]=24664 } },
                { id = 49824, slot = "Head", name = "Horns of the Spurned Val'kyr", sources = { [14]=24398, [15]=24398 }, twSource = 76797 },
                { id = 49819, slot = "Head", name = "Skeleton Lord's Cranium", sources = { [14]=24393, [15]=24393 } },
                { id = 50269, slot = "Legs", name = "Fleshwerk Leggings", sources = { [14]=24654, [15]=24654 } },
                { id = 49822, slot = "Legs", name = "Rimewoven Silks", sources = { [14]=24396, [15]=24396 } },
                { id = 49817, slot = "Legs", name = "Shaggy Wyrmleather Leggings", sources = { [14]=24392, [15]=24392 }, twSource = 76791 },
                { id = 49821, slot = "Off-hand", name = "Protector of Frigid Souls", sources = { [14]=24395, [15]=24395 }, twSource = 76794 },
                { id = 49813, slot = "Ranged", name = "Rimebane Rifle", sources = { [14]=24389, [15]=24389 }, twSource = 76789 },
                { id = 50273, slot = "Two-Hand", name = "Engraved Gargoyle Femur", sources = { [14]=24657, [15]=24657 } },
                { id = 50267, slot = "Two-Hand", name = "Tyrannical Beheader", sources = { [14]=24652, [15]=24652 } },
                { id = 50270, slot = "Waist", name = "Belt of Rotted Fingernails", sources = { [14]=24655, [15]=24655 } },
                { id = 50268, slot = "Weapon", name = "Rimefang's Claw", sources = { [14]=24653, [15]=24653 } },
                { id = 49820, slot = "Wrist", name = "Gondria's Spectral Bracer", sources = { [14]=24394, [15]=24394 }, twSource = 76793 },
            },
            specialLoot = {
                { id = 267007, kind = "decor", name = "Eye of Acherus", decorID = 18483 },
            },
        },
    },

    exitNote    = "Talk to your faction hero to be ported to the entrance",
    minExitNote = "Faction hero offers teleport",

    routing = {
        -- 1. Forgemaster Garfrost (boss 1), past the first quarry camp.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Forgemaster Garfrost",
            requires  = { },
            segments  = {
                {
                    when     = { mapID = 184 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "After zoning in, move slightly ahead to clear the first ^Quarry Camp^.",
                    minNote  = "Clear first quarry camp ahead",
                    points   = {
                        { 0.398, 0.741 },
                    },
                },
                {
                    -- Ringed until the first camp counts on the objective.
                    when            = { mapID = 184 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Camp #1",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    triggeredBy     = { scenario = 109242, quantity = 1 },
                    points          = {
                        { 0.398, 0.741 },
                    },
                },
                {
                    -- Shown with its ring once the first camp counts.
                    when            = { mapID = 184 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Camp #2",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    triggeredBy     = { scenario = 109242, quantity = 1 },
                    drawWhenOpen    = true,
                    note            = "Next, go slightly north to clear the second ^Quarry Camp^.",
                    minNote         = "North to second Quarry Camp",
                    points          = {
                        { 0.381, 0.608 },
                    },
                },
                {
                    -- The second camp counting completes the ring above.
                    when        = { mapID = 184 },
                    kind        = "poi",
                    noMarker    = true,
                    triggeredBy = { scenario = 109242, quantity = 2 },
                    points      = {
                        { 0.381, 0.608 },
                    },
                },
                {
                    when            = { mapID = 184 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Camp #3",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    triggeredBy     = { scenario = 109242, quantity = 2 },
                    drawWhenOpen    = true,
                    note            = "Next, head northeast to clear the third ^Quarry Camp^.",
                    minNote         = "Northeast to third Quarry Camp",
                    points          = {
                        { 0.452, 0.538 },
                    },
                },
                {
                    when        = { mapID = 184 },
                    kind        = "poi",
                    noMarker    = true,
                    triggeredBy = { scenario = 109242, quantity = 3 },
                    points      = {
                        { 0.452, 0.538 },
                    },
                },
                {
                    when            = { mapID = 184 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Camp #4",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    triggeredBy     = { scenario = 109242, quantity = 3 },
                    drawWhenOpen    = true,
                    note            = "Next, head southeast to clear the fourth ^Quarry Camp^.",
                    minNote         = "Southeast to fourth Quarry Camp",
                    points          = {
                        { 0.551, 0.660 },
                    },
                },
                {
                    when        = { mapID = 184 },
                    kind        = "poi",
                    noMarker    = true,
                    triggeredBy = { scenario = 109242, quantity = 4 },
                    points      = {
                        { 0.551, 0.660 },
                    },
                },
                {
                    when    = { mapID = 184 },
                    kind    = "path",
                    note    = "After clearing the fourth ^Quarry Camp^, go north to kill ^Forgemaster Garfrost^.",
                    minNote = "North to kill Garfrost",
                    points  = {
                        { 0.570, 0.598 },
                        { 0.596, 0.589 },
                        { 0.621, 0.548 },
                        { 0.658, 0.548 },
                    },
                },
            },
        },
        -- 2. Ick and Krick (boss 2), past the fifth quarry camp.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Ick and Krick",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 184 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Camp #5",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    triggeredBy     = { scenario = 109242, quantity = 4 },
                    drawWhenOpen    = true,
                    note            = "After defeating ^Forgemaster Garfrost^, head northwest to clear the fifth ^Quarry Camp^.",
                    minNote         = "Northwest to fifth Quarry Camp",
                    points          = {
                        { 0.591, 0.489 },
                    },
                },
                {
                    when        = { mapID = 184 },
                    kind        = "poi",
                    noMarker    = true,
                    triggeredBy = { scenario = 109242, quantity = 5 },
                    points      = {
                        { 0.591, 0.489 },
                    },
                },
                {
                    when            = { mapID = 184 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Camp #6",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    triggeredBy     = { scenario = 109242, quantity = 5 },
                    drawWhenOpen    = true,
                    note            = "Next, head north to clear the sixth ^Quarry Camp^.",
                    minNote         = "North to sixth Quarry Camp",
                    points          = {
                        { 0.561, 0.390 },
                    },
                },
                {
                    when        = { mapID = 184 },
                    kind        = "poi",
                    noMarker    = true,
                    triggeredBy = { scenario = 109242, quantity = 6 },
                    points      = {
                        { 0.561, 0.390 },
                    },
                },
                {
                    when    = { mapID = 184 },
                    kind    = "path",
                    note    = "After clearing the final ^Quarry Camp^, go slightly west to ^Ick and Krick^.",
                    minNote = "West to Ick and Krick",
                    points  = {
                        { 0.539, 0.395 },
                        { 0.500, 0.405 },
                    },
                },
            },
        },
        -- 3. Scourgelord Tyrannus (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Scourgelord Tyrannus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 184 },
                    kind    = "path",
                    note    = "After killing ^Ick and Krick^, go north through the gauntlet and the cave to arrive back outside and engage ^Scourgelord Tyrannus^.",
                    minNote = "North through cave to Tyrannus",
                    points  = {
                        { 0.515, 0.417 },
                        { 0.538, 0.414 },
                        { 0.539, 0.391 },
                        { 0.519, 0.376 },
                        { 0.501, 0.345 },
                        { 0.497, 0.308 },
                        { 0.512, 0.295 },
                        { 0.532, 0.303 },
                        { 0.553, 0.318 },
                        { 0.578, 0.320 },
                        { 0.600, 0.311 },
                        { 0.635, 0.257 },
                        { 0.629, 0.227 },
                        { 0.592, 0.203 },
                        { 0.560, 0.193 },
                        { 0.520, 0.184 },
                        { 0.477, 0.196 },
                        { 0.457, 0.231 },
                    },
                },
            },
        },
    },
}
