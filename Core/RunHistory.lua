-------------------------------------------------------------------------------
-- RetroRuns -- RunHistory.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- The character standing highest with each character-only reputation, and
-- the record of the run in progress that the End of Run Summary reads.
-------------------------------------------------------------------------------

local RR = RetroRuns

local History = {}
RR.RunHistory = History

-- Reputations can read as unloaded for a while after login.
local SCAN_DELAY, SCAN_RETRY, SCAN_TRIES = 5, 5, 24
-- Run records left untouched this long are dropped.
local RECORD_LIFETIME = 8 * 24 * 60 * 60
-- Faction ids are read from 1 up to this.
local FACTION_ID_LIMIT = 4000
-- The bottom of Hated.
local REPUTATION_FLOOR = -42000
-- Coin still counts this long after the loot window closes.
local LOOT_GRACE = 1.5

local function CharacterKey()
    return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

-- learned: each character's name, class and sex. highestReputation: per
-- character, the character-only factions it stands highest with on the
-- account. current: per character, the run in progress at each instance.
-- bestTimes: per character, its fastest clear of each instance and difficulty.
local function Store()
    RetroRunsDB = RetroRunsDB or {}
    local store = RetroRunsDB.runHistory
    if type(store) ~= "table" then
        store = {}
        RetroRunsDB.runHistory = store
    end
    store.learned = store.learned or {}
    store.current = store.current or {}
    store.highestReputation = store.highestReputation or {}
    store.bestTimes = store.bestTimes or {}
    return store
end

-- Clears saved data nothing reads any more: kill statistics and the run log.
function History.DropRetiredCounts()
    local store = Store()
    store.logged, store.recountedMisses = nil, nil
    for _, character in pairs(store.learned) do character.statistics = nil end
    for _, runs in pairs(store.current) do
        for _, record in pairs(runs) do record.statAtStart, record.settled = nil, nil end
    end
end

-------------------------------------------------------------------------------
-- Highest reputation across the account
-------------------------------------------------------------------------------

-- Off zero and above the bottom of Hated.
local function Progressed(standing)
    return standing ~= 0 and standing > REPUTATION_FLOOR
end

local function IsFriendship(factionID)
    local friend = C_GossipInfo and C_GossipInfo.GetFriendshipReputation
        and C_GossipInfo.GetFriendshipReputation(factionID)
    return friend and friend.friendshipFactionID and friend.friendshipFactionID > 0 or false
end

-- This character's standing with each character-only faction but its
-- friendships, and the factions that read as account-wide.
local function ReadCharacterReputation()
    local standings, accountWide = {}, {}
    if not (C_Reputation and C_Reputation.GetFactionDataByID) then return standings, accountWide end
    for factionID = 1, FACTION_ID_LIMIT do
        local data = C_Reputation.GetFactionDataByID(factionID)
        if data and data.name and (data.isHeaderWithRep or not data.isHeader) then
            local standing = data.currentStanding or 0
            if data.isAccountWide then
                accountWide[factionID] = true
            elseif not (Progressed(standing) and IsFriendship(factionID)) then
                standings[factionID] = standing
            end
        end
    end
    return standings, accountWide
end

-- Gives each faction to whichever character stands highest and returns how
-- many of this character's entries changed and how many of those it took
-- the lead on. A faction it did not read keeps its holder.
function History.UpdateHighestReputation(highest, key, standings, accountWide)
    local holderOf = {}
    for holderKey, factions in pairs(highest) do
        for factionID in pairs(factions) do holderOf[factionID] = holderKey end
    end
    local function Release(factionID)
        local holder = holderOf[factionID]
        if holder then highest[holder][factionID] = nil end
    end
    for factionID in pairs(accountWide) do Release(factionID) end
    highest[key] = highest[key] or {}
    local changed, taken = 0, 0
    for factionID, standing in pairs(standings) do
        local holder = holderOf[factionID]
        if holder == key then
            local kept = Progressed(standing) and standing or nil
            if kept ~= highest[key][factionID] then changed = changed + 1 end
            highest[key][factionID] = kept
        elseif Progressed(standing) and (not holder or standing > highest[holder][factionID]) then
            Release(factionID)
            highest[key][factionID] = standing
            changed, taken = changed + 1, taken + 1
        end
    end
    for holderKey, factions in pairs(highest) do
        if next(factions) == nil then highest[holderKey] = nil end
    end
    return changed, taken
