-------------------------------------------------------------------------------
-- RetroRuns Data -- Ruins of Ahn'Qiraj
-- Classic, Patch 1.9.0  |  instanceID: 509  |  journalInstanceID: 743
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[509] = {
    instanceID        = 509,
    journalInstanceID = 743,
    name              = "Ruins of Ahn'Qiraj",
    expansion         = "Classic",
    patch             = "1.9.0",

    exitNote          = "None available",
    minExitNote       = "None available",

    -- One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Ahn'Qiraj: The Fallen Kingdom, at the Scarab Wall gate in
        -- southern Silithus.
        mapID = 327, x = 0.5884, y = 0.1450,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [247] = "Ruins of Ahn'Qiraj",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [20885] = { 1, 2, 4, 5 },   -- Qiraji Martial Drape
            [20886] = { 3, 4, 5, 6 },   -- Qiraji Spiked Hilt
            [20889] = { 1, 2, 4, 5 },   -- Qiraji Regal Drape
            [20890] = { 3, 4, 5, 6 },   -- Qiraji Ornate Hilt
        },
    },

    -- The tokens are quest turn-ins, not vendor purchases: two NPCs at the
    -- Ahn'Qiraj gates take them, and each turn-in also costs an idol pair,
    -- scarabs from trash inside, and Cenarion Circle reputation. The token,
    -- the materials and the reputation tier all differ per class, so each
    -- spot carries a byClass table and the hint follows the class dropdown.
    -- Classes with no AQ20 set (Death Knight, Monk, Demon Hunter, Evoker)
    -- are absent and the hint hides for them. Both NPCs stand beside the
    -- raid entrance, so no travel point is carried.
    tokenVendors = {
        bosses  = { 1, 2, 3, 4, 5, 6 },
        -- Cenarion Circle. The client supplies the localized name.
        repFactionID = 609,
        heading = "These items are acquired by redeeming Qiraji tokens at the AQ20 entrance.",
        locations = {
            {
                place      = "Cloaks",
                vendorName = "From Keyl Swiftclaw",
                -- Bosses that drop a Drape token.
                bosses     = { 1, 2, 4, 5 },
                -- Both NPCs stand together at the gates, so one point serves
                -- the whole hint. Derived, not a live capture.
                mapID = 327, x = 0.594, y = 0.140,
                byClass = {
                    [1]  = { repStanding = 7, token = 20885,
                             mats = { { { 20867, 2 } },
                                      { { 20860, 5 }, { 20864, 5 } } } },
                    [2]  = { repStanding = 7, token = 20889,
                             mats = { { { 20871, 2 } },
                                      { { 20863, 5 }, { 20859, 5 } } } },
                    [3]  = { repStanding = 7, token = 20889,
                             mats = { { { 20868, 2 } },
                                      { { 20862, 5 }, { 20858, 5 } } } },
                    [4]  = { repStanding = 7, token = 20885,
                             mats = { { { 20866, 2 } },
                                      { { 20865, 5 }, { 20861, 5 } } } },
                    [5]  = { repStanding = 7, token = 20885,
                             mats = { { { 20870, 2 } },
                                      { { 20863, 5 }, { 20859, 5 } } } },
                    [7]  = { repStanding = 7, token = 20889,
                             mats = { { { 20871, 2 } },
                                      { { 20859, 5 }, { 20863, 5 } } } },
                    [8]  = { repStanding = 7, token = 20885,
                             mats = { { { 20873, 2 } },
                                      { { 20862, 5 }, { 20858, 5 } } } },
                    [9]  = { repStanding = 7, token = 20889,
                             mats = { { { 20869, 2 } },
                                      { { 20865, 5 }, { 20861, 5 } } } },
                    [11] = { repStanding = 7, token = 20889,
                             mats = { { { 20872, 2 } },
                                      { { 20860, 5 }, { 20864, 5 } } } },
                },
            },
            {
                place      = "Weapons",
                vendorName = "From Warden Haro",
                -- Bosses that drop a Hilt token.
                bosses     = { 3, 4, 5, 6 },
                -- Same point as the cloak spot: the two NPCs stand together.
                -- Repeated so the bosses that show only this half still get
                -- the travel button.
                mapID = 327, x = 0.594, y = 0.140,
                byClass = {
                    [1]  = { repStanding = 8, token = 20886,
                             mats = { { { 20873, 2 } },
                                      { { 20858, 5 }, { 20862, 5 } } } },
                    [2]  = { repStanding = 8, token = 20886,
                             mats = { { { 20869, 2 } },
                                      { { 20865, 5 }, { 20861, 5 } } } },
                    [3]  = { repStanding = 8, token = 20886,
                             mats = { { { 20866, 2 } },
                                      { { 20864, 5 }, { 20860, 5 } } } },
                    [4]  = { repStanding = 8, token = 20886,
                             mats = { { { 20872, 2 } },
                                      { { 20863, 5 }, { 20859, 5 } } } },
                    [5]  = { repStanding = 8, token = 20890,
                             mats = { { { 20868, 2 } },
                                      { { 20865, 5 }, { 20861, 5 } } } },
                    [7]  = { repStanding = 8, token = 20886,
                             mats = { { { 20869, 2 } },
                                      { { 20865, 5 }, { 20861, 5 } } } },
                    [8]  = { repStanding = 8, token = 20890,
                             mats = { { { 20871, 2 } },
                                      { { 20864, 5 }, { 20860, 5 } } } },
                    [9]  = { repStanding = 8, token = 20890,
                             mats = { { { 20867, 2 } },
                                      { { 20863, 5 }, { 20859, 5 } } } },
                    [11] = { repStanding = 8, token = 20890,
                             mats = { { { 20870, 2 } },
                                      { { 20858, 5 }, { 20862, 5 } } } },
                },
            },
        },
    },

    bosses = {
        {
            index              = 1,
            name               = "Kurinnaxx",
            journalEncounterID = 1537,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 21397, slot = "Back", name = "Cape of Eternal Justice", sources = { [14]=8412 }, classes = { 2 } },
                { id = 21409, slot = "Back", name = "Cloak of Unending Life", sources = { [14]=8420 }, classes = { 11 } },
                { id = 21406, slot = "Back", name = "Cloak of Veiled Shadows", sources = { [14]=8418 }, classes = { 4 } },
                { id = 21400, slot = "Back", name = "Cloak of the Gathering Storm", sources = { [14]=8414 }, classes = { 7 } },
                { id = 21403, slot = "Back", name = "Cloak of the Unseen Path", sources = { [14]=8416 }, classes = { 3 } },
                { id = 21394, slot = "Back", name = "Drape of Unyielding Strength", sources = { [14]=8410 }, classes = { 1 } },
                { id = 21415, slot = "Back", name = "Drape of Vaulted Secrets", sources = { [14]=8424 }, classes = { 8 } },
                { id = 21412, slot = "Back", name = "Shroud of Infinite Wisdom", sources = { [14]=8422 }, classes = { 5 } },
                { id = 21418, slot = "Back", name = "Shroud of Unspoken Names", sources = { [14]=8426 }, classes = { 9 } },
                { id = 21499, slot = "Chest", name = "Vestments of the Shifting Sands", sources = { [14]=8499 } },
                { id = 21501, slot = "Hands", name = "Toughened Silithid Hide Gloves", sources = { [14]=8501 } },
                { id = 21500, slot = "Waist", name = "Belt of the Inquisition", sources = { [14]=8500 } },
                { id = 21503, slot = "Waist", name = "Belt of the Sand Reaver", sources = { [14]=8503 } },
                { id = 21498, slot = "Weapon", name = "Qiraji Sacrificial Dagger", sources = { [14]=8498 } },
                { id = 21502, slot = "Wrist", name = "Sand Reaver Wristguards", sources = { [14]=8502 } },
            },
        },
        {
            index              = 2,
            name               = "General Rajaxx",
            journalEncounterID = 1538,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 21397, slot = "Back", name = "Cape of Eternal Justice", sources = { [14]=8412 }, classes = { 2 } },
                { id = 21409, slot = "Back", name = "Cloak of Unending Life", sources = { [14]=8420 }, classes = { 11 } },
                { id = 21406, slot = "Back", name = "Cloak of Veiled Shadows", sources = { [14]=8418 }, classes = { 4 } },
                { id = 21400, slot = "Back", name = "Cloak of the Gathering Storm", sources = { [14]=8414 }, classes = { 7 } },
                { id = 21403, slot = "Back", name = "Cloak of the Unseen Path", sources = { [14]=8416 }, classes = { 3 } },
                { id = 21394, slot = "Back", name = "Drape of Unyielding Strength", sources = { [14]=8410 }, classes = { 1 } },
                { id = 21415, slot = "Back", name = "Drape of Vaulted Secrets", sources = { [14]=8424 }, classes = { 8 } },
                { id = 21412, slot = "Back", name = "Shroud of Infinite Wisdom", sources = { [14]=8422 }, classes = { 5 } },
                { id = 21418, slot = "Back", name = "Shroud of Unspoken Names", sources = { [14]=8426 }, classes = { 9 } },
                { id = 21497, slot = "Feet", name = "Boots of the Qiraji General", sources = { [14]=8497 } },
                { id = 21493, slot = "Feet", name = "Boots of the Vanguard", sources = { [14]=8493 } },
                { id = 21495, slot = "Legs", name = "Legplates of the Qiraji Command", sources = { [14]=8495 } },
                { id = 21492, slot = "Two-Hand", name = "Manslayer of the Qiraji", sources = { [14]=8492 } },
                { id = 21494, slot = "Waist", name = "Southwind's Grasp", sources = { [14]=8494 } },
                { id = 21496, slot = "Wrist", name = "Bracers of Qiraji Command", sources = { [14]=8496 } },
            },
        },
        {
            index              = 3,
            name               = "Moam",
            journalEncounterID = 1539,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 21470, slot = "Back", name = "Cloak of the Savior", sources = { [14]=8474 } },
                { id = 21467, slot = "Chest", name = "Thick Silithid Chestguard", sources = { [14]=8471 } },
                { id = 21469, slot = "Hands", name = "Gauntlets of Southwind", sources = { [14]=8473 } },
                { id = 21479, slot = "Hands", name = "Gauntlets of the Immovable", sources = { [14]=8481 } },
                { id = 21472, slot = "Head", name = "Dustwind Turban", sources = { [14]=8476 } },
                { id = 21455, slot = "Head", name = "Southwind Helm", sources = { [14]=8459 } },
                { id = 21471, slot = "Held In Off-hand", name = "Talon of Furious Concentration", sources = { [14]=8475 } },
                { id = 21475, slot = "Legs", name = "Legplates of the Destroyer", sources = { [14]=8478 } },
                { id = 21476, slot = "Legs", name = "Obsidian Scaled Leggings", sources = { [14]=8479 } },
                { id = 21474, slot = "Shoulder", name = "Chitinous Shoulderguards", sources = { [14]=8477 } },
                { id = 21468, slot = "Shoulder", name = "Mantle of Maz'Nadir", sources = { [14]=8472 } },
                { id = 21407, slot = "Two-Hand", name = "Mace of Unending Life", sources = { [14]=8419 }, classes = { 11 } },
                { id = 21395, slot = "Weapon", name = "Blade of Eternal Justice", sources = { [14]=8411 }, classes = { 2 } },
                { id = 21413, slot = "Weapon", name = "Blade of Vaulted Secrets", sources = { [14]=8423 }, classes = { 8 } },
                { id = 21404, slot = "Weapon", name = "Dagger of Veiled Shadows", sources = { [14]=8417 }, classes = { 4 } },
                { id = 21410, slot = "Weapon", name = "Gavel of Infinite Wisdom", sources = { [14]=8421 }, classes = { 5 } },
                { id = 21398, slot = "Weapon", name = "Hammer of the Gathering Storm", sources = { [14]=8413 }, classes = { 7 } },
                { id = 21416, slot = "Weapon", name = "Kris of Unspoken Names", sources = { [14]=8425 }, classes = { 9 } },
                { id = 21401, slot = "Weapon", name = "Scythe of the Unseen Path", sources = { [14]=8415 }, classes = { 3 } },
                { id = 21392, slot = "Weapon", name = "Sickle of Unyielding Strength", sources = { [14]=8409 }, classes = { 1 } },
            },
        },
        {
            index              = 4,
            name               = "Buru the Gorger",
            journalEncounterID = 1540,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 21397, slot = "Back", name = "Cape of Eternal Justice", sources = { [14]=8412 }, classes = { 2 } },
                { id = 21409, slot = "Back", name = "Cloak of Unending Life", sources = { [14]=8420 }, classes = { 11 } },
                { id = 21406, slot = "Back", name = "Cloak of Veiled Shadows", sources = { [14]=8418 }, classes = { 4 } },
                { id = 21400, slot = "Back", name = "Cloak of the Gathering Storm", sources = { [14]=8414 }, classes = { 7 } },
                { id = 21403, slot = "Back", name = "Cloak of the Unseen Path", sources = { [14]=8416 }, classes = { 3 } },
                { id = 21394, slot = "Back", name = "Drape of Unyielding Strength", sources = { [14]=8410 }, classes = { 1 } },
                { id = 21415, slot = "Back", name = "Drape of Vaulted Secrets", sources = { [14]=8424 }, classes = { 8 } },
                { id = 21412, slot = "Back", name = "Shroud of Infinite Wisdom", sources = { [14]=8422 }, classes = { 5 } },
                { id = 21418, slot = "Back", name = "Shroud of Unspoken Names", sources = { [14]=8426 }, classes = { 9 } },
                { id = 21489, slot = "Feet", name = "Quicksand Waders", sources = { [14]=8489 } },
                { id = 21490, slot = "Feet", name = "Slime Kickers", sources = { [14]=8490 } },
                { id = 21486, slot = "Hands", name = "Gloves of the Swarm", sources = { [14]=8487 } },
                { id = 21487, slot = "Hands", name = "Slimy Scaled Gauntlets", sources = { [14]=8488 } },
                { id = 21485, slot = "Off-hand", name = "Buru's Skull Fragment", sources = { [14]=8486 } },
                { id = 21407, slot = "Two-Hand", name = "Mace of Unending Life", sources = { [14]=8419 }, classes = { 11 } },
                { id = 21395, slot = "Weapon", name = "Blade of Eternal Justice", sources = { [14]=8411 }, classes = { 2 } },
                { id = 21413, slot = "Weapon", name = "Blade of Vaulted Secrets", sources = { [14]=8423 }, classes = { 8 } },
                { id = 21404, slot = "Weapon", name = "Dagger of Veiled Shadows", sources = { [14]=8417 }, classes = { 4 } },
                { id = 21410, slot = "Weapon", name = "Gavel of Infinite Wisdom", sources = { [14]=8421 }, classes = { 5 } },
                { id = 21398, slot = "Weapon", name = "Hammer of the Gathering Storm", sources = { [14]=8413 }, classes = { 7 } },
                { id = 21416, slot = "Weapon", name = "Kris of Unspoken Names", sources = { [14]=8425 }, classes = { 9 } },
                { id = 21401, slot = "Weapon", name = "Scythe of the Unseen Path", sources = { [14]=8415 }, classes = { 3 } },
                { id = 21392, slot = "Weapon", name = "Sickle of Unyielding Strength", sources = { [14]=8409 }, classes = { 1 } },
                { id = 21491, slot = "Wrist", name = "Scaled Bracers of the Gorger", sources = { [14]=8491 } },
            },
        },
        {
            index              = 5,
            name               = "Ayamiss the Hunter",
            journalEncounterID = 1541,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 21397, slot = "Back", name = "Cape of Eternal Justice", sources = { [14]=8412 }, classes = { 2 } },
                { id = 21409, slot = "Back", name = "Cloak of Unending Life", sources = { [14]=8420 }, classes = { 11 } },
                { id = 21406, slot = "Back", name = "Cloak of Veiled Shadows", sources = { [14]=8418 }, classes = { 4 } },
                { id = 21400, slot = "Back", name = "Cloak of the Gathering Storm", sources = { [14]=8414 }, classes = { 7 } },
                { id = 21403, slot = "Back", name = "Cloak of the Unseen Path", sources = { [14]=8416 }, classes = { 3 } },
                { id = 21394, slot = "Back", name = "Drape of Unyielding Strength", sources = { [14]=8410 }, classes = { 1 } },
                { id = 21415, slot = "Back", name = "Drape of Vaulted Secrets", sources = { [14]=8424 }, classes = { 8 } },
                { id = 21412, slot = "Back", name = "Shroud of Infinite Wisdom", sources = { [14]=8422 }, classes = { 5 } },
                { id = 21418, slot = "Back", name = "Shroud of Unspoken Names", sources = { [14]=8426 }, classes = { 9 } },
                { id = 21481, slot = "Feet", name = "Boots of the Desert Protector", sources = { [14]=8483 } },
                { id = 21482, slot = "Feet", name = "Boots of the Fiery Sands", sources = { [14]=8484 } },
                { id = 21479, slot = "Hands", name = "Gauntlets of the Immovable", sources = { [14]=8481 } },
                { id = 21480, slot = "Hands", name = "Scaled Silithid Gauntlets", sources = { [14]=8482 } },
                { id = 21484, slot = "Head", name = "Helm of Regrowth", sources = { [14]=8485 } },
                { id = 21478, slot = "Ranged", name = "Bow of Taut Sinew", sources = { [14]=8480 } },
                { id = 21407, slot = "Two-Hand", name = "Mace of Unending Life", sources = { [14]=8419 }, classes = { 11 } },
                { id = 21395, slot = "Weapon", name = "Blade of Eternal Justice", sources = { [14]=8411 }, classes = { 2 } },
                { id = 21413, slot = "Weapon", name = "Blade of Vaulted Secrets", sources = { [14]=8423 }, classes = { 8 } },
                { id = 21404, slot = "Weapon", name = "Dagger of Veiled Shadows", sources = { [14]=8417 }, classes = { 4 } },
                { id = 21410, slot = "Weapon", name = "Gavel of Infinite Wisdom", sources = { [14]=8421 }, classes = { 5 } },
                { id = 21398, slot = "Weapon", name = "Hammer of the Gathering Storm", sources = { [14]=8413 }, classes = { 7 } },
                { id = 21416, slot = "Weapon", name = "Kris of Unspoken Names", sources = { [14]=8425 }, classes = { 9 } },
                { id = 21401, slot = "Weapon", name = "Scythe of the Unseen Path", sources = { [14]=8415 }, classes = { 3 } },
                { id = 21392, slot = "Weapon", name = "Sickle of Unyielding Strength", sources = { [14]=8409 }, classes = { 1 } },
                { id = 21466, slot = "Weapon", name = "Stinger of Ayamiss", sources = { [14]=8470 } },
            },
        },
        {
            index              = 6,
            name               = "Ossirian the Unscarred",
            journalEncounterID = 1542,
            aliases            = { "Ossirian the Unscarred (lockout)" },
            achievements       = {},
            loot = {
                { id = 21456, slot = "Back", name = "Sandstorm Cloak", sources = { [14]=8460 } },
                { id = 21458, slot = "Hands", name = "Gauntlets of New Life", sources = { [14]=8462 } },
                { id = 21462, slot = "Hands", name = "Gloves of Dark Wisdom", sources = { [14]=8466 } },
                { id = 21460, slot = "Head", name = "Helm of Domination", sources = { [14]=8464 } },
                { id = 21461, slot = "Legs", name = "Leggings of the Black Blizzard", sources = { [14]=8465 } },
                { id = 21459, slot = "Ranged", name = "Crossbow of Imminent Doom", sources = { [14]=8463 } },
                { id = 21453, slot = "Shoulder", name = "Mantle of the Horusath", sources = { [14]=8457 } },
                { id = 21454, slot = "Shoulder", name = "Runic Stone Shoulders", sources = { [14]=8458 } },
                { id = 21407, slot = "Two-Hand", name = "Mace of Unending Life", sources = { [14]=8419 }, classes = { 11 } },
                { id = 21452, slot = "Two-Hand", name = "Staff of the Ruins", sources = { [14]=8456 } },
                { id = 21463, slot = "Waist", name = "Ossirian's Binding", sources = { [14]=8467 } },
                { id = 21395, slot = "Weapon", name = "Blade of Eternal Justice", sources = { [14]=8411 }, classes = { 2 } },
                { id = 21413, slot = "Weapon", name = "Blade of Vaulted Secrets", sources = { [14]=8423 }, classes = { 8 } },
                { id = 21404, slot = "Weapon", name = "Dagger of Veiled Shadows", sources = { [14]=8417 }, classes = { 4 } },
                { id = 21410, slot = "Weapon", name = "Gavel of Infinite Wisdom", sources = { [14]=8421 }, classes = { 5 } },
                { id = 21398, slot = "Weapon", name = "Hammer of the Gathering Storm", sources = { [14]=8413 }, classes = { 7 } },
                { id = 21416, slot = "Weapon", name = "Kris of Unspoken Names", sources = { [14]=8425 }, classes = { 9 } },
                { id = 21715, slot = "Weapon", name = "Sand Polished Hammer", sources = { [14]=8608 } },
                { id = 21401, slot = "Weapon", name = "Scythe of the Unseen Path", sources = { [14]=8415 }, classes = { 3 } },
                { id = 21392, slot = "Weapon", name = "Sickle of Unyielding Strength", sources = { [14]=8409 }, classes = { 1 } },
                { id = 21457, slot = "Wrist", name = "Bracers of Brutality", sources = { [14]=8461 } },
                { id = 21464, slot = "Wrist", name = "Shackles of the Unscarred", sources = { [14]=8468 } },
            },
        },
    },

    routing = {

        -- 1. Kurinnaxx
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Kurinnaxx",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 247 },
                    kind    = "path",
                    note    = "After zoning in, take a right and follow the path to ^Kurinnaxx^.",
                    minNote = "Right to Kurinnaxx",
                    points  = {
                        { 0.598, 0.168 },
                        { 0.631, 0.194 },
                        { 0.582, 0.282 },
                        { 0.572, 0.323 },
                    },
                },
            },
        },

        -- 2. General Rajaxx
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "General Rajaxx",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 247 },
                    kind    = "path",
                    note    = "After defeating ^Kurinnaxx^, continue south until you reach ^General Rajaxx^.",
                    minNote = "South to General Rajaxx",
                    points  = {
                        { 0.585, 0.399 },
                        { 0.591, 0.433 },
                        { 0.588, 0.456 },
                    },
                },
            },
        },

        -- 3. Moam
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Moam",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 247 },
                    kind    = "path",
                    note    = "After defeating ^General Rajaxx^, travel northwest until you reach ^Moam^.",
                    minNote = "Northwest to Moam",
                    points  = {
                        { 0.539, 0.488 },
                        { 0.538, 0.425 },
                        { 0.495, 0.388 },
                        { 0.442, 0.331 },
                        { 0.372, 0.327 },
                        { 0.353, 0.343 },
                    },
                },
            },
        },

        -- 4. Buru the Gorger
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Buru the Gorger",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 247 },
                    kind    = "path",
                    note    = "After killing ^Moam^, travel far southeast until you reach ^Buru the Gorger^.",
                    minNote = "Southeast to Buru",
                    points  = {
                        { 0.355, 0.342 },
                        { 0.393, 0.333 },
                        { 0.446, 0.340 },
                        { 0.498, 0.391 },
                        { 0.541, 0.435 },
                        { 0.539, 0.493 },
                        { 0.574, 0.530 },
                        { 0.610, 0.557 },
                        { 0.675, 0.612 },
                    },
                },
            },
        },

        -- 5. Ayamiss the Hunter
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Ayamiss the Hunter",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 247 },
                    kind    = "path",
                    note    = "After defeating ^Buru the Gorger^, travel south up the ramp and loop around to the left to find ^Ayamiss the Hunter^.",
                    minNote = "Up ramp to Ayamiss",
                    points  = {
                        { 0.705, 0.667 },
                        { 0.687, 0.735 },
                        { 0.665, 0.789 },
                        { 0.655, 0.814 },
                        { 0.627, 0.812 },
                        { 0.607, 0.801 },
                        { 0.589, 0.808 },
                        { 0.577, 0.834 },
                        { 0.585, 0.864 },
                        { 0.594, 0.876 },
                    },
                },
            },
        },

        -- 6. Ossirian the Unscarred
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Ossirian the Unscarred",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 247 },
                    kind    = "path",
                    note    = "After killing ^Ayamiss^, head northwest up the stair path until you reach the final boss, ^Ossirian the Unscarred^.",
                    minNote = "Northwest to Ossirian",
                    points  = {
                        { 0.586, 0.860 },
                        { 0.506, 0.741 },
                        { 0.454, 0.720 },
                    },
                },
            },
        },

    },
}
