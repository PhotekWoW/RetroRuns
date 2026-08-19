-------------------------------------------------------------------------------
-- RetroRuns Data -- Lost City of the Tol'vir
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 755  |  journalInstanceID: 69
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[69] = {
    kind              = "dungeon",
    instanceID        = 755,
    journalInstanceID = 69,
    name              = "Lost City of the Tol'vir",
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
            name               = "General Husam",
            journalEncounterID = 117,
            achievements       = {
            },
            loot = {
                { id = 56379, slot = "Back", name = "Kaleki Cloak", sources = { [14]=27698 } },
                { id = 56381, slot = "Feet", name = "Greaves of Wu the Elder", sources = { [14]=27699 } },
                { id = 56383, slot = "Hands", name = "Ionic Gloves", sources = { [14]=27701 } },
                { id = 56382, slot = "Two-Hand", name = "Seliza's Spear", sources = { [14]=27700 } },
            },
        },
        {
            index              = 2,
            name               = "Lockmaw",
            journalEncounterID = 118,
            achievements       = {
                { id = 5291, name = "Acrocalypse Now", meta = true },
            },
            loot = {
                { id = 56387, slot = "Feet", name = "Greaves of Wu the Younger", sources = { [14]=27704 } },
                { id = 56386, slot = "Legs", name = "Balkar's Waders", sources = { [14]=27703 } },
                { id = 56384, slot = "Weapon", name = "Resonant Kris", sources = { [14]=27702 } },
                { id = 133280, slot = "Wrist", name = "Oasis Bracers", sources = { [14]=76636 }, timewalkingOnly = true },
            },
        },
        {
            index              = 3,
            name               = "High Prophet Barim",
            journalEncounterID = 119,
            achievements       = {
                { id = 5290, name = "Kill It With Fire!", meta = true },
            },
            loot = {
                { id = 56392, slot = "Waist", name = "Sand Dune Belt", sources = { [14]=27707 } },
                { id = 56390, slot = "Weapon", name = "Barim's Main Gauche", sources = { [14]=27706 } },
                { id = 56389, slot = "Wrist", name = "Sand Silk Wristband", sources = { [14]=27705 } },
            },
        },
        {
            index              = 4,
            name               = "Siamat",
            journalEncounterID = 122,
            achievements       = {
                { id = 4848, name = "Lost City of the Tol'vir" },
                { id = 5066, name = "Heroic: Lost City of the Tol'vir" },
                { id = 5292, name = "Headed South", meta = true },
                { id = 5294, name = "Straw That Broke the Camel's Back", meta = true },
            },
            loot = {
                { id = 56397, slot = "Back", name = "Geordan's Cloak", sources = { [14]=27710 } },
                { id = 56395, slot = "Feet", name = "Crafty's Gaiters", sources = { [14]=27708 } },
                { id = 56401, slot = "Legs", name = "Leggings of the Path", sources = { [14]=27712 } },
                { id = 56402, slot = "Off-hand", name = "Zora's Ward", sources = { [14]=27713 } },
                { id = 56399, slot = "Shoulder", name = "Mantle of Master Cho", sources = { [14]=27711 } },
                { id = 56403, slot = "Waist", name = "Evelyn's Belt", sources = { [14]=27714 } },
                { id = 56396, slot = "Weapon", name = "Hammer of Sparks", sources = { [14]=27709 } },
                { id = 157599, slot = "Weapon", name = "Sceptre of Swirling Winds", sources = { [14]=93788 } },
            },
        },
    },
}
