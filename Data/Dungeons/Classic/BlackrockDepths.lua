-------------------------------------------------------------------------------
-- RetroRuns Data -- Blackrock Depths
-- Classic dungeon, Patch 1.0  |  instanceID: 230  |  journalInstanceID: 228
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[228] = {
    kind              = "dungeon",
    instanceID        = 230,
    journalInstanceID = 228,
    name              = "Blackrock Depths",
    expansion         = "Classic",
    difficultyModel   = "dungeonBinary",
    patch             = "1.0",

    bosses = {
        {
            index              = 1,
            name               = "High Interrogator Gerstahn",
            journalEncounterID = 369,
            achievements       = {
            },
            loot = {
                { id = 11626, slot = "Back", name = "Blackveil Cape", sources = { [14]=4203 } },
                { id = 22240, slot = "Feet", name = "Greaves of Withering Despair", sources = { [14]=8751 } },
                { id = 11625, slot = "Off-hand", name = "Enthralled Sphere", sources = { [14]=4202 } },
                { id = 11624, slot = "Shoulder", name = "Kentic Amice", sources = { [14]=4201 } },
            },
        },
        {
            index              = 2,
            name               = "Lord Roccor",
            journalEncounterID = 370,
            achievements       = {
            },
            loot = {
                { id = 22271, slot = "Legs", name = "Leggings of Frenzied Magic", sources = { [14]=8763 } },
                { id = 11631, slot = "Off-hand", name = "Stoneshell Guard", sources = { [14]=4208 } },
                { id = 11632, slot = "Shoulder", name = "Earthslag Shoulders", sources = { [14]=4209 } },
                { id = 22234, slot = "Shoulder", name = "Mantle of Lost Hope", sources = { [14]=8750 } },
                { id = 11679, slot = "Wrist", name = "Rubicund Armguards", sources = { [14]=4218 } },
            },
        },
        {
            index              = 3,
            name               = "Houndmaster Grebmar",
            journalEncounterID = 371,
            achievements       = {
            },
            loot = {
                { id = 11623, slot = "Back", name = "Spritecaster Cape", sources = { [14]=4200 } },
                { id = 11627, slot = "Feet", name = "Fleetfoot Greaves", sources = { [14]=4204 } },
                { id = 11628, slot = "Ranged", name = "Houndmaster's Bow", sources = { [14]=4205 } },
                { id = 11629, slot = "Ranged", name = "Houndmaster's Rifle", sources = { [14]=4206 } },
            },
        },
        {
            index              = 4,
            name               = "Ring of Law",
            journalEncounterID = 372,
            achievements       = {
            },
            loot = {
                { id = 11677, slot = "Back", name = "Graverot Cape", sources = { [14]=4216 } },
                { id = 11678, slot = "Chest", name = "Carapace of Anub'shiah", sources = { [14]=4217 } },
                { id = 11726, slot = "Chest", name = "Savage Gladiator Chain", sources = { [14]=4225 } },
                { id = 11633, slot = "Chest", name = "Spiderfang Carapace", sources = { [14]=4210 } },
                { id = 11731, slot = "Feet", name = "Savage Gladiator Greaves", sources = { [14]=4229 } },
                { id = 11675, slot = "Feet", name = "Shadefiend Boots", sources = { [14]=4215 } },
                { id = 11665, slot = "Hands", name = "Ogreseer Fists", sources = { [14]=4214 } },
                { id = 11730, slot = "Hands", name = "Savage Gladiator Grips", sources = { [14]=4228 } },
                { id = 11634, slot = "Hands", name = "Silkweb Gloves", sources = { [14]=4211 } },
                { id = 11729, slot = "Head", name = "Savage Gladiator Helm", sources = { [14]=4227 } },
                { id = 11728, slot = "Legs", name = "Savage Gladiator Leggings", sources = { [14]=4226 } },
                { id = 11722, slot = "Shoulder", name = "Dregmetal Spaulders", sources = { [14]=4224 } },
                { id = 11685, slot = "Shoulder", name = "Splinthide Shoulders", sources = { [14]=4220 } },
                { id = 11662, slot = "Waist", name = "Ban'thok Sash", sources = { [14]=4213 } },
                { id = 11686, slot = "Waist", name = "Girdle of Beastial Fury", sources = { [14]=4221 } },
                { id = 11703, slot = "Waist", name = "Stonewall Girdle", sources = { [14]=4223 } },
                { id = 22266, slot = "Weapon", name = "Flarethorn", sources = { [14]=8759 } },
                { id = 11702, slot = "Weapon", name = "Grizzle's Skinner", sources = { [14]=4222 } },
                { id = 11635, slot = "Weapon", name = "Hookfang Shanker", sources = { [14]=4212 } },
            },
        },
        {
            index              = 5,
            name               = "Pyromancer Loregrain",
            journalEncounterID = 373,
            achievements       = {
            },
            loot = {
                { id = 11747, slot = "Chest", name = "Flamestrider Robes", sources = { [14]=4235 } },
                { id = 22270, slot = "Feet", name = "Entrenching Boots", sources = { [14]=8762 } },
                { id = 11749, slot = "Legs", name = "Searingscale Leggings", sources = { [14]=4237 } },
                { id = 11748, slot = "Ranged", name = "Pyric Caduceus", sources = { [14]=4236 } },
                { id = 11750, slot = "Two-Hand", name = "Kindling Stave", sources = { [14]=4238 } },
            },
        },
        {
            index              = 6,
            name               = "Lord Incendius",
            journalEncounterID = 374,
            achievements       = {
            },
            loot = {
                { id = 11764, slot = "Wrist", name = "Cinderhide Armsplints", sources = { [14]=4241 } },
                { id = 11767, slot = "Wrist", name = "Emberplate Armguards", sources = { [14]=4244 } },
                { id = 11766, slot = "Wrist", name = "Flameweave Cuffs", sources = { [14]=4243 } },
                { id = 11765, slot = "Wrist", name = "Pyremail Wristguards", sources = { [14]=4242 } },
            },
        },
        {
            index              = 7,
            name               = "Warder Stilgiss",
            journalEncounterID = 375,
            achievements       = {
            },
            loot = {
                { id = 151405, slot = "Chest", name = "Cold-Forged Chestplate", sources = { [14]=89411 } },
                { id = 11782, slot = "Shoulder", name = "Boreal Mantle", sources = { [14]=4246 } },
                { id = 22241, slot = "Shoulder", name = "Dark Warder's Pauldrons", sources = { [14]=8752 } },
                { id = 11783, slot = "Waist", name = "Chillsteel Girdle", sources = { [14]=4247 } },
                { id = 11784, slot = "Weapon", name = "Arbiter's Blade", sources = { [14]=4248 } },
            },
        },
        {
            index              = 8,
            name               = "Fineous Darkvire",
            journalEncounterID = 376,
            achievements       = {
            },
            loot = {
                { id = 11839, slot = "Head", name = "Chief Architect's Monocle", sources = { [14]=4267 } },
                { id = 22223, slot = "Head", name = "Foreman's Head Protector", sources = { [14]=8745 } },
                { id = 11841, slot = "Legs", name = "Senior Designer's Pantaloons", sources = { [14]=4269 } },
                { id = 11842, slot = "Shoulder", name = "Lead Surveyor's Mantle", sources = { [14]=4270 } },
                { id = 151406, slot = "Waist", name = "Belt of the Eminent Mason", sources = { [14]=89412 } },
            },
        },
        {
            index              = 9,
            name               = "Bael'Gar",
            journalEncounterID = 377,
            achievements       = {
            },
            loot = {
                { id = 11802, slot = "Legs", name = "Lavacrest Leggings", sources = { [14]=4252 } },
                { id = 11803, slot = "Two-Hand", name = "Force of Magma", sources = { [14]=4253 } },
                { id = 11807, slot = "Waist", name = "Sash of the Burning Heart", sources = { [14]=4255 } },
                { id = 11805, slot = "Weapon", name = "Rubidium Hammer", sources = { [14]=4254 } },
            },
        },
        {
            index              = 10,
            name               = "General Angerforge",
            journalEncounterID = 378,
            achievements       = {
            },
            loot = {
                { id = 11820, slot = "Chest", name = "Royal Decorated Armor", sources = { [14]=4262 } },
                { id = 11821, slot = "Legs", name = "Warstrife Leggings", sources = { [14]=4263 } },
                { id = 12557, slot = "Shoulder", name = "Ebonsteel Spaulders", sources = { [14]=4464 } },
                { id = 11816, slot = "Two-Hand", name = "Angerforge's Battle Axe", sources = { [14]=4260 } },
                { id = 11932, slot = "Two-Hand", name = "Guiding Stave of Wisdom", sources = { [14]=4328 } },
                { id = 11817, slot = "Weapon", name = "Lord General's Sword", sources = { [14]=4261 } },
            },
        },
        {
            index              = 11,
            name               = "Golem Lord Argelmach",
            journalEncounterID = 379,
            achievements       = {
            },
            loot = {
                { id = 11822, slot = "Feet", name = "Omnicast Boots", sources = { [14]=4264 } },
                { id = 11823, slot = "Legs", name = "Luminary Kilt", sources = { [14]=4265 } },
            },
        },
        {
            index              = 12,
            name               = "Hurley Blackbreath",
            journalEncounterID = 380,
            achievements       = {
            },
            loot = {
                { id = 18043, slot = "Feet", name = "Coal Miner Boots", sources = { [14]=7221 } },
                { id = 11735, slot = "Head", name = "Ragefury Eyepatch", sources = { [14]=4230 } },
                { id = 151407, slot = "Legs", name = "Blackened Pit Trousers", sources = { [14]=89413 } },
                { id = 151408, slot = "Shoulder", name = "Dark Iron Dredger's Pauldrons", sources = { [14]=89414 } },
                { id = 11922, slot = "Weapon", name = "Blood-Etched Blade", sources = { [14]=4318 } },
                { id = 18044, slot = "Weapon", name = "Hurley's Tankard", sources = { [14]=7222 } },
            },
        },
        {
            index              = 13,
            name               = "Phalanx",
            journalEncounterID = 381,
            achievements       = {
            },
            loot = {
                { id = 11745, slot = "Hands", name = "Fists of Phalanx", sources = { [14]=4233 } },
                { id = 22212, slot = "Shoulder", name = "Golem Fitted Pauldrons", sources = { [14]=8742 } },
                { id = 151409, slot = "Waist", name = "Ferrous Cord", sources = { [14]=89415 } },
                { id = 11744, slot = "Weapon", name = "Bloodfist", sources = { [14]=4232 } },
                { id = 22204, slot = "Wrist", name = "Wristguards of Renown", sources = { [14]=8735 } },
            },
        },
        {
            index              = 14,
            name               = "Plugger Spazzring",
            journalEncounterID = 383,
            achievements       = {
            },
            loot = {
                { id = 12793, slot = "Chest", name = "Mixologist's Tunic", sources = { [14]=4546 } },
                { id = 12791, slot = "Weapon", name = "Barman Shanker", sources = { [14]=4544 } },
            },
        },
        {
            index              = 15,
            name               = "Ambassador Flamelash",
            journalEncounterID = 384,
            achievements       = {
            },
            loot = {
                { id = 11812, slot = "Back", name = "Cape of the Fire Salamander", sources = { [14]=4258 } },
                { id = 11814, slot = "Hands", name = "Molten Fists", sources = { [14]=4259 } },
                { id = 11808, slot = "Head", name = "Circle of Flame", sources = { [14]=4256 } },
                { id = 11809, slot = "Two-Hand", name = "Flame Wrath", sources = { [14]=4257 } },
            },
        },
        {
            index              = 16,
            name               = "The Seven",
            journalEncounterID = 385,
            achievements       = {
            },
            loot = {
                { id = 11926, slot = "Chest", name = "Deathdealer Breastplate", sources = { [14]=4322 } },
                { id = 11925, slot = "Head", name = "Ghostshroud", sources = { [14]=4321 } },
                { id = 11929, slot = "Legs", name = "Haunting Specter Leggings", sources = { [14]=4325 } },
                { id = 11927, slot = "Legs", name = "Legplates of the Eternal Guardian", sources = { [14]=4323 } },
                { id = 11921, slot = "Two-Hand", name = "Impervious Giant", sources = { [14]=4317 } },
                { id = 11923, slot = "Weapon", name = "The Hammer of Grace", sources = { [14]=4319 } },
                { id = 11920, slot = "Weapon", name = "Wraith Scythe", sources = { [14]=4316 } },
            },
        },
        {
            index              = 17,
            name               = "Magmus",
            journalEncounterID = 386,
            achievements       = {
            },
            loot = {
                { id = 22275, slot = "Feet", name = "Firemoss Boots", sources = { [14]=8767 } },
                { id = 11746, slot = "Head", name = "Golem Skull Helm", sources = { [14]=4234 } },
                { id = 151411, slot = "Legs", name = "Molten-Warder Leggings", sources = { [14]=89416 } },
                { id = 11935, slot = "Off-hand", name = "Magmus Stone", sources = { [14]=4329 } },
                { id = 22208, slot = "Two-Hand", name = "Lavastone Hammer", sources = { [14]=8739 } },
            },
        },
        {
            index              = 18,
            name               = "Emperor Dagran Thaurissan",
            journalEncounterID = 387,
            achievements       = {
                { id = 642, name = "Blackrock Depths" },
                { id = 295, name = "Direbrewfest" },
            },
            loot = {
                { id = 11930, slot = "Back", name = "The Emperor's New Cape", sources = { [14]=4326 } },
                { id = 11924, slot = "Chest", name = "Robes of the Royal Crown", sources = { [14]=4320 } },
                { id = 12556, slot = "Feet", name = "High Priestess Boots", sources = { [14]=4463 } },
                { id = 12553, slot = "Feet", name = "Swiftwalker Boots", sources = { [14]=4460 } },
                { id = 12554, slot = "Hands", name = "Hands of the Exalted Herald", sources = { [14]=4461 } },
                { id = 11928, slot = "Off-hand", name = "Thaurissan's Royal Scepter", sources = { [14]=4324 } },
                { id = 11931, slot = "Two-Hand", name = "Dreadforge Retaliator", sources = { [14]=4327 } },
                { id = 22207, slot = "Waist", name = "Sash of the Grand Hunt", sources = { [14]=8738 } },
                { id = 11684, slot = "Weapon", name = "Ironfoe", sources = { [14]=4219 } },
            },
            specialLoot = {
                { id = 246429, kind = "decor", name = "Dark Iron Chandelier", decorID = 2246 },
            },
        },
    },
}
