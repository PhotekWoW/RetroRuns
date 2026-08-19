-------------------------------------------------------------------------------
-- RetroRuns Data -- Assault on Violet Hold
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
    patch             = "7.0.3",

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
            achievements       = {
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
            achievements       = {
                { id = 10553, name = "You're Just Making It WORSE!", meta = true },
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
            achievements       = {
                { id = 10798, name = "Assault on Violet Hold" },
                { id = 10799, name = "Heroic: Assault on Violet Hold" },
                { id = 10800, name = "Mythic: Assault on Violet Hold" },
                { id = 60846, name = "Assault on Violet Hold" },
                { id = 60847, name = "Heroic: Assault on Violet Hold" },
                { id = 60848, name = "Mythic: Assault on Violet Hold" },
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
}
