-------------------------------------------------------------------------------
-- RetroRuns Data -- Scarlet Monastery
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
    patch             = "5.0.4",

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
            name               = "Thalnos the Soulrender",
            journalEncounterID = 688,
            achievements       = {
                { id = 6946, name = "Empowered Spiritualist" },
            },
            loot = {
                { id = 88288, slot = "Back", name = "Soulrender Greatcloak", sources = { [14]=45686 } },
                { id = 144183, slot = "Back", name = "Soulrender Greatcloak", sources = { [14]=84451 } },
                { id = 88286, slot = "Legs", name = "Legguards of the Crimson Magus", sources = { [14]=45684 } },
                { id = 144002, slot = "Legs", name = "Legguards of the Crimson Magus", sources = { [14]=84337 } },
                { id = 88284, slot = "Shoulder", name = "Forgotten Bloodmage Mantle", sources = { [14]=45683 } },
                { id = 144001, slot = "Shoulder", name = "Forgotten Bloodmage Mantle", sources = { [14]=84336 } },
                { id = 88287, slot = "Wrist", name = "Bracers of the Fallen Crusader", sources = { [14]=45685 } },
                { id = 144184, slot = "Wrist", name = "Bracers of the Fallen Crusader", sources = { [14]=84452 } },
            },
        },
        {
            index              = 2,
            name               = "Brother Korloff",
            journalEncounterID = 671,
            achievements       = {
                { id = 6928, name = "Burning Man", meta = true },
            },
            loot = {
                { id = 88290, slot = "Back", name = "Scorched Earth Cloak", sources = { [14]=45688 } },
                { id = 144185, slot = "Back", name = "Scorched Earth Cloak", sources = { [14]=84453 } },
                { id = 88291, slot = "Chest", name = "Korloff's Raiment", sources = { [14]=45689 } },
                { id = 143965, slot = "Chest", name = "Korloff's Raiment", sources = { [14]=84300 } },
                { id = 88292, slot = "Head", name = "Helm of Rising Flame", sources = { [14]=45690 } },
                { id = 144026, slot = "Head", name = "Helm of Rising Flame", sources = { [14]=84361 } },
                { id = 88289, slot = "Two-Hand", name = "Firestorm Greatstaff", sources = { [14]=45687 } },
                { id = 144186, slot = "Two-Hand", name = "Firestorm Greatstaff", sources = { [14]=84454 } },
            },
        },
        {
            index              = 3,
            name               = "High Inquisitor Whitemane",
            journalEncounterID = 674,
            achievements       = {
                { id = 637, name = "Scarlet Monastery" },
                { id = 6761, name = "Heroic: Scarlet Monastery" },
                { id = 6929, name = "And Stay Dead!", meta = true },
                { id = 6896, name = "Scarlet Monastery Challenger" },
                { id = 6911, name = "Scarlet Monastery: Bronze" },
                { id = 6912, name = "Scarlet Monastery: Silver" },
                { id = 6913, name = "Scarlet Monastery: Gold" },
                { id = 19908, name = "Scarlet Monastery" },
                { id = 19909, name = "Heroic: Scarlet Monastery" },
            },
            loot = {
                { id = 88295, slot = "Feet", name = "Dashing Strike Treads", sources = { [14]=45691 } },
                { id = 144003, slot = "Feet", name = "Dashing Strike Treads", sources = { [14]=84338 } },
                { id = 132549, slot = "Feet", name = "Deft Strike Treads", sources = { [14]=76384 } },
                { id = 88303, slot = "Head", name = "Crown of Holy Flame", sources = { [14]=45698 } },
                { id = 144027, slot = "Head", name = "Crown of Holy Flame", sources = { [14]=84362 } },
                { id = 88299, slot = "Head", name = "Whitemane's Embroidered Chapeau", sources = { [14]=45695 } },
                { id = 144028, slot = "Head", name = "Whitemane's Embroidered Chapeau", sources = { [14]=84363 } },
                { id = 88298, slot = "Legs", name = "Leggings of Hallowed Fire", sources = { [14]=45694 } },
                { id = 144004, slot = "Legs", name = "Leggings of Hallowed Fire", sources = { [14]=84339 } },
                { id = 88302, slot = "Shoulder", name = "Incarnadine Scarlet Spaulders", sources = { [14]=45697 } },
                { id = 144005, slot = "Shoulder", name = "Incarnadine Scarlet Spaulders", sources = { [14]=84340 } },
                { id = 88301, slot = "Two-Hand", name = "Greatstaff of Righteousness", sources = { [14]=45696 } },
                { id = 144189, slot = "Two-Hand", name = "Greatstaff of Righteousness", sources = { [14]=84457 } },
                { id = 88297, slot = "Two-Hand", name = "Lightbreaker Greatsword", sources = { [14]=45693 } },
                { id = 144187, slot = "Two-Hand", name = "Lightbreaker Greatsword", sources = { [14]=84455 } },
                { id = 88296, slot = "Waist", name = "Waistplate of Imminent Resurrection", sources = { [14]=45692 } },
                { id = 144188, slot = "Waist", name = "Waistplate of Imminent Resurrection", sources = { [14]=84456 } },
            },
        },
    },
}
