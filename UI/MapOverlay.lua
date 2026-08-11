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
local MAX_RINGS    = 10
local MAX_CHEVRONS = 200
-- Always-on global POIs (vendors, doors/tunnels, hand-authored markers) draw
-- from their own pool so their indices never collide with the step segments'.
local MAX_GLOBAL_POI = 12

local overlay = CreateFrame(
    "Frame", "RetroRunsMapOverlay",
    WorldMapFrame.ScrollContainer.Child)
overlay:SetAllPoints(WorldMapFrame.ScrollContainer.Child)

overlay.lines    = {}
overlay.icons    = {}
overlay.dots     = {}
overlay.labels   = {}
overlay.rings    = {}
overlay.chevrons = {}
overlay.poiIcons  = {}   -- always-on global-POI markers
overlay.poiLabels = {}   -- always-on global-POI labels

local function MakeLine(parent)
    local ln = parent:CreateLine(nil, "ARTWORK")
    ln:SetThickness(4)
    ln:SetColorTexture(1.0, 0.82, 0.0, 0.95)
    ln:Hide()
    return ln
end

local function MakeIcon(parent)
    local tx = parent:CreateTexture(nil, "ARTWORK")
    tx:SetSize(18, 18)
    tx:Hide()
    return tx
end

local function MakeDot(parent)
    local tx = parent:CreateTexture(nil, "ARTWORK")
    tx:SetSize(10, 10)
    tx:SetTexture("Interface\\MINIMAP\\TempleofKotmogu_ball_cyan")
    tx:Hide()
    return tx
end

local function MakeLabel(parent)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetTextColor(1.0, 1.0, 1.0, 1.0)
    fs:SetFont(fs:GetFont(), 17, "OUTLINE")
    fs:Hide()
    return fs
end

-- Direction-of-travel chevron. The asset points down at rotation 0.
local function MakeChevron(parent)
    local tx = parent:CreateTexture(nil, "OVERLAY")
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Chevron")
    tx:SetVertexColor(0.30, 0.80, 1.00, 1.0)  -- cyan (matches UI.lua C_BLUE)
    tx:SetSize(18, 18)
    tx:Hide()
    return tx
end

-- Attention ring, drawn above native Blizzard map icons so it can surround one.
local function MakeRing(parent)
    local tx = parent:CreateTexture(nil, "OVERLAY")
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\RingCircle")
    tx:SetVertexColor(1.0, 0.0, 0.0, 1.0)
    tx:SetSize(42, 42)
    tx:Hide()
    return tx
end

for i = 1, MAX_LINES    do overlay.lines[i]    = MakeLine(overlay)    end
for i = 1, MAX_ICONS    do overlay.icons[i]    = MakeIcon(overlay)    end
for i = 1, MAX_DOTS     do overlay.dots[i]     = MakeDot(overlay)     end
for i = 1, MAX_LABELS   do overlay.labels[i]   = MakeLabel(overlay)   end
for i = 1, MAX_RINGS      do overlay.rings[i]     = MakeRing(overlay)  end
for i = 1, MAX_CHEVRONS   do overlay.chevrons[i]  = MakeChevron(overlay) end
for i = 1, MAX_GLOBAL_POI do overlay.poiIcons[i]  = MakeIcon(overlay)  end
for i = 1, MAX_GLOBAL_POI do overlay.poiLabels[i] = MakeLabel(overlay) end

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
        -- Pooled icons carry rotation and layer over from a previous use.
        icon:SetRotation(0)
        icon:SetDrawLayer("ARTWORK")
    end
end

-------------------------------------------------------------------------------
-- End marker. Aims at `dest` from the second-to-last polyline point.
-------------------------------------------------------------------------------

