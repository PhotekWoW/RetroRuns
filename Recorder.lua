-------------------------------------------------------------------------------
-- RetroRuns -- Recorder.lua
--
-- Map-click route recorder that produces complete, pasteable data entries.
--
-- WORKFLOW:
--   1. /rr record start          -- begin recording on current map
--   2. Open the World Map; SHIFT+CLICK each waypoint along the route
--   3. At a teleporter:
--        /rr record tp <n>    -- closes current segment, marks it as a
--                                  teleport. Open the new map, keep
--                                  shift-clicking; the new clicks attach
--                                  to the new map automatically.
--      At a same-mapID sub-zone threshold (rare):
--        /rr record break     -- closes current segment, opens a fresh
--                                  one with the same mapID. Issue this
--                                  AFTER walking across the threshold,
--                                  before any clicks on the new side.
--   4. /rr record note <text>    -- attach a travel note to the current
--                                  segment (can be issued at any time
--                                  during recording, not just at the end)
--   5. /rr record stop           -- finalise
--   6. /rr record dump           -- open a copy window with a complete,
--                                  pasteable routing entry
--                                  (also saved to RetroRunsDB.lastRecording)
--   7. /rr record reset          -- clear and start fresh
--
-- WHY SHIFT-CLICK INSTEAD OF AUTO-POSITION SAMPLING:
-- Blizzard restricts `C_Map.GetPlayerMapPosition` inside instances (it
-- returns nil), which makes auto-position recording useless for raid
-- routing. Shift-click on the World Map works in every context because
-- it reads positions FROM the map UI, not from the player's coordinates.
-------------------------------------------------------------------------------

local RR = RetroRuns

RR.recorder = {
    active   = false,
    segments = {},     -- list of completed segments
    current  = nil,    -- segment being built right now

    -- Auto-stamping infrastructure (added to fix the destination-metadata
    -- class of bug -- segments authored against the visible-map mapID and
    -- the recorder's-physical-location subZone, which describes the LEAVING
    -- point not the ARRIVING point. Especially bites on forced-flight
    -- transitions where the player physically lands on a different mapID
    -- than the one they were clicking points on.)
    --
    -- Two events trigger automatic stamping:
    --   * ENCOUNTER_END (success=1)  -> just-killed boss is the seg's
    --       intended destination. Stamp player's physical mapID + subZone.
    --   * PLAYER_CONTROL_GAINED after PLAYER_CONTROL_LOST -> player just
    --       finished a transition that took control away (gryphon flight,
    --       taxi, scripted teleport). Stamp post-transition location.
    --
    -- Filter: PLAYER_CONTROL_GAINED only triggers a stamp if the player's
    -- mapID actually changed during the control-lost period. Combat CC
    -- and short mount-lock effects produce control-lost/gained pairs but
    -- don't move the player; filtering these out keeps stamping aligned
    -- with actual destination transitions.
    --
    -- Pending-event persistence: events fired BETWEEN recording sessions
    -- (after stop, before next start) are queued in pendingEvent and
    -- consumed on the first seg of the NEXT session. Necessary because
    -- the typical workflow records one segment per leg (start/click/stop)
    -- with boss kills and flight landings happening at the seam between
    -- sessions -- if pending events weren't persisted, the most useful
    -- auto-stamps would never fire onto a real seg.
    --
    -- Stale-event expiry: pending events older than 60s are discarded
    -- on consumption. Prevents a long break between sessions from
    -- mis-attributing an old event to an unrelated new seg.
    --
    -- Stamp records (segIndex, eventName, capturedMapID, capturedSubZone,
    -- pending=true|nil) accumulate in stampLog so the dump can surface
    -- them as comments. Pending=true marks stamps that came from a queued
    -- event rather than a within-session one.
    controlLostMapID = nil,    -- set on PLAYER_CONTROL_LOST, cleared on GAINED
    pendingEvent     = nil,    -- { event, mapID, subZone, time } between sessions
    stampLog         = {},     -- list of { segIndex, event, mapID, subZone, pending? }
    eventFrame       = nil,    -- registered lazily on first StartRecording

    -- Verbose session log: timestamped record of every meaningful
    -- event during a recording session. Persisted to RetroRunsDB so
    -- it survives /reload (necessary for diagnosing bugs that involve
    -- reloads). Accumulates across start/stop cycles -- only cleared
    -- on /rr record reset or when capped at MAX_SESSION_LOG_ENTRIES.
    --
    -- Each entry: { time, kind, ... } where `kind` is a short string
    -- ("Click", "AutoStamp", "Queue", "ConsumeEvent", etc.) and the
    -- remaining fields are kind-specific. Helper LogSession() builds
    -- the entry and handles capping.
    --
    -- Restoration from RetroRunsDB happens in StartRecording (pulls
    -- previous-session entries forward so a reload mid-recording
    -- doesn't lose context). Saving to RetroRunsDB happens
    -- continuously -- every LogSession write also writes-through to
    -- RetroRunsDB.recorderSessionLog.
    sessionLog       = {},     -- list of timestamped log entries
}

-- Cap on session log size to prevent unbounded RetroRunsDB growth on
-- long recording streaks. 2000 entries comfortably covers a full raid
-- recording session even at maximum verbosity. Older entries are
-- dropped FIFO-style when the cap is exceeded.
local MAX_SESSION_LOG_ENTRIES = 2000

-- Append a timestamped entry to the session log AND persist to
-- RetroRunsDB so /reload doesn't lose context. Caps the log at
-- MAX_SESSION_LOG_ENTRIES, dropping oldest entries first.
--
-- Caller passes a `kind` string and a table of additional fields.
-- The fields table is shallow-copied into the entry; caller can
-- safely mutate the original after the call.
--
-- Each entry is stamped with the current raid name (RR.currentRaid.name)
-- so that ShowRecorderSessionLog can default-filter to "just this raid"
-- when the player is in one, while still preserving a cross-raid view
-- via `/rr sessionlog all`. Entries logged outside any raid context
-- (raid = nil) are always shown regardless of filter.
local function LogSession(rec, kind, fields)
    local entry = { time = GetTime and GetTime() or 0, kind = kind }
    if RR.currentRaid and RR.currentRaid.name then
        entry.raid = RR.currentRaid.name
    end
    if fields then
        for k, v in pairs(fields) do entry[k] = v end
    end
    table.insert(rec.sessionLog, entry)
    -- Cap: drop oldest if over the limit. table.remove(t, 1) is O(n)
    -- but we're talking about a 2000-entry table at worst -- rare and
    -- cheap enough that the simplicity beats a ring buffer.
    while #rec.sessionLog > MAX_SESSION_LOG_ENTRIES do
        table.remove(rec.sessionLog, 1)
    end
    -- Write-through to RetroRunsDB. Lazy-init the table since we may
    -- log before the addon-load init runs. Pointer-shared with the
    -- recorder's in-memory copy is fine -- they're the same table.
    if RetroRunsDB then
        RetroRunsDB.recorderSessionLog = rec.sessionLog
    end
end

-- Public wrapper so other files can append to the same session log used
-- by recorder events. Caller passes a kind string and a fields table
-- (same shape as the internal LogSession). Used by UI.lua's travel-pane
-- picker to record what seg note was returned for each fetch -- needed
-- to diagnose seg-picker bugs that otherwise leave no trail (the picker
-- is called every heartbeat tick and can return different segs for the
-- same player location depending on subZone, completion state, etc).
function RR:LogRecorderSession(kind, fields)
    LogSession(self.recorder, kind, fields)
end

-------------------------------------------------------------------------------
-- Internal helpers
-------------------------------------------------------------------------------

local function R3(v) return tonumber(("%.3f"):format(v)) end

-- Get the mapID currently displayed in the World Map. Falls back to the
-- player's best map (works outside instances; will likely fail in raids
-- where Blizzard restricts map APIs).
local function CurrentMapID()
    if WorldMapFrame and WorldMapFrame:IsShown() and WorldMapFrame:GetMapID() then
        return WorldMapFrame:GetMapID()
    end
    return C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
