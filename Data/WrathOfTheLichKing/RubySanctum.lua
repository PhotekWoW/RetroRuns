-------------------------------------------------------------------------------
-- RetroRuns Data -- The Ruby Sanctum
-- Wrath of the Lich King, Patch 3.3.5  |  instanceID: 724  |  journalInstanceID: 761
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[724] = {
    instanceID        = 724,
    journalInstanceID = 761,
    name              = "The Ruby Sanctum",
    expansion         = "Wrath of the Lich King",
    patch             = "3.3.5",

    exitNote = "None available",

    -- Four size/heroic difficulties (10N/25N/10H/25H), each with its own
    -- loot table and display bucket, all sharing one weekly lockout.
    -- Four size/heroic difficulties (10N/25N/10H/25H), each with its own
    -- loot table and display bucket, all sharing one weekly lockout.
    -- Live-verified: once saved, selecting any other difficulty funnels
    -- the player back into the locked one, so committing to any single
    -- difficulty makes the other three unreachable for the week.
    difficultyModel   = "sizesHeroic",

    entrance = {
        -- Dragonblight, at Wyrmrest Temple -- the portal on the moat's far
        -- side from the Obsidian Sanctum.
        mapID = 115, x = 0.614, y = 0.526,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [200] = "The Ruby Sanctum",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    bosses = {
        {
            index              = 1,
            name               = "Halion",
            journalEncounterID = 1652,
            -- The saved-instance lockout also lists Baltharus the Warborn,
            -- Saviana Ragefire and General Zarithrian as their own rows;
            -- they are separate killable encounters, not names for Halion,
            -- so they carry no aliases here and their rows stay unmapped.
            achievements       = {
                { id = 4818, name = "Heroic: The Twilight Destroyer (10 player)", meta = false, soloable = "yes" },
                { id = 4816, name = "Heroic: The Twilight Destroyer (25 player)", meta = false, soloable = "yes" },
            },
            loot = {
                { id = 53115, slot = "Back", name = "Abduction's Cover", sources = { [3]=26023, [5]=26507 } },
                { id = 53489, slot = "Back", name = "Cloak of Burning Dusk", sources = { [4]=26211, [6]=26521 } },
                { id = 53114, slot = "Chest", name = "Gloaming Sark", sources = { [3]=26022, [5]=26511 } },
                { id = 53125, slot = "Feet", name = "Apocalypse's Advance", sources = { [4]=26028, [6]=26517 } },
                { id = 53119, slot = "Feet", name = "Boots of Divided Being", sources = { [3]=26026, [5]=26508 } },
                { id = 53487, slot = "Feet", name = "Foreshadow Steps", sources = { [4]=26209, [6]=26523 } },
                { id = 53127, slot = "Feet", name = "Returning Footfalls", sources = { [4]=26030, [6]=26516 } },
                { id = 53111, slot = "Feet", name = "Scion's Treads", sources = { [3]=26019, [5]=26513 } },
                { id = 53129, slot = "Feet", name = "Treads of Impending Resurrection", sources = { [4]=26031, [6]=26518 } },
                { id = 53117, slot = "Hands", name = "Changeling Gloves", sources = { [3]=26024, [5]=26510 } },
                { id = 53113, slot = "Shoulder", name = "Twilight Scale Shoulders", sources = { [3]=26021, [5]=26515 } },
                { id = 53118, slot = "Waist", name = "Misbegotten Belt", sources = { [3]=26025, [5]=26512 } },
                { id = 53488, slot = "Waist", name = "Split Shape Belt", sources = { [4]=26210, [6]=26524 } },
                { id = 53121, slot = "Waist", name = "Surrogate Belt", sources = { [3]=26027, [5]=26514 } },
                { id = 53486, slot = "Wrist", name = "Bracers of Fiery Night", sources = { [4]=26208, [6]=26520 } },
                { id = 53112, slot = "Wrist", name = "Bracers of the Heir", sources = { [3]=26020, [5]=26509 } },
                { id = 53134, slot = "Wrist", name = "Phaseshifter's Bracers", sources = { [4]=26032, [6]=26522 } },
                { id = 53126, slot = "Wrist", name = "Umbrage Armbands", sources = { [4]=26029, [6]=26519 } },
            },
        },
    },

    routing = {

        -- 1. Halion. The flame wall to his chamber drops only after the
        -- three lieutenants die; segs chain on each lieutenant's encounter
        -- completing, east -> west -> south, then the approach to the
        -- middle. The lieutenants are their own encounters but are not
        -- journal bosses, so they gate segments rather than steps.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Halion",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 200 },
                    kind            = "poi",
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "1. Kill Baltharus",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    note    = "You must kill all 3 mini-bosses to spawn ^Halion^. Start with ^Baltharus the Warborn^ to the east.",
                    minNote = "Kill East Mini-boss",
                    points  = {
                        { 0.654, 0.537 },
                    },
                },
                {
                    when            = { mapID = 200 },
                    kind            = "poi",
                    triggeredBy     = { encounter = 1147 },  -- Baltharus the Warborn
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "2. Kill Saviana",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    note    = "Next, kill ^Saviana Ragefire^ to the west.",
                    minNote = "Kill West Mini-boss",
                    points  = {
                        { 0.363, 0.536 },
                    },
                },
                {
                    when            = { mapID = 200 },
                    kind            = "poi",
                    triggeredBy     = { encounter = 1149 },  -- Saviana Ragefire
                    noMarker        = true,
                    highlightCircle = true,
                    mapLabel        = "3. Kill Zarithrian",
                    mapLabelPos     = "above",
                    completionCheck = true,
                    note    = "Next, kill ^General Zarithrian^ to the south.",
                    minNote = "Kill South Mini-boss",
                    points  = {
                        { 0.495, 0.801 },
                    },
                },
                {
                    when        = { mapID = 200 },
                    kind        = "path",
                    triggeredBy = { encounter = 1148 },  -- General Zarithrian
                    note    = "With all (3) mini-bosses dead, approach the middle area to engage ^Halion^.",
                    minNote = "Halion in Middle",
                    points  = {
                    },
                },
            },
        },
    },
}
