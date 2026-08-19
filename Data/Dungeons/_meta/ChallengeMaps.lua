-------------------------------------------------------------------------------
-- RetroRuns Data -- Challenge map translation
-- mapChallengeModeID -> instance map ID, from MapChallengeMode.db2.
-- Consumed by the seasonal M+ detection: the client's
-- C_ChallengeMode.GetMapTable() returns the CURRENT season's
-- challenge ids, and this table turns them into instances.
-------------------------------------------------------------------------------

RetroRuns_DungeonMeta = RetroRuns_DungeonMeta or {}

RetroRuns_DungeonMeta.challengeMapToInstance = {
    [2] = 960,  -- Temple of the Jade Serpent
    [56] = 961,  -- Stormstout Brewery
    [57] = 962,  -- Gate of the Setting Sun
    [58] = 959,  -- Shado-Pan Monastery
    [59] = 1011,  -- Siege of Niuzao Temple
    [60] = 994,  -- Mogu'shan Palace
    [76] = 1007,  -- Scholomance
    [77] = 1001,  -- Scarlet Halls
    [78] = 1004,  -- Scarlet Monastery
    [161] = 1209,  -- Skyreach
    [163] = 1175,  -- Bloodmaul Slag Mines
    [164] = 1182,  -- Auchindoun
    [165] = 1176,  -- Shadowmoon Burial Grounds
    [166] = 1208,  -- Grimrail Depot
    [167] = 1358,  -- Upper Blackrock Spire
    [168] = 1279,  -- The Everbloom
    [169] = 1195,  -- Iron Docks
    [197] = 1456,  -- Eye of Azshara
    [198] = 1466,  -- Darkheart Thicket
    [199] = 1501,  -- Black Rook Hold
    [200] = 1477,  -- Halls of Valor
    [206] = 1458,  -- Neltharion's Lair
    [207] = 1493,  -- Vault of the Wardens
    [208] = 1492,  -- Maw of Souls
    [209] = 1516,  -- The Arcway
    [210] = 1571,  -- Court of Stars
    [227] = 1651,  -- Return to Karazhan: Lower
    [233] = 1677,  -- Cathedral of Eternal Night
    [234] = 1651,  -- Return to Karazhan: Upper
    [239] = 1753,  -- Seat of the Triumvirate
    [244] = 1763,  -- Atal'Dazar
    [245] = 1754,  -- Freehold
    [246] = 1771,  -- Tol Dagor
    [247] = 1594,  -- The MOTHERLODE!!
    [248] = 1862,  -- Waycrest Manor
    [249] = 1762,  -- Kings' Rest
    [250] = 1877,  -- Temple of Sethraliss
    [251] = 1841,  -- The Underrot
    [252] = 1864,  -- Shrine of the Storm
    [353] = 1822,  -- Siege of Boralus
    [369] = 2097,  -- Operation: Mechagon - Junkyard
    [370] = 2097,  -- Operation: Mechagon - Workshop
    [375] = 2290,  -- Mists of Tirna Scithe
    [376] = 2286,  -- The Necrotic Wake
    [377] = 2291,  -- De Other Side
    [378] = 2287,  -- Halls of Atonement
    [379] = 2289,  -- Plaguefall
    [380] = 2284,  -- Sanguine Depths
    [381] = 2285,  -- Spires of Ascension
    [382] = 2293,  -- Theater of Pain
    [391] = 2441,  -- Tazavesh: Streets of Wonder
    [392] = 2441,  -- Tazavesh: So'leah's Gambit
    [399] = 2521,  -- Ruby Life Pools
    [400] = 2516,  -- The Nokhud Offensive
    [401] = 2515,  -- The Azure Vault
    [402] = 2526,  -- Algeth'ar Academy
    [403] = 2451,  -- Uldaman: Legacy of Tyr
    [404] = 2519,  -- Neltharus
    [405] = 2520,  -- Brackenhide Hollow
    [406] = 2527,  -- Halls of Infusion
    [438] = 657,  -- The Vortex Pinnacle
    [456] = 643,  -- Throne of the Tides
    [463] = 2579,  -- Dawn of the Infinite: Galakrond's Fall
    [464] = 2579,  -- Dawn of the Infinite: Murozond's Rise
    [499] = 2649,  -- Priory of the Sacred Flame
    [500] = 2648,  -- The Rookery
    [501] = 2652,  -- The Stonevault
    [502] = 2669,  -- City of Threads
    [503] = 2660,  -- Ara-Kara, City of Echoes
    [504] = 2651,  -- Darkflame Cleft
    [505] = 2662,  -- The Dawnbreaker
    [506] = 2661,  -- Cinderbrew Meadery
    [507] = 670,  -- Grim Batol
    [525] = 2773,  -- Operation: Floodgate
    [541] = 725,  -- The Stonecore
    [542] = 2830,  -- Eco-Dome Al'dani
    [556] = 658,  -- Pit of Saron
    [557] = 2805,  -- Windrunner Spire
    [558] = 2811,  -- Magisters' Terrace
    [559] = 2915,  -- Nexus-Point Xenas
    [560] = 2874,  -- Maisara Caverns
    [583] = 1753,  -- Seat of the Triumvirate
    [584] = 2859,  -- The Blinding Vale
    [585] = 2923,  -- Voidscar Arena
    [586] = 2825,  -- Den of Nalorakk
    [587] = 2813,  -- Murder Row
    [588] = 2993,  -- Altar of Fangs
}
