-------------------------------------------------------------------------------
-- RetroRuns Data -- Stratholme - Main Gate
-- Classic dungeon, Patch 1.0  |  instanceID: 329  |  journalInstanceID: 236
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[236] = {
    kind              = "dungeon",
    instanceID        = 329,
    journalInstanceID = 236,
    name              = "Stratholme - Main Gate",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Hearthsinger Forresten",
            journalEncounterID = 443,
            achievements       = {
            },
            loot = {
                { id = 13378, slot = "Chest", name = "Songbird Blouse", sources = { [14]=4859 } },
                { id = 13383, slot = "Legs", name = "Woollies of the Prancing Minstrel", sources = { [14]=4862 } },
                { id = 13384, slot = "Waist", name = "Rainbow Girdle", sources = { [14]=4863 } },
            },
            specialLoot = {
                { id = 13379, kind = "toy", name = "Piccolo of the Flaming Fire" },
            },
        },
        {
            index              = 2,
            name               = "The Unforgiven",
            journalEncounterID = 450,
            achievements       = {
            },
            loot = {
                { id = 151404, slot = "Hands", name = "Gauntlets of Purged Sanity", sources = { [14]=89410 } },
                { id = 13404, slot = "Head", name = "Mask of the Unforgiven", sources = { [14]=4882 } },
                { id = 13405, slot = "Shoulder", name = "Wailing Nightbane Pauldrons", sources = { [14]=4883 } },
                { id = 22406, slot = "Two-Hand", name = "Redemption", sources = { [14]=8815 } },
                { id = 13408, slot = "Weapon", name = "Soul Breaker", sources = { [14]=4886 } },
                { id = 13409, slot = "Wrist", name = "Tearfall Bracers", sources = { [14]=4887 } },
            },
        },
        {
            index              = 3,
            name               = "Postmaster Malown",
            journalEncounterID = 2633,
            achievements       = {
            },
            loot = {
                { id = 13388, slot = "Chest", name = "The Postmaster's Tunic", sources = { [14]=4867 } },
                { id = 13391, slot = "Feet", name = "The Postmaster's Treads", sources = { [14]=4870 } },
                { id = 13390, slot = "Head", name = "The Postmaster's Band", sources = { [14]=4869 } },
                { id = 13389, slot = "Legs", name = "The Postmaster's Trousers", sources = { [14]=4868 } },
                { id = 13393, slot = "Two-Hand", name = "Malown's Slam", sources = { [14]=4871 } },
            },
        },
        {
            index              = 4,
            name               = "Timmy the Cruel",
            journalEncounterID = 445,
            achievements       = {
            },
            loot = {
                { id = 13402, slot = "Feet", name = "Timmy's Galoshes", sources = { [14]=4880 } },
                { id = 151403, slot = "Hands", name = "Fetid Stranglers", sources = { [14]=89409 } },
                { id = 13403, slot = "Waist", name = "Grimgore Noose", sources = { [14]=4881 } },
                { id = 13401, slot = "Weapon", name = "The Cruel Hand of Timmy", sources = { [14]=4879 } },
                { id = 13400, slot = "Wrist", name = "Vambraces of the Sadist", sources = { [14]=4878 } },
            },
        },
        {
            index              = 5,
            name               = "Commander Malor",
            journalEncounterID = 749,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 6,
            name               = "Willey Hopebreaker",
            journalEncounterID = 446,
            achievements       = {
            },
            loot = {
                { id = 13381, slot = "Feet", name = "Master Cannoneer Boots", sources = { [14]=4861 } },
                { id = 22407, slot = "Head", name = "Helm of the New Moon", sources = { [14]=8816 } },
                { id = 13380, slot = "Ranged", name = "Willey's Portable Howitzer", sources = { [14]=4860 } },
                { id = 22405, slot = "Shoulder", name = "Mantle of the Scarlet Crusade", sources = { [14]=8814 } },
                { id = 18721, slot = "Waist", name = "Barrage Girdle", sources = { [14]=7454 } },
                { id = 22404, slot = "Weapon", name = "Willey's Back Scratcher", sources = { [14]=8813 } },
            },
        },
        {
            index              = 7,
            name               = "Instructor Galford",
            journalEncounterID = 448,
            achievements       = {
            },
            loot = {
                { id = 13386, slot = "Back", name = "Archivist Cape", sources = { [14]=4865 } },
                { id = 18716, slot = "Feet", name = "Ash Covered Boots", sources = { [14]=7450 } },
                { id = 13385, slot = "Off-hand", name = "Tome of Knowledge", sources = { [14]=4864 } },
                { id = 13387, slot = "Waist", name = "Foresight Girdle", sources = { [14]=4866 } },
            },
        },
        {
            index              = 8,
            name               = "Balnazzar",
            journalEncounterID = 449,
            achievements       = {
                { id = 646, name = "Stratholme" },
                { id = 39936, name = "Stratholme (char specific hidden copy)" },
            },
            loot = {
                { id = 13369, slot = "Feet", name = "Fire Striders", sources = { [14]=4852 } },
                { id = 13359, slot = "Head", name = "Crown of Tyranny", sources = { [14]=4848 } },
                { id = 18718, slot = "Head", name = "Grand Crusader's Helm", sources = { [14]=7452 } },
                { id = 13353, slot = "Off-hand", name = "Book of the Dead", sources = { [14]=4846 } },
                { id = 18720, slot = "Shoulder", name = "Shroud of the Nathrezim", sources = { [14]=7453 } },
                { id = 13358, slot = "Shoulder", name = "Wyrmtongue Shoulders", sources = { [14]=4847 } },
                { id = 13348, slot = "Two-Hand", name = "Demonshear", sources = { [14]=4844 } },
                { id = 18717, slot = "Two-Hand", name = "Hammer of the Grand Crusader", sources = { [14]=7451 } },
                { id = 13360, slot = "Weapon", name = "Gift of the Elven Magi", sources = { [14]=4849 } },
            },
        },
    },
}
