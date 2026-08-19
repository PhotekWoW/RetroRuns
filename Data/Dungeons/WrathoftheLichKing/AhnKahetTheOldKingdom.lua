-------------------------------------------------------------------------------
-- RetroRuns Data -- Ahn'kahet: The Old Kingdom
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 619  |  journalInstanceID: 271
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[271] = {
    kind              = "dungeon",
    instanceID        = 619,
    journalInstanceID = 271,
    name              = "Ahn'kahet: The Old Kingdom",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.0.2",

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Elder Nadox",
            journalEncounterID = 580,
            achievements       = {
                { id = 2038, name = "Respect Your Elders", meta = true },
            },
            loot = {
                { id = 35607, slot = "Hands", name = "Ahn'kahar Handwraps", sources = { [14]=16542 } },
                { id = 37592, slot = "Head", name = "Brood Plague Helmet", sources = { [14]=17884 } },
                { id = 37594, slot = "Head", name = "Elder Headpiece", sources = { [14]=17886 } },
                { id = 37593, slot = "Shoulder", name = "Sprinting Shoulderpads", sources = { [14]=17885 } },
                { id = 35608, slot = "Waist", name = "Crawler-Emblem Belt", sources = { [14]=16543 } },
                { id = 35606, slot = "Weapon", name = "Blade of Nadox", sources = { [14]=16541 } },
                { id = 127616, slot = "Wrist", name = "Glowworm Cavern Bindings", sources = { [14]=72721 }, timewalkingOnly = true },
            },
        },
        {
            index              = 2,
            name               = "Prince Taldaram",
            journalEncounterID = 581,
            achievements       = {
            },
            loot = {
                { id = 37612, slot = "Chest", name = "Bonegrinder Breastplate", sources = { [14]=17893 } },
                { id = 37614, slot = "Hands", name = "Gauntlets of the Plundering Geist", sources = { [14]=17895 } },
                { id = 35611, slot = "Hands", name = "Gloves of the Blood Prince", sources = { [14]=16545 } },
                { id = 35609, slot = "Off-hand", name = "Talisman of Scourge Command", sources = { [14]=16544 } },
                { id = 37613, slot = "Wrist", name = "Flame Sphere Bindings", sources = { [14]=17894 } },
            },
        },
        {
            index              = 3,
            name               = "Jedoga Shadowseeker",
            journalEncounterID = 582,
            achievements       = {
                { id = 2056, name = "Volunteer Work", meta = true },
            },
            loot = {
                { id = 43278, slot = "Back", name = "Cloak of the Darkcaster", sources = { [14]=20940 } },
                { id = 43283, slot = "Back", name = "Subterranean Waterfall Shroud", sources = { [14]=20944 } },
                { id = 43279, slot = "Chest", name = "Battlechest of the Twilight Cult", sources = { [14]=20941 } },
                { id = 43280, slot = "Head", name = "Faceguard of the Hammer Clan", sources = { [14]=20942 } },
                { id = 43281, slot = "Two-Hand", name = "Edge of Oblivion", sources = { [14]=20943 } },
                { id = 44191, slot = "Two-Hand", name = "Ice-Rimed Chopper", sources = { [14]=21378 } },
            },
        },
        {
            index              = 4,
            name               = "Amanitar",
            journalEncounterID = 583,
            achievements       = {
            },
            loot = {
                { id = 43287, slot = "Hands", name = "Silken Bridge Handwraps", sources = { [14]=20947 } },
                { id = 127635, slot = "Hands", name = "Web Winder Gloves", sources = { [14]=72737 }, timewalkingOnly = true },
                { id = 43286, slot = "Legs", name = "Legguards of Swarming Attacks", sources = { [14]=20946 } },
                { id = 43284, slot = "Ranged", name = "Amanitar Skullbow", sources = { [14]=20945 } },
                { id = 127617, slot = "Shoulder", name = "Spored Tendrils Spaulders", sources = { [14]=72722 }, timewalkingOnly = true },
            },
        },
        {
            index              = 5,
            name               = "Herald Volazj",
            journalEncounterID = 584,
            achievements       = {
                { id = 1862, name = "Volazj's Quick Demise", meta = true },
                { id = 481, name = "Ahn'kahet: The Old Kingdom" },
                { id = 492, name = "Heroic: Ahn'kahet: The Old Kingdom" },
                { id = 39928, name = "Ahn'kahet: The Old Kingdom (char specific hidden copy)" },
            },
            loot = {
                { id = 37618, slot = "Feet", name = "Greaves of Ancient Evil", sources = { [14]=17899 } },
                { id = 35614, slot = "Feet", name = "Volazj's Sabatons", sources = { [14]=16548 } },
                { id = 37623, slot = "Hands", name = "Fiery Obelisk Handguards", sources = { [14]=17903 } },
                { id = 37616, slot = "Legs", name = "Kilt of the Forgotten One", sources = { [14]=17897 } },
                { id = 37622, slot = "Legs", name = "Skirt of the Old Kingdom", sources = { [14]=17902 } },
                { id = 37615, slot = "Ranged", name = "Titanium Compound Bow", sources = { [14]=17896 } },
                { id = 37619, slot = "Ranged", name = "Wand of Ahn'kahet", sources = { [14]=17900 } },
                { id = 35612, slot = "Shoulder", name = "Mantle of Echoing Bats", sources = { [14]=16546 } },
                { id = 37617, slot = "Two-Hand", name = "Staff of Sinister Claws", sources = { [14]=17898 } },
                { id = 35613, slot = "Waist", name = "Pyramid Embossed Belt", sources = { [14]=16547 } },
                { id = 37620, slot = "Wrist", name = "Bracers of the Herald", sources = { [14]=17901 } },
            },
        },
    },
}
