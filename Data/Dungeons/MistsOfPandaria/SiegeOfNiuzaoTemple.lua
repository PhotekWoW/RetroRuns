-------------------------------------------------------------------------------
-- RetroRuns Data -- Siege of Niuzao Temple
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 1011  |  journalInstanceID: 324
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[324] = {
    kind              = "dungeon",
    instanceID        = 1011,
    journalInstanceID = 324,
    name              = "Siege of Niuzao Temple",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",

    entrance = {
        mapID = 388,
        x     = 0.3470,
        y     = 0.8150,
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
            name               = "Vizier Jin'bak",
            journalEncounterID = 693,
            achievements       = {
                { id = 6715, name = "Polyformic Acid Science", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 144022, slot = "Head", name = "Hood of Viridian Residue", sources = { [14]=84357, [15]=84357 } },
                { id = 143996, slot = "Legs", name = "Sap-Encrusted Legplates", sources = { [14]=84331, [15]=84331 } },
                { id = 144163, slot = "Waist", name = "Girdle of Soothing Detonation", sources = { [14]=84440, [15]=84440 } },
            },
        },
        {
            index              = 2,
            name               = "Commander Vo'jak",
            journalEncounterID = 738,
            soloTip            = "Kill 5-6 waves until the boss finally comes. You can bang the ^Challenge Gong^ after each wave to speed up the process.",
            achievements       = {
                { id = 6688, name = "Where's My Air Support?", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 143963, slot = "Chest", name = "Chestwrap of Arcing Flame", sources = { [14]=84298, [15]=84298 } },
                { id = 144166, slot = "Hands", name = "Archer's Precision Grips", sources = { [14]=84443, [15]=84443 } },
                { id = 144023, slot = "Head", name = "Sightfinder Helm", sources = { [14]=84358, [15]=84358 } },
                { id = 144164, slot = "Weapon", name = "Siege-Captain's Scimitar", sources = { [14]=84441, [15]=84441 } },
                { id = 144165, slot = "Wrist", name = "Bombardment Bracers", sources = { [14]=84442, [15]=84442 } },
            },
        },
        {
            index              = 3,
            name               = "General Pa'valak",
            journalEncounterID = 692,
            achievements       = {
                { id = 6485, name = "Return to Sender", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 144170, slot = "Back", name = "Aerial Bombardment Cloak", sources = { [14]=84447, [15]=84447 } },
                { id = 144169, slot = "Hands", name = "Breezebinder Handwraps", sources = { [14]=84446, [15]=84446 } },
                { id = 144167, slot = "Ranged", name = "Tempestuous Longbow", sources = { [14]=84444, [15]=84444 } },
                { id = 144168, slot = "Wrist", name = "Siegeworn Bracers", sources = { [14]=84445, [15]=84445 } },
            },
        },
        {
            index              = 4,
            name               = "Wing Leader Ner'onok",
            journalEncounterID = 727,
            achievements       = {
                { id = 6822, name = "Run with the Wind", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 143964, slot = "Chest", name = "Galedodger Chestguard", sources = { [14]=84299, [15]=84299 } },
                { id = 144000, slot = "Feet", name = "Airbender Sandals", sources = { [14]=84335, [15]=84335 } },
                { id = 143997, slot = "Feet", name = "Anchoring Sabatons", sources = { [14]=84332, [15]=84332 } },
                { id = 144025, slot = "Head", name = "Breezeswept Hood", sources = { [14]=84360, [15]=84360 } },
                { id = 144024, slot = "Head", name = "Windblast Helm", sources = { [14]=84359, [15]=84359 } },
                { id = 143998, slot = "Shoulder", name = "Spaulders of Immovable Stone", sources = { [14]=84333, [15]=84333 } },
                { id = 143999, slot = "Shoulder", name = "Whisperwind Spaulders", sources = { [14]=84334, [15]=84334 } },
                { id = 144172, slot = "Two-Hand", name = "Gustwalker Staff", sources = { [14]=84449, [15]=84449 } },
                { id = 144173, slot = "Waist", name = "Belt of Totemic Binding", sources = { [14]=84450, [15]=84450 } },
                { id = 144171, slot = "Weapon", name = "Ner'onok's Razor Katar", sources = { [14]=84448, [15]=84448 } },
                { id = 144219, slot = "Weapon", name = "Tolakesh, Horn of the Black Ox", sources = { [14]=84487, [15]=84487 } },
            },
        },
    },

    exitNote    = "Jump off the ledge behind the final boss to respawn at the ^Challenge Gong^. Run back into the tree, then jump to the lower floor and run out.",
    minExitNote = "Ledge jump behind final boss",

    routing = {
        -- 1. Vizier Jin'bak (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Vizier Jin'bak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 458 },
                    kind    = "path",
                    note    = "After zoning in, kill all three trash packs on the way down the path to ^Vizier Jin'bak^.",
                    minNote = "Clear trash to Jin'bak",
                    points  = {
                        { 0.638, 0.792 },
                        { 0.669, 0.576 },
                        { 0.649, 0.434 },
                        { 0.575, 0.281 },
                        { 0.503, 0.277 },
                        { 0.478, 0.468 },
                    },
                },
            },
        },
        -- 2. Commander Vo'jak (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Commander Vo'jak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 458 },
                    kind    = "path",
                    note    = "After killing ^Vizier Jin'bak^, continue clockwise up the tree path until you reach an exit on your right. Melee attack the ^Hardened Resin^ to break open the path.",
                    minNote = "Continue up path to exit right",
                    points  = {
                        { 0.428, 0.558 },
                        { 0.305, 0.642 },
                        { 0.350, 0.738 },
                        { 0.460, 0.822 },
                        { 0.559, 0.818 },
                    },
                },
                {
                    when    = { mapID = 459 },
                    kind    = "path",
                    note    = "After killing ^Vizier Jin'bak^, continue clockwise up the tree path until you reach an exit on your right. Melee attack the ^Hardened Resin^ to break open the path.",
                    minNote = "Continue up path to exit right",
                    points  = {
                        { 0.613, 0.746 },
                        { 0.673, 0.625 },
                        { 0.672, 0.479 },
                        { 0.610, 0.316 },
                        { 0.517, 0.238 },
                        { 0.371, 0.255 },
                        { 0.296, 0.407 },
                        { 0.258, 0.530 },
                        { 0.179, 0.522 },
                    },
                },
                {
                    when    = { mapID = 457 },
                    kind    = "path",
                    note    = "After killing ^Vizier Jin'bak^, continue clockwise up the tree path until you reach an exit on your right. Melee attack the ^Hardened Resin^ to break open the path.",
                    minNote = "Continue up path to exit right",
                    points  = { },
                },
                {
                    when     = { mapID = 457, subZone = "Rear Staging Area" },
                    kind     = "poi",
                    noMarker = true,
                    note     = "Kill the ^Sik'Thik Warden^ to trigger some dialog, and then talk to ^Yang Ironclaw^ to begin the encounter with ^Commander Vo'jak^.",
                    minNote  = "Talk to Yang for Commander Vo'jak",
                    points   = {
                        { 0.450, 0.745 },
                    },
                },
            },
        },
        -- 3. General Pa'valak (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "General Pa'valak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 457 },
                    kind    = "path",
                    note    = "After defeating ^Commander Vo'jak^, go down the stairs and wait for the NPCs to open the door. Continue north and you'll find ^General Pa'valak^ on the eastern side of the road.",
                    minNote = "Follow path to Pa'valak",
                    points  = {
                        { 0.453, 0.759 },
                        { 0.390, 0.766 },
                        { 0.355, 0.688 },
                        { 0.356, 0.600 },
                        { 0.371, 0.534 },
                        { 0.377, 0.431 },
                        { 0.431, 0.417 },
                        { 0.483, 0.398 },
                        { 0.531, 0.449 },
                    },
                },
            },
        },
        -- 4. Wing Leader Ner'onok (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Wing Leader Ner'onok",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 457 },
                    kind    = "path",
                    note    = "After killing ^General Pa'valak^, go northeast up the stairs and down the path to ^Wing Leader Ner'onok^.",
                    minNote = "Northeast to Ner'onok",
                    points  = {
                        { 0.497, 0.403 },
                        { 0.494, 0.340 },
                        { 0.551, 0.251 },
                    },
                },
            },
        },
    },
}
