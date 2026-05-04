-------------------------------------------------------------------------------
-- RetroRuns Data -- Crucible of Storms
-- Battle for Azeroth, Patch 8.1.5  |  instanceID: 2096  |  journalInstanceID: 1177
-------------------------------------------------------------------------------
-- Crucible of Storms is the second raid of Battle for Azeroth's Tides of
-- Vengeance content cycle (8.1.5), located beneath the Shrine of the Storm
-- in Stormsong Valley, Kul Tiras. Two bosses: The Restless Cabal (a paired
-- encounter against Zaxasj the Speaker and Fa'thuul the Feared) and
-- Uu'nat, Harbinger of the Void.
--
-- No class tier sets. Patch 8.1.5 predated the return of proper tier sets
-- (which came with 9.2 / Sepulcher). No skip mechanic either -- the
-- account-wide raid skip system arrived with Shadowlands.
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2096] = {
    instanceID        = 2096,
    journalInstanceID = 1177,
    name              = "Crucible of Storms",
    expansion         = "Battle for Azeroth",
    patch             = "8.1.5",

    maps = {
        [1345] = "Shrine of Shadows",
        [1346] = "Tendril of Corruption",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    -- No skip mechanic on this raid.

    bosses = {
        {
            index              = 1,
            name               = "The Restless Cabal",
            journalEncounterID = 2328,
            aliases            = { "Zaxasj the Speaker", "Fa'thuul the Feared", "Restless Cabal" },
            achievements       = {
                { id = 13501, name = "Gotta Bounce", meta = false },
            },
            loot = {
                { id = 167218, slot = "Feet",     name = "Zaxasj's Deepstriders",          sources = { [17]=103333, [14]=103330, [15]=103331, [16]=103332 } },
                { id = 167841, slot = "Hands",    name = "Abyssal Speaker's Gauntlets",    sources = { [17]=104185, [14]=104182, [15]=104183, [16]=104184 } },
                { id = 167833, slot = "Hands",    name = "Fathom Dredgers",                sources = { [17]=104157, [14]=104154, [15]=104155, [16]=104156 } },
                { id = 167219, slot = "Hands",    name = "Gloves of the Undying Pact",     sources = { [17]=103337, [14]=103334, [15]=103335, [16]=103336 } },
                { id = 167842, slot = "Legs",     name = "Fa'thuul's Floodguards",         sources = { [17]=104187, [14]=104186, [15]=104188, [16]=104189 } },
                { id = 167838, slot = "Legs",     name = "Leggings of the Aberrant Tidesage", sources = { [17]=104171, [14]=104170, [15]=104172, [16]=104173 } },
                { id = 167863, slot = "Two-Hand", name = "Pillar of the Drowned Cabal",    sources = { [17]=104193, [14]=104190, [15]=104191, [16]=104192 } },
                { id = 167837, slot = "Waist",    name = "Insurgent's Scouring Chain",     sources = { [17]=104167, [14]=104166, [15]=104168, [16]=104169 } },
                { id = 167840, slot = "Waist",    name = "Mindthief's Eldritch Clasp",     sources = { [17]=104181, [14]=104178, [15]=104179, [16]=104180 } },
            },
            specialLoot = {
                { id = 267008, kind = "decor", decorID = 18484, name = "Crucible Votive Rack" },
            },
        },
        {
            index              = 2,
            name               = "Uu'nat, Harbinger of the Void",
            journalEncounterID = 2332,
            aliases            = { "Uu'nat" },
            achievements       = {
                { id = 13506, name = "A Good Eye-dea", meta = false },
            },
            loot = {
                { id = 167834, slot = "Feet",     name = "Stormglide Steps",               sources = { [17]=104159, [14]=104158, [15]=104160, [16]=104161 } },
                { id = 167839, slot = "Hands",    name = "Grips of Forsaken Sanity",       sources = { [17]=104175, [14]=104174, [15]=104176, [16]=104177 } },
                { id = 167217, slot = "Legs",     name = "Legplates of Unbound Anguish",   sources = { [17]=103329, [14]=103326, [15]=103327, [16]=103328 } },
                { id = 167835, slot = "Legs",     name = "Malformed Herald's Legwraps",    sources = { [17]=104163, [14]=104162, [15]=104164, [16]=104165 } },
                -- Trident of Deep Ocean is a Relic of Power with a fixed
                -- appearance across all four difficulties.
                { id = 167864, slot = "Two-Hand", name = "Trident of Deep Ocean",          sources = { [17]=104194, [14]=104194, [15]=104194, [16]=104194 } },
            },
        },
    },

    routing = {
        -- DAG: fully linear chain.
        --   1. Restless Cabal     requires {}
        --   2. Uu'nat             requires { 1 }

        -- 1. The Restless Cabal
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "The Restless Cabal",
            requires  = {},
            segments  = {
                {
                    mapID   = 1345,
                    kind    = "path",
                    subZone = "Shrine of Shadows",
                    note    = "After zoning in, follow the path straight ahead to find and kill The Restless Cabal.",
                    points  = {
                        { 0.656, 0.799 },
                        { 0.520, 0.408 },
                    },
                },
            },
        },

        -- 2. Uu'nat, Harbinger of the Void
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Uu'nat, Harbinger of the Void",
            requires  = { 1 },
            segments  = {
                {
                    mapID   = 1346,
                    kind    = "path",
                    subZone = "Tendril of Corruption",
                    note    = "After defeating The Restless Cabal, there will be a cutscene where you will fall into a deep hole, landing in Tendril of Corruption. Follow the path all the way back to reach Uu'nat.",
                    points  = {
                        { 0.822, 0.332 },
                        { 0.776, 0.312 },
                        { 0.725, 0.318 },
                        { 0.683, 0.454 },
                        { 0.579, 0.474 },
                        { 0.550, 0.529 },
                        { 0.291, 0.542 },
                    },
                },
            },
        },
    },
}
