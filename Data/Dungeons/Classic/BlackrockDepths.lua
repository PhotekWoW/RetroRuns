-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackrock Depths
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 230  |  journalInstanceID: 228
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[228] = {
    kind              = "dungeon",
    instanceID        = 230,
    journalInstanceID = 228,
    name              = "Blackrock Depths",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",

    entrance = {
        mapID = 35,
        x     = 0.3890,
        y     = 0.1840,
    },


    trashLoot = {
        { id = 12552, slot = "Back", name = "Blisterbane Wrap", sources = { [14]=4459 }, bind = "BoE" },
        { id = 12542, slot = "Chest", name = "Funeral Pyre Vestment", sources = { [14]=4453 }, bind = "BoE" },
        { id = 12555, slot = "Feet", name = "Battlechaser's Greaves", sources = { [14]=4462 }, bind = "BoE" },
        { id = 11787, slot = "Feet", name = "Shalehusk Boots", sources = { [14]=4251 }, bind = "BoP", rareNpc = "Panzor the Invincible" },
        { id = 22245, slot = "Feet", name = "Soot Encrusted Footwear", sources = { [14]=8754 }, bind = "BoP", rareNpc = "Panzor the Invincible" },
        { id = 22256, slot = "Hands", name = "Mana Shaping Handwraps", sources = { [14]=8758 }, bind = "BoP", tag = "Secret Safe" },
        { id = 12547, slot = "Hands", name = "Mar Alom's Grip", sources = { [14]=4455 }, bind = "BoE" },
        { id = 11785, slot = "Off-hand", name = "Rock Golem Bulwark", sources = { [14]=4249 }, bind = "BoP", rareNpc = "Panzor the Invincible" },
        { id = 22254, slot = "Ranged", name = "Wand of Eternal Light", sources = { [14]=8757 }, bind = "BoP", tag = "Secret Safe" },
        { id = 12532, slot = "Two-Hand", name = "Spire of the Stoneshaper", sources = { [14]=4451 }, bind = "BoE" },
        { id = 11786, slot = "Two-Hand", name = "Stone of the Earth", sources = { [14]=4250 }, bind = "BoP", rareNpc = "Panzor the Invincible" },
        { id = 12528, slot = "Two-Hand", name = "The Judge's Gavel", sources = { [14]=4449 }, bind = "BoE" },
        { id = 12535, slot = "Weapon", name = "Doomforged Straightedge", sources = { [14]=4452 }, bind = "BoE" },
        { id = 12527, slot = "Weapon", name = "Ribsplitter", sources = { [14]=4448 }, bind = "BoE" },
        { id = 12531, slot = "Weapon", name = "Searing Needle", sources = { [14]=4450 }, bind = "BoE" },
        { id = 12546, slot = "Wrist", name = "Aristocratic Cuffs", sources = { [14]=4454 }, bind = "BoE" },
        { id = 22205, slot = "Wrist", name = "Black Steel Bindings", sources = { [14]=8736 }, bind = "BoP", tag = "Secret Safe" },
        { id = 12550, slot = "Wrist", name = "Runed Golem Shackles", sources = { [14]=4457 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "High Interrogator Gerstahn",
            journalEncounterID = 369,
            dungeonEncounterID = 227,
            achievements       = {
            },
            loot = {
                { id = 11626, slot = "Back", name = "Blackveil Cape", sources = { [14]=4203 } },
                { id = 22240, slot = "Feet", name = "Greaves of Withering Despair", sources = { [14]=8751 } },
                { id = 11625, slot = "Off-hand", name = "Enthralled Sphere", sources = { [14]=4202 } },
                { id = 11624, slot = "Shoulder", name = "Kentic Amice", sources = { [14]=4201 } },
            },
        },
        {
            index              = 2,
            name               = "Lord Roccor",
            journalEncounterID = 370,
            dungeonEncounterID = 228,
            achievements       = {
            },
            loot = {
                { id = 22271, slot = "Legs", name = "Leggings of Frenzied Magic", sources = { [14]=8763 } },
                { id = 11631, slot = "Off-hand", name = "Stoneshell Guard", sources = { [14]=4208 } },
                { id = 11632, slot = "Shoulder", name = "Earthslag Shoulders", sources = { [14]=4209 } },
                { id = 22234, slot = "Shoulder", name = "Mantle of Lost Hope", sources = { [14]=8750 } },
                { id = 11679, slot = "Wrist", name = "Rubicund Armguards", sources = { [14]=4218 } },
            },
        },
        {
            index              = 3,
            name               = "Houndmaster Grebmar",
            journalEncounterID = 371,
            dungeonEncounterID = 229,
            achievements       = {
            },
            loot = {
                { id = 11623, slot = "Back", name = "Spritecaster Cape", sources = { [14]=4200 } },
                { id = 11627, slot = "Feet", name = "Fleetfoot Greaves", sources = { [14]=4204 } },
                { id = 11628, slot = "Ranged", name = "Houndmaster's Bow", sources = { [14]=4205 } },
                { id = 11629, slot = "Ranged", name = "Houndmaster's Rifle", sources = { [14]=4206 } },
            },
        },
        {
            index              = 4,
            name               = "Ring of Law",
            journalEncounterID = 372,
            dungeonEncounterID = 230,
            achievements       = {
            },
            loot = {
                { id = 11677, slot = "Back", name = "Graverot Cape", sources = { [14]=4216 } },
                { id = 11678, slot = "Chest", name = "Carapace of Anub'shiah", sources = { [14]=4217 } },
                { id = 11726, slot = "Chest", name = "Savage Gladiator Chain", sources = { [14]=4225 } },
                { id = 11633, slot = "Chest", name = "Spiderfang Carapace", sources = { [14]=4210 } },
                { id = 11731, slot = "Feet", name = "Savage Gladiator Greaves", sources = { [14]=4229 } },
                { id = 11675, slot = "Feet", name = "Shadefiend Boots", sources = { [14]=4215 } },
                { id = 11665, slot = "Hands", name = "Ogreseer Fists", sources = { [14]=4214 } },
                { id = 11730, slot = "Hands", name = "Savage Gladiator Grips", sources = { [14]=4228 } },
                { id = 11634, slot = "Hands", name = "Silkweb Gloves", sources = { [14]=4211 } },
                { id = 11729, slot = "Head", name = "Savage Gladiator Helm", sources = { [14]=4227 } },
                { id = 11728, slot = "Legs", name = "Savage Gladiator Leggings", sources = { [14]=4226 } },
                { id = 11722, slot = "Shoulder", name = "Dregmetal Spaulders", sources = { [14]=4224 } },
                { id = 11685, slot = "Shoulder", name = "Splinthide Shoulders", sources = { [14]=4220 } },
                { id = 11662, slot = "Waist", name = "Ban'thok Sash", sources = { [14]=4213 } },
                { id = 11686, slot = "Waist", name = "Girdle of Beastial Fury", sources = { [14]=4221 } },
                { id = 11703, slot = "Waist", name = "Stonewall Girdle", sources = { [14]=4223 } },
                { id = 22266, slot = "Weapon", name = "Flarethorn", sources = { [14]=8759 } },
                { id = 11702, slot = "Weapon", name = "Grizzle's Skinner", sources = { [14]=4222 } },
                { id = 11635, slot = "Weapon", name = "Hookfang Shanker", sources = { [14]=4212 } },
            },
        },
        {
            index              = 5,
            name               = "Pyromancer Loregrain",
            journalEncounterID = 373,
            dungeonEncounterID = 231,
            achievements       = {
            },
            loot = {
                { id = 11747, slot = "Chest", name = "Flamestrider Robes", sources = { [14]=4235 } },
                { id = 22270, slot = "Feet", name = "Entrenching Boots", sources = { [14]=8762 } },
                { id = 11749, slot = "Legs", name = "Searingscale Leggings", sources = { [14]=4237 } },
                { id = 11748, slot = "Ranged", name = "Pyric Caduceus", sources = { [14]=4236 } },
                { id = 11750, slot = "Two-Hand", name = "Kindling Stave", sources = { [14]=4238 } },
            },
        },
        {
            index              = 6,
            name               = "Lord Incendius",
            journalEncounterID = 374,
            dungeonEncounterID = 232,
            achievements       = {
            },
            loot = {
                { id = 11764, slot = "Wrist", name = "Cinderhide Armsplints", sources = { [14]=4241 } },
                { id = 11767, slot = "Wrist", name = "Emberplate Armguards", sources = { [14]=4244 } },
                { id = 11766, slot = "Wrist", name = "Flameweave Cuffs", sources = { [14]=4243 } },
                { id = 11765, slot = "Wrist", name = "Pyremail Wristguards", sources = { [14]=4242 } },
            },
        },
        {
            index              = 7,
            name               = "Warder Stilgiss",
            journalEncounterID = 375,
            dungeonEncounterID = 233,
            achievements       = {
            },
            loot = {
                { id = 151405, slot = "Chest", name = "Cold-Forged Chestplate", sources = { [14]=89411 } },
                { id = 11782, slot = "Shoulder", name = "Boreal Mantle", sources = { [14]=4246 } },
                { id = 22241, slot = "Shoulder", name = "Dark Warder's Pauldrons", sources = { [14]=8752 } },
                { id = 11783, slot = "Waist", name = "Chillsteel Girdle", sources = { [14]=4247 } },
                { id = 22242, slot = "Waist", name = "Verek's Leash", sources = { [14]=8753 } },
                { id = 11784, slot = "Weapon", name = "Arbiter's Blade", sources = { [14]=4248 } },
            },
        },
        {
            index              = 8,
            name               = "Fineous Darkvire",
            journalEncounterID = 376,
            dungeonEncounterID = 234,
            achievements       = {
            },
            loot = {
                { id = 11839, slot = "Head", name = "Chief Architect's Monocle", sources = { [14]=4267 } },
                { id = 22223, slot = "Head", name = "Foreman's Head Protector", sources = { [14]=8745 } },
                { id = 11841, slot = "Legs", name = "Senior Designer's Pantaloons", sources = { [14]=4269 } },
                { id = 11842, slot = "Shoulder", name = "Lead Surveyor's Mantle", sources = { [14]=4270 } },
                { id = 151406, slot = "Waist", name = "Belt of the Eminent Mason", sources = { [14]=89412 } },
            },
        },
        {
            index              = 9,
            name               = "Bael'Gar",
            journalEncounterID = 377,
            dungeonEncounterID = 235,
            achievements       = {
            },
            loot = {
                { id = 11802, slot = "Legs", name = "Lavacrest Leggings", sources = { [14]=4252 } },
                { id = 11803, slot = "Two-Hand", name = "Force of Magma", sources = { [14]=4253 } },
                { id = 11807, slot = "Waist", name = "Sash of the Burning Heart", sources = { [14]=4255 } },
                { id = 11805, slot = "Weapon", name = "Rubidium Hammer", sources = { [14]=4254 } },
            },
        },
        {
            index              = 10,
            name               = "General Angerforge",
            journalEncounterID = 378,
            dungeonEncounterID = 236,
            achievements       = {
            },
            loot = {
                { id = 11820, slot = "Chest", name = "Royal Decorated Armor", sources = { [14]=4262 } },
                { id = 11821, slot = "Legs", name = "Warstrife Leggings", sources = { [14]=4263 } },
                { id = 12557, slot = "Shoulder", name = "Ebonsteel Spaulders", sources = { [14]=4464 } },
                { id = 11816, slot = "Two-Hand", name = "Angerforge's Battle Axe", sources = { [14]=4260 } },
                { id = 11932, slot = "Two-Hand", name = "Guiding Stave of Wisdom", sources = { [14]=4328 } },
                { id = 11817, slot = "Weapon", name = "Lord General's Sword", sources = { [14]=4261 } },
            },
        },
        {
            index              = 11,
            name               = "Golem Lord Argelmach",
            journalEncounterID = 379,
            dungeonEncounterID = 237,
            achievements       = {
            },
            loot = {
                { id = 11822, slot = "Feet", name = "Omnicast Boots", sources = { [14]=4264 } },
                { id = 11823, slot = "Legs", name = "Luminary Kilt", sources = { [14]=4265 } },
            },
        },
        {
            index              = 12,
            name               = "Hurley Blackbreath",
            journalEncounterID = 380,
            dungeonEncounterID = 238,
            achievements       = {
            },
            loot = {
                { id = 18043, slot = "Feet", name = "Coal Miner Boots", sources = { [14]=7221 } },
                { id = 11735, slot = "Head", name = "Ragefury Eyepatch", sources = { [14]=4230 } },
                { id = 151407, slot = "Legs", name = "Blackened Pit Trousers", sources = { [14]=89413 } },
                { id = 151408, slot = "Shoulder", name = "Dark Iron Dredger's Pauldrons", sources = { [14]=89414 } },
                { id = 11922, slot = "Weapon", name = "Blood-Etched Blade", sources = { [14]=4318 } },
                { id = 18044, slot = "Weapon", name = "Hurley's Tankard", sources = { [14]=7222 } },
            },
        },
        {
            index              = 13,
            name               = "Phalanx",
            journalEncounterID = 381,
            dungeonEncounterID = 239,
            achievements       = {
            },
            loot = {
                { id = 11745, slot = "Hands", name = "Fists of Phalanx", sources = { [14]=4233 } },
                { id = 22212, slot = "Shoulder", name = "Golem Fitted Pauldrons", sources = { [14]=8742 } },
                { id = 151409, slot = "Waist", name = "Ferrous Cord", sources = { [14]=89415 } },
                { id = 11744, slot = "Weapon", name = "Bloodfist", sources = { [14]=4232 } },
                { id = 22204, slot = "Wrist", name = "Wristguards of Renown", sources = { [14]=8735 } },
            },
        },
        {
            index              = 14,
            name               = "Ribbly Screwspigot",
            -- The Encounter Journal has no entry for him, so the lockout id
            -- comes from here rather than the journal map. He is a bonus
            -- objective: the scenario reports his defeat in its own step.
            dungeonEncounterID = 240,
            achievements       = {
            },
            loot = {
            },
        },
        {
            index              = 15,
            name               = "Plugger Spazzring",
            journalEncounterID = 383,
            dungeonEncounterID = 241,
            achievements       = {
            },
            loot = {
                { id = 12793, slot = "Chest", name = "Mixologist's Tunic", sources = { [14]=4546 } },
                { id = 12791, slot = "Weapon", name = "Barman Shanker", sources = { [14]=4544 } },
            },
        },
        {
            index              = 16,
            name               = "Ambassador Flamelash",
            journalEncounterID = 384,
            dungeonEncounterID = 242,
            achievements       = {
            },
            loot = {
                { id = 11812, slot = "Back", name = "Cape of the Fire Salamander", sources = { [14]=4258 } },
                { id = 11814, slot = "Hands", name = "Molten Fists", sources = { [14]=4259 } },
                { id = 11808, slot = "Head", name = "Circle of Flame", sources = { [14]=4256 } },
                { id = 11809, slot = "Two-Hand", name = "Flame Wrath", sources = { [14]=4257 } },
            },
        },
        {
            index              = 17,
            name               = "The Seven",
            journalEncounterID = 385,
            dungeonEncounterID = 243,
            -- Criterion prose reads "Complete the Trial of Seven" and so
            -- carries no boss name to match on.
            scenarioCriteriaID = 25078,
            achievements       = {
            },
            loot = {
                { id = 11926, slot = "Chest", name = "Deathdealer Breastplate", sources = { [14]=4322 } },
                { id = 11925, slot = "Head", name = "Ghostshroud", sources = { [14]=4321 } },
                { id = 11929, slot = "Legs", name = "Haunting Specter Leggings", sources = { [14]=4325 } },
                { id = 11927, slot = "Legs", name = "Legplates of the Eternal Guardian", sources = { [14]=4323 } },
                { id = 11921, slot = "Two-Hand", name = "Impervious Giant", sources = { [14]=4317 } },
                { id = 11923, slot = "Weapon", name = "The Hammer of Grace", sources = { [14]=4319 } },
                { id = 11920, slot = "Weapon", name = "Wraith Scythe", sources = { [14]=4316 } },
            },
        },
        {
            index              = 18,
            name               = "Magmus",
            journalEncounterID = 386,
            dungeonEncounterID = 244,
            achievements       = {
            },
            loot = {
                { id = 22275, slot = "Feet", name = "Firemoss Boots", sources = { [14]=8767 } },
                { id = 11746, slot = "Head", name = "Golem Skull Helm", sources = { [14]=4234 } },
                { id = 151411, slot = "Legs", name = "Molten-Warder Leggings", sources = { [14]=89416 } },
                { id = 11935, slot = "Off-hand", name = "Magmus Stone", sources = { [14]=4329 } },
                { id = 22208, slot = "Two-Hand", name = "Lavastone Hammer", sources = { [14]=8739 } },
            },
        },
        {
            index              = 19,
            name               = "Emperor Dagran Thaurissan",
            journalEncounterID = 387,
            dungeonEncounterID = 245,
            achievements       = {
            },
            loot = {
                { id = 11930, slot = "Back", name = "The Emperor's New Cape", sources = { [14]=4326 } },
                { id = 11924, slot = "Chest", name = "Robes of the Royal Crown", sources = { [14]=4320 } },
                { id = 12556, slot = "Feet", name = "High Priestess Boots", sources = { [14]=4463 } },
                { id = 12553, slot = "Feet", name = "Swiftwalker Boots", sources = { [14]=4460 } },
                { id = 12554, slot = "Hands", name = "Hands of the Exalted Herald", sources = { [14]=4461 } },
                { id = 11928, slot = "Off-hand", name = "Thaurissan's Royal Scepter", sources = { [14]=4324 } },
                { id = 11931, slot = "Two-Hand", name = "Dreadforge Retaliator", sources = { [14]=4327 } },
                { id = 22207, slot = "Waist", name = "Sash of the Grand Hunt", sources = { [14]=8738 } },
                { id = 11684, slot = "Weapon", name = "Ironfoe", sources = { [14]=4219 } },
            },
            specialLoot = {
                { id = 246429, kind = "decor", name = "Dark Iron Chandelier", decorID = 2246 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    pois = {
        -- Rare spawn points; the vault chests are
        -- their gameobject positions.  Hand-authored from here: the
        -- generator will not rewrite a routed file.
        { mapID = 243, poiKind = "rare", rareNpc = "Panzor the Invincible",
          mapLabelPos = "legend-bottomleft",
          points = { { 0.470, 0.372 }, { 0.480, 0.320 }, { 0.498, 0.424 } } },
        { mapID = 243, poiKind = "chest", tag = "Secret Safe",
          mapLabelPos = "legend-bottomleft",
          hintNote = "Open all twelve Relic Coffers to wake the vault and spawn ^Watchman Doomgrip^. Defeating him opens the hidden door to the Safe.",
          points = { { 0.615, 0.692 } } },
        { mapID = 242, poiKind = "vendor", mapLabel = "Vendor NPC",
          mapLabelPos = "below", points = { { 0.379, 0.798 } } },
        { mapID = 243, poiKind = "vendor", mapLabel = "Recipe Vendor",
          mapLabelPos = "legend-bottomleft",
          hintNote = "^Lokhtos Darkbargainer^ sells Thorium Brotherhood crafting patterns. Reputation gated.",
          points = { { 0.501, 0.574 } } },
    },

    -- Route order is the WALK, not the journal: steps 1-4 are journal
    -- bosses 1, 3, 2, 4. bossIndex is the journal index in every case;
    -- step is the order the player travels.
    routing = {

        -- 1. High Interrogator Gerstahn (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "High Interrogator Gerstahn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242 },
                    kind    = "path",
                    note    = "After zoning in, follow the path to the center of the detention block to find ^High Interrogator Gerstahn^.",
                    minNote = "Right to Gerstahn in Detention Block",
                    points  = {
                        { 0.348, 0.776 },
                        { 0.408, 0.754 },
                        { 0.434, 0.785 },
                        { 0.423, 0.840 },
                        { 0.415, 0.891 },
                        { 0.423, 0.929 },
                        { 0.442, 0.955 },
                        { 0.462, 0.970 },
                        { 0.482, 0.975 },
                        { 0.467, 0.887 },
                    },
                },
            },
        },

        -- 2. Houndmaster Grebmar (boss 3)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 3,
            title     = "Houndmaster Grebmar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242 },
                    kind    = "path",
                    note    = "After killing ^High Interrogator^, go up the stairs behind her and follow the path to ^Houndmaster Grebmar^. He patrols inside a room on the northeast side of the circle.",
                    minNote = "North to Houndmaster",
                    points  = {
                        { 0.466, 0.884 },
                        { 0.449, 0.788 },
                        { 0.454, 0.665 },
                        { 0.462, 0.618 },
                        { 0.480, 0.576 },
                        { 0.501, 0.563 },
                        { 0.512, 0.563 },
                        { 0.557, 0.596 },
                        { 0.525, 0.609 },
                    },
                },
            },
        },

        -- 3. Lord Roccor (boss 2)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 2,
            title     = "Lord Roccor",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242 },
                    kind    = "path",
                    note    = "After defeating ^Houndmaster Grebmar^, continue down the clockwise path until you find ^Lord Roccor^ patrolling this area.",
                    minNote = "Clockwise to Lord Roccor",
                    points  = {
                        { 0.559, 0.599 },
                        { 0.568, 0.637 },
                    },
                },
            },
        },

        -- 4. Ring of Law (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Ring of Law",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242 },
                    kind    = "path",
                    note    = "After killing ^Lord Roccor^, continue clockwise to the entrance for ^Ring of Law^ on your right. Walk to the middle of the room to start the encounter.",
                    minNote = "Follow path to Ring of Law",
                    points  = {
                        { 0.545, 0.705 },
                        { 0.514, 0.714 },
                        { 0.512, 0.685 },
                    },
                },
            },
        },

        -- 5. Pyromancer Loregrain (boss 5). Two floors: the walk
        -- on 242, then a noteless marker-less leg on 243 so the step
        -- still tracks after the floor change. ComputeCurrentSeg
        -- walks down to the last NOTED seg, so the second leg shows
        -- the first one's note.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Pyromancer Loregrain",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242 },
                    kind    = "path",
                    note    = "After defeating ^Ring of Law^, take the west exit to the East Garrison. Take a sharp right up some stairs, and travel around the upper balcony to arrive in the ^Shrine of Thaurissan^. Take a right and head south to reach ^Pyromancer Loregrain^.",
                    minNote = "West exit then up to Loregrain",
                    points  = {
                        { 0.470, 0.638 },
                        { 0.437, 0.624 },
                        { 0.438, 0.603 },
                        { 0.475, 0.610 },
                        { 0.480, 0.594 },
                        { 0.497, 0.586 },
                        { 0.513, 0.590 },
                        { 0.541, 0.608 },
                        { 0.554, 0.628 },
                        { 0.573, 0.627 },
                    },
                },
                {
                    when     = { mapID = 243 },
                    kind     = "poi",
                    noMarker = true,
                    points   = { { 0.569, 0.914 } },
                },
            },
        },


        -- 6. Warder Stilgiss (boss 7). The lava bridge and Domicile legs
        -- lead here now: Warder sits off the FIRST exit from Shadowforge
        -- City, and Fineous is the second. Shadowforge City straddles BOTH
        -- floor maps, so every segment is sub-zone gated.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 7,
            title     = "Warder Stilgiss",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243, subZone = "Shrine of Thaurissan" },
                    kind    = "path",
                    note    = "After defeating ^Pyromancer Loregrain^, go north to cross a bridge over lava.",
                    minNote = "Cross lava bridge",
                    points  = {
                        { 0.569, 0.899 },
                        { 0.561, 0.734 },
                        { 0.528, 0.698 },
                        { 0.553, 0.642 },
                    },
                },
                {
                    -- Carries the note from the far side of the bridge
                    -- onward. Draws nothing -- seg 1's path already runs
                    -- through here -- so it is pinned to seg 1's last
                    -- point rather than geometry of its own. The gate's
                    -- trailing space is in the live subZone string.
                    when     = { mapID = 243, subZone = "The Domicile " },
                    kind     = "poi",
                    noMarker = true,
                    note     = "After the bridge, you will be in ^The Domicile^. Take a left and go to the end of the path. Go downstairs into ^Shadowforge City^, and take the first exit on the right to find ^Warder Stilgiss^ and ^Verek^.",
                    minNote  = "First exit on right",
                    points   = { { 0.553, 0.642 } },
                },
                {
                    -- Noteless: Shadowforge City straddles both floor
                    -- maps, so whichever the client reports, the note
                    -- resolves back to The Domicile's and never flickers.
                    when    = { mapID = 242, subZone = "Shadowforge City" },
                    kind    = "path",
                    points  = {
                        { 0.574, 0.349 },
                        { 0.603, 0.369 },
                    },
                },
            },
        },

        -- 7. Fineous Darkvire (boss 8). Starts inside Warder's room, so
        -- the safe note rides the leg the player is already walking.
        {
            step      = 7,
            priority  = 1,
            bossIndex = 8,
            title     = "Fineous Darkvire",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243, subZone = "The Black Vault" },
                    kind    = "path",
                    note    = "After defeating ^Warder Stilgiss^, you can unlock the ^Secret Safe^ in the room behind him if you have the time and materials. Otherwise, exit the boss room and take the next right.",
                    minNote = "Exit and take second right",
                    points  = {
                        { 0.580, 0.634 },
                        { 0.589, 0.601 },
                        { 0.632, 0.596 },
                        { 0.661, 0.560 },
                        { 0.633, 0.520 },
                    },
                },
                {
                    -- Noteless: the transient leg across Shadowforge City on
                    -- the other floor map, reading segment 1's note.
                    when    = { mapID = 242, subZone = "Shadowforge City" },
                    kind    = "path",
                    points  = {
                        { 0.592, 0.333 },
                        { 0.600, 0.304 },
                        { 0.643, 0.306 },
                        { 0.672, 0.265 },
                        { 0.657, 0.241 },
                    },
                },
                {
                    when    = { mapID = 243, subZone = "Hall of Crafting" },
                    kind    = "path",
                    note    = "Inside the ^Hall of Crafting^, you will find ^Fineous Darkvire^ patrolling the ramps.",
                    minNote = "Find Fineous patrolling ramps",
                    points  = {
                        { 0.603, 0.600 },
                        { 0.629, 0.597 },
                        { 0.659, 0.559 },
                        { 0.643, 0.535 },
                    },
                },
            },
        },

        -- 8. Lord Incendius (boss 6)
        {
            step      = 8,
            priority  = 1,
            bossIndex = 6,
            title     = "Lord Incendius",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242 },
                    kind    = "path",
                    note    = "After killing ^Fineous Darkvire^, exit at the bottom of the room and proceed straight ahead to encounter ^Lord Incendius^.",
                    minNote = "Exit southwest to Lord Incendius",
                    points  = {
                        { 0.611, 0.241 },
                        { 0.586, 0.279 },
                    },
                },
            },
        },

        -- 9. Bael'Gar (boss 9)
        {
            step      = 9,
            priority  = 1,
            bossIndex = 9,
            title     = "Bael'Gar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242 },
                    kind    = "path",
                    note    = "After defeating ^Lord Incendius^, continue on a long southwest path until you reach ^Bael'Gar^.",
                    minNote = "Southwest to Bael'Gar",
                    points  = {
                        { 0.540, 0.350 },
                        { 0.445, 0.495 },
                        { 0.374, 0.597 },
                        { 0.316, 0.595 },
                        { 0.276, 0.554 },
                    },
                },
            },
        },

        -- 10. General Angerforge (boss 10). Both segments sit on
        -- map 242, so each needs its sub-zone gate to stay apart.
        {
            step      = 10,
            priority  = 1,
            bossIndex = 10,
            title     = "General Angerforge",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242, subZone = "Dark Iron Highway" },
                    kind    = "path",
                    note    = "After defeating ^Bael'Gar^, go southeast through the ^Shadowforge Gate^. Just ahead, open the ^East Garrison Door^. Nearby, activate ^The Shadowforge Lock^ to close the door outside and open up the next path.",
                    minNote = "Go activate The Shadowforge Lock",
                    points  = {
                        { 0.276, 0.547 },
                        { 0.304, 0.581 },
                        { 0.350, 0.605 },
                        { 0.357, 0.658 },
                        { 0.394, 0.669 },
                        { 0.415, 0.645 },
                        { 0.441, 0.608 },
                    },
                },
                {
                    -- Noteless: takes its travel text from the path
                    -- segment above, the Uldaman altar-POI shape.
                    -- The label ticks off when the seg below's criterion
                    -- fires, which is the lock click itself. Safe from the
                    -- seed-past trap: that gated seg caps the seeder here,
                    -- so the check cannot land before the click.
                    when        = { mapID = 242, subZone = "East Garrison" },
                    kind        = "poi",
                    mapLabel    = "Click Lock",
                    mapLabelPos = "above",
                    completionCheck = true,
                    points      = { { 0.406, 0.601 } },
                },
                {
                    -- Gated on the scenario criterion "Unlock the
                    -- Shadowforge" (state, not an event -- survives a
                    -- reload). Carries the post-unlock note and is placed
                    -- where the player STANDS at that moment, so the note
                    -- flips on the click; draws nothing of its own.
                    when        = { mapID = 242, subZone = "East Garrison" },
                    kind        = "poi",
                    noMarker    = true,
                    triggeredBy = { scenario = 25080 },
                    note        = "After clicking ^The Shadowforge Lock^, go up the stairs and take the northeast path to ^East Garrison^. Continue along the linear path until you reach ^General Angerforge^.",
                    minNote     = "Follow paths to Angerforge",
                    points      = { { 0.406, 0.601 } },
                },
                {
                    -- Noteless continuation: the walk to Angerforge on the
                    -- other floor map, reading the carrier's note.
                    when    = { mapID = 243, subZone = "East Garrison" },
                    kind    = "path",
                    points  = {
                        { 0.460, 0.867 },
                        { 0.475, 0.817 },
                        { 0.423, 0.734 },
                        { 0.387, 0.758 },
                        { 0.386, 0.774 },
                        { 0.376, 0.791 },
                    },
                },
                {
                    -- Noteless: still the Angerforge approach, so the
                    -- sticky fallback keeps showing the carrier's note.
                    when    = { mapID = 242, subZone = "Shadowforge City" },
                    kind    = "path",
                    points  = {
                        { 0.460, 0.515 },
                        { 0.421, 0.456 },
                    },
                },
                {
                    -- Noteless: last leg of the same approach.
                    when    = { mapID = 242, subZone = "West Garrison" },
                    kind    = "path",
                    points  = {
                        { 0.382, 0.478 },
                        { 0.360, 0.557 },
                    },
                },
            },
        },

        -- 11. Golem Lord Argelmach (boss 11). Both gates kept: West
        -- Garrison straddles 242/243, so a bare mapID on either
        -- segment would let the other's ground match.
        {
            step      = 11,
            priority  = 1,
            bossIndex = 11,
            title     = "Golem Lord Argelmach",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 242, subZone = "West Garrison" },
                    kind    = "path",
                    note    = "After killing ^General Angerforge^, head north until you reach ^Golem Lord Argelmach^.",
                    minNote = "North to Golem Lord",
                    points  = {
                        { 0.355, 0.545 },
                        { 0.352, 0.440 },
                    },
                },
                {
                    -- Noteless: reads the segment above.
                    when    = { mapID = 243, subZone = "The Manufactory" },
                    kind    = "path",
                    points  = {
                        { 0.366, 0.751 },
                        { 0.365, 0.687 },
                    },
                },
            },
        },

        -- 12. Ribbly Screwspigot (boss 14). The walk leaves The Manufactory
        -- and crosses into The Grim Guzzler, so the gate is the floor map
        -- alone -- a sub-zone gate would drop the line at the doorway.
        {
            step      = 12,
            priority  = 1,
            bossIndex = 14,
            title     = "Ribbly Screwspigot",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After defeating ^Golem Lord Argelmach^, head east across a bridge into ^The Grim Guzzler^. Before killing ^Ribbly^, go to the second floor and give 6x ^Dark Iron Ale Mug^ to ^Private Rocknot^. You can purchase them from ^Plugger Spazzring^ nearby.",
                    minNote = "East to Guzzler, 3x Rocknot Turn-ins",
                    points  = {
                        { 0.365, 0.693 },
                        { 0.406, 0.684 },
                        { 0.445, 0.663 },
                        { 0.500, 0.616 },
                    },
                },
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After activating ^Private Rocknot^, go back down and talk to ^Ribbly Screwspigot^ to start the encounter.",
                    minNote = "Talk to Ribbly",
                    triggeredBy = { dialog = { npc = "Private Rocknot", match = "I want more ale" } },
                    points  = { },
                },
            },
        },

        -- 13. Hurley Blackbreath (boss 12)
        {
            step      = 13,
            priority  = 1,
            bossIndex = 12,
            title     = "Hurley Blackbreath",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After killing ^Ribbly Screwspigot^, enter the room to your left and click on 3x ^Thunderbrew Lager Keg^ to spawn ^Hurley Blackbreath^.",
                    minNote = "Click 3 kegs for Hurley",
                    points  = {
                        { 0.481, 0.622 },
                        { 0.475, 0.604 },
                        { 0.482, 0.588 },
                    },
                },
            },
        },

        -- 14. Phalanx (boss 13)
        {
            step      = 14,
            priority  = 1,
            bossIndex = 13,
            title     = "Phalanx",
            optional  = true,
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After defeating ^Hurley Blackbreath^, you will find ^Phalanx^ guarding the door to the east. Talk to him to begin the encounter. If he failed to go hostile, you can {skip} him.",
                    minNote = "Kill Phalanx by east door",
                    points  = {
                        { 0.501, 0.610 },
                        { 0.515, 0.632 },
                        { 0.529, 0.623 },
                    },
                },
            },
        },

        -- 15. Plugger Spazzring (boss 15)
        {
            step      = 15,
            priority  = 1,
            bossIndex = 15,
            title     = "Plugger Spazzring",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After ^Phalanx^, return to ^Plugger Spazzring^ on the bar and kill him.",
                    minNote = "Kill Spazzring upstairs",
                    -- No waypoints: the bar is close quarters and a drawn
                    -- line reads as clutter there.
                    points  = { },
                },
            },
        },

        -- 16. Ambassador Flamelash (boss 16)
        {
            step      = 16,
            priority  = 1,
            bossIndex = 16,
            title     = "Ambassador Flamelash",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After defeating ^Plugger Spazzring^, go through the east exit (the one ^Phalanx^ was guarding) and take the next left. Go down the stairs and you'll emerge right in front of ^Ambassador Flamelash^.",
                    minNote = "East exit to Flamelash",
                    points  = {
                        { 0.532, 0.625 },
                        { 0.532, 0.594 },
                        { 0.539, 0.564 },
                        { 0.512, 0.522 },
                    },
                },
            },
        },

        -- 17. The Seven (boss 17)
        {
            step      = 17,
            priority  = 1,
            bossIndex = 17,
            title     = "The Seven",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After defeating ^Ambassador Flamelash^, continue northwest until you reach ^The Seven^. Talk to ^Doom'rel^ to start the encounter.",
                    minNote = "Northwest to The Seven",
                    points  = {
                        { 0.515, 0.446 },
                        { 0.488, 0.401 },
                        { 0.509, 0.373 },
                        { 0.494, 0.301 },
                        { 0.515, 0.268 },
                    },
                },
                {
                    -- Noteless: reads the path segment's note. The narrower
                    -- sub-zone gate is what releases the bare-mapID seg above.
                    when        = { mapID = 243, subZone = "Summoners' Tomb" },
                    kind        = "poi",
                    mapLabel    = "Talk to Doom'rel",
                    mapLabelPos = "above",
                    points      = {
                        { 0.572, 0.209 },
                    },
                },
            },
        },

        -- 18. Magmus (boss 18). Gated on the floor map alone: the sub-zone
        -- text flips between Summoners' Tomb and The Lyceum around the
        -- braziers, and a flip at the wrong instant would drop the advance.
        -- The two braziers are separate POIs so each ticks off on its own;
        -- the path segment carries the travel note.
        {
            step      = 18,
            priority  = 1,
            bossIndex = 18,
            title     = "Magmus",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After defeating ^The Seven^, exit to the northeast and enter ^The Lyceum^. Find 2x ^Shadowforge Flame Keeper^ and loot their ^Shadowforge Torch^. Use those torches to light 2x ^Shadowforge Brazier^ to advance.",
                    minNote = "Light 2x Braziers with 2x Torches",
                    points  = {
                        { 0.599, 0.200 },
                        { 0.613, 0.176 },
                        { 0.664, 0.120 },
                    },
                },
                {
                    when        = { mapID = 243 },
                    kind        = "poi",
                    mapLabel    = "Light Brazier (1)",
                    mapLabelPos = "above",
                    completionCheck = true,
                    points      = {
                        { 0.720, 0.066 },
                    },
                },
                {
                    -- Carries the trigger for both braziers: the yell fires
                    -- once, on the second one. It advances past this seg and
                    -- onto the seg below, which puts both checks behind
                    -- progress so both tick together as the note flips.
                    when        = { mapID = 243 },
                    kind        = "poi",
                    mapLabel    = "Light Brazier (2)",
                    mapLabelPos = "below",
                    completionCheck = true,
                    triggeredBy = { dialog = { npc = "Magmus", match = "does not wish to be disturbed" } },
                    points      = {
                        { 0.719, 0.169 },
                    },
                },
                {
                    when    = { mapID = 243 },
                    kind    = "path",
                    note    = "After the door opens, proceed straight ahead to ^Magmus^.",
                    minNote = "Ahead to Magmus",
                    points  = {
                        { 0.745, 0.124 },
                        { 0.774, 0.123 },
                    },
                },
            },
        },

        -- 19. Emperor Dagran Thaurissan (boss 19)
        {
            step      = 19,
            priority  = 1,
            bossIndex = 19,
            title     = "Emperor Dagran Thaurissan",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 243, subZone = "The Iron Hall" },
                    kind    = "path",
                    note    = "After killing ^Magmus^, continue straight ahead to the final boss, ^Emperor Dagran Thaurissan^.",
                    minNote = "Ahead to Emperor",
                    points  = {
                        { 0.819, 0.118 },
                        { 0.887, 0.119 },
                    },
                },
            },
        },
    },
}
