-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Valor
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1477  |  journalInstanceID: 721
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[721] = {
    kind              = "dungeon",
    instanceID        = 1477,
    journalInstanceID = 721,
    name              = "Halls of Valor",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    patch             = "7.0.3",

    gloryMeta = {
        id   = 11163,
        name = "Glory of the Legion Hero",
        rewardItemID       = 141217,
        rewardMountSpellID = 225765,
        rewardName         = "Leyfeather Hippogryph",
    },

    bosses = {
        {
            index              = 1,
            name               = "Hymdall",
            journalEncounterID = 1485,
            achievements       = {
            },
            loot = {
                { id = 134179, slot = "Chest", name = "Skoldiir Breastplate", sources = { [14]=77483, [15]=77483, [16]=77483 } },
                { id = 136774, slot = "Feet", name = "Cushioned Treads of Glory", sources = { [14]=78629, [15]=80026, [16]=78629 } },
                { id = 133628, slot = "Hands", name = "Battleborne Sentinel Gauntlets", sources = { [14]=76866, [15]=79935, [16]=76866 } },
                { id = 134216, slot = "Head", name = "Bonespeaker Cowl", sources = { [14]=77510, [15]=77510, [16]=77510 } },
                { id = 134194, slot = "Legs", name = "Biornskin Leggings", sources = { [14]=77495, [15]=77495, [16]=77495 } },
                { id = 134213, slot = "Shoulder", name = "Tideskorn Mantle", sources = { [14]=77507, [15]=77507, [16]=77507 } },
                { id = 133805, slot = "Waist", name = "Thundercaller's Chain", sources = { [14]=76928, [15]=80121, [16]=76928 } },
                { id = 201997, slot = "Weapon", name = "Key to the Halls", sources = { [14]=184051, [15]=184051, [16]=184051 }, mythicPlusOnly = true },
                { id = 133621, slot = "Wrist", name = "Adorned Guardian's Bracers", sources = { [14]=76859, [15]=80060, [16]=76859 } },
            },
        },
        {
            index              = 2,
            name               = "Hyrja",
            journalEncounterID = 1486,
            achievements       = {
            },
            loot = {
                { id = 134219, slot = "Chest", name = "Bonespeaker Robes", sources = { [14]=77513, [15]=77513, [16]=77513 } },
                { id = 133622, slot = "Chest", name = "Thunderfused Val'kyr Hauberk", sources = { [14]=76860, [15]=80114, [16]=76860 } },
                { id = 136772, slot = "Feet", name = "Valkyra Protector Greatboots", sources = { [14]=78627, [15]=79966, [16]=78627 } },
                { id = 134209, slot = "Hands", name = "Tideskorn Gauntlets", sources = { [14]=77503, [15]=77503, [16]=77503 } },
                { id = 134196, slot = "Head", name = "Biornskin Hood", sources = { [14]=77497, [15]=77497, [16]=77497 } },
                { id = 133620, slot = "Shoulder", name = "Amice of the Enlightened", sources = { [14]=76858, [15]=80059, [16]=76858 } },
                { id = 133613, slot = "Waist", name = "Solsten's Arcing Runecord", sources = { [14]=76851, [15]=79999, [16]=76851 } },
                { id = 134186, slot = "Wrist", name = "Skoldiir Bracers", sources = { [14]=77490, [15]=77490, [16]=77490 } },
            },
        },
        {
            index              = 3,
            name               = "Fenryr",
            journalEncounterID = 1487,
            achievements       = {
            },
            loot = {
                { id = 133639, slot = "Back", name = "Goldscar Pelt", sources = { [14]=76872, [15]=80804, [16]=76872 } },
                { id = 133615, slot = "Chest", name = "Hide of Fenryr", sources = { [14]=76853, [15]=80054, [16]=76853 } },
                { id = 133609, slot = "Hands", name = "Silken Bloodscent Gloves", sources = { [14]=76847, [15]=79995, [16]=76847 } },
                { id = 136773, slot = "Waist", name = "Greatbelt of Alpha Dominance", sources = { [14]=78628, [15]=79967, [16]=78628 } },
                { id = 201998, slot = "Weapon", name = "Fenryr's Bloodstained Fang", sources = { [14]=184052, [15]=184052, [16]=184052 }, mythicPlusOnly = true },
                { id = 133626, slot = "Wrist", name = "Runebands of the Worthy", sources = { [14]=76864, [15]=80118, [16]=76864 } },
            },
        },
        {
            index              = 4,
            name               = "God-King Skovald",
            journalEncounterID = 1488,
            achievements       = {
            },
            loot = {
                { id = 134193, slot = "Feet", name = "Biornskin Moccasins", sources = { [14]=77494, [15]=77494, [16]=77494 } },
                { id = 133623, slot = "Feet", name = "Felstep Footguards", sources = { [14]=76861, [15]=80115, [16]=76861 } },
                { id = 133617, slot = "Hands", name = "Cruel Vice Grips", sources = { [14]=76855, [15]=80056, [16]=76855 } },
                { id = 134182, slot = "Head", name = "Skoldiir Helm", sources = { [14]=77486, [15]=77486, [16]=77486 } },
                { id = 133630, slot = "Legs", name = "Greaves of the God-King", sources = { [14]=76868, [15]=79937, [16]=76868 } },
                { id = 134212, slot = "Legs", name = "Tideskorn Leggings", sources = { [14]=77506, [15]=77506, [16]=77506 } },
                { id = 201999, slot = "Off-hand", name = "Skovald's Resolve", sources = { [14]=184053, [15]=184053, [16]=184053 }, mythicPlusOnly = true },
                { id = 136775, slot = "Shoulder", name = "Infernal Mantle of Conquest", sources = { [14]=78630, [15]=80027, [16]=78630 } },
                { id = 134222, slot = "Wrist", name = "Bonespeaker Bracers", sources = { [14]=77516, [15]=77516, [16]=77516 } },
            },
        },
        {
            index              = 5,
            name               = "Odyn",
            journalEncounterID = 1489,
            achievements       = {
                { id = 10786, name = "Halls of Valor" },
                { id = 10788, name = "Heroic: Halls of Valor" },
                { id = 10789, name = "Mythic: Halls of Valor" },
                { id = 60831, name = "Halls of Valor" },
                { id = 60832, name = "Heroic: Halls of Valor" },
                { id = 60833, name = "Mythic: Halls of Valor" },
                { id = 10542, name = "I Got What You Mead", meta = true },
            },
            loot = {
                { id = 133765, slot = "Back", name = "Cape of Valarjar Courage", sources = { [14]=76910, [15]=80805, [16]=76910 } },
                { id = 139280, slot = "Feet", name = "Treads of Light", sources = { [14]=80577, [15]=80578, [16]=80577 } },
                { id = 134217, slot = "Hands", name = "Bonespeaker Gloves", sources = { [14]=77511, [15]=77511, [16]=77511 } },
                { id = 134180, slot = "Hands", name = "Skoldiir Gauntlets", sources = { [14]=77484, [15]=77484, [16]=77484 } },
                { id = 136777, slot = "Head", name = "Collar of Honorable Exultation", sources = { [14]=78632, [15]=80147, [16]=78632 } },
                { id = 139281, slot = "Head", name = "Glory Seeker's Helm", sources = { [14]=80579, [15]=80580, [16]=80579 } },
                { id = 133610, slot = "Legs", name = "Leggings of Swirling Runes", sources = { [14]=76848, [15]=79996, [16]=76848 } },
                { id = 133631, slot = "Shoulder", name = "Pauldrons of the All-Father", sources = { [14]=76869, [15]=79938, [16]=76869 } },
                { id = 136776, slot = "Waist", name = "Bjorn's Hunting Strap", sources = { [14]=78631, [15]=80087, [16]=78631 } },
                { id = 134207, slot = "Waist", name = "Tideskorn Cinch", sources = { [14]=77501, [15]=77501, [16]=77501 } },
                { id = 134192, slot = "Wrist", name = "Biornskin Bracer", sources = { [14]=77493, [15]=77493, [16]=77493 } },
                { id = 139282, slot = "Wrist", name = "Solid Gold Bracelets", sources = { [14]=80581, [15]=80582, [16]=80581 } },
                { id = 139283, slot = "Wrist", name = "Wristbands of Magnificent Splendor", sources = { [14]=80583, [15]=80584, [16]=80583 } },
            },
        },
    },
}
