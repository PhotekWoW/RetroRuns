-------------------------------------------------------------------------------
-- RetroRuns Data -- Ruby Life Pools
-- Dragonflight dungeon, Patch 10.0.2  |  instanceID: 2521  |  journalInstanceID: 1202
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1202] = {
    kind              = "dungeon",
    instanceID        = 2521,
    journalInstanceID = 1202,
    name              = "Ruby Life Pools",
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
            name               = "Melidrussa Chillworn",
            journalEncounterID = 2488,
            achievements       = {
                { id = 16402, name = "Dragon Kill Points", meta = true },
            },
            loot = {
                { id = 193728, slot = "Feet", name = "Scaleguard's Stalwart Greatboots", sources = { [14]=180841, [15]=180841, [16]=180841 } },
                { id = 193758, slot = "Hands", name = "Subjugator's Chilling Grips", sources = { [14]=180863, [15]=180863, [16]=180863 } },
                { id = 193759, slot = "Legs", name = "Egg Tender's Leggings", sources = { [14]=180864, [15]=180864, [16]=180864 } },
                { id = 193761, slot = "Two-Hand", name = "Chillworn's Infusion Staff", sources = { [14]=180866, [15]=180866, [16]=180866 } },
            },
        },
        {
            index              = 2,
            name               = "Kokia Blazehoof",
            journalEncounterID = 2485,
            achievements       = {
                { id = 16320, name = "Does Steam Do Fire Damage?", meta = true },
            },
            loot = {
                { id = 193763, slot = "Back", name = "Fireproof Drape", sources = { [14]=180867, [15]=180867, [16]=180867 } },
                { id = 193764, slot = "Chest", name = "Invader's Firestorm Chestguard", sources = { [14]=180868, [15]=180868, [16]=180868 } },
                { id = 193765, slot = "Head", name = "Blazebound Lieutenant's Helm", sources = { [14]=180869, [15]=180869, [16]=180869 } },
                { id = 193766, slot = "Off-hand", name = "Kokia's Burnout Rod", sources = { [14]=180870, [15]=180870, [16]=180870 } },
                { id = 193767, slot = "Weapon", name = "Havoc Crusher", sources = { [14]=180871, [15]=180871, [16]=180871 } },
            },
        },
        {
            index              = 3,
            name               = "Kyrakka and Erkhart Stormvein",
            journalEncounterID = 2503,
            achievements       = {
                { id = 16266, name = "Ruby Life Pools" },
                { id = 16267, name = "Heroic: Ruby Life Pools" },
                { id = 16268, name = "Mythic: Ruby Life Pools" },
                { id = 16440, name = "Are You My Broodmother?", meta = true },
            },
            loot = {
                { id = 193753, slot = "Chest", name = "Breastplate of Soaring Terror", sources = { [14]=180859, [15]=180859, [16]=180859 } },
                { id = 193752, slot = "Hands", name = "Galerattle Gauntlets", sources = { [14]=180858, [15]=180858, [16]=180858 } },
                { id = 193751, slot = "Head", name = "Crown of Roaring Storms", sources = { [14]=180857, [15]=180857, [16]=180857 } },
                { id = 193750, slot = "Legs", name = "Wind Soarer's Breeches", sources = { [14]=180856, [15]=180856, [16]=180856 } },
                { id = 193754, slot = "Off-hand", name = "Drake Rider's Stecktarge", sources = { [14]=180860, [15]=180860, [16]=180860 } },
                { id = 193755, slot = "Two-Hand", name = "Backdraft Cleaver", sources = { [14]=180861, [15]=180861, [16]=180861 } },
                { id = 193691, slot = "Waist", name = "Sky Saddle Cord", sources = { [14]=180811, [15]=180811, [16]=180811 } },
                { id = 193756, slot = "Weapon", name = "Skyferno Rondel", sources = { [14]=180862, [15]=180862, [16]=180862 } },
            },
            specialLoot = {
                { id = 256428, kind = "decor", name = "Valdrakken Hanging Lamp", decorID = 11163 },
            },
        },
    },
}