end

-- Records this character's standings (read now unless passed in), unless
-- none have loaded. Returns how many it recorded (on its first capture,
-- every one with progress; after, the entries that changed) and how many it
-- took the lead on.
function History.ScanReputation(standings, accountWide)
    if not standings then standings, accountWide = ReadCharacterReputation() end
    local captured = 0
    for _, standing in pairs(standings) do
        if Progressed(standing) then captured = captured + 1 end
    end
    if captured == 0 then return nil end
    local store = Store()
    local key = CharacterKey()
    local changed, taken = History.UpdateHighestReputation(store.highestReputation, key,
        standings, accountWide)
    local character = store.learned[key]
    if character and not character.reputationCaptured then
        character.reputationCaptured = true
        changed = captured
    end
    return changed, taken
end

-- The other character standing highest with a character-only faction, as
-- { name, class, sex, standing }; nil when none is recorded or it is this one.
function RR:GetHighestReputation(factionID)
    local store = Store()
    for holderKey, factions in pairs(store.highestReputation) do
        local standing = factions[factionID]
        if standing then
            if holderKey == CharacterKey() then return nil end
            local character = store.learned[holderKey]
            return {
                name = character and character.name or holderKey:match("^[^-]+"),
                class = character and character.class,
                sex = character and character.sex,
                standing = standing,
            }
        end
    end
    return nil
end

-- Saves this character's name and reputations once the factions have
-- loaded, and says in chat what changed since the last capture.
function History.ScanCharacter(tries)
    local standings, accountWide = ReadCharacterReputation()
    if next(standings) == nil and next(accountWide) == nil then
        tries = (tries or 0) + 1
        if tries <= SCAN_TRIES then
            C_Timer.After(SCAN_RETRY, function() History.ScanCharacter(tries) end)
        end
        return
    end
    local store = Store()
    local key = CharacterKey()
    local before = store.learned[key]
    local _, classToken = UnitClass("player")
    store.learned[key] = {
        name = UnitName("player"), class = classToken, sex = UnitSex("player"),
        scanned = time(),
        reputationCaptured = before and before.reputationCaptured or nil,
    }
    local reputations, leads = History.ScanReputation(standings, accountWide)
    reputations, leads = reputations or 0, leads or 0
    if reputations == 0 then return end
    local name = UnitName("player") or "?"
    local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
    name = color and color:WrapTextInColorCode(name) or name
    RR:Print((RR.L["Character data updated for %s"]):format(name))
    if leads > 0 then
        RR:Print("|cffffffff+|r" .. (RR.L["|cff00ff00%d|r Reputations (New leader for |cff00ff00%d|r)"])
            :format(reputations, leads))
    else
        RR:Print("|cffffffff+|r" .. (RR.L["|cff00ff00%d|r Reputations"]):format(reputations))
    end
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
        gold = 0,
        sources = {},
        reputation = {},
        factionIDs = {},
        specialsMissing = SnapshotSpecials(raid),
    }
    runs[raid.journalInstanceID] = record
    return record
end

local function BestKey(journalID, bucket)
    return tostring(journalID) .. ":" .. tostring(bucket)
end

-- The account's fastest clear of the instance at a difficulty, as
-- { seconds, name, class, mine }; nil before one is recorded.
function History.BestTime(raid, difficultyID)
    local bucket = raid and difficultyID and RR:FoldDifficulty(raid, difficultyID)
    if not bucket then return nil end
    local key = BestKey(raid.journalInstanceID, bucket)
    local store = Store()
    local ownKey = CharacterKey()
    local seconds, holder
    for characterKey, times in pairs(store.bestTimes) do
        local recorded = times[key]
        if recorded and (not seconds or recorded < seconds
                or (recorded == seconds and characterKey == ownKey)) then
            seconds, holder = recorded, characterKey
        end
    end
    if not seconds then return nil end
    local character = store.learned[holder]
    return {
        seconds = seconds,
        name = character and character.name or holder:match("^[^-]+"),
        class = character and character.class,
        mine = holder == ownKey,
    }
