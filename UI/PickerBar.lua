-------------------------------------------------------------------------------
-- RetroRuns -- PickerBar.lua
-- Copyright (c) 2026 Chris Trost (Photek). All rights reserved. See LICENSE.
-- The Picker's bar: the difficulties of the entrance the player stands at,
-- each with its lockout and missing appearances, one click to switch.
-------------------------------------------------------------------------------

local RR = RetroRuns
local UI = RR.UI
local Picker = RR.Picker

local CYAN  = { 0.30, 0.80, 1.00 }
local PINK  = { 0.95, 0.35, 0.78 }
local LABEL = { 1.00, 1.00, 1.00 }
local DIM   = { 0.45, 0.45, 0.45 }
local GREEN_HEX, ORANGE_HEX, GRAY_HEX = "00ff00", "ff9333", "888888"
local LOCK_TEXTURE = "Interface\\PetBattles\\PetBattle-LockIcon"
-- The lock's bounds inside its 32x32 texture, and its width over height.
local LOCK_COORDS = { 5 / 32, 27 / 32, 2 / 32, 29 / 32 }
local LOCK_ASPECT = 22 / 27
local LOCK_HEIGHT = 12
local SELECT_SOUND = "Interface\\AddOns\\RetroRuns\\Media\\Sounds\\picker-select.ogg"

local TITLE_SIZE  = 16
local BUTTON_SIZE = 14
local LINE_SIZE   = 12

-- The art: three atlases, drawn at ART_SCALE atlas pixels per UI unit, or
-- larger when a taller font needs the room (artScale, set by each render).
local ART_SCALE = 3.5
local artScale = ART_SCALE
-- Text clear of the art's inner edges, and of the crest's point, in UI units.
local TEXT_MARGIN, CREST_MARGIN = 2, 1
-- The share of the screen's width the live bar may take before it shrinks.
local SCREEN_FIT = 0.96
-- The live bar's size while two or more entrances stack.
local STACK_SCALE = 0.85
local ART_PATH = "Interface\\AddOns\\RetroRuns\\Media\\Picker\\"
local ATLAS = {
    bar   = { file = ART_PATH .. "picker-bar",   width = 512,  height = 256 },
    tabs  = { file = ART_PATH .. "picker-tabs",  width = 1024, height = 256 },
    plate = { file = ART_PATH .. "picker-plate", width = 1024, height = 256 },
}
-- Each piece: its atlas, then x, y, width and height in atlas pixels.
local PIECES = {
    barCap    = { "bar", 0, 0, 203, 249 },
    barBand   = { "bar", 208, 0, 256, 249 },
    plainEnd  = { "tabs", 0, 0, 66, 170 },
    plainBand = { "tabs", 70, 0, 340, 170 },
    selEnd    = { "tabs", 414, 0, 70, 210 },
    selBand   = { "tabs", 488, 0, 370, 210 },
    gem       = { "tabs", 862, 0, 97, 76 },
    plateWing = { "plate", 0, 0, 365, 175 },
    plateBand = { "plate", 369, 0, 256, 175 },
    plateBeam = { "plate", 629, 0, 289, 30 },
    crest     = { "plate", 629, 34, 365, 143 },
}
-- Placement, in atlas pixels, measured on the art.
local LAYOUT = {
    crestAbove   = 118,  -- the crest's top above the plate's
    plateToBar   = 9,
    plateTextY   = 87,   -- the plate's text center below its top
    plateTextRoom = 135, -- the plate's inner height around that center
    plateTextFit = 280,  -- text width the two wings hold
    crestPoint   = 25,   -- the crest's point below the plate's top
    plateBandMin = 200,
    beamY        = 73,
    beamInset    = 119,  -- beam tips inside the bar's ends
    beamMin      = 40,
    capInset     = 196,  -- the first tab's left edge from the bar's
    tabGap       = 10,
    tabTop       = 41,   -- a tab's top below the bar's
    selRaise     = 34,   -- the selected tab's art starts this far higher
    selPad       = 8,    -- and this far out on each side
    gemTop       = -4,   -- the gem's top from the selected art's
    tabTextY     = 85,   -- a tab's text center below its top
    tabTextRoom  = 140,  -- the tab's inner height around that center
    tabTextPad   = 42,   -- text clear of each tab end
    tabMin       = 330,
    rowGap       = 20,
}
local SELECT_FADE = 0.25
local GEM_LOW_ALPHA, GEM_HALF_PERIOD = 0.35, 1.4
local HOVER_ALPHA = 0.2
-- Top center. While another addon's entrance bar is switched on, it holds
-- the higher spot and ours sits below it.
local TOP_OFFSET        = -40
local TOP_OFFSET_SHARED = -150

local function DefaultTopOffset()
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded
        and C_AddOns.IsAddOnLoaded("Plumber")
    if loaded and type(PlumberDB) == "table" and PlumberDB.InstanceDifficulty == true then
        return TOP_OFFSET_SHARED
    end
    return TOP_OFFSET
end

local function NewBarFrame(parent, name)
    return CreateFrame("Frame", name, parent)
end

local bar = NewBarFrame(UIParent, "RetroRunsPickerBar")
bar:SetFrameStrata("MEDIUM")
bar:SetClampedToScreen(true)
bar:EnableMouse(true)
bar:SetMovable(true)
bar:RegisterForDrag("LeftButton")
bar:Hide()

