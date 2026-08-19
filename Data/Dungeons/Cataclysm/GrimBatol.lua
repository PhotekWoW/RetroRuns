-------------------------------------------------------------------------------
-- RetroRuns Data -- Grim Batol
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 670  |  journalInstanceID: 71
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[71] = {
    kind              = "dungeon",
    instanceID        = 670,
    journalInstanceID = 71,
    name              = "Grim Batol",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    patch             = "4.0.3",

    gloryMeta = {
        id   = 4845,
        name = "Glory of the Cataclysm Hero",
        rewardItemID       = 62900,
        rewardMountSpellID = 88331,
        rewardName         = "Volcanic Stone Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "General Umbriss",
            journalEncounterID = 2617,
            achievements       = {
                { id = 5297, name = "Umbrage for Umbriss" },
            },
            loot = {
                { id = 56442, slot = "Chest", name = "Cursed Skardyn Vest", sources = { [14]=27737 } },
                { id = 133284, slot = "Chest", name = "Cursed Skardyn Vest", sources = { [14]=76638 } },
                { id = 56443, slot = "Head", name = "Wildhammer Riding Helm", sources = { [14]=27738 } },
                { id = 133285, slot = "Head", name = "Wildhammer Riding Helm", sources = { [14]=76639 } },
                { id = 133354, slot = "Legs", name = "Glimmerthread Pantaloons", sources = { [14]=76678 } },
                { id = 157596, slot = "Legs", name = "Glimmerthread Pantaloons", sources = { [14]=93785 } },
                { id = 157612, slot = "Off-hand", name = "Dragonkin Ward", sources = { [14]=93798 } },
                { id = 56441, slot = "Weapon", name = "Modgud's Blade", sources = { [14]=27736 } },
                { id = 133283, slot = "Weapon", name = "Modgud's Blade", sources = { [14]=76637 } },
            },
        },
        {
            index              = 2,
            name               = "Forgemaster Throngus",
            journalEncounterID = 2627,
            achievements       = {
            },
            loot = {
                { id = 133363, slot = "Back", name = "Troggstitched Drape", sources = { [14]=76685 } },
                { id = 157597, slot = "Back", name = "Troggstitched Drape", sources = { [14]=93786 } },
                { id = 56448, slot = "Feet", name = "Dark Iron Chain Boots", sources = { [14]=27741 } },
                { id = 133290, slot = "Feet", name = "Dark Iron Chain Boots", sources = { [14]=76642 } },
                { id = 56446, slot = "Ranged", name = "Wand of Untainted Power", sources = { [14]=27739 } },
                { id = 133288, slot = "Ranged", name = "Wand of Untainted Power", sources = { [14]=76640 } },
                { id = 56447, slot = "Waist", name = "Belt of the Forgemaster", sources = { [14]=27740 } },
                { id = 133289, slot = "Waist", name = "Belt of the Forgemaster", sources = { [14]=76641 } },
                { id = 157613, slot = "Weapon", name = "Geomancy Slicer", sources = { [14]=93799 } },
            },
        },
        {
            index              = 3,
            name               = "Drahga Shadowburner",
            journalEncounterID = 2618,
            achievements       = {
            },
            loot = {
                { id = 56450, slot = "Back", name = "Azureborne Cloak", sources = { [14]=27742 } },
                { id = 133292, slot = "Back", name = "Azureborne Cloak", sources = { [14]=76643 } },
                { id = 157614, slot = "Feet", name = "Flame Invoker's Treads", sources = { [14]=93800 } },
                { id = 56451, slot = "Feet", name = "Red Scale Boots", sources = { [14]=27743 } },
                { id = 133293, slot = "Feet", name = "Red Scale Boots", sources = { [14]=76644 } },
                { id = 133374, slot = "Shoulder", name = "Courier's Dragonriding Spaulders", sources = { [14]=76691 } },
                { id = 157598, slot = "Shoulder", name = "Courier's Dragonriding Spaulders", sources = { [14]=93787 } },
                { id = 56452, slot = "Shoulder", name = "Earthshape Pauldrons", sources = { [14]=27744 } },
                { id = 133294, slot = "Shoulder", name = "Earthshape Pauldrons", sources = { [14]=76645 } },
                { id = 56454, slot = "Weapon", name = "Windwalker Blade", sources = { [14]=27746 } },
                { id = 133296, slot = "Weapon", name = "Windwalker Blade", sources = { [14]=76647 } },
                { id = 56453, slot = "Wrist", name = "Crimsonborne Bracers", sources = { [14]=27745 } },
                { id = 133295, slot = "Wrist", name = "Crimsonborne Bracers", sources = { [14]=76646 } },
            },
        },
        {
            index              = 4,
            name               = "Erudax, the Duke of Below",
            journalEncounterID = 2619,
            achievements       = {
                { id = 4840, name = "Grim Batol" },
                { id = 5062, name = "Heroic: Grim Batol" },
                { id = 5298, name = "Don't Need to Break Eggs to Make an Omelet", meta = true },
            },
            loot = {
                { id = 56455, slot = "Chest", name = "Vest of Misshapen Hides", sources = { [14]=27747 } },
                { id = 133297, slot = "Chest", name = "Vest of Misshapen Hides", sources = { [14]=76648 } },
                { id = 56460, slot = "Head", name = "Crown of Enfeebled Bodies", sources = { [14]=27750 } },
                { id = 133302, slot = "Head", name = "Crown of Enfeebled Bodies", sources = { [14]=76651 } },
                { id = 157615, slot = "Legs", name = "Flamescale Chain Leggings", sources = { [14]=93801 } },
                { id = 56461, slot = "Two-Hand", name = "Staff of Siphoned Essences", sources = { [14]=27751 } },
                { id = 133303, slot = "Two-Hand", name = "Staff of Siphoned Essences", sources = { [14]=76652 } },
                { id = 56456, slot = "Two-Hand", name = "Wild Hammer", sources = { [14]=27748 } },
                { id = 133298, slot = "Two-Hand", name = "Wild Hammer", sources = { [14]=76649 } },
                { id = 56459, slot = "Weapon", name = "Mace of Transformed Bone", sources = { [14]=27749 } },
                { id = 133301, slot = "Weapon", name = "Mace of Transformed Bone", sources = { [14]=76650 } },
                { id = 56464, slot = "Wrist", name = "Bracers of Umbral Mending", sources = { [14]=27752 } },
                { id = 133306, slot = "Wrist", name = "Bracers of Umbral Mending", sources = { [14]=76653 } },
            },
        },
    },
}
