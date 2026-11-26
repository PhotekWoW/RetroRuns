-------------------------------------------------------------------------------
-- RetroRuns Data -- Court of Stars
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1571  |  journalInstanceID: 800
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[800] = {
    kind              = "dungeon",
    instanceID        = 1571,
    journalInstanceID = 800,
    name              = "Court of Stars",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 15, 16 },
    unsavedDifficulties = { 15 },
    patch             = "7.0.3",
    routedIn          = "3.5.5",
    timewalking       = true,

    entrance = {
        mapID = 680,
        x     = 0.5097,
        y     = 0.6559,
    },

    gloryMeta = {
        id   = 11163,
        name = "Glory of the Legion Hero",
        rewardItemID       = 141217,
        rewardMountSpellID = 225765,
        rewardName         = "Leyfeather Hippogryph",
    },

    bosses = {
        {
            index              = 1,
            name               = "Patrol Captain Gerdo",
            journalEncounterID = 1718,
            dungeonEncounterID = 1868,
            achievements       = {
                { id = 10610, name = "Waiting for Gerdo", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 137483, slot = "Back", name = "Cape of the Duskwatch", sources = { [14]=79066, [15]=80818, [16]=79066 } },
                { id = 134415, slot = "Chest", name = "Arcanist's Resonant Robes", sources = { [14]=79062, [15]=80004, [16]=79062 } },
                { id = 137482, slot = "Feet", name = "Duskwatch Guard's Boots", sources = { [14]=79065, [15]=79985, [16]=79065 } },
                { id = 134308, slot = "Feet", name = "Manawracker Sandals", sources = { [15]=77582, [16]=77582 } },
                { id = 134268, slot = "Hands", name = "Arcane Defender's Gauntlets", sources = { [15]=77552, [16]=77552 } },
                { id = 137480, slot = "Hands", name = "Guileful Intruder Handguards", sources = { [14]=79063, [15]=80105, [16]=79063 } },
                { id = 134480, slot = "Shoulder", name = "Epaulets of Deceitful Intent", sources = { [14]=79064, [15]=80140, [16]=79064 } },
                { id = 134296, slot = "Wrist", name = "Ley Dragoon's Wristbraces", sources = { [15]=77570, [16]=77570 } },
                { id = 134280, slot = "Wrist", name = "Swordsinger's Wristguards", sources = { [15]=77561, [16]=77561 } },
            },
        },
        {
            index              = 2,
            name               = "Talixae Flamewreath",
            journalEncounterID = 1719,
            dungeonEncounterID = 1869,
            achievements       = {
            },
            loot = {
                { id = 134503, slot = "Chest", name = "Inferno Breastplate", sources = { [14]=79070, [15]=79945, [16]=79070 } },
                { id = 134385, slot = "Hands", name = "Mardum Chain Gloves", sources = { [15]=77639, [16]=77639 } },
                { id = 134473, slot = "Head", name = "Collar of Fiery Allegiance", sources = { [14]=79069, [15]=80133, [16]=79069 } },
                { id = 134392, slot = "Head", name = "Netherwhisper Hood", sources = { [15]=77646, [16]=77646 } },
                { id = 134460, slot = "Legs", name = "Fevermelt Legguards", sources = { [14]=79068, [15]=80085, [16]=79068 } },
                { id = 201994, slot = "Ranged", name = "Felsworn Covenant Crossbow", sources = { [15]=184048, [16]=184048 } },
                { id = 134374, slot = "Shoulder", name = "Felbat Leather Pauldrons", sources = { [15]=77635, [16]=77635 } },
                { id = 134360, slot = "Shoulder", name = "Portalguard Shoulders", sources = { [15]=77624, [16]=77624 } },
                { id = 137488, slot = "Waist", name = "Cord of Wicked Pyromania", sources = { [14]=79067, [15]=80045, [16]=79067 } },
            },
        },
        {
            index              = 3,
            name               = "Advisor Melandrus",
            journalEncounterID = 1720,
            dungeonEncounterID = 1870,
            achievements       = {
                { id = 10611, name = "Dropping Some Eaves", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 137498, slot = "Chest", name = "Luminous Bladesworn Hauberk", sources = { [14]=79077, [15]=80166, [16]=79077 } },
                { id = 137497, slot = "Feet", name = "Footpads of the Swift Balestra", sources = { [14]=79076, [15]=80106, [16]=79076 } },
                { id = 134298, slot = "Feet", name = "Ley Dragoon's Stompers", sources = { [15]=77572, [16]=77572 } },
                { id = 134513, slot = "Head", name = "Helmet of Reverent Loyalty", sources = { [14]=79059, [15]=79955, [16]=79059 } },
                { id = 134447, slot = "Head", name = "Veil of Unseen Strikes", sources = { [14]=79072, [15]=80072, [16]=79072 } },
                { id = 134271, slot = "Legs", name = "Arcane Defender's Pants", sources = { [15]=77555, [16]=77555 } },
                { id = 137496, slot = "Legs", name = "Suramar Magistrate Leggings", sources = { [14]=79075, [15]=80046, [16]=79075 } },
                { id = 134432, slot = "Shoulder", name = "Amice of the Unfurling Tempest", sources = { [14]=79071, [15]=80020, [16]=79071 } },
                { id = 201995, slot = "Two-Hand", name = "Crux of Blind Faith", sources = { [15]=184049, [16]=184049 } },
                { id = 137489, slot = "Waist", name = "Arcane-Bound Gale Chain", sources = { [14]=79073, [15]=80165, [16]=79073 } },
                { id = 137499, slot = "Waist", name = "Roaring Breeze Waistguard", sources = { [14]=79078, [15]=79986, [16]=79078 } },
                { id = 134287, slot = "Waist", name = "Swordsinger's Belt", sources = { [15]=77568, [16]=77568 } },
                { id = 201996, slot = "Weapon", name = "Edge of the First Blade", sources = { [15]=184050, [16]=184050 } },
                { id = 134310, slot = "Wrist", name = "Manawracker Bindings", sources = { [15]=77584, [16]=77584 } },
            },
            specialLoot = {
                { id = 247913, kind = "decor", name = "Ornate Suramar Table", decorID = 4027 },
            },
        },
    },

    exitNote    = "Talk to the nearby ^Dusk Lily Agent^ to exit.",
    minExitNote = "Talk to nearby NPC to exit",

    routing = {
        -- 1. Patrol Captain Gerdo (boss 1), across the water by lantern.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Patrol Captain Gerdo",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 761 },
                    kind            = "poi",
                    note            = "After zoning in, move forward and use the ^Signal Lantern^ to call for a boat. You will automatically jump into a boat to be taxi'd across the water.",
                    minNote         = "Click Signal Lantern for taxi",
                    mapLabel        = "Click Lantern",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    points          = {
                        { 0.110, 0.682 },
                    },
                },
                {
                    -- The boat is a vehicle: this opens, and draws, on boarding.
                    when         = { mapID = 761 },
                    kind         = "path",
                    note         = "When the boat arrives at Moonlit Landing, head left and enter the building. Climb some stairs to arrive in the ^Gilded Market^, and follow the path to the northwest until you reach ^Patrol Captain Gerdo^ patrolling around.",
                    minNote      = "Left to building, stairs to Gerdo",
                    triggeredBy  = { vehicle = true },
                    drawWhenOpen = true,
                    points       = {
                        { 0.427, 0.768 },
                        { 0.455, 0.725 },
                        { 0.411, 0.673 },
                        { 0.441, 0.620 },
                        { 0.417, 0.602 },
                        { 0.397, 0.535 },
                        { 0.358, 0.521 },
                        { 0.319, 0.463 },
                        { 0.332, 0.289 },
                    },
                },
            },
        },
        -- 2. Talixae Flamewreath (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Talixae Flamewreath",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 761 },
                    kind    = "path",
                    note    = "After killing ^Gerdo^, go up the stairs to the east. Work your way up some steps, then cross into the other building and take some steps back down. Exit the building and go east until you find ^Talixae Flamewreath^ patrolling around.",
                    minNote = "Linear path east to Talixae",
                    points  = {
                        { 0.374, 0.241 },
                        { 0.425, 0.268 },
                        { 0.487, 0.258 },
                        { 0.466, 0.337 },
                        { 0.451, 0.402 },
                        { 0.478, 0.417 },
                        { 0.490, 0.383 },
                        { 0.558, 0.463 },
                        { 0.586, 0.510 },
                        { 0.582, 0.538 },
                    },
                },
            },
        },
        -- 3. Advisor Melandrus (boss 3), through the spy hunt at the
        -- Jeweled Estate.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Advisor Melandrus",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 761 },
                    kind            = "poi",
                    poiKind         = "talk",
                    note            = "After defeating ^Talixae^, you will find ^Ly'leth Lunastre^ standing in front of ^The Jeweled Estate^. Talk to her to receive a disguise.",
                    minNote         = "Talk to Ly'leth for disguise",
                    mapLabel        = "Get Disguise from Ly'leth",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    points          = {
                        { 0.607, 0.622 },
                    },
                },
                {
                    -- Opens when Ly'leth's Masquerade lands.
                    when        = { mapID = 761 },
                    kind        = "path",
                    note        = "With your disguise on, enter ^The Jeweled Estate^. Talk to five ^Chatty Rumormonger^s to capture all five clues.",
                    minNote     = "Talk to five Chatty Rumormongers",
                    triggeredBy = { aura = 213213 },
                    clues       = {
                        total   = 5,
                        traits  = { "Gender", "Vest", "Sleeves", "Gloves", "Cape", "Belt" },
                        options = {
                            [45657] = { trait = "Gender",  value = "Male" },
                            [45658] = { trait = "Gender",  value = "Female" },
                            [45636] = { trait = "Vest",    value = "Light" },
                            [45635] = { trait = "Vest",    value = "Dark" },
                            [45676] = { trait = "Sleeves", value = "Long" },
                            [45677] = { trait = "Sleeves", value = "Short" },
                            [45673] = { trait = "Gloves",  value = "Yes" },
                            [45672] = { trait = "Gloves",  value = "No" },
                            [45674] = { trait = "Cape",    value = "Yes" },
                            [45675] = { trait = "Cape",    value = "No" },
                            [45660] = { trait = "Belt",    value = "Coin pouch" },
                            [45666] = { trait = "Belt",    value = "Potions" },
                            [45667] = { trait = "Belt",    value = "No potions" },
                            [45659] = { trait = "Belt",    value = "Book" },
                        },
                    },
                    points      = { },
                },
                {
                    when        = { mapID = 761 },
                    kind        = "path",
                    note        = "You have all five clues. Find the ^Suspicious Noble^ who matches every clue, talk to them, and accuse them of being the spy.",
                    minNote     = "Accuse the matching noble",
                    triggeredBy = { clues = 5 },
                    points      = { },
                },
                {
                    -- The right noble asks to talk in private.
                    when        = { mapID = 761 },
                    kind        = "path",
                    note        = "The spy will ask you to follow them to a balcony. Follow, then defeat ^Gerenth the Vile^ when he reveals himself.",
                    minNote     = "Follow the spy, defeat Gerenth",
                    triggeredBy = { dialog = { match = "let's not be hasty" } },
                    points      = { },
                },
                {
                    -- Gerenth reveals himself.
                    when            = { mapID = 763 },
                    kind            = "poi",
                    note            = "After killing ^Gerenth^, click the nearby ^Arcane Keys^.",
                    minNote         = "Click Arcane Keys",
                    mapLabel        = "Click Arcane Keys",
                    mapLabelPos     = "above",
                    triggeredBy     = { dialog = { match = "now it's time to die" } },
                    drawWhenOpen    = true,
                    completionCheck = true,
                    points          = {
                        { 0.639, 0.224 },
                    },
                },
                {
                    -- Ly'leth answers the keys.
                    when         = { mapID = 763 },
                    kind         = "path",
                    note         = "With the keys in hand, backtrack through the door and go south to unlock the door to the ^Skyward Terrace^. After a brief dialog, you can kill ^Advisor Melandrus^.",
                    minNote      = "Unlock Skyward Terrace for Melandrus",
                    triggeredBy  = { dialog = { npc = "Ly'leth Lunastre", match = "Now that we have the key" } },
                    drawWhenOpen = true,
                    points       = {
                        { 0.617, 0.265 },
                        { 0.555, 0.356 },
                        { 0.577, 0.403 },
                        { 0.593, 0.476 },
                        { 0.583, 0.555 },
                        { 0.560, 0.613 },
                        { 0.627, 0.734 },
                    },
                },
            },
        },
    },
}
