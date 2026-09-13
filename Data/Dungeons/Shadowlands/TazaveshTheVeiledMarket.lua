-------------------------------------------------------------------------------
-- RetroRuns Data -- Tazavesh, the Veiled Market
-- Shadowlands dungeon, Patch 9.1.0  |  instanceID: 2441  |  journalInstanceID: 1194
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[1194] = {
    kind              = "dungeon",
    instanceID        = 2441,
    journalInstanceID = 1194,
    name              = "Tazavesh, the Veiled Market",
    expansion         = "Shadowlands",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 15, 16 },
    patch             = "9.1.0",

    entrance = {
        mapID = 2472,
        x     = 0.3630,
        y     = 0.1220,
    },

    bosses = {
        {
            index              = 1,
            name               = "Zo'phex the Sentinel",
            journalEncounterID = 2437,
            scenarioCriteriaID = 52836,
            achievements       = {
                { id = 15109, name = "Will it Blend?", soloable = "no" },
            },
            loot = {
                { id = 185793, slot = "Hands", name = "Cyphered Gloves", sources = { [15]=116673, [16]=116673 } },
                { id = 185791, slot = "Hands", name = "Knuckle-Dusting Handwraps", sources = { [15]=116671, [16]=116671 } },
                { id = 185824, slot = "Weapon", name = "Blade of Grievous Harm", sources = { [15]=116701, [16]=116701 } },
                { id = 185780, slot = "Weapon", name = "Interrogator's Flensing Blade", sources = { [15]=116660, [16]=116660 } },
                { id = 185816, slot = "Wrist", name = "Confiscated Bracers of Concealment", sources = { [15]=116695, [16]=116695 } },
                { id = 185815, slot = "Wrist", name = "Vambraces of Verification", sources = { [15]=116694, [16]=116694 } },
            },
        },
        {
            index              = 2,
            name               = "The Grand Menagerie",
            journalEncounterID = 2454,
            scenarioCriteriaID = 52839,
            achievements       = {
            },
            loot = {
                { id = 185792, slot = "Hands", name = "Achillite's Unbreakable Grip", sources = { [15]=116672, [16]=116672 } },
                { id = 185794, slot = "Hands", name = "Gavel Pounders", sources = { [15]=116674, [16]=116674 } },
                { id = 246282, slot = "Hands", name = "Order Bashers", sources = { [15]=293028, [16]=293028 } },
                { id = 185809, slot = "Waist", name = "Venza's Powderbelt", sources = { [15]=116689, [16]=116689 } },
                { id = 185777, slot = "Weapon", name = "Fang of Alcruux", sources = { [15]=116657, [16]=116657 } },
                { id = 185821, slot = "Weapon", name = "Gluttonous Rondel", sources = { [15]=116698, [16]=116698 } },
                { id = 185814, slot = "Wrist", name = "Auctioneer's Counting Bracers", sources = { [15]=116693, [16]=116693 } },
            },
        },
        {
            index              = 3,
            name               = "Mailroom Mayhem",
            journalEncounterID = 2436,
            scenarioCriteriaID = 52838,
            achievements       = {
            },
            loot = {
                { id = 185787, slot = "Feet", name = "Implacable Weatherproof Treads", sources = { [15]=116667, [16]=116667 } },
                { id = 185811, slot = "Off-hand", name = "Package Protector", sources = { [15]=116691, [16]=116691 } },
                { id = 185808, slot = "Waist", name = "Discount Mail-Order Belt", sources = { [15]=116688, [16]=116688 } },
                { id = 185807, slot = "Waist", name = "Pan-Dimensional Packing Cord", sources = { [15]=116687, [16]=116687 } },
                { id = 185817, slot = "Wrist", name = "Bracers of Autonomous Classification", sources = { [15]=116696, [16]=116696 } },
            },
            specialLoot = {
                { id = 186534, kind = "pet", name = "Gizmo" },
            },
        },
        {
            index              = 4,
            name               = "Myza's Oasis",
            journalEncounterID = 2452,
            scenarioCriteriaID = 52837,
            achievements       = {
            },
            loot = {
                { id = 185789, slot = "Feet", name = "Sabatons of Measured Time", sources = { [15]=116669, [16]=116669 } },
                { id = 185812, slot = "Off-hand", name = "Acoustically Alluring Censer", sources = { [15]=116692, [16]=116692 } },
                { id = 185783, slot = "Ranged", name = "Yasahm the Riftbreaker", sources = { [15]=116663, [16]=116663 } },
                { id = 185802, slot = "Shoulder", name = "Breakbeat Shoulderguards", sources = { [15]=116682, [16]=116682 } },
                { id = 185804, slot = "Shoulder", name = "Harmonious Spaulders", sources = { [15]=116684, [16]=116684 } },
                { id = 185806, slot = "Waist", name = "Improvisational Cinch", sources = { [15]=116686, [16]=116686 } },
                { id = 246287, slot = "Waist", name = "Improvisational Girdle", sources = { [15]=293033, [16]=293033 } },
            },
        },
        {
            index              = 5,
            name               = "So'azmi",
            journalEncounterID = 2451,
            achievements       = {
            },
            loot = {
                { id = 185843, slot = "Back", name = "Duplicating Drape", sources = { [15]=116706, [16]=116706 } },
                { id = 185782, slot = "Chest", name = "Robes of Midnight Bargains", sources = { [15]=116662, [16]=116662 } },
                { id = 185786, slot = "Chest", name = "So'azmi's Fractal Vest", sources = { [15]=116666, [16]=116666 } },
                { id = 246285, slot = "Legs", name = "Fluxphase Culottes", sources = { [15]=293031, [16]=293031 } },
                { id = 185800, slot = "Legs", name = "Orbitwarp Culottes", sources = { [15]=116680, [16]=116680 } },
                { id = 185798, slot = "Legs", name = "Quantum Leapers", sources = { [15]=116678, [16]=116678 } },
                { id = 185778, slot = "Weapon", name = "First Fist of the So Cartel", sources = { [15]=116658, [16]=116658 } },
            },
        },
        {
            index              = 6,
            name               = "Hylbrande",
            journalEncounterID = 2448,
            achievements       = {
                { id = 15179, name = "This is Fine", soloable = "yes" },
            },
            loot = {
                { id = 185781, slot = "Back", name = "Drape of Titanic Dreams", sources = { [15]=116661, [16]=116661 } },
                { id = 246280, slot = "Feet", name = "Boots of Titanic Deconversion", sources = { [15]=293027, [16]=293027 } },
                { id = 185788, slot = "Feet", name = "Codebreaker's Cunning Sandals", sources = { [15]=116668, [16]=116668 } },
                { id = 185790, slot = "Feet", name = "Treads of Titanic Deconversion", sources = { [15]=116670, [16]=116670 } },
                { id = 246275, slot = "Hands", name = "Codebreaker's Cunning Handwraps", sources = { [15]=293022, [16]=293022 } },
                { id = 185805, slot = "Shoulder", name = "Hylbrande's Retrofitted Shoulderguards", sources = { [15]=116685, [16]=116685 } },
                { id = 185803, slot = "Shoulder", name = "Stoneflesh Spaulders", sources = { [15]=116683, [16]=116683 } },
                { id = 185810, slot = "Two-Hand", name = "Skyreaver, Greataxe of the Keepers", sources = { [15]=116690, [16]=116690 } },
                { id = 185779, slot = "Two-Hand", name = "Spire of Expurgation", sources = { [15]=116659, [16]=116659 } },
            },
        },
        {
            index              = 7,
            name               = "Timecap'n Hooktail",
            journalEncounterID = 2449,
            achievements       = {
            },
            loot = {
                { id = 185795, slot = "Head", name = "Cowl of Branching Fate", sources = { [15]=116675, [16]=116675 } },
                { id = 246283, slot = "Head", name = "Crown of Absolute Command", sources = { [15]=293029, [16]=293029 } },
                { id = 185796, slot = "Head", name = "Dragonbane Diadem", sources = { [15]=116676, [16]=116676 } },
                { id = 185776, slot = "Head", name = "Hooktail's Commanding Gaze", sources = { [15]=116656, [16]=116656 } },
                { id = 185797, slot = "Head", name = "Rakishly Tipped Tricorne", sources = { [15]=116677, [16]=116677 } },
                { id = 185823, slot = "Weapon", name = "Fatebreaker, Destroyer of Futures", sources = { [15]=116700, [16]=116700 } },
                { id = 185841, slot = "Weapon", name = "Timetwister Tulwar", sources = { [15]=116705, [16]=116705 } },
            },
        },
        {
            index              = 8,
            name               = "So'leah",
            journalEncounterID = 2455,
            achievements       = {
                { id = 15106, name = "Quality Control", soloable = "no" },
                { id = 15190, name = "Mischief!", soloable = "yes" },
            },
            loot = {
                { id = 185785, slot = "Chest", name = "Embrace of the Relicbinder", sources = { [15]=116665, [16]=116665 } },
                { id = 185784, slot = "Chest", name = "Novaburst Warplate", sources = { [15]=116664, [16]=116664 } },
                { id = 185801, slot = "Legs", name = "Anomalous Starlit Breeches", sources = { [15]=116681, [16]=116681 } },
                { id = 185799, slot = "Legs", name = "Hyperlight Leggings", sources = { [15]=116679, [16]=116679 } },
                { id = 185822, slot = "Two-Hand", name = "Staff of Fractured Spacetime", sources = { [15]=116699, [16]=116699 } },
                { id = 185819, slot = "Weapon", name = "Event Horizon's Edge", sources = { [15]=116697, [16]=116697 } },
            },
            specialLoot = {
                { id = 186638, kind = "mount", name = "Cartel Master's Gearglider" },
            },
        },
    },
}
