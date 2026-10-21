-------------------------------------------------------------------------------
-- RetroRuns Data -- Zul'Gurub
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.1.0  |  instanceID: 859  |  journalInstanceID: 76
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[76] = {
    kind              = "dungeon",
    instanceID        = 859,
    journalInstanceID = 76,
    name              = "Zul'Gurub",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.1.0",
    routedIn          = "3.3.5",

    -- One of the four Cache of Madness bosses a run, summoned with the
    -- artifacts. The corpse names the one that spawned.
    spawnChoice = { 3, 4, 5, 6, label = "Cache of Madness" },

    entrance = {
        mapID = 50,
        x     = 0.7225,
        y     = 0.3291,
    },

    pois = {
        { mapID = 337, poiKind = "vendor", mapLabel = "Recipe Vendor",
          mapLabelPos = "below",
          hintNote = "^Rin'wosho the Trader^ trades profession recipes and Zandalar transmog ensembles for Hakkari Bijous and Zandalar Bargaining Tokens.",
          points = { { 0.293, 0.500 } } },
    },

    trashLoot = {
        { id = 69796, slot = "Back", name = "Spiritcaller Cloak", sources = { [14]=35564, [15]=35564 }, bind = "BoE" },
        { id = 69800, slot = "Back", name = "Spiritguard Drape", sources = { [14]=35567, [15]=35567 }, bind = "BoE" },
        { id = 69803, slot = "Weapon", name = "Gurubashi Punisher", sources = { [14]=35569, [15]=35569 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "High Priest Venoxis",
            journalEncounterID = 175,
            dungeonEncounterID = 1178,
            achievements       = {
                { id = 5743, name = "It's Not Easy Being Green", soloable = "yes" },
            },
            loot = {
                { id = 69603, slot = "Chest", name = "Breastplate of Serenity", sources = { [14]=35514, [15]=35514 } },
                { id = 69601, slot = "Legs", name = "Serpentine Leggings", sources = { [14]=35513, [15]=35513 } },
                { id = 69600, slot = "Waist", name = "Belt of Slithering Serpents", sources = { [14]=35512, [15]=35512 } },
                { id = 69604, slot = "Waist", name = "Coils of Hate", sources = { [14]=35515, [15]=35515 } },
            },
        },
        {
            index              = 2,
            name               = "Bloodlord Mandokir",
            journalEncounterID = 176,
            dungeonEncounterID = 1179,
            achievements       = {
                { id = 5762, name = "Ohganot So Fast!", soloable = "yes" },
            },
            loot = {
                { id = 69606, slot = "Back", name = "Hakkari Loa Drape", sources = { [14]=35516, [15]=35516 } },
                { id = 69607, slot = "Ranged", name = "Touch of Discord", sources = { [14]=35517, [15]=35517 } },
                { id = 69609, slot = "Weapon", name = "Bloodlord's Protector", sources = { [14]=35519, [15]=35519 } },
                { id = 69608, slot = "Wrist", name = "Deathcharged Wristguards", sources = { [14]=35518, [15]=35518 } },
            },
            specialLoot = {
                { id = 68823, kind = "mount", name = "Armored Razzashi Raptor" },
            },
        },
        {
            index              = 3,
            name               = "Cache of Madness - Gri'lek",
            journalEncounterID = 177,
            dungeonEncounterID = 1188,
            npcID              = 52258,
            aliases            = { "Cache of Madness" },
            soloTip            = "Requires the Archaeology profession. Click the artifacts around the room until you have found one of each kind: troll, elven, dwarven and fossil. Each one you find floats to the middle, and the fourth summons one of four bosses at random.",
            achievements       = {
            },
            loot = {
                { id = 69634, slot = "Feet", name = "Fasc's Preserved Boots", sources = { [14]=35543, [15]=35543 } },
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
            },
        },
        {
            index              = 4,
            name               = "Cache of Madness - Hazza'rah",
            journalEncounterID = 178,
            dungeonEncounterID = 1188,
            npcID              = 52271,
            aliases            = { "Cache of Madness" },
            soloTip            = "Requires the Archaeology profession. Click the artifacts around the room until you have found one of each kind: troll, elven, dwarven and fossil. Each one you find floats to the middle, and the fourth summons one of four bosses at random.",
            achievements       = {
            },
            loot = {
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69637, slot = "Ranged", name = "Gurubashi Destroyer", sources = { [14]=35545, [15]=35545 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
                { id = 69636, slot = "Weapon", name = "Thekal's Claws", sources = { [14]=35544, [15]=35544 } },
            },
        },
        {
            index              = 5,
            name               = "Cache of Madness - Renataki",
            journalEncounterID = 179,
            dungeonEncounterID = 1188,
            npcID              = 52269,
            aliases            = { "Cache of Madness" },
            soloTip            = "Requires the Archaeology profession. Click the artifacts around the room until you have found one of each kind: troll, elven, dwarven and fossil. Each one you find floats to the middle, and the fourth summons one of four bosses at random.",
            achievements       = {
            },
            loot = {
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
                { id = 69638, slot = "Weapon", name = "Arlokk's Claws", sources = { [14]=35546, [15]=35546 } },
                { id = 69639, slot = "Weapon", name = "Renataki's Soul Slicer", sources = { [14]=35547, [15]=35547 } },
            },
        },
        {
            index              = 6,
            name               = "Cache of Madness - Wushoolay",
            journalEncounterID = 180,
            dungeonEncounterID = 1188,
            npcID              = 52286,
            aliases            = { "Cache of Madness" },
            soloTip            = "Requires the Archaeology profession. Click the artifacts around the room until you have found one of each kind: troll, elven, dwarven and fossil. Each one you find floats to the middle, and the fourth summons one of four bosses at random.",
            achievements       = {
            },
            loot = {
                { id = 69641, slot = "Chest", name = "Troll Skull Chestplate", sources = { [14]=35549, [15]=35549 } },
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69640, slot = "Legs", name = "Kilt of Forgotten Rites", sources = { [14]=35548, [15]=35548 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
            },
        },
        {
            index              = 7,
            name               = "High Priestess Kilnara",
            journalEncounterID = 181,
            dungeonEncounterID = 1180,
            achievements       = {
                { id = 5765, name = "Here, Kitty Kitty...", soloable = "yes" },
            },
            loot = {
                { id = 69614, slot = "Head", name = "Roaring Mask of Bethekk", sources = { [14]=35523, [15]=35523 } },
                { id = 69613, slot = "Legs", name = "Leggings of the Pride", sources = { [14]=35522, [15]=35522 } },
                { id = 69612, slot = "Shoulder", name = "Claw-Fringe Mantle", sources = { [14]=35521, [15]=35521 } },
                { id = 69611, slot = "Waist", name = "Sash of Anguish", sources = { [14]=35520, [15]=35520 } },
            },
            specialLoot = {
                { id = 68824, kind = "mount", name = "Swift Zulian Panther" },
            },
        },
        {
            index              = 8,
            name               = "Zanzil",
            journalEncounterID = 184,
            dungeonEncounterID = 1181,
            achievements       = {
            },
            loot = {
                { id = 69619, slot = "Hands", name = "Bone Plate Handguards", sources = { [14]=35528, [15]=35528 } },
                { id = 69617, slot = "Head", name = "Plumed Medicine Helm", sources = { [14]=35526, [15]=35526 } },
                { id = 69615, slot = "Legs", name = "Zombie Walker Legguards", sources = { [14]=35524, [15]=35524 } },
                { id = 69616, slot = "Shoulder", name = "Spiritbinder Spaulders", sources = { [14]=35525, [15]=35525 } },
                { id = 69618, slot = "Weapon", name = "Zulian Slasher", sources = { [14]=35527, [15]=35527 } },
            },
        },
        {
            index              = 9,
            name               = "Jin'do the Godbreaker",
            journalEncounterID = 185,
            dungeonEncounterID = 1182,
            soloTip            = "The goal is to destroy all 3 chains to activate the boss. You do this by pulling a ^Gurubashi Spirit Warrior^ to the chain and standing there until he casts ^Body Slam^ on you. Do this on all 3 chains, kill the chains, then kill the boss. If you manage to keep him alive, you can kill all 3 chains with the same troll.",
            achievements       = {
                { id = 5759, name = "Spirit Twister", soloable = "yes" },
                { id = 5744, name = "Gurubashi Headhunter", soloable = "yes" },
            },
            loot = {
                { id = 69623, slot = "Chest", name = "Vestments of the Soulflayer", sources = { [14]=35532, [15]=35532 } },
                { id = 69622, slot = "Head", name = "The Hexxer's Mask", sources = { [14]=35531, [15]=35531 } },
                { id = 69629, slot = "Off-hand", name = "Shield of the Blood God", sources = { [14]=35538, [15]=35538 } },
                { id = 69627, slot = "Off-hand", name = "Zulian Ward", sources = { [14]=35536, [15]=35536 } },
                { id = 69625, slot = "Ranged", name = "Mandokir's Tribute", sources = { [14]=35534, [15]=35534 } },
                { id = 69628, slot = "Two-Hand", name = "Jeklik's Smasher", sources = { [14]=35537, [15]=35537 } },
                { id = 69626, slot = "Two-Hand", name = "Jin'do's Verdict", sources = { [14]=35535, [15]=35535 } },
                { id = 69624, slot = "Two-Hand", name = "Legacy of Arlokk", sources = { [14]=35533, [15]=35533 } },
                { id = 69620, slot = "Weapon", name = "Twinblade of the Hakkari", sources = { [14]=35529, [15]=35529 } },
                { id = 69621, slot = "Weapon", name = "Twinblade of the Hakkari", sources = { [14]=35530, [15]=35530 } },
            },
            specialLoot = {
                { id = 122215, kind = "musicroll", name = "Music Roll: Zul'Gurub Voodoo", questID = 38080 },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. High Priest Venoxis (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "High Priest Venoxis",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 337 },
                    kind    = "path",
                    note    = "After zoning in, follow the path straight ahead across two bridges to reach ^High Priest Venoxis^.",
                    minNote = "Straight east to Venoxis",
                    points  = {
                        { 0.324, 0.488 },
                        { 0.347, 0.469 },
                        { 0.369, 0.464 },
                        { 0.383, 0.479 },
                        { 0.395, 0.493 },
                        { 0.449, 0.513 },
                        { 0.486, 0.535 },
                    },
                },
            },
        },

        -- 2. Bloodlord Mandokir (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Bloodlord Mandokir",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 337 },
                    kind    = "path",
                    note    = "After killing ^High Priest Venoxis^, take the southeast path to ^Bloodlord Mandokir^.",
                    minNote = "Southeast to Mandokir",
                    points  = {
                        { 0.487, 0.540 },
                        { 0.485, 0.567 },
                        { 0.495, 0.584 },
                        { 0.515, 0.592 },
                        { 0.538, 0.572 },
                        { 0.557, 0.604 },
                        { 0.567, 0.644 },
                        { 0.570, 0.756 },
                        { 0.587, 0.767 },
                    },
                },
            },
        },

        -- 3. The Cache of Madness (bosses 3-6), whichever spawns. Left
        -- out for a character without Archaeology.
        {
            step      = 3,
            priority  = 1,
            bossIndex = { 3, 4, 5, 6 },
            title     = "Cache of Madness",
            requires  = { },
            requiresArchaeology = true,
            segments  = {
                {
                    when    = { mapID = 337 },
                    kind    = "path",
                    note    = "After defeating ^Bloodlord Mandokir^, backtrack north and then go east up into ^The Cache of Madness^.",
                    minNote = "Backtrack north to Cache",
                    points  = {
                        { 0.582, 0.774 },
                        { 0.571, 0.754 },
                        { 0.570, 0.718 },
                        { 0.568, 0.646 },
                        { 0.560, 0.626 },
                        { 0.557, 0.600 },
                        { 0.540, 0.578 },
                        { 0.540, 0.522 },
                        { 0.571, 0.515 },
                        { 0.575, 0.472 },
                    },
                },
            },
        },

        -- 4. High Priestess Kilnara (boss 7), from the Cache of Madness.
        -- Opens only once the Cache is dead; a run that left it out
        -- takes step 5.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 7,
            title     = "High Priestess Kilnara",
            requires  = { 3 },
            segments  = {
                {
                    when    = { mapID = 337 },
                    kind    = "path",
                    note    = "After defeating ^The Cache of Madness^, take the northern path all the way to ^High Priestess Kilnara^. She is located on the bottom floor of the building.",
                    minNote = "North path to Kilnara",
                    points  = {
                        { 0.578, 0.496 },
                        { 0.576, 0.519 },
                        { 0.556, 0.518 },
                        { 0.566, 0.423 },
                        { 0.583, 0.363 },
                        { 0.583, 0.317 },
                        { 0.562, 0.289 },
                        { 0.475, 0.278 },
                        { 0.478, 0.248 },
                    },
                },
            },
        },

        -- 5. High Priestess Kilnara (boss 7), straight from Bloodlord
        -- Mandokir when the Cache is left out.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 7,
            title     = "High Priestess Kilnara",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 337 },
                    kind    = "path",
                    note    = "After killing ^Bloodlord Mandokir^, go all the way north to ^High Priestess Kilnara^. She is located on the bottom floor of the building.",
                    minNote = "North to Kilnara",
                    points  = {
                        { 0.577, 0.769 },
                        { 0.570, 0.736 },
                        { 0.568, 0.636 },
                        { 0.555, 0.595 },
                        { 0.540, 0.581 },
                        { 0.538, 0.522 },
                        { 0.563, 0.512 },
                        { 0.569, 0.426 },
                        { 0.585, 0.377 },
                        { 0.585, 0.318 },
                        { 0.563, 0.280 },
                        { 0.475, 0.280 },
                        { 0.475, 0.240 },
                    },
                },
            },
        },

        -- 6. Zanzil (boss 8).
        {
            step      = 6,
            priority  = 1,
            bossIndex = 8,
            title     = "Zanzil",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 337 },
                    kind    = "path",
                    note    = "After defeating ^High Priestess Kilnara^, exit the building and go west to find ^Zanzil^.",
                    minNote = "Exit building, west to Zanzil",
                    points  = {
                        { 0.475, 0.242 },
                        { 0.476, 0.282 },
                        { 0.449, 0.283 },
                        { 0.430, 0.302 },
                        { 0.406, 0.280 },
                        { 0.376, 0.279 },
                        { 0.333, 0.278 },
                    },
                },
            },
        },

        -- 7. Jin'do the Godbreaker (boss 9).
        {
            step      = 7,
            priority  = 1,
            bossIndex = 9,
            title     = "Jin'do the Godbreaker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 337 },
                    kind    = "path",
                    note    = "After killing ^Zanzil^, make your way to the central altar. |cffF259C7CAUTION!|r You must kill at least one ^Gurubashi Spirit Warrior^ before pulling the boss or you will end up stuck in the encounter. After you've killed one or more, pull ^Jin'do the Godbreaker^.",
                    minNote = "Kill a Spirit Warrior then Jin'do",
                    points  = {
                        { 0.361, 0.275 },
                        { 0.384, 0.278 },
                        { 0.404, 0.275 },
                        { 0.430, 0.299 },
                        { 0.415, 0.366 },
                        { 0.411, 0.387 },
                        { 0.422, 0.399 },
                        { 0.459, 0.398 },
                        { 0.457, 0.355 },
                        { 0.512, 0.354 },
                        { 0.512, 0.396 },
                    },
                },
            },
        },
    },
}
