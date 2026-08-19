-------------------------------------------------------------------------------
-- RetroRuns Data -- Drak'Tharon Keep
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 600  |  journalInstanceID: 273
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[273] = {
    kind              = "dungeon",
    instanceID        = 600,
    journalInstanceID = 273,
    name              = "Drak'Tharon Keep",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.0.2",

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Trollgore",
            journalEncounterID = 588,
            achievements       = {
                { id = 2151, name = "Consumption Junction", meta = true },
            },
            loot = {
                { id = 37712, slot = "Feet", name = "Terrace Defence Boots", sources = { [14]=17962 } },
                { id = 35620, slot = "Head", name = "Berserker's Horns", sources = { [14]=16554 } },
                { id = 37715, slot = "Head", name = "Cowl of the Dire Troll", sources = { [14]=17964 } },
                { id = 35619, slot = "Legs", name = "Infection Resistant Legguards", sources = { [14]=16553 } },
                { id = 37717, slot = "Legs", name = "Legs of Physical Regeneration", sources = { [14]=17965 } },
                { id = 35618, slot = "Two-Hand", name = "Troll Butcherer", sources = { [14]=16552 } },
                { id = 37714, slot = "Waist", name = "Batrider's Cord", sources = { [14]=17963 } },
            },
        },
        {
            index              = 2,
            name               = "Novos the Summoner",
            journalEncounterID = 589,
            achievements       = {
                { id = 2057, name = "Oh Novos!", meta = true },
            },
            loot = {
                { id = 37722, slot = "Chest", name = "Breastplate of Undeath", sources = { [14]=17968 } },
                { id = 35632, slot = "Chest", name = "Robes of Novos", sources = { [14]=16556 } },
                { id = 37718, slot = "Off-hand", name = "Temple Crystal Fragment", sources = { [14]=17966 } },
                { id = 157558, slot = "Shoulder", name = "Shoddily Stitched Shoulderguards", sources = { [14]=93753 } },
                { id = 37721, slot = "Weapon", name = "Cursed Lich Blade", sources = { [14]=17967 } },
                { id = 35630, slot = "Weapon", name = "Summoner's Stone Gavel", sources = { [14]=16555 } },
                { id = 40490, slot = "Wrist", name = "Necromantic Wristguards", sources = { [14]=19465 } },
            },
        },
        {
            index              = 3,
            name               = "King Dred",
            journalEncounterID = 590,
            achievements       = {
                { id = 2039, name = "Better Off Dred", meta = true },
            },
            loot = {
                { id = 37726, slot = "Head", name = "King Dred's Helm", sources = { [14]=17971 } },
                { id = 35634, slot = "Head", name = "Scabrous-Hide Helm", sources = { [14]=16558 } },
                { id = 35635, slot = "Legs", name = "Stable Master's Breeches", sources = { [14]=16559 } },
                { id = 35633, slot = "Two-Hand", name = "Staff of the Great Reptile", sources = { [14]=16557 } },
                { id = 157561, slot = "Waist", name = "Dino-Toothed Waistguard", sources = { [14]=93756 } },
                { id = 37724, slot = "Wrist", name = "Handler's Arm Strap", sources = { [14]=17969 } },
                { id = 37725, slot = "Wrist", name = "Savage Wound Wrap", sources = { [14]=17970 } },
            },
        },
        {
            index              = 4,
            name               = "The Prophet Tharon'ja",
            journalEncounterID = 591,
            achievements       = {
                { id = 482, name = "Drak'Tharon Keep" },
                { id = 493, name = "Heroic: Drak'Tharon Keep" },
                { id = 39929, name = "Drak'Tharon Keep (char specific hidden copy)" },
            },
            loot = {
                { id = 37735, slot = "Chest", name = "Ziggurat Imprinted Chestguard", sources = { [14]=17977 } },
                { id = 37798, slot = "Hands", name = "Overlook Handguards", sources = { [14]=18029 } },
                { id = 35638, slot = "Head", name = "Helmet of Living Flesh", sources = { [14]=16562 } },
                { id = 37791, slot = "Legs", name = "Leggings of the Winged Serpent", sources = { [14]=18023 } },
                { id = 35637, slot = "Legs", name = "Muradin's Lost Greaves", sources = { [14]=16561 } },
                { id = 35636, slot = "Off-hand", name = "Tharon'ja's Aegis", sources = { [14]=16560 } },
                { id = 37733, slot = "Two-Hand", name = "Mojo Masked Crusher", sources = { [14]=17976 } },
                { id = 37788, slot = "Wrist", name = "Limb Regeneration Bracers", sources = { [14]=18020 } },
            },
        },
    },
}
