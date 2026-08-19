-------------------------------------------------------------------------------
-- RetroRuns Data -- The Underbog
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 546  |  journalInstanceID: 262
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[262] = {
    kind              = "dungeon",
    instanceID        = 546,
    journalInstanceID = 262,
    name              = "The Underbog",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    patch             = "2.0.3",

    bosses = {
        {
            index              = 1,
            name               = "Hungarfen",
            journalEncounterID = 576,
            achievements       = {
            },
            loot = {
                { id = 27745, slot = "Hands", name = "Hungarhide Gauntlets", sources = { [14]=12034 } },
                { id = 24450, slot = "Hands", name = "Manaspark Gloves", sources = { [14]=9564 } },
                { id = 24452, slot = "Hands", name = "Starlight Gauntlets", sources = { [14]=9566 } },
                { id = 27748, slot = "Legs", name = "Cassock of the Loyal", sources = { [14]=12037 } },
                { id = 27743, slot = "Waist", name = "Girdle of Living Flame", sources = { [14]=12033 } },
                { id = 27747, slot = "Weapon", name = "Boggspine Knuckles", sources = { [14]=12036 } },
                { id = 27746, slot = "Wrist", name = "Arcanium Signet Bands", sources = { [14]=12035 } },
                { id = 24451, slot = "Wrist", name = "Lykul Bloodbands", sources = { [14]=9565 } },
            },
        },
        {
            index              = 2,
            name               = "Ghaz'an",
            journalEncounterID = 577,
            achievements       = {
            },
            loot = {
                { id = 24459, slot = "Back", name = "Cloak of Healing Rays", sources = { [14]=9573 } },
                { id = 27759, slot = "Head", name = "Headdress of the Tides", sources = { [14]=12047 } },
                { id = 27757, slot = "Two-Hand", name = "Greatstaff of the Leviathan", sources = { [14]=12046 } },
                { id = 24461, slot = "Two-Hand", name = "Hatebringer", sources = { [14]=9574 } },
                { id = 27760, slot = "Waist", name = "Dunewind Sash", sources = { [14]=12048 } },
                { id = 27755, slot = "Waist", name = "Girdle of Gallantry", sources = { [14]=12044 } },
                { id = 24458, slot = "Waist", name = "Studded Girdle of Virtue", sources = { [14]=9572 } },
            },
        },
        {
            index              = 3,
            name               = "Swamplord Musel'ek",
            journalEncounterID = 578,
            achievements       = {
            },
            loot = {
                { id = 24454, slot = "Back", name = "Cloak of Enduring Swiftness", sources = { [14]=9568 } },
                { id = 24455, slot = "Chest", name = "Tunic of the Nightwatcher", sources = { [14]=9569 } },
                { id = 27764, slot = "Hands", name = "Hands of the Sun", sources = { [14]=12050 } },
                { id = 27763, slot = "Head", name = "Crown of the Forest Lord", sources = { [14]=12049 } },
                { id = 24456, slot = "Legs", name = "Greaves of the Iron Guardian", sources = { [14]=9570 } },
                { id = 24457, slot = "Shoulder", name = "Truth Bearer Shoulderguards", sources = { [14]=9571 } },
                { id = 27767, slot = "Weapon", name = "Bogreaver", sources = { [14]=12052 } },
                { id = 24453, slot = "Weapon", name = "Zangartooth Shortblade", sources = { [14]=9567 } },
                { id = 27765, slot = "Wrist", name = "Armwraps of Disdain", sources = { [14]=12051 } },
            },
        },
        {
            index              = 4,
            name               = "The Black Stalker",
            journalEncounterID = 579,
            achievements       = {
                { id = 670, name = "Heroic: Underbog" },
            },
            loot = {
                { id = 24481, slot = "Chest", name = "Robes of the Augurer", sources = { [14]=9579 } },
                { id = 24465, slot = "Chest", name = "Shamblehide Chestguard", sources = { [14]=9577 } },
                { id = 29265, slot = "Feet", name = "Barkchip Boots", sources = { [14]=13058 } },
                { id = 27781, slot = "Head", name = "Demonfang Ritual Helm", sources = { [14]=12061 } },
                { id = 27938, slot = "Head", name = "Savage Mask of the Lynx Lord", sources = { [14]=12164 } },
                { id = 27773, slot = "Legs", name = "Barbaric Legstraps", sources = { [14]=12057 } },
                { id = 27907, slot = "Legs", name = "Mana-Etched Pantaloons", sources = { [14]=12145 } },
                { id = 24466, slot = "Legs", name = "Skulldugger's Leggings", sources = { [14]=9578 } },
                { id = 30541, slot = "Legs", name = "Stormsong Kilt", sources = { [14]=13811 } },
                { id = 27772, slot = "Off-hand", name = "Stormshield of Renewal", sources = { [14]=12056 } },
                { id = 29350, slot = "Ranged", name = "The Black Stalk", sources = { [14]=13095 } },
                { id = 27771, slot = "Shoulder", name = "Doomplate Shoulderguards", sources = { [14]=12055 } },
                { id = 24463, slot = "Shoulder", name = "Pauldrons of Brute Force", sources = { [14]=9575 } },
                { id = 27769, slot = "Two-Hand", name = "Endbringer", sources = { [14]=12054 } },
                { id = 27768, slot = "Waist", name = "Oracle Belt of Timeless Mystery", sources = { [14]=12053 } },
                { id = 24464, slot = "Weapon", name = "The Stalker's Fangs", sources = { [14]=9576 } },
            },
        },
    },
}