end

-- Kills the lockout holds, read from its saved row; nil without one.
local function LockoutProgress(lockoutId)
    if not (lockoutId and GetNumSavedInstances and GetSavedInstanceInfo) then return nil end
    for index = 1, GetNumSavedInstances() do
        local _, rowLockoutId, _, _, _, _, _, _, _, _, _, encounterProgress = GetSavedInstanceInfo(index)
        if rowLockoutId == lockoutId then return encounterProgress end
    end
    return nil
end

-- Keeps the finished run's length as this character's best when it is, and
-- marks the run when it beat the account's. A lockout holding more kills
-- than the run saw began before it and sets nothing.
local function RecordBestTime(raid, record)
    if not (raid and record.startedAt and record.completedAt) then return end
    local progress = LockoutProgress(record.lockoutId)
    if progress and progress > (record.kills or 0) then return end
    local bucket = RR:FoldDifficulty(raid, record.difficultyID)
    if not bucket then return end
    local seconds = math.max(0, record.completedAt - record.startedAt)
    local best = History.BestTime(raid, record.difficultyID)
    record.newBest = (not best or seconds < best.seconds) or nil
    local store = Store()
    local characterKey = CharacterKey()
    store.bestTimes[characterKey] = store.bestTimes[characterKey] or {}
    local times = store.bestTimes[characterKey]
    local key = BestKey(raid.journalInstanceID, bucket)
    if not times[key] or seconds < times[key] then times[key] = seconds end
end

-- Stamps the finish once, when the route completes with at least one kill
-- seen in it.
function History.CheckComplete()
    if not (RR.IsActiveRouteComplete and RR:IsActiveRouteComplete()) then return end
    local record = History.CurrentRun(false)
    if not record or record.completedAt or (record.kills or 0) == 0 then return end
    record.completedAt = time()
    record.difficultyID = record.difficultyID or RR.state.currentDifficultyID
    RecordBestTime(RR.currentRaid, record)
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
-- Money gained counts as looted while a loot window is open or just closed.
local lootOpenUntil, lastMoney = 0, nil
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:RegisterEvent("ENCOUNTER_START")
watcher:RegisterEvent("ENCOUNTER_END")
watcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
watcher:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
watcher:RegisterEvent("FACTION_STANDING_CHANGED")
watcher:RegisterEvent("LOOT_READY")
watcher:RegisterEvent("LOOT_OPENED")
watcher:RegisterEvent("LOOT_CLOSED")
watcher:RegisterEvent("PLAYER_MONEY")
watcher:RegisterEvent("PLAYER_LOGOUT")
watcher:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        lastMoney = GetMoney()
        if not scanned then
            scanned = true
            PruneRuns()
            History.DropRetiredCounts()
            C_Timer.After(SCAN_DELAY, function() History.ScanCharacter(0) end)
        end
        -- The run starts once the instance has loaded its data.
        C_Timer.After(2, function()
            if RR.currentRaid and InInstance() then History.CurrentRun(true) end
        end)
    elseif event == "ENCOUNTER_START" then
        History.CurrentRun(true)
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
    elseif event == "LOOT_READY" or event == "LOOT_OPENED" then
        lootOpenUntil = math.huge
    elseif event == "LOOT_CLOSED" then
        lootOpenUntil = GetTime() + LOOT_GRACE
    elseif event == "PLAYER_MONEY" then
        local money = GetMoney()
        local gained = lastMoney and money - lastMoney or 0
        lastMoney = money
        if gained <= 0 or GetTime() > lootOpenUntil or not InInstance() then return end
        local record = History.CurrentRun(true)
        if not record then return end
        record.gold = (record.gold or 0) + gained
        if RR.UI and RR.UI.RunSummaryShown and RR.UI.RunSummaryShown() then RR.UI.Update() end
    elseif event == "PLAYER_LOGOUT" then
        History.ScanReputation()
    end
end)
