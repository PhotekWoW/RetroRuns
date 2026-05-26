-------------------------------------------------------------------------------
-- RetroRuns Data -- Battle of Dazar'alor (Alliance side)
-- Battle for Azeroth, Patch 8.1.0  |  instanceID: 2070  |  journalInstanceID: 1176
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2070] = {
    instanceID        = 2070,
    journalInstanceID = 1176,
    name              = "Battle of Dazar'alor",
    expansion         = "Battle for Azeroth",
    patch             = "8.1.0",

    -- Alliance entrance: outside the BfD portal at the Boralus docks.
    -- mapID 1161 is the Boralus city map (interior); the parent zone
    -- Tiragarde Sound is mapID 895.
    entrance = {
        mapID = 1161,
        x     = 0.7057,
        y     = 0.3523,
    },

    -- mapIDs 1352, 1353, 1354, 1356, 1357 cover the Alliance route
    -- through the city interior; 1358 is "The Zocalo" (never visited
    -- by Alliance route, included for completeness); 1364 is "The
    -- Zocalo's" lower deck and is also Horde-side. 862 / 875 / 1367
    -- cover the Bay of Kings ship sequence during the Mekkatorque
    -- and Jaina encounters.
    maps = {
        [862]  = "The Great Sea",
        [875]  = "Zandalar",
        [1352] = "Port of Zandalar",
        [1353] = "Halls of Opulence",
        [1354] = "Loa's Sanctum",
        [1356] = "Walk of Kings",
        [1357] = "The Heart of the Empire",
        [1358] = "The Zocalo",
        [1367] = "Boralus Harbor",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    skipAchievement = {
        mythic = 13314,
    },

    -- Surfaced to players via the Skips window's per-row info button.
    skipTrigger = {
        achievementName = "Mythic: Lady Jaina Proudmoore",
        details         = "After zoning in, talk with ^Ensign Roberts^ to skip straight to ^Lady Jaina Proudmoore^.",
    },

    -- Glory meta-achievement for this raid. Completing all 9 per-boss
    -- criteria below awards the Dazar'alor Windreaver mount. Two of the
    -- nine criteria require 2+ players (De Lurker Be'loa needs one
    -- player on a rope while the rest fight the boss; Snow Fun Allowed
    -- requires 3 players to gather snow mounds simultaneously) -- the
    -- meta as a whole is therefore NOT fully soloable.
    gloryMeta = {
        id   = 13315,
        name = "Glory of the Dazar'alor Raider",
        rewardItemID       = 166539,
        rewardMountSpellID = 289101,
        rewardName         = "Dazar'alor Windreaver",
    },

    bosses = {
        {
            index              = 1,
            name               = "Champion of the Light",
            journalEncounterID = 2344,
            aliases            = {},
            achievements       = {
                { id = 13316, name = "Can I Get a Hek Hek Hek Yeah?", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 165550, slot = "Chest",    name = "Breastplate of Divine Purification", sources = { [17]=101923, [14]=101920, [15]=101921, [16]=101922 } },
                { id = 165834, slot = "Chest",    name = "Divine Fury Raiment",                sources = { [17]=102253, [14]=102250, [15]=102251, [16]=102252 } },
                { id = 165533, slot = "Feet",     name = "Lightgrace Sabatons",                sources = { [17]=101855, [14]=101852, [15]=101853, [16]=101854 } },
                { id = 165549, slot = "Hands",    name = "Crusade Pummelers",                  sources = { [17]=101919, [14]=101916, [15]=101917, [16]=101918 } },
                { id = 165514, slot = "Hands",    name = "Gloves of Spiritual Grace",          sources = { [17]=101777, [14]=101776, [15]=101778, [16]=101779 } },
                { id = 165519, slot = "Head",     name = "Cowl of Righteous Resolve",          sources = { [17]=101799, [14]=101796, [15]=101797, [16]=101798 } },
                { id = 165584, slot = "Off-hand", name = "Sunburst Crest",                     sources = { [17]=101991, [14]=101988, [15]=101989, [16]=101990 } },
                { id = 165921, slot = "Shoulder", name = "Pauldrons of Ancestral Vengeance",   sources = { [17]=102289, [14]=102286, [15]=102287, [16]=102288 } },
                { id = 165586, slot = "Two-Hand", name = "Dawnbreaker",                        sources = { [17]=101999, [14]=101996, [15]=101997, [16]=101998 } },
                { id = 165919, slot = "Weapon",   name = "Desecrated Blade of the Disciples",  sources = { [17]=102281, [14]=102278, [15]=102279, [16]=102280 } },
                { id = 165517, slot = "Wrist",    name = "Bracers of Regal Devotion",          sources = { [17]=101791, [14]=101788, [15]=101789, [16]=101790 } },
                { id = 165501, slot = "Wrist",    name = "Bracers of Zealous Calling",         sources = { [17]=101727, [14]=101724, [15]=101725, [16]=101726 } },
            },
        },
        {
            index              = 2,
            name               = "Jadefire Masters",
            journalEncounterID = 2323,
            aliases            = {},
            achievements       = {
                { id = 13431, name = "Hidden Dragon", meta = true, soloable = "kinda" },
            },
            soloTip            = "If you end up in the maze phase, collect a green orb and use it to bring down the barrier. Movement abilities can be used to get through the maze if needed.",
            loot = {
                { id = 165540, slot = "Chest",    name = "Mistfire Raiment",            sources = { [17]=101881, [14]=101880, [15]=101882, [16]=101883 } },
                { id = 165764, slot = "Hands",    name = "Firecaller's Handwraps",      sources = { [17]=102117, [14]=102114, [15]=102115, [16]=102116 } },
                { id = 165531, slot = "Hands",    name = "Grips of Harmonious Spirits", sources = { [17]=101847, [14]=101844, [15]=101845, [16]=101846 } },
                { id = 165500, slot = "Head",     name = "Blazewing Hood",              sources = { [17]=101723, [14]=101720, [15]=101721, [16]=101722 } },
                { id = 165548, slot = "Head",     name = "Helm of Tempered Jade",       sources = { [17]=101915, [14]=101912, [15]=101913, [16]=101914 } },
                { id = 165521, slot = "Legs",     name = "Cranedancer Leggings",        sources = { [17]=101805, [14]=101804, [15]=101806, [16]=101807 } },
                { id = 165777, slot = "Shoulder", name = "Ma'ra's Boneblade Mantle",    sources = { [17]=102165, [14]=102162, [15]=102163, [16]=102164 } },
                { id = 165587, slot = "Two-Hand", name = "Phoenixfire Staff",           sources = { [17]=102003, [14]=102000, [15]=102001, [16]=102002 } },
                { id = 165552, slot = "Waist",    name = "Embersear Waistguard",        sources = { [17]=101931, [14]=101928, [15]=101929, [16]=101930 } },
            },
        },
        {
            index              = 3,
            name               = "Grong, the Revenant",
            journalEncounterID = 2340,
            aliases            = { "Grong" },
            achievements       = {
                { id = 13383, name = "Barrel of Monkeys", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 165513, slot = "Back",             name = "Silverback Cloak",              sources = { [17]=101775, [14]=101772, [15]=101773, [16]=101774 } },
                { id = 165515, slot = "Chest",            name = "Grongpelt Vest",                sources = { [17]=101781, [14]=101780, [15]=101782, [16]=101783 } },
                { id = 165535, slot = "Head",             name = "Simian Berserker's Helm",       sources = { [17]=101861, [14]=101860, [15]=101862, [16]=101863 } },
                { id = 165582, slot = "Held In Off-hand", name = "Cursed Monkey Palm",            sources = { [17]=101983, [14]=101980, [15]=101981, [16]=101982 } },
                { id = 165499, slot = "Legs",             name = "Leggings of Dire Research",     sources = { [17]=101719, [14]=101716, [15]=101717, [16]=101718 } },
                { id = 165922, slot = "Shoulder",         name = "Bristling Fur-Lined Amice",     sources = { [17]=102763, [14]=102764, [15]=102765, [16]=102766 } },
                { id = 165555, slot = "Shoulder",         name = "Spaulders of the Gorilla King", sources = { [17]=101943, [14]=101940, [15]=101941, [16]=101942 } },
                { id = 165589, slot = "Two-Hand",         name = "Hornridged Crusher",            sources = { [17]=102011, [14]=102008, [15]=102009, [16]=102010 } },
                { id = 165525, slot = "Waist",            name = "Stretched Sinew Waistcord",     sources = { [17]=101821, [14]=101820, [15]=101822, [16]=101823 } },
                { id = 165920, slot = "Weapon",           name = "Apetagonizer's Claw",           sources = { [17]=102285, [14]=102282, [15]=102283, [16]=102284 } },
                { id = 165588, slot = "Weapon",           name = "Bonelash Paw",                  sources = { [17]=102007, [14]=102004, [15]=102005, [16]=102006 } },
                { id = 165534, slot = "Wrist",            name = "Ape Wrangler's Wristguards",    sources = { [17]=101857, [14]=101856, [15]=101858, [16]=101859 } },
                { id = 165551, slot = "Wrist",            name = "Splinter-Bone Vambraces",       sources = { [17]=101927, [14]=101924, [15]=101925, [16]=101926 } },
            },
        },
        {
            index              = 4,
            name               = "Opulence",
            journalEncounterID = 2342,
            aliases            = {},
            achievements       = {
                { id = 13345, name = "Praise the Sunflower", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 165541, slot = "Feet",   name = "Boots of the Gilded Path",     sources = { [17]=101887, [14]=101884, [15]=101885, [16]=101886 } },
                { id = 165561, slot = "Feet",   name = "Coinage Stampers",             sources = { [17]=101967, [14]=101964, [15]=101965, [16]=101966 } },
                { id = 165526, slot = "Head",   name = "Crown of A'akul's Dark Reign", sources = { [17]=101827, [14]=101824, [15]=101825, [16]=101826 } },
                { id = 165821, slot = "Head",   name = "Crown of Bloody Succession",   sources = { [17]=102209, [14]=102206, [15]=102207, [16]=102208 } },
                { id = 165818, slot = "Head",   name = "Crown of the Seducer",         sources = { [17]=102197, [14]=102194, [15]=102195, [16]=102196 } },
                { id = 165820, slot = "Head",   name = "Electrified Crown of Rahu'ai", sources = { [17]=102203, [14]=102202, [15]=102204, [16]=102205 } },
                { id = 165538, slot = "Waist",  name = "Goldenscale Girdle",           sources = { [17]=101875, [14]=101872, [15]=101873, [16]=101874 } },
                { id = 165504, slot = "Waist",  name = "Waistcord of Flowing Silk",    sources = { [17]=101737, [14]=101736, [15]=101738, [16]=101739 } },
                { id = 165591, slot = "Weapon", name = "Bloodtooth, the Soulfeaster",  sources = { [17]=102019, [14]=102016, [15]=102017, [16]=102018 } },
                { id = 165592, slot = "Weapon", name = "Goblet of Glittering Favor",   sources = { [17]=102023, [14]=102020, [15]=102021, [16]=102022 } },
                { id = 165593, slot = "Weapon", name = "Greed's Folly",                sources = { [17]=102027, [14]=102024, [15]=102025, [16]=102026 } },
                { id = 165524, slot = "Wrist",  name = "Amethyst-Studded Bindings",    sources = { [17]=101819, [14]=101816, [15]=101817, [16]=101818 } },
            },
        },
        {
            index              = 5,
            name               = "Conclave of the Chosen",
            journalEncounterID = 2330,
            aliases            = { "Conclave" },
            achievements       = {
                { id = 13325, name = "Walk the Dinosaur", meta = true, soloable = "yes" },
            },
            specialLoot = {
                { id = 165846, kind = "pet", name = "Enchanted Talon of Pa'ku" },
                { id = 165848, kind = "pet", name = "Spawn of Krag'wa" },
                { id = 165847, kind = "pet", name = "Thundering Scale of Akunda" },
            },
            loot = {
                { id = 165512, slot = "Back",     name = "Loa Exultant's Shroud",         sources = { [17]=101769, [14]=101768, [15]=101770, [16]=101771 } },
                { id = 165532, slot = "Chest",    name = "Gonk's Scale Robes",            sources = { [17]=101849, [14]=101848, [15]=101850, [16]=101851 } },
                { id = 165833, slot = "Chest",    name = "Vestments of Indomitable Will", sources = { [17]=102247, [14]=102246, [15]=102248, [16]=102249 } },
                { id = 165502, slot = "Feet",     name = "Lightfeather Footpads",         sources = { [17]=101729, [14]=101728, [15]=101730, [16]=101731 } },
                { id = 165560, slot = "Legs",     name = "Arcing Thunderlizard Legplates", sources = { [17]=101963, [14]=101960, [15]=101961, [16]=101962 } },
                { id = 165599, slot = "Ranged",   name = "Pterrorwing Longbow",           sources = { [17]=102051, [14]=102048, [15]=102049, [16]=102050 } },
                { id = 165507, slot = "Shoulder", name = "Mantle of the Skyterror",       sources = { [17]=101751, [14]=101748, [15]=101749, [16]=101750 } },
                { id = 165562, slot = "Shoulder", name = "Ridgeplate Pauldrons",          sources = { [17]=101971, [14]=101968, [15]=101969, [16]=101970 } },
                { id = 165594, slot = "Weapon",   name = "Akunda's Shocksplitter",        sources = { [17]=102031, [14]=102028, [15]=102029, [16]=102030 } },
                { id = 165595, slot = "Weapon",   name = "Blade of Encroaching Death",    sources = { [17]=102035, [14]=102032, [15]=102033, [16]=102034 } },
            },
        },
        {
            index              = 6,
            name               = "King Rastakhan",
            journalEncounterID = 2335,
            aliases            = { "Rastakhan" },
            achievements       = {
                { id = 13425, name = "We Got Spirit, How About You?", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 165832, slot = "Chest",    name = "Breastplate of the Deathbound",       sources = { [17]=102245, [14]=102242, [15]=102243, [16]=102244 } },
                { id = 165498, slot = "Chest",    name = "Vestments of the Afterlife",          sources = { [17]=101715, [14]=101712, [15]=101713, [16]=101714 } },
                { id = 165536, slot = "Legs",     name = "Deathhunter's Legguards",             sources = { [17]=101867, [14]=101864, [15]=101865, [16]=101866 } },
                { id = 165537, slot = "Shoulder", name = "Mantle of the Soulbinder's Caress",   sources = { [17]=101871, [14]=101868, [15]=101869, [16]=101870 } },
                { id = 165523, slot = "Shoulder", name = "Phantom Stalker Shoulders",           sources = { [17]=101815, [14]=101812, [15]=101813, [16]=101814 } },
                { id = 165597, slot = "Two-Hand", name = "Deathspeaker Spire",                  sources = { [17]=102043, [14]=102040, [15]=102041, [16]=102042 } },
                { id = 165596, slot = "Weapon",   name = "Last Fang of Rezan",                  sources = { [17]=102039, [14]=102036, [15]=102037, [16]=102038 } },
                { id = 165558, slot = "Wrist",    name = "Roka's Bonecrushing Manacles",        sources = { [17]=101955, [14]=101952, [15]=101953, [16]=101954 } },
            },
        },
        {
            index              = 7,
            name               = "High Tinker Mekkatorque",
            journalEncounterID = 2334,
            aliases            = { "Mekkatorque" },
            achievements       = {
                { id = 13401, name = "I Got Next!", meta = true, soloable = "kinda" },
            },
            specialLoot = {
                { id = 166518, kind = "mount", name = "G.M.O.D." },
            },
            loot = {
                { id = 165924, slot = "Back",     name = "High Tinker's Cape",             sources = { [17]=102295, [14]=102294, [15]=102296, [16]=102297 } },
                { id = 165830, slot = "Chest",    name = "Mekkatorque's Bomber Jacket",    sources = { [17]=102235, [14]=102234, [15]=102236, [16]=102237 } },
                { id = 165522, slot = "Hands",    name = "Mech-Jockey Grips",              sources = { [17]=101809, [14]=101808, [15]=101810, [16]=101811 } },
                { id = 165543, slot = "Head",     name = "Target-Tracking Headgear",       sources = { [17]=101893, [14]=101892, [15]=101894, [16]=101895 } },
                { id = 165600, slot = "Ranged",   name = "Twin-Pipe Buster Cannon",        sources = { [17]=102055, [14]=102052, [15]=102053, [16]=102054 } },
                { id = 165825, slot = "Shoulder", name = "Dyno-Sprocket Spaulders",        sources = { [17]=102225, [14]=102222, [15]=102223, [16]=102224 } },
                { id = 165497, slot = "Shoulder", name = "Giga-Charged Shoulderpads",      sources = { [17]=101711, [14]=101708, [15]=101709, [16]=101710 } },
                { id = 165598, slot = "Weapon",   name = "Servo-Claw Smasher",             sources = { [17]=102047, [14]=102044, [15]=102045, [16]=102046 } },
                { id = 165508, slot = "Wrist",    name = "Lever Stabilizing Wristwraps",   sources = { [17]=101755, [14]=101752, [15]=101753, [16]=101754 } },
            },
        },
        {
            index              = 8,
            name               = "Stormwall Blockade",
            journalEncounterID = 2337,
            aliases            = {},
            achievements       = {
                { id = 13430, name = "De Lurker Be'loa", meta = true, soloable = "no" },
            },
            soloTip            = "|cffF259C7(1)|r Click one of the Pterrordax to start the fight. |cffF259C7(2)|r Kill Brother/Sister. Killing too fast can bug the fight. |cffF259C7(3)|r Teleport to change boats and kill the other Brother/Sister. |cffF259C7(4)|r Teleport back to main platform and interrupt/kill the boss before he finishes casting Catastrophic Tides.",
            loot = {
                { id = 165557, slot = "Chest",    name = "Sea Swell Chestplate",      sources = { [17]=101951, [14]=101948, [15]=101949, [16]=101950 } },
                { id = 165546, slot = "Hands",    name = "Slimy Kelpweavers",         sources = { [17]=101907, [14]=101904, [15]=101905, [16]=101906 } },
                { id = 165556, slot = "Hands",    name = "Stormwrought Gauntlets",    sources = { [17]=101947, [14]=101944, [15]=101945, [16]=101946 } },
                { id = 165822, slot = "Head",     name = "Cowl of Tideborne Omens",   sources = { [17]=102213, [14]=102210, [15]=102211, [16]=102212 } },
                { id = 165819, slot = "Head",     name = "Tidemother's Cover",        sources = { [17]=102201, [14]=102198, [15]=102199, [16]=102200 } },
                { id = 165528, slot = "Legs",     name = "Kelp-Laced Greaves",        sources = { [17]=101833, [14]=101832, [15]=101834, [16]=101835 } },
                { id = 165506, slot = "Legs",     name = "Wavecaller Leggings",       sources = { [17]=101747, [14]=101744, [15]=101745, [16]=101746 } },
                { id = 165585, slot = "Off-hand", name = "Blockade Bulwark",          sources = { [17]=101995, [14]=101992, [15]=101993, [16]=101994 } },
                { id = 165603, slot = "Ranged",   name = "Siren's Song",              sources = { [17]=102067, [14]=102064, [15]=102065, [16]=102066 } },
                { id = 165923, slot = "Shoulder", name = "Tidal Shroud Spaulders",    sources = { [17]=102293, [14]=102290, [15]=102291, [16]=102292 } },
                { id = 165602, slot = "Two-Hand", name = "Crash of Tides",            sources = { [17]=102063, [14]=102060, [15]=102061, [16]=102062 } },
                { id = 165590, slot = "Two-Hand", name = "Docksplitter Siege Hook",   sources = { [17]=102015, [14]=102012, [15]=102013, [16]=102014 } },
                { id = 165601, slot = "Weapon",   name = "Storm-Toothed Kasuyu",      sources = { [17]=102059, [14]=102056, [15]=102057, [16]=102058 } },
            },
        },
        {
            index              = 9,
            name               = "Lady Jaina Proudmoore",
            journalEncounterID = 2343,
            aliases            = { "Jaina", "Jaina Proudmoore" },
            achievements       = {
                { id = 13410, name = "Snow Fun Allowed", meta = true, soloable = "no" },
            },
            soloTip            = "Nuke her. If the fight extends into Phase 2, jump off the boat and make your way through the snow to find ^Jaina^ and finish her off.",
            specialLoot = {
                { id = 166705, kind = "mount", name = "Glacial Tidestorm", mythicOnly = true },
            },
            loot = {
                { id = 165831, slot = "Chest",            name = "Flag Officer's Overcoat",           sources = { [17]=102239, [14]=102238, [15]=102240, [16]=102241 } },
                { id = 165505, slot = "Chest",            name = "Robes of Biting Cold",              sources = { [17]=101743, [14]=101740, [15]=101741, [16]=101742 } },
                { id = 165527, slot = "Feet",             name = "Embossed Deckwalkers",              sources = { [17]=101829, [14]=101828, [15]=101830, [16]=101831 } },
                { id = 165823, slot = "Head",             name = "Glaciercrest Helm",                 sources = { [17]=102217, [14]=102214, [15]=102215, [16]=102216 } },
                { id = 165583, slot = "Held In Off-hand", name = "Fogbreaker, Light of the Sea",      sources = { [17]=101987, [14]=101984, [15]=101985, [16]=101986 } },
                { id = 165824, slot = "Shoulder",         name = "Admiralty's Ceremonial Epaulets",   sources = { [17]=102221, [14]=102218, [15]=102219, [16]=102220 } },
                { id = 165559, slot = "Waist",            name = "Hullplate Girdle",                  sources = { [17]=101959, [14]=101956, [15]=101957, [16]=101958 } },
                { id = 165604, slot = "Weapon",           name = "Daelin Proudmoore's Saber",         sources = { [17]=102071, [14]=102068, [15]=102069, [16]=102070 } },
                { id = 165542, slot = "Wrist",            name = "Icebinder's Bracers",               sources = { [17]=101889, [14]=101888, [15]=101890, [16]=101891 } },
            },
        },
    },

    routing = {
        -- Routing: linear progression for Alliance.
        --   1. Champion of the Light    requires {}
        --   2. Jadefire Masters         requires { 1 }
        --   3. Grong, the Revenant      requires { 2 }
        --   4. Opulence                 requires { 3 }
        --   5. Conclave of the Chosen   requires { 4 }
        --   6. King Rastakhan           requires { 5 }
        --   7. High Tinker Mekkatorque  requires { 6 }
        --   8. Stormwall Blockade       requires { 7 }
        --   9. Lady Jaina Proudmoore    requires { 8 }

        -- 1. Champion of the Light
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Champion of the Light",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 1352 },
                    kind    = "path",
                    note    = "After zoning in, proceed straight ahead to the first boss room. Kill trash to start the encounter with ^Champion of the Light^.",
                    points  = {
                        { 0.493, 0.883 },
                        { 0.492, 0.735 },
                    },
                },
            },
        },

        -- 2. Jadefire Masters
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Jadefire Masters",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 1352 },
                    kind    = "path",
                    note    = "After defeating the ^Champion of the Light^, follow the linear path to the right and work your way towards the next boss, ^Jadefire Masters^. Kill trash on the way.",
                    points  = {
                        { 0.518, 0.695 },
                        { 0.602, 0.679 },
                        { 0.600, 0.634 },
                        { 0.492, 0.629 },
                        { 0.492, 0.555 },
                    },
                },
            },
        },

        -- 3. Grong, the Revenant
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Grong, the Revenant",
            requires  = { 2 },
            segments  = {
                {
                    when    = { mapID = 1352 },
                    kind    = "path",
                    note    = "After defeating ^Jadefire Masters^, proceed up the long staircase behind them to reach ^Grong, the Revenant^. Kill trash at the top of the stairs to start the encounter.",
                    points  = {
                        { 0.492, 0.555 },
                        { 0.493, 0.345 },
                    },
                },
            },
        },

        -- 4. Opulence
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Opulence",
            requires  = { 3 },
            segments  = {
                {
                    when    = { mapID = 1352 },
                    kind    = "path",
                    note    = "After killing ^Grong^, continue up the stairwell behind him towards the map exit labeled ^Halls of Opulence^. Jump in the hole when you reach the end of the path.",
                    points  = {
                        { 0.490, 0.280 },
                        { 0.492, 0.194 },
                        { 0.555, 0.193 },
                        { 0.556, 0.137 },
                        { 0.502, 0.136 },
                    },
                },
                {
                    when    = { mapID = 1353 },
                    kind    = "path",
                    note    = "Inside the ^Halls of Opulence^, proceed straight ahead to the middle area to engage ^Opulence^.",
                    points  = {
                        { 0.421, 0.846 },
                        { 0.422, 0.548 },
                    },
                },
            },
        },

        -- 5. Conclave of the Chosen
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Conclave of the Chosen",
            requires  = { 4 },
            segments  = {
                {
                    when    = { mapID = 1353 },
                    kind    = "path",
                    note    = "After killing ^Opulence^, follow the path straight ahead and make your way to the map exit labeled ^Loa's Sanctum^.",
                    points  = {
                        { 0.421, 0.480 },
                        { 0.421, 0.215 },
                        { 0.333, 0.215 },
                        { 0.334, 0.104 },
                        { 0.399, 0.101 },
                    },
                },
                {
                    when    = { mapID = 1354 },
                    kind    = "path",
                    note    = "Continue straight ahead to engage ^Conclave of the Chosen^.",
                    points  = {
                        { 0.474, 0.189 },
                        { 0.471, 0.633 },
                    },
                },
            },
        },

        -- 6. King Rastakhan
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "King Rastakhan",
            requires  = { 5 },
            segments  = {
                {
                    when    = { mapID = 1354 },
                    kind    = "path",
                    note    = "After defeating ^Conclave^, exit the room to the east and ride the elevator up to the ^Walk of Kings^.",
                    points  = {
                        { 0.499, 0.677 },
                        { 0.643, 0.680 },
                        { 0.641, 0.782 },
                    },
                },
                {
                    when    = { mapID = 1356 },
                    kind    = "path",
                    note    = "After getting off the elevator in ^Walk of Kings^, follow the linear path around to ^The Heart of the Empire^.",
                    points  = {
                        { 0.650, 0.684 },
                        { 0.650, 0.389 },
                        { 0.363, 0.388 },
                        { 0.360, 0.569 },
                    },
                },
                {
                    when     = { mapID = 1357 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "Kill trash in the boss room to trigger some dialog and start the encounter with ^King Rastakhan^.",
                    points   = {
                        { 0.5, 0.5 },
                    },
                },
            },
        },

        -- 7. High Tinker Mekkatorque
        --
        -- Multi-segment cross-mapID step: 1357 (Heart of the Empire) ->
        -- 875 (Bay of Kings) via gryphon flight -> 1367 (Boralus Harbor)
        -- via ship -> 1352 (Dazar'alor) for final landing. The flight
        -- briefly transits 1352 mid-route, which is also seg 4's mapID;
        -- the seg routing accounts for this by gating on subZone so the
        -- transit flicker doesn't false-match seg 4.
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "High Tinker Mekkatorque",
            requires  = { 6 },
            segments  = {
                {
                    when    = { mapID = 1357 },
                    kind    = "path",
                    note    = "After defeating ^King Rastakhan^, take the western exit from the room and make your way towards the map exit labeled ^Port of Zandalar^. Interact with the ^7th Legion Gryphon^ to be flown to the next area.",
                    points  = {
                        { 0.473, 0.538 },
                        { 0.407, 0.464 },
                        { 0.322, 0.462 },
                        { 0.321, 0.714 },
                        { 0.471, 0.722 },
                        { 0.473, 0.846 },
                    },
                },
                {
                    when     = { mapID = 875 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "After landing on the ship, make your way to the top of the ship and talk to ^Tandred Proudmoore^ to proceed.",
                    points   = {
                        { 0.558, 0.699 },
                    },
                },
                {
                    when    = { mapID = 1367 },
                    kind    = "path",
                    note    = "When the ship stops, talk to ^Ensign Roberts^ to continue.",
                    points  = {},
                },
                {
                    when    = { mapID = 1352 },
                    kind    = "path",
                    note    = "After you reach the next area, go downstairs and kill trash to begin the fight against ^High Tinker Mekkatorque^.",
                    points  = {
                        { 0.492, 0.200 },
                        { 0.491, 0.285 },
                    },
                },
            },
        },

        -- 8. Stormwall Blockade
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Stormwall Blockade",
            requires  = { 7 },
            segments  = {
                {
                    when    = { mapID = 1352 },
                    kind    = "path",
                    note    = "After defeating ^Mekkatorque^, make your way down the long path south, and kill the trash at the end of the bridge. Interact with a ^Pterrordax^ to start the encounter with ^Stormwall Blockade^.",
                    points  = {
                        { 0.492, 0.354 },
                        { 0.492, 0.889 },
                    },
                },
            },
        },

        -- 9. Lady Jaina Proudmoore
        {
            step      = 9,
            priority  = 1,
            bossIndex = 9,
            title     = "Lady Jaina Proudmoore",
            requires  = { 8 },
            segments  = {
                {
                    when    = { mapID = 1352 },
                    kind    = "poi",
                    poiSize = 35,
                    note    = "After defeating ^Stormwall Blockade^, walk onto the newly-arrived ship and speak with ^Captain Zadari^ to begin the ^Lady Jaina Proudmoore^ encounter.",
                    points  = {
                        { 0.484, 0.975 },
                    },
                },
            },
        },
    },
}