local function PlaceEndMarker(self, icon, pts, dest, W, H, endpointKind)
    -- endpointKind opt-in: data segs can set seg.endpointKind to swap
    -- the default end-triangle for a semantic alternative. Currently
    -- supports "skull" (for jump-off-edge-to-die routing tricks --
    -- Tomb Maiden's Tears step, and any future raid using a suicide
    -- shortcut). Default (nil / unrecognized) renders the standard
    -- directional triangle.
    if endpointKind == "skull" then
        -- WoW's built-in raid-target skull marker -- universally
        -- recognized as "death" without needing a custom asset.
        icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
        icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        icon:SetSize(24, 24)
        icon:SetDrawLayer("OVERLAY")
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", self, "TOPLEFT",
            dest[1] * W, -dest[2] * H)
        -- Skulls aren't directional; reset any prior rotation.
        icon:SetRotation(0)
        return
    end

    icon:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\EndTriangle")
    -- White tint is a no-op, so the asset's baked colours render as authored.
    icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
    icon:SetSize(24, 24)
    icon:SetDrawLayer("OVERLAY")

    icon:ClearAllPoints()
    icon:SetPoint("CENTER", self, "TOPLEFT",
        dest[1] * W, -dest[2] * H)

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
-- Chevrons along a polyline at a fixed pixel stride, each rotated to face
-- along its segment. Returns how many were consumed from the pool.
-------------------------------------------------------------------------------

local CHEVRON_STRIDE_PX  = 25   -- distance between chevrons in pixels
local CHEVRON_END_PAD_PX = 10   -- skip placement within this many px of either endpoint
local CHEVRON_MIN_PATH_PX = 70  -- shorter paths skip chevrons entirely

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
        local segLen = math.sqrt(dx * dx + dy * dy)
        segLens[i-1] = segLen
        total = total + segLen
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

    -- Accumulate arc length, placing a chevron at each stride target.
    local accum = 0
    for i = 1, #segLens do
        local segLen = segLens[i]
        local segStart = accum
        local segEnd = accum + segLen
        local p, c = screenPts[i], screenPts[i+1]
        local dx, dy = c[1] - p[1], c[2] - p[2]
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
    for _, v in ipairs(self.labels)   do
        v:Hide()
        -- Clear completionCheck pulse state so a recycled label
        -- doesn't keep flashing the next time the labels pool is
        -- reused on a non-flashing seg.
        v.flashState = nil
        v.flashBase  = nil
    end
    for _, v in ipairs(self.rings)    do
        v:Hide()
        -- Clear completion state so a recycled ring doesn't stay gray on
        -- an incomplete seg the next time the pool is reused.
        v.completeState = nil
    end
    for _, v in ipairs(self.chevrons) do v:Hide() end
    for _, v in ipairs(self.poiIcons)  do v:Hide() end
    for _, v in ipairs(self.poiLabels) do v:Hide() end
end

-- Is this seg already behind the step's progress?
local function SegIsComplete(step, seg)
    if not step or not step.segments then return false end
    for i, candidate in ipairs(step.segments) do
        if candidate == seg then
            local stepIndex = step.step or step.priority or 0
            return i < RR:GetProgress(stepIndex)
        end
    end
    return false
end

-- Place a text label adjacent to an endpoint icon. Used for opt-in map
-- labels (seg.mapLabel / poi.mapLabel). pos selects one of 9 placements:
-- 4 cardinal (above/below/left/right), 4 diagonal (upper-left/upper-right/
-- lower-left/lower-right), or "middle" (centered ON the coord). Default
-- "below". iconHalf = half the icon's dimension in px (icons are square),
-- for the icon-to-label gap. Diagonal placements anchor the label's inner
-- corner to the icon's outer corner; "middle" sits the label on the coord
-- itself (pair with noMarker to label a point that has no marker).
function overlay:PlaceLabel(label, pos, nx, ny, iconHalf)
    local W, H = self:GetWidth(), self:GetHeight()
    label:ClearAllPoints()
    local gap = iconHalf + 2
    local cx, cy = nx * W, -ny * H
    if pos == "above" then
        label:SetPoint("BOTTOM", self, "TOPLEFT", cx, cy + gap)
    elseif pos == "left" then
        label:SetPoint("RIGHT", self, "TOPLEFT", cx - gap, cy)
    elseif pos == "right" then
        label:SetPoint("LEFT", self, "TOPLEFT", cx + gap, cy)
    elseif pos == "upper-left" then
        label:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", cx - gap, cy + gap)
    elseif pos == "upper-right" then
        label:SetPoint("BOTTOMLEFT", self, "TOPLEFT", cx + gap, cy + gap)
    elseif pos == "lower-left" then
        label:SetPoint("TOPRIGHT", self, "TOPLEFT", cx - gap, cy - gap)
    elseif pos == "lower-right" then
        label:SetPoint("TOPLEFT", self, "TOPLEFT", cx + gap, cy - gap)
    elseif pos == "middle" then
        label:SetPoint("CENTER", self, "TOPLEFT", cx, cy)
    else  -- "below" or nil
        label:SetPoint("TOP", self, "TOPLEFT", cx, cy - gap)
    end
