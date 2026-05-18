-------------------------------------------------------------------------------
-- RetroRuns -- UI.lua
-- All panel and display logic, exposed as the RR.UI module table.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Module table -- all public UI functions live here.
-- Core calls RR.UI.Update(), RR.UI.ApplySettings(), etc.
-------------------------------------------------------------------------------

RR.UI = {}
local UI = RR.UI

-------------------------------------------------------------------------------
-- Layout constants
-------------------------------------------------------------------------------

local PANEL_W    = 430
local PANEL_H    = 460
local PAD_LEFT   = 16
local PAD_RIGHT  = 12
local BODY_WIDTH = PANEL_W - PAD_LEFT - PAD_RIGHT - 10

local TITLE_FONT = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\04B_03.TTF"
-- VT323: monospaced terminal-style font. Vector outlines (not bitmap),
-- so it scales cleanly without the antialiasing-dimness pixel fonts
-- get at non-native sizes. Period-appropriate for the "retro computing"
-- vibe, and pairs visually with 04B_03 (the chrome font) while reading
-- more naturally for body content.
local VT323_FONT = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\VT323.ttf"
local BODY_FONT  = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local TITLE_SIZE = 20

-- Body font metadata. Per-font sizeFactor lets each font render at a
-- size that visually matches FRIZQT at the same nominal point size.
-- The targets table and SafeSetFont call sites in RefreshIdleList etc.
-- pass a baseSize that's tuned for FRIZQT; we multiply by the active
-- font's sizeFactor to get the actual render size.
--   - FRIZQT (standard, default) is the baseline at 1.0.
--   - 04B_03 fits at 1.0 because its tight pixel grid renders at
--     FRIZQT's visual density at the same point size.
--   - VT323 renders narrower and shorter than FRIZQT at the same
--     point size, so it needs a bump to read at comparable visual
--     size. 1.30 gets it close enough.
--
-- Adding a new font: drop the TTF in Media/Fonts/, add a constant and
-- an entry to BODY_FONT_INFO, then add a radio button in the settings
-- panel. No per-widget tuning needed.
local BODY_FONT_INFO = {
    standard = { path = BODY_FONT,  sizeFactor = 1.00 },
    retro    = { path = TITLE_FONT, sizeFactor = 1.00 },
    vt323    = { path = VT323_FONT, sizeFactor = 1.30 },
}

local C_PINK   = { 0.95, 0.35, 0.78 }
local C_BLUE   = { 0.30, 0.80, 1.00 }
local C_LABEL  = "7CFC00"   -- section label colour (green)

-- Known teleporter node names -- highlighted orange in travel text
-------------------------------------------------------------------------------
-- Font helper
-------------------------------------------------------------------------------

local function SafeSetFont(fs, path, size, flags)
    if not fs then return end
    if not (path and fs:SetFont(path, size, flags or "")) then
        fs:SetFont(BODY_FONT, size, flags or "")
    end
end

-- Resolve the user's bodyFontStyle setting to a {path, sizeFactor}
-- entry from BODY_FONT_INFO. Defaults to "standard" (FRIZQT) if unset
-- or invalid -- matches the bodyFontStyle default in Core.lua.
local function GetBodyFontInfo()
    local style = (RetroRuns and RetroRuns.GetSetting)
        and RetroRuns:GetSetting("bodyFontStyle", "standard")
        or "standard"
    return BODY_FONT_INFO[style] or BODY_FONT_INFO.standard
end

-- Returns the font path for body-level text. Body-level = panel body
-- widgets (raid name, pills, encounter card, travel directions, etc.),
-- idle list rows + legend rows, boss progress list, and auxiliary
-- window body text (Tmog / Achievements / Skips popups). Frame
-- chrome (titles, footer, action buttons) is locked to 04B_03 and
-- doesn't go through this function -- those use TITLE_FONT directly.
local function GetBodyFont()
    return GetBodyFontInfo().path
end

-- Returns the effective render size for a given baseSize, accounting
-- for the active body font's sizeFactor. Use this anywhere you'd
-- previously pass `baseSize` to SetFont/SafeSetFont for body widgets.
-- The factor lets a wider-rendered pixel font (like Pixel Operator
-- Mono) be scaled DOWN at the same nominal point so it doesn't
-- overflow widths tuned for FRIZQT.
local function GetBodyFontSize(baseSize)
    return math.max(8, math.floor(baseSize * GetBodyFontInfo().sizeFactor + 0.5))
end

-- Apply the active body font + computed size + a subtle black shadow
-- to a FontString. Use this anywhere a body widget needs to participate
-- in the bodyFontStyle toggle. Wraps three operations:
--   1. SafeSetFont(fs, GetBodyFont(), GetBodyFontSize(baseSize), flags)
--   2. SetShadowOffset(1, -1)
--   3. SetShadowColor(0, 0, 0, 1)
-- The shadow is what makes pixel fonts (especially Pixel Operator at
-- non-integer pixel scales) render with full visual weight rather than
-- looking dim against the dark backdrop. Antialiasing at non-native
-- pixel sizes drops pixel-font glyph edges to partial opacity; a 1px
-- black shadow restores perceived contrast. The shadow is harmless on
-- FRIZQT (very faint, reads as edge sharpening).
local function SetBodyFont(fs, baseSize, flags)
    if not fs then return end
    SafeSetFont(fs, GetBodyFont(), GetBodyFontSize(baseSize), flags or "")
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 1)
end

-------------------------------------------------------------------------------
-- Main panel
-------------------------------------------------------------------------------

local panel = CreateFrame("Frame", "RetroRunsMainFrame", UIParent, "BackdropTemplate")
panel:SetSize(PANEL_W, PANEL_H)
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetClampedToScreen(true)
panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Normalize the anchor back to CENTER/CENTER so the offsets we save
    -- can be correctly re-applied by RestorePanelPosition on reload.
    -- WoW's StartMoving/StopMovingOrSizing may rewrite the frame's
    -- "first point" into a different anchor system (e.g. TOPLEFT of
    -- UIParent BOTTOMLEFT) depending on where the drag ended. If we
    -- saved those raw x/y values, they'd be interpreted as CENTER/
    -- CENTER offsets on the next restore and the panel would land in
    -- the wrong place. Normalizing here guarantees the saved values
    -- always match the CENTER-anchored contract that the restore path
    -- expects.
    local cx, cy   = self:GetCenter()
    local pcx, pcy = UIParent:GetCenter()
    local fscale   = self:GetEffectiveScale()
    local pscale   = UIParent:GetEffectiveScale()
    -- SetPoint("CENTER", UIParent, "CENTER", x, y) interprets x/y in the
    -- ANCHORED frame's scaled coord system (per Wowpedia "UI scaling" --
    -- offsets are specified in the Frame Scaled coordinate system of the
    -- point being anchored). So we convert (panel_center - uiparent_center)
    -- in screen pixels into panel-scaled units by dividing by fscale, NOT
    -- pscale. At windowScale=1.0 fscale==pscale and the bug is invisible;
    -- at any other windowScale this matters.
    local x = (cx * fscale - pcx * pscale) / fscale
    local y = (cy * fscale - pcy * pscale) / fscale
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "CENTER", x, y)
    RR:SetSetting("panelX", math.floor(x + 0.5))
    RR:SetSetting("panelY", math.floor(y + 0.5))
end)

-- Forward-declared so the panel.closeButton OnClick handler (defined below)
-- can reference them. Both are assigned-not-declared further down in the
-- file (look for `tmogWindow =` and `browserState =` without `local`).
local tmogWindow
local browserState
-- Forward-declared too. Skips window is opened by /rr skips and shows
-- account-wide raid-skip unlock status across all supported raids. Same
-- BackdropTemplate framed window pattern as tmogWindow, but without
-- dropdowns / hyperlinks / hover-hide -- it's a pure read-only display.
local skipsWindow

-- Forward-declared too. Achievements window opens from the action-row
-- "Achieves" button. Combines tmogWindow's Expansion/Raid/Boss dropdowns
-- with a simpler open/toggle lifecycle (no hover-grace timer). Keeps its
-- own selection state in achState (parallel to browserState), so the
-- two windows can have independent dropdown selections.
local achievementsWindow
local achState

-- Forward-declared too. What's New window opens from the version-link
-- button in the main panel footer. Shows the most recent release notes
-- from RR.WhatsNew (populated in WhatsNew.lua). Mutexes with the other
-- auxiliary windows since they all anchor to the panel's right edge.
local whatsNewWindow

-- Forward-declared so UI.ApplySettings (defined below, but before the
-- assignment site of RefreshIdleList) can call it after font/scale
-- changes. Without this declaration, the reference in ApplySettings
-- would resolve to a nil global and the toggle buttons would never
-- resize when settings change.
local RefreshIdleList

panel:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
panel:SetBackdropColor(0.03, 0.03, 0.03, 0.92)

-- Enable hyperlink clicks on the panel so achievement links in the
-- encounter FontString become clickable. SetItemRef is Blizzard's global
-- dispatcher that routes |Hachievement:...|h, |Hitem:...|h, etc. to the
-- appropriate pane (achievement, item, spell). The handler intentionally
-- does nothing for links it doesn't recognize -- SetItemRef is a no-op
-- for unknown prefixes.
panel:SetHyperlinksEnabled(true)
panel:SetScript("OnHyperlinkClick", function(_, link, text, button)
    SetItemRef(link, text, button)
end)

-- Logo
panel.logo = panel:CreateTexture(nil, "ARTWORK")
-- Logo size shrunk 34 -> 24 in v1.7 alongside the new minimize button
-- to rebalance the title bar. The original 34px was sized when the logo
-- was the only element competing with the close X for visual weight on
-- the title row; with a minimize button now occupying the right side,
-- 34 felt over-sized and the logo bulged below the title text. 24 is
-- closer to the cap-height of the 12pt title font's OUTLINE rendering,
-- so the logo sits as a peer to the text rather than dominating it.
panel.logo:SetSize(24, 24)
panel.logo:SetPoint("TOPLEFT", PAD_LEFT - 4, -10)
panel.logo:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\LogoSquare")

-- Title (two FontStrings, split only at colour boundary)
panel.titleRetro = panel:CreateFontString(nil, "OVERLAY")
panel.titleRetro:SetPoint("LEFT", panel.logo, "RIGHT", 6, -1)
panel.titleRetro:SetFont(BODY_FONT, 12, "OUTLINE")
panel.titleRetro:SetText("RETRO")
panel.titleRetro:SetTextColor(unpack(C_PINK))
panel.titleRetro:SetShadowOffset(1, -1)
panel.titleRetro:SetShadowColor(0, 0, 0, 1)

panel.titleRuns = panel:CreateFontString(nil, "OVERLAY")
panel.titleRuns:SetPoint("LEFT", panel.titleRetro, "RIGHT", 0, 0)
panel.titleRuns:SetFont(BODY_FONT, 12, "OUTLINE")
panel.titleRuns:SetText("RUNS")
panel.titleRuns:SetTextColor(unpack(C_BLUE))
panel.titleRuns:SetShadowOffset(1, -1)
panel.titleRuns:SetShadowColor(0, 0, 0, 1)

-- Close button
panel.closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
panel.closeButton:SetPoint("TOPRIGHT", -4, -4)
panel.closeButton:SetScript("OnClick", function()
    RR:SetSetting("showPanel", false)
    panel:Hide()
    -- Also close the standalone auxiliary windows if any are open. The
    -- main panel and its auxiliary windows are conceptually a single
    -- experience: closing the main panel should leave nothing of
    -- RetroRuns visible.
    if tmogWindow and tmogWindow:IsShown() then
        browserState.active = false
        tmogWindow:Hide()
    end
    if skipsWindow and skipsWindow:IsShown() then
        skipsWindow:Hide()
    end
    if achievementsWindow and achievementsWindow:IsShown() then
        achievementsWindow:Hide()
    end
end)

-- Minimize / maximize button. Sits just left of the close button.
-- Uses two custom TGA assets in Media/: MinimizeIcon (gold horizontal
-- bar on red face with dark outline, shown when expanded) and
-- MaximizeIcon (gold open square on red face with dark outline, shown
-- when minimized). The icons are full-color TGAs (not white-source),
-- so no vertex tinting is applied -- they render as painted.
--
-- Sized 22x22 to feel like a peer of the close X without competing
-- with it visually. The close X is 32x32 from the UIPanelCloseButton
-- template but its visible glyph (the red square + white X) occupies
-- only the inner ~22px; the outer ~5px on each side is transparent
-- texture padding. Sizing this button to 22 matches the close X's
-- *visual* footprint, not its hit-area footprint. The dark outer
-- outline on the icon art adds visual weight, so a smaller raw size
-- still reads as a peer to the close button.
--
-- Position: TOPRIGHT -30,-4. Iterated empirically from earlier guesses
-- that placed the button too far left and too low. Final placement:
-- the button's top edge aligns with the close X's top edge (both at
-- y=-4), and the button's right edge is 6px clear of the close X's
-- frame left edge. The 22x22 button visually peers with the close X's
-- visible glyph (which centers in its 32x32 frame) rather than the
-- frame itself, so vertical-edge-aligning the two frames produces a
-- "centered against the X glyph" look without further nudging.
panel.minimizeButton = CreateFrame("Button", nil, panel)
panel.minimizeButton:SetSize(22, 22)
panel.minimizeButton:SetPoint("TOPRIGHT", -30, -4)

panel.minimizeButton:SetNormalTexture("Interface\\AddOns\\RetroRuns\\Media\\MinimizeIcon")
panel.minimizeButton:SetPushedTexture("Interface\\AddOns\\RetroRuns\\Media\\MinimizeIcon")
panel.minimizeButton:SetHighlightTexture(
    "Interface\\Buttons\\CheckButtonHilight", "ADD")
-- OnClick wired further below, after UI.SetMinimized is defined --
-- it needs to reference that function and SetMinimized in turn
-- references panel internals defined later in this file.

-- Test-mode label. Anchored to clear both the close button (TOPRIGHT
-- -4,-4 occupying through right-36) AND the minimize button (22x22
-- at TOPRIGHT -30,-4 occupying right-30 through right-52). Pushed
-- to right-56 to give a small visual gap between the rightmost edge
-- of the test-mode text and the minimize button's left edge.
panel.mode = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.mode:SetPoint("TOPRIGHT", -56, -14)
panel.mode:SetText("")
-- Test-mode indicator sits in the title bar band. Locked to 04B_03
-- (header chrome). Only renders when /rr test is active; staying
-- retro keeps it visually consistent with the RETRO RUNS title to
-- its left.
panel.mode:SetFont(TITLE_FONT, 11, "OUTLINE")
panel.mode:SetShadowOffset(1, -1)
panel.mode:SetShadowColor(0, 0, 0, 1)

-- Map / Tmog / Skips / Settings action buttons live in a row at the
-- bottom of the panel; see the "Footer" block further down for their
-- definitions. Keeping all four button creators in one place makes
-- their layout easy to reason about (single anchor calculation, single
-- frame for spacing) -- previously Tmog and Map sat in the header
-- with their own anchor logic, which made adding a third or fourth
-- button awkward.

-- -- Body fields --------------------------------------------------------------

local function AddField(anchor, anchorPoint, relPoint, offsetY, width, template)
    local fs = panel:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    fs:SetPoint(anchorPoint, anchor, relPoint, 0, offsetY)
    fs:SetWidth(width or BODY_WIDTH)
    fs:SetJustifyH("LEFT")
    return fs
end

panel.raid = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
panel.raid:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD_LEFT, -52)
panel.raid:SetWidth(PANEL_W - PAD_LEFT - 80)
panel.raid:SetJustifyH("LEFT")

-- Per-difficulty kill-count pills. Replaces the trailing "(Heroic)"
-- portion of the raid name. Format: "[ LFR x/y | N x/y | H x/y | M x/y ]"
-- matching the bracketed/piped style of the tmog popup's per-difficulty
-- dot row (see BuildPerDiffRow). The player's current difficulty is
-- rendered in white; every other difficulty (whether fully cleared,
-- partially cleared, or untouched) is gray. Reader picks out "what am
-- I playing" by the white highlight, then reads the x/y to know status.
-- Counts come from RR:GetPerDifficultyKillCounts which uses
-- C_RaidLocks.IsEncounterComplete; updates whenever UI.Update runs
-- (which already fires on zone change, ENCOUNTER_END, and the 1Hz
-- heartbeat). No separate event wiring needed.
panel.pills = AddField(panel.raid, "TOPLEFT", "BOTTOMLEFT", -2, BODY_WIDTH, "GameFontNormalSmall")

panel.progress  = AddField(panel.pills,    "TOPLEFT", "BOTTOMLEFT", -6,  BODY_WIDTH, "GameFontNormal")
panel.next      = AddField(panel.progress, "TOPLEFT", "BOTTOMLEFT", -8,  BODY_WIDTH, "GameFontNormal")
panel.travel    = AddField(panel.next,     "TOPLEFT", "BOTTOMLEFT", -12, BODY_WIDTH)

-- Boss Encounter section. A Button (not a plain FontString) so the
-- section can be clicked to expand/collapse the soloTip and
-- Achievements content. Default state is collapsed for bosses with
-- custom notes (player clicks to view); for bosses with no custom
-- note ("Standard Nuke" or empty), the line reads "Standard" and
-- isn't clickable. Single global expand/collapse state stored in
-- RetroRunsDB.encounterExpanded; one click affects all bosses for
-- the rest of the session, but the value is reset to false on each
-- PLAYER_LOGIN (Core.lua) so every session begins collapsed regardless
-- of prior expand history.
-- panel.encounter is a wrapper Frame containing three independent
-- sub-widgets stacked vertically:
--
--   1. .header        - Button. Shows the "Boss Encounter: ..." line.
--                       OnClick toggles the soloTip expand/collapse.
--                       This is the ONLY toggle target.
--   2. .achievements  - Frame with hyperlinks enabled. Shows the
--                       achievements block. NO OnClick handler -- clicks
--                       that don't land on a hyperlink fall through.
--                       This is what makes achievement-link clicks work
--                       reliably regardless of the soloTip state.
--   3. .specialLoot   - Frame with hyperlinks enabled. Shows the
--                       special-loot block. Same pattern as achievements.
--
-- The wrapper itself has no click handling and no FontString. Each
-- sub-widget owns its own FontString and sizes to its content. The
-- wrapper resizes to the sum of children's heights each render so
-- downstream anchors (panel.transmog -> panel.encounter:BOTTOMLEFT)
-- stay valid.
--
-- This isolates the previous bug: a single Button covering the whole
-- encounter content area would intercept clicks meant for hyperlinks
-- when the hyperlink hit-test was pixel-imprecise. By splitting the
-- click-toggle target (header only) from the hyperlink targets
-- (achievements, special loot) into separate widgets, the click
-- competition disappears entirely.
panel.encounter = CreateFrame("Frame", nil, panel)
panel.encounter:SetPoint("TOPLEFT", panel.travel, "BOTTOMLEFT", 0, -8)
panel.encounter:SetSize(BODY_WIDTH, 14)

-- Header sub-widget: the toggle target.
panel.encounter.header = CreateFrame("Button", nil, panel.encounter)
panel.encounter.header:SetPoint("TOPLEFT", 0, 0)
panel.encounter.header:SetSize(BODY_WIDTH, 14)
panel.encounter.header.label = panel.encounter.header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.encounter.header.label:SetPoint("TOPLEFT", 0, 0)
panel.encounter.header.label:SetWidth(BODY_WIDTH)
panel.encounter.header.label:SetJustifyH("LEFT")
panel.encounter.header.label:SetWordWrap(true)
panel.encounter.header.label:SetNonSpaceWrap(true)
panel.encounter.header:RegisterForClicks("LeftButtonUp")
panel.encounter.header:SetScript("OnClick", function(self)
    if not self.clickable then return end
    local now = RR:GetSetting("encounterExpanded")
    RR:SetSetting("encounterExpanded", not now)
    UI.Update()
end)

-- Achievements sub-widget: hyperlinks-only, no toggle.
panel.encounter.achievements = CreateFrame("Frame", nil, panel.encounter)
panel.encounter.achievements:SetPoint("TOPLEFT", panel.encounter.header, "BOTTOMLEFT", 0, -4)
panel.encounter.achievements:SetSize(BODY_WIDTH, 1)
panel.encounter.achievements.label = panel.encounter.achievements:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.encounter.achievements.label:SetPoint("TOPLEFT", 0, 0)
panel.encounter.achievements.label:SetWidth(BODY_WIDTH)
panel.encounter.achievements.label:SetJustifyH("LEFT")
panel.encounter.achievements.label:SetWordWrap(true)
panel.encounter.achievements.label:SetNonSpaceWrap(true)
panel.encounter.achievements:SetHyperlinksEnabled(true)
panel.encounter.achievements:SetScript("OnHyperlinkClick", function(_, link, text, button)
    SetItemRef(link, text, button)
end)

-- Special loot sub-widget: hyperlinks-only, no toggle.
panel.encounter.specialLoot = CreateFrame("Frame", nil, panel.encounter)
panel.encounter.specialLoot:SetPoint("TOPLEFT", panel.encounter.achievements, "BOTTOMLEFT", 0, -4)
panel.encounter.specialLoot:SetSize(BODY_WIDTH, 1)
panel.encounter.specialLoot.label = panel.encounter.specialLoot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.encounter.specialLoot.label:SetPoint("TOPLEFT", 0, 0)
panel.encounter.specialLoot.label:SetWidth(BODY_WIDTH)
panel.encounter.specialLoot.label:SetJustifyH("LEFT")
panel.encounter.specialLoot.label:SetWordWrap(true)
panel.encounter.specialLoot.label:SetNonSpaceWrap(true)
panel.encounter.specialLoot:SetHyperlinksEnabled(true)
panel.encounter.specialLoot:SetScript("OnHyperlinkClick", function(_, link, text, button)
    SetItemRef(link, text, button)
end)

-- Forward declarations for transmog popup (defined later in file)
local GetOrCreateTmogWindow
local BuildTransmogDetail
-- tmogWindow forward-declared near the top of the file (before the panel
-- close-button handler that references it). This is just a no-op assignment
-- to nil; actual assignment happens later in GetOrCreateTmogWindow.

-- Forward declaration for Special Loot section builder. Used by
-- BuildEncounterText (line ~782) but defined alongside the transmog
-- helpers much further down (line ~1115). Actual assignment happens
-- via `BuildSpecialLootSection = function(boss) ... end` at that
-- definition site.
local BuildSpecialLootSection

-- Forward declaration for settings panel (constructed later in file).
-- UI.AutoSize references it, and AutoSize is defined before settingsFrame.
local settingsFrame

-- Browser selection state. Declared here (not at the "Transmog browser"
-- section below) because early handlers on panel.transmog need to close
-- over it. Fields are filled in by EnsureBrowserDefaults().
-- (Assigned to the forward-declared `browserState` from near the top of file;
-- no `local` keyword here.)
browserState = {
    expansion = nil,
    raidKey   = nil,
    bossIndex = nil,
    active    = false,
}

-- Transmog summary button (mouseover opens popup)
panel.transmog = CreateFrame("Button", nil, panel)
-- Tmog hover behavior ---------------------------------------------------
-- The transmog popup is shown on hover, but because it will gain dropdown
-- widgets that extend outside the popup's rectangle, we can't just hide on
-- the summary line's OnLeave. Instead:
--   * OnEnter on EITHER the summary line or the popup cancels any pending
--     hide.
--   * OnLeave on either schedules a short-grace hide.
-- This lets the user travel between the summary line and the popup, and
-- interact with dropdown menus that pop out from the popup, without the
-- popup collapsing under them.
local TMOG_HIDE_GRACE = 0.25   -- seconds

local tmogHideTimer
local function CancelTmogHide()
    if tmogHideTimer then
        tmogHideTimer:Cancel()
        tmogHideTimer = nil
    end
end
local function ScheduleTmogHide()
    -- In browser mode the popup is pinned; don't even arm a hide timer.
    if browserState.active then return end
    CancelTmogHide()
    tmogHideTimer = C_Timer.NewTimer(TMOG_HIDE_GRACE, function()
        tmogHideTimer = nil
        -- Re-check at fire time: user may have pinned the popup during
        -- the grace window (e.g. by clicking the summary line).
        if browserState.active then return end
        local w = tmogWindow
        if not w or not w:IsShown() then return end
        -- Don't hide if the cursor ended up over the popup or summary.
        if w:IsMouseOver() then return end
        if panel.transmog:IsMouseOver() then return end
        w:Hide()
    end)
end

panel.transmog:SetPoint("TOPLEFT", panel.encounter, "BOTTOMLEFT", 0, -8)
panel.transmog:SetSize(BODY_WIDTH, 14)
-- The summary line is click-only: clicking toggles the browser popup open/closed.
-- We deliberately do NOT open on hover -- the dropdowns make that behavior
-- hostile (mouse-leave would close the popup mid-interaction), and the
-- [click to browse] hint in the label makes the click affordance discoverable.
panel.transmog:SetScript("OnEnter", function(self)
    self.label:SetTextColor(1.0, 0.85, 0.0, 1.0)   -- hover highlight only
end)
panel.transmog:SetScript("OnLeave", function(self)
    self.label:SetTextColor(1.0, 1.0, 1.0, 1.0)
end)
panel.transmog:RegisterForClicks("LeftButtonUp")
panel.transmog:SetScript("OnClick", function()
    -- Clicking the summary line ALWAYS refreshes the browser to the
    -- player's current boss. Rationale: the summary line is tied to the
    -- current boss's stats; clicking it and getting a different boss's
    -- loot would be surprising. The /rr tmog command, by contrast,
    -- preserves the last-browsed selection.
    if RR.currentRaid and RR.state.activeStep then
        browserState.expansion = RR.currentRaid.expansion
        browserState.raidKey   = RR.currentRaid.instanceID
        browserState.bossIndex = RR.state.activeStep.bossIndex
    end
    UI.ToggleTransmogBrowser()
end)
panel.transmog.label = panel.transmog:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.transmog.label:SetPoint("LEFT", 0, 0)
panel.transmog.label:SetWidth(BODY_WIDTH)
panel.transmog.label:SetJustifyH("LEFT")
-- Proxy SetText/SetShown/Hide/GetHeight to the label for compatibility
panel.transmog.SetText   = function(self, t) self.label:SetText(t) end
panel.transmog.GetHeight = function(self) return self.label:GetHeight() end

panel.listHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
panel.listHeader:SetPoint("TOPLEFT", panel.transmog, "BOTTOMLEFT", 0, -12)
panel.listHeader:SetWidth(BODY_WIDTH)
panel.listHeader:SetJustifyH("LEFT")

panel.list = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.list:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, -8)
panel.list:SetWidth(BODY_WIDTH)
panel.list:SetJustifyH("LEFT")
panel.list:SetJustifyV("TOP")

-- Pool of invisible Button overlays for the expand/collapse toggles in
-- the idle-state supported-raids list and run-complete state's "Where
-- to next" list. Each Button is positioned over the toggle marker on a
-- specific line of panel.list, scaled to cover the texture glyph plus
-- a small hit-zone padding. Created lazily on demand and parked on
-- the side when not needed (Hide()'d, but kept in the pool for reuse
-- on the next refresh so we're not creating frames in a tight loop).
--
-- Why a separate Button pool instead of FontString hyperlinks: the
-- panel's draggable LeftButton + invisible overlay buttons in the
-- middle of the layout (panel.encounter, panel.transmog) compete
-- with hyperlink hit detection in WoW's mouse dispatch. Hyperlinks
-- on the topmost line specifically end up needing two clicks to
-- register because the first click is consumed by another hit
-- target. Using dedicated Button frames sidesteps the issue
-- entirely -- Button click handling is the most reliable path
-- through WoW's mouse system.
panel.expansionToggleButtons = {}
panel.expansionToggleButtonPool = {}

-- Entrance-navigation buttons. One per raid that has entrance data,
-- anchored to the right end of the raid-name row's FontString. Click
-- drops a TomTom (preferred) or native Blizzard waypoint at the raid's
-- outdoor entrance coords. Pool / lifecycle mirrors the expansion
-- toggle buttons exactly -- created lazily, recycled per refresh, never
-- destroyed -- because the raids list rebuilds fully on every refresh.
panel.entranceButtons = {}
panel.entranceButtonPool = {}

-- Borrow a Button from the pool, creating one if the pool is empty.
-- Returned Buttons are blank/Hide()n; callers configure and Show().
--
-- The button OWNS its visible glyph (SetNormalTexture / SetPushedTexture /
-- SetHighlightTexture). Previously the visible glyph was a |T...|t
-- marker baked into panel.list's text, with this Button sitting as
-- an invisible click-overlay above it. That two-piece design was the
-- root cause of the "multi-click to expand" bug: if the click overlay
-- drifted relative to the rendered text (uneven line heights when
-- mixing textures with text glyphs, accumulated stride drift on
-- deeper lines, etc.), the user clicked where they SAW a glyph but
-- the click landed on empty space.
--
-- One-piece design: the button IS the glyph. They cannot desync
-- because they're the same widget. The button anchors to the left
-- of the raid name so its placement is independent of how the name
-- renders.
local function AcquireExpansionToggleButton()
    local btn = table.remove(panel.expansionToggleButtonPool)
    if btn then return btn end
    btn = CreateFrame("Button", nil, panel)
    -- Width / height set per-call from current font size in
    -- PositionExpansionToggleButton, so the glyph scales with the
    -- user's font setting.
    btn:RegisterForClicks("LeftButtonUp")
    -- Bump frame level so toggle buttons sit above any other panel
    -- children at the same screen position.
    btn:SetFrameLevel((panel:GetFrameLevel() or 0) + 10)
    return btn
end

-- Apply the expanded/collapsed texture set to a button. Called from
-- PositionExpansionToggleButton; separate so a click handler could
-- swap textures without re-positioning if we ever wanted that.
--
-- Pushed texture uses the Down variant for visual feedback when
-- clicking. Highlight texture is the same Highlight variant Blizzard
-- uses for native plus/minus buttons.
local function SetToggleButtonTextures(btn, expanded)
    local upTex, downTex
    if expanded then
        upTex   = "Interface\\Buttons\\UI-MinusButton-Up"
        downTex = "Interface\\Buttons\\UI-MinusButton-Down"
    else
        upTex   = "Interface\\Buttons\\UI-PlusButton-Up"
        downTex = "Interface\\Buttons\\UI-PlusButton-Down"
    end
    btn:SetNormalTexture(upTex)
    btn:SetPushedTexture(downTex)
    btn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
end

-- Return all currently-active toggle Buttons to the pool. Called
-- before each idle-state refresh so the next refresh can reposition
-- a fresh set without leaking widgets.
local function ReleaseExpansionToggleButtons()
    for _, btn in ipairs(panel.expansionToggleButtons) do
        btn:Hide()
        btn:SetScript("OnClick", nil)
        btn:SetScript("OnEnter", nil)
        btn:ClearAllPoints()
        table.insert(panel.expansionToggleButtonPool, btn)
    end
    wipe(panel.expansionToggleButtons)
end

-- Position a toggle Button alongside its expansion-header FontString.
-- The button anchors to the LEFT of the FontString, sized to match the
-- current font height. When the FontString moves (because lines above
-- it changed), the button moves with it -- no measurement, no drift.
--
-- This replaced an earlier line-index + measured-line-height design
-- that had the button anchored to panel.list's TOPLEFT with a
-- computed y-offset. That design relied on the rendered line stride
-- matching the arithmetic estimate; it didn't always, especially for
-- short lists where small per-line errors didn't average out. Symptom:
-- the second expansion's button drifted further from its text label
-- than the first. Anchoring to the actual rendered widget eliminates
-- the entire bug class.
local function PositionExpansionToggleButton(btn, parentFS, expanded)
    local fontSize = RR:GetSetting("fontSize", 12)
    -- Square button at font-size dimensions so the glyph scales with
    -- the user's text size setting and stays visually proportional to
    -- the expansion name beside it.
    btn:SetSize(fontSize, fontSize)
    SetToggleButtonTextures(btn, expanded)
    btn:ClearAllPoints()
    -- Anchor to the LEFT of the expansion-header FontString. The
    -- header text starts with leading-space padding (see emitExpansion
    -- in BuildIdleListRows) so the button has visual room without
    -- overlapping the text. Vertical alignment is automatic -- the
    -- CENTER-of-button to LEFT-of-text anchor pair stays in sync no
    -- matter where the FontString ends up vertically.
    btn:SetPoint("LEFT", parentFS, "LEFT", 0, 0)
end

-- Acquire / configure / position an entrance-navigation button. Same
-- pool / lifecycle pattern as the expansion-toggle buttons (anchor to
-- the row's FontString to avoid line-stride drift). The button uses
-- a yellow taxi/flight icon to read as "travel to" and is anchored
-- just to the right of the raid-name FontString text.
local function AcquireEntranceButton()
    local btn = table.remove(panel.entranceButtonPool)
    if btn then return btn end
    btn = CreateFrame("Button", nil, panel)
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetFrameLevel((panel:GetFrameLevel() or 0) + 10)
    -- FlightMaster minimap tracking icon -- a flight-master silhouette
    -- with a subtle gold glow. Reads as "travel destination" similar
    -- to the prior taxi-icon-yellow but with a slightly more
    -- recognizable shape at small sizes (the boot-on-its-side
    -- silhouette is harder to parse than the FlightMaster figure).
    -- Highlight texture gives mouseover feedback in ADD blend mode.
    --
    -- Routing-vs-waypoint tier signal is conveyed via the button's
    -- alpha (1.0 routing, 0.4 waypoint) -- set at the click-handler
    -- setup site in RefreshIdleList. An earlier attempt to add a
    -- blue glow halo behind the icon was abandoned after three
    -- failed iterations: BACKGROUND-layer textures rendered behind
    -- the panel backdrop (invisible); ARTWORK + ADD blend rendered
    -- nothing on transparent surrounding pixels; ARTWORK + BLEND
    -- with IconAlert texture rendered as a visible-but-rectangular
    -- box that washed out the icon instead of haloing it. The
    -- alpha-difference signal already conveys tier visibly enough.
    btn:SetNormalTexture("Interface\\Minimap\\Tracking\\FlightMaster")
    btn:SetHighlightTexture(
        "Interface\\Minimap\\Tracking\\FlightMaster", "ADD")
    return btn
end

local function ReleaseEntranceButtons()
    for _, btn in ipairs(panel.entranceButtons) do
        btn:Hide()
        btn:SetScript("OnClick", nil)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        btn:ClearAllPoints()
        table.insert(panel.entranceButtonPool, btn)
    end
    wipe(panel.entranceButtons)
end

local function PositionEntranceButton(btn, parentFS)
    local fontSize = RR:GetSetting("fontSize", 12)
    -- Slightly larger than the toggle buttons (1.4x) since the taxi
    -- icon's recognizable shape needs room to read clearly. Anchored
    -- at the right-edge of the FontString's STRING WIDTH (not the
    -- FontString's frame width, which spans the whole panel column);
    -- using GetStringWidth keeps the button snug against the actual
    -- end of the text regardless of how long or short the raid name is.
    local size = math.floor(fontSize * 1.4)
    btn:SetSize(size, size)
    btn:ClearAllPoints()
    btn:SetPoint("LEFT", parentFS, "LEFT",
        (parentFS:GetStringWidth() or 0) + 4, 0)
end

-- Frameless toast popup anchored to a parent frame. Used for
-- branch-specific feedback on the silent waypoint paths of
-- NavigateToEntrance: the player clicks the entrance button, a pin
-- (Blizzard or TomTom) appears on the world map, but no other UI
-- element confirms "yes, that click did something" inside the addon
-- panel where the click happened. This brief fade-in / hold / fade-
-- out toast fills that gap.
--
-- "Frameless" means a single FontString on a transparent host frame
-- (no backdrop, no border). Anchored to the clicked button so the
-- feedback appears spatially next to where the user's eye already
-- is, reinforcing cause and effect without pulling attention.
--
-- Implementation note: an earlier attempt used a CreateAnimationGroup
-- + Alpha animations with SetFromAlpha/SetToAlpha and OnFinished. It
-- didn't render. Rather than debug Blizzard's animation system, this
-- version drives the alpha manually via C_Timer.NewTicker -- more
-- code, but trivially debuggable and known-working. The total budget
-- (~2.2s, ~28 frames at the 80ms tick rate) is well under the cost
-- threshold where ticker overhead would matter.
--
-- Lifecycle: each call creates a fresh FontString-bearing frame on
-- UIParent. Cheap: toasts fire only on user click, so frame creation
-- is bounded by user input rate. The frame self-hides at the end of
-- the fade-out and is left for GC.
local function ShowWaypointToast(anchorFrame, text)
    if not anchorFrame or not text then return end

    local toast = CreateFrame("Frame", nil, UIParent)
    toast:SetFrameStrata("TOOLTIP")  -- above the addon panel
    toast:SetSize(180, 18)
    toast:ClearAllPoints()
    -- Due east of the button: LEFT of the toast anchored to RIGHT
    -- of the button, no vertical offset. Lines up with the button's
    -- vertical center so the toast reads as "the click that just
    -- happened, with confirmation immediately to the right." A small
    -- +6 horizontal offset gives breathing room between the button's
    -- edge and the start of the text.
    toast:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)

    local fs = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("LEFT", toast, "LEFT", 0, 0)
    fs:SetText("|cffffd700" .. text .. "|r")  -- gold for friendly notice
    fs:SetJustifyH("LEFT")

    -- Start invisible. Set alpha BEFORE Show() so the first rendered
    -- frame is at alpha 0, not at the default alpha 1.
    toast:SetAlpha(0)
    toast:Show()

    -- Manual alpha schedule. Tick at 50ms (20 Hz) for visibly smooth
    -- fades. Ramp segments: 0.10s fade-in (2 ticks), 1.50s hold
    -- (30 ticks), 0.60s fade-out (12 ticks). The starting tick = 0,
    -- so the math works out to 44 ticks total.
    local FADE_IN_TICKS  = 2
    local HOLD_TICKS     = 30
    local FADE_OUT_TICKS = 12
    local TOTAL_TICKS    = FADE_IN_TICKS + HOLD_TICKS + FADE_OUT_TICKS

    local tickIndex = 0
    local ticker
    ticker = C_Timer.NewTicker(0.05, function()
        tickIndex = tickIndex + 1
        local alpha
        if tickIndex <= FADE_IN_TICKS then
            alpha = tickIndex / FADE_IN_TICKS
        elseif tickIndex <= FADE_IN_TICKS + HOLD_TICKS then
            alpha = 1
        else
            local fadeOutPos = tickIndex - (FADE_IN_TICKS + HOLD_TICKS)
            alpha = 1 - (fadeOutPos / FADE_OUT_TICKS)
        end
        if alpha < 0 then alpha = 0 end
        if alpha > 1 then alpha = 1 end
        toast:SetAlpha(alpha)
        if tickIndex >= TOTAL_TICKS then
            ticker:Cancel()
            toast:Hide()
        end
    end, TOTAL_TICKS)
end

-- ---------------------------------------------------------------------------
-- Per-line FontString pool for the idle/run-complete supported-raids list
-- ---------------------------------------------------------------------------
--
-- The supported-raids list used to render as one big multi-line string
-- inside panel.list. That worked for plain content but made it
-- impossible to position toggle Buttons reliably -- the buttons had
-- to anchor to panel.list's TOPLEFT and walk down by computed line
-- offsets, and any error in the line-height arithmetic accumulated
-- across rows. Result: the second/third expansion's toggle button
-- drifted further and further from its text label.
--
-- The pool below replaces that with per-line FontStrings. Each rendered
-- line is its own widget, anchored BOTTOMLEFT-of-previous so they stack
-- top-down naturally. Toggle Buttons anchor to their expansion-header
-- FontString's LEFT, so the two move together no matter what.
--
-- Pool semantics: `panel.idleListLines` is the active list (in render
-- order, used to drive AutoSize bottom-of-list calculations).
-- `panel.idleListLinePool` is the recycle bin; FontStrings are pushed
-- there on Release and popped on Acquire.
--
-- Legend rows (skip + entrance keys) live in a parallel
-- `panel.idleListLegendLines` array. They share the same pool and
-- the same FontString lifecycle but are tracked separately so
-- AutoSize doesn't include their height in the path-(b) budget --
-- the legend block is already accounted for in the footerReserve
-- via breathingRoom.
panel.idleListLines        = {}
panel.idleListLegendLines  = {}
panel.idleListLinePool     = {}

-- Acquire a FontString for the next line. Caller is responsible for
-- ClearAllPoints() + SetText() + SetPoint() + Show().
local function AcquireIdleListLine()
    local fs = table.remove(panel.idleListLinePool)
    if fs then return fs end
    fs = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetJustifyH("LEFT")
    fs:SetWidth(BODY_WIDTH)
    return fs
end

-- Return all currently-active line FontStrings to the pool. Hides them
-- and clears their anchors so a fresh layout pass starts cleanly.
local function ReleaseIdleListLines()
    for _, fs in ipairs(panel.idleListLines) do
        fs:Hide()
        fs:ClearAllPoints()
        fs:SetText("")
        -- Clear the _nextGap sentinel used by the spacer-handling
        -- code in RefreshIdleList. Without this, a FontString that
        -- was the final row before a spacer in a prior render
        -- carries SPACER_GAP=6 into the pool. The NEXT render that
        -- recycles this FontString -- for any row, anywhere -- would
        -- then anchor its successor row with SPACER_GAP instead of
        -- ROW_GAP, producing a 4px-too-large gap below a single row
        -- somewhere in the middle of the list. The exact row depends
        -- on pool acquisition order, which is why this bug presents
        -- as "one weird gap somewhere" rather than a systemic stride
        -- issue.
        fs._nextGap = nil
        table.insert(panel.idleListLinePool, fs)
    end
    wipe(panel.idleListLines)
    for _, fs in ipairs(panel.idleListLegendLines) do
        fs:Hide()
        fs:ClearAllPoints()
        fs:SetText("")
        fs._nextGap = nil
        table.insert(panel.idleListLinePool, fs)
    end
    wipe(panel.idleListLegendLines)
end

-- In-raid "Boss Progress" checklist: per-line FontString pool, same
-- architecture as the idle-list pool above. Each visible boss row is
-- its own FontString, anchored top-down via BOTTOMLEFT-of-previous
-- chains. The pool exists in parallel rather than sharing
-- idleListLinePool because the two surfaces have different lifecycles
-- (in-raid vs idle/run-complete) and different release triggers, and
-- the parallel design makes the ownership obvious in tracebacks.
panel.progressListLines    = {}
panel.progressListLinePool = {}

local function AcquireProgressListLine()
    local fs = table.remove(panel.progressListLinePool)
    if fs then return fs end
    fs = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetJustifyH("LEFT")
    fs:SetWidth(BODY_WIDTH)
    return fs
end

local function ReleaseProgressListLines()
    for _, fs in ipairs(panel.progressListLines) do
        fs:Hide()
        fs:ClearAllPoints()
        fs:SetText("")
        table.insert(panel.progressListLinePool, fs)
    end
    wipe(panel.progressListLines)
end

-- Footer (two rows, bottom-up):
--   Bottom row: "Created by Photek" on the left, version on the right,
--               anchored 8px up from the panel's bottom edge.
--   Action row: Map / Tmog / Skips / Settings buttons, anchored above
--               the credit row with a small gap. Standard Blizzard
--               UIPanelButtonTemplate buttons; centered horizontally.
--
-- The previous design used two TEXT rows here (a slash-command bar like
-- "/rr - Toggle | /rr settings | /rr reset | /rr tmog" plus a tagline
-- "Designed for max-level characters running legacy content."). Both
-- were promoted to actual buttons (the slash commands) and dropped
-- entirely (tagline -- redundant once the panel feels action-y rather
-- than informational). The action-button row is more discoverable than
-- a slash-command reference and matches modern WoW addon conventions.
--
-- AutoSize reserves vertical space for both rows via PANEL_FOOTER_RESERVE.
panel.credit = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.credit:SetPoint("BOTTOMLEFT", PAD_LEFT, 8)
panel.credit:SetText("Created by |cff4DCCFFPhotek|r")
-- Footer credit is locked to 04B_03 per the body-font scope rule:
-- header + footer + action buttons stay retro regardless of the user's
-- bodyFontStyle setting. Applied once at construction; the ApplySettings
-- targets table no longer touches this widget.
panel.credit:SetFont(TITLE_FONT, 10, "")
panel.credit:SetShadowOffset(1, -1)
panel.credit:SetShadowColor(0, 0, 0, 1)

-- Right-side footer cluster: "What's New? [!] [v1.10.2]"
--
-- Layout (right-to-left from the panel's BOTTOMRIGHT):
--   panel.version          - clickable Button widget. Child FontString renders
--                            the bracketed version "[v1.10.2]" in link-cyan
--                            (matching the [ i ] convention in the Skips
--                            window). Click opens the What's New window.
--   panel.whatsNewLabel    - "What's New?" prefix, plus a pulsing yellow [!]
--                            until the player clicks the version link. The
--                            [!] is dropped from the label on first-ever
--                            click (account-wide). Text is rewritten each
--                            tick by the existing UI pulse driver so the
--                            [!] breathes the same way the encounter-card
--                            [!] does.
panel.version = CreateFrame("Button", nil, panel)
panel.version:SetSize(70, 14)
panel.version:SetPoint("BOTTOMRIGHT", -PAD_RIGHT, 8)
panel.version.glyph = panel.version:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.version.glyph:SetPoint("RIGHT", panel.version, "RIGHT", 0, 0)
panel.version.glyph:SetText("|cff7faaff[v" .. RetroRuns.VERSION .. "]|r")
-- Footer is locked branding -- the version glyph stays at FRIZQT 10px
-- regardless of the user's fontSize slider or bodyFontStyle setting.
-- Matches the rule that footer + header + action buttons are static
-- chrome (credit and whatsNewLabel are 04B_03 10px; version is the
-- one footer element that stays on Standard so the bracketed [v...]
-- reads as data rather than retro decoration). Applied once at
-- construction; ApplySettings no longer touches this widget.
panel.version.glyph:SetFont(BODY_FONT, 10, "")
-- Resize the button width to wrap the rendered text so the click target
-- doesn't extend past the visible "[v...]" glyph.
panel.version:SetWidth((panel.version.glyph:GetStringWidth() or 60) + 4)
-- Hover tint: brighten on enter, restore on leave. Mirrors the [ i ] icon
-- affordance pattern in the Skips window.
panel.version:SetScript("OnEnter", function(self)
    self.glyph:SetText("|cffffffff[v" .. RetroRuns.VERSION .. "]|r")
end)
panel.version:SetScript("OnLeave", function(self)
    self.glyph:SetText("|cff7faaff[v" .. RetroRuns.VERSION .. "]|r")
end)
panel.version:SetScript("OnClick", function()
    -- First-ever click clears the persistent dismissed flag and stops
    -- the [!] pulse. The flag is checked when rendering the label
    -- (see the pulse driver at the bottom of UI.lua).
    if RetroRunsDB then
        RetroRunsDB.whatsNewSeenVersion = RetroRuns.VERSION
    end
    -- Immediately rewrite the label so the [!] disappears even before
    -- the next ticker tick.
    if panel.whatsNewLabel then
        panel.whatsNewLabel:SetText("|cff9d9d9dWhat's New?|r")
    end
    if UI.ToggleWhatsNewWindow then UI.ToggleWhatsNewWindow() end
end)

panel.whatsNewLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.whatsNewLabel:SetPoint("RIGHT", panel.version, "LEFT", -4, 0)
panel.whatsNewLabel:SetText("|cff9d9d9dWhat's New?|r")
-- Locked to 04B_03 (footer chrome). The pulse ticker at the bottom of
-- this file rewrites this FontString's text every ~100ms via SetText;
-- SetText preserves the font, so a single SetFont here sticks across
-- the lifetime of the addon.
panel.whatsNewLabel:SetFont(TITLE_FONT, 10, "")
panel.whatsNewLabel:SetShadowOffset(1, -1)
panel.whatsNewLabel:SetShadowColor(0, 0, 0, 1)

-- Action button row. Five UIPanelButtonTemplate buttons, evenly
-- horizontally distributed across the panel width with a small gap
-- between each. Anchored above the credit/version row with enough
-- vertical breathing room to read as a separate band rather than
-- crowding the byline.
--
-- Order (left to right): Map, Tmog, Achieves, Skips, Settings. Map is
-- the primary in-raid action; Tmog / Achieves / Skips are reference
-- views grouped together; Settings is config. "Achieves" rather than
-- "Achievements" so the label fits the same 70px button width as the
-- others without font shrinkage.
--
-- panel.mapBtn keeps the same name as the previous header-button
-- version so existing Enable/Disable state-handling code (the in-raid
-- vs out-of-raid logic in UI.Update) continues to work without
-- modification. Same for panel.tmogBtn -- no rename means no caller
-- updates needed.
local BUTTON_W   = 70
local BUTTON_H   = 22
local BUTTON_GAP = 6
local TOTAL_W    = BUTTON_W * 5 + BUTTON_GAP * 4
local START_X    = math.floor((PANEL_W - TOTAL_W) / 2)
local BUTTON_Y   = 28   -- pixels up from the panel's bottom edge

local function MakeActionButton(name, label, x, onClick)
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(BUTTON_W, BUTTON_H)
    btn:SetPoint("BOTTOMLEFT", x, BUTTON_Y)
    btn:SetText(label)
    -- Font is applied via ApplyActionButtonFont after construction so a
    -- single helper handles both the initial paint and re-applying when
    -- the user toggles bodyFontStyle in settings.
    btn:SetScript("OnClick", onClick)
    return btn
end

-- Apply the retro pixel font to all five action button labels. The
-- action buttons are part of the addon's locked branding (alongside
-- the title bar, auxiliary window titles, and footer chrome) and do
-- NOT participate in the bodyFontStyle toggle -- 04B_03 always, at
-- 12px with a shadow for legibility against the button gradient.
-- Called once after all 5 buttons are constructed.
local function ApplyActionButtonFont()
    for _, btn in ipairs({ panel.mapBtn, panel.tmogBtn, panel.achievesBtn,
                            panel.skipsBtn, panel.settingsBtn }) do
        if btn then
            local fs = btn:GetFontString()
            if fs then
                fs:SetFont(TITLE_FONT, 12, "")
                fs:SetShadowOffset(1, -1)
                fs:SetShadowColor(0, 0, 0, 1)
            end
        end
    end
end

panel.mapBtn = MakeActionButton("Map", "Map",
    START_X,
    function() RR:ShowCurrentMapForStep() end)

panel.tmogBtn = MakeActionButton("Tmog", "Tmog",
    START_X + (BUTTON_W + BUTTON_GAP) * 1,
    function()
        -- When in a supported raid, default the browser to that raid +
        -- current boss before opening (so the user sees their actual
        -- context rather than the last-browsed selection). Out of a
        -- raid, fall through to the preserved last-browsed state.
        if RR.currentRaid then
            browserState.expansion = RR.currentRaid.expansion
            browserState.raidKey   = RR.currentRaid.instanceID
            if RR.state and RR.state.activeStep then
                browserState.bossIndex = RR.state.activeStep.bossIndex
            end
        end
        UI.ToggleTransmogBrowser()
    end)

panel.achievesBtn = MakeActionButton("Achieves", "Achieves",
    START_X + (BUTTON_W + BUTTON_GAP) * 2,
    function()
        -- When in a supported raid, default the dropdowns to that raid
        -- before opening (so the user sees their actual context rather
        -- than the last-browsed selection). Out of a raid, fall through
        -- to the preserved last-browsed state. Mirrors the tmog button.
        if RR.currentRaid then
            achState.expansion = RR.currentRaid.expansion
            achState.raidKey   = RR.currentRaid.instanceID
        end
        UI.ToggleAchievementsWindow()
    end)

panel.skipsBtn = MakeActionButton("Skips", "Skips",
    START_X + (BUTTON_W + BUTTON_GAP) * 3,
    function() UI.ToggleSkipsWindow() end)

panel.settingsBtn = MakeActionButton("Settings", "Settings",
    START_X + (BUTTON_W + BUTTON_GAP) * 4,
    function() UI.ToggleSettings() end)

-- Paint action button fonts once after all 5 buttons are constructed.
-- Static 04B_03 -- not tied to the bodyFontStyle toggle, so no need to
-- re-call on settings change. Buttons keep this font for the addon's
-- lifetime.
ApplyActionButtonFont()

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- ApplySettings + auto-sizing
--
-- Design note: the old approach had two independent sliders (font size and
-- window scale) and a fixed panel height. Users could easily pick a font
-- size that overflowed the frame. The fix is auto-sizing: after font/scale
-- are applied, the frame measures its current content and re-fits. The
-- sliders remain as user preferences, but the frame always accommodates
-- the content they produce.
--
-- Called after any change that affects rendered size (font, scale, content
-- reflow). Safe to call frequently -- cheap on modern hardware.
-------------------------------------------------------------------------------

-- Extra breathing room reserved below the last top-down widget. The main
-- panel needs room for the bottom stack (button row ~y=28-50, credit/
-- version ~y=8) plus a visual gap above the buttons separating them
-- from the dynamic content above. ~60px covers the layout with margin.
local PANEL_FOOTER_RESERVE   = 64   -- pixels
local POPUP_CONTENT_CEILING  = 600  -- transmog popup max height
local POPUP_CONTENT_MIN      = 240  -- transmog popup min height

-- Returns the pixel Y-distance from the panel top to the given widget's
-- bottom edge. Works regardless of how the widget is anchored because we
-- ask the widget for its own top-in-panel-space and add its measured
-- height.
local function ContentBottomY(parent, widget)
    if not widget then return 0 end
    -- Widget coords are relative to parent because all our widgets are
    -- parented to the panel. GetTop/GetBottom work in screen space; we
    -- normalize by the parent top.
    local parentTop = parent:GetTop() or 0
    local widgetBot = widget:GetBottom() or parentTop
    return parentTop - widgetBot
end

-- Sets a FontString's effective font + text safely and forces layout so
-- GetStringHeight/Width return updated values on the next frame.
-- (WoW font metrics are recomputed on the next render tick normally; we
-- can force the recomputation by poking SetWidth.)
local function ForceFontRelayout(fs)
    if not fs then return end
    local w = fs:GetWidth()
    if w and w > 0 then fs:SetWidth(w) end
end

function UI.ApplySettings()
    -- Pre-init guard: don't apply settings before SavedVariables loads.
    -- (GetSetting handles nil DB by returning defaults, but we want to
    -- be a true no-op pre-init rather than apply default scale/font on
    -- the un-initialized panel.)
    if not RetroRunsDB then return end

    local scale = RR:GetSetting("windowScale", 1.0)
    panel:SetScale(scale)

    SafeSetFont(panel.titleRetro, TITLE_FONT, TITLE_SIZE, "OUTLINE")
    SafeSetFont(panel.titleRuns,  TITLE_FONT, TITLE_SIZE, "OUTLINE")

    local bump = RR:GetSetting("fontSize", 12) - 12
    -- Each entry is { widget, baseSize, flags, useBodyFontStyle? }. The
    -- optional 4th element (truthy) routes the font through GetBodyFont
    -- so the entry respects the user's bodyFontStyle setting (04B_03 /
    -- Pixel Operator / Standard). Entries without the flag always use
    -- BODY_FONT (FRIZQT).
    --
    -- Scope rule for the bodyFontStyle toggle: everything in the panel
    -- body participates; header chrome (titleRetro/titleRuns, mode),
    -- footer chrome (credit, whatsNewLabel), version glyph, and the
    -- action button row are locked to their construction-time fonts
    -- and NOT routed through targets. The action buttons use 04B_03
    -- always (handled by ApplyActionButtonFont above); credit and
    -- whatsNewLabel are 04B_03, version.glyph is FRIZQT, mode is
    -- 04B_03 -- all set at construction. Only widgets that the user
    -- reads as "panel content" appear in this table.
    local targets = {
        { panel.raid,       14, "",        true },
        { panel.pills,      11, "",        true },
        { panel.progress,   14, "OUTLINE", true },
        { panel.next,       14, "OUTLINE", true },
        { panel.travel,     12, "",        true },
        { panel.encounter.header.label,       12, "", true },
        { panel.encounter.achievements.label, 12, "", true },
        { panel.encounter.specialLoot.label,  12, "", true },
        { panel.transmog.label, 12, "",    true },
        { panel.listHeader, 12, "OUTLINE", true },
        { panel.list,       12, "",        true },
    }
    -- ForceFontRelayout is needed for FontStrings whose `GetStringHeight`
    -- gets read by AutoSize (so the panel re-fits around the bumped font
    -- on the same frame). It works by calling fs:SetWidth(fs:GetWidth())
    -- to poke the layout system, which is fine when the FontString already
    -- has an explicit width or two horizontal anchors -- in those cases
    -- the width returned by GetWidth IS the constraint width.
    --
    -- It is HARMFUL for FontStrings that size to their content (single
    -- horizontal anchor, no SetWidth). Those return their natural rendered
    -- width from GetWidth(), and pinning that width via SetWidth pre-bump
    -- locks the FontString to the OLD font's render extent. When the font
    -- is then bumped larger, the text wraps (left-anchored case) or
    -- truncates with an ellipsis (right-anchored case).
    --
    -- Currently no targets need to skip relayout (all entries are
    -- body widgets with explicit widths or stable anchoring). The
    -- footer chrome -- credit, whatsNewLabel, version.glyph -- is
    -- fonted at construction and not in this table at all.
    local skipRelayout = {}
    for _, t in ipairs(targets) do
        -- The 4th tuple element (truthy) opts the widget into the
        -- bodyFontStyle toggle: font choice from GetBodyFont, size
        -- scaled by the active font's per-font sizeFactor. Widgets
        -- without the flag stay on BODY_FONT (FRIZQT) at the literal
        -- baseSize -- those are widgets that don't participate in the
        -- toggle (e.g., the version glyph).
        --
        -- Body-toggle widgets also get a 1px black shadow applied,
        -- matching SetBodyFont's contract. Pixel fonts at non-integer
        -- pixel sizes antialias glyph edges to partial opacity, which
        -- reads as "dim" against the dark backdrop -- the shadow
        -- restores perceived contrast. Cheap to apply unconditionally
        -- since shadow state persists across SetFont calls without
        -- being reset.
        local size = math.max(8, t[2] + bump)
        local font
        if t[4] then
            font = GetBodyFont()
            size = GetBodyFontSize(size)
        else
            font = BODY_FONT
        end
        SafeSetFont(t[1], font, size, t[3])
        if t[4] then
            t[1]:SetShadowOffset(1, -1)
            t[1]:SetShadowColor(0, 0, 0, 1)
        end
        if not skipRelayout[t[1]] then
            ForceFontRelayout(t[1])
        end
    end

    -- Ancillary frames: popup and settings panel aren't parented to panel,
    -- so they don't inherit SetScale. Apply the same scale to the popup
    -- directly so the whole addon feels consistent to the user.
    --
    -- NOTE: the settings panel deliberately does NOT scale. It's the
    -- control surface the user is touching while dragging the scale
    -- slider -- scaling the thing being dragged causes mouse-drag stutter
    -- as the hitbox moves under the cursor each tick. Settings panel
    -- stays at 1.0x so the user has a stable target to adjust from.
    if tmogWindow then
        tmogWindow:SetScale(scale)
        -- Apply the font size directly to the popup's text without
        -- re-running RefreshContent -- the content (text/line count) hasn't
        -- changed, only the font size, so there's no need to re-invoke
        -- BuildTransmogDetail or SetText on every heartbeat tick. That was
        -- triggering the visible auto-adjust reflow once per second.
        if tmogWindow.contentText then
            local fontSize = RR:GetSetting("fontSize", 12)
            SetBodyFont(tmogWindow.contentText, fontSize - 1, "")
        end
    end

    -- Skips window: same scale treatment as tmog. Unlike tmog, the skips
    -- window's content is per-row widgets at fixed y-offsets, so changing
    -- font size requires re-running RefreshContent to recompute the
    -- y-cursor and reposition rows. Only do this if the window is
    -- currently shown -- if it's hidden, the next OpenSkipsWindow will
    -- pick up the new size on its own.
    if skipsWindow then
        skipsWindow:SetScale(scale)
        if skipsWindow:IsShown() and skipsWindow.RefreshContent then
            skipsWindow.RefreshContent()
        end
    end
    -- Achievements window: scale applied like the others. The current
    -- placeholder content is a single FontString; once real content
    -- (per-achievement rows) lands, this may want a RefreshContent call
    -- like skips does, or a font-only update like tmog does.
    if achievementsWindow then
        achievementsWindow:SetScale(scale)
        -- Achievements window uses a row pool (one frame per row, like
        -- skips), not a single FontString. Font-size changes affect row
        -- spacing and per-cell font metrics, so a full RefreshContent is
        -- the simplest way to apply -- it rebuilds row positioning with
        -- the new font size.
        if achievementsWindow:IsShown() and achievementsWindow.RefreshContent then
            achievementsWindow:RefreshContent()
        end
    end
    -- (intentionally no scale applied to settingsFrame)

    -- Apply panel opacity. Reads the current backdrop RGB from each window
    -- and substitutes the alpha channel only -- text and other content
    -- stay full-opacity for legibility. The base RGB happens to be the
    -- same dark grey across all four windows today (0.03/0.03/0.03), but
    -- reading from the live backdrop instead of hardcoding keeps this
    -- correct if a window's backdrop tint changes in the future.
    local opacity = RR:GetSetting("panelOpacity", 1.0)
    local function ApplyOpacity(frame)
        if not frame then return end
        local r, g, b = frame:GetBackdropColor()
        if r then frame:SetBackdropColor(r, g, b, opacity) end
    end
    ApplyOpacity(panel)
    ApplyOpacity(tmogWindow)
    ApplyOpacity(skipsWindow)
    ApplyOpacity(achievementsWindow)
    ApplyOpacity(settingsFrame)

    -- Re-fit the panel + auxiliary frames now that fonts and scale changed.
    -- AutoSize computes heights from line counts (not GetStringHeight) so a
    -- single synchronous pass is sufficient -- no deferred re-measure pass
    -- needed, which eliminates the visible pop-in flicker.
    UI.AutoSize()

    -- Re-run the idle list refresh so its expansion-toggle Buttons resize
    -- to the new font setting. Toggle pixel dimensions are a function of
    -- fontSize (applied in PositionExpansionToggleButton during refresh),
    -- so without this, the +/- glyphs stay at their previous size until
    -- some other event triggers a refresh -- visible as the toggles not
    -- scaling when the user moves the font slider.
    --
    -- Only fires when the idle list is actually currently rendered. The
    -- distinguishing signal is panel.idleListLines: the in-raid render
    -- path calls ReleaseIdleListLines() which empties this array, while
    -- the idle render path populates it with one FontString per row.
    -- Earlier guards used `panel.list:GetText()` which is truthy in BOTH
    -- states (the in-raid Boss Progress checklist also lives in
    -- panel.list), so during continuous slider drag this incorrectly
    -- triggered an idle-list rebuild on top of the in-raid view --
    -- visible as the Boss Progress checklist briefly flipping to
    -- expansion-header rows on every drag tick.
    --
    -- RefreshIdleList itself is a local function in this file (defined
    -- later); it's safe to call here because Lua resolves upvalues at
    -- call-time, not definition-time.
    --
    -- Avoid calling UI.Update here -- UI.Update itself calls
    -- ApplySettings, which would create an infinite recursion.
    if RefreshIdleList and #panel.idleListLines > 0 then
        RefreshIdleList()
    end

    -- Boss-Progress per-line FontStrings get their font applied during
    -- the in-raid render path's loop (which runs from UI.Update). On a
    -- font-slider drag, the existing on-screen FontStrings would
    -- otherwise keep their old size until the next UI.Update tick.
    -- Re-apply the font in place. No relayout needed -- the rows are
    -- anchored to each other, not measured-line-height, so font changes
    -- flow through the chain without rebuilding.
    if #panel.progressListLines > 0 then
        local progFontSize = RR:GetSetting("fontSize", 12)
        for _, fs in ipairs(panel.progressListLines) do
            SetBodyFont(fs, progFontSize, "")
        end
    end
end

-- =============================================================================
-- Minimize / maximize
-- =============================================================================
--
-- Minimized mode renders the panel as a tiny title-bar (logo + RETRO RUNS
-- text + minimize/close buttons), with all body fields and footer action
-- buttons hidden. Toggle via the minimize button to the left of the close X.
-- Persists across /reload via the `minimized` setting in RetroRunsDB.
--
-- The minimized panel height is fixed at MINIMIZED_PANEL_H. AutoSize is a
-- no-op while minimized, so subsequent UI.Update calls don't override the
-- fixed height. Maximizing flips the setting back, re-shows everything,
-- and falls through to the normal AutoSize path.
--
-- Top-pin behavior matches AutoSize: the panel's top edge stays at the
-- same screen position across the resize, so the panel doesn't visually
-- jump when minimizing/maximizing -- it grows/shrinks downward from the
-- title bar.

-- Height of the minimized panel. The title bar is logo (34px) + small
-- vertical padding above (10px) + below (~6px) = ~50px. We use 44px:
-- the logo extends slightly below the panel's bottom edge by design,
-- which makes the bar feel less cramped than a flush 50.
local MINIMIZED_PANEL_H = 44

function UI.IsMinimized()
    return RR:GetSetting("minimized") and true or false
end

-- Inventory of panel.* elements that are body or footer (i.e. NOT the
-- title bar). Built lazily on first call so it picks up forward-declared
-- elements created later in this file. The title-bar inventory (logo,
-- titleRetro, titleRuns, closeButton, minimizeButton, mode) stays
-- visible regardless.
local function GetBodyAndFooterElements()
    local list = {
        panel.raid, panel.pills, panel.progress, panel.next,
        panel.travel, panel.encounter, panel.transmog,
        panel.listHeader, panel.list,
        panel.credit, panel.version, panel.whatsNewLabel,
        panel.mapBtn, panel.tmogBtn, panel.achievesBtn,
        panel.skipsBtn, panel.settingsBtn,
    }
    return list
end

-- Show or hide every body and footer element based on minimized state.
-- Also walks the dynamic FontString arrays (idleListLines etc.) since
-- those are populated by RefreshIdleList and need to follow the same
-- visibility rule. Pool tables (idleListLinePool etc.) hold inactive
-- frames that are already hidden by the pool mechanism, so we don't
-- touch those.
local function ApplyBodyVisibility(visible)
    for _, fs in ipairs(GetBodyAndFooterElements()) do
        if fs then
            if visible then fs:Show() else fs:Hide() end
        end
    end
    for _, fs in ipairs(panel.idleListLines or {}) do
        if visible then fs:Show() else fs:Hide() end
    end
    for _, fs in ipairs(panel.idleListLegendLines or {}) do
        if visible then fs:Show() else fs:Hide() end
    end
    for _, fs in ipairs(panel.progressListLines or {}) do
        if visible then fs:Show() else fs:Hide() end
    end
    for _, btn in ipairs(panel.expansionToggleButtons or {}) do
        if visible then btn:Show() else btn:Hide() end
    end
    for _, btn in ipairs(panel.entranceButtons or {}) do
        if visible then btn:Show() else btn:Hide() end
    end
end

-- Update the minimize button's texture based on current minimized state.
-- Two custom TGAs in Media/: MinimizeIcon (gold horizontal bar -- shown
-- when expanded, click to minimize) and MaximizeIcon (gold open square
-- -- shown when minimized, click to expand back). Texture swaps cover
-- both Normal and Pushed states so the pressed-frame transition uses
-- the same icon (no Blizzard-style "icon dimmed while pressed" effect
-- needed for a momentary toggle).
local function UpdateMinimizeIcon()
    if not panel.minimizeButton then return end
    local tex
    if UI.IsMinimized() then
        tex = "Interface\\AddOns\\RetroRuns\\Media\\MaximizeIcon"
    else
        tex = "Interface\\AddOns\\RetroRuns\\Media\\MinimizeIcon"
    end
    panel.minimizeButton:SetNormalTexture(tex)
    panel.minimizeButton:SetPushedTexture(tex)
end

-- Compute the panel width needed to display just the title bar content
-- (logo + RETRO RUNS text + minimize button + close button) when
-- minimized. Read at apply-time rather than baked in as a constant
-- because the title text's rendered width depends on the font face
-- and OUTLINE flag, which could change via Settings or future
-- redesigns.
--
-- Returns nil if the title text hasn't yet been rendered (GetRight()
-- returns nil for un-rendered FontStrings). Caller should fall back
-- to a sensible default in that case.
local function ComputeMinimizedPanelW()
    if not panel.titleRuns then return nil end
    local titleRightAbs = panel.titleRuns:GetRight()
    local panelLeftAbs  = panel:GetLeft()
    if not titleRightAbs or not panelLeftAbs then return nil end
    -- Title's right edge in panel-local coords (distance from panel left)
    local titleRightLocal = titleRightAbs - panelLeftAbs
    -- Layout from the panel right edge:
    --   close button right edge at right-4 (TOPRIGHT -4,-4)
    --   close button visible glyph extends ~22px to its left = right-26
    --   minimize button at TOPRIGHT -30,-4 = right-30 to right-52
    -- So the buttons need ~52px of width on the right side.
    -- We want a small visual gap between the title text and the
    -- minimize button: 12px reads as compact but not crowded.
    local rightSideWidth   = 52
    local titleToButtonGap = 12
    return math.ceil(titleRightLocal + titleToButtonGap + rightSideWidth)
end

-- Default width to use if ComputeMinimizedPanelW can't measure (text
-- not yet rendered at first-call time after a fresh reload). 240px is
-- a reasonable fit for the current "RETRO RUNS" text at 12pt OUTLINE
-- with the standard font; close enough for a one-frame fallback before
-- the next UI.Update call (which fires within 1 second on the
-- heartbeat) re-measures and applies the precise width.
local MINIMIZED_PANEL_W_FALLBACK = 240

-- Apply the panel's height and visibility to match the current minimized
-- setting. The actual setting flip is done by SetMinimized below; this
-- helper just acts on whatever the setting currently says, so it can
-- also be called at restore-time (after /reload, when the saved setting
-- is loaded but the panel state hasn't been touched yet).
--
-- Called from UI.Update on every refresh (heartbeat + events). The
-- iteration covers ~25 elements; trivial cost at 1Hz. We don't
-- short-circuit on "state hasn't changed" because RefreshIdleList
-- (called later in UI.Update) acquires NEW FontStrings into
-- idleListLines that need to inherit the current minimized visibility,
-- and a short-circuit would leave them visible when we're minimized.
function UI.ApplyMinimizedState()
    local minimized = UI.IsMinimized()
    UpdateMinimizeIcon()
    ApplyBodyVisibility(not minimized)

    if minimized then
        -- Capture top + left edges before resize so we can re-anchor
        -- the panel to keep BOTH edges at the same screen position.
        -- Same pattern as AutoSize's TOP-PIN extended to also pin LEFT:
        -- SetHeight + SetWidth on a CENTER-anchored frame redistributes
        -- both deltas equally on each side, so without this the panel
        -- would visually jump in two directions when minimizing.
        local oldH = panel:GetHeight() or MINIMIZED_PANEL_H
        local oldW = panel:GetWidth() or PANEL_W
        local newH = MINIMIZED_PANEL_H
        local newW = ComputeMinimizedPanelW() or MINIMIZED_PANEL_W_FALLBACK
        local heightChanged = math.abs(newH - oldH) > 0.5
        local widthChanged  = math.abs(newW - oldW) > 0.5
        if heightChanged or widthChanged then
            local oldTop  = panel:GetTop()
            local oldLeft = panel:GetLeft()
            local fscale  = panel:GetEffectiveScale()
            local pscale  = UIParent:GetEffectiveScale()
            local pcx, pcy = UIParent:GetCenter()
            if heightChanged then panel:SetHeight(newH) end
            if widthChanged  then panel:SetWidth(newW)  end
            if oldTop and oldLeft and pcx and pcy then
                -- Compute new CENTER-anchor offsets that keep the old
                -- top edge AND old left edge at the same screen
                -- position. Both math derivations from the
                -- CENTER-anchor identity:
                --   panel.top  = panel.center.y + height/2
                --   panel.left = panel.center.x - width/2
                -- Solve for new center given old edge values + new
                -- dimensions. All in panel-local scaled units.
                local newCenterY = oldTop  - (newH / 2)
                local newCenterX = oldLeft + (newW / 2)
                -- Convert from panel-local screen pixels back to the
                -- ANCHORED frame's scaled coord system that SetPoint
                -- offsets use (NOT UIParent's, per Wowpedia "UI scaling")
                -- by dividing by fscale, not pscale.
                local y = (newCenterY * fscale - pcy * pscale) / fscale
                local x = (newCenterX * fscale - pcx * pscale) / fscale
                panel:ClearAllPoints()
                panel:SetPoint("CENTER", UIParent, "CENTER", x, y)
                RR:SetSetting("panelX", math.floor(x + 0.5))
                RR:SetSetting("panelY", math.floor(y + 0.5))
            end
        end
        -- If both dimensions are already at minimized values (steady-
        -- state per-heartbeat call after minimize completed), skip
        -- the resize entirely to keep the per-tick cost bounded.
    else
        -- Maximize-side: restore full width if we were minimized.
        -- Width handling is symmetric to the minimize path's LEFT-pin
        -- so the panel grows back rightward from its current left edge,
        -- not from center. Without this, a previously-minimized panel
        -- maximizing on the LEFT half of the screen would jump rightward
        -- as the center stayed fixed and the right edge expanded.
        local oldW = panel:GetWidth() or PANEL_W
        if math.abs(PANEL_W - oldW) > 0.5 then
            local oldLeft = panel:GetLeft()
            local fscale  = panel:GetEffectiveScale()
            local pscale  = UIParent:GetEffectiveScale()
            local pcx, _  = UIParent:GetCenter()
            panel:SetWidth(PANEL_W)
            if oldLeft and pcx then
                local newCenterX = oldLeft + (PANEL_W / 2)
                local x = (newCenterX * fscale - pcx * pscale) / fscale
                -- Re-apply X anchor; preserve Y by reading current Y
                -- offset from settings (AutoSize will overwrite Y next
                -- via its own TOP-pin path).
                local y = RR:GetSetting("panelY", 0)
                panel:ClearAllPoints()
                panel:SetPoint("CENTER", UIParent, "CENTER", x, y)
                RR:SetSetting("panelX", math.floor(x + 0.5))
            end
        end
        -- Falling through to AutoSize handles the maximize-side height
        -- resize. AutoSize does the same TOP-PIN math when the height
        -- changes, so the visual top-edge stability still applies.
        UI.AutoSize()
    end
end

-- Public toggle entry point. Used by the minimize button's OnClick.
-- Could also be called from a slash command in a future enhancement.
--
-- After flipping the setting, runs a full UI.Update so body-content
-- visibility state (e.g. encounter/transmog being explicitly Hide()'d
-- in idle state at the end of UI.Update) is re-asserted correctly when
-- maximizing. Without the explicit Update, ApplyBodyVisibility(true)
-- would briefly un-hide elements that should stay hidden in idle, and
-- they'd flicker until the next heartbeat tick (~1 second).
function UI.SetMinimized(value)
    RR:SetSetting("minimized", value and true or false)
    UI.Update()
end

-- Wire up the minimize button's OnClick now that SetMinimized exists.
panel.minimizeButton:SetScript("OnClick", function()
    UI.SetMinimized(not UI.IsMinimized())
end)

-- Resizes the main panel (and ancillary frames) to fit their current
-- content. Safe to call at any time; idempotent.
function UI.AutoSize()
    -- When minimized, the panel uses a fixed height set in
    -- UI.ApplyMinimizedState. AutoSize otherwise runs on every UI.Update
    -- and on font/scale changes; without this early-return it would
    -- override the fixed minimized height as soon as anything triggered
    -- a normal-mode resize calculation.
    if UI.IsMinimized() then return end

    -- MAIN PANEL -----------------------------------------------------------
    -- The top-down layout ends at either:
    --   (a) the bottom of the per-line FontStrings in
    --       panel.progressListLines (in-raid boss-progress checklist),
    --       OR
    --   (b) the bottom of the per-line FontStrings in panel.idleListLines
    --       (idle / run-complete supported-raids list).
    --
    -- The two pools are mutually exclusive in normal use -- the in-raid
    -- render path releases idle lines, and RefreshIdleList releases
    -- progress lines -- but AutoSize takes max() of both budgets as a
    -- safety net during transitions where both are briefly non-empty.
    -- panel.list (the legacy multi-line FontString) is kept empty in
    -- both states; it remains in the widget tree for compatibility with
    -- GetBodyAndFooterElements / ApplyMinimizedState which iterate it,
    -- but it no longer contributes to the height budget.
    local fontSize   = RR:GetSetting("fontSize", 12)
    -- Use the active body font's effective render size, not the raw
    -- fontSize. The user-configured fontSize is FRIZQT-baseline; when
    -- a font with a different sizeFactor (e.g. VT323 at 1.30) is
    -- active, the body widgets render TALLER than fontSize would
    -- suggest. AutoSize's listH budget needs to match the actual
    -- rendered row height or the panel grows by less than the list
    -- needs and rows overflow downward into the legend block.
    local lineHeight = GetBodyFontSize(fontSize) + 4

    local listH = 0
    local hasContent = false

    -- Path (a): per-line FontStrings in in-raid boss-progress checklist.
    -- Same arithmetic as path (b): one rowH per FontString plus inter-
    -- row gaps plus top spacing under listHeader.
    if #panel.progressListLines > 0 then
        local rowH      = lineHeight
        local gap       = 2
        local progressH = #panel.progressListLines * rowH
                        + (math.max(0, #panel.progressListLines - 1)) * gap
                        + 8  -- top spacing under listHeader
        listH = math.max(listH, progressH)
        hasContent = true
    end

    -- Path (b): per-line FontStrings in idle/run-complete list. Each
    -- FontString contributes one line of height plus its inter-row gap.
    -- Spacers are tracked via the _nextGap field on the prior FontString
    -- (see RefreshIdleList) -- adding fontSize per FontString plus a
    -- conservative 2px gap is close enough for AutoSize budgeting.
    if #panel.idleListLines > 0 then
        local rowH    = lineHeight
        local gap     = 2
        local idleH   = #panel.idleListLines * rowH
                      + (math.max(0, #panel.idleListLines - 1)) * gap
                      + 8  -- top spacing under listHeader
        listH = math.max(listH, idleH)
        hasContent = true
    end

    if hasContent then
        -- Footer reserve must accommodate three visual elements stacked
        -- from the panel's bottom edge:
        --   1. The credit/version text row (bottommost).
        --   2. The action-button row (UIPanelButtonTemplate, BUTTON_H
        --      tall, bottom edge at BUTTON_Y from the panel bottom).
        --   3. The legend block (skip + entrance keys), pinned just
        --      above the action row in RefreshIdleList's bottom-up
        --      legend pass. The legend block is at most 3 rows of
        --      LEGEND_FONT_SIZE=10 text (1 skip legend + 2 entrance
        --      legend rows) plus inter-row spacing.
        --
        -- The reserve = "buttons top edge from panel bottom" + room
        -- for the legend block. The 12px cushion BETWEEN the legend
        -- block and the action button row is already included in
        -- RefreshIdleList's LEGEND_BOTTOM_OFFSET (which positions the
        -- legend's bottom edge at buttonsTop + 12), so the reserve
        -- only needs to account for the legend block's own height
        -- on top of the buttons-from-bottom space.
        --
        -- Idle-mode breathingRoom is computed from the legend block's
        -- ACTUAL height at the active body font's sizeFactor. With
        -- FRIZQT (sizeFactor=1.0) the legend lineHeight is 14 and the
        -- worst-case block is exactly 50px (3*(10+4) + 2*4); with
        -- VT323 (sizeFactor=1.30) the lineHeight is ~17 and the block
        -- is ~59px. The previous hardcoded breathingRoom=50 worked at
        -- FRIZQT but overflowed at VT323, causing legend rows to
        -- bleed up into the bottom of the raid list. Compute the
        -- worst-case block at the active sizeFactor so the reserve
        -- scales with the user's font choice.
        --
        -- In-raid mode has no legend rows, so a fixed small cushion
        -- (~7px) between the last progress row and the action buttons
        -- is enough.
        local buttonsTopFromBottom = BUTTON_Y + BUTTON_H  -- = 50 at defaults
        local isInRaidMode         = #panel.progressListLines > 0
        local breathingRoom
        if isInRaidMode then
            breathingRoom = 7
        else
            -- 3 legend rows worst-case (skip + 2 entrance), each at
            -- lineHeight = GetBodyFontSize(LEGEND_FONT_SIZE=10) + 4px
            -- text-row padding. 2 inter-row gaps of LEGEND_INTER_GAP=4
            -- between the 3 rows.
            local legendLineHeight = GetBodyFontSize(10) + 4
            breathingRoom          = 3 * legendLineHeight + 2 * 4
        end
        local footerReserve        = buttonsTopFromBottom + breathingRoom

        local parentTop      = panel:GetTop()
        local listHeaderBot  = panel.listHeader and panel.listHeader:GetBottom()
        if parentTop and listHeaderBot then
            -- COORDINATE-SYSTEM NOTE: per Wowpedia "UI scaling",
            -- GetTop/GetBottom/GetHeight all return values in the
            -- FRAME's own scaled coordinate system, which is also what
            -- SetHeight expects. No division by scale needed for
            -- `desired`. The only scale conversion is for `maxH` since
            -- UIParent has a different effective scale than panel.
            local scale          = panel:GetScale() or 1
            local topToListTop   = (parentTop - listHeaderBot) + 4
            local desired        = topToListTop + listH + footerReserve
            local screenH        = UIParent:GetHeight() or 900
            local maxH           = (screenH * 0.9) / scale
            local minH           = 240
            local newH           = math.max(minH, math.min(maxH, desired))

            -- Capture geometry BEFORE SetHeight so we work with the
            -- pre-resize frame state. SetHeight on a CENTER-anchored
            -- frame moves the center immediately (WoW redistributes
            -- the delta equally above and below), so any GetCenter()
            -- call after SetHeight returns the shifted center, not the
            -- original one -- causing X to drift on every resize.
            local oldTop  = panel:GetTop()
            local oldH    = panel:GetHeight() or newH
            local fscale  = panel:GetEffectiveScale()
            local pscale  = UIParent:GetEffectiveScale()
            local _, pcy  = UIParent:GetCenter()
            panel:SetHeight(newH)
            if oldTop and oldH and pcy and math.abs(newH - oldH) > 0.5 then
                -- TOP-PIN: compute the CENTER-anchor Y offset that keeps
                -- the top edge at the same screen position after resize.
                -- X never changes on a vertical resize, so we reuse the
                -- already-saved panelX rather than re-deriving it from
                -- GetCenter() (which would return the shifted center and
                -- accumulate error across repeated expand/collapse calls).
                --
                -- All values from GetTop/GetHeight are in panel-local
                -- scaled space. SetPoint anchor offsets are also in the
                -- ANCHORED frame's scaled coord system (NOT UIParent's
                -- -- per Wowpedia "UI scaling"), so we convert from
                -- screen pixels back to panel-scaled units by dividing
                -- by fscale, not pscale.
                local newCenterY = oldTop - (newH / 2)  -- panel scale
                local y = (newCenterY * fscale - pcy * pscale) / fscale
                local x = RR:GetSetting("panelX", 0)
                panel:ClearAllPoints()
                panel:SetPoint("CENTER", UIParent, "CENTER", x, y)
                RR:SetSetting("panelY", math.floor(y + 0.5))
            end
        end
    end

    -- TRANSMOG POPUP -------------------------------------------------------
    -- Size the popup deterministically from the content's line count rather
    -- than measuring rendered text, because GetStringHeight is lazy after
    -- SetFont and produces a visible pop-in on the first frame. Line-height
    -- is approximated from the font size: at fontSize 12, each line renders
    -- ~16px tall with word wrapping. We also reserve chrome for dropdowns.
    if tmogWindow and tmogWindow.contentText then
        local text = tmogWindow.contentText
        local content = text:GetText() or ""
        local lines = 1
        for _ in content:gmatch("\n") do lines = lines + 1 end

        local fontSize = RR:GetSetting("fontSize", 12)
        -- Empirical: WoW's font metrics add ~4px leading above the glyph
        -- height, so effective line height is ~fontSize + 4. Use the
        -- active body font's effective size (sizeFactor-adjusted) so
        -- the Tmog window height budget matches the rendered text for
        -- non-FRIZQT fonts.
        local lineHeight = GetBodyFontSize(fontSize) + 4
        local textH      = lines * lineHeight

        -- Sanctum vendor line (Castle Nathria) lives on its own
        -- FontString below the main content. When shown, it adds one
        -- line of text plus the 8px gap from the BOTTOMLEFT anchor.
        -- Hidden -- which is the case for every non-CN raid and every
        -- CN boss that doesn't drop weapon tokens -- contributes 0.
        local sanctumH = 0
        if tmogWindow.sanctumLine and tmogWindow.sanctumLine:IsShown() then
            sanctumH = lineHeight + 8
        end

        -- Popup chrome: dropdown stack + title bar + margins.
        local chrome = 32      -- title bar
                     + 3 * 32  -- three dropdowns
                     + 10      -- gap between dropdowns and text
                     + 14      -- bottom margin
        local desired = chrome + textH + sanctumH
        local clamped = math.max(POPUP_CONTENT_MIN,
                                 math.min(POPUP_CONTENT_CEILING, desired))
        tmogWindow:SetHeight(clamped)
    end

    -- ACHIEVEMENTS POPUP: sized inside RefreshContent (row-based layout,
    -- same pattern as skips). Nothing to do here.

    -- SETTINGS PANEL -------------------------------------------------------
    -- Frame height = lowest top-down-flowing control + measured bottom row.
    --
    -- The bottom row holds three widgets (Reset button on the left, Submit-
    -- bug button just to its right, minimap checkbox on the right). All
    -- three are BOTTOM-anchored to the frame, so they place themselves
    -- relative to whatever bottom edge SetHeight produces. The frame must
    -- be tall enough that the top edge of the TALLEST bottom-row widget
    -- still clears the lowest top-flowing slider with breathing room.
    --
    -- The earlier implementation used a hardcoded +50 margin that worked
    -- for the current widget set but was opaque -- adding a taller bottom-
    -- row widget would silently overlap the sliders without anyone
    -- noticing until visually inspected. Now the margin is measured: walk
    -- the bottom-row widgets, find the one whose top edge is highest from
    -- the frame's bottom, and add a fixed breathing-room cushion above.
    if settingsFrame then
        local lowestBottom = 0
        for _, child in ipairs({ settingsFrame.fontSlider,
                                  settingsFrame.scaleSlider,
                                  settingsFrame.opacitySlider,
                                  -- Launch-mode + body-font radio
                                  -- groups live below the sliders. The
                                  -- last radio in the body-font stack
                                  -- (fontRadioVT323) is the bottommost
                                  -- body widget; measuring it dominates
                                  -- the earlier rows above.
                                  settingsFrame.fontRadioVT323 }) do
            if child then
                local y = ContentBottomY(settingsFrame, child)
                if y > lowestBottom then lowestBottom = y end
            end
        end
        if lowestBottom > 0 then
            -- Measure how much vertical space the bottom row occupies,
            -- in pixels-from-the-frame-bottom. For each bottom-row
            -- widget, top-edge-from-bottom = its bottom anchor offset +
            -- its height. The frame's content area above the bottom
            -- row needs at least that many pixels reserved.
            local bottomRowTopFromBottom = 0
            for _, child in ipairs({ settingsFrame.resetButton,
                                      settingsFrame.bugButton,
                                      settingsFrame.minimapCheck }) do
                if child then
                    local fBot = settingsFrame:GetBottom() or 0
                    local wTop = child:GetTop() or fBot
                    local topFromBottom = wTop - fBot
                    if topFromBottom > bottomRowTopFromBottom then
                        bottomRowTopFromBottom = topFromBottom
                    end
                end
            end
            -- Breathing room above the bottom row so the lowest slider
            -- doesn't visually crowd it. 16px is roughly the gap the
            -- old hardcoded +50 produced for the current widget set
            -- (tallest top-edge at y=34 → 50 - 34 = 16).
            local BOTTOM_ROW_BREATHING_ROOM = 16
            local reserve = bottomRowTopFromBottom + BOTTOM_ROW_BREATHING_ROOM
            -- Fallback to the old hardcoded value if measurement failed
            -- (e.g. widgets not yet laid out on the first call). 50 is
            -- conservative for the current widget set and won't clip.
            if reserve <= 0 then reserve = 50 end
            settingsFrame:SetHeight(lowestBottom + reserve)
        end
    end
end

-- Expose on the module and also keep backward-compatible reference
RetroRunsUI = panel

panel:Hide()

-------------------------------------------------------------------------------
-- Settings panel
-------------------------------------------------------------------------------

-- settingsFrame is forward-declared near the top alongside transmog
-- forwards, so UI.AutoSize can close over it.

local function BuildSettingsPanel()
    local f = CreateFrame("Frame", "RetroRunsSettingsFrame", UIParent, "BackdropTemplate")
    -- Width is fixed; height is computed by UI.AutoSize's settings
    -- block (above), which walks the body widgets and adds a measured
    -- footer reserve. The placeholder height here is just to give the
    -- frame valid dimensions before the first AutoSize pass runs.
    f:SetSize(300, 200)
    -- Settings is a modal-ish control surface; keep it above the main panel
    -- and the tmog popup so opening it from the main panel isn't occluded.
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.03, 0.03, 0.03, 0.95)
    f:Hide()

    -- Draggable, with persisted position (like the main panel).
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- See main-panel OnDragStop above for why we normalize the anchor
        -- to CENTER/CENTER here before reading offsets.
        local cx, cy   = self:GetCenter()
        local pcx, pcy = UIParent:GetCenter()
        local fscale   = self:GetEffectiveScale()
        local pscale   = UIParent:GetEffectiveScale()
        -- See main-panel drag handler for the fscale-vs-pscale rationale.
        local x = (cx * fscale - pcx * pscale) / fscale
        local y = (cy * fscale - pcy * pscale) / fscale
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", x, y)
        RR:SetSetting("settingsX", math.floor(x + 0.5))
        RR:SetSetting("settingsY", math.floor(y + 0.5))
    end)

    f.RestorePosition = function(self)
        self:ClearAllPoints()
        local x = RR:GetSetting("settingsX", 290)
        local y = RR:GetSetting("settingsY", 60)
        self:SetPoint("CENTER", UIParent, "CENTER", x, y)
    end
    f:RestorePosition()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 14, -12)
    f.title:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  Settings")
    -- Use the 04B_03 retro pixel font for auxiliary window titles to
    -- match the main panel's RETRO RUNS branding. Sized 16px so the
    -- pixel grid renders cleanly (smaller breaks the pixel shapes).
    -- Shadow rather than OUTLINE because OUTLINE on pixel fonts at
    -- this size adds noise that hurts the crisp blocky look.
    f.title:SetFont(TITLE_FONT, 16, "")
    f.title:SetShadowOffset(1, -1)
    f.title:SetShadowColor(0, 0, 0, 1)

    f.versionLabel = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.versionLabel:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -4)
    f.versionLabel:SetText("v" .. RetroRuns.VERSION)

    f.closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeButton:SetPoint("TOPRIGHT", -4, -4)

    -- ---- Body ------------------------------------------------------------
    -- Layout strategy: every body widget anchors top-down from the
    -- widget above (versionLabel -> font slider -> scale slider ->
    -- opacity slider -> "On login" label -> 3 radios). The panel's
    -- final height is computed at the bottom of this block from the
    -- last body widget's position plus a fixed footer reserve, so the
    -- panel always grows to fit content without bottom-anchored
    -- widgets fighting top-anchored ones (the previous failure mode).

    -- Slider helper. Builds an OptionsSliderTemplate slider with a
    -- live-updating label that shows the current value inline with the
    -- name ("Font Size: 12"). `formatValue` (optional) maps the raw
    -- slider value to the display string; defaults to integer rounding.
    -- Used by the scale slider to display 80-130 as "1.00x"-style.
    local function MakeSlider(frameName, label, min, max, step, anchorWidget, offsetY, formatValue)
        local s = CreateFrame("Slider", frameName, f, "OptionsSliderTemplate")
        s:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 0, offsetY)
        s:SetPoint("RIGHT", f, "RIGHT", -24, 0)
        s:SetMinMaxValues(min, max)
        s:SetValueStep(step)
        s:SetObeyStepOnDrag(true)
        s.Low:SetText(tostring(min))
        s.High:SetText(tostring(max))
        s.labelBase   = label
        s.formatValue = formatValue or function(v) return tostring(math.floor(v + 0.5)) end
        s.RefreshLabel = function(self)
            self.Text:SetText(self.labelBase .. ": " .. self.formatValue(self:GetValue()))
        end
        s:RefreshLabel()
        return s
    end

    f.fontSlider  = MakeSlider("RetroRunsFontSlider",  "Font Size",    10, 18,  1, f.versionLabel, -28)
    f.scaleSlider = MakeSlider("RetroRunsScaleSlider", "Window Scale", 80, 130, 5, f.fontSlider, -34,
        function(v)
            -- Slider stores 80-130 (percentage * 100); display as "1.00x"
            -- so the user sees the multiplier rather than the raw int.
            return ("%.2fx"):format(v / 100)
        end)
    f.scaleSlider.Low:SetText("0.8")
    f.scaleSlider.High:SetText("1.3")

    f.opacitySlider = MakeSlider("RetroRunsOpacitySlider", "Panel Opacity", 20, 100, 5, f.scaleSlider, -34,
        function(v) return ("%d%%"):format(math.floor(v + 0.5)) end)
    f.opacitySlider.Low:SetText("20%")
    f.opacitySlider.High:SetText("100%")

    -- Launch-mode radio group. Three mutually-exclusive options that
    -- govern what RetroRuns does to the main panel on addon load:
    -- leave it closed, open minimized, or open fully expanded. Stored
    -- as a string in RetroRunsDB.launchMode; applied at init time by
    -- Core.lua's RR:InitializeDB. Order is "minimized first" (the
    -- default) so users land on the recommended option first.
    --
    -- Wider gap above (-50) than between sliders (-34) to signal the
    -- topic shift from appearance to behavior, in lieu of a section
    -- header line.
    f.launchQuestion = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.launchQuestion:SetPoint("TOPLEFT", f.opacitySlider, "BOTTOMLEFT", 0, -50)
    f.launchQuestion:SetText("On login, show RetroRuns:")

    local function MakeLaunchRadio(value, label, anchorWidget, offsetY)
        local r = CreateFrame("CheckButton", nil, f, "UIRadioButtonTemplate")
        r:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 0, offsetY)
        r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.text:SetPoint("LEFT", r, "RIGHT", 4, 1)
        r.text:SetText(label)
        r.value = value
        r:SetScript("OnClick", function(self)
            RR:SetSetting("launchMode", self.value)
            if f.SyncLaunchRadios then f:SyncLaunchRadios() end
        end)
        return r
    end

    f.launchRadioMinimized = MakeLaunchRadio("minimized", "Open minimized", f.launchQuestion,       -6)
    f.launchRadioFull      = MakeLaunchRadio("full",      "Open full",      f.launchRadioMinimized, -2)
    f.launchRadioHidden    = MakeLaunchRadio("hidden",    "Don't open",     f.launchRadioFull,      -2)

    f.SyncLaunchRadios = function(self)
        local current = RR:GetSetting("launchMode", "minimized")
        self.launchRadioHidden:SetChecked(current    == "hidden")
        self.launchRadioMinimized:SetChecked(current == "minimized")
        self.launchRadioFull:SetChecked(current      == "full")
    end
    f:SyncLaunchRadios()

    -- Body-font radio group. Two mutually-exclusive options that govern
    -- which font is used for body-level text inside the main panel
    -- (action buttons, idle-state raid list, legend rows). Frame
    -- headers (auxiliary window titles, the main panel's RETRO RUNS
    -- title) always use the retro font regardless of this setting --
    -- the toggle is body-scoped. Default is "retro" (04B_03).
    --
    -- Same layout pattern as the launch radio group above: wide gap
    -- below the previous block, question label, then radios.
    f.fontQuestion = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.fontQuestion:SetPoint("TOPLEFT", f.launchRadioHidden, "BOTTOMLEFT", 0, -18)
    f.fontQuestion:SetText("Body font:")

    local function MakeFontRadio(value, label, anchorWidget, offsetY)
        local r = CreateFrame("CheckButton", nil, f, "UIRadioButtonTemplate")
        r:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 0, offsetY)
        r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        r.text:SetPoint("LEFT", r, "RIGHT", 4, 1)
        r.text:SetText(label)
        r.value = value
        r:SetScript("OnClick", function(self)
            RR:SetSetting("bodyFontStyle", self.value)
            if f.SyncFontRadios then f:SyncFontRadios() end
            -- Re-apply across body surfaces. The idle list is redrawn
            -- by invalidating its fingerprint cache and triggering a
            -- refresh; ApplySettings walks the body-widget targets
            -- table and re-fonts the in-raid surface (raid name,
            -- pills, Next, travel, encounter card, etc.) plus the
            -- idle headers. Skips + Achievements windows are auto-
            -- refreshed via ApplySettings if currently shown. The
            -- Tmog window is NOT auto-refreshed by ApplySettings
            -- (its RefreshContent is gated to avoid heartbeat-tick
            -- reflow), so we force it explicitly here. Action
            -- buttons + title bar + footer are locked to 04B_03 and
            -- don't need a re-paint here.
            if UI.InvalidateIdleListCache then UI.InvalidateIdleListCache() end
            UI.ApplySettings()
            if tmogWindow and tmogWindow:IsShown() and tmogWindow.RefreshContent then
                tmogWindow:RefreshContent()
            end
        end)
        return r
    end

    f.fontRadioStandard = MakeFontRadio("standard", "Friz Quadrata (Default)", f.fontQuestion,        -6)
    f.fontRadioRetro    = MakeFontRadio("retro",    "04B_03",                  f.fontRadioStandard,   -2)
    f.fontRadioVT323    = MakeFontRadio("vt323",    "VT323",                   f.fontRadioRetro,      -2)

    f.SyncFontRadios = function(self)
        local current = RR:GetSetting("bodyFontStyle", "standard")
        self.fontRadioStandard:SetChecked(current == "standard")
        self.fontRadioRetro:SetChecked(current    == "retro")
        self.fontRadioVT323:SetChecked(current    == "vt323")
    end
    f:SyncFontRadios()


    local function MakeCheckbox(label, anchorPoint, anchorWidget, anchorRel, offsetX, offsetY, getter, setter)
        local cb = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint(anchorPoint, anchorWidget, anchorRel, offsetX, offsetY)
        cb.Text:SetText(label)
        cb:SetScript("OnClick", function(self)
            setter(self:GetChecked())
            UI.ApplySettings()
        end)
        cb.Sync = function(self) self:SetChecked(getter()) end
        return cb
    end

    f.resetButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.resetButton:SetSize(80, 22)
    f.resetButton:SetPoint("BOTTOMLEFT", 14, 12)
    f.resetButton:SetText("Defaults")
    f.resetButton:SetScript("OnClick", function()
        SlashCmdList["RETRORUNS"]("reset")
    end)

    -- Submit-bug button. Icon-only square button (22x22, matching the
    -- resetButton's height so the row reads as a single horizontal
    -- band) anchored just to the right of the Defaults button. Clicking
    -- pops a Wowhead-style copy popup with the GitHub Issues URL
    -- (RETRORUNS_BUG_URL StaticPopup, defined in this file alongside
    -- the wowhead URL popup -- single-line EditBox, Ctrl+C to copy,
    -- dismiss with Enter or Escape).
    --
    -- Single venue (GitHub Issues) rather than two -- two URLs in one
    -- popup would defeat the "Ctrl+C the URL" pattern, and venue choice
    -- via dropdown was overengineered. CurseForge comments are reachable
    -- by users without a button (they're already on the addon page),
    -- and GitHub Issues is the right venue for tracked bug reports.
    --
    -- Texture: custom BugIcon.tga in Media/. A clean dark beetle
    -- silhouette in top-down view, alpha-keyed background. Authored
    -- specifically for this button after several Blizzard-stock icon
    -- attempts (INV_Misc_Bug_03, Achievement_Faction_Klaxxi,
    -- Ability_Hunter_Pet_Spider) all read poorly at 22x22. Source
    -- art was downscaled from a 1024x1024 reference, alpha-keyed via
    -- luminance threshold to drop the background, and saved as
    -- 64x64 RGBA TGA. WoW renders TGAs cleanly at any rendered size.
    --
    -- Implementation note: skipped the BackdropTemplate frame around
    -- the icon (first attempt) -- the backdrop was hiding the icon
    -- texture. Pure Button widget with normal+pushed+highlight
    -- textures handles the visual treatment cleanly.
    f.bugButton = CreateFrame("Button", nil, f)
    f.bugButton:SetSize(22, 22)
    f.bugButton:SetPoint("LEFT", f.resetButton, "RIGHT", 6, 0)

    f.bugButton:SetNormalTexture("Interface\\AddOns\\RetroRuns\\Media\\BugIcon")
    f.bugButton:SetPushedTexture("Interface\\AddOns\\RetroRuns\\Media\\BugIcon")
    f.bugButton:SetHighlightTexture(
        "Interface\\Buttons\\CheckButtonHilight", "ADD")

    -- Tint the white-source TGA via vertex color multiplication to
    -- RETRO pink (the canonical brand color, C_PINK at the top of
    -- this file = {0.95, 0.35, 0.78}). Earlier conversion of the TGA
    -- baked a uniform DARK grey foreground -- vertex tinting could
    -- only DARKEN those already-dark pixels, never lighten or color
    -- them, since SetVertexColor multiplies channels. Re-converted
    -- with WHITE (255,255,255) foreground so multiplying by any RGB
    -- gives that color at full brightness.
    local nt = f.bugButton:GetNormalTexture()
    if nt then nt:SetVertexColor(0.95, 0.35, 0.78, 1) end
    local pt = f.bugButton:GetPushedTexture()
    if pt then pt:SetVertexColor(0.95, 0.35, 0.78, 1) end

    -- No texcoord trim needed -- our custom TGA fills the canvas
    -- edge-to-edge with no built-in margin (unlike Blizzard's stock
    -- icons which ship with a ~5% transparent border).

    f.bugButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Report a bug")
        GameTooltip:AddLine(
            "Open a copy window with a link to the GitHub issue tracker.",
            1, 1, 1, true)
        GameTooltip:Show()
    end)
    f.bugButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    f.bugButton:SetScript("OnClick", function()
        StaticPopup_Show("RETRORUNS_BUG_URL", nil, nil, {
            url = "https://github.com/PhotekWoW/RetroRuns/issues",
        })
    end)

    -- CurseForge-comments button. Same icon-button pattern as the
    -- bug button: 22x22 square, anchored 6px to the right of the
    -- bug button so the three-button row (Defaults + bug + chat)
    -- reads as one horizontal action band.
    --
    -- Distinct purpose from the bug button: this points to the
    -- CurseForge page's comments tab, the public discussion venue
    -- where users post questions, suggestions, kudos, and general
    -- chatter. Bug button is for filing tracked issues; this is for
    -- conversation. Two separate buttons keeps each affordance clear.
    --
    -- Texture: custom ChatIcon.tga in Media/. Two overlapping speech
    -- bubbles with a "+" in the larger one. Sourced from a 1408x768
    -- reference, cropped to a square (the source had a "CHAT/CONTACT"
    -- caption at the bottom which would be unreadable at 22x22 anyway),
    -- alpha-keyed to a white silhouette via the same luminance-threshold
    -- recipe as BugIcon.tga. Tinted at render time to RETRO cyan
    -- (C_BLUE = {0.30, 0.80, 1.00}, the brand color in the title's
    -- "RUNS" half) to visually distinguish from the pink bug button.
    f.chatButton = CreateFrame("Button", nil, f)
    f.chatButton:SetSize(22, 22)
    f.chatButton:SetPoint("LEFT", f.bugButton, "RIGHT", 6, 0)

    f.chatButton:SetNormalTexture("Interface\\AddOns\\RetroRuns\\Media\\ChatIcon")
    f.chatButton:SetPushedTexture("Interface\\AddOns\\RetroRuns\\Media\\ChatIcon")
    f.chatButton:SetHighlightTexture(
        "Interface\\Buttons\\CheckButtonHilight", "ADD")

    -- Scale the texture region UP beyond the 22x22 button frame so the
    -- silhouette renders at roughly the same visual size as the bug
    -- icon next to it. The chat source TGA was authored with the
    -- silhouette at ~70% of canvas (transparent padding around it for
    -- positional precision), but at button-default sizing that shrinks
    -- the rendered silhouette below the bug icon's apparent size.
    -- Sizing the texture region to ~30x30 centered on the button frame
    -- (vs the button's own 22x22) makes the silhouette inside fill
    -- roughly the bug icon's visual footprint while keeping the
    -- button's 22x22 hit-area for the row's spacing rhythm. Texture
    -- regions can extend outside their parent frame's bounds; only
    -- the click-detection respects the frame size.
    local cnt = f.chatButton:GetNormalTexture()
    if cnt then
        cnt:ClearAllPoints()
        cnt:SetSize(30, 30)
        cnt:SetPoint("CENTER", f.chatButton, "CENTER", 0, 0)
        cnt:SetVertexColor(0.30, 0.80, 1.00, 1)
    end
    local cpt = f.chatButton:GetPushedTexture()
    if cpt then
        cpt:ClearAllPoints()
        cpt:SetSize(30, 30)
        cpt:SetPoint("CENTER", f.chatButton, "CENTER", 0, 0)
        cpt:SetVertexColor(0.30, 0.80, 1.00, 1)
    end

    f.chatButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Comments and feedback")
        GameTooltip:AddLine(
            "Open a copy window with a link to the CurseForge comments page.",
            1, 1, 1, true)
        GameTooltip:Show()
    end)
    f.chatButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    f.chatButton:SetScript("OnClick", function()
        StaticPopup_Show("RETRORUNS_CHAT_URL", nil, nil, {
            url = "https://www.curseforge.com/wow/addons/retroruns/comments",
        })
    end)

    -- Minimap toggle anchored to the bottom-right of the frame, sharing
    -- the same horizontal action band as the Defaults / bug / chat
    -- buttons on the left.
    --
    -- Geometry note: InterfaceOptionsCheckButtonTemplate puts the
    -- checkbox square at the anchor point and the LABEL TO THE RIGHT
    -- of the checkbox (extending outward from the anchor). Anchoring
    -- the checkbox at BOTTOMRIGHT, -120, ... worked but the -120 was
    -- a guess at label width that didn't actually match -- the
    -- compound (checkbox + label) ended up clipping the panel edge or
    -- leaving an awkward gap depending on the label text. And the
    -- y=14 was off from the Defaults row's y=12 by 2px, breaking the
    -- visual baseline alignment.
    --
    -- New approach: anchor the checkbox to BOTTOMRIGHT with a
    -- two-step offset that accounts for both the label's measured
    -- string width and a 14px right margin matching the panel's
    -- standard padding. Y matches the Defaults button at y=12 so
    -- the row reads as one horizontal band.
    f.minimapCheck = MakeCheckbox(
        "Minimap button",
        "BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 8,
        -- showMinimap default is true; only an explicit `false` hides.
        function() return RR:GetSetting("showMinimap") ~= false end,
        function(val)
            RR:SetSetting("showMinimap", val)
            if RR.minimapButton then
                if val then RR.minimapButton:Show()
                else RR.minimapButton:Hide() end
            end
        end)

    -- Reposition after MakeCheckbox returns: measure the label's
    -- string width and re-anchor the compound widget so the LABEL's
    -- right edge sits at the panel's right edge with 14px padding.
    -- Done as a post-create reposition because the label width isn't
    -- known until the FontString has had its text set.
    if f.minimapCheck and f.minimapCheck.Text then
        local labelWidth = f.minimapCheck.Text:GetStringWidth() or 80
        f.minimapCheck:ClearAllPoints()
        -- Total horizontal space the compound needs: label width +
        -- a small gap between the checkbox-square and the label
        -- (the template's built-in spacing is ~4px) + the label's
        -- right margin to the panel edge (14px). The checkbox
        -- square itself is ~26px wide.
        f.minimapCheck:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",
            -(labelWidth + 14), 8)
    end

    f.fontSlider:SetScript("OnValueChanged", function(self, value)
        if not RetroRunsDB then return end
        RR:SetSetting("fontSize", math.floor(value + 0.5))
        self:RefreshLabel()
        -- Font size affects how idle-list rows render even though the
        -- row DATA is unchanged -- invalidate the cache so the next
        -- RefreshIdleList actually rebuilds at the new size.
        if UI.InvalidateIdleListCache then UI.InvalidateIdleListCache() end
        -- Same reasoning for the achievements window's row table.
        if UI.InvalidateAchievementsCache then UI.InvalidateAchievementsCache() end
        UI.ApplySettings()
    end)

    f.scaleSlider:SetScript("OnValueChanged", function(self, value)
        if not RetroRunsDB then return end
        RR:SetSetting("windowScale", value / 100)
        self:RefreshLabel()
        if UI.InvalidateIdleListCache then UI.InvalidateIdleListCache() end
        UI.ApplySettings()
    end)

    f.opacitySlider:SetScript("OnValueChanged", function(self, value)
        if not RetroRunsDB then return end
        RR:SetSetting("panelOpacity", value / 100)
        self:RefreshLabel()
        UI.ApplySettings()
    end)

    f:SetScript("OnShow", function(self) UI.SyncSettingsControls() end)
    return f
end

settingsFrame = BuildSettingsPanel()
RetroRunsSettingsFrame = settingsFrame

function UI.SyncSettingsControls()
    if not RetroRunsDB or not settingsFrame then return end
    settingsFrame.fontSlider:SetValue(RR:GetSetting("fontSize", 12))
    settingsFrame.scaleSlider:SetValue(
        math.floor((RR:GetSetting("windowScale", 1.0) * 100) + 0.5))
    settingsFrame.opacitySlider:SetValue(
        math.floor((RR:GetSetting("panelOpacity", 1.0) * 100) + 0.5))
    -- SetValue only fires OnValueChanged if the value actually changes, so
    -- on first sync (slider at construction-time min, DB matches) the label
    -- wouldn't update. Force a refresh to cover that edge case.
    settingsFrame.fontSlider:RefreshLabel()
    settingsFrame.scaleSlider:RefreshLabel()
    settingsFrame.opacitySlider:RefreshLabel()
    settingsFrame.minimapCheck:Sync()
    if settingsFrame.SyncLaunchRadios then settingsFrame:SyncLaunchRadios() end
    if settingsFrame.SyncFontRadios   then settingsFrame:SyncFontRadios()   end
end

function UI.ToggleSettings()
    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        settingsFrame:Show()
        settingsFrame:Raise()   -- force above other dialogs (e.g. tmog popup)
    end
end

-------------------------------------------------------------------------------
-- Display helpers
-------------------------------------------------------------------------------

local C_ORANGE = "ff7f00"

local function OrangeText(text)
    return "|cff" .. C_ORANGE .. text .. "|r"
end

-- Color transport locations, boss names, and zone/map names orange in any text
-- Blizzard's standard difficulty colors (match item-quality tiers used
-- in the Encounter Journal's difficulty selector).
local DIFFICULTY_COLORS = {
    ["Raid Finder"] = "ff1eff00",  -- green (uncommon)
    ["LFR"]         = "ff1eff00",  -- green (uncommon) -- common shorthand
    ["Normal"]      = "ffffffff",  -- white (common)
    ["Heroic"]      = "ff0070dd",  -- blue (rare)
    ["Mythic"]      = "ffa335ee",  -- purple (epic)
}

-- Pattern-ordered list so longer phrases get matched before substrings
-- (e.g. "Raid Finder" before "Raid", though "Raid" isn't in the table --
-- but the principle applies generally; we put multi-word entries first).
local DIFFICULTY_COLOR_ORDER = {
    "Raid Finder", "LFR", "Normal", "Heroic", "Mythic",
}

-- Colorize difficulty words in a tip. The colorization is context-free:
-- any occurrence of "Mythic" (word boundary) gets the Mythic color,
-- regardless of whether it's being used as a difficulty label. This is
-- an acceptable trade because those words nearly always refer to
-- difficulty in an addon about raid content. Word boundaries protect
-- against partial-match horror (e.g. "Mythica" is not colored).
local function ColorizeDifficulties(text)
    if not text or text == "" then return text end
    for _, word in ipairs(DIFFICULTY_COLOR_ORDER) do
        local color = DIFFICULTY_COLORS[word]
        if color then
            -- %f[%a] and %f[%A] are Lua's frontier patterns, which act as
            -- word boundaries. This keeps "Mythic" from matching inside
            -- "Mythica" and avoids double-coloring if the word appears
            -- inside an already-colored segment (the |c...|r wrap makes
            -- word boundaries stable).
            text = text:gsub(
                "%f[%a]" .. word .. "%f[%A]",
                ("|c%s%s|r"):format(color, word))
        end
    end
    return text
end

-- Apply orange highlighting to prose. The author marks spans with
-- ^carets^ in note/travelText/soloTip strings; this function wraps each
-- marked span in the orange color code. Difficulty words
-- (LFR/Normal/Heroic/Mythic) still get their Blizzard quality colors
-- via ColorizeDifficulties, regardless of caret markup.
--
-- Caret pairs nest cleanly because gsub walks left-to-right. Unmatched
-- carets (odd count, or a stray ^ inside a marked span) get stripped
-- silently rather than producing broken color codes.
local function HighlightNames(text)
    if not text or text == "" then return text end
    text = text:gsub("%^([^%^]+)%^", function(span)
        return OrangeText(span)
    end)
    -- Strip any stragglers (unmatched carets) so they don't render.
    text = text:gsub("%^", "")
    text = ColorizeDifficulties(text)
    return text
end

local function GetBestMapForStep(step)
    if not step then return nil end
    local playerMapID = C_Map and C_Map.GetBestMapForUnit and
                        C_Map.GetBestMapForUnit("player")
    -- Only consider playerMapID for travel-pane segment matching. The
    -- world map's currently-displayed mapID can be stale (the player
    -- may have last viewed a different sub-zone), so using it can
    -- surface a wrong-step-segment note. Map RENDERING does use
    -- worldMapID -- that's the right input for "draw segments on
    -- whichever map is visible" -- but text matching needs to follow
    -- the player's physical location.
    if playerMapID then
        if step.segments then
            for _, seg in ipairs(step.segments) do
                if seg.mapID == playerMapID then return playerMapID end
            end
        elseif step.mapID == playerMapID then
            return playerMapID
        end
    end
    return playerMapID
end
-- Exposed on the UI namespace so out-of-file callers (e.g. the
-- /rr traveldebug slash dispatch in Core.lua) can use the same map-
-- resolution logic the renderer uses, rather than reimplementing it.
UI.GetBestMapForStep = GetBestMapForStep

-- Per-difficulty pill row text. Renders as a bracketed pipe-separated
-- strip matching the tmog dot row's visual style (BuildPerDiffRow at
-- ~line 2080):
--   [ LFR 0/8 | N 8/8 | H 0/8 | M 0/8 ]
-- with brackets and pipes in dark gray, the player's current difficulty
-- in white, every other difficulty (including fully-cleared ones) in
-- mid gray. Reader picks out "what am I playing right now" by the white
-- highlight, then reads the x/y count to know whether each difficulty
-- is fresh, partial, or done.
--
-- Returns "" when no kill data available (raid not loaded, API
-- unsupported, no encounters mapped) so the FontString just renders
-- empty without breaking layout.
local function BuildPillsText()
    local counts = RR:GetPerDifficultyKillCounts()
    if not counts then return "" end

    local activeDiff = RR.state and RR.state.currentDifficultyID
    local WHITE_HEX  = "FFFFFF"
    local GRAY_HEX   = "888888"

    -- Order matches typical Blizzard UI: easiest -> hardest.
    -- difficultyID -> short label.
    local PILLS = {
        { id = 17, label = "LFR" },
        { id = 14, label = "N"   },
        { id = 15, label = "H"   },
        { id = 16, label = "M"   },
    }

    local parts = {}
    for _, p in ipairs(PILLS) do
        local c = counts[p.id]
        if c then
            local hex = (p.id == activeDiff) and WHITE_HEX or GRAY_HEX
            table.insert(parts, ("|cff%s%s %d/%d|r"):format(
                hex, p.label, c.complete, c.total))
        end
    end
    if #parts == 0 then return "" end

    local sep = "|cff555555 | |r"
    return "|cff777777[ |r"
        .. table.concat(parts, sep)
        .. "|cff777777 ]|r"
end

-- Last-rendered travel text, cached so the pane can freeze for the
-- duration of a boss fight. Set on every non-frozen render below;
-- returned verbatim while RR.state.inEncounter is true. Cleared on
-- ENCOUNTER_END (Core.lua) which triggers a re-render with the next
-- step's pre-pull text. Rationale: mid-fight platform changes report
-- different mapIDs (Tindral phase 2 Northern Boughs, etc.) that
-- don't match the pre-pull segment, leading to stale "(Open map for
-- directions)" fallbacks during the fight. Freezing avoids surfacing
-- these mid-encounter regressions.
local lastTravelText = nil

-- Last picker-output we logged. Used to suppress heartbeat-tick spam:
-- the picker is called every UI.Update tick (1Hz) and we only want to
-- log when the returned text actually changes. First-call always logs
-- (lastLoggedTravelText starts nil, any returned text differs).
local lastLoggedTravelText = nil

-- Pulse state for the "[!] view special note" attention-grabber on the
-- Boss Encounter line. Cycles 0..15 every 0.1s, giving a 1.6s round
-- trip with 16 brightness steps per cycle. BuildEncounterText reads
-- this to pick a smoothly-graduated yellow color for the [!] glyph,
-- producing a subtle breathing effect while the encounter section is
-- collapsed and the boss has a custom soloTip. Static at full
-- brightness whenever the section is expanded or no soloTip exists.
--
-- Cosmetic-only: feeds back into UI.Update via the dedicated ticker
-- below, no game-state implications.
local encounterPulsePhase = 0
local ENCOUNTER_PULSE_STEPS = 16

-- Brightness curve: cosine-modulated yellow (RGB ffff00 base, varying
-- brightness multiplier from ~70% to 100%). Built at load time -- a
-- 16-entry lookup table is cheaper than recomputing the math every
-- tick, and keeps BuildEncounterText to a single index lookup.
--
-- Cosine over a full 2π range gives the breathing curve: slow at the
-- extremes (bright peak, dim trough), fast through the middle. Pure
-- linear stepping reads as mechanical even with many steps; the
-- cosine is what makes it feel organic. Multiplier base 0.85 plus
-- amplitude 0.15 keeps the [!] visible at all phases (never below
-- ~70% of full yellow) so it doesn't disappear at the dim end.
local ENCOUNTER_PULSE_COLORS = {}
for i = 0, ENCOUNTER_PULSE_STEPS - 1 do
    local phase = (i / ENCOUNTER_PULSE_STEPS) * 2 * math.pi
    local brightness = 0.85 + 0.15 * math.cos(phase)
    -- Clamp and convert to 0xff-scale byte for RGB. Yellow = ffff00,
    -- so the R and G channels both modulate; B stays 0.
    local byte = math.floor(brightness * 255 + 0.5)
    if byte > 255 then byte = 255 end
    if byte < 0 then byte = 0 end
    ENCOUNTER_PULSE_COLORS[i] = ("|cff%02x%02x00"):format(byte, byte)
end

local function BuildTravelText(step)
    local prefix = ("|cff%sTraveling:|r "):format(C_LABEL)
    if not step then return prefix .. "N/A" end

    -- Encounter-freeze: while a boss fight is active, return the last
    -- text we rendered before the fight started. Avoids mid-fight
    -- mapID-driven flicker / stale text.
    if RR.state and RR.state.inEncounter and lastTravelText then
        return lastTravelText
    end

    -- Compute the current text. Single internal helper so every return
    -- path funnels through one cache-update at the bottom of this
    -- function.
    local function compute()
        local mapID = GetBestMapForStep(step)

        -- Strict-activeSeg picker dispatch: raids that opt in via
        -- `useStrictActiveSegPicker = true` route through the
        -- activeSeg-based picker in Data/StrictPicker.lua. Other raids
        -- fall through to the existing layered-gate logic below.
        -- See StrictPicker.lua header for the model rationale.
        if RR:UsesStrictActiveSegPicker() then
            local seg = RR:PickStrictNoteSeg(step, mapID)
            if seg and seg.note then
                return prefix .. HighlightNames(seg.note)
            end
            -- Picker returned nil (step has no segments, or activeSeg
            -- pointed past the end -- shouldn't happen but guard for it).
            -- Use step.travelText if present.
            if step.travelText then
                return prefix .. HighlightNames(step.travelText)
            end
            return prefix .. "|cff888888Open the map and select a section to see directions.|r"
        end

        if step.segments and mapID then
            local relevant = RR:GetRelevantSegmentsForMap(step, mapID)
            for _, seg in ipairs(relevant) do
                if seg.note then return prefix .. HighlightNames(seg.note) end
            end
            -- Secondary mapID-match loop: same requiresSubZone gating
            -- and sequential-ordering rule as GetRelevantSegmentsForMap.
            -- An incomplete seg with unmet requiresSubZone OR unmet
            -- revealAfter STOPS the walk -- don't skip past it to
            -- consider later segs.
            local currentSubZone = (GetSubZoneText and GetSubZoneText()) or ""
            local stepIndex = step.step or step.priority or 0
            -- Step-scoped reachability cap (opt-in via step.useStrictSegOrdering).
            -- See GetRelevantSegmentsForMap for full rationale.
            local maxReachable = #step.segments
            if step.useStrictSegOrdering then
                if mapID and RR.state.stepVisitedMapIDs then
                    RR.state.stepVisitedMapIDs[mapID] = true
                end
                maxReachable = 0
                local visited = RR.state.stepVisitedMapIDs
                if visited then
                    for segIndex, seg in ipairs(step.segments) do
                        if seg.mapID and visited[seg.mapID] then
                            maxReachable = segIndex
                        else
                            break
                        end
                    end
                end
                if maxReachable == 0 then
                    local visit = RR.state.stepVisitedMapIDs
                    local highestCompleted = 0
                    for segIndex, seg in ipairs(step.segments) do
                        if RR:IsSegmentCompleted(stepIndex, segIndex) then
                            highestCompleted = segIndex
                        end
                    end
                    local currentMatch = 0
                    if mapID then
                        for segIndex, seg in ipairs(step.segments) do
                            if seg.mapID == mapID then
                                currentMatch = segIndex
                                break
                            end
                        end
                    end
                    local highest = math.max(highestCompleted, currentMatch)
                    for segIndex = 1, highest do
                        local seg = step.segments[segIndex]
                        if seg and seg.mapID then
                            visit[seg.mapID] = true
                        end
                    end
                    for segIndex, seg in ipairs(step.segments) do
                        if seg.mapID and visit[seg.mapID] then
                            maxReachable = segIndex
                        else
                            break
                        end
                    end
                end
            end
            for segIndex, seg in ipairs(step.segments) do
                if segIndex > maxReachable then break end
                if seg.mapID == mapID and seg.note then
                    if seg.requiresSubZone and seg.requiresSubZone ~= currentSubZone then
                        break
                    end
                    if seg.revealAfterMapVisit
                        and not (RR.state.visitedMapIDs
                            and RR.state.visitedMapIDs[seg.revealAfterMapVisit])
                    then
                        break
                    end
                    if seg.gateBySubZone and seg.subZone
                        and seg.subZone ~= currentSubZone then
                        break
                    end
                    if not RR:IsSegmentCompleted(stepIndex, segIndex)
                        and not RR:IsSegmentRevealed(stepIndex, seg) then
                        break
                    end
                    return prefix .. HighlightNames(seg.note)
                end
            end
            -- Player IS on a mapID this step covers, but the relevant
            -- segment(s) carry no note (intentionally -- e.g. Sennarth's
            -- during-fight ascent segment on mapID 2123). Don't fall
            -- through to the "first segment note" fallback below, which
            -- would surface seg 1's "After killing Terros, go back..."
            -- text -- stale and misleading mid-fight. Show neutral text
            -- instead; the soloTip line is doing the useful work here.
            if #relevant > 0 then
                return prefix .. "|cff888888(No directions for this section)|r"
            end
        end
        if step.travelText then
            return prefix .. HighlightNames(step.travelText)
        end
        -- No segment matches the current map. This commonly fires
        -- after a boss kill: the player is still standing on the
        -- previous boss's platform (which has its own mapID), the
        -- active step has just advanced to the next boss, and that
        -- next step's segments are all on different mapIDs. Show
        -- the first INCOMPLETE segment's note so the player gets
        -- clear next-step direction without having to open the map.
        --
        -- "First incomplete" rather than "first" matters for
        -- multi-segment routes that cross between mapIDs with
        -- transition zones in between. Example: Xanesh in Ny'alotha
        -- has 3 segments on mapIDs 1581 -> 1582 -> 1592. After
        -- completing seg 1 and seg 2, the player can briefly be on
        -- a mapID that none of the route's segments cover (a
        -- short transition zone). Falling through to seg 1's note
        -- would re-surface "After killing Skitra, backtrack..."
        -- which is now stale and confusing. Walking the list in
        -- order and picking the first incomplete one shows the
        -- next correct instruction instead.
        --
        -- requiresSubZone gating (v1.2): an incomplete seg with
        -- unmet requiresSubZone STOPS the walk -- preserves
        -- sequential ordering, so the picker doesn't jump past a
        -- gated seg to a later one. When the walk stops, the
        -- "all completed" fallback below surfaces seg 1's note
        -- (the prior step's natural starting instruction), which
        -- is the right behavior for transit-gap states.
        if step.segments then
            local stepIndex = step.step or step.priority or 0
            local currentSubZone = (GetSubZoneText and GetSubZoneText()) or ""
            for segIndex, seg in ipairs(step.segments) do
                if seg.note and not RR:IsSegmentCompleted(stepIndex, segIndex) then
                    if seg.requiresSubZone and seg.requiresSubZone ~= currentSubZone then
                        break
                    end
                    if not RR:IsSegmentRevealed(stepIndex, seg) then
                        break
                    end
                    return prefix .. HighlightNames(seg.note)
                end
            end
            -- All segments completed but ENCOUNTER_END hasn't fired
            -- yet (or this step has no terminal segment). Fall back
            -- to seg 1's note so the player isn't shown a blank
            -- pane. Same behavior as the prior implementation in
            -- this corner case.
            if step.segments[1] and step.segments[1].note then
                return prefix .. HighlightNames(step.segments[1].note)
            end
        end
        return prefix .. "|cff888888Open the map and select a section to see directions.|r"
    end

    local text = compute()

    -- Log every change in the picker's returned travel text. The picker
    -- is called every UI.Update tick (~1Hz), so we suppress heartbeat
    -- spam by only logging when text changes vs the previous fetch.
    -- Goal: settle "what seg's note is the picker actually returning at
    -- this player location" questions definitively, without separate
    -- diagnostics. Captures playerMapID, playerSubZone, stepNumber, and
    -- the returned text -- enough to figure out which seg won the walk.
    if text ~= lastLoggedTravelText then
        local playerMapID = C_Map and C_Map.GetBestMapForUnit
            and C_Map.GetBestMapForUnit("player")
        local playerSubZone = (GetSubZoneText and GetSubZoneText()) or ""
        if RR.LogRecorderSession then
            RR:LogRecorderSession("PickerOutput", {
                playerMapID    = playerMapID,
                playerSubZone  = playerSubZone,
                stepNumber     = step and (step.step or step.priority) or 0,
                -- Strip the prefix and any color codes for shorter log
                -- lines; keep the first ~80 chars for identification.
                text           = text:gsub("|c%x%x%x%x%x%x%x%x", "")
                                     :gsub("|r", "")
                                     :sub(1, 80),
            })
        end
        lastLoggedTravelText = text
    end

    lastTravelText = text
    return text
end

-- Detects whether a boss has a "custom" encounter note worth surfacing
-- behind the click affordance. A note is custom when it's non-empty
-- AND not the default "Standard Nuke" placeholder. Achievements are
-- explicitly NOT considered here -- they render unconditionally below
-- the encounter line, regardless of expand state.
local function HasCustomEncounterNote(boss, step)
    local tip = (boss and boss.soloTip) or (step and step.soloTip) or ""
    if tip == "" or tip == "N/A" then return false end
    if tip:lower() == "standard nuke" then return false end
    return true
end

-- Builds the Achievements block as a concatenated multi-line string.
-- Returns "" if the boss has no achievements (caller can append
-- unconditionally; empty result contributes nothing). Header line is
-- "Achievements:" in the standard label color; each achievement is a
-- per-row clickable hyperlink (with "- " prefix and (Meta) tag if
-- applicable), color-coded green/yellow for completed/uncollected.
local function BuildAchievementsBlock(boss)
    if not boss or not boss.achievements or #boss.achievements == 0 then
        return ""
    end
    local lines = { ("|cff%sAchievements:|r"):format(C_LABEL) }

    -- Bracketed state indicator matches the Special Loot section's
    -- visual language (see SPECIAL_COLLECTED / SPECIAL_GLYPH_COLLECTED
    -- definitions later in the file -- those constants live near the
    -- specialLoot rendering and we mirror their values here rather than
    -- restructure file order). The pattern is:
    --   "|cff777777[ |r|c<color><glyph>|r|cff777777 ]|r <link>"
    -- We CANNOT wrap the achievement name with our own color because
    -- GetAchievementLink embeds its own |cff<...>| code, and WoW color
    -- codes don't nest -- the inner code wins. Keeping the indicator
    -- as a separate prefix preserves the link's native color while
    -- still giving us a clearly visible completion state.
    local STATE_COLOR_DONE   = "ff00ff00"
    local STATE_COLOR_TODO   = "ff888888"
    local STATE_GLYPH_DONE   = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
    local STATE_GLYPH_TODO   = "X"

    for _, ach in ipairs(boss.achievements) do
        local _, name, _, completed = GetAchievementInfo(ach.id)
        local label = name or ach.name or ("ID " .. ach.id)
        local tag   = ach.meta and " (Meta)" or ""

        local stateColor = completed and STATE_COLOR_DONE or STATE_COLOR_TODO
        local stateGlyph = completed and STATE_GLYPH_DONE or STATE_GLYPH_TODO
        local indicator  = ("|cff777777[ |r|c%s%s|r|cff777777 ]|r"):format(
            stateColor, stateGlyph)

        -- Build a clickable achievement hyperlink. GetAchievementLink
        -- returns a pre-formatted |Hachievement:...|h[Name]|h string
        -- which, when clicked inside a FontString whose parent has
        -- hyperlinks enabled, routes to SetItemRef (see panel wiring
        -- below). Falls back to plain text if GetAchievementLink fails
        -- or the achievement isn't in the cache yet.
        local link = GetAchievementLink and GetAchievementLink(ach.id)
        if link then
            -- Fold the "(Meta)" tag INTO the hyperlink's display text
            -- so the whole visible string is clickable, not just the
            -- achievement name. The hyperlink uses |h[text]|h for the
            -- display portion; we inject tag before the closing bracket.
            if tag ~= "" then
                link = link:gsub("|h%[(.-)%]|h", "|h[%1" .. tag .. "]|h", 1)
            end

            -- For completed achievements: strip the link's leading
            -- |cff<6hex> wrapper and trailing |r, then re-wrap with
            -- gray. Visual de-emphasis since the achievement is done.
            -- Incomplete achievements keep Blizzard's native yellow
            -- (which `GetAchievementLink` embeds for both states; we
            -- only override it on completion).
            -- Color codes don't nest in WoW chat formatting -- the
            -- inner code wins -- so without stripping, a completed
            -- achievement would render yellow even when wrapped in
            -- our gray. The |H...|h[Name]|h payload is preserved
            -- intact, so clickability survives the unwrap.
            if completed then
                link = link:gsub("^|cff%x%x%x%x%x%x", ""):gsub("|r$", "")
                table.insert(lines, ("%s |c%s%s|r"):format(
                    indicator, STATE_COLOR_TODO, link))
            else
                table.insert(lines, ("%s %s"):format(indicator, link))
            end
        else
            -- Plain-text fallback (cache miss). Wrap the label in our
            -- state color since there's no embedded link color to fight.
            table.insert(lines, ("%s |c%s%s%s|r"):format(
                indicator, stateColor, label, tag))
        end
    end
    return table.concat(lines, "\n")
end

-- BuildEncounterText returns up to two values:
--   text    - the rendered string for panel.encounter
--   clickable - whether panel.encounter should accept clicks (custom
--               soloTip exists; collapsed or expanded both clickable,
--               so the user can toggle either way)
--
-- Section composition (top to bottom):
--   1. "Boss Encounter:" line
--        - "Standard"            (no custom soloTip)
--        - "view special note"   (custom soloTip, collapsed)
--        - <full soloTip text>   (custom soloTip, expanded)
--   2. Achievements block (if any) -- ALWAYS rendered, independent of
--      the encounter expand state. Decoupled from the encounter expand
--      toggle so each section can have its own collapse behaviour later.
--   3. Special Loot block (if any) -- ALWAYS rendered.
local function BuildEncounterText(step)
    local prefix = ("|cff%sBoss Encounter:|r "):format(C_LABEL)
    if not step then return prefix .. "N/A", false end
    local boss = RR:GetBossByIndex(step.bossIndex)

    local hasCustom = HasCustomEncounterNote(boss, step)

    -- Compose the Boss Encounter line based on state.
    local headerLine
    local clickable
    if not hasCustom then
        headerLine = prefix .. "|cffaaaaaaStandard|r"
        clickable  = false
    elseif not RR:GetSetting("encounterExpanded") then
        -- Yellow [!] prefix to draw the eye to bosses that have a
        -- custom soloTip. The "view special note" link itself stays
        -- in subdued grey so the [!] does the attention-grabbing
        -- work without the whole line shouting. When the user
        -- expands the note, the marker drops away (the expanded
        -- text speaks for itself).
        --
        -- The [!] alpha-pulses subtly via encounterPulsePhase (set by
        -- a 0.4s ticker, see ENCOUNTER_PULSE_COLORS). Static-bright at
        -- phase 0, dimmer at phases 1-2, back up at phase 3. Cosmetic
        -- only -- the link itself stays fully readable throughout.
        local pulseColor = ENCOUNTER_PULSE_COLORS[encounterPulsePhase] or "|cffffff00"
        headerLine = prefix .. pulseColor .. "[!]|r |cffaaaaaaview special note|r"
        clickable  = true
    else
        local tip = (boss and boss.soloTip) or step.soloTip or ""
        tip = tip:gsub("%.$", "")
        tip = HighlightNames(tip)
        headerLine = prefix .. tip
        clickable  = true
    end

    -- Achievements + Special Loot render unconditionally below.
    local achBlock = BuildAchievementsBlock(boss) or ""
    local specialBlock = ""
    if boss then
        local special = BuildSpecialLootSection(boss)
        if special then
            specialBlock = special
        end
    end

    return headerLine, achBlock, specialBlock, clickable
end

-- Slots that have no transmog value -- exclude from display entirely
local TRANSMOG_EXCLUDED_SLOTS = {
    ["Neck"]           = true,
    ["Finger"]         = true,
    ["Trinket"]        = true,
    ["Non-equippable"] = true,
    ["Unknown"]        = true,
}

-- Difficulty display order and labels
local DIFF_ORDER  = { 17, 14, 15, 16 }   -- LFR, Normal, Heroic, Mythic
local DIFF_LETTER = {
    [17] = "LFR",
    [14] = "N",
    [15] = "H",
    [16] = "M",
}
-- Full names used in the "Current difficulty: <name>" header line.
local DIFF_NAME = {
    [17] = "Raid Finder",
    [14] = "Normal",
    [15] = "Heroic",
    [16] = "Mythic",
}

-- Four-state colours for difficulty dots:
--   COLLECTED -> you have this exact source learned
--   SHARED    -> you have the same appearance from a DIFFERENT item
--                (tier recolor, world drop, etc.)
--   ACTIVE    -> uncollected everywhere, and this is your current difficulty
--   INACTIVE  -> uncollected everywhere, and this is a different difficulty
local DOT_COLLECTED   = "ff00ff00"   -- bright green
local DOT_SHARED      = "ffbf9000"   -- amber / gold
local DOT_ACTIVE      = "ffffffff"   -- white
local DOT_INACTIVE    = "ff555555"   -- dim gray

-- WoW class IDs (1-13) -> token used as a key into LOCALIZED_CLASS_NAMES_MALE
-- and RAID_CLASS_COLORS. Built once at file load by calling GetClassInfo
-- for each known class ID.
--
-- WARNING: do NOT build this from CLASS_SORT_ORDER. CLASS_SORT_ORDER is a
-- display-order list (e.g. sorted by localized name), NOT an ID-indexed
-- table -- so CLASS_SORT_ORDER[1] is "Death Knight" in many locales, not
-- "Warrior" (classID=1). Using it as a lookup was the cause of the
-- tier-row class mislabeling bug (Luminous Chevalier's Robes showing as
-- "Death Knight Tier" when its classes={2} should say Paladin).
--
-- GetClassInfo(classID) returns (className, classTag, classID) -- the
-- second return value is the UPPERCASE token ("WARRIOR", "DEATHKNIGHT",
-- etc.) which is what RAID_CLASS_COLORS + LOCALIZED_CLASS_NAMES_MALE
-- key on. Class IDs 1..13 are stable across all locales.
local CLASS_ID_TO_TOKEN = {}
if GetClassInfo then
    for classID = 1, 13 do
        local _, classTag = GetClassInfo(classID)
        if classTag then CLASS_ID_TO_TOKEN[classID] = classTag end
    end
end

local function ClassNameForID(classID)
    local token = CLASS_ID_TO_TOKEN[classID]
    if token and LOCALIZED_CLASS_NAMES_MALE then
        return LOCALIZED_CLASS_NAMES_MALE[token]
    end
end

-------------------------------------------------------------------------------
-- Transmog: source resolution + collection check
-------------------------------------------------------------------------------

-- Returns true if the player has the specific appearance source.
local function HasSource(sourceID)
    if not sourceID or not C_TransmogCollection then return false end
    return C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) == true
end

-- Returns true if the appearance (visual) is collected on this character,
-- regardless of which item source granted it.
--
-- Mirrors the approach CanIMogIt uses: enumerate every source for the
-- appearance and check if any are known. We use `pairs` (not `ipairs`)
-- because GetAllAppearanceSources returns a table that is not always a
-- contiguous array -- ipairs would stop at the first gap and under-report.
--
-- We previously tried this with `ipairs` and wrongly concluded the function
-- returns too few entries; it actually returned the entries, we just weren't
-- reading past the gaps.
local function HasAppearanceViaAnySource(appearanceID)
    if not appearanceID or not C_TransmogCollection then return false end
    local sourceIDs = C_TransmogCollection.GetAllAppearanceSources(appearanceID)
    if not sourceIDs then return false end
    for _, srcID in pairs(sourceIDs) do
        if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(srcID) == true then
            return true
        end
    end
    return false
end

-- Returns the appearance ID (visual ID) for an item by its itemID.
-- We use GetItemInfo(itemID) rather than GetSourceInfo(sourceID) because
-- the latter appears to return nil for sources the current character
-- hasn't personally collected -- breaking our shared-appearance detection
-- for the exact case we care about (items the player doesn't have).
-- GetItemInfo is based on the item itself and always returns the pair.
local appearanceIDCache = {}

local function GetAppearanceIDForItem(itemID)
    if not itemID or not C_TransmogCollection then return nil end
    if appearanceIDCache[itemID] ~= nil then
        return appearanceIDCache[itemID] or nil   -- false -> nil
    end
    local appearanceID = C_TransmogCollection.GetItemInfo(itemID)
    appearanceIDCache[itemID] = appearanceID or false
    return appearanceID
end

-- Returns the appearance ID (visual ID) for a SPECIFIC sourceID. Unlike
-- GetAppearanceIDForItem (which resolves via the itemID and thus always
-- returns the Normal-difficulty appearance for tier rows whose schema
-- collapses 4 difficulties under one itemID), this resolves per-source --
-- LFR/N/H/M each have distinct appearance IDs for tier pieces, and this
-- is the only way to reach them.
--
-- We use GetAppearanceInfoBySource (returns a struct with .appearanceID)
-- rather than GetSourceInfo(sourceID).itemAppearanceID, because the
-- itemAppearanceID field has been observed to return nil in current retail
-- (11.0.x) even for sources the character has personally collected, making
-- it useless as an appearance resolver. GetAppearanceInfoBySource works
-- cleanly for both collected and uncollected sources, including sources
-- belonging to items the current character's class cannot equip
-- (verified: Warlock probing Priest tier helm sourceIDs returns correct
-- per-difficulty appearance IDs).
--
-- Callers MUST still handle nil in case the sourceID is invalid or the
-- API returns nothing -- fall back to GetAppearanceIDForItem in that case.
local sourceAppearanceIDCache = {}

local function GetAppearanceIDForSource(sourceID)
    if not sourceID or not C_TransmogCollection then return nil end
    if sourceAppearanceIDCache[sourceID] ~= nil then
        return sourceAppearanceIDCache[sourceID] or nil   -- false -> nil
    end
    local appearanceID
    if C_TransmogCollection.GetAppearanceInfoBySource then
        local info = C_TransmogCollection.GetAppearanceInfoBySource(sourceID)
        appearanceID = info and info.appearanceID
    end
    sourceAppearanceIDCache[sourceID] = appearanceID or false
    return appearanceID
end

-- Returns one of: "collected", "shared", "missing"
-- "collected" -> this exact source is known
-- "shared"    -> this source's appearance is known via another source
-- "missing"   -> neither; player truly doesn't have the look
--
-- Appearance resolution: we FIRST try GetSourceInfo(sourceID) so each
-- per-difficulty dot checks against its OWN appearance ID. This matters for
-- tier rows whose 4 difficulty variants have distinct appearances (our
-- schema collapses them under one itemID, which would otherwise make us
-- always check the Normal-difficulty appearance regardless of which dot
-- we're rendering -- causing LFR/H/M dots to falsely go gold when Normal
-- is learned). If GetSourceInfo returns nil (sources the character hasn't
-- collected can return nil; see GetAppearanceIDForItem comment), we fall
-- back to the itemID path -- preserving prior behavior for non-tier items
-- where all 4 sourceIDs share one appearance anyway.
local function CollectionStateForSource(sourceID, itemID)
    if not sourceID then return "missing" end
    if HasSource(sourceID) then return "collected" end
    local appearanceID = GetAppearanceIDForSource(sourceID)
                      or GetAppearanceIDForItem(itemID)
    if appearanceID and HasAppearanceViaAnySource(appearanceID) then
        return "shared"
    end
    return "missing"
end

-- Fallback when an item has no `sources` table populated yet: check via the
-- shared-itemID path. Returns "collected", "shared", or "missing" as above.
local function FallbackStateForItem(itemID)
    if not itemID or not C_TransmogCollection then return "missing" end
    local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemID)
    if sourceID and HasSource(sourceID) then return "collected" end
    if appearanceID and HasAppearanceViaAnySource(appearanceID) then return "shared" end
    if C_TransmogCollection.PlayerHasTransmog(itemID) == true then return "shared" end
    return "missing"
end

-- Expose the state-computing helpers on the RR namespace so diagnostic
-- commands (like /rr tmogaudit in Core.lua) can use the exact same logic
-- the UI uses at render time. Without this, diagnostics would reimplement
-- the state logic and silently drift from the UI over time.
RR.CollectionStateForSource = CollectionStateForSource
RR.FallbackStateForItem     = FallbackStateForItem

-------------------------------------------------------------------------------
-- Special Loot: mount / pet / toy / decor collection state
--
-- Items like the Jailer's "Fractal Cypher of the Zereth Overseer" (teaches
-- the Zereth Overseer mount) are non-equippable collectibles that don't
-- participate in the transmog system. They get their own schema field
-- `specialLoot = { { id, kind, name, ... }, ... }` on each boss and a
-- separate render section in the main panel's encounter text.
--
-- `kind` is one of "mount", "pet", "toy", "decor". Collection state is a
-- simple boolean: collected (green) or uncollected (white). No per-
-- difficulty columns because these items don't have difficulty variants.
--
-- "decor" was added for Midnight housing system. The C_HousingCatalog
-- APIs landed in patch 11.2.7 (December 2025); earlier clients won't have
-- them. All housing calls are defensive -- the UI silently no-ops the
-- decor branch on clients without the API, so the feature degrades
-- gracefully rather than erroring.
-------------------------------------------------------------------------------

-- Kind labels and colors for the "(Mount)" / "(Pet)" / "(Toy)" / "(Decor)"
-- tag in each row. Chosen to visually distinguish the four kinds without
-- clashing with class colors or achievement yellow.
local SPECIAL_KIND_LABEL = {
    mount      = "Mount",
    pet        = "Pet",
    toy        = "Toy",
    decor      = "Decor",
    manuscript = "Manuscript",
    illusion   = "Illusion",
}
local SPECIAL_KIND_COLOR = {
    mount      = "ff8080ff",   -- light blue
    pet        = "ffff80ff",   -- light magenta
    toy        = "ffffcc66",   -- light amber
    decor      = "ffd4a373",   -- warm cream/tan (evokes housing/home)
    manuscript = "ff7fffd4",   -- aquamarine (evokes dragonriding sky/scale)
    illusion   = "ffc8a2ff",   -- pale violet (evokes arcane weapon-enchant glow)
}

-- Colors for the state indicator:
-- collected   = green (matches tmog "collected" dot); applied to the
--               texture's color via desaturation -- but ReadyCheck-Ready
--               already renders green, so no tint needed.
-- uncollected = medium gray -- reads as "not yet collected" without
--               screaming "error." Bumped from the darker ff555555 used
--               before since the X is a plain letter rather than a
--               texture and needs more contrast to be legible.
local SPECIAL_COLLECTED   = "ff00ff00"
local SPECIAL_UNCOLLECTED = "ff888888"
-- Partial state (some-but-not-all collected) — used by the weapon-token
-- section where the "row" represents a bag of appearances (a spherule
-- pool) rather than a single appearance. Color borrowed from CIMI's
-- RED_ORANGE (constants.lua:78), which they use for ensemble rows
-- where the player has collected some-but-not-all contained
-- appearances. Distinct from our existing gold "shared" state which
-- applies to single-appearance rows owned via a sibling item.
local SPECIAL_PARTIAL     = "ffff9333"

-- Glyphs used inside the [ ] bracketed state indicator.
--
-- Earlier versions of this module used the Unicode check mark (U+2713)
-- and ballot X (U+2717), but WoW's default UI font (Friz Quadrata QT)
-- lacks glyph coverage for those code points -- they rendered as empty
-- space, producing an empty "[ ]" bracket that looks like a rendering
-- bug.
--
-- For the collected state we use the |T...|t texture-markup escape with
-- Blizzard's ReadyCheck-Ready icon (the green check used by the "Ready
-- Check" feature). Texture size 14x14 matches standard chat-line text
-- height roughly. This texture ships with the game client and is
-- universally available back to at least WotLK.
--
-- For the uncollected state we use a plain ASCII "x" letter, which
-- renders reliably in every font. Contrast comes from color (medium
-- gray) rather than glyph choice. The visual vocabulary is slightly
-- mixed (texture vs letter), but this works in our favor: collected
-- rows become more visually prominent than uncollected ones.
--
-- ReadyCheck-NotReady (red X texture) would match the visual vocabulary
-- on the uncollected side, but red reads as "error / something wrong"
-- rather than the neutral "not yet collected" signal we want.
local SPECIAL_GLYPH_COLLECTED   = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local SPECIAL_GLYPH_UNCOLLECTED = "X"
-- Partial glyph: Blizzard's ReadyCheck-Waiting is the yellow question-mark
-- texture used during ready checks before a player responds. Reads as
-- "in-progress / awaiting action" — semantically right for "some
-- collected" or "all gathered, not yet acted on." We recolor via
-- surrounding wrapper (see SPECIAL_PARTIAL) so the visual pops as
-- red-orange rather than the texture's native yellow.
local SPECIAL_GLYPH_PARTIAL     = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:14:14|t"

-- Returns "collected" or "missing" for a specialLoot item. Branches on
-- item.kind.
local function SpecialCollectionStateForItem(item)
    if not item or not item.id or not item.kind then return "missing" end

    if item.kind == "mount" then
        if not C_MountJournal then return "missing" end
        local mountID = item.mountID
                     or (C_MountJournal.GetMountFromItem
                         and C_MountJournal.GetMountFromItem(item.id))
        if not mountID then return "missing" end
        local _, _, _, _, _, _, _, _, _, _, isCollected =
            C_MountJournal.GetMountInfoByID(mountID)
        return isCollected and "collected" or "missing"

    elseif item.kind == "pet" then
        if not C_PetJournal then return "missing" end
        local speciesID = item.speciesID
        if not speciesID and C_PetJournal.GetPetInfoByItemID then
            speciesID = select(13, C_PetJournal.GetPetInfoByItemID(item.id))
        end
        if not speciesID then return "missing" end
        local numCollected = C_PetJournal.GetNumCollectedInfo(speciesID)
        return (numCollected and numCollected > 0) and "collected" or "missing"

    elseif item.kind == "toy" then
        if PlayerHasToy and PlayerHasToy(item.id) then
            return "collected"
        end
        return "missing"

    elseif item.kind == "manuscript" then
        -- Drakewatcher Manuscripts are consumable items: clicking one
        -- casts a "Deciphering" spell whose only effect is to flag a
        -- hidden quest as complete on the current character. The item
        -- is gone after use, but the quest flag persists for life --
        -- so the durable "is the unlock learned?" check is
        -- IsQuestFlaggedCompleted(questID).
        --
        -- Per-character (not account-wide). That's intentional and
        -- matches the rest of RetroRuns' "what does THIS character
        -- still need?" model.
        --
        -- 12.x exposes both the namespaced C_QuestLog form and the
        -- legacy global. Prefer the namespaced one when available,
        -- fall back to the global for safety on older clients.
        if not item.questID then return "missing" end
        local fn = (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted)
                   or IsQuestFlaggedCompleted
        if not fn then return "missing" end
        local ok, completed = pcall(fn, item.questID)
        return (ok and completed) and "collected" or "missing"

    elseif item.kind == "illusion" then
        -- Weapon-enchant illusions are tracked separately from item
        -- transmog appearances. The collection-state lookup is by
        -- the illusion's sourceID (NOT itemID). Schema requires
        -- item.sourceID; without it we can't probe and return
        -- missing.
        --
        -- Two-tier defensive lookup. The 11.x API exposes
        -- C_TransmogCollection.GetIllusions() which returns a
        -- TransmogIllusionInfo[] where each entry has sourceID,
        -- visualID, and isCollected (verified in v1.7 EN bring-up
        -- via /run dump). We iterate and match by sourceID, which
        -- works regardless of whether GetIllusionInfo(sourceID)
        -- exists as a single-item probe. Cost is O(N) over ~64
        -- illusions which is trivial.
        if not item.sourceID then return "missing" end
        if not C_TransmogCollection or not C_TransmogCollection.GetIllusions then
            return "missing"
        end
        local ok, list = pcall(C_TransmogCollection.GetIllusions)
        if not ok or type(list) ~= "table" then return "missing" end
        for _, info in ipairs(list) do
            if info.sourceID == item.sourceID then
                return info.isCollected and "collected" or "missing"
            end
        end
        return "missing"

    elseif item.kind == "decor" then
        -- C_HousingCatalog landed in 11.2.7 (Dec 2025). On earlier
        -- clients, or if the API is unavailable for any reason, we
        -- return "missing" so the UI still renders but never claims
        -- collected -- safer than crashing or silently omitting the row.
        --
        -- The canonical collection-state probe is
        -- C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
        -- where decorID is the decor's catalog record ID (NOT the itemID).
        -- The first argument 1 is the catalog category for decor; the
        -- third argument requests the full info struct. Pattern verified
        -- against the HomeBound and DecorVendor addons, which both treat
        -- this as the authoritative call.
        --
        -- The returned info table has these collection-state fields:
        --   info.quantity              -- copies currently in the player's catalog
        --   info.remainingRedeemable   -- account-bound copies awaiting redemption
        --   info.numPlaced             -- copies currently placed in housing plots
        --   info.firstAcquisitionBonus -- 0 once the first-acquisition bonus has
        --                                 been claimed (= ever-collected indicator)
        -- A decor counts as collected if ANY of quantity/remainingRedeemable/
        -- numPlaced is positive, OR if firstAcquisitionBonus has been claimed
        -- (== 0). The union covers both "have it now" and "had it at some point."
        if not C_HousingCatalog then return "missing" end
        if not C_HousingCatalog.GetCatalogEntryInfoByRecordID then return "missing" end

        -- decorID is the lookup key. The schema accepts it as an explicit
        -- field on the specialLoot row (preferred -- avoids a runtime
        -- itemID -> decorID resolution); without it, we have no reliable
        -- way to look up the catalog entry, since GetCatalogEntryInfoByItem
        -- does not return a usable decorID field.
        local decorID = item.decorID
        if not decorID then return "missing" end

        local ok, info = pcall(
            C_HousingCatalog.GetCatalogEntryInfoByRecordID, 1, decorID, true)
        if not ok or not info then return "missing" end

        local quantity            = info.quantity or 0
        local remainingRedeemable = info.remainingRedeemable or 0
        local numPlaced           = info.numPlaced or 0
        local bonusClaimed        = info.firstAcquisitionBonus == 0

        if quantity > 0 or remainingRedeemable > 0 or numPlaced > 0 or bonusClaimed then
            return "collected"
        end
        return "missing"
    end

    return "missing"
end

RR.SpecialCollectionStateForItem = SpecialCollectionStateForItem

-- Builds the Special Loot section for a boss. Returns a string or nil.
-- Nil means "don't emit a section header" -- used when the boss has no
-- specialLoot entries at all.
--
-- Rows look like:
--   * <ItemLink> (Mount)
-- with the bullet and link colored by collection state. The item link
-- comes from GetItemInfo so clicking it opens the Blizzard tooltip; if
-- GetItemInfo's cache isn't warm yet we fall back to a plain-text name.
--
-- Assigns to the forward-declared `BuildSpecialLootSection` local from
-- near the top of the file, not a new `local function`, because
-- BuildEncounterText (defined much earlier) needs to close over this
-- name.
BuildSpecialLootSection = function(boss)
    if not boss or not boss.specialLoot or #boss.specialLoot == 0 then
        return nil
    end

    local lines = { ("|cff%sSpecial Loot:|r"):format(C_LABEL) }
    for _, item in ipairs(boss.specialLoot) do
        -- For items with a barter group (e.g. Iskaara Trader's Ottuk, which
        -- is purchased from an NPC for two neck-slot ingredients looted
        -- from other bosses), we need a different layout:
        --
        --   While farming (held < total):
        --     [ X ] Iskaara Trader's Ottuk (Mount -- 1/2 necks in bags)
        --         [ X ] Terros's Captive Core (in bags: yes)
        --         [ X ] Eye of the Vengeful Hurricane (in bags: no)
        --
        --   Ready to trade (held == total):
        --     [ check ] Iskaara Trader's Ottuk (Mount -- 2/2 necks, ready to trade!)
        --         [ check ] Terros's Captive Core (in bags: yes)
        --         [ check ] Eye of the Vengeful Hurricane (in bags: yes)
        --         Trade at Tattukiaka in Iskaara (Azure Span 14, 50).
        --
        -- When the mount is already collected, we skip the barter details
        -- entirely and fall through to the simple "(Mount)" display, because
        -- there's nothing left for the player to do.
        local mountCollected = false
        if item.barter and item.kind == "mount" and C_MountJournal then
            local mountID = item.mountID
                         or (C_MountJournal.GetMountFromItem
                             and C_MountJournal.GetMountFromItem(item.id))
            if mountID then
                local _, _, _, _, _, _, _, _, _, _, isCollected =
                    C_MountJournal.GetMountInfoByID(mountID)
                mountCollected = isCollected and true or false
            end
        end

        if item.barter and not mountCollected then
            -- Barter progress path. Count ingredients held in bags.
            local total = #item.barter.ingredients
            local held  = 0
            local ingredientHeld = {}  -- [idx] = boolean
            for idx, ing in ipairs(item.barter.ingredients) do
                local count = GetItemCount(ing.id, false) or 0
                local has   = count > 0
                ingredientHeld[idx] = has
                if has then held = held + 1 end
            end

            -- State of the mount row itself.
            --
            -- "Ready to trade" (held == total but mount not yet learned)
            -- uses the SAME partial glyph/color as the in-progress
            -- (held > 0 < total) state. Both are "you have work to do
            -- here": for 1/2, get the other neck; for 2/2, walk to the
            -- trader. The ONLY thing that should flip a row to the
            -- collected-green state is actually owning the mount, which
            -- is handled by the mountCollected branch above (entire
            -- barter block is skipped, falls through to standard
            -- single-row "(Mount)" render).
            --
            -- The text suffix disambiguates the two partial sub-states:
            -- "1/2 necks in bags" vs "2/2 necks, ready to trade!".
            local parenSuffix
            local stateColor, stateGlyph
            if held == total then
                stateColor, stateGlyph = SPECIAL_PARTIAL,     SPECIAL_GLYPH_PARTIAL
                parenSuffix = ("Mount -- %d/%d necks, ready to trade!"):format(held, total)
            elseif held > 0 then
                stateColor, stateGlyph = SPECIAL_PARTIAL,     SPECIAL_GLYPH_PARTIAL
                parenSuffix = ("Mount -- %d/%d necks in bags"):format(held, total)
            else
                stateColor, stateGlyph = SPECIAL_UNCOLLECTED, SPECIAL_GLYPH_UNCOLLECTED
                parenSuffix = ("Mount -- %d/%d necks in bags"):format(held, total)
            end

            local kindColor  = SPECIAL_KIND_COLOR[item.kind] or "ffaaaaaa"
            local _, itemLink = GetItemInfo(item.id)
            local display    = itemLink or item.name or ("Item "..tostring(item.id))

            table.insert(lines,
                ("|cff777777[ |r|c%s%s|r|cff777777 ]|r %s |c%s(%s)|r"):format(
                    stateColor, stateGlyph, display, kindColor, parenSuffix))

            -- Nested ingredient rows. Indented with a leading spacer so they
            -- visually group under the parent mount row. Color scheme for
            -- the inner state indicator mirrors the parent's vocabulary:
            -- green check = ingredient in bags, gray X = not in bags.
            for idx, ing in ipairs(item.barter.ingredients) do
                local has = ingredientHeld[idx]
                local ingColor = has and SPECIAL_COLLECTED  or SPECIAL_UNCOLLECTED
                local ingGlyph = has and SPECIAL_GLYPH_COLLECTED or SPECIAL_GLYPH_UNCOLLECTED
                local _, ingLink = GetItemInfo(ing.id)
                local ingDisplay = ingLink or ing.name or ("Item "..tostring(ing.id))
                local ingSuffix  = has and "in bags" or "not in bags"
                table.insert(lines,
                    ("    |cff777777[ |r|c%s%s|r|cff777777 ]|r %s |cffaaaaaa(%s)|r"):format(
                        ingColor, ingGlyph, ingDisplay, ingSuffix))
            end

            -- Trade location hint. Only shown once both ingredients are in
            -- bags (held == total), since that's the moment the player can
            -- actually act on the location. While still farming, the
            -- trader's location is irrelevant noise. The "in bags" /
            -- "not in bags" text on each ingredient row already
            -- communicates that bag-only validation is what's being
            -- checked, so a separate caveat line was redundant and was
            -- removed in v0.6.1.
            if item.barter.at and held == total then
                table.insert(lines,
                    ("    |cffaaaaaaTrade at %s.|r"):format(item.barter.at))
            end

        else
            -- Standard (non-barter or mount-already-collected) path. Same
            -- rendering as before: single row, collected or not.
            local state = SpecialCollectionStateForItem(item)
            local isCollected = (state == "collected")
            local stateColor = isCollected and SPECIAL_COLLECTED
                                            or SPECIAL_UNCOLLECTED
            local stateGlyph = isCollected and SPECIAL_GLYPH_COLLECTED
                                            or SPECIAL_GLYPH_UNCOLLECTED

            -- Prefer the real itemLink so clicking opens the tooltip.
            -- GetItemInfo is async -- if it returns nil, fall back to the
            -- schema's name field and a plain-text display. The 1s UI
            -- heartbeat will re-render once the cache warms up.
            local _, itemLink = GetItemInfo(item.id)
            local display = itemLink or item.name or ("Item "..tostring(item.id))

            local kindLabel = SPECIAL_KIND_LABEL[item.kind] or item.kind or "?"
            local kindColor = SPECIAL_KIND_COLOR[item.kind] or "ffaaaaaa"

            -- Build the parenthetical kind+restriction group. Most items
            -- are just "(Pet)"; Mythic-only items become
            -- "(Pet, Mythic only)" with the restriction in the RETRO brand
            -- pink (ffF259C7) so the gate is scannable at a glance. We
            -- avoid Blizzard's epic-quality purple (ffa335ee) here because
            -- it's identical to the color the item link itself renders in,
            -- which makes "Mythic only" visually blur into the item name.
            -- The colored suffix is spliced inside the kindColor wrapper so
            -- the parens themselves stay the kind's color.
            local kindInner = kindLabel
            if item.mythicOnly then
                -- Close kindColor, insert RETRO-pink "Mythic only",
                -- reopen kindColor for the closing paren. The comma
                -- stays in kindColor so the parenthetical reads as one
                -- visually-connected group.
                kindInner = kindLabel .. ", |r|cffF259C7Mythic only|r|c" .. kindColor
            end

            -- Bracketed state indicator goes BEFORE the name, matching the
            -- visual language of the transmog section's per-difficulty dot
            -- row: "|cff777777[ |r" ... "|cff777777 ]|r" with a glyph
            -- inside. Collected = green check texture (Blizzard ReadyCheck
            -- icon); uncollected = gray letter "X". See the glyph constants
            -- above for why we don't use Unicode U+2713 / U+2717.
            --
            -- Render the itemLink (with its native quality color) in BOTH
            -- collected and uncollected states so the row is clickable
            -- either way. Players still want to inspect an item they
            -- already own (preview the appearance, check stats, link it
            -- to chat). The [check] vs [X] state indicator + state-colored
            -- glyph on the left already disambiguates collection state
            -- visually -- the name text doesn't also need to gray out.
            --
            -- Earlier iterations rendered collected rows as plain gray
            -- text to de-emphasize "stop looking here," but that stripped
            -- click-to-tooltip access -- a real loss for illusions / decor
            -- / toys where players still want quick tooltip access (e.g.
            -- checking the appearance preview before placing a decor, or
            -- linking an illusion to a friend in chat). The auto-color-
            -- by-quality behavior of itemLinks (which is why a strip-and-
            -- rewrap gray approach didn't work) is now a feature rather
            -- than a bug: collected items keep their quality color and
            -- stay clickable.
            local nameRender = display

            table.insert(lines,
                ("|cff777777[ |r|c%s%s|r|cff777777 ]|r %s |c%s(%s)|r"):format(
                    stateColor, stateGlyph, nameRender, kindColor, kindInner))
        end
    end
    return table.concat(lines, "\n")
end

-- Is the item relevant to the current player?
-- Regular items: always. Tier items: only if player's class is in item.classes,
-- UNLESS the user has toggled "show all classes" in the tmog browser
-- (RetroRunsDB.showAllTierClasses) -- useful for multi-class players who
-- want to see other tier sets.
local function ItemIsForPlayer(item)
    if not item.classes then return true end
    if RR:GetSetting("showAllTierClasses") then return true end
    local _, _, classID = UnitClass("player")
    for _, cid in ipairs(item.classes) do
        if cid == classID then return true end
    end
    return false
end

-- Is an item a "display candidate" for the transmog popup?
local function ItemIsTransmogCandidate(item)
    if TRANSMOG_EXCLUDED_SLOTS[item.slot] then return false end
    if not ItemIsForPlayer(item) then return false end
    return true
end

-- Is the "active" (current in-game) difficulty known to be one of the four
-- tracked ones? Used to choose the white vs gray dot colour.
local function ActiveDifficulty()
    return RR.state and RR.state.currentDifficultyID
end

-- Returns the rolled-up state of an item across ALL its difficulty
-- buckets. Used by the in-raid summary line so that line agrees with
-- the Tmog browser's per-dot rendering.
--
-- Strict rollup definition:
--   complete -> every populated bucket is `collected` (all green dots in
--               the Tmog browser)
--   needed   -> at least one bucket is `missing` (gray dot)
--   shared   -> no buckets are missing, but at least one is `shared`
--               (amber dot)
--
-- For binary items (1 unique source cloned across 4 buckets), all 4
-- buckets resolve identically -- this collapses to the same answer as
-- evaluating the single source.
--
-- For items with no `sources` table (special-loot mishaps that route
-- through here, hand-edited entries), falls through to FallbackStateForItem
-- which gives a single state with no per-bucket logic.
--
-- Earlier implementation checked ONLY the player's active difficulty,
-- which produced false "All appearances collected!" summaries when a
-- Mythic-zoned player had all Mythic sources collected but was missing
-- LFR/N/H sources. Now uses a strict per-difficulty rollup.
local DIFFS_FOR_SUMMARY = { 17, 14, 15, 16 }
local function ItemSummaryState(item)
    if not item.sources then
        return FallbackStateForItem(item.id)
    end
    local hasMissing = false
    local hasShared = false
    local hasAnyBucket = false
    for _, diffID in ipairs(DIFFS_FOR_SUMMARY) do
        local src = item.sources[diffID]
        if src then
            hasAnyBucket = true
            local s = CollectionStateForSource(src, item.id)
            if s == "missing" then
                hasMissing = true
            elseif s == "shared" then
                hasShared = true
            end
        end
    end
    if not hasAnyBucket then
        -- All buckets nil -- fall through to item-level check.
        return FallbackStateForItem(item.id)
    end
    if hasMissing then return "missing" end
    if hasShared  then return "shared"  end
    return "collected"
end

-------------------------------------------------------------------------------
-- Summary builder (main panel)
-------------------------------------------------------------------------------

-- Count items where the specified difficulty bucket is missing/shared.
-- Returns (needed, shared, total). Only counts items that HAVE a source
-- for the given difficulty; items with no source for that difficulty
-- (some raids have fewer variants) are skipped entirely, not counted.
local function CountBossLootForDifficulty(boss, diffID)
    if not boss or not boss.loot or #boss.loot == 0 then return nil end
    if not diffID then return nil end
    local needed, shared, total = 0, 0, 0
    for _, item in ipairs(boss.loot) do
        if ItemIsTransmogCandidate(item) then
            -- Only items WITH a source for this difficulty are countable.
            local src = item.sources and item.sources[diffID]
            if src then
                total = total + 1
                local s = CollectionStateForSource(src, item.id)
                if s == "missing" then
                    needed = needed + 1
                elseif s == "shared" then
                    shared = shared + 1
                end
            elseif not item.sources then
                -- Items without any sources table fall through to the
                -- item-level check; counted as a single undifferentiated
                -- unit under every difficulty that reaches this path.
                total = total + 1
                local s = FallbackStateForItem(item.id)
                if s == "missing" then
                    needed = needed + 1
                elseif s == "shared" then
                    shared = shared + 1
                end
            end
        end
    end
    if total == 0 then return nil end
    return needed, shared, total
end

-- Count items where AT LEAST ONE of the given difficulty buckets is
-- missing/shared. Used for the "Other difficulties" summary row, which
-- rolls up the three non-active difficulties into a single count.
local function CountBossLootAcrossDifficulties(boss, diffIDs)
    if not boss or not boss.loot or #boss.loot == 0 then return nil end
    local needed, shared, total = 0, 0, 0
    for _, item in ipairs(boss.loot) do
        if ItemIsTransmogCandidate(item) then
            if item.sources then
                -- Evaluate each difficulty bucket in this item's sources.
                -- "hasMissing/hasShared" per-item: the item rolls up to
                -- `missing` if any listed bucket is missing, else `shared`
                -- if any is shared, else `collected`.
                local sawBucket, hasMissing, hasShared = false, false, false
                for _, diffID in ipairs(diffIDs) do
                    local src = item.sources[diffID]
                    if src then
                        sawBucket = true
                        local s = CollectionStateForSource(src, item.id)
                        if s == "missing" then
                            hasMissing = true
                        elseif s == "shared" then
                            hasShared = true
                        end
                    end
                end
                if sawBucket then
                    total = total + 1
                    if hasMissing then
                        needed = needed + 1
                    elseif hasShared then
                        shared = shared + 1
                    end
                end
            else
                -- No sources table: falls through to item-level check,
                -- counted once regardless of the diffIDs requested.
                total = total + 1
                local s = FallbackStateForItem(item.id)
                if s == "missing" then
                    needed = needed + 1
                elseif s == "shared" then
                    shared = shared + 1
                end
            end
        end
    end
    if total == 0 then return nil end
    return needed, shared, total
end

-- Scans an entire boss's loot and returns an aggregate count of:
--   needed   -> items in the "missing" state (gray dot in the Tmog browser)
--   shared   -> items in the "shared" state (amber dot)
--   total    -> total display-candidate items considered
-- Used by the dropdown label counters (CountRaidLoot, CountExpansionLoot)
-- to build the "(have/total)" badges on dropdown entries.
--
-- Semantics: if the player has an active difficulty (in a supported
-- raid, on a tracked difficulty), this returns the per-difficulty slice
-- for that difficulty only -- matching the "Current (Mythic)" line on
-- the main-panel summary. If there's no active difficulty (browsing
-- outside a raid, or on an untracked difficulty), falls back to a
-- cross-all-difficulties rollup where an item counts as `missing` if
-- ANY of its buckets is missing, else `shared` if any is shared, else
-- collected. The fallback path matches the pre-v0.5.2 dropdown behavior
-- so numbers stay visible when browsing out of raid.
local function CountBossLoot(boss)
    if not boss or not boss.loot or #boss.loot == 0 then return nil end
    local activeID = ActiveDifficulty()
    if activeID then
        -- Per-difficulty slice. Returns nil if no items have a source
        -- for this difficulty -- in that case, fall through to the
        -- cross-all rollup rather than hiding the badge entirely.
        local n, s, t = CountBossLootForDifficulty(boss, activeID)
        if t and t > 0 then return n, s, t end
    end
    -- Fallback: cross-all-difficulties rollup via ItemSummaryState.
    local needed, shared, total = 0, 0, 0
    for _, item in ipairs(boss.loot) do
        if ItemIsTransmogCandidate(item) then
            total = total + 1
            local state = ItemSummaryState(item)
            if state == "missing" then
                needed = needed + 1
            elseif state == "shared" then
                shared = shared + 1
            end
        end
    end
    if total == 0 then return nil end
    return needed, shared, total
end

-- Format a single stats tuple (needed, shared) in the
-- "Missing (N) Shared (N)" shape. Number color is:
--   0    -> green   (user has nothing outstanding in this category)
--   1+   -> orange  (user needs / has duplicates here)
-- The category labels themselves stay at the default text color.
--
-- When BOTH categories are zero, returns a single green "Complete"
-- token instead of the Missing/Shared breakdown -- the caller can
-- emit that in place of the counts so users see explicit confirmation
-- rather than a row of zeros.
local function FormatStatsFragment(needed, shared)
    if needed == 0 and shared == 0 then
        return "|cff00ff00Complete|r"
    end
    local missingColor = (needed == 0) and "ff00ff00" or "ffff9900"
    local sharedColor  = (shared == 0) and "ff00ff00" or "ffff9900"
    return ("Missing |c%s(%d)|r Shared |c%s(%d)|r"):format(
        missingColor, needed, sharedColor, shared)
end

-- Main-panel transmog summary. Renders in the Achievements-section
-- style: a "Transmog Needed:" header line followed by dash-prefixed
-- entries for the current difficulty and the other three difficulties
-- rolled up separately. Example output:
--
--   Transmog Needed:
--   - Current (Mythic): Missing (0) Shared (1)
--   - Other difficulties: Missing (2) Shared (0)  [click to browse]
--
-- Display rules:
--   * Both dash lines always shown when active difficulty is known.
--   * Per-line: if both Missing and Shared are zero, the line reads
--     "...: Complete" (in green) instead of the zeros breakdown.
--   * Numbers: 0 renders green, 1+ renders orange.
--   * Collapses to single-line "Transmog Needed: All appearances
--     collected!" when everything is done across all four difficulties.
--   * Falls back to a single-fragment rollup if active difficulty is
--     unknown or unsupported.
local function BuildTransmogSummary(step)
    if not step then return nil end
    local boss = RR:GetBossByIndex(step.bossIndex)
    if not boss then return nil end

    local header   = ("|cff%sTransmog Needed:|r"):format(C_LABEL)
    local clickHnt = "|cff555555[click to browse]|r"
    local activeID = ActiveDifficulty()

    -- Compute the current-difficulty counts (if active difficulty known).
    local curNeeded, curShared, curTotal
    if activeID then
        curNeeded, curShared, curTotal = CountBossLootForDifficulty(boss, activeID)
    end

    -- Compute the other-difficulties counts (rollup of the 3 non-active).
    local otherIDs = {}
    for _, diffID in ipairs(DIFFS_FOR_SUMMARY) do
        if diffID ~= activeID then
            table.insert(otherIDs, diffID)
        end
    end
    local othNeeded, othShared, othTotal = CountBossLootAcrossDifficulties(boss, otherIDs)

    -- Edge case: active difficulty not set / not tracked. Fall back to
    -- a cross-all-difficulties single-line rollup.
    if not activeID or not curTotal then
        local n, s, t = CountBossLootAcrossDifficulties(boss, DIFFS_FOR_SUMMARY)
        if not t then return nil end
        if n == 0 and s == 0 then
            return header .. " |cffF259C7All appearances collected!|r"
        end
        return header .. "\n- " .. FormatStatsFragment(n, s) .. "  " .. clickHnt
    end

    -- Both counts computed. Is everything done across the board?
    local curDone = (curNeeded == 0 and curShared == 0)
    local othDone = (not othTotal) or (othNeeded == 0 and othShared == 0)
    if curDone and othDone then
        return header .. " |cffF259C7All appearances collected!|r"
    end

    -- Header + two dash lines, matching the Achievements section format.
    -- Each line renders either Missing/Shared counts or "Complete".
    -- Click hint always on the last (Other difficulties) line.
    local diffName = DIFF_NAME[activeID] or tostring(activeID)
    local line1 = ("- Current (%s): %s"):format(
        diffName, FormatStatsFragment(curNeeded, curShared))
    local othFrag = othTotal
        and FormatStatsFragment(othNeeded, othShared)
        or "|cff00ff00Complete|r"
    local line2 = ("- Other difficulties: %s  %s"):format(othFrag, clickHnt)
    return header .. "\n" .. line1 .. "\n" .. line2
end

-------------------------------------------------------------------------------
-- Per-difficulty dot row builder
-------------------------------------------------------------------------------

-- Builds a "[ R | N | H | M ]" block with each letter coloured by state.
--
-- NOTE ON COLOR-CODE ESCAPING:
-- WoW parses "|r" as a reset-color sequence. To emit a literal pipe character
-- inside a colored string we must escape it as "||". The separator below uses
-- "||" which renders as a single "|" character on screen.
-------------------------------------------------------------------------------
-- Per-item loot row builder (shape-aware)
--
-- An item's "shape" is determined by counting unique non-nil sourceIDs in
-- its `sources` table:
--
--   * BINARY shape (1 unique source): single-variant item. All 4 difficulty
--     buckets clone the same sourceID; per-difficulty dots carry no extra
--     information. Renders as a single bracketed state indicator
--     `[ ✓ ]` collected / `[ ~ ]` shared / `[ X ]` missing -- same visual
--     language as the Special Loot section so the two sections feel unified.
--
--   * PER-DIFFICULTY shape (2+ unique sources): Mawsworn-tier items,
--     legendaries, per-difficulty drops. The classic `[ LFR | N | H | M ]`
--     strip with each letter colored per that difficulty's state.
--
-- Shape is intrinsic to the item's data -- no schema annotation needed.
-- Sanctum's actual distribution: 96 per-difficulty items, 1 binary
-- (Edge of Night), 1 partial (Rae'shalare, stored in ATT as bonusID
-- variants our batch rewrite didn't handle -- left under-modeled,
-- renders sensibly). Sylvanas's loot is per-difficulty despite
-- earlier notes suggesting otherwise. Future raids auto-dispatch
-- without per-boss flags.
-------------------------------------------------------------------------------

-- Count unique non-nil values in the sources table. Returns 0 if sources
-- is nil or empty, which pushes the caller into the FallbackStateForItem
-- path (binary-shape with a single state).
local function CountUniqueSources(sources)
    if not sources then return 0 end
    local seen = {}
    local count = 0
    for _, src in pairs(sources) do
        if src and not seen[src] then
            seen[src] = true
            count = count + 1
        end
    end
    return count
end

local function ItemShape(item)
    local unique = CountUniqueSources(item.sources)
    if unique <= 1 then
        return "binary"
    else
        return "perdiff"
    end
end

-- Glyphs for the binary-shape bracketed indicator. Mirrors Special Loot's
-- convention (ReadyCheck-Ready texture for collected, plain letter for
-- uncollected) and adds a centered "+" for the "shared" state unique to
-- transmog items (appearance owned via another item entirely).
--
-- BRACKET WIDTH NOTE: the ReadyCheck texture renders as a 14px-wide image
-- via the |T...:14:14|t markup, while single text characters ("X") are
-- narrower in WoW's default font (Friz Quadrata QT). To keep brackets
-- visually aligned across rows, the text glyph is padded with extra
-- spaces so "[ X ]" occupies the same horizontal space as the texture
-- variants. The padding is part of the glyph string so the color-wrapper
-- code doesn't need to know about it.
--
-- SHARED-STATE TINT: the shared glyph uses Blizzard's UI-CheckBox-Check
-- texture (a grayscale checkmark from the standard checkbox widget)
-- tinted gold via the extended |Tpath:h:w:ox:oy:cropX1:cropX2:cropY1:
-- cropY2:r:g:b|t markup. We can't tint ReadyCheck-Ready directly
-- because its native color is green -- multiplicative tint can darken
-- the green but can't shift it to gold. UI-CheckBox-Check is grayscale
-- so the rgb params produce true gold (DOT_SHARED amber, 191/144/0).
local BINARY_GLYPH_COLLECTED = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local BINARY_GLYPH_SHARED    = "|TInterface\\Buttons\\UI-CheckBox-Check:14:14:0:0:32:32:0:32:0:32:255:215:0|t"
local BINARY_GLYPH_MISSING   = " X "

-- Color/glyph for the binary row's single state indicator. Reuses Special
-- Loot's palette (SPECIAL_COLLECTED / SPECIAL_UNCOLLECTED) for the two
-- binary-native states so the two sections read identically, and uses
-- DOT_SHARED (gold) for the transmog-specific "shared" state.
local function BinaryStateRendering(state)
    if state == "collected" then
        return SPECIAL_COLLECTED,   BINARY_GLYPH_COLLECTED
    elseif state == "shared" then
        return DOT_SHARED,          BINARY_GLYPH_SHARED
    else
        return SPECIAL_UNCOLLECTED, BINARY_GLYPH_MISSING
    end
end

-- Renders a binary-shape row: "[ <glyph> ]" bracket with the glyph colored
-- per state. Single sourceID drives a single CollectionStateForSource call.
-- Defensive fallback to FallbackStateForItem when sources is nil/empty:
-- harvested data always populates sources, so this branch is unreachable
-- from current Data/*.lua files, but it remains as a safety net for
-- hand-edited entries that forgot the sources field. Without it, a typo'd
-- entry would render with state=nil and crash BinaryStateRendering.
local function BuildBinaryRow(item)
    local debugEnabled = RR:GetSetting("debug")
    local state

    local unique = CountUniqueSources(item.sources)
    if unique == 1 then
        -- Pull the one sourceID from the table (any bucket works).
        local src
        for _, s in pairs(item.sources) do src = s; break end
        state = CollectionStateForSource(src, item.id)
    else
        -- Defensive: zero unique sources (sources nil/empty). Should
        -- not occur for harvested data; covers hand-edit gaps.
        state = FallbackStateForItem(item.id)
    end

    local colour, glyph = BinaryStateRendering(state)

    if debugEnabled then
        RR._dotTrace = RR._dotTrace or {}
        RR._dotTrace[item.id] = ("item=%s (id=%d) shape=binary state=%s -> %s"):format(
            item.name or "?", item.id or 0, state, colour)
    end

    return ("|cff777777[ |r|c%s%s|r|cff777777 ]|r"):format(colour, glyph)
end

-- Renders a per-difficulty shape row: classic "[ LFR | N | H | M ]" strip
-- with each letter colored by its own difficulty's collection state.
--
-- NOTE ON COLOR-CODE ESCAPING:
-- WoW parses "|r" as a reset-color sequence. To emit a literal pipe character
-- inside a colored string we must escape it as "||". The separator below uses
-- "||" which renders as a single "|" character on screen.
local function BuildPerDiffRow(item)
    local activeDiff = ActiveDifficulty()
    local inner = {}

    -- Build a trace of what we decided per-diff so /rr tmogtrace can show
    -- where the gold-state decision is actually being made during render.
    local debugEnabled = RR:GetSetting("debug")
    local traceLines
    if debugEnabled then
        RR._dotTrace = RR._dotTrace or {}
        traceLines = {}
        table.insert(traceLines, ("item=%s (id=%d) shape=perdiff activeDiff=%s sources=%s"):format(
            item.name or "?", item.id or 0,
            tostring(activeDiff),
            item.sources and "yes" or "NO"))
    end

    for _, diffID in ipairs(DIFF_ORDER) do
        local letter = DIFF_LETTER[diffID]
        local src    = item.sources and item.sources[diffID]
        local colour

        local state = src and CollectionStateForSource(src, item.id) or "missing"

        if state == "collected" then
            colour = DOT_COLLECTED
        elseif state == "shared" then
            colour = DOT_SHARED
        elseif diffID == activeDiff then
            colour = DOT_ACTIVE
        else
            colour = DOT_INACTIVE
        end

        if traceLines then
            -- For "missing" and "shared" states, probe deeper to see which
            -- appearanceID drove the decision and what the any-known check
            -- found. (We need "shared" coverage to diagnose false-gold
            -- cases where a dot paints gold via the Normal appearance's
            -- source graph even though the dot's own per-difficulty
            -- appearance is different.)
            local detail = ""
            if src and (state == "missing" or state == "shared") then
                local srcAp  = GetAppearanceIDForSource(src)
                local itemAp = GetAppearanceIDForItem(item.id)
                local apID   = srcAp or itemAp
                local apFrom = srcAp and "source" or (itemAp and "item(fallback)" or "none")
                local all  = apID and C_TransmogCollection.GetAllAppearanceSources(apID) or nil
                local allCount, knownCount = 0, 0
                if all then
                    for _, sid in pairs(all) do
                        allCount = allCount + 1
                        if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sid) then
                            knownCount = knownCount + 1
                        end
                    end
                end
                detail = (" srcAp=%s itemAp=%s apID=%s(%s) allSources=%d knownInAll=%d"):format(
                    tostring(srcAp), tostring(itemAp),
                    tostring(apID), apFrom, allCount, knownCount)
            end
            table.insert(traceLines, ("  diff=%d letter=%s src=%s state=%s -> %s%s"):format(
                diffID, letter, tostring(src), state, colour, detail))
        end

        table.insert(inner, ("|c%s%s|r"):format(colour, letter))
    end

    if traceLines then
        RR._dotTrace[item.id] = table.concat(traceLines, "\n")
    end

    local sep = "|cff555555 || |r"
    return "|cff777777[ |r"
        .. table.concat(inner, sep)
        .. "|cff777777 ]|r"
end

-- Shape-aware dispatcher. Picks the renderer based on the item's sourceID
-- uniqueness count. BuildDotRow is retained as the public name so any
-- existing callers continue to work.
local function BuildDotRow(item)
    if ItemShape(item) == "binary" then
        return BuildBinaryRow(item)
    else
        return BuildPerDiffRow(item)
    end
end

-------------------------------------------------------------------------------
-- Full-detail popup builder
-------------------------------------------------------------------------------

-- Token families: class IDs that can use each token, plus the slot type
-- (Main-Hand or Off-Hand / Held-in-Off-Hand / Shield). Used by the
-- transmog popup/browser to render weapon-token rows for raids whose
-- tokens don't flow through the standard armor-tier-set pipeline
-- (Castle Nathria's Anima Spherules are the canonical case). Keyed on
-- the first word of the token's localized name ("Mystic Anima Spherule"
-- -> MYSTIC). Mirrors TIER_GROUPS in Harvester.lua; the duplication is
-- intentional while this path is experimental. If weapon-token rendering
-- proves useful long-term, hoist the shared metadata into a common module.
local TOKEN_FAMILY_INFO = {
    -- Castle Nathria (9.0) weapon tokens
    MYSTIC       = { classes = { 11, 3, 8 },           slotLabel = "Main-Hand" },
    ZENITH       = { classes = { 13, 10, 4, 1 },       slotLabel = "Main-Hand" },
    VENERATED    = { classes = { 2, 5, 7 },            slotLabel = "Main-Hand" },
    ABOMINABLE   = { classes = { 6, 12, 9 },           slotLabel = "Main-Hand" },
    APOGEE       = { classes = { 1, 2, 5, 10, 13 },    slotLabel = "Off-Hand"  },
    THAUMATURGIC = { classes = { 7, 8, 9, 11 },        slotLabel = "Off-Hand"  },
}

-- Returns the token family prefix ("MYSTIC" etc.) given a token's
-- localized name. Only the family half is needed; unlike armor tier
-- slots, a weapon-token's slot is fixed per family.
local function ParseTokenFamily(name)
    if not name then return nil end
    local lower = name:lower()
    for prefix in pairs(TOKEN_FAMILY_INFO) do
        if lower:find("^" .. prefix:lower() .. "[%s'%-]") then
            return prefix
        end
    end
    return nil
end

-- Builds the Covenant Sanctum vendor hint line for the Tmog browser
-- popup. Lives on its own FontString below the main text so the Flight
-- button can anchor to it cleanly (rather than overlay-positioned over
-- a line of concatenated text, which has the well-known stride-drift
-- failure modes documented in PositionExpansionToggleButton).
--
-- Returns four values:
--   text         -- formatted, colored string for the FontString, OR
--                   nil if this boss shouldn't show a sanctum line
--                   (raid has no weaponVendors at all, OR this boss
--                   doesn't drop weapon tokens). Caller hides the
--                   FontString and the Flight button when nil.
--   raid, covID  -- forwarded to RR:NavigateToSanctum on Flight click.
--                   covID is 0 if no covenant is detected.
--   vendorInfo   -- the weaponVendors[covID] entry, OR nil if the
--                   player has no covenant (covID == 0). Caller uses
--                   `vendorInfo` presence to decide whether to render
--                   the Flight button (need real coords to route to).
--
-- Arrow: plain "->" ASCII rather than U+2192 "→" because WoW's default
-- UI font (Friz Quadrata QT) doesn't carry a glyph for U+2192 -- it
-- renders as an empty box.
local function BuildSanctumLine(raid, boss)
    if not raid or not raid.weaponVendors or not boss then
        return nil
    end
    -- Boss must actually drop weapon tokens for the sanctum line to
    -- be relevant. Mirrors the gate in BuildTransmogDetail that wraps
    -- the token-section emit.
    local tokenSources = raid.tierSets and raid.tierSets.tokenSources
    if not tokenSources then return nil end
    local bossDropsTokens = false
    for _, bossIdxVal in pairs(tokenSources) do
        if type(bossIdxVal) == "table" then
            for _, bidx in ipairs(bossIdxVal) do
                if bidx == boss.index then
                    bossDropsTokens = true
                    break
                end
            end
        elseif bossIdxVal == boss.index then
            bossDropsTokens = true
        end
        if bossDropsTokens then break end
    end
    if not bossDropsTokens then return nil end

    local covID = 0
    if C_Covenants and C_Covenants.GetActiveCovenantID then
        covID = C_Covenants.GetActiveCovenantID() or 0
    end
    local vendorInfo = raid.weaponVendors[covID]
    local text
    if vendorInfo then
        local cc = vendorInfo.covenantColor or "ffffffff"
        text = ("|cff888888  -> Redeem at |r|c%s%s|r|cff888888 vendor: |r|c%s%s|r|cff888888 (|r|cffffffff%s|r|cff888888)|r"):format(
            cc, vendorInfo.covenantName,
            cc, vendorInfo.zoneMain,
            vendorInfo.zoneSub)
    else
        text = "|cffff9333  -> No covenant detected|r|cff888888 -- align to redeem weapon tokens.|r"
    end
    return text, raid, covID, vendorInfo
end

-- Renders the transmog detail body for either a routing step (current-boss
-- hover flow) or a boss object directly (browser flow). Accepts a table
-- with either a `boss` or `bossIndex` field.
BuildTransmogDetail = function(stepOrCtx)
    local boss
    if stepOrCtx and stepOrCtx.boss then
        boss = stepOrCtx.boss
    elseif stepOrCtx and stepOrCtx.bossIndex then
        boss = RR:GetBossByIndex(stepOrCtx.bossIndex)
    end
    if not boss or not boss.loot or #boss.loot == 0 then
        return "No loot data for this boss."
    end

    -- Reset per-render caches so we pick up collection changes between pops.
    appearanceIDCache = {}
    sourceAppearanceIDCache = {}

    local candidates = {}
    for _, item in ipairs(boss.loot) do
        if ItemIsTransmogCandidate(item) then
            table.insert(candidates, item)
        end
    end

    if #candidates == 0 then
        return "No transmog data for this boss."
    end

    local lines = {}

    -- Compact top line: just the player's current difficulty.
    -- (The dropdown above already names the boss, so no need to repeat it.
    -- The color legend has been moved to the bottom of the list to save
    -- vertical space above the loot -- that's the part the user scans.)
    local activeDiff  = ActiveDifficulty()
    local activeName  = activeDiff and DIFF_NAME[activeDiff]
    if activeName then
        table.insert(lines,
            ("|cff888888Current difficulty: %s|r"):format(activeName))
        table.insert(lines, "")
    end

    -- Resolve the player's class name once for the tier annotation.
    -- Normally the popup filters tier items to the player's class, so we
    -- can use the player's class name as the label. When "show all class
    -- tier" is on, item.classes may contain a class that ISN'T the player's
    -- -- in that case we look up the row's actual class and use its name.
    local _, playerClassToken, playerClassID = UnitClass("player")
    local playerClassName
    if playerClassToken and LOCALIZED_CLASS_NAMES_MALE then
        playerClassName = LOCALIZED_CLASS_NAMES_MALE[playerClassToken]
    end

    -- Bucket candidates by shape so we can render binary items first (the
    -- majority case on most bosses -- a scannable block of brackets to see
    -- "what do I have" at a glance) followed by per-difficulty items (the
    -- minority shape that warrants detailed per-diff inspection). Within
    -- each bucket, sort alphabetically by name so items are findable without
    -- knowing the data-file order.
    local binaryItems  = {}
    local perDiffItems = {}
    for _, item in ipairs(candidates) do
        if ItemShape(item) == "binary" then
            table.insert(binaryItems, item)
        else
            table.insert(perDiffItems, item)
        end
    end
    local byName = function(a, b) return (a.name or "") < (b.name or "") end
    table.sort(binaryItems,  byName)
    table.sort(perDiffItems, byName)

    -- Helper: format one item's full row ("rowIndicator  name [tier label]").
    -- Shared between both groups so the name/class-tier formatting stays
    -- consistent regardless of shape.
    local function FormatItemRow(item)
        local nameText
        if item.classes then
            -- Pick the right class name + color for the label. If item.classes
            -- has exactly one entry and it matches the player's class, use the
            -- player's class name (cheap, no lookup). Otherwise look up the
            -- actual row's class -- which happens when the "show all class
            -- tier" toggle is on.
            local rowClassID = item.classes[1]
            local className, classToken
            if rowClassID == playerClassID then
                className  = playerClassName
                classToken = playerClassToken
            else
                className  = ClassNameForID(rowClassID) or playerClassName
                classToken = CLASS_ID_TO_TOKEN[rowClassID] or playerClassToken
            end

            -- Get the standard WoW class color for this class. RAID_CLASS_COLORS
            -- returns a table with `.colorStr` formatted as "AARRGGBB" (ff-prefixed
            -- alpha), which is exactly what Blizzard chat color codes expect
            -- after the "|c" prefix.
            local classHex = "ffff8000"  -- fallback: orange (the old hardcoded color)
            if classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken] then
                local c = RAID_CLASS_COLORS[classToken]
                if c.colorStr then classHex = c.colorStr end
            end

            if className then
                nameText = ("|cffffffff%s|r |c%s(%s Tier)|r"):format(
                    item.name, classHex, className)
            else
                nameText = ("|cffffffff%s|r"):format(item.name)
            end
        else
            -- Non-tier rows render in white by default, in legendary
            -- orange when the item's GetItemInfo quality reports as
            -- legendary (quality enum 5). Matches Blizzard's own
            -- legendary text color so the row reads as legendary at
            -- a glance, not as a plain drop.
            local nameColor = "ffffffff"
            if item.id and GetItemInfo then
                local quality = select(3, GetItemInfo(item.id))
                if quality == 5 then
                    nameColor = "ffff8000"
                end
            end
            nameText = ("|c%s%s|r"):format(nameColor, item.name)

            -- Class-restricted non-tier items (e.g. Nasz'uro, the Unbound
            -- Legacy on Sarkareth) get a "(<Class> only)" suffix appended
            -- in default text color, with the class name itself colored
            -- in that class's standard WoW color. Distinct from the
            -- `item.classes` tier path above: tier rows are filtered out
            -- of the popup for non-matching classes (only visible when
            -- "Show all class tier" is on), whereas restrictedToClass
            -- items always render for everyone -- the suffix exists to
            -- communicate the restriction in-line rather than hide the
            -- row entirely. Used for legendaries with hard class gates
            -- where players want to see the appearance exists even on
            -- characters who can't equip it.
            if item.restrictedToClass then
                local rcID    = item.restrictedToClass
                local rcName  = (rcID == playerClassID and playerClassName)
                                or ClassNameForID(rcID)
                local rcToken = (rcID == playerClassID and playerClassToken)
                                or CLASS_ID_TO_TOKEN[rcID]
                if rcName then
                    local rcHex = "ffff8000"  -- fallback: orange
                    if rcToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[rcToken] then
                        local c = RAID_CLASS_COLORS[rcToken]
                        if c.colorStr then rcHex = c.colorStr end
                    end
                    -- "(|cAARRGGBB<ClassName>|r only)" -- only the class
                    -- name itself is colored; parens and "only" stay in
                    -- the default text color so the suffix reads as a
                    -- normal-toned tag rather than a louder label.
                    nameText = ("%s |cffffffff(|r|c%s%s|r|cffffffff only)|r"):format(
                        nameText, rcHex, rcName)
                end
            end
        end
        return ("%s  %s"):format(BuildDotRow(item), nameText)
    end

    -- Renders the acquisitionNote sub-line below an item row, if the
    -- item has one. Used for items with unusual acquisition mechanics
    -- (e.g. legendaries gated behind a quest-starter, items unlocked
    -- via a separate vendor exchange). Indented under the row it
    -- annotates and rendered in dim gray so it reads as commentary
    -- without competing with the row's main name.
    local function MaybeAppendAcquisitionNote(item)
        if not item.acquisitionNote then return end
        table.insert(lines, ("        |cff888888%s|r"):format(item.acquisitionNote))
    end

    -- Emit binary-shape group first.
    for _, item in ipairs(binaryItems) do
        table.insert(lines, FormatItemRow(item))
        MaybeAppendAcquisitionNote(item)
    end

    -- Blank-line separator between groups, but only if both groups have
    -- content (otherwise we'd emit a trailing blank line for no reason).
    if #binaryItems > 0 and #perDiffItems > 0 then
        table.insert(lines, "")
    end

    -- Emit per-difficulty group.
    for _, item in ipairs(perDiffItems) do
        table.insert(lines, FormatItemRow(item))
        MaybeAppendAcquisitionNote(item)
    end

    -- Weapon-token section. This is the "intelligence layer" for Castle
    -- Nathria and Sanctum of Domination, where weapons drop as tokens
    -- (Anima Spherules / Shards of Domination) rather than equippable
    -- items. The tokens are redeemed at covenant-specific vendors inside
    -- the player's Covenant Sanctum.
    --
    -- Design rationale for the 3-state (none/some/all) approach vs. a
    -- numeric X/N ratio:
    --   The weapon-token pool is covenant-partitioned -- a Kyrian
    --   Warlock's accessible subset is 6 MH + 2 OH appearances out of
    --   the raid-wide ~36 MH + ~8 OH. The denominator varies by
    --   (covenant, token-family, slot). Our harvested data doesn't
    --   capture that partitioning (TTT's seed list unions everything),
    --   so a "X/36" display over-represents what the player can actually
    --   collect without covenant-hopping. Rather than ship an
    --   over-counted denominator, we collapse to a 3-state indicator
    --   that's honest at the coarse grain ("engage this boss for weapon
    --   transmog progress, visit your vendor to redeem") without lying
    --   about specific collection math.
    --
    -- Row shape:
    --   Main-Hand Weapons:   [some collected]
    --   Off-Hand Weapons:    [all collected]
    --     -> Redeem at Kyrian vendor: Bastion (Elysian Hold)
    --
    -- No-covenant fallback:
    --     -> No covenant detected -- align to redeem weapon tokens.
    local raid = RR.currentRaid
    -- Browser may display a non-current raid; resolve raid from boss.
    if not raid or (raid.bosses and raid.bosses[boss.index] ~= boss) then
        for _, r in pairs(RetroRuns_Data or {}) do
            if r.bosses then
                for _, b in ipairs(r.bosses) do
                    if b == boss then raid = r; break end
                end
            end
            if raid and raid.bosses and raid.bosses[boss.index] == boss then break end
        end
    end

    local tokenPools   = raid and raid.weaponTokenPools
    local tokenSources = raid and raid.tierSets and raid.tierSets.tokenSources
    if tokenPools and tokenSources then
        -- Determine which slots this boss drops tokens for.
        local slotsHere = {}     -- { ["Main-Hand"]=true, ["Off-Hand"]=true }
        for tokenID, bossIdxVal in pairs(tokenSources) do
            local matches = false
            if type(bossIdxVal) == "table" then
                for _, bidx in ipairs(bossIdxVal) do
                    if bidx == boss.index then matches = true; break end
                end
            elseif bossIdxVal == boss.index then
                matches = true
            end
            if matches then
                local tokenName = (GetItemInfo(tokenID))
                local family = ParseTokenFamily(tokenName)
                local info = family and TOKEN_FAMILY_INFO[family]
                if info and info.slotLabel then
                    slotsHere[info.slotLabel] = true
                end
            end
        end

        local slotOrder = { "Main-Hand", "Off-Hand" }
        local slotPoolKeys = {
            ["Main-Hand"] = {
                "mainHandLowerNonMythic",  "mainHandHigherNonMythic",
                "mainHandLowerMythic",     "mainHandHigherMythic",
            },
            ["Off-Hand"] = {
                "offHandLowerNonMythic",   "offHandHigherNonMythic",
                "offHandLowerMythic",      "offHandHigherMythic",
            },
        }

        -- Compute the 3-state for each slot the boss contributes to.
        -- State is based on the union of all 4 same-slot pools (raid-wide
        -- total), not covenant-filtered. "some" will be the most common
        -- state for a real player.
        local tokenRows = {}
        for _, slot in ipairs(slotOrder) do
            if slotsHere[slot] then
                local keys = slotPoolKeys[slot]
                local unionSources = {}   -- appearanceID -> { sourceID, ... }
                for _, k in ipairs(keys) do
                    local pool = tokenPools[k]
                    if pool then
                        for appID, srcs in pairs(pool) do
                            local bucket = unionSources[appID]
                            if not bucket then
                                bucket = {}
                                unionSources[appID] = bucket
                            end
                            for _, sid in ipairs(srcs) do
                                local seen = false
                                for _, ex in ipairs(bucket) do
                                    if ex == sid then seen = true; break end
                                end
                                if not seen then table.insert(bucket, sid) end
                            end
                        end
                    end
                end

                -- Count collected (boolean total: any owned? any missing?)
                local hasCollected, hasUncollected = false, false
                for _, srcs in pairs(unionSources) do
                    local owned = false
                    for _, sid in ipairs(srcs) do
                        if C_TransmogCollection and
                           C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance and
                           C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sid) then
                            owned = true; break
                        end
                        if C_TransmogCollection and
                           C_TransmogCollection.GetAppearanceInfoBySource then
                            local info = C_TransmogCollection.GetAppearanceInfoBySource(sid)
                            if info and info.appearanceIsCollected then
                                owned = true; break
                            end
                        end
                    end
                    if owned then hasCollected   = true
                             else hasUncollected = true end
                    -- Early exit once we know the 3-state result.
                    if hasCollected and hasUncollected then break end
                end

                -- Map to 3-state label + color.
                local stateLabel, stateColor
                if hasCollected and not hasUncollected then
                    stateLabel, stateColor = "all collected",  SPECIAL_COLLECTED
                elseif hasCollected and hasUncollected then
                    stateLabel, stateColor = "some collected", SPECIAL_PARTIAL
                else
                    stateLabel, stateColor = "none collected", SPECIAL_UNCOLLECTED
                end

                -- Row: "<Slot> Weapons:  [<state>]"
                local label = ("%s Weapons:"):format(slot)
                table.insert(tokenRows, ("|cffffffff%s|r  |cff777777[ |r|c%s%s|r|cff777777 ]|r"):format(
                    label, stateColor, stateLabel))
            end
        end

        if #tokenRows > 0 then
            -- Blank-line separator above the token section.
            if #binaryItems > 0 or #perDiffItems > 0 then
                table.insert(lines, "")
            end
            for _, row in ipairs(tokenRows) do
                table.insert(lines, row)
            end

            -- Vendor hint line is rendered separately as its own
            -- FontString below the main text, with a Flight button
            -- anchored to it (see BuildSanctumLine and the
            -- sanctumLine widget on tmogWindow). Skipped here.
        end
    end

    -- Optional per-boss footnote(s). Used to surface collectible context
    -- that doesn't fit the existing schema -- e.g., Sarkareth's Void-Touched
    -- Curio omnitoken, which exchanges for any tier slot and so doesn't
    -- fit the fixed-slot tokenSources mapping. The footnote tells the
    -- player "yes there's more here, just not in the format the dots/
    -- checkbox represent." Rendered in light grey above the color legend
    -- (close enough to the loot list to read as commentary on it; the
    -- legend stays at the very bottom as the visual anchor).
    --
    -- The schema accepts three forms:
    --   string                   -- rendered as-is, embedded WoW markup OK
    --   { text=..., itemID=N }   -- {item} placeholder substituted with
    --                               GetItemInfo(itemID)'s real WoW item
    --                               link (clickable, hover-tooltips, shift-
    --                               clickable into chat). Cold-cache fallback
    --                               to a colored static name if GetItemInfo
    --                               returns nil before the cache warms.
    --   { {text=...,itemID=N}, {text=...,itemID=M}, ... }
    --                            -- list of footnote entries, each rendered
    --                               as its own paragraph block separated by
    --                               a blank line. Useful for bosses with
    --                               multiple unrelated extra-loot mechanics
    --                               (e.g. Sarkareth's Curio + Cracked Titan
    --                               Gem). Each entry follows the same
    --                               text/itemID rules as the single-entry form.
    if boss.tmogFootnote then
        -- Renders a single footnote entry to grey text. Returns the formatted
        -- string, or nil if the entry produces no usable text.
        local function RenderFootnoteEntry(entry)
            if type(entry) == "string" then
                return entry
            end
            if type(entry) ~= "table" then return nil end
            local sub
            if entry.itemID then
                local _, itemLink = GetItemInfo(entry.itemID)
                sub = itemLink   -- nil on cold cache; fallback below
            end
            if not sub then
                -- Cold-cache fallback: render a bracketed colored name in
                -- the WoW-link visual style. Loses clickability for this
                -- one render, but text won't be empty/broken. Subsequent
                -- renders (after the client warms the item-info cache)
                -- will produce a real link.
                local fallbackName = (entry.itemID and GetItemInfo(entry.itemID))
                                     or "(item)"
                sub = ("|cffa335ee[%s]|r"):format(fallbackName)
            end
            return (entry.text or ""):gsub("{item}", sub)
        end

        -- Detect single-entry vs list. A single entry is either a string or
        -- a table with a `text` field. A list is a table with numeric
        -- indices and no `text` field at the top level.
        local entries
        if type(boss.tmogFootnote) == "string" then
            entries = { boss.tmogFootnote }
        elseif type(boss.tmogFootnote) == "table"
               and boss.tmogFootnote.text == nil
               and boss.tmogFootnote[1] then
            entries = boss.tmogFootnote
        else
            entries = { boss.tmogFootnote }
        end

        for _, entry in ipairs(entries) do
            local footnoteText = RenderFootnoteEntry(entry)
            if footnoteText and footnoteText ~= "" then
                table.insert(lines, "")
                table.insert(lines, ("|cff9d9d9d%s|r"):format(footnoteText))
            end
        end
    end

    -- Legend at the bottom. Covers both shapes: the binary bracket's
    -- three states (collected/shared/missing) use the same color palette
    -- as the per-difficulty dots, and "white = needed now" only applies
    -- to the per-difficulty strip (binary rows don't track current
    -- difficulty since the appearance doesn't vary).
    --
    -- Renders unconditionally -- the dots have the same meaning whether
    -- the player is browsing from inside a supported raid or from
    -- elsewhere in the world. The "Current difficulty:" header above is
    -- correctly gated on activeName (no current difficulty to display
    -- when not zoned in), but the legend is just a key for the visual
    -- vocabulary and applies always.
    table.insert(lines, "")
    table.insert(lines,
        ("|c%sgreen|r|cff888888 = collected      |r|c%sgold|r|cff888888 = via another item|r"):format(
            DOT_COLLECTED, DOT_SHARED))
    table.insert(lines,
        ("|c%swhite|r|cff888888 = needed (current difficulty)  |r|c%sgray|r|cff888888 = not collected|r"):format(
            DOT_ACTIVE, DOT_INACTIVE))

    return table.concat(lines, "\n")
end

-------------------------------------------------------------------------------
-- Transmog browser: data enumeration
-------------------------------------------------------------------------------

-- Browser selection state is forward-declared near the top of this file so
-- early handlers on panel.transmog can close over it. See the declaration
-- of `browserState` up there.

-- Expansion ordering used by the transmog browser's dropdown. Newest
-- first so the most recent expansion (and its raids) appear at the top
-- of the dropdown -- matches the idle-state supported-raids list and
-- Blizzard's own EJ ordering. Within each expansion, raids are sorted
-- by patch number descending (newest patch first) via patchDescending
-- below.
local EXPANSION_ORDER_NEWEST_FIRST = {
    "Midnight",
    "The War Within",
    "Dragonflight",
    "Shadowlands",
    "Battle for Azeroth",
    "Legion",
    "Warlords of Draenor",
    "Mists of Pandaria",
    "Cataclysm",
    "Wrath of the Lich King",
    "Burning Crusade",
    "Classic",
}
-- Also expose on RR so cross-window code (Skips) can reach it without
-- duplicating the list. Originally only used by BuildIdleListText below;
-- BuildSkipsRows added a guarded read on RR.EXPANSION_ORDER_NEWEST_FIRST
-- but the hoist was never wired up, leaving Skips silently sorting raids
-- alphabetically by expansion. Wired now.
RR.EXPANSION_ORDER_NEWEST_FIRST = EXPANSION_ORDER_NEWEST_FIRST

-- Shared raid-ordering comparator. Parses a raid's `patch` field
-- (e.g. "10.2", "9.2.5") into a list of integers, then compares
-- lexicographically with the larger value winning -- so 10.2 > 10.1.0,
-- 9.2.5 > 9.2, etc. Raids missing a patch field sort last (the
-- patchKey returns { -1 } as a sentinel). Ties break alphabetically
-- by name so output is deterministic across reloads.
local function patchKey(raid)
    local p = raid.patch
    if not p then return { -1 } end
    local parts = {}
    for n in p:gmatch("(%d+)") do
        table.insert(parts, tonumber(n) or 0)
    end
    if #parts == 0 then return { -1 } end
    return parts
end
local function patchDescending(a, b)
    local ka, kb = patchKey(a), patchKey(b)
    local n = math.max(#ka, #kb)
    for i = 1, n do
        local ai = ka[i] or 0
        local bi = kb[i] or 0
        if ai ~= bi then return ai > bi end
    end
    return (a.name or "") < (b.name or "")
end

-- Gather all loaded raids grouped by expansion. Called fresh each time a
-- dropdown opens so newly-added raid data files appear without a reload.
-- Returns (byExpansion, expansions) where:
--   byExpansion[expName] = { raid, raid, ... } -- raids sorted newest patch first
--   expansions          = { expName, ... }     -- ordered newest expansion first
local function EnumerateRaids()
    local byExpansion = {}
    for _, raid in pairs(RetroRuns_Data or {}) do
        -- Skip dev-stub placeholder entries (instanceID = 0). See
        -- BuildIdleListRows for the full rationale.
        if raid.instanceID and raid.instanceID > 0 then
            local exp = raid.expansion or "Unknown"
            byExpansion[exp] = byExpansion[exp] or {}
            table.insert(byExpansion[exp], raid)
        end
    end
    for _, raids in pairs(byExpansion) do
        table.sort(raids, patchDescending)
    end
    local expansions = {}
    local seen = {}
    for _, e in ipairs(EXPANSION_ORDER_NEWEST_FIRST) do
        if byExpansion[e] then
            table.insert(expansions, e)
            seen[e] = true
        end
    end
    -- Anything left over (unknown/new expansion not yet in the order
    -- table) goes at the end so the dropdown still shows it.
    for e in pairs(byExpansion) do
        if not seen[e] then table.insert(expansions, e) end
    end
    return byExpansion, expansions
end

-- Lenient-count helpers: summed across nested levels. For dropdown labels.
local function CountRaidLoot(raid)
    if not raid or not raid.bosses then return 0, 0, 0 end
    local n, s, t = 0, 0, 0
    for _, boss in ipairs(raid.bosses) do
        local bn, bs, bt = CountBossLoot(boss)
        if bn then n, s, t = n + bn, s + bs, t + bt end
    end
    return n, s, t
end

local function CountExpansionLoot(expansion, byExpansion)
    local raids = byExpansion and byExpansion[expansion]
    if not raids then return 0, 0, 0 end
    local n, s, t = 0, 0, 0
    for _, raid in ipairs(raids) do
        local rn, rs, rt = CountRaidLoot(raid)
        n, s, t = n + rn, s + rs, t + rt
    end
    return n, s, t
end

-- Dropdown label suffix. Currently a no-op — the three browser dropdowns
-- (expansion, raid, boss) render their entries without a per-entry count.
-- Counters retained at call sites so totals can be re-surfaced later
-- (e.g. via a settings toggle) without touching dispatch.
local function FormatCountSuffix(_, _, _)
    return ""
end

local function GetBrowserSelection()
    local raid = browserState.raidKey and RR:GetRaidByInstanceID(browserState.raidKey)
    local boss
    if raid and raid.bosses and browserState.bossIndex then
        boss = raid.bosses[browserState.bossIndex]
    end
    return raid, boss
end

-- Persist the browser's last-selected (expansion, raidKey, bossIndex) to
-- SavedVariables so the browser opens on the same selection across sessions.
-- Called from RefreshAll after every dropdown change.
local function SaveBrowserState()
    RR:SetSetting("browserSelection", {
        expansion = browserState.expansion,
        raidKey   = browserState.raidKey,
        bossIndex = browserState.bossIndex,
    })
end

local function EnsureBrowserDefaults()
    local byExpansion, expansions = EnumerateRaids()
    if #expansions == 0 then return end

    -- First-priority defaults: load from SavedVariables if present. Validate
    -- that the saved raid still exists in RetroRuns_Data (the user might
    -- have removed a raid's data file since their last session).
    local saved = not browserState.raidKey and RR:GetSetting("browserSelection") or nil
    if saved then
        if saved.raidKey and RR:GetRaidByInstanceID(saved.raidKey) then
            browserState.raidKey   = saved.raidKey
            browserState.expansion = saved.expansion
                                     or RR:GetRaidByInstanceID(saved.raidKey).expansion
            browserState.bossIndex = saved.bossIndex or 1
        end
    end

    if not browserState.raidKey then
        local currentID = RR.currentRaid and RR.currentRaid.instanceID
        if currentID and RR:GetRaidByInstanceID(currentID) then
            browserState.raidKey   = currentID
            browserState.expansion = RR:GetRaidByInstanceID(currentID).expansion
        end
    end
    if not browserState.expansion then
        browserState.expansion = expansions[1]
    end
    if not browserState.raidKey then
        local firstRaid = byExpansion[browserState.expansion]
                          and byExpansion[browserState.expansion][1]
        if firstRaid then browserState.raidKey = firstRaid.instanceID end
    end
    if not browserState.bossIndex then
        local step = RR.state and RR.state.activeStep
        if step and RR.currentRaid
           and RR.currentRaid.instanceID == browserState.raidKey then
            browserState.bossIndex = step.bossIndex or 1
        else
            browserState.bossIndex = 1
        end
    end
end

-- Cache-warm pass for the Tmog browser. Walks every loot and specialLoot
-- item in the currently-selected raid (across all bosses) and calls
-- GetItemInfo to prime WoW's async item cache. Mirrors the zone-in
-- warm pass in Core.lua but covers the case where the player opens
-- the browser outside a raid (or browses to a different raid than
-- they're zoned into).
--
-- GetItemInfo's first-call behavior on a cold cache is to return nil
-- and fire GET_ITEM_INFO_RECEIVED later when the data is fetched.
-- Without this pre-warm, items that haven't been fetched recently
-- render as plain-text fallback names with no legendary orange and
-- no clickable item link the first time the popup opens.
--
-- Cheap to call repeatedly: GetItemInfo on a warm cache is a hash
-- lookup. We call it on every RefreshAll (i.e. every dropdown change)
-- so the cache stays primed regardless of which raid the user
-- navigates to.
local function WarmBrowserItemCache()
    if not GetItemInfo then return end
    local raid = browserState.raidKey and RR:GetRaidByInstanceID(browserState.raidKey)
    if not raid or not raid.bosses then return end
    for _, boss in ipairs(raid.bosses) do
        if boss.loot then
            for _, item in ipairs(boss.loot) do
                if item.id then GetItemInfo(item.id) end
            end
        end
        if boss.specialLoot then
            for _, item in ipairs(boss.specialLoot) do
                if item.id then GetItemInfo(item.id) end
            end
        end
        -- Footnote items live outside loot/specialLoot but still
        -- need their links resolved for the footnote rendering.
        if boss.tmogFootnote then
            local function WarmEntry(entry)
                if type(entry) == "table" and entry.itemID then
                    GetItemInfo(entry.itemID)
                end
            end
            if type(boss.tmogFootnote) == "table"
               and boss.tmogFootnote.text == nil
               and boss.tmogFootnote[1] then
                for _, entry in ipairs(boss.tmogFootnote) do
                    WarmEntry(entry)
                end
            else
                WarmEntry(boss.tmogFootnote)
            end
        end
    end
end

-- Throttled re-render hook for GET_ITEM_INFO_RECEIVED. The event fires
-- once per item as WoW resolves async GetItemInfo calls, which on a
-- cold cache means many events in rapid succession after the first
-- browser open. Coalesce them into one repaint per ~100ms window so
-- we don't chain hundreds of redraws back-to-back.
--
-- Only repaints when the browser is actually visible -- no point
-- redrawing a hidden frame, and the next visible RefreshAll will
-- pick up whatever's in the cache anyway.
local browserRefreshScheduled = false
function UI.RequestBrowserRefresh()
    if browserRefreshScheduled then return end
    if not (tmogWindow and tmogWindow:IsShown()) then return end
    browserRefreshScheduled = true
    C_Timer.After(0.1, function()
        browserRefreshScheduled = false
        if tmogWindow and tmogWindow:IsShown() and tmogWindow.RefreshContent then
            tmogWindow:RefreshContent()
        end
    end)
end

-------------------------------------------------------------------------------
-- Transmog popup window
-------------------------------------------------------------------------------

GetOrCreateTmogWindow = function()
    if tmogWindow then return tmogWindow end

    local f = CreateFrame("Frame", "RetroRunsTmogWindow", UIParent, "BackdropTemplate")
    -- Initial size matches POPUP_CONTENT_MIN (240) rather than a guess like
    -- 460. AutoSize will grow the frame to fit actual content on first
    -- refresh; starting small means the first visible state after Show()
    -- is either correct or mid-growth, not a visible shrink-to-fit.
    f:SetSize(440, POPUP_CONTENT_MIN)
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    -- Initial opacity reflects the user's saved setting so the first
    -- frame painted matches subsequent ApplySettings passes. Lazy
    -- windows construct after SavedVariables is loaded (user-action
    -- triggered), so reading the saved value here is safe.
    f:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    f:SetPoint("TOPLEFT", panel, "TOPRIGHT", 6, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:Hide()

    f:HookScript("OnEnter", CancelTmogHide)
    f:HookScript("OnLeave", ScheduleTmogHide)

    -- Hyperlink handlers: makes item links inside contentText (the boss's
    -- loot list, the tmogFootnote) clickable. Same pattern used by
    -- panel.encounter for Special Loot links. SetItemRef is Blizzard's
    -- global router that opens the appropriate frame for each link type
    -- (item -> tooltip, achievement -> achievement frame, etc.) and is a
    -- no-op on link types it doesn't recognize, so safe as a catch-all.
    f:SetHyperlinksEnabled(true)
    f:SetScript("OnHyperlinkClick", function(_, link, text, button)
        SetItemRef(link, text, button)
    end)
    f:SetScript("OnHyperlinkEnter", function(self, link)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    f:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -10)
    title:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  Transmog")
    title:SetFont(TITLE_FONT, 16, "")
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function()
        browserState.active = false
        f:Hide()
    end)

    -- Three cascading dropdowns: Expansion / Raid / Boss.
    -- Each refreshes its successors when changed, so selecting a new
    -- expansion resets the raid + boss dropdowns to their first entries.
    local function MakeDD(name, width, parent)
        local dd = CreateFrame("Frame", "RetroRuns" .. name .. "DD", parent, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(dd, width)
        -- Dropdown menus render as separate top-level frames; their hover
        -- isn't inherited by the popup, so we cancel the hide timer while
        -- the menu is open to prevent the popup from disappearing.
        dd.HookShowHide = function()
            local menu = _G["DropDownList1"]
            if menu then
                menu:HookScript("OnShow", CancelTmogHide)
                menu:HookScript("OnHide", ScheduleTmogHide)
            end
        end
        return dd
    end

    local ddExp  = MakeDD("Expansion", 140, f)
    local ddRaid = MakeDD("Raid",      220, f)
    local ddBoss = MakeDD("Boss",      220, f)

    ddExp:SetPoint("TOPLEFT",  f, "TOPLEFT", -4, -32)
    ddRaid:SetPoint("TOPLEFT", ddExp, "BOTTOMLEFT", 0, 4)
    ddBoss:SetPoint("TOPLEFT", ddRaid, "BOTTOMLEFT", 0, 4)

    f.ddExp, f.ddRaid, f.ddBoss = ddExp, ddRaid, ddBoss

    -- "Show all classes" checkbox -- when enabled, tier rows for ALL 12
    -- classes show up under each boss, not just the player's class. Useful
    -- for multi-class players. Persisted to RetroRunsDB.showAllTierClasses.
    local showAllCheck = CreateFrame("CheckButton", "RetroRunsShowAllTierCheck",
                                     f, "UICheckButtonTemplate")
    showAllCheck:SetPoint("TOPLEFT", ddBoss, "TOPRIGHT", 8, -4)
    showAllCheck:SetSize(20, 20)
    showAllCheck.text = showAllCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    showAllCheck.text:SetPoint("LEFT", showAllCheck, "RIGHT", 2, 1)
    showAllCheck.text:SetText("Show all class tier")
    showAllCheck:SetScript("OnShow", function(self)
        self:SetChecked(RR:GetSetting("showAllTierClasses") or false)
    end)
    showAllCheck:SetScript("OnClick", function(self)
        RR:SetSetting("showAllTierClasses", self:GetChecked() and true or false)
        if f.RefreshAll then f:RefreshAll() end
    end)
    -- Hovering the checkbox shouldn't dismiss the popup.
    showAllCheck:HookScript("OnEnter", CancelTmogHide)
    showAllCheck:HookScript("OnLeave", ScheduleTmogHide)
    f.showAllCheck = showAllCheck

    -- Content text sits directly on the popup (no scroll frame). The popup
    -- auto-sizes to fit whatever the current boss produces, so there's no
    -- need for scrolling in practice.
    local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT",     ddBoss, "BOTTOMLEFT", 22, -10)
    text:SetPoint("TOPRIGHT",    f,      "TOPRIGHT",   -14, 0)   -- width only
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetWordWrap(true)

    f.contentText = text

    -- Sanctum vendor line. Lives on its own FontString below the
    -- main content text so the Flight button can anchor cleanly
    -- against rendered text width (no overlay positioning, no
    -- stride-drift bugs -- same lesson PositionEntranceButton
    -- encodes for the idle list). Width matches the main text so
    -- wrapping behaves consistently. Hidden when BuildSanctumLine
    -- returns nil (boss doesn't drop weapon tokens, or raid has no
    -- weaponVendors -- non-CN raids).
    local sanctumLine = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sanctumLine:SetPoint("TOPLEFT",  text, "BOTTOMLEFT",  0, -8)
    sanctumLine:SetPoint("TOPRIGHT", f,    "TOPRIGHT",   -14, 0)   -- width only
    sanctumLine:SetJustifyH("LEFT")
    sanctumLine:SetJustifyV("TOP")
    sanctumLine:SetWordWrap(true)
    sanctumLine:Hide()
    f.sanctumLine = sanctumLine

    -- Flight button anchored against the sanctum line's RENDERED text
    -- width (GetStringWidth, not the FontString's frame width which
    -- spans the popup). Same FlightMaster minimap-tracking texture as
    -- the entrance buttons in the idle list. Hidden by default;
    -- RefreshContent decides whether to show it based on whether the
    -- player's covenant has a vendor entry with concrete coords.
    local sanctumBtn = CreateFrame("Button", nil, f)
    sanctumBtn:RegisterForClicks("LeftButtonUp")
    sanctumBtn:SetFrameLevel((f:GetFrameLevel() or 0) + 10)
    sanctumBtn:SetNormalTexture("Interface\\Minimap\\Tracking\\FlightMaster")
    sanctumBtn:SetHighlightTexture(
        "Interface\\Minimap\\Tracking\\FlightMaster", "ADD")
    sanctumBtn:Hide()
    sanctumBtn:HookScript("OnEnter", CancelTmogHide)
    sanctumBtn:HookScript("OnLeave", ScheduleTmogHide)
    f.sanctumButton = sanctumBtn

    tmogWindow = f

    -- Dropdown initializers (defined after f exists so they can reference it).
    f.RefreshDropdowns = function(self)
        EnsureBrowserDefaults()
        local byExp, expList = EnumerateRaids()

        -- Expansion dropdown
        UIDropDownMenu_Initialize(ddExp, function()
            for _, expName in ipairs(expList) do
                local n, s, t = CountExpansionLoot(expName, byExp)
                local info = UIDropDownMenu_CreateInfo()
                info.text = expName .. FormatCountSuffix(n, s, t)
                info.value = expName
                info.checked = (expName == browserState.expansion)
                info.func = function()
                    if browserState.expansion == expName then return end
                    browserState.expansion = expName
                    -- Pick first raid + first boss in the new expansion.
                    local first = byExp[expName] and byExp[expName][1]
                    browserState.raidKey   = first and first.instanceID or nil
                    browserState.bossIndex = 1
                    f:RefreshAll()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetText(ddExp, browserState.expansion or "(none)")

        -- Raid dropdown (within current expansion)
        UIDropDownMenu_Initialize(ddRaid, function()
            local raids = byExp[browserState.expansion] or {}
            for _, raid in ipairs(raids) do
                local n, s, t = CountRaidLoot(raid)
                local info = UIDropDownMenu_CreateInfo()
                info.text = (raid.name or "?") .. FormatCountSuffix(n, s, t)
                info.value = raid.instanceID
                info.checked = (raid.instanceID == browserState.raidKey)
                info.func = function()
                    if browserState.raidKey == raid.instanceID then return end
                    browserState.raidKey   = raid.instanceID
                    browserState.bossIndex = 1
                    f:RefreshAll()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        local raidName = "(none)"
        local selRaid = browserState.raidKey and RR:GetRaidByInstanceID(browserState.raidKey)
        if selRaid then raidName = selRaid.name or "?" end
        UIDropDownMenu_SetText(ddRaid, raidName)

        -- Boss dropdown (within current raid)
        UIDropDownMenu_Initialize(ddBoss, function()
            local raid = browserState.raidKey and RR:GetRaidByInstanceID(browserState.raidKey)
            if not raid or not raid.bosses then return end
            for idx, boss in ipairs(raid.bosses) do
                local n, s, t = CountBossLoot(boss)
                local info = UIDropDownMenu_CreateInfo()
                info.text = (boss.name or ("Boss " .. idx)) .. FormatCountSuffix(n or 0, s or 0, t or 0)
                info.value = idx
                info.checked = (idx == browserState.bossIndex)
                info.func = function()
                    if browserState.bossIndex == idx then return end
                    browserState.bossIndex = idx
                    UIDropDownMenu_SetText(ddBoss, boss.name or ("Boss " .. idx))
                    f:RefreshContent()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        local bossName = "(none)"
        local _, selBoss = GetBrowserSelection()
        if selBoss then bossName = selBoss.name or "?" end
        UIDropDownMenu_SetText(ddBoss, bossName)
    end

    f.RefreshContent = function(self)
        local raid, boss = GetBrowserSelection()
        local detail = boss and BuildTransmogDetail({ boss = boss })
                              or "Select a raid and boss."
        text:SetText(detail or "")
        local fontSize = RR:GetSetting("fontSize", 12)
        SetBodyFont(text, fontSize - 1, "")

        -- Sanctum vendor line + Flight button. BuildSanctumLine returns
        -- nil for any boss that doesn't drop weapon tokens or any raid
        -- without weaponVendors (so non-CN raids automatically hide
        -- both widgets, no special-casing needed at this site). When
        -- vendorInfo is nil but text is non-nil, the player has no
        -- covenant -- we show the "no covenant detected" line but
        -- hide the Flight button (no real coords to route to).
        local sanctumText, sanctumRaid, sanctumCovID, sanctumVendor =
            BuildSanctumLine(raid, boss)
        if sanctumText then
            SetBodyFont(sanctumLine, fontSize - 1, "")
            sanctumLine:SetText(sanctumText)
            sanctumLine:Show()
            if sanctumVendor then
                -- Anchor the button against the rendered text width
                -- (GetStringWidth) so it sits snug against the actual
                -- end of the line regardless of how long the vendor /
                -- zone names are. Same trick PositionEntranceButton
                -- uses for the idle list.
                --
                -- Defer positioning by one frame: GetStringWidth is
                -- lazy after SetFont (same WoW UI measurement quirk
                -- documented in AutoSize for GetStringHeight). If we
                -- read it immediately, it returns 0 or a stale value
                -- and the button anchors on top of the text -- which
                -- renders invisibly at small font sizes where the
                -- button is entirely covered by the line. The idle
                -- list's PositionEntranceButton gets away without
                -- this deferral because RefreshIdleList re-runs every
                -- heartbeat tick and self-corrects on the next pass;
                -- RefreshContent only fires on dropdown changes, so
                -- the first measurement has to be right.
                local btnSize = math.floor(fontSize * 1.4)
                sanctumBtn:SetSize(btnSize, btnSize)
                sanctumBtn:ClearAllPoints()
                sanctumBtn:SetPoint("LEFT", sanctumLine, "LEFT",
                    (sanctumLine:GetStringWidth() or 0) + 4, 0)
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function()
                        if sanctumBtn:IsShown() then
                            sanctumBtn:ClearAllPoints()
                            sanctumBtn:SetPoint("LEFT", sanctumLine, "LEFT",
                                (sanctumLine:GetStringWidth() or 0) + 4, 0)
                        end
                    end)
                end
                sanctumBtn:SetScript("OnClick", function()
                    RR:NavigateToSanctum(sanctumRaid, sanctumCovID)
                end)
                sanctumBtn:SetScript("OnEnter", function(selfBtn)
                    CancelTmogHide()
                    GameTooltip:SetOwner(selfBtn, "ANCHOR_RIGHT")
                    GameTooltip:SetText(
                        ("Travel to %s"):format(
                            sanctumVendor.vendorName or "Sanctum vendor"),
                        1, 1, 1)
                    GameTooltip:AddLine(
                        ("%s -- %s"):format(
                            sanctumVendor.zoneSub or "",
                            sanctumVendor.zoneMain or ""),
                        0.7, 0.7, 0.7, true)
                    GameTooltip:Show()
                end)
                sanctumBtn:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                    ScheduleTmogHide()
                end)
                sanctumBtn:Show()
            else
                sanctumBtn:Hide()
                sanctumBtn:SetScript("OnClick", nil)
                sanctumBtn:SetScript("OnEnter", CancelTmogHide)
                sanctumBtn:SetScript("OnLeave", ScheduleTmogHide)
            end
        else
            sanctumLine:Hide()
            sanctumLine:SetText("")
            sanctumBtn:Hide()
            sanctumBtn:SetScript("OnClick", nil)
            sanctumBtn:SetScript("OnEnter", CancelTmogHide)
            sanctumBtn:SetScript("OnLeave", ScheduleTmogHide)
        end

        -- The "Show all class tier" checkbox's enabled state depends on
        -- whether the currently-selected boss drops tier tokens. Refresh
        -- it here (not in RefreshAll) so it stays in sync with the boss
        -- dropdown's per-click state changes -- the boss dropdown calls
        -- RefreshContent only (not the full RefreshAll), so anchoring
        -- this check to RefreshContent is what keeps it correct on a
        -- boss-by-boss stepthrough.
        if self.RefreshShowAllCheckEnabled then
            self:RefreshShowAllCheckEnabled()
        end
        -- Resize popup to fit the new content. We count newlines rather
        -- than calling GetStringHeight because the latter returns stale
        -- metrics immediately after a SetFont call, causing the visible
        -- delayed-resize pop-in.
        UI.AutoSize()
    end

    f.RefreshAll = function(self)
        WarmBrowserItemCache()
        self:RefreshDropdowns()
        self:RefreshContent()
        SaveBrowserState()
    end

    -- "Show all class tier" checkbox is only meaningful on bosses that
    -- actually drop tier tokens. On non-tier bosses (and on the very
    -- first/last bosses of a raid which traditionally don't drop tier),
    -- the toggle has no observable effect -- clicking it would be a
    -- dead-end interaction. Disable the checkbox in those cases so the
    -- player gets a visible "this control doesn't apply right now"
    -- signal instead of silent no-ops.
    --
    -- A boss "drops tier" iff at least one entry in the raid's
    -- tierSets.tokenSources maps to that boss's index. Sarkareth's
    -- omnitoken (Void-Touched Curio) is intentionally not tracked in
    -- tokenSources -- it's a separate item shape -- so Aberrus's last
    -- boss reads as "no tier" here. That's consistent with the schema
    -- decision documented in the data file.
    f.RefreshShowAllCheckEnabled = function(self)
        local raid, boss = GetBrowserSelection()
        local hasTier = false
        if raid and boss and raid.tierSets and raid.tierSets.tokenSources then
            for _, bossIdx in pairs(raid.tierSets.tokenSources) do
                if bossIdx == boss.index then
                    hasTier = true
                    break
                end
            end
        end
        if hasTier then
            showAllCheck:Enable()
            showAllCheck:SetAlpha(1.0)
            showAllCheck.text:SetTextColor(1, 1, 1)
        else
            showAllCheck:Disable()
            showAllCheck:SetAlpha(0.45)
            showAllCheck.text:SetTextColor(0.5, 0.5, 0.5)
        end
    end

    -------------------------------------------------------------------------
    -- Realtime collection-state refresh
    --
    -- When the player learns (or unlearns) a transmog appearance, refresh
    -- the tmog window so collected dots flip green immediately. Collects
    -- the token-conversion case too: clicking a tier token auto-learns the
    -- resulting appearance, which fires TRANSMOG_COLLECTION_SOURCE_ADDED.
    --
    -- Events fire in bursts (a single collection can trigger 3-5 events),
    -- so we debounce via a pending flag + short C_Timer.After. This
    -- collapses the burst into one RefreshContent call ~50ms after the
    -- last event.
    --
    -- Also invalidates the per-render appearance cache (kept inside
    -- BuildTransmogDetail as a module-local) -- stale cache entries would
    -- mask the new collection state. Cache is cleared via a re-assignment
    -- from inside BuildTransmogDetail at render time; we just need to
    -- trigger that render.
    -------------------------------------------------------------------------
    f:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
    f:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")
    f:RegisterEvent("TRANSMOG_COLLECTION_UPDATED")

    local refreshPending = false
    f:SetScript("OnEvent", function(self)
        if not self:IsShown() then return end
        if refreshPending then return end
        refreshPending = true
        C_Timer.After(0.05, function()
            refreshPending = false
            if self:IsShown() and self.RefreshContent then
                self:RefreshContent()
            end
        end)
    end)

    return f
end

function UI.UpdateTmogWindow(step)
    if not tmogWindow or not tmogWindow:IsShown() then return end
    -- If we're in hover mode, sync browser selection to the current step
    -- before rerendering. Browser mode ignores step and shows the user's
    -- current dropdown selection.
    if not browserState.active and step and step.bossIndex and RR.currentRaid then
        browserState.expansion = RR.currentRaid.expansion
        browserState.raidKey   = RR.currentRaid.instanceID
        browserState.bossIndex = step.bossIndex
    end
    tmogWindow:RefreshAll()
end

-- Public entry point for "/rr tmog" and any other "open the browser from
-- anywhere" callers. Opens the popup in BROWSE mode: it stays until the
-- user clicks the close button; the grace-timer auto-hide doesn't apply.
function UI.OpenTransmogBrowser()
    -- Mutex with other auxiliary windows. See UI.OpenSkipsWindow for
    -- rationale.
    if skipsWindow and skipsWindow:IsShown() then skipsWindow:Hide() end
    if achievementsWindow and achievementsWindow:IsShown() then achievementsWindow:Hide() end

    local w = GetOrCreateTmogWindow()
    browserState.active = true
    CancelTmogHide()
    w:RefreshAll()
    w:Show()
    -- One more AutoSize after Show so the first visible frame is already at
    -- the final size. Otherwise the initial creation's SetSize(440, MIN)
    -- briefly shows through before the AutoSize inside RefreshAll's height
    -- takes effect.
    UI.AutoSize()
end

-- Toggle variant for "/rr tmog" when called twice in a row.
function UI.ToggleTransmogBrowser()
    if tmogWindow and tmogWindow:IsShown() and browserState.active then
        browserState.active = false
        tmogWindow:Hide()
    else
        UI.OpenTransmogBrowser()
    end
end

-- ----------------------------------------------------------------------------
-- Shared raid-skip presentation pieces
--
-- Used by both the idle-state list (where the marker appears next to
-- raid names with the skip unlocked) and the skips window (where the
-- marker headlines each unlocked raid). Defined here so both consumers
-- pick up the same glyph rules.
-- ----------------------------------------------------------------------------

-- Skip-unlocked marker. Inline texture markup using the standard yellow
-- raid-target star -- same texture used for Fyrakk's portal POI on the
-- world map (see MapOverlay.lua). Re-using the glyph keeps "yellow star
-- = noteworthy point of interest" consistent across the addon's surfaces.
-- 9x9 pixel render fits cleanly alongside GameFontHighlightSmall text
-- without dominating the raid name; legend text uses the same size for
-- a consistent reading.
--
-- The leading-position raid-row marker has three states:
--
--   SKIP_MARKER_LED      -- gold/native: skip unlocked on this account
--   SKIP_MARKER_LED_DIM  -- dim, R:G:B 80:80:80 multipliers (matches the
--                           ACH_NON_META_PREFIX recipe used in the
--                           achievements window): skip exists for this
--                           raid but not yet unlocked
--   SKIP_MARKER_LED_NONE -- transparent: this raid has no skip mechanic
--                           at all. Renders nothing visually but reserves
--                           the same width as the other two so columns
--                           stay aligned across rows. R:G:B doesn't
--                           matter here -- alpha 0 (the trailing 0) is
--                           what makes it invisible.
--
-- These are the LEADING raid-row variants at 12x12. The original 9x9
-- SKIP_MARKER (no LED suffix) is still used for the in-raid header
-- (panel.raid) where the trailing-marker placement and smaller size
-- both make sense for that surface. The achievement-window patterns
-- (UI-RaidTargetingIcon_3 diamond at 14x14) are independent and live
-- below in their own constants.
local SKIP_MARKER          = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:9:9|t"
local SKIP_MARKER_LED      = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12|t"
local SKIP_MARKER_LED_DIM  = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12:0:0:64:64:0:64:0:64:80:80:80|t"
local SKIP_MARKER_LED_NONE = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12:0:0:64:64:0:64:0:64:0:0:0:0|t"

-- Inline texture marker matching the entrance-navigation buttons that
-- appear next to raid names. Same texture as the button so the legend's
-- "= Navigator powered by..." reads as a key for that exact glyph.
-- Rendered at 12x12 to roughly match the button's visual presence.
local ENTRANCE_MARKER = "|TInterface\\Minimap\\Tracking\\FlightMaster:12:12|t"

-- Footer line shown when the supported-raids list is rendered. Single
-- line: explains the gold star and points to the Skips window for
-- per-difficulty detail. The dim and invisible variants don't need
-- legend coverage -- dim reads as "less prominent than gold," and the
-- absent-glyph rows visually distinguish themselves by absence.
local IDLE_SKIP_LEGEND =
    "|cff9d9d9d" .. SKIP_MARKER_LED .. " = skip unlocked -- check Skips for details|r"

-- Footer line explaining the entrance-navigation icon. Shown only when
-- at least one raid in the rendered list has an entrance button. The
-- copy adapts based on the current routing tier (RR:GetNavTier()) and
-- which routing addons are providing the experience:
--
--   * "routing" tier -> "Navigation powered by [ AWP | Zygor | Mapzeroth ]"
--     three-pill bar matching the visual grammar of the per-difficulty
--     kill pills. Each pill is rendered in its brand color when its
--     addon is installed and active in the current cascade, and dimmed
--     to INACTIVE gray when not. Brand colors:
--       AWP:       |cff00ccff cyan
--       Zygor:     |cffff8800 orange-gold (Zygor brand identity)
--       Mapzeroth: |cff5fcde4 light teal/cyan accent
--     Multiple pills can light simultaneously to honestly credit both the
--     orchestrator and the planner. With AWP and a backend (e.g.
--     Mapzeroth) installed, AWP and Mapzeroth both light because AWP is
--     the orchestrator and Mapzeroth is the actual planning engine. With
--     AWP installed but no backend, only AWP lights -- the dim Zygor and
--     Mapzeroth pills serve as a passive nudge that installing one would
--     unlock multi-leg routing. Without AWP, the legacy two-addon
--     precedence (Zygor wins ties over Mapzeroth) applies to which
--     planner pill lights.
--   * "waypoint" tier (no routing addon installed, OR AWP-only with no
--     backend) -> two-line legend: line 1 "Blizzard waypoint only."
--     line 2 (indented) "Install AzerothWaypoint (with a backend),
--     Zygor, or Mapzeroth for step-by-step routing." The "(with a
--     backend)" caveat on AWP is the architecturally honest correction
--     -- AWP without a routing backend is functionally equivalent to no
--     routing addon at all (single-pin Blizzard fallback), since AWP
--     is a meta-router not a routing engine. All three addon names use
--     cyan branding to match the idle-list visual palette; AWP first
--     to match the active-pill row order, Zygor and Mapzeroth follow.
--
-- Builds the legend at render time so a /reload after the user
-- installs/enables a routing addon picks up the change.
local function BuildEntranceLegend()
    -- Three-role nav legend, active-only. Visual:
    --
    --   Routing: <Zygor|Mapzeroth|None> [with AWP Orchestration]
    --   Waypoint: <TomTom|Native> [with 3D Overlay from <names>]
    --
    -- Previous iterations showed dimmed inactive pills for upgrade-
    -- path discoverability, but the result read as a wall of bracket
    -- noise. This version shows only what's actually active. Users
    -- who see "Routing: None" can infer they're missing something --
    -- and the rest of the addon's documentation can carry the install
    -- guidance.
    --
    -- Three roles:
    --   ROUTING -- multi-leg planner. Zygor or Mapzeroth. "None" when
    --              neither is installed.
    --   WAYPOINT -- destination arrow source. TomTom if installed,
    --               Blizzard native otherwise (labeled "Native").
    --   OVERLAY -- 3D world-overlay tail. AWP and WUI as peer
    --              overlays; both can be active simultaneously. The
    --              tail disappears entirely when neither is installed.
    --
    -- AWP-with-backend gets a "with AWP Orchestration" tail on the
    -- routing line, since AWP is genuinely doing work (orchestrating
    -- the backend's route through its own queue UI). AWP-alone-
    -- without-backend does NOT get this tail (nothing to orchestrate)
    -- but DOES appear in the overlay tail (its 3D overlay fires).
    --
    -- Monochrome by design: bright white for active names, label-gray
    -- for everything else (slot labels, connectors, "with" prepositions).
    local LIT_HEX  = "ffffff"  -- active provider names
    local LBL_HEX  = "9d9d9d"  -- labels, connectors, prepositions

    local function lit(s) return ("|cff%s%s|r"):format(LIT_HEX, s) end
    local function lbl(s) return ("|cff%s%s|r"):format(LBL_HEX, s) end

    local awpInst       = RR:IsAWPInstalled()
    local zygorInst     = RR:IsZygorInstalled()
    local mapzerothInst = RR:IsMapzerothInstalled()
    local wuiInst       = RR:IsWUIInstalled()
    local tomtomInst    = RR:IsTomTomInstalled()

    -- ROUTING line. Zygor wins ties over Mapzeroth (mirrors the
    -- cascade in NavigateToEntrance). "None" surfaces when neither
    -- planner is installed -- explicit empty state, no install hint
    -- inline (kept terse).
    local routingActive
    if zygorInst then
        routingActive = lit("Zygor")
    elseif mapzerothInst then
        routingActive = lit("Mapzeroth")
    else
        routingActive = lit("None")
    end

    -- AWP Orchestration tail: ONLY when AWP is installed AND a backend
    -- is active. AWP-without-backend has nothing to orchestrate; no
    -- tail in that case.
    local routingTail = ""
    if awpInst and (zygorInst or mapzerothInst) then
        routingTail = lbl(" with ") .. lit("AWP Orchestration")
    end

    -- WAYPOINT line. TomTom or Blizzard Native -- exactly one
    -- describes which addon drops the destination arrow. Native is
    -- the universal fallback.
    local waypointActive = tomtomInst and lit("TomTom") or lit("Native")

    -- OVERLAY tail. AWP and WUI as peers; either, both, or neither
    -- can be active. Tail entirely omitted when neither is installed.
    local overlayTail = ""
    if awpInst and wuiInst then
        overlayTail = lbl(" with 3D Overlay from ")
            .. lit("AWP") .. lbl(" and ") .. lit("WUI")
    elseif awpInst then
        overlayTail = lbl(" with 3D Overlay from ") .. lit("AWP")
    elseif wuiInst then
        overlayTail = lbl(" with 3D Overlay from ") .. lit("WUI")
    end

    -- Return two rows. Each row has a label half (gray "Routing: " or
    -- "Waypoint: ") and a data half (the active provider + tails). The
    -- caller renders them as TWO FontStrings per row -- label anchored
    -- to row-left, data anchored to a fixed pixel offset that puts the
    -- data column past the widest label. This sidesteps the alignment
    -- drift that comes from proportional-font label widths (e.g.
    -- "Routing: " is narrower than "Waypoint: " so concatenated text
    -- doesn't column-align even when labels are styled identically).
    return {
        { withMarker = true,  label = lbl("Routing: "),  data = routingActive  .. routingTail },
        { withMarker = false, label = lbl("Waypoint: "), data = waypointActive .. overlayTail },
    }
end

-- ----------------------------------------------------------------------------
-- Skips window
--
-- Account-wide raid skip status display. Lazy-built framed window that
-- mirrors the Tmog browser's structural pattern (BackdropTemplate frame,
-- title bar, close button, draggable, content area with AutoSize) but
-- without the Tmog-specific bits (dropdowns, hyperlinks, hover-hide
-- timer). It's a pure read-only display: re-renders content from the
-- live API every time it's shown, no caching.
--
-- Cascade-aware: each raid line shows the cascade ceiling derived via
-- GetRaidSkipUnlockedCeiling, and the available difficulties listed
-- under it follow the cascade-down rule (Mythic completion -> Mythic +
-- Heroic + Normal listed; Heroic completion -> Heroic + Normal; etc.)
--
-- Why a framed window instead of the copy window: this is a USER-FACING
-- feature, not a diagnostic. The copy window is for diagnostic dumps
-- where the user copies text out; permanent UI surfaces belong in
-- proper framed windows. Format/alignment problems also go away
-- because we control the layout per-row instead of dumping plain
-- text into a proportional-font editbox.
-- ----------------------------------------------------------------------------

-- Sizing constants for the skips window. Independent of POPUP_CONTENT_*
-- (Tmog) because the skips window has different chrome and content
-- shape -- a few raids in a small table + disclaimer is a more
-- predictable height range than transmog content.
--
-- Wrapped in a do/end block to keep the supporting locals out of UI.lua's
-- top-level scope (Lua 5.1 caps local-variable count at 200 per function;
-- this file's main chunk is at the ceiling). Same pattern as the
-- What's New and Achievements window blocks elsewhere in this file.
do
local SKIPS_WINDOW_WIDTH        = 400
local SKIPS_WINDOW_MIN_HEIGHT   = 200
local SKIPS_WINDOW_MAX_HEIGHT   = 600

-- Column x-offsets (px from frame left) for the difficulty cells. The
-- name column starts at frame-left + content padding and runs up to
-- the first cell; the three cell columns are right-aligned around their
-- center x-positions so a glyph and the header letter both sit
-- visually centered. Offsets chosen empirically for SKIPS_WINDOW_WIDTH=400.
--
-- Difficulty order: Mythic / Heroic / Normal (left to right). Hardest
-- first matches a player's typical mental model when checking "do I have
-- skips for this raid" -- they look at Mythic first, eye left to right
-- as the answer cascades down through difficulties. Cascade-down means
-- a partial unlock visually stacks ✓s on the right side of the row.
local SKIPS_COL_NAME_X     = 14
-- Info-button column. All [i] icons in raidRow rendering anchor to
-- this fixed x so they form a vertical column right of the longest
-- raid name and left of the Mythic difficulty column. Sits 35px left
-- of MYTHIC_X to clear multi-chain raids (Antorus) whose Mythic cell
-- splits into two glyphs at MYTHIC_X +/- pairOffset (the leftmost
-- glyph lands at x=230 with pairOffset=10).
local SKIPS_COL_INFO_X     = 205
local SKIPS_COL_MYTHIC_X   = 240
local SKIPS_COL_HEROIC_X   = 300
local SKIPS_COL_NORMAL_X   = 360

-- Per-row vertical spacing. Driven by font size at refresh time; this
-- is the multiplier (rendered line-height = fontSize * SKIPS_LINE_GAP).
local SKIPS_LINE_GAP       = 1.7

-- Divider offset from the row's bottom edge. Positive value moves the
-- divider UP into the row band (toward the text). Tuned empirically
-- so the row text + glyphs sit visually centered between two
-- consecutive dividers. With SKIPS_LINE_GAP = 1.7 and fontSize=12,
-- lineHeight is ~20px; the FontString has a few px of internal
-- top-padding, so the divider needs to sit a few px above the bottom
-- of the band to make the text appear centered.
local SKIPS_ROW_DIVIDER_INSET = 5

-- Glyphs for difficulty cells. Reuse the existing visual vocabulary
-- (ReadyCheck-Ready / plain X) so the meaning is consistent with how
-- collected/uncollected appearances are rendered elsewhere in the
-- addon.
local SKIPS_CELL_UNLOCKED = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local SKIPS_CELL_LOCKED   = "|cff666666X|r"
-- BfD-only: the achievement-gated skip is Mythic-only, so the Normal
-- and Heroic columns are not applicable. Rendered as a muted "N/A" to
-- communicate "no skip exists at this difficulty" rather than "skip
-- exists but you haven't unlocked it yet" (which is what the locked-X
-- means in the other two states).
local SKIPS_CELL_NA       = "|cff888888N/A|r"

local GetOrCreateSkipsWindow

-- Build a structured row list for the skips window. Each row is one of:
--   { kind = "expansionHeader", text = "Dragonflight" }
--   { kind = "raidRow", name = "Aberrus...", mythic = bool, heroic = bool, normal = bool }
--     -- For multi-chain raids (Antorus's Imonar + Aggramar), the row
--     -- additionally carries mythic2/heroic2/normal2 fields for the
--     -- second chain's per-difficulty state. The renderer paints two
--     -- glyphs per cell, centered as a pair on the column midline.
--   { kind = "spacer" }
--   { kind = "message", text = "..." }   -- empty-state and error messages
--
-- Raids without skipQuests OR skipAchievement configured are silently
-- omitted (no row at all). Empty expansions (zero raids with any skip
-- mechanism) drop their header entirely so the table never renders a
-- lonely orphan header.
--
-- The rendering pass turns rows into FontStrings/textures. Keeping the
-- structure separate from rendering makes the layout code a simple loop
-- and lets us add new row kinds (totals, footnotes, etc.) without
-- restructuring.
local function BuildSkipsRows()
    local rows = {}
    local function add(row) table.insert(rows, row) end

    -- API gate: if the OnAccount variant isn't available, return a
    -- single explanatory row.
    local fn = C_QuestLog and C_QuestLog.IsQuestFlaggedCompletedOnAccount
    if not fn then
        add({ kind = "message", text =
            "|cffff5555Account-wide skip detection unavailable on this client.|r\n"
            .. "|cff9d9d9dRequires Patch 11.0.5 or later.|r" })
        return rows
    end

    -- Group raids by expansion, ordered newest-first. Within each
    -- expansion, sort by patch descending (matches the idle list).
    local byExp = {}
    local expOrder = {}
    for _, raid in pairs(RetroRuns_Data or {}) do
        -- Skip dev-stub placeholder entries (instanceID = 0). See
        -- BuildIdleListRows for the full rationale.
        if raid.instanceID and raid.instanceID > 0 then
            local exp = raid.expansion or "Unknown"
            if not byExp[exp] then
                byExp[exp] = {}
                table.insert(expOrder, exp)
            end
            table.insert(byExp[exp], raid)
        end
    end

    -- Use the same EXPANSION_ORDER_NEWEST_FIRST that the idle list uses
    -- if it's exposed on RR; else fall back to alpha sort.
    if RR.EXPANSION_ORDER_NEWEST_FIRST then
        local seen, ordered = {}, {}
        for _, exp in ipairs(RR.EXPANSION_ORDER_NEWEST_FIRST) do
            if byExp[exp] then
                table.insert(ordered, exp); seen[exp] = true
            end
        end
        for _, exp in ipairs(expOrder) do
            if not seen[exp] then table.insert(ordered, exp) end
        end
        expOrder = ordered
    else
        table.sort(expOrder)
    end

    for _, exp in ipairs(expOrder) do
        local raids = byExp[exp]
        table.sort(raids, function(a, b)
            return (a.patch or "") > (b.patch or "")
        end)

        -- Build this expansion's raidRows first so we can decide whether
        -- to emit the expansion header at all. An expansion with zero
        -- skip-configured raids would otherwise produce a lonely header
        -- with nothing under it.
        local expRows = {}
        for _, raid in ipairs(raids) do
            local sk = raid.skipQuests
            local sa = raid.skipAchievement
            -- Raids without skipQuests OR skipAchievement configured are
            -- simply omitted from the table -- there's no useful "no
            -- skip data" row to render for them. Earlier versions added
            -- a "(no skip data)" row, but that just clutters the table
            -- for raids the player can't skip into anyway.
            if sk or sa then
                local cascading = RR:RaidSkipIsCascading(raid)
                -- Three-state cells: true = unlocked, false = locked,
                -- "na" = not applicable for this raid (only Mythic exists).

                -- Multi-chain raids (skipQuests array of chains, e.g.
                -- Antorus's Imonar + Aggramar) render as a single row.
                -- Each difficulty cell paints two glyphs side-by-side --
                -- chain 1 on the left, chain 2 on the right -- with the
                -- pair's visual center aligned to the column midline.
                -- Each chain cascades independently, so each chain's
                -- per-difficulty cells come from its own ceiling.
                local perChain = RR:GetSkipChainCeilings(raid)
                local isMultiChain = perChain and #perChain > 1

                if isMultiChain then
                    local function cellsForChain(c)
                        local mCell, hCell, nCell
                        if cascading then
                            mCell = c.ceiling and c.ceiling >= 16 or false
                            hCell = c.ceiling and c.ceiling >= 15 or false
                            nCell = c.ceiling and c.ceiling >= 14 or false
                        else
                            mCell = c.ceiling == 16
                            hCell = "na"
                            nCell = "na"
                        end
                        return mCell, hCell, nCell
                    end
                    local m1, h1, n1 = cellsForChain(perChain[1])
                    local m2, h2, n2 = cellsForChain(perChain[2])
                    table.insert(expRows, {
                        kind    = "raidRow",
                        name    = raid.name or "?",
                        mythic  = m1, heroic  = h1, normal  = n1,
                        mythic2 = m2, heroic2 = h2, normal2 = n2,
                        trigger = raid.skipTrigger,
                        raidRef = raid,
                    })
                else
                    -- Single-chain raid: existing flat row shape.
                    -- Cascade-down for standard skipQuests: ceiling N
                    -- means difficulties <= N are unlocked. For
                    -- non-cascading (BfD), only the exact ceiling
                    -- difficulty unlocks; the others are "na", not
                    -- "locked".
                    local ceiling = RR:GetRaidSkipUnlockedCeiling(raid)
                    local mCell, hCell, nCell
                    if cascading then
                        mCell = ceiling and ceiling >= 16 or false
                        hCell = ceiling and ceiling >= 15 or false
                        nCell = ceiling and ceiling >= 14 or false
                    else
                        -- Non-cascading: BfD-only. Mythic is the only
                        -- real column; Normal/Heroic render as N/A.
                        mCell = ceiling == 16
                        hCell = "na"
                        nCell = "na"
                    end
                    table.insert(expRows, {
                        kind   = "raidRow",
                        name   = raid.name or "?",
                        mythic = mCell,
                        heroic = hCell,
                        normal = nCell,
                        trigger = raid.skipTrigger,
                        raidRef = raid,
                    })
                end
            end
        end

        -- Only emit the header + spacer when there's at least one row
        -- to anchor under it.
        if #expRows > 0 then
            add({ kind = "expansionHeader", text = exp })
            for _, row in ipairs(expRows) do add(row) end
            add({ kind = "spacer" })
        end
    end

    -- Drop trailing spacer.
    if rows[#rows] and rows[#rows].kind == "spacer" then
        rows[#rows] = nil
    end

    return rows
end

-- Per-row widget pool. Each pool entry is a "row group" containing the
-- name FontString plus three cell FontStrings (mythic / heroic / normal)
-- plus a left-side expansion-header FontString. We hide all four on a
-- given row and only show the ones that match the row's kind, so a
-- single pool slot serves any row type. Slots are created on demand and
-- reused across refreshes.
local skipsRowPool = {}

local function GetSkipsRowSlot(parent, idx)
    if skipsRowPool[idx] then return skipsRowPool[idx] end
    local slot = {}

    slot.expHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slot.expHeader:SetJustifyH("LEFT")

    slot.name = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.name:SetJustifyH("LEFT")

    slot.cellM = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.cellM:SetJustifyH("CENTER")
    slot.cellH = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.cellH:SetJustifyH("CENTER")
    slot.cellN = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.cellN:SetJustifyH("CENTER")

    -- Secondary cell glyphs, used only when the raid has a second skip
    -- chain (Antorus's Imonar + Aggramar pair). The primary cellM/H/N
    -- and the secondary cellM2/H2/N2 sit offset left/right of the
    -- column midline so the pair's visual center lines up with single-
    -- chain raids' single centered glyph. Hidden on rows that don't
    -- need them.
    slot.cellM2 = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.cellM2:SetJustifyH("CENTER")
    slot.cellH2 = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.cellH2:SetJustifyH("CENTER")
    slot.cellN2 = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.cellN2:SetJustifyH("CENTER")

    -- Subtle horizontal divider drawn at the bottom of the row, matching
    -- the achievements-window pattern. Dim and slightly transparent so
    -- it reads as visual structure without competing with the cell text.
    -- ARTWORK draw layer keeps it below the OVERLAY-layer FontStrings
    -- so any text overlap (rare, only when rows are very tight) renders
    -- with the text on top.
    slot.divider = parent:CreateTexture(nil, "ARTWORK")
    slot.divider:SetColorTexture(0.4, 0.4, 0.4, 0.25)
    slot.divider:SetHeight(1)

    -- Active-raid highlight + left accent bar. Same shape as the
    -- achievements window's current-boss highlight: a BORDER-layer
    -- tinted band spanning the row's width, plus a 3px-wide solid
    -- cyan vertical bar at the left edge. Shown on the raidRow whose
    -- instanceID matches RR.currentRaid (i.e., the player is in that
    -- raid right now).
    slot.highlight = parent:CreateTexture(nil, "BORDER")
    slot.highlight:SetColorTexture(0.30, 0.65, 1.0, 0.22)
    slot.accent = parent:CreateTexture(nil, "BORDER")
    slot.accent:SetColorTexture(0.45, 0.80, 1.0, 1.0)
    slot.accent:SetWidth(3)

    -- Info button (the "[i]" glyph rendered as a clickable Button). Sits
    -- just right of the name FontString on rows whose raid has skipTrigger
    -- text authored. Click opens RETRORUNS_SKIP_TRIGGER StaticPopup with
    -- the trigger text. Hidden on rows without skipTrigger so we don't
    -- light up empty popups.
    --
    -- Implementation: a small Button frame with a child FontString that
    -- renders the glyph. The glyph IS the visual; no separate texture.
    -- Hover highlight is a tint shift on the FontString itself. The
    -- "[i]" bracketed-marker style matches the existing "[!] view
    -- special note" convention used elsewhere in the addon, and it's
    -- all-ASCII so STANDARD_TEXT_FONT (FRIZQT) renders it reliably
    -- across locales (Unicode glyphs like U+24D8 ⓘ are not in FRIZQT's
    -- coverage on enUS and render as placeholder boxes).
    slot.infoBtn = CreateFrame("Button", nil, parent)
    slot.infoBtn:SetSize(28, 16)
    -- Fire OnClick on mouse-button-DOWN rather than UP. Default Button
    -- behavior is LeftButtonUp, which fires only after release -- but
    -- the parent Skips window has RegisterForDrag("LeftButton") +
    -- SetMovable, so a press + tiny cursor jiggle on the small 28x16
    -- button can be interpreted as a drag-start on the WINDOW instead
    -- of a click on the BUTTON. Firing on DOWN eliminates that race:
    -- the click registers immediately, before any movement happens.
    slot.infoBtn:RegisterForClicks("AnyDown")
    -- Expand the hit-rect outward 4px on each side so the click target
    -- is slightly larger than the visual [ i ] glyph. Negative inset
    -- values in SetHitRectInsets EXPAND the hit area beyond the
    -- button's SetSize bounds. Cheap safety margin: the glyph itself
    -- is ~16x10 inside a 28x16 button, so cursor positioning at the
    -- edge of the visible text could land just outside the 28x16 rect
    -- under high UI scale or cursor-edge cases. The 4px outward
    -- expansion keeps the click target snappy at any UI scale without
    -- visually changing the button.
    slot.infoBtn:SetHitRectInsets(-4, -4, -4, -4)
    slot.infoBtn.glyph = slot.infoBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.infoBtn.glyph:SetPoint("CENTER", slot.infoBtn, "CENTER", 0, 0)
    slot.infoBtn.glyph:SetText("|cff7faaff[ i ]|r")
    slot.infoBtn:SetScript("OnEnter", function(self)
        self.glyph:SetText("|cffffffff[ i ]|r")
    end)
    slot.infoBtn:SetScript("OnLeave", function(self)
        self.glyph:SetText("|cff7faaff[ i ]|r")
    end)

    -- "message" or "noSkipRow" use the name FontString in a wider mode.
    skipsRowPool[idx] = slot
    return slot
end

local function HideAllSkipsSlots()
    -- pairs (not ipairs) for the same reason as the achievements pool:
    -- not all row kinds populate every pool slot, so integer keys may
    -- have gaps that ipairs would stop at.
    for _, slot in pairs(skipsRowPool) do
        slot.expHeader:Hide()
        slot.name:Hide()
        slot.cellM:Hide()
        slot.cellH:Hide()
        slot.cellN:Hide()
        slot.cellM2:Hide()
        slot.cellH2:Hide()
        slot.cellN2:Hide()
        slot.divider:Hide()
        slot.highlight:Hide()
        slot.accent:Hide()
        slot.infoBtn:Hide()
    end
end

-- Rebuild the skips window content as a table. Walks BuildSkipsRows,
-- positions per-row widgets at the appropriate y offset, and resizes
-- the frame to fit.
local function RefreshSkipsContent()
    local w = skipsWindow
    if not w then return end

    HideAllSkipsSlots()

    local rows = BuildSkipsRows()
    local fontSize = RR:GetSetting("fontSize", 12)
    -- Row content renders one point smaller than the user-facing fontSize
    -- setting, matching the Tmog window's content font for visual parity
    -- across all auxiliary windows. Line spacing keeps using fontSize so
    -- the row pitch isn't affected by the cell-text shrink.
    local rowFontSize = fontSize - 1
    -- Line height uses the active body font's effective size (so VT323
    -- and other non-FRIZQT fonts get the right row pitch). SKIPS_LINE_GAP
    -- is the multiplier (currently 1.7) on top of the effective size.
    local lineHeight = math.floor(GetBodyFontSize(fontSize) * SKIPS_LINE_GAP + 0.5)

    -- y-cursor starts below the chrome (title bar + column headers).
    -- Title bar is at y=-10, takes ~20px. Column headers row sits at
    -- y=-32. First content row starts at y=-32 - lineHeight.
    local topMargin = 32 + lineHeight
    local y = -topMargin

    -- Update the persistent column header strings to match font size.
    if w.colHeaderM then
        SetBodyFont(w.colHeaderM, rowFontSize, "")
        SetBodyFont(w.colHeaderH, rowFontSize, "")
        SetBodyFont(w.colHeaderN, rowFontSize, "")
    end

    for i, row in ipairs(rows) do
        local slot = GetSkipsRowSlot(w, i)

        if row.kind == "expansionHeader" then
            SetBodyFont(slot.expHeader, rowFontSize, "")
            slot.expHeader:SetText("|cff00ffff" .. row.text .. "|r")
            slot.expHeader:ClearAllPoints()
            slot.expHeader:SetPoint("TOPLEFT", w, "TOPLEFT", SKIPS_COL_NAME_X, y)
            slot.expHeader:Show()
            y = y - lineHeight

        elseif row.kind == "raidRow" then
            SetBodyFont(slot.name, rowFontSize, "")
            slot.name:SetText("|cffffffff  " .. row.name .. "|r")
            slot.name:ClearAllPoints()
            slot.name:SetPoint("TOPLEFT", w, "TOPLEFT", SKIPS_COL_NAME_X, y)
            slot.name:SetWidth(SKIPS_COL_INFO_X - SKIPS_COL_NAME_X - 8)
            slot.name:Show()

            -- Active-raid highlight: light up this row if the player is
            -- currently inside this raid. Comparison is by instanceID
            -- (not table reference) so BfD works for both factions --
            -- the Skips window walks the Alliance/symmetric data table,
            -- but RR.currentRaid can resolve to the Horde-specific BfD
            -- table for Horde players. The same instanceID covers both.
            -- Positioning mirrors the achievements window's current-boss
            -- highlight: spans the row's vertical band with 14px L/R
            -- inset matching the divider line, plus a 3px-wide accent
            -- bar on the left.
            if RR.currentRaid and row.raidRef
               and row.raidRef.instanceID == RR.currentRaid.instanceID then
                slot.highlight:ClearAllPoints()
                slot.highlight:SetPoint("TOPLEFT",     w, "TOPLEFT",  4,  y + 2)
                slot.highlight:SetPoint("BOTTOMRIGHT", w, "TOPRIGHT", -4, y - lineHeight + 4)
                slot.highlight:Show()

                slot.accent:ClearAllPoints()
                slot.accent:SetPoint("TOPLEFT",    w, "TOPLEFT", 4, y + 2)
                slot.accent:SetPoint("BOTTOMLEFT", w, "TOPLEFT", 4, y - lineHeight + 4)
                slot.accent:Show()
            end

            -- Info button: positioned in its own column (SKIPS_COL_INFO_X)
            -- so all [i] icons across raidRows form a vertical line right
            -- of the longest raid name and left of the Mythic column.
            -- Hidden when raid.skipTrigger is nil or empty.
            local trig = row.trigger
            local hasTrigger = type(trig) == "table"
                and ((trig.questName and trig.questName ~= "")
                  or (trig.details   and trig.details   ~= ""))
            if hasTrigger then
                slot.infoBtn:ClearAllPoints()
                -- Anchor to the window frame, NOT to slot.name. Anchoring
                -- a Button to a FontString's anchor point produces a hit
                -- rect whose screen position is computed from the
                -- FontString's text-geometry, which is in a different
                -- coordinate space than the parent frame's hit-test grid.
                -- The button renders in the right place visually but
                -- GetMouseFocus returns nil for cursors inside its
                -- reported rect -- the click target effectively isn't
                -- where it draws. Anchoring directly to the window puts
                -- the button on the same hit-test grid as the rest of
                -- the window's clickable children.
                --
                -- Geometry: name is at TOPLEFT (NAME_X, y) on w. The
                -- button is 28 wide, so to center its visual on INFO_X
                -- we anchor TOPLEFT at (INFO_X - 14, y). Using the same
                -- y as the name and cell glyphs (which all anchor their
                -- TOP at y) keeps the [ i ] visually centered in the
                -- row's text band, matching the checkmark / X column
                -- glyphs.
                slot.infoBtn:SetPoint("TOPLEFT", w, "TOPLEFT",
                    SKIPS_COL_INFO_X - 14, y)
                slot.infoBtn:SetFrameLevel(w:GetFrameLevel() + 2)
                local raidRef = row.raidRef
                slot.infoBtn:SetScript("OnClick", function()
                    -- Toggle: if the popup is already up for THIS row's
                    -- raid, close it. Otherwise (popup closed, OR open
                    -- for a different raid) show it for this row.
                    -- StaticPopup_Visible returns the popup frame if
                    -- shown; we tag the frame with the raid instanceID
                    -- in OnShow so we can recognize re-clicks of the
                    -- same row vs. switching between rows.
                    local visible = StaticPopup_Visible("RETRORUNS_SKIP_TRIGGER")
                    local popupFrame = visible and _G[visible]
                    if popupFrame and popupFrame.rrSkipRaidID
                       and raidRef and popupFrame.rrSkipRaidID == raidRef.instanceID then
                        StaticPopup_Hide("RETRORUNS_SKIP_TRIGGER")
                        return
                    end
                    StaticPopup_Show("RETRORUNS_SKIP_TRIGGER",
                        row.name, nil, { raid = raidRef })
                end)
                slot.infoBtn:Show()
            end

            -- Tri-state cell renderer: true = unlocked checkmark,
            -- false = locked X, "na" = dim dash (no skip exists at this
            -- difficulty). The "na" state is only used for BfD's
            -- Mythic-only achievement-gated skip, where the Normal and
            -- Heroic columns are not applicable.
            local function cellText(v)
                if v == "na" then return SKIPS_CELL_NA end
                if v then return SKIPS_CELL_UNLOCKED end
                return SKIPS_CELL_LOCKED
            end

            -- Paired-glyph rendering for multi-chain raids: when the
            -- row carries mythic2/heroic2/normal2, paint a second glyph
            -- offset to the right of the column midline and shift the
            -- primary glyph left by the same amount, so the pair's
            -- visual center stays aligned with the column line (and
            -- with the single-glyph cells on other rows).
            local pairOffset = 10  -- pixels from column midline to each glyph

            SetBodyFont(slot.cellM, rowFontSize, "")
            slot.cellM:SetText(cellText(row.mythic))
            slot.cellM:ClearAllPoints()
            if row.mythic2 ~= nil then
                slot.cellM:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_MYTHIC_X - pairOffset, y)
                SetBodyFont(slot.cellM2, rowFontSize, "")
                slot.cellM2:SetText(cellText(row.mythic2))
                slot.cellM2:ClearAllPoints()
                slot.cellM2:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_MYTHIC_X + pairOffset, y)
                slot.cellM2:Show()
            else
                slot.cellM:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_MYTHIC_X, y)
            end
            slot.cellM:Show()

            SetBodyFont(slot.cellH, rowFontSize, "")
            slot.cellH:SetText(cellText(row.heroic))
            slot.cellH:ClearAllPoints()
            if row.heroic2 ~= nil then
                slot.cellH:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_HEROIC_X - pairOffset, y)
                SetBodyFont(slot.cellH2, rowFontSize, "")
                slot.cellH2:SetText(cellText(row.heroic2))
                slot.cellH2:ClearAllPoints()
                slot.cellH2:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_HEROIC_X + pairOffset, y)
                slot.cellH2:Show()
            else
                slot.cellH:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_HEROIC_X, y)
            end
            slot.cellH:Show()

            SetBodyFont(slot.cellN, rowFontSize, "")
            slot.cellN:SetText(cellText(row.normal))
            slot.cellN:ClearAllPoints()
            if row.normal2 ~= nil then
                slot.cellN:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_NORMAL_X - pairOffset, y)
                SetBodyFont(slot.cellN2, rowFontSize, "")
                slot.cellN2:SetText(cellText(row.normal2))
                slot.cellN2:ClearAllPoints()
                slot.cellN2:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_NORMAL_X + pairOffset, y)
                slot.cellN2:Show()
            else
                slot.cellN:SetPoint("TOP", w, "TOPLEFT", SKIPS_COL_NORMAL_X, y)
            end
            slot.cellN:Show()

            -- Subtle row divider at bottom of this row's vertical span,
            -- inset from each frame edge so it visually frames the table
            -- rather than running edge-to-edge. Vertically, the divider
            -- is pulled up into the band by SKIPS_ROW_DIVIDER_INSET so
            -- the row text + glyphs read as centered between two
            -- consecutive dividers (text has internal top-padding that
            -- shifts its visual midpoint upward).
            slot.divider:ClearAllPoints()
            slot.divider:SetPoint("TOPLEFT",  w, "TOPLEFT",  SKIPS_COL_NAME_X, y - lineHeight + SKIPS_ROW_DIVIDER_INSET)
            slot.divider:SetPoint("TOPRIGHT", w, "TOPRIGHT", -14, y - lineHeight + SKIPS_ROW_DIVIDER_INSET)
            slot.divider:Show()

            y = y - lineHeight

        elseif row.kind == "spacer" then
            y = y - math.floor(lineHeight / 2)

        elseif row.kind == "message" then
            SetBodyFont(slot.name, rowFontSize, "")
            slot.name:SetText(row.text)
            slot.name:ClearAllPoints()
            slot.name:SetPoint("TOPLEFT", w, "TOPLEFT", SKIPS_COL_NAME_X, y)
            slot.name:SetWidth(SKIPS_WINDOW_WIDTH - SKIPS_COL_NAME_X - 14)
            slot.name:Show()
            y = y - (lineHeight * 3)
        end
    end

    -- Position the disclaimer below the last row, with a small gap.
    if w.disclaimer then
        SetBodyFont(w.disclaimer, fontSize - 1, "")
        w.disclaimer:ClearAllPoints()
        w.disclaimer:SetPoint("TOPLEFT", w, "TOPLEFT", SKIPS_COL_NAME_X, y - 8)
        w.disclaimer:SetPoint("TOPRIGHT", w, "TOPRIGHT", -14, y - 8)
    end

    -- Compute total height: |y| (negative offset to last row) + disclaimer
    -- height + bottom margin.
    local lastY = math.abs(y)
    local disclaimerH = w.disclaimer and w.disclaimer:GetStringHeight() or 0
    local desired = lastY + 14 + disclaimerH + 14
    local clamped = math.max(SKIPS_WINDOW_MIN_HEIGHT,
                             math.min(SKIPS_WINDOW_MAX_HEIGHT, desired))
    w:SetHeight(clamped)
end

GetOrCreateSkipsWindow = function()
    if skipsWindow then return skipsWindow end

    local f = CreateFrame("Frame", "RetroRunsSkipsWindow", UIParent, "BackdropTemplate")
    -- Initial height matches MIN; RefreshSkipsContent grows it on first show.
    f:SetSize(SKIPS_WINDOW_WIDTH, SKIPS_WINDOW_MIN_HEIGHT)
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    -- Anchor to the right of the main panel, same as Tmog.
    f:SetPoint("TOPLEFT", panel, "TOPRIGHT", 6, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -10)
    title:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  Raid Skips")
    title:SetFont(TITLE_FONT, 16, "")
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Static column headers. Sit at y=-32, just below the title bar.
    -- These are persistent (not pool-managed) since they never change.
    local function MakeColHeader(x, text)
        local fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOP", f, "TOPLEFT", x, -32)
        fs:SetJustifyH("CENTER")
        fs:SetText("|cffaaaaaa" .. text .. "|r")
        return fs
    end
    f.colHeaderM = MakeColHeader(SKIPS_COL_MYTHIC_X, "Mythic")
    f.colHeaderH = MakeColHeader(SKIPS_COL_HEROIC_X, "Heroic")
    f.colHeaderN = MakeColHeader(SKIPS_COL_NORMAL_X, "Normal")

    -- Disclaimer at the bottom. Anchored dynamically by RefreshSkipsContent
    -- after the last row, so no fixed position here.
    local disclaimer = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    disclaimer:SetJustifyH("LEFT")
    disclaimer:SetWordWrap(true)
    disclaimer:SetText("|cffffd200Note:|r |cff9d9d9dInformational Only|r "
                    .. "|cff7faaff[ i ]|r |cff9d9d9d-- "
                    .. "No skip routing in place|r")
    f.disclaimer = disclaimer

    f.RefreshContent = RefreshSkipsContent

    skipsWindow = f
    return f
end

function UI.OpenSkipsWindow()
    -- Auxiliary windows (skips, tmog, achievements) all anchor to the
    -- same point at the main panel's right edge, so showing two at once
    -- produces visual overlap. Mutex them: opening any auxiliary window
    -- hides the others. The user can still toggle between them with
    -- their respective action-row buttons.
    if tmogWindow and tmogWindow:IsShown() then tmogWindow:Hide() end
    if achievementsWindow and achievementsWindow:IsShown() then achievementsWindow:Hide() end

    local w = GetOrCreateSkipsWindow()
    -- Apply current settings (scale + font) before refreshing so the
    -- first visible state already matches the user's settings rather
    -- than rendering at default and then snapping to settings.
    local scale = RR:GetSetting("windowScale", 1.0)
    w:SetScale(scale)
    RefreshSkipsContent()
    w:Show()
end

function UI.ToggleSkipsWindow()
    if skipsWindow and skipsWindow:IsShown() then
        skipsWindow:Hide()
    else
        UI.OpenSkipsWindow()
    end
end
end -- skips do block

-- ============================================================================
-- What's New window
-- ============================================================================
--
-- Opens from the version-link button in the main panel footer. Renders the
-- release-notes data in RR.WhatsNew (defined in WhatsNew.lua) as a scroll-
-- free multi-line FontString. Same BackdropTemplate window shape as Skips
-- and Tmog, anchored at the right edge of the main panel.
--
-- Wrapped in a do/end block to keep the supporting locals out of UI.lua's
-- top-level scope (Lua 5.1 caps local-variable count at 200 per function;
-- this file's main chunk is close to that ceiling).
do
local WHATSNEW_WINDOW_WIDTH      = 460
local WHATSNEW_WINDOW_MIN_HEIGHT = 200
local WHATSNEW_WINDOW_MAX_HEIGHT = 600
local WHATSNEW_PAD_X             = 14
local WHATSNEW_PAD_TOP           = 36
local WHATSNEW_PAD_BOTTOM        = 14

-- Build the multi-line body text from RR.WhatsNew. One FontString worth
-- of output -- version headers, subheaders, and bulleted lines, joined
-- by newlines. Returns the rendered string.
local function BuildWhatsNewBody()
    local entries = RR.WhatsNew or {}
    local lines = {}

    local function pushBlank()
        table.insert(lines, "")
    end

    for i, entry in ipairs(entries) do
        if i > 1 then pushBlank() end
        -- Version + date line. Version in retro pink (matches Skip:
        -- popup heading + footer Note: convention), date in muted grey.
        table.insert(lines, ("|cffF259C7v%s|r   |cff9d9d9d%s|r"):format(
            entry.version or "?", entry.date or ""))
        for _, section in ipairs(entry.sections or {}) do
            pushBlank()
            -- Subheader (Added / Fixed / Changed / Removed). Gold to
            -- match the "Note:" / "Reward:" / "Title:" label color
            -- used elsewhere in the addon.
            table.insert(lines, ("|cffffd200%s|r"):format(section.heading or ""))
            for _, bullet in ipairs(section.bullets or {}) do
                -- Render **bold** spans as bright-white inline color.
                -- The CHANGELOG voice puts the lead-in headline-style
                -- phrase in **bold** before the supporting prose, so
                -- bright-white-on-grey gives the same visual emphasis
                -- in the rendered popup.
                local rendered = bullet:gsub("%*%*(.-)%*%*",
                    "|cffffffff%1|r")
                table.insert(lines, "  - |cffaaaaaa" .. rendered .. "|r")
            end
        end
    end

    return table.concat(lines, "\n")
end

local function GetOrCreateWhatsNewWindow()
    if whatsNewWindow then return whatsNewWindow end

    local f = CreateFrame("Frame", "RetroRunsWhatsNewWindow",
                          UIParent, "BackdropTemplate")
    f:SetSize(WHATSNEW_WINDOW_WIDTH, WHATSNEW_WINDOW_MIN_HEIGHT)
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    f:SetPoint("TOPLEFT", panel, "TOPRIGHT", 6, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", WHATSNEW_PAD_X, -10)
    title:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  What's New")
    title:SetFont(TITLE_FONT, 16, "")
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Content FontString. Multi-line, word-wrapped, anchored to the
    -- top-left of the content area. The window's height is grown
    -- dynamically by RefreshContent based on the rendered string's
    -- height.
    f.body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.body:SetPoint("TOPLEFT",  f, "TOPLEFT",  WHATSNEW_PAD_X,         -WHATSNEW_PAD_TOP)
    f.body:SetPoint("TOPRIGHT", f, "TOPRIGHT", -WHATSNEW_PAD_X,        -WHATSNEW_PAD_TOP)
    f.body:SetJustifyH("LEFT")
    f.body:SetJustifyV("TOP")
    f.body:SetWordWrap(true)
    f.body:SetSpacing(2)

    f.RefreshContent = function()
        f.body:SetText(BuildWhatsNewBody())
        -- Grow the window height to fit the rendered text, clamped to
        -- MIN/MAX. The body's GetStringHeight returns the height of the
        -- rendered (wrapped) text at its current width.
        local bodyH = f.body:GetStringHeight() or 0
        local desired = WHATSNEW_PAD_TOP + bodyH + WHATSNEW_PAD_BOTTOM
        if desired < WHATSNEW_WINDOW_MIN_HEIGHT then
            desired = WHATSNEW_WINDOW_MIN_HEIGHT
        elseif desired > WHATSNEW_WINDOW_MAX_HEIGHT then
            desired = WHATSNEW_WINDOW_MAX_HEIGHT
        end
        f:SetHeight(desired)
    end

    whatsNewWindow = f
    return f
end

function UI.OpenWhatsNewWindow()
    -- Mutex with other auxiliary windows that share the panel's right
    -- edge -- same rule the Skips / Tmog / Achievements windows follow.
    if tmogWindow         and tmogWindow:IsShown()         then tmogWindow:Hide() end
    if skipsWindow        and skipsWindow:IsShown()        then skipsWindow:Hide() end
    if achievementsWindow and achievementsWindow:IsShown() then achievementsWindow:Hide() end

    local w = GetOrCreateWhatsNewWindow()
    local scale = RR:GetSetting("windowScale", 1.0)
    w:SetScale(scale)
    w.RefreshContent()
    w:Show()
end

function UI.ToggleWhatsNewWindow()
    if whatsNewWindow and whatsNewWindow:IsShown() then
        whatsNewWindow:Hide()
    else
        UI.OpenWhatsNewWindow()
    end
end
end -- do block



-- Build the per-raid pill row for the idle-state list. Same shape as the
-- in-raid pill row, but each pill is colored by its OWN lockout state
-- rather than active-difficulty highlighting:
--   green  = fully cleared this lockout (nothing to farm until reset)
--   amber  = partial kills (still farmable, knows what's left)
--   gray   = no kills / fresh lockout / never entered
--   dim "-" = difficulty doesn't apply to this raid (rare; some legacy
--             raids predate certain difficulties)
--
-- Skip-cascade granularity used to live here as per-pill stars (e.g.
-- "N* 0/9" = skip works at Normal). That decoration was removed when
-- the leading raid-name star (in emitRaid) became the single skip
-- indicator on this surface. Per-difficulty granularity now lives
-- exclusively in the dedicated Skips window, accessed via the action
-- button. The supported-raids list shows binary "skip unlocked /
-- not unlocked / no skip mechanic" via the leading star and points
-- the user to Skips for the breakdown.
local function BuildIdleListPills(raid)
    local counts = RR:GetPerDifficultyKillCountsForRaid(raid)
    if not counts then return "" end

    local PILLS = {
        { id = 17, label = "LFR" },
        { id = 14, label = "N"   },
        { id = 15, label = "H"   },
        { id = 16, label = "M"   },
    }

    -- Color constants are 6-char RGB; the format string prepends |cff.
    -- Earlier version included the alpha byte in these and produced
    -- malformed |cffff00ff00... output (extra "00" leaked as visible
    -- characters before the pill label).
    local CLEARED  = "00ff00"  -- matches SPECIAL_COLLECTED RGB
    local PARTIAL  = "ff9333"  -- matches SPECIAL_PARTIAL RGB
    local FRESH    = "888888"  -- matches SPECIAL_UNCOLLECTED RGB
    local INACTIVE = "555555"  -- doesn't apply

    local parts = {}
    for _, p in ipairs(PILLS) do
        local c = counts[p.id]
        local label = p.label

        if c and c.total > 0 then
            local hex
            if c.complete >= c.total then
                hex = CLEARED
            elseif c.complete > 0 then
                hex = PARTIAL
            else
                hex = FRESH
            end
            table.insert(parts, ("|cff%s%s %d/%d|r"):format(
                hex, label, c.complete, c.total))
        else
            table.insert(parts, ("|cff%s%s -|r"):format(INACTIVE, label))
        end
    end
    if #parts == 0 then return "" end

    local sep = "|cff555555 | |r"
    return "|cff777777[ |r"
        .. table.concat(parts, sep)
        .. "|cff777777 ]|r"
end

-- Returns a list of structured rows for RefreshIdleList to render as
-- per-line FontStrings. Each row is one of:
--   { kind = "expansionHeader", exp = name, expanded = bool }
--   { kind = "raidName",        text = colored-and-formatted string }
--   { kind = "pillRow",         text = colored pill string }
--   { kind = "spacer" }
--   { kind = "skipLegend" }
--   { kind = "emptyMessage",    text = "(no raid data loaded)" }
--
-- Splitting the row data from the rendering pass means RefreshIdleList
-- can anchor toggle Buttons directly to their expansion-header
-- FontString instances (no line-index math, no measurement drift)
-- while keeping data construction and rendering as separate concerns.
local function BuildIdleListRows()
    local byExpansion = {}
    for _, raid in pairs(RetroRuns_Data or {}) do
        -- Skip dev-stub placeholder entries. New-raid bring-ups stub the
        -- data file with instanceID = 0 (and journalInstanceID = 0) until
        -- the in-raid /rr ej capture replaces the placeholders with real
        -- IDs. Without this filter, the placeholder shows up in the idle
        -- list as a raid with all-dash pills (because journalEncounterID = 0
        -- doesn't resolve to any encounter, so total-bosses-detectable = 0
        -- and the pill renderer takes the "doesn't apply" branch).
        if raid.instanceID and raid.instanceID > 0 then
            -- Faction-aware swap: when the player is Horde and we have
            -- Horde-specific data for this raid (currently only BfD), use
            -- that instead of the shared Alliance copy. Without this, the
            -- idle-list pill row would compute kills against Alliance
            -- jeids on a Horde character and report 0/6 instead of 2/9
            -- because Horde kills register against Horde-variant encounter
            -- IDs that don't appear in the Alliance bosses[] table. Mirror
            -- of the dispatch in GetSupportedRaid / GetRaidByInstanceID;
            -- Alliance and Neutral characters get the shared raid object.
            local resolved = RR:GetRaidByInstanceID(raid.instanceID) or raid
            local exp = resolved.expansion or "Unknown"
            byExpansion[exp] = byExpansion[exp] or {}
            table.insert(byExpansion[exp], resolved)
        end
    end

    -- Session-scoped expand state. Default = collapsed (no entry in
    -- the table means "use the default", which is collapsed). The
    -- toggle Button click handlers flip entries in this table; on
    -- a fresh /reload or login the addon's RR.state is empty, so all
    -- expansions start collapsed each session.
    local expanded = (RR.state and RR.state.expandedExpansions) or {}
    local function isExpanded(exp)
        return expanded[exp] == true
    end

    local rows = {}
    -- Tracks whether at least one raid line was emitted (i.e. at
    -- least one expansion is expanded). Used to gate the skip legend,
    -- which now applies to every raid (filled = unlocked, dim = not),
    -- not just to raids with active unlocks. If every expansion is
    -- collapsed, no raid lines render, no stars are visible, and the
    -- legend stays hidden.
    local anyRaidShown = false
    local anyEntranceShown = false

    local function emitRaid(raid)
        local name  = raid.name or "??"
        local patch = raid.patch

        -- Leading skip-status star. Three states drive the glyph:
        --
        --   raid has skip mechanism + ceiling != nil -> gold (unlocked)
        --   raid has skip mechanism + ceiling == nil -> dim   (not unlocked yet)
        --   raid has no skip mechanism              -> transparent placeholder
        --                                              (no skip exists for this raid)
        --
        -- The transparent placeholder reserves the same width as the
        -- gold/dim variants so column alignment is preserved across
        -- rows. Per-tier granularity (which difficulties unlocked) is
        -- intentionally NOT shown here -- the dedicated Skips window
        -- has the full breakdown, and the legend below points there.
        --
        -- The gold-or-dim distinction matters most for users who have
        -- some skips unlocked and some not -- they can scan the column
        -- and see which raids still need the unlock quest. For users
        -- with nothing unlocked, all the skip-bearing raids show dim
        -- and the no-skip-mechanic raids show blank, which still
        -- conveys "these have a skip system you could earn, those
        -- don't have one at all."
        --
        -- "Skip mechanic" is true for raids with either skipQuests
        -- (standard quest-flag cascade) or skipAchievement (BfD-only
        -- achievement-gated, Mythic-only). The leading-LED state is
        -- derived from the unified ceiling -- nil means dim, non-nil
        -- means lit -- so the star renders identically for both kinds.
        local hasSkipMechanic = (raid.skipQuests ~= nil) or (raid.skipAchievement ~= nil)
        local ceiling = RR:GetRaidSkipUnlockedCeiling(raid)
        local leading
        if not hasSkipMechanic then
            leading = SKIP_MARKER_LED_NONE
        elseif ceiling then
            leading = SKIP_MARKER_LED
        else
            leading = SKIP_MARKER_LED_DIM
        end

        local label
        if type(patch) == "string" and patch ~= "" then
            label = ("%s |cffffffff%s (%s)|r"):format(leading, name, patch)
        else
            label = ("%s |cffffffff%s|r"):format(leading, name)
        end

        anyRaidShown = true
        if RR:GetRaidEntrance(raid) then
            anyEntranceShown = true
        end
        table.insert(rows, { kind = "raidName", text = label, raid = raid })
        local pills = BuildIdleListPills(raid)
        if pills ~= "" then
            -- Indent the pill row two spaces under the raid name so the
            -- visual hierarchy is clear: name on the bullet line,
            -- lockout summary on the sub-line.
            table.insert(rows, { kind = "pillRow", text = "  " .. pills })
        end
    end

    -- Render an expansion's header. The toggle button (acquired and
    -- positioned by RefreshIdleList) anchors to the row's FontString;
    -- the row's text starts with leading-space padding so the button
    -- has visual room without overlapping the text.
    local function emitExpansion(exp, raids)
        table.sort(raids, patchDescending)
        table.insert(rows, {
            kind     = "expansionHeader",
            exp      = exp,
            expanded = isExpanded(exp),
        })
        if isExpanded(exp) then
            for _, raid in ipairs(raids) do emitRaid(raid) end
        end
        table.insert(rows, { kind = "spacer" })
    end

    -- Emit known expansions in canonical order
    for _, exp in ipairs(EXPANSION_ORDER_NEWEST_FIRST) do
        if byExpansion[exp] then
            emitExpansion(exp, byExpansion[exp])
            byExpansion[exp] = nil
        end
    end
    -- Anything left over (unknown/new expansion) goes at the end
    for exp, raids in pairs(byExpansion) do
        emitExpansion(exp, raids)
    end

    if #rows == 0 then
        table.insert(rows, { kind = "emptyMessage", text = "|cff9d9d9d(no raid data loaded)|r" })
    end

    -- Skip legend appears whenever at least one raid line is rendered
    -- (i.e. at least one expansion is expanded). Every visible raid
    -- gets a leading star -- filled if unlocked, dim if not -- so
    -- the legend always has something to explain when raids are
    -- visible. If every expansion is collapsed, no raids show, no
    -- stars are visible, and the legend stays hidden.
    --
    -- Both legends are rendered in a separate bottom-up pass in
    -- RefreshIdleList -- they pin near the action button row at the
    -- panel bottom rather than chaining after the last raid line, so
    -- they read as a key block above the action row regardless of
    -- raid-list length.
    if anyRaidShown then
        table.insert(rows, { kind = "skipLegend" })
    end

    -- Entrance legend appears only when at least one currently-visible
    -- raid has entrance data (and therefore got a button rendered next
    -- to its name). Same conditional-explain logic as the skip legend.
    if anyEntranceShown then
        table.insert(rows, { kind = "entranceLegend" })
    end

    return rows
end

-- Helper: rebuild and apply the idle-state list. Each visible row is
-- rendered as its own FontString from the panel.idleListLines pool,
-- anchored top-down via BOTTOMLEFT-of-previous chains. Expansion-header
-- toggle buttons anchor LEFT-of-FontString so they move with their
-- header text -- no measurement, no per-line drift.
--
-- Shared between the idle and run-complete branches of UI.Update so
-- both states get the same click behavior (both states render the
-- supported-raids list, both need the toggles to work).
-- Last-rendered fingerprint for the idle list. Used to short-circuit
-- RefreshIdleList when no state change has occurred since the last
-- render (typically heartbeat-driven UI.Update calls in run-complete
-- or idle states). The previous unconditional rebuild had a click-
-- race bug: heartbeat fires every 1s, ReleaseExpansionToggleButtons
-- does btn:Hide() on every toggle, and a user click whose OnMouseDown
-- landed before the heartbeat but OnMouseUp would have landed after
-- got eaten -- the button vanished mid-click and OnClick never fired.
-- Symptom: inconsistent toggle-button responsiveness in run-complete
-- and idle states, with the bug correlated to heartbeat tick timing.
-- Diagnosed via OnMouseDown/OnMouseUp/OnClick instrumentation showing
-- OnMouseDown firing without the matching OnMouseUp.
local lastIdleListFingerprint = nil

-- Public hook: callers that need to force a rebuild (e.g. font-size
-- changes that affect line stride and button anchor positions) can
-- invalidate the cached fingerprint, ensuring the next RefreshIdleList
-- actually rebuilds. Without this, a font-size slider change wouldn't
-- visually take effect on the idle list until something else mutated
-- the row contents.
function UI.InvalidateIdleListCache()
    lastIdleListFingerprint = nil
end

-- Serialize a row list to a stable string. Used as the cache key. Only
-- includes fields that affect the rendered output -- skips internal
-- raid table references etc. Cheap: ~25 rows * a few fields each =
-- ~100 string ops per heartbeat in the common case (vs releasing and
-- re-acquiring ~25 widgets in the unfingerprinted path).
local function FingerprintIdleRows(rows)
    local parts = {}
    for i, row in ipairs(rows) do
        -- kind + text covers most rows; expansionHeader adds expanded
        -- flag (toggle glyph state); raidName / pillRow include their
        -- rendered text which captures kill counts via the pill string.
        local k = row.kind or "?"
        local t = row.text or ""
        local e = (row.expanded == true) and "1" or "0"
        local exp = row.exp or ""
        parts[i] = ("%s|%s|%s|%s"):format(k, e, exp, t)
    end
    return table.concat(parts, "\n")
end

RefreshIdleList = function()
    -- panel.list is the legacy multi-line FontString. It used to render
    -- both the supported-raids idle list and the in-raid boss-progress
    -- checklist as one big multi-line string. Both surfaces have been
    -- migrated to per-line FontString pools (idleListLines /
    -- progressListLines) for drift-immune row layout. Clear panel.list
    -- and release any progress lines on entry: this function is called
    -- when transitioning INTO an idle/run-complete state, where the
    -- in-raid boss-progress list (if any was on screen) needs to go.
    if panel.list then panel.list:SetText("") end
    ReleaseProgressListLines()

    -- Build the rows first (cheap, pure-data pass) so we can fingerprint
    -- before touching any widgets. If the fingerprint matches the last
    -- render, skip the Release+rebuild entirely -- the existing widgets
    -- on screen are still correct and a tear-down/rebuild would only
    -- introduce the click-race bug described in the
    -- lastIdleListFingerprint comment above.
    local rows = BuildIdleListRows()
    local fp = FingerprintIdleRows(rows)
    if fp == lastIdleListFingerprint
        and #panel.idleListLines > 0 then
        -- Same content as last render AND we have an actual rendered
        -- batch on screen. The second guard handles the first-call
        -- case where lastIdleListFingerprint is nil and #idleListLines
        -- is 0 -- without it, comparing nil == nil would short-circuit
        -- the very first render and the list would never appear.
        return
    end
    lastIdleListFingerprint = fp

    -- Recycle previously-active line FontStrings and toggle Buttons
    -- before this frame's batch is created.
    ReleaseIdleListLines()
    ReleaseExpansionToggleButtons()
    ReleaseEntranceButtons()

    local fontSize = RR:GetSetting("fontSize", 12)

    -- Vertical gap between rows. Conservative -- gives breathing room
    -- without making the list feel sparse.
    local ROW_GAP    = 2
    -- Spacer rows are smaller than a full-line gap; just enough to
    -- visually separate expansion sections.
    local SPACER_GAP = math.max(4, math.floor(fontSize * 0.5))
    -- Hard-coded smaller font for legend rows -- mirrors the
    -- achievements window's bottom-strip soloable legend, which uses
    -- GameFontHighlightSmall regardless of user font-slider value.
    -- The intent is "this is metadata about what you're seeing, not
    -- content to read" -- bumping it with the slider would lose that
    -- visual hierarchy.
    local LEGEND_FONT_SIZE = 10

    local prev = nil  -- previous FontString, for anchor chaining
    -- Collect legend rows during the main pass; render them in a
    -- dedicated bottom-up pass below so they pin near the action
    -- row regardless of how short the raid list is.
    local legendRows = {}
    for _, row in ipairs(rows) do
        if row.kind == "spacer" then
            -- No FontString needed -- next row anchors below the prior
            -- one with an extra gap. Track this via a sentinel so the
            -- next iteration knows to use SPACER_GAP instead of ROW_GAP.
            if prev then
                prev._nextGap = SPACER_GAP
            end
        elseif row.kind == "skipLegend" or row.kind == "entranceLegend" then
            -- Defer: renders bottom-up below.
            table.insert(legendRows, row)
        else
            local fs = AcquireIdleListLine()
            -- Apply font. Non-legend rows use the user's font-slider
            -- value via the body font size. Retro 04B_03 font for the
            -- idle-state list, matching the retro pixel font used on
            -- the action buttons and auxiliary window titles -- gives
            -- the idle UI a unified retro aesthetic.
            SetBodyFont(fs, fontSize, "")

            -- Set text. Different row kinds use different formats; the
            -- text is already pre-colored in BuildIdleListRows. Legend
            -- rows are filtered out earlier and rendered in the post-
            -- loop bottom-up pass.
            if row.kind == "expansionHeader" then
                -- Indent with leading spaces to leave room for the
                -- toggle button glyph anchored at LEFT.
                fs:SetText(("    |cff00ffff%s|r"):format(row.exp))
            else
                -- raidName / pillRow / emptyMessage all carry pre-built
                -- text strings.
                fs:SetText(row.text or "")
            end

            -- Anchor: top of the list for the first row, BOTTOMLEFT of
            -- the previous row otherwise. The previous row may have set
            -- _nextGap (if a spacer preceded this row); use that gap
            -- instead of the default ROW_GAP.
            fs:ClearAllPoints()
            if prev then
                local gap = prev._nextGap or ROW_GAP
                prev._nextGap = nil
                fs:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -gap)
            else
                fs:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, -8)
            end
            fs:Show()

            -- Position the toggle button against this FontString if it's
            -- an expansion header.
            if row.kind == "expansionHeader" then
                local btn = AcquireExpansionToggleButton()
                PositionExpansionToggleButton(btn, fs, row.expanded)
                local expName = row.exp
                btn:SetScript("OnClick", function()
                    -- Single-expand accordion: opening one expansion
                    -- closes any other that's currently open. Keeps
                    -- the supported-raids list short and focused; the
                    -- prior multi-expand mode could grow the panel
                    -- beyond comfortable reading length when the user
                    -- expanded several at once. Toggling the same
                    -- expansion still closes it (click-to-collapse on
                    -- the already-open one).
                    RR.state = RR.state or {}
                    local already = RR.state.expandedExpansions
                                    and RR.state.expandedExpansions[expName]
                    -- Close everything regardless. If this expansion
                    -- was already open, that ends the operation
                    -- (click-to-collapse). Otherwise we fall through
                    -- and re-open just this one.
                    RR.state.expandedExpansions = {}
                    if not already then
                        RR.state.expandedExpansions[expName] = true
                    end
                    if RR.UI and RR.UI.Update then RR.UI.Update() end
                end)
                btn:Show()
                table.insert(panel.expansionToggleButtons, btn)
            end

            -- Position an entrance-navigation button against the raid-name
            -- FontString if the raid has entrance data. Alpha treatment:
            -- full-color (1.0) when ANY nav provider above bare Blizzard
            -- native is installed, muted (0.4) when only the Blizzard
            -- fallback would fire. Any installed nav provider --
            -- including the waypoint-slot single-arrow tiers WUI and
            -- TomTom -- counts as full-alpha: the user chose to install
            -- something, honor that visually. The two-line legend below
            -- conveys the finer detail about which slot(s) are firing.
            if row.kind == "raidName" and row.raid and RR:GetRaidEntrance(row.raid) then
                local btn = AcquireEntranceButton()
                PositionEntranceButton(btn, fs)
                local raid = row.raid
                local anyProviderInstalled = RR:IsAWPInstalled()
                    or RR:IsZygorInstalled()
                    or RR:IsMapzerothInstalled()
                    or RR:IsWUIInstalled()
                    or RR:IsTomTomInstalled()
                btn:SetAlpha(anyProviderInstalled and 1.0 or 0.4)
                btn:SetScript("OnClick", function(self)
                    -- NavigateToEntrance returns a three-role struct:
                    -- { planner, arrow, overlays[] }. Toast rule: show
                    -- the "Waypoint set" toast ONLY when no planner
                    -- fired. The arrow + overlay providers are all
                    -- visually quiet at click time -- TomTom's arrow
                    -- is far off-screen, Blizzard's pin is silent, WUI
                    -- and AWP overlays only render once the player is
                    -- in visual range. The toast covers that silence
                    -- with a spatial confirmation near the button.
                    -- When a planner fires, its own UI surfaces
                    -- prominently (Zygor's arrow, AWP's queue,
                    -- Mapzeroth's GPS frame), so the toast would be
                    -- redundant.
                    local result = RR:NavigateToEntrance(raid)
                    if result and not result.planner then
                        ShowWaypointToast(self, "Waypoint set")
                    end
                end)
                btn:Show()
                table.insert(panel.entranceButtons, btn)
            end

            table.insert(panel.idleListLines, fs)
            prev = fs
        end
    end

    -- Bottom-up legend pass. Renders the legend rows pinned near the
    -- action button row at the bottom of the panel rather than
    -- chained after the last raid line. This keeps the legend in a
    -- predictable spot regardless of how short or long the visible
    -- raid list is, mirroring how the achievements window's
    -- soloable legend is anchored to the frame's bottom-right.
    --
    -- Action row geometry (from MakeActionButton at the top of this
    -- file): buttons sit at BUTTON_Y=28 from the panel's bottom and
    -- are BUTTON_H=22 tall, so the action-row TOP edge is at 50px
    -- up from the panel bottom. We add 12px of breathing room above
    -- that for the lowest legend row's BOTTOM anchor.
    --
    -- Multi-row legends (e.g. when both skip and entrance legends
    -- are showing): the LAST legend row anchors to the panel bottom;
    -- earlier legends chain ABOVE it so the block reads top-down
    -- visually but is anchored from the bottom up.
    --
    -- The entrance legend can itself be multi-row (one FontString per
    -- visual row, since the row-2+ alignment relies on anchor offsets
    -- rather than whitespace inside text -- proportional fonts make
    -- whitespace-based alignment brittle). The render block below
    -- handles both single-row (skip legend) and multi-row (entrance
    -- legend) cases uniformly.
    local LEGEND_BOTTOM_OFFSET = BUTTON_Y + BUTTON_H + 12  -- 28 + 22 + 12 = 62
    local LEGEND_INTER_GAP = 4  -- compact spacing between legend rows
    -- Continuation-row left offset for the entrance-legend's row 2+:
    -- skip past the marker glyph (12px) + " = " (~10px at body-text
    -- size). Tuned to align the column-1 character of row 2's label
    -- ("W" in "Waypoint") with row 1's column-1 character ("R" in
    -- "Routing"). Anchor-based, so it stays aligned at any font
    -- scale.
    local LEGEND_CONTINUATION_INDENT = 22
    -- Data-column left offset for entrance-legend rows: distance
    -- from the row's LABEL FontString left edge to the DATA
    -- FontString left edge, after accounting for per-row x-offset.
    -- Must clear the WIDEST label after any prefix. Row 1's label
    -- is "[12px marker] = Routing: " (~72px); row 2's "Waypoint: "
    -- at x-offset 22 totals ~77px. 64px is below those numbers but
    -- the labels render slightly narrower than ruler-estimated, so
    -- the tighter spacing reads better in practice.
    local LEGEND_DATA_COLUMN = 74

    -- Iterate legendRows in REVERSE so the last legend ends up
    -- anchored to the panel bottom and earlier legends chain ABOVE.
    -- lastLegendTopFS tracks the visually-topmost FontString of the
    -- previously-rendered legend block (which may be a multi-row
    -- entrance legend) so the next-earlier legend can anchor against
    -- its top edge.
    local lastLegendTopFS = nil
    for i = #legendRows, 1, -1 do
        local row = legendRows[i]
        local topFS, bottomFS  -- track this block's outer FontStrings

        if row.kind == "skipLegend" then
            local fs = AcquireIdleListLine()
            SetBodyFont(fs, LEGEND_FONT_SIZE, "")
            fs:SetText(IDLE_SKIP_LEGEND)
            fs:ClearAllPoints()
            if lastLegendTopFS then
                fs:SetPoint("BOTTOMLEFT", lastLegendTopFS, "TOPLEFT", 0, LEGEND_INTER_GAP)
            else
                fs:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD_LEFT, LEGEND_BOTTOM_OFFSET)
            end
            fs:Show()
            table.insert(panel.idleListLegendLines, fs)
            topFS, bottomFS = fs, fs

        elseif row.kind == "entranceLegend" then
            -- Multi-row block, two FontStrings PER row (label + data)
            -- so the data column aligns across rows regardless of
            -- label-width differences in the proportional font. Each
            -- row's spec is { withMarker, label, data }.
            --
            -- Vertical anchor (between rows): the label FontString of
            -- the upper row chains BOTTOMLEFT-to-TOPLEFT against the
            -- LABEL FontString of the row below it (or panel bottom
            -- for the first-rendered row). The DATA FontString of
            -- each row anchors LEFT-to-RIGHT against its own label
            -- with a fixed pixel offset (LEGEND_DATA_COLUMN), so the
            -- data columns align across rows.
            --
            -- Render order: bottom-up within the block so each row's
            -- label has its predecessor (the row below) already
            -- placed when it anchors.
            local entranceRows = BuildEntranceLegend()
            -- xOffsetFor: per-row left position relative to PAD_LEFT.
            -- Marker rows render the marker glyph as text inside the
            -- label FontString, so their label FontString left edge
            -- is at PAD_LEFT. Continuation rows have no marker, so
            -- their label FontString is positioned at
            -- PAD_LEFT + LEGEND_CONTINUATION_INDENT directly --
            -- placing their label column ("Waypoint") flush with the
            -- marker row's label column ("Routing").
            local function xOffsetFor(rowSpec)
                return rowSpec.withMarker and 0 or LEGEND_CONTINUATION_INDENT
            end

            local prevLabelFS = nil
            local prevSpec = nil
            for j = #entranceRows, 1, -1 do
                local rowSpec = entranceRows[j]
                -- LABEL FontString
                local labelFS = AcquireIdleListLine()
                SetBodyFont(labelFS, LEGEND_FONT_SIZE, "")
                if rowSpec.withMarker then
                    labelFS:SetText("|cff9d9d9d" .. ENTRANCE_MARKER .. " = |r" .. rowSpec.label)
                else
                    labelFS:SetText(rowSpec.label)
                end
                labelFS:ClearAllPoints()
                if prevLabelFS then
                    -- Earlier row within the block (visually ABOVE
                    -- the prev row). Anchor BOTTOMLEFT to TOPLEFT of
                    -- the row below. X-offset is the DIFFERENCE
                    -- between this row's intended left position and
                    -- the prev row's.
                    local xOffset = xOffsetFor(rowSpec) - xOffsetFor(prevSpec)
                    labelFS:SetPoint("BOTTOMLEFT", prevLabelFS, "TOPLEFT",
                        xOffset, LEGEND_INTER_GAP)
                else
                    -- Bottom-most row. Anchor to panel or to the
                    -- previously-rendered legend's top edge.
                    local xExtra = xOffsetFor(rowSpec)
                    if lastLegendTopFS then
                        labelFS:SetPoint("BOTTOMLEFT", lastLegendTopFS, "TOPLEFT",
                            xExtra, LEGEND_INTER_GAP)
                    else
                        labelFS:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT",
                            PAD_LEFT + xExtra, LEGEND_BOTTOM_OFFSET)
                    end
                end
                labelFS:Show()
                table.insert(panel.idleListLegendLines, labelFS)

                -- DATA FontString -- anchored to a FIXED panel-x
                -- position (LEGEND_DATA_COLUMN past PAD_LEFT), NOT
                -- relative to the label. Anchoring relative to the
                -- label fails on row 1 because the label there
                -- includes the marker glyph prefix ("[glyph] = "),
                -- so "label LEFT + 56px" lands inside the label text
                -- itself. Panel-anchoring puts both rows' data in
                -- the same vertical column regardless of label
                -- contents. The Y is matched to the label so they
                -- share the same baseline.
                local dataFS = AcquireIdleListLine()
                SetBodyFont(dataFS, LEGEND_FONT_SIZE, "")
                dataFS:SetText(rowSpec.data)
                dataFS:ClearAllPoints()
                dataFS:SetPoint("LEFT", labelFS, "LEFT",
                    LEGEND_DATA_COLUMN - xOffsetFor(rowSpec), 0)
                dataFS:Show()
                table.insert(panel.idleListLegendLines, dataFS)

                if not bottomFS then bottomFS = labelFS end
                topFS = labelFS
                prevLabelFS = labelFS
                prevSpec = rowSpec
            end
        end

        if topFS then
            lastLegendTopFS = topFS
        end
    end
end

-------------------------------------------------------------------------------
-- Main update
-------------------------------------------------------------------------------

function UI.Update()
    if not RetroRunsDB or not RR:IsPanelAllowed() then
        panel:Hide()
        return
    end

    panel:Show()
    UI.ApplySettings()

    local raid   = RR.currentRaid
    local loaded = raid and RR.state.loadedRaidKey == RR:GetRaidContextKey()
    local step   = loaded and (RR.state.activeStep or RR:ComputeNextStep()) or nil

    panel.mode:SetText(RR.state.testMode and "|cffffff00[ TEST MODE ]|r" or "")

    if raid and loaded then
        -- Pills row now carries per-difficulty kill state, so the raid
        -- name line shows just the raid name (no trailing "(Heroic)").
        -- A trailing yellow-star marker appears when the player's
        -- current difficulty is at or below the account's cascade
        -- ceiling -- meaning the in-game skip NPC will actually let
        -- them use it. Showing the star purely on "any unlock exists"
        -- would mislead a Mythic player whose ceiling is only Heroic;
        -- they'd see the star and walk to the skip NPC for nothing.
        -- Faction marker for raids with separate per-faction data.
        -- BfD is the only such raid currently. Symmetric raids get no
        -- marker -- showing [A] on every raid an Alliance player visits
        -- would just be visual noise.
        --
        -- Alliance blue / Horde red roughly matching Blizzard's faction
        -- color conventions. Bracketed letter pattern matches the [!]
        -- style used on the boss-encounter line for consistency.
        local raidLabel = "Raid: " .. raid.name
        if RetroRuns_DataHorde and RetroRuns_DataHorde[raid.instanceID] then
            local faction = UnitFactionGroup("player")
            if faction == "Horde" then
                raidLabel = raidLabel .. " |cffe60100[H]|r"
            else
                raidLabel = raidLabel .. " |cff0078ff[A]|r"
            end
        end
        local currentDiff = RR.state and RR.state.currentDifficultyID
        if currentDiff and RR:IsRaidSkipAvailableAtDifficulty(raid, currentDiff) then
            raidLabel = raidLabel .. " " .. SKIP_MARKER
        end
        panel.raid:SetText(raidLabel)
        panel.pills:SetText(BuildPillsText())
        -- Progress line was "Progress: X/Y" -- the player's current-
        -- difficulty kill count -- but the pills row now displays the
        -- same number (the active-difficulty pill, e.g. "H 0/8").
        -- Empty here so it doesn't duplicate. The FontString is kept
        -- so the unloaded path below can still use it for "Detected:"
        -- and "No supported raid" status messages.
        panel.progress:SetText("")
        panel.mapBtn:Enable()
        panel.mapBtn:SetAlpha(1)

        if step then
            local boss = RR:GetBossByIndex(step.bossIndex)
            -- Re-show the boss-encounter and transmog wrappers in case
            -- they were Hide()'d by a previous idle/run-complete pass
            -- (those states hide the wrappers to avoid layered hit-test
            -- conflicts with the supported-raids list's clickable
            -- expansion headers). panel.transmog gets a more specific
            -- SetShown call below based on whether there's a summary
            -- to display.
            panel.encounter:Show()
            -- White "Boss:" prefix mirrors the "Raid:" label on panel.raid
            -- above. The boss name itself takes the FontString's default
            -- GameFontNormal gold; the |cffffffff...|r escape paints only
            -- the prefix label white so the boss-name color is unchanged.
            panel.next:SetText("|cffffffffBoss:|r " .. (boss and boss.name or "Unknown"))
            panel.travel:SetText(BuildTravelText(step))
            local headerText, achText, specialText, encClickable = BuildEncounterText(step)

            -- Header sub-widget: shows the Boss Encounter line; OnClick
            -- toggles soloTip expand/collapse when clickable is true.
            panel.encounter.header.label:SetText(headerText or "")
            panel.encounter.header.clickable = encClickable
            panel.encounter.header:EnableMouse(encClickable)
            local headerH = math.max(14, panel.encounter.header.label:GetStringHeight())
            panel.encounter.header:SetHeight(headerH)

            -- Achievements sub-widget: hyperlinks-only, no toggle. Hidden
            -- entirely when empty so the layout collapses naturally.
            if achText and achText ~= "" then
                panel.encounter.achievements.label:SetText(achText)
                panel.encounter.achievements:Show()
                local achH = math.max(1, panel.encounter.achievements.label:GetStringHeight())
                panel.encounter.achievements:SetHeight(achH)
            else
                panel.encounter.achievements.label:SetText("")
                panel.encounter.achievements:SetHeight(1)
                panel.encounter.achievements:Hide()
            end

            -- Special loot sub-widget: hyperlinks-only, no toggle.
            if specialText and specialText ~= "" then
                panel.encounter.specialLoot.label:SetText(specialText)
                panel.encounter.specialLoot:Show()
                local specH = math.max(1, panel.encounter.specialLoot.label:GetStringHeight())
                panel.encounter.specialLoot:SetHeight(specH)
            else
                panel.encounter.specialLoot.label:SetText("")
                panel.encounter.specialLoot:SetHeight(1)
                panel.encounter.specialLoot:Hide()
            end

            -- Resize the wrapper to sum-of-children-heights so the
            -- downstream anchor (panel.transmog -> panel.encounter
            -- BOTTOMLEFT) lands at the visual bottom of the content.
            -- The 4+4 accounts for the two 4px gaps between the three
            -- child sub-widgets. Hidden children contribute their 1px
            -- placeholder height + 4px gap; effectively negligible.
            local totalH = headerH
                         + 4 + (panel.encounter.achievements:GetHeight() or 1)
                         + 4 + (panel.encounter.specialLoot:GetHeight() or 1)
            panel.encounter:SetHeight(math.max(14, totalH))
            local tmog = BuildTransmogSummary(step)
            panel.transmog:SetText(tmog or "")
            panel.transmog:SetShown(tmog ~= nil)
            panel.transmog:EnableMouse(true)
            -- Size the click frame to match the rendered text height.
            -- The summary can wrap to two lines (current-diff / other-diffs
            -- split), and without this resize the OnClick hit zone stays
            -- at its 14px construction height and misses the second line.
            if tmog then
                panel.transmog:SetHeight(math.max(14, panel.transmog.label:GetStringHeight()))
            end

            -- In-progress state: listHeader anchored under transmog
            -- as designed; shows "Boss Progress" with per-boss kill
            -- checklist.
            panel.listHeader:ClearAllPoints()
            panel.listHeader:SetPoint("TOPLEFT", panel.transmog, "BOTTOMLEFT", 0, -12)
            panel.listHeader:SetText("Boss Progress")
            -- Render the boss list as per-line FontStrings rather than
            -- one multi-line FontString, matching the idle-list
            -- architecture. No click overlays on these rows today, but
            -- the per-line layout means any future per-row interactivity
            -- (click a boss to scroll routing, hover for loot, etc.)
            -- gets the same drift-immune anchoring the idle list uses.
            -- panel.list (the legacy multi-line FontString) is kept
            -- empty; the per-line FontStrings own all rendering.
            panel.list:SetText("")
            ReleaseProgressListLines()
            local progressLines = RR:GetProgressLines()
            local progFontSize = RR:GetSetting("fontSize", 12)
            local prevProg
            for _, lineText in ipairs(progressLines) do
                local fs = AcquireProgressListLine()
                SetBodyFont(fs, progFontSize, "")
                fs:SetText(lineText or "")
                fs:ClearAllPoints()
                if prevProg then
                    fs:SetPoint("TOPLEFT", prevProg, "BOTTOMLEFT", 0, -2)
                else
                    fs:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, -8)
                end
                fs:Show()
                table.insert(panel.progressListLines, fs)
                prevProg = fs
            end
            -- In-progress list has no expansion-header rows -- it's a
            -- per-boss kill checklist -- so release any toggle Buttons
            -- and per-line FontStrings left over from a prior
            -- idle/run-complete pass to avoid floating widgets over the
            -- progress lines.
            ReleaseExpansionToggleButtons()
            ReleaseEntranceButtons()
            ReleaseIdleListLines()
        else
            -- step == nil branch: either the player has cleared every
            -- boss in this lockout (genuine run-complete) OR the raid
            -- is loaded but doesn't have routing data for every boss
            -- (in-development bring-ups where steps land incrementally).
            -- Distinguish by comparing routing length to boss count:
            -- if every boss has a step authored, an empty
            -- GetAvailableSteps means "all killed/blocked" (genuine
            -- complete); if routing is shorter than bosses, some
            -- bosses don't have steps yet and we shouldn't show the
            -- green "Run complete!" -- the user might have killed
            -- all the steps that exist and still have more boss work
            -- ahead of them per the bosses[] count.
            local routingCount = (RR.currentRaid
                and type(RR.currentRaid.routing) == "table"
                and #RR.currentRaid.routing) or 0
            local bossCount = (RR.currentRaid
                and type(RR.currentRaid.bosses) == "table"
                and #RR.currentRaid.bosses) or 0
            local hasRouting = bossCount > 0 and routingCount >= bossCount

            -- Run-complete state. The user has cleared every boss in
            -- this lockout. Layout goals:
            --   1. Drop the "Traveling: This lockout is complete." line
            --      -- panel.pills at the top already shows the lockout's
            --      complete state, the line was redundant.
            --   2. Close the vertical gap between "Run complete!" and
            --      the supported-raids list -- re-anchor listHeader
            --      directly under panel.next (the "Run complete!" line)
            --      instead of letting empty intermediate widgets'
            --      anchor offsets accumulate.
            --   3. Replace the per-boss "Boss Progress" checklist with
            --      the idle-state per-raid lockout pill list. The boss
            --      list was just re-stating what the pill row at top
            --      already showed; the per-raid list answers the more
            --      useful question "where to farm next?"
            --
            -- Uncaptured-raid state (hasRouting=false): same layout
            -- shape, different text. Tells the user the raid loaded
            -- but routing data isn't available yet, rather than the
            -- misleading "Run complete!" green.
            if hasRouting then
                panel.next:SetText("|cff00ff00Run complete!|r")
            else
                panel.next:SetText("|cffff9333Routing data not yet captured for this raid.|r")
            end
            panel.travel:SetText("")
            panel.encounter.header.label:SetText("")
            panel.encounter.header.clickable = false
            panel.encounter.header:EnableMouse(false)
            panel.encounter.achievements.label:SetText("")
            panel.encounter.achievements:Hide()
            panel.encounter.specialLoot.label:SetText("")
            panel.encounter.specialLoot:Hide()
            panel.encounter:Hide()
            panel.transmog:SetText("")
            -- panel.transmog has its own RegisterForClicks + OnClick
            -- handler (toggles the tmog browser when in-progress). When
            -- transitioning from in-progress to run-complete, this branch
            -- runs but doesn't reset transmog's mouse-enabled state set
            -- by the in-progress branch at line 6338. The idle branch
            -- below has the parallel EnableMouse(false); this branch
            -- needs it too. Without it, transmog retains mouse=true
            -- AFTER the heartbeat-fingerprint cache short-circuits
            -- subsequent UI.Update calls -- the in-progress -> run-
            -- complete transition's mouse state persists.
            panel.transmog:EnableMouse(false)
            panel.transmog:Hide()

            -- Map button does nothing in the run-complete state (no
            -- active step means no segments to draw). Gray it out
            -- the same way the idle state does, so the dead-button
            -- click is visually flagged as unavailable.
            panel.mapBtn:Disable()
            panel.mapBtn:SetAlpha(0.45)

            panel.listHeader:ClearAllPoints()
            panel.listHeader:SetPoint("TOPLEFT", panel.next, "BOTTOMLEFT", 0, -12)
            panel.listHeader:SetText("|cff9d9d9dWhere to next:|r")
            RefreshIdleList()
        end
    else
        -- Idle state. The "RetroRuns v..." line is intentionally blank --
        -- the addon name is already in the title bar at the top of the
        -- panel, and the version is in the footer's bottom-right. A body
        -- line repeating both was redundant. The slot itself stays
        -- because in-raid mode populates it with the raid name.
        panel.raid:SetText("")
        panel.pills:SetText("")

        if raid then
            -- Case: raid was detected (we're zoned into a supported raid)
            -- but the user dismissed the "Load navigation?" popup with
            -- "Not Now." Before: this case read "No supported legacy
            -- raid detected" which was factually wrong -- they're
            -- literally standing in one. Now: acknowledge detection
            -- and tell them how to load.
            local displayName = RR:GetRaidDisplayName() or raid.name
            panel.progress:SetText(
                ("|cffffff00Detected:|r %s"):format(displayName))
            panel.next:SetText("Type |cffffffff/rr|r to load navigation.")
        else
            -- Single line. The "Travel to..." text by itself implies
            -- "you're not in a supported raid yet" -- a separate
            -- "No supported legacy raid detected" line was redundant.
            panel.progress:SetText("Travel to a supported raid to begin.")
            panel.next:SetText("")
        end

        panel.travel:SetText("")
        panel.encounter.header.label:SetText("")
        panel.encounter.header.clickable = false
        panel.encounter.header:EnableMouse(false)
        panel.encounter.achievements.label:SetText("")
        panel.encounter.achievements:Hide()
        panel.encounter.specialLoot.label:SetText("")
        panel.encounter.specialLoot:Hide()
        panel.transmog:SetText("")
        panel.transmog:EnableMouse(false)
        -- Re-anchor listHeader directly below "Travel to..." (panel.progress)
        -- so the supported-raids list sits tight against the prompt.
        -- The intermediate widgets (next, travel, encounter, transmog)
        -- are all empty in idle state but their anchor offsets still
        -- accumulate as visible gap, hence this re-anchor.
        panel.listHeader:ClearAllPoints()
        panel.listHeader:SetPoint("TOPLEFT", panel.progress, "BOTTOMLEFT", 0, -8)
        panel.listHeader:SetText("|cff9d9d9dCurrently supported:|r")
        RefreshIdleList()
        -- Hide the intermediate Button widgets in idle state. With empty
        -- text + EnableMouse(false), Button frames are functionally
        -- invisible to clicks, but they still occupy layout space at
        -- their original anchor positions (panel.next -> panel.travel
        -- -> panel.encounter -> panel.transmog). panel.list is
        -- re-anchored tight under panel.progress in idle state to skip
        -- the empty intermediate gap, which means the toggle Button
        -- overlays positioned over panel.list's lines can end up
        -- vertically overlapping panel.encounter / panel.transmog's
        -- bounding boxes. Even with mouse disabled, sibling Buttons
        -- at the same Z-level can interfere with mouse dispatch.
        -- Hide() removes them from the layout pass entirely so the
        -- toggle Buttons get clean clicks regardless of their final
        -- screen position. The listHeader anchor was re-pointed above
        -- so hiding panel.transmog no longer orphans anything.
        panel.encounter:Hide()
        panel.transmog:Hide()
        panel.mapBtn:Disable()
        panel.mapBtn:SetAlpha(0.45)
    end

    -- Refresh achievements window if open. Route-progress changes shift
    -- the "current boss" highlight and update kill-state pills; without
    -- this hook the highlight would stay pinned to whatever boss was
    -- active when the user last opened the window.
    UI.UpdateAchievementsWindow()

    -- Content size can change significantly between states (in-raid vs idle,
    -- different boss counts, longer strings). Re-fit after content is set.
    -- ApplyMinimizedState handles BOTH the minimized-fixed-height path AND
    -- (via delegation when not minimized) the AutoSize path, so a single
    -- call here covers both cases. It also catches new FontStrings just
    -- acquired by RefreshIdleList above and hides them when minimized.
    UI.ApplyMinimizedState()
end

-- ============================================================================
-- Achievements window
-- ============================================================================
--
-- Standalone window opened by the action-row "Achieves" button. Combines the
-- shape of two existing windows:
--   * tmogWindow: Expansion / Raid / Boss dropdowns at the top
--   * skipsWindow: simple open/close lifecycle (no hover-grace timer)
--
-- Selection state lives in `achState` (forward-declared at top of file),
-- parallel to but independent from tmogWindow's `browserState`. The two
-- windows can have different raid/boss selections in the same session.
--
-- Forward-declared so the open helpers below can reference it.
local GetOrCreateAchievementsWindow

-- Builder: turn a (raid, boss) selection into a multi-line content string
-- with WoW color/glyph codes. Mirrors BuildTransmogDetail's "single FontString"
-- output shape so the window's content area can stay a simple FontString
-- rather than per-row widgets.
--
-- Output layout:
--
--   {Glory meta name}                               [ ✓ ]    (or 7/10)
--   <blank line>
--   {Achievement name with hyperlink}               [ ✓ ]    (or [ X ])
--     Soloable?:           {Yes / No / —}
--     Required Difficulty: {LFR / Normal / Heroic / Mythic / —}
--     Custom Solo Tips:    {verbatim or —}
--   <blank line>
--   ...repeat per achievement...
--
-- Per-achievement field values come from the data file:
--   ach.soloable          -- nil / "yes" / "kinda" / "no"
--                            (rendered as gray / green / orange / red star)
--   ach.requiresDifficulty -- nil or string
--   ach.soloTip           -- nil or verbatim string
-- nil renders as "|cff666666—|r" (em-dash in dark gray) so empty rows are
-- visible-but-de-emphasized rather than missing entirely.
--
-- Glory meta header is per-RAID, surfaced from raid.gloryMeta. Raids without
-- gloryMeta skip the header line entirely. Completion state probed at render
-- time via GetAchievementInfo + GetAchievementNumCriteria.
-- StaticPopup definition for the "copy Wowhead URL" dialog. Defined once
-- at file load (StaticPopupDialogs is a global Blizzard table). The dialog
-- shows a single-line EditBox pre-filled with the URL; the user Ctrl+C's
-- and dismisses. WoW addons cannot open browser URLs directly, so the
-- copy/paste popup is the standard pattern for surfacing external links
-- (BindPad, Pawn, and many others use the same shape).
StaticPopupDialogs["RETRORUNS_WOWHEAD_URL"] = {
    -- The %s slots are filled by the text_arg1/text_arg2 args passed to
    -- StaticPopup_Show: arg1 is the boss name, arg2 the achievement name.
    -- Putting them in the dialog text (rather than the EditBox) keeps the
    -- copy buffer clean -- only the URL is selected for Ctrl+C.
    text         = "%s\n|cffffd200%s|r\n\nWowhead URL (Ctrl+C to copy):",
    button1      = OKAY or "Okay",
    hasEditBox   = true,
    editBoxWidth = 280,
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    -- preferredIndex protects against the "RAID_WARNING" taint chain that
    -- can break popups in older Blizzard code. 3 is the conventional safe
    -- value; addons calling StaticPopup_Show have used this since BfA.
    preferredIndex = 3,
    OnShow = function(self, data)
        local url = (data and data.url) or ""
        -- Modern Blizzard StaticPopup (GameDialog.xml) exposes the edit
        -- box as `self.EditBox` (capital E). Older code referenced
        -- `self.editBox`; that path errors on current clients.
        local eb = self.EditBox or self.editBox
        if eb then
            eb:SetText(url)
            eb:HighlightText()
            eb:SetFocus()
        end
    end,
    EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

-- Sister StaticPopup for the Settings panel's "comments and feedback"
-- button. Same shape as RETRORUNS_BUG_URL but points to the CurseForge
-- comments tab rather than the GitHub Issues tracker.
StaticPopupDialogs["RETRORUNS_CHAT_URL"] = {
    text         = "Comments and feedback\n\nCurseForge URL (Ctrl+C to copy):",
    button1      = OKAY or "Okay",
    hasEditBox   = true,
    editBoxWidth = 280,
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnShow = function(self, data)
        local url = (data and data.url) or ""
        local eb = self.EditBox or self.editBox
        if eb then
            eb:SetText(url)
            eb:HighlightText()
            eb:SetFocus()
        end
    end,
    EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

-- Sister StaticPopup for the Settings panel's "submit a bug" button.
-- Same pattern as RETRORUNS_WOWHEAD_URL but the dialog text is fixed
-- ("Report a bug") rather than dynamic per-target, so no text_arg
-- substitutions in the text format string. Single-line EditBox
-- pre-filled with the GitHub Issues URL; user Ctrl+C's and dismisses.
StaticPopupDialogs["RETRORUNS_BUG_URL"] = {
    text         = "Report a bug\n\nGitHub Issues URL (Ctrl+C to copy):",
    button1      = OKAY or "Okay",
    hasEditBox   = true,
    editBoxWidth = 280,
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnShow = function(self, data)
        local url = (data and data.url) or ""
        local eb = self.EditBox or self.editBox
        if eb then
            eb:SetText(url)
            eb:HighlightText()
            eb:SetFocus()
        end
    end,
    EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

-- Skip-trigger popup. Shown from the Skips window's per-row info icon.
-- Body renders Quest / Quest IDs / Skip Details labeled lines.
-- Visual vocabulary matches the achievements window's gloryMeta block
-- (label in muted grey |cff9d9d9d, values in normal color) and the
-- skips window's column headers (difficulty labels in |cffaaaaaa).
-- Skip Details runs through HighlightNames so authored ^...^ spans
-- render in the addon's standard orange highlight.
--
-- Quest IDs are derived from raid.skipQuests at render time rather
-- than re-authored in the schema -- single source of truth. They
-- render as clickable RR_quest hyperlinks: clicking opens the
-- standard Wowhead URL popup with the quest URL pre-filled for
-- Ctrl+C copying. The skipTrigger schema field carries only the
-- parts that need authoring: questName and details (a sentence
-- describing the in-raid invocation steps). For multi-chain raids
-- (Antorus), questName and details are author-formatted to cover
-- both chains in one block; the Quest IDs line lists all chain IDs
-- labeled by chain.
StaticPopupDialogs["RETRORUNS_SKIP_TRIGGER"] = {
    -- Title: "Skip:" in retro pink (C_PINK = f259c7), then the raid name.
    -- Left-aligned (anchor override done in OnShow since the default
    -- title FontString is center-anchored).
    text         = "|cffF259C7Skip:|r %s",
    button1      = OKAY or "Okay",
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    preferredIndex = 3,
    -- Wide variant so multi-paragraph skip details wrap comfortably
    -- rather than producing a tall narrow column.
    wide         = true,
    OnShow = function(self, data)
        -- Left-align the title and re-anchor it to the top-left of the
        -- dialog. Blizzard's default StaticPopup title is center-aligned
        -- and anchored centrally; we override per-show because the
        -- pooled popup frame may have been left in another popup's
        -- alignment state.
        if self.text then
            self.text:SetJustifyH("LEFT")
            self.text:ClearAllPoints()
            self.text:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -16)
            self.text:SetPoint("TOPRIGHT", self, "TOPRIGHT", -16, -16)
        end

        -- Lazily create the body FontString once per popup frame instance.
        -- StaticPopup recycles a small pool of dialog frames, so we attach
        -- the body to whatever instance is currently in use.
        if not self.rrTriggerBody then
            local fs = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fs:SetJustifyH("LEFT")
            fs:SetWordWrap(true)
            self.rrTriggerBody = fs
        end
        local fs = self.rrTriggerBody
        fs:ClearAllPoints()
        if self.text then
            fs:SetPoint("TOPLEFT", self.text, "BOTTOMLEFT", 0, -10)
            fs:SetPoint("TOPRIGHT", self.text, "BOTTOMRIGHT", 0, -10)
        else
            fs:SetPoint("TOP", self, "TOP", 0, -40)
            fs:SetWidth(360)
        end

        -- Enable hyperlinks on the popup frame so RR_quest links in the
        -- body FontString are clickable. Routed to the standard Wowhead
        -- URL popup. Set per-show because the pooled popup frame is
        -- shared across StaticPopup types and we don't want our handler
        -- intercepting unrelated popups' clicks.
        self:SetHyperlinksEnabled(true)
        self:SetScript("OnHyperlinkClick", function(_, link, text, button)
            local questID = link and link:match("^RR_quest:(%d+)$")
            if questID then
                UI.ShowWowheadQuestPopup(tonumber(questID),
                    (data and data.raid and data.raid.name) or "?",
                    (data and data.raid and data.raid.skipTrigger
                          and data.raid.skipTrigger.questName) or
                    ("Quest " .. questID))
                return
            end
            SetItemRef(link, text, button)
        end)

        -- Build the three-line body. Render lines that have content;
        -- skip lines whose source data is missing so partially-authored
        -- raids degrade gracefully rather than showing "Quest: nil".
        local raid = data and data.raid
        local trig = raid and raid.skipTrigger or {}
        local lines = {}

        if trig.questName and trig.questName ~= "" then
            table.insert(lines,
                "|cff9d9d9dQuest:|r " .. trig.questName)
        elseif trig.achievementName and trig.achievementName ~= "" then
            -- Achievement-gated skips (BfD) render an Achievement name
            -- line in the same slot a Quest name occupies for
            -- quest-gated raids -- visual symmetry across the two
            -- skip-mechanic shapes.
            table.insert(lines,
                "|cff9d9d9dAchievement:|r " .. trig.achievementName)
        elseif trig.questNames and type(trig.questNames) == "table" then
            -- Multi-chain raids (Antorus): one quest name per chain.
            -- Rendered as a labeled bulleted list to match the
            -- multi-chain Quest IDs section below. Chain order
            -- follows raid.skipQuests so the Quest names list and
            -- Quest IDs list line up row-for-row visually.
            local sqList = raid and raid.skipQuests
            if sqList and sqList[1] and type(sqList[1]) == "table" then
                local nameLines = {}
                for _, chain in ipairs(sqList) do
                    local qname = trig.questNames[chain.label]
                    if qname and qname ~= "" then
                        local label = chain.label
                            and ("|cffaaaaaa" .. chain.label .. ":|r ") or ""
                        table.insert(nameLines, label .. qname)
                    end
                end
                if #nameLines > 0 then
                    table.insert(lines,
                        "|cff9d9d9dQuests:|r\n  - " .. table.concat(nameLines, "\n  - "))
                end
            end
        end

        -- Quest IDs line: pull from raid.skipQuests, supporting both
        -- single-chain (flat normal/heroic/mythic) and multi-chain
        -- (array of { label, normal, heroic, mythic }) shapes. Order
        -- Mythic / Heroic / Normal to match the Skips window's column
        -- order. Each ID is wrapped in an RR_quest hyperlink with
        -- bracket display, matching the link-affordance convention
        -- used elsewhere in the addon.
        local function questLink(id)
            if not id then return nil end
            return ("|HRR_quest:%d|h|cff7faaff[%d]|r|h"):format(id, id)
        end
        local sq = raid and raid.skipQuests
        if sq then
            local function fmtTriplet(m, h, n)
                local parts = {}
                local lm = questLink(m)
                local lh = questLink(h)
                local ln = questLink(n)
                if lm then table.insert(parts, "|cffaaaaaaMythic|r " .. lm) end
                if lh then table.insert(parts, "|cffaaaaaaHeroic|r " .. lh) end
                if ln then table.insert(parts, "|cffaaaaaaNormal|r " .. ln) end
                return table.concat(parts, "  ")
            end
            if sq[1] and type(sq[1]) == "table" then
                -- Multi-chain shape. One bullet line per chain, prefixed
                -- by the chain label. Bullet style matches Skip Details
                -- list ("  - " two-space indent + dash + space).
                local chainLines = {}
                for _, chain in ipairs(sq) do
                    local label = chain.label and ("|cffaaaaaa" .. chain.label .. ":|r ") or ""
                    table.insert(chainLines, label
                        .. fmtTriplet(chain.mythic, chain.heroic, chain.normal))
                end
                table.insert(lines,
                    "|cff9d9d9dQuest IDs:|r\n  - " .. table.concat(chainLines, "\n  - "))
            else
                -- Single-chain (flat) shape.
                table.insert(lines,
                    "|cff9d9d9dQuest IDs:|r " .. fmtTriplet(sq.mythic, sq.heroic, sq.normal))
            end
        elseif raid and raid.skipAchievement then
            -- Achievement-gated skip (BfD). Render the achievement ID
            -- in place of quest IDs; same Mythic-only convention as
            -- the skips window. Routed through the existing
            -- RR_wowhead achievement link prefix. Label is
            -- "Achievement ID:" to parallel the Quest / Quest IDs
            -- split used for quest-gated raids -- avoids duplicating
            -- the "Achievement:" label that already appears at the
            -- top of the popup for the achievement name.
            local sa = raid.skipAchievement
            if sa.mythic then
                table.insert(lines, ("|cff9d9d9dAchievement ID:|r |cffaaaaaaMythic|r |HRR_wowhead:%d|h|cff7faaff[%d]|r|h"):format(sa.mythic, sa.mythic))
            end
        end

        if trig.details and trig.details ~= "" then
            table.insert(lines,
                "|cff9d9d9dSkip Details:|r " .. HighlightNames(trig.details))
        end

        fs:SetText(table.concat(lines, "\n\n"))
        fs:Show()

        -- Re-anchor the OK button below the body. StaticPopup positions
        -- button1 assuming the dialog's only content is self.text, so
        -- our appended body FontString overlaps the default button slot.
        -- Anchor button1 to the bottom of fs with a small gap so the
        -- button sits cleanly below the rendered body.
        local btn = self.button1 or _G[self:GetName() .. "Button1"]
        if btn then
            btn:ClearAllPoints()
            btn:SetPoint("TOP", fs, "BOTTOM", 0, -12)
        end

        -- Compute total height from scratch rather than incrementing
        -- self:GetHeight() (which accumulates across re-shows since
        -- Blizzard doesn't always reset the frame between shows of
        -- different content). Components: top padding, title text
        -- height, gap, body height, gap, button height, bottom padding.
        local titleH  = (self.text and self.text:GetStringHeight()) or 16
        local bodyH   = fs:GetStringHeight() or 0
        local buttonH = btn and btn:GetHeight() or 24
        self:SetHeight(20 + titleH + 10 + bodyH + 12 + buttonH + 18)

        -- Tag the popup frame with the raid's instanceID so a re-click
        -- of the SAME row's [ i ] can recognize "popup is already up
        -- for this raid" and toggle it closed, while a click on a
        -- DIFFERENT row's [ i ] still re-shows the popup with the new
        -- raid's content. Cleared in OnHide so a stale ID can't leak
        -- to a future show of an unrelated raid.
        self.rrSkipRaidID = raid and raid.instanceID or nil

        -- Reposition the popup at the cursor instead of screen center.
        -- StaticPopup defaults anchor center-screen via the popup-stack
        -- layout in StaticPopup_DisplayedFrames; we override after the
        -- stack has placed us. Anchor TOPLEFT down-and-right of the
        -- cursor so the [ i ] button the user just clicked stays
        -- uncovered (the popup hangs off the lower-right of the click
        -- point). Without this offset the popup overlays the button
        -- and there's no easy way to toggle it back closed. Clamp to
        -- screen via SetClampedToScreen so popups near the right or
        -- bottom edge slide back into view.
        local mx, my = GetCursorPosition()
        local effScale = UIParent:GetEffectiveScale() or 1
        if mx and my and effScale > 0 then
            self:ClearAllPoints()
            self:SetClampedToScreen(true)
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
                mx / effScale + 16, my / effScale - 16)
        end
    end,
    OnHide = function(self)
        -- Clear the raid-ID tag so a future show of an unrelated
        -- raid (or of this popup type by some other caller) starts
        -- from a clean slate -- the toggle check in the [ i ] button
        -- OnClick relies on this not lingering.
        self.rrSkipRaidID = nil
        if self.rrTriggerBody then
            self.rrTriggerBody:SetText("")
            self.rrTriggerBody:Hide()
        end
        -- Restore the OK button to its default anchor so re-use of this
        -- pooled popup frame by other StaticPopup types doesn't inherit
        -- our custom anchor. Default StaticPopup button1 anchor is
        -- BOTTOM of the frame, offset by 16px.
        local btn = self.button1 or _G[self:GetName() .. "Button1"]
        if btn then
            btn:ClearAllPoints()
            btn:SetPoint("BOTTOM", self, "BOTTOM", 0, 16)
        end
        -- Restore the title FontString to its default center alignment
        -- so other StaticPopup types don't inherit our left-align.
        if self.text then
            self.text:SetJustifyH("CENTER")
        end
        -- Drop our hyperlink handler so subsequent popups using this
        -- pooled frame don't inherit a stale OnHyperlinkClick.
        self:SetScript("OnHyperlinkClick", nil)
    end,
}

-- Public so the achievements window's hyperlink handler can call it.
function UI.ShowWowheadPopup(achievementID, bossName, achievementName)
    if not achievementID then return end
    -- Wowhead handles slug redirection from the bare ID, so we don't need
    -- to construct the human-readable slug ourselves -- /achievement=14293
    -- redirects to /achievement=14293/blind-as-a-bat automatically.
    local url = ("https://www.wowhead.com/achievement=%d"):format(achievementID)
    -- Defensive defaults if the caller (older codepath) doesn't pass names.
    bossName        = bossName        or "?"
    achievementName = achievementName or ("Achievement " .. achievementID)
    StaticPopup_Show("RETRORUNS_WOWHEAD_URL",
                     bossName, achievementName, { url = url })
end

-- Sibling of ShowWowheadPopup for skip quests. Wowhead handles slug
-- redirection from the bare quest ID. Reuses RETRORUNS_WOWHEAD_URL --
-- the popup is generic over URL kind; only the header lines change
-- per caller.
function UI.ShowWowheadQuestPopup(questID, raidName, questName)
    if not questID then return end
    local url = ("https://www.wowhead.com/quest=%d"):format(questID)
    raidName  = raidName  or "?"
    questName = questName or ("Quest " .. questID)
    StaticPopup_Show("RETRORUNS_WOWHEAD_URL",
                     raidName, questName, { url = url })
end


-- Builder: walk a raid's bosses and produce a structured row list that the
-- achievements window's row pool can render as a table. Each row has a
-- `kind` plus kind-specific fields. The window decides per-kind which
-- widgets to show and where to position them.
--
-- Row kinds:
--   "glory"    -- raid-level Glory meta header. Fields: id, name, completed,
--                 done, total, rewardSpellID, rewardItemID, rewardName.
--                 Skipped when raid has no gloryMeta entry. Always first.
--   "spacer"   -- inserts a half-row of vertical space.
--   "header"   -- column header row. Static labels.
--   "achRow"   -- one boss + one achievement. Fields: bossName,
--                 achievementID, achievementName, completed, soloable, meta.
--                 Bosses with N achievements produce N rows (boss name
--                 repeats by design -- the column makes scanning easier).
--   "naRow"    -- boss has zero achievements. Fields: bossName.
--                 Renders "N/A" in the achievement and status columns.
local function BuildAchievementRows(raid)
    local rows = {}
    if not raid then return rows end

    -- 1. Glory meta header (when present)
    local meta = raid.gloryMeta
    if meta and meta.id then
        local _, mName, _, mCompleted = GetAchievementInfo(meta.id)
        local total = GetAchievementNumCriteria and GetAchievementNumCriteria(meta.id) or 0
        local done  = 0
        if total and total > 0 and GetAchievementCriteriaInfo then
            for i = 1, total do
                local _, _, critDone = GetAchievementCriteriaInfo(meta.id, i)
                if critDone then done = done + 1 end
            end
        end
        table.insert(rows, {
            kind          = "glory",
            id            = meta.id,
            name          = mName or meta.name or ("Glory ID " .. meta.id),
            completed     = mCompleted,
            done          = done,
            total         = total,
            rewardSpellID = meta.rewardMountSpellID,
            rewardItemID  = meta.rewardItemID,
            rewardName    = meta.rewardName,
            rewardTitle   = meta.rewardTitle,
        })
        table.insert(rows, { kind = "spacer" })
    end

    -- 2. Column header row (always shown so users can read the table).
    table.insert(rows, { kind = "header" })

    -- 3. Per-boss rows in encounter order. Bosses with multiple achievements
    --    expand to multiple rows (one per achievement); bosses with none
    --    produce a single naRow.
    if raid.bosses then
        for _, boss in ipairs(raid.bosses) do
            local bossName = boss.name or "?"
            if not boss.achievements or #boss.achievements == 0 then
                table.insert(rows, { kind = "naRow", bossName = bossName })
            else
                for _, ach in ipairs(boss.achievements) do
                    local _, aName, _, aCompleted = GetAchievementInfo(ach.id)
                    table.insert(rows, {
                        kind            = "achRow",
                        bossName        = bossName,
                        achievementID   = ach.id,
                        achievementName = aName or ach.name or ("ID " .. ach.id),
                        completed       = aCompleted,
                        soloable        = ach.soloable,
                        meta            = ach.meta,
                    })
                end
            end
        end
    end

    return rows
end

-- Last-rendered fingerprint for the achievements window's row table.
-- Used to short-circuit f.RefreshContent when no state change has occurred
-- since the last render. Same root-cause class as the idle-list click-race
-- bug: UI.Update calls UpdateAchievementsWindow on every 1Hz heartbeat,
-- which calls RefreshContent, which calls HideAllAchSlots() -- hiding the
-- per-row wowhead "?" buttons on every tick. A user click whose
-- OnMouseDown landed before a heartbeat but OnMouseUp would have landed
-- after got eaten: the button vanished mid-click and OnClick never fired.
-- Symptom: intermittent unresponsiveness of the wowhead-column buttons,
-- with the bug correlated to heartbeat tick timing. Mirrors the
-- lastIdleListFingerprint pattern documented earlier in this file.
local lastAchRowsFingerprint = nil

-- Public hook: callers that need to force a rebuild (font-size changes
-- that affect row rendering) can invalidate the cached fingerprint so
-- the next RefreshContent call actually rebuilds. Mirrors
-- UI.InvalidateIdleListCache.
function UI.InvalidateAchievementsCache()
    lastAchRowsFingerprint = nil
end

-- Serialize the row list + current-boss highlight key to a stable string.
-- Only includes fields that affect the rendered output. currentBossName
-- is included because it drives the per-row highlight band independently
-- of row content -- route progress shifts which boss is highlighted
-- without changing any row data, and without including it here the
-- highlight would freeze on whichever boss was current at last render.
local function FingerprintAchRows(rows, currentBossName)
    local parts = {}
    for i, row in ipairs(rows) do
        local k = row.kind or "?"
        if k == "glory" then
            parts[i] = ("G|%s|%s|%s|%s|%s"):format(
                tostring(row.id), tostring(row.name),
                tostring(row.completed),
                tostring(row.done), tostring(row.total))
        elseif k == "achRow" then
            parts[i] = ("A|%s|%s|%s|%s|%s|%s"):format(
                tostring(row.bossName), tostring(row.achievementID),
                tostring(row.achievementName), tostring(row.completed),
                tostring(row.soloable), tostring(row.meta))
        elseif k == "naRow" then
            parts[i] = ("N|%s"):format(tostring(row.bossName))
        else
            -- spacer, header: no per-row state beyond kind
            parts[i] = k
        end
    end
    parts[#parts + 1] = "CB|" .. tostring(currentBossName or "")
    return table.concat(parts, "\n")
end

-- Initialize achState with empty fields. Filled by EnsureAchDefaults() on
-- first open, then maintained by dropdown clicks. Boss-level selection was
-- removed when the window switched to a full-raid table; only Expansion
-- and Raid are user-selectable now.
achState = {
    expansion = nil,
    raidKey   = nil,
}

-- Pick sensible default selection on first open. Mirrors EnsureBrowserDefaults
-- but writes to achState so the tmog browser's selection isn't disturbed.
-- Defaults: current raid if the player is in one, else the first raid in the
-- newest expansion that has data.
local function EnsureAchDefaults()
    local byExpansion, expansions = EnumerateRaids()
    if #expansions == 0 then return end

    -- Prefer the player's current raid if they're standing in one.
    if not achState.raidKey then
        local currentID = RR.currentRaid and RR.currentRaid.instanceID
        local currentRaid = currentID and RR:GetRaidByInstanceID(currentID)
        if currentRaid then
            achState.raidKey   = currentID
            achState.expansion = currentRaid.expansion
        end
    end
    -- Fall back to the first raid in the first expansion.
    if not achState.expansion then
        achState.expansion = expansions[1]
    end
    if not achState.raidKey then
        local firstRaid = byExpansion[achState.expansion]
                          and byExpansion[achState.expansion][1]
        if firstRaid then achState.raidKey = firstRaid.instanceID end
    end
end

-- Layout constants for the achievements row table. Matches the skips
-- window's pattern: column x-offsets are absolute pixel positions from
-- the window's TOPLEFT, used for both header labels and per-row widgets
-- so they line up by construction.
--
-- Window width 440. Status (right-anchored cell, ~50px wide) sits at the
-- left, Achievement is the wide flex column, Boss is the right-side
-- column, and the Wowhead button anchors near the right edge.
local ACH_WINDOW_WIDTH       = 510
local ACH_WINDOW_MIN_HEIGHT  = 200
local ACH_WINDOW_MAX_HEIGHT  = 700

local ACH_COL_STATUS_X     = 36   -- center x of the status indicator
local ACH_COL_NAME_X       = 64   -- left of the achievement-name column
-- The following are FLOOR minimums used by the auto-sizing pass in
-- RefreshContent. The actual column widths and overall window width are
-- computed per-refresh from the longest measured content; these constants
-- prevent the table from collapsing when content is unusually short
-- (single-achievement raid, very short boss names).
local ACH_COL_NAME_W       = 245  -- min width of achievement column
local ACH_COL_BOSS_W       = 150  -- min width of boss column

-- Wowhead column geometry. Both the header label and the per-row button
-- are anchored to the window's TOPRIGHT, with the header CENTER-anchored
-- over the button's center so the column reads as one unit. Driving both
-- from the same offsets avoids the drift that happened when they were
-- anchored independently. Right-inset is bumped enough that the "Wowhead"
-- header text doesn't bleed past the window's edge -- the label is wider
-- than the button, so it needs room beyond the button's footprint.
local ACH_WOWHEAD_BTN_W       = 22
-- Button height shrunk to 14 (was 18) so it fits cleanly inside the
-- row band. The row band's visible vertical extent is ~15px (lineHeight
-- minus ACH_ROW_BOTTOM_INSET), so anything taller than that overflows
-- the divider lines above or below. 14px keeps the button entirely
-- within the band with ~0.5px breathing room top and bottom -- the
-- "?" glyph still reads cleanly at this height since UIPanelButton-
-- Template's internal padding is small.
local ACH_WOWHEAD_BTN_H       = 14
local ACH_WOWHEAD_RIGHT_INSET = 30   -- distance from window right edge to button's right edge
-- Center x of the button = -RIGHT_INSET - BTN_W/2 (relative to TOPRIGHT).
local ACH_WOWHEAD_CENTER_X    = -ACH_WOWHEAD_RIGHT_INSET - ACH_WOWHEAD_BTN_W / 2

-- Per-row vertical spacing. Same multiplier as skips for visual parity.
local ACH_LINE_GAP         = 1.7

-- Row dividers and the bottom edge of the current-boss highlight band
-- both sit at this y-offset above the row's nominal bottom (y -
-- lineHeight). Tuned to hug the text from below instead of leaving
-- extra space below the glyphs -- with the highlight band drawn,
-- extra space makes the text look top-aligned within its band.
-- Higher value moves the divider/highlight bottom UP toward the text.
-- Tune carefully: too high and the divider cuts into text descenders;
-- too low and text looks top-heavy again.
local ACH_ROW_BOTTOM_INSET = 5

-- Glyphs reused from the encounter renderer / skips table for visual
-- consistency.
local ACH_CELL_DONE   = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local ACH_CELL_TODO   = "|cffaaaaaaX|r"
local ACH_CELL_NA     = "|cff666666N/A|r"

-- Meta-Glory prefix textures. Both occupy the same width so non-meta
-- rows visually align with meta rows in the achievement column.
--
-- The non-meta variant uses the same 14x14 texture footprint but with
-- vertex color RGBA = 0,0,0,0 (fully transparent) -- the width is
-- preserved without any visible glyph. The full |T...|t syntax below
-- specifies: path, height, width, xOff, yOff, texW, texH, leftCoord,
-- rightCoord, topCoord, bottomCoord, then R, G, B, A.
local ACH_META_PREFIX     = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t "
local ACH_NON_META_PREFIX = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14:0:0:64:64:0:64:0:64:80:80:80|t "

-- Soloable indicator. Per-achievement `soloable` field is one of:
--   "yes"   -> green star  (any class can solo)
--   "kinda" -> orange star (solo possible but requires specific class
--                           abilities, e.g., self-heal, immunity, pet)
--   "no"    -> red star    (confirmed not soloable)
--   nil     -> gray star   (not yet evaluated)
--
-- Returns a pre-formatted string ready to concatenate into the
-- achievement-cell text. The leading space is folded in so callers don't
-- need to worry about spacing -- if there's no field at all the gray
-- star still renders, since a missing marker would be ambiguous (could
-- mean "no info" OR "not soloable").
local function GetSoloableStar(soloable)
    if soloable == "yes"   then return " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:0:255:0|t" end
    if soloable == "kinda" then return " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:255:136:0|t" end
    if soloable == "no"    then return " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:255:51:51|t" end
    return " |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:40:40:40|t"  -- nil / unknown / not yet evaluated
end

-- Row pool. Each slot holds the widgets needed for any kind of row; the
-- refresh loop hides unused widgets per kind. Keyed by row index so slot
-- N is reused across rebuilds at the same row position.
--
-- Wrapped in a do/end block to keep the supporting locals out of UI.lua's
-- top-level scope (Lua 5.1 caps local-variable count at 200 per function;
-- this file's main chunk hits that ceiling otherwise). Same pattern as
-- the What's New window block above.
do
local achRowPool = {}

local function GetAchRowSlot(parent, idx)
    if achRowPool[idx] then return achRowPool[idx] end
    local slot = {}

    -- Status cell (text). Center-anchored at ACH_COL_STATUS_X.
    slot.status = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.status:SetJustifyH("CENTER")

    -- Achievement-name cell (FontString). Left-anchored, capped width so
    -- long names truncate-with-ellipsis rather than running into the
    -- Boss column.
    slot.ach = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.ach:SetJustifyH("LEFT")
    slot.ach:SetWordWrap(false)

    -- Boss-name cell.
    slot.boss = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.boss:SetJustifyH("LEFT")
    slot.boss:SetWordWrap(false)

    -- Wowhead button (real Button widget so it has hover/click states).
    -- Square-ish, small, "?" label since the column header reads "Wowhead"
    -- already and a plain "?" reads as "more info" without competing with
    -- the achievement-link orange in adjacent rows. UIPanelButtonTemplate
    -- gives the standard Blizzard pressed/highlighted states for free.
    slot.wowhead = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    slot.wowhead:SetSize(ACH_WOWHEAD_BTN_W, ACH_WOWHEAD_BTN_H)
    slot.wowhead:SetText("|cffffffff?|r")

    -- Subtle horizontal divider drawn at the bottom of the row. Dim and
    -- slightly transparent so it reads as visual structure without
    -- competing with the cell text. ARTWORK draw layer keeps it below
    -- the OVERLAY-layer FontStrings -- if a row's text overlaps the
    -- divider position by a pixel or two, the text wins.
    slot.divider = parent:CreateTexture(nil, "ARTWORK")
    slot.divider:SetColorTexture(0.4, 0.4, 0.4, 0.25)
    slot.divider:SetHeight(1)

    -- "Current boss" highlight: a faint full-row blue tint plus a
    -- brighter left-edge accent bar. BORDER draw layer (not BACKGROUND)
    -- so they render ABOVE the frame's own backdrop -- with BACKGROUND,
    -- the panel's opaque chrome was occluding the tint and the
    -- highlight was only visible when window opacity was turned down.
    -- BORDER still sits below ARTWORK (dividers) and OVERLAY (text), so
    -- the highlight reads as a tinted band BEHIND the row's content.
    -- Tint alpha bumped from 0.10 to 0.22 for visibility against the
    -- standard opaque panel; accent saturation bumped to match.
    slot.highlight = parent:CreateTexture(nil, "BORDER")
    slot.highlight:SetColorTexture(0.30, 0.65, 1.0, 0.22)
    slot.accent = parent:CreateTexture(nil, "BORDER")
    slot.accent:SetColorTexture(0.45, 0.80, 1.0, 1.0)
    slot.accent:SetWidth(3)

    achRowPool[idx] = slot
    return slot
end

local function HideAllAchSlots()
    -- IMPORTANT: use pairs, not ipairs. The pool is keyed by render-row
    -- index, but the first 1-3 rows of every render are "glory", "spacer",
    -- and "header" kinds which DON'T call GetAchRowSlot -- so the pool's
    -- integer keys start at 4 (or wherever the first achRow/naRow is),
    -- not 1. ipairs stops at the first nil key, so it would have hidden
    -- nothing and let the previous raid's rows leak through visually.
    for _, slot in pairs(achRowPool) do
        slot.status:Hide()
        slot.ach:Hide()
        slot.boss:Hide()
        slot.wowhead:Hide()
        slot.divider:Hide()
        slot.highlight:Hide()
        slot.accent:Hide()
    end
end

GetOrCreateAchievementsWindow = function()
    if achievementsWindow then return achievementsWindow end

    local f = CreateFrame("Frame", "RetroRunsAchievementsWindow", UIParent, "BackdropTemplate")
    f:SetSize(ACH_WINDOW_WIDTH, ACH_WINDOW_MIN_HEIGHT)
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    f:SetPoint("TOPLEFT", panel, "TOPRIGHT", 6, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f:Hide()

    -- Hyperlink router: achievement and item links use SetItemRef as
    -- usual. Custom RR_wowhead: links would no longer reach this handler
    -- (the per-row Button is the new entry point), but the prefix check
    -- is left in for forward compatibility / safety.
    f:SetHyperlinksEnabled(true)
    f:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local achID = link and link:match("^RR_wowhead:(%d+)$")
        if achID then
            UI.ShowWowheadPopup(tonumber(achID))
            return
        end
        SetItemRef(link, text, button)
    end)
    f:SetScript("OnHyperlinkEnter", function(self, link)
        if link and link:match("^RR_wowhead:") then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    f:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

    -- Title plate
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -10)
    title:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  Achievements")
    title:SetFont(TITLE_FONT, 16, "")
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Two cascading dropdowns: Expansion / Raid. Boss-level selection
    -- was removed when the window switched to a full-raid table view --
    -- all bosses for the selected raid render simultaneously.
    local function MakeDD(name, width, parent)
        local dd = CreateFrame("Frame", "RetroRunsAch" .. name .. "DD", parent,
                               "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(dd, width)
        return dd
    end

    local ddExp  = MakeDD("Expansion", 140, f)
    local ddRaid = MakeDD("Raid",      220, f)

    ddExp:SetPoint("TOPLEFT",  f,     "TOPLEFT",     -4, -32)
    ddRaid:SetPoint("TOPLEFT", ddExp, "BOTTOMLEFT",   0,   4)

    f.ddExp, f.ddRaid = ddExp, ddRaid

    -- Glory header section (above the column-header row). Three FontStrings
    -- repositioned by RefreshContent based on whether the raid has a
    -- gloryMeta. titleLine renders only when the Glory rewards a title
    -- (e.g. "the Tomb Raider"). Hidden entirely when there's no Glory.
    f.gloryLine = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.gloryLine:SetJustifyH("LEFT")
    f.gloryLine:SetWordWrap(false)

    f.rewardLine = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.rewardLine:SetJustifyH("LEFT")
    f.rewardLine:SetWordWrap(false)

    f.titleLine = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.titleLine:SetJustifyH("LEFT")
    f.titleLine:SetWordWrap(false)

    -- Column-header FontStrings. Persistent (positioned by RefreshContent
    -- based on whether Glory is present) and shown for every non-empty
    -- raid render.
    f.hdrStatus = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.hdrStatus:SetJustifyH("CENTER")
    f.hdrStatus:SetText("|cff4DCCFFStatus|r")

    f.hdrAch = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.hdrAch:SetJustifyH("LEFT")
    f.hdrAch:SetText("|cff4DCCFFAchievement|r")

    f.hdrBoss = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.hdrBoss:SetJustifyH("LEFT")
    f.hdrBoss:SetText("|cff4DCCFFBoss|r")

    f.hdrWowhead = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.hdrWowhead:SetJustifyH("CENTER")
    f.hdrWowhead:SetText("|cffff8000Wowhead|r")

    -- Hidden measurement FontString used by RefreshContent to query the
    -- rendered width of each row's text BEFORE laying it out, so columns
    -- and the overall window can auto-size to fit the widest content.
    -- GetStringWidth is synchronous after SetText/SetFont (unlike
    -- GetStringHeight, which is lazy after SetFont) -- the trick is to
    -- call SetFont *first* with the measurement font, then SetText, then
    -- read GetStringWidth. Hidden because we don't want it visible.
    f.measureFS = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    f.measureFS:Hide()

    -- Legend below the table. Two FontStrings: meta-key on the left,
    -- soloable color key on the right. Splitting them lets the soloable
    -- key anchor to BOTTOMRIGHT independently of the meta-key text width
    -- (which used to push the soloable text leftward and made the right
    -- side of the table feel cluttered when the window grew wide).
    --
    -- Star colors match GetSoloableStar() exactly:
    --   green  = soloable (any class)
    --   orange = soloable with class-specific abilities ("kinda")
    --   red    = not soloable
    --   gray   = not yet evaluated
    f.legendLeft = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.legendLeft:SetJustifyH("LEFT")
    f.legendLeft:SetText(
        "|cff9d9d9d|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t = meta criteria|r"
    )

    f.legendRight = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.legendRight:SetJustifyH("RIGHT")
    f.legendRight:SetText(
        "|cff9d9d9dSoloable: |r|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:0:255:0|t|cff9d9d9d yes  |r"
        .. "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:255:136:0|t|cff9d9d9d kinda  |r"
        .. "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:255:51:51|t|cff9d9d9d no  |r"
        .. "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:40:40:40|t|cff9d9d9d unknown|r"
    )

    achievementsWindow = f

    -- ----- Dropdown initializers -----
    f.RefreshDropdowns = function(self)
        EnsureAchDefaults()
        local byExp, expList = EnumerateRaids()

        UIDropDownMenu_Initialize(ddExp, function()
            for _, expName in ipairs(expList) do
                local info = UIDropDownMenu_CreateInfo()
                info.text    = expName
                info.value   = expName
                info.checked = (expName == achState.expansion)
                info.func    = function()
                    if achState.expansion == expName then return end
                    achState.expansion = expName
                    local first = byExp[expName] and byExp[expName][1]
                    achState.raidKey = first and first.instanceID or nil
                    f:RefreshAll()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetText(ddExp, achState.expansion or "(none)")

        UIDropDownMenu_Initialize(ddRaid, function()
            local raids = byExp[achState.expansion] or {}
            for _, raid in ipairs(raids) do
                local info = UIDropDownMenu_CreateInfo()
                info.text    = raid.name or "?"
                info.value   = raid.instanceID
                info.checked = (raid.instanceID == achState.raidKey)
                info.func    = function()
                    if achState.raidKey == raid.instanceID then return end
                    achState.raidKey = raid.instanceID
                    -- Use RefreshAll so the dropdown's displayed-text is
                    -- updated alongside the content. Calling RefreshContent
                    -- alone would leave the raid dropdown showing the
                    -- previous raid's name.
                    f:RefreshAll()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        local raidName = "(none)"
        local selRaid = achState.raidKey and RR:GetRaidByInstanceID(achState.raidKey)
        if selRaid then raidName = selRaid.name or "?" end
        UIDropDownMenu_SetText(ddRaid, raidName)
    end

    -- ----- Row-table refresh -----
    -- Rebuilds the table content, positions all row widgets, sizes the
    -- window. Same shape as RefreshSkipsContent.
    f.RefreshContent = function(self)
        local raid = achState.raidKey and RR:GetRaidByInstanceID(achState.raidKey) or nil
        local rows = BuildAchievementRows(raid)

        -- Determine the current route boss for the displayed raid (if
        -- any). The highlight only fires when the achievements window
        -- is showing the same raid the route is currently progressing
        -- through; cross-raid (browsing Sepulcher while running CN) gets
        -- no highlight, since "current boss" makes no sense there.
        local currentBossName = nil
        if raid and RR.currentRaid and RR.currentRaid.instanceID == raid.instanceID then
            local step = RR.state and RR.state.activeStep
            if step and step.bossIndex and raid.bosses then
                local boss = raid.bosses[step.bossIndex]
                if boss then currentBossName = boss.name end
            end
        end

        -- Fingerprint-gate the rebuild. Heartbeats with no state change
        -- (the common case once the window is open) skip the entire
        -- HideAllAchSlots + widget churn below, which would otherwise
        -- vanish the wowhead "?" buttons mid-click. See
        -- lastAchRowsFingerprint comment for the full rationale.
        -- The second guard handles the first-call case where the
        -- fingerprint is nil and the window has never rendered -- we
        -- need the very first render to proceed even though "no diff"
        -- is technically true.
        local fp = FingerprintAchRows(rows, currentBossName)
        if fp == lastAchRowsFingerprint and f.hdrStatus:IsShown() then
            return
        end
        lastAchRowsFingerprint = fp

        HideAllAchSlots()

        -- Defensively hide the persistent header FontStrings too. They get
        -- :Show()'d again when the "header" row renders below, which is
        -- always for non-empty raids -- but if a future code path renders
        -- a raid with no rows, hiding here ensures the previous raid's
        -- headers don't leak through visually.
        f.gloryLine:Hide()
        f.rewardLine:Hide()
        f.titleLine:Hide()
        f.hdrStatus:Hide()
        f.hdrAch:Hide()
        f.hdrBoss:Hide()
        f.hdrWowhead:Hide()

        local fontSize   = RR:GetSetting("fontSize", 12)
        -- Row content renders one point smaller than the user-facing
        -- fontSize setting, matching the Tmog window's content font for
        -- visual parity across all auxiliary windows. Line spacing keeps
        -- using fontSize so the row pitch isn't affected.
        local rowFontSize = fontSize - 1
        -- Line height uses the active body font's effective size (so
        -- VT323 and other non-FRIZQT fonts get the right row pitch).
        -- ACH_LINE_GAP is the multiplier on top of the effective size.
        local lineHeight  = math.floor(GetBodyFontSize(fontSize) * ACH_LINE_GAP + 0.5)

        -- Width measurement pass. Walk the rows once with a hidden
        -- FontString to find the widest rendered achievement-name and
        -- boss-name strings, then derive column widths and the overall
        -- window width from those measurements. Falls back to minimums
        -- (the ACH_COL_*_W constants) when content is shorter.
        --
        -- This is what makes the window auto-size to fit longer names --
        -- a raid with a "Sanctum of Domination" boss like "Tarragrue,
        -- the Bound One" doesn't get truncated; the window grows.
        local function MeasureWidth(fontString, text)
            SetBodyFont(fontString, rowFontSize, "")
            fontString:SetText(text or "")
            return fontString:GetStringWidth() or 0
        end

        local widestAch  = MeasureWidth(f.measureFS, "Achievement")  -- start with header width
        local widestBoss = MeasureWidth(f.measureFS, "Boss")
        for _, row in ipairs(rows) do
            if row.kind == "achRow" then
                -- Build the same string the achievement column will
                -- render so the measurement matches what's painted.
                -- Both meta and non-meta rows include a fixed-width
                -- prefix for column alignment (transparent for non-meta).
                local metaPrefix = row.meta and ACH_META_PREFIX or ACH_NON_META_PREFIX
                local link = GetAchievementLink and GetAchievementLink(row.achievementID)
                              or row.achievementName
                local soloStar = GetSoloableStar(row.soloable)
                local achText  = metaPrefix .. link .. soloStar
                local achW = MeasureWidth(f.measureFS, achText)
                if achW > widestAch then widestAch = achW end

                local bossW = MeasureWidth(f.measureFS, row.bossName)
                if bossW > widestBoss then widestBoss = bossW end

            elseif row.kind == "naRow" then
                local bossW = MeasureWidth(f.measureFS, row.bossName)
                if bossW > widestBoss then widestBoss = bossW end
            end
        end

        -- Per-column padding: extra px beyond the widest content. Keeps
        -- adjacent columns from feeling crowded.
        local COL_PADDING = 14

        -- Resolve column widths -- max(measured + padding, min-constant).
        local colNameW = math.max(widestAch  + COL_PADDING, ACH_COL_NAME_W)
        local colBossW = math.max(widestBoss + COL_PADDING, ACH_COL_BOSS_W)

        -- Boss column starts after the achievement column ends.
        local colBossX = ACH_COL_NAME_X + colNameW + 6

        -- Window width: status column + ach column + boss column +
        -- Wowhead column (button + inset on each side) + left margin.
        -- The +20 right of the boss column accounts for the gap before
        -- the Wowhead button starts.
        local wowheadColumnW = ACH_WOWHEAD_BTN_W + ACH_WOWHEAD_RIGHT_INSET + 20
        local windowW = colBossX + colBossW + wowheadColumnW
        windowW = math.max(windowW, ACH_WINDOW_WIDTH)
        f:SetWidth(windowW)

        -- Vertical cursor starts below the dropdown stack. The two
        -- dropdowns occupy ~64px below the title bar.
        local DROPDOWNS_BOTTOM = 32 + 2 * 32  -- title + 2 dropdowns
        local y = -DROPDOWNS_BOTTOM - 4

        -- Glory header (two lines: header + reward). Hidden if absent.
        local rowsStart = 1
        if rows[1] and rows[1].kind == "glory" then
            local g = rows[1]

            -- Status fragment: "[ ✓ ]" if completed, "n/N" otherwise.
            -- Gold for the progress count to match the encounter section.
            local statusFrag
            if g.completed then
                statusFrag = ("|cff777777[ |r|cff00ff00%s|r|cff777777 ]|r"):format(ACH_CELL_DONE)
            else
                statusFrag = ("|cffffd200%d/%d|r"):format(g.done or 0, g.total or 0)
            end

            local link = GetAchievementLink and GetAchievementLink(g.id) or g.name
            if g.completed and link ~= g.name then
                link = link:gsub("^|cff%x%x%x%x%x%x", ""):gsub("|r$", "")
                link = ("|cff888888%s|r"):format(link)
            end
            SetBodyFont(f.gloryLine, fontSize + 2, "")
            f.gloryLine:SetText(("%s   %s"):format(link, statusFrag))
            f.gloryLine:ClearAllPoints()
            f.gloryLine:SetPoint("TOPLEFT", f, "TOPLEFT", 14, y)
            f.gloryLine:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, y)
            f.gloryLine:Show()
            y = y - (fontSize + 6)

            -- Reward line. The line shows a state glyph indicating whether
            -- the player has collected the Glory's reward (mount or pet),
            -- then the resolved spell/item link. Glyph vocabulary matches
            -- Special Loot (green check for collected, plain X otherwise).
            local rewardText
            if g.rewardSpellID and C_Spell and C_Spell.GetSpellLink then
                rewardText = C_Spell.GetSpellLink(g.rewardSpellID)
            end
            if not rewardText and g.rewardItemID then
                local _, itemLink = GetItemInfo(g.rewardItemID)
                rewardText = itemLink
            end
            if not rewardText then
                rewardText = g.rewardName
                          and ("|cffffffff%s|r"):format(g.rewardName)
                          or  "|cffffffff(Reward)|r"
            end

            SetBodyFont(f.rewardLine, rowFontSize, "")
            f.rewardLine:SetText(("|cff9d9d9dReward:|r %s"):format(rewardText))
            f.rewardLine:ClearAllPoints()
            f.rewardLine:SetPoint("TOPLEFT", f, "TOPLEFT", 14, y)
            f.rewardLine:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, y)
            f.rewardLine:Show()
            y = y - lineHeight

            -- Title line. Some Glory metas (Tomb, etc.) award a character
            -- title in addition to the mount/pet. Rendered as a plain
            -- informational line below the reward; no collection-state
            -- query since the title-knowledge API surface is awkward and
            -- the value to the player is just knowing it exists.
            if g.rewardTitle then
                SetBodyFont(f.titleLine, rowFontSize, "")
                f.titleLine:SetText(("|cff9d9d9dTitle:|r |cffffffff%s|r"):format(g.rewardTitle))
                f.titleLine:ClearAllPoints()
                f.titleLine:SetPoint("TOPLEFT", f, "TOPLEFT", 14, y)
                f.titleLine:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, y)
                f.titleLine:Show()
                y = y - lineHeight
            else
                f.titleLine:Hide()
            end

            -- Skip the glory row in the data-row loop below; the spacer
            -- row that follows still applies its half-line gap.
            rowsStart = 2
        end

        -- Walk remaining rows. The header row is always present (added
        -- by BuildAchievementRows after the optional glory+spacer); we
        -- treat it the same as data rows in terms of pool-slot reuse,
        -- but render it via the persistent column-header FontStrings.
        for i = rowsStart, #rows do
            local row = rows[i]

            if row.kind == "spacer" then
                y = y - math.floor(lineHeight / 2)

            elseif row.kind == "header" then
                -- Position the persistent column-header FontStrings.
                SetBodyFont(f.hdrStatus, rowFontSize, "")
                f.hdrStatus:ClearAllPoints()
                f.hdrStatus:SetPoint("TOP", f, "TOPLEFT", ACH_COL_STATUS_X, y)
                f.hdrStatus:Show()

                SetBodyFont(f.hdrAch, rowFontSize, "")
                f.hdrAch:ClearAllPoints()
                f.hdrAch:SetPoint("TOPLEFT", f, "TOPLEFT", ACH_COL_NAME_X, y)
                f.hdrAch:Show()

                SetBodyFont(f.hdrBoss, rowFontSize, "")
                f.hdrBoss:ClearAllPoints()
                f.hdrBoss:SetPoint("TOPLEFT", f, "TOPLEFT", colBossX, y)
                f.hdrBoss:Show()

                SetBodyFont(f.hdrWowhead, rowFontSize, "")
                f.hdrWowhead:ClearAllPoints()
                -- CENTER-anchor the header at the button center so the
                -- label reads as a column header for the buttons below.
                f.hdrWowhead:SetPoint("TOP", f, "TOPRIGHT", ACH_WOWHEAD_CENTER_X, y)
                f.hdrWowhead:Show()

                y = y - lineHeight

            elseif row.kind == "achRow" then
                local slot = GetAchRowSlot(f, i)

                -- Current-boss highlight + left accent bar. The textures
                -- span from this row's top (y) down to the bottom of its
                -- vertical band (y - lineHeight). Insets match the divider
                -- inset so the highlight visually frames within the table
                -- bounds rather than running edge-to-edge. The accent bar
                -- is anchored to the highlight's LEFT so they move
                -- together. Both BACKGROUND layer -- text and dividers
                -- render on top, so the highlight reads as a tinted band
                -- behind the row's content.
                if currentBossName and row.bossName == currentBossName then
                    slot.highlight:ClearAllPoints()
                    slot.highlight:SetPoint("TOPLEFT",     f, "TOPLEFT",  14, y + 1)
                    slot.highlight:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                    slot.highlight:Show()

                    slot.accent:ClearAllPoints()
                    slot.accent:SetPoint("TOPLEFT",    f, "TOPLEFT", 14, y + 1)
                    slot.accent:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                    slot.accent:Show()
                end

                -- Status cell: [ ✓ ] or [ X ]
                local statusText
                if row.completed then
                    statusText = ("|cff777777[ |r|cff00ff00%s|r|cff777777 ]|r"):format(ACH_CELL_DONE)
                else
                    statusText = ("|cff777777[ |r%s|cff777777 ]|r"):format(ACH_CELL_TODO)
                end
                SetBodyFont(slot.status, rowFontSize, "")
                slot.status:SetText(statusText)
                slot.status:ClearAllPoints()
                slot.status:SetPoint("TOP", f, "TOPLEFT", ACH_COL_STATUS_X, y)
                slot.status:Show()

                -- Achievement cell: meta-prefix + link + soloable star.
                -- Both meta and non-meta rows include a 14x14 prefix
                -- texture; non-meta uses a fully transparent variant
                -- (same path with vertex-color RGBA=0,0,0,0). This keeps
                -- the achievement-name text aligned to the same column
                -- position regardless of meta status -- without the
                -- transparent placeholder, non-meta names start ~16px
                -- left of meta names.
                local metaPrefix = row.meta and ACH_META_PREFIX or ACH_NON_META_PREFIX
                local link = GetAchievementLink and GetAchievementLink(row.achievementID)
                              or row.achievementName
                if row.completed and link ~= row.achievementName then
                    -- Gray for completed achievements (de-emphasized).
                    link = link:gsub("^|cff%x%x%x%x%x%x", ""):gsub("|r$", "")
                    link = ("|cff888888%s|r"):format(link)
                end
                local soloStar = GetSoloableStar(row.soloable)
                SetBodyFont(slot.ach, rowFontSize, "")
                slot.ach:SetText(metaPrefix .. link .. soloStar)
                slot.ach:SetWidth(colNameW)
                slot.ach:ClearAllPoints()
                slot.ach:SetPoint("TOPLEFT", f, "TOPLEFT", ACH_COL_NAME_X, y)
                slot.ach:Show()

                -- Boss cell.
                SetBodyFont(slot.boss, rowFontSize, "")
                slot.boss:SetText(("|cffcccccc%s|r"):format(row.bossName))
                slot.boss:SetWidth(colBossW)
                slot.boss:ClearAllPoints()
                slot.boss:SetPoint("TOPLEFT", f, "TOPLEFT", colBossX, y)
                slot.boss:Show()

                -- Wowhead button. Click handler captures achievement ID
                -- and display names in a closure so the popup can show
                -- which row it's for. Slot is reused across raid switches
                -- with different IDs/names; the closure rebinds each row.
                local achID    = row.achievementID
                local achName  = row.achievementName
                local bossName = row.bossName
                slot.wowhead:SetScript("OnClick", function()
                    UI.ShowWowheadPopup(achID, bossName, achName)
                end)
                slot.wowhead:ClearAllPoints()
                -- Vertically center the 14px-tall button in the row's
                -- ~15px visible band. The math says anchoring TOPRIGHT
                -- at y should put button top at row top with 1px gap
                -- to the divider below -- but UIPanelButtonTemplate's
                -- chrome (the textured edges) doesn't fill its SetSize
                -- bounds uniformly: the visible button graphics sit
                -- biased toward the bottom of the SetSize box, so a
                -- y-anchored button reads as bottom-heavy with empty
                -- space above. Empirical adjustment (tuned by eye over
                -- several iterations): y+2 lands closest to the visual
                -- center of the row band. y+3 read slightly too high,
                -- y+0 too low.
                slot.wowhead:SetPoint("TOPRIGHT", f, "TOPRIGHT", -ACH_WOWHEAD_RIGHT_INSET, y + 2)
                slot.wowhead:Show()

                -- Subtle row divider. Anchored using ACH_ROW_BOTTOM_INSET
                -- so it sits tight against the text from below rather
                -- than at the bottom of the full lineHeight band. The
                -- comment value (5px above nominal row bottom) is set
                -- once at the constant; tune there.
                slot.divider:ClearAllPoints()
                slot.divider:SetPoint("TOPLEFT",  f, "TOPLEFT",  14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                slot.divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                slot.divider:Show()

                y = y - lineHeight

            elseif row.kind == "naRow" then
                local slot = GetAchRowSlot(f, i)

                -- Current-boss highlight (see achRow comment for layer
                -- and inset rationale). naRow gets the same treatment so
                -- a current boss with no achievements is still visually
                -- marked as "where you are".
                if currentBossName and row.bossName == currentBossName then
                    slot.highlight:ClearAllPoints()
                    slot.highlight:SetPoint("TOPLEFT",     f, "TOPLEFT",  14, y + 1)
                    slot.highlight:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                    slot.highlight:Show()

                    slot.accent:ClearAllPoints()
                    slot.accent:SetPoint("TOPLEFT",    f, "TOPLEFT", 14, y + 1)
                    slot.accent:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                    slot.accent:Show()
                end

                -- N/A in the status column, "N/A" in the achievement
                -- column, boss name in the boss column, no Wowhead btn.
                SetBodyFont(slot.status, rowFontSize, "")
                slot.status:SetText(ACH_CELL_NA)
                slot.status:ClearAllPoints()
                slot.status:SetPoint("TOP", f, "TOPLEFT", ACH_COL_STATUS_X, y)
                slot.status:Show()

                SetBodyFont(slot.ach, rowFontSize, "")
                slot.ach:SetText(ACH_CELL_NA)
                slot.ach:SetWidth(colNameW)
                slot.ach:ClearAllPoints()
                slot.ach:SetPoint("TOPLEFT", f, "TOPLEFT", ACH_COL_NAME_X, y)
                slot.ach:Show()

                SetBodyFont(slot.boss, rowFontSize, "")
                slot.boss:SetText(("|cffcccccc%s|r"):format(row.bossName))
                slot.boss:SetWidth(colBossW)
                slot.boss:ClearAllPoints()
                slot.boss:SetPoint("TOPLEFT", f, "TOPLEFT", colBossX, y)
                slot.boss:Show()

                -- Wowhead button slot stays hidden for naRow (no
                -- achievement ID to link to).

                -- Same row divider as achRow so visual rhythm is uniform.
                slot.divider:ClearAllPoints()
                slot.divider:SetPoint("TOPLEFT",  f, "TOPLEFT",  14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                slot.divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                slot.divider:Show()

                y = y - lineHeight
            end
        end

        -- Legend below the table. Two FontStrings on the same baseline:
        -- left FontString anchored TOPLEFT, right FontString anchored
        -- TOPRIGHT. Both at y - 6 (small gap below the last row's
        -- divider).
        SetBodyFont(f.legendLeft, fontSize - 1, "")
        f.legendLeft:ClearAllPoints()
        f.legendLeft:SetPoint("TOPLEFT", f, "TOPLEFT", 14, y - 6)

        SetBodyFont(f.legendRight, fontSize - 1, "")
        f.legendRight:ClearAllPoints()
        f.legendRight:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, y - 6)

        -- Total height: |y| + legend height + bottom margin. Use the
        -- taller of the two legend FontStrings (they're typically the
        -- same height, but be defensive in case of font wrapping).
        local lastY = math.abs(y)
        local legendH = math.max(
            f.legendLeft:GetStringHeight()  or fontSize,
            f.legendRight:GetStringHeight() or fontSize
        )
        local desired = lastY + legendH + 16
        local clamped = math.max(ACH_WINDOW_MIN_HEIGHT,
                                 math.min(ACH_WINDOW_MAX_HEIGHT, desired))
        f:SetHeight(clamped)
    end

    f.RefreshAll = function(self)
        self:RefreshDropdowns()
        self:RefreshContent()
    end

    -------------------------------------------------------------------------
    -- Live refresh on achievement events
    -------------------------------------------------------------------------
    --
    -- ACHIEVEMENT_EARNED:        fires once per achievement when earned.
    --                            Args: (achievementID).
    -- CRITERIA_UPDATE:           fires when ANY criterion ticks for ANY
    --                            achievement. Very chatty -- every quest
    --                            progress, every kill, every collection
    --                            increment. We want it for the Glory
    --                            header completion count which ticks
    --                            per-criterion before the meta itself
    --                            is earned.
    -- RECEIVED_ACHIEVEMENT_LIST: fires after the achievement system has
    --                            finished initial population on login or
    --                            reload. Without this, a window opened
    --                            before the system is ready would show
    --                            stale-or-missing completion state.
    --
    -- All three feed the same debounced refresh: a single frame of
    -- delay (50ms) collapses event bursts into one render, which matters
    -- because CRITERIA_UPDATE bursts of 5-10 events are common (e.g.
    -- when a quest turn-in advances multiple criteria simultaneously).
    -- Refresh is gated on the window being shown -- events that fire
    -- when the window is hidden are no-ops, so the next time the user
    -- opens it the regular RefreshAll path will pick up current state.
    f:RegisterEvent("ACHIEVEMENT_EARNED")
    f:RegisterEvent("CRITERIA_UPDATE")
    f:RegisterEvent("RECEIVED_ACHIEVEMENT_LIST")

    local refreshPending = false
    f:SetScript("OnEvent", function(self)
        if not self:IsShown() then return end
        if refreshPending then return end
        refreshPending = true
        C_Timer.After(0.05, function()
            refreshPending = false
            if self:IsShown() and self.RefreshContent then
                self:RefreshContent()
            end
        end)
    end)

    return f
end

-- Public refresh hook for route-progress changes. Called from UI.Update
-- when a boss is killed or the route advances. Keeps the current-boss
-- highlight pinned to the actual current step rather than the step that
-- was active when the user last opened the window. Cheap to call on
-- every UI.Update tick; the gating on IsShown() short-circuits if the
-- user hasn't opened the achievements window.
function UI.UpdateAchievementsWindow()
    if achievementsWindow and achievementsWindow:IsShown()
       and achievementsWindow.RefreshContent then
        achievementsWindow:RefreshContent()
    end
end

-- Public entry points. Match the skipsWindow open/toggle shape rather than
-- tmogWindow's hover-grace pattern -- the achievements window doesn't have
-- the in-raid auto-popup behavior the tmog window has, so it doesn't need
-- the cancel/schedule timer machinery.
function UI.OpenAchievementsWindow()
    -- Mutex with other auxiliary windows. See UI.OpenSkipsWindow for
    -- rationale.
    if tmogWindow and tmogWindow:IsShown() then tmogWindow:Hide() end
    if skipsWindow and skipsWindow:IsShown() then skipsWindow:Hide() end

    local w = GetOrCreateAchievementsWindow()
    -- Apply current settings (scale + font) before refreshing so the first
    -- visible state already matches the user's settings rather than
    -- rendering at default and then snapping to settings.
    local scale = RR:GetSetting("windowScale", 1.0)
    w:SetScale(scale)
    w:RefreshAll()
    w:Show()
end

function UI.ToggleAchievementsWindow()
    if achievementsWindow and achievementsWindow:IsShown() then
        achievementsWindow:Hide()
    else
        UI.OpenAchievementsWindow()
    end
end
end -- achievements do block

-- "[!] view special note" subtle pulse driver. Advances
-- encounterPulsePhase through 0..15 every 0.1s (1.6s round trip), and
-- calls UI.Update so BuildEncounterText re-renders the [!] glyph at
-- the new brightness. Pulse is purely cosmetic; it only re-runs the
-- existing UI.Update path. Gated to "panel is allowed and raid is
-- loaded" to avoid wasted work on the login screen / non-raid maps,
-- and to "encounter section is collapsed" since the [!] is only
-- visible in that state.
--
-- Why a separate ticker rather than piggy-backing on the 1Hz Core
-- heartbeat: heartbeat fires every 1s, way too slow for smooth
-- breathing. 0.1s gives 16 phases over the 1.6s cycle, fine enough
-- to read as gradual rather than stepping.
C_Timer.NewTicker(0.1, function()
    -- Cheap exit if there's nothing to display the pulse on.
    if not RR:IsPanelAllowed() then return end
    if not RR.currentRaid then return end
    if RR.state.loadedRaidKey ~= RR:GetRaidContextKey() then return end
    if RR:GetSetting("encounterExpanded") then return end

    encounterPulsePhase = (encounterPulsePhase + 1) % ENCOUNTER_PULSE_STEPS
    UI.Update()
end)

-- Second pulse driver: the "What's New?" footer [!] indicator.
-- Independent gating from the encounter-card pulse (runs whenever the
-- panel is allowed and the [!] hasn't been dismissed for the current
-- version), but reuses the same encounterPulsePhase and color table
-- so both pulses breathe in sync. The label is rewritten in place
-- per tick -- no UI.Update call needed, just a SetText on the FontString.
--
-- Dismissed state is keyed off RetroRunsDB.whatsNewSeenVersion: the [!]
-- shows whenever the stored value != current VERSION (i.e., the player
-- hasn't clicked the link since this version shipped). First-ever click
-- writes the current VERSION into the saved-var, suppressing the [!]
-- until the next version bump.
C_Timer.NewTicker(0.1, function()
    if not RR:IsPanelAllowed() then return end
    if not panel.whatsNewLabel then return end
    local dismissed = RetroRunsDB
        and RetroRunsDB.whatsNewSeenVersion == RetroRuns.VERSION
    if dismissed then
        -- Static muted label, no pulse. SetText is cheap; skipping the
        -- re-set entirely would also be fine but the cost is trivial.
        panel.whatsNewLabel:SetText("|cff9d9d9dWhat's New?|r")
        return
    end
    local pulseColor = ENCOUNTER_PULSE_COLORS[encounterPulsePhase] or "|cffffff00"
    panel.whatsNewLabel:SetText(
        "|cff9d9d9dWhat's New?|r " .. pulseColor .. "[!]|r")
end)
