-------------------------------------------------------------------------------
-- RetroRuns Data -- Ny'alotha, the Waking City
-- Battle for Azeroth, Patch 8.3  |  instanceID: 2217  |  journalInstanceID: 1180
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2217] = {
    instanceID        = 2217,
    journalInstanceID = 1180,
    name              = "Ny'alotha, the Waking City",
    expansion         = "Battle for Azeroth",
    patch             = "8.3",

    -- Entrance is a floating obelisk that ALTERNATES WEEKLY between
    -- two zones: Uldum (uiMapID 1527) at 54/43 above the Vir'naal
    -- Dam, and Vale of Eternal Blossoms (uiMapID 1530) at 39/43
    -- above Whitepetal Lake. We default to Uldum here. If the
    -- obelisk is currently in the Vale instead, the player will
    -- need to travel the short way over from Uldum (or we can
    -- improve this later by detecting the active assault).
    entrance = {
        mapID = 1527,
        x     = 0.551,
        y     = 0.438,
    },

    maps = {
        [1580] = "Vision of Destiny",   -- entrance / Wrathion arena
        [1581] = "Annex of Prophecy",   -- Maut, The Prophet Skitra
        [1582] = "Ny'alotha",           -- elevator/path between Annex of Prophecy and The Ritual Chamber
        [1590] = "The Hive",            -- The Hivemind
        [1591] = "Terrace of Desolation", -- Ra-den the Despoiled
        [1592] = "The Ritual Chamber",  -- Dark Inquisitor Xanesh
        [1593] = "Twilight Landing",    -- Vexiona
        [1594] = "Maw of Gor'ma",       -- Shad'har the Insatiable
        [1595] = "Warren of Decay",     -- Drest'agath
        [1596] = "Chamber of Rebirth",  -- Il'gynoth, Corruption Reborn
        [1597] = "Locus of Infinite Truths", -- Carapace of N'Zoth, N'Zoth the Corruptor
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    skipQuests = {
        normal = 58373,
        heroic = 58374,
        mythic = 58375,
    },

    -- Surfaced to players via the Skips window's per-row info button.
    skipTrigger = {
        questName = "Ny'alotha: MOTHER's Guidance",
        details   = "After defeating ^Wrathion^, you can proceed up the long bridge straight to ^Carapace of N'Zoth^.",
    },

    -- Glory of the Raider meta -- 12 criteria, awards the Wriggling Parasite mount.
    gloryMeta = {
        id   = 14146,
        name = "Glory of the Ny'alotha Raider",
        rewardItemID       = 174861,
        rewardMountSpellID = 316343,
        rewardName         = "Wriggling Parasite",
    },

    bosses = {
        {
            index              = 1,
            name               = "Wrathion, the Black Emperor",
            journalEncounterID = 2368,
            aliases            = { "Wrathion" },
            achievements       = {
                { id = 14019, name = "Smoke Test", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174153, slot = "Hands",  name = "Ebony Scaled Gauntlets",   sources = { [17]=108204, [14]=108201, [15]=108202, [16]=108203 } },
                { id = 174125, slot = "Hands",  name = "Emberscale Gloves",        sources = { [17]=108092, [14]=108089, [15]=108090, [16]=108091 } },
                { id = 174139, slot = "Legs",   name = "Onyx-Imbued Breeches",     sources = { [17]=108146, [14]=108145, [15]=108147, [16]=108148 } },
                { id = 172185, slot = "Weapon", name = "Destroyer's Shadowblade",  sources = { [17]=108323, [14]=106542, [15]=108324, [16]=108325 } },
                { id = 172199, slot = "Weapon", name = "Faralos, Empire's Dream",  sources = { [17]=108365, [14]=106556, [15]=108366, [16]=108367 } },
                { id = 174105, slot = "Weapon", name = "Mish'un, Blade of Tyrants", sources = { [17]=108383, [14]=108032, [15]=108384, [16]=108385 } },
                { id = 174170, slot = "Wrist",  name = "Dragonbone Vambraces",     sources = { [17]=108272, [14]=108269, [15]=108270, [16]=108271 } },
            },
        },
        {
            index              = 2,
            name               = "Maut",
            journalEncounterID = 2365,
            aliases            = {},
            achievements       = {
                { id = 14008, name = "Mana Sponge", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174141, slot = "Feet",     name = "Boots of Manifest Shadow",   sources = { [17]=108154, [14]=108153, [15]=108155, [16]=108156 } },
                { id = 174132, slot = "Head",     name = "Stygian Guise",              sources = { [17]=108120, [14]=108117, [15]=108118, [16]=108119 } },
                { id = 174155, slot = "Legs",     name = "Greaves of Forbidden Magics", sources = { [17]=108212, [14]=108209, [15]=108210, [16]=108211 } },
                { id = 174172, slot = "Legs",     name = "Living Obsidian Legguards",  sources = { [17]=108280, [14]=108277, [15]=108278, [16]=108279 } },
                { id = 174152, slot = "Shoulder", name = "Pauldrons of Ill Portent",   sources = { [17]=108200, [14]=108197, [15]=108198, [16]=108199 } },
                { id = 172191, slot = "Two-Hand", name = "An'zig Vra",                 sources = { [17]=108341, [14]=106548, [15]=108342, [16]=108343 } },
                { id = 172200, slot = "Two-Hand", name = "Sk'shuul Vaz",               sources = { [17]=108368, [14]=106557, [15]=108369, [16]=108370 } },
                { id = 174124, slot = "Waist",    name = "Mana-Infused Sash",          sources = { [17]=108086, [14]=108085, [15]=108087, [16]=108088 } },
            },
            specialLoot = {
                -- Fractured Obsidian Claw teaches the Muar pet (NPC 161919).
                { id = 174446, kind = "pet", name = "Muar" },
            },
        },
        {
            index              = 3,
            name               = "The Prophet Skitra",
            journalEncounterID = 2369,
            aliases            = { "Skitra", "Prophet Skitra" },
            achievements       = {
                { id = 14037, name = "Phase 3: Prophet", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174119, slot = "Chest",    name = "Robes of Unreality",            sources = { [17]=108068, [14]=108065, [15]=108066, [16]=108067 } },
                { id = 174173, slot = "Feet",     name = "Boots of Hallucinatory Reality", sources = { [17]=108282, [14]=108281, [15]=108283, [16]=108284 } },
                { id = 174123, slot = "Feet",     name = "Psychic's Subtle Slippers",     sources = { [17]=108082, [14]=108081, [15]=108083, [16]=108084 } },
                { id = 174157, slot = "Feet",     name = "Talons of Grim Revelations",    sources = { [17]=108220, [14]=108217, [15]=108218, [16]=108219 } },
                { id = 174143, slot = "Legs",     name = "Macabre Ritual Pants",          sources = { [17]=108162, [14]=108161, [15]=108163, [16]=108164 } },
                { id = 172193, slot = "Ranged",   name = "Whispering Eldritch Bow",       sources = { [17]=108347, [14]=106550, [15]=108348, [16]=108349 } },
                { id = 174165, slot = "Shoulder", name = "Writhing Spaulders of Madness", sources = { [17]=108252, [14]=108249, [15]=108250, [16]=108251 } },
                { id = 172201, slot = "Weapon",   name = "Bloodstained Ritual Athame",    sources = { [17]=108371, [14]=106558, [15]=108372, [16]=108373 } },
                { id = 174138, slot = "Wrist",    name = "Bracers of Dark Prophecy",      sources = { [17]=108144, [14]=108141, [15]=108142, [16]=108143 } },
            },
        },
        {
            index              = 4,
            name               = "Dark Inquisitor Xanesh",
            journalEncounterID = 2377,
            aliases            = { "Xanesh", "Dark Inquisitor" },
            achievements       = {
                { id = 14024, name = "Buzzer Beater", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174169, slot = "Hands",            name = "Gauntlets of Foul Inquisition", sources = { [17]=108268, [14]=108265, [15]=108266, [16]=108267 } },
                { id = 172190, slot = "Held In Off-hand", name = "Uhnish Vwah",                   sources = { [17]=108338, [14]=106547, [15]=108339, [16]=108340 } },
                { id = 174121, slot = "Legs",             name = "Trousers of Peculiar Potency",  sources = { [17]=108076, [14]=108073, [15]=108074, [16]=108075 } },
                { id = 174126, slot = "Waist",            name = "Binding of Dark Heresies",      sources = { [17]=108094, [14]=108093, [15]=108095, [16]=108096 } },
                { id = 174156, slot = "Waist",            name = "Chainlink Belt of Ill Omens",   sources = { [17]=108216, [14]=108213, [15]=108214, [16]=108215 } },
                { id = 174140, slot = "Waist",            name = "Cord of Anguished Cries",       sources = { [17]=108150, [14]=108149, [15]=108151, [16]=108152 } },
                { id = 172196, slot = "Weapon",           name = "Vorzz Yoq'al",                  sources = { [17]=108356, [14]=106553, [15]=108357, [16]=108358 } },
            },
        },
        {
            index              = 5,
            name               = "The Hivemind",
            journalEncounterID = 2372,
            aliases            = { "Hivemind" },
            achievements       = {
                { id = 14023, name = "Realizing Your Potential", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174137, slot = "Hands",    name = "Chitinspine Gloves",         sources = { [17]=108138, [14]=108137, [15]=108139, [16]=108140 } },
                { id = 174106, slot = "Two-Hand", name = "Qwor N'lyeth",               sources = { [17]=108386, [14]=108033, [15]=108387, [16]=108388 } },
                { id = 174171, slot = "Waist",    name = "Dark Crystalline Girdle",    sources = { [17]=108274, [14]=108273, [15]=108275, [16]=108276 } },
                { id = 172192, slot = "Weapon",   name = "The All-Seeing Eye",         sources = { [17]=108344, [14]=106549, [15]=108345, [16]=108346 } },
                { id = 174154, slot = "Wrist",    name = "Nightmarish Chain Shackles", sources = { [17]=108206, [14]=108205, [15]=108207, [16]=108208 } },
                { id = 174122, slot = "Wrist",    name = "Void-Drenched Wristwraps",   sources = { [17]=108080, [14]=108077, [15]=108078, [16]=108079 } },
            },
            specialLoot = {
                { id = 174448, kind = "pet", name = "Aqir Hivespawn" },
                { id = 174449, kind = "pet", name = "Ra'kim" },
            },
        },
        {
            index              = 6,
            name               = "Shad'har the Insatiable",
            journalEncounterID = 2367,
            aliases            = { "Shad'har", "Shadhar" },
            achievements       = {
                { id = 13990, name = "You Can Pet the Dog, But...", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174162, slot = "Hands",  name = "Ego-Annihilating Grips",       sources = { [17]=108240, [14]=108237, [15]=108238, [16]=108239 } },
                { id = 174130, slot = "Hands",  name = "Grips of Occult Reminiscence", sources = { [17]=108112, [14]=108109, [15]=108110, [16]=108111 } },
                { id = 174107, slot = "Ranged", name = "Insidious Writhing Longbow",   sources = { [17]=108389, [14]=108034, [15]=108390, [16]=108391 } },
                { id = 172186, slot = "Weapon", name = "Warmace of Waking Nightmares", sources = { [17]=108326, [14]=106543, [15]=108327, [16]=108328 } },
                { id = 174177, slot = "Wrist",  name = "Bracers of Phantom Pains",     sources = { [17]=108300, [14]=108297, [15]=108298, [16]=108299 } },
                { id = 174145, slot = "Wrist",  name = "Wristwraps of Volatile Power", sources = { [17]=108172, [14]=108169, [15]=108170, [16]=108171 } },
            },
        },
        {
            index              = 7,
            name               = "Drest'agath",
            journalEncounterID = 2373,
            aliases            = { "Drestagath" },
            achievements       = {
                { id = 14026, name = "Temper Tantrum", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174146, slot = "Hands",    name = "Gloves of Abyssal Authority", sources = { [17]=108174, [14]=108173, [15]=108175, [16]=108176 } },
                { id = 174159, slot = "Legs",     name = "Spinebarb Legplates",         sources = { [17]=108228, [14]=108225, [15]=108226, [16]=108227 } },
                { id = 172195, slot = "Two-Hand", name = "Halsheth, Slumberer's Spear", sources = { [17]=108353, [14]=106552, [15]=108354, [16]=108355 } },
                { id = 174174, slot = "Waist",    name = "Belt of Muttering Truths",    sources = { [17]=108286, [14]=108285, [15]=108287, [16]=108288 } },
                { id = 172198, slot = "Weapon",   name = "Mar'kowa, the Mindpiercer",   sources = { [17]=108362, [14]=106555, [15]=108363, [16]=108364 } },
            },
        },
        {
            index              = 8,
            name               = "Il'gynoth, Corruption Reborn",
            journalEncounterID = 2374,
            aliases            = { "Il'gynoth", "Ilgynoth" },
            soloTip            = "You will have to bring his health down to zero several times. In each intermission, you must kill an add called Organ of Corruption to continue the fight.",
            achievements       = {
                { id = 14038, name = "Bloody Mess", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174150, slot = "Chest",    name = "Scales of the Scheming Behemoth", sources = { [17]=108190, [14]=108189, [15]=108191, [16]=108192 } },
                { id = 174176, slot = "Feet",     name = "Sabatons of Malevolent Intent",   sources = { [17]=108294, [14]=108293, [15]=108295, [16]=108296 } },
                { id = 174116, slot = "Head",     name = "Cowl of Unspeakable Horrors",     sources = { [17]=108056, [14]=108053, [15]=108054, [16]=108055 } },
                { id = 174163, slot = "Head",     name = "Second Sight Helm",               sources = { [17]=108244, [14]=108241, [15]=108242, [16]=108243 } },
                { id = 172188, slot = "Off-hand", name = "Precipice of Oblivion",           sources = { [17]=108332, [14]=106545, [15]=108333, [16]=108334 } },
                { id = 172189, slot = "Ranged",   name = "Eyestalk of Il'gynoth",           sources = { [17]=108335, [14]=106546, [15]=108336, [16]=108337 } },
                { id = 174135, slot = "Shoulder", name = "Spaulders of Aberrant Allure",    sources = { [17]=108132, [14]=108129, [15]=108130, [16]=108131 } },
                { id = 174142, slot = "Waist",    name = "Belt of Braided Vessels",         sources = { [17]=108158, [14]=108157, [15]=108159, [16]=108160 } },
                { id = 174161, slot = "Wrist",    name = "Bracers of Manifest Apathy",      sources = { [17]=108234, [14]=108233, [15]=108235, [16]=108236 } },
                { id = 174129, slot = "Wrist",    name = "Cuffs of Grim Conjuration",       sources = { [17]=108108, [14]=108105, [15]=108106, [16]=108107 } },
            },
        },
        {
            index              = 9,
            name               = "Vexiona",
            journalEncounterID = 2370,
            aliases            = {},
            achievements       = {
                { id = 14139, name = "Total Annihilation", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174164, slot = "Chest",    name = "Breastplate of Twilight Decimation", sources = { [17]=108248, [14]=108245, [15]=108246, [16]=108247 } },
                { id = 174131, slot = "Chest",    name = "Darkheart Robe",                     sources = { [17]=108114, [14]=108113, [15]=108115, [16]=108116 } },
                { id = 174160, slot = "Feet",     name = "Greaves of the Twilight Drake",      sources = { [17]=108232, [14]=108229, [15]=108230, [16]=108231 } },
                { id = 174148, slot = "Head",     name = "Helm of Deep Despair",               sources = { [17]=108182, [14]=108181, [15]=108183, [16]=108184 } },
                { id = 174120, slot = "Shoulder", name = "Void Ascendant's Mantle",            sources = { [17]=108069, [14]=108070, [15]=108071, [16]=108072 } },
                { id = 172194, slot = "Weapon",   name = "Gift of the Void",                   sources = { [17]=108350, [14]=106551, [15]=108351, [16]=108352 } },
            },
        },
        {
            index              = 10,
            name               = "Ra-den the Despoiled",
            journalEncounterID = 2364,
            aliases            = { "Ra-den", "Raden" },
            achievements       = {
                { id = 13999, name = "How? Isn't it Obelisk?", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174168, slot = "Chest",    name = "Carapace of Pulsing Vita",       sources = { [17]=108264, [14]=108261, [15]=108262, [16]=108263 } },
                { id = 174115, slot = "Chest",    name = "Robe of the Fallen Keeper",      sources = { [17]=108052, [14]=108049, [15]=108050, [16]=108051 } },
                { id = 174128, slot = "Feet",     name = "Boots of Wrought Shadow",        sources = { [17]=108102, [14]=108101, [15]=108103, [16]=108104 } },
                { id = 174134, slot = "Head",     name = "Gibbering Maw",                  sources = { [17]=108128, [14]=108125, [15]=108126, [16]=108127 } },
                { id = 174175, slot = "Legs",     name = "Reality-Defying Greaves",        sources = { [17]=108292, [14]=108289, [15]=108290, [16]=108291 } },
                { id = 174149, slot = "Shoulder", name = "Dreamer's Unblinking Pauldrons", sources = { [17]=108188, [14]=108185, [15]=108186, [16]=108187 } },
                { id = 172228, slot = "Two-Hand", name = "Shandai, Watcher of Cosmos",     sources = { [17]=108377, [14]=106573, [15]=108378, [16]=108379 } },
                { id = 172197, slot = "Weapon",   name = "Unguent Caress",                 sources = { [17]=108359, [14]=106554, [15]=108360, [16]=108361 } },
            },
            specialLoot = {
                { id = 174447, kind = "pet", name = "Void-Scarred Anubisath" },
            },
        },
        {
            index              = 11,
            name               = "Carapace of N'Zoth",
            journalEncounterID = 2366,
            aliases            = { "Carapace", "Carapace of NZoth" },
            soloTip            = "|cffF259C7(1)|r Hit the boss until he runs into the next room. |cffF259C7(2)|r In the next room, your goal is to kill the Synthesis Growths sticking to the walls on both sides of the room. Kill slimes on the floor to clear walking paths. Pickup glowing orbs along the way to keep sanity up. |cffF259C7(3)|r After the Synthesis Growths are all killed, follow the boss into the next room to finish the encounter.",
            achievements       = {
                { id = 14147, name = "Cleansing Treatment", meta = true, soloable = "no" },
            },
            loot = {
                { id = 174136, slot = "Chest",    name = "Tortured Fleshbeast Cuirass",    sources = { [17]=108134, [14]=108133, [15]=108135, [16]=108136 } },
                { id = 174144, slot = "Feet",     name = "Corpuscular Leather Greaves",    sources = { [17]=108166, [14]=108165, [15]=108167, [16]=108168 } },
                { id = 174178, slot = "Hands",    name = "Mirage-Weaver's Gauntlets",      sources = { [17]=108304, [14]=108301, [15]=108302, [16]=108303 } },
                { id = 174151, slot = "Head",     name = "Helm of Actualized Visions",     sources = { [17]=108196, [14]=108193, [15]=108194, [16]=108195 } },
                { id = 174127, slot = "Legs",     name = "Corporeal Supplicant's Trousers", sources = { [17]=108100, [14]=108097, [15]=108098, [16]=108099 } },
                { id = 174166, slot = "Shoulder", name = "Pauldrons of Infinite Darkness", sources = { [17]=108256, [14]=108253, [15]=108254, [16]=108255 } },
                { id = 174117, slot = "Shoulder", name = "Spaulders of Miasmic Mycelia",   sources = { [17]=108057, [14]=108058, [15]=108059, [16]=108060 } },
                { id = 174158, slot = "Waist",    name = "Watcher's Scheming Girdle",      sources = { [17]=108224, [14]=108221, [15]=108222, [16]=108223 } },
                { id = 174109, slot = "Weapon",   name = "Lurker's Piercing Gaze",         sources = { [17]=108395, [14]=108036, [15]=108396, [16]=108397 } },
                { id = 172227, slot = "Weapon",   name = "Shard of the Black Empire",      sources = { [17]=108374, [14]=106572, [15]=108375, [16]=108376 } },
                { id = 174108, slot = "Weapon",   name = "Shgla'yos, Astral Malignity",    sources = { [17]=108392, [14]=108035, [15]=108393, [16]=108394 } },
            },
        },
        {
            index              = 12,
            name               = "N'Zoth the Corruptor",
            journalEncounterID = 2375,
            aliases            = { "N'Zoth", "NZoth" },
            soloTip            = "|cffF259C7(1)|r Kill adds until a blue swirly portal (Mindgate) appears on the ground. Click it to be sent into the Mind of ^N'Zoth^. |cffF259C7(2)|r Note your location on the minimap, because your goal is to kill Psychus and return to your body as fast as possible and click it to return to the physical realm. |cffF259C7(3)|r Back outside, attack ^N'Zoth^. This phase may need to be repeated depending on speed. |cffF259C7(4)|r A waygate will spawn. Enter it to kill an add and return to ^N'Zoth^ and finish the fight.",
            achievements       = {
                { id = 14148, name = "It's Not A Cult", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 174147, slot = "Chest",    name = "Last Vestige of Neltharion",        sources = { [17]=108178, [14]=108177, [15]=108179, [16]=108180 } },
                { id = 174167, slot = "Head",     name = "Greathelm of Phantasmic Reality",   sources = { [17]=108260, [14]=108257, [15]=108258, [16]=108259 } },
                { id = 174118, slot = "Head",     name = "Visage of Nightmarish Machinations", sources = { [17]=108064, [14]=108061, [15]=108062, [16]=108063 } },
                { id = 172229, slot = "Ranged",   name = "Dominion, Lurker Beyond Dreams",    sources = { [17]=108380, [14]=106574, [15]=108381, [16]=108382 } },
                { id = 174133, slot = "Shoulder", name = "Pauldrons of the Great Convergence", sources = { [17]=108124, [14]=108121, [15]=108122, [16]=108123 } },
                { id = 172187, slot = "Two-Hand", name = "Devastation's Hour",                sources = { [17]=108329, [14]=106544, [15]=108330, [16]=108331 } },
            },
            specialLoot        = {
                -- Ny'alotha Allseer mount: 1% drop rate from N'Zoth on
                -- Mythic only; weekly lockout. Also appears on the Black
                -- Market Auction House.
                { id = 174872, kind = "mount", name = "Ny'alotha Allseer", mythicOnly = true },
                { id = 174452, kind = "pet",   name = "Eye of Corruption" },
            },
        },
    },

    -- Skip route: after Wrathion, the long northern path bridges straight
    -- to Carapace of N'Zoth, then N'Zoth. Wrathion and N'Zoth segments
    -- match the standard route.
    skipToBoss = "Carapace of N'Zoth",

    skipRoute = {

        -- 1. Wrathion, the Black Emperor (same as standard)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Wrathion, the Black Emperor",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 1580 },
                    kind    = "path",
                    note    = "Upon zoning in, you will find ^Wrathion^ directly in front of you.",
                    minNote = "Kill Wrathion",
                    points  = {
                        { 0.529, 0.652 },
                        { 0.527, 0.272 },
                    },
                },
            },
        },

        -- 2. Carapace of N'Zoth via the skip path.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 11,
            title     = "Carapace of N'Zoth",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 1581, subZone = "Annex of Prophecy" },
                    kind    = "path",
                    note    = "After defeating ^Wrathion^, proceed through the long northern path to the map exit labeled ^Ny'alotha^. Take the elevator up, and continue through the door ahead.",
                    minNote = "Long Path North",
                    points  = {
                        { 0.538, 0.770 },
                        { 0.593, 0.723 },
                        { 0.593, 0.567 },
                        { 0.509, 0.563 },
                        { 0.511, 0.181 },
                    },
                },
                {
                    when    = { mapID = 1582, subZone = "Ny'alotha" },
                    kind    = "path",
                    note    = "Follow the path to the final map exit labeled ^N'Zoth^. Kill adds on the bridge to spawn a portal at the end.",
                    minNote = "Trash on Bridge",
                    points  = {
                        { 0.524, 0.761 },
                        { 0.558, 0.708 },
                        { 0.568, 0.678 },
                        { 0.573, 0.617 },
                        { 0.571, 0.535 },
                        { 0.569, 0.515 },
                        { 0.525, 0.445 },
                        { 0.526, 0.190 },
                    },
                },
                {
                    when    = { mapID = 1597 },
                    kind    = "path",
                    note    = "In the next area, talk to ^Wrathion^ to trigger a cutscene, then kill some adds to start the fight with ^Carapace of N'Zoth^.",
                    minNote = "Wrathion then Trash",
                    points  = {
                        { 0.487, 0.784 },
                        { 0.486, 0.715 },
                    },
                },
            },
        },

        -- 3. N'Zoth the Corruptor (same as standard)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 12,
            title     = "N'Zoth the Corruptor",
            requires  = { 11 },
            segments  = {
                {
                    when     = { mapID = 1597 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "After killing ^Carapace^, you will find yourself standing in front of ^N'Zoth^. Attack the boss to start the encounter.",
                    minNote  = "Kill N'Zoth",
                    points   = {
                        { 0.483, 0.294 },
                    },
                },
            },
        },
    },

    exitNote = "Exit portal nearby.",
    minExitNote = "Exit Portal Nearby",

    routing = {
        -- `requires` lists immediate predecessors only, not the full
        -- transitive set.
        --
        -- DAG:
        --   1. Wrathion       requires {}
        --   2. Maut           requires { 1 }
        --   3. Skitra         requires { 1 }
        --   4. Xanesh         requires { 2, 3 }
        --   5. Hivemind       requires { 2, 3 }
        --   6. Shad'har       requires { 2, 3 }
        --   7. Drest'agath    requires { 2, 3 }
        --   8. Il'gynoth      requires { 6, 7 }       (Shad'har AND Drest'agath)
        --   9. Vexiona        requires { 4 }          (after Xanesh)
        --  10. Ra-den         requires { 5 }          (after Hivemind)
        --  11. Carapace       requires { 8, 9, 10 }   (the three wing-finishers)
        --  12. N'Zoth         requires { 11 }

        -- 1. Wrathion, the Black Emperor
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Wrathion, the Black Emperor",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 1580 },
                    kind    = "path",
                    note    = "Upon zoning in, you will find ^Wrathion^ directly in front of you.",
                    minNote = "Kill Wrathion",
                    points  = {
                        { 0.529, 0.652 },
                        { 0.527, 0.272 },
                    },
                },
            },
        },

        -- 2. Maut
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Maut",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 1581 },
                    kind    = "path",
                    note    = "After killing ^Wrathion^, take the path all the way to the left. Clear the room to spawn ^Maut^, and kill him.",
                    minNote = "Left to Maut",
                    points  = {
                        { 0.485, 0.768 },
                        { 0.464, 0.750 },
                        { 0.443, 0.748 },
                        { 0.439, 0.664 },
                        { 0.232, 0.661 },
                        { 0.216, 0.608 },
                    },
                },
            },
        },

        -- 3. The Prophet Skitra
        {
            step      = 3,
            priority  = 2,
            bossIndex = 3,
            title     = "The Prophet Skitra",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 1581 },
                    kind    = "path",
                    note    = "After killing ^Maut^, take the long path all the way to the right to reach ^The Prophet Skitra^. Jump off the ledge and die for a shortcut.",
                    minNote = "Jump off and die",
                    points  = {
                        { 0.214, 0.587 },
                        { 0.244, 0.546 },
                        { 0.469, 0.547 },
                        { 0.470, 0.566 },
                        { 0.563, 0.567 },
                        { 0.619, 0.602 },
                        { 0.812, 0.604 },
                    },
                },
            },
        },

        -- 4. Dark Inquisitor Xanesh
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Dark Inquisitor Xanesh",
            requires  = { 2, 3 },
            segments  = {
                {
                    when    = { mapID = 1581 },
                    kind    = "path",
                    note    = "After killing ^Skitra^, backtrack a bit and go north to the map exit labeled ^Ny'alotha^. Ride an elevator up, and kill the trash to open the path to the next area.",
                    minNote = "North to Elevator",
                    points  = {
                        { 0.813, 0.611 },
                        { 0.733, 0.601 },
                        { 0.615, 0.602 },
                        { 0.562, 0.569 },
                        { 0.511, 0.566 },
                        { 0.510, 0.064 },
                    },
                },
                {
                    when    = { mapID = 1582 },
                    kind    = "path",
                    note    = "Make your way up the path and stay to the right and find the map exit labeled ^The Ritual Chamber^.",
                    minNote = "Up and right to Ritual Chamber",
                    points  = {
                        { 0.524, 0.772 },
                        { 0.564, 0.688 },
                        { 0.576, 0.536 },
                        { 0.606, 0.535 },
                    },
                },
                {
                    when    = { mapID = 1592 },
                    kind    = "path",
                    note    = "Loop your way around the path and you will see ^Queen Azshara^ trapped. Clear the trash to engage ^Dark Inquisitor Xanesh^.",
                    minNote = "Trash then Xanesh",
                    points  = {
                        { 0.141, 0.516 },
                        { 0.141, 0.564 },
                        { 0.205, 0.551 },
                        { 0.203, 0.502 },
                        { 0.435, 0.460 },
                    },
                },
            },
        },

        -- 5. Vexiona
        {
            step      = 5,
            priority  = 1,
            bossIndex = 9,
            title     = "Vexiona",
            requires  = { 4 },
            segments  = {
                {
                    when    = { mapID = 1592 },
                    kind    = "path",
                    note    = "After killing ^Xanesh^, leave the room to the east and towards the map exit for ^Twilight Landing^. Ride the elevator up.",
                    minNote = "East to Elevator",
                    points  = {
                        { 0.558, 0.460 },
                        { 0.740, 0.439 },
                    },
                },
                {
                    when    = { mapID = 1593 },
                    kind    = "path",
                    note    = "After reaching the top of the elevator, make your way down the path and clear the trash to engage ^Vexiona^.",
                    minNote = "Trash then Vexiona",
                    points  = {
                        { 0.733, 0.462 },
                        { 0.678, 0.474 },
                        { 0.652, 0.516 },
                        { 0.591, 0.523 },
                        { 0.561, 0.482 },
                        { 0.355, 0.507 },
                    },
                },
            },
        },

        -- 6. Shad'har the Insatiable
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Shad'har the Insatiable",
            requires  = { 2, 3 },
            segments  = {
                {
                    when    = { mapID = 1593 },
                    kind    = "poi",
                    poiSize = 35,
                    mapLabel = "Re-origination Anchor",
                    mapLabelPos = "above",
                    completionCheck = true,
                    note    = "After killing ^Vexiona^, interact with the ^Re-origination Anchor^ behind the boss to be teleported. After you land, continue ahead.",
                    minNote = "Click Re-origination Anchor",
                    points  = {
                        { 0.295, 0.513 },
                    },
                },
                {
                    when    = { mapID = 1582 },
                    kind    = "path",
                    note    = "After landing, follow the path down to the map exit labeled ^Maw of Gor'ma^.",
                    minNote = "Path down to Maw of Gor'ma",
                    points  = {
                        { 0.570, 0.539 },
                        { 0.575, 0.622 },
                        { 0.560, 0.624 },
                        { 0.541, 0.562 },
                        { 0.501, 0.529 },
                    },
                },
                {
                    when    = { mapID = 1594 },
                    kind    = "path",
                    note    = "Make your way down the spiral, following the path to reach ^Shad'har the Insatiable^.",
                    minNote = "Down spiral to Shad'har",
                    points  = {
                        { 0.599, 0.284 },
                        { 0.585, 0.231 },
                        { 0.529, 0.194 },
                        { 0.460, 0.249 },
                        { 0.467, 0.357 },
                        { 0.532, 0.450 },
                        { 0.528, 0.705 },
                    },
                },
            },
        },

        -- 7. Drest'agath
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Drest'agath",
            requires  = { 2, 3 },
            segments  = {
                {
                    when    = { mapID = 1594 },
                    kind    = "path",
                    note    = "After defeating ^Shad'har^, leave his room and continue down the spiral.",
                    minNote = "Continue down spiral",
                    points  = {
                        { 0.528, 0.696 },
                        { 0.532, 0.407 },
                        { 0.597, 0.350 },
                    },
                },
                {
                    when    = { mapID = 1595 },
                    kind    = "path",
                    note    = "Enter the next room and kill ^Drest'agath^.",
                    minNote = "Kill Drest'agath",
                    points  = {
                        { 0.774, 0.452 },
                        { 0.698, 0.418 },
                        { 0.614, 0.564 },
                        { 0.361, 0.570 },
                    },
                },
            },
        },

        -- 8. Il'gynoth, Corruption Reborn
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Il'gynoth, Corruption Reborn",
            requires  = { 6, 7 },
            segments  = {
                {
                    when    = { mapID = 1595 },
                    kind    = "path",
                    note    = "After killing ^Drest'agath^, leave the room and continue down the spiral toward the map exit ^Chamber of Rebirth^.",
                    minNote = "Continue down spiral",
                    points  = {
                        { 0.360, 0.572 },
                        { 0.614, 0.576 },
                        { 0.637, 0.649 },
                    },
                },
                {
                    when    = { mapID = 1596 },
                    kind    = "path",
                    note    = "Follow the path all the way back to find ^Il'gynoth, Corruption Reborn^.",
                    minNote = "Path to Il'gynoth",
                    points  = {
                        { 0.520, 0.845 },
                        { 0.579, 0.812 },
                        { 0.579, 0.701 },
                        { 0.441, 0.619 },
                        { 0.381, 0.514 },
                        { 0.462, 0.353 },
                    },
                },
            },
        },

        -- 9. The Hivemind
        {
            step      = 9,
            priority  = 1,
            bossIndex = 5,
            title     = "The Hivemind",
            requires  = { 2, 3 },
            segments  = {
                {
                    when    = { mapID = 1596 },
                    kind    = "poi",
                    poiSize = 35,
                    mapLabel = "Re-origination Anchor",
                    completionCheck = true,
                    note    = "After defeating ^Il'gynoth^, interact with the nearby ^Re-origination Anchor^ to be flown back to the top.",
                    minNote = "Click Re-origination Anchor",
                    points  = {
                        { 0.449, 0.375 },
                    },
                },
                {
                    when    = { mapID = 1582 },
                    kind    = "path",
                    note    = "After landing up top, follow the path around to the map exit labeled ^The Hive^.",
                    minNote = "Path to Hive",
                    points  = {
                        { 0.521, 0.538 },
                        { 0.542, 0.567 },
                        { 0.563, 0.625 },
                        { 0.572, 0.602 },
                        { 0.571, 0.520 },
                        { 0.522, 0.442 },
                        { 0.494, 0.480 },
                        { 0.460, 0.442 },
                    },
                },
                {
                    when    = { mapID = 1590 },
                    kind    = "path",
                    note    = "Enter the room to engage with ^The Hivemind^.",
                    minNote = "Ahead to Hivemind",
                    points  = {
                        { 0.733, 0.825 },
                        { 0.712, 0.850 },
                        { 0.673, 0.795 },
                        { 0.689, 0.765 },
                        { 0.526, 0.556 },
                    },
                },
            },
        },

        -- 10. Ra-den the Despoiled
        {
            step      = 10,
            priority  = 1,
            bossIndex = 10,
            title     = "Ra-den the Despoiled",
            requires  = { 5 },
            segments  = {
                {
                    when    = { mapID = 1590 },
                    kind    = "path",
                    note    = "After killing ^The Hivemind^, continue past them to the next room, and take the elevator up to the ^Terrace of Desolation^.",
                    minNote = "Elevator to Terrace",
                    points  = {
                        { 0.487, 0.497 },
                        { 0.472, 0.450 },
                        { 0.363, 0.343 },
                    },
                },
                {
                    when    = { mapID = 1591 },
                    kind    = "path",
                    note    = "After reaching the top of the elevator, follow the path back to find ^Ra-den the Despoiled^.",
                    minNote = "Path to Ra-den",
                    points  = {
                        { 0.389, 0.336 },
                        { 0.419, 0.372 },
                        { 0.448, 0.368 },
                        { 0.496, 0.434 },
                        { 0.499, 0.480 },
                        { 0.634, 0.644 },
                    },
                },
            },
        },

        -- 11. Carapace of N'Zoth
        {
            step      = 11,
            priority  = 1,
            bossIndex = 11,
            title     = "Carapace of N'Zoth",
            requires  = { 8, 9, 10 },
            segments  = {
                {
                    when    = { mapID = 1591 },
                    kind    = "poi",
                    poiSize = 35,
                    mapLabel = "Re-origination Anchor",
                    completionCheck = true,
                    note    = "After defeating ^Ra-den^, interact with the ^Re-origination Anchor^ right behind him to be flown back below.",
                    minNote = "Click Re-origination Anchor",
                    points  = {
                        { 0.679, 0.710 },
                    },
                },
                {
                    when    = { mapID = 1582 },
                    kind    = "path",
                    note    = "After landing, follow the path to the final map exit labeled ^N'Zoth^. Kill adds on the bridge to spawn a portal at the end.",
                    minNote = "Trash on Bridge then Portal",
                    points  = {
                        { 0.455, 0.436 },
                        { 0.493, 0.483 },
                        { 0.527, 0.436 },
                        { 0.527, 0.186 },
                    },
                },
                {
                    when    = { mapID = 1597 },
                    kind    = "path",
                    note    = "In the next area, talk to ^Wrathion^ to trigger a cutscene, then kill some adds to start the fight with ^Carapace of N'Zoth^.",
                    minNote = "Talk to Wrathion",
                    points  = {
                        { 0.487, 0.784 },
                        { 0.486, 0.715 },
                    },
                },
            },
        },

        -- 12. N'Zoth the Corruptor
        {
            step      = 12,
            priority  = 1,
            bossIndex = 12,
            title     = "N'Zoth the Corruptor",
            requires  = { 11 },
            segments  = {
                {
                    when     = { mapID = 1597 },
                    kind     = "poi",
                    noMarker = true,
                    note     = "After killing ^Carapace^, you will find yourself standing in front of ^N'Zoth^. Attack the boss to start the encounter.",
                    minNote  = "Kill N'Zoth",
                    points   = {
                        { 0.483, 0.294 },
                    },
                },
            },
        },
    },

    lfrWings = {
        -- Vision of Destiny: Wrathion(1), Maut(2), The Prophet Skitra(3).
        -- This is the one Ny'alotha LFR wing that matches encounter order
        -- (later wings scramble it). LFR zones into the same maps the
        -- standard route uses (1580 for Wrathion, 1581 for Maut/Skitra) and
        -- the three bosses chain linearly, so all routing imports verbatim
        -- from the standard opening.
        [2036] = {
            name   = "Vision of Destiny",
            bosses = { 1, 2, 3 },   -- Wrathion, Maut, The Prophet Skitra
            exitNote = "Leave instance group via LFG tool.\n\nNote: If you plan to visit the ^Waking Dream^ wing to kill ^N'Zoth^, you must have ^Ashjra'kamas, Shroud of Resolve^ in your inventory for the Queueing NPC to present the option.",
            minExitNote = "Leave via LFG Tool",
            -- Per-boss lockout bits, captured one kill at a time on a fresh
            -- lockout: Wrathion->3, Maut->1, The Prophet Skitra->6.
            lockoutBits = { [1] = 3, [2] = 1, [3] = 6 },
            routing = {
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 1,
                    title     = "Wrathion, the Black Emperor",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 1580 },
                            kind    = "path",
                            note    = "Upon zoning in, you will find ^Wrathion^ directly in front of you.",
                            minNote = "Kill Wrathion",
                            points  = {
                                { 0.529, 0.652 },
                                { 0.527, 0.272 },
                            },
                        },
                    },
                },
                {
                    step      = 2,
                    priority  = 1,
                    bossIndex = 2,
                    title     = "Maut",
                    requires  = { 1 },
                    segments  = {
                        {
                            when    = { mapID = 1581 },
                            kind    = "path",
                            note    = "After killing ^Wrathion^, take the path all the way to the left. Clear the room to spawn ^Maut^, and kill him.",
                            minNote = "Left to Maut",
                            points  = {
                                { 0.485, 0.768 },
                                { 0.464, 0.750 },
                                { 0.443, 0.748 },
                                { 0.439, 0.664 },
                                { 0.232, 0.661 },
                                { 0.216, 0.608 },
                            },
                        },
                    },
                },
                {
                    step      = 3,
                    priority  = 1,
                    bossIndex = 3,
                    title     = "The Prophet Skitra",
                    requires  = { 2 },
                    segments  = {
                        {
                            when    = { mapID = 1581 },
                            kind    = "path",
                            note    = "After killing ^Maut^, take the long path all the way to the right to reach ^The Prophet Skitra^. Jump off the ledge and die for a shortcut.",
                            minNote = "Jump off and die",
                            points  = {
                                { 0.214, 0.587 },
                                { 0.244, 0.546 },
                                { 0.469, 0.547 },
                                { 0.470, 0.566 },
                                { 0.563, 0.567 },
                                { 0.619, 0.602 },
                                { 0.812, 0.604 },
                            },
                        },
                    },
                },
            },
        },

        -- Halls of Devotion: Xanesh(4), Vexiona(9), Hivemind(5), Ra-den(10).
        -- LFR walk order does not match encounter order. LFR zones into
        -- mapID 1582, so Xanesh's standard entry ("After killing Skitra,
        -- backtrack...") is replaced by the verbatim LFR zone-in note; the
        -- 1592 approach to Xanesh and the entire Vexiona step import
        -- verbatim. Hivemind's standard entry assumes arrival from Il'gynoth
        -- (a Gift of Flesh boss), so its transition from Vexiona awaits the
        -- verbatim LFR note + points. Ra-den chains off Hivemind and imports
        -- verbatim.
        [2037] = {
            name   = "Halls of Devotion",
            bosses = { 4, 9, 5, 10 },   -- Dark Inquisitor Xanesh, Vexiona, The Hivemind, Ra-den the Despoiled
            exitNote = "Leave instance group via LFG tool.\n\nNote: If you plan to visit the ^Waking Dream^ wing to kill ^N'Zoth^, you must have ^Ashjra'kamas, Shroud of Resolve^ in your inventory for the Queueing NPC to present the option.",
            minExitNote = "Leave via LFG Tool",
            -- Per-boss lockout bits, captured one kill at a time on a fresh
            -- lockout: Xanesh->2, Vexiona->8, The Hivemind->5, Ra-den->4.
            lockoutBits = { [4] = 2, [9] = 8, [5] = 5, [10] = 4 },
            routing = {
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 4,
                    title     = "Dark Inquisitor Xanesh",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 1582 },
                            kind    = "path",
                            note    = "After zoning in, make your way up the path and stay to the right and find the map exit labeled ^The Ritual Chamber^.",
                            minNote = "Up and right to Ritual Chamber",
                            points  = {
                                { 0.524, 0.772 },
                                { 0.564, 0.688 },
                                { 0.576, 0.536 },
                                { 0.606, 0.535 },
                            },
                        },
                        {
                            when    = { mapID = 1592 },
                            kind    = "path",
                            note    = "Loop your way around the path and you will see ^Queen Azshara^ trapped. Clear the trash to engage ^Dark Inquisitor Xanesh^.",
                            minNote = "Trash then Xanesh",
                            points  = {
                                { 0.141, 0.516 },
                                { 0.141, 0.564 },
                                { 0.205, 0.551 },
                                { 0.203, 0.502 },
                                { 0.435, 0.460 },
                            },
                        },
                    },
                },
                {
                    step      = 2,
                    priority  = 1,
                    bossIndex = 9,
                    title     = "Vexiona",
                    requires  = { 4 },
                    segments  = {
                        {
                            when    = { mapID = 1592 },
                            kind    = "path",
                            note    = "After killing ^Xanesh^, leave the room to the east and towards the map exit for ^Twilight Landing^. Ride the elevator up.",
                            minNote = "East to Elevator",
                            points  = {
                                { 0.558, 0.460 },
                                { 0.740, 0.439 },
                            },
                        },
                        {
                            when    = { mapID = 1593 },
                            kind    = "path",
                            note    = "After reaching the top of the elevator, make your way down the path and clear the trash to engage ^Vexiona^.",
                            minNote = "Trash then Vexiona",
                            points  = {
                                { 0.733, 0.462 },
                                { 0.678, 0.474 },
                                { 0.652, 0.516 },
                                { 0.591, 0.523 },
                                { 0.561, 0.482 },
                                { 0.355, 0.507 },
                            },
                        },
                    },
                },
                {
                    step      = 3,
                    priority  = 1,
                    bossIndex = 5,
                    title     = "The Hivemind",
                    requires  = { 9 },
                    segments  = {
                        {
                            when            = { mapID = 1593 },
                            kind            = "poi",
                            poiSize         = 35,
                            mapLabel        = "Re-origination Anchor",
                            mapLabelPos     = "above",
                            completionCheck = true,
                            note            = "After killing ^Vexiona^, interact with the ^Re-origination Anchor^ behind the boss to be teleported. After you land, continue ahead.",
                            minNote         = "Click Re-origination Anchor",
                            points          = {
                                { 0.295, 0.513 },
                            },
                        },
                        {
                            when    = { mapID = 1582, subZone = "Ny'alotha" },
                            kind    = "path",
                            note    = "Follow the path to the map exit labeled ^The Hive^.",
                            minNote = "Path to Hive",
                            points  = {
                                { 0.572, 0.535 },
                                { 0.570, 0.518 },
                                { 0.522, 0.441 },
                                { 0.494, 0.482 },
                                { 0.456, 0.436 },
                            },
                        },
                        {
                            when    = { mapID = 1590 },
                            kind    = "path",
                            note    = "Enter the room to engage with ^The Hivemind^.",
                            minNote = "Ahead to Hivemind",
                            points  = {
                                { 0.733, 0.825 },
                                { 0.712, 0.850 },
                                { 0.673, 0.795 },
                                { 0.689, 0.765 },
                                { 0.526, 0.556 },
                            },
                        },
                    },
                },
                {
                    step      = 4,
                    priority  = 1,
                    bossIndex = 10,
                    title     = "Ra-den the Despoiled",
                    requires  = { 5 },
                    segments  = {
                        {
                            when    = { mapID = 1590 },
                            kind    = "path",
                            note    = "After killing ^The Hivemind^, continue past them to the next room, and take the elevator up to the ^Terrace of Desolation^.",
                            minNote = "Elevator to Terrace",
                            points  = {
                                { 0.487, 0.497 },
                                { 0.472, 0.450 },
                                { 0.363, 0.343 },
                            },
                        },
                        {
                            when    = { mapID = 1591 },
                            kind    = "path",
                            note    = "After reaching the top of the elevator, follow the path back to find ^Ra-den the Despoiled^.",
                            minNote = "Path to Ra-den",
                            points  = {
                                { 0.389, 0.336 },
                                { 0.419, 0.372 },
                                { 0.448, 0.368 },
                                { 0.496, 0.434 },
                                { 0.499, 0.480 },
                                { 0.634, 0.644 },
                            },
                        },
                    },
                },
            },
        },

        -- Gift of Flesh: Shad'har(6), Drest'agath(7), Il'gynoth(8). This
        -- wing matches encounter order. LFR zones into mapID 1582, so
        -- Shad'har's standard entry (the post-Vexiona anchor + landing path)
        -- is replaced by the verbatim LFR zone-in note to the Maw of Gor'ma
        -- exit. The 1594 descent to Shad'har and the entire Drest'agath and
        -- Il'gynoth steps import verbatim from the standard route.
        [2038] = {
            name   = "Gift of Flesh",
            bosses = { 6, 7, 8 },   -- Shad'har the Insatiable, Drest'agath, Il'gynoth, Corruption Reborn
            exitNote = "Leave instance group via LFG tool.\n\nNote: If you plan to visit the ^Waking Dream^ wing to kill ^N'Zoth^, you must have ^Ashjra'kamas, Shroud of Resolve^ in your inventory for the Queueing NPC to present the option.",
            minExitNote = "Leave via LFG Tool",
            -- Per-boss lockout bits, captured one kill at a time on a fresh
            -- lockout: Shad'har->7, Drest'agath->10, Il'gynoth->12.
            lockoutBits = { [6] = 7, [7] = 10, [8] = 12 },
            routing = {
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 6,
                    title     = "Shad'har the Insatiable",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 1582, subZone = "Ny'alotha" },
                            kind    = "path",
                            note    = "After zoning in, follow the path to ^Maw of Gor'ma^.",
                            minNote = "Path down to Maw of Gor'ma",
                            points  = {
                                { 0.563, 0.628 },
                                { 0.541, 0.561 },
                                { 0.513, 0.535 },
                            },
                        },
                        {
                            when    = { mapID = 1594 },
                            kind    = "path",
                            note    = "Make your way down the spiral, following the path to reach ^Shad'har the Insatiable^.",
                            minNote = "Down spiral to Shad'har",
                            points  = {
                                { 0.599, 0.284 },
                                { 0.585, 0.231 },
                                { 0.529, 0.194 },
                                { 0.460, 0.249 },
                                { 0.467, 0.357 },
                                { 0.532, 0.450 },
                                { 0.528, 0.705 },
                            },
                        },
                    },
                },
                {
                    step      = 2,
                    priority  = 1,
                    bossIndex = 7,
                    title     = "Drest'agath",
                    requires  = { 6 },
                    segments  = {
                        {
                            when    = { mapID = 1594 },
                            kind    = "path",
                            note    = "After defeating ^Shad'har^, leave his room and continue down the spiral.",
                            minNote = "Continue down spiral",
                            points  = {
                                { 0.528, 0.696 },
                                { 0.532, 0.407 },
                                { 0.597, 0.350 },
                            },
                        },
                        {
                            when    = { mapID = 1595 },
                            kind    = "path",
                            note    = "Enter the next room and kill ^Drest'agath^.",
                            minNote = "Kill Drest'agath",
                            points  = {
                                { 0.774, 0.452 },
                                { 0.698, 0.418 },
                                { 0.614, 0.564 },
                                { 0.361, 0.570 },
                            },
                        },
                    },
                },
                {
                    step      = 3,
                    priority  = 1,
                    bossIndex = 8,
                    title     = "Il'gynoth, Corruption Reborn",
                    requires  = { 6, 7 },
                    segments  = {
                        {
                            when    = { mapID = 1595 },
                            kind    = "path",
                            note    = "After killing ^Drest'agath^, leave the room and continue down the spiral toward the map exit ^Chamber of Rebirth^.",
                            minNote = "Continue down spiral",
                            points  = {
                                { 0.360, 0.572 },
                                { 0.614, 0.576 },
                                { 0.637, 0.649 },
                            },
                        },
                        {
                            when    = { mapID = 1596 },
                            kind    = "path",
                            note    = "Follow the path all the way back to find ^Il'gynoth, Corruption Reborn^.",
                            minNote = "Path to Il'gynoth",
                            points  = {
                                { 0.520, 0.845 },
                                { 0.579, 0.812 },
                                { 0.579, 0.701 },
                                { 0.441, 0.619 },
                                { 0.381, 0.514 },
                                { 0.462, 0.353 },
                            },
                        },
                    },
                },
            },
        },

        -- The Waking Dream: Carapace of N'Zoth(11), N'Zoth the Corruptor(12).
        -- The final wing. LFR zones directly into mapID 1597 (the N'Zoth
        -- area), so the standard Carapace route's first two segments (the
        -- 1591 anchor + 1582 bridge approach from Ra-den) don't apply -- the
        -- entry segment awaits the verbatim LFR zone-in note. N'Zoth chains
        -- off Carapace on 1597 and imports verbatim. No cloak-gate exit note
        -- here: you are already at N'Zoth, so the reminder shown on the other
        -- wings would be pointless.
        [2039] = {
            name   = "The Waking Dream",
            bosses = { 11, 12 },   -- Carapace of N'Zoth, N'Zoth the Corruptor
            exitNote = "Leave instance group via LFG tool.",
            minExitNote = "Leave via LFG Tool",
            -- Per-boss lockout bits, captured one kill at a time on a fresh
            -- lockout: Carapace->9, N'Zoth->11.
            lockoutBits = { [11] = 9, [12] = 11 },
            routing = {
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 11,
                    title     = "Carapace of N'Zoth",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 1597 },
                            kind    = "path",
                            note    = "After zoning in, talk to ^Wrathion^ to trigger a cutscene, then kill some adds to start the fight with ^Carapace of N'Zoth^.",
                            minNote = "Talk to Wrathion",
                            points  = {
                                { 0.487, 0.784 },
                                { 0.486, 0.715 },
                            },
                        },
                    },
                },
                {
                    step      = 2,
                    priority  = 1,
                    bossIndex = 12,
                    title     = "N'Zoth the Corruptor",
                    requires  = { 11 },
                    segments  = {
                        {
                            when     = { mapID = 1597 },
                            kind     = "poi",
                            noMarker = true,
                            note     = "After killing ^Carapace^, you will find yourself standing in front of ^N'Zoth^. Attack the boss to start the encounter.",
                            minNote  = "Kill N'Zoth",
                            points   = {
                                { 0.483, 0.294 },
                            },
                        },
                    },
                },
            },
        },
    },
}
