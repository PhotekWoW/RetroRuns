-------------------------------------------------------------------------------
-- RetroRuns Data -- Algeth'ar Academy
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2526  |  journalInstanceID: 1201
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1201] = {
    kind              = "dungeon",
    instanceID        = 2526,
    journalInstanceID = 1201,
    name              = "Algeth'ar Academy",
    expansion         = "Dragonflight",
    difficultyModel   = "dungeonTiered",
    patch             = "10.0.2",

    gloryMeta = {
        id   = 16295,
        name = "Glory of the Dragonflight Hero",
        rewardItemID       = 192784,
        rewardMountSpellID = 374155,
        rewardName         = "Shellack",
    },

    bosses = {
        {
            index              = 1,
            name               = "Vexamus",
            journalEncounterID = 2509,
            achievements       = {
                { id = 16434, name = "See Me After Class", meta = true },
            },
            loot = {
                { id = 193709, slot = "Off-hand", name = "Vexamus' Expulsion Rod", sources = { [14]=180824, [15]=180824, [16]=180824 } },
                { id = 258529, slot = "Two-Hand", name = "Arcaneclaw Spear", sources = { [14]=301475, [15]=301475, [16]=301475 } },
                { id = 193711, slot = "Weapon", name = "Spellbane Cutlass", sources = { [14]=180826, [15]=180826, [16]=180826 } },
                { id = 193710, slot = "Weapon", name = "Spellboon Saber", sources = { [14]=180825, [15]=180825, [16]=180825 } },
            },
        },
        {
            index              = 2,
            name               = "Overgrown Ancient",
            journalEncounterID = 2512,
            achievements       = {
                { id = 16329, name = "Duck, Duck, Spruce!", meta = true },
            },
            loot = {
                { id = 193712, slot = "Back", name = "Potion-Stained Cloak", sources = { [14]=180828, [15]=180828, [16]=180828 } },
                { id = 193715, slot = "Feet", name = "Boots of Explosive Growth", sources = { [14]=180830, [15]=180830, [16]=180830 } },
                { id = 193713, slot = "Hands", name = "Experimental Safety Gloves", sources = { [14]=180827, [15]=180827, [16]=180827 } },
                { id = 193716, slot = "Two-Hand", name = "Algeth'ar Hedgecleaver", sources = { [14]=180836, [15]=180836, [16]=180836 } },
                { id = 193717, slot = "Weapon", name = "Mystakria's Harvester", sources = { [14]=180835, [15]=180835, [16]=180835 } },
                { id = 193714, slot = "Wrist", name = "Frenzyroot Cuffs", sources = { [14]=180829, [15]=180829, [16]=180829 } },
            },
        },
        {
            index              = 3,
            name               = "Crawth",
            journalEncounterID = 2495,
            achievements       = {
                { id = 16441, name = "Squad Goals", meta = true },
            },
            loot = {
                { id = 193720, slot = "Chest", name = "Bronze Challenger's Robe", sources = { [14]=180831, [15]=180831, [16]=180831 } },
                { id = 193721, slot = "Hands", name = "Ruby Contestant's Gloves", sources = { [14]=180832, [15]=180832, [16]=180832 } },
                { id = 258531, slot = "Off-hand", name = "Crawth's Scaleguard", sources = { [14]=301476, [15]=301476, [16]=301476 } },
                { id = 193723, slot = "Two-Hand", name = "Obsidian Goaltending Spire", sources = { [14]=180834, [15]=180834, [16]=180834 } },
                { id = 193722, slot = "Waist", name = "Azure Belt of Competition", sources = { [14]=180833, [15]=180833, [16]=180833 } },
            },
        },
        {
            index              = 4,
            name               = "Echo of Doragosa",
            journalEncounterID = 2514,
            achievements       = {
                { id = 16269, name = "Algeth'ar Academy" },
                { id = 16270, name = "Heroic: Algeth'ar Academy" },
                { id = 16271, name = "Mythic: Algeth'ar Academy" },
            },
            loot = {
                { id = 193705, slot = "Chest", name = "Breastplate of Proven Knowledge", sources = { [14]=180821, [15]=180821, [16]=180821 } },
                { id = 193703, slot = "Head", name = "Organized Pontificator's Mask", sources = { [14]=180819, [15]=180819, [16]=180819 } },
                { id = 193706, slot = "Legs", name = "Venerated Professor's Greaves", sources = { [14]=180822, [15]=180822, [16]=180822 } },
                { id = 193704, slot = "Shoulder", name = "Scaled Commencement Spaulders", sources = { [14]=180820, [15]=180820, [16]=180820 } },
                { id = 193707, slot = "Two-Hand", name = "Final Grade", sources = { [14]=180823, [15]=180823, [16]=180823 } },
            },
            specialLoot = {
                { id = 260359, kind = "decor", name = "Valdrakken Bookcase", decorID = 14330 },
            },
        },
    },
}
