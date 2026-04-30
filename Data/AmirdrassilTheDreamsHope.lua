-------------------------------------------------------------------------------
-- RetroRuns Data -- Amirdrassil, the Dream's Hope
-- Dragonflight, Patch 10.2  |  instanceID: 2549  |  journalInstanceID: 1207
-------------------------------------------------------------------------------
-- Amirdrassil is the third Dragonflight raid (10.2, Guardians of the Dream).
-- 9 bosses set in the regrowing World Tree on the Emerald Dream's slopes.
-- Two structural notes worth understanding when reading this file:
--
-- (1) The lockout has a branching shape, similar to Aberrus. After Igira,
--     two pairs unlock in parallel: Volcoross + Larodar on one path,
--     Council of Dreams + Nymue on the other. Both pairs must complete
--     before Smolderon's wing opens. From there it's a linear chain
--     (Smolderon -> Tindral -> Fyrakk). routing[] flattens this into a
--     single recommended order; players who diverge will see "next step
--     still locked" guidance from the addon even though their lockout
--     would permit the kill.
--
-- (2) Fyrakk's headline drops are a Mythic-only legendary mount (Reins
--     of Anu'relos, the only non-drake mount that uses the Dragonriding
--     system) and a rare-drop Drakewatcher Manuscript that re-skins the
--     Renewed Proto-Drake with Fyrakk's pre-Shadowflame appearance.
--     A second manuscript (Embodiment of Shadowflame) was the AOTC reward
--     for Heroic Fyrakk during Dragonflight; it was made unobtainable at
--     the launch of The War Within and is not surfaced in this file.
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2549] = {
    instanceID        = 2549,
    journalInstanceID = 1207,
    name              = "Amirdrassil, the Dream's Hope",
    expansion         = "Dragonflight",
    patch             = "10.2",

    -- Sub-zone mapIDs for Amirdrassil's wings. Names match the in-game
    -- world-map dropdown verbatim. Used by the routing renderer to label
    -- the active region in the panel header.
    maps = {
        [2232] = "Wellspring Atrium",
        [2233] = "Throne of the Firelord",
        [2236] = "The Blessed Boughs",
        [2234] = "The Blessed Boughs",
        [2238] = "Heart of Amirdrassil",
        [2240] = "Verdant Terrace",
        [2244] = "The Scorched Hall",
    },

    -- Dragonflight Season 3 tier set: "Amirdrassil, the Dream's Hope" token
    -- family. Vault (S1) used gem names; Aberrus (S2) used verb-form
    -- scientific words; Amirdrassil (S3) shifted to "Dreamheart" adjectives
    -- (Tormented=Hands, Ashen=Legs, Verdurous=Chest, Smoldering=Shoulder,
    -- Blazing=Head). A second token line uses chronograph/timestrand/
    -- hourglass/bronzestone/hypersphere words for the same five slots,
    -- corresponding to the Bronze Dragonflight loot variant. Both lines
    -- are tracked here under the same setID.
    tierSets = {
        labels = {
            "Amirdrassil, the Dream's Hope",  -- setID=3137
        },
        tokenSources = {
            -- Igira the Cruel (Hands)
            [207466] = 2,  -- Dreadful Tormented Dreamheart
            [217320] = 2,  -- Dreadful Quickened Bronzestone
            [207467] = 2,  -- Mystic Tormented Dreamheart
            [217321] = 2,  -- Mystic Quickened Bronzestone
            [207468] = 2,  -- Venerated Tormented Dreamheart
            [217322] = 2,  -- Venerated Quickened Bronzestone
            [207469] = 2,  -- Zenith Tormented Dreamheart
            [217323] = 2,  -- Zenith Quickened Bronzestone
            -- Larodar, Keeper of the Flame (Legs)
            [207474] = 5,  -- Dreadful Ashen Dreamheart
            [217328] = 5,  -- Dreadful Ephemeral Hypersphere
            [207475] = 5,  -- Mystic Ashen Dreamheart
            [217329] = 5,  -- Mystic Ephemeral Hypersphere
            [207476] = 5,  -- Venerated Ashen Dreamheart
            [217330] = 5,  -- Venerated Ephemeral Hypersphere
            [207477] = 5,  -- Zenith Ashen Dreamheart
            [217331] = 5,  -- Zenith Ephemeral Hypersphere
            -- Nymue, Weaver of the Cycle (Chest)
            [207462] = 6,  -- Dreadful Verdurous Dreamheart
            [217316] = 6,  -- Dreadful Fleeting Hourglass
            [207463] = 6,  -- Mystic Verdurous Dreamheart
            [217317] = 6,  -- Mystic Fleeting Hourglass
            [207464] = 6,  -- Venerated Verdurous Dreamheart
            [217318] = 6,  -- Venerated Fleeting Hourglass
            [207465] = 6,  -- Zenith Verdurous Dreamheart
            [217319] = 6,  -- Zenith Fleeting Hourglass
            -- Smolderon (Shoulder)
            [207478] = 7,  -- Dreadful Smoldering Dreamheart
            [217332] = 7,  -- Dreadful Synchronous Timestrand
            [207479] = 7,  -- Mystic Smoldering Dreamheart
            [217333] = 7,  -- Mystic Synchronous Timestrand
            [207480] = 7,  -- Venerated Smoldering Dreamheart
            [217334] = 7,  -- Venerated Synchronous Timestrand
            [207481] = 7,  -- Zenith Smoldering Dreamheart
            [217335] = 7,  -- Zenith Synchronous Timestrand
            -- Tindral Sageswift, Seer of the Flame (Head)
            [207470] = 8,  -- Dreadful Blazing Dreamheart
            [217324] = 8,  -- Dreadful Decelerating Chronograph
            [207471] = 8,  -- Mystic Blazing Dreamheart
            [217325] = 8,  -- Mystic Decelerating Chronograph
            [207472] = 8,  -- Venerated Blazing Dreamheart
            [217326] = 8,  -- Venerated Decelerating Chronograph
            [207473] = 8,  -- Zenith Blazing Dreamheart
            [217327] = 8,  -- Zenith Decelerating Chronograph
        },
    },

    -- Raid skip quests. Account-wide unlock per Patch 11.0.5; check via
    -- C_QuestLog.IsQuestFlaggedCompletedOnAccount. Per-character
    -- IsQuestFlaggedCompleted does NOT reflect the unlock for alts that
    -- did not personally complete the quest.
    --
    -- Only the questID for the difficulty actually completed returns
    -- true; the in-game cascade that lets you use the skip on lower
    -- difficulties happens at the skip NPC, NOT by backfilling the
    -- per-difficulty quest flags. To detect "skip is available at any
    -- difficulty", OR across all three IDs.
    skipQuests = {
        normal = 78600,
        heroic = 78601,
        mythic = 78602,
    },

    bosses = {
        {
            index              = 1,
            name               = "Gnarlroot",
            journalEncounterID = 2564,
            achievements = {
                { id = 19322, name = "Meaner Pastures", meta = true },
            },
            loot = {
                { id=207160, slot="Back",     name="Inflammable Drapeleaf",       sources={ [17]=193497, [14]=188714, [15]=193498, [16]=193499 } },
                { id=207142, slot="Chest",    name="Ancient Haubark",             sources={ [17]=193418, [14]=188697, [15]=193419, [16]=193420 } },
                { id=207126, slot="Feet",     name="Twisted Blossom Stompers",    sources={ [17]=192627, [14]=188681, [15]=192628, [16]=192629 } },
                { id=207133, slot="Head",     name="Silent Tormentor's Hood",     sources={ [17]=192583, [14]=188688, [15]=192584, [16]=192585 } },
                { id=207153, slot="Legs",     name="Seared Ironwood Greaves",     sources={ [17]=193184, [14]=188708, [15]=193185, [16]=193186 } },
                { id=207797, slot="Off-hand", name="Defender of the Ancient",     sources={ [17]=191040, [14]=188899, [15]=191041, [16]=191042 } },
                { id=207117, slot="Shoulder", name="Requiem Rootmantle",          sources={ [17]=193532, [14]=188672, [15]=193533, [16]=193534 } },
                { id=207800, slot="Two-Hand", name="Gnarlroot's Bonecrusher",     sources={ [17]=191047, [14]=188902, [15]=191048, [16]=191049 } },
                { id=207794, slot="Two-Hand", name="Staff of Incandescent Torment", sources={ [17]=191034, [14]=188896, [15]=191035, [16]=191036 } },
                { id=207144, slot="Waist",    name="Forlorn Leaf Clasp",          sources={ [17]=193483, [14]=188699, [15]=193484, [16]=193485 } },
                { id=207120, slot="Wrist",    name="Anguished Restraints",        sources={ [17]=194147, [14]=188675, [15]=194148, [16]=194149 } },
            },
        },
        {
            index              = 2,
            name               = "Igira the Cruel",
            journalEncounterID = 2554,
            aliases            = { "Igira" },
            achievements = {
                { id = 19320, name = "Cruelty Free", meta = true },
            },
            loot = {
                { id=207118, slot="Legs",     name="Elder's Volcanic Wrap",       sources={ [17]=193539, [14]=188673, [15]=193540, [16]=193541 } },
                { id=207140, slot="Shoulder", name="Drakestalker's Trophy Pauldrons", sources={ [17]=193316, [14]=188695, [15]=193317, [16]=193318 } },
                { id=207131, slot="Waist",    name="Bloody Dragonhide Belt",      sources={ [17]=192572, [14]=188686, [15]=192573, [16]=192574 } },
                { id=207783, slot="Weapon",   name="Cruel Dreamcarver",           sources={ [17]=191037, [14]=188885, [15]=191038, [16]=191039 } },
                { id=207787, slot="Weapon",   name="Igira's Flaying Hatchet",     sources={ [17]=191043, [14]=188889, [15]=191044, [16]=191045 } },
                { id=207150, slot="Wrist",    name="Agonizing Manacles",          sources={ [17]=193239, [14]=188705, [15]=193240, [16]=193241 } },
                -- Tier Hands (13 classes)
                { id=207183, slot="Hands", name="Molten Vanguard's Crushers",            sources={ [17]=193140, [14]=188722, [15]=193141, [16]=193142 }, classes={ 1 } },
                { id=207192, slot="Hands", name="Zealous Pyreknight's Jeweled Gauntlets", sources={ [17]=189349, [14]=188731, [15]=189350, [16]=189351 }, classes={ 2 } },
                { id=207219, slot="Hands", name="Blazing Dreamstalker's Skinners",       sources={ [17]=193379, [14]=188758, [15]=193380, [16]=193381 }, classes={ 3 } },
                { id=207237, slot="Hands", name="Lucid Shadewalker's Clawgrips",         sources={ [17]=191241, [14]=188776, [15]=191242, [16]=191243 }, classes={ 4 } },
                { id=207282, slot="Hands", name="Touch of Lunar Communion",              sources={ [17]=190052, [14]=188821, [15]=190053, [16]=190054 }, classes={ 5 } },
                { id=207201, slot="Hands", name="Thorns of the Risen Nightmare",         sources={ [17]=192286, [14]=188740, [15]=192287, [16]=192288 }, classes={ 6 } },
                { id=207210, slot="Hands", name="Greatwolf Outcast's Grips",             sources={ [17]=189448, [14]=188749, [15]=189449, [16]=189450 }, classes={ 7 } },
                { id=207291, slot="Hands", name="Wayward Chronomancer's Gloves",         sources={ [17]=189140, [14]=188830, [15]=189141, [16]=189142 }, classes={ 8 } },
                { id=207273, slot="Hands", name="Devout Ashdevil's Claws",               sources={ [17]=189250, [14]=188812, [15]=189251, [16]=189252 }, classes={ 9 } },
                { id=207246, slot="Hands", name="Mystic Heron's Glovebills",             sources={ [17]=189547, [14]=188785, [15]=189548, [16]=189549 }, classes={ 10 } },
                { id=207255, slot="Hands", name="Benevolent Embersage's Talons",         sources={ [17]=192517, [14]=188794, [15]=192518, [16]=192519 }, classes={ 11 } },
                { id=207264, slot="Hands", name="Screaming Torchfiend's Grasp",          sources={ [17]=192385, [14]=188803, [15]=192386, [16]=192387 }, classes={ 12 } },
                { id=207228, slot="Hands", name="Weyrnkeeper's Timeless Clawguards",     sources={ [17]=192032, [14]=188767, [15]=192033, [16]=192034 }, classes={ 13 } },
            },
        },
        {
            index              = 3,
            name               = "Volcoross",
            journalEncounterID = 2557,
            achievements = {
                { id = 19321, name = "Swog Champion", meta = true },
            },
            loot = {
                { id=207121, slot="Chest",    name="Vesture of the Smoldering Serpent", sources={ [17]=193567, [14]=188676, [15]=193568, [16]=193569 } },
                { id=207148, slot="Feet",     name="Lavaforged Sollerets",        sources={ [17]=193228, [14]=188703, [15]=193229, [16]=193230 } },
                { id=207122, slot="Feet",     name="Lost Scholar's Belted Treads", sources={ [17]=193518, [14]=188677, [15]=193519, [16]=193520 } },
                { id=207130, slot="Hands",    name="Flamewaker's Grips",          sources={ [17]=192638, [14]=188685, [15]=192639, [16]=192640 } },
                { id=207141, slot="Head",     name="Snake Eater's Cowl",          sources={ [17]=193476, [14]=188696, [15]=193477, [16]=193478 } },
                { id=207785, slot="Ranged",   name="Magmatic Volcannon",          sources={ [17]=191056, [14]=188887, [15]=191057, [16]=191058 } },
                { id=207152, slot="Shoulder", name="Volcanic Spelunker's Vents",  sources={ [17]=193250, [14]=188707, [15]=193251, [16]=193252 } },
                { id=207146, slot="Waist",    name="Jeweled Sash of the Viper",   sources={ [17]=193330, [14]=188701, [15]=193331, [16]=193332 } },
                { id=207789, slot="Weapon",   name="Volcoross's Barbed Fang",     sources={ [17]=191053, [14]=188891, [15]=191054, [16]=191055 } },
                { id=207128, slot="Wrist",    name="Primordial Serpent's Bindings", sources={ [17]=192561, [14]=188683, [15]=192562, [16]=192563 } },
            },
        },
        {
            index              = 4,
            name               = "Council of Dreams",
            journalEncounterID = 2555,
            aliases            = { "Council" },
            achievements = {
                { id = 19193, name = "Ducks In A Row", meta = true },
            },
            loot = {
                { id=207139, slot="Feet",             name="Cleats of the Savage Claw",       sources={ [17]=193469, [14]=188694, [15]=193470, [16]=193471 } },
                { id=207151, slot="Head",             name="Emerald Guardian's Casque",       sources={ [17]=193272, [14]=188706, [15]=193273, [16]=193274 } },
                { id=207796, slot="Held In Off-hand", name="Trickster's Captivating Chime",   sources={ [17]=191059, [14]=188898, [15]=191060, [16]=191061 } },
                { id=207138, slot="Legs",             name="Aerwynn's Ritual Sarong",         sources={ [17]=193462, [14]=188693, [15]=193463, [16]=193464 } },
                { id=207127, slot="Shoulder",         name="Strigine Epaulets",               sources={ [17]=192418, [14]=188682, [15]=192419, [16]=192420 } },
                { id=207119, slot="Waist",            name="Urctos's Hibernal Dial",          sources={ [17]=193511, [14]=188674, [15]=193512, [16]=193513 } },
                { id=207782, slot="Weapon",           name="Sickle of the White Stag",        sources={ [17]=191083, [14]=188884, [15]=191084, [16]=191085 } },
                { id=207784, slot="Weapon",           name="Thorncaller Claw",                sources={ [17]=191062, [14]=188886, [15]=191063, [16]=191064 } },
                { id=210206, slot="Wrist",            name="Verdant Sanctuary Bands",         sources={ [17]=192616, [14]=191965, [15]=192617, [16]=192618 } },
                { id=210205, slot="Wrist",            name="Vigilant Protector's Bracers",    sources={ [17]=193217, [14]=191964, [15]=193218, [16]=193219 } },
            },
            soloTip = "Bosses must die around the same time, so bring them down at the same pace. When you get polymorphed, run over 3 green circles, walk under Urctos, and press 2 on your action bar to return to normal.",
        },
        {
            index              = 5,
            name               = "Larodar, Keeper of the Flame",
            journalEncounterID = 2553,
            aliases            = { "Larodar" },
            achievements = {
                { id = 19089, name = "Don't Let the Doe Hit You On The Way Out", meta = true },
            },
            specialLoot = {
                { id = 209035, kind = "toy", name = "Hearthstone of the Flame" },
            },
            loot = {
                { id=207129, slot="Chest",    name="Robes of the Ashen Grove",     sources={ [17]=192429, [14]=188684, [15]=192430, [16]=192431 } },
                { id=207116, slot="Head",     name="Lost Scholar's Timely Hat",    sources={ [17]=193504, [14]=188671, [15]=193505, [16]=193506 } },
                { id=207792, slot="Two-Hand", name="Scythe of the Fallen Keeper",  sources={ [17]=191068, [14]=188894, [15]=191069, [16]=191070 } },
                { id=207149, slot="Waist",    name="Phlegethic Girdle",            sources={ [17]=193173, [14]=188704, [15]=193174, [16]=193175 } },
                { id=207790, slot="Weapon",   name="Larodar's Moonblade",          sources={ [17]=191065, [14]=188892, [15]=191066, [16]=191067 } },
                { id=207143, slot="Wrist",    name="Twisted Flamecuffs",           sources={ [17]=193429, [14]=188698, [15]=193430, [16]=193431 } },
                -- Tier Legs (13 classes)
                { id=207181, slot="Legs", name="Molten Vanguard's Steel Tassets",   sources={ [17]=193118, [14]=188720, [15]=193119, [16]=193120 }, classes={ 1 } },
                { id=207190, slot="Legs", name="Zealous Pyreknight's Cuisses",      sources={ [17]=189327, [14]=188729, [15]=189328, [16]=189329 }, classes={ 2 } },
                { id=207217, slot="Legs", name="Blazing Dreamstalker's Shellgreaves", sources={ [17]=193365, [14]=188756, [15]=193366, [16]=193367 }, classes={ 3 } },
                { id=207235, slot="Legs", name="Lucid Shadewalker's Chausses",      sources={ [17]=191231, [14]=188774, [15]=191232, [16]=191233 }, classes={ 4 } },
                { id=207280, slot="Legs", name="Leggings of Lunar Communion",       sources={ [17]=190030, [14]=188819, [15]=190031, [16]=190032 }, classes={ 5 } },
                { id=207199, slot="Legs", name="Greaves of the Risen Nightmare",    sources={ [17]=192264, [14]=188738, [15]=192265, [16]=192266 }, classes={ 6 } },
                { id=207208, slot="Legs", name="Greatwolf Outcast's Fur-Lined Kilt", sources={ [17]=189426, [14]=188747, [15]=189427, [16]=189428 }, classes={ 7 } },
                { id=207289, slot="Legs", name="Wayward Chronomancer's Pantaloons", sources={ [17]=189118, [14]=188828, [15]=189119, [16]=189120 }, classes={ 8 } },
                { id=207271, slot="Legs", name="Devout Ashdevil's Tights",          sources={ [17]=189228, [14]=188810, [15]=189229, [16]=189230 }, classes={ 9 } },
                { id=207244, slot="Legs", name="Mystic Heron's Waders",             sources={ [17]=189525, [14]=188783, [15]=189526, [16]=189527 }, classes={ 10 } },
                { id=207253, slot="Legs", name="Benevolent Embersage's Leggings",   sources={ [17]=192495, [14]=188792, [15]=192496, [16]=192497 }, classes={ 11 } },
                { id=207262, slot="Legs", name="Screaming Torchfiend's Blazewraps", sources={ [17]=192363, [14]=188801, [15]=192364, [16]=192365 }, classes={ 12 } },
                { id=207226, slot="Legs", name="Weyrnkeeper's Timeless Breeches",   sources={ [17]=192010, [14]=188765, [15]=192011, [16]=192012 }, classes={ 13 } },
            },
        },
        {
            index              = 6,
            name               = "Nymue, Weaver of the Cycle",
            journalEncounterID = 2556,
            aliases            = { "Nymue" },
            achievements = {
                { id = 19394, name = "A Dream Within a Dream", meta = true },
            },
            loot = {
                { id=207123, slot="Feet",     name="Lifewoven Slippers",                  sources={ [17]=193546, [14]=188678, [15]=193547, [16]=193548 } },
                { id=207155, slot="Hands",    name="Eldermoss Gauntlets",                 sources={ [17]=193283, [14]=188710, [15]=193284, [16]=193285 } },
                { id=207798, slot="Off-hand", name="Verdant Matrix Beacon",               sources={ [17]=191074, [14]=188900, [15]=191075, [16]=191076 } },
                { id=208616, slot="Two-Hand", name="Dreambinder, Loom of the Great Cycle", sources={ [17]=191071, [14]=189940, [15]=191072, [16]=191073 } },
                { id=207135, slot="Waist",    name="Eternal Sentinel's Cord",             sources={ [17]=192440, [14]=188690, [15]=192441, [16]=192442 } },
                { id=210203, slot="Wrist",    name="Wellspring Wristlets",                sources={ [17]=193400, [14]=191962, [15]=193401, [16]=193402 } },
                -- Tier Chest (13 classes)
                { id=207185, slot="Chest", name="Molten Vanguard's Plackart",            sources={ [17]=193162, [14]=188724, [15]=193163, [16]=193164 }, classes={ 1 } },
                { id=207194, slot="Chest", name="Zealous Pyreknight's Warplate",         sources={ [17]=189371, [14]=188733, [15]=189372, [16]=189373 }, classes={ 2 } },
                { id=207221, slot="Chest", name="Blazing Dreamstalker's Scaled Hauberk", sources={ [17]=193393, [14]=188760, [15]=193394, [16]=193395 }, classes={ 3 } },
                { id=207239, slot="Chest", name="Lucid Shadewalker's Cuirass",           sources={ [17]=191251, [14]=188778, [15]=191252, [16]=191253 }, classes={ 4 } },
                { id=207284, slot="Chest", name="Cassock of Lunar Communion",            sources={ [17]=190074, [14]=188823, [15]=190075, [16]=190076 }, classes={ 5 } },
                { id=207203, slot="Chest", name="Casket of the Risen Nightmare",         sources={ [17]=192308, [14]=188742, [15]=192309, [16]=192310 }, classes={ 6 } },
                { id=207212, slot="Chest", name="Greatwolf Outcast's Harness",           sources={ [17]=189470, [14]=188751, [15]=189471, [16]=189472 }, classes={ 7 } },
                { id=207293, slot="Chest", name="Wayward Chronomancer's Patchwork",      sources={ [17]=189162, [14]=188832, [15]=189163, [16]=189164 }, classes={ 8 } },
                { id=207275, slot="Chest", name="Devout Ashdevil's Razorhide",           sources={ [17]=189272, [14]=188814, [15]=189273, [16]=189274 }, classes={ 9 } },
                { id=207248, slot="Chest", name="Mystic Heron's Burdens",                sources={ [17]=189569, [14]=188787, [15]=189570, [16]=189571 }, classes={ 10 } },
                { id=207257, slot="Chest", name="Benevolent Embersage's Robe",           sources={ [17]=192539, [14]=188796, [15]=192540, [16]=192541 }, classes={ 11 } },
                { id=207266, slot="Chest", name="Screaming Torchfiend's Binding",        sources={ [17]=192407, [14]=188805, [15]=192408, [16]=192409 }, classes={ 12 } },
                { id=207230, slot="Chest", name="Weyrnkeeper's Timeless Raiment",        sources={ [17]=192054, [14]=188769, [15]=192055, [16]=192056 }, classes={ 13 } },
            },
            soloTip = "Interrupt/kill both trees to start the fight. When she casts Weaver's Burden on you, run it away from your primary position to drop it out of the way. During intermission(s), interrupt/kill adds.",
        },
        {
            index              = 7,
            name               = "Smolderon",
            journalEncounterID = 2563,
            achievements = {
                { id = 19319, name = "Haven't We Done This Before?", meta = true },
            },
            loot = {
                { id=207161, slot="Back",     name="Mantle of Blazing Sacrifice", sources={ [17]=193490, [14]=188715, [15]=193491, [16]=193492 } },
                { id=207156, slot="Feet",     name="Fused Obsidian Sabatons",     sources={ [17]=193195, [14]=188711, [15]=193196, [16]=193197 } },
                { id=207799, slot="Two-Hand", name="Incandescent Soulcleaver",    sources={ [17]=191077, [14]=188901, [15]=191078, [16]=191079 } },
                { id=207791, slot="Weapon",   name="Remnant Charglaive",          sources={ [17]=191080, [14]=188893, [15]=191081, [16]=191082 } },
                { id=210204, slot="Wrist",    name="Fading Flame Wristbands",     sources={ [17]=193581, [14]=191963, [15]=193582, [16]=193583 } },
                -- Tier Shoulder (13 classes)
                { id=207180, slot="Shoulder", name="Molten Vanguard's Shouldervents",     sources={ [17]=193107, [14]=188719, [15]=193108, [16]=193109 }, classes={ 1 } },
                { id=207189, slot="Shoulder", name="Zealous Pyreknight's Ailettes",       sources={ [17]=189316, [14]=188728, [15]=189317, [16]=189318 }, classes={ 2 } },
                { id=207216, slot="Shoulder", name="Blazing Dreamstalker's Finest Hunt",  sources={ [17]=193358, [14]=188755, [15]=193359, [16]=193360 }, classes={ 3 } },
                { id=207234, slot="Shoulder", name="Lucid Shadewalker's Bladed Spaulders", sources={ [17]=191226, [14]=188773, [15]=191227, [16]=191228 }, classes={ 4 } },
                { id=207279, slot="Shoulder", name="Shoulderguardians of Lunar Communion", sources={ [17]=190019, [14]=188818, [15]=190020, [16]=190021 }, classes={ 5 } },
                { id=207198, slot="Shoulder", name="Skewers of the Risen Nightmare",      sources={ [17]=192253, [14]=188737, [15]=192254, [16]=192255 }, classes={ 6 } },
                { id=207207, slot="Shoulder", name="Greatwolf Outcast's Companions",      sources={ [17]=189415, [14]=188746, [15]=189416, [16]=189417 }, classes={ 7 } },
                { id=207288, slot="Shoulder", name="Wayward Chronomancer's Metronomes",   sources={ [17]=189107, [14]=188827, [15]=189108, [16]=189109 }, classes={ 8 } },
                { id=207270, slot="Shoulder", name="Devout Ashdevil's Hatespikes",        sources={ [17]=189217, [14]=188809, [15]=189218, [16]=189219 }, classes={ 9 } },
                { id=207243, slot="Shoulder", name="Mystic Heron's Hopeful Effigy",       sources={ [17]=189514, [14]=188782, [15]=189515, [16]=189516 }, classes={ 10 } },
                { id=207252, slot="Shoulder", name="Benevolent Embersage's Wisdom",       sources={ [17]=192484, [14]=188791, [15]=192485, [16]=192486 }, classes={ 11 } },
                { id=207261, slot="Shoulder", name="Screaming Torchfiend's Horned Memento", sources={ [17]=192352, [14]=188800, [15]=192353, [16]=192354 }, classes={ 12 } },
                { id=207225, slot="Shoulder", name="Weyrnkeeper's Timeless Sandbrace",    sources={ [17]=191999, [14]=188764, [15]=192000, [16]=192001 }, classes={ 13 } },
            },
        },
        {
            index              = 8,
            name               = "Tindral Sageswift, Seer of the Flame",
            journalEncounterID = 2565,
            aliases            = { "Tindral" },
            achievements = {
                { id = 19393, name = "Whelp, I'm Lost", meta = true },
            },
            loot = {
                { id=207134, slot="Feet",     name="Tasseted Emberwalkers",       sources={ [17]=192594, [14]=188689, [15]=192595, [16]=192596 } },
                { id=207137, slot="Hands",    name="Flameseer's Winged Grasps",   sources={ [17]=193407, [14]=188692, [15]=193408, [16]=193409 } },
                { id=207780, slot="Ranged",   name="Ashen Ranger's Longbow",      sources={ [17]=191089, [14]=188882, [15]=191090, [16]=191091 } },
                { id=207795, slot="Two-Hand", name="Eternal Kindler's Greatstaff", sources={ [17]=191086, [14]=188897, [15]=191087, [16]=191088 } },
                { id=207157, slot="Waist",    name="Smoldering Chevalier's Greatbelt", sources={ [17]=193294, [14]=188712, [15]=193295, [16]=193296 } },
                { id=207781, slot="Weapon",   name="Betrayer's Cinderblade",      sources={ [17]=191050, [14]=188883, [15]=191051, [16]=191052 } },
                -- Tier Head (13 classes)
                { id=207182, slot="Head", name="Molten Vanguard's Domeplate",             sources={ [17]=193129, [14]=188721, [15]=193130, [16]=193131 }, classes={ 1 } },
                { id=207191, slot="Head", name="Zealous Pyreknight's Barbute",            sources={ [17]=189338, [14]=188730, [15]=189339, [16]=189340 }, classes={ 2 } },
                { id=207218, slot="Head", name="Blazing Dreamstalker's Flamewaker Horns", sources={ [17]=193372, [14]=188757, [15]=193373, [16]=193374 }, classes={ 3 } },
                { id=207236, slot="Head", name="Lucid Shadewalker's Deathmask",           sources={ [17]=191236, [14]=188775, [15]=191237, [16]=191238 }, classes={ 4 } },
                { id=207281, slot="Head", name="Crest of Lunar Communion",                sources={ [17]=190041, [14]=188820, [15]=190042, [16]=190043 }, classes={ 5 } },
                { id=207200, slot="Head", name="Piercing Gaze of the Risen Nightmare",    sources={ [17]=192275, [14]=188739, [15]=192276, [16]=192277 }, classes={ 6 } },
                { id=207209, slot="Head", name="Greatwolf Outcast's Jaws",                sources={ [17]=189437, [14]=188748, [15]=189438, [16]=189439 }, classes={ 7 } },
                { id=207290, slot="Head", name="Wayward Chronomancer's Chronocap",        sources={ [17]=189129, [14]=188829, [15]=189130, [16]=189131 }, classes={ 8 } },
                { id=207272, slot="Head", name="Devout Ashdevil's Grimhorns",             sources={ [17]=189239, [14]=188811, [15]=189240, [16]=189241 }, classes={ 9 } },
                { id=207245, slot="Head", name="Mystic Heron's Hatsuburi",                sources={ [17]=189536, [14]=188784, [15]=189537, [16]=189538 }, classes={ 10 } },
                { id=207254, slot="Head", name="Benevolent Embersage's Casque",           sources={ [17]=192506, [14]=188793, [15]=192507, [16]=192508 }, classes={ 11 } },
                { id=207263, slot="Head", name="Screaming Torchfiend's Burning Scowl",    sources={ [17]=192374, [14]=188802, [15]=192375, [16]=192376 }, classes={ 12 } },
                { id=207227, slot="Head", name="Weyrnkeeper's Timeless Dracoif",          sources={ [17]=192021, [14]=188766, [15]=192022, [16]=192023 }, classes={ 13 } },
            },
            soloTip = "When feathers spawn near the boss, grab one. Mount up and follow him.",
        },
        {
            index              = 9,
            name               = "Fyrakk the Blazing",
            journalEncounterID = 2519,
            aliases            = { "Fyrakk" },
            achievements = {
                { id = 19390, name = "Memories of Teldrassil", meta = true },
            },
            specialLoot = {
                -- Reins of Anu'relos, Flame's Guidance. Mythic-only legendary
                -- mount; the only non-drake mount in the game that uses the
                -- Dragonriding system. Learning the mount also grants Feather
                -- of the Blazing Somnowl (a Druid Flight Form skin) and Cinder
                -- of Companionship (lets Hunters tame the spirit beast Nah'qi)
                -- account-wide.
                { id = 210061, kind = "mount", name = "Reins of Anu'relos, Flame's Guidance", mythicOnly = true },
                -- Renewed Proto-Drake: Embodiment of the Blazing
                -- (Drakewatcher Manuscript). Rare random drop on all
                -- difficulties; drop rate is roughly 1%.
                {
                    id      = 210536,
                    kind    = "manuscript",
                    name    = "Renewed Proto-Drake: Embodiment of the Blazing",
                    questID = 78451,
                },
            },
            loot = {
                { id=207154, slot="Chest",    name="Carapace of the Unbending Flame", sources={ [17]=193261, [14]=188709, [15]=193262, [16]=193263 } },
                { id=207145, slot="Feet",     name="Boots of the Molten Hoard",   sources={ [17]=193323, [14]=188700, [15]=193324, [16]=193325 } },
                { id=207115, slot="Hands",    name="Twisting Shadow Claws",       sources={ [17]=193560, [14]=188670, [15]=193561, [16]=193562 } },
                { id=207132, slot="Legs",     name="Frenzied Incarnate Legwraps", sources={ [17]=192649, [14]=188687, [15]=192650, [16]=192651 } },
                -- Fyr'alath the Dreamrender (legendary axe). One shared
                -- appearance across all four difficulties because legendaries
                -- don't have per-difficulty appearance variants.
                { id=207728, slot="Two-Hand", name="Fyr'alath the Dreamrender",  sources={ [17]=188881, [14]=188881, [15]=188881, [16]=188881 } },
                { id=207793, slot="Two-Hand", name="Rashon, the Immortal Blaze", sources={ [17]=191098, [14]=188895, [15]=191099, [16]=191100 } },
                { id=207124, slot="Waist",    name="Blooming Redeemer's Sash",    sources={ [17]=193553, [14]=188679, [15]=193554, [16]=193555 } },
                { id=207786, slot="Weapon",   name="Gholak, the Final Conflagration", sources={ [17]=191092, [14]=188888, [15]=191093, [16]=191094 } },
                { id=207788, slot="Weapon",   name="Vakash, the Shadowed Inferno", sources={ [17]=191095, [14]=188890, [15]=191096, [16]=191097 } },
            },
            -- Flame-Warped Curio is an omnitoken Fyrakk drops alongside
            -- the standard tier piece -- it can be exchanged for any tier
            -- slot of the player's choice.
            tmogFootnote = {
                text   = "Fyrakk additionally drops {item}, an omnitoken that exchanges for any tier slot. Not tracked here.",
                itemID = 210947,
            },
        },
    },

    routing = {

        -- 1. Gnarlroot
        -- Single segment on mapID 2232 (Wellspring Atrium). The raid
        -- entrance opens directly into Gnarlroot's wing -- the path
        -- runs from the zone-in spawn straight ahead, clearing trash
        -- en route to start the encounter.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Gnarlroot",
            requires  = {},
            segments  = {
                {
                    mapID   = 2232,
                    kind    = "path",
                    subZone = "Wellspring Atrium",
                    note    = "After zoning in, follow the path to Gnarlroot. Clear the trash around him to start the encounter.",
                    points  = {
                        { 0.507, 0.904 },
                        { 0.448, 0.817 },
                        { 0.463, 0.704 },
                        { 0.461, 0.588 },
                        { 0.507, 0.554 },
                        { 0.508, 0.437 },
                    },
                },
            },
        },

        -- 2. Igira the Cruel
        -- Single segment on mapID 2232 (same Wellspring Atrium map as
        -- Gnarlroot). The path continues forward from Gnarlroot's pull
        -- spot through one trash pack to Igira's pull point.
        {
            step      = 2,
            priority  = 1,
            bossIndex = 2,
            title     = "Igira the Cruel",
            requires  = { 1 },
            segments  = {
                {
                    mapID   = 2232,
                    kind    = "path",
                    subZone = "Wellspring Atrium",
                    note    = "After killing Gnarlroot, continue forward and clear the trash pack to start the encounter with Igira the Cruel.",
                    points  = {
                        { 0.507, 0.368 },
                        { 0.506, 0.288 },
                    },
                },
            },
        },

        -- 3. Volcoross
        -- Two segments. Seg 1 crosses the last bit of mapID 2232
        -- (Wellspring Atrium) to the Scorched Hall exit on the left.
        -- Seg 2 picks up on mapID 2244 (The Scorched Hall) and runs
        -- through the Pit of Volcoross sub-area to the boss.
        {
            step      = 3,
            priority  = 1,
            bossIndex = 3,
            title     = "Volcoross",
            requires  = { 1, 2 },
            segments  = {
                {
                    mapID   = 2232,
                    kind    = "path",
                    subZone = "Wellspring Atrium",
                    note    = "After killing Igira, take the left exit to The Scorched Hall.",
                    points  = {
                        { 0.486, 0.257 },
                        { 0.440, 0.211 },
                    },
                },
                {
                    mapID   = 2244,
                    kind    = "path",
                    subZone = "Pit of Volcoross",
                    note    = "Follow the path to the boss area, and clear the trash to spawn Volcoross.",
                    points  = {
                        { 0.768, 0.878 },
                        { 0.733, 0.803 },
                        { 0.674, 0.718 },
                        { 0.625, 0.709 },
                        { 0.572, 0.619 },
                    },
                },
            },
        },

        -- 4. Larodar, Keeper of the Flame
        -- Single segment on mapID 2244 (same Scorched Hall map as
        -- Volcoross). The path continues from Volcoross's pull spot
        -- through trash to Larodar's pull point in The Charred Arbor.
        {
            step      = 4,
            priority  = 1,
            bossIndex = 5,
            title     = "Larodar, Keeper of the Flame",
            requires  = { 1, 2, 3 },
            segments  = {
                {
                    mapID   = 2244,
                    kind    = "path",
                    subZone = "The Charred Arbor",
                    note    = "After killing Volcoross, continue down the path behind him. Clear trash to start the encounter with Larodar, Keeper of the Flame.",
                    points  = {
                        { 0.528, 0.556 },
                        { 0.466, 0.470 },
                        { 0.439, 0.430 },
                        { 0.387, 0.354 },
                    },
                },
            },
        },

        -- 5. Council of Dreams
        -- Three segments. After Larodar dies, a seed-activated portal at
        -- the back of the room teleports the player back to the Wellspring
        -- Atrium hub. From there, the route exits east into the Verdant
        -- Terrace wing and continues to the Council's arena in the Sylvan
        -- Conservatory sub-area.
        {
            step      = 5,
            priority  = 2,
            bossIndex = 4,
            title     = "Council of Dreams",
            requires  = { 1, 2 },
            segments  = {
                {
                    mapID       = 2244,
                    kind        = "teleport",
                    subZone     = "The Charred Arbor",
                    destination = "Wellspring Atrium",
                    note        = "After killing Larodar, interact with the seed to unlock a portal at the back of the room. Walk through the portal to arrive back at the Wellspring Atrium.",
                    points      = {
                        { 0.345, 0.289 },
                        { 0.323, 0.331 },
                        { 0.281, 0.330 },
                        { 0.302, 0.223 },
                    },
                },
                {
                    mapID   = 2232,
                    kind    = "path",
                    subZone = "Wellspring Atrium",
                    note    = "After taking the teleport, make your way for the right-most exit labeled Verdant Terrace.",
                    points  = {
                        { 0.422, 0.263 },
                        { 0.584, 0.218 },
                    },
                },
                {
                    mapID   = 2240,
                    kind    = "path",
                    subZone = "Sylvan Conservatory",
                    note    = "Follow the path all the way back to meet the Council of Dreams. Click each of the illusions to start the fight.",
                    points  = {
                        { 0.187, 0.939 },
                        { 0.223, 0.857 },
                        { 0.290, 0.767 },
                        { 0.330, 0.762 },
                        { 0.412, 0.645 },
                    },
                },
            },
        },

        -- 6. Nymue, Weaver of the Cycle
        -- Single segment on mapID 2240 (same Verdant Terrace map as
        -- Council). The path continues from Council's arena through
        -- The Dream's Tapestry sub-area to Nymue's pull point.
        {
            step      = 6,
            priority  = 2,
            bossIndex = 6,
            title     = "Nymue, Weaver of the Cycle",
            requires  = { 1, 2, 4 },
            segments  = {
                {
                    mapID   = 2240,
                    kind    = "path",
                    subZone = "The Dream's Tapestry",
                    note    = "After killing Council of Dreams, follow the path behind them to reach Nymue, Weaver of the Cycle.",
                    points  = {
                        { 0.420, 0.579 },
                        { 0.420, 0.490 },
                        { 0.459, 0.495 },
                        { 0.490, 0.523 },
                        { 0.601, 0.347 },
                    },
                },
            },
        },

        -- 7. Smolderon
        -- Three segments. After Nymue dies, a seed-activated portal at
        -- the back of her room teleports the player back to the Wellspring
        -- Atrium hub (mirroring the Larodar -> Council teleport pattern).
        -- From the hub, the route exits north into the Throne of the
        -- Firelord wing. A formation seed at the wing entrance constructs
        -- the bridge over to Smolderon's platform. The bridge has fire
        -- patches that knock the player off if hit.
        {
            step      = 7,
            priority  = 1,
            bossIndex = 7,
            title     = "Smolderon",
            requires  = { 1, 2, 3, 4, 5, 6 },
            segments  = {
                {
                    mapID       = 2240,
                    kind        = "teleport",
                    subZone     = "The Dream's Tapestry",
                    destination = "Wellspring Atrium",
                    note        = "After killing Nymue, walk up the stairs behind her to interact with the Seed of Life. This opens a portal at the back of the room. Walk through the portal to return back to Wellspring Atrium.",
                    points      = {
                        { 0.643, 0.277 },
                        { 0.667, 0.238 },
                    },
                },
                {
                    mapID   = 2232,
                    kind    = "path",
                    subZone = "Wellspring Atrium",
                    note    = "From Wellspring Atrium, take the final remaining exit labeled Throne of the Firelord. Click on the Formation Seed to construct a bridge to the next area.",
                    points  = {
                        { 0.594, 0.272 },
                        { 0.508, 0.148 },
                    },
                },
                {
                    mapID   = 2233,
                    kind    = "path",
                    subZone = "Throne of the Firelord",
                    note    = "As you cross the bridge, dodge fire so you don't get thrown over the edge. At the end of the bridge, you will find Smolderon.",
                    points  = {
                        { 0.501, 0.941 },
                        { 0.502, 0.370 },
                    },
                },
            },
        },

        -- 8. Tindral Sageswift, Seer of the Flame
        -- After Smolderon dies, a dragon NPC behind him offers a flight
        -- to The Blessed Boughs platform. After landing, approach Tindral
        -- to start the encounter; the platform is small enough that
        -- Blizzard's own boss icon and visible boss model are sufficient
        -- to find him.
        {
            step      = 8,
            priority  = 1,
            bossIndex = 8,
            title     = "Tindral Sageswift, Seer of the Flame",
            requires  = { 1, 2, 3, 4, 5, 6, 7 },
            segments  = {
                {
                    mapID       = 2233,
                    kind        = "teleport",
                    subZone     = "Throne of the Firelord",
                    destination = "The Blessed Boughs",
                    note        = "After killing Smolderon, talk to the dragon to be flown to Tindral Sageswift, Seer of the Flame.",
                    points      = {
                        { 0.504, 0.298 },
                        { 0.458, 0.338 },
                    },
                },
                {
                    mapID   = 2237,
                    kind    = "path",
                    subZone = "The Blessed Boughs",
                    note    = "Approach Tindral to trigger the encounter.",
                },
            },
        },

        -- 9. Fyrakk the Blazing
        -- After Tindral dies, mount up and fly into the fire-colored
        -- portal in the sky to teleport to the Heart of Amirdrassil
        -- platform, then approach Fyrakk to start the encounter. A
        -- marker on the world map shows the portal's location relative
        -- to Tindral's platform; the player's exact landing position
        -- after Tindral is unpredictable, so the marker is more useful
        -- than a path-line.
        {
            step      = 9,
            priority  = 1,
            bossIndex = 9,
            title     = "Fyrakk the Blazing",
            requires  = { 1, 2, 3, 4, 5, 6, 7, 8 },
            segments  = {
                {
                    mapID   = 2234,
                    kind    = "poi",
                    subZone = "The Blessed Boughs",
                    note    = "After killing Tindral, mount up and fly into the fire-colored portal in the sky (marked with a |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t). This will teleport you to Heart of Amirdrassil.",
                    points  = {
                        { 0.540, 0.656 },
                        { 0.538, 0.747 },
                        { 0.568, 0.657 },
                    },
                },
                {
                    mapID       = 2236,
                    kind        = "teleport",
                    subZone     = "The Blessed Boughs",
                    destination = "Heart of Amirdrassil",
                    points      = {
                        { 0.331, 0.602 },
                    },
                },
                {
                    mapID   = 2238,
                    kind    = "path",
                    subZone = "Heart of Amirdrassil",
                    note    = "After the teleport, you should be standing across from Fyrakk. Approach him to start the encounter.",
                    points  = {
                        { 0.256, 0.537 },
                        { 0.537, 0.537 },
                    },
                },
            },
        },

    },
}
