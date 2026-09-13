-------------------------------------------------------------------------------
-- RetroRuns Data -- Siege of Boralus
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1822  |  journalInstanceID: 1023
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1023] = {
    kind              = "dungeon",
    instanceID        = 1822,
    journalInstanceID = 1023,
    name              = "Siege of Boralus",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "8.0.1",

    entrance = {
        mapID = 895,
        x     = 0.8831,
        y     = 0.5104,
    },

    gloryMeta = {
        id   = 12812,
        name = "Glory of the Wartorn Hero",
        rewardItemID       = 161215,
        rewardName         = "Reins of the Obsidian Krolusk",
    },

    bosses = {
        {
            index              = 1,
            name               = "Chopper Redhook",
            journalEncounterID = 2132,
            factionEncounters  = {
                Alliance = { name = "Sergeant Bainbridge", journalEncounterID = 2133 },
                Horde    = { name = "Chopper Redhook", journalEncounterID = 2132 },
            },
            -- Journal carries 3 rows for this encounter; loot unioned.
            achievements       = {
            },
            loot = {
                { id = 159278, slot = "Feet", name = "Slippers of Unwavering Faith", sources = { [14]=95789 } },
                { id = 159251, slot = "Feet", name = "Top-Sail Footwraps", sources = { [14]=95771, [15]=95771, [16]=95771 } },
                { id = 159968, slot = "Hands", name = "Gloves of the Iron Reavers", sources = { [14]=98570, [15]=98570, [16]=98570 } },
                { id = 159328, slot = "Hands", name = "Wharf Warden's Gloves", sources = { [14]=98471 } },
                { id = 159427, slot = "Legs", name = "Legplates of the Irontide Raider", sources = { [14]=95675, [15]=95675, [16]=95675 } },
                { id = 159411, slot = "Legs", name = "Legplates of the Maritime Guard", sources = { [14]=95631 } },
                { id = 159969, slot = "Legs", name = "Powdershot Leggings", sources = { [14]=96008, [15]=96008, [16]=96008 } },
                { id = 159367, slot = "Legs", name = "Unstoppable Zealot's Legplates", sources = { [14]=95853 } },
                { id = 159972, slot = "Two-Hand", name = "Mutineer's Fate", sources = { [14]=96014, [15]=96014, [16]=96014 } },
                { id = 159647, slot = "Two-Hand", name = "Siegebreaker's Halberd", sources = { [14]=95500 } },
                { id = 159245, slot = "Waist", name = "Cord of the Pious Warder", sources = { [14]=95764 } },
                { id = 159965, slot = "Waist", name = "Redhook's Cummerbund", sources = { [14]=96000, [15]=96000, [16]=96000 } },
                { id = 159648, slot = "Weapon", name = "Bainbridge's Blackjack", sources = { [14]=95485 } },
                { id = 159973, slot = "Weapon", name = "Boarder's Billy Club", sources = { [14]=96017, [15]=96017, [16]=96017 } },
            },
        },
        {
            index              = 2,
            name               = "Dread Captain Lockwood",
            journalEncounterID = 2173,
            achievements       = {
                { id = 12727, name = "Stand by Me", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 159320, slot = "Feet", name = "Besieger's Deckstalkers", sources = { [15]=98465, [16]=98465 } },
                { id = 159379, slot = "Feet", name = "Sure-Foot Sabatons", sources = { [15]=95862, [16]=95862 } },
                { id = 159237, slot = "Hands", name = "Captain's Dustfinders", sources = { [15]=95754, [16]=95754 } },
                { id = 159429, slot = "Hands", name = "Rope-Scored Gauntlets", sources = { [15]=95679, [16]=95679 } },
                { id = 159250, slot = "Legs", name = "Powder Monkey's Leggings", sources = { [15]=95770, [16]=95770 } },
                { id = 159434, slot = "Waist", name = "Cannoneer's Toolbelt", sources = { [15]=95684, [16]=95684 } },
                { id = 159309, slot = "Waist", name = "Port Pillager's Belt", sources = { [15]=98454, [16]=98454 } },
                { id = 159649, slot = "Weapon", name = "Saber of Dread Pirate Lockwood", sources = { [15]=95436, [16]=95436 } },
                { id = 159372, slot = "Wrist", name = "Dread Captain's Irons", sources = { [15]=95855, [16]=95855 } },
            },
        },
        {
            index              = 3,
            name               = "Hadal Darkfathom",
            journalEncounterID = 2134,
            achievements       = {
            },
            loot = {
                { id = 159428, slot = "Feet", name = "Ballast Sinkers", sources = { [15]=95677, [16]=95677 } },
                { id = 159322, slot = "Legs", name = "Seawalker's Pantaloons", sources = { [15]=98469, [16]=98469 } },
                { id = 159650, slot = "Two-Hand", name = "Dismembered Submersible Claw", sources = { [15]=95892, [16]=95892 } },
                { id = 159386, slot = "Waist", name = "Anchor Chain Girdle", sources = { [15]=95864, [16]=95864 } },
            },
        },
        {
            index              = 4,
            name               = "Viq'Goth",
            journalEncounterID = 2140,
            achievements       = {
                { id = 12726, name = "A Fish Out of Water", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 159314, slot = "Chest", name = "Cephalohide Jacket", sources = { [14]=98462, [15]=98462, [16]=98462 } },
                { id = 231822, slot = "Chest", name = "Cephalohide Jacket", sources = { [15]=229805, [16]=229805 } },
                { id = 159416, slot = "Chest", name = "Harpooner's Plate Cuirass", sources = { [14]=95667, [15]=95667, [16]=95667 } },
                { id = 231827, slot = "Chest", name = "Harpooner's Plate Cuirass", sources = { [15]=229810, [16]=229810 } },
                { id = 159362, slot = "Chest", name = "Tri-Heart Chestguard", sources = { [14]=95846, [15]=95846, [16]=95846 } },
                { id = 231825, slot = "Chest", name = "Tri-Heart Chestguard", sources = { [15]=229808, [16]=229808 } },
                { id = 159310, slot = "Head", name = "Circlet of the Enveloping Leviathan", sources = { [14]=98456, [15]=98456, [16]=98456 } },
                { id = 231824, slot = "Head", name = "Circlet of the Enveloping Leviathan", sources = { [15]=229807, [16]=229807 } },
                { id = 159252, slot = "Head", name = "Grasping Crown of the Deep", sources = { [14]=95773, [15]=95773, [16]=95773 } },
                { id = 231818, slot = "Head", name = "Grasping Crown of the Deep", sources = { [15]=229804, [16]=229804 } },
                { id = 159376, slot = "Shoulder", name = "Hook-Barbed Spaulders", sources = { [14]=95859, [15]=95859, [16]=95859 } },
                { id = 231826, slot = "Shoulder", name = "Hook-Barbed Spaulders", sources = { [15]=229809, [16]=229809 } },
                { id = 159431, slot = "Shoulder", name = "Kraken Shell Pauldrons", sources = { [14]=95683, [15]=95683, [16]=95683 } },
                { id = 231830, slot = "Shoulder", name = "Kraken Shell Pauldrons", sources = { [15]=229811, [16]=229811 } },
                { id = 159651, slot = "Weapon", name = "Coral-Edged Crescent", sources = { [14]=96075, [15]=96075, [16]=96075 } },
                { id = 159256, slot = "Wrist", name = "Iron-Kelp Wristwraps", sources = { [14]=95775, [15]=95775, [16]=95775 } },
            },
        },
    },
}
