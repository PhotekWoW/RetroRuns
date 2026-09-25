-------------------------------------------------------------------------------
-- RetroRuns Data -- Hour of Twilight
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.3.0  |  instanceID: 940  |  journalInstanceID: 186
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[186] = {
    kind              = "dungeon",
    instanceID        = 940,
    journalInstanceID = 186,
    name              = "Hour of Twilight",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 15 },
    patch             = "4.3.0",

    entrance = {
        mapID = 75,
        x     = 0.6784,
        y     = 0.2885,
    },

    bosses = {
        {
            index              = 1,
            name               = "Arcurion",
            journalEncounterID = 322,
            dungeonEncounterID = 1337,
            achievements       = {
            },
            loot = {
                { id = 72854, slot = "Back", name = "Iceward Cloak", sources = { [15]=37331 } },
                { id = 72850, slot = "Feet", name = "Surestride Boots", sources = { [15]=37327 } },
                { id = 72849, slot = "Feet", name = "Wayfinder Boots", sources = { [15]=37326 } },
                { id = 72853, slot = "Legs", name = "Arcurion Legguards", sources = { [15]=37330 } },
                { id = 72851, slot = "Waist", name = "Chillbane Belt", sources = { [15]=37328 } },
                { id = 76150, slot = "Wrist", name = "Evergreen Wristbands", sources = { [15]=38409 } },
            },
        },
        {
            index              = 2,
            name               = "Asira Dawnslayer",
            journalEncounterID = 342,
            dungeonEncounterID = 1340,
            achievements       = {
            },
            loot = {
                { id = 76151, slot = "Back", name = "Cloak of Subtle Light", sources = { [15]=38410 } },
                { id = 157616, slot = "Chest", name = "Chestguard of Futility", sources = { [15]=93802 } },
                { id = 72859, slot = "Head", name = "Dawnslayer Helm", sources = { [15]=37336 } },
                { id = 72857, slot = "Legs", name = "Leggings of Blinding Speed", sources = { [15]=37334 } },
                { id = 72855, slot = "Off-hand", name = "Corrupted Carapace", sources = { [15]=37332 } },
                { id = 72856, slot = "Shoulder", name = "Pauldrons of Midnight Whispers", sources = { [15]=37333 } },
                { id = 72860, slot = "Weapon", name = "Mandible of the Old Ones", sources = { [15]=37337 } },
            },
        },
        {
            index              = 3,
            name               = "Archbishop Benedictus",
            journalEncounterID = 341,
            dungeonEncounterID = 1339,
            achievements       = {
            },
            loot = {
                { id = 72869, slot = "Ranged", name = "Dragonsmaw Blaster", sources = { [15]=37346 } },
                { id = 72870, slot = "Shoulder", name = "Betrayer's Pauldrons", sources = { [15]=37347 } },
                { id = 72868, slot = "Shoulder", name = "Desecrated Shoulderguards", sources = { [15]=37345 } },
                { id = 72865, slot = "Shoulder", name = "Mantle of False Virtue", sources = { [15]=37342 } },
                { id = 72864, slot = "Shoulder", name = "Pauldrons of Conviction", sources = { [15]=37341 } },
                { id = 72861, slot = "Shoulder", name = "Pauldrons of the Dragonblight", sources = { [15]=37338 } },
                { id = 72863, slot = "Two-Hand", name = "Stalk of Corruption", sources = { [15]=37340 } },
                { id = 72867, slot = "Weapon", name = "Clattering Claw", sources = { [15]=37344 } },
                { id = 72862, slot = "Weapon", name = "Fanged Tentacle", sources = { [15]=37339 } },
                { id = 72866, slot = "Weapon", name = "Treachery's Bite", sources = { [15]=37343 } },
            },
        },
    },
}
