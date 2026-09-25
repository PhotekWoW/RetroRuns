-------------------------------------------------------------------------------
-- RetroRuns Data -- The Underbog
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 546  |  journalInstanceID: 262
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[262] = {
    kind              = "dungeon",
    instanceID        = 546,
    journalInstanceID = 262,
    name              = "The Underbog",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    timewalking       = true,
    routedIn          = "3.1.1",

    entrance = {
        mapID = 102,
        x     = 0.5437,
        y     = 0.3438,
    },

    bosses = {
        {
            index              = 1,
            name               = "Hungarfen",
            journalEncounterID = 576,
            dungeonEncounterID = 1946,
            achievements       = {
            },
            loot = {
                { id = 27745, slot = "Hands", name = "Hungarhide Gauntlets", sources = { [14]=12034, [15]=12034 }, twSource = 165664 },
                { id = 24450, slot = "Hands", name = "Manaspark Gloves", sources = { [14]=9564, [15]=9564 }, twSource = 165647 },
                { id = 24452, slot = "Hands", name = "Starlight Gauntlets", sources = { [14]=9566, [15]=9566 }, twSource = 165649 },
                { id = 27748, slot = "Legs", name = "Cassock of the Loyal", sources = { [14]=12037, [15]=12037 }, twSource = 165667 },
                { id = 27743, slot = "Waist", name = "Girdle of Living Flame", sources = { [14]=12033, [15]=12033 }, twSource = 165663 },
                { id = 27747, slot = "Weapon", name = "Boggspine Knuckles", sources = { [14]=12036, [15]=12036 }, twSource = 165666 },
                { id = 27746, slot = "Wrist", name = "Arcanium Signet Bands", sources = { [14]=12035, [15]=12035 }, twSource = 165665 },
                { id = 24451, slot = "Wrist", name = "Lykul Bloodbands", sources = { [14]=9565, [15]=9565 }, twSource = 165648 },
            },
        },
        {
            index              = 2,
            name               = "Ghaz'an",
            journalEncounterID = 577,
            dungeonEncounterID = 1945,
            achievements       = {
            },
            loot = {
                { id = 24459, slot = "Back", name = "Cloak of Healing Rays", sources = { [14]=9573, [15]=9573 }, twSource = 165656 },
                { id = 27759, slot = "Head", name = "Headdress of the Tides", sources = { [14]=12047, [15]=12047 }, twSource = 165670 },
                { id = 27757, slot = "Two-Hand", name = "Greatstaff of the Leviathan", sources = { [14]=12046, [15]=12046 }, twSource = 165669 },
                { id = 24461, slot = "Two-Hand", name = "Hatebringer", sources = { [14]=9574, [15]=9574 }, twSource = 165657 },
                { id = 27760, slot = "Waist", name = "Dunewind Sash", sources = { [14]=12048, [15]=12048 }, twSource = 165671 },
                { id = 27755, slot = "Waist", name = "Girdle of Gallantry", sources = { [14]=12044, [15]=12044 }, twSource = 165668 },
                { id = 24458, slot = "Waist", name = "Studded Girdle of Virtue", sources = { [14]=9572, [15]=9572 }, twSource = 165655 },
            },
        },
        {
            index              = 3,
            name               = "Swamplord Musel'ek",
            journalEncounterID = 578,
            dungeonEncounterID = 1947,
            achievements       = {
            },
            loot = {
                { id = 24454, slot = "Back", name = "Cloak of Enduring Swiftness", sources = { [14]=9568, [15]=9568 }, twSource = 165651 },
                { id = 24455, slot = "Chest", name = "Tunic of the Nightwatcher", sources = { [14]=9569, [15]=9569 }, twSource = 165652 },
                { id = 27764, slot = "Hands", name = "Hands of the Sun", sources = { [14]=12050, [15]=12050 }, twSource = 165673 },
                { id = 27763, slot = "Head", name = "Crown of the Forest Lord", sources = { [14]=12049, [15]=12049 }, twSource = 165672 },
                { id = 24456, slot = "Legs", name = "Greaves of the Iron Guardian", sources = { [14]=9570, [15]=9570 }, twSource = 165653 },
                { id = 24457, slot = "Shoulder", name = "Truth Bearer Shoulderguards", sources = { [14]=9571, [15]=9571 }, twSource = 165654 },
                { id = 27767, slot = "Weapon", name = "Bogreaver", sources = { [14]=12052, [15]=12052 }, twSource = 165675 },
                { id = 24453, slot = "Weapon", name = "Zangartooth Shortblade", sources = { [14]=9567, [15]=9567 }, twSource = 165650 },
                { id = 27765, slot = "Wrist", name = "Armwraps of Disdain", sources = { [14]=12051, [15]=12051 }, twSource = 165674 },
            },
        },
        {
            index              = 4,
            name               = "The Black Stalker",
            journalEncounterID = 579,
            dungeonEncounterID = 1948,
            achievements       = {
            },
            loot = {
                { id = 24481, slot = "Chest", name = "Robes of the Augurer", sources = { [14]=9579, [15]=9579 }, twSource = 165662 },
                { id = 24465, slot = "Chest", name = "Shamblehide Chestguard", sources = { [14]=9577, [15]=9577 }, twSource = 165660 },
                { id = 29265, slot = "Feet", name = "Barkchip Boots", sources = { [14]=13058, [15]=13058 }, twSource = 165684 },
                { id = 27781, slot = "Head", name = "Demonfang Ritual Helm", sources = { [14]=12061, [15]=12061 }, twSource = 165681 },
                { id = 27938, slot = "Head", name = "Savage Mask of the Lynx Lord", sources = { [14]=12164, [15]=12164 }, twSource = 165683 },
                { id = 27773, slot = "Legs", name = "Barbaric Legstraps", sources = { [14]=12057, [15]=12057 }, twSource = 165680 },
                { id = 27907, slot = "Legs", name = "Mana-Etched Pantaloons", sources = { [14]=12145, [15]=12145 }, twSource = 165682 },
                { id = 24466, slot = "Legs", name = "Skulldugger's Leggings", sources = { [14]=9578, [15]=9578 }, twSource = 165661 },
                { id = 30541, slot = "Legs", name = "Stormsong Kilt", sources = { [14]=13811, [15]=13811 }, twSource = 165686 },
                { id = 27772, slot = "Off-hand", name = "Stormshield of Renewal", sources = { [14]=12056, [15]=12056 }, twSource = 165679 },
                { id = 29350, slot = "Ranged", name = "The Black Stalk", sources = { [14]=13095, [15]=13095 }, twSource = 165685 },
                { id = 27771, slot = "Shoulder", name = "Doomplate Shoulderguards", sources = { [14]=12055, [15]=12055 }, twSource = 165678, setName = "Doomplate Battlegear", dungeonSet = 3 },
                { id = 24463, slot = "Shoulder", name = "Pauldrons of Brute Force", sources = { [14]=9575, [15]=9575 }, twSource = 165658 },
                { id = 27769, slot = "Two-Hand", name = "Endbringer", sources = { [14]=12054, [15]=12054 }, twSource = 165677 },
                { id = 27768, slot = "Waist", name = "Oracle Belt of Timeless Mystery", sources = { [14]=12053, [15]=12053 }, twSource = 165676 },
                { id = 24464, slot = "Weapon", name = "The Stalker's Fangs", sources = { [14]=9576, [15]=9576 }, twSource = 165659 },
            },
        },
    },

    exitNote    = "Continue south past the final boss to reach the exit",
    minExitNote = "South past final boss to exit",

    routing = {
        -- 1. Hungarfen (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Hungarfen",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 262 },
                    kind    = "path",
                    note    = "After zoning in, stay to the right and go up the winding ramp to reach ^Hungarfen^.",
                    minNote = "Stay right, up ramp to Hungarfen",
                    points  = {
                        { 0.303, 0.670 },
                        { 0.330, 0.593 },
                        { 0.373, 0.599 },
                        { 0.393, 0.644 },
                        { 0.404, 0.725 },
                        { 0.491, 0.725 },
                        { 0.567, 0.806 },
                        { 0.586, 0.850 },
                        { 0.592, 0.911 },
                        { 0.577, 0.913 },
                        { 0.557, 0.889 },
                        { 0.565, 0.865 },
                        { 0.667, 0.903 },
                    },
                },
            },
        },
        -- 2. Ghaz'an (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Ghaz'an",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 262 },
                    kind    = "path",
                    note    = "After killing ^Hungarfen^, follow the path clockwise and cross a bridge to end up indoors. Follow the path up the ramp and loop back around until you reach ^Ghaz'an^ below.",
                    minNote = "Follow path to Ghaz'an",
                    points  = {
                        { 0.704, 0.840 },
                        { 0.702, 0.745 },
                        { 0.606, 0.653 },
                        { 0.589, 0.553 },
                        { 0.661, 0.543 },
                        { 0.709, 0.555 },
                        { 0.740, 0.461 },
                        { 0.737, 0.444 },
                        { 0.704, 0.406 },
                        { 0.686, 0.368 },
                        { 0.678, 0.318 },
                        { 0.681, 0.279 },
                        { 0.691, 0.281 },
                        { 0.700, 0.334 },
                        { 0.709, 0.372 },
                        { 0.731, 0.409 },
                        { 0.758, 0.430 },
                        { 0.784, 0.433 },
                        { 0.798, 0.397 },
                        { 0.805, 0.356 },
                    },
                },
            },
        },
        -- 3. Swamplord Musel'ek (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Swamplord Musel'ek",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 262 },
                    kind    = "path",
                    note    = "After defeating ^Ghaz'an^, jump into the water off the north end of the platform, and swim into the opening in the wall. Follow the path west until you reach ^Swamplord Musel'ek^ walking around a campfire.",
                    minNote = "Jump in water, path to Swamplord",
                    points  = {
                        { 0.792, 0.240 },
                        { 0.808, 0.115 },
                        { 0.761, 0.110 },
                        { 0.733, 0.121 },
                        { 0.695, 0.168 },
                        { 0.648, 0.150 },
                        { 0.599, 0.248 },
                        { 0.570, 0.266 },
                        { 0.514, 0.259 },
                        { 0.456, 0.293 },
                        { 0.432, 0.275 },
                    },
                },
            },
        },
        -- 4. The Black Stalker (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "The Black Stalker",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 262 },
                    kind    = "path",
                    note    = "After killing ^Swamplord Musel'ek^, go south and follow the path to ^The Black Stalker^.",
                    minNote = "South path to The Black Stalker",
                    points  = {
                        { 0.417, 0.299 },
                        { 0.418, 0.448 },
                        { 0.372, 0.459 },
                        { 0.341, 0.416 },
                        { 0.323, 0.359 },
                        { 0.294, 0.339 },
                        { 0.252, 0.378 },
                        { 0.248, 0.421 },
                    },
                },
            },
        },
    },
}
