-------------------------------------------------------------------------------
-- RetroRuns Data -- Temple of Sethraliss
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1877  |  journalInstanceID: 1030
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1030] = {
    kind              = "dungeon",
    instanceID        = 1877,
    journalInstanceID = 1030,
    name              = "Temple of Sethraliss",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.0.1",

    bosses = {
        {
            index              = 1,
            name               = "Adderis and Aspix",
            journalEncounterID = 2142,
            achievements       = {
            },
            loot = {
                { id = 159388, slot = "Feet", name = "Sabatons of Coruscating Energy", sources = { [14]=95171, [15]=95172, [16]=98423 } },
                { id = 159259, slot = "Feet", name = "Sandswept Sandals", sources = { [14]=95004, [15]=95005, [16]=95570 } },
                { id = 159329, slot = "Legs", name = "Leggings of the Galeforce Viper", sources = { [14]=95094, [15]=95610, [16]=95611 } },
                { id = 159435, slot = "Legs", name = "Legplates of Charged Duality", sources = { [14]=95239, [15]=95240, [16]=95647 } },
                { id = 159636, slot = "Two-Hand", name = "Staff of the Lightning Serpent", sources = { [14]=95418, [15]=95509, [16]=95510 } },
                { id = 158370, slot = "Two-Hand", name = "Twin-Strike Polearm", sources = { [14]=94381, [15]=94382, [16]=94383 } },
                { id = 159317, slot = "Waist", name = "Whirling Dervish Sash", sources = { [14]=95078, [15]=95079, [16]=95603 } },
                { id = 159380, slot = "Wrist", name = "Arc-Glass Bindings", sources = { [14]=95161, [15]=95162, [16]=98414 } },
                { id = 159263, slot = "Wrist", name = "Bindings of the Slithering Current", sources = { [14]=95009, [15]=95571, [16]=95572 } },
                { id = 159425, slot = "Wrist", name = "Shard-Tipped Vambraces", sources = { [14]=95223, [15]=95224, [16]=95646 } },
            },
        },
        {
            index              = 2,
            name               = "Merektha",
            journalEncounterID = 2143,
            achievements       = {
            },
            loot = {
                { id = 159327, slot = "Feet", name = "Sand-Shined Snakeskin Sandals", sources = { [14]=95092, [15]=95608, [16]=95609 } },
                { id = 159437, slot = "Hands", name = "Fangproof Gauntlets", sources = { [14]=95242, [15]=95648, [16]=95649 } },
                { id = 159375, slot = "Legs", name = "Legguards of the Awakening Brood", sources = { [14]=95154, [15]=98411, [16]=98412 } },
                { id = 159637, slot = "Ranged", name = "Snakebite Recurve", sources = { [14]=95419, [15]=95420, [16]=95421 } },
                { id = 159255, slot = "Waist", name = "Ouroborial Sash", sources = { [14]=94998, [15]=95566, [16]=95567 } },
                { id = 158714, slot = "Weapon", name = "Swarm's Edge", sources = { [14]=94671, [15]=94673, [16]=96027 } },
            },
        },
        {
            index              = 3,
            name               = "Galvazzt",
            journalEncounterID = 2144,
            achievements       = {
            },
            loot = {
                { id = 159247, slot = "Hands", name = "Handwraps of Oscillating Polarity", sources = { [14]=94987, [15]=95562, [16]=95563 } },
                { id = 159664, slot = "Off-hand", name = "Bulwark of Brimming Potential", sources = { [14]=95451, [15]=95521, [16]=95522 } },
                { id = 159442, slot = "Waist", name = "Sand-Scoured Greatbelt", sources = { [14]=95249, [15]=95250, [16]=95652 } },
                { id = 158369, slot = "Weapon", name = "Galvanized Stormcrusher", sources = { [14]=94379, [15]=94380, [16]=94388 } },
            },
        },
        {
            index              = 4,
            name               = "Avatar of Sethraliss",
            journalEncounterID = 2145,
            achievements       = {
                { id = 12504, name = "The Temple of Sethraliss" },
                { id = 12505, name = "Heroic: The Temple of Sethraliss" },
                { id = 12506, name = "Mythic: The Temple of Sethraliss" },
            },
            loot = {
                { id = 159370, slot = "Chest", name = "Corrupted Hexxer's Vestments", sources = { [14]=95146, [15]=95147, [16]=98408 } },
                { id = 159424, slot = "Chest", name = "Desert Guardian's Breastplate", sources = { [14]=95221, [15]=95222, [16]=95645 } },
                { id = 159257, slot = "Chest", name = "Robes of the Reborn Serpent", sources = { [14]=95000, [15]=95001, [16]=95568 } },
                { id = 159337, slot = "Hands", name = "Grips of Electrified Defense", sources = { [14]=95105, [15]=95612, [16]=95613 } },
                { id = 159318, slot = "Head", name = "Hood of the Slithering Loa", sources = { [14]=95080, [15]=95604, [16]=95605 } },
                { id = 159374, slot = "Head", name = "Sethraliss' Fanged Helm", sources = { [14]=95153, [15]=98409, [16]=98410 } },
                { id = 159254, slot = "Shoulder", name = "Brood Cleanser's Amice", sources = { [14]=94997, [15]=95564, [16]=95565 } },
                { id = 159439, slot = "Shoulder", name = "C'thraxxi Binders Pauldrons", sources = { [14]=95244, [15]=95650, [16]=95651 } },
                { id = 158373, slot = "Weapon", name = "Resonating Crystal Scimitar", sources = { [14]=94389, [15]=94390, [16]=94391 } },
            },
            specialLoot = {
                { id = 278982, kind = "decor", name = "Hatchery of Hissing Eggs", decorID = 26198 },
            },
        },
    },
}
