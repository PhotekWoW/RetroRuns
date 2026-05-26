-------------------------------------------------------------------------------
-- RetroRuns -- the RetroEngine
-------------------------------------------------------------------------------
-- Tracks where the player is in a raid and decides which routing
-- instruction to display next. Every raid runs on this engine.
-------------------------------------------------------------------------------

local addonName, addon = ...
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

function RR:GetProgress(stepIndex)
    if not stepIndex then return 1 end
    local store = self.state.progress
    if store and store[stepIndex] then return store[stepIndex] end
    return 1
end

function RR:SetProgress(stepIndex, value)
    if not stepIndex or not value then return end
    self.state.progress = self.state.progress or {}
    self.state.progress[stepIndex] = value

    if not self.currentRaid or not self.currentRaid.instanceID then return end

    RetroRunsDB = RetroRunsDB or {}
    RetroRunsDB.routingProgress = RetroRunsDB.routingProgress or {}
    local instStore = RetroRunsDB.routingProgress[self.currentRaid.instanceID]
    if not instStore then
        instStore = {}
        RetroRunsDB.routingProgress[self.currentRaid.instanceID] = instStore
    end
    local faction = CurrentFactionKey()
    local factionStore = instStore[faction]
    if not factionStore then
        factionStore = { lockoutId = self:GetCurrentLockoutId(), steps = {} }
        instStore[faction] = factionStore
    end
    -- Lockout reset wipes the whole record.
    if factionStore.lockoutId ~= self:GetCurrentLockoutId() then
        factionStore.lockoutId = self:GetCurrentLockoutId()
        factionStore.steps    = {}
        factionStore.triggers = {}
    end
    factionStore.steps[stepIndex] = value
end

function RR:RestorePersistedProgress()
    self.state.progress       = {}
    self.state.triggersFired  = {}
    if not RetroRunsDB or not RetroRunsDB.routingProgress then return end
    local instStore = RetroRunsDB.routingProgress[self.currentRaid.instanceID]
    if not instStore then return end
    local faction = CurrentFactionKey()
    local factionStore = instStore[faction]
    if not factionStore then return end
    if factionStore.lockoutId ~= self:GetCurrentLockoutId() then
        instStore[faction] = nil
        return
    end
    if factionStore.steps then
        for stepIndex, p in pairs(factionStore.steps) do
            self.state.progress[stepIndex] = p
        end
    end
    if factionStore.triggers then
        for stepIndex, segs in pairs(factionStore.triggers) do
            self.state.triggersFired[stepIndex] = {}
            for segIndex, fired in pairs(segs) do
                if fired then
                    self.state.triggersFired[stepIndex][segIndex] = true
                end
            end
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

    if not self.currentRaid or not self.currentRaid.instanceID then return end

    RetroRunsDB = RetroRunsDB or {}
    RetroRunsDB.routingProgress = RetroRunsDB.routingProgress or {}
    local instStore = RetroRunsDB.routingProgress[self.currentRaid.instanceID]
    if not instStore then
        instStore = {}
        RetroRunsDB.routingProgress[self.currentRaid.instanceID] = instStore
    end
    local faction = CurrentFactionKey()
    local factionStore = instStore[faction]
    if not factionStore then
        factionStore = {
            lockoutId = self:GetCurrentLockoutId(),
            steps     = {},
            triggers  = {},
        }
        instStore[faction] = factionStore
    end
    if factionStore.lockoutId ~= self:GetCurrentLockoutId() then
        factionStore.lockoutId = self:GetCurrentLockoutId()
        factionStore.steps    = {}
        factionStore.triggers = {}
    end
    factionStore.triggers = factionStore.triggers or {}
    factionStore.triggers[stepIndex] = factionStore.triggers[stepIndex] or {}
    factionStore.triggers[stepIndex][segIndex] = true
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

local function WhenMatches(seg, mapID, subZone)
    local segMapID = SegMapID(seg)
    if not segMapID then return false end
    if segMapID ~= mapID then return false end
    local gateSubZone = SegWhenSubZone(seg)
    if gateSubZone and gateSubZone ~= subZone then return false end
    return true
end

local function AfterSatisfied(seg, currentProgress)
    if not seg or not seg.after then return true end
    for _, prereqIdx in ipairs(seg.after) do
        if prereqIdx >= currentProgress then return false end
    end
    return true
