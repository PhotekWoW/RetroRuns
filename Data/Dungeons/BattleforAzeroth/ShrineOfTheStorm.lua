-------------------------------------------------------------------------------
-- RetroRuns Data -- Shrine of the Storm
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1864  |  journalInstanceID: 1036
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1036] = {
    kind              = "dungeon",
    instanceID        = 1864,
    journalInstanceID = 1036,
    name              = "Shrine of the Storm",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.0.1",

    gloryMeta = {
        id   = 12812,
        name = "Glory of the Wartorn Hero",
        rewardItemID       = 161215,
        rewardName         = "Reins of the Obsidian Krolusk",
    },

    bosses = {
        {
            index              = 1,
            name               = "Aqu'sirr",
            journalEncounterID = 2153,
            achievements       = {
            },
            loot = {
                { id = 159420, slot = "Feet", name = "Stormsurger's Sabatons", sources = { [14]=95217, [15]=95670, [16]=95671 } },
                { id = 159321, slot = "Hands", name = "Gloves of Corrupted Waters", sources = { [14]=95083, [15]=98466, [16]=98467 } },
                { id = 159366, slot = "Hands", name = "Water Shapers", sources = { [14]=95142, [15]=95850, [16]=95851 } },
                { id = 159239, slot = "Waist", name = "Aqu'sirr's Swirling Sash", sources = { [14]=94976, [15]=95757, [16]=95758 } },
            },
        },
        {
            index              = 2,
            name               = "Tidesage Council",
            journalEncounterID = 2154,
            achievements       = {
            },
            loot = {
                { id = 159311, slot = "Feet", name = "Blessing Bearer's Waders", sources = { [14]=95070, [15]=98457, [16]=98458 } },
                { id = 159295, slot = "Feet", name = "Footpads of the Serene Wake", sources = { [14]=95048, [15]=98446, [16]=98447 } },
                { id = 159419, slot = "Legs", name = "Ironhull's Reinforced Legplates", sources = { [14]=95215, [15]=95216, [16]=95669 } },
                { id = 159359, slot = "Legs", name = "Sea Priest's Greaves", sources = { [14]=95132, [15]=95844, [16]=95845 } },
                { id = 158371, slot = "Two-Hand", name = "Seabreeze", sources = { [14]=94384, [15]=94385, [16]=94386 } },
                { id = 159426, slot = "Waist", name = "Belt of the Unrelenting Gale", sources = { [14]=95225, [15]=95226, [16]=95674 } },
            },
        },
        {
            index              = 3,
            name               = "Lord Stormsong",
            journalEncounterID = 2155,
            achievements       = {
                { id = 12601, name = "The Void Lies Sleeping", meta = true },
            },
            loot = {
                { id = 159289, slot = "Back", name = "Void-Drenched Cape", sources = { [14]=95042, [15]=97045, [16]=97046 } },
                { id = 159421, slot = "Hands", name = "Gauntlets of Total Subservience", sources = { [14]=95218, [15]=95672, [16]=95673 } },
                { id = 159242, slot = "Legs", name = "Leggings of the Drowned Lord", sources = { [14]=94980, [15]=94981, [16]=95760 } },
                { id = 159646, slot = "Weapon", name = "Aq'mar, the Tidecaller", sources = { [14]=95431, [15]=95513, [16]=95514 } },
                { id = 159364, slot = "Wrist", name = "Bindings of the Calling Depths", sources = { [14]=95139, [15]=95140, [16]=95847 } },
                { id = 159308, slot = "Wrist", name = "Bracers of the Sacred Fleet", sources = { [14]=95065, [15]=95066, [16]=98453 } },
            },
        },
        {
            index              = 4,
            name               = "Vol'zith the Whisperer",
            journalEncounterID = 2156,
            achievements       = {
                { id = 12602, name = "Trust No One", meta = true },
                { id = 12835, name = "Shrine of the Storm" },
                { id = 12837, name = "Heroic: Shrine of the Storm" },
                { id = 12838, name = "Mythic: Shrine of the Storm" },
                { id = 12600, name = "Breath of the Shrine", meta = true },
            },
            loot = {
                { id = 159408, slot = "Chest", name = "Chestguard of the Deep Denizen", sources = { [14]=95197, [15]=95198, [16]=95666 } },
                { id = 159354, slot = "Chest", name = "Hauberk of Sunken Despair", sources = { [14]=95124, [15]=95125, [16]=95843 } },
                { id = 159302, slot = "Head", name = "Cowl of Fluid Machinations", sources = { [14]=95058, [15]=98450, [16]=98451 } },
                { id = 159430, slot = "Head", name = "Helm of Abyssal Malevolence", sources = { [14]=95231, [15]=95680, [16]=95681 } },
                { id = 239044, slot = "Head", name = "Helm of Abyssal Malevolence", sources = { [14]=287948, [15]=287949, [16]=287950 } },
                { id = 159244, slot = "Head", name = "Stormlurker's Cowl", sources = { [14]=94984, [15]=95761, [16]=95762 } },
                { id = 159238, slot = "Shoulder", name = "Mantle of Void-Touched Waters", sources = { [14]=94975, [15]=95755, [16]=95756 } },
                { id = 159307, slot = "Shoulder", name = "Tentacle-Laced Spaulders", sources = { [14]=95063, [15]=95064, [16]=98452 } },
                { id = 159377, slot = "Waist", name = "Chain of Consummate Power", sources = { [14]=95156, [15]=95860, [16]=95861 } },
                { id = 159135, slot = "Weapon", name = "Deep Fathom's Bite", sources = { [14]=94881, [15]=95470, [16]=95471 } },
            },
            specialLoot = {
                { id = 245681, kind = "decor", name = "Tidesage's Fireplace", decorID = 1880 },
            },
        },
    },
}
