-------------------------------------------------------------------------------
-- RetroRuns Data -- Scholomance
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 1007  |  journalInstanceID: 246
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[246] = {
    kind              = "dungeon",
    instanceID        = 1007,
    journalInstanceID = 246,
    name              = "Scholomance",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    patch             = "5.0.4",

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Instructor Chillheart",
            journalEncounterID = 659,
            achievements       = {
            },
            loot = {
                { id = 88338, slot = "Chest", name = "Breastplate of Wracking Souls", sources = { [14]=45701 } },
                { id = 143967, slot = "Chest", name = "Breastplate of Wracking Souls", sources = { [14]=84302 } },
                { id = 88339, slot = "Two-Hand", name = "Gravetouch Greatsword", sources = { [14]=45702 } },
                { id = 144201, slot = "Two-Hand", name = "Gravetouch Greatsword", sources = { [14]=84469 } },
                { id = 88336, slot = "Waist", name = "Icewrath Belt", sources = { [14]=45699 } },
                { id = 144202, slot = "Waist", name = "Icewrath Belt", sources = { [14]=84470 } },
                { id = 88337, slot = "Wrist", name = "Shadow Puppet Bracers", sources = { [14]=45700 } },
                { id = 144200, slot = "Wrist", name = "Shadow Puppet Bracers", sources = { [14]=84468 } },
            },
        },
        {
            index              = 2,
            name               = "Jandice Barov",
            journalEncounterID = 663,
            achievements       = {
                { id = 6531, name = "Attention to Detail", meta = true },
            },
            loot = {
                { id = 88349, slot = "Back", name = "Phantasmal Drape", sources = { [14]=45712 } },
                { id = 144208, slot = "Back", name = "Phantasmal Drape", sources = { [14]=84476 } },
                { id = 88348, slot = "Feet", name = "Wraithplate Treads", sources = { [14]=45711 } },
                { id = 144013, slot = "Feet", name = "Wraithplate Treads", sources = { [14]=84348 } },
                { id = 88345, slot = "Head", name = "Barovian Ritual Hood", sources = { [14]=45708 } },
                { id = 144029, slot = "Head", name = "Barovian Ritual Hood", sources = { [14]=84364 } },
                { id = 88347, slot = "Legs", name = "Ghostwoven Legguards", sources = { [14]=45710 } },
                { id = 144012, slot = "Legs", name = "Ghostwoven Legguards", sources = { [14]=84347 } },
                { id = 88346, slot = "Off-hand", name = "Metanoia Shield", sources = { [14]=45709 } },
                { id = 144207, slot = "Off-hand", name = "Metanoia Shield", sources = { [14]=84475 } },
            },
        },
        {
            index              = 3,
            name               = "Rattlegore",
            journalEncounterID = 665,
            achievements       = {
                { id = 6394, name = "Rattle No More", meta = true },
            },
            loot = {
                { id = 88343, slot = "Feet", name = "Bone Golem Boots", sources = { [14]=45706 } },
                { id = 144011, slot = "Feet", name = "Bone Golem Boots", sources = { [14]=84346 } },
                { id = 88342, slot = "Hands", name = "Rattling Gloves", sources = { [14]=45705 } },
                { id = 144206, slot = "Hands", name = "Rattling Gloves", sources = { [14]=84474 } },
                { id = 88341, slot = "Ranged", name = "Necromantic Wand", sources = { [14]=45704 } },
                { id = 144205, slot = "Ranged", name = "Necromantic Wand", sources = { [14]=84473 } },
                { id = 88357, slot = "Shoulder", name = "Vigorsteel Spaulders", sources = { [14]=45718 } },
                { id = 144015, slot = "Shoulder", name = "Vigorsteel Spaulders", sources = { [14]=84350 } },
                { id = 88344, slot = "Two-Hand", name = "Goresoaked Headreaper", sources = { [14]=45707 } },
                { id = 144203, slot = "Two-Hand", name = "Goresoaked Headreaper", sources = { [14]=84471 } },
                { id = 88340, slot = "Wrist", name = "Deadwalker Bracers", sources = { [14]=45703 } },
                { id = 144204, slot = "Wrist", name = "Deadwalker Bracers", sources = { [14]=84472 } },
            },
        },
        {
            index              = 4,
            name               = "Lilian Voss",
            journalEncounterID = 666,
            achievements       = {
            },
            loot = {
                { id = 88352, slot = "Chest", name = "Shivbreaker Vest", sources = { [14]=45715 } },
                { id = 143968, slot = "Chest", name = "Shivbreaker Vest", sources = { [14]=84303 } },
                { id = 88353, slot = "Hands", name = "Dark Blaze Gauntlets", sources = { [14]=45716 } },
                { id = 144209, slot = "Hands", name = "Dark Blaze Gauntlets", sources = { [14]=84477 } },
                { id = 88351, slot = "Head", name = "Soulburner Crown", sources = { [14]=45714 } },
                { id = 144030, slot = "Head", name = "Soulburner Crown", sources = { [14]=84365 } },
                { id = 88350, slot = "Legs", name = "Leggings of Unleashed Anguish", sources = { [14]=45713 } },
                { id = 144014, slot = "Legs", name = "Leggings of Unleashed Anguish", sources = { [14]=84349 } },
            },
        },
        {
            index              = 5,
            name               = "Darkmaster Gandling",
            journalEncounterID = 684,
            achievements       = {
                { id = 645, name = "Scholomance" },
                { id = 6762, name = "Heroic: Scholomance" },
                { id = 6396, name = "Sanguinarian", meta = true },
                { id = 6821, name = "School's Out Forever", meta = true },
                { id = 6897, name = "Scholomance Challenger" },
                { id = 6914, name = "Scholomance: Bronze" },
                { id = 6915, name = "Scholomance: Silver" },
                { id = 6916, name = "Scholomance: Gold" },
            },
            loot = {
                { id = 88361, slot = "Hands", name = "Gloves of Explosive Pain", sources = { [14]=45720 } },
                { id = 144212, slot = "Hands", name = "Gloves of Explosive Pain", sources = { [14]=84480 } },
                { id = 88356, slot = "Hands", name = "Tombstone Gauntlets", sources = { [14]=45717 } },
                { id = 144210, slot = "Hands", name = "Tombstone Gauntlets", sources = { [14]=84478 } },
                { id = 88362, slot = "Shoulder", name = "Shoulderguards of Painful Lessons", sources = { [14]=45721 } },
                { id = 144016, slot = "Shoulder", name = "Shoulderguards of Painful Lessons", sources = { [14]=84351 } },
                { id = 144211, slot = "Two-Hand", name = "Headmaster's Will", sources = { [14]=84479 } },
                { id = 88359, slot = "Waist", name = "Incineration Belt", sources = { [14]=45719 } },
                { id = 144213, slot = "Waist", name = "Incineration Belt", sources = { [14]=84481 } },
            },
        },
    },
}
