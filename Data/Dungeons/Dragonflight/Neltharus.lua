-------------------------------------------------------------------------------
-- RetroRuns Data -- Neltharus
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2519  |  journalInstanceID: 1199
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1199] = {
    kind              = "dungeon",
    instanceID        = 2519,
    journalInstanceID = 1199,
    name              = "Neltharus",
    expansion         = "Dragonflight",
    difficultyModel   = "dungeonTiered",
    patch             = "10.0.2",

    gloryMeta = {
        id   = 16295,
        name = "Glory of the Dragonflight Hero",
        rewardItemID       = 192784,
        rewardMountSpellID = 374155,
        rewardName         = "Shellack",
    },

    bosses = {
        {
            index              = 1,
            name               = "Chargath, Bane of Scales",
            journalEncounterID = 2490,
            achievements       = {
                { id = 16438, name = "Knowledge is... Preserved?", meta = true },
            },
            loot = {
                { id = 193771, slot = "Feet", name = "Pristine Magma Stompers", sources = { [14]=180877, [15]=180877, [16]=180877 } },
                { id = 193772, slot = "Weapon", name = "Dragonscale Ripper", sources = { [14]=180878, [15]=180878, [16]=180878 } },
                { id = 193727, slot = "Wrist", name = "Obsidian-Hardened Wraps", sources = { [14]=180840, [15]=180840, [16]=180840 } },
            },
        },
        {
            index              = 2,
            name               = "Forgemaster Gorek",
            journalEncounterID = 2489,
            achievements       = {
                { id = 16432, name = "Ready for Raiding VIII", meta = true },
            },
            loot = {
                { id = 193782, slot = "Chest", name = "Emberguard Harness", sources = { [14]=180886, [15]=180886, [16]=180886 } },
                { id = 193784, slot = "Hands", name = "Forgemaster's Grips", sources = { [14]=180888, [15]=180888, [16]=180888 } },
                { id = 193781, slot = "Legs", name = "Lavabearer Legwraps", sources = { [14]=180885, [15]=180885, [16]=180885 } },
                { id = 193783, slot = "Off-hand", name = "Irontorch Igniter", sources = { [14]=180887, [15]=180887, [16]=180887 } },
                { id = 193780, slot = "Waist", name = "Flare-Singed Strap", sources = { [14]=180884, [15]=180884, [16]=180884 } },
                { id = 193785, slot = "Weapon", name = "Forgestorm", sources = { [14]=180889, [15]=180889, [16]=180889 } },
            },
        },
        {
            index              = 3,
            name               = "Magmatusk",
            journalEncounterID = 2494,
            achievements       = {
                { id = 16453, name = "Liquid Hot Magma", meta = true },
            },
            loot = {
                { id = 193787, slot = "Back", name = "Mammoth-Trainer's Drape", sources = { [14]=180891, [15]=180891, [16]=180891 } },
                { id = 193789, slot = "Legs", name = "Fural's Blazing Faulds", sources = { [14]=180892, [15]=180892, [16]=180892 } },
                { id = 193788, slot = "Shoulder", name = "Molten Magma Mantle", sources = { [14]=180890, [15]=180890, [16]=180890 } },
                { id = 193790, slot = "Weapon", name = "Searing Tusk Shard", sources = { [14]=180893, [15]=180893, [16]=180893 } },
            },
        },
        {
            index              = 4,
            name               = "Warlord Sargha",
            journalEncounterID = 2501,
            achievements       = {
                { id = 16263, name = "Neltharus" },
                { id = 16264, name = "Heroic: Neltharus" },
                { id = 16265, name = "Mythic: Neltharus" },
            },
            loot = {
                { id = 193776, slot = "Chest", name = "Dragonkiln Chestguard", sources = { [14]=180880, [15]=180880, [16]=180880 } },
                { id = 193775, slot = "Hands", name = "Warlord's Cindermitts", sources = { [14]=180879, [15]=180879, [16]=180879 } },
                { id = 193777, slot = "Head", name = "Helm of Hardened Gold", sources = { [14]=180881, [15]=180881, [16]=180881 } },
                { id = 193778, slot = "Off-hand", name = "Qalashi Defender", sources = { [14]=180882, [15]=180882, [16]=180882 } },
                { id = 193779, slot = "Two-Hand", name = "Sargha's Smasher", sources = { [14]=180883, [15]=180883, [16]=180883 } },
            },
        },
    },
}
