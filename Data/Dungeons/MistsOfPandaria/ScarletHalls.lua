-------------------------------------------------------------------------------
-- RetroRuns Data -- Scarlet Halls
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 1001  |  journalInstanceID: 311
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[311] = {
    kind              = "dungeon",
    instanceID        = 1001,
    journalInstanceID = 311,
    name              = "Scarlet Halls",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",

    entrance = {
        mapID = 19,
        x     = 0.7900,
        y     = 0.6010,
    },

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    -- Appearances that drop only in the pre-Mists wings of this
    -- monastery, reachable again through the Old Keyring. They are
    -- listed here because this is the instance a player browses;
    -- the note under the block says how to get in.
    legacyLabel = "Scarlet Monastery of Old",
    legacyNote  = {
        text   = "SM of Old is accessed with {item}, which can either be found in {item2} or purchased from the Auction House. Once you have the key, turn it in at ^Old Keyring^ to obtain a buff that activates the (4) legacy SM instances. Disable the buff by interacting with the keyring again.",
        emphasis = "SM of Old",
        itemID  = 208485,
        itemID2 = 209024,
        travel = {
            mapID = 19,
            x     = 0.4830,
            y     = 0.5630,
            vendorName = "Old Keyring",
            zoneSub = "The Grand Vestibule",
        },
    },
    legacyLoot = {
        { id = 7711, slot = "Chest", name = "Robe of Doan", sources = { [14]=2923 }, bossNpc = "Arcanist Doan", legacyWing = "Library" },
        { id = 7756, slot = "Hands", name = "Dog Training Gloves", sources = { [14]=2950 }, bossNpc = "Houndmaster Loksey", legacyWing = "Library" },
        { id = 7719, slot = "Head", name = "Raging Berserker's Helm", sources = { [14]=2929 }, bossNpc = "Herod", legacyWing = "Armory" },
        { id = 10330, slot = "Legs", name = "Scarlet Leggings", sources = { [14]=3915 }, bossNpc = "Herod", legacyWing = "Armory" },
        { id = 7718, slot = "Shoulder", name = "Herod's Shoulder", sources = { [14]=2928 }, bossNpc = "Herod", legacyWing = "Armory" },
        { id = 7712, slot = "Shoulder", name = "Mantle of Doan", sources = { [14]=2924 }, bossNpc = "Arcanist Doan", legacyWing = "Library" },
        { id = 23192, slot = "Tabard", name = "Tabard of the Scarlet Crusade", sources = { [14]=9122 }, bind = "BoP", tag = "Scarlet Trainee", legacyWing = "Armory" },
        { id = 7713, slot = "Two-Hand", name = "Illusionary Rod", sources = { [14]=2925 }, bossNpc = "Arcanist Doan", legacyWing = "Library" },
        { id = 7710, slot = "Two-Hand", name = "Loksey's Training Stick", sources = { [14]=2922 }, bossNpc = "Houndmaster Loksey", legacyWing = "Library" },
        { id = 7717, slot = "Two-Hand", name = "Ravager", sources = { [14]=2927 }, bossNpc = "Herod", legacyWing = "Armory" },
        { id = 7714, slot = "Weapon", name = "Hypnotic Blade", sources = { [14]=2926 }, bossNpc = "Arcanist Doan", legacyWing = "Library" },
        { id = 10332, slot = "Feet", name = "Scarlet Boots", sources = { [14]=3917 }, bind = "BoE", legacyWing = "Library" },
        { id = 10329, slot = "Waist", name = "Scarlet Belt", sources = { [14]=3914 }, bind = "BoE", legacyWing = "Armory" },
        { id = 10332, slot = "Feet", name = "Scarlet Boots", sources = { [14]=3917 }, bind = "BoE", legacyWing = "Armory" },
        { id = 10333, slot = "Wrist", name = "Scarlet Wristguards", sources = { [14]=3918 }, bind = "BoE", legacyWing = "Armory" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Houndmaster Braun",
            journalEncounterID = 660,
            dungeonEncounterID = 1422,
            achievements       = {
                { id = 6684, name = "Humane Society", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 88268, slot = "Chest", name = "Canine Commander's Breastplate", sources = { [14]=45670, [15]=84301 } },
                { id = 88266, slot = "Hands", name = "Hound Trainer's Gloves", sources = { [14]=45668, [15]=84460 } },
                { id = 88264, slot = "Ranged", name = "Houndmaster's Compound Crossbow", sources = { [14]=45667, [15]=84458 } },
                { id = 88267, slot = "Wrist", name = "Commanding Bracers", sources = { [14]=45669, [15]=84459 } },
            },
        },
        {
            index              = 2,
            name               = "Armsmaster Harlan",
            journalEncounterID = 654,
            dungeonEncounterID = 1421,
            achievements       = {
                { id = 6427, name = "Mosh Pit", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 132550, slot = "Feet", name = "Scarlet Chain Footpads", sources = { [14]=76385 } },
                { id = 88269, slot = "Feet", name = "Scarlet Sandals", sources = { [14]=45671, [15]=84342 } },
                { id = 88271, slot = "Shoulder", name = "Harlan's Shoulders", sources = { [14]=45673, [15]=84341 } },
                { id = 88272, slot = "Two-Hand", name = "The Gleaming Ravager", sources = { [14]=45674, [15]=84461 } },
                { id = 88270, slot = "Wrist", name = "Lightblade Bracer", sources = { [14]=45672, [15]=84462 } },
            },
        },
        {
            index              = 3,
            name               = "Flameweaver Koegler",
            journalEncounterID = 656,
            dungeonEncounterID = 1420,
            achievements       = {
            },
            loot = {
                { id = 88279, slot = "Chest", name = "Robes of Koegler", sources = { [14]=45679, [15]=84344 } },
                { id = 88282, slot = "Hands", name = "Vellum-Ripper Gloves", sources = { [14]=45681, [15]=84467 } },
                { id = 88283, slot = "Legs", name = "Bradbury's Entropic Legguards", sources = { [14]=45682, [15]=84345 } },
                { id = 88277, slot = "Legs", name = "Pyretic Legguards", sources = { [14]=45677, [15]=84343 } },
                { id = 88278, slot = "Two-Hand", name = "Mograine's Immaculate Might", sources = { [14]=45678, [15]=84464 } },
                { id = 88276, slot = "Waist", name = "Bindburner Belt", sources = { [14]=45676, [15]=84465 } },
                { id = 88274, slot = "Weapon", name = "Koegler's Ritual Knife", sources = { [14]=45675, [15]=84463 } },
                { id = 88280, slot = "Weapon", name = "Melted Hypnotic Blade", sources = { [14]=45680, [15]=84466 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Houndmaster Braun (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Houndmaster Braun",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 431 },
                    kind    = "path",
                    note    = "After zoning in, follow the path to the ^Training Grounds^. Pick up a ^Reinforced Archery Target^ to act as a shield as you make your way to the enemies at the other end. Continue into the next room to find ^Houndmaster Braun^.",
                    minNote = "Ahead to Houndmaster",
                    points  = {
                        { 0.362, 0.847 },
                        { 0.440, 0.848 },
                        { 0.438, 0.809 },
                        { 0.479, 0.807 },
                        { 0.485, 0.567 },
                        { 0.495, 0.496 },
                        { 0.494, 0.363 },
                        { 0.534, 0.364 },
                        { 0.535, 0.330 },
                    },
                },
            },
        },
        -- 2. Armsmaster Harlan (boss 2). Two segments: north out of the
        -- cloister on 431, then through the armory on 432.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Armsmaster Harlan",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 431 },
                    kind    = "path",
                    note    = "After defeating ^Houndmaster Braun^, continue north into the next area.",
                    minNote = "North to next area",
                    points  = {
                        { 0.554, 0.251 },
                        { 0.554, 0.204 },
                        { 0.554, 0.137 },
                    },
                },
                {
                    when    = { mapID = 432 },
                    kind    = "path",
                    note    = "Follow the path through the armory until you reach ^Armsmaster Harlan^.",
                    minNote = "Follow path to Harlan",
                    points  = {
                        { 0.476, 0.903 },
                        { 0.496, 0.880 },
                        { 0.523, 0.876 },
                        { 0.524, 0.800 },
                        { 0.572, 0.801 },
                        { 0.572, 0.724 },
                        { 0.616, 0.720 },
                        { 0.619, 0.493 },
                    },
                },
            },
        },
        -- 3. Flameweaver Koegler (boss 3), back through the hallway and north.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Flameweaver Koegler",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 432 },
                    kind    = "path",
                    note    = "After killing ^Armsmaster Harlan^, backtrack into the main hallway and make your way north until you reach ^Flameweaver Koegler^.",
                    minNote = "North to Koegler",
                    points  = {
                        { 0.615, 0.391 },
                        { 0.592, 0.403 },
                        { 0.579, 0.431 },
                        { 0.577, 0.466 },
                        { 0.592, 0.497 },
                        { 0.617, 0.517 },
                        { 0.619, 0.574 },
                        { 0.485, 0.576 },
                        { 0.485, 0.506 },
                        { 0.393, 0.503 },
                        { 0.392, 0.195 },
                    },
                },
            },
        },
    },
}
