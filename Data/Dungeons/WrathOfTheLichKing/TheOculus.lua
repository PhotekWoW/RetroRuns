-------------------------------------------------------------------------------
-- RetroRuns Data -- The Oculus
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 578  |  journalInstanceID: 282
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[282] = {
    kind              = "dungeon",
    instanceID        = 578,
    journalInstanceID = 282,
    name              = "The Oculus",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    routedIn          = "3.3.0",

    entrance = {
        mapID = 114,
        x     = 0.2752,
        y     = 0.2675,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 36976, slot = "Legs", name = "Ring-Lord's Leggings", sources = { [14]=17508 }, bind = "BoE" },
        { id = 37364, slot = "Off-hand", name = "Frostbridge Orb", sources = { [15]=17753 }, bind = "BoE" },
        { id = 36978, slot = "Waist", name = "Ley-Whelphide Belt", sources = { [14]=17510 }, bind = "BoE" },
        { id = 37365, slot = "Wrist", name = "Bands of the Sky Ring", sources = { [15]=17754 }, bind = "BoE" },
        { id = 36977, slot = "Wrist", name = "Bindings of the Construct", sources = { [14]=17509 }, bind = "BoE" },
        { id = 37366, slot = "Wrist", name = "Drake-Champion's Bracers", sources = { [15]=17755 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Drakos the Interrogator",
            journalEncounterID = 622,
            dungeonEncounterID = 528,
            -- The Heroic lockout keeps a retired row per boss whose bit
            -- belongs to a different boss now, so every kill flags the
            -- wrong twin. All four bosses ignore the lockout.
            lockoutUnreliable  = true,
            achievements       = {
                { id = 1868, name = "Make It Count", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37258, slot = "Chest", name = "Drakewing Raiments", sources = { [14]=17697, [15]=17697 } },
                { id = 36946, slot = "Chest", name = "Runic Cage Chestpiece", sources = { [14]=17493, [15]=17493 } },
                { id = 37256, slot = "Chest", name = "Scaled Armor of Drakos", sources = { [14]=17696, [15]=17696 } },
                { id = 157562, slot = "Two-Hand", name = "Rod of Aggressive Questioning", sources = { [14]=93757, [15]=93757 } },
                { id = 36944, slot = "Weapon", name = "Lifeblade of Belgaristrasz", sources = { [14]=17491, [15]=17491 } },
                { id = 37255, slot = "Weapon", name = "The Interrogator", sources = { [14]=17695, [15]=17695 } },
                { id = 36945, slot = "Wrist", name = "Verdisa's Cuffs of Dreaming", sources = { [14]=17492, [15]=17492 } },
            },
        },
        {
            index              = 2,
            name               = "Varos Cloudstrider",
            journalEncounterID = 623,
            dungeonEncounterID = 530,
            lockoutUnreliable  = true,
            achievements       = {
            },
            loot = {
                { id = 36947, slot = "Back", name = "Centrifuge Core Cloak", sources = { [14]=17494, [15]=17494 } },
                { id = 36950, slot = "Chest", name = "Wing Commander's Breastplate", sources = { [14]=17497, [15]=17497 } },
                { id = 37261, slot = "Hands", name = "Gloves of Radiant Light", sources = { [14]=17699, [15]=17699 } },
                { id = 36949, slot = "Hands", name = "Gloves of the Azure-Lord", sources = { [14]=17496, [15]=17496 } },
                { id = 36948, slot = "Head", name = "Horned Helm of Varos", sources = { [14]=17495, [15]=17495 } },
                { id = 37262, slot = "Legs", name = "Azure Ringmail Leggings", sources = { [14]=17700, [15]=17700 } },
                { id = 37263, slot = "Legs", name = "Legplates of the Oculus Guardian", sources = { [14]=17701, [15]=17701 } },
                { id = 37260, slot = "Weapon", name = "Cloudstrider's Waraxe", sources = { [14]=17698, [15]=17698 } },
            },
        },
        {
            index              = 3,
            name               = "Mage-Lord Urom",
            journalEncounterID = 624,
            dungeonEncounterID = 533,
            lockoutUnreliable  = true,
            soloTip            = "As you fight this boss, he will teleport to neighboring platforms in a clockwise fashion. After that, he will teleport to the main ring where you can finish him. Use your {item} to pursue him between locations.",
            achievements       = {
            },
            loot = {
                { id = 36954, slot = "Feet", name = "The Conjurer's Slippers", sources = { [14]=17501, [15]=17501 } },
                { id = 36951, slot = "Hands", name = "Sidestepping Handguards", sources = { [14]=17498, [15]=17498 } },
                { id = 36953, slot = "Shoulder", name = "Spaulders of Skillful Maneuvers", sources = { [14]=17500, [15]=17500 } },
                { id = 36952, slot = "Waist", name = "Girdle of Obscuring", sources = { [14]=17499, [15]=17499 } },
                { id = 37289, slot = "Waist", name = "Sash of Phantasmal Images", sources = { [14]=17721, [15]=17721 } },
                { id = 37288, slot = "Wrist", name = "Catalytic Bands", sources = { [14]=17720, [15]=17720 } },
            },
        },
        {
            index              = 4,
            name               = "Ley-Guardian Eregos",
            journalEncounterID = 625,
            dungeonEncounterID = 534,
            lockoutUnreliable  = true,
            achievements       = {
                { id = 1871, name = "Experienced Drake Rider", meta = true, soloable = "yes" },
                { id = 2044, name = "Ruby Void", meta = true, soloable = "yes" },
                { id = 2045, name = "Emerald Void", meta = true, soloable = "yes" },
                { id = 2046, name = "Amber Void", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37291, slot = "Back", name = "Ancient Dragon Spirit Cape", sources = { [14]=17722, [15]=17722 } },
                { id = 36974, slot = "Chest", name = "Eregos' Ornamented Chestguard", sources = { [14]=17506, [15]=17506 } },
                { id = 36973, slot = "Chest", name = "Vestments of the Scholar", sources = { [14]=17505, [15]=17505 } },
                { id = 37363, slot = "Hands", name = "Gauntlets of Dragon Wrath", sources = { [14]=17752, [15]=17752 } },
                { id = 37294, slot = "Head", name = "Crown of Unbridled Magic", sources = { [14]=17725, [15]=17725 } },
                { id = 36971, slot = "Head", name = "Headguard of Westrift", sources = { [14]=17504, [15]=17504 } },
                { id = 36969, slot = "Head", name = "Helm of the Ley-Guardian", sources = { [14]=17503, [15]=17503 } },
                { id = 37293, slot = "Head", name = "Mask of the Watcher", sources = { [14]=17724, [15]=17724 } },
                { id = 37362, slot = "Legs", name = "Leggings of Protective Auras", sources = { [14]=17751, [15]=17751 } },
                { id = 37292, slot = "Legs", name = "Ley-Guardian's Legguards", sources = { [14]=17723, [15]=17723 } },
                { id = 36975, slot = "Two-Hand", name = "Malygos' Favor", sources = { [14]=17507, [15]=17507 } },
                { id = 37360, slot = "Two-Hand", name = "Staff of Draconic Combat", sources = { [14]=17749, [15]=17749 } },
                { id = 36962, slot = "Two-Hand", name = "Wyrmclaw Battleaxe", sources = { [14]=17502, [15]=17502 } },
                { id = 37361, slot = "Wrist", name = "Cuffs of Winged Levitation", sources = { [14]=17750, [15]=17750 } },
            },
        },
    },

    exitNote    = "Jump off the ledge for a quick shortcut to the entrance portal",
    minExitNote = "Jump off the ledge to respawn at entrance",

    routing = {
        -- 1. Drakos the Interrogator (boss 1). Around the outer ring to the
        -- Nexus Portal, which teleports onto his platform.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Drakos the Interrogator",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 143 },
                    kind    = "path",
                    note    = "After zoning in, work your way around to the end of the path and click the ^Nexus Portal^ to be teleported to ^Drakos the Interrogator^.",
                    minNote = "Click Portal then kill Drakos",
                    points  = {
                        { 0.624, 0.455 },
                        { 0.640, 0.339 },
                        { 0.645, 0.262 },
                        { 0.610, 0.171 },
                        { 0.575, 0.122 },
                        { 0.401, 0.127 },
                        { 0.357, 0.182 },
                        { 0.340, 0.235 },
                        { 0.330, 0.326 },
                        { 0.336, 0.398 },
                    },
                },
                {
                    when          = { mapID = 143 },
                    kind          = "poi",
                    note          = "After zoning in, work your way around to the end of the path and click the ^Nexus Portal^ to be teleported to ^Drakos the Interrogator^.",
                    minNote       = "Click Portal then kill Drakos",
                    mapLabel      = "Click Nexus Portal",
                    mapLabelPos   = "below",
                    mapLabelPulse = true,
                    points        = {
                        { 0.388, 0.512 },
                    },
                },
            },
        },
        -- 2. Varos Cloudstrider (boss 2). Pick a drake, then clear ten
        -- constructs before the platform opens.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Varos Cloudstrider",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 143 },
                    kind    = "path",
                    note    = "After killing ^Drakos the Interrogator^, three NPCs will emerge from their cages. Talk to whichever you choose, and collect their essence.",
                    minNote = "Pick a dragon",
                    points  = { },
                },
                {
                    when        = { mapID = 143 },
                    kind        = "path",
                    note        = "From this point forward, you will use your {item} to navigate the instance. Your current task is to kill ten ^Centrifuge Constructs^. You can find them on the middle ring as well as the outer platforms.",
                    minNote     = "Use dragon, kill 10 constructs",
                    triggeredBy = { item = { 37860, 37815, 37859 } },
                    points      = { },
                },
                -- The constructs, one mark each, on both maps the client
                -- shows while flying the rings.
                {
                    when          = { mapID = 144 },
                    kind          = "poi",
                    note          = "From this point forward, you will use your {item} to navigate the instance. Your current task is to kill ten ^Centrifuge Constructs^. You can find them on the middle ring as well as the outer platforms.",
                    minNote       = "Use dragon, kill 10 constructs",
                    markAllPoints = true,
                    poiIcon       = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\QuestMarker",
                    poiSize       = 18,
                    markHint      = "%d/%d Constructs Remaining",
                    markHintWidget = 544,
                    markHintTotal = 10,
                    points        = {
                        { 0.729, 0.780 },
                        { 0.749, 0.739 },
                        { 0.717, 0.733 },
                        { 0.279, 0.782 },
                        { 0.261, 0.824 },
                        { 0.250, 0.777 },
                        { 0.417, 0.688 },
                        { 0.397, 0.564 },
                        { 0.589, 0.564 },
                        { 0.570, 0.688 },
                    },
                },
                {
                    when          = { mapID = 142 },
                    kind          = "poi",
                    note          = "From this point forward, you will use your {item} to navigate the instance. Your current task is to kill ten ^Centrifuge Constructs^. You can find them on the middle ring as well as the outer platforms.",
                    minNote       = "Use dragon, kill 10 constructs",
                    markAllPoints = true,
                    poiIcon       = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\QuestMarker",
                    poiSize       = 18,
                    markHint      = "%d/%d Constructs Remaining",
                    markHintWidget = 544,
                    markHintTotal = 10,
                    points        = {
                        { 0.469, 0.517 },
                        { 0.469, 0.477 },
                        { 0.521, 0.477 },
                        { 0.521, 0.517 },
                        { 0.437, 0.525 },
                        { 0.429, 0.543 },
                        { 0.445, 0.543 },
                        { 0.553, 0.525 },
                        { 0.545, 0.543 },
                        { 0.561, 0.543 },
                    },
                },
                -- The tenth kill lands the counter; the ring picks out
                -- the journal's own pin for Varos.
                {
                    when            = { mapID = 144 },
                    kind            = "poi",
                    note            = "With all of the ^Centrifuge Constructs^ dead, fly to the northern platform to kill ^Varos Cloudstrider^.",
                    minNote         = "Kill Varos on north platform",
                    noMarker        = true,
                    highlightCircle = true,
                    drawWhenOpen    = true,
                    triggeredBy     = { widget = 544, value = 0 },
                    points          = {
                        { 0.462, 0.193 },
                    },
                },
            },
        },

        -- 3. Mage-Lord Urom (boss 3). Back on the drake, up and southeast.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Mage-Lord Urom",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 144 },
                    kind    = "path",
                    note    = "After killing ^Varos Cloudstrider^, use your {item} to call your dragon. Fly up and to the southeast to find ^Mage-Lord Urom^ channeling on the outer platform.",
                    minNote = "Fly up and southeast to Urom",
                    noItemNote    = "You are not carrying a drake essence. Return to the three dragons on ^Drakos the Interrogator^'s platform and collect a new one.",
                    noItemMinNote = "Collect a new essence",
                    triggeredBy = { item = { 37860, 37815, 37859 } },
                    points  = {
                        { 0.501, 0.244 },
                        { 0.600, 0.325 },
                    },
                },
                {
                    when        = { mapID = 142 },
                    kind        = "poi",
                    note        = "After killing ^Varos Cloudstrider^, use your {item} to call your dragon. Fly up and to the southeast to find ^Mage-Lord Urom^ channeling on the outer platform.",
                    minNote     = "Fly up and southeast to Urom",
                    mapLabel    = "Mage-Lord Urom",
                    mapLabelPos = "above",
                    points      = {
                        { 0.539, 0.447 },
                    },
                },
            },
        },
        -- 4. Ley-Guardian Eregos (boss 4). Straight up from Urom's platform.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Ley-Guardian Eregos",
            requires  = { },
            segments  = {
                {
                    when          = { mapID = 142 },
                    kind          = "path",
                    note          = "After you kill ^Mage-Lord Urom^, call your dragon with {item}. Fly all the way to the top of the instance to find ^Ley-Guardian Eregos^ flying around. Use your dragon's main attack ability on the boss several times to kill him.",
                    minNote       = "Fly up to Eregos",
                    noItemNote    = "You are not carrying a drake essence. Return to the three dragons on ^Drakos the Interrogator^'s platform and collect a new one.",
                    noItemMinNote = "Collect a new essence",
                    triggeredBy   = { item = { 37860, 37815, 37859 } },
                    points        = { },
                },
            },
        },
    },
}
