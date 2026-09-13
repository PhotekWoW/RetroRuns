-------------------------------------------------------------------------------
-- RetroRuns Data -- De Other Side
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2291  |  journalInstanceID: 1188
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1188] = {
    kind              = "dungeon",
    instanceID        = 2291,
    journalInstanceID = 1188,
    name              = "De Other Side",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 16 },
    patch             = "9.0.1",
    timewalking       = true,

    entrance = {
        mapID = 1565,
        x     = 0.6866,
        y     = 0.6693,
    },

    gloryMeta = {
        id   = 14322,
        name = "Glory of the Shadowlands Hero",
        rewardItemID       = 184183,
        rewardMountSpellID = 344659,
        rewardName         = "Voracious Gorger",
    },

    bosses = {
        {
            index              = 1,
            name               = "Hakkar the Soulflayer",
            journalEncounterID = 2408,
            aliases            = { "Hakkar, the Soulflayer" },
            achievements       = {
            },
            loot = {
                { id = 179322, slot = "Feet", name = "Windscale Moccasins", sources = { [14]=111643, [15]=111643, [16]=111643 } },
                { id = 179325, slot = "Hands", name = "Hakkari Revenant's Grips", sources = { [14]=111646, [15]=111646, [16]=111646 } },
                { id = 179324, slot = "Legs", name = "Soulfeather Breeches", sources = { [14]=111645, [15]=111645, [16]=111645 } },
                { id = 179330, slot = "Two-Hand", name = "Zin'khas, Blade of the Fallen God", sources = { [14]=111650, [15]=111650, [16]=111650 } },
                { id = 179326, slot = "Waist", name = "Girdle of the Soulflayer", sources = { [14]=111647, [15]=111647, [16]=111647 } },
                { id = 179328, slot = "Weapon", name = "Bloodspiller", sources = { [14]=111648, [15]=111648, [16]=111648 } },
            },
        },
        {
            index              = 2,
            name               = "The Manastorms",
            journalEncounterID = 2409,
            achievements       = {
                { id = 14374, name = "Couple's Therapy", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 179335, slot = "Chest", name = "Manastorm's Magnificent Threads", sources = { [14]=111654, [15]=111654, [16]=111654 } },
                { id = 179338, slot = "Feet", name = "Dynamo Doomstompers", sources = { [14]=111657, [15]=111657, [16]=111657 } },
                { id = 179336, slot = "Hands", name = "Rocket Chicken Handlers", sources = { [14]=111655, [15]=111655, [16]=111655 } },
                { id = 179337, slot = "Legs", name = "Techno-Coil Legguards", sources = { [14]=111656, [15]=111656, [16]=111656 } },
                { id = 179339, slot = "Two-Hand", name = "Whizblast Walking Stick", sources = { [14]=111658, [15]=111658, [16]=111658 } },
                { id = 179340, slot = "Weapon", name = "Supercollider", sources = { [14]=111659, [15]=111659, [16]=111659 } },
            },
        },
        {
            index              = 3,
            name               = "Dealer Xy'exa",
            journalEncounterID = 2398,
            achievements       = {
                { id = 14354, name = "Highly Communicable", meta = true, soloable = "no" },
                { id = 14606, name = "Thinking with...", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 179349, slot = "Back", name = "Dealer Xy'exa's Cape", sources = { [14]=111666, [15]=111666, [16]=111666 } },
                { id = 179346, slot = "Chest", name = "Breastplate of Fatal Contrivances", sources = { [14]=111663, [15]=111663, [16]=111663 } },
                { id = 179345, slot = "Feet", name = "Spatial Rift Striders", sources = { [14]=111662, [15]=111662, [16]=111662 } },
                { id = 179348, slot = "Ranged", name = "Xy Cartel Crossbow", sources = { [14]=111665, [15]=111665, [16]=111665 } },
                { id = 179344, slot = "Shoulder", name = "Far Traveler's Shoulderpads", sources = { [14]=111661, [15]=111661, [16]=111661 } },
                { id = 179347, slot = "Two-Hand", name = "Collector's Pulse Staff", sources = { [14]=111664, [15]=111664, [16]=111664 } },
                { id = 179343, slot = "Waist", name = "Sash of Exquisite Acquisitions", sources = { [14]=111660, [15]=111660, [16]=111660 } },
            },
        },
        {
            index              = 4,
            name               = "Mueh'zala",
            journalEncounterID = 2410,
            achievements       = {
            },
            loot = {
                { id = 179353, slot = "Chest", name = "Harness of Twisted Whims", sources = { [14]=111669, [15]=111669, [16]=111669 } },
                { id = 179352, slot = "Feet", name = "Primeval Soul's Ankleguards", sources = { [14]=111668, [15]=111668, [16]=111668 } },
                { id = 179351, slot = "Legs", name = "Mueh'zala's Hexthread Sarong", sources = { [14]=111667, [15]=111667, [16]=111667 } },
                { id = 179354, slot = "Wrist", name = "Reality-Shatter Vambraces", sources = { [14]=111670, [15]=111670, [16]=111670 } },
            },
        },
    },
}