end

local function NewSegment(mapID, kind)
    return {
        mapID   = mapID,
        kind    = kind or "path",
        note    = nil,
        subZone = nil,   -- player's sub-zone string at the most recent click;
                         -- captured for human-readable dumps and for future
                         -- engine use, NOT currently consulted by routing
                         -- logic (which only uses mapID for segment
                         -- advancement). Updated on every shift-click so
                         -- the final value reflects the segment's endpoint.
                         -- Sub-zones that GetSubZoneText returns "" for
                         -- (e.g. Primal Convergence) end up with an empty
                         -- subZone field, which is honest data but means
                         -- those segments get no subZone field in the dump.
        points  = {},
    }
end

-- Auto-stamp the current segment's mapID and subZone from the player's
-- physical location right now. Called by event handlers (ENCOUNTER_END,
-- PLAYER_CONTROL_GAINED) and the manual "Mark Destination" DevTools
-- button. Records the stamp in rec.stampLog so the dump can surface
-- which segs were auto-stamped vs manually authored.
--
-- segIndex passed to stampLog is the index the seg WILL HAVE in the
-- final segs list -- #rec.segments + 1, since rec.current isn't yet
-- in segs. Lets the dump annotate "seg 3 was auto-stamped by
-- ENCOUNTER_END" against the correct seg.
--
-- No-op if recording isn't active or if rec.current is nil. Stamps
-- even if rec.current.points is empty (the empty seg might pick up
-- clicks afterward and we want the metadata correct from the start).
local function AutoStampCurrent(rec, eventName)
    if not rec.active or not rec.current then
        LogSession(rec, "AutoStampSkipped", {
            event  = eventName,
            reason = (not rec.active) and "not active" or "no current seg",
        })
        return
    end

    local mapID = C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")
    local subZone = GetSubZoneText and GetSubZoneText() or ""
    if not mapID then
        LogSession(rec, "AutoStampSkipped", {
            event  = eventName,
            reason = "GetBestMapForUnit returned nil",
        })
        return
    end

    rec.current.mapID         = mapID
    rec.current.subZone       = subZone
    -- Mark this seg as auto-stamped: its subZone field is now reliably
    -- the destination subZone (not a recorder-default leftover from
    -- click-time). Emitting gateBySubZone=true in the dump tells the
    -- renderer's seg-picker to require both mapID AND subZone to match,
    -- preventing transit-zone false-matches like the Mekkatorque
    -- gryphon flight briefly transiting through mapID 1352 and
    -- false-matching seg 4. See UI.lua and Navigation.lua picker logic.
    --
    -- Skipped for raids that opt in to the strict-activeSeg picker.
    -- The strict picker fixes the same transit-flash class of bugs
    -- by design (see Data/StrictPicker.lua header), so emitting
    -- gateBySubZone for those raids would be dead data carrying
    -- anti-pattern intent.
    if not (RR.UsesStrictActiveSegPicker and RR:UsesStrictActiveSegPicker()) then
        rec.current.gateBySubZone = true
    end

    local segIndex = #rec.segments + 1
    table.insert(rec.stampLog, {
        segIndex = segIndex,
        event    = eventName,
        mapID    = mapID,
        subZone  = subZone,
    })

    LogSession(rec, "AutoStamp", {
        event    = eventName,
        segIndex = segIndex,
        mapID    = mapID,
        subZone  = subZone,
    })
