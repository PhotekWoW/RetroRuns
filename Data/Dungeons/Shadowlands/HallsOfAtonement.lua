-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Atonement
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2287  |  journalInstanceID: 1185
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1185] = {
    kind              = "dungeon",
    instanceID        = 2287,
    journalInstanceID = 1185,
    name              = "Halls of Atonement",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    patch             = "9.0.1",

    gloryMeta = {
        id   = 14322,
        name = "Glory of the Shadowlands Hero",
        rewardItemID       = 184183,
        rewardMountSpellID = 344659,
        rewardName         = "Voracious Gorger",
    },

    bosses = {
        {
            index              = 1,
            name               = "Halkias, the Sin-Stained Goliath",
            journalEncounterID = 2406,
            achievements       = {
            },
            loot = {
                { id = 178813, slot = "Chest", name = "Sinlight Shroud", sources = { [14]=111517 } },
                { id = 246273, slot = "Chest", name = "Vest of Refracted Shadows", sources = { [14]=293020 } },
                { id = 178830, slot = "Feet", name = "Shardskin Sabatons", sources = { [14]=111530 } },
                { id = 178817, slot = "Head", name = "Hood of Refracted Shadows", sources = { [14]=111521 } },
                { id = 178818, slot = "Legs", name = "Halkias's Towering Pillars", sources = { [14]=111522 } },
                { id = 246276, slot = "Shoulder", name = "Sinlight Shoulderpads", sources = { [14]=293023 } },
            },
        },
        {
            index              = 2,
            name               = "Echelon",
            journalEncounterID = 2387,
            achievements       = {
                { id = 14284, name = "Breaking Bad", meta = true },
            },
            loot = {
                { id = 178815, slot = "Chest", name = "Soaring Decimator's Hauberk", sources = { [14]=111519 } },
                { id = 178833, slot = "Hands", name = "Stonefiend Shaper's Mitts", sources = { [14]=111533 } },
                { id = 178812, slot = "Head", name = "Wing Commander's Helmet", sources = { [14]=111516 } },
                { id = 178819, slot = "Legs", name = "Skyterror's Stonehide Leggings", sources = { [14]=111523 } },
                { id = 178834, slot = "Weapon", name = "Stoneguardian's Morningstar", sources = { [14]=111534 } },
            },
        },
        {
            index              = 3,
            name               = "High Adjudicator Aleez",
            journalEncounterID = 2411,
            achievements       = {
            },
            loot = {
                { id = 178814, slot = "Chest", name = "Breastplate of Otherworldly Influence", sources = { [14]=111518 } },
                { id = 178832, slot = "Hands", name = "Gloves of Haunting Fixation", sources = { [14]=111532 } },
                { id = 246284, slot = "Off-hand", name = "Nathrian Reliquary", sources = { [14]=293030 } },
                { id = 178828, slot = "Off-hand", name = "Nathrian Tabernacle", sources = { [14]=111528 } },
                { id = 178821, slot = "Shoulder", name = "Mantle of Ephemeral Visages", sources = { [14]=111525 } },
                { id = 178822, slot = "Waist", name = "Cord of the Dark Word", sources = { [14]=111526 } },
            },
        },
        {
            index              = 4,
            name               = "Lord Chamberlain",
            journalEncounterID = 2413,
            achievements       = {
                { id = 14352, name = "Nobody Puts Denathrius in a Corner", meta = true },
                { id = 14370, name = "Halls of Atonement" },
                { id = 14410, name = "Heroic: Halls of Atonement" },
                { id = 14411, name = "Mythic: Halls of Atonement" },
            },
            loot = {
                { id = 178831, slot = "Feet", name = "Slippers of Leavened Station", sources = { [14]=111531 } },
                { id = 178816, slot = "Head", name = "Nathrian Usurper's Mask", sources = { [14]=111520 } },
                { id = 178820, slot = "Shoulder", name = "Pauldrons of Unleashed Pride", sources = { [14]=111524 } },
                { id = 246286, slot = "Shoulder", name = "Spaulders of Unleashed Pride", sources = { [14]=293032 } },
                { id = 178829, slot = "Two-Hand", name = "Nathrian Ferula", sources = { [14]=111529 } },
                { id = 178823, slot = "Waist", name = "Waistcord of Dark Devotion", sources = { [14]=111527 } },
            },
        },
    },
}
