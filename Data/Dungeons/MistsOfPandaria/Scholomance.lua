-------------------------------------------------------------------------------
-- RetroRuns Data -- Scholomance
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 1007  |  journalInstanceID: 246
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[246] = {
    kind              = "dungeon",
    instanceID        = 1007,
    journalInstanceID = 246,
    name              = "Scholomance",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",
    timewalking       = true,

    entrance = {
        mapID = 22,
        x     = 0.6896,
        y     = 0.7272,
    },

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    -- Appearances that drop only in the original Scholomance, reopened
    -- behind an attunement. Listed here because this is the instance a
    -- player browses; the note under the block says how to get in.
    legacyLabel = "Legacy of Scholomance",
    legacyNote  = {
        text   = "Legacy of Scholomance requires a one-time attunement that starts with {item}, dropped by ^Doctor Theolen Krastinov^, a Heroic-only rare that spawns after ^Rattlegore^ dies. After defeating ^Darkmaster Gandling^, use the toy on the pile of bones to summon ^Eva Sarkhoff^ and accept her quest. Once attuned, use {item2} at Caer Darrow to enter.",
        emphasis = "Legacy of Scholomance",
        itemID  = 88566,
        itemID2 = 206346,
        travel = {
            mapID = 22,
            x     = 0.6970,
            y     = 0.7170,
            vendorName = "Eva's Journal",
            zoneSub = "Caer Darrow",
        },
    },
    legacyLoot = {
        { id = 18689, slot = "Back", name = "Phantasmal Cloak", sources = { [14]=7432 }, bossNpc = "Jandice Barov" },
        { id = 13314, slot = "Chest", name = "Alanna's Embrace", sources = { [14]=4831 }, bossNpc = "Ras Frostwhisper" },
        { id = 14340, slot = "Chest", name = "Freezing Lich Robes", sources = { [14]=5348 }, bossNpc = "Ras Frostwhisper" },
        { id = 13944, slot = "Chest", name = "Tombstone Breastplate", sources = { [14]=5070 }, bossNpc = "Darkmaster Gandling" },
        { id = 13398, slot = "Feet", name = "Boots of the Shrieker", sources = { [14]=4876 }, bossNpc = "Darkmaster Gandling" },
        { id = 14537, slot = "Feet", name = "Corpselight Greaves", sources = { [14]=5450 }, bossNpc = "Rattlegore" },
        { id = 18692, slot = "Feet", name = "Death Knight Sabatons", sources = { [14]=7434 }, bossNpc = "Marduk Blackpool" },
        { id = 18694, slot = "Feet", name = "Shadowy Mail Greaves", sources = { [14]=7436 }, bossNpc = "Ras Frostwhisper" },
        { id = 13967, slot = "Feet", name = "Windreaver Greaves", sources = { [14]=5085 }, bossNpc = "Kirtonos the Herald" },
        { id = 14525, slot = "Hands", name = "Boneclenched Gauntlets", sources = { [14]=5441 }, bossNpc = "Ras Frostwhisper" },
        { id = 13957, slot = "Hands", name = "Gargoyle Slashers", sources = { [14]=5078 }, bossNpc = "Kirtonos the Herald" },
        { id = 18693, slot = "Hands", name = "Shivery Handwraps", sources = { [14]=7435 }, bossNpc = "Ras Frostwhisper" },
        { id = 14539, slot = "Head", name = "Bone Ring Helm", sources = { [14]=5452 }, bossNpc = "Rattlegore" },
        { id = 14545, slot = "Legs", name = "Ghostloom Leggings", sources = { [14]=5455 }, bossNpc = "Jandice Barov" },
        { id = 14522, slot = "Legs", name = "Maelstrom Leggings", sources = { [14]=5439 }, bossNpc = "Ras Frostwhisper" },
        { id = 14577, slot = "Legs", name = "Skullsmoke Pants", sources = { [14]=5482 }, bossNpc = "Vectus" },
        { id = 18690, slot = "Legs", name = "Wraithplate Leggings", sources = { [14]=7433 }, bossNpc = "Jandice Barov" },
        { id = 18696, slot = "Off-hand", name = "Intricately Runed Shield", sources = { [14]=7438 }, bossNpc = "Ras Frostwhisper" },
        { id = 14528, slot = "Off-hand", name = "Rattlecage Buckler", sources = { [14]=5443 }, bossNpc = "Rattlegore" },
        { id = 18695, slot = "Off-hand", name = "Spellbound Tome", sources = { [14]=7437 }, bossNpc = "Ras Frostwhisper" },
        { id = 13938, slot = "Ranged", name = "Bonecreeper Stylus", sources = { [14]=5069 }, bossNpc = "Darkmaster Gandling" },
        { id = 14617, slot = "Shirt", name = "Sawbones Shirt", sources = { [14]=5518 }, bossNpc = "Doctor Theolen Krastinov" },
        { id = 18686, slot = "Shoulder", name = "Bone Golem Shoulders", sources = { [14]=7431 }, bossNpc = "Rattlegore" },
        { id = 14538, slot = "Shoulder", name = "Deadwalker Mantle", sources = { [14]=5451 }, bossNpc = "Rattlegore" },
        { id = 14503, slot = "Shoulder", name = "Death's Clutch", sources = { [14]=5438 }, bossNpc = "Ras Frostwhisper" },
        { id = 14548, slot = "Shoulder", name = "Royal Cap Spaulders", sources = { [14]=5456 }, bossNpc = "Jandice Barov" },
        { id = 13955, slot = "Shoulder", name = "Stoneform Shoulders", sources = { [14]=5076 }, bossNpc = "Kirtonos the Herald" },
        { id = 14541, slot = "Two-Hand", name = "Barovian Family Sword", sources = { [14]=5453 }, bossNpc = "Jandice Barov" },
        { id = 14531, slot = "Two-Hand", name = "Frightskull Shaft", sources = { [14]=5444 }, bossNpc = "Rattlegore" },
        { id = 13983, slot = "Two-Hand", name = "Gravestone War Axe", sources = { [14]=5088 }, bossNpc = "Kirtonos the Herald" },
        { id = 13937, slot = "Two-Hand", name = "Headmaster's Charge", sources = { [14]=5068 }, bossNpc = "Darkmaster Gandling" },
        { id = 22394, slot = "Two-Hand", name = "Staff of Metanoia", sources = { [14]=8812 }, bossNpc = "Jandice Barov" },
        { id = 13956, slot = "Waist", name = "Clutch of Andros", sources = { [14]=5077 }, bossNpc = "Kirtonos the Herald" },
        { id = 14502, slot = "Waist", name = "Frostbite Girdle", sources = { [14]=5437 }, bossNpc = "Ras Frostwhisper" },
        { id = 14487, slot = "Weapon", name = "Bonechill Hammer", sources = { [14]=5436 }, bossNpc = "Ras Frostwhisper" },
        { id = 14576, slot = "Weapon", name = "Ebon Hilt of Marduk", sources = { [14]=5481 }, bossNpc = "Marduk Blackpool" },
        { id = 14024, slot = "Weapon", name = "Frightalon", sources = { [14]=5092 }, bossNpc = "Kirtonos the Herald" },
        { id = 13952, slot = "Weapon", name = "Iceblade Hacker", sources = { [14]=5073 }, bossNpc = "Ras Frostwhisper" },
        { id = 13953, slot = "Weapon", name = "Silent Fang", sources = { [14]=5074 }, bossNpc = "Darkmaster Gandling" },
        { id = 13964, slot = "Weapon", name = "Witchblade", sources = { [14]=5084 }, bossNpc = "Darkmaster Gandling" },
        { id = 13969, slot = "Wrist", name = "Loomguard Armbraces", sources = { [14]=5086 }, bossNpc = "Kirtonos the Herald" },
        { id = 13951, slot = "Wrist", name = "Vigorsteel Vambraces", sources = { [14]=5072 }, bossNpc = "Darkmaster Gandling" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Instructor Chillheart",
            journalEncounterID = 659,
            dungeonEncounterID = 1426,
            achievements       = {
            },
            loot = {
                { id = 88338, slot = "Chest", name = "Breastplate of Wracking Souls", sources = { [14]=45701, [15]=84302 } },
                { id = 88339, slot = "Two-Hand", name = "Gravetouch Greatsword", sources = { [14]=45702, [15]=84469 } },
                { id = 88336, slot = "Waist", name = "Icewrath Belt", sources = { [14]=45699, [15]=84470 } },
                { id = 88337, slot = "Wrist", name = "Shadow Puppet Bracers", sources = { [14]=45700, [15]=84468 } },
            },
        },
        {
            index              = 2,
            name               = "Jandice Barov",
            journalEncounterID = 663,
            dungeonEncounterID = 1427,
            achievements       = {
                { id = 6531, name = "Attention to Detail", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 88349, slot = "Back", name = "Phantasmal Drape", sources = { [14]=45712, [15]=84476 } },
                { id = 88348, slot = "Feet", name = "Wraithplate Treads", sources = { [14]=45711, [15]=84348 } },
                { id = 88345, slot = "Head", name = "Barovian Ritual Hood", sources = { [14]=45708, [15]=84364 } },
                { id = 88347, slot = "Legs", name = "Ghostwoven Legguards", sources = { [14]=45710, [15]=84347 } },
                { id = 88346, slot = "Off-hand", name = "Metanoia Shield", sources = { [14]=45709, [15]=84475 } },
            },
        },
        {
            index              = 3,
            name               = "Rattlegore",
            journalEncounterID = 665,
            dungeonEncounterID = 1428,
            achievements       = {
                { id = 6394, name = "Rattle No More", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 88343, slot = "Feet", name = "Bone Golem Boots", sources = { [14]=45706, [15]=84346 } },
                { id = 88342, slot = "Hands", name = "Rattling Gloves", sources = { [14]=45705, [15]=84474 } },
                { id = 88341, slot = "Ranged", name = "Necromantic Wand", sources = { [14]=45704, [15]=84473 } },
                { id = 88357, slot = "Shoulder", name = "Vigorsteel Spaulders", sources = { [14]=45718, [15]=84350 } },
                { id = 88344, slot = "Two-Hand", name = "Goresoaked Headreaper", sources = { [14]=45707, [15]=84471 } },
                { id = 88340, slot = "Wrist", name = "Deadwalker Bracers", sources = { [14]=45703, [15]=84472 } },
            },
        },
        {
            index              = 4,
            name               = "Lilian Voss",
            journalEncounterID = 666,
            dungeonEncounterID = 1429,
            achievements       = {
            },
            loot = {
                { id = 88352, slot = "Chest", name = "Shivbreaker Vest", sources = { [14]=45715, [15]=84303 } },
                { id = 88353, slot = "Hands", name = "Dark Blaze Gauntlets", sources = { [14]=45716, [15]=84477 } },
                { id = 88351, slot = "Head", name = "Soulburner Crown", sources = { [14]=45714, [15]=84365 } },
                { id = 88350, slot = "Legs", name = "Leggings of Unleashed Anguish", sources = { [14]=45713, [15]=84349 } },
            },
        },
        {
            index              = 5,
            name               = "Darkmaster Gandling",
            journalEncounterID = 684,
            dungeonEncounterID = 1430,
            achievements       = {
                { id = 6396, name = "Sanguinarian", meta = true, soloable = "yes" },
                { id = 6821, name = "School's Out Forever", meta = true, soloable = "no" },
            },
            loot = {
                { id = 88361, slot = "Hands", name = "Gloves of Explosive Pain", sources = { [14]=45720, [15]=84480 } },
                { id = 88356, slot = "Hands", name = "Tombstone Gauntlets", sources = { [14]=45717, [15]=84478 } },
                { id = 88362, slot = "Shoulder", name = "Shoulderguards of Painful Lessons", sources = { [14]=45721, [15]=84351 } },
                { id = 144211, slot = "Two-Hand", name = "Headmaster's Will", sources = { [15]=84479 } },
                { id = 88359, slot = "Waist", name = "Incineration Belt", sources = { [14]=45719, [15]=84481 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    pois = {
        { mapID = 477, subZone = "Butcher's Sanctum", poiKind = "rare", rareNpc = "Doctor Theolen Krastinov",
          mapLabelPos = "legend-bottomleft",
          hintNote  = "Spawns only after ^Rattlegore^ dies, Heroic only. Drops ^Krastinov's Bag of Horrors^, the toy that starts the Legacy of Scholomance attunement.",
          hintWhere = "Location: Butcher's Sanctum, past ^Rattlegore^",
          points = { { 0.367, 0.470 } } },
    },

    routing = {
        -- 1. Instructor Chillheart (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Instructor Chillheart",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 476 },
                    kind    = "path",
                    note    = "After zoning in, walk through the ^Iron Gate^ and down the stairs to find the first boss, ^Instructor Chillheart^.",
                    minNote = "Ahead to Instructor Chillheart",
                    points  = {
                        { 0.176, 0.659 },
                        { 0.176, 0.603 },
                        { 0.483, 0.601 },
                        { 0.483, 0.400 },
                        { 0.520, 0.400 },
                        { 0.627, 0.586 },
                    },
                },
            },
        },
        -- 2. Jandice Barov (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Jandice Barov",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 476 },
                    kind    = "path",
                    note    = "After defeating ^Instructor Chillheart^, exit the room to the northeast and make your way down the ramp.",
                    minNote = "Exit northeast to ramp",
                    points  = {
                        { 0.683, 0.576 },
                        { 0.780, 0.519 },
                        { 0.854, 0.520 },
                        { 0.854, 0.240 },
                        { 0.753, 0.241 },
                    },
                },
                {
                    when    = { mapID = 477 },
                    kind    = "path",
                    note    = "Inside the ^Hall of Illusions^, you will find ^Jandice Barov^ at the west end of the room.",
                    minNote = "West to Jandice",
                    points  = {
                        { 0.737, 0.263 },
                        { 0.673, 0.263 },
                        { 0.623, 0.206 },
                    },
                },
            },
        },
        -- 3. Rattlegore (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Rattlegore",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 477 },
                    kind    = "path",
                    note    = "After killing ^Jandice Barov^, continue west into the next room and clear trash to engage ^Rattlegore^.",
                    minNote = "West to Rattlegore",
                    points  = {
                        { 0.601, 0.256 },
                        { 0.518, 0.256 },
                    },
                },
            },
        },
        -- 4. Lilian Voss (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Lilian Voss",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 477 },
                    kind    = "path",
                    note    = "After defeating ^Rattlegore^, continue west into the next area. Open the ^Iron Gate^ to reach ^Lilian Voss^ ahead.",
                    minNote = "Path to Lilian Voss",
                    points  = {
                        { 0.435, 0.263 },
                        { 0.372, 0.262 },
                        { 0.374, 0.431 },
                        { 0.418, 0.471 },
                        { 0.490, 0.471 },
                    },
                },
            },
        },
        -- 5. Darkmaster Gandling (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Darkmaster Gandling",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 477 },
                    kind    = "path",
                    note    = "After completing the ^Lilian Voss^ encounter, grab her loot chest and head south through ^The Viewing Room^.",
                    minNote = "South through The Viewing Room",
                    points  = {
                        { 0.543, 0.562 },
                        { 0.545, 0.670 },
                        { 0.479, 0.839 },
                        { 0.479, 0.894 },
                        { 0.574, 0.894 },
                        { 0.574, 0.974 },
                    },
                },
                {
                    when    = { mapID = 478 },
                    kind    = "path",
                    note    = "Go down the stairs and kill ^Darkmaster Gandling^ to complete the run.",
                    minNote = "Downstairs to kill Gandling",
                    points  = {
                        { 0.494, 0.130 },
                        { 0.494, 0.305 },
                    },
                },
            },
        },
    },
}
