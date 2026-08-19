-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Infusion
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2527  |  journalInstanceID: 1204
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1204] = {
    kind              = "dungeon",
    instanceID        = 2527,
    journalInstanceID = 1204,
    name              = "Halls of Infusion",
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
            name               = "Watcher Irideus",
            journalEncounterID = 2504,
            achievements       = {
            },
            loot = {
                { id = 193746, slot = "Hands", name = "Gauntlets of Incalculable Power", sources = { [14]=180854, [15]=180854, [16]=180854 } },
                { id = 193745, slot = "Off-hand", name = "Rod of Perfect Order", sources = { [14]=180853, [15]=180853, [16]=180853 } },
                { id = 193747, slot = "Ranged", name = "Titan-Forged Blaster", sources = { [14]=180855, [15]=180855, [16]=180855 } },
                { id = 193744, slot = "Waist", name = "Watcher's Clasp of Purpose", sources = { [14]=180852, [15]=180852, [16]=180852 } },
            },
        },
        {
            index              = 2,
            name               = "Gulping Goliath",
            journalEncounterID = 2507,
            achievements       = {
                { id = 16426, name = "Hungry Hungry Hornswog", meta = true },
            },
            loot = {
                { id = 193770, slot = "Feet", name = "Swoglet Stompers", sources = { [14]=180872, [15]=180872, [16]=180872 } },
                { id = 193726, slot = "Head", name = "Amphibian's Bellowing Crown", sources = { [14]=180839, [15]=180839, [16]=180839 } },
                { id = 193725, slot = "Shoulder", name = "Ancient Hornswog Spaulders", sources = { [14]=180838, [15]=180838, [16]=180838 } },
                { id = 193760, slot = "Waist", name = "Ravenous Omnivore's Girdle", sources = { [14]=180865, [15]=180865, [16]=180865 } },
                { id = 193730, slot = "Weapon", name = "Croaking Dagger", sources = { [14]=180843, [15]=180843, [16]=180843 } },
                { id = 193729, slot = "Weapon", name = "Tongue Hacker", sources = { [14]=180842, [15]=180842, [16]=180842 } },
                { id = 193724, slot = "Wrist", name = "Lily-Laced Bracelets", sources = { [14]=180837, [15]=180837, [16]=180837 } },
            },
        },
        {
            index              = 3,
            name               = "Khajin the Unyielding",
            journalEncounterID = 2510,
            achievements       = {
            },
            loot = {
                { id = 193734, slot = "Chest", name = "Hauberk of Frozen Fervor", sources = { [14]=180845, [15]=180845, [16]=180845 } },
                { id = 193733, slot = "Feet", name = "Khajin's Hailstone Footwraps", sources = { [14]=180844, [15]=180844, [16]=180844 } },
                { id = 193735, slot = "Head", name = "Earthshaker's Steel Visor", sources = { [14]=180846, [15]=180846, [16]=180846 } },
            },
        },
        {
            index              = 4,
            name               = "Primal Tsunami",
            journalEncounterID = 2511,
            achievements       = {
                { id = 16260, name = "Halls of Infusion" },
                { id = 16261, name = "Heroic: Halls of Infusion" },
                { id = 16262, name = "Mythic: Halls of Infusion" },
                { id = 16427, name = "Go With the Flow", meta = true },
                { id = 16517, name = "Toxicity Strike Team", meta = true },
            },
            loot = {
                { id = 193738, slot = "Chest", name = "Robe of Plunging Depths", sources = { [14]=180847, [15]=180847, [16]=180847 } },
                { id = 193739, slot = "Feet", name = "Treads of Restored Order", sources = { [14]=180848, [15]=180848, [16]=180848 } },
                { id = 193740, slot = "Hands", name = "Torrential Downpour Gauntlets", sources = { [14]=180849, [15]=180849, [16]=180849 } },
                { id = 193741, slot = "Shoulder", name = "Mantle of Crushing Waves", sources = { [14]=180850, [15]=180850, [16]=180850 } },
                { id = 193742, slot = "Two-Hand", name = "Undertow Tideblade", sources = { [14]=180851, [15]=180851, [16]=180851 } },
            },
        },
    },
}
