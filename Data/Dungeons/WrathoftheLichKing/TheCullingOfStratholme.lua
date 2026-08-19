-------------------------------------------------------------------------------
-- RetroRuns Data -- The Culling of Stratholme
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 595  |  journalInstanceID: 279
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[279] = {
    kind              = "dungeon",
    instanceID        = 595,
    journalInstanceID = 279,
    name              = "The Culling of Stratholme",
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
            name               = "Meathook",
            journalEncounterID = 611,
            achievements       = {
            },
            loot = {
                { id = 37082, slot = "Feet", name = "Slaughterhouse Sabatons", sources = { [14]=17594 } },
                { id = 37678, slot = "Hands", name = "Bile-Cured Gloves", sources = { [14]=17943 } },
                { id = 37083, slot = "Legs", name = "Kilt of Sewn Flesh", sources = { [14]=17595 } },
                { id = 37675, slot = "Legs", name = "Legplates of Steel Implants", sources = { [14]=17942 } },
                { id = 37679, slot = "Shoulder", name = "Spaulders of the Abomination", sources = { [14]=17944 } },
                { id = 37680, slot = "Waist", name = "Belt of Unified Souls", sources = { [14]=17945 } },
                { id = 37081, slot = "Weapon", name = "Meathook's Slicer", sources = { [14]=17593 } },
            },
        },
        {
            index              = 2,
            name               = "Salramm the Fleshcrafter",
            journalEncounterID = 612,
            achievements       = {
            },
            loot = {
                { id = 37084, slot = "Back", name = "Flowing Cloak of Command", sources = { [14]=17596 } },
                { id = 37684, slot = "Head", name = "Forgotten Shadow Hood", sources = { [14]=17948 } },
                { id = 157563, slot = "Legs", name = "Freshly Sewn Leggings", sources = { [14]=93758 } },
                { id = 37086, slot = "Off-hand", name = "Tome of Salramm", sources = { [14]=17597 } },
                { id = 37088, slot = "Waist", name = "Spiked Metal Cilice", sources = { [14]=17598 } },
                { id = 37095, slot = "Waist", name = "Waistband of the Thuzadin", sources = { [14]=17599 } },
                { id = 37681, slot = "Weapon", name = "Gavel of the Fleshcrafter", sources = { [14]=17946 } },
                { id = 37682, slot = "Wrist", name = "Bindings of Dark Will", sources = { [14]=17947 } },
            },
        },
        {
            index              = 3,
            name               = "Chrono-Lord Epoch",
            journalEncounterID = 613,
            achievements       = {
            },
            loot = {
                { id = 37105, slot = "Feet", name = "Treads of Altered History", sources = { [14]=17601 } },
                { id = 37686, slot = "Hands", name = "Cracked Epoch Grasps", sources = { [14]=17949 } },
                { id = 37687, slot = "Hands", name = "Gloves of Distorted Time", sources = { [14]=17950 } },
                { id = 37688, slot = "Legs", name = "Legplates of the Infinite Drakonid", sources = { [14]=17951 } },
                { id = 37099, slot = "Two-Hand", name = "Sempiternal Staff", sources = { [14]=17600 } },
                { id = 37106, slot = "Waist", name = "Ouroboros Belt", sources = { [14]=17602 } },
            },
        },
        {
            index              = 4,
            name               = "Mal'Ganis",
            journalEncounterID = 614,
            achievements       = {
                { id = 479, name = "The Culling of Stratholme" },
                { id = 500, name = "Heroic: The Culling of Stratholme" },
                { id = 1817, name = "The Culling of Time", meta = true },
                { id = 1872, name = "Zombiefest!", meta = true },
                { id = 39926, name = "The Culling of Stratholme (char specific hidden copy)" },
            },
            loot = {
                { id = 37110, slot = "Hands", name = "Gauntlets of Dark Conversion", sources = { [14]=17606 } },
                { id = 37114, slot = "Hands", name = "Gloves of Northern Lordaeron", sources = { [14]=17609 } },
                { id = 37695, slot = "Legs", name = "Legguards of Nature's Power", sources = { [14]=17956 } },
                { id = 37107, slot = "Off-hand", name = "Leeka's Shield", sources = { [14]=17603 } },
                { id = 43085, slot = "Off-hand", name = "Royal Crest of Lordaeron", sources = { [14]=20856 } },
                { id = 37692, slot = "Ranged", name = "Pierce's Pistol", sources = { [14]=17954 } },
                { id = 37109, slot = "Shoulder", name = "Discarded Silver Hand Spaulders", sources = { [14]=17605 } },
                { id = 37691, slot = "Shoulder", name = "Mantle of Deceit", sources = { [14]=17953 } },
                { id = 37690, slot = "Shoulder", name = "Pauldrons of Destiny", sources = { [14]=17952 } },
                { id = 37108, slot = "Two-Hand", name = "Dreadlord's Blade", sources = { [14]=17604 } },
                { id = 37112, slot = "Weapon", name = "Beguiling Scepter", sources = { [14]=17607 } },
                { id = 37693, slot = "Weapon", name = "Greed", sources = { [14]=17955 } },
                { id = 37113, slot = "Wrist", name = "Demonic Fabric Bands", sources = { [14]=17608 } },
                { id = 37696, slot = "Wrist", name = "Plague-Infected Bracers", sources = { [14]=17957 } },
            },
        },
    },
}
