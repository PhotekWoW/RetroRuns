-------------------------------------------------------------------------------
-- RetroRuns Data -- Gundrak
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 604  |  journalInstanceID: 274
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[274] = {
    kind              = "dungeon",
    instanceID        = 604,
    journalInstanceID = 274,
    name              = "Gundrak",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.0.2",

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Slad'ran",
            journalEncounterID = 592,
            achievements       = {
                { id = 2058, name = "Snakes. Why'd It Have To Be Snakes?", meta = true },
            },
            loot = {
                { id = 35584, slot = "Chest", name = "Embroidered Gown of Zul'Drak", sources = { [14]=16522 } },
                { id = 37629, slot = "Feet", name = "Slithering Slippers", sources = { [14]=17908 } },
                { id = 35585, slot = "Legs", name = "Cannibal's Legguards", sources = { [14]=16523 } },
                { id = 37626, slot = "Ranged", name = "Wand of Sseratus", sources = { [14]=17905 } },
                { id = 37627, slot = "Shoulder", name = "Snake Den Spaulders", sources = { [14]=17906 } },
                { id = 35583, slot = "Two-Hand", name = "Witch Doctor's Wildstaff", sources = { [14]=16521 } },
                { id = 157578, slot = "Waist", name = "Belt of Vile Concoctions", sources = { [14]=93769 } },
                { id = 37628, slot = "Waist", name = "Slad'ran's Coiled Cord", sources = { [14]=17907 } },
            },
        },
        {
            index              = 2,
            name               = "Drakkari Colossus",
            journalEncounterID = 593,
            achievements       = {
            },
            loot = {
                { id = 35592, slot = "Chest", name = "Hauberk of Totemic Mastery", sources = { [14]=16528 } },
                { id = 37636, slot = "Head", name = "Helm of Cheated Fate", sources = { [14]=17915 } },
                { id = 35590, slot = "Ranged", name = "Drakkari Hunting Bow", sources = { [14]=16526 } },
                { id = 37635, slot = "Shoulder", name = "Pauldrons of the Colossus", sources = { [14]=17914 } },
                { id = 35591, slot = "Shoulder", name = "Shoulderguards of the Ice Troll", sources = { [14]=16527 } },
                { id = 37637, slot = "Waist", name = "Living Mojo Belt", sources = { [14]=17916 } },
                { id = 127537, slot = "Waist", name = "Snowmelt Silken Cinch", sources = { [14]=72652 }, timewalkingOnly = true },
                { id = 37634, slot = "Wrist", name = "Bracers of the Divine Elemental", sources = { [14]=17913 } },
            },
        },
        {
            index              = 3,
            name               = "Moorabi",
            journalEncounterID = 594,
            achievements       = {
                { id = 2040, name = "Less-rabi", meta = true },
            },
            loot = {
                { id = 157584, slot = "Back", name = "Drape of Moorabi", sources = { [14]=93776 } },
                { id = 37630, slot = "Back", name = "Shroud of Moorabi", sources = { [14]=17909 } },
                { id = 35588, slot = "Chest", name = "Forlorn Breastplate of War", sources = { [14]=16525 } },
                { id = 37632, slot = "Feet", name = "Mojo Frenzy Greaves", sources = { [14]=17911 } },
                { id = 37633, slot = "Head", name = "Ground Tremor Helm", sources = { [14]=17912 } },
                { id = 127560, slot = "Waist", name = "Belt of Tasseled Lanterns", sources = { [14]=72672 }, timewalkingOnly = true },
                { id = 37631, slot = "Weapon", name = "Fist of the Deity", sources = { [14]=17910 } },
                { id = 35587, slot = "Weapon", name = "Frozen Scepter of Necromancy", sources = { [14]=16524 } },
            },
        },
        {
            index              = 4,
            name               = "Eck the Ferocious",
            journalEncounterID = 595,
            achievements       = {
            },
            loot = {
                { id = 43310, slot = "Chest", name = "Engraved Chestplate of Eck", sources = { [14]=20956 } },
                { id = 43312, slot = "Feet", name = "Gorloc Muddy Footwraps", sources = { [14]=20958 } },
                { id = 43311, slot = "Head", name = "Helmet of the Shrine", sources = { [14]=20957 } },
                { id = 43313, slot = "Legs", name = "Leggings of the Ruins Dweller", sources = { [14]=20959 } },
            },
        },
        {
            index              = 5,
            name               = "Gal'darah",
            journalEncounterID = 596,
            achievements       = {
                { id = 1864, name = "What the Eck?", meta = true },
                { id = 2152, name = "Share The Love" },
                { id = 484, name = "Gundrak" },
                { id = 495, name = "Heroic: Gundrak" },
                { id = 39930, name = "Gundrak (char specific hidden copy)" },
            },
            loot = {
                { id = 127559, slot = "Back", name = "Cloak of Bloodied Waters", sources = { [14]=72671 }, timewalkingOnly = true },
                { id = 43305, slot = "Back", name = "Shroud of Akali", sources = { [14]=20955 } },
                { id = 37641, slot = "Chest", name = "Arcane Flame Altar-Garb", sources = { [14]=17919 } },
                { id = 37640, slot = "Feet", name = "Boots of Transformation", sources = { [14]=17918 } },
                { id = 37639, slot = "Hands", name = "Grips of the Beast God", sources = { [14]=17917 } },
                { id = 37645, slot = "Hands", name = "Horn-Tipped Gauntlets", sources = { [14]=17922 } },
                { id = 37644, slot = "Legs", name = "Gored Hide Legguards", sources = { [14]=17921 } },
                { id = 37643, slot = "Waist", name = "Sash of Blood Removal", sources = { [14]=17920 } },
                { id = 127536, slot = "Wrist", name = "Steel Bear Trap Bracers", sources = { [14]=72651 }, timewalkingOnly = true },
            },
        },
    },
}