end

-- Always-on global POIs: raid-level fixtures (vendors, doors/tunnels,
-- hand-authored markers) that show regardless of the current step, unlike
-- the objective POIs the route drives. Icon per poi.poiKind; a plain marker
-- for anything unlisted. Static (no pulse/completion) so they read as
-- reference points, not the current objective.
local GLOBAL_POI_TEXTURES = {
    vendor    = "Interface\\AddOns\\RetroRuns\\Media\\CoinStack",
    repair    = "Interface\\GossipFrame\\VendorRepairGossipIcon",
    innkeeper = "Interface\\GossipFrame\\BinderGossipIcon",
}
local GLOBAL_POI_DEFAULT = "Interface\\GossipFrame\\GossipGossipIcon"

function overlay:DrawGlobalPOIsForMap(mapID)
    local raid = RR.currentRaid
    if not raid or not raid.pois then return end
    local iconIdx, labelIdx = 1, 1
    for _, poi in ipairs(raid.pois) do
        if poi.mapID == mapID and poi.points and #poi.points > 0
            and iconIdx <= MAX_GLOBAL_POI then
            local mark = poi.navPoint or poi.points[#poi.points]
            if not poi.noMarker then
                local icon = self.poiIcons[iconIdx]
                if icon then
                    PlaceAt(icon, self, mark[1], mark[2])
                    icon:SetTexture(GLOBAL_POI_TEXTURES[poi.poiKind]
                                    or GLOBAL_POI_DEFAULT)
                    icon:SetVertexColor(1, 1, 1, 1)
                    icon:SetRotation(0)
                    icon:SetDrawLayer("ARTWORK")
                    icon:SetSize(poi.poiSize or 26, poi.poiSize or 26)
                    icon:Show()
                    iconIdx = iconIdx + 1
                end
            end
            if poi.mapLabel then
                local label = self.poiLabels[labelIdx]
                if label then
                    self:PlaceLabel(label, poi.mapLabelPos, mark[1], mark[2],
                        (poi.poiSize or 26) / 2)
                    label:SetText(RR.L[poi.mapLabel])
                    label:Show()
                    labelIdx = labelIdx + 1
                end
            end
        end
    end
end

function overlay:DrawSegmentsForMap(mapID)
    -- A completed route draws nothing.
    if RR.IsActiveRouteComplete and RR:IsActiveRouteComplete() then return end

    local step = RR.state.activeStep
    if not step then return end

    local segments = RR:PickLineSegs(step, mapID)
    if not segments or #segments == 0 then return end

    local W, H      = self:GetWidth(), self:GetHeight()
    local lineIdx    = 1
    local iconIdx    = 1
    local labelIdx   = 1
    local ringIdx    = 1
    local chevronIdx = 1

    for _, seg in ipairs(segments) do
        local pts = seg.points
        if pts and #pts > 0 then

            -- A "go here" pin rather than a path. noMarker suppresses even
            -- the marker, leaving a note-only seg.
            if seg.kind == "poi" then
                if not seg.noMarker then
                local mark    = seg.navPoint or pts[#pts]
                local poiIcon = self.icons[iconIdx]
                if poiIcon then
                    PlaceAt(poiIcon, self, mark[1], mark[2])
                    poiIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
                    poiIcon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
                    -- Pooled icons carry state over from a previous use.
                    poiIcon:SetRotation(0)
                    poiIcon:SetDrawLayer("ARTWORK")
                    -- 35 suits a sub-zone map; world-scale maps override it.
                    local size = seg.poiSize or 35
                    poiIcon:SetSize(size, size)
                    poiIcon:Show()
                    iconIdx = iconIdx + 1
                end
                end -- end "if not seg.noMarker"

                -- mapLabelPos: above/below/left/right, the four diagonals, or
                -- middle. Default below.
                if seg.mapLabel then
                    local label = self.labels[labelIdx]
                    if label then
                        local mark = seg.navPoint or pts[#pts]
                        local poiHalf = (seg.poiSize or 35) / 2
                        self:PlaceLabel(label, seg.mapLabelPos, mark[1], mark[2], poiHalf)

                        if seg.completionCheck then
                            local isComplete = SegIsComplete(step, seg)
                            local labelText = RR.L[seg.mapLabel]
                            if isComplete then
                                label:SetText("|cff9d9d9d" .. labelText
                                    .. "|r |TInterface\\RaidFrame\\ReadyCheck-Ready:14|t")
                                label.flashState = "completed"
                            else
                                local color = (RR.GetLabelPulseColor and RR:GetLabelPulseColor())
                                    or "|cffffffff"
                                label:SetText(color .. labelText .. "|r")
                                label.flashState = "pulsing"
                                label.flashBase  = labelText
                            end
                        elseif seg.mapLabelPulse then
                            -- Pulses forever, with no completion state.
                            local color = (RR.GetLabelPulseColor and RR:GetLabelPulseColor())
                                or "|cffffffff"
                            label:SetText(color .. RR.L[seg.mapLabel] .. "|r")
                            label.flashState = "pulsing"
                            label.flashBase  = RR.L[seg.mapLabel]
                        else
                            label:SetText(RR.L[seg.mapLabel])
                        end

                        label:Show()
                        labelIdx = labelIdx + 1
                    end
                end
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
                PlaceEndMarker(self, endIcon, pts, dest, W, H, seg.endpointKind)
                endIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Optional opt-in map label. Path end-triangle is 24x24
            -- (see PlaceEndMarker); half-height = 12 for the gap.
            -- Accepts the same seg.mapLabelPos values as the POI
            -- branch above.
            if seg.mapLabel then
                local label = self.labels[labelIdx]
                if label then
                    self:PlaceLabel(label, seg.mapLabelPos, dest[1], dest[2], 12)
                    label:SetText(seg.mapLabel)
                    label:Show()
                    labelIdx = labelIdx + 1
                end
            end

            end -- end "if seg.kind == poi else"

            -- Pulsing red ring at the seg's navPoint.
            if seg.highlightCircle then
                local ring = self.rings[ringIdx]
                if ring then
                    local mark = seg.navPoint or pts[#pts]
                    PlaceAt(ring, self, mark[1], mark[2])
                    -- Stops the ring ticker repainting this one red.
                    if seg.completionCheck and SegIsComplete(step, seg) then
                        ring.completeState = true
                        ring:SetVertexColor(0.61, 0.61, 0.61, 1)
                    else
                        ring.completeState = nil
                    end
                    ring:Show()
                    ringIdx = ringIdx + 1
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
        -- Global POIs first (drawn on every step, between steps, and after
        -- the route is complete -- independent of DrawSegmentsForMap's
        -- active-step and route-complete gates), then the step objectives.
        self:DrawGlobalPOIsForMap(mapID)
        self:DrawSegmentsForMap(mapID)
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
    if button == "LeftButton" and RR.RecorderHandleMapClick then
        RR:RecorderHandleMapClick()
    end
end)

C_Timer.NewTicker(1.0, function()
    if WorldMapFrame and WorldMapFrame:IsShown() then
        overlay:Refresh()
    end
end)

-- Re-tints pulsing labels. Same 0.1s cadence as the panel's [!] glyphs.
C_Timer.NewTicker(0.1, function()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    if not RR.GetLabelPulseColor then return end
    local color = RR:GetLabelPulseColor()
    for _, label in ipairs(overlay.labels) do
        if label:IsShown()
            and label.flashState == "pulsing"
            and label.flashBase
        then
            label:SetText(color .. label.flashBase .. "|r")
        end
    end
end)

-- Breathes the rings by modulating red only, on the same shared phase.
C_Timer.NewTicker(0.1, function()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    if not RR.GetRingPulseRed then return end
    local pulseRed = RR:GetRingPulseRed()
    for _, ring in ipairs(overlay.rings) do
        if ring:IsShown() and not ring.completeState then
            ring:SetVertexColor(pulseRed, 0, 0, 1)
        end
    end
end)
