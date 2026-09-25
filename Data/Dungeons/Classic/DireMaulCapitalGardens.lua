-------------------------------------------------------------------------------
-- RetroRuns Data -- Dire Maul - Capital Gardens
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.3  |  instanceID: 429  |  journalInstanceID: 230
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[230] = {
    kind              = "dungeon",
    instanceID        = 429,
    journalInstanceID = 230,
    name              = "Dire Maul - Capital Gardens",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.3",
    timewalking       = true,

    -- All three Dire Maul wings share instanceID 429, so the instance id
    -- alone cannot say which one the player entered. These are this wing's
    -- floors out of the six in UiMapGroupMember group 159 (235 Gordok
    -- Commons; 236/237/238 the west wing; 239/240 the east).
    uiMaps = { 236, 237, 238 },

    entrance = {
        mapID = 69,
        x     = 0.6030,
        y     = 0.3010,
    },

    pois = {
        -- Tsu'zee roams the Court of the Highborne walkways.
        { mapID = 237, poiKind = "rare", rareNpc = "Tsu'zee", mapLabelPos = "above", points = { { 0.306, 0.438 }, { 0.314, 0.142 }, { 0.320, 0.376 }, { 0.322, 0.200 }, { 0.328, 0.302 }, { 0.358, 0.526 }, { 0.376, 0.226 }, { 0.442, 0.230 }, { 0.520, 0.248 }, { 0.572, 0.172 } } },
        { mapID = 238, poiKind = "vendor", mapLabel = "Shen'dralar Provisioner",
          mapLabelPos = "above",
          points = { { 0.820, 0.269 } } },
    },

    trashLoot = {
        { id = 18339, slot = "Back", name = "Eidolon Cloak", sources = { [14]=7278 }, bind = "BoE" },
        { id = 18387, slot = "Hands", name = "Brightspark Gloves", sources = { [14]=7308 }, bind = "BoP", rareNpc = "Tsu'zee" },
        { id = 18346, slot = "Legs", name = "Threadbare Trousers", sources = { [14]=7282 }, bind = "BoP", rareNpc = "Tsu'zee" },
        { id = 18338, slot = "Ranged", name = "Wand of Arcane Potency", sources = { [14]=7277 }, bind = "BoE" },
        { id = 18337, slot = "Wrist", name = "Orphic Bracers", sources = { [14]=7276 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Tendris Warpwood",
            journalEncounterID = 406,
            dungeonEncounterID = 350,
            achievements       = {
            },
            loot = {
                { id = 18390, slot = "Legs", name = "Tanglemoss Leggings", sources = { [14]=7311 } },
                { id = 18352, slot = "Off-hand", name = "Petrified Bark Shield", sources = { [14]=7288 } },
                { id = 18353, slot = "Two-Hand", name = "Stoneflower Staff", sources = { [14]=7289 } },
                { id = 18393, slot = "Waist", name = "Warpwood Binding", sources = { [14]=7314 } },
            },
        },
        {
            index              = 2,
            name               = "Illyanna Ravenoak",
            journalEncounterID = 407,
            dungeonEncounterID = 347,
            achievements       = {
            },
            loot = {
                { id = 18383, slot = "Hands", name = "Force Imbued Gauntlets", sources = { [14]=7304 } },
                { id = 18349, slot = "Hands", name = "Gauntlets of Accuracy", sources = { [14]=7285 } },
                { id = 18377, slot = "Hands", name = "Quickdraw Gloves", sources = { [14]=7299 } },
                { id = 18386, slot = "Legs", name = "Padre's Trousers", sources = { [14]=7307 } },
                { id = 18347, slot = "Weapon", name = "Well Balanced Axe", sources = { [14]=7283 } },
            },
        },
        {
            index              = 3,
            name               = "Magister Kalendris",
            journalEncounterID = 408,
            dungeonEncounterID = 348,
            achievements       = {
            },
            loot = {
                { id = 18350, slot = "Back", name = "Amplifying Cloak", sources = { [14]=7286 } },
                { id = 18374, slot = "Shoulder", name = "Flamescarred Shoulders", sources = { [14]=7296 } },
                { id = 18351, slot = "Wrist", name = "Magically Sealed Bracers", sources = { [14]=7287 } },
            },
        },
        {
            index              = 4,
            name               = "Immol'thar",
            journalEncounterID = 409,
            dungeonEncounterID = 349,
            achievements       = {
            },
            loot = {
                { id = 18389, slot = "Back", name = "Cloak of the Cosmos", sources = { [14]=7310 } },
                { id = 18385, slot = "Chest", name = "Robe of Everlasting Night", sources = { [14]=7306 } },
                { id = 18379, slot = "Feet", name = "Odious Greaves", sources = { [14]=7301 } },
                { id = 18384, slot = "Shoulder", name = "Bile-Etched Spaulders", sources = { [14]=7305 } },
                { id = 18391, slot = "Waist", name = "Eyestalk Cord", sources = { [14]=7312 } },
                { id = 18372, slot = "Weapon", name = "Blade of the New Moon", sources = { [14]=7294 } },
                { id = 18394, slot = "Wrist", name = "Demon Howl Wristguards", sources = { [14]=7315 } },
            },
        },
        {
            index              = 5,
            name               = "Prince Tortheldrin",
            journalEncounterID = 410,
            dungeonEncounterID = 361,
            achievements       = {
            },
            loot = {
                { id = 18382, slot = "Back", name = "Fluctuating Cloak", sources = { [14]=7303 } },
                { id = 18373, slot = "Chest", name = "Chestplate of Tranquility", sources = { [14]=7295 } },
                { id = 18380, slot = "Legs", name = "Eldritch Reinforced Legplates", sources = { [14]=7302 } },
                { id = 18378, slot = "Legs", name = "Silvermoon Leggings", sources = { [14]=7300 } },
                { id = 18388, slot = "Ranged", name = "Stoneshatter", sources = { [14]=7309 } },
                { id = 18392, slot = "Weapon", name = "Distracting Dagger", sources = { [14]=7313 } },
                { id = 18396, slot = "Weapon", name = "Mind Carver", sources = { [14]=7316 } },
                { id = 18376, slot = "Weapon", name = "Timeworn Mace", sources = { [14]=7298 } },
                { id = 18375, slot = "Wrist", name = "Bracers of the Eclipse", sources = { [14]=7297 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Tendris Warpwood (boss 1), past the first shield generator.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Tendris Warpwood",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 236 },
                    kind    = "path",
                    note    = "After zoning in, proceed west and deactivate the first ^Shield Generator^ by clearing the trash around it.",
                    minNote = "Deactivate first shield generator",
                    points  = {
                        { 0.930, 0.444 },
                        { 0.886, 0.437 },
                        { 0.777, 0.490 },
                        { 0.736, 0.523 },
                    },
                },
                {
                    when        = { mapID = 236 },
                    kind        = "poi",
                    noMarker    = true,
                    highlightCircle = true,
                    mapLabel    = "Shield Generator 1",
                    mapLabelPos = "above",
                    completionCheck = true,
                    triggeredBy = { scenario = 25064, quantity = 1 },
                    points      = {
                        { 0.698, 0.528 },
                    },
                },
                {
                    when    = { mapID = 236 },
                    kind    = "path",
                    note    = "Next, continue west down the ramp to find ^Tendris Warpwood^.",
                    minNote = "West down ramp to Tendris",
                    points  = {
                        { 0.620, 0.555 },
                        { 0.519, 0.528 },
                        { 0.362, 0.537 },
                    },
                },
            },
        },
        -- 2. Magister Kalendris (boss 3). Two segments: up out of the
        -- gardens on 236, then the Court itself on 237. Route order is the
        -- WALK, not the journal; bossIndex stays the journal index.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 3,
            title     = "Magister Kalendris",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 236 },
                    kind    = "path",
                    note    = "After defeating ^Tendris Warpwood^, go back up the ramp and take a left towards the map exit labeled ^Court of the Highborne^.",
                    minNote = "Up ramp to Court of the Highborne",
                    points  = {
                        { 0.374, 0.526 },
                        { 0.536, 0.530 },
                        { 0.533, 0.432 },
                        { 0.484, 0.428 },
                        { 0.453, 0.347 },
                        { 0.412, 0.341 },
                    },
                },
                {
                    when    = { mapID = 237 },
                    kind    = "path",
                    note    = "Inside ^Court of the Highborne^, take a left and you will find ^Magister Kalendris^ standing against the western wall.",
                    minNote = "Left to Magister Kalendris",
                    points  = {
                        { 0.558, 0.206 },
                        { 0.339, 0.224 },
                        { 0.302, 0.452 },
                    },
                },
            },
        },
        -- 3. Illyanna Ravenoak (boss 2), who patrols with her bear. The
        -- stairs on 237, then the top floor back on 236 by way of the
        -- second shield generator.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 2,
            title     = "Illyanna Ravenoak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 237 },
                    kind    = "path",
                    note    = "After killing ^Magister Kalendris^, go up the stairs at the north end of the room.",
                    minNote = "Up the northern stairs",
                    points  = {
                        { 0.303, 0.425 },
                        { 0.305, 0.217 },
                        { 0.514, 0.221 },
                        { 0.506, 0.129 },
                        { 0.414, 0.124 },
                    },
                },
                {
                    when    = { mapID = 236 },
                    kind    = "path",
                    note    = "Once you reach the top floor, go slightly east to deactivate the second ^Shield Generator^.",
                    minNote = "East to second Shield Generator",
                    points  = {
                        { 0.196, 0.190 },
                        { 0.196, 0.235 },
                        { 0.377, 0.227 },
                    },
                },
                {
                    when        = { mapID = 236 },
                    kind        = "poi",
                    noMarker    = true,
                    highlightCircle = true,
                    mapLabel    = "Shield Generator 2",
                    mapLabelPos = "above",
                    completionCheck = true,
                    triggeredBy = { scenario = 25064, quantity = 2 },
                    points      = {
                        { 0.410, 0.225 },
                    },
                },
                {
                    when    = { mapID = 236 },
                    kind    = "path",
                    note    = "After deactivating the second ^Shield Generator^, continue clockwise to find the third ^Shield Generator^ on the south end of the area.",
                    minNote = "South to third Shield Generator",
                    points  = {
                        { 0.442, 0.226 },
                        { 0.485, 0.227 },
                        { 0.486, 0.822 },
                        { 0.460, 0.822 },
                    },
                },
                {
                    when        = { mapID = 236 },
                    kind        = "poi",
                    noMarker    = true,
                    highlightCircle = true,
                    mapLabel    = "Shield Generator 3",
                    mapLabelPos = "above",
                    completionCheck = true,
                    triggeredBy = { scenario = 25064, quantity = 3 },
                    points      = {
                        { 0.407, 0.833 },
                    },
                },
                {
                    when    = { mapID = 236 },
                    kind    = "path",
                    note    = "After deactivating the third ^Shield Generator^, continue clockwise and find ^Illyanna Ravenoak^ patrolling with her bear, ^Ferra^.",
                    minNote = "West to Illyanna",
                    points  = {
                        { 0.353, 0.826 },
                        { 0.230, 0.806 },
                    },
                },
            },
        },
        -- 4. Immol'thar (boss 4). Two segments: down and out of the Court
        -- on 236, then the prison itself on 238.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Immol'thar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 236 },
                    kind    = "path",
                    note    = "After killing ^Illyanna Ravenoak^, find a place to jump down into the area where you killed ^Tendris Warpwood^ earlier. Take the exit labeled ^Prison of Immol'Thar^.",
                    minNote = "Jump down, take door to Prison",
                    points  = {
                        { 0.247, 0.783 },
                        { 0.435, 0.779 },
                        { 0.453, 0.810 },
                        { 0.484, 0.810 },
                        { 0.481, 0.651 },
                        { 0.429, 0.651 },
                        { 0.339, 0.651 },
                        { 0.310, 0.464 },
                    },
                },
                {
                    when    = { mapID = 238 },
                    kind    = "path",
                    note    = "In the next area, continue west and you'll run straight into ^Immol'thar^. You can deactivate the remaining two ^Shield Generators^ if you need to for a quest, but they are not required.",
                    minNote = "West to Immol'thar",
                    points  = {
                        { 0.727, 0.392 },
                        { 0.697, 0.424 },
                        { 0.693, 0.513 },
                        { 0.671, 0.572 },
                        { 0.616, 0.574 },
                        { 0.380, 0.579 },
                    },
                },
            },
        },
        -- 5. Prince Tortheldrin (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Prince Tortheldrin",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 238 },
                    kind    = "path",
                    note    = "After killing ^Immol'thar^, go northeast and go through a door. Jump over the ledge and you will find ^Prince Tortheldrin^ on the bottom level.",
                    minNote = "Northeast to Tortheldrin",
                    points  = {
                        { 0.377, 0.539 },
                        { 0.460, 0.442 },
                        { 0.568, 0.372 },
                        { 0.604, 0.275 },
                    },
                },
            },
        },
    },
}
