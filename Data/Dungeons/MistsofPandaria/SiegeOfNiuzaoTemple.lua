-------------------------------------------------------------------------------
-- RetroRuns Data -- Siege of Niuzao Temple
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 1011  |  journalInstanceID: 324
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[324] = {
    kind              = "dungeon",
    instanceID        = 1011,
    journalInstanceID = 324,
    name              = "Siege of Niuzao Temple",
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
            name               = "Vizier Jin'bak",
            journalEncounterID = 693,
            achievements       = {
            },
            loot = {
                { id = 144022, slot = "Head", name = "Hood of Viridian Residue", sources = { [14]=84357 } },
                { id = 143996, slot = "Legs", name = "Sap-Encrusted Legplates", sources = { [14]=84331 } },
                { id = 144163, slot = "Waist", name = "Girdle of Soothing Detonation", sources = { [14]=84440 } },
            },
        },
        {
            index              = 2,
            name               = "Commander Vo'jak",
            journalEncounterID = 738,
            achievements       = {
                { id = 6688, name = "Where's My Air Support?", meta = true },
            },
            loot = {
                { id = 143963, slot = "Chest", name = "Chestwrap of Arcing Flame", sources = { [14]=84298 } },
                { id = 144166, slot = "Hands", name = "Archer's Precision Grips", sources = { [14]=84443 } },
                { id = 144023, slot = "Head", name = "Sightfinder Helm", sources = { [14]=84358 } },
                { id = 144164, slot = "Weapon", name = "Siege-Captain's Scimitar", sources = { [14]=84441 } },
                { id = 144165, slot = "Wrist", name = "Bombardment Bracers", sources = { [14]=84442 } },
            },
        },
        {
            index              = 3,
            name               = "General Pa'valak",
            journalEncounterID = 692,
            achievements       = {
                { id = 6485, name = "Return to Sender", meta = true },
            },
            loot = {
                { id = 144170, slot = "Back", name = "Aerial Bombardment Cloak", sources = { [14]=84447 } },
                { id = 144169, slot = "Hands", name = "Breezebinder Handwraps", sources = { [14]=84446 } },
                { id = 144167, slot = "Ranged", name = "Tempestuous Longbow", sources = { [14]=84444 } },
                { id = 144168, slot = "Wrist", name = "Siegeworn Bracers", sources = { [14]=84445 } },
            },
        },
        {
            index              = 4,
            name               = "Wing Leader Ner'onok",
            journalEncounterID = 727,
            achievements       = {
                { id = 6763, name = "Heroic: Siege of Niuzao Temple" },
                { id = 10011, name = "Siege of Niuzao Temple" },
                { id = 6822, name = "Run with the Wind", meta = true },
                { id = 6898, name = "Siege of Niuzao Temple Challenger" },
                { id = 6917, name = "Siege of Niuzao Temple: Bronze" },
                { id = 6918, name = "Siege of Niuzao Temple: Silver" },
                { id = 6919, name = "Siege of Niuzao Temple: Gold" },
                { id = 19900, name = "Siege of Niuzao Temple" },
                { id = 19901, name = "Heroic: Siege of Niuzao Temple" },
            },
            loot = {
                { id = 143964, slot = "Chest", name = "Galedodger Chestguard", sources = { [14]=84299 } },
                { id = 144000, slot = "Feet", name = "Airbender Sandals", sources = { [14]=84335 } },
                { id = 143997, slot = "Feet", name = "Anchoring Sabatons", sources = { [14]=84332 } },
                { id = 144025, slot = "Head", name = "Breezeswept Hood", sources = { [14]=84360 } },
                { id = 144024, slot = "Head", name = "Windblast Helm", sources = { [14]=84359 } },
                { id = 143998, slot = "Shoulder", name = "Spaulders of Immovable Stone", sources = { [14]=84333 } },
                { id = 143999, slot = "Shoulder", name = "Whisperwind Spaulders", sources = { [14]=84334 } },
                { id = 144172, slot = "Two-Hand", name = "Gustwalker Staff", sources = { [14]=84449 } },
                { id = 144173, slot = "Waist", name = "Belt of Totemic Binding", sources = { [14]=84450 } },
                { id = 144171, slot = "Weapon", name = "Ner'onok's Razor Katar", sources = { [14]=84448 } },
                { id = 144219, slot = "Weapon", name = "Tolakesh, Horn of the Black Ox", sources = { [14]=84487 } },
            },
        },
    },
}
