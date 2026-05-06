-------------------------------------------------------------------------------
-- RetroRuns Data -- Uldir
-- Battle for Azeroth, Patch 8.0.1  |  instanceID: 1861  |  journalInstanceID: 1031
-------------------------------------------------------------------------------
-- Uldir is the opening raid of Battle for Azeroth (8.0.1), a titan research
-- and quarantine facility located in Nazmir, Zandalar. The titans built it
-- to study the Old Gods, then accidentally created a fifth Old God (G'huun)
-- in the process and sealed the entire facility away. The seals broke and
-- the player goes in to deal with what's still down there.
--
-- Eight bosses across three wings:
--   * Halls of Containment: Taloc, MOTHER
--   * Crimson Descent: Fetid Devourer, Zek'voz, Vectis (parallel three;
--     all required before Zul unlocks)
--   * Heart of Corruption: Zul, Mythrax, G'huun
--
-- No class tier sets. Patch 8.0.1 predated the return of proper tier sets
-- (which came with 9.2 / Sepulcher). No skip mechanic either -- the
-- account-wide raid skip system arrived with Shadowlands.
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1861] = {
    instanceID        = 1861,
    journalInstanceID = 1031,
    name              = "Uldir",
    expansion         = "Battle for Azeroth",
    patch             = "8.0.1",

    maps = {
        [1148] = "Ruin's Descent",
        [1149] = "Hall of Sanitation",
        [1150] = "Ring of Containment",
        [1151] = "Archives of Eternity",
        [1152] = "Plague Vault",
        [1153] = "Gallery of Failures",
        [1154] = "The Oblivion Door",
        [1155] = "The Festering Core",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    -- No skip mechanic on this raid.

    -- Glory meta-achievement for this raid. Completing all 8 per-boss
    -- criteria below awards the Bloodgorged Crawg mount.
    gloryMeta = {
        id   = 12806,
        name = "Glory of the Uldir Raider",
        rewardItemID       = 163216,
        rewardMountSpellID = 250735,
        rewardName         = "Bloodgorged Crawg",
    },

    bosses = {
        {
            index              = 1,
            name               = "Taloc",
            journalEncounterID = 2168,
            aliases            = {},
            achievements       = {
                { id = 12937, name = "Elevator Music", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 160714, slot = "Feet",     name = "Volatile Walkers",               sources = { [17]=98861, [14]=96691, [15]=98862, [16]=98863 } },
                { id = 160618, slot = "Hands",    name = "Gloves of Descending Madness",   sources = { [17]=98890, [14]=96557, [15]=98891, [16]=98892 } },
                { id = 160639, slot = "Legs",     name = "Greaves of Unending Vigil",      sources = { [17]=98990, [14]=96604, [15]=96605, [16]=96606 } },
                { id = 160631, slot = "Legs",     name = "Legguards of Coalescing Plasma", sources = { [17]=98953, [14]=96580, [15]=96581, [16]=96582 } },
                { id = 160680, slot = "Ranged",   name = "Titanspark Animator",            sources = { [17]=99209, [14]=96631, [15]=96632, [16]=96633 } },
                { id = 160679, slot = "Two-Hand", name = "Khor, Hammer of the Corrupted",  sources = { [17]=99126, [14]=96628, [15]=96629, [16]=96630 } },
                { id = 160622, slot = "Waist",    name = "Bloodstorm Buckle",              sources = { [17]=98898, [14]=96565, [15]=98899, [16]=98900 } },
                { id = 160637, slot = "Wrist",    name = "Crimson Colossus Armguards",     sources = { [17]=98988, [14]=96598, [15]=96599, [16]=96600 } },
                { id = 160629, slot = "Wrist",    name = "Rubywrought Sparkguards",        sources = { [17]=98947, [14]=96578, [15]=98948, [16]=98949 } },
            },
        },
        {
            index              = 2,
            name               = "MOTHER",
            journalEncounterID = 2167,
            aliases            = { "M.O.T.H.E.R." },
            achievements       = {
                { id = 12938, name = "Parental Controls", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 160626, slot = "Hands",            name = "Gloves of Involuntary Amputation",  sources = { [17]=98942, [14]=96571, [15]=96572, [16]=96573 } },
                { id = 160634, slot = "Head",             name = "Gridrunner Galea",                  sources = { [17]=98985, [14]=96589, [15]=96590, [16]=96591 } },
                { id = 160695, slot = "Held In Off-hand", name = "Uldir Subject Manifest",            sources = { [17]=99127, [14]=96676, [15]=96677, [16]=96678 } },
                { id = 160615, slot = "Legs",             name = "Leggings of Lingering Infestation", sources = { [17]=98858, [14]=96548, [15]=96549, [16]=96550 } },
                { id = 160625, slot = "Legs",             name = "Pathogenic Legwraps",               sources = { [17]=98905, [14]=96570, [15]=98906, [16]=98907 } },
                { id = 160632, slot = "Shoulder",         name = "Flame-Sterilized Spaulders",        sources = { [17]=98954, [14]=96583, [15]=96584, [16]=96585 } },
                { id = 160638, slot = "Waist",            name = "Decontaminator's Greatbelt",        sources = { [17]=98989, [14]=96601, [15]=96602, [16]=96603 } },
                { id = 160681, slot = "Weapon",           name = "Glaive of the Keepers",             sources = { [17]=99090, [14]=96634, [15]=96635, [16]=96636 } },
                { id = 160683, slot = "Weapon",           name = "Latticework Scalpel",               sources = { [17]=99125, [14]=96640, [15]=96641, [16]=96642 } },
                { id = 160682, slot = "Weapon",           name = "Mother's Twin Gaze",                sources = { [17]=99112, [14]=96637, [15]=96638, [16]=96639 } },
            },
        },
        {
            index              = 3,
            name               = "Fetid Devourer",
            journalEncounterID = 2146,
            aliases            = { "Fetid" },
            achievements       = {
                { id = 12823, name = "Thrash Mouth - All Stars", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 160643, slot = "Back",     name = "Fetid Horror's Tanglecloak",         sources = { [17]=99202, [14]=96614, [15]=99203, [16]=99204 } },
                { id = 160619, slot = "Chest",    name = "Jerkin of the Aberrant Chimera",     sources = { [17]=98893, [14]=96558, [15]=98894, [16]=98895 } },
                { id = 160628, slot = "Feet",     name = "Fused Monstrosity Stompers",         sources = { [17]=98946, [14]=96575, [15]=96576, [16]=96577 } },
                { id = 160635, slot = "Hands",    name = "Waste Disposal Crushers",            sources = { [17]=98986, [14]=96592, [15]=96593, [16]=96594 } },
                { id = 160616, slot = "Head",     name = "Horrific Amalgam's Hood",            sources = { [17]=98859, [14]=96551, [15]=96552, [16]=96553 } },
                { id = 160689, slot = "Two-Hand", name = "Regurgitated Purifier's Flamestaff", sources = { [17]=99120, [14]=96658, [15]=96659, [16]=96660 } },
                { id = 160685, slot = "Weapon",   name = "Biomelding Cleaver",                 sources = { [17]=99074, [14]=96646, [15]=96647, [16]=96648 } },
            },
        },
        {
            index              = 4,
            name               = "Zek'voz, Herald of N'Zoth",
            journalEncounterID = 2169,
            aliases            = { "Zek'voz" },
            achievements       = {
                { id = 12828, name = "What's in the Box?", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 160627, slot = "Chest",    name = "Chainvest of Assured Quality",     sources = { [17]=98943, [14]=96574, [15]=98944, [16]=98945 } },
                { id = 160624, slot = "Feet",     name = "Quarantine Protocol Treads",       sources = { [17]=98902, [14]=96569, [15]=98903, [16]=98904 } },
                { id = 160640, slot = "Feet",     name = "Warboots of Absolute Eradication", sources = { [17]=98991, [14]=96607, [15]=96608, [16]=96609 } },
                { id = 160718, slot = "Legs",     name = "Greaves of Creeping Darkness",     sources = { [17]=98993, [14]=96699, [15]=96700, [16]=96701 } },
                { id = 160613, slot = "Shoulder", name = "Mantle of Contained Corruption",   sources = { [17]=98856, [14]=96542, [15]=96543, [16]=96544 } },
                { id = 160688, slot = "Two-Hand", name = "Void-Binder",                      sources = { [17]=99116, [14]=96655, [15]=96656, [16]=96657 } },
                { id = 160717, slot = "Waist",    name = "Replicated Chitin Cord",           sources = { [17]=98908, [14]=96698, [15]=98909, [16]=98910 } },
                { id = 160633, slot = "Waist",    name = "Titanspark Energy Girdle",         sources = { [17]=98955, [14]=96586, [15]=96587, [16]=96588 } },
                { id = 160687, slot = "Weapon",   name = "Containment Analysis Baton",       sources = { [17]=99115, [14]=96652, [15]=96653, [16]=96654 } },
                { id = 160617, slot = "Wrist",    name = "Void-Lashed Wristband",            sources = { [17]=98860, [14]=96554, [15]=96555, [16]=96556 } },
            },
        },
        {
            index              = 5,
            name               = "Vectis",
            journalEncounterID = 2166,
            aliases            = {},
            achievements       = {
                { id = 12772, name = "Now We Got Bad Blood", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 160644, slot = "Back",     name = "Plasma-Spattered Greatcloak",     sources = { [17]=99201, [14]=96615, [15]=99199, [16]=99200 } },
                { id = 160636, slot = "Chest",    name = "Chestguard of Virulent Mutagens", sources = { [17]=98987, [14]=96595, [15]=96596, [16]=96597 } },
                { id = 160715, slot = "Hands",    name = "Mutagenic Protofluid Handwraps",  sources = { [17]=98864, [14]=96692, [15]=96693, [16]=96694 } },
                { id = 160623, slot = "Head",     name = "Hood of Pestilent Ichor",         sources = { [17]=98901, [14]=96566, [15]=96567, [16]=96568 } },
                { id = 160716, slot = "Legs",     name = "Blighted Anima Greaves",          sources = { [17]=98956, [14]=96695, [15]=96696, [16]=96697 } },
                { id = 160698, slot = "Off-hand", name = "Vector Deflector",                sources = { [17]=99208, [14]=96683, [15]=96684, [16]=96685 } },
                { id = 160678, slot = "Ranged",   name = "Bow of Virulent Infection",       sources = { [17]=99089, [14]=96625, [15]=96626, [16]=96627 } },
                { id = 160734, slot = "Waist",    name = "Cord of Animated Contagion",      sources = { [17]=98870, [14]=96736, [15]=98871, [16]=98872 } },
                { id = 160621, slot = "Wrist",    name = "Wristwraps of Coursing Miasma",   sources = { [17]=98897, [14]=96562, [15]=96563, [16]=96564 } },
            },
        },
        {
            index              = 6,
            name               = "Zul, Reborn",
            journalEncounterID = 2195,
            aliases            = { "Zul" },
            achievements       = {
                { id = 12830, name = "Edgelords", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 160642, slot = "Back",     name = "Cloak of Rippling Whispers",             sources = { [17]=99205, [14]=96613, [15]=99206, [16]=99207 } },
                { id = 160722, slot = "Chest",    name = "Chestplate of Apocalyptic Machinations", sources = { [17]=98994, [14]=96711, [15]=96712, [16]=96713 } },
                { id = 160630, slot = "Head",     name = "Crest of the Undying Visionary",         sources = { [17]=98950, [14]=96579, [15]=98951, [16]=98952 } },
                { id = 160719, slot = "Head",     name = "Visage of the Ascended Prophet",         sources = { [17]=98865, [14]=96702, [15]=96703, [16]=96704 } },
                { id = 160620, slot = "Shoulder", name = "Usurper's Bloodcaked Spaulders",         sources = { [17]=98896, [14]=96559, [15]=96560, [16]=96561 } },
                { id = 160724, slot = "Waist",    name = "Cincture of Profane Deeds",              sources = { [17]=98958, [14]=96717, [15]=96718, [16]=96719 } },
                { id = 160684, slot = "Weapon",   name = "Pursax, the Backborer",                  sources = { [17]=99110, [14]=96643, [15]=96644, [16]=96645 } },
                { id = 160691, slot = "Weapon",   name = "Tusk of the Reborn Prophet",             sources = { [17]=99107, [14]=96664, [15]=96665, [16]=96666 } },
                { id = 160720, slot = "Wrist",    name = "Armbands of Sacrosanct Acts",            sources = { [17]=98911, [14]=96705, [15]=96706, [16]=96707 } },
                { id = 160723, slot = "Wrist",    name = "Imperious Vambraces",                    sources = { [17]=98995, [14]=96714, [15]=96715, [16]=96716 } },
            },
        },
        {
            index              = 7,
            name               = "Mythrax the Unraveler",
            journalEncounterID = 2194,
            aliases            = { "Mythrax" },
            achievements       = {
                { id = 12836, name = "Existential Crisis", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 160725, slot = "Chest",            name = "C'thraxxi General's Hauberk",           sources = { [17]=98959, [14]=96720, [15]=98960, [16]=98961 } },
                { id = 160614, slot = "Chest",            name = "Robes of the Unraveler",                sources = { [17]=98857, [14]=96545, [15]=96546, [16]=96547 } },
                { id = 160721, slot = "Hands",            name = "Oblivion Crushers",                     sources = { [17]=98957, [14]=96708, [15]=96709, [16]=96710 } },
                { id = 163596, slot = "Head",             name = "Cowl of Dark Portents",                 sources = { [17]=99247, [14]=99244, [15]=99245, [16]=99246 } },
                { id = 160696, slot = "Held In Off-hand", name = "Codex of Imminent Ruin",                sources = { [17]=99128, [14]=96679, [15]=96680, [16]=96681 } },
                { id = 160641, slot = "Shoulder",         name = "Chitinspine Pauldrons",                 sources = { [17]=98992, [14]=96610, [15]=96611, [16]=96612 } },
                { id = 160686, slot = "Two-Hand",         name = "Voror, Gleaming Blade of the Stalwart", sources = { [17]=99124, [14]=96649, [15]=96650, [16]=96651 } },
                { id = 160692, slot = "Weapon",           name = "Luminous Edge of Virtue",               sources = { [17]=99123, [14]=96667, [15]=96668, [16]=96669 } },
            },
        },
        {
            index              = 8,
            name               = "G'huun",
            journalEncounterID = 2147,
            aliases            = {},
            achievements       = {
                { id = 12551, name = "Double Dribble", meta = true, soloable = "yes" },
            },
            soloTip            = "The goal is to collect (2) orbs from opposite sides of the room and deposit them into slots on each side of the boss. Next, the boss will become available to kill.",
            loot = {
                { id = 160728, slot = "Chest",    name = "Tunic of the Sanguine Deity",             sources = { [17]=98912, [14]=96725, [15]=98913, [16]=98914 } },
                { id = 160733, slot = "Feet",     name = "Hematocyst Stompers",                     sources = { [17]=98997, [14]=96733, [15]=96734, [16]=96735 } },
                { id = 160729, slot = "Feet",     name = "Striders of the Putrescent Path",         sources = { [17]=98915, [14]=96726, [15]=98916, [16]=98917 } },
                { id = 160732, slot = "Head",     name = "Helm of the Defiled Laboratorium",        sources = { [17]=98996, [14]=96730, [15]=96731, [16]=96732 } },
                { id = 160699, slot = "Off-hand", name = "Barricade of Purifying Resolve",          sources = { [17]=99198, [14]=96686, [15]=96687, [16]=96688 } },
                { id = 160694, slot = "Ranged",   name = "Re-Origination Pulse Rifle",              sources = { [17]=99070, [14]=96673, [15]=96674, [16]=96675 } },
                { id = 160726, slot = "Shoulder", name = "Amice of Corrupting Horror",              sources = { [17]=98866, [14]=96721, [15]=96722, [16]=96723 } },
                { id = 160731, slot = "Shoulder", name = "Spaulders of Coagulated Viscera",         sources = { [17]=98962, [14]=96727, [15]=96728, [16]=96729 } },
                { id = 160690, slot = "Two-Hand", name = "Heptavium, Staff of Torturous Knowledge", sources = { [17]=99117, [14]=96661, [15]=96662, [16]=96663 } },
                { id = 160727, slot = "Waist",    name = "Cord of Septic Envelopment",              sources = { [17]=98867, [14]=96724, [15]=98868, [16]=98869 } },
                { id = 160693, slot = "Weapon",   name = "Lancet of the Deft Hand",                 sources = { [17]=99197, [14]=96670, [15]=96671, [16]=96672 } },
            },
        },
    },

    routing = {
        -- DAG:
        --   1. Taloc       requires {}
        --   2. MOTHER      requires { 1 }
        --   3. Fetid       requires { 2 }   (parallel)
        --   4. Vectis      requires { 2 }   (parallel)
        --   5. Zek'voz     requires { 2 }   (parallel)
        --   6. Zul         requires { 3, 4, 5 }
        --   7. Mythrax     requires { 6 }
        --   8. G'huun      requires { 7 }
        --
        -- The parallel-three (3, 4, 5) all branch from the central Ring
        -- of Containment hub. The route below visits them in geographic
        -- order (Fetid east, Vectis north, Zek'voz west), each with a
        -- backtrack to the Ring before the next branch. Two backtrack
        -- legs total -- the unavoidable minimum for three dead-end
        -- branches off a hub.

        -- 1. Taloc
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Taloc",
            requires  = {},
            segments  = {
                {
                    mapID   = 1148,
                    kind    = "path",
                    subZone = "Rot's Passage",
                    note    = "After zoning in, walk straight ahead and kill the Tendrils to start the encounter with Taloc.",
                    points  = {
                        { 0.521, 0.828 },
                        { 0.520, 0.346 },
                    },
                },
            },
        },

        -- 2. MOTHER
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "MOTHER",
            requires  = { 1 },
            segments  = {
                {
                    mapID   = 1149,
                    kind    = "path",
                    subZone = "Ruin's Descent",
                    note    = "After killing Taloc, the floor will start to descend. Once you reach the bottom, go straight ahead and click the Titan Console.",
                    points  = {
                        { 0.509, 0.752 },
                        { 0.499, 0.583 },
                    },
                },
                {
                    mapID   = 1149,
                    kind    = "path",
                    subZone = "Ruin's Descent",
                    note    = "After activating the Titan Console, kill several waves of adds from the previous room to unlock the door to the next room.",
                    advanceOn = {
                        kind  = "yell",
                        npc   = "Brann Bronzebeard",
                        match = "get these doors open",
                    },
                    points  = {},
                },
                {
                    mapID   = 1149,
                    kind    = "path",
                    subZone = "Hall of Sanitation",
                    note    = "After finishing the adds, proceed forward and defeat MOTHER.",
                    advanceOn = {
                        kind  = "yell",
                        npc   = "MOTHER",
                        match = "decontamination chamber",
                    },
                    points  = {
                        { 0.507, 0.568 },
                        { 0.505, 0.478 },
                    },
                },
            },
        },

        -- 3. Fetid Devourer (parallel branch east)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Fetid Devourer",
            requires  = { 2 },
            segments  = {
                {
                    mapID   = 1149,
                    kind    = "path",
                    subZone = "Hall of Sanitation",
                    note    = "After defeating MOTHER, continue forward to the map exit labeled Ring of Containment.",
                    points  = {
                        { 0.508, 0.402 },
                        { 0.509, 0.133 },
                    },
                },
                {
                    mapID   = 1150,
                    kind    = "path",
                    subZone = "Ring of Containment",
                    note    = "Once you reach the Ring of Containment, take a right and head for the map exit labeled Gallery of Failures.",
                    points  = {
                        { 0.475, 0.842 },
                        { 0.552, 0.839 },
                        { 0.700, 0.621 },
                        { 0.704, 0.502 },
                    },
                },
                {
                    mapID   = 1153,
                    kind    = "path",
                    subZone = "Ring of Containment",
                    note    = "Continue following the path to engage Fetid Devourer.",
                    points  = {
                        { 0.113, 0.495 },
                        { 0.144, 0.554 },
                        { 0.184, 0.479 },
                        { 0.631, 0.487 },
                    },
                },
            },
        },

        -- 4. Vectis (parallel branch north)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 5,
            title     = "Vectis",
            requires  = { 2 },
            segments  = {
                {
                    mapID   = 1153,
                    kind    = "path",
                    subZone = "Gallery of Failures",
                    note    = "After killing Fetid Devourer, go back the way you came to arrive back in the Ring of Containment.",
                    points  = {
                        { 0.627, 0.484 },
                        { 0.181, 0.476 },
                        { 0.145, 0.403 },
                        { 0.113, 0.450 },
                    },
                },
                {
                    mapID   = 1150,
                    kind    = "path",
                    subZone = "Ring of Containment",
                    note    = "Back in the Ring of Containment, head north to the map exit labeled Plague Vault.",
                    points  = {
                        { 0.702, 0.500 },
                        { 0.701, 0.385 },
                        { 0.553, 0.164 },
                        { 0.476, 0.164 },
                    },
                },
                {
                    mapID   = 1152,
                    kind    = "path",
                    subZone = "Ring of Containment",
                    note    = "Continue following the path to reach Vectis.",
                    points  = {
                        { 0.537, 0.915 },
                        { 0.564, 0.879 },
                        { 0.527, 0.838 },
                        { 0.523, 0.342 },
                    },
                },
            },
        },

        -- 5. Zek'voz (parallel branch west)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 4,
            title     = "Zek'voz, Herald of N'Zoth",
            requires  = { 2 },
            segments  = {
                {
                    mapID   = 1152,
                    kind    = "path",
                    subZone = "Plague Vault",
                    note    = "After killing Vectis, go back the way you came to arrive back in the Ring of Containment.",
                    points  = {
                        { 0.525, 0.343 },
                        { 0.527, 0.842 },
                        { 0.490, 0.879 },
                        { 0.514, 0.914 },
                    },
                },
                {
                    mapID   = 1150,
                    kind    = "path",
                    subZone = "Ring of Containment",
                    note    = "After back in the Ring of Containment, head to the leftmost map exit labeled Archives of Eternity.",
                    points  = {
                        { 0.475, 0.165 },
                        { 0.401, 0.163 },
                        { 0.250, 0.384 },
                        { 0.245, 0.502 },
                    },
                },
                {
                    mapID   = 1151,
                    kind    = "path",
                    subZone = "Ring of Containment",
                    note    = "Continue following the path to reach Zek'voz, Herald of N'Zoth. Clear trash to start the encounter.",
                    points  = {
                        { 0.867, 0.507 },
                        { 0.834, 0.428 },
                        { 0.794, 0.506 },
                        { 0.405, 0.509 },
                    },
                },
            },
        },

        -- 6. Zul, Reborn (gated on parallel-three completion)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Zul, Reborn",
            requires  = { 3, 4, 5 },
            segments  = {
                {
                    mapID   = 1151,
                    kind    = "path",
                    subZone = "Archives of Eternity",
                    note    = "After killing Zek'voz, go back the way you came to arrive back in the Ring of Containment.",
                    points  = {
                        { 0.405, 0.508 },
                        { 0.798, 0.511 },
                        { 0.836, 0.426 },
                        { 0.870, 0.508 },
                    },
                },
                {
                    mapID   = 1150,
                    kind    = "path",
                    subZone = "Ring of Containment",
                    note    = "After arriving back in the Ring of Containment, head straight ahead towards the map exit labeled The Oblivion Door.",
                    points  = {
                        { 0.246, 0.503 },
                        { 0.378, 0.504 },
                    },
                },
                {
                    mapID   = 1154,
                    kind    = "path",
                    subZone = "The Oblivion Door",
                    note    = "After arriving in The Oblivion Door, clear all trash to start the encounter with Zul, Reborn.",
                    points  = {
                        { 0.341, 0.531 },
                        { 0.487, 0.533 },
                    },
                },
            },
        },

        -- 7. Mythrax the Unraveler (POI star: Titan Console)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Mythrax the Unraveler",
            requires  = { 6 },
            segments  = {
                {
                    mapID   = 1154,
                    kind    = "poi",
                    subZone = "The Oblivion Door",
                    poiSize = 35,
                    note    = "After killing Zul, activate the Titan Console on the south end of the platform. Then jump into The Festering Core to fight Mythrax the Unraveler.",
                    points  = {
                        { 0.512, 0.752 },
                    },
                },
            },
        },

        -- 8. G'huun
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "G'huun",
            requires  = { 7 },
            segments  = {
                {
                    mapID   = 1155,
                    kind    = "path",
                    subZone = "Chamber of Corruption",
                    note    = "After defeating Mythrax, follow the path north to engage the final boss, G'huun.",
                    points  = {
                        { 0.527, 0.809 },
                        { 0.523, 0.258 },
                    },
                },
            },
        },
    },
}