end

-- Queue an event for consumption by the next recording session. Called
-- when an event fires and recording is inactive (between sessions) -- the
-- typical case in the multi-segment-per-boss workflow where boss kills
-- and flight landings happen at the seam between sessions.
local function QueuePendingEvent(eventName)
    local mapID = C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")
    local subZone = GetSubZoneText and GetSubZoneText() or ""
    if not mapID then
        LogSession(RR.recorder, "QueueSkipped", {
            event  = eventName,
            reason = "GetBestMapForUnit returned nil",
        })
        return
    end
    RR.recorder.pendingEvent = {
        event   = eventName,
        mapID   = mapID,
        subZone = subZone,
        time    = time and time() or 0,   -- epoch seconds; survives /reload
    }
    -- Persist to RetroRunsDB so a /reload between queue and consume
    -- (e.g. user reloads mid-session to install a dev build) doesn't
    -- silently lose the queued event. Restored at addon load alongside
    -- sessionLog. See InitializeDB in Core.lua.
    if RetroRunsDB then
        RetroRunsDB.recorderPendingEvent = RR.recorder.pendingEvent
    end
    LogSession(RR.recorder, "Queue", {
        event   = eventName,
        mapID   = mapID,
        subZone = subZone,
    })
end

-- Event handler. Dispatches ENCOUNTER_END (success=1) and the
-- PLAYER_CONTROL_LOST/GAINED pair through to AutoStampCurrent when
-- recording is active, or to QueuePendingEvent when inactive.
--
-- PLAYER_CONTROL_LOST/GAINED filtering: stash the player's mapID at
-- LOST time, and only stamp on GAINED if the mapID has changed since.
-- This filters out combat CC and mount locks that produce a
-- control-lost/gained pair without actually moving the player.
--
-- LOST tracking happens regardless of recording state -- need it cached
-- so a GAINED event between sessions can still apply the filter.
local function OnRecorderEvent(self, event, ...)
    local rec = RR.recorder

    if event == "ENCOUNTER_END" then
        local _, encName, _, _, success = ...
        LogSession(rec, "Event", {
            event           = "ENCOUNTER_END",
            encounterName   = encName or "?",
            success         = success,
            recordingActive = rec.active,
        })
        if success == 1 then
            if rec.active then
                AutoStampCurrent(rec, "ENCOUNTER_END")
            else
                QueuePendingEvent("ENCOUNTER_END")
            end
        end
    elseif event == "PLAYER_CONTROL_LOST" then
        local mapID = C_Map and C_Map.GetBestMapForUnit
            and C_Map.GetBestMapForUnit("player")
        rec.controlLostMapID = mapID
        LogSession(rec, "Event", {
            event              = "PLAYER_CONTROL_LOST",
            stashedMapID       = mapID,
            recordingActive    = rec.active,
        })
        -- Diagnostic-only: log the LOST when recording is active so we
        -- can later tell if the GAINED side got filtered vs. never fired.
        if rec.active and rec.current then
            table.insert(rec.stampLog, {
                segIndex = #rec.segments + 1,
                event    = "PLAYER_CONTROL_LOST (diagnostic)",
                mapID    = mapID,
                subZone  = "(not captured at LOST)",
            })
        end
    elseif event == "PLAYER_CONTROL_GAINED" then
        local previousMapID = rec.controlLostMapID
        rec.controlLostMapID = nil
        local currentMapID = C_Map and C_Map.GetBestMapForUnit
            and C_Map.GetBestMapForUnit("player")
        LogSession(rec, "Event", {
            event              = "PLAYER_CONTROL_GAINED",
            previousMapID      = previousMapID or "(no LOST stashed)",
            currentMapID       = currentMapID,
            mapIDChanged       = (previousMapID and currentMapID and currentMapID ~= previousMapID) or false,
            recordingActive    = rec.active,
        })
        if not previousMapID then return end
        if currentMapID and currentMapID ~= previousMapID then
            if rec.active then
                AutoStampCurrent(rec, "PLAYER_CONTROL_GAINED")
            else
                QueuePendingEvent("PLAYER_CONTROL_GAINED")
            end
        elseif rec.active and rec.current then
            -- Diagnostic-only: filtered-out GAINED, recording active.
            local subZone = GetSubZoneText and GetSubZoneText() or ""
            table.insert(rec.stampLog, {
                segIndex = #rec.segments + 1,
                event    = "PLAYER_CONTROL_GAINED (FILTERED: no mapID change)",
                mapID    = currentMapID or 0,
                subZone  = subZone,
            })
        end
    end
