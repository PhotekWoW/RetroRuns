-------------------------------------------------------------------------------
-- RetroRuns Data -- Atal'Dazar
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1763  |  journalInstanceID: 968
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[968] = {
    kind              = "dungeon",
    instanceID        = 1763,
    journalInstanceID = 968,
    name              = "Atal'Dazar",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.0.1",

    bosses = {
        {
            index              = 1,
            name               = "Priestess Alun'za",
            journalEncounterID = 2082,
            achievements       = {
            },
            loot = {
                { id = 155861, slot = "Feet", name = "Embellished Ritual Sabatons", sources = { [14]=92511, [15]=95616, [16]=95617 } },
                { id = 158313, slot = "Legs", name = "Legplates of Beaten Gold", sources = { [14]=94320, [15]=94321, [16]=95626 } },
                { id = 158322, slot = "Off-hand", name = "Aureus Vessel", sources = { [14]=95525, [15]=95526, [16]=95527 } },
                { id = 158321, slot = "Ranged", name = "Wand of Zealous Purification", sources = { [14]=94325, [15]=94326, [16]=95498 } },
                { id = 158306, slot = "Waist", name = "Belt of Gleaming Determination", sources = { [14]=94306, [15]=94307, [16]=95580 } },
                { id = 158347, slot = "Waist", name = "Cincture of Glittering Gold", sources = { [14]=94348, [15]=98388, [16]=98389 } },
                { id = 158309, slot = "Wrist", name = "Wristlinks of Alchemical Transfusion", sources = { [14]=94312, [15]=94313, [16]=98383 } },
            },
        },
        {
            index              = 2,
            name               = "Vol'kaal",
            journalEncounterID = 2036,
            achievements       = {
            },
            loot = {
                { id = 158375, slot = "Back", name = "Drape of the Loyal Vassal", sources = { [14]=94392, [15]=97055, [16]=97056 } },
                { id = 158317, slot = "Hands", name = "Gauntlets of Eternal Service", sources = { [14]=94324, [15]=98384, [16]=98385 } },
                { id = 159445, slot = "Hands", name = "Grips of the Everlasting Guardian", sources = { [14]=95254, [15]=95736, [16]=95737 } },
                { id = 155869, slot = "Legs", name = "Shambling Berserker's Leggings", sources = { [14]=92519, [15]=95577, [16]=95578 } },
                { id = 159632, slot = "Weapon", name = "Adulation Enforcer", sources = { [14]=95411, [15]=95490, [16]=95491 } },
                { id = 158348, slot = "Wrist", name = "Wraps of Everliving Fealty", sources = { [14]=94349, [15]=95544, [16]=95545 } },
            },
        },
        {
            index              = 3,
            name               = "Rezan",
            journalEncounterID = 2083,
            achievements       = {
            },
            loot = {
                { id = 158303, slot = "Feet", name = "Devilsaur Worshiper's Sandals", sources = { [14]=94300, [15]=94301, [16]=95541 } },
                { id = 155868, slot = "Legs", name = "Kilt of Fanatical Consumption", sources = { [14]=92518, [15]=98377, [16]=98378 } },
                { id = 158713, slot = "Off-hand", name = "Disc of Indomitable Will", sources = { [14]=94668, [15]=94669, [16]=94670 } },
                { id = 158711, slot = "Ranged", name = "Hallowed Ossein Longbow", sources = { [14]=94665, [15]=94666, [16]=94667 } },
                { id = 160269, slot = "Weapon", name = "Soulrending Claw", sources = { [14]=96264, [15]=96265, [16]=96266 } },
                { id = 160214, slot = "Wrist", name = "Venerated Raptorhide Bindings", sources = { [14]=96220, [15]=96221, [16]=96222 } },
            },
        },
        {
            index              = 4,
            name               = "Yazma",
            journalEncounterID = 2030,
            achievements       = {
                { id = 12824, name = "Atal'Dazar" },
                { id = 12825, name = "Heroic: Atal'Dazar" },
                { id = 12826, name = "Mythic: Atal'Dazar" },
            },
            loot = {
                { id = 159233, slot = "Chest", name = "Loa Betrayer's Vestments", sources = { [14]=94967, [15]=94968, [16]=95554 } },
                { id = 211405, slot = "Chest", name = "Loa Betrayer's Vestments", sources = { [14]=194120, [15]=194120, [16]=194120 }, mythicPlusOnly = true },
                { id = 155860, slot = "Chest", name = "Spymaster's Wrap", sources = { [14]=92510, [15]=95573, [16]=95574 } },
                { id = 211404, slot = "Chest", name = "Spymaster's Wrap", sources = { [14]=194119, [15]=194119, [16]=194119 }, mythicPlusOnly = true },
                { id = 158308, slot = "Feet", name = "Souldrifting Sabatons", sources = { [14]=94310, [15]=94311, [16]=98382 } },
                { id = 159358, slot = "Head", name = "Coif of the Court Spider", sources = { [14]=95131, [15]=98398, [16]=98399 } },
                { id = 211402, slot = "Head", name = "Coif of the Court Spider", sources = { [14]=194117, [15]=194117, [16]=194117 }, mythicPlusOnly = true },
                { id = 158315, slot = "Head", name = "Secret Spinner's Miter", sources = { [14]=94322, [15]=95542, [16]=95543 } },
                { id = 211401, slot = "Head", name = "Secret Spinner's Miter", sources = { [14]=194116, [15]=194116, [16]=194116 }, mythicPlusOnly = true },
                { id = 155866, slot = "Head", name = "Soulspun Casque", sources = { [14]=92516, [15]=95620, [16]=95621 } },
                { id = 211403, slot = "Head", name = "Soulspun Casque", sources = { [14]=194118, [15]=194118, [16]=194118 }, mythicPlusOnly = true },
                { id = 158304, slot = "Shoulder", name = "Mantle of Fastidious Machinations", sources = { [14]=94302, [15]=94303, [16]=95579 } },
                { id = 158323, slot = "Weapon", name = "Soulrender's Fang", sources = { [14]=94328, [15]=94329, [16]=95469 } },
                { id = 160212, slot = "Wrist", name = "Shadowshroud Vambraces", sources = { [14]=96215, [15]=96216, [16]=96217 } },
            },
        },
    },
}
