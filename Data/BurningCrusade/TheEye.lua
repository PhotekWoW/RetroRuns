-------------------------------------------------------------------------------
-- RetroRuns Data -- The Eye
-- Burning Crusade, Patch 2.0.3  |  instanceID: 550  |  journalInstanceID: 749
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[550] = {
    instanceID        = 550,
    journalInstanceID = 749,
    name              = "The Eye",
    expansion         = "Burning Crusade",
    patch             = "2.0.3",

    exitNote          = "None available",

    -- The raid runs at 25-player only. One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Netherstorm, at the foot of Tempest Keep's central spire.
        mapID = 109, x = 0.7388, y = 0.6374,
    },

    -- mapID -> world-map dropdown label. The world map names this
    -- instance Tempest Keep; the journal calls it The Eye.
    maps = {
        [334] = "Tempest Keep",
    },

    -- Patch 2.4.0 removed the requirement to clear the raid before
    -- Kael'thas, so this route is always available -- there is no
    -- attunement, quest or achievement gating it.
    skipToBoss = "Kael'thas Sunstrider",

    skipRoute = {

        -- 1. Kael'thas Sunstrider
        {
            step      = 1,
            priority  = 1,
            bossIndex = 4,
            title     = "Kael'thas Sunstrider",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 334, subZone = "The Phoenix Hall" },
                    kind    = "path",
                    note    = "After zoning in, follow the path through ^Al'ar^'s room and continue north until you reach ^Kael'thas Sunstrider^.",
                    minNote = "North all the way to Kael",
                    points  = {
                        { 0.500, 0.844 },
                        { 0.499, 0.661 },
                        { 0.479, 0.649 },
                        { 0.463, 0.623 },
                        { 0.456, 0.592 },
                        { 0.442, 0.561 },
                        { 0.452, 0.525 },
                        { 0.470, 0.505 },
                        { 0.448, 0.450 },
                        { 0.429, 0.427 },
                        { 0.406, 0.410 },
                        { 0.419, 0.346 },
                        { 0.444, 0.289 },
                        { 0.472, 0.259 },
                        { 0.500, 0.233 },
                        { 0.500, 0.176 },
                    },
                },
            },
        },
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [30248] = 2,   -- Pauldrons of the Vanquished Champion
            [30249] = 2,   -- Pauldrons of the Vanquished Defender
            [30250] = 2,   -- Pauldrons of the Vanquished Hero
            [30236] = 4,   -- Chestguard of the Vanquished Champion
            [30237] = 4,   -- Chestguard of the Vanquished Defender
            [30238] = 4,   -- Chestguard of the Vanquished Hero
        },
    },


    -- Trash drops. The Encounter Journal indexes boss loot only,
    -- so these carry no journal rows and belong to no encounter.
    trashLoot = {
        { id = 30029, slot = "Hands", name = "Bark-Gloves of Ancient Wisdom", sources = { [14]=13474 }, bind = "BoP" },
        { id = 30024, slot = "Shoulder", name = "Mantle of the Elven Kings", sources = { [14]=13470 }, bind = "BoP" },
        { id = 30020, slot = "Waist", name = "Fire-Cord of the Magus", sources = { [14]=13468 }, bind = "BoP" },
        { id = 30030, slot = "Waist", name = "Girdle of Fallen Stars", sources = { [14]=13475 }, bind = "BoP" },
        { id = 30026, slot = "Wrist", name = "Bands of the Celestial Archer", sources = { [14]=13472 }, bind = "BoP" },
    },
    bosses = {
        {
            index              = 1,
            name               = "Al'ar",
            journalEncounterID = 1573,
            achievements       = {},
            loot = {
                { id = 29925, slot = "Back", name = "Phoenix-Wing Cloak", sources = { [14]=13388 } },
                { id = 29921, slot = "Chest", name = "Fire Crest Breastplate", sources = { [14]=13385 } },
                { id = 29947, slot = "Hands", name = "Gloves of the Searing Grip", sources = { [14]=13410 } },
                { id = 29923, slot = "Held In Off-hand", name = "Talisman of the Sun King", sources = { [14]=13386 } },
                { id = 29949, slot = "Ranged", name = "Arcanite Steam-Pistol", sources = { [14]=13412 } },
                { id = 29948, slot = "Weapon", name = "Claw of the Phoenix", sources = { [14]=13411 } },
                { id = 29924, slot = "Weapon", name = "Netherbane", sources = { [14]=13387 } },
                { id = 32944, slot = "Weapon", name = "Talon of the Phoenix", sources = { [14]=15194 } },
                { id = 29918, slot = "Wrist", name = "Mindstorm Wristbands", sources = { [14]=13383 } },
            },
            specialLoot = {
                -- Phoenix hawk battle pet, part of the Raiding with
                -- Leashes II pet collection.
                { id = 97557, kind = "pet", name = "Phoenix Hawk Hatchling" },
            },
        },
        {
            index              = 2,
            name               = "Void Reaver",
            journalEncounterID = 1574,
            achievements       = {},
            loot = {
                { id = 29986, slot = "Head", name = "Cowl of the Grand Engineer", sources = { [14]=13441 } },
                { id = 29983, slot = "Head", name = "Fel-Steel Warhelm", sources = { [14]=13438 } },
                { id = 29985, slot = "Legs", name = "Void Reaver Greaves", sources = { [14]=13440 } },
                { id = 30168, slot = "Shoulder", name = "Cataclysm Shoulderguards", sources = { [14]=13599 }, classes = { 7 } },
                { id = 30173, slot = "Shoulder", name = "Cataclysm Shoulderpads", sources = { [14]=13604 }, classes = { 7 } },
                { id = 30194, slot = "Shoulder", name = "Cataclysm Shoulderplates", sources = { [14]=13618 }, classes = { 7 } },
                { id = 30138, slot = "Shoulder", name = "Crystalforge Pauldrons", sources = { [14]=13573 }, classes = { 2 } },
                { id = 30133, slot = "Shoulder", name = "Crystalforge Shoulderbraces", sources = { [14]=13568 }, classes = { 2 } },
                { id = 30127, slot = "Shoulder", name = "Crystalforge Shoulderguards", sources = { [14]=13562 }, classes = { 2 } },
                { id = 30149, slot = "Shoulder", name = "Deathmantle Shoulderpads", sources = { [14]=13584 }, classes = { 4 } },
                { id = 30122, slot = "Shoulder", name = "Destroyer Shoulderblades", sources = { [14]=13557 }, classes = { 1 } },
                { id = 30117, slot = "Shoulder", name = "Destroyer Shoulderguards", sources = { [14]=13552 }, classes = { 1 } },
                { id = 30186, slot = "Shoulder", name = "Gladiator's Felweave Amice", sources = { [14]=13612 }, classes = { 9 } },
                { id = 30210, slot = "Shoulder", name = "Mantle of Tirisfal", sources = { [14]=13628 }, classes = { 8 } },
                { id = 30154, slot = "Shoulder", name = "Mantle of the Avatar", sources = { [14]=13589 }, classes = { 5 } },
                { id = 30215, slot = "Shoulder", name = "Mantle of the Corruptor", sources = { [14]=13633 }, classes = { 9 } },
                { id = 30230, slot = "Shoulder", name = "Nordrassil Feral-Mantle", sources = { [14]=13648 }, classes = { 11 } },
                { id = 30221, slot = "Shoulder", name = "Nordrassil Life-Mantle", sources = { [14]=13639 }, classes = { 11 } },
                { id = 30235, slot = "Shoulder", name = "Nordrassil Wrath-Mantle", sources = { [14]=13653 }, classes = { 11 } },
                { id = 30143, slot = "Shoulder", name = "Rift Stalker Mantle", sources = { [14]=13578 }, classes = { 3 } },
                { id = 30163, slot = "Shoulder", name = "Wings of the Avatar", sources = { [14]=13594 }, classes = { 5 } },
                { id = 29984, slot = "Waist", name = "Girdle of Zaetar", sources = { [14]=13439 } },
                { id = 32515, slot = "Wrist", name = "Wristguards of Determination", sources = { [14]=15005 } },
            },
            specialLoot = {
                -- Mechanical battle pet, part of the Raiding with
                -- Leashes II pet collection.
                { id = 97555, kind = "pet", name = "Pocket Reaver" },
            },
        },
        {
            index              = 3,
            name               = "High Astromancer Solarian",
            journalEncounterID = 1575,
            achievements       = {},
            loot = {
                { id = 32267, slot = "Feet", name = "Boots of the Resilient", sources = { [14]=14891 } },
                { id = 29951, slot = "Feet", name = "Star-Strider Boots", sources = { [14]=13414 } },
                { id = 29976, slot = "Hands", name = "Worldstorm Gauntlets", sources = { [14]=13431 } },
                { id = 29950, slot = "Legs", name = "Greaves of the Bloodwarder", sources = { [14]=13413 } },
                { id = 29977, slot = "Legs", name = "Star-Soul Breeches", sources = { [14]=13432 } },
                { id = 29972, slot = "Legs", name = "Trousers of the Astromancer", sources = { [14]=13427 } },
                { id = 29982, slot = "Ranged", name = "Wand of the Forgotten Star", sources = { [14]=13437 } },
                { id = 29981, slot = "Two-Hand", name = "Ethereum Life-Staff", sources = { [14]=13436 } },
                { id = 29965, slot = "Waist", name = "Girdle of the Righteous Path", sources = { [14]=13420 } },
                { id = 29962, slot = "Weapon", name = "Heartrazor", sources = { [14]=13418 } },
                { id = 29966, slot = "Wrist", name = "Vambraces of Ending", sources = { [14]=13421 } },
            },
            specialLoot = {
                -- Humanoid battle pet, part of the Raiding with
                -- Leashes II pet collection.
                { id = 97556, kind = "pet", name = "Lesser Voidcaller" },
            },
        },
        {
            index              = 4,
            name               = "Kael'thas Sunstrider",
            journalEncounterID = 1576,
            achievements       = {},
            loot = {
                { id = 29992, slot = "Back", name = "Royal Cloak of the Sunstriders", sources = { [14]=13447 } },
                { id = 29989, slot = "Back", name = "Sunshower Light Cloak", sources = { [14]=13444 } },
                { id = 29994, slot = "Back", name = "Thalassian Wildercloak", sources = { [14]=13449 } },
                { id = 30164, slot = "Chest", name = "Cataclysm Chestguard", sources = { [14]=13595 }, classes = { 7 } },
                { id = 30169, slot = "Chest", name = "Cataclysm Chestpiece", sources = { [14]=13600 }, classes = { 7 } },
                { id = 30185, slot = "Chest", name = "Cataclysm Chestplate", sources = { [14]=13611 }, classes = { 7 } },
                { id = 30129, slot = "Chest", name = "Crystalforge Breastplate", sources = { [14]=13564 }, classes = { 2 } },
                { id = 30123, slot = "Chest", name = "Crystalforge Chestguard", sources = { [14]=13558 }, classes = { 2 } },
                { id = 30134, slot = "Chest", name = "Crystalforge Chestpiece", sources = { [14]=13569 }, classes = { 2 } },
                { id = 30144, slot = "Chest", name = "Deathmantle Chestguard", sources = { [14]=13579 }, classes = { 4 } },
                { id = 30118, slot = "Chest", name = "Destroyer Breastplate", sources = { [14]=13553 }, classes = { 1 } },
                { id = 30113, slot = "Chest", name = "Destroyer Chestguard", sources = { [14]=13548 }, classes = { 1 } },
                { id = 30200, slot = "Chest", name = "Gladiator's Felweave Raiment", sources = { [14]=13620 }, classes = { 9 } },
                { id = 30216, slot = "Chest", name = "Nordrassil Chestguard", sources = { [14]=13634 }, classes = { 11 } },
                { id = 30231, slot = "Chest", name = "Nordrassil Chestpiece", sources = { [14]=13649 }, classes = { 11 } },
                { id = 30222, slot = "Chest", name = "Nordrassil Chestplate", sources = { [14]=13640 }, classes = { 11 } },
                { id = 30139, slot = "Chest", name = "Rift Stalker Hauberk", sources = { [14]=13574 }, classes = { 3 } },
                { id = 30214, slot = "Chest", name = "Robe of the Corruptor", sources = { [14]=13632 }, classes = { 9 } },
                { id = 30196, slot = "Chest", name = "Robes of Tirisfal", sources = { [14]=13619 }, classes = { 8 } },
                { id = 30159, slot = "Chest", name = "Shroud of the Avatar", sources = { [14]=13590 }, classes = { 5 } },
                { id = 30150, slot = "Chest", name = "Vestments of the Avatar", sources = { [14]=13585 }, classes = { 5 } },
                { id = 29987, slot = "Hands", name = "Gauntlets of the Sun King", sources = { [14]=13442 } },
                { id = 29998, slot = "Hands", name = "Royal Gauntlets of Silvermoon", sources = { [14]=13452 } },
                { id = 29990, slot = "Head", name = "Crown of the Sun", sources = { [14]=13445 } },
                { id = 29995, slot = "Legs", name = "Leggings of Murderous Intent", sources = { [14]=13450 } },
                { id = 29991, slot = "Legs", name = "Sunhawk Leggings", sources = { [14]=13446 } },
                { id = 29988, slot = "Two-Hand", name = "The Nexus Key", sources = { [14]=13443 } },
                { id = 29993, slot = "Two-Hand", name = "Twinblade of the Phoenix", sources = { [14]=13448 } },
                { id = 29996, slot = "Weapon", name = "Rod of the Sun King", sources = { [14]=13451 } },
            },
            specialLoot = {
                { id = 32458, kind = "mount", name = "Ashes of Al'ar", mountID = 183 },
            },
        },
    },

    routing = {

        -- 1. Al'ar
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Al'ar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 334, subZone = "The Phoenix Hall" },
                    kind    = "path",
                    note    = "After zoning in, proceed ahead to ^Al'ar^. You may need to walk up a ramp to pull the boss.",
                    minNote = "Ahead to Al'ar",
                    points  = {
                        { 0.500, 0.847 },
                        { 0.500, 0.633 },
                    },
                },
            },
        },

        -- 2. Void Reaver
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Void Reaver",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 334, subZone = "The Phoenix Hall" },
                    kind    = "path",
                    note    = "After defeating ^Al'ar^, take the northwest exit and follow the path to ^Void Reaver^.",
                    minNote = "Northwest to Void Reaver",
                    points  = {
                        { 0.472, 0.640 },
                        { 0.460, 0.617 },
                        { 0.456, 0.587 },
                        { 0.443, 0.561 },
                        { 0.449, 0.529 },
                        { 0.468, 0.504 },
                        { 0.448, 0.451 },
                        { 0.431, 0.428 },
                        { 0.386, 0.408 },
                        { 0.343, 0.422 },
                        { 0.288, 0.472 },
                    },
                },
            },
        },

        -- 3. High Astromancer Solarian
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "High Astromancer Solarian",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 334, subZone = "The Crucible" },
                    kind    = "path",
                    note    = "After defeating ^Void Reaver^, backtrack out of the room and head north as you loop around to ^High Astromancer Solarian^.",
                    minNote = "Path north to Solarian",
                    points  = {
                        { 0.307, 0.452 },
                        { 0.340, 0.423 },
                        { 0.378, 0.408 },
                        { 0.405, 0.411 },
                        { 0.430, 0.309 },
                        { 0.451, 0.280 },
                        { 0.475, 0.258 },
                        { 0.529, 0.257 },
                        { 0.563, 0.295 },
                        { 0.585, 0.355 },
                        { 0.597, 0.411 },
                        { 0.629, 0.408 },
                        { 0.673, 0.434 },
                        { 0.718, 0.477 },
                    },
                },
            },
        },

        -- 4. Kael'thas Sunstrider
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Kael'thas Sunstrider",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 334, subZone = "The Solarium" },
                    kind    = "path",
                    note    = "After killing ^High Astromancer Solarian^, backtrack out of the room and head north to find ^Kael'thas Sunstrider^.",
                    minNote = "North to Kael",
                    points  = {
                        { 0.678, 0.439 },
                        { 0.633, 0.408 },
                        { 0.597, 0.407 },
                        { 0.574, 0.320 },
                        { 0.548, 0.277 },
                        { 0.521, 0.250 },
                        { 0.501, 0.177 },
                    },
                },
            },
        },
    },
}
