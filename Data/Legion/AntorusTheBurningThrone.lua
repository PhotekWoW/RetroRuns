-------------------------------------------------------------------------------
-- RetroRuns Data -- Antorus, the Burning Throne
-- Legion, Patch 7.3.2  |  instanceID: 1712  |  journalInstanceID: 946
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1712] = {
    instanceID        = 1712,
    journalInstanceID = 946,
    name              = "Antorus, the Burning Throne",
    expansion         = "Legion",
    patch             = "7.3.2",

    exitNote = "At the bottom of the stairs, talk to Grand Artificer Romuul for several teleport options.",

    -- Entrance is in Antoran Wastes (mapID 885) on Argus, at the
    -- crack beneath the artillery platform near Felfire Armory --
    -- not the main gates (which kill all who walk near them). The
    -- approach is unnamed within Antoran Wastes (no sub-zone label).
    entrance = {
        mapID   = 885,
        x       = 0.549,
        y       = 0.625,
        subZone = "",
    },

    -- "Upper Deck" and "Lower Deck" are transit-only floors with no
    -- boss content -- never surface in routing, so omitted from maps[].
    maps = {
        [909] = "Antorus, the Burning Throne",
        [910] = "Gaze of the Legion",
        [911] = "Halls of the Boundless Reach",
        [912] = "Elunaria",
        [913] = "Elarian Sanctuary",
        [914] = "The Exhaust",
        [915] = "The Burning Throne",
        [916] = "Chamber of Anguish",
        [917] = "The World Soul",
        [918] = "Seat of the Pantheon",
    },

    tierSets = {
        labels       = { "Antorus, the Burning Throne" },
        tokenSources = {},
    },

    -- Two parallel skip chains, each with the standard
    -- normal/heroic/mythic per-difficulty quest cascade. See the
    -- header docblock for narrative context.
    --   * Imonar (Dark Passage): defeat Imonar 4x at the matching
    --     difficulty to collect 4 Runes of Passage (item 152902);
    --     enables skipping directly to Imonar the Soulhunter.
    --   * Aggramar (Heart of Argus): defeat Aggramar 4x at the
    --     matching difficulty; enables skipping directly to Aggramar.
    skipQuests = {
        { label = "Imonar",   normal = 49032, heroic = 49075, mythic = 49076 },
        { label = "Aggramar", normal = 49133, heroic = 49134, mythic = 49135 },
    },

    -- Surfaced to players via the Skips window's per-row info button.
    skipTrigger = {
        questNames = {
            Imonar   = "Antorus, the Burning Throne: Dark Passage",
            Aggramar = "Antorus, the Burning Throne: The Heart of Argus",
        },
        details   = "After killing ^Garothi Worldbreaker^, you can take the teleporter to whichever skip you have unlocked:\n  - The Exhaust: ^Imonar the Soulhunter^\n  - The Burning Throne: ^Aggramar^\n\nNote: RetroRuns only has the route built for Aggramar at this time.",
    },

    -- Glory meta-achievement for this raid. Completing all 11 per-boss
    -- achievements below awards the Antoran Gloomhound mount.
    gloryMeta = {
        id   = 11987,
        name = "Glory of the Argus Raider",
        rewardItemID       = 152815,
        rewardMountSpellID = 253087,
        rewardName         = "Antoran Gloomhound",
    },

    bosses = {

        {
            index              = 1,
            name               = "Garothi Worldbreaker",
            journalEncounterID = 1992,
            aliases            = {},
            achievements       = {
                { id = 11930, name = "Worm-monger", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 151937, slot = "Back",    name = "Cloak of the Burning Vanguard",               sources = { [17]=90971, [14]=89723, [15]=90972, [16]=90973 } },
                { id = 152017, slot = "Chest",   name = "Soul-Tempered Chestplate",                    sources = { [17]=89941, [14]=89942, [15]=89943, [16]=89944 } },
                { id = 152009, slot = "Feet",    name = "Doomwalker Warboots",                         sources = { [17]=89909, [14]=89910, [15]=89911, [16]=89912 } },
                { id = 151998, slot = "Hands",   name = "Heedless Eradication Gauntlets",              sources = { [17]=89865, [14]=89866, [15]=89867, [16]=89868 } },
                { id = 151943, slot = "Head",    name = "Crown of Relentless Annihilation",            sources = { [17]=89741, [14]=89742, [15]=89743, [16]=89744 } },
                { id = 152002, slot = "Legs",    name = "Battalion-Shattering Leggings",               sources = { [17]=89881, [14]=89882, [15]=89883, [16]=89884 } },
                { id = 151987, slot = "Legs",    name = "Breach-Blocker Legguards",                    sources = { [17]=89821, [14]=89822, [15]=89823, [16]=89824 } },
                { id = 151988, slot = "Shoulder",name = "Shoulderpads of the Demonic Blitz",           sources = { [17]=89825, [14]=89826, [15]=89827, [16]=89828 } },
                { id = 151951, slot = "Waist",   name = "Enhanced Worldscorcher Cinch",                sources = { [17]=89773, [14]=89774, [15]=89775, [16]=89776 } },
            },
        },
        {
            index              = 2,
            name               = "Felhounds of Sargeras",
            journalEncounterID = 1987,
            aliases            = {},
            achievements       = {
                { id = 12065, name = "Hounds Good To Me", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 151980, slot = "Chest",   name = "Harness of Oppressing Dark",                  sources = { [17]=89793, [14]=89794, [15]=89795, [16]=89796 } },
                { id = 151947, slot = "Chest",   name = "Vestments of Enflamed Blight",                sources = { [17]=89757, [14]=89758, [15]=89759, [16]=89760 } },
                { id = 151983, slot = "Feet",    name = "Vicious Flamepaws",                           sources = { [17]=89805, [14]=89806, [15]=89807, [16]=89808 } },
                { id = 152012, slot = "Hands",   name = "Molten Bite Handguards",                      sources = { [17]=89921, [14]=89922, [15]=89923, [16]=89924 } },
                { id = 152000, slot = "Head",    name = "Shadowfused Chain Coif",                      sources = { [17]=89873, [14]=89874, [15]=89875, [16]=89876 } },
                { id = 152004, slot = "Shoulder",name = "Pauldrons of the Soulburner",                 sources = { [17]=89889, [14]=89890, [15]=89891, [16]=89892 } },
                { id = 151949, slot = "Shoulder",name = "Soul-Siphon Mantle",                          sources = { [17]=89765, [14]=89766, [15]=89767, [16]=89768 } },
                { id = 152021, slot = "Waist",   name = "Flamelicked Girdle",                          sources = { [17]=89957, [14]=89958, [15]=89959, [16]=89960 } },
            },
            specialLoot = {
                { id = 152816, kind = "mount", name = "Antoran Charhound" },
            },
        },
        {
            index              = 3,
            name               = "Antoran High Command",
            journalEncounterID = 1997,
            aliases            = {},
            achievements       = {
                { id = 12129, name = "This is the War Room!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 152125, slot = "Back",    name = "Bearmantle Cloak",                            sources = { [17]=90059, [14]=90060, [15]=90061, [16]=90062 }, classes = { 11 } },
                { id = 152143, slot = "Back",    name = "Cloak of Chi-Ji",                             sources = { [17]=90131, [14]=90132, [15]=90133, [16]=90134 }, classes = { 10 } },
                { id = 152161, slot = "Back",    name = "Cloak of the Dashing Scoundrel",              sources = { [17]=90203, [14]=90204, [15]=90205, [16]=90206 }, classes = { 4 } },
                { id = 152167, slot = "Back",    name = "Drape of Venerated Spirits",                  sources = { [17]=90227, [14]=90228, [15]=90229, [16]=90230 }, classes = { 7 } },
                { id = 152113, slot = "Back",    name = "Dreadwake Greatcloak",                        sources = { [17]=90011, [14]=90012, [15]=90013, [16]=90014 }, classes = { 6 } },
                { id = 152119, slot = "Back",    name = "Felreaper Drape",                             sources = { [17]=90035, [14]=90036, [15]=90037, [16]=90038 }, classes = { 12 } },
                { id = 152154, slot = "Back",    name = "Gilded Seraph's Drape",                       sources = { [17]=90175, [14]=90176, [15]=90177, [16]=90178 }, classes = { 5 } },
                { id = 152172, slot = "Back",    name = "Grim Inquisitor's Cloak",                     sources = { [17]=90247, [14]=90248, [15]=90249, [16]=90250 }, classes = { 9 } },
                { id = 152179, slot = "Back",    name = "Juggernaut Cloak",                            sources = { [17]=90275, [14]=90276, [15]=90277, [16]=90278 }, classes = { 1 } },
                { id = 152149, slot = "Back",    name = "Light's Vanguard Greatcloak",                 sources = { [17]=90155, [14]=90156, [15]=90157, [16]=90158 }, classes = { 2 } },
                { id = 152136, slot = "Back",    name = "Runebound Cape",                              sources = { [17]=90103, [14]=90104, [15]=90105, [16]=90106 }, classes = { 8 } },
                { id = 152131, slot = "Back",    name = "Serpentstalker Drape",                        sources = { [17]=90083, [14]=90085, [15]=90086, [16]=90084 }, classes = { 3 } },
                { id = 151994, slot = "Chest",   name = "Fleet Commander's Hauberk",                   sources = { [17]=89849, [14]=89850, [15]=89851, [16]=89852 } },
                { id = 152011, slot = "Feet",    name = "Eredar Warcouncil Sabatons",                  sources = { [17]=89917, [14]=89918, [15]=89919, [16]=89920 } },
                { id = 151985, slot = "Head",    name = "General Erodus' Tricorne",                    sources = { [17]=89813, [14]=89814, [15]=89815, [16]=89816 } },
                { id = 152424, slot = "Legs",    name = "Legwraps of the Seasoned Exterminator",       sources = { [17]=90516, [14]=90517, [15]=90518, [16]=90519 } },
                { id = 152019, slot = "Shoulder",name = "Pauldrons of the Eternal Offensive",          sources = { [17]=89949, [14]=89950, [15]=89951, [16]=89952 } },
                { id = 152006, slot = "Waist",   name = "Depraved Tactician's Waistguard",             sources = { [17]=89897, [14]=89898, [15]=89899, [16]=89900 } },
                { id = 151992, slot = "Wrist",   name = "Fiendish Logistician's Wristwraps",           sources = { [17]=89841, [14]=89842, [15]=89843, [16]=89844 } },
                { id = 151953, slot = "Wrist",   name = "Man'ari Pyromancer Cuffs",                    sources = { [17]=89781, [14]=89782, [15]=89783, [16]=89784 } },
            },
        },
        {
            index              = 4,
            name               = "Portal Keeper Hasabel",
            journalEncounterID = 1985,
            aliases            = {},
            achievements       = {
                { id = 11928, name = "Portal Combat", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 151945, slot = "Feet",    name = "Lady Dacidion's Silk Slippers",               sources = { [17]=89749, [14]=89750, [15]=89751, [16]=89752 } },
                { id = 151941, slot = "Hands",   name = "Aranasi Shadow-Weaver's Gloves",              sources = { [17]=89733, [14]=89734, [15]=89735, [16]=89736 } },
                { id = 152086, slot = "Hands",   name = "Grips of Hungering Shadows",                  sources = { [17]=89982, [14]=89983, [15]=89984, [16]=89985 } },
                { id = 152001, slot = "Head",    name = "Nexus Conductor's Headgear",                  sources = { [17]=89877, [14]=89878, [15]=89879, [16]=89880 } },
                { id = 152020, slot = "Waist",   name = "Nathrezim Battle Girdle",                     sources = { [17]=89953, [14]=89954, [15]=89955, [16]=89956 } },
                { id = 151990, slot = "Waist",   name = "Portal Keeper's Cincture",                    sources = { [17]=89833, [14]=89834, [15]=89835, [16]=89836 } },
                { id = 152008, slot = "Wrist",   name = "Reality-Splitting Wristguards",               sources = { [17]=89905, [14]=89906, [15]=89907, [16]=89908 } },
            },
        },
        {
            index              = 5,
            name               = "Eonar the Life-Binder",
            journalEncounterID = 2025,
            -- The saved-instance cache stores this encounter under the
            -- event name "The Defense of Eonar" (Eonar herself is the NPC
            -- the player is defending, not a tap-and-DPS target). Without
            -- this alias, SyncFromSavedRaidInfo cannot match the lockout-
            -- cache string to our boss row -- so on /reload after a kill,
            -- Eonar comes back as not-killed even though the lockout has
            -- the credit. ENCOUNTER_END's live path uses the encounter ID
            -- map and resolves correctly; only the post-/reload restoration
            -- path needs the alias.
            aliases            = { "Eonar", "The Defense of Eonar" },
            achievements       = {
                { id = 12067, name = "Spheres of Influence", meta = true, soloable = "yes" },
            },
            soloTip            = "|cffF259C7(1)|r Watch for invasions on the minimap. Use Surge of Life to get around the map and defeat waves as they spawn. |cffF259C7(2)|r After clearing 2 waves, boss will emote that invaders are charging their weapons. This is your queue to walk over one of the teleports near the pull location to enter the ship. |cffF259C7(3)|r After entering the ship, kill the mob and then click all 4 crystals in each corner. Jump out of the ship and resume killing waves until the encounter completes.",
            loot = {
                { id = 152124, slot = "Chest",   name = "Bearmantle Harness",                          sources = { [17]=90055, [14]=90056, [15]=90057, [16]=90058 }, classes = { 11 } },
                { id = 152112, slot = "Chest",   name = "Dreadwake Bonecage",                          sources = { [17]=90007, [14]=90008, [15]=90009, [16]=90010 }, classes = { 6 } },
                { id = 152118, slot = "Chest",   name = "Felreaper Vest",                              sources = { [17]=90031, [14]=90032, [15]=90033, [16]=90034 }, classes = { 12 } },
                { id = 152158, slot = "Chest",   name = "Gilded Seraph's Robes",                       sources = { [17]=90191, [14]=90192, [15]=90193, [16]=90194 }, classes = { 5 } },
                { id = 152176, slot = "Chest",   name = "Grim Inquisitor's Robes",                     sources = { [17]=90263, [14]=90264, [15]=90265, [16]=90266 }, classes = { 9 } },
                { id = 152178, slot = "Chest",   name = "Juggernaut Breastplate",                      sources = { [17]=90271, [14]=90272, [15]=90273, [16]=90274 }, classes = { 1 } },
                { id = 152148, slot = "Chest",   name = "Light's Vanguard Breastplate",                sources = { [17]=90151, [14]=90152, [15]=90153, [16]=90154 }, classes = { 2 } },
                { id = 152166, slot = "Chest",   name = "Robes of Venerated Spirits",                  sources = { [17]=90223, [14]=90224, [15]=90225, [16]=90226 }, classes = { 7 } },
                { id = 152140, slot = "Chest",   name = "Runebound Tunic",                             sources = { [17]=90119, [14]=90120, [15]=90121, [16]=90122 }, classes = { 8 } },
                { id = 152130, slot = "Chest",   name = "Serpentstalker Tunic",                        sources = { [17]=90079, [14]=90080, [15]=90081, [16]=90082 }, classes = { 3 } },
                { id = 152142, slot = "Chest",   name = "Tunic of Chi-Ji",                             sources = { [17]=90127, [14]=90128, [15]=90129, [16]=90130 }, classes = { 10 } },
                { id = 152160, slot = "Chest",   name = "Vest of the Dashing Scoundrel",               sources = { [17]=90199, [14]=90200, [15]=90201, [16]=90202 }, classes = { 4 } },
                { id = 151981, slot = "Feet",    name = "Life-Bearing Footpads",                       sources = { [17]=89797, [14]=89798, [15]=89799, [16]=89800 } },
                { id = 152681, slot = "Head",    name = "Headdress of Living Brambles",                sources = { [17]=90568, [14]=90569, [15]=90570, [16]=90571 } },
                { id = 152013, slot = "Head",    name = "Helmet of the Hidden Sanctuary",              sources = { [17]=89925, [14]=89926, [15]=89927, [16]=89928 } },
                { id = 151952, slot = "Waist",   name = "Cord of Blossoming Petals",                   sources = { [17]=89777, [14]=89778, [15]=89779, [16]=89780 } },
                { id = 152007, slot = "Waist",   name = "Sash of the Gilded Rose",                     sources = { [17]=89901, [14]=89902, [15]=89903, [16]=89904 } },
                { id = 152023, slot = "Wrist",   name = "Vambraces of Life's Assurance",               sources = { [17]=89965, [14]=89966, [15]=89967, [16]=89968 } },
            },
        },
        {
            index              = 6,
            name               = "Imonar the Soulhunter",
            journalEncounterID = 2009,
            aliases            = {},
            achievements       = {
                { id = 11949, name = "Hard to Kill", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 151938, slot = "Back",    name = "Drape of the Spirited Hunt",                  sources = { [17]=90974, [14]=89724, [15]=90975, [16]=90976 } },
                { id = 151996, slot = "Feet",    name = "Deft Soulhunter's Sabatons",                  sources = { [17]=89857, [14]=89858, [15]=89859, [16]=89860 } },
                { id = 151939, slot = "Feet",    name = "Whisperstep Runners",                         sources = { [17]=89725, [14]=89726, [15]=89727, [16]=89728 } },
                { id = 152687, slot = "Hands",   name = "Imonar's Demi-Gauntlets",                     sources = { [17]=90588, [14]=90589, [15]=90590, [16]=90591 } },
                { id = 151999, slot = "Hands",   name = "Preysnare Vicegrips",                         sources = { [17]=89869, [14]=89870, [15]=89871, [16]=89872 } },
                { id = 151944, slot = "Head",    name = "Soulhunter's Cowl",                           sources = { [17]=89745, [14]=89746, [15]=89747, [16]=89748 } },
                { id = 152128, slot = "Legs",    name = "Bearmantle Legguards",                        sources = { [17]=90071, [14]=90072, [15]=90073, [16]=90074 }, classes = { 11 } },
                { id = 152116, slot = "Legs",    name = "Dreadwake Legplates",                         sources = { [17]=90023, [14]=90024, [15]=90025, [16]=90026 }, classes = { 6 } },
                { id = 152122, slot = "Legs",    name = "Felreaper Leggings",                          sources = { [17]=90047, [14]=90048, [15]=90049, [16]=90050 }, classes = { 12 } },
                { id = 152157, slot = "Legs",    name = "Gilded Seraph's Leggings",                    sources = { [17]=90187, [14]=90188, [15]=90189, [16]=90190 }, classes = { 5 } },
                { id = 152175, slot = "Legs",    name = "Grim Inquisitor's Leggings",                  sources = { [17]=90259, [14]=90260, [15]=90261, [16]=90262 }, classes = { 9 } },
                { id = 152182, slot = "Legs",    name = "Juggernaut Legplates",                        sources = { [17]=90287, [14]=90288, [15]=90289, [16]=90290 }, classes = { 1 } },
                { id = 152146, slot = "Legs",    name = "Leggings of Chi-Ji",                          sources = { [17]=90143, [14]=90144, [15]=90145, [16]=90146 }, classes = { 10 } },
                { id = 152170, slot = "Legs",    name = "Leggings of Venerated Spirits",               sources = { [17]=90239, [14]=90240, [15]=90241, [16]=90242 }, classes = { 7 } },
                { id = 152152, slot = "Legs",    name = "Light's Vanguard Legplates",                  sources = { [17]=90167, [14]=90168, [15]=90169, [16]=90170 }, classes = { 2 } },
                { id = 152164, slot = "Legs",    name = "Pants of the Dashing Scoundrel",              sources = { [17]=90215, [14]=90216, [15]=90217, [16]=90218 }, classes = { 4 } },
                { id = 152139, slot = "Legs",    name = "Runebound Leggings",                          sources = { [17]=90115, [14]=90116, [15]=90117, [16]=90118 }, classes = { 8 } },
                { id = 152134, slot = "Legs",    name = "Serpentstalker Legguards",                    sources = { [17]=90095, [14]=90096, [15]=90097, [16]=90098 }, classes = { 3 } },
                { id = 152416, slot = "Shoulder",name = "Shoulderguards of Indomitable Purpose",       sources = { [17]=90508, [14]=90509, [15]=90510, [16]=90511 } },
                { id = 151989, slot = "Shoulder",name = "Spaulders of the Relentless Tracker",         sources = { [17]=89829, [14]=89830, [15]=89831, [16]=89832 } },
            },
        },
        {
            index              = 7,
            name               = "Kin'garoth",
            journalEncounterID = 2004,
            aliases            = {},
            achievements       = {
                { id = 12030, name = "The World Revolves Around Me", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 151948, slot = "Chest",   name = "Magma-Spattered Smock",                       sources = { [17]=89761, [14]=89762, [15]=89763, [16]=89764 } },
                { id = 152412, slot = "Feet",    name = "Depraved Machinist's Footpads",               sources = { [17]=90504, [14]=90505, [15]=90506, [16]=90507 } },
                { id = 152126, slot = "Hands",   name = "Bearmantle Paws",                             sources = { [17]=90063, [14]=90064, [15]=90065, [16]=90066 }, classes = { 11 } },
                { id = 152114, slot = "Hands",   name = "Dreadwake Gauntlets",                         sources = { [17]=90015, [14]=90016, [15]=90017, [16]=90018 }, classes = { 6 } },
                { id = 152120, slot = "Hands",   name = "Felreaper Gloves",                            sources = { [17]=90039, [14]=90040, [15]=90041, [16]=90042 }, classes = { 12 } },
                { id = 152155, slot = "Hands",   name = "Gilded Seraph's Handwraps",                   sources = { [17]=90179, [14]=90180, [15]=90181, [16]=90182 }, classes = { 5 } },
                { id = 152168, slot = "Hands",   name = "Gloves of Venerated Spirits",                 sources = { [17]=90231, [14]=90232, [15]=90233, [16]=90234 }, classes = { 7 } },
                { id = 152162, slot = "Hands",   name = "Gloves of the Dashing Scoundrel",             sources = { [17]=90207, [14]=90208, [15]=90209, [16]=90210 }, classes = { 4 } },
                { id = 152173, slot = "Hands",   name = "Grim Inquisitor's Gloves",                    sources = { [17]=90251, [14]=90252, [15]=90253, [16]=90254 }, classes = { 9 } },
                { id = 152144, slot = "Hands",   name = "Grips of Chi-Ji",                             sources = { [17]=90135, [14]=90136, [15]=90137, [16]=90138 }, classes = { 10 } },
                { id = 152180, slot = "Hands",   name = "Juggernaut Gauntlets",                        sources = { [17]=90279, [14]=90280, [15]=90281, [16]=90282 }, classes = { 1 } },
                { id = 152150, slot = "Hands",   name = "Light's Vanguard Gauntlets",                  sources = { [17]=90159, [14]=90160, [15]=90161, [16]=90162 }, classes = { 2 } },
                { id = 152137, slot = "Hands",   name = "Runebound Gloves",                            sources = { [17]=90107, [14]=90108, [15]=90109, [16]=90110 }, classes = { 8 } },
                { id = 152132, slot = "Hands",   name = "Serpentstalker Grips",                        sources = { [17]=90087, [14]=90088, [15]=90089, [16]=90090 }, classes = { 3 } },
                { id = 152014, slot = "Head",    name = "Titan-Subjugator's Visage",                   sources = { [17]=89929, [14]=89930, [15]=89931, [16]=89932 } },
                { id = 152280, slot = "Wrist",   name = "Scalding Shatterguards",                      sources = { [17]=90339, [14]=90340, [15]=90341, [16]=90342 } },
            },
        },
        {
            index              = 8,
            name               = "Varimathras",
            journalEncounterID = 1983,
            aliases            = {},
            achievements       = {
                { id = 11948, name = "Together We Stand", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 151995, slot = "Chest",   name = "Robes of the Forsaken Dreadlord",             sources = { [17]=89853, [14]=89854, [15]=89855, [16]=89856 } },
                { id = 151979, slot = "Chest",   name = "Vest of Unfathomable Anguish",                sources = { [17]=89789, [14]=89790, [15]=89791, [16]=89792 } },
                { id = 151997, slot = "Feet",    name = "Nathrezim Shade-Walkers",                     sources = { [17]=89861, [14]=89862, [15]=89863, [16]=89864 } },
                { id = 152015, slot = "Legs",    name = "Greaves of Mercurial Allegiance",             sources = { [17]=89933, [14]=89934, [15]=89935, [16]=89936 } },
                { id = 151991, slot = "Waist",   name = "Belt of Fractured Sanity",                    sources = { [17]=89837, [14]=89838, [15]=89839, [16]=89840 } },
                { id = 151942, slot = "Waist",   name = "Cord of Surging Hysteria",                    sources = { [17]=89737, [14]=89738, [15]=89739, [16]=89740 } },
                { id = 151954, slot = "Wrist",   name = "Blood-Drenched Bindings",                     sources = { [17]=89785, [14]=89786, [15]=89787, [16]=89788 } },
                { id = 152281, slot = "Wrist",   name = "Varimathras' Shattered Manacles",             sources = { [17]=90343, [14]=90344, [15]=90345, [16]=90346 } },
            },
        },
        {
            index              = 9,
            name               = "The Coven of Shivarra",
            journalEncounterID = 1986,
            aliases            = {},
            achievements       = {
                { id = 12046, name = "Remember the Titans", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 152010, slot = "Feet",    name = "Burning Coven Sabatons",                      sources = { [17]=89913, [14]=89914, [15]=89915, [16]=89916 } },
                { id = 151984, slot = "Hands",   name = "Lurid Grips of the Obscene",                  sources = { [17]=89809, [14]=89810, [15]=89811, [16]=89812 } },
                { id = 151946, slot = "Legs",    name = "Fervent Twilight Legwraps",                   sources = { [17]=89753, [14]=89754, [15]=89755, [16]=89756 } },
                { id = 152003, slot = "Legs",    name = "Legguards of Numbing Gloom",                  sources = { [17]=89885, [14]=89886, [15]=89887, [16]=89888 } },
                { id = 152129, slot = "Shoulder",name = "Bearmantle Shoulders",                        sources = { [17]=90075, [14]=90076, [15]=90077, [16]=90078 }, classes = { 11 } },
                { id = 152117, slot = "Shoulder",name = "Dreadwake Pauldrons",                         sources = { [17]=90027, [14]=90028, [15]=90029, [16]=90030 }, classes = { 6 } },
                { id = 152123, slot = "Shoulder",name = "Felreaper Spaulders",                         sources = { [17]=90051, [14]=90052, [15]=90053, [16]=90054 }, classes = { 12 } },
                { id = 152159, slot = "Shoulder",name = "Gilded Seraph's Amice",                       sources = { [17]=90195, [14]=90196, [15]=90197, [16]=90198 }, classes = { 5 } },
                { id = 152177, slot = "Shoulder",name = "Grim Inquisitor's Shoulderguards",            sources = { [17]=90267, [14]=90268, [15]=90269, [16]=90270 }, classes = { 9 } },
                { id = 152183, slot = "Shoulder",name = "Juggernaut Pauldrons",                        sources = { [17]=90291, [14]=90292, [15]=90293, [16]=90294 }, classes = { 1 } },
                { id = 152153, slot = "Shoulder",name = "Light's Vanguard Shoulderplates",             sources = { [17]=90171, [14]=90172, [15]=90173, [16]=90174 }, classes = { 2 } },
                { id = 152147, slot = "Shoulder",name = "Meditation Spheres of Chi-Ji",                sources = { [17]=90147, [14]=90148, [15]=90149, [16]=90150 }, classes = { 10 } },
                { id = 152171, slot = "Shoulder",name = "Pauldrons of Venerated Spirits",              sources = { [17]=90243, [14]=90244, [15]=90245, [16]=90246 }, classes = { 7 } },
                { id = 152141, slot = "Shoulder",name = "Runebound Mantle",                            sources = { [17]=90123, [14]=90124, [15]=90125, [16]=90126 }, classes = { 8 } },
                { id = 152135, slot = "Shoulder",name = "Serpentstalker Mantle",                       sources = { [17]=90099, [14]=90100, [15]=90101, [16]=90102 }, classes = { 3 } },
                { id = 152165, slot = "Shoulder",name = "Shoulderpads of the Dashing Scoundrel",       sources = { [17]=90219, [14]=90220, [15]=90221, [16]=90222 }, classes = { 4 } },
                { id = 152414, slot = "Wrist",   name = "Bracers of Wanton Morality",                  sources = { [17]=90500, [14]=90501, [15]=90502, [16]=90503 } },
            },
        },
        {
            index              = 10,
            name               = "Aggramar",
            journalEncounterID = 1984,
            aliases            = {},
            achievements       = {
                { id = 11915, name = "Don't Sweat the Technique", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 152062, slot = "Back",    name = "Greatcloak of the Dark Pantheon",             sources = { [17]=90977, [14]=89969, [15]=90978, [16]=90979 } },
                { id = 152018, slot = "Chest",   name = "Breastplate of Molten Rebirth",               sources = { [17]=89945, [14]=89946, [15]=89947, [16]=89948 } },
                { id = 152684, slot = "Feet",    name = "Greatboots of the Searing Tempest",           sources = { [17]=90580, [14]=90581, [15]=90582, [16]=90583 } },
                { id = 151940, slot = "Feet",    name = "Sandals of the Reborn Colossus",              sources = { [17]=89729, [14]=89730, [15]=89731, [16]=89732 } },
                { id = 152127, slot = "Head",    name = "Bearmantle Headdress",                        sources = { [17]=90067, [14]=90068, [15]=90069, [16]=90070 }, classes = { 11 } },
                { id = 152163, slot = "Head",    name = "Cavalier Hat of the Dashing Scoundrel",       sources = { [17]=90211, [14]=90212, [15]=90213, [16]=90214 }, classes = { 4 } },
                { id = 152145, slot = "Head",    name = "Douli of Chi-Ji",                             sources = { [17]=90139, [14]=90140, [15]=90141, [16]=90142 }, classes = { 10 } },
                { id = 152115, slot = "Head",    name = "Dreadwake Helm",                              sources = { [17]=90019, [14]=90020, [15]=90021, [16]=90022 }, classes = { 6 } },
                { id = 152121, slot = "Head",    name = "Felreaper Hood",                              sources = { [17]=90043, [14]=90044, [15]=90045, [16]=90046 }, classes = { 12 } },
                { id = 152156, slot = "Head",    name = "Gilded Seraph's Crown",                       sources = { [17]=90183, [14]=90184, [15]=90185, [16]=90186 }, classes = { 5 } },
                { id = 152174, slot = "Head",    name = "Grim Inquisitor's Death Mask",                sources = { [17]=90255, [14]=90256, [15]=90257, [16]=90258 }, classes = { 9 } },
                { id = 152169, slot = "Head",    name = "Headdress of Venerated Spirits",              sources = { [17]=90235, [14]=90236, [15]=90237, [16]=90238 }, classes = { 7 } },
                { id = 152181, slot = "Head",    name = "Juggernaut Helm",                             sources = { [17]=90283, [14]=90284, [15]=90285, [16]=90286 }, classes = { 1 } },
                { id = 152151, slot = "Head",    name = "Light's Vanguard Helm",                       sources = { [17]=90163, [14]=90164, [15]=90165, [16]=90166 }, classes = { 2 } },
                { id = 152138, slot = "Head",    name = "Runebound Collar",                            sources = { [17]=90111, [14]=90112, [15]=90113, [16]=90114 }, classes = { 8 } },
                { id = 152133, slot = "Head",    name = "Serpentstalker Helmet",                       sources = { [17]=90091, [14]=90092, [15]=90093, [16]=90094 }, classes = { 3 } },
                { id = 152282, slot = "Legs",    name = "Caustic Titanspite Legguards",                sources = { [17]=90347, [14]=90348, [15]=90349, [16]=90350 } },
                { id = 151950, slot = "Shoulder",name = "Fallen Avenger's Amice",                      sources = { [17]=89769, [14]=89770, [15]=89771, [16]=89772 } },
                -- Taeshalach: 2H sword cosmetic appearance. Not exposed by
                -- the Encounter Journal. One sourceID across all four
                -- difficulties (binary shape, like the Fyr'alath legendary
                -- pattern).
                { id = 152094, slot = "Two-Hand",name = "Taeshalach",                                  sources = { [17]=90006, [14]=90006, [15]=90006, [16]=90006 } },
                { id = 152022, slot = "Waist",   name = "Grond-Father Girdle",                         sources = { [17]=89961, [14]=89962, [15]=89963, [16]=89964 } },
                { id = 152683, slot = "Waist",   name = "World-Ravager Waistguard",                    sources = { [17]=90576, [14]=90577, [15]=90578, [16]=90579 } },
            },
        },
        {
            index              = 11,
            name               = "Argus the Unmaker",
            journalEncounterID = 2031,
            aliases            = {},
            achievements       = {
                { id = 12257, name = "Stardust Crusaders", meta = true, soloable = "no" },
            },
            loot = {
                { id = 152679, slot = "Chest",   name = "Gambeson of Sargeras' Corruption",            sources = { [17]=90560, [14]=90561, [15]=90562, [16]=90563 } },
                { id = 151982, slot = "Chest",   name = "Vest of Waning Life",                         sources = { [17]=89801, [14]=89802, [15]=89803, [16]=89804 } },
                { id = 152680, slot = "Hands",   name = "Handwraps of Inevitable Doom",                sources = { [17]=90564, [14]=90565, [15]=90566, [16]=90567 } },
                { id = 152686, slot = "Hands",   name = "Nascent Deathbringer's Clutches",             sources = { [17]=90584, [14]=90585, [15]=90586, [16]=90587 } },
                { id = 152423, slot = "Head",    name = "Helm of the Awakened Soul",                   sources = { [17]=90512, [14]=90513, [15]=90514, [16]=90515 } },
                { id = 152016, slot = "Legs",    name = "Cosmos-Culling Legplates",                    sources = { [17]=89937, [14]=89938, [15]=89939, [16]=89940 } },
                { id = 152005, slot = "Shoulder",name = "Pauldrons of Colossal Burden",                sources = { [17]=89893, [14]=89894, [15]=89895, [16]=89896 } },
                -- Scythe of the Unmaker: 2H polearm cosmetic. Two distinct
                -- appearances drop from Argus -- "Blue" on every difficulty
                -- and a "Red" Mythic-only variant added in 7.3.2. Neither
                -- is exposed by the Encounter Journal. Each appearance is
                -- one sourceID cloned across its difficulty buckets (binary
                -- shape). Red is Mythic-only in-game but encoded here as
                -- binary (cloned across all 4 buckets) so the renderer
                -- treats it the same as Blue -- the appearance-collection
                -- check via GetAllAppearanceSources resolves correctly
                -- regardless of which bucket we read.
                { id = 153115, slot = "Two-Hand",name = "Scythe of the Unmaker (Blue)",                sources = { [17]=90755, [14]=90755, [15]=90755, [16]=90755 } },
                { id = 155880, slot = "Two-Hand",name = "Scythe of the Unmaker (Red)",                 sources = { [17]=92527, [14]=92527, [15]=92527, [16]=92527 } },
                { id = 151986, slot = "Waist",   name = "Death-Enveloping Cincture",                   sources = { [17]=89817, [14]=89818, [15]=89819, [16]=89820 } },
            },
            specialLoot = {
                { id = 152789, kind = "mount", name = "Shackled Ur'zul", mythicOnly = true },
            },
        },
    },

    lfrWings = {
        -- Wing 1 -- Light's Breach: Garothi Worldbreaker, Felhounds of
        -- Sargeras, Antoran High Command (first three of the standard
        -- order). Notes and routing imported verbatim from standard
        -- steps 1-3.
        [1916] = {
            name   = "Light's Breach",
            bosses = { 1, 2, 3 },
            lockoutBits = { [1] = 8, [2] = 6, [3] = 4 },
            routing = {
                -- 1. Garothi Worldbreaker
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 1,
                    title     = "Garothi Worldbreaker",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 909 },
                            mapID   = 909,
                            kind    = "path",
                            note    = "After zoning in, follow the linear path to find the first boss, ^Garothi Worldbreaker^.",
                            minNote = "Path to Boss",
                            points  = {
                                { 0.902, 0.633 },
                                { 0.888, 0.560 },
                                { 0.750, 0.598 },
                            },
                        },
                    },
                },

                -- 2. Felhounds of Sargeras
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 2,
                    title     = "Felhounds of Sargeras",
                    requires  = { 1 },
                    segments  = {
                        {
                            when    = { mapID = 909 },
                            mapID   = 909,
                            kind    = "path",
                            note    = "After defeating ^Garothi Worldbreaker^, continue straight ahead on the path to ^Felhounds of Sargeras^.",
                            minNote = "Ahead to Felhounds",
                            points  = {
                                { 0.706, 0.636 },
                                { 0.569, 0.566 },
                                { 0.464, 0.603 },
                                { 0.431, 0.568 },
                            },
                        },
                    },
                },

                -- 3. Antoran High Command. LFR differs from standard:
                -- the player clicks a Lightforged Teleportation Pad in
                -- the Felhounds room. Seg 1 is the labeled pad POI, seg 2
                -- the short walk to the elevator -- both carry the same
                -- note so it stays visible across the POI and the path.
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 3,
                    title     = "Antoran High Command",
                    requires  = { 2 },
                    segments  = {
                        {
                            when        = { mapID = 909 },
                            mapID       = 909,
                            kind        = "poi",
                            mapLabel    = "Teleportation Pad",
                            mapLabelPos = "below",
                            note        = "After defeating the ^Felhounds of Sargeras^, click the ^Lightforged Teleportation Pad^ in their boss room to be teleported further up the path. After landing, proceed ahead to ride the elevator up.",
                            minNote     = "Click Teleportation Pad",
                            points      = {
                                { 0.431, 0.569 },
                            },
                        },
                        {
                            when    = { mapID = 909 },
                            mapID   = 909,
                            kind    = "path",
                            note    = "After defeating the ^Felhounds of Sargeras^, click the ^Lightforged Teleportation Pad^ in their boss room to be teleported further up the path. After landing, proceed ahead to ride the elevator up.",
                            minNote = "Click Teleportation Pad",
                            points  = {
                                { 0.351, 0.403 },
                                { 0.190, 0.226 },
                            },
                        },
                        {
                            when    = { mapID = 910 },
                            mapID   = 910,
                            kind    = "path",
                            note    = "From the top of the elevator, proceed ahead up the ramp to find the ^Antoran High Command^.",
                            minNote = "Ahead to AHC",
                            points  = {
                                { 0.680, 0.759 },
                                { 0.588, 0.787 },
                                { 0.547, 0.609 },
                                { 0.434, 0.487 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 2 -- Forbidden Descent: Eonar the Life-Binder, Portal
        -- Keeper Hasabel, Imonar the Soulhunter (LFR order -- LFR forces
        -- Eonar first). LFR drops the player on mapID 911; Eonar's entry
        -- is an LFR-specific walk to the Elunaria portal, then the
        -- standard 912/913 legs to the orb.
        [1915] = {
            name   = "Forbidden Descent",
            bosses = { 5, 4, 6 },
            lockoutBits = { [5] = 7, [4] = 2, [6] = 9 },
            routing = {
                -- 5. Eonar the Life-Binder (LFR-specific entry, then
                -- standard 912/913 legs)
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 5,
                    title     = "Eonar the Life-Binder",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 911 },
                            mapID   = 911,
                            kind    = "path",
                            note    = "After zoning in, enter the room on the left and enter the portal at the map exit labeled ^Elunaria^.",
                            minNote = "Portal to Elunaria",
                            points  = {
                                { 0.781, 0.514 },
                                { 0.757, 0.558 },
                                { 0.675, 0.557 },
                                { 0.671, 0.677 },
                            },
                        },
                        {
                            when    = { mapID = 912 },
                            mapID   = 912,
                            kind    = "path",
                            note    = "After taking the portal, follow the long, linear path towards the next map exit labeled ^Elarian Sanctuary^.",
                            minNote = "Follow Path Ahead",
                            points  = {
                                { 0.603, 0.853 },
                                { 0.644, 0.707 },
                                { 0.629, 0.601 },
                                { 0.311, 0.233 },
                            },
                        },
                        {
                            when    = { mapID = 913 },
                            mapID   = 913,
                            kind    = "path",
                            note    = "Once you enter the ^Elarian Sanctuary^, approach the ^Essence of Eonar^ (blue floating orb), and interact with it to begin the encounter for ^Eonar the Life-Binder^.",
                            minNote = "Click Essence of Eonar",
                            points  = {
                                { 0.731, 0.594 },
                                { 0.596, 0.409 },
                                { 0.545, 0.442 },
                                { 0.501, 0.421 },
                                { 0.424, 0.551 },
                            },
                        },
                    },
                },

                -- 4. Portal Keeper Hasabel. Step 1 is the post-Eonar
                -- "click the Essence of Eonar" POI (imported from the
                -- standard Imonar approach), which sends the player back
                -- to Antorus.
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 4,
                    title     = "Portal Keeper Hasabel",
                    requires  = { 5 },
                    segments  = {
                        {
                            when    = { mapID = 913, subZone = "Elarian Sanctuary" },
                            mapID   = 913,
                            kind    = "poi",
                            poiSize = 35,
                            mapLabel = "Essence of Eonar",
                            note    = "Talk to the ^Essence of Eonar^ to be sent back to Antorus.",
                            minNote = "Talk to Essence",
                            points  = {
                                { 0.376, 0.633 },
                            },
                        },
                        {
                            when    = { mapID = 911 },
                            mapID   = 911,
                            kind    = "path",
                            note    = "After arriving back in Antorus, follow the path to the left to reach ^Portal Keeper Hasabel^.",
                            minNote = "Path to Hasabel",
                            points  = {
                                { 0.673, 0.623 },
                                { 0.672, 0.579 },
                                { 0.590, 0.512 },
                                { 0.459, 0.511 },
                            },
                        },
                    },
                },

                -- 6. Imonar the Soulhunter. Seg 1 is the LFR-specific
                -- return to the Light's Breach portal.
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 6,
                    title     = "Imonar the Soulhunter",
                    requires  = { 4 },
                    segments  = {
                        {
                            when    = { mapID = 911 },
                            mapID   = 911,
                            kind    = "path",
                            note    = "After killing ^Portal Keeper Hasabel^, return to the portal marked on the map as ^Light's Breach^.",
                            minNote = "Light's Breach Portal",
                            points  = {
                                { 0.494, 0.513 },
                                { 0.603, 0.509 },
                                { 0.638, 0.558 },
                                { 0.760, 0.564 },
                                { 0.785, 0.527 },
                            },
                        },
                        {
                            when    = { mapID = 909 },
                            mapID   = 909,
                            kind    = "path",
                            note    = "After teleporting, proceed forward and click on one of the ^Lightforged Warframes^ to be flown to the next area.",
                            minNote = "Click Lightforged Warframe",
                            points  = {
                                { 0.551, 0.438 },
                                { 0.569, 0.515 },
                            },
                        },
                        {
                            when    = { mapID = 909, subZone = "Broken Cliffs" },
                            mapID   = 909,
                            kind    = "path",
                            note    = "After landing, move forward and click the ^Lightforged Beacon^ to be teleported to ^The Exhaust^.",
                            minNote = "Beacon to The Exhaust",
                            points  = {
                                { 0.564, 0.648 },
                                { 0.549, 0.699 },
                            },
                        },
                        {
                            when    = { mapID = 914 },
                            mapID   = 914,
                            kind    = "path",
                            note    = "After landing in ^The Exhaust^, move forward to start the encounter with ^Imonar the Soulhunter^.",
                            minNote = "Forward to Imonar",
                            points  = {},
                        },
                    },
                },
            },
        },

        -- Wing 3 -- Hope's End: Kin'garoth, Varimathras, The Coven of
        -- Shivarra (standard order). LFR drops the player on mapID 914,
        -- so Kin'garoth's entry note is an LFR zone-in; Varimathras and
        -- Coven import from standard steps 8 and 9.
        [1914] = {
            name   = "Hope's End",
            bosses = { 7, 8, 9 },
            lockoutBits = { [7] = 10, [8] = 3, [9] = 5 },
            routing = {
                -- 7. Kin'garoth (reworded zone-in entry)
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 7,
                    title     = "Kin'garoth",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 914 },
                            mapID   = 914,
                            kind    = "path",
                            note    = "After zoning in, make your way down the long path to find ^Kin'garoth^.",
                            minNote = "Ahead to Kin'garoth",
                            points  = {
                                { 0.200, 0.500 },
                                { 0.778, 0.502 },
                            },
                        },
                    },
                },

                -- 8. Varimathras (standard segs verbatim)
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 8,
                    title     = "Varimathras",
                    requires  = { 7 },
                    segments  = {
                        {
                            when    = { mapID = 914 },
                            mapID   = 914,
                            kind    = "path",
                            note    = "After killing ^Kin'garoth^, click the ^Lightforged Beacon^ behind you to be teleported to the next area. Select ^The Burning Throne^ from the dialog options.",
                            minNote = "Beacon to Burning Throne",
                            points  = {
                                { 0.778, 0.495 },
                                { 0.687, 0.498 },
                            },
                        },
                        {
                            when    = { mapID = 915 },
                            mapID   = 915,
                            kind    = "path",
                            note    = "After arriving in ^The Burning Throne^, proceed down the path and kill ^Tarneth^ to open the door. Jump in the hole behind the next trash pack.",
                            minNote = "Ahead to Hole",
                            points  = {
                                { 0.857, 0.529 },
                                { 0.638, 0.527 },
                                { 0.606, 0.580 },
                                { 0.564, 0.580 },
                                { 0.542, 0.527 },
                                { 0.411, 0.527 },
                            },
                        },
                        {
                            when    = { mapID = 916 },
                            mapID   = 916,
                            kind    = "path",
                            note    = "After jumping in the hole, you will be in ^Chamber of Anguish^. Proceed to the next room to find ^Varimathras^.",
                            minNote = "Ahead to Varimathras",
                            points  = {
                                { 0.692, 0.682 },
                                { 0.605, 0.690 },
                                { 0.537, 0.771 },
                            },
                        },
                    },
                },

                -- 9. The Coven of Shivarra (standard segs verbatim)
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 9,
                    title     = "The Coven of Shivarra",
                    requires  = { 8 },
                    segments  = {
                        {
                            when    = { mapID = 916 },
                            mapID   = 916,
                            kind    = "path",
                            note    = "After defeating ^Varimathras^, take the ascending stairwell out of the room towards ^Temple of Anguish^.",
                            minNote = "Exit via Stairwell",
                            points  = {
                                { 0.516, 0.770 },
                                { 0.515, 0.402 },
                                { 0.327, 0.396 },
                                { 0.326, 0.261 },
                                { 0.501, 0.251 },
                            },
                        },
                        {
                            when    = { mapID = 915 },
                            mapID   = 915,
                            kind    = "path",
                            note    = "After reaching the top of the stairs and opening a door, you will encounter ^The Coven of Shivarra^.",
                            minNote = "Ahead to Coven",
                            points  = {
                                { 0.321, 0.452 },
                                { 0.321, 0.495 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 4 -- Seat of the Pantheon: Aggramar, Argus the Unmaker
        -- (final wing). LFR drops the player on mapID 917 (The World
        -- Soul), so Aggramar's entry is the standard final 917 seg with
        -- an LFR zone-in opener; Argus imports from standard step 11.
        [1913] = {
            name   = "Seat of the Pantheon",
            bosses = { 10, 11 },
            lockoutBits = { [10] = 1, [11] = 11 },
            routing = {
                -- 10. Aggramar (reworded zone-in entry)
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 10,
                    title     = "Aggramar",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 917 },
                            mapID   = 917,
                            kind    = "path",
                            note    = "After zoning in, proceed ahead to engage ^Aggramar^.",
                            minNote = "Ahead to Aggramar",
                            points  = {
                                { 0.718, 0.539 },
                                { 0.639, 0.541 },
                                { 0.621, 0.476 },
                                { 0.562, 0.476 },
                                { 0.533, 0.533 },
                                { 0.269, 0.529 },
                            },
                        },
                    },
                },

                -- 11. Argus the Unmaker (standard segs verbatim)
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 11,
                    title     = "Argus the Unmaker",
                    requires  = { 10 },
                    segments  = {
                        {
                            when    = { mapID = 917 },
                            mapID   = 917,
                            kind    = "poi",
                            poiSize = 35,
                            note    = "After defeating ^Aggramar^, speak to ^Magni Bronzebeard^ and tell him you're ready.",
                            minNote = "Talk to Magni",
                            points  = {
                                { 0.302, 0.554 },
                            },
                        },
                        {
                            when    = { mapID = 918 },
                            mapID    = 918,
                            kind     = "poi",
                            noMarker = true,
                            note     = "You have reached the final boss, ^Argus the Unmaker^. Kill him!",
                            minNote  = "Kill Argus",
                            points   = {
                                { 0.501, 0.574 },
                            },
                        },
                    },
                },
            },
        },
    },

    routing = {
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Garothi Worldbreaker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 909 },
                    mapID   = 909,
                    kind    = "path",
                    note    = "After zoning in, follow the linear path to find the first boss, ^Garothi Worldbreaker^.",
                    minNote = "Path to Boss",
                    points  = {
                        { 0.902, 0.633 },
                        { 0.888, 0.560 },
                        { 0.750, 0.598 },
                    },
                },
            },
        },
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Felhounds of Sargeras",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 909 },
                    mapID   = 909,
                    kind    = "path",
                    note    = "After defeating ^Garothi Worldbreaker^, continue straight ahead on the path to ^Felhounds of Sargeras^.",
                    minNote = "Ahead to Felhounds",
                    points  = {
                        { 0.706, 0.636 },
                        { 0.569, 0.566 },
                        { 0.464, 0.603 },
                        { 0.431, 0.568 },
                    },
                },
            },
        },
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Antoran High Command",
            requires  = { 2 },
            segments  = {
                {
                    when    = { mapID = 909 },
                    mapID   = 909,
                    kind    = "path",
                    note    = "After defeating ^Felhounds of Sargeras^, backtrack towards the closest intersection and keep to the left. Kill a trash pack to spawn a ^Lightforged Teleportation Pad^. Use it to cross the chasm, then proceed ahead to ride an elevator up.",
                    minNote = "Path to Elevator",
                    points  = {
                        { 0.431, 0.569 },
                        { 0.459, 0.602 },
                        { 0.498, 0.591 },
                        { 0.497, 0.546 },
                        { 0.440, 0.492 },
                        { 0.359, 0.412 },
                        { 0.182, 0.217 },
                    },
                },
                {
                    when    = { mapID = 910 },
                    mapID   = 910,
                    kind    = "path",
                    note    = "From the top of the elevator, proceed ahead up the ramp to find the ^Antoran High Command^.",
                    minNote = "Ahead to AHC",
                    points  = {
                        { 0.680, 0.759 },
                        { 0.588, 0.787 },
                        { 0.547, 0.609 },
                        { 0.434, 0.487 },
                    },
                },
            },
        },
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Portal Keeper Hasabel",
            requires  = { 3 },
            segments  = {
                {
                    when         = { mapID = 910 },
                    mapID        = 910,
                    kind         = "path",
                    endpointKind = "skull",
                    note    = "After killing ^Antoran High Command^, kill yourself by jumping down the elevator hole to save time getting to the next boss.",
                    minNote = "Suicide in Elevator",
                    points  = {
                        { 0.436, 0.491 },
                        { 0.547, 0.608 },
                        { 0.575, 0.785 },
                        { 0.677, 0.769 },
                        { 0.637, 0.713 },
                    },
                },
                {
                    when    = { mapID = 909 },
                    mapID   = 909,
                    kind    = "path",
                    note    = "After spawning, cross the chasm using the ^Lightforged Teleport Pod^. Stay to the left when you reach the intersection, and follow the path to interact with a ^Portal^.",
                    minNote = "Path to Portal",
                    points  = {
                        { 0.362, 0.415 },
                        { 0.441, 0.496 },
                        { 0.498, 0.547 },
                        { 0.561, 0.515 },
                        { 0.548, 0.407 },
                    },
                },
                {
                    when    = { mapID = 911 },
                    mapID   = 911,
                    kind    = "path",
                    note    = "After taking the teleport, follow the path to reach ^Portal Keeper Hasabel^.",
                    minNote = "Path to Hasabel",
                    points  = {
                        { 0.763, 0.510 },
                        { 0.759, 0.557 },
                        { 0.634, 0.557 },
                        { 0.596, 0.511 },
                        { 0.462, 0.511 },
                    },
                },
            },
        },
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Eonar the Life-Binder",
            requires  = { 4 },
            segments  = {
                {
                    when    = { mapID = 911 },
                    mapID   = 911,
                    kind    = "path",
                    note    = "After defeating ^Portal Keeper Hasabel^, leave the boss room and stay to the right to find the map exit labeled ^Elunaria^. Click the portal.",
                    minNote = "Elunaria Portal",
                    points  = {
                        { 0.467, 0.511 },
                        { 0.614, 0.511 },
                        { 0.671, 0.589 },
                        { 0.672, 0.670 },
                    },
                },
                {
                    when    = { mapID = 912 },
                    mapID   = 912,
                    kind    = "path",
                    note    = "After taking the portal, follow the long, linear path towards the next map exit labeled ^Elarian Sanctuary^.",
                    minNote = "Follow Path Ahead",
                    points  = {
                        { 0.603, 0.853 },
                        { 0.644, 0.707 },
                        { 0.629, 0.601 },
                        { 0.311, 0.233 },
                    },
                },
                {
                    when    = { mapID = 913 },
                    mapID   = 913,
                    kind    = "path",
                    note    = "Once you enter the ^Elarian Sanctuary^, approach the ^Essence of Eonar^ (blue floating orb), and interact with it to begin the encounter for ^Eonar the Life-Binder^.",
                    minNote = "Click Essence of Eonar",
                    points  = {
                        { 0.731, 0.594 },
                        { 0.596, 0.409 },
                        { 0.545, 0.442 },
                        { 0.501, 0.421 },
                        { 0.424, 0.551 },
                    },
                },
            },
        },
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Imonar the Soulhunter",
            requires  = { 5 },
            segments  = {
                {
                    when    = { mapID = 913, subZone = "Elarian Sanctuary" },
                    mapID   = 913,
                    kind    = "poi",
                    poiSize = 35,
                    mapLabel = "Essence of Eonar",
                    note    = "Talk to the ^Essence of Eonar^ to be sent back to Antorus.",
                    minNote = "Talk to Essence",
                    points  = {
                        { 0.376, 0.633 },
                    },
                },
                {
                    when    = { mapID = 909 },
                    mapID   = 909,
                    kind    = "path",
                    note    = "Back on Antorus, proceed forward and click on one of the ^Lightforged Warframes^ to be flown to the next area.",
                    minNote = "Click Lightforged Warframe",
                    points  = {
                        { 0.551, 0.438 },
                        { 0.569, 0.515 },
                    },
                },
                {
                    when    = { mapID = 909, subZone = "Broken Cliffs" },
                    mapID   = 909,
                    kind    = "path",
                    note    = "After landing, move forward and click the ^Lightforged Beacon^ to be teleported to ^The Exhaust^.",
                    minNote = "Click Lightforged Beacon",
                    points  = {
                        { 0.564, 0.648 },
                        { 0.549, 0.699 },
                    },
                },
                {
                    when    = { mapID = 914 },
                    mapID   = 914,
                    kind    = "path",
                    note    = "After landing in ^The Exhaust^, move forward to start the encounter with ^Imonar the Soulhunter^.",
                    minNote = "Forward to Imonar",
                    points  = {},
                },
            },
        },
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Kin'garoth",
            requires  = { 6 },
            segments  = {
                {
                    when    = { mapID = 914 },
                    mapID   = 914,
                    kind    = "path",
                    note    = "After killing ^Imonar^, make your way down the long path to find the next boss, ^Kin'garoth^.",
                    minNote = "Ahead to Kin'garoth",
                    points  = {
                        { 0.200, 0.500 },
                        { 0.778, 0.502 },
                    },
                },
            },
        },
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Varimathras",
            requires  = { 7 },
            segments  = {
                {
                    when    = { mapID = 914 },
                    mapID   = 914,
                    kind    = "path",
                    note    = "After killing ^Kin'garoth^, click the ^Lightforged Beacon^ behind you to be teleported to the next area. Select ^The Burning Throne^ from the dialog options.",
                    minNote = "Beacon to Burning Throne",
                    points  = {
                        { 0.778, 0.495 },
                        { 0.687, 0.498 },
                    },
                },
                {
                    when    = { mapID = 915 },
                    mapID   = 915,
                    kind    = "path",
                    note    = "After arriving in ^The Burning Throne^, proceed down the path and kill ^Tarneth^ to open the door. Jump in the hole behind the next trash pack.",
                    minNote = "Ahead to Hole",
                    points  = {
                        { 0.857, 0.529 },
                        { 0.638, 0.527 },
                        { 0.606, 0.580 },
                        { 0.564, 0.580 },
                        { 0.542, 0.527 },
                        { 0.411, 0.527 },
                    },
                },
                {
                    when    = { mapID = 916 },
                    mapID   = 916,
                    kind    = "path",
                    note    = "After jumping in the hole, you will be in ^Chamber of Anguish^. Proceed to the next room to find ^Varimathras^.",
                    minNote = "Ahead to Varimathras",
                    points  = {
                        { 0.692, 0.682 },
                        { 0.605, 0.690 },
                        { 0.537, 0.771 },
                    },
                },
            },
        },
        {
            step      = 9,
            priority  = 1,
            bossIndex = 9,
            title     = "The Coven of Shivarra",
            requires  = { 8 },
            segments  = {
                {
                    when    = { mapID = 916 },
                    mapID   = 916,
                    kind    = "path",
                    note    = "After defeating ^Varimathras^, take the ascending stairwell out of the room towards ^Temple of Anguish^.",
                    minNote = "Exit via Stairwell",
                    points  = {
                        { 0.516, 0.770 },
                        { 0.515, 0.402 },
                        { 0.327, 0.396 },
                        { 0.326, 0.261 },
                        { 0.501, 0.251 },
                    },
                },
                {
                    when    = { mapID = 915 },
                    mapID   = 915,
                    kind    = "path",
                    note    = "After reaching the top of the stairs and opening a door, you will encounter ^The Coven of Shivarra^.",
                    minNote = "Ahead to Coven",
                    points  = {
                        { 0.321, 0.452 },
                        { 0.321, 0.495 },
                    },
                },
            },
        },
        {
            step      = 10,
            priority  = 1,
            bossIndex = 10,
            title     = "Aggramar",
            requires  = { 9 },
            segments  = {
                {
                    when    = { mapID = 915 },
                    mapID   = 915,
                    kind    = "path",
                    note    = "After defeating ^The Coven of Shivarra^, take some stairs out of the area and make your way west towards the map exit labeled ^The World Soul^.",
                    minNote = "West Exit",
                    points  = {
                        { 0.322, 0.563 },
                        { 0.321, 0.646 },
                        { 0.267, 0.646 },
                        { 0.225, 0.528 },
                        { 0.160, 0.528 },
                    },
                },
                {
                    when    = { mapID = 917 },
                    mapID   = 917,
                    kind    = "path",
                    note    = "Proceed ahead to engage ^Aggramar^.",
                    minNote = "Ahead to Aggramar",
                    points  = {
                        { 0.718, 0.539 },
                        { 0.639, 0.541 },
                        { 0.621, 0.476 },
                        { 0.562, 0.476 },
                        { 0.533, 0.533 },
                        { 0.269, 0.529 },
                    },
                },
            },
        },
        {
            step      = 11,
            priority  = 1,
            bossIndex = 11,
            title     = "Argus the Unmaker",
            requires  = { 10 },
            segments  = {
                {
                    when    = { mapID = 917 },
                    mapID   = 917,
                    kind    = "poi",
                    poiSize = 35,
                    note    = "After defeating ^Aggramar^, speak to ^Magni Bronzebeard^ and tell him you're ready.",
                    minNote = "Talk to Magni",
                    points  = {
                        { 0.302, 0.554 },
                    },
                },
                {
                    when    = { mapID = 918 },
                    mapID    = 918,
                    kind     = "poi",
                    noMarker = true,
                    note     = "You have reached the final boss, ^Argus the Unmaker^. Kill him!",
                    minNote  = "Kill Argus",
                    points   = {
                        { 0.501, 0.574 },
                    },
                },
            },
        },
    },

    skipToBoss = "Aggramar",


    skipRoute = {

        -- 1. Garothi Worldbreaker (same as standard run).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Garothi Worldbreaker",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 909 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path to find the first boss, ^Garothi Worldbreaker^.",
                    minNote = "Ahead to Boss",
                    points  = {
                        { 0.902, 0.633 },
                        { 0.888, 0.560 },
                        { 0.750, 0.598 },
                    },
                },
            },
        },

        -- 2. Aggramar, reached from the post-Garothi teleporter via The Burning
        --    Throne (skips bosses 2-9). Requires the Heart of Argus unlock.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 10,
            title     = "Aggramar",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 909, subZone = "Edge of Discord" },
                    kind    = "path",
                    note    = "After defeating ^Garothi Worldbreaker^, cross the bridge and take a left to locate a teleporter. Select ^The Burning Throne^ to skip ahead to ^Aggramar^.",
                    minNote = "Path to Teleporter",
                    points  = {
                        { 0.706, 0.637 },
                        { 0.569, 0.565 },
                        { 0.528, 0.582 },
                        { 0.537, 0.631 },
                        { 0.554, 0.634 },
                        { 0.560, 0.652 },
                        { 0.557, 0.677 },
                    },
                },
                {
                    when    = { mapID = 915, subZone = "The Burning Throne" },
                    kind    = "path",
                    note    = "After arriving in ^The Burning Throne^, proceed down the long path and kill ^Tarneth^ to open the door. Continue west to the map exit labeled ^The World Soul^.",
                    minNote = "West to World Soul",
                    points  = {
                        { 0.848, 0.528 },
                        { 0.652, 0.526 },
                        { 0.605, 0.581 },
                        { 0.564, 0.578 },
                        { 0.540, 0.523 },
                        { 0.418, 0.525 },
                        { 0.360, 0.651 },
                        { 0.274, 0.652 },
                        { 0.224, 0.526 },
                        { 0.159, 0.526 },
                    },
                },
                {
                    when    = { mapID = 917 },
                    kind    = "path",
                    note    = "Proceed ahead to engage ^Aggramar^.",
                    minNote = "Ahead to Aggramar",
                    points  = {
                        { 0.718, 0.539 },
                        { 0.639, 0.541 },
                        { 0.621, 0.476 },
                        { 0.562, 0.476 },
                        { 0.533, 0.533 },
                        { 0.269, 0.529 },
                    },
                },
            },
        },

        -- 3. Argus the Unmaker (same as standard run).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 11,
            title     = "Argus the Unmaker",
            requires  = { 10 },
            segments  = {
                {
                    when    = { mapID = 917 },
                    kind    = "poi",
                    note    = "After defeating ^Aggramar^, speak to ^Magni Bronzebeard^ and tell him you're ready.",
                    minNote = "Talk to Magni",
                    points  = {
                        { 0.302, 0.554 },
                    },
                },
                {
                    when     = { mapID = 918 },
                    kind     = "poi",
                    note     = "You have reached the final boss, ^Argus the Unmaker^. Kill him!",
                    minNote  = "Kill Argus",
                    points   = {
                        { 0.501, 0.574 },
                    },
                },
            },
        },

    },

}
