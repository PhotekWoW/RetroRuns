-------------------------------------------------------------------------------
-- RetroRuns Data -- Stratholme - Service Entrance
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Classic dungeon, Patch 1.0  |  instanceID: 329  |  journalInstanceID: 1292
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1292] = {
    kind              = "dungeon",
    instanceID        = 329,
    journalInstanceID = 1292,
    name              = "Stratholme - Service Entrance",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14 },
    patch             = "1.0",
    timewalking       = true,
    -- Both doors report the same instanceID, so the wing is
    -- picked from the uiMap the player enters on.
    uiMaps = { 318 },

    entrance = {
        mapID = 23,
        x     = 0.4380,
        y     = 0.1750,
    },

    pois = {
        -- His range is DRAWN, not derived: the sighting list spans two thirds
        -- of the wing, and its bounding box swallowed the map. This is the
        -- ground he actually walks, captured in game.
        { mapID = 318, poiKind = "rare", rareNpc = "Stonespine", mapLabelPos = "above", navPoint = { 0.613, 0.360 }, points = { { 0.440, 0.210 }, { 0.544, 0.494 }, { 0.560, 0.178 }, { 0.576, 0.372 }, { 0.610, 0.246 }, { 0.614, 0.476 }, { 0.614, 0.586 }, { 0.634, 0.712 }, { 0.668, 0.284 }, { 0.668, 0.796 }, { 0.674, 0.212 }, { 0.682, 0.336 }, { 0.692, 0.158 }, { 0.700, 0.482 }, { 0.706, 0.388 }, { 0.762, 0.476 } } },
    },

    trashLoot = {
        { id = 18743, slot = "Back", name = "Gracious Cape", sources = { [14]=7470 }, bind = "BoE" },
        { id = 17061, slot = "Back", name = "Juno's Shadow", sources = { [14]=7074 }, bind = "BoE" },
        { id = 13397, slot = "Back", name = "Stoneskin Gargoyle Cape", sources = { [14]=4875 }, bind = "BoP", rareNpc = "Stonespine" },
        { id = 13954, slot = "Feet", name = "Verdant Footpads", sources = { [14]=5075 }, bind = "BoP", rareNpc = "Stonespine" },
        { id = 18744, slot = "Hands", name = "Plaguebat Fur Gloves", sources = { [14]=7471 }, bind = "BoE" },
        { id = 18736, slot = "Legs", name = "Plaguehound Leggings", sources = { [14]=7463 }, bind = "BoE" },
        { id = 18745, slot = "Legs", name = "Sacred Cloth Leggings", sources = { [14]=7472 }, bind = "BoE" },
        { id = 18742, slot = "Shoulder", name = "Stratholme Militia Shoulderguard", sources = { [14]=7469 }, bind = "BoE" },
        { id = 16736, slot = "Waist", name = "Belt of Valor", sources = { [14]=6867 }, bind = "BoE" },
        { id = 16723, slot = "Waist", name = "Lightforge Belt", sources = { [14]=6854 }, bind = "BoE" },
        { id = 13399, slot = "Weapon", name = "Gargoyle Shredder Talons", sources = { [14]=4877 }, bind = "BoP", rareNpc = "Stonespine" },
        { id = 16681, slot = "Wrist", name = "Beaststalker's Bindings", sources = { [14]=6812 }, bind = "BoE" },
        { id = 16671, slot = "Wrist", name = "Bindings of Elements", sources = { [14]=6802 }, bind = "BoE" },
        { id = 16697, slot = "Wrist", name = "Devout Bracers", sources = { [14]=6828 }, bind = "BoE" },
        { id = 18741, slot = "Wrist", name = "Morlune's Bracer", sources = { [14]=7468 }, bind = "BoE" },
        { id = 16714, slot = "Wrist", name = "Wildheart Bracers", sources = { [14]=6845 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Baroness Anastari",
            journalEncounterID = 451,
            dungeonEncounterID = 479,
            achievements       = {
            },
            loot = {
                { id = 13535, slot = "Chest", name = "Coldtouch Phantom Wraps", sources = { [14]=4904 } },
                { id = 13539, slot = "Hands", name = "Banshee's Touch", sources = { [14]=4907 } },
                { id = 18730, slot = "Hands", name = "Shadowy Laced Handwraps", sources = { [14]=7460 } },
                { id = 13534, slot = "Ranged", name = "Banshee Finger", sources = { [14]=4903 } },
                { id = 18729, slot = "Ranged", name = "Screeching Bow", sources = { [14]=7459 } },
                { id = 13538, slot = "Shoulder", name = "Windshrieker Pauldrons", sources = { [14]=4906 } },
                { id = 13537, slot = "Wrist", name = "Chillhide Bracers", sources = { [14]=4905 } },
            },
        },
        {
            index              = 2,
            name               = "Nerub'enkan",
            journalEncounterID = 452,
            dungeonEncounterID = 480,
            achievements       = {
            },
            loot = {
                { id = 13530, slot = "Feet", name = "Fangdrip Runners", sources = { [14]=4899 } },
                { id = 13532, slot = "Hands", name = "Darkspinner Claws", sources = { [14]=4901 } },
                { id = 18739, slot = "Legs", name = "Chitinous Plate Legguards", sources = { [14]=7466 } },
                { id = 13531, slot = "Legs", name = "Crypt Stalker Leggings", sources = { [14]=4900 } },
                { id = 13529, slot = "Off-hand", name = "Husk of Nerub'enkan", sources = { [14]=4898 } },
                { id = 18738, slot = "Ranged", name = "Carapace Spine Crossbow", sources = { [14]=7465 } },
                { id = 13533, slot = "Shoulder", name = "Acid-Etched Pauldrons", sources = { [14]=4902 } },
                { id = 18740, slot = "Waist", name = "Thuzadin Sash", sources = { [14]=7467 } },
            },
        },
        {
            index              = 3,
            name               = "Maleki the Pallid",
            journalEncounterID = 453,
            dungeonEncounterID = 481,
            achievements       = {
            },
            loot = {
                { id = 18734, slot = "Back", name = "Pale Moon Cloak", sources = { [14]=7461 } },
                { id = 13527, slot = "Feet", name = "Lavawalker Greaves", sources = { [14]=4896 } },
                { id = 18735, slot = "Feet", name = "Maleki's Footwraps", sources = { [14]=7462 } },
                { id = 13525, slot = "Hands", name = "Darkbind Fingers", sources = { [14]=4894 } },
                { id = 13524, slot = "Off-hand", name = "Skull of Burning Shadows", sources = { [14]=4893 } },
                { id = 13526, slot = "Waist", name = "Flamescarred Girdle", sources = { [14]=4895 } },
                { id = 18737, slot = "Weapon", name = "Bone Slicing Hatchet", sources = { [14]=7464 } },
                { id = 13528, slot = "Wrist", name = "Twilight Void Bracers", sources = { [14]=4897 } },
            },
        },
        {
            index              = 4,
            name               = "Magistrate Barthilas",
            journalEncounterID = 454,
            dungeonEncounterID = 482,
            achievements       = {
            },
            loot = {
                { id = 13376, slot = "Back", name = "Royal Tribunal Cloak", sources = { [14]=4857 } },
                { id = 18722, slot = "Hands", name = "Death Grips", sources = { [14]=7455 } },
                { id = 18727, slot = "Head", name = "Crimson Felt Hat", sources = { [14]=7458 } },
                { id = 18725, slot = "Two-Hand", name = "Peacemaker", sources = { [14]=7456 } },
                { id = 18726, slot = "Wrist", name = "Magistrate's Cuffs", sources = { [14]=7457 } },
            },
        },
        {
            index              = 5,
            name               = "Ramstein the Gorger",
            journalEncounterID = 455,
            dungeonEncounterID = 483,
            achievements       = {
            },
            loot = {
                { id = 13375, slot = "Off-hand", name = "Crest of Retribution", sources = { [14]=4856 } },
                { id = 13374, slot = "Shoulder", name = "Soulstealer Mantle", sources = { [14]=4855 } },
                { id = 13372, slot = "Two-Hand", name = "Slavedriver's Cane", sources = { [14]=4854 } },
            },
        },
        {
            index              = 6,
            name               = "Lord Aurius Rivendare",
            journalEncounterID = 456,
            dungeonEncounterID = 484,
            achievements       = {
            },
            loot = {
                { id = 13340, slot = "Back", name = "Cape of the Black Baron", sources = { [14]=4840 } },
                { id = 13346, slot = "Chest", name = "Robes of the Exalted", sources = { [14]=4843 } },
                { id = 22409, slot = "Chest", name = "Tunic of the Crescent Moon", sources = { [14]=8818 } },
                { id = 13344, slot = "Hands", name = "Dracorian Gauntlets", sources = { [14]=4842 } },
                { id = 22410, slot = "Hands", name = "Gauntlets of Deftness", sources = { [14]=8819 } },
                { id = 22411, slot = "Head", name = "Helm of the Executioner", sources = { [14]=8820 } },
                { id = 22408, slot = "Ranged", name = "Ritssyn's Wand of Bad Mojo", sources = { [14]=8817 } },
                { id = 22412, slot = "Shoulder", name = "Thuzadin Mantle", sources = { [14]=8821 } },
                { id = 13505, slot = "Two-Hand", name = "Runeblade of Baron Rivendare", sources = { [14]=4892 } },
                { id = 13368, slot = "Weapon", name = "Bonescraper", sources = { [14]=4851 } },
                { id = 13349, slot = "Weapon", name = "Scepter of the Unholy", sources = { [14]=4845 } },
                { id = 13361, slot = "Weapon", name = "Skullforge Reaver", sources = { [14]=4850 } },
            },
            specialLoot = {
                { id = 13335, kind = "mount", name = "Deathcharger's Reins" },
            },
        },
    },

    routing = {

        -- 1. Baroness Anastari (boss 1)
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Baroness Anastari",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 318 },
                    kind    = "path",
                    note    = "After zoning in, go north and then east to reach ^Baroness Anastari^.",
                    minNote = "North then east to Baroness",
                    points  = {
                        { 0.685, 0.834 },
                        { 0.652, 0.752 },
                        { 0.634, 0.664 },
                        { 0.617, 0.595 },
                        { 0.661, 0.541 },
                        { 0.691, 0.503 },
                        { 0.723, 0.483 },
                    },
                },
            },
        },

        -- 2. Nerub'enkan (boss 2)
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Nerub'enkan",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 318 },
                    kind        = "poi",
                    note        = "After defeating ^Baroness Anastari^, go inside the ^Ash'ari Crystal^ behind her and clear out the enemies.",
                    minNote     = "Clear out building behind Anastari",
                    mapLabel    = "Clear building",
                    mapLabelPos = "below",
                    completionCheck = true,
                    -- Fires on the FIRST of the three crystals, not all
                    -- three: the other two are cleared later in the run.
                    triggeredBy = { scenario = 24918, quantity = 1 },
                    points      = {
                        { 0.781, 0.479 },
                    },
                },
                {
                    when    = { mapID = 318 },
                    kind    = "path",
                    note    = "After clearing out the crystal, go west to find ^Nerub'enkan^ standing in front of the second ^Ash'ari Crystal^.",
                    minNote = "West to Nerub'enkan",
                    points  = {
                        { 0.719, 0.481 },
                        { 0.661, 0.508 },
                        { 0.615, 0.454 },
                        { 0.596, 0.449 },
                    },
                },
            },
        },

        -- 3. Maleki the Pallid (boss 3)
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Maleki the Pallid",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 318 },
                    kind        = "poi",
                    note        = "After defeating ^Nerub'enkan^, go inside the ^Ash'ari Crystal^ behind him and clear out the enemies.",
                    minNote     = "Clear out building behind Nerub'enkan",
                    mapLabel    = "Clear building",
                    mapLabelPos = "below",
                    completionCheck = true,
                    -- Second of the three crystals.
                    triggeredBy = { scenario = 24918, quantity = 2 },
                    points      = {
                        { 0.533, 0.492 },
                    },
                },
                {
                    when    = { mapID = 318 },
                    kind    = "path",
                    note    = "After clearing out the second crystal, go northeast to find ^Maleki the Pallid^ standing on the steps in front of the third ^Ash'ari Crystal^.",
                    minNote = "Northeast to Maleki",
                    points  = {
                        { 0.578, 0.424 },
                        { 0.588, 0.331 },
                        { 0.607, 0.293 },
                        { 0.650, 0.254 },
                    },
                },
            },
        },

        -- 4. Magistrate Barthilas (boss 4)
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Magistrate Barthilas",
            requires  = { },
            segments  = {
                {
                    when        = { mapID = 318 },
                    kind        = "poi",
                    note        = "After defeating ^Maleki the Pallid^, go inside the final ^Ash'ari Crystal^ behind him and clear out the enemies.",
                    minNote     = "Clear out the final crystal",
                    mapLabel    = "Clear building",
                    mapLabelPos = "above",
                    completionCheck = true,
                    -- Dialog, not the scenario criterion: completing the
                    -- LAST crystal advances the scenario step, so criterion
                    -- 24918 leaves the current step at the same moment it
                    -- would read 3/3 and can never be observed there.
                    -- Quantities 1 and 2 are fine -- the step is still live.
                    -- The Thuzadin Acolyte's per-crystal lines say "has been
                    -- destroyed"; this one says "have", and the npc pin makes
                    -- it exact either way.
                    triggeredBy = { dialog = { npc = "Lord Aurius Rivendare", match = "Crystals have been destroyed" } },
                    points      = {
                        { 0.700, 0.171 },
                    },
                },
                {
                    when    = { mapID = 318 },
                    kind    = "path",
                    note    = "After clearing out the final crystal, go northwest to find ^Magistrate Barthilas^.",
                    minNote = "Northwest to Barthilas",
                    points  = {
                        { 0.644, 0.257 },
                        { 0.622, 0.261 },
                        { 0.583, 0.243 },
                        { 0.567, 0.203 },
                    },
                },
            },
        },

        -- 5. Ramstein the Gorger (boss 5)
        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Ramstein the Gorger",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 318 },
                    kind    = "path",
                    note    = "After killing ^Magistrate Barthilas^, go west into ^Slaughter Square^ and kill all of the abominations to spawn ^Ramstein the Gorger^.",
                    minNote = "Kill aboms to spawn Ramstein",
                    points  = {
                        { 0.542, 0.189 },
                        { 0.480, 0.197 },
                    },
                },
            },
        },

        -- 6. Lord Aurius Rivendare (boss 6)
        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Lord Aurius Rivendare",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 318 },
                    kind    = "path",
                    note    = "After defeating ^Ramstein the Gorger^, kill the trash that appears then walk into the building to find ^Lord Aurius Rivendare^.",
                    minNote = "Trash then Rivendare",
                    points  = {
                        { 0.434, 0.202 },
                        { 0.410, 0.201 },
                    },
                },
            },
        },

    },
}
