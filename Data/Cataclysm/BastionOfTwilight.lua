-------------------------------------------------------------------------------
-- RetroRuns Data -- The Bastion of Twilight
-- Cataclysm, Patch 4.0.3  |  instanceID: 671  |  journalInstanceID: 72
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[671] = {
    instanceID        = 671,
    journalInstanceID = 72,
    name              = "The Bastion of Twilight",
    expansion         = "Cataclysm",
    patch             = "4.0.3",

    exitNote = "Jump in the lava to die. You will respawn at the entrance. |cffffffff(Heroic Only)|r",

    -- Both Normal and Heroic are offered, folded into one weekly lockout.
    difficultyModel     = "shared",
    availableDifficulties = { 14, 15 },

    entrance = {
        mapID = 241,
        x     = 0.3390,
        y     = 0.7800,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [294] = "The Twilight Enclave",
        [295] = "Throne of the Apocalypse",
        [296] = "The Twilight Caverns",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [67423] = 1,  -- Chest of the Forlorn Conqueror
            [67424] = 1,  -- Chest of the Forlorn Protector
            [67425] = 1,  -- Chest of the Forlorn Vanquisher
            [64314] = 4,  -- Mantle of the Forlorn Vanquisher
            [64315] = 4,  -- Mantle of the Forlorn Conqueror
            [64316] = 4,  -- Mantle of the Forlorn Protector
            [65087] = 4,  -- Shoulders of the Forlorn Protector
            [65088] = 4,  -- Shoulders of the Forlorn Conqueror
            [65089] = 4,  -- Shoulders of the Forlorn Vanquisher
        },
    },

    gloryMeta = {
        id   = 4853,
        name = "Glory of the Cataclysm Raider",
        rewardItemID       = 62901,
        rewardMountSpellID = 88335,
        rewardName         = "Reins of the Drake of the East Wind",
    },

    bosses = {
        {
            index              = 1,
            name               = "Halfus Wyrmbreaker",
            journalEncounterID = 156,
            aliases            = {},
            achievements       = {
                { id = 5118, name = "Heroic: Halfus Wyrmbreaker", meta = true, soloable = "yes" },
                { id = 5300, name = "The Only Escape", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59482, slot = "Chest", name = "Robes of the Burning Acolyte", sources = { [14]=29700, [15]=32707 } },
                { id = 59469, slot = "Feet", name = "Storm Rider's Boots", sources = { [14]=29692, [15]=32715 } },
                { id = 59472, slot = "Hands", name = "Proto-Handler's Gauntlets", sources = { [14]=29695, [15]=32712 } },
                { id = 59481, slot = "Head", name = "Helm of the Nether Scion", sources = { [14]=29699, [15]=32708 } },
                { id = 59484, slot = "Held In Off-hand", name = "Book of Binding Will", sources = { [14]=29701, [15]=32706 } },
                { id = 59476, slot = "Legs", name = "Legguards of the Emerald Brood", sources = { [14]=29698, [15]=32709 } },
                { id = 59471, slot = "Shoulder", name = "Pauldrons of the Great Ettin", sources = { [14]=29694, [15]=32713 } },
                { id = 59474, slot = "Two-Hand", name = "Malevolence", sources = { [14]=29696, [15]=32711 } },
                { id = 59470, slot = "Wrist", name = "Bracers of Impossible Strength", sources = { [14]=29693, [15]=32714 } },
                { id = 59475, slot = "Wrist", name = "Bracers of the Bronze Flight", sources = { [14]=29697, [15]=32710 } },
                { id = 60323, slot = "Chest", name = "Earthen Battleplate", sources = { [14]=30055, [15]=32825 }, classes = { 1 } },
                { id = 60329, slot = "Chest", name = "Earthen Chestguard", sources = { [14]=30061, [15]=32830 }, classes = { 1 } },
                { id = 60344, slot = "Chest", name = "Reinforced Sapphirium Battleplate", sources = { [14]=30071, [15]=32775 }, classes = { 2 } },
                { id = 60354, slot = "Chest", name = "Reinforced Sapphirium Chestguard", sources = { [14]=30081, [15]=32785 }, classes = { 2 } },
                { id = 60360, slot = "Chest", name = "Reinforced Sapphirium Breastplate", sources = { [14]=30087, [15]=32780 }, classes = { 2 } },
                { id = 60304, slot = "Chest", name = "Lightning-Charged Tunic", sources = { [14]=30036, [15]=32765 }, classes = { 3 } },
                { id = 60301, slot = "Chest", name = "Wind Dancer's Tunic", sources = { [14]=30033, [15]=32800 }, classes = { 4 } },
                { id = 60254, slot = "Chest", name = "Mercurial Vestment", sources = { [14]=30003, [15]=32798 }, classes = { 5 } },
                { id = 60259, slot = "Chest", name = "Mercurial Robes", sources = { [14]=30008, [15]=32793 }, classes = { 5 } },
                { id = 60339, slot = "Chest", name = "Magma Plated Battleplate", sources = { [14]=30066, [15]=32740 }, classes = { 6 } },
                { id = 60349, slot = "Chest", name = "Magma Plated Chestguard", sources = { [14]=30076, [15]=32745 }, classes = { 6 } },
                { id = 60309, slot = "Chest", name = "Tunic of the Raging Elements", sources = { [14]=30041, [15]=32805 }, classes = { 7 } },
                { id = 60313, slot = "Chest", name = "Hauberk of the Raging Elements", sources = { [14]=30045, [15]=32815 }, classes = { 7 } },
                { id = 60318, slot = "Chest", name = "Cuirass of the Raging Elements", sources = { [14]=30050, [15]=32810 }, classes = { 7 } },
                { id = 60244, slot = "Chest", name = "Firelord's Robes", sources = { [14]=29993, [15]=32773 }, classes = { 8 } },
                { id = 60251, slot = "Chest", name = "Shadowflame Robes", sources = { [14]=30000, [15]=32823 }, classes = { 9 } },
                { id = 60276, slot = "Chest", name = "Stormrider's Robes", sources = { [14]=30012, [15]=32758 }, classes = { 11 } },
                { id = 60281, slot = "Chest", name = "Stormrider's Vestment", sources = { [14]=30017, [15]=32763 }, classes = { 11 } },
                { id = 60287, slot = "Chest", name = "Stormrider's Raiment", sources = { [14]=30023, [15]=32753 }, classes = { 11 } },
            },
        },
        {
            index              = 2,
            name               = "Theralion and Valiona",
            journalEncounterID = 157,
            aliases            = {},
            achievements       = {
                { id = 4852, name = "Double Dragon", meta = true, soloable = "yes" },
                { id = 5117, name = "Heroic: Valiona and Theralion", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59516, slot = "Back", name = "Drape of the Twins", sources = { [14]=29722, [15]=32687 } },
                { id = 63531, slot = "Head", name = "Daybreaker Helm", sources = { [14]=31860, [15]=32679 } },
                { id = 63534, slot = "Head", name = "Helm of Eldritch Authority", sources = { [14]=31863, [15]=32676 } },
                { id = 63532, slot = "Ranged", name = "Dragonheart Piercer", sources = { [14]=31861, [15]=32678 } },
                { id = 63535, slot = "Waist", name = "Waistguard of Hatred", sources = { [14]=31864, [15]=32675 } },
                { id = 63536, slot = "Weapon", name = "Blade of the Witching Hour", sources = { [14]=31865, [15]=32674 } },
                { id = 63533, slot = "Weapon", name = "Fang of Twilight", sources = { [14]=31862, [15]=32677 } },
            },
            specialLoot = {
                { id = 152969, kind = "pet", name = "Odd Twilight Egg" },
            },
        },
        {
            index              = 3,
            name               = "Ascendant Council",
            journalEncounterID = 158,
            aliases            = {},
            achievements       = {
                { id = 5311, name = "Elementary", meta = true, soloable = "yes" },
                { id = 5119, name = "Heroic: Ascendant Council", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59507, slot = "Back", name = "Glittering Epidermis", sources = { [14]=29716, [15]=32693 } },
                { id = 59508, slot = "Feet", name = "Treads of Liquid Ice", sources = { [14]=29717, [15]=32692 } },
                { id = 59505, slot = "Hands", name = "Gravitational Pull", sources = { [14]=29715, [15]=32694 } },
                { id = 59511, slot = "Hands", name = "Hydrolance Gloves", sources = { [14]=29720, [15]=32689 } },
                { id = 59504, slot = "Head", name = "Arion's Crown", sources = { [14]=29714, [15]=32695 } },
                { id = 59509, slot = "Head", name = "Glaciated Helm", sources = { [14]=29718, [15]=32691 } },
                { id = 59513, slot = "Held In Off-hand", name = "Scepter of Ice", sources = { [14]=29721, [15]=32688 } },
                { id = 59503, slot = "Legs", name = "Terrastra's Legguards", sources = { [14]=29713, [15]=32696 } },
                { id = 59510, slot = "Shoulder", name = "Feludius' Mantle", sources = { [14]=29719, [15]=32690 } },
                { id = 59502, slot = "Waist", name = "Dispersing Belt", sources = { [14]=29712, [15]=32697 } },
            },
            specialLoot = {
                { id = 152970, kind = "pet", name = "Lesser Circle of Binding" },
            },
        },
        {
            index              = 4,
            name               = "Cho'gall",
            journalEncounterID = 167,
            aliases            = {},
            achievements       = {
                { id = 5312, name = "The Abyss Will Gaze Back Into You", meta = true, soloable = "yes" },
                { id = 5120, name = "Heroic: Cho'gall", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59486, slot = "Chest", name = "Battleplate of the Apocalypse", sources = { [14]=29703, [15]=32704 } },
                { id = 59495, slot = "Feet", name = "Treads of Hideous Transformation", sources = { [14]=29708, [15]=32701 } },
                { id = 59498, slot = "Hands", name = "Hands of the Twilight Council", sources = { [14]=29710, [15]=32699 } },
                { id = 59487, slot = "Head", name = "Helm of Maddening Whispers", sources = { [14]=29704, [15]=32703 } },
                { id = 59490, slot = "Head", name = "Membrane of C'Thun", sources = { [14]=29705, [15]=32702 } },
                { id = 59499, slot = "Legs", name = "Kilt of the Forgotten Battle", sources = { [14]=29711, [15]=32698 } },
                { id = 59330, slot = "Two-Hand", name = "Shalug'doom, the Axe of Unmaking", sources = { [14]=29579, [15]=32716 } },
                { id = 59485, slot = "Waist", name = "Coil of Ten-Thousand Screams", sources = { [14]=29702, [15]=32705 } },
                { id = 63680, slot = "Weapon", name = "Twilight's Hammer", sources = { [14]=31995, [15]=32673 } },
                { id = 59494, slot = "Weapon", name = "Uhn'agh Fash, the Darkest Betrayal", sources = { [14]=29707, [15]=35131 } },
                { id = 59497, slot = "Wrist", name = "Shackles of the End of Days", sources = { [14]=29709, [15]=32700 } },
                { id = 60327, slot = "Shoulder", name = "Earthen Pauldrons", sources = { [14]=30059, [15]=32829 }, classes = { 1 } },
                { id = 60331, slot = "Shoulder", name = "Earthen Shoulderguards", sources = { [14]=30063, [15]=32834 }, classes = { 1 } },
                { id = 60348, slot = "Shoulder", name = "Reinforced Sapphirium Pauldrons", sources = { [14]=30075, [15]=32779 }, classes = { 2 } },
                { id = 60358, slot = "Shoulder", name = "Reinforced Sapphirium Shoulderguards", sources = { [14]=30085, [15]=32789 }, classes = { 2 } },
                { id = 60362, slot = "Shoulder", name = "Reinforced Sapphirium Mantle", sources = { [14]=30089, [15]=32784 }, classes = { 2 } },
                { id = 60306, slot = "Shoulder", name = "Lightning-Charged Spaulders", sources = { [14]=30038, [15]=32769 }, classes = { 3 } },
                { id = 60302, slot = "Shoulder", name = "Wind Dancer's Spaulders", sources = { [14]=30034, [15]=32804 }, classes = { 4 } },
                { id = 60253, slot = "Shoulder", name = "Mercurial Shoulderwraps", sources = { [14]=30002, [15]=32799 }, classes = { 5 } },
                { id = 60262, slot = "Shoulder", name = "Mercurial Mantle", sources = { [14]=30010, [15]=32794 }, classes = { 5 } },
                { id = 60343, slot = "Shoulder", name = "Magma Plated Pauldrons", sources = { [14]=30070, [15]=32744 }, classes = { 6 } },
                { id = 60353, slot = "Shoulder", name = "Magma Plated Shoulderguards", sources = { [14]=30080, [15]=32749 }, classes = { 6 } },
                { id = 60311, slot = "Shoulder", name = "Mantle of the Raging Elements", sources = { [14]=30043, [15]=32809 }, classes = { 7 } },
                { id = 60317, slot = "Shoulder", name = "Shoulderwraps of the Raging Elements", sources = { [14]=30049, [15]=32819 }, classes = { 7 } },
                { id = 60322, slot = "Shoulder", name = "Spaulders of the Raging Elements", sources = { [14]=30054, [15]=32814 }, classes = { 7 } },
                { id = 60246, slot = "Shoulder", name = "Firelord's Mantle", sources = { [14]=29995, [15]=32774 }, classes = { 8 } },
                { id = 60252, slot = "Shoulder", name = "Shadowflame Mantle", sources = { [14]=30001, [15]=32824 }, classes = { 9 } },
                { id = 60279, slot = "Shoulder", name = "Stormrider's Mantle", sources = { [14]=30015, [15]=32759 }, classes = { 11 } },
                { id = 60284, slot = "Shoulder", name = "Stormrider's Shoulderwraps", sources = { [14]=30020, [15]=32764 }, classes = { 11 } },
                { id = 60289, slot = "Shoulder", name = "Stormrider's Spaulders", sources = { [14]=30025, [15]=32754 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 152972, kind = "pet", name = "Twilight Summoning Portal" },
            },
        },
        {
            index              = 5,
            name               = "Sinestra",
            journalEncounterID = 168,
            aliases            = {},
            achievements       = {
                { id = 5121, name = "Heroic: Sinestra", meta = false, soloable = "yes" },
            },
            soloTip            = "There is a large egg on each side of ^Sinestra^. Attack the boss/whelps until the barriers drop from these two large eggs. Kill the 2 large eggs, then kill the boss.",
            -- Sinestra is a Heroic-only encounter, unlocked by defeating
            -- Cho'gall on Heroic: she does not exist on Normal. This
            -- restricts kill-count denominators, the routing picker, and
            -- the boss-progress display to the Heroic bucket (15). Without
            -- it the Normal pill would cap at 4/5 forever and the panel
            -- would route toward a boss that can't be engaged.
            availableDifficulties = { 15 },
            loot = {
                { id = 60232, slot = "Back", name = "Shroud of Endless Grief", sources = { [15]=29986 } },
                { id = 60235, slot = "Feet", name = "Boots of Az'galada", sources = { [15]=29988 } },
                { id = 60236, slot = "Feet", name = "Nightmare Rider's Boots", sources = { [15]=29989 } },
                { id = 60229, slot = "Feet", name = "War-Torn Crushers", sources = { [15]=29983 } },
                { id = 60237, slot = "Head", name = "Crown of the Twilight Queen", sources = { [15]=29990 } },
                { id = 60230, slot = "Legs", name = "Twilight Scale Leggings", sources = { [15]=29984 } },
                { id = 60231, slot = "Waist", name = "Belt of the Fallen Brood", sources = { [15]=29985 } },
                { id = 60234, slot = "Wrist", name = "Bindings of Bleak Betrayal", sources = { [15]=29987 } },
                { id = 60238, slot = "Wrist", name = "Bracers of the Dark Mother", sources = { [15]=29991 } },
                { id = 60228, slot = "Wrist", name = "Bracers of the Mat'redor", sources = { [15]=29982 } },
            },
        },
    },

    routing = {

        -- 1. Halfus Wyrmbreaker
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Halfus Wyrmbreaker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 294, subZone = "Bastion Antechamber" },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path to ^Halfus Wyrmbreaker^.",
                    minNote = "Path to Halfus",
                    points  = {
                        { 0.394, 0.480 },
                        { 0.395, 0.194 },
                        { 0.505, 0.194 },
                    },
                },
            },
        },

        -- 2. Theralion and Valiona
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Theralion and Valiona",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 294, subZone = "Wyrmbreaker's Rookery" },
                    kind    = "path",
                    note    = "After defeating ^Halfus^, follow the path straight south to reach ^Theralion and Valiona^. Kill trash to begin the gauntlet on the way to the boss.",
                    minNote = "Gauntlet then Dragons",
                    points  = {
                        { 0.536, 0.250 },
                        { 0.536, 0.741 },
                    },
                },
            },
        },

        -- 3. Ascendant Council
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Ascendant Council",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 294, subZone = "The Twilight Enclave" },
                    kind    = "path",
                    note    = "After killing ^Theralion and Valiona^, head south and exit this area.",
                    minNote = "South exit",
                    points  = {
                        { 0.536, 0.843 },
                        { 0.534, 0.920 },
                        { 0.496, 0.919 },
                        { 0.464, 0.939 },
                    },
                },
                {
                    when    = { mapID = 295, subZone = "The Twilight Enclave" },
                    kind    = "path",
                    note    = "Follow the path to reach the ^Ascendant Council^.",
                    minNote = "Path to Council",
                    points  = {
                        { 0.550, 0.125 },
                        { 0.483, 0.143 },
                        { 0.423, 0.186 },
                        { 0.420, 0.410 },
                    },
                },
            },
        },

        -- 4. Cho'gall
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Cho'gall",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 295, subZone = "Sanctum of the Ascended" },
                    kind    = "path",
                    note    = "After defeating the ^Ascendant Council^, continue down the southern path until you reach ^Cho'gall^.",
                    minNote = "South to Cho'gall",
                    points  = {
                        { 0.424, 0.496 },
                        { 0.423, 0.755 },
                        { 0.702, 0.755 },
                    },
                },
            },
        },

        -- 5. Sinestra (Heroic-only)
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Sinestra",
            requires  = { },
            segments  = {
                {
                    when     = { mapID = 295, subZone = "Throne of the Apocalypse" },
                    kind     = "poi",
                    note     = "After defeating ^Cho'gall^, jump in the hole in the middle of the room.",
                    minNote  = "Jump in hole",
                    mapLabel = "Jump in Hole",
                    points   = {
                        { 0.696, 0.754 },
                    },
                },
                {
                    when    = { mapID = 296, subZone = "The Twilight Caverns" },
                    kind    = "path",
                    note    = "After landing, follow the path ahead to reach ^Sinestra^.",
                    minNote = "Ahead to Sinestra",
                    points  = {
                        { 0.579, 0.594 },
                        { 0.589, 0.546 },
                        { 0.592, 0.497 },
                        { 0.567, 0.447 },
                        { 0.512, 0.370 },
                    },
                },
            },
        },
    },
}
