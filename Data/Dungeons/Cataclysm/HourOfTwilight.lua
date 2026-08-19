-------------------------------------------------------------------------------
-- RetroRuns Data -- Hour of Twilight
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
    patch             = "4.3.0",

    bosses = {
        {
            index              = 1,
            name               = "Arcurion",
            journalEncounterID = 322,
            achievements       = {
            },
            loot = {
                { id = 72854, slot = "Back", name = "Iceward Cloak", sources = { [14]=37331 } },
                { id = 72850, slot = "Feet", name = "Surestride Boots", sources = { [14]=37327 } },
                { id = 72849, slot = "Feet", name = "Wayfinder Boots", sources = { [14]=37326 } },
                { id = 72853, slot = "Legs", name = "Arcurion Legguards", sources = { [14]=37330 } },
                { id = 72851, slot = "Waist", name = "Chillbane Belt", sources = { [14]=37328 } },
                { id = 76150, slot = "Wrist", name = "Evergreen Wristbands", sources = { [14]=38409 } },
            },
        },
        {
            index              = 2,
            name               = "Asira Dawnslayer",
            journalEncounterID = 342,
            achievements       = {
            },
            loot = {
                { id = 76151, slot = "Back", name = "Cloak of Subtle Light", sources = { [14]=38410 } },
                { id = 157616, slot = "Chest", name = "Chestguard of Futility", sources = { [14]=93802 } },
                { id = 72859, slot = "Head", name = "Dawnslayer Helm", sources = { [14]=37336 } },
                { id = 72857, slot = "Legs", name = "Leggings of Blinding Speed", sources = { [14]=37334 } },
                { id = 72855, slot = "Off-hand", name = "Corrupted Carapace", sources = { [14]=37332 } },
                { id = 72856, slot = "Shoulder", name = "Pauldrons of Midnight Whispers", sources = { [14]=37333 } },
                { id = 72860, slot = "Weapon", name = "Mandible of the Old Ones", sources = { [14]=37337 } },
            },
        },
        {
            index              = 3,
            name               = "Archbishop Benedictus",
            journalEncounterID = 341,
            achievements       = {
                { id = 6119, name = "Heroic: Hour of Twilight" },
            },
            loot = {
                { id = 72869, slot = "Ranged", name = "Dragonsmaw Blaster", sources = { [14]=37346 } },
                { id = 72870, slot = "Shoulder", name = "Betrayer's Pauldrons", sources = { [14]=37347 } },
                { id = 72868, slot = "Shoulder", name = "Desecrated Shoulderguards", sources = { [14]=37345 } },
                { id = 72865, slot = "Shoulder", name = "Mantle of False Virtue", sources = { [14]=37342 } },
                { id = 72864, slot = "Shoulder", name = "Pauldrons of Conviction", sources = { [14]=37341 } },
                { id = 72861, slot = "Shoulder", name = "Pauldrons of the Dragonblight", sources = { [14]=37338 } },
                { id = 72863, slot = "Two-Hand", name = "Stalk of Corruption", sources = { [14]=37340 } },
                { id = 72867, slot = "Weapon", name = "Clattering Claw", sources = { [14]=37344 } },
                { id = 72862, slot = "Weapon", name = "Fanged Tentacle", sources = { [14]=37339 } },
                { id = 72866, slot = "Weapon", name = "Treachery's Bite", sources = { [14]=37343 } },
            },
        },
    },
}