end

-- Consume any pending event at the start of a new recording session.
-- Stamps the current seg with the queued event's metadata, OR discards
-- the event if it's older than 60s (stale -- author probably took a
-- long break and the queued event is unrelated to what they're now
-- recording). Marks the stamp log entry with `pending = true` so the
-- author can see this stamp came from a cross-session queue rather
-- than a within-session event.
local function ConsumePendingEvent(rec)
    local pending = rec.pendingEvent
    rec.pendingEvent = nil
    -- Clear persisted copy too -- a /reload between consume and the
    -- next queue would otherwise restore an already-consumed event.
    if RetroRunsDB then
        RetroRunsDB.recorderPendingEvent = nil
    end
    if not pending then
        LogSession(rec, "Consume", { result = "no pending event" })
        return
    end

    -- Staleness check uses time() (epoch seconds) rather than GetTime()
    -- (seconds-since-WoW-launch) because GetTime() resets on /reload --
    -- a queued event that survived a reload would have a pending.time
    -- value from the prior session that's not comparable to the new
    -- session's GetTime(). pending.time was written as time() in
    -- QueuePendingEvent for exactly this reason.
    local now = time and time() or 0
    local age = now - (pending.time or 0)
    if age > 60 then
        -- Stale -- log the discard so the author isn't surprised by a
        -- missing stamp.
        table.insert(rec.stampLog, {
            segIndex = #rec.segments + 1,
            event    = ("%s (DISCARDED: %.0fs stale)"):format(pending.event, age),
            mapID    = pending.mapID or 0,
            subZone  = pending.subZone or "",
        })
        LogSession(rec, "Consume", {
            result    = "DISCARDED stale",
            event     = pending.event,
            ageSecs   = ("%.1f"):format(age),
            mapID     = pending.mapID or 0,
            subZone   = pending.subZone or "",
        })
        return
    end

    if not rec.current then
        LogSession(rec, "Consume", { result = "no current seg to stamp" })
        return
    end
    rec.current.mapID         = pending.mapID
    rec.current.subZone       = pending.subZone
    -- See AutoStampCurrent for rationale on gateBySubZone (and the
    -- v1.7 strict-picker exception).
    if not (RR.UsesStrictActiveSegPicker and RR:UsesStrictActiveSegPicker()) then
        rec.current.gateBySubZone = true
    end
    table.insert(rec.stampLog, {
        segIndex = #rec.segments + 1,
        event    = pending.event,
        mapID    = pending.mapID,
        subZone  = pending.subZone,
        pending  = true,
    })
    LogSession(rec, "Consume", {
        result    = "consumed",
        event     = pending.event,
        ageSecs   = ("%.1f"):format(age),
        mapID     = pending.mapID,
        subZone   = pending.subZone,
    })
    -- Stash a copy in case StopRecording ends up dropping the only seg
    -- (zero-points discard via existing line-179 guard). Without this
    -- restore-on-empty path, a brief throwaway recording session
    -- (cutscene-cancellation, accidental start/stop, etc.) silently
    -- consumes a queued event onto a soon-to-be-dropped seg, and the
    -- event vanishes -- the next real session sees an empty queue and
    -- the auto-stamp goes missing. Restoring at Stop preserves the
    -- queued event for the next session, where it actually belongs.
    rec.consumedPendingThisSession = {
        event   = pending.event,
        mapID   = pending.mapID,
        subZone = pending.subZone,
        time    = pending.time,
    }
end

-- Lazy event-frame setup. Registered on first StartRecording, kept
-- alive across recordings (cheap; events only act when rec.active).
local function EnsureEventFrame()
    local rec = RR.recorder
    if rec.eventFrame then return end
    local f = CreateFrame("Frame")
    f:RegisterEvent("ENCOUNTER_END")
    f:RegisterEvent("PLAYER_CONTROL_LOST")
    f:RegisterEvent("PLAYER_CONTROL_GAINED")
    f:SetScript("OnEvent", OnRecorderEvent)
    rec.eventFrame = f
end

-- Manual auto-stamp trigger for the "Mark Destination" DevTools button.
-- Use when neither ENCOUNTER_END nor PLAYER_CONTROL_GAINED fires at the
-- destination -- intermediate non-boss locations, seamless portals,
-- mid-zone destinations like "stand at the orb" that have no Blizzard
-- event. Stamps the current segment with the player's physical mapID
-- and subZone right now.
function RR:RecorderMarkDestination()
    local rec = self.recorder
    if not rec.active then
        LogSession(rec, "MarkDestination", { result = "rejected: not active" })
        self:Print("Recorder is not running. Start recording first.")
        return
    end
    if not rec.current then
        LogSession(rec, "MarkDestination", { result = "rejected: no current seg" })
        self:Print("No active segment to stamp.")
        return
    end
    AutoStampCurrent(rec, "MANUAL")
    self:Print(("Stamped current segment: mapID=%d subZone=%q"):format(
        rec.current.mapID or 0, rec.current.subZone or ""))
