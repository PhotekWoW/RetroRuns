-------------------------------------------------------------------------------
-- RetroRuns -- the RetroEngine
-------------------------------------------------------------------------------
-- Tracks where the player is in a raid and decides which routing
-- instruction to display next. Every raid runs on this engine.
-------------------------------------------------------------------------------

local RR = _G.RetroRuns

-------------------------------------------------------------------------------
-- Faction helper
-------------------------------------------------------------------------------

local function CurrentFactionKey()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    if faction == "Horde" then return "Horde" end
    return "Alliance"
end

-------------------------------------------------------------------------------
-- Progress state
-------------------------------------------------------------------------------

-- Namespaces progress storage by routing variant.
-- Keys: "wing:<lfgDungeonID>", "skip", or "standard".
function RR:ActiveVariantKey()
    local raid = self.currentRaid
    if raid and raid.lfrWings and self:IsInLFR() then
        local id = self:GetCurrentLfgDungeonID()
        if id then
            local wing = raid.lfrWings[id]
            if wing then
                if wing.aliasOf then id = wing.aliasOf end
                return "wing:" .. tostring(id)
            end
        end
    end
    if self.state and self.state.activeRouteVariant == "skip"
        and raid and raid.skipRoute then
        return "skip"
    end
    return "standard"
end

-- The steps table for the active variant, under `byVariant`. Legacy bare
-- top-level steps/triggers are not read.
function RR:GetVariantSteps(store, create)
    if not store then return nil end
    local key = self:ActiveVariantKey()
    if create then
        store.byVariant = store.byVariant or {}
        store.byVariant[key] = store.byVariant[key] or { steps = {}, triggers = {} }
        return store.byVariant[key]
    end
    if not store.byVariant then return nil end
    return store.byVariant[key]
end

function RR:GetProgress(stepIndex)
    if not stepIndex then return 1 end
    local store = self.state.progress
    if store and store[stepIndex] then return store[stepIndex] end
    return 1
end

-- The persisted store, keyed [instanceID][faction][lockoutId]. Nil when the
-- lockout isn't readable yet, or no record exists and create is false.
function RR:GetLockoutStore(create)
    if not self.currentRaid or not self.currentRaid.instanceID then return nil end
    local lockoutId = self:GetCurrentLockoutId()
    if not lockoutId then return nil end

    if create then
        RetroRunsDB = RetroRunsDB or {}
        RetroRunsDB.routingProgress = RetroRunsDB.routingProgress or {}
    end
    if not RetroRunsDB or not RetroRunsDB.routingProgress then return nil end

    local instStore = RetroRunsDB.routingProgress[self.currentRaid.instanceID]
    if not instStore then
        if not create then return nil end
        instStore = {}
        RetroRunsDB.routingProgress[self.currentRaid.instanceID] = instStore
    end

    local faction = CurrentFactionKey()
    local factionStore = instStore[faction]
    if not factionStore then
        if not create then return nil end
        factionStore = {}
        instStore[faction] = factionStore
    end

    local lockoutStore = factionStore[lockoutId]
    if not lockoutStore then
        if not create then return nil end
        lockoutStore = { steps = {}, triggers = {} }
        factionStore[lockoutId] = lockoutStore
    end
    return lockoutStore
end

function RR:SetProgress(stepIndex, value)
    if not stepIndex or not value then return end
    self.state.progress = self.state.progress or {}
    self.state.progress[stepIndex] = value

    local store = self:GetLockoutStore(true)
    if not store then return end
    local vstore = self:GetVariantSteps(store, true)
    vstore.steps = vstore.steps or {}
    vstore.steps[stepIndex] = value
end

-- True if a saved routing store exists for the current raid, faction, and
-- lockout -- i.e. the player already loaded a route and committed to this
-- lockout. Used to skip the load dialog on reload and silently restore the
-- route they were running.
function RR:HasPersistedProgressForCurrentLockout()
    return self:GetLockoutStore(false) ~= nil
end

-- Any saved store for this raid + faction, across any lockout. Distinct from
-- HasPersistedProgressForCurrentLockout.
function RR:HasSavedRouteStore()
    if not self.currentRaid or not self.currentRaid.instanceID then return false end
    if not RetroRunsDB or not RetroRunsDB.routingProgress then return false end
    local instStore = RetroRunsDB.routingProgress[self.currentRaid.instanceID]
    if not instStore then return false end
    local factionStore = instStore[CurrentFactionKey()]
    return factionStore ~= nil and next(factionStore) ~= nil
end

-- Persist which route variant ("standard" | "skip") the player loaded, in
-- the current lockout's store. Lets a reload restore the chosen route
-- instead of re-prompting and letting the player switch variants mid-
-- lockout. Written once at load time.
function RR:PersistRouteVariant(variant)
    local store = self:GetLockoutStore(true)
    if not store then
        -- Lockout-less: rides the run record, same as the skips and gates.
        -- No lockout-less instance offers variants today, so this closes the
        -- shape rather than a live defect.
        self.state.activeRouteVariant = variant
        self:PersistRunProgress()
        return
    end
    store.routeVariant = variant
end

-- The route variant ("standard" | "skip") persisted for the current
-- lockout, or nil if none has been saved yet. Read by the load dialog so
-- it can mark the previously-chosen route with a "Continue?" hint when
-- re-prompting before the first kill.
function RR:GetPersistedRouteVariant()
    local store = self:GetLockoutStore(false)
    if store then return store.routeVariant end
    local record = RetroRunsDB and RetroRunsDB.activeRuns
        and self.currentRaid
        and RetroRunsDB.activeRuns[self.currentRaid.journalInstanceID or 0]
    return record and record.routeVariant or nil
end

-- Persist a bypassed optional boss for the current lockout.
--
-- `state.bossesSkipped` alone is not enough. It is runtime-only, and unlike
-- `bossesKilled` -- which a reload rebuilds from the server's saved-instance
-- data -- a skip has no external source to rebuild from, so it silently
-- reverted to "(optional)" on every /reload.
--
-- Kept on the lockout store rather than the per-variant one, the same way
-- routeVariant is: the choice is about a BOSS, and bosses are the same
-- across route variants even where their step numbering is not. The store
-- is keyed by lockout id, so the per-lockout reset comes for free.
function RR:PersistBossSkipped(bossIndex, skipped)
    if not bossIndex then return end
    local store = self:GetLockoutStore(true)
    if not store then
        -- A lockout-less instance (every Normal dungeon) has no store, so the
        -- skip rides the run record instead -- same lifetime as the kills.
        -- Without this the bare return dropped it on the floor and a reload
        -- put the bypassed boss back in front of the player.
        self:PersistRunProgress()
        return
    end
    store.skippedBosses = store.skippedBosses or {}
    store.skippedBosses[bossIndex] = skipped and true or nil
end

-------------------------------------------------------------------------------
-- Run-scoped kill state, for instances the server does not save
-------------------------------------------------------------------------------
-- A Normal 5-man creates no saved instance: every Normal row in
-- MapDifficulty is ResetInterval 0, and leaving destroys the instance. So
-- `bossesKilled` cannot be rebuilt from `GetSavedInstanceInfo` the way a
-- raid's is, and a /reload mid-run lost every kill. The reasoning that gave
-- `PersistBossSkipped` its store applies here one step further: with no
-- external source at all, the kills themselves have to be written down.
--
-- ONE record, because a player is only ever inside one instance. It is
-- cleared on leaving, so a surviving record means the client stopped
-- (reload, logout, crash) while still inside.
-- journalInstanceID as well as instanceID: four wings can share ONE
-- instanceID (Scarlet Monastery of Old), and matching on the instance
-- alone restored the Cathedral's dead bosses onto the Graveyard's rows,
-- which hold different bosses at the same indexes. A record written by a
-- build that stored no wing id simply stops matching, costing one restore.
local function ActiveRunMatchesCurrent(record)
    return record ~= nil
        and RR.currentRaid ~= nil
        and record.instanceID == RR.currentRaid.instanceID
        and record.journalInstanceID == RR.currentRaid.journalInstanceID
        and record.difficultyID == RR.state.currentDifficultyID
end

-- Kills the SERVER knows about in an instance it does not save. A legacy
-- Normal dungeon still runs a scenario: the current step carries the required
-- bosses, and GetBonusSteps() carries the rest, one criterion per boss with
-- its completion. The scenario belongs to the SESSION that walked in, not
-- to the instance: after a relog it is simply absent, and combat does not
-- wake it. Criteria answer only within the session that created
-- the run; at a login they can prove nothing either way.
--
-- Criteria are keyed on a creature id the data does not carry, so the boss is
-- resolved by matching the criterion's description against the client's own
-- localized boss name. Both strings come from Blizzard, so this is not a
-- hand-kept translation and holds in every locale. Where several names match,
-- the longest wins, so "Serpentis" cannot claim "Lord Serpentis"'s criterion.
local MAX_SCENARIO_CRITERIA = 20

-- Walks every criterion the scenario exposes -- the current step's, then
-- each bonus step's. Stops early when the callback returns true.
local function ForEachScenarioCriterion(callback)
    if not C_ScenarioInfo then return end
    if C_ScenarioInfo.GetCriteriaInfo then
        for i = 1, MAX_SCENARIO_CRITERIA do
            local info = C_ScenarioInfo.GetCriteriaInfo(i)
            if not info then break end
            if callback(info) then return end
        end
    end
    if C_Scenario and C_Scenario.GetBonusSteps
        and C_ScenarioInfo.GetCriteriaInfoByStep then
        for _, stepID in ipairs(C_Scenario.GetBonusSteps() or {}) do
            for i = 1, MAX_SCENARIO_CRITERIA do
                local info = C_ScenarioInfo.GetCriteriaInfoByStep(stepID, i)
                if not info then break end
                if callback(info) then return end
            end
        end
    end
end

