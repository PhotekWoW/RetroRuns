-------------------------------------------------------------------------------
-- RetroRuns Data -- Mogu'shan Palace
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 994  |  journalInstanceID: 321
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[321] = {
    kind              = "dungeon",
    instanceID        = 994,
    journalInstanceID = 321,
    name              = "Mogu'shan Palace",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",
    timewalking       = true,

    entrance = {
        mapID = 1530,
        x     = 0.814,
        y     = 0.302,
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
            name               = "Trial of the King",
            journalEncounterID = 708,
            -- Criterion prose reads "Trial of Kings defeated" and carries no boss name.
            scenarioCriteriaID = 24784,
            achievements       = {
                { id = 6715, name = "Polyformic Acid Science", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144145, slot = "Hands", name = "Conflagrating Gloves", sources = { [14]=84432, [15]=84432 } },
                { id = 144020, slot = "Head", name = "Crest of the Clan Lords", sources = { [14]=84355, [15]=84355 } },
                { id = 144021, slot = "Head", name = "Meteoric Greathelm", sources = { [14]=84356, [15]=84356 } },
                { id = 144143, slot = "Waist", name = "Hurricane Belt", sources = { [14]=84431, [15]=84431 } },
            },
        },
        {
            index              = 2,
            name               = "Gekkan",
            journalEncounterID = 690,
            achievements       = {
                { id = 6478, name = "Glintrok N' Roll", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144147, slot = "Back", name = "Cloak of Cleansing Flame", sources = { [14]=84433, [15]=84433 } },
                { id = 143992, slot = "Feet", name = "Glintrok Sollerets", sources = { [14]=84327, [15]=84327 } },
                { id = 144149, slot = "Hands", name = "Hexxer's Lethargic Gloves", sources = { [14]=84435, [15]=84435 } },
                { id = 144148, slot = "Weapon", name = "Claws of Gekkan", sources = { [14]=84434, [15]=84434 } },
            },
        },
        {
            index              = 3,
            name               = "Xin the Weaponmaster",
            journalEncounterID = 698,
            achievements       = {
                { id = 6736, name = "What Does This Button Do?", meta = true, soloable = "kinda" },
                { id = 6713, name = "Quarrelsome Quilen Quintet", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 143956, slot = "Chest", name = "Mind's Eye Breastplate", sources = { [14]=84291, [15]=84291 } },
                { id = 143993, slot = "Feet", name = "Boots of Plummeting Death", sources = { [14]=84328, [15]=84328 } },
                { id = 143994, slot = "Feet", name = "Soulbinder Treads", sources = { [14]=84329, [15]=84329 } },
                { id = 144151, slot = "Hands", name = "Axebreaker Gauntlets", sources = { [14]=84437, [15]=84437 } },
                { id = 143995, slot = "Shoulder", name = "Regal Silk Shoulderpads", sources = { [14]=84330, [15]=84330 } },
                { id = 144150, slot = "Two-Hand", name = "Ghostheart", sources = { [14]=84436, [15]=84436 } },
                { id = 144214, slot = "Two-Hand", name = "Mogu'Dar, Blade of the Thousand Slaves", sources = { [14]=84482, [15]=84482 } },
                { id = 144154, slot = "Weapon", name = "Firescribe Dagger", sources = { [14]=84439, [15]=84439 } },
                { id = 144153, slot = "Wrist", name = "Groundshaker Bracers", sources = { [14]=84438, [15]=84438 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Trial of the King (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Trial of the King",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 453 },
                    kind    = "path",
                    note    = "After zoning in, take a right and go down the long hallway until you reach the ^Trial of Kings^.",
                    minNote = "Right path to Trial of Kings",
                    points  = {
                        { 0.329, 0.200 },
                        { 0.372, 0.201 },
                        { 0.404, 0.254 },
                        { 0.402, 0.670 },
                    },
                },
            },
        },
        -- 2. Gekkan (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Gekkan",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 453 },
                    kind    = "path",
                    note    = "After defeating the ^Trial of the King^, open the loot chest to the east on your way down the stairs.",
                    minNote = "East to chest then stairs",
                    points  = {
                        { 0.483, 0.702 },
                        { 0.506, 0.702 },
                        { 0.500, 0.670 },
                        { 0.476, 0.657 },
                    },
                },
                {
                    when    = { mapID = 454 },
                    kind    = "path",
                    note    = "Continue down the stairs, and follow the linear path to the south side of the map. Jump down to engage ^Gekkan^.",
                    minNote = "Follow path, jump down to Gekkan",
                    points  = {
                        { 0.547, 0.183 },
                        { 0.312, 0.185 },
                        { 0.288, 0.214 },
                        { 0.288, 0.384 },
                        { 0.287, 0.717 },
                        { 0.297, 0.747 },
                        { 0.336, 0.757 },
                    },
                },
            },
        },
        -- 3. Xin the Weaponmaster (boss 3). East to the elevator on 454,
        -- the elevator marker, then the upper floor on 455.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Xin the Weaponmaster",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 454 },
                    kind    = "path",
                    note    = "After defeating ^Gekkan^, take the eastern path until you reach an elevator. Take it up.",
                    minNote = "East to elevator",
                    points  = {
                        { 0.476, 0.756 },
                        { 0.618, 0.756 },
                        { 0.654, 0.748 },
                        { 0.697, 0.764 },
                    },
                },
                {
                    when        = { mapID = 454 },
                    kind        = "poi",
                    mapLabel    = "Take Elevator Up",
                    mapLabelPos = "above",
                    minNote     = "Take elevator up",
                    points      = {
                        { 0.715, 0.760 },
                    },
                },
                {
                    when    = { mapID = 455 },
                    kind    = "path",
                    note    = "Once you reach the top of the elevator, follow the long path south until you reach the final boss, ^Xin the Weaponmaster^.",
                    minNote = "South to Xin",
                    points  = {
                        { 0.543, 0.239 },
                        { 0.445, 0.239 },
                        { 0.445, 0.312 },
                        { 0.405, 0.312 },
                        { 0.406, 0.826 },
                    },
                },
            },
        },
    },
}
