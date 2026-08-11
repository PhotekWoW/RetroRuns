-------------------------------------------------------------------------------
-- RetroRuns Data -- Serpentshrine Cavern
-- Burning Crusade, Patch 2.0.3  |  instanceID: 548  |  journalInstanceID: 748
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[548] = {
    instanceID        = 548,
    journalInstanceID = 748,
    name              = "Serpentshrine Cavern",
    expansion         = "Burning Crusade",
    patch             = "2.0.3",

    exitNote          = "None available",

    -- The raid runs at 25-player only. One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Zangarmarsh, inside Coilfang Reservoir.
        mapID = 102, x = 0.519, y = 0.328,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [332] = "Serpentshrine Cavern",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [30239] = 3,   -- Gloves of the Vanquished Champion
            [30240] = 3,   -- Gloves of the Vanquished Defender
            [30241] = 3,   -- Gloves of the Vanquished Hero
            [30245] = 4,   -- Leggings of the Vanquished Champion
            [30246] = 4,   -- Leggings of the Vanquished Defender
            [30247] = 4,   -- Leggings of the Vanquished Hero
            [30242] = 6,   -- Helm of the Vanquished Champion
            [30243] = 6,   -- Helm of the Vanquished Defender
            [30244] = 6,   -- Helm of the Vanquished Hero
        },
    },


    -- Trash drops. The Encounter Journal indexes boss loot only,
    -- so these carry no journal rows and belong to no encounter.
    trashLoot = {
        { id = 30027, slot = "Feet", name = "Boots of Courage Unending", sources = { [14]=13473 }, bind = "BoP" },
        { id = 30021, slot = "Two-Hand", name = "Wildfury Greatstaff", sources = { [14]=13469 }, bind = "BoP" },
    },
    bosses = {
        {
            index              = 1,
            name               = "Hydross the Unstable",
            journalEncounterID = 1567,
            achievements       = {},
            loot = {
                { id = 30054, slot = "Chest", name = "Ranger-General's Chestguard", sources = { [14]=13497 } },
                { id = 30056, slot = "Chest", name = "Robe of Hateful Echoes", sources = { [14]=13499 } },
                { id = 30050, slot = "Feet", name = "Boots of the Shifting Nightmare", sources = { [14]=13495 } },
                { id = 30048, slot = "Head", name = "Brighthelm of Justice", sources = { [14]=13493 } },
                { id = 30049, slot = "Held In Off-hand", name = "Fathomstone", sources = { [14]=13494 } },
                { id = 30053, slot = "Shoulder", name = "Pauldrons of the Wardancer", sources = { [14]=13496 } },
                { id = 30055, slot = "Shoulder", name = "Shoulderpads of the Stranger", sources = { [14]=13498 } },
                { id = 30047, slot = "Wrist", name = "Blackfathom Warbands", sources = { [14]=13492 } },
                { id = 32516, slot = "Wrist", name = "Wraps of Purification", sources = { [14]=15006 } },
            },
            specialLoot = {
                -- Elemental battle pet, part of the Raiding with
                -- Leashes II pet collection.
                { id = 97553, kind = "pet", name = "Tainted Waveling" },
                { id = 138834, kind = "illusion", name = "Illusion: Frostbrand", sourceID = 5873 },
            },
        },
        {
            index              = 2,
            name               = "The Lurker Below",
            journalEncounterID = 1568,
            achievements       = {
                { id = 144, name = "The Lurker Above", meta = false, soloable = "yes" },
            },
            loot = {
                { id = 30065, slot = "Chest", name = "Glowing Breastplate of Truth", sources = { [14]=13505 } },
                { id = 30060, slot = "Feet", name = "Boots of Effortless Striking", sources = { [14]=13502 } },
                { id = 30066, slot = "Feet", name = "Tempest-Strider Boots", sources = { [14]=13506 } },
                { id = 30067, slot = "Feet", name = "Velvet Boots of the Guardian", sources = { [14]=13507 } },
                { id = 30064, slot = "Waist", name = "Cord of Screaming Terrors", sources = { [14]=13504 } },
                { id = 30058, slot = "Weapon", name = "Mallet of the Tides", sources = { [14]=13501 } },
                { id = 30057, slot = "Wrist", name = "Bracers of Eradication", sources = { [14]=13500 } },
                { id = 30062, slot = "Wrist", name = "Grove-Bands of Remulos", sources = { [14]=13503 } },
            },
        },
        {
            index              = 3,
            name               = "Leotheras the Blind",
            journalEncounterID = 1569,
            achievements       = {},
            loot = {
                { id = 30092, slot = "Feet", name = "Orca-Hide Boots", sources = { [14]=13531 } },
                { id = 30189, slot = "Hands", name = "Cataclysm Gauntlets", sources = { [14]=13615 }, classes = { 7 } },
                { id = 30165, slot = "Hands", name = "Cataclysm Gloves", sources = { [14]=13596 }, classes = { 7 } },
                { id = 30170, slot = "Hands", name = "Cataclysm Handgrips", sources = { [14]=13601 }, classes = { 7 } },
                { id = 30130, slot = "Hands", name = "Crystalforge Gauntlets", sources = { [14]=13565 }, classes = { 2 } },
                { id = 30135, slot = "Hands", name = "Crystalforge Gloves", sources = { [14]=13570 }, classes = { 2 } },
                { id = 30124, slot = "Hands", name = "Crystalforge Handguards", sources = { [14]=13559 }, classes = { 2 } },
                { id = 30145, slot = "Hands", name = "Deathmantle Handguards", sources = { [14]=13580 }, classes = { 4 } },
                { id = 30119, slot = "Hands", name = "Destroyer Gauntlets", sources = { [14]=13554 }, classes = { 1 } },
                { id = 30114, slot = "Hands", name = "Destroyer Handguards", sources = { [14]=13549 }, classes = { 1 } },
                { id = 30188, slot = "Hands", name = "Gladiator's Felweave Handguards", sources = { [14]=13614 }, classes = { 9 } },
                { id = 30205, slot = "Hands", name = "Gloves of Tirisfal", sources = { [14]=13623 }, classes = { 8 } },
                { id = 30151, slot = "Hands", name = "Gloves of the Avatar", sources = { [14]=13586 }, classes = { 5 } },
                { id = 30211, slot = "Hands", name = "Gloves of the Corruptor", sources = { [14]=13629 }, classes = { 9 } },
                { id = 30160, slot = "Hands", name = "Handguards of the Avatar", sources = { [14]=13591 }, classes = { 5 } },
                { id = 30232, slot = "Hands", name = "Nordrassil Gauntlets", sources = { [14]=13650 }, classes = { 11 } },
                { id = 30217, slot = "Hands", name = "Nordrassil Gloves", sources = { [14]=13635 }, classes = { 11 } },
                { id = 30223, slot = "Hands", name = "Nordrassil Handgrips", sources = { [14]=13641 }, classes = { 11 } },
                { id = 30140, slot = "Hands", name = "Rift Stalker Gauntlets", sources = { [14]=13575 }, classes = { 3 } },
                { id = 30097, slot = "Shoulder", name = "Coral-Barbed Shoulderpads", sources = { [14]=13535 } },
                { id = 30096, slot = "Waist", name = "Girdle of the Invulnerable", sources = { [14]=13534 } },
                { id = 30095, slot = "Weapon", name = "Fang of the Leviathan", sources = { [14]=13533 } },
                { id = 30091, slot = "Wrist", name = "True-Aim Stalker Bands", sources = { [14]=13530 } },
            },
        },
        {
            index              = 4,
            name               = "Fathom-Lord Karathress",
            journalEncounterID = 1570,
            achievements       = {},
            loot = {
                { id = 30101, slot = "Chest", name = "Bloodsea Brigand's Vest", sources = { [14]=13538 } },
                { id = 30100, slot = "Feet", name = "Soul-Strider Boots", sources = { [14]=13537 } },
                { id = 30153, slot = "Legs", name = "Breeches of the Avatar", sources = { [14]=13588 }, classes = { 5 } },
                { id = 30172, slot = "Legs", name = "Cataclysm Leggings", sources = { [14]=13603 }, classes = { 7 } },
                { id = 30167, slot = "Legs", name = "Cataclysm Legguards", sources = { [14]=13598 }, classes = { 7 } },
                { id = 30192, slot = "Legs", name = "Cataclysm Legplates", sources = { [14]=13617 }, classes = { 7 } },
                { id = 30132, slot = "Legs", name = "Crystalforge Greaves", sources = { [14]=13567 }, classes = { 2 } },
                { id = 30137, slot = "Legs", name = "Crystalforge Leggings", sources = { [14]=13572 }, classes = { 2 } },
                { id = 30126, slot = "Legs", name = "Crystalforge Legguards", sources = { [14]=13561 }, classes = { 2 } },
                { id = 30148, slot = "Legs", name = "Deathmantle Legguards", sources = { [14]=13583 }, classes = { 4 } },
                { id = 30121, slot = "Legs", name = "Destroyer Greaves", sources = { [14]=13556 }, classes = { 1 } },
                { id = 30116, slot = "Legs", name = "Destroyer Legguards", sources = { [14]=13551 }, classes = { 1 } },
                { id = 30201, slot = "Legs", name = "Gladiator's Felweave Trousers", sources = { [14]=13621 }, classes = { 9 } },
                { id = 30207, slot = "Legs", name = "Leggings of Tirisfal", sources = { [14]=13625 }, classes = { 8 } },
                { id = 30162, slot = "Legs", name = "Leggings of the Avatar", sources = { [14]=13593 }, classes = { 5 } },
                { id = 30213, slot = "Legs", name = "Leggings of the Corruptor", sources = { [14]=13631 }, classes = { 9 } },
                { id = 30229, slot = "Legs", name = "Nordrassil Feral-Kilt", sources = { [14]=13647 }, classes = { 11 } },
                { id = 30220, slot = "Legs", name = "Nordrassil Life-Kilt", sources = { [14]=13638 }, classes = { 11 } },
                { id = 30234, slot = "Legs", name = "Nordrassil Wrath-Kilt", sources = { [14]=13652 }, classes = { 11 } },
                { id = 30142, slot = "Legs", name = "Rift Stalker Leggings", sources = { [14]=13577 }, classes = { 3 } },
                { id = 30090, slot = "Two-Hand", name = "World Breaker", sources = { [14]=13529 } },
            },
        },
        {
            index              = 5,
            name               = "Morogrim Tidewalker",
            journalEncounterID = 1571,
            achievements       = {},
            loot = {
                { id = 30098, slot = "Back", name = "Razor-Scale Battlecloak", sources = { [14]=13536 } },
                { id = 30075, slot = "Chest", name = "Gnarled Chestpiece of the Ancients", sources = { [14]=13515 } },
                { id = 30081, slot = "Feet", name = "Warboots of Obliteration", sources = { [14]=13521 } },
                { id = 30080, slot = "Ranged", name = "Luminescent Rod of the Naaru", sources = { [14]=13520 } },
                { id = 30079, slot = "Shoulder", name = "Illidari Shoulderpads", sources = { [14]=13519 } },
                { id = 30085, slot = "Shoulder", name = "Mantle of the Tireless Tracker", sources = { [14]=13524 } },
                { id = 30084, slot = "Shoulder", name = "Pauldrons of the Argent Sentinel", sources = { [14]=13523 } },
                { id = 30068, slot = "Waist", name = "Girdle of the Tidal Call", sources = { [14]=13508 } },
                { id = 30082, slot = "Weapon", name = "Talon of Azshara", sources = { [14]=13522 } },
            },
            specialLoot = {
                -- Aquatic battle pet, part of the Raiding with Leashes II
                -- pet collection.
                { id = 97552, kind = "pet", name = "Tideskipper" },
            },
        },
        {
            index              = 6,
            name               = "Lady Vashj",
            journalEncounterID = 1572,
            achievements       = {},
            loot = {
                { id = 30102, slot = "Chest", name = "Krakken-Heart Breastplate", sources = { [14]=13539 } },
                { id = 30107, slot = "Chest", name = "Vestments of the Sea-Witch", sources = { [14]=13544 } },
                { id = 30104, slot = "Feet", name = "Cobra-Lash Boots", sources = { [14]=13541 } },
                { id = 30112, slot = "Hands", name = "Glorious Gauntlets of Crestfall", sources = { [14]=13547 } },
                { id = 30166, slot = "Head", name = "Cataclysm Headguard", sources = { [14]=13597 }, classes = { 7 } },
                { id = 30171, slot = "Head", name = "Cataclysm Headpiece", sources = { [14]=13602 }, classes = { 7 } },
                { id = 30190, slot = "Head", name = "Cataclysm Helm", sources = { [14]=13616 }, classes = { 7 } },
                { id = 30206, slot = "Head", name = "Cowl of Tirisfal", sources = { [14]=13624 }, classes = { 8 } },
                { id = 30152, slot = "Head", name = "Cowl of the Avatar", sources = { [14]=13587 }, classes = { 5 } },
                { id = 30125, slot = "Head", name = "Crystalforge Faceguard", sources = { [14]=13560 }, classes = { 2 } },
                { id = 30136, slot = "Head", name = "Crystalforge Greathelm", sources = { [14]=13571 }, classes = { 2 } },
                { id = 30131, slot = "Head", name = "Crystalforge War-Helm", sources = { [14]=13566 }, classes = { 2 } },
                { id = 30146, slot = "Head", name = "Deathmantle Helm", sources = { [14]=13581 }, classes = { 4 } },
                { id = 30120, slot = "Head", name = "Destroyer Battle-Helm", sources = { [14]=13555 }, classes = { 1 } },
                { id = 30115, slot = "Head", name = "Destroyer Greathelm", sources = { [14]=13550 }, classes = { 1 } },
                { id = 30187, slot = "Head", name = "Gladiator's Felweave Cowl", sources = { [14]=13613 }, classes = { 9 } },
                { id = 30161, slot = "Head", name = "Hood of the Avatar", sources = { [14]=13592 }, classes = { 5 } },
                { id = 30212, slot = "Head", name = "Hood of the Corruptor", sources = { [14]=13630 }, classes = { 9 } },
                { id = 30228, slot = "Head", name = "Nordrassil Headdress", sources = { [14]=13646 }, classes = { 11 } },
                { id = 30219, slot = "Head", name = "Nordrassil Headguard", sources = { [14]=13637 }, classes = { 11 } },
                { id = 30233, slot = "Head", name = "Nordrassil Headpiece", sources = { [14]=13651 }, classes = { 11 } },
                { id = 30141, slot = "Head", name = "Rift Stalker Helm", sources = { [14]=13576 }, classes = { 3 } },
                { id = 30105, slot = "Ranged", name = "Serpent Spine Longbow", sources = { [14]=13542 } },
                { id = 30111, slot = "Shoulder", name = "Runetotem's Mantle", sources = { [14]=13546 } },
                { id = 30106, slot = "Waist", name = "Belt of One-Hundred Deaths", sources = { [14]=13543 } },
                { id = 30103, slot = "Weapon", name = "Fang of Vashj", sources = { [14]=13540 } },
                { id = 30108, slot = "Weapon", name = "Lightfathom Scepter", sources = { [14]=13545 } },
            },
            specialLoot = {
                -- Beast battle pet, part of the Raiding with Leashes II
                -- pet collection.
                { id = 97554, kind = "pet", name = "Coilfang Stalker" },
            },
        },
    },

    -- Patch 2.4.0 removed the requirement to clear the raid before Lady
    -- Vashj, so the direct route is always available. No unlock to track.
    skipToBoss = "Lady Vashj",

    skipRoute = {

        -- 1. Lady Vashj
        {
            step      = 1,
            priority  = 1,
            bossIndex = 6,
            title     = "Lady Vashj",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 332 },
                    kind    = "path",
                    note    = "After zoning in, beware the legendary elevator boss! Go down to reach the next area. Take a left when you reach ^Hydross the Unstable^ and follow the path all the way around until you reach the ^Lady Vashj Bridge Console^. Click the console to open the bridge, then cross it to reach the final boss, ^Lady Vashj^.",
                    minNote = "Console then bridge to Vashj",
                    points  = {
                        { 0.177, 0.614 },
                        { 0.173, 0.670 },
                        { 0.204, 0.698 },
                        { 0.215, 0.743 },
                        { 0.243, 0.733 },
                        { 0.269, 0.747 },
                        { 0.278, 0.797 },
                        { 0.301, 0.824 },
                        { 0.336, 0.820 },
                        { 0.360, 0.760 },
                        { 0.361, 0.702 },
                        { 0.354, 0.643 },
                        { 0.339, 0.601 },
                        { 0.341, 0.574 },
                        { 0.339, 0.540 },
                        { 0.353, 0.506 },
                        { 0.371, 0.500 },
                        { 0.380, 0.484 },
                        { 0.444, 0.485 },
                        { 0.452, 0.507 },
                        { 0.469, 0.514 },
                        { 0.478, 0.544 },
                        { 0.509, 0.579 },
                        { 0.698, 0.589 },
                    },
                },
                {
                    -- Noteless, inheriting the segment above, same shape the
                    -- standard route's console POI uses.
                    when        = { mapID = 332 },
                    kind        = "poi",
                    mapLabel    = "Click Console",
                    mapLabelPos = "below",
                    points      = {
                        { 0.511, 0.580 },
                    },
                },
            },
        },
    },

    routing = {

        -- 1. Hydross the Unstable
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Hydross the Unstable",
            requires  = { },
            segments  = {
                {
                    when     = { mapID = 332 },
                    kind     = "poi",
                    mapLabel = "Go Down Elevator",
                    note     = "After zoning in, beware the legendary elevator boss! Go down to reach the next area, then take the southern path to ^Hydross the Unstable^.",
                    minNote  = "Go down elevator",
                    points   = {
                        { 0.135, 0.573 },
                    },
                },
                {
                    -- Noteless, so it inherits the segment above. Repeating
                    -- the note here would pin progress on the elevator: the
                    -- engine stops advancing at a second noted segment on the
                    -- same map, and the star would never gray out as passed.
                    when    = { mapID = 332 },
                    kind    = "path",
                    points  = {
                        { 0.176, 0.614 },
                        { 0.175, 0.673 },
                        { 0.191, 0.693 },
                        { 0.204, 0.693 },
                        { 0.217, 0.743 },
                        { 0.244, 0.735 },
                        { 0.269, 0.745 },
                        { 0.276, 0.792 },
                        { 0.293, 0.822 },
                        { 0.340, 0.841 },
                    },
                },
            },
        },

        -- 2. The Lurker Below
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "The Lurker Below",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 332 },
                    kind    = "path",
                    note    = "After defeating ^Hydross the Unstable^, head north and jump down to the platform in the middle of the water. Cast ^Fishing^ in the water swirl until you fish up ^The Lurker Below^.",
                    minNote = "Fish up The Lurker Below",
                    points  = {
                        { 0.337, 0.809 },
                        { 0.363, 0.763 },
                        { 0.361, 0.704 },
                        { 0.352, 0.623 },
                        { 0.391, 0.615 },
                    },
                },
            },
        },

        -- 3. Leotheras the Blind
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Leotheras the Blind",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 332 },
                    kind    = "path",
                    note    = "After killing ^The Lurker Below^, go up a nearby ramp and work your way up the path to ^Leotheras the Blind^.",
                    minNote = "Northwest path to Leotheras",
                    points  = {
                        { 0.430, 0.571 },
                        { 0.460, 0.533 },
                        { 0.445, 0.514 },
                        { 0.431, 0.502 },
                        { 0.411, 0.493 },
                        { 0.411, 0.412 },
                        { 0.394, 0.400 },
                        { 0.333, 0.418 },
                        { 0.302, 0.406 },
                        { 0.301, 0.382 },
                        { 0.302, 0.350 },
                        { 0.296, 0.327 },
                        { 0.304, 0.298 },
                        { 0.327, 0.282 },
                        { 0.342, 0.260 },
                        { 0.395, 0.254 },
                    },
                },
            },
        },
        -- 4. Fathom-Lord Karathress
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Fathom-Lord Karathress",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 332 },
                    kind    = "path",
                    note    = "After killing ^Leotheras the Blind^, take the eastern exit from the room and follow the path around to find ^Fathom-Lord Karathress^.",
                    minNote = "East path to Karathress",
                    points  = {
                        { 0.429, 0.306 },
                        { 0.450, 0.306 },
                        { 0.455, 0.273 },
                        { 0.455, 0.234 },
                        { 0.436, 0.204 },
                        { 0.410, 0.215 },
                        { 0.390, 0.200 },
                        { 0.393, 0.179 },
                        { 0.426, 0.142 },
                        { 0.472, 0.142 },
                        { 0.482, 0.165 },
                    },
                },
            },
        },
        -- 5. Morogrim Tidewalker
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Morogrim Tidewalker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 332 },
                    kind    = "path",
                    note    = "After defeating ^Fathom-Lord Karathress^, take the eastern path out of the room and follow the path to ^Morogrim Tidewalker^.",
                    minNote = "East to Morogrim",
                    points  = {
                        { 0.513, 0.143 },
                        { 0.546, 0.143 },
                        { 0.568, 0.108 },
                        { 0.583, 0.109 },
                        { 0.597, 0.129 },
                        { 0.596, 0.225 },
                    },
                },
            },
        },
        -- 6. Lady Vashj
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Lady Vashj",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 332 },
                    kind    = "path",
                    note    = "After defeating ^Morogrim Tidewalker^, continue south, and work your way around the path to the east until you reach the ^Lady Vashj Bridge Console^. Click the console to open the bridge, then cross it to reach the final boss, ^Lady Vashj^.",
                    minNote = "Console then bridge to Vashj",
                    points  = {
                        { 0.597, 0.324 },
                        { 0.596, 0.359 },
                        { 0.577, 0.378 },
                        { 0.528, 0.426 },
                        { 0.517, 0.408 },
                        { 0.492, 0.402 },
                        { 0.463, 0.418 },
                        { 0.439, 0.417 },
                        { 0.410, 0.413 },
                        { 0.410, 0.481 },
                        { 0.442, 0.484 },
                        { 0.453, 0.507 },
                        { 0.471, 0.515 },
                        { 0.482, 0.557 },
                        { 0.500, 0.563 },
                        { 0.504, 0.579 },
                        { 0.697, 0.585 },
                    },
                },
                {
                    -- Noteless, so it inherits the segment above rather than
                    -- repeating it. The console sits at the far end of that
                    -- path, just before the bridge crossing, so the star
                    -- lands on the route rather than starting it.
                    when        = { mapID = 332 },
                    kind        = "poi",
                    mapLabel    = "Click Console",
                    mapLabelPos = "below",
                    points      = {
                        { 0.511, 0.580 },
                    },
                },
            },
        },
    },
}
