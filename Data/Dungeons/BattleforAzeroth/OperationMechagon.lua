-------------------------------------------------------------------------------
-- RetroRuns Data -- Operation: Mechagon
-- Battle for Azeroth dungeon, Patch 8.2.0  |  instanceID: 2097  |  journalInstanceID: 1178
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1178] = {
    kind              = "dungeon",
    instanceID        = 2097,
    journalInstanceID = 1178,
    name              = "Operation: Mechagon",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.2.0",

    bosses = {
        {
            index              = 1,
            name               = "King Gobbamak",
            journalEncounterID = 2357,
            achievements       = {
                { id = 13706, name = "Stay Positive" },
            },
            loot = {
                { id = 169053, slot = "Feet", name = "Roughshod Chain Boots", sources = { [15]=105008, [16]=104924 } },
                { id = 169049, slot = "Feet", name = "Supplicant's Soiled Slippers", sources = { [15]=105009, [16]=104918 } },
                { id = 169054, slot = "Hands", name = "Galvanized Leather Grips", sources = { [15]=105006, [16]=104925 } },
                { id = 169051, slot = "Legs", name = "Anodized Plate Legguards", sources = { [15]=105007, [16]=104920 } },
                { id = 169050, slot = "Two-Hand", name = "Logg", sources = { [16]=104919 } },
                { id = 169035, slot = "Two-Hand", name = "Reclaimed Shock Coil", sources = { [15]=104903, [16]=104904 } },
                { id = 169052, slot = "Weapon", name = "Cranial Recalibrator", sources = { [15]=104922, [16]=104923 } },
            },
        },
        {
            index              = 2,
            name               = "Gunker",
            journalEncounterID = 2358,
            achievements       = {
                { id = 13698, name = "Clean Up On Aisle Mechagon" },
            },
            loot = {
                { id = 169055, slot = "Feet", name = "Greaves of Acid Resistance", sources = { [15]=104927, [16]=104928 } },
                { id = 169056, slot = "Feet", name = "Ooey-Gooey Galoshes", sources = { [15]=105011, [16]=104929 } },
                { id = 169061, slot = "Hands", name = "Insulating Threaded Gloves", sources = { [15]=105010, [16]=104940 } },
                { id = 169059, slot = "Hands", name = "Slick Tactical Grips", sources = { [15]=104935, [16]=104936 } },
                { id = 169060, slot = "Waist", name = "Mekgineer's Utility Belt", sources = { [15]=104938, [16]=104939 } },
                { id = 169057, slot = "Waist", name = "Well-Oiled Plate Girdle", sources = { [15]=104931, [16]=104932 } },
                { id = 169058, slot = "Weapon", name = "Salvaged Incendiary Tool", sources = { [15]=105402, [16]=105403 } },
                { id = 169062, slot = "Weapon", name = "Sharpened Trogg Femur", sources = { [15]=105098, [16]=104941 } },
            },
        },
        {
            index              = 3,
            name               = "Trixie & Naeno",
            journalEncounterID = 2360,
            achievements       = {
            },
            loot = {
                { id = 169064, slot = "Back", name = "Mountebank's Colorful Cloak", sources = { [15]=104944, [16]=104945 } },
                { id = 169063, slot = "Hands", name = "High Speed Gauntlets", sources = { [15]=105012, [16]=104942 } },
                { id = 169065, slot = "Legs", name = "Reinforced Riding Chausses", sources = { [15]=105013, [16]=104946 } },
                { id = 169070, slot = "Legs", name = "Unseen Predator's Breeches", sources = { [15]=105014, [16]=104959 } },
                { id = 169068, slot = "Off-hand", name = "Salvaged Mekacycle Shielding", sources = { [15]=104954, [16]=104955 } },
                { id = 169067, slot = "Waist", name = "Silken Safety Harness", sources = { [15]=104951, [16]=104952 } },
                { id = 169066, slot = "Weapon", name = "Trixie's Backup Backbiter", sources = { [15]=104948, [16]=104949 } },
                { id = 169069, slot = "Wrist", name = "Wraps of Electrostatic Potential", sources = { [15]=104957, [16]=104958 } },
            },
        },
        {
            index              = 4,
            name               = "HK-8 Aerial Oppression Unit",
            journalEncounterID = 2355,
            achievements       = {
            },
            loot = {
                { id = 169073, slot = "Chest", name = "Type II Bomber Jacket", sources = { [15]=104967, [16]=104968 } },
                { id = 169072, slot = "Chest", name = "Volatile Arming Doublet", sources = { [15]=104964, [16]=104965 } },
                { id = 169071, slot = "Legs", name = "Overcharged Pantaloons", sources = { [15]=104961, [16]=104962 } },
                { id = 169077, slot = "Ranged", name = "Light Auto-Stabilizing Energy Rifle", sources = { [15]=104974, [16]=104975 } },
                { id = 169074, slot = "Shoulder", name = "Epaulets of Arcing Power", sources = { [15]=104970, [16]=104971 } },
                { id = 169075, slot = "Shoulder", name = "Tank Buster Pauldrons", sources = { [15]=105015, [16]=105016 } },
                { id = 168963, slot = "Weapon", name = "Fusion Hacker", sources = { [15]=105004, [16]=105005 } },
            },
            specialLoot = {
                { id = 168826, kind = "mount", name = "Mechagon Peacekeeper", mythicOnly = true },
                { id = 169385, kind = "pet", name = "Microbot 8D", mythicOnly = true },
            },
        },
        {
            index              = 5,
            name               = "Tussle Tonks",
            journalEncounterID = 2336,
            achievements       = {
                { id = 13723, name = "M.C., Hammered" },
            },
            loot = {
                { id = 168964, slot = "Feet", name = "Hyperthread Boots", sources = { [15]=105020, [16]=104812 } },
                { id = 168966, slot = "Legs", name = "Heavy Alloy Legplates", sources = { [15]=105019, [16]=104813 } },
                { id = 168957, slot = "Waist", name = "Mekgineer's Championship Belt", sources = { [15]=105018, [16]=104804 } },
                { id = 168958, slot = "Waist", name = "Ringmaster's Cummerbund", sources = { [15]=104806, [16]=104807 } },
                { id = 168962, slot = "Weapon", name = "Apex Perforator", sources = { [15]=104809, [16]=104810 } },
                { id = 168955, slot = "Weapon", name = "Electrifying Cognitive Amplifier", sources = { [15]=104802, [16]=104803 } },
                { id = 168967, slot = "Wrist", name = "Gold-Coated Superconductors", sources = { [15]=105017, [16]=104814 } },
            },
        },
        {
            index              = 6,
            name               = "K.U.-J.0.",
            journalEncounterID = 2339,
            achievements       = {
            },
            loot = {
                { id = 168970, slot = "Back", name = "Trashmaster's Mantle", sources = { [15]=104818, [16]=104819 } },
                { id = 168972, slot = "Feet", name = "Pyroclastic Greatboots", sources = { [15]=104824, [16]=104825 } },
                { id = 168969, slot = "Hands", name = "Operator's Mitts", sources = { [15]=105030, [16]=104816 } },
                { id = 168971, slot = "Hands", name = "Swift Pneumatic Grips", sources = { [15]=104821, [16]=104822 } },
                { id = 168968, slot = "Legs", name = "Flame-Seared Leggings", sources = { [15]=105027, [16]=104815 } },
            },
        },
        {
            index              = 7,
            name               = "Machinist's Garden",
            journalEncounterID = 2348,
            achievements       = {
                { id = 13545, name = "Go Ahead, Make My Daisy" },
            },
            loot = {
                { id = 168975, slot = "Feet", name = "Machinist's Treasured Treads", sources = { [15]=105021, [16]=104832 } },
                { id = 168974, slot = "Legs", name = "Self-Repairing Cuisses", sources = { [15]=104830, [16]=104831 } },
                { id = 168973, slot = "Two-Hand", name = "Neural Synapse Enhancer", sources = { [15]=104827, [16]=104828 } },
                { id = 168976, slot = "Waist", name = "Automatic Waist Tightener", sources = { [15]=104834, [16]=104835 } },
                { id = 169608, slot = "Weapon", name = "Tearing Sawtooth Blade", sources = { [15]=105159, [16]=105160 } },
            },
        },
        {
            index              = 8,
            name               = "King Mechagon",
            journalEncounterID = 2331,
            achievements       = {
            },
            loot = {
                { id = 168981, slot = "Chest", name = "Circuit-Linked Chainmail", sources = { [15]=105022, [16]=104843 } },
                { id = 168979, slot = "Chest", name = "Mechanized Plate Chasse", sources = { [15]=104840, [16]=104841 } },
                { id = 168982, slot = "Feet", name = "Regal Mekanospurs", sources = { [15]=105025, [16]=104844 } },
                { id = 168980, slot = "Hands", name = "Gauntlets of Absolute Authority", sources = { [15]=105023, [16]=104842 } },
                { id = 168985, slot = "Hands", name = "Self-Sanitizing Handwraps", sources = { [15]=105028, [16]=104849 } },
                { id = 169003, slot = "Head", name = "Apogee Inventor's Goggles", sources = { [16]=104870 }, mythicOnly = true },
                { id = 169006, slot = "Head", name = "Inventor's Ingenious Trifocals", sources = { [16]=104877 }, mythicOnly = true },
                { id = 169005, slot = "Head", name = "Mekgineer's Mindbending Headgear", sources = { [16]=104874 }, mythicOnly = true },
                { id = 169004, slot = "Head", name = "Psychogenic Prognosticator's Lenses", sources = { [16]=104873 }, mythicOnly = true },
                { id = 168988, slot = "Legs", name = "Royal Attendant's Trousers", sources = { [15]=105031, [16]=104854 } },
                { id = 168984, slot = "Shoulder", name = "Extravagant Epaulets", sources = { [15]=104847, [16]=104848 } },
                { id = 168987, slot = "Shoulder", name = "Shoulderguards of Fraying Sanity", sources = { [15]=104852, [16]=104853 } },
                { id = 168986, slot = "Waist", name = "Mad King's Sporran", sources = { [15]=105029, [16]=104850 } },
                { id = 168983, slot = "Waist", name = "Maniacal Monarch's Girdle", sources = { [15]=105026, [16]=104845 } },
                { id = 168978, slot = "Wrist", name = "Anodized Deflectors", sources = { [15]=104837, [16]=104838 } },
                { id = 168989, slot = "Wrist", name = "Hyperthread Wristwraps", sources = { [15]=105024, [16]=104855 } },
            },
            specialLoot = {
                { id = 255672, kind = "decor", name = "Gnomish Tesla Tower", decorID = 10887 },
                { id = 169378, kind = "pet", name = "Golden Snorf" },
            },
        },
    },
}
