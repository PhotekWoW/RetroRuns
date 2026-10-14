-------------------------------------------------------------------------------
-- RetroRuns Data -- Deadmines
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 36  |  journalInstanceID: 63
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[63] = {
    kind              = "dungeon",
    instanceID        = 36,
    journalInstanceID = 63,
    name              = "Deadmines",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.0.3",
    timewalking       = true,
    routedIn          = "3.3.5",

    entrance = {
        mapID = 55,
        x     = 0.2530,
        y     = 0.5110,
    },

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    trashLoot = {
        { id = 1930, slot = "Back", name = "Stonemason Cloak", sources = { [14]=497 }, bind = "BoE" },
        { id = 10401, slot = "Hands", name = "Blackened Defias Gloves", sources = { [14]=3953 }, bind = "BoE" },
        { id = 1944, slot = "Hands", name = "Metalworking Gloves", sources = { [14]=505 }, bind = "BoE" },
        { id = 1945, slot = "Hands", name = "Woodworking Gloves", sources = { [14]=506 }, bind = "BoE" },
        { id = 7997, slot = "Head", name = "Red Defias Mask", sources = { [14]=3008 }, bind = "BoP" },
        { id = 10400, slot = "Legs", name = "Blackened Defias Leggings", sources = { [14]=3952 }, bind = "BoE" },
        { id = 1943, slot = "Legs", name = "Goblin Mail Leggings", sources = { [14]=504 }, bind = "BoE" },
        { id = 1928, slot = "Two-Hand", name = "Defias Mage Staff", sources = { [14]=495 }, bind = "BoE" },
        { id = 1951, slot = "Weapon", name = "Blackwater Cutlass", sources = { [14]=507 }, bind = "BoE" },
        { id = 1925, slot = "Weapon", name = "Defias Rapier", sources = { [14]=492 }, bind = "BoE" },
        { id = 1936, slot = "Weapon", name = "Goblin Screwdriver", sources = { [14]=501 }, bind = "BoE" },
        { id = 1926, slot = "Weapon", name = "Weighted Sap", sources = { [14]=493 }, bind = "BoE" },
        { id = 8492, kind = "pet", name = "Parrot Cage (Green Wing Macaw)", normalOnly = true },
    },

    bosses = {
        {
            index              = 1,
            name               = "Glubtok",
            journalEncounterID = 89,
            dungeonEncounterID = 2976,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5366, name = "Ready for Raiding", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 5444, slot = "Back", name = "Miner's Cape", sources = { [14]=2104 } },
                { id = 63467, slot = "Back", name = "Shadow of the Past", sources = { [15]=31827 } },
                { id = 63468, slot = "Chest", name = "Defias Brotherhood Vest", sources = { [15]=31828 } },
                { id = 63471, slot = "Chest", name = "Vest of the Curious Visitor", sources = { [15]=31830 } },
                { id = 5195, slot = "Hands", name = "Gold-Flecked Gloves", sources = { [14]=1987, [15]=93814 } },
                { id = 63470, slot = "Shoulder", name = "Missing Diplomat's Pauldrons", sources = { [15]=31829 } },
                { id = 2169, slot = "Weapon", name = "Buzzer Blade", sources = { [14]=642, [15]=32727 } },
            },
        },
        {
            index              = 2,
            name               = "Helix Gearbreaker",
            journalEncounterID = 90,
            dungeonEncounterID = 2977,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5367, name = "Rat Pack", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63473, slot = "Back", name = "Cloak of Thredd", sources = { [15]=31832 } },
                { id = 151063, slot = "Hands", name = "Gear-Marked Gauntlets", sources = { [14]=89249, [15]=31833 } },
                { id = 63475, slot = "Hands", name = "Old Friend's Gloves", sources = { [15]=31834 } },
                { id = 132556, slot = "Legs", name = "Smelter's Britches", sources = { [14]=76391 } },
                { id = 5199, slot = "Legs", name = "Smelting Pants", sources = { [14]=1991 } },
                { id = 5443, slot = "Off-hand", name = "Gold-Plated Buckler", sources = { [14]=2103 } },
                { id = 5200, slot = "Two-Hand", name = "Impaling Harpoon", sources = { [14]=1992 } },
                { id = 5191, slot = "Weapon", name = "Cruel Barb", sources = { [14]=1983, [15]=32728 } },
                { id = 151062, slot = "Wrist", name = "Armbands of Exiled Architects", sources = { [14]=89248, [15]=93933 } },
                { id = 63476, slot = "Wrist", name = "Gearbreaker's Bindings", sources = { [15]=31835 } },
            },
        },
        {
            index              = 3,
            name               = "Foe Reaper 5000",
            journalEncounterID = 91,
            dungeonEncounterID = 2975,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5368, name = "Prototype Prodigy", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 151064, slot = "Chest", name = "Vest of the Curious Visitor", sources = { [14]=89250, [15]=93934 } },
                { id = 151065, slot = "Hands", name = "Old Friend's Gloves", sources = { [14]=89251, [15]=93935 } },
                { id = 151066, slot = "Shoulder", name = "Missing Diplomat's Pauldrons", sources = { [14]=89252, [15]=93936 } },
                { id = 5201, slot = "Two-Hand", name = "Emberstone Staff", sources = { [14]=1993, [15]=32731 } },
                { id = 5187, slot = "Two-Hand", name = "Foe Reaper", sources = { [14]=1982, [15]=32729 } },
                { id = 1937, slot = "Weapon", name = "Buzz Saw", sources = { [14]=502, [15]=32730 } },
            },
        },
        {
            index              = 4,
            name               = "Admiral Ripsnarl",
            journalEncounterID = 92,
            dungeonEncounterID = 2974,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5369, name = "It's Frost Damage", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 872, slot = "Two-Hand", name = "Rockslicer", sources = { [14]=136, [15]=32732 } },
                { id = 5196, slot = "Weapon", name = "Smite's Reaver", sources = { [14]=1988, [15]=32733 } },
            },
        },
        {
            index              = 5,
            name               = "\"Captain\" Cookie",
            journalEncounterID = 93,
            dungeonEncounterID = 2973,
            -- Journal carries 2 rows for this encounter; loot unioned.
            achievements       = {
                { id = 5370, name = "I'm on a Diet", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 5193, slot = "Back", name = "Cape of the Brotherhood", sources = { [14]=1985, [15]=32738 } },
                { id = 5202, slot = "Chest", name = "Corsair's Overshirt", sources = { [14]=1994, [15]=32737 } },
                { id = 5198, slot = "Ranged", name = "Cookie's Stirring Rod", sources = { [14]=1990, [15]=32735 } },
                { id = 5197, slot = "Weapon", name = "Cookie's Tenderizer", sources = { [14]=1989, [15]=32734 } },
                { id = 5192, slot = "Weapon", name = "Thief's Blade", sources = { [14]=1984, [15]=32736 } },
            },
            specialLoot = {
                { id = 248332, kind = "decor", name = "Stormwind Footlocker", decorID = 4401 },
            },
        },
        {
            index              = 6,
            name               = "Vanessa VanCleef",
            journalEncounterID = 95,
            dungeonEncounterID = 1081,
            soloTip            = "Vanessa begins by forcing you through a Nightmare Elixir gauntlet: escape the forge, survive Glubtok's fire/ice, kill Helix, navigate Foe Reaper's electrical hazards, then rescue Ripsnarl's family from worgen. Finish the encounter back where it started.",
            availableDifficulties = { 15 },
            achievements       = {
                { id = 5371, name = "Vigorous VanCleef Vindicator", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63483, slot = "Feet", name = "Guildmaster's Greaves", sources = { [15]=31840 } },
                { id = 65178, slot = "Feet", name = "VanCleef's Boots", sources = { [15]=32739 } },
                { id = 63482, slot = "Hands", name = "Daughter's Hands", sources = { [15]=31839 } },
                { id = 63485, slot = "Head", name = "Cowl of Rebellion", sources = { [15]=31842 } },
                { id = 63478, slot = "Head", name = "Stonemason's Helm", sources = { [15]=31837 } },
                { id = 63484, slot = "Wrist", name = "Armbands of Exiled Architects", sources = { [15]=31841 } },
                { id = 63479, slot = "Wrist", name = "Bracers of Some Consequence", sources = { [15]=31838 } },
                { id = 63486, slot = "Wrist", name = "Shackles of the Betrayed", sources = { [15]=31843 } },
            },
            specialLoot = {
                { id = 248332, kind = "decor", name = "Stormwind Footlocker", decorID = 4401 },
            },
        },
    },

    exitNote    = "Exit the ship to the east and follow the path into a cave to find a portal to the entrance.",
    minExitNote = "Exit portal in cave east of ship",

    routing = {
        -- 1. Glubtok (boss 1).
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Glubtok",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 291 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path ahead until you reach ^Glubtok^.",
                    minNote = "Follow path ahead to Glubtok",
                    points  = {
                        { 0.246, 0.170 },
                        { 0.246, 0.331 },
                        { 0.258, 0.399 },
                        { 0.305, 0.455 },
                        { 0.290, 0.505 },
                        { 0.288, 0.538 },
                        { 0.339, 0.602 },
                    },
                },
            },
        },

        -- 2. Helix Gearbreaker (boss 2).
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Helix Gearbreaker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 291 },
                    kind    = "path",
                    note    = "After killing ^Glubtok^, continue on the linear path until you reach ^Helix Gearbreaker^.",
                    minNote = "Continue on path to Helix",
                    points  = {
                        { 0.396, 0.606 },
                        { 0.436, 0.596 },
                        { 0.476, 0.613 },
                        { 0.483, 0.663 },
                        { 0.451, 0.697 },
                        { 0.435, 0.740 },
                        { 0.440, 0.866 },
                        { 0.475, 0.870 },
                    },
                },
            },
        },

        -- 3. Foe Reaper 5000 (boss 3).
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Foe Reaper 5000",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 291 },
                    kind    = "path",
                    note    = "After defeating ^Helix Gearbreaker^, continue east to the ^Goblin Foundry^ and go down the long spiral ramp. You will find ^Foe Reaper 5000^ when you reach the bottom. Clear trash to start the encounter.",
                    minNote = "Path to Foe Reaper 5000",
                    points  = {
                        { 0.536, 0.872 },
                        { 0.576, 0.874 },
                        { 0.612, 0.892 },
                        { 0.640, 0.917 },
                        { 0.656, 0.904 },
                        { 0.653, 0.871 },
                        { 0.625, 0.835 },
                        { 0.610, 0.801 },
                        { 0.609, 0.715 },
                        { 0.577, 0.700 },
                        { 0.564, 0.653 },
                        { 0.573, 0.606 },
                        { 0.597, 0.577 },
                        { 0.630, 0.582 },
                        { 0.650, 0.603 },
                        { 0.659, 0.639 },
                    },
                },
            },
        },

        -- 4. Admiral Ripsnarl (boss 4).
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Admiral Ripsnarl",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 292 },
                    kind    = "path",
                    note    = "After killing ^Foe Reaper 5000^, continue north to a locked door. Click the nearby cannon to get through the door, then take the path all the way up onto the pirate ship where you will encounter ^Admiral Ripsnarl^.",
                    minNote = "Path to pirate ship for Ripsnarl",
                    points  = {
                        { 0.122, 0.701 },
                        { 0.127, 0.603 },
                        { 0.151, 0.592 },
                        { 0.201, 0.594 },
                        { 0.235, 0.581 },
                        { 0.251, 0.530 },
                        { 0.339, 0.485 },
                        { 0.411, 0.481 },
                        { 0.428, 0.413 },
                        { 0.422, 0.311 },
                        { 0.426, 0.262 },
                        { 0.477, 0.200 },
                        { 0.532, 0.211 },
                        { 0.565, 0.277 },
                        { 0.549, 0.298 },
                        { 0.536, 0.332 },
                        { 0.528, 0.385 },
                        { 0.529, 0.420 },
                        { 0.537, 0.477 },
                        { 0.564, 0.545 },
                        { 0.544, 0.555 },
                        { 0.526, 0.498 },
                        { 0.520, 0.457 },
                        { 0.552, 0.444 },
                        { 0.550, 0.376 },
                        { 0.563, 0.323 },
                        { 0.580, 0.342 },
                    },
                },
            },
        },

        -- 5. "Captain" Cookie (boss 5).
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "\"Captain\" Cookie",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 292 },
                    kind    = "path",
                    note    = "After killing ^Admiral Ripsnarl^, a few moments later, ^\"Captain\" Cookie^ will spawn in the shadows of the nearby cannon house. Walk inside to lure him into combat.",
                    minNote = "Cookie spawns in a moment",
                    points  = { },
                },
            },
        },

        -- 6. Vanessa VanCleef (boss 6, Heroic only).
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Vanessa VanCleef",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 292 },
                    kind    = "path",
                    note    = "After killing ^Cookie^, click ^A Note From Vanessa^ on the ground nearby. After some dialog, the ^Vanessa VanCleef^ encounter will begin.",
                    minNote = "Click Note to start Vanessa",
                    points  = { },
                },
            },
        },
    },
}
