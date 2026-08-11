-------------------------------------------------------------------------------
-- RetroRuns Data -- The Battle for Mount Hyjal
-- Burning Crusade, Patch 2.1.0  |  instanceID: 534  |  journalInstanceID: 750
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[534] = {
    instanceID        = 534,
    journalInstanceID = 750,
    name              = "The Battle for Mount Hyjal",
    expansion         = "Burning Crusade",
    patch             = "2.1.0",

    exitNote          = "None available",

    -- The raid runs at 25-player only. One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Caverns of Time, at the Hyjal portal. Same handling as Dragon
        -- Soul: the coordinate is the portal itself, so a routing addon
        -- walks the player all the way down rather than stopping at the
        -- cavern mouth in Tanaris.
        mapID = 75, x = 0.352, y = 0.153,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [329] = "Hyjal Summit",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [31092] = 4,   -- Gloves of the Forgotten Conqueror
            [31093] = 4,   -- Gloves of the Forgotten Vanquisher
            [31094] = 4,   -- Gloves of the Forgotten Protector
            [31095] = 5,   -- Helm of the Forgotten Protector
            [31096] = 5,   -- Helm of the Forgotten Vanquisher
            [31097] = 5,   -- Helm of the Forgotten Conqueror
        },
    },


    -- Trash drops. The Encounter Journal indexes boss loot only,
    -- so these carry no journal rows and belong to no encounter.
    trashLoot = {
        { id = 32590, slot = "Back", name = "Nethervoid Cloak", sources = { [14]=15043 }, bind = "BoP" },
        { id = 34010, slot = "Back", name = "Pepe's Shroud of Pacification", sources = { [14]=15732 }, bind = "BoP" },
        { id = 32592, slot = "Chest", name = "Chestguard of Relentless Storms", sources = { [14]=15044 }, bind = "BoP" },
        { id = 32609, slot = "Feet", name = "Boots of the Divine Light", sources = { [14]=15053 }, bind = "BoP" },
        { id = 32946, slot = "Weapon", name = "Claw of Molten Fury", sources = { [14]=15196 }, bind = "BoP" },
        { id = 32945, slot = "Weapon", name = "Fist of Molten Fury", sources = { [14]=15195 }, bind = "BoP" },
        { id = 34009, slot = "Weapon", name = "Hammer of Judgment", sources = { [14]=15731 }, bind = "BoP" },
    },
    bosses = {
        {
            index              = 1,
            name               = "Rage Winterchill",
            journalEncounterID = 1577,
            soloTip            = "Kill (8) waves of trash and the boss will come.",
            achievements       = {},
            loot = {
                { id = 30873, slot = "Feet", name = "Stillwater Boots", sources = { [14]=13950 } },
                { id = 30872, slot = "Held In Off-hand", name = "Chronicle of Dark Secrets", sources = { [14]=13949 } },
                { id = 30866, slot = "Shoulder", name = "Blood-Stained Pauldrons", sources = { [14]=13944 } },
                { id = 30865, slot = "Weapon", name = "Tracker's Blade", sources = { [14]=13943 } },
                { id = 30862, slot = "Wrist", name = "Blessed Adamantite Bracers", sources = { [14]=13940 } },
                { id = 30871, slot = "Wrist", name = "Bracers of Martyrdom", sources = { [14]=13948 } },
                { id = 30864, slot = "Wrist", name = "Bracers of the Pathfinder", sources = { [14]=13942 } },
                { id = 30870, slot = "Wrist", name = "Cuffs of Devastation", sources = { [14]=13947 } },
                { id = 30863, slot = "Wrist", name = "Deadly Cuffs", sources = { [14]=13941 } },
                { id = 30861, slot = "Wrist", name = "Furious Shackles", sources = { [14]=13939 } },
                { id = 30869, slot = "Wrist", name = "Howling Wind Bracers", sources = { [14]=13946 } },
                { id = 30868, slot = "Wrist", name = "Rejuvenating Bracers", sources = { [14]=13945 } },
            },
        },
        {
            index              = 2,
            name               = "Anetheron",
            journalEncounterID = 1578,
            soloTip            = "Kill (8) waves of trash and the boss will come.",
            achievements       = {},
            loot = {
                { id = 30887, slot = "Chest", name = "Golden Links of Restoration", sources = { [14]=13961 } },
                { id = 30885, slot = "Feet", name = "Archbishop's Slippers", sources = { [14]=13959 } },
                { id = 30886, slot = "Feet", name = "Enchanted Leather Sandals", sources = { [14]=13960 } },
                { id = 30880, slot = "Feet", name = "Quickstrider Moccasins", sources = { [14]=13954 } },
                { id = 30882, slot = "Off-hand", name = "Bastion of Light", sources = { [14]=13956 } },
                { id = 30878, slot = "Shoulder", name = "Glimmering Steel Mantle", sources = { [14]=13952 } },
                { id = 30884, slot = "Shoulder", name = "Hatefury Mantle", sources = { [14]=13958 } },
                { id = 30883, slot = "Two-Hand", name = "Pillar of Ferocity", sources = { [14]=13957 } },
                { id = 30888, slot = "Waist", name = "Anetheron's Noose", sources = { [14]=13962 } },
                { id = 30879, slot = "Waist", name = "Don Alejandro's Money Belt", sources = { [14]=13953 } },
                { id = 30881, slot = "Weapon", name = "Blade of Infamy", sources = { [14]=13955 } },
                { id = 30874, slot = "Weapon", name = "The Unbreakable Will", sources = { [14]=13951 } },
            },
            specialLoot = {
                -- Undead battle pet, part of the Raiding with Leashes III
                -- pet collection.
                { id = 122111, kind = "pet", name = "Stinkrot" },
            },
        },
        {
            index              = 3,
            name               = "Kaz'rogal",
            journalEncounterID = 1579,
            soloTip            = "Kill (8) waves of trash and the boss will come.  Some waves will include gargoyles in the back area.",
            achievements       = {},
            loot = {
                { id = 30891, slot = "Feet", name = "Black Featherlight Boots", sources = { [14]=13964 } },
                { id = 30894, slot = "Feet", name = "Blue Suede Shoes", sources = { [14]=13967 } },
                { id = 30916, slot = "Legs", name = "Leggings of Channeled Elements", sources = { [14]=13989 } },
                { id = 30893, slot = "Legs", name = "Sun-Touched Chain Leggings", sources = { [14]=13966 } },
                { id = 30889, slot = "Off-hand", name = "Kaz'rogal's Hardened Heart", sources = { [14]=13963 } },
                { id = 30892, slot = "Shoulder", name = "Beast-Tamer's Shoulders", sources = { [14]=13965 } },
                { id = 30917, slot = "Shoulder", name = "Razorfury Mantle", sources = { [14]=13990 } },
                { id = 30895, slot = "Waist", name = "Angelista's Sash", sources = { [14]=13968 } },
                { id = 30915, slot = "Waist", name = "Belt of Seething Fury", sources = { [14]=13988 } },
                { id = 30914, slot = "Waist", name = "Belt of the Crescent Moon", sources = { [14]=13987 } },
                { id = 30919, slot = "Waist", name = "Valestalker Girdle", sources = { [14]=13992 } },
                { id = 30918, slot = "Weapon", name = "Hammer of Atonement", sources = { [14]=13991 } },
            },
        },
        {
            index              = 4,
            name               = "Azgalor",
            journalEncounterID = 1580,
            soloTip            = "Kill (8) waves of trash and the boss will come.  Infernals will drop out of the sky all over the area.",
            achievements       = {},
            loot = {
                { id = 30899, slot = "Chest", name = "Don Rodrigo's Poncho", sources = { [14]=13972 } },
                { id = 30896, slot = "Chest", name = "Glory of the Defender", sources = { [14]=13969 } },
                { id = 31060, slot = "Hands", name = "Gloves of Absolution", sources = { [14]=14128 }, classes = { 5 } },
                { id = 31050, slot = "Hands", name = "Gloves of the Malefic", sources = { [14]=14118 }, classes = { 9 } },
                { id = 31055, slot = "Hands", name = "Gloves of the Tempest", sources = { [14]=14123 }, classes = { 8 } },
                { id = 31001, slot = "Hands", name = "Gronnstalker's Gloves", sources = { [14]=14072 }, classes = { 3 } },
                { id = 31061, slot = "Hands", name = "Handguards of Absolution", sources = { [14]=14129 }, classes = { 5 } },
                { id = 30982, slot = "Hands", name = "Lightbringer Gauntlets", sources = { [14]=14053 }, classes = { 2 } },
                { id = 30983, slot = "Hands", name = "Lightbringer Gloves", sources = { [14]=14054 }, classes = { 2 } },
                { id = 30985, slot = "Hands", name = "Lightbringer Handguards", sources = { [14]=14056 }, classes = { 2 } },
                { id = 30969, slot = "Hands", name = "Onslaught Gauntlets", sources = { [14]=14042 }, classes = { 1 } },
                { id = 30970, slot = "Hands", name = "Onslaught Handguards", sources = { [14]=14043 }, classes = { 1 } },
                { id = 31008, slot = "Hands", name = "Skyshatter Gauntlets", sources = { [14]=14079 }, classes = { 7 } },
                { id = 31007, slot = "Hands", name = "Skyshatter Gloves", sources = { [14]=14078 }, classes = { 7 } },
                { id = 31011, slot = "Hands", name = "Skyshatter Grips", sources = { [14]=14082 }, classes = { 7 } },
                { id = 31026, slot = "Hands", name = "Slayer's Handguards", sources = { [14]=14096 }, classes = { 4 } },
                { id = 31034, slot = "Hands", name = "Thunderheart Gauntlets", sources = { [14]=14102 }, classes = { 11 } },
                { id = 31032, slot = "Hands", name = "Thunderheart Gloves", sources = { [14]=14101 }, classes = { 11 } },
                { id = 31035, slot = "Hands", name = "Thunderheart Handguards", sources = { [14]=14103 }, classes = { 11 } },
                { id = 30900, slot = "Legs", name = "Bow-Stitched Leggings", sources = { [14]=13973 } },
                { id = 30898, slot = "Legs", name = "Shady Dealer's Pantaloons", sources = { [14]=13971 } },
                { id = 30897, slot = "Waist", name = "Girdle of Hope", sources = { [14]=13970 } },
                { id = 30901, slot = "Weapon", name = "Boundless Agony", sources = { [14]=13974 } },
            },
            specialLoot = {
                -- Elemental battle pet, part of the Raiding with Leashes
                -- III pet collection.
                { id = 122105, kind = "pet", name = "Grotesque" },
            },
        },
        {
            index              = 5,
            name               = "Archimonde",
            journalEncounterID = 1581,
            achievements       = {},
            loot = {
                { id = 30907, slot = "Chest", name = "Mail of Fevered Pursuit", sources = { [14]=13980 } },
                { id = 30905, slot = "Chest", name = "Midnight Chestguard", sources = { [14]=13978 } },
                { id = 30913, slot = "Chest", name = "Robes of Rhonin", sources = { [14]=13986 } },
                { id = 30904, slot = "Chest", name = "Savior's Grasp", sources = { [14]=13977 } },
                { id = 31063, slot = "Head", name = "Cowl of Absolution", sources = { [14]=14131 }, classes = { 5 } },
                { id = 31056, slot = "Head", name = "Cowl of the Tempest", sources = { [14]=14124 }, classes = { 8 } },
                { id = 31003, slot = "Head", name = "Gronnstalker's Helmet", sources = { [14]=14074 }, classes = { 3 } },
                { id = 31064, slot = "Head", name = "Hood of Absolution", sources = { [14]=14132 }, classes = { 5 } },
                { id = 31051, slot = "Head", name = "Hood of the Malefic", sources = { [14]=14119 }, classes = { 9 } },
                { id = 30987, slot = "Head", name = "Lightbringer Faceguard", sources = { [14]=14058 }, classes = { 2 } },
                { id = 30988, slot = "Head", name = "Lightbringer Greathelm", sources = { [14]=14059 }, classes = { 2 } },
                { id = 30989, slot = "Head", name = "Lightbringer War-Helm", sources = { [14]=14060 }, classes = { 2 } },
                { id = 30972, slot = "Head", name = "Onslaught Battle-Helm", sources = { [14]=14045 }, classes = { 1 } },
                { id = 30974, slot = "Head", name = "Onslaught Greathelm", sources = { [14]=14046 }, classes = { 1 } },
                { id = 31015, slot = "Head", name = "Skyshatter Cover", sources = { [14]=14086 }, classes = { 7 } },
                { id = 31014, slot = "Head", name = "Skyshatter Headguard", sources = { [14]=14085 }, classes = { 7 } },
                { id = 31012, slot = "Head", name = "Skyshatter Helmet", sources = { [14]=14083 }, classes = { 7 } },
                { id = 31027, slot = "Head", name = "Slayer's Helm", sources = { [14]=14097 }, classes = { 4 } },
                { id = 31039, slot = "Head", name = "Thunderheart Cover", sources = { [14]=14107 }, classes = { 11 } },
                { id = 31040, slot = "Head", name = "Thunderheart Headguard", sources = { [14]=14108 }, classes = { 11 } },
                { id = 31037, slot = "Head", name = "Thunderheart Helmet", sources = { [14]=14105 }, classes = { 11 } },
                { id = 30911, slot = "Held In Off-hand", name = "Scepter of Purification", sources = { [14]=13984 } },
                { id = 30912, slot = "Legs", name = "Leggings of Eternity", sources = { [14]=13985 } },
                { id = 30903, slot = "Legs", name = "Legguards of Endless Rage", sources = { [14]=13976 } },
                { id = 30909, slot = "Off-hand", name = "Antonidas' Aegis of Rapt Concentration", sources = { [14]=13982 } },
                { id = 30906, slot = "Ranged", name = "Bristleblitz Striker", sources = { [14]=13979 } },
                { id = 30908, slot = "Two-Hand", name = "Apostle of Argus", sources = { [14]=13981 } },
                { id = 30902, slot = "Two-Hand", name = "Cataclysm's Edge", sources = { [14]=13975 } },
                { id = 30910, slot = "Weapon", name = "Tempest of Chaos", sources = { [14]=13983 } },
            },
            specialLoot = {
                -- Elemental battle pet, part of the Raiding with Leashes
                -- III pet collection.
                { id = 122112, kind = "pet", name = "Hyjal Wisp" },
            },
        },
    },

    routing = {

        -- 1. Rage Winterchill
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Rage Winterchill",
            requires  = { },
            segments  = {
                {
                    -- Landing area. Bare mapID, so it matches anywhere in
                    -- Hyjal Summit; the segment below narrows to the base and
                    -- takes over once the player is through the portal.
                    -- No points: the note is the whole instruction and there
                    -- is nothing on the map worth pointing at.
                    when    = { mapID = 329 },
                    kind    = "path",
                    note    = "After zoning into the landing area, take the left portal to zone into the raid.",
                    minNote = "Left portal to enter raid",
                },
                {
                    when    = { mapID = 329, subZone = "Alliance Base" },
                    kind    = "path",
                    note    = "Inside the raid, talk to ^Lady Jaina Proudmoore^ to start the encounter with ^Rage Winterchill^.",
                    minNote = "Talk to Jaina for Rage Winterchill",
                },
            },
        },

        -- 2. Anetheron
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Anetheron",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 329 },
                    kind    = "path",
                    note    = "After defeating ^Rage Winterchill^, speak to ^Lady Jaina Proudmoore^ to begin the next encounter against ^Anetheron^.",
                    minNote = "Talk to Jaina for Anetheron",
                },
            },
        },

        -- 3. Kaz'rogal
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Kaz'rogal",
            requires  = { },
            segments  = {
                {
                    -- The noted segment comes first and is gated on the map
                    -- alone. Only a segment whose `when` still matches is
                    -- eligible to display, so the one carrying the note has
                    -- to match everywhere this leg takes the player: the
                    -- Alliance Base, the road, and the encampment. The two
                    -- markers below are noteless and inherit it.
                    when    = { mapID = 329 },
                    kind    = "path",
                    note    = "After killing ^Anetheron^, talk to ^Lady Jaina Proudmoore^ to continue and she will teleport out. Next, take the long road east until you reach the ^Horde Encampment^.",
                    minNote = "Jaina, then east to the encampment",
                    points  = {
                        { 0.159, 0.606 },
                        { 0.176, 0.562 },
                        { 0.206, 0.581 },
                        { 0.225, 0.628 },
                        { 0.252, 0.635 },
                        { 0.322, 0.635 },
                        { 0.350, 0.602 },
                        { 0.357, 0.567 },
                        { 0.348, 0.535 },
                        { 0.322, 0.501 },
                        { 0.314, 0.440 },
                        { 0.328, 0.398 },
                        { 0.385, 0.358 },
                    },
                },
                {
                    when        = { mapID = 329, subZone = "Alliance Base" },
                    kind        = "poi",
                    mapLabel    = "Talk to Jaina",
                    mapLabelPos = "above",
                    points      = {
                        { 0.104, 0.619 },
                    },
                },
                {
                    -- Noted rather than inheriting: the panel shows one note
                    -- at a time, so this takes over from the travel note on
                    -- arrival and keeps each one short. Both still draw on
                    -- the map together.
                    when        = { mapID = 329, subZone = "Horde Encampment" },
                    kind        = "poi",
                    mapLabel    = "Talk to Thrall",
                    mapLabelPos = "below",
                    note        = "Talk to ^Thrall^ to start the fight with ^Kaz'rogal^.",
                    minNote     = "Talk to Thrall for Kaz'rogal",
                    points      = {
                        { 0.478, 0.431 },
                    },
                },
            },
        },

        -- 4. Azgalor
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Azgalor",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 329, subZone = "Horde Encampment" },
                    kind        = "poi",
                    mapLabel    = "Talk to Thrall",
                    mapLabelPos = "below",
                    note        = "After killing ^Kaz'rogal^, talk to ^Thrall^ again to start the encounter against ^Azgalor^.",
                    minNote     = "Talk to Thrall for Azgalor",
                    points      = {
                        { 0.478, 0.431 },
                    },
                },
            },
        },

        -- 5. Archimonde
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Archimonde",
            requires  = { },
            segments  = {
                {
                    -- Gated on the map alone. This note covers a walk out of
                    -- the encampment, and a sub-zone gate would stop matching
                    -- as soon as the player sets off. Same as the road in.
                    when    = { mapID = 329 },
                    kind    = "path",
                    note    = "After defeating ^Azgalor^, take another long road to the far east. Stop and talk to ^Tyrande Whisperwind^ and continue north to ^Archimonde^.",
                    minNote = "Tyrande then Archimonde",
                    points  = {
                        { 0.501, 0.409 },
                        { 0.517, 0.434 },
                        { 0.550, 0.437 },
                        { 0.569, 0.483 },
                        { 0.592, 0.529 },
                        { 0.629, 0.535 },
                        { 0.654, 0.490 },
                        { 0.733, 0.439 },
                        { 0.750, 0.453 },
                        { 0.752, 0.481 },
                        { 0.741, 0.510 },
                        { 0.741, 0.547 },
                        { 0.752, 0.574 },
                        { 0.775, 0.572 },
                        { 0.796, 0.548 },
                        { 0.824, 0.529 },
                        { 0.855, 0.534 },
                        { 0.876, 0.517 },
                        { 0.879, 0.475 },
                        { 0.891, 0.434 },
                        { 0.896, 0.398 },
                        { 0.853, 0.382 },
                    },
                },
                {
                    -- Noteless, inheriting the road note above.
                    when        = { mapID = 329, subZone = "Night Elf Village" },
                    kind        = "poi",
                    mapLabel    = "Talk to Tyrande",
                    mapLabelPos = "below",
                    points      = {
                        { 0.742, 0.587 },
                    },
                },
            },
        },
    },
}
