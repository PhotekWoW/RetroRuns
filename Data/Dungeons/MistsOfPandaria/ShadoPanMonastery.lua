-------------------------------------------------------------------------------
-- RetroRuns Data -- Shado-Pan Monastery
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 959  |  journalInstanceID: 312
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[312] = {
    kind              = "dungeon",
    instanceID        = 959,
    journalInstanceID = 312,
    name              = "Shado-Pan Monastery",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",
    timewalking       = true,

    entrance = {
        mapID = 388,
        x     = 0.7893,
        y     = 0.2383,
    },

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Gu Cloudstrike",
            journalEncounterID = 673,
            achievements       = {
                { id = 6715, name = "Polyformic Acid Science", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 143961, slot = "Chest", name = "Azure Serpent Chestguard", sources = { [14]=84296, [15]=84296 } },
                { id = 143978, slot = "Legs", name = "Leggings of the Charging Soul", sources = { [14]=84313, [15]=84313 } },
                { id = 144096, slot = "Waist", name = "Sparkbreath Girdle", sources = { [14]=84402, [15]=84402 } },
                { id = 144126, slot = "Wrist", name = "Star Summoner Bracers", sources = { [14]=84423, [15]=84423 } },
            },
        },
        {
            index              = 2,
            name               = "Master Snowdrift",
            journalEncounterID = 657,
            achievements       = {
                { id = 6477, name = "Respect", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144106, slot = "Hands", name = "Gauntlets of Resolute Fury", sources = { [14]=84411, [15]=84411 } },
                { id = 144110, slot = "Two-Hand", name = "Snowdrift's Bladed Staff", sources = { [14]=84415, [15]=84415 } },
                { id = 144097, slot = "Waist", name = "Quivering Heart Girdle", sources = { [14]=84403, [15]=84403 } },
            },
        },
        {
            index              = 3,
            name               = "Sha of Violence",
            journalEncounterID = 685,
            achievements       = {
                { id = 6472, name = "The Obvious Solution", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 143985, slot = "Feet", name = "Spike-Soled Stompers", sources = { [14]=84320, [15]=84320 } },
                { id = 144107, slot = "Hands", name = "Gloves of Enraged Slaughter", sources = { [14]=84412, [15]=84412 } },
                { id = 144099, slot = "Weapon", name = "Crescent of Ichor", sources = { [14]=84405, [15]=84405 } },
                { id = 144131, slot = "Wrist", name = "Bladed Smoke Bracers", sources = { [14]=84424, [15]=84424 } },
            },
        },
        {
            index              = 4,
            name               = "Taran Zhu",
            journalEncounterID = 686,
            achievements       = {
                { id = 6471, name = "Hate Leads to Suffering", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 143962, slot = "Chest", name = "Hateshatter Chestplate", sources = { [14]=84297, [15]=84297 } },
                { id = 143990, slot = "Chest", name = "Robes of Fevered Dreams", sources = { [14]=84325, [15]=84325 } },
                { id = 143986, slot = "Feet", name = "Blastwalker Footguards", sources = { [14]=84321, [15]=84321 } },
                { id = 144108, slot = "Hands", name = "Mindbinder Plate Gloves", sources = { [14]=84413, [15]=84413 } },
                { id = 143979, slot = "Legs", name = "Darkbinder Leggings", sources = { [14]=84314, [15]=84314 } },
                { id = 144103, slot = "Off-hand", name = "Shield of Blind Hate", sources = { [14]=84408, [15]=84408 } },
                { id = 143981, slot = "Shoulder", name = "Shadowspine Shoulderguards", sources = { [14]=84316, [15]=84316 } },
                { id = 144109, slot = "Two-Hand", name = "Warmace of Taran Zhu", sources = { [14]=84414, [15]=84414 } },
                { id = 144215, slot = "Weapon", name = "Ka'eng, Breath of the Shadow", sources = { [14]=84483, [15]=84483 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Gu Cloudstrike (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Gu Cloudstrike",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 444 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path until you're outside and you'll run right into ^Gu Cloudstrike^.",
                    minNote = "Follow path to Gu Cloudstrike",
                    points  = {
                        { 0.854, 0.549 },
                        { 0.833, 0.492 },
                        { 0.751, 0.452 },
                        { 0.638, 0.541 },
                        { 0.586, 0.394 },
                        { 0.467, 0.269 },
                    },
                },
            },
        },
        -- 2. Master Snowdrift (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Master Snowdrift",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 444 },
                    kind    = "path",
                    note    = "After defeating ^Gu Cloudstrike^, re-enter the building to the southwest. Travel a short distance and you will be back outside with archers firing at you.",
                    minNote = "Go southwest through building",
                    points  = {
                        { 0.456, 0.320 },
                        { 0.470, 0.539 },
                        { 0.501, 0.642 },
                        { 0.166, 0.886 },
                    },
                },
                {
                    when    = { mapID = 443 },
                    kind    = "path",
                    note    = "Mount up and follow the path upstairs and across the bridge. Enter the building to the west.",
                    minNote = "West path to building",
                    points  = {
                        { 0.549, 0.856 },
                        { 0.535, 0.792 },
                        { 0.541, 0.752 },
                        { 0.535, 0.716 },
                        { 0.507, 0.703 },
                        { 0.413, 0.761 },
                        { 0.373, 0.806 },
                        { 0.324, 0.766 },
                    },
                },
                {
                    when    = { mapID = 445 },
                    kind    = "poi",
                    note    = "Once you enter the building, kill several waves of enemies. After defeating the two senior students, you can go up the stairs.",
                    minNote = "Kill several waves",
                    points  = {
                        { 0.606, 0.645 },
                    },
                },
                {
                    when        = { mapID = 445 },
                    kind        = "path",
                    triggeredBy = { dialog = { npc = "Master Snowdrift", match = "You have bested my prize students" } },
                    note        = "Go up the stairs and face ^Master Snowdrift^ next.",
                    minNote     = "Upstairs to Snowdrift",
                    points      = {
                        { 0.556, 0.593 },
                        { 0.483, 0.516 },
                        { 0.413, 0.659 },
                        { 0.383, 0.626 },
                        { 0.455, 0.477 },
                        { 0.272, 0.291 },
                    },
                },
            },
        },
        -- 3. Sha of Violence (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Sha of Violence",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 445 },
                    kind    = "path",
                    note    = "After defeating ^Master Snowdrift^, exit the building behind him and follow the path across a bridge. Continue into the next building.",
                    minNote = "Path to next building",
                    points  = {
                        { 0.234, 0.245 },
                        { 0.120, 0.136 },
                    },
                },
                {
                    when    = { mapID = 443 },
                    kind    = "path",
                    note    = "After defeating ^Master Snowdrift^, exit the building behind him and follow the path across a bridge. Continue into the next building.",
                    minNote = "Path to next building",
                    points  = {
                        { 0.248, 0.699 },
                        { 0.201, 0.694 },
                        { 0.172, 0.700 },
                        { 0.122, 0.624 },
                        { 0.248, 0.421 },
                        { 0.332, 0.338 },
                    },
                },
                {
                    when    = { mapID = 446 },
                    kind    = "path",
                    note    = "In the next building, you will find ^Sha of Violence^ straight ahead.",
                    minNote = "Ahead to Sha of Violence",
                    points  = {
                        { 0.200, 0.708 },
                        { 0.240, 0.697 },
                        { 0.255, 0.628 },
                        { 0.296, 0.616 },
                        { 0.332, 0.660 },
                        { 0.459, 0.614 },
                    },
                },
            },
        },
        -- 4. Taran Zhu (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Taran Zhu",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 446 },
                    kind    = "path",
                    note    = "After killing ^Sha of Violence^, exit the building to the south.",
                    minNote = "Exit building to south",
                    points  = {
                        { 0.487, 0.689 },
                        { 0.521, 0.875 },
                    },
                },
                {
                    when    = { mapID = 443 },
                    kind    = "path",
                    note    = "Back outside, follow the path to the east until you reach ^Taran Zhu^.",
                    minNote = "East to Taran Zhu",
                    points  = {
                        { 0.471, 0.441 },
                        { 0.552, 0.522 },
                        { 0.613, 0.529 },
                        { 0.696, 0.495 },
                    },
                },
            },
        },
    },
}
