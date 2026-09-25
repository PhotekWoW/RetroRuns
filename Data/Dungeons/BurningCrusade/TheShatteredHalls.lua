-------------------------------------------------------------------------------
-- RetroRuns Data -- The Shattered Halls
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 540  |  journalInstanceID: 259
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[259] = {
    kind              = "dungeon",
    instanceID        = 540,
    journalInstanceID = 259,
    name              = "The Shattered Halls",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "2.0.3",
    routedIn          = "3.2.0",
    timewalking       = true,

    entrance = {
        mapID = 100,
        x     = 0.4740,
        y     = 0.5202,
    },

    bosses = {
        {
            index              = 1,
            name               = "Grand Warlock Nethekurse",
            journalEncounterID = 566,
            dungeonEncounterID = 1936,
            achievements       = {
            },
            loot = {
                { id = 27519, slot = "Back", name = "Cloak of Malice", sources = { [14]=11950, [15]=11950 }, twSource = 69441 },
                { id = 27520, slot = "Head", name = "Greathelm of the Unbreakable", sources = { [14]=11951, [15]=11951 }, twSource = 69442 },
                { id = 27534, slot = "Off-hand", name = "Hortus' Seal of Brilliance", sources = { [14]=11962, [15]=11962 }, twSource = 69452 },
                { id = 27521, slot = "Waist", name = "Telaari Hunting Girdle", sources = { [14]=11952, [15]=11952 }, twSource = 69443 },
                { id = 27517, slot = "Wrist", name = "Bands of Nethekurse", sources = { [14]=11949, [15]=11949 }, twSource = 69440 },
            },
        },
        {
            index              = 2,
            name               = "Blood Guard Porung",
            journalEncounterID = 728,
            dungeonEncounterID = 1935,
            availableDifficulties = { 15, 24 },
            achievements       = {
            },
            loot = {
                { id = 30707, slot = "Feet", name = "Nimble-Foot Treads", sources = { [15]=13860 }, twSource = 69461 },
                { id = 27474, slot = "Hands", name = "Beast Lord Handguards", sources = { [15]=11922 }, setName = "Beast Lord Armor", dungeonSet = 3 },
                { id = 27536, slot = "Hands", name = "Hallowed Handwraps", sources = { [15]=11964 }, twSource = 69454, setName = "Hallowed Raiment", dungeonSet = 3 },
                { id = 30709, slot = "Legs", name = "Pantaloons of Flaming Wrath", sources = { [15]=13862 }, twSource = 69463 },
                { id = 124000, slot = "Shoulder", name = "Justice Bearer's Pauldrons", sources = { [24]=69457 } },
                { id = 30705, slot = "Shoulder", name = "Spaulders of Slaughter", sources = { [15]=13859 }, twSource = 69460 },
                { id = 30708, slot = "Waist", name = "Belt of Flowing Thought", sources = { [15]=13861 }, twSource = 69462 },
            },
        },
        {
            index              = 3,
            name               = "Warbringer O'mrogg",
            journalEncounterID = 568,
            dungeonEncounterID = 1937,
            achievements       = {
            },
            loot = {
                { id = 29254, slot = "Feet", name = "Boots of the Righteous Path", sources = { [14]=13049, [15]=13049 }, twSource = 69465 },
                { id = 27525, slot = "Feet", name = "Jeweled Boots of Sanctification", sources = { [14]=11955, [15]=11955 }, twSource = 69446 },
                { id = 27526, slot = "Ranged", name = "Skyfire Hawk-Bow", sources = { [14]=11956, [15]=11956 }, twSource = 69447 },
                { id = 27524, slot = "Two-Hand", name = "Firemaul of Destruction", sources = { [14]=11954, [15]=11954 }, twSource = 69445 },
                { id = 27868, slot = "Weapon", name = "Runesong Dagger", sources = { [14]=12115, [15]=12115 }, twSource = 69459 },
                { id = 29263, slot = "Wrist", name = "Forestheart Bracers", sources = { [14]=13056, [15]=13056 }, twSource = 69467 },
                { id = 27522, slot = "Wrist", name = "World's End Bracers", sources = { [14]=11953, [15]=11953 }, twSource = 69444 },
            },
        },
        {
            index              = 4,
            name               = "Warchief Kargath Bladefist",
            journalEncounterID = 569,
            dungeonEncounterID = 1938,
            achievements       = {
            },
            loot = {
                { id = 27528, slot = "Hands", name = "Gauntlets of Desolation", sources = { [14]=11958, [15]=11958 }, twSource = 69449, setName = "Desolation Battlegear", dungeonSet = 3 },
                { id = 27535, slot = "Hands", name = "Gauntlets of the Righteous", sources = { [14]=11963, [15]=11963 }, twSource = 69453, setName = "Righteous Armor", dungeonSet = 3 },
                { id = 27537, slot = "Hands", name = "Gloves of Oblivion", sources = { [14]=11965, [15]=11965 }, twSource = 69455, setName = "Oblivion Raiment", dungeonSet = 3 },
                { id = 27531, slot = "Hands", name = "Wastewalker Gloves", sources = { [14]=11960, [15]=11960 }, twSource = 69450, setName = "Wastewalker Armor", dungeonSet = 3 },
                { id = 27527, slot = "Legs", name = "Greaves of the Shatterer", sources = { [14]=11957, [15]=11957 }, twSource = 69448 },
                { id = 27540, slot = "Ranged", name = "Nexus Torch", sources = { [14]=11968, [15]=11968 }, twSource = 69458 },
                { id = 27802, slot = "Shoulder", name = "Tidefury Shoulderguards", sources = { [14]=12077, [15]=12077 }, setName = "Tidefury Raiment", dungeonSet = 3 },
                { id = 27533, slot = "Weapon", name = "Demonblood Eviscerator", sources = { [14]=11961, [15]=11961 }, twSource = 69451 },
                { id = 27538, slot = "Weapon", name = "Lightsworn Hammer", sources = { [14]=11966, [15]=11966 }, twSource = 69456 },
                { id = 29348, slot = "Weapon", name = "The Bladefist", sources = { [14]=13094, [15]=13094 }, twSource = 69468 },
                { id = 29255, slot = "Wrist", name = "Bands of Rarefied Magic", sources = { [14]=13050, [15]=13050 }, twSource = 69466 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Grand Warlock Nethekurse (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Grand Warlock Nethekurse",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 246 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path leading through ^The Sewer^ and landing at ^Grand Warlock Nethekurse^. Rogues can save a few seconds by unlocking the door before the sewer.",
                    minNote = "Follow the path to Nethekurse",
                    points  = {
                        { 0.592, 0.880 },
                        { 0.592, 0.785 },
                        { 0.576, 0.773 },
                        { 0.343, 0.775 },
                        { 0.343, 0.694 },
                        { 0.397, 0.694 },
                        { 0.437, 0.635 },
                        { 0.416, 0.620 },
                        { 0.393, 0.615 },
                        { 0.356, 0.619 },
                    },
                },
            },
        },
        -- 2. Blood Guard Porung (boss 2, Heroic only)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Blood Guard Porung",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 246 },
                    kind    = "path",
                    note    = "Follow the linear path north to find ^Blood Guard Porung^ at the end of the gauntlet.",
                    minNote = "North to Porung",
                    points  = {
                        { 0.341, 0.553 },
                        { 0.341, 0.526 },
                        { 0.325, 0.509 },
                        { 0.296, 0.510 },
                        { 0.295, 0.185 },
                    },
                },
            },
        },
        -- 3. Warbringer O'mrogg (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Warbringer O'mrogg",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 246 },
                    kind    = "path",
                    note    = "Continue following the linear path north to eventually reach ^Warbringer O'mrogg^.",
                    minNote = "Follow path to O'mrogg",
                    points  = {
                        { 0.342, 0.554 },
                        { 0.342, 0.524 },
                        { 0.325, 0.510 },
                        { 0.296, 0.510 },
                        { 0.296, 0.139 },
                        { 0.522, 0.137 },
                        { 0.539, 0.160 },
                        { 0.540, 0.309 },
                    },
                },
            },
        },
        -- 4. Warchief Kargath Bladefist (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Warchief Kargath Bladefist",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 246 },
                    kind    = "path",
                    note    = "After defeating ^Warbringer O'mrogg^, follow the linear path east until you reach ^Warchief Kargath^.",
                    minNote = "East path to Warchief Kargath",
                    points  = {
                        { 0.582, 0.343 },
                        { 0.659, 0.342 },
                        { 0.672, 0.359 },
                        { 0.672, 0.512 },
                    },
                },
            },
        },
    },
}
