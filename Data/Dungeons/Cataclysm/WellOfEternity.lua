-------------------------------------------------------------------------------
-- RetroRuns Data -- Well of Eternity
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
    patch             = "4.3.0",

    bosses = {
        {
            index              = 1,
            name               = "Peroth'arn",
            journalEncounterID = 290,
            achievements       = {
                { id = 6127, name = "Lazy Eye" },
            },
            loot = {
                { id = 72829, slot = "Off-hand", name = "Orb of the First Satyrs", sources = { [14]=37309 } },
                { id = 72832, slot = "Waist", name = "Girdle of the Queen's Champion", sources = { [14]=37311 } },
                { id = 72830, slot = "Waist", name = "Peroth'arn's Belt", sources = { [14]=37310 } },
                { id = 72827, slot = "Weapon", name = "Gavel of Peroth'arn", sources = { [14]=37307 } },
                { id = 72828, slot = "Weapon", name = "Trickster's Edge", sources = { [14]=37308 } },
            },
        },
        {
            index              = 2,
            name               = "Queen Azshara",
            journalEncounterID = 291,
            achievements       = {
            },
            loot = {
                { id = 72838, slot = "Back", name = "Cloak of the Royal Protector", sources = { [14]=37316 } },
                { id = 72834, slot = "Chest", name = "Breastplate of the Queen's Guard", sources = { [14]=37313 } },
                { id = 72836, slot = "Feet", name = "Slippers of Wizardry", sources = { [14]=37315 } },
                { id = 72835, slot = "Legs", name = "Puppeteer's Pantaloons", sources = { [14]=37314 } },
                { id = 72833, slot = "Weapon", name = "Scepter of Azshara", sources = { [14]=37312 } },
            },
        },
        {
            index              = 3,
            name               = "Mannoroth and Varo'then",
            journalEncounterID = 292,
            achievements       = {
                { id = 6070, name = "That's Not Canon!" },
                { id = 6118, name = "Heroic: Well of Eternity" },
            },
            loot = {
                { id = 72841, slot = "Chest", name = "Demonsbane Chestguard", sources = { [14]=37319 } },
                { id = 72842, slot = "Head", name = "Annihilan Helm", sources = { [14]=37320 } },
                { id = 72839, slot = "Head", name = "Cowl of Highborne Sorcerers", sources = { [14]=37317 } },
                { id = 72843, slot = "Head", name = "Helm of Power", sources = { [14]=37321 } },
                { id = 72847, slot = "Head", name = "Helm of Thorns", sources = { [14]=37324 } },
                { id = 72848, slot = "Legs", name = "Legguards of the Legion", sources = { [14]=37325 } },
                { id = 72840, slot = "Shoulder", name = "Spaulders of Eternity", sources = { [14]=37318 } },
                { id = 72844, slot = "Two-Hand", name = "Pit Lord's Destroyer", sources = { [14]=37322 } },
                { id = 72846, slot = "Two-Hand", name = "Thornwood Staff", sources = { [14]=37323 } },
            },
        },
    },
}
