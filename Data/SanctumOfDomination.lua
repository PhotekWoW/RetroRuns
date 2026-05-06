-------------------------------------------------------------------------------
-- RetroRuns Data -- Sanctum of Domination
-- Shadowlands, Patch 9.1  |  instanceID: 2450  |  journalInstanceID: 1193
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2450] = {
    instanceID        = 2450,
    journalInstanceID = 1193,
    name              = "Sanctum of Domination",
    expansion         = "Shadowlands",
    patch             = "9.1",

    maps = {
        -- Sub-zone names taken from the world-map dropdown (the
        -- authoritative source in-game). GetMapInfo(mapID).name
        -- returns the parent raid name "Sanctum of Domination" for
        -- every sub-map in this raid, and the maps are structurally
        -- flat children of The Maw (uiMapID 1543) rather than of a
        -- Sanctum parent node, so no API-side lookup can recover
        -- the dropdown label. Maintain by hand.
        [1998] = "Tower of the Damned",    -- entrance, Tarragrue
        [1999] = "Shadowsteel Foundry",    -- Eye of the Jailer, The Nine
        [2000] = "The Torment Chambers",   -- Soulrender, Ner'zhul, Painsmith
        [2001] = "Crown of Gorgoa",        -- Guardian, Fatescribe, Kel'Thuzad
        [2002] = "Pinnacle of Domination", -- Sylvanas Windrunner
    },

    -- No class tier sets. Patch 9.1 predated the return of proper tier
    -- sets (which came with 9.2 / Sepulcher). The raid's appearance
    -- sets are unified purely by model, not by token drops, so there
    -- is nothing to route per-boss and no per-class filtering applies.
    tierSets = {
        labels       = {},
        tokenSources = {},
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
        normal = 64597,
        heroic = 64598,
        mythic = 64599,
    },

    -- Glory meta-achievement for this raid. Completing all 10 per-boss
    -- criteria below awards the Hand of Hrestimorak mount.
    gloryMeta = {
        id   = 15130,
        name = "Glory of the Dominant Raider",
        rewardItemID       = 186653,
        rewardMountSpellID = 339957,
        rewardName         = "Hand of Hrestimorak",
    },

    bosses = {
        {
            index              = 1,
            name               = "The Tarragrue",
            journalEncounterID = 2435,
            aliases            = { "Tarragrue" },
            achievements       = {
                { id = 14998, name = "Name A Better Duo, I'll Wait", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186303, slot = "Chest", name = "Colossus Slayer's Hauberk", sources = { [17]=145673, [14]=145672, [15]=145674, [16]=145675 } },
                { id = 186318, slot = "Feet", name = "Champion's Gruesome Greaves", sources = { [17]=145725, [14]=145724, [15]=145726, [16]=145727 } },
                { id = 186281, slot = "Feet", name = "Phantasma-Forged Striders", sources = { [17]=145597, [14]=145596, [15]=145598, [16]=145599 } },
                { id = 186311, slot = "Hands", name = "Cavalier Oathbreaker's Grasps", sources = { [17]=145697, [14]=145696, [15]=145698, [16]=145699 } },
                { id = 186285, slot = "Legs", name = "Sorcerer's Headlong Legwraps", sources = { [17]=145613, [14]=145612, [15]=145614, [16]=145615 } },
                { id = 186415, slot = "Off-hand", name = "Moriaz's Spare Targe", sources = { [17]=146649, [14]=145987, [15]=146650, [16]=145988 } },
                { id = 186298, slot = "Shoulder", name = "Smuggler's Plundered Pauldrons", sources = { [17]=145657, [14]=145656, [15]=145658, [16]=145659 } },
                { id = 186381, slot = "Weapon", name = "Elethium-Bladed Glaive", sources = { [17]=146655, [14]=145945, [15]=146656, [16]=145946 } },
                { id = 186297, slot = "Wrist", name = "Clasps of the Unfortunate Troubadour", sources = { [17]=145653, [14]=145652, [15]=145654, [16]=145655 } },
                { id = 186302, slot = "Wrist", name = "Mistwrap Manacles", sources = { [17]=145669, [14]=145668, [15]=145670, [16]=145671 } },
            },
        },
        {
            index              = 2,
            name               = "The Eye of the Jailer",
            journalEncounterID = 2442,
            aliases            = { "Eye of the Jailer" },
            achievements       = {
                { id = 15065, name = "Eye Wish You Were Here", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186296, slot = "Chest", name = "Mawsworn Eviscerator's Cuirass", sources = { [17]=145649, [14]=145648, [15]=145650, [16]=145651 } },
                { id = 186306, slot = "Feet", name = "Greaves of Extermination", sources = { [17]=145685, [14]=145684, [15]=145686, [16]=145687 } },
                { id = 186288, slot = "Hands", name = "Grasps of the Clairvoyant Sage", sources = { [17]=145625, [14]=145624, [15]=145626, [16]=145627 } },
                { id = 186295, slot = "Hands", name = "Loyal Kvaldir's Handwraps", sources = { [17]=145645, [14]=145644, [15]=145646, [16]=145647 } },
                { id = 186418, slot = "Held In Off-hand", name = "Guarm's Lost Chew Toy", sources = { [17]=146663, [14]=145993, [15]=146664, [16]=145994 } },
                { id = 186403, slot = "Two-Hand", name = "Stygian Lance of Passage", sources = { [17]=146685, [14]=145967, [15]=146686, [16]=145968 } },
                { id = 186301, slot = "Waist", name = "Coiled Stygian Grapnel", sources = { [17]=145665, [14]=145664, [15]=145666, [16]=145667 } },
                { id = 186383, slot = "Weapon", name = "Gazepiercer", sources = { [17]=146689, [14]=145947, [15]=146690, [16]=145948 } },
                { id = 186316, slot = "Wrist", name = "Airborne Abductor's Vambraces", sources = { [17]=145717, [14]=145716, [15]=145718, [16]=145719 } },
            },
            specialLoot = {
                { id = 186554, kind = "pet", name = "Eye of Allseeing" },
                { id = 186555, kind = "pet", name = "Eye of Extermination", mythicOnly = true },
            },
        },
        {
            index              = 3,
            name               = "The Nine",
            journalEncounterID = 2439,
            aliases            = { "Nine" },
            soloTip            = "After some dialog, the boss is a Standard Nuke.",
            achievements       = {
                { id = 15003, name = "To the Nines", meta = true, soloable = "no" },
            },
            loot = {
                { id = 186299, slot = "Feet", name = "Daschla's Defiant Treads", sources = { [17]=145661, [14]=145660, [15]=145662, [16]=145663 } },
                { id = 186346, slot = "Hands", name = "Kyra's Unending Protectors", sources = { [17]=145829, [14]=145828, [15]=145830, [16]=145831 } },
                { id = 186313, slot = "Legs", name = "Agatha's Gothic Greaves", sources = { [17]=145705, [14]=145704, [15]=145706, [16]=145707 } },
                { id = 186307, slot = "Legs", name = "Aradne's Lancer Legguards", sources = { [17]=145689, [14]=145688, [15]=145690, [16]=145691 } },
                { id = 186286, slot = "Shoulder", name = "Mantle of Arthura's Chosen", sources = { [17]=145617, [14]=145616, [15]=145618, [16]=145619 } },
                { id = 186404, slot = "Two-Hand", name = "Jotungeirr, Destiny's Call", sources = { [17]=146687, [14]=145969, [15]=146688, [16]=145970 } },
                { id = 186385, slot = "Weapon", name = "Signe's Sonorous Scramaseax", sources = { [17]=146645, [14]=145951, [15]=146646, [16]=145952 } },
                { id = 186384, slot = "Weapon", name = "Skyja's Revenant Fury", sources = { [17]=146673, [14]=145949, [15]=146674, [16]=145950 } },
                { id = 186339, slot = "Wrist", name = "Brynja's Mournful Wristwraps", sources = { [17]=145801, [14]=145800, [15]=145802, [16]=145803 } },
            },
            specialLoot = {
                { id = 186656, kind = "mount", name = "Sanctum Gloomcharger's Reins" },
            },
        },
        {
            index              = 4,
            name               = "Remnant of Ner'zhul",
            journalEncounterID = 2444,
            aliases            = { "Ner'zhul", "Nerzhul" },
            achievements       = {
                { id = 15058, name = "I Used to Bullseye Deeprun Rats Back Home", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186312, slot = "Chest", name = "Cuirass of the Lonely Citadel", sources = { [17]=145701, [14]=145700, [15]=145702, [16]=145703 } },
                { id = 186308, slot = "Hands", name = "Grasps of Ancestral Whispers", sources = { [17]=145693, [14]=145692, [15]=145694, [16]=145695 } },
                { id = 186292, slot = "Head", name = "Cap of Writhing Malevolence", sources = { [17]=145633, [14]=145632, [15]=145634, [16]=145635 } },
                { id = 186304, slot = "Head", name = "Crest of the Fallen", sources = { [17]=145677, [14]=145676, [15]=145678, [16]=145679 } },
                { id = 186315, slot = "Head", name = "Dark Tormentor's Gaze", sources = { [17]=145713, [14]=145712, [15]=145714, [16]=145715 } },
                { id = 186287, slot = "Head", name = "Hood of Vengeful Possession", sources = { [17]=145621, [14]=145620, [15]=145622, [16]=145623 } },
                { id = 186405, slot = "Two-Hand", name = "Gnarled Staff of the Elder Shaman", sources = { [17]=146679, [14]=145971, [15]=146680, [16]=145972 } },
                { id = 186386, slot = "Weapon", name = "Betrayer's Shadowspike", sources = { [17]=146647, [14]=145953, [15]=146648, [16]=145954 } },
            },
        },
        {
            index              = 5,
            name               = "Soulrender Dormazain",
            journalEncounterID = 2445,
            aliases            = { "Dormazain", "Soulrender" },
            achievements       = {
                { id = 15105, name = "Tormentor's Tango", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186289, slot = "Back", name = "Cloak of Scarred Honor", sources = { [17]=145629, [14]=145628, [15]=145630, [16]=145631 } },
                { id = 186343, slot = "Feet", name = "Ragebound Leg Irons", sources = { [17]=145817, [14]=145816, [15]=145818, [16]=145819 } },
                { id = 186319, slot = "Feet", name = "Tormented Shadowcleft Boots", sources = { [17]=145729, [14]=145728, [15]=145730, [16]=145731 } },
                { id = 186337, slot = "Feet", name = "Trenchant Warmonger Treads", sources = { [17]=145793, [14]=145792, [15]=145794, [16]=145795 } },
                { id = 186411, slot = "Ranged", name = "Soulrent Outrider's Recurve", sources = { [17]=146677, [14]=145981, [15]=146678, [16]=145982 } },
                { id = 186305, slot = "Shoulder", name = "Pauldrons of Tyrannical Defiance", sources = { [17]=145681, [14]=145680, [15]=145682, [16]=145683 } },
                { id = 186314, slot = "Shoulder", name = "Ruinous Warchief's Shoulderguards", sources = { [17]=145709, [14]=145708, [15]=145710, [16]=145711 } },
                { id = 186407, slot = "Two-Hand", name = "Hellscream's Requiem", sources = { [17]=146675, [14]=145975, [15]=146676, [16]=145976 } },
                { id = 186294, slot = "Waist", name = "Agonizing Spiked Belt", sources = { [17]=145641, [14]=145640, [15]=145642, [16]=145643 } },
                { id = 186387, slot = "Weapon", name = "Dormazain's Tenderizer", sources = { [17]=146657, [14]=145955, [15]=146658, [16]=145956 } },
                { id = 186283, slot = "Wrist", name = "Cruel Overlord's Shackles", sources = { [17]=145605, [14]=145604, [15]=145606, [16]=145607 } },
            },
            specialLoot = {
                { id = 186558, kind = "pet", name = "Irongrasp" },
            },
        },
        {
            index              = 6,
            name               = "Painsmith Raznal",
            journalEncounterID = 2443,
            aliases            = { "Painsmith", "Raznal" },
            achievements       = {
                { id = 15131, name = "Whack-A-Soul", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186282, slot = "Chest", name = "Sacrificer's Sacramental Cassock", sources = { [17]=145601, [14]=145600, [15]=145602, [16]=145603 } },
                { id = 186369, slot = "Hands", name = "Guillotine Gauntlets", sources = { [17]=145921, [14]=145920, [15]=145922, [16]=145923 } },
                { id = 186333, slot = "Hands", name = "Hangman's Knotbinders", sources = { [17]=145777, [14]=145776, [15]=145778, [16]=145779 } },
                { id = 186341, slot = "Head", name = "Shadowsteel Facecage", sources = { [17]=145809, [14]=145808, [15]=145810, [16]=145811 } },
                { id = 186293, slot = "Legs", name = "Flameclasp-Scorched Legguards", sources = { [17]=145637, [14]=145636, [15]=145638, [16]=145639 } },
                { id = 186323, slot = "Legs", name = "Leggings of the Screaming Flames", sources = { [17]=145745, [14]=145744, [15]=145746, [16]=145747 } },
                { id = 186388, slot = "Weapon", name = "Cruciform Veinripper", sources = { [17]=146667, [14]=145957, [15]=146668, [16]=145958 } },
                { id = 186392, slot = "Weapon", name = "Exacting Mindslicer", sources = { [17]=146691, [14]=145961, [15]=146692, [16]=145962 } },
                { id = 186391, slot = "Weapon", name = "Shadowsteel Demoralizer", sources = { [17]=146659, [14]=145959, [15]=146660, [16]=145960 } },
            },
        },
        {
            index              = 7,
            name               = "Guardian of the First Ones",
            journalEncounterID = 2446,
            aliases            = { "Guardian" },
            achievements       = {
                { id = 15132, name = "Knowledge is Power", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186374, slot = "Back", name = "Self-Replicating Tissue", sources = { [17]=145941, [14]=145940, [15]=145942, [16]=145943 } },
                { id = 186347, slot = "Chest", name = "Ancient Colossus Chassis", sources = { [17]=145833, [14]=145832, [15]=145834, [16]=145835 } },
                { id = 186354, slot = "Feet", name = "Sandals of Sacred Symmetry", sources = { [17]=145861, [14]=145860, [15]=145862, [16]=145863 } },
                { id = 186363, slot = "Feet", name = "Unstable Energizer Boots", sources = { [17]=145897, [14]=145896, [15]=145898, [16]=145899 } },
                { id = 186344, slot = "Legs", name = "Hyperdense Greaves", sources = { [17]=145821, [14]=145820, [15]=145822, [16]=145823 } },
                { id = 186416, slot = "Off-hand", name = "Infinity's Last Bulwark", sources = { [17]=146651, [14]=145989, [15]=146652, [16]=145990 } },
                { id = 186413, slot = "Ranged", name = "Directional Meltdown Projector", sources = { [17]=146671, [14]=145983, [15]=146672, [16]=145984 } },
                { id = 186409, slot = "Two-Hand", name = "Pylon of the Great Purge", sources = { [17]=146683, [14]=145977, [15]=146684, [16]=145978 } },
                { id = 186317, slot = "Waist", name = "Disintegration-Proof Waistband", sources = { [17]=145721, [14]=145720, [15]=145722, [16]=145723 } },
                { id = 186284, slot = "Waist", name = "Enigmatic Energy Circuit", sources = { [17]=145609, [14]=145608, [15]=145610, [16]=145611 } },
                { id = 186393, slot = "Weapon", name = "Torch of Eternal Knowledge", sources = { [17]=146661, [14]=145963, [15]=146662, [16]=145964 } },
            },
        },
        {
            index              = 8,
            name               = "Fatescribe Roh-Kalo",
            journalEncounterID = 2447,
            aliases            = { "Fatescribe", "Roh-Kalo" },
            achievements       = {
                { id = 15040, name = "Flawless Fate", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186340, slot = "Chest", name = "Conjunction-Forged Chainmail", sources = { [17]=145805, [14]=145804, [15]=145806, [16]=145807 } },
                { id = 186320, slot = "Chest", name = "Diviner's Draped Finery", sources = { [17]=145733, [14]=145732, [15]=145734, [16]=145735 } },
                { id = 186345, slot = "Hands", name = "Demigaunts of Predestination", sources = { [17]=145825, [14]=145824, [15]=145826, [16]=145827 } },
                { id = 186326, slot = "Hands", name = "Gloves of Forsaken Purpose", sources = { [17]=145757, [14]=145756, [15]=145758, [16]=145759 } },
                { id = 186330, slot = "Head", name = "Cowl of Haunting Precognition", sources = { [17]=145765, [14]=145764, [15]=145766, [16]=145767 } },
                { id = 186419, slot = "Held In Off-hand", name = "Record of Collapsing Realities", sources = { [17]=146665, [14]=145995, [15]=146666, [16]=145996 } },
                { id = 186348, slot = "Legs", name = "Fateforged Legplates", sources = { [17]=145837, [14]=145836, [15]=145838, [16]=145839 } },
                { id = 186352, slot = "Waist", name = "Binding of Dark Destinies", sources = { [17]=145853, [14]=145852, [15]=145854, [16]=145855 } },
                { id = 186335, slot = "Wrist", name = "Fate-Threaded Bindings", sources = { [17]=145785, [14]=145784, [15]=145786, [16]=145787 } },
            },
        },
        {
            index              = 9,
            name               = "Kel'Thuzad",
            journalEncounterID = 2440,
            aliases            = { "KT", "Kelthuzad" },
            soloTip            = "Bring boss health to 0 and it will trigger a new phase. Run to the boss, and an extra action button will appear. Use this button to enter the phylactery. Inside, kill the 1 enemy and you will appear back outside to kill the boss one more time.",
            achievements       = {
                { id = 15108, name = "Together Forever", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 186350, slot = "Head", name = "Valorous Visage of Krexus", sources = { [17]=145845, [14]=145844, [15]=145846, [16]=145847 } },
                { id = 186331, slot = "Legs", name = "Elite Aranakk Breeches", sources = { [17]=145769, [14]=145768, [15]=145770, [16]=145771 } },
                { id = 186324, slot = "Shoulder", name = "Frame of the False Margrave", sources = { [17]=145749, [14]=145748, [15]=145750, [16]=145751 } },
                { id = 186336, slot = "Shoulder", name = "Spaulders of the Crooked Confidant", sources = { [17]=145789, [14]=145788, [15]=145790, [16]=145791 } },
                { id = 187542, slot = "Two-Hand", name = "Jaithys, the Prison Blade", sources = { [17]=146730, [14]=146728, [15]=146731, [16]=146729 } },
                { id = 186406, slot = "Two-Hand", name = "Maledict Opus", sources = { [17]=146681, [14]=145973, [15]=146682, [16]=145974 } },
                { id = 186338, slot = "Waist", name = "Ceremonial Construct Clasp", sources = { [17]=145797, [14]=145796, [15]=145798, [16]=145799 } },
                { id = 186322, slot = "Waist", name = "Sash of Duplicitous Magics", sources = { [17]=145741, [14]=145740, [15]=145742, [16]=145743 } },
                { id = 187056, slot = "Weapon", name = "The Devouring Cold", sources = { [17]=146583, [14]=146519, [15]=146584, [16]=146585 } },
                { id = 186365, slot = "Wrist", name = "Bands of the Fallen House", sources = { [17]=145905, [14]=145904, [15]=145906, [16]=145907 } },
                { id = 186351, slot = "Wrist", name = "Vyraz's Parade Cuffs", sources = { [17]=145849, [14]=145848, [15]=145850, [16]=145851 } },
            },
            specialLoot = {
                { id = 186550, kind = "pet", name = "Mawsworn Minion" },
            },
        },
        {
            index              = 10,
            name               = "Sylvanas Windrunner",
            journalEncounterID = 2441,
            aliases            = { "Sylvanas" },
            achievements       = {
                { id = 15133, name = "This World is a Prism", meta = true, soloable = "no" },
            },
            loot = {
                { id = 186439, slot = "Back", name = "Dark Ranger's Quiver", sources = { [17]=145999, [14]=145998, [15]=146000, [16]=146001 } },
                { id = 186334, slot = "Chest", name = "Witherheart Studded Breastplate", sources = { [17]=145781, [14]=145780, [15]=145782, [16]=145783 } },
                { id = 186353, slot = "Feet", name = "Greaves of Haunting Ruination", sources = { [17]=145857, [14]=145856, [15]=145858, [16]=145859 } },
                { id = 186325, slot = "Head", name = "Veil of the Banshee Queen", sources = { [17]=145753, [14]=145752, [15]=145754, [16]=145755 } },
                { id = 186417, slot = "Off-hand", name = "Guard of the Sundered Defender", sources = { [17]=146653, [14]=145991, [15]=146654, [16]=145992 } },
                -- Rae'shalare (ranged) and Edge of Night (weapon) are
                -- unified-visual items: all four difficulty sources share
                -- a single visualID, so the in-game Wardrobe shows one
                -- appearance, not four. Encoded here as binary (one
                -- source cloned across all difficulty buckets) so the
                -- UI renders them as a single-state `[ check ]` pair
                -- matching the Wardrobe's representation.
                { id = 186414, slot = "Ranged", name = "Rae'shalare, Death's Whisper", sources = { [17]=145986, [14]=145986, [15]=145986, [16]=145986 } },
                { id = 186342, slot = "Shoulder", name = "Epaulets of the Master Ranger", sources = { [17]=145813, [14]=145812, [15]=145814, [16]=145815 } },
                { id = 186349, slot = "Shoulder", name = "Spires of Broken Hope", sources = { [17]=145841, [14]=145840, [15]=145842, [16]=145843 } },
                { id = 186332, slot = "Waist", name = "Windrunner's Baldric", sources = { [17]=145773, [14]=145772, [15]=145774, [16]=145775 } },
                { id = 186398, slot = "Weapon", name = "Edge of Night", sources = { [17]=145965, [14]=145965, [15]=145965, [16]=145965 } },
                { id = 186321, slot = "Wrist", name = "Desecrator's Keening Wristwraps", sources = { [17]=145737, [14]=145736, [15]=145738, [16]=145739 } },
            },
            specialLoot = {
                { id = 186642, kind = "mount", name = "Vengeance's Reins", mythicOnly = true },
            },
        },
    },

    routing = {

        -- 1. The Tarragrue
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "The Tarragrue",
            requires  = {},
            segments  = {
                {
                    mapID  = 1998,
                    kind   = "path",
                    note   = "Follow the map from the entrance to the Tarragrue.",
                    points = {
                        { 0.346, 0.785 },
                        { 0.382, 0.739 },
                        { 0.360, 0.688 },
                        { 0.395, 0.551 },
                        { 0.427, 0.530 },
                        { 0.437, 0.494 },
                        { 0.522, 0.491 },
                    },
                },
            },
        },

        -- 2. The Eye of the Jailer
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "The Eye of the Jailer",
            requires  = { 1 },
            segments  = {
                {
                    mapID  = 1998,
                    kind   = "path",
                    note   = "After killing Tarragrue, wait for dialog to complete, then walk through the portal marked as a map exit Shadowsteel Foundry.",
                    points = {},
                },
                {
                    mapID  = 1999,
                    kind   = "path",
                    note   = "After teleporting, follow the path to Eye of the Jailer and clear all trash on his platform. To reach the far side, walk to the pile of chains and use the extra action button",
                    points = {
                        { 0.723, 0.757 },
                        { 0.595, 0.607 },
                        { 0.567, 0.668 },
                        { 0.595, 0.713 },
                        { 0.582, 0.796 },
                        { 0.551, 0.790 },
                        { 0.470, 0.892 },
                    },
                },
            },
        },

        -- 3. The Nine
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "The Nine",
            requires  = { 2 },
            segments  = {
                {
                    mapID  = 1999,
                    kind   = "path",
                    note   = "After killing The Eye of the Jailer, follow the path all the way north to find The Nine.",
                    points = {
                        { 0.468, 0.888 },
                        { 0.410, 0.847 },
                        { 0.379, 0.798 },
                        { 0.348, 0.797 },
                        { 0.349, 0.737 },
                        { 0.368, 0.716 },
                        { 0.422, 0.713 },
                        { 0.422, 0.233 },
                    },
                },
            },
        },

        -- 4. Soulrender Dormazain
        {
            step      = 4,
            priority  = 4,
            bossIndex = 5,
            title     = "Soulrender Dormazain",
            requires  = { 3 },
            segments  = {
                {
                    mapID  = 1999,
                    kind   = "teleport",
                    note   = "After killing The Nine, take the elevator to the left. You will arrive at The Torment Chambers.",
                    points = {
                        { 0.400, 0.162 },
                        { 0.368, 0.111 },
                    },
                },
                {
                    mapID  = 2000,
                    kind   = "path",
                    note   = "After arriving at The Torment Chambers, follow the path to Soulrender Dormazain.",
                    points = {
                        { 0.226, 0.498 },
                        { 0.211, 0.543 },
                        { 0.657, 0.547 },
                        { 0.655, 0.596 },
                        { 0.678, 0.609 },
                        { 0.658, 0.685 },
                        { 0.681, 0.700 },
                        { 0.693, 0.724 },
                        { 0.690, 0.749 },
                        { 0.664, 0.788 },
                        { 0.558, 0.734 },
                    },
                },
            },
        },

        -- 5. Remnant of Ner'zhul
        {
            step      = 5,
            priority  = 5,
            bossIndex = 4,
            title     = "Remnant of Ner'zhul",
            requires  = { 5 },
            segments  = {
                {
                    mapID  = 2000,
                    kind   = "path",
                    note   = "After killing Soulrender Dormazain, follow the path to Remnant of Ner'zhul. Kill the trash to engage the boss.",
                    points = {
                        { 0.566, 0.736 },
                        { 0.673, 0.798 },
                        { 0.691, 0.747 },
                        { 0.688, 0.708 },
                        { 0.656, 0.685 },
                        { 0.677, 0.609 },
                        { 0.659, 0.597 },
                        { 0.656, 0.546 },
                        { 0.662, 0.489 },
                        { 0.697, 0.472 },
                        { 0.729, 0.489 },
                        { 0.786, 0.422 },
                        { 0.858, 0.381 },
                    },
                },
            },
        },

        -- 6. Painsmith Raznal
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Painsmith Raznal",
            requires  = { 4 },
            segments  = {
                {
                    mapID  = 2000,
                    kind   = "path",
                    note   = "After killing Remnant of Ner'zhul, follow the path to loop back around to Painsmith Raznal.",
                    points = {
                        { 0.848, 0.389 },
                        { 0.754, 0.445 },
                        { 0.727, 0.492 },
                        { 0.700, 0.471 },
                        { 0.657, 0.490 },
                        { 0.653, 0.544 },
                        { 0.767, 0.543 },
                        { 0.769, 0.420 },
                        { 0.732, 0.406 },
                        { 0.697, 0.411 },
                        { 0.672, 0.332 },
                    },
                },
            },
        },

        -- 7. Guardian of the First Ones
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Guardian of the First Ones",
            requires  = { 6 },
            segments  = {
                {
                    mapID  = 2000,
                    kind   = "teleport",
                    note   = "After killing Painsmith Raznal, walk out the new exit to the West and walk through the portal.",
                    points = {
                        { 0.638, 0.310 },
                        { 0.537, 0.368 },
                    },
                },
                {
                    mapID  = 2001,
                    kind   = "path",
                    note   = "After arriving in Crown of Gorgoa, follow the path North to Guardian of the First Ones.",
                    points = {
                        { 0.614, 0.519 },
                        { 0.579, 0.519 },
                        { 0.570, 0.448 },
                        { 0.545, 0.410 },
                        { 0.631, 0.191 },
                    },
                },
            },
        },

        -- 8. Fatescribe Roh-Kalo
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Fatescribe Roh-Kalo",
            requires  = { 7 },
            segments  = {
                {
                    mapID  = 2001,
                    kind   = "path",
                    note   = "After killing Guardian of the First Ones, go back the way you came and follow the path to Fatescribe Roh-Kalo. For a shortcut, you can jump off the ledge to respawn halfway there.",
                    points = {
                        { 0.615, 0.226 },
                        { 0.542, 0.420 },
                        { 0.571, 0.449 },
                        { 0.580, 0.495 },
                        { 0.577, 0.546 },
                        { 0.565, 0.587 },
                        { 0.520, 0.633 },
                        { 0.465, 0.621 },
                        { 0.446, 0.654 },
                        { 0.429, 0.647 },
                        { 0.406, 0.704 },
                        { 0.440, 0.740 },
                        { 0.467, 0.678 },
                        { 0.547, 0.724 },
                    },
                },
            },
        },

        -- 9. Kel'Thuzad
        {
            step      = 9,
            priority  = 9,
            bossIndex = 9,
            title     = "Kel'Thuzad",
            requires  = { 8 },
            segments  = {
                {
                    mapID  = 2001,
                    kind   = "path",
                    note   = "After killing Fatescribe Roh-Kalo, go back out the way you came and follow the path to Kel'Thuzad.",
                    points = {
                        { 0.546, 0.704 },
                        { 0.490, 0.704 },
                        { 0.451, 0.657 },
                        { 0.466, 0.619 },
                        { 0.435, 0.578 },
                        { 0.428, 0.521 },
                        { 0.322, 0.521 },
                    },
                },
            },
        },

        -- 10. Sylvanas Windrunner
        {
            step      = 10,
            priority  = 10,
            bossIndex = 10,
            title     = "Sylvanas Windrunner",
            requires  = { 9 },
            segments  = {
                {
                    mapID  = 2001,
                    kind   = "path",
                    note   = "After killing Kel'Thuzad, take the purple portal that appeared right behind him.",
                    points = {},
                },
                {
                    mapID  = 2002,
                    kind   = "path",
                    note   = "You arrive at Pinnacle of Domination right in front of Sylvanas Windrunner. Walk towards the boss to trigger dialog and start the encounter.",
                    points = {},
                },
            },
        },

    },  -- routing
}
