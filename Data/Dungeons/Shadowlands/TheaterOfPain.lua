-------------------------------------------------------------------------------
-- RetroRuns Data -- Theater of Pain
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2293  |  journalInstanceID: 1187
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1187] = {
    kind              = "dungeon",
    instanceID        = 2293,
    journalInstanceID = 1187,
    name              = "Theater of Pain",
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
            name               = "An Affront of Challengers",
            journalEncounterID = 2397,
            achievements       = {
            },
            loot = {
                { id = 178795, slot = "Chest", name = "Vest of Concealed Secrets", sources = { [14]=111503 } },
                { id = 178799, slot = "Head", name = "Amphitheater Stalker's Hood", sources = { [14]=111507 } },
                { id = 178800, slot = "Legs", name = "Galvanized Oxxein Legguards", sources = { [14]=111508 } },
                { id = 178803, slot = "Shoulder", name = "Plague-Licked Amice", sources = { [14]=111511 } },
                { id = 178866, slot = "Two-Hand", name = "Dessia's Decimating Decapitator", sources = { [14]=111561 } },
            },
        },
        {
            index              = 2,
            name               = "Gorechop",
            journalEncounterID = 2401,
            achievements       = {
                { id = 14607, name = "Fresh Meat!", meta = true },
            },
            loot = {
                { id = 178793, slot = "Chest", name = "Abdominal Securing Chestguard", sources = { [14]=111501 } },
                { id = 178798, slot = "Hands", name = "Grips of Overwhelming Beatings", sources = { [14]=111506 } },
                { id = 178806, slot = "Wrist", name = "Contaminated Gauze Wristwraps", sources = { [14]=111514 } },
            },
        },
        {
            index              = 3,
            name               = "Xav the Unfallen",
            journalEncounterID = 2390,
            achievements       = {
            },
            loot = {
                { id = 178794, slot = "Chest", name = "Triumphant Combatant's Chainmail", sources = { [14]=111502 } },
                { id = 178801, slot = "Legs", name = "Fearless Challenger's Leggings", sources = { [14]=111509 } },
                { id = 178865, slot = "Two-Hand", name = "Xav's Pike of Authority", sources = { [14]=111560 } },
                { id = 178789, slot = "Weapon", name = "Fleshcrafter's Knife", sources = { [14]=111499 } },
                { id = 178864, slot = "Weapon", name = "Gorebound Predator's Gavel", sources = { [14]=111559 } },
                { id = 178863, slot = "Weapon", name = "Gorestained Cleaver", sources = { [14]=111558 } },
                { id = 178807, slot = "Wrist", name = "Pit Fighter's Wristguards", sources = { [14]=111515 } },
            },
        },
        {
            index              = 4,
            name               = "Kul'tharok",
            journalEncounterID = 2389,
            achievements       = {
            },
            loot = {
                { id = 178792, slot = "Chest", name = "Soulsewn Vestments", sources = { [14]=111500 } },
                { id = 178796, slot = "Feet", name = "Boots of Shuddering Matter", sources = { [14]=111504 } },
                { id = 178805, slot = "Waist", name = "Girdle of Shattered Dreams", sources = { [14]=111513 } },
            },
        },
        {
            index              = 5,
            name               = "Mordretha, the Endless Empress",
            journalEncounterID = 2417,
            achievements       = {
                { id = 14372, name = "Theater of Pain" },
                { id = 14416, name = "Heroic: Theater of Pain" },
                { id = 14417, name = "Mythic: Theater of Pain" },
                { id = 14533, name = "Royal Rumble", meta = true },
                { id = 14297, name = "Three Choose One", meta = true },
            },
            loot = {
                { id = 178797, slot = "Feet", name = "Vanquished Usurper's Footpads", sources = { [14]=111505 } },
                { id = 178867, slot = "Off-hand", name = "Barricade of the Endless Empire", sources = { [14]=111562 } },
                { id = 178868, slot = "Off-hand", name = "Deathwalker's Promise", sources = { [14]=111563 } },
                { id = 178802, slot = "Shoulder", name = "Unyielding Combatant's Pauldrons", sources = { [14]=111510 } },
                { id = 178804, slot = "Waist", name = "Fallen Empress's Cord", sources = { [14]=111512 } },
            },
        },
    },
}
