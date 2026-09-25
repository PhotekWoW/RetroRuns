-------------------------------------------------------------------------------
-- RetroRuns Data -- Utgarde Pinnacle
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 575  |  journalInstanceID: 286
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[286] = {
    kind              = "dungeon",
    instanceID        = 575,
    journalInstanceID = 286,
    name              = "Utgarde Pinnacle",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",
    routedIn          = "3.3.0",

    entrance = {
        mapID = 117,
        x     = 0.573,
        y     = 0.467,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    trashLoot = {
        { id = 37587, slot = "Chest", name = "Ymirjar Physician's Robe", sources = { [15]=17882 }, bind = "BoE" },
        { id = 37068, slot = "Feet", name = "Berserker's Sabatons", sources = { [14]=17582, [15]=17582 }, bind = "BoE" },
        { id = 37070, slot = "Feet", name = "Tundra Wolf Boots", sources = { [14]=17584, [15]=17584 }, bind = "BoE" },
        { id = 37590, slot = "Wrist", name = "Bands of Fading Light", sources = { [15]=17883 }, bind = "BoE" },
        { id = 37069, slot = "Wrist", name = "Dragonflayer Seer's Bindings", sources = { [14]=17583, [15]=17583 }, bind = "BoE" },
    },

    bosses = {
        {
            index              = 1,
            name               = "Svala Sorrowgrave",
            journalEncounterID = 641,
            dungeonEncounterID = 2030,
            achievements       = {
                { id = 2043, name = "The Incredible Hulk", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 37367, slot = "Feet", name = "Echoing Stompers", sources = { [14]=17756, [15]=17756 } },
                { id = 37043, slot = "Hands", name = "Tear-Linked Gauntlets", sources = { [14]=17562, [15]=17562 } },
                { id = 37369, slot = "Legs", name = "Sorrowgrave's Breeches", sources = { [14]=17758, [15]=17758 } },
                { id = 37038, slot = "Ranged", name = "Brazier Igniter", sources = { [14]=17557, [15]=17557 } },
                { id = 37368, slot = "Shoulder", name = "Silent Spectator Shoulderpads", sources = { [14]=17757, [15]=17757 } },
                { id = 37037, slot = "Weapon", name = "Ritualistic Athame", sources = { [14]=17556, [15]=17556 } },
                { id = 37370, slot = "Wrist", name = "Cuffs of the Trussed Hall", sources = { [14]=17759, [15]=17759 } },
                { id = 37040, slot = "Wrist", name = "Svala's Bloodied Shackles", sources = { [14]=17559, [15]=17559 } },
            },
        },
        {
            index              = 2,
            name               = "Gortok Palehoof",
            journalEncounterID = 642,
            dungeonEncounterID = 2027,
            scenarioCriteriaID = 27886,
            achievements       = {
            },
            loot = {
                { id = 37048, slot = "Back", name = "Shroud of Resurrection", sources = { [14]=17566, [15]=17566 } },
                { id = 37052, slot = "Chest", name = "Reanimated Armor", sources = { [14]=17570, [15]=17570 } },
                { id = 37374, slot = "Legs", name = "Ravenous Leggings of the Furbolg", sources = { [14]=17761, [15]=17761 } },
                { id = 37051, slot = "Off-hand", name = "Seal of Valgarde", sources = { [14]=17569, [15]=17569 } },
                { id = 37050, slot = "Ranged", name = "Trophy Gatherer", sources = { [14]=17568, [15]=17568 } },
                { id = 37376, slot = "Shoulder", name = "Ferocious Pauldrons of the Rhino", sources = { [14]=17763, [15]=17763 } },
                { id = 37373, slot = "Shoulder", name = "Massive Spaulders of the Jormungar", sources = { [14]=17760, [15]=17760 } },
            },
        },
        {
            index              = 3,
            name               = "Skadi the Ruthless",
            journalEncounterID = 643,
            dungeonEncounterID = 2029,
            soloTip            = "To win this fight, you need to hit the boss 3 times with the ^Harpoon Launcher^. Kill ^Ymirjar Harpooner^ and collect the harpoons they drop. When the boss is in range, click the ^Harpoon Launcher^. Do this three times to dismount the boss and then kill him.",
            achievements       = {
                { id = 1873, name = "Lodi Dodi We Loves the Skadi", meta = true, soloable = "yes" },
                { id = 2156, name = "My Girl Loves to Skadi All the Time", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37057, slot = "Chest", name = "Drake Rider's Tunic", sources = { [14]=17574, [15]=17574 } },
                { id = 37056, slot = "Feet", name = "Harpooner's Striders", sources = { [14]=17573, [15]=17573 } },
                { id = 157560, slot = "Feet", name = "Skadi's Scaled Boots", sources = { [14]=93755, [15]=93755 } },
                { id = 37389, slot = "Legs", name = "Crenelation Leggings", sources = { [14]=17775, [15]=17775 } },
                { id = 37055, slot = "Shoulder", name = "Silken Amice of the Ymirjar", sources = { [14]=17572, [15]=17572 } },
                { id = 37384, slot = "Two-Hand", name = "Staff of Wayward Principles", sources = { [14]=17770, [15]=17770 } },
                { id = 37379, slot = "Waist", name = "Skadi's Iron Belt", sources = { [14]=17766, [15]=17766 } },
                { id = 37377, slot = "Weapon", name = "Netherbreath Spellblade", sources = { [14]=17764, [15]=17764 } },
            },
            specialLoot = {
                { id = 44151, kind = "mount", name = "Reins of the Blue Proto-Drake", heroicOnly = true },
            },
        },
        {
            index              = 4,
            name               = "King Ymiron",
            journalEncounterID = 644,
            dungeonEncounterID = 2028,
            achievements       = {
                { id = 2157, name = "King's Bane", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 37395, slot = "Chest", name = "Ornamented Plate Regalia", sources = { [14]=17780, [15]=17780 } },
                { id = 37409, slot = "Hands", name = "Gilt-Edged Leather Gauntlets", sources = { [14]=17793, [15]=17793 } },
                { id = 37062, slot = "Head", name = "Crown of Forgotten Kings", sources = { [14]=17578, [15]=17578 } },
                { id = 37066, slot = "Legs", name = "Ancient Royal Legguards", sources = { [14]=17580, [15]=17580 } },
                { id = 37061, slot = "Off-hand", name = "Tor's Crest", sources = { [14]=17577, [15]=17577 } },
                { id = 37067, slot = "Shoulder", name = "Ceremonial Pyre Mantle", sources = { [14]=17581, [15]=17581 } },
                { id = 37398, slot = "Shoulder", name = "Mantle of Discarded Ways", sources = { [14]=17782, [15]=17782 } },
                { id = 37408, slot = "Waist", name = "Girdle of Bane", sources = { [14]=17792, [15]=17792 } },
                { id = 37407, slot = "Waist", name = "Sovereign's Belt", sources = { [14]=17791, [15]=17791 } },
                { id = 37060, slot = "Weapon", name = "Jeweled Coronation Sword", sources = { [14]=17576, [15]=17576 } },
                { id = 37401, slot = "Weapon", name = "Red Sword of Courage", sources = { [14]=17785, [15]=17785 } },
                { id = 37065, slot = "Weapon", name = "Ymiron's Blade", sources = { [14]=17579, [15]=17579 } },
            },
        },
    },

    exitNote    = "Take the northern path from the boss room to arrive at the entrance",
    minExitNote = "North path to entrance",

    routing = {
        -- 1. Svala Sorrowgrave (boss 1). One linear path from the door;
        -- she activates after her dialog.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Svala Sorrowgrave",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 137 },
                    kind    = "path",
                    note    = "After zoning in, follow the linear path until you reach ^Svala Sorrowgrave^. She will activate after some dialog.",
                    minNote = "Follow path to Svala",
                    points  = {
                        { 0.445, 0.186 },
                        { 0.445, 0.357 },
                        { 0.342, 0.360 },
                        { 0.333, 0.462 },
                        { 0.340, 0.523 },
                        { 0.330, 0.589 },
                        { 0.340, 0.692 },
                        { 0.393, 0.692 },
                        { 0.393, 0.773 },
                        { 0.416, 0.774 },
                        { 0.452, 0.742 },
                    },
                },
            },
        },

        -- 2. Gortok Palehoof (boss 2). South out of Svala's room, then the
        -- stairs up.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Gortok Palehoof",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 136 },
                    kind    = "path",
                    note    = "After defeating ^Svala Sorrowgrave^, exit the room to the south. Climb a series of stairs on your way to ^Gortok Palehoof^. Click the ^Stasis Generator^ to start the encounter.",
                    minNote = "Follow path to Gortok Palehoof",
                    points  = {
                        { 0.359, 0.747 },
                        { 0.359, 0.863 },
                        { 0.454, 0.862 },
                        { 0.454, 0.786 },
                    },
                },
                {
                    when    = { mapID = 137 },
                    kind    = "path",
                    note    = "After defeating ^Svala Sorrowgrave^, exit the room to the south. Climb a series of stairs on your way to ^Gortok Palehoof^. Click the ^Stasis Generator^ to start the encounter.",
                    minNote = "Follow path to Gortok Palehoof",
                    points  = {
                        { 0.542, 0.813 },
                        { 0.544, 0.786 },
                        { 0.536, 0.755 },
                        { 0.522, 0.755 },
                        { 0.515, 0.786 },
                        { 0.521, 0.845 },
                        { 0.608, 0.845 },
                        { 0.608, 0.722 },
                    },
                },
                {
                    when            = { mapID = 137 },
                    kind            = "poi",
                    note            = "After defeating ^Svala Sorrowgrave^, exit the room to the south. Climb a series of stairs on your way to ^Gortok Palehoof^. Click the ^Stasis Generator^ to start the encounter.",
                    minNote         = "Click the Stasis Generator",
                    mapLabel        = "Click Stasis Generator",
                    mapLabelPos     = "below",
                    completionCheck = true,
                    points          = {
                        { 0.627, 0.842 },
                    },
                },
            },
        },

        -- 3. Skadi the Ruthless (boss 3). East out of the Trophy Hall.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Skadi the Ruthless",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 137 },
                    kind    = "path",
                    note    = "After defeating ^Gortok Palehoof^, exit the room to the east. Follow the path to ^Skadi the Ruthless^.",
                    minNote = "Follow path to Skadi",
                    points  = {
                        { 0.637, 0.695 },
                        { 0.663, 0.700 },
                        { 0.681, 0.697 },
                        { 0.690, 0.606 },
                        { 0.686, 0.397 },
                    },
                },
            },
        },

        -- 4. King Ymiron (boss 4). West from Skadi's terrace, then down
        -- the stairs to the throne room.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "King Ymiron",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 137 },
                    kind    = "path",
                    note    = "After killing ^Skadi the Ruthless^, exit to the west and work your way down several sets of stairs.",
                    minNote = "Exit west then downstairs",
                    points  = {
                        { 0.653, 0.366 },
                        { 0.628, 0.366 },
                        { 0.588, 0.388 },
                        { 0.559, 0.375 },
                        { 0.558, 0.343 },
                        { 0.581, 0.333 },
                        { 0.601, 0.339 },
                    },
                },
                {
                    when    = { mapID = 136 },
                    kind    = "path",
                    note    = "Continue on the linear path until you reach ^King Ymiron^.",
                    minNote = "Follow path to King Ymiron",
                    points  = {
                        { 0.564, 0.219 },
                        { 0.565, 0.346 },
                        { 0.510, 0.447 },
                        { 0.389, 0.446 },
                    },
                },
                -- The approach climbs back onto the first segment's map;
                -- these two hold the Ymiron note in the throne-room areas
                -- so the descent note does not flip back. The line is
                -- already drawn by the segment above.
                {
                    when    = { mapID = 137, subZone = "Ruined Court" },
                    kind    = "path",
                    note    = "Continue on the linear path until you reach ^King Ymiron^.",
                    minNote = "Follow path to King Ymiron",
                },
                {
                    when    = { mapID = 137, subZone = "Ymiron's Seat" },
                    kind    = "path",
                    note    = "Continue on the linear path until you reach ^King Ymiron^.",
                    minNote = "Follow path to King Ymiron",
                },
            },
        },
    },
}
