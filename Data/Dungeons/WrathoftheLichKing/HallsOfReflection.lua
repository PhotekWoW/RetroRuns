-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Reflection
-- Wrath of the Lich King dungeon, Patch 3.3.0  |  instanceID: 668  |  journalInstanceID: 276
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[276] = {
    kind              = "dungeon",
    instanceID        = 668,
    journalInstanceID = 276,
    name              = "Halls of Reflection",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.3.0",

    bosses = {
        {
            index              = 1,
            name               = "Falric",
            journalEncounterID = 601,
            achievements       = {
            },
            loot = {
                { id = 49832, slot = "Back", name = "Eerie Runeblade Polisher", sources = { [14]=24406 } },
                { id = 50294, slot = "Chest", name = "Chestpiece of High Treason", sources = { [14]=24672 } },
                { id = 49831, slot = "Feet", name = "Muddied Boots of Brill", sources = { [14]=24405 } },
                { id = 50295, slot = "Feet", name = "Spiked Toestompers", sources = { [14]=24673 } },
                { id = 49828, slot = "Hands", name = "Marwyn's Macabre Fingertips", sources = { [14]=24402 } },
                { id = 49830, slot = "Head", name = "Fallen Sentry's Hood", sources = { [14]=24404 } },
                { id = 50291, slot = "Ranged", name = "Soulsplinter", sources = { [14]=24669 } },
                { id = 50293, slot = "Shoulder", name = "Spaulders of Black Betrayal", sources = { [14]=24671 } },
                { id = 49829, slot = "Shoulder", name = "Valonforth's Tarnished Pauldrons", sources = { [14]=24403 } },
                { id = 50290, slot = "Weapon", name = "Falric's Wrist-Chopper", sources = { [14]=24668 } },
                { id = 49827, slot = "Weapon", name = "Ghoulslicer", sources = { [14]=24401 } },
                { id = 50292, slot = "Wrist", name = "Bracer of Worn Molars", sources = { [14]=24670 } },
            },
        },
        {
            index              = 2,
            name               = "Marwyn",
            journalEncounterID = 602,
            achievements       = {
            },
            loot = {
                { id = 50300, slot = "Chest", name = "Choking Hauberk", sources = { [14]=24678 } },
                { id = 50297, slot = "Chest", name = "Frostsworn Bone Chestpiece", sources = { [14]=24675 } },
                { id = 49838, slot = "Hands", name = "Carpal Tunnelers", sources = { [14]=24412 } },
                { id = 49837, slot = "Hands", name = "Mitts of Burning Hail", sources = { [14]=24411 } },
                { id = 50299, slot = "Hands", name = "Suspiciously Soft Gloves", sources = { [14]=24677 } },
                { id = 50298, slot = "Head", name = "Sightless Crown of Ulmaas", sources = { [14]=24676 } },
                { id = 49836, slot = "Legs", name = "Frostsworn Bone Leggings", sources = { [14]=24410 } },
                { id = 49835, slot = "Off-hand", name = "Splintered Door of the Citadel", sources = { [14]=24409 } },
                { id = 49834, slot = "Shoulder", name = "Frayed Abomination Stitching Shoulders", sources = { [14]=24408 } },
                { id = 50296, slot = "Two-Hand", name = "Orca-Hunter's Harpoon", sources = { [14]=24674 } },
                { id = 49833, slot = "Weapon", name = "Splintered Icecrown Parapet", sources = { [14]=24407 } },
            },
        },
        {
            index              = 3,
            name               = "Escape from Arthas",
            journalEncounterID = 603,
            achievements       = {
                { id = 4526, name = "We're Not Retreating; We're Advancing in a Different Direction." },
                { id = 4518, name = "The Halls of Reflection" },
                { id = 4521, name = "Heroic: The Halls of Reflection" },
            },
            loot = {
                { id = 49842, slot = "Back", name = "Tapestry of the Frozen Throne", sources = { [14]=24416 } },
                { id = 49841, slot = "Chest", name = "Blackened Geist Ribs", sources = { [14]=24415 } },
                { id = 50312, slot = "Chest", name = "Chestguard of Broken Branches", sources = { [14]=24686 } },
                { id = 50308, slot = "Feet", name = "Blighted Leather Footpads", sources = { [14]=24683 } },
                { id = 50305, slot = "Feet", name = "Grinning Skull Boots", sources = { [14]=24682 } },
                { id = 49843, slot = "Hands", name = "Crystalline Citadel Gauntlets", sources = { [14]=24417 } },
                { id = 50304, slot = "Hands", name = "Hoarfrost Gauntlets", sources = { [14]=24681 } },
                { id = 49851, slot = "Head", name = "Greathelm of the Silver Hand", sources = { [14]=24424 } },
                { id = 50311, slot = "Head", name = "Second Helm of the Executioner", sources = { [14]=24685 } },
                { id = 49849, slot = "Head", name = "Tattered Glacial-Woven Hood", sources = { [14]=24423 } },
                { id = 49847, slot = "Legs", name = "Legguards of Untimely Demise", sources = { [14]=24421 } },
                { id = 50309, slot = "Off-hand", name = "Shriveled Heart", sources = { [14]=24684 } },
                { id = 49844, slot = "Ranged", name = "Crypt Fiend Slayer", sources = { [14]=24418 } },
                { id = 49848, slot = "Shoulder", name = "Grim Lasher Shoulderguards", sources = { [14]=24422 } },
                { id = 49839, slot = "Two-Hand", name = "Mourning Malice", sources = { [14]=24413 } },
                { id = 50314, slot = "Waist", name = "Strip of Remorse", sources = { [14]=24687 } },
                { id = 50303, slot = "Weapon", name = "Black Icicle", sources = { [14]=24680 } },
                { id = 49845, slot = "Weapon", name = "Bone Golem Scapula", sources = { [14]=24419 } },
                { id = 49846, slot = "Weapon", name = "Chilled Heart of the Glacier", sources = { [14]=24420 } },
                { id = 49840, slot = "Weapon", name = "Hate-Forged Cleaver", sources = { [14]=24414 } },
                { id = 50302, slot = "Weapon", name = "Liar's Tongue", sources = { [14]=24679 } },
            },
        },
    },
}
