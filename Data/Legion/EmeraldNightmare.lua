-------------------------------------------------------------------------------
-- RetroRuns Data -- The Emerald Nightmare
-- Legion, Patch 7.0.3  |  instanceID: 1520  |  journalInstanceID: 768
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1520] = {
    instanceID        = 1520,
    journalInstanceID = 768,
    name              = "The Emerald Nightmare",
    expansion         = "Legion",
    patch             = "7.0.3",

    exitNote = "Run past the pond to find an exit portal among the trees.",
    minExitNote = "Past Pond to Portal",

    -- Entrance is in Val'sharah (mapID 641), subZone Shaladrassil,
    -- under the corrupted World Tree. The player walks through a
    -- portal at the tree's base to zone into the raid.
    entrance = {
        mapID   = 641,
        x       = 0.567,
        y       = 0.375,
        subZone = "Shaladrassil",
    },

    -- Hub architecture: mapID 778 (Core of the Nightmare) is the
    -- central hub the player returns to between every boss. It has
    -- four outbound portals -- one per Wing 2 boss (Il'gynoth,
    -- Elerethe, Ursoc, Dragons of Nightmare) -- plus a center
    -- portal (the Nightmare Iris) that opens after all four wings
    -- are dead, leading to Cenarius and Xavius.
    maps = {
        [777] = "Clutch of Corruption",     -- Nythendra approach (entrance courtyard)
        [778] = "Core of the Nightmare",    -- Central portal hub between every boss
        [779] = "Mulgore",                  -- Elerethe Renferal wing
        [780] = "Un'Goro Crater",           -- Il'gynoth wing
        [781] = "The Emerald Nightmare",    -- Dragons of Nightmare wing (in-zone subZone is "The Emerald Dreamway")
        [786] = "Grizzly Hills",            -- Ursoc wing
        [787] = "Moonglade",                -- Cenarius wing (reached via central Nightmare Iris)
        [788] = "Rift of Aln",              -- Xavius wing (reached via portal behind Cenarius)
    },

    -- Empty by design: Emerald Nightmare predates Legion's tier
    -- reintroduction (patch 7.0.3, before tier-19 in 7.1.5). The class
    -- gearing path here was the artifact-relic system, not tier sets.
    -- The raid's per-class loot table contains no `classes = { N }`
    -- rows because there are no class-restricted tier pieces to gate
    -- on. Don't add labels here without matching loot rows; the data
    -- shape matches Trial of Valor (same relic-only Legion cohort) and
    -- contrasts with Nighthold/Tomb/Antorus (later Legion raids that
    -- did ship tier sets).
    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    skipQuests = {
        normal = 44283,
        heroic = 44284,
        mythic = 44285,
    },

    -- Surfaced to players via the Skips window's per-row info button.
    skipTrigger = {
        questName = "The Emerald Nightmare: Piercing the Veil",
        details   = "Kill ^Nythendra^, then talk to ^Malfurion Stormrage^ to skip to ^Cenarius^.",
    },

    -- Glory meta-achievement covering both Emerald Nightmare and The
    -- Nighthold. Completing the listed per-boss achievements across
    -- both raids awards the Grove Defiler mount. The same gloryMeta
    -- block appears in Nighthold.lua so the entry surfaces in either
    -- raid's achievements pane with shared progress.
    gloryMeta = {
        id   = 11180,
        name = "Glory of the Legion Raider",
        rewardItemID       = 141216,
        rewardMountSpellID = 193007,
        rewardName         = "Grove Defiler",
    },

    -- Dragons of Nightmare is a multi-NPC encounter -- four dragons
    -- (Ysondre, Lethon, Taerar, Emeriss) are alive simultaneously,
    -- modeled as a single encounter (journalEncounterID 1704) covering
    -- the room as a whole.
    bosses = {
        {
            index              = 1,
            name               = "Nythendra",
            journalEncounterID = 1703,
            aliases            = {},
            achievements = {
                { id = 10555, name = "Buggy Fight", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 139224, slot = "Chest",    name = "Insect-Etched Chestplate",  sources = { [17]=81275, [14]=80524, [15]=81273, [16]=81274 } },
                { id = 139200, slot = "Feet",     name = "Stained Maggot Squishers",  sources = { [17]=81178, [14]=80501, [15]=81176, [16]=81177 } },
                { id = 139214, slot = "Head",     name = "Greyed Dragonscale Coif",   sources = { [17]=81227, [14]=80515, [15]=81225, [16]=81226 } },
                { id = 139191, slot = "Shoulder", name = "Ancient Dreamwoven Mantle", sources = { [17]=81130, [14]=80492, [15]=81128, [16]=81129 } },
                { id = 139212, slot = "Waist",    name = "Creeping String of Larva",  sources = { [17]=81242, [14]=80513, [15]=81240, [16]=81241 } },
                { id = 139197, slot = "Waist",    name = "Lifeless Buckled Girdle",   sources = { [17]=81200, [14]=80498, [15]=81198, [16]=81199 } },
                { id = 139235, slot = "Wrist",    name = "Wristclamps of Mad Dreams", sources = { [17]=81272, [14]=80535, [15]=81270, [16]=81271 } },
            },
        },
        {
            index              = 2,
            name               = "Il'gynoth, Heart of Corruption",
            journalEncounterID = 1738,
            -- Aliases include both the short form ("Il'gynoth") and
            -- the longer in-game encounter name with the "The" article
            -- ("Il'gynoth, The Heart of Corruption"). The Encounter
            -- Journal title omits "The" but the combat encounter event
            -- includes it; aliasing both lets the addon recognize the
            -- kill regardless of which form Blizzard reports.
            aliases            = { "Il'gynoth", "Il'gynoth, The Heart of Corruption" },
            achievements = {
                { id = 10830, name = "Took the Red Eye Down", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 139202, slot = "Hands",    name = "Dreamsculptor's Gloves",         sources = { [17]=81196, [14]=80503, [15]=81194, [16]=81195 } },
                { id = 139213, slot = "Hands",    name = "Gauntlets of Malevolent Intent", sources = { [17]=81224, [14]=80514, [15]=81222, [16]=81223 } },
                { id = 139188, slot = "Head",     name = "Celestially Aligned Hood",       sources = { [17]=81139, [14]=80489, [15]=81137, [16]=81138 } },
                { id = 139215, slot = "Legs",     name = "Singular Chain Leggings",        sources = { [17]=81245, [14]=80516, [15]=81243, [16]=81244 } },
                { id = 139206, slot = "Shoulder", name = "Otherworldy Leather Mantle",     sources = { [17]=81203, [14]=80507, [15]=81201, [16]=81202 } },
                { id = 139233, slot = "Shoulder", name = "Pauldrons of Shifting Runes",    sources = { [17]=81284, [14]=80533, [15]=81282, [16]=81283 } },
                { id = 139227, slot = "Waist",    name = "Waistplate of Nameless Horror",  sources = { [17]=81263, [14]=80527, [15]=81261, [16]=81262 } },
                { id = 139187, slot = "Wrist",    name = "Clasp of Cosmic Insignificance", sources = { [17]=81154, [14]=80488, [15]=81152, [16]=81153 } },
            },
            soloTip = "You can just attack through his shield at this point. But if you need help, kill Nightmare Ichors near the boss to bring down his shield. When he becomes vulnerable, go inside and finish him off.",
        },
        {
            index              = 3,
            name               = "Elerethe Renferal",
            journalEncounterID = 1744,
            aliases            = {},
            achievements = {
                { id = 10771, name = "Webbing Crashers", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 138221, slot = "Back",     name = "Gossamer-Spun Greatcloak",  sources = { [17]=81046, [14]=79557, [15]=81044, [16]=81045 } },
                { id = 139221, slot = "Chest",    name = "Patient Ambusher's Hauberk", sources = { [17]=81236, [14]=80522, [15]=81234, [16]=81235 } },
                { id = 139219, slot = "Feet",     name = "Black Venom Sabatons",      sources = { [17]=81251, [14]=80520, [15]=81249, [16]=81250 } },
                { id = 139204, slot = "Head",     name = "Mask of Multitudinous Eyes", sources = { [17]=81215, [14]=80505, [15]=81213, [16]=81214 } },
                { id = 139229, slot = "Head",     name = "Venom-Fanged Barbute",      sources = { [17]=81269, [14]=80529, [15]=81267, [16]=81268 } },
                { id = 139190, slot = "Legs",     name = "Ragged Horrorweave Leggings", sources = { [17]=81160, [14]=80491, [15]=81158, [16]=81159 } },
                { id = 139230, slot = "Legs",     name = "Storm-Battered Legplates",  sources = { [17]=81172, [14]=80530, [15]=81170, [16]=81171 } },
                { id = 138217, slot = "Waist",    name = "Pliable Spider Silk Cinch", sources = { [17]=81127, [14]=79554, [15]=81125, [16]=81126 } },
                { id = 139209, slot = "Wrist",    name = "Wristwraps of Broken Trust", sources = { [17]=81187, [14]=80510, [15]=81185, [16]=81186 } },
            },
        },
        {
            index              = 4,
            name               = "Ursoc",
            journalEncounterID = 1667,
            aliases            = {},
            achievements = {
                { id = 10753, name = "Scare Bear", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 139208, slot = "Chest",    name = "Scarred Ragefang Chestpiece", sources = { [17]=81206, [14]=80509, [15]=81204, [16]=81205 } },
                { id = 139195, slot = "Feet",     name = "Crimson Wool-Lined Slippers", sources = { [17]=81145, [14]=80496, [15]=81143, [16]=81144 } },
                { id = 139220, slot = "Feet",     name = "Scored Ironclaw Sabatons",    sources = { [17]=81254, [14]=80521, [15]=81252, [16]=81253 } },
                { id = 139234, slot = "Feet",     name = "Trampling Warboots",          sources = { [17]=81175, [14]=80534, [15]=81173, [16]=81174 } },
                { id = 139226, slot = "Hands",    name = "Primal Gauntlets of Rage",    sources = { [17]=81169, [14]=80526, [15]=81167, [16]=81168 } },
                { id = 139201, slot = "Legs",     name = "Splotched Bloodfur Leggings", sources = { [17]=81212, [14]=80502, [15]=81210, [16]=81211 } },
                { id = 139217, slot = "Shoulder", name = "Matted Fur Pauldrons",        sources = { [17]=81233, [14]=80518, [15]=81231, [16]=81232 } },
                { id = 139196, slot = "Wrist",    name = "Ragged Fur Wristwraps",       sources = { [17]=81148, [14]=80497, [15]=81146, [16]=81147 } },
            },
        },
        {
            index              = 5,
            name               = "Dragons of Nightmare",
            journalEncounterID = 1704,
            barLabel           = "Dragons",
            aliases            = { "Ysondre", "Lethon", "Taerar", "Emeriss" },
            achievements = {
                { id = 10663, name = "Imagined Dragons World Tour", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 138215, slot = "Chest",    name = "Dreamscale Inlaid Vestments",    sources = { [17]=81124, [14]=79552, [15]=81122, [16]=81123 } },
                { id = 138216, slot = "Chest",    name = "Horror Inscribed Chestguard",    sources = { [17]=81260, [14]=79553, [15]=81258, [16]=81259 } },
                { id = 138211, slot = "Feet",     name = "Malignant Sabatons",             sources = { [17]=81218, [14]=79548, [15]=81216, [16]=81217 } },
                { id = 138214, slot = "Hands",    name = "Gauntlets of the Demented Mind", sources = { [17]=81239, [14]=79551, [15]=81237, [16]=81238 } },
                { id = 138212, slot = "Hands",    name = "Handwraps of Delusional Power",  sources = { [17]=81151, [14]=79549, [15]=81149, [16]=81150 } },
                { id = 139205, slot = "Head",     name = "Cowl of Fright",                 sources = { [17]=81184, [14]=80506, [15]=81182, [16]=81183 } },
                { id = 138218, slot = "Wrist",    name = "Dragonbone Wristclamps",         sources = { [17]=81163, [14]=79555, [15]=81161, [16]=81162 } },
                { id = 138219, slot = "Wrist",    name = "Dragonspur Wristguards",         sources = { [17]=81190, [14]=79556, [15]=81188, [16]=81189 } },
            },
        },
        {
            index              = 6,
            name               = "Cenarius",
            journalEncounterID = 1750,
            aliases            = {},
            achievements = {
                { id = 10772, name = "Use the Force(s)", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 139248, slot = "Back",     name = "Evergreen Vinewrap Drape",      sources = { [17]=81049, [14]=80544, [15]=81047, [16]=81048 } },
                { id = 139207, slot = "Chest",    name = "Grove Keeper's Robe",           sources = { [17]=82062, [14]=80508, [15]=82061, [16]=81197 } },
                { id = 139194, slot = "Feet",     name = "Cozy Dryad Hoof-Socks",         sources = { [17]=81142, [14]=80495, [15]=81140, [16]=81141 } },
                { id = 139225, slot = "Hands",    name = "Fitted Ironbark Gauntlets",     sources = { [17]=81166, [14]=80525, [15]=81164, [16]=81165 } },
                { id = 139231, slot = "Head",     name = "Crown of Steely Brambles",      sources = { [17]=81278, [14]=80531, [15]=81276, [16]=81277 } },
                { id = 139192, slot = "Shoulder", name = "Mantle of Perpetual Bloom",     sources = { [17]=81133, [14]=80493, [15]=81131, [16]=81132 } },
                { id = 139218, slot = "Shoulder", name = "Thorny Bramblemail Pauldrons",  sources = { [17]=81248, [14]=80519, [15]=81246, [16]=81247 } },
                { id = 139198, slot = "Waist",    name = "Forest-Lord's Waistwrap",       sources = { [17]=81193, [14]=80499, [15]=81191, [16]=81192 } },
                { id = 139211, slot = "Waist",    name = "Laughing Sister's Pouch-Chain", sources = { [17]=81221, [14]=80512, [15]=81219, [16]=81220 } },
            },
        },
        {
            index              = 7,
            name               = "Xavius",
            journalEncounterID = 1726,
            aliases            = {},
            achievements = {
                { id = 10755, name = "I Attack the Darkness", meta = true, soloable = "kinda" },
            },
            specialLoot = {
                -- Illusion: Nightmare. Weapon enchant illusion that
                -- adds a green/sickly glow to a weapon. Drops from
                -- Xavius all difficulties (the only non-gear drop
                -- in the raid). Also obtainable from the Black
                -- Market Auction House via Thaumaturge Vashreen at
                -- a 2,500g opening bid -- relevant for gold-rich
                -- players who don't want to wait for the low Xavius
                -- drop chance.
                { id = 138827, kind = "illusion", name = "Illusion: Nightmare", sourceID = 5876 },
            },
            loot = {
                { id = 139193, slot = "Chest",    name = "Maddening Robe of Secrets",      sources = { [17]=81136, [14]=80494, [15]=81134, [16]=81135 } },
                { id = 139199, slot = "Feet",     name = "Boots of Endless Betrayal",      sources = { [17]=81209, [14]=80500, [15]=81207, [16]=81208 } },
                { id = 139189, slot = "Head",     name = "Hood of Darkened Visions",       sources = { [17]=81157, [14]=80490, [15]=81155, [16]=81156 } },
                { id = 139216, slot = "Legs",     name = "Disjointed Linkage Leggings",    sources = { [17]=81230, [14]=80517, [15]=81228, [16]=81229 } },
                { id = 139203, slot = "Legs",     name = "Repulsive Leathery Pants",       sources = { [17]=81181, [14]=80504, [15]=81179, [16]=81180 } },
                -- The First Satyr's Spaulders: leather shoulders, drops on
                -- Heroic and Mythic only (per EJ inspection -- not on LFR
                -- or Normal). C_TransmogCollection.GetItemInfo(itemID)
                -- returns nil for this item, and the EJ's
                -- GetLootInfoByIndex returns the row with a nil link.
                -- Sources 93947 and 93948 both exist for this item (found
                -- via GetSourceInfo brute-force scan); both grant the
                -- same appearance (visualID 31252).
                --
                -- Encoded as binary shape (one sourceID cloned across all
                -- four buckets) so the renderer treats it like the
                -- legendary pattern -- a single bracketed indicator rather
                -- than a 4-dot strip. The H/M-only drop limitation isn't
                -- visually represented in the data shape; the appearance-
                -- collection check via GetAllAppearanceSources resolves
                -- correctly regardless of which bucket we read.
                { id = 141006, slot = "Shoulder", name = "The First Satyr's Spaulders",    sources = { [17]=93947, [14]=93947, [15]=93947, [16]=93947 } },
                { id = 139232, slot = "Shoulder", name = "Midnight Herald's Pauldrons",    sources = { [17]=81281, [14]=80532, [15]=81279, [16]=81280 } },
                { id = 139228, slot = "Waist",    name = "Eon-Tempered Waistplate",        sources = { [17]=81266, [14]=80528, [15]=81264, [16]=81265 } },
                { id = 139222, slot = "Wrist",    name = "Manacles of the Nightmare Colossus", sources = { [17]=81257, [14]=80523, [15]=81255, [16]=81256 } },
            },
        },
    },

    -- Routing structure (canonical clockwise-from-Ursoc community order):
    --   step 1, bossIndex 1: Nythendra              requires {}
    --   step 2, bossIndex 4: Ursoc                  requires { 1 }
    --   step 3, bossIndex 5: Dragons of Nightmare   requires { 1 }
    --   step 4, bossIndex 3: Elerethe Renferal      requires { 1 }
    --   step 5, bossIndex 2: Il'gynoth              requires { 1 }
    --   step 6, bossIndex 6: Cenarius               requires { 2, 3, 4, 5 }
    --   step 7, bossIndex 7: Xavius                 requires { 6 }
    --
    -- The routing order (Ursoc 2nd) differs from the Encounter
    -- Journal's order (Il'gynoth 2nd) -- the addon walks the
    -- parallel middle bosses clockwise from Ursoc, which is the
    -- common solo route since the Ursoc-Dragons-Elerethe-Il'gynoth
    -- loop returns the player to the central hub naturally.
    --
    -- Hub-and-spoke physical structure: after Nythendra, every
    -- subsequent boss step starts from mapID 778 (Core of the
    -- Nightmare). Bosses 2-5 take one of four spoke portals;
    -- bosses 6-7 use the center portal (the Nightmare Iris) that
    -- unlocks once all four wings are clear. The player physically
    -- traverses 778 between every boss kill.
    lfrWings = {
        -- Wing 1 -- Darkbough: Nythendra, Elerethe, Il'gynoth (LFR order).
        -- Wing 2 -- Tormented Guardians: Ursoc, Dragons, Cenarius (not yet keyed).
        -- Wing 3 -- Rift of Aln: Xavius (not yet keyed).
        [1926] = {
            name   = "Rift of Aln",
            bosses = { 7 },
            lockoutBits = { [7] = 4 },
            routing = {
                -- 7. Xavius
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 7,
                    title     = "Xavius",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 788 },
                            kind    = "path",
                            note    = "After zoning in, start killing trash. They will continue coming in waves until finally, you will meet ^Xavius^.",
                            minNote = "Trash then Xavius",
                            points  = {
                                { 0.374, 0.770 },
                                { 0.467, 0.528 },
                            },
                        },
                    },
                },
            },
        },

        [1927] = {
            name   = "Tormented Guardians",
            bosses = { 4, 5, 6 },
            lockoutBits = { [4] = 1, [5] = 3, [6] = 7 },
            routing = {
                -- 4. Ursoc
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 4,
                    title     = "Ursoc",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 786 },
                            kind    = "path",
                            note    = "After zoning in, follow the path around to find ^Ursoc^.",
                            minNote = "Path to Ursoc",
                            points  = {
                                { 0.307, 0.668 },
                                { 0.466, 0.821 },
                                { 0.505, 0.745 },
                                { 0.474, 0.341 },
                            },
                        },
                    },
                },

                -- 5. Dragons of Nightmare
                {
                    step      = 2,
                    priority  = 1,
                    bossIndex = 5,
                    title     = "Dragons of Nightmare",
                    requires  = { 4 },
                    segments  = {
                        {
                            when    = { mapID = 786 },
                            kind    = "path",
                            note    = "After killing ^Ursoc^, go back the way you came and go back through the portal to ^Core of the Nightmare^.",
                            minNote = "Back to Core hub",
                            points  = {
                                { 0.479, 0.333 },
                                { 0.495, 0.797 },
                                { 0.420, 0.786 },
                                { 0.300, 0.653 },
                            },
                        },
                        {
                            when    = { mapID = 778 },
                            kind    = "path",
                            note    = "After walking through the portal, continue on the path and walk through the second portal to ^The Emerald Nightmare^.",
                            minNote = "Emerald Nightmare Portal",
                            points  = {
                                { 0.559, 0.216 },
                                { 0.544, 0.354 },
                                { 0.571, 0.450 },
                                { 0.603, 0.446 },
                                { 0.647, 0.374 },
                            },
                        },
                        {
                            when    = { mapID = 781 },
                            kind    = "path",
                            note    = "After arriving in ^The Emerald Nightmare^, proceed forward to start the encounter with ^Dragons of Nightmare^.",
                            minNote = "Ahead to Dragons",
                            points  = {
                                { 0.279, 0.790 },
                                { 0.300, 0.655 },
                                { 0.357, 0.514 },
                            },
                        },
                    },
                },

                -- 6. Cenarius
                {
                    step      = 3,
                    priority  = 1,
                    bossIndex = 6,
                    title     = "Cenarius",
                    requires  = { 5 },
                    segments  = {
                        {
                            when    = { mapID = 781 },
                            kind    = "path",
                            note    = "After defeating the ^Dragons of Nightmare^, go back the way you came and return to ^Core of the Nightmare^.",
                            minNote = "Back to Core hub",
                            points  = {
                                { 0.357, 0.513 },
                                { 0.305, 0.690 },
                                { 0.277, 0.795 },
                            },
                        },
                        {
                            when        = { mapID = 778 },
                            kind        = "poi",
                            mapLabel    = "Malfurion",
                            mapLabelPos = "above",
                            note        = "After returning to the central hub, talk to ^Malfurion^ then interact with the ^Nightmare Iris^ to continue.",
                            minNote     = "Malfurion then Iris",
                            points      = {
                                { 0.561, 0.485 },
                            },
                        },
                        {
                            when    = { mapID = 787 },
                            kind    = "path",
                            note    = "Once inside ^Moonglade^, work your way down to ^Cenarius^ and kill him.",
                            minNote = "Down to Cenarius",
                            points  = {
                                { 0.360, 0.840 },
                                { 0.471, 0.407 },
                                { 0.574, 0.354 },
                            },
                        },
                    },
                },
            },
        },

        [1912] = {
            name   = "Darkbough",
            bosses = { 1, 3, 2 },
            lockoutBits = { [1] = 2, [3] = 6, [2] = 5 },
            routing = {
                -- 1. Nythendra
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 1,
                    title     = "Nythendra",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 777 },
                            kind    = "path",
                            note    = "After zoning in, proceed forward and clear the slimes to begin the encounter with ^Nythendra^.",
                            minNote = "Trash then Nythendra",
                            points  = {
                                { 0.446, 0.570 },
                                { 0.526, 0.523 },
                            },
                        },
                    },
                },

                -- 2. Elerethe Renferal
                {
                    step      = 2,
                    priority  = 1,
                    bossIndex = 3,
                    title     = "Elerethe Renferal",
                    requires  = { 1 },
                    segments  = {
                        {
                            when    = { mapID = 777 },
                            kind    = "path",
                            note    = "After defeating ^Nythendra^, follow the path up and around towards the map exit labeled ^Core of the Nightmare^.",
                            minNote = "Path to Core hub",
                            points  = {
                                { 0.562, 0.460 },
                                { 0.698, 0.377 },
                                { 0.567, 0.228 },
                                { 0.406, 0.328 },
                                { 0.356, 0.513 },
                                { 0.341, 0.773 },
                            },
                        },
                        {
                            when    = { mapID = 778, subZone = "Clutch of Corruption" },
                            kind    = "path",
                            note    = "When you reach the central hub, take the map exit labeled ^Mulgore^.",
                            minNote = "Mulgore Portal",
                            points  = {
                                { 0.235, 0.748 },
                                { 0.238, 0.657 },
                                { 0.290, 0.594 },
                                { 0.472, 0.523 },
                                { 0.561, 0.486 },
                                { 0.587, 0.518 },
                                { 0.627, 0.510 },
                                { 0.688, 0.566 },
                            },
                        },
                        {
                            when    = { mapID = 779 },
                            kind    = "path",
                            note    = "Once inside ^Mulgore^, follow the path around, and clear the trash on your way to ^Elerethe Renferal^.",
                            minNote = "Trash then Elerethe",
                            points  = {
                                { 0.881, 0.877 },
                                { 0.849, 0.948 },
                                { 0.732, 0.940 },
                                { 0.616, 0.745 },
                                { 0.536, 0.362 },
                                { 0.347, 0.576 },
                            },
                        },
                    },
                },

                -- 3. Il'gynoth, Heart of Corruption
                {
                    step      = 3,
                    priority  = 1,
                    bossIndex = 2,
                    title     = "Il'gynoth, Heart of Corruption",
                    requires  = { 3 },
                    segments  = {
                        {
                            when    = { mapID = 779 },
                            kind    = "path",
                            note    = "After defeating ^Elerethe^, backtrack to the portal and return to ^Core of the Nightmare^. You can jump off the ledge for a shortcut.",
                            minNote = "Jump off and die",
                            points  = {
                                { 0.353, 0.660 },
                                { 0.395, 0.753 },
                                { 0.490, 0.733 },
                                { 0.807, 0.945 },
                                { 0.879, 0.875 },
                            },
                        },
                        {
                            when    = { mapID = 778 },
                            kind    = "path",
                            note    = "When you're back in the central hub, take the final portal towards ^Un'Goro Crater^.",
                            minNote = "Un'Goro Crater Portal",
                            points  = {
                                { 0.588, 0.520 },
                                { 0.583, 0.646 },
                            },
                        },
                        {
                            when    = { mapID = 780 },
                            kind    = "path",
                            note    = "When you reach ^Un'Goro Crater^, follow the linear path to the back and kill ^Il'gynoth^.",
                            minNote = "Path to Il'gynoth",
                            points  = {
                                { 0.654, 0.973 },
                                { 0.557, 0.760 },
                                { 0.498, 0.520 },
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
            title     = "Nythendra",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 777 },
                    kind    = "path",
                    note    = "After zoning in, proceed forward and clear the slimes to begin the encounter with ^Nythendra^.",
                    minNote = "Trash then Nythendra",
                    points  = {
                        { 0.446, 0.570 },
                        { 0.526, 0.523 },
                    },
                },
            },
        },

        {
            step      = 2,
            priority  = 2,
            bossIndex = 4,
            title     = "Ursoc",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 777 },
                    kind    = "path",
                    note    = "After defeating ^Nythendra^, follow the path up and around towards the map exit labeled ^Core of the Nightmare^.",
                    minNote = "Path to Core hub",
                    points  = {
                        { 0.562, 0.460 },
                        { 0.698, 0.377 },
                        { 0.567, 0.228 },
                        { 0.406, 0.328 },
                        { 0.356, 0.513 },
                        { 0.341, 0.773 },
                    },
                },
                {
                    when    = { mapID = 778 },
                    kind    = "path",
                    note    = "Continue working your way towards the central hub. When you get there, take the first path on the left and take the portal to ^Grizzly Hills^.",
                    minNote = "Grizzly Hills Portal",
                    points  = {
                        { 0.341, 0.831 },
                        { 0.221, 0.740 },
                        { 0.257, 0.607 },
                        { 0.572, 0.480 },
                        { 0.542, 0.324 },
                        { 0.559, 0.206 },
                    },
                },
                {
                    when    = { mapID = 786 },
                    kind    = "path",
                    note    = "After walking through the portal into ^Grizzly Hills^, follow the path around to find ^Ursoc^.",
                    minNote = "Path to Ursoc",
                    points  = {
                        { 0.307, 0.668 },
                        { 0.466, 0.821 },
                        { 0.505, 0.745 },
                        { 0.474, 0.341 },
                    },
                },
            },
        },

        {
            step      = 3,
            priority  = 3,
            bossIndex = 5,
            title     = "Dragons of Nightmare",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 786 },
                    kind    = "path",
                    note    = "After killing ^Ursoc^, go back the way you came and go back through the portal to ^Core of the Nightmare^.",
                    minNote = "Back to Core hub",
                    points  = {
                        { 0.479, 0.333 },
                        { 0.495, 0.797 },
                        { 0.420, 0.786 },
                        { 0.300, 0.653 },
                    },
                },
                {
                    when    = { mapID = 778 },
                    kind    = "path",
                    note    = "After walking through the portal, continue on the path and walk through the second portal to ^The Emerald Nightmare^.",
                    minNote = "Emerald Nightmare Portal",
                    points  = {
                        { 0.559, 0.216 },
                        { 0.544, 0.354 },
                        { 0.571, 0.450 },
                        { 0.603, 0.446 },
                        { 0.647, 0.374 },
                    },
                },
                {
                    when    = { mapID = 781 },
                    kind    = "path",
                    note    = "After arriving in ^The Emerald Nightmare^, proceed forward to start the encounter with ^Dragons of Nightmare^.",
                    minNote = "Ahead to Dragons",
                    points  = {
                        { 0.279, 0.790 },
                        { 0.300, 0.655 },
                        { 0.357, 0.514 },
                    },
                },
            },
        },

        {
            step      = 4,
            priority  = 4,
            bossIndex = 3,
            title     = "Elerethe Renferal",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 781 },
                    kind    = "path",
                    note    = "After defeating the ^Dragons of Nightmare^, go back the way you came and return to ^Core of the Nightmare^.",
                    minNote = "Back to Core hub",
                    points  = {
                        { 0.357, 0.513 },
                        { 0.305, 0.690 },
                        { 0.277, 0.795 },
                    },
                },
                {
                    when    = { mapID = 778 },
                    kind    = "path",
                    note    = "After returning to the central hub, continue clockwise through the next portal to reach ^Mulgore^.",
                    minNote = "Mulgore Portal",
                    points  = {
                        { 0.649, 0.372 },
                        { 0.601, 0.453 },
                        { 0.610, 0.501 },
                        { 0.691, 0.565 },
                    },
                },
                {
                    when    = { mapID = 779 },
                    kind    = "path",
                    note    = "Once inside ^Mulgore^, follow the path around, and clear the trash on your way to ^Elerethe Renferal^.",
                    minNote = "Trash then Elerethe",
                    points  = {
                        { 0.881, 0.877 },
                        { 0.849, 0.948 },
                        { 0.732, 0.940 },
                        { 0.616, 0.745 },
                        { 0.536, 0.362 },
                        { 0.347, 0.576 },
                    },
                },
            },
        },

        {
            step      = 5,
            priority  = 5,
            bossIndex = 2,
            title     = "Il'gynoth, Heart of Corruption",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 779 },
                    kind    = "path",
                    note    = "After defeating ^Elerethe^, backtrack to the portal and return to ^Core of the Nightmare^. You can jump off the ledge for a shortcut.",
                    minNote = "Jump off and die",
                    points  = {
                        { 0.353, 0.660 },
                        { 0.395, 0.753 },
                        { 0.490, 0.733 },
                        { 0.807, 0.945 },
                        { 0.879, 0.875 },
                    },
                },
                {
                    when    = { mapID = 778 },
                    kind    = "path",
                    note    = "When you're back in the central hub, take the final portal towards ^Un'Goro Crater^.",
                    minNote = "Un'Goro Crater Portal",
                    points  = {
                        { 0.588, 0.520 },
                        { 0.583, 0.646 },
                    },
                },
                {
                    when    = { mapID = 780 },
                    kind    = "path",
                    note    = "When you reach ^Un'Goro Crater^, follow the linear path to the back and kill ^Il'gynoth^.",
                    minNote = "Path to Il'gynoth",
                    points  = {
                        { 0.654, 0.973 },
                        { 0.557, 0.760 },
                        { 0.498, 0.520 },
                    },
                },
            },
        },

        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Cenarius",
            requires  = { 2, 3, 4, 5 },
            segments  = {
                {
                    when    = { mapID = 780 },
                    kind    = "path",
                    note    = "After killing ^Il'gynoth^, return back the way you came, through the portal to ^Core of the Nightmare^.",
                    minNote = "Back to Core hub",
                    points  = {
                        { 0.418, 0.400 },
                        { 0.567, 0.782 },
                        { 0.631, 0.916 },
                    },
                },
                {
                    when    = { mapID = 778 },
                    kind    = "path",
                    note    = "After returning to the central hub, approach the middle of the room and interact with the ^Nightmare Iris^ to reach ^Moonglade^.",
                    minNote = "Click Nightmare Iris",
                    points  = {
                        { 0.584, 0.645 },
                        { 0.586, 0.493 },
                    },
                },
                {
                    when    = { mapID = 787 },
                    kind    = "path",
                    note    = "Once inside ^Moonglade^, work your way down to ^Cenarius^ and kill him.",
                    minNote = "Down to Cenarius",
                    points  = {
                        { 0.360, 0.840 },
                        { 0.471, 0.407 },
                        { 0.574, 0.354 },
                    },
                },
            },
        },

        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Xavius",
            requires  = { 6 },
            segments  = {
                {
                    when    = { mapID = 787 },
                    kind    = "path",
                    note    = "After killing ^Cenarius^, jump into the portal behind him to reach the ^Rift of Aln^.",
                    minNote = "Portal behind Cenarius",
                    points  = {
                        { 0.627, 0.339 },
                        { 0.685, 0.363 },
                    },
                },
                {
                    when    = { mapID = 788 },
                    kind    = "path",
                    note    = "After landing in ^Rift of Aln^, start killing trash. They will continue coming in waves until finally, you will meet ^Xavius^.",
                    minNote = "Trash then Xavius",
                    points  = {
                        { 0.374, 0.770 },
                        { 0.467, 0.528 },
                    },
                },
            },
        },
    },

    skipToBoss = "Cenarius",


    skipRoute = {

        -- 1. Nythendra (same as standard run).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Nythendra",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 777 },
                    kind    = "path",
                    note    = "After zoning in, proceed forward and clear the slimes to begin the encounter with ^Nythendra^.",
                    minNote = "Trash then Nythendra",
                    points  = {
                        { 0.446, 0.570 },
                        { 0.526, 0.523 },
                    },
                },
            },
        },

        -- 2. Cenarius via the Nightmare Iris, used early after Nythendra
        --    (skips Il'gynoth, Elerethe, Ursoc, Dragons of Nightmare).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 6,
            title     = "Cenarius",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 777 },
                    kind    = "path",
                    note    = "After defeating ^Nythendra^, follow the path up and around towards the map exit labeled ^Core of the Nightmare^.",
                    minNote = "Follow Path Ahead",
                    points  = {
                        { 0.562, 0.460 },
                        { 0.698, 0.377 },
                        { 0.567, 0.228 },
                        { 0.406, 0.328 },
                        { 0.356, 0.513 },
                        { 0.341, 0.773 },
                    },
                },
                {
                    when    = { mapID = 778, subZone = "Clutch of Corruption" },
                    kind    = "path",
                    note    = "Work your way up to ^Malfurion Stormrage^ and talk to him to open the ^Nightmare Iris^. Interact with it to skip ahead to ^Cenarius^.",
                    minNote = "Talk to Malfurion",
                    points  = {
                        { 0.288, 0.818 },
                        { 0.222, 0.743 },
                        { 0.233, 0.652 },
                        { 0.284, 0.591 },
                        { 0.373, 0.550 },
                        { 0.439, 0.533 },
                    },
                },
                {
                    when     = { mapID = 778, subZone = "Core of the Nightmare" },
                    kind     = "poi",
                    minNote  = "Talk to Malfurion",
                    mapLabel = "Talk to Malfurion",
                    points   = {
                        { 0.561, 0.485 },
                    },
                },
                {
                    when    = { mapID = 787 },
                    kind    = "path",
                    note    = "Once inside ^Moonglade^, work your way down to ^Cenarius^ and kill him.",
                    minNote = "Path to Cenarius",
                    points  = {
                        { 0.360, 0.840 },
                        { 0.471, 0.407 },
                        { 0.574, 0.354 },
                    },
                },
            },
        },

        -- 3. Xavius (same as standard run).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 7,
            title     = "Xavius",
            requires  = { 6 },
            segments  = {
                {
                    when    = { mapID = 787 },
                    kind    = "path",
                    note    = "After killing ^Cenarius^, jump into the portal behind him to reach the ^Rift of Aln^.",
                    minNote = "Jump into Portal",
                    points  = {
                        { 0.627, 0.339 },
                        { 0.685, 0.363 },
                    },
                },
                {
                    when    = { mapID = 788 },
                    kind    = "path",
                    note    = "After landing in ^Rift of Aln^, start killing trash. They will continue coming in waves until finally, you will meet ^Xavius^.",
                    minNote = "Trash then Xavius",
                    points  = {
                        { 0.374, 0.770 },
                        { 0.467, 0.528 },
                    },
                },
            },
        },

    },
}
