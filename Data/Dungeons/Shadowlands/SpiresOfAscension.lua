-------------------------------------------------------------------------------
-- RetroRuns Data -- Spires of Ascension
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2285  |  journalInstanceID: 1186
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1186] = {
    kind              = "dungeon",
    instanceID        = 2285,
    journalInstanceID = 1186,
    name              = "Spires of Ascension",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    patch             = "9.0.1",

    gloryMeta = {
        id   = 14322,
        name = "Glory of the Shadowlands Hero",
        rewardItemID       = 184183,
        rewardMountSpellID = 344659,
        rewardName         = "Voracious Gorger",
    },

    bosses = {
        {
            index              = 1,
            name               = "Kin-Tara",
            journalEncounterID = 2399,
            achievements       = {
            },
            loot = {
                { id = 180100, slot = "Chest", name = "Forsworn Stalker's Hauberk", sources = { [14]=112877 } },
                { id = 180101, slot = "Feet", name = "Warboots of Ruthless Conviction", sources = { [14]=112878 } },
                { id = 180103, slot = "Hands", name = "Winged Hunters' Gloves", sources = { [14]=112880 } },
                { id = 180097, slot = "Two-Hand", name = "Quarterstaff of Discordant Ethic", sources = { [14]=112874 } },
                { id = 180109, slot = "Waist", name = "Kin-Tara's Baleful Cord", sources = { [14]=112886 } },
            },
        },
        {
            index              = 2,
            name               = "Ventunax",
            journalEncounterID = 2416,
            achievements       = {
            },
            loot = {
                { id = 180102, slot = "Feet", name = "Dark Stride Footwraps", sources = { [14]=112879 } },
                { id = 180104, slot = "Hands", name = "Distorted Construct's Gauntlets", sources = { [14]=112881 } },
                { id = 180110, slot = "Waist", name = "Dark Praetorian's Clasp", sources = { [14]=112887 } },
                { id = 180111, slot = "Waist", name = "Shadowhirl Waistwrap", sources = { [14]=112888 } },
                { id = 180095, slot = "Weapon", name = "Penitent Edge", sources = { [14]=112872 } },
            },
        },
        {
            index              = 3,
            name               = "Oryphrion",
            journalEncounterID = 2414,
            achievements       = {
                { id = 14331, name = "Goliath Offline", meta = true },
            },
            loot = {
                { id = 180105, slot = "Hands", name = "Absonant Construct's Handguards", sources = { [14]=112882 } },
                { id = 180106, slot = "Head", name = "Vicious Surge Faceguard", sources = { [14]=112883 } },
                { id = 180107, slot = "Legs", name = "Purge Protocol Legwraps", sources = { [14]=112884 } },
                { id = 180112, slot = "Ranged", name = "The Philosopher", sources = { [14]=112889 } },
                { id = 180113, slot = "Wrist", name = "Thunderous Echo Vambraces", sources = { [14]=112890 } },
            },
        },
        {
            index              = 4,
            name               = "Devos, Paragon of Doubt",
            journalEncounterID = 2412,
            achievements       = {
                { id = 14323, name = "ExSPEARiential", meta = true },
                { id = 14324, name = "Heroic: Spires of Ascension" },
                { id = 14325, name = "Mythic: Spires of Ascension" },
                { id = 14326, name = "Spires of Ascension" },
                { id = 14327, name = "I Can See My House From Here", meta = true },
            },
            loot = {
                { id = 180123, slot = "Back", name = "Drape of Twisted Loyalties", sources = { [14]=112892 } },
                { id = 180099, slot = "Chest", name = "Breastplate of Brutal Dissonance", sources = { [14]=112876 } },
                { id = 180098, slot = "Chest", name = "Sinister Requiem Vestments", sources = { [14]=112875 } },
                { id = 180108, slot = "Legs", name = "Abyssal Disharmony Breeches", sources = { [14]=112885 } },
                { id = 180096, slot = "Two-Hand", name = "Devos's Cacophonous Poleaxe", sources = { [14]=112873 } },
                { id = 180114, slot = "Wrist", name = "Fallen Paragon's Armguards", sources = { [14]=112891 } },
            },
        },
    },
}
