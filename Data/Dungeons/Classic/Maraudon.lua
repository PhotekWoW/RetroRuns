-------------------------------------------------------------------------------
-- RetroRuns Data -- Maraudon
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.2  |  instanceID: 349  |  journalInstanceID: 232
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[232] = {
    kind              = "dungeon",
    instanceID        = 349,
    journalInstanceID = 232,
    name              = "Maraudon",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.2",

    entrance = {
        mapID = 67,
        x     = 0.7830,
        y     = 0.5630,
    },

    pois = {
        { mapID = 280, poiKind = "rare", rareNpc = "Meshlok the Harvester", mapLabelPos = "above", points = { { 0.204, 0.694 }, { 0.232, 0.744 }, { 0.246, 0.866 }, { 0.248, 0.796 }, { 0.264, 0.694 }, { 0.266, 0.576 }, { 0.306, 0.858 }, { 0.364, 0.650 } } },
    },

    trashLoot = {
        { id = 17742, slot = "Chest", name = "Fungus Shroud Armor", sources = { [14]=7195 }, bind = "BoP", rareNpc = "Meshlok the Harvester" },
        { id = 17741, slot = "Chest", name = "Nature's Embrace", sources = { [14]=7194 }, bind = "BoP", rareNpc = "Meshlok the Harvester" },
        { id = 17767, slot = "Head", name = "Bloomsprout Headpiece", sources = { [14]=7208 }, bind = "BoP", rareNpc = "Meshlok the Harvester" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Noxxion",
            journalEncounterID = 423,
            dungeonEncounterID = 422,
            achievements       = {
            },
            loot = {
                { id = 151450, slot = "Chest", name = "Chainmail of the Noxious Hollow", sources = { [14]=89447 } },
                { id = 17745, slot = "Ranged", name = "Noxious Shooter", sources = { [14]=7197 } },
                { id = 151449, slot = "Waist", name = "Fungal-Spore Cinch", sources = { [14]=89446 } },
                { id = 17746, slot = "Wrist", name = "Noxxion's Shackles", sources = { [14]=7198 } },
            },
        },
        {
            index              = 2,
            name               = "Razorlash",
            journalEncounterID = 424,
            dungeonEncounterID = 423,
            achievements       = {
            },
            loot = {
                { id = 17748, slot = "Feet", name = "Vinerot Sandals", sources = { [14]=7199 } },
                { id = 151451, slot = "Hands", name = "Strip-Thorn Gauntlets", sources = { [14]=89448 } },
                { id = 17751, slot = "Legs", name = "Brusslehide Leggings", sources = { [14]=7202 } },
                { id = 132563, slot = "Legs", name = "Chloro-Stained Britches", sources = { [14]=76396 } },
                { id = 132562, slot = "Shoulder", name = "Leaf-Scale Pauldrons", sources = { [14]=76395 } },
                { id = 17749, slot = "Shoulder", name = "Phytoskin Spaulders", sources = { [14]=7200 } },
                { id = 17750, slot = "Waist", name = "Chloromesh Girdle", sources = { [14]=7201 } },
            },
        },
        {
            index              = 3,
            name               = "Tinkerer Gizlock",
            journalEncounterID = 425,
            dungeonEncounterID = 427,
            achievements       = {
            },
            loot = {
                { id = 17718, slot = "Off-hand", name = "Gizlock's Hypertech Buckler", sources = { [14]=7181 } },
                { id = 17717, slot = "Ranged", name = "Megashot Rifle", sources = { [14]=7180 } },
                { id = 17719, slot = "Weapon", name = "Inventor's Focal Sword", sources = { [14]=7182 } },
            },
        },
        {
            index              = 4,
            name               = "Lord Vyletongue",
            journalEncounterID = 427,
            dungeonEncounterID = 424,
            achievements       = {
            },
            loot = {
                { id = 151448, slot = "Chest", name = "Lord Vyletongue's Satyrplate", sources = { [14]=89445 } },
                { id = 17754, slot = "Legs", name = "Infernal Trickster Leggings", sources = { [14]=7205 } },
                { id = 17755, slot = "Waist", name = "Satyrmane Sash", sources = { [14]=7206 } },
                { id = 17752, slot = "Weapon", name = "Satyr's Lash", sources = { [14]=7203 } },
                { id = 151447, slot = "Wrist", name = "Zaetar-kin Wristwraps", sources = { [14]=89444 } },
            },
        },
        {
            index              = 5,
            name               = "Celebras the Cursed",
            journalEncounterID = 428,
            dungeonEncounterID = 425,
            achievements       = {
            },
            loot = {
                { id = 17739, slot = "Back", name = "Grovekeeper's Drape", sources = { [14]=7192 } },
                { id = 132561, slot = "Head", name = "Corrupted Keeper's Band", sources = { [14]=76394 } },
                { id = 17740, slot = "Head", name = "Soothsayer's Headdress", sources = { [14]=7193 } },
                { id = 17738, slot = "Weapon", name = "Claw of Celebras", sources = { [14]=7191 } },
            },
        },
        {
            index              = 6,
            name               = "Landslide",
            journalEncounterID = 429,
            dungeonEncounterID = 426,
            achievements       = {
            },
            loot = {
                { id = 17736, slot = "Hands", name = "Rockgrip Gauntlets", sources = { [14]=7189 } },
                { id = 17734, slot = "Head", name = "Helm of the Mountain", sources = { [14]=7188 } },
                { id = 17737, slot = "Off-hand", name = "Cloud Stone", sources = { [14]=7190 } },
                { id = 17943, slot = "Weapon", name = "Fist of Stone", sources = { [14]=7218 } },
            },
        },
        {
            index              = 7,
            name               = "Rotgrip",
            journalEncounterID = 430,
            dungeonEncounterID = 428,
            achievements       = {
            },
            loot = {
                { id = 17728, slot = "Feet", name = "Albino Crocscale Boots", sources = { [14]=7185 } },
                { id = 132564, slot = "Feet", name = "Albino Crocscale Waders", sources = { [14]=76397 } },
                { id = 17732, slot = "Shoulder", name = "Rotgrip Mantle", sources = { [14]=7187 } },
                { id = 17730, slot = "Two-Hand", name = "Gatorbite Axe", sources = { [14]=7186 } },
                { id = 151452, slot = "Waist", name = "Crocolisk Wrestler's Waistguard", sources = { [14]=89449 } },
            },
        },
        {
            index              = 8,
            name               = "Princess Theradras",
            journalEncounterID = 431,
            dungeonEncounterID = 429,
            achievements       = {
            },
            loot = {
                { id = 17715, slot = "Head", name = "Eye of Theradras", sources = { [14]=7179 } },
                { id = 17711, slot = "Legs", name = "Elemental Rockridge Leggings", sources = { [14]=7177 } },
                { id = 17766, slot = "Two-Hand", name = "Princess Theradras' Scepter", sources = { [14]=7207 } },
                { id = 17780, slot = "Weapon", name = "Blade of Eternal Darkness", sources = { [14]=7215 } },
                { id = 17710, slot = "Weapon", name = "Charstone Dirk", sources = { [14]=7176 } },
                { id = 17714, slot = "Wrist", name = "Bracers of the Stone Princess", sources = { [14]=7178 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {

        -- 1. Noxxion (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Noxxion",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 280 },
                    kind    = "path",
                    note    = "After zoning in, follow the path west before looping your way north to reach ^Noxxion^.",
                    minNote = "Follow path to Noxxion",
                    points  = {
                        { 0.614, 0.248 },
                        { 0.601, 0.210 },
                        { 0.557, 0.227 },
                        { 0.541, 0.234 },
                        { 0.542, 0.278 },
                        { 0.511, 0.299 },
                        { 0.490, 0.308 },
                        { 0.444, 0.361 },
                        { 0.426, 0.398 },
                        { 0.404, 0.428 },
                        { 0.417, 0.454 },
                        { 0.430, 0.482 },
                        { 0.454, 0.470 },
                        { 0.487, 0.443 },
                        { 0.515, 0.414 },
                        { 0.542, 0.385 },
                        { 0.542, 0.338 },
                        { 0.512, 0.331 },
                        { 0.464, 0.280 },
                        { 0.463, 0.249 },
                        { 0.482, 0.209 },
                        { 0.458, 0.184 },
                        { 0.411, 0.160 },
                        { 0.385, 0.112 },
                    },
                },
            },
        },

        -- 2. Razorlash (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Razorlash",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 280 },
                    kind    = "path",
                    note    = "After killing ^Noxxion^, follow the path west until you reach ^Razorlash^.",
                    minNote = "West to Razorlash",
                    points  = {
                        { 0.390, 0.139 },
                        { 0.390, 0.256 },
                        { 0.368, 0.263 },
                        { 0.362, 0.302 },
                        { 0.336, 0.344 },
                        { 0.331, 0.401 },
                        { 0.306, 0.404 },
                        { 0.278, 0.375 },
                        { 0.257, 0.358 },
                        { 0.219, 0.375 },
                        { 0.207, 0.342 },
                        { 0.189, 0.345 },
                    },
                },
            },
        },

        -- 3. Tinkerer Gizlock (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Tinkerer Gizlock",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 280 },
                    kind    = "path",
                    note    = "After defeating ^Razorlash^, follow the path through ^Poison Falls^ and work your way up to ^Tinkerer Gizlock^.",
                    minNote = "Long path east to Gizlock",
                    points  = {
                        { 0.192, 0.337 },
                        { 0.214, 0.354 },
                        { 0.220, 0.382 },
                        { 0.210, 0.421 },
                        { 0.217, 0.468 },
                        { 0.268, 0.430 },
                        { 0.306, 0.462 },
                        { 0.338, 0.439 },
                        { 0.400, 0.519 },
                        { 0.416, 0.595 },
                        { 0.363, 0.671 },
                        { 0.342, 0.671 },
                        { 0.324, 0.649 },
                        { 0.300, 0.646 },
                        { 0.285, 0.679 },
                        { 0.247, 0.751 },
                        { 0.259, 0.800 },
                        { 0.259, 0.849 },
                        { 0.264, 0.877 },
                        { 0.286, 0.895 },
                        { 0.309, 0.902 },
                        { 0.330, 0.873 },
                        { 0.423, 0.873 },
                        { 0.495, 0.842 },
                        { 0.485, 0.796 },
                        { 0.500, 0.698 },
                        { 0.487, 0.674 },
                        { 0.511, 0.570 },
                    },
                },
            },
        },

        -- 4. Lord Vyletongue (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Lord Vyletongue",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 280 },
                    kind    = "path",
                    note    = "After killing ^Tinkerer Gizlock^, backtrack south to ^Poison Falls^ and climb your way up some stairs to reach ^Lord Vyletongue^ standing inside of a building.",
                    minNote = "South then upstairs to Vyletongue",
                    points  = {
                        { 0.511, 0.593 },
                        { 0.492, 0.635 },
                        { 0.487, 0.675 },
                        { 0.498, 0.702 },
                        { 0.489, 0.737 },
                        { 0.491, 0.839 },
                        { 0.468, 0.862 },
                        { 0.433, 0.880 },
                        { 0.358, 0.880 },
                        { 0.359, 0.800 },
                        { 0.419, 0.798 },
                        { 0.419, 0.764 },
                        { 0.378, 0.764 },
                        { 0.378, 0.741 },
                    },
                },
            },
        },

        -- 5. Celebras the Cursed (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Celebras the Cursed",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 280 },
                    kind    = "path",
                    note    = "After defeating ^Lord Vyletongue^, go southwest to find a path towards the poison in ^The Wicked Grotto^. Work your way north and jump over a poison waterfall before you go west to the other side of the dungeon.",
                    minNote = "West through poison",
                    points  = {
                        { 0.378, 0.759 },
                        { 0.330, 0.777 },
                        { 0.311, 0.818 },
                        { 0.324, 0.874 },
                        { 0.310, 0.906 },
                        { 0.281, 0.889 },
                        { 0.261, 0.873 },
                        { 0.264, 0.815 },
                        { 0.249, 0.746 },
                        { 0.189, 0.601 },
                        { 0.122, 0.584 },
                    },
                },
                {
                    when    = { mapID = 281 },
                    kind    = "path",
                    note    = "Proceed straight ahead to find ^Celebras the Cursed^.",
                    minNote = "Ahead to Celebras",
                    points  = {
                        { 0.265, 0.068 },
                        { 0.247, 0.110 },
                    },
                },
            },
        },

        -- 6. Landslide (boss 6)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Landslide",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 281 },
                    kind    = "path",
                    note    = "After defeating ^Celebras the Cursed^, follow the path south and make your way up the cliffside to find ^Landslide^.",
                    minNote = "South to Landslide",
                    points  = {
                        { 0.249, 0.184 },
                        { 0.280, 0.251 },
                        { 0.281, 0.402 },
                        { 0.302, 0.477 },
                        { 0.304, 0.593 },
                        { 0.343, 0.618 },
                        { 0.364, 0.595 },
                        { 0.405, 0.602 },
                        { 0.440, 0.603 },
                        { 0.460, 0.594 },
                        { 0.459, 0.561 },
                        { 0.449, 0.549 },
                        { 0.435, 0.567 },
                        { 0.416, 0.578 },
                        { 0.410, 0.583 },
                        { 0.410, 0.622 },
                        { 0.402, 0.637 },
                        { 0.377, 0.627 },
                        { 0.364, 0.616 },
                        { 0.364, 0.566 },
                        { 0.385, 0.539 },
                        { 0.417, 0.548 },
                        { 0.427, 0.520 },
                    },
                },
            },
        },

        -- 7. Princess Theradras (boss 8)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 8,
            title     = "Princess Theradras",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 281 },
                    kind    = "path",
                    note    = "After killing ^Landslide^, make your way down the cliffside and take the path west until you reach ^Princess Theradras^.",
                    minNote = "Down cliffside then west to Princess",
                    points  = {
                        { 0.426, 0.524 },
                        { 0.411, 0.555 },
                        { 0.411, 0.593 },
                        { 0.400, 0.645 },
                        { 0.429, 0.683 },
                        { 0.454, 0.668 },
                        { 0.466, 0.680 },
                        { 0.453, 0.744 },
                        { 0.420, 0.760 },
                        { 0.380, 0.790 },
                        { 0.344, 0.795 },
                        { 0.282, 0.787 },
                    },
                },
            },
        },

        -- 8. Rotgrip (boss 7)
        {
            step      = 8,
            priority  = 1,
            bossIndex = 7,
            title     = "Rotgrip",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 281 },
                    kind    = "path",
                    note    = "After defeating ^Princess Theradras^, backtrack east and you can find ^Rotgrip^ in the water below.",
                    minNote = "Backtrack east, Rotgrip in water",
                    points  = {
                        { 0.285, 0.783 },
                        { 0.316, 0.784 },
                        { 0.364, 0.803 },
                        { 0.383, 0.825 },
                    },
                },
            },
        },

    },
}
