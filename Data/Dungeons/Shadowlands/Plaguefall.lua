-------------------------------------------------------------------------------
-- RetroRuns Data -- Plaguefall
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2289  |  journalInstanceID: 1183
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1183] = {
    kind              = "dungeon",
    instanceID        = 2289,
    journalInstanceID = 1183,
    name              = "Plaguefall",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    patch             = "9.0.1",

    gloryMeta = {
        id   = 14322,
        name = "Glory of the Shadowlands Hero",
        rewardItemID       = 184183,
        rewardMountSpellID = 344659,
        rewardName         = "Voracious Gorger",
    },

    bosses = {
        {
            index              = 1,
            name               = "Globgrog",
            journalEncounterID = 2419,
            achievements       = {
                { id = 14347, name = "Full Gores Meal", meta = true },
            },
            loot = {
                { id = 178756, slot = "Feet", name = "Stradama's Misplaced Slippers", sources = { [14]=111478 } },
                { id = 178760, slot = "Head", name = "Digested Interrogator's Gaze", sources = { [14]=111482 } },
                { id = 178773, slot = "Head", name = "Plague Handler's Greathelm", sources = { [14]=111490 } },
                { id = 178762, slot = "Legs", name = "Blightborne Chain Legguards", sources = { [14]=111484 } },
                { id = 178753, slot = "Weapon", name = "Surgical Pustule Extractor", sources = { [14]=111475 } },
            },
        },
        {
            index              = 2,
            name               = "Doctor Ickus",
            journalEncounterID = 2403,
            achievements       = {
                { id = 14296, name = "Going Viral", meta = true },
            },
            loot = {
                { id = 178775, slot = "Hands", name = "Fleshfused Crushers", sources = { [14]=111492 } },
                { id = 178759, slot = "Head", name = "Depraved Physician's Mask", sources = { [14]=111481 } },
                { id = 178763, slot = "Shoulder", name = "Malodorous Gristle-Sown Spaulders", sources = { [14]=111485 } },
                { id = 178752, slot = "Weapon", name = "Sophisticated Bonecracker", sources = { [14]=111474 } },
                { id = 178767, slot = "Wrist", name = "Tortured Assistant's Bindings", sources = { [14]=111488 } },
            },
        },
        {
            index              = 3,
            name               = "Domina Venomblade",
            journalEncounterID = 2423,
            achievements       = {
            },
            loot = {
                { id = 178930, slot = "Hands", name = "Mitts of Flawless Duplication", sources = { [14]=111585 } },
                { id = 178929, slot = "Two-Hand", name = "Halberd of the Aranakk", sources = { [14]=111584 } },
                { id = 178932, slot = "Waist", name = "Belt of Wretched Manipulations", sources = { [14]=111587 } },
                { id = 178931, slot = "Waist", name = "Scarred Bloodbound Girdle", sources = { [14]=111586 } },
                { id = 178928, slot = "Weapon", name = "Domina's Oozing Shiv", sources = { [14]=111583 } },
                { id = 178934, slot = "Wrist", name = "Fastened Venombarb Binds", sources = { [14]=111588 } },
            },
        },
        {
            index              = 4,
            name               = "Margrave Stradama",
            journalEncounterID = 2404,
            achievements       = {
                { id = 14369, name = "Plaguefall" },
                { id = 14414, name = "Heroic: Plaguefall" },
                { id = 14415, name = "Mythic: Plaguefall" },
                { id = 14292, name = "Riding with my Slimes", meta = true },
            },
            loot = {
                { id = 178755, slot = "Back", name = "Blighted Margrave's Cloak", sources = { [14]=111477 } },
                { id = 178774, slot = "Feet", name = "Muckwallow Stompers", sources = { [14]=111491 } },
                { id = 178757, slot = "Hands", name = "Gloves of Obscure Rituals", sources = { [14]=111479 } },
                { id = 178761, slot = "Legs", name = "Leggings of the Erudite Scholar", sources = { [14]=111483 } },
                { id = 178764, slot = "Shoulder", name = "Plagueborne Shoulderguards", sources = { [14]=111486 } },
                { id = 178754, slot = "Weapon", name = "Poxstorm, Longsword of Pestilence", sources = { [14]=111476 } },
            },
            specialLoot = {
                { id = 181271, kind = "pet", name = "Sludge Feeler", mythicOnly = true },
            },
        },
    },
}
