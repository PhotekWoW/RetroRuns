-------------------------------------------------------------------------------
-- RetroRuns Data -- Tomb of Sargeras
-- Legion, Patch 7.2.5  |  instanceID: 1676  |  journalInstanceID: 875
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1676] = {
    instanceID        = 1676,
    journalInstanceID = 875,
    name              = "Tomb of Sargeras",
    expansion         = "Legion",
    patch             = "7.2.5",

    -- Entrance is in Broken Shore (mapID 646), at the portal in the
    -- southern part of the zone. Coords (64.5, 20.9) are the actual
    -- instance portal, in-game verified.
    entrance = {
        mapID   = 646,
        x       = 0.645,
        y       = 0.209,
        subZone = "The Tomb of Sargeras",
    },

    -- Goroth, Demonic Inquisition, and Harjatan all share mapID 850,
    -- with finer-grained sub-zones "The Breach", "Chamber of the
    -- Moon", and "Conclave of Torment" respectively.
    --
    -- mapID 855 hosts the FA->KJ slime corridor; its sub-zone label
    -- is "Chamber of the Avatar" (shared with mapID 854, the prior
    -- Fallen Avatar arena).
    maps = {
        [850] = "Chamber of the Moon",
        [851] = "The Abyssal Throne",
        [852] = "Terrace of the Moon",
        [853] = "The Guardian's Sanctum",
        [854] = "Chamber of the Avatar",
        [855] = "Felstorm's Breach",
        [856] = "The Twisting Nether",
    },

    tierSets = {
        labels       = { "Tomb of Sargeras" },
        tokenSources = {},
    },

    skipQuests = {
        normal = 47725,
        heroic = 47726,
        mythic = 47727,
    },

    -- Surfaced to players via the Skips window's per-row info button.
    skipTrigger = {
        questName = "Tomb of Sargeras: Aegwynn's Path",
        details   = "After killing ^Goroth^, the door behind ^Image of Aegwynn^ opens, allowing you to skip to ^Maiden of Vigilance^.",
    },

    -- Glory meta-achievement for this raid. Completing all 9 per-boss
    -- achievements below awards the Micronax Controller battle pet
    -- and the "the Tomb Raider" character title.
    gloryMeta = {
        id   = 11763,
        name = "Glory of the Tomb Raider",
        rewardItemID       = 101426,
        rewardMountSpellID = 249870,
        rewardName         = "Micronax Controller",
        rewardKind         = "pet",
        rewardTitle        = "the Tomb Raider",
    },

    bosses = {
        {
            index              = 1,
            name               = "Goroth",
            journalEncounterID = 1862,
            aliases            = {},
            achievements       = {
                { id = 11724, name = "Fel Turkey!", meta = true, soloable = "yes" },
            },
            loot = {
                -- Cloak of Stifling Brimstone has a single appearance
                -- across all four difficulties. Same pattern as Crucible
                -- of Storms' Trident of Deep Ocean.
                { id = 146984, slot = "Back",     name = "Cloak of Stifling Brimstone",     sources = { [17]=86903, [14]=86903, [15]=86903, [16]=86903 } },
                { id = 147027, slot = "Chest",    name = "Spirebreaker Harness",            sources = { [17]=86599, [14]=86600, [15]=86601, [16]=86602 } },
                { id = 146986, slot = "Feet",     name = "Emberscatter Treads",             sources = { [17]=86739, [14]=86740, [15]=86741, [16]=86742 } },
                { id = 147065, slot = "Legs",     name = "Lava-Slough Legguards",           sources = { [17]=86499, [14]=86500, [15]=86501, [16]=86502 } },
                { id = 146992, slot = "Legs",     name = "Legwraps of Fused Loathing",      sources = { [17]=86751, [14]=86752, [15]=86753, [16]=86754 } },
                { id = 147069, slot = "Shoulder", name = "Shoulderplates of Crackling Flame", sources = { [17]=86635, [14]=86636, [15]=86637, [16]=86638 } },
                { id = 147055, slot = "Waist",    name = "Belt of Screaming Slag",          sources = { [17]=86571, [14]=86572, [15]=86573, [16]=86574 } },
                { id = 147039, slot = "Waist",    name = "Cinch of Sizzling Flesh",         sources = { [17]=86695, [14]=86696, [15]=86697, [16]=86698 } },
                { id = 147057, slot = "Wrist",    name = "Pain-Singed Armguards",           sources = { [17]=86575, [14]=86576, [15]=86577, [16]=86578 } },
            },
        },
        {
            index              = 2,
            name               = "Demonic Inquisition",
            journalEncounterID = 1867,
            aliases            = {},
            achievements       = {
                { id = 11696, name = "Grin and Bear It", meta = true, soloable = "yes" },
            },
            loot = {
                -- Tier 20 Head (one per class).
                { id = 147147, slot = "Head",     name = "Crown of the Arcane Tempest",     sources = { [17]=86207, [14]=86208, [15]=86209, [16]=86210 }, classes = { 8 } },
                { id = 147130, slot = "Head",     name = "Demonbane Faceguard",             sources = { [17]=86141, [14]=86142, [15]=86143, [16]=86144 }, classes = { 12 } },
                { id = 147183, slot = "Head",     name = "Diabolic Helm",                   sources = { [17]=86351, [14]=86352, [15]=86353, [16]=86354 }, classes = { 9 } },
                { id = 147172, slot = "Head",     name = "Fanged Slayer's Helm",            sources = { [17]=86307, [14]=86308, [15]=86309, [16]=86310 }, classes = { 4 } },
                { id = 147124, slot = "Head",     name = "Gravewarden Visage",              sources = { [17]=86117, [14]=86118, [15]=86119, [16]=86120 }, classes = { 6 } },
                { id = 147178, slot = "Head",     name = "Helmet of the Skybreaker",        sources = { [17]=86331, [14]=86332, [15]=86333, [16]=86334 }, classes = { 7 } },
                { id = 147165, slot = "Head",     name = "Hood of Blind Absolution",        sources = { [17]=86279, [14]=86280, [15]=86281, [16]=86282 }, classes = { 5 } },
                { id = 147160, slot = "Head",     name = "Radiant Lightbringer Crown",      sources = { [17]=86259, [14]=86260, [15]=86261, [16]=86262 }, classes = { 2 } },
                { id = 147136, slot = "Head",     name = "Stormheart Headdress",            sources = { [17]=86165, [14]=86166, [15]=86167, [16]=86168 }, classes = { 11 } },
                { id = 147190, slot = "Head",     name = "Titanic Onslaught Greathelm",     sources = { [17]=86379, [14]=86380, [15]=86381, [16]=86382 }, classes = { 1 } },
                { id = 147142, slot = "Head",     name = "Wildstalker Helmet",              sources = { [17]=86187, [14]=86188, [15]=86189, [16]=86190 }, classes = { 3 } },
                { id = 147154, slot = "Head",     name = "Xuen's Helm",                     sources = { [17]=86235, [14]=86236, [15]=86237, [16]=86238 }, classes = { 10 } },
                { id = 147035, slot = "Legs",     name = "Bonespur Studded Legwraps",       sources = { [17]=86535, [14]=86536, [15]=86537, [16]=86538 } },
                { id = 147051, slot = "Legs",     name = "Flesh-Raking Leggings",           sources = { [17]=86563, [14]=86564, [15]=86565, [16]=86566 } },
                { id = 146996, slot = "Shoulder", name = "Mantle of Broken Spirits",        sources = { [17]=86663, [14]=86664, [15]=86665, [16]=86666 } },
                { id = 147053, slot = "Shoulder", name = "Pauldrons of the Gibbering Eye", sources = { [17]=86567, [14]=86568, [15]=86569, [16]=86570 } },
                { id = 146998, slot = "Waist",    name = "Braided Torture Lash",            sources = { [17]=86591, [14]=86592, [15]=86593, [16]=86594 } },
                { id = 147073, slot = "Wrist",    name = "Bonemeal-Crusted Armplates",      sources = { [17]=86511, [14]=86512, [15]=86513, [16]=86514 } },
                { id = 147041, slot = "Wrist",    name = "Sinew-Stitched Wristguards",      sources = { [17]=86699, [14]=86700, [15]=86701, [16]=86702 } },
            },
        },
        {
            index              = 3,
            name               = "Harjatan",
            journalEncounterID = 1856,
            aliases            = {},
            achievements       = {
                { id = 11699, name = "Grand Fin-ale", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 147043, slot = "Chest",    name = "Hauberk of Frozen Mist",          sources = { [17]=86703, [14]=86704, [15]=86705, [16]=86706 } },
                { id = 146994, slot = "Chest",    name = "Robe of Aqueous Command",         sources = { [17]=86587, [14]=86588, [15]=86589, [16]=86590 } },
                { id = 147067, slot = "Chest",    name = "Wave-Hammered Breastplate",       sources = { [17]=86631, [14]=86632, [15]=86633, [16]=86634 } },
                { id = 147029, slot = "Feet",     name = "Glacier Walkers",                 sources = { [17]=86519, [14]=86520, [15]=86521, [16]=86522 } },
                { id = 147045, slot = "Feet",     name = "Insulated Finpads",               sources = { [17]=86707, [14]=86708, [15]=86709, [16]=86710 } },
                -- Tier 20 Hands (one per class).
                { id = 147146, slot = "Hands",    name = "Gloves of the Arcane Tempest",    sources = { [17]=86203, [14]=86204, [15]=86205, [16]=86206 }, classes = { 8 } },
                { id = 147129, slot = "Hands",    name = "Demonbane Gauntlets",             sources = { [17]=86137, [14]=86138, [15]=86139, [16]=86140 }, classes = { 12 } },
                { id = 147182, slot = "Hands",    name = "Diabolic Gloves",                 sources = { [17]=86347, [14]=86348, [15]=86349, [16]=86350 }, classes = { 9 } },
                { id = 147171, slot = "Hands",    name = "Fanged Slayer's Handguards",      sources = { [17]=86303, [14]=86304, [15]=86305, [16]=86306 }, classes = { 4 } },
                { id = 147123, slot = "Hands",    name = "Gravewarden Handguards",          sources = { [17]=86113, [14]=86114, [15]=86115, [16]=86116 }, classes = { 6 } },
                { id = 147177, slot = "Hands",    name = "Grips of the Skybreaker",         sources = { [17]=86327, [14]=86328, [15]=86329, [16]=86330 }, classes = { 7 } },
                { id = 147164, slot = "Hands",    name = "Gloves of Blind Absolution",      sources = { [17]=86275, [14]=86276, [15]=86277, [16]=86278 }, classes = { 5 } },
                { id = 147159, slot = "Hands",    name = "Radiant Lightbringer Gauntlets",  sources = { [17]=86255, [14]=86256, [15]=86257, [16]=86258 }, classes = { 2 } },
                { id = 147135, slot = "Hands",    name = "Stormheart Gloves",               sources = { [17]=86161, [14]=86162, [15]=86163, [16]=86164 }, classes = { 11 } },
                { id = 147189, slot = "Hands",    name = "Titanic Onslaught Handguards",    sources = { [17]=86375, [14]=86376, [15]=86377, [16]=86378 }, classes = { 1 } },
                { id = 147141, slot = "Hands",    name = "Wildstalker Gauntlets",           sources = { [17]=86183, [14]=86184, [15]=86185, [16]=86186 }, classes = { 3 } },
                { id = 147153, slot = "Hands",    name = "Xuen's Gauntlets",                sources = { [17]=86231, [14]=86232, [15]=86233, [16]=86234 }, classes = { 10 } },
                { id = 147037, slot = "Shoulder", name = "Dripping Arcfin Shoulderpads",    sources = { [17]=86607, [14]=86608, [15]=86609, [16]=86610 } },
                { id = 147071, slot = "Waist",    name = "Shiversleet Waistguard",          sources = { [17]=86639, [14]=86640, [15]=86641, [16]=86642 } },
                { id = 147000, slot = "Wrist",    name = "Ravenous Devotee's Bracelets",    sources = { [17]=86763, [14]=86764, [15]=86765, [16]=86766 } },
            },
        },
        {
            index              = 4,
            name               = "Sisters of the Moon",
            journalEncounterID = 1903,
            aliases            = { "Sisters" },
            achievements       = {
                { id = 11773, name = "Wax On, Wax Off", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 147068, slot = "Chest",    name = "Cuirass of Blinding Dawn",        sources = { [17]=86779, [14]=86780, [15]=86781, [16]=86782 } },
                { id = 146987, slot = "Feet",     name = "Slippers of Enduring Vigilance",  sources = { [17]=86647, [14]=86648, [15]=86649, [16]=86650 } },
                { id = 147061, slot = "Hands",    name = "Dusk-Crusher Handguards",         sources = { [17]=86623, [14]=86624, [15]=86625, [16]=86626 } },
                { id = 147031, slot = "Hands",    name = "Moonfire Stranglers",             sources = { [17]=86531, [14]=86532, [15]=86533, [16]=86534 } },
                { id = 147033, slot = "Head",     name = "Lunar-Wrath Headgear",            sources = { [17]=86687, [14]=86688, [15]=86689, [16]=86690 } },
                { id = 147054, slot = "Shoulder", name = "Mantle of Waning Radiance",       sources = { [17]=86723, [14]=86724, [15]=86725, [16]=86726 } },
                { id = 146997, slot = "Shoulder", name = "Shoulderpads of Whispering Twilight", sources = { [17]=86755, [14]=86756, [15]=86757, [16]=86758 } },
                { id = 147056, slot = "Waist",    name = "Waistguard of Interminable Unity", sources = { [17]=86727, [14]=86728, [15]=86729, [16]=86730 } },
            },
        },
        {
            index              = 5,
            name               = "Mistress Sassz'ine",
            journalEncounterID = 1861,
            aliases            = { "Sassz'ine" },
            achievements       = {
                { id = 11676, name = "Five Course Seafood Buffet", meta = true, soloable = "kinda" },
            },
            specialLoot = {
                { id = 143643, kind = "mount", name = "Abyss Worm" },
            },
            loot = {
                -- Shroud of the Drowned Adherent is a binary single-source
                -- item (see Goroth's Cloak of Stifling Brimstone above for
                -- the same pattern).
                { id = 146985, slot = "Back",     name = "Shroud of the Drowned Adherent",  sources = { [17]=86904, [14]=86904, [15]=86904, [16]=86904 } },
                { id = 147028, slot = "Chest",    name = "Hide of the Abyssal Behemoth",    sources = { [17]=86675, [14]=86676, [15]=86677, [16]=86678 } },
                { id = 147059, slot = "Feet",     name = "Iron Ballast Sabatons",           sources = { [17]=86767, [14]=86768, [15]=86769, [16]=86770 } },
                { id = 147049, slot = "Head",     name = "Azure Squallshaper's Helm",       sources = { [17]=86715, [14]=86716, [15]=86717, [16]=86718 } },
                { id = 146990, slot = "Head",     name = "Hundred-Fathom Veil",             sources = { [17]=86655, [14]=86656, [15]=86657, [16]=86658 } },
                -- Tier 20 Legs (one per class).
                { id = 147148, slot = "Legs",     name = "Leggings of the Arcane Tempest",  sources = { [17]=86211, [14]=86212, [15]=86213, [16]=86214 }, classes = { 8 } },
                { id = 147131, slot = "Legs",     name = "Demonbane Leggings",              sources = { [17]=86145, [14]=86146, [15]=86147, [16]=86148 }, classes = { 12 } },
                { id = 147184, slot = "Legs",     name = "Diabolic Leggings",               sources = { [17]=86355, [14]=86356, [15]=86357, [16]=86358 }, classes = { 9 } },
                { id = 147173, slot = "Legs",     name = "Fanged Slayer's Legguards",       sources = { [17]=86311, [14]=86312, [15]=86313, [16]=86314 }, classes = { 4 } },
                { id = 147125, slot = "Legs",     name = "Gravewarden Legplates",           sources = { [17]=86121, [14]=86122, [15]=86123, [16]=86124 }, classes = { 6 } },
                { id = 147179, slot = "Legs",     name = "Legguards of the Skybreaker",     sources = { [17]=86335, [14]=86336, [15]=86337, [16]=86338 }, classes = { 7 } },
                { id = 147166, slot = "Legs",     name = "Leggings of Blind Absolution",    sources = { [17]=86283, [14]=86284, [15]=86285, [16]=86286 }, classes = { 5 } },
                { id = 147161, slot = "Legs",     name = "Radiant Lightbringer Greaves",    sources = { [17]=86263, [14]=86264, [15]=86265, [16]=86266 }, classes = { 2 } },
                { id = 147137, slot = "Legs",     name = "Stormheart Legguards",            sources = { [17]=86169, [14]=86170, [15]=86171, [16]=86172 }, classes = { 11 } },
                { id = 147191, slot = "Legs",     name = "Titanic Onslaught Greaves",       sources = { [17]=86383, [14]=86384, [15]=86385, [16]=86386 }, classes = { 1 } },
                { id = 147143, slot = "Legs",     name = "Wildstalker Leggings",            sources = { [17]=86191, [14]=86192, [15]=86193, [16]=86194 }, classes = { 3 } },
                { id = 147155, slot = "Legs",     name = "Xuen's Legguards",                sources = { [17]=86239, [14]=86240, [15]=86241, [16]=86242 }, classes = { 10 } },
            },
        },
        {
            index              = 6,
            name               = "The Desolate Host",
            journalEncounterID = 1896,
            aliases            = { "Desolate Host" },
            achievements       = {
                { id = 11674, name = "Great Soul, Great Purpose", meta = true, soloable = "kinda" },
            },
            loot = {
                -- Tier 20 Back (one per class).
                { id = 147145, slot = "Back",     name = "Drape of the Arcane Tempest",     sources = { [17]=86199, [14]=86200, [15]=86201, [16]=86202 }, classes = { 8 } },
                { id = 147128, slot = "Back",     name = "Demonbane Shroud",                sources = { [17]=86133, [14]=86134, [15]=86135, [16]=86136 }, classes = { 12 } },
                { id = 147181, slot = "Back",     name = "Diabolic Shroud",                 sources = { [17]=86343, [14]=86344, [15]=86345, [16]=86346 }, classes = { 9 } },
                { id = 147170, slot = "Back",     name = "Fanged Slayer's Shroud",          sources = { [17]=86299, [14]=86300, [15]=86301, [16]=86302 }, classes = { 4 } },
                { id = 147122, slot = "Back",     name = "Gravewarden Cloak",               sources = { [17]=86109, [14]=86110, [15]=86111, [16]=86112 }, classes = { 6 } },
                { id = 147176, slot = "Back",     name = "Drape of the Skybreaker",         sources = { [17]=86323, [14]=86324, [15]=86325, [16]=86326 }, classes = { 7 } },
                { id = 147163, slot = "Back",     name = "Shawl of Blind Absolution",       sources = { [17]=86271, [14]=86272, [15]=86273, [16]=86274 }, classes = { 5 } },
                { id = 147158, slot = "Back",     name = "Radiant Lightbringer Cape",       sources = { [17]=86251, [14]=86252, [15]=86253, [16]=86254 }, classes = { 2 } },
                { id = 147134, slot = "Back",     name = "Stormheart Drape",                sources = { [17]=86157, [14]=86158, [15]=86159, [16]=86160 }, classes = { 11 } },
                { id = 147188, slot = "Back",     name = "Titanic Onslaught Cloak",         sources = { [17]=86371, [14]=86372, [15]=86373, [16]=86374 }, classes = { 1 } },
                { id = 147140, slot = "Back",     name = "Wildstalker Cape",                sources = { [17]=86181, [14]=86401, [15]=86402, [16]=86182 }, classes = { 3 } },
                { id = 147152, slot = "Back",     name = "Xuen's Cloak",                    sources = { [17]=86227, [14]=86228, [15]=86229, [16]=86230 }, classes = { 10 } },
                { id = 146995, slot = "Chest",    name = "Soul Queen's Ceremonial Robes",   sources = { [17]=86659, [14]=86660, [15]=86661, [16]=86662 } },
                { id = 147047, slot = "Hands",    name = "Gauntlets of Spiteful Haunting",  sources = { [17]=86555, [14]=86556, [15]=86557, [16]=86558 } },
                { id = 147063, slot = "Head",     name = "Armet of the Rotten Mind",        sources = { [17]=86495, [14]=86496, [15]=86497, [16]=86498 } },
                { id = 147070, slot = "Shoulder", name = "Grave-Dredged Pauldrons",         sources = { [17]=86503, [14]=86504, [15]=86505, [16]=86506 } },
                { id = 147040, slot = "Waist",    name = "Etched Bone Waistband",           sources = { [17]=86539, [14]=86540, [15]=86541, [16]=86542 } },
            },
        },
        {
            index              = 7,
            name               = "Maiden of Vigilance",
            journalEncounterID = 1897,
            aliases            = { "Maiden" },
            achievements       = {
                { id = 11675, name = "Sky Walker", meta = true, soloable = "kinda" },
            },
            loot = {
                -- Tier 20 Chest (one per class). Many third-party
                -- guides attribute the tier chest pieces to Kil'jaeden,
                -- but in-game data shows them dropping from Maiden of
                -- Vigilance.
                { id = 147149, slot = "Chest",    name = "Robes of the Arcane Tempest",     sources = { [17]=86215, [14]=86216, [15]=86217, [16]=86218 }, classes = { 8 } },
                { id = 147127, slot = "Chest",    name = "Demonbane Harness",               sources = { [17]=86129, [14]=86130, [15]=86131, [16]=86132 }, classes = { 12 } },
                { id = 147185, slot = "Chest",    name = "Diabolic Robe",                   sources = { [17]=86359, [14]=86360, [15]=86361, [16]=86362 }, classes = { 9 } },
                { id = 147169, slot = "Chest",    name = "Fanged Slayer's Chestguard",      sources = { [17]=86295, [14]=86296, [15]=86297, [16]=86298 }, classes = { 4 } },
                { id = 147121, slot = "Chest",    name = "Gravewarden Chestplate",          sources = { [17]=86105, [14]=86106, [15]=86107, [16]=86108 }, classes = { 6 } },
                { id = 147175, slot = "Chest",    name = "Harness of the Skybreaker",       sources = { [17]=86319, [14]=86320, [15]=86321, [16]=86322 }, classes = { 7 } },
                { id = 147167, slot = "Chest",    name = "Robes of Blind Absolution",       sources = { [17]=86287, [14]=86288, [15]=86289, [16]=86290 }, classes = { 5 } },
                { id = 147157, slot = "Chest",    name = "Radiant Lightbringer Breastplate", sources = { [17]=86247, [14]=86248, [15]=86249, [16]=86250 }, classes = { 2 } },
                { id = 147133, slot = "Chest",    name = "Stormheart Tunic",                sources = { [17]=86153, [14]=86154, [15]=86155, [16]=86156 }, classes = { 11 } },
                { id = 147187, slot = "Chest",    name = "Titanic Onslaught Breastplate",   sources = { [17]=86367, [14]=86368, [15]=86369, [16]=86370 }, classes = { 1 } },
                { id = 147139, slot = "Chest",    name = "Wildstalker Chestguard",          sources = { [17]=86177, [14]=86178, [15]=86179, [16]=86180 }, classes = { 3 } },
                { id = 147151, slot = "Chest",    name = "Xuen's Tunic",                    sources = { [17]=86223, [14]=86224, [15]=86225, [16]=86226 }, classes = { 10 } },
                { id = 147060, slot = "Feet",     name = "Steadfast Purifier's Warboots",   sources = { [17]=86619, [14]=86620, [15]=86621, [16]=86622 } },
                { id = 147032, slot = "Hands",    name = "Gloves of Wayward Compulsions",   sources = { [17]=86683, [14]=86684, [15]=86685, [16]=86686 } },
                { id = 147050, slot = "Head",     name = "Crown of Discarded Hope",         sources = { [17]=86559, [14]=86560, [15]=86561, [16]=86562 } },
                { id = 146993, slot = "Legs",     name = "Leggings of Divine Portents",     sources = { [17]=86583, [14]=86584, [15]=86585, [16]=86586 } },
                { id = 146999, slot = "Waist",    name = "Strife-Riddled Cinch",            sources = { [17]=86759, [14]=86760, [15]=86761, [16]=86762 } },
                -- Hammer of Vigilance: 1H mace cosmetic. Drops on all
                -- 4 difficulties from Maiden but is not exposed by the
                -- Encounter Journal. One sourceID across all four
                -- difficulties (binary shape). Found via GetSourceInfo
                -- brute-force scan.
                { id = 151524, slot = "Weapon",   name = "Hammer of Vigilance",             sources = { [17]=89458, [14]=89458, [15]=89458, [16]=89458 } },
            },
        },
        {
            index              = 8,
            name               = "Fallen Avatar",
            journalEncounterID = 1873,
            aliases            = { "Avatar" },
            achievements       = {
                { id = 11683, name = "Bingo!", meta = true, soloable = "yes" },
            },
            loot = {
                -- Cape of Mindless Fury is a binary single-source item
                -- (see Goroth's Cloak of Stifling Brimstone above for the
                -- same pattern).
                { id = 147193, slot = "Back",     name = "Cape of Mindless Fury",           sources = { [17]=86905, [14]=86905, [15]=86905, [16]=86905 } },
                { id = 147030, slot = "Feet",     name = "Felscape Pathfinders",            sources = { [17]=86679, [14]=86680, [15]=86681, [16]=86682 } },
                { id = 147062, slot = "Hands",    name = "Groundshatter Gauntlets",         sources = { [17]=86771, [14]=86772, [15]=86773, [16]=86774 } },
                { id = 146991, slot = "Head",     name = "Blackened Mask of Disgrace",      sources = { [17]=86747, [14]=86748, [15]=86749, [16]=86750 } },
                { id = 147052, slot = "Legs",     name = "Legguards of Siphoned Power",     sources = { [17]=86719, [14]=86720, [15]=86721, [16]=86722 } },
                -- Tier 20 Shoulder (one per class).
                { id = 147150, slot = "Shoulder", name = "Mantle of the Arcane Tempest",    sources = { [17]=86219, [14]=86220, [15]=86221, [16]=86222 }, classes = { 8 } },
                { id = 147132, slot = "Shoulder", name = "Demonbane Shoulderpads",          sources = { [17]=86149, [14]=86150, [15]=86151, [16]=86152 }, classes = { 12 } },
                { id = 147186, slot = "Shoulder", name = "Diabolic Mantle",                 sources = { [17]=86363, [14]=86364, [15]=86365, [16]=86366 }, classes = { 9 } },
                { id = 147174, slot = "Shoulder", name = "Fanged Slayer's Shoulderpads",    sources = { [17]=86315, [14]=86316, [15]=86317, [16]=86318 }, classes = { 4 } },
                { id = 147126, slot = "Shoulder", name = "Gravewarden Pauldrons",           sources = { [17]=86125, [14]=86126, [15]=86127, [16]=86128 }, classes = { 6 } },
                { id = 147180, slot = "Shoulder", name = "Pauldrons of the Skybreaker",     sources = { [17]=86339, [14]=86340, [15]=86341, [16]=86342 }, classes = { 7 } },
                { id = 147168, slot = "Shoulder", name = "Mantle of Blind Absolution",      sources = { [17]=86291, [14]=86292, [15]=86293, [16]=86294 }, classes = { 5 } },
                { id = 147162, slot = "Shoulder", name = "Radiant Lightbringer Shoulderguards", sources = { [17]=86267, [14]=86268, [15]=86269, [16]=86270 }, classes = { 2 } },
                { id = 147138, slot = "Shoulder", name = "Stormheart Mantle",               sources = { [17]=86173, [14]=86174, [15]=86175, [16]=86176 }, classes = { 11 } },
                { id = 147192, slot = "Shoulder", name = "Titanic Onslaught Pauldrons",     sources = { [17]=86387, [14]=86388, [15]=86389, [16]=86390 }, classes = { 1 } },
                { id = 147144, slot = "Shoulder", name = "Wildstalker Spaulders",           sources = { [17]=86195, [14]=86196, [15]=86197, [16]=86198 }, classes = { 3 } },
                { id = 147156, slot = "Shoulder", name = "Xuen's Shoulderguards",           sources = { [17]=86243, [14]=86244, [15]=86245, [16]=86246 }, classes = { 10 } },
                { id = 147042, slot = "Wrist",    name = "Bracers of Rippling Darkness",    sources = { [17]=86543, [14]=86544, [15]=86545, [16]=86546 } },
                { id = 147001, slot = "Wrist",    name = "Oathbreaker's Cuffs",             sources = { [17]=86667, [14]=86668, [15]=86669, [16]=86670 } },
            },
        },
        {
            index              = 9,
            name               = "Kil'jaeden",
            journalEncounterID = 1898,
            aliases            = {},
            achievements       = {
                { id = 11770, name = "Dark Souls", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 147046, slot = "Feet",     name = "Star-Stalker Treads",             sources = { [17]=86551, [14]=86552, [15]=86553, [16]=86554 } },
                { id = 146988, slot = "Hands",    name = "Gloves of Furtive Oppression",    sources = { [17]=86743, [14]=86744, [15]=86745, [16]=86746 } },
                { id = 147048, slot = "Hands",    name = "Vicegrip of the Unrepentant",     sources = { [17]=86711, [14]=86712, [15]=86713, [16]=86714 } },
                { id = 147034, slot = "Head",     name = "Shadow-Scarred Headcover",        sources = { [17]=86603, [14]=86604, [15]=86605, [16]=86606 } },
                { id = 147066, slot = "Legs",     name = "Greaves of Impure Midnight",      sources = { [17]=86775, [14]=86776, [15]=86777, [16]=86778 } },
                { id = 147072, slot = "Waist",    name = "Soul-Render's Greatbelt",         sources = { [17]=86507, [14]=86508, [15]=86509, [16]=86510 } },
                { id = 147347, slot = "Waist",    name = "Waistguard of Profane Duplicity", sources = { [17]=86527, [14]=86528, [15]=86529, [16]=86530 } },
            },
        },
    },

    routing = {
        -- 1. Goroth
        -- Single segment on mapID 850 (sub-zone "The Breach", a
        -- finer-grained label than the maps[] wing name "Chamber of
        -- the Moon"). Straight-line approach from the entrance portal.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Goroth",
            requires  = {},
            segments  = {
                {
                    when   = { mapID = 850 },
                    kind    = "path",
                    note    = "After zoning in, proceed straight ahead to engage ^Goroth^.",
                    points  = {
                        { 0.450, 0.893 },
                        { 0.451, 0.604 },
                    },
                },
            },
        },

        -- 2. Demonic Inquisition
        -- Single segment on mapID 850 (same parent map as Goroth, but
        -- here the sub-zone is "Chamber of the Moon" vs "The Breach"
        -- for the Goroth approach -- mapID 850 spans multiple
        -- finer-grained sub-areas in the Gates of Hell wing). Path
        -- heads forward past trash NPCs and up the stairs.
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Demonic Inquisition",
            requires  = {},
            segments  = {
                {
                    when   = { mapID = 850 },
                    kind    = "path",
                    note    = "After defeating ^Goroth^, proceed straight ahead past the group of NPCs and go up the stairs to find ^Demonic Inquisition^.",
                    points  = {
                        { 0.450, 0.532 },
                        { 0.451, 0.447 },
                        { 0.489, 0.410 },
                        { 0.483, 0.359 },
                        { 0.450, 0.339 },
                        { 0.448, 0.195 },
                    },
                },
            },
        },

        -- 3. Harjatan
        -- Three segments:
        --   seg 1: poi -- click the Hammer of Khaz'goroth in the
        --          Demonic Inquisition room. Hammer sits directly
        --          under the boss icon so the map marker is
        --          suppressed (noMarker = true); the "Click Hammer"
        --          map label and travel-note text carry the
        --          instruction. Image of Aegwynn says a flavor line
        --          when the hammer is clicked, used as the dialog
        --          trigger so the segment progresses automatically
        --          when the click takes effect.
        --   seg 2: path west on mapID 850 (sub-zone "Conclave of
        --          Torment") to the map exit labeled "The Abyssal
        --          Throne" -- a hole the player jumps into.
        --   seg 3: path on mapID 851 (sub-zone "The Collapse") to
        --          Harjatan.
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Harjatan",
            requires  = {},
            segments  = {
                {
                    when            = { mapID = 850 },
                    kind            = "poi",
                    noMarker        = true,
                    mapLabel        = "Click Hammer",
                    mapLabelPos     = "middle",
                    completionCheck = true,
                    note    = "Click the ^Hammer of Khaz'goroth^ in the middle of this room after killing ^Demonic Inquisition^.",
                    triggeredBy = { dialog = { npc = "Image of Aegwynn", match = "shatters the bonds of fate" } },
                    points  = {
                        { 0.449, 0.195 },
                    },
                },
                {
                    when   = { mapID = 850 },
                    kind    = "path",
                    note    = "After clicking the ^Hammer^, proceed down the stairs towards the west side of the room and the map exit labeled ^The Abyssal Throne^.",
                    points  = {
                        { 0.449, 0.213 },
                        { 0.448, 0.340 },
                        { 0.424, 0.350 },
                        { 0.415, 0.381 },
                        { 0.424, 0.427 },
                        { 0.448, 0.458 },
                        { 0.446, 0.515 },
                        { 0.409, 0.569 },
                        { 0.388, 0.564 },
                    },
                },
                {
                    when   = { mapID = 851 },
                    kind    = "path",
                    note    = "After jumping in the hole, follow the path straight ahead to find ^Harjatan^.",
                    points  = {
                        { 0.146, 0.255 },
                        { 0.162, 0.292 },
                        { 0.206, 0.306 },
                        { 0.223, 0.391 },
                        { 0.292, 0.438 },
                        { 0.339, 0.534 },
                        { 0.433, 0.671 },
                    },
                },
            },
        },

        -- 4. Mistress Sassz'ine (bossIndex=5; routing-vs-EJ-order
        -- divergence is intentional). The canonical solo walk goes
        -- Harjatan -> Sassz'ine in the same wing (Gates of Hell
        -- extended into the abyssal area), with Sisters of the Moon
        -- and Desolate Host reached separately through a different
        -- wing (Wailing Halls). Boss data preserves EJ display order
        -- so the Boss Progress panel matches the in-game journal;
        -- routing uses walk order.
        {
            step      = 4,
            priority  = 4,
            bossIndex = 5,
            title     = "Mistress Sassz'ine",
            requires  = {},
            segments  = {
                {
                    when   = { mapID = 851 },
                    kind    = "path",
                    note    = "After killing ^Harjatan^, jump over the ledge to his left and land in the water. Follow the path through the tunnel and continue straight ahead to find ^Mistress Sassz'ine^.",
                    points  = {
                        { 0.433, 0.645 },
                        { 0.475, 0.570 },
                        { 0.494, 0.612 },
                        { 0.521, 0.692 },
                        { 0.582, 0.730 },
                        { 0.648, 0.679 },
                        { 0.734, 0.696 },
                        { 0.791, 0.726 },
                        { 0.811, 0.789 },
                        { 0.823, 0.822 },
                    },
                },
            },
        },

        -- 5. Sisters of the Moon (bossIndex=4; second routing-vs-EJ
        -- divergence). After Sassz'ine, click the Tidestone of
        -- Golganneth to trigger another Aegwynn line, then backtrack
        -- and head up through the Terrace of the Moon to reach Sisters.
        --   seg 1: poi -- click the Tidestone of Golganneth in
        --          Sassz'ine's room. Like the Hammer of Khaz'goroth
        --          for Harjatan, the Tidestone sits under the boss
        --          icon so the map marker is suppressed (noMarker =
        --          true); the "Click Tidestone" map label and
        --          travel-note text carry the instruction. An
        --          Aegwynn SAY event ("washes clean the darkness")
        --          fires the dialog trigger.
        --   seg 2: path on mapID 851 (sub-zone "The Abyssal Throne",
        --          the wing's maps[] label). Backtrack northwest past
        --          a giant statue and climb a long winding staircase
        --          to the wing's map exit labeled "Terrace of the Moon".
        --   seg 3: path on mapID 852 (sub-zone "Sunken Stair") from
        --          the top of the staircase, through a door, north
        --          to the Sisters of the Moon encounter.
        {
            step      = 5,
            priority  = 5,
            bossIndex = 4,
            title     = "Sisters of the Moon",
            requires  = {},
            segments  = {
                {
                    when            = { mapID = 851 },
                    kind            = "poi",
                    noMarker        = true,
                    mapLabel        = "Click Tidestone",
                    mapLabelPos     = "middle",
                    completionCheck = true,
                    note    = "Click the ^Tidestone of Golganneth^ after killing ^Mistress Sassz'ine^.",
                    triggeredBy = { dialog = { npc = "Image of Aegwynn", match = "washes clean the darkness" } },
                    points  = {
                        { 0.833, 0.824 },
                    },
                },
                {
                    when   = { mapID = 851 },
                    kind    = "path",
                    note    = "After clicking the ^Tidestone^, backtrack a bit and take a right towards the map exit labeled ^Terrace of the Moon^. You will pass a giant statue and begin climbing a long, winding staircase.",
                    points  = {
                        { 0.833, 0.824 },
                        { 0.815, 0.796 },
                        { 0.795, 0.728 },
                        { 0.742, 0.704 },
                        { 0.642, 0.675 },
                        { 0.633, 0.591 },
                        { 0.653, 0.521 },
                        { 0.686, 0.515 },
                        { 0.710, 0.486 },
                        { 0.711, 0.427 },
                        { 0.686, 0.391 },
                    },
                },
                {
                    when   = { mapID = 852 },
                    kind    = "path",
                    note    = "When you reach the top of the staircase, you will go through a door and continue north to reach ^Sisters of the Moon^. For the next few areas, avoid the purple circular areas on the ground as they will stun you.",
                    points  = {
                        { 0.576, 0.835 },
                        { 0.575, 0.886 },
                        { 0.597, 0.914 },
                        { 0.582, 0.945 },
                        { 0.533, 0.920 },
                        { 0.509, 0.847 },
                        { 0.524, 0.721 },
                        { 0.547, 0.642 },
                        { 0.504, 0.617 },
                    },
                },
            },
        },

        -- 6. The Desolate Host. Single segment on mapID 852
        -- (sub-zone "Terrace of the Moon", which is also this mapID's
        -- maps[] label). Path winds east then descends northwest to
        -- the Desolate Host arena. The hazard warning for purple-
        -- circle stun traps was moved upstream to Sisters of the
        -- Moon seg 3 so players read it before entering the
        -- affected areas rather than at the corridor's last segment.
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "The Desolate Host",
            requires  = {},
            segments  = {
                {
                    when   = { mapID = 852 },
                    kind    = "path",
                    note    = "After defeating ^Sisters of the Moon^, leave the boss room and take a left. Follow the winding path back to ^The Desolate Host^.",
                    points  = {
                        { 0.511, 0.605 },
                        { 0.506, 0.625 },
                        { 0.564, 0.637 },
                        { 0.594, 0.606 },
                        { 0.606, 0.555 },
                        { 0.614, 0.511 },
                        { 0.604, 0.475 },
                        { 0.514, 0.380 },
                        { 0.521, 0.337 },
                        { 0.574, 0.236 },
                    },
                },
            },
        },

        -- 7. Maiden of Vigilance. Four segments, including the
        -- canonical "jump-suicide-respawn" routing trick:
        --   seg 1: poi -- click the Tears of Elune in the Desolate
        --          Host room. Like Hammer and Tidestone, the Tears
        --          sit under the boss icon so the map marker is
        --          suppressed (noMarker = true); the "Click Tears"
        --          map label and travel-note text carry the
        --          instruction. An Aegwynn SAY event ("purify your
        --          hearts") fires the dialog trigger.
        --   seg 2: path on mapID 852 (sub-zone "Befouled Sanctum",
        --          another finer-grained sub-area within the Terrace
        --          of the Moon wing). After clicking Tears,
        --          jump off the edge to die -- the graveyard
        --          respawn drops the player back at the entrance
        --          area on mapID 850 / Chamber of the Moon. The
        --          player's death-and-respawn is the transition
        --          mechanic; there's no in-game teleport object.
        --   seg 3: path on mapID 850 (sub-zone "Chamber of the Moon")
        --          from the respawn position forward to a stairwell
        --          behind a group of NPCs.
        --   seg 4: path on mapID 853 (sub-zone "The Guardian's
        --          Sanctum"). Cross the room to engage Maiden.
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Maiden of Vigilance",
            requires  = {},
            segments  = {
                {
                    when            = { mapID = 852 },
                    kind            = "poi",
                    noMarker        = true,
                    mapLabel        = "Click Tears",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    note    = "Click the ^Tears of Elune^ in the middle of the room after killing ^The Desolate Host^.",
                    triggeredBy = { dialog = { npc = "Image of Aegwynn", match = "purify your hearts" } },
                    points  = {
                        { 0.591, 0.235 },
                    },
                },
                {
                    when         = { mapID = 852 },
                    kind         = "path",
                    endpointKind = "skull",
                    note    = "After clicking the ^Tears of Elune^, jump off the edge to die and respawn back in ^Chamber of the Moon^.",
                    points  = {
                        { 0.591, 0.235 },
                        { 0.601, 0.291 },
                    },
                },
                {
                    when   = { mapID = 850 },
                    kind    = "path",
                    note    = "After respawning in ^Chamber of the Moon^, proceed towards the group of NPCs and enter the descending stairwell behind them.",
                    points  = {
                        { 0.449, 0.605 },
                        { 0.450, 0.453 },
                    },
                },
                {
                    when   = { mapID = 853 },
                    kind    = "path",
                    note    = "When you reach the bottom of the stairwell, cross the room and engage ^Maiden of Vigilance^.",
                    points  = {
                        { 0.484, 0.863 },
                        { 0.500, 0.812 },
                        { 0.499, 0.543 },
                        { 0.418, 0.450 },
                        { 0.419, 0.335 },
                        { 0.474, 0.278 },
                    },
                },
            },
        },

        -- 8. Fallen Avatar. Two segments:
        --   seg 1: poi -- click the Teleportation Pad in Maiden's
        --          room (mapID 853 / The Guardian's Sanctum). The
        --          pad carries the player to mapID 854; the engine
        --          advances on the mapID change.
        --   seg 2: path on mapID 854 (sub-zone "Chamber of the
        --          Avatar"). Forward across the room, killing trash
        --          to open the door, then a dialog plays before the
        --          encounter is engageable.
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Fallen Avatar",
            requires  = {},
            segments  = {
                {
                    when            = { mapID = 853 },
                    kind            = "poi",
                    destination     = "Chamber of the Avatar",
                    noMarker        = true,
                    mapLabel        = "Click Teleporter",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    note        = "After killing ^Maiden of Vigilance^, click the nearby ^Teleportation Pad^ to be taken to ^Chamber of the Avatar^. Note: the pad will likely be under the boss corpse until she despawns, but you can still click it.",
                    points      = {
                        { 0.501, 0.297 },
                    },
                },
                {
                    when   = { mapID = 854 },
                    kind    = "path",
                    note    = "In the ^Chamber of the Avatar^, move forward and kill trash to open the door, then watch some dialog before engaging with ^Fallen Avatar^.",
                    points  = {
                        { 0.503, 0.731 },
                        { 0.501, 0.221 },
                    },
                },
            },
        },

        -- 9. Kil'jaeden. Two segments:
        --   seg 1: path on mapID 855 (sub-zone "Chamber of the
        --          Avatar" -- a transit corridor that shares its
        --          sub-zone label with mapID 854, the prior Fallen
        --          Avatar arena). Cross slime to a map exit portal
        --          labeled "The Twisting Nether" and step through.
        --   seg 2: path on mapID 856 (sub-zone "The Twisting
        --          Nether"). Long traverse from west to east,
        --          killing trash all the way to Kil'jaeden's
        --          encounter platform.
        {
            step      = 9,
            priority  = 9,
            bossIndex = 9,
            title     = "Kil'jaeden",
            requires  = {},
            segments  = {
                {
                    when   = { mapID = 855 },
                    kind    = "path",
                    note    = "After killing ^Fallen Avatar^, continue straight ahead across the slime to the map exit labeled ^The Twisting Nether^. Walk into the green swirly portal.",
                    points  = {
                        { 0.525, 0.301 },
                        { 0.532, 0.189 },
                    },
                },
                {
                    when   = { mapID = 856 },
                    kind    = "path",
                    note    = "After arriving in ^The Twisting Nether^, work your way down the path, killing trash all the way until you reach ^Kil'Jaeden^.",
                    points  = {
                        { 0.158, 0.468 },
                        { 0.394, 0.456 },
                        { 0.423, 0.376 },
                        { 0.499, 0.352 },
                        { 0.564, 0.348 },
                        { 0.626, 0.372 },
                        { 0.700, 0.425 },
                    },
                },
            },
        },
    },
}
