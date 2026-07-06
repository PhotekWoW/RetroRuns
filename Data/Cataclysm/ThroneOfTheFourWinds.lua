-------------------------------------------------------------------------------
-- RetroRuns Data -- Throne of the Four Winds
-- Cataclysm, Patch 4.0.3  |  instanceID: 754  |  journalInstanceID: 74
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[754] = {
    instanceID        = 754,
    journalInstanceID = 74,
    name              = "Throne of the Four Winds",
    expansion         = "Cataclysm",
    patch             = "4.0.3",

    exitNote = "None available",

    -- Both Normal and Heroic are offered, folded into one weekly lockout.
    difficultyModel     = "shared",
    availableDifficulties = { 14, 15 },

    entrance = {
        mapID = 249,
        x     = 0.3837,
        y     = 0.8063,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [328] = "Throne of the Four Winds",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [63682] = 2,  -- Helm of the Forlorn Vanquisher
            [63683] = 2,  -- Helm of the Forlorn Conqueror
            [63684] = 2,  -- Helm of the Forlorn Protector
            [64314] = 2,  -- Mantle of the Forlorn Vanquisher
            [64315] = 2,  -- Mantle of the Forlorn Conqueror
            [64316] = 2,  -- Mantle of the Forlorn Protector
            [65000] = 2,  -- Crown of the Forlorn Protector
            [65001] = 2,  -- Crown of the Forlorn Conqueror
            [65002] = 2,  -- Crown of the Forlorn Vanquisher
            [65087] = 2,  -- Shoulders of the Forlorn Protector
            [65088] = 2,  -- Shoulders of the Forlorn Conqueror
            [65089] = 2,  -- Shoulders of the Forlorn Vanquisher
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
            name               = "The Conclave of Wind",
            journalEncounterID = 154,
            aliases            = { "Conclave of Wind" },
            achievements       = {
                { id = 5122, name = "Heroic: Conclave of Wind", meta = true, soloable = "yes" },
                { id = 5304, name = "Stay Chill", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63497, slot = "Waist", name = "Gale Rouser Belt", sources = { [14]=31850, [15]=32911 } },
                { id = 63496, slot = "Waist", name = "Lightning Well Belt", sources = { [14]=31849, [15]=32914 } },
                { id = 63490, slot = "Waist", name = "Sky Strider Belt", sources = { [14]=31844, [15]=32908 } },
                { id = 63498, slot = "Waist", name = "Soul Breath Belt", sources = { [14]=31851, [15]=32913 } },
                { id = 63492, slot = "Waist", name = "Star Chaser Belt", sources = { [14]=31846, [15]=32907 } },
                { id = 63495, slot = "Waist", name = "Tempest Keeper Belt", sources = { [14]=31848, [15]=32912 } },
                { id = 63491, slot = "Waist", name = "Thunder Wall Belt", sources = { [14]=31845, [15]=32909 } },
                { id = 63493, slot = "Waist", name = "Wind Stalker Belt", sources = { [14]=31847, [15]=32910 } },
            },
            soloTip            = "Jump from West -> North -> East and kill them all within 60 seconds of eachother.",
        },
        {
            index              = 2,
            name               = "Al'Akir",
            journalEncounterID = 155,
            aliases            = {},
            achievements       = {
                { id = 5305, name = "Four Play", meta = true, soloable = "yes" },
                { id = 5123, name = "Heroic: Al'Akir", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 69834, slot = "Back", name = "Cloudburst Cloak", sources = { [14]=35576, [15]=35590 } },
                { id = 69831, slot = "Back", name = "Mistral Drape", sources = { [14]=35574, [15]=35592 } },
                { id = 69833, slot = "Back", name = "Permafrost Cape", sources = { [14]=35575, [15]=35589 } },
                { id = 69835, slot = "Back", name = "Planetary Drape", sources = { [14]=35577, [15]=35591 } },
                { id = 63506, slot = "Legs", name = "Gale Rouser Leggings", sources = { [14]=31858, [15]=32920 } },
                { id = 63505, slot = "Legs", name = "Lightning Well Legguards", sources = { [14]=31857, [15]=32922 } },
                { id = 63500, slot = "Legs", name = "Sky Strider Greaves", sources = { [14]=31852, [15]=32916 } },
                { id = 63507, slot = "Legs", name = "Soul Breath Leggings", sources = { [14]=31859, [15]=32919 } },
                { id = 63502, slot = "Legs", name = "Star Chaser Legguards", sources = { [14]=31854, [15]=32915 } },
                { id = 63504, slot = "Legs", name = "Tempest Keeper Leggings", sources = { [14]=31856, [15]=32921 } },
                { id = 63501, slot = "Legs", name = "Thunder Wall Greaves", sources = { [14]=31853, [15]=32917 } },
                { id = 63503, slot = "Legs", name = "Wind Stalker Leggings", sources = { [14]=31855, [15]=32918 } },
                { id = 68129, slot = "Weapon", name = "Stormwake, the Tempest's Reach", sources = { [14]=34730, [15]=34733 } },
                { id = 60328, slot = "Head", name = "Earthen Faceguard", sources = { [14]=30060, [15]=32832 }, classes = { 1 } },
                { id = 60325, slot = "Head", name = "Earthen Helmet", sources = { [14]=30057, [15]=32827 }, classes = { 1 } },
                { id = 60308, slot = "Head", name = "Faceguard of the Raging Elements", sources = { [14]=30040, [15]=32807 }, classes = { 7 } },
                { id = 60243, slot = "Head", name = "Firelord's Hood", sources = { [14]=29992, [15]=32771 }, classes = { 8 } },
                { id = 60315, slot = "Head", name = "Headpiece of the Raging Elements", sources = { [14]=30047, [15]=32817 }, classes = { 7 } },
                { id = 60320, slot = "Head", name = "Helmet of the Raging Elements", sources = { [14]=30052, [15]=32812 }, classes = { 7 } },
                { id = 60303, slot = "Head", name = "Lightning-Charged Headguard", sources = { [14]=30035, [15]=32767 }, classes = { 3 } },
                { id = 60351, slot = "Head", name = "Magma Plated Faceguard", sources = { [14]=30078, [15]=32747 }, classes = { 6 } },
                { id = 60341, slot = "Head", name = "Magma Plated Helmet", sources = { [14]=30068, [15]=32742 }, classes = { 6 } },
                { id = 60258, slot = "Head", name = "Mercurial Cowl", sources = { [14]=30007, [15]=32791 }, classes = { 5 } },
                { id = 60256, slot = "Head", name = "Mercurial Hood", sources = { [14]=30005, [15]=32796 }, classes = { 5 } },
                { id = 60356, slot = "Head", name = "Reinforced Sapphirium Faceguard", sources = { [14]=30083, [15]=32787 }, classes = { 2 } },
                { id = 60359, slot = "Head", name = "Reinforced Sapphirium Headguard", sources = { [14]=30086, [15]=32782 }, classes = { 2 } },
                { id = 60346, slot = "Head", name = "Reinforced Sapphirium Helmet", sources = { [14]=30073, [15]=32777 }, classes = { 2 } },
                { id = 60249, slot = "Head", name = "Shadowflame Hood", sources = { [14]=29998, [15]=32821 }, classes = { 9 } },
                { id = 60282, slot = "Head", name = "Stormrider's Cover", sources = { [14]=30018, [15]=32761 }, classes = { 11 } },
                { id = 60286, slot = "Head", name = "Stormrider's Headpiece", sources = { [14]=30022, [15]=32751 }, classes = { 11 } },
                { id = 60277, slot = "Head", name = "Stormrider's Helm", sources = { [14]=30013, [15]=32756 }, classes = { 11 } },
                { id = 60299, slot = "Head", name = "Wind Dancer's Helmet", sources = { [14]=30031, [15]=32802 }, classes = { 4 } },
                { id = 60327, slot = "Shoulder", name = "Earthen Pauldrons", sources = { [14]=30059, [15]=32829 }, classes = { 1 } },
                { id = 60331, slot = "Shoulder", name = "Earthen Shoulderguards", sources = { [14]=30063, [15]=32834 }, classes = { 1 } },
                { id = 60246, slot = "Shoulder", name = "Firelord's Mantle", sources = { [14]=29995, [15]=32774 }, classes = { 8 } },
                { id = 60306, slot = "Shoulder", name = "Lightning-Charged Spaulders", sources = { [14]=30038, [15]=32769 }, classes = { 3 } },
                { id = 60343, slot = "Shoulder", name = "Magma Plated Pauldrons", sources = { [14]=30070, [15]=32744 }, classes = { 6 } },
                { id = 60353, slot = "Shoulder", name = "Magma Plated Shoulderguards", sources = { [14]=30080, [15]=32749 }, classes = { 6 } },
                { id = 60311, slot = "Shoulder", name = "Mantle of the Raging Elements", sources = { [14]=30043, [15]=32809 }, classes = { 7 } },
                { id = 60262, slot = "Shoulder", name = "Mercurial Mantle", sources = { [14]=30010, [15]=32794 }, classes = { 5 } },
                { id = 60253, slot = "Shoulder", name = "Mercurial Shoulderwraps", sources = { [14]=30002, [15]=32799 }, classes = { 5 } },
                { id = 60362, slot = "Shoulder", name = "Reinforced Sapphirium Mantle", sources = { [14]=30089, [15]=32784 }, classes = { 2 } },
                { id = 60348, slot = "Shoulder", name = "Reinforced Sapphirium Pauldrons", sources = { [14]=30075, [15]=32779 }, classes = { 2 } },
                { id = 60358, slot = "Shoulder", name = "Reinforced Sapphirium Shoulderguards", sources = { [14]=30085, [15]=32789 }, classes = { 2 } },
                { id = 60252, slot = "Shoulder", name = "Shadowflame Mantle", sources = { [14]=30001, [15]=32824 }, classes = { 9 } },
                { id = 60317, slot = "Shoulder", name = "Shoulderwraps of the Raging Elements", sources = { [14]=30049, [15]=32819 }, classes = { 7 } },
                { id = 60322, slot = "Shoulder", name = "Spaulders of the Raging Elements", sources = { [14]=30054, [15]=32814 }, classes = { 7 } },
                { id = 60279, slot = "Shoulder", name = "Stormrider's Mantle", sources = { [14]=30015, [15]=32759 }, classes = { 11 } },
                { id = 60284, slot = "Shoulder", name = "Stormrider's Shoulderwraps", sources = { [14]=30020, [15]=32764 }, classes = { 11 } },
                { id = 60289, slot = "Shoulder", name = "Stormrider's Spaulders", sources = { [14]=30025, [15]=32754 }, classes = { 11 } },
                { id = 60302, slot = "Shoulder", name = "Wind Dancer's Spaulders", sources = { [14]=30034, [15]=32804 }, classes = { 4 } },
            },
            specialLoot = {
                { id = 63041, kind = "mount", name = "Reins of the Drake of the South Wind" },
                { id = 152973, kind = "pet", name = "Zephyr's Call" },
                { id = 138836, kind = "illusion", name = "Illusion: Windfury", sourceID = 5875 },
            },
        },
    },

    routing = {

        -- 1. Conclave of the Wind
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Conclave of the Wind",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 328 },
                    kind        = "poi",
                    noMarker    = true,
                    mapLabel    = "1",
                    mapLabelPos = "middle",
                    note        = "After zoning in, go to the West platform to start the fight with ^Conclave of the Wind^.",
                    points      = {
                        { 0.352, 0.494 },
                    },
                },
                {
                    when        = { mapID = 328 },
                    kind        = "poi",
                    noMarker    = true,
                    mapLabel    = "2",
                    mapLabelPos = "middle",
                    points      = {
                        { 0.473, 0.313 },
                    },
                },
                {
                    when        = { mapID = 328 },
                    kind        = "poi",
                    noMarker    = true,
                    mapLabel    = "3",
                    mapLabelPos = "middle",
                    points      = {
                        { 0.595, 0.494 },
                    },
                },
            },
        },

        -- 2. Al'Akir
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Al'Akir",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 328 },
                    kind        = "poi",
                    noMarker    = true,
                    mapLabel    = "Slipstream",
                    mapLabelPos = "middle",
                    note        = "After defeating ^Conclave of Wind^, collect the loot chest on the north platform, then click on the nearby ^Slipstream^ to be flown to the main platform to face ^Al'Akir^.",
                    points      = {
                        { 0.475, 0.227 },
                    },
                },
            },
        },

    },
}
