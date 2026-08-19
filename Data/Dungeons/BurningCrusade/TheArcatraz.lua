-------------------------------------------------------------------------------
-- RetroRuns Data -- The Arcatraz
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 552  |  journalInstanceID: 254
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[254] = {
    kind              = "dungeon",
    instanceID        = 552,
    journalInstanceID = 254,
    name              = "The Arcatraz",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Zereketh the Unbound",
            journalEncounterID = 548,
            achievements       = {
            },
            loot = {
                { id = 28373, slot = "Back", name = "Cloak of Scintillating Auras", sources = { [14]=12425 } },
                { id = 28384, slot = "Feet", name = "Outland Striders", sources = { [14]=12434 } },
                { id = 28396, slot = "Hands", name = "Gloves of the Unbound", sources = { [14]=12442 } },
                { id = 28415, slot = "Head", name = "Hood of Oblivion", sources = { [14]=12459 } },
                { id = 28374, slot = "Shoulder", name = "Mana-Sphere Shoulderguards", sources = { [14]=12426 } },
                { id = 28375, slot = "Waist", name = "Rubium War-Girdle", sources = { [14]=12427 } },
            },
        },
        {
            index              = 2,
            name               = "Dalliah the Doomsayer",
            journalEncounterID = 549,
            achievements       = {
            },
            loot = {
                { id = 28384, slot = "Feet", name = "Outland Striders", sources = { [14]=12434 } },
                { id = 28390, slot = "Hands", name = "Thatia's Self-Correcting Gauntlets", sources = { [14]=12438 } },
                { id = 28414, slot = "Head", name = "Helm of Assassination", sources = { [14]=12458 } },
                { id = 28387, slot = "Off-hand", name = "Lamp of Peaceful Repose", sources = { [14]=12437 } },
                { id = 28386, slot = "Ranged", name = "Nether Core's Control Rod", sources = { [14]=12436 } },
                { id = 28416, slot = "Weapon", name = "Hungering Spineripper", sources = { [14]=12460 } },
                { id = 28392, slot = "Weapon", name = "Reflex Blades", sources = { [14]=12440 } },
            },
        },
        {
            index              = 3,
            name               = "Wrath-Scryer Soccothrates",
            journalEncounterID = 550,
            achievements       = {
            },
            loot = {
                { id = 28403, slot = "Chest", name = "Doomplate Chestguard", sources = { [14]=12448 } },
                { id = 28391, slot = "Chest", name = "Worldfire Chestguard", sources = { [14]=12439 } },
                { id = 28413, slot = "Head", name = "Hallowed Crown", sources = { [14]=12457 } },
                { id = 28397, slot = "Ranged", name = "Emberhawk Crossbow", sources = { [14]=12443 } },
                { id = 28393, slot = "Two-Hand", name = "Warmaul of Infused Light", sources = { [14]=12441 } },
                { id = 28398, slot = "Waist", name = "The Sleeper's Cord", sources = { [14]=12444 } },
            },
        },
        {
            index              = 4,
            name               = "Harbinger Skyriss",
            journalEncounterID = 551,
            achievements       = {
                { id = 660, name = "The Arcatraz" },
                { id = 681, name = "Heroic: The Arcatraz" },
            },
            loot = {
                { id = 28205, slot = "Chest", name = "Breastplate of the Bold", sources = { [14]=12327 } },
                { id = 28231, slot = "Chest", name = "Tidefury Chestpiece", sources = { [14]=12348 } },
                { id = 29248, slot = "Feet", name = "Shadowstep Striders", sources = { [14]=13043 } },
                { id = 28406, slot = "Feet", name = "Sigil-Laced Boots", sources = { [14]=12451 } },
                { id = 28412, slot = "Off-hand", name = "Lamp of Peaceful Radiance", sources = { [14]=12456 } },
                { id = 29241, slot = "Waist", name = "Belt of Depravity", sources = { [14]=13036 } },
                { id = 29360, slot = "Weapon", name = "Vileblade of the Betrayer", sources = { [14]=13103 } },
                { id = 29252, slot = "Wrist", name = "Bracers of Dignity", sources = { [14]=13047 } },
            },
        },
    },
}
