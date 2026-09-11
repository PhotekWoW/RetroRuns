-------------------------------------------------------------------------------
-- RetroRuns Data -- Shadowfang Keep
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 33  |  journalInstanceID: 64
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[64] = {
    kind              = "dungeon",
    instanceID        = 33,
    journalInstanceID = 64,
    name              = "Shadowfang Keep",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.0.3",

    entrance = {
        mapID = 21,
        x     = 0.4480,
        y     = 0.6780,
    },

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    pois = {
        { mapID = 316, poiKind = "rare", rareNpc = "Deathsworn Captain", mapLabelPos = "above", points = { { 0.230, 0.744 }, { 0.284, 0.756 }, { 0.342, 0.760 }, { 0.396, 0.788 }, { 0.402, 0.438 }, { 0.436, 0.846 }, { 0.446, 0.308 }, { 0.448, 0.186 }, { 0.454, 0.412 }, { 0.454, 0.470 }, { 0.456, 0.244 }, { 0.504, 0.826 }, { 0.508, 0.500 }, { 0.522, 0.884 }, { 0.544, 0.940 }, { 0.560, 0.832 }, { 0.586, 0.532 }, { 0.614, 0.822 }, { 0.616, 0.874 }, { 0.638, 0.522 }, { 0.668, 0.846 }, { 0.678, 0.578 }, { 0.688, 0.788 }, { 0.706, 0.688 }, { 0.712, 0.628 } } },
    },

    trashLoot = {
        { id = 6642, slot = "Chest", name = "Phantom Armor", sources = { [14]=2550 }, bind = "BoP", rareNpc = "Deathsworn Captain" },
        { id = 6641, slot = "Two-Hand", name = "Haunting Blade", sources = { [14]=2549 }, bind = "BoP", rareNpc = "Deathsworn Captain" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Baron Ashbury",
            journalEncounterID = 96,
            achievements       = {
                { id = 5503, name = "Pardon Denied", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 6314, slot = "Back", name = "Wolfmaster Cape", sources = { [14]=2340 } },
                { id = 6324, slot = "Chest", name = "Robes of Arugal", sources = { [14]=2347, [15]=31799 } },
                { id = 63435, slot = "Feet", name = "Boots of the Predator", sources = { [15]=31801 } },
                { id = 63434, slot = "Hands", name = "Gloves of the Greymane Wall", sources = { [15]=31800 } },
                { id = 63436, slot = "Hands", name = "Traitor's Grips", sources = { [15]=31802 } },
                { id = 6323, slot = "Weapon", name = "Baron's Scepter", sources = { [14]=2346 } },
                { id = 63437, slot = "Wrist", name = "Baron Ashbury's Cuffs", sources = { [15]=31803 } },
            },
        },
        {
            index              = 2,
            name               = "Baron Silverlaine",
            journalEncounterID = 97,
            achievements       = {
            },
            loot = {
                { id = 63444, slot = "Feet", name = "Baron Silverlaine's Greaves", sources = { [15]=31806 } },
                { id = 63440, slot = "Feet", name = "Boots of Lingering Sorrow", sources = { [15]=31805 } },
                { id = 63439, slot = "Hands", name = "Gloves of the Uplifted Cup", sources = { [15]=31804 } },
                { id = 5254, slot = "Shoulder", name = "Rugged Spaulders", sources = { [14]=2021 } },
                { id = 132568, slot = "Shoulder", name = "Shadowfang Pauldrons", sources = { [14]=76401 } },
                { id = 132567, slot = "Waist", name = "Blindwatcher's Chain", sources = { [14]=76400 } },
                { id = 6319, slot = "Waist", name = "Girdle of the Blindwatcher", sources = { [14]=2343 } },
                { id = 5943, slot = "Wrist", name = "Rift Bracers", sources = { [14]=2209 } },
            },
        },
        {
            index              = 3,
            name               = "Commander Springvale",
            journalEncounterID = 98,
            achievements       = {
                { id = 5504, name = "To the Ground!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63448, slot = "Back", name = "Springvale's Cloak", sources = { [15]=31810 } },
                { id = 151069, slot = "Chest", name = "Breastplate of the Stilled Heart", sources = { [14]=89255, [15]=31809 } },
                { id = 151067, slot = "Feet", name = "Boots of Lingering Sorrow", sources = { [14]=89253 } },
                { id = 151068, slot = "Feet", name = "Boots of the Predator", sources = { [14]=89254 } },
                { id = 63446, slot = "Feet", name = "Haunting Footfalls", sources = { [15]=31808 } },
                { id = 151070, slot = "Hands", name = "Gloves of the Greymane Wall", sources = { [14]=89256 } },
                { id = 6320, slot = "Off-hand", name = "Commander's Crest", sources = { [14]=2344 } },
                { id = 63449, slot = "Shoulder", name = "Thieving Spaulders", sources = { [15]=31811 } },
                { id = 3191, slot = "Two-Hand", name = "Arced War Axe", sources = { [14]=1115, [15]=31807 } },
            },
        },
        {
            index              = 4,
            name               = "Lord Walden",
            journalEncounterID = 99,
            achievements       = {
            },
            loot = {
                { id = 6642, slot = "Chest", name = "Phantom Armor", sources = { [14]=2550, [15]=31812 } },
                { id = 63455, slot = "Head", name = "Blinders of the Follower", sources = { [15]=31816 } },
                { id = 6341, slot = "Off-hand", name = "Eerie Stable Lantern", sources = { [14]=2356 } },
                { id = 63452, slot = "Shoulder", name = "Burden of Lost Humanity", sources = { [15]=31813 } },
                { id = 63453, slot = "Waist", name = "Iron Will Girdle", sources = { [15]=31814 } },
                { id = 1292, slot = "Weapon", name = "Butcher's Cleaver", sources = { [14]=225 } },
                { id = 3230, slot = "Wrist", name = "Black Wolf Bracers", sources = { [14]=1148 } },
                { id = 132566, slot = "Wrist", name = "Dark Lupine Wraps", sources = { [14]=76399 } },
                { id = 63454, slot = "Wrist", name = "Double Dealing Bracers", sources = { [15]=31815 } },
            },
        },
        {
            index              = 5,
            name               = "Lord Godfrey",
            journalEncounterID = 100,
            achievements       = {
                { id = 5505, name = "Bullet Time", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63458, slot = "Chest", name = "Lord Walden's Breastplate", sources = { [15]=31819 } },
                { id = 157617, slot = "Chest", name = "Wolfshide Vest", sources = { [15]=93803 } },
                { id = 151071, slot = "Hands", name = "Gloves of the Uplifted Cup", sources = { [14]=89257 } },
                { id = 63462, slot = "Head", name = "Helm of Untold Stories", sources = { [15]=31822 } },
                { id = 151072, slot = "Head", name = "Worgen Hunter's Helm", sources = { [14]=89258, [15]=31820 } },
                { id = 151073, slot = "Legs", name = "Greaves of the Misguided", sources = { [14]=89259, [15]=31824 } },
                { id = 3748, slot = "Shoulder", name = "Feline Mantle", sources = { [14]=1388 } },
                { id = 63465, slot = "Shoulder", name = "Mantle of Loss", sources = { [15]=31825 } },
                { id = 63463, slot = "Shoulder", name = "Mantle of the Eastern Lords", sources = { [15]=31823 } },
                { id = 6641, slot = "Two-Hand", name = "Haunting Blade", sources = { [14]=2549 } },
                { id = 6318, slot = "Two-Hand", name = "Odo's Ley Staff", sources = { [14]=2342 } },
                { id = 63461, slot = "Two-Hand", name = "Staff of Isolation", sources = { [15]=31821 } },
                { id = 6220, slot = "Weapon", name = "Meteor Shard", sources = { [14]=2303, [15]=31817 } },
                { id = 63457, slot = "Wrist", name = "Shackles of Undeath", sources = { [15]=31818 } },
            },
            specialLoot = {
                { id = 244655, kind = "decor", name = "Gilnean Circular Rug", decorID = 1445 },
            },
        },
    },
}
