-------------------------------------------------------------------------------
-- RetroRuns Data -- Dire Maul - Capital Gardens
-- Classic dungeon, Patch 1.3  |  instanceID: 429  |  journalInstanceID: 230
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[230] = {
    kind              = "dungeon",
    instanceID        = 429,
    journalInstanceID = 230,
    name              = "Dire Maul - Capital Gardens",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.3",

    bosses = {
        {
            index              = 1,
            name               = "Tendris Warpwood",
            journalEncounterID = 406,
            achievements       = {
            },
            loot = {
                { id = 18390, slot = "Legs", name = "Tanglemoss Leggings", sources = { [14]=7311 } },
                { id = 18352, slot = "Off-hand", name = "Petrified Bark Shield", sources = { [14]=7288 } },
                { id = 18353, slot = "Two-Hand", name = "Stoneflower Staff", sources = { [14]=7289 } },
                { id = 18393, slot = "Waist", name = "Warpwood Binding", sources = { [14]=7314 } },
            },
        },
        {
            index              = 2,
            name               = "Illyanna Ravenoak",
            journalEncounterID = 407,
            achievements       = {
            },
            loot = {
                { id = 18383, slot = "Hands", name = "Force Imbued Gauntlets", sources = { [14]=7304 } },
                { id = 18349, slot = "Hands", name = "Gauntlets of Accuracy", sources = { [14]=7285 } },
                { id = 18377, slot = "Hands", name = "Quickdraw Gloves", sources = { [14]=7299 } },
                { id = 18386, slot = "Legs", name = "Padre's Trousers", sources = { [14]=7307 } },
                { id = 18347, slot = "Weapon", name = "Well Balanced Axe", sources = { [14]=7283 } },
            },
        },
        {
            index              = 3,
            name               = "Magister Kalendris",
            journalEncounterID = 408,
            achievements       = {
            },
            loot = {
                { id = 18350, slot = "Back", name = "Amplifying Cloak", sources = { [14]=7286 } },
                { id = 18374, slot = "Shoulder", name = "Flamescarred Shoulders", sources = { [14]=7296 } },
                { id = 18351, slot = "Wrist", name = "Magically Sealed Bracers", sources = { [14]=7287 } },
            },
        },
        {
            index              = 4,
            name               = "Immol'thar",
            journalEncounterID = 409,
            achievements       = {
            },
            loot = {
                { id = 18389, slot = "Back", name = "Cloak of the Cosmos", sources = { [14]=7310 } },
                { id = 18385, slot = "Chest", name = "Robe of Everlasting Night", sources = { [14]=7306 } },
                { id = 18379, slot = "Feet", name = "Odious Greaves", sources = { [14]=7301 } },
                { id = 18384, slot = "Shoulder", name = "Bile-Etched Spaulders", sources = { [14]=7305 } },
                { id = 18391, slot = "Waist", name = "Eyestalk Cord", sources = { [14]=7312 } },
                { id = 18372, slot = "Weapon", name = "Blade of the New Moon", sources = { [14]=7294 } },
                { id = 18394, slot = "Wrist", name = "Demon Howl Wristguards", sources = { [14]=7315 } },
            },
        },
        {
            index              = 5,
            name               = "Prince Tortheldrin",
            journalEncounterID = 410,
            achievements       = {
                { id = 644, name = "King of Dire Maul" },
            },
            loot = {
                { id = 18382, slot = "Back", name = "Fluctuating Cloak", sources = { [14]=7303 } },
                { id = 18373, slot = "Chest", name = "Chestplate of Tranquility", sources = { [14]=7295 } },
                { id = 18380, slot = "Legs", name = "Eldritch Reinforced Legplates", sources = { [14]=7302 } },
                { id = 18378, slot = "Legs", name = "Silvermoon Leggings", sources = { [14]=7300 } },
                { id = 18388, slot = "Ranged", name = "Stoneshatter", sources = { [14]=7309 } },
                { id = 18392, slot = "Weapon", name = "Distracting Dagger", sources = { [14]=7313 } },
                { id = 18396, slot = "Weapon", name = "Mind Carver", sources = { [14]=7316 } },
                { id = 18376, slot = "Weapon", name = "Timeworn Mace", sources = { [14]=7298 } },
                { id = 18375, slot = "Wrist", name = "Bracers of the Eclipse", sources = { [14]=7297 } },
            },
        },
    },
}
