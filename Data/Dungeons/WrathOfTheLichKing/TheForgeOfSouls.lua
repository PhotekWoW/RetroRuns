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
    availableDifficulties = { 14, 15 },
    patch             = "3.3.0",
    timewalking       = true,

    entrance = {
        mapID = 123,
        x     = 0.7845,
        y     = 0.0192,
    },

    bosses = {
        {
            index              = 1,
            name               = "Bronjahm",
            journalEncounterID = 615,
            achievements       = {
                { id = 4522, name = "Soul Power", soloable = "yes" },
            },
            loot = {
                { id = 49786, slot = "Chest", name = "Robes of the Cheating Heart", sources = { [14]=24366, [15]=24366 }, twSource = 165769 },
                { id = 49788, slot = "Hands", name = "Cold Sweat Grips", sources = { [14]=24368, [15]=24368 }, twSource = 165771 },
                { id = 50194, slot = "Hands", name = "Weeping Gauntlets", sources = { [14]=24610, [15]=24610 }, twSource = 165784 },
                { id = 50197, slot = "Head", name = "Eyes of Bewilderment", sources = { [14]=24611, [15]=24611 }, twSource = 165785 },
                { id = 49784, slot = "Legs", name = "Minister's Number One Legplates", sources = { [14]=24364, [15]=24364 }, twSource = 165767 },
                { id = 49785, slot = "Shoulder", name = "Bewildering Shoulderpads", sources = { [14]=24365, [15]=24365 }, twSource = 165768 },
                { id = 50193, slot = "Shoulder", name = "Very Fashionable Shoulders", sources = { [14]=24609, [15]=24609 }, twSource = 165783 },
                { id = 49783, slot = "Weapon", name = "Lucky Old Sun", sources = { [14]=24363, [15]=24363 }, twSource = 165766 },
                { id = 50191, slot = "Weapon", name = "Nighttime", sources = { [14]=24607, [15]=24607 }, twSource = 165782 },
                { id = 49787, slot = "Wrist", name = "Seven Stormy Mornings", sources = { [14]=24367, [15]=24367 }, twSource = 165770 },
            },
        },
        {
            index              = 2,
            name               = "Devourer of Souls",
            journalEncounterID = 616,
            achievements       = {
                { id = 4523, name = "Three Faced", soloable = "yes" },
            },
            loot = {
                { id = 49792, slot = "Back", name = "Accursed Crawling Cape", sources = { [14]=24372, [15]=24372 }, twSource = 165775 },
                { id = 49791, slot = "Chest", name = "Lost Reliquary Chestguard", sources = { [14]=24371, [15]=24371 }, twSource = 165774 },
                { id = 50213, slot = "Chest", name = "Mord'rethar Robes", sources = { [14]=24623, [15]=24623 }, twSource = 165793 },
                { id = 50207, slot = "Feet", name = "Black Spire Sabatons", sources = { [14]=24618, [15]=24618 }, twSource = 165788 },
                { id = 50215, slot = "Feet", name = "Recovered Reliquary Boots", sources = { [14]=24625, [15]=24625 }, twSource = 165795 },
                { id = 49795, slot = "Feet", name = "Sollerets of Suffering", sources = { [14]=24375, [15]=24375 }, twSource = 165778 },
                { id = 49798, slot = "Feet", name = "Soul Screaming Boots", sources = { [14]=24378, [15]=24378 }, twSource = 165781 },
                { id = 50212, slot = "Hands", name = "Essence of Desire", sources = { [14]=24622, [15]=24622 }, twSource = 165792 },
                { id = 50206, slot = "Head", name = "Frayed Scoundrel's Cap", sources = { [14]=24617, [15]=24617 }, twSource = 165787 },
                { id = 50214, slot = "Head", name = "Helm of the Spirit Shock", sources = { [14]=24624, [15]=24624 }, twSource = 165794 },
                { id = 49794, slot = "Legs", name = "Legplates of Frozen Granite", sources = { [14]=24374, [15]=24374 }, twSource = 165777 },
                { id = 50208, slot = "Shoulder", name = "Pauldrons of the Souleater", sources = { [14]=24619, [15]=24619 }, twSource = 165789 },
                { id = 49790, slot = "Two-Hand", name = "Blood Boil Lancet", sources = { [14]=24370, [15]=24370 }, twSource = 165773 },
                { id = 49793, slot = "Two-Hand", name = "Tower of the Mouldering Corpse", sources = { [14]=24373, [15]=24373 }, twSource = 165776 },
                { id = 49796, slot = "Waist", name = "Essence of Anger", sources = { [14]=24376, [15]=24376 }, twSource = 165779 },
                { id = 50203, slot = "Weapon", name = "Blood Weeper", sources = { [14]=24614, [15]=24614 }, twSource = 165786 },
                { id = 49789, slot = "Weapon", name = "Heartshiver", sources = { [14]=24369, [15]=24369 }, twSource = 165772 },
                { id = 50210, slot = "Weapon", name = "Seethe", sources = { [14]=24621, [15]=24621 }, twSource = 165791 },
                { id = 49797, slot = "Wrist", name = "Brace Guards of the Starless Night", sources = { [14]=24377, [15]=24377 }, twSource = 165780 },
                { id = 50209, slot = "Wrist", name = "Essence of Suffering", sources = { [14]=24620, [15]=24620 }, twSource = 165790 },
            },
        },
    },
}
