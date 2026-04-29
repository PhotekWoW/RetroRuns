-------------------------------------------------------------------------------
-- RetroRuns -- Navigation.lua
-- Boss resolution, step computation, segment selection, progress tracking,
-- teleport-arrival detection. Pure logic -- no UI or frame references.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Boss lookup
-------------------------------------------------------------------------------

function RR:GetBossByIndex(index)
    if not self.currentRaid then return nil end
    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.index == index then return boss end
    end
end

function RR:GetBossByName(name)
    if not self.currentRaid or not name then return nil end
    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.name == name then return boss end
    end
end

function RR:GetBossByNormalizedName(name)
    if not self.currentRaid or not name then return nil end
    local needle = self:NormalizeName(name)
    for _, boss in ipairs(self.currentRaid.bosses) do
        if self:NormalizeName(boss.name) == needle then return boss end
        if boss.aliases then
            for _, alias in ipairs(boss.aliases) do
                if self:NormalizeName(alias) == needle then return boss end
            end
        end
    end
end

function RR:ResolveBoss(name)
    return self:GetBossByName(name) or self:GetBossByNormalizedName(name)
end

-------------------------------------------------------------------------------
-- Kill state
-------------------------------------------------------------------------------

function RR:IsBossKilled(index)
    return self.state.bossesKilled[index] == true
end

