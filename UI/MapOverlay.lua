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
-- One entry per POI: a multi-spawn rare draws a single area rather than a
-- marker per point, so the count is POIs on screen, not spawn points.
local MAX_GLOBAL_POI = 24

-- Spawn spots: small copies of the rare skull at each recorded sighting,
-- shown while the cursor rests on the marker and kept shown by a click.
-- Each POI takes a palette color by its position in the pois list, so two
-- pinned rares can never share one and a rare keeps its color all
-- session. Nothing is drawn between the sightings, so the map never
-- claims ground the data does not have.
local SPOT_SIZE = 12
local SPOT_ALPHA = 0.95
-- INVARIANT: none of these may be a color the ROUTE draws in. The route
-- line is gold (1.0, 0.82, 0.0), its chevrons cyan (0.30, 0.80, 1.00) and
-- its gated variant pink (0.95, 0.35, 0.78). Three of the four original
-- entries WERE those exact values, so a skull sitting on the path was
-- indistinguishable from the path. Pick a new color from outside that set,
-- never from the route's.
local SPOT_PALETTE = {
    { 0.800, 0.600, 1.000 },   -- lavender
    { 0.400, 0.930, 0.470 },   -- mint
    { 1.000, 1.000, 1.000 },   -- white
    { 1.000, 0.640, 0.420 },   -- peach
}
local MAX_SPAWN_SPOTS = 64

-- Brand glow behind a marker whose own art carries no RetroRuns color, so
-- it still reads as ours. Additive, so it lifts the map rather than masking
-- it. Both are dimmed -- additive blending on a light map blows out fast at
-- full strength. Which color a kind takes is a LOOK decision: pink behind
-- the gold chest, brand cyan behind the coin stack, whose own gold turns
-- muddy under pink.
local C_POI_GLOW_PINK = { 0.949, 0.349, 0.780, 0.55 }
local C_POI_GLOW_CYAN = { 0.000, 0.750, 1.000, 0.55 }
local POI_GLOW_SCALE = 2.6

-- Global-POI chrome sits a step under the route's own markers and labels, so
-- reference points read as secondary to the objective.
local GLOBAL_POI_SIZE = 23.4   -- route markers use 26
local GLOBAL_POI_FONT = 15     -- shared label size is 17

-- Brand wordmark, for tooltips and the map-column menu: everything this
-- overlay pops up says whose it is.
local RETRO_WORDMARK = "|cffF259C7RETRO|r|cff4DCCFFRUNS|r"

local overlay = CreateFrame(
    "Frame", "RetroRunsMapOverlay",
    WorldMapFrame.ScrollContainer.Child)
overlay:SetAllPoints(WorldMapFrame.ScrollContainer.Child)

-- Pin addons draw at HIGH strata and re-derive their level on every pin
-- acquire, one above whatever is highest, so no fixed level draws over
-- them. The overlay sits at HIGH just under the player-arrow band: above
-- the canvas, below their markers. Our marker is the larger of the two so
-- its edge reads at zoom, both keep their hover, and the corner legend
-- carries the names independently of the icons.
do
    local canvasMap = WorldMapFrame.ScrollContainer
        and WorldMapFrame.ScrollContainer.GetMap
        and WorldMapFrame.ScrollContainer:GetMap()
    local levelManager = canvasMap and canvasMap.GetPinFrameLevelsManager
        and canvasMap:GetPinFrameLevelsManager()
    if levelManager and levelManager.GetValidFrameLevel then
        local levelOk, playerBand = pcall(levelManager.GetValidFrameLevel,
            levelManager, "PIN_FRAME_LEVEL_GROUP_MEMBER")
        if levelOk and type(playerBand) == "number" and playerBand > 10 then
            overlay:SetFrameLevel(playerBand - 10)
        end
    end
end

overlay.lines    = {}
overlay.icons    = {}
overlay.dots     = {}
overlay.labels   = {}
overlay.rings    = {}
overlay.chevrons = {}
overlay.poiIcons  = {}   -- always-on global-POI markers
overlay.legendIcons = {}  -- skull swatches for corner-legend entries
overlay.poiLabels = {}   -- always-on global-POI labels
overlay.poiSpots     = {}   -- sighting skulls behind a hovered/pinned marker
overlay.poiSpotBacks = {}   -- dark discs that lift the skulls off the map art
overlay.poiSpotRings = {}   -- breathing color rings around the skulls
overlay.poiButtons   = {}   -- invisible hit targets over multi-spawn markers
overlay.spotPois     = {}   -- spotKey -> poi, rebuilt each refresh
overlay.pinnedSpots  = {}   -- spotKey -> true while a click holds them on
overlay.poiGlows     = {}   -- brand halo behind a marker that earns one

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

local function MakeLabel(parent, fontSize)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetTextColor(1.0, 1.0, 1.0, 1.0)
    fs:SetFont(fs:GetFont(), fontSize or 17, "OUTLINE")
    fs:Hide()
    return fs
end

