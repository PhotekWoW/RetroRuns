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
    patch             = "9.1.0",

    bosses = {
        {
            index              = 1,
            name               = "Zo'phex the Sentinel",
            journalEncounterID = 2437,
            achievements       = {
                { id = 15109, name = "Will it Blend?" },
            },
            loot = {
                { id = 185793, slot = "Hands", name = "Cyphered Gloves", sources = { [14]=116673 } },
                { id = 185791, slot = "Hands", name = "Knuckle-Dusting Handwraps", sources = { [14]=116671 } },
                { id = 185824, slot = "Weapon", name = "Blade of Grievous Harm", sources = { [14]=116701 } },
                { id = 185780, slot = "Weapon", name = "Interrogator's Flensing Blade", sources = { [14]=116660 } },
                { id = 185816, slot = "Wrist", name = "Confiscated Bracers of Concealment", sources = { [14]=116695 } },
                { id = 185815, slot = "Wrist", name = "Vambraces of Verification", sources = { [14]=116694 } },
            },
        },
        {
            index              = 2,
            name               = "The Grand Menagerie",
            journalEncounterID = 2454,
            achievements       = {
            },
            loot = {
                { id = 185792, slot = "Hands", name = "Achillite's Unbreakable Grip", sources = { [14]=116672 } },
                { id = 185794, slot = "Hands", name = "Gavel Pounders", sources = { [14]=116674 } },
                { id = 246282, slot = "Hands", name = "Order Bashers", sources = { [14]=293028 } },
                { id = 185809, slot = "Waist", name = "Venza's Powderbelt", sources = { [14]=116689 } },
                { id = 185777, slot = "Weapon", name = "Fang of Alcruux", sources = { [14]=116657 } },
                { id = 185821, slot = "Weapon", name = "Gluttonous Rondel", sources = { [14]=116698 } },
                { id = 185814, slot = "Wrist", name = "Auctioneer's Counting Bracers", sources = { [14]=116693 } },
            },
        },
        {
            index              = 3,
            name               = "Mailroom Mayhem",
            journalEncounterID = 2436,
            achievements       = {
            },
            loot = {
                { id = 185787, slot = "Feet", name = "Implacable Weatherproof Treads", sources = { [14]=116667 } },
                { id = 185811, slot = "Off-hand", name = "Package Protector", sources = { [14]=116691 } },
                { id = 185808, slot = "Waist", name = "Discount Mail-Order Belt", sources = { [14]=116688 } },
                { id = 185807, slot = "Waist", name = "Pan-Dimensional Packing Cord", sources = { [14]=116687 } },
                { id = 185817, slot = "Wrist", name = "Bracers of Autonomous Classification", sources = { [14]=116696 } },
            },
            specialLoot = {
                { id = 186534, kind = "pet", name = "Gizmo" },
            },
        },
        {
            index              = 4,
            name               = "Myza's Oasis",
            journalEncounterID = 2452,
            achievements       = {
            },
            loot = {
                { id = 185789, slot = "Feet", name = "Sabatons of Measured Time", sources = { [14]=116669 } },
                { id = 185812, slot = "Off-hand", name = "Acoustically Alluring Censer", sources = { [14]=116692 } },
                { id = 185783, slot = "Ranged", name = "Yasahm the Riftbreaker", sources = { [14]=116663 } },
                { id = 185802, slot = "Shoulder", name = "Breakbeat Shoulderguards", sources = { [14]=116682 } },
                { id = 185804, slot = "Shoulder", name = "Harmonious Spaulders", sources = { [14]=116684 } },
                { id = 185806, slot = "Waist", name = "Improvisational Cinch", sources = { [14]=116686 } },
                { id = 246287, slot = "Waist", name = "Improvisational Girdle", sources = { [14]=293033 } },
            },
        },
        {
            index              = 5,
            name               = "So'azmi",
            journalEncounterID = 2451,
            achievements       = {
                { id = 15650, name = "Mythic: Streets of Wonder" },
            },
            loot = {
                { id = 185843, slot = "Back", name = "Duplicating Drape", sources = { [14]=116706 } },
                { id = 185782, slot = "Chest", name = "Robes of Midnight Bargains", sources = { [14]=116662 } },
                { id = 185786, slot = "Chest", name = "So'azmi's Fractal Vest", sources = { [14]=116666 } },
                { id = 246285, slot = "Legs", name = "Fluxphase Culottes", sources = { [14]=293031 } },
                { id = 185800, slot = "Legs", name = "Orbitwarp Culottes", sources = { [14]=116680 } },
                { id = 185798, slot = "Legs", name = "Quantum Leapers", sources = { [14]=116678 } },
                { id = 185778, slot = "Weapon", name = "First Fist of the So Cartel", sources = { [14]=116658 } },
            },
        },
        {
            index              = 6,
            name               = "Hylbrande",
            journalEncounterID = 2448,
            achievements       = {
                { id = 15179, name = "This is Fine" },
            },
            loot = {
                { id = 185781, slot = "Back", name = "Drape of Titanic Dreams", sources = { [14]=116661 } },
                { id = 246280, slot = "Feet", name = "Boots of Titanic Deconversion", sources = { [14]=293027 } },
                { id = 185788, slot = "Feet", name = "Codebreaker's Cunning Sandals", sources = { [14]=116668 } },
                { id = 185790, slot = "Feet", name = "Treads of Titanic Deconversion", sources = { [14]=116670 } },
                { id = 246275, slot = "Hands", name = "Codebreaker's Cunning Handwraps", sources = { [14]=293022 } },
                { id = 185805, slot = "Shoulder", name = "Hylbrande's Retrofitted Shoulderguards", sources = { [14]=116685 } },
                { id = 185803, slot = "Shoulder", name = "Stoneflesh Spaulders", sources = { [14]=116683 } },
                { id = 185810, slot = "Two-Hand", name = "Skyreaver, Greataxe of the Keepers", sources = { [14]=116690 } },
                { id = 185779, slot = "Two-Hand", name = "Spire of Expurgation", sources = { [14]=116659 } },
            },
        },
        {
            index              = 7,
            name               = "Timecap'n Hooktail",
            journalEncounterID = 2449,
            achievements       = {
            },
            loot = {
                { id = 185795, slot = "Head", name = "Cowl of Branching Fate", sources = { [14]=116675 } },
                { id = 246283, slot = "Head", name = "Crown of Absolute Command", sources = { [14]=293029 } },
                { id = 185796, slot = "Head", name = "Dragonbane Diadem", sources = { [14]=116676 } },
                { id = 185776, slot = "Head", name = "Hooktail's Commanding Gaze", sources = { [14]=116656 } },
                { id = 185797, slot = "Head", name = "Rakishly Tipped Tricorne", sources = { [14]=116677 } },
                { id = 185823, slot = "Weapon", name = "Fatebreaker, Destroyer of Futures", sources = { [14]=116700 } },
                { id = 185841, slot = "Weapon", name = "Timetwister Tulwar", sources = { [14]=116705 } },
            },
        },
        {
            index              = 8,
            name               = "So'leah",
            journalEncounterID = 2455,
            achievements       = {
                { id = 15177, name = "Tazavesh, the Veiled Market" },
                { id = 15652, name = "Mythic: So'leah's Gambit" },
                { id = 15106, name = "Quality Control" },
                { id = 15190, name = "Mischief!" },
            },
            loot = {
                { id = 185785, slot = "Chest", name = "Embrace of the Relicbinder", sources = { [14]=116665 } },
                { id = 185784, slot = "Chest", name = "Novaburst Warplate", sources = { [14]=116664 } },
                { id = 185801, slot = "Legs", name = "Anomalous Starlit Breeches", sources = { [14]=116681 } },
                { id = 185799, slot = "Legs", name = "Hyperlight Leggings", sources = { [14]=116679 } },
                { id = 185822, slot = "Two-Hand", name = "Staff of Fractured Spacetime", sources = { [14]=116699 } },
                { id = 185819, slot = "Weapon", name = "Event Horizon's Edge", sources = { [14]=116697 } },
            },
            specialLoot = {
                { id = 186638, kind = "mount", name = "Cartel Master's Gearglider" },
            },
        },
    },
}
