-------------------------------------------------------------------------------
-- RetroRuns Data -- The Arcatraz
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 552  |  journalInstanceID: 254
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[254] = {
    kind              = "dungeon",
    instanceID        = 552,
    journalInstanceID = 254,
    name              = "The Arcatraz",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.1.2",

    entrance = {
        mapID = 109,
        x     = 0.7457,
        y     = 0.5762,
    },

    bosses = {
        {
            index              = 1,
            name               = "Zereketh the Unbound",
            journalEncounterID = 548,
            achievements       = {
            },
            loot = {
                { id = 28373, slot = "Back", name = "Cloak of Scintillating Auras", sources = { [14]=12425, [15]=12425 } },
                { id = 28384, slot = "Feet", name = "Outland Striders", sources = { [14]=12434, [15]=12434 } },
                { id = 28396, slot = "Hands", name = "Gloves of the Unbound", sources = { [14]=12442, [15]=12442 } },
                { id = 28415, slot = "Head", name = "Hood of Oblivion", sources = { [14]=12459, [15]=12459 } },
                { id = 28374, slot = "Shoulder", name = "Mana-Sphere Shoulderguards", sources = { [14]=12426, [15]=12426 } },
                { id = 28375, slot = "Waist", name = "Rubium War-Girdle", sources = { [14]=12427, [15]=12427 } },
            },
        },
        {
            index              = 2,
            name               = "Dalliah the Doomsayer",
            journalEncounterID = 549,
            achievements       = {
            },
            loot = {
                { id = 28384, slot = "Feet", name = "Outland Striders", sources = { [14]=12434, [15]=12434 } },
                { id = 28390, slot = "Hands", name = "Thatia's Self-Correcting Gauntlets", sources = { [14]=12438, [15]=12438 } },
                { id = 28414, slot = "Head", name = "Helm of Assassination", sources = { [14]=12458, [15]=12458 } },
                { id = 28387, slot = "Off-hand", name = "Lamp of Peaceful Repose", sources = { [14]=12437, [15]=12437 } },
                { id = 28386, slot = "Ranged", name = "Nether Core's Control Rod", sources = { [14]=12436, [15]=12436 } },
                { id = 28416, slot = "Weapon", name = "Hungering Spineripper", sources = { [14]=12460, [15]=12460 } },
                { id = 28392, slot = "Weapon", name = "Reflex Blades", sources = { [14]=12440, [15]=12440 } },
            },
        },
        {
            index              = 3,
            name               = "Wrath-Scryer Soccothrates",
            journalEncounterID = 550,
            achievements       = {
            },
            loot = {
                { id = 28403, slot = "Chest", name = "Doomplate Chestguard", sources = { [14]=12448, [15]=12448 } },
                { id = 28391, slot = "Chest", name = "Worldfire Chestguard", sources = { [14]=12439, [15]=12439 } },
                { id = 28413, slot = "Head", name = "Hallowed Crown", sources = { [14]=12457, [15]=12457 } },
                { id = 28397, slot = "Ranged", name = "Emberhawk Crossbow", sources = { [14]=12443, [15]=12443 } },
                { id = 28393, slot = "Two-Hand", name = "Warmaul of Infused Light", sources = { [14]=12441, [15]=12441 } },
                { id = 28398, slot = "Waist", name = "The Sleeper's Cord", sources = { [14]=12444, [15]=12444 } },
            },
        },
        {
            index              = 4,
            name               = "Harbinger Skyriss",
            journalEncounterID = 551,
            achievements       = {
            },
            loot = {
                { id = 28205, slot = "Chest", name = "Breastplate of the Bold", sources = { [14]=12327, [15]=12327 } },
                { id = 28231, slot = "Chest", name = "Tidefury Chestpiece", sources = { [14]=12348, [15]=12348 } },
                { id = 29248, slot = "Feet", name = "Shadowstep Striders", sources = { [14]=13043, [15]=13043 } },
                { id = 28406, slot = "Feet", name = "Sigil-Laced Boots", sources = { [14]=12451, [15]=12451 } },
                { id = 28412, slot = "Off-hand", name = "Lamp of Peaceful Radiance", sources = { [14]=12456, [15]=12456 } },
                { id = 29241, slot = "Waist", name = "Belt of Depravity", sources = { [14]=13036, [15]=13036 } },
                { id = 29360, slot = "Weapon", name = "Vileblade of the Betrayer", sources = { [14]=13103, [15]=13103 } },
                { id = 29252, slot = "Wrist", name = "Bracers of Dignity", sources = { [14]=13047, [15]=13047 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Zereketh the Unbound (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Zereketh the Unbound",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 269 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path until you reach ^Zereketh the Unbound^.",
                    minNote = "Follow path Zereketh",
                    points  = {
                        { 0.415, 0.752 },
                        { 0.414, 0.445 },
                        { 0.450, 0.394 },
                        { 0.599, 0.393 },
                        { 0.602, 0.284 },
                    },
                },
            },
        },
        -- 2. Dalliah the Doomsayer (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Dalliah the Doomsayer",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 269 },
                    kind    = "path",
                    note    = "After defeating ^Zereketh^, go up the spiral ramp on the east side of the room.",
                    minNote = "East to spiral ramp",
                    points  = {
                        { 0.618, 0.309 },
                        { 0.645, 0.358 },
                        { 0.667, 0.352 },
                        { 0.689, 0.329 },
                        { 0.689, 0.298 },
                        { 0.674, 0.263 },
                    },
                },
                {
                    when    = { mapID = 270 },
                    kind    = "path",
                    note    = "Follow the linear path until you reach ^Dalliah the Doomsayer^.",
                    minNote = "Follow path to Dalliah",
                    points  = {
                        { 0.896, 0.469 },
                        { 0.894, 0.419 },
                        { 0.863, 0.386 },
                        { 0.605, 0.386 },
                        { 0.421, 0.292 },
                        { 0.322, 0.292 },
                        { 0.285, 0.361 },
                        { 0.285, 0.640 },
                        { 0.346, 0.750 },
                    },
                },
            },
        },
        -- 3. Wrath-Scryer Soccothrates (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Wrath-Scryer Soccothrates",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 270 },
                    kind    = "path",
                    note    = "With ^Dalliah^ dead, turn around to kill ^Wrath-Scryer Soccothrates^ behind you.",
                    minNote = "Soccothrates behind you",
                    points  = { },
                },
            },
        },
        -- 4. Harbinger Skyriss (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Harbinger Skyriss",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 270 },
                    kind    = "path",
                    note    = "After killing ^Soccothrates^, backtrack a little and go up the stairs to the east.",
                    minNote = "Backtrack to east stairs",
                    points  = {
                        { 0.227, 0.759 },
                        { 0.320, 0.573 },
                        { 0.456, 0.571 },
                    },
                },
                {
                    when    = { mapID = 271 },
                    kind    = "path",
                    note    = "Follow the linear path until you reach ^Harbinger Skyriss^. Tag ^Warden Mellichar^ to start the encounter.",
                    minNote = "Follow path to Skyriss",
                    points  = {
                        { 0.238, 0.883 },
                        { 0.302, 0.883 },
                        { 0.303, 0.363 },
                        { 0.339, 0.306 },
                        { 0.594, 0.305 },
                    },
                },
            },
        },
    },
}
