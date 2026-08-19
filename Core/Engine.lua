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
    if not store then return end
    store.routeVariant = variant
end

-- The route variant ("standard" | "skip") persisted for the current
-- lockout, or nil if none has been saved yet. Read by the load dialog so
-- it can mark the previously-chosen route with a "Continue?" hint when
-- re-prompting before the first kill.
function RR:GetPersistedRouteVariant()
    local store = self:GetLockoutStore(false)
    return store and store.routeVariant or nil
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
    if not store then return end
    store.skippedBosses = store.skippedBosses or {}
    store.skippedBosses[bossIndex] = skipped and true or nil
end

function RR:RestorePersistedProgress()
    self.state.progress       = {}
    self.state.triggersFired  = {}
    -- Record which variant the in-memory progress now reflects, so a later
    -- variant change (e.g. walking from one LFR wing into another without a
    -- raid reload) can detect the mismatch and reload the right namespace.
    self.state.progressVariantKey = self:ActiveVariantKey()
    local store = self:GetLockoutStore(false)
    if not store then return end
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

    local store = self:GetLockoutStore(true)
    if not store then return end
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
-- triggeredBy.encounter matches a successful ENCOUNTER_END's
-- dungeonEncounterID. Prefer the encounter form where both would work.
local function TriggerMatches(seg, event, eventData)
    if not seg or not seg.triggeredBy then return true end

    if seg.triggeredBy.encounter then
        if event ~= "encounter-end" then return false end
        if not eventData then return false end
        return eventData.encounterID == seg.triggeredBy.encounter
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
            gateCeiling = i
            break
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
        "what happened recently -- in-memory trace, wiped on reload")
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

    -- LFR per-boss bit capture (S7 aid). Only shown when entries exist, so it
    -- doesn't clutter diag for non-LFR work. Each line is one captured LFR
    -- kill and the lockout bit it set.
    local bitLog = (RetroRunsDebug and RetroRunsDebug.lfrBitLog) or {}
    if #bitLog > 0 then
        divider(5, "LFR BIT CAPTURE",
            "per-boss lockout bit, recorded on each LFR kill -- also via /rr lfrbits")
        for i = 1, #bitLog do
            local entry = bitLog[i]
            add(("%s  %s  ->  bit %s   [%s]"):format(
                tostring(entry.t), tostring(entry.boss), tostring(entry.bit), tostring(entry.raid)))
        end
    end

    self:ShowCopyWindow("RetroRuns -- Diagnostic", table.concat(lines, "\n"))
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
    add("boss                            dungeonEncID  source     per-bucket complete")
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
