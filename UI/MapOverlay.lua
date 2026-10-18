-------------------------------------------------------------------------------
-- RetroRuns -- MapOverlay.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- Draws route lines and nav icons on the World Map.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Pool sizes -- sized to handle the largest expected raid routing
-------------------------------------------------------------------------------

local MAX_LINES    = 80
local MAX_ICONS    = 30
local MAX_LABELS   = 30
local MAX_RINGS    = 10
local MAX_CHEVRONS = 200
-- Always-on global POIs (vendors, doors/tunnels, hand-authored markers) draw
-- from their own pool so their indices never collide with the step segments'.
-- One entry per POI: a multi-spawn rare draws a single area rather than a
-- marker per point, so the count is POIs on screen, not spawn points.
local MAX_GLOBAL_POI = 24
local MAX_MARK_HINTS = 24   -- hover targets over a seg's markers

-- Spawn spots: small copies of the rare skull at each recorded sighting,
-- shown while the cursor rests on the marker and kept shown by a click.
-- Each POI takes a palette color by its position in the pois list, so two
-- pinned rares can never share one and a rare keeps its color all
-- session. Nothing is drawn between the sightings, so the map never
-- claims ground the data does not have.
local SPOT_SIZE = 12
local SPOT_ALPHA = 0.95
-- INVARIANT: none of these may be a color the ROUTE draws in: line pink
-- (0.95, 0.35, 0.78), chevrons cyan (0.30, 0.80, 1.00).
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
local BOSS_PIN_SIZE   = 32     -- Blizzard's Encounter Journal boss pin

-- Brand wordmark, for tooltips and the map-column menu: everything this
-- overlay pops up says whose it is.
local RETRO_WORDMARK = "|cffF259C7RETRO|r|cff4DCCFFRUNS|r"
local RETRO_MARK     = "|cffF259C7R|r|cff4DCCFFR|r"

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
overlay.labels   = {}
overlay.rings    = {}
overlay.chevrons = {}
overlay.poiIcons  = {}   -- always-on global-POI markers
overlay.legendIcons = {}  -- skull swatches for corner-legend entries
overlay.poiLabels = {}   -- always-on global-POI labels
overlay.poiSpots     = {}   -- sighting skulls behind a hovered/pinned marker
overlay.markButtons  = {}   -- hover targets over a seg's markers (markHint)
overlay.poiSpotBacks = {}   -- dark discs that lift the skulls off the map art
overlay.poiSpotRings = {}   -- breathing color rings around the skulls
overlay.poiButtons   = {}   -- invisible hit targets over multi-spawn markers
overlay.spotPois     = {}   -- spotKey -> poi, rebuilt each refresh
overlay.pinnedSpots  = {}   -- spotKey -> true while a click holds them on
overlay.poiGlows     = {}   -- brand halo behind a marker that earns one