function RR:MarkBossKilled(boss)
    if not boss then return end
    self.state.bossesKilled[boss.index] = true
    if self.state.manualTargetBossIndex == boss.index then
        self.state.manualTargetBossIndex = nil
    end

    -- Mark all segments of this boss's step complete. Route-aware
    -- mapID-change marking (in HandleLocationChange) only marks
    -- segments whose successor's mapID matches the new mapID -- the
    -- LAST segment of any step never matches that rule (no successor)
    -- so it would stay incomplete forever without this. Marking all
    -- segs complete on the kill is also a defense-in-depth: if any
    -- earlier segment got missed by the mapID-change rule (e.g. due
    -- to the player teleporting past it, or a quirk we haven't seen),
    -- the kill cleans up the state anyway.
    local killedStepIndex
    if self.currentRaid and self.currentRaid.routing then
        for _, step in ipairs(self.currentRaid.routing) do
            if step.bossIndex == boss.index and step.segments then
                local stepIndex = step.step or step.priority or 0
                killedStepIndex = stepIndex
                for segIndex = 1, #step.segments do
                    if not self:IsSegmentCompleted(stepIndex, segIndex) then
                        self:MarkSegmentCompleted(stepIndex, segIndex)
                    end
                end
            end
        end
    end

    -- Prune persisted segments for the now-killed step. Persisted
    -- walk progress is only useful for the active step (where the
    -- player is currently routing to); once a boss is killed, that
    -- step's segments are no longer relevant and shouldn't carry
    -- across sessions to confuse the next walk-through. See HANDOFF
    -- 2026-04-26 stale-persistence investigation -- the second-pass
    -- fix that addresses the within-lockout staleness case.
    if killedStepIndex
        and self.currentRaid and self.currentRaid.instanceID
        and RetroRunsDB and RetroRunsDB.completedSegments
    then
        local store = RetroRunsDB.completedSegments[self.currentRaid.instanceID]
        if store and store.segments then
            store.segments[killedStepIndex] = nil
        end
    end
end

function RR:MarkBossKilledByEncounterName(encounterName)
    if not self.currentRaid or not encounterName then
        if self.ZoneLog then
            self:ZoneLog(("MarkBossKilledByEncounterName: bailing -- currentRaid=%s name=%s")
                :format(tostring(self.currentRaid), tostring(encounterName)))
        end
        return
    end
    local boss = self:ResolveBoss(encounterName)
    if boss then
        if self.ZoneLog then
            self:ZoneLog(("MarkBossKilledByEncounterName: resolved %q -> bossIndex %d (%s)")
                :format(encounterName, boss.index, boss.name))
        end
        self:MarkBossKilled(boss)
        self:ComputeNextStep()
    else
        if self.ZoneLog then
            self:ZoneLog(("MarkBossKilledByEncounterName: NO MATCH for %q"):format(encounterName))
        end
        self:Debug("No boss matched encounter: " .. encounterName)
    end
end

function RR:ClearBossState()
    wipe(self.state.bossesKilled)
    -- DO NOT wipe completedSegments here. Segment completion is purely
    -- client-side state derived from player movement (zone-change
    -- transitions, kill-segment proximity), not from saved raid info.
    -- Wiping it on every server-state sync caused freshly-marked
    -- segments to be cleared at the end of the same HandleLocationChange
    -- invocation that marked them, which broke same-mapID disambiguation
    -- in Vault (Terros's two Vault Approach segments). Segments are
    -- wiped only when the user explicitly resets state via /rr reset.
end

-------------------------------------------------------------------------------
-- Segment completion  (keyed by step index + seg index -- never touches data)
-------------------------------------------------------------------------------

function RR:IsSegmentCompleted(stepIndex, segIndex)
    local s = self.state.completedSegments[stepIndex]
    return s and s[segIndex] == true
end

function RR:MarkSegmentCompleted(stepIndex, segIndex)
    self.state.completedSegments[stepIndex] =
        self.state.completedSegments[stepIndex] or {}
    self.state.completedSegments[stepIndex][segIndex] = true

    -- Persist to SavedVariable, scoped by raid instanceID. Segment
    -- completion is purely client-side (no server cache to sync from)
    -- so without persistence, /reload mid-route loses progress and
    -- the renderer's earliest-incomplete picker shows the wrong
    -- segment when multiple segments share a mapID. Restore happens
    -- in LoadCurrentRaid via RestorePersistedSegments. See HANDOFF
    -- 2026-04-25 (initial persistence) and 2026-04-26 (lockout-reset
    -- staleness fix) for context.
    --
    -- Schema includes lockoutId so the restore path can detect when
    -- the weekly reset has rolled a fresh lockout and the stored
    -- segments are stale.
    --
    -- Edge case: lockoutId is nil if no boss has been killed yet this
    -- lockout (no GetSavedInstanceInfo record exists). In that case we
    -- skip persistence entirely -- the restore path can't distinguish
    -- "fresh lockout, zero kills" from "old-schema record with no
    -- lockoutId field," so it would treat the write as stale on next
    -- read anyway. Tradeoff: pre-first-kill walk progress doesn't
    -- survive /reload. Acceptable -- once you kill any boss, lockoutId
    -- populates and persistence resumes working normally.
    if self.currentRaid and self.currentRaid.instanceID and RetroRunsDB then
        local lockoutId = self:GetCurrentLockoutId()
        if lockoutId then
            RetroRunsDB.completedSegments = RetroRunsDB.completedSegments or {}
            local store = RetroRunsDB.completedSegments[self.currentRaid.instanceID]
            -- If the existing record is the old flat-table schema (no
            -- segments field), or doesn't exist yet, OR the lockoutId
            -- has changed since the previous save (cross-lockout
            -- write), replace it with a fresh new-schema record.
            if not store or not store.segments or store.lockoutId ~= lockoutId then
                store = {
                    lockoutId = lockoutId,
                    segments  = {},
                }
            end
            store.segments[stepIndex] = store.segments[stepIndex] or {}
            store.segments[stepIndex][segIndex] = true
            RetroRunsDB.completedSegments[self.currentRaid.instanceID] = store
        end
    end
end

-------------------------------------------------------------------------------
-- Step availability
-------------------------------------------------------------------------------

function RR:RequirementsMet(requirements)
    if not requirements or #requirements == 0 then return true end
    for _, idx in ipairs(requirements) do
        if not self:IsBossKilled(idx) then return false end
    end
    return true
end

function RR:GetAvailableSteps()
    local results = {}
    if not self.currentRaid or not self.currentRaid.routing then return results end
    for _, step in ipairs(self.currentRaid.routing) do
        if not self:IsBossKilled(step.bossIndex)
            and self:RequirementsMet(step.requires) then
            table.insert(results, step)
        end
    end
    table.sort(results, function(a, b)
        return (a.priority or a.step or 999) < (b.priority or b.step or 999)
    end)
    return results
end

function RR:ComputeNextStep()
    self.state.activeStep = nil
    if not self.currentRaid then return nil end
    local available = self:GetAvailableSteps()
    if self.state.manualTargetBossIndex then
        for _, step in ipairs(available) do
            if step.bossIndex == self.state.manualTargetBossIndex then
                self.state.activeStep = step
                return step
            end
        end
        self.state.manualTargetBossIndex = nil
    end
    if #available > 0 then
        self.state.activeStep = available[1]
        return available[1]
    end
    return nil
end

function RR:SetManualTarget(bossIndex)
    self.state.manualTargetBossIndex = bossIndex
    self:ComputeNextStep()
end

-------------------------------------------------------------------------------
-- Progress
-------------------------------------------------------------------------------

-- Returns "X/Y" where X is bosses killed on the player's current
-- difficulty and Y is the raid's total boss count. Currently unused
-- after UI.lua's "Progress: X/Y" line was retired (information now
-- redundant with the per-difficulty pills row in the panel header).
-- Kept available for future callers (tooltip text, alternate UI
-- modes, etc.).
function RR:GetProgressText()
    if not self.currentRaid then return "0/0" end
    local total, killed = #self.currentRaid.bosses, 0
    for _, boss in ipairs(self.currentRaid.bosses) do
        if self:IsBossKilled(boss.index) then killed = killed + 1 end
    end
    return ("%d/%d"):format(killed, total)
end

function RR:GetProgressLines()
    local lines = {}
    if not self.currentRaid then return lines end
    -- 3-state coloring, deliberately NOT 4-state.
    --
    -- Earlier versions distinguished "available but not active" (white)
    -- from "not yet available, prereqs unmet" (gray). The white state
    -- was removed 2026-04-22 because the visual was misleading: in
    -- raids like Castle Nathria with branching DAGs (Sun King's
    -- prereq is Shriekwing, but our recorded solo-clear route visits
    -- Sun King after Altimor/Destroyer/Inerva), a player seeing a
    -- white boss name reads it as "you can fight this next if you
    -- want" -- and going off-route breaks the guide's segment-by-
    -- segment navigation. Now every non-killed, non-active boss is
    -- uniformly "pending" (gray), regardless of prereq state. The
    -- player's only CTA is the yellow active boss.
    --
    -- Killed marker uses Blizzard's ReadyCheck-Ready texture (green
    -- check) to match the Special Loot section's "collected" glyph.
    -- Prior versions used an ASCII "x" which collided visually with
    -- Special Loot's "X" meaning "uncollected" -- same letter,
    -- opposite semantics, on the same panel. Unified glyph removes
    -- the confusion.
    local KILLED_GLYPH = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t"
    for _, boss in ipairs(self.currentRaid.bosses) do
        local marker, color
        if self.state.bossesKilled[boss.index] then
            marker, color = "[" .. KILLED_GLYPH .. "]", "ff00ff00"
        elseif self.state.activeStep
            and self.state.activeStep.bossIndex == boss.index then
            marker, color = "[>]", "ffffff00"
        else
            marker, color = "[ ]", "ff9d9d9d"
        end
        table.insert(lines, ("|c%s%s %s|r"):format(color, marker, boss.name))
    end
    return lines