end

-------------------------------------------------------------------------------
-- Click integration with MapOverlay
--
-- MapOverlay.lua hooks `WorldMapFrame.ScrollContainer:OnMouseUp` for the
-- entire addon and dispatches left-clicks here via RR:RecorderHandleMapClick.
-- We don't install our own hook (would duplicate MapOverlay's). Per-click
-- logic lives entirely in this method.
--
-- The method is called on EVERY left-click on the map; we only act when
-- recording is active AND shift is held. Other clicks (drag-pan, normal
-- left-clicks for navigation, etc.) pass through untouched.
-------------------------------------------------------------------------------

function RR:RecorderHandleMapClick()
    local rec = self.recorder
    if not rec.active then return end
    if not IsShiftKeyDown() then return end
    if not rec.current then return end
    if not WorldMapFrame or not WorldMapFrame.ScrollContainer then return end

    local container = WorldMapFrame.ScrollContainer

    -- Convert screen-space cursor position to map-normalized coords. Wrapped
    -- in pcall to defend against future Blizzard API changes -- if either
    -- GetCursorPosition or NormalizeUIPosition disappears or changes its
    -- signature, we want to silently no-op rather than throw a Lua error
    -- on every map click. (A previous version of this hook errored loudly
    -- because of a missing method; pcall would have prevented user-visible
    -- errors during that bug.)
    local ok, cx, cy = pcall(container.GetCursorPosition, container)
    if not ok or not cx or not cy then
        if not ok then self:Debug("RecorderHandleMapClick: GetCursorPosition failed: " .. tostring(cx)) end
        return
    end
    local ok2, nx, ny = pcall(container.NormalizeUIPosition, container, cx, cy)
    if not ok2 or not nx or not ny or nx < 0 or nx > 1 or ny < 0 or ny > 1 then
        if not ok2 then self:Debug("RecorderHandleMapClick: NormalizeUIPosition failed: " .. tostring(nx)) end
        return
    end

    -- Use the World Map's currently-displayed mapID. If the user has
    -- changed maps (e.g. after a teleport), this will reflect the new
    -- map automatically.
    local ok3, visibleMapID = pcall(WorldMapFrame.GetMapID, WorldMapFrame)
    if not ok3 or not visibleMapID then return end

    -- If the visible map differs from the current segment's map, the
    -- user is mapping a different floor/zone now. Close the current
    -- segment (if it has any points) and open a new one. This lets a
    -- multi-map raid be recorded by just changing the World Map's
    -- displayed map between clicks -- no /rr record tp needed for
    -- pure map-floor changes (only for actual teleporter usage where
    -- the segment kind needs to be "teleport").
    if rec.current.mapID ~= visibleMapID then
        -- Diagnostic: log the discard if we're about to throw away an
        -- auto-stamped empty seg. This catches the suspected bug where
        -- ConsumePendingEvent stamps the seg with the player's physical
        -- mapID, but the user has the world map open to a different
        -- mapID, so the first shift-click immediately discards the
        -- stamped seg and creates a fresh one with the visible-map
        -- mapID. Auto-stamp metadata lost.
        if #rec.current.points == 0
            and rec.consumedPendingThisSession
        then
            table.insert(rec.stampLog, {
                segIndex = #rec.segments + 1,
                event    = ("CLICK_HANDLER_DISCARD: stamped seg discarded -- rec.current.mapID=%d visibleMapID=%d (stamp from %s)"):format(
                    rec.current.mapID or 0,
                    visibleMapID,
                    rec.consumedPendingThisSession.event or "?"),
                mapID    = rec.current.mapID or 0,
                subZone  = rec.current.subZone or "",
            })
        end
        LogSession(rec, "SegCut", {
            reason         = "visible-map mismatch",
            oldSegMapID    = rec.current.mapID or 0,
            oldSegPoints   = #rec.current.points,
            newSegMapID    = visibleMapID,
            droppedEmpty   = (#rec.current.points == 0),
            wasStamped     = (rec.consumedPendingThisSession ~= nil),
        })
        if #rec.current.points > 0 then
            table.insert(rec.segments, rec.current)
        end
        rec.current = NewSegment(visibleMapID, "path")
    end

    table.insert(rec.current.points, { R3(nx), R3(ny) })

    -- Capture the player's current sub-zone string. Updated on every
    -- click so the final value on the segment reflects the destination
    -- (the spot the player is standing when they finish mapping the
    -- route). Empty string means the player is in the parent zone with
    -- no named sub-zone (still useful as a distinct value vs. nil).
    if GetSubZoneText then
        rec.current.subZone = GetSubZoneText()
    end

    LogSession(rec, "Click", {
        cursor             = ("(%.3f, %.3f)"):format(R3(nx), R3(ny)),
        visibleMapID       = visibleMapID,
        currentSegMapID    = rec.current.mapID or 0,
        playerMapID        = C_Map and C_Map.GetBestMapForUnit
            and C_Map.GetBestMapForUnit("player"),
        playerSubZone      = GetSubZoneText and GetSubZoneText() or "",
        currentSegPoints   = #rec.current.points,
    })
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

function RR:StartRecording()
    local rec = self.recorder
    if rec.active then self:Print("Recorder is already running.") ; return end

    -- Pick a starting map. Prefer whatever the World Map is showing right
    -- now (the user is probably looking at the map they want to record on).
    -- Fall back to player's current map.
    local mapID = CurrentMapID()
    if not mapID then
        self:Print("Cannot determine map. Open the World Map first.")
        return
    end

    rec.active           = true
    rec.segments         = {}
    rec.current          = NewSegment(mapID, "path")
    rec.stampLog         = {}
    -- Note: controlLostMapID is NOT reset -- a LOST event between
    -- sessions still needs to be available for filter-checking when
    -- its corresponding GAINED arrives. Same for pendingEvent, which
    -- ConsumePendingEvent below will read and clear.

    LogSession(rec, "StartRecording", {
        startMapID         = mapID,
        playerMapID        = C_Map and C_Map.GetBestMapForUnit
            and C_Map.GetBestMapForUnit("player"),
        playerSubZone      = GetSubZoneText and GetSubZoneText() or "",
        hasPendingEvent    = rec.pendingEvent and rec.pendingEvent.event or "(none)",
        controlLostStashed = rec.controlLostMapID or "(nil)",
    })

    EnsureEventFrame()
    ConsumePendingEvent(rec)

    self:Print("Recording started.")
end

function RR:StopRecording()
    local rec = self.recorder
    rec.active = false

    local pointsInCurrent = (rec.current and #rec.current.points) or 0
    if rec.current then
        if #rec.current.points > 0 then
            table.insert(rec.segments, rec.current)
        end
        rec.current = nil
    end

    -- Restore-on-empty: if this session consumed a pending event but
    -- ended up producing zero kept segs (typical case: a brief
    -- start/stop to dodge a cutscene), put the event back in the queue
    -- so the next real session can pick it up. Without this, the
    -- queued event is silently lost -- the soon-to-be-dropped seg ate
    -- the stamp and went away with it. See ConsumePendingEvent for
    -- where consumedPendingThisSession gets set.
    local restoredPending = false
    if #rec.segments == 0 and rec.consumedPendingThisSession then
        rec.pendingEvent = rec.consumedPendingThisSession
        restoredPending = true
        -- Re-persist so a /reload after this empty stop doesn't lose
        -- the just-restored event.
        if RetroRunsDB then
            RetroRunsDB.recorderPendingEvent = rec.pendingEvent
        end
    end
    rec.consumedPendingThisSession = nil

    LogSession(rec, "StopRecording", {
        segsKept          = #rec.segments,
        pointsInCurrent   = pointsInCurrent,
        restoredPending   = restoredPending,
        playerMapID       = C_Map and C_Map.GetBestMapForUnit
            and C_Map.GetBestMapForUnit("player"),
        playerSubZone     = GetSubZoneText and GetSubZoneText() or "",
    })

    self:Print("Recording stopped.")

    -- Auto-dump on stop. The author's workflow always wants to see (and
    -- copy) the export immediately after stopping; previously this
    -- required a separate /rr record dump call. Auto-firing the dump
    -- saves a keystroke per recording and matches the natural "stop
    -- and show me what I caught" mental model. If there's nothing to
    -- export (Start -> Stop with no shift-clicks), say so explicitly --
    -- silent skip caused confusion when the export window failed to
    -- appear and the user couldn't tell whether Stop had registered.
    if #rec.segments > 0 then
        self:DumpRecording()
    else
        self:Print("No waypoints captured.")
    end
end

--- Called at a teleporter. Closes the current walking segment, marks it as
--- a teleport kind, and opens a fresh segment that will pick up the new
--- map's ID on the next shift-click.
function RR:RecordTeleport(destination)
    local rec = self.recorder
    if not rec.active then
        self:Print("Recorder is not running. Use /rr record start first.")
        return
    end

    -- Finalise the current segment as a teleport segment
    if rec.current then
        rec.current.kind = "teleport"
        rec.current.destination = destination
        if not rec.current.note then
            rec.current.note = ("Use the teleporter and select %s."):format(destination)
        end
        if #rec.current.points > 0 then
            table.insert(rec.segments, rec.current)
        end
    end

    -- Open a placeholder segment with no mapID. The first shift-click on
    -- the new map will detect the mapID mismatch and rotate this segment
    -- with a properly-mapID'd one. (See RecorderHandleMapClick.)
    rec.current = NewSegment(0, "path")  -- mapID=0 is a sentinel; first click overwrites

    self:Print(("Teleport marked: %s"):format(destination))
    self:Print("  Open the new map after teleporting, then SHIFT+CLICK to continue.")
end

--- Insert a segment break on the current map. Closes the current segment and
--- opens a fresh one with the SAME mapID. Use when the player crosses a
--- sub-zone threshold inside a single map (e.g. Vault Approach -> Quarry of
--- Infusion, both on mapID 2122) and the route engine needs the two halves
--- as separate segments for disambiguation. The new segment will pick up
--- the player's current sub-zone string on its first shift-click, since
--- subZone is captured per-click and reflects the most recent value.
---
--- Distinct from RecordTeleport: no kind change, no mapID change, no
--- destination string. Just "stop this segment here, start a new one."
function RR:RecordBreak()
    local rec = self.recorder
    if not rec.active then
        self:Print("Recorder is not running. Use /rr record start first.")
        return
    end
    if not rec.current or #rec.current.points == 0 then
        self:Print("No points in current segment yet; nothing to break.")
        return
    end
    local mapID = rec.current.mapID
    LogSession(rec, "RecordBreak", {
        oldSegMapID  = mapID,
        oldSegPoints = #rec.current.points,
    })
    table.insert(rec.segments, rec.current)
    rec.current = NewSegment(mapID, "path")
    self:Print(("Segment break inserted (mapID %d). Continue shift-clicking."):format(mapID))
end

--- Attach a travel note to the current segment.
function RR:RecordSetNote(text)
    local rec = self.recorder
    if not rec.active then
        self:Print("Recorder is not running.")
        return
    end
    local target = rec.current or rec.segments[#rec.segments]
    if not target then
        self:Print("No segment to annotate.")
        return
    end
    target.note = text
    self:Print("Note set: " .. text)
end

--- Render the verbose recorder session log into a copy window. Called
--- by the DevTools "Session Log" button. Each log entry rendered as
--- "[time] kind  field=value field=value ..." -- one line per entry.
--- Time is formatted as seconds-since-session-start (relative to the
--- earliest entry) so absolute clock noise doesn't dominate.
---
--- The session log persists across /reload and across start/stop
--- cycles, so this view shows the full history of recorder activity
--- since the last /rr record reset.
---
--- @param showAll boolean? When truthy, shows ALL entries regardless of
---        raid context (cross-raid chronological view). When falsy/nil
---        and the player is currently in a known raid, filters to entries
---        stamped with that raid's name (plus any unstamped entries, which
---        were logged outside raid context). When falsy/nil and the player
---        is not in a raid, shows all entries.
function RR:ShowRecorderSessionLog(showAll)
    local rec = self.recorder
    local log = rec.sessionLog or {}

    -- Decide filter: if showAll is set, no filter. Otherwise filter to
    -- the current raid (if we're in one). This default-current-raid
    -- behavior keeps the log readable when bouncing between raids in
    -- one play session -- without it, debugging an issue in one raid
    -- surfaces entries from a prior run in a different raid that just
    -- clutter the view.
    local filterRaid = nil
    if not showAll and self.currentRaid and self.currentRaid.name then
        filterRaid = self.currentRaid.name
    end

    local filtered = log
    if filterRaid then
        filtered = {}
        for _, entry in ipairs(log) do
            -- Include entries stamped with this raid name. Entries
            -- without a raid stamp (logged outside any raid) are
            -- excluded from per-raid views; they're only visible via
            -- /rr sessionlog all. This is the right default since
            -- cross-raid noise like login-time events shouldn't show
            -- up in "what just happened in this raid."
            if entry.raid == filterRaid then
                table.insert(filtered, entry)
            end
        end
    end

    if #filtered == 0 then
        local msg
        if filterRaid then
            msg = ("(no entries for %s -- use /rr sessionlog all to see all entries)"):format(filterRaid)
        else
            msg = "(empty -- no recorder activity since last reset)"
        end
        self:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaRecorder Session Log|r",
            msg)
        return
    end

    local out = {}
    if filterRaid then
        table.insert(out, ("Session log: %d entries for %s (oldest first; %d total in buffer; /rr sessionlog all for cross-raid view)"):format(
            #filtered, filterRaid, #log))
    else
        table.insert(out, ("Session log: %d entries (oldest first)"):format(#filtered))
    end
    table.insert(out, "")

    local startTime = filtered[1].time or 0
    for _, entry in ipairs(filtered) do
        local relTime = (entry.time or 0) - startTime
        local fields = {}
        for k, v in pairs(entry) do
            -- Don't print `raid` as a field when filtering to one raid;
            -- it's redundant. Always show it in the all-entries view so
            -- the reader can tell which raid each entry came from.
            if k ~= "time" and k ~= "kind" and not (k == "raid" and filterRaid) then
                table.insert(fields, ("%s=%s"):format(k, tostring(v)))
            end
        end
        table.sort(fields)
        table.insert(out, ("[%7.2fs] %-18s  %s"):format(
            relTime, entry.kind or "?", table.concat(fields, "  ")))
    end

    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaRecorder Session Log|r",
        table.concat(out, "\n"))
end

function RR:ResetRecording()
    local rec = self.recorder
    LogSession(rec, "ResetRecording", { sessionLogCleared = true })
    rec.active, rec.segments, rec.current = false, {}, nil
    rec.stampLog = {}
    rec.sessionLog = {}
    rec.consumedPendingThisSession = nil
    rec.pendingEvent = nil
    rec.controlLostMapID = nil
    if RetroRunsDB then
        RetroRunsDB.recorderSessionLog = rec.sessionLog
        RetroRunsDB.recorderPendingEvent = nil
    end
    self:Print("Recorder reset (session log cleared).")
end

function RR:RecordingStatus()
    local rec = self.recorder
    local pts = (rec.current and #rec.current.points) or 0
    local mapStr = "(none)"
    if rec.current and rec.current.mapID and rec.current.mapID ~= 0 then
        mapStr = tostring(rec.current.mapID)
    end
    self:Print(("Recorder: %s | segments=%d | current points=%d | map=%s"):format(
        rec.active and "ACTIVE" or "stopped",
        #rec.segments, pts, mapStr))
end

-------------------------------------------------------------------------------
-- Export
--
-- Produces a complete segments = { ... } block suitable for pasting directly
-- into a raid data file's `routing[]` array. The user supplies bossIndex,
-- requires, soloTip, and achievements separately.
-------------------------------------------------------------------------------

function RR:BuildRecordingExport()
    local rec = self.recorder
    local segs = rec.segments

    -- If recording is still active and there's an in-progress segment with
    -- points, include it in the export so the user doesn't have to /rr
    -- record stop first.
    if rec.active and rec.current and #rec.current.points > 0 then
        segs = {}
        for _, s in ipairs(rec.segments) do table.insert(segs, s) end
        table.insert(segs, rec.current)
    end

    if #segs == 0 then return nil, "No segments recorded." end

    local out = {}
    table.insert(out, "-- Paste into the raid's routing[] array. Fill in TODOs.")

    -- Stamp log: one comment line per auto-stamp event that fired during
    -- recording, ordered as they occurred. Lets the author verify which
    -- segs got authoritative metadata from the auto-stamp system vs.
    -- which still rely on the recorder's "visible-map mapID + player-
    -- physical-subZone" defaults. If a seg you expected to see in the
    -- log isn't there, that seg's mapID/subZone may need manual review.
    if rec.stampLog and #rec.stampLog > 0 then
        table.insert(out, "-- Auto-stamp log:")
        for _, s in ipairs(rec.stampLog) do
            local pendingTag = s.pending and " [from pending queue]" or ""
            table.insert(out, ("--   seg %d: %s -> mapID=%d subZone=%q%s"):format(
                s.segIndex, s.event, s.mapID or 0, s.subZone or "", pendingTag))
        end
    end

    table.insert(out, "{")
    table.insert(out, "    step      = TODO,")
    table.insert(out, "    priority  = TODO,")
    table.insert(out, "    bossIndex = TODO,")
    table.insert(out, "    title     = \"TODO\",")
    table.insert(out, "    requires  = { },")
    table.insert(out, "    segments  = {")

    for _, s in ipairs(segs) do
        -- Auto-detect POI segments: a default-path segment with exactly
        -- one waypoint is almost certainly meant to be a POI marker
        -- (single-point paths don't render usefully). Saves the manual
        -- rewrite from "path" to "poi" at integration time. Empty-points
        -- segments stay "path" -- they're the yell-gated kill-in-place
        -- pattern (Uldir MOTHER), not a POI. Explicit teleport segments
        -- (kind = "teleport") are untouched.
        local kind = s.kind or "path"
        if kind == "path" and #s.points == 1 then
            kind = "poi"
        end

        table.insert(out, "        {")
        table.insert(out, ("            mapID = %d,"):format(s.mapID or 0))
        table.insert(out, ("            kind  = %q,"):format(kind))
        if s.subZone and s.subZone ~= "" then
            table.insert(out, ("            subZone = %q,"):format(s.subZone))
        end
        if s.gateBySubZone then
            table.insert(out, "            gateBySubZone = true,")
        end
        if s.destination then
            table.insert(out, ("            destination = %q,"):format(s.destination))
        end
        if s.note then
            table.insert(out, ("            note = %q,"):format(s.note))
        end
        table.insert(out, "            points = {")
        for _, p in ipairs(s.points) do
            table.insert(out, ("                { %.3f, %.3f },"):format(p[1], p[2]))
        end
        table.insert(out, "            },")
        table.insert(out, "        },")
    end

    table.insert(out, "    },")
    table.insert(out, "},")

    return table.concat(out, "\n")
end

function RR:DumpRecording()
    local export, err = self:BuildRecordingExport()
    if not export then
        self:Print(err)
        return
    end

    self:SetSetting("lastRecording", export)

    -- Show the copy window (defined in Harvester.lua's ShowCopyWindow helper).
    -- Single-click copy beats the previous line-by-line chat dump (which
    -- forced the user to scrollback and copy line-by-line out of chat).
    if self.ShowCopyWindow then
        self:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaRecording Export|r",
            export)
        self:Print("Recording window opened. Click inside, Ctrl+A, Ctrl+C.")
        self:Print("(Also saved to RetroRunsDB.lastRecording.)")
    else
        -- Fallback: ShowCopyWindow not available (Harvester.lua not loaded?).
        -- Print line-by-line as before.
        self:Print("Export saved to RetroRunsDB.lastRecording")
        self:Print("-------------------------------------")
        for line in export:gmatch("[^\n]+") do
            DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa" .. line .. "|r")
        end
        self:Print("-------------------------------------")
        self:Print("Copy the above into your data file.")
    end
end

