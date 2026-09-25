-------------------------------------------------------------------------------
-- RetroRuns Data -- Old Hillsbrad Foothills
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 560  |  journalInstanceID: 251
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[251] = {
    kind              = "dungeon",
    instanceID        = 560,
    journalInstanceID = 251,
    name              = "Old Hillsbrad Foothills",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.2.0",

    entrance = {
        mapID = 75,
        x     = 0.2680,
        y     = 0.3440,
    },

    bosses = {
        {
            index              = 1,
            name               = "Lieutenant Drake",
            journalEncounterID = 538,
            dungeonEncounterID = 1905,
            achievements       = {
            },
            loot = {
                { id = 27423, slot = "Back", name = "Cloak of Impulsiveness", sources = { [14]=11889, [15]=11889 } },
                { id = 27420, slot = "Feet", name = "Uther's Ceremonial Warboots", sources = { [14]=11888, [15]=11888 } },
                { id = 28214, slot = "Hands", name = "Grips of the Lunar Eclipse", sources = { [14]=12334, [15]=12334 } },
                { id = 28215, slot = "Head", name = "Mok'Nathal Mask of Battle", sources = { [14]=12335, [15]=12335 } },
                { id = 28212, slot = "Legs", name = "Aran's Sorcerous Slacks", sources = { [14]=12332, [15]=12332 } },
                { id = 27418, slot = "Legs", name = "Stormreaver Shadow-Kilt", sources = { [14]=11887, [15]=11887 } },
                { id = 28213, slot = "Off-hand", name = "Lordaeron Medical Guide", sources = { [14]=12333, [15]=12333 } },
                { id = 27417, slot = "Shoulder", name = "Ravenwing Pauldrons", sources = { [14]=11886, [15]=11886 } },
                { id = 28210, slot = "Weapon", name = "Bloodskull Destroyer", sources = { [14]=12331, [15]=12331 } },
            },
        },
        {
            index              = 2,
            name               = "Captain Skarloc",
            journalEncounterID = 539,
            dungeonEncounterID = 1907,
            achievements       = {
            },
            loot = {
                { id = 27427, slot = "Chest", name = "Durotan's Battle Harness", sources = { [14]=11892, [15]=11892 } },
                { id = 28221, slot = "Feet", name = "Boots of the Watchful Heart", sources = { [14]=12340, [15]=12340 } },
                { id = 27428, slot = "Hands", name = "Stormfront Gauntlets", sources = { [14]=11893, [15]=11893 } },
                { id = 28220, slot = "Head", name = "Moon-Crown Antlers", sources = { [14]=12339, [15]=12339 } },
                { id = 28219, slot = "Legs", name = "Emerald-Scale Greaves", sources = { [14]=12338, [15]=12338 } },
                { id = 28218, slot = "Legs", name = "Pontiff's Pantaloons of Prophecy", sources = { [14]=12337, [15]=12337 } },
                { id = 27430, slot = "Legs", name = "Scaled Greaves of Patience", sources = { [14]=11894, [15]=11894 } },
                { id = 27424, slot = "Weapon", name = "Amani Venom-Axe", sources = { [14]=11890, [15]=11890 } },
                { id = 28216, slot = "Weapon", name = "Dathrohan's Ceremonial Hammer", sources = { [14]=12336, [15]=12336 } },
                { id = 27426, slot = "Weapon", name = "Northshire Battlemace", sources = { [14]=11891, [15]=11891 } },
            },
        },
        {
            index              = 3,
            name               = "Epoch Hunter",
            journalEncounterID = 540,
            dungeonEncounterID = 1906,
            achievements       = {
            },
            loot = {
                { id = 28401, slot = "Chest", name = "Hauberk of Desolation", sources = { [14]=12446, [15]=12446 }, setName = "Desolation Battlegear", dungeonSet = 3 },
                { id = 28191, slot = "Chest", name = "Mana-Etched Vestments", sources = { [14]=12313, [15]=12313 } },
                { id = 28225, slot = "Head", name = "Doomplate Warhelm", sources = { [14]=12343, [15]=12343 }, setName = "Doomplate Battlegear", dungeonSet = 3 },
                { id = 28224, slot = "Head", name = "Wastewalker Helm", sources = { [14]=12342, [15]=12342 }, setName = "Wastewalker Armor", dungeonSet = 3 },
                { id = 30536, slot = "Legs", name = "Greaves of the Martyr", sources = { [14]=13809, [15]=13809 } },
                { id = 30534, slot = "Legs", name = "Wyrmscale Greaves", sources = { [14]=13807, [15]=13807 } },
                { id = 27434, slot = "Shoulder", name = "Mantle of Perenolde", sources = { [14]=11897, [15]=11897 } },
                { id = 27433, slot = "Shoulder", name = "Pauldrons of Sufferance", sources = { [14]=11896, [15]=11896 } },
                { id = 28344, slot = "Shoulder", name = "Wyrmfury Pauldrons", sources = { [14]=12412, [15]=12412 } },
                { id = 28222, slot = "Two-Hand", name = "Reaver of the Infinites", sources = { [14]=12341, [15]=12341 } },
                { id = 29250, slot = "Waist", name = "Cord of Sanctification", sources = { [14]=13045, [15]=13045 } },
                { id = 27911, slot = "Waist", name = "Epoch's Whispering Cinch", sources = { [14]=12149, [15]=12149 } },
                { id = 27431, slot = "Weapon", name = "Time-Shifted Dagger", sources = { [14]=11895, [15]=11895 } },
                { id = 28226, slot = "Weapon", name = "Timeslicer", sources = { [14]=12344, [15]=12344 } },
                { id = 29246, slot = "Wrist", name = "Nightfall Wristguards", sources = { [14]=13041, [15]=13041 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Lieutenant Drake (boss 1). Erozion hands over the bombs, Brazen
        -- flies the player to the keep, five barrels light the lodges, and
        -- Drake's yell on the fifth opens the hunt.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Lieutenant Drake",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 274 },
                    kind            = "poi",
                    note            = "After zoning in, move forward and talk to ^Erozion^ to receive ^Pack of Incendiary Bombs^.",
                    minNote         = "Get bombs from Erozion",
                    mapLabel        = "Get Bombs from Erozion",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    points          = {
                        { 0.297, 0.486 },
                    },
                },
                {
                    -- The bombs landing in the bags open the flight.
                    when        = { mapID = 274 },
                    kind        = "path",
                    note        = "Once you've picked up the bombs, talk to ^Brazen^ to be flown towards ^Durnholde Keep^.",
                    minNote     = "Fly on Brazen",
                    triggeredBy = { item = 25853 },
                    points      = { },
                },
                {
                    -- One marker per lodge, at the building's center: the
                    -- barrel moves within it between runs. Brazen's flight
                    -- landing is what brings this seg forward.
                    when            = { mapID = 274 },
                    kind            = "poi",
                    note            = "After you land, go through the archway and jump down into the internment camp. Your goal is to place a bomb inside each of the five buildings by interacting with the ^Barrel^ within.",
                    minNote         = "Place bomb inside 5 buildings",
                    mapLabel        = "Place Bombs",
                    mapLabelPos     = "lower-right",
                    triggeredBy     = { taxi = true },
                    markAllPoints   = true,
                    poiIcon         = "Interface\\GossipFrame\\AvailableQuestIcon",
                    poiSize         = 18,
                    completionCheck = true,
                    points          = {
                        { 0.772, 0.668 },
                        { 0.765, 0.689 },
                        { 0.747, 0.682 },
                        { 0.692, 0.625 },
                        { 0.687, 0.577 },
                    },
                },
                {
                    when        = { mapID = 274 },
                    kind        = "path",
                    note        = "After the fifth ^Barrel^, the buildings will light on fire and ^Lieutenant Drake^ will spawn and begin to patrol the area. Find and kill him.",
                    minNote     = "Find and kill Lieutenant Drake",
                    triggeredBy = { dialog = { npc = "Lieutenant Drake", match = "fetch water quickly" } },
                    points      = { },
                },
            },
        },
        -- 2. Captain Skarloc (boss 2). Thrall's line starts the escort.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Captain Skarloc",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 274 },
                    kind            = "poi",
                    note            = "After killing ^Lieutenant Drake^, take the northeast stairs out of the internment camp and head into ^Durnholde Keep^.  Inside the keep, go downstairs and talk to ^Thrall^ to begin an escort.",
                    minNote         = "Inside keep to Thrall",
                    mapLabel        = "Begin Thrall Escort",
                    mapLabelPos     = "right",
                    poiSize         = 18,
                    completionCheck = true,
                    points          = {
                        { 0.736, 0.572 },
                    },
                },
                {
                    when        = { mapID = 274 },
                    kind        = "path",
                    note        = "Escort ^Thrall^ to collect his gear, and then outside to face ^Captain Skarloc^.",
                    minNote     = "Escort Thrall to Captain Skarloc",
                    triggeredBy = { dialog = { npc = "Thrall", match = "Very well then" } },
                    points      = { },
                },
            },
        },
        -- 3. Epoch Hunter (boss 3). Thrall's second line starts the walk
        -- to Tarren Mill.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Epoch Hunter",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 274 },
                    kind            = "poi",
                    note            = "After defeating ^Captain Skarloc^, talk to ^Thrall^ to begin the next escort.",
                    minNote         = "Talk to Thrall",
                    mapLabel        = "Begin Thrall Escort",
                    mapLabelPos     = "above",
                    poiSize         = 18,
                    completionCheck = true,
                    points          = {
                        { 0.703, 0.690 },
                    },
                },
                {
                    when        = { mapID = 274 },
                    kind        = "path",
                    note        = "The rest of the dungeon is one long escort as ^Thrall^ searches the town for ^Taretha^. Continue following him and you will eventually be confronted by the final boss, ^Epoch Hunter^.",
                    minNote     = "Continue escort until Epoch Hunter",
                    triggeredBy = { dialog = { npc = "Thrall", match = "Tarren Mill lies just west" } },
                    points      = { },
                },
            },
        },
    },
}