-- Exposed for the bring-up dump, which lists every live criterion and
-- which boss it binds to.
function RR:ForEachScenarioCriterion(callback)
    return ForEachScenarioCriterion(callback)
end

-- Whether one scenario objective is complete, by criteriaID -- the stable,
-- locale-proof key (descriptions are Blizzard prose and drift even in
-- English: "Golem Lord Argelmach" carries no verb where its siblings say
-- "defeated"). This is SERVER STATE, not an event: it stays true for the
-- rest of the run, which is what lets a trigger on it survive a reload.
-- minQuantity widens the check for COUNTER criteria ("0/5 Shield Generators
-- deactivated"): those read completed only at full count, but a gate can sit
-- on an earlier tick. Still server state -- quantity holds for the rest of
-- the run -- so the reload semantics above are unchanged.
function RR:IsScenarioCriterionComplete(criteriaID, minQuantity)
    local complete = false
    ForEachScenarioCriterion(function(info)
        if info.criteriaID == criteriaID then
            complete = info.completed == true
            if not complete and minQuantity then
                local quantity = tonumber(info.quantity)
                complete = quantity ~= nil and quantity >= minQuantity
            end
            return true
        end
    end)
    return complete
end

function RR:ReadScenarioKills()
    if not self.currentRaid or not C_ScenarioInfo then return nil end
    local bosses = self.currentRaid.bosses
    if not bosses then return nil end

    local function resolveBoss(description)
        if type(description) ~= "string" or description == "" then return nil end
        local bestIndex, bestLength
        for _, boss in ipairs(bosses) do
            local bossName = self:GetLocalizedBossName(boss)
            if bossName and bossName ~= ""
                and description:find(bossName, 1, true) then
                if not bestLength or #bossName > bestLength then
                    bestIndex, bestLength = boss.index, #bossName
                end
            end
        end
        return bestIndex
    end

    -- criteriaID is the stable, locale-proof key. A boss whose criterion
    -- prose does not carry its name declares the id in its data row; the
    -- name match stays for every boss whose prose does.
    local byCriteriaID = {}
    for _, boss in ipairs(bosses) do
        if boss.scenarioCriteriaID then
            byCriteriaID[boss.scenarioCriteriaID] = boss.index
        end
        -- A duo the data carries as one boss can be two objectives.
        for _, criteriaID in ipairs(boss.scenarioCriteriaIDs or {}) do
            byCriteriaID[criteriaID] = boss.index
        end
    end

    local killed, found = {}, false
    local function readCriterion(info)
        if not info then return false end
        if info.completed then
            local bossIndex = byCriteriaID[info.criteriaID]
                or resolveBoss(info.description)
            if bossIndex then
                killed[bossIndex] = true
                found = true
            else
                -- A completed objective matching no boss is either a
                -- non-boss objective or prose that omits the boss name.
                -- The second kind is a data gap, and silence is what let
                -- one hide. Once per id, so the reads cannot flood.
                local seen = self.state.unmatchedCriteriaLogged
                if not seen then
                    seen = {}
                    self.state.unmatchedCriteriaLogged = seen
                end
                if info.criteriaID and not seen[info.criteriaID] then
                    seen[info.criteriaID] = true
                    self:ZoneLog(("scenario criterion %s complete but matched no boss: %q")
                        :format(tostring(info.criteriaID),
                                tostring(info.description)))
                end
            end
        end
        return true
    end

    -- criteriaCount is nil on the step-info table even where criteria
    -- exist, so the iterator ends each walk on the first nil rather than
    -- trusting a count. Bonus bosses live in their OWN steps, keyed by db2
    -- step id, and are invisible to GetCriteriaInfo -- the iterator covers
    -- both.
    ForEachScenarioCriterion(function(info)
        readCriterion(info)
    end)
    if not found then return nil end
    return killed
end

-- The raw shape of the scenario, kept apart from the kill read.
-- ReadScenarioKills collapses "no criteria at all" and "criteria present,
-- none complete" into one nil; this reports both counts so the restore
-- rules can be decided from what the client actually says.
function RR:ReadScenarioCriteriaStats()
    if not C_ScenarioInfo then return nil end
    local stats = { criteriaSeen = 0, criteriaComplete = 0 }
    local scenario = C_ScenarioInfo.GetScenarioInfo
        and C_ScenarioInfo.GetScenarioInfo() or nil
    if scenario then
        stats.scenarioName = scenario.name
        stats.currentStage = scenario.currentStage
        stats.numStages = scenario.numStages
        stats.scenarioComplete = scenario.isComplete
    end
    ForEachScenarioCriterion(function(criterion)
        stats.criteriaSeen = stats.criteriaSeen + 1
        if criterion.completed then
            stats.criteriaComplete = stats.criteriaComplete + 1
        end
    end)
    return stats
end

-- One-line render of those stats for the zone log and the diag dump.
local function DescribeScenarioStats(stats)
    if not stats then return "scenario api unavailable" end
    local header
    if stats.scenarioName then
        header = ("scenario=%q stage=%s/%s complete=%s")
            :format(tostring(stats.scenarioName),
                    tostring(stats.currentStage),
                    tostring(stats.numStages),
                    tostring(stats.scenarioComplete))
    else
        header = "scenario=none"
    end
    return ("%s  criteria=%d seen/%d complete")
        :format(header, stats.criteriaSeen, stats.criteriaComplete)
end

-- Criteria are not always populated the instant the player enters the world,
-- so a load-time read can come back empty on an instance that really does
-- have kills. Same ladder shape as the kill-sync retry, and it stops as soon
-- as the API answers at all -- an answer of "nothing complete" is a real
-- answer, not a not-ready one.
local SCENARIO_RETRY_DELAYS = { 0.5, 1.5, 3.0 }

-- Folds the criteria into the run record. ADDITIVE ONLY: it sets a boss
-- killed and never clears one, so a partial read cannot walk the record
-- backwards. Returns changed, answered.
--
-- Runs under a lockout too. A lockout records encounters, not deaths: a
-- boss that dies before its encounter opens leaves the lockout empty while
-- the scenario criterion still completes, so the criteria are the only
-- witness there as well.
function RR:MergeScenarioKills()
    if self.state.testMode then return false, false end
    if not self.currentRaid then return false, false end
    local killed = self:ReadScenarioKills()
    if not killed then return false, false end
    local changed = false
    for bossIndex in pairs(killed) do
        if not self.state.bossesKilled[bossIndex] then
            self.state.bossesKilled[bossIndex] = true
            changed = true
        end
    end
    return changed, true
end

-- Merges and writes through, for the live paths. A kill can land with no
-- ENCOUNTER_END and no BOSS_KILL behind it, and the criteria are then the
-- only witness the run has.
function RR:ApplyLiveScenarioKills(source)
    if not self:MergeScenarioKills() then return false end
    self:ZoneLog(("scenario-kill merge (%s): marked kill(s) the events missed")
        :format(tostring(source)))
    -- Same follow-up the event path runs after a kill: persist, then move
    -- the route off the boss just recorded.
    self:PersistRunProgress()
    self:ComputeNextStep()
    self:RefreshAll()
    return true
end

function RR:ScheduleScenarioKillRetry()
    if self.state.testMode then return end
    if not self.currentRaid then return end
    local raidKeyAtSchedule = self:GetRaidContextKey()
    local function tick(attempt)
        if not self.currentRaid
            or self:GetRaidContextKey() ~= raidKeyAtSchedule then return end
        local changed, answered = self:MergeScenarioKills()
        self:ZoneLog(("scenario-kill retry %d/%d: answered=%s changed=%s  %s")
            :format(attempt, #SCENARIO_RETRY_DELAYS, tostring(answered),
                    tostring(changed),
                    DescribeScenarioStats(self:ReadScenarioCriteriaStats())))
        if answered then
            if changed then self:RefreshAll() end
            -- Criteria just became readable; scenario-triggered segs can
            -- now be re-derived, covering a reload where the seed ran
            -- before the API had answers.
            self:AdvanceProgress("scenario")
            return
        end
        if attempt < #SCENARIO_RETRY_DELAYS then
            C_Timer.After(SCENARIO_RETRY_DELAYS[attempt + 1],
                function() tick(attempt + 1) end)
        end
    end
    C_Timer.After(SCENARIO_RETRY_DELAYS[1], function() tick(1) end)
end

-- Writes kill state for an instance with no server-side lockout behind it.
-- A no-op where a lockout exists: there the server is the authority and
-- SyncFromSavedRaidInfo already rebuilds from it on load.
function RR:PersistRunProgress()
    if not self.currentRaid or self.state.testMode then return end
    if self:GetCurrentLockoutId() then return end
    RetroRunsDB = RetroRunsDB or {}
    local killed = {}
    for bossIndex in pairs(self.state.bossesKilled or {}) do
        killed[bossIndex] = true
    end
    local partial = {}
    for bossIndex, members in pairs(self.state.bossPartialKills or {}) do
        partial[bossIndex] = {}
        for encID in pairs(members) do
            partial[bossIndex][encID] = true
        end
    end
    -- Fired gates ride the record too. The seeder can re-derive segment
    -- progress from where the player is standing, but it cannot walk past a
    -- trigger-gated seg, and a dialog event can never be replayed -- so
    -- without this a reload drops the route back behind the gate.
    local triggers = {}
    for stepIndex, segs in pairs(self.state.triggersFired or {}) do
        triggers[stepIndex] = {}
        for segIndex in pairs(segs) do
            triggers[stepIndex][segIndex] = true
        end
    end
    -- Bypassed optional bosses ride the record for the same reason the gates
    -- do: nothing external can rebuild a skip, so a reload would offer the
    -- boss again as though the player had never passed on it.
    local skipped = {}
    for bossIndex in pairs(self.state.bossesSkipped or {}) do
        skipped[bossIndex] = true
    end
    -- One slot PER WING, keyed by journalInstanceID. A single shared slot
    -- meant starting any other instance discarded this one's record --
    -- and in Dire Maul, where hopping between three wings mid-run is the
    -- normal way to play, that threw away gates the scenario cannot give
    -- back (a dialog never re-fires).
    RetroRunsDB.activeRuns = RetroRunsDB.activeRuns or {}
    -- The last-seen stamp survives the rewrite -- every kill used to build
    -- a fresh table and silently erase it -- and then refreshes, since a
    -- kill is one moment the player's spot is guaranteed current.
    local previousRecord =
        RetroRunsDB.activeRuns[self.currentRaid.journalInstanceID or 0]
    RetroRunsDB.activeRuns[self.currentRaid.journalInstanceID or 0] = {
        instanceID   = self.currentRaid.instanceID,
        journalInstanceID = self.currentRaid.journalInstanceID,
        difficultyID = self.state.currentDifficultyID,
        killed       = killed,
        partial      = partial,
        triggers     = triggers,
        skipped      = skipped,
        routeVariant = self.state.activeRouteVariant,
        stamp        = time(),
        lastSeen     = previousRecord and previousRecord.lastSeen,
    }
    self:StampLastSeen()
    -- The single-slot record is superseded; drop it so it cannot shadow a
    -- newer per-wing slot on a later read.
    RetroRunsDB.activeRun = nil
    local killedCount, partialCount = 0, 0
    for _ in pairs(killed) do killedCount = killedCount + 1 end
    for _ in pairs(partial) do partialCount = partialCount + 1 end
    self:ZoneLog(("run record written: %d killed, %d partial")
        :format(killedCount, partialCount))
end

-- Drops the CURRENT instance's record (its wing's slot plus the legacy
-- single-slot form). The ResetInstances hook clears the other slots itself,
-- because its rule is different: it keeps whichever instance the player is
-- standing in, since the game refuses to reset that one.
function RR:ClearRunProgress()
    if not RetroRunsDB then return end
    RetroRunsDB.activeRun = nil
    if RetroRunsDB.activeRuns and self.currentRaid then
        RetroRunsDB.activeRuns[self.currentRaid.journalInstanceID or 0] = nil
    end
