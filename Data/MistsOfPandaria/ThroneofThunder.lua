-------------------------------------------------------------------------------
-- RetroRuns Data -- Throne of Thunder
-- Mists of Pandaria, Patch 5.2.0  |  instanceID: 1098  |  journalInstanceID: 362
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1098] = {
    instanceID        = 1098,
    journalInstanceID = 362,
    name              = "Throne of Thunder",
    expansion         = "Mists of Pandaria",
    patch             = "5.2.0",

    -- Pandaria-era raids split lockouts by raid size (10 and 25) rather
    -- than offering Mythic. Loot is shared across sizes, so the two
    -- Normal lockouts fold into one Normal bucket and the two Heroic
    -- lockouts into one Heroic; Raid Finder stands alone. This tells the
    -- difficulty engine to fold that way instead of the modern scheme.
    difficultyModel   = "mop",

    entrance = {
        mapID = 504,
        x     = 0.6370,
        y     = 0.3230,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [508] = "Overgrown Statuary",
        [509] = "Royal Amphitheater",
        [510] = "Forgotten Depths",
        [511] = "Roost of Ji-Kun",
        [512] = "Halls of Flesh-Shaping",
        [513] = "Hall of Kings",
        [514] = "Pinnacle of Storms",
        [515] = "Hidden Cell",
    },

    tierSets = {
        labels = {
            -- Tier 15 is the Throne of Thunder set. The raid drops all
            -- five token slots: Council of Elders (Hands), Ji-Kun
            -- (Legs), Dark Animus (Chest), Iron Qon (Shoulders), and
            -- the Twin Empyreans (Head).
        },
        tokenSources = {
            [95570] = 3,  -- Gauntlets of the Crackling Vanquisher
            [95575] = 3,  -- Gauntlets of the Crackling Conqueror
            [95580] = 3,  -- Gauntlets of the Crackling Protector
            [95855] = 3,  -- Gauntlets of the Crackling Vanquisher
            [95856] = 3,  -- Gauntlets of the Crackling Conqueror
            [95857] = 3,  -- Gauntlets of the Crackling Protector
            [96599] = 3,  -- Gauntlets of the Crackling Vanquisher
            [96600] = 3,  -- Gauntlets of the Crackling Conqueror
            [96601] = 3,  -- Gauntlets of the Crackling Protector
            [95572] = 6,  -- Leggings of the Crackling Vanquisher
            [95576] = 6,  -- Leggings of the Crackling Conqueror
            [95581] = 6,  -- Leggings of the Crackling Protector
            [95887] = 6,  -- Leggings of the Crackling Vanquisher
            [95888] = 6,  -- Leggings of the Crackling Conqueror
            [95889] = 6,  -- Leggings of the Crackling Protector
            [96631] = 6,  -- Leggings of the Crackling Vanquisher
            [96632] = 6,  -- Leggings of the Crackling Conqueror
            [96633] = 6,  -- Leggings of the Crackling Protector
            [95569] = 9,  -- Chest of the Crackling Vanquisher
            [95574] = 9,  -- Chest of the Crackling Conqueror
            [95579] = 9,  -- Chest of the Crackling Protector
            [95822] = 9,  -- Chest of the Crackling Vanquisher
            [95823] = 9,  -- Chest of the Crackling Conqueror
            [95824] = 9,  -- Chest of the Crackling Protector
            [96566] = 9,  -- Chest of the Crackling Vanquisher
            [96567] = 9,  -- Chest of the Crackling Conqueror
            [96568] = 9,  -- Chest of the Crackling Protector
            [95573] = 10,  -- Shoulders of the Crackling Vanquisher
            [95578] = 10,  -- Shoulders of the Crackling Conqueror
            [95583] = 10,  -- Shoulders of the Crackling Protector
            [95955] = 10,  -- Shoulders of the Crackling Vanquisher
            [95956] = 10,  -- Shoulders of the Crackling Conqueror
            [95957] = 10,  -- Shoulders of the Crackling Protector
            [96699] = 10,  -- Shoulders of the Crackling Vanquisher
            [96700] = 10,  -- Shoulders of the Crackling Conqueror
            [96701] = 10,  -- Shoulders of the Crackling Protector
            [95571] = 11,  -- Helm of the Crackling Vanquisher
            [95577] = 11,  -- Helm of the Crackling Conqueror
            [95582] = 11,  -- Helm of the Crackling Protector
            [95879] = 11,  -- Helm of the Crackling Vanquisher
            [95880] = 11,  -- Helm of the Crackling Conqueror
            [95881] = 11,  -- Helm of the Crackling Protector
            [96623] = 11,  -- Helm of the Crackling Vanquisher
            [96624] = 11,  -- Helm of the Crackling Conqueror
            [96625] = 11,  -- Helm of the Crackling Protector
        },
    },

    gloryMeta = {
        id   = 8124,
        name = "Glory of the Thundering Raider",
        rewardItemID       = 93662,
        rewardMountSpellID = 136400,
        rewardName         = "Reins of the Armored Skyscreamer",
    },

    bosses = {
        {
            index              = 1,
            name               = "Jin'rokh the Breaker",
            journalEncounterID = 827,
            aliases            = {},
            achievements       = {
                { id = 8056, name = "Heroic: Jin'rokh the Breaker", meta = true, soloable = "yes" },
                { id = 8094, name = "Lightning Overload", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94735, slot = "Back", name = "Drape of Booming Nights", sources = { [17]=50173, [14]=49592, [15]=50797 } },
                { id = 94723, slot = "Chest", name = "Chestplate of Violent Detonation", sources = { [17]=50166, [14]=49581, [15]=50790 } },
                { id = 94734, slot = "Chest", name = "Ionized Yojamban Carapace", sources = { [17]=50177, [14]=49591, [15]=50801 } },
                { id = 94731, slot = "Chest", name = "Robes of Static Bursts", sources = { [17]=50172, [14]=49588, [15]=50796 } },
                { id = 94736, slot = "Feet", name = "Ghostbinder Greatboots", sources = { [17]=50176, [14]=49593, [15]=50800 } },
                { id = 94737, slot = "Hands", name = "Lightningweaver Gauntlets", sources = { [17]=50169, [14]=49594, [15]=50793 } },
                { id = 94724, slot = "Head", name = "Lightning-Eye Hood", sources = { [17]=50162, [14]=49582, [15]=50786 } },
                { id = 94739, slot = "Legs", name = "Al'set's Tormented Leggings", sources = { [17]=50170, [14]=49595, [15]=50794 } },
                { id = 94728, slot = "Legs", name = "Spearman's Jingling Leggings", sources = { [17]=50163, [14]=49586, [15]=50787 } },
                { id = 94733, slot = "Shoulder", name = "Fissure-Split Shoulderwraps", sources = { [17]=50171, [14]=49590, [15]=50795 } },
                { id = 94725, slot = "Shoulder", name = "Static-Shot Shoulderguards", sources = { [17]=50164, [14]=49583, [15]=50788 } },
                { id = 94726, slot = "Waist", name = "Cloudbreaker Greatbelt", sources = { [17]=50165, [14]=49584, [15]=50789 } },
                { id = 94730, slot = "Weapon", name = "Soulblade of the Breaking Storm", sources = { [17]=50174, [14]=49587, [15]=50798 } },
                { id = 94722, slot = "Weapon", name = "Worldbreaker's Stormscythe", sources = { [17]=50168, [14]=49580, [15]=50792 } },
                { id = 94727, slot = "Wrist", name = "Bracers of Constant Implosion", sources = { [17]=50167, [14]=49585, [15]=50791 } },
                { id = 94732, slot = "Wrist", name = "Infinitely Conducting Bracers", sources = { [17]=50175, [14]=49589, [15]=50799 } },
            },
        },
        {
            index              = 2,
            name               = "Horridon",
            journalEncounterID = 819,
            aliases            = {},
            achievements       = {
                { id = 8057, name = "Heroic: Horridon", meta = true, soloable = "yes" },
                { id = 8038, name = "Cretaceous Collector", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94745, slot = "Back", name = "Horn-Rimmed Doomcloak", sources = { [17]=50185, [14]=49601, [15]=50809 } },
                { id = 94748, slot = "Back", name = "Wastewalker's Sandblasted Drape", sources = { [17]=50178, [14]=49603, [15]=50802 } },
                { id = 94741, slot = "Chest", name = "Sul'lithuz Sandmail", sources = { [17]=50181, [14]=49597, [15]=50805 } },
                { id = 94752, slot = "Head", name = "Flamecaster's Burning Crown", sources = { [17]=50186, [14]=49607, [15]=50810 } },
                { id = 94744, slot = "Head", name = "Puncture-Proof Greathelm", sources = { [17]=50184, [14]=49600, [15]=50808 } },
                { id = 94747, slot = "Legs", name = "Bloodlord's Bloodsoaked Legplates", sources = { [17]=50183, [14]=49602, [15]=50807 } },
                { id = 94975, slot = "Legs", name = "Legguards of Scintillating Scales", sources = { [17]=50192, [14]=49785, [15]=50816 } },
                { id = 94756, slot = "Legs", name = "Roots of Rampaging Earth", sources = { [17]=50190, [14]=49610, [15]=50814 } },
                { id = 94755, slot = "Ranged", name = "Venomlord's Totemic Wand", sources = { [17]=50189, [14]=49609, [15]=50813 } },
                { id = 94753, slot = "Shoulder", name = "Spaulders of Dinomancy", sources = { [17]=50191, [14]=49608, [15]=50815 } },
                { id = 94749, slot = "Two-Hand", name = "Dinomancer's Spiritbinding Spire", sources = { [17]=50188, [14]=49604, [15]=50812 } },
                { id = 94740, slot = "Two-Hand", name = "Jalak's Maelstrom Staff", sources = { [17]=50179, [14]=49596, [15]=50803 } },
                { id = 94751, slot = "Wrist", name = "Armplates of the Vanquished Abomination", sources = { [17]=50193, [14]=49606, [15]=50817 } },
                { id = 94743, slot = "Wrist", name = "Bindings of Multiplicative Strikes", sources = { [17]=50180, [14]=49599, [15]=50804 } },
                { id = 94742, slot = "Wrist", name = "Frozen Warlord's Bracers", sources = { [17]=50182, [14]=49598, [15]=50806 } },
                { id = 94750, slot = "Wrist", name = "Vaccinator's Armwraps", sources = { [17]=50187, [14]=49605, [15]=50811 } },
            },
            specialLoot = {
                { id = 93666, kind = "mount", name = "Spawn of Horridon" },
                { id = 94574, kind = "pet", name = "Pygmy Direhorn" },
            },
        },
        {
            index              = 3,
            name               = "Council of Elders",
            journalEncounterID = 816,
            aliases            = {},
            achievements       = {
                { id = 8073, name = "Cage Match", meta = true, soloable = "yes" },
                { id = 8058, name = "Heroic: Council of Elders", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94764, slot = "Chest", name = "Overloaded Bladebreaker Cuirass", sources = { [17]=50201, [14]=49618, [15]=50825 } },
                { id = 94765, slot = "Chest", name = "Robes of Treacherous Ground", sources = { [17]=50198, [14]=49619, [15]=50822 } },
                { id = 94761, slot = "Chest", name = "Zandalari Robes of the Final Rite", sources = { [17]=50196, [14]=49615, [15]=50820 } },
                { id = 94762, slot = "Feet", name = "Mar'li's Bloodstained Sandals", sources = { [17]=50195, [14]=49616, [15]=50819 } },
                { id = 94763, slot = "Head", name = "Gaze of Gara'jal", sources = { [17]=50199, [14]=49617, [15]=50823 } },
                { id = 94758, slot = "Two-Hand", name = "Zerat, Malakk's Soulburning Greatsword", sources = { [17]=50202, [14]=49612, [15]=50826 } },
                { id = 94760, slot = "Weapon", name = "Amun-Thoth, Sul's Spiritrending Talons", sources = { [17]=50197, [14]=49614, [15]=50821 } },
                { id = 94759, slot = "Weapon", name = "Kura-Kura, Kazra'jin's Skullcleaver", sources = { [17]=50194, [14]=49613, [15]=50818 } },
                { id = 94767, slot = "Wrist", name = "Loa-Ridden Bracers", sources = { [17]=50200, [14]=49620, [15]=50824 } },
                { id = 95332, slot = "Hands", name = "Gauntlets of the Last Mogu", sources = { [17]=50466, [14]=50074, [15]=51090 }, classes = { 1 } },
                { id = 95336, slot = "Hands", name = "Handguards of the Last Mogu", sources = { [17]=50470, [14]=50078, [15]=51094 }, classes = { 1 } },
                { id = 95281, slot = "Hands", name = "Lightning Emperor's Gauntlets", sources = { [17]=50397, [14]=50023, [15]=51021 }, classes = { 2 } },
                { id = 95286, slot = "Hands", name = "Lightning Emperor's Gloves", sources = { [17]=50402, [14]=50028, [15]=51026 }, classes = { 2 } },
                { id = 95291, slot = "Hands", name = "Lightning Emperor's Handguards", sources = { [17]=50407, [14]=50033, [15]=51031 }, classes = { 2 } },
                { id = 95256, slot = "Hands", name = "Saurok Stalker's Gloves", sources = { [17]=50372, [14]=49998, [15]=50996 }, classes = { 3 } },
                { id = 95306, slot = "Hands", name = "Nine-Tailed Gloves", sources = { [17]=50422, [14]=50048, [15]=51046 }, classes = { 4 } },
                { id = 95295, slot = "Hands", name = "Handwraps of the Exorcist", sources = { [17]=50411, [14]=50037, [15]=51035 }, classes = { 5 } },
                { id = 95300, slot = "Hands", name = "Gloves of the Exorcist", sources = { [17]=50416, [14]=50042, [15]=51040 }, classes = { 5 } },
                { id = 95226, slot = "Hands", name = "Gauntlets of the All-Consuming Maw", sources = { [17]=50321, [14]=49968, [15]=50945 }, classes = { 6 } },
                { id = 95231, slot = "Hands", name = "Handguards of the All-Consuming Maw", sources = { [17]=50326, [14]=49973, [15]=50950 }, classes = { 6 } },
                { id = 95311, slot = "Hands", name = "Handwraps of the Witch Doctor", sources = { [17]=50427, [14]=50053, [15]=51051 }, classes = { 7 } },
                { id = 95316, slot = "Hands", name = "Grips of the Witch Doctor", sources = { [17]=50432, [14]=50058, [15]=51056 }, classes = { 7 } },
                { id = 95321, slot = "Hands", name = "Gloves of the Witch Doctor", sources = { [17]=50437, [14]=50063, [15]=51061 }, classes = { 7 } },
                { id = 95260, slot = "Hands", name = "Gloves of the Chromatic Hydra", sources = { [17]=50376, [14]=50002, [15]=51000 }, classes = { 8 } },
                { id = 95325, slot = "Hands", name = "Gloves of the Thousandfold Hells", sources = { [17]=50459, [14]=50067, [15]=51083 }, classes = { 9 } },
                { id = 95266, slot = "Hands", name = "Fire-Charm Grips", sources = { [17]=50382, [14]=50008, [15]=51006 }, classes = { 10 } },
                { id = 95270, slot = "Hands", name = "Fire-Charm Handwraps", sources = { [17]=50386, [14]=50012, [15]=51010 }, classes = { 10 } },
                { id = 95276, slot = "Hands", name = "Fire-Charm Gauntlets", sources = { [17]=50392, [14]=50018, [15]=51016 }, classes = { 10 } },
                { id = 95236, slot = "Hands", name = "Grips of the Haunted Forest", sources = { [17]=50331, [14]=49978, [15]=50955 }, classes = { 11 } },
                { id = 95240, slot = "Hands", name = "Handwraps of the Haunted Forest", sources = { [17]=50335, [14]=49982, [15]=50959 }, classes = { 11 } },
                { id = 95245, slot = "Hands", name = "Gloves of the Haunted Forest", sources = { [17]=50340, [14]=49987, [15]=50964 }, classes = { 11 } },
                { id = 95251, slot = "Hands", name = "Handguards of the Haunted Forest", sources = { [17]=50346, [14]=49993, [15]=50970 }, classes = { 11 } },
            },
        },
        {
            index              = 4,
            name               = "Tortos",
            journalEncounterID = 825,
            aliases            = {},
            achievements       = {
                { id = 8077, name = "One-Up", meta = true, soloable = "yes" },
                { id = 8059, name = "Heroic: Tortos", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94774, slot = "Back", name = "Beakbreaker Greatcloak", sources = { [17]=50211, [14]=49627, [15]=50835 } },
                { id = 94785, slot = "Back", name = "Shimmershell Cape", sources = { [17]=50215, [14]=49637, [15]=50839 } },
                { id = 94779, slot = "Chest", name = "Robes of Concussive Shocks", sources = { [17]=50218, [14]=49631, [15]=50842 } },
                { id = 94770, slot = "Chest", name = "Rockfall Ribwraps", sources = { [17]=50204, [14]=49623, [15]=50828 } },
                { id = 94772, slot = "Feet", name = "Quakestompers", sources = { [17]=50207, [14]=49625, [15]=50831 } },
                { id = 94780, slot = "Hands", name = "Crystal-Claw Gloves", sources = { [17]=50214, [14]=49632, [15]=50838 } },
                { id = 94777, slot = "Hands", name = "Grips of Vampiric Cruelty", sources = { [17]=50205, [14]=49629, [15]=50829 } },
                { id = 94787, slot = "Hands", name = "Tortos' Shellseizers", sources = { [17]=50221, [14]=49639, [15]=50845 } },
                { id = 94782, slot = "Head", name = "Stonegaze Hood", sources = { [17]=50213, [14]=49634, [15]=50837 } },
                { id = 94778, slot = "Off-hand", name = "Tortos' Discarded Shell", sources = { [17]=50216, [14]=49630, [15]=50840 } },
                { id = 94769, slot = "Ranged", name = "Shattered Tortoiseshell Longbow", sources = { [17]=50203, [14]=49622, [15]=50827 } },
                { id = 94773, slot = "Shoulder", name = "Shoulderguards of Centripetal Destruction", sources = { [17]=50208, [14]=49626, [15]=50832 } },
                { id = 94783, slot = "Shoulder", name = "Spaulders of Quaking Fear", sources = { [17]=50219, [14]=49635, [15]=50843 } },
                { id = 94784, slot = "Waist", name = "Refreshing Abalone Girdle", sources = { [17]=50220, [14]=49636, [15]=50844 } },
                { id = 94768, slot = "Weapon", name = "Shellsplitter Greataxe", sources = { [17]=50210, [14]=49621, [15]=50834 } },
                { id = 94781, slot = "Wrist", name = "Azure Shell Bracers", sources = { [17]=50212, [14]=49633, [15]=50836 } },
                { id = 94775, slot = "Wrist", name = "Beady-Eye Bracers", sources = { [17]=50206, [14]=49628, [15]=50830 } },
                { id = 94771, slot = "Wrist", name = "Shell-Coated Wristplates", sources = { [17]=50209, [14]=49624, [15]=50833 } },
                { id = 94786, slot = "Wrist", name = "Vampire Bat-Hide Bracers", sources = { [17]=50217, [14]=49638, [15]=50841 } },
            },
        },
        {
            index              = 5,
            name               = "Megaera",
            journalEncounterID = 821,
            aliases            = {},
            achievements       = {
                { id = 8082, name = "Head Case", meta = true, soloable = "kinda" },
                { id = 8060, name = "Heroic: Megaera", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94797, slot = "Chest", name = "Chain of Consuming Magic", sources = { [17]=50233, [14]=49646, [15]=50857 } },
                { id = 94789, slot = "Chest", name = "Rot-Proof Greatplate", sources = { [17]=50226, [14]=49641, [15]=50850 } },
                { id = 94798, slot = "Feet", name = "Ice-Scored Treads", sources = { [17]=50234, [14]=49647, [15]=50858 } },
                { id = 94799, slot = "Feet", name = "Sandals of Arcane Fury", sources = { [17]=50227, [14]=49648, [15]=50851 } },
                { id = 94790, slot = "Hands", name = "Grips of Cinderflesh", sources = { [17]=50224, [14]=49642, [15]=50848 } },
                { id = 94800, slot = "Head", name = "Hood of Smoldering Flesh", sources = { [17]=50231, [14]=49649, [15]=50855 } },
                { id = 94796, slot = "Held In Off-hand", name = "Fetish of the Hydra", sources = { [17]=50230, [14]=49645, [15]=50854 } },
                { id = 94801, slot = "Shoulder", name = "Gleaming-Eye Shoulderpads", sources = { [17]=50228, [14]=49650, [15]=50852 } },
                { id = 94791, slot = "Shoulder", name = "Poisonblood Bladeshoulders", sources = { [17]=50223, [14]=49643, [15]=50847 } },
                { id = 94802, slot = "Waist", name = "Links of the Bifurcated Tongue", sources = { [17]=50232, [14]=49651, [15]=50856 } },
                { id = 94792, slot = "Waist", name = "Plated Toothbreaker Girdle", sources = { [17]=50225, [14]=49644, [15]=50849 } },
                { id = 94788, slot = "Weapon", name = "Megaera's Poisoned Fang", sources = { [17]=50222, [14]=49640, [15]=50846 } },
                { id = 94804, slot = "Wrist", name = "Frostborn Wristwraps", sources = { [17]=50229, [14]=49652, [15]=50853 } },
            },
        },
        {
            index              = 6,
            name               = "Ji-Kun",
            journalEncounterID = 828,
            aliases            = {},
            achievements       = {
                { id = 8097, name = "Soft Hands", meta = true, soloable = "kinda" },
                { id = 8061, name = "Heroic: Ji-Kun", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94812, slot = "Back", name = "Pinionfeather Greatcloak", sources = { [17]=50235, [14]=49660, [15]=50859 } },
                { id = 94806, slot = "Chest", name = "Robe of Midnight Down", sources = { [17]=50237, [14]=49654, [15]=50861 } },
                { id = 94810, slot = "Chest", name = "Talonrender Chestplate", sources = { [17]=50242, [14]=49658, [15]=50866 } },
                { id = 94807, slot = "Hands", name = "Egg-Shard Grips", sources = { [17]=50243, [14]=49655, [15]=50867 } },
                { id = 94808, slot = "Hands", name = "Grasp of the Ruthless Mother", sources = { [17]=50240, [14]=49656, [15]=50864 } },
                { id = 94809, slot = "Head", name = "Crown of Potentiated Birth", sources = { [17]=50241, [14]=49657, [15]=50865 } },
                { id = 94805, slot = "Two-Hand", name = "Giorgio's Caduceus of Pure Moods", sources = { [17]=50238, [14]=49653, [15]=50862 } },
                { id = 94813, slot = "Waist", name = "Cord of Cacophonous Cawing", sources = { [17]=50236, [14]=49661, [15]=50860 } },
                { id = 94811, slot = "Waist", name = "Featherflight Belt", sources = { [17]=50239, [14]=49659, [15]=50863 } },
                { id = 95333, slot = "Legs", name = "Legplates of the Last Mogu", sources = { [17]=50467, [14]=50075, [15]=51091 }, classes = { 1 } },
                { id = 95338, slot = "Legs", name = "Legguards of the Last Mogu", sources = { [17]=50472, [14]=50080, [15]=51096 }, classes = { 1 } },
                { id = 95283, slot = "Legs", name = "Lightning Emperor's Legplates", sources = { [17]=50399, [14]=50025, [15]=51023 }, classes = { 2 } },
                { id = 95288, slot = "Legs", name = "Lightning Emperor's Greaves", sources = { [17]=50404, [14]=50030, [15]=51028 }, classes = { 2 } },
                { id = 95293, slot = "Legs", name = "Lightning Emperor's Legguards", sources = { [17]=50409, [14]=50035, [15]=51033 }, classes = { 2 } },
                { id = 95258, slot = "Legs", name = "Saurok Stalker's Legguards", sources = { [17]=50374, [14]=50000, [15]=50998 }, classes = { 3 } },
                { id = 95308, slot = "Legs", name = "Nine-Tailed Legguards", sources = { [17]=50424, [14]=50050, [15]=51048 }, classes = { 4 } },
                { id = 95297, slot = "Legs", name = "Legwraps of the Exorcist", sources = { [17]=50413, [14]=50039, [15]=51037 }, classes = { 5 } },
                { id = 95302, slot = "Legs", name = "Leggings of the Exorcist", sources = { [17]=50418, [14]=50044, [15]=51042 }, classes = { 5 } },
                { id = 95228, slot = "Legs", name = "Greaves of the All-Consuming Maw", sources = { [17]=50323, [14]=49970, [15]=50947 }, classes = { 6 } },
                { id = 95233, slot = "Legs", name = "Legguards of the All-Consuming Maw", sources = { [17]=50328, [14]=49975, [15]=50952 }, classes = { 6 } },
                { id = 95313, slot = "Legs", name = "Legwraps of the Witch Doctor", sources = { [17]=50429, [14]=50055, [15]=51053 }, classes = { 7 } },
                { id = 95318, slot = "Legs", name = "Legguards of the Witch Doctor", sources = { [17]=50434, [14]=50060, [15]=51058 }, classes = { 7 } },
                { id = 95323, slot = "Legs", name = "Kilt of the Witch Doctor", sources = { [17]=50439, [14]=50065, [15]=51063 }, classes = { 7 } },
                { id = 95262, slot = "Legs", name = "Leggings of the Chromatic Hydra", sources = { [17]=50378, [14]=50004, [15]=51002 }, classes = { 8 } },
                { id = 95327, slot = "Legs", name = "Leggings of the Thousandfold Hells", sources = { [17]=50461, [14]=50069, [15]=51085 }, classes = { 9 } },
                { id = 95268, slot = "Legs", name = "Fire-Charm Leggings", sources = { [17]=50384, [14]=50010, [15]=51008 }, classes = { 10 } },
                { id = 95272, slot = "Legs", name = "Fire-Charm Legwraps", sources = { [17]=50388, [14]=50014, [15]=51012 }, classes = { 10 } },
                { id = 95278, slot = "Legs", name = "Fire-Charm Legguards", sources = { [17]=50394, [14]=50020, [15]=51018 }, classes = { 10 } },
                { id = 95238, slot = "Legs", name = "Legguards of the Haunted Forest", sources = { [17]=50333, [14]=49980, [15]=50957 }, classes = { 11 } },
                { id = 95242, slot = "Legs", name = "Legwraps of the Haunted Forest", sources = { [17]=50337, [14]=49984, [15]=50961 }, classes = { 11 } },
                { id = 95247, slot = "Legs", name = "Leggings of the Haunted Forest", sources = { [17]=50342, [14]=49989, [15]=50966 }, classes = { 11 } },
                { id = 95253, slot = "Legs", name = "Breeches of the Haunted Forest", sources = { [17]=50348, [14]=49995, [15]=50972 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 95059, kind = "mount", name = "Clutch of Ji-Kun" },
                { id = 94835, kind = "pet", name = "Ji-Kun Hatchling" },
            },
        },
        {
            index              = 7,
            name               = "Durumu the Forgotten",
            journalEncounterID = 818,
            aliases            = {},
            achievements       = {
                { id = 8098, name = "You Said Crossing the Streams Was Bad", meta = true, soloable = "kinda" },
                { id = 8062, name = "Heroic: Durumu the Forgotten", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94929, slot = "Back", name = "Deadly Glare Cape", sources = { [17]=50256, [14]=49746, [15]=50880 } },
                { id = 94822, slot = "Back", name = "Reinforced Mirror-Sheen Cloak", sources = { [17]=50252, [14]=49670, [15]=50876 } },
                { id = 94818, slot = "Chest", name = "Aberrant Chestguard of Torment", sources = { [17]=50247, [14]=49666, [15]=50871 } },
                { id = 94927, slot = "Feet", name = "Sandals of the Starving Eye", sources = { [17]=50258, [14]=49744, [15]=50882 } },
                { id = 94817, slot = "Feet", name = "Treads of the Blind Eye", sources = { [17]=50250, [14]=49665, [15]=50874 } },
                { id = 94821, slot = "Hands", name = "Artery Rippers", sources = { [17]=50251, [14]=49669, [15]=50875 } },
                { id = 94924, slot = "Hands", name = "Iceshatter Gauntlets", sources = { [17]=50260, [14]=49741, [15]=50884 } },
                { id = 94925, slot = "Hands", name = "Lifedrainer's Sordid Grip", sources = { [17]=50253, [14]=49742, [15]=50877 } },
                { id = 94816, slot = "Legs", name = "Crimson Bloom Legguards", sources = { [17]=50245, [14]=49664, [15]=50869 } },
                { id = 94923, slot = "Legs", name = "Leggings of Pulsing Blood", sources = { [17]=50254, [14]=49740, [15]=50878 } },
                { id = 94930, slot = "Legs", name = "Legplates of Re-Emergence", sources = { [17]=50261, [14]=49747, [15]=50885 } },
                { id = 94815, slot = "Legs", name = "Legplates of the Dark Parasite", sources = { [17]=50249, [14]=49663, [15]=50873 } },
                { id = 94814, slot = "Ranged", name = "Durumu's Baleful Gaze", sources = { [17]=50244, [14]=49662, [15]=50868 } },
                { id = 94928, slot = "Shoulder", name = "Chilblain Spaulders", sources = { [17]=50255, [14]=49745, [15]=50879 } },
                { id = 94819, slot = "Waist", name = "Links of the Disintegrator", sources = { [17]=50246, [14]=49667, [15]=50870 } },
                { id = 94922, slot = "Weapon", name = "Ritual Dagger of the Mind's Eye", sources = { [17]=50257, [14]=49739, [15]=50881 } },
                { id = 94820, slot = "Wrist", name = "Caustic Spike Bracers", sources = { [17]=50248, [14]=49668, [15]=50872 } },
                { id = 94926, slot = "Wrist", name = "Vein-Cover Bracers", sources = { [17]=50259, [14]=49743, [15]=50883 } },
            },
        },
        {
            index              = 8,
            name               = "Primordius",
            journalEncounterID = 820,
            aliases            = {},
            achievements       = {
                { id = 8037, name = "Genetically Unmodified Organism", meta = true, soloable = "yes" },
                { id = 8063, name = "Heroic: Primordius", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94942, slot = "Back", name = "Hydra-Scale Bloodcloak", sources = { [17]=50268, [14]=49753, [15]=50892 } },
                { id = 94951, slot = "Chest", name = "Robes of Mutagenic Blood", sources = { [17]=50270, [14]=49762, [15]=50894 } },
                { id = 94939, slot = "Hands", name = "Gloves of Cushioned Air", sources = { [17]=50262, [14]=49750, [15]=50886 } },
                { id = 94947, slot = "Hands", name = "Helix-Breaker Gloves", sources = { [17]=50271, [14]=49758, [15]=50895 } },
                { id = 94938, slot = "Hands", name = "Pathogenic Gauntlets", sources = { [17]=50265, [14]=49749, [15]=50889 } },
                { id = 94943, slot = "Hands", name = "Synapse-String Handguards", sources = { [17]=50264, [14]=49754, [15]=50888 } },
                { id = 94949, slot = "Head", name = "Clear-Mind Helm", sources = { [17]=50275, [14]=49760, [15]=50899 } },
                { id = 94944, slot = "Legs", name = "Black Blood Legplates", sources = { [17]=50266, [14]=49755, [15]=50890 } },
                { id = 94953, slot = "Legs", name = "Leggings of Ebon Veins", sources = { [17]=50272, [14]=49764, [15]=50896 } },
                { id = 94946, slot = "Legs", name = "Leggings of the Malformed Sapling", sources = { [17]=50274, [14]=49757, [15]=50898 } },
                { id = 94945, slot = "Off-hand", name = "Greatshield of the Gloaming", sources = { [17]=50278, [14]=49756, [15]=50902 } },
                { id = 94941, slot = "Shoulder", name = "Metabolically Boosted Shoulderplates", sources = { [17]=50267, [14]=49752, [15]=50891 } },
                { id = 94950, slot = "Shoulder", name = "Spaulders of Primordial Growth", sources = { [17]=50277, [14]=49761, [15]=50901 } },
                { id = 94937, slot = "Weapon", name = "Acid-Spine Bonemace", sources = { [17]=50269, [14]=49748, [15]=50893 } },
                { id = 94952, slot = "Wrist", name = "Bonemender Bracers", sources = { [17]=50276, [14]=49763, [15]=50900 } },
                { id = 94948, slot = "Wrist", name = "Bracers of Fragile Bone", sources = { [17]=50273, [14]=49759, [15]=50897 } },
                { id = 94940, slot = "Wrist", name = "Bracers of Mutagenic Fervor", sources = { [17]=50263, [14]=49751, [15]=50887 } },
            },
            specialLoot = {
                { id = 97960, kind = "pet", name = "Dark Quivering Blob", normalHeroicOnly = true },
                { id = 97959, kind = "pet", name = "Quivering Blob", lfrOnly = true },
            },
        },
        {
            index              = 9,
            name               = "Dark Animus",
            journalEncounterID = 824,
            aliases            = {},
            achievements       = {
                { id = 8081, name = "Ritualist Who?", meta = true, soloable = "kinda" },
                { id = 8064, name = "Heroic: Dark Animus", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94960, slot = "Back", name = "Constantly Accelerating Cloak", sources = { [17]=50281, [14]=49771, [15]=50905 } },
                { id = 94957, slot = "Hands", name = "Anima-Ringed Fingers", sources = { [17]=50284, [14]=49768, [15]=50908 } },
                { id = 94958, slot = "Head", name = "Crown of the Golden Golem", sources = { [17]=50286, [14]=49769, [15]=50910 } },
                { id = 94959, slot = "Head", name = "Hood of the Crimson Wake", sources = { [17]=50280, [14]=49770, [15]=50904 } },
                { id = 94956, slot = "Legs", name = "Matter-Swapped Legplates", sources = { [17]=50285, [14]=49767, [15]=50909 } },
                { id = 94962, slot = "Legs", name = "Worldbinder Leggings", sources = { [17]=50283, [14]=49772, [15]=50907 } },
                { id = 94955, slot = "Weapon", name = "Athame of the Sanguine Ritual", sources = { [17]=50282, [14]=49766, [15]=50906 } },
                { id = 94954, slot = "Weapon", name = "Hand of the Dark Animus", sources = { [17]=50279, [14]=49765, [15]=50903 } },
                { id = 95331, slot = "Chest", name = "Battleplate of the Last Mogu", sources = { [17]=50465, [14]=50073, [15]=51089 }, classes = { 1 } },
                { id = 95335, slot = "Chest", name = "Chestguard of the Last Mogu", sources = { [17]=50469, [14]=50077, [15]=51093 }, classes = { 1 } },
                { id = 95280, slot = "Chest", name = "Lightning Emperor's Battleplate", sources = { [17]=50396, [14]=50022, [15]=51020 }, classes = { 2 } },
                { id = 95285, slot = "Chest", name = "Lightning Emperor's Breastplate", sources = { [17]=50401, [14]=50027, [15]=51025 }, classes = { 2 } },
                { id = 95290, slot = "Chest", name = "Lightning Emperor's Chestguard", sources = { [17]=50406, [14]=50032, [15]=51030 }, classes = { 2 } },
                { id = 95255, slot = "Chest", name = "Saurok Stalker's Tunic", sources = { [17]=50371, [14]=49997, [15]=50995 }, classes = { 3 } },
                { id = 95305, slot = "Chest", name = "Nine-Tailed Tunic", sources = { [17]=50421, [14]=50047, [15]=51045 }, classes = { 4 } },
                { id = 95298, slot = "Chest", name = "Robes of the Exorcist", sources = { [17]=50414, [14]=50040, [15]=51038 }, classes = { 5 } },
                { id = 95303, slot = "Chest", name = "Raiment of the Exorcist", sources = { [17]=50419, [14]=50045, [15]=51043 }, classes = { 5 } },
                { id = 95225, slot = "Chest", name = "Breastplate of the All-Consuming Maw", sources = { [17]=50320, [14]=49967, [15]=50944 }, classes = { 6 } },
                { id = 95230, slot = "Chest", name = "Chestguard of the All-Consuming Maw", sources = { [17]=50325, [14]=49972, [15]=50949 }, classes = { 6 } },
                { id = 95310, slot = "Chest", name = "Tunic of the Witch Doctor", sources = { [17]=50426, [14]=50052, [15]=51050 }, classes = { 7 } },
                { id = 95315, slot = "Chest", name = "Cuirass of the Witch Doctor", sources = { [17]=50431, [14]=50057, [15]=51055 }, classes = { 7 } },
                { id = 95320, slot = "Chest", name = "Hauberk of the Witch Doctor", sources = { [17]=50436, [14]=50062, [15]=51060 }, classes = { 7 } },
                { id = 95263, slot = "Chest", name = "Robes of the Chromatic Hydra", sources = { [17]=50379, [14]=50005, [15]=51003 }, classes = { 8 } },
                { id = 95328, slot = "Chest", name = "Robes of the Thousandfold Hells", sources = { [17]=50462, [14]=50070, [15]=51086 }, classes = { 9 } },
                { id = 95265, slot = "Chest", name = "Fire-Charm Tunic", sources = { [17]=50381, [14]=50007, [15]=51005 }, classes = { 10 } },
                { id = 95273, slot = "Chest", name = "Fire-Charm Vest", sources = { [17]=50389, [14]=50015, [15]=51013 }, classes = { 10 } },
                { id = 95275, slot = "Chest", name = "Fire-Charm Chestguard", sources = { [17]=50391, [14]=50017, [15]=51015 }, classes = { 10 } },
                { id = 95235, slot = "Chest", name = "Raiment of the Haunted Forest", sources = { [17]=50330, [14]=49977, [15]=50954 }, classes = { 11 } },
                { id = 95243, slot = "Chest", name = "Robes of the Haunted Forest", sources = { [17]=50338, [14]=49985, [15]=50962 }, classes = { 11 } },
                { id = 95248, slot = "Chest", name = "Vestment of the Haunted Forest", sources = { [17]=50343, [14]=49990, [15]=50967 }, classes = { 11 } },
                { id = 95250, slot = "Chest", name = "Tunic of the Haunted Forest", sources = { [17]=50345, [14]=49992, [15]=50969 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 94152, kind = "pet", name = "Son of Animus" },
            },
        },
        {
            index              = 10,
            name               = "Iron Qon",
            journalEncounterID = 817,
            aliases            = {},
            achievements       = {
                { id = 8087, name = "Can't Touch This", meta = true, soloable = "yes" },
                { id = 8065, name = "Heroic: Iron Qon", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94969, slot = "Chest", name = "Ro'shak's Molten Chain", sources = { [17]=50294, [14]=49779, [15]=50918 } },
                { id = 94968, slot = "Feet", name = "Dam'ren's Frozen Footguards", sources = { [17]=50291, [14]=49778, [15]=50915 } },
                { id = 94967, slot = "Feet", name = "Spurs of the Storm Cavalry", sources = { [17]=50293, [14]=49777, [15]=50917 } },
                { id = 94972, slot = "Hands", name = "Rein-Binder's Fists", sources = { [17]=50295, [14]=49782, [15]=50919 } },
                { id = 94965, slot = "Held In Off-hand", name = "Orb of Arcing Lightning", sources = { [17]=50292, [14]=49775, [15]=50916 } },
                { id = 94966, slot = "Legs", name = "Saddle-Scarred Leggings", sources = { [17]=50290, [14]=49776, [15]=50914 } },
                { id = 94963, slot = "Ranged", name = "Voice of the Quilen", sources = { [17]=50288, [14]=49773, [15]=50912 } },
                { id = 94970, slot = "Waist", name = "Quet'zal's Crackling Cord", sources = { [17]=50289, [14]=49780, [15]=50913 } },
                { id = 94971, slot = "Weapon", name = "Iron Qon's Boot Knife", sources = { [17]=50287, [14]=49781, [15]=50911 } },
                { id = 94964, slot = "Weapon", name = "Qon's Flaming Scimitar", sources = { [17]=50296, [14]=49774, [15]=50920 } },
                { id = 95334, slot = "Shoulder", name = "Pauldrons of the Last Mogu", sources = { [17]=50468, [14]=50076, [15]=51092 }, classes = { 1 } },
                { id = 95339, slot = "Shoulder", name = "Shoulderguards of the Last Mogu", sources = { [17]=50473, [14]=50081, [15]=51097 }, classes = { 1 } },
                { id = 95284, slot = "Shoulder", name = "Lightning Emperor's Pauldrons", sources = { [17]=50400, [14]=50026, [15]=51024 }, classes = { 2 } },
                { id = 95289, slot = "Shoulder", name = "Lightning Emperor's Mantle", sources = { [17]=50405, [14]=50031, [15]=51029 }, classes = { 2 } },
                { id = 95294, slot = "Shoulder", name = "Lightning Emperor's Shoulderguards", sources = { [17]=50410, [14]=50036, [15]=51034 }, classes = { 2 } },
                { id = 95259, slot = "Shoulder", name = "Saurok Stalker's Spaulders", sources = { [17]=50375, [14]=50001, [15]=50999 }, classes = { 3 } },
                { id = 95309, slot = "Shoulder", name = "Nine-Tailed Spaulders", sources = { [17]=50425, [14]=50051, [15]=51049 }, classes = { 4 } },
                { id = 95299, slot = "Shoulder", name = "Mantle of the Exorcist", sources = { [17]=50415, [14]=50041, [15]=51039 }, classes = { 5 } },
                { id = 95304, slot = "Shoulder", name = "Shoulderguards of the Exorcist", sources = { [17]=50420, [14]=50046, [15]=51044 }, classes = { 5 } },
                { id = 95229, slot = "Shoulder", name = "Pauldrons of the All-Consuming Maw", sources = { [17]=50324, [14]=49971, [15]=50948 }, classes = { 6 } },
                { id = 95234, slot = "Shoulder", name = "Shoulderguards of the All-Consuming Maw", sources = { [17]=50329, [14]=49976, [15]=50953 }, classes = { 6 } },
                { id = 95314, slot = "Shoulder", name = "Mantle of the Witch Doctor", sources = { [17]=50430, [14]=50056, [15]=51054 }, classes = { 7 } },
                { id = 95319, slot = "Shoulder", name = "Spaulders of the Witch Doctor", sources = { [17]=50435, [14]=50061, [15]=51059 }, classes = { 7 } },
                { id = 95324, slot = "Shoulder", name = "Shoulderwraps of the Witch Doctor", sources = { [17]=50440, [14]=50066, [15]=51064 }, classes = { 7 } },
                { id = 95264, slot = "Shoulder", name = "Mantle of the Chromatic Hydra", sources = { [17]=50380, [14]=50006, [15]=51004 }, classes = { 8 } },
                { id = 95329, slot = "Shoulder", name = "Mantle of the Thousandfold Hells", sources = { [17]=50463, [14]=50071, [15]=51087 }, classes = { 9 } },
                { id = 95269, slot = "Shoulder", name = "Fire-Charm Spaulders", sources = { [17]=50385, [14]=50011, [15]=51009 }, classes = { 10 } },
                { id = 95274, slot = "Shoulder", name = "Fire-Charm Mantle", sources = { [17]=50390, [14]=50016, [15]=51014 }, classes = { 10 } },
                { id = 95279, slot = "Shoulder", name = "Fire-Charm Shoulderguards", sources = { [17]=50395, [14]=50021, [15]=51019 }, classes = { 10 } },
                { id = 95239, slot = "Shoulder", name = "Spaulders of the Haunted Forest", sources = { [17]=50334, [14]=49981, [15]=50958 }, classes = { 11 } },
                { id = 95244, slot = "Shoulder", name = "Mantle of the Haunted Forest", sources = { [17]=50339, [14]=49986, [15]=50963 }, classes = { 11 } },
                { id = 95249, slot = "Shoulder", name = "Shoulderwraps of the Haunted Forest", sources = { [17]=50344, [14]=49991, [15]=50968 }, classes = { 11 } },
                { id = 95254, slot = "Shoulder", name = "Shoulderguards of the Haunted Forest", sources = { [17]=50349, [14]=49996, [15]=50973 }, classes = { 11 } },
            },
        },
        {
            index              = 11,
            name               = "Twin Empyreans",
            journalEncounterID = 829,
            aliases            = {},
            achievements       = {
                { id = 8066, name = "Heroic: Twin Empyreans", meta = true, soloable = "yes" },
                { id = 8086, name = "From Dusk 'til Dawn", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 94977, slot = "Chest", name = "Robes of the Moon Lotus", sources = { [17]=50298, [14]=49787, [15]=50922 } },
                { id = 94976, slot = "Feet", name = "Tidal Force Treads", sources = { [17]=50303, [14]=49786, [15]=50927 } },
                { id = 94757, slot = "Hands", name = "Fingers of the Night", sources = { [17]=50304, [14]=49611, [15]=50928 } },
                { id = 95515, slot = "Off-hand", name = "Shield of Twinned Despair", sources = { [17]=50299, [14]=50122, [15]=50923 } },
                { id = 94974, slot = "Two-Hand", name = "Suen-Wo, Spire of the Falling Sun", sources = { [17]=50300, [14]=49784, [15]=50924 } },
                { id = 94978, slot = "Waist", name = "Girdle of Night and Day", sources = { [17]=50302, [14]=49788, [15]=50926 } },
                { id = 94973, slot = "Weapon", name = "Wu-Lai, Bladed Fan of the Empyreans", sources = { [17]=50297, [14]=49783, [15]=50921 } },
                { id = 94979, slot = "Wrist", name = "Bracers of the Midnight Comet", sources = { [17]=50301, [14]=49789, [15]=50925 } },
                { id = 95330, slot = "Head", name = "Helmet of the Last Mogu", sources = { [17]=50464, [14]=50072, [15]=51088 }, classes = { 1 } },
                { id = 95337, slot = "Head", name = "Faceguard of the Last Mogu", sources = { [17]=50471, [14]=50079, [15]=51095 }, classes = { 1 } },
                { id = 95282, slot = "Head", name = "Lightning Emperor's Helmet", sources = { [17]=50398, [14]=50024, [15]=51022 }, classes = { 2 } },
                { id = 95287, slot = "Head", name = "Lightning Emperor's Headguard", sources = { [17]=50403, [14]=50029, [15]=51027 }, classes = { 2 } },
                { id = 95292, slot = "Head", name = "Lightning Emperor's Faceguard", sources = { [17]=50408, [14]=50034, [15]=51032 }, classes = { 2 } },
                { id = 95257, slot = "Head", name = "Saurok Stalker's Headguard", sources = { [17]=50373, [14]=49999, [15]=50997 }, classes = { 3 } },
                { id = 95307, slot = "Head", name = "Nine-Tailed Helmet", sources = { [17]=50423, [14]=50049, [15]=51047 }, classes = { 4 } },
                { id = 95296, slot = "Head", name = "Cowl of the Exorcist", sources = { [17]=50412, [14]=50038, [15]=51036 }, classes = { 5 } },
                { id = 95301, slot = "Head", name = "Hood of the Exorcist", sources = { [17]=50417, [14]=50043, [15]=51041 }, classes = { 5 } },
                { id = 95227, slot = "Head", name = "Helmet of the All-Consuming Maw", sources = { [17]=50322, [14]=49969, [15]=50946 }, classes = { 6 } },
                { id = 95232, slot = "Head", name = "Faceguard of the All-Consuming Maw", sources = { [17]=50327, [14]=49974, [15]=50951 }, classes = { 6 } },
                { id = 95312, slot = "Head", name = "Faceguard of the Witch Doctor", sources = { [17]=50428, [14]=50054, [15]=51052 }, classes = { 7 } },
                { id = 95317, slot = "Head", name = "Helmet of the Witch Doctor", sources = { [17]=50433, [14]=50059, [15]=51057 }, classes = { 7 } },
                { id = 95322, slot = "Head", name = "Headpiece of the Witch Doctor", sources = { [17]=50438, [14]=50064, [15]=51062 }, classes = { 7 } },
                { id = 95261, slot = "Head", name = "Hood of the Chromatic Hydra", sources = { [17]=50377, [14]=50003, [15]=51001 }, classes = { 8 } },
                { id = 95326, slot = "Head", name = "Hood of the Thousandfold Hells", sources = { [17]=50460, [14]=50068, [15]=51084 }, classes = { 9 } },
                { id = 95267, slot = "Head", name = "Fire-Charm Headpiece", sources = { [17]=50383, [14]=50009, [15]=51007 }, classes = { 10 } },
                { id = 95271, slot = "Head", name = "Fire-Charm Helm", sources = { [17]=50387, [14]=50013, [15]=51011 }, classes = { 10 } },
                { id = 95277, slot = "Head", name = "Fire-Charm Crown", sources = { [17]=50393, [14]=50019, [15]=51017 }, classes = { 10 } },
                { id = 95237, slot = "Head", name = "Headpiece of the Haunted Forest", sources = { [17]=50332, [14]=49979, [15]=50956 }, classes = { 11 } },
                { id = 95241, slot = "Head", name = "Helm of the Haunted Forest", sources = { [17]=50336, [14]=49983, [15]=50960 }, classes = { 11 } },
                { id = 95246, slot = "Head", name = "Cover of the Haunted Forest", sources = { [17]=50341, [14]=49988, [15]=50965 }, classes = { 11 } },
                { id = 95252, slot = "Head", name = "Headguard of the Haunted Forest", sources = { [17]=50347, [14]=49994, [15]=50971 }, classes = { 11 } },
            },
        },
        {
            index              = 12,
            name               = "Lei Shen",
            journalEncounterID = 832,
            aliases            = {},
            achievements       = {
                { id = 8090, name = "A Complete Circuit", meta = true, soloable = "kinda" },
                { id = 8072, name = "Pinnacle of Storms", meta = false, soloable = "yes" },
            },
            loot = {
                { id = 94987, slot = "Chest", name = "Fusion Slasher Chestguard", sources = { [17]=50306, [14]=49795, [15]=50930 } },
                { id = 94989, slot = "Chest", name = "Lei Shen's Grounded Carapace", sources = { [17]=50319, [14]=49797, [15]=50943 } },
                { id = 94993, slot = "Hands", name = "Gloves of the Maimed Vizier", sources = { [17]=50314, [14]=49801, [15]=50938 } },
                { id = 94991, slot = "Hands", name = "Grips of Slicing Electricity", sources = { [17]=50317, [14]=49799, [15]=50941 } },
                { id = 94984, slot = "Head", name = "Doomed Crown of Lei Shen", sources = { [17]=50308, [14]=49792, [15]=50932 } },
                { id = 95473, slot = "Held In Off-hand", name = "Lei Shen's Orb of Command", sources = { [17]=50316, [14]=50107, [15]=50940 } },
                { id = 94986, slot = "Legs", name = "Conduit-Breaker Chain Leggings", sources = { [17]=50307, [14]=49794, [15]=50931 } },
                { id = 94992, slot = "Legs", name = "Leggings of the Violent Gale", sources = { [17]=50318, [14]=49800, [15]=50942 } },
                { id = 94985, slot = "Legs", name = "Legplates of Whipping Ionization", sources = { [17]=50310, [14]=49793, [15]=50934 } },
                { id = 95535, slot = "Legs", name = "Legplates of the Lightning Throne", sources = { [17]=50309, [14]=50142, [15]=50933 } },
                { id = 94990, slot = "Legs", name = "Legwraps of Cardinality", sources = { [17]=50313, [14]=49798, [15]=50937 } },
                { id = 95472, slot = "Off-hand", name = "Ultimate Protection of the Emperor", sources = { [17]=50312, [14]=50106, [15]=50936 } },
                { id = 94983, slot = "Two-Hand", name = "Shan-Dun, Breaker of Hope", sources = { [17]=50305, [14]=49791, [15]=50929 } },
                { id = 94982, slot = "Two-Hand", name = "Uroe, Harbinger of Terror", sources = { [17]=50311, [14]=49790, [15]=50935 } },
                { id = 94988, slot = "Weapon", name = "Torall, Rod of the Shattered Throne", sources = { [17]=50315, [14]=49796, [15]=50939 } },
            },
        },
        {
            index              = 13,
            name               = "Ra-den",
            journalEncounterID = 831,
            -- Ra-den is a hidden bonus boss the Encounter Journal doesn't
            -- index, so the EJ-derived journal->dungeon map has no entry for
            -- him. Supply the dungeonEncounterID directly (observed from the
            -- live ENCOUNTER_END event) so kill detection and lockout-based
            -- completion can resolve him like every other boss.
            dungeonEncounterID = 1581,
            aliases            = {},
            achievements       = {},
            -- Ra-den is a Heroic-only encounter: he does not exist on Normal
            -- or LFR. This restricts kill-count denominators, the routing
            -- picker, and the boss-progress display to the Heroic bucket
            -- (15). Without it the Normal pill would cap at 12/13 forever
            -- and the panel would route toward a boss that can't be engaged.
            availableDifficulties = { 15 },
            loot = {
                { id = 95013, slot = "Back", name = "Black Night Thundercloak", sources = { [15]=49820 } },
                { id = 95015, slot = "Back", name = "Grey Wind Mistcloak", sources = { [15]=49822 } },
                { id = 95014, slot = "Back", name = "Red Sky Cloudcloak", sources = { [15]=49821 } },
                { id = 95016, slot = "Back", name = "White Snow Skycloak", sources = { [15]=49823 } },
                { id = 95017, slot = "Back", name = "Yellow Dawn Lightningcloak", sources = { [15]=49824 } },
                { id = 95038, slot = "Chest", name = "Carapace of the Core", sources = { [15]=49840 } },
                { id = 95035, slot = "Chest", name = "Chains of Counted Souls", sources = { [15]=49837 } },
                { id = 95033, slot = "Chest", name = "Chestguard of Coruscating Blades", sources = { [15]=49835 } },
                { id = 95036, slot = "Chest", name = "Nova-Binder Breastplate", sources = { [15]=49838 } },
                { id = 95037, slot = "Chest", name = "Planet-Birthed Cuirass", sources = { [15]=49839 } },
                { id = 95032, slot = "Chest", name = "Robes of Contagious Time", sources = { [15]=49834 } },
                { id = 95040, slot = "Chest", name = "Robes of Nova", sources = { [15]=49842 } },
                { id = 95034, slot = "Chest", name = "Scales of Shaped Flesh", sources = { [15]=49836 } },
                { id = 95039, slot = "Chest", name = "Starburner Robes", sources = { [15]=49841 } },
                { id = 95010, slot = "Feet", name = "Hypersensitive Sollerets", sources = { [15]=49817 } },
                { id = 95011, slot = "Feet", name = "Lightning-Walker Clawfeet", sources = { [15]=49818 } },
                { id = 95006, slot = "Feet", name = "Roots of Pain", sources = { [15]=49813 } },
                { id = 95012, slot = "Feet", name = "Sabatons of the Superior Being", sources = { [15]=49819 } },
                { id = 95004, slot = "Feet", name = "Starwalker Sandals", sources = { [15]=49811 } },
                { id = 95005, slot = "Feet", name = "Treads of Delicate Fascia", sources = { [15]=49812 } },
                { id = 95009, slot = "Feet", name = "Treads of the Sanguine Volley", sources = { [15]=49816 } },
                { id = 95007, slot = "Feet", name = "Twist-Toe Tabi", sources = { [15]=49814 } },
                { id = 95008, slot = "Feet", name = "World-Mote Sabatons", sources = { [15]=49815 } },
                { id = 95025, slot = "Legs", name = "Archaic Protector's Legguards", sources = { [15]=49827 } },
                { id = 95028, slot = "Legs", name = "Cosmicfire Legwraps", sources = { [15]=49830 } },
                { id = 95029, slot = "Legs", name = "Kilt of Perpetual Genuflection", sources = { [15]=49831 } },
                { id = 95030, slot = "Legs", name = "Leggings of the Discarded Warning", sources = { [15]=49832 } },
                { id = 95027, slot = "Legs", name = "Legguards of Awaked Repair", sources = { [15]=49829 } },
                { id = 95031, slot = "Legs", name = "Legguards of Surreal Visions", sources = { [15]=49833 } },
                { id = 95023, slot = "Legs", name = "Legplates of Lightning Blood", sources = { [15]=49825 } },
                { id = 95026, slot = "Legs", name = "Sparkstring Chain Leggings", sources = { [15]=49828 } },
                { id = 95024, slot = "Legs", name = "Time-Lost Greaves", sources = { [15]=49826 } },
                { id = 95001, slot = "Waist", name = "Bubbling Anima Belt", sources = { [15]=49808 } },
                { id = 95002, slot = "Waist", name = "Cracklesnap Clasp", sources = { [15]=49809 } },
                { id = 94995, slot = "Waist", name = "Detonation Cord", sources = { [15]=49802 } },
                { id = 95003, slot = "Waist", name = "Flare-Forged Greatbelt", sources = { [15]=49810 } },
                { id = 95000, slot = "Waist", name = "Jingling Fetishgirdle", sources = { [15]=49807 } },
                { id = 94999, slot = "Waist", name = "Longdraw Chain Belt", sources = { [15]=49806 } },
                { id = 94998, slot = "Waist", name = "Strap of Murderous Strikes", sources = { [15]=49805 } },
                { id = 94996, slot = "Waist", name = "Vita-Binder Wrap", sources = { [15]=49803 } },
                { id = 94997, slot = "Waist", name = "Worldbender Waistband", sources = { [15]=49804 } },
            },
        },
    },

    routing = {

        -- 1. Jin'rokh the Breaker
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Jin'rokh the Breaker",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 508, subZone = "Ruined Approach" },
                    kind    = "path",
                    note    = "After zoning in, make your way to the other end of the room. Open the door to find ^Jin'rokh the Breaker^.",
                    points  = {
                        { 0.332, 0.256 },
                        { 0.356, 0.234 },
                        { 0.405, 0.234 },
                        { 0.436, 0.216 },
                        { 0.457, 0.214 },
                        { 0.473, 0.256 },
                        { 0.570, 0.258 },
                    },
                },
            },
        },

        -- 2. Horridon
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Horridon",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 508, subZone = "Overgrown Statuary" },
                    kind    = "path",
                    note    = "After killing ^Jin'rokh^, take the long path south and cross two bridges before arriving in the next area. Avoid blue circles; they will throw you off the edge.",
                    points  = {
                        { 0.595, 0.315 },
                        { 0.593, 0.452 },
                        { 0.617, 0.464 },
                        { 0.618, 0.498 },
                        { 0.594, 0.533 },
                        { 0.594, 0.791 },
                        { 0.843, 0.792 },
                    },
                },
                {
                    when    = { mapID = 509, subZone = "Ruined Approach" },
                    kind    = "path",
                    note    = "Open the door in front of you to land in ^Horridon^'s room. After a brief dialog, kill the boss.",
                    points  = {
                        { 0.190, 0.786 },
                        { 0.245, 0.786 },
                    },
                },
            },
        },

        -- 3. Council of Elders
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Council of Elders",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 509, subZone = "Royal Amphitheater" },
                    kind    = "path",
                    note    = "After killing ^Horridon^, go through the north exit and follow the path all the way to ^Council of Elders^. Kill trash to unlock doors along the way.",
                    points  = {
                        { 0.270, 0.681 },
                        { 0.267, 0.199 },
                        { 0.409, 0.192 },
                        { 0.410, 0.237 },
                        { 0.462, 0.239 },
                        { 0.491, 0.225 },
                    },
                },
            },
        },

        -- 4. Tortos
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Tortos",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 509, subZone = "Lightning Promenade" },
                    kind    = "path",
                    note    = "After defeating ^Council of Elders^, go through the door behind them. As you cross the bridge, there will be a cutscene and you will fall below.",
                    points  = {
                        { 0.531, 0.193 },
                        { 0.758, 0.193 },
                    },
                },
                {
                    when    = { mapID = 510, subZone = "Lair of Tortos" },
                    kind    = "path",
                    note    = "In the next area, move ahead into the cave to engage ^Tortos^.",
                    points  = {
                        { 0.177, 0.810 },
                        { 0.289, 0.823 },
                    },
                },
            },
        },

        -- 5. Megaera
        -- Spawned by destroying three bells in the room; the note describes
        -- the requirement and the bells are marked on the map. Routing is a
        -- straight path -- no per-bell tracking.
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Megaera",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 510, subZone = "Forgotten Depths" },
                    kind    = "path",
                    note    = "After defeating ^Tortos^, walk through him to reach the next area. To spawn ^Megaera^, you must destroy the (3) bells marked on the map, which are protected by ^Eternal Guardians^.",
                    points  = {},
                },
                {
                    when     = { mapID = 510, subZone = "Forgotten Depths" },
                    kind     = "poi",
                    mapLabel = "Bell",
                    points  = {
                        { 0.318, 0.460 },
                    },
                },
                {
                    when     = { mapID = 510, subZone = "Forgotten Depths" },
                    kind     = "poi",
                    mapLabel = "Bell",
                    points  = {
                        { 0.498, 0.147 },
                    },
                },
                {
                    when     = { mapID = 510, subZone = "Forgotten Depths" },
                    kind     = "poi",
                    mapLabel = "Bell",
                    points  = {
                        { 0.568, 0.730 },
                    },
                },
                {
                    when    = { mapID = 510, subZone = "Forgotten Depths" },
                    kind    = "path",
                    points  = {
                        { 0.617, 0.383 },
                        { 0.690, 0.287 },
                    },
                },
            },
        },

        -- 6. Ji-Kun
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Ji-Kun",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 510, subZone = "Forgotten Depths" },
                    kind    = "path",
                    note    = "After defeating ^Megaera^, take the new exit on the east side of the room.",
                    points  = {
                        { 0.676, 0.308 },
                        { 0.656, 0.457 },
                        { 0.735, 0.528 },
                        { 0.744, 0.570 },
                    },
                },
                {
                    when    = { mapID = 511, subZone = "Roost of Ji-Kun" },
                    kind    = "path",
                    note    = "Inside the ^Roost of Ji-Kun^, make your way up and around the long series of paths and stairwells until you reach the platform of ^Ji-Kun^. Avoid the snails; they will still 1-shot you.",
                    points  = {
                        { 0.218, 0.218 },
                        { 0.219, 0.307 },
                        { 0.192, 0.405 },
                        { 0.162, 0.496 },
                        { 0.145, 0.608 },
                        { 0.181, 0.663 },
                        { 0.273, 0.619 },
                        { 0.340, 0.736 },
                        { 0.436, 0.810 },
                        { 0.431, 0.873 },
                        { 0.448, 0.924 },
                        { 0.487, 0.950 },
                        { 0.524, 0.940 },
                        { 0.554, 0.899 },
                        { 0.563, 0.860 },
                        { 0.680, 0.818 },
                        { 0.749, 0.740 },
                        { 0.780, 0.659 },
                        { 0.654, 0.558 },
                        { 0.530, 0.444 },
                    },
                },
            },
        },

        -- 7. Durumu the Forgotten
        -- Exit is a two-step interactable: click a feather, then use the
        -- Extra Action Button to fly to the southwest exit. Two labeled POIs
        -- mark the spots ("Click Feather" -> "Fly Here").
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Durumu the Forgotten",
            requires  = {},
            segments  = {
                {
                    when        = { mapID = 511, subZone = "Roost of Ji-Kun" },
                    kind        = "poi",
                    mapLabel    = "Click Feather",
                    mapLabelPos = "above",
                    note    = "After killing ^Ji-Kun^, click a feather followed by your Extra Action Button to fly to the southwest exit of the room.",
                    points  = {
                        { 0.429, 0.474 },
                    },
                },
                {
                    when        = { mapID = 511, subZone = "Roost of Ji-Kun" },
                    kind        = "poi",
                    mapLabel    = "Fly Here",
                    mapLabelPos = "above",
                    points  = {
                        { 0.339, 0.553 },
                    },
                },
                {
                    when    = { mapID = 512, subZone = "Refuse Disposal" },
                    kind    = "path",
                    note    = "After landing, continue ahead to find ^Durumu the Forgotten^. Clear all trash in the room to spawn the boss.",
                    points  = {
                        { 0.752, 0.091 },
                        { 0.711, 0.099 },
                        { 0.710, 0.154 },
                        { 0.690, 0.166 },
                        { 0.685, 0.192 },
                        { 0.684, 0.213 },
                        { 0.707, 0.298 },
                    },
                },
            },
        },

        -- 8. Primordius
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Primordius",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 512, subZone = "Watcher's Sanctum" },
                    kind    = "path",
                    note    = "After defeating ^Durumu^, follow the linear path through several sets of stairs and make your way to ^Primordius^.",
                    points  = {
                        { 0.711, 0.377 },
                        { 0.711, 0.516 },
                        { 0.731, 0.526 },
                        { 0.743, 0.546 },
                        { 0.746, 0.573 },
                        { 0.739, 0.596 },
                        { 0.712, 0.622 },
                        { 0.710, 0.737 },
                        { 0.730, 0.742 },
                        { 0.742, 0.758 },
                        { 0.746, 0.781 },
                        { 0.599, 0.781 },
                    },
                },
            },
        },

        -- 9. Dark Animus
        {
            step      = 9,
            priority  = 9,
            bossIndex = 9,
            title     = "Dark Animus",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 512, subZone = "Saurok Creation Pit" },
                    kind    = "path",
                    note    = "After killing ^Primordius^, take the western stairwell out of the room and follow it to ^Dark Animus^. Kill the ritualists to start the fight.",
                    points  = {
                        { 0.548, 0.783 },
                        { 0.391, 0.779 },
                        { 0.396, 0.753 },
                        { 0.414, 0.734 },
                        { 0.426, 0.730 },
                        { 0.424, 0.608 },
                    },
                },
            },
        },

        -- 10. Iron Qon
        -- Two legs: the approach through Halls of Flesh-Shaping (mapID 512)
        -- to a masked gate, then the courtyard beyond (mapID 513). The
        -- mapID/subZone change across the gate drives the advance; no
        -- explicit gate field is needed (the recorder's gateBySubZone is an
        -- unused field and is intentionally omitted).
        {
            step      = 10,
            priority  = 10,
            bossIndex = 10,
            title     = "Iron Qon",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 512, subZone = "Halls of Flesh-Shaping" },
                    kind    = "path",
                    note    = "After defeating ^Dark Animus^, take the northern stairwell out of the room and follow the path to open a masked gate.",
                    points  = {
                        { 0.384, 0.485 },
                        { 0.383, 0.429 },
                        { 0.333, 0.428 },
                        { 0.332, 0.314 },
                        { 0.466, 0.315 },
                        { 0.466, 0.176 },
                    },
                },
                {
                    when    = { mapID = 513, subZone = "Grand Courtyard" },
                    kind    = "path",
                    note    = "On the other side of the gate, proceed ahead to engage ^Iron Qon^.",
                    points  = {
                        { 0.204, 0.659 },
                        { 0.247, 0.596 },
                        { 0.317, 0.592 },
                    },
                },
            },
        },

        -- 11. Twin Empyreans
        {
            step      = 11,
            priority  = 11,
            bossIndex = 11,
            title     = "Twin Empyreans",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 513, subZone = "Grand Courtyard" },
                    kind    = "path",
                    note    = "After defeating ^Iron Qon^, proceed through the new door behind them and follow the linear path to the ^Twin Empyreans^.",
                    points  = {
                        { 0.402, 0.588 },
                        { 0.614, 0.590 },
                        { 0.638, 0.549 },
                        { 0.684, 0.519 },
                        { 0.755, 0.423 },
                    },
                },
            },
        },

        -- 12. Lei Shen
        -- Two legs: the stair climb out of Grand Courtyard through
        -- Celestial Enclave (mapID 513), then a Displacement Pad teleport
        -- to the Pinnacle of Storms (mapID 514) where Lei Shen waits. The
        -- mapID/subZone change drives the advance; the recorder's
        -- gateBySubZone is an unused field and is intentionally omitted.
        {
            step      = 12,
            priority  = 12,
            bossIndex = 12,
            title     = "Lei Shen",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 513, subZone = "Celestial Enclave" },
                    kind    = "path",
                    note    = "After killing the ^Twin Empyreans^, take the southeastern exit from the room.",
                    points  = {
                        { 0.804, 0.415 },
                        { 0.892, 0.545 },
                        { 0.847, 0.626 },
                        { 0.857, 0.709 },
                        { 0.887, 0.759 },
                    },
                },
                {
                    when     = { mapID = 514, subZone = "Pinnacle of Storms" },
                    kind     = "poi",
                    mapLabel = "Click Displacement Pad",
                    note     = "At the top of the stairs, walk through a door and click on the ^Displacement Pad^. After landing, engage ^Lei Shen^.",
                    points   = {
                        { 0.501, 0.157 },
                    },
                },
            },
        },

        -- 13. Ra-den (Heroic only)
        -- Hidden bonus boss, unlocked only by clearing Lei Shen on Heroic.
        -- After Lei Shen dies, a Displacement Pad in his room teleports the
        -- player back to Primordius's room, then a spiral stairwell leads
        -- down to Ra-den. Two label-only POIs (noMarker) mark the pad and
        -- the stairwell. The picker excludes this step on Normal
        -- (availableDifficulties = {15}).
        {
            step      = 13,
            priority  = 13,
            bossIndex = 13,
            title     = "Ra-den",
            requires  = {},
            segments  = {
                {
                    when        = { mapID = 514, subZone = "Pinnacle of Storms" },
                    kind        = "poi",
                    noMarker    = true,
                    mapLabel    = "Displacement Pad",
                    mapLabelPos = "below",
                    note        = "After killing ^Lei Shen^, click the ^Displacement Pad^ in the middle of the room to be teleported back to ^Primordius^' room.",
                    points  = {
                        { 0.507, 0.542 },
                    },
                },
                {
                    when        = { mapID = 512, subZone = "Saurok Creation Pit" },
                    kind        = "poi",
                    noMarker    = true,
                    mapLabel    = "Stairwell",
                    mapLabelPos = "below",
                    note        = "After teleporting, take the spiral stairwell down in the middle of the room.",
                    points  = {
                        { 0.572, 0.815 },
                    },
                },
                {
                    when    = { mapID = 515, subZone = "Hidden Cell" },
                    kind    = "path",
                    note    = "After reaching the bottom of the stairs, proceed forward to trigger a lengthy dialog, then engage ^Ra-den^.",
                    points  = {
                        { 0.521, 0.509 },
                        { 0.523, 0.772 },
                    },
                },
            },
        },

    },
}
