-------------------------------------------------------------------------------
-- RetroRuns Data -- The Arcway
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1516  |  journalInstanceID: 726
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[726] = {
    kind              = "dungeon",
    instanceID        = 1516,
    journalInstanceID = 726,
    name              = "The Arcway",
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
            name               = "Ivanyr",
            journalEncounterID = 1497,
            achievements       = {
                { id = 10773, name = "Arcanic Cling", meta = true },
            },
            loot = {
                { id = 134501, slot = "Chest", name = "Crackling Overcharge Chestguard", sources = { [14]=78986, [15]=79943, [16]=78986 } },
                { id = 134298, slot = "Feet", name = "Ley Dragoon's Stompers", sources = { [14]=77572, [15]=77572, [16]=77572 } },
                { id = 137397, slot = "Feet", name = "Tunnel Trudger Footguards", sources = { [14]=78983, [15]=80095, [16]=78983 } },
                { id = 134421, slot = "Hands", name = "Ink-Smudged Handwraps", sources = { [14]=78981, [15]=80010, [16]=78981 } },
                { id = 134467, slot = "Hands", name = "Nether Mindsnappers", sources = { [14]=78984, [15]=80127, [16]=78984 } },
                { id = 134309, slot = "Shoulder", name = "Manawracker Shoulders", sources = { [14]=77583, [15]=77583, [16]=77583 } },
                { id = 134269, slot = "Waist", name = "Arcane Defender's Belt", sources = { [14]=77553, [15]=77553, [16]=77553 } },
                { id = 134280, slot = "Wrist", name = "Swordsinger's Wristguards", sources = { [14]=77561, [15]=77561, [16]=77561 } },
            },
        },
        {
            index              = 2,
            name               = "Corstilax",
            journalEncounterID = 1498,
            achievements       = {
                { id = 10775, name = "Clean House", meta = true },
            },
            loot = {
                { id = 134402, slot = "Back", name = "Cape of Rigid Order", sources = { [14]=78989, [15]=80807, [16]=78989 } },
                { id = 134463, slot = "Chest", name = "Decontaminated Chain Tunic", sources = { [14]=78985, [15]=80123, [16]=78985 } },
                { id = 134424, slot = "Head", name = "Collar of Enclosure", sources = { [14]=78987, [15]=80013, [16]=78987 } },
                { id = 134453, slot = "Shoulder", name = "Spaulders of Aberrant Inhibition", sources = { [14]=78982, [15]=80078, [16]=78982 } },
                { id = 134522, slot = "Wrist", name = "Detention Wristclamps", sources = { [14]=78988, [15]=79964, [16]=78988 } },
            },
        },
        {
            index              = 3,
            name               = "General Xakal",
            journalEncounterID = 1499,
            achievements       = {
            },
            loot = {
                { id = 134373, slot = "Chest", name = "Felbat Leather Vest", sources = { [14]=77634, [15]=77634, [16]=77634 } },
                { id = 134396, slot = "Feet", name = "Netherwhisper Slippers", sources = { [14]=77650, [15]=77650, [16]=77650 } },
                { id = 134509, slot = "Hands", name = "Fists of the Legion", sources = { [14]=78993, [15]=79951, [16]=78993 } },
                { id = 134387, slot = "Head", name = "Mardum Chain Helm", sources = { [14]=77641, [15]=77641, [16]=77641 } },
                { id = 134449, slot = "Legs", name = "Bloodclaw Leggings", sources = { [14]=78991, [15]=80074, [16]=78991 } },
                { id = 137404, slot = "Legs", name = "Legwraps of Reverberating Shadows", sources = { [14]=78990, [15]=80037, [16]=78990 } },
                { id = 134359, slot = "Legs", name = "Portalguard Legplates", sources = { [14]=77623, [15]=77623, [16]=77623 } },
                { id = 137405, slot = "Wrist", name = "Remorseless Chain Armbands", sources = { [14]=78992, [15]=80156, [16]=78992 } },
            },
        },
        {
            index              = 4,
            name               = "Nal'tira",
            journalEncounterID = 1500,
            achievements       = {
            },
            loot = {
                { id = 134410, slot = "Back", name = "Cloak of Mana-Spun Silk", sources = { [14]=78998, [15]=80813, [16]=78998 } },
                { id = 137410, slot = "Head", name = "Greathelm of Barbed Chelicerae", sources = { [14]=78997, [15]=79976, [16]=78997 } },
                { id = 134472, slot = "Shoulder", name = "Arcane Exterminator's Shoulderguards", sources = { [14]=78996, [15]=80132, [16]=78996 } },
                { id = 137409, slot = "Waist", name = "Manafang Waistguard", sources = { [14]=78995, [15]=80096, [16]=78995 } },
                { id = 134435, slot = "Wrist", name = "Tunnel Fiend Bracers", sources = { [14]=78994, [15]=80023, [16]=78994 } },
            },
        },
        {
            index              = 5,
            name               = "Advisor Vandros",
            journalEncounterID = 1501,
            achievements       = {
                { id = 10776, name = "No Time to Waste", meta = true },
                { id = 10813, name = "Mythic: The Arcway" },
                { id = 60840, name = "The Arcway" },
                { id = 60841, name = "Heroic: The Arcway" },
                { id = 60842, name = "Mythic: The Arcway" },
            },
            loot = {
                { id = 134267, slot = "Chest", name = "Arcane Defender's Breastplate", sources = { [14]=77551, [15]=77551, [16]=77551 } },
                { id = 134413, slot = "Chest", name = "Fluxflow Robes", sources = { [14]=78999, [15]=80002, [16]=78999 } },
                { id = 137417, slot = "Feet", name = "Treads of Fates Entwined", sources = { [14]=79006, [15]=79977, [16]=79006 } },
                { id = 134297, slot = "Hands", name = "Ley Dragoon's Gloves", sources = { [14]=77571, [15]=77571, [16]=77571 } },
                { id = 134444, slot = "Hands", name = "Mana-Lanced Gloves", sources = { [14]=79001, [15]=80069, [16]=79001 } },
                { id = 137415, slot = "Head", name = "Gaze of Fleeting Hours", sources = { [14]=79002, [15]=80097, [16]=79002 } },
                { id = 134304, slot = "Head", name = "Manawracker Crown", sources = { [14]=77578, [15]=77578, [16]=77578 } },
                { id = 134475, slot = "Legs", name = "Mute Erasure Legguards", sources = { [14]=79003, [15]=80135, [16]=79003 } },
                { id = 134518, slot = "Shoulder", name = "Frozen Pendulum Shoulderguards", sources = { [14]=79005, [15]=79960, [16]=79005 } },
                { id = 134286, slot = "Shoulder", name = "Swordsinger's Shoulders", sources = { [14]=77567, [15]=77567, [16]=77567 } },
                { id = 137416, slot = "Waist", name = "Chain of Causal Links", sources = { [14]=79004, [15]=80157, [16]=79004 } },
                { id = 137413, slot = "Waist", name = "Time-Breached Waistband", sources = { [14]=79000, [15]=80038, [16]=79000 } },
            },
        },
    },
}
