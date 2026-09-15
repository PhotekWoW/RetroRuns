-------------------------------------------------------------------------------
-- RetroRuns Data -- The Mechanar
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 554  |  journalInstanceID: 258
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[258] = {
    kind              = "dungeon",
    instanceID        = 554,
    journalInstanceID = 258,
    name              = "The Mechanar",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.1.2",

    entrance = {
        mapID = 109,
        x     = 0.7064,
        y     = 0.6982,
    },

    trashLoot = {
        { id = 28249, slot = "Back", name = "Capacitus' Cloak of Calibration", sources = { [14]=12350, [15]=12350 }, bind = "BoP", tag = "Cache of the Legion" },
        { id = 28252, slot = "Chest", name = "Bloodfyre Robes of Annihilation", sources = { [14]=12353, [15]=12353 }, bind = "BoP", tag = "Cache of the Legion" },
        { id = 28251, slot = "Feet", name = "Boots of the Glade-Keeper", sources = { [14]=12352, [15]=12352 }, bind = "BoP", tag = "Cache of the Legion" },
        { id = 28250, slot = "Shoulder", name = "Vestia's Pauldrons of Inner Grace", sources = { [14]=12351, [15]=12351 }, bind = "BoP", tag = "Cache of the Legion" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Mechano-Lord Capacitus",
            journalEncounterID = 563,
            achievements       = {
            },
            loot = {
                { id = 28256, slot = "Back", name = "Thoriumweave Cloak", sources = { [14]=12356, [15]=12356 } },
                { id = 28255, slot = "Shoulder", name = "Lunar-Claw Pauldrons", sources = { [14]=12355, [15]=12355 } },
                { id = 28253, slot = "Two-Hand", name = "Plasma Rat's Hyper-Scythe", sources = { [14]=12354, [15]=12354 } },
                { id = 28257, slot = "Weapon", name = "Hammer of the Penitent", sources = { [14]=12357, [15]=12357 } },
            },
        },
        {
            index              = 2,
            name               = "Nethermancer Sepethrea",
            journalEncounterID = 564,
            achievements       = {
            },
            loot = {
                { id = 28262, slot = "Chest", name = "Jade-Skull Breastplate", sources = { [14]=12360, [15]=12360 } },
                { id = 28202, slot = "Chest", name = "Moonglade Robe", sources = { [14]=12324, [15]=12324 } },
                { id = 28275, slot = "Head", name = "Beast Lord Helm", sources = { [14]=12367, [15]=12367 } },
                { id = 28260, slot = "Off-hand", name = "Manual of the Nethermancer", sources = { [14]=12359, [15]=12359 } },
                { id = 28263, slot = "Weapon", name = "Stellaris", sources = { [14]=12361, [15]=12361 } },
            },
        },
        {
            index              = 3,
            name               = "Pathaleon the Calculator",
            journalEncounterID = 565,
            achievements       = {
            },
            loot = {
                { id = 28269, slot = "Back", name = "Baba's Cloak of Arcanistry", sources = { [14]=12366, [15]=12366 } },
                { id = 28204, slot = "Chest", name = "Tunic of Assassination", sources = { [14]=12326, [15]=12326 } },
                { id = 29251, slot = "Feet", name = "Boots of the Pious", sources = { [14]=13046, [15]=13046 } },
                { id = 32076, slot = "Hands", name = "Handguards of the Steady", sources = { [14]=14751, [15]=14751 } },
                { id = 28285, slot = "Head", name = "Helm of the Righteous", sources = { [14]=12369, [15]=12369 } },
                { id = 28278, slot = "Head", name = "Incanter's Cowl", sources = { [14]=12368, [15]=12368 } },
                { id = 28266, slot = "Legs", name = "Molten Earth Kilt", sources = { [14]=12363, [15]=12363 } },
                { id = 30533, slot = "Legs", name = "Vanquisher's Legplates", sources = { [14]=13806, [15]=13806 } },
                { id = 28286, slot = "Ranged", name = "Telescopic Sharprifle", sources = { [14]=12370, [15]=12370 } },
                { id = 28267, slot = "Weapon", name = "Edge of the Cosmos", sources = { [14]=12364, [15]=12364 } },
                { id = 27899, slot = "Weapon", name = "Mana Wrath", sources = { [14]=12139, [15]=12139 } },
                { id = 29362, slot = "Weapon", name = "The Sun Eater", sources = { [14]=13104, [15]=13104 } },
            },
        },
    },

    exitNote    = "There is an exit portal to your immediate south",
    minExitNote = "Exit portal to the south",

    pois = {
        { mapID = 267, poiKind = "chest", tag = "Cache of the Legion",
          mapLabelPos = "legend-bottomleft",
          hintNote = "Unlocks when Gatewatcher Gyro-Kill dies",
          points = { { 0.390, 0.278 } } },
    },

    routing = {
        -- 1. Mechano-Lord Capacitus (boss 1), after both Gatewatchers.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Mechano-Lord Capacitus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 267 },
                    kind    = "path",
                    note    = "After zoning in, go up the path on the left and kill the mini-boss ^Gatewatcher Gyro-Kill^.",
                    minNote = "Left to kill Gatewatcher Gyro-Kill",
                    points  = {
                        { 0.490, 0.840 },
                        { 0.491, 0.753 },
                        { 0.432, 0.703 },
                        { 0.405, 0.705 },
                        { 0.405, 0.641 },
                        { 0.452, 0.628 },
                    },
                },
                {
                    when        = { mapID = 267 },
                    kind        = "poi",
                    mapLabel    = "Kill Gatewatcher",
                    mapLabelPos = "above",
                    completionCheck = true,
                    triggeredBy = { scenario = 24878 },
                    points      = {
                        { 0.461, 0.592 },
                    },
                },
                {
                    when    = { mapID = 267 },
                    kind    = "path",
                    note    = "After killing ^Gatewatcher Gyro-Kill^, go down the stairs to the north, and bypass the boss for now as you aim to kill ^Gatewatcher Iron-Hand^ on the stairs to the east.",
                    minNote = "East to kill Gatewatcher Iron-Hand",
                    points  = {
                        { 0.433, 0.550 },
                        { 0.376, 0.505 },
                        { 0.379, 0.377 },
                        { 0.414, 0.377 },
                        { 0.433, 0.464 },
                        { 0.471, 0.469 },
                        { 0.498, 0.448 },
                        { 0.537, 0.361 },
                        { 0.580, 0.350 },
                        { 0.602, 0.374 },
                    },
                },
                {
                    when        = { mapID = 267 },
                    kind        = "poi",
                    mapLabel    = "Kill Gatewatcher",
                    mapLabelPos = "below",
                    completionCheck = true,
                    triggeredBy = { scenario = 24877 },
                    points      = {
                        { 0.603, 0.431 },
                    },
                },
                {
                    when    = { mapID = 267 },
                    kind    = "path",
                    note    = "After killing ^Gatewatcher Iron-Hand^, turn around and kill the boss, ^Mechano-Lord Capacitus^.",
                    minNote = "Kill Mechano-Lord Capacitus",
                    points  = { },
                },
            },
        },
        -- 2. Nethermancer Sepethrea (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Nethermancer Sepethrea",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 267 },
                    kind    = "path",
                    note    = "After defeating ^Mechano-Lord Capacitus^, loop back around to the west and go up the now-unlocked elevator.",
                    minNote = "West to elevator",
                    points  = {
                        { 0.515, 0.373 },
                        { 0.493, 0.456 },
                        { 0.449, 0.473 },
                        { 0.419, 0.435 },
                        { 0.418, 0.206 },
                    },
                },
                {
                    when    = { mapID = 268 },
                    kind    = "path",
                    note    = "After you reach the top of the elevator, you will find ^Nethermancer Sepethrea^ on the platform ahead.",
                    minNote = "Sepethrea on platform ahead",
                    points  = {
                        { 0.419, 0.303 },
                        { 0.476, 0.237 },
                    },
                },
            },
        },
        -- 3. Pathaleon the Calculator (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Pathaleon the Calculator",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 268 },
                    kind    = "path",
                    note    = "After killing ^Nethermancer Sepethrea^, take the southeast exit and follow the path to ^Pathaleon the Calculator^, killing all enemies that spawn along the path.",
                    minNote = "Southeast path to Pathaleon",
                    points  = {
                        { 0.488, 0.243 },
                        { 0.527, 0.312 },
                        { 0.529, 0.511 },
                        { 0.495, 0.591 },
                        { 0.431, 0.614 },
                        { 0.298, 0.614 },
                    },
                },
            },
        },
    },
}
