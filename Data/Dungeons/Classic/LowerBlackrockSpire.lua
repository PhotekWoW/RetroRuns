-------------------------------------------------------------------------------
-- RetroRuns Data -- Lower Blackrock Spire
-- Classic dungeon, Patch 1.0  |  instanceID: 229  |  journalInstanceID: 229
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[229] = {
    kind              = "dungeon",
    instanceID        = 229,
    journalInstanceID = 229,
    name              = "Lower Blackrock Spire",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Highlord Omokk",
            journalEncounterID = 388,
            achievements       = {
            },
            loot = {
                { id = 13168, slot = "Chest", name = "Plate of the Shaman King", sources = { [14]=4780 } },
                { id = 151412, slot = "Head", name = "Ogre Highlord's Casque", sources = { [14]=89417 } },
                { id = 13170, slot = "Legs", name = "Skyshroud Leggings", sources = { [14]=4782 } },
                { id = 13169, slot = "Legs", name = "Tressermane Leggings", sources = { [14]=4781 } },
                { id = 13166, slot = "Shoulder", name = "Slamshot Shoulders", sources = { [14]=4778 } },
                { id = 13167, slot = "Two-Hand", name = "Fist of Omokk", sources = { [14]=4779 } },
            },
        },
        {
            index              = 2,
            name               = "Shadow Hunter Vosh'gajin",
            journalEncounterID = 389,
            achievements       = {
            },
            loot = {
                { id = 13255, slot = "Hands", name = "Trueaim Gauntlets", sources = { [14]=4814 } },
                { id = 12651, slot = "Ranged", name = "Blackcrow", sources = { [14]=4508 } },
                { id = 12653, slot = "Ranged", name = "Riphook", sources = { [14]=4509 } },
                { id = 13257, slot = "Shoulder", name = "Demonic Runed Spaulders", sources = { [14]=4815 } },
                { id = 151413, slot = "Waist", name = "Smolderthorn Greatbelt", sources = { [14]=89418 } },
                { id = 12626, slot = "Wrist", name = "Funeral Cuffs", sources = { [14]=4496 } },
            },
        },
        {
            index              = 3,
            name               = "War Master Voone",
            journalEncounterID = 390,
            achievements       = {
            },
            loot = {
                { id = 22231, slot = "Feet", name = "Kayser's Boots of Precision", sources = { [14]=8748 } },
                { id = 13175, slot = "Ranged", name = "Voone's Twitchbow", sources = { [14]=4783 } },
                { id = 12582, slot = "Weapon", name = "Keris of Zul'Serak", sources = { [14]=4465 } },
                { id = 13179, slot = "Wrist", name = "Brazecore Armguards", sources = { [14]=4784 } },
            },
        },
        {
            index              = 4,
            name               = "Mother Smolderweb",
            journalEncounterID = 391,
            achievements       = {
            },
            loot = {
                { id = 13244, slot = "Hands", name = "Gilded Gauntlets", sources = { [14]=4806 } },
                { id = 13183, slot = "Weapon", name = "Venomspitter", sources = { [14]=4787 } },
            },
            specialLoot = {
                { id = 68673, kind = "pet", name = "Smolderweb Egg" },
            },
        },
        {
            index              = 5,
            name               = "Urok Doomhowl",
            journalEncounterID = 392,
            achievements       = {
            },
            loot = {
                { id = 13259, slot = "Feet", name = "Ribsteel Footguards", sources = { [14]=4817 } },
                { id = 13258, slot = "Hands", name = "Slaghide Gauntlets", sources = { [14]=4816 } },
                { id = 22232, slot = "Waist", name = "Marksman's Girdle", sources = { [14]=8749 } },
            },
        },
        {
            index              = 6,
            name               = "Quartermaster Zigris",
            journalEncounterID = 393,
            achievements       = {
            },
            loot = {
                { id = 151415, slot = "Feet", name = "Veteran Spearman's Chain Boots", sources = { [14]=89420 } },
                { id = 13253, slot = "Hands", name = "Hands of Power", sources = { [14]=4812 } },
                { id = 151416, slot = "Legs", name = "Dark Horde Grunt's Legplates", sources = { [14]=89421 } },
                { id = 13252, slot = "Waist", name = "Cloudrunner Girdle", sources = { [14]=4811 } },
            },
            specialLoot = {
                { id = 12264, kind = "pet", name = "Worg Carrier" },
            },
        },
        {
            index              = 7,
            name               = "Halycon",
            journalEncounterID = 394,
            achievements       = {
            },
            loot = {
                { id = 13210, slot = "Feet", name = "Pads of the Dread Wolf", sources = { [14]=4797 } },
                { id = 22313, slot = "Wrist", name = "Ironweave Bracers", sources = { [14]=8782 } },
                { id = 13211, slot = "Wrist", name = "Slashclaw Bracers", sources = { [14]=4798 } },
            },
        },
        {
            index              = 8,
            name               = "Gizrul the Slavener",
            journalEncounterID = 395,
            achievements       = {
            },
            loot = {
                { id = 151418, slot = "Head", name = "Raider Aspirant's Helm", sources = { [14]=89423 } },
                { id = 13206, slot = "Legs", name = "Wolfshear Leggings", sources = { [14]=4795 } },
                { id = 13205, slot = "Off-hand", name = "Rhombeard Protector", sources = { [14]=4794 } },
                { id = 151417, slot = "Shoulder", name = "Worg-Keeper's Spaulders", sources = { [14]=89422 } },
                { id = 13208, slot = "Wrist", name = "Bleak Howler Armguards", sources = { [14]=4796 } },
            },
        },
        {
            index              = 9,
            name               = "Overlord Wyrmthalak",
            journalEncounterID = 396,
            achievements       = {
                { id = 643, name = "Lower Blackrock Spire" },
                { id = 2188, name = "Leeeeeeeeeeeeeroy!" },
            },
            loot = {
                { id = 13162, slot = "Hands", name = "Reiver Claws", sources = { [14]=4775 } },
                { id = 13148, slot = "Two-Hand", name = "Chillpike", sources = { [14]=4771 } },
                { id = 13163, slot = "Two-Hand", name = "Relentless Scythe", sources = { [14]=4776 } },
                { id = 13161, slot = "Two-Hand", name = "Trindlehaven Staff", sources = { [14]=4774 } },
            },
        },
    },
}
