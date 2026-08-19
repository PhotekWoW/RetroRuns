-------------------------------------------------------------------------------
-- RetroRuns Data -- Pit of Saron
-- Wrath of the Lich King dungeon, Patch 3.3.0  |  instanceID: 658  |  journalInstanceID: 278
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[278] = {
    kind              = "dungeon",
    instanceID        = 658,
    journalInstanceID = 278,
    name              = "Pit of Saron",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    patch             = "3.3.0",

    bosses = {
        {
            index              = 1,
            name               = "Forgemaster Garfrost",
            journalEncounterID = 608,
            achievements       = {
                { id = 4524, name = "Doesn't Go to Eleven" },
            },
            loot = {
                { id = 49805, slot = "Feet", name = "Ice-Steeped Sandals", sources = { [14]=24382 } },
                { id = 49804, slot = "Head", name = "Polished Mirror Helm", sources = { [14]=24381 } },
                { id = 50229, slot = "Legs", name = "Legguards of the Frosty Depths", sources = { [14]=24632 } },
                { id = 50234, slot = "Shoulder", name = "Shoulderplates of Frozen Blood", sources = { [14]=24635 } },
                { id = 50233, slot = "Shoulder", name = "Spurned Val'kyr Shoulderguards", sources = { [14]=24634 } },
                { id = 49802, slot = "Two-Hand", name = "Garfrost's Two-Ton Hammer", sources = { [14]=24380 } },
                { id = 49801, slot = "Two-Hand", name = "Unspeakable Secret", sources = { [14]=24379 } },
                { id = 49806, slot = "Waist", name = "Flayer's Black Belt", sources = { [14]=24383 } },
                { id = 50227, slot = "Weapon", name = "Surgeon's Needle", sources = { [14]=24631 } },
                { id = 50230, slot = "Wrist", name = "Malykriss Vambraces", sources = { [14]=24633 } },
            },
        },
        {
            index              = 2,
            name               = "Ick and Krick",
            journalEncounterID = 609,
            achievements       = {
            },
            loot = {
                { id = 50266, slot = "Chest", name = "Ancient Polar Bear Hide", sources = { [14]=24651 } },
                { id = 49811, slot = "Legs", name = "Black Dragonskin Breeches", sources = { [14]=24388 } },
                { id = 50265, slot = "Legs", name = "Blackened Ghoul Skin Leggings", sources = { [14]=24650 } },
                { id = 50262, slot = "Ranged", name = "Felglacier Bolter", sources = { [14]=24647 } },
                { id = 133517, slot = "Shoulder", name = "Saronite-Studded Shoulderguards", sources = { [14]=76800 }, timewalkingOnly = true },
                { id = 49808, slot = "Waist", name = "Bent Gold Belt", sources = { [14]=24385 } },
                { id = 50263, slot = "Waist", name = "Braid of Salt and Fire", sources = { [14]=24648 } },
                { id = 49810, slot = "Waist", name = "Scabrous Zombie Belt", sources = { [14]=24387 } },
                { id = 49807, slot = "Weapon", name = "Krick's Beetle Stabber", sources = { [14]=24384 } },
                { id = 50264, slot = "Wrist", name = "Chewed Leather Wristguards", sources = { [14]=24649 } },
                { id = 49809, slot = "Wrist", name = "Wristguards of Subterranean Moss", sources = { [14]=24386 } },
            },
        },
        {
            index              = 3,
            name               = "Scourgelord Tyrannus",
            journalEncounterID = 610,
            achievements       = {
                { id = 4525, name = "Don't Look Up" },
                { id = 4517, name = "The Pit of Saron" },
                { id = 4520, name = "Heroic: The Pit of Saron" },
            },
            loot = {
                { id = 49823, slot = "Back", name = "Cloak of the Fallen Cardinal", sources = { [14]=24397 } },
                { id = 50272, slot = "Chest", name = "Frost Wyrm Ribcage", sources = { [14]=24656 } },
                { id = 50285, slot = "Chest", name = "Icebound Bronze Cuirass", sources = { [14]=24665 } },
                { id = 49825, slot = "Chest", name = "Palebone Robes", sources = { [14]=24399 } },
                { id = 49816, slot = "Chest", name = "Scourgelord's Frigid Chestplate", sources = { [14]=24391 } },
                { id = 49826, slot = "Chest", name = "Shroud of Rime", sources = { [14]=24400 } },
                { id = 50283, slot = "Feet", name = "Mudslide Boots", sources = { [14]=24663 } },
                { id = 50286, slot = "Feet", name = "Prelate's Snowshoes", sources = { [14]=24666 } },
                { id = 50284, slot = "Hands", name = "Rusty Frozen Fingerguards", sources = { [14]=24664 } },
                { id = 49824, slot = "Head", name = "Horns of the Spurned Val'kyr", sources = { [14]=24398 } },
                { id = 49819, slot = "Head", name = "Skeleton Lord's Cranium", sources = { [14]=24393 } },
                { id = 50269, slot = "Legs", name = "Fleshwerk Leggings", sources = { [14]=24654 } },
                { id = 49822, slot = "Legs", name = "Rimewoven Silks", sources = { [14]=24396 } },
                { id = 49817, slot = "Legs", name = "Shaggy Wyrmleather Leggings", sources = { [14]=24392 } },
                { id = 49821, slot = "Off-hand", name = "Protector of Frigid Souls", sources = { [14]=24395 } },
                { id = 49813, slot = "Ranged", name = "Rimebane Rifle", sources = { [14]=24389 } },
                { id = 50273, slot = "Two-Hand", name = "Engraved Gargoyle Femur", sources = { [14]=24657 } },
                { id = 50267, slot = "Two-Hand", name = "Tyrannical Beheader", sources = { [14]=24652 } },
                { id = 50270, slot = "Waist", name = "Belt of Rotted Fingernails", sources = { [14]=24655 } },
                { id = 50268, slot = "Weapon", name = "Rimefang's Claw", sources = { [14]=24653 } },
                { id = 49820, slot = "Wrist", name = "Gondria's Spectral Bracer", sources = { [14]=24394 } },
            },
            specialLoot = {
                { id = 267007, kind = "decor", name = "Eye of Acherus", decorID = 18483 },
            },
        },
    },
}
