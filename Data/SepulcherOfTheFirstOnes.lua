-------------------------------------------------------------------------------
-- RetroRuns Data -- Sepulcher of the First Ones
-- Shadowlands, Patch 9.2  |  instanceID: 2481  |  journalInstanceID: 1195
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2481] = {
    instanceID        = 2481,
    journalInstanceID = 1195,
    name              = "Sepulcher of the First Ones",
    expansion         = "Shadowlands",
    patch             = "9.2",

    maps = {
        [2047] = "Immortal Hearth",
        [2048] = "Genesis Cradle",
        [2049] = "The Endless Foundry",
        [2050] = "Domination's Grasp",
        [2051] = "Heart of Eternity",
        [2052] = "The Grand Design",
        [2061] = "Ephemeral Plains",
    },

    -- Tier-set metadata. Each entry in tokenSources routes a per-class
    -- per-slot tier item to the boss that drops its token. Sepulcher's
    -- tier sets are 5 modules per group (Helm/Shoulder/Chest/Hand/Leg)
    -- for 4 groups (Mystic/Venerated/Zenith/Dreadful), distributed one
    -- slot per tier-dropping boss: Lihuvim drops Hands, Halondrus drops
    -- Legs, Anduin drops Helms, Lords of Dread drops Shoulders, Rygelon
    -- drops Chests.
    tierSets = {
        labels = {
            "Sepulcher of the First Ones",
        },
        tokenSources = {
            -- Mystic (Druid, Hunter, Mage)
            [191002] = 8,   -- Mystic Helm Module      -> Anduin Wrynn
            [191007] = 9,   -- Mystic Shoulder Module  -> Lords of Dread
            [191011] = 10,  -- Mystic Chest Module     -> Rygelon
            [191015] = 6,   -- Mystic Hand Module      -> Lihuvim, Principal Architect
            [191019] = 7,   -- Mystic Leg Module       -> Halondrus the Reclaimer
            -- Venerated (Paladin, Priest, Shaman)
            [191003] = 8,   -- Venerated Helm Module     -> Anduin Wrynn
            [191008] = 9,   -- Venerated Shoulder Module -> Lords of Dread
            [191012] = 10,  -- Venerated Chest Module    -> Rygelon
            [191016] = 6,   -- Venerated Hand Module     -> Lihuvim, Principal Architect
            [191020] = 7,   -- Venerated Leg Module      -> Halondrus the Reclaimer
            -- Zenith (Rogue, Warrior, Monk, Evoker)
            [191004] = 8,   -- Zenith Helm Module      -> Anduin Wrynn
            [191009] = 9,   -- Zenith Shoulder Module  -> Lords of Dread
            [191013] = 10,  -- Zenith Chest Module     -> Rygelon
            [191017] = 6,   -- Zenith Hand Module      -> Lihuvim, Principal Architect
            [191021] = 7,   -- Zenith Leg Module       -> Halondrus the Reclaimer
            -- Dreadful (Death Knight, Demon Hunter, Warlock)
            [191005] = 8,   -- Dreadful Helm Module      -> Anduin Wrynn
            [191006] = 9,   -- Dreadful Shoulder Module  -> Lords of Dread
            [191010] = 10,  -- Dreadful Chest Module     -> Rygelon
            [191014] = 6,   -- Dreadful Hand Module      -> Lihuvim, Principal Architect
            [191018] = 7,   -- Dreadful Leg Module       -> Halondrus the Reclaimer
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
        normal = 65764,
        heroic = 65763,
        mythic = 65762,
    },

    -- Glory meta-achievement for this raid. Completing all 11 per-boss
    -- criteria below awards the Shimmering Aurelid mount.
    gloryMeta = {
        id   = 15491,
        name = "Glory of the Sepulcher Raider",
        rewardItemID       = 187675,
        rewardMountSpellID = 359379,
        rewardName         = "Shimmering Aurelid",
    },

    bosses = {
        {
            index              = 1,
            name               = "Vigilant Guardian",
            journalEncounterID = 2458,
            aliases            = {},
            achievements = {
                { id = 15381, name = "Power ON", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 189774, slot = "Chest", name = "Fractured Colossus Core", sources = { [17]=167739, [14]=167738, [15]=167740, [16]=167741 } },
                { id = 189770, slot = "Feet", name = "Pre-Fabricated Footpads", sources = { [17]=167727, [14]=167726, [15]=167728, [16]=167729 } },
                { id = 189775, slot = "Head", name = "Helm of Solemn Vigil", sources = { [17]=167743, [14]=167742, [15]=167744, [16]=167745 } },
                { id = 189771, slot = "Legs", name = "Ancient Materium Tassets", sources = { [17]=167731, [14]=167730, [15]=167732, [16]=167733 } },
                { id = 189778, slot = "Legs", name = "Legplates of the Slumbering Sentinel", sources = { [17]=167755, [14]=167754, [15]=167756, [16]=167757 } },
                { id = 189584, slot = "Off-hand", name = "Sepulcher's Savior", sources = { [17]=167513, [14]=167510, [15]=167511, [16]=167512 } },
                { id = 189776, slot = "Waist", name = "Girdle of the First Gate", sources = { [17]=167747, [14]=167746, [15]=167748, [16]=167749 } },
                { id = 189779, slot = "Weapon", name = "Key to the Immortal Hearth", sources = { [17]=167760, [14]=167758, [15]=167761, [16]=167759 } },
                { id = 189777, slot = "Wrist", name = "Unstable Giant's Cuffs", sources = { [17]=167751, [14]=167750, [15]=167752, [16]=167753 } },
            },
            soloTip = "Kill trash to fill the energy bar. Three Unstable Cores will spawn. Carry all 3 (one at a time) to the boss and throw them to spawn the boss. On Mythic, boss spawns immediately for a quicker kill.",
        },
        {
            index              = 2,
            name               = "Skolex, the Insatiable Ravener",
            journalEncounterID = 2465,
            aliases            = { "Skolex" },
            achievements = {
                { id = 15401, name = "Wisdom Comes From the Desert", meta = true, soloable = "no" },
            },
            loot = {
                { id = 189815, slot = "Back", name = "Lurking Predator's Camouflage", sources = { [17]=168835, [14]=168834, [15]=168836, [16]=168837 } },
                { id = 189819, slot = "Off-hand", name = "Assimilated Safeguard", sources = { [17]=168848, [14]=168845, [15]=168846, [16]=168847 } },
                { id = 189810, slot = "Shoulder", name = "Ephemera-Softened Exoskeleton", sources = { [17]=167872, [14]=167871, [15]=167873, [16]=167874 } },
                { id = 189814, slot = "Shoulder", name = "Gluttonous Gardbrace", sources = { [17]=167888, [14]=167887, [15]=167889, [16]=167890 } },
                { id = 189813, slot = "Shoulder", name = "Mantle of the Broken Beast", sources = { [17]=167884, [14]=167883, [15]=167885, [16]=167886 } },
                { id = 189817, slot = "Two-Hand", name = "Rift-Scarred Solcrusher", sources = { [17]=167897, [14]=167895, [15]=167898, [16]=167896 } },
                { id = 189811, slot = "Waist", name = "Infinitely Collapsing Coil", sources = { [17]=167876, [14]=167875, [15]=167877, [16]=167878 } },
                { id = 189816, slot = "Weapon", name = "Crystallized Viscera Spike", sources = { [17]=167893, [14]=167891, [15]=167894, [16]=167892 } },
                { id = 189812, slot = "Wrist", name = "Devourer's Sandblown Hidebinders", sources = { [17]=167880, [14]=167879, [15]=167881, [16]=167882 } },
                { id = 189809, slot = "Wrist", name = "Skolex's Ravenous Skinguards", sources = { [17]=167868, [14]=167867, [15]=167869, [16]=167870 } },
            },
        },
        {
            index              = 3,
            name               = "Artificer Xy'mox",
            journalEncounterID = 2470,
            aliases            = { "Artificer Xymox" },
            achievements = {
                { id = 15398, name = "Xy Never, Ever Marks the Spot.", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 189823, slot = "Feet", name = "Stolen Nathrian Slippers", sources = { [17]=167909, [14]=167908, [15]=167910, [16]=167911 } },
                { id = 189824, slot = "Hands", name = "Unlicensed Hyperlight Handlers", sources = { [17]=167913, [14]=167912, [15]=167914, [16]=167915 } },
                { id = 189828, slot = "Ranged", name = "Xy Captain's Crossbow", sources = { [17]=167926, [14]=167924, [15]=167927, [16]=167925 } },
                { id = 189822, slot = "Shoulder", name = "Imported Illidari Spaulders", sources = { [17]=167905, [14]=167904, [15]=167906, [16]=167907 } },
                { id = 189826, slot = "Waist", name = "Enforcer's Containment Cinch", sources = { [17]=167921, [14]=167920, [15]=167922, [16]=167923 } },
                { id = 189821, slot = "Waist", name = "Illicit Artifact Holster", sources = { [17]=167901, [14]=167900, [15]=167902, [16]=167903 } },
                { id = 189829, slot = "Weapon", name = "Forerunner's Relic Blade", sources = { [17]=167930, [14]=167928, [15]=167931, [16]=167929 } },
                { id = 189830, slot = "Weapon", name = "Replicated Relic Blade", sources = { [17]=167934, [14]=167932, [15]=167935, [16]=167933 } },
                { id = 189825, slot = "Wrist", name = "Veiled Auctioneer's Vambraces", sources = { [17]=167917, [14]=167916, [15]=167918, [16]=167919 } },
            },
        },
        {
            index              = 4,
            name               = "Dausegne, the Fallen Oracle",
            journalEncounterID = 2459,
            aliases            = { "Dausegne" },
            achievements = {
                { id = 15397, name = "Four Ring Circus", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 189791, slot = "Back", name = "Drape of Mournful Melodies", sources = { [17]=168831, [14]=168830, [15]=168832, [16]=168833 } },
                { id = 189782, slot = "Chest", name = "Haunting Hymnal Robes", sources = { [17]=167767, [14]=167766, [15]=167768, [16]=167769 } },
                { id = 189785, slot = "Chest", name = "Oracle's Chromatic Cuirass", sources = { [17]=167779, [14]=167778, [15]=167780, [16]=167781 } },
                { id = 189786, slot = "Feet", name = "Song-Mad Sabatons", sources = { [17]=167783, [14]=167782, [15]=167784, [16]=167785 } },
                { id = 189787, slot = "Head", name = "Dausegne's Dissonant Halo", sources = { [17]=167787, [14]=167786, [15]=167788, [16]=167789 } },
                { id = 189790, slot = "Ranged", name = "Final Forte", sources = { [17]=167800, [14]=167798, [15]=167801, [16]=167799 } },
                { id = 189784, slot = "Shoulder", name = "Epaulets of the Ailing Aria", sources = { [17]=167775, [14]=167774, [15]=167776, [16]=167777 } },
                { id = 189773, slot = "Waist", name = "Clasp of Crooked Crescendos", sources = { [17]=167735, [14]=167734, [15]=167736, [16]=167737 } },
                { id = 189793, slot = "Waist", name = "Sash of the Silent Sonata", sources = { [17]=167804, [14]=167803, [15]=167805, [16]=167806 } },
                { id = 189807, slot = "Weapon", name = "Discordant Deathblade", sources = { [17]=167861, [14]=167859, [15]=167862, [16]=167860 } },
                { id = 189788, slot = "Weapon", name = "Maestro's Malice", sources = { [17]=167792, [14]=167790, [15]=167793, [16]=167791 } },
            },
        },
        {
            index              = 5,
            name               = "Prototype Pantheon",
            journalEncounterID = 2460,
            aliases            = { "Pantheon of Death" },
            achievements = {
                { id = 15400, name = "Where the Wild Corgis Are", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 189796, slot = "Chest", name = "Duty's Ascendant Breastplate", sources = { [17]=167816, [14]=167815, [15]=167817, [16]=167818 } },
                { id = 189794, slot = "Feet", name = "Boots of Ceaseless Conflict", sources = { [17]=167808, [14]=167807, [15]=167809, [16]=167810 } },
                { id = 189798, slot = "Feet", name = "Moccasins of Dreadful Absolution", sources = { [17]=167824, [14]=167823, [15]=167825, [16]=167826 } },
                { id = 189795, slot = "Feet", name = "Winter's Stampeding Striders", sources = { [17]=167812, [14]=167811, [15]=167813, [16]=167814 } },
                { id = 189783, slot = "Head", name = "Sin-Steeped Coronet", sources = { [17]=167771, [14]=167770, [15]=167772, [16]=167773 } },
                { id = 189799, slot = "Two-Hand", name = "Elysia's Promise", sources = { [17]=167829, [14]=167827, [15]=167830, [16]=167828 } },
                { id = 189800, slot = "Two-Hand", name = "Prelude to Pride", sources = { [17]=167833, [14]=167831, [15]=167834, [16]=167832 } },
                { id = 189789, slot = "Two-Hand", name = "Pursuit of Victory", sources = { [17]=167796, [14]=167794, [15]=167797, [16]=167795 } },
                { id = 189797, slot = "Wrist", name = "Wristwraps of Night's Renewal", sources = { [17]=167820, [14]=167819, [15]=167821, [16]=167822 } },
            },
            soloTip = "Clear surrounding trash to activate the bosses. Depending on difficulty, bosses will either spawn in pairs of 2, or all 4 together. Either way, the goal is to kill them around the same time.",
        },
        {
            index              = 6,
            name               = "Lihuvim, Principal Architect",
            journalEncounterID = 2461,
            aliases            = { "Lihuvim" },
            achievements = {
                { id = 15419, name = "The Protoform Matrix", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 189801, slot = "Head", name = "Ephemera-Charged Thinking Cap", sources = { [17]=167836, [14]=167835, [15]=167837, [16]=167838 } },
                { id = 189803, slot = "Legs", name = "Automa-Tender's Tights", sources = { [17]=167844, [14]=167843, [15]=167845, [16]=167846 } },
                { id = 189804, slot = "Waist", name = "Combustible Collaboration Girdle", sources = { [17]=167848, [14]=167847, [15]=167849, [16]=167850 } },
                { id = 189754, slot = "Weapon", name = "Genesis Lathe", sources = { [17]=167719, [14]=167717, [15]=167720, [16]=167718 } },
                { id = 189808, slot = "Weapon", name = "Lihuvim's Severing Scalpel", sources = { [17]=167865, [14]=167863, [15]=167866, [16]=167864 } },
                { id = 189805, slot = "Wrist", name = "Bracers of the Inscrutable Inventor", sources = { [17]=167852, [14]=167851, [15]=167853, [16]=167854 } },
                -- Tier (12 items)
                { id = 188937, slot = "Hands", name = "Grasps of the Infinite Infantry", sources = { [17]=166394, [14]=166393, [15]=166395, [16]=166396 }, classes = { 1 } },
                { id = 188928, slot = "Hands", name = "Luminous Chevalier's Gauntlets", sources = { [17]=166361, [14]=166360, [15]=166362, [16]=166363 }, classes = { 2 } },
                { id = 188861, slot = "Hands", name = "Godstalker's Gauntlets", sources = { [17]=166120, [14]=166119, [15]=166121, [16]=166122 }, classes = { 3 } },
                { id = 188907, slot = "Hands", name = "Soulblade Grasps", sources = { [17]=168566, [14]=166288, [15]=168567, [16]=168568 }, classes = { 4 } },
                { id = 188881, slot = "Hands", name = "Caress of the Empyrean", sources = { [17]=166194, [14]=166193, [15]=166195, [16]=166196 }, classes = { 5 } },
                { id = 188863, slot = "Hands", name = "Gauntlets of the First Eidolon", sources = { [17]=166125, [14]=166124, [15]=166126, [16]=166127 }, classes = { 6 } },
                { id = 188925, slot = "Hands", name = "Theurgic Starspeaker's Runebindings", sources = { [17]=166352, [14]=166351, [15]=166353, [16]=166354 }, classes = { 7 } },
                { id = 188845, slot = "Hands", name = "Erudite Occultist's Handwraps", sources = { [17]=166062, [14]=166061, [15]=166063, [16]=166064 }, classes = { 8 } },
                { id = 188890, slot = "Hands", name = "Grasps of the Demon Star", sources = { [17]=166230, [14]=166229, [15]=166231, [16]=166232 }, classes = { 9 } },
                { id = 188916, slot = "Hands", name = "Grips of the Grand Upwelling", sources = { [17]=168575, [14]=166318, [15]=168576, [16]=168577 }, classes = { 10 } },
                { id = 188853, slot = "Hands", name = "Handwraps of the Fixed Stars", sources = { [17]=168584, [14]=166090, [15]=168585, [16]=168586 }, classes = { 11 } },
                { id = 188898, slot = "Hands", name = "Mercurial Punisher's Grips", sources = { [17]=168590, [14]=166258, [15]=168591, [16]=168592 }, classes = { 12 } },
            },
        },
        {
            index              = 7,
            name               = "Halondrus the Reclaimer",
            journalEncounterID = 2463,
            aliases            = { "Halondrus" },
            achievements = {
                { id = 15386, name = "Shimmering Secrets", meta = true, soloable = "no" },
            },
            loot = {
                { id = 189831, slot = "Feet", name = "Ephemera-Stained Sollerets", sources = { [17]=167937, [14]=167936, [15]=167938, [16]=167939 } },
                { id = 189832, slot = "Feet", name = "Greatboots of the Roaming Goliath", sources = { [17]=167941, [14]=167940, [15]=167942, [16]=167943 } },
                { id = 189781, slot = "Held In Off-hand", name = "Obscured Fractal Prism", sources = { [17]=168844, [14]=168841, [15]=168842, [16]=168843 } },
                { id = 189834, slot = "Two-Hand", name = "Guardstaff of the Great Cycle", sources = { [17]=167950, [14]=167948, [15]=167951, [16]=167949 } },
                { id = 189806, slot = "Weapon", name = "Lightshatter Hatchet", sources = { [17]=167857, [14]=167855, [15]=167858, [16]=167856 } },
                -- Tier (12 items)
                { id = 188940, slot = "Legs", name = "Legplates of the Infinite Infantry", sources = { [17]=166406, [14]=166405, [15]=166407, [16]=166408 }, classes = { 1 } },
                { id = 188931, slot = "Legs", name = "Luminous Chevalier's Robes", sources = { [17]=166373, [14]=166372, [15]=166374, [16]=166375 }, classes = { 2 } },
                { id = 188860, slot = "Legs", name = "Godstalker's Tassets", sources = { [17]=166116, [14]=166115, [15]=166117, [16]=166118 }, classes = { 3 } },
                { id = 188902, slot = "Legs", name = "Soulblade Leggings", sources = { [17]=166272, [14]=166271, [15]=166273, [16]=166274 }, classes = { 4 } },
                { id = 188878, slot = "Legs", name = "Leggings of the Empyrean", sources = { [17]=166182, [14]=166181, [15]=166183, [16]=166184 }, classes = { 5 } },
                { id = 188866, slot = "Legs", name = "Chausses of the First Eidolon", sources = { [17]=166137, [14]=166136, [15]=166138, [16]=166139 }, classes = { 6 } },
                { id = 188924, slot = "Legs", name = "Theurgic Starspeaker's Tassets", sources = { [17]=166348, [14]=166347, [15]=166349, [16]=166350 }, classes = { 7 } },
                { id = 188842, slot = "Legs", name = "Erudite Occultist's Leggings", sources = { [17]=166050, [14]=166049, [15]=166051, [16]=166052 }, classes = { 8 } },
                { id = 188887, slot = "Legs", name = "Leggings of the Demon Star", sources = { [17]=166218, [14]=166217, [15]=166219, [16]=166220 }, classes = { 9 } },
                { id = 188911, slot = "Legs", name = "Legguards of the Grand Upwelling", sources = { [17]=166302, [14]=166301, [15]=166303, [16]=166304 }, classes = { 10 } },
                { id = 188848, slot = "Legs", name = "Leggings of the Fixed Stars", sources = { [17]=166074, [14]=166073, [15]=166075, [16]=166076 }, classes = { 11 } },
                { id = 188893, slot = "Legs", name = "Mercurial Punisher's Breeches", sources = { [17]=166242, [14]=166241, [15]=166243, [16]=166244 }, classes = { 12 } },
            },
        },
        {
            index              = 8,
            name               = "Anduin Wrynn",
            journalEncounterID = 2469,
            aliases            = { "Anduin" },
            achievements = {
                { id = 15399, name = "Coming to Terms", meta = false, soloable = "no" },
            },
            loot = {
                { id = 189835, slot = "Chest", name = "Anduin's Princely Vestments", sources = { [17]=167953, [14]=167952, [15]=167954, [16]=167955 } },
                { id = 189837, slot = "Waist", name = "King's Wolfheart Waistband", sources = { [17]=167961, [14]=167960, [15]=167962, [16]=167963 } },
                { id = 189840, slot = "Waist", name = "Remnant's Blasphemous Scourgebelt", sources = { [17]=167973, [14]=167972, [15]=167974, [16]=167975 } },
                { id = 189836, slot = "Wrist", name = "Wrists of the Wicked Star", sources = { [17]=167957, [14]=167956, [15]=167958, [16]=167959 } },
                -- Tier (12 items)
                { id = 188942, slot = "Head", name = "Gaze of the Infinite Infantry", sources = { [17]=166414, [14]=166413, [15]=166415, [16]=166416 }, classes = { 1 } },
                { id = 188933, slot = "Head", name = "Luminous Chevalier's Casque", sources = { [17]=166381, [14]=166380, [15]=166382, [16]=166383 }, classes = { 2 } },
                { id = 188859, slot = "Head", name = "Godstalker's Sallet", sources = { [17]=166112, [14]=166111, [15]=166113, [16]=166114 }, classes = { 3 } },
                { id = 188901, slot = "Head", name = "Soulblade Guise", sources = { [17]=166268, [14]=166267, [15]=166269, [16]=166270 }, classes = { 4 } },
                { id = 188880, slot = "Head", name = "Amice of the Empyrean", sources = { [17]=166190, [14]=166189, [15]=166191, [16]=166192 }, classes = { 5 } },
                { id = 188868, slot = "Head", name = "Visage of the First Eidolon", sources = { [17]=166145, [14]=166144, [15]=166146, [16]=166147 }, classes = { 6 } },
                { id = 188923, slot = "Head", name = "Theurgic Starspeaker's Howl", sources = { [17]=166344, [14]=166343, [15]=166345, [16]=166346 }, classes = { 7 } },
                { id = 188844, slot = "Head", name = "Erudite Occultist's Hood", sources = { [17]=166058, [14]=166057, [15]=166059, [16]=166060 }, classes = { 8 } },
                { id = 188889, slot = "Head", name = "Horns of the Demon Star", sources = { [17]=166226, [14]=166225, [15]=166227, [16]=166228 }, classes = { 9 } },
                { id = 188910, slot = "Head", name = "Crown of the Grand Upwelling", sources = { [17]=166298, [14]=166297, [15]=166299, [16]=166300 }, classes = { 10 } },
                { id = 188847, slot = "Head", name = "Headpiece of the Fixed Stars", sources = { [17]=166070, [14]=166069, [15]=166071, [16]=166072 }, classes = { 11 } },
                { id = 188892, slot = "Head", name = "Mercurial Punisher's Hood", sources = { [17]=166238, [14]=166237, [15]=166239, [16]=166240 }, classes = { 12 } },
            },
        },
        {
            index              = 9,
            name               = "Lords of Dread",
            journalEncounterID = 2457,
            aliases            = {},
            achievements = {
                { id = 15315, name = "Amidst Ourselves", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 189847, slot = "Back", name = "Shroud of the Sire's Chosen", sources = { [17]=168827, [14]=168826, [15]=168828, [16]=168829 } },
                { id = 189844, slot = "Hands", name = "Gauntlets of Unseen Guests", sources = { [17]=167985, [14]=167984, [15]=167986, [16]=167987 } },
                { id = 189843, slot = "Hands", name = "Grasps of Abducted Fate", sources = { [17]=167981, [14]=167980, [15]=167982, [16]=167983 } },
                { id = 189845, slot = "Off-hand", name = "Ruined Crest of Lordaeron", sources = { [17]=167989, [14]=167988, [15]=167990, [16]=167991 } },
                { id = 189846, slot = "Weapon", name = "Alandien's Tortured Twinblades", sources = { [17]=167993, [14]=167992, [15]=167994, [16]=167995 } },
                { id = 189842, slot = "Wrist", name = "Cuffs of the Covert Commander", sources = { [17]=167977, [14]=167976, [15]=167978, [16]=167979 } },
                -- Tier (12 items)
                { id = 188941, slot = "Shoulder", name = "Pauldrons of the Infinite Infantry", sources = { [17]=166410, [14]=166409, [15]=166411, [16]=166412 }, classes = { 1 } },
                { id = 188932, slot = "Shoulder", name = "Luminous Chevalier's Epaulets", sources = { [17]=166377, [14]=166376, [15]=166378, [16]=166379 }, classes = { 2 } },
                { id = 188856, slot = "Shoulder", name = "Godstalker's Pauldrons", sources = { [17]=166100, [14]=166099, [15]=166101, [16]=166102 }, classes = { 3 } },
                { id = 188905, slot = "Shoulder", name = "Soulblade Nightwings", sources = { [17]=166284, [14]=166283, [15]=166285, [16]=166286 }, classes = { 4 } },
                { id = 188879, slot = "Shoulder", name = "Capelet of the Empyrean", sources = { [17]=166186, [14]=166185, [15]=166187, [16]=166188 }, classes = { 5 } },
                { id = 188867, slot = "Shoulder", name = "Shoulderplates of the First Eidolon", sources = { [17]=166141, [14]=166140, [15]=166142, [16]=166143 }, classes = { 6 } },
                { id = 188920, slot = "Shoulder", name = "Theurgic Starspeaker's Adornment", sources = { [17]=166332, [14]=166331, [15]=166333, [16]=166334 }, classes = { 7 } },
                { id = 188843, slot = "Shoulder", name = "Erudite Occultist's Mantle", sources = { [17]=166054, [14]=166053, [15]=166055, [16]=166056 }, classes = { 8 } },
                { id = 188888, slot = "Shoulder", name = "Mantle of the Demon Star", sources = { [17]=166222, [14]=166221, [15]=166223, [16]=166224 }, classes = { 9 } },
                { id = 188914, slot = "Shoulder", name = "Tassels of the Grand Upwelling", sources = { [17]=166314, [14]=166313, [15]=166315, [16]=166316 }, classes = { 10 } },
                { id = 188851, slot = "Shoulder", name = "Shoulderpads of the Fixed Stars", sources = { [17]=166086, [14]=166085, [15]=166087, [16]=166088 }, classes = { 11 } },
                { id = 188896, slot = "Shoulder", name = "Mercurial Punisher's Shoulderpads", sources = { [17]=166254, [14]=166253, [15]=166255, [16]=166256 }, classes = { 12 } },
            },
        },
        {
            index              = 10,
            name               = "Rygelon",
            journalEncounterID = 2467,
            aliases            = {},
            achievements = {
                { id = 15396, name = "We Are All Made of Stars", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 189848, slot = "Feet", name = "Treads of Titanic Curiosity", sources = { [17]=167997, [14]=167996, [15]=167998, [16]=167999 } },
                { id = 189850, slot = "Hands", name = "Handguards of Hidden Realms", sources = { [17]=168005, [14]=168004, [15]=168006, [16]=168007 } },
                { id = 189853, slot = "Ranged", name = "Astral Verdict", sources = { [17]=168017, [14]=168016, [15]=168018, [16]=168019 } },
                { id = 189852, slot = "Weapon", name = "Antumbra, Shadow of the Cosmos", sources = { [17]=168013, [14]=168012, [15]=168014, [16]=168015 } },
                { id = 189851, slot = "Weapon", name = "Devastated Worldshard", sources = { [17]=168009, [14]=168008, [15]=168010, [16]=168011 } },
                { id = 191001, slot = "Weapon", name = "Observer's Umbral Shiv", sources = { [17]=169590, [14]=169587, [15]=169588, [16]=169589 } },
                { id = 189849, slot = "Wrist", name = "Interdimensional Manica", sources = { [17]=168001, [14]=168000, [15]=168002, [16]=168003 } },
                -- Tier (12 items)
                { id = 188938, slot = "Chest", name = "Breastplate of the Infinite Infantry", sources = { [17]=166398, [14]=166397, [15]=166399, [16]=166400 }, classes = { 1 } },
                { id = 188929, slot = "Chest", name = "Luminous Chevalier's Plackart", sources = { [17]=166365, [14]=166364, [15]=166366, [16]=166367 }, classes = { 2 } },
                { id = 188858, slot = "Chest", name = "Godstalker's Hauberk", sources = { [17]=166108, [14]=166107, [15]=166109, [16]=166110 }, classes = { 3 } },
                { id = 188903, slot = "Chest", name = "Soulblade Leathers", sources = { [17]=166276, [14]=166275, [15]=166277, [16]=166278 }, classes = { 4 } },
                { id = 188875, slot = "Chest", name = "Habit of the Empyrean", sources = { [17]=166170, [14]=166169, [15]=166171, [16]=166172 }, classes = { 5 } },
                { id = 188864, slot = "Chest", name = "Carapace of the First Eidolon", sources = { [17]=166129, [14]=166128, [15]=166130, [16]=166131 }, classes = { 6 } },
                { id = 188922, slot = "Chest", name = "Theurgic Starspeaker's Ringmail", sources = { [17]=166340, [14]=166339, [15]=166341, [16]=166342 }, classes = { 7 } },
                { id = 188839, slot = "Chest", name = "Erudite Occultist's Robes", sources = { [17]=166038, [14]=166037, [15]=166039, [16]=166040 }, classes = { 8 } },
                { id = 188884, slot = "Chest", name = "Robes of the Demon Star", sources = { [17]=166206, [14]=166205, [15]=166207, [16]=166208 }, classes = { 9 } },
                { id = 188912, slot = "Chest", name = "Cuirass of the Grand Upwelling", sources = { [17]=166306, [14]=166305, [15]=166307, [16]=166308 }, classes = { 10 } },
                { id = 188849, slot = "Chest", name = "Chestguard of the Fixed Stars", sources = { [17]=166078, [14]=166077, [15]=166079, [16]=166080 }, classes = { 11 } },
                { id = 188894, slot = "Chest", name = "Mercurial Punisher's Jerkin", sources = { [17]=166246, [14]=166245, [15]=166247, [16]=166248 }, classes = { 12 } },
            },
        },
        {
            index              = 11,
            name               = "The Jailer",
            journalEncounterID = 2464,
            aliases            = {},
            achievements = {
                { id = 15494, name = "Damnation Aviation", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 189855, slot = "Hands", name = "Bindings of the Banished One", sources = { [17]=168021, [14]=168020, [15]=168022, [16]=168023 } },
                { id = 189860, slot = "Held In Off-hand", name = "Forbidden Truth", sources = { [17]=168041, [14]=168040, [15]=168042, [16]=168043 } },
                { id = 189857, slot = "Legs", name = "Epochal Oppressor's Greaves", sources = { [17]=168029, [14]=168028, [15]=168030, [16]=168031 } },
                { id = 189858, slot = "Legs", name = "Legguards of the Ultimate Threat", sources = { [17]=168033, [14]=168032, [15]=168034, [16]=168035 } },
                { id = 189862, slot = "Two-Hand", name = "Gavel of the First Arbiter", sources = { [17]=168840, [14]=168840, [15]=168840, [16]=168840 } },
                { id = 189861, slot = "Two-Hand", name = "Zovastrum, the Unmaking", sources = { [17]=168045, [14]=168044, [15]=168046, [16]=168047 } },
                { id = 189856, slot = "Waist", name = "Runecarver's Twisted Ward", sources = { [17]=168025, [14]=168024, [15]=168026, [16]=168027 } },
                { id = 189818, slot = "Weapon", name = "Domination's Deliverance", sources = { [17]=168852, [14]=168849, [15]=168850, [16]=168851 } },
            },
            specialLoot = {
                { id = 190768, kind = "mount", name = "Fractal Cypher of the Zereth Overseer" },
            },
            soloTip = "When he casts Relentless Domination (mind control), use a nearby pillar to line-of-sight, then resume nuke.",
        },
    },  -- bosses

    routing = {

        -- 1. Vigilant Guardian
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Vigilant Guardian",
            requires  = {},
            segments  = {
                {
                    mapID  = 2047,
                    kind   = "path",
                    note   = "Follow the main path to Vigilant Guardian.",
                    points = {
                        { 0.100, 0.516 },
                        { 0.243, 0.518 },
                        { 0.246, 0.399 },
                        { 0.442, 0.428 },
                        { 0.503, 0.516 },
                    },
                },
            },
        },

        -- 2. Skolex
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Skolex, the Insatiable Ravener",
            requires  = { 1 },
            segments  = {
                {
                    mapID       = 2047,
                    kind        = "teleport",
                    destination = "Ephemeral Plains Alpha",
                    note        = "Head down the long hallway to the teleporter. Select Ephemeral Plains Alpha.",
                    points      = {
                        { 0.503, 0.516 },
                        { 0.563, 0.516 },
                        { 0.910, 0.521 },
                    },
                },
                {
                    mapID  = 2061,
                    kind   = "path",
                    note   = "Follow the path down to Skolex. Kill the trash to spawn the boss.",
                    points = {
                        { 0.163, 0.377 },
                        { 0.191, 0.412 },
                        { 0.169, 0.495 },
                        { 0.184, 0.599 },
                        { 0.162, 0.661 },
                    },
                },
            },
        },

        -- 3. Artificer Xy'mox
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Artificer Xy'mox",
            requires  = { 2 },
            segments  = {
                {
                    mapID  = 2061,
                    kind   = "path",
                    note   = "Follow the ring path up and around to Artificer Xy'mox.",
                    points = {
                        { 0.163, 0.660 },
                        { 0.193, 0.584 },
                        { 0.169, 0.512 },
                        { 0.189, 0.419 },
                        { 0.227, 0.388 },
                        { 0.295, 0.437 },
                        { 0.330, 0.420 },
                        { 0.371, 0.426 },
                    },
                },
            },
        },

        -- 4. Halondrus (requires Skolex + Xy'mox)
        {
            step      = 4,
            priority  = 4,
            bossIndex = 7,
            title     = "Halondrus the Reclaimer",
            requires  = { 2, 3 },
            segments  = {
                {
                    mapID  = 2061,
                    kind   = "path",
                    note   = "After killing both Skolex and Artificer Xy'mox, follow the path south to Halondrus.",
                    points = {
                        { 0.362, 0.422 },
                        { 0.309, 0.420 },
                        { 0.306, 0.609 },
                        { 0.419, 0.763 },
                    },
                },
            },
        },

        -- 5. Dausegne
        {
            step      = 5,
            priority  = 5,
            bossIndex = 4,
            title     = "Dausegne, the Fallen Oracle",
            requires  = { 7 },
            segments  = {
                {
                    mapID       = 2061,
                    kind        = "teleport",
                    destination = "Genesis Cradle Alpha",
                    note        = "After killing Halondrus, continue down the path behind him to reach his loot chest. Activate the nearby teleporter and select Genesis Cradle Alpha.",
                    points      = {
                        { 0.477, 0.770 },
                        { 0.630, 0.596 },
                        { 0.751, 0.742 },
                        { 0.914, 0.515 },
                    },
                },
                {
                    mapID  = 2048,
                    kind   = "path",
                    note   = "Cross Genesis Cradle to Dausegne.",
                    points = {
                        { 0.254, 0.841 },
                        { 0.315, 0.757 },
                        { 0.288, 0.624 },
                        { 0.305, 0.601 },
                        { 0.347, 0.619 },
                        { 0.363, 0.601 },
                        { 0.358, 0.566 },
                        { 0.405, 0.501 },
                        { 0.461, 0.522 },
                        { 0.500, 0.466 },
                    },
                },
            },
        },

        -- 6. Prototype Pantheon
        {
            step      = 6,
            priority  = 6,
            bossIndex = 5,
            title     = "Prototype Pantheon",
            requires  = { 4 },
            segments  = {
                {
                    mapID  = 2048,
                    kind   = "path",
                    note   = "Continue past Dausegne toward the Endless Foundry entrance.",
                    points = {
                        { 0.543, 0.466 },
                        { 0.572, 0.510 },
                        { 0.692, 0.331 },
                        { 0.678, 0.191 },
                        { 0.710, 0.142 },
                    },
                },
                {
                    mapID  = 2049,
                    kind   = "path",
                    note   = "Follow the foundry floor to Prototype Pantheon.",
                    points = {
                        { 0.257, 0.807 },
                        { 0.305, 0.738 },
                    },
                },
            },
        },

        -- 7. Lihuvim
        {
            step      = 7,
            priority  = 7,
            bossIndex = 6,
            title     = "Lihuvim, Principal Architect",
            requires  = { 5 },
            segments  = {
                {
                    mapID  = 2049,
                    kind   = "path",
                    note   = "Follow the path through The Endless Foundry, killing the trash on the way to Lihuvim.",
                    points = {
                        { 0.349, 0.663 },
                        { 0.621, 0.259 },
                    },
                },
            },
        },

        -- 8. Anduin Wrynn
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Anduin Wrynn",
            requires  = { 6 },
            segments  = {
                {
                    mapID       = 2049,
                    kind        = "teleport",
                    destination = "Domination's Grasp",
                    note        = "Find the teleporter behind Lihuvim and select Domination's Grasp.",
                    points      = {
                        { 0.668, 0.187 },
                        { 0.682, 0.098 },
                    },
                },
                {
                    mapID  = 2050,
                    kind   = "path",
                    note   = "Follow the bridge into Domination's Grasp to Anduin.",
                    points = {
                        { 0.161, 0.518 },
                        { 0.377, 0.520 },
                    },
                },
            },
        },

        -- 9. Lords of Dread
        {
            step      = 9,
            priority  = 9,
            bossIndex = 9,
            title     = "Lords of Dread",
            requires  = { 8 },
            segments  = {
                {
                    mapID       = 2050,
                    kind        = "teleport",
                    destination = "The Grand Design",
                    note        = "Cross the bridge behind Anduin to the teleporter. Select Proceed.",
                    points      = {
                        { 0.435, 0.519 },
                        { 0.857, 0.517 },
                    },
                },
                {
                    mapID  = 2052,
                    kind   = "path",
                    note   = "Follow the path through The Grand Design, killing trash on the way to Lords of Dread.",
                    points = {
                        { 0.484, 0.202 },
                        { 0.607, 0.204 },
                        { 0.630, 0.289 },
                        { 0.607, 0.437 },
                    },
                },
            },
        },

        -- 10. Rygelon
        {
            step      = 10,
            priority  = 10,
            bossIndex = 10,
            title     = "Rygelon",
            requires  = { 9 },
            segments  = {
                {
                    mapID  = 2052,
                    kind   = "path",
                    note   = "After killing Lords of Dread, you will find a teleporter behind them. Use it to take a shortcut back to the beginning of the room, and follow the path to Rygelon.",
                    points = {
                        { 0.607, 0.440 },
                        { 0.641, 0.340 },
                        { 0.635, 0.317 },
                        { 0.639, 0.292 },
                        { 0.608, 0.204 },
                        { 0.377, 0.206 },
                        { 0.344, 0.279 },
                        { 0.300, 0.280 },
                        { 0.287, 0.303 },
                        { 0.306, 0.360 },
                        { 0.325, 0.360 },
                        { 0.363, 0.463 },
                    },
                },
            },
        },

        -- 11. The Jailer
        {
            step      = 11,
            priority  = 11,
            bossIndex = 11,
            title     = "The Jailer",
            requires  = { 10 },
            segments  = {
                {
                    mapID  = 2052,
                    kind   = "path",
                    note   = "Follow the path behind Rygelon all the way to The Jailer.",
                    points = {
                        { 0.395, 0.545 },
                        { 0.425, 0.621 },
                        { 0.492, 0.625 },
                        { 0.604, 0.898 },
                    },
                },
                -- Heart of Eternity (2051) is the sub-area containing
                -- the Jailer's actual platform. The map swaps from
                -- "The Grand Design" (2052) to this area just before
                -- reaching his platform, so without a segment for this
                -- mapID the router falls back to "(Open map for
                -- directions)". Note/points are minimal: the player is
                -- already headed the right way, they just need
                -- acknowledgement that they're on-route.
                {
                    mapID  = 2051,
                    kind   = "path",
                    note   = "Continue forward to The Jailer's platform.",
                    points = {
                        { 0.500, 0.500 },
                    },
                },
            },
        },

    },  -- routing
}
