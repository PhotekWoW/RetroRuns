-------------------------------------------------------------------------------
-- RetroRuns Data -- Strict-activeSeg picker
-------------------------------------------------------------------------------
-- Alternative picker subsystem for raids that opt in via the
-- `useStrictActiveSegPicker = true` flag on their data table. Other
-- raids continue using the default picker via dispatch in
-- Navigation.lua and UI.lua. Originally written for Battle of
-- Dazar'alor (hence the filename), since generalized to support
-- additional raids.
--
-- THE MODEL: each step has an integer activeSeg pointer
-- (state.strictActiveSeg[stepIndex]), starting at 1 and monotonically
-- advancing. Advances ONE seg at a time when the player's mapID
-- transitions to the next seg's mapID. Never retreats. Persisted
-- across /reload, wiped on lockout reset.
--
-- DISPLAY:
--   * Note: picker always returns step.segments[activeSeg].note. The
--     displayed note doesn't change based on the player's current
--     mapID -- it changes only when activeSeg advances. This trades
--     backtrack-redisplay for correctness on transit cases (mid-
--     flight transits, jump-in-hole tunnel passes) where mapID-based
--     matching would surface wrong notes.
--
--   * Lines: drawn for every seg whose mapID matches the currently-
--     visible map. Independent of activeSeg, so the visual breadcrumb
--     trail is preserved even when notes follow a strict pointer.
--     Player gets "what to do next" (note) plus "where I've been"
--     (lines).
--
-- ADVANCEMENT:
--   * On player mapID transition: if the new mapID matches the next
--     seg's mapID, advance by exactly one. No multi-seg jumps during
--     live play (prevents transit-flash bugs where a brief mid-flight
--     mapID match would jump past intermediate segs not physically
--     visited).
--
--   * On step activation (post-boss-kill, fresh login, /reload):
--     seeded via "highest seg whose mapID matches the player's
--     current mapID," or 1 if no match. This recovers the pointer
--     for /reload mid-step scenarios without requiring a journey
--     through every prior mapID.
-------------------------------------------------------------------------------

local addonName, addon = ...
local RR = _G.RetroRuns

-- Predicate: does the currently-active raid opt in to the strict-activeSeg
-- picker via `useStrictActiveSegPicker = true` on its data table? Returns
-- false if no raid is loaded or the flag is absent / falsy.
--
-- Every public function in this picker is a no-op when this predicate is
-- false; that gives non-opted-in raids zero behavioural change. Dispatch
-- sites in Navigation.lua and UI.lua check the same predicate to choose
-- between this picker and the default picker.
function RR:UsesStrictActiveSegPicker()
    return self.currentRaid and self.currentRaid.useStrictActiveSegPicker == true
end

-------------------------------------------------------------------------------
-- State accessors
-------------------------------------------------------------------------------

-- Returns the activeSeg (current seg index) for the given step. Defaults to
-- 1 for never-touched steps. Reads from persisted RetroRunsDB; if not yet
-- populated, falls back to in-memory state. The activeSeg is scoped by
-- instanceID + lockoutId, so weekly reset wipes it cleanly via the same
-- mechanism as completedSegments.
function RR:GetStrictActiveSeg(stepIndex)
    if not stepIndex then return 1 end
    local store = self.state.strictActiveSeg
    if store and store[stepIndex] then return store[stepIndex] end
    return 1
end

-- Returns "Alliance" or "Horde" for storage scoping. Pandaren on the
-- Wandering Isle return "Neutral" from UnitFactionGroup; they can't
-- enter raids anyway, but bucketing them under "Alliance" keeps the
-- table shape predictable and matches how GetSupportedRaid falls
-- through to the shared (Alliance) data table for Neutral characters.
local function CurrentFactionKey()
    local faction = UnitFactionGroup("player")
    if faction == "Horde" then return "Horde" end
    return "Alliance"
end

