-------------------------------------------------------------------------------
-- RetroRuns -- MapOverlay.lua
-- Draws route lines and nav icons on the World Map.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Pool sizes -- sized to handle the largest expected raid routing
-------------------------------------------------------------------------------

local MAX_LINES  = 80
local MAX_ICONS  = 30
local MAX_DOTS   = 80
local MAX_LABELS = 30

local overlay = CreateFrame(
    "Frame", "RetroRunsMapOverlay",
    WorldMapFrame.ScrollContainer.Child)
overlay:SetAllPoints(WorldMapFrame.ScrollContainer.Child)

overlay.lines  = {}
overlay.icons  = {}
overlay.dots   = {}
overlay.labels = {}

local function MakeLine(p)
    local ln = p:CreateLine(nil, "ARTWORK")
    ln:SetThickness(4)
    ln:SetColorTexture(1.0, 0.82, 0.0, 0.95)
    ln:Hide()
    return ln
end

local function MakeIcon(p)
    local tx = p:CreateTexture(nil, "ARTWORK")
    tx:SetSize(18, 18)
    tx:Hide()
    return tx
end

local function MakeDot(p)
    local tx = p:CreateTexture(nil, "ARTWORK")
    tx:SetSize(10, 10)
    tx:SetTexture("Interface\\MINIMAP\\TempleofKotmogu_ball_cyan")
    tx:Hide()
    return tx
end

local function MakeLabel(p)
    local fs = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetTextColor(1.0, 1.0, 1.0, 1.0)
    fs:SetFont(fs:GetFont(), 17, "OUTLINE")
    fs:Hide()
    return fs
end

for i = 1, MAX_LINES  do overlay.lines[i]  = MakeLine(overlay)  end
for i = 1, MAX_ICONS  do overlay.icons[i]  = MakeIcon(overlay)  end
for i = 1, MAX_DOTS   do overlay.dots[i]   = MakeDot(overlay)   end
for i = 1, MAX_LABELS do overlay.labels[i] = MakeLabel(overlay) end

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function PlaceAt(el, parent, nx, ny)
    el:ClearAllPoints()
    el:SetPoint("CENTER", parent, "TOPLEFT",
        nx * parent:GetWidth(), -ny * parent:GetHeight())
end

local function ApplyIconStyle(icon, kind)
    if kind == "start" then
        icon:SetTexture("Interface\\MINIMAP\\TempleofKotmogu_ball_cyan")
        icon:SetVertexColor(0.2, 1.0, 1.0, 1.0)
        icon:SetSize(14, 14)
    else  -- "end"
        icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
        icon:SetVertexColor(1.0, 0.85, 0.15, 1.0)
        icon:SetSize(18, 18)
    end
end

-------------------------------------------------------------------------------
-- Drawing
-------------------------------------------------------------------------------

function overlay:HideAll()
    for _, v in ipairs(self.lines)  do v:Hide() end
    for _, v in ipairs(self.icons)  do v:Hide() end
    for _, v in ipairs(self.dots)   do v:Hide() end
    for _, v in ipairs(self.labels) do v:Hide() end
end

