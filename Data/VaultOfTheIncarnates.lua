-------------------------------------------------------------------------------
-- RetroRuns Data -- Vault of the Incarnates
-- Dragonflight, Patch 10.0  |  instanceID: 2522  |  journalInstanceID: 1200
-------------------------------------------------------------------------------
-- Vault of the Incarnates is the first Dragonflight raid (10.0). Two
-- structural notes worth understanding when reading this file:
--
-- 1. Boss order in routing[] is NOT the EJ order. The encounter journal
--    lists the bosses in geography-paired wing order, but the natural
--    solo-running path walks through them in a different sequence that
--    backtracks through Vault Approach (mapID 2122) multiple times.
--    `step`/`priority` follow the run order; `bossIndex` indexes into
--    bosses[] which stays EJ-ordered for transmog-lookup purposes.
--
-- 2. Routing segments often share a mapID within a single step. Vault
--    is the first raid where this happens; the renderer
--    (GetRelevantSegmentsForMap in Navigation.lua) handles it by
--    picking the earliest incomplete segment when player position
--    is unavailable (always the case inside raid instances per
--    Blizzard's C_Map.GetPlayerMapPosition restriction).
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2522] = {
    instanceID        = 2522,
    journalInstanceID = 1200,
    name              = "Vault of the Incarnates",
    expansion         = "Dragonflight",
    patch             = "10.0",

    maps = {
        -- Sub-zone names match the in-game world-map dropdown. mapID 2125
        -- is the parent raid map (same name as the raid itself) rather
        -- than a sub-zone -- it's used for Raszageth's encounter platform
        -- which sits above the sub-zone hierarchy. Distinct from the
        -- raid's instanceID 2522 (different namespaces, different APIs).
        [2119] = "The Primal Bulwark",
        [2120] = "The Elemental Conclave",
        [2121] = "Galewind Crag",
        [2122] = "The Vault Approach",
        [2123] = "Iceskitter Hollow",
        [2124] = "The Primal Convergence",
        [2125] = "Vault of the Incarnates",
        [2126] = "The Clutchwarren",
    },

    -- Dragonflight Season 1 tier set: "Lost Flights" (aka "Primalist") token
    -- family. Unlike Sepulcher-era tokens ("Mystic Leg Module" etc.) which
    -- encode their slot as a body-part word, Vault tokens encode the slot
    -- as a gem name: Jade=Legs, Amethyst=Chest, Garnet=Hands, Lapis=Shoulders,
    -- Topaz=Head.
    tierSets = {
        labels = {
            "Vault of the Incarnates",  -- setID=2601
        },
        tokenSources = {
            -- Sennarth (Legs)
            [196588] = 4,  -- Dreadful Jade Forgestone
            [196598] = 4,  -- Mystic Jade Forgestone
            [196603] = 4,  -- Venerated Jade Forgestone
            [196593] = 4,  -- Zenith Jade Forgestone
            -- Dathea (Hands)
            [196587] = 5,  -- Dreadful Garnet Forgestone
            [196597] = 5,  -- Mystic Garnet Forgestone
            [196602] = 5,  -- Venerated Garnet Forgestone
            [196592] = 5,  -- Zenith Garnet Forgestone
            -- Kurog (Chest)
            [196586] = 6,  -- Dreadful Amethyst Forgestone
            [196596] = 6,  -- Mystic Amethyst Forgestone
            [196601] = 6,  -- Venerated Amethyst Forgestone
            [196591] = 6,  -- Zenith Amethyst Forgestone
            -- Broodkeeper (Shoulders)
            [196589] = 7,  -- Dreadful Lapis Forgestone
            [196599] = 7,  -- Mystic Lapis Forgestone
            [196604] = 7,  -- Venerated Lapis Forgestone
            [196594] = 7,  -- Zenith Lapis Forgestone
            -- Raszageth (Head)
            [196590] = 8,  -- Dreadful Topaz Forgestone
            [196600] = 8,  -- Mystic Topaz Forgestone
            [196605] = 8,  -- Venerated Topaz Forgestone
            [196595] = 8,  -- Zenith Topaz Forgestone
        },
    },

    bosses = {
        {
            index              = 1,
            name               = "Eranog",
            journalEncounterID = 2480,
            achievements = {
                { id = 16335, name = "What Frozen Things Do", meta = true },
            },
            loot = {
                { id=195482, slot="Back",     name="Decorated Commander's Cindercloak", sources={ [17]=183391, [14]=181141, [15]=183392, [16]=183393 } },
                { id=195478, slot="Chest",    name="Valdrakken Protector's Turncoat",   sources={ [17]=181651, [14]=181137, [15]=181649, [16]=181650 } },
                { id=195476, slot="Head",     name="Eranog's Adorned Sallet",           sources={ [17]=181627, [14]=181135, [15]=181625, [16]=181626 } },
                { id=195479, slot="Legs",     name="Flametender's Legwraps",            sources={ [17]=181603, [14]=181138, [15]=181601, [16]=181602 } },
                { id=195475, slot="Off-hand", name="Flame Marshal's Bulwark",           sources={ [17]=183388, [14]=181134, [15]=183389, [16]=183390 } },
                { id=195490, slot="Ranged",   name="Searing Blazecaster",               sources={ [17]=183161, [14]=181149, [15]=183159, [16]=183160 } },
                { id=195477, slot="Shoulder", name="Scaldrons of Molten Might",         sources={ [17]=181582, [14]=181136, [15]=181580, [16]=181581 } },
            },
        },
        {
            index              = 2,
            name               = "Terros",
            journalEncounterID = 2500,
            -- Wing: Caverns of Infusion (with Sennarth, Kurog Grimtotem).
            -- Drops `Terros's Captive Core` (neck), one of two barter items
            -- for Iskaara Trader's Ottuk. Combine with Eye of the Vengeful
            -- Hurricane (Dathea) at Tattukiaka in Iskaara.
            achievements = {
                { id = 16365, name = "Little Friends", meta = true },
            },
            loot = {
                { id=195500, slot="Chest",    name="Compressed Cultist's Frock",        sources={ [17]=181621, [14]=181159, [15]=181619, [16]=181620 } },
                { id=195498, slot="Head",     name="Gaze of the Living Quarry",         sources={ [17]=181579, [14]=181157, [15]=181577, [16]=181578 } },
                { id=195499, slot="Shoulder", name="Faultline Mantle",                  sources={ [17]=181639, [14]=181158, [15]=181637, [16]=181638 } },
                { id=195504, slot="Two-Hand", name="Awakened Planar Pillar",            sources={ [17]=183402, [14]=181163, [15]=183400, [16]=183401 } },
                { id=195497, slot="Two-Hand", name="Quake-Detecting Seismostaff",       sources={ [17]=183399, [14]=181156, [15]=183397, [16]=183398 } },
                { id=195501, slot="Waist",    name="Fused Shale Waistband",             sources={ [17]=181660, [14]=181160, [15]=181658, [16]=181659 } },
                { id=195503, slot="Weapon",   name="Enduring Shard of Terros",          sources={ [17]=183265, [14]=181162, [15]=183263, [16]=183264 } },
            },
            specialLoot = {
                -- Iskaara Trader's Ottuk mount. Obtained by trading two
                -- neck pieces (Terros's Captive Core from Terros + Eye of
                -- the Vengeful Hurricane from Dathea) to Tattukiaka in
                -- Iskaara (Azure Span, ~14, 50). Both bosses surface the
                -- same mount entry with a "necks collected" progress group.
                {
                    id = 198871, kind = "mount", name = "Iskaara Trader's Ottuk",
                    barter = {
                        at = "Tattukiaka in Iskaara (Azure Span 14, 50)",
                        ingredients = {
                            { id = 195502, name = "Terros's Captive Core" },
                            { id = 195496, name = "Eye of the Vengeful Hurricane" },
                        },
                    },
                },
            },
        },
        {
            index              = 3,
            name               = "The Primal Council",
            journalEncounterID = 2486,
            -- Wing: The Primal Bulwark (with Dathea Ascended).
            achievements = {
                { id = 16364, name = "The Lunker Below", meta = true },
            },
            loot = {
                { id=195487, slot="Chest",            name="Embar's Ashen Hauberk",            sources={ [17]=181636, [14]=181146, [15]=181634, [16]=181635 } },
                { id=195485, slot="Head",             name="Councilor's Terrormask",           sources={ [17]=181606, [14]=181144, [15]=181604, [16]=181605 } },
                { id=195484, slot="Held In Off-hand", name="Icewrath's Channeling Conduit",    sources={ [17]=183396, [14]=181143, [15]=183394, [16]=183395 } },
                { id=195488, slot="Legs",             name="Opalfang's Earthbound Legguards",  sources={ [17]=181585, [14]=181147, [15]=181583, [16]=181584 } },
                { id=195486, slot="Shoulder",         name="Twisted Loam Spaulders",           sources={ [17]=181657, [14]=181145, [15]=181655, [16]=181656 } },
                { id=195518, slot="Two-Hand",         name="Imbued Qalashi Crusher",           sources={ [17]=183417, [14]=181177, [15]=183415, [16]=183416 } },
                { id=195489, slot="Weapon",           name="Maul of the Earthshaper",          sources={ [17]=183262, [14]=181148, [15]=183260, [16]=183261 } },
            },
        },
        {
            index              = 4,
            name               = "Sennarth, the Cold Breath",
            journalEncounterID = 2482,
            aliases            = { "Sennarth" },
            -- Wing: Caverns of Infusion (with Terros, Kurog Grimtotem).
            achievements = {
                { id = 16419, name = "I Was Saving That For Later", meta = true },
            },
            loot = {
                { id=195511, slot="Back",   name="Acid-Proof Webbing",         sources={ [17]=183408, [14]=181170, [15]=183406, [16]=183407 } },
                { id=195509, slot="Feet",   name="Ice-Climber's Cleats",       sources={ [17]=183040, [14]=181168, [15]=183041, [16]=183042 } },
                { id=195506, slot="Hands",  name="Diamond-Etched Gauntlets",   sources={ [17]=181591, [14]=181165, [15]=181589, [16]=181590 } },
                { id=195507, slot="Waist",  name="Unnatural Dripstone Cinch",  sources={ [17]=181642, [14]=181166, [15]=181640, [16]=181641 } },
                { id=195505, slot="Weapon", name="Caustic Coldsteel Slicer",   sources={ [17]=183405, [14]=181164, [15]=183403, [16]=183404 } },
                { id=195510, slot="Weapon", name="Frostbreath Thumper",        sources={ [17]=183256, [14]=181169, [15]=183254, [16]=183255 } },
                { id=195508, slot="Wrist",  name="Chilled Silken Restraints",  sources={ [17]=181615, [14]=181167, [15]=181613, [16]=181614 } },
                -- Tier Legs (13 classes, from Jade Forgestone tokens)
                { id=200427, slot="Legs", name="Poleyns of the Walking Mountain",   sources={ [17]=182898, [14]=182895, [15]=182897, [16]=182896 }, classes={ 1 } },
                { id=200418, slot="Legs", name="Virtuous Silver Cuisses",           sources={ [17]=182862, [14]=182859, [15]=182861, [16]=182860 }, classes={ 2 } },
                { id=200391, slot="Legs", name="Stormwing Harrier's Greaves",       sources={ [17]=182754, [14]=182751, [15]=182753, [16]=182752 }, classes={ 3 } },
                { id=200373, slot="Legs", name="Vault Delver's Pantaloons",         sources={ [17]=182682, [14]=182679, [15]=182681, [16]=182680 }, classes={ 4 } },
                { id=200328, slot="Legs", name="Draconic Hierophant's Britches",    sources={ [17]=182502, [14]=182499, [15]=182501, [16]=182500 }, classes={ 5 } },
                { id=200409, slot="Legs", name="Greaves of the Haunted Frostbrood", sources={ [17]=182826, [14]=182823, [15]=182825, [16]=182824 }, classes={ 6 } },
                { id=200400, slot="Legs", name="Leggings of Infused Earth",         sources={ [17]=182790, [14]=182787, [15]=182789, [16]=182788 }, classes={ 7 } },
                { id=200319, slot="Legs", name="Crystal Scholar's Britches",        sources={ [17]=182466, [14]=182463, [15]=182465, [16]=182464 }, classes={ 8 } },
                { id=200337, slot="Legs", name="Scalesworn Cultist's Culottes",     sources={ [17]=182538, [14]=182535, [15]=182537, [16]=182536 }, classes={ 9 } },
                { id=200364, slot="Legs", name="Legguards of the Waking Fist",      sources={ [17]=182646, [14]=182643, [15]=182645, [16]=182644 }, classes={ 10 } },
                { id=200355, slot="Legs", name="Lost Landcaller's Leggings",        sources={ [17]=182610, [14]=182607, [15]=182609, [16]=182608 }, classes={ 11 } },
                { id=200346, slot="Legs", name="Skybound Avenger's Legguards",      sources={ [17]=182574, [14]=182571, [15]=182573, [16]=182572 }, classes={ 12 } },
                { id=200382, slot="Legs", name="Legguards of the Awakened",         sources={ [17]=182718, [14]=182715, [15]=182717, [16]=182716 }, classes={ 13 } },
            },
        },
        {
            index              = 5,
            name               = "Dathea, Ascended",
            journalEncounterID = 2502,
            aliases            = { "Dathea" },
            -- Wing: The Primal Bulwark (with Primal Council).
            -- Drops `Eye of the Vengeful Hurricane` (neck), one of two
            -- barter items for Iskaara Trader's Ottuk. Combine with
            -- Terros's Captive Core (Terros) at Tattukiaka in Iskaara.
            achievements = {
                { id = 16458, name = "Nothing But Air", meta = true },
            },
            loot = {
                { id=195494, slot="Chest",    name="Dathea's Cyclonic Cage",        sources={ [17]=181588, [14]=181153, [15]=181586, [16]=181587 } },
                { id=195495, slot="Feet",     name="Daring Chasm-Leapers",          sources={ [17]=181630, [14]=181154, [15]=181628, [16]=181629 } },
                { id=195492, slot="Head",     name="Windborne Hatsuburi",           sources={ [17]=183230, [14]=181151, [15]=183229, [16]=183231 } },
                { id=195493, slot="Shoulder", name="Ascended Squallspires",         sources={ [17]=181612, [14]=181152, [15]=181610, [16]=181611 } },
                { id=195491, slot="Weapon",   name="Infused Stormglaives",          sources={ [17]=183158, [14]=181150, [15]=183156, [16]=183157 } },
                { id=195481, slot="Weapon",   name="Scepter of Drastic Measures",   sources={ [17]=183259, [14]=181140, [15]=183257, [16]=183258 } },
                -- Tier Hands (13 classes, from Garnet Forgestone tokens)
                { id=200425, slot="Hands", name="Gauntlets of the Walking Mountain",  sources={ [17]=182890, [14]=182887, [15]=182889, [16]=182888 }, classes={ 1 } },
                { id=200416, slot="Hands", name="Virtuous Silver Gauntlets",          sources={ [17]=182854, [14]=182851, [15]=182853, [16]=182852 }, classes={ 2 } },
                { id=200389, slot="Hands", name="Stormwing Harrier's Handguards",     sources={ [17]=182746, [14]=182743, [15]=182745, [16]=182744 }, classes={ 3 } },
                { id=200371, slot="Hands", name="Vault Delver's Lockbreakers",        sources={ [17]=182674, [14]=182671, [15]=182673, [16]=182672 }, classes={ 4 } },
                { id=200326, slot="Hands", name="Draconic Hierophant's Grips",        sources={ [17]=182494, [14]=182491, [15]=182493, [16]=182492 }, classes={ 5 } },
                { id=200407, slot="Hands", name="Grasps of the Haunted Frostbrood",   sources={ [17]=182818, [14]=182815, [15]=182817, [16]=182816 }, classes={ 6 } },
                { id=200398, slot="Hands", name="Gauntlets of Infused Earth",         sources={ [17]=182782, [14]=182779, [15]=182781, [16]=182780 }, classes={ 7 } },
                { id=200317, slot="Hands", name="Crystal Scholar's Pageturners",      sources={ [17]=182458, [14]=182455, [15]=182457, [16]=182456 }, classes={ 8 } },
                { id=200335, slot="Hands", name="Scalesworn Cultist's Gloves",        sources={ [17]=182530, [14]=182527, [15]=182529, [16]=182528 }, classes={ 9 } },
                { id=200362, slot="Hands", name="Palms of the Waking Fist",           sources={ [17]=182638, [14]=182635, [15]=182637, [16]=182636 }, classes={ 10 } },
                { id=200353, slot="Hands", name="Lost Landcaller's Claws",            sources={ [17]=182602, [14]=182599, [15]=182601, [16]=182600 }, classes={ 11 } },
                { id=200344, slot="Hands", name="Skybound Avenger's Grips",           sources={ [17]=182566, [14]=182563, [15]=182565, [16]=182564 }, classes={ 12 } },
                { id=200380, slot="Hands", name="Gauntlets of the Awakened",          sources={ [17]=182710, [14]=182707, [15]=182709, [16]=182708 }, classes={ 13 } },
            },
            specialLoot = {
                -- Iskaara Trader's Ottuk mount. See Terros for full
                -- description; surfaced on both bosses since either's
                -- neck token contributes to the barter.
                {
                    id = 198871, kind = "mount", name = "Iskaara Trader's Ottuk",
                    barter = {
                        at = "Tattukiaka in Iskaara (Azure Span 14, 50)",
                        ingredients = {
                            { id = 195502, name = "Terros's Captive Core" },
                            { id = 195496, name = "Eye of the Vengeful Hurricane" },
                        },
                    },
                },
            },
        },
        {
            index              = 6,
            name               = "Kurog Grimtotem",
            journalEncounterID = 2491,
            aliases            = { "Kurog" },
            -- Wing: Caverns of Infusion (with Terros, Sennarth).
            achievements = {
                { id = 16450, name = "The Power is MINE!", meta = true },
            },
            loot = {
                { id=195517, slot="Feet",             name="Kurog's Thunderhooves",             sources={ [17]=181594, [14]=181176, [15]=181592, [16]=181593 } },
                { id=195514, slot="Hands",            name="Treacherous Totem Wraps",           sources={ [17]=181663, [14]=181173, [15]=181661, [16]=181662 } },
                { id=195513, slot="Held In Off-hand", name="Scripture of Primal Devotion",      sources={ [17]=183414, [14]=181172, [15]=183412, [16]=183413 } },
                { id=195483, slot="Two-Hand",         name="Awak'mani, Grimtotem's Legacy",     sources={ [17]=183253, [14]=181142, [15]=183251, [16]=183252 } },
                { id=195515, slot="Waist",            name="Magatha's Spiritual Sash",          sources={ [17]=181624, [14]=181174, [15]=181622, [16]=181623 } },
                { id=195512, slot="Weapon",           name="Fist of the Grand Summoner",        sources={ [17]=183411, [14]=181171, [15]=183409, [16]=183410 } },
                { id=195516, slot="Wrist",            name="Surging-Song Conductors",           sources={ [17]=181633, [14]=181175, [15]=181631, [16]=181632 } },
                -- Tier Chest (13 classes, from Amethyst Forgestone tokens)
                { id=200423, slot="Chest", name="Husk of the Walking Mountain",           sources={ [17]=182882, [14]=182879, [15]=182881, [16]=182880 }, classes={ 1 } },
                { id=200414, slot="Chest", name="Virtuous Silver Breastplate",            sources={ [17]=182846, [14]=182843, [15]=182845, [16]=182844 }, classes={ 2 } },
                { id=200387, slot="Chest", name="Stormwing Harrier's Cuirass",            sources={ [17]=182738, [14]=182735, [15]=182737, [16]=182736 }, classes={ 3 } },
                { id=200369, slot="Chest", name="Vault Delver's Brigandine",              sources={ [17]=182666, [14]=182663, [15]=182665, [16]=182664 }, classes={ 4 } },
                { id=200324, slot="Chest", name="Draconic Hierophant's Vestment",         sources={ [17]=182486, [14]=182483, [15]=182485, [16]=182484 }, classes={ 5 } },
                { id=200405, slot="Chest", name="Breastplate of the Haunted Frostbrood",  sources={ [17]=182810, [14]=182807, [15]=182809, [16]=182808 }, classes={ 6 } },
                { id=200396, slot="Chest", name="Robe of Infused Earth",                  sources={ [17]=182774, [14]=182771, [15]=182773, [16]=182772 }, classes={ 7 } },
                { id=200315, slot="Chest", name="Crystal Scholar's Tunic",                sources={ [17]=182450, [14]=182447, [15]=182449, [16]=182448 }, classes={ 8 } },
                { id=200333, slot="Chest", name="Scalesworn Cultist's Frock",             sources={ [17]=182522, [14]=182519, [15]=182521, [16]=182520 }, classes={ 9 } },
                { id=200360, slot="Chest", name="Chestwrap of the Waking Fist",           sources={ [17]=182630, [14]=182627, [15]=182629, [16]=182628 }, classes={ 10 } },
                { id=200351, slot="Chest", name="Lost Landcaller's Robes",                sources={ [17]=182594, [14]=182591, [15]=182593, [16]=182592 }, classes={ 11 } },
                { id=200342, slot="Chest", name="Skybound Avenger's Harness",             sources={ [17]=182558, [14]=182555, [15]=182557, [16]=182556 }, classes={ 12 } },
                { id=200378, slot="Chest", name="Hauberk of the Awakened",                sources={ [17]=182702, [14]=182699, [15]=182701, [16]=182700 }, classes={ 13 } },
            },
        },
        {
            index              = 7,
            name               = "Broodkeeper Diurna",
            journalEncounterID = 2493,
            aliases            = { "Broodkeeper", "Diurna" },
            -- Drops [Shard of the Greatstaff] x3 for the "Break a Few Eggs"
            -- skip quest (unlocks Raszageth direct-access teleport for
            -- future runs).
            achievements = {
                { id = 16442, name = "Incubation Extermination", meta = true },
            },
            loot = {
                { id=195523, slot="Hands",    name="Eggtender's Safety Mitts",         sources={ [17]=181609, [14]=181182, [15]=181607, [16]=181608 } },
                { id=195522, slot="Legs",     name="Tassets of the Tarasek Legion",    sources={ [17]=181645, [14]=181181, [15]=181643, [16]=181644 } },
                { id=195520, slot="Off-hand", name="Broodsworn Legionnaire's Pavise",  sources={ [17]=183420, [14]=181179, [15]=183418, [16]=183419 } },
                -- Kharnalex, The First Light is Evoker-only. Like other
                -- class-locked legendaries it shares a single appearance
                -- across all four difficulties; the row renders for all
                -- classes with an "(Evoker only)" suffix so the
                -- appearance is visible to non-Evoker collectors.
                { id=195519, slot="Two-Hand", name="Kharnalex, The First Light",       sources={ [17]=181178, [14]=181178, [15]=181178, [16]=181178 }, restrictedToClass=13 },
                { id=195524, slot="Waist",    name="Matriarch's Opulent Girdle",       sources={ [17]=181597, [14]=181183, [15]=181595, [16]=181596 } },
                { id=195521, slot="Weapon",   name="Ornamental Drakonid Claw",         sources={ [17]=183423, [14]=181180, [15]=183421, [16]=183422 } },
                { id=195525, slot="Wrist",    name="Loyal Flametender's Bracers",      sources={ [17]=181654, [14]=181184, [15]=181652, [16]=181653 } },
                -- Tier Shoulder (13 classes, from Lapis Forgestone tokens)
                { id=200428, slot="Shoulder", name="Peaks of the Walking Mountain",        sources={ [17]=182902, [14]=182899, [15]=182901, [16]=182900 }, classes={ 1 } },
                { id=200419, slot="Shoulder", name="Virtuous Silver Pauldrons",            sources={ [17]=182866, [14]=182863, [15]=182865, [16]=182864 }, classes={ 2 } },
                { id=200392, slot="Shoulder", name="Stormwing Harrier's Pinions",          sources={ [17]=182758, [14]=182755, [15]=182757, [16]=182756 }, classes={ 3 } },
                { id=200374, slot="Shoulder", name="Vault Delver's Epaulets",              sources={ [17]=182686, [14]=182683, [15]=182685, [16]=182684 }, classes={ 4 } },
                { id=200329, slot="Shoulder", name="Draconic Hierophant's Wisdom",         sources={ [17]=182506, [14]=182503, [15]=182505, [16]=182504 }, classes={ 5 } },
                { id=200410, slot="Shoulder", name="Jaws of the Haunted Frostbrood",       sources={ [17]=182830, [14]=182827, [15]=182829, [16]=182828 }, classes={ 6 } },
                { id=200401, slot="Shoulder", name="Calderas of Infused Earth",            sources={ [17]=182794, [14]=182791, [15]=182793, [16]=182792 }, classes={ 7 } },
                { id=200320, slot="Shoulder", name="Crystal Scholar's Beacons",            sources={ [17]=182470, [14]=182467, [15]=182469, [16]=182468 }, classes={ 8 } },
                { id=200338, slot="Shoulder", name="Scalesworn Cultist's Effigy",          sources={ [17]=182542, [14]=182539, [15]=182541, [16]=182540 }, classes={ 9 } },
                { id=200365, slot="Shoulder", name="Mantle of the Waking Fist",            sources={ [17]=182650, [14]=182647, [15]=182649, [16]=182648 }, classes={ 10 } },
                { id=200356, slot="Shoulder", name="Lost Landcaller's Mantle",             sources={ [17]=182614, [14]=182611, [15]=182613, [16]=182612 }, classes={ 11 } },
                { id=200347, slot="Shoulder", name="Skybound Avenger's Ailerons",          sources={ [17]=182578, [14]=182575, [15]=182577, [16]=182576 }, classes={ 12 } },
                { id=200383, slot="Shoulder", name="Talons of the Awakened",               sources={ [17]=182722, [14]=182719, [15]=182721, [16]=182720 }, classes={ 13 } },
            },
        },
        {
            index              = 8,
            name               = "Raszageth the Storm-Eater",
            journalEncounterID = 2499,
            aliases            = { "Raszageth", "Storm-Eater" },
            achievements = {
                { id = 16451, name = "The Ol Raszle Daszle", meta = true },
            },
            specialLoot = {
                -- Renewed Proto-Drake: Embodiment of the Storm-Eater
                -- (Drakewatcher Manuscript). Item is consumed on use; the
                -- "use" spell (394780 "Deciphering") completes hidden quest
                -- 72367 as its only effect. Tracking the unlock therefore
                -- comes down to IsQuestFlaggedCompleted(72367), which
                -- persists per-character even after the item is gone.
                -- Drops on all difficulties (LFR through Mythic).
                {
                    id      = 201790,
                    kind    = "manuscript",
                    name    = "Renewed Proto-Drake: Embodiment of the Storm-Eater",
                    questID = 72367,
                },
            },
            loot = {
                { id=195532, slot="Feet",     name="Sandals of the Wild Sovereign",   sources={ [17]=181618, [14]=181191, [15]=181616, [16]=181617 } },
                { id=195531, slot="Hands",    name="Calamitous Shockguards",          sources={ [17]=181648, [14]=181190, [15]=181646, [16]=181647 } },
                { id=195530, slot="Legs",     name="Loathsome Thunderhosen",          sources={ [17]=181666, [14]=181189, [15]=181664, [16]=181665 } },
                { id=195527, slot="Ranged",   name="Neltharax, Enemy of the Sky",     sources={ [17]=183426, [14]=181186, [15]=183424, [16]=183425 } },
                { id=195528, slot="Two-Hand", name="Incarnate Sky-Splitter",          sources={ [17]=183429, [14]=181187, [15]=183427, [16]=183428 } },
                { id=195529, slot="Weapon",   name="Stormlash's Last Resort",         sources={ [17]=183432, [14]=181188, [15]=183430, [16]=183431 } },
                { id=195533, slot="Wrist",    name="Shackles of Titanic Failure",     sources={ [17]=181600, [14]=181192, [15]=181598, [16]=181599 } },
                -- Tier Head (13 classes, from Topaz Forgestone tokens)
                { id=200426, slot="Head", name="Casque of the Walking Mountain",   sources={ [17]=182894, [14]=182891, [15]=182893, [16]=182892 }, classes={ 1 } },
                { id=200417, slot="Head", name="Virtuous Silver Heaume",           sources={ [17]=182858, [14]=182855, [15]=182857, [16]=182856 }, classes={ 2 } },
                { id=200390, slot="Head", name="Stormwing Harrier's Skullmask",    sources={ [17]=182750, [14]=182747, [15]=182749, [16]=182748 }, classes={ 3 } },
                { id=200372, slot="Head", name="Vault Delver's Vizard",            sources={ [17]=182678, [14]=182675, [15]=182677, [16]=182676 }, classes={ 4 } },
                { id=200327, slot="Head", name="Draconic Hierophant's Archcowl",   sources={ [17]=182498, [14]=182495, [15]=182497, [16]=182496 }, classes={ 5 } },
                { id=200408, slot="Head", name="Maw of the Haunted Frostbrood",    sources={ [17]=182822, [14]=182819, [15]=182821, [16]=182820 }, classes={ 6 } },
                { id=200399, slot="Head", name="Faceguard of Infused Earth",       sources={ [17]=182786, [14]=182783, [15]=182785, [16]=182784 }, classes={ 7 } },
                { id=200318, slot="Head", name="Crystal Scholar's Cowl",           sources={ [17]=182462, [14]=182459, [15]=182461, [16]=182460 }, classes={ 8 } },
                { id=200336, slot="Head", name="Scalesworn Cultist's Scorn",       sources={ [17]=182534, [14]=182531, [15]=182533, [16]=182532 }, classes={ 9 } },
                { id=200363, slot="Head", name="Gaze of the Waking Fist",          sources={ [17]=182642, [14]=182639, [15]=182641, [16]=182640 }, classes={ 10 } },
                { id=200354, slot="Head", name="Lost Landcaller's Antlers",        sources={ [17]=182606, [14]=182603, [15]=182605, [16]=182604 }, classes={ 11 } },
                { id=200345, slot="Head", name="Skybound Avenger's Visor",         sources={ [17]=182570, [14]=182567, [15]=182569, [16]=182568 }, classes={ 12 } },
                { id=200381, slot="Head", name="Crown of the Awakened",            sources={ [17]=182714, [14]=182711, [15]=182713, [16]=182712 }, classes={ 13 } },
            },
        },
    },

    -- Solo-run order. step/priority follow this order; bossIndex points
    -- into bosses[] which stays EJ-ordered.
    --   step 1 - Eranog               (bossIndex 1)
    --   step 2 - Terros               (bossIndex 2)
    --   step 3 - Sennarth             (bossIndex 4)
    --   step 4 - Kurog Grimtotem      (bossIndex 6)
    --   step 5 - The Primal Council   (bossIndex 3)
    --   step 6 - Dathea, Ascended     (bossIndex 5)
    --   step 7 - Broodkeeper Diurna   (bossIndex 7)
    --   step 8 - Raszageth            (bossIndex 8)

    routing = {

        -- 1. Eranog
        -- Three segments on mapID 2119. The route runs from the
        -- post-flyover platform (The Outer Seal sub-zone) into the
        -- Primal Bulwark, past the mini-boss Volcanius, and on to
        -- Eranog's pull spot. Volcanius is a routing-segment gate,
        -- not a boss (no entry in bosses[]) and not a registered
        -- ENCOUNTER_START encounter. With no clean signal to detect
        -- Volcanius's death or the wall opening, this step uses
        -- renderAllSegments=true: all three segments render
        -- simultaneously with numbered waypoints, and the player
        -- self-paces through them. The consolidated travel note on
        -- seg 1 walks through the (1)/(2)/(3) sequence verbally to
        -- match the on-map numbers.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Eranog",
            requires  = {},
            -- Eranog's segments include the path past Volcanius, a
            -- mini-boss the player walks past and kills mid-route. There's
            -- no kill-detection signal between him and Eranog, so all
            -- waypoints render at once and the player self-paces.
            renderAllSegments = true,
            segments  = {
                {
                    mapID  = 2119,
                    kind   = "path",
                    note   = "|cffF259C7(1)|r Upon zoning in, talk to all 5 dragons. Then talk to Khadgar to begin the assault. Choose any dragon; doesn't matter. |cffF259C7(2)|r After landing, follow the path to kill the mini-boss Volcanius. |cffF259C7(3)|r Next, follow the newly-opened path to Eranog and kill him.",
                    points = {
                        { 0.629, 0.920 },
                        { 0.615, 0.856 },
                    },
                },
                {
                    mapID  = 2119,
                    kind   = "path",
                    points = {
                        { 0.566, 0.530 },
                        { 0.511, 0.472 },
                        { 0.535, 0.411 },
                        { 0.561, 0.378 },
                    },
                },
                {
                    mapID  = 2119,
                    kind   = "path",
                    points = {
                        { 0.561, 0.377 },
                        { 0.512, 0.425 },
                        { 0.488, 0.339 },
                        { 0.548, 0.222 },
                    },
                    navPoint = { 0.549, 0.27 },
                },
            },
        },

        -- 2. Terros
        -- Four segments across three mapIDs. The player crosses Vault
        -- Approach to reach Primal Convergence, kills Terros there,
        -- then backtracks through Vault Approach (entering via the
        -- Quarry of Infusion sub-zone) on the way to other bosses.
        -- Segment 4's path traverses both Vault Approach and Quarry
        -- of Infusion as a single contiguous walk, with no mid-route
        -- redraw at the sub-zone boundary.
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Terros",
            requires  = { 1 },
            segments  = {
                {
                    mapID  = 2119,
                    kind   = "path",
                    note   = "After killing Eranog, there are 3 paths available. Take the path on the right labeled The Vault Approach.",
                    points = {
                        { 0.569, 0.172 },
                        { 0.598, 0.152 },
                    },
                },
                {
                    mapID  = 2122,
                    kind   = "path",
                    note   = "Follow the path to The Primal Convergence.",
                    points = {
                        { 0.836, 0.871 },
                        { 0.835, 0.783 },
                        { 0.717, 0.562 },
                    },
                },
                {
                    mapID  = 2124,
                    kind   = "path",
                    note   = "When you arrive in The Primal Convergence, take the first path on the left labeled Quarry of Infusion.",
                    points = {
                        { 0.638, 0.822 },
                        { 0.512, 0.861 },
                        { 0.396, 0.821 },
                    },
                },
                {
                    mapID  = 2122,
                    kind   = "path",
                    note   = "Follow the path to Terros.",
                    points = {
                        { 0.554, 0.571 },
                        { 0.534, 0.623 },
                        { 0.519, 0.662 },
                        { 0.461, 0.762 },
                        { 0.243, 0.759 },
                    },
                },
            },
        },

        -- 3. Sennarth, the Cold Breath
        -- Four segments. Route backtracks through Primal Convergence
        -- to reach a different region of Vault Approach via the
        -- Iceskitter Hollow doorway, where the encounter starts.
        -- Segment 4 fires DURING the fight: Sennarth ascends from
        -- 2122 into the actual Iceskitter Hollow sub-zone (2123)
        -- and the player follows.
        {
            step      = 3,
            priority  = 3,
            bossIndex = 4,
            title     = "Sennarth, the Cold Breath",
            requires  = { 1, 2 },
            segments  = {
                {
                    mapID  = 2122,
                    kind   = "path",
                    note   = "After killing Terros, go back the way you came and arrive back in The Primal Convergence.",
                    points = {
                        { 0.250, 0.763 },
                        { 0.474, 0.753 },
                        { 0.533, 0.625 },
                        { 0.557, 0.557 },
                    },
                },
                {
                    mapID  = 2124,
                    kind   = "path",
                    note   = "From The Primal Convergence, follow the path to the entrance labeled Iceskitter Hollow.",
                    points = {
                        { 0.376, 0.836 },
                        { 0.392, 0.806 },
                        { 0.276, 0.511 },
                        { 0.259, 0.511 },
                    },
                },
                {
                    mapID  = 2122,
                    kind   = "path",
                    note   = "Follow the path to Sennarth, the Cold Breath",
                    points = {
                        { 0.486, 0.358 },
                        { 0.334, 0.353 },
                    },
                },
                {
                    mapID  = 2123,
                    kind   = "path",
                    note   = "Finish him!",
                    points = {
                        { 0.572, 0.237 },
                        { 0.663, 0.526 },
                        { 0.605, 0.755 },
                        { 0.373, 0.725 },
                        { 0.338, 0.418 },
                    },
                },
            },
            soloTip = "Avoid Sticky Webbing on the ground. The boss will attempt to pull you off the edge with Gossamer Burst. Easiest way to avoid this is to step on a Sticky Webbing before he finishes the cast. When he ascends, follow him up and finish the kill.",
        },

        -- 4. Kurog Grimtotem
        -- Three segments. After Sennarth dies on the Iceskitter Hollow
        -- upper platform, the player rides Gust of Wind down to the
        -- bottom of the room, then walks back out to Primal Convergence
        -- and follows the newly-opened east path to Kurog.
        {
            step      = 4,
            priority  = 4,
            bossIndex = 6,
            title     = "Kurog Grimtotem",
            requires  = { 1, 2, 4 },
            segments  = {
                {
                    mapID  = 2123,
                    kind   = "path",
                    note   = "After killing Sennarth, click the Gust of Wind behind him to return to the bottom of the room. If you killed him on the ground floor, proceed up the ramp to find his corpse and collect his loot!",
                    points = {
                        { 0.331, 0.460 },
                        { 0.368, 0.405 },
                    },
                },
                {
                    mapID  = 2122,
                    kind   = "path",
                    note   = "After landing from Gust of Wind, follow the path back out to The Primal Convergence.",
                    points = {
                        { 0.350, 0.348 },
                        { 0.489, 0.357 },
                    },
                },
                {
                    mapID  = 2124,
                    kind   = "path",
                    note   = "Back in The Primal Convergence, follow the newly-opened path to Kurog Grimtotem.",
                    points = {
                        { 0.260, 0.505 },
                        { 0.306, 0.335 },
                        { 0.400, 0.220 },
                        { 0.498, 0.471 },
                    },
                },
            },
        },

        -- 5. The Primal Council
        -- Four segments backtracking through earlier sub-zones to
        -- reach the previously-unvisited Elemental Conclave. Vault
        -- Approach is traversed for the third time on this route.
        -- Segment 4 walks past Braekkas, a named mini-boss in the
        -- direct path -- the player walks through him naturally on
        -- the way to the Council pull spot.
        {
            step      = 5,
            priority  = 5,
            bossIndex = 3,
            title     = "The Primal Council",
            requires  = { 1, 2, 4, 6 },
            segments  = {
                {
                    mapID  = 2124,
                    kind   = "path",
                    note   = "After killing Kurog Grimtotem, follow the path back to The Vault Approach.",
                    points = {
                        { 0.527, 0.546 },
                        { 0.634, 0.825 },
                    },
                },
                {
                    mapID  = 2122,
                    kind   = "path",
                    note   = "Continue following the path to arrive back at the The Primal Bulwark.",
                    points = {
                        { 0.714, 0.559 },
                        { 0.837, 0.799 },
                        { 0.832, 0.871 },
                    },
                },
                {
                    mapID  = 2119,
                    kind   = "path",
                    note   = "This time, take the far-left exit to reach The Elemental Conclave.",
                    points = {
                        { 0.600, 0.153 },
                        { 0.543, 0.154 },
                    },
                },
                {
                    mapID  = 2120,
                    kind   = "path",
                    note   = "Follow the path and kill Braekkas to open the wall. Continue on to find The Primal Council.",
                    points = {
                        { 0.849, 0.299 },
                        { 0.808, 0.226 },
                        { 0.671, 0.257 },
                        { 0.559, 0.427 },
                        { 0.494, 0.492 },
                        { 0.496, 0.635 },
                        { 0.466, 0.673 },
                    },
                },
            },
        },

        -- 6. Dathea, Ascended
        -- Two segments crossing two new sub-zones. Walk Elemental
        -- Conclave past Thondrozus (mini-boss, walked through) to the
        -- Upward Draft updraft. Clicking the updraft teleports the
        -- player to Galewind Crag; walk across to the Downward Draft,
        -- which carries the player to the Dathea encounter platform.
        {
            step      = 6,
            priority  = 6,
            bossIndex = 5,
            title     = "Dathea, Ascended",
            requires  = { 1, 2, 3, 4, 6 },
            segments  = {
                {
                    mapID  = 2120,
                    kind   = "path",
                    note   = "After killing The Primal Council, follow the path towards the exit labeled Galewind Crag. Kill Thondrozus, and click on Upward Draft to be carried up to Galewind Crag. Approach the Downward Draft.",
                    points = {
                        { 0.462, 0.676 },
                        { 0.550, 0.646 },
                        { 0.582, 0.717 },
                        { 0.635, 0.718 },
                        { 0.714, 0.530 },
                        { 0.761, 0.532 },
                    },
                },
                {
                    mapID  = 2121,
                    kind   = "path",
                    note   = "Click the Downward Draft to be flown to the platform and engage Dathea, Ascended.",
                    points = {
                        { 0.316, 0.507 },
                        { 0.450, 0.541 },
                        { 0.535, 0.527 },
                    },
                },
            },
            soloTip = "For the knockback, position yourself between the boss and a tornado.",
        },

        -- 7. Broodkeeper Diurna
        -- Four segments backtracking from Galewind Crag through the
        -- Primal Bulwark, then through a third distinct region of
        -- Vault Approach (the southern stairs), and finally into The
        -- Clutchwarren. Segment 2's note references the in-game sign
        -- labeled "The Clutchwarren" even though the path actually
        -- transits Vault Approach before arriving there.
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "Broodkeeper Diurna",
            requires  = { 1, 2, 3, 4, 5, 6 },
            segments  = {
                {
                    mapID  = 2121,
                    kind   = "path",
                    note   = "After killing Dathea, Ascended, take one of the nearby Downward Draft to return below to The Primal Bulwark.",
                    points = {
                        { 0.565, 0.476 },
                        { 0.590, 0.303 },
                    },
                },
                {
                    mapID  = 2119,
                    kind   = "path",
                    note   = "Once you land, take the middle (and final) path labeled The Clutchwarren.",
                    points = {
                        { 0.601, 0.161 },
                        { 0.572, 0.139 },
                    },
                },
                {
                    mapID  = 2122,
                    kind   = "path",
                    note   = "Work your way upstairs through The Vault Approach and you will enter The Clutchwarren.",
                    points = {
                        { 0.741, 0.931 },
                        { 0.743, 0.490 },
                    },
                },
                {
                    mapID  = 2126,
                    kind   = "path",
                    note   = "Follow the path up to Broodkeeper Diurna.",
                    points = {
                        { 0.734, 0.894 },
                        { 0.739, 0.835 },
                        { 0.534, 0.556 },
                    },
                },
            },
            soloTip = "Stand on boss and cleave everything down",
        },

        -- 8. Raszageth
        -- Two segments. After Diurna dies, the player clicks a nearby
        -- dragon (a scripted flight, not an instant teleport) which
        -- carries them up to the Raszageth platform.
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Raszageth",
            requires  = { 1, 2, 3, 4, 5, 6, 7 },
            segments  = {
                {
                    mapID  = 2126,
                    kind   = "path",
                    note   = "After killing Broodkeeper Diurna, click any nearby dragon to fly to the Vault of the Incarnates.",
                    points = {
                        { 0.487, 0.516 },
                        { 0.380, 0.469 },
                    },
                },
                {
                    mapID  = 2125,
                    kind   = "path",
                    note   = "After a brief dialog, kill Raszageth the Storm-Eater!",
                    points = {
                        { 0.620, 0.674 },
                        { 0.581, 0.635 },
                    },
                },
            },
            soloTip = "The only mechanic that matters anymore is his knockback. Position yourself so it launches you to the left or right platform. Kill adds on both platforms and return to middle. For next knockback, let it knock you to the upper middle platform. Finish the boss there!",
        },
    },
}
