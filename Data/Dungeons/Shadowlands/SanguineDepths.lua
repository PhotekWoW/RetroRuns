-------------------------------------------------------------------------------
-- RetroRuns Data -- Sanguine Depths
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Shadowlands dungeon, Patch 9.0.1  |  instanceID: 2284  |  journalInstanceID: 1189
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1189] = {
    kind              = "dungeon",
    instanceID        = 2284,
    journalInstanceID = 1189,
    name              = "Sanguine Depths",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15, 16 },
    patch             = "9.0.1",
    timewalking       = true,

    entrance = {
        mapID = 1525,
        x     = 0.5106,
        y     = 0.3047,
    },

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
            name               = "Kryxis the Voracious",
            journalEncounterID = 2388,
            dungeonEncounterID = 2360,
            achievements       = {
            },
            loot = {
                { id = 178835, slot = "Chest", name = "Anima-Splattered Hide", sources = { [14]=111535, [15]=111535, [16]=111535 } },
                { id = 178836, slot = "Feet", name = "Sabatons of the Rushing Juggernaut", sources = { [14]=111536, [15]=111536, [16]=111536 } },
                { id = 178854, slot = "Weapon", name = "Hungering Devourer's Twinblade", sources = { [14]=111551, [15]=111551, [16]=111551 } },
                { id = 178853, slot = "Weapon", name = "Voracious Gorger Spine", sources = { [14]=111550, [15]=111550, [16]=111550 } },
                { id = 178844, slot = "Wrist", name = "Essence Surge Binders", sources = { [14]=111544, [15]=111544, [16]=111544 } },
                { id = 178846, slot = "Wrist", name = "Shackles of Alluring Vitality", sources = { [14]=111546, [15]=111546, [16]=111546 } },
            },
        },
        {
            index              = 2,
            name               = "Executor Tarvold",
            journalEncounterID = 2415,
            dungeonEncounterID = 2361,
            achievements       = {
                { id = 14286, name = "Residue Evil", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 178851, slot = "Back", name = "Cloak of Enveloping Manifestations", sources = { [14]=111548, [15]=111548, [16]=111548 } },
                { id = 178837, slot = "Feet", name = "Sinsoaked Waders", sources = { [14]=111537, [15]=111537, [16]=111537 } },
                { id = 178859, slot = "Shoulder", name = "Castigator's Mantle", sources = { [14]=111556, [15]=111556, [16]=111556 } },
                { id = 178843, slot = "Waist", name = "Executor's Prideful Girdle", sources = { [14]=111543, [15]=111543, [16]=111543 } },
                { id = 178855, slot = "Weapon", name = "Sinsmasher", sources = { [14]=111552, [15]=111552, [16]=111552 } },
                { id = 178845, slot = "Wrist", name = "Vambraces of the Depraved Warden", sources = { [14]=111545, [15]=111545, [16]=111545 } },
            },
        },
        {
            index              = 3,
            name               = "Grand Proctor Beryllia",
            journalEncounterID = 2421,
            dungeonEncounterID = 2362,
            achievements       = {
            },
            loot = {
                { id = 178841, slot = "Hands", name = "Iron Spiked Handgrips", sources = { [14]=111541, [15]=111541, [16]=111541 } },
                { id = 178838, slot = "Legs", name = "Beryllia's Leggings of Endless Torment", sources = { [14]=111538, [15]=111538, [16]=111538 } },
                { id = 178852, slot = "Off-hand", name = "Vessel of Shining Radiance", sources = { [14]=111549, [15]=111549, [16]=111549 } },
                { id = 178842, slot = "Waist", name = "Waistguard of Expurged Anguish", sources = { [14]=111542, [15]=111542, [16]=111542 } },
                { id = 178847, slot = "Wrist", name = "Radiant Light Binders", sources = { [14]=111547, [15]=111547, [16]=111547 } },
            },
            specialLoot = {
                { id = 180591, kind = "pet", name = "Vial of Roiling Emotions", mythicOnly = true },
            },
        },
        {
            index              = 4,
            name               = "General Kaal",
            journalEncounterID = 2407,
            dungeonEncounterID = 2363,
            achievements       = {
                { id = 14289, name = "Kaal-ed Shot", meta = true, soloable = "kinda" },
                { id = 14290, name = "I Only Have Eyes For You", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 178840, slot = "Hands", name = "Guilewind Stone Talons", sources = { [14]=111540, [15]=111540, [16]=111540 } },
                { id = 178860, slot = "Head", name = "Cowl of the Devoted General", sources = { [14]=111557, [15]=111557, [16]=111557 } },
                { id = 178839, slot = "Legs", name = "Wind Dancer's Legguards", sources = { [14]=111539, [15]=111539, [16]=111539 } },
                { id = 178858, slot = "Shoulder", name = "Wicked Bladewing Pauldrons", sources = { [14]=111555, [15]=111555, [16]=111555 } },
                { id = 178856, slot = "Weapon", name = "Kaal's Gloomblade", sources = { [14]=111553, [15]=111553, [16]=111553 } },
                { id = 178857, slot = "Weapon", name = "Stone General's Edge", sources = { [14]=111554, [15]=111554, [16]=111554 } },
            },
        },
    },
}
