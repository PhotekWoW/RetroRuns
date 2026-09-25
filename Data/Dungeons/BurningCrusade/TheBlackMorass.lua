-------------------------------------------------------------------------------
-- RetroRuns Data -- The Black Morass
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 269  |  journalInstanceID: 255
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[255] = {
    kind              = "dungeon",
    instanceID        = 269,
    journalInstanceID = 255,
    name              = "The Black Morass",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.2.0",

    entrance = {
        mapID = 75,
        x     = 0.3580,
        y     = 0.8420,
    },

    bosses = {
        {
            index              = 1,
            name               = "Chrono Lord Deja",
            journalEncounterID = 552,
            dungeonEncounterID = 1920,
            achievements       = {
            },
            loot = {
                { id = 27988, slot = "Back", name = "Burnoose of Shifting Ages", sources = { [14]=12197, [15]=12197 } },
                { id = 27993, slot = "Head", name = "Mask of Inner Fire", sources = { [14]=12198, [15]=12198 } },
                { id = 27977, slot = "Legs", name = "Legplates of the Bold", sources = { [14]=12191, [15]=12191 }, setName = "Bold Armor", dungeonSet = 3 },
                { id = 27873, slot = "Legs", name = "Moonglade Pants", sources = { [14]=12118, [15]=12118 } },
                { id = 27987, slot = "Ranged", name = "Melmorta's Twilight Longbow", sources = { [14]=12196, [15]=12196 } },
                { id = 27994, slot = "Shoulder", name = "Mantle of Three Terrors", sources = { [14]=12199, [15]=12199 } },
                { id = 27995, slot = "Shoulder", name = "Sun-Gilded Shouldercaps", sources = { [14]=12200, [15]=12200 } },
            },
        },
        {
            index              = 2,
            name               = "Temporus",
            journalEncounterID = 553,
            dungeonEncounterID = 1921,
            achievements       = {
            },
            loot = {
                { id = 28186, slot = "Chest", name = "Laughing Skull Battle-Harness", sources = { [14]=12309, [15]=12309 } },
                { id = 27509, slot = "Hands", name = "Handgrips of Assassination", sources = { [14]=11943, [15]=11943 }, setName = "Assassination Armor", dungeonSet = 3 },
                { id = 28185, slot = "Legs", name = "Khadgar's Kilt of Abjuration", sources = { [14]=12308, [15]=12308 } },
                { id = 28187, slot = "Off-hand", name = "Star-Heart Lamp", sources = { [14]=12310, [15]=12310 } },
                { id = 28033, slot = "Two-Hand", name = "Epoch-Mender", sources = { [14]=12230, [15]=12230 } },
                { id = 29356, slot = "Two-Hand", name = "Quantum Blade", sources = { [14]=13100, [15]=13100 } },
                { id = 28184, slot = "Weapon", name = "Millennium Blade", sources = { [14]=12307, [15]=12307 } },
            },
        },
        {
            index              = 3,
            name               = "Aeonus",
            journalEncounterID = 554,
            dungeonEncounterID = 1919,
            achievements       = {
            },
            loot = {
                { id = 28206, slot = "Head", name = "Cowl of the Guiltless", sources = { [14]=12328, [15]=12328 } },
                { id = 28192, slot = "Head", name = "Helm of Desolation", sources = { [14]=12314, [15]=12314 }, setName = "Desolation Battlegear", dungeonSet = 3 },
                { id = 28193, slot = "Head", name = "Mana-Etched Crown", sources = { [14]=12315, [15]=12315 } },
                { id = 30531, slot = "Legs", name = "Breeches of the Occultist", sources = { [14]=13804, [15]=13804 } },
                { id = 27839, slot = "Legs", name = "Legplates of the Righteous", sources = { [14]=12098, [15]=12098 }, setName = "Righteous Armor", dungeonSet = 3 },
                { id = 28207, slot = "Shoulder", name = "Pauldrons of the Crimson Flight", sources = { [14]=12329, [15]=12329 } },
                { id = 28188, slot = "Two-Hand", name = "Bloodfire Greatstaff", sources = { [14]=12311, [15]=12311 } },
                { id = 29253, slot = "Waist", name = "Girdle of Valorous Deeds", sources = { [14]=13048, [15]=13048 } },
                { id = 29247, slot = "Waist", name = "Girdle of the Deathdealer", sources = { [14]=13042, [15]=13042 } },
                { id = 28189, slot = "Weapon", name = "Latro's Shifting Sword", sources = { [14]=12312, [15]=12312 } },
                { id = 28194, slot = "Wrist", name = "Primal Surge Bracers", sources = { [14]=12316, [15]=12316 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Chrono Lord Deja (boss 1). Medivh starts the event; the
        -- portals run on their own clock and the sixth brings the boss.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Chrono Lord Deja",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 273 },
                    kind            = "poi",
                    note            = "After zoning in, ignore ^Sa'at^ and head south to find ^Medivh^ channeling a large waygate. Approach him to begin the portal sequence.",
                    minNote         = "Approach Medivh to begin",
                    mapLabel        = "Approach Medivh",
                    mapLabelPos     = "above",
                    poiSize         = 18,
                    completionCheck = true,
                    points          = {
                        { 0.487, 0.733 },
                    },
                },
                {
                    when        = { mapID = 273 },
                    kind        = "path",
                    note        = "Portals spawn at random around the area. Clear portals 1-6 to spawn ^Chrono Lord Deja^.",
                    minNote     = "Clear portals 1-6 for Deja",
                    triggeredBy = { dialog = { npc = "Medivh", match = "order your warlocks" } },
                    points      = { },
                },
            },
        },
        -- 2. Temporus (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Temporus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 273 },
                    kind    = "path",
                    note    = "Clear portals 7-12 to spawn ^Temporus^.",
                    minNote = "Clear portals 7-12 for Temporus",
                    points  = { },
                },
            },
        },
        -- 3. Aeonus (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Aeonus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 273 },
                    kind    = "path",
                    note    = "Clear portals 13-18 to spawn the final boss, ^Aeonus^.",
                    minNote = "Clear portals 13-18 for Aeonus",
                    points  = { },
                },
            },
        },
    },
}