local function Scale()
    return RR:GetSetting("pickerScale", 1.0) or 1.0
end

-- Below 1 while the live bar at its own scale would be wider than the screen.
local fitScale = 1
-- STACK_SCALE while entrances stack, else 1.
local stackScale = 1

-- The saved spot is the bar's top center, in screen units from the top
-- center of the screen, so bars of any width stay centered on it.
local function ApplyPosition()
    local scale = Scale() * stackScale * fitScale
    local anchor = RR:GetSetting("pickerAnchor", nil)
    local x, y = 0, DefaultTopOffset()
    if type(anchor) == "table" and anchor.x and anchor.y then
        x, y = anchor.x, anchor.y
    end
    bar:SetScale(scale)
    bar:ClearAllPoints()
    bar:SetPoint("TOP", UIParent, "TOP", x / scale, y / scale)
end

local FADE_IN, FADE_OUT = 0.25, 0.4

-- Native fades that keep their end alpha; each starts where the other
-- stopped.
local fadeIn = bar:CreateAnimationGroup()
fadeIn:SetToFinalAlpha(true)
local fadeInAlpha = fadeIn:CreateAnimation("Alpha")
fadeInAlpha:SetToAlpha(1)

local fadeOut = bar:CreateAnimationGroup()
fadeOut:SetToFinalAlpha(true)
local fadeOutAlpha = fadeOut:CreateAnimation("Alpha")
fadeOutAlpha:SetToAlpha(0)
fadeOut:SetScript("OnFinished", function() bar:Hide() end)

local fadeFrom = 0

local function CurrentAlpha()
    if fadeIn:IsPlaying() then
        return fadeFrom + (1 - fadeFrom) * fadeInAlpha:GetProgress()
    elseif fadeOut:IsPlaying() then
        return fadeFrom * (1 - fadeOutAlpha:GetProgress())
    end
    return bar:IsShown() and 1 or 0
end

local function PlayFade(group, animation, fromAlpha, toAlpha, duration)
    fadeIn:Stop()
    fadeOut:Stop()
    fadeFrom = fromAlpha
    bar:SetAlpha(fromAlpha)
    animation:SetFromAlpha(fromAlpha)
    animation:SetDuration(duration * math.abs(toAlpha - fromAlpha))
    group:Play()
end

-- The bar's text follows the Body Font setting, with the main panel's shadow.
local function SetFont(fontString, size)
    RR.SafeSetFont(fontString, RR:GetBodyFont(), RR:GetBodyFontSize(size), "")
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)
end

-- Places one piece of art: x, y and width in atlas pixels from the parent's
-- top left. A narrower width crops the piece, keeping the side keepRight
-- names; a wider one stretches it.
local function DrawPiece(texture, parent, name, x, y, width, mirror, keepRight)
    local piece = PIECES[name]
    local atlas = ATLAS[piece[1]]
    local left, top, pieceWidth, height = piece[2], piece[3], piece[4], piece[5]
    width = width or pieceWidth
    local right = left + pieceWidth
    if width < pieceWidth then
        if keepRight then left = right - width else right = left + width end
    end
    local leftCoord, rightCoord = left / atlas.width, right / atlas.width
    if mirror then leftCoord, rightCoord = rightCoord, leftCoord end
    texture:SetTexture(atlas.file)
    texture:SetTexCoord(leftCoord, rightCoord, top / atlas.height, (top + height) / atlas.height)
    texture:SetSize(width / artScale, height / artScale)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", parent, "TOPLEFT", x / artScale, -y / artScale)
    texture:Show()
end

-- Textures for one drawn piece set; an alpha makes them an additive glow.
local function NewTextures(owner, count, layer, alpha)
    local textures = {}
    for index = 1, count do
        local texture = owner:CreateTexture(nil, layer)
        if alpha then
            texture:SetBlendMode("ADD")
            texture:SetAlpha(alpha)
        end
        textures[index] = texture
    end
    return textures
end

local function ShowTextures(textures, shown)
    for _, texture in ipairs(textures) do texture:SetShown(shown) end
end

-- Grays a set of textures out, or restores them.
local function MuteTextures(textures, muted)
    local shade = muted and 0.55 or 1
    for _, texture in ipairs(textures) do
        texture:SetDesaturated(muted)
        texture:SetVertexColor(shade, shade, shade)
    end
end

-- A plain tab, width atlas pixels wide: an end, the band, the end mirrored.
local function DrawPlainTab(textures, parent, width)
    local endWidth = PIECES.plainEnd[4]
    DrawPiece(textures[1], parent, "plainEnd", 0, 0)
    DrawPiece(textures[2], parent, "plainBand", endWidth, 0, width - 2 * endWidth)
    DrawPiece(textures[3], parent, "plainEnd", width - endWidth, 0, nil, true)
end

