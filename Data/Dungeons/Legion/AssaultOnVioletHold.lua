-------------------------------------------------------------------------------
-- RetroRuns Data -- Assault on Violet Hold
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Legion dungeon, Patch 7.0.3  |  instanceID: 1544  |  journalInstanceID: 777
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[777] = {
    kind              = "dungeon",
    instanceID        = 1544,
    journalInstanceID = 777,
    name              = "Assault on Violet Hold",
    expansion         = "Legion",
    difficultyModel   = "dungeonTiered",
    availableDifficulties = { 14, 15, 16 },
    patch             = "7.0.3",
    routedIn          = "3.5.1",

    -- Two of the six prisoners a run, one per stage objective. Lord Malgath
    -- names each one as its cell opens.
    bossPool = {
        slotLabel = "Escaped Prisoner",
        slots     = { 24858, 24859 },
        members   = { 1, 2, 3, 4, 5, 6 },
        announce  = {
            { member = 1, dialog = { npc = "Lord Malgath", match = "wretched Abomination" } },
            { member = 2, dialog = { npc = "Lord Malgath", match = "Shivermaw" } },
            { member = 3, dialog = { { npc = "Lord Malgath", match = "Thal'ena" },
                                     { npc = "Lord Malgath", match = "San'layn" } } },
            { member = 4, dialog = { npc = "Lord Malgath", match = "Faceless One" } },
            { member = 5, dialog = { { npc = "Lord Malgath", match = "darkest nightmares" },
                                     { npc = "Lord Malgath", match = "bitterness in this gnome" } } },
            { member = 6, dialog = { { npc = "Lord Malgath", match = "Crypt lords" },
                                     { npc = "Lord Malgath", match = "Anub'esset" } } },
        },
    },

    -- Sael'orn or Fel Lord Betrug, one a run, out when Lord Malgath dies.
    -- The label heads the panel until then. Betrug names himself 7 s after
    -- Malgath's death line and Sael'orn never does, so silence means her.
    spawnChoice = {
        7, 8, label = "Final Boss",
        byElimination = {
            member  = 7,
            seconds = 8,
            dialog  = {
                { npc = "Lord Malgath", match = "sooner or later" },
                { npc = "Lord Malgath", match = "I will not see the world" },
            },
        },
    },

    entrance = {
        mapID = 627,
        x     = 0.6795,
        y     = 0.7046,
    },

    gloryMeta = {
        id   = 11163,
        name = "Glory of the Legion Hero",
        rewardItemID       = 141217,
        rewardMountSpellID = 225765,
        rewardName         = "Leyfeather Hippogryph",
    },

    bosses = {
        {
            index              = 1,
            name               = "Festerface",
            journalEncounterID = 1693,
            dungeonEncounterID = 1848,
            achievements       = {
                { id = 10554, name = "I Made a Food!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 134414, slot = "Chest", name = "Fetid Gutcover Apron", sources = { [14]=79021, [15]=80003, [16]=79021 } },
                { id = 137437, slot = "Chest", name = "Slimeflow Breastplate", sources = { [14]=79027, [15]=79981, [16]=79027 } },
                { id = 134468, slot = "Hands", name = "Gloves of Flesh-Shaping", sources = { [14]=79025, [15]=80128, [16]=79025 } },
                { id = 137479, slot = "Head", name = "Cowl of Promising News", sources = { [14]=79061, [15]=80164, [16]=79061 } },
                { id = 134454, slot = "Shoulder", name = "Spaulders of Unstable Experiments", sources = { [14]=79023, [15]=80079, [16]=79023 } },
                { id = 137435, slot = "Waist", name = "Blightbile Waistband", sources = { [14]=79024, [15]=80100, [16]=79024 } },
                { id = 137436, slot = "Waist", name = "Pustulous Girdle", sources = { [14]=79026, [15]=79980, [16]=79026 } },
                { id = 137434, slot = "Wrist", name = "Split-Vein Bracers", sources = { [14]=79022, [15]=80040, [16]=79022 } },
            },
        },
        {
            index              = 2,
            name               = "Shivermaw",
            journalEncounterID = 1694,
            dungeonEncounterID = 1845,
            achievements       = {
            },
            loot = {
                { id = 134411, slot = "Back", name = "Iceblood Shroud", sources = { [14]=79020, [15]=80814, [16]=79020 } },
                { id = 134523, slot = "Feet", name = "Etched Dragonbone Warboots", sources = { [14]=79030, [15]=79965, [16]=79030 } },
                { id = 134445, slot = "Hands", name = "Frostcarver Grips", sources = { [14]=79028, [15]=80070, [16]=79028 } },
                { id = 134476, slot = "Legs", name = "Wyrmwing Kilt", sources = { [14]=79029, [15]=80136, [16]=79029 } },
                { id = 134434, slot = "Waist", name = "Cinch of Freezing Fog", sources = { [14]=79007, [15]=80022, [16]=79007 } },
            },
        },
        {
            index              = 3,
            name               = "Blood-Princess Thal'ena",
            journalEncounterID = 1702,
            dungeonEncounterID = 1855,
            achievements       = {
            },
            loot = {
                { id = 134404, slot = "Back", name = "Stole of Malefic Repose", sources = { [14]=79060, [15]=80808, [16]=79060 } },
                { id = 137460, slot = "Chest", name = "Constricting Chain Harness", sources = { [14]=79058, [15]=80163, [16]=79058 } },
                { id = 134422, slot = "Hands", name = "Satin Throatclutchers", sources = { [14]=79056, [15]=80011, [16]=79056 } },
                { id = 134516, slot = "Legs", name = "Tassets of Ravenous Euphoria", sources = { [14]=79074, [15]=79958, [16]=79074 } },
                { id = 134457, slot = "Waist", name = "Sash of the Twilight Princess", sources = { [14]=79057, [15]=80082, [16]=79057 } },
            },
        },
        {
            index              = 4,
            name               = "Mindflayer Kaahrj",
            journalEncounterID = 1686,
            dungeonEncounterID = 1846,
            achievements       = {
            },
            loot = {
                { id = 134439, slot = "Chest", name = "Tunic of the Underworld", sources = { [14]=79017, [15]=80064, [16]=79017 } },
                { id = 134425, slot = "Head", name = "Hood of Ancient Evil", sources = { [14]=79016, [15]=80014, [16]=79016 } },
                { id = 134479, slot = "Shoulder", name = "Mantle of the Abyss", sources = { [14]=79018, [15]=80139, [16]=79018 } },
                { id = 137431, slot = "Wrist", name = "Despair-Bound Armplates", sources = { [14]=79019, [15]=79979, [16]=79019 } },
            },
        },
        {
            index              = 5,
            name               = "Millificent Manastorm",
            journalEncounterID = 1688,
            dungeonEncounterID = 1847,
            achievements       = {
                { id = 10553, name = "You're Just Making It WORSE!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 137444, slot = "Feet", name = "Plasma-Drilled Steel Toes", sources = { [14]=79036, [15]=80160, [16]=79036 } },
                { id = 137445, slot = "Head", name = "Insurmountable Skullfortress", sources = { [14]=79038, [15]=79982, [16]=79038 } },
                { id = 137441, slot = "Head", name = "Millificent's Turboview Specs", sources = { [14]=79032, [15]=80041, [16]=79032 } },
                { id = 137443, slot = "Head", name = "Mithril Melon Vault", sources = { [14]=79035, [15]=80159, [16]=79035 } },
                { id = 134450, slot = "Legs", name = "D-Lux Slipstream Pants", sources = { [14]=79033, [15]=80075, [16]=79033 } },
                { id = 134430, slot = "Shoulder", name = "Magnificent Aeroglide Shoulderpads", sources = { [14]=79031, [15]=80018, [16]=79031 } },
                { id = 137442, slot = "Wrist", name = "Compact Trifold Wristbands", sources = { [14]=79034, [15]=80101, [16]=79034 } },
                { id = 134502, slot = "Wrist", name = "Exo-Mesh Carpalform Armplates Mk. VII", sources = { [14]=79037, [15]=79944, [16]=79037 } },
            },
        },
        {
            index              = 6,
            name               = "Anub'esset",
            journalEncounterID = 1696,
            dungeonEncounterID = 1852,
            achievements       = {
            },
            loot = {
                { id = 137428, slot = "Chest", name = "Chestguard of Ravaged Chitin", sources = { [14]=79012, [15]=80158, [16]=79012 } },
                { id = 134418, slot = "Hands", name = "Scarab-Caller Grips", sources = { [14]=79015, [15]=80007, [16]=79015 } },
                { id = 137429, slot = "Hands", name = "Serrated Mandible Grips", sources = { [14]=79014, [15]=79978, [16]=79014 } },
                { id = 137427, slot = "Head", name = "Corpse Feast Headwrap", sources = { [14]=79010, [15]=80099, [16]=79010 } },
                { id = 137424, slot = "Legs", name = "Burrow-Dweller Leggings", sources = { [14]=79008, [15]=80039, [16]=79008 } },
                { id = 134506, slot = "Legs", name = "Legplates of the Swarm", sources = { [14]=79013, [15]=79948, [16]=79013 } },
                { id = 137425, slot = "Wrist", name = "Cryptwalker Bracers", sources = { [14]=79009, [15]=80098, [16]=79009 } },
                { id = 134485, slot = "Wrist", name = "Cuffs of the Nerubian Empire", sources = { [14]=79011, [15]=80145, [16]=79011 } },
            },
        },
        {
            index              = 7,
            name               = "Sael'orn",
            journalEncounterID = 1697,
            dungeonEncounterID = 1851,
            achievements       = {
            },
            loot = {
                { id = 134390, slot = "Chest", name = "Mardum Chain Vest", sources = { [14]=77644, [15]=77644, [16]=77644 } },
                { id = 137449, slot = "Chest", name = "Wicked Broodmother's Chestguard", sources = { [14]=79042, [15]=80103, [16]=79042 } },
                { id = 137448, slot = "Feet", name = "Toxin-Stitched Footwraps", sources = { [14]=79041, [15]=80102, [16]=79041 } },
                { id = 134371, slot = "Hands", name = "Felbat Leather Gloves", sources = { [14]=77632, [15]=77632, [16]=77632 } },
                { id = 134393, slot = "Hands", name = "Netherwhisper Gloves", sources = { [14]=77647, [15]=77647, [16]=77647 } },
                { id = 137451, slot = "Head", name = "Vision of the Spider Queen", sources = { [14]=79046, [15]=79983, [16]=79046 } },
                { id = 137450, slot = "Legs", name = "Leggings of Acidic Venom", sources = { [14]=79044, [15]=80161, [16]=79044 } },
                { id = 134521, slot = "Shoulder", name = "Dread-Stricken Shoulderguards", sources = { [14]=79045, [15]=79963, [16]=79045 } },
                { id = 137447, slot = "Shoulder", name = "Lair Matron's Spaulders", sources = { [14]=79040, [15]=80042, [16]=79040 } },
                { id = 134482, slot = "Waist", name = "Cinch of Frozen Fear", sources = { [14]=79043, [15]=80142, [16]=79043 } },
                { id = 134357, slot = "Waist", name = "Portalguard Waistplate", sources = { [14]=77621, [15]=77621, [16]=77621 } },
                { id = 134436, slot = "Wrist", name = "Armbands of Slaughter", sources = { [14]=79039, [15]=80024, [16]=79039 } },
            },
        },
        {
            index              = 8,
            name               = "Fel Lord Betrug",
            journalEncounterID = 1711,
            dungeonEncounterID = 1856,
            achievements       = {
            },
            loot = {
                { id = 134407, slot = "Back", name = "Rugged Marauder Cape", sources = { [14]=79047, [15]=80811, [16]=79047 } },
                { id = 137457, slot = "Chest", name = "Chestplate of the Obstinate Conqueror", sources = { [14]=79055, [15]=79984, [16]=79055 } },
                { id = 134395, slot = "Chest", name = "Netherwhisper Robes", sources = { [14]=77649, [15]=77649, [16]=77649 } },
                { id = 134466, slot = "Feet", name = "Begrudging Trudgers", sources = { [14]=79052, [15]=80126, [16]=79052 } },
                { id = 137454, slot = "Feet", name = "Footguards of Stayed Execution", sources = { [14]=79049, [15]=80044, [16]=79049 } },
                { id = 134446, slot = "Head", name = "Vigilant Bondbreaker Headdress", sources = { [14]=79050, [15]=80071, [16]=79050 } },
                { id = 134515, slot = "Legs", name = "Greaves of Ruinous Dominion", sources = { [14]=79054, [15]=79957, [16]=79054 } },
                { id = 137453, slot = "Legs", name = "Legwraps of Rampant Turmoil", sources = { [14]=79048, [15]=80043, [16]=79048 } },
                { id = 134389, slot = "Shoulder", name = "Mardum Chain Pauldrons", sources = { [14]=77643, [15]=77643, [16]=77643 } },
                { id = 134360, slot = "Shoulder", name = "Portalguard Shoulders", sources = { [14]=77624, [15]=77624, [16]=77624 } },
                { id = 137455, slot = "Shoulder", name = "Spaulders of Tense Sinew", sources = { [14]=79051, [15]=80104, [16]=79051 } },
                { id = 137456, slot = "Waist", name = "Belt of Mighty Links", sources = { [14]=79053, [15]=80162, [16]=79053 } },
                { id = 134368, slot = "Wrist", name = "Felbat Leather Wristwraps", sources = { [14]=77629, [15]=77629, [16]=77629 } },
            },
        },
    },

    exitNote    = "None available",
    minExitNote = "None available",

    routing = {
        -- 1. Sael'orn or Fel Lord Betrug (bosses 7-8). One step for the
        -- whole event, from Sinclari to the final boss.
        {
            step      = 1,
            priority  = 1,
            bossIndex = { 7, 8 },
            title     = "Final Boss",
            requires  = { },
            segments  = {
                {
                    when            = { mapID = 732 },
                    kind            = "poi",
                    poiKind         = "talk",
                    note            = "After zoning in, talk to ^Lieutenant Sinclari^ to begin the instance.",
                    minNote         = "Talk to Sinclari to begin",
                    mapLabel        = "Talk to Sinclari",
                    completionCheck = true,
                    points          = {
                        { 0.529, 0.721 },
                    },
                },
                {
                    -- Sinclari locks the door once the event is running.
                    when        = { mapID = 732 },
                    kind        = "path",
                    note        = "Clear portals until the Invasion Forces bar fills to spawn the first ^Escaped Prisoner^ at random.",
                    minNote     = "Clear portals for boss",
                    triggeredBy = { dialog = { npc = "Lieutenant Sinclari", match = "locking the door" } },
                    points      = { },
                },
                {
                    when        = { mapID = 732 },
                    kind        = "path",
                    note        = "Clear portals until the Invasion Forces bar fills again to spawn the second ^Escaped Prisoner^ at random.",
                    minNote     = "Clear portals for boss",
                    triggeredBy = { scenario = 24858 },
                    points      = { },
                },
                {
                    when        = { mapID = 732 },
                    kind        = "path",
                    note        = "Clear portals until ^Lord Malgath^ lands, then kill him to spawn the final boss.",
                    minNote     = "Clear portals, kill Malgath",
                    triggeredBy = { scenario = 24859 },
                    points      = { },
                },
                {
                    -- Either of Malgath's death lines.
                    when        = { mapID = 732 },
                    kind        = "path",
                    note        = "Kill the final boss, ^Sael'orn^ or ^Fel Lord Betrug^, to complete the instance.",
                    minNote     = "Kill the final boss",
                    triggeredBy = { dialog = {
                        { npc = "Lord Malgath", match = "sooner or later" },
                        { npc = "Lord Malgath", match = "I will not see the world" },
                    } },
                    points      = { },
                },
            },
        },
    },
}
