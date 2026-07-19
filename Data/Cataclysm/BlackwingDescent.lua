-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackwing Descent
-- Cataclysm, Patch 4.0.3  |  instanceID: 669  |  journalInstanceID: 73
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[669] = {
    instanceID        = 669,
    journalInstanceID = 73,
    name              = "Blackwing Descent",
    expansion         = "Cataclysm",
    patch             = "4.0.3",

    exitNote = "None available",

    -- Both Normal and Heroic are offered, folded into one weekly lockout.
    difficultyModel     = "shared",
    availableDifficulties = { 14, 15 },

    entrance = {
        mapID = 13,
        x     = 0.484,
        y     = 0.718,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [285] = "The Broken Hall",
        [286] = "Vault of the Shadowflame",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [67429] = 2,  -- Gauntlets of the Forlorn Conqueror
            [67430] = 2,  -- Gauntlets of the Forlorn Protector
            [67431] = 2,  -- Gauntlets of the Forlorn Vanquisher
            [67426] = 5,  -- Leggings of the Forlorn Vanquisher
            [67427] = 5,  -- Leggings of the Forlorn Protector
            [67428] = 5,  -- Leggings of the Forlorn Conqueror
            [63682] = 6,  -- Helm of the Forlorn Vanquisher
            [63683] = 6,  -- Helm of the Forlorn Conqueror
            [63684] = 6,  -- Helm of the Forlorn Protector
            [65000] = 6,  -- Crown of the Forlorn Protector
            [65001] = 6,  -- Crown of the Forlorn Conqueror
            [65002] = 6,  -- Crown of the Forlorn Vanquisher
        },
    },

    gloryMeta = {
        id   = 4853,
        name = "Glory of the Cataclysm Raider",
        rewardItemID       = 62901,
        rewardMountSpellID = 88335,
        rewardName         = "Reins of the Drake of the East Wind",
    },

    bosses = {
        {
            index              = 1,
            name               = "Omnotron Defense System",
            journalEncounterID = 169,
            aliases            = {},
            achievements       = {
                { id = 5307, name = "Achieve-a-tron", meta = true, soloable = "yes" },
                { id = 5107, name = "Heroic: Omnotron Defense System", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 63540, slot = "Chest", name = "Circuit Design Breastplate", sources = { [14]=31868, [15]=32601 } },
                { id = 59119, slot = "Chest", name = "Voltage Source Chestguard", sources = { [14]=29425, [15]=32670 } },
                { id = 59216, slot = "Feet", name = "Life Force Chargers", sources = { [14]=29485, [15]=32667 } },
                { id = 59219, slot = "Head", name = "Power Generator Hood", sources = { [14]=29488, [15]=32664 } },
                { id = 59218, slot = "Shoulder", name = "Passive Resistor Spaulders", sources = { [14]=29487, [15]=32665 } },
                { id = 59120, slot = "Shoulder", name = "Poison Protocol Pauldrons", sources = { [14]=29426, [15]=32669 } },
                { id = 59117, slot = "Waist", name = "Jumbotron Power Belt", sources = { [14]=29423, [15]=32672 } },
                { id = 59217, slot = "Waist", name = "X-Tron Duct Tape", sources = { [14]=29486, [15]=32666 } },
                { id = 59122, slot = "Weapon", name = "Organic Lifeform Inverter", sources = { [14]=29427, [15]=32668 } },
                { id = 59118, slot = "Wrist", name = "Electron Inductor Coils", sources = { [14]=29424, [15]=32671 } },
            },
            specialLoot = {
                { id = 152966, kind = "pet", name = "Rough-Hewn Remote" },
            },
        },
        {
            index              = 2,
            name               = "Magmaw",
            journalEncounterID = 170,
            aliases            = {},
            achievements       = {
                { id = 5306, name = "Parasite Evening", meta = true, soloable = "yes" },
                { id = 5094, name = "Heroic: Magmaw", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59340, slot = "Chest", name = "Breastplate of Avenging Flame", sources = { [14]=29586, [15]=32635 } },
                { id = 59335, slot = "Chest", name = "Scorched Wormling Vest", sources = { [14]=29583, [15]=32638 } },
                { id = 59328, slot = "Feet", name = "Molten Tantrum Boots", sources = { [14]=29577, [15]=32643 } },
                { id = 59452, slot = "Head", name = "Crown of Burning Waters", sources = { [14]=29676, [15]=32616 } },
                { id = 59336, slot = "Legs", name = "Flame Pillar Leggings", sources = { [14]=29584, [15]=32637 } },
                { id = 59331, slot = "Legs", name = "Leggings of Lethal Force", sources = { [14]=29580, [15]=32641 } },
                { id = 59492, slot = "Two-Hand", name = "Akirus the Worm-Breaker", sources = { [14]=29706, [15]=32604 } },
                { id = 59334, slot = "Waist", name = "Lifecycle Waistguard", sources = { [14]=29582, [15]=32639 } },
                { id = 59341, slot = "Weapon", name = "Incineratus", sources = { [14]=29587, [15]=32634 } },
                { id = 59333, slot = "Weapon", name = "Lava Spine", sources = { [14]=29581, [15]=32640 } },
                { id = 59329, slot = "Wrist", name = "Parasitic Bands", sources = { [14]=29578, [15]=32642 } },
                { id = 60326, slot = "Hands", name = "Earthen Gauntlets", sources = { [14]=30058, [15]=32826 }, classes = { 1 } },
                { id = 60332, slot = "Hands", name = "Earthen Handguards", sources = { [14]=30064, [15]=32831 }, classes = { 1 } },
                { id = 60345, slot = "Hands", name = "Reinforced Sapphirium Gauntlets", sources = { [14]=30072, [15]=32776 }, classes = { 2 } },
                { id = 60355, slot = "Hands", name = "Reinforced Sapphirium Handguards", sources = { [14]=30082, [15]=32786 }, classes = { 2 } },
                { id = 60363, slot = "Hands", name = "Reinforced Sapphirium Gloves", sources = { [14]=30090, [15]=32781 }, classes = { 2 } },
                { id = 60307, slot = "Hands", name = "Lightning-Charged Gloves", sources = { [14]=30039, [15]=32766 }, classes = { 3 } },
                { id = 60298, slot = "Hands", name = "Wind Dancer's Gloves", sources = { [14]=30030, [15]=32801 }, classes = { 4 } },
                { id = 60257, slot = "Hands", name = "Mercurial Gloves", sources = { [14]=30006, [15]=32795 }, classes = { 5 } },
                { id = 60275, slot = "Hands", name = "Mercurial Handwraps", sources = { [14]=30011, [15]=32790 }, classes = { 5 } },
                { id = 60340, slot = "Hands", name = "Magma Plated Gauntlets", sources = { [14]=30067, [15]=32741 }, classes = { 6 } },
                { id = 60350, slot = "Hands", name = "Magma Plated Handguards", sources = { [14]=30077, [15]=32746 }, classes = { 6 } },
                { id = 60312, slot = "Hands", name = "Handwraps of the Raging Elements", sources = { [14]=30044, [15]=32806 }, classes = { 7 } },
                { id = 60314, slot = "Hands", name = "Gloves of the Raging Elements", sources = { [14]=30046, [15]=32816 }, classes = { 7 } },
                { id = 60319, slot = "Hands", name = "Grips of the Raging Elements", sources = { [14]=30051, [15]=32811 }, classes = { 7 } },
                { id = 60247, slot = "Hands", name = "Firelord's Gloves", sources = { [14]=29996, [15]=32770 }, classes = { 8 } },
                { id = 60248, slot = "Hands", name = "Shadowflame Handwraps", sources = { [14]=29997, [15]=32820 }, classes = { 9 } },
                { id = 60280, slot = "Hands", name = "Stormrider's Handwraps", sources = { [14]=30016, [15]=32755 }, classes = { 11 } },
                { id = 60285, slot = "Hands", name = "Stormrider's Gloves", sources = { [14]=30021, [15]=32760 }, classes = { 11 } },
                { id = 60290, slot = "Hands", name = "Stormrider's Grips", sources = { [14]=30026, [15]=32750 }, classes = { 11 } },
            },
        },
        {
            index              = 3,
            name               = "Atramedes",
            journalEncounterID = 171,
            aliases            = {},
            achievements       = {
                { id = 5308, name = "Silence is Golden", meta = true, soloable = "yes" },
                { id = 5109, name = "Heroic: Atramedes", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59316, slot = "Chest", name = "Battleplate of Ancient Kings", sources = { [14]=29568, [15]=32652 } },
                { id = 59318, slot = "Chest", name = "Sark of the Unwatched", sources = { [14]=29570, [15]=32650 } },
                { id = 59315, slot = "Feet", name = "Boots of Vertigo", sources = { [14]=29567, [15]=32653 } },
                { id = 59324, slot = "Hands", name = "Gloves of Cacophony", sources = { [14]=29574, [15]=32646 } },
                { id = 59312, slot = "Head", name = "Helm of the Blind Seer", sources = { [14]=29564, [15]=32656 } },
                { id = 59317, slot = "Legs", name = "Legguards of the Unseeing", sources = { [14]=29569, [15]=32651 } },
                { id = 59327, slot = "Off-hand", name = "Kingdom's Heart", sources = { [14]=29576, [15]=32644 } },
                { id = 59320, slot = "Ranged", name = "Themios the Darkbringer", sources = { [14]=29571, [15]=32649 } },
                { id = 59325, slot = "Shoulder", name = "Mantle of Roaring Flames", sources = { [14]=29575, [15]=32645 } },
                { id = 59322, slot = "Wrist", name = "Bracers of the Burningeye", sources = { [14]=29573, [15]=32647 } },
            },
        },
        {
            index              = 4,
            name               = "Chimaeron",
            journalEncounterID = 172,
            aliases            = {},
            achievements       = {
                { id = 5309, name = "Full of Sound and Fury", meta = true, soloable = "yes" },
                { id = 5115, name = "Heroic: Chimaeron", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59221, slot = "Feet", name = "Massacre Treads", sources = { [14]=29489, [15]=32663 } },
                { id = 59234, slot = "Feet", name = "Quickstep Galoshes", sources = { [14]=29493, [15]=32659 } },
                { id = 59313, slot = "Hands", name = "Brackish Gloves", sources = { [14]=29565, [15]=32655 } },
                { id = 59223, slot = "Hands", name = "Double Attack Handguards", sources = { [14]=29491, [15]=32661 } },
                { id = 59225, slot = "Hands", name = "Plated Fists of Provocation", sources = { [14]=29492, [15]=32660 } },
                { id = 59314, slot = "Ranged", name = "Pip's Solution Agitator", sources = { [14]=29566, [15]=32654 } },
                { id = 59311, slot = "Shoulder", name = "Burden of Mortality", sources = { [14]=29563, [15]=32657 } },
                { id = 59310, slot = "Wrist", name = "Chaos Beast Bracers", sources = { [14]=29562, [15]=32658 } },
                { id = 59355, slot = "Wrist", name = "Chimaeron Armguards", sources = { [14]=29599, [15]=32622 } },
                { id = 59451, slot = "Wrist", name = "Manacles of the Sleeping Beast", sources = { [14]=29675, [15]=32617 } },
            },
        },
        {
            index              = 5,
            name               = "Maloriak",
            journalEncounterID = 173,
            aliases            = {},
            achievements       = {
                { id = 5310, name = "Aberrant Behavior", meta = true, soloable = "yes" },
                { id = 5108, name = "Heroic: Maloriak", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59348, slot = "Back", name = "Cloak of Biting Chill", sources = { [14]=29593, [15]=32628 } },
                { id = 59346, slot = "Chest", name = "Tunic of Failed Experiments", sources = { [14]=29591, [15]=32630 } },
                { id = 59350, slot = "Feet", name = "Treads of Flawless Creation", sources = { [14]=29595, [15]=32626 } },
                { id = 59352, slot = "Hands", name = "Flash Freeze Gauntlets", sources = { [14]=29597, [15]=32624 } },
                { id = 59344, slot = "Head", name = "Dragon Bone Warhelm", sources = { [14]=29590, [15]=32631 } },
                { id = 59343, slot = "Legs", name = "Aberration's Leggings", sources = { [14]=29589, [15]=32632 } },
                { id = 59353, slot = "Legs", name = "Leggings of Consuming Flames", sources = { [14]=29598, [15]=32623 } },
                { id = 59351, slot = "Legs", name = "Legwraps of the Greatest Son", sources = { [14]=29596, [15]=32625 } },
                { id = 59342, slot = "Waist", name = "Belt of Absolute Zero", sources = { [14]=29588, [15]=32633 } },
                { id = 59349, slot = "Waist", name = "Belt of Arcane Storms", sources = { [14]=29594, [15]=32627 } },
                { id = 59347, slot = "Weapon", name = "Mace of Acrid Death", sources = { [14]=29592, [15]=32629 } },
                { id = 60324, slot = "Legs", name = "Earthen Legplates", sources = { [14]=30056, [15]=32828 }, classes = { 1 } },
                { id = 60330, slot = "Legs", name = "Earthen Legguards", sources = { [14]=30062, [15]=32833 }, classes = { 1 } },
                { id = 60347, slot = "Legs", name = "Reinforced Sapphirium Legplates", sources = { [14]=30074, [15]=32778 }, classes = { 2 } },
                { id = 60357, slot = "Legs", name = "Reinforced Sapphirium Legguards", sources = { [14]=30084, [15]=32788 }, classes = { 2 } },
                { id = 60361, slot = "Legs", name = "Reinforced Sapphirium Greaves", sources = { [14]=30088, [15]=32783 }, classes = { 2 } },
                { id = 60305, slot = "Legs", name = "Lightning-Charged Legguards", sources = { [14]=30037, [15]=32768 }, classes = { 3 } },
                { id = 60300, slot = "Legs", name = "Wind Dancer's Legguards", sources = { [14]=30032, [15]=32803 }, classes = { 4 } },
                { id = 60255, slot = "Legs", name = "Mercurial Leggings", sources = { [14]=30004, [15]=32797 }, classes = { 5 } },
                { id = 60261, slot = "Legs", name = "Mercurial Legwraps", sources = { [14]=30009, [15]=32792 }, classes = { 5 } },
                { id = 60342, slot = "Legs", name = "Magma Plated Legplates", sources = { [14]=30069, [15]=32743 }, classes = { 6 } },
                { id = 60352, slot = "Legs", name = "Magma Plated Legguards", sources = { [14]=30079, [15]=32748 }, classes = { 6 } },
                { id = 60310, slot = "Legs", name = "Legwraps of the Raging Elements", sources = { [14]=30042, [15]=32808 }, classes = { 7 } },
                { id = 60316, slot = "Legs", name = "Kilt of the Raging Elements", sources = { [14]=30048, [15]=32818 }, classes = { 7 } },
                { id = 60321, slot = "Legs", name = "Legguards of the Raging Elements", sources = { [14]=30053, [15]=32813 }, classes = { 7 } },
                { id = 60245, slot = "Legs", name = "Firelord's Leggings", sources = { [14]=29994, [15]=32772 }, classes = { 8 } },
                { id = 60250, slot = "Legs", name = "Shadowflame Leggings", sources = { [14]=29999, [15]=32822 }, classes = { 9 } },
                { id = 60278, slot = "Legs", name = "Stormrider's Legwraps", sources = { [14]=30014, [15]=32757 }, classes = { 11 } },
                { id = 60283, slot = "Legs", name = "Stormrider's Leggings", sources = { [14]=30019, [15]=32762 }, classes = { 11 } },
                { id = 60288, slot = "Legs", name = "Stormrider's Legguards", sources = { [14]=30024, [15]=32752 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 152967, kind = "pet", name = "Experiment-In-A-Jar" },
            },
        },
        {
            index              = 6,
            name               = "Nefarian's End",
            journalEncounterID = 174,
            aliases            = {},
            achievements       = {
                { id = 4849, name = "Keeping it in the Family", meta = true, soloable = "yes" },
                { id = 5116, name = "Heroic: Nefarian", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 59457, slot = "Back", name = "Shadow of Dread", sources = { [14]=29681, [15]=32614 } },
                { id = 59454, slot = "Chest", name = "Shadowblaze Robes", sources = { [14]=29678, [15]=32615 } },
                { id = 59444, slot = "Off-hand", name = "Akmin-Kurai, Dominion's Shield", sources = { [14]=29671, [15]=32619 } },
                { id = 59337, slot = "Shoulder", name = "Mantle of Nefarius", sources = { [14]=29585, [15]=32636 } },
                { id = 59356, slot = "Shoulder", name = "Pauldrons of the Apocalypse", sources = { [14]=29600, [15]=32621 } },
                { id = 59222, slot = "Shoulder", name = "Spaulders of the Scarred Lady", sources = { [14]=29490, [15]=32662 } },
                { id = 63679, slot = "Two-Hand", name = "Reclaimed Ashkandi, Greatsword of the Brotherhood", sources = { [14]=31994, [15]=32600 } },
                { id = 59450, slot = "Waist", name = "Belt of the Blackhand", sources = { [14]=29674, [15]=32618 } },
                { id = 59321, slot = "Waist", name = "Belt of the Nightmare", sources = { [14]=29572, [15]=32648 } },
                { id = 59459, slot = "Weapon", name = "Andoros, Fist of the Dragon King", sources = { [14]=29683, [15]=32613 } },
                { id = 59443, slot = "Weapon", name = "Crul'korak, the Lightning's Arc", sources = { [14]=29670, [15]=32620 } },
                { id = 60325, slot = "Head", name = "Earthen Helmet", sources = { [14]=30057, [15]=32827 }, classes = { 1 } },
                { id = 60328, slot = "Head", name = "Earthen Faceguard", sources = { [14]=30060, [15]=32832 }, classes = { 1 } },
                { id = 60346, slot = "Head", name = "Reinforced Sapphirium Helmet", sources = { [14]=30073, [15]=32777 }, classes = { 2 } },
                { id = 60356, slot = "Head", name = "Reinforced Sapphirium Faceguard", sources = { [14]=30083, [15]=32787 }, classes = { 2 } },
                { id = 60359, slot = "Head", name = "Reinforced Sapphirium Headguard", sources = { [14]=30086, [15]=32782 }, classes = { 2 } },
                { id = 60303, slot = "Head", name = "Lightning-Charged Headguard", sources = { [14]=30035, [15]=32767 }, classes = { 3 } },
                { id = 60299, slot = "Head", name = "Wind Dancer's Helmet", sources = { [14]=30031, [15]=32802 }, classes = { 4 } },
                { id = 60256, slot = "Head", name = "Mercurial Hood", sources = { [14]=30005, [15]=32796 }, classes = { 5 } },
                { id = 60258, slot = "Head", name = "Mercurial Cowl", sources = { [14]=30007, [15]=32791 }, classes = { 5 } },
                { id = 60341, slot = "Head", name = "Magma Plated Helmet", sources = { [14]=30068, [15]=32742 }, classes = { 6 } },
                { id = 60351, slot = "Head", name = "Magma Plated Faceguard", sources = { [14]=30078, [15]=32747 }, classes = { 6 } },
                { id = 60308, slot = "Head", name = "Faceguard of the Raging Elements", sources = { [14]=30040, [15]=32807 }, classes = { 7 } },
                { id = 60315, slot = "Head", name = "Headpiece of the Raging Elements", sources = { [14]=30047, [15]=32817 }, classes = { 7 } },
                { id = 60320, slot = "Head", name = "Helmet of the Raging Elements", sources = { [14]=30052, [15]=32812 }, classes = { 7 } },
                { id = 60243, slot = "Head", name = "Firelord's Hood", sources = { [14]=29992, [15]=32771 }, classes = { 8 } },
                { id = 60249, slot = "Head", name = "Shadowflame Hood", sources = { [14]=29998, [15]=32821 }, classes = { 9 } },
                { id = 60277, slot = "Head", name = "Stormrider's Helm", sources = { [14]=30013, [15]=32756 }, classes = { 11 } },
                { id = 60282, slot = "Head", name = "Stormrider's Cover", sources = { [14]=30018, [15]=32761 }, classes = { 11 } },
                { id = 60286, slot = "Head", name = "Stormrider's Headpiece", sources = { [14]=30022, [15]=32751 }, classes = { 11 } },
            },
            specialLoot = {
                { id = 152968, kind = "pet", name = "Shadowy Pile of Bones" },
                { id = 138802, kind = "illusion", name = "Illusion: Power Torrent", sourceID = 4097 },
            },
        },
    },

    routing = {

        -- 1. Omnotron Defense System
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Omnotron Defense System",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 285, subZone = "The Broken Hall" },
                    kind    = "path",
                    note    = "After zoning in, go up the stairs to the right to reach the ^Omnotron Defense System^.",
                    minNote = "Right to Omnotron",
                    points  = {
                        { 0.495, 0.594 },
                        { 0.582, 0.594 },
                        { 0.626, 0.574 },
                    },
                },
            },
        },

        -- 2. Magmaw
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Magmaw",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 285, subZone = "Stone Sentinel's Overlook" },
                    kind    = "path",
                    note    = "After defeating the ^Omnotron Defense System^, go back downstairs and proceed straight ahead to reach ^Magmaw^.",
                    minNote = "Downstairs across to Magmaw",
                    points  = {
                        { 0.606, 0.572 },
                        { 0.583, 0.596 },
                        { 0.352, 0.592 },
                        { 0.302, 0.586 },
                    },
                },
            },
        },

        -- 3. Maloriak (boss 5 in the journal; killed third on the solo route)
        {
            step      = 3,
            priority  = 3,
            bossIndex = 5,
            title     = "Maloriak",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 285, subZone = "The Broken Hall" },
                    kind    = "path",
                    note    = "After killing ^Magmaw^, go back down the stairs to the main lobby. Take a left and ride the elevator down.",
                    minNote = "Left Elevator down",
                    points  = {
                        { 0.302, 0.574 },
                        { 0.338, 0.573 },
                        { 0.353, 0.595 },
                        { 0.427, 0.596 },
                        { 0.470, 0.540 },
                        { 0.470, 0.444 },
                    },
                },
                {
                    when    = { mapID = 286, subZone = "Vault of the Shadowflame" },
                    kind    = "path",
                    note    = "After reaching the bottom of the elevator, take a right and follow the path to reach ^Maloriak^.",
                    minNote = "Right to Maloriak",
                    points  = {
                        { 0.475, 0.834 },
                        { 0.541, 0.785 },
                        { 0.563, 0.696 },
                        { 0.625, 0.698 },
                        { 0.626, 0.677 },
                        { 0.644, 0.677 },
                        { 0.646, 0.694 },
                        { 0.689, 0.698 },
                    },
                },
            },
        },

        -- 4. Atramedes (boss 3 in the journal; killed fourth on the solo route)
        {
            step      = 4,
            priority  = 4,
            bossIndex = 3,
            title     = "Atramedes",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 286, subZone = "Fleshrender's Workshop" },
                    kind    = "path",
                    note    = "After defeating ^Maloriak^, exit back to the main ring and head to the north exit. Kill trash, then hit the large bell at the back of the room to begin the encounter with ^Atramedes^.",
                    minNote = "North, Trash then Bell",
                    points  = {
                        { 0.682, 0.697 },
                        { 0.563, 0.694 },
                        { 0.543, 0.603 },
                        { 0.475, 0.558 },
                        { 0.473, 0.367 },
                    },
                },
            },
        },

        -- 5. Chimaeron (boss 4 in the journal; killed fifth on the solo route)
        {
            step      = 5,
            priority  = 5,
            bossIndex = 4,
            title     = "Chimaeron",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 286, subZone = "The Athenaeum" },
                    kind    = "path",
                    note    = "After killing ^Atramedes^, go back out to the main ring and head to the western ring to fight ^Chimaeron^.",
                    minNote = "West to Chimaeron",
                    points  = {
                        { 0.473, 0.392 },
                        { 0.474, 0.562 },
                        { 0.411, 0.603 },
                        { 0.375, 0.692 },
                        { 0.269, 0.696 },
                    },
                },
            },
        },

        -- 6. Nefarian's End
        {
            step      = 6,
            priority  = 6,
            bossIndex = 6,
            title     = "Nefarian's End",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 286, subZone = "Den of the Devourer" },
                    kind    = "path",
                    note    = "After defeating ^Chimaeron^, go back out to the main ring and follow the path to the ^Orb of Culmination^. Interact with it to begin the encounter with ^Nefarian^.",
                    minNote = "Click Orb of Culmination",
                    points  = {
                        { 0.271, 0.696 },
                        { 0.385, 0.694 },
                        { 0.413, 0.602 },
                    },
                },
                {
                    when        = { mapID = 286, subZone = "Den of the Devourer" },
                    kind        = "poi",
                    noMarker    = true,
                    mapLabel    = "Click Orb",
                    mapLabelPos = "middle",
                    points      = {
                        { 0.465, 0.582 },
                    },
                },
            },
        },
    },
}
