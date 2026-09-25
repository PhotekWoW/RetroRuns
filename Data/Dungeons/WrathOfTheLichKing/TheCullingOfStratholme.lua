-------------------------------------------------------------------------------
-- RetroRuns Data -- The Culling of Stratholme
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 595  |  journalInstanceID: 279
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

-- Steps 2 to 4 are the same on both routes; the intro is the only
-- difference, so they are written once.
local salrammStep = {
    step      = 2,
    priority  = 1,
    bossIndex = 2,
    title     = "Salramm the Fleshcrafter",
    requires  = { },
    segments  = {
        {
            when    = { mapID = 131 },
            kind    = "path",
            note         = "After defeating ^Meathook^, kill the remaining 5 waves to spawn ^Salramm the Fleshcrafter^.",
            minNote      = "Kill 5 more waves for Salramm",
            ringAreaPOIs = true,
            points       = { },
        },
        {
            when        = { mapID = 131 },
            kind        = "path",
            note         = "^Salramm^ has spawned! He can spawn in various locations along the main road.",
            minNote      = "Find Salramm patrolling",
            triggeredBy  = { dialog = { npc = "Salramm the Fleshcrafter", match = "The dead shall have their day" } },
            ringAreaPOIs = true,
            points       = { },
        },
    },
}

local epochStep = {
    step      = 3,
    priority  = 1,
    bossIndex = 3,
    title     = "Chrono-Lord Epoch",
    requires  = { },
    segments  = {
        {
            when            = { mapID = 131 },
            kind            = "poi",
            note            = "After defeating ^Salramm^, go east towards the Town Hall. Talk to ^Arthas^ to begin a scripted escort through the building.",
            minNote         = "East to Arthas",
            mapLabel        = "Talk to Arthas",
            mapLabelPos     = "right",
            completionCheck = true,
            points          = {
                { 0.585, 0.354 },
            },
        },
        {
            when        = { mapID = 131 },
            kind        = "path",
            note        = "Escort ^Arthas^ through the building, stopping 4 times to kill enemy trash packs on the way. At the end of the escort, you will face ^Chrono-Lord Epoch^.",
            minNote     = "Escort Arthas to Chrono-Lord",
            triggeredBy = { dialog = { npc = "Arthas", match = "I know the way through" } },
            points      = { },
        },
    },
}

local malganisStep = {
    step      = 4,
    priority  = 1,
    bossIndex = 4,
    title     = "Mal'Ganis",
    requires  = { },
    segments  = {
        {
            when            = { mapID = 131 },
            kind            = "poi",
            note            = "After defeating ^Chrono-Lord Epoch^, talk to Arthas to advance.",
            minNote         = "Talk to Arthas",
            mapLabel        = "Talk to Arthas",
            mapLabelPos     = "below",
            completionCheck = true,
            points          = {
                { 0.647, 0.292 },
            },
        },
        {
            when            = { mapID = 131 },
            kind            = "poi",
            note            = "Follow ^Arthas^ back outside. Speak to him once again to start another escort.",
            minNote         = "Talk to Arthas for escort",
            mapLabel        = "Talk to Arthas",
            mapLabelPos     = "above",
            completionCheck = true,
            triggeredBy     = { dialog = { npc = "Arthas", match = "behind that bookshelf ahead" } },
            points          = {
                { 0.651, 0.149 },
            },
        },
        {
            when        = { mapID = 131 },
            kind        = "path",
            note        = "Escort ^Arthas^ to the other side, killing all enemies along the way.",
            minNote     = "Kill all enemies on escort",
            triggeredBy = { dialog = { npc = "Arthas", match = "the fires might" } },
            points      = { },
        },
        {
            when            = { mapID = 131 },
            kind            = "poi",
            note            = "After the escort, talk to ^Arthas^ one final time to advance.",
            minNote         = "Talk to Arthas",
            mapLabel        = "Talk to Arthas",
            mapLabelPos     = "above",
            completionCheck = true,
            triggeredBy     = { dialog = { npc = "Arthas", match = "Market Row has not caught fire yet" } },
            points          = {
                { 0.404, 0.383 },
            },
        },
        {
            when        = { mapID = 131 },
            kind        = "path",
            note        = "Follow ^Arthas^ into the next room to engage ^Mal'Ganis^.",
            minNote     = "Follow Arthas to Mal'Ganis",
            triggeredBy = { dialog = { npc = "Arthas", match = "Justice will be done" } },
            points      = { },
        },
    },
}

