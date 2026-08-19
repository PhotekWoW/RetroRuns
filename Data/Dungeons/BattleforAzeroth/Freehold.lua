-------------------------------------------------------------------------------
-- RetroRuns Data -- Freehold
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1754  |  journalInstanceID: 1001
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1001] = {
    kind              = "dungeon",
    instanceID        = 1754,
    journalInstanceID = 1001,
    name              = "Freehold",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.0.1",

    gloryMeta = {
        id   = 12812,
        name = "Glory of the Wartorn Hero",
        rewardItemID       = 161215,
        rewardName         = "Reins of the Obsidian Krolusk",
    },

    bosses = {
        {
            index              = 1,
            name               = "Skycap'n Kragg",
            journalEncounterID = 2102,
            achievements       = {
                { id = 12548, name = "I'm in Charge Now!", meta = true },
            },
            loot = {
                { id = 155884, slot = "Back", name = "Parrotfeather Cloak", sources = { [14]=92528, [15]=99294, [16]=99295 } },
                { id = 155862, slot = "Feet", name = "Kragg's Rigging Scalers", sources = { [14]=92512, [15]=95575, [16]=95576 } },
                { id = 159353, slot = "Waist", name = "Chain-Linked Safety Cord", sources = { [14]=95123, [15]=95841, [16]=95842 } },
                { id = 158360, slot = "Waist", name = "Sharkbait Harness Girdle", sources = { [14]=94372, [15]=94373, [16]=95660 } },
                { id = 159633, slot = "Weapon", name = "Sharkbait's Fishhook", sources = { [14]=95412, [15]=95413, [16]=95797 } },
                { id = 159227, slot = "Wrist", name = "Silk Cuffs of the Skycap'n", sources = { [14]=94961, [15]=95751, [16]=95752 } },
            },
        },
        {
            index              = 2,
            name               = "Council o' Captains",
            journalEncounterID = 2093,
            achievements       = {
            },
            loot = {
                { id = 158351, slot = "Feet", name = "Dashing Bilge Rat Shoes", sources = { [14]=94354, [15]=94355, [16]=95750 } },
                { id = 159297, slot = "Legs", name = "Silver-Trimmed Breeches", sources = { [14]=95050, [15]=98448, [16]=98449 } },
                { id = 159130, slot = "Ranged", name = "Captain's Diplomacy", sources = { [14]=94876, [15]=95463, [16]=95464 } },
                { id = 158346, slot = "Waist", name = "Sailcloth Waistband", sources = { [14]=94347, [15]=95748, [16]=95749 } },
                { id = 159132, slot = "Weapon", name = "Jolly's Boot Dagger", sources = { [14]=94878, [15]=95482, [16]=95483 } },
                { id = 158311, slot = "Wrist", name = "Concealed Fencing Plates", sources = { [14]=94316, [15]=94317, [16]=95659 } },
                { id = 159356, slot = "Wrist", name = "Raoul's Barrelhook Bracers", sources = { [14]=95128, [15]=95129, [16]=98395 } },
            },
        },
        {
            index              = 3,
            name               = "Ring of Booty",
            journalEncounterID = 2094,
            achievements       = {
            },
            loot = {
                { id = 158356, slot = "Feet", name = "Shell-Kickers", sources = { [14]=94364, [15]=94365, [16]=95836 } },
                { id = 155892, slot = "Hands", name = "Bite-Resistant Chain Gloves", sources = { [14]=92536, [15]=95834, [16]=95835 } },
                { id = 155891, slot = "Hands", name = "Greasy Bacon-Grabbers", sources = { [14]=92535, [15]=95742, [16]=95743 } },
                { id = 155889, slot = "Hands", name = "Sharkhide Grips", sources = { [14]=92533, [15]=98440, [16]=98441 } },
                { id = 155890, slot = "Hands", name = "Sharktooth-Knuckled Grips", sources = { [14]=92534, [15]=95657, [16]=95658 } },
                { id = 158302, slot = "Legs", name = "Chum-Coated Leggings", sources = { [14]=94298, [15]=94299, [16]=95745 } },
                { id = 158361, slot = "Legs", name = "Sharkwater Waders", sources = { [14]=94374, [15]=94375, [16]=95661 } },
                { id = 159634, slot = "Two-Hand", name = "Jeweled Sharksplitter", sources = { [14]=95414, [15]=95515, [16]=95516 } },
                { id = 158305, slot = "Wrist", name = "Sea Dog's Cuffs", sources = { [14]=94304, [15]=94305, [16]=98442 } },
            },
        },
        {
            index              = 4,
            name               = "Harlan Sweete",
            journalEncounterID = 2095,
            achievements       = {
                { id = 12831, name = "Freehold" },
                { id = 12832, name = "Heroic: Freehold" },
                { id = 12833, name = "Mythic: Freehold" },
                { id = 12998, name = "That Sweete Booty", meta = true },
            },
            loot = {
                { id = 158301, slot = "Chest", name = "Ruffled Poet Blouse", sources = { [14]=94296, [15]=94297, [16]=95744 } },
                { id = 155888, slot = "Head", name = "Irontide Captain's Hat", sources = { [14]=92532, [15]=98438, [16]=98439 } },
                { id = 155885, slot = "Head", name = "Sea-Brawler's Greathelm", sources = { [14]=92529, [15]=95655, [16]=95656 } },
                { id = 155886, slot = "Head", name = "Smartly Plumed Cap", sources = { [14]=92530, [15]=95740, [16]=95741 } },
                { id = 155887, slot = "Head", name = "Sweete's Jeweled Headgear", sources = { [14]=92531, [15]=95832, [16]=95833 } },
                { id = 159352, slot = "Shoulder", name = "Gaping Maw Shoulderguard", sources = { [14]=95122, [15]=95122, [16]=95122 } },
                { id = 159299, slot = "Shoulder", name = "Gold-Tasseled Epaulets", sources = { [14]=95052, [15]=95053, [16]=95589 } },
                { id = 159407, slot = "Shoulder", name = "Lockjaw Shoulderplate", sources = { [14]=95196, [15]=95196, [16]=95196 } },
                { id = 159635, slot = "Weapon", name = "Bloody Tideturner", sources = { [14]=95415, [15]=95416, [16]=95417 } },
            },
            specialLoot = {
                { id = 246421, kind = "decor", name = "Stolen Ironforge Seat", decorID = 2238 },
                { id = 159842, kind = "mount", name = "Sharkbait's Favorite Crackers" },
            },
        },
    },
}
