-------------------------------------------------------------------------------
-- RetroRuns Data -- Onyxia's Lair
-- Wrath of the Lich King, Patch 3.2.2  |  instanceID: 249  |  journalInstanceID: 760
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[249] = {
    instanceID        = 249,
    journalInstanceID = 760,
    name              = "Onyxia's Lair",
    -- The Encounter Journal groups the raid under Wrath of the Lich King
    -- (the 10/25-player revamp), which is where players look for it.
    expansion         = "Wrath of the Lich King",
    patch             = "3.2.2",

    exitNote = "None available",

    -- 10-player and 25-player are separate difficulties with their own
    -- loot tables, so each size keeps its own display bucket -- but the
    -- two sizes share one weekly lockout.
    difficultyModel   = "sizesShared",

    entrance = {
        -- Dustwallow Marsh, in Wyrmbog.
        mapID = 70, x = 0.531, y = 0.774,
    },

    -- mapID -> world-map dropdown label.
    maps = {
        [248] = "Onyxia's Lair",
    },

    tierSets = {
        labels       = {},
        tokenSources = {},
    },

    bosses = {
        {
            index              = 1,
            name               = "Onyxia",
            journalEncounterID = 1651,
            achievements       = {
                { id = 4402, name = "More Dots! (10 player)", meta = false, soloable = "yes" },
                { id = 4405, name = "More Dots! (25 player)", meta = false, soloable = "yes" },
                { id = 4403, name = "Many Whelps! Handle It! (10 player)", meta = false, soloable = "kinda" },
                { id = 4406, name = "Many Whelps! Handle It! (25 player)", meta = false, soloable = "kinda" },
                { id = 4404, name = "She Deep Breaths More (10 player)", meta = false, soloable = "yes" },
                { id = 4407, name = "She Deep Breaths More (25 player)", meta = false, soloable = "yes" },
            },
            loot = {
                { id = 49491, slot = "Back", name = "Flowing Sapphiron Drape", sources = { [4]=24198 } },
                { id = 49307, slot = "Back", name = "Fluttering Sapphiron Drape", sources = { [3]=24068 } },
                { id = 49482, slot = "Head", name = "Aurora of Transcendence", sources = { [4]=24194 }, classes = { 5 } },
                { id = 49477, slot = "Head", name = "Bloodfang Hood", sources = { [4]=24189 }, classes = { 4 } },
                { id = 49322, slot = "Head", name = "Bloodfang Mask", sources = { [3]=24078 }, classes = { 4 } },
                { id = 49316, slot = "Head", name = "Circlet of Transcendence", sources = { [3]=24072 }, classes = { 5 } },
                { id = 49331, slot = "Head", name = "Coif of Ten Storms", sources = { [3]=24087 }, classes = { 7 } },
                { id = 49317, slot = "Head", name = "Coronet of Transcendence", sources = { [3]=24073 }, classes = { 5 } },
                { id = 49330, slot = "Head", name = "Cowl of Ten Storms", sources = { [3]=24086 }, classes = { 7 } },
                { id = 49469, slot = "Head", name = "Crown of Ten Storms", sources = { [4]=24181 }, classes = { 7 } },
                { id = 49480, slot = "Head", name = "Dragonstalker's Helm", sources = { [4]=24192 }, classes = { 3 } },
                { id = 49319, slot = "Head", name = "Dragonstalker's Helmet", sources = { [3]=24075 }, classes = { 3 } },
                { id = 49320, slot = "Head", name = "Faceguard of Wrath", sources = { [3]=24076 }, classes = { 1 } },
                { id = 49467, slot = "Head", name = "Frostforged Greathelm", sources = { [4]=24179 }, classes = { 6 } },
                { id = 49466, slot = "Head", name = "Frostforged Helm", sources = { [4]=24178 }, classes = { 6 } },
                { id = 49333, slot = "Head", name = "Frostforged Helmet", sources = { [3]=24089 }, classes = { 6 } },
                { id = 49332, slot = "Head", name = "Frostforged Ringhelm", sources = { [3]=24088 }, classes = { 6 } },
                { id = 49329, slot = "Head", name = "Gaze of Ten Storms", sources = { [3]=24085 }, classes = { 7 } },
                { id = 49321, slot = "Head", name = "Greathelm of Wrath", sources = { [3]=24077 }, classes = { 1 } },
                { id = 49483, slot = "Head", name = "Halo of Transcendence", sources = { [4]=24195 }, classes = { 5 } },
                { id = 49468, slot = "Head", name = "Helm of Ten Storms", sources = { [4]=24180 }, classes = { 7 } },
                { id = 49479, slot = "Head", name = "Helm of Wrath", sources = { [4]=24191 }, classes = { 1 } },
                { id = 49470, slot = "Head", name = "Helmet of Ten Storms", sources = { [4]=24182 }, classes = { 7 } },
                { id = 49478, slot = "Head", name = "Helmet of Wrath", sources = { [4]=24190 }, classes = { 1 } },
                { id = 49323, slot = "Head", name = "Judgment Cover", sources = { [3]=24079 }, classes = { 2 } },
                { id = 49476, slot = "Head", name = "Judgment Crown", sources = { [4]=24188 }, classes = { 2 } },
                { id = 49475, slot = "Head", name = "Judgment Heaume", sources = { [4]=24187 }, classes = { 2 } },
                { id = 49325, slot = "Head", name = "Judgment Helm", sources = { [3]=24081 }, classes = { 2 } },
                { id = 49324, slot = "Head", name = "Judgment Helmet", sources = { [3]=24080 }, classes = { 2 } },
                { id = 49474, slot = "Head", name = "Judgment Hood", sources = { [4]=24186 }, classes = { 2 } },
                { id = 49484, slot = "Head", name = "Nemesis Skullcap", sources = { [4]=24196 }, classes = { 9 } },
                { id = 49315, slot = "Head", name = "Nemesis Skullcover", sources = { [3]=24071 }, classes = { 9 } },
                { id = 49481, slot = "Head", name = "Netherwind Crown", sources = { [4]=24193 }, classes = { 8 } },
                { id = 49318, slot = "Head", name = "Netherwind Hood", sources = { [3]=24074 }, classes = { 8 } },
                { id = 49327, slot = "Head", name = "Stormrage Antlers", sources = { [3]=24083 }, classes = { 11 } },
                { id = 49473, slot = "Head", name = "Stormrage Cover", sources = { [4]=24185 }, classes = { 11 } },
                { id = 49471, slot = "Head", name = "Stormrage Coverlet", sources = { [4]=24183 }, classes = { 11 } },
                { id = 49472, slot = "Head", name = "Stormrage Crown", sources = { [4]=24184 }, classes = { 11 } },
                { id = 49328, slot = "Head", name = "Stormrage Helm", sources = { [3]=24084 }, classes = { 11 } },
                { id = 49326, slot = "Head", name = "Stormrage Hood", sources = { [3]=24082 }, classes = { 11 } },
                { id = 49490, slot = "Held In Off-hand", name = "Antediluvian Cornerstone Grimoire", sources = { [4]=24197 } },
                { id = 49308, slot = "Held In Off-hand", name = "Antique Cornerstone Grimoire", sources = { [3]=24069 } },
                { id = 49493, slot = "Ranged", name = "Rifled Blastershot Launcher", sources = { [4]=24199 } },
                { id = 49305, slot = "Ranged", name = "Snub-Nose Blastershot Launcher", sources = { [3]=24067 } },
                { id = 49299, slot = "Two-Hand", name = "Keen Obsidian Edged Blade", sources = { [3]=24062 } },
                { id = 49302, slot = "Two-Hand", name = "Reclaimed Shadowstrike", sources = { [3]=24064 } },
                { id = 49496, slot = "Two-Hand", name = "Reinforced Shadowstrike", sources = { [4]=24202 } },
                { id = 49498, slot = "Two-Hand", name = "Sharpened Obsidian Edged Blade", sources = { [4]=24204 } },
                { id = 49495, slot = "Weapon", name = "Burnished Quel'Serrar", sources = { [4]=24201 } },
                { id = 49297, slot = "Weapon", name = "Empowered Deathbringer", sources = { [3]=24060 } },
                { id = 49303, slot = "Weapon", name = "Gleaming Quel'Serrar", sources = { [3]=24065 } },
                { id = 49298, slot = "Weapon", name = "Glinting Azuresong Mageblade", sources = { [3]=24061 } },
                { id = 49494, slot = "Weapon", name = "Honed Fang of the Mystics", sources = { [4]=24200 } },
                { id = 49499, slot = "Weapon", name = "Polished Azuresong Mageblade", sources = { [4]=24205 } },
                { id = 49500, slot = "Weapon", name = "Raging Deathbringer", sources = { [4]=24206 } },
                { id = 49437, slot = "Weapon", name = "Rusted Gutgore Ripper", sources = { [3]=24154 } },
                { id = 49304, slot = "Weapon", name = "Sharpened Fang of the Mystics", sources = { [3]=24066 } },
                { id = 49296, slot = "Weapon", name = "Singed Vis'kag the Bloodletter", sources = { [3]=24059 } },
                { id = 49465, slot = "Weapon", name = "Tarnished Gutgore Ripper", sources = { [4]=24177 } },
                { id = 49501, slot = "Weapon", name = "Tempered Vis'kag the Bloodletter", sources = { [4]=24207 } },
            },
            -- The drake drops on both the 10-player and the 25-player
            -- difficulty.
            specialLoot = {
                { id = 49636, kind = "mount", name = "Reins of the Onyxian Drake" },
            },
        },
    },

    routing = {

        -- 1. Onyxia
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Onyxia",
            requires  = { },
            segments  = {
                {
                    when    = { mapID = 248 },
                    kind    = "path",
                    note    = "After zoning in, follow the path all the way back to ^Onyxia^.",
                    minNote = "Path to Onyxia",
                    points  = {
                        { 0.374, 0.214 },
                        { 0.436, 0.222 },
                        { 0.486, 0.204 },
                        { 0.476, 0.167 },
                        { 0.446, 0.150 },
                        { 0.397, 0.167 },
                        { 0.383, 0.313 },
                        { 0.413, 0.325 },
                        { 0.435, 0.363 },
                        { 0.434, 0.566 },
                        { 0.578, 0.824 },
                        { 0.665, 0.812 },
                        { 0.675, 0.658 },
                        { 0.673, 0.347 },
                    },
                },
            },
        },
    },
}
