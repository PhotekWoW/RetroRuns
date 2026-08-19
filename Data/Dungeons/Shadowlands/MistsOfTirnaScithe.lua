-------------------------------------------------------------------------------
-- RetroRuns Data -- Mists of Tirna Scithe
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2290  |  journalInstanceID: 1184
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1184] = {
    kind              = "dungeon",
    instanceID        = 2290,
    journalInstanceID = 1184,
    name              = "Mists of Tirna Scithe",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    patch             = "9.0.1",

    gloryMeta = {
        id   = 14322,
        name = "Glory of the Shadowlands Hero",
        rewardItemID       = 184183,
        rewardMountSpellID = 344659,
        rewardName         = "Voracious Gorger",
    },

    bosses = {
        {
            index              = 1,
            name               = "Ingra Maloch",
            journalEncounterID = 2400,
            achievements       = {
                { id = 14503, name = "Hooked On Hydroponics", meta = true },
            },
            loot = {
                { id = 178698, slot = "Chest", name = "Rainshadow Hauberk", sources = { [14]=111580 } },
                { id = 178692, slot = "Head", name = "Soulthorn Visage", sources = { [14]=111443 } },
                { id = 178694, slot = "Head", name = "Wrathbark Greathelm", sources = { [14]=111447 } },
                { id = 178696, slot = "Shoulder", name = "Ingra Maloch's Mantle", sources = { [14]=111440 } },
                { id = 178708, slot = "Trinket", name = "Unbound Changeling", sources = { [14]=112936 } },
                { id = 178713, slot = "Two-Hand", name = "Drustlord's Greataxe", sources = { [14]=111452 } },
                { id = 178700, slot = "Waist", name = "Clasp of Waning Shadow", sources = { [14]=111445 } },
                { id = 178709, slot = "Weapon", name = "Scithewood Scepter", sources = { [14]=112853 } },
                { id = 178704, slot = "Wrist", name = "Deathshackle Wristwraps", sources = { [14]=111441 } },
            },
        },
        {
            index              = 2,
            name               = "Mistcaller",
            journalEncounterID = 2402,
            achievements       = {
                { id = 14291, name = "Someone Could Trip on These!", meta = true },
            },
            loot = {
                { id = 178706, slot = "Hands", name = "Fogweaver Gauntlets", sources = { [14]=111450 } },
                { id = 178705, slot = "Hands", name = "Tricksprite Gloves", sources = { [14]=111442 } },
                { id = 182305, slot = "Head", name = "Crown of Autumnal Flora", sources = { [14]=114079 } },
                { id = 178691, slot = "Head", name = "Hood of the Hidden Path", sources = { [14]=111579 } },
                { id = 178697, slot = "Shoulder", name = "Prankster's Pauldrons", sources = { [14]=111448 } },
                { id = 178695, slot = "Shoulder", name = "Wintersnap Shoulderguards", sources = { [14]=111444 } },
                { id = 178710, slot = "Weapon", name = "Tanglewood Thorn", sources = { [14]=111453 } },
            },
        },
        {
            index              = 3,
            name               = "Tred'ova",
            journalEncounterID = 2405,
            achievements       = {
                { id = 14371, name = "Mists of Tirna Scithe" },
                { id = 14375, name = "Hunger for Knowledge", meta = true },
                { id = 14412, name = "Heroic: Mists of Tirna Scithe" },
                { id = 14413, name = "Mythic: Mists of Tirna Scithe" },
            },
            loot = {
                { id = 178693, slot = "Head", name = "Cocoonsilk Cowl", sources = { [14]=111439 } },
                { id = 178701, slot = "Legs", name = "Gormshell Greaves", sources = { [14]=111449 } },
                { id = 178712, slot = "Off-hand", name = "Acidslough Bulwark", sources = { [14]=111455 } },
                { id = 178714, slot = "Two-Hand", name = "Lakali's Spire of Knowledge", sources = { [14]=111454 } },
                { id = 178699, slot = "Waist", name = "Sapgorger Belt", sources = { [14]=111581 } },
                { id = 178711, slot = "Weapon", name = "Axe of the Deadgrove", sources = { [14]=111451 } },
                { id = 178702, slot = "Wrist", name = "Bands of the Undergrowth", sources = { [14]=111582 } },
                { id = 178703, slot = "Wrist", name = "Hiveswarm Bracers", sources = { [14]=111446 } },
            },
            specialLoot = {
                { id = 183623, kind = "pet", name = "Spinemaw Gormling" },
            },
        },
    },
}
