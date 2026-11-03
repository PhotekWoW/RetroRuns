-------------------------------------------------------------------------------
-- RetroRuns -- RunHistory.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Times run per instance across every character, and the record of the run
-- in progress that the End of Run Summary reads.
-------------------------------------------------------------------------------

local RR = RetroRuns

local History = {}
RR.RunHistory = History

-- Statistics can read as unloaded for a while after login.
local SCAN_DELAY, SCAN_RETRY, SCAN_TRIES = 5, 5, 24
-- Run records left untouched this long are dropped.
local RECORD_LIFETIME = 8 * 24 * 60 * 60
-- Seconds after a finish before the statistic is compared: an early look
-- that can only confirm the game counted the run, then the final one.
local STAT_SETTLE, STAT_SETTLE_FINAL = 5, 30

local function CharacterKey()
    return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

-- learned: the game's statistics, per character. logged: the runs this
-- addon saw finish, per instance, character and difficulty, with those the
-- game's statistic missed counted apart. Kept separate; only the total
-- shown combines them.
local function Store()
    RetroRunsDB = RetroRunsDB or {}
    local store = RetroRunsDB.runHistory
    if type(store) ~= "table" then
        store = {}
        RetroRunsDB.runHistory = store
    end
    store.learned = store.learned or {}
    store.logged = store.logged or {}
    store.current = store.current or {}
    return store
end

local function SumValues(values)
    local total = 0
    for _, value in pairs(values or {}) do total = total + value end
    return total
end

-- A kill statistic as a number, or nil while the statistics have not loaded.
local function ReadStatistic(statisticID)
    local raw = GetStatistic and GetStatistic(statisticID)
    if type(raw) == "boolean" then return nil end
    if type(raw) == "number" then return raw end
    if type(raw) ~= "string" then return 0 end
    return tonumber((raw:gsub("%D", ""))) or 0
end

-- Every mapped statistic for this character, or nil while any is unloaded.
local function ReadAllStatistics()
    local counts = {}
    for _, statistics in pairs(RetroRuns_RunStatistics or {}) do
        if statistics then
            for _, statisticID in ipairs(statistics) do
                local value = ReadStatistic(statisticID)
                if value == nil then return nil end
                counts[statisticID] = value
            end
        end
    end
    return counts
end

local function SumStatistics(counts, statistics)
    local total = 0
    for _, statisticID in ipairs(statistics) do
        total = total + (counts[statisticID] or 0)
    end
    return total
end

-- This character's statistics for one instance, read live; nil when the
-- instance has none or they have not loaded.
local function OwnInstanceStatistic(journalID)
    local statistics = RetroRuns_RunStatistics and RetroRuns_RunStatistics[journalID]
    if not statistics then return nil end
    local total = 0
    for _, statisticID in ipairs(statistics) do
        local value = ReadStatistic(statisticID)
        if value == nil then return nil end
        total = total + value
    end
    return total
end

-- This character's logged runs at one instance: runs and missed, each
-- keyed by difficulty.
local function LoggedEntry(journalID)
    local store = Store()
    local key = CharacterKey()
    store.logged[journalID] = store.logged[journalID] or {}
    local entry = store.logged[journalID][key]
    if not entry then
        local _, classToken = UnitClass("player")
        entry = { name = UnitName("player"), class = classToken, runs = {}, missed = {} }
        store.logged[journalID][key] = entry
    end
    return entry
end

-- A finished run the game's statistic did not count (a difficulty it does
-- not track) is marked missed, so the total can add it. The statistic can
-- trail the kill, so only the final check marks a run missed.
function History.SettleRun(record, journalID, final)
    if not record or record.settled or not record.completedAt then return end
    if not (RetroRuns_RunStatistics and RetroRuns_RunStatistics[journalID]) then
        record.settled = true
        return
    end
    local now = OwnInstanceStatistic(journalID)
    if now == nil then return end
    local counted
    if record.statAtStart then
        counted = now > record.statAtStart
    else
        counted = now > 0
    end
    if not counted and not final then return end
    if not counted then
        local entry = LoggedEntry(journalID)
        local difficultyID = record.difficultyID or 0
        entry.missed[difficultyID] = (entry.missed[difficultyID] or 0) + 1
    end
    record.settled = true
    if RR.UI and RR.UI.Update then RR.UI.Update() end
end

local function SettlePendingRuns()
    local runs = Store().current[CharacterKey()]
    for journalID, record in pairs(runs or {}) do
        History.SettleRun(record, journalID, true)
    end
end

