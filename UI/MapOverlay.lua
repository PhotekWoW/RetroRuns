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
-- Highlight rings: a few per map at most (one per seg opting in via
-- highlightCircle). 10 is comfortable headroom for any single render.
local MAX_RINGS    = 10
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
overlay.rings    = {}
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

-- Highlight ring. Uses Media/RingCircle.tga -- a 64x64 anti-aliased
-- white ring on transparent background, band radius 24..28 in texture
-- space (so the ring sits at ~75-88% of the texture extent and scales
-- predictably with SetSize). Authored white so SetVertexColor's red
-- channel cleanly drives the displayed red intensity for the pulse.
--
-- Drawn at OVERLAY so the ring sits above native Blizzard map icons
-- (exit arrows, NPC dots) -- the whole point of the ring is to draw
-- the eye to one of those native icons, so we want to surround it
-- visually rather than be painted over.
local function MakeRing(p)
    local tx = p:CreateTexture(nil, "OVERLAY")
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
for i = 1, MAX_RINGS    do overlay.rings[i]    = MakeRing(overlay)    end
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
-- at rotation 0 (WoW's raid-target icon orientation isn't documented, so
-- this is from observed behavior). WoW SetRotation uses
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
        -- points DOWN (south, +y in screen coords) at rotation 0, from
        -- observed behavior. WoW's SetRotation uses counter-clockwise
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
    for _, v in ipairs(self.labels)   do
        v:Hide()
        -- Clear completionCheck pulse state so a recycled label
        -- doesn't keep flashing the next time the labels pool is
        -- reused on a non-flashing seg.
        v.flashState = nil
        v.flashBase  = nil
    end
    for _, v in ipairs(self.rings)    do v:Hide() end
    for _, v in ipairs(self.chevrons) do v:Hide() end
end

