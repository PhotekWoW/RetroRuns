-------------------------------------------------------------------------------
-- RetroRuns Data -- Razorfen Downs
-- Classic dungeon, Patch 1.0  |  instanceID: 129  |  journalInstanceID: 233
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[233] = {
    kind              = "dungeon",
    instanceID        = 129,
    journalInstanceID = 233,
    name              = "Razorfen Downs",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 64,
        x     = 0.4781,
        y     = 0.2379,
    },

    trashLoot = {
        { id = 10581, slot = "Chest", name = "Death's Head Vestment", sources = { [14]=4000 }, bind = "BoE" },
        { id = 10583, slot = "Chest", name = "Quillward Harness", sources = { [14]=4002 }, bind = "BoE" },
        { id = 10582, slot = "Feet", name = "Briar Tredders", sources = { [14]=4001 }, bind = "BoE" },
        { id = 10578, slot = "Feet", name = "Thoughtcast Boots", sources = { [14]=3998 }, bind = "BoE" },
        { id = 10584, slot = "Hands", name = "Stormgale Fists", sources = { [14]=4003 }, bind = "BoE" },
        { id = 10574, slot = "Head", name = "Corpseshroud", sources = { [14]=3997 }, bind = "BoE" },
        { id = 10572, slot = "Ranged", name = "Freezing Shard", sources = { [14]=3995 }, bind = "BoE" },
        { id = 10567, slot = "Ranged", name = "Quillshooter", sources = { [14]=3991 }, bind = "BoE" },
        { id = 10573, slot = "Two-Hand", name = "Boneslasher", sources = { [14]=3996 }, bind = "BoE" },
        { id = 10570, slot = "Two-Hand", name = "Manslayer", sources = { [14]=3993 }, bind = "BoE" },
        { id = 10571, slot = "Weapon", name = "Ebony Boneclub", sources = { [14]=3994 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Aarux",
            journalEncounterID = 1142,
            aliases            = { "Aaurx" },
            achievements       = {
            },
            loot = {
                { id = 10776, slot = "Back", name = "Silky Spider Cape", sources = { [14]=4083 } },
                { id = 10775, slot = "Chest", name = "Carapace of Tuten'kash", sources = { [14]=4082 } },
                { id = 10777, slot = "Hands", name = "Arachnid Gloves", sources = { [14]=4084 } },
            },
        },
        {
            index              = 2,
            name               = "Mordresh Fire Eye",
            journalEncounterID = 433,
            achievements       = {
            },
            loot = {
                { id = 10770, slot = "Off-hand", name = "Mordresh's Lifeless Skull", sources = { [14]=4078 } },
                { id = 10771, slot = "Waist", name = "Deathmage Sash", sources = { [14]=4079 } },
            },
        },
        {
            index              = 3,
            name               = "Mushlump",
            journalEncounterID = 1143,
            achievements       = {
            },
            loot = {
                { id = 10774, slot = "Shoulder", name = "Fleshhide Shoulders", sources = { [14]=4081 } },
                { id = 10772, slot = "Weapon", name = "Glutton's Cleaver", sources = { [14]=4080 } },
            },
        },
        {
            index              = 4,
            name               = "Death Speaker Blackthorn",
            journalEncounterID = 1146,
            achievements       = {
            },
            loot = {
                { id = 151454, slot = "Feet", name = "Splinterbone Sabatons", sources = { [14]=89450 } },
                { id = 10760, slot = "Hands", name = "Swine Fists", sources = { [14]=4069 } },
                { id = 10767, slot = "Off-hand", name = "Savage Boar's Guard", sources = { [14]=4076 } },
                { id = 10766, slot = "Ranged", name = "Plaguerot Sprig", sources = { [14]=4075 } },
                { id = 10758, slot = "Two-Hand", name = "X'caliboar", sources = { [14]=4068 } },
                { id = 10768, slot = "Waist", name = "Boar Champion's Belt", sources = { [14]=4077 } },
            },
        },
        {
            index              = 5,
            name               = "Amnennar the Coldbringer",
            journalEncounterID = 1141,
            achievements       = {
            },
            loot = {
                { id = 10764, slot = "Chest", name = "Deathchill Armor", sources = { [14]=4073 } },
                { id = 10762, slot = "Chest", name = "Robes of the Lich", sources = { [14]=4071 } },
                { id = 10765, slot = "Hands", name = "Bonefingers", sources = { [14]=4074 } },
                { id = 10763, slot = "Head", name = "Icemetal Barbute", sources = { [14]=4072 } },
                { id = 10761, slot = "Weapon", name = "Coldrage Dagger", sources = { [14]=4070 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {

        -- 1. Aarux (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Aarux",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 300 },
                    kind    = "path",
                    note    = "After zoning in, stay to the left and follow the path east all the way to ^Aarux^. Click the ^Gong^ to start the fight.",
                    minNote = "East to Aarux",
                    points  = {
                        { 0.289, 0.185 },
                        { 0.327, 0.181 },
                        { 0.344, 0.199 },
                        { 0.358, 0.222 },
                        { 0.377, 0.231 },
                        { 0.397, 0.223 },
                        { 0.410, 0.197 },
                        { 0.431, 0.182 },
                        { 0.454, 0.194 },
                        { 0.456, 0.237 },
                        { 0.431, 0.269 },
                        { 0.424, 0.293 },
                        { 0.446, 0.322 },
                        { 0.503, 0.344 },
                        { 0.519, 0.304 },
                        { 0.535, 0.286 },
                        { 0.555, 0.290 },
                        { 0.573, 0.308 },
                    },
                },
                {
                    -- Noteless: takes its travel text from the path
                    -- segment above, the Uldaman altar-POI shape.
                    when        = { mapID = 300 },
                    kind        = "poi",
                    mapLabel    = "Click Gong",
                    mapLabelPos = "above",
                    points      = {
                        { 0.595, 0.277 },
                    },
                },
            },
        },

        -- 2. Mordresh Fire Eye (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Mordresh Fire Eye",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 300 },
                    kind    = "path",
                    note    = "After killing ^Aarux^, follow the path east to find ^Mordresh Fire Eye^ dancing on a large pile of bones.",
                    minNote = "East to Mordresh Fire Eye",
                    points  = {
                        { 0.620, 0.380 },
                        { 0.637, 0.410 },
                        { 0.659, 0.416 },
                        { 0.696, 0.393 },
                        { 0.783, 0.339 },
                        { 0.838, 0.381 },
                        { 0.850, 0.435 },
                    },
                },
            },
        },

        -- 3. Mushlump (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Mushlump",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 300 },
                    kind    = "path",
                    note    = "After defeating ^Mordresh Fire Eye^, follow the long path west through the ^Spiral of Thorns^ to find ^Mushlump^ patrolling around.",
                    minNote = "West to Mushlump",
                    points  = {
                        { 0.832, 0.456 },
                        { 0.784, 0.425 },
                        { 0.755, 0.437 },
                        { 0.724, 0.465 },
                        { 0.702, 0.500 },
                        { 0.668, 0.510 },
                        { 0.623, 0.504 },
                        { 0.576, 0.474 },
                        { 0.507, 0.453 },
                        { 0.438, 0.433 },
                        { 0.377, 0.469 },
                        { 0.340, 0.517 },
                        { 0.330, 0.576 },
                        { 0.339, 0.626 },
                    },
                },
            },
        },

        -- 4. Death Speaker Blackthorn (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Death Speaker Blackthorn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 300 },
                    kind    = "path",
                    note    = "After killing ^Mushlump^, continue counter-clockwise up the long spiraling path until you reach the top, where you will face ^Death Speaker Blackthorn^.",
                    minNote = "Up spiral to Death Speaker",
                    points  = {
                        { 0.373, 0.709 },
                        { 0.416, 0.764 },
                        { 0.453, 0.755 },
                        { 0.492, 0.721 },
                        { 0.520, 0.668 },
                        { 0.528, 0.585 },
                        { 0.501, 0.523 },
                        { 0.452, 0.491 },
                        { 0.409, 0.484 },
                        { 0.371, 0.520 },
                        { 0.365, 0.589 },
                        { 0.374, 0.639 },
                        { 0.402, 0.685 },
                        { 0.438, 0.688 },
                    },
                },
            },
        },

        -- 5. Amnennar the Coldbringer (boss 5). Spawns where Death Speaker
        -- Blackthorn fell, so the step carries its note without drawing a
        -- path or marker; the point anchors it to that spot.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Amnennar the Coldbringer",
            requires  = { },
            segments  = {
                {
                    when     = { mapID = 300 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "After defeating ^Death Speaker Blackthorn^, you will fight the final boss, ^Amnennar the Coldbringer^, right at the same location.",
                    minNote  = "Amnennar spawns here",
                    points   = { { 0.438, 0.688 } },
                },
            },
        },
    },
}