-- Saves this character's counts; the first time, says so in chat.
function History.ScanCharacter(tries)
    local counts = ReadAllStatistics()
    if not counts then
        tries = (tries or 0) + 1
        if tries <= SCAN_TRIES then
            C_Timer.After(SCAN_RETRY, function() History.ScanCharacter(tries) end)
        end
        return
    end
    local store = Store()
    local key = CharacterKey()
    local isNew = store.learned[key] == nil
    local _, classToken = UnitClass("player")
    store.learned[key] = {
        name = UnitName("player"), class = classToken, statistics = counts, scanned = time(),
    }
    SettlePendingRuns()
    if not isNew then return end
    local runs, instances = 0, 0
    for _, statistics in pairs(RetroRuns_RunStatistics or {}) do
        if statistics then
            local count = SumStatistics(counts, statistics)
            if count > 0 then
                runs = runs + count
                instances = instances + 1
            end
        end
    end
    local name = UnitName("player") or "?"
    local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
    RR:Print((RR.L["Instance statistics captured for %s:"]):format(color and color:WrapTextInColorCode(name) or name))
    RR:Print("|cffffffff+|r " .. (RR.L["|cff00ff00%d|r clears across |cff00ff00%d|r instances"]):format(runs, instances))
    RR:Print(RR.L["This is a one-time capture for each character to be used in the \"End of Run Summary\"."])
end

