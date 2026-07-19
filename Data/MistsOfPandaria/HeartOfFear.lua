-------------------------------------------------------------------------------
-- RetroRuns Data -- Heart of Fear
-- Mists of Pandaria, Patch 5.0.4  |  instanceID: 1009  |  journalInstanceID: 330
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1009] = {
    instanceID        = 1009,
    journalInstanceID = 330,
    name              = "Heart of Fear",
    expansion         = "Mists of Pandaria",
    patch             = "5.0.4",

    exitNote = "None available",

    -- Pandaria-era raids split lockouts by raid size (10 and 25) rather
    -- than offering Mythic. Loot is shared across sizes, so the two
    -- Normal lockouts fold into one Normal bucket and the two Heroic
    -- lockouts into one Heroic; Raid Finder stands alone. This tells the
    -- difficulty engine to fold that way instead of the independent scheme.
    difficultyModel   = "sharedLfr",

    entrance = {
        mapID = 422,
        x     = 0.3900,
        y     = 0.3490,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [474] = "Oratorium of the Voice",
        [475] = "Heart of Fear",
    },

    tierSets = {
        labels = {
            -- Tier 14 spans Heart of Fear, Terrace of Endless
            -- Spring, and the Sha of Anger world boss. Heart of
            -- Fear drops the Hands, Legs, and Chest tokens.
        },
        tokenSources = {
            [89240] = 4,  -- Gauntlets of the Shadowy Conqueror
            [89241] = 4,  -- Gauntlets of the Shadowy Protector
            [89242] = 4,  -- Gauntlets of the Shadowy Vanquisher
            [89255] = 4,  -- Gauntlets of the Shadowy Vanquisher
            [89256] = 4,  -- Gauntlets of the Shadowy Conqueror
            [89257] = 4,  -- Gauntlets of the Shadowy Protector
            [89270] = 4,  -- Gauntlets of the Shadowy Vanquisher
            [89271] = 4,  -- Gauntlets of the Shadowy Conqueror
            [89272] = 4,  -- Gauntlets of the Shadowy Protector
            [89243] = 5,  -- Leggings of the Shadowy Conqueror
            [89244] = 5,  -- Leggings of the Shadowy Protector
            [89245] = 5,  -- Leggings of the Shadowy Vanquisher
            [89252] = 5,  -- Leggings of the Shadowy Vanquisher
            [89253] = 5,  -- Leggings of the Shadowy Conqueror
            [89254] = 5,  -- Leggings of the Shadowy Protector
            [89267] = 5,  -- Leggings of the Shadowy Vanquisher
            [89268] = 5,  -- Leggings of the Shadowy Conqueror
            [89269] = 5,  -- Leggings of the Shadowy Protector
            [89237] = 6,  -- Chest of the Shadowy Conqueror
            [89238] = 6,  -- Chest of the Shadowy Protector
            [89239] = 6,  -- Chest of the Shadowy Vanquisher
            [89249] = 6,  -- Chest of the Shadowy Vanquisher
            [89250] = 6,  -- Chest of the Shadowy Conqueror
            [89251] = 6,  -- Chest of the Shadowy Protector
            [89264] = 6,  -- Chest of the Shadowy Vanquisher
            [89265] = 6,  -- Chest of the Shadowy Conqueror
            [89266] = 6,  -- Chest of the Shadowy Protector
        },
    },

    gloryMeta = {
        id   = 6932,
        name = "Glory of the Pandaria Raider",
        rewardItemID       = 87773,
        rewardMountSpellID = 127161,
        rewardName         = "Reins of the Heavenly Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Imperial Vizier Zor'lok",
            journalEncounterID = 745,
            aliases            = {},
            achievements       = {
                { id = 6937, name = "Overzealous", meta = true, soloable = "yes" },
                { id = 6725, name = "Heroic: Imperial Vizier Zor'lok", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86154, slot = "Back", name = "Hisek's Chrysanthemum Cape", sources = { [17]=44693, [14]=44297, [15]=44807 } },
                { id = 86158, slot = "Chest", name = "Chestplate of the Forbidden Tower", sources = { [17]=44695, [14]=44299, [15]=44812 } },
                { id = 86160, slot = "Chest", name = "Mail of Screaming Secrets", sources = { [17]=44697, [14]=44301, [15]=44811 } },
                { id = 87824, slot = "Chest", name = "Zor'lok's Fizzing Chestguard", sources = { [17]=45316, [14]=45317, [15]=45315 } },
                { id = 86153, slot = "Feet", name = "Boots of the Still Breath", sources = { [17]=44692, [14]=44296, [15]=44805 } },
                { id = 89829, slot = "Feet", name = "Scent-Soaked Sandals", sources = { [17]=46680, [14]=46608, [15]=46649 } },
                { id = 86159, slot = "Hands", name = "Gauntlets of Undesired Gifts", sources = { [17]=44696, [14]=44300, [15]=44810 } },
                { id = 86161, slot = "Hands", name = "Gloves of Grasping Claws", sources = { [17]=44698, [14]=44302, [15]=44808 } },
                { id = 86203, slot = "Legs", name = "Articulated Legplates", sources = { [17]=44728, [14]=44339, [15]=44806 } },
                { id = 89826, slot = "Waist", name = "Warbelt of Sealed Pods", sources = { [17]=46681, [14]=46606, [15]=46650 } },
                { id = 86157, slot = "Wrist", name = "Attenuating Bracers", sources = { [17]=44694, [14]=44298, [15]=44809 } },
            },
            specialLoot = {
                { id = 167058, kind = "pet", name = "Kor'thik Swarmling" },
            },
        },
        {
            index              = 2,
            name               = "Blade Lord Ta'yak",
            journalEncounterID = 744,
            aliases            = {},
            achievements       = {
                { id = 6936, name = "Candle in the Wind", meta = true, soloable = "kinda" },
                { id = 6726, name = "Heroic: Blade Lord Ta'yak", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86169, slot = "Back", name = "Drape of Gathering Clouds", sources = { [17]=44704, [14]=44308, [15]=44819 } },
                { id = 86167, slot = "Feet", name = "Boots of the Blowing Wind", sources = { [17]=44702, [14]=44306, [15]=44817 } },
                { id = 90738, slot = "Hands", name = "Kaz'tik's Stormseizer Gauntlets", sources = { [17]=47151, [14]=47150, [15]=47152 } },
                { id = 86165, slot = "Hands", name = "Windblade Talons", sources = { [17]=44701, [14]=44305, [15]=44815 } },
                { id = 89831, slot = "Head", name = "Hood of Stilled Winds", sources = { [17]=46684, [14]=46610, [15]=46653 } },
                { id = 86171, slot = "Held In Off-hand", name = "Tornado-Summoning Censer", sources = { [17]=44706, [14]=44310, [15]=44818 } },
                { id = 89830, slot = "Legs", name = "Sword Dancer's Leggings", sources = { [17]=46682, [14]=46609, [15]=46651 } },
                { id = 89828, slot = "Shoulder", name = "Pauldrons of the Broken Blade", sources = { [17]=46683, [14]=46607, [15]=46652 } },
                { id = 86164, slot = "Waist", name = "Waistplate of Overwhelming Assault", sources = { [17]=44700, [14]=44304, [15]=44814 } },
                { id = 86168, slot = "Wrist", name = "Bracers of Tempestuous Fury", sources = { [17]=44703, [14]=44307, [15]=44820 } },
                { id = 86163, slot = "Wrist", name = "Bracers of Unseen Strikes", sources = { [17]=44699, [14]=44303, [15]=44813 } },
                { id = 86170, slot = "Wrist", name = "Twisting Wind Bracers", sources = { [17]=44705, [14]=44309, [15]=44816 } },
            },
            specialLoot = {
                { id = 167053, kind = "pet", name = "Tiny Amber Wings" },
            },
        },
        {
            index              = 3,
            name               = "Garalon",
            journalEncounterID = 713,
            aliases            = {},
            achievements       = {
                { id = 6553, name = "Like an Arrow to the Face", meta = true, soloable = "kinda" },
                { id = 6727, name = "Heroic: Garalon", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86173, slot = "Back", name = "Legbreaker Greatcloak", sources = { [17]=44707, [14]=44311, [15]=44821 } },
                { id = 86182, slot = "Back", name = "Stormwake Mistcloak", sources = { [17]=44715, [14]=44319, [15]=44827 } },
                { id = 89832, slot = "Chest", name = "Garalon's Graven Carapace", sources = { [17]=46685, [14]=46611, [15]=46654 } },
                { id = 86180, slot = "Chest", name = "Robes of Eighty Lights", sources = { [17]=44713, [14]=44317, [15]=44828 } },
                { id = 89834, slot = "Chest", name = "Vestments of Steaming Ichor", sources = { [17]=46687, [14]=46613, [15]=46656 } },
                { id = 86178, slot = "Feet", name = "Sandals of the Unbidden", sources = { [17]=44711, [14]=44315, [15]=44825 } },
                { id = 86176, slot = "Hands", name = "Bonebreaker Gauntlets", sources = { [17]=44710, [14]=44314, [15]=44822 } },
                { id = 86179, slot = "Hands", name = "Grasps of Panic", sources = { [17]=44712, [14]=44316, [15]=44829 } },
                { id = 86175, slot = "Hands", name = "Grips of the Leviathan", sources = { [17]=44709, [14]=44313, [15]=44823 } },
                { id = 86174, slot = "Head", name = "Garalon's Hollow Skull", sources = { [17]=44708, [14]=44312, [15]=44824 } },
                { id = 86181, slot = "Head", name = "Xaril's Hood of Intoxicating Vapors", sources = { [17]=44714, [14]=44318, [15]=44826 } },
                { id = 89833, slot = "Shoulder", name = "Shoulders of Foaming Fluids", sources = { [17]=46686, [14]=46612, [15]=46655 } },
            },
            specialLoot = {
                { id = 167054, kind = "pet", name = "Spawn of Garalon" },
            },
        },
        {
            index              = 4,
            name               = "Wind Lord Mel'jarak",
            journalEncounterID = 741,
            aliases            = {},
            achievements       = {
                { id = 6683, name = "Less Than Three", meta = true, soloable = "yes" },
                { id = 6728, name = "Heroic: Wind Lord Mel'jarak", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86202, slot = "Back", name = "Cloak of Raining Blades", sources = { [17]=44727, [14]=44338, [15]=44834 } },
                { id = 86513, slot = "Chest", name = "Robes of Torn Nightmares", sources = { [17]=44773, [14]=44482, [15]=44830 } },
                { id = 86201, slot = "Feet", name = "Impaling Treads", sources = { [17]=44726, [14]=44337, [15]=44833 } },
                { id = 86514, slot = "Hands", name = "Clutches of Dying Hope", sources = { [17]=44774, [14]=44483, [15]=44831 } },
                { id = 86204, slot = "Shoulder", name = "Wingslasher Pauldrons", sources = { [17]=44729, [14]=44340, [15]=44832 } },
                { id = 86667, slot = "Hands", name = "Handguards of Resounding Rings", sources = { [17]=43685, [14]=44565, [15]=45024 }, classes = { 1 } },
                { id = 86671, slot = "Hands", name = "Gauntlets of Resounding Rings", sources = { [17]=43689, [14]=44569, [15]=45020 }, classes = { 1 } },
                { id = 86662, slot = "Hands", name = "White Tiger Handguards", sources = { [17]=43680, [14]=44560, [15]=44946 }, classes = { 2 } },
                { id = 86682, slot = "Hands", name = "White Tiger Gauntlets", sources = { [17]=43700, [14]=44580, [15]=44936 }, classes = { 2 } },
                { id = 86687, slot = "Hands", name = "White Tiger Gloves", sources = { [17]=43705, [14]=44585, [15]=44941 }, classes = { 2 } },
                { id = 86637, slot = "Hands", name = "Yaungol Slayer's Gloves", sources = { [17]=43655, [14]=44535, [15]=44856 }, classes = { 3 } },
                { id = 86642, slot = "Hands", name = "Gloves of the Thousandfold Blades", sources = { [17]=43660, [14]=44540, [15]=44961 }, classes = { 4 } },
                { id = 86703, slot = "Hands", name = "Guardian Serpent Handwraps", sources = { [17]=43721, [14]=44601, [15]=44950 }, classes = { 5 } },
                { id = 86704, slot = "Hands", name = "Guardian Serpent Gloves", sources = { [17]=43722, [14]=44602, [15]=44955 }, classes = { 5 } },
                { id = 86657, slot = "Hands", name = "Handguards of the Lost Catacomb", sources = { [17]=43675, [14]=44555, [15]=44781 }, classes = { 6 } },
                { id = 86677, slot = "Hands", name = "Gauntlets of the Lost Catacomb", sources = { [17]=43695, [14]=44575, [15]=44776 }, classes = { 6 } },
                { id = 86627, slot = "Hands", name = "Firebird's Grips", sources = { [17]=43645, [14]=44525, [15]=44971 }, classes = { 7 } },
                { id = 86630, slot = "Hands", name = "Firebird's Gloves", sources = { [17]=43648, [14]=44528, [15]=44976 }, classes = { 7 } },
                { id = 86692, slot = "Hands", name = "Firebird's Handwraps", sources = { [17]=43710, [14]=44590, [15]=44966 }, classes = { 7 } },
                { id = 86718, slot = "Hands", name = "Gloves of the Burning Scroll", sources = { [17]=43736, [14]=44616, [15]=44860 }, classes = { 8 } },
                { id = 86709, slot = "Hands", name = "Sha-Skin Gloves", sources = { [17]=43727, [14]=44607, [15]=45013 }, classes = { 9 } },
                { id = 86727, slot = "Hands", name = "Red Crane Gauntlets", sources = { [17]=43745, [14]=44625, [15]=44931 }, classes = { 10 } },
                { id = 86729, slot = "Hands", name = "Red Crane Handwraps", sources = { [17]=43747, [14]=44627, [15]=44925 }, classes = { 10 } },
                { id = 86735, slot = "Hands", name = "Red Crane Grips", sources = { [17]=43753, [14]=44633, [15]=44921 }, classes = { 10 } },
                { id = 86648, slot = "Hands", name = "Eternal Blossom Gloves", sources = { [17]=43666, [14]=44546, [15]=44795 }, classes = { 11 } },
                { id = 86652, slot = "Hands", name = "Eternal Blossom Grips", sources = { [17]=43670, [14]=44550, [15]=44786 }, classes = { 11 } },
                { id = 86698, slot = "Hands", name = "Eternal Blossom Handwraps", sources = { [17]=43716, [14]=44596, [15]=44790 }, classes = { 11 } },
                { id = 86720, slot = "Hands", name = "Eternal Blossom Handguards", sources = { [17]=43738, [14]=44618, [15]=44801 }, classes = { 11 } },
            },
        },
        {
            index              = 5,
            name               = "Amber-Shaper Un'sok",
            journalEncounterID = 737,
            aliases            = {},
            achievements       = {
                { id = 6518, name = "I Heard You Like Amber...", meta = true, soloable = "kinda" },
                { id = 6729, name = "Heroic: Amber-Shaper Un'sok", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86214, slot = "Feet", name = "Monstrous Stompers", sources = { [17]=44733, [14]=44348, [15]=44838 } },
                { id = 86212, slot = "Feet", name = "Treads of Deadly Secretions", sources = { [17]=44731, [14]=44346, [15]=44837 } },
                { id = 86213, slot = "Shoulder", name = "Shoulderpads of Misshapen Life", sources = { [17]=44732, [14]=44347, [15]=44839 } },
                { id = 86210, slot = "Waist", name = "Belt of Malleable Amber", sources = { [17]=44730, [14]=44345, [15]=44835 } },
                { id = 86219, slot = "Weapon", name = "Scimitar of Seven Stars", sources = { [17]=44735, [14]=44352, [15]=44840 } },
                { id = 86217, slot = "Weapon", name = "Un'sok's Amber Scalpel", sources = { [17]=44734, [14]=44350, [15]=44836 } },
                { id = 86665, slot = "Legs", name = "Legguards of Resounding Rings", sources = { [17]=43683, [14]=44563, [15]=45026 }, classes = { 1 } },
                { id = 86670, slot = "Legs", name = "Legplates of Resounding Rings", sources = { [17]=43688, [14]=44568, [15]=45021 }, classes = { 1 } },
                { id = 86660, slot = "Legs", name = "White Tiger Legguards", sources = { [17]=43678, [14]=44558, [15]=44948 }, classes = { 2 } },
                { id = 86680, slot = "Legs", name = "White Tiger Legplates", sources = { [17]=43698, [14]=44578, [15]=44938 }, classes = { 2 } },
                { id = 86685, slot = "Legs", name = "White Tiger Greaves", sources = { [17]=43703, [14]=44583, [15]=44943 }, classes = { 2 } },
                { id = 86635, slot = "Legs", name = "Yaungol Slayer's Legguards", sources = { [17]=43653, [14]=44533, [15]=44858 }, classes = { 3 } },
                { id = 86640, slot = "Legs", name = "Legguards of the Thousandfold Blades", sources = { [17]=43658, [14]=44538, [15]=44963 }, classes = { 4 } },
                { id = 86701, slot = "Legs", name = "Guardian Serpent Legwraps", sources = { [17]=43719, [14]=44599, [15]=44952 }, classes = { 5 } },
                { id = 86706, slot = "Legs", name = "Guardian Serpent Leggings", sources = { [17]=43724, [14]=44604, [15]=44957 }, classes = { 5 } },
                { id = 86655, slot = "Legs", name = "Legguards of the Lost Catacomb", sources = { [17]=43673, [14]=44553, [15]=44783 }, classes = { 6 } },
                { id = 86675, slot = "Legs", name = "Greaves of the Lost Catacomb", sources = { [17]=43693, [14]=44573, [15]=44778 }, classes = { 6 } },
                { id = 86625, slot = "Legs", name = "Firebird's Legguards", sources = { [17]=43643, [14]=44523, [15]=44973 }, classes = { 7 } },
                { id = 86632, slot = "Legs", name = "Firebird's Kilt", sources = { [17]=43650, [14]=44530, [15]=44978 }, classes = { 7 } },
                { id = 86690, slot = "Legs", name = "Firebird's Legwraps", sources = { [17]=43708, [14]=44588, [15]=44968 }, classes = { 7 } },
                { id = 86716, slot = "Legs", name = "Leggings of the Burning Scroll", sources = { [17]=43734, [14]=44614, [15]=44862 }, classes = { 8 } },
                { id = 86711, slot = "Legs", name = "Sha-Skin Leggings", sources = { [17]=43729, [14]=44609, [15]=45015 }, classes = { 9 } },
                { id = 86725, slot = "Legs", name = "Red Crane Legguards", sources = { [17]=43743, [14]=44623, [15]=44933 }, classes = { 10 } },
                { id = 86731, slot = "Legs", name = "Red Crane Legwraps", sources = { [17]=43749, [14]=44629, [15]=44927 }, classes = { 10 } },
                { id = 86737, slot = "Legs", name = "Red Crane Leggings", sources = { [17]=43755, [14]=44635, [15]=44923 }, classes = { 10 } },
                { id = 86646, slot = "Legs", name = "Eternal Blossom Leggings", sources = { [17]=43664, [14]=44544, [15]=44797 }, classes = { 11 } },
                { id = 86650, slot = "Legs", name = "Eternal Blossom Legguards", sources = { [17]=43668, [14]=44548, [15]=44788 }, classes = { 11 } },
                { id = 86696, slot = "Legs", name = "Eternal Blossom Legwraps", sources = { [17]=43714, [14]=44594, [15]=44792 }, classes = { 11 } },
                { id = 86722, slot = "Legs", name = "Eternal Blossom Breeches", sources = { [17]=43740, [14]=44620, [15]=44803 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 167055, kind = "pet", name = "Amber Goo Puddle" },
            },
        },
        {
            index              = 6,
            name               = "Grand Empress Shek'zeer",
            journalEncounterID = 743,
            aliases            = {},
            achievements       = {
                { id = 6922, name = "Timing is Everything", meta = true, soloable = "kinda" },
                { id = 6730, name = "Heroic: Grand Empress Shek'zeer", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86228, slot = "Head", name = "Crown of the Doomed Empress", sources = { [17]=44738, [14]=44360, [15]=44844 } },
                { id = 89835, slot = "Head", name = "Hood of Dark Dreams", sources = { [17]=46689, [14]=46614, [15]=46658 } },
                { id = 86229, slot = "Legs", name = "Leggings of Shadow Infestation", sources = { [17]=44739, [14]=44361, [15]=44842 } },
                { id = 89837, slot = "Legs", name = "Legplates of Regal Reinforcement", sources = { [17]=46690, [14]=46616, [15]=46659 } },
                { id = 89836, slot = "Shoulder", name = "Shadow Heart Spaulders", sources = { [17]=46688, [14]=46615, [15]=46657 } },
                { id = 86226, slot = "Weapon", name = "Claws of Shek'zeer", sources = { [17]=44736, [14]=44358, [15]=44841 } },
                { id = 86227, slot = "Weapon", name = "Kri'tak, Imperial Scepter of the Swarm", sources = { [17]=44737, [14]=44359, [15]=44843 } },
                { id = 86668, slot = "Chest", name = "Chestguard of Resounding Rings", sources = { [17]=43686, [14]=44566, [15]=45023 }, classes = { 1 } },
                { id = 86672, slot = "Chest", name = "Battleplate of Resounding Rings", sources = { [17]=43690, [14]=44570, [15]=45019 }, classes = { 1 } },
                { id = 86663, slot = "Chest", name = "White Tiger Chestguard", sources = { [17]=43681, [14]=44561, [15]=44945 }, classes = { 2 } },
                { id = 86683, slot = "Chest", name = "White Tiger Battleplate", sources = { [17]=43701, [14]=44581, [15]=44935 }, classes = { 2 } },
                { id = 86688, slot = "Chest", name = "White Tiger Breastplate", sources = { [17]=43706, [14]=44586, [15]=44940 }, classes = { 2 } },
                { id = 86638, slot = "Chest", name = "Yaungol Slayer's Tunic", sources = { [17]=43656, [14]=44536, [15]=44855 }, classes = { 3 } },
                { id = 86643, slot = "Chest", name = "Tunic of the Thousandfold Blades", sources = { [17]=43661, [14]=44541, [15]=44960 }, classes = { 4 } },
                { id = 86700, slot = "Chest", name = "Guardian Serpent Robes", sources = { [17]=43718, [14]=44598, [15]=44953 }, classes = { 5 } },
                { id = 86707, slot = "Chest", name = "Guardian Serpent Raiment", sources = { [17]=43725, [14]=44605, [15]=44958 }, classes = { 5 } },
                { id = 86658, slot = "Chest", name = "Chestguard of the Lost Catacomb", sources = { [17]=43676, [14]=44556, [15]=44780 }, classes = { 6 } },
                { id = 86678, slot = "Chest", name = "Breastplate of the Lost Catacomb", sources = { [17]=43696, [14]=44576, [15]=44775 }, classes = { 6 } },
                { id = 86628, slot = "Chest", name = "Firebird's Cuirass", sources = { [17]=43646, [14]=44526, [15]=44970 }, classes = { 7 } },
                { id = 86629, slot = "Chest", name = "Firebird's Hauberk", sources = { [17]=43647, [14]=44527, [15]=44975 }, classes = { 7 } },
                { id = 86693, slot = "Chest", name = "Firebird's Tunic", sources = { [17]=43711, [14]=44591, [15]=44965 }, classes = { 7 } },
                { id = 86715, slot = "Chest", name = "Robes of the Burning Scroll", sources = { [17]=43733, [14]=44613, [15]=44863 }, classes = { 8 } },
                { id = 86712, slot = "Chest", name = "Sha-Skin Robes", sources = { [17]=43730, [14]=44610, [15]=45016 }, classes = { 9 } },
                { id = 86728, slot = "Chest", name = "Red Crane Chestguard", sources = { [17]=43746, [14]=44626, [15]=44930 }, classes = { 10 } },
                { id = 86732, slot = "Chest", name = "Red Crane Vest", sources = { [17]=43750, [14]=44630, [15]=44928 }, classes = { 10 } },
                { id = 86734, slot = "Chest", name = "Red Crane Tunic", sources = { [17]=43752, [14]=44632, [15]=44920 }, classes = { 10 } },
                { id = 86645, slot = "Chest", name = "Eternal Blossom Vestment", sources = { [17]=43663, [14]=44543, [15]=44798 }, classes = { 11 } },
                { id = 86653, slot = "Chest", name = "Eternal Blossom Raiment", sources = { [17]=43671, [14]=44551, [15]=44785 }, classes = { 11 } },
                { id = 86695, slot = "Chest", name = "Eternal Blossom Robes", sources = { [17]=43713, [14]=44593, [15]=44793 }, classes = { 11 } },
                { id = 86719, slot = "Chest", name = "Eternal Blossom Tunic", sources = { [17]=43737, [14]=44617, [15]=44800 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 167056, kind = "pet", name = "Essence of Pride" },
            },
        },
    },

    routing = {

        -- 1. Imperial Vizier Zor'lok
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Imperial Vizier Zor'lok",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 474, subZone = "Palace Antechamber" },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path to reach ^Imperial Vizier Zor'lok^. Clear all trash in his room to start the fight.",
                    minNote = "Path to Zor'lok",
                    points  = {
                        { 0.343, 0.814 },
                        { 0.342, 0.697 },
                        { 0.412, 0.611 },
                        { 0.521, 0.613 },
                        { 0.529, 0.561 },
                        { 0.550, 0.538 },
                        { 0.630, 0.660 },
                    },
                },
            },
        },

        -- 2. Blade Lord Ta'yak
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Blade Lord Ta'yak",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 474, subZone = "Oratorium of the Voice" },
                    kind    = "path",
                    note    = "After killing ^Zor'lok^, take the northwest stairwell and follow the path into the next room to find ^Blade Lord Ta'yak^. Kill trash in all 4 corners to begin the fight.",
                    minNote = "Northwest to Ta'yak",
                    points  = {
                        { 0.595, 0.604 },
                        { 0.545, 0.535 },
                        { 0.570, 0.503 },
                        { 0.596, 0.494 },
                        { 0.594, 0.233 },
                    },
                },
            },
        },

        -- 3. Garalon
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Garalon",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 474, subZone = "Training Quarters" },
                    kind    = "path",
                    note    = "After killing ^Blade Lord Ta'yak^, take the long stairwell exit on the west side of the room.",
                    minNote = "West stairwell",
                    points  = {
                        { 0.516, 0.322 },
                        { 0.318, 0.324 },
                        { 0.318, 0.132 },
                    },
                },
                {
                    when    = { mapID = 475, subZone = "Staging Balcony" },
                    kind    = "path",
                    note    = "At the top of the stairs, clear the elite trash on the platform to spawn ^Garalon^.",
                    minNote = "Clear elites for Garalon",
                    points  = {
                        { 0.664, 0.262 },
                        { 0.663, 0.203 },
                    },
                },
            },
        },

        -- 4. Wind Lord Mel'jarak
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Wind Lord Mel'jarak",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 475, subZone = "Staging Balcony" },
                    kind    = "path",
                    note    = "After killing ^Garalon^, walk up the stairs behind you to find ^Wind Lord Mel'jarak^.",
                    minNote = "Up to Wind Lord",
                    points  = {
                        { 0.661, 0.212 },
                        { 0.660, 0.256 },
                        { 0.638, 0.267 },
                        { 0.622, 0.289 },
                        { 0.616, 0.320 },
                        { 0.619, 0.349 },
                        { 0.627, 0.370 },
                        { 0.635, 0.381 },
                        { 0.648, 0.364 },
                    },
                },
            },
        },

        -- 5. Amber-Shaper Un'sok
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Amber-Shaper Un'sok",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 475, subZone = "Staging Balcony" },
                    kind    = "path",
                    note    = "After defeating ^Wind Lord Mel'jarak^, take the southern stairwell and follow the linear path all the way to ^Amber-Shaper Un'sok^.",
                    minNote = "South to Un'sok",
                    points  = {
                        { 0.662, 0.379 },
                        { 0.663, 0.663 },
                        { 0.633, 0.679 },
                        { 0.606, 0.734 },
                        { 0.473, 0.736 },
                    },
                },
            },
        },

        -- 6. Grand Empress Shek'zeer
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Grand Empress Shek'zeer",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 475, subZone = "Amber Research Sanctum" },
                    kind    = "path",
                    note    = "After defeating ^Amber-Shaper Un'sok^, exit the room to the west and head straight for ^Grand Empress Shek'zeer^. Clear all the trash to spawn the boss.",
                    minNote = "West to Shek'zeer",
                    points  = {
                        { 0.470, 0.736 },
                        { 0.408, 0.737 },
                        { 0.399, 0.776 },
                        { 0.381, 0.793 },
                        { 0.350, 0.774 },
                        { 0.295, 0.741 },
                    },
                },
            },
        },

    },

    lfrWings = {

        -- The Dread Approach: Zor'lok, Ta'yak, Garalon.
        [832] = {
            name   = "The Dread Approach",
            bosses = { 1, 2, 3 },
            lockoutBits = { [1] = 7, [2] = 6, [3] = 1 },
            routing = {

                -- 1. Imperial Vizier Zor'lok
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 1,
                    title     = "Imperial Vizier Zor'lok",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 474, subZone = "Palace Antechamber" },
                            kind    = "path",
                            note    = "After zoning in, follow the linear path to reach ^Imperial Vizier Zor'lok^. Clear all trash in his room to start the fight.",
                            minNote = "Path to Zor'lok",
                            points  = {
                                { 0.343, 0.814 },
                                { 0.342, 0.697 },
                                { 0.412, 0.611 },
                                { 0.521, 0.613 },
                                { 0.529, 0.561 },
                                { 0.550, 0.538 },
                                { 0.630, 0.660 },
                            },
                        },
                    },
                },

                -- 2. Blade Lord Ta'yak
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 2,
                    title     = "Blade Lord Ta'yak",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 474, subZone = "Oratorium of the Voice" },
                            kind    = "path",
                            note    = "After killing ^Zor'lok^, take the northwest stairwell and follow the path into the next room to find ^Blade Lord Ta'yak^. Kill trash in all 4 corners to begin the fight.",
                            minNote = "Northwest to Ta'yak",
                            points  = {
                                { 0.595, 0.604 },
                                { 0.545, 0.535 },
                                { 0.570, 0.503 },
                                { 0.596, 0.494 },
                                { 0.594, 0.233 },
                            },
                        },
                    },
                },

                -- 3. Garalon
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 3,
                    title     = "Garalon",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 474, subZone = "Training Quarters" },
                            kind    = "path",
                            note    = "After killing ^Blade Lord Ta'yak^, take the long stairwell exit on the west side of the room.",
                            minNote = "West stairwell",
                            points  = {
                                { 0.516, 0.322 },
                                { 0.318, 0.324 },
                                { 0.318, 0.132 },
                            },
                        },
                        {
                            when    = { mapID = 475, subZone = "Staging Balcony" },
                            kind    = "path",
                            note    = "At the top of the stairs, clear the elite trash on the platform to spawn ^Garalon^.",
                            minNote = "Clear elites for Garalon",
                            points  = {
                                { 0.664, 0.262 },
                                { 0.663, 0.203 },
                            },
                        },
                    },
                },

            },
        },

        -- Nightmare of Shek'zeer: Mel'jarak, Un'sok, Shek'zeer.
        [833] = {
            name   = "Nightmare of Shek'zeer",
            bosses = { 4, 5, 6 },
            lockoutBits = { [4] = 2, [5] = 3, [6] = 4 },
            routing = {

                -- 4. Wind Lord Mel'jarak
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 4,
                    title     = "Wind Lord Mel'jarak",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 475, subZone = "Staging Balcony" },
                            kind    = "path",
                            note    = "After zoning in, walk up the ramp in front of you to find ^Wind Lord Mel'jarak^.",
                            minNote = "Up to Wind Lord",
                            points  = {
                                { 0.661, 0.212 },
                                { 0.660, 0.256 },
                                { 0.638, 0.267 },
                                { 0.622, 0.289 },
                                { 0.616, 0.320 },
                                { 0.619, 0.349 },
                                { 0.627, 0.370 },
                                { 0.635, 0.381 },
                                { 0.648, 0.364 },
                            },
                        },
                    },
                },

                -- 5. Amber-Shaper Un'sok
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 5,
                    title     = "Amber-Shaper Un'sok",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 475, subZone = "Staging Balcony" },
                            kind    = "path",
                            note    = "After defeating ^Wind Lord Mel'jarak^, take the southern stairwell and follow the linear path all the way to ^Amber-Shaper Un'sok^.",
                            minNote = "South to Un'sok",
                            points  = {
                                { 0.662, 0.379 },
                                { 0.663, 0.663 },
                                { 0.633, 0.679 },
                                { 0.606, 0.734 },
                                { 0.473, 0.736 },
                            },
                        },
                    },
                },

                -- 6. Grand Empress Shek'zeer
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 6,
                    title     = "Grand Empress Shek'zeer",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 475, subZone = "Amber Research Sanctum" },
                            kind    = "path",
                            note    = "After defeating ^Amber-Shaper Un'sok^, exit the room to the west and head straight for ^Grand Empress Shek'zeer^. Clear all the trash to spawn the boss.",
                            minNote = "West to Shek'zeer",
                            points  = {
                                { 0.470, 0.736 },
                                { 0.408, 0.737 },
                                { 0.399, 0.776 },
                                { 0.381, 0.793 },
                                { 0.350, 0.774 },
                                { 0.295, 0.741 },
                            },
                        },
                    },
                },

            },
        },

    },
}
