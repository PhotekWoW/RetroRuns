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
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    timewalking       = true,

    entrance = {
        mapID = 109,
        x     = 0.7183,
        y     = 0.5482,
    },

    bosses = {
        {
            index              = 1,
            name               = "Commander Sarannis",
            journalEncounterID = 558,
            achievements       = {
            },
            loot = {
                { id = 28301, slot = "Back", name = "Sarannis' Mystic Sheen", sources = { [14]=12378, [15]=12378 }, twSource = 165690 },
                { id = 28304, slot = "Hands", name = "Prismatic Mittens of Mending", sources = { [14]=12380, [15]=12380 }, twSource = 165691 },
                { id = 28350, slot = "Head", name = "Warhelm of the Bold", sources = { [14]=12418, [15]=12418 }, twSource = 165711 },
                { id = 28347, slot = "Legs", name = "Warpscale Leggings", sources = { [14]=12415, [15]=12415 }, twSource = 165708 },
                { id = 28306, slot = "Shoulder", name = "Towering Mantle of the Hunt", sources = { [14]=12382, [15]=12382 }, twSource = 165692 },
                { id = 28311, slot = "Weapon", name = "Revenger", sources = { [14]=12387, [15]=12387 }, twSource = 165693 },
            },
        },
        {
            index              = 2,
            name               = "High Botanist Freywinn",
            journalEncounterID = 559,
            achievements       = {
            },
            loot = {
                { id = 28228, slot = "Chest", name = "Beast Lord Cuirass", sources = { [14]=12345, [15]=12345 }, twSource = 165688 },
                { id = 28318, slot = "Feet", name = "Obsidian Clodstompers", sources = { [14]=12394, [15]=12394 }, twSource = 165697 },
                { id = 28317, slot = "Hands", name = "Energis Armwraps", sources = { [14]=12393, [15]=12393 }, twSource = 165696 },
                { id = 28348, slot = "Head", name = "Moonglade Cowl", sources = { [14]=12416, [15]=12416 }, twSource = 165709 },
                { id = 28316, slot = "Off-hand", name = "Aegis of the Sunbird", sources = { [14]=12392, [15]=12392 }, twSource = 165695 },
                { id = 28315, slot = "Weapon", name = "Stormreaver Warblades", sources = { [14]=12391, [15]=12391 }, twSource = 165694 },
            },
        },
        {
            index              = 3,
            name               = "Thorngrin the Tender",
            journalEncounterID = 560,
            achievements       = {
            },
            loot = {
                { id = 28324, slot = "Hands", name = "Gauntlets of Cruel Intention", sources = { [14]=12398, [15]=12398 }, twSource = 165699 },
                { id = 28325, slot = "Two-Hand", name = "Dreamer's Dragonstaff", sources = { [14]=12399, [15]=12399 }, twSource = 165700 },
                { id = 28322, slot = "Weapon", name = "Runed Dagger of Solace", sources = { [14]=12397, [15]=12397 }, twSource = 165698 },
            },
        },
        {
            index              = 4,
            name               = "Laj",
            journalEncounterID = 561,
            achievements       = {
            },
            loot = {
                { id = 28328, slot = "Back", name = "Mithril-Bark Cloak", sources = { [14]=12400, [15]=12400 }, twSource = 165701 },
                { id = 28339, slot = "Feet", name = "Boots of the Shifting Sands", sources = { [14]=12408, [15]=12408 }, twSource = 165703 },
                { id = 28349, slot = "Head", name = "Tidefury Helm", sources = { [14]=12417, [15]=12417 }, twSource = 165710 },
                { id = 28338, slot = "Legs", name = "Devil-Stitched Leggings", sources = { [14]=12407, [15]=12407 }, twSource = 165702 },
                { id = 28340, slot = "Shoulder", name = "Mantle of Autumn", sources = { [14]=12409, [15]=12409 }, twSource = 165704 },
                { id = 27739, slot = "Shoulder", name = "Spaulders of the Righteous", sources = { [14]=12030, [15]=12030 }, twSource = 165687 },
            },
        },
        {
            index              = 5,
            name               = "Warp Splinter",
            journalEncounterID = 562,
            achievements       = {
            },
            loot = {
                { id = 28371, slot = "Back", name = "Netherfury Cape", sources = { [14]=12424, [15]=12424 }, twSource = 165713 },
                { id = 28229, slot = "Chest", name = "Incanter's Robe", sources = { [14]=12346, [15]=12346 }, twSource = 165689 },
                { id = 28342, slot = "Chest", name = "Warp-Infused Drape", sources = { [14]=12411, [15]=12411 }, twSource = 165706 },
                { id = 29258, slot = "Feet", name = "Boots of Ethereal Manipulation", sources = { [14]=13052, [15]=13052 }, twSource = 165714 },
                { id = 29262, slot = "Feet", name = "Boots of the Endless Hunt", sources = { [14]=13055, [15]=13055 }, twSource = 165715 },
                { id = 32072, slot = "Hands", name = "Gauntlets of Dissension", sources = { [14]=14749, [15]=14749 }, twSource = 165717 },
                { id = 29359, slot = "Two-Hand", name = "Feral Staff of Lashing", sources = { [14]=13102, [15]=13102 }, twSource = 165716 },
                { id = 28367, slot = "Two-Hand", name = "Greatsword of Forlorn Visions", sources = { [14]=12423, [15]=12423 }, twSource = 165712 },
                { id = 28341, slot = "Two-Hand", name = "Warpstaff of Arcanum", sources = { [14]=12410, [15]=12410 }, twSource = 165705 },
                { id = 28345, slot = "Weapon", name = "Warp Splinter's Thorn", sources = { [14]=12413, [15]=12413 }, twSource = 165707 },
            },
        },
    },
}
