-------------------------------------------------------------------------------
-- RetroRuns Data -- Ahn'kahet: The Old Kingdom
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 619  |  journalInstanceID: 271
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[271] = {
    kind              = "dungeon",
    instanceID        = 619,
    journalInstanceID = 271,
    name              = "Ahn'kahet: The Old Kingdom",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    routedIn          = "3.3.0",

    entrance = {
        mapID = 115,
        x     = 0.2853,
        y     = 0.5176,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37625, slot = "Hands", name = "Web Winder Gloves", sources = { [15]=17904 }, bind = "BoE" },
        { id = 35616, slot = "Shoulder", name = "Spored Tendrils Spaulders", sources = { [14]=16550 }, bind = "BoE" },
        { id = 35615, slot = "Wrist", name = "Glowworm Cavern Bindings", sources = { [14]=16549 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Elder Nadox",
            journalEncounterID = 580,
            dungeonEncounterID = 1969,
            achievements       = {
                { id = 2038, name = "Respect Your Elders", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 35607, slot = "Hands", name = "Ahn'kahar Handwraps", sources = { [14]=16542, [15]=16542 } },
                { id = 37592, slot = "Head", name = "Brood Plague Helmet", sources = { [14]=17884, [15]=17884 } },
                { id = 37594, slot = "Head", name = "Elder Headpiece", sources = { [14]=17886, [15]=17886 } },
                { id = 37593, slot = "Shoulder", name = "Sprinting Shoulderpads", sources = { [14]=17885, [15]=17885 } },
                { id = 35608, slot = "Waist", name = "Crawler-Emblem Belt", sources = { [14]=16543, [15]=16543 } },
                { id = 35606, slot = "Weapon", name = "Blade of Nadox", sources = { [14]=16541, [15]=16541 } },
            },
        },
        {
            index              = 2,
            name               = "Prince Taldaram",
            journalEncounterID = 581,
            dungeonEncounterID = 1966,
            achievements       = {
            },
            loot = {
                { id = 37612, slot = "Chest", name = "Bonegrinder Breastplate", sources = { [14]=17893, [15]=17893 } },
                { id = 37614, slot = "Hands", name = "Gauntlets of the Plundering Geist", sources = { [14]=17895, [15]=17895 } },
                { id = 35611, slot = "Hands", name = "Gloves of the Blood Prince", sources = { [14]=16545, [15]=16545 } },
                { id = 35609, slot = "Off-hand", name = "Talisman of Scourge Command", sources = { [14]=16544, [15]=16544 } },
                { id = 37613, slot = "Wrist", name = "Flame Sphere Bindings", sources = { [14]=17894, [15]=17894 } },
            },
        },
        {
            index              = 3,
            name               = "Jedoga Shadowseeker",
            journalEncounterID = 582,
            dungeonEncounterID = 1967,
            achievements       = {
                { id = 2056, name = "Volunteer Work", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 43278, slot = "Back", name = "Cloak of the Darkcaster", sources = { [14]=20940, [15]=20940 } },
                { id = 43283, slot = "Back", name = "Subterranean Waterfall Shroud", sources = { [14]=20944, [15]=20944 } },
                { id = 43279, slot = "Chest", name = "Battlechest of the Twilight Cult", sources = { [14]=20941, [15]=20941 } },
                { id = 43280, slot = "Head", name = "Faceguard of the Hammer Clan", sources = { [14]=20942, [15]=20942 } },
                { id = 43281, slot = "Two-Hand", name = "Edge of Oblivion", sources = { [14]=20943, [15]=20943 } },
                { id = 44191, slot = "Two-Hand", name = "Ice-Rimed Chopper", sources = { [14]=21378, [15]=21378 } },
            },
        },
        {
            index              = 4,
            name               = "Amanitar",
            journalEncounterID = 583,
            dungeonEncounterID = 1989,
            availableDifficulties = { 15 },
            achievements       = {
            },
            loot = {
                { id = 43287, slot = "Hands", name = "Silken Bridge Handwraps", sources = { [15]=20947 } },
                { id = 43286, slot = "Legs", name = "Legguards of Swarming Attacks", sources = { [15]=20946 } },
                { id = 43284, slot = "Ranged", name = "Amanitar Skullbow", sources = { [15]=20945 } },
            },
        },
        {
            index              = 5,
            name               = "Herald Volazj",
            journalEncounterID = 584,
            dungeonEncounterID = 1968,
            achievements       = {
                { id = 1862, name = "Volazj's Quick Demise", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37618, slot = "Feet", name = "Greaves of Ancient Evil", sources = { [14]=17899, [15]=17899 } },
                { id = 35614, slot = "Feet", name = "Volazj's Sabatons", sources = { [14]=16548, [15]=16548 } },
                { id = 37623, slot = "Hands", name = "Fiery Obelisk Handguards", sources = { [14]=17903, [15]=17903 } },
                { id = 37616, slot = "Legs", name = "Kilt of the Forgotten One", sources = { [14]=17897, [15]=17897 } },
                { id = 37622, slot = "Legs", name = "Skirt of the Old Kingdom", sources = { [14]=17902, [15]=17902 } },
                { id = 37615, slot = "Ranged", name = "Titanium Compound Bow", sources = { [14]=17896, [15]=17896 } },
                { id = 37619, slot = "Ranged", name = "Wand of Ahn'kahet", sources = { [14]=17900, [15]=17900 } },
                { id = 35612, slot = "Shoulder", name = "Mantle of Echoing Bats", sources = { [14]=16546, [15]=16546 } },
                { id = 37617, slot = "Two-Hand", name = "Staff of Sinister Claws", sources = { [14]=17898, [15]=17898 } },
                { id = 35613, slot = "Waist", name = "Pyramid Embossed Belt", sources = { [14]=16547, [15]=16547 } },
                { id = 37620, slot = "Wrist", name = "Bracers of the Herald", sources = { [14]=17901, [15]=17901 } },
            },
        },
    },

    exitNote    = "Continue west past the boss to exit",
    minExitNote = "Continue west to exit",

    routing = {
        -- 1. Elder Nadox (boss 1). Straight along the path from the door.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Elder Nadox",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 132 },
                    kind    = "path",
                    note    = "After zoning in, follow the path ahead until you reach ^Elder Nadox^.",
                    minNote = "Follow path to Elder Nadox",
                    points  = {
                        { 0.870, 0.726 },
                        { 0.802, 0.556 },
                        { 0.784, 0.444 },
                        { 0.815, 0.411 },
                        { 0.807, 0.344 },
                        { 0.751, 0.305 },
                        { 0.719, 0.328 },
                        { 0.708, 0.306 },
                    },
                },
            },
        },

        -- 2. Prince Taldaram (boss 2). Two devices to click on the way,
        -- each leg drawn only once its cue has landed.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Prince Taldaram",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 132 },
                    kind    = "path",
                    note    = "After killing ^Elder Nadox^, follow the path to click the first ^Ancient Nerubian Device^.",
                    minNote = "Follow path to first Nerubian Device",
                    points  = {
                        { 0.693, 0.308 },
                        { 0.671, 0.331 },
                        { 0.650, 0.254 },
                        { 0.609, 0.285 },
                        { 0.619, 0.355 },
                        { 0.591, 0.357 },
                        { 0.572, 0.323 },
                        { 0.568, 0.277 },
                    },
                },
                {
                    -- Noteless, so the leg above keeps the pane while the
                    -- device is unclicked; the label carries its check.
                    when            = { mapID = 132 },
                    kind            = "poi",
                    mapLabel        = "Click 1st Device",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    points          = {
                        { 0.564, 0.241 },
                    },
                },
                {
                    -- The emote lands on the first device clicked.
                    when         = { mapID = 132 },
                    kind         = "path",
                    note         = "Go up the next ramp to the west and click the second ^Ancient Nerubian Device^.",
                    minNote      = "West to click second Nerubian Device",
                    triggeredBy  = { dialog = { npc = "Prince Taldaram", match = "The hum of magic energy in the air diminishes" } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.567, 0.277 },
                        { 0.570, 0.327 },
                        { 0.540, 0.350 },
                        { 0.514, 0.316 },
                    },
                },
                {
                    -- Waits on the same emote as the leg above it, so the
                    -- second star appears with the leg that walks to it
                    -- rather than from zone-in.
                    when            = { mapID = 132 },
                    kind            = "poi",
                    mapLabel        = "Click 2nd Device",
                    mapLabelPos     = "upper-left",
                    completionCheck = true,
                    triggeredBy     = { dialog = { npc = "Prince Taldaram", match = "The hum of magic energy in the air diminishes" } },
                    drawWhenOpen    = true,
                    points          = {
                        { 0.500, 0.302 },
                    },
                },
                {
                    -- The prince answers the second device.
                    when         = { mapID = 132 },
                    kind         = "path",
                    note         = "With both devices deactivated, go south to kill ^Prince Taldaram^.",
                    minNote      = "South to kill Prince Taldaram",
                    triggeredBy  = { dialog = { npc = "Prince Taldaram", match = "Intruders! Who trespasses in the Old Kingdom?" } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.524, 0.326 },
                        { 0.544, 0.347 },
                        { 0.557, 0.458 },
                        { 0.598, 0.501 },
                    },
                },
            },
        },

        -- 3. Amanitar (boss 4, Heroic only). The tunnel leg is shared with
        -- Jedoga's step: whichever step the difficulty leaves standing has
        -- to carry it.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 4,
            title     = "Amanitar",
            requires  = { },
            -- Left out once his appearances are all collected; step 5 then
            -- takes the tunnel to Jedoga.
            skipWhenCollected = true,
            segments  = {
                {
                    when    = { mapID = 132, subZone = "Befouled Terrace" },
                    kind    = "path",
                    note    = "After defeating ^Prince Taldaram^, enter the tunnel behind him and take it down to arrive in the southwest portion of the map.",
                    minNote = "Tunnel behind boss",
                    points  = {
                        { 0.645, 0.463 },
                        { 0.661, 0.477 },
                        { 0.665, 0.499 },
                        { 0.657, 0.519 },
                        { 0.639, 0.538 },
                        { 0.618, 0.541 },
                        { 0.600, 0.542 },
                        { 0.574, 0.587 },
                    },
                },
                {
                    when    = { mapID = 132, subZone = "Fallen Temple of Ahn'kahet" },
                    kind    = "path",
                    note    = "After you reach the bottom of the tunnel, take a hard left and follow the path around to ^Amanitar^.",
                    minNote = "Left to Amanitar",
                    points  = {
                        { 0.582, 0.560 },
                        { 0.563, 0.600 },
                        { 0.587, 0.625 },
                        { 0.632, 0.592 },
                        { 0.657, 0.603 },
                        { 0.668, 0.643 },
                        { 0.672, 0.754 },
                    },
                },
            },
        },

        -- 4. Jedoga Shadowseeker (boss 3), Heroic: from Amanitar's room.
        -- Opens only once he is dead; Normal runs take step 5.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 3,
            title     = "Jedoga Shadowseeker",
            requires  = { 4 },
            segments  = {
                {
                    when    = { mapID = 132 },
                    kind    = "path",
                    note    = "After killing ^Amanitar^, backtrack north out of the ^Shimmering Bog^ and go left up the stairs to ^Jedoga Shadowseeker^. Kill all mobs on the platform to activate the boss.",
                    minNote = "Backtrack then west to Jedoga",
                    points  = {
                        { 0.671, 0.745 },
                        { 0.661, 0.601 },
                        { 0.635, 0.593 },
                        { 0.612, 0.611 },
                        { 0.542, 0.723 },
                        { 0.505, 0.733 },
                    },
                },
            },
        },

        -- 5. Jedoga Shadowseeker (boss 3), through the tunnel. The Normal
        -- route; Heroic takes step 4.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 3,
            title     = "Jedoga Shadowseeker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 132, subZone = "Befouled Terrace" },
                    kind    = "path",
                    note    = "After defeating ^Prince Taldaram^, enter the tunnel behind him and take it down to arrive in the southwest portion of the map.",
                    minNote = "Tunnel behind boss",
                    points  = {
                        { 0.645, 0.463 },
                        { 0.661, 0.477 },
                        { 0.665, 0.499 },
                        { 0.657, 0.519 },
                        { 0.639, 0.538 },
                        { 0.618, 0.541 },
                        { 0.600, 0.542 },
                        { 0.574, 0.587 },
                    },
                },
                {
                    when    = { mapID = 132, subZone = "Fallen Temple of Ahn'kahet" },
                    kind    = "path",
                    note    = "After you reach the bottom of the tunnel, go straight ahead up the stairs to reach ^Jedoga Shadowseeker^. Clear all mobs on the platform to activate the boss.",
                    minNote = "Ahead to Jedoga",
                    points  = {
                        { 0.594, 0.545 },
                        { 0.563, 0.602 },
                        { 0.530, 0.570 },
                        { 0.486, 0.654 },
                        { 0.486, 0.692 },
                    },
                },
            },
        },

        -- 6. Herald Volazj (boss 5). West from the altar.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 5,
            title     = "Herald Volazj",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 132 },
                    kind    = "path",
                    note    = "After defeating ^Jedoga Shadowseeker^, go back down the stairs and make your way to the west to engage the final boss, ^Herald Volazj^.",
                    minNote = "Downstairs, left to Volazj",
                    points  = {
                        { 0.479, 0.687 },
                        { 0.481, 0.654 },
                        { 0.539, 0.541 },
                        { 0.506, 0.491 },
                        { 0.262, 0.505 },
                    },
                },
            },
        },
    },
}
