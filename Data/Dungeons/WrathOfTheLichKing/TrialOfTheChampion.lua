-------------------------------------------------------------------------------
-- RetroRuns Data -- Trial of the Champion
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.2.0  |  instanceID: 650  |  journalInstanceID: 284
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[284] = {
    kind              = "dungeon",
    instanceID        = 650,
    journalInstanceID = 284,
    name              = "Trial of the Champion",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.2.0",

    -- Eadric or Paletress, one a run. The one named in chat is the one
    -- that spawned; the other is unavailable. The label heads the panel
    -- until then.
    spawnChoice = { 2, 3, label = "Argent Champion" },

    entrance = {
        mapID = 118,
        x     = 0.7418,
        y     = 0.2068,
    },

    bosses = {
        {
            index              = 1,
            name               = "Grand Champions",
            journalEncounterID = 634,
            dungeonEncounterID = 2022,
            soloTip            = "After the fight begins, you can immediately dismount and kill the bosses the old-fashioned way. After you defeat them on their mounts, they will come back on foot.",
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
            },
            loot = {
                { id = 47176, slot = "Chest", name = "Breastplate of the Imperial Joust", sources = { [14]=22610, [15]=22610 } },
                { id = 47178, slot = "Chest", name = "Carapace of Grim Visions", sources = { [14]=22612, [15]=22612 } },
                { id = 47244, slot = "Chest", name = "Chestguard of the Ravenous Fiend", sources = { [14]=22659, [15]=22659 } },
                { id = 47175, slot = "Feet", name = "Scale Boots of the Outlander", sources = { [14]=22609, [15]=22609 } },
                { id = 47248, slot = "Feet", name = "Treads of Dismal Fortune", sources = { [14]=22661, [15]=22661 } },
                { id = 47177, slot = "Hands", name = "Gloves of the Argent Fanatic", sources = { [14]=22611, [15]=22611 } },
                { id = 47172, slot = "Head", name = "Helm of the Bested Gallant", sources = { [14]=22606, [15]=22606 } },
                { id = 47185, slot = "Legs", name = "Leggings of the Haggard Apprentice", sources = { [14]=22616, [15]=22616 } },
                { id = 47249, slot = "Legs", name = "Leggings of the Snowy Bramble", sources = { [14]=22662, [15]=22662 } },
                { id = 47171, slot = "Legs", name = "Legguards of Abandoned Fealty", sources = { [14]=22605, [15]=22605 } },
                { id = 47250, slot = "Shoulder", name = "Pauldrons of the Deafening Gale", sources = { [14]=22663, [15]=22663 } },
                { id = 47493, slot = "Two-Hand", name = "Edge of Ruin", sources = { [14]=22798, [15]=22798 } },
                { id = 47170, slot = "Waist", name = "Belt of Fierce Competition", sources = { [14]=22604, [15]=22604 } },
                { id = 47181, slot = "Waist", name = "Belt of the Churning Blaze", sources = { [14]=22613, [15]=22613 } },
                { id = 47174, slot = "Waist", name = "Binding of the Tranquil Glade", sources = { [14]=22608, [15]=22608 } },
                { id = 47173, slot = "Wrist", name = "Bindings of the Wicked", sources = { [14]=22607, [15]=22607 } },
            },
        },
        {
            index              = 2,
            name               = "Eadric the Pure",
            journalEncounterID = 635,
            dungeonEncounterID = 2023,
            npcID              = 35119,
            aliases            = { "Argent Champion" },
            achievements       = {
            },
            loot = {
                { id = 47501, slot = "Back", name = "Kurisu's Indecision", sources = { [14]=22804, [15]=22804 } },
                { id = 47176, slot = "Chest", name = "Breastplate of the Imperial Joust", sources = { [14]=22610, [15]=22610 } },
                { id = 47178, slot = "Chest", name = "Carapace of Grim Visions", sources = { [14]=22612, [15]=22612 } },
                { id = 47504, slot = "Feet", name = "Barkhide Treads", sources = { [14]=22807, [15]=22807 } },
                { id = 47201, slot = "Feet", name = "Boots of Heartfelt Repentance", sources = { [14]=22628, [15]=22628 } },
                { id = 47199, slot = "Feet", name = "Greaves of the Grand Paladin", sources = { [14]=22627, [15]=22627 } },
                { id = 47197, slot = "Hands", name = "Gauntlets of the Stouthearted Crusader", sources = { [14]=22626, [15]=22626 } },
                { id = 47498, slot = "Hands", name = "Gloves of Dismal Fortune", sources = { [14]=22802, [15]=22802 } },
                { id = 47177, slot = "Hands", name = "Gloves of the Argent Fanatic", sources = { [14]=22611, [15]=22611 } },
                { id = 47497, slot = "Head", name = "Helm of the Crestfallen Challenger", sources = { [14]=22801, [15]=22801 } },
                { id = 47202, slot = "Legs", name = "Leggings of Brazen Trespass", sources = { [14]=22629, [15]=22629 } },
                { id = 47185, slot = "Legs", name = "Leggings of the Haggard Apprentice", sources = { [14]=22616, [15]=22616 } },
                { id = 47495, slot = "Legs", name = "Legplates of Relentless Onslaught", sources = { [14]=22799, [15]=22799 } },
                { id = 47503, slot = "Legs", name = "Legplates of the Argent Armistice", sources = { [14]=22806, [15]=22806 } },
                { id = 47502, slot = "Shoulder", name = "Majestic Silversmith Shoulderplates", sources = { [14]=22805, [15]=22805 } },
                { id = 47210, slot = "Shoulder", name = "Mantle of Gnarled Overgrowth", sources = { [14]=22637, [15]=22637 } },
                { id = 47181, slot = "Waist", name = "Belt of the Churning Blaze", sources = { [14]=22613, [15]=22613 } },
                { id = 47508, slot = "Weapon", name = "Aledar's Battlestar", sources = { [14]=22810, [15]=22810 } },
                { id = 47509, slot = "Weapon", name = "Mariel's Sorrow", sources = { [14]=22811, [15]=22811 } },
                { id = 47500, slot = "Weapon", name = "Peacekeeper Blade", sources = { [14]=22803, [15]=22803 } },
                { id = 47496, slot = "Wrist", name = "Armbands of the Wary Lookout", sources = { [14]=22800, [15]=22800 } },
            },
        },
        {
            index              = 3,
            name               = "Argent Confessor Paletress",
            journalEncounterID = 636,
            dungeonEncounterID = 2023,
            npcID              = 34928,
            aliases            = { "Argent Champion" },
            achievements       = {
            },
            loot = {
                { id = 47176, slot = "Chest", name = "Breastplate of the Imperial Joust", sources = { [14]=22610, [15]=22610 } },
                { id = 47178, slot = "Chest", name = "Carapace of Grim Visions", sources = { [14]=22612, [15]=22612 } },
                { id = 47511, slot = "Feet", name = "Plated Greaves of Providence", sources = { [14]=22813, [15]=22813 } },
                { id = 47498, slot = "Hands", name = "Gloves of Dismal Fortune", sources = { [14]=22802, [15]=22802 } },
                { id = 47177, slot = "Hands", name = "Gloves of the Argent Fanatic", sources = { [14]=22611, [15]=22611 } },
                { id = 47212, slot = "Hands", name = "Mercy's Hold", sources = { [14]=22639, [15]=22639 } },
                { id = 47217, slot = "Head", name = "Gaze of the Somber Keeper", sources = { [14]=22640, [15]=22640 } },
                { id = 47497, slot = "Head", name = "Helm of the Crestfallen Challenger", sources = { [14]=22801, [15]=22801 } },
                { id = 47185, slot = "Legs", name = "Leggings of the Haggard Apprentice", sources = { [14]=22616, [15]=22616 } },
                { id = 47495, slot = "Legs", name = "Legplates of Relentless Onslaught", sources = { [14]=22799, [15]=22799 } },
                { id = 47245, slot = "Shoulder", name = "Pauldrons of Concealed Loathing", sources = { [14]=22660, [15]=22660 } },
                { id = 47514, slot = "Shoulder", name = "Regal Aurous Shoulderplates", sources = { [14]=22815, [15]=22815 } },
                { id = 47522, slot = "Two-Hand", name = "Marrowstrike", sources = { [14]=22823, [15]=22823 } },
                { id = 47181, slot = "Waist", name = "Belt of the Churning Blaze", sources = { [14]=22613, [15]=22613 } },
                { id = 47218, slot = "Waist", name = "The Confessor's Binding", sources = { [14]=22641, [15]=22641 } },
                { id = 47510, slot = "Waist", name = "Trueheart Girdle", sources = { [14]=22812, [15]=22812 } },
                { id = 47500, slot = "Weapon", name = "Peacekeeper Blade", sources = { [14]=22803, [15]=22803 } },
                { id = 47496, slot = "Wrist", name = "Armbands of the Wary Lookout", sources = { [14]=22800, [15]=22800 } },
                { id = 47211, slot = "Wrist", name = "Wristguards of Ceaseless Regret", sources = { [14]=22638, [15]=22638 } },
            },
        },
        {
            index              = 4,
            name               = "The Black Knight",
            journalEncounterID = 637,
            dungeonEncounterID = 2021,
            achievements       = {
            },
            loot = {
                { id = 47232, slot = "Back", name = "Drape of the Undefeated", sources = { [14]=22651, [15]=22651 } },
                { id = 47527, slot = "Chest", name = "Embrace of Madness", sources = { [14]=22828, [15]=22828 } },
                { id = 47560, slot = "Feet", name = "Boots of the Crackling Flame", sources = { [14]=22844, [15]=22844 } },
                { id = 47567, slot = "Hands", name = "Gauntlets of Revelation", sources = { [14]=22849, [15]=22849 } },
                { id = 47561, slot = "Hands", name = "Gloves of the Dark Exile", sources = { [14]=22845, [15]=22845 } },
                { id = 47230, slot = "Hands", name = "Handwraps of Surrendered Hope", sources = { [14]=22649, [15]=22649 } },
                { id = 47564, slot = "Head", name = "Gaze of the Unknown", sources = { [14]=22847, [15]=22847 } },
                { id = 47220, slot = "Head", name = "Helm of the Violent Fray", sources = { [14]=22642, [15]=22642 } },
                { id = 47529, slot = "Head", name = "Mask of Distant Memory", sources = { [14]=22830, [15]=22830 } },
                { id = 47228, slot = "Legs", name = "Leggings of the Bloodless Knight", sources = { [14]=22647, [15]=22647 } },
                { id = 47568, slot = "Ranged", name = "True-Aim Long Rifle", sources = { [14]=22850, [15]=22850 } },
                { id = 47226, slot = "Shoulder", name = "Mantle of Inconsolable Fear", sources = { [14]=22645, [15]=22645 } },
                { id = 47221, slot = "Shoulder", name = "Shoulderpads of the Infamous Knave", sources = { [14]=22643, [15]=22643 } },
                { id = 47231, slot = "Waist", name = "Belt of Merciless Cruelty", sources = { [14]=22650, [15]=22650 } },
                { id = 47229, slot = "Waist", name = "Girdle of Arrogant Downfall", sources = { [14]=22648, [15]=22648 } },
                { id = 47563, slot = "Waist", name = "Girdle of the Dauntless Conqueror", sources = { [14]=22846, [15]=22846 } },
                { id = 47227, slot = "Waist", name = "Girdle of the Pallid Knight", sources = { [14]=22646, [15]=22646 } },
                { id = 49682, slot = "Weapon", name = "Black Knight's Rondel", sources = { [14]=24316, [15]=24316 } },
                { id = 47569, slot = "Weapon", name = "Spectral Kris", sources = { [14]=22851, [15]=22851 } },
                { id = 47565, slot = "Wrist", name = "Vambraces of Unholy Command", sources = { [14]=22848, [15]=22848 } },
            },
        },
    },

    exitNote    = "Exit to the north",
    minExitNote = "Exit to the north",

    routing = {
        -- 1. Grand Champions (boss 1). Lance and mount, then the herald.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Grand Champions",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 171 },
                    kind        = "poi",
                    note        = "After zoning in, pick up and equip an ^Argent Lance^ from a nearby ^Lance Rack^. Then choose a nearby mount.",
                    minNote     = "Equip lance and choose mount",
                    mapLabel    = "Get Lance and Mount",
                    mapLabelPos = "above",
                    points      = {
                        { 0.400, 0.371 },
                    },
                },
                {
                    when        = { mapID = 171 },
                    kind        = "path",
                    triggeredBy = { vehicle = true },
                    note        = "Once mounted, talk to ^Arelas Brightstar^ in the middle of the arena to start the encounter with the ^Grand Champions^.",
                    minNote     = "Talk to Arelas Brightstar to begin",
                },
            },
        },
        -- 2/3. Eadric or Paletress, whichever spawns; the other step
        -- drops once chat names the champion.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Eadric the Pure",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 171 },
                    kind    = "path",
                    note    = "Re-equip your regular weapon, and talk to ^Arelas Brightstar^ to begin the next fight.",
                    minNote = "Talk to Arelas for next fight",
                },
            },
        },
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Argent Confessor Paletress",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 171 },
                    kind    = "path",
                    note    = "Re-equip your regular weapon, and talk to ^Arelas Brightstar^ to begin the next fight.",
                    minNote = "Talk to Arelas for next fight",
                },
            },
        },
        -- 4. The Black Knight (boss 4).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "The Black Knight",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 171 },
                    kind    = "path",
                    note    = "After defeating {spawned}, talk to ^Arelas Brightstar^ to start the final encounter against ^The Black Knight^.",
                    minNote = "Talk to Arelas for Black Knight",
                },
            },
        },
    },
}