function overlay:DrawSegmentsForMap(mapID)
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

    -- Place a text label adjacent to an endpoint icon. Used for
    -- opt-in per-seg map labels (seg.mapLabel = "Console", etc.).
    -- pos selects one of 9 placements: 4 cardinal (above/below/left/
    -- right), 4 diagonal (upper-left/upper-right/lower-left/lower-
    -- right), or "middle" (centered ON the coord with no gap).
    -- Default "below" preserves the original behavior.
    -- iconHalf = half the icon's dimension in pixels (icons are
    -- square), used to compute the gap between icon and label.
    --
    -- Cardinal placements align the label's far edge with the
    -- icon's center axis. Diagonal placements anchor the label's
    -- inner corner to the icon's outer corner, giving the label a
    -- 45-degree offset clear of both axes -- useful when adjacent
    -- segments leave both vertical and horizontal space around
    -- the icon partially obstructed. "middle" centers the label on
    -- the coord itself; paired with noMarker=true it lets the label
    -- sit directly over a fixed reference point (e.g. an interactable
    -- located underneath a boss icon, where any cardinal offset
    -- would push the label off the object).
    local function PlaceLabel(label, pos, nx, ny, iconHalf)
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
                    -- Default 35 is the standard sub-zone-map size used
                    -- across the shipped raids. Outliers on world-scale
                    -- maps (Fyrakk's portal on Amirdrassil) override
                    -- via per-segment poiSize for proportional rendering.
                    local size = seg.poiSize or 35
                    poiIcon:SetSize(size, size)
                    poiIcon:Show()
                    iconIdx = iconIdx + 1
                end
                end -- end "if not seg.noMarker"

                -- Optional opt-in map label. POI uses the star's
                -- half-size for the gap so the label sits adjacent
                -- to the star regardless of poiSize. Segments whose
                -- icon sits close to adjacent path lines or other
                -- icons can choose a non-default placement via
                -- seg.mapLabelPos = "above" | "below" | "left" |
                -- "right" | "upper-left" | "upper-right" |
                -- "lower-left" | "lower-right" | "middle". Default
                -- is "below". "middle" centers the label on the
                -- coord with no gap, useful for noMarker segs where
                -- the coord is the visual anchor.
                --
                -- seg.completionCheck = true opts the label into a
                -- two-state visual: while the seg is incomplete the
                -- text breathes in the same yellow pulse as the
                -- encounter [!] glyph; once the seg completes, the
                -- text goes static gray with a green checkmark
                -- appended. The pulse retint happens on a 0.1s
                -- ticker at the bottom of this file; the static
                -- complete state is set once here and persists
                -- until the next label-pool recycle.
                if seg.mapLabel then
                    local label = self.labels[labelIdx]
                    if label then
                        local mark = seg.navPoint or pts[#pts]
                        local poiHalf = (seg.poiSize or 35) / 2
                        PlaceLabel(label, seg.mapLabelPos, mark[1], mark[2], poiHalf)

                        if seg.completionCheck then
                            -- Locate segIndex by identity in step.segments
                            -- so we can query the engine's completion state.
                            local segIndex
                            for i, s in ipairs(step.segments) do
                                if s == seg then segIndex = i; break end
                            end
                            local isComplete = false
                            if segIndex then
                                local stepIndex = step.step or step.priority or 0
                                isComplete = segIndex < RR:GetProgress(stepIndex)
                            end

                            if isComplete then
                                label:SetText("|cff9d9d9d" .. seg.mapLabel
                                    .. "|r |TInterface\\RaidFrame\\ReadyCheck-Ready:14|t")
                                label.flashState = "completed"
                            else
                                local color = (RR.GetLabelPulseColor and RR:GetLabelPulseColor())
                                    or "|cffffffff"
                                label:SetText(color .. seg.mapLabel .. "|r")
                                label.flashState = "pulsing"
                                label.flashBase  = seg.mapLabel
                            end
                        elseif seg.mapLabelPulse then
                            -- Always-pulse mode: no completion tracking, no
                            -- gray/checkmark end-state. Used when the seg
                            -- represents an interactable with no detectable
                            -- completion signal (e.g. clicking an object
                            -- that fires no event the addon can hook). The
                            -- label breathes yellow on the same shared phase
                            -- counter as completionCheck pulses.
                            local color = (RR.GetLabelPulseColor and RR:GetLabelPulseColor())
                                or "|cffffffff"
                            label:SetText(color .. seg.mapLabel .. "|r")
                            label.flashState = "pulsing"
                            label.flashBase  = seg.mapLabel
                        else
                            label:SetText(seg.mapLabel)
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
                    PlaceLabel(label, seg.mapLabelPos, dest[1], dest[2], 12)
                    label:SetText(seg.mapLabel)
                    label:Show()
                    labelIdx = labelIdx + 1
                end
            end

            end -- end "if seg.kind == poi else"

            -- Optional opt-in attention ring. Renders a pulsing red
            -- ring at the seg's navPoint (or final point) on top of
            -- whatever the seg drew above. Drawn at OVERLAY layer so
            -- it sits above any native Blizzard map icon at that
            -- coord (exit arrows, NPC dots) -- the point of the ring
            -- is to surround such a native icon visually, drawing
            -- the eye to it without obscuring it.
            --
            -- Pulse via the ring ticker at the bottom of this file:
            -- 0.1s cadence, red-brightness modulated in sync with
            -- the label and yellow [!] pulses (shared phase counter).
            if seg.highlightCircle then
                local ring = self.rings[ringIdx]
                if ring then
                    local mark = seg.navPoint or pts[#pts]
                    PlaceAt(ring, self, mark[1], mark[2])
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

-- Per-label pulse ticker for opt-in completionCheck labels. Runs at
-- 0.1s (same cadence as the UI's encounter [!] and What's New? [!]
-- pulses) and re-tints labels whose flashState == "pulsing" so the
-- "click this" attention-grabber breathes while the seg remains
-- incomplete. Completed labels are static (gray + checkmark) and
-- skipped. Cheap: bails entirely when the world map isn't visible,
-- and iterates only the labels pool (typically <10 entries).
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

-- Per-ring pulse ticker for highlightCircle rings. Same 0.1s cadence
-- as the label and yellow [!] pulses (shared phase counter via the
-- RR:GetRingPulseRed accessor), but modulates the red channel only
-- so the ring breathes bright-red to dim-red and back. Same bail-out
-- guard as the label ticker; rings pool is small (MAX_RINGS=10).
C_Timer.NewTicker(0.1, function()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    if not RR.GetRingPulseRed then return end
    local r = RR:GetRingPulseRed()
    for _, ring in ipairs(overlay.rings) do
        if ring:IsShown() then
            ring:SetVertexColor(r, 0, 0, 1)
        end
    end
end)
