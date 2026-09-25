-------------------------------------------------------------------------------
-- RetroRuns Data -- Gate of the Setting Sun
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 962  |  journalInstanceID: 303
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[303] = {
    kind              = "dungeon",
    instanceID        = 962,
    journalInstanceID = 303,
    name              = "Gate of the Setting Sun",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",
    timewalking       = true,

    entrance = {
        mapID = 422,
        x     = 0.7584,
        y     = 0.2009,
    },

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Saboteur Kip'tilak",
            journalEncounterID = 655,
            dungeonEncounterID = 1397,
            achievements       = {
                { id = 6479, name = "Bomberman", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144018, slot = "Head", name = "Fallout-Filtering Hood", sources = { [14]=84353, [15]=84353 } },
                { id = 144134, slot = "Waist", name = "Grenadier's Belt", sources = { [14]=84425, [15]=84425 } },
                { id = 144100, slot = "Wrist", name = "Saboteur's Stabilizing Bracers", sources = { [14]=84406, [15]=84406 } },
            },
        },
        {
            index              = 2,
            name               = "Striker Ga'dok",
            journalEncounterID = 675,
            dungeonEncounterID = 1405,
            achievements       = {
            },
            loot = {
                { id = 143983, slot = "Feet", name = "Airstream Treads", sources = { [14]=84318, [15]=84318 } },
                { id = 144137, slot = "Hands", name = "Bomber's Precision Gloves", sources = { [14]=84426, [15]=84426 } },
                { id = 143980, slot = "Shoulder", name = "Acid-Scarred Spaulders", sources = { [14]=84315, [15]=84315 } },
                { id = 144095, slot = "Waist", name = "Impaler's Girdle", sources = { [14]=84401, [15]=84401 } },
            },
        },
        {
            index              = 3,
            name               = "Commander Ri'mok",
            journalEncounterID = 676,
            dungeonEncounterID = 1406,
            achievements       = {
                { id = 6715, name = "Polyformic Acid Science", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144019, slot = "Head", name = "Swarmcall Helm", sources = { [14]=84354, [15]=84354 } },
                { id = 143982, slot = "Legs", name = "Leggings of the Frenzy", sources = { [14]=84317, [15]=84317 } },
                { id = 144098, slot = "Weapon", name = "Mantid Trochanter", sources = { [14]=84404, [15]=84404 } },
                { id = 144138, slot = "Wrist", name = "Ri'mok's Shattered Scale", sources = { [14]=84427, [15]=84427 } },
            },
        },
        {
            index              = 4,
            name               = "Raigonn",
            journalEncounterID = 649,
            dungeonEncounterID = 1419,
            achievements       = {
                { id = 6945, name = "Mantid Swarm", soloable = "yes" },
                { id = 6476, name = "Conscriptinator", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144141, slot = "Back", name = "Drape of the Screeching Swarm", sources = { [14]=84429, [15]=84429 } },
                { id = 143955, slot = "Chest", name = "Swarmbringer Chestguard", sources = { [14]=84290, [15]=84290 } },
                { id = 143984, slot = "Feet", name = "Treads of Fixation", sources = { [14]=84319, [15]=84319 } },
                { id = 144105, slot = "Hands", name = "Hive Protector's Gauntlets", sources = { [14]=84410, [15]=84410 } },
                { id = 143977, slot = "Legs", name = "Wall-Breaker Legguards", sources = { [14]=84312, [15]=84312 } },
                { id = 144140, slot = "Off-hand", name = "Impervious Carapace", sources = { [14]=84428, [15]=84428 } },
                { id = 144104, slot = "Off-hand", name = "Shield of the Protectorate", sources = { [14]=84409, [15]=84409 } },
                { id = 144218, slot = "Ranged", name = "Klatith, Fangs of the Swarm", sources = { [14]=84486, [15]=84486 } },
                { id = 143991, slot = "Shoulder", name = "Shoulders of Engulfing Winds", sources = { [14]=84326, [15]=84326 } },
                { id = 144101, slot = "Weapon", name = "Carapace Breaker", sources = { [14]=84407, [15]=84407 } },
                { id = 144142, slot = "Wrist", name = "Frenzyswarm Bracers", sources = { [14]=84430, [15]=84430 } },
            },
        },
    },

    exitNote    = "Exit portal to the east",
    minExitNote = "Exit portal to the east",

    routing = {
        -- 1. Saboteur Kip'tilak (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Saboteur Kip'tilak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 437 },
                    kind    = "path",
                    note    = "After zoning in, follow the path straight ahead to find ^Saboteur Kip'tilak^ flying around inside the first building.",
                    minNote = "Ahead to Kip'tilak",
                    points  = {
                        { 0.592, 0.879 },
                        { 0.484, 0.880 },
                    },
                },
            },
        },
        -- 2. Striker Ga'dok (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Striker Ga'dok",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 437 },
                    kind    = "path",
                    note    = "After defeating ^Saboteur Kip'tilak^, continue on the linear path until you arrive at an elevator inside of a building. Click the ^Lever^ to take the elevator up.",
                    minNote = "Path to elevator",
                    points  = {
                        { 0.461, 0.843 },
                        { 0.461, 0.752 },
                        { 0.413, 0.752 },
                        { 0.413, 0.680 },
                        { 0.413, 0.452 },
                        { 0.462, 0.451 },
                        { 0.462, 0.356 },
                    },
                },
                {
                    when        = { mapID = 437 },
                    kind        = "poi",
                    mapLabel    = "Click Lever",
                    mapLabelPos = "right",
                    points      = {
                        { 0.472, 0.326 },
                    },
                },
                {
                    when     = { mapID = 438 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "When you reach the top of the elevator, you'll find ^Striker Ga'dok^ on the north side of the platform.",
                    minNote  = "Kill Striker Ga'dok",
                    points   = {
                        { 0.491, 0.310 },
                    },
                },
            },
        },
        -- 3. Commander Ri'mok (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Commander Ri'mok",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 438 },
                    kind        = "poi",
                    note        = "After defeating ^Striker Ga'dok^, click the nearby ^Lever^ to return to the lower floor.",
                    minNote     = "Click nearby lever",
                    mapLabel    = "Click Lever",
                    mapLabelPos = "above",
                    points      = {
                        { 0.529, 0.516 },
                    },
                },
                {
                    when            = { mapID = 437 },
                    kind            = "poi",
                    note            = "At the bottom of the elevator, go north to reach the ^Signal Flame^. Click it to trigger a cutscene.",
                    minNote         = "North to Signal Flame",
                    mapLabel        = "Click Signal Flame",
                    mapLabelPos     = "upper-left",
                    highlightCircle = true,
                    completionCheck = true,
                    points          = {
                        { 0.480, 0.116 },
                    },
                },
                {
                    when        = { mapID = 437 },
                    kind        = "path",
                    triggeredBy = { dialog = { npc = "Commander Ri'mok", match = "The gates are about to fall" } },
                    note        = "After the cutscene, backtrack south and you'll run right into ^Commander Ri'mok^.",
                    minNote     = "South to Commander Ri'mok",
                    points      = { },
                },
            },
        },
        -- 4. Raigonn (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Raigonn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 437 },
                    kind    = "path",
                    note    = "After killing ^Commander Ri'mok^, go south and jump carefully down into the main pit to reach ^Raigonn^.",
                    minNote = "South then jump down to Raigonn",
                    points  = {
                        { 0.461, 0.282 },
                        { 0.463, 0.463 },
                        { 0.477, 0.506 },
                        { 0.477, 0.580 },
                        { 0.463, 0.592 },
                    },
                },
            },
        },
    },
}