function overlay:DrawSegmentsForMap(mapID)
    local step = RR.state.activeStep
    if not step then return end

    local segments = RR:GetRelevantSegmentsForMap(step, mapID)
    if not segments or #segments == 0 then return end

    local W, H      = self:GetWidth(), self:GetHeight()
    local lineIdx   = 1
    local iconIdx   = 1

    for _, seg in ipairs(segments) do
        local pts = seg.points
        if pts and #pts > 0 then

            -- Start dot: always show so the player knows where the segment begins
            local startIcon = self.icons[iconIdx]
            if startIcon then
                PlaceAt(startIcon, self, pts[1][1], pts[1][2])
                ApplyIconStyle(startIcon, "start")
                startIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Lines: all segments use the same bright thick line for visibility
            for i = 2, #pts do
                local ln = self.lines[lineIdx]
                if ln then
                    local p, c = pts[i-1], pts[i]
                    ln:SetThickness(5)
                    ln:SetColorTexture(1.0, 0.95, 0.3, 1.0)
                    ln:SetStartPoint("TOPLEFT", p[1] * W, -p[2] * H)
                    ln:SetEndPoint  ("TOPLEFT", c[1] * W, -c[2] * H)
                    ln:Show()
                    lineIdx = lineIdx + 1
                end
            end

            -- End icon: red X marking the boss location. (Teleporter
            -- destinations are rendered natively by the World Map, so
            -- segments whose kind=="teleport" still get the end icon
            -- here -- we no longer draw a separate teleporter glyph.)
            local dest    = seg.navPoint or pts[#pts]
            local endIcon = self.icons[iconIdx]
            if endIcon then
                PlaceAt(endIcon, self, dest[1], dest[2])
                ApplyIconStyle(endIcon, "end")
                endIcon:Show()
                iconIdx = iconIdx + 1
            end
        end
    end
end

-------------------------------------------------------------------------------
-- DrawAllSegmentsForMap  (multi-segment "show the whole route" mode)
--
-- Used when the active step has step.renderAllSegments = true. Draws every
-- incomplete segment matching the player's mapID simultaneously, with a
-- numbered label at each segment's endpoint so the player can see which
-- waypoint corresponds to which step number. Bypasses the
-- GetRelevantSegmentsForMap "pick one" filter that DrawSegmentsForMap uses.
--
-- Why this exists: C_Map.GetPlayerMapPosition returns nil inside raid
-- instances (Blizzard restriction, see Recorder.lua preamble), so the
-- position-based segment-advancement tickers can't fire to mark earlier
-- segments complete as the player progresses. The "earliest incomplete
-- segment" fallback in GetRelevantSegmentsForMap means the player's note
-- would stay stuck on segment 1 throughout a multi-segment same-mapID
-- step. Rendering all segments with numbered waypoints sidesteps the
-- problem: the player reads the map for spatial cues and self-paces
-- through the waypoints in order.
--
-- Numeric labels match the segment's index within the step's segments
-- array. On a single-mapID step the numbers are sequential (1, 2, 3...);
-- on a step that visits the same mapID twice (e.g. Sennarth seg 1 and
-- seg 3 both on 2122), the visible numbers may be non-sequential, which
-- is the intended behavior -- it accurately reflects the run order.
-------------------------------------------------------------------------------

function overlay:DrawAllSegmentsForMap(mapID)
    local step = RR.state.activeStep
    if not step or not step.segments then return end

    local W, H    = self:GetWidth(), self:GetHeight()
    local lineIdx = 1
    local iconIdx = 1
    local labelIdx = 1

    -- Per-segment color palette, cycled by segIndex. Three high-contrast
    -- colors that read against the World Map's textured background.
    -- Indexed mod 3 so a hypothetical 4-segment step would reuse seg 1's
    -- color for seg 4, but adjacent segments are always different.
    local SEG_COLORS = {
        { 1.0, 0.95, 0.30 },  -- yellow   (seg 1, 4, 7...)
        { 0.30, 0.85, 1.00 },  -- cyan    (seg 2, 5, 8...)
        { 1.00, 0.40, 0.85 },  -- magenta (seg 3, 6, 9...)
    }

    local stepIndex = step.step or step.priority or 0
    for segIndex, seg in ipairs(step.segments) do
        if seg.mapID == mapID
            and seg.points and #seg.points > 0
            and not RR:IsSegmentCompleted(stepIndex, segIndex) then
            local pts = seg.points
            local color = SEG_COLORS[((segIndex - 1) % #SEG_COLORS) + 1]

            -- Start dot
            local startIcon = self.icons[iconIdx]
            if startIcon then
                PlaceAt(startIcon, self, pts[1][1], pts[1][2])
                ApplyIconStyle(startIcon, "start")
                startIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Polyline (color varies per segment so overlapping lines
            -- from different segments stay visually distinguishable)
            for i = 2, #pts do
                local ln = self.lines[lineIdx]
                if ln then
                    local p, c = pts[i-1], pts[i]
                    ln:SetThickness(5)
                    ln:SetColorTexture(color[1], color[2], color[3], 1.0)
                    ln:SetStartPoint("TOPLEFT", p[1] * W, -p[2] * H)
                    ln:SetEndPoint  ("TOPLEFT", c[1] * W, -c[2] * H)
                    ln:Show()
                    lineIdx = lineIdx + 1
                end
            end

            -- End icon (red X) at the segment endpoint
            local dest    = seg.navPoint or pts[#pts]
            local endIcon = self.icons[iconIdx]
            if endIcon then
                PlaceAt(endIcon, self, dest[1], dest[2])
                ApplyIconStyle(endIcon, "end")
                endIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Numbered label, centered directly on the X icon. Centering
            -- (rather than offsetting) ensures the number is visible even
            -- when the segment endpoint sits near a map edge -- a
            -- previous offset-above approach was clipped by the World
            -- Map's title bar when the endpoint had a low y coord.
            local label = self.labels[labelIdx]
            if label then
                PlaceAt(label, self, dest[1], dest[2])
                label:SetText(tostring(segIndex))
                label:Show()
                labelIdx = labelIdx + 1
            end
        end
    end
end

function overlay:DrawRecorder(mapID)
    -- Support both old DB-backed recorder and new in-memory recorder
    local rec    = RR.recorder
    local active = rec and rec.active
    local points = {}

    if active and rec.current and rec.current.mapID == mapID then
        -- Draw committed segments for this map too
        for _, seg in ipairs(rec.segments) do
            if seg.mapID == mapID then
                for _, pt in ipairs(seg.points) do
                    table.insert(points, pt)
                end
            end
        end
        for _, pt in ipairs(rec.current.points) do
            table.insert(points, pt)
        end
    end

    if #points == 0 then return end

    local W, H    = self:GetWidth(), self:GetHeight()
    local lineIdx = math.floor(MAX_LINES / 2) + 1
    local dotIdx  = 1

    for i, pt in ipairs(points) do
        local dt = self.dots[dotIdx]
        if dt then
            PlaceAt(dt, self, pt[1], pt[2])
            dt:SetVertexColor(0.2, 1.0, 0.2, 1.0)
            dt:Show()
            dotIdx = dotIdx + 1
        end
        if i > 1 then
            local ln = self.lines[lineIdx]
            if ln then
                local prev = points[i-1]
                ln:SetThickness(2)
                ln:SetColorTexture(0.2, 1.0, 0.2, 0.85)
                ln:SetStartPoint("TOPLEFT", prev[1] * W, -prev[2] * H)
                ln:SetEndPoint  ("TOPLEFT", pt[1]   * W, -pt[2]   * H)
                ln:Show()
                lineIdx = lineIdx + 1
            end
        end
    end
end

function overlay:Refresh()
    self:HideAll()
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then return end

    if RR.currentRaid
        and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
        local step = RR.state.activeStep
        if step and step.renderAllSegments then
            self:DrawAllSegmentsForMap(mapID)
        else
            self:DrawSegmentsForMap(mapID)
        end
    end

    self:DrawRecorder(mapID)
end

RetroRunsMapOverlay = overlay

-------------------------------------------------------------------------------
-- Hooks
-------------------------------------------------------------------------------

hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
    overlay:Refresh()
    RR.UI.Update()
end)

WorldMapFrame:HookScript("OnShow", function()
    overlay:Refresh()
    RR.UI.Update()
end)

WorldMapFrame.ScrollContainer:HookScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
        RR:RecorderHandleMapClick()
    end
end)

C_Timer.NewTicker(1.0, function()
    if WorldMapFrame and WorldMapFrame:IsShown() then
        overlay:Refresh()
    end
end)
