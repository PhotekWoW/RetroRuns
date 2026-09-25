-------------------------------------------------------------------------------
-- RetroRuns Data -- Auchenai Crypts
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 558  |  journalInstanceID: 247
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[247] = {
    kind              = "dungeon",
    instanceID        = 558,
    journalInstanceID = 247,
    name              = "Auchenai Crypts",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.2.0",

    entrance = {
        mapID = 108,
        x     = 0.3419,
        y     = 0.6560,
    },

    bosses = {
        {
            index              = 1,
            name               = "Shirrak the Dead Watcher",
            journalEncounterID = 523,
            dungeonEncounterID = 1890,
            achievements       = {
            },
            loot = {
                { id = 27845, slot = "Feet", name = "Magma Plume Boots", sources = { [14]=12103, [15]=12103 } },
                { id = 27493, slot = "Hands", name = "Gloves of the Deadwatcher", sources = { [14]=11935, [15]=11935 } },
                { id = 27410, slot = "Head", name = "Collar of Command", sources = { [14]=11881, [15]=11881 } },
                { id = 27408, slot = "Head", name = "Hope Bearer Helm", sources = { [14]=11879, [15]=11879 } },
                { id = 27409, slot = "Head", name = "Raven-Heart Headdress", sources = { [14]=11880, [15]=11880 } },
                { id = 27866, slot = "Head", name = "Scintillating Headdress of Second Sight", sources = { [14]=12113, [15]=12113 } },
                { id = 27847, slot = "Shoulder", name = "Fanblade Pauldrons", sources = { [14]=12105, [15]=12105 } },
                { id = 27846, slot = "Weapon", name = "Claw of the Watcher", sources = { [14]=12104, [15]=12104 } },
                { id = 25964, slot = "Weapon", name = "Shaarde the Lesser", sources = { [14]=10673, [15]=10673 } },
                { id = 27865, slot = "Wrist", name = "Bracers of Shirrak", sources = { [14]=12112, [15]=12112 } },
            },
        },
        {
            index              = 2,
            name               = "Exarch Maladaar",
            journalEncounterID = 524,
            dungeonEncounterID = 1889,
            achievements       = {
            },
            loot = {
                { id = 29354, slot = "Back", name = "Light-Touched Stole of Altruism", sources = { [14]=13098, [15]=13098 } },
                { id = 27867, slot = "Feet", name = "Boots of the Unjust", sources = { [14]=12114, [15]=12114 } },
                { id = 27411, slot = "Feet", name = "Slippers of Serenity", sources = { [14]=11882, [15]=11882 } },
                { id = 27415, slot = "Head", name = "Darkguard Face Mask", sources = { [14]=11885, [15]=11885 } },
                { id = 27414, slot = "Head", name = "Mok'Nathal Beast-Mask", sources = { [14]=11884, [15]=11884 } },
                { id = 27870, slot = "Legs", name = "Doomplate Legguards", sources = { [14]=12116, [15]=12116 }, setName = "Doomplate Battlegear", dungeonSet = 3 },
                { id = 27412, slot = "Two-Hand", name = "Ironstaff of Regeneration", sources = { [14]=11883, [15]=11883 } },
                { id = 29257, slot = "Waist", name = "Sash of Arcane Visions", sources = { [14]=13051, [15]=13051 } },
                { id = 29244, slot = "Waist", name = "Wave-Song Girdle", sources = { [14]=13039, [15]=13039 } },
                { id = 27872, slot = "Weapon", name = "The Harvester of Souls", sources = { [14]=12117, [15]=12117 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Shirrak the Dead Watcher (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Shirrak the Dead Watcher",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 256 },
                    kind    = "path",
                    note    = "After zoning in, head north on the linear path and climb the staircase. Follow the path east into the next room.",
                    minNote = "North to stairs then east",
                    points  = {
                        { 0.443, 0.734 },
                        { 0.442, 0.470 },
                        { 0.435, 0.422 },
                        { 0.435, 0.313 },
                        { 0.447, 0.170 },
                        { 0.398, 0.170 },
                        { 0.399, 0.292 },
                        { 0.419, 0.301 },
                        { 0.480, 0.300 },
                        { 0.481, 0.232 },
                        { 0.512, 0.233 },
                    },
                },
                {
                    when    = { mapID = 257 },
                    kind    = "path",
                    note    = "Continue following the linear path until you reach ^Shirrak the Dead Watcher^.",
                    minNote = "Follow path to Shirrak",
                    points  = {
                        { 0.358, 0.173 },
                        { 0.424, 0.173 },
                        { 0.462, 0.234 },
                        { 0.465, 0.646 },
                    },
                },
            },
        },
        -- 2. Exarch Maladaar (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Exarch Maladaar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 257 },
                    kind    = "path",
                    note    = "After defeating ^Shirrak^, continue on the linear path until you reach ^Exarch Maladaar^.",
                    minNote = "Follow path to Maladaar",
                    points  = {
                        { 0.463, 0.739 },
                        { 0.464, 0.878 },
                        { 0.534, 0.878 },
                        { 0.590, 0.859 },
                        { 0.665, 0.880 },
                        { 0.736, 0.880 },
                        { 0.736, 0.549 },
                    },
                },
            },
        },
    },
}
