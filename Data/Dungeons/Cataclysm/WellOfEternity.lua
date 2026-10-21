-------------------------------------------------------------------------------
-- RetroRuns Data -- Well of Eternity
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.3.0  |  instanceID: 939  |  journalInstanceID: 185
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[185] = {
    kind              = "dungeon",
    instanceID        = 939,
    journalInstanceID = 185,
    name              = "Well of Eternity",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 15 },
    patch             = "4.3.0",
    routedIn          = "3.3.7",

    entrance = {
        mapID = 75,
        x     = 0.2187,
        y     = 0.6415,
    },

    trashLoot = {
        { id = 76158, slot = "Feet", name = "Courtier's Slippers", sources = { [15]=38416 }, bind = "BoE" },
        { id = 76157, slot = "Hands", name = "Waterworn Handguards", sources = { [15]=38415 }, bind = "BoE" },
        { id = 76159, slot = "Wrist", name = "Legion Bindings", sources = { [15]=38417 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Peroth'arn",
            journalEncounterID = 290,
            dungeonEncounterID = 1272,
            achievements       = {
                { id = 6127, name = "Lazy Eye", soloable = "yes" },
            },
            loot = {
                { id = 72829, slot = "Off-hand", name = "Orb of the First Satyrs", sources = { [15]=37309 } },
                { id = 72832, slot = "Waist", name = "Girdle of the Queen's Champion", sources = { [15]=37311 } },
                { id = 72830, slot = "Waist", name = "Peroth'arn's Belt", sources = { [15]=37310 } },
                { id = 72827, slot = "Weapon", name = "Gavel of Peroth'arn", sources = { [15]=37307 } },
                { id = 72828, slot = "Weapon", name = "Trickster's Edge", sources = { [15]=37308 } },
            },
        },
        {
            index              = 2,
            name               = "Queen Azshara",
            journalEncounterID = 291,
            dungeonEncounterID = 1273,
            soloTip            = "After a brief dialog, ^Azshara^ will activate her ^Enchanted Magi^ two at a time. Kill each of them as they activate.",
            achievements       = {
            },
            loot = {
                { id = 72838, slot = "Back", name = "Cloak of the Royal Protector", sources = { [15]=37316 } },
                { id = 72834, slot = "Chest", name = "Breastplate of the Queen's Guard", sources = { [15]=37313 } },
                { id = 72836, slot = "Feet", name = "Slippers of Wizardry", sources = { [15]=37315 } },
                { id = 72835, slot = "Legs", name = "Puppeteer's Pantaloons", sources = { [15]=37314 } },
                { id = 72833, slot = "Weapon", name = "Scepter of Azshara", sources = { [15]=37312 } },
            },
        },
        {
            index              = 3,
            name               = "Mannoroth and Varo'then",
            journalEncounterID = 292,
            dungeonEncounterID = 1274,
            -- "Mannoroth defeated", the encounter's end; "Varo'then defeated"
            -- (24839) falls mid-fight and stays unbound.
            scenarioCriteriaID = 24840,
            aliases            = { "Mannoroth" },
            achievements       = {
                { id = 6070, name = "That's Not Canon!", soloable = "yes" },
            },
            loot = {
                { id = 72841, slot = "Chest", name = "Demonsbane Chestguard", sources = { [15]=37319 } },
                { id = 72842, slot = "Head", name = "Annihilan Helm", sources = { [15]=37320 } },
                { id = 72839, slot = "Head", name = "Cowl of Highborne Sorcerers", sources = { [15]=37317 } },
                { id = 72843, slot = "Head", name = "Helm of Power", sources = { [15]=37321 } },
                { id = 72847, slot = "Head", name = "Helm of Thorns", sources = { [15]=37324 } },
                { id = 72848, slot = "Legs", name = "Legguards of the Legion", sources = { [15]=37325 } },
                { id = 72840, slot = "Shoulder", name = "Spaulders of Eternity", sources = { [15]=37318 } },
                { id = 72844, slot = "Two-Hand", name = "Pit Lord's Destroyer", sources = { [15]=37322 } },
                { id = 72846, slot = "Two-Hand", name = "Thornwood Staff", sources = { [15]=37323 } },
            },
        },
    },

    exitNote    = "After some dialog, you can talk to Chromie to be teleported to Hour of Twilight then zone out. Or, you can backtrack south to a Time Transit Device and teleport to the entrance.",
    minExitNote = "Chromie exit or teleporter to south",

    routing = {
        -- 1. Peroth'arn (boss 1). Illidan's line after the talk opens the
        -- way to the first portal.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Peroth'arn",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 398 },
                    kind            = "poi",
                    poiKind         = "talk",
                    note            = "After zoning in, move ahead for a brief dialog then kill the ^Legion Demon^ to open the path. Talk to ^Illidan Stormrage^ to start an escort.",
                    minNote         = "Ahead to Illidan for escort",
                    mapLabel        = "Talk to Illidan",
                    completionCheck = true,
                    points          = {
                        { 0.186, 0.686 },
                    },
                },
                {
                    when            = { mapID = 398 },
                    kind            = "poi",
                    note            = "After ^Illidan^ opens the way for you, go east and disable ^Portal 1^ by clicking on the ^Portal Energy Focus^.",
                    minNote         = "East to disable Portal 1",
                    triggeredBy     = { dialog = { npc = "Illidan Stormrage", match = "live long enough to see me save this world" } },
                    drawWhenOpen    = true,
                    noMarker        = true,
                    highlightCircle = true,
                    completionCheck = true,
                    points          = {
                        { 0.274, 0.573 },
                    },
                },
                {
                    -- Opens on "First Portal disabled".
                    when            = { mapID = 398 },
                    kind            = "poi",
                    note            = "Follow ^Illidan^ north to disable ^Portal 2^. If he bugs out, suicide by walking into the demons, then come back and talk to him again.",
                    minNote         = "North to disable Portal 2",
                    triggeredBy     = { scenario = 24834 },
                    drawWhenOpen    = true,
                    noMarker        = true,
                    highlightCircle = true,
                    completionCheck = true,
                    points          = {
                        { 0.184, 0.377 },
                    },
                },
                {
                    -- Opens on "Second Portal disabled".
                    when            = { mapID = 398 },
                    kind            = "poi",
                    note            = "With the first two portals disabled, follow ^Illidan^ to the stairwell on the northwest side of the room. Work your way to ^Portal 3^ and disable it.",
                    minNote         = "Northwest stairs to disable Portal 3",
                    triggeredBy     = { scenario = 24835 },
                    drawWhenOpen    = true,
                    noMarker        = true,
                    highlightCircle = true,
                    completionCheck = true,
                    points          = {
                        { 0.161, 0.345 },
                    },
                },
                {
                    -- Opens on "Third Portal disabled".
                    when         = { mapID = 398 },
                    kind         = "path",
                    note         = "After disabling ^Portal 3^, backtrack to the main courtyard to defeat ^Peroth'arn^.",
                    minNote      = "Backtrack to courtyard for Peroth'arn",
                    triggeredBy  = { scenario = 24836 },
                    drawWhenOpen = true,
                    points       = {
                        { 0.138, 0.362 },
                        { 0.097, 0.401 },
                        { 0.090, 0.445 },
                        { 0.134, 0.469 },
                        { 0.209, 0.500 },
                    },
                },
            },
        },
        -- 2. Queen Azshara (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Queen Azshara",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 398 },
                    kind    = "path",
                    note    = "After killing ^Peroth'arn^, follow the path up the eastern stairwell until you reach ^Queen Azshara^.",
                    minNote = "Eastern stairs to Queen Azshara",
                    points  = {
                        { 0.271, 0.440 },
                        { 0.344, 0.374 },
                        { 0.314, 0.292 },
                        { 0.317, 0.244 },
                        { 0.336, 0.208 },
                        { 0.366, 0.195 },
                        { 0.400, 0.206 },
                        { 0.417, 0.227 },
                        { 0.446, 0.299 },
                        { 0.454, 0.334 },
                    },
                },
            },
        },
        -- 3. Mannoroth and Varo'then (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Mannoroth and Varo'then",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 398 },
                    kind            = "poi",
                    note            = "After defeating the ^Queen Azshara^ encounter, watch a brief dialog then click a nearby ^Bronze Drake^ to be flown to the next area.",
                    minNote         = "Use Bronze Drake",
                    mapLabel        = "Use Bronze Drake",
                    completionCheck = true,
                    points          = {
                        { 0.506, 0.384 },
                    },
                },
                {
                    -- The drake is a vehicle: this opens on boarding.
                    when        = { mapID = 398 },
                    kind        = "path",
                    note        = "You will watch a lengthy dialog from your drake. After you land, move ahead to engage the trash. They will all run towards the group of NPCs to be eliminated.",
                    minNote     = "Dialog, land, then trash",
                    triggeredBy = { vehicle = true },
                    points      = { },
                },
                {
                    when         = { mapID = 398 },
                    kind         = "path",
                    note         = "With the trash dead, your group can head north to the final boss. Kill several enemies on the way, including mini-boss ^Captain Varo'then^, then you can kill ^Mannoroth^.",
                    minNote      = "North to Mannoroth",
                    triggeredBy  = { dialog = { npc = "Illidan Stormrage", match = "Hardly worthy of being called a legion" } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.743, 0.722 },
                        { 0.817, 0.673 },
                        { 0.840, 0.629 },
                        { 0.842, 0.570 },
                        { 0.857, 0.531 },
                    },
                },
            },
        },
    },
}
