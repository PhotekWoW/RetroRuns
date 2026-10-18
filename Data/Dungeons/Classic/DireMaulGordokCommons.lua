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

    -- The Gordok Tribute chest, shown in the browser's event section.
    eventLabel = "Tribute Chest",
    eventNote  = "Tribute loot comes from the Gordok Tribute chest: defeat King Gordok while the wing's other bosses still live, then speak with Mizzle the Crafty to be crowned and claim the chest. The more bosses you leave alive, the more loot it holds.",
    eventLoot = {
        { id = 18495, slot = "Back", name = "Redoubt Cloak", sources = { [14]=7373 }, bind = "BoP" },
        { id = 18478, slot = "Chest", name = "Hyena Hide Jerkin", sources = { [14]=7360 }, bind = "BoP" },
        { id = 18532, slot = "Chest", name = "Mindsurge Robe", sources = { [14]=7399 }, bind = "BoP" },
        { id = 18530, slot = "Chest", name = "Ogre Forged Hauberk", sources = { [14]=7397 }, bind = "BoP" },
        { id = 18476, slot = "Feet", name = "Mud Stained Boots", sources = { [14]=7358 }, bind = "BoP" },
        { id = 18479, slot = "Head", name = "Carrion Scorpid Helm", sources = { [14]=7361 }, bind = "BoP" },
        { id = 18480, slot = "Head", name = "Scarab Plate Helm", sources = { [14]=7362 }, bind = "BoP" },
        { id = 18477, slot = "Legs", name = "Shaggy Leggings", sources = { [14]=7359 }, bind = "BoP" },
        { id = 18499, slot = "Off-hand", name = "Barrier Shield", sources = { [14]=7377 }, bind = "BoP" },
        { id = 18482, slot = "Ranged", name = "Ogre Toothpick Shooter", sources = { [14]=7364 }, bind = "BoP" },
        { id = 18528, slot = "Shoulder", name = "Cyclone Spaulders", sources = { [14]=7395 }, bind = "BoP" },
        { id = 18534, slot = "Two-Hand", name = "Rod of the Ogre Magi", sources = { [14]=7401 }, bind = "BoP" },
        { id = 18481, slot = "Two-Hand", name = "Skullcracking Mace", sources = { [14]=7363 }, bind = "BoP" },
        { id = 18538, slot = "Two-Hand", name = "Treant's Bane", sources = { [14]=7404 }, bind = "BoP" },
        { id = 18531, slot = "Two-Hand", name = "Unyielding Maul", sources = { [14]=7398 }, bind = "BoP" },
        { id = 18529, slot = "Waist", name = "Elemental Plate Girdle", sources = { [14]=7396 }, bind = "BoP" },
        { id = 18475, slot = "Waist", name = "Oddly Magical Belt", sources = { [14]=7357 }, bind = "BoP" },
        { id = 18533, slot = "Wrist", name = "Gordok Bracers of Power", sources = { [14]=7400 }, bind = "BoP" },
    },
    -- The chest's rewards count toward the Tribute run only, with King
    -- Gordok, whose death brings Mizzle and the chest.
    eventVariant = "skip",
    eventBoss    = 7,

    -- The Tribute run is this wing's second route: every guard and Cho'Rush
    -- left alive, Slip'kik trapped, Kromcrush fooled, then the king.
    skipRouteKind       = "tribute",
    -- Shown on the Tribute run's complete screen.
    skipRouteCompleteNote = "Talk to ^Mizzle the Crafty^ until he spawns the ^Gordok Tribute^ chest, then open it.",
    skipRouteLeaveAlive = { 1, 2, 3, 4, 5, 6 },
    -- "Do Not Kill" sits below each pin; Slip'kik's goes right, Kromcrush's
    -- above, clear of Knot Thimblejack's label.
    skipRouteLeaveAliveLabelPos = { [4] = "right", [5] = "above" },
    -- When each counts as left alive: the guards and Slip'kik once the route
    -- is past the trap, Kromcrush once his line opens the king's segment.
    -- Every one still standing counts once the king is dead.
    skipRoutePassed = {
        { bosses = { 1, 2, 3, 4 }, atSegment = 3 },
        { bosses = { 5 },          atSegment = 8 },
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
            },
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
            skipWhenCollected = true,
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

    -- The Tribute run as one step on the king: the way to the trap, then
    -- segments that open on the trap's quest, the tannin, the suit, the suit
    -- worn and Kromcrush's line once fooled.
    skipRoute = {
        {
            step      = 1,
            priority  = 1,
            bossIndex = 7,
            title     = "King Gordok",
            requires  = { },
            drawCurrentSegOnly = true,
            checklist = {
                label = "Tribute Checklist:",
                rows  = {
                    { bossesAlive = { 1, 2, 3, 4, 5 }, text = "Guards alive" },
                    { heardAtSegment = 3, text = "Broken Trap armed" },
                    { doneAtSegment = 5, text = "Ogre Tannin" },
                    { doneAtSegment = 6, aura = 22736, useItem = 18258, timerUntilSegment = 8,
                      text = "Gordok Ogre Suit" },
                    { doneAtSegment = 8, text = "Captain Kromcrush fooled" },
                    { bossesAlive = { 6 }, text = "Cho'Rush the Observer alive",
                      brokenText = "(killed)" },
                },
            },
            segments  = {
                {
                    when    = { mapID = 235 },
                    kind    = "path",
                    note    = "Skip the first three bosses as you follow the path into ^Guard Slip'kik^'s room. Click the ^Broken Trap^ and let ^Slip'kik^ walk into it.",
                    minNote = "Click Broken Trap for Slip'kik",
                    points  = {
                        { 0.718, 0.882 },
                        { 0.677, 0.882 },
                        { 0.648, 0.872 },
                        { 0.604, 0.873 },
                        { 0.603, 0.779 },
                        { 0.381, 0.783 },
                        { 0.352, 0.785 },
                        { 0.328, 0.786 },
                        { 0.304, 0.780 },
                        { 0.289, 0.773 },
                        { 0.272, 0.724 },
                        { 0.269, 0.658 },
                    },
                },
                {
                    -- Noteless: the path's text stands. Checks off when
                    -- the trap's quest opens the next segment.
                    when            = { mapID = 235 },
                    kind            = "poi",
                    noMarker        = true,
                    poiSize         = 24,
                    mapLabel        = "Click Broken Trap",
                    mapLabelPos     = "right",
                    completionCheck = true,
                    points          = {
                        { 0.269, 0.658 },
                    },
                },
                {
                    -- Opens on turning in "A Broken Trap", which arms it.
                    when        = { mapID = 235 },
                    kind        = "path",
                    note        = "Go up the ramp in the southwest corner and take the ^Ogre Tannin^ from the basket. An ogre comes for you when you do.",
                    minNote     = "Up the ramp for Ogre Tannin",
                    triggeredBy = { quest = 27118 },
                    points      = {
                        { 0.232, 0.671 },
                        { 0.232, 0.577 },
                    },
                },
                {
                    -- Noteless: the tannin path's text stands. Checks off
                    -- when the tannin lands in the bags.
                    when            = { mapID = 235 },
                    kind            = "poi",
                    noMarker        = true,
                    poiSize         = 24,
                    mapLabel        = "Click Tannin Basket",
                    mapLabelPos     = "upper-left",
                    completionCheck = true,
                    points          = {
                        { 0.232, 0.577 },
                    },
                },
                {
                    when        = { mapID = 235 },
                    kind        = "poi",
                    note        = "Jump down to ^Knot Thimblejack^ by the bonfire and accept his quest, ^The Gordok Ogre Suit^. With the ^Ogre Tannin^ in your bags, turn it right back in to get the ^Gordok Ogre Suit^.",
                    minNote     = "Knot's quest for the suit",
                    mapLabel    = "Knot Thimblejack",
                    mapLabelPos = "above",
                    triggeredBy = { item = 18240, latch = true },
                    points      = {
                        { 0.285, 0.555 },
                    },
                },
                {
                    -- Opens with the suit in the bags; the next one opens
                    -- once it is worn.
                    when        = { mapID = 235 },
                    kind        = "path",
                    note        = "Use the ^Gordok Ogre Suit^ to disguise yourself and start a 10 minute timer.",
                    minNote     = "Use the Gordok Ogre Suit",
                    triggeredBy = { item = 18258, latch = true },
                    points      = {},
                },
                {
                    when        = { mapID = 235 },
                    kind        = "path",
                    note        = "Take the ramp on the southwest corner of the room, then continue climbing up and around until you reach ^Captain Kromcrush^. Talk to him while disguised.",
                    minNote     = "Suit on, talk to Kromcrush",
                    triggeredBy = { aura = 22736, latch = true },
                    points      = {
                        { 0.231, 0.659 },
                        { 0.231, 0.544 },
                        { 0.269, 0.544 },
                        { 0.271, 0.659 },
                        { 0.314, 0.654 },
                        { 0.316, 0.560 },
                    },
                },
                {
                    when        = { mapID = 235 },
                    kind        = "path",
                    note        = "Proceed forward to the final boss, ^King Gordok^. |cffF259C7CAUTION!|r Do not AoE or cleave. ^Cho'Rush the Observer^ must survive for full rewards.",
                    minNote     = "Kill Gordok, spare Cho'Rush",
                    triggeredBy = { dialog = { npc = "Captain Kromcrush", match = "gnoll lover" } },
                    points      = {
                        { 0.315, 0.469 },
                        { 0.315, 0.347 },
                        { 0.320, 0.277 },
                    },
                },
            },
        },
    },
}
