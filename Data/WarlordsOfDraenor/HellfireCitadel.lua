-------------------------------------------------------------------------------
-- RetroRuns Data -- Hellfire Citadel
-- Warlords of Draenor, Patch 6.2.0  |  instanceID: 1448  |  journalInstanceID: 669
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1448] = {
    instanceID        = 1448,
    journalInstanceID = 669,
    name              = "Hellfire Citadel",
    expansion         = "Warlords of Draenor",
    patch             = "6.2.0",

    exitNote = "Take one of the nearby Kirin Tor portals to be teleported to the raid entrance.",

    entrance = {
        mapID = 534,
        x     = 0.4556,
        y     = 0.5361,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [661] = "Hellfire Citadel",
        [662] = "Hellfire Antechamber",
        [663] = "Hellfire Passage",
        [664] = "Pits of Mannoroth",
        [665] = "Court of Blood",
        [666] = "Grommash's Torment",
        [667] = "The Felborne Breach",
        [668] = "Halls of the Sargerei",
        [669] = "Destructor's Rise",
        [670] = "The Black Gate",
    },

    -- WoD-era raids have two separate boss loot tables: an LFR pool
    -- (unique appearances that drop ONLY at Raid Finder difficulty)
    -- and an N/H/M pool (the per-difficulty recolors that drop at
    -- Normal, Heroic, and Mythic). The two pools share no items.
    splitLootTables = true,

    -- Two parallel skip chains, each with the standard
    -- normal/heroic/mythic per-difficulty quest cascade.
    --   * Well of Souls (Gorefiend Soul Remnants): collect 4 from
    --     Gorefiend at the matching difficulty; enables skipping
    --     through the Upper Citadel directly to Shadow-Lord Iskar.
    --   * The Fel Spire (Mannoroth Fel Essences): collect 4 from
    --     Mannoroth at the matching difficulty; enables skipping
    --     through Destructor's Rise directly to Mannoroth.
    skipQuests = {
        { label = "Shadow-Lord Iskar", normal = 39499, heroic = 39500, mythic = 39501 },
        { label = "Mannoroth",         normal = 39502, heroic = 39504, mythic = 39505 },
    },

    -- Surfaced to players via the Skips window's per-row info button.
    skipTrigger = {
        questNames = {
            ["Shadow-Lord Iskar"] = "Well of Souls",
            Mannoroth             = "The Fel Spire",
        },
        details   = "After zoning in, you will find portals to your left/right depending on which skips you've unlocked.\n* Upper Citadel -> ^Shadow-Lord Iskar^\n* Destructor's Rise -> ^Mannoroth^\n\nNote: RetroRuns only has the route built for Mannoroth at this time.",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    gloryMeta = {
        id   = 10149,
        name = "Glory of the Hellfire Raider",
        rewardItemID       = 127140,
        rewardMountSpellID = 186305,
        rewardName         = "Infernal Direwolf",
    },

    bosses = {
        {
            index              = 1,
            name               = "Hellfire Assault",
            journalEncounterID = 1426,
            aliases            = {},
            achievements       = {
                { id = 10026, name = "Nearly Indestructible", meta = true, soloable = "yes" },
            },
            soloTip            = "The goal of the fight is to collect ^Felfire Munitions^ and run them to the ^Hellfire Cannons^. You collect munitions by killing ^Felfire-Imbued Siege Vehicles^ which will come in waves.",
            loot = {
                { id = 124132, slot = "Back",               name = "Forward Observer's Camouflage Cloak",          sources = { [14]=69507, [15]=69508, [16]=69509 } },
                { id = 124136, slot = "Back",               name = "Sparkburnt Welder's Cloak",                    sources = { [14]=69519, [15]=69520, [16]=69521 } },
                { id = 124168, slot = "Chest",              name = "Felgrease-Smudged Robes",                      sources = { [14]=69622, [15]=69624, [16]=69625 } },
                { id = 124183, slot = "Wrist",              name = "Powder-Singed Bracers",                        sources = { [14]=69674, [15]=69676, [16]=69677 } },
                { id = 124270, slot = "Shoulder",           name = "Rangefinder's Spaulders",                      sources = { [14]=69791, [15]=69793, [16]=69794 } },
                { id = 124278, slot = "Wrist",              name = "Gorebound Wristguards",                        sources = { [14]=69820, [15]=69822, [16]=69823 } },
                { id = 124289, slot = "Hands",              name = "Hand Loader Gauntlets",                        sources = { [14]=69861, [15]=69862, [16]=69863 } },
                { id = 124298, slot = "Legs",               name = "Iron Dragoon's Pantaloons",                    sources = { [14]=69892, [15]=69894, [16]=69895 } },
                { id = 124320, slot = "Feet",               name = "Shell-Resistant Stompers",                     sources = { [14]=69972, [15]=69974, [16]=69975 } },
                { id = 124324, slot = "Hands",              name = "Flamebelcher's Insulated Mitts",               sources = { [14]=69988, [15]=69990, [16]=69991 } },
                { id = 124335, slot = "Legs",               name = "Blastproof Legguards",                         sources = { [14]=70026, [15]=70028, [16]=70029 } },
                { id = 124356, slot = "Off-hand",           name = "Smoldercore Bulwark",                          sources = { [14]=70102, [15]=70103, [16]=70104 } },
                { id = 124365, slot = "Weapon",             name = "Blackfuse Company Utility Knife",              sources = { [14]=70129, [15]=70130, [16]=70131 } },
                { id = 124370, slot = "Ranged",             name = "Felfire Munitions Launcher",                   sources = { [14]=70144, [15]=70145, [16]=70146 } },
                { id = 128028, slot = "Chest",              name = "Sooty Felcult Robes",                          sources = { [17]=72874 } },
                { id = 128029, slot = "Wrist",              name = "Manacles of Enforced Labor",                   sources = { [17]=72878 } },
                { id = 128030, slot = "Wrist",              name = "Fel Mechanic's Sparkguard Bracers",            sources = { [17]=72882 } },
                { id = 128031, slot = "Legs",               name = "Siegesmith's Chain Leggings",                  sources = { [17]=72886 } },
                { id = 128050, slot = "Feet",               name = "Engine-Kicking Boots",                         sources = { [17]=72962 } },
                { id = 128071, slot = "Waist",              name = "Blackfuse Company Tool Belt",                  sources = { [17]=73046 } },
                { id = 128073, slot = "Hands",              name = "Ironspike Knuckled Gauntlets",                 sources = { [17]=73054 } },
                { id = 128081, slot = "Head",               name = "Iron Dragoon's Coif",                          sources = { [17]=73086 } },
                { id = 128092, slot = "Weapon",             name = "Wicked Bonecarver's Knife",                    sources = { [17]=73127 } },
                { id = 128098, slot = "Ranged",             name = "Snub-Nosed Iron Rifle",                        sources = { [17]=73139 } },
            },
        },
        {
            index              = 2,
            name               = "Iron Reaver",
            journalEncounterID = 1425,
            aliases            = {},
            achievements       = {
                { id = 10057, name = "Turning the Tide", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 124145, slot = "Back",               name = "Ironthread Greatcloak",                        sources = { [14]=69546, [15]=69547, [16]=69548 } },
                { id = 124148, slot = "Feet",               name = "Pedal-Pushing Sandals",                        sources = { [14]=69555, [15]=69557, [16]=69558 } },
                { id = 124174, slot = "Shoulder",           name = "Pilot's Pauldrons",                            sources = { [14]=69642, [15]=69644, [16]=69645 } },
                { id = 124249, slot = "Feet",               name = "Spiked Irontoe Slippers",                      sources = { [14]=69716, [15]=69718, [16]=69719 } },
                { id = 124253, slot = "Hands",              name = "Insulated Wirer's Gloves",                     sources = { [14]=69732, [15]=69734, [16]=69735 } },
                { id = 124264, slot = "Legs",               name = "Rivet-Studded Leggings",                       sources = { [14]=69770, [15]=69772, [16]=69773 } },
                { id = 124285, slot = "Feet",               name = "Die-Cast Ringmail Sabatons",                   sources = { [14]=69846, [15]=69847, [16]=69848 } },
                { id = 124309, slot = "Waist",              name = "Torch-Brazed Waistguard",                      sources = { [14]=69931, [15]=69933, [16]=69934 } },
                { id = 124315, slot = "Chest",              name = "Stamped Felsteel Chestplate",                  sources = { [14]=69955, [15]=69957, [16]=69958 } },
                { id = 124351, slot = "Wrist",              name = "Hot-Rolled Iron Bracers",                      sources = { [14]=70084, [15]=70086, [16]=70087 } },
                { id = 124354, slot = "Off-hand",           name = "Felforged Aegis",                              sources = { [14]=70096, [15]=70097, [16]=70098 } },
                { id = 124373, slot = "Weapon",             name = "Iron Skullcrusher",                            sources = { [14]=70153, [15]=70154, [16]=70155 } },
                { id = 128033, slot = "Legs",               name = "Assembly Worker's Legguards",                  sources = { [17]=72894 } },
                { id = 128053, slot = "Shoulder",           name = "Liquid-Cooled Mantle",                         sources = { [17]=72974 } },
                { id = 128058, slot = "Wrist",              name = "Roughly Soldered Wristclamps",                 sources = { [17]=72994 } },
                { id = 128060, slot = "Shoulder",           name = "Double-Polished Chain Pauldrons",              sources = { [17]=73002 } },
                { id = 128067, slot = "Wrist",              name = "Pulley Chain Wristwraps",                      sources = { [17]=73030 } },
                { id = 128075, slot = "Feet",               name = "Double-Padded Slippers",                       sources = { [17]=73062 } },
                { id = 128076, slot = "Chest",              name = "Fel-Steamed Leather Tunic",                    sources = { [17]=73066 } },
                { id = 128094, slot = "Weapon",             name = "Spiked Torque Wrench",                         sources = { [17]=73131 } },
                { id = 128102, slot = "Back",               name = "Unfired Ejection Parachute",                   sources = { [17]=73148 } },
                { id = 128105, slot = "Back",               name = "Commander's Seat Cushion Cover",               sources = { [17]=73154 } },
                { id = 128118, slot = "Off-hand",           name = "Demonhorn Buckler",                            sources = { [17]=73159 } },
                { id = 128168, slot = "Feet",               name = "Shrapnel-Studded Boots",                       sources = { [17]=73276 } },
            },
        },
        {
            index              = 3,
            name               = "Kormrok",
            journalEncounterID = 1392,
            aliases            = {},
            achievements       = {
                { id = 10013, name = "Waves Came Crashing Down All Around", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 124139, slot = "Back",               name = "Polymorphic Cloak of Absorption",              sources = { [14]=69528, [15]=69529, [16]=69530 } },
                { id = 124151, slot = "Hands",              name = "Craggy Gloves of Grasping",                    sources = { [14]=69566, [15]=69568, [16]=69569 } },
                { id = 124160, slot = "Head",               name = "Cowl of the Arcanic Conclave",                 sources = { [14]=69597, [15]=69598, [16]=69599 }, classes = { 8 } },
                { id = 124161, slot = "Head",               name = "Pious Cowl",                                   sources = { [14]=69600, [15]=69601, [16]=69602 }, classes = { 5 } },
                { id = 124162, slot = "Head",               name = "Deathrattle Mask",                             sources = { [14]=69603, [15]=69604, [16]=69605 }, classes = { 9 } },
                { id = 124180, slot = "Waist",              name = "Sludge-Soaked Waistband",                      sources = { [14]=69663, [15]=69665, [16]=69666 } },
                { id = 124243, slot = "Chest",              name = "Tunic of Reformative Runes",                   sources = { [14]=69696, [15]=69697, [16]=69698 } },
                { id = 124261, slot = "Head",               name = "Oathclaw Helm",                                sources = { [14]=69761, [15]=69762, [16]=69763 }, classes = { 11 } },
                { id = 124262, slot = "Head",               name = "Mask of the Hurricane's Eye",                  sources = { [14]=69764, [15]=69765, [16]=69766 }, classes = { 10 } },
                { id = 124263, slot = "Head",               name = "Felblade Hood",                                sources = { [14]=69767, [15]=69768, [16]=69769 }, classes = { 4 } },
                { id = 124296, slot = "Head",               name = "Hood of the Savage Hunt",                      sources = { [14]=69886, [15]=69887, [16]=69888 }, classes = { 3 } },
                { id = 124297, slot = "Head",               name = "Crown of the Living Mountain",                 sources = { [14]=69889, [15]=69890, [16]=69891 }, classes = { 7 } },
                { id = 124304, slot = "Shoulder",           name = "Rugged Stoneshaped Pauldrons",                 sources = { [14]=69913, [15]=69915, [16]=69916 } },
                { id = 124332, slot = "Head",               name = "Demongaze Helm",                               sources = { [14]=70017, [15]=70018, [16]=70019 }, classes = { 6 } },
                { id = 124333, slot = "Head",               name = "Helm of the Ceaseless Vigil",                  sources = { [14]=70020, [15]=70021, [16]=70022 }, classes = { 2 } },
                { id = 124334, slot = "Head",               name = "Faceguard of Iron Wrath",                      sources = { [14]=70023, [15]=70024, [16]=70025 }, classes = { 1 } },
                { id = 124341, slot = "Shoulder",           name = "Fel-Inscribed Shoulderplates",                 sources = { [14]=70047, [15]=70049, [16]=70050 } },
                { id = 124358, slot = "Weapon",             name = "Runeaxe of the Breaker",                       sources = { [14]=70108, [15]=70109, [16]=70110 } },
                { id = 124363, slot = "Weapon",             name = "Runic Magnaron Tooth",                         sources = { [14]=70123, [15]=70124, [16]=70125 } },
                { id = 124377, slot = "Two-Hand",           name = "Rune-Infused Spear",                           sources = { [14]=70165, [15]=70166, [16]=70167 } },
                { id = 128056, slot = "Waist",              name = "Industrial Lifting Belt",                      sources = { [17]=72986 } },
                { id = 128057, slot = "Chest",              name = "Chestplate of Potential Energy",               sources = { [17]=72990 } },
                { id = 128059, slot = "Hands",              name = "Goop-Proof Gloves",                            sources = { [17]=72998 } },
                { id = 128064, slot = "Legs",               name = "Sludge-Resistant Waders",                      sources = { [17]=73018 } },
                { id = 128103, slot = "Back",               name = "Sigil-Stitched Drape",                         sources = { [17]=73150 } },
                { id = 128104, slot = "Back",               name = "Splashcover Cloak",                            sources = { [17]=73152 } },
                { id = 128128, slot = "Head",               name = "Felfume Hood",                                 sources = { [17]=73196 } },
                { id = 128130, slot = "Head",               name = "Ironpelt Helm",                                sources = { [17]=73204 } },
                { id = 128132, slot = "Head",               name = "Rancorbite Hood",                              sources = { [17]=73212 } },
                { id = 128134, slot = "Head",               name = "Demonbreaker Helm",                            sources = { [17]=73220 } },
                { id = 139627, slot = "Head",               name = "Ferroleather Hood",                            sources = { [14]=80938, [15]=80939, [16]=80940 }, classes = { 12 } },
            },
        },
        {
            index              = 4,
            name               = "Hellfire High Council",
            journalEncounterID = 1432,
            aliases            = {},
            achievements       = {
                { id = 10054, name = "Don't Fear the Reaper", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 124133, slot = "Back",               name = "Windswept Wanderer's Drape",                   sources = { [14]=69510, [15]=69511, [16]=69512 } },
                { id = 124142, slot = "Back",               name = "Rugged Bloodcaked Drape",                      sources = { [14]=69537, [15]=69538, [16]=69539 } },
                { id = 124163, slot = "Legs",               name = "Dia's Nightmarish Leggings",                   sources = { [14]=69606, [15]=69608, [16]=69609 } },
                { id = 124184, slot = "Wrist",              name = "Cursed Blood Bracers",                         sources = { [14]=69678, [15]=69680, [16]=69681 } },
                { id = 124258, slot = "Head",               name = "Gurtogg's Discarded Hood",                     sources = { [14]=69749, [15]=69751, [16]=69752 } },
                { id = 124271, slot = "Shoulder",           name = "Blood-Tanned Pauldrons",                       sources = { [14]=69795, [15]=69797, [16]=69798 } },
                { id = 124299, slot = "Legs",               name = "Kilt of Self-Reflection",                      sources = { [14]=69896, [15]=69897, [16]=69898 } },
                { id = 124312, slot = "Wrist",              name = "Bloody Berserker's Bracers",                   sources = { [14]=69943, [15]=69945, [16]=69946 } },
                { id = 124336, slot = "Legs",               name = "Acid-Etched Legplates",                        sources = { [14]=70030, [15]=70032, [16]=70033 } },
                { id = 124347, slot = "Waist",              name = "Girdle of Savage Resolve",                     sources = { [14]=70068, [15]=70070, [16]=70071 } },
                { id = 124383, slot = "Weapon",             name = "Mindbender's Flameblade",                      sources = { [14]=70183, [15]=70184, [16]=70185 } },
                { id = 124385, slot = "Weapon",             name = "Blazing Demonhilt Sword",                      sources = { [14]=70189, [15]=70190, [16]=70191 } },
                { id = 124388, slot = "Two-Hand",           name = "Fel-Burning Blade",                            sources = { [14]=70198, [15]=70199, [16]=70200 } },
                { id = 128040, slot = "Feet",               name = "Bladewalk Boots",                              sources = { [17]=72922 } },
                { id = 128061, slot = "Shoulder",           name = "Wailing Woe Pauldrons",                        sources = { [17]=73006 } },
                { id = 128062, slot = "Legs",               name = "Void-Pact Leggings",                           sources = { [17]=73010 } },
                { id = 128065, slot = "Shoulder",           name = "Fel-Crazed Pauldrons",                         sources = { [17]=73022 } },
                { id = 128068, slot = "Waist",              name = "Blade-Chipped Waistguard",                     sources = { [17]=73034 } },
                { id = 128077, slot = "Hands",              name = "Gauntlets of Reckless Assault",                sources = { [17]=73070 } },
                { id = 128089, slot = "Waist",              name = "Sash of Guttural Intonation",                  sources = { [17]=73118 } },
                { id = 128095, slot = "Weapon",             name = "Viscera-Stained Longsword",                    sources = { [17]=73133 } },
                { id = 128097, slot = "Two-Hand",           name = "Rivetspike Cleaver",                           sources = { [17]=73137 } },
                { id = 128100, slot = "Two-Hand",           name = "Spring-Loaded Jawstaff",                       sources = { [17]=73143 } },
                { id = 128191, slot = "Weapon",             name = "Hellfire Mindblade",                           sources = { [17]=73311 } },
            },
        },
        {
            index              = 5,
            name               = "Kilrogg Deadeye",
            journalEncounterID = 1396,
            aliases            = {},
            achievements       = {
                { id = 9972, name = "A Race Against Slime", meta = true, soloable = "yes" },
            },
            specialLoot = {
                { id = 138808, kind = "illusion", name = "Illusion: Mark of the Bleeding Hollow", sourceID = 5384 },
            },
            loot = {
                { id = 124137, slot = "Back",               name = "Shawl of Sanguinary Ritual",                   sources = { [14]=69522, [15]=69523, [16]=69524 } },
                { id = 124152, slot = "Hands",              name = "Velvet Bloodweaver Gloves",                    sources = { [14]=69570, [15]=69572, [16]=69573 } },
                { id = 124169, slot = "Chest",              name = "Ancient Gorestained Wrap",                     sources = { [14]=69626, [15]=69628, [16]=69629 } },
                { id = 124250, slot = "Feet",               name = "Toxicologist's Treated Boots",                 sources = { [14]=69720, [15]=69722, [16]=69723 } },
                { id = 124279, slot = "Wrist",              name = "Bloodcult Bracers",                            sources = { [14]=69824, [15]=69826, [16]=69827 } },
                { id = 124281, slot = "Chest",              name = "Jungle Flayer's Chestguard",                   sources = { [14]=69831, [15]=69833, [16]=69834 } },
                { id = 124305, slot = "Shoulder",           name = "Pauldrons of Rapid Coagulation",               sources = { [14]=69917, [15]=69919, [16]=69920 } },
                { id = 124321, slot = "Feet",               name = "Stompers of Brazen Terror",                    sources = { [14]=69976, [15]=69978, [16]=69979 } },
                { id = 124325, slot = "Hands",              name = "Crimson Throatgrabbers",                       sources = { [14]=69992, [15]=69994, [16]=69995 } },
                { id = 124330, slot = "Head",               name = "Helm of Precognition",                         sources = { [14]=70009, [15]=70011, [16]=70012 } },
                { id = 124364, slot = "Weapon",             name = "Fallen Warlord's Mindcarver",                  sources = { [14]=70126, [15]=70127, [16]=70128 } },
                { id = 124366, slot = "Weapon",             name = "Ruinous Gutripper",                            sources = { [14]=70132, [15]=70133, [16]=70134 } },
                { id = 124379, slot = "Two-Hand",           name = "Bite of the Bleeding Hollow",                  sources = { [14]=70171, [15]=70172, [16]=70173 } },
                { id = 128042, slot = "Hands",              name = "Ribwrencher Gauntlets",                        sources = { [17]=72930 } },
                { id = 128047, slot = "Waist",              name = "Cinch of the Bleeding Hollow",                 sources = { [17]=72950 } },
                { id = 128049, slot = "Shoulder",           name = "Pauldrons of Perceived Depths",                sources = { [17]=72958 } },
                { id = 128070, slot = "Feet",               name = "Boots of Final Salvation",                     sources = { [17]=73042 } },
                { id = 128074, slot = "Head",               name = "Hollowheart Helm",                             sources = { [17]=73058 } },
                { id = 128078, slot = "Chest",              name = "Goresoaked Ritual Robes",                      sources = { [17]=73074 } },
                { id = 128087, slot = "Wrist",              name = "Bloodsurge Bracers",                           sources = { [17]=73110 } },
                { id = 128093, slot = "Weapon",             name = "Demonhorn Spike",                              sources = { [17]=73129 } },
                { id = 128167, slot = "Feet",               name = "Sandals of Sanguine Supplication",             sources = { [17]=73272 } },
                { id = 128192, slot = "Weapon",             name = "Balanced Machete",                             sources = { [17]=73313 } },
            },
        },
        {
            index              = 6,
            name               = "Gorefiend",
            journalEncounterID = 1372,
            aliases            = {},
            achievements       = {
                { id = 9979, name = "Get In My Belly!", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 124140, slot = "Back",               name = "Cloak of Insatiable Greed",                    sources = { [14]=69531, [15]=69532, [16]=69533 } },
                { id = 124146, slot = "Back",               name = "Drape of Gluttony",                            sources = { [14]=69549, [15]=69550, [16]=69551 } },
                { id = 124157, slot = "Head",               name = "Cowl of a Thousand Hungers",                   sources = { [14]=69587, [15]=69588, [16]=69589 } },
                { id = 124165, slot = "Legs",               name = "Pantaloons of the Arcanic Conclave",           sources = { [14]=69613, [15]=69614, [16]=69615 }, classes = { 8 } },
                { id = 124166, slot = "Legs",               name = "Pious Leggings",                               sources = { [14]=69616, [15]=69617, [16]=69618 }, classes = { 5 } },
                { id = 124167, slot = "Legs",               name = "Deathrattle Leggings",                         sources = { [14]=69619, [15]=69620, [16]=69621 }, classes = { 9 } },
                { id = 124205, slot = "Held In Off-hand",   name = "Gibbering Madness",                            sources = { [14]=69690, [15]=69691, [16]=69692 } },
                { id = 124244, slot = "Chest",              name = "Chestguard of Gnawing Desire",                 sources = { [14]=69699, [15]=69701, [16]=69702 } },
                { id = 124267, slot = "Legs",               name = "Oathclaw Leggings",                            sources = { [14]=69782, [15]=69783, [16]=69784 }, classes = { 11 } },
                { id = 124268, slot = "Legs",               name = "Legwraps of the Hurricane's Eye",              sources = { [14]=69785, [15]=69786, [16]=69787 }, classes = { 10 } },
                { id = 124269, slot = "Legs",               name = "Felblade Leggings",                            sources = { [14]=69788, [15]=69789, [16]=69790 }, classes = { 4 } },
                { id = 124290, slot = "Hands",              name = "Mitts of Eternal Famishment",                  sources = { [14]=69864, [15]=69866, [16]=69867 } },
                { id = 124301, slot = "Legs",               name = "Leggings of the Savage Hunt",                  sources = { [14]=69904, [15]=69905, [16]=69906 }, classes = { 3 } },
                { id = 124302, slot = "Legs",               name = "Leggings of the Living Mountain",              sources = { [14]=69907, [15]=69908, [16]=69909 }, classes = { 7 } },
                { id = 124338, slot = "Legs",               name = "Demongaze Legplates",                          sources = { [14]=70038, [15]=70039, [16]=70040 }, classes = { 6 } },
                { id = 124339, slot = "Legs",               name = "Greaves of the Ceaseless Vigil",               sources = { [14]=70041, [15]=70042, [16]=70043 }, classes = { 2 } },
                { id = 124340, slot = "Legs",               name = "Legplates of Iron Wrath",                      sources = { [14]=70044, [15]=70045, [16]=70046 }, classes = { 1 } },
                { id = 124342, slot = "Shoulder",           name = "Soulgorged Pauldrons",                         sources = { [14]=70051, [15]=70053, [16]=70054 } },
                { id = 124348, slot = "Waist",              name = "Ravenous Girdle",                              sources = { [14]=70072, [15]=70074, [16]=70075 } },
                { id = 124359, slot = "Weapon",             name = "Voracious Souleater",                          sources = { [14]=70111, [15]=70112, [16]=70113 } },
                { id = 124380, slot = "Two-Hand",           name = "Spur of the Great Devourer",                   sources = { [14]=70174, [15]=70175, [16]=70176 } },
                { id = 128069, slot = "Hands",              name = "Gloves of Great Engorgement",                  sources = { [17]=73038 } },
                { id = 128072, slot = "Chest",              name = "Bulging Chain Vest",                           sources = { [17]=73050 } },
                { id = 128079, slot = "Head",               name = "Boisterous Bellower's Hood",                   sources = { [17]=73078 } },
                { id = 128101, slot = "Two-Hand",           name = "Soulcult Ritual Staff",                        sources = { [17]=73145 } },
                { id = 128106, slot = "Back",               name = "Greatcloak of the Terrible Feast",             sources = { [17]=73156 } },
                { id = 128129, slot = "Legs",               name = "Felfume Pantaloons",                           sources = { [17]=73200 } },
                { id = 128131, slot = "Legs",               name = "Ironpelt Leggings",                            sources = { [17]=73208 } },
                { id = 128133, slot = "Legs",               name = "Rancorbite Leggings",                          sources = { [17]=73216 } },
                { id = 128135, slot = "Legs",               name = "Demonbreaker Legplates",                       sources = { [17]=73224 } },
                { id = 128196, slot = "Weapon",             name = "Limbcarver Hatchet",                           sources = { [17]=73321 } },
                { id = 128200, slot = "Held In Off-hand",   name = "Deserter's Honor",                             sources = { [17]=73329 } },
                { id = 139628, slot = "Legs",               name = "Ferroleather Leggings",                        sources = { [14]=80941, [15]=80942, [16]=80943 }, classes = { 12 } },
            },
        },
        {
            index              = 7,
            name               = "Shadow-Lord Iskar",
            journalEncounterID = 1433,
            aliases            = {},
            achievements       = {
                { id = 9988, name = "Pro Toss", meta = true, soloable = "yes" },
            },
            specialLoot = {
                { id = 127749, kind = "pet", name = "Corrupted Nest Guardian" },
            },
            loot = {
                { id = 124134, slot = "Back",               name = "Cloak of Desperate Temerity",                  sources = { [14]=69513, [15]=69514, [16]=69515 } },
                { id = 124170, slot = "Chest",              name = "Raiment of Divine Clarity",                    sources = { [14]=69630, [15]=69631, [16]=69632 } },
                { id = 124175, slot = "Shoulder",           name = "Amice of Phantasmal Power",                    sources = { [14]=69646, [15]=69648, [16]=69649 } },
                { id = 124259, slot = "Head",               name = "Helm of Imagined Horrors",                     sources = { [14]=69753, [15]=69755, [16]=69756 } },
                { id = 124275, slot = "Waist",              name = "Belt of Misconceived Loyalty",                 sources = { [14]=69808, [15]=69810, [16]=69811 } },
                { id = 124282, slot = "Chest",              name = "Vestment of Illusory Might",                   sources = { [14]=69835, [15]=69837, [16]=69838 } },
                { id = 124286, slot = "Feet",               name = "Surefooted Chain Treads",                      sources = { [14]=69849, [15]=69851, [16]=69852 } },
                { id = 124294, slot = "Head",               name = "Coif of Untrue Sight",                         sources = { [14]=69878, [15]=69880, [16]=69881 } },
                { id = 124316, slot = "Chest",              name = "Chestguard of Ill Fate",                       sources = { [14]=69959, [15]=69961, [16]=69962 } },
                { id = 124352, slot = "Wrist",              name = "Wristplate of the Wretched",                   sources = { [14]=70088, [15]=70090, [16]=70091 } },
                { id = 124387, slot = "Weapon",             name = "Shadowrend Talonblade",                        sources = { [14]=70195, [15]=70196, [16]=70197 } },
                { id = 124390, slot = "Ranged",             name = "Deceiver's Felbeak Wand",                      sources = { [14]=70204, [15]=70205, [16]=70206 } },
                { id = 128041, slot = "Head",               name = "Beaked Hood of Betrayal",                      sources = { [17]=72926 } },
                { id = 128055, slot = "Hands",              name = "Chakram-Gripping Gloves",                      sources = { [17]=72982 } },
                { id = 128063, slot = "Waist",              name = "Phantasmal Cummerbund",                        sources = { [17]=73014 } },
                { id = 128082, slot = "Chest",              name = "Corrupted Talonguard Chestplate",              sources = { [17]=73090 } },
                { id = 128083, slot = "Wrist",              name = "Feather-Embellished Wristclamps",              sources = { [17]=73094 } },
                { id = 128086, slot = "Wrist",              name = "Bracers of Supreme Despair",                   sources = { [17]=73106 } },
                { id = 128096, slot = "Ranged",             name = "Demonspine Wand",                              sources = { [17]=73135 } },
                { id = 128186, slot = "Back",               name = "Cursefeather Cloak",                           sources = { [17]=73302 } },
            },
        },
        {
            index              = 8,
            name               = "Socrethar the Eternal",
            journalEncounterID = 1427,
            aliases            = {},
            achievements       = {
                { id = 10086, name = "I'm a Soul Man", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 124141, slot = "Back",               name = "Drape of Beckoned Souls",                      sources = { [14]=69534, [15]=69535, [16]=69536 } },
                { id = 124143, slot = "Back",               name = "Soulbinder's Greatcloak",                      sources = { [14]=69540, [15]=69541, [16]=69542 } },
                { id = 124154, slot = "Hands",              name = "Gloves of the Arcanic Conclave",               sources = { [14]=69578, [15]=69579, [16]=69580 }, classes = { 8 } },
                { id = 124155, slot = "Hands",              name = "Pious Handwraps",                              sources = { [14]=69581, [15]=69582, [16]=69583 }, classes = { 5 } },
                { id = 124156, slot = "Hands",              name = "Deathrattle Gloves",                           sources = { [14]=69584, [15]=69585, [16]=69586 }, classes = { 9 } },
                { id = 124185, slot = "Wrist",              name = "Pristine Man'ari Cuffs",                       sources = { [14]=69682, [15]=69684, [16]=69685 } },
                { id = 124245, slot = "Chest",              name = "Tunic of the Soulbinder",                      sources = { [14]=69703, [15]=69705, [16]=69706 } },
                { id = 124255, slot = "Hands",              name = "Oathclaw Gauntlets",                           sources = { [14]=69740, [15]=69741, [16]=69742 }, classes = { 11 } },
                { id = 124256, slot = "Hands",              name = "Fistwraps of the Hurricane's Eye",             sources = { [14]=69743, [15]=69744, [16]=69745 }, classes = { 10 } },
                { id = 124257, slot = "Hands",              name = "Felblade Gloves",                              sources = { [14]=69746, [15]=69747, [16]=69748 }, classes = { 4 } },
                { id = 124292, slot = "Hands",              name = "Gloves of the Savage Hunt",                    sources = { [14]=69872, [15]=69873, [16]=69874 }, classes = { 3 } },
                { id = 124293, slot = "Hands",              name = "Gauntlets of the Living Mountain",             sources = { [14]=69875, [15]=69876, [16]=69877 }, classes = { 7 } },
                { id = 124313, slot = "Wrist",              name = "Chain Wristguards of the Stricken",            sources = { [14]=69947, [15]=69949, [16]=69950 } },
                { id = 124327, slot = "Hands",              name = "Demongaze Gauntlets",                          sources = { [14]=70000, [15]=70001, [16]=70002 }, classes = { 6 } },
                { id = 124328, slot = "Hands",              name = "Gauntlets of the Ceaseless Vigil",             sources = { [14]=70003, [15]=70004, [16]=70005 }, classes = { 2 } },
                { id = 124329, slot = "Hands",              name = "Gauntlets of Iron Wrath",                      sources = { [14]=70006, [15]=70007, [16]=70008 }, classes = { 1 } },
                { id = 124331, slot = "Head",               name = "Casque of Foul Concentration",                 sources = { [14]=70013, [15]=70015, [16]=70016 } },
                { id = 124357, slot = "Off-hand",           name = "Soulwarped Tower Shield",                      sources = { [14]=70105, [15]=70106, [16]=70107 } },
                { id = 124362, slot = "Ranged",             name = "Felcrystal Impaler",                           sources = { [14]=70120, [15]=70121, [16]=70122 } },
                { id = 124384, slot = "Weapon",             name = "Saber of Twisted Virtue",                      sources = { [14]=70186, [15]=70187, [16]=70188 } },
                { id = 124386, slot = "Weapon",             name = "Felstricken Sha'tari Crystalsword",            sources = { [14]=70192, [15]=70193, [16]=70194 } },
                { id = 128035, slot = "Waist",              name = "Crystal-Buckle Belt",                          sources = { [17]=72902 } },
                { id = 128036, slot = "Head",               name = "Hood of Unhealthy Fixation",                   sources = { [17]=72906 } },
                { id = 128046, slot = "Shoulder",           name = "Shoulderpads of Wrought Destruction",          sources = { [17]=72946 } },
                { id = 128051, slot = "Shoulder",           name = "Automated Shoulderplates",                     sources = { [17]=72966 } },
                { id = 128084, slot = "Wrist",              name = "Socrethar's Ceremonial Cuffs",                 sources = { [17]=73098 } },
                { id = 128085, slot = "Chest",              name = "Constructbreaker's Chestguard",                sources = { [17]=73102 } },
                { id = 128088, slot = "Waist",              name = "Girdle of Bound Agony",                        sources = { [17]=73114 } },
                { id = 128119, slot = "Off-hand",           name = "Decaying Draenic Shield",                      sources = { [17]=73161 } },
                { id = 128190, slot = "Back",               name = "Haunting Nightmare Cloak",                     sources = { [17]=73310 } },
                { id = 128195, slot = "Ranged",             name = "Toxin-Tipped Bolt Launcher",                   sources = { [17]=73319 } },
                { id = 128197, slot = "Weapon",             name = "Felgore Double Blade",                         sources = { [17]=73323 } },
                { id = 139626, slot = "Hands",              name = "Ferroleather Gloves",                          sources = { [14]=80935, [15]=80936, [16]=80937 }, classes = { 12 } },
            },
        },
        {
            index              = 9,
            name               = "Fel Lord Zakuun",
            journalEncounterID = 1391,
            aliases            = {},
            achievements       = {
                { id = 10012, name = "This Land Was Green and Good Until...", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 124138, slot = "Back",               name = "Cloak of Hideous Unity",                       sources = { [14]=69525, [15]=69526, [16]=69527 } },
                { id = 124149, slot = "Feet",               name = "Bloody Dagger-Heeled Pumps",                   sources = { [14]=69559, [15]=69561, [16]=69562 } },
                { id = 124181, slot = "Waist",              name = "Sash of Unending Anguish",                     sources = { [14]=69667, [15]=69669, [16]=69670 } },
                { id = 124265, slot = "Legs",               name = "Leggings of Eternal Terror",                   sources = { [14]=69774, [15]=69776, [16]=69777 } },
                { id = 124280, slot = "Wrist",              name = "Manacles of the Multitudes",                   sources = { [14]=69828, [15]=69829, [16]=69830 } },
                { id = 124283, slot = "Chest",              name = "Ringmail of Madness Accordant",                sources = { [14]=69839, [15]=69841, [16]=69842 } },
                { id = 124310, slot = "Waist",              name = "Girdle of the Legion General",                 sources = { [14]=69935, [15]=69937, [16]=69938 } },
                { id = 124337, slot = "Legs",               name = "Legguards of Grievous Consonances",            sources = { [14]=70034, [15]=70036, [16]=70037 } },
                { id = 124360, slot = "Two-Hand",           name = "Hellrender",                                   sources = { [14]=70114, [15]=70115, [16]=70116 } },
                { id = 124368, slot = "Weapon",             name = "Demonblade Eviscerator",                       sources = { [14]=70138, [15]=70139, [16]=70140 } },
                { id = 124369, slot = "Weapon",             name = "Mindscythe of the Legion",                     sources = { [14]=70141, [15]=70142, [16]=70143 } },
                { id = 128038, slot = "Hands",              name = "Brittleskin Wraps",                            sources = { [17]=72914 } },
                { id = 128043, slot = "Head",               name = "Gaze of Superiority",                          sources = { [17]=72934 } },
                { id = 128066, slot = "Legs",               name = "Imp-Infested Legplates",                       sources = { [17]=73026 } },
                { id = 128174, slot = "Wrist",              name = "Bindings of Imminent Fury",                    sources = { [17]=73288 } },
                { id = 128175, slot = "Wrist",              name = "Manacles of the Demon General",                sources = { [17]=73292 } },
                { id = 128189, slot = "Back",               name = "Bloodcrystal Chaincloak",                      sources = { [17]=73308 } },
                { id = 128202, slot = "Weapon",             name = "Ironblade Knuckles",                           sources = { [17]=73333 } },
                { id = 128299, slot = "Waist",              name = "Withering Waistwrap",                          sources = { [17]=73392 } },
                { id = 128300, slot = "Waist",              name = "Befouled Demonhide Belt",                      sources = { [17]=73396 } },
            },
        },
        {
            index              = 10,
            name               = "Xhul'horac",
            journalEncounterID = 1447,
            aliases            = {},
            achievements       = {
                { id = 10087, name = "You Gotta Keep 'em Separated", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 124147, slot = "Back",               name = "Void Lord's Wizened Cloak",                    sources = { [14]=69552, [15]=69553, [16]=69554 } },
                { id = 124158, slot = "Head",               name = "Countenance of the Revenant",                  sources = { [14]=69590, [15]=69591, [16]=69592 } },
                { id = 124177, slot = "Shoulder",           name = "Mantle of the Arcanic Conclave",               sources = { [14]=69654, [15]=69655, [16]=69656 }, classes = { 8 } },
                { id = 124178, slot = "Shoulder",           name = "Pious Mantle",                                 sources = { [14]=69657, [15]=69658, [16]=69659 }, classes = { 5 } },
                { id = 124179, slot = "Shoulder",           name = "Deathrattle Shoulderpads",                     sources = { [14]=69660, [15]=69661, [16]=69662 }, classes = { 9 } },
                { id = 124260, slot = "Head",               name = "Hood of Unknowable Secrets",                   sources = { [14]=69757, [15]=69759, [16]=69760 } },
                { id = 124272, slot = "Shoulder",           name = "Oathclaw Mantle",                              sources = { [14]=69799, [15]=69800, [16]=69801 }, classes = { 11 } },
                { id = 124273, slot = "Shoulder",           name = "Mantle of the Hurricane's Eye",                sources = { [14]=69802, [15]=69803, [16]=69804 }, classes = { 10 } },
                { id = 124274, slot = "Shoulder",           name = "Felblade Spaulders",                           sources = { [14]=69805, [15]=69806, [16]=69807 }, classes = { 4 } },
                { id = 124295, slot = "Head",               name = "Sinister Felborne Helmet",                     sources = { [14]=69882, [15]=69884, [16]=69885 } },
                { id = 124307, slot = "Shoulder",           name = "Pauldrons of the Savage Hunt",                 sources = { [14]=69925, [15]=69926, [16]=69927 }, classes = { 3 } },
                { id = 124308, slot = "Shoulder",           name = "Pauldrons of the Living Mountain",             sources = { [14]=69928, [15]=69929, [16]=69930 }, classes = { 7 } },
                { id = 124344, slot = "Shoulder",           name = "Demongaze Pauldrons",                          sources = { [14]=70059, [15]=70060, [16]=70061 }, classes = { 6 } },
                { id = 124345, slot = "Shoulder",           name = "Shoulderplates of the Ceaseless Vigil",        sources = { [14]=70062, [15]=70063, [16]=70064 }, classes = { 2 } },
                { id = 124346, slot = "Shoulder",           name = "Pauldrons of Iron Wrath",                      sources = { [14]=70065, [15]=70066, [16]=70067 }, classes = { 1 } },
                { id = 124353, slot = "Wrist",              name = "Breach-Scarred Wristplates",                   sources = { [14]=70092, [15]=70094, [16]=70095 } },
                { id = 124371, slot = "Weapon",             name = "Hammer of Wicked Infusion",                    sources = { [14]=70147, [15]=70148, [16]=70149 } },
                { id = 124374, slot = "Weapon",             name = "Fiendsbreath Warmace",                         sources = { [14]=70156, [15]=70157, [16]=70158 } },
                { id = 124381, slot = "Two-Hand",           name = "Voidcore Greatstaff",                          sources = { [14]=70177, [15]=70178, [16]=70179 } },
                { id = 128032, slot = "Feet",               name = "Demonbreaker Crushers",                        sources = { [17]=72890 } },
                { id = 128052, slot = "Feet",               name = "Felfume Slippers",                             sources = { [17]=72970 } },
                { id = 128054, slot = "Feet",               name = "Ironpelt Boots",                               sources = { [17]=72978 } },
                { id = 128080, slot = "Feet",               name = "Rancorbite Sabatons",                          sources = { [17]=73082 } },
                { id = 128091, slot = "Legs",               name = "Stoic Netherfel Legplates",                    sources = { [17]=73126 } },
                { id = 128176, slot = "Wrist",              name = "Bracers of Tainted Magic",                     sources = { [17]=73296 } },
                { id = 128187, slot = "Back",               name = "Voidthread Spineguard",                        sources = { [17]=73304 } },
                { id = 128295, slot = "Waist",              name = "Shadowfel Cord",                               sources = { [17]=73384 } },
                { id = 128298, slot = "Waist",              name = "Girdle of Volatile Duality",                   sources = { [17]=73388 } },
                { id = 139629, slot = "Shoulder",           name = "Ferroleather Spaulders",                       sources = { [14]=80944, [15]=80945, [16]=80946 }, classes = { 12 } },
            },
        },
        {
            index              = 11,
            name               = "Tyrant Velhari",
            journalEncounterID = 1394,
            aliases            = {},
            achievements       = {
                { id = 9989, name = "Non-Lethal Enforcer", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 124153, slot = "Hands",              name = "Satin Gloves of Injustice",                    sources = { [14]=69574, [15]=69576, [16]=69577 } },
                { id = 124186, slot = "Wrist",              name = "Contemptuous Wristguards",                     sources = { [14]=69686, [15]=69688, [16]=69689 } },
                { id = 124251, slot = "Feet",               name = "Oppressor's Merciless Treads",                 sources = { [14]=69724, [15]=69726, [16]=69727 } },
                { id = 124287, slot = "Feet",               name = "Spiked Throatcrusher Boots",                   sources = { [14]=69853, [15]=69855, [16]=69856 } },
                { id = 124300, slot = "Legs",               name = "Haughty Chain Legguards",                      sources = { [14]=69900, [15]=69902, [16]=69903 } },
                { id = 124306, slot = "Shoulder",           name = "Pauldrons of Contempt",                        sources = { [14]=69921, [15]=69923, [16]=69924 } },
                { id = 124326, slot = "Hands",              name = "Gauntlets of Derision",                        sources = { [14]=69996, [15]=69998, [16]=69999 } },
                { id = 124355, slot = "Off-hand",           name = "Fallen Defender of Argus",                     sources = { [14]=70099, [15]=70100, [16]=70101 } },
                { id = 124375, slot = "Two-Hand",           name = "Maul of Tyranny",                              sources = { [14]=70159, [15]=70160, [16]=70161 } },
                { id = 124376, slot = "Two-Hand",           name = "Warhammer of Arrogance",                       sources = { [14]=70162, [15]=70163, [16]=70164 } },
                { id = 128045, slot = "Shoulder",           name = "Mantle of Unrestrained Contempt",              sources = { [17]=72942 } },
                { id = 128090, slot = "Chest",              name = "Harbinger's Desecrated Chain Shirt",           sources = { [17]=73122 } },
                { id = 128099, slot = "Two-Hand",           name = "Spiked Gnarlroot Greatclub",                   sources = { [17]=93730 } },
                { id = 128136, slot = "Hands",              name = "Felfume Gloves",                               sources = { [17]=73228 } },
                { id = 128137, slot = "Hands",              name = "Ironpelt Mitts",                               sources = { [17]=73232 } },
                { id = 128138, slot = "Hands",              name = "Rancorbite Grips",                             sources = { [17]=73236 } },
                { id = 128139, slot = "Hands",              name = "Demonbreaker Gauntlets",                       sources = { [17]=73240 } },
                { id = 128188, slot = "Back",               name = "Impertinent Student's Cloak",                  sources = { [17]=73306 } },
            },
        },
        {
            index              = 12,
            name               = "Mannoroth",
            journalEncounterID = 1395,
            aliases            = {},
            achievements       = {
                { id = 10030, name = "Bad Manner(oth)", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 124135, slot = "Back",               name = "Cloak of Tangible Dread",                      sources = { [14]=69516, [15]=69517, [16]=69518 } },
                { id = 124164, slot = "Legs",               name = "Leggings of the Iron Summoner",                sources = { [14]=69610, [15]=69611, [16]=69612 } },
                { id = 124171, slot = "Chest",              name = "Robe of the Arcanic Conclave",                 sources = { [14]=69633, [15]=69634, [16]=69635 }, classes = { 8 } },
                { id = 124172, slot = "Chest",              name = "Pious Raiment",                                sources = { [14]=69636, [15]=69637, [16]=69638 }, classes = { 5 } },
                { id = 124173, slot = "Chest",              name = "Deathrattle Robe",                             sources = { [14]=69639, [15]=69640, [16]=69641 }, classes = { 9 } },
                { id = 124206, slot = "Held In Off-hand",   name = "Thumping Demonheart Fetish",                   sources = { [14]=69693, [15]=69694, [16]=69695 } },
                { id = 124246, slot = "Chest",              name = "Oathclaw Vestment",                            sources = { [14]=69707, [15]=69708, [16]=69709 }, classes = { 11 } },
                { id = 124247, slot = "Chest",              name = "Robe of the Hurricane's Eye",                  sources = { [14]=69710, [15]=69711, [16]=69712 }, classes = { 10 } },
                { id = 124248, slot = "Chest",              name = "Felblade Chestguard",                          sources = { [14]=69713, [15]=69714, [16]=69715 }, classes = { 4 } },
                { id = 124266, slot = "Legs",               name = "Empowered Demonskin Kilt",                     sources = { [14]=69778, [15]=69779, [16]=69780 } },
                { id = 124284, slot = "Chest",              name = "Hauberk of the Savage Hunt",                   sources = { [14]=69843, [15]=69844, [16]=69845 }, classes = { 3 } },
                { id = 124303, slot = "Chest",              name = "Robe of the Living Mountain",                  sources = { [14]=69910, [15]=69911, [16]=69912 }, classes = { 7 } },
                { id = 124314, slot = "Wrist",              name = "Bracers of Fel Empowerment",                   sources = { [14]=69951, [15]=69953, [16]=69954 } },
                { id = 124317, slot = "Chest",              name = "Demongaze Chestplate",                         sources = { [14]=69963, [15]=69964, [16]=69965 }, classes = { 6 } },
                { id = 124318, slot = "Chest",              name = "Cuirass of the Ceaseless Vigil",               sources = { [14]=69966, [15]=69967, [16]=69968 }, classes = { 2 } },
                { id = 124319, slot = "Chest",              name = "Breastplate of Iron Wrath",                    sources = { [14]=69969, [15]=69970, [16]=69971 }, classes = { 1 } },
                { id = 124349, slot = "Waist",              name = "Annihilan's Waistplate",                       sources = { [14]=70076, [15]=70078, [16]=70079 } },
                { id = 124361, slot = "Ranged",             name = "Cursed Demonbone Longbow",                     sources = { [14]=70117, [15]=70118, [16]=70119 } },
                { id = 124367, slot = "Weapon",             name = "Fang of the Pit",                              sources = { [14]=70135, [15]=70136, [16]=70137 } },
                { id = 124378, slot = "Two-Hand",           name = "Xu'tenash, Glaive of Ruin",                    sources = { [14]=70168, [15]=70169, [16]=70170 } },
                { id = 128034, slot = "Head",               name = "Pit Lord's Cowl",                              sources = { [17]=72898 } },
                { id = 128037, slot = "Legs",               name = "Leggings of Wasted Flesh",                     sources = { [17]=72910 } },
                { id = 128112, slot = "Held In Off-hand",   name = "Fel-Light Lantern",                            sources = { [17]=73157 } },
                { id = 128120, slot = "Shoulder",           name = "Felfume Mantle",                               sources = { [17]=73166 } },
                { id = 128121, slot = "Shoulder",           name = "Ironpelt Pauldrons",                           sources = { [17]=73170 } },
                { id = 128122, slot = "Shoulder",           name = "Rancorbite Spaulders",                         sources = { [17]=73174 } },
                { id = 128123, slot = "Shoulder",           name = "Demonbreaker Pauldrons",                       sources = { [17]=73178 } },
                { id = 128170, slot = "Feet",               name = "Hellstorm Sabatons",                           sources = { [17]=73280 } },
                { id = 128177, slot = "Wrist",              name = "Demonforged Iron Bracers",                     sources = { [17]=73300 } },
                { id = 128193, slot = "Weapon",             name = "Serrated Bloodritual Dagger",                  sources = { [17]=73315 } },
                { id = 128194, slot = "Ranged",             name = "Snarlwood Recurve Bow",                        sources = { [17]=73317 } },
                { id = 128198, slot = "Two-Hand",           name = "Irontalon Staff",                              sources = { [17]=73326 } },
                { id = 139625, slot = "Chest",              name = "Ferroleather Chestguard",                      sources = { [14]=80932, [15]=80933, [16]=80934 }, classes = { 12 } },
            },
        },
        {
            index              = 13,
            name               = "Archimonde",
            journalEncounterID = 1438,
            aliases            = {},
            achievements       = {
                { id = 10073, name = "Echoes of Doomfire", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 124144, slot = "Back",               name = "Cloak of Incendiary Wrath",                    sources = { [14]=69543, [15]=69544, [16]=69545 } },
                { id = 124159, slot = "Head",               name = "Demon Prince's Ascendant Crown",               sources = { [14]=69593, [15]=69593, [16]=69593, [17]=69593 } },
                { id = 124176, slot = "Shoulder",           name = "Mantle of the Eredar Lord",                    sources = { [14]=69650, [15]=69650, [16]=69650, [17]=69650 } },
                { id = 124200, slot = "Waist",              name = "Demonbuckle Sash of Argus",                    sources = { [14]=73423, [15]=73423, [16]=73423, [17]=73423 } },
                { id = 124254, slot = "Hands",              name = "Felfinger Runegloves",                         sources = { [14]=69736, [15]=69738, [16]=69739 } },
                { id = 124276, slot = "Waist",              name = "Waistwrap of Banishment",                      sources = { [14]=69812, [15]=69814, [16]=69815 } },
                { id = 124291, slot = "Hands",              name = "Eredar Fel-Chain Gloves",                      sources = { [14]=69868, [15]=69870, [16]=69871 } },
                { id = 124322, slot = "Feet",               name = "Treads of the Defiler",                        sources = { [14]=69980, [15]=69982, [16]=69983 } },
                { id = 124343, slot = "Shoulder",           name = "Doomcrier's Shoulderplates",                   sources = { [14]=70055, [15]=70057, [16]=70058 } },
                { id = 124372, slot = "Weapon",             name = "Gavel of the Eredar",                          sources = { [14]=70150, [15]=70151, [16]=70152 } },
                { id = 124382, slot = "Two-Hand",           name = "Edict of Argus",                               sources = { [14]=70180, [15]=70181, [16]=70182 } },
                { id = 124389, slot = "Two-Hand",           name = "Calamity's Edge",                              sources = { [14]=70201, [15]=70202, [16]=70203 } },
                { id = 128039, slot = "Legs",               name = "Shadeflesh Legguards",                         sources = { [17]=72918 } },
                { id = 128044, slot = "Head",               name = "Voidsight Hood",                               sources = { [17]=72938 } },
                { id = 128048, slot = "Hands",              name = "Vintage Draenic Handguards",                   sources = { [17]=72954 } },
                { id = 128124, slot = "Chest",              name = "Felfume Robes",                                sources = { [17]=73182 } },
                { id = 128125, slot = "Chest",              name = "Ironpelt Jerkin",                              sources = { [17]=73184 } },
                { id = 128126, slot = "Chest",              name = "Rancorbite Chain Shirt",                       sources = { [17]=73188 } },
                { id = 128127, slot = "Chest",              name = "Demonbreaker Chestplate",                      sources = { [17]=73192 } },
                { id = 128171, slot = "Feet",               name = "Stompers of Echoing Doom",                     sources = { [17]=73284 } },
                { id = 128199, slot = "Two-Hand",           name = "Fractured Soulgem Staff",                      sources = { [17]=73327 } },
                { id = 128201, slot = "Two-Hand",           name = "Greatsword of Chaos",                          sources = { [17]=73331 } },
            },
        },
    },

    lfrWings = {
        -- Wing 1 -- Hellbreach: Hellfire Assault, Iron Reaver, Kormrok
        -- (standard routing steps 1-3). Notes and routing imported
        -- verbatim from the standard route.
        [1366] = {
            name   = "Hellbreach",
            bosses = { 1, 2, 3 },
            lockoutBits = { [1] = 2, [2] = 5, [3] = 7 },
            routing = {
                -- 1. Hellfire Assault
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 1,
                    title     = "Hellfire Assault",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 661 },
                            kind    = "poi",
                            noMarker = true,
                            note    = "Run around the room killing elites/vehicles until the encounter with ^Hellfire Assault^ begins.",
                            points  = {
                                { 0.671, 0.438 },
                            },
                        },
                    },
                },

                -- 2. Iron Reaver
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 2,
                    title     = "Iron Reaver",
                    requires  = { 1 },
                    segments  = {
                        {
                            when    = { mapID = 661 },
                            kind    = "poi",
                            noMarker = true,
                            note    = "After completing the ^Hellfire Assault^ encounter, you will find ^Iron Reaver^ spawned right in front of you.",
                            points  = {
                                { 0.671, 0.438 },
                            },
                        },
                    },
                },

                -- 3. Kormrok
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 3,
                    title     = "Kormrok",
                    requires  = { 2 },
                    segments  = {
                        {
                            when    = { mapID = 661, subZone = "The Iron Bulwark" },
                            kind    = "path",
                            note    = "After killing ^Iron Reaver^, continue up the stairs behind him to the next area.",
                            points  = {
                                { 0.403, 0.507 },
                                { 0.323, 0.509 },
                            },
                        },
                        {
                            when    = { mapID = 662 },
                            kind    = "path",
                            note    = "In the next area, follow the path upstairs to the right and follow it around.",
                            points  = {
                                { 0.837, 0.475 },
                                { 0.777, 0.440 },
                                { 0.772, 0.288 },
                                { 0.721, 0.282 },
                                { 0.718, 0.208 },
                            },
                        },
                        {
                            when    = { mapID = 663 },
                            kind    = "path",
                            note    = "Continue following the linear path into the next room.",
                            points  = {
                                { 0.677, 0.878 },
                                { 0.676, 0.753 },
                                { 0.512, 0.743 },
                                { 0.504, 0.204 },
                            },
                        },
                        {
                            when    = { mapID = 664 },
                            kind    = "path",
                            note    = "In the boss room, kill all of the trash and approach the boss to start the encounter with ^Kormrok^.",
                            points  = {
                                { 0.606, 0.781 },
                                { 0.530, 0.501 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 2 -- Halls of Blood: Hellfire High Council, Kilrogg
        -- Deadeye, Gorefiend (LFR order, same as standard). LFR drops the
        -- player on mapID 665, so High Council's entry is the standard
        -- 665 seg with a reworded zone-in note (the 664/663/662 backtrack
        -- from Kormrok does not apply); Kilrogg and Gorefiend chain from
        -- High Council and import verbatim.
        [1367] = {
            name   = "Halls of Blood",
            bosses = { 4, 5, 6 },
            lockoutBits = { [4] = 11, [5] = 6, [6] = 3 },
            routing = {
                -- 4. Hellfire High Council (reworded 665 zone-in entry)
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 4,
                    title     = "Hellfire High Council",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 665 },
                            kind    = "path",
                            note    = "After zoning in, follow the path around to ^Hellfire High Council^.",
                            points  = {
                                { 0.816, 0.245 },
                                { 0.816, 0.332 },
                                { 0.713, 0.335 },
                                { 0.713, 0.631 },
                            },
                        },
                    },
                },

                -- 5. Kilrogg Deadeye (standard seg verbatim)
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 5,
                    title     = "Kilrogg Deadeye",
                    requires  = { 4 },
                    segments  = {
                        {
                            when    = { mapID = 665 },
                            kind    = "path",
                            note    = "After defeating the ^Hellfire High Council^, take the southwestern exit out of the room and follow the long linear path to ^Kilrogg Deadeye^.",
                            points  = {
                                { 0.684, 0.700 },
                                { 0.576, 0.797 },
                                { 0.465, 0.799 },
                                { 0.461, 0.643 },
                                { 0.125, 0.647 },
                                { 0.122, 0.342 },
                                { 0.486, 0.336 },
                            },
                        },
                    },
                },

                -- 6. Gorefiend (standard segs verbatim)
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 6,
                    title     = "Gorefiend",
                    requires  = { 5 },
                    segments  = {
                        {
                            when    = { mapID = 665 },
                            kind    = "path",
                            note    = "After killing ^Kilrogg Deadeye^, exit behind him to the east and follow the path out of this area.",
                            points  = {
                                { 0.541, 0.334 },
                                { 0.819, 0.330 },
                                { 0.815, 0.076 },
                            },
                        },
                        {
                            when    = { mapID = 662 },
                            kind    = "path",
                            note    = "Back in ^Hellfire Antechamber^, follow the path to reach ^Gorefiend^. Kill the trash to start the encounter.",
                            points  = {
                                { 0.726, 0.659 },
                                { 0.780, 0.596 },
                                { 0.780, 0.440 },
                                { 0.684, 0.433 },
                                { 0.639, 0.425 },
                                { 0.583, 0.474 },
                                { 0.366, 0.476 },
                                { 0.348, 0.543 },
                                { 0.311, 0.616 },
                                { 0.243, 0.649 },
                                { 0.191, 0.494 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 3 -- Bastion of Shadows: Shadow-Lord Iskar, Socrethar the
        -- Eternal, Tyrant Velhari (LFR walk order). LFR drops the player
        -- on mapID 666, so Iskar's entry is the standard 666 seg with a
        -- reworded zone-in note (the 662 Gorefiend-portal POI does not
        -- apply); Socrethar and Velhari chain from Iskar and import
        -- verbatim.
        [1368] = {
            name   = "Bastion of Shadows",
            bosses = { 7, 8, 11 },
            lockoutBits = { [7] = 8, [8] = 9, [11] = 4 },
            routing = {
                -- 7. Shadow-Lord Iskar (reworded 666 zone-in entry)
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 7,
                    title     = "Shadow-Lord Iskar",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 666 },
                            kind    = "path",
                            note    = "After zoning in, go west to reach ^Shadow-Lord Iskar^.",
                            points  = {
                                { 0.593, 0.766 },
                                { 0.425, 0.764 },
                            },
                        },
                    },
                },

                -- 8. Socrethar the Eternal (standard segs verbatim)
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 8,
                    title     = "Socrethar the Eternal",
                    requires  = { 7 },
                    segments  = {
                        {
                            when    = { mapID = 666 },
                            kind    = "path",
                            note    = "After killing ^Shadow-Lord Iskar^, exit the room to the east. At the first intersection, go south to the next area.",
                            points  = {
                                { 0.424, 0.765 },
                                { 0.594, 0.766 },
                                { 0.617, 0.806 },
                                { 0.618, 0.858 },
                            },
                        },
                        {
                            when    = { mapID = 668 },
                            kind    = "path",
                            note    = "In the next area, go east, then south down some stairs. When you reach the boss room, clear the trash to start the encounter with ^Socrethar the Eternal^.",
                            points  = {
                                { 0.424, 0.204 },
                                { 0.425, 0.254 },
                                { 0.621, 0.254 },
                                { 0.621, 0.346 },
                                { 0.612, 0.401 },
                                { 0.608, 0.486 },
                            },
                        },
                    },
                },

                -- 11. Tyrant Velhari (standard seg verbatim)
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 11,
                    title     = "Tyrant Velhari",
                    requires  = { 8 },
                    segments  = {
                        {
                            when    = { mapID = 668 },
                            kind    = "path",
                            note    = "After defeating ^Socrethar the Eternal^, leave the room to the south. In the next room, click 4x ^Demon Portals^ then kill ^Lord Aram'el^ to open the door. Proceed along the path to ^Tyrant Velhari^.",
                            points  = {
                                { 0.593, 0.572 },
                                { 0.571, 0.619 },
                                { 0.567, 0.806 },
                                { 0.425, 0.808 },
                                { 0.424, 0.702 },
                                { 0.292, 0.694 },
                                { 0.290, 0.558 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 4 -- Destructor's Rise: Fel Lord Zakuun, Xhul'horac,
        -- Mannoroth (LFR walk order). LFR drops the player on mapID 666,
        -- so Zakuun's entry is an LFR-specific zone-in walk (the standard
        -- 668->666 backtrack from Velhari does not apply); Xhul'horac and
        -- Mannoroth chain from Zakuun and import.
        [1369] = {
            name   = "Destructor's Rise",
            bosses = { 9, 10, 12 },
            lockoutBits = { [9] = 1, [10] = 13, [12] = 10 },
            routing = {
                -- 9. Fel Lord Zakuun (LFR-specific zone-in entry)
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 9,
                    title     = "Fel Lord Zakuun",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 666 },
                            kind    = "path",
                            note    = "After zoning in, go left to find ^Fel Lord Zakuun^.",
                            points  = {
                                { 0.463, 0.482 },
                                { 0.495, 0.372 },
                                { 0.494, 0.220 },
                            },
                        },
                    },
                },

                -- 10. Xhul'horac (standard seg verbatim)
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 10,
                    title     = "Xhul'horac",
                    requires  = { 9 },
                    segments  = {
                        {
                            when    = { mapID = 666 },
                            kind    = "path",
                            note    = "After defeating ^Fel Lord Zakuun^, climb out of this area the way you came, and go all the way east to reach ^Xhul'horac^. Kill trash to start the encounter.",
                            points  = {
                                { 0.500, 0.217 },
                                { 0.499, 0.386 },
                                { 0.569, 0.447 },
                                { 0.802, 0.454 },
                                { 0.869, 0.515 },
                            },
                        },
                    },
                },

                -- 12. Mannoroth (standard segs verbatim)
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 12,
                    title     = "Mannoroth",
                    requires  = { 10 },
                    segments  = {
                        {
                            when        = { mapID = 667 },
                            kind        = "poi",
                            mapLabel    = "Take Portal",
                            mapLabelPos = "above",
                            note        = "After killing ^Xhul'horac^, take the portal that appears right next to you.",
                            points      = {
                                { 0.484, 0.507 },
                            },
                        },
                        {
                            when    = { mapID = 669 },
                            kind    = "poi",
                            noMarker = true,
                            note    = "After taking the portal, you will arrive in ^Destructor's Rise^. On ^Mythic^, do NOT kill the ^Fel Iron Summoners^. Just tag them, and let ^Mannoroth^ kill them or you could bug the encounter. On other difficulties, kill the ^Fel Iron Summoners^ to begin the fight.",
                            points  = {
                                { 0.511, 0.369 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 5 -- The Black Gate: Archimonde (final wing). LFR zones
        -- the player in right in front of Archimonde on mapID 670, so a
        -- single note-only poi (the standard 669 Mannoroth-portal seg
        -- does not apply).
        [1370] = {
            name   = "The Black Gate",
            bosses = { 13 },
            lockoutBits = { [13] = 12 },
            routing = {
                -- 13. Archimonde
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 13,
                    title     = "Archimonde",
                    requires  = {},
                    segments  = {
                        {
                            when     = { mapID = 670 },
                            kind     = "poi",
                            noMarker = true,
                            note     = "You will zone in right in front of ^Archimonde^. Kill him!",
                            points   = {
                                { 0.462, 0.515 },
                            },
                        },
                    },
                },
            },
        },
    },

    routing = {

        -- 1. Hellfire Assault
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Hellfire Assault",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 661 },
                    kind    = "poi",
                    noMarker = true,
                    note    = "Run around the room killing elites/vehicles until the encounter with ^Hellfire Assault^ begins.",
                    points  = {
                        { 0.671, 0.438 },
                    },
                },
            },
        },

        -- 2. Iron Reaver
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Iron Reaver",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 661 },
                    kind    = "poi",
                    noMarker = true,
                    note    = "After completing the ^Hellfire Assault^ encounter, you will find ^Iron Reaver^ spawned right in front of you.",
                    points  = {
                        { 0.671, 0.438 },
                    },
                },
            },
        },

        -- 3. Kormrok
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Kormrok",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 661, subZone = "The Iron Bulwark" },
                    kind    = "path",
                    note    = "After killing ^Iron Reaver^, continue up the stairs behind him to the next area.",
                    points  = {
                        { 0.403, 0.507 },
                        { 0.323, 0.509 },
                    },
                },
                {
                    when    = { mapID = 662 },
                    kind    = "path",
                    note    = "In the next area, follow the path upstairs to the right and follow it around.",
                    points  = {
                        { 0.837, 0.475 },
                        { 0.777, 0.440 },
                        { 0.772, 0.288 },
                        { 0.721, 0.282 },
                        { 0.718, 0.208 },
                    },
                },
                {
                    when    = { mapID = 663 },
                    kind    = "path",
                    note    = "Continue following the linear path into the next room.",
                    points  = {
                        { 0.677, 0.878 },
                        { 0.676, 0.753 },
                        { 0.512, 0.743 },
                        { 0.504, 0.204 },
                    },
                },
                {
                    when    = { mapID = 664 },
                    kind    = "path",
                    note    = "In the boss room, kill all of the trash and approach the boss to start the encounter with ^Kormrok^.",
                    points  = {
                        { 0.606, 0.781 },
                        { 0.530, 0.501 },
                    },
                },
            },
        },

        -- 4. Hellfire High Council
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Hellfire High Council",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 664 },
                    kind    = "path",
                    note    = "After killing ^Kormrok^, exit the room the way you entered.",
                    points  = {
                        { 0.547, 0.491 },
                        { 0.606, 0.755 },
                        { 0.606, 0.904 },
                    },
                },
                {
                    when    = { mapID = 663 },
                    kind    = "path",
                    note    = "Continue backtracking through this room.",
                    points  = {
                        { 0.509, 0.229 },
                        { 0.509, 0.745 },
                        { 0.677, 0.751 },
                        { 0.677, 0.906 },
                    },
                },
                {
                    when    = { mapID = 662 },
                    kind    = "path",
                    note    = "Cross the room and take the southern exit.",
                    points  = {
                        { 0.722, 0.245 },
                        { 0.777, 0.347 },
                        { 0.776, 0.593 },
                        { 0.722, 0.703 },
                        { 0.719, 0.743 },
                    },
                },
                {
                    when    = { mapID = 665 },
                    kind    = "path",
                    note    = "Follow the path around to ^Hellfire High Council^.",
                    points  = {
                        { 0.816, 0.245 },
                        { 0.816, 0.332 },
                        { 0.713, 0.335 },
                        { 0.713, 0.631 },
                    },
                },
            },
        },

        -- 5. Kilrogg Deadeye
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Kilrogg Deadeye",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 665 },
                    kind    = "path",
                    note    = "After defeating the ^Hellfire High Council^, take the southwestern exit out of the room and follow the long linear path to ^Kilrogg Deadeye^.",
                    points  = {
                        { 0.684, 0.700 },
                        { 0.576, 0.797 },
                        { 0.465, 0.799 },
                        { 0.461, 0.643 },
                        { 0.125, 0.647 },
                        { 0.122, 0.342 },
                        { 0.486, 0.336 },
                    },
                },
            },
        },

        -- 6. Gorefiend
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Gorefiend",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 665 },
                    kind    = "path",
                    note    = "After killing ^Kilrogg Deadeye^, exit behind him to the east and follow the path out of this area.",
                    points  = {
                        { 0.541, 0.334 },
                        { 0.819, 0.330 },
                        { 0.815, 0.076 },
                    },
                },
                {
                    when    = { mapID = 662 },
                    kind    = "path",
                    note    = "Back in ^Hellfire Antechamber^, follow the path to reach ^Gorefiend^. Kill the trash to start the encounter.",
                    points  = {
                        { 0.726, 0.659 },
                        { 0.780, 0.596 },
                        { 0.780, 0.440 },
                        { 0.684, 0.433 },
                        { 0.639, 0.425 },
                        { 0.583, 0.474 },
                        { 0.366, 0.476 },
                        { 0.348, 0.543 },
                        { 0.311, 0.616 },
                        { 0.243, 0.649 },
                        { 0.191, 0.494 },
                    },
                },
            },
        },

        -- 7. Shadow-Lord Iskar
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Shadow-Lord Iskar",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 662 },
                    kind    = "poi",
                    mapLabel    = "Portal",
                    mapLabelPos = "above",
                    note    = "After killing ^Gorefiend^, click the nearby portal.",
                    points  = {
                        { 0.238, 0.466 },
                    },
                },
                {
                    when    = { mapID = 666 },
                    kind    = "path",
                    note    = "After landing in the next area, go west to reach ^Shadow-Lord Iskar^.",
                    points  = {
                        { 0.593, 0.766 },
                        { 0.425, 0.764 },
                    },
                },
            },
        },

        -- 8. Socrethar the Eternal
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Socrethar the Eternal",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 666 },
                    kind    = "path",
                    note    = "After killing ^Shadow-Lord Iskar^, exit the room to the east. At the first intersection, go south to the next area.",
                    points  = {
                        { 0.424, 0.765 },
                        { 0.594, 0.766 },
                        { 0.617, 0.806 },
                        { 0.618, 0.858 },
                    },
                },
                {
                    when    = { mapID = 668 },
                    kind    = "path",
                    note    = "In the next area, go east, then south down some stairs. When you reach the boss room, clear the trash to start the encounter with ^Socrethar the Eternal^.",
                    points  = {
                        { 0.424, 0.204 },
                        { 0.425, 0.254 },
                        { 0.621, 0.254 },
                        { 0.621, 0.346 },
                        { 0.612, 0.401 },
                        { 0.608, 0.486 },
                    },
                },
            },
        },

        -- Tyrant Velhari (bossIndex 11; routed here, ninth in walk order,
        -- because the route reaches Velhari directly after Socrethar --
        -- the encounter order from the Journal does not match the path).
        {
            step      = 9,
            priority  = 9,
            bossIndex = 11,
            title     = "Tyrant Velhari",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 668 },
                    kind    = "path",
                    note    = "After defeating ^Socrethar the Eternal^, leave the room to the south. In the next room, click 4x ^Demon Portals^ then kill ^Lord Aram'el^ to open the door. Proceed along the path to ^Tyrant Velhari^.",
                    points  = {
                        { 0.593, 0.572 },
                        { 0.571, 0.619 },
                        { 0.567, 0.806 },
                        { 0.425, 0.808 },
                        { 0.424, 0.702 },
                        { 0.292, 0.694 },
                        { 0.290, 0.558 },
                    },
                },
            },
        },

        -- Fel Lord Zakuun (bossIndex 9; routed tenth in walk order, after
        -- Tyrant Velhari -- the path order does not match the Journal's
        -- encounter order).
        {
            step      = 10,
            priority  = 10,
            bossIndex = 9,
            title     = "Fel Lord Zakuun",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 668 },
                    kind    = "path",
                    note    = "After killing ^Tyrant Velhari^, leave the room to the west and proceed up the path to the north.",
                    points  = {
                        { 0.261, 0.571 },
                        { 0.214, 0.569 },
                        { 0.215, 0.421 },
                        { 0.231, 0.246 },
                        { 0.272, 0.246 },
                        { 0.289, 0.213 },
                        { 0.289, 0.190 },
                    },
                },
                {
                    when    = { mapID = 666 },
                    kind    = "path",
                    note    = "In the next area, you will pass through the spot where you killed ^Shadow-Lord Iskar^ previously. Continue following the path around, eventually reaching ^Fel Lord Zakuun^.",
                    points  = {
                        { 0.456, 0.904 },
                        { 0.456, 0.767 },
                        { 0.734, 0.763 },
                        { 0.734, 0.448 },
                        { 0.610, 0.445 },
                        { 0.548, 0.460 },
                        { 0.499, 0.371 },
                        { 0.496, 0.220 },
                    },
                },
            },
        },

        -- Xhul'horac (bossIndex 10; routed eleventh in walk order, after
        -- Fel Lord Zakuun -- the path order does not match the Journal's
        -- encounter order).
        {
            step      = 11,
            priority  = 11,
            bossIndex = 10,
            title     = "Xhul'horac",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 666 },
                    kind    = "path",
                    note    = "After defeating ^Fel Lord Zakuun^, climb out of this area the way you came, and go all the way east to reach ^Xhul'horac^. Kill trash to start the encounter.",
                    points  = {
                        { 0.500, 0.217 },
                        { 0.499, 0.386 },
                        { 0.569, 0.447 },
                        { 0.802, 0.454 },
                        { 0.869, 0.515 },
                    },
                },
            },
        },

        -- 12. Mannoroth
        {
            step      = 12,
            priority  = 12,
            bossIndex = 12,
            title     = "Mannoroth",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 667 },
                    kind    = "path",
                    note    = "After killing ^Xhul'horac^, head west out of the room the same way you came in.",
                    points  = {
                        { 0.454, 0.505 },
                        { 0.175, 0.509 },
                    },
                },
                {
                    when    = { mapID = 666 },
                    kind    = "path",
                    highlightCircle = true,
                    mapLabel    = "Portal",
                    mapLabelPos = "above",
                    note    = "In the next area, follow the path to click a portal being channeled by ^Archmage Khadgar^.",
                    points  = {
                        { 0.844, 0.509 },
                        { 0.795, 0.440 },
                        { 0.736, 0.437 },
                        { 0.732, 0.765 },
                        { 0.620, 0.765 },
                        { 0.621, 0.604 },
                    },
                },
                {
                    when    = { mapID = 669 },
                    kind    = "poi",
                    noMarker = true,
                    note    = "After taking the portal, you will arrive in ^Destructor's Rise^. On ^Mythic^, do NOT kill the ^Fel Iron Summoners^. Just tag them, and let ^Mannoroth^ kill them or you could bug the encounter. On other difficulties, kill the ^Fel Iron Summoners^ to begin the fight.",
                    points  = {
                        { 0.511, 0.369 },
                    },
                },
            },
        },

        -- 13. Archimonde
        {
            step      = 13,
            priority  = 13,
            bossIndex = 13,
            title     = "Archimonde",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 669 },
                    kind    = "poi",
                    mapLabel    = "Portal",
                    mapLabelPos = "above",
                    note    = "After killing ^Mannoroth^, click the nearby portal.",
                    points  = {
                        { 0.511, 0.369 },
                    },
                },
                {
                    when    = { mapID = 670 },
                    kind    = "poi",
                    noMarker = true,
                    note    = "After taking the teleport, you will land right in front of ^Archimonde^. Kill him!",
                    points  = {
                        { 0.462, 0.515 },
                    },
                },
            },
        },

    },

    skipToBoss = "Mannoroth",


    skipRoute = {

        -- 1. Mannoroth, reached from the entrance via the Destructor's Rise
        --    portal (skips bosses 1-11). Requires the Fel Spire unlock.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 12,
            title     = "Mannoroth",
            requires  = {},
            segments  = {
                {
                    when     = { mapID = 661, subZone = "The Iron Bulwark" },
                    kind     = "poi",
                    mapLabel = "Click Portal",
                    mapLabelPos = "above",
                    note     = "After zoning in, click the portal on the right for ^Destructor's Rise^ to be teleported to ^Mannoroth^.",
                    points   = {
                        { 0.687, 0.389 },
                    },
                },
                {
                    when    = { mapID = 669 },
                    kind    = "poi",
                    note    = "After taking the portal, you will arrive in ^Destructor's Rise^. On ^Mythic^, do NOT kill the ^Fel Iron Summoners^. Just tag them, and let ^Mannoroth^ kill them or you could bug the encounter. On other difficulties, kill the ^Fel Iron Summoners^ to begin the fight.",
                    points  = {
                        { 0.511, 0.369 },
                    },
                },
            },
        },

        -- 2. Archimonde (same as standard run).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 13,
            title     = "Archimonde",
            requires  = { 12 },
            segments  = {
                {
                    when    = { mapID = 669 },
                    kind    = "poi",
                    note    = "After killing ^Mannoroth^, click the nearby portal.",
                    points  = {
                        { 0.511, 0.369 },
                    },
                },
                {
                    when    = { mapID = 670 },
                    kind    = "poi",
                    note    = "After taking the teleport, you will land right in front of ^Archimonde^. Kill him!",
                    points  = {
                        { 0.462, 0.515 },
                    },
                },
            },
        },

    },
}
