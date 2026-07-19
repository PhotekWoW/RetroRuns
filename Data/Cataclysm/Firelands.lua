-------------------------------------------------------------------------------
-- RetroRuns Data -- Firelands
-- Cataclysm, Patch 4.2.0  |  instanceID: 720  |  journalInstanceID: 78
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[720] = {
    instanceID        = 720,
    journalInstanceID = 78,
    name              = "Firelands",
    expansion         = "Cataclysm",
    patch             = "4.2.0",

    exitNote = "Jump in the lava to die, and you will respawn at the raid entrance.",

    -- Firelands keeps Normal and Heroic on separate weekly lockouts (unlike
    -- the other Cataclysm raids, which share one). Patch 4.2 shipped with
    -- shared lockouts, but 8.2.5 split them when Firelands joined the
    -- Timewalking rotation, so each difficulty is its own bucket here.
    availableDifficulties = { 14, 15 },

    entrance = {
        mapID = 198,
        x     = 0.4730,
        y     = 0.7810,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [367] = "Firelands",
        [368] = "The Anvil of Conflagration",
        [369] = "Sulfuron Keep",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [71672] = 3,  -- Chest of the Fiery Vanquisher
            [71679] = 3,  -- Chest of the Fiery Conqueror
            [71686] = 3,  -- Chest of the Fiery Protector
            [71671] = 4,  -- Leggings of the Fiery Vanquisher
            [71678] = 4,  -- Leggings of the Fiery Conqueror
            [71685] = 4,  -- Leggings of the Fiery Protector
            [71669] = 5,  -- Gauntlets of the Fiery Vanquisher
            [71676] = 5,  -- Gauntlets of the Fiery Conqueror
            [71683] = 5,  -- Gauntlets of the Fiery Protector
            [71673] = 6,  -- Shoulders of the Fiery Vanquisher
            [71674] = 6,  -- Mantle of the Fiery Vanquisher
            [71680] = 6,  -- Shoulders of the Fiery Conqueror
            [71681] = 6,  -- Mantle of the Fiery Conqueror
            [71687] = 6,  -- Shoulders of the Fiery Protector
            [71688] = 6,  -- Mantle of the Fiery Protector
            [71668] = 7,  -- Helm of the Fiery Vanquisher
            [71670] = 7,  -- Crown of the Fiery Vanquisher
            [71675] = 7,  -- Helm of the Fiery Conqueror
            [71677] = 7,  -- Crown of the Fiery Conqueror
            [71682] = 7,  -- Helm of the Fiery Protector
            [71684] = 7,  -- Crown of the Fiery Protector
        },
    },

    gloryMeta = {
        id   = 5828,
        name = "Glory of the Firelands Raider",
        rewardItemID       = 69230,
        rewardName         = "Corrupted Egg of Millagazor",
        rewardKind         = "mount",
    },

    bosses = {
        {
            index              = 1,
            name               = "Beth'tilac",
            journalEncounterID = 192,
            aliases            = {},
            achievements       = {
                { id = 5821, name = "Death from Above", meta = true, soloable = "yes" },
                { id = 5807, name = "Heroic: Beth'tilac", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 70914, slot = "Chest", name = "Carapace of Imbibed Flame", sources = { [14]=36325, [15]=36637 } },
                { id = 71041, slot = "Chest", name = "Robes of Smoldering Devastation", sources = { [14]=36411, [15]=36639 } },
                { id = 71029, slot = "Feet", name = "Arachnaflame Treads", sources = { [14]=36404, [15]=36636 } },
                { id = 71044, slot = "Hands", name = "Cindersilk Gloves", sources = { [14]=36414, [15]=36642 } },
                { id = 71040, slot = "Head", name = "Cowl of the Clicking Menace", sources = { [14]=36410, [15]=36643 } },
                { id = 71031, slot = "Legs", name = "Cinderweb Leggings", sources = { [14]=36406, [15]=36634 } },
                { id = 71042, slot = "Legs", name = "Thoracic Flame Kilt", sources = { [14]=36412, [15]=36644 } },
                { id = 71038, slot = "Off-hand", name = "Ward of the Red Widow", sources = { [14]=36408, [15]=36640 } },
                { id = 71030, slot = "Shoulder", name = "Flickering Shoulders", sources = { [14]=36405, [15]=36635 } },
                { id = 71043, slot = "Shoulder", name = "Spaulders of Manifold Eyes", sources = { [14]=36413, [15]=36645 } },
                { id = 71039, slot = "Two-Hand", name = "Funeral Pyre", sources = { [14]=36409, [15]=36641 } },
                { id = 71775, slot = "Two-Hand", name = "Smoldering Censer of Purity", sources = { [14]=36859, [15]=36858 } },
                { id = 71780, slot = "Two-Hand", name = "Zoid's Firelit Greatsword", sources = { [14]=36864, [15]=36865 } },
                { id = 71779, slot = "Weapon", name = "Avool's Incendiary Shanker", sources = { [14]=36863, [15]=36862 } },
                { id = 71787, slot = "Weapon", name = "Entrail Disgorger", sources = { [14]=36871, [15]=36870 } },
                { id = 71776, slot = "Weapon", name = "Eye of Purification", sources = { [14]=36860, [15]=36861 } },
                { id = 71785, slot = "Weapon", name = "Firethorn Mindslicer", sources = { [14]=36869, [15]=36868 } },
                { id = 70922, slot = "Weapon", name = "Mandible of Beth'tilac", sources = { [14]=36331, [15]=36638 } },
                { id = 71782, slot = "Weapon", name = "Shatterskull Bonecrusher", sources = { [14]=36866, [15]=36867 } },
            },
            specialLoot = {
                { id = 152976, kind = "pet", name = "Cinderweb Egg" },
            },
        },
        {
            index              = 2,
            name               = "Lord Rhyolith",
            journalEncounterID = 193,
            aliases            = {},
            achievements       = {
                { id = 5808, name = "Heroic: Lord Rhyolith", meta = true, soloable = "yes" },
                { id = 5810, name = "Not an Ambi-Turner", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 70992, slot = "Back", name = "Dreadfire Drape", sources = { [14]=36383, [15]=36647 } },
                { id = 71005, slot = "Chest", name = "Flaming Core Chestguard", sources = { [14]=36387, [15]=36649 } },
                { id = 71010, slot = "Chest", name = "Incendic Chestguard", sources = { [14]=36391, [15]=36655 } },
                { id = 70912, slot = "Feet", name = "Cracked Obsidian Stompers", sources = { [14]=36323, [15]=36652 } },
                { id = 70993, slot = "Hands", name = "Fireskin Gauntlets", sources = { [14]=36384, [15]=36651 } },
                { id = 71007, slot = "Hands", name = "Grips of the Raging Giant", sources = { [14]=36389, [15]=36657 } },
                { id = 71011, slot = "Head", name = "Flickering Cowl", sources = { [14]=36392, [15]=36653 } },
                { id = 71003, slot = "Head", name = "Hood of Rampant Disdain", sources = { [14]=36385, [15]=36648 } },
                { id = 70991, slot = "Ranged", name = "Arbalest of Erupting Fury", sources = { [14]=36382, [15]=36646 } },
                { id = 71775, slot = "Two-Hand", name = "Smoldering Censer of Purity", sources = { [14]=36859, [15]=36858 } },
                { id = 71780, slot = "Two-Hand", name = "Zoid's Firelit Greatsword", sources = { [14]=36864, [15]=36865 } },
                { id = 71779, slot = "Weapon", name = "Avool's Incendiary Shanker", sources = { [14]=36863, [15]=36862 } },
                { id = 71787, slot = "Weapon", name = "Entrail Disgorger", sources = { [14]=36871, [15]=36870 } },
                { id = 71776, slot = "Weapon", name = "Eye of Purification", sources = { [14]=36860, [15]=36861 } },
                { id = 71785, slot = "Weapon", name = "Firethorn Mindslicer", sources = { [14]=36869, [15]=36868 } },
                { id = 71782, slot = "Weapon", name = "Shatterskull Bonecrusher", sources = { [14]=36866, [15]=36867 } },
                { id = 71006, slot = "Weapon", name = "Volcanospike", sources = { [14]=36388, [15]=36654 } },
                { id = 71004, slot = "Wrist", name = "Earthcrack Bracers", sources = { [14]=36386, [15]=36650 } },
                { id = 71009, slot = "Wrist", name = "Lava Line Wristbands", sources = { [14]=36390, [15]=36656 } },
            },
        },
        {
            index              = 3,
            name               = "Alysrazor",
            journalEncounterID = 194,
            aliases            = {},
            achievements       = {
                { id = 5809, name = "Heroic: Alysrazor", meta = true, soloable = "yes" },
                { id = 5813, name = "Do a Barrel Roll!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 70990, slot = "Back", name = "Wings of Flame", sources = { [14]=36381, [15]=36664 } },
                { id = 70988, slot = "Chest", name = "Clutch of the Firemother", sources = { [14]=36379, [15]=36669 } },
                { id = 70987, slot = "Feet", name = "Phoenix-Down Treads", sources = { [14]=36378, [15]=36666 } },
                { id = 70986, slot = "Hands", name = "Clawshaper Gauntlets", sources = { [14]=36377, [15]=36667 } },
                { id = 70734, slot = "Head", name = "Greathelm of the Voracious Maw", sources = { [14]=36156, [15]=36661 } },
                { id = 70739, slot = "Legs", name = "Lavaworm Legplates", sources = { [14]=36160, [15]=36662 } },
                { id = 70989, slot = "Legs", name = "Leggings of Billowing Fire", sources = { [14]=36380, [15]=36665 } },
                { id = 70736, slot = "Legs", name = "Moltenfeather Leggings", sources = { [14]=36158, [15]=36660 } },
                { id = 70985, slot = "Shoulder", name = "Craterflame Spaulders", sources = { [14]=36376, [15]=36668 } },
                { id = 70737, slot = "Shoulder", name = "Spaulders of Recurring Flame", sources = { [14]=36159, [15]=36663 } },
                { id = 71775, slot = "Two-Hand", name = "Smoldering Censer of Purity", sources = { [14]=36859, [15]=36858 } },
                { id = 71780, slot = "Two-Hand", name = "Zoid's Firelit Greatsword", sources = { [14]=36864, [15]=36865 } },
                { id = 70733, slot = "Weapon", name = "Alysra's Razor", sources = { [14]=36155, [15]=36658 } },
                { id = 71779, slot = "Weapon", name = "Avool's Incendiary Shanker", sources = { [14]=36863, [15]=36862 } },
                { id = 71787, slot = "Weapon", name = "Entrail Disgorger", sources = { [14]=36871, [15]=36870 } },
                { id = 71776, slot = "Weapon", name = "Eye of Purification", sources = { [14]=36860, [15]=36861 } },
                { id = 71785, slot = "Weapon", name = "Firethorn Mindslicer", sources = { [14]=36869, [15]=36868 } },
                { id = 71782, slot = "Weapon", name = "Shatterskull Bonecrusher", sources = { [14]=36866, [15]=36867 } },
                { id = 70735, slot = "Wrist", name = "Flickering Wristbands", sources = { [14]=36157, [15]=36659 } },
                { id = 70945, slot = "Chest", name = "Chestguard of the Molten Giant", sources = { [15]=36813 }, classes = { 1 } },
                { id = 71068, slot = "Chest", name = "Battleplate of the Molten Giant", sources = { [15]=36809 }, classes = { 1 } },
                { id = 70950, slot = "Chest", name = "Immolation Chestguard", sources = { [15]=36748 }, classes = { 2 } },
                { id = 71063, slot = "Chest", name = "Immolation Battleplate", sources = { [15]=36738 }, classes = { 2 } },
                { id = 71091, slot = "Chest", name = "Immolation Breastplate", sources = { [15]=36743 }, classes = { 2 } },
                { id = 71054, slot = "Chest", name = "Flamewaker's Tunic", sources = { [15]=36728 }, classes = { 3 } },
                { id = 71045, slot = "Chest", name = "Dark Phoenix Tunic", sources = { [15]=36763 }, classes = { 4 } },
                { id = 71274, slot = "Chest", name = "Robes of the Cleansing Flame", sources = { [15]=36756 }, classes = { 5 } },
                { id = 71279, slot = "Chest", name = "Vestment of the Cleansing Flame", sources = { [15]=36761 }, classes = { 5 } },
                { id = 70955, slot = "Chest", name = "Elementium Deathplate Chestguard", sources = { [15]=36708 }, classes = { 6 } },
                { id = 71058, slot = "Chest", name = "Elementium Deathplate Breastplate", sources = { [15]=36703 }, classes = { 6 } },
                { id = 71291, slot = "Chest", name = "Erupting Volcanic Hauberk", sources = { [15]=36778 }, classes = { 7 } },
                { id = 71296, slot = "Chest", name = "Erupting Volcanic Tunic", sources = { [15]=36768 }, classes = { 7 } },
                { id = 71301, slot = "Chest", name = "Erupting Volcanic Cuirass", sources = { [15]=36773 }, classes = { 7 } },
                { id = 71289, slot = "Chest", name = "Firehawk Robes", sources = { [15]=36736 }, classes = { 8 } },
                { id = 71284, slot = "Chest", name = "Balespider's Robes", sources = { [15]=36806 }, classes = { 9 } },
                { id = 71100, slot = "Chest", name = "Obsidian Arborweave Raiment", sources = { [15]=36713 }, classes = { 11 } },
                { id = 71105, slot = "Chest", name = "Obsidian Arborweave Tunic", sources = { [15]=36721 }, classes = { 11 } },
                { id = 71110, slot = "Chest", name = "Obsidian Arborweave Vestment", sources = { [15]=36726 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 71665, kind = "mount", name = "Flametalon of Alysrazor" },
            },
        },
        {
            index              = 4,
            name               = "Shannox",
            journalEncounterID = 195,
            aliases            = {},
            achievements       = {
                { id = 5806, name = "Heroic: Shannox", meta = true, soloable = "yes" },
                { id = 5829, name = "Bucket List", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 71023, slot = "Feet", name = "Coalwalker Sandals", sources = { [14]=36399, [15]=36676 } },
                { id = 71027, slot = "Feet", name = "Treads of Implicit Obedience", sources = { [14]=36402, [15]=36679 } },
                { id = 71020, slot = "Hands", name = "Gloves of Dissolving Smoke", sources = { [14]=36396, [15]=36670 } },
                { id = 71018, slot = "Head", name = "Scalp of the Bandit Prince", sources = { [14]=36395, [15]=36672 } },
                { id = 71022, slot = "Held In Off-hand", name = "Goblet of Anger", sources = { [14]=36398, [15]=36677 } },
                { id = 71028, slot = "Legs", name = "Legplates of Absolute Control", sources = { [14]=36403, [15]=36681 } },
                { id = 70913, slot = "Legs", name = "Legplates of Frenzied Devotion", sources = { [14]=36324, [15]=36674 } },
                { id = 71025, slot = "Shoulder", name = "Flickering Shoulderpads", sources = { [14]=36400, [15]=36678 } },
                { id = 71014, slot = "Two-Hand", name = "Skullstealer Greataxe", sources = { [14]=36394, [15]=36675 } },
                { id = 71775, slot = "Two-Hand", name = "Smoldering Censer of Purity", sources = { [14]=36859, [15]=36858 } },
                { id = 71780, slot = "Two-Hand", name = "Zoid's Firelit Greatsword", sources = { [14]=36864, [15]=36865 } },
                { id = 71021, slot = "Waist", name = "Uncrushable Belt of Fury", sources = { [14]=36397, [15]=36673 } },
                { id = 71779, slot = "Weapon", name = "Avool's Incendiary Shanker", sources = { [14]=36863, [15]=36862 } },
                { id = 71787, slot = "Weapon", name = "Entrail Disgorger", sources = { [14]=36871, [15]=36870 } },
                { id = 71776, slot = "Weapon", name = "Eye of Purification", sources = { [14]=36860, [15]=36861 } },
                { id = 71013, slot = "Weapon", name = "Feeding Frenzy", sources = { [14]=36393, [15]=36671 } },
                { id = 71785, slot = "Weapon", name = "Firethorn Mindslicer", sources = { [14]=36869, [15]=36868 } },
                { id = 71782, slot = "Weapon", name = "Shatterskull Bonecrusher", sources = { [14]=36866, [15]=36867 } },
                { id = 71026, slot = "Wrist", name = "Bracers of the Dread Hunter", sources = { [14]=36401, [15]=36680 } },
                { id = 70942, slot = "Legs", name = "Legguards of the Molten Giant", sources = { [15]=36816 }, classes = { 1 } },
                { id = 71071, slot = "Legs", name = "Legplates of the Molten Giant", sources = { [15]=36811 }, classes = { 1 } },
                { id = 70947, slot = "Legs", name = "Immolation Legguards", sources = { [15]=36751 }, classes = { 2 } },
                { id = 71066, slot = "Legs", name = "Immolation Legplates", sources = { [15]=36741 }, classes = { 2 } },
                { id = 71094, slot = "Legs", name = "Immolation Greaves", sources = { [15]=36746 }, classes = { 2 } },
                { id = 71052, slot = "Legs", name = "Flamewaker's Legguards", sources = { [15]=36731 }, classes = { 3 } },
                { id = 71048, slot = "Legs", name = "Dark Phoenix Legguards", sources = { [15]=36766 }, classes = { 4 } },
                { id = 71273, slot = "Legs", name = "Legwraps of the Cleansing Flame", sources = { [15]=36755 }, classes = { 5 } },
                { id = 71278, slot = "Legs", name = "Leggings of the Cleansing Flame", sources = { [15]=36760 }, classes = { 5 } },
                { id = 70952, slot = "Legs", name = "Elementium Deathplate Legguards", sources = { [15]=36711 }, classes = { 6 } },
                { id = 71061, slot = "Legs", name = "Elementium Deathplate Greaves", sources = { [15]=36706 }, classes = { 6 } },
                { id = 71294, slot = "Legs", name = "Erupting Volcanic Kilt", sources = { [15]=36781 }, classes = { 7 } },
                { id = 71299, slot = "Legs", name = "Erupting Volcanic Legwraps", sources = { [15]=36771 }, classes = { 7 } },
                { id = 71304, slot = "Legs", name = "Erupting Volcanic Legguards", sources = { [15]=36776 }, classes = { 7 } },
                { id = 71288, slot = "Legs", name = "Firehawk Leggings", sources = { [15]=36735 }, classes = { 8 } },
                { id = 71283, slot = "Legs", name = "Balespider's Leggings", sources = { [15]=36805 }, classes = { 9 } },
                { id = 71099, slot = "Legs", name = "Obsidian Arborweave Legguards", sources = { [15]=36716 }, classes = { 11 } },
                { id = 71104, slot = "Legs", name = "Obsidian Arborweave Legwraps", sources = { [15]=36720 }, classes = { 11 } },
                { id = 71109, slot = "Legs", name = "Obsidian Arborweave Leggings", sources = { [15]=36725 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 152975, kind = "pet", name = "Smoldering Treat" },
            },
        },
        {
            index              = 5,
            name               = "Baleroc, the Gatekeeper",
            journalEncounterID = 196,
            aliases            = { "Baleroc" },
            achievements       = {
                { id = 5805, name = "Heroic: Baleroc", meta = true, soloable = "yes" },
                { id = 5830, name = "Share the Pain", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 71314, slot = "Chest", name = "Breastplate of the Incendiary Soul", sources = { [14]=36590, [15]=36683 } },
                { id = 71340, slot = "Chest", name = "Gatekeeper's Embrace", sources = { [14]=36597, [15]=36692 } },
                { id = 71315, slot = "Feet", name = "Decimation Treads", sources = { [14]=36591, [15]=36685 } },
                { id = 70917, slot = "Hands", name = "Flickering Handguards", sources = { [14]=36328, [15]=36686 } },
                { id = 71342, slot = "Head", name = "Casque of Flame", sources = { [14]=36599, [15]=36693 } },
                { id = 70916, slot = "Head", name = "Helm of Blazing Glory", sources = { [14]=36327, [15]=36687 } },
                { id = 71323, slot = "Held In Off-hand", name = "Molten Scream", sources = { [14]=36592, [15]=36690 } },
                { id = 70915, slot = "Off-hand", name = "Shard of Torment", sources = { [14]=36326, [15]=36688 } },
                { id = 71343, slot = "Shoulder", name = "Mantle of Closed Doors", sources = { [14]=36600, [15]=36689 } },
                { id = 71345, slot = "Shoulder", name = "Shoulderpads of the Forgotten Gate", sources = { [14]=36602, [15]=36684 } },
                { id = 71775, slot = "Two-Hand", name = "Smoldering Censer of Purity", sources = { [14]=36859, [15]=36858 } },
                { id = 71780, slot = "Two-Hand", name = "Zoid's Firelit Greatsword", sources = { [14]=36864, [15]=36865 } },
                { id = 71779, slot = "Weapon", name = "Avool's Incendiary Shanker", sources = { [14]=36863, [15]=36862 } },
                { id = 71787, slot = "Weapon", name = "Entrail Disgorger", sources = { [14]=36871, [15]=36870 } },
                { id = 71776, slot = "Weapon", name = "Eye of Purification", sources = { [14]=36860, [15]=36861 } },
                { id = 71785, slot = "Weapon", name = "Firethorn Mindslicer", sources = { [14]=36869, [15]=36868 } },
                { id = 71312, slot = "Weapon", name = "Gatecrasher", sources = { [14]=36588, [15]=36682 } },
                { id = 71782, slot = "Weapon", name = "Shatterskull Bonecrusher", sources = { [14]=36866, [15]=36867 } },
                { id = 71341, slot = "Wrist", name = "Glowing Wing Bracers", sources = { [14]=36598, [15]=36691 } },
                { id = 70943, slot = "Hands", name = "Handguards of the Molten Giant", sources = { [15]=36814 }, classes = { 1 } },
                { id = 71069, slot = "Hands", name = "Gauntlets of the Molten Giant", sources = { [15]=36810 }, classes = { 1 } },
                { id = 70949, slot = "Hands", name = "Immolation Handguards", sources = { [15]=36749 }, classes = { 2 } },
                { id = 71064, slot = "Hands", name = "Immolation Gauntlets", sources = { [15]=36739 }, classes = { 2 } },
                { id = 71092, slot = "Hands", name = "Immolation Gloves", sources = { [15]=36744 }, classes = { 2 } },
                { id = 71050, slot = "Hands", name = "Flamewaker's Gloves", sources = { [15]=36729 }, classes = { 3 } },
                { id = 71046, slot = "Hands", name = "Dark Phoenix Gloves", sources = { [15]=36764 }, classes = { 4 } },
                { id = 71271, slot = "Hands", name = "Handwraps of the Cleansing Flame", sources = { [15]=36753 }, classes = { 5 } },
                { id = 71276, slot = "Hands", name = "Gloves of the Cleansing Flame", sources = { [15]=36758 }, classes = { 5 } },
                { id = 70953, slot = "Hands", name = "Elementium Deathplate Handguards", sources = { [15]=36709 }, classes = { 6 } },
                { id = 71059, slot = "Hands", name = "Elementium Deathplate Gauntlets", sources = { [15]=36704 }, classes = { 6 } },
                { id = 71292, slot = "Hands", name = "Erupting Volcanic Gloves", sources = { [15]=36779 }, classes = { 7 } },
                { id = 71297, slot = "Hands", name = "Erupting Volcanic Handwraps", sources = { [15]=36769 }, classes = { 7 } },
                { id = 71302, slot = "Hands", name = "Erupting Volcanic Grips", sources = { [15]=36774 }, classes = { 7 } },
                { id = 71286, slot = "Hands", name = "Firehawk Gloves", sources = { [15]=36733 }, classes = { 8 } },
                { id = 71281, slot = "Hands", name = "Balespider's Handwraps", sources = { [15]=36803 }, classes = { 9 } },
                { id = 71097, slot = "Hands", name = "Obsidian Arborweave Grips", sources = { [15]=36714 }, classes = { 11 } },
                { id = 71102, slot = "Hands", name = "Obsidian Arborweave Handwraps", sources = { [15]=36718 }, classes = { 11 } },
                { id = 71107, slot = "Hands", name = "Obsidian Arborweave Gloves", sources = { [15]=36723 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 152977, kind = "pet", name = "Vibrating Stone" },
            },
        },
        {
            index              = 6,
            name               = "Majordomo Staghelm",
            journalEncounterID = 197,
            aliases            = {},
            achievements       = {
                { id = 5804, name = "Heroic: Majordomo Fandral Staghelm", meta = true, soloable = "yes" },
                { id = 5799, name = "Only the Penitent...", meta = true, soloable = "no" },
            },
            loot = {
                { id = 71344, slot = "Chest", name = "Breastplate of Shifting Visions", sources = { [14]=36601, [15]=36697 } },
                { id = 71313, slot = "Feet", name = "Sandals of Leaping Coals", sources = { [14]=36589, [15]=36695 } },
                { id = 71351, slot = "Feet", name = "Treads of the Penitent Man", sources = { [14]=36607, [15]=36702 } },
                { id = 71346, slot = "Hands", name = "Grips of Unerring Precision", sources = { [14]=36603, [15]=36696 } },
                { id = 71349, slot = "Legs", name = "Firecat Leggings", sources = { [14]=36605, [15]=36701 } },
                { id = 71347, slot = "Ranged", name = "Stinger of the Flaming Scorpion", sources = { [14]=36604, [15]=36700 } },
                { id = 69897, slot = "Two-Hand", name = "Fandral's Flamescythe", sources = { [14]=35599, [15]=36694 } },
                { id = 71775, slot = "Two-Hand", name = "Smoldering Censer of Purity", sources = { [14]=36859, [15]=36858 } },
                { id = 71780, slot = "Two-Hand", name = "Zoid's Firelit Greatsword", sources = { [14]=36864, [15]=36865 } },
                { id = 71779, slot = "Weapon", name = "Avool's Incendiary Shanker", sources = { [14]=36863, [15]=36862 } },
                { id = 71787, slot = "Weapon", name = "Entrail Disgorger", sources = { [14]=36871, [15]=36870 } },
                { id = 71776, slot = "Weapon", name = "Eye of Purification", sources = { [14]=36860, [15]=36861 } },
                { id = 71785, slot = "Weapon", name = "Firethorn Mindslicer", sources = { [14]=36869, [15]=36868 } },
                { id = 71782, slot = "Weapon", name = "Shatterskull Bonecrusher", sources = { [14]=36866, [15]=36867 } },
                { id = 70920, slot = "Wrist", name = "Bracers of the Fiery Path", sources = { [14]=36329, [15]=36698 } },
                { id = 71350, slot = "Wrist", name = "Wristwraps of Arrogant Doom", sources = { [14]=36606, [15]=36699 } },
                { id = 70941, slot = "Shoulder", name = "Shoulderguards of the Molten Giant", sources = { [14]=36337, [15]=36817 }, classes = { 1 } },
                { id = 71072, slot = "Shoulder", name = "Pauldrons of the Molten Giant", sources = { [14]=36440, [15]=36812 }, classes = { 1 } },
                { id = 70946, slot = "Shoulder", name = "Immolation Shoulderguards", sources = { [14]=36342, [15]=36752 }, classes = { 2 } },
                { id = 71067, slot = "Shoulder", name = "Immolation Pauldrons", sources = { [14]=36435, [15]=36742 }, classes = { 2 } },
                { id = 71095, slot = "Shoulder", name = "Immolation Mantle", sources = { [14]=36454, [15]=36747 }, classes = { 2 } },
                { id = 71053, slot = "Shoulder", name = "Flamewaker's Spaulders", sources = { [14]=36423, [15]=36732 }, classes = { 3 } },
                { id = 71049, slot = "Shoulder", name = "Dark Phoenix Spaulders", sources = { [14]=36419, [15]=36767 }, classes = { 4 } },
                { id = 71275, slot = "Shoulder", name = "Mantle of the Cleansing Flame", sources = { [14]=36557, [15]=36757 }, classes = { 5 } },
                { id = 71280, slot = "Shoulder", name = "Shoulderwraps of the Cleansing Flame", sources = { [14]=36562, [15]=36762 }, classes = { 5 } },
                { id = 70951, slot = "Shoulder", name = "Elementium Deathplate Shoulderguards", sources = { [14]=36347, [15]=36712 }, classes = { 6 } },
                { id = 71062, slot = "Shoulder", name = "Elementium Deathplate Pauldrons", sources = { [14]=36430, [15]=36707 }, classes = { 6 } },
                { id = 71295, slot = "Shoulder", name = "Erupting Volcanic Shoulderwraps", sources = { [14]=36577, [15]=36782 }, classes = { 7 } },
                { id = 71300, slot = "Shoulder", name = "Erupting Volcanic Mantle", sources = { [14]=36582, [15]=36772 }, classes = { 7 } },
                { id = 71305, slot = "Shoulder", name = "Erupting Volcanic Spaulders", sources = { [14]=36587, [15]=36777 }, classes = { 7 } },
                { id = 71290, slot = "Shoulder", name = "Firehawk Mantle", sources = { [14]=36572, [15]=36737 }, classes = { 8 } },
                { id = 71285, slot = "Shoulder", name = "Balespider's Mantle", sources = { [14]=36567, [15]=36807 }, classes = { 9 } },
                { id = 71101, slot = "Shoulder", name = "Obsidian Arborweave Spaulders", sources = { [14]=36459, [15]=36717 }, classes = { 11 } },
                { id = 71106, slot = "Shoulder", name = "Obsidian Arborweave Mantle", sources = { [14]=36464, [15]=36722 }, classes = { 11 } },
                { id = 71111, slot = "Shoulder", name = "Obsidian Arborweave Shoulderwraps", sources = { [14]=36469, [15]=36727 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 152978, kind = "pet", name = "Fandral's Pet Carrier" },
            },
        },
        {
            index              = 7,
            name               = "Ragnaros",
            journalEncounterID = 198,
            aliases            = {},
            achievements       = {},
            loot = {
                { id = 71358, slot = "Hands", name = "Fingers of Incineration", sources = { [14]=36613, [15]=36821 } },
                { id = 71356, slot = "Head", name = "Crown of Flame", sources = { [14]=36611, [15]=36823 } },
                { id = 71353, slot = "Ranged", name = "Arathar, the Eye of Flame", sources = { [14]=36609, [15]=36818 } },
                { id = 70921, slot = "Shoulder", name = "Pauldrons of Roaring Flame", sources = { [14]=36330, [15]=36819 } },
                { id = 71798, slot = "Two-Hand", name = "Sho'ravon, Greatstaff of Annihilation", sources = { [14]=36873, [15]=36872 } },
                { id = 71352, slot = "Two-Hand", name = "Sulfuras, the Extinguished Hand", sources = { [14]=36608, [15]=36152 } },
                { id = 71357, slot = "Waist", name = "Majordomo's Chain of Office", sources = { [14]=36612, [15]=36820 } },
                { id = 71355, slot = "Weapon", name = "Ko'gun, Hammer of the Firelord", sources = { [14]=36610, [15]=36822 } },
                { id = 70944, slot = "Head", name = "Faceguard of the Molten Giant", sources = { [14]=36340, [15]=36815 }, classes = { 1 } },
                { id = 71070, slot = "Head", name = "Helmet of the Molten Giant", sources = { [14]=36438, [15]=36808 }, classes = { 1 } },
                { id = 70948, slot = "Head", name = "Immolation Faceguard", sources = { [14]=36344, [15]=36750 }, classes = { 2 } },
                { id = 71065, slot = "Head", name = "Immolation Helmet", sources = { [14]=36433, [15]=36740 }, classes = { 2 } },
                { id = 71093, slot = "Head", name = "Immolation Headguard", sources = { [14]=36452, [15]=36745 }, classes = { 2 } },
                { id = 71051, slot = "Head", name = "Flamewaker's Headguard", sources = { [14]=36421, [15]=36730 }, classes = { 3 } },
                { id = 71047, slot = "Head", name = "Dark Phoenix Helmet", sources = { [14]=36417, [15]=36765 }, classes = { 4 } },
                { id = 71272, slot = "Head", name = "Cowl of the Cleansing Flame", sources = { [14]=36554, [15]=36754 }, classes = { 5 } },
                { id = 71277, slot = "Head", name = "Hood of the Cleansing Flame", sources = { [14]=36559, [15]=36759 }, classes = { 5 } },
                { id = 70954, slot = "Head", name = "Elementium Deathplate Faceguard", sources = { [14]=36350, [15]=36710 }, classes = { 6 } },
                { id = 71060, slot = "Head", name = "Elementium Deathplate Helmet", sources = { [14]=36428, [15]=36705 }, classes = { 6 } },
                { id = 71293, slot = "Head", name = "Erupting Volcanic Headpiece", sources = { [14]=36575, [15]=36780 }, classes = { 7 } },
                { id = 71298, slot = "Head", name = "Erupting Volcanic Faceguard", sources = { [14]=36580, [15]=36770 }, classes = { 7 } },
                { id = 71303, slot = "Head", name = "Erupting Volcanic Helmet", sources = { [14]=36585, [15]=36775 }, classes = { 7 } },
                { id = 71287, slot = "Head", name = "Firehawk Hood", sources = { [14]=36569, [15]=36734 }, classes = { 8 } },
                { id = 71282, slot = "Head", name = "Balespider's Hood", sources = { [14]=36564, [15]=36804 }, classes = { 9 } },
                { id = 71098, slot = "Head", name = "Obsidian Arborweave Headpiece", sources = { [14]=36456, [15]=36715 }, classes = { 11 } },
                { id = 71103, slot = "Head", name = "Obsidian Arborweave Helm", sources = { [14]=36461, [15]=36719 }, classes = { 11 } },
                { id = 71108, slot = "Head", name = "Obsidian Arborweave Cover", sources = { [14]=36466, [15]=36724 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 69224, kind = "mount", name = "Smoldering Egg of Millagazor" },
            },
        },
    },

    routing = {

        -- 1. Beth'tilac
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Beth'tilac",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 367 },
                    kind    = "path",
                    note    = "After zoning in, make your way down the path in front of you. When you can, hang a left and work your way around to ^Beth'tilac^.",
                    minNote = "Left to Beth'tilac",
                    points  = {
                        { 0.277, 0.831 },
                        { 0.332, 0.757 },
                        { 0.385, 0.685 },
                        { 0.366, 0.641 },
                        { 0.279, 0.616 },
                        { 0.233, 0.532 },
                        { 0.179, 0.532 },
                        { 0.157, 0.455 },
                        { 0.186, 0.452 },
                        { 0.209, 0.463 },
                        { 0.229, 0.455 },
                        { 0.249, 0.467 },
                        { 0.276, 0.439 },
                        { 0.229, 0.364 },
                    },
                },
            },
        },

        -- 2. Lord Rhyolith
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Lord Rhyolith",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 367 },
                    kind    = "path",
                    note    = "After defeating ^Beth'tilac^, follow the path all the way to the southeastern corner of the map to reach ^Lord Rhyolith^. Kill trash on your path, to minimize the amount you have to kill later to spawn ^Shannox^.",
                    minNote = "Southeast to Rhyolith",
                    points  = {
                        { 0.238, 0.368 },
                        { 0.272, 0.431 },
                        { 0.328, 0.419 },
                        { 0.424, 0.434 },
                        { 0.647, 0.572 },
                        { 0.713, 0.650 },
                        { 0.718, 0.727 },
                        { 0.683, 0.745 },
                    },
                },
            },
        },

        -- 3. Alysrazor
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Alysrazor",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 367 },
                    kind    = "path",
                    note    = "After killing ^Lord Rhyolith^, make your way north to reach ^Alysrazor^. Tag ^Majordomo^ to start the encounter.",
                    minNote = "Tag Majordomo to start Alysrazor",
                    points  = {
                        { 0.682, 0.736 },
                        { 0.713, 0.720 },
                        { 0.716, 0.665 },
                        { 0.674, 0.605 },
                        { 0.617, 0.560 },
                        { 0.633, 0.416 },
                    },
                },
            },
        },

        {
            step      = 4,
            priority  = 1,
            bossIndex = 4,
            title     = "Shannox",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 367 },
                    kind    = "path",
                    note    = "After defeating ^Alysrazor^, you will find ^Shannox^ patrolling around the main circular path of the instance. If he hasn't spawned yet, kill random trash until he emotes.",
                    minNote = "Kill Trash to Spawn Shannox",
                    points  = {
                        { 0.634, 0.422 },
                        { 0.594, 0.535 },
                        { 0.577, 0.509 },
                        { 0.548, 0.501 },
                        { 0.516, 0.470 },
                    },
                },
            },
        },

        {
            step      = 5,
            priority  = 1,
            bossIndex = 5,
            title     = "Baleroc, the Gatekeeper",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 367 },
                    kind    = "path",
                    note    = "After defeating ^Shannox^, head north to reach ^Baleroc^.",
                    minNote = "North to Baleroc",
                    points  = {
                        { 0.494, 0.405 },
                        { 0.494, 0.350 },
                    },
                },
            },
        },

        {
            step      = 6,
            priority  = 1,
            bossIndex = 6,
            title     = "Majordomo Staghelm",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 367 },
                    kind            = "poi",
                    mapLabel        = "Magma Orb",
                    mapLabelPos     = "above",
                    note            = "After killing ^Baleroc^, interact with the ^Magma Orb^ behind him to open the bridge. Cross the bridge and kill the trash to engage ^Majordomo Staghelm^.",
                    minNote         = "Orb then bridge to Majordomo",
                    points          = {
                        { 0.509, 0.249 },
                    },
                },
            },
        },

        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Ragnaros",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 369 },
                    kind    = "path",
                    note    = "After killing ^Majordomo Staghelm^, proceed straight ahead all the way to ^Ragnaros^.",
                    minNote = "Ahead to Ragnaros",
                    points  = {
                        { 0.508, 0.682 },
                        { 0.504, 0.635 },
                        { 0.482, 0.625 },
                        { 0.484, 0.602 },
                        { 0.507, 0.594 },
                        { 0.505, 0.194 },
                    },
                },
                {
                    when        = { mapID = 369 },
                    kind        = "poi",
                    noMarker    = true,
                    triggeredBy = { dialog = { npc = "Malfurion Stormrage", match = "It is finished then" } },
                    note        = "Ragnaros defeated! Due to a Blizzard bug, it may take a moment for the game to register the kill. If your progress doesn't update after 10-15 seconds, /reload or re-log to force it.",
                    minNote     = "/reload if stuck",
                    points      = {
                        { 0.505, 0.194 },
                    },
                },
            },
        },

    },
}
