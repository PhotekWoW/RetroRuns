-------------------------------------------------------------------------------
-- RetroRuns Data -- Scarlet Halls
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 1001  |  journalInstanceID: 311
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[311] = {
    kind              = "dungeon",
    instanceID        = 1001,
    journalInstanceID = 311,
    name              = "Scarlet Halls",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    patch             = "5.0.4",

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Houndmaster Braun",
            journalEncounterID = 660,
            achievements       = {
                { id = 6684, name = "Humane Society", meta = true },
            },
            loot = {
                { id = 88268, slot = "Chest", name = "Canine Commander's Breastplate", sources = { [14]=45670 } },
                { id = 143966, slot = "Chest", name = "Canine Commander's Breastplate", sources = { [14]=84301 } },
                { id = 88266, slot = "Hands", name = "Hound Trainer's Gloves", sources = { [14]=45668 } },
                { id = 144192, slot = "Hands", name = "Hound Trainer's Gloves", sources = { [14]=84460 } },
                { id = 88264, slot = "Ranged", name = "Houndmaster's Compound Crossbow", sources = { [14]=45667 } },
                { id = 144190, slot = "Ranged", name = "Houndmaster's Compound Crossbow", sources = { [14]=84458 } },
                { id = 88267, slot = "Wrist", name = "Commanding Bracers", sources = { [14]=45669 } },
                { id = 144191, slot = "Wrist", name = "Commanding Bracers", sources = { [14]=84459 } },
            },
        },
        {
            index              = 2,
            name               = "Armsmaster Harlan",
            journalEncounterID = 654,
            achievements       = {
                { id = 6427, name = "Mosh Pit", meta = true },
            },
            loot = {
                { id = 132550, slot = "Feet", name = "Scarlet Chain Footpads", sources = { [14]=76385 } },
                { id = 88269, slot = "Feet", name = "Scarlet Sandals", sources = { [14]=45671 } },
                { id = 144007, slot = "Feet", name = "Scarlet Sandals", sources = { [14]=84342 } },
                { id = 88271, slot = "Shoulder", name = "Harlan's Shoulders", sources = { [14]=45673 } },
                { id = 144006, slot = "Shoulder", name = "Harlan's Shoulders", sources = { [14]=84341 } },
                { id = 88272, slot = "Two-Hand", name = "The Gleaming Ravager", sources = { [14]=45674 } },
                { id = 144193, slot = "Two-Hand", name = "The Gleaming Ravager", sources = { [14]=84461 } },
                { id = 88270, slot = "Wrist", name = "Lightblade Bracer", sources = { [14]=45672 } },
                { id = 144194, slot = "Wrist", name = "Lightblade Bracer", sources = { [14]=84462 } },
            },
        },
        {
            index              = 3,
            name               = "Flameweaver Koegler",
            journalEncounterID = 656,
            achievements       = {
                { id = 6760, name = "Heroic: Scarlet Halls" },
                { id = 7413, name = "Scarlet Halls" },
                { id = 6895, name = "Scarlet Halls Challenger" },
                { id = 6908, name = "Scarlet Halls: Bronze" },
                { id = 6909, name = "Scarlet Halls: Silver" },
                { id = 6910, name = "Scarlet Halls: Gold" },
                { id = 19906, name = "Scarlet Halls" },
                { id = 19907, name = "Heroic: Scarlet Halls" },
            },
            loot = {
                { id = 88279, slot = "Chest", name = "Robes of Koegler", sources = { [14]=45679 } },
                { id = 144009, slot = "Chest", name = "Robes of Koegler", sources = { [14]=84344 } },
                { id = 88282, slot = "Hands", name = "Vellum-Ripper Gloves", sources = { [14]=45681 } },
                { id = 144199, slot = "Hands", name = "Vellum-Ripper Gloves", sources = { [14]=84467 } },
                { id = 88283, slot = "Legs", name = "Bradbury's Entropic Legguards", sources = { [14]=45682 } },
                { id = 144010, slot = "Legs", name = "Bradbury's Entropic Legguards", sources = { [14]=84345 } },
                { id = 88277, slot = "Legs", name = "Pyretic Legguards", sources = { [14]=45677 } },
                { id = 144008, slot = "Legs", name = "Pyretic Legguards", sources = { [14]=84343 } },
                { id = 88278, slot = "Two-Hand", name = "Mograine's Immaculate Might", sources = { [14]=45678 } },
                { id = 144196, slot = "Two-Hand", name = "Mograine's Immaculate Might", sources = { [14]=84464 } },
                { id = 88276, slot = "Waist", name = "Bindburner Belt", sources = { [14]=45676 } },
                { id = 144197, slot = "Waist", name = "Bindburner Belt", sources = { [14]=84465 } },
                { id = 88274, slot = "Weapon", name = "Koegler's Ritual Knife", sources = { [14]=45675 } },
                { id = 144195, slot = "Weapon", name = "Koegler's Ritual Knife", sources = { [14]=84463 } },
                { id = 88280, slot = "Weapon", name = "Melted Hypnotic Blade", sources = { [14]=45680 } },
                { id = 144198, slot = "Weapon", name = "Melted Hypnotic Blade", sources = { [14]=84466 } },
            },
        },
    },
}
