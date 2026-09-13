-------------------------------------------------------------------------------
-- RetroRuns Data -- Zul'Gurub
-- Cataclysm dungeon, Patch 4.1.0  |  instanceID: 859  |  journalInstanceID: 76
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[76] = {
    kind              = "dungeon",
    instanceID        = 859,
    journalInstanceID = 76,
    name              = "Zul'Gurub",
    expansion         = "Cataclysm",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "4.1.0",

    entrance = {
        mapID = 50,
        x     = 0.7225,
        y     = 0.3291,
    },

    bosses = {
        {
            index              = 1,
            name               = "High Priest Venoxis",
            journalEncounterID = 175,
            achievements       = {
                { id = 5743, name = "It's Not Easy Being Green", soloable = "yes" },
            },
            loot = {
                { id = 69603, slot = "Chest", name = "Breastplate of Serenity", sources = { [14]=35514, [15]=35514 } },
                { id = 69601, slot = "Legs", name = "Serpentine Leggings", sources = { [14]=35513, [15]=35513 } },
                { id = 69600, slot = "Waist", name = "Belt of Slithering Serpents", sources = { [14]=35512, [15]=35512 } },
                { id = 69604, slot = "Waist", name = "Coils of Hate", sources = { [14]=35515, [15]=35515 } },
            },
        },
        {
            index              = 2,
            name               = "Bloodlord Mandokir",
            journalEncounterID = 176,
            achievements       = {
                { id = 5762, name = "Ohganot So Fast!", soloable = "yes" },
            },
            loot = {
                { id = 69606, slot = "Back", name = "Hakkari Loa Drape", sources = { [14]=35516, [15]=35516 } },
                { id = 69607, slot = "Ranged", name = "Touch of Discord", sources = { [14]=35517, [15]=35517 } },
                { id = 69609, slot = "Weapon", name = "Bloodlord's Protector", sources = { [14]=35519, [15]=35519 } },
                { id = 69608, slot = "Wrist", name = "Deathcharged Wristguards", sources = { [14]=35518, [15]=35518 } },
            },
            specialLoot = {
                { id = 68823, kind = "mount", name = "Armored Razzashi Raptor" },
            },
        },
        {
            index              = 3,
            name               = "Cache of Madness - Gri'lek",
            journalEncounterID = 177,
            aliases            = { "Edge of Madness" },
            achievements       = {
            },
            loot = {
                { id = 69634, slot = "Feet", name = "Fasc's Preserved Boots", sources = { [14]=35543, [15]=35543 } },
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
            },
        },
        {
            index              = 4,
            name               = "Cache of Madness - Hazza'rah",
            journalEncounterID = 178,
            aliases            = { "Edge of Madness" },
            achievements       = {
            },
            loot = {
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69637, slot = "Ranged", name = "Gurubashi Destroyer", sources = { [14]=35545, [15]=35545 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
                { id = 69636, slot = "Weapon", name = "Thekal's Claws", sources = { [14]=35544, [15]=35544 } },
            },
        },
        {
            index              = 5,
            name               = "Cache of Madness - Renataki",
            journalEncounterID = 179,
            aliases            = { "Edge of Madness" },
            achievements       = {
            },
            loot = {
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
                { id = 69638, slot = "Weapon", name = "Arlokk's Claws", sources = { [14]=35546, [15]=35546 } },
                { id = 69639, slot = "Weapon", name = "Renataki's Soul Slicer", sources = { [14]=35547, [15]=35547 } },
            },
        },
        {
            index              = 6,
            name               = "Cache of Madness - Wushoolay",
            journalEncounterID = 180,
            aliases            = { "Edge of Madness" },
            achievements       = {
            },
            loot = {
                { id = 69641, slot = "Chest", name = "Troll Skull Chestplate", sources = { [14]=35549, [15]=35549 } },
                { id = 69630, slot = "Hands", name = "Handguards of the Tormented", sources = { [14]=35539, [15]=35539 } },
                { id = 69633, slot = "Hands", name = "Plunderer's Gauntlets", sources = { [14]=35542, [15]=35542 } },
                { id = 69640, slot = "Legs", name = "Kilt of Forgotten Rites", sources = { [14]=35548, [15]=35548 } },
                { id = 69632, slot = "Off-hand", name = "Lost Bag of Whammies", sources = { [14]=35541, [15]=35541 } },
                { id = 69631, slot = "Ranged", name = "Zulian Voodoo Stick", sources = { [14]=35540, [15]=35540 } },
            },
        },
        {
            index              = 7,
            name               = "High Priestess Kilnara",
            journalEncounterID = 181,
            achievements       = {
            },
            loot = {
                { id = 69614, slot = "Head", name = "Roaring Mask of Bethekk", sources = { [14]=35523, [15]=35523 } },
                { id = 69613, slot = "Legs", name = "Leggings of the Pride", sources = { [14]=35522, [15]=35522 } },
                { id = 69612, slot = "Shoulder", name = "Claw-Fringe Mantle", sources = { [14]=35521, [15]=35521 } },
                { id = 69611, slot = "Waist", name = "Sash of Anguish", sources = { [14]=35520, [15]=35520 } },
            },
            specialLoot = {
                { id = 68824, kind = "mount", name = "Swift Zulian Panther" },
            },
        },
        {
            index              = 8,
            name               = "Zanzil",
            journalEncounterID = 184,
            achievements       = {
            },
            loot = {
                { id = 69619, slot = "Hands", name = "Bone Plate Handguards", sources = { [14]=35528, [15]=35528 } },
                { id = 69617, slot = "Head", name = "Plumed Medicine Helm", sources = { [14]=35526, [15]=35526 } },
                { id = 69615, slot = "Legs", name = "Zombie Walker Legguards", sources = { [14]=35524, [15]=35524 } },
                { id = 69616, slot = "Shoulder", name = "Spiritbinder Spaulders", sources = { [14]=35525, [15]=35525 } },
                { id = 69618, slot = "Weapon", name = "Zulian Slasher", sources = { [14]=35527, [15]=35527 } },
            },
        },
        {
            index              = 9,
            name               = "Jin'do the Godbreaker",
            journalEncounterID = 185,
            achievements       = {
                { id = 5759, name = "Spirit Twister", soloable = "yes" },
                { id = 5744, name = "Gurubashi Headhunter", soloable = "yes" },
            },
            loot = {
                { id = 69623, slot = "Chest", name = "Vestments of the Soulflayer", sources = { [14]=35532, [15]=35532 } },
                { id = 69622, slot = "Head", name = "The Hexxer's Mask", sources = { [14]=35531, [15]=35531 } },
                { id = 69629, slot = "Off-hand", name = "Shield of the Blood God", sources = { [14]=35538, [15]=35538 } },
                { id = 69627, slot = "Off-hand", name = "Zulian Ward", sources = { [14]=35536, [15]=35536 } },
                { id = 69625, slot = "Ranged", name = "Mandokir's Tribute", sources = { [14]=35534, [15]=35534 } },
                { id = 69628, slot = "Two-Hand", name = "Jeklik's Smasher", sources = { [14]=35537, [15]=35537 } },
                { id = 69626, slot = "Two-Hand", name = "Jin'do's Verdict", sources = { [14]=35535, [15]=35535 } },
                { id = 69624, slot = "Two-Hand", name = "Legacy of Arlokk", sources = { [14]=35533, [15]=35533 } },
                { id = 69620, slot = "Weapon", name = "Twinblade of the Hakkari", sources = { [14]=35529, [15]=35529 } },
                { id = 69621, slot = "Weapon", name = "Twinblade of the Hakkari", sources = { [14]=35530, [15]=35530 } },
            },
        },
    },
}
