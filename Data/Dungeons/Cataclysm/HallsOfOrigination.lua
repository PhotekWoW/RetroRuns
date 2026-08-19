-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Origination
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 644  |  journalInstanceID: 70
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[70] = {
    kind              = "dungeon",
    instanceID        = 644,
    journalInstanceID = 70,
    name              = "Halls of Origination",
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
            name               = "Temple Guardian Anhuur",
            journalEncounterID = 124,
            achievements       = {
                { id = 5293, name = "I Hate That Song", meta = true },
            },
            loot = {
                { id = 56408, slot = "Feet", name = "Awakening Footfalls", sources = { [14]=27716 } },
                { id = 56410, slot = "Waist", name = "Belt of Petrified Tears", sources = { [14]=27718 } },
                { id = 56409, slot = "Wrist", name = "Poison Fang Bracers", sources = { [14]=27717 } },
            },
        },
        {
            index              = 2,
            name               = "Earthrager Ptah",
            journalEncounterID = 125,
            achievements       = {
            },
            loot = {
                { id = 56425, slot = "Chest", name = "Breastplate of the Risen Land", sources = { [14]=27726 } },
                { id = 56426, slot = "Off-hand", name = "Bulwark of the Primordial Mound", sources = { [14]=27727 } },
                { id = 56424, slot = "Two-Hand", name = "Soul Releaser", sources = { [14]=27725 } },
                { id = 56423, slot = "Waist", name = "Underworld Cord", sources = { [14]=27724 } },
            },
        },
        {
            index              = 3,
            name               = "Anraphet",
            journalEncounterID = 126,
            achievements       = {
            },
            loot = {
                { id = 57868, slot = "Chest", name = "Anraphet's Regalia", sources = { [14]=28578 } },
                { id = 57869, slot = "Chest", name = "Omega Breastplate", sources = { [14]=28579 } },
                { id = 57867, slot = "Feet", name = "Boots of Crumbling Ruin", sources = { [14]=28577 } },
                { id = 157611, slot = "Head", name = "Crown of Patient Vigil", sources = { [14]=93797 } },
                { id = 57866, slot = "Shoulder", name = "Mantle of Soft Shadows", sources = { [14]=28576 } },
                { id = 57870, slot = "Wrist", name = "Alpha Bracers", sources = { [14]=28580 } },
            },
        },
        {
            index              = 4,
            name               = "Isiset, Construct of Magic",
            journalEncounterID = 127,
            achievements       = {
            },
            loot = {
                { id = 56413, slot = "Legs", name = "Legwraps of Astral Rain", sources = { [14]=27719 } },
                { id = 157609, slot = "Weapon", name = "Scepter of Stargazing", sources = { [14]=93795 } },
                { id = 56416, slot = "Wrist", name = "Armguards of Unearthly Light", sources = { [14]=27720 } },
            },
        },
        {
            index              = 5,
            name               = "Ammunae, Construct of Life",
            journalEncounterID = 128,
            achievements       = {
            },
            loot = {
                { id = 56417, slot = "Chest", name = "Robes of Rampant Growth", sources = { [14]=27721 } },
                { id = 56419, slot = "Shoulder", name = "Bloodpetal Mantle", sources = { [14]=27722 } },
            },
        },
        {
            index              = 6,
            name               = "Setesh, Construct of Destruction",
            journalEncounterID = 129,
            achievements       = {
            },
            loot = {
                { id = 57874, slot = "Chest", name = "Hieroglyphic Vest", sources = { [14]=28584 } },
                { id = 57873, slot = "Head", name = "Helm of Setesh", sources = { [14]=28583 } },
                { id = 57871, slot = "Head", name = "Helm of the Typhonic Beast", sources = { [14]=28581 } },
                { id = 57875, slot = "Legs", name = "Chaotic Wrappings", sources = { [14]=28585 } },
                { id = 57872, slot = "Weapon", name = "Scepter of Power", sources = { [14]=28582 } },
            },
        },
        {
            index              = 7,
            name               = "Rajh, Construct of Sun",
            journalEncounterID = 130,
            achievements       = {
                { id = 4841, name = "Halls of Origination" },
                { id = 5065, name = "Heroic: Halls of Origination" },
                { id = 5295, name = "Sun of a....", meta = true },
                { id = 5296, name = "Faster Than the Speed of Light", meta = true },
            },
            loot = {
                { id = 56434, slot = "Back", name = "Solar Wind Cloak", sources = { [14]=27732 } },
                { id = 56436, slot = "Feet", name = "Hekatic Slippers", sources = { [14]=27734 } },
                { id = 56428, slot = "Hands", name = "Fingers of Light", sources = { [14]=27728 } },
                { id = 56435, slot = "Legs", name = "Legguards of Noon", sources = { [14]=27733 } },
                { id = 56429, slot = "Waist", name = "Red Beam Cord", sources = { [14]=27729 } },
                { id = 56433, slot = "Weapon", name = "Blade of the Burning Sun", sources = { [14]=27731 } },
                { id = 56430, slot = "Weapon", name = "Sun Strike", sources = { [14]=27730 } },
            },
        },
    },
}