-- 5. Infinite Corruptor (boss 5), Heroic only; on Normal the step is
-- filtered out with its boss.
local corruptorStep = {
    step      = 5,
    priority  = 1,
    bossIndex = 5,
    title     = "Infinite Corruptor",
    requires  = { },
    -- The drake and the achievement are all he offers; a character with
    -- both ends the run on Mal'Ganis.
    skipWhenCollected = true,
    segments  = {
        {
            when    = { mapID = 131 },
            kind    = "path",
            note    = "After killing ^Mal'Ganis^, backtrack out of his area and go east to kill the ^Infinite Corruptor^.",
            minNote = "East to Infinite Corruptor",
            points  = {
                { 0.352, 0.446 },
                { 0.405, 0.420 },
                { 0.432, 0.437 },
                { 0.450, 0.456 },
                { 0.470, 0.467 },
                { 0.493, 0.436 },
            },
        },
    },
}

-- Meathook's spawn line, on both routes.
local meathookSpawnedSeg = {
    when         = { mapID = 131 },
    kind         = "path",
    note         = "^Meathook^ has spawned! Find him patrolling various parts of the main road.",
    minNote      = "Find Meathook patrolling",
    triggeredBy  = { dialog = { npc = "Meathook", match = "Play time!" } },
    ringAreaPOIs = true,
    points       = { },
}

