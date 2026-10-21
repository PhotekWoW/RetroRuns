-------------------------------------------------------------------------------
-- RetroRuns Data -- Hour of Twilight
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.3.0  |  instanceID: 940  |  journalInstanceID: 186
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[186] = {
    kind              = "dungeon",
    instanceID        = 940,
    journalInstanceID = 186,
    name              = "Hour of Twilight",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 15 },
    patch             = "4.3.0",
    routedIn          = "3.3.7",

    entrance = {
        mapID = 75,
        x     = 0.6784,
        y     = 0.2885,
    },

    trashLoot = {
        { id = 76160, slot = "Back", name = "Drapes of the Dragonshrine", sources = { [15]=38418 }, bind = "BoE" },
        { id = 76161, slot = "Hands", name = "Gauntlets of the Twilight Hour", sources = { [15]=38419 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Arcurion",
            journalEncounterID = 322,
            dungeonEncounterID = 1337,
            achievements       = {
            },
            loot = {
                { id = 72854, slot = "Back", name = "Iceward Cloak", sources = { [15]=37331 } },
                { id = 72850, slot = "Feet", name = "Surestride Boots", sources = { [15]=37327 } },
                { id = 72849, slot = "Feet", name = "Wayfinder Boots", sources = { [15]=37326 } },
                { id = 72853, slot = "Legs", name = "Arcurion Legguards", sources = { [15]=37330 } },
                { id = 72851, slot = "Waist", name = "Chillbane Belt", sources = { [15]=37328 } },
                { id = 76150, slot = "Wrist", name = "Evergreen Wristbands", sources = { [15]=38409 } },
            },
        },
        {
            index              = 2,
            name               = "Asira Dawnslayer",
            journalEncounterID = 342,
            dungeonEncounterID = 1340,
            achievements       = {
            },
            loot = {
                { id = 76151, slot = "Back", name = "Cloak of Subtle Light", sources = { [15]=38410 } },
                { id = 157616, slot = "Chest", name = "Chestguard of Futility", sources = { [15]=93802 } },
                { id = 72859, slot = "Head", name = "Dawnslayer Helm", sources = { [15]=37336 } },
                { id = 72857, slot = "Legs", name = "Leggings of Blinding Speed", sources = { [15]=37334 } },
                { id = 72855, slot = "Off-hand", name = "Corrupted Carapace", sources = { [15]=37332 } },
                { id = 72856, slot = "Shoulder", name = "Pauldrons of Midnight Whispers", sources = { [15]=37333 } },
                { id = 72860, slot = "Weapon", name = "Mandible of the Old Ones", sources = { [15]=37337 } },
            },
        },
        {
            index              = 3,
            name               = "Archbishop Benedictus",
            journalEncounterID = 341,
            dungeonEncounterID = 1339,
            achievements       = {
                { id = 6132, name = "Eclipse", soloable = "yes" },
            },
            loot = {
                { id = 72869, slot = "Ranged", name = "Dragonsmaw Blaster", sources = { [15]=37346 } },
                { id = 72870, slot = "Shoulder", name = "Betrayer's Pauldrons", sources = { [15]=37347 } },
                { id = 72868, slot = "Shoulder", name = "Desecrated Shoulderguards", sources = { [15]=37345 } },
                { id = 72865, slot = "Shoulder", name = "Mantle of False Virtue", sources = { [15]=37342 } },
                { id = 72864, slot = "Shoulder", name = "Pauldrons of Conviction", sources = { [15]=37341 } },
                { id = 72861, slot = "Shoulder", name = "Pauldrons of the Dragonblight", sources = { [15]=37338 } },
                { id = 72863, slot = "Two-Hand", name = "Stalk of Corruption", sources = { [15]=37340 } },
                { id = 72867, slot = "Weapon", name = "Clattering Claw", sources = { [15]=37344 } },
                { id = 72862, slot = "Weapon", name = "Fanged Tentacle", sources = { [15]=37339 } },
                { id = 72866, slot = "Weapon", name = "Treachery's Bite", sources = { [15]=37343 } },
            },
        },
    },

    exitNote    = "There is a portal to Stormwind / Orgrimmar behind the boss. There is no shortcut to exit the dungeon.",
    minExitNote = "Stormwind / Orgrimmar portal otherwise N/A",

    routing = {
        -- 1. Arcurion (boss 1). Thrall's line after the talk starts the escort.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Arcurion",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 399 },
                    kind            = "poi",
                    poiKind         = "talk",
                    note            = "After zoning in, talk to ^Thrall^ to begin his escort.",
                    minNote         = "Talk to Thrall for escort",
                    mapLabel        = "Talk to Thrall",
                    completionCheck = true,
                    points          = {
                        { 0.499, 0.194 },
                    },
                },
                {
                    when        = { mapID = 399 },
                    kind        = "path",
                    note        = "Escort ^Thrall^ through the canyon, killing several packs of enemies along the way. When he stops at the checkpoint, talk to him again and approach ^Arcurion^.",
                    minNote     = "Escort Thrall to Arcurion",
                    triggeredBy = { dialog = { npc = "Thrall", match = "The Aspects await us within Wyrmrest" } },
                    points      = { },
                },
            },
        },
        -- 2. Asira Dawnslayer (boss 2). Thrall's line after the talk resumes
        -- the escort.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Asira Dawnslayer",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 399 },
                    kind            = "poi",
                    poiKind         = "talk",
                    note            = "After killing ^Arcurion^, follow ^Thrall^ through a short sequence where he destroys the wall. When you can, talk to him to begin the next phase of the escort.",
                    minNote         = "Talk to Thrall for escort",
                    mapLabel        = "Talk to Thrall",
                    completionCheck = true,
                    points          = {
                        { 0.575, 0.279 },
                    },
                },
                {
                    when        = { mapID = 399 },
                    kind        = "path",
                    note        = "Escort ^Thrall^ to the southwest. After he stops at the checkpoint, talk to him again and continue the escort all the way to ^Asira Dawnslayer^.",
                    minNote     = "Escort Thrall to Asira Dawnslayer",
                    triggeredBy = { dialog = { npc = "Thrall", match = "Follow me." } },
                    points      = { },
                },
            },
        },
        -- 3. Archbishop Benedictus (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Archbishop Benedictus",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 399 },
                    kind            = "poi",
                    note            = "After defeating ^Asira Dawnslayer^, there will be a brief dialog then ^Thrall^ will fly away. A few moments later, a group of dragons will approach. Click on a ^Life Warden^ to be flown to the next area.",
                    minNote         = "Fly on Life Warden",
                    mapLabel        = "Fly on Life Warden",
                    completionCheck = true,
                    points          = {
                        { 0.398, 0.498 },
                    },
                },
                {
                    -- The Life Warden is a vehicle: this opens on boarding.
                    when            = { mapID = 399 },
                    kind            = "poi",
                    poiKind         = "talk",
                    note            = "After this short flight, you will land near ^Thrall^. Talk to him to begin the approach to the final boss.",
                    minNote         = "Talk to Thrall after landing",
                    mapLabel        = "Talk to Thrall",
                    triggeredBy     = { vehicle = true },
                    drawWhenOpen    = true,
                    completionCheck = true,
                    points          = {
                        { 0.498, 0.671 },
                    },
                },
                {
                    when        = { mapID = 399 },
                    kind        = "path",
                    note        = "Escort ^Thrall^ and friends all the way to ^Archbishop Benedictus^. You must kill all enemies to keep the escort moving.",
                    minNote     = "Escort Thrall to Archbishop",
                    triggeredBy = { dialog = { npc = "Dark Haze", match = "Spawn of the Old Gods materialize nearby" } },
                    points      = { },
                },
            },
        },
    },
}
