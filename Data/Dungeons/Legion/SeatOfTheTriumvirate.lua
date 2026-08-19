-------------------------------------------------------------------------------
-- RetroRuns Data -- Seat of the Triumvirate
-- Legion dungeon, Patch 7.3.0  |  instanceID: 1753  |  journalInstanceID: 945
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[945] = {
    kind              = "dungeon",
    instanceID        = 1753,
    journalInstanceID = 945,
    name              = "Seat of the Triumvirate",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    patch             = "7.3.0",

    bosses = {
        {
            index              = 1,
            name               = "Zuraal the Ascended",
            journalEncounterID = 1979,
            achievements       = {
                { id = 12004, name = "Welcome the Void" },
            },
            loot = {
                { id = 151329, slot = "Chest", name = "Breastplate of the Dark Touch", sources = { [14]=89373, [15]=89374, [16]=89373 } },
                { id = 151320, slot = "Feet", name = "Void-Coated Stompers", sources = { [14]=89355, [15]=89356, [16]=89355 } },
                { id = 151300, slot = "Hands", name = "Handwraps of the Ascended", sources = { [14]=89328, [15]=89329, [16]=89328 } },
                { id = 151336, slot = "Head", name = "Voidlashed Hood", sources = { [14]=89385, [15]=89386, [16]=89385 } },
                { id = 151304, slot = "Legs", name = "Subjugator's Leggings", sources = { [14]=89336, [15]=89337, [16]=89336 } },
                { id = 151331, slot = "Shoulder", name = "Pauldrons of the Broken", sources = { [14]=89377, [15]=89378, [16]=89377 } },
                { id = 258514, slot = "Two-Hand", name = "Umbral Spire of Zuraal", sources = { [14]=301468, [15]=301468, [16]=301468 } },
                { id = 151326, slot = "Waist", name = "Waistguard of Bound Energy", sources = { [14]=89367, [15]=89368, [16]=89367 } },
                { id = 151315, slot = "Wrist", name = "Bracers of Dark Binding", sources = { [14]=89345, [15]=89346, [16]=89345 } },
            },
        },
        {
            index              = 2,
            name               = "Saprish",
            journalEncounterID = 1980,
            achievements       = {
                { id = 12005, name = "Let it All Out" },
            },
            loot = {
                { id = 151303, slot = "Chest", name = "Voidbender Robe", sources = { [14]=89334, [15]=89335, [16]=89334 } },
                { id = 151330, slot = "Feet", name = "Trap Jammers", sources = { [14]=89375, [15]=89376, [16]=89375 } },
                { id = 151318, slot = "Hands", name = "Gloves of the Dark Shroud", sources = { [14]=89351, [15]=89352, [16]=89351 } },
                { id = 151337, slot = "Head", name = "Shadow-Weaver's Crown", sources = { [14]=89387, [15]=89388, [16]=89387 } },
                { id = 151314, slot = "Legs", name = "Shifting Stalker Hide Pants", sources = { [14]=89343, [15]=89344, [16]=89343 } },
                { id = 258516, slot = "Ranged", name = "Wand of Saprish's Gaze", sources = { [14]=301469, [15]=301469, [16]=301469 } },
                { id = 151323, slot = "Shoulder", name = "Pauldrons of the Void Hunter", sources = { [14]=89361, [15]=89362, [16]=89361 } },
                { id = 151327, slot = "Waist", name = "Girdle of the Shadowguard", sources = { [14]=89369, [15]=89370, [16]=89369 } },
                { id = 151321, slot = "Wrist", name = "Darkfang Scale Wristguards", sources = { [14]=89357, [15]=89358, [16]=89357 } },
            },
        },
        {
            index              = 3,
            name               = "Viceroy Nezhar",
            journalEncounterID = 1981,
            achievements       = {
            },
            loot = {
                { id = 151325, slot = "Chest", name = "Void-Linked Robe", sources = { [14]=89365, [15]=89366, [16]=89365 } },
                { id = 151317, slot = "Feet", name = "Footpads of Seeping Dread", sources = { [14]=89349, [15]=89350, [16]=89349 } },
                { id = 151332, slot = "Hands", name = "Voidclaw Gauntlets", sources = { [14]=89379, [15]=89380, [16]=89379 } },
                { id = 151333, slot = "Head", name = "Crown of the Dark Envoy", sources = { [14]=89381, [15]=89382, [16]=89381 } },
                { id = 151338, slot = "Legs", name = "Leggings of Shifting Darkness", sources = { [14]=89389, [15]=89390, [16]=89389 } },
                { id = 258523, slot = "Off-hand", name = "Nezhar's Netherclaw", sources = { [14]=301470, [15]=301470, [16]=301470 } },
                { id = 151299, slot = "Shoulder", name = "Viceroy's Umbral Mantle", sources = { [14]=89326, [15]=89327, [16]=89326 } },
                { id = 151316, slot = "Waist", name = "Cinch of the Umbral Lasher", sources = { [14]=89347, [15]=89348, [16]=89347 } },
                { id = 258524, slot = "Weapon", name = "Grips of the Dark Viceroy", sources = { [14]=301471, [15]=301471, [16]=301471 } },
                { id = 151305, slot = "Wrist", name = "Entropic Wristwraps", sources = { [14]=89338, [15]=89339, [16]=89338 } },
            },
        },
        {
            index              = 4,
            name               = "L'ura",
            journalEncounterID = 1982,
            achievements       = {
                { id = 12007, name = "Heroic: Seat of the Triumvirate" },
                { id = 12008, name = "Mythic: Seat of the Triumvirate" },
                { id = 12009, name = "Darker Side" },
                { id = 60852, name = "Heroic: Seat of the Triumvirate" },
                { id = 60853, name = "Mythic: Seat of the Triumvirate" },
            },
            loot = {
                { id = 151313, slot = "Chest", name = "Vest of the Void's Embrace", sources = { [14]=89341, [15]=89342, [16]=89341 } },
                { id = 151301, slot = "Feet", name = "Slippers of Growing Despair", sources = { [14]=89330, [15]=89331, [16]=89330 } },
                { id = 151322, slot = "Hands", name = "Void-Touched Grips", sources = { [14]=89359, [15]=89360, [16]=89359 } },
                { id = 151324, slot = "Head", name = "Helm of Shadowy Descent", sources = { [14]=89363, [15]=89364, [16]=89363 } },
                { id = 151339, slot = "Legs", name = "Legplates of Ultimate Sacrifice", sources = { [14]=89391, [15]=89392, [16]=89391 } },
                { id = 151319, slot = "Shoulder", name = "Twilight's Edge Spaulders", sources = { [14]=89353, [15]=89354, [16]=89353 } },
                { id = 151302, slot = "Waist", name = "Cord of Unraveling Reality", sources = { [14]=89332, [15]=89333, [16]=89332 } },
                { id = 258525, slot = "Weapon", name = "Scepter of the Endless Night", sources = { [14]=301472, [15]=301472, [16]=301472 } },
                { id = 151328, slot = "Wrist", name = "Vambraces of Lost Hope", sources = { [14]=89371, [15]=89372, [16]=89371 } },
            },
            specialLoot = {
                { id = 241044, kind = "decor", name = "Argussian Crate", decorID = 926 },
            },
        },
    },
}