end

function RR:GetDisplayBossNumber(step, boss)
    if step and step.displayIndex then return step.displayIndex end
    if step and step.step         then return step.step end
    return (boss and boss.index) or (step and step.bossIndex) or 0
end

-------------------------------------------------------------------------------
-- Segment / map helpers
-------------------------------------------------------------------------------

function RR:GetPlayerMapPosition()
    if C_Map and C_Map.GetBestMapForUnit then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then return mapID, pos.x, pos.y end
        end
    end
    return nil, nil, nil
end

function RR:GetRelevantSegmentsForMap(step, mapID)
    local results = {}
    if not step or not step.segments or not mapID then return results end
    local stepIndex = step.step or step.priority or 0
    local matches   = {}
    for segIndex, seg in ipairs(step.segments) do
        -- Note: don't gate on seg.points here. Note-only segments
        -- (no points, just a note) should still match for travel-pane
        -- text purposes -- they're authored when no path-line is
        -- needed (e.g. "the platform is small enough that Blizzard's
        -- own boss icon is sufficient guidance, but the player still
        -- benefits from seeing the next-step note"). The map renderer
        -- already gates on #points > 0 at its draw sites
        -- (DrawSegmentsForMap, DrawAllSegmentsForMap), so note-only
        -- segments are correctly skipped there.
        if not self:IsSegmentCompleted(stepIndex, segIndex)
            and seg.mapID == mapID then
            table.insert(matches, { segIndex = segIndex, seg = seg })
        end
    end
    if #matches <= 1 then
        for _, m in ipairs(matches) do table.insert(results, m.seg) end
        return results
    end
    local _, px, py = self:GetPlayerMapPosition()
    if not px then
        -- Inside raid instances, C_Map.GetPlayerMapPosition returns nil
        -- (Blizzard restriction -- see Recorder.lua's preamble for the
        -- documented behavior). When player position can't be resolved
        -- we default to the EARLIEST incomplete segment matching the
        -- player's mapID, on the principle of "show the player the
        -- next thing they need to do, not the last." This is the path
        -- that fires for every multi-segment-same-mapID case during
        -- actual raid play; the closest-distance heuristic below is
        -- effectively dead code inside instances. Picking matches[#matches]
        -- here would surface a later segment (e.g. Eranog's "After
        -- killing Volcanius..." instead of the dragon flyover) on
        -- fresh zone-in, which is exactly what was reported by
        -- Photek 2026-04-25.
        table.insert(results, matches[1].seg)
        return results
    end
    -- Closest-point heuristic for picking among multiple same-mapID
    -- segments. Skip note-only segments here -- they have no
    -- waypoint to measure distance against. If all candidates are
    -- note-only, fall back to the earliest one.
    local bestSeg, bestDist
    for _, m in ipairs(matches) do
        local pt = m.seg.points and m.seg.points[1]
        if pt then
            local d = (px - pt[1])^2 + (py - pt[2])^2
            if not bestDist or d < bestDist then bestSeg, bestDist = m.seg, d end
        end
    end
    if bestSeg then
        table.insert(results, bestSeg)
    else
        table.insert(results, matches[1].seg)
    end
    return results
end

function RR:GetStepMaps(step)
    step = step or self.state.activeStep
    local maps = {}
    if not step then return maps end
    if step.segments then
        for _, seg in ipairs(step.segments) do
            if seg.mapID then maps[seg.mapID] = true end
        end
    elseif step.mapID then
        maps[step.mapID] = true
    end
    return maps
end

function RR:GetFirstIncompleteSegment(step)
    if not step or not step.segments then return nil end
    local stepIndex = step.step or step.priority or 0
    for segIndex, seg in ipairs(step.segments) do
        if not self:IsSegmentCompleted(stepIndex, segIndex) then return seg end
    end
    return step.segments[1]
end

function RR:ShowCurrentMapForStep()
    local step = self.state.activeStep
    if not step or not WorldMapFrame then return end
    local currentMapID = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    local stepMaps     = self:GetStepMaps(step)
    local activeSeg    = self:GetFirstIncompleteSegment(step)
    local targetMapID  =
        (currentMapID and stepMaps[currentMapID] and currentMapID)
        or (activeSeg and activeSeg.mapID)
        or step.mapID
    if not targetMapID then return end
    if not WorldMapFrame:IsShown() then ToggleWorldMap() end
    C_Timer.After(0, function()
        WorldMapFrame:SetMapID(targetMapID)
        if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
    end)
end

-------------------------------------------------------------------------------
-- Teleport-arrival detection
-------------------------------------------------------------------------------

function RR:CheckTeleportArrivalAdvance()
    local step = self.state.activeStep
    if not step or not step.segments or #step.segments < 2 then return end
    local playerMapID, px, py = self:GetPlayerMapPosition()
    if not playerMapID then return end
    local stepIndex = step.step or step.priority or 0
    for i = 1, #step.segments - 1 do
        local seg     = step.segments[i]
        local nextSeg = step.segments[i + 1]
        if seg.kind == "teleport"
            and not self:IsSegmentCompleted(stepIndex, i)
            and nextSeg.points and #nextSeg.points > 0
            and playerMapID == nextSeg.mapID then
            local arr = nextSeg.points[1]
            if (px - arr[1])^2 + (py - arr[2])^2 <= 0.06^2 then
                self:MarkSegmentCompleted(stepIndex, i)
                RR.UI.Update()
                if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
                return
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Kill-gate advancement  (segment kind="kill" with targetName="<mob name>")
--
-- Position-based, NOT combat-log-based. Advances the segment when the
-- player reaches the last point of the kill segment's path -- i.e. when
-- they've walked to the mini-boss's pull spot. The `targetName` field
-- is kept on the segment for authoring clarity and potential future
-- features (tooltips, status output) but the actual advancement
-- trigger is proximity to points[#points].
--
-- Why position-based instead of CLEU:
--   COMBAT_LOG_EVENT_UNFILTERED registration produces a taint popup
--   on some WoW 12.0 configurations, reproducible with an isolated
--   20-line test addon that does nothing but register CLEU. Not a
--   code-fixable issue -- it's environmental. Position triggers use
--   the existing ticker infrastructure (same pattern as
--   CheckTeleportArrivalAdvance) and have zero taint exposure.
--
-- User-visible behavior:
--   Player walks toward Volcanius along the kill-segment path. When
--   they arrive at his pull spot, they fight him. Seconds after the
--   kill they move off that spot (or before the kill if they kite),
--   and by then the ticker has already marked the segment complete
--   based on proximity to points[#points]. The note advances to the
--   next segment ("the path opens") smoothly. Indistinguishable from
--   the CLEU-triggered version in practice.
--
-- Radius tuning:
--   Uses the same 0.06 radius as CheckTeleportArrivalAdvance, since
--   that's been validated in Sanctum. Represents about a 6% map
--   coordinate distance -- roughly a typical melee-range footprint.
-------------------------------------------------------------------------------

function RR:CheckKillAdvance()
    local step = self.state.activeStep
    if not step or not step.segments then return end
    local playerMapID, px, py = self:GetPlayerMapPosition()
    if not playerMapID then return end
    local stepIndex = step.step or step.priority or 0
    for segIndex, seg in ipairs(step.segments) do
        if seg.kind == "kill"
            and not self:IsSegmentCompleted(stepIndex, segIndex)
            and seg.mapID == playerMapID
            and seg.points and #seg.points > 0 then
            local last = seg.points[#seg.points]
            if (px - last[1])^2 + (py - last[2])^2 <= 0.06^2 then
                self:MarkSegmentCompleted(stepIndex, segIndex)
                RR.UI.Update()
                if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
                return
            end
        end
    end
end

function RR:IsPanelAllowed()
    return self:GetSetting("showPanel") and true or false
end
