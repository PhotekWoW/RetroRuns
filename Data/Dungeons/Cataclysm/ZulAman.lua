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
    routedIn          = "3.3.6",

    entrance = {
        mapID = 95,
        x     = 0.8220,
        y     = 0.6430,
    },

    -- Instance-wide achievements with no single boss; every boss lists them.
    raidAchievements = {
        { id = 5761, name = "Hex Mix", soloable = "yes" },
    },

    pois = {
        { mapID = 333, poiKind = "quest", mapLabel = "Bakkalzu", mapLabelPos = "below",
          hintNote = "Kill ^Akil'zon^ before the timer runs out, then free this prisoner for a reward.",
          points = { { 0.299, 0.326 } } },
        { mapID = 333, poiKind = "quest", mapLabel = "Hazlek", mapLabelPos = "below",
          hintNote = "Kill ^Nalorakk^ before the timer runs out, then free this prisoner for a reward.",
          points = { { 0.409, 0.846 } } },
        { mapID = 333, poiKind = "quest", mapLabel = "Norkani", mapLabelPos = "below",
          hintNote = "Kill ^Jan'alai^ before the timer runs out, then free this prisoner for a reward.",
          points = { { 0.547, 0.761 } } },
        { mapID = 333, poiKind = "quest", mapLabel = "Kasha", mapLabelPos = "below",
          hintNote = "Kill ^Halazzi^ before the timer runs out, then free this prisoner for a reward.",
          points = { { 0.602, 0.219 } } },
        { mapID = 333, poiKind = "pet", tag = "Forest Frog", mapLabelPos = "legend-bottomleft",
          hintNote = "Use an ^Amani Hex Stick^ on a ^Forest Frog^ for a chance that ^Mojo^ appears and hops into your bags. The sticks drop from trash in the dungeon.",
          navPoint = { 0.383, 0.538 },
          points = { { 0.374, 0.569 }, { 0.376, 0.557 }, { 0.378, 0.510 }, { 0.381, 0.503 }, { 0.384, 0.566 }, { 0.388, 0.518 }, { 0.390, 0.505 }, { 0.393, 0.574 }, { 0.509, 0.512 }, { 0.509, 0.537 } } },
    },

    trashLoot = {
        { id = 69797, slot = "Hands", name = "Charmbinder Grips", sources = { [14]=35565, [15]=35565 }, bind = "BoE" },
        { id = 69798, slot = "Hands", name = "Knotted Handwraps", sources = { [14]=35566, [15]=35566 }, bind = "BoE" },
        { id = 69801, slot = "Wrist", name = "Amani Armguards", sources = { [14]=35568, [15]=35568 }, bind = "BoE" },
        { id = 33993, kind = "pet", name = "Mojo", tag = "Forest Frog" },
    },

    -- The hostage event's chests, shown in the browser's event section.
    eventLabel = "Hostage Rescue",
    eventNote  = "Kill the four animal bosses before the timer runs out to free their prisoners. Each freed prisoner leaves a chest, and its loot depends on how many you have freed so far: the fourth chest holds the Amani Battle Bear.",
    eventLoot = {
        { id = 69584, slot = "Back", name = "Recovered Cloak of Frostheim", sources = { [14]=35496, [15]=35496 }, bind = "BoP", tag = "2nd Rescue" },
        { id = 69587, slot = "Chest", name = "Chestplate of Hubris", sources = { [14]=35499, [15]=35499 }, bind = "BoP", tag = "2nd Rescue" },
        { id = 69588, slot = "Feet", name = "Skullcrusher Warboots", sources = { [14]=35500, [15]=35500 }, bind = "BoP", tag = "2nd Rescue" },
        { id = 69586, slot = "Feet", name = "Two-Toed Boots", sources = { [14]=35498, [15]=35498 }, bind = "BoP", tag = "2nd Rescue" },
        { id = 69585, slot = "Wrist", name = "Wristwraps of Madness", sources = { [14]=35497, [15]=35497 }, bind = "BoP", tag = "2nd Rescue" },
        { id = 69593, slot = "Chest", name = "Battleplate of the Amani Empire", sources = { [14]=35505, [15]=35505 }, bind = "BoP", tag = "3rd Rescue" },
        { id = 69590, slot = "Hands", name = "Mojo-Mender's Gloves", sources = { [14]=35502, [15]=35502 }, bind = "BoP", tag = "3rd Rescue" },
        { id = 69589, slot = "Legs", name = "Leggings of Dancing Blades", sources = { [14]=35501, [15]=35501 }, bind = "BoP", tag = "3rd Rescue" },
        { id = 69592, slot = "Two-Hand", name = "Reforged Trollbane", sources = { [14]=35504, [15]=35504 }, bind = "BoP", tag = "3rd Rescue" },
        { id = 69591, slot = "Weapon", name = "Voodoo Hexblade", sources = { [14]=35503, [15]=35503 }, bind = "BoP", tag = "3rd Rescue" },
        { id = 69747, kind = "mount", name = "Amani Battle Bear", tag = "4th Rescue" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Akil'zon",
            journalEncounterID = 186,
            dungeonEncounterID = 1189,
            achievements       = {
                { id = 5858, name = "Bear-ly Made It", soloable = "yes" },
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
                { id = 5858, name = "Bear-ly Made It", soloable = "yes" },
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
                { id = 5858, name = "Bear-ly Made It", soloable = "yes" },
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
                { id = 5858, name = "Bear-ly Made It", soloable = "yes" },
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

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Akil'zon (boss 1). Vol'jin's first line follows the talk, his
        -- second the gong, and the doors open on it.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Akil'zon",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 333 },
                    kind            = "poi",
                    note            = "After zoning in, go around the corner and talk to ^Vol'jin^ to start the dungeon.",
                    minNote         = "Talk to Vol'jin to start",
                    mapLabel        = "Talk to Vol'jin",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    points          = {
                        { 0.140, 0.528 },
                    },
                },
                {
                    when        = { mapID = 333 },
                    kind        = "path",
                    note        = "Follow ^Vol'jin^ over to the ^Strange Gong^. Hit it once, and let your swing animation keep going on its own until the doors open.",
                    minNote     = "Follow Vol'jin and hit the gong",
                    triggeredBy = { dialog = { npc = "Vol'jin", match = "both of us to open these gates" } },
                    points      = { },
                },
                {
                    when         = { mapID = 333 },
                    kind         = "path",
                    note         = "With the doors open, go down the stairs and take the northern route until you reach ^Akil'zon^. Kill all trash on the way or the boss can despawn.",
                    minNote      = "Downstairs and north to Akil'zon",
                    triggeredBy  = { dialog = { npc = "Vol'jin", match = "deny you rulership of da Amani" } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.209, 0.532 },
                        { 0.250, 0.533 },
                        { 0.264, 0.486 },
                        { 0.341, 0.491 },
                        { 0.355, 0.467 },
                        { 0.356, 0.447 },
                        { 0.339, 0.440 },
                        { 0.322, 0.443 },
                        { 0.297, 0.431 },
                        { 0.298, 0.406 },
                        { 0.314, 0.404 },
                        { 0.339, 0.399 },
                        { 0.374, 0.403 },
                        { 0.382, 0.384 },
                        { 0.377, 0.353 },
                        { 0.360, 0.266 },
                    },
                },
            },
        },
        -- 2. Nalorakk (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Nalorakk",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 333 },
                    kind    = "path",
                    note    = "After killing ^Akil'zon^, follow the path all the way south to ^Nalorakk^. Again, kill trash on the way to the boss.",
                    minNote = "South to Nalorakk. Kill trash",
                    points  = {
                        { 0.360, 0.277 },
                        { 0.380, 0.366 },
                        { 0.380, 0.399 },
                        { 0.352, 0.405 },
                        { 0.306, 0.404 },
                        { 0.292, 0.416 },
                        { 0.298, 0.440 },
                        { 0.355, 0.447 },
                        { 0.351, 0.481 },
                        { 0.344, 0.495 },
                        { 0.345, 0.621 },
                        { 0.317, 0.624 },
                        { 0.309, 0.645 },
                        { 0.312, 0.673 },
                        { 0.342, 0.673 },
                        { 0.342, 0.769 },
                        { 0.381, 0.769 },
                    },
                },
            },
        },
        -- 3. Jan'alai (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Jan'alai",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 333 },
                    kind    = "path",
                    note    = "After defeating ^Nalorakk^, go south and follow the path to ^Jan'alai^.",
                    minNote = "South to Jan'alai",
                    points  = {
                        { 0.361, 0.767 },
                        { 0.345, 0.772 },
                        { 0.341, 0.796 },
                        { 0.340, 0.858 },
                        { 0.335, 0.900 },
                        { 0.349, 0.926 },
                        { 0.391, 0.920 },
                        { 0.418, 0.890 },
                        { 0.442, 0.914 },
                        { 0.477, 0.905 },
                        { 0.494, 0.866 },
                        { 0.540, 0.833 },
                        { 0.572, 0.840 },
                        { 0.598, 0.838 },
                        { 0.604, 0.813 },
                        { 0.586, 0.784 },
                        { 0.553, 0.766 },
                        { 0.553, 0.743 },
                    },
                },
            },
        },
        -- 4. Halazzi (boss 4).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Halazzi",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 333 },
                    kind    = "path",
                    note    = "After killing ^Jan'alai^, go north and follow the path to ^Halazzi^.",
                    minNote = "North to Halazzi",
                    points  = {
                        { 0.554, 0.674 },
                        { 0.557, 0.465 },
                        { 0.582, 0.438 },
                        { 0.581, 0.396 },
                        { 0.606, 0.397 },
                        { 0.629, 0.342 },
                        { 0.637, 0.310 },
                        { 0.659, 0.300 },
                        { 0.672, 0.263 },
                        { 0.722, 0.229 },
                        { 0.757, 0.223 },
                        { 0.764, 0.202 },
                        { 0.751, 0.149 },
                        { 0.710, 0.144 },
                        { 0.690, 0.151 },
                        { 0.683, 0.176 },
                        { 0.668, 0.235 },
                        { 0.612, 0.236 },
                    },
                },
            },
        },
        -- 5. Hex Lord Malacrass (boss 5).
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Hex Lord Malacrass",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 333 },
                    kind    = "path",
                    note    = "After defeating ^Halazzi^, go south and follow the path east to ^Hex Lord Malacrass^.",
                    minNote = "Follow path to Malacrass",
                    points  = {
                        { 0.581, 0.305 },
                        { 0.580, 0.455 },
                        { 0.555, 0.470 },
                        { 0.555, 0.545 },
                        { 0.685, 0.543 },
                    },
                },
            },
        },
        -- 6. Daakara (boss 6).
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Daakara",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 333 },
                    kind    = "path",
                    note    = "After you take down ^Hex Lord Malacrass^, open the door and continue ahead to the final boss, ^Daakara^.",
                    minNote = "East to Daakara",
                    points  = {
                        { 0.737, 0.531 },
                        { 0.782, 0.532 },
                        { 0.790, 0.511 },
                        { 0.803, 0.501 },
                        { 0.818, 0.508 },
                        { 0.828, 0.531 },
                        { 0.880, 0.531 },
                    },
                },
            },
        },
    },
}
