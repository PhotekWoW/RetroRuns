-------------------------------------------------------------------------------
-- RetroRuns Data -- Zul'Farrak
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 209  |  journalInstanceID: 241
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[241] = {
    kind              = "dungeon",
    instanceID        = 209,
    journalInstanceID = 241,
    name              = "Zul'Farrak",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 24 },
    patch             = "1.0",
    timewalking       = true,

    entrance = {
        mapID = 71,
        x     = 0.3920,
        y     = 0.2120,
    },

    trashLoot = {
        { id = 9512, slot = "Back", name = "Blackmetal Cape", sources = { [14]=3327 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 12470, slot = "Feet", name = "Sandstalker Ankleguards", sources = { [14]=4442 }, bind = "BoP", rareNpc = "Zerillis" },
        { id = 9484, slot = "Legs", name = "Spellshock Leggings", sources = { [14]=3314 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 12471, slot = "Off-hand", name = "Desertwalker Cane", sources = { [14]=4443 }, bind = "BoP", rareNpc = "Dustwraith" },
        { id = 2040, slot = "Off-hand", name = "Troll Protector", sources = { [14]=556 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 9483, slot = "Ranged", name = "Flaming Incinerator", sources = { [14]=3313 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 9480, slot = "Two-Hand", name = "Eyegouger", sources = { [14]=3310 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 9481, slot = "Two-Hand", name = "The Minotaur", sources = { [14]=3311 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 9482, slot = "Two-Hand", name = "Witch Doctor's Cane", sources = { [14]=3312 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 9511, slot = "Weapon", name = "Bloodletter Scalpel", sources = { [14]=3326 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
        { id = 5616, slot = "Weapon", name = "Gutwrencher", sources = { [14]=2158 }, bind = "BoE", rareNpc = "Sandarr Dunereaver" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Theka the Martyr",
            journalEncounterID = 485,
            dungeonEncounterID = 596,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 2,
            name               = "Hydromancer Velratha",
            journalEncounterID = 482,
            dungeonEncounterID = 593,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 3,
            name               = "Antu'sul",
            journalEncounterID = 484,
            dungeonEncounterID = 595,
            achievements       = {
            },
            loot = {
                { id = 9640, slot = "Hands", name = "Vice Grips", sources = { [14]=3368 } },
                { id = 9379, slot = "Weapon", name = "Sang'thraze the Deflector", sources = { [14]=3231 }, bagAlert = true },
                { id = 9639, slot = "Weapon", name = "The Hand of Antu'sul", sources = { [14]=3367 } },
            },
            tmogFootnote = {
                text       = "{item1} combines with {item2}, dropped by Chief Ukorz Sandscalp, to form {item3}.",
                itemIDs    = { 9379, 11086, 9372 },
            },
        },
        {
            index              = 4,
            name               = "Witch Doctor Zum'rah",
            journalEncounterID = 486,
            dungeonEncounterID = 597,
            achievements       = {
            },
            loot = {
                { id = 18083, slot = "Hands", name = "Jumanza Grips", sources = { [14]=7227 } },
                { id = 18082, slot = "Two-Hand", name = "Zum'rah's Vexing Cane", sources = { [14]=7226 } },
            },
        },
        {
            index              = 5,
            name               = "Gahz'rilla",
            journalEncounterID = 483,
            dungeonEncounterID = 594,
            aliases            = { "Ghaz'rilla" },
            achievements       = {
            },
            loot = {
                { id = 151455, slot = "Back", name = "Gahz'rilla Scale Cloak", sources = { [14]=89451 } },
                { id = 9469, slot = "Chest", name = "Gahz'rilla Scale Armor", sources = { [14]=3301 } },
                { id = 9467, slot = "Weapon", name = "Gahz'rilla Fang", sources = { [14]=3300 } },
            },
        },
        {
            index              = 6,
            name               = "Nekrum & Sezz'ziz",
            journalEncounterID = 487,
            dungeonEncounterID = 598,
            -- One pull, two encounters: the pair fires ENCOUNTER_END twice,
            -- for Nekrum Gutchewer (598) and Shadowpriest Sezz'ziz (599).
            -- Only 598 carries a journal entry, so the second arrives with
            -- an id this row cannot resolve; the names let the fallback
            -- land it here instead of reporting an unmatched kill.
            aliases            = { "Nekrum Gutchewer", "Shadowpriest Sezz'ziz" },
            -- The scenario tracks the pair as two "defeated" objectives.
            scenarioCriteriaIDs = { 24947, 24946 },
            achievements       = {
            },
            loot = {
                { id = 9473, slot = "Chest", name = "Jinxed Hoodoo Skin", sources = { [14]=3303 } },
                { id = 151458, slot = "Feet", name = "Sezz'ziz's Captive Kickers", sources = { [14]=89452 } },
                { id = 9470, slot = "Head", name = "Bad Mojo Mask", sources = { [14]=3302 } },
                { id = 9474, slot = "Legs", name = "Jinxed Hoodoo Kilt", sources = { [14]=3304 } },
                { id = 9475, slot = "Two-Hand", name = "Diabolic Skiver", sources = { [14]=3305 } },
                { id = 151459, slot = "Waist", name = "Nekrum's Witherguard", sources = { [14]=89453 } },
            },
        },
        {
            index              = 7,
            name               = "Chief Ukorz Sandscalp",
            journalEncounterID = 489,
            dungeonEncounterID = 600,
            achievements       = {
            },
            loot = {
                { id = 151460, slot = "Chest", name = "Farraki Ceremonial Robes", sources = { [14]=89454 } },
                { id = 9479, slot = "Head", name = "Embrace of the Lycan", sources = { [14]=3309 } },
                { id = 151461, slot = "Legs", name = "Ukorz's Chain Leggings", sources = { [14]=89455 } },
                { id = 9476, slot = "Shoulder", name = "Big Bad Pauldrons", sources = { [14]=3306 } },
                { id = 9372, slot = "Two-Hand", name = "Sul'thraze the Lasher", sources = { [14]=3228, [24]=230433 } },
                { id = 9477, slot = "Two-Hand", name = "The Chief's Enforcer", sources = { [14]=3307 } },
                { id = 11086, slot = "Weapon", name = "Jang'thraze the Protector", sources = { [14]=4132 }, bagAlert = true },
                { id = 9478, slot = "Weapon", name = "Ripsaw", sources = { [14]=3308 } },
            },
            tmogFootnote = {
                text       = "{item1} combines with {item2}, dropped by Antu'sul, to form {item3}.",
                itemIDs    = { 11086, 9379, 9372 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    -- Route order is not journal order. Every step is required: the four
    -- bosses the dungeon counts as bonus objectives are routed through in
    -- place, so each note can name the boss before it.
    pois = {
        -- Rare spawn points.
        { mapID = 219, poiKind = "rare", rareNpc = "Dustwraith",
          mapLabelPos = "legend-bottomleft", navPoint = { 0.374, 0.176 },
          points = { { 0.242, 0.178 }, { 0.296, 0.378 }, { 0.300, 0.438 }, { 0.304, 0.204 }, { 0.352, 0.452 }, { 0.356, 0.166 }, { 0.390, 0.284 }, { 0.392, 0.506 }, { 0.436, 0.198 }, { 0.444, 0.520 }, { 0.476, 0.574 }, { 0.482, 0.464 }, { 0.488, 0.222 }, { 0.532, 0.274 }, { 0.542, 0.460 }, { 0.544, 0.410 }, { 0.566, 0.540 }, { 0.566, 0.914 }, { 0.574, 0.790 }, { 0.574, 0.846 }, { 0.586, 0.668 }, { 0.586, 0.730 }, { 0.594, 0.600 } } },
        { mapID = 219, poiKind = "rare", rareNpc = "Sandarr Dunereaver",
          mapLabelPos = "legend-bottomleft", navPoint = { 0.520, 0.410 },
          points = { { 0.446, 0.154 }, { 0.524, 0.424 }, { 0.646, 0.270 } } },
        { mapID = 219, poiKind = "rare", rareNpc = "Zerillis",
          mapLabelPos = "legend-bottomleft", navPoint = { 0.511, 0.403 },
          points = { { 0.254, 0.178 }, { 0.366, 0.440 }, { 0.432, 0.202 }, { 0.480, 0.460 }, { 0.510, 0.392 }, { 0.510, 0.570 }, { 0.552, 0.512 }, { 0.572, 0.858 }, { 0.574, 0.780 }, { 0.584, 0.240 }, { 0.588, 0.374 }, { 0.634, 0.266 }, { 0.636, 0.432 }, { 0.648, 0.214 } } },
    },

    routing = {
        -- 1. Antu'sul (boss 3)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 3,
            title     = "Antu'sul",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 219 },
                    kind    = "path",
                    note    = "After zoning in, follow the path to ^Antu'sul^. Approach the cave and the boss will run out.",
                    minNote = "Path to Antu'sul",
                    points  = {
                        { 0.567, 0.872 },
                        { 0.589, 0.687 },
                        { 0.581, 0.605 },
                        { 0.556, 0.526 },
                        { 0.538, 0.482 },
                        { 0.525, 0.440 },
                        { 0.553, 0.410 },
                        { 0.592, 0.422 },
                        { 0.594, 0.395 },
                        { 0.580, 0.347 },
                        { 0.552, 0.301 },
                        { 0.576, 0.267 },
                        { 0.621, 0.278 },
                    },
                },
            },
        },

        -- 2. Theka the Martyr (boss 1)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 1,
            title     = "Theka the Martyr",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 219 },
                    kind    = "path",
                    note    = "After killing ^Antu'sul^, go slightly west to find ^Theka the Martyr^ patrolling around an area filled with scarabs.",
                    minNote = "West to Theka",
                    points  = {
                        { 0.615, 0.276 },
                        { 0.584, 0.271 },
                        { 0.557, 0.267 },
                    },
                },
            },
        },

        -- 3. Witch Doctor Zum'rah (boss 4)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 4,
            title     = "Witch Doctor Zum'rah",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 219 },
                    kind    = "path",
                    note    = "After defeating ^Theka^, continue northwest to find ^Witch Doctor Zum'rah^ standing in a small room under an archway. Approach him to activate the encounter.",
                    minNote = "Northwest to Zum'rah",
                    points  = {
                        { 0.508, 0.241 },
                        { 0.466, 0.201 },
                    },
                },
            },
        },

        -- 4. Nekrum & Sezz'ziz (boss 6)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 6,
            title     = "Nekrum & Sezz'ziz",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 219 },
                    kind    = "path",
                    note    = "After killing ^Zum'rah^, continue west and run up the long staircase. Kill the ^Sandfury Executioner^ and release the prisoners from their cages to start the stair event. Clear trash waves and you will find ^Shadowpriest Sezz'ziz^ and ^Nekrum Gutchewer^ at the bottom of the stairs.",
                    minNote = "West to stair event",
                    points  = {
                        { 0.392, 0.206 },
                        { 0.356, 0.190 },
                        { 0.262, 0.180 },
                    },
                },
            },
        },

        -- 5. Hydromancer Velratha (boss 2)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 2,
            title     = "Hydromancer Velratha",
            requires  = { },
            segments  = {
                {
                    -- Ring and label both track completion: red-pulsing
                    -- until Bly is down, then gray with a check.
                    when            = { mapID = 219 },
                    kind            = "poi",
                    note            = "After defeating ^Nekrum & Sezz'ziz^, talk to ^Sergeant Bly^ and kill him to open a door you will need to enter very soon.",
                    minNote         = "Kill Sergeant Bly",
                    mapLabel        = "Kill Sergeant Bly",
                    mapLabelPos     = "below",
                    highlightCircle = true,
                    completionCheck = true,
                    points          = {
                        { 0.319, 0.187 },
                    },
                },
                {
                    -- Bly's death sends Weegli off, and his parting line is
                    -- the cue that the way on has opened.
                    when        = { mapID = 219 },
                    kind        = "path",
                    note        = "After killing ^Sergeant Bly^, head south through the archway until you find ^Hydromancer Velratha^ patrolling around the pool.",
                    minNote     = "South to Hydromancer",
                    triggeredBy = { dialog = { npc = "Weegli Blastfuse", match = "I'm out of here" } },
                    points      = {
                        { 0.307, 0.218 },
                        { 0.346, 0.287 },
                        { 0.347, 0.348 },
                        { 0.312, 0.416 },
                    },
                },
            },
        },

        -- 6. Gahz'rilla (boss 5) -- spawned by the gong, so the step is a
        -- single marker on it rather than a path.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 5,
            title     = "Gahz'rilla",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 219 },
                    kind        = "poi",
                    note        = "After killing ^Hydromancer^, ring the gong at the end of the pool to spawn ^Gahz'rilla^.",
                    minNote     = "Ring gong for Gahz'rilla",
                    mapLabel    = "Ring Gong",
                    mapLabelPos = "below",
                    points      = {
                        { 0.333, 0.443 },
                    },
                },
            },
        },

        -- 7. Chief Ukorz Sandscalp (boss 7)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Chief Ukorz Sandscalp",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 219 },
                    kind    = "path",
                    note    = "After defeating ^Gahz'rilla^, backtrack to the area with the stair event and take a right. Follow the path up to reach the final boss, ^Chief Ukorz Sandscalp^.",
                    minNote = "Backtrack to Chief Ukorz",
                    points  = {
                        { 0.347, 0.343 },
                        { 0.346, 0.284 },
                        { 0.321, 0.242 },
                        { 0.350, 0.213 },
                        { 0.400, 0.302 },
                        { 0.444, 0.359 },
                    },
                },
            },
        },
    },
}