-- Sets the activeSeg for a step. Persists to RetroRunsDB. Idempotent: setting
-- to the current value is a no-op write (RetroRunsDB-shape side-effects
-- are minor enough we don't bother to early-return). Monotonicity for
-- mid-step advancement is enforced by callers (AdvanceStrictActiveSeg only
-- ever increments by 1). SeedStrictActiveSeg resets unconditionally on
-- step transitions, treating each new step as a clean slate.
--
-- Faction-scoped: BfD's seg counts differ between Alliance and Horde
-- (Alliance step 4 has 2 segs, Horde step 4 has 4 segs, etc.). Storing
-- per-faction prevents an alt of a different faction from inheriting an
-- activeSeg index that's larger than its faction's seg count, which
-- would cause the picker to return nil and the travel pane to fall
-- through to the "Open the map..." default.
function RR:SetStrictActiveSeg(stepIndex, value)
    if not stepIndex or not value then return end
    self.state.strictActiveSeg = self.state.strictActiveSeg or {}
    self.state.strictActiveSeg[stepIndex] = value
    if not self.currentRaid or not self.currentRaid.instanceID then return end
    RetroRunsDB = RetroRunsDB or {}
    RetroRunsDB.strictActiveSeg = RetroRunsDB.strictActiveSeg or {}
    local instStore = RetroRunsDB.strictActiveSeg[self.currentRaid.instanceID]
    if not instStore then
        instStore = {}
        RetroRunsDB.strictActiveSeg[self.currentRaid.instanceID] = instStore
    end
    -- Detect and migrate from the pre-faction-scoped shape: if the
    -- record has lockoutId/activeSegs at the top level instead of
    -- under a faction key, wipe and re-init. We can't safely assign
    -- the old data to either faction (it could be from either side
    -- and the seg counts differ).
    if instStore.lockoutId ~= nil or instStore.activeSegs ~= nil then
        wipe(instStore)
    end
    local faction = CurrentFactionKey()
    local factionStore = instStore[faction]
    if not factionStore then
        factionStore = { lockoutId = self:GetCurrentLockoutId(), activeSegs = {} }
        instStore[faction] = factionStore
    end
    -- Lockout reset: if the persisted lockoutId doesn't match the current
    -- lockout, wipe and re-stamp. Same pattern as completedSegments
    -- persistence (see RestorePersistedSegments).
    if factionStore.lockoutId ~= self:GetCurrentLockoutId() then
        factionStore.lockoutId = self:GetCurrentLockoutId()
        factionStore.activeSegs = {}
    end
    factionStore.activeSegs[stepIndex] = value
end

-- Restores in-memory strictActiveSeg state from RetroRunsDB at addon load /
-- raid-load time. Mirrors the shape of RestorePersistedSegments. Wipes
-- and re-stamps if the persisted lockoutId is stale, OR if the persisted
-- record is in the pre-faction-scoped shape.
function RR:RestorePersistedStrictActiveSeg()
    self.state.strictActiveSeg = {}
    if not self:UsesStrictActiveSegPicker() then
        return
    end
    if not RetroRunsDB or not RetroRunsDB.strictActiveSeg then return end
    local instStore = RetroRunsDB.strictActiveSeg[self.currentRaid.instanceID]
    if not instStore then return end
    -- Pre-faction-scoped shape: top-level lockoutId/activeSegs instead of
    -- nested under a faction key. Wipe -- can't safely apply old data to
    -- either faction (seg counts differ).
    if instStore.lockoutId ~= nil or instStore.activeSegs ~= nil then
        RetroRunsDB.strictActiveSeg[self.currentRaid.instanceID] = nil
        return
    end
    local faction = CurrentFactionKey()
    local factionStore = instStore[faction]
    if not factionStore then return end
    -- Defensive: nil-lockoutId persistence is a corruption signature.
    -- Wiping ensures stale activeSeg state can't leak across sessions
    -- via a nil==nil comparison on restore -- next progress write
    -- will repopulate with a real lockoutId.
    if factionStore.lockoutId == nil then
        instStore[faction] = nil
        return
    end
    if factionStore.lockoutId ~= self:GetCurrentLockoutId() then
        -- Stale persisted state for this faction -- wipe and let
        -- SeedStrictActiveSeg re-populate as the player progresses.
        instStore[faction] = nil
        return
    end
    if factionStore.activeSegs then
        for stepIndex, seg in pairs(factionStore.activeSegs) do
            self.state.strictActiveSeg[stepIndex] = seg
        end
    end
end

-------------------------------------------------------------------------------
-- ActiveSeg advancement
-------------------------------------------------------------------------------

-- Called from the HLC handler when the player's mapID transitions. Advances
-- the active step's activeSeg by ONE if and only if the new mapID matches
-- seg[activeSeg+1].mapID. Single-step advancement prevents transit-flash bugs
-- where a brief mid-flight mapID hit on a later seg would jump the activeSeg
-- past intermediate segs.
--
-- Only fires for the active step. Other steps' activeSegs stay at whatever
-- they were last set to (typically 1 for unstarted steps).
--
-- Idempotent across redundant call sites: the event-driven HLC handler and
-- the heartbeat poll BOTH fire Advance for the same physical mapID transition
-- (HLC immediately on the event, poll up to 1s later on the next tick).
-- Without the lastAdvancedMapID guard, both calls would land for transitions
-- where TWO consecutive segs share a mapID -- the first Advance moves
-- activeSeg N -> N+1, then the second Advance sees that segs[N+2] also
-- matches and advances N+1 -> N+2, skipping seg N+1's note entirely.
-- Tracking the last mapID we advanced on and short-circuiting if Advance
-- is called again with the same value closes that gap. The guard resets
-- when the activeStep changes (via ResetStrictAdvanceGuard, called from
-- OnActiveStepChanged), so each new step gets a fresh single-advance budget.
-- Predicate: is this segment a "gate" that must complete before later
-- segs in the same step can become active? A gate is any seg with an
-- `advanceOn` block -- by definition that's a segment whose completion
-- is conditional on an external trigger (yell, kill, etc.), not on
-- mapID transitions. Object-click pois (Hammer of Khaz'goroth,
-- Tidestone of Golganneth, Tears of Elune) are the canonical case.
-- Defined here at file scope so both AdvanceStrictActiveSeg (below)
-- and SeedStrictActiveSeg (further below) can use it.
local function IsGateSegment(seg)
    return seg and seg.advanceOn ~= nil
end

local lastAdvancedMapID = nil
local lastAdvancedStep  = nil

function RR:ResetStrictAdvanceGuard()
    lastAdvancedMapID = nil
    lastAdvancedStep  = nil
end

function RR:AdvanceStrictActiveSeg(currentMapID)
    if not self:UsesStrictActiveSegPicker() then
        return
    end
    local step = self.state.activeStep
    if not step or not step.segments then return end
    local stepIndex = step.step or step.priority or 0
    if stepIndex == 0 then return end
    -- Idempotency guard. If we already advanced on this exact (step, mapID)
    -- pair, the call is redundant -- either the heartbeat poll racing
    -- the HLC handler, or a re-entrant Update flow. Short-circuit so a
    -- single physical mapID transition never advances more than one seg
    -- even when consecutive segs share a mapID.
    if lastAdvancedStep == stepIndex and lastAdvancedMapID == currentMapID then
        return
    end
    local activeSeg = self:GetStrictActiveSeg(stepIndex)
    -- Gate-respect: if the current activeSeg is an uncompleted gate (has
    -- advanceOn, not yet marked complete in completedSegments), refuse
    -- to advance. The gate's trigger (yell/kill/etc) is what completes
    -- it, and once it's marked complete the yell-trigger handler also
    -- bumps activeSeg via the same code path that completes it -- so
    -- this check pairs with that to keep activeSeg locked on the gate
    -- until the trigger fires. Same defensive logic as the seeder in
    -- SeedStrictActiveSeg; without it the seeder's gate-respect is
    -- undone by the very next heartbeat poll (player still on the
    -- gate's mapID, segs[activeSeg+1] also matches, advance fires).
    local activeSegObj = step.segments[activeSeg]
    if IsGateSegment(activeSegObj)
        and not self:IsSegmentCompleted(stepIndex, activeSeg)
    then
        return
    end
    -- SubZone-respect guard: if the current activeSeg has a `subZone`
    -- defined and the player is still in that subZone, refuse to advance.
    -- This protects against in-zone mapID flicker that the heartbeat poll
    -- would otherwise interpret as a real transition.
    --
    -- Canonical refuse case (Antorus Eonar): seg 1 has subZone "Elarian
    -- Sanctuary" and mapID 913; the in-room Surge of Life ability flies
    -- the player across open space, momentarily flickering the resolved
    -- mapID 913 -> 909 while subZone stays "Elarian Sanctuary". Without
    -- this guard, the heartbeat poll catches the flicker and advances
    -- seg 1 -> seg 2 even though the player hasn't actually progressed.
    -- The legitimate orb-click teleport DOES change subZone away from
    -- "Elarian Sanctuary", so the guard correctly allows the advance
    -- when the player actually leaves.
    --
    -- Escape clause (path-only): if activeSeg's kind is "path" AND the
    -- next seg's declared mapID matches the new currentMapID, allow the
    -- advance even though subZone still matches. The data author has
    -- explicitly declared "the next step happens on mapID Y" -- when the
    -- player arrives at mapID Y, that IS the transition, regardless of
    -- whether subZone has caught up to it yet. Canonical allow case
    -- (Antorus Hasabel elevator drop): seg 1 has subZone "Gaze of the
    -- Legion" and mapID 910 (top platform); seg 2 has mapID 909 (bottom).
    -- Jumping down the hatch produces a real 910->909 mapID transition,
    -- but subZone stays "Gaze of the Legion" on both sides of the
    -- threshold while the WoW client catches up.
    --
    -- Why path-only: poi/teleport/star segs represent "stop here and
    -- interact" gates. The Eonar orb seg is `kind = "poi"` with mapID
    -- 913 and subZone "Elarian Sanctuary"; the next seg's mapID is 909.
    -- Without the path-only restriction, in-room Surge of Life flickers
    -- (mid-encounter, hasn't clicked the orb yet) would slip through the
    -- escape clause because currentMapID transiently reads 909 -- the
    -- exact same value nextSeg declares. Path segs represent continuous
    -- traversal where mid-segment mapID changes reflect real movement;
    -- non-path segs require an explicit player action and shouldn't
    -- advance via the escape.
    --
    -- Safety: the escape clause never advances across multi-step
    -- boundaries (we only check the NEXT seg in the same step, not future
    -- steps) and never bypasses an `advanceOn` gate (the gate check at
    -- the top of this function fires first and short-circuits).
    if activeSegObj and activeSegObj.subZone and GetSubZoneText then
        local currentSubZone = GetSubZoneText() or ""
        if currentSubZone == activeSegObj.subZone then
            local nextSegPeek = step.segments[activeSeg + 1]
            local escapeOK = activeSegObj.kind == "path"
                         and nextSegPeek
                         and nextSegPeek.mapID == currentMapID
            if escapeOK then
                if self.ZoneLog then
                    self:ZoneLog(("strict activeSeg advance ALLOWED via mapID-match escape: subZone %q still matches but nextSeg.mapID=%d == currentMapID (step %d seg %d)")
                        :format(currentSubZone, currentMapID, stepIndex, activeSeg))
                end
                -- Fall through to the normal advance path below.
            else
                if self.ZoneLog then
                    self:ZoneLog(("strict activeSeg advance REFUSED: still in subZone %q (step %d seg %d, mapID=%d)")
                        :format(currentSubZone, stepIndex, activeSeg, currentMapID))
                end
                return
            end
        end
    end
    local nextSeg = step.segments[activeSeg + 1]
    if nextSeg and nextSeg.mapID == currentMapID then
        self:SetStrictActiveSeg(stepIndex, activeSeg + 1)
        lastAdvancedStep  = stepIndex
        lastAdvancedMapID = currentMapID
        if self.ZoneLog then
            self:ZoneLog(("strict activeSeg advance: step %d %d -> %d (mapID=%d)")
                :format(stepIndex, activeSeg, activeSeg + 1, currentMapID))
        end
    else
        if self.ZoneLog then
            local nextMapStr = nextSeg and tostring(nextSeg.mapID) or "(no next seg)"
            self:ZoneLog(("Advance no-op: nextSeg.mapID=%s != currentMapID=%d (step=%d activeSeg=%d)")
                :format(nextMapStr, currentMapID, stepIndex, activeSeg))
        end
    end
end

-- Called when a step becomes active (post-boss-kill advancement, /reload
-- restoration, fresh login). Seeds the activeSeg to the highest seg index
-- whose mapID matches the player's current mapID, capped at the first
-- uncompleted gate seg if one exists earlier in the list.
--
-- Resets unconditionally: a step transition is a clean slate. The hook
-- this gets called from (Navigation.lua's OnActiveStepChanged) only fires
-- when the active step actually changes, so any prior activeSeg value
-- belongs to a different step and must not carry over. The picker's
-- per-step state is keyed by step number; raids with multiple routing
-- entries at the same step number (DAG-middle siblings like Nighthold's
-- step 5: Star Augur / Tel'arn / Tichondrius / Krosus, walked in route-
-- defined order one boss at a time) need this reset so the second
-- sibling's activeSeg doesn't inherit the first sibling's terminal
-- value.
--
-- Gate-respect: if a seg with `advanceOn` exists earlier in the segment
-- list and is NOT yet marked complete in completedSegments, the seed
-- caps at that seg's index. This prevents the seeder from jumping past
-- gating pois that share a mapID with later path segs (e.g. the Hammer
-- of Khaz'goroth click in Tomb of Sargeras sits on mapID 850, same as
-- the path leading away from it). Once the gate is marked complete
-- (via the yell-trigger handler in Navigation.lua), subsequent re-seeds
-- (e.g. after /reload mid-step) walk past it normally and pick the
-- highest matching same-mapID seg as before.
--
-- Monotonic-advance protection still applies to AdvanceStrictActiveSeg,
-- which fires on player mapID transitions WITHIN a step -- that's the
-- correct place to guard against transit-flash and mid-step retrace.
function RR:SeedStrictActiveSeg(step)
    if not self:UsesStrictActiveSegPicker() then
        return
    end
    if not step or not step.segments then return end
    local stepIndex = step.step or step.priority or 0
    if stepIndex == 0 then return end
    local playerMapID = C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")

    -- First pass: find the lowest-index uncompleted gate seg (if any).
    -- Initially this seg is the ceiling: the seed must not exceed it,
    -- because the gate's advanceOn trigger has to fire before later
    -- segs can legitimately become active. EXCEPTION below: if the
    -- player has visibly progressed past the gate (their current
    -- mapID matches a seg index > gateCeiling), treat the gate as
    -- already-traversed for seeding purposes. The cross-mapID transit
    -- to the post-gate seg's mapID is the proof of progression.
    local gateCeiling = nil
    for i, seg in ipairs(step.segments) do
        if IsGateSegment(seg) and not self:IsSegmentCompleted(stepIndex, i) then
            gateCeiling = i
            break
        end
    end

    -- Visible-past-gate detection: if any post-gate seg matches the
    -- player's mapID, the player has physically crossed past the gate
    -- (e.g. Antorus Imonar step 3: gate is seg 3 on mapID 909/Broken
    -- Cliffs, post-gate seg 4 is on mapID 914/The Exhaust; if the
    -- player /reloads while on mapID 914, they've already used the
    -- Lightforged Beacon to teleport past Broken Cliffs and the gate
    -- shouldn't cap their seed). Without this check the seeder would
    -- snap them back to the gate's index and the strict picker would
    -- park on the pre-Beacon "click the Beacon" instruction.
    if gateCeiling and playerMapID then
        for i = gateCeiling + 1, #step.segments do
            if step.segments[i].mapID == playerMapID then
                gateCeiling = nil
                break
            end
        end
    end

    -- Second pass: highest matching mapID up to the ceiling (or end of
    -- segments if no ceiling -- the original behaviour). Fallback when
    -- no mapID match: the gate ceiling itself, or seg 1.
    local highestMatch = 0
    if playerMapID then
        local upper = gateCeiling or #step.segments
        for i = 1, upper do
            if step.segments[i].mapID == playerMapID then
                highestMatch = i
            end
        end
    end
    local seed = (highestMatch > 0) and highestMatch
        or (gateCeiling or 1)

    local current = self:GetStrictActiveSeg(stepIndex)
    self:SetStrictActiveSeg(stepIndex, seed)

    -- Re-baseline the heartbeat poll's last-seen mapID to match the
    -- seed's playerMapID. The 1Hz heartbeat in Core.lua fires
    -- AdvanceStrictActiveSeg(nowMapID) whenever nowMapID differs from
    -- RR.state.lastPolledMapID; without this re-baseline, a step
    -- transition that seeds at mapID X with the poll's baseline still
    -- holding pre-seed value Y can fire a spurious advance on the
    -- next tick when the poll "discovers" a phantom X->Y delta even
    -- though the player hasn't moved. Antorus Eonar->Imonar is the
    -- documented case: post-ENCOUNTER_END the player's mapID can
    -- briefly resolve 913->909 around the kill (parent-map
    -- resolution flicker), and without this sync the heartbeat
    -- snaps activeSeg from 1 (the "talk to Essence of Eonar" orb)
    -- to 2 (the "click the warframe" post-orb instruction) before
    -- the player has actually clicked the orb.
    if RR.state then
        RR.state.lastPolledMapID = playerMapID
    end

    if self.ZoneLog then
        self:ZoneLog(("strict activeSeg seed: step %d %d -> %d (playerMapID=%s gateCeiling=%s)")
            :format(stepIndex, current, seed,
                    tostring(playerMapID or "nil"),
                    tostring(gateCeiling or "none")))
    end
end

-------------------------------------------------------------------------------
-- Picker entry points (called from Navigation.lua / UI.lua dispatch)
-------------------------------------------------------------------------------

-- Note picker: returns the seg the activeSeg currently points at. That's it.
-- The note doesn't change based on the player's current mapID; it changes
-- only when the activeSeg advances (which happens via AdvanceStrictActiveSeg when
-- the player physically arrives on the next-expected-seg's mapID).
--
-- Why strict-activeSeg: the picker has no way to distinguish "player is
-- transiting through an irrelevant mapID" from "player is deliberately
-- walking back to view a prior seg's note." Both produce identical
-- (mapID, activeSeg) state. Earlier attempts to disambiguate via hysteresis,
-- per-seg gating flags, or sub-zone strings each had failure modes.
-- Strict-activeSeg refuses to disambiguate -- it always shows the next
-- directive, which is the only thing the player consistently needs.
--
-- Trade: backtrack-note-redisplay is lost. Player walking back to a
-- prior seg's mapID does NOT see that seg's note redisplay. They see
-- the activeSeg seg's note (current directive) the whole time. Lines on
-- the map still redraw via PickStrictLineSegs (which is independent of
-- activeSeg and follows mapID-match), so the visual breadcrumb trail
-- is preserved.
--
-- Returns the seg table (with .note, .points, etc.) or nil. Callers
-- responsible for nil-handling. The playerMapID parameter is accepted
-- for signature compatibility with the dispatch site but is unused.
function RR:PickStrictNoteSeg(step, playerMapID)
    if not step or not step.segments then return nil end
    local stepIndex = step.step or step.priority or 0
    local activeSeg = self:GetStrictActiveSeg(stepIndex)
    -- Defensive clamp: if activeSeg points past the end of step.segments
    -- (cross-faction stale persistence, manual DB poke, or future
    -- regression), return the last seg rather than nil. Clamping keeps
    -- the travel pane displaying meaningful content instead of falling
    -- through to "Open the map..." default. The activeSeg in state isn't
    -- modified by the read; we let the caller's natural progression or
    -- a fresh SeedStrictActiveSeg fix the underlying state.
    if activeSeg > #step.segments then
        activeSeg = #step.segments
    end
    return step.segments[activeSeg]
end

-- Line picker: returns all segs whose mapID matches the currently-visible
-- map AND that have points worth drawing. Used by the map renderer to
-- decide which lines to draw. Returns an array of seg tables (possibly
-- empty).
--
-- Independent of activeSeg: every seg whose mapID matches gets its line
-- drawn, supporting full breadcrumb-trail visualization on backtrack.
-- This is the visual complement to the strict-activeSeg note picker --
-- the player gets next-directive text plus trail-of-lines visualization,
-- separating "what to do" from "where I've been."
function RR:PickStrictLineSegs(step, mapID)
    local results = {}
    if not step or not step.segments or not mapID then return results end
    for _, seg in ipairs(step.segments) do
        if seg.mapID == mapID and seg.points and #seg.points > 0 then
            table.insert(results, seg)
        end
    end
    return results
end
