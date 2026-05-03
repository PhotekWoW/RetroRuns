-------------------------------------------------------------------------------
-- RetroRuns Data -- The Eternal Palace
-- Battle for Azeroth, Patch 8.2  |  instanceID: 2164  |  journalInstanceID: 1179
-------------------------------------------------------------------------------
-- The Eternal Palace is the third raid of Battle for Azeroth (8.2),
-- located in Nazjatar. Two structural notes worth understanding when
-- reading this file:
--
-- 1. No class tier sets. Patch 8.2 predated the return of proper tier
--    sets (which came with 9.2 / Sepulcher). Loot is a mix of standard
--    raid drops, Azerite armor, and Benthic-tier upgrades, none of
--    which is per-class-token-gated. The tierSets block is empty.
--
-- 2. Two orb-click gates between Behemoth and Ashvane. The route is
--    fully linear (no parallel pairs), but two of the boss approaches
--    are gated by clicking interactable "Font of Power" orbs which
--    trigger NPC voicelines. The first orb gates the final approach
--    to Radiance; the second gates the final approach to Ashvane.
--    Both orbs produce yells from First Arcanist Thalyssra. Without
--    detecting the yell, geographic-only routing would fail to
--    recognize the orb interaction and stall the player at the orb's
--    coords.
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2164] = {
    instanceID        = 2164,
    journalInstanceID = 1179,
    name              = "The Eternal Palace",
    expansion         = "Battle for Azeroth",
    patch             = "8.2",

    maps = {
        [1512] = "Dais of Eternity",
        [1513] = "Halls of the Chosen",
        [1514] = "Darkest Depths",
        [1516] = "The Traverse",
        [1517] = "The Hatchery",
        [1518] = "The Queen's Court",
        [1519] = "Precipice of Dreams",
        [1520] = "The Last Prison",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    -- No skip mechanic on this raid. Eternal Palace pre-dates Ny'alotha's
    -- MOTHER's Guidance system and has no equivalent boss-skip facility,
    -- so the skipQuests field is omitted (renderer treats absent
    -- skipQuests as "no skip system on this raid").

    bosses = {
        {
            index              = 1,
            name               = "Abyssal Commander Sivara",
            journalEncounterID = 2352,
            aliases            = { "Sivara" },
            achievements       = {
                { id = 13684, name = "You and What Army?", meta = true },
            },
            loot = {
                { id = 168361, slot = "Chest",            name = "Naga Centaur's Shellplate",     sources = { [17]=104469, [14]=104466, [15]=104467, [16]=104468 } },
                { id = 168341, slot = "Chest",            name = "Siren Mystic's Vestments",      sources = { [17]=104389, [14]=104386, [15]=104387, [16]=104388 } },
                { id = 168390, slot = "Feet",             name = "Sabatons of the Stalwart",      sources = { [17]=104571, [14]=104570, [15]=104572, [16]=104573 } },
                { id = 168386, slot = "Hands",            name = "Gauntlets of Overflowing Chill", sources = { [17]=104557, [14]=104554, [15]=104555, [16]=104556 } },
                { id = 168345, slot = "Head",             name = "Helm of the Inexorable Tide",   sources = { [17]=104405, [14]=104402, [15]=104403, [16]=104404 } },
                { id = 168477, slot = "Held In Off-hand", name = "Tidebinder's Driftglobe",       sources = { [17]=105064, [14]=104583, [15]=105062, [16]=105063 } },
                { id = 168371, slot = "Legs",             name = "Seawrath Legwraps",             sources = { [17]=104497, [14]=104494, [15]=104495, [16]=104496 } },
                { id = 168273, slot = "Ranged",           name = "Shiver Venom Crossbow",         sources = { [17]=105049, [14]=104333, [15]=105047, [16]=105048 } },
                { id = 168359, slot = "Shoulder",         name = "Abyssal Commander's Mantle",    sources = { [17]=104461, [14]=104458, [15]=104459, [16]=104460 } },
                { id = 168306, slot = "Two-Hand",         name = "Shiver Venom Lance",            sources = { [17]=104361, [14]=104358, [15]=104359, [16]=104360 } },
                { id = 168384, slot = "Waist",            name = "Wavespine Clutch",              sources = { [17]=104549, [14]=104546, [15]=104547, [16]=104548 } },
                { id = 168276, slot = "Weapon",           name = "Claw of the Myrmidon",          sources = { [17]=104336, [14]=104337, [15]=105039, [16]=105040 } },
                { id = 168901, slot = "Weapon",           name = "Royal Scaleguard's Battleaxe",  sources = { [17]=104786, [14]=104783, [15]=104784, [16]=104785 } },
                { id = 168903, slot = "Weapon",           name = "Scepter of the Azsh'ari",       sources = { [17]=104794, [14]=104791, [15]=104792, [16]=104793 } },
                { id = 168818, slot = "Weapon",           name = "Sivara's Slitherblade",         sources = { [17]=105035, [14]=104675, [15]=105033, [16]=105034 } },
                { id = 168387, slot = "Wrist",            name = "Palace Sentinel Vambraces",     sources = { [17]=104561, [14]=104558, [15]=104559, [16]=104560 } },
                { id = 168377, slot = "Wrist",            name = "Tideblood Bracers",             sources = { [17]=104521, [14]=104518, [15]=104519, [16]=104520 } },
            },
        },
        {
            index              = 2,
            name               = "Blackwater Behemoth",
            journalEncounterID = 2347,
            aliases            = { "Behemoth" },
            achievements       = {
                { id = 13628, name = "Intro to Marine Biology", meta = true },
            },
            loot = {
                { id = 168343, slot = "Chest",    name = "Blackwater Shimmerscale Vest",   sources = { [17]=104395, [14]=104394, [15]=104396, [16]=104397 } },
                { id = 168373, slot = "Feet",     name = "Eelskin Flippers",               sources = { [17]=104503, [14]=104502, [15]=104504, [16]=104505 } },
                { id = 168385, slot = "Feet",     name = "Slipstreamer's Saltwalkers",     sources = { [17]=104553, [14]=104550, [15]=104551, [16]=104552 } },
                { id = 168376, slot = "Hands",    name = "Anglerfish Feelers",             sources = { [17]=104515, [14]=104514, [15]=104516, [16]=104517 } },
                { id = 168885, slot = "Hands",    name = "Undercove Crushers",             sources = { [17]=104749, [14]=104746, [15]=104747, [16]=104748 } },
                { id = 168353, slot = "Head",     name = "Hood of Lightless Depths",       sources = { [17]=104435, [14]=104434, [15]=104436, [16]=104437 } },
                { id = 168389, slot = "Legs",     name = "Fleetwrecker's Greaves",         sources = { [17]=104569, [14]=104566, [15]=104567, [16]=104568 } },
                { id = 168383, slot = "Legs",     name = "Pelagos Predator's Legguards",   sources = { [17]=104545, [14]=104542, [15]=104543, [16]=104544 } },
                { id = 168342, slot = "Shoulder", name = "Fathom-Feeder's Mantle",         sources = { [17]=104390, [14]=104391, [15]=104392, [16]=104393 } },
                { id = 168362, slot = "Shoulder", name = "Trench Tyrant's Shoulderplates", sources = { [17]=104473, [14]=104470, [15]=104471, [16]=104472 } },
                { id = 168379, slot = "Waist",    name = "Ship Swallower's Belt",          sources = { [17]=104527, [14]=104526, [15]=104528, [16]=104529 } },
                { id = 168900, slot = "Weapon",   name = "Diver's Folly",                  sources = { [17]=104782, [14]=104779, [15]=104780, [16]=104781 } },
                { id = 168397, slot = "Weapon",   name = "Fang of the Behemoth",           sources = { [17]=105058, [14]=104578, [15]=105056, [16]=105057 } },
            },
            specialLoot = {
                { id = 169360, kind = "pet", name = "Mindlost Bloodfrenzy" },
            },
        },
        {
            index              = 3,
            name               = "Radiance of Azshara",
            journalEncounterID = 2353,
            aliases            = { "Radiance" },
            achievements       = {
                { id = 13767, name = "Fun Run", meta = true },
            },
            loot = {
                { id = 168355, slot = "Chest",    name = "Servitor's Heartguard",         sources = { [17]=104443, [14]=104442, [15]=104444, [16]=104445 } },
                { id = 168380, slot = "Feet",     name = "Ancient Tempest Striders",      sources = { [17]=104531, [14]=104530, [15]=104532, [16]=104533 } },
                { id = 168375, slot = "Hands",    name = "Gloves of Unshackled Arcana",   sources = { [17]=104513, [14]=104510, [15]=104511, [16]=104512 } },
                { id = 168381, slot = "Hands",    name = "Grips of the Scaled Arcanist",  sources = { [17]=104537, [14]=104534, [15]=104535, [16]=104536 } },
                { id = 168336, slot = "Head",     name = "Handmaiden's Cowl of Sacrifice", sources = { [17]=104369, [14]=104366, [15]=104367, [16]=104368 } },
                { id = 168360, slot = "Head",     name = "Warhelm of Dread Waters",       sources = { [17]=104465, [14]=104462, [15]=104463, [16]=104464 } },
                { id = 168378, slot = "Legs",     name = "Leggings of the Stormborn",     sources = { [17]=104523, [14]=104522, [15]=104524, [16]=104525 } },
                { id = 168475, slot = "Off-hand", name = "Bulwark of the Seaborn Avatar", sources = { [17]=105076, [14]=104581, [15]=105074, [16]=105075 } },
                { id = 168348, slot = "Shoulder", name = "Shoulderpads of Frothing Rage", sources = { [17]=104417, [14]=104414, [15]=104415, [16]=104416 } },
                { id = 168478, slot = "Two-Hand", name = "Monstrosity's Shipbreaker",     sources = { [17]=105070, [14]=104584, [15]=105068, [16]=105069 } },
                { id = 168374, slot = "Waist",    name = "Belt of Blind Devotion",        sources = { [17]=104507, [14]=104506, [15]=104508, [16]=104509 } },
                { id = 168388, slot = "Waist",    name = "Storm-Tempered Girdle",         sources = { [17]=104563, [14]=104562, [15]=104564, [16]=104565 } },
                { id = 168382, slot = "Wrist",    name = "Arcanamental Bindings",         sources = { [17]=104539, [14]=104538, [15]=104540, [16]=104541 } },
                { id = 168372, slot = "Wrist",    name = "Sea Sculptor's Cuffs",          sources = { [17]=104501, [14]=104498, [15]=104499, [16]=104500 } },
            },
        },
        {
            index              = 4,
            name               = "Lady Ashvane",
            journalEncounterID = 2354,
            aliases            = { "Ashvane" },
            achievements       = {
                { id = 13629, name = "Simple Geometry", meta = true },
            },
            loot = {
                { id = 168367, slot = "Chest",    name = "Barnacle-Crusted Breastplate",     sources = { [17]=104493, [14]=104490, [15]=104491, [16]=104492 } },
                { id = 168335, slot = "Chest",    name = "Robes of Sunken Nobility",         sources = { [17]=104365, [14]=104362, [15]=104363, [16]=104364 } },
                { id = 168877, slot = "Feet",     name = "Coralshell Warboots",              sources = { [17]=104715, [14]=104714, [15]=104716, [16]=104717 } },
                { id = 168347, slot = "Head",     name = "Helm of Hideous Transformation",   sources = { [17]=104413, [14]=104410, [15]=104411, [16]=104412 } },
                { id = 168876, slot = "Legs",     name = "Priscilla's Fishnets",             sources = { [17]=104713, [14]=104710, [15]=104711, [16]=104712 } },
                { id = 168354, slot = "Shoulder", name = "Shoulderguards of Crushing Depths", sources = { [17]=104441, [14]=104438, [15]=104439, [16]=104440 } },
                { id = 168870, slot = "Waist",    name = "Tanglekelp Waistwrap",             sources = { [17]=104689, [14]=104686, [15]=104687, [16]=104688 } },
                { id = 168904, slot = "Weapon",   name = "Current-Weaver's Gavel",           sources = { [17]=104798, [14]=104795, [15]=104796, [16]=104797 } },
                { id = 168883, slot = "Wrist",    name = "Cultured Pearl Armbands",          sources = { [17]=104741, [14]=104738, [15]=104739, [16]=104740 } },
            },
            specialLoot = {
                { id = 169358, kind = "pet", name = "Lightless Ambusher" },
            },
        },
        {
            index              = 5,
            name               = "Orgozoa",
            journalEncounterID = 2351,
            aliases            = {},
            achievements       = {
                { id = 13724, name = "A Smack of Jellyfish", meta = true },
            },
            loot = {
                { id = 168604, slot = "Back",     name = "Drape of the Hatcher",          sources = { [17]=104596, [14]=104593, [15]=104594, [16]=104595 } },
                { id = 168352, slot = "Chest",    name = "Scalemail of Unnatural Selection", sources = { [17]=104431, [14]=104430, [15]=104432, [16]=104433 } },
                { id = 168365, slot = "Head",     name = "Greathelm of the Tender",       sources = { [17]=104485, [14]=104482, [15]=104483, [16]=104484 } },
                { id = 168339, slot = "Head",     name = "Incubator's Bellcap",           sources = { [17]=104381, [14]=104378, [15]=104379, [16]=104380 } },
                { id = 168875, slot = "Legs",     name = "Formcrafter's Pants",           sources = { [17]=104707, [14]=104706, [15]=104708, [16]=104709 } },
                { id = 168476, slot = "Off-hand", name = "Great Reef Barrier",            sources = { [17]=105079, [14]=104582, [15]=105077, [16]=105078 } },
                { id = 168894, slot = "Ranged",   name = "Squidhunter Speargun",          sources = { [17]=105052, [14]=104764, [15]=105050, [16]=105051 } },
                { id = 168346, slot = "Shoulder", name = "Tidal Drifter's Shoulders",     sources = { [17]=104409, [14]=104406, [15]=104407, [16]=104408 } },
                { id = 168274, slot = "Two-Hand", name = "Aqua-Pulse Trident",            sources = { [17]=105055, [14]=104334, [15]=105053, [16]=105054 } },
                { id = 168897, slot = "Two-Hand", name = "Tentacle Crusher",              sources = { [17]=105073, [14]=104770, [15]=105071, [16]=105072 } },
                { id = 168872, slot = "Waist",    name = "Cephalopod's Sash",             sources = { [17]=104695, [14]=104694, [15]=104696, [16]=104697 } },
                { id = 168893, slot = "Weapon",   name = "Hatchery Scraper",              sources = { [17]=105043, [14]=104763, [15]=105041, [16]=105042 } },
                { id = 168899, slot = "Weapon",   name = "Orgozoa's Paralytic Barb",      sources = { [17]=104778, [14]=104775, [15]=104776, [16]=104777 } },
            },
        },
        {
            index              = 6,
            name               = "The Queen's Court",
            journalEncounterID = 2359,
            aliases            = { "Queen's Court", "Court" },
            achievements       = {
                { id = 13633, name = "If It Pleases the Court", meta = true },
            },
            loot = {
                { id = 168350, slot = "Chest",            name = "Tunic of the Sycophant",        sources = { [17]=104423, [14]=104422, [15]=104424, [16]=104425 } },
                { id = 168879, slot = "Feet",             name = "Ardent Worshipper's Boots",     sources = { [17]=104723, [14]=104722, [15]=104724, [16]=104725 } },
                { id = 168886, slot = "Hands",            name = "Hands of the Fanatic",          sources = { [17]=104753, [14]=104750, [15]=104751, [16]=104752 } },
                { id = 168357, slot = "Head",             name = "Silivaz's Skullguard",          sources = { [17]=104453, [14]=104450, [15]=104451, [16]=104452 } },
                { id = 168896, slot = "Held In Off-hand", name = "Stormtamer's Orb",              sources = { [17]=105067, [14]=104769, [15]=105065, [16]=105066 } },
                { id = 168898, slot = "Ranged",           name = "Pashmar's Finial",              sources = { [17]=104774, [14]=104771, [15]=104772, [16]=104773 } },
                { id = 168338, slot = "Shoulder",         name = "Amice of the Reef Witch",       sources = { [17]=104374, [14]=104375, [15]=104376, [16]=104377 } },
                { id = 168364, slot = "Shoulder",         name = "Pauldrons of Fanatical Might",  sources = { [17]=104481, [14]=104478, [15]=104479, [16]=104480 } },
                { id = 168892, slot = "Weapon",           name = "Court Dagger of Sentencing",    sources = { [17]=105038, [14]=104762, [15]=105036, [16]=105037 } },
                { id = 168881, slot = "Wrist",            name = "Naga Executor's Armguards",     sources = { [17]=104733, [14]=104730, [15]=104731, [16]=104732 } },
            },
        },
        {
            index              = 7,
            name               = "Za'qul, Harbinger of Ny'alotha",
            journalEncounterID = 2349,
            aliases            = { "Za'qul" },
            achievements       = {
                { id = 13716, name = "Lactose Intolerant", meta = true },
            },
            loot = {
                { id = 168391, slot = "Back",     name = "Cloak of Ill Tidings",            sources = { [17]=104577, [14]=104574, [15]=104575, [16]=104576 } },
                { id = 168363, slot = "Chest",    name = "Dark Passenger's Breastplate",    sources = { [17]=104477, [14]=104474, [15]=104475, [16]=104476 } },
                { id = 168337, slot = "Chest",    name = "Vestments of Creeping Terror",    sources = { [17]=104373, [14]=104370, [15]=104371, [16]=104372 } },
                { id = 168349, slot = "Head",     name = "Shroud of Unmooring Whispers",    sources = { [17]=104421, [14]=104418, [15]=104419, [16]=104420 } },
                { id = 169588, slot = "Shoulder", name = "Gardbrace of Fractured Reality",  sources = { [17]=105158, [14]=105155, [15]=105156, [16]=105157 } },
                { id = 168902, slot = "Weapon",   name = "Dream's End",                     sources = { [17]=104790, [14]=104787, [15]=104788, [16]=104789 } },
                { id = 168301, slot = "Weapon",   name = "Sever, Edge of Madness",          sources = { [17]=105046, [14]=104357, [15]=105044, [16]=105045 } },
                { id = 168884, slot = "Wrist",    name = "Bindings of the Herald",          sources = { [17]=104745, [14]=104742, [15]=104743, [16]=104744 } },
                { id = 168882, slot = "Wrist",    name = "Shackles of Dissonance",          sources = { [17]=104735, [14]=104734, [15]=104736, [16]=104737 } },
            },
            specialLoot = {
                { id = 169362, kind = "pet", name = "Nameless Octopode" },
            },
        },
        {
            index              = 8,
            name               = "Queen Azshara",
            journalEncounterID = 2361,
            aliases            = { "Azshara" },
            achievements       = {
                { id = 13768, name = "The Best of Us", meta = true },
            },
            loot = {
                { id = 168880, slot = "Feet",     name = "Slippers of the Sorceress-Queen",    sources = { [17]=104727, [14]=104726, [15]=104728, [16]=104729 } },
                { id = 168878, slot = "Feet",     name = "Vethan's Icewalkers",                sources = { [17]=104721, [14]=104718, [15]=104719, [16]=104720 } },
                { id = 168887, slot = "Hands",    name = "Gloves of Incomparable Beauty",      sources = { [17]=104755, [14]=104754, [15]=104756, [16]=104757 } },
                { id = 168888, slot = "Hands",    name = "Handguards of the Highest-Born",     sources = { [17]=104761, [14]=104758, [15]=104759, [16]=104760 } },
                { id = 168874, slot = "Legs",     name = "Cherished Empress's Leggings",       sources = { [17]=104705, [14]=104702, [15]=104703, [16]=104704 } },
                { id = 168873, slot = "Legs",     name = "Tide Goddess's Wargreaves",          sources = { [17]=104701, [14]=104698, [15]=104699, [16]=104700 } },
                { id = 168275, slot = "Two-Hand", name = "Anu-Azshara, Staff of the Eternal",  sources = { [17]=105061, [14]=104335, [15]=105059, [16]=105060 } },
                { id = 168871, slot = "Waist",    name = "Beloved Monarch's Waistwrap",        sources = { [17]=104691, [14]=104690, [15]=104692, [16]=104693 } },
                { id = 168869, slot = "Waist",    name = "Eternity Keeper's Greatbelt",        sources = { [17]=104683, [14]=104682, [15]=104684, [16]=104685 } },
            },
            specialLoot = {
                { id = 169348, kind = "pet", name = "Zanj'ir Poker" },
            },
        },
    },

    routing = {
        -- DAG: fully linear chain.
        --   1. Sivara          requires {}
        --   2. Behemoth        requires { 1 }
        --   3. Radiance        requires { 2 }   (yell-gated final approach)
        --   4. Ashvane         requires { 3 }   (yell-gated final approach)
        --   5. Orgozoa         requires { 4 }
        --   6. Queen's Court   requires { 5 }
        --   7. Za'qul          requires { 6 }
        --   8. Queen Azshara   requires { 7 }

        -- 1. Abyssal Commander Sivara
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Abyssal Commander Sivara",
            requires  = {},
            segments  = {
                {
                    mapID   = 1512,
                    kind    = "path",
                    subZone = "Dais of Eternity",
                    note    = "After zoning in, follow the path straight ahead to engage Sivara.",
                    points  = {
                        { 0.914, 0.487 },
                        { 0.523, 0.487 },
                    },
                },
            },
        },

        -- 2. Blackwater Behemoth
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Blackwater Behemoth",
            requires  = { 1 },
            segments  = {
                {
                    mapID   = 1512,
                    kind    = "path",
                    subZone = "Dais of Eternity",
                    note    = "After defeating Sivara, continue past her towards the map exit labeled Halls of the Chosen. Take the underwater tunnel to reach the next area.",
                    points  = {
                        { 0.473, 0.487 },
                        { 0.463, 0.390 },
                        { 0.417, 0.386 },
                        { 0.344, 0.486 },
                        { 0.265, 0.489 },
                        { 0.238, 0.411 },
                        { 0.178, 0.402 },
                        { 0.159, 0.463 },
                    },
                },
                {
                    mapID   = 1513,
                    kind    = "path",
                    subZone = "Halls of the Chosen",
                    -- The mapID 1512 -> 1513 transition fires the
                    -- moment the player enters the underwater corridor,
                    -- which is technically part of mapID 1513 but
                    -- reports the parent raid name as its sub-zone.
                    -- This seg waits until the player surfaces into
                    -- the named "Halls of the Chosen" sub-zone, so
                    -- the "After coming out of the water" instruction
                    -- doesn't display while the player is still
                    -- swimming.
                    requiresSubZone = "Halls of the Chosen",
                    note    = "After coming out of the water, take the path south towards the map exit labeled Darkest Depths.",
                    points  = {
                        { 0.648, 0.708 },
                        { 0.626, 0.695 },
                        { 0.608, 0.672 },
                        { 0.553, 0.695 },
                        { 0.535, 0.756 },
                        { 0.473, 0.808 },
                        { 0.473, 0.860 },
                        { 0.460, 0.885 },
                    },
                },
                {
                    mapID   = 1514,
                    kind    = "path",
                    subZone = "Darkest Depths",
                    note    = "Enter the water and click the Oxygen-Rich Membrane for swim speed and water breathing. You must kill the last trash pack in the tunnel to spawn Blackwater Behemoth.",
                    points  = {
                        { 0.564, 0.176 },
                        { 0.561, 0.282 },
                        { 0.423, 0.294 },
                        { 0.377, 0.242 },
                    },
                },
            },
        },

        -- 3. Radiance of Azshara  (gated by Orb 1 / Font of Power)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Radiance of Azshara",
            requires  = { 2 },
            segments  = {
                {
                    mapID   = 1514,
                    kind    = "path",
                    subZone = "Darkest Depths",
                    note    = "After killing Behemoth, swim back out the way you came to the map exit labeled Halls of the Chosen.",
                    points  = {
                        { 0.373, 0.237 },
                        { 0.445, 0.289 },
                        { 0.562, 0.280 },
                        { 0.568, 0.158 },
                    },
                },
                {
                    mapID   = 1513,
                    kind    = "path",
                    subZone = "Halls of the Chosen",
                    -- Same underwater-corridor situation as Behemoth
                    -- seg 2: the swim-back from Darkest Depths transits
                    -- the unnamed portion of mapID 1513 before
                    -- surfacing into the named "Halls of the Chosen"
                    -- sub-zone. This seg waits until the actual surface
                    -- arrival.
                    requiresSubZone = "Halls of the Chosen",
                    note    = "After returning to the Halls of the Chosen, walk straight ahead to kill a couple Azsh'ari Channelers and click the orb (Font of Power).",
                    points  = {
                        { 0.460, 0.883 },
                        { 0.475, 0.859 },
                        { 0.473, 0.760 },
                    },
                },
                {
                    -- Approach to Radiance opens after clicking the
                    -- first Font of Power orb. Detected via First
                    -- Arcanist Thalyssra's voiceline; without that
                    -- detection the player would stand at the orb's
                    -- coords with no follow-on instruction.
                    mapID   = 1513,
                    kind    = "path",
                    subZone = "Halls of the Chosen",
                    note    = "After clicking the first orb, follow the path all the way north to kill Radiance of Azshara. Clear all the trash to start the encounter.",
                    advanceOn = {
                        kind  = "yell",
                        npc   = "First Arcanist Thalyssra",
                        match = "find the last font",
                    },
                    points  = {
                        { 0.474, 0.761 },
                        { 0.473, 0.808 },
                        { 0.437, 0.795 },
                        { 0.398, 0.750 },
                        { 0.380, 0.685 },
                        { 0.392, 0.610 },
                        { 0.439, 0.569 },
                        { 0.471, 0.564 },
                        { 0.469, 0.370 },
                        { 0.432, 0.359 },
                        { 0.417, 0.318 },
                        { 0.418, 0.272 },
                        { 0.450, 0.225 },
                    },
                },
            },
        },

        -- 4. Lady Ashvane  (gated by Orb 2 / second Font of Power)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Lady Ashvane",
            requires  = { 3 },
            segments  = {
                {
                    mapID   = 1513,
                    kind    = "path",
                    subZone = "Halls of the Chosen",
                    note    = "After defeating Radiance of Azshara, leave the room the way you came and find 2 more Azsh'ari Channelers guarding an orb. Kill them and click Orb #2.",
                    points  = {
                        { 0.469, 0.226 },
                        { 0.428, 0.252 },
                        { 0.413, 0.308 },
                        { 0.437, 0.363 },
                        { 0.467, 0.375 },
                        { 0.473, 0.600 },
                    },
                },
                {
                    -- Approach to Ashvane opens after clicking the
                    -- second Font of Power orb. Same NPC voiceline
                    -- mechanism as the first orb, with a different
                    -- spoken phrase.
                    mapID   = 1513,
                    kind    = "path",
                    subZone = "Halls of the Chosen",
                    note    = "After clicking the Orb, the path opens to fight Lady Ashvane.",
                    advanceOn = {
                        kind  = "yell",
                        npc   = "First Arcanist Thalyssra",
                        match = "barrier has fallen",
                    },
                    points  = {
                        { 0.473, 0.615 },
                        { 0.472, 0.567 },
                        { 0.422, 0.569 },
                        { 0.386, 0.655 },
                        { 0.383, 0.685 },
                        { 0.455, 0.689 },
                    },
                },
            },
        },

        -- 5. Orgozoa
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Orgozoa",
            requires  = { 4 },
            -- The Traverse (mapID 1516) is a teleport-pad room where
            -- the player hops between landing pads in a fixed sequence.
            -- Path lines between the pads visually misrepresent the
            -- movement (teleports look like running), so the room
            -- renders three numbered waypoint markers instead of a
            -- polyline.
            renderAllSegments = true,
            segments  = {
                {
                    -- Instruction-only seg (no points). Auto-completes
                    -- when the player jumps from mapID 1513 (Ashvane's
                    -- room) into mapID 1516 (The Traverse). The travel
                    -- pane shows the note while the map-overlay stays
                    -- empty for this seg.
                    mapID   = 1513,
                    kind    = "path",
                    subZone = "Halls of the Chosen",
                    note    = "After killing Lady Ashvane, jump through the hole in the middle of her boss room to land in The Traverse.",
                    points  = {},
                },
                {
                    mapID   = 1516,
                    kind    = "path",
                    subZone = "The Traverse",
                    note    = "After jumping through the hole into The Traverse, make your way to the bottom of the room by walking over a sequence of teleporting panels on the floor.",
                    points  = {
                        { 0.542, 0.459 },
                    },
                },
                {
                    mapID   = 1516,
                    kind    = "path",
                    subZone = "The Traverse",
                    points  = {
                        { 0.561, 0.437 },
                    },
                },
                {
                    mapID   = 1516,
                    kind    = "path",
                    subZone = "The Traverse",
                    points  = {
                        { 0.518, 0.570 },
                    },
                },
                {
                    mapID   = 1517,
                    kind    = "path",
                    subZone = "The Hatchery",
                    note    = "When you reach the bottom, simply follow the path to Orgozoa and kill him.",
                    points  = {
                        { 0.825, 0.367 },
                        { 0.795, 0.398 },
                        { 0.793, 0.471 },
                        { 0.774, 0.474 },
                    },
                },
            },
        },

        -- 6. The Queen's Court
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "The Queen's Court",
            requires  = { 5 },
            segments  = {
                {
                    mapID   = 1517,
                    kind    = "path",
                    subZone = "The Hatchery",
                    note    = "After killing Orgozoa, travel to the far west to reach the map exit labeled The Queen's Court. You will be swimming for a good portion of this journey.",
                    points  = {
                        { 0.728, 0.468 },
                        { 0.699, 0.458 },
                        { 0.709, 0.377 },
                        { 0.688, 0.333 },
                        { 0.650, 0.328 },
                        { 0.629, 0.366 },
                        { 0.634, 0.415 },
                        { 0.654, 0.477 },
                        { 0.653, 0.581 },
                        { 0.571, 0.553 },
                        { 0.449, 0.559 },
                        { 0.119, 0.619 },
                    },
                },
                {
                    mapID   = 1518,
                    kind    = "path",
                    subZone = "The Queen's Court",
                    note    = "After surfacing from the water, follow the path around to reach The Queen's Court.",
                    points  = {
                        { 0.667, 0.482 },
                        { 0.474, 0.479 },
                        { 0.424, 0.329 },
                        { 0.281, 0.277 },
                        { 0.262, 0.314 },
                        { 0.299, 0.348 },
                        { 0.330, 0.444 },
                    },
                },
            },
        },

        -- 7. Za'qul, Harbinger of Ny'alotha
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Za'qul, Harbinger of Ny'alotha",
            requires  = { 6 },
            segments  = {
                {
                    mapID   = 1518,
                    kind    = "path",
                    subZone = "The Queen's Court",
                    note    = "After defeating The Queen's Court, head up some stairs towards the map exit labeled Precipice of Dreams.",
                    points  = {
                        { 0.312, 0.483 },
                        { 0.247, 0.420 },
                        { 0.203, 0.432 },
                        { 0.172, 0.479 },
                    },
                },
                {
                    mapID   = 1519,
                    kind    = "path",
                    subZone = "Precipice of Dreams",
                    note    = "Inside the Precipice of Dreams, follow the path all the way west to kill Za'qul, Harbinger of Ny'alotha.",
                    points  = {
                        { 0.869, 0.512 },
                        { 0.696, 0.510 },
                        { 0.681, 0.297 },
                        { 0.537, 0.323 },
                        { 0.539, 0.510 },
                        { 0.364, 0.510 },
                        { 0.357, 0.427 },
                        { 0.331, 0.408 },
                        { 0.297, 0.417 },
                        { 0.206, 0.510 },
                    },
                },
            },
        },

        -- 8. Queen Azshara
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Queen Azshara",
            requires  = { 7 },
            segments  = {
                {
                    mapID   = 1519,
                    kind    = "path",
                    subZone = "Precipice of Dreams",
                    note    = "After killing Za'qul, watch a brief dialog while waiting on a portal to spawn behind the boss. Take the portal, marked on the map as an exit labeled The Last Prison.",
                    points  = {
                        { 0.155, 0.500 },
                        { 0.112, 0.471 },
                    },
                },
                {
                    -- Star marker on the Titan Console, the
                    -- interactable that engages Queen Azshara after
                    -- the player takes the portal into The Last Prison.
                    mapID    = 1520,
                    kind     = "poi",
                    subZone  = "The Last Prison",
                    note     = "After taking the portal into The Last Prison, you will watch some lengthy dialog then click the Titan Console in front of you to engage Queen Azshara.",
                    poiSize  = 35,
                    points   = {
                        { 0.580, 0.521 },
                    },
                },
            },
        },
    },
}
