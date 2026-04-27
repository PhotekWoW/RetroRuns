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
}

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

    rec.active   = true
    rec.segments = {}
    rec.current  = NewSegment(mapID, "path")

    self:ShowRecorderHUD()

    self:Print("Recording started.")
    self:Print("  Open the World Map and SHIFT+CLICK each waypoint along the route.")
    self:Print("  Switch World Map floors between clicks to record across multiple maps.")
    self:Print("  /rr record tp <name>   -- mark current segment as a teleporter use")
    self:Print("  /rr record break       -- split AFTER crossing a sub-zone threshold")
    self:Print("  /rr record note <text> -- attach a travel note to the current segment")
    self:Print("  /rr record stop        -- finish")
end

function RR:StopRecording()
    local rec = self.recorder
    rec.active = false

    self:HideRecorderHUD()

    if rec.current then
        if #rec.current.points > 0 then
            table.insert(rec.segments, rec.current)
        end
        rec.current = nil
    end

    local total = 0
    for _, s in ipairs(rec.segments) do total = total + #s.points end
    self:Print(("Stopped. %d segment(s), %d total waypoint(s)."):format(
        #rec.segments, total))

    -- Auto-dump on stop. The author's workflow always wants to see (and
    -- copy) the export immediately after stopping; previously this
    -- required a separate /rr record dump call. Auto-firing the dump
    -- saves a keystroke per recording and matches the natural "stop
    -- and show me what I caught" mental model.
    --
    -- Skip silently if there's nothing to export -- this happens when
    -- the user stops a recording they aborted early (no shift-clicks
    -- captured) and is about to /rr record reset. Showing a "nothing
    -- to export" error in that case is noise. The /rr record dump
    -- command is still available for manual invocation if the user
    -- wants to re-export later (the data persists in
    -- RetroRunsDB.lastRecording).
    if #rec.segments > 0 then
        self:DumpRecording()
    else
        self:Print("/rr record reset -- to clear")
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

function RR:ResetRecording()
    local rec = self.recorder
    rec.active, rec.segments, rec.current = false, {}, nil
    self:Print("Recorder reset.")
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
    table.insert(out, "{")
    table.insert(out, "    step      = TODO,")
    table.insert(out, "    priority  = TODO,")
    table.insert(out, "    bossIndex = TODO,")
    table.insert(out, "    title     = \"TODO\",")
    table.insert(out, "    requires  = { },")
    table.insert(out, "    segments  = {")

    for _, s in ipairs(segs) do
        table.insert(out, "        {")
        table.insert(out, ("            mapID = %d,"):format(s.mapID or 0))
        table.insert(out, ("            kind  = %q,"):format(s.kind or "path"))
        if s.subZone and s.subZone ~= "" then
            table.insert(out, ("            subZone = %q,"):format(s.subZone))
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

-------------------------------------------------------------------------------
-- Recorder HUD
--
-- A small floating frame that shows the player's current zone, sub-zone, and
-- mapID in real time. Shown only while recording is active. Purpose: the
-- author needs to know when route waypoints are crossing into named sub-zones
-- (so they can issue /rr record break for same-mapID segment splits, decide
-- when waypoint clicks should be made, and verify segment endpoints land in
-- the expected sub-zone for the dump). Watching the white sub-zone toast
-- flicker by on screen is unreliable; this HUD shows current state in place,
-- always glance-able.
--
-- Frame is created lazily on first /rr record start so we don't allocate UI
-- bandwidth on installs that never record. Position is draggable and saved
-- to RetroRunsDB.recorderHudX/Y. Default position is roughly top-center.
--
-- Refresh sources:
--   * ZONE_CHANGED, ZONE_CHANGED_INDOORS, ZONE_CHANGED_NEW_AREA events
--     (the _INDOORS variant catches sub-sub-zone transitions that don't
--     fire ZONE_CHANGED).
--   * 1Hz polling ticker, started on Show, cancelled on Hide. Catches
--     the case where C_Map.GetBestMapForUnit's return value drifts
--     without a corresponding zone event firing (observed during
--     Sennarth's ascent: mapID 2122 -> 2123 transition completed
--     without ZONE_CHANGED, leaving event-only refresh stale until
--     the next event happened to fire).
-------------------------------------------------------------------------------

local hud  -- frame, lazily created

local function HudUpdate()
    if not hud or not hud:IsShown() then return end
    local zone    = (GetZoneText and GetZoneText())       or ""
    local subZone = (GetSubZoneText and GetSubZoneText()) or ""
    local mapID   = (C_Map and C_Map.GetBestMapForUnit and
                     C_Map.GetBestMapForUnit("player")) or 0
    if zone    == "" then zone    = "<empty>" end
    if subZone == "" then subZone = "<empty>" end
    hud.zoneFS:SetText("zone:    " .. zone)
    hud.subFS:SetText( "subZone: " .. subZone)
    hud.mapFS:SetText( "mapID:   " .. tostring(mapID))
end

local function HudCreate()
    if hud then return hud end
    local f = CreateFrame("Frame", "RetroRunsRecorderHUD", UIParent, "BackdropTemplate")
    f:SetSize(260, 64)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.03, 0.03, 0.03, 0.85)

    -- Restore saved position. Same CENTER-anchored contract as the main
    -- panel uses (UI.lua RestorePanelPosition).
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER",
        RR:GetSetting("recorderHudX", 0),
        RR:GetSetting("recorderHudY", 240))

    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local cx, cy   = self:GetCenter()
        local pcx, pcy = UIParent:GetCenter()
        local scale    = self:GetEffectiveScale()
        local pscale   = UIParent:GetEffectiveScale()
        local x = (cx * scale - pcx * pscale) / pscale
        local y = (cy * scale - pcy * pscale) / pscale
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", x, y)
        RR:SetSetting("recorderHudX", math.floor(x + 0.5))
        RR:SetSetting("recorderHudY", math.floor(y + 0.5))
    end)

    -- Three left-aligned FontStrings, monospace-ish via GameFontHighlight
    -- (the addon's standard small-text font). Stacked top-to-bottom.
    local function makeFS(parent, yOffset)
        local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
        fs:SetJustifyH("LEFT")
        fs:SetTextColor(0.9, 0.9, 0.9)
        return fs
    end
    f.zoneFS = makeFS(f, -8)
    f.subFS  = makeFS(f, -24)
    f.mapFS  = makeFS(f, -40)

    -- Event listening. Three zone events cover most transitions; HudUpdate
    -- is also called eagerly on Show() so the HUD has correct state the
    -- moment it appears (events won't fire until the player moves). A
    -- polling ticker (1Hz, started on Show, cancelled on Hide) catches
    -- the case where C_Map.GetBestMapForUnit's return value drifts
    -- without a corresponding zone event firing -- e.g. during the
    -- Sennarth ascent the player's mapID transitions from 2122 to 2123
    -- without a ZONE_CHANGED, so event-only refresh leaves the HUD stale.
    -- /rr status reads on demand and stays correct, but the HUD needs
    -- continuous updates while it's visible. Polling cost is three
    -- string reads per tick, only while HUD is visible (i.e. during
    -- active recording), so the overhead is negligible.
    f:SetScript("OnEvent", HudUpdate)
    f:RegisterEvent("ZONE_CHANGED")
    f:RegisterEvent("ZONE_CHANGED_INDOORS")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

    f:SetScript("OnShow", function(self)
        HudUpdate()
        if not self.ticker then
            self.ticker = C_Timer.NewTicker(1.0, HudUpdate)
        end
    end)
    f:SetScript("OnHide", function(self)
        if self.ticker then
            self.ticker:Cancel()
            self.ticker = nil
        end
    end)
    f:Hide()

    hud = f
    return hud
end

function RR:ShowRecorderHUD()
    HudCreate()
    if hud then hud:Show() end
end

function RR:HideRecorderHUD()
    if hud then hud:Hide() end
end
