-------------------------------------------------------------------------------
-- RetroRuns Data -- Trial of Valor
-- Legion, Patch 7.1.0  |  instanceID: 1648  |  journalInstanceID: 861
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[1648] = {
    instanceID        = 1648,
    journalInstanceID = 861,
    name              = "Trial of Valor",
    expansion         = "Legion",
    patch             = "7.1.0",

    -- Entrance is in Stormheim (mapID 634), at the Gates of Valor in
    -- the northeast corner of the zone. The player approaches the
    -- arched portal and zones in.
    entrance = {
        mapID   = 634,
        x       = 0.712,
        y       = 0.727,
        subZone = "Gates of Valor",
    },

    maps = {
        [807] = "Trial of Valor",   -- Odyn approach (escalator wing, "The Ephemeral Way" / "Hall of Glory")
        [806] = "Trial of Valor",   -- Guarm approach (post-Odyn-dialog teleport, "Field of Fallen Kings")
        [808] = "Helheim",          -- Guarm fight room and Helya wing ("The Eternal Battlefield")
    },

    -- Empty by design: Trial of Valor was a Legion mini-raid using
    -- the artifact-relic gearing path, not class tier sets. No tier
    -- pieces to harvest, no class-restricted loot rows. The data shape
    -- matches Emerald Nightmare (same relic-only Legion cohort) and
    -- contrasts with Nighthold/Tomb/Antorus.
    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    bosses = {
        {
            index              = 1,
            name               = "Odyn",
            journalEncounterID = 1819,
            aliases            = {},
            achievements       = {
                { id = 11337, name = "You Runed Everything!", soloable = "kinda" },
            },
            loot = {
                { id = 142540, slot = "Back",  name = "Mantle of the Victorious Dead", sources = { [17]=83221, [14]=83220, [15]=83222, [16]=83223 } },
                { id = 142431, slot = "Chest", name = "Gleaming Val'kyr Cuirass",      sources = { [17]=83175, [14]=83172, [15]=83173, [16]=83174 } },
                { id = 142410, slot = "Chest", name = "Robes of Celestial Adornment",  sources = { [17]=83095, [14]=83092, [15]=83093, [16]=83094 } },
                { id = 142422, slot = "Feet",  name = "Radiant Soul Sabatons",         sources = { [17]=83143, [14]=83140, [15]=83141, [16]=83142 } },
                { id = 142430, slot = "Hands", name = "Gloves of Issued Challenge",    sources = { [17]=83171, [14]=83168, [15]=83169, [16]=83170 } },
                { id = 142425, slot = "Legs",  name = "Goldrune Legplates",            sources = { [17]=83155, [14]=83152, [15]=83153, [16]=83154 } },
                { id = 142421, slot = "Legs",  name = "Leggings of the Undaunted",     sources = { [17]=83139, [14]=83136, [15]=83137, [16]=83138 } },
                { id = 142411, slot = "Waist", name = "Cinch of Light",                sources = { [17]=83099, [14]=83096, [15]=83097, [16]=83098 } },
                { id = 142419, slot = "Wrist", name = "Sky-Valiant's Wristguards",     sources = { [17]=83131, [14]=83128, [15]=83129, [16]=83130 } },
            },
        },
        {
            index              = 2,
            name               = "Guarm",
            journalEncounterID = 1830,
            aliases            = {},
            achievements       = {
                { id = 11386, name = "Boneafide Tri Tip", soloable = "yes" },
            },
            loot = {
                { id = 142412, slot = "Back",  name = "Windwhipped Sailcloth",                sources = { [17]=83103, [14]=83100, [15]=83101, [16]=83102 } },
                { id = 142432, slot = "Chest", name = "Helbeast Skin Tunic",                  sources = { [17]=83179, [14]=83176, [15]=83177, [16]=83178 } },
                { id = 142426, slot = "Feet",  name = "Lead-Soled Seabed Striders",           sources = { [17]=83159, [14]=83156, [15]=83157, [16]=83158 } },
                { id = 142417, slot = "Feet",  name = "Moccasins of Silent Passage",          sources = { [17]=83123, [14]=83120, [15]=83121, [16]=83122 } },
                { id = 142434, slot = "Hands", name = "Kvaldir Exult's Grips",                sources = { [17]=83187, [14]=83184, [15]=83185, [16]=83186 } },
                { id = 142435, slot = "Hands", name = "Reinforced Hound-Handler's Gauntlets", sources = { [17]=83191, [14]=83188, [15]=83189, [16]=83190 } },
                { id = 142413, slot = "Legs",  name = "Leggings of the Lower Planes",         sources = { [17]=83107, [14]=83104, [15]=83105, [16]=83106 } },
                { id = 142423, slot = "Wrist", name = "Bite-Resistant Wristclamps",           sources = { [17]=83147, [14]=83144, [15]=83145, [16]=83146 } },
                { id = 142415, slot = "Wrist", name = "Helhound Hair Bracers",                sources = { [17]=83115, [14]=83112, [15]=83113, [16]=83114 } },
            },
        },
        {
            index              = 3,
            name               = "Helya",
            journalEncounterID = 1829,
            aliases            = {},
            achievements       = {
                { id = 11377, name = "Patient Zero", soloable = "yes" },
            },
            loot = {
                { id = 142521, slot = "Back",  name = "Drape of the Unworthy",      sources = { [17]=83207, [14]=83204, [15]=83205, [16]=83206 } },
                { id = 142433, slot = "Chest", name = "Corroded Val'kyr Chainmail", sources = { [17]=83183, [14]=83180, [15]=83181, [16]=83182 } },
                { id = 142414, slot = "Feet",  name = "Treads of the Drowned",      sources = { [17]=83111, [14]=83108, [15]=83109, [16]=83110 } },
                { id = 142429, slot = "Hands", name = "Oiled Rigger's Handwraps",   sources = { [17]=83167, [14]=83164, [15]=83165, [16]=83166 } },
                { id = 142418, slot = "Legs",  name = "Sucker-Scarred Leggings",    sources = { [17]=83127, [14]=83124, [15]=83125, [16]=83126 } },
                { id = 142420, slot = "Waist", name = "Anchor Chain Waistguard",    sources = { [17]=83135, [14]=83132, [15]=83133, [16]=83134 } },
                { id = 142424, slot = "Waist", name = "Krakenbone Waistplate",      sources = { [17]=83151, [14]=83148, [15]=83149, [16]=83150 } },
                { id = 142416, slot = "Waist", name = "Strand of Whelk Shells",     sources = { [17]=83119, [14]=83116, [15]=83117, [16]=83118 } },
                { id = 142427, slot = "Wrist", name = "Calcareous Wristclamps",     sources = { [17]=83163, [14]=83160, [15]=83161, [16]=83162 } },
            },
            soloTip = "Nuke her. During intermission, kill tentacle(s) on the side platform(s).",
        },
    },

    routing = {
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Odyn",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 807 },
                    kind    = "path",
                    note    = "After zoning in, take the escalator all the way up to engage ^Odyn^.",
                    points  = {
                        { 0.514, 0.087 },
                        { 0.515, 0.784 },
                    },
                },
            },
        },

        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Guarm",
            requires  = { 1 },
            segments  = {
                {
                    when    = { mapID = 807 },
                    kind    = "poi",
                    note    = "After defeating ^Odyn^, talk to him and select the only dialog option available. You will be dropped into ^Helheim^.",
                    points  = {
                        { 0.514, 0.892 },
                    },
                },
                {
                    when    = { mapID = 806 },
                    kind    = "path",
                    note    = "After landing down below, take the downhill path and kill trash as you walk through the ^Helheim^ portal at the bottom.",
                    points  = {
                        { 0.539, 0.588 },
                        { 0.695, 0.354 },
                    },
                },
                {
                    when    = { mapID = 808 },
                    kind    = "path",
                    note    = "Once you reach ^Helheim^, follow the path around to find ^Guarm^.",
                    points  = {
                        { 0.638, 0.450 },
                        { 0.592, 0.399 },
                        { 0.596, 0.304 },
                        { 0.529, 0.312 },
                    },
                },
            },
        },

        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Helya",
            requires  = { 2 },
            segments  = {
                {
                    when    = { mapID = 808 },
                    kind    = "path",
                    note    = "After killing ^Guarm^, continue down the path to meet ^Helya^. Kill the trash to start the encounter.",
                    points  = {
                        { 0.481, 0.319 },
                        { 0.385, 0.265 },
                    },
                },
            },
        },
    },
}
