-------------------------------------------------------------------------------
-- RetroRuns Data -- Karazhan
-- Burning Crusade, Patch 2.0.3  |  instanceID: 532  |  journalInstanceID: 745
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[532] = {
    instanceID        = 532,
    journalInstanceID = 745,
    name              = "Karazhan",
    expansion         = "Burning Crusade",
    patch             = "2.0.3",

    exitNote          = "None available",
    minExitNote       = "None available",

    -- The raid runs at 10-player only. One difficulty, one weekly lockout.
    difficultyModel   = "single",

    entrance = {
        -- Deadwind Pass, at the foot of the tower.
        mapID = 42, x = 0.468, y = 0.746,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [350] = "Servant's Quarters",
        [351] = "Upper Livery Stables",
        [352] = "The Banquet Hall",
        [353] = "The Guest Chambers",
        [354] = "Opera Hall Balcony",
        [355] = "Master's Terrace",
        [356] = "Lower Broken Stair",
        [357] = "Upper Broken Stair",
        [358] = "The Menagerie",
        [359] = "Guardian's Library",
        [360] = "The Repository",
        [361] = "Upper Library",
        [362] = "The Celestial Watch",
        [363] = "Gamesman's Hall",
        [364] = "Medivh's Chambers",
        [365] = "The Power Station",
        [366] = "Netherspace",
    },

    tierSets = {
        labels       = {},
        tokenSources = {
            [29756] = 5,   -- Gloves of the Fallen Hero
            [29757] = 5,   -- Gloves of the Fallen Champion
            [29758] = 5,   -- Gloves of the Fallen Defender
            [29759] = 10,  -- Helm of the Fallen Hero
            [29760] = 10,  -- Helm of the Fallen Champion
            [29761] = 10,  -- Helm of the Fallen Defender
        },
    },


    -- Drops that belong to the raid rather than to any of its encounters.
    -- Two kinds sit here. Most are ordinary trash drops, which the Encounter
    -- Journal does not index at all. The Lurker's, Glider's and Ravager's
    -- sets come from the three rare spawns in the Servant's Quarters --
    -- Hyakiss the Lurker, Shadikith the Glider and Rokad the Ravager, one
    -- set each. Only one of the three is up per lockout. The journal does
    -- list those twelve, but under a room entry that reports no kill, so
    -- they cannot hang off a boss.
    trashLoot = {
        { id = 30642, slot = "Back", name = "Drape of the Righteous", sources = { [14]=13829 }, bind = "BoP" },
        { id = 30641, slot = "Feet", name = "Boots of Elusion", sources = { [14]=13828 }, bind = "BoP" },
        { id = 30681, slot = "Feet", name = "Glider's Boots", sources = { [14]=13848 }, bind = "BoP" },
        { id = 30680, slot = "Feet", name = "Glider's Foot-Wraps", sources = { [14]=13847 }, bind = "BoP" },
        { id = 30683, slot = "Feet", name = "Glider's Greaves", sources = { [14]=13850 }, bind = "BoP" },
        { id = 30682, slot = "Feet", name = "Glider's Sabatons", sources = { [14]=13849 }, bind = "BoP" },
        { id = 30674, slot = "Feet", name = "Zierhut's Lost Treads", sources = { [14]=13842 }, bind = "BoP" },
        { id = 30668, slot = "Hands", name = "Grasp of the Dead", sources = { [14]=13837 }, bind = "BoP" },
        { id = 30644, slot = "Hands", name = "Grips of Deftness", sources = { [14]=13831 }, bind = "BoP" },
        { id = 30643, slot = "Waist", name = "Belt of the Tracker", sources = { [14]=13830 }, bind = "BoP" },
        { id = 30673, slot = "Waist", name = "Inferno Waist Cord", sources = { [14]=13841 }, bind = "BoP" },
        { id = 30677, slot = "Waist", name = "Lurker's Belt", sources = { [14]=13845 }, bind = "BoP" },
        { id = 30675, slot = "Waist", name = "Lurker's Cord", sources = { [14]=13843 }, bind = "BoP" },
        { id = 30678, slot = "Waist", name = "Lurker's Girdle", sources = { [14]=13846 }, bind = "BoP" },
        { id = 30676, slot = "Waist", name = "Lurker's Grasp", sources = { [14]=13844 }, bind = "BoP" },
        { id = 30686, slot = "Wrist", name = "Ravager's Bands", sources = { [14]=13853 }, bind = "BoP" },
        { id = 30687, slot = "Wrist", name = "Ravager's Bracers", sources = { [14]=13854 }, bind = "BoP" },
        { id = 30684, slot = "Wrist", name = "Ravager's Cuffs", sources = { [14]=13851 }, bind = "BoP" },
        { id = 30685, slot = "Wrist", name = "Ravager's Wrist-Wraps", sources = { [14]=13852 }, bind = "BoP" },
    },
    bosses = {
        {
            index              = 1,
            name               = "Attumen the Huntsman",
            journalEncounterID = 1553,
            dungeonEncounterID = 652,
            achievements       = {},
            loot = {
                { id = 28505, slot = "Hands", name = "Gauntlets of Renewed Hope", sources = { [14]=12513 } },
                { id = 28506, slot = "Hands", name = "Gloves of Dexterous Manipulation", sources = { [14]=12514 } },
                { id = 28508, slot = "Hands", name = "Gloves of Saintly Blessings", sources = { [14]=12516 } },
                { id = 28507, slot = "Hands", name = "Handwraps of Flowing Thought", sources = { [14]=12515 } },
                { id = 28504, slot = "Ranged", name = "Steelhawk Crossbow", sources = { [14]=12512 } },
                { id = 28453, slot = "Wrist", name = "Bracers of the White Stag", sources = { [14]=12491 } },
                { id = 28477, slot = "Wrist", name = "Harbinger Bands", sources = { [14]=12495 } },
                { id = 28454, slot = "Wrist", name = "Stalker's War Bands", sources = { [14]=12492 } },
                { id = 28502, slot = "Wrist", name = "Vambraces of Courage", sources = { [14]=12510 } },
                { id = 28503, slot = "Wrist", name = "Whirlwind Bracers", sources = { [14]=12511 } },
            },
            specialLoot = {
                { id = 30480, kind = "mount", name = "Fiery Warhorse's Reins", mountID = 168 },
            },
        },
        {
            index              = 2,
            name               = "Moroes",
            journalEncounterID = 1554,
            dungeonEncounterID = 653,
            achievements       = {},
            loot = {
                { id = 28529, slot = "Back", name = "Royal Cloak of Arathi Kings", sources = { [14]=12529 } },
                { id = 28570, slot = "Back", name = "Shadow-Cloak of Dalaran", sources = { [14]=12553 } },
                { id = 28569, slot = "Feet", name = "Boots of Valiance", sources = { [14]=12552 } },
                { id = 28545, slot = "Feet", name = "Edgewalker Longboots", sources = { [14]=12544 } },
                { id = 28525, slot = "Held In Off-hand", name = "Signet of Unshakable Faith", sources = { [14]=12528 } },
                { id = 28567, slot = "Waist", name = "Belt of Gale Force", sources = { [14]=12551 } },
                { id = 28566, slot = "Waist", name = "Crimson Girdle of the Indomitable", sources = { [14]=12550 } },
                { id = 28565, slot = "Waist", name = "Nethershard Girdle", sources = { [14]=12549 } },
                { id = 28524, slot = "Weapon", name = "Emerald Ripper", sources = { [14]=12527 } },
            },
            specialLoot = {
                { id = 138797, kind = "illusion", name = "Illusion: Mongoose", sourceID = 2673 },
            },
        },
        {
            index              = 3,
            name               = "Maiden of Virtue",
            journalEncounterID = 1555,
            dungeonEncounterID = 654,
            achievements       = {},
            loot = {
                { id = 28517, slot = "Feet", name = "Boots of Foretelling", sources = { [14]=12521 } },
                { id = 28520, slot = "Hands", name = "Gloves of Centering", sources = { [14]=12524 } },
                { id = 28519, slot = "Hands", name = "Gloves of Quickening", sources = { [14]=12523 } },
                { id = 28518, slot = "Hands", name = "Iron Gauntlets of the Maiden", sources = { [14]=12522 } },
                { id = 28521, slot = "Hands", name = "Mitts of the Treemender", sources = { [14]=12525 } },
                { id = 28522, slot = "Weapon", name = "Shard of the Virtuous", sources = { [14]=12526 } },
                { id = 28511, slot = "Wrist", name = "Bands of Indwelling", sources = { [14]=12517 } },
                { id = 28515, slot = "Wrist", name = "Bands of Nefarious Deeds", sources = { [14]=12520 } },
                { id = 28512, slot = "Wrist", name = "Bracers of Justice", sources = { [14]=12518 } },
                { id = 28514, slot = "Wrist", name = "Bracers of Maliciousness", sources = { [14]=12519 } },
            },
        },
        {
            index              = 4,
            name               = "Opera Hall",
            journalEncounterID = 1556,
            dungeonEncounterID = 655,
            aliases            = { "Opera Event" },
            achievements       = {},
            loot = {
                { id = 28582, slot = "Back", name = "Red Riding Hood's Cloak", sources = { [14]=12562 } },
                { id = 28578, slot = "Chest", name = "Masquerade Gown", sources = { [14]=12560 } },
                { id = 28585, slot = "Feet", name = "Ruby Slippers", sources = { [14]=12565 } },
                { id = 28583, slot = "Head", name = "Big Bad Wolf's Head", sources = { [14]=12563 } },
                { id = 28593, slot = "Head", name = "Eternium Greathelm", sources = { [14]=12571 } },
                { id = 28586, slot = "Head", name = "Wicked Witch's Hat", sources = { [14]=12566 } },
                { id = 28591, slot = "Legs", name = "Earthsoul Leggings", sources = { [14]=12570 } },
                { id = 28594, slot = "Legs", name = "Trial-Fire Trousers", sources = { [14]=12572 } },
                { id = 28588, slot = "Ranged", name = "Blue Diamond Witchwand", sources = { [14]=12568 } },
                { id = 28581, slot = "Ranged", name = "Wolfslayer Sniper Rifle", sources = { [14]=12561 } },
                { id = 28589, slot = "Shoulder", name = "Beastmaw Pauldrons", sources = { [14]=12569 } },
                { id = 28573, slot = "Two-Hand", name = "Despair", sources = { [14]=12555 } },
                { id = 28587, slot = "Two-Hand", name = "Legacy", sources = { [14]=12567 } },
                { id = 28584, slot = "Weapon", name = "Big Bad Wolf's Paw", sources = { [14]=12564 } },
                { id = 28572, slot = "Weapon", name = "Blade of the Unrequited", sources = { [14]=12554 } },
            },
            specialLoot = {
                -- Beast battle pet, part of the Raiding with Leashes II
                -- pet collection.
                { id = 97548, kind = "pet", name = "Lil' Bad Wolf" },
            },
        },
        {
            index              = 5,
            name               = "The Curator",
            journalEncounterID = 1557,
            dungeonEncounterID = 656,
            achievements       = {},
            loot = {
                { id = 29039, slot = "Hands", name = "Cyclone Gauntlets", sources = { [14]=12918 }, classes = { 7 } },
                { id = 29032, slot = "Hands", name = "Cyclone Gloves", sources = { [14]=12911 }, classes = { 7 } },
                { id = 29034, slot = "Hands", name = "Cyclone Handguards", sources = { [14]=12913 }, classes = { 7 } },
                { id = 29085, slot = "Hands", name = "Demon Stalker Gauntlets", sources = { [14]=12961 }, classes = { 3 } },
                { id = 29097, slot = "Hands", name = "Gauntlets of Malorne", sources = { [14]=12973 }, classes = { 11 } },
                { id = 29092, slot = "Hands", name = "Gloves of Malorne", sources = { [14]=12968 }, classes = { 11 } },
                { id = 29080, slot = "Hands", name = "Gloves of the Aldor", sources = { [14]=12956 }, classes = { 8 } },
                { id = 29057, slot = "Hands", name = "Gloves of the Incarnate", sources = { [14]=12933 }, classes = { 5 } },
                { id = 29090, slot = "Hands", name = "Handguards of Malorne", sources = { [14]=12966 }, classes = { 11 } },
                { id = 29055, slot = "Hands", name = "Handwraps of the Incarnate", sources = { [14]=12931 }, classes = { 5 } },
                { id = 29072, slot = "Hands", name = "Justicar Gauntlets", sources = { [14]=12948 }, classes = { 2 } },
                { id = 29065, slot = "Hands", name = "Justicar Gloves", sources = { [14]=12941 }, classes = { 2 } },
                { id = 29067, slot = "Hands", name = "Justicar Handguards", sources = { [14]=12943 }, classes = { 2 } },
                { id = 29048, slot = "Hands", name = "Netherblade Gloves", sources = { [14]=12926 }, classes = { 4 } },
                { id = 28968, slot = "Hands", name = "Voidheart Gloves", sources = { [14]=12855 }, classes = { 9 } },
                { id = 29020, slot = "Hands", name = "Warbringer Gauntlets", sources = { [14]=12903 }, classes = { 1 } },
                { id = 29017, slot = "Hands", name = "Warbringer Handguards", sources = { [14]=12901 }, classes = { 1 } },
                { id = 28621, slot = "Legs", name = "Wrynn Dynasty Greaves", sources = { [14]=12594 } },
                { id = 28631, slot = "Shoulder", name = "Dragon-Quake Shoulderguards", sources = { [14]=12604 } },
                { id = 28647, slot = "Shoulder", name = "Forest Wind Shoulderpads", sources = { [14]=12615 } },
                { id = 28612, slot = "Shoulder", name = "Pauldrons of the Solace-Giver", sources = { [14]=12585 } },
                { id = 28633, slot = "Two-Hand", name = "Staff of Infinite Mysteries", sources = { [14]=12605 } },
            },
            specialLoot = {
                -- Mechanical battle pet, part of the Raiding with Leashes
                -- II pet collection.
                { id = 97549, kind = "pet", name = "Menagerie Custodian" },
            },
        },
        {
            index              = 6,
            name               = "Shade of Aran",
            journalEncounterID = 1559,
            dungeonEncounterID = 658,
            achievements       = {},
            loot = {
                { id = 28672, slot = "Back", name = "Drape of the Dark Reavers", sources = { [14]=12633 } },
                { id = 28663, slot = "Feet", name = "Boots of the Incorrupt", sources = { [14]=12628 } },
                { id = 28670, slot = "Feet", name = "Boots of the Infernal Coven", sources = { [14]=12631 } },
                { id = 28669, slot = "Feet", name = "Rapscallion Boots", sources = { [14]=12630 } },
                { id = 28671, slot = "Head", name = "Steelspine Faceguard", sources = { [14]=12632 } },
                { id = 28728, slot = "Held In Off-hand", name = "Aran's Soothing Sapphire", sources = { [14]=12682 } },
                { id = 28673, slot = "Ranged", name = "Tirisfal Wand of Ascendancy", sources = { [14]=12634 } },
                { id = 28726, slot = "Shoulder", name = "Mantle of the Mind Flayer", sources = { [14]=12681 } },
                { id = 28666, slot = "Shoulder", name = "Pauldrons of the Justice-Seeker", sources = { [14]=12629 } },
            },
            specialLoot = {
                { id = 138798, kind = "illusion", name = "Illusion: Sunfire", sourceID = 5865 },
            },
        },
        {
            index              = 7,
            name               = "Terestian Illhoof",
            journalEncounterID = 1560,
            dungeonEncounterID = 657,
            achievements       = {},
            loot = {
                { id = 28660, slot = "Back", name = "Gilded Thorium Cloak", sources = { [14]=12626 } },
                { id = 28653, slot = "Back", name = "Shadowvine Cloak of Infusion", sources = { [14]=12619 } },
                { id = 28662, slot = "Chest", name = "Breastplate of the Lightbinder", sources = { [14]=12627 } },
                { id = 28658, slot = "Two-Hand", name = "Terestian's Stranglestaff", sources = { [14]=12624 } },
                { id = 28652, slot = "Waist", name = "Cincture of Will", sources = { [14]=12618 } },
                { id = 28655, slot = "Waist", name = "Cord of Nature's Sustenance", sources = { [14]=12621 } },
                { id = 28656, slot = "Waist", name = "Girdle of the Prowler", sources = { [14]=12622 } },
                { id = 28654, slot = "Waist", name = "Malefic Girdle", sources = { [14]=12620 } },
                { id = 28657, slot = "Weapon", name = "Fool's Bane", sources = { [14]=12623 } },
            },
            specialLoot = {
                -- Demon battle pet, part of the Raiding with Leashes II
                -- pet collection.
                { id = 97551, kind = "pet", name = "Fiendish Imp" },
                { id = 138799, kind = "illusion", name = "Illusion: Soulfrost", sourceID = 5866 },
            },
        },
        {
            index              = 8,
            name               = "Netherspite",
            journalEncounterID = 1561,
            dungeonEncounterID = 659,
            achievements       = {},
            loot = {
                { id = 28735, slot = "Chest", name = "Earthblood Chestguard", sources = { [14]=12687 } },
                { id = 28732, slot = "Head", name = "Cowl of Defiance", sources = { [14]=12684 } },
                { id = 28744, slot = "Head", name = "Uni-Mind Headdress", sources = { [14]=12696 } },
                { id = 28734, slot = "Held In Off-hand", name = "Jewel of Infinite Possibilities", sources = { [14]=12686 } },
                { id = 28742, slot = "Legs", name = "Pantaloons of Repentance", sources = { [14]=12694 } },
                { id = 28740, slot = "Legs", name = "Rip-Flayer Leggings", sources = { [14]=12692 } },
                { id = 28741, slot = "Legs", name = "Skulker's Greaves", sources = { [14]=12693 } },
                { id = 28743, slot = "Shoulder", name = "Mantle of Abrahmis", sources = { [14]=12695 } },
                { id = 28733, slot = "Waist", name = "Girdle of Truth", sources = { [14]=12685 } },
                { id = 28729, slot = "Weapon", name = "Spiteblade", sources = { [14]=12683 } },
            },
        },
        {
            index              = 9,
            name               = "Chess Event",
            journalEncounterID = 1562,
            dungeonEncounterID = 660,
            soloTip            = "Kill the enemy king before yours dies. The easy button: take control of your king and spam Heroism or Bloodlust until it's over. It takes a few minutes, but it works.",
            achievements       = {},
            loot = {
                { id = 28747, slot = "Feet", name = "Battlescar Boots", sources = { [14]=12698 } },
                { id = 28746, slot = "Feet", name = "Fiend Slayer Boots", sources = { [14]=12697 } },
                { id = 28752, slot = "Feet", name = "Forestlord Striders", sources = { [14]=12703 } },
                { id = 28756, slot = "Head", name = "Headdress of the High Potentate", sources = { [14]=12706 } },
                { id = 28751, slot = "Legs", name = "Heart-Flame Leggings", sources = { [14]=12702 } },
                { id = 28748, slot = "Legs", name = "Legplates of the Innocent", sources = { [14]=12699 } },
                { id = 28754, slot = "Off-hand", name = "Triptych Shield of the Ancients", sources = { [14]=12704 } },
                { id = 28755, slot = "Shoulder", name = "Bladed Shoulderpads of the Merciless", sources = { [14]=12705 } },
                { id = 28750, slot = "Waist", name = "Girdle of Treachery", sources = { [14]=12701 } },
                { id = 28749, slot = "Weapon", name = "King's Defender", sources = { [14]=12700 } },
            },
        },
        {
            index              = 10,
            name               = "Prince Malchezaar",
            journalEncounterID = 1563,
            dungeonEncounterID = 661,
            achievements       = {},
            loot = {
                { id = 28764, slot = "Back", name = "Farstrider Wildercloak", sources = { [14]=12711 } },
                { id = 28766, slot = "Back", name = "Ruby Drape of the Mysticant", sources = { [14]=12713 } },
                { id = 28765, slot = "Back", name = "Stainless Cloak of the Pure Hearted", sources = { [14]=12712 } },
                { id = 29093, slot = "Head", name = "Antlers of Malorne", sources = { [14]=12969 }, classes = { 11 } },
                { id = 29076, slot = "Head", name = "Collar of the Aldor", sources = { [14]=12952 }, classes = { 8 } },
                { id = 29086, slot = "Head", name = "Crown of Malorne", sources = { [14]=12962 }, classes = { 11 } },
                { id = 29035, slot = "Head", name = "Cyclone Faceguard", sources = { [14]=12914 }, classes = { 7 } },
                { id = 29028, slot = "Head", name = "Cyclone Headdress", sources = { [14]=12907 }, classes = { 7 } },
                { id = 29040, slot = "Head", name = "Cyclone Helm", sources = { [14]=12919 }, classes = { 7 } },
                { id = 29081, slot = "Head", name = "Demon Stalker Greathelm", sources = { [14]=12957 }, classes = { 3 } },
                { id = 29073, slot = "Head", name = "Justicar Crown", sources = { [14]=12949 }, classes = { 2 } },
                { id = 29061, slot = "Head", name = "Justicar Diadem", sources = { [14]=12937 }, classes = { 2 } },
                { id = 29068, slot = "Head", name = "Justicar Faceguard", sources = { [14]=12944 }, classes = { 2 } },
                { id = 29049, slot = "Head", name = "Light-Collar of the Incarnate", sources = { [14]=12927 }, classes = { 5 } },
                { id = 29044, slot = "Head", name = "Netherblade Facemask", sources = { [14]=12922 }, classes = { 4 } },
                { id = 29058, slot = "Head", name = "Soul-Collar of the Incarnate", sources = { [14]=12934 }, classes = { 5 } },
                { id = 29098, slot = "Head", name = "Stag-Helm of Malorne", sources = { [14]=12974 }, classes = { 11 } },
                { id = 28963, slot = "Head", name = "Voidheart Crown", sources = { [14]=12850 }, classes = { 9 } },
                { id = 29021, slot = "Head", name = "Warbringer Battle-Helm", sources = { [14]=12904 }, classes = { 1 } },
                { id = 29011, slot = "Head", name = "Warbringer Greathelm", sources = { [14]=12895 }, classes = { 1 } },
                { id = 28772, slot = "Ranged", name = "Sunfury Bow of the Phoenix", sources = { [14]=12718 } },
                { id = 28773, slot = "Two-Hand", name = "Gorehowl", sources = { [14]=12719 } },
                { id = 28771, slot = "Weapon", name = "Light's Justice", sources = { [14]=12717 } },
                { id = 28768, slot = "Weapon", name = "Malchazeen", sources = { [14]=12715 } },
                { id = 28770, slot = "Weapon", name = "Nathrezim Mindblade", sources = { [14]=12716 } },
                { id = 28767, slot = "Weapon", name = "The Decapitator", sources = { [14]=12714 } },
            },
            specialLoot = {
                -- Demon battle pet, part of the Raiding with Leashes II
                -- pet collection.
                { id = 97550, kind = "pet", name = "Netherspace Abyssal" },
            },
        },
        {
            index              = 11,
            name               = "Nightbane",
            dungeonEncounterID = 662,
            achievements       = {},
            -- Nightbane is a summoned optional boss with no Encounter
            -- Journal entry, so his drops carry no JournalEncounterItem
            -- rows. Every sourceID below resolved from
            -- ItemModifiedAppearance the same way as every other row here.
            loot = {
                { id = 28601, slot = "Chest", name = "Chestguard of the Conniver", sources = { [14]=12576 } },
                { id = 28597, slot = "Chest", name = "Panzar'Thar Breastplate", sources = { [14]=12573 } },
                { id = 28602, slot = "Chest", name = "Robe of the Elder Scribes", sources = { [14]=12577 } },
                { id = 28599, slot = "Chest", name = "Scaled Breastplate of Carnage", sources = { [14]=12574 } },
                { id = 28600, slot = "Chest", name = "Stonebough Jerkin", sources = { [14]=12575 } },
                { id = 28610, slot = "Feet", name = "Ferocious Swift-Kickers", sources = { [14]=12583 } },
                { id = 28608, slot = "Feet", name = "Ironstriders of Urgency", sources = { [14]=12582 } },
                { id = 28603, slot = "Held In Off-hand", name = "Talisman of Nightbane", sources = { [14]=12578 } },
                { id = 28611, slot = "Off-hand", name = "Dragonheart Flameshield", sources = { [14]=12584 } },
                { id = 28606, slot = "Off-hand", name = "Shield of Impenetrable Darkness", sources = { [14]=12581 } },
                { id = 28604, slot = "Two-Hand", name = "Nightstaff of the Everliving", sources = { [14]=12579 } },
            },
        },
    },

    -- Always-on map markers, shown regardless of the current step: vendors,
    -- doors/tunnels, hand-authored points. Not tied to routing.
    pois = {
        { mapID = 361, poiKind = "vendor", mapLabel = "Vendor NPC",
          mapLabelPos = "below", points = { { 0.443, 0.271 } } },
    },

    routing = {

        -- 1. Attumen the Huntsman
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Attumen the Huntsman",
            requires  = { },
            segments  = {
                {
                    -- Gated on the map alone. The note covers a walk out of
                    -- the Gatehouse and up through the stables, so a
                    -- sub-zone gate would stop matching as soon as the
                    -- player sets off.
                    when    = { mapID = 350 },
                    kind    = "path",
                    note    = "After zoning in, proceed up to the left and work your way through the ^Livery Stables^ until you reach ^Attumen the Huntsman^.",
                    minNote = "Left to Huntsman",
                    points  = {
                        { 0.575, 0.738 },
                        { 0.548, 0.704 },
                        { 0.514, 0.708 },
                        { 0.492, 0.732 },
                        { 0.486, 0.760 },
                        { 0.509, 0.807 },
                        { 0.477, 0.888 },
                        { 0.426, 0.877 },
                        { 0.434, 0.861 },
                    },
                },
            },
        },

        -- 2. Moroes
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Moroes",
            requires  = { },
            segments  = {
                {
                    -- Gated on the map alone: the note covers a backtrack
                    -- out of the stables, so a sub-zone gate would stop
                    -- matching as soon as the player sets off.
                    when    = { mapID = 350 },
                    kind    = "path",
                    note    = "After killing ^Attumen the Huntsman^, backtrack towards the entrance and take the stairs behind ^Berthold^.",
                    minNote = "Backtrack then upstairs",
                    points  = {
                        { 0.434, 0.859 },
                        { 0.436, 0.883 },
                        { 0.477, 0.894 },
                        { 0.505, 0.816 },
                        { 0.480, 0.742 },
                        { 0.516, 0.703 },
                        { 0.529, 0.639 },
                    },
                },
                {
                    when    = { mapID = 352 },
                    kind    = "path",
                    note    = "Continue up the stairs into ^The Grand Ballroom^. Take a left into ^The Banquet Hall^ and find ^Moroes^ up on a small platform.",
                    minNote = "Moroes in Banquet Hall",
                    points  = {
                        { 0.532, 0.828 },
                        { 0.555, 0.570 },
                        { 0.453, 0.553 },
                        { 0.299, 0.637 },
                    },
                },
            },
        },

        -- 3. Maiden of Virtue
        {
            step      = 3,
            priority  = 3,
            bossIndex = 3,
            title     = "Maiden of Virtue",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 352 },
                    kind    = "path",
                    note    = "After killing ^Moroes^, backtrack to ^The Grand Ballroom^ and climb the stairwell on the north end of the room.",
                    minNote = "Grand Ballroom north stairs",
                    points  = {
                        { 0.323, 0.639 },
                        { 0.465, 0.551 },
                        { 0.597, 0.566 },
                        { 0.665, 0.480 },
                        { 0.669, 0.423 },
                        { 0.736, 0.425 },
                        { 0.738, 0.376 },
                        { 0.677, 0.366 },
                    },
                },
                {
                    when    = { mapID = 353 },
                    kind    = "path",
                    note    = "From the top of the stairs, take your first right. Travel east down the hallway until you reach ^Maiden of Virtue^.",
                    minNote = "Path to Maiden of Virtue",
                    points  = {
                        { 0.653, 0.422 },
                        { 0.562, 0.383 },
                        { 0.566, 0.311 },
                        { 0.636, 0.317 },
                        { 0.695, 0.348 },
                        { 0.812, 0.469 },
                    },
                },
            },
        },

        -- 4. Opera Hall
        {
            step      = 4,
            priority  = 4,
            bossIndex = 4,
            title     = "Opera Hall",
            requires  = { },
            segments  = {
                {
                    -- Bare mapID so the note holds for the whole walk. The
                    -- POI below shares this mapID and narrows to the hall,
                    -- which releases the stay-here pin on arrival.
                    when    = { mapID = 353 },
                    kind    = "path",
                    note    = "After defeating ^Maiden of Virtue^, follow the long, winding path until you reach ^Barnes^. Talk to him to start the ^Opera Hall^ encounter.",
                    minNote = "Path to Barnes to start Opera",
                    points  = {
                        { 0.773, 0.422 },
                        { 0.669, 0.331 },
                        { 0.567, 0.306 },
                        { 0.560, 0.405 },
                        { 0.402, 0.384 },
                        { 0.405, 0.330 },
                        { 0.381, 0.287 },
                        { 0.349, 0.256 },
                        { 0.321, 0.240 },
                        { 0.287, 0.233 },
                        { 0.233, 0.222 },
                        { 0.235, 0.186 },
                        { 0.255, 0.189 },
                        { 0.238, 0.277 },
                        { 0.215, 0.347 },
                        { 0.198, 0.425 },
                        { 0.113, 0.415 },
                        { 0.124, 0.251 },
                        { 0.213, 0.274 },
                        { 0.193, 0.310 },
                    },
                },
                {
                    -- Noteless, inheriting the path note above so both
                    -- draw on the map together.
                    when        = { mapID = 353, subZone = "The Opera Hall" },
                    kind        = "poi",
                    mapLabel    = "Talk to Barnes",
                    mapLabelPos = "above",
                    points      = {
                        { 0.219, 0.272 },
                    },
                },
            },
        },

        -- 5. Nightbane
        -- Routed fifth but listed eleventh: he has no Encounter Journal
        -- entry, so he sits at the end of the boss list while the route
        -- takes him in the order the tower is walked.
        {
            step      = 5,
            priority  = 5,
            bossIndex = 11,
            title     = "Nightbane",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 353 },
                    kind    = "path",
                    note    = "After defeating ^Opera Hall^, go up the ramp on the south side of the stage.",
                    minNote = "Up ramp to south",
                    points  = {
                        { 0.201, 0.414 },
                        { 0.195, 0.443 },
                        { 0.194, 0.472 },
                        { 0.202, 0.490 },
                        { 0.220, 0.500 },
                        { 0.243, 0.495 },
                    },
                },
                {
                    when    = { mapID = 354 },
                    kind    = "path",
                    note    = "Continue north through the ^Opera Hall Balcony^ and climb the ramp at the end.",
                    minNote = "Wrap around to ramp",
                    points  = {
                        { 0.456, 0.847 },
                        { 0.617, 0.837 },
                        { 0.740, 0.768 },
                        { 0.780, 0.570 },
                        { 0.763, 0.412 },
                        { 0.679, 0.326 },
                        { 0.692, 0.278 },
                        { 0.622, 0.229 },
                        { 0.633, 0.192 },
                    },
                },
                {
                    when    = { mapID = 355 },
                    kind    = "path",
                    note    = "Work your way down the long southeast path towards ^Master's Terrace^.",
                    minNote = "Southeast to Master's Terrace",
                    points  = {
                        { 0.424, 0.174 },
                        { 0.445, 0.229 },
                        { 0.440, 0.300 },
                        { 0.429, 0.355 },
                        { 0.488, 0.463 },
                        { 0.450, 0.501 },
                        { 0.460, 0.520 },
                        { 0.484, 0.499 },
                        { 0.534, 0.548 },
                        { 0.580, 0.615 },
                        { 0.621, 0.696 },
                        { 0.591, 0.737 },
                        { 0.589, 0.835 },
                        { 0.575, 0.900 },
                        { 0.540, 0.932 },
                    },
                },
                {
                    when        = { mapID = 355, subZone = "Master's Terrace" },
                    kind        = "poi",
                    note        = "Once you reach ^Master's Terrace^, loop around and click on the ^Blackened Urn^. After a short delay, ^Nightbane^ will fly in to be killed by you.",
                    minNote     = "Click on Blackened Urn",
                    mapLabel    = "Click Urn",
                    mapLabelPos = "above",
                    points      = {
                        { 0.427, 0.826 },
                    },
                },
            },
        },

        -- 6. The Curator
        {
            step      = 6,
            priority  = 6,
            bossIndex = 5,
            title     = "The Curator",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 355 },
                    kind    = "path",
                    note    = "After defeating ^Nightbane^, exit to the east (the way you came in). Back in ^The Broken Stair^, go up the ramp right above you and take a right when you reach the top.",
                    minNote = "Exit east, then up the ramp",
                    points  = {
                        { 0.524, 0.937 },
                        { 0.546, 0.925 },
                        { 0.579, 0.896 },
                        { 0.585, 0.835 },
                        { 0.598, 0.743 },
                        { 0.579, 0.727 },
                        { 0.563, 0.724 },
                        { 0.556, 0.740 },
                        { 0.570, 0.758 },
                        { 0.585, 0.766 },
                        { 0.605, 0.759 },
                        { 0.623, 0.748 },
                        { 0.645, 0.720 },
                        { 0.645, 0.684 },
                        { 0.676, 0.678 },
                    },
                },
                {
                    when    = { mapID = 356 },
                    kind    = "path",
                    note    = "Continue working your way up the ramp and stairs.",
                    minNote = "Continue up the ramp/stairs",
                    points  = {
                        { 0.722, 0.650 },
                        { 0.717, 0.530 },
                        { 0.686, 0.400 },
                        { 0.626, 0.314 },
                        { 0.580, 0.288 },
                        { 0.563, 0.341 },
                        { 0.522, 0.361 },
                        { 0.423, 0.617 },
                        { 0.465, 0.644 },
                        { 0.522, 0.526 },
                        { 0.542, 0.540 },
                        { 0.498, 0.652 },
                        { 0.513, 0.666 },
                        { 0.547, 0.603 },
                    },
                },
                {
                    when    = { mapID = 357 },
                    kind    = "path",
                    note    = "Continue climbing.",
                    minNote = "Continue climbing",
                    points  = {
                        { 0.603, 0.461 },
                        { 0.473, 0.383 },
                        { 0.395, 0.459 },
                        { 0.334, 0.505 },
                        { 0.299, 0.595 },
                        { 0.460, 0.751 },
                        { 0.500, 0.648 },
                        { 0.537, 0.532 },
                    },
                },
                {
                    when    = { mapID = 358 },
                    kind    = "path",
                    note    = "When you reach the top of the stairs, continue following the path to reach ^The Curator^.",
                    minNote = "Path to The Curator",
                    points  = {
                        { 0.577, 0.150 },
                        { 0.528, 0.130 },
                        { 0.478, 0.126 },
                        { 0.408, 0.192 },
                        { 0.473, 0.332 },
                    },
                },
            },
        },

        -- 7. Terestian Illhoof
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Terestian Illhoof",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 358 },
                    kind    = "path",
                    note    = "After killing ^The Curator^, proceed past him and follow the ramps through the library.",
                    minNote = "Ramps through library",
                    points  = {
                        { 0.524, 0.427 },
                        { 0.481, 0.474 },
                        { 0.524, 0.573 },
                        { 0.479, 0.614 },
                        { 0.420, 0.587 },
                        { 0.379, 0.566 },
                        { 0.332, 0.579 },
                        { 0.318, 0.602 },
                        { 0.328, 0.632 },
                        { 0.355, 0.625 },
                        { 0.396, 0.637 },
                        { 0.419, 0.663 },
                        { 0.439, 0.715 },
                        { 0.447, 0.769 },
                        { 0.432, 0.830 },
                        { 0.413, 0.854 },
                        { 0.305, 0.648 },
                    },
                },
                {
                    when    = { mapID = 359 },
                    kind    = "path",
                    note    = "Click the ^Disconcerting Bookshelf^ to open a secret passage.",
                    minNote = "Click Bookshelf",
                    points  = {
                        { 0.316, 0.612 },
                        { 0.283, 0.549 },
                        { 0.283, 0.427 },
                        { 0.373, 0.322 },
                        { 0.383, 0.261 },
                    },
                },
                {
                    when        = { mapID = 359, subZone = "Guardian's Library" },
                    kind        = "poi",
                    mapLabel    = "Click Bookshelf",
                    mapLabelPos = "above",
                    points      = {
                        { 0.363, 0.210 },
                    },
                },
                {
                    when    = { mapID = 360 },
                    kind    = "path",
                    note    = "Behind the bookshelf, proceed down the ramp until you reach ^Terestian Illhoof^.",
                    minNote = "Down ramp to Illhoof",
                    points  = {
                        { 0.630, 0.282 },
                        { 0.433, 0.513 },
                        { 0.503, 0.656 },
                    },
                },
            },
        },

        -- 8. Shade of Aran
        {
            step      = 8,
            priority  = 8,
            bossIndex = 6,
            title     = "Shade of Aran",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 360 },
                    kind    = "path",
                    note    = "After defeating ^Terestian Illhoof^, backtrack up the ramp and back through the bookcase.",
                    minNote = "Backtrack through bookcase",
                    points  = {
                        { 0.491, 0.641 },
                        { 0.436, 0.513 },
                        { 0.676, 0.236 },
                    },
                },
                {
                    when    = { mapID = 359 },
                    kind    = "path",
                    note    = "Back in the library, continue up the ramps and open the ^Private Library Door^ to reach ^Shade of Aran^. Note: Killing this boss unlocks a teleport from the entrance NPC to this room, if you need to leave/logout and come back later.",
                    minNote = "Up ramps to Shade of Aran",
                    points  = {
                        { 0.410, 0.294 },
                        { 0.494, 0.462 },
                        { 0.567, 0.440 },
                        { 0.695, 0.293 },
                    },
                },
            },
        },

        -- 9. Netherspite
        {
            step      = 9,
            priority  = 9,
            bossIndex = 8,
            title     = "Netherspite",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 359 },
                    kind    = "path",
                    note    = "After defeating ^Shade of Aran^, exit the library and take a left up the ramp.",
                    minNote = "Exit library then left",
                    points  = {
                        { 0.690, 0.293 },
                        { 0.541, 0.468 },
                        { 0.614, 0.603 },
                    },
                },
                {
                    when    = { mapID = 361 },
                    kind    = "path",
                    note    = "Continue along the path until you reach a room with Ethereal enemies, and take the ramp up.",
                    minNote = "Up ramp after Ethereals",
                    points  = {
                        { 0.490, 0.562 },
                        { 0.549, 0.497 },
                        { 0.570, 0.533 },
                        { 0.514, 0.732 },
                        { 0.403, 0.864 },
                        { 0.291, 0.653 },
                        { 0.269, 0.647 },
                        { 0.251, 0.616 },
                    },
                },
                {
                    when    = { mapID = 362 },
                    kind    = "path",
                    note    = "At the top of the ramp, continue ahead until you reach ^Netherspite^.",
                    minNote = "Ahead to Netherspite",
                    points  = {
                        { 0.520, 0.741 },
                        { 0.479, 0.640 },
                        { 0.376, 0.453 },
                    },
                },
            },
        },

        -- 10. Chess Event
        {
            step      = 10,
            priority  = 10,
            bossIndex = 9,
            title     = "Chess Event",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 362 },
                    kind    = "path",
                    note    = "After killing ^Netherspite^, backtrack to the Ethereal room and take the ramp down this time. Open the ^Gamesman's Hall Door^ to reach the next area. There is a vendor NPC nearby if you need to clear bag space.",
                    minNote = "Backtrack and take ramp down",
                    points  = {
                        { 0.379, 0.452 },
                        { 0.479, 0.645 },
                        { 0.556, 0.824 },
                    },
                },
                {
                    when    = { mapID = 361 },
                    kind    = "path",
                    points  = {
                        { 0.275, 0.590 },
                        { 0.204, 0.445 },
                        { 0.296, 0.343 },
                        { 0.332, 0.282 },
                        { 0.389, 0.248 },
                        { 0.406, 0.174 },
                    },
                },
                {
                    when        = { mapID = 363 },
                    kind        = "poi",
                    faction     = "Alliance",
                    note        = "Talk to ^King Llane^ to begin the ^Chess Event^.",
                    minNote     = "Talk to King to begin",
                    mapLabel    = "Talk to King",
                    mapLabelPos = "above",
                    points      = {
                        { 0.419, 0.699 },
                    },
                },
                {
                    when        = { mapID = 363 },
                    kind        = "poi",
                    faction     = "Horde",
                    note        = "Talk to ^Warchief Blackhand^ to begin the ^Chess Event^.",
                    minNote     = "Talk to Warchief to begin",
                    mapLabel    = "Talk to King",
                    mapLabelPos = "above",
                    points      = {
                        { 0.321, 0.512 },
                    },
                },
            },
        },

        -- 11. Prince Malchezaar
        {
            step      = 11,
            priority  = 11,
            bossIndex = 10,
            title     = "Prince Malchezaar",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 363 },
                    kind    = "path",
                    note    = "After defeating the ^Chess Event^, leave the room up the stairs to the northeast, and follow the path to a spiral staircase.",
                    minNote = "East to spiral staircase",
                    points  = {
                        { 0.515, 0.431 },
                        { 0.555, 0.391 },
                        { 0.671, 0.435 },
                        { 0.770, 0.466 },
                        { 0.760, 0.560 },
                        { 0.788, 0.576 },
                        { 0.791, 0.604 },
                        { 0.805, 0.624 },
                        { 0.828, 0.626 },
                        { 0.841, 0.598 },
                        { 0.837, 0.571 },
                        { 0.823, 0.551 },
                    },
                },
                {
                    when    = { mapID = 364 },
                    kind    = "path",
                    note    = "Continue up the spiral stairwell.",
                    minNote = "Continue up the stairs",
                    points  = {
                        { 0.790, 0.752 },
                        { 0.804, 0.778 },
                        { 0.826, 0.781 },
                        { 0.846, 0.767 },
                        { 0.852, 0.725 },
                    },
                },
                {
                    when    = { mapID = 365 },
                    kind    = "path",
                    note    = "Continue up the spiral stairwell.",
                    minNote = "Continue up the stairs",
                    points  = {
                        { 0.707, 0.636 },
                        { 0.668, 0.613 },
                        { 0.623, 0.635 },
                        { 0.603, 0.705 },
                        { 0.620, 0.753 },
                    },
                },
                {
                    when    = { mapID = 366 },
                    kind    = "path",
                    note    = "Once you reach the top of the stairs, follow the path ahead to reach ^Prince Malchezaar^.",
                    minNote = "Ahead to Prince",
                    points  = {
                        { 0.473, 0.844 },
                        { 0.433, 0.820 },
                        { 0.432, 0.771 },
                        { 0.400, 0.753 },
                        { 0.397, 0.684 },
                        { 0.404, 0.649 },
                        { 0.449, 0.635 },
                        { 0.477, 0.606 },
                        { 0.508, 0.409 },
                    },
                },
            },
        },
    },
}
