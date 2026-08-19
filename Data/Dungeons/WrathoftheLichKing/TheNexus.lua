-------------------------------------------------------------------------------
-- RetroRuns Data -- The Nexus
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 576  |  journalInstanceID: 281
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[281] = {
    kind              = "dungeon",
    instanceID        = 576,
    journalInstanceID = 281,
    name              = "The Nexus",
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
            name               = "Commander Stoutbeard",
            journalEncounterID = 617,
            achievements       = {
            },
            loot = {
                { id = 37728, slot = "Back", name = "Cloak of the Enemy", sources = { [14]=17972 } },
                { id = 127600, slot = "Back", name = "Rippling Azure Cloak", sources = { [14]=72706 }, timewalkingOnly = true },
                { id = 37730, slot = "Feet", name = "Cleric's Linen Shoes", sources = { [14]=17974 } },
                { id = 37729, slot = "Hands", name = "Grips of Sculptured Icicles", sources = { [14]=17973 } },
                { id = 37731, slot = "Legs", name = "Opposed Stasis Leggings", sources = { [14]=17975 } },
            },
        },
        {
            index              = 2,
            name               = "Commander Kolurg",
            journalEncounterID = 833,
            achievements       = {
            },
            loot = {
                { id = 37728, slot = "Back", name = "Cloak of the Enemy", sources = { [14]=17972 } },
                { id = 127600, slot = "Back", name = "Rippling Azure Cloak", sources = { [14]=72706 }, timewalkingOnly = true },
                { id = 37730, slot = "Feet", name = "Cleric's Linen Shoes", sources = { [14]=17974 } },
                { id = 37729, slot = "Hands", name = "Grips of Sculptured Icicles", sources = { [14]=17973 } },
                { id = 37731, slot = "Legs", name = "Opposed Stasis Leggings", sources = { [14]=17975 } },
            },
        },
        {
            index              = 3,
            name               = "Grand Magus Telestra",
            journalEncounterID = 618,
            achievements       = {
            },
            loot = {
                { id = 37135, slot = "Head", name = "Arcane-Shielded Helm", sources = { [14]=17620 } },
                { id = 37134, slot = "Off-hand", name = "Telestra's Journal", sources = { [14]=17619 } },
                { id = 35617, slot = "Ranged", name = "Wand of Shimmering Scales", sources = { [14]=16551 } },
                { id = 37139, slot = "Shoulder", name = "Spaulders of the Careless Thief", sources = { [14]=17622 } },
                { id = 35605, slot = "Waist", name = "Belt of Draconic Runes", sources = { [14]=16540 } },
                { id = 37138, slot = "Wrist", name = "Bands of Channeled Energy", sources = { [14]=17621 } },
                { id = 35604, slot = "Wrist", name = "Insulating Bindings", sources = { [14]=16539 } },
            },
        },
        {
            index              = 4,
            name               = "Anomalus",
            journalEncounterID = 619,
            achievements       = {
                { id = 2037, name = "Chaos Theory", meta = true },
            },
            loot = {
                { id = 37144, slot = "Chest", name = "Hauberk of the Arcane Wraith", sources = { [14]=17623 } },
                { id = 127602, slot = "Feet", name = "Cavern Leather Treads", sources = { [14]=72708 }, timewalkingOnly = true },
                { id = 35600, slot = "Feet", name = "Cleated Ice Boots", sources = { [14]=16535 } },
                { id = 37150, slot = "Feet", name = "Rift Striders", sources = { [14]=17626 } },
                { id = 35599, slot = "Hands", name = "Gauntlets of Serpent Scales", sources = { [14]=16534 } },
                { id = 37149, slot = "Head", name = "Helm of Anomalus", sources = { [14]=17625 } },
                { id = 35598, slot = "Off-hand", name = "Tome of the Lore Keepers", sources = { [14]=16533 } },
            },
        },
        {
            index              = 5,
            name               = "Ormorok the Tree-Shaper",
            journalEncounterID = 620,
            achievements       = {
            },
            loot = {
                { id = 127600, slot = "Back", name = "Rippling Azure Cloak", sources = { [14]=72706 }, timewalkingOnly = true },
                { id = 35603, slot = "Feet", name = "Greaves of the Blue Flight", sources = { [14]=16538 } },
                { id = 37153, slot = "Hands", name = "Gloves of the Crystal Gardener", sources = { [14]=17628 } },
                { id = 37155, slot = "Legs", name = "Frozen Forest Kilt", sources = { [14]=17629 } },
                { id = 35602, slot = "Shoulder", name = "Chiseled Stalagmite Pauldrons", sources = { [14]=16537 } },
                { id = 157559, slot = "Waist", name = "Chilly Cinch", sources = { [14]=93754 } },
                { id = 37152, slot = "Waist", name = "Girdle of Ice", sources = { [14]=17627 } },
                { id = 35601, slot = "Weapon", name = "Drakonid Arm Blade", sources = { [14]=16536 } },
            },
        },
        {
            index              = 6,
            name               = "Keristrasza",
            journalEncounterID = 621,
            achievements       = {
                { id = 2036, name = "Intense Cold", meta = true },
                { id = 478, name = "The Nexus" },
                { id = 490, name = "Heroic: The Nexus" },
                { id = 39925, name = "The Nexus (char specific hidden copy)" },
            },
            loot = {
                { id = 37165, slot = "Chest", name = "Crystal-Infused Tunic", sources = { [14]=17631 } },
                { id = 35596, slot = "Feet", name = "Attuned Crystalline Boots", sources = { [14]=16532 } },
                { id = 37167, slot = "Feet", name = "Dragon Slayer's Sabatons", sources = { [14]=17632 } },
                { id = 37172, slot = "Hands", name = "Gloves of Glistening Runes", sources = { [14]=17636 } },
                { id = 157565, slot = "Hands", name = "Tangler-Leather Gloves", sources = { [14]=93760 } },
                { id = 37162, slot = "Off-hand", name = "Bulwark of the Noble Protector", sources = { [14]=17630 } },
                { id = 37171, slot = "Waist", name = "Flame-Bathed Steel Girdle", sources = { [14]=17635 } },
                { id = 35595, slot = "Weapon", name = "Glacier Sharpened Vileblade", sources = { [14]=16531 } },
                { id = 37169, slot = "Weapon", name = "War Mace of Unrequited Love", sources = { [14]=17633 } },
                { id = 37170, slot = "Wrist", name = "Interwoven Scale Bracers", sources = { [14]=17634 } },
            },
        },
    },
}