-- Direction-of-travel chevron. The asset points down at rotation 0.
local function MakeChevron(parent)
    local tx = parent:CreateTexture(nil, "OVERLAY")
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\Chevron")
    tx:SetVertexColor(0.30, 0.80, 1.00, 1.0)  -- cyan (matches UI.lua C_BLUE)
    tx:SetSize(18, 18)
    tx:Hide()
    return tx
end

-- Soft halo, the same EpicGlow the toaster haloes an appearance with.
local function MakePoiGlow(parent)
    local tx = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Toast\\EpicGlow")
    tx:SetBlendMode("ADD")
    tx:Hide()
    return tx
end

local function MakeSpot(parent)
    local tx = parent:CreateTexture(nil, "ARTWORK", nil, -1)
    tx:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
    tx:SetSize(SPOT_SIZE, SPOT_SIZE)
    tx:Hide()
    return tx
end

-- A dark disc under each sighting skull: the map art is light, the skulls
-- are small, and without a backing they sink into it.
local function MakeSpotBack(parent)
    local tx = parent:CreateTexture(nil, "ARTWORK", nil, -2)
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\StatusDot")
    tx:SetVertexColor(0, 0, 0, 0.55)
    tx:SetSize(SPOT_SIZE + 5, SPOT_SIZE + 5)
    tx:Hide()
    return tx
end

-- The highlight border around each sighting skull, in the rare's color.
-- Its alpha breathes while shown (see SetSpotPulse).
local function MakeSpotRing(parent)
    local tx = parent:CreateTexture(nil, "ARTWORK", nil, -1)
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\RingCircle")
    tx:SetSize(SPOT_SIZE + 8, SPOT_SIZE + 8)
    tx:Hide()
    return tx
end

-- A marker's own appearances, each with whether the look is collected.
-- Mirrors the special-loot rows' glyphs so one convention covers both.
local TIP_GLYPH_HAVE = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local TIP_GLYPH_NEED = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14|t"

