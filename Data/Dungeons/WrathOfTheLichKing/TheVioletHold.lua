-------------------------------------------------------------------------------
-- RetroRuns Data -- The Violet Hold
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 608  |  journalInstanceID: 283
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[283] = {
    kind              = "dungeon",
    instanceID        = 608,
    journalInstanceID = 283,
    name              = "The Violet Hold",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    routedIn          = "3.2.0",

    entrance = {
        mapID = 127,
        x     = 0.3536,
        y     = 0.4556,
    },

    -- Two random prisoners a run, then Cyanigosa. The slots are the two
    -- "Escaped Prisoner defeated" criteria; the prisoner that fills one is
    -- read from its corpse.
    bossPool = {
        slotLabel = "Escaped Prisoner",
        slots     = { 24858, 24859 },
        members   = { 1, 2, 3, 4, 5, 6 },
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37890, slot = "Legs", name = "Chain Gang Legguards", sources = { [15]=18082 }, bind = "BoE" },
        { id = 37889, slot = "Off-hand", name = "Prison Manifest", sources = { [15]=18081 }, bind = "BoE" },
        { id = 35652, slot = "Ranged", name = "Incessant Torch", sources = { [14]=16575, [15]=16575 }, bind = "BoE" },
        { id = 35653, slot = "Waist", name = "Girdle of the Mystical Prison", sources = { [14]=16576, [15]=16576 }, bind = "BoE" },
        { id = 35654, slot = "Wrist", name = "Bindings of the Bastille", sources = { [14]=16577, [15]=16577 }, bind = "BoE" },
        { id = 37891, slot = "Wrist", name = "Cast Iron Shackles", sources = { [15]=18083 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Erekem",
            journalEncounterID = 626,
            npcID              = 29315,
            achievements       = {
                { id = 1865, name = "Lockdown!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 43406, slot = "Back", name = "Cloak of the Gushing Wound", sources = { [14]=20971, [15]=20971 } },
                { id = 43363, slot = "Back", name = "Screeching Cape", sources = { [14]=20964, [15]=20964 } },
                { id = 157567, slot = "Feet", name = "Bodyguard's Treads", sources = { [14]=93762, [15]=93762 } },
                { id = 43405, slot = "Feet", name = "Sabatons of Erekem", sources = { [14]=20970, [15]=20970 } },
                { id = 43375, slot = "Legs", name = "Trousers of the Arakkoa", sources = { [14]=20965, [15]=20965 } },
                { id = 157583, slot = "Off-hand", name = "Protector's Buckler", sources = { [14]=93774, [15]=93774 } },
                { id = 43407, slot = "Weapon", name = "Stormstrike Mace", sources = { [14]=20972, [15]=20972 } },
            },
        },
        {
            index              = 2,
            name               = "Moragg",
            journalEncounterID = 627,
            npcID              = 29316,
            achievements       = {
            },
            loot = {
                { id = 43410, slot = "Chest", name = "Moragg's Chestguard", sources = { [14]=20974, [15]=20974 } },
                { id = 157566, slot = "Chest", name = "Vest of the Observant", sources = { [14]=93761, [15]=93761 } },
                { id = 43387, slot = "Shoulder", name = "Shoulderplates of the Beholder", sources = { [14]=20966, [15]=20966 } },
                { id = 43409, slot = "Two-Hand", name = "Saliva Corroded Pike", sources = { [14]=20973, [15]=20973 } },
            },
        },
        {
            index              = 3,
            name               = "Ichoron",
            journalEncounterID = 628,
            npcID              = 29313,
            achievements       = {
                { id = 2041, name = "Dehydration", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 43401, slot = "Chest", name = "Water-Drenched Robe", sources = { [14]=20967, [15]=20967 } },
                { id = 37862, slot = "Hands", name = "Gauntlets of the Water Revenant", sources = { [14]=18070, [15]=18070 } },
                { id = 35647, slot = "Hands", name = "Handguards of Rapid Pursuit", sources = { [14]=16571, [15]=16571 } },
                { id = 157569, slot = "Legs", name = "Chain Leggings of the Tide", sources = { [14]=93764, [15]=93764 } },
                { id = 35643, slot = "Shoulder", name = "Spaulders of Ichoron", sources = { [14]=16567, [15]=16567 } },
            },
        },
        {
            index              = 4,
            name               = "Xevozz",
            journalEncounterID = 629,
            npcID              = 29266,
            achievements       = {
            },
            loot = {
                { id = 37867, slot = "Feet", name = "Footwraps of Teleportation", sources = { [14]=18071, [15]=18071 } },
                { id = 157571, slot = "Hands", name = "Gauntlets of Stuttering Reality", sources = { [14]=93766, [15]=93766 } },
                { id = 157575, slot = "Off-hand", name = "Crystal of Ensnared Power", sources = { [14]=93768, [15]=93768 } },
                { id = 35642, slot = "Off-hand", name = "Riot Shield", sources = { [14]=16566, [15]=16566 } },
                { id = 37868, slot = "Waist", name = "Girdle of the Ethereal", sources = { [14]=18072, [15]=18072 } },
                { id = 35644, slot = "Waist", name = "Xevozz's Belt", sources = { [14]=16568, [15]=16568 } },
            },
        },
        {
            index              = 5,
            name               = "Lavanthor",
            journalEncounterID = 630,
            npcID              = 29312,
            achievements       = {
            },
            loot = {
                { id = 37870, slot = "Feet", name = "Twin-Headed Boots", sources = { [14]=18073, [15]=18073 } },
                { id = 35646, slot = "Hands", name = "Lava Burn Gloves", sources = { [14]=16570, [15]=16570 } },
                { id = 157570, slot = "Head", name = "Helm of Cauterization", sources = { [14]=93765, [15]=93765 } },
                { id = 35645, slot = "Ranged", name = "Prison Warden's Shotgun", sources = { [14]=16569, [15]=16569 } },
                { id = 157572, slot = "Shoulder", name = "Pauldrons of the Great Tide", sources = { [14]=93767, [15]=93767 } },
                { id = 37871, slot = "Weapon", name = "The Key", sources = { [14]=18074, [15]=18074 } },
            },
        },
        {
            index              = 6,
            name               = "Zuramat the Obliterator",
            journalEncounterID = 631,
            npcID              = 29314,
            achievements       = {
                { id = 2153, name = "A Void Dance", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 43402, slot = "Feet", name = "The Obliterator Greaves", sources = { [14]=20968, [15]=20968 } },
                { id = 157568, slot = "Head", name = "Helm of Dire Vision", sources = { [14]=93763, [15]=93763 } },
                { id = 43403, slot = "Head", name = "Shroud of Darkness", sources = { [14]=20969, [15]=20969 } },
                { id = 43353, slot = "Legs", name = "Void Sentry Legplates", sources = { [14]=20963, [15]=20963 } },
            },
        },
        {
            index              = 7,
            name               = "Cyanigosa",
            journalEncounterID = 632,
            dungeonEncounterID = 2020,
            npcID              = 31134,
            achievements       = {
                { id = 1816, name = "Defenseless", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 35650, slot = "Feet", name = "Boots of the Portal Guardian", sources = { [14]=16573, [15]=16573 } },
                { id = 37874, slot = "Hands", name = "Gauntlets of Capture", sources = { [14]=18075, [15]=18075 } },
                { id = 37886, slot = "Hands", name = "Handgrips of the Savage Emissary", sources = { [14]=18080, [15]=18080 } },
                { id = 35651, slot = "Hands", name = "Plate Claws of the Dragon", sources = { [14]=16574, [15]=16574 } },
                { id = 43500, slot = "Legs", name = "Bolstered Legplates", sources = { [14]=21013, [15]=21013 } },
                { id = 37876, slot = "Legs", name = "Cyanigosa's Leggings", sources = { [14]=18077, [15]=18077 } },
                { id = 37875, slot = "Shoulder", name = "Spaulders of the Violet Hold", sources = { [14]=18076, [15]=18076 } },
                { id = 35649, slot = "Two-Hand", name = "Jailer's Baton", sources = { [14]=16572, [15]=16572 } },
                { id = 37883, slot = "Two-Hand", name = "Staff of Trickery", sources = { [14]=18078, [15]=18078 } },
                { id = 37884, slot = "Wrist", name = "Azure Cloth Bindings", sources = { [14]=18079, [15]=18079 } },
                { id = 150845, slot = "Wrist", name = "Bracers of Ley-Line Eradication", sources = { [14]=93775, [15]=93775 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Cyanigosa (boss 7). One step for the whole event: Sinclari
        -- starts it, the portal waves run on their own clock, and the two
        -- prisoner criteria hand the notes forward.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 7,
            title     = "Cyanigosa",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 168 },
                    kind            = "poi",
                    note            = "After zoning in, talk to ^Lieutenant Sinclari^ to start the sequence.",
                    minNote         = "Talk to Sinclari",
                    mapLabel        = "Talk to Sinclari",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    points          = {
                        { 0.481, 0.904 },
                    },
                },
                {
                    -- Sinclari locks the door behind her once the event
                    -- is running.
                    when        = { mapID = 168 },
                    kind        = "path",
                    note        = "Clear portals 1-6 to spawn the first ^Escaped Prisoner^ at random.",
                    minNote     = "Clear portals 1-6 for boss",
                    triggeredBy = { dialog = { npc = "Lieutenant Sinclari", match = "locking the door" } },
                    points      = { },
                },
                {
                    when        = { mapID = 168 },
                    kind        = "path",
                    note        = "Clear portals 7-12 to spawn the second ^Escaped Prisoner^ at random.",
                    minNote     = "Clear portals 7-12 for boss",
                    triggeredBy = { scenario = 24858 },
                    points      = { },
                },
                {
                    when        = { mapID = 168 },
                    kind        = "path",
                    note        = "Clear portals 13-18 to spawn the final boss, ^Cyanigosa^.",
                    minNote     = "Clear portals 13-18 for Cyanigosa",
                    triggeredBy = { scenario = 24859 },
                    points      = { },
                },
            },
        },
    },
}
