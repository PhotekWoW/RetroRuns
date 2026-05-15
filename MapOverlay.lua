-------------------------------------------------------------------------------
-- RetroRuns -- MapOverlay.lua
-- Draws route lines and nav icons on the World Map.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Pool sizes -- sized to handle the largest expected raid routing
-------------------------------------------------------------------------------

local MAX_LINES    = 80
local MAX_ICONS    = 30
local MAX_DOTS     = 80
local MAX_LABELS   = 30
-- Direction-of-travel chevrons placed along route polylines at a fixed
-- pixel stride. Sized for the tightest current stride (35px) across the
-- largest current routes -- multi-segment renders like Eranog produce
-- the highest counts. 200 leaves comfortable headroom.
local MAX_CHEVRONS = 200

local overlay = CreateFrame(
    "Frame", "RetroRunsMapOverlay",
    WorldMapFrame.ScrollContainer.Child)
overlay:SetAllPoints(WorldMapFrame.ScrollContainer.Child)

overlay.lines    = {}
overlay.icons    = {}
overlay.dots     = {}
overlay.labels   = {}
overlay.chevrons = {}

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

-- Direction-of-travel chevron. Uses our own asset Media/Chevron.tga --
-- a 32x32 white-on-transparent "V" pointing DOWN at native rotation 0.
-- Authored white-on-transparent specifically so SetVertexColor can tint
-- it freely to any color. Cyan {0.30, 0.80, 1.00} matches UI.lua C_BLUE
-- for the RETRORUNS color scheme.
--
-- The asset's "tip points down" orientation matches the placement
-- helper's atan2(dx, dy) rotation formula so swapping the asset
-- doesn't require any geometry changes.
--
-- Drawn at OVERLAY (above the ARTWORK lines) so chevrons sit on top of
-- the polyline rather than being painted over by it.
local function MakeChevron(p)
    local tx = p:CreateTexture(nil, "OVERLAY")
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Chevron")
    tx:SetVertexColor(0.30, 0.80, 1.00, 1.0)  -- cyan (matches UI.lua C_BLUE)
    tx:SetSize(18, 18)
    tx:Hide()
    return tx
end

for i = 1, MAX_LINES    do overlay.lines[i]    = MakeLine(overlay)    end
for i = 1, MAX_ICONS    do overlay.icons[i]    = MakeIcon(overlay)    end
for i = 1, MAX_DOTS     do overlay.dots[i]     = MakeDot(overlay)     end
for i = 1, MAX_LABELS   do overlay.labels[i]   = MakeLabel(overlay)   end
for i = 1, MAX_CHEVRONS do overlay.chevrons[i] = MakeChevron(overlay) end

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function PlaceAt(el, parent, nx, ny)
    el:ClearAllPoints()
    el:SetPoint("CENTER", parent, "TOPLEFT",
        nx * parent:GetWidth(), -ny * parent:GetHeight())
end

local function ApplyIconStyle(icon, kind)
    -- "start" only -- the "end" case is handled by PlaceEndMarker below
    -- (which also wants rotation, so it lives separately).
    if kind == "start" then
        icon:SetTexture("Interface\\MINIMAP\\TempleofKotmogu_ball_cyan")
        icon:SetVertexColor(0.2, 1.0, 1.0, 1.0)
        icon:SetSize(14, 14)
        -- Reset rotation and draw layer in case this icon was previously
        -- used as an end marker (which sets a non-zero rotation and bumps
        -- the layer to OVERLAY). The cyan ball texture is rotation-
        -- invariant visually, but cleaner to keep state predictable.
        icon:SetRotation(0)
        icon:SetDrawLayer("ARTWORK")
    end
end

