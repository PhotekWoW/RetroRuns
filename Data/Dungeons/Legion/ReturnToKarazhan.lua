-------------------------------------------------------------------------------
-- RetroRuns Data -- Return to Karazhan
-- Legion dungeon, Patch 7.1.0  |  instanceID: 1651  |  journalInstanceID: 860
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[860] = {
    kind              = "dungeon",
    instanceID        = 1651,
    journalInstanceID = 860,
    name              = "Return to Karazhan",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 15, 16 },
    patch             = "7.1.0",

    entrance = {
        mapID = 42,
        x     = 0.4637,
        y     = 0.7066,
    },

    bosses = {
        {
            index              = 1,
            name               = "Opera Hall: Wikket",
            journalEncounterID = 1820,
            aliases            = { "Opera Hall" },
            scenarioCriteriaID = 35483,
            achievements       = {
            },
            loot = {
                { id = 142298, slot = "Feet", name = "Astonishingly Scarlet Slippers", sources = { [15]=83079, [16]=83079 } },
                { id = 142204, slot = "Feet", name = "Boots of False Promises", sources = { [15]=83068, [16]=83068 } },
                { id = 142299, slot = "Hands", name = "Horkin' Stuff-Lobbers", sources = { [15]=83080, [16]=83080 } },
                { id = 142205, slot = "Hands", name = "Jabber Grookin' Gauntlets", sources = { [15]=83069, [16]=83069 } },
                { id = 142296, slot = "Head", name = "Wikket Witch's Hat", sources = { [15]=83077, [16]=83077 } },
                { id = 142300, slot = "Legs", name = "Greaves of Miraculous Magnificence", sources = { [15]=83081, [16]=83081 } },
                { id = 142137, slot = "Waist", name = "Short Jibbet Waistguard", sources = { [15]=83047, [16]=83047 } },
                { id = 142198, slot = "Wrist", name = "Inordinately Wondrous Wristguards", sources = { [15]=83061, [16]=83061 } },
            },
        },
        {
            index              = 2,
            name               = "Opera Hall: Westfall Story",
            journalEncounterID = 1826,
            aliases            = { "Opera Hall" },
            achievements       = {
            },
            loot = {
                { id = 142201, slot = "Shoulder", name = "Mantle of Conflicted Loyalties", sources = { [15]=83065, [16]=83065 } },
                { id = 142302, slot = "Wrist", name = "Armguards of Burning Passion", sources = { [15]=83083, [16]=83083 } },
                { id = 142146, slot = "Wrist", name = "Blackfin Wristband", sources = { [15]=83040, [16]=83040 } },
                { id = 142154, slot = "Wrist", name = "Bracelets of the Sorrowful Bride", sources = { [15]=83032, [16]=83032 } },
            },
        },
        {
            index              = 3,
            name               = "Opera Hall: Beautiful Beast",
            journalEncounterID = 1827,
            aliases            = { "Opera Hall" },
            achievements       = {
            },
            loot = {
                { id = 142206, slot = "Back", name = "Cloak of Sweltering Flame", sources = { [15]=83070, [16]=83070 } },
                { id = 142304, slot = "Head", name = "Visage of Brutish Iron", sources = { [15]=83085, [16]=83085 } },
                { id = 142197, slot = "Legs", name = "Legguards of Imprisonment", sources = { [15]=83060, [16]=83060 } },
                { id = 142202, slot = "Legs", name = "Trousers of Royal Vanity", sources = { [15]=83066, [16]=83066 } },
                { id = 142196, slot = "Waist", name = "Cinch of Improbable Desire", sources = { [15]=83059, [16]=83059 } },
            },
        },
        {
            index              = 4,
            name               = "Maiden of Virtue",
            journalEncounterID = 1825,
            achievements       = {
            },
            loot = {
                { id = 142170, slot = "Back", name = "Drape of Shame", sources = { [15]=83057, [16]=83057 } },
                { id = 142139, slot = "Chest", name = "Vest of Wanton Deeds", sources = { [15]=83033, [16]=83033 } },
                { id = 142124, slot = "Feet", name = "Treads of the Depraved", sources = { [15]=83050, [16]=83050 } },
                { id = 142153, slot = "Waist", name = "Cord of the Penitent", sources = { [15]=83031, [16]=83031 } },
                { id = 142138, slot = "Wrist", name = "Confiscated Manacles", sources = { [15]=83048, [16]=83048 } },
            },
        },
        {
            index              = 5,
            name               = "Attumen the Huntsman",
            journalEncounterID = 1835,
            achievements       = {
            },
            loot = {
                { id = 142140, slot = "Feet", name = "Calliard's Galoshes", sources = { [15]=83034, [16]=83034 } },
                { id = 142148, slot = "Feet", name = "Wilderness Stalker's Softsoles", sources = { [15]=83026, [16]=83026 } },
                { id = 142126, slot = "Head", name = "Helm of Phantasmal Scars", sources = { [15]=83052, [16]=83052 } },
                { id = 142136, slot = "Shoulder", name = "Mantle of Hideous Trophies", sources = { [15]=83046, [16]=83046 } },
            },
            specialLoot = {
                { id = 142236, kind = "mount", name = "Midnight's Eternal Reins", mythicOnly = true },
            },
        },
        {
            index              = 6,
            name               = "Moroes",
            journalEncounterID = 1837,
            achievements       = {
                { id = 11338, name = "Dine and Bash", soloable = "yes" },
            },
            loot = {
                { id = 142123, slot = "Chest", name = "Breastplate of Obligation", sources = { [15]=83049, [16]=83049 } },
                { id = 142147, slot = "Chest", name = "Robes of Wicked Modesty", sources = { [15]=83025, [16]=83025 } },
                { id = 142134, slot = "Head", name = "Castellan's Blinders", sources = { [15]=83044, [16]=83044 } },
                { id = 142143, slot = "Legs", name = "Willbreaker Legguards", sources = { [15]=83037, [16]=83037 } },
            },
        },
        {
            index              = 7,
            name               = "The Curator",
            journalEncounterID = 1836,
            achievements       = {
            },
            loot = {
                { id = 142141, slot = "Hands", name = "Custodian's Soothing Touch", sources = { [15]=83035, [16]=83035 } },
                { id = 142133, slot = "Hands", name = "Gauntlets of Confinement", sources = { [15]=83043, [16]=83043 } },
                { id = 142149, slot = "Hands", name = "Gloves of Arcane Confluence", sources = { [15]=83027, [16]=83027 } },
                { id = 142125, slot = "Hands", name = "Repurposed Golem Grips", sources = { [15]=83051, [16]=83051 } },
                { id = 142130, slot = "Wrist", name = "Bite-Marked Wristplates", sources = { [15]=83056, [16]=83056 } },
            },
        },
        {
            index              = 8,
            name               = "Shade of Medivh",
            journalEncounterID = 1817,
            achievements       = {
            },
            loot = {
                { id = 142131, slot = "Chest", name = "Frozen-Link Chestguard", sources = { [15]=83041, [16]=83041 } },
                { id = 142152, slot = "Shoulder", name = "Shoulderpads of Chaotic Thought", sources = { [15]=83030, [16]=83030 } },
                { id = 142145, slot = "Waist", name = "Girdle of Ghostly Exclusion", sources = { [15]=83039, [16]=83039 } },
                { id = 142129, slot = "Waist", name = "Spellwarding Waistguard", sources = { [15]=83055, [16]=83055 } },
            },
        },
        {
            index              = 9,
            name               = "Mana Devourer",
            journalEncounterID = 1818,
            achievements       = {
                { id = 11431, name = "The Rat Pack", soloable = "no" },
            },
            loot = {
                { id = 142215, slot = "Back", name = "Wine-Stained Mantle", sources = { [15]=83072, [16]=83072 } },
                { id = 142150, slot = "Head", name = "Hood of Uncanny Perspectives", sources = { [15]=83028, [16]=83028 } },
                { id = 142135, slot = "Legs", name = "Legguards of Countless Hours", sources = { [15]=83045, [16]=83045 } },
                { id = 142128, slot = "Shoulder", name = "Pauldrons of Encroaching Limits", sources = { [15]=83054, [16]=83054 } },
                { id = 142144, slot = "Shoulder", name = "Unending Horizon Spaulders", sources = { [15]=83038, [16]=83038 } },
            },
        },
        {
            index              = 10,
            name               = "Viz'aduum the Watcher",
            journalEncounterID = 1838,
            achievements       = {
                { id = 11335, name = "Season Tickets", soloable = "kinda" },
            },
            loot = {
                { id = 142132, slot = "Feet", name = "Doomstride Footguards", sources = { [15]=83042, [16]=83042 } },
                { id = 142142, slot = "Head", name = "Unbound Reality Mask", sources = { [15]=83036, [16]=83036 } },
                { id = 142151, slot = "Legs", name = "Leggings of Countless Worlds", sources = { [15]=83029, [16]=83029 } },
                { id = 142127, slot = "Legs", name = "Tassets of Perpetual Despair", sources = { [15]=83053, [16]=83053 } },
            },
            specialLoot = {
                { id = 246865, kind = "decor", name = "Tome of Reliquary Insights", decorID = 2531 },
            },
        },
    },
}
