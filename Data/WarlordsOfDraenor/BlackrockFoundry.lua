-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackrock Foundry
-- Warlords of Draenor, Patch 6.0.3  |  instanceID: 1205  |  journalInstanceID: 457
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1205] = {
    instanceID        = 1205,
    journalInstanceID = 457,
    name              = "Blackrock Foundry",
    expansion         = "Warlords of Draenor",
    patch             = "6.0.3",

    exitNote = "Jump off the ledge to your death, and you will respawn at the raid exit.",

    entrance = {
        mapID = 543,
        x     = 0.5155,
        y     = 0.2723,
    },

    maps = {
        [596] = "The Black Forge",
        [597] = "Slagworks",
        [598] = "The Workshop",
        [599] = "Iron Assembly",
        [600] = "The Crucible",
    },

    -- WoD-era raids have two separate boss loot tables: an LFR pool
    -- (unique appearances that drop ONLY at Raid Finder difficulty)
    -- and an N/H/M pool (the per-difficulty recolors that drop at
    -- Normal, Heroic, and Mythic). The two pools share no items.
    splitLootTables = true,

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    skipQuests = {
        normal = 37029,
        heroic = 37030,
        mythic = 37031,
    },

    skipTrigger = {
        questName = "Sigil of the Black Hand",
        details   = "Kill the opening trash packs, and click the large artifact on either side of the bridge to open a path to skip straight to ^Blackhand^.",
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
            name               = "Oregorger",
            journalEncounterID = 1202,
            aliases            = { "Oregorger the Devourer" },
            achievements       = {
                { id = 8979, name = "He Shoots, He Ores", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 113878, slot = "Back",             name = "Barrage Dodger Cloak",              sources = { [14]=62687, [15]=66781, [16]=66782 } },
                { id = 113883, slot = "Back",             name = "Ravenous Greatcloak",               sources = { [14]=62697, [15]=66798, [16]=66799 } },
                { id = 113881, slot = "Chest",            name = "Chestplate of Rolling Fury",        sources = { [14]=62694, [15]=62696, [16]=67179 } },
                { id = 113876, slot = "Hands",            name = "Toothbreaker Grips",                sources = { [14]=62684, [15]=62686, [16]=67253 } },
                { id = 113880, slot = "Head",             name = "Acidic Jaws",                       sources = { [14]=62691, [15]=62693, [16]=67118 } },
                { id = 113879, slot = "Held In Off-hand", name = "Caged Living Ooze",                 sources = { [14]=62688, [15]=62689, [16]=62690 } },
                { id = 113875, slot = "Legs",             name = "Corrosion-Proof Legguards",         sources = { [14]=62681, [15]=62683, [16]=67199 } },
                { id = 113884, slot = "Shoulder",         name = "Unstable Slag Shoulderplates",      sources = { [14]=62698, [15]=62700, [16]=67160 } },
                { id = 119448, slot = "Two-Hand",         name = "Head-Lopper Skullscythe",           sources = { [14]=67130, [15]=67131, [16]=67132 } },
                { id = 116215, slot = "Waist",            name = "Barrage Blaster Belt",              sources = { [17]=66891 } },
                { id = 116240, slot = "Waist",            name = "Waistplate of Caustic Spittle",     sources = { [17]=66948 } },
                { id = 113874, slot = "Weapon",           name = "Oregorger's Acid-Etched Gutripper", sources = { [14]=62678, [15]=62679, [16]=62680 } },
                { id = 116381, slot = "Weapon",           name = "Oregorger's Blackrock Shanker",     sources = { [17]=65252 } },
                { id = 116380, slot = "Weapon",           name = "Oregorger's Venomous Canine",       sources = { [17]=65249 } },
                { id = 116046, slot = "Wrist",            name = "Bracers of Satiation",              sources = { [17]=66941 } },
                { id = 116007, slot = "Wrist",            name = "Bracers of Unending Consumption",   sources = { [17]=66876 } },
    { id = 116033, slot = "Hands",               name = "Roilgut Gauntlets",                             sources = { [17]=66912 } },
    { id = 116257, slot = "Head",                name = "Acid-Munched Greathelm",                        sources = { [17]=66885 } },
    { id = 116308, slot = "Back",                name = "Greatcloak of Insatiable Hunger",               sources = { [17]=66838 } },
    { id = 116021, slot = "Feet",                name = "Chasmwalker Sandals",                           sources = { [17]=64873 } },
            },
        },
        {
            index              = 2,
            name               = "Hans'gar and Franzok",
            journalEncounterID = 1155,
            barLabel           = "Hans & Franz",
            aliases            = { "Hans'gar", "Hans'gar & Franzok" },
            achievements       = {
                { id = 8980, name = "Stamp Stamp Revolution", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113902, slot = "Chest",    name = "Chestguard of Unending Roars", sources = { [14]=62734, [15]=62736, [16]=67201 } },
                { id = 113898, slot = "Chest",    name = "Eye-Catching Gilded Robe",     sources = { [14]=62728, [15]=62729, [16]=62730 } },
                { id = 116034, slot = "Feet",     name = "Drop Kickers",                 sources = { [17]=66931 } },
                { id = 116238, slot = "Feet",     name = "Heel Protectors",              sources = { [17]=66947 } },
                { id = 113906, slot = "Hands",    name = "Gauntlets of Dramatic Blows",  sources = { [14]=62743, [15]=62745, [16]=67181 } },
                { id = 113910, slot = "Head",     name = "Hardened Greathelm",           sources = { [14]=62749, [15]=62751, [16]=67294 } },
                { id = 113903, slot = "Shoulder", name = "Giant Pumpers",                sources = { [14]=62737, [15]=62739, [16]=67255 } },
                { id = 113899, slot = "Shoulder", name = "Neckbreaker Shoulderguards",   sources = { [14]=62731, [15]=62733, [16]=67272 } },
                { id = 113907, slot = "Waist",    name = "Girdle of Unconquered Glory",  sources = { [14]=62746, [15]=62748, [16]=67235 } },
                { id = 113904, slot = "Weapon",   name = "Franzok's Headsmasher",        sources = { [14]=62740, [15]=62741, [16]=62742 } },
                { id = 113897, slot = "Weapon",   name = "Hans'gar's Forgehammer",       sources = { [14]=62725, [15]=62726, [16]=62727 } },
    { id = 116256, slot = "Shoulder",            name = "Elbow Drop Spaulders",                          sources = { [17]=66884 } },
    { id = 116227, slot = "Chest",               name = "Blood-Binder Chestguard",                       sources = { [17]=66910 } },
    { id = 116012, slot = "Head",                name = "Fresh-Face Hood",                               sources = { [17]=66923 } },
    { id = 116305, slot = "Back",                name = "Scorchburn Cloak",                              sources = { [17]=66840 } },
    { id = 116217, slot = "Wrist",               name = "Brawler Brother's Bracers",                     sources = { [17]=66892 } },
            },
        },
        {
            index              = 3,
            name               = "Beastlord Darmac",
            journalEncounterID = 1122,
            aliases            = {},
            achievements       = {
                { id = 8981, name = "Fain Would Lie Down", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113945, slot = "Back",     name = "Flame Infusion Drape",                      sources = { [14]=62821, [15]=66788, [16]=66789 } },
                { id = 116255, slot = "Chest",    name = "Heartsmasher Chestplate",                   sources = { [17]=66952 } },
                { id = 116016, slot = "Chest",    name = "Robes of Brutal Tantrums",                  sources = { [17]=66969 } },
                { id = 113951, slot = "Chest",    name = "Unrendable Wolfhide Robes",                 sources = { [14]=62831, [15]=62833, [16]=67310 } },
                { id = 116213, slot = "Feet",     name = "Black Iron Spurs",                          sources = { [17]=66897 } },
                { id = 113942, slot = "Feet",     name = "Inferno Breath Sandals",                    sources = { [14]=62812, [15]=62813, [16]=62814 } },
                { id = 116019, slot = "Feet",     name = "Treads of the Flaming Maw",                 sources = { [17]=66926 } },
                { id = 113949, slot = "Hands",    name = "Cannonball Loader's Grips",                 sources = { [14]=62825, [15]=62827, [16]=67238 } },
                { id = 113944, slot = "Legs",     name = "Legguards of the Stampede",                 sources = { [14]=62818, [15]=62820, [16]=67275 } },
                { id = 116223, slot = "Legs",     name = "Legguards of the Unstoppable Charge",       sources = { [17]=66894 } },
                { id = 116048, slot = "Legs",     name = "Rylakk-Rider's Legguards",                  sources = { [17]=66942 } },
                { id = 113946, slot = "Off-hand", name = "Heart of the Clefthoof",                    sources = { [14]=62822, [15]=62823, [16]=62824 } },
                { id = 113939, slot = "Two-Hand", name = "Tal'rak, Bloody Skull of the Thunderlords", sources = { [14]=62806, [15]=62807, [16]=62808 } },
                { id = 113950, slot = "Waist",    name = "Ironcrusher's Collar",                      sources = { [14]=62828, [15]=62830, [16]=67183 } },
                { id = 113941, slot = "Waist",    name = "Seeking Ember Girdle",                      sources = { [14]=62809, [15]=62811, [16]=67219 } },
                { id = 113943, slot = "Wrist",    name = "Bracers of the Wolf's Cunning",             sources = { [14]=62815, [15]=62817, [16]=67203 } },
    { id = 116038, slot = "Wrist",               name = "Beastmaster's Iron Bracers",                    sources = { [17]=66916 } },
    { id = 116262, slot = "Waist",               name = "Waistplate of Soothed Beasts",                  sources = { [17]=66886 } },
    { id = 116306, slot = "Back",                name = "Dreaded Wing",                                  sources = { [17]=66833 } },
            },
        },
        {
            index              = 4,
            name               = "Gruul",
            journalEncounterID = 1161,
            aliases            = {},
            achievements       = {
                { id = 8978, name = "The Iron Price", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113873, slot = "Back",     name = "Gronn-Stitched Greatcloak",     sources = { [14]=62677, [15]=66796, [16]=66797 } },
                { id = 120078, slot = "Back",     name = "Runescribed Gronncloak",        sources = { [14]=67782, [15]=67783, [16]=67784 } },
                { id = 113870, slot = "Chest",    name = "Vest of Forceful Fury",         sources = { [14]=62671, [15]=62673, [16]=67117 } },
                { id = 113864, slot = "Feet",     name = "Cavedweller's Climbers",        sources = { [14]=62659, [15]=62661, [16]=67252 } },
                { id = 113868, slot = "Head",     name = "Flare-Eyed Hood",               sources = { [14]=62665, [15]=62666, [16]=62667 } },
                { id = 113863, slot = "Head",     name = "Gronn-Skin Crown",              sources = { [14]=62656, [15]=62658, [16]=67270 } },
                { id = 113867, slot = "Shoulder", name = "Spaulders of Reflected Stone",  sources = { [14]=62662, [15]=62664, [16]=67198 } },
                { id = 113869, slot = "Two-Hand", name = "Inferno-Flame Staff",           sources = { [14]=62668, [15]=62669, [16]=62670 } },
                { id = 116039, slot = "Waist",    name = "Delver's Belt",                 sources = { [17]=66917 } },
                { id = 116009, slot = "Waist",    name = "Rockfall Girdle",               sources = { [17]=66965 } },
                { id = 113862, slot = "Weapon",   name = "Taner's Terrible Spine",        sources = { [14]=62653, [15]=62654, [16]=62655 } },
                { id = 113871, slot = "Wrist",    name = "Bracers of Martial Perfection", sources = { [14]=62674, [15]=62676, [16]=67293 } },
    { id = 116229, slot = "Head",                name = "Gaze of the Gronn Killer",                      sources = { [17]=66903 } },
    { id = 116045, slot = "Chest",               name = "Spelunker's Chestguard",                        sources = { [17]=66934 } },
    { id = 116018, slot = "Legs",                name = "Cave Smasher Leggings",                         sources = { [17]=66877 } },
    { id = 116242, slot = "Wrist",               name = "Gruul's Smallest Shackles",                     sources = { [17]=66883 } },
    { id = 116307, slot = "Back",                name = "Cloak of Unfulfilled Potential",                sources = { [17]=66836 } },
    { id = 116216, slot = "Hands",               name = "Grips of Shackled Power",                       sources = { [17]=66908 } },
            },
        },
        {
            index              = 5,
            name               = "Flamebender Ka'graz",
            journalEncounterID = 1123,
            aliases            = {},
            achievements       = {
                { id = 8929, name = "The Steel Has Been Brought", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113916, slot = "Back",     name = "Charbreath Firecloak",            sources = { [14]=62761, [15]=66808, [16]=66809 } },
                { id = 120389, slot = "Chest",    name = "Ashlink Hauberk",                 sources = { [17]=68051 } },
                { id = 120393, slot = "Chest",    name = "Blacksteel Chestplate",           sources = { [17]=68067 } },
                { id = 120375, slot = "Chest",    name = "Ebonflame Robes",                 sources = { [17]=67996 } },
                { id = 120380, slot = "Chest",    name = "Sootfur Harness",                 sources = { [17]=68013 } },
                { id = 113919, slot = "Feet",     name = "Treads of Rekindled Flames",      sources = { [14]=62765, [15]=62767, [16]=67202 } },
                { id = 113925, slot = "Hands",    name = "Flamefury Gauntlets",             sources = { [14]=62777, [15]=62779, [16]=67163 } },
                { id = 113915, slot = "Hands",    name = "Grips of Rekindling",             sources = { [14]=62758, [15]=62760, [16]=67273 } },
                { id = 113921, slot = "Legs",     name = "Firestorm Legplates",             sources = { [14]=62771, [15]=62773, [16]=67162 } },
                { id = 113914, slot = "Legs",     name = "Leggings of the Molten Torrent",  sources = { [14]=62755, [15]=62756, [16]=62757 } },
                { id = 113924, slot = "Shoulder", name = "Flamebender's Shoulderguards",    sources = { [14]=62774, [15]=62776, [16]=67236 } },
                { id = 113913, slot = "Two-Hand", name = "Ka'graz's Burning Blade",         sources = { [14]=62752, [15]=62753, [16]=62754 } },
                { id = 116047, slot = "Waist",    name = "Bloodsteel Warbelt",              sources = { [17]=66935 } },
                { id = 116264, slot = "Waist",    name = "Cinderhide Belt",                 sources = { [17]=66911 } },
                { id = 113920, slot = "Weapon",   name = "Dagger of Blazing Radiance",      sources = { [14]=62768, [15]=62769, [16]=62770 } },
                { id = 113918, slot = "Weapon",   name = "Molten Edge Eviscerator",         sources = { [14]=62762, [15]=62763, [16]=62764 } },
                -- Tier (11 items)
                { id = 115582, slot = "Chest",    name = "Blackhand's Chestguard",          sources = { [14]=64472, [15]=67170, [16]=67171 }, classes = { 1 } },
                { id = 115566, slot = "Chest",    name = "Battleplate of Guiding Light",    sources = { [14]=64456, [15]=67299, [16]=67300 }, classes = { 2 } },
                { id = 115548, slot = "Chest",    name = "Rylakstalker's Tunic",            sources = { [14]=64438, [15]=67211, [16]=67212 }, classes = { 3 } },
                { id = 115570, slot = "Chest",    name = "Poisoner's Tunic",                sources = { [14]=64460, [15]=67313, [16]=67314 }, classes = { 4 } },
                { id = 115560, slot = "Chest",    name = "Soul Priest's Raiment",           sources = { [14]=64450, [15]=67257, [16]=67258 }, classes = { 5 } },
                { id = 115537, slot = "Chest",    name = "Ogreskull Boneplate Breastplate", sources = { [14]=64427, [15]=67188, [16]=67189 }, classes = { 6 } },
                { id = 115577, slot = "Chest",    name = "Windspeaker's Tunic",             sources = { [14]=64467, [15]=67283, [16]=67284 }, classes = { 7 } },
                { id = 115550, slot = "Chest",    name = "Arcanoshatter Robes",             sources = { [14]=64440, [15]=67102, [16]=67103 }, classes = { 8 } },
                { id = 115588, slot = "Chest",    name = "Shadow Council's Robes",          sources = { [14]=64478, [15]=67229, [16]=67230 }, classes = { 9 } },
                { id = 115558, slot = "Chest",    name = "Vest of the Somber Gaze",         sources = { [14]=64448, [15]=67246, [16]=67247 }, classes = { 10 } },
                { id = 115540, slot = "Chest",    name = "Living Wood Raiment",             sources = { [14]=64430, [15]=67120, [16]=67121 }, classes = { 11 } },
    { id = 116384, slot = "Off-hand",            name = "Steelbringer's Polished Shield",                sources = { [17]=65258 } },
    { id = 116385, slot = "Weapon",              name = "Magma Monsoon Mace",                            sources = { [17]=65261 } },
    { id = 116226, slot = "Wrist",               name = "Scorched Gauntlet Liners",                      sources = { [17]=66901 } },
    { id = 116040, slot = "Legs",                name = "Magma-Mauled Leggings",                         sources = { [17]=66939 } },
    { id = 116011, slot = "Feet",                name = "Fixated Treads",                                sources = { [17]=66967 } },
    { id = 116245, slot = "Head",                name = "Maw of Charring Breath",                        sources = { [17]=66958 } },
    { id = 116253, slot = "Hands",               name = "Lava-Crushing Grips",                           sources = { [17]=66950 } },
            },
        },
        {
            index              = 6,
            name               = "Operator Thogar",
            journalEncounterID = 1147,
            aliases            = {},
            achievements       = {
                { id = 8982, name = "There's Always a Bigger Train", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113958, slot = "Chest",            name = "Woundsear Robes",                 sources = { [14]=62846, [15]=62848, [16]=67256 } },
                { id = 113961, slot = "Feet",             name = "Iron Bellow Sabatons",            sources = { [14]=62852, [15]=62854, [16]=67164 } },
                { id = 113954, slot = "Feet",             name = "Railwalker's Ratcheted Boots",    sources = { [14]=62837, [15]=62839, [16]=67276 } },
                { id = 113960, slot = "Held In Off-hand", name = "Engine-Stoker's Lantern",         sources = { [14]=62849, [15]=62850, [16]=62851 } },
                { id = 120388, slot = "Shoulder",         name = "Ashlink Pauldrons",               sources = { [17]=68047 } },
                { id = 120395, slot = "Shoulder",         name = "Blacksteel Shoulderplates",       sources = { [17]=68075 } },
                { id = 120376, slot = "Shoulder",         name = "Ebonflame Spaulders",             sources = { [17]=68000 } },
                { id = 120381, slot = "Shoulder",         name = "Sootfur Shoulderguards",          sources = { [17]=68019 } },
                { id = 116013, slot = "Shoulder",         name = "Spaulders of Soothing Flame",     sources = { [17]=67959 } },
                { id = 113953, slot = "Two-Hand",         name = "Thogar's Control Rod",            sources = { [14]=62834, [15]=62835, [16]=62836 } },
                { id = 113964, slot = "Waist",            name = "Conductor's Multi-Pocket Girdle", sources = { [14]=62858, [15]=62860, [16]=67311 } },
                { id = 113955, slot = "Waist",            name = "Grenadier's Belt",                sources = { [14]=62840, [15]=62842, [16]=67204 } },
                { id = 116049, slot = "Waist",            name = "Raider's Spikeholder Belt",       sources = { [17]=66943 } },
                { id = 116265, slot = "Waist",            name = "Sniper's Ammo Belt",              sources = { [17]=66904 } },
                { id = 116252, slot = "Waist",            name = "Waistplate of Obliteration",      sources = { [17]=66961 } },
                { id = 113956, slot = "Wrist",            name = "Bracers of Enkindled Power",      sources = { [14]=62843, [15]=62845, [16]=67220 } },
                { id = 113962, slot = "Wrist",            name = "Squire's Electroplated Bracers",  sources = { [14]=62855, [15]=62856, [16]=67119 } },
                -- Tier (11 items)
                { id = 115581, slot = "Shoulder",         name = "Blackhand's Shoulderguards",      sources = { [14]=64471, [15]=67168, [16]=67169 }, classes = { 1 } },
                { id = 115565, slot = "Shoulder",         name = "Pauldrons of Guiding Light",      sources = { [14]=64455, [15]=67297, [16]=67298 }, classes = { 2 } },
                { id = 115547, slot = "Shoulder",         name = "Rylakstalker's Spaulders",        sources = { [14]=64437, [15]=67209, [16]=67210 }, classes = { 3 } },
                { id = 115574, slot = "Shoulder",         name = "Poisoner's Spaulders",            sources = { [14]=64464, [15]=67321, [16]=67322 }, classes = { 4 } },
                { id = 115561, slot = "Shoulder",         name = "Soul Priest's Shoulderguards",    sources = { [14]=64451, [15]=67259, [16]=67260 }, classes = { 5 } },
                { id = 115536, slot = "Shoulder",         name = "Ogreskull Boneplate Pauldrons",   sources = { [14]=64426, [15]=67186, [16]=67187 }, classes = { 6 } },
                { id = 115576, slot = "Shoulder",         name = "Windspeaker's Mantle",            sources = { [14]=64466, [15]=67281, [16]=67282 }, classes = { 7 } },
                { id = 115551, slot = "Shoulder",         name = "Arcanoshatter Mantle",            sources = { [14]=64441, [15]=67104, [16]=67105 }, classes = { 8 } },
                { id = 115589, slot = "Shoulder",         name = "Shadow Council's Mantle",         sources = { [14]=64479, [15]=67231, [16]=67232 }, classes = { 9 } },
                { id = 115559, slot = "Shoulder",         name = "Mantle of the Somber Gaze",       sources = { [14]=64449, [15]=67248, [16]=67249 }, classes = { 10 } },
                { id = 115544, slot = "Shoulder",         name = "Living Wood Spaulders",           sources = { [14]=64434, [15]=67128, [16]=67129 }, classes = { 11 } },
    { id = 116388, slot = "Ranged",              name = "Crack-Shot Longrifle",                          sources = { [17]=65270 } },
    { id = 116389, slot = "Two-Hand",            name = "Thogar's Imperialistic Spire",                  sources = { [17]=65273 } },
    { id = 116014, slot = "Hands",               name = "Grips of Cauterization",                        sources = { [17]=66968 } },
    { id = 116239, slot = "Legs",                name = "Gunnery Sergeant's Legplates",                  sources = { [17]=66881 } },
    { id = 116304, slot = "Back",                name = "Deadshot Longcloak",                            sources = { [17]=66842 } },
            },
        },
        {
            index              = 7,
            name               = "The Blast Furnace",
            journalEncounterID = 1154,
            aliases            = { "Blast Furnace" },
            achievements       = {
                { id = 8930, name = "Ya, We've Got Time...", meta = true, soloable = "yes" },
            },
            soloTip            = "You have to destroy the blast doors on both sides of the furnace. Go to one side, and let engineers come to you. Kill them, pick up their bombs, and use them by the door until the door \"dies\". Repeat process on the other side. After both doors are down, take down the elemental.",
            loot = {
                { id = 113895, slot = "Feet",     name = "Furnace Tender's Treads",       sources = { [14]=62719, [15]=62721, [16]=67234 } },
                { id = 113888, slot = "Feet",     name = "Slagstomper Treads",            sources = { [14]=62710, [15]=62712, [16]=67200 } },
                { id = 116241, slot = "Hands",    name = "Gauntlets of Electrocution",    sources = { [17]=66882 } },
                { id = 116041, slot = "Hands",    name = "Grips of the Ruptured Furnace", sources = { [17]=66932 } },
                { id = 113891, slot = "Head",     name = "Blast-Proof Cowl",              sources = { [14]=62713, [15]=62715, [16]=67271 } },
                { id = 113894, slot = "Head",     name = "Lava-Dipped Greathelm",         sources = { [14]=62716, [15]=62718, [16]=67161 } },
                { id = 120385, slot = "Legs",     name = "Ashlink Legguards",             sources = { [17]=68035 } },
                { id = 120391, slot = "Legs",     name = "Blacksteel Legplates",          sources = { [17]=68059 } },
                { id = 120377, slot = "Legs",     name = "Ebonflame Leggings",            sources = { [17]=68004 } },
                { id = 116214, slot = "Legs",     name = "Raging Pyroclasm Leggings",     sources = { [17]=66907 } },
                { id = 120379, slot = "Legs",     name = "Sootfur Legwraps",              sources = { [17]=68011 } },
                { id = 113885, slot = "Ranged",   name = "Mouth of The Fury",             sources = { [14]=62701, [15]=62702, [16]=62703 } },
                { id = 113886, slot = "Two-Hand", name = "Crescent of Living Magma",      sources = { [14]=62704, [15]=62705, [16]=62706 } },
                { id = 113887, slot = "Wrist",    name = "Bracers of Spattered Steel",    sources = { [14]=62707, [15]=62709, [16]=67254 } },
                { id = 113896, slot = "Wrist",    name = "Fleshmelter Bracers",           sources = { [14]=62722, [15]=62724, [16]=67180 } },
                -- Tier (11 items)
                { id = 115580, slot = "Legs",     name = "Blackhand's Legguards",         sources = { [14]=64470, [15]=67166, [16]=67167 }, classes = { 1 } },
                { id = 115569, slot = "Legs",     name = "Legplates of Guiding Light",    sources = { [14]=64459, [15]=67305, [16]=67306 }, classes = { 2 } },
                { id = 115546, slot = "Legs",     name = "Rylakstalker's Legguards",      sources = { [14]=64436, [15]=67207, [16]=67208 }, classes = { 3 } },
                { id = 115573, slot = "Legs",     name = "Poisoner's Legguards",          sources = { [14]=64463, [15]=67319, [16]=67320 }, classes = { 4 } },
                { id = 115564, slot = "Legs",     name = "Soul Priest's Leggings",        sources = { [14]=64454, [15]=67265, [16]=67266 }, classes = { 5 } },
                { id = 115535, slot = "Legs",     name = "Ogreskull Boneplate Greaves",   sources = { [14]=64425, [15]=67184, [16]=67185 }, classes = { 6 } },
                { id = 115575, slot = "Legs",     name = "Windspeaker's Legwraps",        sources = { [14]=64465, [15]=67279, [16]=67280 }, classes = { 7 } },
                { id = 115554, slot = "Legs",     name = "Arcanoshatter Leggings",        sources = { [14]=64444, [15]=67110, [16]=67111 }, classes = { 8 } },
                { id = 115587, slot = "Legs",     name = "Shadow Council's Leggings",     sources = { [14]=64477, [15]=67227, [16]=67228 }, classes = { 9 } },
                { id = 115557, slot = "Legs",     name = "Legwraps of the Somber Gaze",   sources = { [14]=64447, [15]=67244, [16]=67245 }, classes = { 10 } },
                { id = 115543, slot = "Legs",     name = "Living Wood Legguards",         sources = { [14]=64433, [15]=67126, [16]=67127 }, classes = { 11 } },
    { id = 116004, slot = "Head",                name = "Pyroclastic Hood",                              sources = { [17]=66964 } },
    { id = 116228, slot = "Shoulder",            name = "Spaulders of Tempered Fury",                    sources = { [17]=66902 } },
    { id = 116037, slot = "Chest",               name = "Chest of Heaving Bellows",                      sources = { [17]=66915 } },
    { id = 116015, slot = "Wrist",               name = "Bracers of Searing Heat",                       sources = { [17]=66924 } },
    { id = 116379, slot = "Held In Off-hand",    name = "Flickering Lantern Wisp",                       sources = { [17]=65246 } },
    { id = 116382, slot = "Two-Hand",            name = "Spire of Pyroclastic Flame",                    sources = { [17]=65255 } },
            },
        },
        {
            index              = 8,
            name               = "Kromog",
            journalEncounterID = 1162,
            aliases            = { "Kromog, Legend of the Mountain" },
            achievements       = {
                { id = 8983, name = "Would You Give Me a Hand?", meta = true, soloable = "no" },
            },
            loot = {
                { id = 113929, slot = "Back",     name = "Cloak of Delving Secrets",          sources = { [14]=62789, [15]=66812, [16]=66813 } },
                { id = 113937, slot = "Back",     name = "Runefrenzy Greatcloak",             sources = { [14]=62805, [15]=66792, [16]=66793 } },
                { id = 116218, slot = "Chest",    name = "Chestguard of Allegorical Shadows", sources = { [17]=66898 } },
                { id = 116243, slot = "Chest",    name = "Chestplate of Runed Earth",         sources = { [17]=66957 } },
                { id = 116008, slot = "Chest",    name = "Robes of Living Earth",             sources = { [17]=66922 } },
                { id = 120387, slot = "Feet",     name = "Ashlink Treads",                    sources = { [17]=68043 } },
                { id = 120394, slot = "Feet",     name = "Blacksteel Greatboots",             sources = { [17]=68071 } },
                { id = 120378, slot = "Feet",     name = "Ebonflame Sandals",                 sources = { [17]=68007 } },
                { id = 113936, slot = "Feet",     name = "Sabatons of Fractal Earth",         sources = { [14]=62802, [15]=62804, [16]=67182 } },
                { id = 116222, slot = "Feet",     name = "Slam Jammers",                      sources = { [17]=66893 } },
                { id = 120383, slot = "Feet",     name = "Sootfur Stompers",                  sources = { [17]=68027 } },
                { id = 113933, slot = "Hands",    name = "Stonewarper Wraps",                 sources = { [14]=62793, [15]=62794, [16]=62795 } },
                { id = 113926, slot = "Off-hand", name = "Kromog's Protecting Palm",          sources = { [14]=62780, [15]=62781, [16]=62782 } },
                { id = 113928, slot = "Shoulder", name = "Earthripple Shoulderpads",          sources = { [14]=62786, [15]=62788, [16]=67218 } },
                { id = 113930, slot = "Waist",    name = "Earthgrasp Girdle",                 sources = { [14]=62790, [15]=62792, [16]=67274 } },
                { id = 113934, slot = "Weapon",   name = "Fang of the Earth",                 sources = { [14]=62796, [15]=62797, [16]=62798 } },
                { id = 113927, slot = "Weapon",   name = "Kromog's Brutal Fist",              sources = { [14]=62783, [15]=62784, [16]=62785 } },
                { id = 113935, slot = "Wrist",    name = "Bracers of Shattered Stalactites",  sources = { [14]=62799, [15]=62801, [16]=67237 } },
                -- Tier (11 items)
                { id = 115584, slot = "Head",     name = "Blackhand's Faceguard",             sources = { [14]=64474, [15]=67174, [16]=67175 }, classes = { 1 } },
                { id = 115568, slot = "Head",     name = "Helmet of Guiding Light",           sources = { [14]=64458, [15]=67303, [16]=67304 }, classes = { 2 } },
                { id = 115545, slot = "Head",     name = "Rylakstalker's Headguard",          sources = { [14]=64435, [15]=67205, [16]=67206 }, classes = { 3 } },
                { id = 115572, slot = "Head",     name = "Poisoner's Helmet",                 sources = { [14]=64462, [15]=67317, [16]=67318 }, classes = { 4 } },
                { id = 115563, slot = "Head",     name = "Soul Priest's Hood",                sources = { [14]=64453, [15]=67263, [16]=67264 }, classes = { 5 } },
                { id = 115539, slot = "Head",     name = "Ogreskull Boneplate Greathelm",     sources = { [14]=64429, [15]=67192, [16]=67193 }, classes = { 6 } },
                { id = 115579, slot = "Head",     name = "Windspeaker's Faceguard",           sources = { [14]=64469, [15]=67287, [16]=67288 }, classes = { 7 } },
                { id = 115553, slot = "Head",     name = "Arcanoshatter Hood",                sources = { [14]=64443, [15]=67108, [16]=67109 }, classes = { 8 } },
                { id = 115586, slot = "Head",     name = "Shadow Council's Hood",             sources = { [14]=64476, [15]=67225, [16]=67226 }, classes = { 9 } },
                { id = 115556, slot = "Head",     name = "Helm of the Somber Gaze",           sources = { [14]=64446, [15]=67242, [16]=67243 }, classes = { 10 } },
                { id = 115542, slot = "Head",     name = "Living Wood Headpiece",             sources = { [14]=64432, [15]=67124, [16]=67125 }, classes = { 11 } },
    { id = 116386, slot = "Off-hand",            name = "Earthbound Shield",                             sources = { [17]=65264 } },
    { id = 116035, slot = "Head",                name = "Rockbreaker Warcap",                            sources = { [17]=66913 } },
    { id = 116387, slot = "Two-Hand",            name = "Axe of the Stone Geyser",                       sources = { [17]=65267 } },
    { id = 116006, slot = "Hands",               name = "Thundersmash Gloves",                           sources = { [17]=66875 } },
    { id = 116044, slot = "Shoulder",            name = "Erupting Mantle",                               sources = { [17]=66933 } },
    { id = 116254, slot = "Wrist",               name = "Reverberating Bracers",                         sources = { [17]=66951 } },
            },
        },
        {
            index              = 9,
            name               = "The Iron Maidens",
            journalEncounterID = 1203,
            aliases            = {},
            achievements       = {
                { id = 8984, name = "Be Quick or Be Dead", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 113972, slot = "Back",   name = "Cloak of Sanguine Terror",       sources = { [14]=62877, [15]=66806, [16]=66807 } },
                { id = 113971, slot = "Back",   name = "Drape of the Dark Hunt",         sources = { [14]=62876, [15]=66810, [16]=66811 } },
                { id = 113977, slot = "Chest",  name = "Bloodsoaked Heart Protector",    sources = { [14]=62887, [15]=62889, [16]=67165 } },
                { id = 113974, slot = "Feet",   name = "Treads of the Dark Hunt",        sources = { [14]=62881, [15]=62883, [16]=67312 } },
                { id = 120386, slot = "Hands",  name = "Ashlink Gloves",                 sources = { [17]=68039 } },
                { id = 120392, slot = "Hands",  name = "Blacksteel Gauntlets",           sources = { [17]=68063 } },
                { id = 120374, slot = "Hands",  name = "Ebonflame Grips",                sources = { [17]=67992 } },
                { id = 116225, slot = "Hands",  name = "Gauntlets of Flickering Blades", sources = { [17]=66900 } },
                { id = 120384, slot = "Hands",  name = "Sootfur Gauntlets",              sources = { [17]=68031 } },
                { id = 116050, slot = "Head",   name = "Bombardeer's Targeting Helm",    sources = { [17]=66944 } },
                { id = 116220, slot = "Head",   name = "Grapeshot Hood",                 sources = { [17]=66899 } },
                { id = 113978, slot = "Head",   name = "Sorka's Nightshade Cowl",        sources = { [14]=62890, [15]=62892, [16]=67970 } },
                { id = 116263, slot = "Head",   name = "Vortex Plate Helm",              sources = { [17]=66953 } },
                { id = 116010, slot = "Legs",   name = "Incendiary Leggings",            sources = { [17]=66966 } },
                { id = 116051, slot = "Legs",   name = "Rogg's Earthen Legguards",       sources = { [17]=66918 } },
                { id = 113970, slot = "Legs",   name = "Turret Mechanic's Legwraps",     sources = { [14]=62873, [15]=62875, [16]=67221 } },
                { id = 113966, slot = "Ranged", name = "Gar'an's Brutal Spearlauncher",  sources = { [14]=62864, [15]=62865, [16]=62866 } },
                { id = 113967, slot = "Waist",  name = "Deckhand's Rope Belt",           sources = { [14]=62867, [15]=62868, [16]=62869 } },
                { id = 113976, slot = "Waist",  name = "Uktar's Belt of Chiming Rings",  sources = { [14]=62884, [15]=62886, [16]=67295 } },
                { id = 113973, slot = "Weapon", name = "Koloch Na, the Blood Feast",     sources = { [14]=62878, [15]=62879, [16]=62880 } },
                { id = 113965, slot = "Weapon", name = "Sorka's Chainfist",              sources = { [14]=62861, [15]=62862, [16]=62863 } },
                { id = 113968, slot = "Wrist",  name = "Bloodwhirl Bracers",             sources = { [14]=62870, [15]=62872, [16]=67277 } },
                -- Tier (11 items)
                { id = 115583, slot = "Hands",  name = "Blackhand's Handguards",         sources = { [14]=64473, [15]=67172, [16]=67173 }, classes = { 1 } },
                { id = 115567, slot = "Hands",  name = "Gauntlets of Guiding Light",     sources = { [14]=64457, [15]=67301, [16]=67302 }, classes = { 2 } },
                { id = 115549, slot = "Hands",  name = "Rylakstalker's Gloves",          sources = { [14]=64439, [15]=67213, [16]=67214 }, classes = { 3 } },
                { id = 115571, slot = "Hands",  name = "Poisoner's Gloves",              sources = { [14]=64461, [15]=67315, [16]=67316 }, classes = { 4 } },
                { id = 115562, slot = "Hands",  name = "Soul Priest's Gloves",           sources = { [14]=64452, [15]=67261, [16]=67262 }, classes = { 5 } },
                { id = 115538, slot = "Hands",  name = "Ogreskull Boneplate Gauntlets",  sources = { [14]=64428, [15]=67190, [16]=67191 }, classes = { 6 } },
                { id = 115578, slot = "Hands",  name = "Windspeaker's Handwraps",        sources = { [14]=64468, [15]=67285, [16]=67286 }, classes = { 7 } },
                { id = 115552, slot = "Hands",  name = "Arcanoshatter Gloves",           sources = { [14]=64442, [15]=67106, [16]=67107 }, classes = { 8 } },
                { id = 115585, slot = "Hands",  name = "Shadow Council's Gloves",        sources = { [14]=64475, [15]=67223, [16]=67224 }, classes = { 9 } },
                { id = 115555, slot = "Hands",  name = "Handwraps of the Somber Gaze",   sources = { [14]=64445, [15]=67240, [16]=67241 }, classes = { 10 } },
                { id = 115541, slot = "Hands",  name = "Living Wood Grips",              sources = { [14]=64431, [15]=67122, [16]=67123 }, classes = { 11 } },
    { id = 116390, slot = "Ranged",              name = "Battle Medic's Wand",                           sources = { [17]=67149 } },
    { id = 116017, slot = "Waist",               name = "Deckhand's Cord",                               sources = { [17]=66925 } },
    { id = 116250, slot = "Feet",                name = "Impaler's Greatboots",                          sources = { [17]=66959 } },
            },
        },
        {
            index              = 10,
            name               = "Blackhand",
            journalEncounterID = 959,
            aliases            = {},
            achievements       = {
                { id = 8952, name = "Ashes, Ashes...", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 113982, slot = "Chest",    name = "Chestguard of the Siegemaker",   sources = { [14]=62902, [15]=62904, [16]=67278 } },
                { id = 120390, slot = "Head",     name = "Ashlink Coif",                   sources = { [17]=68055 } },
                { id = 120396, slot = "Head",     name = "Blacksteel Casque",              sources = { [17]=68079 } },
                { id = 120373, slot = "Head",     name = "Ebonflame Hood",                 sources = { [17]=67988 } },
                { id = 113981, slot = "Head",     name = "Slagbomber's Hood",              sources = { [14]=62899, [15]=62901, [16]=67222 } },
                { id = 120382, slot = "Head",     name = "Sootfur Cap",                    sources = { [17]=68023 } },
                { id = 113989, slot = "Legs",     name = "Shattering Smash Leggings",      sources = { [14]=62908, [15]=62910, [16]=67239 } },
                { id = 116036, slot = "Shoulder", name = "Deathmark Shoulderguards",       sources = { [17]=66914 } },
                { id = 116005, slot = "Shoulder", name = "Forgestoker's Shoulderpads",     sources = { [17]=66921 } },
                { id = 113990, slot = "Shoulder", name = "Overdriven Spaulders",           sources = { [14]=62911, [15]=62913, [16]=67296 } },
                { id = 116219, slot = "Shoulder", name = "Spaulders of Erupting Iron",     sources = { [17]=66909 } },
                { id = 116244, slot = "Shoulder", name = "Spaulders of the Iron Crucible", sources = { [17]=66949 } },
                { id = 113988, slot = "Two-Hand", name = "Blackhand Doomstaff",            sources = { [14]=62905, [15]=62906, [16]=62907 } },
                { id = 113979, slot = "Two-Hand", name = "The Black Hand",                 sources = { [14]=62893, [15]=62895, [16]=62894 } },
                { id = 113980, slot = "Weapon",   name = "Iron Soldier's Saber",           sources = { [14]=62896, [15]=62897, [16]=62898 } },
    { id = 116224, slot = "Waist",               name = "Bomb-Carrier's Harness",                        sources = { [17]=66895 } },
    { id = 116391, slot = "Two-Hand",            name = "Blackhand Forgehammer",                         sources = { [17]=93722 } },
    { id = 116393, slot = "Weapon",              name = "Dagger of the Shattered Crucible",              sources = { [17]=93723 } },
    { id = 116042, slot = "Feet",                name = "Ram-Carrier's Treads",                          sources = { [17]=66940 } },
    { id = 116022, slot = "Hands",               name = "Flamestoker Wraps",                             sources = { [17]=66927 } },
    { id = 116251, slot = "Legs",                name = "Ironshatter Legplates",                         sources = { [17]=66960 } },
            },
            specialLoot = {
                { id = 116660, kind = "mount",    name = "Ironhoof Destroyer",          mythicOnly = true },
                { id = 138809, kind = "illusion", name = "Illusion: Mark of Blackrock", sourceID = 5336 },
            },
        },
    },

    lfrWings = {
        -- Wing 1 -- Slagworks: Oregorger, Gruul, The Blast Furnace
        -- (standard routing steps 1-3). Notes and routing imported
        -- verbatim from the standard route.
        [1361] = {
            name   = "Slagworks",
            bosses = { 1, 4, 7 },
            lockoutBits = { [1] = 8, [4] = 3, [7] = 2 },
            routing = {
                -- 1. Oregorger
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 1,
                    title     = "Oregorger",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 598 },
                            kind    = "path",
                            note    = "After zoning in, follow the path to the right and make your way down a spiral ramp.",
                            minNote = "Right to ramp",
                            points  = {
                                { 0.410, 0.895 },
                                { 0.409, 0.635 },
                                { 0.457, 0.564 },
                                { 0.512, 0.544 },
                                { 0.556, 0.564 },
                                { 0.564, 0.608 },
                                { 0.564, 0.651 },
                                { 0.542, 0.682 },
                                { 0.508, 0.688 },
                            },
                        },
                        {
                            when    = { mapID = 597 },
                            kind    = "path",
                            note    = "Approach the bridge and take a left. Follow the path to ^Oregorger^. Clear trash to spawn the boss.",
                            minNote = "Path to Oregorger",
                            points  = {
                                { 0.624, 0.533 },
                                { 0.550, 0.533 },
                                { 0.549, 0.828 },
                                { 0.522, 0.836 },
                                { 0.456, 0.838 },
                            },
                        },
                    },
                },

                -- 4. Gruul
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 4,
                    title     = "Gruul",
                    requires  = { 1 },
                    segments  = {
                        {
                            when    = { mapID = 597 },
                            kind    = "path",
                            note    = "After killing ^Oregorger^, leave his area the way you came and follow the path all the way north to find ^Gruul^.",
                            minNote = "North to Gruul",
                            points  = {
                                { 0.469, 0.839 },
                                { 0.533, 0.835 },
                                { 0.553, 0.792 },
                                { 0.546, 0.585 },
                                { 0.546, 0.483 },
                                { 0.554, 0.442 },
                                { 0.564, 0.288 },
                                { 0.536, 0.249 },
                                { 0.449, 0.241 },
                            },
                        },
                    },
                },

                -- 7. The Blast Furnace
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 7,
                    title     = "The Blast Furnace",
                    requires  = { 4 },
                    segments  = {
                        {
                            when    = { mapID = 597 },
                            kind    = "path",
                            note    = "After killing ^Gruul^, backtrack to the bridge and go east. Follow the spiral down, then at the bottom go straight ahead to locate ^The Blast Furnace^.",
                            minNote = "Path to Blast Furnace",
                            points  = {
                                { 0.457, 0.244 },
                                { 0.557, 0.257 },
                                { 0.558, 0.340 },
                                { 0.547, 0.511 },
                                { 0.605, 0.513 },
                                { 0.605, 0.618 },
                                { 0.617, 0.643 },
                                { 0.643, 0.645 },
                                { 0.669, 0.639 },
                                { 0.683, 0.610 },
                                { 0.683, 0.576 },
                                { 0.669, 0.545 },
                                { 0.490, 0.541 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 2 -- The Black Forge: Hans'gar and Franzok, Flamebender
        -- Ka'graz, Kromog (LFR order). LFR drops the player on mapID 598
        -- (The Workshop); the standard route reaches Hans'gar from the
        -- Iron Maidens (not in this wing), so Hans'gar's approach is
        -- LFR-specific. Flamebender and Kromog chain from Hans'gar and
        -- import from standard.
        [1360] = {
            name   = "The Black Forge",
            bosses = { 2, 5, 8 },
            lockoutBits = { [2] = 5, [5] = 1, [8] = 10 },
            routing = {
                -- 2. Hans'gar and Franzok. Seg 1 is the LFR-specific
                -- zone-in walk from The Workshop (598) toward The Black
                -- Forge.
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 2,
                    title     = "Hans'gar and Franzok",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 598 },
                            kind    = "path",
                            note    = "After zoning in, take a left and head towards ^The Black Forge^. Take the elevator down.",
                            minNote = "Left to Elevator",
                            points  = {
                                { 0.408, 0.795 },
                                { 0.408, 0.625 },
                                { 0.334, 0.539 },
                                { 0.286, 0.535 },
                            },
                        },
                        {
                            when    = { mapID = 596 },
                            kind    = "path",
                            note    = "Once you reach the bottom of the elevator, take the southern path to reach ^Hans'gar and Franzok^. After a brief dialog, kill the trash to start the encounter.",
                            minNote = "South to Hans & Franz",
                            points  = {
                                { 0.472, 0.623 },
                                { 0.475, 0.660 },
                                { 0.474, 0.733 },
                            },
                        },
                    },
                },

                -- 5. Flamebender Ka'graz (standard seg verbatim)
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 5,
                    title     = "Flamebender Ka'graz",
                    requires  = { 2 },
                    segments  = {
                        {
                            when    = { mapID = 596 },
                            kind    = "path",
                            note    = "After killing ^Hans'gar and Franzok^, take the southern exit out of the room. Follow the path across the next room to reach ^Flamebender Ka'graz^.",
                            minNote = "Path to Ka'graz",
                            points  = {
                                { 0.474, 0.865 },
                                { 0.474, 0.914 },
                                { 0.439, 0.929 },
                                { 0.403, 0.911 },
                                { 0.399, 0.769 },
                                { 0.222, 0.768 },
                            },
                        },
                    },
                },

                -- 8. Kromog (standard seg verbatim)
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 8,
                    title     = "Kromog",
                    requires  = { 5 },
                    segments  = {
                        {
                            when    = { mapID = 596 },
                            kind    = "path",
                            note    = "After defeating ^Flamebender Ka'graz^, head slightly east and then follow the path north to reach ^Kromog^.",
                            minNote = "Path to Kromog",
                            points  = {
                                { 0.239, 0.764 },
                                { 0.309, 0.762 },
                                { 0.310, 0.699 },
                                { 0.328, 0.686 },
                                { 0.331, 0.469 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 3 -- Iron Assembly: Beastlord Darmac, Operator Thogar,
        -- The Iron Maidens (LFR order). LFR drops the player on mapID
        -- 598 (The Workshop); Darmac's entry is an LFR-specific zone-in
        -- walk toward Iron Assembly, then the standard 599 approach.
        -- Thogar and Iron Maidens chain from Darmac and import.
        [1362] = {
            name   = "Iron Assembly",
            bosses = { 3, 6, 9 },
            lockoutBits = { [3] = 6, [6] = 4, [9] = 7 },
            routing = {
                -- 3. Beastlord Darmac (LFR-specific 598 entry, then
                -- standard 599 seg)
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 3,
                    title     = "Beastlord Darmac",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 598 },
                            kind    = "path",
                            note    = "After zoning in, take the northeastern path towards the ^Iron Assembly^.",
                            minNote = "Northeast to Iron Assembly",
                            points  = {
                                { 0.409, 0.813 },
                                { 0.409, 0.635 },
                                { 0.493, 0.543 },
                                { 0.490, 0.495 },
                                { 0.511, 0.428 },
                                { 0.557, 0.425 },
                            },
                        },
                        {
                            when    = { mapID = 599 },
                            kind    = "path",
                            note    = "Inside ^Iron Assembly^, follow the path around to ^Beastlord Darmac^.",
                            minNote = "Path to Beastlord",
                            points  = {
                                { 0.453, 0.836 },
                                { 0.453, 0.716 },
                                { 0.578, 0.716 },
                            },
                        },
                    },
                },

                -- 6. Operator Thogar (standard seg verbatim)
                {
                    step      = 2,
                    priority  = 2,
                    bossIndex = 6,
                    title     = "Operator Thogar",
                    requires  = { 3 },
                    segments  = {
                        {
                            when    = { mapID = 599 },
                            kind    = "path",
                            note    = "After killing ^Beastlord Darmac^, leave the room and take a right. Follow the path north to reach ^Operator Thogar^. To open the gate and start the fight, kill trash on both platforms, then kill the gunners on the train that pulls up.",
                            minNote = "Path to Thogar",
                            points  = {
                                { 0.530, 0.712 },
                                { 0.453, 0.714 },
                                { 0.453, 0.435 },
                            },
                        },
                    },
                },

                -- 9. The Iron Maidens (standard segs verbatim)
                {
                    step      = 3,
                    priority  = 3,
                    bossIndex = 9,
                    title     = "The Iron Maidens",
                    requires  = { 6 },
                    segments  = {
                        {
                            when            = { mapID = 599 },
                            kind            = "poi",
                            highlightCircle = true,
                            mapLabel        = "Jump!",
                            mapLabelPos     = "above",
                            note            = "After defeating ^Operator Thogar^, jump down the hole marked on the east side of the room.",
                            minNote = "Hole to East",
                            points          = {
                                { 0.549, 0.489 },
                            },
                        },
                        {
                            when    = { mapID = 596 },
                            kind    = "path",
                            note    = "After landing, clear trash in the water, then move up the short ramp and clear the remaining trash to engage ^Iron Maidens^.",
                            minNote = "Trash then Maidens",
                            points  = {
                                { 0.776, 0.246 },
                                { 0.790, 0.246 },
                                { 0.821, 0.249 },
                            },
                        },
                    },
                },
            },
        },

        -- Wing 4 -- Blackhand's Crucible: Blackhand (final wing). Routed
        -- like the skip route (straight across the bridge to the
        -- elevator) but without the artifact-click pieces -- in LFR the
        -- bridge gate is already open, so the artifact POI and its
        -- instruction are omitted. Entry note is LFR-specific; elevator
        -- seg imports from the skip route.
        [1359] = {
            name   = "Blackhand's Crucible",
            bosses = { 10 },
            lockoutBits = { [10] = 9 },
            routing = {
                -- 10. Blackhand
                {
                    step      = 1,
                    priority  = 1,
                    bossIndex = 10,
                    title     = "Blackhand",
                    requires  = {},
                    segments  = {
                        {
                            when    = { mapID = 598 },
                            kind    = "path",
                            note    = "After zoning in, head straight ahead and follow the route across the bridge.",
                            minNote = "Cross Bridge Ahead",
                            points  = {
                                { 0.407, 0.741 },
                                { 0.413, 0.154 },
                                { 0.329, 0.150 },
                            },
                        },
                        {
                            when    = { mapID = 600 },
                            kind    = "path",
                            note    = "Take the elevator up and continue forward to reach ^Blackhand^.",
                            minNote = "Elevator to Blackhand",
                            points  = {
                                { 0.519, 0.922 },
                                { 0.484, 0.920 },
                                { 0.483, 0.389 },
                            },
                        },
                    },
                },
            },
        },
    },

    routing = {

        -- 1. Oregorger
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Oregorger",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 598 },
                    kind    = "path",
                    note    = "After zoning in, follow the path to the right and make your way down a spiral ramp.",
                    minNote = "Right to ramp",
                    points  = {
                        { 0.410, 0.895 },
                        { 0.409, 0.635 },
                        { 0.457, 0.564 },
                        { 0.512, 0.544 },
                        { 0.556, 0.564 },
                        { 0.564, 0.608 },
                        { 0.564, 0.651 },
                        { 0.542, 0.682 },
                        { 0.508, 0.688 },
                    },
                },
                {
                    when    = { mapID = 597 },
                    kind    = "path",
                    note    = "Approach the bridge and take a left. Follow the path to ^Oregorger^. Clear trash to spawn the boss.",
                    minNote = "Path to Oregorger",
                    points  = {
                        { 0.624, 0.533 },
                        { 0.550, 0.533 },
                        { 0.549, 0.828 },
                        { 0.522, 0.836 },
                        { 0.456, 0.838 },
                    },
                },
            },
        },

        -- 2. Gruul
        {
            step      = 2,
            priority  = 1,
            bossIndex = 4,
            title     = "Gruul",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 597 },
                    kind    = "path",
                    note    = "After killing ^Oregorger^, leave his area the way you came and follow the path all the way north to find ^Gruul^.",
                    minNote = "North to Gruul",
                    points  = {
                        { 0.469, 0.839 },
                        { 0.533, 0.835 },
                        { 0.553, 0.792 },
                        { 0.546, 0.585 },
                        { 0.546, 0.483 },
                        { 0.554, 0.442 },
                        { 0.564, 0.288 },
                        { 0.536, 0.249 },
                        { 0.449, 0.241 },
                    },
                },
            },
        },

        -- 3. The Blast Furnace
        {
            step      = 3,
            priority  = 1,
            bossIndex = 7,
            title     = "The Blast Furnace",
            requires  = { 4 },
            segments  = {
                {
                    when    = { mapID = 597 },
                    kind    = "path",
                    note    = "After killing ^Gruul^, backtrack to the bridge and go east. Follow the spiral down, then at the bottom go straight ahead to locate ^The Blast Furnace^.",
                    minNote = "Path to Blast Furnace",
                    points  = {
                        { 0.457, 0.244 },
                        { 0.557, 0.257 },
                        { 0.558, 0.340 },
                        { 0.547, 0.511 },
                        { 0.605, 0.513 },
                        { 0.605, 0.618 },
                        { 0.617, 0.643 },
                        { 0.643, 0.645 },
                        { 0.669, 0.639 },
                        { 0.683, 0.610 },
                        { 0.683, 0.576 },
                        { 0.669, 0.545 },
                        { 0.490, 0.541 },
                    },
                },
            },
        },

        -- 4. Beastlord Darmac
        {
            step      = 4,
            priority  = 1,
            bossIndex = 3,
            title     = "Beastlord Darmac",
            requires  = { 7 },
            segments  = {
                {
                    when    = { mapID = 597 },
                    kind    = "path",
                    note    = "After defeating ^The Blast Furnace^, go straight ahead back up the spiral ramp. When you reach the bridge area, take a right and go up another ramp towards the main lobby.",
                    minNote = "Return to Lobby",
                    points  = {
                        { 0.518, 0.543 },
                        { 0.625, 0.540 },
                        { 0.650, 0.543 },
                        { 0.666, 0.545 },
                        { 0.673, 0.560 },
                        { 0.676, 0.588 },
                        { 0.674, 0.614 },
                        { 0.665, 0.628 },
                        { 0.648, 0.638 },
                        { 0.628, 0.643 },
                        { 0.615, 0.632 },
                        { 0.610, 0.609 },
                        { 0.608, 0.591 },
                        { 0.607, 0.566 },
                        { 0.608, 0.527 },
                        { 0.620, 0.522 },
                        { 0.636, 0.521 },
                        { 0.653, 0.521 },
                        { 0.673, 0.521 },
                        { 0.685, 0.520 },
                    },
                },
                {
                    when    = { mapID = 598 },
                    kind    = "path",
                    note    = "Back in the main lobby, take the northeast exit towards ^Iron Assembly^.",
                    minNote = "Northeast to Iron Assembly",
                    points  = {
                        { 0.496, 0.684 },
                        { 0.546, 0.680 },
                        { 0.564, 0.651 },
                        { 0.566, 0.600 },
                        { 0.547, 0.555 },
                        { 0.495, 0.545 },
                        { 0.491, 0.486 },
                        { 0.512, 0.431 },
                        { 0.551, 0.425 },
                    },
                },
                {
                    when    = { mapID = 599 },
                    kind    = "path",
                    note    = "Inside ^Iron Assembly^, follow the path around to ^Beastlord Darmac^.",
                    minNote = "Path to Beastlord",
                    points  = {
                        { 0.453, 0.836 },
                        { 0.453, 0.716 },
                        { 0.578, 0.716 },
                    },
                },
            },
        },

        -- 5. Operator Thogar
        {
            step      = 5,
            priority  = 1,
            bossIndex = 6,
            title     = "Operator Thogar",
            requires  = { 3 },
            segments  = {
                {
                    when    = { mapID = 599 },
                    kind    = "path",
                    note    = "After killing ^Beastlord Darmac^, leave the room and take a right. Follow the path north to reach ^Operator Thogar^. To open the gate and start the fight, kill trash on both platforms, then kill the gunners on the train that pulls up.",
                    minNote = "Path to Thogar",
                    points  = {
                        { 0.530, 0.712 },
                        { 0.453, 0.714 },
                        { 0.453, 0.435 },
                    },
                },
            },
        },

        -- 6. The Iron Maidens
        {
            step      = 6,
            priority  = 1,
            bossIndex = 9,
            title     = "The Iron Maidens",
            requires  = { 6 },
            segments  = {
                {
                    when            = { mapID = 599 },
                    kind            = "poi",
                    highlightCircle = true,
                    mapLabel        = "Jump!",
                    mapLabelPos     = "above",
                    note            = "After defeating ^Operator Thogar^, jump down the hole marked on the east side of the room.",
                    minNote = "Hole to East",
                    points          = {
                        { 0.549, 0.489 },
                    },
                },
                {
                    when    = { mapID = 596 },
                    kind    = "path",
                    note    = "After landing, clear trash in the water, then move up the short ramp and clear the remaining trash to engage ^Iron Maidens^.",
                    minNote = "Trash then Maidens",
                    points  = {
                        { 0.776, 0.246 },
                        { 0.790, 0.246 },
                        { 0.821, 0.249 },
                    },
                },
            },
        },

        -- 7. Hans'gar and Franzok
        {
            step      = 7,
            priority  = 1,
            bossIndex = 2,
            title     = "Hans'gar and Franzok",
            requires  = { 9 },
            segments  = {
                {
                    when    = { mapID = 596 },
                    kind    = "path",
                    note    = "After defeating ^Iron Maidens^, take the southern path and keep to the left until you reach ^Hans'gar and Franzok^. After a brief dialog, kill the trash to start the encounter.",
                    minNote = "South to Hans & Franz",
                    points  = {
                        { 0.822, 0.338 },
                        { 0.787, 0.375 },
                        { 0.746, 0.382 },
                        { 0.690, 0.505 },
                        { 0.634, 0.505 },
                        { 0.605, 0.507 },
                        { 0.607, 0.550 },
                        { 0.586, 0.572 },
                        { 0.543, 0.579 },
                        { 0.470, 0.563 },
                        { 0.473, 0.732 },
                    },
                },
            },
        },

        -- 8. Flamebender Ka'graz
        {
            step      = 8,
            priority  = 1,
            bossIndex = 5,
            title     = "Flamebender Ka'graz",
            requires  = { 2 },
            segments  = {
                {
                    when    = { mapID = 596 },
                    kind    = "path",
                    note    = "After killing ^Hans'gar and Franzok^, take the southern exit out of the room. Follow the path across the next room to reach ^Flamebender Ka'graz^.",
                    minNote = "Path to Ka'graz",
                    points  = {
                        { 0.474, 0.865 },
                        { 0.474, 0.914 },
                        { 0.439, 0.929 },
                        { 0.403, 0.911 },
                        { 0.399, 0.769 },
                        { 0.222, 0.768 },
                    },
                },
            },
        },

        -- 9. Kromog
        {
            step      = 9,
            priority  = 1,
            bossIndex = 8,
            title     = "Kromog",
            requires  = { 5 },
            segments  = {
                {
                    when    = { mapID = 596 },
                    kind    = "path",
                    note    = "After defeating ^Flamebender Ka'graz^, head slightly east and then follow the path north to reach ^Kromog^.",
                    minNote = "Path to Kromog",
                    points  = {
                        { 0.239, 0.764 },
                        { 0.309, 0.762 },
                        { 0.310, 0.699 },
                        { 0.328, 0.686 },
                        { 0.331, 0.469 },
                    },
                },
            },
        },

        -- 10. Blackhand
        {
            step      = 10,
            priority  = 1,
            bossIndex = 10,
            title     = "Blackhand",
            requires  = { 8 },
            segments  = {
                {
                    when            = { mapID = 596 },
                    kind            = "path",
                    highlightCircle = true,
                    mapLabel        = "Elevator",
                    mapLabelPos     = "above",
                    note            = "After killing ^Kromog^, exit the room to the east and follow the path to the elevator.",
                    minNote = "East then Elevator",
                    points          = {
                        { 0.406, 0.438 },
                        { 0.479, 0.440 },
                        { 0.483, 0.364 },
                        { 0.538, 0.358 },
                        { 0.543, 0.411 },
                        { 0.557, 0.466 },
                        { 0.580, 0.503 },
                        { 0.608, 0.515 },
                        { 0.606, 0.555 },
                        { 0.574, 0.572 },
                        { 0.534, 0.572 },
                        { 0.504, 0.564 },
                        { 0.467, 0.572 },
                    },
                },
                {
                    when    = { mapID = 598 },
                    kind    = "path",
                    note    = "Once you reach the top of the elevator, follow the path to the north to reach ^The Crucible^.",
                    minNote = "North to The Crucible",
                    points  = {
                        { 0.332, 0.537 },
                        { 0.408, 0.482 },
                        { 0.411, 0.155 },
                        { 0.328, 0.149 },
                    },
                },
                {
                    when    = { mapID = 600 },
                    kind    = "path",
                    note    = "Take the elevator up and continue forward to reach ^Blackhand^.",
                    minNote = "Continue to Blackhand",
                    points  = {
                        { 0.519, 0.922 },
                        { 0.484, 0.920 },
                        { 0.483, 0.389 },
                    },
                },
            },
        },
    },

    skipToBoss = "Blackhand",


    skipRoute = {

        -- 1. Blackhand, reached from the entrance bridge by clicking the
        --    artifact to open the shortcut path (skips bosses 1-9).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 10,
            title     = "Blackhand",
            requires  = {},
            segments  = {
                {
                    when     = { mapID = 598, subZone = "The Workshop" },
                    kind     = "poi",
                    minNote  = "Click Artifact by Bridge",
                    mapLabel = "Click Artifact",
                    mapLabelPos = "below",
                    points   = {
                        { 0.365, 0.474 },
                    },
                },
                {
                    when    = { mapID = 598, subZone = "The Workshop" },
                    kind    = "path",
                    note    = "After zoning in, click ^Blackrock Artifact^ on either side of the bridge, and it will open the gate leading across the bridge. Go forward and follow the route across the bridge.",
                    minNote = "Click Artifact by Bridge",
                    points  = {
                        { 0.408, 0.482 },
                        { 0.411, 0.155 },
                        { 0.328, 0.149 },
                    },
                },
                {
                    when    = { mapID = 600 },
                    kind    = "path",
                    note    = "Take the elevator up and continue forward to reach ^Blackhand^.",
                    minNote = "Elevator to Blackhand",
                    points  = {
                        { 0.519, 0.922 },
                        { 0.484, 0.920 },
                        { 0.483, 0.389 },
                    },
                },
            },
        },

    },
}
