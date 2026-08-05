-------------------------------------------------------------------------------
-- RetroRuns Data -- The Obsidian Sanctum
-- Wrath of the Lich King, Patch 3.0.2  |  instanceID: 615  |  journalInstanceID: 755
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[615] = {
    instanceID        = 615,
    journalInstanceID = 755,
    name              = "The Obsidian Sanctum",
    expansion         = "Wrath of the Lich King",
    patch             = "3.0.2",

    exitNote = "None available",

    -- 10-player and 25-player are separate difficulties with their own
    -- loot tables, so each size keeps its own display bucket -- but the
    -- two sizes share one weekly lockout.
    difficultyModel   = "sizesShared",

    entrance = {
        -- Dragonblight, The Dragon Wastes, beneath Wyrmrest Temple.
        mapID = 115, x = 0.600, y = 0.570,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [155] = "The Obsidian Sanctum",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [40613] = 1,  -- Gloves of the Lost Conqueror
            [40614] = 1,  -- Gloves of the Lost Protector
            [40615] = 1,  -- Gloves of the Lost Vanquisher
            [40628] = 1,  -- Gauntlets of the Lost Conqueror
            [40629] = 1,  -- Gauntlets of the Lost Protector
            [40630] = 1,  -- Gauntlets of the Lost Vanquisher
        },
    },

    -- The Naxxramas-era glory pair spans Naxxramas, The Eye of Eternity,
    -- and this raid. The same pair appears in each participating raid's
    -- file so the entry surfaces in every raid's achievements pane with
    -- shared progress.
    gloryMetas = {
        {
            id   = 2137,
            name = "Glory of the Raider (10 player)",
            rewardMountSpellID = 60021,
            rewardName         = "Plagued Proto-Drake",
            rewardRemoved      = true,
        },
        {
            id   = 2138,
            name = "Glory of the Raider (25 player)",
            rewardMountSpellID = 59976,
            rewardName         = "Black Proto-Drake",
            rewardRemoved      = true,
        },
    },

    bosses = {
        {
            index              = 1,
            name               = "Sartharion",
            journalEncounterID = 1616,
            -- The saved-instance lockout also lists Tenebron, Shadron and
            -- Vesperon as their own rows; they are separate killable
            -- encounters, not names for Sartharion, so they carry no
            -- aliases here and their rows stay unmapped.
            achievements       = {
                { id = 2047, name = "Gonna Go When the Volcano Blows (10 player)", meta = true, soloable = "yes" },
                { id = 2048, name = "Gonna Go When the Volcano Blows (25 player)", meta = true, soloable = "yes" },
                { id = 2051, name = "The Twilight Zone (10 player)", meta = true, soloable = "yes" },
                { id = 2054, name = "The Twilight Zone (25 player)", meta = true, soloable = "yes" },
                { id = 2049, name = "Twilight Assist (10 player)", meta = false, soloable = "yes" },
                { id = 2052, name = "Twilight Assist (25 player)", meta = false, soloable = "yes" },
                { id = 2050, name = "Twilight Duo (10 player)", meta = false, soloable = "yes" },
                { id = 2053, name = "Twilight Duo (25 player)", meta = false, soloable = "yes" },
                { id = 624, name = "Less Is More (10 player)", meta = false, soloable = "yes" },
                { id = 1877, name = "Less Is More (25 player)", meta = false, soloable = "yes" },
            },
            loot = {
                { id = 43988, slot = "Back", name = "Gale-Proof Cloak", sources = { [3]=21275 } },
                { id = 44005, slot = "Back", name = "Pennant Cloak", sources = { [4]=21287 } },
                { id = 43990, slot = "Chest", name = "Blade-Scarred Tunic", sources = { [3]=21277 } },
                { id = 43998, slot = "Chest", name = "Chestguard of Flagrant Prowess", sources = { [3]=21282 } },
                { id = 40453, slot = "Chest", name = "Chestplate of the Great Aspects", sources = { [4]=19436 } },
                { id = 44000, slot = "Chest", name = "Dragonstorm Breastplate", sources = { [4]=21283 } },
                { id = 44002, slot = "Chest", name = "The Sanctum's Flowing Vestments", sources = { [4]=21284 } },
                { id = 43996, slot = "Feet", name = "Sabatons of Firmament", sources = { [3]=21281 } },
                { id = 44004, slot = "Hands", name = "Bountiful Gauntlets", sources = { [4]=21286 } },
                { id = 43995, slot = "Head", name = "Enamored Cowl", sources = { [3]=21280 } },
                { id = 44007, slot = "Head", name = "Headpiece of Reconciliation", sources = { [4]=21289 } },
                { id = 40451, slot = "Head", name = "Hyaline Helm of the Sniper", sources = { [4]=19434 } },
                { id = 44006, slot = "Head", name = "Obsidian Greathelm", sources = { [4]=21288 } },
                { id = 40428, slot = "Head", name = "Titan's Outlook", sources = { [3]=19415 } },
                { id = 43994, slot = "Legs", name = "Belabored Legplates", sources = { [3]=21279 } },
                { id = 40446, slot = "Legs", name = "Dragon Brood Legguards", sources = { [4]=19429 } },
                { id = 44011, slot = "Legs", name = "Leggings of the Honored", sources = { [4]=21291 } },
                { id = 43991, slot = "Legs", name = "Legguards of Composure", sources = { [3]=21278 } },
                { id = 40437, slot = "Shoulder", name = "Concealment Shoulderpads", sources = { [4]=19420 } },
                { id = 40438, slot = "Shoulder", name = "Council Chamber Epaulets", sources = { [4]=19421 } },
                { id = 40439, slot = "Shoulder", name = "Mantle of the Eternal Sentinel", sources = { [4]=19422 } },
                { id = 44003, slot = "Shoulder", name = "Upstanding Spaulders", sources = { [4]=21285 } },
                { id = 40455, slot = "Two-Hand", name = "Staff of Restraint", sources = { [4]=19438 } },
                { id = 43989, slot = "Waist", name = "Remembrance Girdle", sources = { [3]=21276 } },
                { id = 40429, slot = "Weapon", name = "Crimson Steel", sources = { [3]=19416 } },
                { id = 44008, slot = "Wrist", name = "Unsullied Cuffs", sources = { [4]=21290 } },
                { id = 39609, slot = "Hands", name = "Heroes' Dreadnaught Gauntlets", sources = { [3]=18987 }, classes = { 1 } },
                { id = 39622, slot = "Hands", name = "Heroes' Dreadnaught Handguards", sources = { [3]=18997 }, classes = { 1 } },
                { id = 40527, slot = "Hands", name = "Valorous Dreadnaught Gauntlets", sources = { [4]=19500 }, classes = { 1 } },
                { id = 40545, slot = "Hands", name = "Valorous Dreadnaught Handguards", sources = { [4]=19513 }, classes = { 1 } },
                { id = 39634, slot = "Hands", name = "Heroes' Redemption Gauntlets", sources = { [3]=19009 }, classes = { 2 } },
                { id = 39632, slot = "Hands", name = "Heroes' Redemption Gloves", sources = { [3]=19007 }, classes = { 2 } },
                { id = 39639, slot = "Hands", name = "Heroes' Redemption Handguards", sources = { [3]=19014 }, classes = { 2 } },
                { id = 40575, slot = "Hands", name = "Valorous Redemption Gauntlets", sources = { [4]=19542 }, classes = { 2 } },
                { id = 40570, slot = "Hands", name = "Valorous Redemption Gloves", sources = { [4]=19537 }, classes = { 2 } },
                { id = 40580, slot = "Hands", name = "Valorous Redemption Handguards", sources = { [4]=19547 }, classes = { 2 } },
                { id = 39582, slot = "Hands", name = "Heroes' Cryptstalker Handguards", sources = { [3]=18966 }, classes = { 3 } },
                { id = 40504, slot = "Hands", name = "Valorous Cryptstalker Handguards", sources = { [4]=19477 }, classes = { 3 } },
                { id = 39560, slot = "Hands", name = "Heroes' Bonescythe Gauntlets", sources = { [3]=18958 }, classes = { 4 } },
                { id = 40496, slot = "Hands", name = "Valorous Bonescythe Gauntlets", sources = { [4]=19470 }, classes = { 4 } },
                { id = 39519, slot = "Hands", name = "Heroes' Gloves of Faith", sources = { [3]=18932 }, classes = { 5 } },
                { id = 39530, slot = "Hands", name = "Heroes' Handwraps of Faith", sources = { [3]=18938 }, classes = { 5 } },
                { id = 40445, slot = "Hands", name = "Valorous Gloves of Faith", sources = { [4]=19428 }, classes = { 5 } },
                { id = 40454, slot = "Hands", name = "Valorous Handwraps of Faith", sources = { [4]=19437 }, classes = { 5 } },
                { id = 39618, slot = "Hands", name = "Heroes' Scourgeborne Gauntlets", sources = { [3]=18993 }, classes = { 6 } },
                { id = 39624, slot = "Hands", name = "Heroes' Scourgeborne Handguards", sources = { [3]=18999 }, classes = { 6 } },
                { id = 40552, slot = "Hands", name = "Valorous Scourgeborne Gauntlets", sources = { [4]=19519 }, classes = { 6 } },
                { id = 40563, slot = "Hands", name = "Valorous Scourgeborne Handguards", sources = { [4]=19530 }, classes = { 6 } },
                { id = 39593, slot = "Hands", name = "Heroes' Earthshatter Gloves", sources = { [3]=18973 }, classes = { 7 } },
                { id = 39601, slot = "Hands", name = "Heroes' Earthshatter Grips", sources = { [3]=18979 }, classes = { 7 } },
                { id = 39591, slot = "Hands", name = "Heroes' Earthshatter Handguards", sources = { [3]=18971 }, classes = { 7 } },
                { id = 40515, slot = "Hands", name = "Valorous Earthshatter Gloves", sources = { [4]=19488 }, classes = { 7 } },
                { id = 40520, slot = "Hands", name = "Valorous Earthshatter Grips", sources = { [4]=19493 }, classes = { 7 } },
                { id = 40509, slot = "Hands", name = "Valorous Earthshatter Handguards", sources = { [4]=19482 }, classes = { 7 } },
                { id = 39495, slot = "Hands", name = "Heroes' Frostfire Gloves", sources = { [3]=18918 }, classes = { 8 } },
                { id = 40415, slot = "Hands", name = "Valorous Frostfire Gloves", sources = { [4]=19405 }, classes = { 8 } },
                { id = 39500, slot = "Hands", name = "Heroes' Plagueheart Gloves", sources = { [3]=18923 }, classes = { 9 } },
                { id = 40420, slot = "Hands", name = "Valorous Plagueheart Gloves", sources = { [4]=19410 }, classes = { 9 } },
                { id = 39544, slot = "Hands", name = "Heroes' Dreamwalker Gloves", sources = { [3]=18947 }, classes = { 11 } },
                { id = 39557, slot = "Hands", name = "Heroes' Dreamwalker Handgrips", sources = { [3]=18956 }, classes = { 11 } },
                { id = 39543, slot = "Hands", name = "Heroes' Dreamwalker Handguards", sources = { [3]=18946 }, classes = { 11 } },
                { id = 40466, slot = "Hands", name = "Valorous Dreamwalker Gloves", sources = { [4]=19449 }, classes = { 11 } },
                { id = 40472, slot = "Hands", name = "Valorous Dreamwalker Handgrips", sources = { [4]=19455 }, classes = { 11 } },
                { id = 40460, slot = "Hands", name = "Valorous Dreamwalker Handguards", sources = { [4]=19443 }, classes = { 11 } },
            },
            -- The drakes are size-split: the Black Drake drops on the
            -- 10-player difficulty, the Twilight Drake on the 25-player
            -- difficulty. Both require the three twilight drakes left
            -- alive for the kill.
            specialLoot = {
                { id = 43986, kind = "mount", name = "Reins of the Black Drake", size10Only = true },
                { id = 43954, kind = "mount", name = "Reins of the Twilight Drake", size25Only = true },
            },
        },
    },

    routing = {

        -- 1. Sartharion
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Sartharion",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 155 },
                    kind    = "path",
                    note    = "Proceed straight ahead to engage ^Sartharion^.",
                    minNote = "Straight ahead to Sartharion",
                    points  = {
                    },
                },
            },
        },
    },
}
