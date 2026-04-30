-------------------------------------------------------------------------------
-- RetroRuns Data -- Aberrus, the Shadowed Crucible
-- Dragonflight, Patch 10.1  |  instanceID: 2569  |  journalInstanceID: 1208
-------------------------------------------------------------------------------
-- Aberrus is the second Dragonflight raid (10.1, Embers of Neltharion). 9
-- bosses set in Neltharion's hidden experimentation laboratory beneath the
-- Forbidden Reach. One structural note worth understanding when reading
-- this file:
--
-- The lockout has a branching shape: after Kazzara, two pairs unlock in
-- parallel (Amalgamation Chamber + Forgotten Experiments on one side,
-- Assault of the Zaqali + Rashok on the other). Both pairs must complete
-- before Zskarn's wing opens. From there it's a linear chain (Zskarn ->
-- Magmorax -> Echo of Neltharion -> Sarkareth). routing[] flattens this
-- into a single recommended order chosen for shortest in-zone walking
-- distance; players who diverge will see "next step still locked"
-- guidance from the addon even though their lockout would permit the
-- kill. Same trade-off Vault's branching wings made.
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2569] = {
    instanceID        = 2569,
    journalInstanceID = 1208,
    name              = "Aberrus, the Shadowed Crucible",
    expansion         = "Dragonflight",
    patch             = "10.1",

    -- Sub-zone mapIDs for Aberrus's five wings. Names match the in-game
    -- world-map dropdown verbatim. Used by the routing renderer to label
    -- the active region in the panel header.
    maps = {
        [2166] = "Molten Crucible",
        [2167] = "Onyx Laboratory",
        [2168] = "Defiant Ramparts",
        [2169] = "Neltharion's Sanctum",
        [2170] = "Edge of Oblivion",
    },

    -- Dragonflight Season 2 tier set: "Aberrus, the Shadowed Crucible"
    -- token family. Marketing names follow a verb-form scientific
    -- convention paired with "Fluid": Melting=Head, Corrupting=Shoulder,
    -- Ventilation=Chest, Mixing=Hands, Cooling=Legs.
    --
    -- Sarkareth additionally drops Void-Touched Curio, an omnitoken that
    -- exchanges for any tier slot of choice. It's surfaced as a footnote
    -- on Sarkareth's transmog browser view rather than as a tracked
    -- token (since it can become any of the five tier slots).
    tierSets = {
        labels = {
            "Aberrus, the Shadowed Crucible",  -- setID=2858
        },
        tokenSources = {
            -- Forgotten Experiments (Hands)
            [202624] = 3,  -- Dreadful Mixing Fluid
            [202625] = 3,  -- Mystic Mixing Fluid
            [202626] = 3,  -- Venerated Mixing Fluid
            [202638] = 3,  -- Zenith Mixing Fluid
            -- Rashok (Legs)
            [202634] = 5,  -- Dreadful Cooling Fluid
            [202635] = 5,  -- Mystic Cooling Fluid
            [202636] = 5,  -- Venerated Cooling Fluid
            [202640] = 5,  -- Zenith Cooling Fluid
            -- Zskarn (Chest)
            [202631] = 6,  -- Dreadful Ventilation Fluid
            [202632] = 6,  -- Mystic Ventilation Fluid
            [202633] = 6,  -- Venerated Ventilation Fluid
            [202639] = 6,  -- Zenith Ventilation Fluid
            -- Magmorax (Head)
            [202627] = 7,  -- Dreadful Melting Fluid
            [202628] = 7,  -- Mystic Melting Fluid
            [202629] = 7,  -- Venerated Melting Fluid
            [202630] = 7,  -- Zenith Melting Fluid
            -- Echo of Neltharion (Shoulder)
            [202621] = 8,  -- Dreadful Corrupting Fluid
            [202622] = 8,  -- Mystic Corrupting Fluid
            [202623] = 8,  -- Venerated Corrupting Fluid
            [202637] = 8,  -- Zenith Corrupting Fluid
        },
    },

    -- Raid skip quests. Account-wide unlock per Patch 11.0.5; check via
    -- C_QuestLog.IsQuestFlaggedCompletedOnAccount. Per-character
    -- IsQuestFlaggedCompleted does NOT reflect the unlock for alts that
    -- did not personally complete the quest.
    --
    -- Only the questID for the difficulty actually completed returns
    -- true; the in-game cascade that lets you use the skip on lower
    -- difficulties happens at the skip NPC, NOT by backfilling the
    -- per-difficulty quest flags. To detect "skip is available at any
    -- difficulty", OR across all three IDs.
    skipQuests = {
        normal = 76083,
        heroic = 76085,
        mythic = 76086,
    },

    bosses = {
        {
            index              = 1,
            name               = "Kazzara, the Hellforged",
            journalEncounterID = 2522,
            aliases            = { "Kazzara" },
            achievements = {
                { id = 18229, name = "Cosplate", meta = true },
            },
            loot = {
                { id=202573, slot="Back",     name="Etchings of the Captive Revenant", sources={ [17]=186778, [14]=184546, [15]=186776, [16]=186777 } },
                { id=202600, slot="Chest",    name="Reanimator's Wicked Cassock",      sources={ [17]=186510, [14]=184573, [15]=186508, [16]=186509 } },
                { id=202576, slot="Feet",     name="Dreadrift Stompers",               sources={ [17]=186655, [14]=184549, [15]=186653, [16]=186654 } },
                { id=202583, slot="Hands",    name="Grasps of Welded Anguish",         sources={ [17]=186525, [14]=184556, [15]=186523, [16]=186524 } },
                { id=202602, slot="Head",     name="Violent Gravemask",                sources={ [17]=186652, [14]=184575, [15]=186650, [16]=186651 } },
                { id=202590, slot="Shoulder", name="Kazzara's Grafted Companion",      sources={ [17]=186528, [14]=184563, [15]=186526, [16]=186527 } },
                { id=202559, slot="Two-Hand", name="Infernal Shadelance",              sources={ [17]=185480, [14]=184533, [15]=185481, [16]=185482 } },
                { id=202589, slot="Waist",    name="Sash of Abandoned Hope",           sources={ [17]=186465, [14]=184562, [15]=186463, [16]=186464 } },
                { id=202557, slot="Weapon",   name="Hellsteel Mutilator",              sources={ [17]=185494, [14]=184531, [15]=185495, [16]=185496 } },
                { id=202594, slot="Wrist",    name="Bloodstench Skinguards",           sources={ [17]=186613, [14]=184567, [15]=186611, [16]=186612 } },
            },
        },
        {
            index              = 2,
            name               = "The Amalgamation Chamber",
            journalEncounterID = 2529,
            aliases            = { "Amalgamation Chamber" },
            achievements = {
                { id = 18168, name = "I'll Make My Own Shadowflame", meta = true },
            },
            loot = {
                { id=202598, slot="Chest",    name="Cuirass of Meticulous Mixture",   sources={ [17]=186513, [14]=184571, [15]=186511, [16]=186512 } },
                { id=202579, slot="Head",     name="Attendant's Concocting Cover",    sources={ [17]=186489, [14]=184552, [15]=186487, [16]=186488 } },
                { id=202596, slot="Legs",     name="Tassets of Blistering Twilight",  sources={ [17]=186637, [14]=184569, [15]=186635, [16]=186636 } },
                { id=202595, slot="Shoulder", name="Shoulderplates of Planar Isolation", sources={ [17]=186688, [14]=184568, [15]=186686, [16]=186687 } },
                { id=202563, slot="Two-Hand", name="Obsidian Stirring Staff",         sources={ [17]=185506, [14]=184537, [15]=185507, [16]=185508 } },
                { id=202605, slot="Waist",    name="Gloomfused Chemistry Belt",       sources={ [17]=186537, [14]=184578, [15]=186535, [16]=186536 } },
                { id=202568, slot="Weapon",   name="Scholar's Thinking Cudgel",       sources={ [17]=185503, [14]=184542, [15]=185504, [16]=185505 } },
                { id=202593, slot="Wrist",    name="Unstable Vial Handlers",          sources={ [17]=186471, [14]=184566, [15]=186469, [16]=186470 } },
            },
        },
        {
            index              = 3,
            name               = "The Forgotten Experiments",
            journalEncounterID = 2530,
            aliases            = { "Forgotten Experiments" },
            achievements = {
                { id = 18173, name = "Tabula Rasa", meta = true },
            },
            loot = {
                { id=202588, slot="Feet",             name="Exacting Augmenter's Sabatons",   sources={ [17]=186555, [14]=184561, [15]=186553, [16]=186554 } },
                { id=204318, slot="Held In Off-hand", name="Thadrion's Erratic Arcanotrode",  sources={ [17]=185520, [14]=185521, [15]=185522, [16]=185523 } },
                { id=202571, slot="Off-hand",         name="Experiment 1, Kitewing",          sources={ [17]=185524, [14]=184545, [15]=185525, [16]=185526 } },
                { id=202575, slot="Shoulder",         name="Neldris's Sinewy Scapula",        sources={ [17]=186643, [14]=184548, [15]=186641, [16]=186642 } },
                { id=202652, slot="Waist",            name="Discarded Creation's Restraint",  sources={ [17]=186468, [14]=184584, [15]=186466, [16]=186467 } },
                { id=202566, slot="Weapon",           name="Rionthus's Bladed Visage",        sources={ [17]=185517, [14]=184540, [15]=185518, [16]=185519 } },
                { id=202582, slot="Wrist",            name="Manacles of Cruel Progress",      sources={ [17]=186670, [14]=184555, [15]=186668, [16]=186669 } },
                -- Tier Hands (13 classes, from Mixing Fluid tokens)
                { id=202444, slot="Hands", name="Handguards of the Onyx Crucible",   sources={ [17]=186318, [14]=184418, [15]=186316, [16]=186317 }, classes={ 1 } },
                { id=202453, slot="Hands", name="Heartfire Sentinel's Protectors",   sources={ [17]=186005, [14]=184427, [15]=186003, [16]=186004 }, classes={ 2 } },
                { id=202480, slot="Hands", name="Ashen Predator's Skinners",         sources={ [17]=186092, [14]=184454, [15]=186090, [16]=186091 }, classes={ 3 } },
                { id=202498, slot="Hands", name="Lurking Specter's Handgrips",       sources={ [17]=186125, [14]=184472, [15]=186123, [16]=186124 }, classes={ 4 } },
                { id=202543, slot="Hands", name="Grasp of the Furnace Seraph",       sources={ [17]=186255, [14]=184517, [15]=186253, [16]=186254 }, classes={ 5 } },
                { id=202462, slot="Hands", name="Lingering Phantom's Gauntlets",     sources={ [17]=186276, [14]=184436, [15]=186274, [16]=186275 }, classes={ 6 } },
                { id=202471, slot="Hands", name="Knuckles of the Cinderwolf",        sources={ [17]=186053, [14]=184445, [15]=186051, [16]=186052 }, classes={ 7 } },
                { id=202552, slot="Hands", name="Underlight Conjurer's Gloves",      sources={ [17]=186357, [14]=184526, [15]=186355, [16]=186356 }, classes={ 8 } },
                { id=202534, slot="Hands", name="Grips of the Sinister Savant",      sources={ [17]=186215, [14]=184508, [15]=186213, [16]=186214 }, classes={ 9 } },
                { id=202507, slot="Hands", name="Fists of the Vermillion Forge",     sources={ [17]=185780, [14]=184481, [15]=185781, [16]=185782 }, classes={ 10 } },
                { id=202516, slot="Hands", name="Handguards of the Autumn Blaze",    sources={ [17]=186170, [14]=184490, [15]=186168, [16]=186169 }, classes={ 11 } },
                { id=202525, slot="Hands", name="Kinslayer's Bloodstained Grips",    sources={ [17]=186438, [14]=184499, [15]=186436, [16]=186437 }, classes={ 12 } },
                { id=202489, slot="Hands", name="Claws of Obsidian Secrets",         sources={ [17]=186399, [14]=184463, [15]=186397, [16]=186398 }, classes={ 13 } },
            },
        },
        {
            index              = 4,
            name               = "Assault of the Zaqali",
            journalEncounterID = 2524,
            aliases            = { "Zaqali" },
            achievements = {
                { id = 18228, name = "Are You Even Trying?", meta = true },
            },
            loot = {
                { id=202586, slot="Chest",    name="Warlord's Volcanic Vest",          sources={ [17]=186640, [14]=184559, [15]=186638, [16]=186639 } },
                { id=202574, slot="Feet",     name="Flamebound Huntsman's Footpads",   sources={ [17]=186607, [14]=184547, [15]=186605, [16]=186606 } },
                { id=202578, slot="Hands",    name="Phoenix-Plume Gloves",             sources={ [17]=186501, [14]=184551, [15]=186499, [16]=186500 } },
                { id=202591, slot="Head",     name="Gatecrasher Giant's Coif",         sources={ [17]=186531, [14]=184564, [15]=186529, [16]=186530 } },
                { id=202597, slot="Legs",     name="Obsidian Guard's Chausses",        sources={ [17]=186682, [14]=184570, [15]=186680, [16]=186681 } },
                { id=202607, slot="Ranged",   name="Brutal Dragonslayer's Trophy",     sources={ [17]=185514, [14]=184580, [15]=185515, [16]=185516 } },
                { id=202580, slot="Shoulder", name="Mystic's Scalding Frame",          sources={ [17]=186492, [14]=184553, [15]=186490, [16]=186491 } },
                { id=202577, slot="Waist",    name="Seal of the Defiant Hordes",       sources={ [17]=186673, [14]=184550, [15]=186671, [16]=186672 } },
                { id=204279, slot="Weapon",   name="Wallclimber's Incursion Hatchet",  sources={ [17]=185509, [14]=185510, [15]=185511, [16]=185512 } },
                { id=202604, slot="Wrist",    name="Boulder-Tossing Bands",            sources={ [17]=186549, [14]=184577, [15]=186547, [16]=186548 } },
            },
        },
        {
            index              = 5,
            name               = "Rashok, the Elder",
            journalEncounterID = 2525,
            aliases            = { "Rashok" },
            achievements = {
                { id = 18230, name = "Whac-A-Swog", meta = true },
            },
            loot = {
                { id=202603, slot="Feet",     name="Sandals of Ancient Fury",          sources={ [17]=186483, [14]=184576, [15]=186481, [16]=186482 } },
                { id=202592, slot="Head",     name="Unyielding Goliath's Burgonet",    sources={ [17]=186691, [14]=184565, [15]=186689, [16]=186690 } },
                { id=202569, slot="Two-Hand", name="Djaruun, Pillar of the Elder Flame", sources={ [17]=185477, [14]=184543, [15]=185478, [16]=185479 } },
                { id=202655, slot="Waist",    name="Elder's Volcanic Binding",         sources={ [17]=186622, [14]=184587, [15]=186620, [16]=186621 } },
                { id=204319, slot="Weapon",   name="Bloodfire Extraction Conduit",     sources={ [17]=185527, [14]=185528, [15]=185529, [16]=185530 } },
                { id=202659, slot="Wrist",    name="Shackles of the Shadowed Bastille", sources={ [17]=186552, [14]=184591, [15]=186550, [16]=186551 } },
                -- Tier Legs (13 classes, from Cooling Fluid tokens)
                { id=202442, slot="Legs", name="Legplates of the Onyx Crucible",     sources={ [17]=186309, [14]=184416, [15]=186307, [16]=186308 }, classes={ 1 } },
                { id=202451, slot="Legs", name="Heartfire Sentinel's Faulds",        sources={ [17]=185993, [14]=184425, [15]=185991, [16]=185992 }, classes={ 2 } },
                { id=202478, slot="Legs", name="Ashen Predator's Poleyns",           sources={ [17]=186080, [14]=184452, [15]=186078, [16]=186079 }, classes={ 3 } },
                { id=202496, slot="Legs", name="Lurking Specter's Tights",           sources={ [17]=186119, [14]=184470, [15]=186117, [16]=186118 }, classes={ 4 } },
                { id=202541, slot="Legs", name="Breeches of the Furnace Seraph",     sources={ [17]=186243, [14]=184515, [15]=186241, [16]=186242 }, classes={ 5 } },
                { id=202460, slot="Legs", name="Lingering Phantom's Schynbalds",     sources={ [17]=186282, [14]=184434, [15]=186280, [16]=186281 }, classes={ 6 } },
                { id=202469, slot="Legs", name="Braies of the Cinderwolf",           sources={ [17]=186041, [14]=184443, [15]=186039, [16]=186040 }, classes={ 7 } },
                { id=202550, slot="Legs", name="Underlight Conjurer's Trousers",     sources={ [17]=186351, [14]=184524, [15]=186349, [16]=186350 }, classes={ 8 } },
                { id=202532, slot="Legs", name="Leggings of the Sinister Savant",    sources={ [17]=186203, [14]=184506, [15]=186201, [16]=186202 }, classes={ 9 } },
                { id=202505, slot="Legs", name="Pantaloons of the Vermillion Forge", sources={ [17]=185774, [14]=184479, [15]=185775, [16]=185776 }, classes={ 10 } },
                { id=202514, slot="Legs", name="Pants of the Autumn Blaze",          sources={ [17]=186158, [14]=184488, [15]=186156, [16]=186157 }, classes={ 11 } },
                { id=202523, slot="Legs", name="Kinslayer's Legguards",              sources={ [17]=186426, [14]=184497, [15]=186424, [16]=186425 }, classes={ 12 } },
                { id=202487, slot="Legs", name="Chausses of Obsidian Secrets",       sources={ [17]=186387, [14]=184461, [15]=186385, [16]=186386 }, classes={ 13 } },
            },
        },
        {
            index              = 6,
            name               = "The Vigilant Steward, Zskarn",
            journalEncounterID = 2532,
            aliases            = { "Vigilant Steward, Zskarn", "Zskarn" },
            achievements = {
                { id = 18193, name = "Eggscellent Eggsecution", meta = true },
            },
            loot = {
                { id=204467, slot="Back",   name="Drape of the Dracthyr Trials",       sources={ [17]=186775, [14]=185607, [15]=186773, [16]=186774 } },
                { id=204391, slot="Feet",   name="Failed Applicant's Footpads",        sources={ [17]=186610, [14]=185556, [15]=186608, [16]=186609 } },
                { id=204322, slot="Ranged", name="Failure Disposal Cannon",            sources={ [17]=185538, [14]=185539, [15]=185540, [16]=185541 } },
                { id=204400, slot="Waist",  name="Recycled Golemskin Waistguard",      sources={ [17]=186676, [14]=185563, [15]=186674, [16]=186675 } },
                { id=204320, slot="Weapon", name="Proctor's Tactical Cleaver",         sources={ [17]=185534, [14]=185535, [15]=185536, [16]=185537 } },
                { id=202555, slot="Weapon", name="Zskarn's Autopsy Scalpel",           sources={ [17]=185500, [14]=184529, [15]=185501, [16]=185502 } },
                { id=204393, slot="Wrist",  name="Clasps of the Diligent Steward",     sources={ [17]=186474, [14]=185558, [15]=186472, [16]=186473 } },
                -- Tier Chest (13 classes, from Ventilation Fluid tokens)
                { id=202446, slot="Chest", name="Battlechest of the Onyx Crucible",     sources={ [17]=186324, [14]=184420, [15]=186322, [16]=186323 }, classes={ 1 } },
                { id=202455, slot="Chest", name="Heartfire Sentinel's Brigandine",     sources={ [17]=186011, [14]=184429, [15]=186009, [16]=186010 }, classes={ 2 } },
                { id=202482, slot="Chest", name="Ashen Predator's Sling Vest",         sources={ [17]=186098, [14]=184456, [15]=186096, [16]=186097 }, classes={ 3 } },
                { id=202500, slot="Chest", name="Lurking Specter's Brigandine",        sources={ [17]=186131, [14]=184474, [15]=186129, [16]=186130 }, classes={ 4 } },
                { id=202545, slot="Chest", name="Command of the Furnace Seraph",       sources={ [17]=186233, [14]=184519, [15]=186231, [16]=186232 }, classes={ 5 } },
                { id=202464, slot="Chest", name="Lingering Phantom's Plackart",        sources={ [17]=186267, [14]=184438, [15]=186265, [16]=186266 }, classes={ 6 } },
                { id=202473, slot="Chest", name="Adornments of the Cinderwolf",        sources={ [17]=186059, [14]=184447, [15]=186057, [16]=186058 }, classes={ 7 } },
                { id=202554, slot="Chest", name="Underlight Conjurer's Vestment",     sources={ [17]=186363, [14]=184528, [15]=186361, [16]=186362 }, classes={ 8 } },
                { id=202536, slot="Chest", name="Cursed Robes of the Sinister Savant", sources={ [17]=186200, [14]=184510, [15]=186198, [16]=186199 }, classes={ 9 } },
                { id=202509, slot="Chest", name="Cuirass of the Vermillion Forge",    sources={ [17]=185786, [14]=184483, [15]=185787, [16]=185788 }, classes={ 10 } },
                { id=202518, slot="Chest", name="Chestroots of the Autumn Blaze",     sources={ [17]=186176, [14]=184492, [15]=186174, [16]=186175 }, classes={ 11 } },
                { id=202527, slot="Chest", name="Kinslayer's Vest",                   sources={ [17]=186444, [14]=184501, [15]=186442, [16]=186443 }, classes={ 12 } },
                { id=202491, slot="Chest", name="Hauberk of Obsidian Secrets",        sources={ [17]=186405, [14]=184465, [15]=186403, [16]=186404 }, classes={ 13 } },
            },
        },
        {
            index              = 7,
            name               = "Magmorax",
            journalEncounterID = 2527,
            achievements = {
                { id = 18172, name = "Escar-Go-Go-Go", meta = true },
            },
            loot = {
                { id=204396, slot="Feet",   name="Spittle-Resistant Sollerets",   sources={ [17]=186658, [14]=185561, [15]=186656, [16]=186657 } },
                { id=204395, slot="Waist",  name="Hydratooth Girdle",             sources={ [17]=186540, [14]=185560, [15]=186538, [16]=186539 } },
                { id=202560, slot="Weapon", name="Claws of the Blazing Behemoth", sources={ [17]=185491, [14]=184534, [15]=185492, [16]=185493 } },
                { id=202570, slot="Weapon", name="Lavaflow Control Rod",          sources={ [17]=185474, [14]=184544, [15]=185475, [16]=185476 } },
                { id=204394, slot="Wrist",  name="Cuffs of the Savage Serpent",   sources={ [17]=186616, [14]=185559, [15]=186614, [16]=186615 } },
                -- Tier Head (13 classes, from Melting Fluid tokens)
                { id=202443, slot="Head", name="Thraexhelm of the Onyx Crucible",     sources={ [17]=185918, [14]=184417, [15]=185920, [16]=185919 }, classes={ 1 } },
                { id=202452, slot="Head", name="Heartfire Sentinel's Forgehelm",      sources={ [17]=185994, [14]=184426, [15]=185995, [16]=185996 }, classes={ 2 } },
                { id=202479, slot="Head", name="Ashen Predator's Faceguard",          sources={ [17]=186081, [14]=184453, [15]=186082, [16]=186083 }, classes={ 3 } },
                { id=202497, slot="Head", name="Lurking Specter's Visage",            sources={ [17]=186122, [14]=184471, [15]=186120, [16]=186121 }, classes={ 4 } },
                { id=202542, slot="Head", name="Mask of the Furnace Seraph",          sources={ [17]=186244, [14]=184516, [15]=186245, [16]=186246 }, classes={ 5 } },
                { id=202461, slot="Head", name="Lingering Phantom's Dreadhorns",      sources={ [17]=186279, [14]=184435, [15]=186277, [16]=186278 }, classes={ 6 } },
                { id=202470, slot="Head", name="Spangenhelm of the Cinderwolf",       sources={ [17]=186042, [14]=184444, [15]=186043, [16]=186044 }, classes={ 7 } },
                { id=202551, slot="Head", name="Underlight Conjurer's Arcanocowl",   sources={ [17]=186354, [14]=184525, [15]=186352, [16]=186353 }, classes={ 8 } },
                { id=202533, slot="Head", name="Grimhorns of the Sinister Savant",    sources={ [17]=186204, [14]=184507, [15]=186205, [16]=186206 }, classes={ 9 } },
                { id=202506, slot="Head", name="Cover of the Vermillion Forge",       sources={ [17]=185777, [14]=184480, [15]=185778, [16]=185779 }, classes={ 10 } },
                { id=202515, slot="Head", name="Bough of the Autumn Blaze",           sources={ [17]=186159, [14]=184489, [15]=186160, [16]=186161 }, classes={ 11 } },
                { id=202524, slot="Head", name="Kinslayer's Hood",                    sources={ [17]=186427, [14]=184498, [15]=186428, [16]=186429 }, classes={ 12 } },
                { id=202488, slot="Head", name="Crown of Obsidian Secrets",           sources={ [17]=186388, [14]=184462, [15]=186389, [16]=186390 }, classes={ 13 } },
            },
        },
        {
            index              = 8,
            name               = "Echo of Neltharion",
            journalEncounterID = 2523,
            achievements = {
                { id = 18149, name = "Objects in Transit May Shatter", meta = true },
            },
            loot = {
                { id=204392, slot="Feet",             name="Treads of Fractured Realities", sources={ [17]=186486, [14]=185557, [15]=186484, [16]=186485 } },
                { id=202601, slot="Hands",            name="Twisted Vision's Demigaunts",   sources={ [17]=186679, [14]=184574, [15]=186677, [16]=186678 } },
                { id=204324, slot="Held In Off-hand", name="Echo's Maddening Volume",       sources={ [17]=185545, [14]=185546, [15]=185547, [16]=185548 } },
                { id=202558, slot="Off-hand",         name="Calamity's Herald",             sources={ [17]=185549, [14]=184532, [15]=185550, [16]=185551 } },
                { id=202606, slot="Two-Hand",         name="Ashkandur, Fall of the Brotherhood", sources={ [17]=185542, [14]=184579, [15]=185543, [16]=185544 } },
                -- Tier Shoulder (13 classes, from Corrupting Fluid tokens)
                { id=202441, slot="Shoulder", name="Pauldrons of the Onyx Crucible",      sources={ [17]=186298, [14]=184415, [15]=186299, [16]=186300 }, classes={ 1 } },
                { id=202450, slot="Shoulder", name="Heartfire Sentinel's Steelwings",    sources={ [17]=185982, [14]=184424, [15]=185983, [16]=185984 }, classes={ 2 } },
                { id=202477, slot="Shoulder", name="Ashen Predator's Trophy",            sources={ [17]=186069, [14]=184451, [15]=186070, [16]=186071 }, classes={ 3 } },
                { id=202495, slot="Shoulder", name="Lurking Specter's Shoulderblades",   sources={ [17]=186108, [14]=184469, [15]=186109, [16]=186110 }, classes={ 4 } },
                { id=202540, slot="Shoulder", name="Devotion of the Furnace Seraph",     sources={ [17]=186228, [14]=184514, [15]=186229, [16]=186230 }, classes={ 5 } },
                { id=202459, slot="Shoulder", name="Lingering Phantom's Shoulderplates", sources={ [17]=186285, [14]=184433, [15]=186283, [16]=186284 }, classes={ 6 } },
                { id=202468, slot="Shoulder", name="Thunderpads of the Cinderwolf",      sources={ [17]=186030, [14]=184442, [15]=186031, [16]=186032 }, classes={ 7 } },
                { id=202549, slot="Shoulder", name="Underlight Conjurer's Aurora",       sources={ [17]=186340, [14]=184523, [15]=186341, [16]=186342 }, classes={ 8 } },
                { id=202531, slot="Shoulder", name="Amice of the Sinister Savant",       sources={ [17]=186189, [14]=184505, [15]=186190, [16]=186191 }, classes={ 9 } },
                { id=202504, slot="Shoulder", name="Spines of the Vermillion Forge",     sources={ [17]=185771, [14]=184478, [15]=185772, [16]=185773 }, classes={ 10 } },
                { id=202513, slot="Shoulder", name="Mantle of the Autumn Blaze",         sources={ [17]=186147, [14]=184487, [15]=186148, [16]=186149 }, classes={ 11 } },
                { id=202522, slot="Shoulder", name="Kinslayer's Tainted Spaulders",      sources={ [17]=186415, [14]=184496, [15]=186416, [16]=186417 }, classes={ 12 } },
                { id=202486, slot="Shoulder", name="Wingspan of Obsidian Secrets",       sources={ [17]=186376, [14]=184460, [15]=186377, [16]=186378 }, classes={ 13 } },
            },
            soloTip = "When the boss shields, you must kill the adds to break his shield. Use Neltharion's various abilities (Rushing Darkness, Calamitous Strike) to break walls and reach the adds. You can attack the shielded adds once you have Corruption cast on you.",
        },
        {
            index              = 9,
            name               = "Scalecommander Sarkareth",
            journalEncounterID = 2520,
            aliases            = { "Sarkareth" },
            achievements = {
                { id = 17877, name = "We'll Never See That Again, Surely", meta = true },
            },
            specialLoot = {
                -- Highland Drake: Embodiment of the Hellforged
                -- (Drakewatcher Manuscript). Once you've used the
                -- manuscript on a character, the customization is
                -- permanently unlocked for that character even though
                -- the item itself is consumed. The Hellforged variant
                -- is the Mythic-only drop; a separate lesser variant
                -- drops on LFR/Normal/Heroic and grants the same
                -- customization unlock.
                {
                    id      = 205876,
                    kind    = "manuscript",
                    name    = "Highland Drake: Embodiment of the Hellforged",
                    questID = 75967,
                },
            },
            loot = {
                { id=204465, slot="Back",     name="Voice of the Silent Star",         sources={ [17]=186700, [14]=186698, [15]=186699, [16]=185606 } },
                { id=202599, slot="Chest",    name="Sarkareth's Abyssal Embrace",      sources={ [17]=186685, [14]=184572, [15]=186683, [16]=186684 } },
                { id=204424, slot="Feet",     name="Crechebound Soldier's Boots",      sources={ [17]=186558, [14]=185582, [15]=186556, [16]=186557 } },
                { id=202587, slot="Hands",    name="Oathbreaker's Obsessive Gauntlets", sources={ [17]=186628, [14]=184560, [15]=186626, [16]=186627 } },
                { id=202585, slot="Legs",     name="Coattails of the Rightful Heir",   sources={ [17]=186504, [14]=184558, [15]=186502, [16]=186503 } },
                { id=202584, slot="Legs",     name="Scalecommander's Ebon Schynbalds", sources={ [17]=186522, [14]=184557, [15]=186520, [16]=186521 } },
                { id=202565, slot="Two-Hand", name="Erethos, the Empty Promise",       sources={ [17]=187670, [14]=184539, [15]=187668, [16]=187669 } },
                { id=204399, slot="Waist",    name="Oblivion's Immortal Coil",         sources={ [17]=186625, [14]=185562, [15]=186623, [16]=186624 } },
                { id=202564, slot="Weapon",   name="Fang of the Sundered Flame",       sources={ [17]=185497, [14]=184538, [15]=185498, [16]=185499 } },
                { id=204390, slot="Wrist",    name="Bonds of Desperate Ascension",     sources={ [17]=186667, [14]=185555, [15]=186665, [16]=186666 } },
                -- Nasz'uro, the Unbound Legacy (legendary Evoker fist weapon).
                -- Sarkareth drops the Cracked Titan Gem (item 204255), which
                -- starts a long quest chain that ultimately rewards Nasz'uro.
                -- The gem can drop on any difficulty; like other legendaries,
                -- Nasz'uro has a single shared appearance across all four
                -- difficulties. Restricted to Evokers; the row renders for
                -- all classes with an "(Evoker only)" suffix so the
                -- appearance is visible to non-Evoker collectors as well.
                { id=204177, slot="Weapon",   name="Nasz'uro, the Unbound Legacy",     sources={ [17]=185459, [14]=185459, [15]=185459, [16]=185459 }, restrictedToClass=13 },
            },
            soloTip = "Oblivion stacks don't matter anymore, but avoid swirly/portal-looking areas on the ground. Stay away from the edge.",
            -- Two omnitoken-shaped extras Sarkareth drops alongside his
            -- regular loot: the Void-Touched Curio (any-tier-slot exchange)
            -- and the Cracked Titan Gem (starts the quest chain that
            -- rewards Nasz'uro for Evokers). Each surfaces as its own
            -- footnote block.
            tmogFootnote = {
                {
                    text   = "Sarkareth additionally drops {item}, an omnitoken that exchanges for any tier slot. Not tracked here.",
                    itemID = 206046,
                },
                {
                    text   = "Sarkareth also drops {item}, which starts the quest chain that rewards Nasz'uro, the Unbound Legacy (Evoker only).",
                    itemID = 204255,
                },
            },
        },
    },

    routing = {

        -- 1. Kazzara, the Hellforged
        -- Single segment on mapID 2166 (Molten Crucible). Path runs from
        -- the zone-in spawn straight ahead, clearing trash en route to
        -- spawn the boss.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Kazzara, the Hellforged",
            requires  = {},
            segments  = {
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Blazing Bulwark",
                    note    = "After zoning in, go straight ahead and clear all trash to spawn Kazzara.",
                    points  = {
                        { 0.512, 0.934 },
                        { 0.512, 0.757 },
                    },
                },
            },
        },

        -- 2. The Amalgamation Chamber
        -- Two segments. Seg 1 traverses Kazzara's room (mapID 2166,
        -- Molten Crucible) heading toward the labeled "Onyx Laboratory"
        -- exit on the left. Seg 2 picks up on mapID 2167 (Onyx
        -- Laboratory) and finishes by clearing trash to spawn the
        -- boss.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "The Amalgamation Chamber",
            requires  = { 1 },
            segments  = {
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Molten Crucible",
                    note    = "After killing Kazzara, take the left path towards the exit labeled Onyx Laboratory.",
                    points  = {
                        { 0.512, 0.686 },
                        { 0.512, 0.617 },
                        { 0.466, 0.599 },
                        { 0.411, 0.536 },
                        { 0.385, 0.448 },
                        { 0.350, 0.446 },
                    },
                },
                {
                    mapID   = 2167,
                    kind    = "path",
                    subZone = "Onyx Laboratory",
                    note    = "Continue down the path and clear the trash to spawn The Amalgamation Chamber.",
                    points  = {
                        { 0.557, 0.620 },
                        { 0.529, 0.637 },
                        { 0.468, 0.637 },
                    },
                },
            },
        },

        -- 3. The Forgotten Experiments
        -- Two segments. Seg 1 traverses Onyx Laboratory (mapID 2167)
        -- north toward stairs leading back into the Molten Crucible
        -- map. Seg 2 picks up on mapID 2166 (Molten Crucible) for the
        -- final approach -- killing the slimes en route spawns the
        -- boss.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "The Forgotten Experiments",
            requires  = { 1, 2 },
            segments  = {
                {
                    mapID   = 2167,
                    kind    = "path",
                    subZone = "Onyx Laboratory",
                    note    = "After killing The Amalgamation Chamber, follow the path north to reach some stairs leading to the Molten Crucible.",
                    points  = {
                        { 0.468, 0.632 },
                        { 0.485, 0.536 },
                        { 0.485, 0.337 },
                        { 0.451, 0.184 },
                        { 0.516, 0.128 },
                        { 0.557, 0.180 },
                    },
                },
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Onyx Laboratory",
                    note    = "Kill the slimes to spawn The Forgotten Experiments.",
                    points  = {
                        { 0.339, 0.198 },
                        { 0.371, 0.263 },
                    },
                },
            },
        },

        -- 4. Assault of the Zaqali
        -- Two segments. Seg 1 traverses Molten Crucible (mapID 2166)
        -- east toward the Defiant Ramparts exit -- the route jumps
        -- down behind the Forgotten Experiments arena (under a chain)
        -- and crosses the room. Seg 2 picks up on mapID 2168 (Defiant
        -- Ramparts) and climbs stairs to the boss arena, where killing
        -- the last trash pack spawns the encounter.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Assault of the Zaqali",
            requires  = { 1, 2, 3 },
            segments  = {
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Molten Crucible",
                    note    = "After defeating The Forgotten Experiments, jump down behind them (under a chain) and take the path across the room to the exit labeled Defiant Ramparts.",
                    points  = {
                        { 0.372, 0.259 },
                        { 0.408, 0.293 },
                        { 0.511, 0.356 },
                        { 0.636, 0.297 },
                        { 0.663, 0.336 },
                    },
                },
                {
                    mapID   = 2168,
                    kind    = "path",
                    subZone = "Defiant Ramparts",
                    note    = "Inside Defiant Ramparts, follow the path to climb some stairs. Kill the last trash pack to spawn Assault of the Zaqali.",
                    points  = {
                        { 0.375, 0.685 },
                        { 0.560, 0.684 },
                        { 0.549, 0.496 },
                        { 0.450, 0.382 },
                    },
                },
            },
        },

        -- 5. Rashok, the Elder
        -- Two segments. Seg 1 backtracks a short distance through
        -- Defiant Ramparts (mapID 2168) toward a doorway labeled
        -- Molten Crucible. Seg 2 picks up on mapID 2166 (Molten
        -- Crucible) for the final approach -- killing the trash
        -- engages the boss.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Rashok, the Elder",
            requires  = { 1, 2, 3, 4 },
            segments  = {
                {
                    mapID   = 2168,
                    kind    = "path",
                    subZone = "Defiant Ramparts",
                    note    = "After defeating the Assault of the Zaqali, enter the nearby room labeled Molten Crucible.",
                    points  = {
                        { 0.450, 0.384 },
                        { 0.396, 0.391 },
                    },
                },
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Aberrus, the Shadowed Crucible",
                    note    = "Approach the boss, and kill the trash to engage Rashok.",
                    points  = {
                        { 0.722, 0.143 },
                        { 0.695, 0.186 },
                    },
                },
            },
        },

        -- 6. The Vigilant Steward, Zskarn
        -- Single segment on mapID 2166 (Molten Crucible). After Rashok,
        -- climb the chain behind him and follow the path around to
        -- the boss arena.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "The Vigilant Steward, Zskarn",
            requires  = { 1, 2, 3, 4, 5 },
            segments  = {
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Molten Crucible",
                    note    = "After defeating Rashok, make your way up the chain behind him, and follow the path around to The Vigilant Steward, Zskarn.",
                    points  = {
                        { 0.660, 0.256 },
                        { 0.643, 0.279 },
                        { 0.592, 0.266 },
                        { 0.570, 0.189 },
                        { 0.585, 0.128 },
                        { 0.538, 0.127 },
                        { 0.514, 0.183 },
                        { 0.514, 0.211 },
                    },
                },
            },
        },

        -- 7. Magmorax
        -- Single segment on mapID 2166 (Molten Crucible). After Zskarn,
        -- drop down through a hole behind the friendly Neltharion NPC
        -- (he accompanies the party through the raid alongside Wrathion
        -- and Sabellian) and walk to the boss platform; clearing the
        -- trash there spawns the encounter.
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Magmorax",
            requires  = { 1, 2, 3, 4, 5, 6 },
            segments  = {
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Molten Crucible",
                    note    = "After defeating Zskarn, drop down into the hole behind Neltharion. Leap down again (across some lava), and make your way to the boss platform. Clear the trash to spawn Magmorax.",
                    points  = {
                        { 0.489, 0.250 },
                        { 0.512, 0.310 },
                        { 0.512, 0.435 },
                    },
                },
            },
        },

        -- 8. Echo of Neltharion
        -- Two segments. Seg 1 finishes the lava swim south across
        -- Molten Crucible (mapID 2166) to the labeled Neltharion's
        -- Sanctum exit, then a drop-down. Seg 2 picks up on mapID
        -- 2169 (Neltharion's Sanctum); clearing the trash inside
        -- spawns the encounter.
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Echo of Neltharion",
            requires  = { 1, 2, 3, 4, 5, 6, 7 },
            segments  = {
                {
                    mapID   = 2166,
                    kind    = "path",
                    subZone = "Aberrus, the Shadowed Crucible",
                    note    = "After defeating Magmorax, swim across the lava to reach the southern exit labeled Neltharion's Sanctum. Jump down into the hole.",
                    points  = {
                        { 0.514, 0.503 },
                        { 0.514, 0.574 },
                    },
                },
                {
                    mapID   = 2169,
                    kind    = "path",
                    subZone = "Neltharion's Sanctum",
                    note    = "After you land, enter the room and clear the trash to spawn Echo of Neltharion.",
                    points  = {
                        { 0.507, 0.167 },
                        { 0.508, 0.252 },
                    },
                },
            },
        },

        -- 9. Scalecommander Sarkareth
        -- Two segments. Seg 1 traverses Neltharion's Sanctum (mapID
        -- 2169) into a back room and through a purple portal circle.
        -- Seg 2 picks up on mapID 2170 (Edge of Oblivion) for the
        -- final approach to the encounter.
        {
            step      = 9,
            priority  = 1,
            bossIndex = 9,
            title     = "Scalecommander Sarkareth",
            requires  = { 1, 2, 3, 4, 5, 6, 7, 8 },
            segments  = {
                {
                    mapID   = 2169,
                    kind    = "path",
                    subZone = "Neltharion's Sanctum",
                    note    = "After defeating Echo of Neltharion, walk into the room behind him and jump into the purple circle to reach Edge of Oblivion.",
                    points  = {
                        { 0.508, 0.318 },
                        { 0.507, 0.588 },
                    },
                },
                {
                    mapID   = 2170,
                    kind    = "path",
                    subZone = "Edge of Oblivion",
                    note    = "After landing below, follow the path to reach Scalecommander Sarkareth.",
                    points  = {
                        { 0.490, 0.254 },
                        { 0.490, 0.678 },
                    },
                },
            },
        },

    },
}
