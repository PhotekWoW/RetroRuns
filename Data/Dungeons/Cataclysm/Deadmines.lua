-------------------------------------------------------------------------------
-- RetroRuns Data -- Deadmines
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 36  |  journalInstanceID: 63
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[63] = {
    kind              = "dungeon",
    instanceID        = 36,
    journalInstanceID = 63,
    name              = "Deadmines",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    patch             = "4.0.3",

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Glubtok",
            journalEncounterID = 89,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5366, name = "Ready for Raiding", meta = true },
            },
            loot = {
                { id = 5444, slot = "Back", name = "Miner's Cape", sources = { [14]=2104 } },
                { id = 63467, slot = "Back", name = "Shadow of the Past", sources = { [14]=31827 } },
                { id = 63468, slot = "Chest", name = "Defias Brotherhood Vest", sources = { [14]=31828 } },
                { id = 63471, slot = "Chest", name = "Vest of the Curious Visitor", sources = { [14]=31830 } },
                { id = 5195, slot = "Hands", name = "Gold-Flecked Gloves", sources = { [14]=1987 } },
                { id = 157628, slot = "Hands", name = "Gold-Flecked Gloves", sources = { [14]=93814 } },
                { id = 63470, slot = "Shoulder", name = "Missing Diplomat's Pauldrons", sources = { [14]=31829 } },
                { id = 2169, slot = "Weapon", name = "Buzzer Blade", sources = { [14]=642 } },
                { id = 65163, slot = "Weapon", name = "Buzzer Blade", sources = { [14]=32727 } },
            },
        },
        {
            index              = 2,
            name               = "Rhahk'Zor",
            journalEncounterID = 2613,
            achievements       = {
            },
            loot = {
                { id = 224733, slot = "Feet", name = "Watchman's Boots", sources = { [14]=220566 }, timewalkingOnly = true },
                { id = 224734, slot = "Shoulder", name = "Defias Spiked Pauldrons", sources = { [14]=220567 }, timewalkingOnly = true },
                { id = 224731, slot = "Waist", name = "Ogre-Sized Belt", sources = { [14]=220564 }, timewalkingOnly = true },
                { id = 224732, slot = "Wrist", name = "Foreman's Handwraps", sources = { [14]=220565 }, timewalkingOnly = true },
            },
        },
        {
            index              = 3,
            name               = "Sneed",
            journalEncounterID = 2626,
            achievements       = {
            },
            loot = {
                { id = 224737, slot = "Feet", name = "Goblin Treekickers", sources = { [14]=220569 }, timewalkingOnly = true },
                { id = 224739, slot = "Shoulder", name = "Lumbermaster's Mantle", sources = { [14]=220571 }, timewalkingOnly = true },
                { id = 5194, slot = "Two-Hand", name = "Taskmaster Axe", sources = { [14]=1986 }, timewalkingOnly = true },
                { id = 224736, slot = "Weapon", name = "Shredder Teeth", sources = { [14]=220568 }, timewalkingOnly = true },
                { id = 224738, slot = "Wrist", name = "Logger's Wristguards", sources = { [14]=220570 }, timewalkingOnly = true },
            },
        },
        {
            index              = 4,
            name               = "Gilnid",
            journalEncounterID = 2628,
            achievements       = {
            },
            loot = {
                { id = 224740, slot = "Head", name = "Forgemasters's Faceshield", sources = { [14]=220572 }, timewalkingOnly = true },
                { id = 224741, slot = "Weapon", name = "Defias Scimitar", sources = { [14]=220573 }, timewalkingOnly = true },
            },
        },
        {
            index              = 5,
            name               = "Mr. Smite",
            journalEncounterID = 2629,
            achievements       = {
            },
            loot = {
                { id = 224744, slot = "Chest", name = "Defias Cuirass", sources = { [14]=220576 }, timewalkingOnly = true },
                { id = 224745, slot = "Feet", name = "Blackguard Slippers", sources = { [14]=220577 }, timewalkingOnly = true },
                { id = 224746, slot = "Hands", name = "Thief's Gloves", sources = { [14]=220578 }, timewalkingOnly = true },
                { id = 224742, slot = "Ranged", name = "Smite's Pistol", sources = { [14]=220574 }, timewalkingOnly = true },
                { id = 7230, slot = "Two-Hand", name = "Smite's Mighty Hammer", sources = { [14]=2729 }, timewalkingOnly = true },
                { id = 224747, slot = "Weapon", name = "Buccaneer's Bludgeon", sources = { [14]=220579 }, timewalkingOnly = true },
            },
        },
        {
            index              = 6,
            name               = "Captain Greenskin",
            journalEncounterID = 2630,
            achievements       = {
            },
            loot = {
                { id = 224749, slot = "Feet", name = "Goblin Griptreads", sources = { [14]=220581 }, timewalkingOnly = true },
                { id = 224748, slot = "Head", name = "Captain's Tricorne", sources = { [14]=220580 }, timewalkingOnly = true },
                { id = 10403, slot = "Waist", name = "Blackened Defias Belt", sources = { [14]=3955 }, timewalkingOnly = true },
                { id = 224753, slot = "Waist", name = "Pirate Captain's Girdle", sources = { [14]=220582 }, timewalkingOnly = true },
            },
        },
        {
            index              = 7,
            name               = "Edwin VanCleef",
            journalEncounterID = 2631,
            achievements       = {
            },
            loot = {
                { id = 10399, slot = "Chest", name = "Blackened Defias Armor", sources = { [14]=3951 }, timewalkingOnly = true },
                { id = 224754, slot = "Legs", name = "Guildmaster's Leggings", sources = { [14]=220583 }, timewalkingOnly = true },
                { id = 224755, slot = "Wrist", name = "Defias Knifeguards", sources = { [14]=220584 }, timewalkingOnly = true },
            },
        },
        {
            index              = 8,
            name               = "Cookie",
            journalEncounterID = 2632,
            achievements       = {
                { id = 628, name = "Deadmines" },
                { id = 5370, name = "I'm on a Diet", meta = true },
            },
            loot = {
                { id = 224757, slot = "Hands", name = "Master Chef's Gloves", sources = { [14]=220586 }, timewalkingOnly = true },
                { id = 224758, slot = "Head", name = "Stolen Stormwind Helmet", sources = { [14]=220587 }, timewalkingOnly = true },
                { id = 224756, slot = "Off-hand", name = "Cookie's Special Flavors", sources = { [14]=220585 }, timewalkingOnly = true },
                { id = 224759, slot = "Wrist", name = "Pirate's Bracers", sources = { [14]=220588 }, timewalkingOnly = true },
            },
        },
        {
            index              = 9,
            name               = "Helix Gearbreaker",
            journalEncounterID = 90,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5367, name = "Rat Pack", meta = true },
            },
            loot = {
                { id = 63473, slot = "Back", name = "Cloak of Thredd", sources = { [14]=31832 } },
                { id = 63474, slot = "Hands", name = "Gear-Marked Gauntlets", sources = { [14]=31833 } },
                { id = 151063, slot = "Hands", name = "Gear-Marked Gauntlets", sources = { [14]=89249 } },
                { id = 63475, slot = "Hands", name = "Old Friend's Gloves", sources = { [14]=31834 } },
                { id = 132556, slot = "Legs", name = "Smelter's Britches", sources = { [14]=76391 } },
                { id = 5199, slot = "Legs", name = "Smelting Pants", sources = { [14]=1991 } },
                { id = 5443, slot = "Off-hand", name = "Gold-Plated Buckler", sources = { [14]=2103 } },
                { id = 5200, slot = "Two-Hand", name = "Impaling Harpoon", sources = { [14]=1992 } },
                { id = 5191, slot = "Weapon", name = "Cruel Barb", sources = { [14]=1983 } },
                { id = 65164, slot = "Weapon", name = "Cruel Barb", sources = { [14]=32728 } },
                { id = 151062, slot = "Wrist", name = "Armbands of Exiled Architects", sources = { [14]=89248 } },
                { id = 157752, slot = "Wrist", name = "Armbands of Exiled Architects", sources = { [14]=93933 } },
                { id = 63476, slot = "Wrist", name = "Gearbreaker's Bindings", sources = { [14]=31835 } },
            },
        },
        {
            index              = 10,
            name               = "Foe Reaper 5000",
            journalEncounterID = 91,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5368, name = "Prototype Prodigy", meta = true },
            },
            loot = {
                { id = 151064, slot = "Chest", name = "Vest of the Curious Visitor", sources = { [14]=89250 } },
                { id = 157753, slot = "Chest", name = "Vest of the Curious Visitor", sources = { [14]=93934 } },
                { id = 151065, slot = "Hands", name = "Old Friend's Gloves", sources = { [14]=89251 } },
                { id = 157754, slot = "Hands", name = "Old Friend's Gloves", sources = { [14]=93935 } },
                { id = 151066, slot = "Shoulder", name = "Missing Diplomat's Pauldrons", sources = { [14]=89252 } },
                { id = 157755, slot = "Shoulder", name = "Missing Diplomat's Pauldrons", sources = { [14]=93936 } },
                { id = 5201, slot = "Two-Hand", name = "Emberstone Staff", sources = { [14]=1993 } },
                { id = 65167, slot = "Two-Hand", name = "Emberstone Staff", sources = { [14]=32731 } },
                { id = 5187, slot = "Two-Hand", name = "Foe Reaper", sources = { [14]=1982 } },
                { id = 65165, slot = "Two-Hand", name = "Foe Reaper", sources = { [14]=32729 } },
                { id = 1937, slot = "Weapon", name = "Buzz Saw", sources = { [14]=502 } },
                { id = 65166, slot = "Weapon", name = "Buzz Saw", sources = { [14]=32730 } },
            },
        },
        {
            index              = 11,
            name               = "Admiral Ripsnarl",
            journalEncounterID = 92,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5369, name = "It's Frost Damage", meta = true },
            },
            loot = {
                { id = 872, slot = "Two-Hand", name = "Rockslicer", sources = { [14]=136 } },
                { id = 65168, slot = "Two-Hand", name = "Rockslicer", sources = { [14]=32732 } },
                { id = 5196, slot = "Weapon", name = "Smite's Reaver", sources = { [14]=1988 } },
                { id = 65170, slot = "Weapon", name = "Smite's Reaver", sources = { [14]=32733 } },
            },
        },
        {
            index              = 12,
            name               = "\"Captain\" Cookie",
            journalEncounterID = 93,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
            },
            loot = {
                { id = 5193, slot = "Back", name = "Cape of the Brotherhood", sources = { [14]=1985 } },
                { id = 65177, slot = "Back", name = "Cape of the Brotherhood", sources = { [14]=32738 } },
                { id = 5202, slot = "Chest", name = "Corsair's Overshirt", sources = { [14]=1994 } },
                { id = 65174, slot = "Chest", name = "Corsair's Overshirt", sources = { [14]=32737 } },
                { id = 5198, slot = "Ranged", name = "Cookie's Stirring Rod", sources = { [14]=1990 } },
                { id = 65172, slot = "Ranged", name = "Cookie's Stirring Rod", sources = { [14]=32735 } },
                { id = 5197, slot = "Weapon", name = "Cookie's Tenderizer", sources = { [14]=1989 } },
                { id = 65171, slot = "Weapon", name = "Cookie's Tenderizer", sources = { [14]=32734 } },
                { id = 5192, slot = "Weapon", name = "Thief's Blade", sources = { [14]=1984 } },
                { id = 65173, slot = "Weapon", name = "Thief's Blade", sources = { [14]=32736 } },
            },
            specialLoot = {
                { id = 248332, kind = "decor", name = "Stormwind Footlocker", decorID = 4401 },
            },
        },
        {
            index              = 13,
            name               = "Vanessa VanCleef",
            journalEncounterID = 95,
            achievements       = {
                { id = 5083, name = "Heroic: Deadmines" },
                { id = 5371, name = "Vigorous VanCleef Vindicator", meta = true },
            },
            loot = {
                { id = 63483, slot = "Feet", name = "Guildmaster's Greaves", sources = { [14]=31840 } },
                { id = 65178, slot = "Feet", name = "VanCleef's Boots", sources = { [14]=32739 } },
                { id = 63482, slot = "Hands", name = "Daughter's Hands", sources = { [14]=31839 } },
                { id = 63485, slot = "Head", name = "Cowl of Rebellion", sources = { [14]=31842 } },
                { id = 63478, slot = "Head", name = "Stonemason's Helm", sources = { [14]=31837 } },
                { id = 63484, slot = "Wrist", name = "Armbands of Exiled Architects", sources = { [14]=31841 } },
                { id = 63479, slot = "Wrist", name = "Bracers of Some Consequence", sources = { [14]=31838 } },
                { id = 63486, slot = "Wrist", name = "Shackles of the Betrayed", sources = { [14]=31843 } },
            },
            specialLoot = {
                { id = 248332, kind = "decor", name = "Stormwind Footlocker", decorID = 4401 },
            },
        },
    },
}
