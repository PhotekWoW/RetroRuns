-------------------------------------------------------------------------------
-- RetroRuns Data -- Tol Dagor
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1771  |  journalInstanceID: 1002
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1002] = {
    kind              = "dungeon",
    instanceID        = 1771,
    journalInstanceID = 1002,
    name              = "Tol Dagor",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.0.1",

    gloryMeta = {
        id   = 12812,
        name = "Glory of the Wartorn Hero",
        rewardItemID       = 161215,
        rewardName         = "Reins of the Obsidian Krolusk",
    },

    bosses = {
        {
            index              = 1,
            name               = "The Sand Queen",
            journalEncounterID = 2097,
            achievements       = {
            },
            loot = {
                { id = 159392, slot = "Legs", name = "Gaoler's Chainmail Gaiters", sources = { [14]=95177, [15]=95871, [16]=95872 } },
                { id = 159668, slot = "Off-hand", name = "Rattling Jar of Eyes", sources = { [14]=96085, [15]=96308, [16]=96309 } },
                { id = 159656, slot = "Two-Hand", name = "Halberd of the Unwary Guard", sources = { [14]=95443, [15]=95501, [16]=95502 } },
                { id = 160215, slot = "Waist", name = "Sewer Grate Girdle", sources = { [14]=96223, [15]=96224, [16]=96225 } },
                { id = 160110, slot = "Weapon", name = "Warglaive of the Sand Queen", sources = { [14]=96121, [15]=96122, [16]=96123 } },
                { id = 159332, slot = "Wrist", name = "Wristguards of the Sandswimmer", sources = { [14]=95098, [15]=95099, [16]=98473 } },
            },
        },
        {
            index              = 2,
            name               = "Jes Howlis",
            journalEncounterID = 2098,
            achievements       = {
            },
            loot = {
                { id = 159293, slot = "Back", name = "Turncoat's Cape", sources = { [14]=95046, [15]=97051, [16]=97052 } },
                { id = 159363, slot = "Feet", name = "Gnawed Iron Fetters", sources = { [14]=95137, [15]=95138, [16]=96219 } },
                { id = 159266, slot = "Hands", name = "Claw-Slit Brawler's Handwraps", sources = { [14]=95012, [15]=95776, [16]=95777 } },
                { id = 159306, slot = "Legs", name = "Singe-Blotched Britches", sources = { [14]=95062, [15]=95598, [16]=95599 } },
                { id = 159666, slot = "Off-hand", name = "Improvised Riot Shield", sources = { [14]=95453, [15]=95519, [16]=95520 } },
                { id = 159131, slot = "Weapon", name = "Howlis' Crystal Shiv", sources = { [14]=94877, [15]=95480, [16]=95481 } },
            },
        },
        {
            index              = 3,
            name               = "Knight Captain Valyri",
            journalEncounterID = 2099,
            achievements       = {
                { id = 12457, name = "Remix to Ignition", meta = true },
            },
            loot = {
                { id = 159444, slot = "Feet", name = "Gunpowder-Scoured Sabatons", sources = { [14]=95253, [15]=95689, [16]=95690 } },
                { id = 159343, slot = "Feet", name = "Spark Dampening Footpads", sources = { [14]=95114, [15]=98484, [16]=98485 } },
                { id = 159390, slot = "Hands", name = "Sure-Grip Munition Handlers", sources = { [14]=95175, [15]=95867, [16]=95868 } },
                { id = 159277, slot = "Legs", name = "Wild Pyromancer's Trousers", sources = { [14]=95027, [15]=95028, [16]=95788 } },
                { id = 159333, slot = "Waist", name = "Cincture of the Azerite Arsenal", sources = { [14]=95100, [15]=95101, [16]=98474 } },
                { id = 159274, slot = "Waist", name = "Knight Captain's Waistcord", sources = { [14]=95023, [15]=95785, [16]=95786 } },
                { id = 159389, slot = "Wrist", name = "Flint-Linked Wristguards", sources = { [14]=95173, [15]=95174, [16]=95866 } },
                { id = 159441, slot = "Wrist", name = "Valyri's Fire-Proof Bracers", sources = { [14]=95247, [15]=95248, [16]=95688 } },
            },
        },
        {
            index              = 4,
            name               = "Overseer Korgus",
            journalEncounterID = 2096,
            achievements       = {
                { id = 12462, name = "Shot Through the Heart", meta = true },
                { id = 12840, name = "Tol Dagor" },
                { id = 12841, name = "Heroic: Tol Dagor" },
                { id = 12842, name = "Mythic: Tol Dagor" },
            },
            loot = {
                { id = 159440, slot = "Chest", name = "Ashvane Warden's Cuirass", sources = { [14]=95245, [15]=95246, [16]=95687 } },
                { id = 159268, slot = "Chest", name = "Inmate's Straight Robe", sources = { [14]=95014, [15]=95015, [16]=95778 } },
                { id = 159334, slot = "Head", name = "Flashpowder Hood", sources = { [14]=95102, [15]=98475, [16]=98476 } },
                { id = 159391, slot = "Head", name = "Hood of the Dark Reaper", sources = { [14]=95176, [15]=95869, [16]=95870 } },
                { id = 159414, slot = "Head", name = "Overseer's Riot Helmet", sources = { [14]=95207, [15]=95636, [16]=95637 } },
                { id = 159657, slot = "Ranged", name = "Korgus' Blackpowder Rifle", sources = { [14]=95444, [15]=95465, [16]=95466 } },
                { id = 159393, slot = "Shoulder", name = "Cannoneer's Mantle", sources = { [14]=95178, [15]=95873, [16]=95874 } },
                { id = 159331, slot = "Shoulder", name = "Pistoleer's Spaulders", sources = { [14]=95096, [15]=95097, [16]=98472 } },
                { id = 159129, slot = "Two-Hand", name = "Flamecaster Botefeux", sources = { [14]=94875, [15]=95507, [16]=95508 } },
                { id = 159658, slot = "Weapon", name = "Cudgel of Correctional Oversight", sources = { [14]=95445, [15]=95486, [16]=95487 } },
            },
        },
    },
}