-- Times run for an instance across the account: the total, one row per
-- character ({ name, class, count }, largest first), and how many
-- characters were counted. Where the game keeps a statistic: learned plus
-- the logged runs it missed. Where it keeps none: every logged run.
function RR:GetTimesRun(instance)
    local journalID = instance and instance.journalInstanceID
    if not journalID then return nil end
    local store = Store()
    local rows, total = {}, 0
    local logged = store.logged[journalID] or {}
    local statistics = RetroRuns_RunStatistics and RetroRuns_RunStatistics[journalID]
    if statistics then
        -- This character reads live, so the kill that just ended the run counts.
        local own = store.learned[CharacterKey()]
        if own then
            for _, statisticID in ipairs(statistics) do
                local value = ReadStatistic(statisticID)
                if value then own.statistics[statisticID] = value end
            end
        end
        -- A run that just finished counts at once while the game's number
        -- has not caught up with it; once it has, that number carries it.
        local ownKey = CharacterKey()
        local ownRuns = store.current[ownKey]
        local pending = ownRuns and ownRuns[journalID]
        if pending and not (pending.completedAt and not pending.settled and pending.statAtStart) then
            pending = nil
        end
        local seen = {}
        for characterKey, character in pairs(store.learned) do
            seen[characterKey] = true
            local entry = logged[characterKey]
            local learned = SumStatistics(character.statistics or {}, statistics)
            local count = learned + SumValues(entry and entry.missed)
            if pending and characterKey == ownKey and learned <= pending.statAtStart then
                count = count + 1
            end
            rows[#rows + 1] = { name = character.name, class = character.class, count = count }
            total = total + count
        end
        for characterKey, entry in pairs(logged) do
            if not seen[characterKey] then
                local count = SumValues(entry.missed)
                rows[#rows + 1] = { name = entry.name, class = entry.class, count = count }
                total = total + count
            end
        end
    else
        for _, entry in pairs(logged) do
            local count = SumValues(entry.runs)
            rows[#rows + 1] = { name = entry.name, class = entry.class, count = count }
            total = total + count
        end
    end
    table.sort(rows, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return (a.name or "") < (b.name or "")
    end)
    return total, rows, #rows
end

-------------------------------------------------------------------------------
-- The run in progress
-------------------------------------------------------------------------------

-- The instance book's key for the spawn the player is standing in.
local function CurrentSpawnKey()
    local info = RR:GetCurrentInstanceInfo()
    if not info or not info.instanceID then return nil end
    local lastSpawn = RetroRunsDB and RetroRunsDB.instanceLastSpawn
    return lastSpawn and lastSpawn[CharacterKey() .. ":" .. tostring(info.instanceID)]
end

local function SpawnCreated(spawnKey)
    local history = RetroRunsDB and RetroRunsDB.instanceHistory
    local entry = spawnKey and history and history[spawnKey]
    return entry and entry.create
end

-- Every special-loot row the instance offers this character.
function History.SpecialRows(instance)
    local rows = {}
    local classID = RR.PlayerClassID and RR.PlayerClassID()
    local function Add(item, boss)
        if not item.kind or not RR:SpecialLootForPlayer(item) then return end
        if item.restrictedToClass and item.restrictedToClass ~= classID then return end
        rows[#rows + 1] = { item = item, boss = boss }
    end
    for _, boss in ipairs(instance.bosses or {}) do
        for _, item in ipairs(boss.specialLoot or {}) do Add(item, boss) end
    end
    for _, item in ipairs(instance.trashLoot or {}) do Add(item, nil) end
    for _, item in ipairs(instance.eventLoot or {}) do Add(item, nil) end
    return rows
end

local function SpecialKey(item)
    return (item.kind or "") .. ":" .. tostring(item.id)
end
History.SpecialKey = SpecialKey

-- The special loot still to collect when the run began.
local function SnapshotSpecials(instance)
    local missing = {}
    if not RR.SpecialCollectionStateForItem then return missing end
    for _, row in ipairs(History.SpecialRows(instance)) do
        if RR.SpecialCollectionStateForItem(row.item) ~= "collected" then
            missing[SpecialKey(row.item)] = true
        end
    end
    return missing
end

local function InInstance()
    local inInstance = IsInInstance and IsInInstance()
    return inInstance and true or false
end

-- This character's record of the run it is in, matched by lockout or by
-- spawn so a reload, a relog or the first kill's new lockout keeps it.
-- With create, starts one when none matches.
function History.CurrentRun(create)
    local raid = RR.currentRaid
    if not raid or not raid.journalInstanceID or RR.state.testMode then return nil end
    local store = Store()
    local key = CharacterKey()
    store.current[key] = store.current[key] or {}
    local runs = store.current[key]
    local record = runs[raid.journalInstanceID]
    local lockoutId = RR:GetCurrentLockoutId()
    local spawnKey = InInstance() and CurrentSpawnKey() or nil
    if record and ((lockoutId and record.lockoutId == lockoutId)
            or (spawnKey and record.spawnKey == spawnKey)) then
        record.lockoutId = record.lockoutId or lockoutId
        record.spawnKey = spawnKey or record.spawnKey
        record.touched = time()
        return record
    end
    if not create or not InInstance() then return nil end
    record = {
        lockoutId = lockoutId,
        spawnKey = spawnKey,
        difficultyID = RR.state.currentDifficultyID,
        startedAt = SpawnCreated(spawnKey) or time(),
        touched = time(),
        kills = 0,
        sources = {},
        reputation = {},
        factionIDs = {},
        specialsMissing = SnapshotSpecials(raid),
        statAtStart = OwnInstanceStatistic(raid.journalInstanceID),
    }
    runs[raid.journalInstanceID] = record
    return record
end

-- Stamps the finish once, and logs the run, when the route completes with
-- at least one kill seen in it.
function History.CheckComplete()
    if not (RR.IsActiveRouteComplete and RR:IsActiveRouteComplete()) then return end
    local record = History.CurrentRun(false)
    if not record or record.completedAt or (record.kills or 0) == 0 then return end
    record.completedAt = time()
    local journalID = RR.currentRaid.journalInstanceID
    local entry = LoggedEntry(journalID)
    record.difficultyID = record.difficultyID or RR.state.currentDifficultyID
    local difficultyID = record.difficultyID or 0
    entry.runs[difficultyID] = (entry.runs[difficultyID] or 0) + 1
    C_Timer.After(STAT_SETTLE, function() History.SettleRun(record, journalID, false) end)
    C_Timer.After(STAT_SETTLE_FINAL, function() History.SettleRun(record, journalID, true) end)
end

local function PruneRuns()
    local now = time()
    for _, runs in pairs(Store().current) do
        for journalID, record in pairs(runs) do
            if now - (record.touched or record.startedAt or 0) > RECORD_LIFETIME then
                runs[journalID] = nil
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------

local scanned = false
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:RegisterEvent("ENCOUNTER_START")
watcher:RegisterEvent("ENCOUNTER_END")
watcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
watcher:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
watcher:RegisterEvent("FACTION_STANDING_CHANGED")
watcher:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if not scanned then
            scanned = true
            PruneRuns()
            C_Timer.After(SCAN_DELAY, function() History.ScanCharacter(0) end)
        end
        -- The run starts once the instance has loaded its data.
        C_Timer.After(2, function()
            if RR.currentRaid and InInstance() then History.CurrentRun(true) end
        end)
    elseif event == "ENCOUNTER_START" then
        local record = History.CurrentRun(true)
        if record and record.statAtStart == nil and RR.currentRaid then
            record.statAtStart = OwnInstanceStatistic(RR.currentRaid.journalInstanceID)
        end
    elseif event == "ENCOUNTER_END" then
        local success = select(5, ...)
        if success ~= 1 then return end
        local record = History.CurrentRun(true)
        if not record then return end
        record.kills = (record.kills or 0) + 1
        C_Timer.After(1, History.CheckComplete)
    elseif event == "TRANSMOG_COLLECTION_SOURCE_ADDED" then
        local sourceID = ...
        if type(sourceID) ~= "number" or not InInstance() then return end
        local record = History.CurrentRun(true)
        if record then record.sources[sourceID] = true end
    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        local message = ...
        if issecretvalue and issecretvalue(message) then return end
        if not InInstance() or not RR.ParseFactionLine then return end
        local faction, amount = RR.ParseFactionLine(message)
        if not faction then return end
        local record = History.CurrentRun(true)
        if record then
            record.reputation[faction] = (record.reputation[faction] or 0) + amount
        end
    elseif event == "FACTION_STANDING_CHANGED" then
        local factionID = ...
        if not InInstance() or not C_Reputation or not C_Reputation.GetFactionDataByID then return end
        local data = type(factionID) == "number" and C_Reputation.GetFactionDataByID(factionID)
        local record = data and data.name and History.CurrentRun(true)
        if record then record.factionIDs[data.name] = factionID end
    end
end)
