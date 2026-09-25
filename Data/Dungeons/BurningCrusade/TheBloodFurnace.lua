-------------------------------------------------------------------------------
-- RetroRuns Data -- The Blood Furnace
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 542  |  journalInstanceID: 256
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[256] = {
    kind              = "dungeon",
    instanceID        = 542,
    journalInstanceID = 256,
    name              = "The Blood Furnace",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    routedIn          = "3.2.0",
    timewalking       = true,

    entrance = {
        mapID = 100,
        x     = 0.4587,
        y     = 0.5193,
    },

    bosses = {
        {
            index              = 1,
            name               = "The Maker",
            journalEncounterID = 555,
            dungeonEncounterID = 1922,
            achievements       = {
            },
            loot = {
                { id = 27485, slot = "Back", name = "Embroidered Cape of Mysteries", sources = { [14]=11928, [15]=11928 }, twSource = 165628 },
                { id = 24387, slot = "Hands", name = "Ironblade Gauntlets", sources = { [14]=9528, [15]=9528 }, twSource = 165616 },
                { id = 27488, slot = "Head", name = "Mage-Collar of the Firestorm", sources = { [14]=11931, [15]=11931 }, twSource = 165630 },
                { id = 27487, slot = "Legs", name = "Bloodlord Legplates", sources = { [14]=11930, [15]=11930 }, twSource = 165629 },
                { id = 24388, slot = "Waist", name = "Girdle of the Gale Storm", sources = { [14]=9529, [15]=9529 }, twSource = 165617 },
                { id = 24384, slot = "Weapon", name = "Diamond-Core Sledgemace", sources = { [14]=9527, [15]=9527 }, twSource = 165615 },
                { id = 27483, slot = "Wrist", name = "Moon-Touched Bands", sources = { [14]=11927, [15]=11927 }, twSource = 165627 },
            },
        },
        {
            index              = 2,
            name               = "Broggok",
            journalEncounterID = 556,
            dungeonEncounterID = 1924,
            achievements       = {
            },
            loot = {
                { id = 27848, slot = "Feet", name = "Embroidered Spellpyre Boots", sources = { [14]=12106, [15]=12106 }, twSource = 165642 },
                { id = 24393, slot = "Hands", name = "Bloody Surgeon's Mitts", sources = { [14]=9533, [15]=9533 }, twSource = 165621 },
                { id = 24391, slot = "Legs", name = "Kilt of the Night Strider", sources = { [14]=9531, [15]=9531 }, twSource = 165619 },
                { id = 27492, slot = "Legs", name = "Moonchild Leggings", sources = { [14]=11934, [15]=11934 }, twSource = 165633 },
                { id = 24389, slot = "Ranged", name = "Legion Blunderbuss", sources = { [14]=9530, [15]=9530 }, twSource = 165618 },
                { id = 27490, slot = "Weapon", name = "Firebrand Battleaxe", sources = { [14]=11933, [15]=11933 }, twSource = 165632 },
                { id = 24392, slot = "Wrist", name = "Arcing Bracers", sources = { [14]=9532, [15]=9532 }, twSource = 165620 },
                { id = 27494, slot = "Wrist", name = "Emerald Eye Bracer", sources = { [14]=11936, [15]=11936 }, twSource = 165634 },
                { id = 27489, slot = "Wrist", name = "Virtue Bearer's Vambraces", sources = { [14]=11932, [15]=11932 }, twSource = 165631 },
            },
        },
        {
            index              = 3,
            name               = "Keli'dan the Breaker",
            journalEncounterID = 557,
            dungeonEncounterID = 1923,
            achievements       = {
            },
            loot = {
                { id = 24397, slot = "Chest", name = "Raiments of Divine Authority", sources = { [14]=9537, [15]=9537 }, twSource = 165625 },
                { id = 27506, slot = "Chest", name = "Robe of Effervescent Light", sources = { [14]=11940, [15]=11940 }, twSource = 165637 },
                { id = 24396, slot = "Chest", name = "Vest of Vengeance", sources = { [14]=9536, [15]=9536 }, twSource = 165624 },
                { id = 28264, slot = "Chest", name = "Wastewalker Tunic", sources = { [14]=12362, [15]=12362 }, twSource = 165643, setName = "Wastewalker Armor", dungeonSet = 3 },
                { id = 27788, slot = "Feet", name = "Bloodsworn Warboots", sources = { [14]=12064, [15]=12064 }, twSource = 165641 },
                { id = 29239, slot = "Feet", name = "Eaglecrest Warboots", sources = { [14]=13034, [15]=13034 }, twSource = 165644 },
                { id = 29245, slot = "Feet", name = "Wave-Crest Striders", sources = { [14]=13040, [15]=13040 }, twSource = 165645 },
                { id = 27497, slot = "Hands", name = "Doomplate Gauntlets", sources = { [14]=11938, [15]=11938 }, twSource = 165635, setName = "Doomplate Battlegear", dungeonSet = 3 },
                { id = 27505, slot = "Head", name = "Ruby Helm of the Just", sources = { [14]=11939, [15]=11939 }, twSource = 165636 },
                { id = 27514, slot = "Legs", name = "Leggings of the Unrepentant", sources = { [14]=11946, [15]=11946 }, twSource = 165640 },
                { id = 27507, slot = "Ranged", name = "Adamantine Repeater", sources = { [14]=11941, [15]=11941 }, twSource = 165638 },
                { id = 32080, slot = "Shoulder", name = "Mantle of Shadowy Embrace", sources = { [14]=14754, [15]=14754 }, twSource = 165646 },
                { id = 24398, slot = "Shoulder", name = "Mantle of the Dusk-Dweller", sources = { [14]=9538, [15]=9538 }, twSource = 165626 },
                { id = 24394, slot = "Two-Hand", name = "Warsong Howling Axe", sources = { [14]=9534, [15]=9534 }, twSource = 165622 },
                { id = 24395, slot = "Waist", name = "Mindfire Waistband", sources = { [14]=9535, [15]=9535 }, twSource = 165623 },
                { id = 27512, slot = "Weapon", name = "The Willbreaker", sources = { [14]=11945, [15]=11945 }, twSource = 165639 },
            },
        },
    },

    exitNote    = "Take the southern path to arrive back at the entrance",
    minExitNote = "Southern path to entrance",

    routing = {
        -- 1. The Maker (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "The Maker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 261 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path ahead until you reach ^The Maker^.",
                    minNote = "Follow path to The Maker",
                    points  = {
                        { 0.516, 0.900 },
                        { 0.580, 0.901 },
                        { 0.580, 0.549 },
                        { 0.540, 0.538 },
                        { 0.507, 0.489 },
                        { 0.497, 0.465 },
                        { 0.493, 0.435 },
                        { 0.462, 0.414 },
                        { 0.410, 0.415 },
                    },
                },
            },
        },
        -- 2. Broggok (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Broggok",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 261 },
                    kind    = "path",
                    note    = "After defeating ^The Maker^, continue on the linear path until you reach ^Broggok^. To engage the boss, pull the ^Cell Door Lever^ and clear the four waves.",
                    minNote = "Follow path to Broggok",
                    points  = {
                        { 0.360, 0.411 },
                        { 0.345, 0.410 },
                        { 0.321, 0.433 },
                        { 0.313, 0.389 },
                        { 0.307, 0.325 },
                        { 0.311, 0.252 },
                        { 0.319, 0.211 },
                        { 0.339, 0.220 },
                        { 0.365, 0.220 },
                    },
                },
                {
                    when            = { mapID = 261 },
                    kind            = "poi",
                    note            = "After defeating ^The Maker^, continue on the linear path until you reach ^Broggok^. To engage the boss, pull the ^Cell Door Lever^ and clear the four waves.",
                    minNote         = "Pull the Cell Door Lever",
                    mapLabel        = "Pull Lever",
                    mapLabelPos     = "below",
                    completionCheck = true,
                    points          = {
                        { 0.444, 0.219 },
                    },
                },
                {
                    -- Broggok's yell after the lever marks it pulled.
                    when        = { mapID = 261 },
                    kind        = "path",
                    note        = "After defeating ^The Maker^, continue on the linear path until you reach ^Broggok^. To engage the boss, pull the ^Cell Door Lever^ and clear the four waves.",
                    minNote     = "Clear the four waves",
                    triggeredBy = { dialog = { npc = "Broggok", match = "Kill them" } },
                    points      = { },
                },
            },
        },
        -- 3. Keli'dan the Breaker (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Keli'dan the Breaker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 261 },
                    kind    = "path",
                    note    = "After killing ^Broggok^, follow the linear path to the east and you will eventually arrive at ^Keli'dan the Breaker^. Clear the enemies around him to engage the boss.",
                    minNote = "Follow path to Keli'dan",
                    points  = {
                        { 0.455, 0.214 },
                        { 0.581, 0.214 },
                        { 0.581, 0.274 },
                        { 0.618, 0.289 },
                        { 0.638, 0.301 },
                        { 0.659, 0.338 },
                        { 0.673, 0.388 },
                        { 0.673, 0.414 },
                        { 0.609, 0.414 },
                    },
                },
            },
        },
    },
}
