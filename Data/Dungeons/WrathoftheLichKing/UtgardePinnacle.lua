-------------------------------------------------------------------------------
-- RetroRuns Data -- Utgarde Pinnacle
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 575  |  journalInstanceID: 286
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[286] = {
    kind              = "dungeon",
    instanceID        = 575,
    journalInstanceID = 286,
    name              = "Utgarde Pinnacle",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.0.2",

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Svala Sorrowgrave",
            journalEncounterID = 641,
            achievements       = {
                { id = 2043, name = "The Incredible Hulk", meta = true },
            },
            loot = {
                { id = 127502, slot = "Chest", name = "Ymirjar Physician's Robe", sources = { [14]=72619 }, timewalkingOnly = true },
                { id = 127478, slot = "Feet", name = "Berserker's Sabatons", sources = { [14]=72598 }, timewalkingOnly = true },
                { id = 37367, slot = "Feet", name = "Echoing Stompers", sources = { [14]=17756 } },
                { id = 37043, slot = "Hands", name = "Tear-Linked Gauntlets", sources = { [14]=17562 } },
                { id = 37369, slot = "Legs", name = "Sorrowgrave's Breeches", sources = { [14]=17758 } },
                { id = 37038, slot = "Ranged", name = "Brazier Igniter", sources = { [14]=17557 } },
                { id = 37368, slot = "Shoulder", name = "Silent Spectator Shoulderpads", sources = { [14]=17757 } },
                { id = 37037, slot = "Weapon", name = "Ritualistic Athame", sources = { [14]=17556 } },
                { id = 37370, slot = "Wrist", name = "Cuffs of the Trussed Hall", sources = { [14]=17759 } },
                { id = 37040, slot = "Wrist", name = "Svala's Bloodied Shackles", sources = { [14]=17559 } },
            },
        },
        {
            index              = 2,
            name               = "Gortok Palehoof",
            journalEncounterID = 642,
            achievements       = {
            },
            loot = {
                { id = 37048, slot = "Back", name = "Shroud of Resurrection", sources = { [14]=17566 } },
                { id = 37052, slot = "Chest", name = "Reanimated Armor", sources = { [14]=17570 } },
                { id = 127480, slot = "Feet", name = "Tundra Wolf Boots", sources = { [14]=72600 }, timewalkingOnly = true },
                { id = 37374, slot = "Legs", name = "Ravenous Leggings of the Furbolg", sources = { [14]=17761 } },
                { id = 37051, slot = "Off-hand", name = "Seal of Valgarde", sources = { [14]=17569 } },
                { id = 37050, slot = "Ranged", name = "Trophy Gatherer", sources = { [14]=17568 } },
                { id = 37376, slot = "Shoulder", name = "Ferocious Pauldrons of the Rhino", sources = { [14]=17763 } },
                { id = 37373, slot = "Shoulder", name = "Massive Spaulders of the Jormungar", sources = { [14]=17760 } },
            },
        },
        {
            index              = 3,
            name               = "Skadi the Ruthless",
            journalEncounterID = 643,
            achievements       = {
                { id = 1873, name = "Lodi Dodi We Loves the Skadi", meta = true },
                { id = 2156, name = "My Girl Loves to Skadi All the Time", meta = true },
            },
            loot = {
                { id = 37057, slot = "Chest", name = "Drake Rider's Tunic", sources = { [14]=17574 } },
                { id = 37056, slot = "Feet", name = "Harpooner's Striders", sources = { [14]=17573 } },
                { id = 157560, slot = "Feet", name = "Skadi's Scaled Boots", sources = { [14]=93755 } },
                { id = 37389, slot = "Legs", name = "Crenelation Leggings", sources = { [14]=17775 } },
                { id = 37055, slot = "Shoulder", name = "Silken Amice of the Ymirjar", sources = { [14]=17572 } },
                { id = 37384, slot = "Two-Hand", name = "Staff of Wayward Principles", sources = { [14]=17770 } },
                { id = 37379, slot = "Waist", name = "Skadi's Iron Belt", sources = { [14]=17766 } },
                { id = 37377, slot = "Weapon", name = "Netherbreath Spellblade", sources = { [14]=17764 } },
                { id = 127503, slot = "Wrist", name = "Bands of Fading Light", sources = { [14]=72620 }, timewalkingOnly = true },
                { id = 127479, slot = "Wrist", name = "Dragonflayer Seer's Bindings", sources = { [14]=72599 }, timewalkingOnly = true },
            },
            specialLoot = {
                { id = 44151, kind = "mount", name = "Reins of the Blue Proto-Drake" },
            },
        },
        {
            index              = 4,
            name               = "King Ymiron",
            journalEncounterID = 644,
            achievements       = {
                { id = 2157, name = "King's Bane", meta = true },
                { id = 488, name = "Utgarde Pinnacle" },
                { id = 499, name = "Heroic: Utgarde Pinnacle" },
                { id = 39934, name = "Utgarde Pinnacle (char specific hidden copy)" },
            },
            loot = {
                { id = 37395, slot = "Chest", name = "Ornamented Plate Regalia", sources = { [14]=17780 } },
                { id = 37409, slot = "Hands", name = "Gilt-Edged Leather Gauntlets", sources = { [14]=17793 } },
                { id = 37062, slot = "Head", name = "Crown of Forgotten Kings", sources = { [14]=17578 } },
                { id = 37066, slot = "Legs", name = "Ancient Royal Legguards", sources = { [14]=17580 } },
                { id = 37061, slot = "Off-hand", name = "Tor's Crest", sources = { [14]=17577 } },
                { id = 37067, slot = "Shoulder", name = "Ceremonial Pyre Mantle", sources = { [14]=17581 } },
                { id = 37398, slot = "Shoulder", name = "Mantle of Discarded Ways", sources = { [14]=17782 } },
                { id = 37408, slot = "Waist", name = "Girdle of Bane", sources = { [14]=17792 } },
                { id = 37407, slot = "Waist", name = "Sovereign's Belt", sources = { [14]=17791 } },
                { id = 37060, slot = "Weapon", name = "Jeweled Coronation Sword", sources = { [14]=17576 } },
                { id = 37401, slot = "Weapon", name = "Red Sword of Courage", sources = { [14]=17785 } },
                { id = 37065, slot = "Weapon", name = "Ymiron's Blade", sources = { [14]=17579 } },
            },
        },
    },
}