-- Keyed on whatever named the marker: a rare's npc name, or an object's
-- tag. The BRD safe and the Tribute chest carry their loot on `tag`, so
-- matching only `rareNpc` left those markers with nothing to show.
local function PoiLootLines(key)
    local raid = RR.currentRaid
    local lookCollected = RR.UI and RR.UI.IsSourceLookCollected
    if not raid or not raid.trashLoot or not key or not lookCollected then
        return nil
    end
    local rows = {}
    for _, row in ipairs(raid.trashLoot) do
        if (row.rareNpc == key or row.tag == key) and row.sources then
            -- A row can carry several difficulty buckets; it only counts as
            -- collected once every look it offers is owned.
            local seen, have = false, true
            for _, sourceID in pairs(row.sources) do
                seen = true
                if not lookCollected(sourceID) then have = false end
            end
            if seen then
                rows[#rows + 1] =
                    { id = row.id, name = row.name, have = have }
            end
        end
    end
    return rows
end

-- Caret spans render orange, mirroring UI.lua's HighlightNames. That one is
-- a file-local in a chunk at Lua's 200-local ceiling and cannot be called
-- from here, so the logic is duplicated -- but the COLOR is not.
local HINT_ORANGE = "|cff" .. RR.C_ORANGE

local function HighlightCarets(text)
    if not text or text == "" then return text end
    text = text:gsub("%^([^%^]+)%^", function(span)
        local localized = (RR.L and RR.L[span]) or span
        return HINT_ORANGE .. localized .. "|r"
    end)
    return (text:gsub("%^", ""))
end

-- A gated boss's own looks, in the same shape PoiLootLines returns, so an
-- object that unlocks a boss lists what is behind it exactly the way a rare
-- lists its own drops.
local function BossLootLines(bossIndex)
    local raid = RR.currentRaid
    local lookCollected = RR.UI and RR.UI.IsSourceLookCollected
    if not raid or not raid.bosses or not bossIndex or not lookCollected then
        return nil
    end
    local boss
    for _, candidate in ipairs(raid.bosses) do
        if candidate.index == bossIndex then boss = candidate break end
    end
    if not boss or not boss.loot then return nil end
    local rows = {}
    for _, row in ipairs(boss.loot) do
        local seen, have = false, true
        for _, sourceID in pairs(row.sources or {}) do
            seen = true
            if not lookCollected(sourceID) then have = false end
        end
        if seen then
            rows[#rows + 1] = { id = row.id, name = row.name, have = have }
        end
    end
    return rows
end

-- Tooltip for a marker hit target. Split from OnEnter so a click can
-- refresh the pin hint without re-arming the hover preview. The brand
-- mark rides the title line's right edge, saying whose popup this is
-- without spending a line on it.
local function ShowSpotTooltip(btn)
    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
    GameTooltip:AddDoubleLine(btn.labelText or "",
        "|cffF259C7R|r|cff4DCCFFR|r", 1, 1, 1, 1, 1, 1)
    local tint  = btn.spotColor or SPOT_PALETTE[1]
    local count = btn.spotCount or 0
    -- Sightings are a RARE's story. A vendor or a chest does not spawn, so
    -- the line would read as nonsense on the 24 markers that are neither.
    if btn.poiKind == "rare" then
        GameTooltip:AddLine(count == 1
            and RR.L["1 recorded spawn point"]
            or (RR.L["%d recorded spawn points"]):format(count),
            tint[1], tint[2], tint[3])
    end
    -- One sighting is already where the marker sits, so there is nothing a
    -- click could reveal; the hint would promise a behavior we do not have.
    if count > 1 then
        GameTooltip:AddLine(overlay.pinnedSpots[btn.spotKey]
            and RR.L["Click to hide them"]
            or RR.L["Click to keep them shown"], 0.7, 0.7, 0.7)
    end
    -- Where it is, then what it is for. Both wrap: a marker hint is prose,
    -- and the loot lines below set the tooltip's width on their own.
    --
    -- The location line is DIRECTIONS, so it earns its space only while the
    -- player is somewhere else. A uiMap can stack two areas -- map 250 holds
    -- both Blackrock Spire's first floor and Tazz'Alor below it -- and the
    -- marker cannot say which one it means positionally. Naming the subZone
    -- lets the hint say it in words, and say it only when it is needed.
    -- The marker itself always shows, for anyone browsing from elsewhere.
    if btn.hintNote then
        GameTooltip:AddLine(HighlightCarets(RR.L[btn.hintNote]), 1, 1, 1, true)
    end
    if btn.hintWhere then
        local here = (GetSubZoneText and GetSubZoneText()) or ""
        if not btn.poiSubZone or btn.poiSubZone ~= here then
            GameTooltip:AddLine(HighlightCarets(RR.L[btn.hintWhere]), 1, 1, 1, true)
        end
    end
    -- A marker's own drops first; an object that only GATES a boss shows
    -- that boss's looks instead, so both read the same way.
    local loot = PoiLootLines(btn.spotKey)
    if (not loot or #loot == 0) and btn.hintBoss then
        loot = BossLootLines(btn.hintBoss)
    end
    if loot and #loot > 0 then
        GameTooltip:AddLine(" ")
        for _, row in ipairs(loot) do
            -- Cold item cache: GetItemInfo answers nil until the client has
            -- seen the item, and a placeholder reads as a broken row. The
            -- data row's own name covers the gap, and the request warms the
            -- cache so the next hover gets the real localized link.
            local _, link = C_Item.GetItemInfo(row.id)
            if not link then
                if C_Item and C_Item.RequestLoadItemDataByID then
                    C_Item.RequestLoadItemDataByID(row.id)
                end
            end
            -- White explicitly: AddLine with no color defaults to YELLOW,
            -- so the cold-cache fallback name read as a highlight until the
            -- item cache answered. A real link carries its own quality
            -- color and overrides this.
            GameTooltip:AddLine(("%s %s"):format(
                row.have and TIP_GLYPH_HAVE or TIP_GLYPH_NEED,
                link or row.name or tostring(row.id)), 1, 1, 1)
        end
    end
    GameTooltip:Show()
end

-- Invisible hit target sized to the marker it covers. Hovering previews
-- the sighting skulls and a tooltip; clicking keeps the skulls shown.
local function MakePoiButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:Hide()
    btn:SetScript("OnEnter", function(self)
        overlay.hoveredSpotKey = self.spotKey
        overlay:UpdateSpawnSpots()
        ShowSpotTooltip(self)
    end)
    btn:SetScript("OnLeave", function(self)
        overlay.hoveredSpotKey = nil
        overlay:UpdateSpawnSpots()
        GameTooltip:Hide()
    end)
    btn:SetScript("OnClick", function(self)
        if (self.spotCount or 0) < 2 then return end
        if overlay.pinnedSpots[self.spotKey] then
            overlay.pinnedSpots[self.spotKey] = nil
            -- An unpin means off NOW. Leaving the hover preview armed kept
            -- the skulls up until the cursor left, reading as a dead click.
            overlay.hoveredSpotKey = nil
        else
            overlay.pinnedSpots[self.spotKey] = true
        end
        overlay:UpdateSpawnSpots()
        ShowSpotTooltip(self)
    end)
    return btn
end

local function MakeRing(parent)
    local tx = parent:CreateTexture(nil, "OVERLAY")
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\RingCircle")
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
for i = 1, MAX_GLOBAL_POI do overlay.legendIcons[i] = MakeIcon(overlay) end
for i = 1, MAX_GLOBAL_POI do overlay.poiLabels[i] = MakeLabel(overlay, GLOBAL_POI_FONT) end
for i = 1, MAX_SPAWN_SPOTS do overlay.poiSpots[i]     = MakeSpot(overlay)     end
for i = 1, MAX_SPAWN_SPOTS do overlay.poiSpotBacks[i] = MakeSpotBack(overlay) end
for i = 1, MAX_SPAWN_SPOTS do overlay.poiSpotRings[i] = MakeSpotRing(overlay) end
for i = 1, MAX_GLOBAL_POI  do overlay.poiButtons[i]   = MakePoiButton(overlay) end
for i = 1, MAX_GLOBAL_POI do overlay.poiGlows[i]     = MakePoiGlow(overlay)  end

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

    icon:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\EndTriangle")
    -- White tint is a no-op, so the asset's baked colors render as authored.
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
    for _, v in ipairs(self.legendIcons) do v:Hide() end
    for _, v in ipairs(self.poiLabels) do v:Hide() end
    for _, v in ipairs(self.poiSpots)     do v:Hide() end
    for _, v in ipairs(self.poiSpotBacks) do v:Hide() end
    for _, v in ipairs(self.poiSpotRings) do v:Hide() end
    -- poiButtons deliberately NOT hidden here: hiding a button between
    -- mouse-down and mouse-up cancels the click, and the heartbeat runs
    -- this often (the heartbeat click-race). The draw loop hides exactly
    -- the buttons that go unused, and Refresh covers the no-draw paths.
    for _, v in ipairs(self.poiGlows)      do v:Hide() end
end

-- Is this seg already behind the step's progress?
local function SegIsComplete(step, seg)
    if not step or not step.segments then return false end
    for i, candidate in ipairs(step.segments) do
        if candidate == seg then
            local stepIndex = step.step or step.priority or 0
            if i < RR:GetProgress(stepIndex) then return true end
            -- A gate that fired is complete even while progress still sits
            -- ON it -- which is always the case for a triggered poi that is
            -- its step's LAST segment: progress cannot move past the end,
            -- so the strict comparison alone would never tick it.
            return candidate.triggeredBy ~= nil
                and RR.HasTriggerFired ~= nil
                and RR:HasTriggerFired(stepIndex, i)
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

-- Corner legend. On a floor carrying several rares the anchored labels
-- collide with each other and with the route; these stack in one corner
-- instead. Opt-in per POI, because an empty corner on one map is a busy
-- one on the next.
local LEGEND_CORNERS = {
    ["legend-bottomleft"]  = "BOTTOMLEFT",
    ["legend-bottomright"] = "BOTTOMRIGHT",
    ["legend-topleft"]     = "TOPLEFT",
    ["legend-topright"]    = "TOPRIGHT",
}
local LEGEND_INSET_X = 14
-- Right-hand corners also stand in from the edge, clear of the rock art
-- that frames the right side of most instance maps.
local LEGEND_INSET_X_RIGHT = 70
local LEGEND_INSET_Y = 52
-- The right-hand corners sit over the map frame's own bottom-right
-- controls, so their stack starts higher.
local LEGEND_INSET_Y_RIGHT = 140
local LEGEND_LINE    = 22
local LEGEND_FONT    = 19
local LEGEND_ICON    = 18

-- Entries keep their palette color, so color is the only thing tying a
-- line back to its skull. Order follows draw order, stacking away from the
-- corner it is anchored to.
function overlay:PlaceLegendLabel(label, icon, corner, index, tint, texture)
    local up    = corner:find("BOTTOM") ~= nil
    local right = corner:find("RIGHT") ~= nil
    local insetY = right and LEGEND_INSET_Y_RIGHT or LEGEND_INSET_Y
    local dy    = (up and 1 or -1) * (insetY + index * LEGEND_LINE)
    local dx    = right and -LEGEND_INSET_X_RIGHT or LEGEND_INSET_X
    label:ClearAllPoints()
    label:SetJustifyH(right and "RIGHT" or "LEFT")
    -- The skull rides the outer edge so the names stay flush in a column;
    -- on a right-hand corner that mirrors, skull outside, text inboard.
    if icon and texture then
        icon:SetTexture(texture)
        icon:SetTexCoord(0, 1, 0, 1)
        icon:SetSize(LEGEND_ICON, LEGEND_ICON)
        icon:SetVertexColor(tint[1], tint[2], tint[3], 1)
        icon:ClearAllPoints()
        icon:SetPoint(corner, self, corner, dx, dy)
        icon:Show()
        label:SetPoint(right and "RIGHT" or "LEFT", icon,
                       right and "LEFT" or "RIGHT", right and -6 or 6, 0)
    else
        label:SetPoint(corner, self, corner, dx, dy)
    end
end

-- Always-on global POIs: raid-level fixtures (vendors, doors/tunnels,
-- hand-authored markers) that show regardless of the current step, unlike
-- the objective POIs the route drives. Icon per poi.poiKind; a plain marker
-- for anything unlisted. Static (no pulse/completion) so they read as
-- reference points, not the current objective.
local GLOBAL_POI_TEXTURES = {
    vendor    = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\CoinStack",
    repair    = "Interface\\GossipFrame\\VendorRepairGossipIcon",
    innkeeper = "Interface\\GossipFrame\\BinderGossipIcon",
    alchemy   = "Interface\\Icons\\Trade_Alchemy",
    -- An NPC who takes a turn-in rather than selling anything. The coin
    -- stack would read as "buy from me" where nothing is bought.
    quest     = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\QuestMarker",
    -- Sells gear for a token or currency rather than gold. Blizzard's own
    -- Justice Points icon, which is the helm players already associate
    -- with a gear quartermaster.
    quartermaster = "Interface\\Icons\\pvecurrency-justice",
    -- A rare spawn worth killing for its drops. The skull raid marker
    -- reads as a kill target at pin size and needs no new art.
    rare      = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
    -- A static container the player has to click for its loot, rather
    -- than a mob to kill.
    chest     = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\ChestIcon",
}
-- Tint per kind, multiplied over the texture. Blizzard's skull is white,
-- so a multiply lands on the exact color asked for. Untinted kinds draw
-- at full white, which is the identity for this blend.
local GLOBAL_POI_TINTS = {
    -- RETRO pink, so a rare reads as ours next to every other addon's
    -- plain white skull.
    rare = { 0.949, 0.349, 0.780 },
    -- No entry for chest: its art is drawn in its own colors and a
    -- tint would multiply them away.
}
local GLOBAL_POI_WHITE = { 1, 1, 1 }

-- Kinds that wear the brand halo, and in which color. The rare skull is
-- already tinted pink so it needs none; these two carry their own colors --
-- hand-drawn art and the coin stack -- and the glow marks them as ours
-- without touching the artwork.
local GLOWING_POI_KINDS = {
    chest  = C_POI_GLOW_PINK,
    vendor = C_POI_GLOW_CYAN,
}

local GLOBAL_POI_DEFAULT = "Interface\\GossipFrame\\GossipGossipIcon"

-- Class icons come from Blizzard's shared circle sheet, cropped per class.
local CLASS_ICON_SHEET = "Interface\\TargetingFrame\\UI-Classes-Circles"

function overlay:DrawGlobalPOIsForMap(mapID)
    local raid = RR.currentRaid
    if not raid or not raid.pois then return end
    -- Read at draw time: at file scope the player unit may not exist yet.
    local playerFaction = UnitFactionGroup and UnitFactionGroup("player")
    local _, playerClassToken, playerClassID = UnitClass("player")
    -- A POI tagged with a faction or class draws only for the player it
    -- belongs to; untagged entries stay shared. ICC's tier vendors are a
    -- different NPC per class per faction, so one shared pin sends a Death
    -- Knight most of a room away from theirs.
    local function BelongsToPlayer(poi)
        if poi.faction and poi.faction ~= playerFaction then return false end
        if poi.class and poi.class ~= playerClassID then return false end
        return true
    end
    -- With the setting off, a rare whose every look is already collected
    -- stops drawing: the marker is an errand, and this one has nothing
    -- left to give. A rare with no attributed loot always draws.
    local showCollectedRares =
        RR:GetSetting("showCollectedRares", true) ~= false
    local function RareStillWanted(poi)
        if showCollectedRares then return true end
        if poi.poiKind ~= "rare" or not poi.rareNpc then return true end
        local lookCollected = RR.UI and RR.UI.IsSourceLookCollected
        if not lookCollected then return true end
        local sawLoot = false
        for _, row in ipairs(raid.trashLoot or {}) do
            if row.rareNpc == poi.rareNpc and row.sources then
                sawLoot = true
                for _, sourceID in pairs(row.sources) do
                    if not lookCollected(sourceID) then return true end
                end
            end
        end
        return not sawLoot
    end
    local mapW, mapH = self:GetWidth(), self:GetHeight()
    local legendCount = {}
    local legendSeen  = {}
    -- Marker positions resolve BEFORE rendering so coincident markers can
    -- be nudged apart -- Zerillis and Sandarr Dunereaver's spawn grounds
    -- genuinely overlap, and two skulls on one spot read as one rare. Any
    -- pair closer than a marker's width pushes apart along the line
    -- between them, and the one pushed lower flips its label underneath so
    -- the texts separate too.
    local markFor, labelPosFor, drawList = {}, {}, {}
    for _, poi in ipairs(raid.pois) do
        if poi.mapID == mapID and poi.points and #poi.points > 0
            and BelongsToPlayer(poi) and RareStillWanted(poi) then
            local mark = poi.navPoint or poi.points[1]
            if not poi.navPoint and #poi.points > 1 then
                local sumX, sumY = 0, 0
                for i = 1, #poi.points do
                    sumX = sumX + poi.points[i][1]
                    sumY = sumY + poi.points[i][2]
                end
                mark = { sumX / #poi.points, sumY / #poi.points }
            end
            markFor[poi] = { mark[1], mark[2] }
            drawList[#drawList + 1] = poi
        end
    end
    -- Distances measure in units of the minimum gap per axis, so "1" is
    -- exactly touching whatever the map's aspect ratio.
    local minGapX = (GLOBAL_POI_SIZE + 6) / mapW
    local minGapY = (GLOBAL_POI_SIZE + 6) / mapH
    for a = 1, #drawList - 1 do
        for b = a + 1, #drawList do
            local markA, markB = markFor[drawList[a]], markFor[drawList[b]]
            local dx = (markB[1] - markA[1]) / minGapX
            local dy = (markB[2] - markA[2]) / minGapY
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < 1 then
                local pushX, pushY
                if dist < 0.05 then
                    pushX, pushY = 0, 1
                else
                    pushX, pushY = dx / dist, dy / dist
                end
                local give = (1 - dist) / 2
                markA[1] = markA[1] - pushX * give * minGapX
                markA[2] = markA[2] - pushY * give * minGapY
                markB[1] = markB[1] + pushX * give * minGapX
                markB[2] = markB[2] + pushY * give * minGapY
                local lower = (markA[2] > markB[2])
                    and drawList[a] or drawList[b]
                if (lower.mapLabelPos or "below") == "above" then
                    labelPosFor[lower] = "below"
                end
            end
        end
    end
    local iconIdx, labelIdx = 1, 1
    for poiIndex, poi in ipairs(raid.pois) do
        if poi.mapID == mapID and poi.points and #poi.points > 0
            and BelongsToPlayer(poi)
            and RareStillWanted(poi)
            and iconIdx <= MAX_GLOBAL_POI then
            -- One marker per POI whatever the point count: the rare is at
            -- exactly one of its sightings, so a field of identical markers
            -- would claim more than it knows. An authored navPoint places
            -- the marker; without one a multi-spawn POI centers on its
            -- sightings. The position itself comes from the separation
            -- pass above, already nudged clear of its neighbors.
            local mark = markFor[poi] or poi.navPoint or poi.points[1]
            -- Composed before the marker so the hit target can hand the
            -- same text to its tooltip. A rare POI composes its label from
            -- one format string, so the npc name is the same locale key the
            -- trash rows' tag uses and each name is translated once.
            local labelText
            if poi.mapLabel then
                labelText = RR.L[poi.mapLabel]
            elseif poi.rareNpc then
                labelText = RR.L["%s (Rare)"]:format(RR.L[poi.rareNpc])
            elseif poi.tag then
                labelText = RR.L[poi.tag]
            end
            local spotKey = poi.rareNpc or poi.tag or poi.mapLabel
            local spotColor = SPOT_PALETTE[(poiIndex - 1) % #SPOT_PALETTE + 1]
            if not poi.noMarker then
              do
                local icon = self.poiIcons[iconIdx]
                if icon then
                    PlaceAt(icon, self, mark[1], mark[2])
                    -- Class-tagged markers wear that class's icon. The pool
                    -- is shared, so the plain branch clears the crop.
                    local classCoords = poi.class and CLASS_ICON_TCOORDS
                        and CLASS_ICON_TCOORDS[playerClassToken]
                    if classCoords then
                        icon:SetTexture(CLASS_ICON_SHEET)
                        icon:SetTexCoord(classCoords[1], classCoords[2],
                                         classCoords[3], classCoords[4])
                    else
                        icon:SetTexture(GLOBAL_POI_TEXTURES[poi.poiKind]
                                        or GLOBAL_POI_DEFAULT)
                        icon:SetTexCoord(0, 1, 0, 1)
                    end
                    -- A class-cropped icon keeps its own colors. A rare
                    -- wears its palette color -- the same one its label,
                    -- sightings and tooltip carry -- so two rares on one
                    -- floor never look alike; other kinds keep their
                    -- per-kind tint.
                    local tint = GLOBAL_POI_WHITE
                    if not classCoords then
                        tint = (poi.poiKind == "rare" and spotColor)
                            or GLOBAL_POI_TINTS[poi.poiKind]
                            or GLOBAL_POI_WHITE
                    end
                    icon:SetVertexColor(tint[1], tint[2], tint[3], 1)
                    icon:SetRotation(0)
                    -- Above the route entirely: the lines and dots sit on
                    -- ARTWORK and the chevrons and end markers on OVERLAY,
                    -- so a path drawn through a rare's room passes under
                    -- the skull rather than across its face.
                    icon:SetDrawLayer("OVERLAY", 2)
                    local iconSize = poi.poiSize or GLOBAL_POI_SIZE
                    icon:SetSize(iconSize, iconSize)
                    icon:Show()
                    local glowColor = GLOWING_POI_KINDS[poi.poiKind]
                    if glowColor then
                        -- Same pool index as the marker it sits behind,
                        -- so the two can never drift apart.
                        local glow = self.poiGlows[iconIdx]
                        if glow then
                            PlaceAt(glow, self, mark[1], mark[2])
                            glow:SetSize(iconSize * POI_GLOW_SCALE,
                                         iconSize * POI_GLOW_SCALE)
                            glow:SetVertexColor(glowColor[1], glowColor[2],
                                                glowColor[3], glowColor[4])
                            glow:Show()
                        end
                    end
                    -- Every marker takes a hit target, so the tooltip is
                    -- ours wherever another addon pins the same rare. Only a
                    -- multi-sighting marker registers spots to reveal: one
                    -- sighting already sits under the marker itself.
                    local button = self.poiButtons[iconIdx]
                    if spotKey and #poi.points > 1 then
                        self.spotPois[spotKey] =
                            { poi = poi, color = spotColor,
                              mark = mark, size = iconSize }
                    end
                    if spotKey and button then
                        PlaceAt(button, self, mark[1], mark[2])
                        button:SetSize(iconSize, iconSize)
                        button.spotKey = spotKey
                        button.labelText = labelText
                        button.spotCount = #poi.points
                        button.spotColor = spotColor
                        button.poiKind   = poi.poiKind
                        button.hintNote  = poi.hintNote
                        button.hintWhere = poi.hintWhere
                        button.poiSubZone = poi.subZone
                        button.hintBoss  = poi.hintBoss
                        button:Show()
                    elseif button then
                        button:Hide()
                    end
                    iconIdx = iconIdx + 1
                end
              end
            end
            if labelText then
                local label = self.poiLabels[labelIdx]
                if label then
                    label:SetText(labelText)
                    local pos    = labelPosFor[poi] or poi.mapLabelPos
                    local corner = LEGEND_CORNERS[pos or ""]
                    local fontFile = label:GetFont()
                    -- Two markers of one kind sharing a name (BWL's pair
                    -- of alchemy workbenches) fold to one legend line.
                    local legendKey = corner
                        and (corner .. "|" .. (poi.poiKind or "") .. "|" .. labelText)
                    local legendFolded = legendKey and legendSeen[legendKey]
                    if legendFolded then
                        label:Hide()
                    elseif corner then
                        legendSeen[legendKey] = true
                        local used = legendCount[corner] or 0
                        legendCount[corner] = used + 1
                        label:SetFont(fontFile, LEGEND_FONT, "OUTLINE")
                        -- The legend icon wears exactly what the map icon
                        -- wears: a rare its palette color, any other kind
                        -- its per-kind tint, so the two never disagree.
                        self:PlaceLegendLabel(label,
                            self.legendIcons[labelIdx], corner, used,
                            (poi.poiKind == "rare") and spotColor
                                or GLOBAL_POI_TINTS[poi.poiKind]
                                or GLOBAL_POI_WHITE,
                            GLOBAL_POI_TEXTURES[poi.poiKind]
                                or GLOBAL_POI_DEFAULT)
                    else
                        label:SetFont(fontFile, GLOBAL_POI_FONT, "OUTLINE")
                        self:PlaceLabel(label, pos, mark[1], mark[2],
                            (poi.poiSize or GLOBAL_POI_SIZE) / 2)
                    end
                    -- A rare's label wears its palette color from the
                    -- start, matching its skull; the pool resets to white
                    -- for everything else.
                    if poi.poiKind == "rare" then
                        label:SetTextColor(spotColor[1], spotColor[2],
                                           spotColor[3], 1)
                    else
                        label:SetTextColor(1, 1, 1, 1)
                    end
                    if legendFolded then
                        -- The pooled label stays hidden and unused.
                    else
                        label:Show()
                        labelIdx = labelIdx + 1
                    end
                end
            end
        end
    end
    for buttonIdx = iconIdx, MAX_GLOBAL_POI do
        local unused = self.poiButtons[buttonIdx]
        if unused then unused:Hide() end
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
        local pts = RR:ResolveSegPoints(seg)
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

-- The RETRORUNS entry in the world map's icon column, through the shared
-- Krowi stack so it lines up under every other addon's button there. The
-- menu mirrors the Settings Map page and jumps to the full canvas.
local function BuildWorldMapButton()
    local KrowiButtons = LibStub
        and LibStub:GetLibrary("Krowi_WorldMapButtons-1.4", true)
    if not KrowiButtons then return end
    local button = KrowiButtons:Add(nil, "DropdownButton")
    -- Above the map canvas. The default strata left the button rendering
    -- behind the map: present, shown, invisible.
    button:SetFrameStrata("HIGH")
    -- Same geometry as the minimap button: the brand art is a FINISHED
    -- button, ring and all, so it fills the frame. Compositing it inside
    -- Blizzard's tracking border drew a ring inside a ring and squeezed
    -- the art into an opening it was never cut for.
    button:SetSize(31, 31)
    local brandIcon = button:CreateTexture(nil, "BACKGROUND")
    brandIcon:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\MinimapIcon")
    brandIcon:SetAllPoints()
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints()
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(RETRO_WORDMARK)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- The Krowi stack calls Refresh on every overlay reflow; the menu is
    -- static, so there is nothing to rebuild.
    function button:Refresh() end
    button:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_WORLD_MAP_RETRORUNS")
        rootDescription:CreateTitle(RETRO_WORDMARK)
        rootDescription:CreateCheckbox(RR.L["Enable Map POIs"],
            function() return RR:GetSetting("mapPois", true) ~= false end,
            function()
                RR:SetSetting("mapPois",
                    not (RR:GetSetting("mapPois", true) ~= false))
                overlay:Refresh()
            end)
        -- The stored setting is SHOW; this entry asks the opposite, so the
        -- tick reads as "hidden" without migrating anyone's saved value.
        local collectedEntry = rootDescription:CreateCheckbox(
            RR.L["Hide fully collected rares from map"],
            function()
                return RR:GetSetting("showCollectedRares", true) == false
            end,
            function()
                RR:SetSetting("showCollectedRares",
                    RR:GetSetting("showCollectedRares", true) == false)
                overlay:Refresh()
            end)
        collectedEntry:SetEnabled(function()
            return RR:GetSetting("mapPois", true) ~= false
        end)
        rootDescription:CreateDivider()
        rootDescription:CreateButton(RR.L["Open Settings"], function()
            if RR.UI and RR.UI.ToggleSettings then RR.UI.ToggleSettings() end
        end)
    end)
end
BuildWorldMapButton()

-- The rings breathe so the sightings catch the eye on busy map art. A
-- ticker drives the alpha by hand -- the toast recipe's lesson, manual
-- driving over AnimationGroups -- and exists only while rings are shown.
local spotPulseTicker
local function SetSpotPulse(active)
    if active and not spotPulseTicker then
        spotPulseTicker = C_Timer.NewTicker(0.05, function()
            local pulseAlpha = 0.6 + 0.35 * math.sin(GetTime() * 4)
            for _, ring in ipairs(overlay.poiSpotRings) do
                if ring:IsShown() then ring:SetAlpha(pulseAlpha) end
            end
        end)
    elseif not active and spotPulseTicker then
        spotPulseTicker:Cancel()
        spotPulseTicker = nil
    end
end

-- Redraws the sighting skulls from hover + pinned state. Cheap enough to
-- run straight from the mouse handlers; Refresh runs it too so pinned
-- skulls come back after a map change.
function overlay:UpdateSpawnSpots()
    for _, spot in ipairs(self.poiSpots)     do spot:Hide() end
    for _, back in ipairs(self.poiSpotBacks) do back:Hide() end
    for _, ring in ipairs(self.poiSpotRings) do ring:Hide() end
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then SetSpotPulse(false) return end
    local spotIdx = 1
    for spotKey, entry in pairs(self.spotPois) do
        if (self.pinnedSpots[spotKey] or self.hoveredSpotKey == spotKey)
            and entry.poi.mapID == mapID then
            -- A sighting under the marker itself draws nothing: the skull
            -- already stands on it, and a second spot there reads as a
            -- stray dot poking out from beneath the icon.
            local mark, half = entry.mark, (entry.size or 0) / 2
            local frameW, frameH = self:GetWidth(), self:GetHeight()
            for _, point in ipairs(entry.poi.points) do
                local underMarker = mark
                    and math.abs((point[1] - mark[1]) * frameW) < half
                    and math.abs((point[2] - mark[2]) * frameH) < half
                if not underMarker then
                local spot = self.poiSpots[spotIdx]
                if not spot then
                    SetSpotPulse(true)
                    return
                end
                local back = self.poiSpotBacks[spotIdx]
                local ring = self.poiSpotRings[spotIdx]
                PlaceAt(back, self, point[1], point[2])
                back:Show()
                -- A sighting wears the marker's own art: a small skull
                -- under a rare, a small chest under a chest. The rare's
                -- palette color ties its spots to it; a chest draws in
                -- its own colors with the pink glow on the ring.
                local kind = entry.poi.poiKind
                local spotColor = entry.color
                spot:SetTexture(GLOBAL_POI_TEXTURES[kind]
                                or GLOBAL_POI_TEXTURES.rare)
                if kind ~= "rare" then
                    spotColor = GLOBAL_POI_TINTS[kind] or GLOBAL_POI_WHITE
                end
                PlaceAt(spot, self, point[1], point[2])
                spot:SetVertexColor(spotColor[1], spotColor[2],
                                    spotColor[3], SPOT_ALPHA)
                spot:Show()
                local ringColor = (kind == "rare") and entry.color
                    or C_POI_GLOW_PINK
                PlaceAt(ring, self, point[1], point[2])
                ring:SetVertexColor(ringColor[1], ringColor[2],
                                    ringColor[3])
                ring:Show()
                spotIdx = spotIdx + 1
                end
            end
        end
    end
    SetSpotPulse(spotIdx > 1)
end

function overlay:Refresh()
    self:HideAll()
    wipe(self.spotPois)
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then return end

    if RR.currentRaid
        and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
        -- Global POIs first (drawn on every step, between steps, and after
        -- the route is complete -- independent of DrawSegmentsForMap's
        -- active-step and route-complete gates), then the step objectives.
        -- The layer's off switch lives on the map-column button and the
        -- Settings Map page.
        if RR:GetSetting("mapPois", true) ~= false then
            self:DrawGlobalPOIsForMap(mapID)
        else
            for _, button in ipairs(self.poiButtons) do button:Hide() end
        end
        self:DrawSegmentsForMap(mapID)
    else
        -- No loaded instance: the hit targets go with the markers.
        for _, button in ipairs(self.poiButtons) do button:Hide() end
    end

    -- Pinned sighting dots come back after every repaint -- Refresh hides
    -- the pool wholesale, and the heartbeat repaints often.
    self:UpdateSpawnSpots()

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

-- Re-tints pulsing labels and breathes the rings (red channel only), both
-- off the panel's shared phase, in one 0.1s ticker.
C_Timer.NewTicker(0.1, function()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    if RR.GetLabelPulseColor then
        local color = RR:GetLabelPulseColor()
        for _, label in ipairs(overlay.labels) do
            if label:IsShown()
                and label.flashState == "pulsing"
                and label.flashBase
            then
                label:SetText(color .. label.flashBase .. "|r")
            end
        end
    end
    if RR.GetRingPulseRed then
        local pulseRed = RR:GetRingPulseRed()
        for _, ring in ipairs(overlay.rings) do
            if ring:IsShown() and not ring.completeState then
                ring:SetVertexColor(pulseRed, 0, 0, 1)
            end
        end
    end
end)
