-------------------------------------------------------------------------------
-- RetroRuns Data -- Maw of Souls
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1492  |  journalInstanceID: 727
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[727] = {
    kind              = "dungeon",
    instanceID        = 1492,
    journalInstanceID = 727,
    name              = "Maw of Souls",
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
            name               = "Ymiron, the Fallen King",
            journalEncounterID = 1502,
            achievements       = {
                { id = 10413, name = "Instant Karma", meta = true },
            },
            loot = {
                { id = 134179, slot = "Chest", name = "Skoldiir Breastplate", sources = { [14]=77483, [15]=77483, [16]=77483 } },
                { id = 134210, slot = "Feet", name = "Tideskorn Sabatons", sources = { [14]=77504, [15]=77504, [16]=77504 } },
                { id = 134217, slot = "Hands", name = "Bonespeaker Gloves", sources = { [14]=77511, [15]=77511, [16]=77511 } },
                { id = 133629, slot = "Head", name = "Crown of Fallen Kings", sources = { [14]=76867, [15]=79936, [16]=76867 } },
                { id = 133616, slot = "Legs", name = "Legwraps of Unworthy Souls", sources = { [14]=76854, [15]=80055, [16]=76854 } },
                { id = 133625, slot = "Shoulder", name = "Shoulderguards of Bane", sources = { [14]=76863, [15]=80117, [16]=76863 } },
                { id = 134199, slot = "Waist", name = "Biornskin Belt", sources = { [14]=77500, [15]=77500, [16]=77500 } },
                { id = 133614, slot = "Wrist", name = "Frost-Stricken Cuffs", sources = { [14]=76852, [15]=80000, [16]=76852 } },
            },
        },
        {
            index              = 2,
            name               = "Harbaron",
            journalEncounterID = 1512,
            achievements       = {
            },
            loot = {
                { id = 133771, slot = "Back", name = "Seacursed Wrap", sources = { [14]=76913, [15]=80806, [16]=76913 } },
                { id = 134197, slot = "Chest", name = "Biornskin Vest", sources = { [14]=77498, [15]=77498, [16]=77498 } },
                { id = 133611, slot = "Chest", name = "Soul-Stitched Robes", sources = { [14]=76849, [15]=79997, [16]=76849 } },
                { id = 137324, slot = "Feet", name = "Bleak Underworld Treads", sources = { [14]=78929, [15]=80090, [16]=78929 } },
                { id = 134211, slot = "Head", name = "Tideskorn Coif", sources = { [14]=77505, [15]=77505, [16]=77505 } },
                { id = 134218, slot = "Legs", name = "Bonespeaker Leggings", sources = { [14]=77512, [15]=77512, [16]=77512 } },
                { id = 134183, slot = "Legs", name = "Skoldiir Legguards", sources = { [14]=77487, [15]=77487, [16]=77487 } },
                { id = 137325, slot = "Wrist", name = "Afterlife Manacles", sources = { [14]=78930, [15]=80151, [16]=78930 } },
                { id = 133632, slot = "Wrist", name = "Void-Touched Wristplates", sources = { [14]=76870, [15]=79939, [16]=76870 } },
            },
        },
        {
            index              = 3,
            name               = "Helya",
            journalEncounterID = 1663,
            achievements       = {
                { id = 10412, name = "Poor Unfortunate Souls", meta = true },
                { id = 10807, name = "Maw of Souls" },
                { id = 10808, name = "Heroic: Maw of Souls" },
                { id = 10809, name = "Mythic: Maw of Souls" },
                { id = 60828, name = "Maw of Souls" },
                { id = 60829, name = "Heroic: Maw of Souls" },
                { id = 60830, name = "Mythic: Maw of Souls" },
                { id = 10411, name = "Helheim Hath No Fury", meta = true },
            },
            loot = {
                { id = 134214, slot = "Chest", name = "Tideskorn Vest", sources = { [14]=77508, [15]=77508, [16]=77508 } },
                { id = 133608, slot = "Feet", name = "Mistbound Helarjar Footwraps", sources = { [14]=76846, [15]=79994, [16]=76846 } },
                { id = 137334, slot = "Feet", name = "Salt-Laden Stompers", sources = { [14]=78934, [15]=79971, [16]=78934 } },
                { id = 134195, slot = "Hands", name = "Biornskin Gloves", sources = { [14]=77496, [15]=77496, [16]=77496 } },
                { id = 137333, slot = "Hands", name = "Seaworthy Deck Hands", sources = { [14]=78933, [15]=80152, [16]=78933 } },
                { id = 133618, slot = "Head", name = "Kraken Hide Helm", sources = { [14]=76856, [15]=80057, [16]=76856 } },
                { id = 133769, slot = "Legs", name = "Tempered Seaborne Leggings", sources = { [14]=76911, [15]=80120, [16]=76911 } },
                { id = 134221, slot = "Shoulder", name = "Bonespeaker Mantle", sources = { [14]=77515, [15]=77515, [16]=77515 } },
                { id = 137332, slot = "Shoulder", name = "Mantle of the Dark Sea", sources = { [14]=78932, [15]=80091, [16]=78932 } },
                { id = 134184, slot = "Shoulder", name = "Skoldiir Shoulderguards", sources = { [14]=77488, [15]=77488, [16]=77488 } },
                { id = 137331, slot = "Waist", name = "Belt of Eternal Torment", sources = { [14]=78931, [15]=80032, [16]=78931 } },
                { id = 133770, slot = "Waist", name = "Slack Tide Girdle", sources = { [14]=76912, [15]=79941, [16]=76912 } },
            },
        },
    },
}