-- The selected tab over a plain one of the same width: raised, a little
-- wider, with its gem centered on the top edge.
local function DrawSelectedTab(textures, gem, parent, width)
    local endWidth = PIECES.selEnd[4]
    local total = width + 2 * LAYOUT.selPad
    local x, y = -LAYOUT.selPad, -LAYOUT.selRaise
    DrawPiece(textures[1], parent, "selEnd", x, y, nil, true)
    DrawPiece(textures[2], parent, "selBand", x + endWidth, y, total - 2 * endWidth)
    DrawPiece(textures[3], parent, "selEnd", x + total - endWidth, y)
    DrawPiece(gem, parent, "gem", math.floor((width - PIECES.gem[4]) / 2), y + LAYOUT.gemTop)
end

-- The selected art fades in on the newly picked tab and out on the old one.
local function BuildSelectFade(layer)
    local fadeIn = layer:CreateAnimationGroup()
    local rise = fadeIn:CreateAnimation("Alpha")
    rise:SetFromAlpha(0)
    rise:SetToAlpha(1)
    rise:SetDuration(SELECT_FADE)
    rise:SetSmoothing("OUT")
    local fadeOut = layer:CreateAnimationGroup()
    fadeOut:SetToFinalAlpha(true)
    local fall = fadeOut:CreateAnimation("Alpha")
    fall:SetFromAlpha(1)
    fall:SetToAlpha(0)
    fall:SetDuration(SELECT_FADE)
    fall:SetSmoothing("IN")
    fadeOut:SetScript("OnFinished", function()
        layer:Hide()
        layer:SetAlpha(1)
    end)
    layer.fadeIn, layer.fadeOut = fadeIn, fadeOut
end

-- Shows or hides a button's selected art. It fades only when the selection
-- flips between repaints for the same key, so a reused button never does.
local function SetSelectedShown(button, selected, key)
    local layer = button.sel
    local changed = button.selectKey == key and button.selectOn ~= selected
    button.selectKey, button.selectOn = key, selected
    if selected then
        layer.fadeOut:Stop()
        layer:Show()
        if changed then layer.fadeIn:Play() end
    elseif changed then
        layer.fadeIn:Stop()
        layer.fadeOut:Play()
    elseif not layer.fadeOut:IsPlaying() then
        layer:Hide()
    end
end

-- A hidden button forgets its selection key, so a reused one never fades.
local function HideButton(button)
    button.selectKey = nil
    button:Hide()
end

-- A view is one drawn bar: the live one, or the settings preview.
local function NewView(frame, preview)
    return { frame = frame, rows = {}, preview = preview }
end

-- A row is one entrance: its plate and crest over its bar of tabs.
local function AcquireRow(view, index)
    local row = view.rows[index]
    if row then return row end
    row = { buttons = {} }
    row.bar = NewTextures(view.frame, 3, "BACKGROUND")
    row.plate = NewTextures(view.frame, 5, "BACKGROUND")
    row.crest = view.frame:CreateTexture(nil, "BORDER")
    row.title = view.frame:CreateFontString(nil, "OVERLAY")
    row.title:SetJustifyH("CENTER")
    row.expansion = view.frame:CreateFontString(nil, "OVERLAY")
    row.expansion:SetJustifyH("CENTER")
    view.rows[index] = row
    return row
end

local ShowTip   -- forward declaration; the buttons' hover handler
local OnClick   -- forward declaration; the buttons' click handler

local function AcquireButton(view, row, index)
    local button = row.buttons[index]
    if button then return button end
    button = CreateFrame("Button", nil, view.frame)
    button.view = view
    button.plain = NewTextures(button, 3, "BACKGROUND")
    button.hover = NewTextures(button, 3, "BORDER", HOVER_ALPHA)
    -- The selected art with its breathing gem, and the text above both.
    button.sel = CreateFrame("Frame", nil, button)
    button.sel:SetAllPoints(button)
    button.selArt = NewTextures(button.sel, 3, "BACKGROUND")
    button.gem = button.sel:CreateTexture(nil, "ARTWORK")
    BuildSelectFade(button.sel)
    button.sel:Hide()
    local text = CreateFrame("Frame", nil, button)
    text:SetAllPoints(button)
    text:SetFrameLevel(button.sel:GetFrameLevel() + 1)
    button.label = text:CreateFontString(nil, "OVERLAY")
    button.count = text:CreateFontString(nil, "OVERLAY")
    button.count:SetPoint("LEFT", button.label, "RIGHT", 4, 0)
    button.lockLine = text:CreateFontString(nil, "OVERLAY")
    -- A small lock in the tab's lower right when the week's shared lockout
    -- shuts the difficulty out.
    button.lock = text:CreateTexture(nil, "OVERLAY")
    button.lock:SetTexture(LOCK_TEXTURE)
    button.lock:SetTexCoord(unpack(LOCK_COORDS))
    button.lock:SetSize(LOCK_HEIGHT * LOCK_ASPECT, LOCK_HEIGHT)
    button.lock:Hide()
    button:SetScript("OnEnter", function(self)
        self.hovered = true
        ShowTextures(self.hover, self.hoverable == true)
        ShowTip(self)
    end)
    button:SetScript("OnLeave", function(self)
        self.hovered = nil
        ShowTextures(self.hover, false)
        GameTooltip_Hide()
    end)
    button:SetScript("OnClick", function(self) OnClick(self) end)
    -- The preview only shows.
    button:EnableMouse(not view.preview)
    row.buttons[index] = button
    return button
end

