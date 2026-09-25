-------------------------------------------------------------------------------
-- RetroRuns Data -- Lower Blackrock Spire
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 229  |  journalInstanceID: 229
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[229] = {
    kind              = "dungeon",
    instanceID        = 229,
    journalInstanceID = 229,
    name              = "Lower Blackrock Spire",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 33,
        x     = 0.8040,
        y     = 0.4090,
    },

    pois = {
        { mapID = 251, poiKind = "rare", rareNpc = "Bannok Grimaxe", mapLabelPos = "legend-bottomleft", navPoint = { 0.479, 0.642 }, points = { { 0.476, 0.562 }, { 0.479, 0.642 }, { 0.508, 0.512 }, { 0.576, 0.732 } } },
        { mapID = 251, poiKind = "rare", rareNpc = "Burning Felguard", mapLabelPos = "legend-bottomleft", points = { { 0.374, 0.550 }, { 0.444, 0.576 }, { 0.522, 0.554 }, { 0.566, 0.386 }, { 0.574, 0.576 }, { 0.642, 0.416 }, { 0.650, 0.574 }, { 0.664, 0.484 } } },
        { mapID = 251, poiKind = "rare", rareNpc = "Crystal Fang", mapLabelPos = "legend-bottomleft", points = { { 0.514, 0.742 }, { 0.576, 0.734 } } },
        { mapID = 254, poiKind = "rare", rareNpc = "Ghok Bashguud", mapLabelPos = "legend-bottomleft", points = { { 0.344, 0.710 }, { 0.348, 0.604 }, { 0.396, 0.738 }, { 0.424, 0.794 } } },
        { mapID = 252, poiKind = "rare", rareNpc = "Spirestone Battle Lord", mapLabelPos = "legend-bottomleft", navPoint = { 0.352, 0.558 }, points = { { 0.352, 0.558 }, { 0.432, 0.578 } } },
        { mapID = 252, poiKind = "rare", rareNpc = "Spirestone Butcher", mapLabelPos = "legend-bottomleft", points = { { 0.512, 0.567 } } },
        { mapID = 252, poiKind = "rare", rareNpc = "Spirestone Lord Magus", mapLabelPos = "legend-bottomleft", navPoint = { 0.414, 0.586 }, points = { { 0.356, 0.578 }, { 0.414, 0.586 } } },
        { mapID = 250, subZone = "Hordemar City", poiKind = "quest", mapLabel = "Roughshod Pike",
          mapLabelPos = "legend-bottomleft",
          hintWhere = "Location: First level. Across the hall from ^Highlord Omokk^",
          hintNote = "Required to summon optional boss ^Urok Doomhowl^ later", hintBoss = 5,
          points = { { 0.682, 0.577 } } },
    },

    trashLoot = {
        { id = 13203, slot = "Back", name = "Armswake Cloak", sources = { [14]=4792 }, bind = "BoP", rareNpc = "Ghok Bashguud" },
        { id = 12608, slot = "Back", name = "Butcher's Apron", sources = { [14]=4480 }, bind = "BoP", rareNpc = "Spirestone Butcher" },
        { id = 13282, slot = "Feet", name = "Ogreseer Tower Boots", sources = { [14]=4821 }, bind = "BoP", rareNpc = "Spirestone Lord Magus" },
        { id = 13284, slot = "Feet", name = "Swiftdart Battleboots", sources = { [14]=4822 }, bind = "BoP", rareNpc = "Spirestone Battle Lord" },
        { id = 13260, slot = "Feet", name = "Wind Dancer Boots", sources = { [14]=4818 }, bind = "BoE" },
        { id = 12637, slot = "Hands", name = "Backusarian Gauntlets", sources = { [14]=4504 }, bind = "BoP", rareNpc = "Bannok Grimaxe" },
        { id = 13181, slot = "Hands", name = "Demonskin Gloves", sources = { [14]=4785 }, bind = "BoP", rareNpc = "Burning Felguard" },
        { id = 13184, slot = "Hands", name = "Fallbrush Handgrips", sources = { [14]=4788 }, bind = "BoP", rareNpc = "Crystal Fang" },
        { id = 13261, slot = "Off-hand", name = "Globe of D'sak", sources = { [14]=4819 }, bind = "BoP", rareNpc = "Spirestone Lord Magus" },
        { id = 13185, slot = "Shoulder", name = "Sunderseer Mantle", sources = { [14]=4789 }, bind = "BoP", rareNpc = "Crystal Fang" },
        { id = 13285, slot = "Two-Hand", name = "The Blackrock Slicer", sources = { [14]=4823 }, bind = "BoP", rareNpc = "Spirestone Battle Lord" },
        { id = 12634, slot = "Waist", name = "Chiselbrand Girdle", sources = { [14]=4502 }, bind = "BoP", rareNpc = "Bannok Grimaxe" },
        { id = 13204, slot = "Weapon", name = "Bashguuder", sources = { [14]=4793 }, bind = "BoP", rareNpc = "Ghok Bashguud" },
        { id = 12621, slot = "Weapon", name = "Demonfork", sources = { [14]=4493 }, bind = "BoP", rareNpc = "Bannok Grimaxe" },
        { id = 13218, slot = "Weapon", name = "Fang of the Crystal Spider", sources = { [14]=4800 }, bind = "BoP", rareNpc = "Crystal Fang" },
        { id = 13198, slot = "Weapon", name = "Hurd Smasher", sources = { [14]=4790 }, bind = "BoP", rareNpc = "Ghok Bashguud" },
        { id = 13182, slot = "Weapon", name = "Phase Blade", sources = { [14]=4786 }, bind = "BoP", rareNpc = "Burning Felguard" },
        { id = 13286, slot = "Weapon", name = "Rivenspike", sources = { [14]=4824 }, bind = "BoP", rareNpc = "Spirestone Butcher" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Highlord Omokk",
            journalEncounterID = 388,
            dungeonEncounterID = 267,
            achievements       = {
            },
            loot = {
                { id = 13168, slot = "Chest", name = "Plate of the Shaman King", sources = { [14]=4780 } },
                { id = 151412, slot = "Head", name = "Ogre Highlord's Casque", sources = { [14]=89417 } },
                { id = 13170, slot = "Legs", name = "Skyshroud Leggings", sources = { [14]=4782 } },
                { id = 13169, slot = "Legs", name = "Tressermane Leggings", sources = { [14]=4781 } },
                { id = 13166, slot = "Shoulder", name = "Slamshot Shoulders", sources = { [14]=4778 } },
                { id = 13167, slot = "Two-Hand", name = "Fist of Omokk", sources = { [14]=4779 } },
            },
        },
        {
            index              = 2,
            name               = "Shadow Hunter Vosh'gajin",
            journalEncounterID = 389,
            dungeonEncounterID = 268,
            achievements       = {
            },
            loot = {
                { id = 13255, slot = "Hands", name = "Trueaim Gauntlets", sources = { [14]=4814 } },
                { id = 12651, slot = "Ranged", name = "Blackcrow", sources = { [14]=4508 } },
                { id = 12653, slot = "Ranged", name = "Riphook", sources = { [14]=4509 } },
                { id = 13257, slot = "Shoulder", name = "Demonic Runed Spaulders", sources = { [14]=4815 } },
                { id = 151413, slot = "Waist", name = "Smolderthorn Greatbelt", sources = { [14]=89418 } },
                { id = 12626, slot = "Wrist", name = "Funeral Cuffs", sources = { [14]=4496 } },
            },
        },
        {
            index              = 3,
            name               = "War Master Voone",
            journalEncounterID = 390,
            dungeonEncounterID = 269,
            achievements       = {
            },
            loot = {
                { id = 22231, slot = "Feet", name = "Kayser's Boots of Precision", sources = { [14]=8748 } },
                { id = 13175, slot = "Ranged", name = "Voone's Twitchbow", sources = { [14]=4783 } },
                { id = 12582, slot = "Weapon", name = "Keris of Zul'Serak", sources = { [14]=4465 } },
                { id = 13179, slot = "Wrist", name = "Brazecore Armguards", sources = { [14]=4784 } },
            },
        },
        {
            index              = 4,
            name               = "Mother Smolderweb",
            journalEncounterID = 391,
            dungeonEncounterID = 270,
            achievements       = {
            },
            loot = {
                { id = 13244, slot = "Hands", name = "Gilded Gauntlets", sources = { [14]=4806 } },
                { id = 13183, slot = "Weapon", name = "Venomspitter", sources = { [14]=4787 } },
                { id = 151414, slot = "Back", name = "Arachnophile's Greatcloak", sources = { [14]=89419 } },
            },
            specialLoot = {
                { id = 68673, kind = "pet", name = "Smolderweb Egg" },
            },
        },
        {
            index              = 5,
            name               = "Urok Doomhowl",
            journalEncounterID = 392,
            dungeonEncounterID = 271,
            achievements       = {
            },
            loot = {
                { id = 13259, slot = "Feet", name = "Ribsteel Footguards", sources = { [14]=4817 } },
                { id = 13258, slot = "Hands", name = "Slaghide Gauntlets", sources = { [14]=4816 } },
                { id = 22232, slot = "Waist", name = "Marksman's Girdle", sources = { [14]=8749 } },
            },
        },
        {
            index              = 6,
            name               = "Quartermaster Zigris",
            journalEncounterID = 393,
            dungeonEncounterID = 272,
            achievements       = {
            },
            loot = {
                { id = 151415, slot = "Feet", name = "Veteran Spearman's Chain Boots", sources = { [14]=89420 } },
                { id = 13253, slot = "Hands", name = "Hands of Power", sources = { [14]=4812 } },
                { id = 151416, slot = "Legs", name = "Dark Horde Grunt's Legplates", sources = { [14]=89421 } },
                { id = 13252, slot = "Waist", name = "Cloudrunner Girdle", sources = { [14]=4811 } },
            },
            specialLoot = {
                { id = 12264, kind = "pet", name = "Worg Carrier" },
            },
        },
        {
            index              = 7,
            name               = "Halycon",
            journalEncounterID = 394,
            dungeonEncounterID = 274,
            achievements       = {
            },
            loot = {
                { id = 13210, slot = "Feet", name = "Pads of the Dread Wolf", sources = { [14]=4797 } },
                { id = 22313, slot = "Wrist", name = "Ironweave Bracers", sources = { [14]=8782 } },
                { id = 13211, slot = "Wrist", name = "Slashclaw Bracers", sources = { [14]=4798 } },
            },
        },
        {
            index              = 8,
            name               = "Gizrul the Slavener",
            journalEncounterID = 395,
            dungeonEncounterID = 273,
            achievements       = {
            },
            loot = {
                { id = 151418, slot = "Head", name = "Raider Aspirant's Helm", sources = { [14]=89423 } },
                { id = 13206, slot = "Legs", name = "Wolfshear Leggings", sources = { [14]=4795 } },
                { id = 13205, slot = "Off-hand", name = "Rhombeard Protector", sources = { [14]=4794 } },
                { id = 151417, slot = "Shoulder", name = "Worg-Keeper's Spaulders", sources = { [14]=89422 } },
                { id = 13208, slot = "Wrist", name = "Bleak Howler Armguards", sources = { [14]=4796 } },
            },
        },
        {
            index              = 9,
            name               = "Overlord Wyrmthalak",
            journalEncounterID = 396,
            dungeonEncounterID = 275,
            achievements       = {
            },
            loot = {
                { id = 13162, slot = "Hands", name = "Reiver Claws", sources = { [14]=4775 } },
                { id = 13148, slot = "Two-Hand", name = "Chillpike", sources = { [14]=4771 } },
                { id = 13163, slot = "Two-Hand", name = "Relentless Scythe", sources = { [14]=4776 } },
                { id = 13161, slot = "Two-Hand", name = "Trindlehaven Staff", sources = { [14]=4774 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {

        -- 1. Highlord Omokk (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Highlord Omokk",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 253 },
                    kind    = "path",
                    note    = "After zoning in, take your first left at the bottom of the ramp. ^Roughshod Pike^ is marked on the map if you plan to summon ^Urok Doomhowl^ later. Follow the linear path until you reach a room called ^Mok'Doom^. You will find ^Highlord Omokk^ in the far corner surrounded by ogres.",
                    minNote = "Follow path to Omokk",
                    points  = {
                        { 0.382, 0.425 },
                        { 0.383, 0.483 },
                        { 0.405, 0.482 },
                        { 0.405, 0.452 },
                        { 0.428, 0.452 },
                        { 0.443, 0.438 },
                        { 0.473, 0.439 },
                        { 0.517, 0.390 },
                        { 0.527, 0.381 },
                        { 0.549, 0.381 },
                        { 0.573, 0.396 },
                        { 0.586, 0.423 },
                        { 0.603, 0.429 },
                        { 0.641, 0.429 },
                        { 0.664, 0.439 },
                        { 0.661, 0.507 },
                    },
                },
                -- Same path on the sibling floor: the entrance straddles the
                -- 252/253 boundary and either map can be the one on screen.
                -- Noteless on purpose, so the note above serves both.
                {
                    when    = { mapID = 252 },
                    kind    = "path",
                    points  = {
                        { 0.378, 0.448 },
                        { 0.377, 0.483 },
                        { 0.424, 0.481 },
                        { 0.542, 0.387 },
                        { 0.578, 0.394 },
                        { 0.591, 0.428 },
                        { 0.663, 0.427 },
                        { 0.662, 0.506 },
                        { 0.659, 0.577 },
                        { 0.417, 0.579 },
                    },
                },
                {
                    when    = { mapID = 250 },
                    kind    = "path",
                    points  = {
                        { 0.585, 0.426 },
                        { 0.657, 0.428 },
                        { 0.655, 0.591 },
                        { 0.500, 0.593 },
                    },
                },
            },
        },

        -- 2. Shadow Hunter Vosh'gajin (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Shadow Hunter Vosh'gajin",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 252 },
                    kind    = "path",
                    note    = "After defeating ^Highlord Omokk^, backtrack out of his room and take a left. Take another left and follow the ramp down into a room filled with trolls. Go up the stairs at the south side of the room to locate ^Shadow Hunter Vosh'gajin^.",
                    minNote = "Follow path to Vosh'gajin",
                    points  = {
                        { 0.476, 0.576 },
                        { 0.574, 0.576 },
                        { 0.574, 0.507 },
                        { 0.527, 0.508 },
                    },
                },
                {
                    when    = { mapID = 250 },
                    kind    = "path",
                    points  = {
                        { 0.553, 0.577 },
                        { 0.594, 0.577 },
                        { 0.593, 0.522 },
                        { 0.569, 0.522 },
                    },
                },
                {
                    when    = { mapID = 251 },
                    kind    = "path",
                    points  = {
                        { 0.584, 0.504 },
                        { 0.533, 0.508 },
                        { 0.532, 0.537 },
                        { 0.552, 0.614 },
                        { 0.553, 0.657 },
                    },
                },
            },
        },

        -- 3. War Master Voone (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "War Master Voone",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 251 },
                    kind    = "path",
                    note    = "After killing ^Vosh'gajin^, exit his room and take a right to continue down several ramps.",
                    minNote = "Right down several ramps",
                    points  = {
                        { 0.552, 0.658 },
                        { 0.554, 0.579 },
                        { 0.594, 0.579 },
                        { 0.595, 0.642 },
                    },
                },
                {
                    when    = { mapID = 250 },
                    kind    = "path",
                    note    = "When you reach the floor, take the western hallway ahead and you will find ^War Master Voone^ at the end.",
                    minNote = "Western hallway to Voone",
                    points  = {
                        { 0.581, 0.642 },
                        { 0.556, 0.639 },
                        { 0.551, 0.618 },
                        { 0.531, 0.616 },
                        { 0.527, 0.578 },
                    },
                },
            },
        },

        -- 4. Mother Smolderweb (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Mother Smolderweb",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 250 },
                    kind    = "path",
                    note    = "After defeating ^War Master Voone^, backtrack to the large room and take the northeast exit. Follow this path around until you reach ^Mother Smolderweb^.",
                    minNote = "Northeast path to Smolderweb",
                    points  = {
                        { 0.527, 0.615 },
                        { 0.552, 0.617 },
                        { 0.663, 0.522 },
                        { 0.663, 0.483 },
                        { 0.639, 0.483 },
                        { 0.619, 0.465 },
                        { 0.594, 0.483 },
                        { 0.518, 0.481 },
                        { 0.516, 0.510 },
                        { 0.487, 0.520 },
                        { 0.484, 0.640 },
                        { 0.537, 0.699 },
                        { 0.648, 0.701 },
                        { 0.648, 0.737 },
                        { 0.616, 0.740 },
                    },
                },
            },
        },

        -- 5. Urok Doomhowl (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Urok Doomhowl",
            -- Summoned, so bypassable: the step cedes to the next one once
            -- the player walks past. The following step carries the bypass
            -- prose, per the optional-step rule.
            optional  = true,
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 251 },
                    kind    = "path",
                    note    = "After defeating ^Mother Smolderweb^, go up the purple ramp to the west.",
                    minNote = "Up purple ramp to west",
                    points  = {
                        { 0.596, 0.732 },
                        { 0.528, 0.748 },
                        { 0.486, 0.735 },
                    },
                },
                {
                    when    = { mapID = 252 },
                    kind    = "path",
                    note    = "Continue up the ramp and clear the ogres. Use ^Omokk's Head^ while standing over ^Urok's Tribute Pile^ to summon ^Urok Doomhowl^. You can {skip} this boss if you want.",
                    minNote = "Summon Urok at Tribute Pile",
                    points  = {
                        { 0.477, 0.730 },
                        { 0.473, 0.676 },
                        { 0.470, 0.602 },
                    },
                },
            },
        },

        -- 6. Quartermaster Zigris (boss 6)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Quartermaster Zigris",
            requires  = { },
            segments  = {
                -- The purple-ramp leg is SHARED: both paths walk it, so a
                -- player who skipped Urok needs the same instruction step 5
                -- gives one who did not. Carrying it here also lets the skip
                -- be taken from the ramp itself -- CanSkipBoss refuses while
                -- no LATER step matches the player's position, and before
                -- this segment existed nothing did until map 252.
                {
                    when         = { mapID = 251 },
                    kind         = "path",
                    skipWhenBoss = 5,
                    skipNote     = "After defeating ^Mother Smolderweb^, go up the purple ramp to the west.",
                    skipMinNote  = "Up purple ramp to west",
                    skipPoints   = {
                        { 0.596, 0.732 },
                        { 0.528, 0.748 },
                        { 0.486, 0.735 },
                    },
                },
                -- Bypass only. The kill path leaves Urok on 253, not here,
                -- so its guidance lives on that segment instead.
                {
                    when         = { mapID = 252 },
                    kind         = "path",
                    skipWhenBoss = 5,
                    skipNote     = "Continue up the ramp and keep to the left, bypassing ^Urok's Tribute Pile^. Follow the ramp as it turns sharply back to the south.",
                    skipMinNote  = "Bypass Tribute Pile and go South",
                    skipPoints   = {
                        { 0.476, 0.731 },
                        { 0.461, 0.597 },
                        { 0.429, 0.591 },
                        { 0.429, 0.733 },
                    },
                },
                -- Shared final approach: both paths arrive here.
                {
                    when    = { mapID = 253 },
                    kind    = "path",
                    note    = "Continue south until the path ends, and take a left to follow the path east until you reach ^Quartermaster Zigris^ walking around.",
                    minNote = "At end of path, left to Zigris",
                    points  = {
                        { 0.430, 0.553 },
                        { 0.427, 0.800 },
                        { 0.525, 0.801 },
                    },
                },
                -- Same approach on the sibling floor: either map can be the
                -- one on screen. Noteless, so the note above serves both.
                {
                    when    = { mapID = 254 },
                    kind    = "path",
                    points  = {
                        { 0.428, 0.744 },
                        { 0.429, 0.797 },
                        { 0.527, 0.798 },
                        { 0.528, 0.812 },
                    },
                },
            },
        },

        -- 7. Halycon (boss 7)
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Halycon",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 254 },
                    kind    = "path",
                    note    = "After killing ^Quartermaster Zigris^, exit his room and go to the far other end of the hallway. Go left to find ^Halycon^.",
                    minNote = "Down hallway, left to Halycon",
                    points  = {
                        { 0.526, 0.811 },
                        { 0.525, 0.795 },
                        { 0.418, 0.796 },
                        { 0.372, 0.805 },
                        { 0.380, 0.840 },
                    },
                },
            },
        },

        -- 8. Gizrul the Slavener (boss 8)
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Gizrul the Slavener",
            requires  = { },
            segments  = {
                -- No points: he comes to the player at Halycon's corpse, so
                -- there is nothing to walk and a line would invent a route.
                {
                    when    = { mapID = 254 },
                    kind    = "path",
                    note    = "After ^Halycon^ dies, ^Gizrul the Slavener^ will emerge from the nearby hallway. Kill him.",
                    minNote = "Kill Gizrul when he appears",
                },
            },
        },

        -- 9. Overlord Wyrmthalak (boss 9)
        {
            step      = 9,
            priority  = 1,
            bossIndex = 9,
            title     = "Overlord Wyrmthalak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 254 },
                    kind    = "path",
                    note    = "After killing ^Gizrul the Slavener^, take the first ramp up on the left. Be careful crossing this room so you don't fall into the map below. When you reach the other side, take a right to exit the room.",
                    minNote = "Ramp up and cross room",
                    points  = {
                        { 0.395, 0.793 },
                        { 0.400, 0.751 },
                        { 0.399, 0.729 },
                        { 0.351, 0.720 },
                        { 0.352, 0.686 },
                        { 0.373, 0.657 },
                        { 0.373, 0.597 },
                        { 0.403, 0.598 },
                    },
                },
                {
                    when    = { mapID = 255 },
                    kind    = "path",
                    note    = "Follow the path east to reach the final boss, ^Overlord Wyrmthalak^.",
                    minNote = "East path to Wyrmthalak",
                    points  = {
                        { 0.438, 0.602 },
                        { 0.552, 0.603 },
                    },
                },
            },
        },
    },
}
