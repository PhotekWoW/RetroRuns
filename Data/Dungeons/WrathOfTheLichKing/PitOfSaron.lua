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
    availableDifficulties = { 14, 15, 24 },
    patch             = "3.3.0",
    timewalking       = true,

    entrance = {
        mapID = 123,
        x     = 0.7819,
        y     = 0.0668,
    },

    bosses = {
        {
            index              = 1,
            name               = "Forgemaster Garfrost",
            journalEncounterID = 608,
            achievements       = {
            },
            loot = {
                { id = 49805, slot = "Feet", name = "Ice-Steeped Sandals", sources = { [14]=24382, [15]=24382 }, twSource = 76782 },
                { id = 49804, slot = "Head", name = "Polished Mirror Helm", sources = { [14]=24381, [15]=24381 }, twSource = 76781 },
                { id = 50229, slot = "Legs", name = "Legguards of the Frosty Depths", sources = { [14]=24632, [15]=24632 } },
                { id = 50234, slot = "Shoulder", name = "Shoulderplates of Frozen Blood", sources = { [14]=24635, [15]=24635 } },
                { id = 50233, slot = "Shoulder", name = "Spurned Val'kyr Shoulderguards", sources = { [14]=24634, [15]=24634 } },
                { id = 49802, slot = "Two-Hand", name = "Garfrost's Two-Ton Hammer", sources = { [14]=24380, [15]=24380 }, twSource = 76780 },
                { id = 49801, slot = "Two-Hand", name = "Unspeakable Secret", sources = { [14]=24379, [15]=24379 }, twSource = 76779 },
                { id = 49806, slot = "Waist", name = "Flayer's Black Belt", sources = { [14]=24383, [15]=24383 }, twSource = 76783 },
                { id = 50227, slot = "Weapon", name = "Surgeon's Needle", sources = { [14]=24631, [15]=24631 } },
                { id = 50230, slot = "Wrist", name = "Malykriss Vambraces", sources = { [14]=24633, [15]=24633 } },
            },
        },
        {
            index              = 2,
            name               = "Ick and Krick",
            journalEncounterID = 609,
            scenarioCriteriaID = 27938,
            achievements       = {
            },
            loot = {
                { id = 50266, slot = "Chest", name = "Ancient Polar Bear Hide", sources = { [14]=24651, [15]=24651 } },
                { id = 49811, slot = "Legs", name = "Black Dragonskin Breeches", sources = { [14]=24388, [15]=24388 }, twSource = 76788 },
                { id = 50265, slot = "Legs", name = "Blackened Ghoul Skin Leggings", sources = { [14]=24650, [15]=24650 } },
                { id = 50262, slot = "Ranged", name = "Felglacier Bolter", sources = { [14]=24647, [15]=24647 } },
                { id = 133517, slot = "Shoulder", name = "Saronite-Studded Shoulderguards", sources = { [24]=76800 } },
                { id = 49808, slot = "Waist", name = "Bent Gold Belt", sources = { [14]=24385, [15]=24385 }, twSource = 76785 },
                { id = 50263, slot = "Waist", name = "Braid of Salt and Fire", sources = { [14]=24648, [15]=24648 } },
                { id = 49810, slot = "Waist", name = "Scabrous Zombie Belt", sources = { [14]=24387, [15]=24387 }, twSource = 76787 },
                { id = 49807, slot = "Weapon", name = "Krick's Beetle Stabber", sources = { [14]=24384, [15]=24384 }, twSource = 76784 },
                { id = 50264, slot = "Wrist", name = "Chewed Leather Wristguards", sources = { [14]=24649, [15]=24649 } },
                { id = 49809, slot = "Wrist", name = "Wristguards of Subterranean Moss", sources = { [14]=24386, [15]=24386 }, twSource = 76786 },
            },
        },
        {
            index              = 3,
            name               = "Scourgelord Tyrannus",
            journalEncounterID = 610,
            achievements       = {
            },
            loot = {
                { id = 49823, slot = "Back", name = "Cloak of the Fallen Cardinal", sources = { [14]=24397, [15]=24397 }, twSource = 76796 },
                { id = 50272, slot = "Chest", name = "Frost Wyrm Ribcage", sources = { [14]=24656, [15]=24656 } },
                { id = 50285, slot = "Chest", name = "Icebound Bronze Cuirass", sources = { [14]=24665, [15]=24665 } },
                { id = 49825, slot = "Chest", name = "Palebone Robes", sources = { [14]=24399, [15]=24399 }, twSource = 76798 },
                { id = 49816, slot = "Chest", name = "Scourgelord's Frigid Chestplate", sources = { [14]=24391, [15]=24391 }, twSource = 76790 },
                { id = 49826, slot = "Chest", name = "Shroud of Rime", sources = { [14]=24400, [15]=24400 }, twSource = 76799 },
                { id = 50283, slot = "Feet", name = "Mudslide Boots", sources = { [14]=24663, [15]=24663 } },
                { id = 50286, slot = "Feet", name = "Prelate's Snowshoes", sources = { [14]=24666, [15]=24666 } },
                { id = 50284, slot = "Hands", name = "Rusty Frozen Fingerguards", sources = { [14]=24664, [15]=24664 } },
                { id = 49824, slot = "Head", name = "Horns of the Spurned Val'kyr", sources = { [14]=24398, [15]=24398 }, twSource = 76797 },
                { id = 49819, slot = "Head", name = "Skeleton Lord's Cranium", sources = { [14]=24393, [15]=24393 }, twSource = 76792 },
                { id = 50269, slot = "Legs", name = "Fleshwerk Leggings", sources = { [14]=24654, [15]=24654 } },
                { id = 49822, slot = "Legs", name = "Rimewoven Silks", sources = { [14]=24396, [15]=24396 }, twSource = 76795 },
                { id = 49817, slot = "Legs", name = "Shaggy Wyrmleather Leggings", sources = { [14]=24392, [15]=24392 }, twSource = 76791 },
                { id = 49821, slot = "Off-hand", name = "Protector of Frigid Souls", sources = { [14]=24395, [15]=24395 }, twSource = 76794 },
                { id = 49813, slot = "Ranged", name = "Rimebane Rifle", sources = { [14]=24389, [15]=24389 }, twSource = 76789 },
                { id = 50273, slot = "Two-Hand", name = "Engraved Gargoyle Femur", sources = { [14]=24657, [15]=24657 } },
                { id = 50267, slot = "Two-Hand", name = "Tyrannical Beheader", sources = { [14]=24652, [15]=24652 } },
                { id = 50270, slot = "Waist", name = "Belt of Rotted Fingernails", sources = { [14]=24655, [15]=24655 } },
                { id = 50268, slot = "Weapon", name = "Rimefang's Claw", sources = { [14]=24653, [15]=24653 } },
                { id = 49820, slot = "Wrist", name = "Gondria's Spectral Bracer", sources = { [14]=24394, [15]=24394 }, twSource = 76793 },
            },
            specialLoot = {
                { id = 267007, kind = "decor", name = "Eye of Acherus", decorID = 18483 },
            },
        },
    },
}
