-------------------------------------------------------------------------------
-- RetroRuns Data -- The Black Morass
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 269  |  journalInstanceID: 255
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[255] = {
    kind              = "dungeon",
    instanceID        = 269,
    journalInstanceID = 255,
    name              = "The Black Morass",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Chrono Lord Deja",
            journalEncounterID = 552,
            achievements       = {
            },
            loot = {
                { id = 27988, slot = "Back", name = "Burnoose of Shifting Ages", sources = { [14]=12197 } },
                { id = 27993, slot = "Head", name = "Mask of Inner Fire", sources = { [14]=12198 } },
                { id = 27977, slot = "Legs", name = "Legplates of the Bold", sources = { [14]=12191 } },
                { id = 27873, slot = "Legs", name = "Moonglade Pants", sources = { [14]=12118 } },
                { id = 27987, slot = "Ranged", name = "Melmorta's Twilight Longbow", sources = { [14]=12196 } },
                { id = 27994, slot = "Shoulder", name = "Mantle of Three Terrors", sources = { [14]=12199 } },
                { id = 27995, slot = "Shoulder", name = "Sun-Gilded Shouldercaps", sources = { [14]=12200 } },
            },
        },
        {
            index              = 2,
            name               = "Temporus",
            journalEncounterID = 553,
            achievements       = {
            },
            loot = {
                { id = 28186, slot = "Chest", name = "Laughing Skull Battle-Harness", sources = { [14]=12309 } },
                { id = 27509, slot = "Hands", name = "Handgrips of Assassination", sources = { [14]=11943 } },
                { id = 28185, slot = "Legs", name = "Khadgar's Kilt of Abjuration", sources = { [14]=12308 } },
                { id = 28187, slot = "Off-hand", name = "Star-Heart Lamp", sources = { [14]=12310 } },
                { id = 28033, slot = "Two-Hand", name = "Epoch-Mender", sources = { [14]=12230 } },
                { id = 29356, slot = "Two-Hand", name = "Quantum Blade", sources = { [14]=13100 } },
                { id = 28184, slot = "Weapon", name = "Millennium Blade", sources = { [14]=12307 } },
            },
        },
        {
            index              = 3,
            name               = "Aeonus",
            journalEncounterID = 554,
            achievements       = {
                { id = 676, name = "Heroic: Opening of the Dark Portal" },
            },
            loot = {
                { id = 28206, slot = "Head", name = "Cowl of the Guiltless", sources = { [14]=12328 } },
                { id = 28192, slot = "Head", name = "Helm of Desolation", sources = { [14]=12314 } },
                { id = 28193, slot = "Head", name = "Mana-Etched Crown", sources = { [14]=12315 } },
                { id = 30531, slot = "Legs", name = "Breeches of the Occultist", sources = { [14]=13804 } },
                { id = 27839, slot = "Legs", name = "Legplates of the Righteous", sources = { [14]=12098 } },
                { id = 28207, slot = "Shoulder", name = "Pauldrons of the Crimson Flight", sources = { [14]=12329 } },
                { id = 28188, slot = "Two-Hand", name = "Bloodfire Greatstaff", sources = { [14]=12311 } },
                { id = 29253, slot = "Waist", name = "Girdle of Valorous Deeds", sources = { [14]=13048 } },
                { id = 29247, slot = "Waist", name = "Girdle of the Deathdealer", sources = { [14]=13042 } },
                { id = 28189, slot = "Weapon", name = "Latro's Shifting Sword", sources = { [14]=12312 } },
                { id = 28194, slot = "Wrist", name = "Primal Surge Bracers", sources = { [14]=12316 } },
            },
        },
    },
}
