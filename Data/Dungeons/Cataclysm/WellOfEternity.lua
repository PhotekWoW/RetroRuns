-------------------------------------------------------------------------------
-- RetroRuns Data -- Well of Eternity
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.3.0  |  instanceID: 939  |  journalInstanceID: 185
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[185] = {
    kind              = "dungeon",
    instanceID        = 939,
    journalInstanceID = 185,
    name              = "Well of Eternity",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 15 },
    patch             = "4.3.0",

    entrance = {
        mapID = 75,
        x     = 0.2187,
        y     = 0.6415,
    },

    bosses = {
        {
            index              = 1,
            name               = "Peroth'arn",
            journalEncounterID = 290,
            dungeonEncounterID = 1272,
            achievements       = {
                { id = 6127, name = "Lazy Eye", soloable = "yes" },
            },
            loot = {
                { id = 72829, slot = "Off-hand", name = "Orb of the First Satyrs", sources = { [15]=37309 } },
                { id = 72832, slot = "Waist", name = "Girdle of the Queen's Champion", sources = { [15]=37311 } },
                { id = 72830, slot = "Waist", name = "Peroth'arn's Belt", sources = { [15]=37310 } },
                { id = 72827, slot = "Weapon", name = "Gavel of Peroth'arn", sources = { [15]=37307 } },
                { id = 72828, slot = "Weapon", name = "Trickster's Edge", sources = { [15]=37308 } },
            },
        },
        {
            index              = 2,
            name               = "Queen Azshara",
            journalEncounterID = 291,
            dungeonEncounterID = 1273,
            achievements       = {
            },
            loot = {
                { id = 72838, slot = "Back", name = "Cloak of the Royal Protector", sources = { [15]=37316 } },
                { id = 72834, slot = "Chest", name = "Breastplate of the Queen's Guard", sources = { [15]=37313 } },
                { id = 72836, slot = "Feet", name = "Slippers of Wizardry", sources = { [15]=37315 } },
                { id = 72835, slot = "Legs", name = "Puppeteer's Pantaloons", sources = { [15]=37314 } },
                { id = 72833, slot = "Weapon", name = "Scepter of Azshara", sources = { [15]=37312 } },
            },
        },
        {
            index              = 3,
            name               = "Mannoroth and Varo'then",
            journalEncounterID = 292,
            dungeonEncounterID = 1274,
            aliases            = { "Mannoroth" },
            achievements       = {
                { id = 6070, name = "That's Not Canon!", soloable = "yes" },
            },
            loot = {
                { id = 72841, slot = "Chest", name = "Demonsbane Chestguard", sources = { [15]=37319 } },
                { id = 72842, slot = "Head", name = "Annihilan Helm", sources = { [15]=37320 } },
                { id = 72839, slot = "Head", name = "Cowl of Highborne Sorcerers", sources = { [15]=37317 } },
                { id = 72843, slot = "Head", name = "Helm of Power", sources = { [15]=37321 } },
                { id = 72847, slot = "Head", name = "Helm of Thorns", sources = { [15]=37324 } },
                { id = 72848, slot = "Legs", name = "Legguards of the Legion", sources = { [15]=37325 } },
                { id = 72840, slot = "Shoulder", name = "Spaulders of Eternity", sources = { [15]=37318 } },
                { id = 72844, slot = "Two-Hand", name = "Pit Lord's Destroyer", sources = { [15]=37322 } },
                { id = 72846, slot = "Two-Hand", name = "Thornwood Staff", sources = { [15]=37323 } },
            },
        },
    },
}
