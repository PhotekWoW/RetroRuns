-------------------------------------------------------------------------------
-- RetroRuns Data -- Waycrest Manor
-- Battle for Azeroth dungeon, Patch 8.0.1  |  instanceID: 1862  |  journalInstanceID: 1021
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1021] = {
    kind              = "dungeon",
    instanceID        = 1862,
    journalInstanceID = 1021,
    name              = "Waycrest Manor",
    expansion         = "Battle for Azeroth",
    difficultyModel   = "dungeonTiered",
    patch             = "8.0.1",

    gloryMeta = {
        id   = 12812,
        name = "Glory of the Wartorn Hero",
        rewardItemID       = 161215,
        rewardName         = "Reins of the Obsidian Krolusk",
    },

    bosses = {
        {
            index              = 1,
            name               = "Heartsbane Triad",
            journalEncounterID = 2125,
            achievements       = {
            },
            loot = {
                { id = 159404, slot = "Feet", name = "Bramble Looped Boots", sources = { [14]=95192, [15]=95193, [16]=95887 } },
                { id = 159272, slot = "Hands", name = "Twisted Sisters Handwraps", sources = { [14]=95021, [15]=95781, [16]=95782 } },
                { id = 159345, slot = "Legs", name = "Blight Toadskin Leggings", sources = { [14]=95116, [15]=98488, [16]=98489 } },
                { id = 159400, slot = "Legs", name = "Nettle-Scarred Greaves", sources = { [14]=95188, [15]=95881, [16]=95882 } },
                { id = 159669, slot = "Off-hand", name = "Solena's Watchful Collection", sources = { [14]=96084, [15]=96310, [16]=96311 } },
                { id = 159450, slot = "Waist", name = "Girdle of Burgeoning Apathy", sources = { [14]=95261, [15]=95262, [16]=95695 } },
                { id = 159133, slot = "Weapon", name = "Jagged Iris Sica", sources = { [14]=94879, [15]=95476, [16]=95477 } },
                { id = 159340, slot = "Wrist", name = "Bracers of Dreadful Maladies", sources = { [14]=95109, [15]=95110, [16]=98480 } },
                { id = 159449, slot = "Wrist", name = "Soulwarped Vambraces", sources = { [14]=95259, [15]=95260, [16]=95694 } },
            },
        },
        {
            index              = 2,
            name               = "Soulbound Goliath",
            journalEncounterID = 2126,
            achievements       = {
                { id = 12495, name = "Run Wild Like a Man On Fire", meta = true },
            },
            loot = {
                { id = 159399, slot = "Hands", name = "Thornshaper Mitts", sources = { [14]=95187, [15]=95879, [16]=95880 } },
                { id = 159456, slot = "Legs", name = "Petrified Wickerplate Greaves", sources = { [14]=95269, [15]=95270, [16]=95705 } },
                { id = 159341, slot = "Waist", name = "Hound-Jowl Waistband", sources = { [14]=95111, [15]=95112, [16]=98481 } },
                { id = 159659, slot = "Weapon", name = "Sinister Wicker Talons", sources = { [14]=96086, [15]=96492, [16]=96493 } },
                { id = 159282, slot = "Wrist", name = "Drust-Thatched Wristwraps", sources = { [14]=95034, [15]=95794, [16]=95795 } },
            },
        },
        {
            index              = 3,
            name               = "Raal the Gluttonous",
            journalEncounterID = 2127,
            achievements       = {
            },
            loot = {
                { id = 159294, slot = "Back", name = "Raal's Bib", sources = { [14]=95047, [15]=97053, [16]=97054 } },
                { id = 159452, slot = "Feet", name = "Fatty Hooves of Gory Comfort", sources = { [14]=95265, [15]=95697, [16]=95698 } },
                { id = 159346, slot = "Hands", name = "Grubby Servant-Grabbers", sources = { [14]=95117, [15]=98490, [16]=98491 } },
                { id = 159285, slot = "Legs", name = "Bloodstained Sous Chef Pants", sources = { [14]=95037, [15]=95038, [16]=95796 } },
                { id = 159660, slot = "Weapon", name = "Servant Splitter", sources = { [14]=95447, [15]=95447, [16]=95447 } },
                { id = 159397, slot = "Wrist", name = "Slaughterhouse-Chain Bracers", sources = { [14]=95184, [15]=95185, [16]=95876 } },
            },
        },
        {
            index              = 4,
            name               = "Lord and Lady Waycrest",
            journalEncounterID = 2128,
            achievements       = {
            },
            loot = {
                { id = 159347, slot = "Feet", name = "Moss-Covered Wingtip Shoes", sources = { [14]=95118, [15]=98492, [16]=98493 } },
                { id = 159457, slot = "Hands", name = "Risen Lord's Oversized Gauntlets", sources = { [14]=95271, [15]=95706, [16]=95707 } },
                { id = 159262, slot = "Waist", name = "Belt of Undying Devotion", sources = { [14]=95008, [15]=95712, [16]=95713 } },
                { id = 159403, slot = "Waist", name = "Waistguard of Deteriorating Grace", sources = { [14]=95191, [15]=95885, [16]=95886 } },
                { id = 159661, slot = "Weapon", name = "Soulcharmer's Bludgeon", sources = { [14]=95448, [15]=95488, [16]=95489 } },
            },
        },
        {
            index              = 5,
            name               = "Gorak Tul",
            journalEncounterID = 2129,
            achievements       = {
                { id = 12483, name = "Waycrest Manor" },
                { id = 12484, name = "Heroic: Waycrest Manor" },
                { id = 12488, name = "Mythic: Waycrest Manor" },
                { id = 12490, name = "Alchemical Romance", meta = true },
                { id = 12489, name = "Losing My Profession", meta = true },
            },
            loot = {
                { id = 159448, slot = "Chest", name = "Breastplate of the Vengeful", sources = { [14]=95257, [15]=95258, [16]=95693 } },
                { id = 159395, slot = "Chest", name = "Deathslaver's Hauberk", sources = { [14]=95180, [15]=95181, [16]=95875 } },
                { id = 159335, slot = "Chest", name = "Raiment of the Blighted Tribe", sources = { [14]=95103, [15]=98477, [16]=98478 } },
                { id = 159279, slot = "Head", name = "Soulfuel Headdress", sources = { [14]=95031, [15]=95790, [16]=95791 } },
                { id = 159398, slot = "Head", name = "Soulscarred Headgear", sources = { [14]=95186, [15]=95877, [16]=95878 } },
                { id = 159273, slot = "Shoulder", name = "Amice of the Returned", sources = { [14]=95022, [15]=95783, [16]=95784 } },
                { id = 159339, slot = "Shoulder", name = "Gorak Tul's Mantle", sources = { [14]=95107, [15]=95108, [16]=98479 } },
                { id = 159455, slot = "Shoulder", name = "Pauldrons of the Horned Horror", sources = { [14]=95268, [15]=95703, [16]=95704 } },
                { id = 159662, slot = "Two-Hand", name = "Blightreaper", sources = { [14]=95449, [15]=96494, [16]=96495 } },
            },
        },
    },
}
