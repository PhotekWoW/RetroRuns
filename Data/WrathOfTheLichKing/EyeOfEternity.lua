-------------------------------------------------------------------------------
-- RetroRuns Data -- The Eye of Eternity
-- Wrath of the Lich King, Patch 3.0.2  |  instanceID: 616  |  journalInstanceID: 756
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[616] = {
    instanceID        = 616,
    journalInstanceID = 756,
    name              = "The Eye of Eternity",
    expansion         = "Wrath of the Lich King",
    patch             = "3.0.2",

    exitNote = "Click Exit Portal nearby",
    minExitNote = "Click Exit Portal Nearby",

    -- 10-player and 25-player are separate difficulties with their own
    -- loot tables, so each size keeps its own display bucket -- but the
    -- two sizes share one weekly lockout.
    difficultyModel   = "sizesShared",

    entrance = {
        -- Coldarra, on the Nexus.
        mapID = 114, x = 0.276, y = 0.267,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [141] = "The Eye of Eternity",
    },

    -- The Naxxramas-era glory pair spans Naxxramas, The Obsidian Sanctum,
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
            name               = "Malygos",
            journalEncounterID = 1617,
            achievements       = {
                { id = 1874, name = "You Don't Have an Eternity (10 player)", meta = true, soloable = "yes" },
                { id = 1875, name = "You Don't Have an Eternity (25 player)", meta = true, soloable = "yes" },
                { id = 1869, name = "A Poke in the Eye (10 player)", meta = true, soloable = "yes" },
                { id = 1870, name = "A Poke in the Eye (25 player)", meta = true, soloable = "yes" },
                { id = 2148, name = "Denyin' the Scion (10 player)", meta = true, soloable = "yes" },
                { id = 2149, name = "Denyin' the Scion (25 player)", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 40194, slot = "Chest", name = "Blanketing Robes of Snow", sources = { [4]=19238 } },
                { id = 40539, slot = "Chest", name = "Chestguard of the Recluse", sources = { [4]=19507 } },
                { id = 40526, slot = "Chest", name = "Gown of the Spell-Weaver", sources = { [3]=19499 } },
                { id = 40588, slot = "Chest", name = "Tunic of the Artifact Guardian", sources = { [4]=19551 } },
                { id = 40558, slot = "Feet", name = "Arcanic Tramplers", sources = { [4]=19525 } },
                { id = 40592, slot = "Feet", name = "Boots of Healing Energies", sources = { [4]=19555 } },
                { id = 40549, slot = "Feet", name = "Boots of the Renewed Flight", sources = { [4]=19517 } },
                { id = 40519, slot = "Feet", name = "Footsteps of Malygos", sources = { [3]=19492 } },
                { id = 40591, slot = "Feet", name = "Melancholy Sabatons", sources = { [4]=19554 } },
                { id = 40541, slot = "Hands", name = "Frosted Adroit Handguards", sources = { [4]=19509 } },
                { id = 40564, slot = "Hands", name = "Winter Spectacle Gloves", sources = { [4]=19531 } },
                { id = 40543, slot = "Head", name = "Blue Aspect Helm", sources = { [4]=19511 } },
                { id = 40562, slot = "Head", name = "Hood of Rationality", sources = { [4]=19529 } },
                { id = 40560, slot = "Legs", name = "Leggings of the Wanton Spellcaster", sources = { [4]=19527 } },
                { id = 40589, slot = "Legs", name = "Legplates of Sovereignty", sources = { [4]=19552 } },
                { id = 40475, slot = "Off-hand", name = "Barricade of Eternity", sources = { [3]=19457 } },
                { id = 40590, slot = "Shoulder", name = "Elevated Lair Pauldrons", sources = { [4]=19553 } },
                { id = 40511, slot = "Shoulder", name = "Focusing Energy Epaulets", sources = { [3]=19484 } },
                { id = 40555, slot = "Shoulder", name = "Mantle of Dissemination", sources = { [4]=19522 } },
                { id = 40594, slot = "Shoulder", name = "Spaulders of Catatonia", sources = { [4]=19556 } },
                { id = 40497, slot = "Two-Hand", name = "Black Ice", sources = { [3]=19471 } },
                { id = 40489, slot = "Two-Hand", name = "Greatstaff of the Nexus", sources = { [3]=19464 } },
                { id = 40561, slot = "Waist", name = "Leash of Heedless Magic", sources = { [4]=19528 } },
                { id = 40566, slot = "Waist", name = "Unravelling Strands of Sanity", sources = { [4]=19533 } },
                { id = 40491, slot = "Weapon", name = "Hailstorm", sources = { [3]=19466 } },
                { id = 40488, slot = "Weapon", name = "Ice Spire Scepter", sources = { [3]=19463 } },
            },
            -- Both drakes drop on the 10-player and the 25-player
            -- difficulty.
            specialLoot = {
                { id = 43952, kind = "mount", name = "Reins of the Azure Drake" },
                { id = 43953, kind = "mount", name = "Reins of the Blue Drake" },
            },
        },
    },

    routing = {

        -- 1. Malygos
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Malygos",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 141 },
                    kind    = "path",
                    note    = "After zoning in, click ^The Focusing Iris^ at the center of the platform to start the encounter with ^Malygos^.",
                    minNote = "Click Focusing Iris",
                    points  = {
                    },
                },
            },
        },
    },
}
