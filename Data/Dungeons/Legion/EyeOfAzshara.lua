-------------------------------------------------------------------------------
-- RetroRuns Data -- Eye of Azshara
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1456  |  journalInstanceID: 716
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[716] = {
    kind              = "dungeon",
    instanceID        = 1456,
    journalInstanceID = 716,
    name              = "Eye of Azshara",
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
            name               = "Warlord Parjesh",
            journalEncounterID = 1480,
            achievements       = {
                { id = 10456, name = "But You Say He's Just a Friend", meta = true },
            },
            loot = {
                { id = 134223, slot = "Chest", name = "Coralplate Chestguard", sources = { [14]=77517, [15]=77517, [16]=77517 } },
                { id = 134441, slot = "Feet", name = "Shellshock Footguards", sources = { [14]=78958, [15]=80066, [16]=78958 } },
                { id = 134261, slot = "Hands", name = "Seawitch Gloves", sources = { [14]=77545, [15]=77545, [16]=77545 } },
                { id = 134240, slot = "Head", name = "Brinewashed Leather Cowl", sources = { [14]=77531, [15]=77531, [16]=77531 } },
                { id = 137360, slot = "Shoulder", name = "Shoulderpads of Crashing Waves", sources = { [14]=78957, [15]=80035, [16]=78957 } },
                { id = 137361, slot = "Waist", name = "Roaring Shellbreaker Greatbelt", sources = { [14]=78961, [15]=79975, [16]=78961 } },
                { id = 134251, slot = "Waist", name = "Sea Stalker's Cinch", sources = { [14]=77535, [15]=77535, [16]=77535 } },
                { id = 134484, slot = "Wrist", name = "Crestrider Conduit Bracers", sources = { [14]=78959, [15]=80144, [16]=78959 } },
            },
        },
        {
            index              = 2,
            name               = "Lady Hatecoil",
            journalEncounterID = 1490,
            achievements       = {
                { id = 10457, name = "Stay Salty", meta = true },
            },
            loot = {
                { id = 134263, slot = "Chest", name = "Seawitch Robes", sources = { [14]=77547, [15]=77547, [16]=77547 } },
                { id = 134505, slot = "Feet", name = "Horizon Line Warboots", sources = { [14]=78960, [15]=79947, [16]=78960 } },
                { id = 134253, slot = "Hands", name = "Sea Stalker's Gloves", sources = { [14]=77537, [15]=77537, [16]=77537 } },
                { id = 134471, slot = "Head", name = "Helm of Endless Dunes", sources = { [14]=78964, [15]=80131, [16]=78964 } },
                { id = 134238, slot = "Legs", name = "Brinewashed Leather Pants", sources = { [14]=77529, [15]=77529, [16]=77529 } },
                { id = 137364, slot = "Shoulder", name = "Crashing Oceantide Mantle", sources = { [14]=78963, [15]=80094, [16]=78963 } },
                { id = 134433, slot = "Waist", name = "Cord of the Sea-Caller", sources = { [14]=78962, [15]=80021, [16]=78962 } },
                { id = 134230, slot = "Wrist", name = "Coralplate Wristguard", sources = { [14]=77524, [15]=77524, [16]=77524 } },
            },
        },
        {
            index              = 3,
            name               = "King Deepbeard",
            journalEncounterID = 1491,
            achievements       = {
            },
            loot = {
                { id = 134406, slot = "Back", name = "Mainsail Cloak", sources = { [14]=78969, [15]=80810, [16]=78969 } },
                { id = 137368, slot = "Chest", name = "Breastplate of Ten Lashes", sources = { [14]=78967, [15]=80155, [16]=78967 } },
                { id = 134514, slot = "Legs", name = "Keelhauler Legplates", sources = { [14]=78968, [15]=79956, [16]=78968 } },
                { id = 134428, slot = "Legs", name = "Rising Ocean Legwraps", sources = { [14]=78965, [15]=80017, [16]=78965 } },
                { id = 134456, slot = "Waist", name = "Taut Halyard Waistband", sources = { [14]=78966, [15]=80081, [16]=78966 } },
            },
        },
        {
            index              = 4,
            name               = "Serpentrix",
            journalEncounterID = 1479,
            achievements       = {
            },
            loot = {
                { id = 134438, slot = "Chest", name = "Tunic of the Pitiless Monstrosity", sources = { [14]=78971, [15]=80063, [16]=78971 } },
                { id = 134465, slot = "Feet", name = "Hydra Scale Sabatons", sources = { [14]=78972, [15]=80125, [16]=78972 } },
                { id = 134239, slot = "Hands", name = "Brinewashed Leather Grips", sources = { [14]=77530, [15]=77530, [16]=77530 } },
                { id = 134508, slot = "Hands", name = "Stormwake Handguards", sources = { [14]=78973, [15]=79950, [16]=78973 } },
                { id = 134260, slot = "Head", name = "Seawitch Hood", sources = { [14]=77544, [15]=77544, [16]=77544 } },
                { id = 134256, slot = "Legs", name = "Sea Stalker's Leggings", sources = { [14]=77540, [15]=77540, [16]=77540 } },
                { id = 134228, slot = "Shoulder", name = "Coralplate Pauldrons", sources = { [14]=77522, [15]=77522, [16]=77522 } },
                { id = 137372, slot = "Wrist", name = "Wristbands of the Swirling Deeps", sources = { [14]=78970, [15]=80036, [16]=78970 } },
            },
        },
        {
            index              = 5,
            name               = "Wrath of Azshara",
            journalEncounterID = 1492,
            achievements       = {
                { id = 10458, name = "Ready for Raiding V", meta = true },
                { id = 10780, name = "Eye of Azshara" },
                { id = 10781, name = "Heroic: Eye of Azshara" },
                { id = 10782, name = "Mythic: Eye of Azshara" },
                { id = 60819, name = "Eye of Azshara" },
                { id = 60820, name = "Heroic: Eye of Azshara" },
                { id = 60821, name = "Mythic: Eye of Azshara" },
            },
            loot = {
                { id = 134237, slot = "Feet", name = "Brinewashed Leather Boots", sources = { [14]=77528, [15]=77528, [16]=77528 } },
                { id = 134417, slot = "Feet", name = "Slippers of Martyrdom", sources = { [14]=78974, [15]=80006, [16]=78974 } },
                { id = 134512, slot = "Head", name = "Casque of the Deep", sources = { [14]=78977, [15]=79954, [16]=78977 } },
                { id = 134255, slot = "Head", name = "Sea Stalker's Hood", sources = { [14]=77539, [15]=77539, [16]=77539 } },
                { id = 134478, slot = "Shoulder", name = "Thundercrush Pauldrons", sources = { [14]=78976, [15]=80138, [16]=78976 } },
                { id = 134225, slot = "Waist", name = "Coralplate Girdle", sources = { [14]=77519, [15]=77519, [16]=77519 } },
                { id = 134259, slot = "Waist", name = "Seawitch Cinch", sources = { [14]=77543, [15]=77543, [16]=77543 } },
                { id = 134459, slot = "Wrist", name = "Cuffs of the Arcane Storm", sources = { [14]=78975, [15]=80084, [16]=78975 } },
            },
        },
    },
}
