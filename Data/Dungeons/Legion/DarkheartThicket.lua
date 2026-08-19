-------------------------------------------------------------------------------
-- RetroRuns Data -- Darkheart Thicket
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1466  |  journalInstanceID: 762
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[762] = {
    kind              = "dungeon",
    instanceID        = 1466,
    journalInstanceID = 762,
    name              = "Darkheart Thicket",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    patch             = "7.0.3",

    gloryMeta = {
        id   = 11163,
        name = "Glory of the Legion Hero",
        rewardItemID       = 141217,
        rewardMountSpellID = 225765,
        rewardName         = "Leyfeather Hippogryph",
    },

    bosses = {
        {
            index              = 1,
            name               = "Archdruid Glaidalis",
            journalEncounterID = 1654,
            achievements       = {
            },
            loot = {
                { id = 139071, slot = "Chest", name = "Tranquil Bough Vest", sources = { [14]=80416, [15]=80416, [16]=80416 } },
                { id = 134429, slot = "Feet", name = "Grove Darkener's Treads", sources = { [14]=78909, [15]=80062, [16]=78909 } },
                { id = 137300, slot = "Hands", name = "Gloves of Wretched Lesions", sources = { [14]=78910, [15]=80148, [16]=78910 } },
                { id = 139086, slot = "Head", name = "Night Dreamer Crest", sources = { [14]=80428, [15]=80428, [16]=80428 } },
                { id = 139058, slot = "Head", name = "Nightsfall Helmet", sources = { [14]=80406, [15]=80406, [16]=80406 } },
                { id = 139077, slot = "Waist", name = "Bramblemail Belt", sources = { [14]=80419, [15]=80419, [16]=80419 } },
                { id = 134423, slot = "Waist", name = "Poisonroot Belt", sources = { [14]=78908, [15]=80012, [16]=78908 } },
                { id = 134520, slot = "Wrist", name = "Thornscar Wristguards", sources = { [14]=78911, [15]=79962, [16]=78911 } },
            },
        },
        {
            index              = 2,
            name               = "Oakheart",
            journalEncounterID = 1655,
            achievements       = {
            },
            loot = {
                { id = 134500, slot = "Chest", name = "Breastplate of Preservation", sources = { [14]=78915, [15]=79942, [16]=78915 } },
                { id = 121325, slot = "Hands", name = "Terrorweave Gloves", sources = { [14]=68476, [15]=68476, [16]=68476 } },
                { id = 121319, slot = "Head", name = "Vilescale Helm", sources = { [14]=68470, [15]=68470, [16]=68470 } },
                { id = 137304, slot = "Legs", name = "Oakheart's Trunkwarmers", sources = { [14]=78913, [15]=80028, [16]=78913 } },
                { id = 121280, slot = "Legs", name = "Wracksoul Legplates", sources = { [14]=68433, [15]=68433, [16]=68433 } },
                { id = 134452, slot = "Shoulder", name = "Epaulets of Desiccated Foliage", sources = { [14]=78912, [15]=80077, [16]=78912 } },
                { id = 121299, slot = "Waist", name = "Dreadhide Girdle", sources = { [14]=68450, [15]=68450, [16]=68450 } },
                { id = 211473, slot = "Weapon", name = "Corrupted Knot", sources = { [14]=194146, [15]=194146, [16]=194146 }, mythicPlusOnly = true },
                { id = 137305, slot = "Wrist", name = "Blighted Grasp Bracers", sources = { [14]=78914, [15]=80149, [16]=78914 } },
            },
        },
        {
            index              = 3,
            name               = "Dresaron",
            journalEncounterID = 1656,
            achievements       = {
                { id = 10766, name = "Egg-cellent!", meta = true },
            },
            loot = {
                { id = 139089, slot = "Chest", name = "Night Dreamer Robe", sources = { [14]=80431, [15]=80431, [16]=80431 } },
                { id = 134464, slot = "Feet", name = "Whelp Handler's Lined Boots", sources = { [14]=78919, [15]=80124, [16]=78919 } },
                { id = 139056, slot = "Hands", name = "Nightsfall Gauntlets", sources = { [14]=80404, [15]=80404, [16]=80404 } },
                { id = 139070, slot = "Head", name = "Tranquil Bough Hood", sources = { [14]=80415, [15]=80415, [16]=80415 } },
                { id = 139082, slot = "Legs", name = "Bramblemail Greaves", sources = { [14]=80424, [15]=80424, [16]=80424 } },
                { id = 137309, slot = "Shoulder", name = "Slipstream Shoulderpads", sources = { [14]=78916, [15]=80029, [16]=78916 } },
                { id = 137310, slot = "Waist", name = "Greatbelt of Disruption", sources = { [14]=78920, [15]=79969, [16]=78920 } },
                { id = 134461, slot = "Wrist", name = "Thermal Bindings", sources = { [14]=78918, [15]=80086, [16]=78918 } },
            },
        },
        {
            index              = 4,
            name               = "Shade of Xavius",
            journalEncounterID = 1657,
            achievements       = {
                { id = 10783, name = "Darkheart Thicket" },
                { id = 10784, name = "Heroic: Darkheart Thicket" },
                { id = 10785, name = "Mythic: Darkheart Thicket" },
                { id = 60837, name = "Darkheart Thicket" },
                { id = 60838, name = "Heroic: Darkheart Thicket" },
                { id = 60839, name = "Mythic: Darkheart Thicket" },
            },
            loot = {
                { id = 134405, slot = "Back", name = "Cloak of Fading Echoes", sources = { [14]=78917, [15]=80809, [16]=78917 } },
                { id = 134462, slot = "Chest", name = "Dream Bolstered Chestguard", sources = { [14]=78923, [15]=80122, [16]=78923 } },
                { id = 121276, slot = "Chest", name = "Wracksoul Chestplate", sources = { [14]=68429, [15]=68429, [16]=68429 } },
                { id = 134504, slot = "Feet", name = "Curserunner Soulcrushers", sources = { [14]=78924, [15]=79946, [16]=78924 } },
                { id = 121293, slot = "Feet", name = "Dreadhide Boots", sources = { [14]=68444, [15]=68444, [16]=68444 } },
                { id = 137319, slot = "Feet", name = "Paranoid Sprinters", sources = { [14]=78925, [15]=80031, [16]=78925 } },
                { id = 137320, slot = "Hands", name = "Gloves of Vile Defiance", sources = { [14]=78926, [15]=80089, [16]=78926 } },
                { id = 134448, slot = "Legs", name = "Ashen Satyr Leggings", sources = { [14]=78922, [15]=80073, [16]=78922 } },
                { id = 121326, slot = "Legs", name = "Terrorweave Leggings", sources = { [14]=68477, [15]=68477, [16]=68477 } },
                { id = 137321, slot = "Shoulder", name = "Burning Sky Pauldrons", sources = { [14]=78927, [15]=80150, [16]=78927 } },
                { id = 137322, slot = "Shoulder", name = "Mantle of the Resolute Champion", sources = { [14]=78928, [15]=79970, [16]=78928 } },
                { id = 121316, slot = "Wrist", name = "Vilescale Bracers", sources = { [14]=68467, [15]=68467, [16]=68467 } },
                { id = 137314, slot = "Wrist", name = "Wristbands of Cursed Torment", sources = { [14]=78921, [15]=80030, [16]=78921 } },
            },
            specialLoot = {
                { id = 238857, kind = "decor", name = "Moon-Blessed Storage Crate", decorID = 673 },
            },
        },
    },
}
