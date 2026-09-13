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
    availableDifficulties = { 14, 15, 16 },
    patch             = "9.0.1",
    timewalking       = true,

    entrance = {
        mapID = 1525,
        x     = 0.7870,
        y     = 0.4939,
    },

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
            scenarioCriteriaID = 48110,
            achievements       = {
            },
            loot = {
                { id = 178813, slot = "Chest", name = "Sinlight Shroud", sources = { [14]=111517, [15]=111517, [16]=111517 } },
                { id = 246273, slot = "Chest", name = "Vest of Refracted Shadows", sources = { [14]=293020, [15]=293020, [16]=293020 } },
                { id = 178830, slot = "Feet", name = "Shardskin Sabatons", sources = { [14]=111530, [15]=111530, [16]=111530 } },
                { id = 178817, slot = "Head", name = "Hood of Refracted Shadows", sources = { [14]=111521, [15]=111521, [16]=111521 } },
                { id = 178818, slot = "Legs", name = "Halkias's Towering Pillars", sources = { [14]=111522, [15]=111522, [16]=111522 } },
                { id = 246276, slot = "Shoulder", name = "Sinlight Shoulderpads", sources = { [14]=293023, [15]=293023, [16]=293023 } },
            },
        },
        {
            index              = 2,
            name               = "Echelon",
            journalEncounterID = 2387,
            achievements       = {
                { id = 14284, name = "Breaking Bad", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 178815, slot = "Chest", name = "Soaring Decimator's Hauberk", sources = { [14]=111519, [15]=111519, [16]=111519 } },
                { id = 178833, slot = "Hands", name = "Stonefiend Shaper's Mitts", sources = { [14]=111533, [15]=111533, [16]=111533 } },
                { id = 178812, slot = "Head", name = "Wing Commander's Helmet", sources = { [14]=111516, [15]=111516, [16]=111516 } },
                { id = 178819, slot = "Legs", name = "Skyterror's Stonehide Leggings", sources = { [14]=111523, [15]=111523, [16]=111523 } },
                { id = 178834, slot = "Weapon", name = "Stoneguardian's Morningstar", sources = { [14]=111534, [15]=111534, [16]=111534 } },
            },
        },
        {
            index              = 3,
            name               = "High Adjudicator Aleez",
            journalEncounterID = 2411,
            achievements       = {
            },
            loot = {
                { id = 178814, slot = "Chest", name = "Breastplate of Otherworldly Influence", sources = { [14]=111518, [15]=111518, [16]=111518 } },
                { id = 178832, slot = "Hands", name = "Gloves of Haunting Fixation", sources = { [14]=111532, [15]=111532, [16]=111532 } },
                { id = 246284, slot = "Off-hand", name = "Nathrian Reliquary", sources = { [15]=293030, [16]=293030 } },
                { id = 178828, slot = "Off-hand", name = "Nathrian Tabernacle", sources = { [14]=111528, [15]=111528, [16]=111528 } },
                { id = 178821, slot = "Shoulder", name = "Mantle of Ephemeral Visages", sources = { [14]=111525, [15]=111525, [16]=111525 } },
                { id = 178822, slot = "Waist", name = "Cord of the Dark Word", sources = { [14]=111526, [15]=111526, [16]=111526 } },
            },
        },
        {
            index              = 4,
            name               = "Lord Chamberlain",
            journalEncounterID = 2413,
            achievements       = {
                { id = 14352, name = "Nobody Puts Denathrius in a Corner", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 178831, slot = "Feet", name = "Slippers of Leavened Station", sources = { [14]=111531, [15]=111531, [16]=111531 } },
                { id = 178816, slot = "Head", name = "Nathrian Usurper's Mask", sources = { [14]=111520, [15]=111520, [16]=111520 } },
                { id = 178820, slot = "Shoulder", name = "Pauldrons of Unleashed Pride", sources = { [14]=111524, [15]=111524, [16]=111524 } },
                { id = 246286, slot = "Shoulder", name = "Spaulders of Unleashed Pride", sources = { [15]=293032, [16]=293032 } },
                { id = 178829, slot = "Two-Hand", name = "Nathrian Ferula", sources = { [14]=111529, [15]=111529, [16]=111529 } },
                { id = 178823, slot = "Waist", name = "Waistcord of Dark Devotion", sources = { [14]=111527, [15]=111527, [16]=111527 } },
            },
        },
    },
}
