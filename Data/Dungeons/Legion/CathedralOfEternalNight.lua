-------------------------------------------------------------------------------
-- RetroRuns Data -- Cathedral of Eternal Night
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.2.0  |  instanceID: 1677  |  journalInstanceID: 900
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[900] = {
    kind              = "dungeon",
    instanceID        = 1677,
    journalInstanceID = 900,
    name              = "Cathedral of Eternal Night",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 15, 16 },
    patch             = "7.2.0",
    routedIn          = "3.5.1",

    entrance = {
        mapID = 646,
        x     = 0.6487,
        y     = 0.1683,
    },

    bosses = {
        {
            index              = 1,
            name               = "Agronox",
            journalEncounterID = 1905,
            dungeonEncounterID = 2055,
            achievements       = {
                { id = 11768, name = "Boom Bloom", soloable = "yes" },
            },
            loot = {
                { id = 144468, slot = "Back", name = "Felpruner's Shroud", sources = { [15]=84580, [16]=84580 } },
                { id = 144483, slot = "Chest", name = "Spore-Coated Vest", sources = { [14]=84598, [15]=84599, [16]=84598 } },
                { id = 144490, slot = "Feet", name = "Corruption-Fused Stompers", sources = { [14]=84612, [15]=84613, [16]=84612 } },
                { id = 144470, slot = "Hands", name = "Grovetender's Handwraps", sources = { [14]=84584, [15]=84585, [16]=84584 } },
                { id = 144469, slot = "Shoulder", name = "Caretaker's Budding Mantle", sources = { [14]=84582, [15]=84583, [16]=84582 } },
                { id = 144497, slot = "Waist", name = "Petrified Husk Girdle", sources = { [14]=84624, [15]=84625, [16]=84624 } },
                { id = 144491, slot = "Wrist", name = "Choking Vine Bindings", sources = { [14]=84614, [15]=84615, [16]=84614 } },
                { id = 144498, slot = "Wrist", name = "Vambraces of Fel Crust", sources = { [14]=84626, [15]=84627, [16]=84626 } },
            },
        },
        {
            index              = 2,
            name               = "Thrashbite the Scornful",
            journalEncounterID = 1906,
            dungeonEncounterID = 2057,
            scenarioCriteriaID = 36202,
            achievements       = {
                { id = 11769, name = "A Steamy Romance Saga", soloable = "no" },
            },
            loot = {
                { id = 144499, slot = "Chest", name = "Tenderized Breastplate", sources = { [14]=84628, [15]=84629, [16]=84628 } },
                { id = 144471, slot = "Feet", name = "Pulverizing Felsoles", sources = { [14]=84586, [15]=84587, [16]=84586 } },
                { id = 144492, slot = "Hands", name = "Chain-Draped Gauntlets", sources = { [14]=84616, [15]=84617, [16]=84616 } },
                { id = 144484, slot = "Legs", name = "Tattered Scornful Leggings", sources = { [14]=84600, [15]=84601, [16]=84600 } },
                { id = 144493, slot = "Shoulder", name = "Link-Lashed Spaulders", sources = { [14]=84618, [15]=84619, [16]=84618 } },
                { id = 144472, slot = "Waist", name = "Thrashbite's Cummerbund", sources = { [14]=84588, [15]=84589, [16]=84588 } },
                { id = 144485, slot = "Wrist", name = "Mo'arg Heavyweight's Wristwraps", sources = { [14]=84602, [15]=84603, [16]=84602 } },
            },
        },
        {
            index              = 3,
            name               = "Domatrax",
            journalEncounterID = 1904,
            dungeonEncounterID = 2053,
            achievements       = {
            },
            loot = {
                { id = 144476, slot = "Back", name = "Cloak of the Unending Assault", sources = { [15]=84596, [16]=84596 } },
                { id = 144495, slot = "Chest", name = "Domatrax's Chain Hauberk", sources = { [14]=84620, [15]=84621, [16]=84620 } },
                { id = 144500, slot = "Feet", name = "Two-Toed Thrashstompers", sources = { [14]=84630, [15]=84631, [16]=84630 } },
                { id = 144488, slot = "Hands", name = "Feaster Hide Gloves", sources = { [14]=84608, [15]=84609, [16]=84608 } },
                { id = 144503, slot = "Head", name = "Helm of Domatrax", sources = { [14]=84636, [15]=84637, [16]=84636 } },
                { id = 144474, slot = "Legs", name = "Sheer Felwoven Hosiery", sources = { [14]=84592, [15]=84593, [16]=84592 } },
                { id = 144489, slot = "Shoulder", name = "Shoulderguards of Legion Domination", sources = { [14]=84610, [15]=84611, [16]=84610 } },
                { id = 144496, slot = "Waist", name = "Burning Chain Waistguard", sources = { [14]=84622, [15]=84623, [16]=84622 } },
                { id = 144475, slot = "Wrist", name = "Dark Mistress' Cuffs", sources = { [14]=84594, [15]=84595, [16]=84594 } },
            },
        },
        {
            index              = 4,
            name               = "Mephistroth",
            journalEncounterID = 1878,
            dungeonEncounterID = 2039,
            achievements       = {
                { id = 11703, name = "Master of Shadows", soloable = "yes" },
            },
            loot = {
                { id = 144473, slot = "Chest", name = "Nathrezim Acolyte's Robes", sources = { [14]=84590, [15]=84591, [16]=84590 } },
                { id = 144487, slot = "Feet", name = "Treads of Creeping Shadows", sources = { [14]=84606, [15]=84607, [16]=84606 } },
                { id = 144502, slot = "Hands", name = "Shadowed Grips of the Nathrezim", sources = { [14]=84634, [15]=84635, [16]=84634 } },
                { id = 144494, slot = "Head", name = "Imposing Dreadsoul Headgear", sources = { [14]=84638, [15]=84639, [16]=84638 } },
                { id = 144501, slot = "Shoulder", name = "Dread Commander's Pauldrons", sources = { [14]=84632, [15]=84633, [16]=84632 } },
                { id = 144486, slot = "Waist", name = "Cerulean Shadowfade Belt", sources = { [14]=84604, [15]=84605, [16]=84604 } },
            },
        },
    },

    exitNote    = "Talk to ^Illidan Stormrage^ to be transported out.",
    minExitNote = "Talk to Illidan for exit",

    routing = {
        -- 1. Agronox (boss 1), on the floor above.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Agronox",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 845 },
                    kind    = "path",
                    note    = "After zoning in, loop around the main path and go up the stairs at the far north end of the room.",
                    minNote = "North path, go upstairs",
                    points  = {
                        { 0.467, 0.881 },
                        { 0.472, 0.684 },
                        { 0.576, 0.685 },
                        { 0.652, 0.624 },
                        { 0.684, 0.527 },
                        { 0.681, 0.447 },
                        { 0.646, 0.371 },
                        { 0.580, 0.325 },
                        { 0.476, 0.308 },
                        { 0.463, 0.263 },
                        { 0.461, 0.232 },
                        { 0.478, 0.225 },
                    },
                },
                {
                    when    = { mapID = 846 },
                    kind    = "path",
                    note    = "Once you reach the top of the stairs, take the southwest path and loop around to ^Agronox^.",
                    minNote = "Southwest path to Agronox",
                    points  = {
                        { 0.456, 0.111 },
                        { 0.475, 0.102 },
                        { 0.493, 0.121 },
                        { 0.488, 0.163 },
                        { 0.471, 0.167 },
                        { 0.471, 0.204 },
                        { 0.413, 0.257 },
                        { 0.400, 0.315 },
                        { 0.403, 0.360 },
                        { 0.412, 0.394 },
                        { 0.441, 0.384 },
                        { 0.480, 0.375 },
                        { 0.511, 0.388 },
                        { 0.530, 0.423 },
                    },
                },
            },
        },
        -- 2. Thrashbite the Scornful (boss 2), on the floor above.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Thrashbite the Scornful",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 846 },
                    kind    = "path",
                    note    = "After killing ^Agronox^, go south to climb another stairwell.",
                    minNote = "South to go up more stairs",
                    points  = {
                        { 0.531, 0.477 },
                        { 0.534, 0.536 },
                        { 0.539, 0.579 },
                        { 0.525, 0.619 },
                        { 0.450, 0.733 },
                        { 0.444, 0.762 },
                        { 0.455, 0.774 },
                        { 0.479, 0.772 },
                    },
                },
                {
                    when    = { mapID = 847 },
                    kind    = "path",
                    note    = "After reaching the top of the stairs, continue north to reach ^Thrashbite the Scornful^. Kill ^Gazerax^ to spawn the boss.",
                    minNote = "North to Thrashbite",
                    points  = {
                        { 0.498, 0.869 },
                        { 0.504, 0.898 },
                        { 0.525, 0.907 },
                        { 0.544, 0.893 },
                        { 0.550, 0.864 },
                        { 0.539, 0.838 },
                        { 0.523, 0.828 },
                        { 0.524, 0.620 },
                    },
                },
            },
        },
        -- 3. Domatrax (boss 3), past Nal'asha and up the stairs.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Domatrax",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 847 },
                    kind    = "path",
                    note    = "After defeating ^Thrashbite^, continue north to climb another stairwell.",
                    minNote = "North to another stairwell",
                    points  = {
                        { 0.526, 0.546 },
                        { 0.527, 0.361 },
                        { 0.508, 0.345 },
                        { 0.509, 0.314 },
                        { 0.524, 0.295 },
                        { 0.542, 0.306 },
                    },
                },
                {
                    when    = { mapID = 848 },
                    kind    = "path",
                    note    = "After you reach the top of the stairs, move ahead and kill ^Nal'asha^ to unblock the path. Continue south to climb one more stairwell.",
                    minNote = "Kill Nal'asha then climb stairs",
                    points  = {
                        { 0.463, 0.129 },
                        { 0.483, 0.122 },
                        { 0.503, 0.139 },
                        { 0.502, 0.197 },
                        { 0.483, 0.211 },
                        { 0.474, 0.655 },
                        { 0.452, 0.669 },
                        { 0.453, 0.694 },
                        { 0.462, 0.716 },
                        { 0.481, 0.716 },
                        { 0.492, 0.698 },
                    },
                },
                {
                    when    = { mapID = 849 },
                    kind    = "path",
                    note    = "Once you reach the top of the stairs, continue ahead to click the ^Aegis of Aggramar^ in the middle of the room to start the encounter with ^Domatrax^.",
                    minNote = "Click Aegis for Domatrax",
                    points  = {
                        { 0.486, 0.852 },
                        { 0.499, 0.911 },
                        { 0.532, 0.920 },
                        { 0.565, 0.881 },
                        { 0.559, 0.852 },
                        { 0.519, 0.789 },
                        { 0.522, 0.611 },
                        { 0.522, 0.514 },
                    },
                },
                {
                    -- Noteless: the path's note above stands.
                    when        = { mapID = 849 },
                    kind        = "poi",
                    mapLabel    = "Click Aegis",
                    mapLabelPos = "above",
                    points      = {
                        { 0.524, 0.360 },
                    },
                },
            },
        },
        -- 4. Mephistroth (boss 4), started at the same Aegis.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Mephistroth",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 849 },
                    kind        = "poi",
                    note        = "After defeating ^Domatrax^, click the ^Aegis^ once more and kill the nearby trash to start the final encounter with ^Mephistroth^.",
                    minNote     = "Click Aegis again for Mephistroth",
                    mapLabel    = "Click Aegis",
                    mapLabelPos = "above",
                    points      = {
                        { 0.524, 0.360 },
                    },
                },
            },
        },
    },
}