-- Route line: brand pink (UI.lua's C_PINK), paired with cyan chevrons.
local function MakeLine(parent)
    local ln = parent:CreateLine(nil, "ARTWORK")
    ln:SetThickness(5)
    ln:SetColorTexture(0.95, 0.35, 0.78, 1.0)
    ln:Hide()
    return ln
end

local function MakeIcon(parent)
    local tx = parent:CreateTexture(nil, "ARTWORK")
    tx:SetSize(18, 18)
    tx:Hide()
    return tx
end

local function MakeLabel(parent, fontSize)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetTextColor(1.0, 1.0, 1.0, 1.0)
    RR.SafeSetFont(fs, fs:GetFont(), fontSize or 17, "OUTLINE")
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
-- Its alpha breathes while shown (see UpdateSpawnSpots).
local function MakeSpotRing(parent)
    local tx = parent:CreateTexture(nil, "ARTWORK", nil, -1)
    tx:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\RingCircle")
    tx:SetSize(SPOT_SIZE + 8, SPOT_SIZE + 8)
    tx:Hide()
    return tx
end

-- Each row of `list` that `matches` accepts, with whether its looks are
-- collected: a row carrying several difficulty buckets only counts once every
-- look it offers is owned. Nil while the collection check is unavailable.
local function LootLines(list, matches)
    local lookCollected = RR.UI and RR.UI.IsSourceLookCollected
    if not list or not lookCollected then return nil end
    local rows = {}
    for _, row in ipairs(list) do
        if not matches or matches(row) then
            local seen, have = false, true
            for _, sourceID in pairs(row.sources or {}) do
                seen = true
                if not lookCollected(sourceID) then have = false end
            end
            -- A mount, pet or toy has no look; its own collection check answers.
            if row.kind and RR.SpecialCollectionStateForItem then
                seen = true
                have = RR.SpecialCollectionStateForItem(row) == "collected"
            end
            if seen then
                rows[#rows + 1] = { id = row.id, name = row.name, have = have, item = row }
            end
        end
    end
    return rows
end

-------------------------------------------------------------------------------
-- Map tooltip: the panel's border, and state checks drawn as textures (the
-- panel's gold check for shared).
-------------------------------------------------------------------------------

local MAP_TIP_EDGE    = 14   -- the minimized panel's border thickness
local MAP_TIP_PAD     = 14   -- content inset inside the border
local MAP_TIP_MIN_W   = 200
local MAP_TIP_MAX_W   = 320
local MAP_TIP_CELL    = 12
local MAP_TIP_ROW_GAP = 2
local MAP_TIP_BLANK   = 8
local MAP_TIP_WHITE   = { 1, 1, 1 }
local MAP_TIP_GRAY    = { 0.7, 0.7, 0.7 }

local mapTip

-- Built on first hover.
local function MapTip()
    if mapTip then return mapTip end
    mapTip = CreateFrame("Frame", "RetroRunsMapTip", UIParent, "BackdropTemplate")
    mapTip:SetFrameStrata("TOOLTIP")
    mapTip:SetClampedToScreen(true)
    mapTip:SetBackdrop(RR.UI.PanelBackdrop(MAP_TIP_EDGE))
    mapTip:SetBackdropColor(1, 1, 1, 1)
    mapTip:SetBackdropBorderColor(1, 1, 1, 1)
    mapTip.lines = {}
    mapTip:Hide()
    return mapTip
end

local function MapTipLine(tip, index)
    local line = tip.lines[index]
    if not line then
        line = {
            left  = tip:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall"),
            right = tip:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall"),
            cell  = tip:CreateTexture(nil, "OVERLAY"),
        }
        line.left:SetJustifyH("LEFT")
        line.right:SetJustifyH("RIGHT")
        line.cell:SetSize(MAP_TIP_CELL, MAP_TIP_CELL)
        tip.lines[index] = line
    end
    return line
end

local function MapTipIsOwnedBy(owner)
    return mapTip ~= nil and mapTip:IsShown() and mapTip.owner == owner
end

-- Hides the tooltip; with an owner, only while that owner holds it.
local function HideMapTip(owner)
    if not mapTip or (owner and mapTip.owner ~= owner) then return end
    mapTip:Hide()
    mapTip.owner = nil
end

-- Lays out `rows` and shows them against `owner`, to its right, or to its
-- left with anchorLeft. A row is { text, right, color, header, wrap, cell,
-- indent } or { blank = true }; `wrap` rows do not widen the tooltip.
local function ShowMapTip(owner, rows, anchorLeft)
    local tip = MapTip()
    local contentW = MAP_TIP_MIN_W
    for index, row in ipairs(rows) do
        local line = MapTipLine(tip, index)
        local font = row.header and GameTooltipText or GameTooltipTextSmall
        line.left:SetFontObject(font)
        line.right:SetFontObject(font)
        line.left:SetText(row.text or "")
        line.right:SetText(row.right or "")
        line.textX = (row.indent or 0) + (row.cell and MAP_TIP_CELL + 4 or 0)
        line.rightW = row.right and line.right:GetUnboundedStringWidth() or 0
        if not row.blank and not row.wrap then
            local need = line.textX + line.left:GetUnboundedStringWidth()
                + (line.rightW > 0 and line.rightW + 16 or 0)
            contentW = math.max(contentW, need)
        end
    end
    contentW = math.min(math.ceil(contentW), MAP_TIP_MAX_W)

    local y = -MAP_TIP_PAD
    for index, row in ipairs(rows) do
        local line = tip.lines[index]
        if row.blank then
            line.left:Hide()
            line.right:Hide()
            line.cell:Hide()
            y = y - MAP_TIP_BLANK
        else
            local color = row.color or MAP_TIP_WHITE
            line.left:SetTextColor(color[1], color[2], color[3])
            line.right:SetTextColor(1, 1, 1)
            line.left:SetWidth(contentW - line.textX
                - (line.rightW > 0 and line.rightW + 16 or 0))
            line.left:SetWordWrap(true)
            line.left:ClearAllPoints()
            line.left:SetPoint("TOPLEFT", tip, "TOPLEFT", MAP_TIP_PAD + line.textX, y)
            line.left:Show()
            local height = line.left:GetStringHeight()
            if line.rightW > 0 then
                line.right:ClearAllPoints()
                line.right:SetPoint("TOPRIGHT", tip, "TOPRIGHT", -MAP_TIP_PAD, y)
                line.right:Show()
                height = math.max(height, line.right:GetStringHeight())
            else
                line.right:Hide()
            end
            local spec = row.cell and RR.UI.PROGRESS_CELL_ICON[row.cell]
            if spec then
                local _, fontSize = line.left:GetFont()
                line.cell:SetTexture(spec.file)
                line.cell:SetDesaturated(spec.desaturate and true or false)
                line.cell:SetVertexColor(spec.r or 1, spec.g or 1, spec.b or 1)
                line.cell:ClearAllPoints()
                line.cell:SetPoint("TOPLEFT", tip, "TOPLEFT",
                    MAP_TIP_PAD + (row.indent or 0),
                    y - ((fontSize or MAP_TIP_CELL) - MAP_TIP_CELL) / 2)
                line.cell:Show()
            else
                line.cell:Hide()
            end
            y = y - height - MAP_TIP_ROW_GAP
        end
    end
    for index = #rows + 1, #tip.lines do
        tip.lines[index].left:Hide()
        tip.lines[index].right:Hide()
        tip.lines[index].cell:Hide()
    end

    tip:SetSize(contentW + 2 * MAP_TIP_PAD, MAP_TIP_PAD - y - MAP_TIP_ROW_GAP)
    tip:ClearAllPoints()
    if anchorLeft then
        tip:SetPoint("BOTTOMRIGHT", owner, "TOPLEFT")
    else
        tip:SetPoint("BOTTOMLEFT", owner, "TOPRIGHT")
    end
    tip.owner = owner
    tip:Show()
end

-- An item's link, or its data-row name while the item cache is cold; the
-- tooltip redraws through `redraw` once the item arrives, if still hovered.
local function ItemLineText(itemID, name, owner, redraw)
    local _, link = C_Item.GetItemInfo(itemID)
    if not link and Item and Item.CreateFromItemID then
        local pending = Item:CreateFromItemID(itemID)
        if not pending:IsItemEmpty() then
            pending:ContinueOnItemLoad(function()
                if MapTipIsOwnedBy(owner) and owner:IsMouseOver() then
                    redraw(owner)
                end
            end)
        end
    end
    return link or name or tostring(itemID)
end

-- Loot lines keyed on whatever named the marker: a rare's npc name, or an
-- object's tag (the BRD safe, the Tribute chest).
local function PoiLootLines(key)
    local raid = RR.currentRaid
    if not raid or not key then return nil end
    return LootLines(raid.trashLoot, function(row)
        return row.rareNpc == key or row.tag == key
    end)
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
    if not raid or not raid.bosses or not bossIndex then return nil end
    for _, boss in ipairs(raid.bosses) do
        if boss.index == bossIndex then return LootLines(boss.loot) end
    end
    return nil
end

-- Tooltip for a marker hit target. Split from OnEnter so a click can
-- refresh the pin hint without re-arming the hover preview. The brand
-- mark rides the title line's right edge, saying whose popup this is
-- without spending a line on it.
local function ShowSpotTooltip(btn)
    local rows = { { text = btn.labelText or "", right = RETRO_MARK, header = true } }
    local tint  = btn.spotColor or SPOT_PALETTE[1]
    local count = btn.spotCount or 0
    -- Sightings are a RARE's story. A vendor or a chest does not spawn, so
    -- the line would read as nonsense on the 24 markers that are neither.
    if btn.poiKind == "rare" then
        rows[#rows + 1] = { color = tint, text = count == 1
            and RR.L["1 recorded spawn point"]
            or (RR.L["%d recorded spawn points"]):format(count) }
    end
    -- One sighting is already where the marker sits, so there is nothing a
    -- click could reveal; the hint would promise a behavior we do not have.
    if count > 1 then
        rows[#rows + 1] = { color = MAP_TIP_GRAY, text = overlay.pinnedSpots[btn.spotKey]
            and RR.L["Click to hide them"]
            or RR.L["Click to keep them shown"] }
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
        rows[#rows + 1] = { text = HighlightCarets(RR.L[btn.hintNote]), wrap = true }
    end
    if btn.hintWhere then
        local here = (GetSubZoneText and GetSubZoneText()) or ""
        if not btn.poiSubZone or btn.poiSubZone ~= here then
            rows[#rows + 1] = { text = HighlightCarets(RR.L[btn.hintWhere]), wrap = true }
        end
    end
    -- A marker's own drops first; an object that only GATES a boss shows
    -- that boss's looks instead, so both read the same way.
    local loot = PoiLootLines(btn.spotKey)
    if (not loot or #loot == 0) and btn.hintBoss then
        loot = BossLootLines(btn.hintBoss)
    end
    if loot and #loot > 0 then
        rows[#rows + 1] = { blank = true }
        local summaryState = RR.UI and RR.UI.ItemSummaryState
        for _, row in ipairs(loot) do
            local state = (not row.item.kind and summaryState
                    and summaryState(row.item))
                or (row.have and "collected" or "missing")
            rows[#rows + 1] = { cell = state,
                text = ItemLineText(row.id, row.name, btn, ShowSpotTooltip) }
        end
    end
    ShowMapTip(btn, rows)
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
        HideMapTip(self)
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

-- Tooltip for a route marker that carries a hint: the seg's line with the
-- live count filled in. A widget that is not up reads as nothing killed.
local function ShowMarkTooltip(btn)
    local seg = btn.hintSeg
    if not seg or not seg.markHint then return end
    local total = seg.markHintTotal or 0
    local remaining = RR.ReadWidgetNumber and RR:ReadWidgetNumber(seg.markHintWidget)
    if remaining == nil then remaining = total end
    -- The counter can vanish once it has landed; the open gate says so.
    if RR.StepWidgetGateOpen and RR:StepWidgetGateOpen(RR.state.activeStep) then
        remaining = 0
    end
    ShowMapTip(btn, { { text = (RR.L[seg.markHint]):format(remaining, total),
        right = RETRO_MARK, header = true } })
end

-- Invisible hit target over a route marker. Hover only; nothing to click.
local function MakeMarkButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:Hide()
    btn:SetScript("OnEnter", function(self) ShowMarkTooltip(self) end)
    btn:SetScript("OnLeave", function(self) HideMapTip(self) end)
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
for i = 1, MAX_MARK_HINTS  do overlay.markButtons[i]  = MakeMarkButton(overlay) end
for i = 1, MAX_GLOBAL_POI do overlay.poiGlows[i]     = MakePoiGlow(overlay)  end

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function PlaceAt(el, parent, nx, ny)
    el:ClearAllPoints()
    el:SetPoint("CENTER", parent, "TOPLEFT",
        nx * parent:GetWidth(), -ny * parent:GetHeight())
end

-- Hides a pool's widgets from index `first` on (the whole pool by default).
local function HideFrom(pool, first)
    for index = first or 1, #pool do pool[index]:Hide() end
end

-- Settles breaths after a repaint: kept running on each pooled widget still
-- shown that `breathes` accepts, stopped on the rest.
local function SettleBreaths(pool, lowAlpha, breathes)
    for _, region in ipairs(pool) do
        RR.UI.SetBreathing(region,
            region:IsShown() and (not breathes or breathes(region)) or false,
            lowAlpha)
    end
end

-------------------------------------------------------------------------------
-- End marker at `dest`: the triangle, aimed along the polyline's last leg,
-- or for a seg with endpointKind "skull" the raid-target skull, unrotated --
-- a die-here shortcut (Antorus's elevator hole, Tomb's Tears of Elune jump).
-------------------------------------------------------------------------------

local function PlaceEndMarker(self, icon, pts, dest, W, H, endpointKind)
    local skull = endpointKind == "skull"
    icon:SetTexture(skull and "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
        or "Interface\\AddOns\\RetroRuns\\Media\\Icons\\EndTriangle")
    -- White tint is a no-op, so the art renders in its own colors.
    icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
    icon:SetSize(24, 24)
    icon:SetDrawLayer("OVERLAY")
    PlaceAt(icon, self, dest[1], dest[2])
    local rotation = 0
    local prev = not skull and pts and #pts >= 2 and pts[#pts - 1]
    if prev then
        local dx, dy = (dest[1] - prev[1]) * W, (dest[2] - prev[2]) * H
        if dx ~= 0 or dy ~= 0 then rotation = math.atan2(dx, dy) end
    end
    icon:SetRotation(rotation)
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

    -- Short paths skip chevrons: the start dot and end marker already show
    -- the direction.
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
    -- poiButtons and markButtons stay out: hiding one mid-click cancels the
    -- click. The draw loops and Refresh hide the unused ones.
    for _, pool in ipairs({ self.lines, self.icons, self.chevrons,
        self.poiIcons, self.legendIcons, self.poiLabels, self.poiSpots,
        self.poiSpotBacks, self.poiSpotRings, self.poiGlows }) do
        HideFrom(pool)
    end
    -- A recycled label must not keep pulsing on a seg that does not pulse.
    for _, label in ipairs(self.labels) do
        label:Hide()
        label.flashState = nil
    end
    -- A recycled ring must not stay gray on a seg that is not complete.
    for _, ring in ipairs(self.rings) do
        ring:Hide()
        ring.completeState = nil
    end
end

-- Is this seg already behind the step's progress?
local function SegIsComplete(step, seg)
    if not step or not step.segments then return false end
    for i, candidate in ipairs(step.segments) do
        if candidate == seg then
            local stepIndex = step.step or step.priority or 0
            if i < RR:GetProgress(stepIndex) then return true end
            -- A gate that fired is complete even while progress still sits
            -- ON it, but only for a triggered poi that is its step's LAST
            -- segment: progress cannot move past the end, so the strict
            -- comparison alone would never tick it. Anywhere else the gate
            -- is what OPENS the seg, and the seg completes when the route
            -- moves past it.
            return i == #step.segments
                and candidate.triggeredBy ~= nil
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
    icon:SetTexture(texture)
    icon:SetTexCoord(0, 1, 0, 1)
    icon:SetSize(LEGEND_ICON, LEGEND_ICON)
    icon:SetVertexColor(tint[1], tint[2], tint[3], 1)
    icon:ClearAllPoints()
    icon:SetPoint(corner, self, corner, dx, dy)
    icon:Show()
    label:SetPoint(right and "RIGHT" or "LEFT", icon,
                   right and "LEFT" or "RIGHT", right and -6 or 6, 0)
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
    -- Where a pet comes from (Zul'Aman's frogs).
    pet       = "Interface\\Icons\\INV_Frog2_Teal",
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
    if not raid or not raid.pois then
        -- Hit buttons left over from another instance's POIs must not stay hoverable.
        HideFrom(self.poiButtons)
        return
    end
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
        -- A marker for one route draws only while that route is chosen.
        if poi.routeVariant and poi.routeVariant ~= RR:ActiveVariantKey() then
            return false
        end
        return true
    end
    -- With the setting off, a marker whose own drops (the rows its hover
    -- lists) are all collected stops drawing. A marker with none always draws.
    local showCollectedRares =
        RR:GetSetting("showCollectedRares", true) ~= false
    local function MarkerStillWanted(poi)
        if showCollectedRares then return true end
        local key = poi.rareNpc or poi.tag or poi.mapLabel
        if not key then return true end
        local lines = LootLines(raid.trashLoot, function(row)
            return row.rareNpc == key or row.tag == key
        end)
        if not lines or #lines == 0 then return true end
        for _, line in ipairs(lines) do
            if not line.have then return true end
        end
        return false
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
    local markFor, labelPosFor, drawList, poiIndexFor = {}, {}, {}, {}
    for poiIndex, poi in ipairs(raid.pois) do
        if poi.mapID == mapID and poi.points and #poi.points > 0
            and BelongsToPlayer(poi) and MarkerStillWanted(poi) then
            poiIndexFor[poi] = poiIndex
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
    -- Blizzard's boss pins stay where they are; a marker under one moves
    -- just clear of it (Dire Maul's Broken Trap beside Guard Slip'kik).
    local bossPins = C_EncounterJournal and C_EncounterJournal.GetEncountersOnMap
        and C_EncounterJournal.GetEncountersOnMap(mapID)
    local pinGapX = (BOSS_PIN_SIZE / 2 + GLOBAL_POI_SIZE / 2 + 2) / mapW
    local pinGapY = (BOSS_PIN_SIZE / 2 + GLOBAL_POI_SIZE / 2 + 2) / mapH
    for _, bossPin in ipairs(type(bossPins) == "table" and bossPins or {}) do
        local pinX, pinY = bossPin.mapX, bossPin.mapY
        if type(pinX) == "number" and type(pinY) == "number" then
            for _, poi in ipairs(drawList) do
                local mark = markFor[poi]
                local dx = (mark[1] - pinX) / pinGapX
                local dy = (mark[2] - pinY) / pinGapY
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < 1 then
                    if dist < 0.05 then dx, dy, dist = 0, 1, 1 end
                    mark[1] = pinX + dx / dist * pinGapX
                    mark[2] = pinY + dy / dist * pinGapY
                end
            end
        end
    end
    local iconIdx, labelIdx = 1, 1
    for _, poi in ipairs(drawList) do
        if iconIdx > MAX_GLOBAL_POI then break end
        -- One marker per POI, placed by its navPoint or centered on its
        -- sightings, after the separation pass.
        local mark = markFor[poi]
        -- The label, composed before the marker so its tooltip can reuse it.
        local labelText
        if poi.mapLabel then
            labelText = RR.L[poi.mapLabel]
        elseif poi.rareNpc then
            labelText = RR.L["%s (Rare)"]:format(RR.L[poi.rareNpc])
        elseif poi.tag then
            labelText = RR.L[poi.tag]
        end
        local spotKey = poi.rareNpc or poi.tag or poi.mapLabel
        local spotColor = SPOT_PALETTE[(poiIndexFor[poi] - 1) % #SPOT_PALETTE + 1]
        -- A rare wears its palette color, as its label, sightings, tooltip and
        -- legend swatch do; other kinds keep their per-kind tint.
        local kindTint = (poi.poiKind == "rare" and spotColor)
            or GLOBAL_POI_TINTS[poi.poiKind] or GLOBAL_POI_WHITE
        local texture = GLOBAL_POI_TEXTURES[poi.poiKind] or GLOBAL_POI_DEFAULT
        if not poi.noMarker then
            local icon = self.poiIcons[iconIdx]
            PlaceAt(icon, self, mark[1], mark[2])
            -- Class-tagged markers wear that class's icon in its own colors.
            -- The pool is shared, so the plain branch clears the crop.
            local classCoords = poi.class and CLASS_ICON_TCOORDS
                and CLASS_ICON_TCOORDS[playerClassToken]
            if classCoords then
                icon:SetTexture(CLASS_ICON_SHEET)
                icon:SetTexCoord(classCoords[1], classCoords[2],
                                 classCoords[3], classCoords[4])
            else
                icon:SetTexture(texture)
                icon:SetTexCoord(0, 1, 0, 1)
            end
            local tint = classCoords and GLOBAL_POI_WHITE or kindTint
            icon:SetVertexColor(tint[1], tint[2], tint[3], 1)
            icon:SetRotation(0)
            -- Drawn above the route's lines, dots, chevrons and end markers.
            icon:SetDrawLayer("OVERLAY", 2)
            local iconSize = poi.poiSize or GLOBAL_POI_SIZE
            icon:SetSize(iconSize, iconSize)
            icon:Show()
            local glowColor = GLOWING_POI_KINDS[poi.poiKind]
            if glowColor then
                -- Same pool index as the marker it sits behind, so the two
                -- can never drift apart.
                local glow = self.poiGlows[iconIdx]
                PlaceAt(glow, self, mark[1], mark[2])
                glow:SetSize(iconSize * POI_GLOW_SCALE, iconSize * POI_GLOW_SCALE)
                glow:SetVertexColor(glowColor[1], glowColor[2],
                                    glowColor[3], glowColor[4])
                glow:Show()
            end
            -- Every marker takes a hit target; only a multi-sighting marker
            -- registers spots to reveal.
            local button = self.poiButtons[iconIdx]
            if spotKey and #poi.points > 1 then
                self.spotPois[spotKey] =
                    { poi = poi, color = spotColor, mark = mark, size = iconSize }
            end
            if spotKey then
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
            else
                button:Hide()
            end
            iconIdx = iconIdx + 1
        end
        if labelText then
            local label = self.poiLabels[labelIdx]
            if label then
                label:SetText(labelText)
                local pos    = labelPosFor[poi] or poi.mapLabelPos
                local corner = LEGEND_CORNERS[pos or ""]
                local fontFile = label:GetFont()
                -- Two markers of one kind sharing a name (BWL's pair of
                -- alchemy workbenches) fold to one legend line.
                local legendKey = corner
                    and (corner .. "|" .. (poi.poiKind or "") .. "|" .. labelText)
                local legendFolded = legendKey and legendSeen[legendKey]
                if legendFolded then
                    label:Hide()
                elseif corner then
                    legendSeen[legendKey] = true
                    local used = legendCount[corner] or 0
                    legendCount[corner] = used + 1
                    RR.SafeSetFont(label, fontFile, LEGEND_FONT, "OUTLINE")
                    self:PlaceLegendLabel(label, self.legendIcons[labelIdx],
                        corner, used, kindTint, texture)
                else
                    RR.SafeSetFont(label, fontFile, GLOBAL_POI_FONT, "OUTLINE")
                    self:PlaceLabel(label, pos, mark[1], mark[2],
                        (poi.poiSize or GLOBAL_POI_SIZE) / 2)
                end
                -- A rare's label wears its palette color, matching its
                -- skull; the pool resets to white for everything else.
                if poi.poiKind == "rare" then
                    label:SetTextColor(spotColor[1], spotColor[2], spotColor[3], 1)
                else
                    label:SetTextColor(1, 1, 1, 1)
                end
                -- A folded label stays hidden and its pool slot unused.
                if not legendFolded then
                    label:Show()
                    labelIdx = labelIdx + 1
                end
            end
        end
    end
    HideFrom(self.poiButtons, iconIdx)
end

-- A leg is a noted segment and the noteless ones after it, which take their
-- text from it. True when segIndex belongs to the leg holding `progress`.
local function SegInCurrentLeg(segments, progress, segIndex)
    local legStart = progress
    while legStart > 1 and segments[legStart] and not segments[legStart].note do
        legStart = legStart - 1
    end
    local legEnd = legStart
    while segments[legEnd + 1] and not segments[legEnd + 1].note do
        legEnd = legEnd + 1
    end
    return segIndex >= legStart and segIndex <= legEnd
end

function overlay:DrawSegmentsForMap(mapID)
    -- A completed route draws nothing.
    if RR.IsActiveRouteComplete and RR:IsActiveRouteComplete() then return end

    local step = RR.state.activeStep
    if not step then return end

    local segments = RR:PickLineSegs(step, mapID) or {}

    local W, H      = self:GetWidth(), self:GetHeight()
    local lineIdx    = 1
    local iconIdx    = 1
    local labelIdx   = 1
    local ringIdx    = 1
    local chevronIdx = 1

    -- Marks that stand for a counter dim once the counter has landed.
    local counterLanded = RR.StepWidgetGateOpen and RR:StepWidgetGateOpen(step)
    local stepIndex = step.step or step.priority or 0

    for segIndex, seg in ipairs(step.segments) do
        local pts = RR:ResolveSegPoints(seg)
        -- A seg that waits for its gate draws nothing until the gate is
        -- open; the segments list already holds only this map's segs.
        local drawn = false
        for _, candidate in ipairs(segments) do
            if candidate == seg then drawn = true break end
        end
        if drawn and seg.drawWhenOpen
            and not RR:IsSegGateOpen(stepIndex, seg, segIndex, step.segments) then
            drawn = false
        end
        -- A step drawn one leg at a time shows only the leg the route is on.
        if drawn and step.drawCurrentSegOnly
            and not SegInCurrentLeg(step.segments, RR:GetProgress(stepIndex), segIndex) then
            drawn = false
        end
        if drawn and pts and #pts > 0 then

            -- A "go here" pin rather than a path. noMarker suppresses even
            -- the marker, leaving a note-only seg. markAllPoints puts a
            -- marker on every point instead of the last one only -- several
            -- objects to find in any order -- with one label on the mark
            -- nearest the middle of the set.
            if seg.kind == "poi" then
                local marks
                if seg.markAllPoints then
                    marks = pts
                else
                    marks = { seg.navPoint or pts[#pts] }
                end
                if not seg.noMarker then
                    for _, mark in ipairs(marks) do
                        local poiIcon = self.icons[iconIdx]
                        if not poiIcon then break end
                        PlaceAt(poiIcon, self, mark[1], mark[2])
                        -- The raid-target star unless the seg names its own.
                        poiIcon:SetTexture(seg.poiIcon
                            or "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
                        if seg.markHintWidget and counterLanded then
                            poiIcon:SetVertexColor(0.45, 0.45, 0.45, 0.7)
                        else
                            poiIcon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
                        end
                        -- Pooled icons carry state over from a previous use.
                        poiIcon:SetRotation(0)
                        poiIcon:SetDrawLayer("ARTWORK")
                        -- 35 suits a sub-zone map; world-scale maps override it.
                        local size = seg.poiSize or 35
                        poiIcon:SetSize(size, size)
                        poiIcon:Show()
                        iconIdx = iconIdx + 1
                        -- A hinted mark takes a hover target. The buttons
                        -- are re-placed rather than hidden and re-shown, so
                        -- the once-a-second redraw does not blink a tooltip
                        -- the cursor is already on.
                        if seg.markHint then
                            local used = (self.markButtonsUsed or 0) + 1
                            local hit = self.markButtons[used]
                            if hit then
                                PlaceAt(hit, self, mark[1], mark[2])
                                hit:SetSize(size, size)
                                hit.hintSeg = seg
                                hit:Show()
                                self.markButtonsUsed = used
                            end
                        end
                    end
                end

                -- mapLabelPos: above/below/left/right, the four diagonals, or
                -- middle. Default below.
                if seg.mapLabel then
                    local label = self.labels[labelIdx]
                    if label then
                        local labelX, labelY = marks[1][1], marks[1][2]
                        if #marks > 1 then
                            local sumX, sumY = 0, 0
                            for _, mark in ipairs(marks) do
                                sumX, sumY = sumX + mark[1], sumY + mark[2]
                            end
                            local midX, midY = sumX / #marks, sumY / #marks
                            local nearest
                            for _, mark in ipairs(marks) do
                                local dx, dy = mark[1] - midX, mark[2] - midY
                                local distance = dx * dx + dy * dy
                                if not nearest or distance < nearest then
                                    nearest = distance
                                    labelX, labelY = mark[1], mark[2]
                                end
                            end
                        end
                        local poiHalf = (seg.poiSize or 35) / 2
                        self:PlaceLabel(label, seg.mapLabelPos, labelX, labelY, poiHalf)

                        -- completionCheck pulses until the seg is done, then
                        -- grays with a check; mapLabelPulse pulses forever.
                        local labelText = RR.L[seg.mapLabel]
                        if seg.completionCheck and SegIsComplete(step, seg) then
                            label:SetText("|cff9d9d9d" .. labelText
                                .. "|r |TInterface\\RaidFrame\\ReadyCheck-Ready:14|t")
                        elseif seg.completionCheck or seg.mapLabelPulse then
                            -- Breathes (SettleBreaths, after the draw).
                            label:SetText(labelText)
                            label.flashState = "pulsing"
                        else
                            label:SetText(labelText)
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
                startIcon:SetTexture("Interface\\MINIMAP\\TempleofKotmogu_ball_cyan")
                startIcon:SetVertexColor(0.2, 1.0, 1.0, 1.0)
                startIcon:SetSize(14, 14)
                -- Pooled icons carry rotation and layer over from a previous use.
                startIcon:SetRotation(0)
                startIcon:SetDrawLayer("ARTWORK")
                startIcon:Show()
                iconIdx = iconIdx + 1
            end

            for i = 2, #pts do
                local ln = self.lines[lineIdx]
                if ln then
                    local p, c = pts[i-1], pts[i]
                    ln:SetStartPoint("TOPLEFT", p[1] * W, -p[2] * H)
                    ln:SetEndPoint  ("TOPLEFT", c[1] * W, -c[2] * H)
                    ln:Show()
                    lineIdx = lineIdx + 1
                end
            end

            -- Direction-of-travel chevrons along the polyline.
            chevronIdx = chevronIdx +
                PlaceChevronsAlongPath(self, pts, W, H, chevronIdx)

            -- End marker at the seg's destination. A teleport seg gets one
            -- too; the World Map draws teleporters natively.
            local dest    = seg.navPoint or pts[#pts]
            local endIcon = self.icons[iconIdx]
            if endIcon then
                PlaceEndMarker(self, endIcon, pts, dest, W, H, seg.endpointKind)
                endIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Optional map label, placed off the 24px end marker (half = 12).
            -- Takes the same seg.mapLabelPos values as the POI branch above.
            if seg.mapLabel then
                local label = self.labels[labelIdx]
                if label then
                    self:PlaceLabel(label, seg.mapLabelPos, dest[1], dest[2], 12)
                    label:SetText(RR.L[seg.mapLabel])
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
                    -- A done seg's ring goes gray and holds still; the rest
                    -- breathe red (SettleBreaths, after the draw).
                    if seg.completionCheck and SegIsComplete(step, seg) then
                        ring.completeState = true
                        ring:SetVertexColor(0.61, 0.61, 0.61, 1)
                    else
                        ring.completeState = nil
                        ring:SetVertexColor(1.0, 0.0, 0.0, 1.0)
                    end
                    ring:Show()
                    ringIdx = ringIdx + 1
                end
            end
        end
    end

    -- The game's own area markers on this map (the Culling's wave flags),
    -- ringed while the current seg asks for it. Read fresh every refresh,
    -- so a ring goes with the flag it sat on.
    local currentSeg = RR.PickNoteSeg and RR:PickNoteSeg(step, mapID)
    if currentSeg and currentSeg.ringAreaPOIs
        and C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIForMap then
        for _, areaPoiID in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(mapID) or {}) do
            local ring = self.rings[ringIdx]
            if not ring then break end
            local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
            local position = info and info.position
            if position and position.GetXY then
                local x, y = position:GetXY()
                if x and y then
                    PlaceAt(ring, self, x, y)
                    ring.completeState = nil
                    ring:SetVertexColor(1.0, 0.0, 0.0, 1.0)
                    ring:Show()
                    ringIdx = ringIdx + 1
                end
            end
        end
    end

    -- On a route that leaves bosses alive, each one still standing gets a
    -- pulsing red ring and "Do Not Kill" at its journal pin.
    local raid = RR.currentRaid
    if raid and raid.skipRouteLeaveAlive and RR:ActiveVariantKey() == "skip"
        and C_EncounterJournal and C_EncounterJournal.GetEncountersOnMap then
        local pinByEncounter = {}
        for _, pin in ipairs(C_EncounterJournal.GetEncountersOnMap(mapID) or {}) do
            pinByEncounter[pin.encounterID] = pin
        end
        for _, bossIndex in ipairs(raid.skipRouteLeaveAlive) do
            local boss = RR:GetBossByIndex(bossIndex)
            local pin = boss and pinByEncounter[boss.journalEncounterID]
            if pin and type(pin.mapX) == "number" and not RR:IsBossKilled(bossIndex) then
                local ring = self.rings[ringIdx]
                if not ring then break end
                PlaceAt(ring, self, pin.mapX, pin.mapY)
                ring.completeState = nil
                ring:SetVertexColor(1.0, 0.0, 0.0, 1.0)
                ring:Show()
                ringIdx = ringIdx + 1
                local label = self.labels[labelIdx]
                if label then
                    local labelPos = raid.skipRouteLeaveAliveLabelPos
                        and raid.skipRouteLeaveAliveLabelPos[bossIndex] or "below"
                    self:PlaceLabel(label, labelPos, pin.mapX, pin.mapY, BOSS_PIN_SIZE / 2)
                    label:SetText("|cffff3333" .. RR.L["Do Not Kill"] .. "|r")
                    label.flashState = nil
                    label:Show()
                    labelIdx = labelIdx + 1
                end
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
            RR.L["Hide fully collected POIs from map"],
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
        local bossIconsEntry = rootDescription:CreateCheckbox(RR.L["Enhanced Boss Icons"],
            function() return RR:GetSetting("enhancedBossIcons", true) ~= false end,
            function()
                RR:SetSetting("enhancedBossIcons",
                    not (RR:GetSetting("enhancedBossIcons", true) ~= false))
            end)
        bossIconsEntry:SetTooltip(function(tooltip)
            GameTooltip_SetTitle(tooltip, RR.L["Enhanced Boss Icons"])
            GameTooltip_AddNormalLine(tooltip, RR.L["When hovering a boss icon, you will see the collection status for each item the boss drops"])
        end)
        rootDescription:CreateDivider()
        rootDescription:CreateButton(RR.L["Open Settings"], function()
            if RR.UI and RR.UI.ToggleSettings then RR.UI.ToggleSettings() end
        end)
    end)
end
BuildWorldMapButton()

-- Redraws the sighting skulls from hover + pinned state. Cheap enough to
-- run straight from the mouse handlers; Refresh runs it too so pinned
-- skulls come back after a map change. The rings around them breathe so the
-- sightings catch the eye on busy map art.
function overlay:UpdateSpawnSpots()
    HideFrom(self.poiSpots)
    HideFrom(self.poiSpotBacks)
    HideFrom(self.poiSpotRings)
    self:DrawSpawnSpots()
    SettleBreaths(self.poiSpotRings, 0.25)
end

function overlay:DrawSpawnSpots()
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then return end
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
                if not spot then return end
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
end

-- The objective rings breathe red until their seg is done; pulsing labels
-- breathe with them.
local function RingBreathes(ring) return not ring.completeState end
local function LabelBreathes(label) return label.flashState == "pulsing" end

function overlay:Refresh()
    self:HideAll()
    wipe(self.spotPois)
    self.markButtonsUsed = 0
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then
        HideFrom(self.markButtons)
        SettleBreaths(self.rings, 0.55, RingBreathes)
        SettleBreaths(self.labels, 0.6, LabelBreathes)
        return
    end

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
            HideFrom(self.poiButtons)
        end
        self:DrawSegmentsForMap(mapID)
    else
        -- No loaded instance: the hit targets go with the markers.
        HideFrom(self.poiButtons)
    end
    -- Mark hover targets past the ones this draw placed go away.
    HideFrom(self.markButtons, self.markButtonsUsed + 1)
    SettleBreaths(self.rings, 0.55, RingBreathes)
    SettleBreaths(self.labels, 0.6, LabelBreathes)

    -- Pinned sighting dots come back after every repaint -- Refresh hides
    -- the pool wholesale, and the heartbeat repaints often.
    self:UpdateSpawnSpots()
end

-------------------------------------------------------------------------------
-- Blizzard's journal boss pins. With Enhanced Boss Icons on, a boss of the
-- current instance shows the map tooltip in place of Blizzard's, with its
-- transmog and special loot added.
-------------------------------------------------------------------------------

local BOSS_TIP_LOOK_CAP = 15
local LOOK_STATE_RANK = { missing = 1, shared = 2, collected = 3 }

local function BossForEncounter(encounterID)
    local raid = RR.currentRaid
    if not raid or not raid.bosses or not encounterID then return nil end
    for _, boss in ipairs(raid.bosses) do
        if boss.journalEncounterID == encounterID then return boss end
    end
    return nil
end

local function ShowBossPinTooltip(pin)
    if RR:GetSetting("enhancedBossIcons", true) == false then return end
    local boss = BossForEncounter(pin.encounterID)
    if not boss or not pin.tooltipTitle then return end
    if GameTooltip:IsOwned(pin) then GameTooltip:Hide() end

    -- Blizzard's own lines first, as their tooltip draws them.
    local rows = { { text = pin.tooltipTitle, header = true } }
    if C_EncounterJournal.IsEncounterComplete(pin.encounterID) then
        rows[#rows + 1] = { text = DUNGEON_ENCOUNTER_DEFEATED,
            color = { RED_FONT_COLOR:GetRGB() } }
    end
    if pin.tooltipText and pin.tooltipText ~= "" then
        rows[#rows + 1] = { text = pin.tooltipText, wrap = true,
            color = { NORMAL_FONT_COLOR:GetRGB() } }
    end

    -- The looks the panel counts, missing first, then shared, then collected.
    local looks = {}
    local needed, shared = 0, 0
    RR.UI.ForEachBossLook(boss, function(item, state)
        looks[#looks + 1] = { item = item, state = state, order = #looks + 1 }
        if state == "missing" then
            needed = needed + 1
        elseif state == "shared" then
            shared = shared + 1
        end
    end)
    if #looks > 0 then
        table.sort(looks, function(a, b)
            local rankA = LOOK_STATE_RANK[a.state] or 3
            local rankB = LOOK_STATE_RANK[b.state] or 3
            if rankA ~= rankB then return rankA < rankB end
            return a.order < b.order
        end)
        rows[#rows + 1] = { blank = true }
        rows[#rows + 1] = { text = RETRO_WORDMARK, right =
            (RR.L["Missing"] .. " (%d) " .. RR.L["Shared"] .. " (%d)"):format(needed, shared) }
        for index = 1, math.min(#looks, BOSS_TIP_LOOK_CAP) do
            local look = looks[index]
            rows[#rows + 1] = { cell = look.state, text = ItemLineText(look.item.id,
                look.item.name, pin, ShowBossPinTooltip) }
        end
        if #looks > BOSS_TIP_LOOK_CAP then
            rows[#rows + 1] = { color = MAP_TIP_GRAY, text =
                (RR.L["+%d more in the transmog browser"]):format(#looks - BOSS_TIP_LOOK_CAP) }
        end
    end

    -- Special loot as the panel lists it.
    local header, lines = RR.UI.BuildSpecialLootSection(boss)
    if header and lines then
        rows[#rows + 1] = { blank = true }
        rows[#rows + 1] = { text = header }
        for _, line in ipairs(lines) do
            rows[#rows + 1] = { text = line.text, wrap = line.noCell,
                cell = not line.noCell and line.cell or nil,
                indent = (line.indentSpaces or 0) * 3 }
        end
    end
    ShowMapTip(pin, rows, true)
end

-- Each pooled boss pin is hooked once, after the provider places it.
local hookedBossPins = {}
local function HookBossPins()
    for pin in WorldMapFrame:EnumeratePinsByTemplate("EncounterJournalPinTemplate") do
        if not hookedBossPins[pin] then
            hookedBossPins[pin] = true
            pin:HookScript("OnEnter", ShowBossPinTooltip)
            pin:HookScript("OnLeave", HideMapTip)
        end
    end
end

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

WorldMapFrame:HookScript("OnHide", function() HideMapTip() end)

-- The journal's map provider, found by a method only it carries.
local journalMixin = EncounterJournalDataProviderMixin
if journalMixin and journalMixin.CheckForContentTracking
    and WorldMapFrame.dataProviders then
    for provider in pairs(WorldMapFrame.dataProviders) do
        if provider.CheckForContentTracking == journalMixin.CheckForContentTracking then
            hooksecurefunc(provider, "RefreshAllData", HookBossPins)
        end
    end
end

C_Timer.NewTicker(1.0, function()
    if WorldMapFrame and WorldMapFrame:IsShown() then
        overlay:Refresh()
    end
end)
