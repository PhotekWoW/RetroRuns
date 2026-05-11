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
-- are minor enough we don't bother to early-return). Monotonicity is
-- enforced by callers (AdvanceStrictActiveSeg only ever increments by 1, and
-- SeedStrictActiveSeg only ever increases the existing value, never decreases).
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
function RR:AdvanceStrictActiveSeg(currentMapID)
    if not self:UsesStrictActiveSegPicker() then
        return
    end
    local step = self.state.activeStep
    if not step or not step.segments then return end
    local stepIndex = step.step or step.priority or 0
    if stepIndex == 0 then return end
    local activeSeg = self:GetStrictActiveSeg(stepIndex)
    local nextSeg = step.segments[activeSeg + 1]
    if nextSeg and nextSeg.mapID == currentMapID then
        self:SetStrictActiveSeg(stepIndex, activeSeg + 1)
        if self.ZoneLog then
            self:ZoneLog(("strict activeSeg advance: step %d %d -> %d (mapID=%d)")
                :format(stepIndex, activeSeg, activeSeg + 1, currentMapID))
        end
    end
end

-- Called when a step becomes active (post-boss-kill advancement, /reload
-- restoration, fresh login). Seeds the activeSeg to the highest seg index
-- whose mapID matches the player's current mapID. If no seg matches,
-- leaves the activeSeg at its current value (defaults to 1 for never-touched
-- steps, or whatever was persisted).
--
-- Only INCREASES the activeSeg; never decreases. Protects against legitimate
-- mid-step retrace where the player has activeSeg=3 and is currently on
-- seg[1].mapID -- we wouldn't want to seed activeSeg back to 1.
function RR:SeedStrictActiveSeg(step)
    if not self:UsesStrictActiveSegPicker() then
        return
    end
    if not step or not step.segments then return end
    local stepIndex = step.step or step.priority or 0
    if stepIndex == 0 then return end
    local playerMapID = C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")
    if not playerMapID then return end
    local highestMatch = 0
    for i, seg in ipairs(step.segments) do
        if seg.mapID == playerMapID then highestMatch = i end
    end
    if highestMatch == 0 then return end
    local current = self:GetStrictActiveSeg(stepIndex)
    if highestMatch > current then
        self:SetStrictActiveSeg(stepIndex, highestMatch)
        if self.ZoneLog then
            self:ZoneLog(("strict activeSeg seed: step %d %d -> %d (playerMapID=%d)")
                :format(stepIndex, current, highestMatch, playerMapID))
        end
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
