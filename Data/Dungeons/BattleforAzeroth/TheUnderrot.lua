-------------------------------------------------------------------------------
-- RetroRuns Data -- The Underrot
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1841  |  journalInstanceID: 1022
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1022] = {
    kind              = "dungeon",
    instanceID        = 1841,
    journalInstanceID = 1022,
    name              = "The Underrot",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.0.1",

    gloryMeta = {
        id   = 12812,
        name = "Glory of the Wartorn Hero",
        rewardItemID       = 161215,
        rewardName         = "Reins of the Obsidian Krolusk",
    },

    bosses = {
        {
            index              = 1,
            name               = "Elder Leaxa",
            journalEncounterID = 2157,
            achievements       = {
                { id = 12498, name = "Taint Nobody Got Time For That", meta = true },
            },
            loot = {
                { id = 159443, slot = "Legs", name = "Legplates of Profane Sacrifice", sources = { [14]=95251, [15]=95252, [16]=95735 } },
                { id = 159402, slot = "Waist", name = "Waistguard of Sanguine Fervor", sources = { [14]=95190, [15]=98427, [16]=98428 } },
                { id = 159652, slot = "Weapon", name = "Leaxa's Thought-Piercer", sources = { [14]=95439, [15]=95496, [16]=95497 } },
                { id = 159324, slot = "Wrist", name = "Blood Elder's Bindings", sources = { [14]=95087, [15]=95088, [16]=95721 } },
            },
        },
        {
            index              = 2,
            name               = "Cragmaw the Infested",
            journalEncounterID = 2131,
            achievements       = {
            },
            loot = {
                { id = 159436, slot = "Feet", name = "Fluorescent Flora Stompers", sources = { [14]=95241, [15]=95733, [16]=95734 } },
                { id = 159396, slot = "Feet", name = "Waders of the Infested", sources = { [14]=95182, [15]=95183, [16]=98426 } },
                { id = 159382, slot = "Hands", name = "Blood Tick Crushers", sources = { [14]=95164, [15]=98417, [16]=98418 } },
                { id = 159344, slot = "Hands", name = "Underrot Grotto Tenders", sources = { [14]=95115, [15]=98486, [16]=98487 } },
                { id = 159269, slot = "Legs", name = "Darklight Legwarmers", sources = { [14]=95016, [15]=95017, [16]=95716 } },
                { id = 159325, slot = "Waist", name = "Bloodfeaster Belt", sources = { [14]=95089, [15]=95090, [16]=95722 } },
                { id = 159653, slot = "Weapon", name = "Bile-Stained Crawg Tusks", sources = { [14]=96087, [15]=96490, [16]=96491 } },
                { id = 159134, slot = "Weapon", name = "Heart-Piercing Stalactite", sources = { [14]=94880, [15]=95478, [16]=95479 } },
                { id = 159433, slot = "Wrist", name = "Phosphorescent Armplates", sources = { [14]=95235, [15]=95236, [16]=95732 } },
                { id = 159275, slot = "Wrist", name = "Wristwraps of Twined Morels", sources = { [14]=95024, [15]=95718, [16]=95719 } },
            },
        },
        {
            index              = 3,
            name               = "Sporecaller Zancha",
            journalEncounterID = 2130,
            achievements       = {
                { id = 12549, name = "Not a Fun Guy", meta = true },
            },
            loot = {
                { id = 159292, slot = "Back", name = "Sporecaller's Shroud", sources = { [14]=95045, [15]=98373, [16]=98374 } },
                { id = 159270, slot = "Feet", name = "Blood Warder's Moccasins", sources = { [14]=95018, [15]=95019, [16]=95717 } },
                { id = 159384, slot = "Legs", name = "Corpuscular Greaves", sources = { [14]=95166, [15]=98419, [16]=98420 } },
                { id = 159338, slot = "Legs", name = "Pustule Bearer's Pants", sources = { [14]=95106, [15]=95729, [16]=95730 } },
                { id = 159665, slot = "Off-hand", name = "Targe of the Ancient Warder", sources = { [14]=95452, [15]=95523, [16]=95524 } },
                { id = 159654, slot = "Two-Hand", name = "Corruption Borne Headlopper", sources = { [14]=95441, [15]=95467, [16]=95468 } },
                { id = 159410, slot = "Waist", name = "Zancha's Venerated Greatbelt", sources = { [14]=95201, [15]=95202, [16]=95630 } },
            },
        },
        {
            index              = 4,
            name               = "Unbound Abomination",
            journalEncounterID = 2158,
            achievements       = {
                { id = 12499, name = "Sporely Alive", meta = true },
                { id = 12500, name = "Underrot" },
                { id = 12501, name = "Heroic: Underrot" },
                { id = 12502, name = "Mythic: Underrot" },
            },
            loot = {
                { id = 159241, slot = "Chest", name = "Blood-Drenched Robes", sources = { [14]=94978, [15]=94979, [16]=95759 } },
                { id = 206199, slot = "Chest", name = "Blood-Drenched Robes", sources = { [14]=187867, [15]=187867, [16]=187867 }, mythicPlusOnly = true },
                { id = 159432, slot = "Chest", name = "Breastplate of Arterial Protection", sources = { [14]=95233, [15]=95234, [16]=95731 } },
                { id = 206197, slot = "Chest", name = "Breastplate of Arterial Protection", sources = { [14]=187862, [15]=187862, [16]=187862 }, mythicPlusOnly = true },
                { id = 159330, slot = "Chest", name = "Gore-Splattered Vest", sources = { [14]=95095, [15]=95725, [16]=95726 } },
                { id = 206198, slot = "Chest", name = "Gore-Splattered Vest", sources = { [14]=187866, [15]=187866, [16]=187866 }, mythicPlusOnly = true },
                { id = 159253, slot = "Hands", name = "Gloves of Staunched Wounds", sources = { [14]=94996, [15]=95708, [16]=95709 } },
                { id = 159446, slot = "Head", name = "Greathelm of the Putrid Path", sources = { [14]=95255, [15]=95738, [16]=95739 } },
                { id = 159381, slot = "Head", name = "Visage of Bloody Horrors", sources = { [14]=95163, [15]=98415, [16]=98416 } },
                { id = 159385, slot = "Shoulder", name = "Amalgamated Abomination Spaulders", sources = { [14]=95167, [15]=98421, [16]=98422 } },
                { id = 159267, slot = "Shoulder", name = "Pauldrons of Vile Corruption", sources = { [14]=95013, [15]=95714, [16]=95715 } },
                { id = 159323, slot = "Shoulder", name = "Shoulders of the Sanguine Monstrosity", sources = { [14]=95085, [15]=95086, [16]=95720 } },
                { id = 159655, slot = "Two-Hand", name = "Vile Exsanguinator", sources = { [14]=95442, [15]=95505, [16]=95506 } },
            },
            specialLoot = {
                { id = 160829, kind = "mount", name = "Underrot Crawg Harness" },
            },
        },
    },
}
