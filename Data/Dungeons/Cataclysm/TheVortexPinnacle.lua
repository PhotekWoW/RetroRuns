-------------------------------------------------------------------------------
-- RetroRuns Data -- The Vortex Pinnacle
-- Cataclysm dungeon, Patch 4.0.3  |  instanceID: 657  |  journalInstanceID: 68
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[68] = {
    kind              = "dungeon",
    instanceID        = 657,
    journalInstanceID = 68,
    name              = "The Vortex Pinnacle",
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
            name               = "Grand Vizier Ertan",
            journalEncounterID = 114,
            achievements       = {
            },
            loot = {
                { id = 56358, slot = "Head", name = "Headcover of Fog", sources = { [14]=27684 } },
                { id = 56359, slot = "Shoulder", name = "Fallen Snow Shoulderguards", sources = { [14]=27685 } },
                { id = 133235, slot = "Shoulder", name = "Fallen Snow Shoulderguards", sources = { [14]=76606 } },
                { id = 157603, slot = "Two-Hand", name = "Thundercleaver Axe", sources = { [14]=93789 } },
                { id = 56356, slot = "Waist", name = "Stratosphere Belt", sources = { [14]=27682 } },
                { id = 133232, slot = "Waist", name = "Stratosphere Belt", sources = { [14]=76603 } },
                { id = 56357, slot = "Weapon", name = "Biting Wind", sources = { [14]=27683 } },
                { id = 133233, slot = "Weapon", name = "Biting Wind", sources = { [14]=76604 } },
            },
        },
        {
            index              = 2,
            name               = "Altairus",
            journalEncounterID = 115,
            achievements       = {
            },
            loot = {
                { id = 133362, slot = "Back", name = "Billowing Skydrape", sources = { [14]=76684 } },
                { id = 157604, slot = "Back", name = "Billowing Skydrape", sources = { [14]=93790 } },
                { id = 133253, slot = "Feet", name = "Darksky Treads", sources = { [14]=76618 } },
                { id = 133370, slot = "Feet", name = "Sandals of the West Wind", sources = { [14]=76689 } },
                { id = 157605, slot = "Feet", name = "Sandals of the West Wind", sources = { [14]=93791 } },
                { id = 133251, slot = "Ranged", name = "Thundercall", sources = { [14]=76617 } },
                { id = 56361, slot = "Shoulder", name = "Mantle of Bestilled Winds", sources = { [14]=27686 } },
                { id = 133237, slot = "Shoulder", name = "Mantle of Bestilled Winds", sources = { [14]=76607 } },
                { id = 133371, slot = "Two-Hand", name = "Thundercleaver Axe", sources = { [14]=76690 } },
                { id = 56363, slot = "Waist", name = "Hail-Strung Belt", sources = { [14]=27687 } },
                { id = 133239, slot = "Waist", name = "Hail-Strung Belt", sources = { [14]=76608 } },
                { id = 56364, slot = "Weapon", name = "Axe of the Eclipse", sources = { [14]=27688 } },
                { id = 133240, slot = "Weapon", name = "Axe of the Eclipse", sources = { [14]=76609 } },
            },
            specialLoot = {
                { id = 63040, kind = "mount", name = "Reins of the Drake of the North Wind" },
            },
        },
        {
            index              = 3,
            name               = "Asaad, Caliph of Zephyrs",
            journalEncounterID = 116,
            achievements       = {
                { id = 4847, name = "The Vortex Pinnacle" },
                { id = 5064, name = "Heroic: The Vortex Pinnacle" },
                { id = 5288, name = "No Static at All", meta = true },
                { id = 5289, name = "Extra Credit Bonus Stage", meta = true },
            },
            loot = {
                { id = 56369, slot = "Back", name = "Billowing Cape", sources = { [14]=27692 } },
                { id = 133245, slot = "Back", name = "Billowing Cape", sources = { [14]=76613 } },
                { id = 56371, slot = "Back", name = "Shadow of Perfect Bliss", sources = { [14]=27693 } },
                { id = 133247, slot = "Back", name = "Shadow of Perfect Bliss", sources = { [14]=76614 } },
                { id = 56368, slot = "Hands", name = "Gloves of Haze", sources = { [14]=27691 } },
                { id = 133244, slot = "Hands", name = "Gloves of Haze", sources = { [14]=76612 } },
                { id = 56374, slot = "Head", name = "Lunar Halo", sources = { [14]=27694 } },
                { id = 133249, slot = "Head", name = "Lunar Halo", sources = { [14]=76615 } },
                { id = 56375, slot = "Legs", name = "Leggings of Iridescent Clouds", sources = { [14]=27695 } },
                { id = 133250, slot = "Legs", name = "Leggings of Iridescent Clouds", sources = { [14]=76616 } },
                { id = 56367, slot = "Legs", name = "Legguards of Winnowing Wind", sources = { [14]=27690 } },
                { id = 133243, slot = "Legs", name = "Legguards of Winnowing Wind", sources = { [14]=76611 } },
                { id = 56366, slot = "Ranged", name = "Lightningflash", sources = { [14]=27689 } },
                { id = 133242, slot = "Ranged", name = "Lightningflash", sources = { [14]=76610 } },
                { id = 56376, slot = "Ranged", name = "Thundercall", sources = { [14]=27696 } },
            },
        },
    },
}
