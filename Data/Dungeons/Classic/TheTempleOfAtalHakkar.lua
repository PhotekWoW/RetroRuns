-------------------------------------------------------------------------------
-- RetroRuns Data -- The Temple of Atal'hakkar
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 109  |  journalInstanceID: 237
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[237] = {
    kind              = "dungeon",
    instanceID        = 109,
    journalInstanceID = 237,
    name              = "The Temple of Atal'hakkar",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 51,
        x     = 0.7610,
        y     = 0.4524,
    },

    trashLoot = {
        { id = 10629, slot = "Feet", name = "Mistwalker Boots", sources = { [14]=4021 }, bind = "BoE" },
        { id = 10631, slot = "Hands", name = "Murkwater Gauntlets", sources = { [14]=4023 }, bind = "BoE" },
        { id = 10630, slot = "Head", name = "Soulcatcher Halo", sources = { [14]=4022 }, bind = "BoE" },
        { id = 10633, slot = "Legs", name = "Silvershell Leggings", sources = { [14]=4025 }, bind = "BoE" },
        { id = 10624, slot = "Ranged", name = "Stinging Bow", sources = { [14]=4016 }, bind = "BoE" },
        { id = 10627, slot = "Two-Hand", name = "Bludgeon of the Grinning Dog", sources = { [14]=4019 }, bind = "BoE" },
        { id = 10628, slot = "Two-Hand", name = "Deathblow", sources = { [14]=4020 }, bind = "BoE" },
        { id = 10626, slot = "Two-Hand", name = "Ragehammer", sources = { [14]=4018 }, bind = "BoE" },
        { id = 10625, slot = "Weapon", name = "Stealthblade", sources = { [14]=4017 }, bind = "BoE" },
        { id = 10623, slot = "Weapon", name = "Winter's Bite", sources = { [14]=4015 }, bind = "BoE" },
        { id = 10632, slot = "Wrist", name = "Slimescale Bracers", sources = { [14]=4024 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Avatar of Hakkar",
            journalEncounterID = 457,
            dungeonEncounterID = 492,
            achievements       = {
            },
            loot = {
                { id = 10843, slot = "Back", name = "Featherskin Cape", sources = { [14]=4119 } },
                { id = 12462, slot = "Chest", name = "Embrace of the Wind Serpent", sources = { [14]=4435 } },
                { id = 10845, slot = "Chest", name = "Warrior's Embrace", sources = { [14]=4121 } },
                { id = 10846, slot = "Feet", name = "Bloodshot Greaves", sources = { [14]=4122 } },
                { id = 10842, slot = "Legs", name = "Windscale Sarong", sources = { [14]=4118 } },
                { id = 10844, slot = "Two-Hand", name = "Spire of Hakkar", sources = { [14]=4120 } },
                { id = 10838, slot = "Weapon", name = "Might of Hakkar", sources = { [14]=4117 } },
            },
        },
        {
            index              = 2,
            name               = "Jammal'an the Prophet",
            journalEncounterID = 458,
            dungeonEncounterID = 488,
            achievements       = {
            },
            loot = {
                { id = 12465, slot = "Back", name = "Nightfall Drape", sources = { [14]=4438 } },
                { id = 10806, slot = "Chest", name = "Vestments of the Atal'ai Prophet", sources = { [14]=4103 } },
                { id = 10808, slot = "Hands", name = "Gloves of the Atal'ai Prophet", sources = { [14]=4105 } },
                { id = 10807, slot = "Legs", name = "Kilt of the Atal'ai Prophet", sources = { [14]=4104 } },
                { id = 10803, slot = "Weapon", name = "Blade of the Wretched", sources = { [14]=4100 } },
                { id = 10805, slot = "Weapon", name = "Eater of the Dead", sources = { [14]=4102 } },
                { id = 10804, slot = "Weapon", name = "Fist of the Damned", sources = { [14]=4101 } },
            },
        },
        {
            index              = 3,
            name               = "Wardens of the Dream",
            journalEncounterID = 459,
            -- One journal entry, four real encounters: each dragon fires
            -- its own ENCOUNTER_END and the EJ map carries none of them.
            -- IDs observed live at bring-up (Weaver, Dreamscythe, Morphaz,
            -- Hazzas).
            dungeonEncounterIDs = { 486, 487, 490, 491 },
            achievements       = {
            },
            loot = {
                { id = 12464, slot = "Hands", name = "Bloodfire Talons", sources = { [14]=4437 } },
                { id = 10796, slot = "Off-hand", name = "Drakestone", sources = { [14]=4093 } },
                { id = 12463, slot = "Two-Hand", name = "Drakefang Butcher", sources = { [14]=4436 } },
                { id = 12243, slot = "Two-Hand", name = "Smoldering Claw", sources = { [14]=4368 } },
                { id = 12466, slot = "Waist", name = "Dawnspire Cord", sources = { [14]=4439 } },
                { id = 10797, slot = "Weapon", name = "Firebreather", sources = { [14]=4094 } },
            },
        },
        {
            index              = 4,
            name               = "Shade of Eranikus",
            journalEncounterID = 463,
            dungeonEncounterID = 493,
            achievements       = {
            },
            loot = {
                { id = 10833, slot = "Head", name = "Horns of Eranikus", sources = { [14]=4113 } },
                { id = 10835, slot = "Off-hand", name = "Crest of Supremacy", sources = { [14]=4114 } },
                { id = 10836, slot = "Ranged", name = "Rod of Corrosion", sources = { [14]=4115 } },
                { id = 10828, slot = "Weapon", name = "Dire Nail", sources = { [14]=4112 } },
                { id = 10847, slot = "Weapon", name = "Dragon's Call", sources = { [14]=4123 } },
                { id = 10837, slot = "Weapon", name = "Tooth of Eranikus", sources = { [14]=4116 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Avatar of Hakkar (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Avatar of Hakkar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 220, subZone = "The Temple of Atal'Hakkar" },
                    kind    = "path",
                    note    = "After zoning in, take a right and make your way to ^Avatar of Hakkar^. Interact with the ^Shrine of the Soulflayer^ to summon the boss.",
                    minNote = "Go right to Avatar of Hakkar",
                    points  = {
                        { 0.500, 0.285 },
                        { 0.497, 0.319 },
                        { 0.454, 0.348 },
                        { 0.417, 0.386 },
                        { 0.296, 0.279 },
                        { 0.242, 0.279 },
                        { 0.239, 0.421 },
                    },
                },
                {
                    when        = { mapID = 220, subZone = "Sanctum of the Fallen God" },
                    kind        = "poi",
                    mapLabel    = "Click Shrine",
                    mapLabelPos = "lower-right",
                    points      = {
                        { 0.269, 0.453 },
                    },
                },
            },
        },

        -- 2. Jammal'an the Prophet (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Jammal'an the Prophet",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 220 },
                    kind    = "path",
                    note    = "After defeating ^Avatar of Hakkar^, travel east to the far opposite side of the instance to find ^Jammal'an the Prophet^.",
                    minNote = "East to Jammal'an",
                    points  = {
                        { 0.239, 0.527 },
                        { 0.242, 0.647 },
                        { 0.299, 0.631 },
                        { 0.415, 0.535 },
                        { 0.589, 0.533 },
                        { 0.723, 0.643 },
                        { 0.757, 0.643 },
                        { 0.761, 0.501 },
                    },
                },
            },
        },

        -- 3. Wardens of the Dream (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Wardens of the Dream",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 220 },
                    kind    = "path",
                    note    = "After killing ^Jammal'an^, backtrack to the main area and kill two of the wardens. A little further south, you will find the remaining two ^Wardens of the Dream^.",
                    minNote = "South path to Wardens",
                    points  = {
                        { 0.764, 0.560 },
                        { 0.761, 0.642 },
                        { 0.708, 0.639 },
                        { 0.588, 0.533 },
                        { 0.501, 0.603 },
                        { 0.496, 0.836 },
                    },
                },
            },
        },

        -- 4. Shade of Eranikus (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Shade of Eranikus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 220 },
                    kind    = "path",
                    note    = "After defeating all of the ^Wardens of the Dream^, continue east to find ^Shade of Eranikus^.",
                    minNote = "East to Eranikus",
                    points  = {
                        { 0.537, 0.875 },
                        { 0.647, 0.877 },
                    },
                },
            },
        },
    },
}
