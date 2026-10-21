-------------------------------------------------------------------------------
-- RetroRuns Data -- Scarlet Monastery
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 1004  |  journalInstanceID: 316
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[316] = {
    kind              = "dungeon",
    instanceID        = 1004,
    journalInstanceID = 316,
    name              = "Scarlet Monastery",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",

    entrance = {
        mapID = 19,
        x     = 0.6880,
        y     = 0.2350,
    },

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    -- Appearances that drop only in the pre-Mists wings of this
    -- monastery, reachable again through the Old Keyring. They are
    -- listed here because this is the instance a player browses;
    -- the note under the block says how to get in.
    legacyLabel = "Scarlet Monastery of Old",
    legacyNote  = {
        text   = "SM of Old is accessed with {item}, which can either be found in {item2} or purchased from the Auction House. Once you have the key, turn it in at ^Old Keyring^ to obtain a buff that activates the (4) legacy SM instances. Disable the buff by interacting with the keyring again.",
        emphasis = "SM of Old",
        itemID  = 208485,
        itemID2 = 209024,
        travel = {
            mapID = 19,
            x     = 0.4830,
            y     = 0.5630,
            vendorName = "Old Keyring",
            zoneSub = "The Grand Vestibule",
        },
    },
    legacyLoot = {
        { id = 7688, slot = "Chest", name = "Ironspine's Ribcage", sources = { [14]=2914 }, bind = "BoP", rareNpc = "Ironspine", legacyWing = "Graveyard" },
        { id = 19509, slot = "Feet", name = "Dusty Mail Boots", sources = { [14]=7722 }, bossNpc = "High Inquisitor Fairbanks", legacyWing = "Cathedral" },
        { id = 7690, slot = "Hands", name = "Ebon Vise", sources = { [14]=2916 }, bind = "BoP", rareNpc = "Fallen Champion", legacyWing = "Graveyard" },
        { id = 7724, slot = "Hands", name = "Gauntlets of Divinity", sources = { [14]=2933 }, bossNpc = "Scarlet Commander Mograine", legacyWing = "Cathedral" },
        { id = 7691, slot = "Head", name = "Embalmed Shroud", sources = { [14]=2917 }, bind = "BoP", rareNpc = "Fallen Champion", legacyWing = "Graveyard" },
        { id = 7720, slot = "Head", name = "Whitemane's Chapeau", sources = { [14]=2930 }, bossNpc = "High Inquisitor Whitemane", legacyWing = "Cathedral" },
        { id = 7709, slot = "Legs", name = "Blighted Leggings", sources = { [14]=2921 }, bind = "BoP", rareNpc = "Azshir the Sleepless", legacyWing = "Graveyard" },
        { id = 10330, slot = "Legs", name = "Scarlet Leggings", sources = { [14]=3915 }, bossNpc = "Scarlet Commander Mograine", legacyWing = "Cathedral" },
        { id = 7726, slot = "Off-hand", name = "Aegis of the Scarlet Commander", sources = { [14]=2934 }, bossNpc = "Scarlet Commander Mograine", legacyWing = "Cathedral" },
        { id = 7685, slot = "Off-hand", name = "Orb of the Forgotten Seer", sources = { [14]=2912 }, bossNpc = "Bloodmage Thalnos", legacyWing = "Graveyard" },
        { id = 7708, slot = "Ranged", name = "Necrotic Wand", sources = { [14]=2920 }, bind = "BoP", rareNpc = "Azshir the Sleepless", legacyWing = "Graveyard" },
        { id = 7684, slot = "Shoulder", name = "Bloodmage Mantle", sources = { [14]=2911 }, bossNpc = "Bloodmage Thalnos", legacyWing = "Graveyard" },
        { id = 19507, slot = "Shoulder", name = "Inquisitor's Shawl", sources = { [14]=7720 }, bossNpc = "High Inquisitor Fairbanks", legacyWing = "Cathedral" },
        { id = 7723, slot = "Two-Hand", name = "Mograine's Might", sources = { [14]=2932 }, bossNpc = "Scarlet Commander Mograine", legacyWing = "Cathedral" },
        { id = 7689, slot = "Two-Hand", name = "Morbid Dawn", sources = { [14]=2915 }, bind = "BoP", rareNpc = "Fallen Champion", legacyWing = "Graveyard" },
        { id = 7683, slot = "Weapon", name = "Bloody Brass Knuckles", sources = { [14]=2910 }, bossNpc = "Interrogator Vishas", legacyWing = "Graveyard" },
        { id = 7721, slot = "Weapon", name = "Hand of Righteousness", sources = { [14]=2931 }, bossNpc = "High Inquisitor Whitemane", legacyWing = "Cathedral" },
        { id = 7687, slot = "Weapon", name = "Ironspine's Fist", sources = { [14]=2913 }, bind = "BoP", rareNpc = "Ironspine", legacyWing = "Graveyard" },
        { id = 7682, slot = "Weapon", name = "Torturing Poker", sources = { [14]=2909 }, bossNpc = "Interrogator Vishas", legacyWing = "Graveyard" },
        { id = 19508, slot = "Wrist", name = "Branded Leather Bracers", sources = { [14]=7721 }, bossNpc = "High Inquisitor Fairbanks", legacyWing = "Cathedral" },
        { id = 10332, slot = "Feet", name = "Scarlet Boots", sources = { [14]=3917 }, bind = "BoE", legacyWing = "Graveyard" },
        { id = 10328, slot = "Chest", name = "Scarlet Chestpiece", sources = { [14]=3913 }, bind = "BoE", tag = "Scarlet Champion", legacyWing = "Cathedral" },
        { id = 10329, slot = "Waist", name = "Scarlet Belt", sources = { [14]=3914 }, bind = "BoE", legacyWing = "Cathedral" },
        { id = 10331, slot = "Hands", name = "Scarlet Gauntlets", sources = { [14]=3916 }, bind = "BoE", tag = "Scarlet Centurion", legacyWing = "Cathedral" },
        { id = 10332, slot = "Feet", name = "Scarlet Boots", sources = { [14]=3917 }, bind = "BoE", legacyWing = "Cathedral" },
    },

    -- Hallow's End's Headless Horseman, shown in the browser's event section.
    eventLabel       = "Hallow's End",
    eventNote        = "During Hallow's End, queue for the Headless Horseman in the Dungeon Finder. These come from the {item} he drops.",
    eventHoliday     = true,
    eventNoteItemID  = 209024,
    eventBossName    = "The Headless Horseman",
    eventEncounterID = 2725,
    eventAchievements = {
        { id = 18960, name = "Kickin' With the Wick", soloable = "yes" },
    },
    eventLoot = {
        { id = 117355, slot = "Head", name = "The Horseman's Horrific Hood", sources = { [14]=65951, [15]=65951 } },
        { id = 117356, slot = "Weapon", name = "The Horseman's Sinister Slicer", sources = { [14]=65952, [15]=65952 } },
        { id = 33292, slot = "Head", name = "Hallowed Helm", sources = { [14]=15335, [15]=15335 } },
        { id = 226690, slot = "Head", name = "Patched Harvest Golem's Head", sources = { [14]=223195, [15]=223195 } },
        { id = 226454, slot = "Shoulder", name = "Patched Harvest Golem's Pauldrons", sources = { [14]=223008, [15]=223008 } },
        { id = 226457, slot = "Chest", name = "Patched Harvest Golem's Chest", sources = { [14]=223011, [15]=223011 } },
        { id = 226456, slot = "Hands", name = "Patched Harvest Golem's Gloves", sources = { [14]=223010, [15]=223010 } },
        { id = 226461, slot = "Waist", name = "Patched Harvest Golem's Belt", sources = { [14]=223013, [15]=223013 } },
        { id = 226455, slot = "Legs", name = "Patched Harvest Golem's Pants", sources = { [14]=223009, [15]=223009 } },
        { id = 226458, slot = "Feet", name = "Patched Harvest Golem's Boots", sources = { [14]=223012, [15]=223012 } },
        { id = 247964, slot = "Head", name = "The Horseman's Ghoulish Helm", sources = { [14]=295322, [15]=295322 } },
        { id = 250708, slot = "Head", name = "The Horseman's Ghoulish Cowl", sources = { [14]=297970, [15]=297970 } },
        { id = 247965, slot = "Shoulder", name = "The Horseman's Ghoulish Mantle", sources = { [14]=295323, [15]=295323 } },
        { id = 247972, slot = "Back", name = "The Horseman's Ghoulish Cloak", sources = { [14]=295329, [15]=295329 } },
        { id = 247966, slot = "Chest", name = "The Horseman's Ghoulish Breastplate", sources = { [14]=295324, [15]=295324 } },
        { id = 247971, slot = "Hands", name = "The Horseman's Ghoulish Grips", sources = { [14]=295328, [15]=295328 } },
        { id = 247967, slot = "Waist", name = "The Horseman's Ghoulish Cinch", sources = { [14]=295325, [15]=295325 } },
        { id = 247968, slot = "Legs", name = "The Horseman's Ghoulish Greaves", sources = { [14]=295326, [15]=295326 } },
        { id = 247969, slot = "Feet", name = "The Horseman's Ghoulish Treads", sources = { [14]=295327, [15]=295327 } },
        { id = 37012, kind = "mount", name = "The Horseman's Reins" },
        { id = 247721, kind = "mount", name = "The Headless Horseman's Ghoulish Charger" },
        { id = 33154, kind = "pet", name = "Sinister Squashling" },
        { id = 211271, kind = "pet", name = "Arfus" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Thalnos the Soulrender",
            journalEncounterID = 688,
            dungeonEncounterID = 1423,
            achievements       = {
                { id = 6946, name = "Empowered Spiritualist", soloable = "yes" },
            },
            loot = {
                { id = 88288, slot = "Back", name = "Soulrender Greatcloak", sources = { [14]=45686, [15]=84451 } },
                { id = 88286, slot = "Legs", name = "Legguards of the Crimson Magus", sources = { [14]=45684, [15]=84337 } },
                { id = 88284, slot = "Shoulder", name = "Forgotten Bloodmage Mantle", sources = { [14]=45683, [15]=84336 } },
                { id = 88287, slot = "Wrist", name = "Bracers of the Fallen Crusader", sources = { [14]=45685, [15]=84452 } },
            },
        },
        {
            index              = 2,
            name               = "Brother Korloff",
            journalEncounterID = 671,
            dungeonEncounterID = 1424,
            achievements       = {
                { id = 6928, name = "Burning Man", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 88290, slot = "Back", name = "Scorched Earth Cloak", sources = { [14]=45688, [15]=84453 } },
                { id = 88291, slot = "Chest", name = "Korloff's Raiment", sources = { [14]=45689, [15]=84300 } },
                { id = 88292, slot = "Head", name = "Helm of Rising Flame", sources = { [14]=45690, [15]=84361 } },
                { id = 88289, slot = "Two-Hand", name = "Firestorm Greatstaff", sources = { [14]=45687, [15]=84454 } },
            },
        },
        {
            index              = 3,
            name               = "High Inquisitor Whitemane",
            journalEncounterID = 674,
            dungeonEncounterID = 1425,
            achievements       = {
                { id = 6929, name = "And Stay Dead!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 88295, slot = "Feet", name = "Dashing Strike Treads", sources = { [14]=45691, [15]=84338 } },
                { id = 132549, slot = "Feet", name = "Deft Strike Treads", sources = { [14]=76384 } },
                { id = 88303, slot = "Head", name = "Crown of Holy Flame", sources = { [14]=45698, [15]=84362 } },
                { id = 88299, slot = "Head", name = "Whitemane's Embroidered Chapeau", sources = { [14]=45695, [15]=84363 } },
                { id = 88298, slot = "Legs", name = "Leggings of Hallowed Fire", sources = { [14]=45694, [15]=84339 } },
                { id = 88302, slot = "Shoulder", name = "Incarnadine Scarlet Spaulders", sources = { [14]=45697, [15]=84340 } },
                { id = 88301, slot = "Two-Hand", name = "Greatstaff of Righteousness", sources = { [14]=45696, [15]=84457 } },
                { id = 88297, slot = "Two-Hand", name = "Lightbreaker Greatsword", sources = { [14]=45693, [15]=84455 } },
                { id = 88296, slot = "Waist", name = "Waistplate of Imminent Resurrection", sources = { [14]=45692, [15]=84456 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Thalnos the Soulrender (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Thalnos the Soulrender",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 435 },
                    kind    = "path",
                    note    = "After zoning in, proceed straight ahead to ^Thalnos the Soulrender^ at the end of the walkway.",
                    minNote = "Ahead to Thalnos",
                    points  = {
                        { 0.644, 0.459 },
                        { 0.449, 0.453 },
                        { 0.429, 0.489 },
                        { 0.399, 0.491 },
                        { 0.383, 0.457 },
                        { 0.293, 0.461 },
                    },
                },
            },
        },
        -- 2. Brother Korloff (boss 2). Two segments: out of the cloister
        -- on 435, then south through the gardens on 436.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Brother Korloff",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 435 },
                    kind    = "path",
                    note    = "After defeating ^Thalnos the Soulrender^, follow the path to the south to exit this area.",
                    minNote = "Take southern exit",
                    points  = {
                        { 0.351, 0.517 },
                        { 0.348, 0.760 },
                        { 0.365, 0.780 },
                        { 0.379, 0.780 },
                        { 0.391, 0.797 },
                        { 0.393, 0.848 },
                        { 0.485, 0.851 },
                        { 0.485, 0.934 },
                    },
                },
                {
                    when    = { mapID = 436 },
                    kind    = "path",
                    note    = "In the ^Chapel Gardens^, follow the path south to find ^Brother Korloff^ patrolling around.",
                    minNote = "South to Brother Korloff",
                    points  = {
                        { 0.488, 0.163 },
                        { 0.521, 0.159 },
                        { 0.525, 0.356 },
                        { 0.555, 0.364 },
                        { 0.550, 0.454 },
                        { 0.513, 0.484 },
                    },
                },
            },
        },
        -- 3. High Inquisitor Whitemane (boss 3), straight into the chapel.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "High Inquisitor Whitemane",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 436 },
                    kind    = "path",
                    note    = "After defeating ^Brother Korloff^, go straight ahead into the chapel to engage ^High Inquisitor Whitemane^.",
                    minNote = "Into chapel for Whitemane",
                    points  = {
                        { 0.492, 0.564 },
                        { 0.490, 0.769 },
                    },
                },
            },
        },
    },
}
