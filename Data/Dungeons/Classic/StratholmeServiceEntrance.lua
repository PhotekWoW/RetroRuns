-------------------------------------------------------------------------------
-- RetroRuns Data -- Stratholme - Service Entrance
-- Classic dungeon, Patch 1.0  |  instanceID: 329  |  journalInstanceID: 1292
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1292] = {
    kind              = "dungeon",
    instanceID        = 329,
    journalInstanceID = 1292,
    name              = "Stratholme - Service Entrance",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "Baroness Anastari",
            journalEncounterID = 451,
            achievements       = {
            },
            loot = {
                { id = 13535, slot = "Chest", name = "Coldtouch Phantom Wraps", sources = { [14]=4904 } },
                { id = 13539, slot = "Hands", name = "Banshee's Touch", sources = { [14]=4907 } },
                { id = 18730, slot = "Hands", name = "Shadowy Laced Handwraps", sources = { [14]=7460 } },
                { id = 13534, slot = "Ranged", name = "Banshee Finger", sources = { [14]=4903 } },
                { id = 18729, slot = "Ranged", name = "Screeching Bow", sources = { [14]=7459 } },
                { id = 13538, slot = "Shoulder", name = "Windshrieker Pauldrons", sources = { [14]=4906 } },
                { id = 13537, slot = "Wrist", name = "Chillhide Bracers", sources = { [14]=4905 } },
            },
        },
        {
            index              = 2,
            name               = "Nerub'enkan",
            journalEncounterID = 452,
            achievements       = {
            },
            loot = {
                { id = 13530, slot = "Feet", name = "Fangdrip Runners", sources = { [14]=4899 } },
                { id = 13532, slot = "Hands", name = "Darkspinner Claws", sources = { [14]=4901 } },
                { id = 18739, slot = "Legs", name = "Chitinous Plate Legguards", sources = { [14]=7466 } },
                { id = 13531, slot = "Legs", name = "Crypt Stalker Leggings", sources = { [14]=4900 } },
                { id = 13529, slot = "Off-hand", name = "Husk of Nerub'enkan", sources = { [14]=4898 } },
                { id = 18738, slot = "Ranged", name = "Carapace Spine Crossbow", sources = { [14]=7465 } },
                { id = 13533, slot = "Shoulder", name = "Acid-Etched Pauldrons", sources = { [14]=4902 } },
                { id = 18740, slot = "Waist", name = "Thuzadin Sash", sources = { [14]=7467 } },
            },
        },
        {
            index              = 3,
            name               = "Maleki the Pallid",
            journalEncounterID = 453,
            achievements       = {
            },
            loot = {
                { id = 18734, slot = "Back", name = "Pale Moon Cloak", sources = { [14]=7461 } },
                { id = 13527, slot = "Feet", name = "Lavawalker Greaves", sources = { [14]=4896 } },
                { id = 18735, slot = "Feet", name = "Maleki's Footwraps", sources = { [14]=7462 } },
                { id = 13525, slot = "Hands", name = "Darkbind Fingers", sources = { [14]=4894 } },
                { id = 13524, slot = "Off-hand", name = "Skull of Burning Shadows", sources = { [14]=4893 } },
                { id = 13526, slot = "Waist", name = "Flamescarred Girdle", sources = { [14]=4895 } },
                { id = 18737, slot = "Weapon", name = "Bone Slicing Hatchet", sources = { [14]=7464 } },
                { id = 13528, slot = "Wrist", name = "Twilight Void Bracers", sources = { [14]=4897 } },
            },
        },
        {
            index              = 4,
            name               = "Magistrate Barthilas",
            journalEncounterID = 454,
            achievements       = {
            },
            loot = {
                { id = 13376, slot = "Back", name = "Royal Tribunal Cloak", sources = { [14]=4857 } },
                { id = 18722, slot = "Hands", name = "Death Grips", sources = { [14]=7455 } },
                { id = 18727, slot = "Head", name = "Crimson Felt Hat", sources = { [14]=7458 } },
                { id = 18725, slot = "Two-Hand", name = "Peacemaker", sources = { [14]=7456 } },
                { id = 18726, slot = "Wrist", name = "Magistrate's Cuffs", sources = { [14]=7457 } },
            },
        },
        {
            index              = 5,
            name               = "Ramstein the Gorger",
            journalEncounterID = 455,
            achievements       = {
            },
            loot = {
                { id = 13375, slot = "Off-hand", name = "Crest of Retribution", sources = { [14]=4856 } },
                { id = 13374, slot = "Shoulder", name = "Soulstealer Mantle", sources = { [14]=4855 } },
                { id = 13372, slot = "Two-Hand", name = "Slavedriver's Cane", sources = { [14]=4854 } },
            },
        },
        {
            index              = 6,
            name               = "Lord Aurius Rivendare",
            journalEncounterID = 456,
            achievements       = {
                { id = 646, name = "Stratholme" },
                { id = 39936, name = "Stratholme (char specific hidden copy)" },
            },
            loot = {
                { id = 13340, slot = "Back", name = "Cape of the Black Baron", sources = { [14]=4840 } },
                { id = 13346, slot = "Chest", name = "Robes of the Exalted", sources = { [14]=4843 } },
                { id = 22409, slot = "Chest", name = "Tunic of the Crescent Moon", sources = { [14]=8818 } },
                { id = 13344, slot = "Hands", name = "Dracorian Gauntlets", sources = { [14]=4842 } },
                { id = 22410, slot = "Hands", name = "Gauntlets of Deftness", sources = { [14]=8819 } },
                { id = 22411, slot = "Head", name = "Helm of the Executioner", sources = { [14]=8820 } },
                { id = 22408, slot = "Ranged", name = "Ritssyn's Wand of Bad Mojo", sources = { [14]=8817 } },
                { id = 22412, slot = "Shoulder", name = "Thuzadin Mantle", sources = { [14]=8821 } },
                { id = 13505, slot = "Two-Hand", name = "Runeblade of Baron Rivendare", sources = { [14]=4892 } },
                { id = 13368, slot = "Weapon", name = "Bonescraper", sources = { [14]=4851 } },
                { id = 13349, slot = "Weapon", name = "Scepter of the Unholy", sources = { [14]=4845 } },
                { id = 13361, slot = "Weapon", name = "Skullforge Reaver", sources = { [14]=4850 } },
            },
            specialLoot = {
                { id = 13335, kind = "mount", name = "Deathcharger's Reins" },
            },
        },
    },
}
