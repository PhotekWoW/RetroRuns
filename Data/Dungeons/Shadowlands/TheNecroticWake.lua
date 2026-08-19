-------------------------------------------------------------------------------
-- RetroRuns Data -- The Necrotic Wake
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2286  |  journalInstanceID: 1182
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1182] = {
    kind              = "dungeon",
    instanceID        = 2286,
    journalInstanceID = 1182,
    name              = "The Necrotic Wake",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    patch             = "9.0.1",

    gloryMeta = {
        id   = 14322,
        name = "Glory of the Shadowlands Hero",
        rewardItemID       = 184183,
        rewardMountSpellID = 344659,
        rewardName         = "Voracious Gorger",
    },

    bosses = {
        {
            index              = 1,
            name               = "Blightbone",
            journalEncounterID = 2395,
            achievements       = {
            },
            loot = {
                { id = 178731, slot = "Feet", name = "Viscera-Stitched Footpads", sources = { [14]=111457 } },
                { id = 178732, slot = "Head", name = "Abominable Visage", sources = { [14]=111458 } },
                { id = 178735, slot = "Ranged", name = "Blight Belcher", sources = { [14]=111461 } },
                { id = 178733, slot = "Shoulder", name = "Blightbone Spaulders", sources = { [14]=111459 } },
                { id = 178734, slot = "Waist", name = "Fused Bone Greatbelt", sources = { [14]=111460 } },
                { id = 178730, slot = "Weapon", name = "Engorged Worm Smasher", sources = { [14]=111456 } },
            },
        },
        {
            index              = 2,
            name               = "Amarth, The Harvester",
            journalEncounterID = 2391,
            achievements       = {
                { id = 14295, name = "Bountiful Harvest", meta = true },
            },
            loot = {
                { id = 178738, slot = "Head", name = "Rattling Deadeye Hood", sources = { [14]=111463 } },
                { id = 178739, slot = "Legs", name = "Legplates of Unholy Frenzy", sources = { [14]=111464 } },
                { id = 178740, slot = "Shoulder", name = "Reanimator's Mantle", sources = { [14]=111465 } },
                { id = 178737, slot = "Weapon", name = "Amarth's Spellblade", sources = { [14]=111462 } },
                { id = 178741, slot = "Wrist", name = "Risen Monstrosity Cuffs", sources = { [14]=111466 } },
            },
        },
        {
            index              = 3,
            name               = "Surgeon Stitchflesh",
            journalEncounterID = 2392,
            achievements       = {
                { id = 14320, name = "Surgeon's Supplies", meta = true },
            },
            loot = {
                { id = 178744, slot = "Chest", name = "Freshly Embalmed Jerkin", sources = { [14]=111468 } },
                { id = 178745, slot = "Feet", name = "Striders of Restless Malice", sources = { [14]=111469 } },
                { id = 178748, slot = "Hands", name = "Gory Surgeon's Gloves", sources = { [14]=111471 } },
                { id = 178750, slot = "Off-hand", name = "Encrusted Canopic Lid", sources = { [14]=111473 } },
                { id = 178749, slot = "Shoulder", name = "Vile Butcher's Pauldrons", sources = { [14]=111472 } },
                { id = 178743, slot = "Weapon", name = "Stitchflesh's Scalpel", sources = { [14]=111467 } },
            },
        },
        {
            index              = 4,
            name               = "Nalthor the Rimebinder",
            journalEncounterID = 2396,
            achievements       = {
                { id = 14285, name = "Ready for Raiding VII", meta = true },
                { id = 14366, name = "The Necrotic Wake" },
                { id = 14367, name = "Heroic: The Necrotic Wake" },
                { id = 14368, name = "Mythic: The Necrotic Wake" },
            },
            loot = {
                { id = 178777, slot = "Head", name = "Darkfrost Helmet", sources = { [14]=111494 } },
                { id = 178778, slot = "Legs", name = "Lichbone Legguards", sources = { [14]=111495 } },
                { id = 178779, slot = "Shoulder", name = "Undying Chill Shoulderpads", sources = { [14]=111496 } },
                { id = 178780, slot = "Two-Hand", name = "Rimebinder's Runeblade", sources = { [14]=111497 } },
                { id = 178782, slot = "Wrist", name = "Necropolis Lord's Shackles", sources = { [14]=111498 } },
            },
            specialLoot = {
                { id = 181819, kind = "mount", name = "Marrowfang's Reins" },
            },
        },
    },
}
