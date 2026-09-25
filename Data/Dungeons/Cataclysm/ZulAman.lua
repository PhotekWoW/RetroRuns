-------------------------------------------------------------------------------
-- RetroRuns Data -- Zul'Aman
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.1.0  |  instanceID: 568  |  journalInstanceID: 77
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[77] = {
    kind              = "dungeon",
    instanceID        = 568,
    journalInstanceID = 77,
    name              = "Zul'Aman",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.1.0",

    entrance = {
        mapID = 95,
        x     = 0.8259,
        y     = 0.6431,
    },

    bosses = {
        {
            index              = 1,
            name               = "Akil'zon",
            journalEncounterID = 186,
            dungeonEncounterID = 1189,
            achievements       = {
            },
            loot = {
                { id = 69550, slot = "Legs", name = "Leggings of Ancient Magics", sources = { [14]=35466, [15]=35466 } },
                { id = 69551, slot = "Shoulder", name = "Feathers of Akil'zon", sources = { [14]=35467, [15]=35467 } },
                { id = 69552, slot = "Wrist", name = "Bracers of Hidden Purpose", sources = { [14]=35468, [15]=35468 } },
                { id = 69549, slot = "Wrist", name = "Wristguards of the Predator", sources = { [14]=35465, [15]=35465 } },
            },
        },
        {
            index              = 2,
            name               = "Nalorakk",
            journalEncounterID = 187,
            dungeonEncounterID = 1190,
            achievements       = {
            },
            loot = {
                { id = 69555, slot = "Feet", name = "Boots of the Ursine", sources = { [14]=35470, [15]=35470 } },
                { id = 69558, slot = "Head", name = "Spiritshield Mask", sources = { [14]=35473, [15]=35473 } },
                { id = 69557, slot = "Legs", name = "Jungle Striders", sources = { [14]=35472, [15]=35472 } },
                { id = 69554, slot = "Shoulder", name = "Pauldrons of Nalorakk", sources = { [14]=35469, [15]=35469 } },
                { id = 69556, slot = "Wrist", name = "Armbands of the Bear Spirit", sources = { [14]=35471, [15]=35471 } },
            },
        },
        {
            index              = 3,
            name               = "Jan'alai",
            journalEncounterID = 188,
            dungeonEncounterID = 1191,
            achievements       = {
            },
            loot = {
                { id = 69562, slot = "Feet", name = "Boots of Bad Mojo", sources = { [14]=35477, [15]=35477 } },
                { id = 69560, slot = "Shoulder", name = "Jan'alai's Spaulders", sources = { [14]=35475, [15]=35475 } },
                { id = 69561, slot = "Waist", name = "Hawkscale Waistguard", sources = { [14]=35476, [15]=35476 } },
                { id = 69559, slot = "Wrist", name = "Amani'shi Bracers", sources = { [14]=35474, [15]=35474 } },
            },
        },
        {
            index              = 4,
            name               = "Halazzi",
            journalEncounterID = 189,
            dungeonEncounterID = 1192,
            achievements       = {
                { id = 5750, name = "Tunnel Vision", soloable = "yes" },
            },
            loot = {
                { id = 69565, slot = "Chest", name = "Breastplate of Primal Fury", sources = { [14]=35479, [15]=35479 } },
                { id = 69564, slot = "Head", name = "The Savager's Mask", sources = { [14]=35478, [15]=35478 } },
                { id = 69568, slot = "Wrist", name = "Shadowmender Wristguards", sources = { [14]=35481, [15]=35481 } },
                { id = 69567, slot = "Wrist", name = "Wristwraps of Departed Spirits", sources = { [14]=35480, [15]=35480 } },
            },
        },
        {
            index              = 5,
            name               = "Hex Lord Malacrass",
            journalEncounterID = 190,
            dungeonEncounterID = 1193,
            achievements       = {
            },
            loot = {
                { id = 69572, slot = "Back", name = "Hex Lord's Bloody Cloak", sources = { [14]=35484, [15]=35484 } },
                { id = 69569, slot = "Chest", name = "Shadowtooth Trollskin Breastplate", sources = { [14]=35482, [15]=35482 } },
                { id = 69573, slot = "Shoulder", name = "Pauldrons of Sacrifice", sources = { [14]=35485, [15]=35485 } },
                { id = 69570, slot = "Waist", name = "Waistband of Hexes", sources = { [14]=35483, [15]=35483 } },
                { id = 70080, slot = "Weapon", name = "Reforged Heartless", sources = { [14]=35686, [15]=35686 } },
            },
        },
        {
            index              = 6,
            name               = "Daakara",
            journalEncounterID = 191,
            dungeonEncounterID = 1194,
            achievements       = {
                { id = 5760, name = "Ring Out!", soloable = "yes" },
                { id = 5761, name = "Hex Mix", soloable = "yes" },
                { id = 5858, name = "Bear-ly Made It", soloable = "yes" },
            },
            loot = {
                { id = 69578, slot = "Chest", name = "Hexing Robes", sources = { [14]=35490, [15]=35490 } },
                { id = 69579, slot = "Head", name = "Amani Headdress", sources = { [14]=35491, [15]=35491 } },
                { id = 69577, slot = "Head", name = "Collar of Bones", sources = { [14]=35489, [15]=35489 } },
                { id = 69576, slot = "Head", name = "Headdress of Sharpened Vision", sources = { [14]=35488, [15]=35488 } },
                { id = 69580, slot = "Head", name = "Mask of Restless Spirits", sources = { [14]=35492, [15]=35492 } },
                { id = 69583, slot = "Legs", name = "Legguards of the Unforgiving", sources = { [14]=35495, [15]=35495 } },
                { id = 69582, slot = "Shoulder", name = "Skullpiercer Pauldrons", sources = { [14]=35494, [15]=35494 } },
                { id = 69574, slot = "Shoulder", name = "Tusked Shoulderpads", sources = { [14]=35486, [15]=35486 } },
                { id = 69581, slot = "Weapon", name = "Amani Scepter of Rites", sources = { [14]=35493, [15]=35493 } },
                { id = 69575, slot = "Weapon", name = "Mace of the Sacrificed", sources = { [14]=35487, [15]=35487 } },
            },
        },
    },
}
