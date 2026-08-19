-------------------------------------------------------------------------------
-- RetroRuns Data -- The Temple of Atal'hakkar
-- Classic dungeon, Patch 1.0  |  instanceID: 109  |  journalInstanceID: 237
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[237] = {
    kind              = "dungeon",
    instanceID        = 109,
    journalInstanceID = 237,
    name              = "The Temple of Atal'hakkar",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Avatar of Hakkar",
            journalEncounterID = 457,
            achievements       = {
            },
            loot = {
                { id = 10843, slot = "Back", name = "Featherskin Cape", sources = { [14]=4119 } },
                { id = 12462, slot = "Chest", name = "Embrace of the Wind Serpent", sources = { [14]=4435 } },
                { id = 10845, slot = "Chest", name = "Warrior's Embrace", sources = { [14]=4121 } },
                { id = 10846, slot = "Feet", name = "Bloodshot Greaves", sources = { [14]=4122 } },
                { id = 10842, slot = "Legs", name = "Windscale Sarong", sources = { [14]=4118 } },
                { id = 10844, slot = "Two-Hand", name = "Spire of Hakkar", sources = { [14]=4120 } },
                { id = 10838, slot = "Weapon", name = "Might of Hakkar", sources = { [14]=4117 } },
            },
        },
        {
            index              = 2,
            name               = "Jammal'an the Prophet",
            journalEncounterID = 458,
            achievements       = {
            },
            loot = {
                { id = 12465, slot = "Back", name = "Nightfall Drape", sources = { [14]=4438 } },
                { id = 10806, slot = "Chest", name = "Vestments of the Atal'ai Prophet", sources = { [14]=4103 } },
                { id = 10808, slot = "Hands", name = "Gloves of the Atal'ai Prophet", sources = { [14]=4105 } },
                { id = 10807, slot = "Legs", name = "Kilt of the Atal'ai Prophet", sources = { [14]=4104 } },
                { id = 10803, slot = "Weapon", name = "Blade of the Wretched", sources = { [14]=4100 } },
                { id = 10805, slot = "Weapon", name = "Eater of the Dead", sources = { [14]=4102 } },
                { id = 10804, slot = "Weapon", name = "Fist of the Damned", sources = { [14]=4101 } },
            },
        },
        {
            index              = 3,
            name               = "Wardens of the Dream",
            journalEncounterID = 459,
            achievements       = {
            },
            loot = {
                { id = 12464, slot = "Hands", name = "Bloodfire Talons", sources = { [14]=4437 } },
                { id = 10796, slot = "Off-hand", name = "Drakestone", sources = { [14]=4093 } },
                { id = 12463, slot = "Two-Hand", name = "Drakefang Butcher", sources = { [14]=4436 } },
                { id = 12243, slot = "Two-Hand", name = "Smoldering Claw", sources = { [14]=4368 } },
                { id = 12466, slot = "Waist", name = "Dawnspire Cord", sources = { [14]=4439 } },
                { id = 10797, slot = "Weapon", name = "Firebreather", sources = { [14]=4094 } },
            },
        },
        {
            index              = 4,
            name               = "Shade of Eranikus",
            journalEncounterID = 463,
            achievements       = {
            },
            loot = {
                { id = 10833, slot = "Head", name = "Horns of Eranikus", sources = { [14]=4113 } },
                { id = 10835, slot = "Off-hand", name = "Crest of Supremacy", sources = { [14]=4114 } },
                { id = 10836, slot = "Ranged", name = "Rod of Corrosion", sources = { [14]=4115 } },
                { id = 10828, slot = "Weapon", name = "Dire Nail", sources = { [14]=4112 } },
                { id = 10847, slot = "Weapon", name = "Dragon's Call", sources = { [14]=4123 } },
                { id = 10837, slot = "Weapon", name = "Tooth of Eranikus", sources = { [14]=4116 } },
            },
        },
    },
}
