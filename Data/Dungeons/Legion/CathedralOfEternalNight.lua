-------------------------------------------------------------------------------
-- RetroRuns Data -- Cathedral of Eternal Night
-- Legion dungeon, Patch 7.2.0  |  instanceID: 1677  |  journalInstanceID: 900
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[900] = {
    kind              = "dungeon",
    instanceID        = 1677,
    journalInstanceID = 900,
    name              = "Cathedral of Eternal Night",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    patch             = "7.2.0",

    bosses = {
        {
            index              = 1,
            name               = "Agronox",
            journalEncounterID = 1905,
            achievements       = {
                { id = 11768, name = "Boom Bloom" },
            },
            loot = {
                { id = 144468, slot = "Back", name = "Felpruner's Shroud", sources = { [14]=84580, [15]=84580, [16]=84580 } },
                { id = 144483, slot = "Chest", name = "Spore-Coated Vest", sources = { [14]=84598, [15]=84599, [16]=84598 } },
                { id = 144490, slot = "Feet", name = "Corruption-Fused Stompers", sources = { [14]=84612, [15]=84613, [16]=84612 } },
                { id = 144470, slot = "Hands", name = "Grovetender's Handwraps", sources = { [14]=84584, [15]=84585, [16]=84584 } },
                { id = 144469, slot = "Shoulder", name = "Caretaker's Budding Mantle", sources = { [14]=84582, [15]=84583, [16]=84582 } },
                { id = 144497, slot = "Waist", name = "Petrified Husk Girdle", sources = { [14]=84624, [15]=84625, [16]=84624 } },
                { id = 144491, slot = "Wrist", name = "Choking Vine Bindings", sources = { [14]=84614, [15]=84615, [16]=84614 } },
                { id = 144498, slot = "Wrist", name = "Vambraces of Fel Crust", sources = { [14]=84626, [15]=84627, [16]=84626 } },
            },
        },
        {
            index              = 2,
            name               = "Thrashbite the Scornful",
            journalEncounterID = 1906,
            achievements       = {
                { id = 11769, name = "A Steamy Romance Saga" },
            },
            loot = {
                { id = 144499, slot = "Chest", name = "Tenderized Breastplate", sources = { [14]=84628, [15]=84629, [16]=84628 } },
                { id = 144471, slot = "Feet", name = "Pulverizing Felsoles", sources = { [14]=84586, [15]=84587, [16]=84586 } },
                { id = 144492, slot = "Hands", name = "Chain-Draped Gauntlets", sources = { [14]=84616, [15]=84617, [16]=84616 } },
                { id = 144484, slot = "Legs", name = "Tattered Scornful Leggings", sources = { [14]=84600, [15]=84601, [16]=84600 } },
                { id = 144493, slot = "Shoulder", name = "Link-Lashed Spaulders", sources = { [14]=84618, [15]=84619, [16]=84618 } },
                { id = 144472, slot = "Waist", name = "Thrashbite's Cummerbund", sources = { [14]=84588, [15]=84589, [16]=84588 } },
                { id = 144485, slot = "Wrist", name = "Mo'arg Heavyweight's Wristwraps", sources = { [14]=84602, [15]=84603, [16]=84602 } },
            },
        },
        {
            index              = 3,
            name               = "Domatrax",
            journalEncounterID = 1904,
            achievements       = {
            },
            loot = {
                { id = 144476, slot = "Back", name = "Cloak of the Unending Assault", sources = { [14]=84596, [15]=84596, [16]=84596 } },
                { id = 144495, slot = "Chest", name = "Domatrax's Chain Hauberk", sources = { [14]=84620, [15]=84621, [16]=84620 } },
                { id = 144500, slot = "Feet", name = "Two-Toed Thrashstompers", sources = { [14]=84630, [15]=84631, [16]=84630 } },
                { id = 144488, slot = "Hands", name = "Feaster Hide Gloves", sources = { [14]=84608, [15]=84609, [16]=84608 } },
                { id = 144503, slot = "Head", name = "Helm of Domatrax", sources = { [14]=84636, [15]=84637, [16]=84636 } },
                { id = 144474, slot = "Legs", name = "Sheer Felwoven Hosiery", sources = { [14]=84592, [15]=84593, [16]=84592 } },
                { id = 144489, slot = "Shoulder", name = "Shoulderguards of Legion Domination", sources = { [14]=84610, [15]=84611, [16]=84610 } },
                { id = 144496, slot = "Waist", name = "Burning Chain Waistguard", sources = { [14]=84622, [15]=84623, [16]=84622 } },
                { id = 144475, slot = "Wrist", name = "Dark Mistress' Cuffs", sources = { [14]=84594, [15]=84595, [16]=84594 } },
            },
        },
        {
            index              = 4,
            name               = "Mephistroth",
            journalEncounterID = 1878,
            achievements       = {
                { id = 11700, name = "Cathedral of Eternal Night" },
                { id = 11701, name = "Heroic: Cathedral of Eternal Night" },
                { id = 11702, name = "Mythic: Cathedral of Eternal Night" },
                { id = 11703, name = "Master of Shadows" },
                { id = 60849, name = "Cathedral of Eternal Night" },
                { id = 60850, name = "Heroic: Cathedral of Eternal Night" },
                { id = 60851, name = "Mythic: Cathedral of Eternal Night" },
            },
            loot = {
                { id = 144473, slot = "Chest", name = "Nathrezim Acolyte's Robes", sources = { [14]=84590, [15]=84591, [16]=84590 } },
                { id = 144487, slot = "Feet", name = "Treads of Creeping Shadows", sources = { [14]=84606, [15]=84607, [16]=84606 } },
                { id = 144502, slot = "Hands", name = "Shadowed Grips of the Nathrezim", sources = { [14]=84634, [15]=84635, [16]=84634 } },
                { id = 144494, slot = "Head", name = "Imposing Dreadsoul Headgear", sources = { [14]=84638, [15]=84639, [16]=84638 } },
                { id = 144501, slot = "Shoulder", name = "Dread Commander's Pauldrons", sources = { [14]=84632, [15]=84633, [16]=84632 } },
                { id = 144486, slot = "Waist", name = "Cerulean Shadowfade Belt", sources = { [14]=84604, [15]=84605, [16]=84604 } },
            },
        },
    },
}
