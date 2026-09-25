-------------------------------------------------------------------------------
-- RetroRuns Data -- Dire Maul - Gordok Commons
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.3  |  instanceID: 429  |  journalInstanceID: 1277
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1277] = {
    kind              = "dungeon",
    instanceID        = 429,
    journalInstanceID = 1277,
    name              = "Dire Maul - Gordok Commons",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.3",
    timewalking       = true,

    -- All three Dire Maul wings share instanceID 429, so the instance id
    -- alone cannot say which one the player entered. These are this wing's
    -- floors out of the six in UiMapGroupMember group 159 (235 Gordok
    -- Commons; 236/237/238 the west wing; 239/240 the east).
    uiMaps = { 235 },

    entrance = {
        mapID = 69,
        x     = 0.6250,
        y     = 0.2490,
    },

    bosses = {
        {
            index              = 1,
            name               = "Guard Mol'dar",
            journalEncounterID = 411,
            dungeonEncounterID = 362,
            -- The kill criterion says "Mol'dar defeated" without the Guard,
            -- so the prose matcher cannot see it; the id carries the mapping.
            scenarioCriteriaID = 25066,
            achievements       = {
            },
            loot = {
                { id = 18496, slot = "Back", name = "Heliotrope Cloak", sources = { [14]=7374 } },
                { id = 18450, slot = "Chest", name = "Robe of Combustion", sources = { [14]=7343 } },
                { id = 18460, slot = "Ranged", name = "Unsophisticated Hand Cannon", sources = { [14]=7353 } },
                { id = 18493, slot = "Shoulder", name = "Bulky Iron Spaulders", sources = { [14]=7371 } },
                { id = 18494, slot = "Shoulder", name = "Denwatcher's Shoulders", sources = { [14]=7372 } },
                { id = 18451, slot = "Waist", name = "Hyena Hide Belt", sources = { [14]=7344 } },
                { id = 18498, slot = "Weapon", name = "Hedgecutter", sources = { [14]=7376 } },
                { id = 18462, slot = "Weapon", name = "Jagged Bone Fist", sources = { [14]=7355 } },
                { id = 18463, slot = "Weapon", name = "Ogre Pocket Knife", sources = { [14]=7356 } },
                { id = 18497, slot = "Wrist", name = "Sublime Wristguards", sources = { [14]=7375 } },
            },
        },
        {
            index              = 2,
            name               = "Stomper Kreeg",
            journalEncounterID = 412,
            dungeonEncounterID = 363,
            achievements       = {
            },
            loot = {
                { id = 18425, slot = "Off-hand", name = "Kreeg's Mug", sources = { [14]=7328 } },
            },
        },
        {
            index              = 3,
            name               = "Guard Fengus",
            journalEncounterID = 413,
            dungeonEncounterID = 364,
            achievements       = {
            },
            loot = {
                { id = 18496, slot = "Back", name = "Heliotrope Cloak", sources = { [14]=7374 } },
                { id = 18450, slot = "Chest", name = "Robe of Combustion", sources = { [14]=7343 } },
                { id = 18460, slot = "Ranged", name = "Unsophisticated Hand Cannon", sources = { [14]=7353 } },
                { id = 18493, slot = "Shoulder", name = "Bulky Iron Spaulders", sources = { [14]=7371 } },
                { id = 18494, slot = "Shoulder", name = "Denwatcher's Shoulders", sources = { [14]=7372 } },
                { id = 18451, slot = "Waist", name = "Hyena Hide Belt", sources = { [14]=7344 } },
                { id = 18498, slot = "Weapon", name = "Hedgecutter", sources = { [14]=7376 } },
                { id = 18462, slot = "Weapon", name = "Jagged Bone Fist", sources = { [14]=7355 } },
                { id = 18463, slot = "Weapon", name = "Ogre Pocket Knife", sources = { [14]=7356 } },
                { id = 18497, slot = "Wrist", name = "Sublime Wristguards", sources = { [14]=7375 } },
            },
        },
        {
            index              = 4,
            name               = "Guard Slip'kik",
            journalEncounterID = 414,
            dungeonEncounterID = 365,
            achievements       = {
            },
            loot = {
                { id = 18496, slot = "Back", name = "Heliotrope Cloak", sources = { [14]=7374 } },
                { id = 18450, slot = "Chest", name = "Robe of Combustion", sources = { [14]=7343 } },
                { id = 18460, slot = "Ranged", name = "Unsophisticated Hand Cannon", sources = { [14]=7353 } },
                { id = 18493, slot = "Shoulder", name = "Bulky Iron Spaulders", sources = { [14]=7371 } },
                { id = 18494, slot = "Shoulder", name = "Denwatcher's Shoulders", sources = { [14]=7372 } },
                { id = 18451, slot = "Waist", name = "Hyena Hide Belt", sources = { [14]=7344 } },
                { id = 18498, slot = "Weapon", name = "Hedgecutter", sources = { [14]=7376 } },
                { id = 18462, slot = "Weapon", name = "Jagged Bone Fist", sources = { [14]=7355 } },
                { id = 18463, slot = "Weapon", name = "Ogre Pocket Knife", sources = { [14]=7356 } },
                { id = 18497, slot = "Wrist", name = "Sublime Wristguards", sources = { [14]=7375 } },
            },
        },
        {
            index              = 5,
            name               = "Captain Kromcrush",
            journalEncounterID = 415,
            dungeonEncounterID = 366,
            achievements       = {
            },
            loot = {
                { id = 18503, slot = "Chest", name = "Kromcrush's Chestplate", sources = { [14]=7379 } },
                { id = 18507, slot = "Feet", name = "Boots of the Full Moon", sources = { [14]=7383 } },
                { id = 18502, slot = "Two-Hand", name = "Monstrous Glaive", sources = { [14]=7378 } },
                { id = 18505, slot = "Waist", name = "Mugger's Belt", sources = { [14]=7381 } },
                { id = 18458, slot = "Wrist", name = "Modest Armguards", sources = { [14]=7351 } },
            },
        },
        {
            index              = 6,
            name               = "Cho'Rush the Observer",
            journalEncounterID = 416,
            dungeonEncounterID = 367,
            achievements       = {
            },
            loot = {
                { id = 18527, slot = "Hands", name = "Harmonious Gauntlets", sources = { [14]=7394 } },
                { id = 18490, slot = "Head", name = "Insightful Hood", sources = { [14]=7369 } },
                { id = 18485, slot = "Off-hand", name = "Observer's Shield", sources = { [14]=7367 } },
                { id = 18483, slot = "Ranged", name = "Mana Channeling Wand", sources = { [14]=7365 } },
                { id = 18484, slot = "Weapon", name = "Cho'Rush's Blade", sources = { [14]=7366 } },
                { id = 18459, slot = "Wrist", name = "Gallant's Wristguards", sources = { [14]=7352 } },
            },
        },
        {
            index              = 7,
            name               = "King Gordok",
            journalEncounterID = 417,
            dungeonEncounterID = 368,
            achievements       = {
            },
            loot = {
                { id = 18521, slot = "Feet", name = "Grimy Metal Boots", sources = { [14]=7389 } },
                { id = 18526, slot = "Head", name = "Crown of the Ogre King", sources = { [14]=7393 } },
                { id = 18524, slot = "Legs", name = "Leggings of Destruction", sources = { [14]=7391 } },
                { id = 18523, slot = "Off-hand", name = "Brightly Glowing Stone", sources = { [14]=7390 } },
                { id = 18520, slot = "Two-Hand", name = "Barbarous Blade", sources = { [14]=7388 } },
                { id = 18525, slot = "Wrist", name = "Bracers of Prosperity", sources = { [14]=7392 } },
                { id = 18495, slot = "Back", name = "Redoubt Cloak", sources = { [14]=7373 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18478, slot = "Chest", name = "Hyena Hide Jerkin", sources = { [14]=7360 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18532, slot = "Chest", name = "Mindsurge Robe", sources = { [14]=7399 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18530, slot = "Chest", name = "Ogre Forged Hauberk", sources = { [14]=7397 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18476, slot = "Feet", name = "Mud Stained Boots", sources = { [14]=7358 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18479, slot = "Head", name = "Carrion Scorpid Helm", sources = { [14]=7361 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18480, slot = "Head", name = "Scarab Plate Helm", sources = { [14]=7362 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18477, slot = "Legs", name = "Shaggy Leggings", sources = { [14]=7359 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18499, slot = "Off-hand", name = "Barrier Shield", sources = { [14]=7377 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18482, slot = "Ranged", name = "Ogre Toothpick Shooter", sources = { [14]=7364 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18528, slot = "Shoulder", name = "Cyclone Spaulders", sources = { [14]=7395 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18534, slot = "Two-Hand", name = "Rod of the Ogre Magi", sources = { [14]=7401 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18481, slot = "Two-Hand", name = "Skullcracking Mace", sources = { [14]=7363 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18538, slot = "Two-Hand", name = "Treant's Bane", sources = { [14]=7404 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18531, slot = "Two-Hand", name = "Unyielding Maul", sources = { [14]=7398 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18529, slot = "Waist", name = "Elemental Plate Girdle", sources = { [14]=7396 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18475, slot = "Waist", name = "Oddly Magical Belt", sources = { [14]=7357 }, bind = "BoP", tag = "Tribute Chest" },
                { id = 18533, slot = "Wrist", name = "Gordok Bracers of Power", sources = { [14]=7400 }, bind = "BoP", tag = "Tribute Chest" },
            },
            tagNote = "Tribute loot comes from the Gordok Tribute chest: defeat King Gordok while the wing's other bosses still live, then speak with Mizzle the Crafty to be crowned and claim the chest.",
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Guard Mol'dar (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Guard Mol'dar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "After zoning in, go down the ramp in front of you to engage ^Guard Mol'dar^.",
                    minNote = "Down ramp to Mol'dar",
                    points  = {
                        { 0.712, 0.893 },
                        { 0.695, 0.857 },
                        { 0.695, 0.797 },
                    },
                },
            },
        },
        -- 2. Stomper Kreeg (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Stomper Kreeg",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "After defeating ^Guard Mol'dar^, go up the ramp behind him and take a left. You will run into ^Stomper Kreeg^ very soon.",
                    minNote = "Up ramp to Stomper Kreeg",
                    points  = {
                        { 0.692, 0.723 },
                        { 0.693, 0.688 },
                        { 0.635, 0.688 },
                    },
                },
            },
        },
        -- 3. Guard Fengus (boss 3), who patrols.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Guard Fengus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "After killing ^Stomper Kreeg^, go up a series of ramps to the west and you will find ^Guard Fengus^ patrolling around.",
                    minNote = "Up ramps to Fengus",
                    points  = {
                        { 0.585, 0.711 },
                        { 0.565, 0.713 },
                        { 0.566, 0.779 },
                        { 0.520, 0.785 },
                    },
                },
            },
        },
        -- 4. Guard Slip'kik (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Guard Slip'kik",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "After defeating ^Guard Fengus^, go through the ^Gordok Courtyard Door^ to the west. Follow the path to find ^Guard Slip'kik^ patrolling underneath the platform above.",
                    minNote = "West to Guard Slip'kik",
                    points  = {
                        { 0.447, 0.781 },
                        { 0.313, 0.780 },
                        { 0.284, 0.763 },
                        { 0.268, 0.719 },
                        { 0.262, 0.607 },
                    },
                },
            },
        },
        -- 5. Captain Kromcrush (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Captain Kromcrush",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "After killing ^Guard Slip'kik^, go up the ramp at the southwest corner of the room. Follow the path around to a hallway where you will find ^Captain Kromcrush^.",
                    minNote = "Up ramp to Kromcrush",
                    points  = {
                        { 0.221, 0.615 },
                        { 0.220, 0.679 },
                        { 0.240, 0.679 },
                        { 0.242, 0.618 },
                        { 0.240, 0.533 },
                        { 0.284, 0.533 },
                        { 0.279, 0.656 },
                        { 0.317, 0.652 },
                        { 0.317, 0.543 },
                    },
                },
            },
        },
        -- 6. Cho'Rush the Observer (boss 6), who stands with King Gordok.
        -- Optional: killing the king first turns him friendly, so a route
        -- that required him could never complete. No skip prose by design --
        -- the two stand side by side, so a player past this step is already
        -- standing at the next one.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            optional  = true,
            -- Once the king falls the ogres turn friendly, so this skip
            -- cannot be walked back; only a reset offers him again.
            skipIrreversible = true,
            title     = "Cho'Rush the Observer",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "After defeating ^Captain Kromcrush^, proceed straight ahead to find ^Cho'Rush the Observer^ standing next to ^King Gordok^. Kill Cho'Rush first: once the king falls, the remaining ogres turn friendly and he can no longer be attacked.",
                    minNote = "Ahead to Cho'Rush/Gordok",
                    points  = {
                        { 0.315, 0.469 },
                        { 0.315, 0.347 },
                    },
                },
            },
        },
        -- 7. King Gordok (boss 7). No path: he stands beside Cho'Rush, so
        -- the step is prose only and lands the moment the player is already
        -- there.
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "King Gordok",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "After defeating ^Cho'Rush the Observer^, you can kill ^King Gordok^ right next to him.",
                    minNote = "Kill Gordok nearby",
                    points  = {},
                },
            },
        },
    },
}
