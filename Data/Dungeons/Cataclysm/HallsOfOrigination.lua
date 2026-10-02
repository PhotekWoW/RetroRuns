-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Origination
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 644  |  journalInstanceID: 70
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[70] = {
    kind              = "dungeon",
    instanceID        = 644,
    journalInstanceID = 70,
    name              = "Halls of Origination",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.0.3",
    routedIn          = "3.3.3",

    entrance = {
        mapID = 249,
        x     = 0.6909,
        y     = 0.5310,
    },

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    trashLoot = {
        { id = 56109, slot = "Off-hand", name = "Book of Origination", sources = { [14]=27559, [15]=27559 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Temple Guardian Anhuur",
            journalEncounterID = 124,
            dungeonEncounterID = 1080,
            achievements       = {
                { id = 5293, name = "I Hate That Song", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56408, slot = "Feet", name = "Awakening Footfalls", sources = { [14]=27716, [15]=27716 } },
                { id = 56410, slot = "Waist", name = "Belt of Petrified Tears", sources = { [14]=27718, [15]=27718 } },
                { id = 56409, slot = "Wrist", name = "Poison Fang Bracers", sources = { [14]=27717, [15]=27717 } },
            },
        },
        {
            index              = 2,
            name               = "Earthrager Ptah",
            journalEncounterID = 125,
            dungeonEncounterID = 1076,
            achievements       = {
            },
            loot = {
                { id = 56425, slot = "Chest", name = "Breastplate of the Risen Land", sources = { [14]=27726, [15]=27726 } },
                { id = 56426, slot = "Off-hand", name = "Bulwark of the Primordial Mound", sources = { [14]=27727, [15]=27727 } },
                { id = 56424, slot = "Two-Hand", name = "Soul Releaser", sources = { [14]=27725, [15]=27725 } },
                { id = 56423, slot = "Waist", name = "Underworld Cord", sources = { [14]=27724, [15]=27724 } },
            },
        },
        {
            index              = 3,
            name               = "Anraphet",
            journalEncounterID = 126,
            dungeonEncounterID = 1075,
            achievements       = {
            },
            loot = {
                { id = 57868, slot = "Chest", name = "Anraphet's Regalia", sources = { [14]=28578, [15]=28578 } },
                { id = 57869, slot = "Chest", name = "Omega Breastplate", sources = { [14]=28579, [15]=28579 } },
                { id = 57867, slot = "Feet", name = "Boots of Crumbling Ruin", sources = { [14]=28577, [15]=28577 } },
                { id = 157611, slot = "Head", name = "Crown of Patient Vigil", sources = { [14]=93797, [15]=93797 } },
                { id = 57866, slot = "Shoulder", name = "Mantle of Soft Shadows", sources = { [14]=28576, [15]=28576 } },
                { id = 57870, slot = "Wrist", name = "Alpha Bracers", sources = { [14]=28580, [15]=28580 } },
            },
        },
        {
            index              = 4,
            name               = "Isiset, Construct of Magic",
            journalEncounterID = 127,
            dungeonEncounterID = 1077,
            aliases            = { "Isiset" },
            scenarioCriteriaID = 24831,
            achievements       = {
            },
            loot = {
                { id = 56413, slot = "Legs", name = "Legwraps of Astral Rain", sources = { [14]=27719, [15]=27719 } },
                { id = 157609, slot = "Weapon", name = "Scepter of Stargazing", sources = { [14]=93795, [15]=93795 } },
                { id = 56416, slot = "Wrist", name = "Armguards of Unearthly Light", sources = { [14]=27720, [15]=27720 } },
            },
        },
        {
            index              = 5,
            name               = "Ammunae, Construct of Life",
            journalEncounterID = 128,
            dungeonEncounterID = 1074,
            aliases            = { "Ammunae" },
            achievements       = {
            },
            loot = {
                { id = 56417, slot = "Chest", name = "Robes of Rampant Growth", sources = { [14]=27721, [15]=27721 } },
                { id = 56419, slot = "Shoulder", name = "Bloodpetal Mantle", sources = { [14]=27722, [15]=27722 } },
            },
        },
        {
            index              = 6,
            name               = "Setesh, Construct of Destruction",
            journalEncounterID = 129,
            dungeonEncounterID = 1079,
            aliases            = { "Setesh" },
            achievements       = {
            },
            loot = {
                { id = 57874, slot = "Chest", name = "Hieroglyphic Vest", sources = { [14]=28584, [15]=28584 } },
                { id = 57873, slot = "Head", name = "Helm of Setesh", sources = { [14]=28583, [15]=28583 } },
                { id = 57871, slot = "Head", name = "Helm of the Typhonic Beast", sources = { [14]=28581, [15]=28581 } },
                { id = 57875, slot = "Legs", name = "Chaotic Wrappings", sources = { [14]=28585, [15]=28585 } },
                { id = 57872, slot = "Weapon", name = "Scepter of Power", sources = { [14]=28582, [15]=28582 } },
            },
        },
        {
            index              = 7,
            name               = "Rajh, Construct of Sun",
            journalEncounterID = 130,
            dungeonEncounterID = 1078,
            aliases            = { "Rajh" },
            achievements       = {
                { id = 5295, name = "Sun of a....", meta = true, soloable = "yes" },
                { id = 5296, name = "Faster Than the Speed of Light", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 56434, slot = "Back", name = "Solar Wind Cloak", sources = { [14]=27732, [15]=27732 } },
                { id = 56436, slot = "Feet", name = "Hekatic Slippers", sources = { [14]=27734, [15]=27734 } },
                { id = 56428, slot = "Hands", name = "Fingers of Light", sources = { [14]=27728, [15]=27728 } },
                { id = 56435, slot = "Legs", name = "Legguards of Noon", sources = { [14]=27733, [15]=27733 } },
                { id = 56429, slot = "Waist", name = "Red Beam Cord", sources = { [14]=27729, [15]=27729 } },
                { id = 56433, slot = "Weapon", name = "Blade of the Burning Sun", sources = { [14]=27731, [15]=27731 } },
                { id = 56430, slot = "Weapon", name = "Sun Strike", sources = { [14]=27730, [15]=27730 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Temple Guardian Anhuur (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Temple Guardian Anhuur",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 297 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path to the north until you reach ^Temple Guardian Anhuur^.",
                    minNote = "Follow path north to Anhuur",
                    points  = {
                        { 0.483, 0.924 },
                        { 0.482, 0.735 },
                        { 0.502, 0.735 },
                        { 0.502, 0.629 },
                        { 0.561, 0.630 },
                    },
                },
            },
        },

        -- 2. Anraphet (boss 3). Brann opens the door; four elementals in
        -- the room beyond spawn Anraphet once dead.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 3,
            title     = "Anraphet",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 297 },
                    kind    = "path",
                    note    = "After killing ^Temple Guardian Anhuur^, continue past him to the east. At the junction, go west to find ^Brann^ standing at a door. Talk to him to proceed.",
                    minNote = "Follow path to Brann",
                    points  = {
                        { 0.608, 0.627 },
                        { 0.672, 0.629 },
                        { 0.674, 0.498 },
                        { 0.563, 0.498 },
                    },
                },
                {
                    -- Noteless, so the note above stands until the door
                    -- opens; his line moves the route past it.
                    when            = { mapID = 297 },
                    kind            = "poi",
                    mapLabel        = "Talk to Brann",
                    mapLabelPos     = "right",
                    completionCheck = true,
                    points          = {
                        { 0.561, 0.428 },
                    },
                },
                {
                    when          = { mapID = 297 },
                    kind          = "poi",
                    note          = "With the door open, work your way around the room killing all four elementals to spawn ^Anraphet^.",
                    minNote       = "Kill four elementals for Anraphet",
                    triggeredBy   = { dialog = { npc = "Brann Bronzebeard", match = "Just need to input the final entry sequence into the door mechanism" } },
                    drawWhenOpen  = true,
                    markAllPoints = true,
                    poiIcon       = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\QuestMarker",
                    poiSize       = 18,
                    points        = {
                        { 0.494, 0.324 },
                        { 0.632, 0.324 },
                        { 0.632, 0.211 },
                        { 0.494, 0.212 },
                    },
                },
            },
        },

        -- 3. Earthrager Ptah (boss 2). The Transit Device in the Vault of
        -- Lights carries the player down to the Tomb of the Earthrager.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 2,
            title     = "Earthrager Ptah",
            requires  = { },
            segments  = {
                {
                    when     = { mapID = 297 },
                    kind     = "poi",
                    note     = "After killing ^Anraphet^, click the ^Halls of Origination Transit Device^ in the middle of the room.",
                    minNote  = "Click Transit Device in middle of room",
                    mapLabel = "Click Transit Device",
                    points   = {
                        { 0.561, 0.280 },
                    },
                },
                {
                    when    = { mapID = 297, subZone = "The Maker's Rise" },
                    kind    = "path",
                    note    = "After teleporting, go east to the next area.",
                    minNote = "After teleporting go east",
                    points  = {
                        { 0.703, 0.497 },
                        { 0.915, 0.496 },
                    },
                },
                {
                    when    = { mapID = 298 },
                    kind    = "path",
                    note    = "Continue ahead to reach ^Earthrager Ptah^.",
                    minNote = "Ahead to Earthrager Ptah",
                    points  = {
                        { 0.327, 0.492 },
                        { 0.473, 0.492 },
                    },
                },
            },
        },

        -- 4. Isiset, Construct of Magic (boss 4).
        -- Carries the way up, for when earlier Constructs are left out.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Isiset, Construct of Magic",
            requires  = { },
            skipWhenCollected = true,
            segments  = {
                {
                    when     = { mapID = 298 },
                    kind     = "poi",
                    note     = "After bringing down ^Earthrager Ptah^, go slightly west and click on the ^Halls of Origination Transit Device^ to teleport back to the main corridor.",
                    minNote  = "West to Transit Device",
                    mapLabel = "Click Transit Device",
                    points   = {
                        { 0.383, 0.493 },
                    },
                },
                {
                    when        = { mapID = 297 },
                    kind        = "poi",
                    note        = "After teleporting back to ^The Maker's Rise^, click ^The Maker's Lift Controller^ on the northwest side of the room and take it to the second floor.",
                    minNote     = "Take Lift to Second Floor",
                    mapLabel    = "Take Lift",
                    mapLabelPos = "above",
                    points      = {
                        { 0.660, 0.473 },
                    },
                },
                {
                    when    = { mapID = 299 },
                    kind    = "path",
                    note    = "Visit the west wing to kill ^Isiset, Construct of Magic^.",
                    minNote = "West to Isiset",
                    points  = {
                        { 0.445, 0.493 },
                        { 0.334, 0.493 },
                    },
                },
            },
        },

        -- 5. Ammunae, Construct of Life (boss 5).
        -- Carries the way up, for when earlier Constructs are left out.
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Ammunae, Construct of Life",
            requires  = { },
            skipWhenCollected = true,
            segments  = {
                {
                    when     = { mapID = 298 },
                    kind     = "poi",
                    note     = "After bringing down ^Earthrager Ptah^, go slightly west and click on the ^Halls of Origination Transit Device^ to teleport back to the main corridor.",
                    minNote  = "West to Transit Device",
                    mapLabel = "Click Transit Device",
                    points   = {
                        { 0.383, 0.493 },
                    },
                },
                {
                    when        = { mapID = 297 },
                    kind        = "poi",
                    note        = "After teleporting back to ^The Maker's Rise^, click ^The Maker's Lift Controller^ on the northwest side of the room and take it to the second floor.",
                    minNote     = "Take Lift to Second Floor",
                    mapLabel    = "Take Lift",
                    mapLabelPos = "above",
                    points      = {
                        { 0.660, 0.473 },
                    },
                },
                {
                    when    = { mapID = 299 },
                    kind    = "path",
                    note    = "Visit the south wing to kill ^Ammunae, Construct of Life^.",
                    minNote = "South wing for Ammunae",
                    points  = {
                        { 0.472, 0.551 },
                        { 0.472, 0.712 },
                    },
                },
            },
        },

        -- 6. Setesh, Construct of Destruction (boss 6).
        -- Carries the way up, for when earlier Constructs are left out.
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Setesh, Construct of Destruction",
            requires  = { },
            skipWhenCollected = true,
            segments  = {
                {
                    when     = { mapID = 298 },
                    kind     = "poi",
                    note     = "After bringing down ^Earthrager Ptah^, go slightly west and click on the ^Halls of Origination Transit Device^ to teleport back to the main corridor.",
                    minNote  = "West to Transit Device",
                    mapLabel = "Click Transit Device",
                    points   = {
                        { 0.383, 0.493 },
                    },
                },
                {
                    when        = { mapID = 297 },
                    kind        = "poi",
                    note        = "After teleporting back to ^The Maker's Rise^, click ^The Maker's Lift Controller^ on the northwest side of the room and take it to the second floor.",
                    minNote     = "Take Lift to Second Floor",
                    mapLabel    = "Take Lift",
                    mapLabelPos = "above",
                    points      = {
                        { 0.660, 0.473 },
                    },
                },
                {
                    when    = { mapID = 299 },
                    kind    = "path",
                    note    = "Visit the east wing to kill ^Setesh, Construct of Destruction^.",
                    minNote = "East wing for Setesh",
                    points  = {
                        { 0.504, 0.493 },
                        { 0.616, 0.493 },
                    },
                },
            },
        },

        -- 7. Rajh, Construct of Sun (boss 7), the north wing. Open from the
        -- start, with the same way up as the other three.
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Rajh, Construct of Sun",
            requires  = { },
            segments  = {
                {
                    when     = { mapID = 298 },
                    kind     = "poi",
                    note     = "After bringing down ^Earthrager Ptah^, go slightly west and click on the ^Halls of Origination Transit Device^ to teleport back to the main corridor.",
                    minNote  = "West to Transit Device",
                    mapLabel = "Click Transit Device",
                    points   = {
                        { 0.383, 0.493 },
                    },
                },
                {
                    when        = { mapID = 297 },
                    kind        = "poi",
                    note        = "After teleporting back to ^The Maker's Rise^, click ^The Maker's Lift Controller^ on the northwest side of the room and take it to the second floor.",
                    minNote     = "Take Lift to Second Floor",
                    mapLabel    = "Take Lift",
                    mapLabelPos = "above",
                    points      = {
                        { 0.660, 0.473 },
                    },
                },
                {
                    when    = { mapID = 299 },
                    kind    = "path",
                    note    = "Visit the north wing to kill ^Rajh, Construct of Sun^.",
                    minNote = "North wing for Rajh",
                    points  = {
                        { 0.472, 0.435 },
                        { 0.472, 0.274 },
                    },
                },
            },
        },
    },
}
