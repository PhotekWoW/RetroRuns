-------------------------------------------------------------------------------
-- RetroRuns Data -- Highmaul
-- Warlords of Draenor, Patch 6.0.3  |  instanceID: 1228  |  journalInstanceID: 477
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1228] = {
    instanceID        = 1228,
    journalInstanceID = 477,
    name              = "Highmaul",
    expansion         = "Warlords of Draenor",
    patch             = "6.0.3",

    exitNote = "None available",

    entrance = {
        mapID   = 550,
        x       = 0.3290,
        y       = 0.3830,
        subZone = "Highmaul",
    },

    maps = {
        [610] = "Highmaul",
        [611] = "Gladiator's Rest",
        [612] = "The Coliseum",
        [613] = "Chamber of Nullification",
        [614] = "Imperator's Rise",
        [615] = "Throne of the Imperator",
    },

    -- WoD-era raids have two separate boss loot tables: an LFR pool
    -- (unique appearances that drop ONLY at Raid Finder difficulty,
    -- e.g. Highmaul's Sootfur Garb set) and an N/H/M pool (the per-
    -- difficulty recolors that drop at Normal, Heroic, and Mythic).
    -- The two pools share no items. Items render with bucket shapes
    -- matching their pool: LFR-only items show "[ LFR ]", N/H/M items
    -- show "[ N | H | M ]" -- no spurious cross-pool sourceIDs.
    splitLootTables = true,

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    gloryMeta = {
        id   = 8985,
        name = "Glory of the Draenor Raider",
        rewardItemID       = 116383,
        rewardMountSpellID = 171436,
        rewardName         = "Gorestrider Gronnling",
    },

    bosses = {
        {
            index              = 1,
            name               = "Kargath Bladefist",
            journalEncounterID = 1128,
            aliases            = {},
            achievements       = {
                { id = 8948, name = "Flame On!", meta = true, soloable = "yes" },
            },
            specialLoot = {
                -- Illusion: Mark of the Shattered Hand. Weapon enchant
                -- illusion modeled on the WoD-era Garrison enchanter
                -- recipe of the same name.
                { id = 138807, kind = "illusion", name = "Illusion: Mark of the Shattered Hand", sourceID = 5331 },
            },
            loot = {
                { id = 113605, slot = "Back",             name = "Fireproof Greatcloak",            sources = { [14]=62379, [15]=66800, [16]=66801 } },
                { id = 116298, slot = "Back",             name = "Flamescarred Drape",              sources = { [17]=66837 } },
                { id = 113601, slot = "Chest",            name = "Chestguard of the Roaring Crowd", sources = { [14]=62373, [15]=62374, [16]=62375 } },
                { id = 116205, slot = "Feet",             name = "Firewalker's Treads",             sources = { [17]=66905 } },
                { id = 116003, slot = "Feet",             name = "Spectator's Sandals of Carnage",  sources = { [17]=66963 } },
                { id = 113595, slot = "Feet",             name = "Treads of Sand and Blood",        sources = { [14]=62364, [15]=62365, [16]=62366 } },
                { id = 113593, slot = "Hands",            name = "Grips of Vicious Mauling",        sources = { [14]=62361, [15]=62362, [16]=62363 } },
                { id = 113602, slot = "Hands",            name = "Throat-Ripper Gauntlets",         sources = { [14]=62376, [15]=62378, [16]=67307 } },
                { id = 113600, slot = "Head",             name = "Casque of the Iron Bomber",       sources = { [14]=62370, [15]=62372, [16]=67176 } },
                { id = 113596, slot = "Head",             name = "Vilebreath Mask",                 sources = { [14]=62367, [15]=62368, [16]=62369 } },
                { id = 113592, slot = "Held In Off-hand", name = "Bileslinger's Censer",            sources = { [14]=62358, [15]=62359, [16]=62360 } },
                { id = 116236, slot = "Shoulder",         name = "Iron Bomb Spaulders",             sources = { [17]=66956 } },
                { id = 116360, slot = "Weapon",           name = "Blade Dancer's Claws",            sources = { [17]=65211 } },
                { id = 113591, slot = "Weapon",           name = "The Bladefist",                   sources = { [14]=62355, [15]=62356, [16]=62357 } },
                { id = 116030, slot = "Wrist",            name = "Bracer of Amputation",            sources = { [17]=66929 } },
            },
        },
        {
            index              = 2,
            name               = "The Butcher",
            journalEncounterID = 971,
            aliases            = {},
            achievements       = {
                { id = 8947, name = "Hurry Up, Maggot!", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 113637, slot = "Back",     name = "Cloak of Frenzied Rage",          sources = { [14]=62414, [15]=66802, [16]=66803 } },
                { id = 116297, slot = "Back",     name = "Fleshhook Cloak",                 sources = { [17]=93720 } },
                { id = 116026, slot = "Feet",     name = "Bonebreaker Boots",               sources = { [17]=93719 } },
                { id = 113633, slot = "Feet",     name = "Entrail Squishers",               sources = { [14]=62405, [15]=62407, [16]=67177 } },
                { id = 116230, slot = "Feet",     name = "Ogre-Eater Treads",               sources = { [17]=66879 } },
                { id = 113632, slot = "Hands",    name = "Gauntlets of the Heavy Hand",     sources = { [14]=62402, [15]=62404, [16]=67289 } },
                { id = 113610, slot = "Hands",    name = "Meatmonger's Gory Grips",         sources = { [14]=62392, [15]=62394, [16]=67215 } },
                { id = 115998, slot = "Hands",    name = "Sterilized Handwraps",            sources = { [17]=66919 } },
                { id = 113608, slot = "Head",     name = "Hood of Dispassionate Execution", sources = { [14]=62386, [15]=62388, [16]=67194 } },
                { id = 113609, slot = "Shoulder", name = "Slaughterhouse Spaulders",        sources = { [14]=62389, [15]=62391, [16]=67093 } },
                { id = 113636, slot = "Waist",    name = "Belt of Bloody Guts",             sources = { [14]=62411, [15]=62413, [16]=67112 } },
                { id = 113606, slot = "Weapon",   name = "Butcher's Bloody Cleaver",        sources = { [14]=62380, [15]=62381, [16]=62382 } },
                { id = 116361, slot = "Weapon",   name = "Butcher's Cruel Chopper",         sources = { [17]=65214 } },
                { id = 113607, slot = "Weapon",   name = "Butcher's Terrible Tenderizer",   sources = { [14]=62383, [15]=62384, [16]=62385 } },
                { id = 113634, slot = "Wrist",    name = "Bracers of Spare Skin",           sources = { [14]=62408, [15]=62410, [16]=67308 } },
                { id = 116209, slot = "Wrist",    name = "Spine-Ripper Bracers",            sources = { [17]=66906 } },
            },
        },
        {
            index              = 3,
            name               = "Tectus",
            journalEncounterID = 1195,
            aliases            = { "Tectus, The Living Mountain" },
            achievements       = {
                { id = 8974, name = "More Like Wrecked-us", meta = true, soloable = "yes" },
            },
            specialLoot = {
                -- Illusion: Rockbiter. Weapon enchant illusion modeled
                -- on the Shaman ability of the same name. Shaman-only
                -- drop.
                { id = 138835, kind = "illusion", name = "Illusion: Rockbiter", sourceID = 5874 },
            },
            loot = {
                { id = 116210, slot = "Chest",    name = "Chestwrap of Violent Upheaval",  sources = { [17]=66888 } },
                { id = 116000, slot = "Chest",    name = "Mountainslide Robes",            sources = { [17]=66874 } },
                { id = 113649, slot = "Feet",     name = "Mountainwalker's Boots",         sources = { [14]=62431, [15]=62433, [16]=67113 } },
                { id = 116237, slot = "Head",     name = "Crown of the Crags",             sources = { [17]=66946 } },
                { id = 116032, slot = "Legs",     name = "Legguards of Ravenous Assault",  sources = { [17]=66930 } },
                { id = 113648, slot = "Legs",     name = "Legplates of Fractured Crystal", sources = { [14]=62428, [15]=62430, [16]=67290 } },
                { id = 116363, slot = "Off-hand", name = "Shield of Violent Upheaval",     sources = { [17]=65220 } },
                { id = 113641, slot = "Shoulder", name = "Living Mountain Shoulderguards", sources = { [14]=62422, [15]=62424, [16]=67195 } },
                { id = 113640, slot = "Two-Hand", name = "Earthwarped Bladestaff",         sources = { [14]=62418, [15]=62419, [16]=62420 } },
                { id = 113639, slot = "Two-Hand", name = "Spire of Tectus",                sources = { [14]=62415, [15]=62416, [16]=62417 } },
                { id = 116362, slot = "Weapon",   name = "Shard of Crystalline Fury",      sources = { [17]=65217 } },
                { id = 113642, slot = "Wrist",    name = "Crystal-Woven Bracers",          sources = { [14]=62425, [15]=62427, [16]=67094 } },
            },
        },
        {
            index              = 4,
            name               = "Brackenspore",
            journalEncounterID = 1196,
            aliases            = {},
            achievements       = {
                { id = 8975, name = "A Fungus Among Us", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113657, slot = "Back",     name = "Cloak of Creeping Necrosis",                     sources = { [14]=62449, [15]=66814, [16]=66815 } },
                { id = 116294, slot = "Back",     name = "Rotmelter Mosscloak",                            sources = { [17]=66841 } },
                { id = 113654, slot = "Chest",    name = "Moss-Woven Mailshirt",                           sources = { [14]=62440, [15]=62442, [16]=67267 } },
                { id = 113655, slot = "Chest",    name = "Robes of Necrotic Whispers",                     sources = { [14]=62443, [15]=62445, [16]=67216 } },
                { id = 113660, slot = "Feet",     name = "Mosscrusher Sabatons",                           sources = { [14]=62453, [15]=62455, [16]=67291 } },
                { id = 113664, slot = "Feet",     name = "Sandals of Mycoid Musing",                       sources = { [14]=62459, [15]=62461, [16]=67114 } },
                { id = 116208, slot = "Hands",    name = "Carnage Breath Gauntlets",                       sources = { [17]=66887 } },
                { id = 116233, slot = "Hands",    name = "Grips of Burning Infusion",                      sources = { [17]=66954 } },
                { id = 113653, slot = "Off-hand", name = "Maw of Souls",                                   sources = { [14]=62437, [15]=62438, [16]=62439 } },
                { id = 113652, slot = "Ranged",   name = "Crystalline Branch of the Brackenspore",         sources = { [14]=62434, [15]=62435, [16]=62436 } },
                { id = 113661, slot = "Shoulder", name = "Deep Walker Paulders",                           sources = { [14]=62456, [15]=62458, [16]=67309 } },
                { id = 116028, slot = "Shoulder", name = "Shoulderguards of Perpetually Exploding Fungus", sources = { [17]=66937 } },
                { id = 113659, slot = "Waist",    name = "Fleshchewer Greatbelt",                          sources = { [14]=62450, [15]=62452, [16]=67158 } },
                { id = 113656, slot = "Waist",    name = "Girdle of the Infected Mind",                    sources = { [14]=62446, [15]=62448, [16]=67250 } },
                { id = 115999, slot = "Wrist",    name = "Rotmonger Bracers",                              sources = { [17]=66962 } },
            },
        },
        {
            index              = 5,
            name               = "Twin Ogron",
            journalEncounterID = 1148,
            aliases            = {},
            achievements       = {
                { id = 8958, name = "Brothers in Arms", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113830, slot = "Back",             name = "Cloak of Ruminant Deception",     sources = { [14]=62607, [15]=66804, [16]=66805 } },
                { id = 113831, slot = "Chest",            name = "Chestplate of Arcane Volatility", sources = { [14]=62608, [15]=62610, [16]=67292 } },
                { id = 116025, slot = "Hands",            name = "Pulverizing Grips",               sources = { [17]=66936 } },
                { id = 113832, slot = "Hands",            name = "Treacherous Palms",               sources = { [14]=62611, [15]=62613, [16]=67115 } },
                { id = 116365, slot = "Held In Off-hand", name = "Captured Arcane Fragment",        sources = { [17]=65226 } },
                { id = 113828, slot = "Legs",             name = "Sea-Cursed Leggings",             sources = { [14]=62604, [15]=62606, [16]=67251 } },
                { id = 113666, slot = "Off-hand",         name = "Absalom's Bloody Bulwark",        sources = { [14]=62463, [15]=62464, [16]=62465 } },
                { id = 116211, slot = "Shoulder",         name = "Shoulderguards of the Shepherd",  sources = { [17]=66889 } },
                { id = 115997, slot = "Shoulder",         name = "Twin-Gaze Spaulders",             sources = { [17]=66873 } },
                { id = 113827, slot = "Waist",            name = "Belt of Imminent Lies",           sources = { [14]=62601, [15]=62603, [16]=67196 } },
                { id = 116364, slot = "Weapon",           name = "Dagger of Enfeeblement",          sources = { [17]=93721 } },
                { id = 113667, slot = "Weapon",           name = "Phemos' Double Slasher",          sources = { [14]=62466, [15]=62467, [16]=62468 } },
                { id = 116234, slot = "Wrist",            name = "Bracers of Cursed Cries",         sources = { [17]=66955 } },
                { id = 113826, slot = "Wrist",            name = "Bracers of the Crying Chorus",    sources = { [14]=62598, [15]=62600, [16]=67268 } },
            },
        },
        {
            index              = 6,
            name               = "Ko'ragh",
            journalEncounterID = 1153,
            aliases            = {},
            achievements       = {
                { id = 8976, name = "Pair Annihilation", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 116295, slot = "Back",     name = "Cloak of Overflowing Energies",    sources = { [17]=66839 } },
                { id = 113847, slot = "Back",     name = "Cloak of Searing Shadows",         sources = { [14]=62633, [15]=66794, [16]=66795 } },
                { id = 116029, slot = "Chest",    name = "Crackle-Proof Chestguard",         sources = { [17]=66938 } },
                { id = 113840, slot = "Feet",     name = "Destablized Sandals",              sources = { [14]=62624, [15]=62626, [16]=67217 } },
                { id = 116212, slot = "Head",     name = "Alloy-Inlaid Cap",                 sources = { [17]=66890 } },
                { id = 115996, slot = "Head",     name = "Fel-Flame Coronet",                sources = { [17]=66872 } },
                { id = 113845, slot = "Head",     name = "Rune-Enscribed Hood",              sources = { [14]=62630, [15]=62632, [16]=67233 } },
                { id = 113839, slot = "Legs",     name = "Leggings of Broken Magic",         sources = { [14]=62621, [15]=62623, [16]=67269 } },
                { id = 116231, slot = "Legs",     name = "Legplates of Arcanic Absorbtion",  sources = { [17]=66945 } },
                { id = 113837, slot = "Ranged",   name = "Rod of Fel Nullification",         sources = { [14]=62617, [15]=67091, [16]=67092 } },
                { id = 116367, slot = "Ranged",   name = "Shield-Shatter Longbow",           sources = { [17]=65232 } },
                { id = 113838, slot = "Two-Hand", name = "Gar'tash, Hammer of the Breakers", sources = { [14]=62618, [15]=62619, [16]=62620 } },
                { id = 116366, slot = "Two-Hand", name = "Magic-Breaker Greatsword",         sources = { [17]=65229 } },
                { id = 116368, slot = "Two-Hand", name = "Polearm of Expulsion",             sources = { [17]=65235 } },
                { id = 113836, slot = "Weapon",   name = "Ko'ragh's Boot Knife",             sources = { [14]=62614, [15]=62615, [16]=62616 } },
                { id = 113844, slot = "Wrist",    name = "Bracers of Mirrored Flame",        sources = { [14]=62627, [15]=62629, [16]=67159 } },
            },
        },
        {
            index              = 7,
            name               = "Imperator Mar'gok",
            journalEncounterID = 1197,
            aliases            = {},
            achievements       = {
                { id = 8977, name = "Lineage of Power", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 113852, slot = "Back",     name = "Force Nova Cloak",                     sources = { [14]=62643, [15]=66790, [16]=66791 } },
                { id = 116296, slot = "Back",     name = "Greatcloak of Impactful Pulses",       sources = { [17]=66834 } },
                { id = 116235, slot = "Chest",    name = "Chestplate of Destructive Resonance",  sources = { [17]=66880 } },
                { id = 113850, slot = "Chest",    name = "Robes of the Arcane Ultimatum",        sources = { [14]=62640, [15]=62642, [16]=67095 } },
                { id = 113849, slot = "Feet",     name = "Face Kickers",                         sources = { [14]=62637, [15]=62639, [16]=67197 } },
                { id = 116027, slot = "Head",     name = "Gorian Royal Crown",                   sources = { [17]=66928 } },
                { id = 116002, slot = "Legs",     name = "High Arcanist Leggings",               sources = { [17]=66920 } },
                { id = 113856, slot = "Legs",     name = "Nether Blast Leggings",                sources = { [14]=62647, [15]=62649, [16]=67116 } },
                { id = 116206, slot = "Legs",     name = "Warmage's Legwraps",                   sources = { [17]=66896 } },
                { id = 116373, slot = "Off-hand", name = "Mirrorshield of Arcane Fortification", sources = { [17]=65241 } },
                { id = 113855, slot = "Shoulder", name = "Uncrushable Shoulderplates",           sources = { [14]=62644, [15]=62646, [16]=67178 } },
                { id = 113848, slot = "Two-Hand", name = "Gor'gah, High Blade of the Gorians",   sources = { [14]=62634, [15]=62635, [16]=62636 } },
                { id = 116372, slot = "Two-Hand", name = "Imperator's Warstaff",                 sources = { [17]=65238 } },
                { id = 113857, slot = "Two-Hand", name = "Staff of the Grand Imperator",         sources = { [14]=62650, [15]=62651, [16]=62652 } },
            },
        },
    },

    routing = {

        -- 1. Kargath Bladefist
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Kargath Bladefist",
            requires  = {},
            segments  = {
                {
                    when            = { mapID = 611 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "Talk to Gharg",
                    mapLabelPos     = "below",
                    note            = "After zoning in, talk to ^Gharg^ and tell him you're ready. He will send you up an elevator into ^The Coliseum^.",
                    points          = {
                        { 0.469, 0.474 },
                    },
                },
                {
                    when    = { mapID = 610 },
                    kind    = "path",
                    note    = "After some dialog, kill the trash wave that spawns, and ^Kargath Bladefist^ will enter the ring.",
                    points  = {},
                },
            },
        },

        -- 2. The Butcher
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "The Butcher",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 610 },
                    kind    = "path",
                    note    = "After killing ^Kargath^, exit the room to the northwest and follow the path around to ^The Butcher^.",
                    points  = {
                        { 0.633, 0.838 },
                        { 0.501, 0.672 },
                        { 0.499, 0.600 },
                        { 0.529, 0.558 },
                        { 0.555, 0.554 },
                    },
                },
            },
        },

        -- 3. Tectus
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Tectus",
            requires  = { 2 },
            segments  = {
                {
                    when    = { mapID = 610 },
                    kind    = "path",
                    note    = "After killing ^The Butcher^, follow the path to the west to reach ^Tectus^. Kill the (3) rock golems to spawn the boss.",
                    points  = {
                        { 0.555, 0.532 },
                        { 0.479, 0.471 },
                        { 0.395, 0.595 },
                        { 0.360, 0.620 },
                        { 0.346, 0.691 },
                        { 0.352, 0.715 },
                    },
                },
            },
        },

        -- 4. Brackenspore
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Brackenspore",
            requires  = { 3 },
            segments  = {
                {
                    when    = { mapID = 610 },
                    kind    = "path",
                    note    = "After defeating ^Tectus^, follow the path northeast to reach ^Brackenspore^.",
                    points  = {
                        { 0.346, 0.717 },
                        { 0.368, 0.608 },
                        { 0.400, 0.590 },
                        { 0.454, 0.498 },
                        { 0.511, 0.371 },
                        { 0.511, 0.197 },
                    },
                },
            },
        },

        -- 5. Twin Ogron
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Twin Ogron",
            requires  = { 4 },
            segments  = {
                {
                    when    = { mapID = 610 },
                    kind    = "path",
                    note    = "After defeating ^Brackenspore^, go back out the way you came and travel far west to reach a portal.",
                    points  = {
                        { 0.513, 0.225 },
                        { 0.519, 0.349 },
                        { 0.449, 0.505 },
                        { 0.397, 0.599 },
                        { 0.336, 0.605 },
                        { 0.314, 0.612 },
                    },
                },
                {
                    when    = { mapID = 613 },
                    kind    = "path",
                    note    = "After taking the portal, follow the path around to find ^Twin Ogron^. Clear trash to start the encounter.",
                    points  = {
                        { 0.827, 0.619 },
                        { 0.675, 0.412 },
                        { 0.579, 0.375 },
                    },
                },
            },
        },

        -- 6. Ko'ragh
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Ko'ragh",
            requires  = { 5 },
            segments  = {
                {
                    when    = { mapID = 613 },
                    kind    = "path",
                    note    = "After defeating ^Twin Ogron^, proceed up the stairwell behind them to reach ^Ko'ragh^. Clear trash to start the encounter.",
                    points  = {
                        { 0.512, 0.420 },
                        { 0.449, 0.383 },
                        { 0.391, 0.375 },
                        { 0.383, 0.424 },
                        { 0.473, 0.495 },
                        { 0.406, 0.609 },
                    },
                },
            },
        },

        -- 7. Imperator Mar'gok
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Imperator Mar'gok",
            requires  = { 6 },
            segments  = {
                {
                    when    = { mapID = 613 },
                    kind    = "path",
                    note    = "After killing ^Ko'ragh^, take the northwest stairwell out of the room.",
                    points  = {
                        { 0.356, 0.624 },
                        { 0.297, 0.546 },
                    },
                },
                {
                    when    = { mapID = 614 },
                    kind    = "path",
                    note    = "Work your way through the next area, and kill ^Warden Thul'tok^ to spawn a portal. Walk through the portal.",
                    points  = {
                        { 0.345, 0.606 },
                        { 0.411, 0.545 },
                        { 0.461, 0.560 },
                        { 0.519, 0.621 },
                        { 0.609, 0.562 },
                        { 0.469, 0.301 },
                    },
                },
                {
                    when    = { mapID = 615 },
                    kind    = "path",
                    note    = "After taking the portal, move ahead to clear trash to open the door and reach the final boss, ^Imperator Mar'gok^.",
                    points  = {
                        { 0.467, 0.313 },
                        { 0.449, 0.717 },
                    },
                },
            },
        },

    },
}
