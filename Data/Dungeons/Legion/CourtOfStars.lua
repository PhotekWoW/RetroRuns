-------------------------------------------------------------------------------
-- RetroRuns Data -- Court of Stars
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1571  |  journalInstanceID: 800
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[800] = {
    kind              = "dungeon",
    instanceID        = 1571,
    journalInstanceID = 800,
    name              = "Court of Stars",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    patch             = "7.0.3",

    gloryMeta = {
        id   = 11163,
        name = "Glory of the Legion Hero",
        rewardItemID       = 141217,
        rewardMountSpellID = 225765,
        rewardName         = "Leyfeather Hippogryph",
    },

    bosses = {
        {
            index              = 1,
            name               = "Patrol Captain Gerdo",
            journalEncounterID = 1718,
            achievements       = {
                { id = 10610, name = "Waiting for Gerdo", meta = true },
            },
            loot = {
                { id = 137483, slot = "Back", name = "Cape of the Duskwatch", sources = { [14]=79066, [15]=80818, [16]=79066 } },
                { id = 134415, slot = "Chest", name = "Arcanist's Resonant Robes", sources = { [14]=79062, [15]=80004, [16]=79062 } },
                { id = 137482, slot = "Feet", name = "Duskwatch Guard's Boots", sources = { [14]=79065, [15]=79985, [16]=79065 } },
                { id = 134308, slot = "Feet", name = "Manawracker Sandals", sources = { [14]=77582, [15]=77582, [16]=77582 } },
                { id = 134268, slot = "Hands", name = "Arcane Defender's Gauntlets", sources = { [14]=77552, [15]=77552, [16]=77552 } },
                { id = 137480, slot = "Hands", name = "Guileful Intruder Handguards", sources = { [14]=79063, [15]=80105, [16]=79063 } },
                { id = 134480, slot = "Shoulder", name = "Epaulets of Deceitful Intent", sources = { [14]=79064, [15]=80140, [16]=79064 } },
                { id = 134296, slot = "Wrist", name = "Ley Dragoon's Wristbraces", sources = { [14]=77570, [15]=77570, [16]=77570 } },
                { id = 134280, slot = "Wrist", name = "Swordsinger's Wristguards", sources = { [14]=77561, [15]=77561, [16]=77561 } },
            },
        },
        {
            index              = 2,
            name               = "Talixae Flamewreath",
            journalEncounterID = 1719,
            achievements       = {
            },
            loot = {
                { id = 134503, slot = "Chest", name = "Inferno Breastplate", sources = { [14]=79070, [15]=79945, [16]=79070 } },
                { id = 134385, slot = "Hands", name = "Mardum Chain Gloves", sources = { [14]=77639, [15]=77639, [16]=77639 } },
                { id = 134473, slot = "Head", name = "Collar of Fiery Allegiance", sources = { [14]=79069, [15]=80133, [16]=79069 } },
                { id = 134392, slot = "Head", name = "Netherwhisper Hood", sources = { [14]=77646, [15]=77646, [16]=77646 } },
                { id = 134460, slot = "Legs", name = "Fevermelt Legguards", sources = { [14]=79068, [15]=80085, [16]=79068 } },
                { id = 201994, slot = "Ranged", name = "Felsworn Covenant Crossbow", sources = { [14]=184048, [15]=184048, [16]=184048 }, mythicPlusOnly = true },
                { id = 134374, slot = "Shoulder", name = "Felbat Leather Pauldrons", sources = { [14]=77635, [15]=77635, [16]=77635 } },
                { id = 134360, slot = "Shoulder", name = "Portalguard Shoulders", sources = { [14]=77624, [15]=77624, [16]=77624 } },
                { id = 137488, slot = "Waist", name = "Cord of Wicked Pyromania", sources = { [14]=79067, [15]=80045, [16]=79067 } },
            },
        },
        {
            index              = 3,
            name               = "Advisor Melandrus",
            journalEncounterID = 1720,
            achievements       = {
                { id = 10611, name = "Dropping Some Eaves", meta = true },
                { id = 10816, name = "Mythic: Court of Stars" },
                { id = 60843, name = "Court of Stars" },
                { id = 60844, name = "Heroic: Court of Stars" },
                { id = 60845, name = "Mythic: Court of Stars" },
            },
            loot = {
                { id = 137498, slot = "Chest", name = "Luminous Bladesworn Hauberk", sources = { [14]=79077, [15]=80166, [16]=79077 } },
                { id = 137497, slot = "Feet", name = "Footpads of the Swift Balestra", sources = { [14]=79076, [15]=80106, [16]=79076 } },
                { id = 134298, slot = "Feet", name = "Ley Dragoon's Stompers", sources = { [14]=77572, [15]=77572, [16]=77572 } },
                { id = 134513, slot = "Head", name = "Helmet of Reverent Loyalty", sources = { [14]=79059, [15]=79955, [16]=79059 } },
                { id = 134447, slot = "Head", name = "Veil of Unseen Strikes", sources = { [14]=79072, [15]=80072, [16]=79072 } },
                { id = 134271, slot = "Legs", name = "Arcane Defender's Pants", sources = { [14]=77555, [15]=77555, [16]=77555 } },
                { id = 137496, slot = "Legs", name = "Suramar Magistrate Leggings", sources = { [14]=79075, [15]=80046, [16]=79075 } },
                { id = 134432, slot = "Shoulder", name = "Amice of the Unfurling Tempest", sources = { [14]=79071, [15]=80020, [16]=79071 } },
                { id = 201995, slot = "Two-Hand", name = "Crux of Blind Faith", sources = { [14]=184049, [15]=184049, [16]=184049 }, mythicPlusOnly = true },
                { id = 137489, slot = "Waist", name = "Arcane-Bound Gale Chain", sources = { [14]=79073, [15]=80165, [16]=79073 } },
                { id = 137499, slot = "Waist", name = "Roaring Breeze Waistguard", sources = { [14]=79078, [15]=79986, [16]=79078 } },
                { id = 134287, slot = "Waist", name = "Swordsinger's Belt", sources = { [14]=77568, [15]=77568, [16]=77568 } },
                { id = 201996, slot = "Weapon", name = "Edge of the First Blade", sources = { [14]=184050, [15]=184050, [16]=184050 }, mythicPlusOnly = true },
                { id = 134310, slot = "Wrist", name = "Manawracker Bindings", sources = { [14]=77584, [15]=77584, [16]=77584 } },
            },
            specialLoot = {
                { id = 247913, kind = "decor", name = "Ornate Suramar Table", decorID = 4027 },
            },
        },
    },
}