-- The game difficulties a special-loot availability flag allows. A row with
-- no flag, or hardModeOnly (chosen inside the fight), drops on every one.
local SPECIAL_FLAG_DIFFICULTIES = {
    mythicOnly       = { [16] = true, [23] = true },
    lfrOnly          = { [7] = true, [17] = true },
    normalHeroicOnly = { [1] = true, [2] = true, [3] = true, [4] = true,
                         [5] = true, [6] = true, [14] = true, [15] = true },
    heroicOnly       = { [2] = true, [5] = true, [6] = true, [15] = true },
    heroic25Only     = { [6] = true },
    size10Only       = { [3] = true, [5] = true },
    size25Only       = { [4] = true, [6] = true },
    normalOnly       = { [1] = true, [3] = true, [4] = true, [14] = true },
    heroicMythicOnly = { [2] = true, [15] = true, [16] = true, [23] = true },
}

-- Every look and special-loot row one or more difficulties offer: the
-- bosses' drops, the drops of rares and other map markers, the instance's
-- event rewards, and special loot this character can get there. A look is
-- its row when every difficulty shows one appearance, else its source at
-- that difficulty, so one look on several difficulties is kept once, at its
-- worst state. Returns looks (key -> state), specials (row -> missing) and
-- how many rows were seen.
local function InstanceLooks(instance, options)
    local classID = RR.PlayerClassID and RR.PlayerClassID()
    local looks, specials, seen = {}, {}, 0
    local bucket, option
    local function Visit(row, state)
        local key = row
        if UI.ItemShape and UI.ItemShape(row) ~= "binary" then
            key = UI.SourceAt(row, bucket) or row
        end
        local previous = looks[key]
        if previous == "missing" or (previous == "shared" and state ~= "missing") then return end
        looks[key] = state
    end
    local function CountSpecial(item)
        if not RR:SpecialLootForPlayer(item) then return end
        if item.restrictedToClass and item.restrictedToClass ~= classID then return end
        for flag, difficulties in pairs(SPECIAL_FLAG_DIFFICULTIES) do
            if item[flag] and not difficulties[option.difficultyID] then return end
        end
        seen = seen + 1
        specials[item] = RR.SpecialCollectionStateForItem(item) ~= "collected"
    end
    -- Special rows count on their own; the rest count as appearances.
    local function CountRows(rows, keep)
        local rowLooks = {}
        for _, item in ipairs(rows or {}) do
            if not keep or keep(item) then
                if item.kind then
                    CountSpecial(item)
                else
                    rowLooks[#rowLooks + 1] = item
                end
            end
        end
        seen = seen + UI.ForEachBossLookAt({ loot = rowLooks }, bucket, classID, Visit)
    end
    -- A map marker's drops are the trash rows naming a rare or a source;
    -- a row a boss also carries is counted once, on the boss.
    local carried = UI.BossCarriedSourceSet(instance)
    local eventCounts = RR:EventLootCounts(instance)
    for _, each in ipairs(options) do
        option, bucket = each, each.bucket
        for _, boss in ipairs(instance.bosses or {}) do
            seen = seen + UI.ForEachBossLookAt(boss, bucket, classID, Visit)
            for _, item in ipairs(boss.specialLoot or {}) do CountSpecial(item) end
        end
        CountRows(instance.trashLoot, function(item)
            return (item.rareNpc or item.tag) and not UI.TrashRowIsBossCarried(item, carried)
        end)
        if eventCounts then CountRows(instance.eventLoot) end
    end
    return looks, specials, seen
end

-- What one or more difficulties still have to collect: appearances missing,
-- then shared, then special loot missing. Nil when nothing is countable.
local function MissingCounts(instance, options)
    local looks, specials, seen = InstanceLooks(instance, options)
    if seen == 0 then return nil end
    local needed, shared, special = 0, 0, 0
    for _, state in pairs(looks) do
        if state == "missing" then
            needed = needed + 1
        elseif state == "shared" then
            shared = shared + 1
        end
    end
    for _, missing in pairs(specials) do
        if missing then special = special + 1 end
    end
    return needed, shared, special
end

-- The count beside a difficulty's name and the tooltip lines that explain
-- it: everything still missing, else the shared looks, in orange; a green 0
-- and "Nothing Left to Collect" once nothing is left. Nil when nothing
-- there is countable.
local function CollectionTexts(instance, option)
    local needed, shared, special = MissingCounts(instance, { option })
    if not needed then return nil, nil end
    local lines = {}
    -- White word, orange count, as the main panel's Transmog Needed reads.
    local function AddLine(label, count)
        lines[#lines + 1] = ("|cffffffff%s|r |cff%s(%d)|r"):format(label, ORANGE_HEX, count)
    end
    if needed > 0 then
        AddLine(RR.L["Missing Appearances"], needed)
    elseif shared > 0 then
        AddLine(RR.L["Shared Appearances"], shared)
    end
    if special > 0 then AddLine(RR.L["Missing Special Loot"], special) end
    if #lines == 0 then
        return ("|cff%s(0)|r"):format(GREEN_HEX),
            { ("|cff%s%s|r"):format(GREEN_HEX, RR.L["Nothing Left to Collect"]) }
    end
    local count = needed + special
    if count == 0 then count = shared end
    return ("|cff%s(%d)|r"):format(ORANGE_HEX, count), lines
end

-- A difficulty's lockout count, or nil for one that never saves.
local function LockCount(instance, option, counts)
    if RR:BucketNeverSaves(instance, option.bucket) then return nil end
    local count = counts[option.bucket]
    if not count or count.total == 0 then return nil end
    return count
end

local function LockText(count)
    local hex = GRAY_HEX
    if count.complete >= count.total then
        hex = GREEN_HEX
    elseif count.complete > 0 then
        hex = ORANGE_HEX
    end
    return ("|cff%s%d/%d|r"):format(hex, count.complete, count.total)
end


local function DifficultyName(difficultyID)
    return (GetDifficultyInfo and GetDifficultyInfo(difficultyID)) or tostring(difficultyID)
end

-- The raid sizes as short tab labels, the transmog browser's shorthand on
-- every client; the tooltip keeps the game's full name.
local SIZE_LABELS = { [3] = "10N", [4] = "25N", [5] = "10H", [6] = "25H" }

local function TabLabel(difficultyID)
    return SIZE_LABELS[difficultyID] or DifficultyName(difficultyID)
end

-- Shared with the End of Run Summary, so the two count alike.
UI.InstanceMissingCounts = MissingCounts
UI.InstanceLooks = InstanceLooks
UI.DifficultyTabLabel = TabLabel

-- Sets one line's text, returning its size, or hides it.
local function FillLine(fontString, text)
    if not text then
        fontString:Hide()
        return 0, 0
    end
    SetFont(fontString, LINE_SIZE)
    fontString:SetText(text)
    fontString:Show()
    return fontString:GetStringWidth(), math.ceil(fontString:GetStringHeight())
end

-- Draws one row's plate, crest and bar, top at y (atlas pixels), centered
-- on center. Returns the bar's top.
local function DrawRowArt(frame, layout, y, center)
    local row = layout.row
    local wingWidth, capWidth = PIECES.plateWing[4], PIECES.barCap[4]
    local plateTop = y + (layout.hasCrest and LAYOUT.crestAbove or 0)
    local plateLeft = math.floor(center - layout.plateWidth / 2)
    local beamY = plateTop + LAYOUT.beamY
    DrawPiece(row.plate[1], frame, "plateBeam", plateLeft - layout.beam, beamY, layout.beam)
    DrawPiece(row.plate[2], frame, "plateWing", plateLeft, plateTop)
    DrawPiece(row.plate[3], frame, "plateBand", plateLeft + wingWidth, plateTop, layout.plateBand)
    DrawPiece(row.plate[4], frame, "plateWing", plateLeft + wingWidth + layout.plateBand,
        plateTop, nil, true)
    DrawPiece(row.plate[5], frame, "plateBeam", plateLeft + layout.plateWidth, beamY,
        layout.beam, true)
    -- Only the top row wears the crest.
    if layout.hasCrest then
        DrawPiece(row.crest, frame, "crest", math.floor(center - PIECES.crest[4] / 2), y)
    else
        row.crest:Hide()
    end

    local barTop = plateTop + PIECES.plateWing[5] + LAYOUT.plateToBar
    local barLeft = math.floor(center - layout.barWidth / 2)
    DrawPiece(row.bar[1], frame, "barCap", barLeft, barTop)
    DrawPiece(row.bar[2], frame, "barBand", barLeft + capWidth, barTop,
        layout.barWidth - 2 * capWidth)
    DrawPiece(row.bar[3], frame, "barCap", barLeft + layout.barWidth - capWidth, barTop,
        nil, true)

    -- Name over expansion, centered on the plate's text line.
    local textTop = (plateTop + LAYOUT.plateTextY) / artScale - layout.plateTextH / 2
    row.title:ClearAllPoints()
    row.title:SetPoint("TOP", frame, "TOPLEFT", center / artScale, -textTop)
    row.expansion:ClearAllPoints()
    row.expansion:SetPoint("TOP", row.title, "BOTTOM", 0, -3)
    return barTop
end

-- The art scale the measured text fits: ART_SCALE, or less (larger art)
-- where a taller font would crowd a tab, the plate, or the crest's point.
local function FitArtScale(layouts)
    local scale = ART_SCALE
    for _, layout in ipairs(layouts) do
        scale = math.min(scale,
            LAYOUT.tabTextRoom / (layout.tabTextH + 2 * TEXT_MARGIN),
            LAYOUT.plateTextRoom / (layout.plateTextH + 2 * TEXT_MARGIN))
        if layout.hasCrest then
            scale = math.min(scale, (LAYOUT.plateTextY - LAYOUT.crestPoint)
                / (layout.plateTextH / 2 + CREST_MARGIN))
        end
    end
    return scale
end

-- One row's widths in atlas pixels at the current art scale: every tab as
-- wide as the widest, the bar around them, the plate around the name, and
-- beams reaching toward the bar's ends.
local function SizeRow(layout)
    local tabWidth = LAYOUT.tabMin
    for _, cell in ipairs(layout.cells) do
        tabWidth = math.max(tabWidth,
            math.ceil(cell.contentWidth * artScale) + 2 * LAYOUT.tabTextPad)
    end
    layout.barWidth = 2 * LAYOUT.capInset + math.max(0, #layout.cells - 1) * LAYOUT.tabGap
    for _, cell in ipairs(layout.cells) do
        cell.tabWidth = tabWidth
        layout.barWidth = layout.barWidth + tabWidth
    end
    layout.plateBand = math.max(LAYOUT.plateBandMin,
        math.ceil(layout.plateTextW * artScale) - LAYOUT.plateTextFit)
    layout.plateWidth = 2 * PIECES.plateWing[4] + layout.plateBand
    layout.beam = math.max(LAYOUT.beamMin, math.floor(
        (layout.barWidth - 2 * LAYOUT.beamInset - layout.plateWidth) / 2))
    return math.max(layout.barWidth, layout.plateWidth + 2 * layout.beam)
end

-- Lays out one row per entrance in range, centered, and sizes the bar to
-- fit. Every tab in a row is as wide as its widest and reserves the same lines.
local function Render(view)
    local currentHits = view.hits
    if not currentHits then return end
    local frame, rows = view.frame, view.rows
    local blocked = Picker.ChangeBlocked()
    local showLock = RR:GetSetting("pickerShowLockouts", true) ~= false
    local showMiss = RR:GetSetting("pickerShowMissing", true) ~= false
    local dungeonRows = 0
    for _, hit in ipairs(currentHits) do
        if hit.entry.instance.kind == "dungeon" then dungeonRows = dungeonRows + 1 end
    end

    local layouts = {}
    for rowIndex, hit in ipairs(currentHits) do
        local instance = hit.entry.instance
        local row = AcquireRow(view, rowIndex)
        SetFont(row.title, TITLE_SIZE)
        row.title:SetTextColor(unpack(CYAN))
        -- Bold look: a shadow in the text's own color, 1px to the right.
        row.title:SetShadowColor(CYAN[1], CYAN[2], CYAN[3], 1)
        row.title:SetShadowOffset(1, 0)
        row.title:SetText(RR:GetLocalizedRaidName(instance) or instance.name)
        row.title:Show()
        -- The expansion in the locale table's wording, as the browser shows it.
        SetFont(row.expansion, LINE_SIZE)
        row.expansion:SetTextColor(unpack(PINK))
        row.expansion:SetText(instance.expansion and RR.L[instance.expansion] or "")
        row.expansion:SetShown(instance.expansion ~= nil)
        local layout = { row = row, cells = {}, labelH = 0, lockH = 0, hasCrest = rowIndex == 1 }
        layouts[rowIndex] = layout
        layout.plateTextH = math.ceil(row.title:GetStringHeight()) + (row.expansion:IsShown()
            and (math.ceil(row.expansion:GetStringHeight()) + 3) or 0)
        layout.plateTextW = math.max(row.title:GetStringWidth(),
            row.expansion:IsShown() and row.expansion:GetStringWidth() or 0)

        local options = Picker.Options(instance)
        local counts = RR:GetPerDifficultyKillCountsForRaid(instance) or {}
        local resets = RR:GetResetsByBucket(instance)
        local locked, lockedOn, lockedOnBucket = {}, nil, nil
        for _, bucket in ipairs(RR:GetLockedOutBuckets(instance, counts) or {}) do
            locked[bucket] = true
        end
        for _, option in ipairs(options) do
            local count = counts[option.bucket]
            if not lockedOn and count and count.complete > 0 then
                lockedOn = DifficultyName(option.difficultyID)
                lockedOnBucket = option.bucket
            end
        end

        for index, option in ipairs(options) do
            local button = AcquireButton(view, row, index)
            local name = DifficultyName(option.difficultyID)
            local selected = Picker.CurrentDifficulty(option.kind) == option.difficultyID
            local count = LockCount(instance, option, counts)
            local nameCount, tipLines = CollectionTexts(instance, option)
            local shutOut = locked[option.bucket] == true
            local muted = blocked ~= nil
            button.data = {
                option = option, name = name, selected = selected,
                count = count, tipLines = tipLines,
                shutOut = shutOut, lockedOn = lockedOn,
                reset = resets[option.bucket] or (shutOut and resets[lockedOnBucket]) or nil,
                sharedNote = instance.kind == "dungeon" and dungeonRows > 1,
            }
            button.lock:SetShown(shutOut)

            SetFont(button.label, BUTTON_SIZE)
            button.label:SetText(TabLabel(option.difficultyID))
            button.label:SetTextColor(unpack(muted and DIM or LABEL))
            if not showMiss then nameCount = nil end
            SetFont(button.count, BUTTON_SIZE)
            button.count:SetText(nameCount or "")
            button.count:SetShown(nameCount ~= nil)
            local countW = nameCount and (4 + button.count:GetStringWidth()) or 0
            button.nameWidth = button.label:GetStringWidth() + countW
            -- Keyed to the entrance and difficulty, so a button reused for
            -- another entrance never fades.
            SetSelectedShown(button, selected, hit.entry.key .. ":" .. option.difficultyID)
            UI.SetBreathing(button.gem, selected and not blocked, GEM_LOW_ALPHA, GEM_HALF_PERIOD)
            MuteTextures(button.plain, muted)
            MuteTextures(button.selArt, blocked ~= nil)
            MuteTextures({ button.gem }, blocked ~= nil)
            button.hoverable = not selected and not muted

            -- A difficulty that never saves reads "- / -".
            local lockLine
            if showLock then
                lockLine = count and LockText(count) or ("|cff%s- / -|r"):format(GRAY_HEX)
            end
            local lockW, lockH = FillLine(button.lockLine, lockLine)
            layout.labelH = math.max(layout.labelH, math.ceil(button.label:GetStringHeight()))
            layout.lockH = math.max(layout.lockH, lockH)
            layout.cells[index] = { button = button,
                contentWidth = math.ceil(math.max(button.nameWidth, lockW)) + 4 }
        end
        for index = #options + 1, #row.buttons do HideButton(row.buttons[index]) end
        layout.tabTextH = layout.labelH + 5 + layout.lockH
    end

    artScale = FitArtScale(layouts)
    local widest = 0
    for _, layout in ipairs(layouts) do widest = math.max(widest, SizeRow(layout)) end

    -- Second pass: every row centered in the widest one, stacked.
    local y = 0
    local tabHeight = PIECES.plainEnd[5]
    for _, layout in ipairs(layouts) do
        local barTop = DrawRowArt(frame, layout, y, widest / 2)
        local lockTop = layout.labelH + 5
        local textTop = LAYOUT.tabTextY / artScale - layout.tabTextH / 2
        local x = math.floor(widest / 2 - layout.barWidth / 2) + LAYOUT.capInset
        for _, cell in ipairs(layout.cells) do
            local button = cell.button
            local width = cell.tabWidth / artScale
            button:SetSize(width, tabHeight / artScale)
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", x / artScale,
                -(barTop + LAYOUT.tabTop) / artScale)
            DrawPlainTab(button.plain, button, cell.tabWidth)
            DrawPlainTab(button.hover, button, cell.tabWidth)
            ShowTextures(button.hover, button.hovered and button.hoverable)
            DrawSelectedTab(button.selArt, button.gem, button.sel, cell.tabWidth)
            -- Name and count centered together, the lockout line under them.
            button.label:ClearAllPoints()
            button.label:SetPoint("TOPLEFT", button, "TOPLEFT",
                math.floor((width - button.nameWidth) / 2), -textTop)
            button.lockLine:ClearAllPoints()
            button.lockLine:SetPoint("TOP", button, "TOP", 0, -(textTop + lockTop))
            -- The lock level with the lockout line, or with the name when lines are off.
            local lockCenter = layout.lockH > 0 and (lockTop + layout.lockH / 2) or (layout.labelH / 2)
            button.lock:ClearAllPoints()
            button.lock:SetPoint("RIGHT", button, "TOPRIGHT",
                -LAYOUT.tabTextPad / artScale, -(textTop + lockCenter))
            button:Show()
            x = x + cell.tabWidth + LAYOUT.tabGap
        end
        y = barTop + PIECES.barCap[5] + LAYOUT.rowGap
    end
    for index = #currentHits + 1, #rows do
        local row = rows[index]
        row.title:Hide()
        row.expansion:Hide()
        row.crest:Hide()
        ShowTextures(row.bar, false)
        ShowTextures(row.plate, false)
        for _, button in ipairs(row.buttons) do HideButton(button) end
    end
    frame:SetSize(widest / artScale, (y - LAYOUT.rowGap) / artScale)

    -- The live bar draws smaller while entrances stack, and shrinks rather
    -- than run past the screen's edges.
    if not view.preview then
        local stack = (#currentHits > 1) and STACK_SCALE or 1
        local width = widest / artScale * Scale() * stack
        local fit = math.min(1, (UIParent:GetWidth() or width) * SCREEN_FIT / math.max(width, 1))
        if math.abs(fit - fitScale) > 0.001 or stack ~= stackScale then
            fitScale, stackScale = fit, stack
            ApplyPosition()
        end
    end
end

ShowTip = function(button)
    local data = button.data
    if not data then return end
    GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
    GameTooltip_SetTitle(GameTooltip, data.name)
    local saved = data.shutOut
    if data.shutOut then
        GameTooltip_AddNormalLine(GameTooltip,
            (RR.L["Locked for this week: your lockout is on %s."]):format(data.lockedOn or ""))
    elseif data.count then
        if data.count.complete > 0 then
            -- The bar already shows the count; the tooltip adds the reset.
            saved = true
        else
            GameTooltip_AddNormalLine(GameTooltip, RR.L["Not saved"])
        end
    end
    if saved and data.reset then
        GameTooltip_AddNormalLine(GameTooltip, RR:ResetText(data.reset))
    end
    for _, line in ipairs(data.tipLines or {}) do
        GameTooltip_AddNormalLine(GameTooltip, line)
    end
    if data.sharedNote then
        GameTooltip_AddNormalLine(GameTooltip, RR.L["Dungeon difficulty applies to every dungeon."])
    end
    local blocked = Picker.ChangeBlocked()
    if blocked == "leader" then
        GameTooltip_AddNormalLine(GameTooltip, RR.L["Only the group leader can change the difficulty."])
    elseif blocked == "finder" then
        GameTooltip_AddNormalLine(GameTooltip, RR.L["Difficulty can't be changed in a group finder group."])
    elseif not data.selected then
        GameTooltip_AddNormalLine(GameTooltip, (RR.L["Click to set %s."]):format(data.name))
    end
    GameTooltip:Show()
end

OnClick = function(button)
    local data = button.data
    if not data or data.selected or Picker.ChangeBlocked() then return end
    Picker.SetDifficulty(data.option)
    if RR:GetSetting("pickerSound", true) ~= false then
        PlaySoundFile(SELECT_SOUND, "SFX")
    end
    Render(button.view)
    if GameTooltip:GetOwner() == button then ShowTip(button) end
end

local live = NewView(bar, false)
local liveHits      -- the entrances the player stands at, or nil
local unlocked = false

-- What an unlocked bar and the preview show: Bloodmaul Slag Mines, or the
-- first dungeon with data when it is missing.
local function SampleHits()
    local sample
    for _, dungeon in pairs(RetroRuns_DungeonData or {}) do
        if type(dungeon) == "table" and dungeon.instanceID and dungeon.bosses then
            if dungeon.instanceID == 1175 then sample = dungeon; break end
            sample = sample or dungeon
        end
    end
    if not sample then return nil end
    return { { entry = { instance = sample, key = "sample" }, distance = 0 } }
end

-- Shows the bar for the entrances in range, or the sample while unlocked;
-- fades it out when there is neither.
local function Sync()
    local hits = liveHits or (unlocked and SampleHits()) or nil
    if not hits then
        if not bar:IsShown() or fadeOut:IsPlaying() then return end
        live.hits = nil
        PlayFade(fadeOut, fadeOutAlpha, CurrentAlpha(), 0, FADE_OUT)
        return
    end
    live.hits = hits
    Render(live)
    local fromAlpha = CurrentAlpha()
    bar:Show()
    if fromAlpha < 1 and not fadeIn:IsPlaying() then
        PlayFade(fadeIn, fadeInAlpha, fromAlpha, 1, FADE_IN)
    end
end

-- Hint caption above an unlocked bar.
local dragLabel = bar:CreateFontString(nil, "OVERLAY")
dragLabel:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 4)
dragLabel:Hide()

bar:SetScript("OnDragStart", function(self)
    if unlocked then self:StartMoving() end
end)
bar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if not unlocked then return end
    local scale = self:GetScale()
    local centerX = self:GetCenter()
    local top = self:GetTop()
    if centerX and top then
        RR:SetSetting("pickerAnchor", {
            x = math.floor(centerX * scale - (UIParent:GetWidth() or 0) / 2 + 0.5),
            y = math.floor(top * scale - (UIParent:GetHeight() or 0) + 0.5),
        })
    end
    ApplyPosition()
end)

-- The settings preview: a second bar on the given parent, drawn from the
-- sample at the live bar's on-screen size.
local function BuildPreview(parent)
    local frame = NewBarFrame(parent)
    local view = NewView(frame, true)
    local handle = { frame = frame }
    -- Matches the live bar's effective scale; shrinks only past
    -- handle.maxWidth.
    function handle:Refresh()
        view.hits = SampleHits()
        Render(view)
        local scale = Scale() * UIParent:GetEffectiveScale()
            / math.max(parent:GetEffectiveScale(), 0.01)
        local width = frame:GetWidth() or 0
        if self.maxWidth and width > 0 and width * scale > self.maxWidth then
            scale = self.maxWidth / width
        end
        frame:SetScale(scale)
        frame:SetShown(view.hits ~= nil)
    end
    return handle
end

local previews = {}

-- Difficulty, group and lockout changes repaint an open bar.
local events = CreateFrame("Frame")
for _, eventName in ipairs({ "PLAYER_DIFFICULTY_CHANGED", "UPDATE_INSTANCE_INFO",
        "GROUP_ROSTER_UPDATE", "PARTY_LEADER_CHANGED" }) do
    events:RegisterEvent(eventName)
end
events:SetScript("OnEvent", function()
    if bar:IsShown() and live.hits then Render(live) end
end)

UI.PickerBar = {
    Show = function(hits)
        liveHits = hits
        ApplyPosition()
        Sync()
        if RequestRaidInfo then RequestRaidInfo() end
    end,
    Hide = function()
        if liveHits == nil then return end
        liveHits = nil
        Sync()
    end,
    -- Settings changes repaint an open bar and the previews.
    Refresh = function()
        ApplyPosition()
        if bar:IsShown() and live.hits then Render(live) end
        for _, preview in ipairs(previews) do
            if preview.frame:IsVisible() then preview:Refresh() end
        end
    end,
    Unlock = function()
        unlocked = true
        RR.SafeSetFont(dragLabel, RR:GetChromeFont(), 12, "OUTLINE")
        dragLabel:SetText(RR.L["Drag to move"])
        dragLabel:SetTextColor(1, 0.7, 0.9, 1)
        dragLabel:Show()
        -- Above the settings window while it is being placed.
        bar:SetFrameStrata("FULLSCREEN_DIALOG")
        ApplyPosition()
        Sync()
    end,
    Lock = function()
        unlocked = false
        dragLabel:Hide()
        bar:SetFrameStrata("MEDIUM")
        Sync()
    end,
    ResetPosition = function()
        RR:SetSetting("pickerAnchor", nil)
        ApplyPosition()
    end,
    BuildPreview = function(parent)
        local preview = BuildPreview(parent)
        previews[#previews + 1] = preview
        return preview
    end,
}
