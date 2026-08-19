-------------------------------------------------------------------------------
-- RetroRuns Data -- Gate of the Setting Sun
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 962  |  journalInstanceID: 303
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[303] = {
    kind              = "dungeon",
    instanceID        = 962,
    journalInstanceID = 303,
    name              = "Gate of the Setting Sun",
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
            name               = "Saboteur Kip'tilak",
            journalEncounterID = 655,
            achievements       = {
                { id = 6479, name = "Bomberman", meta = true },
            },
            loot = {
                { id = 144018, slot = "Head", name = "Fallout-Filtering Hood", sources = { [14]=84353 } },
                { id = 144134, slot = "Waist", name = "Grenadier's Belt", sources = { [14]=84425 } },
                { id = 144100, slot = "Wrist", name = "Saboteur's Stabilizing Bracers", sources = { [14]=84406 } },
            },
        },
        {
            index              = 2,
            name               = "Striker Ga'dok",
            journalEncounterID = 675,
            achievements       = {
            },
            loot = {
                { id = 143983, slot = "Feet", name = "Airstream Treads", sources = { [14]=84318 } },
                { id = 144137, slot = "Hands", name = "Bomber's Precision Gloves", sources = { [14]=84426 } },
                { id = 143980, slot = "Shoulder", name = "Acid-Scarred Spaulders", sources = { [14]=84315 } },
                { id = 144095, slot = "Waist", name = "Impaler's Girdle", sources = { [14]=84401 } },
            },
        },
        {
            index              = 3,
            name               = "Commander Ri'mok",
            journalEncounterID = 676,
            achievements       = {
            },
            loot = {
                { id = 144019, slot = "Head", name = "Swarmcall Helm", sources = { [14]=84354 } },
                { id = 143982, slot = "Legs", name = "Leggings of the Frenzy", sources = { [14]=84317 } },
                { id = 144098, slot = "Weapon", name = "Mantid Trochanter", sources = { [14]=84404 } },
                { id = 144138, slot = "Wrist", name = "Ri'mok's Shattered Scale", sources = { [14]=84427 } },
            },
        },
        {
            index              = 4,
            name               = "Raigonn",
            journalEncounterID = 649,
            achievements       = {
                { id = 6759, name = "Heroic: Gate of the Setting Sun" },
                { id = 6945, name = "Mantid Swarm" },
                { id = 10010, name = "Gate of the Setting Sun" },
                { id = 6476, name = "Conscriptinator", meta = true },
                { id = 6894, name = "Gate of the Setting Sun Challenger" },
                { id = 6905, name = "Gate of the Setting Sun: Bronze" },
                { id = 6906, name = "Gate of the Setting Sun: Silver" },
                { id = 6907, name = "Gate of the Setting Sun: Gold" },
                { id = 19902, name = "Gate of the Setting Sun" },
                { id = 19903, name = "Heroic: Gate of the Setting Sun" },
            },
            loot = {
                { id = 144141, slot = "Back", name = "Drape of the Screeching Swarm", sources = { [14]=84429 } },
                { id = 143955, slot = "Chest", name = "Swarmbringer Chestguard", sources = { [14]=84290 } },
                { id = 143984, slot = "Feet", name = "Treads of Fixation", sources = { [14]=84319 } },
                { id = 144105, slot = "Hands", name = "Hive Protector's Gauntlets", sources = { [14]=84410 } },
                { id = 143977, slot = "Legs", name = "Wall-Breaker Legguards", sources = { [14]=84312 } },
                { id = 144140, slot = "Off-hand", name = "Impervious Carapace", sources = { [14]=84428 } },
                { id = 144104, slot = "Off-hand", name = "Shield of the Protectorate", sources = { [14]=84409 } },
                { id = 144218, slot = "Ranged", name = "Klatith, Fangs of the Swarm", sources = { [14]=84486 } },
                { id = 143991, slot = "Shoulder", name = "Shoulders of Engulfing Winds", sources = { [14]=84326 } },
                { id = 144101, slot = "Weapon", name = "Carapace Breaker", sources = { [14]=84407 } },
                { id = 144142, slot = "Wrist", name = "Frenzyswarm Bracers", sources = { [14]=84430 } },
            },
        },
    },
}
