-------------------------------------------------------------------------------
-- RetroRuns Data -- Maraudon
-- Classic dungeon, Patch 1.2  |  instanceID: 349  |  journalInstanceID: 232
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[232] = {
    kind              = "dungeon",
    instanceID        = 349,
    journalInstanceID = 232,
    name              = "Maraudon",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.2",

    bosses = {
        {
            index              = 1,
            name               = "Noxxion",
            journalEncounterID = 423,
            achievements       = {
            },
            loot = {
                { id = 151450, slot = "Chest", name = "Chainmail of the Noxious Hollow", sources = { [14]=89447 } },
                { id = 17745, slot = "Ranged", name = "Noxious Shooter", sources = { [14]=7197 } },
                { id = 151449, slot = "Waist", name = "Fungal-Spore Cinch", sources = { [14]=89446 } },
                { id = 17746, slot = "Wrist", name = "Noxxion's Shackles", sources = { [14]=7198 } },
            },
        },
        {
            index              = 2,
            name               = "Razorlash",
            journalEncounterID = 424,
            achievements       = {
            },
            loot = {
                { id = 17748, slot = "Feet", name = "Vinerot Sandals", sources = { [14]=7199 } },
                { id = 151451, slot = "Hands", name = "Strip-Thorn Gauntlets", sources = { [14]=89448 } },
                { id = 17751, slot = "Legs", name = "Brusslehide Leggings", sources = { [14]=7202 } },
                { id = 132563, slot = "Legs", name = "Chloro-Stained Britches", sources = { [14]=76396 } },
                { id = 132562, slot = "Shoulder", name = "Leaf-Scale Pauldrons", sources = { [14]=76395 } },
                { id = 17749, slot = "Shoulder", name = "Phytoskin Spaulders", sources = { [14]=7200 } },
                { id = 17750, slot = "Waist", name = "Chloromesh Girdle", sources = { [14]=7201 } },
            },
        },
        {
            index              = 3,
            name               = "Tinkerer Gizlock",
            journalEncounterID = 425,
            achievements       = {
            },
            loot = {
                { id = 17718, slot = "Off-hand", name = "Gizlock's Hypertech Buckler", sources = { [14]=7181 } },
                { id = 17717, slot = "Ranged", name = "Megashot Rifle", sources = { [14]=7180 } },
                { id = 17719, slot = "Weapon", name = "Inventor's Focal Sword", sources = { [14]=7182 } },
            },
        },
        {
            index              = 4,
            name               = "Lord Vyletongue",
            journalEncounterID = 427,
            achievements       = {
            },
            loot = {
                { id = 151448, slot = "Chest", name = "Lord Vyletongue's Satyrplate", sources = { [14]=89445 } },
                { id = 17754, slot = "Legs", name = "Infernal Trickster Leggings", sources = { [14]=7205 } },
                { id = 17755, slot = "Waist", name = "Satyrmane Sash", sources = { [14]=7206 } },
                { id = 17752, slot = "Weapon", name = "Satyr's Lash", sources = { [14]=7203 } },
                { id = 151447, slot = "Wrist", name = "Zaetar-kin Wristwraps", sources = { [14]=89444 } },
            },
        },
        {
            index              = 5,
            name               = "Celebras the Cursed",
            journalEncounterID = 428,
            achievements       = {
            },
            loot = {
                { id = 17739, slot = "Back", name = "Grovekeeper's Drape", sources = { [14]=7192 } },
                { id = 132561, slot = "Head", name = "Corrupted Keeper's Band", sources = { [14]=76394 } },
                { id = 17740, slot = "Head", name = "Soothsayer's Headdress", sources = { [14]=7193 } },
                { id = 17738, slot = "Weapon", name = "Claw of Celebras", sources = { [14]=7191 } },
            },
        },
        {
            index              = 6,
            name               = "Landslide",
            journalEncounterID = 429,
            achievements       = {
            },
            loot = {
                { id = 17736, slot = "Hands", name = "Rockgrip Gauntlets", sources = { [14]=7189 } },
                { id = 17734, slot = "Head", name = "Helm of the Mountain", sources = { [14]=7188 } },
                { id = 17737, slot = "Off-hand", name = "Cloud Stone", sources = { [14]=7190 } },
                { id = 17943, slot = "Weapon", name = "Fist of Stone", sources = { [14]=7218 } },
            },
        },
        {
            index              = 7,
            name               = "Rotgrip",
            journalEncounterID = 430,
            achievements       = {
            },
            loot = {
                { id = 17728, slot = "Feet", name = "Albino Crocscale Boots", sources = { [14]=7185 } },
                { id = 132564, slot = "Feet", name = "Albino Crocscale Waders", sources = { [14]=76397 } },
                { id = 17732, slot = "Shoulder", name = "Rotgrip Mantle", sources = { [14]=7187 } },
                { id = 17730, slot = "Two-Hand", name = "Gatorbite Axe", sources = { [14]=7186 } },
                { id = 151452, slot = "Waist", name = "Crocolisk Wrestler's Waistguard", sources = { [14]=89449 } },
            },
        },
        {
            index              = 8,
            name               = "Princess Theradras",
            journalEncounterID = 431,
            achievements       = {
                { id = 640, name = "Maraudon" },
            },
            loot = {
                { id = 17715, slot = "Head", name = "Eye of Theradras", sources = { [14]=7179 } },
                { id = 17711, slot = "Legs", name = "Elemental Rockridge Leggings", sources = { [14]=7177 } },
                { id = 17766, slot = "Two-Hand", name = "Princess Theradras' Scepter", sources = { [14]=7207 } },
                { id = 17780, slot = "Weapon", name = "Blade of Eternal Darkness", sources = { [14]=7215 } },
                { id = 17710, slot = "Weapon", name = "Charstone Dirk", sources = { [14]=7176 } },
                { id = 17714, slot = "Wrist", name = "Bracers of the Stone Princess", sources = { [14]=7178 } },
            },
        },
    },
}