-------------------------------------------------------------------------------
-- End marker
--
-- Place the destination marker at the end of a route. Uses our own
-- Media/EndTriangle.tga -- a 32x32 white-on-transparent solid triangle
-- pointing DOWN at native rotation 0. Same color (cyan) and rotation
-- math as the trail chevrons so the visual flow lands cleanly on a
-- single shape pointing at the boss.
--
-- Rotation points toward `dest` from the previous polyline point, NOT
-- along the last polyline segment. This matters when navPoint is set
-- (boss icon offset from the polyline end) -- the marker should point
-- at the actual destination, not along the recorded path's tail.
--
-- For single-point segments (#pts == 1) where there's no direction
-- to compute, the marker renders un-rotated (tip pointing down) --
-- visually fine since there's no path leading into it.
-------------------------------------------------------------------------------

local function PlaceEndMarker(self, icon, pts, dest, W, H)
    icon:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\EndTriangle")
    -- Cyan fill and pink border are baked into the asset (vertex tint
    -- is global to the texture so we can't tint fill and border
    -- independently at runtime). White tint = no-op so the baked
    -- colors render as authored.
    icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
    -- 24x24 (vs the trail chevrons' 18x18) -- a filled triangle reads
    -- as smaller-presence than an open V-chevron at the same pixel
    -- size because there's no negative space carrying the shape's
    -- visual extent outward. Going up to 24 matches the trail's weight.
    icon:SetSize(24, 24)
    -- Bump to OVERLAY so the triangle sits above the polyline. The icon
    -- pool is created at ARTWORK (same layer as the lines), and on this
    -- platform the lines were winning the draw order. Start-dot and POI
    -- styling reset back to ARTWORK so the bump doesn't leak across
    -- pool reuse.
    icon:SetDrawLayer("OVERLAY")

    -- Position at dest (normalized coords -> pixels).
    icon:ClearAllPoints()
    icon:SetPoint("CENTER", self, "TOPLEFT",
        dest[1] * W, -dest[2] * H)

    -- Rotation: from the second-to-last polyline point toward dest.
    -- Same texture-orientation assumption as the chevron asset (tip
    -- points down at rotation 0), so atan2(dx, dy) aligns the tip
    -- with the destination direction in screen coords (+y is down).
    if pts and #pts >= 2 then
        local prev = pts[#pts - 1]
        local dx = (dest[1] - prev[1]) * W
        local dy = (dest[2] - prev[2]) * H
        if dx ~= 0 or dy ~= 0 then
            icon:SetRotation(math.atan2(dx, dy))
        else
            icon:SetRotation(0)
        end
    else
        icon:SetRotation(0)
    end
end

-------------------------------------------------------------------------------
-- Direction-of-travel chevrons
--
-- Place chevron textures along a polyline at a fixed pixel stride, each
-- rotated to face along the local segment direction. The raid-target
-- triangle texture's "forward" axis points DOWN (south, +y on screen)
-- at rotation 0 (determined empirically -- WoW's raid-target icons
-- aren't documented for orientation). WoW SetRotation uses
-- counter-clockwise radians, so rotation = atan2(dx, dy) aligns the
-- triangle's tip with the screen-space travel direction.
--
-- Skips chevrons placed within END_PADDING px of the start or end of the
-- path so they don't crowd the start dot or end-X icon. Returns the
-- number of chevrons consumed from the pool starting at startChevronIdx.
-------------------------------------------------------------------------------

local CHEVRON_STRIDE_PX  = 25   -- distance between chevrons in pixels
local CHEVRON_END_PAD_PX = 10   -- skip placement within this many px of either endpoint
-- Paths shorter than this skip chevrons entirely. The start dot + end
-- triangle alone make the route's direction clear at short distances;
-- chevrons in between just crowd the visual. 70px lines up roughly with
-- "could fit at least 2 chevrons comfortably given the stride" -- below
-- that, chevron placement starts looking sparse and pointless.
local CHEVRON_MIN_PATH_PX = 70

local function PlaceChevronsAlongPath(self, pts, W, H, startChevronIdx)
    -- Need at least 2 points to define a direction.
    if not pts or #pts < 2 then return 0 end

    -- Convert all points from normalized (0..1) into screen pixels once.
    -- Pre-compute per-segment lengths and total path length so we can
    -- place chevrons by arc-length parameter.
    local screenPts = {}
    for i, pt in ipairs(pts) do
        screenPts[i] = { pt[1] * W, pt[2] * H }
    end

    local segLens = {}
    local total = 0
    for i = 2, #screenPts do
        local p, c = screenPts[i-1], screenPts[i]
        local dx, dy = c[1] - p[1], c[2] - p[2]
        local d = math.sqrt(dx * dx + dy * dy)
        segLens[i-1] = d
        total = total + d
    end

    -- Skip chevrons on short paths -- start dot + end triangle make the
    -- direction obvious without them. (See CHEVRON_MIN_PATH_PX docstring.)
    if total < CHEVRON_MIN_PATH_PX then return 0 end

    local chevronIdx = startChevronIdx
    local placed = 0

    -- Start at the first stride-multiple that's past the start padding,
    -- continue while still inside the end padding.
    local target = CHEVRON_STRIDE_PX
    if target < CHEVRON_END_PAD_PX then target = CHEVRON_END_PAD_PX end

    -- Walk the polyline accumulating arc length. When the accumulator
    -- crosses each `target`, interpolate within the current segment to
    -- find the chevron position, compute rotation from that segment's
    -- direction, place the chevron, and advance target by the stride.
    local accum = 0
    for i = 1, #segLens do
        local segLen = segLens[i]
        local segStart = accum
        local segEnd = accum + segLen
        local p, c = screenPts[i], screenPts[i+1]
        local dx, dy = c[1] - p[1], c[2] - p[2]
        -- Rotation: the raid-target triangle texture's "forward" axis
        -- points DOWN (south, +y in screen coords) at rotation 0 --
        -- determined empirically. WoW's SetRotation uses counter-clockwise
        -- radians. atan2(dx, dy) maps the screen-space travel direction
        -- (dx, dy where +y is DOWN) to the rotation needed to align the
        -- triangle's tip with travel direction.
        local rot = math.atan2(dx, dy)

        while target <= segEnd and target <= total - CHEVRON_END_PAD_PX do
            local localT = (target - segStart) / segLen
            local px = p[1] + dx * localT
            local py = p[2] + dy * localT

            local ch = self.chevrons[chevronIdx]
            if not ch then return placed end

            ch:ClearAllPoints()
            ch:SetPoint("CENTER", self, "TOPLEFT", px, -py)
            ch:SetRotation(rot)
            ch:Show()
            chevronIdx = chevronIdx + 1
            placed = placed + 1
            target = target + CHEVRON_STRIDE_PX
        end

        accum = segEnd
        if target > total - CHEVRON_END_PAD_PX then break end
    end

    return placed
end

-------------------------------------------------------------------------------
-- Drawing
-------------------------------------------------------------------------------

function overlay:HideAll()
    for _, v in ipairs(self.lines)    do v:Hide() end
    for _, v in ipairs(self.icons)    do v:Hide() end
    for _, v in ipairs(self.dots)     do v:Hide() end
    for _, v in ipairs(self.labels)   do v:Hide() end
    for _, v in ipairs(self.chevrons) do v:Hide() end
end

function overlay:DrawSegmentsForMap(mapID)
    local step = RR.state.activeStep
    if not step then return end

    local segments = RR:GetRelevantSegmentsForMap(step, mapID)
    if not segments or #segments == 0 then return end

    local W, H      = self:GetWidth(), self:GetHeight()
    local lineIdx    = 1
    local iconIdx    = 1
    local chevronIdx = 1

    for _, seg in ipairs(segments) do
        local pts = seg.points
        if pts and #pts > 0 then

            -- Point-of-interest segment: a single marker showing the
            -- player approximately where to find an interactable.
            -- Used when the start position is unpredictable (e.g. after
            -- a boss kill where the kill location varies) but the
            -- target location is fixed. Renders only the end-icon
            -- (red X) at the segment's last point. No start dot, no
            -- lines -- the segment isn't a path, it's a "go here" pin.
            if seg.kind == "poi" then
                -- noMarker=true on a poi segment suppresses the World Map
                -- icon entirely. Used for "step needs to exist structurally
                -- (carries a note for the panel travel pane) but the
                -- player doesn't need a map marker because they're
                -- already at the destination" cases. N'Zoth (Ny'alotha)
                -- is the canonical example: after killing Carapace, the
                -- player auto-spawns directly in front of the boss --
                -- no walking, no clicking, no decision about where to go.
                if not seg.noMarker then
                local mark    = seg.navPoint or pts[#pts]
                local poiIcon = self.icons[iconIdx]
                if poiIcon then
                    PlaceAt(poiIcon, self, mark[1], mark[2])
                    -- POI uses a distinctive bold marker so it reads
                    -- as a search-area indicator at parent-zoom-out
                    -- map scale, distinct from the standard end-of-
                    -- path cyan triangle. Star raid-target icon is
                    -- semantically familiar to players ("look here")
                    -- and sized large enough to read clearly when
                    -- the world map is zoomed to a parent map view.
                    poiIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
                    poiIcon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
                    -- Reset rotation and draw layer in case this icon was
                    -- previously used as an end marker. The star is
                    -- rotation-invariant visually but cleaner to keep
                    -- state predictable.
                    poiIcon:SetRotation(0)
                    poiIcon:SetDrawLayer("ARTWORK")
                    -- Default 78 matches Fyrakk in Amirdrassil. Older raids
                    -- on smaller sub-zone maps (Ny'alotha) can override via
                    -- per-segment poiSize for proportional rendering.
                    local size = seg.poiSize or 78
                    poiIcon:SetSize(size, size)
                    poiIcon:Show()
                    iconIdx = iconIdx + 1
                end
                end -- end "if not seg.noMarker"
            else

            -- Start dot: always show so the player knows where the segment begins
            local startIcon = self.icons[iconIdx]
            if startIcon then
                PlaceAt(startIcon, self, pts[1][1], pts[1][2])
                ApplyIconStyle(startIcon, "start")
                startIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Lines: all segments use the same bright thick line for visibility.
            -- Pink {0.95, 0.35, 0.78} matches UI.lua C_PINK (the RETRORUNS
            -- title color); pairs with cyan chevrons for the addon's color
            -- scheme.
            for i = 2, #pts do
                local ln = self.lines[lineIdx]
                if ln then
                    local p, c = pts[i-1], pts[i]
                    ln:SetThickness(5)
                    ln:SetColorTexture(0.95, 0.35, 0.78, 1.0)
                    ln:SetStartPoint("TOPLEFT", p[1] * W, -p[2] * H)
                    ln:SetEndPoint  ("TOPLEFT", c[1] * W, -c[2] * H)
                    ln:Show()
                    lineIdx = lineIdx + 1
                end
            end

            -- Direction-of-travel chevrons along the polyline.
            chevronIdx = chevronIdx +
                PlaceChevronsAlongPath(self, pts, W, H, chevronIdx)

            -- End marker: cyan triangle pointing at the boss location.
            -- (Teleporter destinations are rendered natively by the World
            -- Map, so segments whose kind=="teleport" still get the end
            -- marker here -- we no longer draw a separate teleporter glyph.)
            local dest    = seg.navPoint or pts[#pts]
            local endIcon = self.icons[iconIdx]
            if endIcon then
                PlaceEndMarker(self, endIcon, pts, dest, W, H)
                endIcon:Show()
                iconIdx = iconIdx + 1
            end

            end -- end "if seg.kind == poi else"
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
    local lineIdx    = 1
    local iconIdx    = 1
    local labelIdx   = 1
    local chevronIdx = 1

    -- Label number reflects the seg's position among segs ACTUALLY
    -- DRAWN ON THIS MAP, not its absolute segIndex within step.segments.
    -- This way, instruction-only segs (no points), segs on a different
    -- mapID, or already-completed segs don't consume a number. Result:
    -- the on-map labels always start at 1 and count contiguously,
    -- matching what the player sees. Eranog (3 segs all on map 2119,
    -- all renderable) labels 1/2/3 -- unchanged from absolute-segIndex
    -- behavior. Orgozoa step (5 segs across 3 mapIDs) labels its
    -- three Traverse segs as 1/2/3 on map 1516 even though they sit
    -- at absolute indices 2/3/4 in the segments array.
    local renderNum = 0

    -- Pre-count how many segs will actually render on this map. When
    -- only one seg is renderable -- typically because revealAfter is
    -- gating the rest -- a lone "(1)" label looks orphaned and
    -- meaningless. Skip labeling entirely in that case; the player
    -- only needs the start/end icons to know where they're going.
    local renderableCount = 0
    do
        local sIdx = step.step or step.priority or 0
        for segIndex, seg in ipairs(step.segments) do
            if seg.mapID == mapID
                and seg.points and #seg.points > 0
                and not RR:IsSegmentCompleted(sIdx, segIndex)
                and RR:IsSegmentRevealed(sIdx, seg) then
                renderableCount = renderableCount + 1
            end
        end
    end
    local labelSegs = renderableCount > 1

    local stepIndex = step.step or step.priority or 0
    for segIndex, seg in ipairs(step.segments) do
        if seg.mapID == mapID
            and seg.points and #seg.points > 0
            and not RR:IsSegmentCompleted(stepIndex, segIndex)
            and RR:IsSegmentRevealed(stepIndex, seg) then
            local pts = seg.points
            renderNum = renderNum + 1

            -- Start dot. Skipped for single-point segments: with no
            -- path to "start," the start dot would just stack under
            -- the end icon at the same coord, adding visual noise. A
            -- single-point seg is conceptually a destination marker
            -- (the end icon + numbered label communicate the "go here"
            -- intent on their own).
            if #pts > 1 then
                local startIcon = self.icons[iconIdx]
                if startIcon then
                    PlaceAt(startIcon, self, pts[1][1], pts[1][2])
                    ApplyIconStyle(startIcon, "start")
                    startIcon:Show()
                    iconIdx = iconIdx + 1
                end
            end

            -- Polyline. Pink {0.95, 0.35, 0.78} matches the single-segment
            -- render path so multi-segment maps stay visually consistent
            -- with the rest of the addon. Disambiguation between segments
            -- on the same map is carried by the numbered (1)/(2)/(3)
            -- labels placed at each segment's endpoint, not by line color.
            for i = 2, #pts do
                local ln = self.lines[lineIdx]
                if ln then
                    local p, c = pts[i-1], pts[i]
                    ln:SetThickness(5)
                    ln:SetColorTexture(0.95, 0.35, 0.78, 1.0)
                    ln:SetStartPoint("TOPLEFT", p[1] * W, -p[2] * H)
                    ln:SetEndPoint  ("TOPLEFT", c[1] * W, -c[2] * H)
                    ln:Show()
                    lineIdx = lineIdx + 1
                end
            end

            -- Direction-of-travel chevrons along the polyline.
            chevronIdx = chevronIdx +
                PlaceChevronsAlongPath(self, pts, W, H, chevronIdx)

            -- End marker (cyan triangle) at the segment endpoint
            local dest    = seg.navPoint or pts[#pts]
            local endIcon = self.icons[iconIdx]
            if endIcon then
                PlaceEndMarker(self, endIcon, pts, dest, W, H)
                endIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Numbered label, centered directly on the X icon. Centering
            -- (rather than offsetting) ensures the number is visible even
            -- when the segment endpoint sits near a map edge -- a
            -- previous offset-above approach was clipped by the World
            -- Map's title bar when the endpoint had a low y coord.
            -- Skipped when only one seg renders (labelSegs=false) -- a
            -- lone "(1)" with no sibling is just visual noise.
            if labelSegs then
                local label = self.labels[labelIdx]
                if label then
                    PlaceAt(label, self, dest[1], dest[2])
                    label:SetText(tostring(renderNum))
                    label:Show()
                    labelIdx = labelIdx + 1
                end
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
