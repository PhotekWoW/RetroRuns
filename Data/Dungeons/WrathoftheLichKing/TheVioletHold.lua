-------------------------------------------------------------------------------
-- RetroRuns Data -- The Violet Hold
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 608  |  journalInstanceID: 283
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[283] = {
    kind              = "dungeon",
    instanceID        = 608,
    journalInstanceID = 283,
    name              = "The Violet Hold",
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
            name               = "Erekem",
            journalEncounterID = 626,
            achievements       = {
                { id = 1865, name = "Lockdown!", meta = true },
            },
            loot = {
                { id = 43406, slot = "Back", name = "Cloak of the Gushing Wound", sources = { [14]=20971 } },
                { id = 43363, slot = "Back", name = "Screeching Cape", sources = { [14]=20964 } },
                { id = 157567, slot = "Feet", name = "Bodyguard's Treads", sources = { [14]=93762 } },
                { id = 43405, slot = "Feet", name = "Sabatons of Erekem", sources = { [14]=20970 } },
                { id = 43375, slot = "Legs", name = "Trousers of the Arakkoa", sources = { [14]=20965 } },
                { id = 157583, slot = "Off-hand", name = "Protector's Buckler", sources = { [14]=93774 } },
                { id = 43407, slot = "Weapon", name = "Stormstrike Mace", sources = { [14]=20972 } },
            },
        },
        {
            index              = 2,
            name               = "Moragg",
            journalEncounterID = 627,
            achievements       = {
            },
            loot = {
                { id = 43410, slot = "Chest", name = "Moragg's Chestguard", sources = { [14]=20974 } },
                { id = 157566, slot = "Chest", name = "Vest of the Observant", sources = { [14]=93761 } },
                { id = 43387, slot = "Shoulder", name = "Shoulderplates of the Beholder", sources = { [14]=20966 } },
                { id = 43409, slot = "Two-Hand", name = "Saliva Corroded Pike", sources = { [14]=20973 } },
            },
        },
        {
            index              = 3,
            name               = "Ichoron",
            journalEncounterID = 628,
            achievements       = {
                { id = 2041, name = "Dehydration", meta = true },
            },
            loot = {
                { id = 43401, slot = "Chest", name = "Water-Drenched Robe", sources = { [14]=20967 } },
                { id = 37862, slot = "Hands", name = "Gauntlets of the Water Revenant", sources = { [14]=18070 } },
                { id = 35647, slot = "Hands", name = "Handguards of Rapid Pursuit", sources = { [14]=16571 } },
                { id = 157569, slot = "Legs", name = "Chain Leggings of the Tide", sources = { [14]=93764 } },
                { id = 35643, slot = "Shoulder", name = "Spaulders of Ichoron", sources = { [14]=16567 } },
            },
        },
        {
            index              = 4,
            name               = "Xevozz",
            journalEncounterID = 629,
            achievements       = {
            },
            loot = {
                { id = 37867, slot = "Feet", name = "Footwraps of Teleportation", sources = { [14]=18071 } },
                { id = 157571, slot = "Hands", name = "Gauntlets of Stuttering Reality", sources = { [14]=93766 } },
                { id = 157575, slot = "Off-hand", name = "Crystal of Ensnared Power", sources = { [14]=93768 } },
                { id = 35642, slot = "Off-hand", name = "Riot Shield", sources = { [14]=16566 } },
                { id = 37868, slot = "Waist", name = "Girdle of the Ethereal", sources = { [14]=18072 } },
                { id = 35644, slot = "Waist", name = "Xevozz's Belt", sources = { [14]=16568 } },
            },
        },
        {
            index              = 5,
            name               = "Lavanthor",
            journalEncounterID = 630,
            achievements       = {
            },
            loot = {
                { id = 37870, slot = "Feet", name = "Twin-Headed Boots", sources = { [14]=18073 } },
                { id = 35646, slot = "Hands", name = "Lava Burn Gloves", sources = { [14]=16570 } },
                { id = 157570, slot = "Head", name = "Helm of Cauterization", sources = { [14]=93765 } },
                { id = 35645, slot = "Ranged", name = "Prison Warden's Shotgun", sources = { [14]=16569 } },
                { id = 157572, slot = "Shoulder", name = "Pauldrons of the Great Tide", sources = { [14]=93767 } },
                { id = 37871, slot = "Weapon", name = "The Key", sources = { [14]=18074 } },
            },
        },
        {
            index              = 6,
            name               = "Zuramat the Obliterator",
            journalEncounterID = 631,
            achievements       = {
                { id = 2153, name = "A Void Dance", meta = true },
            },
            loot = {
                { id = 43402, slot = "Feet", name = "The Obliterator Greaves", sources = { [14]=20968 } },
                { id = 157568, slot = "Head", name = "Helm of Dire Vision", sources = { [14]=93763 } },
                { id = 43403, slot = "Head", name = "Shroud of Darkness", sources = { [14]=20969 } },
                { id = 43353, slot = "Legs", name = "Void Sentry Legplates", sources = { [14]=20963 } },
            },
        },
        {
            index              = 7,
            name               = "Cyanigosa",
            journalEncounterID = 632,
            achievements       = {
                { id = 483, name = "The Violet Hold" },
                { id = 494, name = "Heroic: The Violet Hold" },
                { id = 1816, name = "Defenseless", meta = true },
            },
            loot = {
                { id = 35650, slot = "Feet", name = "Boots of the Portal Guardian", sources = { [14]=16573 } },
                { id = 37874, slot = "Hands", name = "Gauntlets of Capture", sources = { [14]=18075 } },
                { id = 37886, slot = "Hands", name = "Handgrips of the Savage Emissary", sources = { [14]=18080 } },
                { id = 35651, slot = "Hands", name = "Plate Claws of the Dragon", sources = { [14]=16574 } },
                { id = 43500, slot = "Legs", name = "Bolstered Legplates", sources = { [14]=21013 } },
                { id = 37876, slot = "Legs", name = "Cyanigosa's Leggings", sources = { [14]=18077 } },
                { id = 37875, slot = "Shoulder", name = "Spaulders of the Violet Hold", sources = { [14]=18076 } },
                { id = 35649, slot = "Two-Hand", name = "Jailer's Baton", sources = { [14]=16572 } },
                { id = 37883, slot = "Two-Hand", name = "Staff of Trickery", sources = { [14]=18078 } },
                { id = 37884, slot = "Wrist", name = "Azure Cloth Bindings", sources = { [14]=18079 } },
                { id = 150845, slot = "Wrist", name = "Bracers of Ley-Line Eradication", sources = { [14]=93775 } },
            },
        },
    },
}
