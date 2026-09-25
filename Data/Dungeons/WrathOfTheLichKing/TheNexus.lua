-------------------------------------------------------------------------------
-- RetroRuns Data -- The Nexus
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 576  |  journalInstanceID: 281
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[281] = {
    kind              = "dungeon",
    instanceID        = 576,
    journalInstanceID = 281,
    name              = "The Nexus",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "3.0.2",
    timewalking       = true,
    routedIn          = "3.3.0",

    entrance = {
        mapID = 114,
        x     = 0.2750,
        y     = 0.2589,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Commander Stoutbeard",
            journalEncounterID = 617,
            dungeonEncounterID = 3017,
            factionEncounters  = {
                Alliance = { name = "Commander Kolurg",     journalEncounterID = 833, dungeonEncounterID = 3017 },
                Horde    = { name = "Commander Stoutbeard", journalEncounterID = 617, dungeonEncounterID = 3017 },
            },
            aliases            = { "Frozen Commander" },
            availableDifficulties = { 15, 24 },
            achievements       = {
            },
            loot = {
                { id = 37728, slot = "Back", name = "Cloak of the Enemy", sources = { [15]=17972 }, twSource = 72709 },
                { id = 127600, slot = "Back", name = "Rippling Azure Cloak", sources = { [24]=72706 } },
                { id = 127569, slot = "Feet", name = "Attuned Crystalline Boots", sources = { [24]=72679 } },
                { id = 37730, slot = "Feet", name = "Cleric's Linen Shoes", sources = { [15]=17974 }, twSource = 72711 },
                { id = 37729, slot = "Hands", name = "Grips of Sculptured Icicles", sources = { [15]=17973 }, twSource = 72710 },
                { id = 37731, slot = "Legs", name = "Opposed Stasis Leggings", sources = { [15]=17975 }, twSource = 72712 },
                { id = 127568, slot = "Weapon", name = "Glacier Sharpened Vileblade", sources = { [24]=72678 } },
            },
        },
        {
            index              = 2,
            name               = "Grand Magus Telestra",
            journalEncounterID = 618,
            dungeonEncounterID = 2010,
            achievements       = {
            },
            loot = {
                { id = 37135, slot = "Head", name = "Arcane-Shielded Helm", sources = { [14]=17620, [15]=17620 }, twSource = 72690 },
                { id = 37134, slot = "Off-hand", name = "Telestra's Journal", sources = { [14]=17619, [15]=17619 }, twSource = 72689 },
                { id = 35617, slot = "Ranged", name = "Wand of Shimmering Scales", sources = { [14]=16551, [15]=16551 }, twSource = 72688 },
                { id = 37139, slot = "Shoulder", name = "Spaulders of the Careless Thief", sources = { [14]=17622, [15]=17622 }, twSource = 72692 },
                { id = 35605, slot = "Waist", name = "Belt of Draconic Runes", sources = { [14]=16540, [15]=16540 }, twSource = 72687 },
                { id = 37138, slot = "Wrist", name = "Bands of Channeled Energy", sources = { [14]=17621, [15]=17621 }, twSource = 72691 },
                { id = 35604, slot = "Wrist", name = "Insulating Bindings", sources = { [14]=16539, [15]=16539 }, twSource = 72686 },
            },
        },
        {
            index              = 3,
            name               = "Anomalus",
            journalEncounterID = 619,
            dungeonEncounterID = 2009,
            -- The Heroic lockout marks him defeated when the Frozen
            -- Commander dies (a retired encounter row shares his bit).
            lockoutUnreliable  = true,
            achievements       = {
                { id = 2037, name = "Chaos Theory", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37144, slot = "Chest", name = "Hauberk of the Arcane Wraith", sources = { [14]=17623, [15]=17623 } },
                { id = 127602, slot = "Feet", name = "Cavern Leather Treads", sources = { [24]=72708 } },
                { id = 35600, slot = "Feet", name = "Cleated Ice Boots", sources = { [14]=16535, [15]=16535 } },
                { id = 127576, slot = "Feet", name = "Greaves of the Blue Flight", sources = { [24]=72685 } },
                { id = 37150, slot = "Feet", name = "Rift Striders", sources = { [14]=17626, [15]=17626 } },
                { id = 35599, slot = "Hands", name = "Gauntlets of Serpent Scales", sources = { [14]=16534, [15]=16534 } },
                { id = 127590, slot = "Hands", name = "Gloves of the Crystal Gardener", sources = { [24]=72697 } },
                { id = 37149, slot = "Head", name = "Helm of Anomalus", sources = { [14]=17625, [15]=17625 } },
                { id = 127591, slot = "Legs", name = "Frozen Forest Kilt", sources = { [24]=72698 } },
                { id = 35598, slot = "Off-hand", name = "Tome of the Lore Keepers", sources = { [14]=16533, [15]=16533 } },
                { id = 127575, slot = "Shoulder", name = "Chiseled Stalagmite Pauldrons", sources = { [24]=72684 } },
                { id = 127589, slot = "Waist", name = "Girdle of Ice", sources = { [24]=72696 } },
                { id = 127574, slot = "Weapon", name = "Drakonid Arm Blade", sources = { [24]=72683 } },
            },
        },
        {
            index              = 4,
            name               = "Ormorok the Tree-Shaper",
            journalEncounterID = 620,
            dungeonEncounterID = 2012,
            achievements       = {
            },
            loot = {
                { id = 127603, slot = "Back", name = "Cloak of the Enemy", sources = { [24]=72709 } },
                { id = 127600, slot = "Back", name = "Rippling Azure Cloak", sources = { [24]=72706 } },
                { id = 127569, slot = "Feet", name = "Attuned Crystalline Boots", sources = { [24]=72679 } },
                { id = 127605, slot = "Feet", name = "Cleric's Linen Shoes", sources = { [24]=72711 } },
                { id = 35603, slot = "Feet", name = "Greaves of the Blue Flight", sources = { [14]=16538, [15]=16538 } },
                { id = 37153, slot = "Hands", name = "Gloves of the Crystal Gardener", sources = { [14]=17628, [15]=17628 } },
                { id = 127604, slot = "Hands", name = "Grips of Sculptured Icicles", sources = { [24]=72710 } },
                { id = 37155, slot = "Legs", name = "Frozen Forest Kilt", sources = { [14]=17629, [15]=17629 } },
                { id = 127606, slot = "Legs", name = "Opposed Stasis Leggings", sources = { [24]=72712 } },
                { id = 35602, slot = "Shoulder", name = "Chiseled Stalagmite Pauldrons", sources = { [14]=16537, [15]=16537 } },
                { id = 157559, slot = "Waist", name = "Chilly Cinch", sources = { [14]=93754, [15]=93754 } },
                { id = 37152, slot = "Waist", name = "Girdle of Ice", sources = { [14]=17627, [15]=17627 } },
                { id = 35601, slot = "Weapon", name = "Drakonid Arm Blade", sources = { [14]=16536, [15]=16536 } },
                { id = 127568, slot = "Weapon", name = "Glacier Sharpened Vileblade", sources = { [24]=72678 } },
            },
        },
        {
            index              = 5,
            name               = "Keristrasza",
            journalEncounterID = 621,
            dungeonEncounterID = 2011,
            achievements       = {
                { id = 2036, name = "Intense Cold", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37165, slot = "Chest", name = "Crystal-Infused Tunic", sources = { [14]=17631, [15]=17631 }, twSource = 72700 },
                { id = 35596, slot = "Feet", name = "Attuned Crystalline Boots", sources = { [14]=16532, [15]=16532 } },
                { id = 37167, slot = "Feet", name = "Dragon Slayer's Sabatons", sources = { [14]=17632, [15]=17632 }, twSource = 72701 },
                { id = 37172, slot = "Hands", name = "Gloves of Glistening Runes", sources = { [14]=17636, [15]=17636 }, twSource = 72705 },
                { id = 157565, slot = "Hands", name = "Tangler-Leather Gloves", sources = { [14]=93760, [15]=93760 } },
                { id = 37162, slot = "Off-hand", name = "Bulwark of the Noble Protector", sources = { [14]=17630, [15]=17630 }, twSource = 72699 },
                { id = 37171, slot = "Waist", name = "Flame-Bathed Steel Girdle", sources = { [14]=17635, [15]=17635 }, twSource = 72704 },
                { id = 35595, slot = "Weapon", name = "Glacier Sharpened Vileblade", sources = { [14]=16531, [15]=16531 } },
                { id = 37169, slot = "Weapon", name = "War Mace of Unrequited Love", sources = { [14]=17633, [15]=17633 }, twSource = 72702 },
                { id = 37170, slot = "Wrist", name = "Interwoven Scale Bracers", sources = { [14]=17634, [15]=17634 }, twSource = 72703 },
            },
        },
    },

    exitNote    = "Go south from the boss room to reach the entrance",
    minExitNote = "South to entrance",

    routing = {
        -- 1. Commander Kolurg / Stoutbeard (boss 1, Heroic only). Left from
        -- the door into the Hall of Stasis, where he patrols.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Commander Kolurg",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 129 },
                    kind    = "path",
                    note    = "After zoning in, take a left and follow the path into the ^Hall of Stasis^, where ^Commander Kolurg^ patrols.",
                    minNote = "Go left to Kolurg",
                    points  = {
                        { 0.337, 0.779 },
                        { 0.267, 0.676 },
                        { 0.226, 0.677 },
                        { 0.210, 0.645 },
                        { 0.221, 0.583 },
                        { 0.193, 0.541 },
                    },
                },
            },
        },

        -- 2. Grand Magus Telestra (boss 2). The same corridor on from the
        -- door, worded for both the Normal and the post-Commander reader.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Grand Magus Telestra",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 129 },
                    kind    = "path",
                    note    = "Follow the linear path to ^Grand Magus Telestra^.",
                    minNote = "Follow path to Telestra",
                    points  = {
                        { 0.337, 0.779 },
                        { 0.267, 0.676 },
                        { 0.226, 0.677 },
                        { 0.210, 0.645 },
                        { 0.221, 0.583 },
                        { 0.193, 0.541 },
                        { 0.198, 0.469 },
                        { 0.219, 0.448 },
                        { 0.209, 0.381 },
                        { 0.226, 0.349 },
                        { 0.262, 0.333 },
                        { 0.275, 0.338 },
                        { 0.276, 0.367 },
                    },
                },
            },
        },
        -- 3. Anomalus (boss 3). North out of the Librarium and across The Rift.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Anomalus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 129 },
                    kind    = "path",
                    note    = "After defeating ^Grand Magus Telestra^, follow the northern path into ^The Rift^. Work your way across the room until you reach ^Anomalus^.",
                    minNote = "Follow path to Anomalus",
                    points  = {
                        { 0.275, 0.354 },
                        { 0.277, 0.296 },
                        { 0.255, 0.289 },
                        { 0.270, 0.249 },
                        { 0.313, 0.220 },
                        { 0.448, 0.219 },
                        { 0.462, 0.290 },
                        { 0.495, 0.259 },
                        { 0.510, 0.150 },
                        { 0.522, 0.149 },
                        { 0.555, 0.217 },
                        { 0.594, 0.222 },
                    },
                },
            },
        },
        -- 4. Ormorok the Tree-Shaper (boss 4). South out of The Rift and
        -- around The Singing Grove.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Ormorok the Tree-Shaper",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 129 },
                    kind    = "path",
                    note    = "After defeating ^Anomalus^, work your way south into ^The Singing Grove^. Follow the path around until you reach ^Ormorok the Tree-Shaper^.",
                    minNote = "Follow the southern path to Ormorok",
                    points  = {
                        { 0.592, 0.220 },
                        { 0.529, 0.218 },
                        { 0.507, 0.257 },
                        { 0.541, 0.361 },
                        { 0.539, 0.429 },
                        { 0.552, 0.464 },
                        { 0.551, 0.494 },
                        { 0.559, 0.511 },
                        { 0.570, 0.538 },
                        { 0.602, 0.528 },
                        { 0.643, 0.529 },
                        { 0.651, 0.616 },
                        { 0.619, 0.614 },
                        { 0.603, 0.639 },
                        { 0.571, 0.691 },
                    },
                },
            },
        },
        -- 5. Keristrasza (boss 5). West out of the grove; three orbs release her.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Keristrasza",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 129 },
                    kind    = "path",
                    note    = "After bringing down ^Ormorok the Tree-Shaper^, take the western exit behind him and follow the path to ^Keristrasza^. Click all three orbs to activate the boss.",
                    minNote = "Western path to Keristrasza",
                    points  = {
                        { 0.532, 0.705 },
                        { 0.523, 0.686 },
                        { 0.531, 0.655 },
                        { 0.542, 0.636 },
                        { 0.525, 0.611 },
                        { 0.492, 0.677 },
                        { 0.387, 0.677 },
                    },
                },
            },
        },
    },
}
