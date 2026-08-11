-------------------------------------------------------------------------------
-- RetroRuns Data -- Black Temple
-- Burning Crusade, Patch 2.1.0  |  instanceID: 564  |  journalInstanceID: 751
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[564] = {
    instanceID        = 564,
    journalInstanceID = 751,
    name              = "Black Temple",
    expansion         = "Burning Crusade",
    patch             = "2.1.0",

    exitNote          = "None available",
    minExitNote       = "None available",

    -- The raid runs at a single Normal difficulty and one weekly lockout.
    -- It also opens at Timewalking during that event, which is group
    -- content and not covered here.
    difficultyModel   = "single",

    entrance = {
        -- Shadowmoon Valley, at the temple's western gate.
        mapID = 104, x = 0.710, y = 0.466,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [340] = "Karabor Sewers",
        [339] = "Black Temple",
        [341] = "Sanctuary of Shadows",
        [342] = "Halls of Anguish",
        [343] = "Gorefiend's Vigil",
        [344] = "Den of Mortal Delights",
        [345] = "Chamber of Command",
        [346] = "Temple Summit",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [31101] = 7,   -- Pauldrons of the Forgotten Conqueror
            [31102] = 7,   -- Pauldrons of the Forgotten Vanquisher
            [31103] = 7,   -- Pauldrons of the Forgotten Protector
            [31098] = 8,   -- Leggings of the Forgotten Conqueror
            [31099] = 8,   -- Leggings of the Forgotten Vanquisher
            [31100] = 8,   -- Leggings of the Forgotten Protector
            [31089] = 9,   -- Chestguard of the Forgotten Conqueror
            [31090] = 9,   -- Chestguard of the Forgotten Vanquisher
            [31091] = 9,   -- Chestguard of the Forgotten Protector
        },
    },


    -- Trash drops. The Encounter Journal indexes boss loot only,
    -- so these carry no journal rows and belong to no encounter.
    trashLoot = {
        { id = 34012, slot = "Back", name = "Shroud of the Final Stand", sources = { [14]=15734 }, bind = "BoP" },
        { id = 32593, slot = "Feet", name = "Treads of the Den Mother", sources = { [14]=15045 }, bind = "BoP" },
        { id = 32608, slot = "Hands", name = "Pillager's Gauntlets", sources = { [14]=15052 }, bind = "BoP" },
        { id = 34011, slot = "Off-hand", name = "Illidari Runeshield", sources = { [14]=15733 }, bind = "BoP" },
        { id = 32606, slot = "Waist", name = "Girdle of the Lightbearer", sources = { [14]=15050 }, bind = "BoP" },
        { id = 32943, slot = "Weapon", name = "Swiftsteel Bludgeon", sources = { [14]=15193 }, bind = "BoP" },
    },
    bosses = {
        {
            index              = 1,
            name               = "High Warlord Naj'entus",
            journalEncounterID = 1582,
            achievements       = {},
            loot = {
                { id = 32242, slot = "Feet", name = "Boots of Oceanic Fury", sources = { [14]=14873 } },
                { id = 32243, slot = "Feet", name = "Pearl Inlaid Boots", sources = { [14]=14874 } },
                { id = 32239, slot = "Feet", name = "Slippers of the Seacaller", sources = { [14]=14870 } },
                { id = 32245, slot = "Feet", name = "Tide-Stomper's Greaves", sources = { [14]=14875 } },
                { id = 32234, slot = "Hands", name = "Fists of Mukoa", sources = { [14]=14866 } },
                { id = 32240, slot = "Head", name = "Guise of the Tidal Lurker", sources = { [14]=14871 } },
                { id = 32241, slot = "Head", name = "Helm of Soothing Currents", sources = { [14]=14872 } },
                { id = 32377, slot = "Shoulder", name = "Mantle of Darkness", sources = { [14]=14945 } },
                { id = 32248, slot = "Two-Hand", name = "Halberd of Desolation", sources = { [14]=14877 } },
                { id = 32236, slot = "Weapon", name = "Rising Tide", sources = { [14]=14868 } },
                { id = 32237, slot = "Weapon", name = "The Maelstrom's Fury", sources = { [14]=14869 } },
                { id = 32232, slot = "Wrist", name = "Eternium Shell Bracers", sources = { [14]=14865 } },
            },
            specialLoot = {
                -- Aquatic battle pet, part of the Raiding with Leashes
                -- III pet collection.
                { id = 122104, kind = "pet", name = "Leviathan Hatchling" },
            },
        },
        {
            index              = 2,
            name               = "Supremus",
            journalEncounterID = 1583,
            achievements       = {},
            loot = {
                { id = 32252, slot = "Chest", name = "Nether Shadow Tunic", sources = { [14]=14880 } },
                { id = 32255, slot = "Off-hand", name = "Felstone Bulwark", sources = { [14]=14883 } },
                { id = 32253, slot = "Ranged", name = "Legionkiller", sources = { [14]=14881 } },
                { id = 32250, slot = "Shoulder", name = "Pauldrons of Abyssal Fury", sources = { [14]=14878 } },
                { id = 32258, slot = "Waist", name = "Naturalist's Preserving Cinch", sources = { [14]=14885 } },
                { id = 32256, slot = "Waist", name = "Waistwrap of Infinity", sources = { [14]=14884 } },
                { id = 32262, slot = "Weapon", name = "Syphon of the Nathrezim", sources = { [14]=14887 } },
                { id = 32254, slot = "Weapon", name = "The Brutalizer", sources = { [14]=14882 } },
                { id = 32259, slot = "Wrist", name = "Bands of the Coming Storm", sources = { [14]=14886 } },
                { id = 32251, slot = "Wrist", name = "Wraps of Precise Flight", sources = { [14]=14879 } },
            },
            specialLoot = {
                -- Elemental battle pet, part of the Raiding with Leashes
                -- III pet collection.
                { id = 122106, kind = "pet", name = "Abyssius" },
            },
        },
        {
            index              = 3,
            name               = "Shade of Akama",
            journalEncounterID = 1584,
            soloTip            = "Kill the ^Ashtongue Channelers^ and the boss will start slowly moving towards ^Akama^. When he reaches ^Akama^, you can kill him.",
            achievements       = {},
            loot = {
                { id = 32268, slot = "Feet", name = "Myrmidon's Treads", sources = { [14]=14892 } },
                { id = 32278, slot = "Hands", name = "Grips of Silent Justice", sources = { [14]=14900 } },
                { id = 32275, slot = "Hands", name = "Spiritwalker Gauntlets", sources = { [14]=14898 } },
                { id = 32361, slot = "Held In Off-hand", name = "Blind-Seers Icon", sources = { [14]=14934 } },
                { id = 32271, slot = "Legs", name = "Kilt of Immortal Nature", sources = { [14]=14895 } },
                { id = 32263, slot = "Legs", name = "Praetorian's Legguards", sources = { [14]=14888 } },
                { id = 32273, slot = "Shoulder", name = "Amice of Brilliant Light", sources = { [14]=14897 } },
                { id = 32264, slot = "Shoulder", name = "Shoulders of the Hidden Predator", sources = { [14]=14889 } },
                { id = 32276, slot = "Waist", name = "Flashfire Girdle", sources = { [14]=14899 } },
                { id = 32265, slot = "Waist", name = "Shadow-Walker's Cord", sources = { [14]=14890 } },
                { id = 32270, slot = "Wrist", name = "Focused Mana Bindings", sources = { [14]=14894 } },
                { id = 32279, slot = "Wrist", name = "The Seeker's Wristguards", sources = { [14]=14901 } },
                { id = 32513, slot = "Wrist", name = "Wristbands of Divine Influence", sources = { [14]=15004 } },
            },
        },
        {
            index              = 4,
            name               = "Teron Gorefiend",
            journalEncounterID = 1585,
            achievements       = {},
            loot = {
                { id = 32323, slot = "Back", name = "Shadowmoon Destroyer's Drape", sources = { [14]=14904 } },
                { id = 32327, slot = "Chest", name = "Robe of the Shadow Council", sources = { [14]=14908 } },
                { id = 32510, slot = "Feet", name = "Softstep Boots of Tracking", sources = { [14]=15002 } },
                { id = 32328, slot = "Hands", name = "Botanist's Gloves of Growth", sources = { [14]=14909 } },
                { id = 32280, slot = "Hands", name = "Gauntlets of Enforcement", sources = { [14]=14902 } },
                { id = 32329, slot = "Head", name = "Cowl of Benevolence", sources = { [14]=14910 } },
                { id = 32325, slot = "Ranged", name = "Rifle of the Stoic Guardian", sources = { [14]=14906 } },
                { id = 32348, slot = "Two-Hand", name = "Soul Cleaver", sources = { [14]=14927 } },
                { id = 32512, slot = "Waist", name = "Girdle of Lordaeron's Fallen", sources = { [14]=15003 } },
                { id = 32324, slot = "Wrist", name = "Insidious Bands", sources = { [14]=14905 } },
            },
        },
        {
            index              = 5,
            name               = "Gurtogg Bloodboil",
            journalEncounterID = 1586,
            achievements       = {},
            loot = {
                { id = 32337, slot = "Back", name = "Shroud of Forgiveness", sources = { [14]=14916 } },
                { id = 32340, slot = "Chest", name = "Garments of Temperance", sources = { [14]=14919 } },
                { id = 32334, slot = "Chest", name = "Vest of Mounting Assault", sources = { [14]=14914 } },
                { id = 32341, slot = "Legs", name = "Leggings of Divine Retribution", sources = { [14]=14920 } },
                { id = 32343, slot = "Ranged", name = "Wand of Prismatic Focus", sources = { [14]=14922 } },
                { id = 32338, slot = "Shoulder", name = "Blood-Cursed Shoulderpads", sources = { [14]=14917 } },
                { id = 32344, slot = "Two-Hand", name = "Staff of Immaculate Recovery", sources = { [14]=14923 } },
                { id = 32339, slot = "Waist", name = "Belt of Primal Majesty", sources = { [14]=14918 } },
                { id = 32342, slot = "Waist", name = "Girdle of Mighty Resolve", sources = { [14]=14921 } },
                { id = 32333, slot = "Waist", name = "Girdle of Stability", sources = { [14]=14913 } },
                { id = 32269, slot = "Weapon", name = "Messenger of Fate", sources = { [14]=14893 } },
            },
        },
        {
            index              = 6,
            name               = "Reliquary of Souls",
            journalEncounterID = 1587,
            achievements       = {},
            loot = {
                { id = 32345, slot = "Feet", name = "Dreadboots of the Legion", sources = { [14]=14924 } },
                { id = 32352, slot = "Feet", name = "Naturewarden's Treads", sources = { [14]=14930 } },
                { id = 32353, slot = "Hands", name = "Gloves of Unfailing Faith", sources = { [14]=14931 } },
                { id = 32347, slot = "Hands", name = "Grips of Damnation", sources = { [14]=14926 } },
                { id = 32354, slot = "Head", name = "Crown of Empowered Fate", sources = { [14]=14932 } },
                { id = 32350, slot = "Held In Off-hand", name = "Touch of Inspiration", sources = { [14]=14928 } },
                { id = 32363, slot = "Ranged", name = "Naaru-Blessed Life Rod", sources = { [14]=14935 } },
                { id = 32517, slot = "Shoulder", name = "The Wavemender's Mantle", sources = { [14]=15007 } },
                { id = 32332, slot = "Two-Hand", name = "Torch of the Damned", sources = { [14]=14912 } },
                { id = 32346, slot = "Waist", name = "Boneweave Girdle", sources = { [14]=14925 } },
                { id = 32351, slot = "Wrist", name = "Elunite Empowered Bracers", sources = { [14]=14929 } },
            },
            specialLoot = {
                -- Three undead battle pets, part of the Raiding with
                -- Leashes III pet collection.
                { id = 122107, kind = "pet", name = "Fragment of Anger" },
                { id = 122109, kind = "pet", name = "Fragment of Desire" },
                { id = 122108, kind = "pet", name = "Fragment of Suffering" },
            },
        },
        {
            index              = 7,
            name               = "Mother Shahraz",
            journalEncounterID = 1588,
            achievements       = {},
            loot = {
                { id = 32365, slot = "Chest", name = "Heartshatter Breastplate", sources = { [14]=14936 } },
                { id = 32366, slot = "Feet", name = "Shadowmaster's Boots", sources = { [14]=14937 } },
                { id = 32367, slot = "Legs", name = "Leggings of Devastation", sources = { [14]=14938 } },
                { id = 31006, slot = "Shoulder", name = "Gronnstalker's Spaulders", sources = { [14]=14077 }, classes = { 3 } },
                { id = 30996, slot = "Shoulder", name = "Lightbringer Pauldrons", sources = { [14]=14067 }, classes = { 2 } },
                { id = 30997, slot = "Shoulder", name = "Lightbringer Shoulderbraces", sources = { [14]=14068 }, classes = { 2 } },
                { id = 30998, slot = "Shoulder", name = "Lightbringer Shoulderguards", sources = { [14]=14069 }, classes = { 2 } },
                { id = 31069, slot = "Shoulder", name = "Mantle of Absolution", sources = { [14]=14137 }, classes = { 5 } },
                { id = 31054, slot = "Shoulder", name = "Mantle of the Malefic", sources = { [14]=14122 }, classes = { 9 } },
                { id = 31059, slot = "Shoulder", name = "Mantle of the Tempest", sources = { [14]=14127 }, classes = { 8 } },
                { id = 30979, slot = "Shoulder", name = "Onslaught Shoulderblades", sources = { [14]=14051 }, classes = { 1 } },
                { id = 30980, slot = "Shoulder", name = "Onslaught Shoulderguards", sources = { [14]=14052 }, classes = { 1 } },
                { id = 31070, slot = "Shoulder", name = "Shoulderpads of Absolution", sources = { [14]=14138 }, classes = { 5 } },
                { id = 31023, slot = "Shoulder", name = "Skyshatter Mantle", sources = { [14]=14094 }, classes = { 7 } },
                { id = 31024, slot = "Shoulder", name = "Skyshatter Pauldrons", sources = { [14]=14095 }, classes = { 7 } },
                { id = 31022, slot = "Shoulder", name = "Skyshatter Shoulderpads", sources = { [14]=14093 }, classes = { 7 } },
                { id = 31030, slot = "Shoulder", name = "Slayer's Shoulderpads", sources = { [14]=14100 }, classes = { 4 } },
                { id = 31048, slot = "Shoulder", name = "Thunderheart Pauldrons", sources = { [14]=14116 }, classes = { 11 } },
                { id = 31049, slot = "Shoulder", name = "Thunderheart Shoulderpads", sources = { [14]=14117 }, classes = { 11 } },
                { id = 31047, slot = "Shoulder", name = "Thunderheart Spaulders", sources = { [14]=14115 }, classes = { 11 } },
                { id = 32369, slot = "Weapon", name = "Blade of Savagery", sources = { [14]=14939 } },
            },
            specialLoot = {
                -- Humanoid battle pet, part of the Raiding with Leashes
                -- III pet collection.
                { id = 122110, kind = "pet", name = "Sister of Temptation" },
            },
        },
        {
            index              = 8,
            name               = "The Illidari Council",
            journalEncounterID = 1589,
            achievements       = {},
            loot = {
                { id = 32331, slot = "Back", name = "Cloak of the Illidari Council", sources = { [14]=14911 } },
                { id = 32376, slot = "Head", name = "Forest Prowler's Helm", sources = { [14]=14944 } },
                { id = 32373, slot = "Head", name = "Helm of the Illidari Shatterer", sources = { [14]=14941 } },
                { id = 31068, slot = "Legs", name = "Breeches of Absolution", sources = { [14]=14136 }, classes = { 5 } },
                { id = 31005, slot = "Legs", name = "Gronnstalker's Leggings", sources = { [14]=14076 }, classes = { 3 } },
                { id = 31067, slot = "Legs", name = "Leggings of Absolution", sources = { [14]=14135 }, classes = { 5 } },
                { id = 31053, slot = "Legs", name = "Leggings of the Malefic", sources = { [14]=14121 }, classes = { 9 } },
                { id = 31058, slot = "Legs", name = "Leggings of the Tempest", sources = { [14]=14126 }, classes = { 8 } },
                { id = 30993, slot = "Legs", name = "Lightbringer Greaves", sources = { [14]=14064 }, classes = { 2 } },
                { id = 30994, slot = "Legs", name = "Lightbringer Leggings", sources = { [14]=14065 }, classes = { 2 } },
                { id = 30995, slot = "Legs", name = "Lightbringer Legguards", sources = { [14]=14066 }, classes = { 2 } },
                { id = 30977, slot = "Legs", name = "Onslaught Greaves", sources = { [14]=14049 }, classes = { 1 } },
                { id = 30978, slot = "Legs", name = "Onslaught Legguards", sources = { [14]=14050 }, classes = { 1 } },
                { id = 31019, slot = "Legs", name = "Skyshatter Leggings", sources = { [14]=14090 }, classes = { 7 } },
                { id = 31020, slot = "Legs", name = "Skyshatter Legguards", sources = { [14]=14091 }, classes = { 7 } },
                { id = 31021, slot = "Legs", name = "Skyshatter Pants", sources = { [14]=14092 }, classes = { 7 } },
                { id = 31029, slot = "Legs", name = "Slayer's Legguards", sources = { [14]=14099 }, classes = { 4 } },
                { id = 31044, slot = "Legs", name = "Thunderheart Leggings", sources = { [14]=14112 }, classes = { 11 } },
                { id = 31045, slot = "Legs", name = "Thunderheart Legguards", sources = { [14]=14113 }, classes = { 11 } },
                { id = 31046, slot = "Legs", name = "Thunderheart Pants", sources = { [14]=14114 }, classes = { 11 } },
                { id = 32518, slot = "Shoulder", name = "Veil of Turning Leaves", sources = { [14]=15008 } },
                { id = 32519, slot = "Waist", name = "Belt of Divine Guidance", sources = { [14]=15009 } },
            },
        },
        {
            index              = 9,
            name               = "Illidan Stormrage",
            journalEncounterID = 1590,
            achievements       = {},
            loot = {
                { id = 32524, slot = "Back", name = "Shroud of the Highborne", sources = { [14]=15013 } },
                { id = 31004, slot = "Chest", name = "Gronnstalker's Chestguard", sources = { [14]=14075 }, classes = { 3 } },
                { id = 30990, slot = "Chest", name = "Lightbringer Breastplate", sources = { [14]=14061 }, classes = { 2 } },
                { id = 30991, slot = "Chest", name = "Lightbringer Chestguard", sources = { [14]=14062 }, classes = { 2 } },
                { id = 30992, slot = "Chest", name = "Lightbringer Chestpiece", sources = { [14]=14063 }, classes = { 2 } },
                { id = 30975, slot = "Chest", name = "Onslaught Breastplate", sources = { [14]=14047 }, classes = { 1 } },
                { id = 30976, slot = "Chest", name = "Onslaught Chestguard", sources = { [14]=14048 }, classes = { 1 } },
                { id = 31052, slot = "Chest", name = "Robe of the Malefic", sources = { [14]=14120 }, classes = { 9 } },
                { id = 31057, slot = "Chest", name = "Robes of the Tempest", sources = { [14]=14125 }, classes = { 8 } },
                { id = 31065, slot = "Chest", name = "Shroud of Absolution", sources = { [14]=14133 }, classes = { 5 } },
                { id = 31017, slot = "Chest", name = "Skyshatter Breastplate", sources = { [14]=14088 }, classes = { 7 } },
                { id = 31016, slot = "Chest", name = "Skyshatter Chestguard", sources = { [14]=14087 }, classes = { 7 } },
                { id = 31018, slot = "Chest", name = "Skyshatter Tunic", sources = { [14]=14089 }, classes = { 7 } },
                { id = 31028, slot = "Chest", name = "Slayer's Chestguard", sources = { [14]=14098 }, classes = { 4 } },
                { id = 31042, slot = "Chest", name = "Thunderheart Chestguard", sources = { [14]=14110 }, classes = { 11 } },
                { id = 31041, slot = "Chest", name = "Thunderheart Tunic", sources = { [14]=14109 }, classes = { 11 } },
                { id = 31043, slot = "Chest", name = "Thunderheart Vest", sources = { [14]=14111 }, classes = { 11 } },
                { id = 31066, slot = "Chest", name = "Vestments of Absolution", sources = { [14]=14134 }, classes = { 5 } },
                { id = 32525, slot = "Head", name = "Cowl of the Illidari High Lord", sources = { [14]=15014 } },
                { id = 32235, slot = "Head", name = "Cursed Vision of Sargeras", sources = { [14]=14867 } },
                { id = 32521, slot = "Head", name = "Faceplate of the Impenetrable", sources = { [14]=15011 } },
                { id = 32375, slot = "Off-hand", name = "Bulwark of Azzinoth", sources = { [14]=14943 } },
                { id = 32838, slot = "Off-hand", name = "Warglaive of Azzinoth", sources = { [14]=15137 } },
                { id = 32336, slot = "Ranged", name = "Black Bow of the Betrayer", sources = { [14]=14915 } },
                { id = 32374, slot = "Two-Hand", name = "Zhar'doom, Greatstaff of the Devourer", sources = { [14]=14942 } },
                { id = 32500, slot = "Weapon", name = "Crystal Spire of Karabor", sources = { [14]=14999 } },
                { id = 32471, slot = "Weapon", name = "Shard of Azzinoth", sources = { [14]=14984 } },
                { id = 32837, slot = "Weapon", name = "Warglaive of Azzinoth", sources = { [14]=15136 } },
            },
        },
    },

    -- Always-on map markers, shown regardless of the current step: vendors,
    -- doors/tunnels, hand-authored points. Not tied to routing.
    pois = {
        { mapID = 341, poiKind = "vendor", mapLabel = "Ashtongue Vendors",
          mapLabelPos = "above", points = { { 0.624, 0.502 } } },
    },

    routing = {

        -- 1. High Warlord Naj'entus
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "High Warlord Naj'entus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 340 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path up the ramps until you reach ^High Warlord Naj'entus^.",
                    minNote = "Up the ramps to Naj'entus",
                    points  = {
                        { 0.221, 0.556 },
                        { 0.234, 0.516 },
                        { 0.233, 0.484 },
                        { 0.212, 0.437 },
                        { 0.232, 0.416 },
                        { 0.258, 0.432 },
                        { 0.317, 0.431 },
                        { 0.331, 0.410 },
                        { 0.368, 0.382 },
                        { 0.372, 0.190 },
                        { 0.415, 0.189 },
                    },
                },
            },
        },

        -- 2. Supremus
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Supremus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 340 },
                    kind    = "path",
                    note    = "After defeating ^High Warlord Naj'entus^, make your way up and through a pipe on the west side of the room.",
                    minNote = "West through pipe",
                    points  = {
                        { 0.404, 0.190 },
                        { 0.291, 0.193 },
                        { 0.278, 0.193 },
                        { 0.274, 0.177 },
                        { 0.274, 0.149 },
                        { 0.274, 0.122 },
                        { 0.272, 0.065 },
                    },
                },
                {
                    when    = { mapID = 339 },
                    kind    = "path",
                    note    = "In the large outdoor area, make your way up the middle path to ^Supremus^.",
                    minNote = "Up path to Supremus",
                    points  = {
                        { 0.286, 0.705 },
                        { 0.330, 0.471 },
                        { 0.631, 0.469 },
                    },
                },
            },
        },

        -- 3. Shade of Akama
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Shade of Akama",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 339 },
                    kind    = "path",
                    note    = "After defeating ^Supremus^, continue up the ramp behind him into the next area.",
                    minNote = "Up ramp into next area",
                    points  = {
                        { 0.634, 0.473 },
                        { 0.778, 0.473 },
                    },
                },
                {
                    -- Holds the Supremus note across mapID 341 until the
                    -- Sanctuary of Shadows subzone below takes over; the line
                    -- draws from that seg.
                    when    = { mapID = 341 },
                    kind    = "path",
                    note    = "After defeating ^Supremus^, continue up the ramp behind him into the next area.",
                    minNote = "Up ramp into next area",
                },
                {
                    when    = { mapID = 341, subZone = "Sanctuary of Shadows" },
                    kind    = "path",
                    note    = "In the next area, take a right and travel south until you reach ^Akama^. Talk to him to begin the battle against ^Shade of Akama^.",
                    minNote = "Talk to Akama to start Shade",
                    points  = {
                        { 0.339, 0.506 },
                        { 0.387, 0.549 },
                        { 0.411, 0.639 },
                    },
                },
                {
                    -- Akama's room reports its own subzone; the line is already
                    -- drawn by the segment above.
                    when    = { mapID = 341, subZone = "The Refectory" },
                    kind    = "path",
                    note    = "In the next area, take a right and travel south until you reach ^Akama^. Talk to him to begin the battle against ^Shade of Akama^.",
                    minNote = "Talk to Akama to start Shade",
                },
                {
                    when        = { mapID = 341, subZone = "Sanctuary of Shadows" },
                    kind        = "poi",
                    mapLabel    = "Talk to Akama",
                    mapLabelPos = "below",
                    points      = {
                        { 0.406, 0.734 },
                    },
                },
            },
        },

        -- 4. Teron Gorefiend
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Teron Gorefiend",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 341 },
                    kind    = "path",
                    note    = "After defeating ^Shade of Akama^, backtrack out of this room and go east towards ^Gorefiend's Vigil^. Follow the path up a couple sets of stairs.",
                    minNote = "East to Gorefiend's Vigil",
                    points  = {
                        { 0.410, 0.739 },
                        { 0.408, 0.656 },
                        { 0.706, 0.665 },
                        { 0.706, 0.785 },
                        { 0.665, 0.788 },
                        { 0.601, 0.905 },
                        { 0.574, 0.908 },
                    },
                },
                {
                    when    = { mapID = 343 },
                    kind    = "path",
                    note    = "Follow the path through the next area until you reach ^Teron Gorefiend^.",
                    minNote = "Path to Gorefiend",
                    points  = {
                        { 0.591, 0.690 },
                        { 0.525, 0.687 },
                        { 0.508, 0.647 },
                        { 0.479, 0.641 },
                        { 0.457, 0.665 },
                        { 0.423, 0.680 },
                        { 0.380, 0.679 },
                        { 0.344, 0.678 },
                        { 0.347, 0.562 },
                        { 0.393, 0.428 },
                        { 0.391, 0.162 },
                    },
                },
            },
        },

        -- 5. Gurtogg Bloodboil
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Gurtogg Bloodboil",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 343 },
                    kind    = "path",
                    note    = "After killing ^Teron Gorefiend^, backtrack towards the main concourse.",
                    minNote = "Backtrack to main concourse",
                    points  = {
                        { 0.392, 0.168 },
                        { 0.390, 0.444 },
                        { 0.346, 0.566 },
                        { 0.345, 0.677 },
                        { 0.457, 0.688 },
                        { 0.475, 0.649 },
                        { 0.499, 0.645 },
                        { 0.514, 0.671 },
                        { 0.538, 0.682 },
                        { 0.747, 0.689 },
                    },
                },
                {
                    when    = { mapID = 341 },
                    kind    = "path",
                    note    = "Continue backtracking to main concourse. When you reach it, cut through the platform and take the northeast path out of this room.",
                    minNote = "Northeast from main concourse",
                    points  = {
                        { 0.600, 0.903 },
                        { 0.661, 0.777 },
                        { 0.703, 0.776 },
                        { 0.704, 0.658 },
                        { 0.542, 0.654 },
                        { 0.505, 0.580 },
                        { 0.530, 0.561 },
                        { 0.553, 0.533 },
                        { 0.554, 0.497 },
                        { 0.548, 0.463 },
                        { 0.506, 0.410 },
                        { 0.518, 0.361 },
                        { 0.568, 0.342 },
                        { 0.625, 0.342 },
                    },
                },
                {
                    when    = { mapID = 342 },
                    kind    = "path",
                    note    = "In the next area, head north then go down the stairs on your left. Follow this path until you reach ^Gurtogg Bloodboil^.",
                    minNote = "Path downstairs to Gurtogg",
                    points  = {
                        { 0.672, 0.390 },
                        { 0.719, 0.364 },
                        { 0.745, 0.331 },
                        { 0.742, 0.211 },
                        { 0.538, 0.211 },
                        { 0.534, 0.441 },
                    },
                },
            },
        },

        -- 6. Reliquary of Souls
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Reliquary of Souls",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 342 },
                    kind    = "path",
                    note    = "After killing ^Gurtogg Bloodboil^, go up the stairs just east of his corpse. When you reach the top, go south until you reach ^Reliquary of Souls^.",
                    minNote = "South to Reliquary",
                    points  = {
                        { 0.564, 0.474 },
                        { 0.664, 0.474 },
                        { 0.743, 0.525 },
                        { 0.746, 0.606 },
                        { 0.730, 0.629 },
                        { 0.731, 0.672 },
                        { 0.742, 0.848 },
                        { 0.639, 0.851 },
                    },
                },
            },
        },

        -- 7. Mother Shahraz
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Mother Shahraz",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 342 },
                    kind    = "path",
                    note    = "After defeating ^Reliquary of Souls^, backtrack to the main concourse.",
                    minNote = "Backtrack to main concourse",
                    points  = {
                        { 0.679, 0.848 },
                        { 0.745, 0.840 },
                        { 0.747, 0.684 },
                        { 0.727, 0.653 },
                        { 0.740, 0.606 },
                        { 0.738, 0.494 },
                        { 0.694, 0.492 },
                        { 0.690, 0.435 },
                        { 0.677, 0.391 },
                        { 0.639, 0.391 },
                    },
                },
                {
                    when    = { mapID = 341 },
                    kind    = "path",
                    note    = "Back in the main concourse, take the northern exit and go up some stairs.",
                    minNote = "Northern exit, up stairs",
                    points  = {
                        { 0.590, 0.345 },
                        { 0.416, 0.344 },
                        { 0.411, 0.228 },
                        { 0.347, 0.171 },
                        { 0.265, 0.174 },
                        { 0.266, 0.248 },
                    },
                },
                {
                    when    = { mapID = 344 },
                    kind    = "path",
                    note    = "Continue up the stairs. When you reach the top, follow the path to ^Mother Shahraz^.",
                    minNote = "Path to Shahraz",
                    points  = {
                        { 0.082, 0.558 },
                        { 0.086, 0.665 },
                        { 0.214, 0.661 },
                        { 0.268, 0.535 },
                        { 0.271, 0.364 },
                        { 0.646, 0.368 },
                    },
                },
            },
        },

        -- 8. The Illidari Council
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "The Illidari Council",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 344 },
                    kind    = "path",
                    note    = "After defeating ^Mother Shahraz^, take the nearby exit to the south.",
                    minNote = "Exit South",
                    points  = {
                        { 0.673, 0.405 },
                        { 0.672, 0.565 },
                    },
                },
                {
                    when    = { mapID = 345 },
                    kind    = "path",
                    note    = "Follow the path south and continue on to ^The Illidari Council^.",
                    minNote = "Path south to Council",
                    points  = {
                        { 0.692, 0.225 },
                        { 0.659, 0.249 },
                        { 0.658, 0.306 },
                        { 0.691, 0.369 },
                        { 0.691, 0.442 },
                        { 0.659, 0.488 },
                        { 0.657, 0.669 },
                        { 0.674, 0.703 },
                        { 0.675, 0.762 },
                        { 0.647, 0.789 },
                        { 0.473, 0.788 },
                        { 0.473, 0.473 },
                    },
                },
            },
        },

        -- 9. Illidan Stormrage
        {
            step      = 9,
            priority  = 9,
            bossIndex = 9,
            title     = "Illidan Stormrage",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 345 },
                    kind        = "poi",
                    note        = "After killing ^The Illidari Council^, talk to ^Akama^ and follow him up the ramp. After some dialog, he will open the door to the final area.",
                    minNote     = "Talk to Akama",
                    mapLabel    = "Talk to Akama",
                    mapLabelPos = "above",
                    points      = {
                        { 0.471, 0.558 },
                    },
                },
                {
                    when        = { mapID = 346 },
                    kind        = "poi",
                    note        = "Follow ^Akama^ into the next area. Talk to him to start the final battle against ^Illidan Stormrage^.",
                    minNote     = "Talk to Akama for Illidan",
                    mapLabel    = "Talk to Akama",
                    mapLabelPos = "below",
                    points      = {
                        { 0.722, 0.398 },
                    },
                },
            },
        },
    },
}
