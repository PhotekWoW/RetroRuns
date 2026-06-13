-------------------------------------------------------------------------------
-- RetroRuns Data -- Mogu'shan Vaults
-- Mists of Pandaria, Patch 5.0.4  |  instanceID: 1008  |  journalInstanceID: 317
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1008] = {
    instanceID        = 1008,
    journalInstanceID = 317,
    name              = "Mogu'shan Vaults",
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
        mapID = 379,
        x     = 0.5960,
        y     = 0.3910,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [471] = "Dais of Conquerors",
        [472] = "The Repository",
        [473] = "Forge of the Endless",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
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
            name               = "The Stone Guard",
            journalEncounterID = 679,
            aliases            = {},
            achievements       = {
                { id = 6823, name = "Must Love Dogs", meta = true, soloable = "yes" },
                { id = 6719, name = "Heroic: Stone Guard", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 85979, slot = "Back", name = "Cape of Three Lanterns", sources = { [17]=44645, [14]=44174, [15]=44870 } },
                { id = 89766, slot = "Chest", name = "Stonefang Chestguard", sources = { [17]=46691, [14]=46566, [15]=46660 } },
                { id = 85975, slot = "Feet", name = "Heavenly Jade Greatboots", sources = { [17]=44641, [14]=44170, [15]=44873 } },
                { id = 85925, slot = "Feet", name = "Jasper Clawfeet", sources = { [17]=44639, [14]=44136, [15]=44868 } },
                { id = 89768, slot = "Hands", name = "Claws of Amethyst", sources = { [17]=46693, [14]=46568, [15]=46662 } },
                { id = 85976, slot = "Head", name = "Sixteen-Fanged Crown", sources = { [17]=44642, [14]=44171, [15]=44872 } },
                { id = 85978, slot = "Legs", name = "Jade Dust Leggings", sources = { [17]=44644, [14]=44173, [15]=44869 } },
                { id = 85926, slot = "Legs", name = "Stoneflesh Leggings", sources = { [17]=44640, [14]=44137, [15]=44866 } },
                { id = 89767, slot = "Waist", name = "Ruby-Linked Girdle", sources = { [17]=46692, [14]=46567, [15]=46661 } },
                { id = 86134, slot = "Waist", name = "Star-Stealer Waistguard", sources = { [17]=44677, [14]=44281, [15]=44906 } },
                { id = 85977, slot = "Waist", name = "Stonebound Cinch", sources = { [17]=44643, [14]=44172, [15]=44871 } },
                { id = 85924, slot = "Weapon", name = "Dagger of the Seven Stars", sources = { [17]=44638, [14]=44135, [15]=44865 } },
                { id = 85923, slot = "Wrist", name = "Stonemaw Armguards", sources = { [17]=44637, [14]=44134, [15]=44867 } },
            },
            specialLoot = {
                -- Quilen battle pet, part of the Raiding with Leashes VI
                -- pet collection. Drops on all difficulties.
                { id = 167047, kind = "pet", name = "Stoneclaw" },
            },
        },
        {
            index              = 2,
            name               = "Feng the Accursed",
            journalEncounterID = 689,
            aliases            = {},
            achievements       = {
                { id = 6674, name = "Anything You Can Do, I Can Do Better...", meta = true, soloable = "no" },
                { id = 6720, name = "Heroic: Feng the Accursed", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86082, slot = "Back", name = "Arrow Breaking Windcloak", sources = { [17]=44670, [14]=44252, [15]=44893 } },
                { id = 85985, slot = "Back", name = "Cloak of Peacock Feathers", sources = { [17]=44650, [14]=44179, [15]=44878 } },
                { id = 85990, slot = "Chest", name = "Imperial Ghostbinder's Robes", sources = { [17]=44654, [14]=44183, [15]=44879 } },
                { id = 85980, slot = "Feet", name = "Wildfire Worldwalkers", sources = { [17]=44646, [14]=44175, [15]=44875 } },
                { id = 85989, slot = "Head", name = "Hood of Cursed Dreams", sources = { [17]=44653, [14]=44182, [15]=44880 } },
                { id = 85984, slot = "Head", name = "Nullification Greathelm", sources = { [17]=44649, [14]=44178, [15]=44876 } },
                { id = 89424, slot = "Held In Off-hand", name = "Fan of Fiery Winds", sources = { [17]=46320, [14]=46318, [15]=46319 } },
                { id = 85988, slot = "Legs", name = "Legplates of Sagacious Shadows", sources = { [17]=44652, [14]=44181, [15]=44882 } },
                { id = 85987, slot = "Waist", name = "Chain of Shadow", sources = { [17]=44651, [14]=44180, [15]=44881 } },
                { id = 85982, slot = "Waist", name = "Tomb Raider's Girdle", sources = { [17]=44647, [14]=44176, [15]=44874 } },
                { id = 85983, slot = "Wrist", name = "Bracers of Six Oxen", sources = { [17]=44648, [14]=44177, [15]=44877 } },
            },
        },
        {
            index              = 3,
            name               = "Gara'jal the Spiritbinder",
            journalEncounterID = 682,
            aliases            = {},
            achievements       = {
                { id = 7056, name = "Sorry, Were You Looking for This?", meta = true, soloable = "kinda" },
                { id = 6721, name = "Heroic: Gara'jal the Spiritbinder", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 85997, slot = "Feet", name = "Sandals of the Severed Soul", sources = { [17]=44660, [14]=44189, [15]=44887 } },
                { id = 85992, slot = "Feet", name = "Sollerets of Spirit Splitting", sources = { [17]=44655, [14]=44184, [15]=44886 } },
                { id = 86040, slot = "Legs", name = "Leggings of Imprisoned Will", sources = { [17]=44663, [14]=44226, [15]=44891 } },
                { id = 85996, slot = "Off-hand", name = "Eye of the Ancient Spirit", sources = { [17]=44659, [14]=44188, [15]=44889 } },
                { id = 85995, slot = "Shoulder", name = "Netherrealm Shoulderpads", sources = { [17]=44658, [14]=44187, [15]=44884 } },
                { id = 86041, slot = "Shoulder", name = "Shadowsummoner Spaulders", sources = { [17]=44664, [14]=44227, [15]=44888 } },
                { id = 86039, slot = "Shoulder", name = "Spaulders of the Divided Mind", sources = { [17]=44662, [14]=44225, [15]=44890 } },
                { id = 85993, slot = "Waist", name = "Fetters of Death", sources = { [17]=44656, [14]=44185, [15]=44885 } },
                { id = 85994, slot = "Weapon", name = "Gara'kal, Fist of the Spiritbinder", sources = { [17]=44657, [14]=44186, [15]=44883 } },
                { id = 86027, slot = "Wrist", name = "Bindings of Ancient Spirits", sources = { [17]=44661, [14]=44214, [15]=44892 } },
                { id = 89817, slot = "Wrist", name = "Bonded Soul Bracers", sources = { [17]=46694, [14]=46598, [15]=46663 } },
            },
            specialLoot = {
                -- Undead battle pet, part of the Raiding with Leashes VI
                -- pet collection. Drops on all difficulties.
                { id = 167048, kind = "pet", name = "Wayward Spirit" },
            },
        },
        {
            index              = 4,
            name               = "The Spirit Kings",
            journalEncounterID = 687,
            aliases            = {},
            achievements       = {
                { id = 6687, name = "Getting Hot In Here", meta = false, soloable = "kinda" },
                { id = 6722, name = "Heroic: Four Kings", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 89819, slot = "Back", name = "Mindshard Drape", sources = { [17]=46696, [14]=46600, [15]=46665 } },
                { id = 86076, slot = "Chest", name = "Breastplate of the Kings' Guard", sources = { [17]=44667, [14]=44248, [15]=44896 } },
                { id = 86084, slot = "Feet", name = "Meng's Treads of Insanity", sources = { [17]=44671, [14]=44253, [15]=44902 } },
                { id = 86128, slot = "Hands", name = "Undying Shadow Grips", sources = { [17]=44674, [14]=44278, [15]=44900 } },
                { id = 86129, slot = "Head", name = "Hood of Blind Eyes", sources = { [17]=44675, [14]=44279, [15]=44899 } },
                { id = 86081, slot = "Legs", name = "Subetai's Pillaging Leggings", sources = { [17]=44669, [14]=44251, [15]=44895 } },
                { id = 86075, slot = "Off-hand", name = "Steelskin, Qiang's Impervious Shield", sources = { [17]=44666, [14]=44247, [15]=44898 } },
                { id = 86080, slot = "Shoulder", name = "Shoulderguards of the Unflanked", sources = { [17]=44668, [14]=44250, [15]=44897 } },
                { id = 86071, slot = "Two-Hand", name = "Screaming Tiger, Qiang's Unbreakable Polearm", sources = { [17]=44665, [14]=44246, [15]=44894 } },
                { id = 86086, slot = "Waist", name = "Girdle of Delirious Visions", sources = { [17]=44672, [14]=44254, [15]=44903 } },
                { id = 86127, slot = "Wrist", name = "Bracers of Dark Thoughts", sources = { [17]=44673, [14]=44277, [15]=44901 } },
                { id = 89818, slot = "Wrist", name = "Bracers of Violent Meditation", sources = { [17]=46695, [14]=46599, [15]=46664 } },
            },
        },
        {
            index              = 5,
            name               = "Elegon",
            journalEncounterID = 726,
            aliases            = {},
            achievements       = {
                { id = 6686, name = "Straight Six", meta = true, soloable = "kinda" },
                { id = 6723, name = "Heroic: Elegon", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 86136, slot = "Chest", name = "Chestguard of Total Annihilation", sources = { [17]=44679, [14]=44283, [15]=44904 } },
                { id = 86138, slot = "Feet", name = "Phasewalker Striders", sources = { [17]=44681, [14]=44285, [15]=44911 } },
                { id = 86135, slot = "Hands", name = "Starcrusher Gauntlets", sources = { [17]=44678, [14]=44282, [15]=44905 } },
                { id = 89821, slot = "Head", name = "Crown of Keening Stars", sources = { [17]=46698, [14]=46602, [15]=46667 } },
                { id = 86137, slot = "Ranged", name = "Torch of the Celestial Spark", sources = { [17]=44680, [14]=44284, [15]=44910 } },
                { id = 86141, slot = "Shoulder", name = "Shoulders of Empyreal Focus", sources = { [17]=44684, [14]=44288, [15]=44912 } },
                { id = 86140, slot = "Two-Hand", name = "Starshatter", sources = { [17]=44683, [14]=44287, [15]=44907 } },
                { id = 89822, slot = "Waist", name = "Galaxyfire Girdle", sources = { [17]=46697, [14]=46603, [15]=46666 } },
                { id = 86139, slot = "Waist", name = "Orbital Belt", sources = { [17]=44682, [14]=44286, [15]=44909 } },
                { id = 86130, slot = "Weapon", name = "Elegion, the Fanged Crescent", sources = { [17]=44676, [14]=44280, [15]=44908 } },
            },
            specialLoot = {
                -- Rare mount drop from the Cache of Pure Energy. Drops on
                -- both Normal and Heroic.
                { id = 87777, kind = "mount", name = "Reins of the Astral Cloud Serpent" },
                -- Stellar lion battle pet, part of the Raiding with
                -- Leashes VI pet collection. Drops on all difficulties.
                { id = 167049, kind = "pet", name = "Celestial Gift" },
            },
        },
        {
            index              = 6,
            name               = "Will of the Emperor",
            journalEncounterID = 677,
            aliases            = {},
            achievements       = {
                { id = 6455, name = "Show Me Your Moves!", meta = false, soloable = "kinda" },
                { id = 6724, name = "Heroic: Will of the Emperor", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 89823, slot = "Chest", name = "Chestguard of Eternal Vigilance", sources = { [17]=46700, [14]=46604, [15]=46669 } },
                { id = 89825, slot = "Hands", name = "Enameled Grips of Solemnity", sources = { [17]=46701, [14]=46605, [15]=46670 } },
                { id = 87827, slot = "Hands", name = "Grips of Terra Cotta", sources = { [17]=45319, [14]=45320, [15]=45318 } },
                { id = 86146, slot = "Head", name = "Crown of Opportunistic Strikes", sources = { [17]=44687, [14]=44291, [15]=44914 } },
                { id = 89820, slot = "Head", name = "Dreadeye Gaze", sources = { [17]=46699, [14]=46601, [15]=46668 } },
                { id = 86151, slot = "Head", name = "Hood of Focused Energy", sources = { [17]=44691, [14]=44295, [15]=44916 } },
                { id = 86145, slot = "Legs", name = "Jang-xi's Devastating Legplates", sources = { [17]=44686, [14]=44290, [15]=44915 } },
                { id = 86150, slot = "Legs", name = "Magnetized Leggings", sources = { [17]=44690, [14]=44294, [15]=44918 } },
                { id = 86142, slot = "Ranged", name = "Fang Kung, Spark of Titans", sources = { [17]=44685, [14]=44289, [15]=44913 } },
                { id = 86149, slot = "Shoulder", name = "Spaulders of the Emperor's Rage", sources = { [17]=44689, [14]=44293, [15]=44919 } },
                { id = 86148, slot = "Weapon", name = "Tihan, Scepter of the Sleeping Emperor", sources = { [17]=44688, [14]=44292, [15]=44917 } },
            },
            specialLoot = {
                -- Weapon enchant illusion. Drops on all difficulties.
                { id = 138804, kind = "illusion", name = "Illusion: Colossus", sourceID = 5861 },
                -- Mogu statuette battle pet, part of the Raiding with
                -- Leashes VI pet collection. Drops on all difficulties.
                { id = 167050, kind = "pet", name = "Mogu Statue" },
            },
        },
    },

    routing = {

        -- 1. The Stone Guard
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "The Stone Guard",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 471, subZone = "The Golden Hall" },
                    kind    = "path",
                    note    = "After zoning in, move ahead to find ^The Stone Guard^.",
                    points  = {
                        { 0.749, 0.704 },
                        { 0.752, 0.643 },
                        { 0.486, 0.639 },
                    },
                },
            },
        },

        -- 2. Feng the Accursed
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Feng the Accursed",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 471, subZone = "The Golden Hall" },
                    kind    = "path",
                    note    = "After defeating ^The Stone Guard^, continue ahead to several trash packs with glowing orbs floating near them. Physically walk into the adds to spawn the trash. Once they're down, you can engage ^Feng the Accursed^.",
                    points  = {
                        { 0.428, 0.641 },
                        { 0.320, 0.639 },
                        { 0.318, 0.370 },
                    },
                },
            },
        },

        -- 3. Gara'jal the Spiritbinder
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Gara'jal the Spiritbinder",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 471, subZone = "Dais of Conquerors" },
                    kind    = "path",
                    note    = "After killing ^Feng^, continue on to the next area.",
                    points  = {
                        { 0.322, 0.283 },
                        { 0.318, 0.118 },
                    },
                },
                {
                    when    = { mapID = 472, subZone = "Emperor's Reach" },
                    kind    = "path",
                    note    = "In the next area, clear the trash before, on, and after the platform to force ^Gara'jal the Spiritbinder^ into combat.",
                    points  = {
                        { 0.776, 0.755 },
                        { 0.776, 0.383 },
                    },
                },
            },
        },

        -- 4. The Spirit Kings
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "The Spirit Kings",
            requires  = {},
            segments  = {
                {
                    when            = { mapID = 472, subZone = "The Repository" },
                    kind            = "poi",
                    mapLabel        = "Talk to Lorewalker Cho",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    note    = "After killing ^Gara'jal^, follow the linear path to ^Lorewalker Cho^. Speak to him to trigger a series of trash encounters.",
                    points  = {
                        { 0.328, 0.292 },
                    },
                },
                {
                    when    = { mapID = 472 },
                    kind    = "path",
                    triggeredBy = { dialog = { npc = "Lorewalker Cho", match = "What might this button do" } },
                    points  = {
                        { 0.717, 0.339 },
                        { 0.444, 0.341 },
                        { 0.407, 0.290 },
                    },
                },
                {
                    when    = { mapID = 472 },
                    kind    = "path",
                    note    = "After clearing the final trash wave, follow the path up to engage ^The Spirit Kings^.",
                    points  = {
                        { 0.336, 0.686 },
                        { 0.238, 0.692 },
                        { 0.237, 0.629 },
                        { 0.212, 0.556 },
                    },
                },
            },
        },

        -- 5. Elegon
        {
            step      = 5,
            priority  = 5,
            bossIndex = 5,
            title     = "Elegon",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 472, subZone = "The Repository" },
                    kind    = "path",
                    note    = "After defeating ^The Spirit Kings^, go downstairs to the previous room and take the new path by ^Lorewalker Cho^.",
                    points  = {
                        { 0.238, 0.400 },
                        { 0.243, 0.292 },
                        { 0.339, 0.294 },
                        { 0.335, 0.414 },
                        { 0.294, 0.513 },
                    },
                },
                {
                    when    = { mapID = 473, subZone = "The Repository" },
                    kind    = "path",
                    note    = "In the boss room, kill the final trash pack and talk to ^Lorewalker Cho^ to trigger the boss fight with ^Elegon^.",
                    points  = {
                        { 0.610, 0.105 },
                        { 0.609, 0.211 },
                        { 0.685, 0.217 },
                        { 0.686, 0.408 },
                        { 0.490, 0.412 },
                        { 0.487, 0.505 },
                        { 0.292, 0.509 },
                    },
                },
            },
        },

        -- 6. Will of the Emperor
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Will of the Emperor",
            requires  = {},
            segments  = {
                {
                    when    = { mapID = 473, subZone = "Engine of Nalak'sha" },
                    kind    = "path",
                    note    = "After killing ^Elegon^, follow the path out of the room and head south to arrive at the next boss room. To start the fight with ^Will of the Emperor^, click the pipes below (^Heroic^) or click the console (^Normal^).",
                    points  = {
                        { 0.406, 0.509 },
                        { 0.491, 0.505 },
                        { 0.492, 0.412 },
                        { 0.686, 0.410 },
                        { 0.688, 0.654 },
                    },
                },
            },
        },

    },
}
