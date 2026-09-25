-------------------------------------------------------------------------------
-- RetroRuns Data -- Dire Maul - Warpwood Quarter
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.3  |  instanceID: 429  |  journalInstanceID: 1276
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1276] = {
    kind              = "dungeon",
    instanceID        = 429,
    journalInstanceID = 1276,
    name              = "Dire Maul - Warpwood Quarter",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.3",
    timewalking       = true,

    -- All three Dire Maul wings share instanceID 429, so the instance id
    -- alone cannot say which one the player entered. These are this wing's
    -- floors out of the six in UiMapGroupMember group 159 (235 Gordok
    -- Commons; 236/237/238 the west wing; 239/240 here).
    uiMaps = { 239, 240 },

    entrance = {
        -- The East main gate, on the ravine's eastern approach. The pair of
        -- doors beside the West entrance both lead into Capital Gardens, and
        -- two further doors to the east are back ways into this wing.
        mapID = 69,
        x     = 0.6485,
        y     = 0.3007,
    },

    trashLoot = {
        { id = 18295, slot = "Feet", name = "Phasing Boots", sources = { [14]=7249 }, bind = "BoE" },
        { id = 18344, slot = "Hands", name = "Stonebark Gauntlets", sources = { [14]=7281 }, bind = "BoE" },
        { id = 18298, slot = "Legs", name = "Unbridled Leggings", sources = { [14]=7251 }, bind = "BoE" },
        { id = 18296, slot = "Wrist", name = "Marksman Bands", sources = { [14]=7250 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Lethtendris",
            journalEncounterID = 404,
            dungeonEncounterID = 345,
            achievements       = {
            },
            loot = {
                { id = 18325, slot = "Head", name = "Felhide Cap", sources = { [14]=7272 } },
                { id = 18301, slot = "Ranged", name = "Lethtendris' Wand", sources = { [14]=7252 } },
                { id = 18311, slot = "Two-Hand", name = "Quel'dorei Channeling Rod", sources = { [14]=7261 } },
            },
        },
        {
            index              = 2,
            name               = "Hydrospawn",
            journalEncounterID = 403,
            dungeonEncounterID = 344,
            achievements       = {
            },
            loot = {
                { id = 18307, slot = "Feet", name = "Riptide Shoes", sources = { [14]=7257 } },
                { id = 18322, slot = "Feet", name = "Waterspout Boots", sources = { [14]=7269 } },
                { id = 18305, slot = "Legs", name = "Breakwater Legguards", sources = { [14]=7255 } },
                { id = 18324, slot = "Two-Hand", name = "Waveslicer", sources = { [14]=7271 } },
            },
        },
        {
            index              = 3,
            name               = "Zevrim Thornhoof",
            journalEncounterID = 402,
            dungeonEncounterID = 343,
            achievements       = {
            },
            loot = {
                { id = 18306, slot = "Hands", name = "Gloves of Shadowy Mist", sources = { [14]=7256 } },
                { id = 18308, slot = "Head", name = "Clever Hat", sources = { [14]=7258 } },
                { id = 18319, slot = "Head", name = "Fervent Helm", sources = { [14]=7266 } },
                { id = 18313, slot = "Head", name = "Helm of Awareness", sources = { [14]=7263 } },
                { id = 18323, slot = "Ranged", name = "Satyr's Bow", sources = { [14]=7270 } },
            },
        },
        {
            index              = 4,
            name               = "Alzzin the Wildshaper",
            journalEncounterID = 405,
            dungeonEncounterID = 346,
            achievements       = {
            },
            loot = {
                { id = 18328, slot = "Back", name = "Shadewood Cloak", sources = { [14]=7275 } },
                { id = 18312, slot = "Chest", name = "Energized Chestplate", sources = { [14]=7262 } },
                { id = 18318, slot = "Feet", name = "Merciful Greaves", sources = { [14]=7265 } },
                { id = 18309, slot = "Hands", name = "Gloves of Restoration", sources = { [14]=7259 } },
                { id = 18326, slot = "Hands", name = "Razor Gauntlets", sources = { [14]=7273 } },
                { id = 18327, slot = "Waist", name = "Whipvine Cord", sources = { [14]=7274 } },
                { id = 18321, slot = "Weapon", name = "Energetic Rod", sources = { [14]=7268 } },
                { id = 18310, slot = "Weapon", name = "Fiendish Machete", sources = { [14]=7260 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Lethtendris (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Lethtendris",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 239 },
                    kind    = "path",
                    note    = "After zoning in, follow the path counter-clockwise and take the northeast exit out of the room. Take your next right, and go up the ramp at the other end of the room to find ^Lethtendris^.",
                    minNote = "Follow path to Lethtendris",
                    points  = {
                        { 0.130, 0.364 },
                        { 0.125, 0.763 },
                        { 0.318, 0.769 },
                        { 0.320, 0.257 },
                        { 0.439, 0.261 },
                        { 0.439, 0.348 },
                        { 0.381, 0.442 },
                        { 0.380, 0.562 },
                        { 0.424, 0.657 },
                        { 0.435, 0.657 },
                        { 0.435, 0.527 },
                    },
                },
            },
        },
        -- 2. Hydrospawn (boss 2). Two segments: down off the Warpwood
        -- floor on 239, then the Shrine of Eldretharr on 240.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Hydrospawn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 239 },
                    kind    = "path",
                    note    = "After defeating ^Lethtendris^, go back down the ramp and take a left towards ^The Shrine of Eldretharr^.",
                    minNote = "Down ramp, go left",
                    points  = {
                        { 0.439, 0.582 },
                        { 0.436, 0.665 },
                        { 0.455, 0.665 },
                        { 0.478, 0.631 },
                        { 0.514, 0.631 },
                    },
                },
                {
                    when    = { mapID = 240 },
                    kind    = "path",
                    note    = "After reaching the bottom of the spiral ramp, find ^Hydrospawn^ in the small body of water ahead.",
                    minNote = "Hydrospawn ahead in water",
                    points  = {
                        { 0.620, 0.828 },
                        { 0.636, 0.856 },
                        { 0.638, 0.893 },
                        { 0.619, 0.925 },
                        { 0.594, 0.921 },
                        { 0.571, 0.884 },
                        { 0.532, 0.755 },
                    },
                },
            },
        },
        -- 3. Zevrim Thornhoof (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Zevrim Thornhoof",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 240 },
                    kind    = "path",
                    note    = "After killing ^Hydrospawn^, take the northern ramp out of the room and continue on the path until you reach ^Zevrim Thornhoof^ on the upper platform.",
                    minNote = "Northern ramp to Zevrim",
                    points  = {
                        { 0.538, 0.649 },
                        { 0.577, 0.555 },
                        { 0.583, 0.526 },
                        { 0.602, 0.519 },
                        { 0.616, 0.529 },
                        { 0.622, 0.559 },
                        { 0.620, 0.694 },
                        { 0.600, 0.690 },
                        { 0.586, 0.711 },
                    },
                },
            },
        },
        -- 4. Alzzin the Wildshaper (boss 4). Ironbark opens the door on an
        -- escort, so the marker sits on him and his reply advances the step.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Alzzin the Wildshaper",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 240 },
                    kind    = "path",
                    note    = "After defeating ^Zevrim Thornhoof^, jump off the platform to the west and take the southwest exit to ^The Conservatory^. Follow the path north until you reach ^Ironbark the Redeemed^. Talk to him to begin an escort to open the door.",
                    minNote = "Jump off, south to Ironbark",
                    points  = {
                        { 0.553, 0.753 },
                        { 0.531, 0.753 },
                        { 0.529, 0.913 },
                        { 0.489, 0.910 },
                        { 0.441, 0.849 },
                    },
                },
                {
                    when        = { mapID = 240 },
                    kind        = "poi",
                    mapLabel    = "Talk to Ironbark",
                    mapLabelPos = "above",
                    completionCheck = true,
                    triggeredBy = { dialog = { npc = "Ironbark the Redeemed", match = "As you wish" } },
                    points      = {
                        { 0.403, 0.799 },
                    },
                },
                {
                    when    = { mapID = 240 },
                    kind    = "path",
                    note    = "After the door is opened, follow the path to reach ^Alzzin the Wildshaper^.",
                    minNote = "Through north door to Alzzin",
                    points  = {
                        { 0.406, 0.667 },
                        { 0.393, 0.592 },
                        { 0.404, 0.476 },
                        { 0.402, 0.330 },
                        { 0.411, 0.299 },
                        { 0.435, 0.288 },
                        { 0.543, 0.290 },
                    },
                },
            },
        },
    },
}
