-------------------------------------------------------------------------------
-- RetroRuns Data -- The Botanica
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 553  |  journalInstanceID: 257
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[257] = {
    kind              = "dungeon",
    instanceID        = 553,
    journalInstanceID = 257,
    name              = "The Botanica",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Commander Sarannis",
            journalEncounterID = 558,
            achievements       = {
            },
            loot = {
                { id = 28301, slot = "Back", name = "Sarannis' Mystic Sheen", sources = { [14]=12378 } },
                { id = 28304, slot = "Hands", name = "Prismatic Mittens of Mending", sources = { [14]=12380 } },
                { id = 28350, slot = "Head", name = "Warhelm of the Bold", sources = { [14]=12418 } },
                { id = 28347, slot = "Legs", name = "Warpscale Leggings", sources = { [14]=12415 } },
                { id = 28306, slot = "Shoulder", name = "Towering Mantle of the Hunt", sources = { [14]=12382 } },
                { id = 28311, slot = "Weapon", name = "Revenger", sources = { [14]=12387 } },
            },
        },
        {
            index              = 2,
            name               = "High Botanist Freywinn",
            journalEncounterID = 559,
            achievements       = {
            },
            loot = {
                { id = 28228, slot = "Chest", name = "Beast Lord Cuirass", sources = { [14]=12345 } },
                { id = 28318, slot = "Feet", name = "Obsidian Clodstompers", sources = { [14]=12394 } },
                { id = 28317, slot = "Hands", name = "Energis Armwraps", sources = { [14]=12393 } },
                { id = 28348, slot = "Head", name = "Moonglade Cowl", sources = { [14]=12416 } },
                { id = 28316, slot = "Off-hand", name = "Aegis of the Sunbird", sources = { [14]=12392 } },
                { id = 28315, slot = "Weapon", name = "Stormreaver Warblades", sources = { [14]=12391 } },
            },
        },
        {
            index              = 3,
            name               = "Thorngrin the Tender",
            journalEncounterID = 560,
            achievements       = {
            },
            loot = {
                { id = 28324, slot = "Hands", name = "Gauntlets of Cruel Intention", sources = { [14]=12398 } },
                { id = 28325, slot = "Two-Hand", name = "Dreamer's Dragonstaff", sources = { [14]=12399 } },
                { id = 28322, slot = "Weapon", name = "Runed Dagger of Solace", sources = { [14]=12397 } },
            },
        },
        {
            index              = 4,
            name               = "Laj",
            journalEncounterID = 561,
            achievements       = {
            },
            loot = {
                { id = 28328, slot = "Back", name = "Mithril-Bark Cloak", sources = { [14]=12400 } },
                { id = 28339, slot = "Feet", name = "Boots of the Shifting Sands", sources = { [14]=12408 } },
                { id = 28349, slot = "Head", name = "Tidefury Helm", sources = { [14]=12417 } },
                { id = 28338, slot = "Legs", name = "Devil-Stitched Leggings", sources = { [14]=12407 } },
                { id = 28340, slot = "Shoulder", name = "Mantle of Autumn", sources = { [14]=12409 } },
                { id = 27739, slot = "Shoulder", name = "Spaulders of the Righteous", sources = { [14]=12030 } },
            },
        },
        {
            index              = 5,
            name               = "Warp Splinter",
            journalEncounterID = 562,
            achievements       = {
                { id = 659, name = "The Botanica" },
                { id = 680, name = "Heroic: The Botanica" },
            },
            loot = {
                { id = 28371, slot = "Back", name = "Netherfury Cape", sources = { [14]=12424 } },
                { id = 28229, slot = "Chest", name = "Incanter's Robe", sources = { [14]=12346 } },
                { id = 28342, slot = "Chest", name = "Warp-Infused Drape", sources = { [14]=12411 } },
                { id = 29258, slot = "Feet", name = "Boots of Ethereal Manipulation", sources = { [14]=13052 } },
                { id = 29262, slot = "Feet", name = "Boots of the Endless Hunt", sources = { [14]=13055 } },
                { id = 32072, slot = "Hands", name = "Gauntlets of Dissension", sources = { [14]=14749 } },
                { id = 29359, slot = "Two-Hand", name = "Feral Staff of Lashing", sources = { [14]=13102 } },
                { id = 28367, slot = "Two-Hand", name = "Greatsword of Forlorn Visions", sources = { [14]=12423 } },
                { id = 28341, slot = "Two-Hand", name = "Warpstaff of Arcanum", sources = { [14]=12410 } },
                { id = 28345, slot = "Weapon", name = "Warp Splinter's Thorn", sources = { [14]=12413 } },
            },
        },
    },
}
