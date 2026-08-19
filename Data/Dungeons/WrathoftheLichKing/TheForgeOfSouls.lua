-------------------------------------------------------------------------------
-- RetroRuns Data -- The Forge of Souls
-- Wrath of the Lich King dungeon, Patch 3.3.0  |  instanceID: 632  |  journalInstanceID: 280
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[280] = {
    kind              = "dungeon",
    instanceID        = 632,
    journalInstanceID = 280,
    name              = "The Forge of Souls",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.3.0",

    bosses = {
        {
            index              = 1,
            name               = "Bronjahm",
            journalEncounterID = 615,
            achievements       = {
                { id = 4522, name = "Soul Power" },
            },
            loot = {
                { id = 49786, slot = "Chest", name = "Robes of the Cheating Heart", sources = { [14]=24366 } },
                { id = 49788, slot = "Hands", name = "Cold Sweat Grips", sources = { [14]=24368 } },
                { id = 50194, slot = "Hands", name = "Weeping Gauntlets", sources = { [14]=24610 } },
                { id = 50197, slot = "Head", name = "Eyes of Bewilderment", sources = { [14]=24611 } },
                { id = 49784, slot = "Legs", name = "Minister's Number One Legplates", sources = { [14]=24364 } },
                { id = 49785, slot = "Shoulder", name = "Bewildering Shoulderpads", sources = { [14]=24365 } },
                { id = 50193, slot = "Shoulder", name = "Very Fashionable Shoulders", sources = { [14]=24609 } },
                { id = 49783, slot = "Weapon", name = "Lucky Old Sun", sources = { [14]=24363 } },
                { id = 50191, slot = "Weapon", name = "Nighttime", sources = { [14]=24607 } },
                { id = 49787, slot = "Wrist", name = "Seven Stormy Mornings", sources = { [14]=24367 } },
            },
        },
        {
            index              = 2,
            name               = "Devourer of Souls",
            journalEncounterID = 616,
            achievements       = {
                { id = 4523, name = "Three Faced" },
                { id = 4516, name = "The Forge of Souls" },
                { id = 4519, name = "Heroic: The Forge of Souls" },
            },
            loot = {
                { id = 49792, slot = "Back", name = "Accursed Crawling Cape", sources = { [14]=24372 } },
                { id = 49791, slot = "Chest", name = "Lost Reliquary Chestguard", sources = { [14]=24371 } },
                { id = 50213, slot = "Chest", name = "Mord'rethar Robes", sources = { [14]=24623 } },
                { id = 50207, slot = "Feet", name = "Black Spire Sabatons", sources = { [14]=24618 } },
                { id = 50215, slot = "Feet", name = "Recovered Reliquary Boots", sources = { [14]=24625 } },
                { id = 49795, slot = "Feet", name = "Sollerets of Suffering", sources = { [14]=24375 } },
                { id = 49798, slot = "Feet", name = "Soul Screaming Boots", sources = { [14]=24378 } },
                { id = 50212, slot = "Hands", name = "Essence of Desire", sources = { [14]=24622 } },
                { id = 50206, slot = "Head", name = "Frayed Scoundrel's Cap", sources = { [14]=24617 } },
                { id = 50214, slot = "Head", name = "Helm of the Spirit Shock", sources = { [14]=24624 } },
                { id = 49794, slot = "Legs", name = "Legplates of Frozen Granite", sources = { [14]=24374 } },
                { id = 50208, slot = "Shoulder", name = "Pauldrons of the Souleater", sources = { [14]=24619 } },
                { id = 49790, slot = "Two-Hand", name = "Blood Boil Lancet", sources = { [14]=24370 } },
                { id = 49793, slot = "Two-Hand", name = "Tower of the Mouldering Corpse", sources = { [14]=24373 } },
                { id = 49796, slot = "Waist", name = "Essence of Anger", sources = { [14]=24376 } },
                { id = 50203, slot = "Weapon", name = "Blood Weeper", sources = { [14]=24614 } },
                { id = 49789, slot = "Weapon", name = "Heartshiver", sources = { [14]=24369 } },
                { id = 50210, slot = "Weapon", name = "Seethe", sources = { [14]=24621 } },
                { id = 49797, slot = "Wrist", name = "Brace Guards of the Starless Night", sources = { [14]=24377 } },
                { id = 50209, slot = "Wrist", name = "Essence of Suffering", sources = { [14]=24620 } },
            },
        },
    },
}
