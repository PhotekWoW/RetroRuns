-------------------------------------------------------------------------------
-- RetroRuns Data -- Deadmines
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
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
    availableDifficulties = { 14, 15 },
    patch             = "4.0.3",
    timewalking       = true,

    entrance = {
        mapID = 52,
        x     = 0.3820,
        y     = 0.7748,
    },

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
            dungeonEncounterID = 2976,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5366, name = "Ready for Raiding", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 5444, slot = "Back", name = "Miner's Cape", sources = { [14]=2104 } },
                { id = 63467, slot = "Back", name = "Shadow of the Past", sources = { [15]=31827 } },
                { id = 63468, slot = "Chest", name = "Defias Brotherhood Vest", sources = { [15]=31828 } },
                { id = 63471, slot = "Chest", name = "Vest of the Curious Visitor", sources = { [15]=31830 } },
                { id = 5195, slot = "Hands", name = "Gold-Flecked Gloves", sources = { [14]=1987, [15]=93814 } },
                { id = 63470, slot = "Shoulder", name = "Missing Diplomat's Pauldrons", sources = { [15]=31829 } },
                { id = 2169, slot = "Weapon", name = "Buzzer Blade", sources = { [14]=642, [15]=32727 } },
            },
        },
        {
            index              = 2,
            name               = "Helix Gearbreaker",
            journalEncounterID = 90,
            dungeonEncounterID = 2977,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5367, name = "Rat Pack", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63473, slot = "Back", name = "Cloak of Thredd", sources = { [15]=31832 } },
                { id = 151063, slot = "Hands", name = "Gear-Marked Gauntlets", sources = { [14]=89249, [15]=31833 } },
                { id = 63475, slot = "Hands", name = "Old Friend's Gloves", sources = { [15]=31834 } },
                { id = 132556, slot = "Legs", name = "Smelter's Britches", sources = { [14]=76391 } },
                { id = 5199, slot = "Legs", name = "Smelting Pants", sources = { [14]=1991 } },
                { id = 5443, slot = "Off-hand", name = "Gold-Plated Buckler", sources = { [14]=2103 } },
                { id = 5200, slot = "Two-Hand", name = "Impaling Harpoon", sources = { [14]=1992 } },
                { id = 5191, slot = "Weapon", name = "Cruel Barb", sources = { [14]=1983, [15]=32728 } },
                { id = 151062, slot = "Wrist", name = "Armbands of Exiled Architects", sources = { [14]=89248, [15]=93933 } },
                { id = 63476, slot = "Wrist", name = "Gearbreaker's Bindings", sources = { [15]=31835 } },
            },
        },
        {
            index              = 3,
            name               = "Foe Reaper 5000",
            journalEncounterID = 91,
            dungeonEncounterID = 2975,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5368, name = "Prototype Prodigy", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 151064, slot = "Chest", name = "Vest of the Curious Visitor", sources = { [14]=89250, [15]=93934 } },
                { id = 151065, slot = "Hands", name = "Old Friend's Gloves", sources = { [14]=89251, [15]=93935 } },
                { id = 151066, slot = "Shoulder", name = "Missing Diplomat's Pauldrons", sources = { [14]=89252, [15]=93936 } },
                { id = 5201, slot = "Two-Hand", name = "Emberstone Staff", sources = { [14]=1993, [15]=32731 } },
                { id = 5187, slot = "Two-Hand", name = "Foe Reaper", sources = { [14]=1982, [15]=32729 } },
                { id = 1937, slot = "Weapon", name = "Buzz Saw", sources = { [14]=502, [15]=32730 } },
            },
        },
        {
            index              = 4,
            name               = "Admiral Ripsnarl",
            journalEncounterID = 92,
            dungeonEncounterID = 2974,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5369, name = "It's Frost Damage", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 872, slot = "Two-Hand", name = "Rockslicer", sources = { [14]=136, [15]=32732 } },
                { id = 5196, slot = "Weapon", name = "Smite's Reaver", sources = { [14]=1988, [15]=32733 } },
            },
        },
        {
            index              = 5,
            name               = "\"Captain\" Cookie",
            journalEncounterID = 93,
            dungeonEncounterID = 2973,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5370, name = "I'm on a Diet", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 5193, slot = "Back", name = "Cape of the Brotherhood", sources = { [14]=1985, [15]=32738 } },
                { id = 5202, slot = "Chest", name = "Corsair's Overshirt", sources = { [14]=1994, [15]=32737 } },
                { id = 5198, slot = "Ranged", name = "Cookie's Stirring Rod", sources = { [14]=1990, [15]=32735 } },
                { id = 5197, slot = "Weapon", name = "Cookie's Tenderizer", sources = { [14]=1989, [15]=32734 } },
                { id = 5192, slot = "Weapon", name = "Thief's Blade", sources = { [14]=1984, [15]=32736 } },
            },
            specialLoot = {
                { id = 248332, kind = "decor", name = "Stormwind Footlocker", decorID = 4401 },
            },
        },
        {
            index              = 6,
            name               = "Vanessa VanCleef",
            journalEncounterID = 95,
            dungeonEncounterID = 1081,
            availableDifficulties = { 15 },
            achievements       = {
                { id = 5371, name = "Vigorous VanCleef Vindicator", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63483, slot = "Feet", name = "Guildmaster's Greaves", sources = { [15]=31840 } },
                { id = 65178, slot = "Feet", name = "VanCleef's Boots", sources = { [15]=32739 } },
                { id = 63482, slot = "Hands", name = "Daughter's Hands", sources = { [15]=31839 } },
                { id = 63485, slot = "Head", name = "Cowl of Rebellion", sources = { [15]=31842 } },
                { id = 63478, slot = "Head", name = "Stonemason's Helm", sources = { [15]=31837 } },
                { id = 63484, slot = "Wrist", name = "Armbands of Exiled Architects", sources = { [15]=31841 } },
                { id = 63479, slot = "Wrist", name = "Bracers of Some Consequence", sources = { [15]=31838 } },
                { id = 63486, slot = "Wrist", name = "Shackles of the Betrayed", sources = { [15]=31843 } },
            },
            specialLoot = {
                { id = 248332, kind = "decor", name = "Stormwind Footlocker", decorID = 4401 },
            },
        },
    },
}
