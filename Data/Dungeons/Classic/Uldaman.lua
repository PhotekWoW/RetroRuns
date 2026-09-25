-------------------------------------------------------------------------------
-- RetroRuns Data -- Uldaman
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 70  |  journalInstanceID: 239
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[239] = {
    kind              = "dungeon",
    instanceID        = 70,
    journalInstanceID = 239,
    name              = "Uldaman",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 16,
        x     = 0.3660,
        y     = 0.2910,
    },

    trashLoot = {
        { id = 9397, slot = "Back", name = "Energy Cloak", sources = { [14]=3248 }, bind = "BoE" },
        { id = 9406, slot = "Chest", name = "Spirewind Fetter", sources = { [14]=3257 }, bind = "BoE" },
        { id = 9420, slot = "Head", name = "Adventurer's Pith Helmet", sources = { [14]=3270 }, bind = "BoE" },
        { id = 9429, slot = "Head", name = "Miner's Hat of the Deep", sources = { [14]=3278 }, bind = "BoE" },
        { id = 9431, slot = "Head", name = "Papal Fez", sources = { [14]=3280 }, bind = "BoE" },
        { id = 9393, slot = "Off-hand", name = "Beacon of Hope", sources = { [14]=3244 }, bind = "BoE" },
        { id = 9381, slot = "Ranged", name = "Earthen Rod", sources = { [14]=3232 }, bind = "BoE" },
        { id = 9426, slot = "Ranged", name = "Monolithic Bow", sources = { [14]=3275 }, bind = "BoE" },
        { id = 9422, slot = "Ranged", name = "Shadowforge Bushmaster", sources = { [14]=3271 }, bind = "BoE" },
        { id = 9430, slot = "Shoulder", name = "Spaulders of a Lost Age", sources = { [14]=3279 }, bind = "BoE" },
        { id = 9383, slot = "Two-Hand", name = "Obsidian Cleaver", sources = { [14]=3234 }, bind = "BoE" },
        { id = 9425, slot = "Two-Hand", name = "Pendulum of Doom", sources = { [14]=3274 }, bind = "BoE" },
        { id = 9423, slot = "Two-Hand", name = "The Jackhammer", sources = { [14]=3272 }, bind = "BoE" },
        { id = 9391, slot = "Two-Hand", name = "The Shoveler", sources = { [14]=3242 }, bind = "BoE" },
        { id = 9392, slot = "Weapon", name = "Annealed Blade", sources = { [14]=3243 }, bind = "BoE" },
        { id = 9465, slot = "Weapon", name = "Digmaster 5000", sources = { [14]=3299 }, bind = "BoE" },
        { id = 9386, slot = "Weapon", name = "Excavator's Brand", sources = { [14]=3237 }, bind = "BoE" },
        { id = 9424, slot = "Weapon", name = "Ginn-Su Sword", sources = { [14]=3273 }, bind = "BoE" },
        { id = 9427, slot = "Weapon", name = "Stonevault Bonebreaker", sources = { [14]=3276 }, bind = "BoE" },
        { id = 9384, slot = "Weapon", name = "Stonevault Shiv", sources = { [14]=3235 }, bind = "BoE" },
        { id = 9432, slot = "Wrist", name = "Skullplate Bracers", sources = { [14]=3281 }, bind = "BoE" },
        { id = 9428, slot = "Wrist", name = "Unearthed Bands", sources = { [14]=3277 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Revelosh",
            journalEncounterID = 467,
            dungeonEncounterID = 547,
            achievements       = {
            },
            loot = {
                { id = 9387, slot = "Feet", name = "Revelosh's Boots", sources = { [14]=3238 } },
                { id = 9390, slot = "Hands", name = "Revelosh's Gloves", sources = { [14]=3241 } },
                { id = 132736, slot = "Shoulder", name = "Revelosh's Pauldrons", sources = { [14]=76413 } },
                { id = 9389, slot = "Shoulder", name = "Revelosh's Spaulders", sources = { [14]=3240 } },
                { id = 151395, slot = "Waist", name = "Revelosh's Girdle", sources = { [14]=89402 } },
                { id = 9388, slot = "Wrist", name = "Revelosh's Armguards", sources = { [14]=3239 } },
            },
        },
        {
            index              = 2,
            name               = "The Lost Dwarves",
            journalEncounterID = 468,
            dungeonEncounterID = 548,
            -- Horde-only encounter: the NPCs stand there for Alliance but
            -- cannot be engaged, and the journal hides the entry.
            faction            = "Horde",
            achievements       = {
            },
            loot = {
                { id = 132734, slot = "Feet", name = "Viking Chain Boots", sources = { [14]=76411 }, faction = "Horde" },
                { id = 9398, slot = "Feet", name = "Worn Running Boots", sources = { [14]=3249 }, faction = "Horde" },
                { id = 9394, slot = "Head", name = "Horned Viking Helmet", sources = { [14]=3245 }, faction = "Horde" },
                { id = 9403, slot = "Off-hand", name = "Battered Viking Shield", sources = { [14]=3254 }, faction = "Horde" },
                { id = 9404, slot = "Off-hand", name = "Olaf's All Purpose Shield", sources = { [14]=3255 }, faction = "Horde" },
                { id = 9400, slot = "Ranged", name = "Baelog's Shortbow", sources = { [14]=3251 }, faction = "Horde" },
                { id = 9401, slot = "Weapon", name = "Nordic Longshank", sources = { [14]=3252 }, faction = "Horde" },
                { id = 151396, slot = "Wrist", name = "Erik's High-Performance Armbands", sources = { [14]=89403 }, faction = "Horde" },
            },
        },
        {
            index              = 3,
            name               = "Ironaya",
            journalEncounterID = 469,
            dungeonEncounterID = 549,
            achievements       = {
            },
            loot = {
                { id = 151420, slot = "Chest", name = "Vault-Watcher's Breastplate", sources = { [14]=89424 } },
                { id = 151398, slot = "Head", name = "Hood of the Idle Architect", sources = { [14]=89405 } },
                { id = 9407, slot = "Legs", name = "Stoneweaver Leggings", sources = { [14]=3258 } },
                { id = 9408, slot = "Two-Hand", name = "Ironshod Bludgeon", sources = { [14]=3259 } },
                { id = 9409, slot = "Wrist", name = "Ironaya's Bracers", sources = { [14]=3260 } },
            },
        },
        {
            index              = 4,
            name               = "Obsidian Sentinel",
            journalEncounterID = 748,
            dungeonEncounterID = 1887,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 5,
            name               = "Ancient Stone Keeper",
            journalEncounterID = 470,
            dungeonEncounterID = 551,
            achievements       = {
            },
            loot = {
                { id = 151400, slot = "Feet", name = "Sand-Scoured Treads", sources = { [14]=89406 } },
                { id = 9410, slot = "Hands", name = "Cragfists", sources = { [14]=3261 } },
                { id = 151401, slot = "Legs", name = "Titanic Stone Legguards", sources = { [14]=89407 } },
                { id = 9411, slot = "Shoulder", name = "Rockshard Pauldrons", sources = { [14]=3262 } },
                { id = 132733, slot = "Shoulder", name = "Stone Keeper's Mantle", sources = { [14]=76410 } },
            },
        },
        {
            index              = 6,
            name               = "Galgann Firehammer",
            journalEncounterID = 471,
            dungeonEncounterID = 552,
            achievements       = {
            },
            loot = {
                { id = 11311, slot = "Back", name = "Emberscale Cape", sources = { [14]=4167 } },
                { id = 9412, slot = "Ranged", name = "Galgann's Fireblaster", sources = { [14]=3263 } },
                { id = 11310, slot = "Shoulder", name = "Flameseer Mantle", sources = { [14]=4166 } },
                { id = 9419, slot = "Weapon", name = "Galgann's Firehammer", sources = { [14]=3269 } },
            },
        },
        {
            index              = 7,
            name               = "Grimlok",
            journalEncounterID = 472,
            dungeonEncounterID = 553,
            achievements       = {
            },
            loot = {
                { id = 9415, slot = "Chest", name = "Grimlok's Tribal Vestments", sources = { [14]=3266 } },
                { id = 132735, slot = "Legs", name = "Grimlok's Chain Chaps", sources = { [14]=76412 } },
                { id = 9414, slot = "Legs", name = "Oilskin Leggings", sources = { [14]=3265 } },
                { id = 9416, slot = "Two-Hand", name = "Grimlok's Charge", sources = { [14]=3267 } },
                { id = 151402, slot = "Wrist", name = "Grimlok's Jagged Wristguards", sources = { [14]=89408 } },
            },
        },
        {
            index              = 8,
            name               = "Archaedas",
            journalEncounterID = 473,
            dungeonEncounterID = 554,
            achievements       = {
            },
            loot = {
                { id = 9418, slot = "Two-Hand", name = "Stoneslayer", sources = { [14]=3268 } },
                { id = 9413, slot = "Two-Hand", name = "The Rockpounder", sources = { [14]=3264 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    -- Step order matches journal order here, and step number matches
    -- boss index throughout.
    routing = {
        -- 1. Revelosh (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Revelosh",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 230 },
                    kind    = "path",
                    note    = "After zoning in, follow the path around to ^Revelosh^.",
                    minNote = "Follow path to Revelosh",
                    points  = {
                        { 0.655, 0.679 },
                        { 0.654, 0.632 },
                        { 0.621, 0.632 },
                        { 0.620, 0.698 },
                        { 0.568, 0.700 },
                        { 0.566, 0.636 },
                        { 0.532, 0.636 },
                        { 0.532, 0.693 },
                    },
                },
            },
        },

        -- 2. The Lost Dwarves (boss 2) -- Horde only. The step is dropped
        -- for an Alliance route, whose bosses are the other seven.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "The Lost Dwarves",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 230 },
                    kind    = "path",
                    note    = "After killing ^Revelosh^, head south into ^Dig 2^ and you will find ^The Lost Dwarves^ up the ramp.",
                    minNote = "South to Lost Dwarves",
                    points  = {
                        { 0.532, 0.770 },
                        { 0.533, 0.812 },
                        { 0.564, 0.814 },
                        { 0.566, 0.849 },
                        { 0.587, 0.860 },
                        { 0.592, 0.886 },
                    },
                },
            },
        },

        -- 3. Ironaya (boss 3) -- spawned by the Keystone, so the step is a
        -- single marker on it rather than a path.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Ironaya",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 230 },
                    kind        = "poi",
                    note        = "Head west and click the ^Keystone^ in the small green model buildings. After a short scripted sequence, ^Ironaya^ will emerge from the door.",
                    minNote     = "Click Keystone to spawn Ironaya",
                    mapLabel    = "Click Keystone",
                    mapLabelPos = "above",
                    points      = {
                        { 0.448, 0.742 },
                    },
                },
            },
        },

        -- 4. Obsidian Sentinel (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Obsidian Sentinel",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 230 },
                    kind    = "path",
                    note    = "After defeating ^Ironaya^, take the northern path and keep left until you reach ^Obsidian Sentinel^.",
                    minNote = "North to Obsidian Sentinel",
                    points  = {
                        { 0.439, 0.694 },
                        { 0.423, 0.664 },
                        { 0.400, 0.651 },
                        { 0.361, 0.639 },
                        { 0.359, 0.613 },
                        { 0.364, 0.596 },
                        { 0.356, 0.567 },
                        { 0.325, 0.538 },
                        { 0.316, 0.562 },
                        { 0.295, 0.562 },
                    },
                },
            },
        },

        -- 5. Ancient Stone Keeper (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Ancient Stone Keeper",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 230 },
                    kind    = "path",
                    note    = "After defeating ^Obsidian Sentinel^, go east and work your way around to ^Ancient Stone Keeper^.",
                    minNote = "East to Ancient Stone Keeper",
                    points  = {
                        { 0.315, 0.562 },
                        { 0.324, 0.534 },
                        { 0.345, 0.549 },
                        { 0.357, 0.567 },
                        { 0.368, 0.556 },
                        { 0.359, 0.518 },
                        { 0.365, 0.495 },
                        { 0.452, 0.490 },
                        { 0.456, 0.473 },
                    },
                },
            },
        },

        -- 6. Galgann Firehammer (boss 6)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Galgann Firehammer",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 230 },
                    kind    = "path",
                    note    = "After killing ^Ancient Stone Keeper^, take the northwest exit and follow the western path until you reach ^Galgann Firehammer^.",
                    minNote = "West to Galgann Firehammer",
                    points  = {
                        { 0.449, 0.410 },
                        { 0.415, 0.412 },
                        { 0.410, 0.362 },
                        { 0.397, 0.362 },
                        { 0.383, 0.395 },
                        { 0.354, 0.398 },
                        { 0.332, 0.363 },
                        { 0.326, 0.348 },
                        { 0.291, 0.346 },
                    },
                },
            },
        },

        -- 7. Grimlok (boss 7)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Grimlok",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 230 },
                    kind    = "path",
                    note    = "After defeating ^Galgann Firehammer^, go northwest to reach ^Grimlok^.",
                    minNote = "Northwest to Grimlok",
                    points  = {
                        { 0.294, 0.346 },
                        { 0.308, 0.346 },
                        { 0.316, 0.321 },
                        { 0.323, 0.287 },
                        { 0.314, 0.260 },
                        { 0.281, 0.215 },
                        { 0.243, 0.264 },
                    },
                },
            },
        },

        -- 8. Archaedas (boss 8) -- two altars and a floor change: the vault
        -- gate on 230, then the descent to Khaz'goroth's Seat on 231.
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Archaedas",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 230 },
                    kind    = "path",
                    note    = "After defeating ^Grimlok^, follow the path to the northeast section of the map until you reach a room with four golems. Activate the ^Altar of the Keepers^, kill the golems, and continue through the door.",
                    minNote = "Northeast to the golem room",
                    points  = {
                        { 0.246, 0.260 },
                        { 0.281, 0.212 },
                        { 0.324, 0.276 },
                        { 0.379, 0.299 },
                        { 0.394, 0.299 },
                        { 0.406, 0.330 },
                        { 0.422, 0.333 },
                        { 0.436, 0.324 },
                        { 0.453, 0.286 },
                        { 0.392, 0.086 },
                        { 0.446, 0.051 },
                        { 0.495, 0.206 },
                        { 0.466, 0.226 },
                    },
                },
                {
                    when        = { mapID = 230, subZone = "The Stone Vault" },
                    kind        = "poi",
                    mapLabel    = "Click Altar",
                    mapLabelPos = "left",
                    points      = {
                        { 0.419, 0.167 },
                    },
                },
                {
                    when    = { mapID = 231, subZone = "Hall of the Crafters" },
                    kind    = "path",
                    note    = "Continue down the stairs until you reach the room with ^Archaedas^. Activate the ^Altar of Archaedas^ to begin the fight.",
                    minNote = "Click Altar for Archaedas",
                    points  = {
                        { 0.661, 0.468 },
                        { 0.693, 0.581 },
                        { 0.599, 0.644 },
                        { 0.584, 0.606 },
                    },
                },
                {
                    when        = { mapID = 231, subZone = "Khaz'goroth's Seat" },
                    kind        = "poi",
                    mapLabel    = "Click Altar",
                    mapLabelPos = "right",
                    points      = {
                        { 0.565, 0.537 },
                    },
                },
            },
        },
    },
}
