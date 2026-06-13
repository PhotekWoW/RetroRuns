-------------------------------------------------------------------------------
-- RetroRuns Data -- Siege of Orgrimmar
-- Mists of Pandaria, Patch 5.4.0  |  instanceID: 1136  |  journalInstanceID: 369
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

-- Faction divergence in the Galakras intro (the raid is otherwise symmetric):
-- Alliance land at Bladefist Bay mapID 559 and are greeted by Jaina; Horde land
-- on 556 and are greeted by Lor'themar. Resolved once at file load.
local isHorde = (UnitFactionGroup and UnitFactionGroup("player")) == "Horde"

-- Galakras intro landing: the bay reports uiMapID 559 for Alliance, 556 for
-- Horde. Only this segment diverges; Dranosh'ar Landing on is 559 for both.
local bladefistMapID = isHorde and 556 or 559

-- Galakras post-teleport: greeting NPC differs (Jaina / Lor'themar).
local galakrasGreetNote = isHorde
    and "After teleporting, talk to ^Lor'themar^ to continue. After some dialog, the NPCs will summon a portal. Take the portal and make your way down the bridge."
    or  "After teleporting, talk to ^Jaina^ to continue. After some dialog, she will summon a portal. Take her portal and make your way down the bridge."

-- Post-cannons: greeting NPC differs (Jaina / Lor'themar).
local galakrasReturnNote = isHorde
    and "After destroying the last of the cannons, run back towards the bridge. When ^Lor'themar^ appears, talk to him to begin the battle with ^Galakras^."
    or  "After destroying the last of the cannons, run back towards the bridge. When ^Jaina^ appears, talk to her to begin the battle with ^Galakras^."

-- Spoils of Pandaria door dialog: Alliance hear Jaina, Horde hear Vol'jin.
local spoilsDoorTrigger = isHorde
    and { dialog = { npc = "Vol'jin", match = "lust for power" } }
    or  { dialog = { npc = "Lady Jaina Proudmoore", match = "chaos in the city streets" } }

RetroRuns_Data[1136] = {
    instanceID        = 1136,
    journalInstanceID = 369,
    name              = "Siege of Orgrimmar",
    expansion         = "Mists of Pandaria",
    patch             = "5.4.0",

    exitNote = "None available",

    entrance = {
        mapID   = 1530,
        x       = 0.7270,
        y       = 0.4210,
        subZone = "Mogu'shan Palace",
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [556] = "Siege of Orgrimmar",
        [557] = "Pools of Power",
        [558] = "Vault of Y'Shaarj",
        [559] = "Gates of Orgrimmar",
        [560] = "The Valley of Strength",
        [561] = "The Cleft of Shadow",
        [562] = "The Descent",
        [563] = "Kor'Kron Barracks",
        [564] = "The Menagerie",
        [565] = "The Siegeworks",
        [566] = "Chamber of the Paragons",
        [567] = "The Inner Sanctum",
        [568] = "Terrace of Endless Spring",
        [569] = "Temple of the Jade Serpent",
        [570] = "Temple of the Red Crane",
    },

    tierSets = {
        labels       = {
            -- Tier 16 is the Siege of Orgrimmar set. The raid drops all
            -- five token slots plus the Essence off-set token: Sha of
            -- Pride (Chest), General Nazgrim (Hands), Thok the
            -- Bloodthirsty (Helm), Siegecrafter Blackfuse (Shoulders),
            -- Paragons of the Klaxxi (Legs), and Garrosh Hellscream
            -- (Essence).
        },
        tokenSources = {
        [99667] = 8,  -- Gauntlets of the Cursed Protector
        [99668] = 12,  -- Shoulders of the Cursed Vanquisher
        [99669] = 12,  -- Shoulders of the Cursed Conqueror
        [99670] = 12,  -- Shoulders of the Cursed Protector
        [99671] = 11,  -- Helm of the Cursed Vanquisher
        [99672] = 11,  -- Helm of the Cursed Conqueror
        [99673] = 11,  -- Helm of the Cursed Protector
        [99674] = 13,  -- Leggings of the Cursed Vanquisher
        [99675] = 13,  -- Leggings of the Cursed Conqueror
        [99676] = 13,  -- Leggings of the Cursed Protector
        [99677] = 4,  -- Chest of the Cursed Vanquisher
        [99678] = 4,  -- Chest of the Cursed Conqueror
        [99679] = 4,  -- Chest of the Cursed Protector
        [99680] = 8,  -- Gauntlets of the Cursed Vanquisher
        [99681] = 8,  -- Gauntlets of the Cursed Conqueror
        [99682] = 8,  -- Gauntlets of the Cursed Vanquisher
        [99683] = 11,  -- Helm of the Cursed Vanquisher
        [99684] = 13,  -- Leggings of the Cursed Vanquisher
        [99685] = 12,  -- Shoulders of the Cursed Vanquisher
        [99686] = 4,  -- Chest of the Cursed Conqueror
        [99687] = 8,  -- Gauntlets of the Cursed Conqueror
        [99688] = 13,  -- Leggings of the Cursed Conqueror
        [99689] = 11,  -- Helm of the Cursed Conqueror
        [99690] = 12,  -- Shoulders of the Cursed Conqueror
        [99691] = 4,  -- Chest of the Cursed Protector
        [99692] = 8,  -- Gauntlets of the Cursed Protector
        [99693] = 13,  -- Leggings of the Cursed Protector
        [99694] = 11,  -- Helm of the Cursed Protector
        [99695] = 12,  -- Shoulders of the Cursed Protector
        [99696] = 4,  -- Chest of the Cursed Vanquisher
        [99712] = 13,  -- Leggings of the Cursed Conqueror
        [99713] = 13,  -- Leggings of the Cursed Protector
        [99714] = 4,  -- Chest of the Cursed Vanquisher
        [99715] = 4,  -- Chest of the Cursed Conqueror
        [99716] = 4,  -- Chest of the Cursed Protector
        [99717] = 12,  -- Shoulders of the Cursed Vanquisher
        [99718] = 12,  -- Shoulders of the Cursed Conqueror
        [99719] = 12,  -- Shoulders of the Cursed Protector
        [99720] = 8,  -- Gauntlets of the Cursed Vanquisher
        [99721] = 8,  -- Gauntlets of the Cursed Conqueror
        [99722] = 8,  -- Gauntlets of the Cursed Protector
        [99723] = 11,  -- Helm of the Cursed Vanquisher
        [99724] = 11,  -- Helm of the Cursed Conqueror
        [99725] = 11,  -- Helm of the Cursed Protector
        [99726] = 13,  -- Leggings of the Cursed Vanquisher
        [99742] = 4,  -- Chest of the Cursed Vanquisher
        [99743] = 4,  -- Chest of the Cursed Conqueror
        [99744] = 4,  -- Chest of the Cursed Protector
        [99745] = 8,  -- Gauntlets of the Cursed Vanquisher
        [99746] = 8,  -- Gauntlets of the Cursed Conqueror
        [99747] = 8,  -- Gauntlets of the Cursed Protector
        [99748] = 11,  -- Helm of the Cursed Vanquisher
        [99749] = 11,  -- Helm of the Cursed Conqueror
        [99750] = 11,  -- Helm of the Cursed Protector
        [99751] = 13,  -- Leggings of the Cursed Vanquisher
        [99752] = 13,  -- Leggings of the Cursed Conqueror
        [99753] = 13,  -- Leggings of the Cursed Protector
        [99754] = 12,  -- Shoulders of the Cursed Vanquisher
        [99755] = 12,  -- Shoulders of the Cursed Conqueror
        [99756] = 12,  -- Shoulders of the Cursed Protector
        [105857] = 14,  -- Essence of the Cursed Protector
        [105858] = 14,  -- Essence of the Cursed Conqueror
        [105859] = 14,  -- Essence of the Cursed Vanquisher
        [105860] = 14,  -- Essence of the Cursed Protector
        [105861] = 14,  -- Essence of the Cursed Conqueror
        [105862] = 14,  -- Essence of the Cursed Vanquisher
        [105863] = 14,  -- Essence of the Cursed Protector
        [105864] = 14,  -- Essence of the Cursed Conqueror
        [105865] = 14,  -- Essence of the Cursed Vanquisher
        [105866] = 14,  -- Essence of the Cursed Protector
        [105867] = 14,  -- Essence of the Cursed Conqueror
        [105868] = 14,  -- Essence of the Cursed Vanquisher
        },
    },

    -- Account-wide skip ("Scroll of Past Deeds"), unlocked once any character
    -- defeats Garrosh. Per-difficulty state is graded from the strongest proof:
    --   mythicAchievement  -- account-wide Mythic kill; unlocks all difficulties
    --   heroicAchievements -- Heroic+ kill, account-wide (Conqueror = Alliance,
    --                         Liberator = Horde); unlocks Heroic + Normal
    --   normalStatistics   -- Normal kill counts (10N / 25N), character-scoped
    -- With none, Normal renders as unknown ("?").
    skipGarrosh = {
        mythicAchievement  = 8482,           -- Mythic: Garrosh Hellscream
        heroicAchievements = { 8679, 8680 }, -- Conqueror (A) / Liberator (H)
        normalStatistics   = {
            8635, -- 10-player Normal
            8636, -- 25-player Normal
        },
    },

    -- Skips window info text.
    skipTrigger = {
        details = "After zoning in, read the ^Scroll of Past Deeds^ beside ^Lorewalker Cho^ to skip straight to ^Garrosh Hellscream^.\nThe scroll unlocks for your whole account once any character has defeated Garrosh.",
    },

    gloryMeta = {
        id   = 8454,
        name = "Glory of the Orgrimmar Raider",
        rewardItemID       = 104208,
        rewardMountSpellID = 148392,
        rewardName         = "Reins of Galakras",
    },

    bosses = {
        {
            index              = 1,
            name               = "Immerseus",
            journalEncounterID = 852,
            aliases            = {},
            achievements       = {
                { id = 8536, name = "No More Tears", meta = true, soloable = "kinda" },
            },
            soloTip            = "^Immerseus^ alternates between phases several times. Phase1: Hit the boss. Phase2: Kill black blobs, heal blue ones if you can. The more killing/healing, the faster the fight.",
            loot = {
                { id = 110784, slot = "Two-Hand", name = "Trident of Corrupted Waters", sources = { [17]=60980, [14]=60024, [15]=60024, [16]=60979 } },
                { id = 110785, slot = "Weapon", name = "Encapsulated Essence of Immerseus", sources = { [17]=60925, [14]=60025, [15]=60025, [16]=60926 } },
                { id = 112382, slot = "Head", name = "Hood of Blackened Tears", sources = { [17]=60892, [14]=60891, [15]=60891, [16]=60893 } },
                { id = 112383, slot = "Feet", name = "Puddle Punishers", sources = { [17]=60896, [14]=60895, [15]=60895, [16]=60897 } },
                { id = 112416, slot = "Wrist", name = "Bubble-Burst Bracers", sources = { [17]=60908, [14]=60907, [15]=60907, [16]=60909 } },
                { id = 112417, slot = "Chest", name = "Chestplate of Congealed Corrosion", sources = { [17]=60911, [14]=60910, [15]=60910, [16]=60912 } },
                { id = 112418, slot = "Hands", name = "Corruption-Rotted Gauntlets", sources = { [17]=60914, [14]=60913, [15]=60913, [16]=60915 } },
                { id = 112419, slot = "Feet", name = "Treads of Unchained Hate", sources = { [17]=60917, [14]=60916, [15]=60916, [16]=60918 } },
                { id = 112420, slot = "Wrist", name = "Bracers of Sordid Sleep", sources = { [17]=60920, [14]=60919, [15]=60919, [16]=60921 } },
                { id = 112421, slot = "Shoulder", name = "Pauldrons of Violent Eruption", sources = { [17]=60923, [14]=60922, [15]=60922, [16]=60924 } },
                { id = 112422, slot = "Hands", name = "Bolt-Burster Grips", sources = { [17]=60928, [14]=60927, [15]=60927, [16]=60929 } },
                { id = 112423, slot = "Shoulder", name = "Ichor-Dripping Shoulderpads", sources = { [17]=60931, [14]=60930, [15]=60930, [16]=60932 } },
                { id = 112424, slot = "Head", name = "Hood of Swirling Senses", sources = { [17]=60934, [14]=60933, [15]=60933, [16]=60935 } },
                { id = 112425, slot = "Back", name = "Cloak of Misguided Power", sources = { [14]=60936, [15]=60936 } },
                { id = 112428, slot = "Feet", name = "Salt Water Sandals", sources = { [17]=60938, [14]=60937, [15]=60937, [16]=60939 } },
                { id = 112429, slot = "Wrist", name = "Bracers of Purified Spirit", sources = { [17]=60941, [14]=60940, [15]=60940, [16]=60942 } },
                { id = 112445, slot = "Hands", name = "Soul-Soaked Gloves", sources = { [17]=60958, [14]=60957, [15]=60957, [16]=60959 } },
                { id = 112447, slot = "Waist", name = "Greatbelt of Living Waters", sources = { [17]=60961, [14]=60960, [15]=60960, [16]=60962 } },
                { id = 112448, slot = "Feet", name = "Waterwalker Greatboots", sources = { [17]=60964, [14]=60963, [15]=60963, [16]=60965 } },
            },
        },
        {
            index              = 2,
            name               = "The Fallen Protectors",
            journalEncounterID = 849,
            aliases            = { "Fallen Protectors" },
            achievements       = {
                { id = 8528, name = "Go Long", meta = true, soloable = "no" },
            },
            loot = {
                { id = 112477, slot = "Weapon", name = "Softfoot's Last Resort", sources = { [17]=60982, [14]=60981, [15]=60981, [16]=60983 } },
                { id = 112478, slot = "Ranged", name = "Death Lotus Crossbow", sources = { [17]=60985, [14]=60984, [15]=60984, [16]=60986 } },
                { id = 112479, slot = "Feet", name = "Stonetoe's Tormented Treads", sources = { [17]=60988, [14]=60987, [15]=60987, [16]=60989 } },
                { id = 112480, slot = "Hands", name = "Grips of Unending Anguish", sources = { [17]=60991, [14]=60990, [15]=60990, [16]=60992 } },
                { id = 112481, slot = "Shoulder", name = "Darkfallen Shoulderplates", sources = { [17]=60994, [14]=60993, [15]=60993, [16]=60995 } },
                { id = 112482, slot = "Waist", name = "Poisonbinder Girth", sources = { [17]=60997, [14]=60996, [15]=60996, [16]=60998 } },
                { id = 112483, slot = "Hands", name = "Shockstriker Gauntlets", sources = { [17]=61000, [14]=60999, [15]=60999, [16]=61001 } },
                { id = 112485, slot = "Back", name = "Gloomwrap Greatcloak", sources = { [14]=61002, [15]=61002 } },
                { id = 112486, slot = "Feet", name = "Sha-Seared Sandals", sources = { [17]=61004, [14]=61003, [15]=61003, [16]=61005 } },
                { id = 112487, slot = "Chest", name = "Robes of the Tendered Heart", sources = { [17]=61007, [14]=61006, [15]=61006, [16]=61008 } },
                { id = 112488, slot = "Shoulder", name = "Shoulderpads of Dou Dou Chong", sources = { [17]=61010, [14]=61009, [15]=61009, [16]=61011 } },
                { id = 112489, slot = "Wrist", name = "Lifebane Bracers", sources = { [17]=61013, [14]=61012, [15]=61012, [16]=61014 } },
                { id = 112491, slot = "Off-hand", name = "Purehearted Cricket Cage", sources = { [17]=61016, [14]=61015, [15]=61015, [16]=61017 } },
                { id = 112492, slot = "Shoulder", name = "Shoulders of the Roiling Inferno", sources = { [17]=61019, [14]=61018, [15]=61018, [16]=61020 } },
                { id = 112493, slot = "Feet", name = "Sabatons of Defilement", sources = { [17]=61022, [14]=61021, [15]=61021, [16]=61023 } },
                { id = 112494, slot = "Shoulder", name = "Shoulderguards of Dark Meditations", sources = { [17]=61025, [14]=61024, [15]=61024, [16]=61026 } },
                { id = 112495, slot = "Hands", name = "Grips of the Fallen Council", sources = { [17]=61028, [14]=61027, [15]=61027, [16]=61029 } },
                { id = 112496, slot = "Head", name = "Gaze of Echoing Despair", sources = { [17]=61031, [14]=61030, [15]=61030, [16]=61032 } },
            },
        },
        {
            index              = 3,
            name               = "Norushen",
            journalEncounterID = 866,
            aliases            = {},
            achievements       = {
                { id = 8532, name = "None Shall Pass", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 112545, slot = "Wrist", name = "Bracers of Blind Hatred", sources = { [17]=61047, [14]=61046, [15]=61046, [16]=61048 } },
                { id = 112546, slot = "Weapon", name = "Xifeng, Longblade of the Titanic Guardian", sources = { [17]=61050, [14]=61049, [15]=61049, [16]=61051 } },
                { id = 112547, slot = "Weapon", name = "Norushen's Shortblade", sources = { [17]=61053, [14]=61052, [15]=61052, [16]=61054 } },
                { id = 112548, slot = "Hands", name = "Gloves of the Golden Protector", sources = { [17]=61056, [14]=61055, [15]=61055, [16]=61057 } },
                { id = 112549, slot = "Chest", name = "Robes of the Blackened Watcher", sources = { [17]=61059, [14]=61058, [15]=61058, [16]=61060 } },
                { id = 112550, slot = "Shoulder", name = "Quarantine Shoulderguards", sources = { [17]=61062, [14]=61061, [15]=61061, [16]=61063 } },
                { id = 112551, slot = "Legs", name = "Leggings of Unabashed Anger", sources = { [17]=61065, [14]=61064, [15]=61064, [16]=61066 } },
                { id = 112552, slot = "Head", name = "Rage-Blind Greathelm", sources = { [17]=61068, [14]=61067, [15]=61067, [16]=61069 } },
                { id = 112554, slot = "Back", name = "Drape of the Despairing Pit", sources = { [14]=61070, [15]=61070 } },
                { id = 112555, slot = "Wrist", name = "Bracers of Broken Causation", sources = { [17]=61072, [14]=61071, [15]=61071, [16]=61073 } },
                { id = 112556, slot = "Hands", name = "Blight Hurlers", sources = { [17]=61075, [14]=61074, [15]=61074, [16]=61076 } },
                { id = 112557, slot = "Waist", name = "Sash of the Last Guardian", sources = { [17]=61078, [14]=61077, [15]=61077, [16]=61079 } },
                { id = 112558, slot = "Shoulder", name = "Rime-Rift Shoulders", sources = { [17]=61081, [14]=61080, [15]=61080, [16]=61082 } },
                { id = 112560, slot = "Off-hand", name = "Norushen's Enigmatic Barrier", sources = { [17]=61084, [14]=61083, [15]=61083, [16]=61085 } },
                { id = 112561, slot = "Feet", name = "Boots of Broken Reliance", sources = { [17]=61087, [14]=61086, [15]=61086, [16]=61088 } },
                { id = 112562, slot = "Hands", name = "Confident Grips", sources = { [17]=61090, [14]=61089, [15]=61089, [16]=61091 } },
                { id = 112563, slot = "Wrist", name = "Bracers of Final Serenity", sources = { [17]=61093, [14]=61092, [15]=61092, [16]=61094 } },
                { id = 112564, slot = "Legs", name = "Shadow-Binder's Kilt", sources = { [17]=61096, [14]=61095, [15]=61095, [16]=61097 } },
                { id = 112565, slot = "Wrist", name = "Wristplates of Broken Doubt", sources = { [17]=61099, [14]=61098, [15]=61098, [16]=61100 } },
            },
        },
        {
            index              = 4,
            name               = "Sha of Pride",
            journalEncounterID = 867,
            aliases            = {},
            achievements       = {
                { id = 8521, name = "Swallow Your Pride", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 112702, slot = "Head", name = "Crown of Boastful Words", sources = { [17]=61512, [14]=61511, [15]=61511, [16]=61513 } },
                { id = 112949, slot = "Two-Hand", name = "Greatsword of Pride's Fall", sources = { [17]=61976, [14]=61975, [15]=61975, [16]=61977 } },
                { id = 112950, slot = "Off-hand", name = "Shield of Mockery", sources = { [17]=61979, [14]=61978, [15]=61978, [16]=61980 } },
                { id = 112951, slot = "Two-Hand", name = "Gaze of Arrogance", sources = { [17]=61982, [14]=61981, [15]=61981, [16]=61983 } },
                { id = 112952, slot = "Head", name = "Self-Reflecting Mask", sources = { [17]=61985, [14]=61984, [15]=61984, [16]=61986 } },
                { id = 112953, slot = "Feet", name = "Greaves of Sublime Superiority", sources = { [17]=61988, [14]=61987, [15]=61987, [16]=61989 } },
            { id = 99201, slot = "Chest", name = "Chestguard of the Prehistoric Marauder", sources = { [17]=52318, [14]=52482, [16]=52696 }, classes = { 1 } },
            { id = 99197, slot = "Chest", name = "Battleplate of the Prehistoric Marauder", sources = { [17]=52328, [14]=52478, [16]=52692 }, classes = { 1 } },
            { id = 99133, slot = "Chest", name = "Breastplate of Winged Triumph", sources = { [17]=52284, [14]=52414, [16]=52655 }, classes = { 2 } },
            { id = 99126, slot = "Chest", name = "Chestguard of Winged Triumph", sources = { [17]=52312, [14]=52407, [16]=52649 }, classes = { 2 } },
            { id = 99136, slot = "Chest", name = "Battleplate of Winged Triumph", sources = { [17]=52333, [14]=52417, [16]=52668 }, classes = { 2 } },
            { id = 99167, slot = "Chest", name = "Tunic of the Unblinking Vigil", sources = { [17]=52366, [14]=52448, [16]=52686 }, classes = { 3 } },
            { id = 99112, slot = "Chest", name = "Tunic of the Barbed Assassin", sources = { [17]=52287, [14]=52393, [16]=52637 }, classes = { 4 } },
            { id = 99110, slot = "Chest", name = "Raiment of the Ternion Glory", sources = { [17]=52285, [14]=52391, [16]=52643 }, classes = { 5 } },
            { id = 99119, slot = "Chest", name = "Robes of the Ternion Glory", sources = { [17]=52298, [14]=52400, [16]=52638 }, classes = { 5 } },
            { id = 99188, slot = "Chest", name = "Chestguard of Cyclopean Dread", sources = { [17]=52341, [14]=52469, [16]=52611 }, classes = { 6 } },
            { id = 99192, slot = "Chest", name = "Breastplate of Cyclopean Dread", sources = { [17]=52347, [14]=52473, [16]=52616 }, classes = { 6 } },
            { id = 99101, slot = "Chest", name = "Cuirass of Celestial Harmony", sources = { [17]=52273, [14]=52382, [16]=52628 }, classes = { 7 } },
            { id = 99107, slot = "Chest", name = "Tunic of Celestial Harmony", sources = { [17]=52292, [14]=52388, [16]=52632 }, classes = { 7 } },
            { id = 99106, slot = "Chest", name = "Hauberk of Celestial Harmony", sources = { [17]=52368, [14]=52387, [16]=52625 }, classes = { 7 } },
            { id = 99152, slot = "Chest", name = "Chronomancer Robes", sources = { [17]=52359, [14]=52433, [16]=52681 }, classes = { 8 } },
            { id = 99204, slot = "Chest", name = "Robes of the Horned Nightmare", sources = { [17]=52337, [14]=52485, [16]=52697 }, classes = { 9 } },
            { id = 99150, slot = "Chest", name = "Vest of Seven Sacred Seals", sources = { [17]=52342, [14]=52431, [16]=52672 }, classes = { 10 } },
            { id = 99140, slot = "Chest", name = "Chestguard of Seven Sacred Seals", sources = { [17]=52344, [14]=52421, [16]=52663 }, classes = { 10 } },
            { id = 99154, slot = "Chest", name = "Tunic of Seven Sacred Seals", sources = { [17]=52352, [14]=52435, [16]=52677 }, classes = { 10 } },
            { id = 99177, slot = "Chest", name = "Vestment of the Shattered Vale", sources = { [17]=52278, [14]=52458, [16]=52708 }, classes = { 11 } },
            { id = 99170, slot = "Chest", name = "Tunic of the Shattered Vale", sources = { [17]=52280, [14]=52451, [16]=52700 }, classes = { 11 } },
            { id = 99172, slot = "Chest", name = "Robes of the Shattered Vale", sources = { [17]=52296, [14]=52453, [16]=52711 }, classes = { 11 } },
            { id = 99180, slot = "Chest", name = "Raiment of the Shattered Vale", sources = { [17]=52322, [14]=52461, [16]=52607 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 104162, kind = "pet", name = "Droplet of Y'Shaarj" },
                { id = 104163, kind = "pet", name = "Gooey Sha-ling" },
            },
        },
        {
            index              = 5,
            name               = "Galakras",
            journalEncounterID = 881,
            -- On Horde, the Encounter Journal's journal-to-dungeon map omits
            -- Galakras, so lockout-based completion can't resolve him and the
            -- idle boss count comes up one short (13/14 on a full clear).
            -- Alliance's journal does expose him. The lockout credits the kill
            -- under this dungeonEncounterID on both factions, so supplying it
            -- directly lets completion resolve regardless of faction.
            dungeonEncounterID = 1622,
            aliases            = {},
            achievements       = {
                { id = 8530, name = "The Immortal Vanguard", meta = true, soloable = "yes" },
            },
            soloTip            = "Kill trash waves until the south tower reaches 100%. Then climb the south tower, and shoot ^Galakras^ as many times as you can. Kill some more trash on the ground level until ^Galakras^ drops to the ground.",
            loot = {
                { id = 112704, slot = "Wrist", name = "Arcsmasher Bracers", sources = { [17]=61515, [14]=61514, [15]=61514, [16]=61516 } },
                { id = 112705, slot = "Shoulder", name = "Krugruk's Rigid Shoulderplates", sources = { [17]=61518, [14]=61517, [15]=61517, [16]=61519 } },
                { id = 112706, slot = "Feet", name = "Unrepentant Heels", sources = { [17]=61521, [14]=61520, [15]=61520, [16]=61522 } },
                { id = 112707, slot = "Hands", name = "Korgra's Venom-Soaked Gauntlets", sources = { [17]=61524, [14]=61523, [15]=61523, [16]=61525 } },
                { id = 112710, slot = "Ranged", name = "Dagryn's Discarded Longbow", sources = { [17]=61527, [14]=61526, [15]=61526, [16]=61528 } },
                { id = 112711, slot = "Waist", name = "Cannoneer's Multipocket Gunbelt", sources = { [17]=61530, [14]=61529, [15]=61529, [16]=61531 } },
                { id = 112712, slot = "Wrist", name = "Dagryn's Fuselight Bracers", sources = { [17]=61533, [14]=61532, [15]=61532, [16]=61534 } },
                { id = 112713, slot = "Head", name = "Thranok's Shattering Helm", sources = { [17]=61536, [14]=61535, [15]=61535, [16]=61537 } },
                { id = 112715, slot = "Feet", name = "Bone-Inlaid Sandals", sources = { [17]=61539, [14]=61538, [15]=61538, [16]=61540 } },
                { id = 112716, slot = "Wrist", name = "Scalebane Bracers", sources = { [17]=61542, [14]=61541, [15]=61541, [16]=61543 } },
                { id = 112717, slot = "Head", name = "Flameslinger's Fiery Cowl", sources = { [17]=61545, [14]=61544, [15]=61544, [16]=61546 } },
                { id = 112718, slot = "Feet", name = "Skydancer Boots", sources = { [17]=61548, [14]=61547, [15]=61547, [16]=61549 } },
                { id = 112719, slot = "Shoulder", name = "Shoulderpads of Pulsing Protection", sources = { [17]=61551, [14]=61550, [15]=61550, [16]=61552 } },
                { id = 112723, slot = "Two-Hand", name = "Drakebinder Greatstaff", sources = { [17]=61554, [14]=61553, [15]=61553, [16]=61555 } },
                { id = 112725, slot = "Waist", name = "Dragonmaw Emergency Strap", sources = { [17]=61557, [14]=61556, [15]=61556, [16]=61558 } },
                { id = 112726, slot = "Hands", name = "Grips of Tidal Force", sources = { [17]=61560, [14]=61559, [15]=61559, [16]=61561 } },
                { id = 112727, slot = "Wrist", name = "Smoldering Drakescale Bracers", sources = { [17]=61563, [14]=61562, [15]=61562, [16]=61564 } },
                { id = 112728, slot = "Legs", name = "Windfire Legplates", sources = { [17]=61566, [14]=61565, [15]=61565, [16]=61567 } },
            },
        },
        {
            index              = 6,
            name               = "Iron Juggernaut",
            journalEncounterID = 864,
            aliases            = {},
            achievements       = {
                { id = 8520, name = "Fire in the Hole!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 112731, slot = "Feet", name = "Minelayer's Padded Boots", sources = { [17]=61569, [14]=61568, [15]=61568, [16]=61570 } },
                { id = 112732, slot = "Hands", name = "Tar-Coated Gauntlets", sources = { [17]=61572, [14]=61571, [15]=61571, [16]=61573 } },
                { id = 112733, slot = "Wrist", name = "Wall-Borer Bracers", sources = { [17]=61575, [14]=61574, [15]=61574, [16]=61576 } },
                { id = 112734, slot = "Hands", name = "Precision Cutters", sources = { [17]=61578, [14]=61577, [15]=61577, [16]=61579 } },
                { id = 112735, slot = "Waist", name = "Demolisher's Reinforced Belt", sources = { [17]=61581, [14]=61580, [15]=61580, [16]=61582 } },
                { id = 112736, slot = "Weapon", name = "Seismic Bore", sources = { [17]=61584, [14]=61583, [15]=61583, [16]=61585 } },
                { id = 112739, slot = "Wrist", name = "Laser Burn Bracers", sources = { [17]=61589, [14]=61588, [15]=61588, [16]=61590 } },
                { id = 112740, slot = "Shoulder", name = "Ricocheting Shoulderguards", sources = { [17]=61592, [14]=61591, [15]=61591, [16]=61593 } },
                { id = 112741, slot = "Chest", name = "Earthbreaker's Steaming Chestplate", sources = { [17]=61595, [14]=61594, [15]=61594, [16]=61596 } },
                { id = 112743, slot = "Waist", name = "Belt of Ominous Trembles", sources = { [17]=61598, [14]=61597, [15]=61597, [16]=61599 } },
                { id = 112744, slot = "Legs", name = "Leggings of Furious Flame", sources = { [17]=61601, [14]=61600, [15]=61600, [16]=61602 } },
                { id = 112745, slot = "Wrist", name = "Bracers of the Broken Fault", sources = { [17]=61604, [14]=61603, [15]=61603, [16]=61605 } },
                { id = 112746, slot = "Chest", name = "Shock Pulse Robes", sources = { [17]=61609, [14]=61608, [15]=61608, [16]=61610 } },
                { id = 112748, slot = "Off-hand", name = "Juggernaut's Power Core", sources = { [17]=61612, [14]=61611, [15]=61611, [16]=61613 } },
                { id = 112749, slot = "Wrist", name = "Castlebreaker Bracers", sources = { [17]=61615, [14]=61614, [15]=61614, [16]=61616 } },
                { id = 112750, slot = "Feet", name = "Treads of Autonomic Motion", sources = { [17]=61618, [14]=61617, [15]=61617, [16]=61619 } },
                { id = 112751, slot = "Wrist", name = "Cavemaker Wristguards", sources = { [17]=61621, [14]=61620, [15]=61620, [16]=61622 } },
                { id = 112752, slot = "Feet", name = "Borer Drill Boots", sources = { [17]=61624, [14]=61623, [15]=61623, [16]=61625 } },
                { id = 112946, slot = "Hands", name = "Earthripper Gloves", sources = { [17]=61973, [14]=61972, [15]=61972, [16]=61974 } },
            },
        },
        {
            index              = 7,
            name               = "Kor'kron Dark Shaman",
            journalEncounterID = 856,
            aliases            = {},
            achievements       = {
                { id = 8453, name = "Rescue Raiders", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 112755, slot = "Chest", name = "Breastplate of Shamanic Mirrors", sources = { [17]=61627, [14]=61626, [15]=61626, [16]=61628 } },
                { id = 112757, slot = "Feet", name = "Wolf-Rider Spurs", sources = { [17]=61630, [14]=61629, [15]=61629, [16]=61631 } },
                { id = 112759, slot = "Weapon", name = "Haromm's Frozen Crescent", sources = { [17]=61633, [14]=61632, [15]=61632, [16]=61634 } },
                { id = 112760, slot = "Waist", name = "Damron's Belt of Darkness", sources = { [17]=61636, [14]=61635, [15]=61635, [16]=61637 } },
                { id = 112761, slot = "Legs", name = "Riou's Vigilant Leggings", sources = { [17]=61639, [14]=61638, [15]=61638, [16]=61640 } },
                { id = 112762, slot = "Head", name = "Haromm's Horrifying Helm", sources = { [17]=61642, [14]=61641, [15]=61641, [16]=61643 } },
                { id = 112763, slot = "Waist", name = "Ashen Wall Girdle", sources = { [17]=61645, [14]=61644, [15]=61644, [16]=61646 } },
                { id = 112764, slot = "Back", name = "Poisonmist Nightcloak", sources = { [17]=61648, [14]=61647, [15]=61647, [16]=61649 } },
                { id = 112765, slot = "Feet", name = "Toxic Tornado Treads", sources = { [17]=61651, [14]=61650, [15]=61650, [16]=61652 } },
                { id = 112766, slot = "Head", name = "Iron Wolf Hood", sources = { [17]=61654, [14]=61653, [15]=61653, [16]=61655 } },
                { id = 112769, slot = "Weapon", name = "Kardris' Scepter", sources = { [17]=61657, [14]=61656, [15]=61656, [16]=61658 } },
                { id = 112770, slot = "Head", name = "Darkfang Mask", sources = { [17]=61660, [14]=61659, [15]=61659, [16]=61661 } },
                { id = 112771, slot = "Waist", name = "Belt of the Iron Prison", sources = { [17]=61663, [14]=61662, [15]=61662, [16]=61664 } },
                { id = 112772, slot = "Shoulder", name = "Shoulderguards of Foul Streams", sources = { [17]=61666, [14]=61665, [15]=61665, [16]=61667 } },
                { id = 112773, slot = "Wrist", name = "Shackles of Stinking Slime", sources = { [17]=61669, [14]=61668, [15]=61668, [16]=61670 } },
                { id = 112774, slot = "Shoulder", name = "Shoulderplates of Gushing Geysers", sources = { [17]=61672, [14]=61671, [15]=61671, [16]=61673 } },
            },
        },
        {
            index              = 8,
            name               = "General Nazgrim",
            journalEncounterID = 850,
            aliases            = {},
            achievements       = {
                { id = 8448, name = "Gamon Will Save Us!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 112779, slot = "Feet", name = "Ravager's Pathwalkers", sources = { [17]=61680, [14]=61679, [15]=61679, [16]=61681 } },
                { id = 112780, slot = "Weapon", name = "Nazgrim's Gutripper", sources = { [17]=61683, [14]=61682, [15]=61682, [16]=61684 } },
                { id = 112781, slot = "Off-hand", name = "Bulwark of the Fallen General", sources = { [17]=61686, [14]=61685, [15]=61685, [16]=61687 } },
                { id = 112782, slot = "Feet", name = "Sandals of Two Little Bees", sources = { [17]=61689, [14]=61688, [15]=61688, [16]=61690 } },
                { id = 112783, slot = "Shoulder", name = "Shoulderguards of the Righteous Stand", sources = { [17]=61692, [14]=61691, [15]=61691, [16]=61693 } },
                { id = 112785, slot = "Two-Hand", name = "Gar'tok, Strength of the Faithful", sources = { [17]=61695, [14]=61694, [15]=61694, [16]=61696 } },
                { id = 112787, slot = "Weapon", name = "Arcweaver Spell Sword", sources = { [17]=61698, [14]=61697, [15]=61697, [16]=61699 } },
                { id = 112788, slot = "Chest", name = "Robes of the Warrior's Fall", sources = { [17]=61702, [14]=61701, [15]=61701, [16]=61703 } },
                { id = 112789, slot = "Head", name = "Crown of Tragic Truth", sources = { [17]=61705, [14]=61704, [15]=61704, [16]=61706 } },
                { id = 112790, slot = "Shoulder", name = "Spaulders of Kor'kron Fealty", sources = { [17]=61708, [14]=61707, [15]=61707, [16]=61709 } },
            { id = 99198, slot = "Hands", name = "Gauntlets of the Prehistoric Marauder", sources = { [17]=52315, [14]=52479, [16]=52693 }, classes = { 1 } },
            { id = 99202, slot = "Hands", name = "Handguards of the Prehistoric Marauder", sources = { [17]=52319, [14]=52483, [16]=52689 }, classes = { 1 } },
            { id = 99134, slot = "Hands", name = "Gloves of Winged Triumph", sources = { [17]=52263, [14]=52415, [16]=52656 }, classes = { 2 } },
            { id = 99137, slot = "Hands", name = "Gauntlets of Winged Triumph", sources = { [17]=52283, [14]=52418, [16]=52661 }, classes = { 2 } },
            { id = 99127, slot = "Hands", name = "Handguards of Winged Triumph", sources = { [17]=52309, [14]=52408, [16]=52650 }, classes = { 2 } },
            { id = 99168, slot = "Hands", name = "Gloves of the Unblinking Vigil", sources = { [17]=52367, [14]=52449, [16]=52687 }, classes = { 3 } },
            { id = 99113, slot = "Hands", name = "Gloves of the Barbed Assassin", sources = { [17]=52288, [14]=52394, [16]=52636 }, classes = { 4 } },
            { id = 99121, slot = "Hands", name = "Gloves of the Ternion Glory", sources = { [17]=52300, [14]=52402, [16]=52640 }, classes = { 5 } },
            { id = 99131, slot = "Hands", name = "Handwraps of the Ternion Glory", sources = { [17]=52304, [14]=52412, [16]=52646 }, classes = { 5 } },
            { id = 99189, slot = "Hands", name = "Handguards of Cyclopean Dread", sources = { [17]=52329, [14]=52470, [16]=52612 }, classes = { 6 } },
            { id = 99193, slot = "Hands", name = "Gauntlets of Cyclopean Dread", sources = { [17]=52348, [14]=52474, [16]=52617 }, classes = { 6 } },
            { id = 99108, slot = "Hands", name = "Handwraps of Celestial Harmony", sources = { [17]=52269, [14]=52389, [16]=52633 }, classes = { 7 } },
            { id = 99102, slot = "Hands", name = "Grips of Celestial Harmony", sources = { [17]=52274, [14]=52383, [16]=52621 }, classes = { 7 } },
            { id = 99092, slot = "Hands", name = "Gloves of Celestial Harmony", sources = { [17]=52369, [14]=52373, [16]=52626 }, classes = { 7 } },
            { id = 99160, slot = "Hands", name = "Chronomancer Gloves", sources = { [17]=52364, [14]=52441, [16]=52678 }, classes = { 8 } },
            { id = 99096, slot = "Hands", name = "Gloves of the Horned Nightmare", sources = { [17]=52334, [14]=52377, [16]=52705 }, classes = { 9 } },
            { id = 99141, slot = "Hands", name = "Gauntlets of Seven Sacred Seals", sources = { [17]=52345, [14]=52422, [16]=52664 }, classes = { 10 } },
            { id = 99147, slot = "Hands", name = "Handwraps of Seven Sacred Seals", sources = { [17]=52349, [14]=52428, [16]=52669 }, classes = { 10 } },
            { id = 99155, slot = "Hands", name = "Grips of Seven Sacred Seals", sources = { [17]=52353, [14]=52436, [16]=52673 }, classes = { 10 } },
            { id = 99174, slot = "Hands", name = "Gloves of the Shattered Vale", sources = { [17]=52275, [14]=52455, [16]=52713 }, classes = { 11 } },
            { id = 99163, slot = "Hands", name = "Handguards of the Shattered Vale", sources = { [17]=52281, [14]=52444, [16]=52701 }, classes = { 11 } },
            { id = 99185, slot = "Hands", name = "Handwraps of the Shattered Vale", sources = { [17]=52293, [14]=52466, [16]=52716 }, classes = { 11 } },
            { id = 99181, slot = "Hands", name = "Grips of the Shattered Vale", sources = { [17]=52323, [14]=52462, [16]=52608 }, classes = { 11 } },
            },
        },
        {
            index              = 9,
            name               = "Malkorok",
            journalEncounterID = 846,
            aliases            = {},
            achievements       = {
                { id = 8538, name = "Unlimited Potential", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 112793, slot = "Wrist", name = "Blood Rage Bracers", sources = { [17]=61712, [14]=61711, [15]=61711, [16]=61713 } },
                { id = 112794, slot = "Chest", name = "Lazahk's Lost Shadowrap", sources = { [17]=61715, [14]=61714, [15]=61714, [16]=61716 } },
                { id = 112796, slot = "Feet", name = "Malkorok's Giant Stompers", sources = { [17]=61718, [14]=61717, [15]=61717, [16]=61719 } },
                { id = 112797, slot = "Wrist", name = "Wristguards of Ruination", sources = { [17]=61721, [14]=61720, [15]=61720, [16]=61722 } },
                { id = 112804, slot = "Weapon", name = "Malkorok's Skullcleaver", sources = { [17]=61724, [14]=61723, [15]=61723, [16]=61725 } },
                { id = 112805, slot = "Two-Hand", name = "Halberd of Inner Shadows", sources = { [17]=61727, [14]=61726, [15]=61726, [16]=61728 } },
                { id = 112806, slot = "Ranged", name = "Kor'kron Hand Cannon", sources = { [17]=61730, [14]=61729, [15]=61729, [16]=61731 } },
                { id = 112807, slot = "Legs", name = "Legplates of Willful Doom", sources = { [17]=61733, [14]=61732, [15]=61732, [16]=61734 } },
                { id = 112808, slot = "Waist", name = "Miasmic Skullbelt", sources = { [17]=61736, [14]=61735, [15]=61735, [16]=61737 } },
                { id = 112813, slot = "Head", name = "Hood of Perpetual Implosion", sources = { [17]=61744, [14]=61743, [15]=61743, [16]=61745 } },
                { id = 112814, slot = "Chest", name = "Robes of Riven Dreams", sources = { [17]=61747, [14]=61746, [15]=61746, [16]=61748 } },
                { id = 112816, slot = "Back", name = "Black-Blooded Drape", sources = { [17]=61751, [14]=61750, [15]=61750, [16]=61752 } },
                { id = 112818, slot = "Off-hand", name = "Visage of the Monstrous", sources = { [17]=61754, [14]=61753, [15]=61753, [16]=61755 } },
                { id = 112819, slot = "Feet", name = "Boots of Perilous Infusion", sources = { [17]=61757, [14]=61756, [15]=61756, [16]=61758 } },
                { id = 112820, slot = "Wrist", name = "Bracers of Averted Fatality", sources = { [17]=61760, [14]=61759, [15]=61759, [16]=61761 } },
                { id = 112821, slot = "Chest", name = "Ebon Blood Chestguard", sources = { [17]=61763, [14]=61762, [15]=61762, [16]=61764 } },
                { id = 112823, slot = "Chest", name = "Terrorguard Chestplate", sources = { [17]=61767, [14]=61766, [15]=61766, [16]=61768 } },
            },
        },
        {
            index              = 10,
            name               = "Spoils of Pandaria",
            journalEncounterID = 870,
            aliases            = {},
            achievements       = {
                { id = 8529, name = "Criss Cross", meta = true, soloable = "no" },
            },
            soloTip            = "Choose any dialog options to start the fight; doesn't matter. To beat this encounter, visit all 4 rooms one at a time (by chain or by lever, depending on order). Inside each room, click boxes and defeat enemies to fill the meter, then pull the room's lever. After you pull the 4th lever, the fight is over. You must beat the timer!",
            loot = {
                { id = 112826, slot = "Feet", name = "Ominous Mogu Greatboots", sources = { [17]=61774, [14]=61773, [15]=61773, [16]=61775 } },
                { id = 112827, slot = "Feet", name = "Pandaren Roofsprinters", sources = { [17]=61777, [14]=61776, [15]=61776, [16]=61778 } },
                { id = 112829, slot = "Off-hand", name = "Ancient Mogu Tower Shield", sources = { [17]=61780, [14]=61779, [15]=61779, [16]=61781 } },
                { id = 112831, slot = "Waist", name = "Arrowflight Girdle", sources = { [17]=61788, [14]=61787, [15]=61787, [16]=61789 } },
                { id = 112832, slot = "Head", name = "Helm of the Night Watchman", sources = { [17]=61791, [14]=61790, [15]=61790, [16]=61792 } },
                { id = 112833, slot = "Wrist", name = "Mantid Carapace Augments", sources = { [17]=61794, [14]=61793, [15]=61793, [16]=61795 } },
                { id = 112834, slot = "Waist", name = "Untarnishable Greatbelt", sources = { [17]=61797, [14]=61796, [15]=61796, [16]=61798 } },
                { id = 112835, slot = "Weapon", name = "Enchanted Shao-Tien Saber", sources = { [17]=61800, [14]=61799, [15]=61799, [16]=61801 } },
                { id = 112836, slot = "Chest", name = "Ancient Archer's Chestguard", sources = { [17]=61803, [14]=61802, [15]=61802, [16]=61804 } },
                { id = 112837, slot = "Wrist", name = "Avool's Ancestral Bracers", sources = { [17]=61806, [14]=61805, [15]=61805, [16]=61807 } },
                { id = 112838, slot = "Chest", name = "Mantid Vizier's Robes", sources = { [17]=61809, [14]=61808, [15]=61808, [16]=61810 } },
                { id = 112841, slot = "Ranged", name = "Immaculately Preserved Wand", sources = { [17]=61818, [14]=61817, [15]=61817, [16]=61819 } },
                { id = 112842, slot = "Hands", name = "Klaxxi Grips of Rejuvenation", sources = { [17]=61821, [14]=61820, [15]=61820, [16]=61822 } },
                { id = 112843, slot = "Legs", name = "Shado-Pan Reliquary Kilt", sources = { [17]=61824, [14]=61823, [15]=61823, [16]=61825 } },
                { id = 112844, slot = "Waist", name = "Chitin-Link Chain Belt", sources = { [17]=61827, [14]=61826, [15]=61826, [16]=61828 } },
                { id = 112845, slot = "Wrist", name = "Bracers of the Pristine Purifier", sources = { [17]=61830, [14]=61829, [15]=61829, [16]=61831 } },
                { id = 112846, slot = "Waist", name = "Plate Belt of the War-Healer", sources = { [17]=61833, [14]=61832, [15]=61832, [16]=61834 } },
                { id = 112847, slot = "Feet", name = "Mogu Mindbender's Greaves", sources = { [17]=61836, [14]=61835, [15]=61835, [16]=61837 } },
            },
        },
        {
            index              = 11,
            name               = "Thok the Bloodthirsty",
            journalEncounterID = 851,
            aliases            = {},
            achievements       = {
                { id = 8527, name = "Giant Dinosaur vs. Mega Snail", meta = true, soloable = "no" },
            },
            loot = {
                { id = 112853, slot = "Weapon", name = "Hvitserk's Formidable Shanker", sources = { [17]=61839, [14]=61838, [15]=61838, [16]=61840 } },
                { id = 112854, slot = "Hands", name = "Montak's Grips of Scorching Breath", sources = { [17]=61842, [14]=61841, [15]=61841, [16]=61843 } },
                { id = 112856, slot = "Chest", name = "Icy Blood Chestplate", sources = { [17]=61845, [14]=61844, [15]=61844, [16]=61846 } },
                { id = 112861, slot = "Off-hand", name = "Festering Primordial Globule", sources = { [17]=61848, [14]=61847, [15]=61847, [16]=61849 } },
                { id = 112862, slot = "Two-Hand", name = "Britomart's Jagged Pike", sources = { [17]=61851, [14]=61850, [15]=61850, [16]=61852 } },
                { id = 112866, slot = "Chest", name = "Akolik's Acid-Soaked Robes", sources = { [17]=61854, [14]=61853, [15]=61853, [16]=61855 } },
            { id = 99203, slot = "Head", name = "Faceguard of the Prehistoric Marauder", sources = { [17]=52313, [14]=52484, [16]=52690 }, classes = { 1 } },
            { id = 99206, slot = "Head", name = "Helmet of the Prehistoric Marauder", sources = { [17]=52327, [14]=52487, [16]=52699 }, classes = { 1 } },
            { id = 99135, slot = "Head", name = "Headguard of Winged Triumph", sources = { [17]=52260, [14]=52416, [16]=52657 }, classes = { 2 } },
            { id = 99138, slot = "Head", name = "Helmet of Winged Triumph", sources = { [17]=52266, [14]=52419, [16]=52660 }, classes = { 2 } },
            { id = 99128, slot = "Head", name = "Faceguard of Winged Triumph", sources = { [17]=52310, [14]=52409, [16]=52651 }, classes = { 2 } },
            { id = 99157, slot = "Head", name = "Headguard of the Unblinking Vigil", sources = { [17]=52361, [14]=52438, [16]=52683 }, classes = { 3 } },
            { id = 99114, slot = "Head", name = "Helmet of the Barbed Assassin", sources = { [17]=52289, [14]=52395, [16]=52912 }, classes = { 4 } },
            { id = 99122, slot = "Head", name = "Hood of the Ternion Glory", sources = { [17]=52301, [14]=52403, [16]=52868 }, classes = { 5 } },
            { id = 99117, slot = "Head", name = "Cowl of the Ternion Glory", sources = { [17]=52305, [14]=52398, [16]=52872 }, classes = { 5 } },
            { id = 99190, slot = "Head", name = "Faceguard of Cyclopean Dread", sources = { [17]=52330, [14]=52471, [16]=52886 }, classes = { 6 } },
            { id = 99194, slot = "Head", name = "Helmet of Cyclopean Dread", sources = { [17]=52338, [14]=52475, [16]=52852 }, classes = { 6 } },
            { id = 99103, slot = "Head", name = "Helmet of Celestial Harmony", sources = { [17]=52264, [14]=52384, [16]=52622 }, classes = { 7 } },
            { id = 99109, slot = "Head", name = "Faceguard of Celestial Harmony", sources = { [17]=52270, [14]=52390, [16]=52634 }, classes = { 7 } },
            { id = 99093, slot = "Head", name = "Headpiece of Celestial Harmony", sources = { [17]=52370, [14]=52374, [16]=52613 }, classes = { 7 } },
            { id = 99161, slot = "Head", name = "Chronomancer Hood", sources = { [17]=52365, [14]=52442, [16]=52679 }, classes = { 8 } },
            { id = 99097, slot = "Head", name = "Hood of the Horned Nightmare", sources = { [17]=52335, [14]=52378, [16]=52706 }, classes = { 9 } },
            { id = 99142, slot = "Head", name = "Crown of Seven Sacred Seals", sources = { [17]=52346, [14]=52423, [16]=52665 }, classes = { 10 } },
            { id = 99148, slot = "Head", name = "Helm of Seven Sacred Seals", sources = { [17]=52350, [14]=52429, [16]=52670 }, classes = { 10 } },
            { id = 99156, slot = "Head", name = "Headpiece of Seven Sacred Seals", sources = { [17]=52354, [14]=52437, [16]=52674 }, classes = { 10 } },
            { id = 99175, slot = "Head", name = "Cover of the Shattered Vale", sources = { [17]=52276, [14]=52456, [16]=52714 }, classes = { 11 } },
            { id = 99164, slot = "Head", name = "Headguard of the Shattered Vale", sources = { [17]=52282, [14]=52445, [16]=52702 }, classes = { 11 } },
            { id = 99178, slot = "Head", name = "Helm of the Shattered Vale", sources = { [17]=52294, [14]=52459, [16]=52717 }, classes = { 11 } },
            { id = 99182, slot = "Head", name = "Headpiece of the Shattered Vale", sources = { [17]=52324, [14]=52463, [16]=52609 }, classes = { 11 } },
            },
        },
        {
            index              = 12,
            name               = "Siegecrafter Blackfuse",
            journalEncounterID = 865,
            aliases            = {},
            achievements       = {
                { id = 8543, name = "Lasers and Magnets and Drills! Oh My!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 112882, slot = "Hands", name = "Calixian Bladebreakers", sources = { [17]=61866, [14]=61865, [15]=61865, [16]=61867 } },
                { id = 112890, slot = "Feet", name = "Powder-Stained Totemic Treads", sources = { [17]=61869, [14]=61868, [15]=61868, [16]=61870 } },
                { id = 112892, slot = "Two-Hand", name = "Lever of the Megantholithic Apparatus", sources = { [17]=61872, [14]=61871, [15]=61871, [16]=61873 } },
                { id = 112895, slot = "Wrist", name = "Bracers of Infinite Pipes", sources = { [17]=61875, [14]=61874, [15]=61874, [16]=61876 } },
                { id = 112896, slot = "Wrist", name = "Bomber's Blackened Wristwatch", sources = { [17]=61878, [14]=61877, [15]=61877, [16]=61879 } },
                { id = 112897, slot = "Weapon", name = "Siegecrafter's Forge Hammer", sources = { [17]=61881, [14]=61880, [15]=61880, [16]=61882 } },
                { id = 112898, slot = "Hands", name = "Fusespark Gloves", sources = { [17]=61884, [14]=61883, [15]=61883, [16]=61885 } },
            { id = 99196, slot = "Shoulder", name = "Shoulderguards of the Prehistoric Marauder", sources = { [17]=52311, [14]=52477, [16]=52688 }, classes = { 1 } },
            { id = 99200, slot = "Shoulder", name = "Pauldrons of the Prehistoric Marauder", sources = { [17]=52317, [14]=52481, [16]=52695 }, classes = { 1 } },
            { id = 99132, slot = "Shoulder", name = "Pauldrons of Winged Triumph", sources = { [17]=52268, [14]=52413, [16]=52654 }, classes = { 2 } },
            { id = 99130, slot = "Shoulder", name = "Shoulderguards of Winged Triumph", sources = { [17]=52308, [14]=52411, [16]=52645 }, classes = { 2 } },
            { id = 99125, slot = "Shoulder", name = "Mantle of Winged Triumph", sources = { [17]=52357, [14]=52406, [16]=52659 }, classes = { 2 } },
            { id = 99159, slot = "Shoulder", name = "Spaulders of the Unblinking Vigil", sources = { [17]=52363, [14]=52440, [16]=52685 }, classes = { 3 } },
            { id = 99116, slot = "Shoulder", name = "Spaulders of the Barbed Assassin", sources = { [17]=52291, [14]=52397, [16]=52916 }, classes = { 4 } },
            { id = 99111, slot = "Shoulder", name = "Shoulderguards of the Ternion Glory", sources = { [17]=52286, [14]=52392, [16]=52909 }, classes = { 5 } },
            { id = 99120, slot = "Shoulder", name = "Mantle of the Ternion Glory", sources = { [17]=52299, [14]=52401, [16]=52866 }, classes = { 5 } },
            { id = 99179, slot = "Shoulder", name = "Shoulderguards of Cyclopean Dread", sources = { [17]=52321, [14]=52460, [16]=52933 }, classes = { 6 } },
            { id = 99187, slot = "Shoulder", name = "Pauldrons of Cyclopean Dread", sources = { [17]=52340, [14]=52468, [16]=52920 }, classes = { 6 } },
            { id = 99105, slot = "Shoulder", name = "Spaulders of Celestial Harmony", sources = { [17]=52258, [14]=52386, [16]=52624 }, classes = { 7 } },
            { id = 99100, slot = "Shoulder", name = "Mantle of Celestial Harmony", sources = { [17]=52272, [14]=52381, [16]=52627 }, classes = { 7 } },
            { id = 99095, slot = "Shoulder", name = "Shoulderwraps of Celestial Harmony", sources = { [17]=52372, [14]=52376, [16]=52615 }, classes = { 7 } },
            { id = 99153, slot = "Shoulder", name = "Chronomancer Mantle", sources = { [17]=52360, [14]=52434, [16]=52682 }, classes = { 8 } },
            { id = 99205, slot = "Shoulder", name = "Mantle of the Horned Nightmare", sources = { [17]=52326, [14]=52486, [16]=52698 }, classes = { 9 } },
            { id = 99144, slot = "Shoulder", name = "Shoulderguards of Seven Sacred Seals", sources = { [17]=52332, [14]=52425, [16]=52667 }, classes = { 10 } },
            { id = 99151, slot = "Shoulder", name = "Mantle of Seven Sacred Seals", sources = { [17]=52343, [14]=52432, [16]=52662 }, classes = { 10 } },
            { id = 99146, slot = "Shoulder", name = "Spaulders of Seven Sacred Seals", sources = { [17]=52356, [14]=52427, [16]=52676 }, classes = { 10 } },
            { id = 99166, slot = "Shoulder", name = "Shoulderguards of the Shattered Vale", sources = { [17]=52259, [14]=52447, [16]=52704 }, classes = { 11 } },
            { id = 99169, slot = "Shoulder", name = "Shoulderwraps of the Shattered Vale", sources = { [17]=52279, [14]=52450, [16]=52709 }, classes = { 11 } },
            { id = 99173, slot = "Shoulder", name = "Mantle of the Shattered Vale", sources = { [17]=52297, [14]=52454, [16]=52712 }, classes = { 11 } },
            { id = 99184, slot = "Shoulder", name = "Spaulders of the Shattered Vale", sources = { [17]=52303, [14]=52465, [16]=52603 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 104158, kind = "pet", name = "Blackfuse Bombling" },
            },
        },
        {
            index              = 13,
            name               = "Paragons of the Klaxxi",
            journalEncounterID = 853,
            aliases            = {},
            achievements       = {
                { id = 8531, name = "Now We are the Paragon", meta = true, soloable = "kinda" },
            },
            soloTip            = "To avoid bugging the encounter, let each group of 3 fully land before killing any.",
            loot = {
                { id = 112914, slot = "Wrist", name = "Bracers of Sonic Projection", sources = { [17]=61888, [14]=61887, [15]=61887, [16]=61889 } },
                { id = 112915, slot = "Hands", name = "Gauntlets of Insane Calculations", sources = { [17]=61891, [14]=61890, [15]=61890, [16]=61892 } },
                { id = 112918, slot = "Ranged", name = "Hisek's Reserve Longbow", sources = { [17]=61894, [14]=61893, [15]=61893, [16]=61895 } },
                { id = 112919, slot = "Chest", name = "Chestguard of Toxic Injections", sources = { [17]=61897, [14]=61896, [15]=61896, [16]=61898 } },
                { id = 112920, slot = "Weapon", name = "Korven's Crimson Crescent", sources = { [17]=61900, [14]=61899, [15]=61899, [16]=61901 } },
                { id = 112921, slot = "Weapon", name = "Kil'ruk's Furious Blade", sources = { [17]=61903, [14]=61902, [15]=61902, [16]=61904 } },
                { id = 112922, slot = "Weapon", name = "Rik'kal's Bloody Scalpel", sources = { [17]=61906, [14]=61905, [15]=61905, [16]=61907 } },
                { id = 112923, slot = "Chest", name = "Amber Parasite Wraps", sources = { [17]=61909, [14]=61908, [15]=61908, [16]=61910 } },
            { id = 99195, slot = "Legs", name = "Legguards of the Prehistoric Marauder", sources = { [17]=52314, [14]=52476, [16]=52691 }, classes = { 1 } },
            { id = 99199, slot = "Legs", name = "Legplates of the Prehistoric Marauder", sources = { [17]=52316, [14]=52480, [16]=52694 }, classes = { 1 } },
            { id = 99124, slot = "Legs", name = "Greaves of Winged Triumph", sources = { [17]=52261, [14]=52405, [16]=52658 }, classes = { 2 } },
            { id = 99139, slot = "Legs", name = "Legplates of Winged Triumph", sources = { [17]=52267, [14]=52420, [16]=52653 }, classes = { 2 } },
            { id = 99129, slot = "Legs", name = "Legguards of Winged Triumph", sources = { [17]=52307, [14]=52410, [16]=52652 }, classes = { 2 } },
            { id = 99158, slot = "Legs", name = "Legguards of the Unblinking Vigil", sources = { [17]=52362, [14]=52439, [16]=52684 }, classes = { 3 } },
            { id = 99115, slot = "Legs", name = "Legguards of the Barbed Assassin", sources = { [17]=52290, [14]=52396, [16]=52630 }, classes = { 4 } },
            { id = 99123, slot = "Legs", name = "Leggings of the Ternion Glory", sources = { [17]=52302, [14]=52404, [16]=52642 }, classes = { 5 } },
            { id = 99118, slot = "Legs", name = "Legwraps of the Ternion Glory", sources = { [17]=52306, [14]=52399, [16]=52648 }, classes = { 5 } },
            { id = 99191, slot = "Legs", name = "Legguards of Cyclopean Dread", sources = { [17]=52320, [14]=52472, [16]=52605 }, classes = { 6 } },
            { id = 99186, slot = "Legs", name = "Greaves of Cyclopean Dread", sources = { [17]=52339, [14]=52467, [16]=52619 }, classes = { 6 } },
            { id = 99104, slot = "Legs", name = "Legguards of Celestial Harmony", sources = { [17]=52265, [14]=52385, [16]=52623 }, classes = { 7 } },
            { id = 99099, slot = "Legs", name = "Legwraps of Celestial Harmony", sources = { [17]=52271, [14]=52380, [16]=52635 }, classes = { 7 } },
            { id = 99094, slot = "Legs", name = "Leggings of Celestial Harmony", sources = { [17]=52371, [14]=52375, [16]=52614 }, classes = { 7 } },
            { id = 99162, slot = "Legs", name = "Chronomancer Leggings", sources = { [17]=52358, [14]=52443, [16]=52680 }, classes = { 8 } },
            { id = 99098, slot = "Legs", name = "Leggings of the Horned Nightmare", sources = { [17]=52336, [14]=52379, [16]=52707 }, classes = { 9 } },
            { id = 99143, slot = "Legs", name = "Legguards of Seven Sacred Seals", sources = { [17]=52331, [14]=52424, [16]=52666 }, classes = { 10 } },
            { id = 99149, slot = "Legs", name = "Legwraps of Seven Sacred Seals", sources = { [17]=52351, [14]=52430, [16]=52671 }, classes = { 10 } },
            { id = 99145, slot = "Legs", name = "Leggings of Seven Sacred Seals", sources = { [17]=52355, [14]=52426, [16]=52675 }, classes = { 10 } },
            { id = 99165, slot = "Legs", name = "Breeches of the Shattered Vale", sources = { [17]=52262, [14]=52446, [16]=52703 }, classes = { 11 } },
            { id = 99176, slot = "Legs", name = "Leggings of the Shattered Vale", sources = { [17]=52277, [14]=52457, [16]=52715 }, classes = { 11 } },
            { id = 99171, slot = "Legs", name = "Legwraps of the Shattered Vale", sources = { [17]=52295, [14]=52452, [16]=52710 }, classes = { 11 } },
            { id = 99183, slot = "Legs", name = "Legguards of the Shattered Vale", sources = { [17]=52325, [14]=52464, [16]=52610 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 104165, kind = "pet", name = "Kovok" },
            },
        },
        {
            index              = 14,
            name               = "Garrosh Hellscream",
            journalEncounterID = 869,
            aliases            = {},
            achievements       = {
                { id = 8537, name = "Strike!", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 112925, slot = "Two-Hand", name = "Xal'atoh, Desecrated Image of Gorehowl", sources = { [17]=61912, [14]=61911, [15]=61911, [16]=61913 } },
                { id = 112926, slot = "Head", name = "Kor'kron Elite Skullmask", sources = { [17]=61915, [14]=61914, [15]=61914, [16]=61916 } },
                { id = 112927, slot = "Shoulder", name = "Shoulderguards of Intended Power", sources = { [17]=61918, [14]=61917, [15]=61917, [16]=61919 } },
                { id = 112928, slot = "Head", name = "Greathelm of the Warchief", sources = { [17]=61921, [14]=61920, [15]=61920, [16]=61922 } },
                { id = 112929, slot = "Waist", name = "Cord of Black Dreams", sources = { [17]=61924, [14]=61923, [15]=61923, [16]=61925 } },
                { id = 112930, slot = "Head", name = "Penetrating Gaze of Y'Shaarj", sources = { [17]=61927, [14]=61926, [15]=61926, [16]=61928 } },
                { id = 112931, slot = "Chest", name = "Chestguard of Relentless Tyranny", sources = { [17]=61930, [14]=61929, [15]=61929, [16]=61931 } },
                { id = 112932, slot = "Two-Hand", name = "Kor'kron Spire of Supremacy", sources = { [17]=61933, [14]=61932, [15]=61932, [16]=61934 } },
                { id = 112933, slot = "Legs", name = "Legplates of Unthinking Strife", sources = { [17]=61936, [14]=61935, [15]=61935, [16]=61937 } },
                { id = 112934, slot = "Shoulder", name = "Spaulders of the Fallen Warchief", sources = { [17]=61939, [14]=61938, [15]=61938, [16]=61940 } },
                { id = 112935, slot = "Shoulder", name = "Tusks of Mannoroth", sources = { [15]=93949, [16]=61943 } },
                { id = 112936, slot = "Waist", name = "Belt of the Broken Pact", sources = { [17]=61945, [14]=61944, [15]=61944, [16]=61946 } },
                { id = 112937, slot = "Head", name = "Ebon Ritual Hood", sources = { [17]=61948, [14]=61947, [15]=61947, [16]=61949 } },
                { id = 112939, slot = "Weapon", name = "Horned Mace of the Old Ones", sources = { [17]=61951, [14]=61950, [15]=61950, [16]=61952 } },
                { id = 112940, slot = "Off-hand", name = "Revelations of Y'Shaarj", sources = { [17]=61954, [14]=61953, [15]=61953, [16]=61955 } },
                { id = 112941, slot = "Waist", name = "Seal of Karmic Return", sources = { [17]=61957, [14]=61956, [15]=61956, [16]=61958 } },
                { id = 112942, slot = "Shoulder", name = "Hopeglow Spaulders", sources = { [17]=61960, [14]=61959, [15]=61959, [16]=61961 } },
                { id = 112943, slot = "Head", name = "Cowl of Smoking Dreams", sources = { [17]=61964, [14]=61963, [15]=61963, [16]=61965 } },
                { id = 112944, slot = "Chest", name = "Chestplate of Fallen Passion", sources = { [17]=61967, [14]=61966, [15]=61966, [16]=61968 } },
                { id = 112945, slot = "Shoulder", name = "Mantle of Looming Darkness", sources = { [17]=61970, [14]=61969, [15]=61969, [16]=61971 } },
            },
            specialLoot = {
                { id = 104253, kind = "mount", name = "Kor'kron Juggernaut" },
                { id = 253242, kind = "decor", decorID = 9263, name = "Horde Warlord's Throne" },
            },
        },
    },

    routing = {

        -- 1. Immerseus
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Immerseus",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 557, subZone = "Pools of Power" },
                    kind    = "path",
                    note    = "After zoning in, head down the stairs and move straight ahead to engage ^Immerseus^.",
                    points  = {
                        { 0.849, 0.454 },
                        { 0.835, 0.521 },
                        { 0.792, 0.568 },
                        { 0.739, 0.567 },
                        { 0.690, 0.497 },
                        { 0.515, 0.494 },
                        { 0.444, 0.474 },
                    },
                },
            },
        },

        -- 2. The Fallen Protectors
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "The Fallen Protectors",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 557, subZone = "Pools of Power" },
                    kind    = "path",
                    note    = "After defeating ^Immerseus^, take the tall western stairwell behind him.",
                    points  = {
                        { 0.325, 0.454 },
                        { 0.147, 0.451 },
                    },
                },
                {
                    when        = { mapID = 557, subZone = "Ruined Passage" },
                    kind        = "poi",
                    mapLabel    = "Stand in Light, Click Button",
                    mapLabelPos = "above",
                    note        = "Walk into the ^beam of light^ and click the ^Extra Action Button^ to trigger a cutscene. After the cutscene, go up the stairs and jump off the ledge.",
                    points  = {
                        { 0.118, 0.453 },
                    },
                },
                {
                    when    = { mapID = 557, subZone = "Ruined Passage" },
                    kind    = "path",
                    points  = {
                        { 0.117, 0.507 },
                        { 0.117, 0.696 },
                    },
                },
                {
                    when     = { mapID = 556 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "After jumping in the hole, engage ^The Fallen Protectors^.",
                    points  = {
                        { 0.250, 0.148 },
                    },
                },
            },
        },

        -- 3. Norushen
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Norushen",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 556, subZone = "Scarred Vale" },
                    kind    = "path",
                    note    = "After defeating ^The Fallen Protectors^, follow the path to the mineshaft. Kill ^Zeal^ to unlock the way.",
                    points  = {
                        { 0.330, 0.194 },
                        { 0.376, 0.361 },
                        { 0.437, 0.438 },
                        { 0.452, 0.577 },
                        { 0.431, 0.705 },
                    },
                },
                {
                    when    = { mapID = 558, subZone = "Big Blossom Mine" },
                    kind    = "path",
                    note    = "Follow the mineshaft into the next room. After a lengthy dialog, speak to ^Norushen^ to start the encounter.",
                    points  = {
                        { 0.592, 0.168 },
                        { 0.571, 0.206 },
                        { 0.568, 0.269 },
                        { 0.587, 0.318 },
                        { 0.622, 0.353 },
                        { 0.664, 0.357 },
                        { 0.701, 0.355 },
                        { 0.731, 0.526 },
                        { 0.576, 0.583 },
                    },
                },
            },
        },

        -- 4. Sha of Pride
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Sha of Pride",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 558, subZone = "Chamber of Purification" },
                    kind    = "path",
                    note    = "After completing the ^Norushen^ encounter, move ahead into the next room and clear all trash to start the fight with ^Sha of Pride^.",
                    points  = {
                        { 0.477, 0.611 },
                        { 0.319, 0.658 },
                    },
                },
            },
        },

        -- 5. Galakras
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Galakras",
            requires  = {},
            segments  = {
                {
                    when        = { mapID = 558, subZone = "Vault of Y'Shaarj" },
                    kind        = "poi",
                    mapLabel    = "Click Portal",
                    mapLabelPos = "above",
                    note        = "After defeating ^Sha of Pride^, watch some dialog then click the portal in the southwest corner of the room.",
                    points  = {
                        { 0.223, 0.834 },
                    },
                },
                {
                    when    = { mapID = bladefistMapID, subZone = "Bladefist Bay" },
                    kind    = "path",
                    note    = galakrasGreetNote,
                    points  = {
                        { 0.862, 0.280 },
                        { 0.795, 0.290 },
                    },
                },
                {
                    when    = { mapID = 559, subZone = "Dranosh'ar Landing" },
                    kind    = "poi",
                    mapLabel    = "Kill Cannons",
                    mapLabelPos = "above",
                    completionCheck = true,
                    note    = "On the beach, your goal is to destroy (7) ^Kor'kron Cannons^. Click the ^Spike Mines^ next to each cannon to destroy them.",
                    points  = {
                        { 0.801, 0.351 },
                        { 0.833, 0.408 },
                        { 0.848, 0.471 },
                    },
                },
                {
                    when        = { mapID = 559, subZone = "Dranosh'ar Landing" },
                    kind        = "path",
                    note        = galakrasReturnNote,
                    triggeredBy = { dialog = { npc = "Warlord Zaela", match = "Your blood will fill this bay" } },
                    points  = {},
                },
            },
        },

        -- 6. Iron Juggernaut
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Iron Juggernaut",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 559, subZone = "Dranosh'ar Landing" },
                    kind    = "path",
                    note    = "After killing ^Galakras^, follow the long path to the west until you arrive at ^Iron Juggernaut^.",
                    points  = {
                        { 0.689, 0.322 },
                        { 0.631, 0.370 },
                        { 0.567, 0.403 },
                        { 0.561, 0.515 },
                        { 0.528, 0.600 },
                        { 0.460, 0.679 },
                        { 0.386, 0.712 },
                        { 0.345, 0.665 },
                        { 0.347, 0.555 },
                        { 0.326, 0.454 },
                    },
                },
            },
        },

        -- 7. Kor'kron Dark Shaman
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Kor'kron Dark Shaman",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 559, subZone = "Before the Gates" },
                    kind    = "path",
                    note    = "After killing ^Iron Juggernaut^, head into the ^Gates of Orgrimmar^.",
                    points  = {
                        { 0.318, 0.442 },
                        { 0.298, 0.324 },
                        { 0.303, 0.274 },
                    },
                },
                {
                    when    = { mapID = 560, subZone = "Valley of Strength" },
                    kind    = "path",
                    note    = "Inside ^Orgrimmar^, move ahead into the boss tower to fight ^Kor'kron Dark Shaman^.",
                    points  = {
                        { 0.512, 0.743 },
                        { 0.491, 0.652 },
                    },
                },
            },
        },

        -- 8. General Nazgrim
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "General Nazgrim",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 560, subZone = "Valley of Strength" },
                    kind    = "path",
                    note    = "After killing ^Kor'kron Dark Shaman^, follow the northeastern path towards ^The Drag^. Clear trash and enter the ^Cleft of Shadows^.",
                    points  = {
                        { 0.504, 0.666 },
                        { 0.508, 0.574 },
                        { 0.495, 0.495 },
                        { 0.520, 0.471 },
                        { 0.562, 0.483 },
                        { 0.601, 0.446 },
                        { 0.616, 0.389 },
                        { 0.605, 0.332 },
                        { 0.587, 0.288 },
                        { 0.572, 0.261 },
                        { 0.553, 0.245 },
                        { 0.536, 0.288 },
                    },
                },
                {
                    when    = { mapID = 561, subZone = "Cleft of Shadow" },
                    kind    = "path",
                    note    = "Inside the ^Cleft of Shadows^, jump off to the left and head into another tunnel.",
                    points  = {
                        { 0.728, 0.154 },
                        { 0.697, 0.202 },
                        { 0.700, 0.272 },
                        { 0.698, 0.347 },
                        { 0.664, 0.387 },
                        { 0.583, 0.455 },
                        { 0.606, 0.509 },
                        { 0.696, 0.501 },
                    },
                },
                {
                    when    = { mapID = 562, subZone = "Ragefire Chasm" },
                    kind    = "path",
                    note    = "Inside the next tunnel, follow the long path to reach ^General Nazgrim^.",
                    points  = {
                        { 0.344, 0.174 },
                        { 0.399, 0.158 },
                        { 0.412, 0.280 },
                        { 0.461, 0.396 },
                        { 0.496, 0.481 },
                        { 0.511, 0.534 },
                        { 0.564, 0.605 },
                        { 0.587, 0.674 },
                        { 0.627, 0.719 },
                    },
                },
            },
        },

        -- 9. Malkorok
        {
            step      = 9,
            priority  = 9,
            bossIndex = 9,
            title     = "Malkorok",
            requires  = {},
            segments  = {
                {
                    when        = { mapID = 562, subZone = "Ragefire Chasm" },
                    kind        = "poi",
                    mapLabel    = "Elevator",
                    mapLabelPos = "above",
                    note        = "After defeating ^General Nazgrim^, take the elevator down in the northeastern section of the room.",
                    points  = {
                        { 0.761, 0.612 },
                    },
                },
                {
                    when    = { mapID = 563, subZone = "Rough-Hewn Passage" },
                    kind    = "path",
                    note    = "In the next area, follow the path around a few turns and up some stairs, killing trash on your way to ^Malkorok^.",
                    points  = {
                        { 0.239, 0.603 },
                        { 0.292, 0.556 },
                        { 0.385, 0.573 },
                        { 0.408, 0.624 },
                        { 0.487, 0.631 },
                        { 0.572, 0.559 },
                        { 0.592, 0.600 },
                        { 0.525, 0.661 },
                        { 0.432, 0.460 },
                    },
                },
            },
        },

        -- 10. Spoils of Pandaria
        {
            step      = 10,
            priority  = 10,
            bossIndex = 10,
            title     = "Spoils of Pandaria",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 563, subZone = "Kor'kron Barracks" },
                    kind    = "path",
                    note    = "After killing ^Malkorok^, take the northwestern exit from the platform and follow it around to kill the scorpion and click ^Release Lever^.",
                    points  = {
                        { 0.397, 0.381 },
                        { 0.307, 0.174 },
                        { 0.375, 0.113 },
                        { 0.469, 0.326 },
                    },
                },
                {
                    when        = { mapID = 563, subZone = "Kor'kron Barracks" },
                    kind        = "poi",
                    mapLabel    = "Release Lever",
                    mapLabelPos = "above",
                    completionCheck = true,
                    points  = {
                        { 0.482, 0.356 },
                    },
                },
                {
                    when        = { mapID = 563, subZone = "Kor'kron Barracks" },
                    kind        = "path",
                    note        = "After clicking the lever, travel through the opened door to the northeast and follow it around to a big clearing. Take the southwestern door.",
                    triggeredBy = spoilsDoorTrigger,
                    points  = {
                        { 0.541, 0.299 },
                        { 0.631, 0.230 },
                        { 0.807, 0.600 },
                    },
                },
                {
                    when        = { mapID = 563, subZone = "Kor'kron Barracks" },
                    kind        = "poi",
                    mapLabel    = "Go Here",
                    mapLabelPos = "above",
                    points  = {
                        { 0.781, 0.738 },
                    },
                },
                {
                    when    = { mapID = 564, subZone = "Artifact Storage" },
                    kind    = "path",
                    note    = "Once inside ^Artifact Storage^, continue forward and click on the ^Secured Stockpile of Pandaren Spoils^ to begin the ^Spoils of Pandaria^ encounter.",
                    points  = {
                        { 0.620, 0.197 },
                        { 0.552, 0.259 },
                    },
                },
            },
        },

        -- 11. Thok the Bloodthirsty
        {
            step      = 11,
            priority  = 11,
            bossIndex = 11,
            title     = "Thok the Bloodthirsty",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 564, subZone = "Artifact Storage" },
                    kind    = "path",
                    note    = "After completing the ^Spoils of Pandaria^ encounter, follow the path ahead to reach ^Thok the Bloodthirsty^.",
                    points  = {
                        { 0.499, 0.313 },
                        { 0.386, 0.423 },
                        { 0.362, 0.509 },
                        { 0.403, 0.574 },
                        { 0.492, 0.777 },
                    },
                },
            },
        },

        -- 12. Siegecrafter Blackfuse
        {
            step      = 12,
            priority  = 12,
            bossIndex = 12,
            title     = "Siegecrafter Blackfuse",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 564, subZone = "The Menagerie" },
                    kind    = "path",
                    note    = "After defeating ^Thok^, backtrack all the way past ^Spoils of Pandaria^ to arrive back in ^Underhold Nexus^.",
                    points  = {
                        { 0.471, 0.728 },
                        { 0.364, 0.503 },
                        { 0.409, 0.406 },
                        { 0.653, 0.163 },
                    },
                },
                {
                    when        = { mapID = 563, subZone = "Underhold Nexus" },
                    kind        = "poi",
                    mapLabel    = "Go Here",
                    mapLabelPos = "above",
                    note        = "Back in ^Underhold Nexus^, go straight ahead to another door marked on the map.",
                    points  = {
                        { 0.902, 0.621 },
                    },
                },
                {
                    when        = { mapID = 565, subZone = "The Siegeworks" },
                    kind        = "poi",
                    mapLabel    = "Jump in tunnel",
                    mapLabelPos = "above",
                    note        = "In the next area, kill several waves of trash. After killing ^Shanna Sparkfizz^, jump in the pipe to reach ^Siegecrafter Blackfuse^.",
                    points  = {
                        { 0.474, 0.584 },
                    },
                },
            },
        },

        -- 13. Paragons of the Klaxxi
        {
            step      = 13,
            priority  = 13,
            bossIndex = 13,
            title     = "Paragons of the Klaxxi",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 565, subZone = "The Siegeworks" },
                    kind    = "path",
                    note    = "After defeating ^Siegecrafter Blackfuse^, jump back in the pipe towards the room entrance. Continue southwest back the way you came.",
                    points  = {
                        { 0.508, 0.542 },
                        { 0.223, 0.831 },
                    },
                },
                {
                    when        = { mapID = 563, subZone = "Underhold Nexus" },
                    kind        = "poi",
                    mapLabel    = "Go Here",
                    mapLabelPos = "above",
                    note        = "Back in the ^Underhold Nexus^, take the southern (final) door marked on the map.",
                    points  = {
                        { 0.884, 0.773 },
                    },
                },
                {
                    when    = { mapID = 566, subZone = "Rough-Hewn Passage" },
                    kind    = "path",
                    note    = "After walking through the door, follow the path to ^Paragons of the Klaxxi^. Clear trash and click ^Mantid Amber^ in the middle of the room to start the encounter.",
                    points  = {
                        { 0.345, 0.196 },
                        { 0.389, 0.242 },
                        { 0.436, 0.214 },
                        { 0.471, 0.147 },
                        { 0.504, 0.098 },
                        { 0.550, 0.096 },
                        { 0.583, 0.130 },
                        { 0.664, 0.315 },
                    },
                },
            },
        },

        -- 14. Garrosh Hellscream
        {
            step      = 14,
            priority  = 14,
            bossIndex = 14,
            title     = "Garrosh Hellscream",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 566, subZone = "Chamber of the Paragons" },
                    kind    = "path",
                    note    = "After defeating the ^Paragons of the Klaxxi^, take the new exit on the south side of the room. As you approach ^Garrosh^, pull the hallway trash with you and most of the dialog will be skipped!",
                    points  = {
                        { 0.719, 0.433 },
                        { 0.805, 0.663 },
                        { 0.665, 0.881 },
                        { 0.650, 0.938 },
                    },
                },
                {
                    when    = { mapID = 567, subZone = "The Inner Sanctum" },
                    kind    = "path",
                    note    = "After opening the door, proceed ahead to witness a lengthy dialog before engaging ^Garrosh Hellscream^.",
                    points  = {
                        { 0.534, 0.139 },
                        { 0.490, 0.665 },
                    },
                },
            },
        },

    },

    skipToBoss = "Garrosh Hellscream",


    skipRoute = {

        -- 1. Garrosh Hellscream, reached directly from the entrance by reading
        --    the Scroll of Past Deeds beside Lorewalker Cho (skips bosses 1-13).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 14,
            title     = "Garrosh Hellscream",
            requires  = {},
            segments  = {
                {
                    when     = { mapID = 557, subZone = "Pools of Power" },
                    kind     = "poi",
                    mapLabel = "Click Scroll",
                    mapLabelPos = "above",
                    note     = "After zoning in, click the ^Scroll of Past Deeds^ on the wall to skip ahead to ^Garrosh^. It's on the wall next to ^Lorewalker Cho^.",
                    points   = {
                        { 0.881, 0.436 },
                    },
                },
                {
                    when    = { mapID = 567, subZone = "The Inner Sanctum" },
                    kind    = "path",
                    note    = "After teleporting, proceed ahead to witness a lengthy dialog before engaging ^Garrosh Hellscream^.",
                    points  = {
                        { 0.534, 0.139 },
                        { 0.490, 0.665 },
                    },
                },
            },
        },

    },
}