end

-------------------------------------------------------------------------------
-- Instance-per-hour tracking
-------------------------------------------------------------------------------
-- The game allows 10 instance entries per account per hour and reports the
-- count nowhere -- the only client-visible artifact is the refusal message
-- once the cap is already hit. So the addon keeps its own book: one entry
-- per spawned instance,
-- keyed by character, instance and difficulty plus a generation counter
-- that advances on every reset. Walking back into a still-living
-- instance touches its existing entry; only a reset (or a genuinely new
-- spawn) opens a new one. Entries age out an hour after last contact. The
-- count is approximate and errs toward counting, which warns early rather
-- than late.
local INSTANCE_HISTORY_LIMIT  = 10
local INSTANCE_HISTORY_WINDOW = 60 * 60
-- How long an empty non-saved instance is assumed to survive before the
-- server drops it. A return after a longer gap is a new spawn. Approximate,
-- and short on purpose: overcounting warns early, undercounting warns late.
local INSTANCE_EMPTY_TIMEOUT  = 30 * 60

function RR:TrackInstanceEntry(info)
    if self.state.testMode then
        self:ZoneLog("instance history: skipped (test mode)")
        return
    end
    info = info or self:GetCurrentInstanceInfo()
    if info.instanceType ~= "party" and info.instanceType ~= "raid" then return end
    RetroRunsDB = RetroRunsDB or {}
    RetroRunsDB.instanceHistory = RetroRunsDB.instanceHistory or {}
    RetroRunsDB.instanceLastSpawn = RetroRunsDB.instanceLastSpawn or {}
    local now = time()
    local player = (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
    local instanceKey = player .. ":" .. tostring(info.instanceID)
    local spawnKey = ("%s:%s:%d"):format(instanceKey,
        tostring(info.difficultyID), RetroRunsDB.instanceHistoryGen or 1)

    -- The same spawn only while it is the LAST one used for this instance:
    -- changing difficulty resets a non-saved instance, so Heroic, Normal,
    -- Heroic again is three spawns under two keys. A long empty gap is a
    -- new spawn too.
    local entry = RetroRunsDB.instanceHistory[spawnKey]
    local idleGap = entry and (now - (entry.last or entry.create or now)) or 0
    local sameSpawn = entry
        and RetroRunsDB.instanceLastSpawn[instanceKey] == spawnKey
        and idleGap <= INSTANCE_EMPTY_TIMEOUT
    if not sameSpawn then
        if entry then spawnKey = spawnKey .. "@" .. now end
        entry = { create = now }
        RetroRunsDB.instanceHistory[spawnKey] = entry
        local liveCount = self:GetInstanceUseCount()
        self:ZoneLog(("instance history: new slot, %d live"):format(liveCount))
    end
    RetroRunsDB.instanceLastSpawn[instanceKey] = spawnKey
    entry.last = now
end

-- ResetInstances cannot touch the instance the player is standing in, so a
-- reset called inside defers the key change until the player leaves.
function RR:AdvanceInstanceGeneration()
    RetroRunsDB = RetroRunsDB or {}
    RetroRunsDB.instanceHistoryGenPending = true
    local info = self:GetCurrentInstanceInfo()
    if info.instanceType ~= "party" and info.instanceType ~= "raid" then
        self:ApplyPendingInstanceGeneration()
    end
end

function RR:ApplyPendingInstanceGeneration()
    if not (RetroRunsDB and RetroRunsDB.instanceHistoryGenPending) then return end
    RetroRunsDB.instanceHistoryGenPending = nil
    RetroRunsDB.instanceHistoryGen = (RetroRunsDB.instanceHistoryGen or 1) + 1
    self:ZoneLog("instance history: generation advanced")
end

-- Live count against the hourly cap and seconds until the oldest slot
-- frees. Reaps expired entries as it counts.
function RR:GetInstanceUseCount()
    local history = RetroRunsDB and RetroRunsDB.instanceHistory
    if not history then return 0, nil, INSTANCE_HISTORY_LIMIT end
    local now = time()
    local liveCount, oldestTouch = 0, nil
    for key, entry in pairs(history) do
        local lastTouch = entry.last or entry.create or 0
        if now > lastTouch + INSTANCE_HISTORY_WINDOW then
            history[key] = nil
        else
            liveCount = liveCount + 1
            if not oldestTouch or lastTouch < oldestTouch then
                oldestTouch = lastTouch
            end
        end
    end
    local secondsUntilFree = oldestTouch
        and (oldestTouch + INSTANCE_HISTORY_WINDOW - now) or nil
    return liveCount, secondsUntilFree, INSTANCE_HISTORY_LIMIT
end

-- The stored run belongs to an instantiation that no longer exists, proven
-- by an encounter starting on a boss the record holds dead. A COMPLETED run
-- resets silently: there is nothing in it worth resuming, and the live
-- instance is authoritative that every boss is alive. A partial run only
-- logs.
function RR:HandleStaleRunRecord()
    local complete = self.IsActiveRouteComplete and self:IsActiveRouteComplete()
    self:ZoneLog(("stale run record: complete=%s"):format(tostring(complete)))
    if not complete then return end
    self:ClearRunProgress()
    -- Re-run the zone resolution as if this were first entry: it wipes the
    -- in-memory kill state, finds no record to restore, and reloads fresh.
    self.state.lastSeenRaidKey = nil
    self:HandleLocationChange()
end

-- Restores kills for a lockout-less instance. `sameSession` is true for a
-- /reload, where the client never left and the instance is provably the one
-- we were in, so the record is taken as-is.
--
-- Expiry is event-based, not a timer. A rolling time window has no basis:
-- one expired a correct record while the player was standing in the very
-- instance it described. Nothing in the client reports whether a lockout-less instance still
-- exists -- scenario criteria reset on re-entry, so they cannot answer it
-- either -- so the only honest bounds are events we can actually observe:
--
--   * the player calls ResetInstances -- hooked, clears the record outright
--   * a DAILY RESET passes -- no dungeon instance survives one
--
-- Between those, the record stands. The error direction is deliberate and
-- matches the loot-row color ruling: wrongly showing a boss dead costs a
-- walk and self-corrects on the kill, while wrongly wiping the record
-- destroys a real run that cannot be re-killed back into existence.
local function DailyResetPassedSince(stamp)
    if not stamp then return true end
    local api = C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset
    if not api then return false end   -- unavailable: trust the record
    local untilReset = api()
    if not untilReset or untilReset <= 0 then return false end
    local lastReset = time() + untilReset - (24 * 60 * 60)
    return stamp < lastReset
end

-- Where the client put us at login, against where the record says the
-- player logged out. A preserved instance keeps the player's spot; a
-- reset one is a NEW instance that spawns them at its entrance -- so
-- relocation is proof of a reset the scenario cannot give. Player
-- coordinates do not exist inside
-- instances, so the spot is the FLOOR plus the zone text -- which also
-- sets the resolution floor: a logout standing in the entrance's own
-- subzone cannot tell a reset from a preserved instance, and that one
-- case falls back to the first-pull correction.
local function LoginPositionVerdict(record)
    if not record or not record.lastSeen then return nil, "no stamp" end
    local mapID = C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")
    if not mapID then return nil, "no map" end
    local subZone = GetSubZoneText() or ""
    local minimap = GetMinimapZoneText() or ""
    local stamp = record.lastSeen
    local detail = ("login=%d %q/%q logout=%d %q/%q"):format(
        mapID, subZone, minimap,
        stamp.mapID or 0, stamp.subZone or "", stamp.minimap or "")
    -- Empty zone text is the unsettled login read, not an answer; the
    -- deferred recheck gets the settled strings.
    if subZone == "" and minimap == "" then return nil, detail end
    -- With real zone text in hand, a different floor or different zone
    -- strings mean the client did not put us back where we logged out:
    -- the old instance is gone.
    if mapID ~= stamp.mapID then return true, detail end
    if subZone == (stamp.subZone or "")
        and minimap == (stamp.minimap or "") then
        return false, detail
    end
    return true, detail
end

-- Writes the player's spot into the wing's record: the LAST-SEEN stamp.
-- Called on every location change, on every persist, and at
-- PLAYER_LOGOUT, so the record always carries the last spot the player
-- was seen and the login comparison never depends on a logout event
-- firing (the overnight 08-31 test showed the logout-only stamp arriving
-- empty). Empty zone text is the unsettled read and never stamps; a map
-- outside the raid's own floors is the player leaving and never stamps
-- either.
function RR:StampLastSeen()
    if not self.currentRaid or self.state.testMode then return end
    -- Never inside the login settle window: the restore and its deferred
    -- recheck must read the PREVIOUS session's stamp, and the login-time
    -- persist would otherwise overwrite it with the login spot first.
    if self.state.loginSettleUntil
        and GetTime() < self.state.loginSettleUntil then
        return
    end
    if self:GetCurrentLockoutId() then return end
    local record = RetroRunsDB and RetroRunsDB.activeRuns
        and RetroRunsDB.activeRuns[self.currentRaid.journalInstanceID or 0]
    if not record then return end
    local mapID = C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")
    if not mapID then return end
    local raidMaps = self.currentRaid.maps
    if raidMaps and not raidMaps[mapID] then return end
    local subZone = GetSubZoneText() or ""
    local minimap = GetMinimapZoneText() or ""
    if subZone == "" and minimap == "" then return end
    record.lastSeen = {
        mapID   = mapID,
        subZone = subZone,
        minimap = minimap,
    }
end

-- A login whose position could not be read yet gets one deferred look:
-- if the settled position then proves relocation, the applied record was
-- a reset instance's ghost and the context restarts fresh.
function RR:ScheduleLoginPositionRecheck()
    C_Timer.After(3.0, function()
        if not self.currentRaid or self.state.testMode then return end
        if self:GetCurrentLockoutId() then return end
        local record = RetroRunsDB and RetroRunsDB.activeRuns
            and RetroRunsDB.activeRuns[self.currentRaid.journalInstanceID or 0]
        local verdict, detail = LoginPositionVerdict(record)
        self:ZoneLog(("login position recheck: verdict=%s  %s"):format(
            verdict == nil and "inconclusive" or tostring(verdict),
            tostring(detail)))
        if verdict ~= true then return end
        wipe(self.state.bossesKilled)
        wipe(self.state.bossPartialKills)
        wipe(self.state.triggersFired)
        self:ClearRunProgress()
        self.state.lastSeenRaidKey = nil
        self:HandleLocationChange()
    end)
end

function RR:RestoreRunProgress(sameSession)
    if self.state.testMode then return false end
    if not self.currentRaid then return false end
    if self:GetCurrentLockoutId() then return false end

    -- Server truth first. A criterion reported complete proves both the kill
    -- and that this instance was never reset, so the stored record is taken
    -- as valid alongside it however old it is.
    local scenarioKills = self:ReadScenarioKills()
    local scenarioStats = self:ReadScenarioCriteriaStats()
    local loginRestore = not sameSession
        and self.state.loginSettleUntil ~= nil
        and GetTime() < self.state.loginSettleUntil
    local restored = 0
    if scenarioKills then
        for bossIndex in pairs(scenarioKills) do
            self.state.bossesKilled[bossIndex] = true
            restored = restored + 1
        end
    end

    -- The wing's own slot first; the legacy single slot only as a
    -- migration fallback, and ActiveRunMatchesCurrent still validates
    -- whichever one is read.
    local record = RetroRunsDB and RetroRunsDB.activeRuns
        and RetroRunsDB.activeRuns[self.currentRaid.journalInstanceID or 0]
    if not record then
        record = RetroRunsDB and RetroRunsDB.activeRun
    end
    local recordStatus = "none"
    local restoredGates = 0
    if ActiveRunMatchesCurrent(record) then
        -- A running scenario whose criteria are present with none complete
        -- is the server saying nothing has happened here: the instance is
        -- fresh whatever the record claims, so the record is discarded and
        -- the run starts over. A fresh entry reports its criteria on the
        -- first read; a finished run's scenario vanishes outright.
        --
        -- A CLEARED instance the player walks back into does not always
        -- vanish its scenario, so the criteria counts alone cannot carry
        -- this: a finished scenario can also stay. In Ragefire Chasm it
        -- stayed, kept all four criteria visible and reset them to
        -- incomplete, which reads identically to a fresh entry on every
        -- count. isComplete is what separates them -- a fresh entry reports
        -- stage 1/1 not complete, a cleared one stage 1/0 complete -- and a
        -- scenario declaring itself complete is the opposite of a fresh
        -- instance whatever its criteria say.
        local freshInstance = not sameSession
            and scenarioStats ~= nil
            and not scenarioStats.scenarioComplete
            and scenarioStats.criteriaSeen > 0
            and scenarioStats.criteriaComplete == 0
        -- A passed daily reset still refuses a record on its own, covering
        -- an instance whose scenario never answered. Refused means IGNORED,
        -- never deleted -- criteria can arrive late, and a later pass must
        -- still find the record intact.
        local unproven = not sameSession and not scenarioKills
            and DailyResetPassedSince(record.stamp)
        -- The login position check: relocation proves a reset outright,
        -- a matching spot confirms the instance held, and anything else
        -- decides nothing (the deferred recheck below covers it).
        local relocated = nil
        if loginRestore and not scenarioKills then
            local verdict, detail = LoginPositionVerdict(record)
            relocated = verdict
            self:ZoneLog(("login position check: verdict=%s  %s"):format(
                verdict == nil and "inconclusive" or tostring(verdict),
                tostring(detail)))
        end
        if freshInstance then
            recordStatus = "discarded (fresh instance)"
            self:ClearRunProgress()
        elseif relocated == true then
            recordStatus = "discarded (relocated at login)"
            self:ClearRunProgress()
        elseif unproven then
            recordStatus = "ignored (daily reset passed)"
        else
            recordStatus = "applied"
            if relocated == nil and loginRestore and not scenarioKills then
                self:ScheduleLoginPositionRecheck()
            end
            for bossIndex in pairs(record.killed or {}) do
                if not self.state.bossesKilled[bossIndex] then
                    self.state.bossesKilled[bossIndex] = true
                    restored = restored + 1
                end
            end
            -- Gates that already fired come back before the seeder runs,
            -- so it can walk past them instead of stalling at the ceiling.
            for stepIndex, segs in pairs(record.triggers or {}) do
                self.state.triggersFired = self.state.triggersFired or {}
                self.state.triggersFired[stepIndex] =
                    self.state.triggersFired[stepIndex] or {}
                for segIndex in pairs(segs) do
                    self.state.triggersFired[stepIndex][segIndex] = true
                    restoredGates = restoredGates + 1
                end
            end
            if record.routeVariant then
                self.state.activeRouteVariant = record.routeVariant
            end
            -- Bypassed optional bosses come back too, so the route does
            -- not re-offer a boss the player already passed on.
            self.state.bossesSkipped = self.state.bossesSkipped or {}
            for bossIndex in pairs(record.skipped or {}) do
                self.state.bossesSkipped[bossIndex] = true
            end
            -- Partial multi-encounter kills (two of the four dragons) come
            -- back with the record; a full member set never reaches here
            -- because completion folded it into `killed` at mark time.
            for bossIndex, members in pairs(record.partial or {}) do
                if not self.state.bossesKilled[bossIndex] then
                    local mine = self.state.bossPartialKills[bossIndex] or {}
                    for encID in pairs(members) do mine[encID] = true end
                    self.state.bossPartialKills[bossIndex] = mine
                end
            end
            -- A finished run in a preserved instance restores like any
            -- other record: its scenario vanished with the last kill, so an
            -- empty read contradicts nothing and the bosses really are
            -- dead. A finished record in a genuinely fresh instance is
            -- refused by the criteria check above; where the scenario never
            -- answers, HandleStaleRunRecord clears it on the first pull.
            --
            -- A real login gets the same trust, and deliberately so: a
            -- relogged instance runs no scenario at all, so proof can never
            -- arrive there. The record applies; a reset instance corrects on
            -- the first pull, where an encounter starting on a
            -- recorded-dead boss proves the reset.
        end
    end
    local scenarioCount = 0
    if scenarioKills then
        for _ in pairs(scenarioKills) do scenarioCount = scenarioCount + 1 end
    end
    self:ZoneLog(("run-record restore: sameSession=%s scenario=%s record=%s restored=%d gates=%d  %s")
        :format(tostring(sameSession or false),
                scenarioKills and tostring(scenarioCount) or "none",
                recordStatus, restored, restoredGates,
                DescribeScenarioStats(scenarioStats)))
    return restored > 0
end

function RR:RestorePersistedProgress()
    -- Record which variant the in-memory progress now reflects, so a later
    -- variant change (e.g. walking from one LFR wing into another without a
    -- raid reload) can detect the mismatch and reload the right namespace.
    self.state.progressVariantKey = self:ActiveVariantKey()
    local store = self:GetLockoutStore(false)
    if not store then
        -- A lockout-less instance has no store to rebuild from: its segment
        -- progress and fired gates come from the RUN RECORD, applied moments
        -- before this runs, so nothing here may reset them.
        self.state.progress      = self.state.progress or {}
        self.state.triggersFired = self.state.triggersFired or {}
        self.state.bossesSkipped = self.state.bossesSkipped or {}
        return
    end
    self.state.progress       = {}
    self.state.triggersFired  = {}
    local vstore = self:GetVariantSteps(store, false)
    if vstore then
        if vstore.steps then
            for stepIndex, p in pairs(vstore.steps) do
                self.state.progress[stepIndex] = p
            end
        end
        if vstore.triggers then
            for stepIndex, segs in pairs(vstore.triggers) do
                self.state.triggersFired[stepIndex] = {}
                for segIndex, fired in pairs(segs) do
                    if fired then
                        self.state.triggersFired[stepIndex][segIndex] = true
                    end
                end
            end
        end
    end
    -- Restore the route variant chosen at load time so a reload follows
    -- the same route (skip or standard) the player was running.
    if store.routeVariant then
        self.state.activeRouteVariant = store.routeVariant
    end
    -- Bypassed optional bosses, so a reload does not quietly put a skipped
    -- boss back in front of the player.
    self.state.bossesSkipped = self.state.bossesSkipped or {}
    wipe(self.state.bossesSkipped)
    if store.skippedBosses then
        for bossIndex, isSkipped in pairs(store.skippedBosses) do
            if isSkipped then self.state.bossesSkipped[bossIndex] = true end
        end
    end
end

-- Records that a gate event (NPC dialog, etc.) fired this lockout. Lets the
-- seeder skip past gates whose triggers already happened on relog --
-- the addon can't replay dialog events.
function RR:RecordTriggerFired(stepIndex, segIndex)
    if not stepIndex or not segIndex then return end
    self.state.triggersFired = self.state.triggersFired or {}
    self.state.triggersFired[stepIndex] =
        self.state.triggersFired[stepIndex] or {}
    self.state.triggersFired[stepIndex][segIndex] = true

    -- A lockout-less instance (every Normal dungeon) has no lockout store,
    -- so the gate rides the run record instead -- same lifetime as the kills.
    local store = self:GetLockoutStore(true)
    if not store then
        self:PersistRunProgress()
        return
    end
    local vstore = self:GetVariantSteps(store, true)
    vstore.triggers = vstore.triggers or {}
    vstore.triggers[stepIndex] = vstore.triggers[stepIndex] or {}
    vstore.triggers[stepIndex][segIndex] = true
end

function RR:HasTriggerFired(stepIndex, segIndex)
    if not stepIndex or not segIndex then return false end
    local stepTriggers = self.state.triggersFired
        and self.state.triggersFired[stepIndex]
    return stepTriggers and stepTriggers[segIndex] == true
end

-------------------------------------------------------------------------------
-- Match predicates
-------------------------------------------------------------------------------

local function SegMapID(seg)
    return seg and seg.when and seg.when.mapID
end

local function SegWhenSubZone(seg)
    if not seg or not seg.when then return nil end
    return seg.when.subZone
end

-- Separates alternate localized forms of one gate value, e.g.
-- "Kammer des Mondes|Die Kammer des Mondes".
local GATE_ALTERNATE_SEPARATOR = "|"

-- True when liveSubZone is the gate's authored English or a localized form
-- the active locale lists.
local function GateSubZoneMatches(gateSubZone, liveSubZone)
    if not gateSubZone then return true end
    if gateSubZone == liveSubZone then return true end
    local localizedGate = RR and RR.L and RR.L[gateSubZone]
    if not localizedGate or localizedGate == gateSubZone then
        return false
    end
    if localizedGate == liveSubZone then return true end
    if not string.find(localizedGate, GATE_ALTERNATE_SEPARATOR, 1, true) then
        return false
    end
    for alternate in string.gmatch(localizedGate, "[^" ..
            GATE_ALTERNATE_SEPARATOR .. "]+") do
        if alternate == liveSubZone then return true end
    end
    return false
end

local function WhenMatches(seg, mapID, subZone)
    local segMapID = SegMapID(seg)
    if not segMapID then return false end
    if segMapID ~= mapID then return false end
    return GateSubZoneMatches(SegWhenSubZone(seg), subZone)
end

-- True when ANY of the step's segments location-matches the player.
-- Public: step selection uses this for the optional-step cede rule
-- (a step flagged `optional` yields to a later step once the player's
-- position matches the later step and no longer matches this one).
function RR:StepLocationMatches(step, mapID, subZone)
    if not step or not step.segments or not mapID then return false end
    for _, seg in ipairs(step.segments) do
        if WhenMatches(seg, mapID, subZone) then return true end
    end
    return false
end

local function AfterSatisfied(seg, currentProgress)
    if not seg or not seg.after then return true end
    for _, prereqIdx in ipairs(seg.after) do
        if prereqIdx >= currentProgress then return false end
    end
    return true
end

-- Blizzard's localized strings mix both apostrophe glyphs for the same name.
local function FoldApostrophes(text)
    return (string.gsub(text, "\226\128\153", "'"))
end

-- triggeredBy.dialog matches an NPC dialog event's npc + text.
-- triggeredBy.scenario is a STATE CHECK, not an event match: it passes on
-- ANY event once the scenario criterion reads complete, because the
-- completion persists server-side and an event-only match would strand a
-- player who reloaded after the objective.
-- triggeredBy.encounter matches a successful ENCOUNTER_END's
-- dungeonEncounterID. Prefer the encounter form where both would work.
local function TriggerMatches(seg, event, eventData)
    if not seg or not seg.triggeredBy then return true end

    if seg.triggeredBy.encounter then
        if event ~= "encounter-end" then return false end
        if not eventData then return false end
        return eventData.encounterID == seg.triggeredBy.encounter
    end

    if seg.triggeredBy.scenario then
        return RR:IsScenarioCriterionComplete(seg.triggeredBy.scenario,
            seg.triggeredBy.quantity)
    end

    if seg.triggeredBy.dialog then
        if event ~= "npc-dialog" then return false end
        if not eventData then return false end
        local dialogTrigger = seg.triggeredBy.dialog
        -- npc is optional; without it the trigger matches on text alone.
        if dialogTrigger.npc and eventData.npc ~= dialogTrigger.npc then
            -- Sender names arrive localized. Compared case-insensitively.
            local localizedNpc = RR and RR.L and RR.L[dialogTrigger.npc]
            if not (localizedNpc and localizedNpc ~= dialogTrigger.npc
                    and eventData.npc ~= nil
                    and string.lower(FoldApostrophes(localizedNpc))
                        == string.lower(FoldApostrophes(eventData.npc))) then
                return false
            end
        end
        if not dialogTrigger.match or not eventData.text then return false end
        -- Only the boolean result is used, so folding the haystack is safe;
        -- no caller reads the returned position.
        local spokenLine = FoldApostrophes(eventData.text)
        if string.find(spokenLine, FoldApostrophes(dialogTrigger.match),
                       1, true) then
            return true
        end
        -- The spoken line also arrives in the client's language; the locale
        -- table maps the authored English fragment to a fragment of the
        -- localized line, matched the same way.
        local localizedMatch = RR and RR.L and RR.L[dialogTrigger.match]
        return localizedMatch ~= nil
            and localizedMatch ~= dialogTrigger.match
            and string.find(spokenLine, FoldApostrophes(localizedMatch),
                            1, true) ~= nil
    end

    return false
end

-- "Has the player left this seg?": the test that powers stay-here.
-- For subZone-gated segs, only subZone change counts as leaving (mapID
-- can flicker without the player having actually moved).
local function HasLeft(seg, mapID, subZone)
    if not seg then return true end
    local gateSubZone = SegWhenSubZone(seg)
    if gateSubZone then
        return not GateSubZoneMatches(gateSubZone, subZone)
    end
    local segMapID = SegMapID(seg)
    if not segMapID then return true end
    return mapID ~= segMapID
end

-------------------------------------------------------------------------------
-- Advance rule
-------------------------------------------------------------------------------

-- Walks from progress+1, advancing through segs whose conditions hold.
-- Stops after landing on the second noted seg so the player sees one
-- panel-text transition per event. Noteless segs chain freely.
local function ComputeAdvancedProgress(segments, progress, state, event, eventData, stepIndex)
    if not segments then return progress end
    local segCount = #segments
    if progress >= segCount then return progress end

    -- Stay-here: don't release the current seg until the player has
    -- actually moved off it. NPC dialogue gets a conditional bypass
    -- when the dialogue belongs to a gate the player is crossing.
    if progress >= 1 and segments[progress] then
        local progressSeg = segments[progress]
        if not HasLeft(progressSeg, state.mapID, state.subZone) then
            -- Moved-deeper: the current seg's bare-mapID predicate still
            -- matches but a later seg on the same mapID has a narrower
            -- subZone gate that just became true. Player has moved forward
            -- into the narrower seg's scope; release stay-here.
            local movedDeeper = false
            if not SegWhenSubZone(progressSeg) then
                local progressMapID = SegMapID(progressSeg)
                if progressMapID then
                    for laterIdx = progress + 1, segCount do
                        local laterSeg = segments[laterIdx]
                        if laterSeg
                            and SegMapID(laterSeg) == progressMapID
                            and SegWhenSubZone(laterSeg)
                            and WhenMatches(laterSeg, state.mapID, state.subZone)
                        then
                            movedDeeper = true
                            break
                        end
                    end
                end
            end

            if not movedDeeper then
                local gatePasses = false
                if event == "npc-dialog" then
                    if not progressSeg.triggeredBy then
                        gatePasses = true
                    elseif TriggerMatches(progressSeg, event, eventData) then
                        gatePasses = true
                    elseif stepIndex and RR:HasTriggerFired(stepIndex, progress) then
                        gatePasses = true
                    end
                elseif event == "encounter-end" then
                    -- Narrower than the dialog case: only a seg declaring a
                    -- matching encounter trigger releases stay-here.
                    local nextSeg = segments[progress + 1]
                    if nextSeg and nextSeg.triggeredBy
                        and nextSeg.triggeredBy.encounter
                        and TriggerMatches(nextSeg, event, eventData)
                    then
                        gatePasses = true
                    end
                elseif event == "scenario" then
                    -- Same narrow shape: a player at the objective has not
                    -- moved, so the completion itself must release
                    -- stay-here -- but only onto a seg that declares it.
                    local nextSeg = segments[progress + 1]
                    if nextSeg and nextSeg.triggeredBy
                        and nextSeg.triggeredBy.scenario
                        and TriggerMatches(nextSeg, event, eventData)
                    then
                        gatePasses = true
                    end
                end
                if not gatePasses then
                    return progress
                end
            end
        end
    end

    local advancedPastNoted = false
    local segIndex = progress + 1
    while segIndex <= segCount do
        local seg = segments[segIndex]
        if not seg then break end

        if not WhenMatches(seg, state.mapID, state.subZone) then break end
        if not AfterSatisfied(seg, segIndex) then break end
        if not TriggerMatches(seg, event, eventData) then break end

        if seg.note and advancedPastNoted then break end

        progress = segIndex
        if seg.note then advancedPastNoted = true end
        segIndex = segIndex + 1
    end

    return progress
end

-- event: "zone" | "heartbeat" | "npc-dialog" | "step-transition" | "pew"
function RR:AdvanceProgress(event, eventData)
    local step = self.state.activeStep
    if not step or not step.segments then return false end
    local stepIndex = step.step or step.priority or 0
    if stepIndex == 0 then return false end

    local mapID = (C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")) or nil
    local subZone = (GetSubZoneText and GetSubZoneText()) or ""
    local state = { mapID = mapID, subZone = subZone }

    local oldProgress = self:GetProgress(stepIndex)
    local newProgress = ComputeAdvancedProgress(step.segments, oldProgress, state, event, eventData, stepIndex)

    if newProgress ~= oldProgress then
        local prefix = "[RetroEngine]"
        if self.ZoneLog then
            self:ZoneLog(("%s advance: step %d progress %d -> %d (event=%s mapID=%s subZone=%q)")
                :format(prefix, stepIndex, oldProgress, newProgress,
                        tostring(event), tostring(mapID), tostring(subZone)))
        end
        self:SetProgress(stepIndex, newProgress)

        -- Record any gates crossed by this advance.
        for i = oldProgress + 1, newProgress do
            local seg = step.segments[i]
            if seg and seg.triggeredBy then
                self:RecordTriggerFired(stepIndex, i)
                if self.ZoneLog then
                    self:ZoneLog(("%s trigger fired: step %d seg %d")
                        :format(prefix, stepIndex, i))
                end
            end
        end
        return true
    end

    return false
end

-------------------------------------------------------------------------------
-- Current-derivation rule
-------------------------------------------------------------------------------

-- Returns the seg to display. Walks from progress down to 1, picking the
-- highest noted seg whose location matches the player. This is what makes
-- backtrack work: walking back changes `current` without touching progress.
local function ComputeCurrentSeg(segments, progress, state)
    if not segments or #segments == 0 then return nil end
    if progress > #segments then progress = #segments end

    for i = progress, 1, -1 do
        local seg = segments[i]
        if seg and seg.note and WhenMatches(seg, state.mapID, state.subZone) then
            return seg, i
        end
    end

    -- Sticky fallback: during brief transit windows, no seg may match
    -- the player's exact state. Return the latest noted seg anyway so
    -- the panel keeps a meaningful instruction instead of flashing the
    -- default text.
    for i = progress, 1, -1 do
        local seg = segments[i]
        if seg and seg.note then return seg, i end
    end

    return segments[progress], progress
end

function RR:PickNoteSeg(step, playerMapID)
    if not step or not step.segments then return nil end
    local stepIndex = step.step or step.priority or 0
    local progress = self:GetProgress(stepIndex)
    local mapID = playerMapID or (C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")) or nil
    local subZone = (GetSubZoneText and GetSubZoneText()) or ""
    local state = { mapID = mapID, subZone = subZone }
    local seg, segIdx = ComputeCurrentSeg(step.segments, progress, state)

    -- One entry per backward-derivation transition. The
    -- noteless-POI-over-noted-path shape is suppressed as normal.
    if segIdx and segIdx < progress and self.ZoneLog then
        self.state = self.state or {}
        self.state.backtraceLastCurrent = self.state.backtraceLastCurrent or {}
        local last = self.state.backtraceLastCurrent[stepIndex]
        local segAtProgress = step.segments[progress]
        local isExpectedPOIBacktrace =
            segAtProgress
            and segAtProgress.kind == "poi"
            and not segAtProgress.note
        if (last == nil or last >= progress) and not isExpectedPOIBacktrace then
            local prefix = "[RetroEngine]"
            self:ZoneLog(("%s backtrace: step %d current %d < progress %d (mapID=%s subZone=%q)")
                :format(prefix, stepIndex, segIdx, progress,
                        tostring(state.mapID or "nil"), state.subZone or ""))
        end
        self.state.backtraceLastCurrent[stepIndex] = segIdx
    elseif segIdx then
        self.state = self.state or {}
        self.state.backtraceLastCurrent = self.state.backtraceLastCurrent or {}
        self.state.backtraceLastCurrent[stepIndex] = segIdx
    end

    return seg
end

-- Which authored string a segment shows, before localization.
--
-- A step that follows an optional boss is read from two different places: the
-- player who killed the boss stands at it, the player who bypassed it stands
-- where the bypass left them. `skipNote` / `skipMinNote` carry the wording for
-- the second, and `skipWhenBoss` names the boss whose bypass selects them.
-- The base string is always authored and is what every other reader (the
-- noted-seg tests, the route linter) still sees.
local SKIP_VARIANT_FIELD = { note = "skipNote", minNote = "skipMinNote" }

function RR:ResolveSegNote(seg, field)
    if not seg or not field then return nil end
    local base = seg[field]
    local variantField = SKIP_VARIANT_FIELD[field]
    if not variantField then return base end
    local variant = seg[variantField]
    if not variant or variant == "" then return base end
    if not seg.skipWhenBoss then return base end
    if not self:IsBossSkipped(seg.skipWhenBoss) then return base end
    return variant
end

-- The line a segment draws right now. `skipPoints` is the wording fields'
-- counterpart: the bypass route is a different path, not just different
-- prose, so the two readers need different geometry as well.
function RR:ResolveSegPoints(seg)
    if not seg then return nil end
    local base = seg.points
    local variant = seg.skipPoints
    if not variant or #variant == 0 then return base end
    if not seg.skipWhenBoss then return base end
    if not self:IsBossSkipped(seg.skipWhenBoss) then return base end
    return variant
end

-- The minimized bar's short instruction, from the same seg derivation the
-- travel pane uses. Nil keeps the full wordmark.
function RR:GetActiveMinNote()
    local step = self.state and self.state.activeStep
    if not step then return nil end
    local seg = self:PickNoteSeg(step)
    local minNote = self:ResolveSegNote(seg, "minNote")
    if minNote and minNote ~= "" then
        -- Resolved through the locale table at the source so every consumer
        -- (bar body, layout measuring) sees the same translated text.
        return RR.L[minNote]
    end
    return nil
end

-- The active route's exit note, localized. An LFR wing uses its own note or
-- the generic tool line. Nil when nothing is authored.
function RR:GetActiveExitNote()
    local activeWing = self:GetActiveWing()
    if activeWing then
        return RR.L[activeWing.exitNote or "Leave instance group via LFG tool."]
    end
    local raid = self.currentRaid
    if raid and raid.exitNote and raid.exitNote ~= "" then
        return RR.L[raid.exitNote]
    end
    return nil
end

-- A standalone line for a boss the route never visits, so a player reading
-- the exit note learns what is still owed there. Two wordings: one naming
-- how many appearances remain, one for a character who has them all. The
-- boss is named by `exitNoteExtraBoss` (a bosses[] index). It renders in
-- its own field under the exit note rather than joining that sentence.
function RR:GetExitNoteExtra()
    local raid = self.currentRaid
    if not raid or not raid.exitNoteExtraBoss then return nil end
    local boss = raid.bosses and raid.bosses[raid.exitNoteExtraBoss]
    if not boss then return nil end
    -- The browser owns the collection maths; UI.lua exposes it. Absent
    -- (data files loaded without the UI), the line is simply skipped.
    if not self.BossAppearancesStillNeeded then return nil end
    local needed = self:BossAppearancesStillNeeded(boss)
    -- Nothing countable there for this character -- say nothing at all
    -- rather than claiming a complete collection.
    if not needed then return nil end
    if needed > 0 then
        if not raid.exitNoteExtra then return nil end
        return (RR.L[raid.exitNoteExtra]):format(needed)
    end
    if not raid.exitNoteExtraDone then return nil end
    return RR.L[raid.exitNoteExtraDone]
end

-- Short exit line for the minimized bar. Same selection as
-- GetActiveExitNote, but never nil.
function RR:GetActiveMinExitNote()
    local activeWing = self:GetActiveWing()
    if activeWing then
        return RR.L[activeWing.minExitNote or "Leave via LFG Tool"]
    end
    local raid = self.currentRaid
    if raid and raid.minExitNote and raid.minExitNote ~= "" then
        return RR.L[raid.minExitNote]
    end
    return RR.L["No shortcut available"]
end

-------------------------------------------------------------------------------
-- Line picker
-------------------------------------------------------------------------------

-- Returns every seg on the visible map with points to draw. Returning
-- all matches (not just the current one) keeps backtrack lines drawn
-- and lets parallel routes render side-by-side.
function RR:PickLineSegs(step, mapID)
    local results = {}
    if not step or not step.segments or not mapID then return results end
    for _, seg in ipairs(step.segments) do
        local points = self:ResolveSegPoints(seg)
        if SegMapID(seg) == mapID
            and points and #points > 0
        then
            table.insert(results, seg)
        end
    end
    return results
end

-------------------------------------------------------------------------------
-- Seeder
-------------------------------------------------------------------------------

-- On step change: the highest seg matching the player's location, capped at
-- the seg before any uncompleted gate, clamped against persisted progress.
function RR:SeedProgress(step)
    if not step or not step.segments then return end
    local stepIndex = step.step or step.priority or 0
    if stepIndex == 0 then return end

    local mapID = (C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")) or nil
    local subZone = (GetSubZoneText and GetSubZoneText()) or ""

    -- Gate ceiling: cap seeding at the seg before any uncompleted gate.
    -- Gates whose trigger already fired this lockout don't count -- the
    -- player has clearly progressed past them.
    local gateCeiling = nil
    for i, seg in ipairs(step.segments) do
        if seg.triggeredBy and not self:HasTriggerFired(stepIndex, i) then
            -- A scenario criterion is server state: already complete means
            -- the gate fired, even when this session never saw the event.
            if not (seg.triggeredBy.scenario
                and self:IsScenarioCriterionComplete(seg.triggeredBy.scenario,
                    seg.triggeredBy.quantity))
            then
                gateCeiling = i
                break
            end
        end
    end

    local upper = gateCeiling and (gateCeiling - 1) or #step.segments
    if upper < 1 then upper = 1 end

    local seed = 1
    for i = upper, 1, -1 do
        local seg = step.segments[i]
        if seg and not seg.triggeredBy then
            local segMapID = SegMapID(seg)
            local segSubZ  = SegWhenSubZone(seg)
            if segMapID == mapID
                and GateSubZoneMatches(segSubZ, subZone)
            then
                seed = i
                break
            end
        end
    end

    local oldProgress = self:GetProgress(stepIndex)
    -- Monotonic clamp: never reduce persisted progress.
    local effective = (seed > oldProgress) and seed or oldProgress
    self:SetProgress(stepIndex, effective)

    -- Re-baseline the heartbeat poll so post-seed state doesn't look
    -- like a state change on the next tick.
    if self.state then
        self.state.lastPolledMapID = mapID
    end

    if self.ZoneLog then
        local prefix = "[RetroEngine]"
        self:ZoneLog(("%s seed: step %d progress %d -> %d (mapID=%s subZone=%q gateCeiling=%s)")
            :format(prefix, stepIndex, oldProgress, effective,
                    tostring(mapID), tostring(subZone),
                    tostring(gateCeiling or "none")))
    end
end

-------------------------------------------------------------------------------
-- Engine probe (dev diagnostic)
-------------------------------------------------------------------------------

function RR:BuildEngineProbeLines(opts)
    opts = opts or {}
    local lines = {}
    local function add(line) lines[#lines + 1] = line end
    local raid = self.currentRaid

    add(("currentRaid: %s (instanceID=%s)"):format(
        tostring(raid and raid.name or "(none)"),
        tostring(raid and raid.instanceID or "(none)")))

    if not raid then
        add("(no raid loaded; nothing to probe)")
        return lines
    end

    local mapID = (C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")) or nil
    local subZone = (GetSubZoneText and GetSubZoneText()) or ""
    add(("playerMapID: %s    playerSubZone: %q"):format(
        tostring(mapID), subZone))

    -- Active route variant. When skip is active, also report the skip
    -- route's step count so the diag shows at a glance which path the
    -- engine is following (vs the standard route's full boss list).
    local variant = (self.state and self.state.activeRouteVariant) or "standard"
    if variant == "skip" and raid.skipRoute then
        add(("routeVariant: skip (%d-step skip route)"):format(#raid.skipRoute))
    elseif raid.skipRoute then
        add("routeVariant: standard (skip route available)")
    else
        add("routeVariant: standard")
    end

    local activeStep = self.state and self.state.activeStep
    if activeStep then
        local stepIndex = activeStep.step or activeStep.priority or 0
        add("")
        add(("activeStep: step=%s priority=%s title=%q"):format(
            tostring(activeStep.step), tostring(activeStep.priority),
            tostring(activeStep.title)))
        add(("progress for step %d: %d"):format(stepIndex,
            self:GetProgress(stepIndex)))
    else
        add("activeStep: (none)")
    end

    -- Bypassed bosses drive both step selection and the skip note/line
    -- variants. Without this the only sign of one is a step that quietly
    -- went missing from the pointer.
    local skippedNames = {}
    for _, step in ipairs(raid.routing or {}) do
        if self:IsBossSkipped(step.bossIndex) then
            table.insert(skippedNames, ("%s (boss %s)"):format(
                tostring(step.title), tostring(step.bossIndex)))
        end
    end
    add("bossesSkipped: " .. (#skippedNames > 0
        and table.concat(skippedNames, ", ") or "(none)"))

    add("")
    add("-- Per-Step State --")
    for _, step in ipairs(raid.routing or {}) do
        local stepIndex = step.step or step.priority or 0
        local progress = self:GetProgress(stepIndex)
        add(("step %d (%s): progress=%d / %d segs"):format(
            stepIndex, tostring(step.title), progress,
            step.segments and #step.segments or 0))
        if step.segments then
            local state = { mapID = mapID, subZone = subZone }
            local seg, segIdx = ComputeCurrentSeg(step.segments, progress, state)
            if seg then
                -- Resolved, not authored: a segment following a bypassed boss
                -- renders its skip variant, and a diagnostic that printed the
                -- base string would misreport the very thing it is read for.
                local shown = self:ResolveSegNote(seg, "note")
                local variantTag = (shown ~= seg.note) and " [skip variant]" or ""
                add(("  derived current: seg %d%s, note=%q"):format(
                    segIdx, variantTag, shown or "(no note)"))
            else
                add("  derived current: (no match)")
            end
            if step == activeStep then
                for i, s2 in ipairs(step.segments) do
                    local marker = (i == progress) and " <-- progress" or ""
                    local mapStr = tostring(SegMapID(s2))
                    local szGate = SegWhenSubZone(s2)
                    local szStr  = szGate and (",subZone=" .. ("%q"):format(szGate)) or ""
                    local trig = s2.triggeredBy and " trigger=yes" or ""
                    local after = s2.after and (" after={" .. table.concat(s2.after, ",") .. "}") or ""
                    add(("    seg %d: when={mapID=%s%s}%s%s%s"):format(
                        i, mapStr, szStr, trig, after, marker))
                end
            end
        end
    end

    if mapID and activeStep then
        add("")
        add(("-- Line Picker (visible mapID=%d) --"):format(mapID))
        local segs = self:PickLineSegs(activeStep, mapID)
        add(("returned %d seg(s)"):format(#segs))
        for i, seg in ipairs(segs) do
            local drawn = self:ResolveSegPoints(seg)
            local variantTag = (drawn ~= seg.points) and " [skip variant]" or ""
            add(("  match #%d: when.mapID=%s points=%d%s"):format(
                i, tostring(SegMapID(seg)),
                drawn and #drawn or 0, variantTag))
        end
    end

    add("")
    if opts.scopeToCurrentRaid then
        add(("-- Persisted RetroRunsDB.routingProgress (instanceID=%s only) --"):format(
            tostring(raid.instanceID)))
    else
        add("-- Persisted RetroRunsDB.routingProgress --")
    end
    if RetroRunsDB and RetroRunsDB.routingProgress then
        local anyEmitted = false
        for instID, instStore in pairs(RetroRunsDB.routingProgress) do
            if (not opts.scopeToCurrentRaid) or instID == raid.instanceID then
                anyEmitted = true
                add(("instanceID %s:"):format(tostring(instID)))
                for faction, factionStore in pairs(instStore) do
                    for lockoutId, store in pairs(factionStore) do
                        if type(store) == "table" then
                        add(("  [%s] lockoutId=%s  routeVariant=%s"):format(
                            tostring(faction), tostring(lockoutId),
                            tostring(store.routeVariant or "standard")))
                        -- A skip has no external source to rebuild from, so
                        -- the stored copy is the only record that it survived.
                        if store.skippedBosses then
                            local indexes = {}
                            for bossIndex in pairs(store.skippedBosses) do
                                table.insert(indexes, bossIndex)
                            end
                            table.sort(indexes)
                            if #indexes > 0 then
                                add(("    skippedBosses = %s"):format(
                                    table.concat(indexes, ", ")))
                            end
                        end
                        -- Namespaced per-variant progress (current scheme).
                        if store.byVariant then
                            for vkey, vstore in pairs(store.byVariant) do
                                add(("    [%s]"):format(tostring(vkey)))
                                if vstore.steps then
                                    for stepIdx, p in pairs(vstore.steps) do
                                        add(("      step %d progress = %d"):format(stepIdx, p))
                                    end
                                end
                                if vstore.triggers then
                                    for stepIdx, segs in pairs(vstore.triggers) do
                                        for segIdx, fired in pairs(segs) do
                                            if fired then
                                                add(("      step %d seg %d trigger fired"):format(stepIdx, segIdx))
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        -- Legacy bare steps/triggers (pre-namespacing). Only
                        -- present on stores written by an older build; shown so
                        -- a stale carry-over is visible rather than silent.
                        if store.steps then
                            for stepIdx, p in pairs(store.steps) do
                                add(("    [legacy] step %d progress = %d"):format(stepIdx, p))
                            end
                        end
                        if store.triggers then
                            for stepIdx, segs in pairs(store.triggers) do
                                for segIdx, fired in pairs(segs) do
                                    if fired then
                                        add(("    [legacy] step %d seg %d trigger fired"):format(stepIdx, segIdx))
                                    end
                                end
                            end
                        end
                        end
                    end
                end
            end
        end
        if not anyEmitted then
            add("(no persisted entry for this raid yet)")
        end
    else
        add("(empty)")
    end

    -- The wing's run record, stamp included, so a login dispute reads
    -- straight off the dump.
    local runRecord = RetroRunsDB and RetroRunsDB.activeRuns and raid
        and RetroRunsDB.activeRuns[raid.journalInstanceID or 0]
    add("")
    add(("-- Run record (journalInstanceID=%s) --")
        :format(tostring(raid and raid.journalInstanceID)))
    if runRecord then
        local killedList = {}
        for bossIndex in pairs(runRecord.killed or {}) do
            killedList[#killedList + 1] = bossIndex
        end
        table.sort(killedList)
        add(("killed: [%s]   stamp: %s")
            :format(table.concat(killedList, ","),
                    runRecord.stamp and date("%H:%M:%S", runRecord.stamp)
                        or "none"))
        local lastSeenStamp = runRecord.lastSeen
        if lastSeenStamp then
            add(("last seen: map %s  subZone=%q  minimap=%q")
                :format(tostring(lastSeenStamp.mapID),
                        lastSeenStamp.subZone or "",
                        lastSeenStamp.minimap or ""))
        else
            add("last seen: (not stamped)")
        end
    else
        add("(no run record for this wing)")
    end

    return lines
end

-------------------------------------------------------------------------------
-- Combined diagnostic dump
-------------------------------------------------------------------------------

function RR:DiagDump()
    local lines = {}
    local function add(line) lines[#lines + 1] = line or "" end
    local function divider(num, label, desc)
        add("")
        add(("=== %d. %s "):format(num, label) ..
            string.rep("=", math.max(3, 56 - #label - #tostring(num))))
        if desc then add(("(%s)"):format(desc)) end
        add("")
    end

    local raid = self.currentRaid
    local raidLabel
    if raid then
        raidLabel = ("%s (instanceID=%s)"):format(
            tostring(raid.name), tostring(raid.instanceID))
    else
        raidLabel = "(no raid loaded)"
    end

    local timestamp = (date and date("%Y-%m-%d %H:%M:%S")) or ""

    add(string.rep("=", 60))
    add("RetroRuns Diagnostic")
    if timestamp ~= "" then add(timestamp) end
    add(raidLabel)
    add(string.rep("=", 60))

    divider(1, "RETROENGINE STATE",
        "where you are now -- RetroEngine snapshot + persistence")
    local probeLines = self:BuildEngineProbeLines({ scopeToCurrentRaid = true })
    for _, line in ipairs(probeLines) do add(line) end

    divider(2, "ZONE LOG",
        "what happened recently -- persists across reload, wiped on login")
    local buf = self.state and self.state.zoneLog or {}
    if #buf == 0 then
        add("(empty -- move between sub-zones or trigger advances to populate)")
    else
        add(("%d entries (oldest first):"):format(#buf))
        add("")
        for _, line in ipairs(buf) do add(line) end
    end

    divider(3, "SESSION LOG",
        "recorder/picker events -- persists across reload")
    local sessLines = self:BuildRecorderSessionLogLines(false)
    for _, line in ipairs(sessLines) do add(line) end

    divider(4, "COMPLETION STATE",
        "per-boss kill detection -- both sources side by side")
    for _, line in ipairs(self:BuildCompletionDiagLines()) do add(line) end

    -- LFR per-boss bit capture (S7 aid). Diag scopes to the raid the player
    -- is standing in; /rr lfrbits holds the full cross-raid log. Each line is
    -- one captured LFR kill and the lockout bit it set.
    local bitLog = (RetroRunsDebug and RetroRunsDebug.lfrBitLog) or {}
    local currentRaidName = self.currentRaid and self.currentRaid.name
    local bitLines, otherCount = {}, 0
    for i = 1, #bitLog do
        local entry = bitLog[i]
        if currentRaidName and entry.raid == currentRaidName then
            bitLines[#bitLines + 1] = ("%s  %s  ->  bit %s   [%s]"):format(
                tostring(entry.t), tostring(entry.boss), tostring(entry.bit), tostring(entry.raid))
        else
            otherCount = otherCount + 1
        end
    end
    if #bitLines > 0 then
        divider(5, "LFR BIT CAPTURE",
            "per-boss lockout bit, recorded on each LFR kill -- also via /rr lfrbits")
        for _, line in ipairs(bitLines) do add(line) end
        if otherCount > 0 then
            add("")
            add(("(%d entries for other raids not shown -- /rr lfrbits for all)")
                :format(otherCount))
        end
    end

    local body = table.concat(lines, "\n")
    -- Also parked in SavedVariables so the dump can be read off disk rather
    -- than copied out by hand. It lands on the next reload or logout, which
    -- is also when the zone log above is wiped -- so the copy outlives the
    -- trace it captured. Capped, keeping BOTH ends: the head carries the
    -- engine state and the tail the newest events, so an over-long run
    -- loses only its oldest middle.
    local DIAG_CAP = 400000
    local stored = body
    if #stored > DIAG_CAP then
        local head = math.floor(DIAG_CAP * 0.25)
        local tail = DIAG_CAP - head
        stored = body:sub(1, head)
            .. ("\n\n... %d characters elided ...\n\n")
                :format(#body - DIAG_CAP)
            .. body:sub(#body - tail + 1)
    end
    self:SetSetting("lastDiag", stored)
    self:ShowCopyWindow("RetroRuns -- Diagnostic", body)
end

-- Per-boss completion dump: how each boss's dungeonEncID resolved, and its
-- per-bucket result.
function RR:BuildCompletionDiagLines()
    local out = {}
    local function add(line) out[#out + 1] = line or "" end

    local raid = self.currentRaid
    if not raid then
        add("(no raid loaded; zone into a raid to dump completion state)")
        return out
    end
    if not C_RaidLocks or not C_RaidLocks.IsEncounterComplete then
        add("(C_RaidLocks.IsEncounterComplete unavailable on this client)")
        return out
    end

    local instanceID = raid.instanceID
    local journalToDungeonEnc =
        self:GetEJMapForJournalInstance(raid.journalInstanceID) or {}
    local model = self:GetDifficultyModel(raid)

    -- Live difficulty IDs grouped by display bucket, so completion can be
    -- asked at every size that folds into a bucket (mirrors the count path).
    local liveIdsForBucket = {}
    for liveId, bucket in pairs(model.fold) do
        liveIdsForBucket[bucket] = liveIdsForBucket[bucket] or {}
        table.insert(liveIdsForBucket[bucket], liveId)
    end

    local BUCKET_LABEL = { [14] = "N", [15] = "H", [16] = "M", [17] = "LFR" }
    local bucketOrder = model.buckets

    add(("raid=%s  instanceID=%s  journalInstanceID=%s")
        :format(tostring(raid.name), tostring(instanceID),
                tostring(raid.journalInstanceID)))

    local ejEntryCount = 0
    for _ in pairs(journalToDungeonEnc) do ejEntryCount = ejEntryCount + 1 end
    local bucketLabels = {}
    for _, b in ipairs(bucketOrder) do
        bucketLabels[#bucketLabels + 1] = BUCKET_LABEL[b] or tostring(b)
    end
    add(("EJ map entries: %d   buckets: %s")
        :format(ejEntryCount, table.concat(bucketLabels, "/")))
    add("")
    -- An instance with no lockout has nothing for IsEncounterComplete to
    -- report, and it answers FALSE rather than nil -- so asking it there
    -- prints "no" against a boss lying dead on the floor and reads as a
    -- kill-detection bug. Ask the two sources that can actually answer.
    local lockoutless = (self.GetCurrentLockoutId
        and self:GetCurrentLockoutId() == nil) or false
    local scenarioKills = lockoutless and self.ReadScenarioKills
        and self:ReadScenarioKills() or nil
    local scenarioStats = lockoutless and self.ReadScenarioCriteriaStats
        and self:ReadScenarioCriteriaStats() or nil

    if lockoutless then
        add("no lockout on this instance -- IsEncounterComplete cannot answer")
        add("here (it returns false, not nil), so kills come from our run")
        add("record and the game's own scenario criteria instead.")
        add(DescribeScenarioStats(scenarioStats))
        add("")
        add("boss                            dungeonEncID  source     killed  scenario")
    else
        add("boss                            dungeonEncID  source     per-bucket complete")
    end
    add(string.rep("-", 78))

    local unresolved = 0
    for _, b in ipairs(raid.bosses or {}) do
        local fromEJ   = journalToDungeonEnc[b.journalEncounterID]
        local fromData = b.dungeonEncounterID
        local dungeonEncID = fromEJ or fromData

        local source
        if fromEJ then
            source = "EJ map"
        elseif fromData then
            source = "data"
        else
            source = "NONE"
            unresolved = unresolved + 1
        end

        local perBucket = {}
        if lockoutless then
            perBucket[#perBucket + 1] =
                (self.state.bossesKilled[b.index] and "yes" or "no")
            if not scenarioKills then
                if scenarioStats and scenarioStats.criteriaSeen > 0 then
                    perBucket[#perBucket + 1] = "   no"
                else
                    perBucket[#perBucket + 1] = "   (no criteria)"
                end
            else
                perBucket[#perBucket + 1] =
                    "   " .. (scenarioKills[b.index] and "yes" or "no")
            end
        else
        for _, bucket in ipairs(bucketOrder) do
            local label = BUCKET_LABEL[bucket] or tostring(bucket)
            if not self:BossAvailableInBucket(b, bucket) then
                perBucket[#perBucket + 1] = label .. ":n/a"
            elseif not dungeonEncID then
                perBucket[#perBucket + 1] = label .. ":?"
            else
                local done = false
                for _, liveId in ipairs(liveIdsForBucket[bucket] or {}) do
                    if C_RaidLocks.IsEncounterComplete(
                            instanceID, dungeonEncID, liveId) then
                        done = true
                        break
                    end
                end
                perBucket[#perBucket + 1] =
                    label .. ":" .. (done and "yes" or "no")
            end
        end
        end

        add(("%-30s  %-12s  %-9s  %s"):format(
            (tostring(b.name)):sub(1, 30),
            tostring(dungeonEncID or "nil"),
            source,
            table.concat(perBucket, "  ")))
    end

    add("")
    if unresolved > 0 then
        add(("WARNING: %d boss(es) have NO dungeonEncID (EJ map miss + no data "
            .. "fallback). These are invisible to the idle-list count and will "
            .. "under-report a full clear. Add an explicit dungeonEncounterID to "
            .. "the boss entry."):format(unresolved))
    else
        add("All bosses resolved a dungeonEncID (EJ map or data fallback).")
    end
    return out
end
