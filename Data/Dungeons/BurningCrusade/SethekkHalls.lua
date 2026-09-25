-------------------------------------------------------------------------------
-- RetroRuns Data -- Sethekk Halls
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 556  |  journalInstanceID: 252
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[252] = {
    kind              = "dungeon",
    instanceID        = 556,
    journalInstanceID = 252,
    name              = "Sethekk Halls",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.2.0",

    entrance = {
        mapID = 108,
        x     = 0.4506,
        y     = 0.6562,
    },

    bosses = {
        {
            index              = 1,
            name               = "Darkweaver Syth",
            journalEncounterID = 541,
            dungeonEncounterID = 1903,
            achievements       = {
            },
            loot = {
                { id = 27919, slot = "Feet", name = "Light-Woven Slippers", sources = { [14]=12156, [15]=12156 } },
                { id = 27914, slot = "Feet", name = "Moonstrider Boots", sources = { [14]=12152, [15]=12152 } },
                { id = 27915, slot = "Feet", name = "Sky-Hunter Swift Boots", sources = { [14]=12153, [15]=12153 } },
                { id = 27918, slot = "Wrist", name = "Bands of Syth", sources = { [14]=12155, [15]=12155 } },
            },
        },
        {
            index              = 2,
            name               = "Anzu",
            journalEncounterID = 542,
            dungeonEncounterID = 1904,
            availableDifficulties = { 15 },
            achievements       = {
            },
            loot = {
                { id = 32778, slot = "Feet", name = "Boots of Righteous Fortitude", sources = { [15]=15089 } },
                { id = 27936, slot = "Legs", name = "Greaves of Desolation", sources = { [15]=12162 }, setName = "Desolation Battlegear", dungeonSet = 3 },
                { id = 32780, slot = "Ranged", name = "The Boomstick", sources = { [15]=15090 } },
                { id = 32769, slot = "Waist", name = "Belt of the Raven Lord", sources = { [15]=15087 } },
                { id = 32781, slot = "Weapon", name = "Talon of Anzu", sources = { [15]=15091 } },
            },
            specialLoot = {
                { id = 32768, kind = "mount", name = "Reins of the Raven Lord", heroicOnly = true },
            },
        },
        {
            index              = 3,
            name               = "Talon King Ikiss",
            journalEncounterID = 543,
            dungeonEncounterID = 1902,
            achievements       = {
            },
            loot = {
                { id = 27946, slot = "Back", name = "Avian Cloak of Feathers", sources = { [14]=12167, [15]=12167 } },
                { id = 27981, slot = "Back", name = "Sethekk Oracle Cloak", sources = { [14]=12193, [15]=12193 } },
                { id = 27875, slot = "Legs", name = "Hallowed Trousers", sources = { [14]=12120, [15]=12120 }, setName = "Hallowed Raiment", dungeonSet = 3 },
                { id = 27838, slot = "Legs", name = "Incanter's Trousers", sources = { [14]=12097, [15]=12097 }, setName = "Incanter's Regalia", dungeonSet = 3 },
                { id = 27948, slot = "Legs", name = "Trousers of Oblivion", sources = { [14]=12168, [15]=12168 }, setName = "Oblivion Raiment", dungeonSet = 3 },
                { id = 27776, slot = "Shoulder", name = "Shoulderpads of Assassination", sources = { [14]=12059, [15]=12059 }, setName = "Assassination Armor", dungeonSet = 3 },
                { id = 32073, slot = "Shoulder", name = "Spaulders of Dementia", sources = { [14]=14750, [15]=14750 } },
                { id = 27986, slot = "Two-Hand", name = "Crow Wing Reaper", sources = { [14]=12195, [15]=12195 } },
                { id = 29355, slot = "Two-Hand", name = "Terokk's Shadowstaff", sources = { [14]=13099, [15]=13099 } },
                { id = 27985, slot = "Waist", name = "Deathforge Girdle", sources = { [14]=12194, [15]=12194 } },
                { id = 27980, slot = "Weapon", name = "Terokk's Nightmace", sources = { [14]=12192, [15]=12192 } },
                { id = 29249, slot = "Wrist", name = "Bands of the Benevolent", sources = { [14]=13044, [15]=13044 } },
                { id = 29259, slot = "Wrist", name = "Bracers of the Hunt", sources = { [14]=13053, [15]=13053 } },
            },
        },
    },

    exitNote    = "Go east from Ikiss for a shortcut to the exit",
    minExitNote = "East path for shortcut to exit",

    routing = {
        -- 1. Darkweaver Syth (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Darkweaver Syth",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 258 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path until you reach ^Darkweaver Syth^.",
                    minNote = "Follow path to Darkweaver Syth",
                    points  = {
                        { 0.731, 0.339 },
                        { 0.731, 0.275 },
                        { 0.641, 0.276 },
                        { 0.590, 0.396 },
                        { 0.590, 0.521 },
                        { 0.486, 0.521 },
                        { 0.486, 0.644 },
                    },
                },
            },
        },
        -- 2. Anzu (boss 2, Heroic only)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Anzu",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 258 },
                    kind    = "path",
                    note    = "After killing ^Darkweaver Syth^, continue south up the stairs.",
                    minNote = "South to stairs",
                    points  = {
                        { 0.481, 0.715 },
                        { 0.481, 0.951 },
                        { 0.532, 0.950 },
                        { 0.532, 0.901 },
                    },
                },
                {
                    when    = { mapID = 259 },
                    kind    = "path",
                    note    = "At the top of the stairs, continue following the path until you reach ^Anzu^.",
                    minNote = "Follow path to Anzu",
                    points  = {
                        { 0.531, 0.884 },
                        { 0.531, 0.819 },
                        { 0.443, 0.819 },
                        { 0.443, 0.885 },
                        { 0.302, 0.885 },
                        { 0.261, 0.835 },
                        { 0.261, 0.787 },
                        { 0.327, 0.744 },
                        { 0.326, 0.579 },
                    },
                },
            },
        },
        -- 3. Talon King Ikiss (boss 3). One path for both difficulties: the
        -- Heroic player stands on it at Anzu's spot.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Talon King Ikiss",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 258 },
                    kind    = "path",
                    note    = "After killing ^Darkweaver Syth^, continue south up the stairs.",
                    minNote = "South to stairs",
                    points  = {
                        { 0.481, 0.715 },
                        { 0.481, 0.951 },
                        { 0.532, 0.950 },
                        { 0.532, 0.901 },
                    },
                },
                {
                    when    = { mapID = 259 },
                    kind    = "path",
                    note    = "Continue on the path until you reach ^Talon King Ikiss^.",
                    minNote = "Follow path to Talon King Ikiss",
                    points  = {
                        { 0.533, 0.920 },
                        { 0.533, 0.825 },
                        { 0.444, 0.825 },
                        { 0.444, 0.888 },
                        { 0.302, 0.889 },
                        { 0.255, 0.823 },
                        { 0.264, 0.776 },
                        { 0.325, 0.755 },
                        { 0.326, 0.311 },
                    },
                },
            },
        },
    },
}
