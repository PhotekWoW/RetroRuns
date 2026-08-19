-------------------------------------------------------------------------------
-- RetroRuns Data -- Shado-Pan Monastery
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 959  |  journalInstanceID: 312
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[312] = {
    kind              = "dungeon",
    instanceID        = 959,
    journalInstanceID = 312,
    name              = "Shado-Pan Monastery",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    patch             = "5.0.4",

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Gu Cloudstrike",
            journalEncounterID = 673,
            achievements       = {
            },
            loot = {
                { id = 143961, slot = "Chest", name = "Azure Serpent Chestguard", sources = { [14]=84296 } },
                { id = 143978, slot = "Legs", name = "Leggings of the Charging Soul", sources = { [14]=84313 } },
                { id = 144096, slot = "Waist", name = "Sparkbreath Girdle", sources = { [14]=84402 } },
                { id = 144126, slot = "Wrist", name = "Star Summoner Bracers", sources = { [14]=84423 } },
            },
        },
        {
            index              = 2,
            name               = "Master Snowdrift",
            journalEncounterID = 657,
            achievements       = {
                { id = 6477, name = "Respect", meta = true },
            },
            loot = {
                { id = 144106, slot = "Hands", name = "Gauntlets of Resolute Fury", sources = { [14]=84411 } },
                { id = 144110, slot = "Two-Hand", name = "Snowdrift's Bladed Staff", sources = { [14]=84415 } },
                { id = 144097, slot = "Waist", name = "Quivering Heart Girdle", sources = { [14]=84403 } },
            },
        },
        {
            index              = 3,
            name               = "Sha of Violence",
            journalEncounterID = 685,
            achievements       = {
                { id = 6472, name = "The Obvious Solution", meta = true },
            },
            loot = {
                { id = 143985, slot = "Feet", name = "Spike-Soled Stompers", sources = { [14]=84320 } },
                { id = 144107, slot = "Hands", name = "Gloves of Enraged Slaughter", sources = { [14]=84412 } },
                { id = 144099, slot = "Weapon", name = "Crescent of Ichor", sources = { [14]=84405 } },
                { id = 144131, slot = "Wrist", name = "Bladed Smoke Bracers", sources = { [14]=84424 } },
            },
        },
        {
            index              = 4,
            name               = "Taran Zhu",
            journalEncounterID = 686,
            achievements       = {
                { id = 6469, name = "Shado-Pan Monastery" },
                { id = 6470, name = "Heroic: Shado-Pan Monastery" },
                { id = 6471, name = "Hate Leads to Suffering", meta = true },
                { id = 6893, name = "Shado-Pan Monastery Challenger" },
                { id = 6902, name = "Shado-Pan Monastery: Bronze" },
                { id = 6903, name = "Shado-Pan Monastery: Silver" },
                { id = 6904, name = "Shado-Pan Monastery: Gold" },
                { id = 19898, name = "Shado-Pan Monastery" },
                { id = 19899, name = "Heroic: Shado-Pan Monastery" },
            },
            loot = {
                { id = 143962, slot = "Chest", name = "Hateshatter Chestplate", sources = { [14]=84297 } },
                { id = 143990, slot = "Chest", name = "Robes of Fevered Dreams", sources = { [14]=84325 } },
                { id = 143986, slot = "Feet", name = "Blastwalker Footguards", sources = { [14]=84321 } },
                { id = 144108, slot = "Hands", name = "Mindbinder Plate Gloves", sources = { [14]=84413 } },
                { id = 143979, slot = "Legs", name = "Darkbinder Leggings", sources = { [14]=84314 } },
                { id = 144103, slot = "Off-hand", name = "Shield of Blind Hate", sources = { [14]=84408 } },
                { id = 143981, slot = "Shoulder", name = "Shadowspine Shoulderguards", sources = { [14]=84316 } },
                { id = 144109, slot = "Two-Hand", name = "Warmace of Taran Zhu", sources = { [14]=84414 } },
                { id = 144215, slot = "Weapon", name = "Ka'eng, Breath of the Shadow", sources = { [14]=84483 } },
            },
        },
    },
}
