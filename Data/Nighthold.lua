-------------------------------------------------------------------------------
-- RetroRuns Data -- The Nighthold
-- Legion, Patch 7.1.5  |  instanceID: 1530  |  journalInstanceID: 786
-------------------------------------------------------------------------------
-- The Nighthold is the third raid of Legion (7.1.5, opened
-- January 17 2017), set in the Nightborne royal palace in Suramar.
-- Entrance is reached via the Sanctum of Order in central Suramar
-- City. Ten boss encounters with mixed topology:
--
--   Linear opening   -- Skorpyron, Chronomatic Anomaly, Trilliax,
--                       Spellblade Aluriel (must be done in order;
--                       killing Aluriel unlocks the main Nighthold
--                       portal as a raid shortcut)
--   Optional middle  -- Tichondrius, Krosus, High Botanist Tel'arn,
--                       Star Augur Etraeus (any order after Aluriel)
--   Linear ending    -- Grand Magistrix Elisande (after all four
--                       middle bosses), then Gul'dan
--
-- Tier: Nighthold drops Tier 19 ("The Nighthold" set), distributed
-- across five bosses by slot -- Tichondrius: Shoulders, Krosus:
-- Chest, Star Augur: Hands, Elisande: Head, Gul'dan: Legs. Unlike
-- Shadowlands+ tier raids, Legion tier pieces drop directly as
-- class-restricted items rather than via cross-class tokens, so
-- `tierSets.tokenSources` is empty and each tier row carries a
-- `classes = { N }` field identifying its class.
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1530] = {
    instanceID        = 1530,
    journalInstanceID = 786,
    name              = "The Nighthold",
    expansion         = "Legion",
    patch             = "7.1.5",

    useStrictActiveSegPicker = true,

    -- Entrance is in Suramar (mapID 680), at the Sanctum Depths
    -- portal inside the Sanctum of Order building in central Suramar
    -- City. Coords (44.2, 59.7) are the actual instance portal,
    -- in-game verified. ATT lists two coords for this raid: this
    -- portal AND (43.3, 62.3) which is the building's ground-level
    -- entrance (subzone "Sanctum of Order"). Third-party guides
    -- (e.g. dungeon.guide) tend to give the building entrance since
    -- it's visually more findable; we point to the portal itself
    -- since that's what the addon's navigation feature should target.
    -- The path inside is: enter the building, head straight down and
    -- turn left onto the portal pad.
    entrance = {
        mapID   = 680,
        x       = 0.442,
        y       = 0.597,
        subZone = "Sanctum Depths",
    },

    -- mapID -> world-map dropdown label.
    -- Pairing pending recorder walk; mapIDs are confirmed but
    -- which label maps to which mapID has not yet been verified
    -- in-game.
    maps = {
        [764] = "The Nightwell",
        [765] = "The Nighthold",
        [766] = "?? unverified",
        [767] = "Shal'Dorei Terrace",
        [768] = "Captain's Quarters",
        [769] = "Astromancer's Rise",
        [770] = "The Nightspire",
        [772] = "The Font of Night",
    },

    tierSets = {
        labels       = { "The Nighthold" },
        tokenSources = {},
    },

    -- Raid skip quest: "The Nighthold: Talisman of the Shal'dorei"
    -- (one quest per difficulty). Skip target: jump from the raid
    -- entrance straight to Grand Magistrix Elisande, bypassing bosses
    -- 1-8 entirely. Earn it by collecting 4 Echoes of Time from
    -- Elisande on the matching difficulty (kill Elisande four times)
    -- and turning in to First Arcanist Thalyssra. The reward is the
    -- Talisman of the Shal'dorei neck, which lets the bearer use the
    -- skip teleporter at the entrance on subsequent runs. Higher
    -- difficulty completions unlock lower difficulties automatically
    -- (Mythic clear lights up Normal + Heroic + Mythic). Quest added
    -- in patch 7.1.0 (2016-10-25), one patch before Nighthold opened.
    skipQuests = {
        normal = 45381,
        heroic = 45382,
        mythic = 45383,
    },

    bosses = {
        {
            index              = 1,
            name               = "Skorpyron",
            journalEncounterID = 1706,
            aliases            = {},
            achievements       = {
                { id = 10678, name = "Cage Rematch", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 140875, slot = "Chest",  name = "Arcanochitin Hauberk",         sources = { [17]=81901, [14]=81898, [15]=81899, [16]=81900 } },
                { id = 140884, slot = "Feet",   name = "Leystone-Toe Kickers",         sources = { [17]=81937, [14]=81934, [15]=81935, [16]=81936 } },
                { id = 140888, slot = "Hands",  name = "Scorpid Handler's Gloves",     sources = { [17]=81953, [14]=81950, [15]=81951, [16]=81952 } },
                { id = 140901, slot = "Head",   name = "Vintage Suramar Nobility Hat", sources = { [17]=82057, [14]=82054, [15]=82055, [16]=82056 } },
                { id = 140862, slot = "Legs",   name = "Gnawed Nightfallen Britches",  sources = { [17]=81851, [14]=81848, [15]=81849, [16]=81850 } },
                { id = 140849, slot = "Waist",  name = "Antiquated Highborne Cinch",   sources = { [17]=81803, [14]=81800, [15]=81801, [16]=81802 } },
                { id = 140902, slot = "Wrist",  name = "Jagged Carapace Wristclamps",  sources = { [17]=81977, [14]=81974, [15]=81975, [16]=81976 } },
                { id = 140876, slot = "Wrist",  name = "Stinger Resistant Bracers",    sources = { [17]=81905, [14]=81902, [15]=81903, [16]=81904 } },
            },
        },
        {
            index              = 2,
            name               = "Chronomatic Anomaly",
            journalEncounterID = 1725,
            aliases            = { "Anomaly" },
            achievements       = {
                { id = 10697, name = "Grand Opening", meta = true, soloable = "kinda" },
            },
            specialLoot = {
                -- Illusion: Chronos. Weapon enchant illusion that adds
                -- a swirling temporal glow to a weapon. Drops from
                -- Chronomatic Anomaly all difficulties (the only non-
                -- gear drop on this boss). Also obtainable from the
                -- Black Market Auction House via Thaumaturge Vashreen
                -- at a 2,500g opening bid.
                { id = 138828, kind = "illusion", name = "Illusion: Chronos", sourceID = 5877 },
            },
            loot = {
                { id = 140848, slot = "Chest",    name = "Robes of Fluctuating Energy", sources = { [17]=81799, [14]=81796, [15]=81797, [16]=81798 } },
                { id = 140860, slot = "Feet",     name = "Stutterstep Treads",          sources = { [17]=81843, [14]=81840, [15]=81841, [16]=81842 } },
                { id = 140879, slot = "Hands",    name = "Gauntlets of Fractured Eons", sources = { [17]=81917, [14]=81914, [15]=81915, [16]=81916 } },
                { id = 140863, slot = "Hands",    name = "Temporally Displaced Gloves", sources = { [17]=81855, [14]=81852, [15]=81853, [16]=81854 } },
                { id = 140903, slot = "Head",     name = "Hood of Fading Opportunity",  sources = { [17]=81981, [14]=81978, [15]=81979, [16]=81980 } },
                { id = 140882, slot = "Legs",     name = "Chrono-Tempered Legplates",   sources = { [17]=81929, [14]=81926, [15]=81927, [16]=81928 } },
                { id = 140853, slot = "Shoulder", name = "Chaos-Scarred Mantle",        sources = { [17]=81819, [14]=81816, [15]=81817, [16]=81818 } },
                { id = 140872, slot = "Shoulder", name = "Pauldrons of Warped Memory",  sources = { [17]=81889, [14]=81886, [15]=81887, [16]=81888 } },
            },
        },
        {
            index              = 3,
            name               = "Trilliax",
            journalEncounterID = 1731,
            aliases            = {},
            achievements       = {
                { id = 10742, name = "Gluten Free", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 138375, slot = "Back",     name = "Cape of Second Sight",              sources = { [17]=81543, [14]=81540, [15]=81541, [16]=81542 } },
                { id = 138373, slot = "Back",     name = "Cloak of Azj'Aqir",                 sources = { [17]=81562, [14]=81559, [15]=81560, [16]=81561 } },
                { id = 138367, slot = "Back",     name = "Cloak of Enveloped Dissonance",     sources = { [17]=81089, [14]=81109, [15]=81110, [16]=81556 } },
                { id = 138365, slot = "Back",     name = "Cloak of Everburning Knowledge",    sources = { [17]=81121, [14]=81107, [15]=81419, [16]=80174 } },
                { id = 138372, slot = "Back",     name = "Cloak of Shackled Elements",        sources = { [17]=81539, [14]=81536, [15]=81537, [16]=81538 } },
                { id = 138366, slot = "Back",     name = "Cloak of the Astral Warden",        sources = { [17]=81558, [14]=80486, [15]=81557, [16]=81095 } },
                { id = 138371, slot = "Back",     name = "Doomblade Shadowwrap",              sources = { [17]=81555, [14]=83008, [15]=83009, [16]=83010 } },
                { id = 138364, slot = "Back",     name = "Dreadwyrm Greatcloak",              sources = { [17]=81068, [14]=81550, [15]=81551, [16]=81067 } },
                { id = 138368, slot = "Back",     name = "Eagletalon Cloak",                  sources = { [17]=81079, [14]=81552, [15]=81553, [16]=81554 } },
                { id = 138374, slot = "Back",     name = "Greatcloak of the Obsidian Aspect", sources = { [17]=81055, [14]=81544, [15]=81545, [16]=81546 } },
                { id = 138369, slot = "Back",     name = "Greatmantle of the Highlord",       sources = { [17]=81549, [14]=81547, [15]=81061, [16]=81548 } },
                { id = 138370, slot = "Back",     name = "Purifier's Drape",                  sources = { [17]=81106, [14]=81563, [15]=81564, [16]=81565 } },
                { id = 140865, slot = "Chest",    name = "Tunic of Unwavering Devotion",      sources = { [17]=82050, [14]=81860, [15]=82049, [16]=81861 } },
                { id = 140904, slot = "Feet",     name = "Immaculately Polished Boots",       sources = { [17]=81985, [14]=81982, [15]=81983, [16]=81984 } },
                { id = 140854, slot = "Feet",     name = "Perpetually Muddy Sandals",         sources = { [17]=81823, [14]=81820, [15]=81821, [16]=81822 } },
                { id = 140869, slot = "Hands",    name = "Sterilizer's Insulated Gauntlets",  sources = { [17]=81877, [14]=81874, [15]=81875, [16]=81876 } },
                { id = 140851, slot = "Head",     name = "Nighthold Custodian's Hood",        sources = { [17]=81811, [14]=81808, [15]=81809, [16]=81810 } },
                { id = 140871, slot = "Legs",     name = "Pertinacious Legplates",            sources = { [17]=81885, [14]=81882, [15]=81883, [16]=81884 } },
                { id = 140858, slot = "Waist",    name = "Cake Carrier's Girdle",             sources = { [17]=81835, [14]=81832, [15]=81833, [16]=81834 } },
                { id = 140880, slot = "Waist",    name = "Gilded Nightborne Waistplate",      sources = { [17]=81921, [14]=81918, [15]=81919, [16]=81920 } },
            },
        },
        {
            index              = 4,
            name               = "Spellblade Aluriel",
            journalEncounterID = 1751,
            aliases            = { "Aluriel" },
            achievements       = {
                { id = 10817, name = "A Change In Scenery", meta = true, soloable = "yes" },
            },
            specialLoot = {
                { id = 256682, kind = "decor", decorID = 11283, name = "Magistrix's Garden Fountain" },
            },
            loot = {
                { id = 140877, slot = "Chest",  name = "Captain's Parade Breastplate",    sources = { [17]=81909, [14]=81906, [15]=81907, [16]=81908 } },
                { id = 140867, slot = "Feet",   name = "Sabatons of Burning Steps",       sources = { [17]=81869, [14]=81866, [15]=81867, [16]=81868 } },
                { id = 140905, slot = "Hands",  name = "Gloves of Synchronous Elements",  sources = { [17]=81989, [14]=81986, [15]=81987, [16]=81988 } },
                { id = 140866, slot = "Head",   name = "Nightborne Battle-Magus Hood",    sources = { [17]=81865, [14]=81862, [15]=81863, [16]=81864 } },
                { id = 140852, slot = "Legs",   name = "Master Warmage's Leggings",       sources = { [17]=81815, [14]=81812, [15]=81813, [16]=81814 } },
                { id = 140868, slot = "Waist",  name = "Emblazoned Duskwatch Belt",       sources = { [17]=81873, [14]=81870, [15]=81871, [16]=81872 } },
                { id = 140850, slot = "Wrist",  name = "Bracers of Harnessed Flame",      sources = { [17]=81807, [14]=81804, [15]=81805, [16]=81806 } },
                { id = 140878, slot = "Wrist",  name = "Duskwatch Plate Bracers",         sources = { [17]=81913, [14]=81910, [15]=81911, [16]=81912 } },
            },
        },
        {
            index              = 5,
            name               = "Tichondrius",
            journalEncounterID = 1762,
            aliases            = {},
            achievements       = {
                { id = 10704, name = "Not For You", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 140855, slot = "Back",     name = "Dreadlord's Tattered Wingcover",        sources = { [17]=81827, [14]=81824, [15]=81825, [16]=81826 } },
                -- Tier 19 Shoulders (one per class).
                { id = 138321, slot = "Shoulder", name = "Mantle of Everburning Knowledge",       sources = { [17]=81120, [14]=79805, [15]=79806, [16]=79807 }, classes = { 8 } },
                { id = 138322, slot = "Shoulder", name = "Purifier's Mantle",                     sources = { [17]=81105, [14]=79808, [15]=79809, [16]=79810 }, classes = { 5 } },
                { id = 138323, slot = "Shoulder", name = "Pauldrons of Azj'Aqir",                 sources = { [17]=81100, [14]=79811, [15]=79812, [16]=79813 }, classes = { 9 } },
                { id = 138336, slot = "Shoulder", name = "Mantle of the Astral Warden",           sources = { [17]=81094, [14]=79850, [15]=79851, [16]=79852 }, classes = { 11 } },
                { id = 138337, slot = "Shoulder", name = "Pauldrons of Enveloped Dissonance",     sources = { [17]=81088, [14]=79853, [15]=79854, [16]=79855 }, classes = { 10 } },
                { id = 138338, slot = "Shoulder", name = "Doomblade Spaulders",                   sources = { [17]=81084, [14]=79856, [15]=79857, [16]=79858 }, classes = { 4 } },
                { id = 138347, slot = "Shoulder", name = "Eagletalon Spaulders",                  sources = { [17]=81078, [14]=79883, [15]=79884, [16]=79885 }, classes = { 3 } },
                { id = 138348, slot = "Shoulder", name = "Pauldrons of Shackled Elements",        sources = { [17]=81073, [14]=79886, [15]=79887, [16]=79888 }, classes = { 7 } },
                { id = 138361, slot = "Shoulder", name = "Dreadwyrm Shoulderguards",              sources = { [17]=81066, [14]=79925, [15]=79926, [16]=79927 }, classes = { 6 } },
                { id = 138362, slot = "Shoulder", name = "Pauldrons of the Highlord",             sources = { [17]=81060, [14]=79928, [15]=79929, [16]=79930 }, classes = { 2 } },
                { id = 138363, slot = "Shoulder", name = "Shoulderplates of the Obsidian Aspect", sources = { [17]=81054, [14]=79931, [15]=79932, [16]=79933 }, classes = { 1 } },
                { id = 138380, slot = "Shoulder", name = "Shoulderguards of Second Sight",        sources = { [17]=81115, [14]=80187, [15]=80188, [16]=80189 }, classes = { 12 } },
                { id = 140859, slot = "Waist",    name = "Girdle of Nefarious Strategy",          sources = { [17]=81839, [14]=81836, [15]=81837, [16]=81838 } },
                { id = 140892, slot = "Waist",    name = "Goresmeared Abyssal Waistplate",        sources = { [17]=81969, [14]=81966, [15]=81967, [16]=81968 } },
            },
        },
        {
            index              = 6,
            name               = "Krosus",
            journalEncounterID = 1713,
            aliases            = {},
            achievements       = {
                { id = 10575, name = "Burning Bridges", meta = true, soloable = "yes" },
            },
            loot = {
                -- Tier 19 Chest (one per class).
                { id = 138318, slot = "Chest",  name = "Robe of Everburning Knowledge",     sources = { [17]=81119, [14]=79796, [15]=79797, [16]=79798 }, classes = { 8 } },
                { id = 138319, slot = "Chest",  name = "Purifier's Cassock",                sources = { [17]=81104, [14]=79799, [15]=79800, [16]=79801 }, classes = { 5 } },
                { id = 138320, slot = "Chest",  name = "Finery of Azj'Aqir",                sources = { [17]=81099, [14]=79802, [15]=79803, [16]=79804 }, classes = { 9 } },
                { id = 138324, slot = "Chest",  name = "Robe of the Astral Warden",         sources = { [17]=81090, [14]=79814, [15]=79815, [16]=79816 }, classes = { 11 } },
                { id = 138325, slot = "Chest",  name = "Tunic of Enveloped Dissonance",     sources = { [17]=81108, [14]=79817, [15]=79818, [16]=79819 }, classes = { 10 } },
                { id = 138326, slot = "Chest",  name = "Doomblade Tunic",                   sources = { [17]=81080, [14]=79820, [15]=79821, [16]=79822 }, classes = { 4 } },
                { id = 138339, slot = "Chest",  name = "Eagletalon Tunic",                  sources = { [17]=81074, [14]=79859, [15]=79860, [16]=79861 }, classes = { 3 } },
                { id = 138346, slot = "Chest",  name = "Raiment of Shackled Elements",      sources = { [17]=81072, [14]=79880, [15]=79881, [16]=79882 }, classes = { 7 } },
                { id = 138349, slot = "Chest",  name = "Dreadwyrm Breastplate",             sources = { [17]=81062, [14]=79889, [15]=79890, [16]=79891 }, classes = { 6 } },
                { id = 138350, slot = "Chest",  name = "Breastplate of the Highlord",       sources = { [17]=81056, [14]=79892, [15]=79893, [16]=79894 }, classes = { 2 } },
                { id = 138351, slot = "Chest",  name = "Chestplate of the Obsidian Aspect", sources = { [17]=81050, [14]=79895, [15]=79896, [16]=79897 }, classes = { 1 } },
                { id = 138376, slot = "Chest",  name = "Tunic of Second Sight",             sources = { [17]=81111, [14]=80175, [15]=80176, [16]=80177 }, classes = { 12 } },
                { id = 140907, slot = "Hands",  name = "Bridgebreaker Gauntlets",           sources = { [17]=81993, [14]=81990, [15]=81991, [16]=81992 } },
                { id = 140870, slot = "Head",   name = "Architect's Coif of Despair",       sources = { [17]=81881, [14]=81878, [15]=81879, [16]=81880 } },
                { id = 140887, slot = "Waist",  name = "Man'ari Skullbuckled Cinch",        sources = { [17]=81949, [14]=81946, [15]=81947, [16]=81948 } },
                { id = 140857, slot = "Wrist",  name = "Well-Flattened Wristguards",        sources = { [17]=81831, [14]=81828, [15]=81829, [16]=81830 } },
            },
        },
        {
            index              = 7,
            name               = "High Botanist Tel'arn",
            journalEncounterID = 1761,
            aliases            = { "Tel'arn" },
            achievements       = {
                { id = 10754, name = "Fruit of All Evil", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 140861, slot = "Feet",     name = "Grove-Tender's Moccasins",      sources = { [17]=81847, [14]=81844, [15]=81845, [16]=81846 } },
                { id = 140873, slot = "Feet",     name = "Shal'dorei Weedstompers",       sources = { [17]=81893, [14]=81890, [15]=81891, [16]=81892 } },
                { id = 140881, slot = "Head",     name = "Eventide Casque",               sources = { [17]=81925, [14]=81922, [15]=81923, [16]=81924 } },
                { id = 140908, slot = "Legs",     name = "Trousers of Cultivation",       sources = { [17]=81997, [14]=81994, [15]=81995, [16]=81996 } },
                { id = 140883, slot = "Shoulder", name = "Shoulderguard of the Eclipse",  sources = { [17]=81933, [14]=81930, [15]=81931, [16]=81932 } },
                { id = 140874, slot = "Wrist",    name = "Thistle-Proof Thorngrabbers",   sources = { [17]=81897, [14]=81894, [15]=81895, [16]=81896 } },
                { id = 140886, slot = "Wrist",    name = "Woven Lasher Tendril Bracers",  sources = { [17]=81945, [14]=81942, [15]=81943, [16]=81944 } },
            },
        },
        {
            index              = 8,
            name               = "Star Augur Etraeus",
            journalEncounterID = 1732,
            aliases            = { "Star Augur", "Etraeus" },
            achievements       = {
                { id = 10851, name = "Elementalry!", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 140909, slot = "Back",     name = "Astromancer's Greatcloak",         sources = { [17]=82001, [14]=81998, [15]=81999, [16]=82000 } },
                { id = 140891, slot = "Feet",     name = "Sabatons of Unchanging Fate",      sources = { [17]=81965, [14]=81962, [15]=81963, [16]=81964 } },
                { id = 140885, slot = "Feet",     name = "Treads of Galactic Odyssey",       sources = { [17]=81941, [14]=81938, [15]=81939, [16]=81940 } },
                -- Tier 19 Hands (one per class).
                { id = 138309, slot = "Hands",    name = "Gloves of Everburning Knowledge",  sources = { [17]=81116, [14]=79769, [15]=79770, [16]=79771 }, classes = { 8 } },
                { id = 138310, slot = "Hands",    name = "Purifier's Gloves",                sources = { [17]=81101, [14]=79772, [15]=79773, [16]=79774 }, classes = { 5 } },
                { id = 138311, slot = "Hands",    name = "Clutch of Azj'Aqir",               sources = { [17]=81096, [14]=79775, [15]=79776, [16]=79777 }, classes = { 9 } },
                { id = 138327, slot = "Hands",    name = "Gloves of the Astral Warden",      sources = { [17]=81091, [14]=79823, [15]=79824, [16]=79825 }, classes = { 11 } },
                { id = 138328, slot = "Hands",    name = "Gloves of Enveloped Dissonance",   sources = { [17]=81085, [14]=79826, [15]=79827, [16]=79828 }, classes = { 10 } },
                { id = 138329, slot = "Hands",    name = "Doomblade Gauntlets",              sources = { [17]=81081, [14]=79829, [15]=79830, [16]=79831 }, classes = { 4 } },
                { id = 138340, slot = "Hands",    name = "Eagletalon Gauntlets",             sources = { [17]=81075, [14]=79862, [15]=79863, [16]=79864 }, classes = { 3 } },
                { id = 138341, slot = "Hands",    name = "Gauntlets of Shackled Elements",   sources = { [17]=81069, [14]=79865, [15]=79866, [16]=79867 }, classes = { 7 } },
                { id = 138352, slot = "Hands",    name = "Dreadwyrm Gauntlets",              sources = { [17]=81063, [14]=79898, [15]=79899, [16]=79900 }, classes = { 6 } },
                { id = 138353, slot = "Hands",    name = "Gauntlets of the Highlord",        sources = { [17]=81057, [14]=79901, [15]=79902, [16]=79903 }, classes = { 2 } },
                { id = 138354, slot = "Hands",    name = "Gauntlets of the Obsidian Aspect", sources = { [17]=81051, [14]=79904, [15]=79905, [16]=79906 }, classes = { 1 } },
                { id = 138377, slot = "Hands",    name = "Gloves of Second Sight",           sources = { [17]=81112, [14]=80178, [15]=80179, [16]=80180 }, classes = { 12 } },
                { id = 140864, slot = "Shoulder", name = "Mantle of the Torn Sky",           sources = { [17]=81859, [14]=81856, [15]=81857, [16]=81858 } },
            },
        },
        {
            index              = 9,
            name               = "Grand Magistrix Elisande",
            journalEncounterID = 1743,
            aliases            = { "Elisande" },
            achievements       = {
                { id = 10699, name = "Infinitesimal", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 140910, slot = "Back",     name = "Cloak of Temporal Recalibration",   sources = { [17]=82005, [14]=82002, [15]=82003, [16]=82004 } },
                -- Tier 19 Head (one per class).
                { id = 138312, slot = "Head",     name = "Hood of Everburning Knowledge",     sources = { [17]=81117, [14]=79778, [15]=79779, [16]=79780 }, classes = { 8 } },
                { id = 138313, slot = "Head",     name = "Purifier's Gorget",                 sources = { [17]=81102, [14]=79781, [15]=79782, [16]=79783 }, classes = { 5 } },
                { id = 138314, slot = "Head",     name = "Eyes of Azj'Aqir",                  sources = { [17]=81097, [14]=79784, [15]=79785, [16]=79786 }, classes = { 9 } },
                { id = 138330, slot = "Head",     name = "Hood of the Astral Warden",         sources = { [17]=81092, [14]=79832, [15]=79833, [16]=79834 }, classes = { 11 } },
                { id = 138331, slot = "Head",     name = "Hood of Enveloped Dissonance",      sources = { [17]=81086, [14]=79835, [15]=79836, [16]=79837 }, classes = { 10 } },
                { id = 138332, slot = "Head",     name = "Doomblade Cowl",                    sources = { [17]=81082, [14]=79838, [15]=79839, [16]=79840 }, classes = { 4 } },
                { id = 138342, slot = "Head",     name = "Eagletalon Cowl",                   sources = { [17]=81076, [14]=79868, [15]=79869, [16]=79870 }, classes = { 3 } },
                { id = 138343, slot = "Head",     name = "Helm of Shackled Elements",         sources = { [17]=81070, [14]=79871, [15]=79872, [16]=79873 }, classes = { 7 } },
                { id = 138355, slot = "Head",     name = "Dreadwyrm Crown",                   sources = { [17]=81064, [14]=79907, [15]=79908, [16]=79909 }, classes = { 6 } },
                { id = 138356, slot = "Head",     name = "Helmet of the Highlord",            sources = { [17]=81058, [14]=79910, [15]=79911, [16]=79912 }, classes = { 2 } },
                { id = 138357, slot = "Head",     name = "Warhelm of the Obsidian Aspect",    sources = { [17]=81052, [14]=79913, [15]=79914, [16]=79915 }, classes = { 1 } },
                { id = 138378, slot = "Head",     name = "Mask of Second Sight",              sources = { [17]=81113, [14]=80181, [15]=80182, [16]=80183 }, classes = { 12 } },
                { id = 140911, slot = "Shoulder", name = "Mantle of Prestidigitation",        sources = { [17]=82009, [14]=82006, [15]=82007, [16]=82008 } },
                { id = 140890, slot = "Waist",    name = "Belt of Celestial Alignment",       sources = { [17]=81961, [14]=81958, [15]=81959, [16]=81960 } },
                { id = 140912, slot = "Waist",    name = "Waistplate of Fractured Realities", sources = { [17]=82013, [14]=82010, [15]=82011, [16]=82012 } },
                { id = 140889, slot = "Wrist",    name = "Bracers of Impossible Choices",     sources = { [17]=81957, [14]=81954, [15]=81955, [16]=81956 } },
                { id = 140893, slot = "Wrist",    name = "Eternally Recurring Bracers",       sources = { [17]=81973, [14]=81970, [15]=81971, [16]=81972 } },
            },
        },
        {
            index              = 10,
            name               = "Gul'dan",
            journalEncounterID = 1737,
            aliases            = {},
            achievements       = {
                { id = 10696, name = "I've Got My Eyes On You", meta = true, soloable = "kinda" },
            },
            specialLoot = {
                -- The two toys below are NOT listed in the in-game
                -- Encounter Journal -- Blizzard never tagged them in
                -- the EJ data. Both are real drops from Gul'dan
                -- though, sourced via ATT cross-reference and
                -- confirmed by Wowhead/Wowpedia. The Golden
                -- Hearthstone Card was being farmed during the July
                -- 2025 Collector's Bounty event (Icy Veins coverage),
                -- so it is current as of this writing. Same harvester
                -- gap pattern as Illusion: Chronos on Chronomatic
                -- Anomaly and most other non-gear collectibles.
                { id = 119211, kind = "toy", name = "Golden Hearthstone Card: Lord Jaraxxus" },
                { id = 143544, kind = "toy", name = "Skull of Corruption", classes = { 12 } },
                { id = 137575, kind = "mount", name = "Fiendish Hellfire Core" },
                { id = 137574, kind = "mount", name = "Living Infernal Core" },
            },
            loot = {
                { id = 140913, slot = "Chest",    name = "Breastplate of the Remembered King", sources = { [17]=82017, [14]=82014, [15]=82015, [16]=82016 } },
                { id = 140914, slot = "Feet",     name = "Outcast Wanderer's Footrags",        sources = { [17]=82021, [14]=82018, [15]=82019, [16]=82020 } },
                -- Tier 19 Legs (one per class).
                { id = 138315, slot = "Legs",     name = "Leggings of Everburning Knowledge",  sources = { [17]=81118, [14]=79787, [15]=79788, [16]=79789 }, classes = { 8 } },
                { id = 138316, slot = "Legs",     name = "Purifier's Leggings",                sources = { [17]=81103, [14]=79790, [15]=79791, [16]=79792 }, classes = { 5 } },
                { id = 138317, slot = "Legs",     name = "Leggings of Azj'Aqir",               sources = { [17]=81098, [14]=79793, [15]=79794, [16]=79795 }, classes = { 9 } },
                { id = 138333, slot = "Legs",     name = "Leggings of the Astral Warden",      sources = { [17]=81093, [14]=79841, [15]=79842, [16]=79843 }, classes = { 11 } },
                { id = 138334, slot = "Legs",     name = "Leggings of Enveloped Dissonance",   sources = { [17]=81087, [14]=79844, [15]=79845, [16]=79846 }, classes = { 10 } },
                { id = 138335, slot = "Legs",     name = "Doomblade Pants",                    sources = { [17]=81083, [14]=79847, [15]=79848, [16]=79849 }, classes = { 4 } },
                { id = 138344, slot = "Legs",     name = "Eagletalon Legchains",               sources = { [17]=81077, [14]=79874, [15]=79875, [16]=79876 }, classes = { 3 } },
                { id = 138345, slot = "Legs",     name = "Leggings of Shackled Elements",      sources = { [17]=81071, [14]=79877, [15]=79878, [16]=79879 }, classes = { 7 } },
                { id = 138358, slot = "Legs",     name = "Dreadwyrm Legplates",                sources = { [17]=81065, [14]=79916, [15]=79917, [16]=79918 }, classes = { 6 } },
                { id = 138359, slot = "Legs",     name = "Legplates of the Highlord",          sources = { [17]=81059, [14]=79919, [15]=79920, [16]=79921 }, classes = { 2 } },
                { id = 138360, slot = "Legs",     name = "Legplates of the Obsidian Aspect",   sources = { [17]=81053, [14]=79922, [15]=79923, [16]=79924 }, classes = { 1 } },
                { id = 138379, slot = "Legs",     name = "Legwraps of Second Sight",           sources = { [17]=81114, [14]=80184, [15]=80185, [16]=80186 }, classes = { 12 } },
                { id = 140917, slot = "Shoulder", name = "Netherbranded Shoulderpads",         sources = { [17]=82025, [14]=82022, [15]=82023, [16]=82024 } },
                { id = 140919, slot = "Waist",    name = "High Shadow Councilor's Wrap",       sources = { [17]=82029, [14]=82026, [15]=82027, [16]=82028 } },
            },
        },
    },

    routing = {

        -- 1. Skorpyron
        -- Single segment on mapID 764 (sub-zone label "Arcing Depths"
        -- per recorder; pending dropdown walk to confirm). Path runs
        -- from the zone-in spawn, forward then bears left to reach
        -- Skorpyron.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Skorpyron",
            requires  = {},
            segments  = {
                {
                    mapID   = 764,
                    kind    = "path",
                    subZone = "Arcing Depths",
                    note    = "After zoning in, move forward and take your first left to reach Skorpyron.",
                    points  = {
                        { 0.255, 0.886 },
                        { 0.313, 0.796 },
                        { 0.262, 0.722 },
                        { 0.283, 0.661 },
                        { 0.300, 0.638 },
                    },
                },
            },
        },

        -- 2. Chronomatic Anomaly
        -- Single segment on mapID 764 (sub-zone label "Crystal Breach"
        -- per recorder; pending dropdown walk to confirm). After
        -- Skorpyron, raid takes the new southeast exit up the ramp.
        -- Trash must be cleared en route to open the door to CA.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Chronomatic Anomaly",
            requires  = { 1 },
            segments  = {
                {
                    mapID   = 764,
                    kind    = "path",
                    subZone = "Crystal Breach",
                    note    = "After defeating Skorpyron, take the new southeast exit up the ramp and make your way towards Chronomatic Anomaly. Kill trash on the way to open the door.",
                    points  = {
                        { 0.321, 0.647 },
                        { 0.367, 0.719 },
                        { 0.510, 0.507 },
                    },
                },
            },
        },

        -- 3. Trilliax
        -- Single segment on mapID 764 (sub-zone label "The Nightwell"
        -- per recorder; pending dropdown walk to confirm). Path runs
        -- from CA's room up the stairwell on the northwest side.
        -- Slimes in the boss room must be cleared to engage Trilliax.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Trilliax",
            requires  = { 2 },
            segments  = {
                {
                    mapID   = 764,
                    kind    = "path",
                    subZone = "The Nightwell",
                    note    = "After killing Chronomatic Anomaly, proceed up the stairwell at the northwest side of the room, and clear slimes in the boss room to engage Trilliax.",
                    points  = {
                        { 0.504, 0.437 },
                        { 0.507, 0.334 },
                        { 0.438, 0.232 },
                    },
                },
            },
        },

        -- 4. Spellblade Aluriel
        -- Three-segment approach crossing mapIDs 764 -> 765 -> 766.
        -- Seg 1: spiral staircase from Trilliax's room (mapID 764,
        --   recorder reported no subZone label at the stairs).
        -- Seg 2: gate at top of stairs, around the path to another
        --   set of stairs (mapID 765, label "Arcing Depths" per
        --   recorder -- pending dropdown walk to confirm; same label
        --   the recorder gave Skorpyron's mapID-764 room earlier in
        --   the run, which may or may not be a coincidence).
        -- Seg 3: into the main courtyard where Aluriel patrols (mapID
        --   766, no subZone label captured).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Spellblade Aluriel",
            requires  = { 3 },
            segments  = {
                {
                    mapID   = 764,
                    kind    = "path",
                    note    = "After defeating Trilliax, take the northwest exit out of the room and make your way up the spiral staircase.",
                    points  = {
                        { 0.386, 0.152 },
                        { 0.367, 0.132 },
                        { 0.356, 0.174 },
                        { 0.356, 0.206 },
                        { 0.365, 0.243 },
                        { 0.379, 0.267 },
                        { 0.401, 0.279 },
                    },
                },
                {
                    mapID   = 765,
                    kind    = "path",
                    subZone = "Arcing Depths",
                    note    = "When you reach the top of the stairwell, follow the path around and find a steep ramp you need to walk up. At the top of this ramp, open the gate to reach the map exit labeled The Nighthold.",
                    points  = {
                        { 0.436, 0.548 },
                        { 0.458, 0.621 },
                        { 0.528, 0.662 },
                        { 0.571, 0.652 },
                        { 0.618, 0.530 },
                        { 0.676, 0.530 },
                        { 0.677, 0.308 },
                        { 0.446, 0.314 },
                    },
                },
                {
                    mapID   = 766,
                    kind    = "path",
                    note    = "Continue ahead into the main courtyard to find Spellblade Aluriel.",
                    points  = {
                        { 0.255, 0.186 },
                        { 0.335, 0.313 },
                    },
                },
            },
        },

        -- 8. Star Augur Etraeus  (DAG middle, sibling step with
        --    Tichondrius, Krosus, Tel'arn -- all gated by Aluriel.)
        -- Two-segment approach crossing mapIDs 766 -> 769.
        -- Seg 1: northeast building from Aluriel's courtyard (mapID
        --   766, no subZone label captured -- same situation as
        --   Aluriel's seg 3 on this map).
        -- Seg 2: through the door, up the stairs to Star Augur
        --   (mapID 769, label "Astromancer's Rise" per recorder --
        --   pending dropdown walk to confirm).
        {
            step      = 5,
            priority  = 1,
            bossIndex = 8,
            title     = "Star Augur Etraeus",
            requires  = { 4 },
            segments  = {
                {
                    mapID   = 766,
                    kind    = "path",
                    note    = "After defeating Aluriel Spellblade, take the path into the building to the northeast, and clear trash as you approach the map exit labeled Astromancer's Rise.",
                    points  = {
                        { 0.404, 0.361 },
                        { 0.414, 0.274 },
                        { 0.448, 0.226 },
                        { 0.463, 0.229 },
                    },
                },
                {
                    mapID   = 769,
                    kind    = "path",
                    subZone = "Astromancer's Rise",
                    note    = "Once the door opens, proceed through it and climb some stairs to reach Star Augur Etraeus.",
                    points  = {
                        { 0.516, 0.522 },
                        { 0.550, 0.477 },
                        { 0.390, 0.242 },
                    },
                },
            },
        },

        -- 7. High Botanist Tel'arn  (DAG middle sibling at step 5.)
        -- Three-segment approach 769 -> 766 -> 767. The Star Augur
        -- ENCOUNTER_END auto-stamp surfaced a new label for mapID 769:
        -- "Eternal Observatory" (Star Augur's fight room, distinct
        -- from the "Astromancer's Rise" approach label on the same
        -- mapID). Seg 2's subZone "Astromancer's Rise" on mapID 766
        -- is the second sub-zone label echo we've seen across
        -- mapIDs (Arcing Depths was the first, on 764/765).
        {
            step      = 5,
            priority  = 2,
            bossIndex = 7,
            title     = "High Botanist Tel'arn",
            requires  = { 4 },
            segments  = {
                {
                    mapID   = 769,
                    kind    = "path",
                    subZone = "Astromancer's Rise",
                    note    = "After defeating Star Augur Etraeus, backtrack down the stairs to return to Astromancer's Rise.",
                    points  = {
                        { 0.393, 0.243 },
                        { 0.549, 0.477 },
                        { 0.503, 0.542 },
                    },
                },
                {
                    mapID   = 766,
                    kind    = "path",
                    subZone = "Astromancer's Rise",
                    note    = "Back on the main level of Astromancer's Rise, take the northeast exit from the building towards the map exit labeled Shal'Dorei Terrace.",
                    points  = {
                        { 0.455, 0.211 },
                        { 0.534, 0.093 },
                    },
                },
                {
                    mapID   = 767,
                    kind    = "path",
                    subZone = "Shal'dorei Terrace",
                    note    = "Once you reach Shal'dorei Terrace, make your way over to High Botanist Tel'arn to begin the encounter.",
                    points  = {
                        { 0.267, 0.516 },
                        { 0.351, 0.392 },
                        { 0.415, 0.261 },
                        { 0.487, 0.324 },
                        { 0.509, 0.391 },
                        { 0.623, 0.392 },
                    },
                },
            },
        },

        -- 5. Tichondrius  (DAG middle sibling at step 5.)
        -- Three-segment approach 767 -> 766 -> 768. First time mapID
        -- 768 surfaces in the route; recorder captured no subZone
        -- label there (pending dropdown walk to resolve).
        -- The "Captain's Quarters" mentioned in seg 2's note is an
        -- in-game place name the recorder did not assign as a
        -- subZone label -- it stays as navigation prose.
        {
            step      = 5,
            priority  = 3,
            bossIndex = 5,
            title     = "Tichondrius",
            requires  = { 4 },
            segments  = {
                {
                    mapID   = 767,
                    kind    = "path",
                    subZone = "Shal'dorei Terrace",
                    note    = "After defeating High Botanist Tel'arn, backtrack towards the map exit labeled The Nighthold.",
                    points  = {
                        { 0.623, 0.390 },
                        { 0.515, 0.395 },
                        { 0.438, 0.424 },
                        { 0.354, 0.403 },
                        { 0.253, 0.547 },
                    },
                },
                {
                    mapID   = 766,
                    kind    = "path",
                    subZone = "Astromancer's Rise",
                    note    = "Follow the path back out to the main courtyard, and make your way to the Captain's Quarters entrance on the southwest corner of the map. Inside the Captain's Quarters, take your first right to go up a short stairwell.",
                    points  = {
                        { 0.531, 0.097 },
                        { 0.413, 0.277 },
                        { 0.363, 0.289 },
                        { 0.325, 0.324 },
                        { 0.301, 0.447 },
                        { 0.280, 0.476 },
                        { 0.255, 0.477 },
                        { 0.246, 0.464 },
                    },
                },
                {
                    mapID   = 768,
                    kind    = "path",
                    note    = "Continue up and around the stairwell until you reach Tichondrius.",
                    points  = {
                        { 0.373, 0.261 },
                        { 0.252, 0.428 },
                        { 0.214, 0.363 },
                        { 0.254, 0.304 },
                        { 0.280, 0.337 },
                        { 0.255, 0.363 },
                        { 0.302, 0.448 },
                        { 0.267, 0.589 },
                    },
                },
            },
        },

        -- 6. Krosus  (DAG middle sibling at step 5, closes the wing.)
        -- Two-segment approach 768 -> 766. The recorder pinned a
        -- label "Captain's Quarters" on mapID 768 this time (Tich
        -- seg 3 captured no label there), confirming that's the
        -- in-game name for the interior. Seg 2 on mapID 766 also
        -- surfaces "Captain's Quarters" -- a NEW label on this mapID
        -- (Aluriel/Tel'arn/Tich each captured a different label for
        -- 766). Confirms 766 hosts multiple subzones at different
        -- player positions; dropdown walk will disambiguate.
        {
            step      = 5,
            priority  = 4,
            bossIndex = 6,
            title     = "Krosus",
            requires  = { 4 },
            segments  = {
                {
                    mapID   = 768,
                    kind    = "path",
                    subZone = "Captain's Quarters",
                    note    = "After killing Tichondrius, backtrack the way you came to return to the main courtyard.",
                    points  = {
                        { 0.270, 0.601 },
                        { 0.286, 0.415 },
                        { 0.258, 0.367 },
                        { 0.281, 0.338 },
                        { 0.259, 0.304 },
                        { 0.215, 0.370 },
                        { 0.248, 0.424 },
                        { 0.390, 0.255 },
                        { 0.408, 0.289 },
                    },
                },
                {
                    mapID   = 766,
                    kind    = "path",
                    subZone = "Captain's Quarters",
                    note    = "After returning to the main courtyard, follow the path all the way to the far southeast of the map to reach Krosus.",
                    points  = {
                        { 0.280, 0.477 },
                        { 0.320, 0.429 },
                        { 0.408, 0.637 },
                        { 0.475, 0.657 },
                        { 0.544, 0.620 },
                        { 0.719, 0.888 },
                    },
                },
            },
        },

        -- 9. Grand Magistrix Elisande  (starts the final linear
        --    ascent through The Nightspire.)
        -- Two-segment approach: 766 -> 770.
        -- Seg 1: backtrack from Krosus across the courtyard to the
        --   Suramar Portal, then on through the post-teleport landing
        --   area up to the boss room entrance. The teleport itself
        --   produces no client-visible signal (no mapID change, no
        --   control loss, no spell cast on the player); the landing
        --   area is also on mapID 766, so the picker has no way to
        --   distinguish "approaching the portal" from "after landing."
        --   The two phases ship as one seg with a combined note that
        --   walks the player through both halves.
        -- Seg 2: inside The Nightspire, clear trash to engage
        --   Elisande (mapID 770, label "The Nightspire").
        {
            step      = 6,
            priority  = 1,
            bossIndex = 9,
            title     = "Grand Magistrix Elisande",
            requires  = { 5, 6, 7, 8 },
            segments  = {
                {
                    mapID   = 766,
                    kind    = "path",
                    subZone = "The Shattered Walkway",
                    note    = "After defeating Krosus, backtrack up to the main courtyard and click the portal to teleport to The Nightspire. After landing, proceed ahead into the boss room.",
                    points  = {
                        { 0.718, 0.887 },
                        { 0.491, 0.542 },
                        { 0.497, 0.481 },
                    },
                },
                {
                    mapID   = 770,
                    kind    = "path",
                    subZone = "The Nightspire",
                    note    = "Inside The Nightspire, clear trash around the room to begin the encounter with Grand Magistrix Elisande.",
                    points  = {
                        { 0.620, 0.346 },
                        { 0.486, 0.444 },
                    },
                },
            },
        },

        -- 10. Gul'dan  (final encounter; reached via second teleport
        --     to "Font of Night" from outside Elisande's room.)
        -- Two segments, both at the top of the Nightspire tower:
        -- Seg 1: short walk on mapID 770 to the teleporter.
        -- Seg 2: kind="poi" not "path" -- Gul'dan is right at the
        --   teleport destination, so a single waypoint near the boss
        --   is sufficient and no traversal line is drawn (mapID 772,
        --   label "The Font of Night").
        -- Note: mapID 771 never surfaced in any routing segment;
        --   either an unused tower floor or a non-routing connector.
        --   Still in maps[] for the dropdown walk to resolve.
        {
            step      = 7,
            priority  = 1,
            bossIndex = 10,
            title     = "Gul'dan",
            requires  = { 9 },
            segments  = {
                {
                    mapID   = 770,
                    kind    = "path",
                    subZone = "The Nightspire",
                    note    = "After defeating Elisande, approach the teleporter outside the room and choose \"Font of Night\" as your destination.",
                    points  = {
                        { 0.431, 0.420 },
                        { 0.320, 0.269 },
                    },
                },
                {
                    mapID   = 772,
                    kind    = "poi",
                    subZone = "The Font of Night",
                    note    = "You have reached the final encounter. Kill Gul'dan!",
                    poiSize = 35,
                    points  = {
                        { 0.495, 0.475 },
                    },
                },
            },
        },

    },
}
