-------------------------------------------------------------------------------
-- RetroRuns Data -- Old Hillsbrad Foothills
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 560  |  journalInstanceID: 251
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[251] = {
    kind              = "dungeon",
    instanceID        = 560,
    journalInstanceID = 251,
    name              = "Old Hillsbrad Foothills",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Lieutenant Drake",
            journalEncounterID = 538,
            achievements       = {
            },
            loot = {
                { id = 27423, slot = "Back", name = "Cloak of Impulsiveness", sources = { [14]=11889 } },
                { id = 27420, slot = "Feet", name = "Uther's Ceremonial Warboots", sources = { [14]=11888 } },
                { id = 28214, slot = "Hands", name = "Grips of the Lunar Eclipse", sources = { [14]=12334 } },
                { id = 28215, slot = "Head", name = "Mok'Nathal Mask of Battle", sources = { [14]=12335 } },
                { id = 28212, slot = "Legs", name = "Aran's Sorcerous Slacks", sources = { [14]=12332 } },
                { id = 27418, slot = "Legs", name = "Stormreaver Shadow-Kilt", sources = { [14]=11887 } },
                { id = 28213, slot = "Off-hand", name = "Lordaeron Medical Guide", sources = { [14]=12333 } },
                { id = 27417, slot = "Shoulder", name = "Ravenwing Pauldrons", sources = { [14]=11886 } },
                { id = 28210, slot = "Weapon", name = "Bloodskull Destroyer", sources = { [14]=12331 } },
            },
        },
        {
            index              = 2,
            name               = "Captain Skarloc",
            journalEncounterID = 539,
            achievements       = {
            },
            loot = {
                { id = 27427, slot = "Chest", name = "Durotan's Battle Harness", sources = { [14]=11892 } },
                { id = 28221, slot = "Feet", name = "Boots of the Watchful Heart", sources = { [14]=12340 } },
                { id = 27428, slot = "Hands", name = "Stormfront Gauntlets", sources = { [14]=11893 } },
                { id = 28220, slot = "Head", name = "Moon-Crown Antlers", sources = { [14]=12339 } },
                { id = 28219, slot = "Legs", name = "Emerald-Scale Greaves", sources = { [14]=12338 } },
                { id = 28218, slot = "Legs", name = "Pontiff's Pantaloons of Prophecy", sources = { [14]=12337 } },
                { id = 27430, slot = "Legs", name = "Scaled Greaves of Patience", sources = { [14]=11894 } },
                { id = 27424, slot = "Weapon", name = "Amani Venom-Axe", sources = { [14]=11890 } },
                { id = 28216, slot = "Weapon", name = "Dathrohan's Ceremonial Hammer", sources = { [14]=12336 } },
                { id = 27426, slot = "Weapon", name = "Northshire Battlemace", sources = { [14]=11891 } },
            },
        },
        {
            index              = 3,
            name               = "Epoch Hunter",
            journalEncounterID = 540,
            achievements       = {
                { id = 673, name = "Heroic: The Escape From Durnholde" },
            },
            loot = {
                { id = 28401, slot = "Chest", name = "Hauberk of Desolation", sources = { [14]=12446 } },
                { id = 28191, slot = "Chest", name = "Mana-Etched Vestments", sources = { [14]=12313 } },
                { id = 28225, slot = "Head", name = "Doomplate Warhelm", sources = { [14]=12343 } },
                { id = 28224, slot = "Head", name = "Wastewalker Helm", sources = { [14]=12342 } },
                { id = 30536, slot = "Legs", name = "Greaves of the Martyr", sources = { [14]=13809 } },
                { id = 30534, slot = "Legs", name = "Wyrmscale Greaves", sources = { [14]=13807 } },
                { id = 27434, slot = "Shoulder", name = "Mantle of Perenolde", sources = { [14]=11897 } },
                { id = 27433, slot = "Shoulder", name = "Pauldrons of Sufferance", sources = { [14]=11896 } },
                { id = 28344, slot = "Shoulder", name = "Wyrmfury Pauldrons", sources = { [14]=12412 } },
                { id = 28222, slot = "Two-Hand", name = "Reaver of the Infinites", sources = { [14]=12341 } },
                { id = 29250, slot = "Waist", name = "Cord of Sanctification", sources = { [14]=13045 } },
                { id = 27911, slot = "Waist", name = "Epoch's Whispering Cinch", sources = { [14]=12149 } },
                { id = 27431, slot = "Weapon", name = "Time-Shifted Dagger", sources = { [14]=11895 } },
                { id = 28226, slot = "Weapon", name = "Timeslicer", sources = { [14]=12344 } },
                { id = 29246, slot = "Wrist", name = "Nightfall Wristguards", sources = { [14]=13041 } },
            },
        },
    },
}
