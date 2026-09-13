-------------------------------------------------------------------------------
-- RetroRuns Data -- Throne of the Tides
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 643  |  journalInstanceID: 65
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[65] = {
    kind              = "dungeon",
    instanceID        = 643,
    journalInstanceID = 65,
    name              = "Throne of the Tides",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 24 },
    patch             = "4.0.3",
    timewalking       = true,

    entrance = {
        mapID = 204,
        x     = 0.6961,
        y     = 0.2488,
    },

    bosses = {
        {
            index              = 1,
            name               = "Lady Naz'jar",
            journalEncounterID = 101,
            achievements       = {
            },
            loot = {
                { id = 56267, slot = "Back", name = "Periwinkle Cloak", sources = { [14]=27623, [15]=27623 } },
                { id = 133180, slot = "Back", name = "Periwinkle Cloak", sources = { [14]=76568, [15]=76568 } },
                { id = 56268, slot = "Hands", name = "Wrasse Handwraps", sources = { [14]=27624, [15]=27624 } },
                { id = 133181, slot = "Hands", name = "Wrasse Handwraps", sources = { [14]=76569, [15]=76569 } },
                { id = 56269, slot = "Head", name = "Aurelian Miter", sources = { [14]=27625, [15]=27625 } },
                { id = 133182, slot = "Head", name = "Aurelian Miter", sources = { [14]=76570, [15]=76570 } },
                { id = 133358, slot = "Head", name = "Old One Eye's Cowl", sources = { [14]=76682, [15]=76682 } },
                { id = 157587, slot = "Head", name = "Old One Eye's Cowl", sources = { [14]=93779, [15]=93779 } },
                { id = 133205, slot = "Legs", name = "Alpheus Legguards", sources = { [24]=76584 } },
                { id = 133367, slot = "Off-hand", name = "Barnacled Shell Buckler", sources = { [14]=76687, [15]=76687 } },
                { id = 56266, slot = "Weapon", name = "Lightning Whelk Axe", sources = { [14]=27622, [15]=27622 } },
                { id = 133179, slot = "Weapon", name = "Lightning Whelk Axe", sources = { [14]=76567, [15]=76567 } },
            },
        },
        {
            index              = 2,
            name               = "Commander Ulthok, the Festering Prince",
            journalEncounterID = 102,
            aliases            = { "Commander Ulthok" },
            scenarioCriteriaID = 24799,
            achievements       = {
            },
            loot = {
                { id = 56275, slot = "Back", name = "Eagle Ray Cloak", sources = { [14]=27630, [15]=27630 }, twSource = 76575 },
                { id = 56274, slot = "Chest", name = "Chromis Chestpiece", sources = { [14]=27629, [15]=27629 } },
                { id = 133187, slot = "Chest", name = "Chromis Chestpiece", sources = { [14]=76574, [15]=76574 } },
                { id = 56273, slot = "Shoulder", name = "Caridean Epaulets", sources = { [14]=27628, [15]=27628 } },
                { id = 133186, slot = "Shoulder", name = "Caridean Epaulets", sources = { [14]=76573, [15]=76573 } },
                { id = 56272, slot = "Shoulder", name = "Harp Shell Pauldrons", sources = { [14]=27627, [15]=27627 } },
                { id = 133185, slot = "Shoulder", name = "Harp Shell Pauldrons", sources = { [14]=76572, [15]=76572 } },
                { id = 56271, slot = "Two-Hand", name = "Cerith Spire Staff", sources = { [14]=27626, [15]=27626 } },
                { id = 133184, slot = "Two-Hand", name = "Cerith Spire Staff", sources = { [14]=76571, [15]=76571 } },
            },
        },
        {
            index              = 3,
            name               = "Mindbender Ghur'sha",
            journalEncounterID = 103,
            achievements       = {
            },
            loot = {
                { id = 56277, slot = "Feet", name = "Decapod Slippers", sources = { [14]=27631, [15]=27631 } },
                { id = 133190, slot = "Feet", name = "Decapod Slippers", sources = { [14]=76576, [15]=76576 } },
                { id = 56278, slot = "Head", name = "Anomuran Helm", sources = { [14]=27632, [15]=27632 } },
                { id = 133191, slot = "Head", name = "Anomuran Helm", sources = { [14]=76577, [15]=76577 } },
                { id = 133200, slot = "Off-hand", name = "Bioluminescent Lamp", sources = { [14]=76582, [15]=76582 } },
                { id = 133360, slot = "Waist", name = "Stonespeaker's Spare Cinch", sources = { [14]=76683, [15]=76683 } },
                { id = 157586, slot = "Waist", name = "Stonespeaker's Spare Cinch", sources = { [14]=93778, [15]=93778 } },
            },
        },
        {
            index              = 4,
            name               = "Ozumat",
            journalEncounterID = 104,
            achievements       = {
            },
            loot = {
                { id = 56291, slot = "Chest", name = "Abalone Plate Armor", sources = { [14]=27638, [15]=27638 } },
                { id = 133202, slot = "Chest", name = "Abalone Plate Armor", sources = { [14]=76583, [15]=76583 } },
                { id = 56281, slot = "Chest", name = "Wentletrap Vest", sources = { [14]=27633, [15]=27633 }, twSource = 76578 },
                { id = 56286, slot = "Hands", name = "Mnemiopsis Gloves", sources = { [14]=27636, [15]=27636 } },
                { id = 133198, slot = "Hands", name = "Mnemiopsis Gloves", sources = { [14]=76581, [15]=76581 } },
                { id = 56283, slot = "Legs", name = "Triton Legplates", sources = { [14]=27634, [15]=27634 } },
                { id = 133195, slot = "Legs", name = "Triton Legplates", sources = { [14]=76579, [15]=76579 } },
                { id = 56289, slot = "Off-hand", name = "Bioluminescent Lamp", sources = { [14]=27637, [15]=27637 } },
                { id = 56284, slot = "Two-Hand", name = "Whitefin Axe", sources = { [14]=27635, [15]=27635 } },
                { id = 133196, slot = "Two-Hand", name = "Whitefin Axe", sources = { [14]=76580, [15]=76580 } },
                { id = 133368, slot = "Waist", name = "Salty Shell-Studded Girdle", sources = { [14]=76688, [15]=76688 } },
                { id = 157589, slot = "Waist", name = "Salty Shell-Studded Girdle", sources = { [14]=93780, [15]=93780 } },
            },
        },
    },
}