end

-- triggeredBy.dialog fires on any NPC dialog event (CHAT_MSG_MONSTER_YELL,
-- _SAY, _RAID_BOSS_EMOTE) whose npc + text matches the seg's trigger.
local function TriggerMatches(seg, event, eventData)
    if not seg or not seg.triggeredBy then return true end

    if seg.triggeredBy.dialog then
        if event ~= "npc-dialog" then return false end
        if not eventData then return false end
        local dialogTrigger = seg.triggeredBy.dialog
        if eventData.npc ~= dialogTrigger.npc then return false end
        if not dialogTrigger.match or not eventData.text then return false end
        return string.find(eventData.text, dialogTrigger.match, 1, true) ~= nil
    end

    return false
end

-- "Has the player left this seg?" — the test that powers stay-here.
-- For subZone-gated segs, only subZone change counts as leaving (mapID
-- can flicker without the player having actually moved).
local function HasLeft(seg, mapID, subZone)
    if not seg then return true end
    local gateSubZone = SegWhenSubZone(seg)
    if gateSubZone then
        return subZone ~= gateSubZone
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
                local dialoguePasses = false
                if event == "npc-dialog" then
                    if not progressSeg.triggeredBy then
                        dialoguePasses = true
                    elseif TriggerMatches(progressSeg, event, eventData) then
                        dialoguePasses = true
                    elseif stepIndex and RR:HasTriggerFired(stepIndex, progress) then
                        dialoguePasses = true
                    end
                end
                if not dialoguePasses then
                    return progress
                end
            end
        end
    end

    local advancedPastNoted = false
    local i = progress + 1
    while i <= segCount do
        local seg = segments[i]
        if not seg then break end

        if not WhenMatches(seg, state.mapID, state.subZone) then break end
        if not AfterSatisfied(seg, i) then break end
        if not TriggerMatches(seg, event, eventData) then break end

        if seg.note and advancedPastNoted then break end

        progress = i
        if seg.note then advancedPastNoted = true end
        i = i + 1
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

    -- Log when derived current drops below progress (backward derivation).
    -- One entry per transition, not per render.
    --
    -- Suppress the canonical POI-overlay shape: a noteless POI seg sits at
    -- progress, the picker walks back to the earlier path seg that carries
    -- the note. This access pattern is the algorithm working correctly --
    -- the visual marker is on a later seg, the prose is on an earlier seg
    -- at the same physical location. Logging it on every seed is noise.
    -- Any backtrace where the seg at progress IS noted still logs, because
    -- that indicates progress didn't location-match -- a real diagnostic.
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
        if SegMapID(seg) == mapID
            and seg.points and #seg.points > 0
        then
            table.insert(results, seg)
        end
    end
    return results
end

-------------------------------------------------------------------------------
-- Seeder
-------------------------------------------------------------------------------

-- Called when the active step changes (boss kill, /reload, fresh login,
-- raid entry). Picks the highest seg whose location matches the player,
-- capped at the seg before any uncompleted gate. The monotonic clamp at
-- the end still protects against regressing past a player-completed
-- point if persisted progress is higher.
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
                and (not segSubZ or segSubZ == subZone)
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
    local function add(s) lines[#lines + 1] = s end
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
                add(("  derived current: seg %d, note=%q"):format(
                    segIdx, seg.note or "(no note)"))
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
            add(("  match #%d: when.mapID=%s points=%d"):format(
                i, tostring(SegMapID(seg)),
                seg.points and #seg.points or 0))
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
                    add(("  [%s] lockoutId=%s"):format(
                        tostring(faction), tostring(factionStore.lockoutId)))
                    if factionStore.steps then
                        for stepIdx, p in pairs(factionStore.steps) do
                            add(("    step %d progress = %d"):format(stepIdx, p))
                        end
                    end
                    if factionStore.triggers then
                        for stepIdx, segs in pairs(factionStore.triggers) do
                            for segIdx, fired in pairs(segs) do
                                if fired then
                                    add(("    step %d seg %d trigger fired"):format(stepIdx, segIdx))
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
    local function add(s) lines[#lines + 1] = s or "" end
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

    self:ShowCopyWindow("RetroRuns -- Diagnostic", table.concat(lines, "\n"))
end
