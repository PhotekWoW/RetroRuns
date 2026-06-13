-------------------------------------------------------------------------------
-- RetroRuns Data -- Terrace of Endless Spring
-- Mists of Pandaria, Patch 5.0.4  |  instanceID: 996  |  journalInstanceID: 320
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[996] = {
    instanceID        = 996,
    journalInstanceID = 320,
    name              = "Terrace of Endless Spring",
    expansion         = "Mists of Pandaria",
    patch             = "5.0.4",

    exitNote = "None available",

    -- Pandaria-era raids split lockouts by raid size (10 and 25) rather
    -- than offering Mythic. Loot is shared across sizes, so the two
    -- Normal lockouts fold into one Normal bucket and the two Heroic
    -- lockouts into one Heroic; Raid Finder stands alone. This tells the
    -- difficulty engine to fold that way instead of the modern scheme.
    difficultyModel   = "mop",

    entrance = {
        mapID = 433,
        x     = 0.4840,
        y     = 0.6140,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [456] = "Terrace of Endless Spring",
    },

    tierSets = {
        labels = {
            -- Tier 14 spans Heart of Fear, Terrace of Endless
            -- Spring, and the Sha of Anger world boss. Terrace of
            -- Endless Spring drops the Shoulder and Head tokens.
        },
        tokenSources = {
            [89246] = 3,  -- Shoulders of the Shadowy Conqueror
            [89247] = 3,  -- Shoulders of the Shadowy Protector
            [89248] = 3,  -- Shoulders of the Shadowy Vanquisher
            [89261] = 3,  -- Shoulders of the Shadowy Vanquisher
            [89262] = 3,  -- Shoulders of the Shadowy Conqueror
            [89263] = 3,  -- Shoulders of the Shadowy Protector
            [89276] = 3,  -- Shoulders of the Shadowy Vanquisher
            [89277] = 3,  -- Shoulders of the Shadowy Conqueror
            [89278] = 3,  -- Shoulders of the Shadowy Protector
            [89234] = 4,  -- Helm of the Shadowy Vanquisher
            [89235] = 4,  -- Helm of the Shadowy Conqueror
            [89236] = 4,  -- Helm of the Shadowy Protector
            [89258] = 4,  -- Helm of the Shadowy Vanquisher
            [89259] = 4,  -- Helm of the Shadowy Conqueror
            [89260] = 4,  -- Helm of the Shadowy Protector
            [89273] = 4,  -- Helm of the Shadowy Vanquisher
            [89274] = 4,  -- Helm of the Shadowy Conqueror
            [89275] = 4,  -- Helm of the Shadowy Protector
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
            name               = "Protectors of the Endless",
            journalEncounterID = 683,
            aliases            = {},
            achievements       = {
                { id = 6717, name = "Power Overwhelming", meta = true, soloable = "yes" },
                { id = 6731, name = "Heroic: Protectors of the Endless", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86316, slot = "Back", name = "Cloak of Overwhelming Corruption", sources = { [17]=44742, [14]=44369, [15]=44983 } },
                { id = 86320, slot = "Feet", name = "Asani's Uncleansed Sandals", sources = { [17]=44746, [14]=44373, [15]=44985 } },
                { id = 86232, slot = "Feet", name = "Deepwater Greatboots", sources = { [17]=44741, [14]=44363, [15]=44981 } },
                { id = 86319, slot = "Feet", name = "Lightning Prisoner's Boots", sources = { [17]=44745, [14]=44372, [15]=44986 } },
                { id = 86318, slot = "Head", name = "Casque of Expelled Corruption", sources = { [17]=44744, [14]=44371, [15]=44987 } },
                { id = 90518, slot = "Legs", name = "Legguards of Failing Purification", sources = { [17]=46702, [14]=47058, [15]=47048 } },
                { id = 90519, slot = "Shoulder", name = "Waterborne Shoulderguards", sources = { [17]=46703, [14]=47059, [15]=47049 } },
                { id = 86390, slot = "Weapon", name = "Regail's Crackling Dagger", sources = { [17]=44771, [14]=44398, [15]=44984 } },
                { id = 86230, slot = "Wrist", name = "Bracers of Defiled Earth", sources = { [17]=44740, [14]=44362, [15]=44980 } },
                { id = 86317, slot = "Wrist", name = "Cuffs of the Corrupted Waters", sources = { [17]=44743, [14]=44370, [15]=44982 } },
            },
        },
        {
            index              = 2,
            name               = "Tsulong",
            journalEncounterID = 742,
            aliases            = {},
            achievements       = {
                { id = 6933, name = "Who's Got Two Green Thumbs?", meta = true, soloable = "yes" },
                { id = 6732, name = "Heroic: Tsulong", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86325, slot = "Back", name = "Daybreak Drape", sources = { [17]=44749, [14]=44376, [15]=44990 } },
                { id = 86324, slot = "Chest", name = "Sunwrought Mail Hauberk", sources = { [17]=44748, [14]=44375, [15]=44989 } },
                { id = 86330, slot = "Feet", name = "Sandals of the Blackest Night", sources = { [17]=44753, [14]=44380, [15]=44992 } },
                { id = 86329, slot = "Feet", name = "Sollerets of Instability", sources = { [17]=44752, [14]=44379, [15]=44994 } },
                { id = 89842, slot = "Hands", name = "Gauntlets of the Shadow's Caress", sources = { [17]=46704, [14]=46619, [15]=46673 } },
                { id = 89843, slot = "Hands", name = "Grasps of Serpentine Might", sources = { [17]=46705, [14]=46620, [15]=46674 } },
                { id = 89884, slot = "Legs", name = "Fear-Blackened Leggings", sources = { [17]=46707, [14]=46633, [15]=46676 } },
                { id = 89883, slot = "Shoulder", name = "Shoulderpads of Twisted Fate", sources = { [17]=46706, [14]=46632, [15]=46675 } },
                { id = 86321, slot = "Two-Hand", name = "Gao-Rei, Staff of the Legendary Protector", sources = { [17]=44747, [14]=44374, [15]=44988 } },
                { id = 86326, slot = "Waist", name = "Belt of Embodied Terror", sources = { [17]=44750, [14]=44377, [15]=44991 } },
                { id = 86342, slot = "Waist", name = "Binder's Chain of Unending Summer", sources = { [17]=44763, [14]=44390, [15]=45009 } },
                { id = 86337, slot = "Waist", name = "Healer's Belt of Final Winter", sources = { [17]=44758, [14]=44385, [15]=45004 } },
                { id = 86338, slot = "Waist", name = "Invoker's Belt of Final Winter", sources = { [17]=44759, [14]=44386, [15]=45003 } },
                { id = 86383, slot = "Waist", name = "Mender's Girdle of Endless Spring", sources = { [17]=44765, [14]=44392, [15]=45010 } },
                { id = 86385, slot = "Waist", name = "Patroller's Girdle of Endless Spring", sources = { [17]=44767, [14]=44394, [15]=45012 } },
                { id = 86384, slot = "Waist", name = "Protector's Girdle of Endless Spring", sources = { [17]=44766, [14]=44393, [15]=45011 } },
                { id = 86343, slot = "Waist", name = "Ranger's Chain of Unending Summer", sources = { [17]=44764, [14]=44391, [15]=45008 } },
                { id = 86339, slot = "Waist", name = "Sorcerer's Belt of Final Winter", sources = { [17]=44760, [14]=44387, [15]=45005 } },
                { id = 86341, slot = "Waist", name = "Stalker's Cord of Eternal Autumn", sources = { [17]=44762, [14]=44389, [15]=45006 } },
                { id = 86340, slot = "Waist", name = "Weaver's Cord of Eternal Autumn", sources = { [17]=44761, [14]=44388, [15]=45007 } },
                { id = 86328, slot = "Weapon", name = "Loshan, Terror Incarnate", sources = { [17]=44751, [14]=44378, [15]=44993 } },
            },
            specialLoot = {
                { id = 167051, kind = "pet", name = "Azure Cloud Serpent Egg" },
            },
        },
        {
            index              = 3,
            name               = "Lei Shi",
            journalEncounterID = 729,
            aliases            = {},
            achievements       = {
                { id = 6824, name = "Face Clutchers", meta = true, soloable = "yes" },
                { id = 6733, name = "Heroic: Lei Shi", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86333, slot = "Chest", name = "Cuirass of the Animated Protector", sources = { [17]=44755, [14]=44382, [15]=44999 } },
                { id = 86334, slot = "Chest", name = "Robes of the Unknown Fear", sources = { [17]=44756, [14]=44383, [15]=44997 } },
                { id = 86331, slot = "Ranged", name = "Taoren, the Soul Burner", sources = { [17]=44754, [14]=44381, [15]=44996 } },
                { id = 86335, slot = "Two-Hand", name = "Jin'ya, Orb of the Waterspeaker", sources = { [17]=44757, [14]=44384, [15]=44998 } },
                { id = 86342, slot = "Waist", name = "Binder's Chain of Unending Summer", sources = { [17]=44763, [14]=44390, [15]=45009 } },
                { id = 86337, slot = "Waist", name = "Healer's Belt of Final Winter", sources = { [17]=44758, [14]=44385, [15]=45004 } },
                { id = 86338, slot = "Waist", name = "Invoker's Belt of Final Winter", sources = { [17]=44759, [14]=44386, [15]=45003 } },
                { id = 86383, slot = "Waist", name = "Mender's Girdle of Endless Spring", sources = { [17]=44765, [14]=44392, [15]=45010 } },
                { id = 86385, slot = "Waist", name = "Patroller's Girdle of Endless Spring", sources = { [17]=44767, [14]=44394, [15]=45012 } },
                { id = 86384, slot = "Waist", name = "Protector's Girdle of Endless Spring", sources = { [17]=44766, [14]=44393, [15]=45011 } },
                { id = 86343, slot = "Waist", name = "Ranger's Chain of Unending Summer", sources = { [17]=44764, [14]=44391, [15]=45008 } },
                { id = 86339, slot = "Waist", name = "Sorcerer's Belt of Final Winter", sources = { [17]=44760, [14]=44387, [15]=45005 } },
                { id = 86341, slot = "Waist", name = "Stalker's Cord of Eternal Autumn", sources = { [17]=44762, [14]=44389, [15]=45006 } },
                { id = 86340, slot = "Waist", name = "Weaver's Cord of Eternal Autumn", sources = { [17]=44761, [14]=44388, [15]=45007 } },
                { id = 86391, slot = "Weapon", name = "Spiritsever", sources = { [17]=44772, [14]=44399, [15]=44995 } },
                { id = 86664, slot = "Shoulder", name = "Shoulderguards of Resounding Rings", sources = { [17]=43682, [14]=44562, [15]=45027 }, classes = { 1 } },
                { id = 86669, slot = "Shoulder", name = "Pauldrons of Resounding Rings", sources = { [17]=43687, [14]=44567, [15]=45022 }, classes = { 1 } },
                { id = 86659, slot = "Shoulder", name = "White Tiger Shoulderguards", sources = { [17]=43677, [14]=44557, [15]=44949 }, classes = { 2 } },
                { id = 86679, slot = "Shoulder", name = "White Tiger Pauldrons", sources = { [17]=43697, [14]=44577, [15]=44939 }, classes = { 2 } },
                { id = 86684, slot = "Shoulder", name = "White Tiger Mantle", sources = { [17]=43702, [14]=44582, [15]=44944 }, classes = { 2 } },
                { id = 86634, slot = "Shoulder", name = "Yaungol Slayer's Spaulders", sources = { [17]=43652, [14]=44532, [15]=44859 }, classes = { 3 } },
                { id = 86639, slot = "Shoulder", name = "Spaulders of the Thousandfold Blades", sources = { [17]=43657, [14]=44537, [15]=44964 }, classes = { 4 } },
                { id = 86699, slot = "Shoulder", name = "Guardian Serpent Mantle", sources = { [17]=43717, [14]=44597, [15]=44954 }, classes = { 5 } },
                { id = 86708, slot = "Shoulder", name = "Guardian Serpent Shoulderguards", sources = { [17]=43726, [14]=44606, [15]=44959 }, classes = { 5 } },
                { id = 86654, slot = "Shoulder", name = "Shoulderguards of the Lost Catacomb", sources = { [17]=43672, [14]=44552, [15]=44784 }, classes = { 6 } },
                { id = 86674, slot = "Shoulder", name = "Pauldrons of the Lost Catacomb", sources = { [17]=43692, [14]=44572, [15]=44779 }, classes = { 6 } },
                { id = 86624, slot = "Shoulder", name = "Firebird's Spaulders", sources = { [17]=43642, [14]=44522, [15]=44974 }, classes = { 7 } },
                { id = 86633, slot = "Shoulder", name = "Firebird's Shoulderwraps", sources = { [17]=43651, [14]=44531, [15]=44979 }, classes = { 7 } },
                { id = 86689, slot = "Shoulder", name = "Firebird's Mantle", sources = { [17]=43707, [14]=44587, [15]=44969 }, classes = { 7 } },
                { id = 86714, slot = "Shoulder", name = "Mantle of the Burning Scroll", sources = { [17]=43732, [14]=44612, [15]=44864 }, classes = { 8 } },
                { id = 86713, slot = "Shoulder", name = "Sha-Skin Mantle", sources = { [17]=43731, [14]=44611, [15]=45017 }, classes = { 9 } },
                { id = 86724, slot = "Shoulder", name = "Red Crane Shoulderguards", sources = { [17]=43742, [14]=44622, [15]=44934 }, classes = { 10 } },
                { id = 86733, slot = "Shoulder", name = "Red Crane Mantle", sources = { [17]=43751, [14]=44631, [15]=44929 }, classes = { 10 } },
                { id = 86738, slot = "Shoulder", name = "Red Crane Spaulders", sources = { [17]=43756, [14]=44636, [15]=44924 }, classes = { 10 } },
                { id = 86644, slot = "Shoulder", name = "Eternal Blossom Shoulderwraps", sources = { [17]=43662, [14]=44542, [15]=44799 }, classes = { 11 } },
                { id = 86649, slot = "Shoulder", name = "Eternal Blossom Spaulders", sources = { [17]=43667, [14]=44547, [15]=44789 }, classes = { 11 } },
                { id = 86694, slot = "Shoulder", name = "Eternal Blossom Mantle", sources = { [17]=43712, [14]=44592, [15]=44794 }, classes = { 11 } },
                { id = 86723, slot = "Shoulder", name = "Eternal Blossom Shoulderguards", sources = { [17]=43741, [14]=44621, [15]=44804 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 167052, kind = "pet", name = "Spirit of the Spring" },
            },
        },
        {
            index              = 4,
            name               = "Sha of Fear",
            journalEncounterID = 709,
            aliases            = {},
            achievements       = {
                { id = 6825, name = "The Mind-Killer", meta = true, soloable = "yes" },
                { id = 6734, name = "Heroic: Sha of Fear", meta = false, soloable = "yes" },
            },
            loot = {
                { id = 89887, slot = "Chest", name = "Robes of Pinioned Eyes", sources = { [17]=46708, [14]=46636, [15]=46677 } },
                { id = 89886, slot = "Chest", name = "Wrap of Instant Petrification", sources = { [17]=46709, [14]=46635, [15]=46678 } },
                { id = 86389, slot = "Legs", name = "Dreadwoven Leggings of Failure", sources = { [17]=44770, [14]=44397, [15]=45001 } },
                { id = 86386, slot = "Two-Hand", name = "Shin'ka, Execution of Dominion", sources = { [17]=44768, [14]=44395, [15]=45002 } },
                { id = 89839, slot = "Waist", name = "Shadowgrip Girdle", sources = { [17]=46710, [14]=46617, [15]=46679 } },
                { id = 86387, slot = "Weapon", name = "Kilrak, Jaws of Terror", sources = { [17]=44769, [14]=44396, [15]=45000 } },
                { id = 86666, slot = "Head", name = "Faceguard of Resounding Rings", sources = { [17]=43684, [14]=44564, [15]=45025 }, classes = { 1 } },
                { id = 86673, slot = "Head", name = "Helmet of Resounding Rings", sources = { [17]=43691, [14]=44571, [15]=45018 }, classes = { 1 } },
                { id = 86661, slot = "Head", name = "White Tiger Faceguard", sources = { [17]=43679, [14]=44559, [15]=44947 }, classes = { 2 } },
                { id = 86681, slot = "Head", name = "White Tiger Helmet", sources = { [17]=43699, [14]=44579, [15]=44937 }, classes = { 2 } },
                { id = 86686, slot = "Head", name = "White Tiger Headguard", sources = { [17]=43704, [14]=44584, [15]=44942 }, classes = { 2 } },
                { id = 86636, slot = "Head", name = "Yaungol Slayer's Headguard", sources = { [17]=43654, [14]=44534, [15]=44857 }, classes = { 3 } },
                { id = 86641, slot = "Head", name = "Helmet of the Thousandfold Blades", sources = { [17]=43659, [14]=44539, [15]=44962 }, classes = { 4 } },
                { id = 86702, slot = "Head", name = "Guardian Serpent Cowl", sources = { [17]=43720, [14]=44600, [15]=44951 }, classes = { 5 } },
                { id = 86705, slot = "Head", name = "Guardian Serpent Hood", sources = { [17]=43723, [14]=44603, [15]=44956 }, classes = { 5 } },
                { id = 86656, slot = "Head", name = "Faceguard of the Lost Catacomb", sources = { [17]=43674, [14]=44554, [15]=44782 }, classes = { 6 } },
                { id = 86676, slot = "Head", name = "Helmet of the Lost Catacomb", sources = { [17]=43694, [14]=44574, [15]=44777 }, classes = { 6 } },
                { id = 86626, slot = "Head", name = "Firebird's Helmet", sources = { [17]=43644, [14]=44524, [15]=44972 }, classes = { 7 } },
                { id = 86631, slot = "Head", name = "Firebird's Headpiece", sources = { [17]=43649, [14]=44529, [15]=44977 }, classes = { 7 } },
                { id = 86691, slot = "Head", name = "Firebird's Faceguard", sources = { [17]=43709, [14]=44589, [15]=44967 }, classes = { 7 } },
                { id = 86717, slot = "Head", name = "Hood of the Burning Scroll", sources = { [17]=43735, [14]=44615, [15]=44861 }, classes = { 8 } },
                { id = 86710, slot = "Head", name = "Sha-Skin Hood", sources = { [17]=43728, [14]=44608, [15]=45014 }, classes = { 9 } },
                { id = 86726, slot = "Head", name = "Red Crane Crown", sources = { [17]=43744, [14]=44624, [15]=44932 }, classes = { 10 } },
                { id = 86730, slot = "Head", name = "Red Crane Helm", sources = { [17]=43748, [14]=44628, [15]=44926 }, classes = { 10 } },
                { id = 86736, slot = "Head", name = "Red Crane Headpiece", sources = { [17]=43754, [14]=44634, [15]=44922 }, classes = { 10 } },
                { id = 86647, slot = "Head", name = "Eternal Blossom Cover", sources = { [17]=43665, [14]=44545, [15]=44796 }, classes = { 11 } },
                { id = 86651, slot = "Head", name = "Eternal Blossom Headpiece", sources = { [17]=43669, [14]=44549, [15]=44787 }, classes = { 11 } },
                { id = 86697, slot = "Head", name = "Eternal Blossom Helm", sources = { [17]=43715, [14]=44595, [15]=44791 }, classes = { 11 } },
                { id = 86721, slot = "Head", name = "Eternal Blossom Headguard", sources = { [17]=43739, [14]=44619, [15]=44802 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 138805, kind = "illusion", name = "Illusion: Jade Spirit", sourceID = 4442 },
            },
        },
    },

    routing = {

        -- 1. Protectors of the Endless
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Protectors of the Endless",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 456 },
                    kind    = "path",
                    note    = "After zoning in, move ahead and kill the trash to begin the encounter with ^Protectors of the Endless^.",
                    points  = {},
                },
            },
        },

        -- 2. Tsulong
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Tsulong",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 456 },
                    kind    = "path",
                    note    = "After defeating ^Protectors of the Endless^, there will be a brief delay and then ^Tsulong^ will spawn at the same location.",
                    points  = {},
                },
            },
        },

        -- 3. Lei Shi
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Lei Shi",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 456 },
                    kind    = "path",
                    note    = "After defeating ^Tsulong^, keep moving straight ahead and kill the trash to spawn ^Lei Shi^.",
                    points  = {},
                },
            },
        },

        -- 4. Sha of Fear
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Sha of Fear",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 456 },
                    kind    = "path",
                    note    = "After defeating ^Lei Shi^, continue straight up the stairs to engage ^Sha of Fear^.",
                    points  = {},
                },
            },
        },

    },
}
