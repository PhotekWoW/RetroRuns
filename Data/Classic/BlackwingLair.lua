-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackwing Lair
-- Classic, Patch 1.6.0  |  instanceID: 469  |  journalInstanceID: 742
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[469] = {
    instanceID        = 469,
    journalInstanceID = 742,
    name              = "Blackwing Lair",
    expansion         = "Classic",
    patch             = "1.6.0",

    exitNote          = "None available",
    minExitNote       = "None available",

    -- The raid runs at 40-player only. One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Blackrock Mountain interior, at the Blackrock Spire door on the
        -- Burning Steppes side. The raid portal is inside the spire, up
        -- the chain island.
        mapID = 33, x = 0.643, y = 0.710,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [287] = "Dragonmaw Garrison",
        [288] = "Halls of Strife",
        [289] = "Crimson Laboratories",
        [290] = "Nefarian's Lair",
    },

    -- Drawn on every step, not tied to one boss.
    pois = {
        -- Two labs on the same floor; one label between them is enough.
        { mapID = 289, poiKind = "alchemy", mapLabel = "Alchemy Lab",
          mapLabelPos = "below", points = { { 0.398, 0.513 } } },
        { mapID = 289, poiKind = "alchemy",
          points = { { 0.493, 0.538 } } },
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    -- Trash drops. The Encounter Journal indexes boss loot only,
    -- so these carry no journal rows and belong to no encounter.
    trashLoot = {
        { id = 19436, slot = "Back", name = "Cloak of Draconic Might", sources = { [14]=7710 }, bind = "BoP" },
        { id = 19439, slot = "Chest", name = "Interlaced Shadow Jerkin", sources = { [14]=7713 }, bind = "BoP" },
        { id = 19437, slot = "Feet", name = "Boots of Pure Thought", sources = { [14]=7711 }, bind = "BoP" },
        { id = 19438, slot = "Feet", name = "Ringo's Blizzard Boots", sources = { [14]=7712 }, bind = "BoP" },
        { id = 19435, slot = "Ranged", name = "Essence Gatherer", sources = { [14]=7709 }, bind = "BoP" },
        { id = 19354, slot = "Two-Hand", name = "Draconic Avenger", sources = { [14]=7665 }, bind = "BoP" },
        { id = 19358, slot = "Two-Hand", name = "Draconic Maul", sources = { [14]=7669 }, bind = "BoP" },
        { id = 19362, slot = "Weapon", name = "Doom's Edge", sources = { [14]=7672 }, bind = "BoP" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Razorgore the Untamed",
            journalEncounterID = 1529,
            aliases            = { "Razorgore the Untamed (lockout)" },
            soloTip            = "Do not attack ^Razorgore^ directly or you will wipe. To start the encounter properly, kill the adds on the opposite platform. Immediately click the ^Orb of Domination^ to mind control the boss. As quickly as you can, destroy all eggs in the room. You can do this by walking to each one and pressing the action button for ^Destroy Egg^. After you've killed the last egg, the mind control will end and you can kill ^Razorgore^. If you run out of time, kill adds and click the orb again to finish off the remaining eggs.",
            achievements       = {},
            loot = {
                { id = 19369, slot = "Hands", name = "Gloves of Rapid Evolution", sources = { [14]=7679 } },
                { id = 19370, slot = "Shoulder", name = "Mantle of the Blackwing Cabal", sources = { [14]=7680 } },
                { id = 19334, slot = "Two-Hand", name = "The Untamed Blade", sources = { [14]=7655 } },
                { id = 19335, slot = "Weapon", name = "Spineshatter", sources = { [14]=7656 } },
                { id = 16926, slot = "Wrist", name = "Bindings of Transcendence", sources = { [14]=6990 }, classes = { 5 } },
                { id = 16911, slot = "Wrist", name = "Bloodfang Bracers", sources = { [14]=6975 }, classes = { 4 } },
                { id = 16959, slot = "Wrist", name = "Bracelets of Wrath", sources = { [14]=7023 }, classes = { 1 } },
                { id = 16943, slot = "Wrist", name = "Bracers of Ten Storms", sources = { [14]=7007 }, classes = { 7 } },
                { id = 16935, slot = "Wrist", name = "Dragonstalker's Bracers", sources = { [14]=6999 }, classes = { 3 } },
                { id = 16951, slot = "Wrist", name = "Judgment Bindings", sources = { [14]=7015 }, classes = { 2 } },
                { id = 16934, slot = "Wrist", name = "Nemesis Bracers", sources = { [14]=6998 }, classes = { 9 } },
                { id = 16918, slot = "Wrist", name = "Netherwind Bindings", sources = { [14]=6982 }, classes = { 8 } },
                { id = 16904, slot = "Wrist", name = "Stormrage Bracers", sources = { [14]=6968 }, classes = { 11 } },
            },
        },
        {
            index              = 2,
            name               = "Vaelastrasz the Corrupt",
            journalEncounterID = 1530,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 19372, slot = "Head", name = "Helm of Endless Rage", sources = { [14]=7681 } },
                { id = 19348, slot = "Off-hand", name = "Red Dragonscale Protector", sources = { [14]=7659 } },
                { id = 16944, slot = "Waist", name = "Belt of Ten Storms", sources = { [14]=7008 }, classes = { 7 } },
                { id = 16925, slot = "Waist", name = "Belt of Transcendence", sources = { [14]=6989 }, classes = { 5 } },
                { id = 16910, slot = "Waist", name = "Bloodfang Belt", sources = { [14]=6974 }, classes = { 4 } },
                { id = 16936, slot = "Waist", name = "Dragonstalker's Belt", sources = { [14]=7000 }, classes = { 3 } },
                { id = 16952, slot = "Waist", name = "Judgment Belt", sources = { [14]=7016 }, classes = { 2 } },
                { id = 16933, slot = "Waist", name = "Nemesis Belt", sources = { [14]=6997 }, classes = { 9 } },
                { id = 16818, slot = "Waist", name = "Netherwind Belt", sources = { [14]=6903 }, classes = { 8 } },
                { id = 16903, slot = "Waist", name = "Stormrage Belt", sources = { [14]=6967 }, classes = { 11 } },
                { id = 16960, slot = "Waist", name = "Waistband of Wrath", sources = { [14]=7024 }, classes = { 1 } },
                { id = 19346, slot = "Weapon", name = "Dragonfang Blade", sources = { [14]=7657 } },
            },
        },
        {
            index              = 3,
            name               = "Broodlord Lashlayer",
            journalEncounterID = 1531,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 16906, slot = "Feet", name = "Bloodfang Boots", sources = { [14]=6970 }, classes = { 4 } },
                { id = 16919, slot = "Feet", name = "Boots of Transcendence", sources = { [14]=6983 }, classes = { 5 } },
                { id = 16941, slot = "Feet", name = "Dragonstalker's Greaves", sources = { [14]=7005 }, classes = { 3 } },
                { id = 16949, slot = "Feet", name = "Greaves of Ten Storms", sources = { [14]=7013 }, classes = { 7 } },
                { id = 16957, slot = "Feet", name = "Judgment Sabatons", sources = { [14]=7021 }, classes = { 2 } },
                { id = 16927, slot = "Feet", name = "Nemesis Boots", sources = { [14]=6991 }, classes = { 9 } },
                { id = 16912, slot = "Feet", name = "Netherwind Boots", sources = { [14]=6976 }, classes = { 8 } },
                { id = 16965, slot = "Feet", name = "Sabatons of Wrath", sources = { [14]=7029 }, classes = { 1 } },
                { id = 16898, slot = "Feet", name = "Stormrage Boots", sources = { [14]=6962 }, classes = { 11 } },
                { id = 19350, slot = "Ranged", name = "Heartstriker", sources = { [14]=7661 } },
                { id = 19373, slot = "Shoulder", name = "Black Brood Pauldrons", sources = { [14]=7682 } },
                { id = 19351, slot = "Weapon", name = "Maladath, Runed Blade of the Black Flight", sources = { [14]=7662 } },
                { id = 19374, slot = "Wrist", name = "Bracers of Arcane Accuracy", sources = { [14]=7683 } },
            },
        },
        {
            index              = 4,
            name               = "Firemaw",
            journalEncounterID = 1532,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 19398, slot = "Back", name = "Cloak of Firemaw", sources = { [14]=7699 } },
                { id = 19399, slot = "Chest", name = "Black Ash Robe", sources = { [14]=7700 } },
                { id = 16907, slot = "Hands", name = "Bloodfang Gloves", sources = { [14]=6971 }, classes = { 4 } },
                { id = 16940, slot = "Hands", name = "Dragonstalker's Gauntlets", sources = { [14]=7004 }, classes = { 3 } },
                { id = 16948, slot = "Hands", name = "Gauntlets of Ten Storms", sources = { [14]=7012 }, classes = { 7 } },
                { id = 16964, slot = "Hands", name = "Gauntlets of Wrath", sources = { [14]=7028 }, classes = { 1 } },
                { id = 16920, slot = "Hands", name = "Handguards of Transcendence", sources = { [14]=6984 }, classes = { 5 } },
                { id = 16956, slot = "Hands", name = "Judgment Gauntlets", sources = { [14]=7020 }, classes = { 2 } },
                { id = 16928, slot = "Hands", name = "Nemesis Gloves", sources = { [14]=6992 }, classes = { 9 } },
                { id = 16913, slot = "Hands", name = "Netherwind Gloves", sources = { [14]=6977 }, classes = { 8 } },
                { id = 16899, slot = "Hands", name = "Stormrage Handguards", sources = { [14]=6963 }, classes = { 11 } },
                { id = 19402, slot = "Legs", name = "Legguards of the Fallen Crusader", sources = { [14]=7703 } },
                { id = 19401, slot = "Legs", name = "Primalist's Linked Legguards", sources = { [14]=7702 } },
                { id = 19394, slot = "Shoulder", name = "Drake Talon Pauldrons", sources = { [14]=7697 } },
                { id = 19353, slot = "Two-Hand", name = "Drake Talon Cleaver", sources = { [14]=7664 } },
                { id = 19355, slot = "Two-Hand", name = "Shadow Wing Focus Staff", sources = { [14]=7666 } },
                { id = 19400, slot = "Waist", name = "Firemaw's Clutch", sources = { [14]=7701 } },
                { id = 19396, slot = "Waist", name = "Taut Dragonhide Belt", sources = { [14]=7698 } },
                { id = 19365, slot = "Weapon", name = "Claw of the Black Drake", sources = { [14]=7675 } },
            },
        },
        {
            index              = 5,
            name               = "Ebonroc",
            journalEncounterID = 1533,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 19405, slot = "Chest", name = "Malfurion's Blessed Bulwark", sources = { [14]=7705 } },
                { id = 16907, slot = "Hands", name = "Bloodfang Gloves", sources = { [14]=6971 }, classes = { 4 } },
                { id = 16940, slot = "Hands", name = "Dragonstalker's Gauntlets", sources = { [14]=7004 }, classes = { 3 } },
                { id = 19407, slot = "Hands", name = "Ebony Flame Gloves", sources = { [14]=7706 } },
                { id = 16948, slot = "Hands", name = "Gauntlets of Ten Storms", sources = { [14]=7012 }, classes = { 7 } },
                { id = 16964, slot = "Hands", name = "Gauntlets of Wrath", sources = { [14]=7028 }, classes = { 1 } },
                { id = 16920, slot = "Hands", name = "Handguards of Transcendence", sources = { [14]=6984 }, classes = { 5 } },
                { id = 16956, slot = "Hands", name = "Judgment Gauntlets", sources = { [14]=7020 }, classes = { 2 } },
                { id = 16928, slot = "Hands", name = "Nemesis Gloves", sources = { [14]=6992 }, classes = { 9 } },
                { id = 16913, slot = "Hands", name = "Netherwind Gloves", sources = { [14]=6977 }, classes = { 8 } },
                { id = 16899, slot = "Hands", name = "Stormrage Handguards", sources = { [14]=6963 }, classes = { 11 } },
                { id = 19368, slot = "Ranged", name = "Dragonbreath Hand Cannon", sources = { [14]=7678 } },
                { id = 19394, slot = "Shoulder", name = "Drake Talon Pauldrons", sources = { [14]=7697 } },
                { id = 19353, slot = "Two-Hand", name = "Drake Talon Cleaver", sources = { [14]=7664 } },
                { id = 19355, slot = "Two-Hand", name = "Shadow Wing Focus Staff", sources = { [14]=7666 } },
                { id = 19396, slot = "Waist", name = "Taut Dragonhide Belt", sources = { [14]=7698 } },
            },
        },
        {
            index              = 6,
            name               = "Flamegor",
            journalEncounterID = 1534,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 19430, slot = "Back", name = "Shroud of Pure Thought", sources = { [14]=7707 } },
                { id = 16907, slot = "Hands", name = "Bloodfang Gloves", sources = { [14]=6971 }, classes = { 4 } },
                { id = 16940, slot = "Hands", name = "Dragonstalker's Gauntlets", sources = { [14]=7004 }, classes = { 3 } },
                { id = 16948, slot = "Hands", name = "Gauntlets of Ten Storms", sources = { [14]=7012 }, classes = { 7 } },
                { id = 16964, slot = "Hands", name = "Gauntlets of Wrath", sources = { [14]=7028 }, classes = { 1 } },
                { id = 16920, slot = "Hands", name = "Handguards of Transcendence", sources = { [14]=6984 }, classes = { 5 } },
                { id = 16956, slot = "Hands", name = "Judgment Gauntlets", sources = { [14]=7020 }, classes = { 2 } },
                { id = 16928, slot = "Hands", name = "Nemesis Gloves", sources = { [14]=6992 }, classes = { 9 } },
                { id = 16913, slot = "Hands", name = "Netherwind Gloves", sources = { [14]=6977 }, classes = { 8 } },
                { id = 16899, slot = "Hands", name = "Stormrage Handguards", sources = { [14]=6963 }, classes = { 11 } },
                { id = 19433, slot = "Legs", name = "Emberweave Leggings", sources = { [14]=7708 } },
                { id = 19367, slot = "Ranged", name = "Dragon's Touch", sources = { [14]=7677 } },
                { id = 19394, slot = "Shoulder", name = "Drake Talon Pauldrons", sources = { [14]=7697 } },
                { id = 19353, slot = "Two-Hand", name = "Drake Talon Cleaver", sources = { [14]=7664 } },
                { id = 19357, slot = "Two-Hand", name = "Herald of Woe", sources = { [14]=7668 } },
                { id = 19355, slot = "Two-Hand", name = "Shadow Wing Focus Staff", sources = { [14]=7666 } },
                { id = 19396, slot = "Waist", name = "Taut Dragonhide Belt", sources = { [14]=7698 } },
            },
        },
        {
            index              = 7,
            name               = "Chromaggus",
            journalEncounterID = 1535,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 19386, slot = "Back", name = "Elementium Threaded Cloak", sources = { [14]=7689 } },
                { id = 19387, slot = "Feet", name = "Chromatic Boots", sources = { [14]=7690 } },
                { id = 19391, slot = "Feet", name = "Shimmering Geta", sources = { [14]=7694 } },
                { id = 19390, slot = "Hands", name = "Taut Dragonhide Gloves", sources = { [14]=7693 } },
                { id = 19385, slot = "Legs", name = "Empowered Leggings", sources = { [14]=7688 } },
                { id = 19349, slot = "Off-hand", name = "Elementium Reinforced Bulwark", sources = { [14]=7660 } },
                { id = 19361, slot = "Ranged", name = "Ashjre'thul, Crossbow of Smiting", sources = { [14]=7671 } },
                { id = 16832, slot = "Shoulder", name = "Bloodfang Spaulders", sources = { [14]=6917 }, classes = { 4 } },
                { id = 16937, slot = "Shoulder", name = "Dragonstalker's Spaulders", sources = { [14]=7001 }, classes = { 3 } },
                { id = 16945, slot = "Shoulder", name = "Epaulets of Ten Storms", sources = { [14]=7009 }, classes = { 7 } },
                { id = 16953, slot = "Shoulder", name = "Judgment Spaulders", sources = { [14]=7017 }, classes = { 2 } },
                { id = 16932, slot = "Shoulder", name = "Nemesis Spaulders", sources = { [14]=6996 }, classes = { 9 } },
                { id = 16917, slot = "Shoulder", name = "Netherwind Mantle", sources = { [14]=6981 }, classes = { 8 } },
                { id = 16924, slot = "Shoulder", name = "Pauldrons of Transcendence", sources = { [14]=6988 }, classes = { 5 } },
                { id = 16961, slot = "Shoulder", name = "Pauldrons of Wrath", sources = { [14]=7025 }, classes = { 1 } },
                { id = 16902, slot = "Shoulder", name = "Stormrage Pauldrons", sources = { [14]=6966 }, classes = { 11 } },
                { id = 19389, slot = "Shoulder", name = "Taut Dragonhide Shoulderpads", sources = { [14]=7692 } },
                { id = 19388, slot = "Waist", name = "Angelista's Grasp", sources = { [14]=7691 } },
                { id = 19392, slot = "Waist", name = "Girdle of the Fallen Crusader", sources = { [14]=7695 } },
                { id = 19393, slot = "Waist", name = "Primalist's Linked Waistguard", sources = { [14]=7696 } },
                { id = 19352, slot = "Weapon", name = "Chromatically Tempered Sword", sources = { [14]=7663 } },
                { id = 19347, slot = "Weapon", name = "Claw of Chromaggus", sources = { [14]=7658 } },
            },
        },
        {
            index              = 8,
            name               = "Nefarian",
            journalEncounterID = 1536,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 19378, slot = "Back", name = "Cloak of the Brood Lord", sources = { [14]=7685 } },
                { id = 16905, slot = "Chest", name = "Bloodfang Chestpiece", sources = { [14]=6969 }, classes = { 4 } },
                { id = 16950, slot = "Chest", name = "Breastplate of Ten Storms", sources = { [14]=7014 }, classes = { 7 } },
                { id = 16966, slot = "Chest", name = "Breastplate of Wrath", sources = { [14]=7030 }, classes = { 1 } },
                { id = 16942, slot = "Chest", name = "Dragonstalker's Breastplate", sources = { [14]=7006 }, classes = { 3 } },
                { id = 16958, slot = "Chest", name = "Judgment Breastplate", sources = { [14]=7022 }, classes = { 2 } },
                { id = 16931, slot = "Chest", name = "Nemesis Robes", sources = { [14]=6995 }, classes = { 9 } },
                { id = 16916, slot = "Chest", name = "Netherwind Robes", sources = { [14]=6980 }, classes = { 8 } },
                { id = 16923, slot = "Chest", name = "Robes of Transcendence", sources = { [14]=6987 }, classes = { 5 } },
                { id = 16897, slot = "Chest", name = "Stormrage Chestguard", sources = { [14]=6961 }, classes = { 11 } },
                { id = 19381, slot = "Feet", name = "Boots of the Shadow Flame", sources = { [14]=7687 } },
                { id = 16908, slot = "Head", name = "Bloodfang Hood", sources = { [14]=6972 }, classes = { 4 } },
                { id = 16939, slot = "Head", name = "Dragonstalker's Helm", sources = { [14]=7003 }, classes = { 3 } },
                { id = 16921, slot = "Head", name = "Halo of Transcendence", sources = { [14]=6985 }, classes = { 5 } },
                { id = 16963, slot = "Head", name = "Helm of Wrath", sources = { [14]=7027 }, classes = { 1 } },
                { id = 16947, slot = "Head", name = "Helmet of Ten Storms", sources = { [14]=7011 }, classes = { 7 } },
                { id = 16955, slot = "Head", name = "Judgment Crown", sources = { [14]=7019 }, classes = { 2 } },
                { id = 19375, slot = "Head", name = "Mish'undare, Circlet of the Mind Flayer", sources = { [14]=7684 } },
                { id = 16929, slot = "Head", name = "Nemesis Skullcap", sources = { [14]=6993 }, classes = { 9 } },
                { id = 16914, slot = "Head", name = "Netherwind Crown", sources = { [14]=6978 }, classes = { 8 } },
                { id = 16900, slot = "Head", name = "Stormrage Cover", sources = { [14]=6964 }, classes = { 11 } },
                { id = 19364, slot = "Two-Hand", name = "Ashkandi, Greatsword of the Brotherhood", sources = { [14]=7674 } },
                { id = 19356, slot = "Two-Hand", name = "Staff of the Shadow Flame", sources = { [14]=7667 } },
                { id = 19380, slot = "Waist", name = "Therazane's Link", sources = { [14]=7686 } },
                { id = 19363, slot = "Weapon", name = "Crul'shorukh, Edge of Chaos", sources = { [14]=7673 } },
                { id = 19360, slot = "Weapon", name = "Lok'amir il Romathis", sources = { [14]=7670 } },
            },
        },
    },

    routing = {

        -- 1. Razorgore the Untamed
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Razorgore the Untamed",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 287 },
                    kind    = "path",
                    note    = "After zoning in, proceed straight ahead to ^Razorgore^. |cffF259C7CAUTION!|r Do not attack ^Razorgore^ directly. Review the note!",
                    minNote = "Read Note for Razorgore",
                    points  = {
                        { 0.516, 0.814 },
                        { 0.435, 0.637 },
                    },
                },
            },
        },

        -- 2. Vaelastrasz the Corrupt
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Vaelastrasz the Corrupt",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 287 },
                    kind    = "path",
                    note    = "After defeating ^Razorgore^, proceed northwest into the next room. Talk to ^Vaelastrasz the Corrupt^ to start the encounter.",
                    minNote = "Northwest to Vaelastrasz",
                    points  = {
                        { 0.373, 0.511 },
                        { 0.334, 0.424 },
                        { 0.328, 0.313 },
                    },
                },
            },
        },

        -- 3. Broodlord Lashlayer
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Broodlord Lashlayer",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 287 },
                    kind    = "path",
                    note    = "After defeating ^Vaelastrasz^, take the northwest stairwell out of the room.",
                    minNote = "Take northwest stairwell",
                    points  = {
                        { 0.331, 0.233 },
                        { 0.350, 0.166 },
                        { 0.393, 0.126 },
                        { 0.381, 0.100 },
                        { 0.342, 0.138 },
                    },
                },
                {
                    when    = { mapID = 288 },
                    kind    = "path",
                    note    = "Travel along the ledge into the next room. Stick to one side of the room to avoid overlapping auras, and click ^Suppression Devices^ to temporarily disable them as you move through the room.",
                    minNote = "Path to Broodlord",
                    points  = {
                        { 0.450, 0.213 },
                        { 0.352, 0.314 },
                        { 0.383, 0.394 },
                        { 0.342, 0.435 },
                        { 0.282, 0.563 },
                        { 0.246, 0.604 },
                        { 0.276, 0.673 },
                        { 0.394, 0.561 },
                        { 0.490, 0.770 },
                        { 0.493, 0.803 },
                        { 0.517, 0.852 },
                    },
                },
                {
                    when    = { mapID = 289 },
                    kind    = "path",
                    note    = "You will find ^Broodlord Lashlayer^ at the end of the next room.",
                    minNote = "Ahead to Broodlord",
                    points  = {
                        { 0.552, 0.889 },
                        { 0.580, 0.860 },
                        { 0.495, 0.676 },
                        { 0.496, 0.652 },
                    },
                },
            },
        },

        -- 4. Firemaw
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Firemaw",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 289 },
                    kind    = "path",
                    note    = "After killing ^Broodlord Lashlayer^, continue northwest to find ^Firemaw^ patrolling the path ahead.",
                    minNote = "Northwest to Firemaw",
                    points  = {
                        { 0.483, 0.572 },
                        { 0.471, 0.541 },
                        { 0.462, 0.462 },
                    },
                },
            },
        },

        -- 5. Ebonroc
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Ebonroc",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 289 },
                    kind    = "path",
                    note    = "After defeating ^Firemaw^, continue northwest until you reach ^Ebonroc^.",
                    minNote = "Northwest to Ebonroc",
                    points  = {
                        { 0.440, 0.377 },
                        { 0.365, 0.371 },
                        { 0.313, 0.416 },
                        { 0.281, 0.347 },
                        { 0.327, 0.244 },
                    },
                },
            },
        },

        -- 6. Flamegor
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Flamegor",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 289 },
                    kind    = "path",
                    note    = "After defeating ^Ebonroc^, go up the ramp behind him.",
                    minNote = "Go up ramp",
                    points  = {
                        { 0.373, 0.204 },
                        { 0.396, 0.211 },
                        { 0.412, 0.194 },
                        { 0.409, 0.163 },
                    },
                },
                {
                    when    = { mapID = 290 },
                    kind    = "path",
                    note    = "In the next room, ^Flamegor^ will be flying around right in front of you.",
                    minNote = "Flamegor ahead",
                    points  = {
                        { 0.293, 0.478 },
                        { 0.313, 0.489 },
                        { 0.332, 0.473 },
                        { 0.352, 0.406 },
                    },
                },
            },
        },

        -- 7. Chromaggus
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Chromaggus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 290 },
                    kind    = "path",
                    note    = "After killing ^Flamegor^, continue southeast into the next room to find a lever. Pull it to release ^Chromaggus^.",
                    minNote = "Southeast to Chromaggus",
                    points  = {
                        { 0.393, 0.475 },
                        { 0.439, 0.585 },
                        { 0.426, 0.691 },
                        { 0.416, 0.702 },
                    },
                },
                {
                    when        = { mapID = 290 },
                    kind        = "poi",
                    mapLabel    = "Click Lever",
                    mapLabelPos = "below",
                    points      = {
                        { 0.503, 0.715 },
                    },
                },
            },
        },

        -- 8. Nefarian
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Nefarian",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 290 },
                    kind    = "path",
                    note    = "After killing ^Chromaggus^, exit northeast and follow the path to the next room. Talk to ^Lord Victor Nefarius^ to begin the final encounter against ^Nefarian^.",
                    minNote = "Northeast to Nefarian",
                    points  = {
                        { 0.506, 0.610 },
                        { 0.549, 0.572 },
                        { 0.596, 0.674 },
                        { 0.682, 0.690 },
                    },
                },
                {
                    when        = { mapID = 290 },
                    kind        = "poi",
                    mapLabel    = "Talk to Victor",
                    mapLabelPos = "below",
                    points      = {
                        { 0.761, 0.892 },
                    },
                },
            },
        },

    },
}
