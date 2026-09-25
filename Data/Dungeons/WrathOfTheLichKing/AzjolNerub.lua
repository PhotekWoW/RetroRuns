-------------------------------------------------------------------------------
-- RetroRuns Data -- Azjol-Nerub
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 601  |  journalInstanceID: 272
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[272] = {
    kind              = "dungeon",
    instanceID        = 601,
    journalInstanceID = 272,
    name              = "Azjol-Nerub",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    timewalking       = true,
    routedIn          = "3.3.0",

    entrance = {
        mapID = 115,
        x     = 0.2590,
        y     = 0.5099,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37244, slot = "Feet", name = "Fungi-Coated Boots", sources = { [15]=17692 }, bind = "BoE" },
        { id = 37625, slot = "Hands", name = "Web Winder Gloves", sources = { [15]=17904 }, bind = "BoE" },
        { id = 37243, slot = "Waist", name = "Treasure Seeker's Belt", sources = { [15]=17691 }, bind = "BoE" },
        { id = 35664, slot = "Weapon", name = "Unknown Archaeologist's Hammer", sources = { [14]=16586 }, bind = "BoE" },
        { id = 35665, slot = "Wrist", name = "Soothing Lichen Wraps", sources = { [14]=16587 }, bind = "BoE" },
        { id = 37245, slot = "Wrist", name = "Tangled Web Bindings", sources = { [15]=17693 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Krik'thir the Gatewatcher",
            journalEncounterID = 585,
            dungeonEncounterID = 1971,
            achievements       = {
                { id = 1296, name = "Watch Him Die", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37219, slot = "Chest", name = "Custodian's Chestpiece", sources = { [14]=17672, [15]=17672 }, twSource = 165729 },
                { id = 35657, slot = "Feet", name = "Exquisite Spider-Silk Footwraps", sources = { [14]=16580, [15]=16580 }, twSource = 165720 },
                { id = 37218, slot = "Feet", name = "Stone-Worn Footwraps", sources = { [14]=17671, [15]=17671 }, twSource = 165728 },
                { id = 35656, slot = "Hands", name = "Aura Focused Gauntlets", sources = { [14]=16579, [15]=16579 }, twSource = 165719 },
                { id = 37216, slot = "Off-hand", name = "Facade Shield of Glyphs", sources = { [14]=17669, [15]=17669 }, twSource = 165726 },
                { id = 157582, slot = "Shoulder", name = "Nerubian Mantle", sources = { [14]=93773, [15]=93773 }, twSource = 165741 },
                { id = 35655, slot = "Weapon", name = "Cobweb Machete", sources = { [14]=16578, [15]=16578 }, twSource = 165718 },
                { id = 37217, slot = "Wrist", name = "Golden Limb Bands", sources = { [14]=17670, [15]=17670 }, twSource = 165727 },
            },
        },
        {
            index              = 2,
            name               = "Hadronox",
            journalEncounterID = 586,
            dungeonEncounterID = 1972,
            achievements       = {
                { id = 1297, name = "Hadronox Denied", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37222, slot = "Chest", name = "Egg Sac Robes", sources = { [14]=17674, [15]=17674 }, twSource = 165731 },
                { id = 35659, slot = "Feet", name = "Treads of Aspiring Heights", sources = { [14]=16582, [15]=16582 }, twSource = 165722 },
                { id = 37230, slot = "Hands", name = "Grotto Mist Gloves", sources = { [14]=17681, [15]=17681 }, twSource = 165732 },
                { id = 157581, slot = "Hands", name = "Skittering Gauntlets", sources = { [14]=93772, [15]=93772 }, twSource = 165740 },
                { id = 37221, slot = "Legs", name = "Hollowed Mandible Legplates", sources = { [14]=17673, [15]=17673 }, twSource = 165730 },
                { id = 35660, slot = "Shoulder", name = "Spinneret Epaulets", sources = { [14]=16583, [15]=16583 }, twSource = 165723 },
                { id = 35658, slot = "Two-Hand", name = "Life-Staff of the Web Lair", sources = { [14]=16581, [15]=16581 }, twSource = 165721 },
            },
        },
        {
            index              = 3,
            name               = "Anub'arak",
            journalEncounterID = 587,
            dungeonEncounterID = 1973,
            achievements       = {
                { id = 1860, name = "Gotta Go!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37236, slot = "Chest", name = "Insect Vestments", sources = { [14]=17684, [15]=17684 }, twSource = 165734 },
                { id = 37237, slot = "Head", name = "Chitin Shell Greathelm", sources = { [14]=17685, [15]=17685 }, twSource = 165735 },
                { id = 37238, slot = "Ranged", name = "Rod of the Fallen Monarch", sources = { [14]=17686, [15]=17686 }, twSource = 165736 },
                { id = 37241, slot = "Waist", name = "Ancient Aligned Girdle", sources = { [14]=17689, [15]=17689 }, twSource = 165738 },
                { id = 35663, slot = "Waist", name = "Charmed Silken Cord", sources = { [14]=16585, [15]=16585 }, twSource = 165725 },
                { id = 37242, slot = "Waist", name = "Sash of the Servant", sources = { [14]=17690, [15]=17690 }, twSource = 165739 },
                { id = 35662, slot = "Waist", name = "Wing Cover Girdle", sources = { [14]=16584, [15]=16584 }, twSource = 165724 },
                { id = 37235, slot = "Weapon", name = "Crypt Lord's Deft Blade", sources = { [14]=17683, [15]=17683 }, twSource = 165733 },
                { id = 37240, slot = "Wrist", name = "Flamebeard's Bracers", sources = { [14]=17688, [15]=17688 }, twSource = 165737 },
            },
        },
    },

    exitNote    = "Continue east past the boss to arrive at an exit",
    minExitNote = "Continue east to exit",

    routing = {
        -- 1. Krik'thir the Gatewatcher (boss 1). Straight down the tunnel
        -- from the door.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Krik'thir the Gatewatcher",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 159 },
                    kind    = "path",
                    note    = "After zoning in, follow the path straight ahead to reach ^Krik'thir the Gatewatcher^.",
                    minNote = "Follow path to Krik'thir",
                    points  = {
                        { 0.154, 0.831 },
                        { 0.196, 0.727 },
                        { 0.207, 0.579 },
                        { 0.231, 0.420 },
                        { 0.252, 0.361 },
                        { 0.293, 0.361 },
                        { 0.463, 0.458 },
                    },
                },
            },
        },

        -- 2. Hadronox (boss 2). Along the path behind the Gatewatcher, then
        -- a drop onto the webs.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Hadronox",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 159 },
                    kind    = "path",
                    note    = "After killing ^Krik'thir the Gatewatcher^, continue on the path behind him. When you're at a safe height, jump down to find ^Hadronox^ walking around on the spiderwebs below.",
                    minNote = "Follow path to Hadronox",
                    points  = {
                        { 0.543, 0.444 },
                        { 0.889, 0.447 },
                        { 0.861, 0.407 },
                        { 0.796, 0.408 },
                        { 0.738, 0.398 },
                        { 0.659, 0.250 },
                    },
                },
            },
        },

        -- 3. Anub'arak (boss 3). Down through the webs to the hole.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Anub'arak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 158 },
                    kind    = "path",
                    note    = "After defeating ^Hadronox^, continue down through the webs and jump into the hole by the pile of skeletons.",
                    minNote = "Jump into hole by skeletons",
                    points  = {
                        { 0.474, 0.142 },
                        { 0.579, 0.178 },
                        { 0.610, 0.279 },
                        { 0.617, 0.368 },
                        { 0.592, 0.557 },
                        { 0.463, 0.680 },
                    },
                },
                {
                    when    = { mapID = 157 },
                    kind    = "path",
                    note    = "After you land, follow the path to ^Anub'arak^.",
                    minNote = "Follow path to Anub'arak",
                    points  = {
                        { 0.285, 0.506 },
                        { 0.364, 0.491 },
                        { 0.596, 0.489 },
                    },
                },
            },
        },
    },
}