RetroRuns_DungeonData[279] = {
    kind              = "dungeon",
    instanceID        = 595,
    journalInstanceID = 279,
    name              = "The Culling of Stratholme",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    routedIn          = "3.2.0",

    entrance = {
        mapID = 75,
        x     = 0.5835,
        y     = 0.8294,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37115, slot = "Shoulder", name = "Crusader's Square Pauldrons", sources = { [14]=17610, [15]=17610 }, bind = "BoE" },
        { id = 37116, slot = "Shoulder", name = "Epaulets of Market Row", sources = { [14]=17611, [15]=17611 }, bind = "BoE" },
        { id = 37698, slot = "Shoulder", name = "Spaulders of Elder's Square", sources = { [14]=17959, [15]=17959 }, bind = "BoE" },
        { id = 37699, slot = "Waist", name = "Festival Lane Girdle", sources = { [14]=17960, [15]=17960 }, bind = "BoE" },
        { id = 37697, slot = "Weapon", name = "Trade District Knife", sources = { [14]=17958, [15]=17958 }, bind = "BoE" },
        { id = 37117, slot = "Wrist", name = "King's Square Bracers", sources = { [14]=17612, [15]=17612 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Meathook",
            journalEncounterID = 611,
            dungeonEncounterID = 2002,
            achievements       = {
            },
            loot = {
                { id = 37082, slot = "Feet", name = "Slaughterhouse Sabatons", sources = { [14]=17594, [15]=17594 } },
                { id = 37678, slot = "Hands", name = "Bile-Cured Gloves", sources = { [14]=17943, [15]=17943 } },
                { id = 37083, slot = "Legs", name = "Kilt of Sewn Flesh", sources = { [14]=17595, [15]=17595 } },
                { id = 37675, slot = "Legs", name = "Legplates of Steel Implants", sources = { [14]=17942, [15]=17942 } },
                { id = 37679, slot = "Shoulder", name = "Spaulders of the Abomination", sources = { [14]=17944, [15]=17944 } },
                { id = 37680, slot = "Waist", name = "Belt of Unified Souls", sources = { [14]=17945, [15]=17945 } },
                { id = 37081, slot = "Weapon", name = "Meathook's Slicer", sources = { [14]=17593, [15]=17593 } },
            },
        },
        {
            index              = 2,
            name               = "Salramm the Fleshcrafter",
            journalEncounterID = 612,
            dungeonEncounterID = 2004,
            aliases            = { "Salram the Fleshcrafter" },
            achievements       = {
            },
            loot = {
                { id = 37084, slot = "Back", name = "Flowing Cloak of Command", sources = { [14]=17596, [15]=17596 } },
                { id = 37684, slot = "Head", name = "Forgotten Shadow Hood", sources = { [14]=17948, [15]=17948 } },
                { id = 157563, slot = "Legs", name = "Freshly Sewn Leggings", sources = { [14]=93758, [15]=93758 } },
                { id = 37086, slot = "Off-hand", name = "Tome of Salramm", sources = { [14]=17597, [15]=17597 } },
                { id = 37088, slot = "Waist", name = "Spiked Metal Cilice", sources = { [14]=17598, [15]=17598 } },
                { id = 37095, slot = "Waist", name = "Waistband of the Thuzadin", sources = { [14]=17599, [15]=17599 } },
                { id = 37681, slot = "Weapon", name = "Gavel of the Fleshcrafter", sources = { [14]=17946, [15]=17946 } },
                { id = 37682, slot = "Wrist", name = "Bindings of Dark Will", sources = { [14]=17947, [15]=17947 } },
            },
        },
        {
            index              = 3,
            name               = "Chrono-Lord Epoch",
            journalEncounterID = 613,
            dungeonEncounterID = 2003,
            achievements       = {
            },
            loot = {
                { id = 37105, slot = "Feet", name = "Treads of Altered History", sources = { [14]=17601, [15]=17601 } },
                { id = 37686, slot = "Hands", name = "Cracked Epoch Grasps", sources = { [14]=17949, [15]=17949 } },
                { id = 37687, slot = "Hands", name = "Gloves of Distorted Time", sources = { [14]=17950, [15]=17950 } },
                { id = 37688, slot = "Legs", name = "Legplates of the Infinite Drakonid", sources = { [14]=17951, [15]=17951 } },
                { id = 37099, slot = "Two-Hand", name = "Sempiternal Staff", sources = { [14]=17600, [15]=17600 } },
                { id = 37106, slot = "Waist", name = "Ouroboros Belt", sources = { [14]=17602, [15]=17602 } },
            },
        },
        {
            index              = 4,
            name               = "Mal'Ganis",
            journalEncounterID = 614,
            dungeonEncounterID = 2005,
            aliases            = { "Mal'ganis" },
            achievements       = {
                { id = 1872, name = "Zombiefest!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37110, slot = "Hands", name = "Gauntlets of Dark Conversion", sources = { [14]=17606, [15]=17606 } },
                { id = 37114, slot = "Hands", name = "Gloves of Northern Lordaeron", sources = { [14]=17609, [15]=17609 } },
                { id = 37695, slot = "Legs", name = "Legguards of Nature's Power", sources = { [14]=17956, [15]=17956 } },
                { id = 37107, slot = "Off-hand", name = "Leeka's Shield", sources = { [14]=17603, [15]=17603 } },
                { id = 43085, slot = "Off-hand", name = "Royal Crest of Lordaeron", sources = { [14]=20856, [15]=20856 } },
                { id = 37692, slot = "Ranged", name = "Pierce's Pistol", sources = { [14]=17954, [15]=17954 } },
                { id = 37109, slot = "Shoulder", name = "Discarded Silver Hand Spaulders", sources = { [14]=17605, [15]=17605 } },
                { id = 37691, slot = "Shoulder", name = "Mantle of Deceit", sources = { [14]=17953, [15]=17953 } },
                { id = 37690, slot = "Shoulder", name = "Pauldrons of Destiny", sources = { [14]=17952, [15]=17952 } },
                { id = 37108, slot = "Two-Hand", name = "Dreadlord's Blade", sources = { [14]=17604, [15]=17604 } },
                { id = 37112, slot = "Weapon", name = "Beguiling Scepter", sources = { [14]=17607, [15]=17607 } },
                { id = 37693, slot = "Weapon", name = "Greed", sources = { [14]=17955, [15]=17955 } },
                { id = 37113, slot = "Wrist", name = "Demonic Fabric Bands", sources = { [14]=17608, [15]=17608 } },
                { id = 37696, slot = "Wrist", name = "Plague-Infected Bracers", sources = { [14]=17957, [15]=17957 } },
            },
        },
        {
            -- Not a journal boss. Heroic only, behind the Infinite portal
            -- off Festival Lane, and gone once the 25-minute timer runs out.
            index              = 5,
            name               = "Infinite Corruptor",
            npcID              = 32273,
            scenarioCriteriaID = 24857,
            availableDifficulties = { 15 },
            achievements       = {
                { id = 1817, name = "The Culling of Time", meta = true, soloable = "yes" },
            },
            loot = {
            },
            specialLoot = {
                { id = 43951, kind = "mount", name = "Reins of the Bronze Drake", mountID = 264 },
            },
        },
    },

    exitNote    = "Exit portal south of Mal'Ganis",
    minExitNote = "Exit portal south of Mal'Ganis",

    routing = {
        -- 1. Meathook (boss 1). Chromie hands over the Arcane Disruptor
        -- first; the disruptor landing in the bags is the handoff.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Meathook",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 130 },
                    kind            = "poi",
                    note            = "After zoning in, go up the ramps and talk to ^Chromie^.",
                    minNote         = "Talk to Chromie",
                    mapLabel        = "Talk to Chromie",
                    mapLabelPos     = "below",
                    poiSize         = 26,
                    completionCheck = true,
                    points          = {
                        { 0.859, 0.607 },
                    },
                },
                {
                    -- One marker per crate, the cannons shape; the
                    -- disruptor landing in the bags opens the seg.
                    when            = { mapID = 130 },
                    kind            = "poi",
                    note            = "After collecting the ^Arcane Disruptor^, go up through the Inn to arrive outside. Use the item on five different ^Suspicious Grain Crate^ which are marked with |TInterface\\GossipFrame\\AvailableQuestIcon:0|t on the map.",
                    minNote         = "Use Arcane Disruptor on 5 boxes",
                    mapLabel        = "Reveal Crates",
                    mapLabelPos     = "above",
                    markAllPoints   = true,
                    poiIcon         = "Interface\\GossipFrame\\AvailableQuestIcon",
                    poiSize         = 18,
                    completionCheck = true,
                    triggeredBy     = { item = 37888 },
                    points          = {
                        { 0.846, 0.588 },
                        { 0.805, 0.600 },
                        { 0.774, 0.537 },
                        { 0.727, 0.555 },
                        { 0.696, 0.506 },
                    },
                },
                {
                    -- Bartleby's line lands the moment the fifth crate is
                    -- found, but only if he is in earshot; Chromie's
                    -- whisper follows seconds later wherever the player is.
                    when            = { mapID = 130 },
                    kind            = "poi",
                    note            = "Now that you've finished with the crates, continue west and talk to ^Chromie^ again to start a lengthy dialog between ^Arthas^ and ^Uther^.",
                    minNote         = "West to Chromie",
                    mapLabel        = "Talk to Chromie",
                    mapLabelPos     = "lower-left",
                    completionCheck = true,
                    triggeredBy     = { dialog = {
                        { npc = "Bartleby Battson", match = "load everything back into the cart" },
                        { npc = "Chromie", match = "Good work with the crates" },
                    } },
                    points          = {
                        { 0.469, 0.391 },
                    },
                },
                {
                    -- The footman's line opens the Arthas and Uther scene.
                    when        = { mapID = 130 },
                    kind        = "path",
                    note        = "This dialog takes roughly 2.5 minutes to complete. When ^Arthas^ finally enters Stratholme, follow him.",
                    minNote     = "Follow Arthas inside after dialog",
                    triggeredBy = { dialog = { npc = "Lordaeron Footman", match = "The Lightbringer" } },
                    points      = { },
                },
                {
                    -- Arthas's line lands outside; the seg is current from
                    -- that moment, and its marker draws once inside.
                    when            = { mapID = 131 },
                    kind            = "poi",
                    note            = "Enter Stratholme and talk to ^Arthas^ to begin another dialog sequence. This one will last about 1.5 minutes.",
                    minNote         = "Talk to Arthas for another scene",
                    mapLabel        = "Talk to Arthas",
                    mapLabelPos     = "below",
                    completionCheck = true,
                    triggeredBy     = { dialog = { npc = "Arthas", match = "Take position here" } },
                    points          = {
                        { 0.505, 0.777 },
                    },
                },
                {
                    when        = { mapID = 131 },
                    kind        = "path",
                    note         = "After ^Mal'Ganis^ vanishes, the dungeon finally begins. Defeat 5 scourge waves to spawn ^Meathook^. Waves appear on the map as white flags.",
                    minNote      = "Defeat 5 waves to spawn Meathook",
                    triggeredBy  = { dialog = { npc = "Arthas", match = "send out some of his Scourge minions" } },
                    ringAreaPOIs = true,
                    points       = { },
                },
                meathookSpawnedSeg,
            },
        },
        -- 2. Salramm the Fleshcrafter (boss 2)
        salrammStep,
        -- 3. Chrono-Lord Epoch (boss 3)
        epochStep,
        -- 4. Mal'Ganis (boss 4)
        malganisStep,
        -- 5. Infinite Corruptor (boss 5), Heroic only
        corruptorStep,
    },

    -- Chromie's skip, offered once A Royal Escort is complete, teleports
    -- the player to King's Square with the waves already starting. The
    -- crier announces them at once; a full run hears that line only with
    -- the disruptor in hand.
    altRouteWhen = {
        dialog      = { npc = "Lordaeron Crier", match = "Scourge forces have been spotted" },
        withoutItem = 37888,
    },
    altRoute = {
        -- 1. Meathook (boss 1), from the waves.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Meathook",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 131 },
                    kind    = "path",
                    note         = "Defeat 5 scourge waves to spawn ^Meathook^. Waves appear on the map as white flags.",
                    minNote      = "Defeat 5 waves to spawn Meathook",
                    ringAreaPOIs = true,
                    points       = { },
                },
                meathookSpawnedSeg,
            },
        },
        salrammStep,
        epochStep,
        malganisStep,
        corruptorStep,
    },
}
