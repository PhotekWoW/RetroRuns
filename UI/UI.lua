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
-- Custom border frame thickness. Content is inset by these amounts on each edge
-- so it sits inside the frame's opening rather than under the ornate border art.
-- Horizontal inset is the rail thickness; vertical is a touch more to clear the
-- taller corner caps at the top/bottom.
local FRAME_INSET_X = 10
local FRAME_INSET_Y = 16
local PAD_LEFT   = 16 + FRAME_INSET_X
local PAD_RIGHT  = 12 + FRAME_INSET_X
local BODY_WIDTH = PANEL_W - PAD_LEFT - PAD_RIGHT - 10

local TITLE_FONT = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\04B_03.TTF"
-- VT323: monospaced terminal-style body font.
local VT323_FONT = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\VT323.ttf"
local BODY_FONT  = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local TITLE_SIZE = 20

-- Body font metadata. sizeFactor scales each font to match FRIZQT's
-- visual density at the same nominal size.
local BODY_FONT_INFO = {
    standard = { path = BODY_FONT,  sizeFactor = 1.00 },
    retro    = { path = TITLE_FONT, sizeFactor = 1.00 },
    vt323    = { path = VT323_FONT, sizeFactor = 1.30 },
}

local C_PINK   = { 0.95, 0.35, 0.78 }
local C_BLUE   = { 0.30, 0.80, 1.00 }
local C_PINK_HEX = "f259c7"  -- C_PINK as a text-escape hex (RETRO pink)
local C_LABEL  = "7CFC00"   -- section label colour (green)

-- Idle-list pill-row leading spacers: transparent fixed-width inline textures
-- that reserve exact pixel widths at the head of a pill string. The pill text,
-- the plane anchor, and the chevron measurement all read these.
--   PILL_SUBLINE_INDENT  16px: indents the pill row so it reads as a sub-line
--                        under the raid name.
--   PILL_PLANE_GUTTER    18px: the column the nav plane sits in, at the head of
--                        the row after the sub-line indent.
RR.PILL_SUBLINE_INDENT = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:16:0:0:64:64:0:64:0:64:0:0:0:0|t"
RR.PILL_PLANE_GUTTER   = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:18:0:0:64:64:0:64:0:64:0:0:0:0|t"

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

-- Returns the body-text font path. Chrome (titles, action buttons)
-- uses 04B_03 directly via TITLE_FONT.
local function GetBodyFont()
    return GetBodyFontInfo().path
end

-- Returns the render size for a given baseSize after applying the
-- active body font's sizeFactor.
local function GetBodyFontSize(baseSize)
    return math.max(8, math.floor(baseSize * GetBodyFontInfo().sizeFactor + 0.5))
end

-- Apply body font + computed size + black shadow to a FontString.
-- The shadow keeps pixel fonts crisp at non-native scales.
local function SetBodyFont(fs, baseSize, flags)
    if not fs then return end
    SafeSetFont(fs, GetBodyFont(), GetBodyFontSize(baseSize), flags or "")
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 1)
end

-- Exposed on RR so modules outside UI.lua (e.g. the Toaster) can resolve
-- the user's body font the same way the panel does.
function RR:GetBodyFont()
    return GetBodyFont()
end
function RR:GetBodyFontSize(baseSize)
    return GetBodyFontSize(baseSize)
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
    -- Normalize the anchor back to CENTER/CENTER so saved offsets
    -- restore correctly on reload.
    local cx, cy   = self:GetCenter()
    local pcx, pcy = UIParent:GetCenter()
    local fscale   = self:GetEffectiveScale()
    local pscale   = UIParent:GetEffectiveScale()
    -- SetPoint offsets are in the anchored frame's scaled coords --
    -- divide by fscale, not pscale.
    local x = (cx * fscale - pcx * pscale) / fscale
    local y = (cy * fscale - pcy * pscale) / fscale
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "CENTER", x, y)
    RR:SetSetting("panelX", math.floor(x + 0.5))
    RR:SetSetting("panelY", math.floor(y + 0.5))
end)

-- Forward declarations for auxiliary windows (assigned further down).
local tmogWindow
local browserState
local skipsWindow
local achievementsWindow
local achState
local RefreshIdleList
local PositionLegendDivider

-- Custom frame border via the engine's edgeFile nine-slice -- the standard,
-- reliable mechanism (SetTextureSliceMargins silently no-ops on this client, so
-- a single stretched texture distorted on resize). An edgeFile is a filmstrip
-- of 8 equal slices (left/right/top/bottom edges + 4 corners) that the engine
-- repeats the edges between fixed corners automatically, at any frame size.
-- bgFile fills the interior (dark). edgeSize sets the on-screen corner/border
-- thickness. This is how Blizzard's own dialog frames and most addons do it.
--
-- The minimized bar reuses the same edge art at a smaller edgeSize so the
-- ornate corners stay on-theme without overwhelming the much shorter bar.
local PANEL_EDGE_SIZE_FULL      = 26
local PANEL_EDGE_SIZE_MINIMIZED = 14

local function PanelBackdrop(edgeSize)
    return {
        bgFile   = "Interface\\AddOns\\RetroRuns\\Media\\panel-bg",
        edgeFile = "Interface\\AddOns\\RetroRuns\\Media\\panel-edge",
        tile = true, tileSize = 64,
        edgeSize = edgeSize,
        insets = { left = 7, right = 7, top = 7, bottom = 7 },
    }
end

panel:SetBackdrop(PanelBackdrop(PANEL_EDGE_SIZE_FULL))
panel:SetBackdropColor(1, 1, 1, RR:GetSetting("panelOpacity", 1.0))
panel:SetBackdropBorderColor(1, 1, 1, 1)

-- The edgeFile backdrop nine-slices at any frame size, but a single fixed
-- edgeSize that looks right on the tall expanded panel reads as oversized
-- ornate corners on the short minimized bar. Re-apply the backdrop at the
-- smaller edgeSize while minimized and the full size when expanded. There is
-- no edgeSize-only setter on this client, so the whole backdrop is re-set;
-- that clears the border/background color, which is restored right after.
local function ApplyBorderArtForState(minimized)
    local edgeSize = minimized and PANEL_EDGE_SIZE_MINIMIZED
                                or PANEL_EDGE_SIZE_FULL
    panel:SetBackdrop(PanelBackdrop(edgeSize))
    panel:SetBackdropColor(1, 1, 1, RR:GetSetting("panelOpacity", 1.0))
    panel:SetBackdropBorderColor(1, 1, 1, 1)
end

-- Enable hyperlink clicks on the panel so achievement links in the
-- encounter FontString become clickable. SetItemRef is Blizzard's global
-- dispatcher that routes |Hachievement:...|h, |Hitem:...|h, etc. to the
-- appropriate pane (achievement, item, spell). The handler intentionally
-- does nothing for links it doesn't recognize -- SetItemRef is a no-op
-- for unknown prefixes.
--
-- We also intercept a custom "retroruns:zygor_arrow" link from the
-- entrance-legend's "Zygor Waypoint Arrow Disabled!" warning. Clicking
-- the warning enables Zygor's arrow setting and re-renders our legend
-- so the warning disappears. Zygor itself picks up the new setting on
-- its next SetWaypoint call (which happens when the user clicks any
-- entrance button), so the typical user flow -- click warning, click
-- entrance -- works end-to-end without /reload.
panel:SetHyperlinksEnabled(true)
panel:SetScript("OnHyperlinkClick", function(_, link, text, button)
    if link == "retroruns:zygor_arrow" then
        local zgv = _G.ZygorGuidesViewer
        if zgv and zgv.db and zgv.db.profile then
            zgv.db.profile.arrowshow = true
            -- The fingerprint cache short-circuits RefreshIdleList when
            -- row data hasn't changed. The Zygor arrow state is read
            -- only by the legend builder, not BuildIdleListRows, so a
            -- raw RefreshIdleList call would no-op here. Invalidate
            -- explicitly so the legend actually re-renders.
            UI.InvalidateIdleListCache()
            if RefreshIdleList then RefreshIdleList() end
        end
        return
    end
    SetItemRef(link, text, button)
end)

-- Logo
panel.logo = panel:CreateTexture(nil, "ARTWORK")
-- Logo sized to sit as a peer to the 12pt title text rather than dominating
-- the title row alongside the minimize and close buttons.
-- Logo retained as an object but hidden -- the title bar shows just the
-- "RETRO RUNS" wordmark now (logo removed from the title row by request).
panel.logo:SetSize(24, 24)
panel.logo:SetPoint("TOPLEFT", PAD_LEFT - 4, -10 - FRAME_INSET_Y)
panel.logo:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\LogoSquare")
panel.logo:Hide()

-- Title (two FontStrings, split only at colour boundary). Anchored to the
-- panel's top-left now that the logo is hidden.
panel.titleRetro = panel:CreateFontString(nil, "OVERLAY")
panel.titleRetro:SetPoint("TOPLEFT", PAD_LEFT + 8, -12 - FRAME_INSET_Y)
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

-- Minimized-bar next-step note. Sits to the right of the wordmark and shows
-- the active segment's short instruction while minimized. White so it reads
-- as content distinct from the pink/blue brand letters. Hidden by default;
-- ApplyTitleLayoutForState shows it (and collapses the wordmark to "RR") only
-- when minimized with an active route note to display. A small left pad
-- separates it from the brand letters.
panel.titleMinNote = panel:CreateFontString(nil, "OVERLAY")
panel.titleMinNote:SetPoint("LEFT", panel.titleRuns, "RIGHT", 6, 0)
panel.titleMinNote:SetFont(BODY_FONT, 12, "OUTLINE")
panel.titleMinNote:SetText("")
panel.titleMinNote:SetTextColor(1, 1, 1)
panel.titleMinNote:SetShadowOffset(1, -1)
panel.titleMinNote:SetShadowColor(0, 0, 0, 1)
panel.titleMinNote:Hide()

-- Close button
-- Close button. Custom 20x20 frame (not Blizzard's UIPanelCloseButton,
-- whose 32x32 frame and fixed red-X can't be themed) using the retro
-- neon CloseIcon texture. Hover brightens via vertex color.
panel.closeButton = CreateFrame("Button", nil, panel)
panel.closeButton:SetSize(24, 24)
panel.closeButton:SetPoint("TOPRIGHT", -10 - FRAME_INSET_X, -4 - FRAME_INSET_Y)
do
    local tex = panel.closeButton:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\CloseIcon")
    tex:SetAllPoints(panel.closeButton)
    panel.closeButton._tex = tex
    panel.closeButton:SetScript("OnEnter", function(self) self._tex:SetVertexColor(1.4, 1.4, 1.4) end)
    panel.closeButton:SetScript("OnLeave", function(self) self._tex:SetVertexColor(1, 1, 1) end)
end
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

-- Minimize / maximize button, sits left of the close X. 22x22 to
-- visually match the close X's painted glyph (not its 32x32 frame).
panel.minimizeButton = CreateFrame("Button", nil, panel)
panel.minimizeButton:SetSize(24, 24)
panel.minimizeButton:SetPoint("TOPRIGHT", -36 - FRAME_INSET_X, -4 - FRAME_INSET_Y)
do
    local tex = panel.minimizeButton:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\MinimizeIcon")
    tex:SetAllPoints(panel.minimizeButton)
    panel.minimizeButton._tex = tex
    panel.minimizeButton:SetScript("OnEnter", function(self) self._tex:SetVertexColor(1.4, 1.4, 1.4) end)
    panel.minimizeButton:SetScript("OnLeave", function(self) self._tex:SetVertexColor(1, 1, 1) end)
end
-- (OnClick handler wired further below, after UI.SetMinimized exists.)

-- Test-mode label, positioned to clear both the close X and the
-- minimize button.
panel.mode = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.mode:SetPoint("TOPRIGHT", -56 - FRAME_INSET_X, -14 - FRAME_INSET_Y)
panel.mode:SetText("")
panel.mode:SetFont(TITLE_FONT, 9, "OUTLINE")
panel.mode:SetShadowOffset(1, -1)
panel.mode:SetShadowColor(0, 0, 0, 1)

-- Action buttons (Map / Tmog / Skips / Settings) live in a single
-- row at the bottom; defined further down in the Footer block.

-- -- Body fields --------------------------------------------------------------

local function AddField(anchor, anchorPoint, relPoint, offsetY, width, template)
    local fs = panel:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    fs:SetPoint(anchorPoint, anchor, relPoint, 0, offsetY)
    fs:SetWidth(width or BODY_WIDTH)
    fs:SetJustifyH("LEFT")
    return fs
end

panel.raid = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
panel.raid:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD_LEFT, -30 - FRAME_INSET_Y)
panel.raid:SetWidth(PANEL_W - PAD_LEFT - 80)
panel.raid:SetJustifyH("LEFT")

-- LFR wing subline, shown only in a wing (populated in UI.Update). Its own
-- FontString so it can run 4pt smaller than the raid name; an empty string
-- collapses to zero height, so when not in a wing the pills row (anchored
-- below it) sits directly under the raid name as before. Sized at raid-font
-- minus 4 in UI.Update, where the live raid font size is readable.
panel.wingLine = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
panel.wingLine:SetPoint("TOPLEFT", panel.raid, "BOTTOMLEFT", 0, -2)
panel.wingLine:SetWidth(PANEL_W - PAD_LEFT - 80)
panel.wingLine:SetJustifyH("LEFT")
panel.wingLine:SetText("")

-- Per-difficulty kill-count pills row. Active difficulty in white,
-- others in gray. Format: "[ LFR x/y | N x/y | H x/y | M x/y ]".
panel.pills = AddField(panel.wingLine, "TOPLEFT", "BOTTOMLEFT", -2, BODY_WIDTH, "GameFontNormalSmall")

-- Invisible hover region over the pills row. FontStrings can't take
-- mouse scripts, so a sibling frame sits on top to surface the
-- shared-lockout tooltip. It only arms its tooltip when the current
-- raid is actually on a single-lockout model (set in UI.Update); when
-- disarmed it still exists but shows nothing on hover.
panel.pillsHover = CreateFrame("Frame", nil, panel)
panel.pillsHover:SetPoint("TOPLEFT", panel.pills, "TOPLEFT", 0, 0)
panel.pillsHover:SetPoint("BOTTOM", panel.pills, "BOTTOM", 0, 0)
panel.pillsHover:SetWidth(1)
panel.pillsHover:EnableMouse(true)
panel.pillsHover._lockoutTip = false
panel.pillsHover:SetScript("OnEnter", function(self)
    if not self._lockoutTip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("This raid only supports a single lockout per character", 1, 1, 1, true)
    if GameTooltipTextSmall then
        GameTooltipTextLeft1:SetFontObject(GameTooltipTextSmall)
    end
    GameTooltip:Show()
end)
panel.pillsHover:SetScript("OnLeave", function()
    GameTooltip:Hide()
    if GameTooltipText then
        GameTooltipTextLeft1:SetFontObject(GameTooltipText)
    end
end)

panel.progress  = AddField(panel.pills, "TOPLEFT", "BOTTOMLEFT", -6,  BODY_WIDTH, "GameFontNormal")
panel.next      = AddField(panel.progress, "TOPLEFT", "BOTTOMLEFT", -8,  BODY_WIDTH, "GameFontNormal")
-- Run-complete exit shortcut. Sits below panel.next with a slightly
-- larger gap than the usual -8/-12 so there's a little breathing room
-- under the "Run complete!" banner. Smaller font than the banner (see
-- targets table). Only populated when the loaded raid authors an exitNote.
panel.exitNote  = AddField(panel.next,     "TOPLEFT", "BOTTOMLEFT", -13, BODY_WIDTH, "GameFontNormalSmall")
panel.travel    = AddField(panel.next,     "TOPLEFT", "BOTTOMLEFT", -12, BODY_WIDTH)

-- Boss Encounter section. A wrapper Frame holding three stacked
-- sub-widgets:
--   .header        Button -- click toggles the soloTip expand/collapse
--   .achievements  Frame with hyperlinks enabled (achievement links)
--   .specialLoot   Frame with hyperlinks enabled (loot links)
-- Splitting the click-toggle target (header) from the hyperlink
-- targets prevents click competition over imprecise hyperlink hit-tests.
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

-- Forward declarations (defined later).
local GetOrCreateTmogWindow
local BuildTransmogDetail
local BuildSpecialLootSection

-- Transmog browser selection state. Filled in by EnsureBrowserDefaults.
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
    -- Custom diagonal jet silhouette (Media/PlaneIcon), authored white so
    -- it can be vertex-tinted. Tinted to RETRO pink; reads as "travel /
    -- go here" and clicking opens the nav chooser. The white-source +
    -- SetVertexColor pattern matches BugIcon/ChatIcon/RingCircle.
    --
    -- Routing-vs-waypoint tier signal is conveyed via the button's
    -- alpha (1.0 routing, 0.4 waypoint) -- set at the click-handler
    -- setup site in RefreshIdleList.
    btn:SetNormalTexture("Interface\\AddOns\\RetroRuns\\Media\\PlaneIcon")
    local nt = btn:GetNormalTexture()
    if nt then nt:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 1) end
    -- Highlight: same texture in ADD blend for a brighten-on-hover feel.
    btn:SetHighlightTexture(
        "Interface\\AddOns\\RetroRuns\\Media\\PlaneIcon", "ADD")
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
    -- Taxi icon at 1.4x the toggle-button size. Anchored at a fixed left inset
    -- on the pill-row FontString so every plane lands in one vertical column.
    local size = math.floor(fontSize * 1.4)
    btn:SetSize(size, size)
    btn:ClearAllPoints()
    -- +17 = the 16px sub-line indent + 1px into the plane gutter.
    btn:SetPoint("LEFT", parentFS, "LEFT", 17, 0)
end

-- Frameless toast: a single FontString fade-in/hold/fade-out near
-- the clicked button. Used to confirm silent waypoint paths
-- (Blizzard/TomTom) where nothing else in the panel acknowledges
-- the click. Drives alpha manually via C_Timer.NewTicker.
local function ShowWaypointToast(anchorFrame, text)
    if not anchorFrame or not text then return end

    local toast = CreateFrame("Frame", nil, UIParent)
    toast:SetFrameStrata("TOOLTIP")  -- above the addon panel
    toast:SetSize(180, 18)
    toast:ClearAllPoints()
    toast:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)

    local fs = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("LEFT", toast, "LEFT", 0, 0)
    fs:SetText("|cffffd700" .. text .. "|r")  -- gold for friendly notice
    fs:SetJustifyH("LEFT")

    toast:SetAlpha(0)  -- start invisible
    toast:Show()

    -- Manual alpha schedule: 0.10s fade-in, 1.50s hold, 0.60s fade-out.
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

-- ShowNavChooser is wrapped in a do/end block and scoped to the panel
-- table. The navChooser singleton lives as an upvalue inside the block;
-- the function is reachable as panel.ShowNavChooser.
do
    local navChooser  -- the singleton frame, lazily created
    function panel.ShowNavChooser(anchorFrame, raid)
        if not anchorFrame or not raid then return end

        -- Lazy construction of the singleton frame + its two option buttons.
        if not navChooser then
            local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            f:SetFrameStrata("DIALOG")
            f:EnableMouse(true)  -- swallow clicks on the chooser body
            -- Thin tooltip-style border (not the heavy ornamented panel
            -- edge, which overwhelms a small popup). Tinted to a flat
            -- pink/blue midpoint so the border reads as a blend of the two
            -- option colors. Backdrop border takes ONE color (no gradient),
            -- so the midpoint blend is the "gradient" within engine limits.
            f:SetBackdrop({
                bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 12,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            f:SetBackdropColor(0.02, 0.03, 0.05, 0.96)
            local BR = (C_PINK[1] + C_BLUE[1]) / 2
            local BG = (C_PINK[2] + C_BLUE[2]) / 2
            local BB = (C_PINK[3] + C_BLUE[3]) / 2
            f:SetBackdropBorderColor(BR, BG, BB, 1)
            f:Hide()

            -- "Navigate to:" header row inside the frame (not floating above
            -- it), so the popup is self-contained and clears the list text in
            -- any open direction.
            local title = f:CreateFontString(nil, "OVERLAY")
            SetBodyFont(title, math.max(9, RR:GetSetting("fontSize", 12) - 2), "")
            title:SetText("Navigate to:")
            title:SetTextColor(0.54, 0.58, 0.64, 1)  -- muted gray
            title:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -4)
            f.title = title
            local titleH = (title:GetStringHeight() or 10) + 4  -- header band height

            local PAD_X, PAD_Y = 14, 7

            -- Build one horizontal option cell with a colored label. The
            -- cell auto-sizes to its label plus horizontal padding; onClick
            -- is wired per-show (closes over the current raid).
            local function makeOption(labelText, color)
                local b = CreateFrame("Button", nil, f)
                b:RegisterForClicks("LeftButtonUp")
                local fs = b:CreateFontString(nil, "OVERLAY")
                SetBodyFont(fs, RR:GetSetting("fontSize", 12), "")
                fs:SetText(labelText)
                fs:SetTextColor(color[1], color[2], color[3], 1)
                fs:SetPoint("CENTER", b, "CENTER", 0, 0)
                b.label = fs
                -- Cell width = label width + side padding; height = label
                -- height + vertical padding. Measured after SetText.
                local w = (fs:GetStringWidth() or 20) + PAD_X * 2
                local h = (fs:GetStringHeight() or 12) + PAD_Y * 2
                b:SetSize(w, h)
                -- Hover highlight tinted to the option color.
                local hl = b:CreateTexture(nil, "HIGHLIGHT")
                hl:SetAllPoints(b)
                hl:SetColorTexture(color[1], color[2], color[3], 0.18)
                return b
            end

            -- Horizontal layout: [ LFR | STD ], LFR left (matches the pill
            -- order where LFR is leftmost).
            f.lfrButton = makeOption("LFR", C_PINK)
            f.stdButton = makeOption("STD", C_BLUE)

            -- 1px vertical divider between the two cells.
            local divider = f:CreateTexture(nil, "OVERLAY")
            divider:SetColorTexture(BR, BG, BB, 0.8)
            f.divider = divider

            -- Anchor cells side by side, BELOW the title header band.
            f.lfrButton:SetPoint("TOPLEFT", f, "TOPLEFT", 3, -(3 + titleH))
            divider:SetPoint("TOPLEFT", f.lfrButton, "TOPRIGHT", 0, 0)
            divider:SetWidth(1)
            divider:SetPoint("BOTTOMLEFT", f.lfrButton, "BOTTOMRIGHT", 0, 0)
            f.stdButton:SetPoint("TOPLEFT", divider, "TOPRIGHT", 0, 0)

            -- Frame sizes to the title band + the two cells + the 1px divider
            -- + 3px inset on each side. Heights match (same font), so use
            -- lfr's height.
            local cellH = select(2, f.lfrButton:GetSize())
            local totalW = select(1, f.lfrButton:GetSize())
                         + 1
                         + select(1, f.stdButton:GetSize())
                         + 6  -- 3px inset each side
            f:SetSize(totalW, cellH + 6 + titleH)

            -- Global mouse-catcher: a full-screen transparent button BEHIND
            -- the chooser that closes it when the player clicks elsewhere.
            local catcher = CreateFrame("Button", nil, UIParent)
            catcher:SetFrameStrata("DIALOG")
            catcher:SetFrameLevel(math.max(0, (f:GetFrameLevel() or 1) - 1))
            catcher:SetAllPoints(UIParent)
            catcher:RegisterForClicks("AnyUp")
            catcher:Hide()
            catcher:SetScript("OnClick", function()
                f:Hide()
            end)
            f.catcher = catcher
            f:SetScript("OnHide", function() catcher:Hide() end)

            navChooser = f
        end

        local f = navChooser

        -- Per-show wiring: each option closes over THIS raid. The nav calls
        -- mirror the prior inline behavior (toast on no-planner branch).
        f.stdButton:SetScript("OnClick", function(self)
            f:Hide()
            local result = RR:NavigateToEntrance(raid)
            if result and not result.planner then
                ShowWaypointToast(self, "Waypoint set")
            end
        end)
        f.lfrButton:SetScript("OnClick", function(self)
            f:Hide()
            local result = RR:NavigateToLFRNPC(raid.expansion)
            if result and not result.planner then
                ShowWaypointToast(self, "Waypoint set")
            end
        end)

        -- Open the chooser vertically off the clicked plane: upward by
        -- default, downward for raids near the top of the panel.
        f:ClearAllPoints()
        local anchorTop = anchorFrame:GetTop()
        local panelTop  = panel:GetTop()
        -- Flip downward within ~80px of the panel top (the reference is the
        -- panel, not the screen, since the panel is draggable).
        local openDown = anchorTop and panelTop
            and (panelTop - anchorTop) < 80
        if openDown then
            f:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", -2, -4)
        else
            f:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", -2, 4)
        end
        f.catcher:Show()
        f:Show()
        f:Raise()
        -- Level the catcher exactly one below the chooser AFTER the raise,
        -- so the catcher always sits behind the chooser body (and the
        -- chooser's option buttons receive their clicks first). Setting
        -- this at construction is insufficient because Raise() changes the
        -- chooser's level at show time without moving the catcher.
        f.catcher:SetFrameLevel(math.max(0, (f:GetFrameLevel() or 1) - 1))
    end
end


-- ---------------------------------------------------------------------------
-- Per-line FontString pool for the idle/run-complete supported-raids list.
-- Each rendered line is its own widget so toggle Buttons can anchor to
-- the line's FontString and stay aligned. Legend rows (skip + entrance
-- keys) live in a parallel array so AutoSize excludes them from the
-- list-height budget (the legend space is reserved in the footer).
-- ---------------------------------------------------------------------------
panel.idleListLines        = {}
panel.idleListLegendLines  = {}
panel.idleListLinePool     = {}

-- Single persistent divider drawn above the idle-list legend block, to
-- separate the Routing/Waypoint/skip key rows from the last raid pill row.
-- Created once, repositioned + shown/hidden per refresh.
--
-- The line texture is a pure-WHITE alpha-mask (the shape lives in the alpha
-- channel: a thin band that fades out at both ends), tinted to the theme
-- magenta in code via SetVertexColor. Baking color into the art and keying it
-- out washed the color toward white and looked fuzzy; a white mask + vertex
-- tint stays crisp and true. Texture sharpening is disabled
-- (SetTexelSnappingBias/filter) to avoid the soft-edge blur. A small cyan gem
-- texture sits centered on the line.
panel.legendDivider = panel:CreateTexture(nil, "ARTWORK")
panel.legendDivider:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\divider-line")
panel.legendDivider:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 0.55)
panel.legendDivider:SetHeight(6)
if panel.legendDivider.SetTexelSnappingBias then
    panel.legendDivider:SetTexelSnappingBias(0)
    panel.legendDivider:SetSnapToPixelGrid(false)
end
panel.legendDivider:Hide()

-- Cyan gem centered on the divider line.
panel.legendDividerGem = panel:CreateTexture(nil, "OVERLAY")
panel.legendDividerGem:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\divider-gem")
panel.legendDividerGem:SetSize(14, 14)
panel.legendDividerGem:SetPoint("CENTER", panel.legendDivider, "CENTER", 0, 0)
if panel.legendDividerGem.SetTexelSnappingBias then
    panel.legendDividerGem:SetTexelSnappingBias(0)
    panel.legendDividerGem:SetSnapToPixelGrid(false)
end
panel.legendDividerGem:Hide()

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
    -- The divider is a persistent texture (not pooled); hide it here so a
    -- teardown that isn't immediately followed by a legend re-render (e.g.
    -- switching into in-raid boss-progress mode) doesn't leave it floating.
    if panel.legendDivider then panel.legendDivider:Hide() end
    if panel.legendDividerGem then panel.legendDividerGem:Hide() end
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

-- Idle-list pillRow hover regions. FontStrings can't take mouse
-- scripts, so locked-out pill rows get an invisible mouse-enabled frame
-- on top to surface the shared-lockout tooltip. Pooled and recycled in
-- lockstep with the line FontStrings (same lifecycle as the toggle /
-- entrance button pools).
panel.pillHoverFrames    = {}
panel.pillHoverFramePool = {}

-- Strikethrough line textures drawn over dead boss names in the wing rows.
-- One per dead boss currently shown. Pooled and recycled per idle-list
-- render in lockstep with the line FontStrings. A thin line at the name's
-- vertical center, spanning the rendered name width (WoW FontStrings have
-- no native strikethrough).
panel.wingStrikes     = {}
panel.wingStrikePool  = {}

-- Wing-expand chevron buttons on pill rows (one per raid with LFR wings)
-- and per-wing chevrons on wing-header rows. Parallel pool to the
-- expansion-toggle buttons; toggle a raid's wingExpandedRaids state (raid
-- level) or its open-wing (wing level).
panel.wingToggleButtons    = {}
panel.wingToggleButtonPool = {}

local function AcquirePillHoverFrame()
    local f = table.remove(panel.pillHoverFramePool)
    if f then return f end
    f = CreateFrame("Frame", nil, panel)
    f:SetFrameLevel((panel:GetFrameLevel() or 0) + 10)
    f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("This raid only supports a single lockout per character", 1, 1, 1, true)
        if GameTooltipTextSmall then
            GameTooltipTextLeft1:SetFontObject(GameTooltipTextSmall)
        end
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if GameTooltipText then
            GameTooltipTextLeft1:SetFontObject(GameTooltipText)
        end
    end)
    return f
end

local function ReleasePillHoverFrames()
    for _, f in ipairs(panel.pillHoverFrames) do
        f:Hide()
        f:ClearAllPoints()
        table.insert(panel.pillHoverFramePool, f)
    end
    wipe(panel.pillHoverFrames)
end

-- Wing-row strikethrough lines and wing-expand chevrons. Both helper sets
-- are scoped to the panel table inside a do/end block, callable from
-- RefreshIdleList.
do
    -- Strikethrough line over a dead boss name. A thin theme-gray line at
    -- the name's vertical center, spanning the rendered name width. Drawn
    -- at OVERLAY so it sits above the line FontString.
    function panel.AcquireWingStrike()
        local tx = table.remove(panel.wingStrikePool)
        if tx then return tx end
        tx = panel:CreateTexture(nil, "OVERLAY")
        -- Faded gray, matching the dead-boss name color.
        tx:SetColorTexture(0.44, 0.44, 0.44, 0.9)
        return tx
    end

    function panel.ReleaseWingStrikes()
        for _, tx in ipairs(panel.wingStrikes) do
            tx:Hide()
            tx:ClearAllPoints()
            table.insert(panel.wingStrikePool, tx)
        end
        wipe(panel.wingStrikes)
    end

    -- Wing-expand chevron button. Uses two pre-oriented WHITE triangle
    -- textures (TriRight for collapsed, TriDown for expanded) swapped by
    -- panel.SetWingChevron -- NOT runtime SetRotation, which bleeds the
    -- texture past its bounds (oversized footprint + edge sampling). White
    -- source means SetVertexColor tints to a clean SOLID color. Used at the
    -- raid level (pill row) and wing level (wing header).
    function panel.AcquireWingToggleButton()
        local btn = table.remove(panel.wingToggleButtonPool)
        if btn then return btn end
        btn = CreateFrame("Button", nil, panel)
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetFrameLevel((panel:GetFrameLevel() or 0) + 10)
        local tx = btn:CreateTexture(nil, "ARTWORK")
        tx:SetAllPoints(btn)
        btn._chevronTex = tx
        -- Highlight: a brighter overlay on hover (texture set per-call to
        -- match the current orientation).
        local hl = btn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(btn)
        hl:SetVertexColor(1, 1, 1, 0.3)
        btn._chevronHL = hl
        return btn
    end

    -- Apply the expanded/collapsed triangle (texture swap, no rotation) and
    -- solid RETRO pink tint (matches the plane nav icon, the other
    -- interactive glyph in the idle list).
    function panel.SetWingChevron(btn, expanded)
        local tex = expanded
            and "Interface\\AddOns\\RetroRuns\\Media\\TriDown"
            or  "Interface\\AddOns\\RetroRuns\\Media\\TriRight"
        local tx = btn._chevronTex
        if tx then
            tx:SetTexture(tex)
            tx:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 1)
        end
        if btn._chevronHL then btn._chevronHL:SetTexture(tex) end
    end

    function panel.ReleaseWingToggleButtons()
        for _, btn in ipairs(panel.wingToggleButtons) do
            btn:Hide()
            btn:SetScript("OnClick", nil)
            btn:ClearAllPoints()
            table.insert(panel.wingToggleButtonPool, btn)
        end
        wipe(panel.wingToggleButtons)
    end

    -- Draw a strikethrough over a dead boss's name. bossFS is the wingBoss
    -- row's FontString. The FontString left-anchors at the row's left edge
    -- but the visible name is indented (leading spaces), so the line must
    -- start at the name, not the FontString left. We measure the indent's
    -- width and span only the name portion. indentStr is the exact leading
    -- whitespace the row used so the measured offset matches.
    function panel.StrikeBossName(bossFS, fontSize, indentStr)
        local fullW = bossFS:GetStringWidth() or 0
        if fullW <= 0 then return end

        -- Measure the indent width with a hidden FontString synced to the
        -- row's font, so the strike starts exactly where the name does.
        if not panel._strikeMeasureFS then
            panel._strikeMeasureFS = panel:CreateFontString(nil, "ARTWORK")
            panel._strikeMeasureFS:Hide()
        end
        local mfs = panel._strikeMeasureFS
        local ff, fsz, ffl = bossFS:GetFont()
        if ff then mfs:SetFont(ff, fsz or fontSize, ffl or "") end
        mfs:SetText(indentStr or "")
        local indentW = mfs:GetStringWidth() or 0

        local nameW = fullW - indentW
        if nameW <= 0 then return end

        local tx = panel.AcquireWingStrike()
        tx:ClearAllPoints()
        tx:SetSize(nameW, 1)
        -- Start at the name (past the indent), centered vertically.
        tx:SetPoint("LEFT", bossFS, "LEFT", indentW, 0)
        tx:Show()
        table.insert(panel.wingStrikes, tx)
    end
end

-- Footer, two rows anchored bottom-up: credit + version on the bottom row,
-- the Map / Tmog / Skips / Settings buttons on the row above it. AutoSize
-- reserves space for both via PANEL_FOOTER_RESERVE.
panel.credit = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.credit:SetPoint("BOTTOMLEFT", PAD_LEFT, 8 + FRAME_INSET_Y)
panel.credit:SetText("")
-- Footer credit: standard font, locked at construction (footer doesn't
-- scale with the user's font slider).
panel.credit:SetFont(BODY_FONT, 10, "")

-- Right-side footer cluster: "What's New?" label plus a clickable bracketed
-- version link. A pulsing yellow [!] sits next to the label until the player
-- clicks the version (account-wide, dropped on first click). The pulse reuses
-- the same driver as the encounter-card [!].
panel.version = CreateFrame("Button", nil, panel)
panel.version:SetSize(70, 14)
panel.version:SetPoint("BOTTOMRIGHT", -PAD_RIGHT, 8 + FRAME_INSET_Y)
panel.version.glyph = panel.version:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.version.glyph:SetPoint("BOTTOMRIGHT", panel.version, "BOTTOMRIGHT", 0, 0)
panel.version.glyph:SetText("|cff7faaff[v" .. RetroRuns.VERSION .. "]|r")
-- Footer version glyph: standard font, locked at construction (footer
-- doesn't scale with the user's font slider).
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
    if UI.OpenSettingsToWhatsNew then UI.OpenSettingsToWhatsNew() end
end)

panel.whatsNewLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.whatsNewLabel:SetPoint("BOTTOMRIGHT", panel.version, "BOTTOMLEFT", -4, 0)
panel.whatsNewLabel:SetText("|cff9d9d9dWhat's New?|r")
-- Footer label: standard font, locked at construction. The pulse ticker
-- at the bottom of this file rewrites this FontString's text every
-- ~100ms via SetText; SetText preserves the font, so a single SetFont
-- here sticks across the lifetime of the addon.
panel.whatsNewLabel:SetFont(BODY_FONT, 10, "")

-- Centered footer status: "Toaster:" + a colored arrow glyph mirroring the
-- settings panel's Active Status (green up = active, amber down = travel to a
-- supported raid, red down = disabled). At-a-glance state without opening
-- settings. Locked font like the rest of the footer (no scaling). The label +
-- arrow are grouped in a container so the pair centers as a unit on the row.
panel.toastStatus = CreateFrame("Button", nil, panel)
panel.toastStatus:SetSize(120, 14)
panel.toastStatus:SetPoint("BOTTOM", 0, 8 + FRAME_INSET_Y)
do
    local f = panel.toastStatus
    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.label:SetFont(BODY_FONT, 10, "")
    f.label:SetText("Toaster:")
    f.label:SetTextColor(0.62, 0.62, 0.62)

    f.arrow = f:CreateTexture(nil, "OVERLAY")
    f.arrow:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\ArrowDown")
    f.arrow:SetSize(10, 10)

    -- Center the label+arrow pair as a group on the footer's bottom baseline.
    f.Layout = function()
        local lw = f.label:GetStringWidth() or 0
        local gap, aw = 4, 10
        local total = lw + gap + aw
        f.label:ClearAllPoints()
        f.label:SetPoint("BOTTOMLEFT", f, "BOTTOM", -total / 2, 0)
        f.arrow:ClearAllPoints()
        f.arrow:SetPoint("BOTTOMLEFT", f.label, "BOTTOMRIGHT", gap, 0)
        -- Tighten the click target to the rendered width so it doesn't capture
        -- clicks across the whole footer.
        f:SetWidth(total + 8)
    end
    f.Layout()

    -- Clickable shortcut into the Toaster settings tab. Brighten the label
    -- on hover to signal it's interactive (the arrow keeps its state color).
    f:SetScript("OnEnter", function() f.label:SetTextColor(0.95, 0.95, 0.95) end)
    f:SetScript("OnLeave", function() f.label:SetTextColor(0.62, 0.62, 0.62) end)
    f:SetScript("OnClick", function()
        if UI.OpenSettingsToToaster then UI.OpenSettingsToToaster() end
    end)

    -- Initial state matches the disabled default (red, down). The lifecycle
    -- reconcile repaints with the live state at login and on every raid
    -- enter/leave and toggle thereafter.
    f.arrow:SetRotation(0)
    f.arrow:SetVertexColor(0.95, 0.35, 0.35)
end

-- Action button row: Map, Tmog, Achieves, Skips, Settings, evenly distributed
-- across the panel width above the credit/version row. Map is the primary
-- in-raid action; Tmog/Achieves/Skips are reference views; Settings is config.
-- Square icon buttons (neon TGAs); a shared footnote below the row names the
-- hovered button.
local BUTTON_W   = 28
local BUTTON_H   = 28
local BUTTON_GAP = 14
local TOTAL_W    = BUTTON_W * 5 + BUTTON_GAP * 4
local START_X    = math.floor((PANEL_W - TOTAL_W) / 2)
local BUTTON_Y   = 30 + FRAME_INSET_Y   -- pixels up from the panel's bottom edge (incl. frame inset)

-- Shared one-line footnote shown above the hovered button. A single
-- FontString reused by all five buttons: OnEnter re-anchors it above that
-- button and sets the label; OnLeave clears it. Gray to match the credit row.
panel.actionFootnote = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.actionFootnote:SetText("")

local function MakeActionButton(name, label, icon, x, onClick)
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(BUTTON_W, BUTTON_H)
    btn:SetPoint("BOTTOMLEFT", x, BUTTON_Y)
    btn:SetText("")
    -- Hide the template's button-face textures so only our icon shows.
    if btn.SetNormalTexture     then btn:SetNormalTexture("")     end
    if btn.SetPushedTexture     then btn:SetPushedTexture("")     end
    if btn.SetHighlightTexture  then btn:SetHighlightTexture("")  end
    if btn.SetDisabledTexture   then btn:SetDisabledTexture("")   end

    local tex = btn:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\" .. icon)
    tex:SetAllPoints(btn)
    btn._tex  = tex
    btn._label = label

    btn:SetScript("OnEnter", function(self)
        self._tex:SetVertexColor(1.4, 1.4, 1.4)
        panel.actionFootnote:ClearAllPoints()
        panel.actionFootnote:SetPoint("BOTTOM", self, "TOP", 0, 3)
        panel.actionFootnote:SetText(self._label)
    end)
    btn:SetScript("OnLeave", function(self)
        self._tex:SetVertexColor(1, 1, 1)
        panel.actionFootnote:SetText("")
    end)
    btn:SetScript("OnClick", onClick)
    return btn
end

panel.mapBtn = MakeActionButton("Map", "Map", "MapIcon.tga",
    START_X,
    function() RR:ShowCurrentMapForStep() end)

panel.tmogBtn = MakeActionButton("Tmog", "Tmog", "HangerIcon.tga",
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

panel.achievesBtn = MakeActionButton("Achieves", "Achieves", "TrophyIcon.tga",
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

panel.skipsBtn = MakeActionButton("Skips", "Skips", "SkipIcon.tga",
    START_X + (BUTTON_W + BUTTON_GAP) * 3,
    function() UI.ToggleSkipsWindow() end)

panel.settingsBtn = MakeActionButton("Settings", "Settings", "SettingsIcon.tga",
    START_X + (BUTTON_W + BUTTON_GAP) * 4,
    function() UI.ToggleSettings() end)

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
local POPUP_CONTENT_CEILING  = 900  -- transmog popup max height (tall enough
                                    -- for the longest list -- Ra-den, ToT,
                                    -- 41 items -- without overflow)
local POPUP_CONTENT_MIN      = 240  -- transmog popup min height


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
    -- and NOT routed through targets. The action buttons use the
    -- UIPanelButtonTemplate default font; credit and whatsNewLabel
    -- are 04B_03, version.glyph is FRIZQT, mode is 04B_03 -- all set
    -- at construction. Only widgets that the user reads as "panel
    -- content" appear in this table.
    local targets = {
        { panel.raid,       14, "",        true },
        { panel.pills,      11, "",        true },
        { panel.progress,   14, "OUTLINE", true },
        { panel.next,       14, "OUTLINE", true },
        { panel.exitNote,   11, "",        true },
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
    -- window's content is per-row widgets at fixed y-offsets, so a font
    -- size change requires re-running RefreshContent to recompute the
    -- y-cursor and reposition rows.
    --
    -- Critical: this must only fire when scale/font ACTUALLY changed, not
    -- every heartbeat. UI.Update calls ApplySettings ~1Hz (and far more
    -- often while in a raid). An unconditional RefreshContent here rebuilds
    -- the row widgets every tick, which releases and re-acquires the
    -- expansion-toggle buttons -- so a click whose mouse-up landed just
    -- after a rebuild hit a button that had already been recycled, and the
    -- expand/collapse silently did nothing. Idle, the tick is infrequent
    -- enough that clicks usually survived; in a raid the constant refresh
    -- ate them, which is why the menus "wouldn't expand inside a raid."
    -- Gate on a change to scale or font size so a shown window only
    -- rebuilds when the layout inputs change, leaving toggle clicks intact.
    -- ALSO reset the expand state when the current-raid context changes,
    -- so expands don't carry across a zone-in/out. Keyed on instanceID
    -- (nil when not in a raid) -- a discrete change, not a per-tick one,
    -- so it doesn't reintroduce the click-eating churn.
    if skipsWindow then
        skipsWindow:SetScale(scale)

        -- Track the raid-context transition regardless of whether the
        -- window is shown. A raid change clears the explicit expand
        -- choices so the next render resets to a clean all-collapsed
        -- state. This MUST run even while the window is closed --
        -- otherwise expanding a few sections, closing the window, then
        -- zoning out would leave those stale expands to reappear when
        -- the window is reopened, because the reset never fired.
        local raidKey = RR.currentRaid and RR.currentRaid.instanceID or nil
        if skipsWindow._lastRaidKey ~= raidKey then
            skipsWindow._lastRaidKey = raidKey
            RR.state = RR.state or {}
            RR.state.skipsExpandedExpansions = {}
            skipsWindow._needsRebuild = true
        end

        if skipsWindow:IsShown() and skipsWindow.RefreshContent then
            local fontSize = RR:GetSetting("fontSize", 12)
            local fontStyle = RR:GetSetting("bodyFontStyle", "standard")
            -- Rebuild on a layout-input change (scale/font size/font family)
            -- or when the raid transition above flagged a needed rebuild.
            -- Gating keeps the per-tick churn away (which would eat toggle
            -- clicks). Font FAMILY must be tracked too: changing the body font
            -- (Friz / 04B_03 / VT323) without changing the size still needs a
            -- rebuild so the rows pick up the new font, the same way the idle
            -- list does via ApplySettings' targets table.
            if skipsWindow._lastScale ~= scale
               or skipsWindow._lastFontSize ~= fontSize
               or skipsWindow._lastFontStyle ~= fontStyle
               or skipsWindow._needsRebuild then
                skipsWindow._lastScale = scale
                skipsWindow._lastFontSize = fontSize
                skipsWindow._lastFontStyle = fontStyle
                skipsWindow._needsRebuild = nil
                skipsWindow.RefreshContent()
            end
        end
    end
    -- Achievements window: scale applied like the others. The window uses a
    -- row pool (one frame per row, like skips), so font-size or font-family
    -- changes affect row spacing and per-cell font metrics. Gate the rebuild
    -- on those layout inputs rather than refreshing every tick -- the old
    -- unconditional per-tick RefreshContent was wasteful and risked eating
    -- row interactions the same way skips did before its gate.
    if achievementsWindow then
        achievementsWindow:SetScale(scale)
        if achievementsWindow:IsShown() and achievementsWindow.RefreshContent then
            local fontSize = RR:GetSetting("fontSize", 12)
            local fontStyle = RR:GetSetting("bodyFontStyle", "standard")
            if achievementsWindow._lastScale ~= scale
               or achievementsWindow._lastFontSize ~= fontSize
               or achievementsWindow._lastFontStyle ~= fontStyle then
                achievementsWindow._lastScale = scale
                achievementsWindow._lastFontSize = fontSize
                achievementsWindow._lastFontStyle = fontStyle
                achievementsWindow:RefreshContent()
            end
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
    -- The main panel's interior fill is the backdrop bgFile; fade it via the
    -- backdrop color alpha (border stays full opacity for frame legibility).
    if panel.SetBackdropColor then panel:SetBackdropColor(1, 1, 1, opacity) end
    ApplyOpacity(tmogWindow)
    ApplyOpacity(skipsWindow)
    ApplyOpacity(achievementsWindow)

    -- Re-fit the panel + auxiliary frames now that fonts and scale changed.
    -- AutoSize computes heights from line counts (not GetStringHeight) so a
    -- single synchronous pass is sufficient -- no deferred re-measure pass
    -- needed, which eliminates the visible pop-in flicker.
    UI.AutoSize()

    -- Re-run the idle list refresh so expansion-toggle Buttons pick up
    -- the new font size. Gated on idleListLines (only fires when the
    -- idle list is actually rendered, not in-raid mode).
    if RefreshIdleList and #panel.idleListLines > 0 then
        RefreshIdleList()
    end

    -- Re-apply the active font to in-raid Boss-Progress rows in place.
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
-- which makes the bar feel less cramped than a flush 50. The minimized bar
-- art has thin top/bottom edges, so it doesn't take the full panel inset --
-- the title/buttons are re-centered for the bar in ApplyMinimizedState.
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
        panel.raid, panel.wingLine, panel.pills, panel.progress, panel.next,
        panel.travel, panel.encounter, panel.transmog,
        panel.exitNote,
        panel.listHeader, panel.list,
        panel.credit, panel.version, panel.whatsNewLabel,
        panel.toastStatus,
        panel.mapBtn, panel.tmogBtn, panel.achievesBtn,
        panel.skipsBtn, panel.settingsBtn,
        panel.actionFootnote,
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
    if panel.legendDivider and #(panel.idleListLegendLines or {}) > 0 then
        if visible then panel.legendDivider:Show() else panel.legendDivider:Hide() end
        if panel.legendDividerGem then
            if visible then panel.legendDividerGem:Show() else panel.legendDividerGem:Hide() end
        end
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
    for _, btn in ipairs(panel.wingToggleButtons or {}) do
        if visible then btn:Show() else btn:Hide() end
    end
    for _, tx in ipairs(panel.wingStrikes or {}) do
        if visible then tx:Show() else tx:Hide() end
    end
    for _, f in ipairs(panel.pillHoverFrames or {}) do
        if visible then f:Show() else f:Hide() end
    end
    if panel.pillsHover then
        if visible then panel.pillsHover:Show() else panel.pillsHover:Hide() end
    end
end

-- Update the minimize button's texture based on current minimized state.
-- MinimizeIcon shows when expanded (click to minimize); MaximizeIcon
-- shows when minimized (click to expand). Swaps the single _tex texture.
local function UpdateMinimizeIcon()
    if not panel.minimizeButton or not panel.minimizeButton._tex then return end
    local tex
    if UI.IsMinimized() then
        tex = "Interface\\AddOns\\RetroRuns\\Media\\MaximizeIcon"
    else
        tex = "Interface\\AddOns\\RetroRuns\\Media\\MinimizeIcon"
    end
    panel.minimizeButton._tex:SetTexture(tex)
end

-- Compute the panel width needed to display just the title bar content
-- (logo + RETRO RUNS text + minimize button + close button) when
-- minimized. Read at apply-time rather than baked in as a constant
-- because the title text's rendered width depends on the font face
-- and OUTLINE flag, which could change via Settings or future
-- redesigns.

-- Scale applied to the title wordmark and the title-row buttons. Used both
-- when laying out the row and when computing the bar width from the title's
-- string width, so it lives as one named value rather than a repeated literal.
local TITLE_SCALE = 0.83

-- Width of the minimized bar. Derived from the title's rendered STRING width
-- (a constant for fixed "RETRO RUNS" text) rather than from live screen-edge
-- positions. The earlier GetRight()-minus-GetLeft() approach re-measured
-- absolute screen coords on every UI.Update, and those edges can resolve
-- transiently wrong while layout is mid-flight on an unrelated event (opening
-- a mailbox fires an event that runs UI.Update, and the bar grew because the
-- measured right edge came back inflated for that frame). String width can't
-- be perturbed that way, so the bar width stays stable.
local function ComputeMinimizedPanelW()
    if not panel.titleRetro or not panel.titleRuns then return nil end
    local retroW = panel.titleRetro:GetStringWidth()
    local runsW  = panel.titleRuns:GetStringWidth()
    if not retroW or not runsW or retroW <= 0 or runsW <= 0 then
        -- Text not yet rendered (e.g. first call after a fresh reload);
        -- caller falls back to MINIMIZED_PANEL_W_FALLBACK for one frame.
        return nil
    end
    -- The title is drawn at TITLE_SCALE while on the bar, so its on-screen
    -- width is the rendered string width times that scale. The title's left
    -- edge sits PAD_LEFT from the panel left.
    local wordmarkW = retroW + runsW
    -- When the next-step note is showing, the wordmark is collapsed to "RR"
    -- and the white note sits to its right (anchored with a 6px left pad).
    -- Add the note's rendered width plus that pad so the bar grows to fit the
    -- instruction instead of letting it run under the buttons. The pad is in
    -- screen pixels; convert to pre-scale string-space by dividing by the
    -- scale so the final * TITLE_SCALE leaves it at 6px on screen.
    if panel.titleMinNote and panel.titleMinNote:IsShown() then
        local noteW = panel.titleMinNote:GetStringWidth() or 0
        if noteW > 0 then
            wordmarkW = wordmarkW + noteW + (6 / TITLE_SCALE)
        end
    end
    local titleScreenW = wordmarkW * TITLE_SCALE
    local titleRightLocal = PAD_LEFT + titleScreenW
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
-- Position the title wordmark and the top-right buttons for the current state.
-- Expanded: top-anchored under the frame's top rail (offset by the vertical
-- frame inset). Minimized: vertically centered in the short bar, where the bar
-- art's thin top/bottom edges leave room. Without this, the expanded top-offset
-- (-12 - FRAME_INSET_Y) strands the title near the bottom of the short bar with
-- a void above it.
local function ApplyTitleLayoutForState(minimized)
    if minimized then
        -- Shrink via SetScale (not SetFont/SetSize): scaling shrinks the glyph
        -- AND the bounding box together, so the RETRO/RUNS spacing stays tight
        -- and the close button's X actually shrinks (SetSize leaves the template
        -- X glyph full-size). TITLE_SCALE = roughly 10pt-equivalent for the
        -- 12pt title and ~10% off the buttons.
        local s = TITLE_SCALE
        panel.titleRetro:SetScale(s)
        panel.titleRuns:SetScale(s)
        panel.titleMinNote:SetScale(s)
        panel.closeButton:SetScale(s)
        panel.minimizeButton:SetScale(s)

        -- Decide whether to show the next-step note. GetActiveMinNote returns
        -- nil when there's no active routing step OR the current seg carries no
        -- minNote, so a non-nil return is the signal that genuine per-segment
        -- data exists. Only then collapse the wordmark to "RR" and show the note;
        -- otherwise keep the full "RETRO RUNS" wordmark. This keeps the bar
        -- unchanged until minNote data is authored into the routing segments.
        local minNote = RR.GetActiveMinNote and RR:GetActiveMinNote() or nil
        if minNote and minNote ~= "" then
            panel.titleRetro:SetText("R")
            panel.titleRuns:SetText("R")
            panel.titleMinNote:SetText(minNote)
            panel.titleMinNote:Show()
        else
            panel.titleRetro:SetText("RETRO")
            panel.titleRuns:SetText("RUNS")
            panel.titleMinNote:SetText("")
            panel.titleMinNote:Hide()
        end
        local titleEdge = 20 / s   -- screen clearance so the title clears the corner art
        local btnEdge   = 18 / s   -- buttons sit a bit closer to the right corner
        panel.titleRetro:ClearAllPoints()
        panel.titleRetro:SetPoint("LEFT", panel, "LEFT", titleEdge, 0)
        panel.closeButton:ClearAllPoints()
        panel.closeButton:SetPoint("RIGHT", panel, "RIGHT", -btnEdge, 0)
        -- Center the minimize button on the close button's CENTER so the two
        -- sit at exactly the same height. Both are 24px frames; the x-offset
        -- tucks them together with a small gap.
        panel.minimizeButton:ClearAllPoints()
        panel.minimizeButton:SetPoint("CENTER", panel.closeButton, "CENTER", -30, 0)
    else
        -- Expanded panel: same compact scale as the minimized bar, and the
        -- title row placed at the SAME distance from the top border as the
        -- minimized bar (where the title centers in MINIMIZED_PANEL_H). This
        -- keeps the title-to-top-border gap identical between the two states.
        local s = TITLE_SCALE
        panel.titleRetro:SetScale(s)
        panel.titleRuns:SetScale(s)
        panel.titleMinNote:SetScale(s)
        panel.closeButton:SetScale(s)
        panel.minimizeButton:SetScale(s)
        -- Expanded panel always shows the full wordmark; the next-step note is
        -- a minimized-bar-only affordance, so restore "RETRO RUNS" and hide it.
        panel.titleRetro:SetText("RETRO")
        panel.titleRuns:SetText("RUNS")
        panel.titleMinNote:SetText("")
        panel.titleMinNote:Hide()
        local expandedRowCenterY = -26
        panel.closeButton:ClearAllPoints()
        panel.closeButton:SetPoint("RIGHT", panel, "TOPRIGHT", (-22) / s, expandedRowCenterY / s)
        panel.minimizeButton:ClearAllPoints()
        panel.minimizeButton:SetPoint("CENTER", panel.closeButton, "CENTER", -30, 0)
        -- Title: left-anchored, vertical center matched to the button row center.
        panel.titleRetro:ClearAllPoints()
        panel.titleRetro:SetPoint("LEFT", panel, "TOPLEFT", PAD_LEFT / s, expandedRowCenterY / s)
    end
end

function UI.ApplyMinimizedState()
    local minimized = UI.IsMinimized()
    UpdateMinimizeIcon()
    ApplyBodyVisibility(not minimized)
    ApplyBorderArtForState(minimized)
    ApplyTitleLayoutForState(minimized)

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
    -- Minimized mode pins height to a fixed value via ApplyMinimizedState.
    if UI.IsMinimized() then return end

    -- Bottom of the layout is whichever pool is non-empty -- in-raid
    -- boss-progress lines, or idle supported-raids list.
    local fontSize   = RR:GetSetting("fontSize", 12)
    -- Row height is the single-line FontString height (the font pixel
    -- size). The progress/idle rows are bare FontStrings laid out at a
    -- -2px stride (see the GetProgressLines / idle-list layout), so the
    -- per-row advance is fontHeight + 2px gap. An earlier +4 here padded
    -- every row by 4px the FontStrings don't occupy, inflating the panel
    -- by ~4px * rowCount -- ~56px of dead space at SoO's 14 bosses.
    local lineHeight = GetBodyFontSize(fontSize)

    local listH = 0
    local hasContent = false

    -- (a) In-raid boss-progress lines.
    if #panel.progressListLines > 0 then
        local rowH      = lineHeight
        local gap       = 2
        local progressH = #panel.progressListLines * rowH
                        + (math.max(0, #panel.progressListLines - 1)) * gap
                        + 8  -- top spacing under listHeader
        listH = math.max(listH, progressH)
        hasContent = true
    end

    -- (b) Idle / run-complete supported-raids list.
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
        -- Footer reserve covers (from the panel's bottom edge): the action
        -- button row and, in idle mode, the skip/entrance legend block that
        -- pins above it. The legend block bottom-anchors LEGEND_BOTTOM_OFFSET
        -- px up from the panel bottom (see RefreshIdleList; that value already
        -- clears the button row plus a cushion). The reserve must therefore
        -- measure from that anchor, NOT from the button-row top -- the earlier
        -- math used buttonsTopFromBottom (=50) as the legend base, undershooting
        -- by the LEGEND_BOTTOM_OFFSET-vs-button-top gap and letting the list
        -- overlap the Routing/Waypoint lines when a tall expansion is open.
        -- Legend row metrics scale with the active body font's sizeFactor.
        local buttonsTopFromBottom = BUTTON_Y + BUTTON_H  -- BUTTON_Y includes frame inset
        local isInRaidMode         = #panel.progressListLines > 0
        local footerReserve
        if isInRaidMode then
            -- In-raid reserve: button row plus a footnote line above it.
            local FOOTNOTE_RESERVE = GetBodyFontSize(10) + 12
            footerReserve = buttonsTopFromBottom + FOOTNOTE_RESERVE
        else
            -- Must mirror RefreshIdleList's legend constants so the two stay
            -- in sync. The legend block bottom sits at LEGEND_BOTTOM_OFFSET
            -- from the panel bottom; above it stack up to 3 rows worst-case
            -- (skip + Routing + Waypoint), each GetBodyFontSize(LEGEND_FONT_
            -- SIZE=10) + 4px text-row padding, with LEGEND_INTER_GAP gaps
            -- between them. A final cushion sits above the topmost legend row
            -- to separate it from the last raid pill row.
            local LEGEND_BOTTOM_OFFSET = BUTTON_Y + BUTTON_H + 12  -- BUTTON_Y includes frame inset
            local LEGEND_INTER_GAP     = 4
            local LEGEND_TOP_CUSHION   = 36  -- gap between last pill row and legend (holds the divider)
            local legendLineHeight     = GetBodyFontSize(10) + 4
            -- Reserve for the legend rows actually present (1-3) rather than a
            -- fixed worst-case 3 -- reserving 3 when fewer show left a big empty
            -- band above the footer in the idle view.
            local legendRows           = #(panel.idleListLegendLines or {})
            if legendRows < 1 then legendRows = 1 end
            if legendRows > 3 then legendRows = 3 end
            local legendBlockHeight    = legendRows * legendLineHeight
                                       + math.max(0, legendRows - 1) * LEGEND_INTER_GAP
            footerReserve = LEGEND_BOTTOM_OFFSET + legendBlockHeight + LEGEND_TOP_CUSHION
        end

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

    -- Now that the panel height (and thus the bottom-pinned legend's screen
    -- position) is final, place the divider at the midpoint between the last
    -- raid row and the legend top. Guarded internally for the no-legend case.
    if PositionLegendDivider then PositionLegendDivider() end

    -- TRANSMOG POPUP -------------------------------------------------------
    -- Size the popup deterministically from the content's line count rather
    -- than measuring rendered text, because GetStringHeight is lazy after
    -- SetFont and produces a visible pop-in on the first frame. Line-height
    -- is approximated from the font size; the content widgets are all
    -- rendered at fontSize-1 (see RefreshContent's SetBodyFont calls). The
    -- per-line vertical advance for FRIZQT at that size is about 11.3 px, so
    -- a +2 px per-line safety margin absorbs a modest amount of word-wrap
    -- without over-allocating.
    if tmogWindow and tmogWindow.contentText then
        local text = tmogWindow.contentText
        local content = text:GetText() or ""
        local lines = 1
        for _ in content:gmatch("\n") do lines = lines + 1 end

        local fontSize = RR:GetSetting("fontSize", 12)
        -- Match the actual rendered font size (fontSize - 1, per
        -- RefreshContent) and the active body font's sizeFactor so
        -- the height budget matches the rendered text for non-FRIZQT
        -- fonts too.
        --
        -- Per-line advance: measured against rendered text, the real vertical
        -- advance is GetBodyFontSize plus a fraction of a pixel of leading
        -- (e.g. a 43-line list rendered at size 11 measured 480.5px -> 11.17
        -- px/line, vs GetBodyFontSize(11) = 11). The previous +2 budget left
        -- ~1.8 px of slack per line, which on a 43-line list piled up into an
        -- ~80px blank strip below the legend. A +0.5 pad covers the real
        -- leading with a little rounding headroom while keeping the per-line
        -- slack negligible (~0.3 px), so long lists no longer over-grow.
        local renderedSize = math.max(8, fontSize - 1)
        local lineHeight   = GetBodyFontSize(renderedSize) + 0.5
        local textH        = lines * lineHeight

        -- Sanctum vendor line (Castle Nathria) lives on its own
        -- FontString below the main content. When shown, it adds one
        -- line of text plus the 2px gap from the BOTTOMLEFT anchor
        -- (tight so the redeem line reads as a continuation of the
        -- weapon-token heading directly above it). Hidden -- which
        -- is the case for every non-CN raid and every CN boss that
        -- doesn't drop weapon tokens -- contributes 0.
        local sanctumH = 0
        if tmogWindow.sanctumLine and tmogWindow.sanctumLine:IsShown() then
            sanctumH = lineHeight + 2
        end

        -- Color legend always renders as a global footer below the
        -- sanctum line (or below the main text when sanctum is
        -- hidden). Two lines of text plus the 8px gap.
        local legendH = 2 * lineHeight + 8

        -- Popup chrome: dropdown stack + top inset + margins. The
        -- dropdowns anchor via BOTTOMLEFT +4 (positive y = up in WoW),
        -- which means each successive dropdown OVERLAPS the one above
        -- it by 4 px. Three dropdowns produce two overlaps, so the
        -- effective stack height is 3*32 - 8 = 88, not 96.
        local chrome = 32         -- top: close-button reserve
                     + 3 * 32 - 8 -- three dropdowns, two 4px overlaps
                     + 10         -- gap between dropdowns and text
                     + 14         -- bottom margin
        local desired = chrome + textH + sanctumH + legendH
        local clamped = math.max(POPUP_CONTENT_MIN,
                                 math.min(POPUP_CONTENT_CEILING, desired))
        tmogWindow:SetHeight(clamped)
    end

    -- ACHIEVEMENTS POPUP: sized inside RefreshContent (row-based layout,
    -- same pattern as skips). Nothing to do here.
end

-- Expose on the module and also keep backward-compatible reference
RetroRunsUI = panel

panel:Hide()

-------------------------------------------------------------------------------
-- Settings panel
-------------------------------------------------------------------------------
-- Settings are built natively with the Blizzard Settings API in
-- UI/SettingsCanvas.lua and live in Options > AddOns. There is no custom
-- settings frame here anymore.


-- Settings now live in the Blizzard Options > AddOns window, built natively
-- with the Settings API in UI/SettingsCanvas.lua. There is no custom settings
-- frame to construct or sync; the native controls read RetroRunsDB directly
-- through their proxy settings.

function UI.SyncSettingsControls()
    -- No-op. The native settings panel reads RetroRunsDB on demand and stays
    -- in sync without an explicit push; this stays for callers that expect it.
end

function UI.ToggleSettings()
    -- Open the Blizzard settings window to the RetroRuns category.
    -- (UI.OpenSettings is defined in UI/SettingsCanvas.lua.)
    if UI.OpenSettings then UI.OpenSettings() end
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
--
-- Author-marked ^carets^ win: words already inside a |c...|r color
-- span (e.g. caret-wrapped via HighlightNames) are left alone, so a
-- soloTip can write ^Mythic^ to force orange highlighting instead of
-- the auto-applied purple difficulty color.
local function ColorizeDifficulties(text)
    if not text or text == "" then return text end
    local function colorizePlain(s)
        for _, word in ipairs(DIFFICULTY_COLOR_ORDER) do
            local color = DIFFICULTY_COLORS[word]
            if color then
                -- %f[%a] and %f[%A] are Lua's frontier patterns, which act as
                -- word boundaries. This keeps "Mythic" from matching inside
                -- "Mythica" and avoids double-coloring if the word appears
                -- inside an already-colored segment (the |c...|r wrap makes
                -- word boundaries stable).
                s = s:gsub(
                    "%f[%a]" .. word .. "%f[%A]",
                    ("|c%s%s|r"):format(color, word))
            end
        end
        return s
    end
    -- Walk the text, applying difficulty colors only outside existing
    -- |c...|r spans. Preserves caret-wrapped highlights verbatim.
    local out, pos = {}, 1
    while pos <= #text do
        local s, e = text:find("|c%x%x%x%x%x%x%x%x.-|r", pos)
        if not s then
            out[#out+1] = colorizePlain(text:sub(pos))
            break
        end
        if s > pos then
            out[#out+1] = colorizePlain(text:sub(pos, s - 1))
        end
        out[#out+1] = text:sub(s, e)
        pos = e + 1
    end
    return table.concat(out)
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


-- The world map's currently-displayed mapID can be stale (the player
-- may have last viewed a different sub-zone), so using it can surface
-- a wrong-step-segment note. Map RENDERING does use worldMapID --
-- that's the right input for "draw segments on whichever map is
-- visible" -- but text matching needs to follow the player's physical
-- location.
local function GetBestMapForStep(step)
    if not step then return nil end
    return C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")
end
-- Exposed on the UI namespace so out-of-file callers can use the same
-- map-resolution logic the renderer uses, rather than reimplementing it.
UI.GetBestMapForStep = GetBestMapForStep

-- Per-difficulty pill row text. Renders as a bracketed pipe-separated
-- strip matching the tmog dot row's visual style (BuildPerDiffRow at
-- ~line 2080):
--   [ LFR 0/8 | N 8/8 | H 0/8 | M 0/8 ]
-- with brackets and pipes in dark gray. Pill text color uses the same
-- 3-state palette as the Boss Progress checklist:
--   green  -- this difficulty is fully cleared (count == total)
--   yellow -- this is the player's current difficulty
--   gray   -- everything else (untouched, or partial-not-active;
--             the x/y count carries the partial info)
-- Complete trumps active: a player standing in a fully cleared
-- difficulty sees green, not yellow.
--
-- Returns "" when no kill data available (raid not loaded, API
-- unsupported, no encounters mapped) so the FontString just renders
-- empty without breaking layout.
local function BuildPillsText()
    local counts = RR:GetPerDifficultyKillCounts()
    if not counts then return "" end

    local raid = RR.currentRaid
    -- Active difficulty is a live ID; fold it to its display bucket so it
    -- lines up with the bucket-keyed counts under any difficulty model.
    local activeDiff = RR:FoldDifficulty(raid, RR.state and RR.state.currentDifficultyID)
    local COMPLETE_HEX = "00ff00"
    local ACTIVE_HEX   = "ffff00"
    local PENDING_HEX  = "9d9d9d"

    -- Short label per display bucket. LFR (17) is intentionally absent:
    -- like the rest of the addon, the pill row covers Normal and up,
    -- while LFR sources live in the transmog browser. Mists raids drop
    -- Mythic (16); the model's bucket list handles that automatically.
    local BUCKET_LABEL = { [14] = "N", [15] = "H", [16] = "M" }

    -- Order matches typical Blizzard UI: easiest -> hardest. Built from
    -- the raid's difficulty model so Mists raids show N | H and modern
    -- raids show N | H | M without a per-era branch here.
    local model = RR:GetDifficultyModel(raid)
    local PILLS = {}
    for _, bucket in ipairs(model.buckets) do
        local label = BUCKET_LABEL[bucket]
        if label then
            table.insert(PILLS, { id = bucket, label = label })
        end
    end

    -- Mists shared lockout: the Normal/Heroic sibling of a committed mode
    -- is locked for the week. Lock glyph marks it (no recolor; see the
    -- idle builder for why color alone won't read here).
    local lockedBucket = RR:GetLockedOutBucket(raid, counts)
    -- yOffset drops the icon onto the text baseline; trailing RGB tints it
    -- gold (the LFG lock is the locked-out marker).
    local LOCK_GLYPH = " |TInterface\\PetBattles\\PetBattle-LockIcon:12:12:0:0|t"

    local parts = {}

    -- LFR pill first (easiest -> hardest ordering). LFR completion comes from
    -- the lockout bitfield, not C_RaidLocks like the other buckets, so it's
    -- sourced separately. Shown only for raids that have LFR wing data. The
    -- active-difficulty highlight applies when the player is currently in LFR.
    local lfr = RR:GetLFRKillCount()
    if lfr then
        local hex
        if lfr.total > 0 and lfr.complete == lfr.total then
            hex = COMPLETE_HEX
        elseif RR:IsInLFR() then
            hex = ACTIVE_HEX
        else
            hex = PENDING_HEX
        end
        table.insert(parts, ("|cff%sLFR %d/%d|r"):format(hex, lfr.complete, lfr.total))
    end

    for _, p in ipairs(PILLS) do
        local c = counts[p.id]
        if c then
            local hex
            if c.total > 0 and c.complete == c.total then
                hex = COMPLETE_HEX
            elseif p.id == activeDiff then
                hex = ACTIVE_HEX
            else
                hex = PENDING_HEX
            end
            local lock = (p.id == lockedBucket) and LOCK_GLYPH or ""
            table.insert(parts, ("|cff%s%s %d/%d|r%s"):format(
                hex, p.label, c.complete, c.total, lock))
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

-- Public accessor for the current pulse color escape. Cross-module
-- readers (MapOverlay's completionCheck flashing labels, etc.) call
-- this to breathe in sync with the encounter [!] and What's New?
-- [!] pulses. Closes over the local ENCOUNTER_PULSE_COLORS table
-- and encounterPulsePhase so callers don't need their own copy.
function RR:GetPulseColor()
    return ENCOUNTER_PULSE_COLORS[encounterPulsePhase] or "|cffffff00"
end

-- Pulse table for map labels: same cadence as the encounter [!], but sweeps
-- all three RGB channels so text breathes gray->white (0.60..1.00) instead of
-- dim-to-bright yellow, keeping map labels in the white-text vocabulary.
local LABEL_PULSE_COLORS = {}
for i = 0, ENCOUNTER_PULSE_STEPS - 1 do
    local phase = (i / ENCOUNTER_PULSE_STEPS) * 2 * math.pi
    local brightness = 0.80 + 0.20 * math.cos(phase)
    local byte = math.floor(brightness * 255 + 0.5)
    if byte > 255 then byte = 255 end
    if byte < 0 then byte = 0 end
    LABEL_PULSE_COLORS[i] = ("|cff%02x%02x%02x"):format(byte, byte, byte)
end

-- Public accessor for the gray-white label pulse. Used by MapOverlay's
-- completionCheck label ticker; breathes in sync with the yellow [!]
-- pulses (shared phase counter) so all addon attention-grabbers move
-- together, just in different palettes for their respective contexts.
function RR:GetLabelPulseColor()
    return LABEL_PULSE_COLORS[encounterPulsePhase] or "|cffffffff"
end

-- Parallel pulse table for the world map highlight ring: same cosine
-- cadence as the label pulse, but modulates only the red channel. Ring
-- texture is white at authoring time so SetVertexColor's R-channel
-- value IS the displayed red intensity. Range 0.55..1.00 -- a wider
-- sweep than the label gray-white because the ring is a stronger
-- attention element and benefits from a more pronounced breath.
local RING_PULSE_REDS = {}
for i = 0, ENCOUNTER_PULSE_STEPS - 1 do
    local phase = (i / ENCOUNTER_PULSE_STEPS) * 2 * math.pi
    RING_PULSE_REDS[i] = 0.775 + 0.225 * math.cos(phase)
end

-- Returns the current red-channel value (0..1 float) for the highlight
-- ring's vertex color. MapOverlay's ring ticker calls this each 0.1s
-- and applies it via SetVertexColor(r, 0, 0, 1) so the ring breathes
-- bright-red to dim-red and back in sync with the label and [!] pulses.
function RR:GetRingPulseRed()
    return RING_PULSE_REDS[encounterPulsePhase] or 1.0
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

        local seg = RR:PickNoteSeg(step, mapID)
        if seg and seg.note then
            return prefix .. HighlightNames(seg.note)
        end
        if step.travelText then
            return prefix .. HighlightNames(step.travelText)
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
            -- Strip color codes; cap with ellipsis so truncated entries
            -- read as truncated rather than mid-word cutoffs. Cap is wide
            -- enough that the vast majority of notes fit in full.
            local stripped = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            if #stripped > 200 then
                stripped = stripped:sub(1, 197) .. "..."
            end
            RR:LogRecorderSession("PickerOutput", {
                playerMapID    = playerMapID,
                playerSubZone  = playerSubZone,
                stepNumber     = step and (step.step or step.priority) or 0,
                text           = stripped,
            })
        end
        lastLoggedTravelText = text
    end

    lastTravelText = text
    return text
end

-- A boss has a "custom" note when it's non-empty AND not the
-- default "Standard Nuke" placeholder.
local function HasCustomEncounterNote(boss, step)
    local tip = (boss and boss.soloTip) or (step and step.soloTip) or ""
    if tip == "" or tip == "N/A" then return false end
    if tip:lower() == "standard nuke" then return false end
    return true
end

-- Builds the Achievements block: "Achievements:" header + per-row
-- clickable hyperlinks color-coded by completion state. Returns ""
-- for bosses with no achievements (caller appends unconditionally).
local function BuildAchievementsBlock(boss)
    if not boss or not boss.achievements or #boss.achievements == 0 then
        return ""
    end
    local lines = { ("|cff%sAchievements:|r"):format(C_LABEL) }

    -- Bracketed state indicator before the link, matching the
    -- Special Loot section's visual grammar. Kept as a separate
    -- prefix since GetAchievementLink embeds its own color code
    -- and WoW color codes don't nest.
    local STATE_COLOR_DONE   = "ff00ff00"
    local STATE_COLOR_TODO   = "ff888888"
    local STATE_GLYPH_DONE   = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
    local STATE_GLYPH_TODO   = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14|t"

    for _, ach in ipairs(boss.achievements) do
        local _, name, _, completed = GetAchievementInfo(ach.id)
        local label = name or ach.name or ("ID " .. ach.id)
        local tag   = ach.meta and " (Meta)" or ""

        local stateColor = completed and STATE_COLOR_DONE or STATE_COLOR_TODO
        local stateGlyph = completed and STATE_GLYPH_DONE or STATE_GLYPH_TODO
        local indicator  = ("|cff777777[ |r|c%s%s|r|cff777777 ]|r"):format(
            stateColor, stateGlyph)

        local link = GetAchievementLink and GetAchievementLink(ach.id)
        if link then
            -- Fold "(Meta)" inside the |h[...]|h so the tag is part
            -- of the clickable hit-area.
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
    [17] = "LFR",
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

-- Per-source appearance ID (visualID). Resolves per-difficulty,
-- unlike GetAppearanceIDForItem which collapses to Normal-difficulty.
-- Uses GetAppearanceInfoBySource because GetSourceInfo.itemAppearanceID
-- returns nil in current retail. Callers must handle nil.
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

-- State-indicator colors. |c...|r wraps text only -- texture glyphs
-- like ReadyCheck-Ready keep their native colors.
local SPECIAL_COLLECTED   = "ff00ff00"
local SPECIAL_UNCOLLECTED = "ff888888"
-- Partial: weapon-token-style rows where the row represents a pool
-- of appearances (some collected, some not).
local SPECIAL_PARTIAL     = "ffff9333"

-- 14x14 textures from RaidFrame family so brackets align across
-- states. Native colors (green/red) since |c...|r doesn't tint
-- embedded textures.
local SPECIAL_GLYPH_COLLECTED   = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local SPECIAL_GLYPH_UNCOLLECTED = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14|t"
-- Partial glyph: ReadyCheck-Waiting (question mark) recolored to
-- red-orange via SPECIAL_PARTIAL wrapper.
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
        -- Weapon-enchant illusions are tracked by sourceID (not itemID).
        -- Iterate C_TransmogCollection.GetIllusions() and match by source.
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
        -- C_HousingCatalog landed in 11.2.7. The collection-state probe
        -- is GetCatalogEntryInfoByRecordID(1, decorID, true). A decor
        -- counts as collected if quantity/remainingRedeemable/numPlaced
        -- is positive, OR firstAcquisitionBonus has been claimed (== 0).
        if not C_HousingCatalog then return "missing" end
        if not C_HousingCatalog.GetCatalogEntryInfoByRecordID then return "missing" end

        -- decorID is the lookup key (schema field on the specialLoot row).
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
        -- Barter items (e.g. Iskaara Trader's Ottuk -- two-ingredient
        -- purchase) render the mount row with per-ingredient sub-rows
        -- showing in-bag status. Already-collected mounts skip the
        -- barter detail and render as a plain "(Mount)" row.
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
                kindInner = kindLabel .. ", |r|cffF259C7Mythic only|r|c" .. kindColor
            elseif item.lfrOnly then
                kindInner = kindLabel .. ", |r|cffF259C7LFR only|r|c" .. kindColor
            elseif item.normalHeroicOnly then
                kindInner = kindLabel .. ", |r|cffF259C7Normal/Heroic only|r|c" .. kindColor
            end

            -- Bracketed state indicator before the name, matching the
            -- per-difficulty dot row. The itemLink keeps its native
            -- quality color in BOTH states so collected rows stay
            -- clickable (players still want preview/link access).
            local nameRender = display

            table.insert(lines,
                ("|cff777777[ |r|c%s%s|r|cff777777 ]|r %s |c%s(%s)|r"):format(
                    stateColor, stateGlyph, nameRender, kindColor, kindInner))
        end
    end
    return table.concat(lines, "\n")
end

-- Tier items only show if the player's class is in item.classes, or
-- the user has toggled "show all classes" in the tmog browser.
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
    -- Special-loot entries (pets, mounts, toys, illusions, manuscripts,
    -- decor) carry a `kind` and belong in the boss specialLoot list, which
    -- the core UI surfaces separately. They have no equip slot and no
    -- per-difficulty appearance sources, so they must never appear in the
    -- transmog browser regardless of which array they were authored into.
    if item.kind then return false end
    if TRANSMOG_EXCLUDED_SLOTS[item.slot] then return false end
    if not ItemIsForPlayer(item) then return false end
    return true
end

-- The "active" (current in-game) difficulty, folded to its display
-- bucket so it lines up with the 14/15/16/17 keys the source data uses.
-- Under the Mists model a live size variant (e.g. 25-player Heroic)
-- folds to its Heroic bucket; under the modern model the id is returned
-- unchanged. Used to choose the white vs gray dot colour in the browser.
local function ActiveDifficulty()
    return RR:FoldDifficulty(RR.currentRaid, RR.state and RR.state.currentDifficultyID)
end

-- Strict per-difficulty rollup state for an item:
--   missing  -> at least one bucket is missing
--   shared   -> no missing, at least one shared
--   collected -> all populated buckets collected
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

-- Main-panel transmog summary: "Transmog Needed:" header + per-
-- difficulty Missing/Shared counts. Zero in both -> "Complete" (green).
-- Numbers: 0 green, 1+ orange. Collapses to "All appearances
-- collected!" when every difficulty is done.
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
    local line1 = ("- Current (|cff%s%s|r): %s"):format(
        C_PINK_HEX, diffName, FormatStatsFragment(curNeeded, curShared))
    local othFrag = othTotal
        and FormatStatsFragment(othNeeded, othShared)
        or "|cff00ff00Complete|r"
    local line2 = ("- Other difficulties: %s  %s"):format(othFrag, clickHnt)
    return header .. "\n" .. line1 .. "\n" .. line2
end

-------------------------------------------------------------------------------
-- Per-difficulty dot row builder
-------------------------------------------------------------------------------

-- Per-item loot row builder. Item shape is intrinsic to its data:
--   * BINARY (1 unique source): renders as a single bracketed state
--     `[ ✓ ]` / `[ ~ ]` / `[ X ]` -- same grammar as Special Loot.
--   * PER-DIFFICULTY (2+ unique sources): the classic
--     `[ LFR | N | H | M ]` strip with each letter colored per state.
-- The "|" literal in the strip is escaped as "||" since WoW reads
-- "|r" as a reset-color sequence.
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
    if not item.sources then return nil end
    local bucketCount = 0
    local uniqueSources = {}
    for _, src in pairs(item.sources) do
        bucketCount = bucketCount + 1
        uniqueSources[src] = true
    end
    local uniqueCount = 0
    for _ in pairs(uniqueSources) do uniqueCount = uniqueCount + 1 end

    if uniqueCount == 0 then return nil end

    -- Binary shape: a single appearance across multiple buckets. Two
    -- ways the source data expresses this:
    --   (a) Single sourceID cloned across buckets -- e.g. Sepulcher's
    --       Gavel of the First Arbiter (all 4 diffs same source), or
    --       WoD N/H/M items where Normal/Heroic/Mythic all resolve
    --       to the same source.
    --   (b) Multiple sourceIDs that all resolve to ONE visualID. WoW's
    --       transmog system tracks per-(item x difficulty) acquisition
    --       paths even when they share a visual; Blackrock Foundry's
    --       The Black Hand has sourceIDs 62893 and 62895 both pointing
    --       at visual 23383. Blizzard's own appearance tab shows it as
    --       one appearance. Render as one bracket to match.
    -- 1-bucket items (e.g. WoD LFR-only {[17]=X}) deliberately don't
    -- qualify -- they render as "[ LFR ]" via the perdiff path, which
    -- cues the player to queue Raid Finder specifically.
    if bucketCount >= 2 then
        if uniqueCount == 1 then
            return "binary"
        end
        -- visualID equivalence path. Falls through to perdiff if any
        -- source's visualID is unresolved (cold cache); the next
        -- render after the cache warms reclassifies correctly.
        local seenAppearances = {}
        local apCount = 0
        local allResolved = true
        for _, src in pairs(item.sources) do
            local ap = GetAppearanceIDForSource(src)
            if not ap then
                allResolved = false
                break
            end
            if not seenAppearances[ap] then
                seenAppearances[ap] = true
                apCount = apCount + 1
            end
        end
        if allResolved and apCount == 1 then
            return "binary"
        end
    end

    return "perdiff"
end

-- Glyphs for the binary-shape bracketed indicator. Collected uses
-- ReadyCheck-Ready (native green). Missing uses ReadyCheck-NotReady
-- (native red X) to match the rest of the addon -- Skips, Achievements,
-- and Special Loot all use the same texture for "uncollected / locked /
-- incomplete." The shared glyph uses UI-CheckBox-Check (grayscale)
-- tinted gold rather than ReadyCheck-Ready (native green, can't shift
-- to gold).
local BINARY_GLYPH_COLLECTED = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local BINARY_GLYPH_SHARED    = "|TInterface\\Buttons\\UI-CheckBox-Check:14:14:0:0:32:32:0:32:0:32:255:215:0|t"
local BINARY_GLYPH_MISSING   = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14|t"

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
-- Falls back to FallbackStateForItem when sources is nil/empty so an entry
-- missing that field renders safely instead of crashing BinaryStateRendering.
local function BuildBinaryRow(item)
    local debugEnabled = RR:GetSetting("debug")
    local state

    -- Every source of a binary item resolves to the same visualID, but the
    -- sources do NOT share one per-source collected state: WoW tracks each
    -- (item x difficulty) source's acquisition independently. A player who
    -- looted the Mythic source has THAT source directly collected, while the
    -- Normal/Heroic sources stay uncollected -- the appearance is owned, so
    -- those read "shared" rather than "collected". Picking one arbitrary
    -- source (pairs order is undefined) would report "shared" (gold)
    -- whenever the pick landed on an uncollected source, even though the
    -- player collected this very item on another difficulty and it should
    -- read "collected" (green).
    --
    -- Fold across every source and keep the strongest state:
    --   collected (green) > shared (gold) > missing (red).
    -- "collected" means at least one of THIS item's own sources is directly
    -- known; "shared" means none are, but the appearance is owned via some
    -- other item; "missing" means the look isn't owned at all.
    if item.sources then
        local best = "missing"
        for _, s in pairs(item.sources) do
            local st = CollectionStateForSource(s, item.id)
            if st == "collected" then
                best = "collected"
                break
            elseif st == "shared" then
                best = "shared"
            end
        end
        state = best
    else
        -- sources nil/empty (hand-edited data file missing the field);
        -- without this BinaryStateRendering would crash on state=nil.
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
        local src = item.sources and item.sources[diffID]
        -- Skip empty buckets. WoD-era split-loot-table raids have items
        -- with only 1 bucket ({[17]} for LFR pool) or 3 buckets ({[14],
        -- [15], [16]} for N/H/M pool); rendering iterates only over
        -- the diffs the item actually drops at.
        if src then
            local letter = DIFF_LETTER[diffID]
            local colour

            local state = CollectionStateForSource(src, item.id)

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
                if state == "missing" or state == "shared" then
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

-- Builds the Covenant Sanctum vendor hint line for the Tmog popup.
-- Returns (text, raid, covID, vendorInfo); text is nil if the boss
-- doesn't drop tokens or the raid has no weaponVendors. The Flight
-- button anchors to this FontString.
local function BuildSanctumLine(raid, boss)
    if not raid or not raid.weaponVendors or not boss then
        return nil
    end
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

-- Renders the transmog detail body. Accepts {boss=...} or {bossIndex=N}.
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

    -- Bucket candidates by shape: binary first (rare: single-appearance
    -- multi-difficulty items like Sepulcher's Gavel of the First Arbiter),
    -- then everything else under "perdiff" which renders adaptively over
    -- whatever buckets are populated.
    --
    -- Within perdiff, sort by bucket count ascending then name. This puts
    -- WoD-era LFR-only items (1 bucket: { [17] }) first, then WoD N/H/M
    -- items (3 buckets: { [14], [15], [16] }), then full 4-bucket items
    -- (Legion+ per-difficulty raids). The grouping reads naturally as
    -- "shorter strips at the top" without needing an explicit sub-header.
    local binaryItems  = {}
    local perDiffItems = {}
    for _, item in ipairs(candidates) do
        if ItemShape(item) == "binary" then
            table.insert(binaryItems, item)
        else
            table.insert(perDiffItems, item)
        end
    end
    local function bucketCount(item)
        local n = 0
        for _ in pairs(item.sources or {}) do n = n + 1 end
        return n
    end
    -- A stable signature of which difficulty buckets an item drops from, so
    -- items with the same bucket count cluster by their actual difficulties
    -- rather than interleaving alphabetically. For WoD split-loot bosses this
    -- keeps the single-bucket group from mixing Normal-only ({[14]}) items in
    -- with the Raid Finder ({[17]}) pool -- they share bucketCount 1 but are
    -- different drop sources and shouldn't be intermingled. Lower difficulty
    -- IDs sort first (Normal 14 before LFR 17).
    local function bucketSignature(item)
        local ids = {}
        for diffID in pairs(item.sources or {}) do ids[#ids + 1] = diffID end
        table.sort(ids)
        return table.concat(ids, ",")
    end
    table.sort(binaryItems, function(a, b) return (a.name or "") < (b.name or "") end)
    -- Tier rows (those carrying `item.classes`) sort as a block ABOVE the
    -- regular gear, ordered by class ID then name. Regular (non-tier) rows
    -- keep the bucket-count -> signature -> name ordering. This makes the
    -- tier separation deliberate across every tier raid rather than an
    -- incidental side effect of tier's bucket signature differing from
    -- regular gear (which only happened to cluster on raids like SoO whose
    -- tier has a 3-bucket shape distinct from 4-bucket regular drops).
    local function isTier(item)
        return item.classes and #item.classes > 0
    end
    table.sort(perDiffItems, function(a, b)
        local ta, tb = isTier(a), isTier(b)
        if ta ~= tb then return ta end           -- tier block first
        if ta then
            -- Within tier: class ID ascending, then name.
            local ka = a.classes[1] or 0
            local kb = b.classes[1] or 0
            if ka ~= kb then return ka < kb end
            return (a.name or "") < (b.name or "")
        end
        -- Within regular gear: shorter bucket strips first, then a stable
        -- difficulty signature, then name.
        local ca, cb = bucketCount(a), bucketCount(b)
        if ca ~= cb then return ca < cb end
        local sa, sb = bucketSignature(a), bucketSignature(b)
        if sa ~= sb then return sa < sb end
        return (a.name or "") < (b.name or "")
    end)

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

    -- Emit per-difficulty group. Items are pre-sorted by bucket count
    -- ascending, then by bucket signature, so groups separate by both shape
    -- and difficulty: for WoD split-loot bosses the single-bucket Normal-only
    -- ({[14]}) items and the Raid Finder ({[17]}) pool each get their own
    -- block with a blank line between, then the 3-bucket N/H/M items, then
    -- any full 4-bucket items -- no explicit sub-headers needed.
    local lastSignature
    for _, item in ipairs(perDiffItems) do
        local sig = bucketSignature(item)
        if lastSignature and sig ~= lastSignature then
            table.insert(lines, "")
        end
        lastSignature = sig
        table.insert(lines, FormatItemRow(item))
        MaybeAppendAcquisitionNote(item)
    end

    -- Weapon-token section (Castle Nathria, Sanctum of Domination).
    -- Tokens are covenant-partitioned in ways the data doesn't capture,
    -- so each slot renders as 3-state (none/some/all) rather than an
    -- inaccurate X/N ratio.
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
        -- Walk this boss's token drops. For each match, attribute the
        -- token to its slot ("Main-Hand" / "Off-Hand") and collect
        -- the union of classes that family is usable by. A single
        -- boss can drop tokens from multiple families that share a
        -- slot (e.g. Sire Denathrius drops all 4 Main-Hand families);
        -- the per-slot class set unions across them.
        local slotClasses = {}   -- ["Main-Hand"] = { [classID]=true, ... }
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
                if info and info.slotLabel and info.classes then
                    local bucket = slotClasses[info.slotLabel]
                    if not bucket then
                        bucket = {}
                        slotClasses[info.slotLabel] = bucket
                    end
                    for _, classID in ipairs(info.classes) do
                        bucket[classID] = true
                    end
                end
            end
        end

        local slotOrder = { "Main-Hand", "Off-Hand" }

        -- Builds the class-list suffix for a slot's class set. WoW
        -- exposes class IDs 1..13 in canonical UI order (1=Warrior,
        -- 2=Paladin, ..., 13=Evoker). Each name renders in its
        -- standard class color (paladin pink, mage cyan, etc.) via
        -- RAID_CLASS_COLORS. When the slot's union covers every class
        -- that has weapon access at that slot for this raid (4 of 4
        -- Main-Hand families = all 13 classes, or 2 of 2 Off-Hand
        -- families = 9 classes), the heading collapses to "All
        -- classes" instead of an unwieldy colored list.
        local function FormatClassList(classSet, slotLabel)
            local ids = {}
            for cid in pairs(classSet) do table.insert(ids, cid) end
            table.sort(ids)
            local allCount = (slotLabel == "Main-Hand") and 13 or 9
            if #ids >= allCount then
                return "All classes"
            end
            local parts = {}
            for _, cid in ipairs(ids) do
                local n = GetClassInfo and GetClassInfo(cid)
                if n then
                    local hex
                    local token = CLASS_ID_TO_TOKEN[cid]
                    if token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token] then
                        local c = RAID_CLASS_COLORS[token]
                        if c.colorStr then hex = c.colorStr end
                    end
                    if hex then
                        table.insert(parts, ("|c%s%s|r"):format(hex, n))
                    else
                        table.insert(parts, n)
                    end
                end
            end
            return table.concat(parts, " / ")
        end

        local tokenRows = {}
        for _, slot in ipairs(slotOrder) do
            local classSet = slotClasses[slot]
            if classSet and next(classSet) then
                local label = ("%s Weapon Token: %s"):format(
                    slot, FormatClassList(classSet, slot))
                table.insert(tokenRows, ("|cffffffff%s|r"):format(label))
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

    -- Optional per-boss footnote(s). Accepts three forms:
    --   string                   -- rendered as-is
    --   { text=..., itemID=N }   -- {item} -> WoW item link
    --   { {text=...,itemID=N}, ... }   -- list of entries
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
                -- Cold-cache fallback: bracketed name, loses clickability
                -- for this render only.
                local fallbackName = (entry.itemID and GetItemInfo(entry.itemID))
                                     or "(item)"
                sub = ("|cffa335ee[%s]|r"):format(fallbackName)
            end
            return (entry.text or ""):gsub("{item}", sub)
        end

        -- Single entry vs list: a list has numeric indices, no top-level
        -- `text` field.
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

    return table.concat(lines, "\n")
end

-- Color legend rendered as the bottom-most line in the Tmog window. The
-- dot colors mean the same thing whether or not the player is in a
-- supported raid, so it sits below the per-boss content and the
-- weapon-token redemption hint (when present), as a global footer.
local function BuildTmogLegendText()
    return
        ("|c%sgreen|r|cff888888 = collected      |r|c%sgold|r|cff888888 = via another item|r\n"):format(
            DOT_COLLECTED, DOT_SHARED)
     .. ("|c%swhite|r|cff888888 = needed (current difficulty)  |r|c%sgray|r|cff888888 = not collected|r"):format(
            DOT_ACTIVE, DOT_INACTIVE)
end

-------------------------------------------------------------------------------
-- Transmog browser: data enumeration
-------------------------------------------------------------------------------

-- Expansion ordering for the transmog browser's dropdown. Newest
-- first; within each expansion, raids sort by patch descending via
-- patchDescending
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
        -- Skip incomplete entries (instanceID = 0); they have no resolved
        -- journal IDs and would render as all-dash pills.
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

-- Dropdown label suffix. Currently a no-op; the three browser dropdowns
-- (expansion, raid, boss) render their entries without a per-entry count.
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

-- Tmog-browser cache-warm pass: GetItemInfo on every loot/specialLoot
-- item in the selected raid so first-render produces real item links
-- instead of plain-text fallbacks. Called on every RefreshAll.
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
    --
    -- Gap to main text is tight (-2) so the redeem line reads as
    -- the continuation of the weapon-token heading it sits beneath,
    -- rather than as a separate paragraph.
    local sanctumLine = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sanctumLine:SetPoint("TOPLEFT",  text, "BOTTOMLEFT",  0, -2)
    sanctumLine:SetPoint("TOPRIGHT", f,    "TOPRIGHT",   -14, 0)   -- width only
    sanctumLine:SetJustifyH("LEFT")
    sanctumLine:SetJustifyV("TOP")
    sanctumLine:SetWordWrap(true)
    sanctumLine:Hide()
    f.sanctumLine = sanctumLine

    -- Color legend. Lives at the bottom of the window as a global
    -- footer. Anchored just below the sanctum line so the redemption
    -- hint (when present) sits between the per-boss content and the
    -- legend. When the sanctum line is hidden, RefreshContent
    -- re-anchors the legend directly under the main text so the
    -- vertical gap doesn't double.
    local legendLine = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    legendLine:SetPoint("TOPLEFT",  sanctumLine, "BOTTOMLEFT",  0, -8)
    legendLine:SetPoint("TOPRIGHT", f,           "TOPRIGHT",   -14, 0)
    legendLine:SetJustifyH("LEFT")
    legendLine:SetJustifyV("TOP")
    legendLine:SetWordWrap(true)
    f.legendLine = legendLine

    -- Flight button anchored against the sanctum line's RENDERED text
    -- width (GetStringWidth, not the FontString's frame width which
    -- spans the popup). Uses the FlightMaster minimap-tracking texture
    -- (the idle-list entrance buttons moved to the custom PlaneIcon, but
    -- this sanctum vendor button keeps the stock glyph). Hidden by
    -- default; RefreshContent decides whether to show it based on whether
    -- the player's covenant has a vendor entry with concrete coords.
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
                -- Anchor against the line's rendered text width. The
                -- one-frame deferral works around GetStringWidth being
                -- lazy after SetFont -- needed here because
                -- RefreshContent only fires on dropdown change.
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

        -- Legend: always rendered. Re-anchored so it sits directly
        -- below whichever widget above it is visible -- under the
        -- sanctum line when that's shown, otherwise directly under
        -- the main text. Keeps the gap consistent (8px) in either
        -- case rather than doubling when sanctum is hidden.
        SetBodyFont(legendLine, fontSize - 1, "")
        legendLine:SetText(BuildTmogLegendText())
        legendLine:ClearAllPoints()
        if sanctumLine:IsShown() then
            legendLine:SetPoint("TOPLEFT",  sanctumLine, "BOTTOMLEFT",  0, -8)
        else
            legendLine:SetPoint("TOPLEFT",  text,        "BOTTOMLEFT",  0, -8)
        end
        legendLine:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, 0)

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
    --
    -- Tier tokens aren't the only class-restricted loot, though: some
    -- raids (WoD's Blackrock Foundry, Highmaul) drop class-specific armor
    -- pieces tagged with a `classes` field but no tier-set membership
    -- (e.g. Blackhand's Faceguard, Warrior-only). Those are hidden for
    -- off-class players by ItemIsForPlayer just like tier rows, so the
    -- "show all" toggle must be live for them too. Enable the toggle when
    -- the boss has tier tokens OR any class-restricted loot item.
    f.RefreshShowAllCheckEnabled = function(self)
        local raid, boss = GetBrowserSelection()
        local hasClassFiltered = false
        if raid and boss then
            if raid.tierSets and raid.tierSets.tokenSources then
                for _, bossIdx in pairs(raid.tierSets.tokenSources) do
                    if bossIdx == boss.index then
                        hasClassFiltered = true
                        break
                    end
                end
            end
            if not hasClassFiltered and boss.loot then
                for _, item in ipairs(boss.loot) do
                    if item.classes then
                        hasClassFiltered = true
                        break
                    end
                end
            end
        end
        if hasClassFiltered then
            showAllCheck:Enable()
            showAllCheck:SetAlpha(1.0)
            showAllCheck.text:SetTextColor(1, 1, 1)
        else
            showAllCheck:Disable()
            showAllCheck:SetAlpha(0.45)
            showAllCheck.text:SetTextColor(0.5, 0.5, 0.5)
        end
    end

    -- Realtime collection-state refresh, debounced 50ms. The per-render
    -- appearance cache (in BuildTransmogDetail) auto-clears on next render.
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

-- Force a content refresh of the tmog window if it's open. Used by the
-- settings body-font control: ApplySettings deliberately does NOT refresh the
-- tmog window on its heartbeat tick (that caused a once-per-second reflow), so
-- a font-family change has to repaint it explicitly.
function UI.RefreshTmogWindowIfShown()
    if tmogWindow and tmogWindow:IsShown() and tmogWindow.RefreshContent then
        tmogWindow:RefreshContent()
    end
end

-- Update the centered footer "Toaster:" arrow to match the live state:
-- green up = active (enabled + in a supported raid), amber down = enabled but
-- not in a supported raid, red down = disabled. Mirrors the settings panel's
-- Active Status so both surfaces agree. Safe to call any time.
function UI.RefreshFooterToasterStatus()
    local f = panel.toastStatus
    if not f or not f.arrow then return end
    local enabled = RR:GetSetting("toasterEnabled", false) ~= false
    local inRaid  = RR.currentRaid ~= nil
    local color, up
    if not enabled then
        color, up = { 0.95, 0.35, 0.35 }, false   -- red, down
    elseif inRaid then
        color, up = { 0.40, 0.90, 0.45 }, true     -- green, up
    else
        color, up = { 1.00, 0.55, 0.20 }, false    -- amber, down
    end
    f.arrow:SetRotation(up and math.pi or 0)       -- asset points down natively
    f.arrow:SetVertexColor(color[1], color[2], color[3])
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
    -- Apply current scale before showing so the first visible state matches
    -- the user's saved windowScale rather than rendering at the frame's
    -- construction-time default of 1.0. Skips and achievements apply scale
    -- at their open sites the same way.
    local scale = RR:GetSetting("windowScale", 1.0)
    w:SetScale(scale)
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

-- Dump tmog window sizing geometry. Used for diagnosing visible blank
-- space (popup ends up taller than rendered content) or content clip
-- (legend extends past the frame bottom). Tmog window must be open;
-- caller is expected to select the boss they want to measure before
-- running the probe.
function UI.DumpTmogSize()
    local lines = {}
    local function add(s) table.insert(lines, s or "") end

    if not tmogWindow then
        add("Tmog window not constructed yet. Open the tmog browser first.")
        RR:ShowCopyWindow("tmogsize", table.concat(lines, "\n"))
        return
    end
    if not tmogWindow:IsShown() then
        add("Tmog window not shown. Open the tmog browser first.")
        RR:ShowCopyWindow("tmogsize", table.concat(lines, "\n"))
        return
    end

    local text        = tmogWindow.contentText
    local sanctumLine = tmogWindow.sanctumLine
    local legendLine  = tmogWindow.legendLine

    local fScale = tmogWindow:GetScale() or 1
    local fTop   = tmogWindow:GetTop() or 0
    local fBot   = tmogWindow:GetBottom() or 0
    local fH     = tmogWindow:GetHeight() or 0

    add(("Frame: scale=%.2f  height=%.1f  top=%.1f  bottom=%.1f"):format(
        fScale, fH, fTop, fBot))

    local function widgetSummary(label, w)
        if not w then add(("  %s: nil"):format(label)); return end
        local shown = w:IsShown() and "shown" or "HIDDEN"
        local top   = w:GetTop()    or 0
        local bot   = w:GetBottom() or 0
        local h     = w:GetHeight() or 0
        local sh    = (w.GetStringHeight and w:GetStringHeight()) or -1
        add(("  %s [%s]: height=%.1f  stringHeight=%.1f  top=%.1f  bottom=%.1f"):format(
            label, shown, h, sh, top, bot))
    end

    widgetSummary("text",        text)
    widgetSummary("sanctumLine", sanctumLine)
    widgetSummary("legendLine",  legendLine)

    -- Mirror the AutoSize calculation so we can compare against actual.
    -- Must match AutoSize exactly: rendered size is fontSize-1 (RefreshContent
    -- renders the body at fontSize-1), and the per-line pad is +0.5.
    local fontSize     = RR:GetSetting("fontSize", 12)
    local renderedSize = math.max(8, fontSize - 1)
    local bodySize     = GetBodyFontSize and GetBodyFontSize(renderedSize) or renderedSize
    local lineHeight   = bodySize + 0.5
    local content    = (text and text:GetText()) or ""
    local lineCount  = 1
    for _ in content:gmatch("\n") do lineCount = lineCount + 1 end
    local textH = lineCount * lineHeight

    local sanctumH = 0
    if sanctumLine and sanctumLine:IsShown() then
        sanctumH = lineHeight + 2
    end
    local legendH = 2 * lineHeight + 8

    local chrome = 32 + (3 * 32 - 8) + 10 + 14
    local desired = chrome + textH + sanctumH + legendH

    add("")
    add("AutoSize math:")
    add(("  fontSize=%d  bodySize=%d  lineHeight=%d"):format(
        fontSize, bodySize, lineHeight))
    add(("  text lineCount (newline-counted) = %d"):format(lineCount))
    add(("  textH (calculated) = %d"):format(textH))
    add(("  sanctumH = %d"):format(sanctumH))
    add(("  legendH = %d"):format(legendH))
    add(("  chrome = 32 + 88 + 10 + 14 = %d"):format(chrome))
    add(("  desired = chrome + textH + sanctumH + legendH = %d"):format(desired))
    add(("  set frame height = %.1f"):format(fH))

    -- Geometry comparison: where does the last visible widget actually
    -- end vs where the frame ends?
    local lastBot = legendLine and legendLine:GetBottom()
    if sanctumLine and sanctumLine:IsShown() then
        -- Legend is anchored under sanctumLine when sanctum shows;
        -- legend is still the lowest widget either way.
    end
    if lastBot and fBot then
        local gap = lastBot - fBot
        add("")
        add(("Visible gap below legend = %.1f px"):format(gap))
        add("  (positive = blank space below legend, negative = legend clipped past frame)")
    end

    RR:ShowCopyWindow("tmogsize", table.concat(lines, "\n"))
end

-- ----------------------------------------------------------------------------
-- Shared raid-skip presentation pieces
--
-- Used by both the idle-state list (where the marker appears next to
-- raid names with the skip unlocked) and the skips window (where the
-- marker headlines each unlocked raid). Defined here so both consumers
-- pick up the same glyph rules.
-- ----------------------------------------------------------------------------

-- Skip-unlocked marker: yellow raid-target star, same texture used for
-- Fyrakk's portal POI. Three states for the leading raid-row marker:
--   SKIP_MARKER_LED      -- gold: skip unlocked on this account
--   SKIP_MARKER_LED_DIM  -- dim: skip exists but not yet unlocked
--   SKIP_MARKER_LED_NONE -- transparent: no skip mechanic; reserves
--                           column width so rows align.
local SKIP_MARKER_LED      = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12|t"
local SKIP_MARKER_LED_DIM  = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12:0:0:64:64:0:64:0:64:80:80:80|t"
local SKIP_MARKER_LED_NONE = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12:0:0:64:64:0:64:0:64:0:0:0:0|t"
-- Row variants: the idle-list raid rows render at the body font (12+),
-- the legend at LEGEND_FONT_SIZE (10), so the same texture px reads
-- larger on the rows. These row markers are sized down to land at the
-- legend star's apparent size at the default font.
local SKIP_MARKER_ROW      = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:10|t"
local SKIP_MARKER_ROW_DIM  = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:10:0:0:64:64:0:64:0:64:80:80:80|t"
local SKIP_MARKER_ROW_NONE = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:10:0:0:64:64:0:64:0:64:0:0:0:0|t"

-- Inline texture marker matching the entrance-navigation buttons (the
-- custom PlaneIcon, tinted RETRO pink via the extended texture-markup
-- RGB params 242,89,199 = the 0.95/0.35/0.78 brand pink scaled to 0-255).
-- The full-texture coords (0:64:0:64) plus trailing R:G:B tint the white
-- silhouette without cropping it.
local ENTRANCE_MARKER =
    "|TInterface\\AddOns\\RetroRuns\\Media\\PlaneIcon:12:12:0:0:64:64:0:64:0:64:242:89:199|t"

-- Skip-legend footer line. Explains the gold star; dim and invisible
-- variants don't need explicit legend coverage.
local IDLE_SKIP_LEGEND =
    "|cff9d9d9d" .. SKIP_MARKER_LED .. " = skip unlocked -- check Skips for details|r"

-- Footer legend below the supported-raids list. Two lines:
--   Routing: <Zygor|Mapzeroth|None> [with AWP Orchestration]
--   Waypoint: <TomTom|Native> [with 3D Overlay from <names>]
-- Rebuilt on every render so a /reload picks up newly installed addons.
local function BuildEntranceLegend()
    local LIT_HEX  = "ffffff"  -- active provider names
    local LBL_HEX  = "9d9d9d"  -- labels, connectors, prepositions
    local WARN_HEX = "ff4040"  -- soft-warning text (Zygor arrow off)

    local function lit(s) return ("|cff%s%s|r"):format(LIT_HEX, s) end
    local function lbl(s) return ("|cff%s%s|r"):format(LBL_HEX, s) end
    local function warn(s) return ("|cff%s%s|r"):format(WARN_HEX, s) end

    local awpInst       = RR:IsAWPInstalled()
    local zygorInst     = RR:IsZygorInstalled()
    local mapzerothInst = RR:IsMapzerothInstalled()
    local wuiInst       = RR:IsWUIInstalled()
    local tomtomInst    = RR:IsTomTomInstalled()

    -- ROUTING line. Zygor wins ties over Mapzeroth (mirrors the
    -- cascade in NavigateToEntrance). "None" surfaces when neither
    -- planner is installed -- explicit empty state, no install hint
    -- inline (kept terse).
    --
    -- Zygor-specific soft-fail: when Zygor is installed but the user
    -- has the waypoint arrow turned off in Zygor's settings, the
    -- dispatch still picks Zygor (presence-only design) but Zygor
    -- produces no visible waypoint. We surface that here so the
    -- dead-click cause is visible BEFORE the user clicks. The warning
    -- itself is a clickable hyperlink (retroruns:zygor_arrow, handled
    -- at the panel-level OnHyperlinkClick) -- a click enables Zygor's
    -- arrow setting and re-renders this legend so the warning
    -- disappears immediately.
    local routingActive
    if zygorInst then
        routingActive = lit("Zygor")
        if not RR:IsZygorArrowEnabled() then
            routingActive = routingActive .. " " .. warn(
                "|Hretroruns:zygor_arrow|h[Waypoint Arrow Disabled - Click to Enable]|h")
        end
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
-- Account-wide raid skip status. Lazy-built framed window mirroring
-- the Tmog browser's pattern; pure read-only, no caching.
-- Each raid line shows the cascade ceiling (Mythic -> Heroic -> Normal).
-- ----------------------------------------------------------------------------

-- Sizing constants for the skips window. Wrapped in do/end to keep
-- supporting locals out of UI.lua's top-level scope (Lua 5.1 caps
-- local-variable count at 200 per function;
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
-- visually centered. Offsets are tuned for SKIPS_WINDOW_WIDTH=400.
--
-- Difficulty order: Mythic / Heroic / Normal (left to right). Hardest
-- first matches a player's typical mental model when checking "do I have
-- skips for this raid" -- they look at Mythic first, eye left to right
-- as the answer cascades up through difficulties. Cascade order means
-- a partial unlock visually stacks checks on the left side of the row,
-- with Normal leftmost and Mythic rightmost (traditional progression).
local SKIPS_COL_NAME_X     = 14
-- Info-button column. All [i] icons in raidRow rendering anchor to
-- this fixed x so they form a vertical column right of the longest
-- raid name and left of the leftmost difficulty column (Normal). Sits
-- 35px left of NORMAL_X to clear multi-chain raids (Antorus) whose
-- leftmost cell splits into two glyphs at the column x +/- pairOffset
-- (the leftmost glyph lands at x=230 with pairOffset=10).
local SKIPS_COL_INFO_X     = 205
local SKIPS_COL_NORMAL_X   = 240
local SKIPS_COL_HEROIC_X   = 300
local SKIPS_COL_MYTHIC_X   = 360

-- Per-row vertical spacing. Driven by font size at refresh time; this
-- is the multiplier (rendered line-height = fontSize * SKIPS_LINE_GAP).
local SKIPS_LINE_GAP       = 1.7

-- Divider offset from the row's bottom edge. Positive value moves the
-- divider UP into the row band (toward the text), set so the row text +
-- glyphs sit visually centered between two consecutive dividers. With
-- SKIPS_LINE_GAP = 1.7 and fontSize=12, lineHeight is ~20px; the
-- FontString has a few px of internal
-- top-padding, so the divider needs to sit a few px above the bottom
-- of the band to make the text appear centered.
local SKIPS_ROW_DIVIDER_INSET = 5

-- Glyphs for difficulty cells. Reuse the existing visual vocabulary
-- (ReadyCheck-Ready green check / ReadyCheck-NotReady red X) so the
-- meaning is consistent with how collected/uncollected appearances
-- are rendered elsewhere in the addon. Both textures are natively
-- 14x14 from the RaidFrame family so column widths stay even.
-- Skips-window cell glyphs. Each per-difficulty cell paints one of
-- these. The dots form a severity ramp:
--   Gray    N/A      -- no skip exists at this difficulty
--   White   Locked   -- skip exists here, not yet unlocked
--   Green   Unlocked -- unlocked at this difficulty
-- Rendered from the white StatusDot texture vertex-tinted per state, so
-- they're font-independent (a typographic bullet renders as a missing
-- glyph in pixel fonts like VT323).
local function StatusDotGlyph(r, g, b)
    return ("|TInterface\\AddOns\\RetroRuns\\Media\\StatusDot:10:10:0:0:64:64:0:64:0:64:%d:%d:%d|t"):format(r, g, b)
end
local SKIPS_CELL_NA       = StatusDotGlyph(80, 80, 80)
local SKIPS_CELL_LOCKED   = StatusDotGlyph(255, 255, 255)
local SKIPS_CELL_UNLOCKED = StatusDotGlyph(51, 204, 85)
-- Unknown state: used by the Siege of Orgrimmar Garrosh scroll when no
-- account-wide achievement proves a kill and the current character's
-- kill statistics are all zero. The skip may still be unlocked by a kill
-- on another character that left no readable account-wide trace, so this
-- communicates "can't determine" rather than locked. Shrunk to ~dot size
-- so it reads as one entry in the same glyph ramp.
local SKIPS_CELL_UNKNOWN  = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:10:10|t"


local GetOrCreateSkipsWindow

-- Build a structured row list for the skips window. Row kinds:
--   { kind = "expansionHeader", text = ... }
--   { kind = "raidRow", name = ..., mythic/heroic/normal = bool, ... }
--     -- Multi-chain raids carry mythic2/heroic2/normal2 too.
--   { kind = "spacer" }
--   { kind = "message", text = ... }
-- Raids with no skip mechanism are silently omitted.
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
        -- Skip incomplete entries (instanceID = 0); they have no resolved
        -- journal IDs and would render as all-dash pills.
        if raid.instanceID and raid.instanceID > 0 then
            -- Faction-aware swap: a Horde player with Horde-specific data
            -- for a raid (currently only BfD) uses that instead of the
            -- shared Alliance copy, so the skip trigger names the correct
            -- faction's NPC. Mirrors BuildIdleListRows.
            local resolved = RR:GetRaidByInstanceID(raid.instanceID) or raid
            local exp = resolved.expansion or "Unknown"
            if not byExp[exp] then
                byExp[exp] = {}
                table.insert(expOrder, exp)
            end
            table.insert(byExp[exp], resolved)
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

    -- Session-scoped expand state, mirroring the idle list's expansion
    -- collapse (RR.state.expandedExpansions) but kept in a separate table
    -- so the two windows collapse independently. The table holds explicit
    -- user choices only: true = user expanded, false = user collapsed,
    -- nil = no explicit choice yet.
    --
    -- Default for an expansion with no explicit choice is collapsed --
    -- EXCEPT the expansion of the raid the player is currently in, which
    -- auto-expands. That auto-open is a live check against RR.currentRaid
    -- (not a stored seed), so it follows the player: zoning out of a raid
    -- drops currentRaid and the section collapses again on the next
    -- refresh. A manual collapse still wins (the explicit false in the
    -- table overrides the auto-open) so the user can close the current
    -- raid's section if they want.
    -- Session-scoped expand state. true = user expanded, false/nil =
    -- collapsed. Single-expand accordion, matching the idle list: opening
    -- one section closes the others, but a section never auto-opens, so
    -- the clicked +/- button keeps its screen position across a refresh
    -- (nothing above the click changes height). Spam-clicking the same
    -- toggle stays under the cursor.
    local expandedState = (RR.state and RR.state.skipsExpandedExpansions) or {}
    local function isExpanded(exp)
        return expandedState[exp] == true
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
            -- Raids without any skip mechanic configured are omitted;
            -- there's no useful "no skip data" row for raids the player
            -- can't skip into anyway.
            if RR:RaidHasSkipMechanic(raid) then
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
                    if raid.skipGarrosh then
                        -- Garrosh scroll: per-difficulty states are not a
                        -- simple cascade from one ceiling (Normal can be
                        -- "unknown" while Heroic is not-confirmed), so the
                        -- cells come straight from the four-tier resolver.
                        mCell, hCell, nCell = RR:GetGarroshSkipStates(raid)
                    elseif cascading then
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
        -- to anchor under it. The raidRows render only when the
        -- expansion is expanded (collapse mirrors the idle list); the
        -- header always emits so the toggle stays reachable.
        if #expRows > 0 then
            local expd = isExpanded(exp)
            add({ kind = "expansionHeader", text = exp, expanded = expd })
            if expd then
                for _, row in ipairs(expRows) do add(row) end
            end
            -- Tag the spacer with the collapse state so the renderer can
            -- use a tight gap between collapsed headers (matching the
            -- main-UI list) and a normal gap below an expanded block.
            add({ kind = "spacer", collapsed = not expd })
        end
    end

    -- Drop trailing spacer.
    if rows[#rows] and rows[#rows].kind == "spacer" then
        rows[#rows] = nil
    end

    return rows
end

-- Expansion-toggle buttons for the Skips window. Same one-piece
-- button-IS-the-glyph design as the idle list's expansion toggles
-- (the button owns its +/- texture and anchors to the header
-- FontString, so it can't desync from the rendered text). Pooled and
-- recycled per refresh; parented to the skips window, set lazily on
-- first use since skipsWindow doesn't exist at module load.
local skipsToggleButtons = {}
local skipsToggleButtonPool = {}

local function AcquireSkipsToggleButton(parent)
    local btn = table.remove(skipsToggleButtonPool)
    if btn then return btn end
    btn = CreateFrame("Button", nil, parent)
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetFrameLevel((parent:GetFrameLevel() or 0) + 10)
    return btn
end

local function SetSkipsToggleTextures(btn, expanded)
    if expanded then
        btn:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
        btn:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
    else
        btn:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
        btn:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
    end
    btn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
end

local function ReleaseSkipsToggleButtons()
    for _, btn in ipairs(skipsToggleButtons) do
        btn:Hide()
        btn:SetScript("OnClick", nil)
        btn:ClearAllPoints()
        table.insert(skipsToggleButtonPool, btn)
    end
    wipe(skipsToggleButtons)
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
    -- text authored. Click opens the skip-detail frame with the trigger
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
    ReleaseSkipsToggleButtons()

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
    -- Tighter pitch for expansion-header rows so the collapsed list packs
    -- like the main-UI idle list (text height + a small gap) instead of
    -- the looser content-row pitch. ~font height plus a 4px breath.
    local headerPitch = math.floor(GetBodyFontSize(fontSize) + 0.5) + 4

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
            -- Four leading spaces reserve room for the toggle button
            -- glyph anchored at the FontString's LEFT, matching the idle
            -- list exactly. Two spaces (an earlier attempt) left the
            -- button overlapping the first letter. The button is sized
            -- to the font height and anchored to LEFT, so the reserved
            -- run of spaces keeps the visible label from shifting whether
            -- the button shows +/- or the row expands/collapses.
            slot.expHeader:SetText(("    |cff00ffff%s|r"):format(row.text))
            slot.expHeader:ClearAllPoints()
            slot.expHeader:SetPoint("TOPLEFT", w, "TOPLEFT", SKIPS_COL_NAME_X, y)
            slot.expHeader:Show()

            -- Toggle button: square at the font height, anchored to the
            -- LEFT of the header FontString so it tracks the text with no
            -- line-stride drift (identical to PositionExpansionToggleButton
            -- in the idle list). Click flips collapse state and rebuilds.
            local exp = row.text
            local shown = row.expanded
            local btn = AcquireSkipsToggleButton(w)
            btn:SetSize(rowFontSize, rowFontSize)
            SetSkipsToggleTextures(btn, shown)
            btn:ClearAllPoints()
            btn:SetPoint("LEFT", slot.expHeader, "LEFT", 0, 0)
            btn:SetScript("OnClick", function()
                RR.state = RR.state or {}
                -- Single-expand accordion, identical to the idle list:
                -- close everything, then re-open the clicked section
                -- unless it was already open (click-to-collapse).
                local already = RR.state.skipsExpandedExpansions
                                and RR.state.skipsExpandedExpansions[exp]
                RR.state.skipsExpandedExpansions = {}
                if not already then
                    RR.state.skipsExpandedExpansions[exp] = true
                end
                RefreshSkipsContent()
            end)
            btn:Show()
            table.insert(skipsToggleButtons, btn)
            -- Header rows use a tighter pitch than content rows so the
            -- collapsed list reads as a compact stack of expansion names,
            -- matching the main-UI idle list (which packs headers at
            -- text-height + a small gap). The full 1.7x lineHeight is
            -- only needed for content rows, where it gives the per-row
            -- highlight/divider bands room. headerPitch ~= font height
            -- plus a few px.
            y = y - headerPitch

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
                -- Anchor to the window (not to slot.name's FontString) so
                -- the button's hit rect lives on the same coord grid as
                -- the rest of the clickable children. Button is 28 wide;
                -- anchor TOPLEFT at (INFO_X - 14, y) to center on INFO_X.
                -- y+2 lifts the glyph so its center aligns with the row
                -- name's visual midline -- the button's GameFontHighlightSmall
                -- glyph centers at y-8 (button is 16 tall), while the row
                -- name's body-font text sits higher in its line-box.
                slot.infoBtn:SetPoint("TOPLEFT", w, "TOPLEFT",
                    SKIPS_COL_INFO_X - 14, y + 2)
                slot.infoBtn:SetFrameLevel(w:GetFrameLevel() + 2)
                local raidRef = row.raidRef
                slot.infoBtn:SetScript("OnClick", function()
                    -- Toggle: re-click same row closes; click on a
                    -- different row swaps; first click opens.
                    UI.ToggleSkipDetail(raidRef)
                end)
                slot.infoBtn:Show()
            end

            -- Cell renderer. States map to the dot ramp:
            --   "na" -> gray (no skip at this difficulty)
            --   "?"  -> unknown glyph (Garrosh undeterminable)
            --   true -> green (unlocked)
            --   false -> white (locked: exists but not unlocked)
            local function cellText(v)
                if v == "na" then return SKIPS_CELL_NA end
                if v == "?" then return SKIPS_CELL_UNKNOWN end
                if v then
                    return SKIPS_CELL_UNLOCKED
                end
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
            -- Tight gap between collapsed headers so they stack like the
            -- main-UI list; a roomier gap below an expanded block to set
            -- its raid rows off from the next header.
            if row.collapsed then
                y = y - 2
            else
                y = y - math.floor(lineHeight / 2)
            end

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

    -- TOP-PIN (in place): keep the window's top-left corner at its current
    -- screen position across the resize so it grows downward only and never
    -- jumps. Dragging the frame (StartMoving) converts its anchor to a
    -- CENTER-relative point; a bare SetHeight then splits the height delta
    -- above and below center, moving the expansion +/- buttons out from
    -- under the cursor. Re-anchoring TOPLEFT to the captured screen
    -- position fixes that without snapping the window back to the panel,
    -- so a user-dragged position is preserved.
    --
    -- GetTop/GetLeft and the SetPoint offset both live in the frame's own
    -- scaled coord space, and UIParent BOTTOMLEFT is the origin, so the
    -- captured values can be used directly as the anchor offset at any
    -- window-scale setting.
    local oldTop  = w:GetTop()
    local oldLeft = w:GetLeft()
    w:SetHeight(clamped)
    if oldTop and oldLeft then
        w:ClearAllPoints()
        w:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", oldLeft, oldTop)
    end
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

    -- The skip-detail frame is conceptually a child of this window (it
    -- opens from a row's [ i ] button). Hide it whenever this window
    -- hides, so it doesn't linger after the Skips window is closed or
    -- mutexed away by another auxiliary window.
    f:HookScript("OnHide", function() UI.HideSkipDetail() end)

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
    f.colHeaderN = MakeColHeader(SKIPS_COL_NORMAL_X, "Normal")
    f.colHeaderH = MakeColHeader(SKIPS_COL_HEROIC_X, "Heroic")
    f.colHeaderM = MakeColHeader(SKIPS_COL_MYTHIC_X, "Mythic")

    -- Disclaimer at the bottom. Anchored dynamically by RefreshSkipsContent
    -- after the last row, so no fixed position here.
    -- Footer legend: the four cell-dot states plus the info-button note.
    -- Dots reuse the cell glyph constants so the key always matches what
    -- the rows paint. The "?" unknown state is intentionally omitted.
    local disclaimer = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    disclaimer:SetJustifyH("LEFT")
    disclaimer:SetWordWrap(true)
    disclaimer:SetText(
        SKIPS_CELL_NA       .. " |cff9d9d9dN/A|r    "
     .. SKIPS_CELL_LOCKED   .. " |cff9d9d9dLocked|r    "
     .. SKIPS_CELL_UNLOCKED .. " |cff9d9d9dUnlocked|r")
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

    -- Snap to the current raid: opening the window while in a supported
    -- raid expands that raid's expansion section. Seeded only here, at
    -- open time, so the accordion still governs subsequent toggles.
    if RR.currentRaid and RR.currentRaid.expansion then
        RR.state = RR.state or {}
        RR.state.skipsExpandedExpansions = { [RR.currentRaid.expansion] = true }
        -- Mark the raid context as seen so the settings heartbeat doesn't
        -- treat the new window's nil _lastRaidKey as a transition.
        w._lastRaidKey = RR.currentRaid.instanceID
    end

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
-- What's New (release-notes body builder)
-- ============================================================================
--
-- Renders the release-notes data in RR.WhatsNew (defined in WhatsNew.lua) into
-- a single multi-line, color-coded string. Consumed by the Settings "What's
-- New" tab (the footer version link opens that tab). There is no longer a
-- standalone popup window -- the tab is the single What's New surface.
--
-- Wrapped in a do/end block to keep the supporting locals out of UI.lua's
-- top-level scope (Lua 5.1 caps local-variable count at 200 per function;
-- this file's main chunk is close to that ceiling).
do
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
                -- bright-white-on-grey gives the same visual emphasis.
                local rendered = bullet:gsub("%*%*(.-)%*%*",
                    "|cffffffff%1|r")
                table.insert(lines, "  - |cffaaaaaa" .. rendered .. "|r")
            end
        end
    end

    return table.concat(lines, "\n")
end

-- Exposed so the Settings "What's New" tab can render the body.
UI.BuildWhatsNewBody = BuildWhatsNewBody
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
-- The supported-raids list shows a binary skip indicator via the leading
-- raid-name star (in emitRaid): skip unlocked / not unlocked / no skip
-- mechanic. Per-difficulty skip granularity lives in the dedicated Skips
-- window, reached via the action button.
local function BuildIdleListPills(raid)
    local counts = RR:GetPerDifficultyKillCountsForRaid(raid)
    if not counts then return "" end

    -- Build from the raid's difficulty model so Mists raids show N | H
    -- and modern raids show N | H | M without a per-era branch. LFR (17)
    -- is intentionally absent from the label map, matching the in-raid
    -- pill row -- LFR sources live in the transmog browser.
    local BUCKET_LABEL = { [14] = "N", [15] = "H", [16] = "M" }
    local model = RR:GetDifficultyModel(raid)
    local PILLS = {}
    for _, bucket in ipairs(model.buckets) do
        local label = BUCKET_LABEL[bucket]
        if label then
            table.insert(PILLS, { id = bucket, label = label })
        end
    end

    -- Color constants are 6-char RGB; the format string prepends |cff.
    -- No alpha byte here, or it leaks as visible characters before the label.
    local CLEARED  = "00ff00"  -- matches SPECIAL_COLLECTED RGB
    local PARTIAL  = "ff9333"  -- matches SPECIAL_PARTIAL RGB
    local FRESH    = "888888"  -- matches SPECIAL_UNCOLLECTED RGB
    local INACTIVE = "555555"  -- doesn't apply

    -- Mists shared lockout: once a mode is committed for the week, its
    -- Normal/Heroic sibling is unreachable. Mark that sibling with a lock
    -- glyph (no recolor -- an untouched pill is already gray, so color
    -- alone couldn't distinguish "locked this week" from "not yet done").
    local lockedBucket = RR:GetLockedOutBucket(raid, counts)
    -- yOffset drops the icon onto the text baseline; trailing RGB tints it
    -- gold (the LFG lock is the locked-out marker).
    local LOCK_GLYPH = " |TInterface\\PetBattles\\PetBattle-LockIcon:12:12:0:0|t"

    -- LFR pill first (easiest -> hardest ordering), matching the in-raid row.
    -- LFR completion comes from the lockout bitfield, not C_RaidLocks, so it's
    -- sourced separately. Shown only for raids with LFR wing data. Colored by
    -- the raid's own lockout state, like the other idle pills (no active-
    -- difficulty highlight here -- the idle list shows every raid at once).
    -- The LFR pill lives in its OWN bracket group, separate from the N/H/M
    -- group. For wing raids the bracket reserves an inner slot before its
    -- closing "]" (WING_CHEVRON_SLOT) so the wing-expand chevron can sit
    -- INSIDE the bracket, anchored there by RefreshIdleList.
    local lfrSegment = nil
    local lfr = RR:GetLFRKillCountForRaid(raid)
    if lfr then
        local hex
        if lfr.total > 0 and lfr.complete >= lfr.total then
            hex = CLEARED
        elseif lfr.complete > 0 then
            hex = PARTIAL
        else
            hex = FRESH
        end
        local lfrToken = ("|cff%sLFR %d/%d|r"):format(hex, lfr.complete, lfr.total)
        -- Wing raids reserve an 11px transparent slot before the closing "]"
        -- for the expand chevron (anchored there by RefreshIdleList). Non-wing
        -- raids keep the tight "[ LFR n/N ]".
        local chevronSlot = raid.lfrWings
            and "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:11:0:0:64:64:0:64:0:64:0:0:0:0|t"
            or ""
        lfrSegment = ("|cff777777[ |r%s%s|cff777777 ]|r"):format(
            lfrToken, chevronSlot)
    end

    local parts = {}
    for _, p in ipairs(PILLS) do
        local c = counts[p.id]
        local label = p.label
        local lock = (p.id == lockedBucket) and LOCK_GLYPH or ""

        if c and c.total > 0 then
            local hex
            if c.complete >= c.total then
                hex = CLEARED
            elseif c.complete > 0 then
                hex = PARTIAL
            else
                hex = FRESH
            end
            table.insert(parts, ("|cff%s%s %d/%d|r%s"):format(
                hex, label, c.complete, c.total, lock))
        else
            table.insert(parts, ("|cff%s%s -|r%s"):format(INACTIVE, label, lock))
        end
    end

    -- N/H/M difficulty pills in their own bracket group.
    local diffSegment = nil
    if #parts > 0 then
        local sep = "|cff555555 | |r"
        diffSegment = "|cff777777[ |r"
            .. table.concat(parts, sep)
            .. "|cff777777 ]|r"
    end

    -- Join the two bracket groups with a two-space gap.
    if lfrSegment and diffSegment then
        return lfrSegment .. "  " .. diffSegment
    end
    return lfrSegment or diffSegment or ""
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
        -- Skip incomplete entries (instanceID = 0). These have no resolved
        -- journal IDs yet, so they'd render as a raid with all-dash pills
        -- (journalEncounterID = 0 resolves to no encounter, detectable bosses
        -- = 0, and the pill renderer takes the "doesn't apply" branch).
        if raid.instanceID and raid.instanceID > 0 then
            -- Faction-aware swap: a Horde player with Horde-specific data for
            -- a raid (currently only BfD) uses that instead of the shared
            -- Alliance copy. Otherwise the idle-list pill row counts kills
            -- against Alliance encounter IDs on a Horde character and reports
            -- 0/6 instead of 2/9, since Horde kills register against the
            -- Horde-variant IDs absent from the Alliance bosses[] table.
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

        -- Leading skip-status marker(s). Single-chain raids show one
        -- marker; multi-chain raids (Antorus, Hellfire Citadel) show one
        -- marker per chain, each filled or dimmed by that chain's own
        -- unlock state. Marker states:
        --   skip unlocked      -> gold
        --   skip exists, not unlocked -> dim
        --   no skip mechanic   -> transparent (reserves column width)
        -- "Skip mechanic" covers raids with skipQuests, skipAchievement,
        -- or the Garrosh scroll (skipGarrosh).
        local hasSkipMechanic = RR:RaidHasSkipMechanic(raid)
        local leading
        if not hasSkipMechanic then
            leading = SKIP_MARKER_ROW_NONE
        else
            -- Per-chain ceilings when the raid uses skipQuests; nil for
            -- achievement-gated skips (handled by the single-marker
            -- fallback below).
            local chainStates = RR.GetSkipChainCeilings and RR:GetSkipChainCeilings(raid)
            if chainStates and #chainStates > 1 then
                -- Multi-chain raids (Antorus, Hellfire Citadel) show a single
                -- marker: gold if any chain is unlocked, dim if none are. The
                -- per-chain detail is in the Skips window.
                local anyUnlocked = false
                for _, c in ipairs(chainStates) do
                    if c.ceiling then anyUnlocked = true break end
                end
                leading = anyUnlocked and SKIP_MARKER_ROW or SKIP_MARKER_ROW_DIM
            else
                -- Single-chain or achievement-gated: one marker driven by
                -- the raid-wide ceiling, as before.
                local ceiling = RR:GetRaidSkipUnlockedCeiling(raid)
                leading = ceiling and SKIP_MARKER_ROW or SKIP_MARKER_ROW_DIM
            end
        end

        local label = ("%s |cffffffff%s|r"):format(leading, name)

        anyRaidShown = true
        if RR:GetRaidEntrance(raid) then
            anyEntranceShown = true
        end
        table.insert(rows, { kind = "raidName", text = label, raid = raid })
        local pills = BuildIdleListPills(raid)
        if pills ~= "" then
            local counts = RR:GetPerDifficultyKillCountsForRaid(raid)
            -- Raids with LFR wing data get a wing-expand chevron on the pill
            -- row, positioned in RefreshIdleList.
            local hasWings = raid.lfrWings ~= nil
            -- Raids with entrance data carry the nav plane in the gutter
            -- (RR.PILL_PLANE_GUTTER), positioned in RefreshIdleList.
            local hasPlane = (RR:GetRaidEntrance(raid) ~= nil)
            local gutter = hasPlane and RR.PILL_PLANE_GUTTER or ""
            -- Pill row text: sub-line indent, plane gutter, then the pills.
            -- The indent renders it as a sub-line under the raid name.
            table.insert(rows, {
                kind = "pillRow",
                text = RR.PILL_SUBLINE_INDENT .. gutter .. "  " .. pills,
                lockedOut = (RR:GetLockedOutBucket(raid, counts) ~= nil),
                raid = raid,
                hasWings = hasWings,
                hasPlane = hasPlane,
            })

            -- When this raid's wings are expanded, inject the wing rows
            -- right below the pill. Each wing becomes a header row
            -- (WingName + n/N) with its own chevron; the bosses of the
            -- currently-open wing render below that header (one boss per
            -- row, so long lists stack instead of wrapping). Only one wing
            -- per raid is open at a time -- tracked in openWingByRaid keyed
            -- by raid.instanceID -> wing key. Wing/boss state comes from
            -- GetWingProgressForRaid.
            local wingExpanded = (RR.state and RR.state.wingExpandedRaids) or {}
            if hasWings and wingExpanded[raid.instanceID] then
                local wings = RR:GetWingProgressForRaid(raid)
                if wings then
                    local openWing = (RR.state and RR.state.openWingByRaid
                        and RR.state.openWingByRaid[raid.instanceID])
                    for _, w in ipairs(wings) do
                        local isOpen = (openWing == w.key)
                        table.insert(rows, {
                            kind = "wingHeader",
                            wing = w,
                            raid = raid,
                            wingOpen = isOpen,
                        })
                        if isOpen then
                            for _, b in ipairs(w.bosses or {}) do
                                table.insert(rows, {
                                    kind = "wingBoss",
                                    boss = b,
                                    unmapped = w.unmapped,
                                })
                            end
                        end
                    end
                end
            end
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

-- Rebuild the idle-state list. Each row gets its own FontString from
-- the pool; expansion-header toggle buttons anchor LEFT of their
-- header so the two stay aligned without measurement.
-- Fingerprint guard prevents heartbeat-driven rebuilds from eating
-- in-flight clicks (a heartbeat-time Hide() would otherwise drop the
-- click target between OnMouseDown and OnMouseUp).
local lastIdleListFingerprint = nil

-- Force a rebuild on the next RefreshIdleList (used by font-size
-- changes that affect layout but not row content).
function UI.InvalidateIdleListCache()
    lastIdleListFingerprint = nil
end

-- Stable string-serialization of a row list, used as the cache key.
-- Only includes fields that affect rendered output.
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
        -- Wing rows carry no .text; serialize their content so expand/
        -- collapse and any kill-state change re-fingerprints (and re-renders).
        if k == "wingHeader" and row.wing then
            local w = row.wing
            t = ("%s|%d/%d|%s|%s"):format(
                w.name or "", w.complete or 0, w.total or 0,
                w.unmapped and "u" or "m",
                row.wingOpen and "o" or "c")
        elseif k == "wingBoss" and row.boss then
            local b = row.boss
            local kill = (b.killed == true) and "1"
                or (b.killed == false and "0" or "x")
            t = ("%s|%s|%s"):format(b.name or "", kill,
                row.unmapped and "u" or "m")
        end
        parts[i] = ("%s|%s|%s|%s"):format(k, e, exp, t)
    end
    return table.concat(parts, "\n")
end

RefreshIdleList = function()
    -- panel.list is a multi-line FontString no longer used for row layout;
    -- the idle list and in-raid progress checklist render through per-line
    -- FontString pools (idleListLines / progressListLines) for stable rows.
    -- Clear panel.list and release any progress lines on entry: this function
    -- is called
    -- when transitioning INTO an idle/run-complete state, where the
    -- in-raid boss-progress list (if any was on screen) needs to go.
    if panel.list then panel.list:SetText("") end
    ReleaseProgressListLines()

    -- Collapse all expansions on a raid-context change (run start, run
    -- complete, or zone out), so the run-complete and idle lists open
    -- fully collapsed. Keyed on instanceID (nil when not in a raid) so it
    -- fires once per transition, not every refresh tick -- otherwise a
    -- user expand would be cleared on the next tick.
    local idleRaidContext = RR.currentRaid and RR.currentRaid.instanceID or nil
    if panel._lastIdleRaidContext ~= idleRaidContext then
        panel._lastIdleRaidContext = idleRaidContext
        RR.state = RR.state or {}
        RR.state.expandedExpansions = {}
        -- Collapse any open wing expanders too, so the list opens fully
        -- collapsed on each raid-context transition (matches the
        -- expansion accordion's reset behavior).
        RR.state.wingExpandedRaids = {}
        RR.state.openWingByRaid = {}
    end

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
    ReleasePillHoverFrames()
    panel.ReleaseWingStrikes()
    panel.ReleaseWingToggleButtons()

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
            elseif row.kind == "wingHeader" then
                -- Wing header: "WingName (n/N)", one level under the pill row.
                -- Green when fully cleared, gray otherwise. An unmapped wing
                -- appends a small gray flag. Leads with the sub-line indent so
                -- it sits under the pill row, then its own spaces step further.
                local w = row.wing
                local hex = (w.total > 0 and w.complete >= w.total)
                    and "00ff00" or "888888"
                local marker = w.unmapped and " |cff888888*|r" or ""
                fs:SetText((RR.PILL_SUBLINE_INDENT .. "        |cff%s%s|r |cff9d9d9d(%d/%d)|r%s"):format(
                    hex, w.name, w.complete or 0, w.total or 0, marker))
            elseif row.kind == "wingBoss" then
                -- One boss per line, a further level under the wing header.
                -- Dead = faded gray; alive = white; unmapped wing's bosses
                -- render neutral lavender. Leads with the sub-line indent like
                -- the wing header.
                local b = row.boss
                local hex
                if row.unmapped then
                    hex = "b9a3d6"       -- pending (per-boss state unknown)
                elseif b.killed then
                    hex = "6f6f6f"       -- dead, faded
                else
                    hex = "ffffff"       -- alive
                end
                fs:SetText((RR.PILL_SUBLINE_INDENT .. "            |cff%s%s|r"):format(hex, b.name))
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

            -- Locked-out pill rows get an invisible hover frame on top
            -- so the shared-lockout tooltip can fire (the FontString
            -- itself can't take mouse events). Sized to the rendered pill
            -- string, not the full column width, so the hit area matches
            -- what's visible.
            if row.kind == "pillRow" and row.lockedOut then
                local hf = AcquirePillHoverFrame()
                hf:ClearAllPoints()
                hf:SetPoint("TOPLEFT", fs, "TOPLEFT", 0, 0)
                hf:SetPoint("BOTTOMRIGHT", fs, "BOTTOMLEFT",
                    (fs:GetStringWidth() or 0), 0)
                hf:Show()
                table.insert(panel.pillHoverFrames, hf)
            end

            -- Dead boss rows (mapped wings only) get a strikethrough over the
            -- name. The indent string matches the wingBoss text leading (the
            -- sub-line indent + 12 spaces) so the strike starts at the name.
            if row.kind == "wingBoss" and row.boss and row.boss.killed
                and not row.unmapped then
                panel.StrikeBossName(fs, fontSize, RR.PILL_SUBLINE_INDENT .. "            ")
            end

            -- Wing-expand chevron on pill rows that have LFR wings. Placed
            -- inside the LFR bracket, in the reserved slot before the "]", so
            -- it reads as part of the LFR pill it controls.
            if row.kind == "pillRow" and row.hasWings and row.raid then
                local btn = panel.AcquireWingToggleButton()
                local raid = row.raid
                RR.state = RR.state or {}
                local wingExpanded = RR.state.wingExpandedRaids
                    and RR.state.wingExpandedRaids[raid.instanceID]
                local g = math.floor(fontSize * 0.83)
                btn:SetSize(g, g)
                panel.SetWingChevron(btn, wingExpanded)
                btn:ClearAllPoints()

                -- Place the chevron in the reserved slot before the "]".
                -- Measure the string up to the end of the count (sub-line
                -- indent + plane gutter + "[ LFR n/N"), then +1 to center it
                -- in the slot.
                local lfr = RR:GetLFRKillCountForRaid(raid)
                local lfrPrefix = RR.PILL_SUBLINE_INDENT .. RR.PILL_PLANE_GUTTER
                    .. ("  [ LFR %d/%d"):format(
                        lfr and lfr.complete or 0, lfr and lfr.total or 0)
                if not panel._wingChevronMeasureFS then
                    panel._wingChevronMeasureFS =
                        panel:CreateFontString(nil, "ARTWORK")
                    panel._wingChevronMeasureFS:Hide()
                end
                local mfs = panel._wingChevronMeasureFS
                local ff, fsz, ffl = fs:GetFont()
                if ff then mfs:SetFont(ff, fsz or fontSize, ffl or "") end
                mfs:SetText(lfrPrefix)
                local lfrW = mfs:GetStringWidth() or 0

                btn:SetPoint("LEFT", fs, "LEFT", lfrW + 1, 0)
                btn:SetScript("OnClick", function()
                    RR.state = RR.state or {}
                    RR.state.wingExpandedRaids = RR.state.wingExpandedRaids or {}
                    local cur = RR.state.wingExpandedRaids[raid.instanceID]
                    -- Toggle this raid's wings (independent per raid --
                    -- unlike the single-expand expansion accordion, several
                    -- raids' wings can be open at once since each is short).
                    if cur then
                        RR.state.wingExpandedRaids[raid.instanceID] = nil
                    else
                        RR.state.wingExpandedRaids[raid.instanceID] = true
                    end
                    if RR.UI and RR.UI.Update then RR.UI.Update() end
                end)
                btn:Show()
                table.insert(panel.wingToggleButtons, btn)
            end

            -- Wing-level chevron on each wing-header row. Anchored just left
            -- of the wing name; toggles which wing is open for this raid
            -- (one at a time -- opening another wing closes the prior one).
            if row.kind == "wingHeader" and row.raid then
                local btn = panel.AcquireWingToggleButton()
                local raid = row.raid
                local wingKey = row.wing.key
                local g = math.floor(fontSize * 0.71)
                btn:SetSize(g, g)
                panel.SetWingChevron(btn, row.wingOpen)
                btn:ClearAllPoints()
                -- Just left of the wing name: 24px = the 16px sub-line indent
                -- + the 8 leading spaces of the wing-header text.
                btn:SetPoint("LEFT", fs, "LEFT", 24, 0)
                btn:SetScript("OnClick", function()
                    RR.state = RR.state or {}
                    RR.state.openWingByRaid = RR.state.openWingByRaid or {}
                    local cur = RR.state.openWingByRaid[raid.instanceID]
                    -- One wing open at a time: clicking the open wing closes
                    -- it; clicking a different wing switches to it.
                    if cur == wingKey then
                        RR.state.openWingByRaid[raid.instanceID] = nil
                    else
                        RR.state.openWingByRaid[raid.instanceID] = wingKey
                    end
                    if RR.UI and RR.UI.Update then RR.UI.Update() end
                end)
                btn:Show()
                table.insert(panel.wingToggleButtons, btn)
            end

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

            -- Nav button on the pill row, at a fixed left inset so every
            -- plane lands in one vertical column. Clicking opens the
            -- LFR/Standard chooser. Alpha: full-color when any nav provider
            -- above bare-Blizzard is installed, muted otherwise.
            if row.kind == "pillRow" and row.raid and RR:GetRaidEntrance(row.raid) then
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
                    panel.ShowNavChooser(self, raid)
                end)
                btn:Show()
                table.insert(panel.entranceButtons, btn)
            end

            table.insert(panel.idleListLines, fs)
            prev = fs
        end
    end


    -- Bottom-up legend pass. The legend pins to a fixed distance from
    -- the panel bottom (above the action button row) regardless of how
    -- long the raid list is. Multi-row legends chain upward from the
    -- bottom-anchored row.
    local LEGEND_BOTTOM_OFFSET = BUTTON_Y + BUTTON_H + 12  -- BUTTON_Y already includes the frame inset
    local LEGEND_INTER_GAP = 4  -- compact spacing between legend rows
    -- Row 2+ left indent (skip past the marker + " = ") so labels
    -- align under row 1's label.
    local LEGEND_CONTINUATION_INDENT = 22
    -- Data-column offset from each row's label-FontString left edge.
    local LEGEND_DATA_COLUMN = 74

    -- Iterate in reverse so the last legend bottom-anchors and
    -- earlier legends chain above it.
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

    -- Divider above the legend block. The legend anchors upward from the
    -- panel bottom, so its final screen position isn't settled until
    -- AutoSize runs (after this function). Stash the topmost legend row
    -- here and do the actual divider placement in PositionLegendDivider,
    -- called at the tail of AutoSize once geometry is final -- that lets
    -- the divider sit at the true midpoint between the legend top and the
    -- last raid row above it, whatever the gap turns out to be.
    panel._legendTopRow = lastLegendTopFS
    if not lastLegendTopFS then
        panel.legendDivider:Hide()
        if panel.legendDividerGem then panel.legendDividerGem:Hide() end
    end
end

-- Place the legend divider at the vertical midpoint between the bottom of
-- the last raid-list row and the top of the topmost legend row. Both
-- positions are read live, so this MUST run after AutoSize has set the
-- final panel height (the legend pins to the panel bottom, so its screen
-- Y depends on that height).
-- (forward-declared above so AutoSize, defined earlier, can call it)
PositionLegendDivider = function()
    local topRow  = panel._legendTopRow
    local lastList = panel.idleListLines and panel.idleListLines[#panel.idleListLines]
    if not (topRow and lastList) then
        if panel.legendDivider then panel.legendDivider:Hide() end
        if panel.legendDividerGem then panel.legendDividerGem:Hide() end
        return
    end
    local rowBottom    = lastList:GetBottom()
    local legendTop    = topRow:GetTop()
    if not (rowBottom and legendTop) then
        panel.legendDivider:Hide()
        if panel.legendDividerGem then panel.legendDividerGem:Hide() end
        return
    end
    -- True midpoint between the last raid row's bottom and the legend's top.
    -- Anchor the divider by its CENTER to that point so its visual center IS the
    -- midpoint (anchoring by TOPLEFT instead would hang the divider + its taller
    -- gem below the midpoint by half their height -- the off-center bug).
    local mid       = (rowBottom + legendTop) / 2   -- midpoint Y (screen coords)
    local dyFromRow = rowBottom - mid               -- downward distance from the row bottom to the midpoint
    panel.legendDivider:ClearAllPoints()
    panel.legendDivider:SetPoint("CENTER", lastList, "BOTTOMLEFT", BODY_WIDTH / 2, -dyFromRow)
    panel.legendDivider:SetWidth(BODY_WIDTH)
    panel.legendDivider:Show()
    if panel.legendDividerGem then panel.legendDividerGem:Show() end
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

    -- Title-bar mode slot: skip route only, as a compact cyan [ SKIP ]
    -- marker. Standard runs leave it blank. Test mode shows next to the
    -- Boss Progress header instead (set in the in-progress branch).
    -- Anchor live here (not just at construction) so position changes
    -- take effect on refresh; ClearAllPoints first since SetPoint stacks.
    -- Footer left slot. In an active raid it shows the current route; when
    -- idle it shows the author credit.
    if raid and loaded then
        local routeLabel
        if RR:GetActiveWing() then
            -- An LFR wing route is active (overrides standard/skip, the same
            -- way GetActiveRouting prefers the wing). Pink matches the LFR
            -- theming used elsewhere (the wing-name message).
            routeLabel = "|cffF259C7LFR|r"
        elseif RR.state.activeRouteVariant == "skip" then
            routeLabel = "|cff00ffffSkip|r"
        else
            routeLabel = "|cff00ff00Standard|r"
        end
        panel.credit:SetText("|cff9d9d9dRoute:|r " .. routeLabel)
    else
        panel.credit:SetText("Created by |cff4DCCFFPhotek|r")
    end

    if raid and loaded then
        -- The raid name line shows just the raid name; per-difficulty kill
        -- state lives in the pills row below. A trailing yellow-star marker
        -- appears when the player's current difficulty is at or below the
        -- account's cascade ceiling, i.e. when the in-game skip NPC will
        -- actually let them use it.
        -- Faction marker for raids with separate per-faction data (currently
        -- only BfD); symmetric raids get no marker.
        --
        -- Alliance blue / Horde red roughly matching Blizzard's faction
        -- colors. Bracketed-letter pattern matches the [!] style on the
        -- boss-encounter line.
        local raidLabel = "Raid: " .. raid.name
        if RetroRuns_DataHorde and RetroRuns_DataHorde[raid.instanceID] then
            local faction = UnitFactionGroup("player")
            if faction == "Horde" then
                raidLabel = raidLabel .. " |cffe60100[H]|r"
            else
                raidLabel = raidLabel .. " |cff0078ff[A]|r"
            end
        end
        panel.raid:SetText(raidLabel)

        -- LFR wing subline. Shown only in a wing; sized 2pt below the raid
        -- font (read live so it tracks the template). Prefixed with the same
        -- forward-chevron glyph the Boss Progress list uses for its active row,
        -- and a small indent, so it reads as a sub-item of the raid line.
        local wing = RR:GetActiveWing()
        if wing and wing.name then
            local rfFont, rfSize, rfFlags = panel.raid:GetFont()
            if rfFont and rfSize then
                panel.wingLine:SetFont(rfFont, rfSize - 2, rfFlags)
            end
            local WING_ARROW = "|TInterface\\ChatFrame\\ChatFrameExpandArrow:10:10:0:0:32:32:0:32:0:32:242:89:199|t"
            panel.wingLine:SetText(
                "  " .. WING_ARROW ..
                " |cff9d9d9dLFR Wing:|r |cffF259C7" .. wing.name .. "|r")
        else
            panel.wingLine:SetText("")
        end
        panel.pills:SetText(BuildPillsText())
        -- Arm the lockout tooltip only when a mode is actually claimed
        -- this week (the lock glyph is showing); otherwise hovering the
        -- pills row says nothing.
        if panel.pillsHover then
            local counts = RR:GetPerDifficultyKillCounts()
            local locked = (RR:GetLockedOutBucket(raid, counts) ~= nil)
            panel.pillsHover._lockoutTip = locked
            if locked then
                panel.pillsHover:SetWidth((panel.pills:GetStringWidth() or 0) + 2)
            end
        end
        -- Progress line was "Progress: X/Y" -- the player's current-
        -- difficulty kill count -- but the pills row now displays the
        -- same number (the active-difficulty pill, e.g. "H 0/8").
        -- Empty here so it doesn't duplicate. The FontString is kept
        -- so the unloaded path below can still use it for "Detected:"
        -- and "No supported raid" status messages.
        panel.progress:SetText("")
        panel.mapBtn:Enable()
        panel.mapBtn:SetAlpha(1)

        if RR:IsInLFR() and not RR:GetActiveWing() then
            -- LFR mode: routing, segments, and per-boss progress are
            -- not modeled. LFR wings have different boss subsets and
            -- different paths than the Normal/Heroic/Mythic layout the
            -- routing data is authored for, so showing those would lead
            -- the player toward bosses or transitions that don't exist
            -- in the wing they're standing in. The panel surfaces a
            -- single message in place of the routing/encounter content.
            -- The action button row (Achievements, Transmog, Skips,
            -- Settings) sits outside this render path and stays visible,
            -- so the still-working browsers remain one click away.
            local wingName = RR:GetCurrentWingName()
            if wingName then
                panel.next:SetText(("|cffffffffLFR routing for |r|cffF259C7%s|r|cffffffff isn't supported yet.|r"):format(wingName))
            else
                panel.next:SetText("|cffffffffLFR routing isn't supported yet.|r")
            end
            panel.travel:SetText("")
            panel.exitNote:SetText("")
            panel.exitNote:Hide()
            panel.encounter.header.label:SetText("")
            panel.encounter.header.clickable = false
            panel.encounter.header:EnableMouse(false)
            panel.encounter.achievements.label:SetText("")
            panel.encounter.achievements:Hide()
            panel.encounter.specialLoot.label:SetText("")
            panel.encounter.specialLoot:Hide()
            panel.encounter:Hide()
            panel.transmog:SetText("")
            panel.transmog:EnableMouse(false)
            panel.transmog:Hide()

            -- Map button stays active: with no routing step it opens the
            -- world map at the player's current location.
            panel.mapBtn:Enable()
            panel.mapBtn:SetAlpha(1)

            -- Release any list widgets left over from a prior in-progress
            -- pass; nothing to render in their place.
            ReleaseExpansionToggleButtons()
            ReleaseEntranceButtons()
            panel.ReleaseWingStrikes()
            panel.ReleaseWingToggleButtons()
            ReleaseIdleListLines()
            ReleaseProgressListLines()
            panel.listHeader:SetText("")
        elseif step then
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
            panel.exitNote:SetText("")
            panel.exitNote:Hide()
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
            if RR.state.testMode then
                panel.listHeader:SetText("Boss Progress  |cffffff00[ TEST MODE ]|r")
            else
                panel.listHeader:SetText("Boss Progress")
            end
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
            panel.ReleaseWingStrikes()
            panel.ReleaseWingToggleButtons()
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
            -- Completion keys off whether every boss in the active route
            -- is dead (IsActiveRouteComplete), not a step-count comparison.
            -- That way a skip route -- which has fewer steps than the raid
            -- has bosses -- reaches "complete" when its final boss dies,
            -- instead of never satisfying routingCount >= bossCount. An
            -- empty/unauthored route returns false, preserving the
            -- "not yet captured" state for in-development bring-ups.
            local routeComplete = RR.IsActiveRouteComplete and RR:IsActiveRouteComplete()
            local isSkip = RR.state and RR.state.activeRouteVariant == "skip"

            -- Run-complete state: every boss in the active route cleared.
            -- Drops the Travel line, re-anchors listHeader under the exit
            -- note (or panel.next when there's no exit note), and shows the
            -- idle per-raid pill list instead of the boss checklist.
            -- Uncaptured-raid state (routeComplete=false) uses the same
            -- layout with different text.
            if routeComplete then
                if RR:GetActiveWing() then
                    panel.next:SetText("|cff00ff00LFR Wing Complete!|r")
                elseif isSkip then
                    panel.next:SetText("|cff00ff00Skip Run Complete!|r")
                else
                    panel.next:SetText("|cff00ff00Run complete!|r")
                end
                -- Optional per-raid exit note, shown below the banner with an
                -- inline exit glyph. In an LFR wing the raid's authored exit
                -- (walk to a specific spot / portal) doesn't apply -- you leave
                -- through the LFG tool. A wing may author its own exitNote (for
                -- per-wing instructions); when it doesn't, fall back to the
                -- generic LFG-tool line. Outside LFR, show the raid's note.
                local exitNote
                local activeWing = RR:GetActiveWing()
                if activeWing then
                    exitNote = activeWing.exitNote or "Leave instance group via LFG tool."
                else
                    exitNote = raid and raid.exitNote
                end
                if exitNote and exitNote ~= "" then
                    local exitFontSize = RR:GetSetting("fontSize", 12)
                    local exitGlyphSize = exitFontSize + 3
                    panel.exitNote:SetText(
                        ("|TInterface\\AddOns\\RetroRuns\\Media\\ExitIcon:%d:%d:0:-1:64:64:0:64:0:64:242:89:199|t ")
                            :format(exitGlyphSize, exitGlyphSize) ..
                        "|cfff259c7Exit Note:|r " .. HighlightNames(exitNote))
                    panel.exitNote:SetTextColor(1, 1, 1)
                    SetBodyFont(panel.exitNote, exitFontSize, "")
                    panel.exitNote:Show()
                else
                    panel.exitNote:SetText("")
                    panel.exitNote:Hide()
                end
            else
                panel.next:SetText("|cffff9333Routing data not yet captured for this raid.|r")
                panel.exitNote:SetText("")
                panel.exitNote:Hide()
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
            -- Reset transmog mouse-enable too -- the in-progress branch
            -- enabled it; the idle branch disables it; we need to here too.
            panel.transmog:EnableMouse(false)
            panel.transmog:Hide()

            -- Map button stays active: it opens the world map at the
            -- player's current location even with no active step.
            panel.mapBtn:Enable()
            panel.mapBtn:SetAlpha(1)

            panel.listHeader:ClearAllPoints()
            if panel.exitNote:IsShown() then
                panel.listHeader:SetPoint("TOPLEFT", panel.exitNote, "BOTTOMLEFT", 0, -12)
            else
                panel.listHeader:SetPoint("TOPLEFT", panel.next, "BOTTOMLEFT", 0, -12)
            end
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
        panel.wingLine:SetText("")
        panel.pills:SetText("")
        if panel.pillsHover then panel.pillsHover._lockoutTip = false end

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
        panel.exitNote:SetText("")
        panel.exitNote:Hide()
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
        panel.mapBtn:Enable()
        panel.mapBtn:SetAlpha(1)
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
-- Standalone window opened by the "Achieves" action button. Selection
-- state in `achState`, independent from `browserState` (the Tmog window).

local GetOrCreateAchievementsWindow

-- StaticPopup for the "copy Wowhead URL" dialog (Ctrl+C, dismiss). Addons
-- can't open URLs directly, so a copy-popup is the standard pattern.
StaticPopupDialogs["RETRORUNS_WOWHEAD_URL"] = {
    text         = "%s\n|cffffd200%s|r\n\nWowhead URL (Ctrl+C to copy):",
    button1      = OKAY or "Okay",
    hasEditBox   = true,
    editBoxWidth = 280,
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    -- preferredIndex 3 sidesteps the RAID_WARNING taint chain.
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

-- StaticPopup for the Settings panel's "comments and feedback" button.
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

StaticPopupDialogs["RETRORUNS_DISCORD_URL"] = {
    text         = "Known Hangout\n\nDiscord invite URL (Ctrl+C to copy):",
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
-- Skip-trigger popup, shown from each Skips-window row's info icon.
-- Body: Quest / Quest IDs / Skip Details labeled lines. Quest IDs
-- are derived from raid.skipQuests at render time (clickable hyperlinks
-- to the Wowhead URL popup).
-- Skip-detail window. A standalone RetroRuns-owned frame (not a
-- StaticPopup) so that opening the Wowhead URL StaticPopup from a quest
-- link doesn't trigger Blizzard's popup-stack relayout -- which used to
-- yank this frame to screen-center and flicker a duplicate of it. The
-- frame is created once and reused; ShowSkipDetail repopulates it.
local skipDetailFrame
local function GetOrCreateSkipDetailFrame()
    if skipDetailFrame then return skipDetailFrame end

    local f = CreateFrame("Frame", "RetroRunsSkipDetailFrame", UIParent, "BackdropTemplate")
    f:SetSize(312, 120)  -- placeholder; ShowSkipDetail sizes to content
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    f:SetFrameStrata("DIALOG")  -- above the Skips window it spawns from
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    -- Title: "Skip:" in retro pink, then the raid name. Left-aligned,
    -- anchored top-left with a 16px inset.
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetJustifyH("LEFT")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -14)
    f.titleText = title

    -- Body: the labeled detail lines. Anchored below the title; width is
    -- set per-show once the content width is measured.
    local body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetJustifyH("LEFT")
    body:SetWordWrap(true)
    body:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -40)
    f.bodyText = body

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Hyperlink routing on the body FontString's parent frame. Quest
    -- links open the Wowhead URL StaticPopup; native achievement links
    -- fall through to SetItemRef (opens the in-game Achievement frame).
    -- Because this frame is not a StaticPopup, spawning the URL popup
    -- doesn't relayout or move it.
    f:SetHyperlinksEnabled(true)
    f:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local questID = link and link:match("^RR_quest:(%d+)$")
        if questID then
            local raid = f.rrRaid
            UI.ShowWowheadQuestPopup(tonumber(questID),
                (raid and raid.name) or "?",
                (raid and raid.skipTrigger and raid.skipTrigger.questName)
                    or ("Quest " .. questID))
            return
        end
        SetItemRef(link, text, button)
    end)
    f:SetScript("OnHyperlinkEnter", function(self2, link)
        -- In-game tooltip for native achievement links on hover. RR_quest
        -- links carry no resolvable tooltip, so skip them.
        if link and link:match("^RR_quest:") then return end
        GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    f:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

    -- Hidden tag for the [ i ]-button toggle: which raid is currently
    -- displayed. Cleared on hide.
    f:SetScript("OnHide", function(self) self.rrSkipRaidID = nil end)

    skipDetailFrame = f
    return f
end

-- Populate and show the skip-detail frame for a raid, positioned at the
-- cursor. Mirrors the old StaticPopup body-build verbatim.
function UI.ShowSkipDetail(raid)
    local f  = GetOrCreateSkipDetailFrame()
    local fs = f.bodyText

    f.rrRaid = raid
    f.titleText:SetText("|cffF259C7Skip:|r " .. ((raid and raid.name) or "?"))

    do
        -- Build the labeled body lines. Render lines that have content;
        -- skip lines whose source data is missing so partially-authored
        -- raids degrade gracefully rather than showing "Quest: nil".
        local trig = raid and raid.skipTrigger or {}
        local lines = {}

        -- Link builders. Both render the same cyan [id] bracket so quest
        -- and achievement links read identically, even though they route
        -- differently on click (quest -> Wowhead URL popup; achievement
        -- -> in-game Achievement frame, with a hover tooltip).
        local LINK_COLOR = "ff7faaff"
        local function questLink(id)
            if not id then return nil end
            return ("|HRR_quest:%d|h|c%s[%d]|r|h"):format(id, LINK_COLOR, id)
        end
        -- Build a native |Hachievement:|h link but display it as the same
        -- cyan [id] bracket as quest links. GetAchievementLink returns
        -- "|cffhex|Hachievement:ID:...|h[Name]|h|r"; we strip its embedded
        -- color wrapper, swap the [Name] display for [id], and re-wrap in
        -- our cyan. The |H...|h payload (which carries the achievement ID
        -- for SetItemRef and the hover tooltip) is preserved, so clicking
        -- and hovering still work. Falls back to a plain cyan [id] if the
        -- link can't be built (achievement not in the client cache yet).
        local function achievementLink(id)
            if not id then return nil end
            local raw = GetAchievementLink and GetAchievementLink(id)
            if not raw then
                return ("|c%s[%d]|r"):format(LINK_COLOR, id)
            end
            raw = raw:gsub("^|cff%x%x%x%x%x%x", ""):gsub("|r$", "")
            raw = raw:gsub("|h%[.-%]|h", ("|h[%d]|h"):format(id), 1)
            return ("|c%s%s|r"):format(LINK_COLOR, raw)
        end

        -- A "Detection:" row: a gray difficulty label and a value (one or
        -- more links, or plain text). Empty values are skipped by callers.
        local function detectionLine(label, value)
            return ("|cff9d9d9d%s Detection:|r %s"):format(label, value)
        end

        -- Header line: the human-readable name of the unlock, type-
        -- specific but parallel in form. Garrosh has no single name, so
        -- its panel goes straight to the Detection rows.
        if trig.questName and trig.questName ~= "" then
            table.insert(lines, "|cff9d9d9dQuest:|r " .. trig.questName)
        elseif trig.achievementName and trig.achievementName ~= "" then
            table.insert(lines, "|cff9d9d9dAchievement:|r " .. trig.achievementName)
        end

        -- Detection rows. Every skip type renders the same per-difficulty
        -- "<label> Detection:" grammar so the panels read consistently.
        local sq = raid and raid.skipQuests
        if sq and sq[1] and type(sq[1]) == "table" then
            -- Multi-chain quest (Antorus, HFC). One block per chain: a
            -- "<Chain> Detection:" header (with the chain's quest name in
            -- parens when known) and an indented Mythic/Heroic/Normal
            -- triplet. The two-line shape keeps the frame narrow even
            -- with long chain names.
            local names = (trig and trig.questNames) or {}
            for _, chain in ipairs(sq) do
                local chainLabel = chain.label or "Skip"
                local qname = names[chain.label]
                local header = ("|cff9d9d9d%s Detection:|r"):format(chainLabel)
                if qname and qname ~= "" then
                    header = header .. (" |cffaaaaaa(%s)|r"):format(qname)
                end
                table.insert(lines, header)

                local parts = {}
                local lm, lh, ln = questLink(chain.mythic), questLink(chain.heroic), questLink(chain.normal)
                if lm then table.insert(parts, "|cffaaaaaaM|r " .. lm) end
                if lh then table.insert(parts, "|cffaaaaaaH|r " .. lh) end
                if ln then table.insert(parts, "|cffaaaaaaN|r " .. ln) end
                table.insert(lines, "  " .. table.concat(parts, "   "))
            end
        elseif sq then
            -- Single-chain quest. One Detection row per difficulty.
            local lm, lh, ln = questLink(sq.mythic), questLink(sq.heroic), questLink(sq.normal)
            if lm then table.insert(lines, detectionLine("Mythic", lm)) end
            if lh then table.insert(lines, detectionLine("Heroic", lh)) end
            if ln then table.insert(lines, detectionLine("Normal", ln)) end
        elseif raid and raid.skipAchievement then
            -- Achievement-gated skip (BfD). Mythic-only.
            local sa = raid.skipAchievement
            if sa.mythic then
                table.insert(lines, detectionLine("Mythic", achievementLink(sa.mythic)))
            end
        elseif raid and raid.skipGarrosh then
            -- Account-wide scroll skip (SoO). Detection sources by
            -- difficulty: the Mythic achievement, the faction Heroic
            -- achievements, and the per-character Normal kill statistics.
            local sg = raid.skipGarrosh
            if sg.mythicAchievement then
                table.insert(lines, detectionLine("Mythic", achievementLink(sg.mythicAchievement)))
            end
            if sg.heroicAchievements and #sg.heroicAchievements > 0 then
                local achParts = {}
                for _, achID in ipairs(sg.heroicAchievements) do
                    table.insert(achParts, achievementLink(achID))
                end
                -- The faction-alternative achievements (Conqueror /
                -- Liberator) are mutually exclusive -- only one applies
                -- per character -- so join them with "or".
                table.insert(lines, detectionLine("Heroic",
                    table.concat(achParts, " |cffaaaaaaor|r ")))
            end
            if sg.normalStatistics and #sg.normalStatistics > 0 then
                local statParts = {}
                for _, statID in ipairs(sg.normalStatistics) do
                    table.insert(statParts, ("%d"):format(statID))
                end
                table.insert(lines, detectionLine("Normal",
                    "|cffaaaaaaStatistic Check on Normal Kills (This Char) - ID "
                    .. table.concat(statParts, ", ") .. "|r"))
            end
        end

        if trig.details and trig.details ~= "" then
            -- Swap the legend tokens for the same glyphs the difficulty
            -- columns render, so a note's legend reads against its marks.
            -- Raids without these tokens are unaffected (gsub no-ops).
            -- The textures are written as literals here; they must stay in
            -- sync with the SKIPS_CELL_UNLOCKED / _LOCKED / _UNKNOWN
            -- definitions.
            local detailText = trig.details
                :gsub("{check}", "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t")
                :gsub("{x}", "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14:0:-2|t")
                :gsub("{unknown}", "|TInterface\\RaidFrame\\ReadyCheck-Waiting:14:14|t")
            table.insert(lines,
                "|cff9d9d9dSkip Details:|r " .. HighlightNames(detailText))
        end

        fs:SetText(table.concat(lines, "\n\n"))
        fs:Show()

        -- Size the frame to fit the widest single line so the Quest IDs
        -- rows (Mythic/Heroic/Normal triplets) don't wrap. Measure each
        -- logical line with word-wrap off; GetStringWidth reports the
        -- rendered width (color/hyperlink escapes excluded), so the
        -- measurement matches what's painted. Body lines are joined with
        -- single \n here (sections use \n\n, multi-chain blocks use
        -- "\n  - "); splitting on \n measures every physical line.
        local measure = {}
        for _, l in ipairs(lines) do
            for sub in (l .. "\n"):gmatch("(.-)\n") do
                table.insert(measure, sub)
            end
        end
        local widest = 0
        fs:SetWordWrap(false)
        for _, line in ipairs(measure) do
            fs:SetText(line)
            local w = fs:GetStringWidth() or 0
            if w > widest then widest = w end
        end

        -- Frame width hugs the widest rendered line: body width is the
        -- Frame width hugs the widest rendered line, floored at a
        -- minimum so short-content panels stay readable and capped at a
        -- maximum so a long Skip Details paragraph wraps within the
        -- border instead of stretching the frame across the screen. The
        -- short Detection / ID lines fall well under the cap and stay on
        -- one line; only long prose hits it and wraps.
        local INSET    = 16
        local MIN_BODY = 280
        local MAX_BODY = 420
        local bodyW    = math.max(MIN_BODY, math.min(MAX_BODY, widest))
        f:SetWidth(bodyW + 2 * INSET)

        -- Give the body an explicit width matching the frame's inset box
        -- and restore wrap, so the multi-paragraph Skip Details flows
        -- within the border while the (shorter) Detection lines stay on
        -- one line. Anchored TOPLEFT only, so width must be set here.
        fs:SetWidth(bodyW)
        fs:SetWordWrap(true)
        fs:SetText(table.concat(lines, "\n\n"))

        -- Compute total height: top padding, title height, gap, body
        -- height, bottom padding. The close [X] overlays the top-right
        -- corner rather than occupying vertical space.
        local titleH = f.titleText:GetStringHeight() or 16
        local bodyH  = fs:GetStringHeight() or 0
        f:SetHeight(20 + titleH + 10 + bodyH + 18)

        -- Tag the frame with the raid's instanceID so the [ i ] button
        -- can recognize "already open for this raid" and toggle closed.
        f.rrSkipRaidID = raid and raid.instanceID or nil
    end

    -- Apply the user's window scale before positioning so the cursor
    -- math below uses the frame's final effective scale (mismatched
    -- scale would offset the anchor by the scale factor).
    f:SetScale(RR:GetSetting("windowScale", 1.0))

    -- Position at the cursor, hanging down-and-right of the click point
    -- so the [ i ] button stays uncovered. GetCursorPosition returns
    -- UIParent-space pixels; divide by the frame's own effective scale
    -- so the anchor lands at the cursor regardless of windowScale. Clamp
    -- so popups near a screen edge slide back into view.
    local mx, my = GetCursorPosition()
    local effScale = f:GetEffectiveScale() or 1
    f:ClearAllPoints()
    if mx and my and effScale > 0 then
        f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
            mx / effScale + 16, my / effScale - 16)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    f:Show()
    f:Raise()
end

function UI.HideSkipDetail()
    if skipDetailFrame then skipDetailFrame:Hide() end
end

-- Toggle for the [ i ] button: re-click the same row closes; click on a
-- different row swaps content; first click opens.
function UI.ToggleSkipDetail(raid)
    if skipDetailFrame and skipDetailFrame:IsShown()
       and skipDetailFrame.rrSkipRaidID
       and raid and skipDetailFrame.rrSkipRaidID == raid.instanceID then
        skipDetailFrame:Hide()
        return
    end
    UI.ShowSkipDetail(raid)
end

function UI._GetOrCreateLoadDialog()
    if UI._loadDialogFrame then return UI._loadDialogFrame end

    local LOAD_DIALOG_BASE = "LOADING"

    local f = CreateFrame("Frame", "RetroRunsLoadDialog", UIParent, "BackdropTemplate")
    f.loadBase = LOAD_DIALOG_BASE
    f:SetSize(340, 175)
    f:SetBackdrop(PanelBackdrop(PANEL_EDGE_SIZE_FULL))
    f:SetBackdropColor(1, 1, 1, RR:GetSetting("panelOpacity", 1.0))
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 240)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)

    -- RETRORUNS wordmark, retro font, two-tone like the panel title.
    -- Larger than the raid name below it. Pulled in from the top border.
    local brand = f:CreateFontString(nil, "OVERLAY")
    brand:SetFont(TITLE_FONT, 22, "OUTLINE")
    brand:SetPoint("TOP", f, "TOP", 0, -24)
    brand:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r")
    f.brand = brand

    -- Raid name (replaces "Route data found for:"), retro font, smaller
    -- than the wordmark above.
    local raidName = f:CreateFontString(nil, "OVERLAY")
    raidName:SetFont(TITLE_FONT, 13, "")
    raidName:SetPoint("TOP", brand, "BOTTOM", 0, -14)
    raidName:SetWidth(300)
    raidName:SetWordWrap(true)
    raidName:SetJustifyH("CENTER")
    raidName:SetTextColor(1, 1, 0)
    f.raidName = raidName

    -- Animated LOADING line in the retro font. "LOADING" stays put
    -- (centered as a unit) and the dots animate in a separate FontString
    -- anchored to its right, so the word doesn't shift left as dots are
    -- added. The pair is nudged left by half the max dot width so the
    -- whole thing reads centered.
    local loading = f:CreateFontString(nil, "OVERLAY")
    loading:SetFont(TITLE_FONT, 14, "")
    loading:SetPoint("TOP", raidName, "BOTTOM", -12, -14)
    loading:SetJustifyH("CENTER")
    loading:SetText(LOAD_DIALOG_BASE)
    f.loading = loading

    local loadingDots = f:CreateFontString(nil, "OVERLAY")
    loadingDots:SetFont(TITLE_FONT, 14, "")
    loadingDots:SetPoint("LEFT", loading, "RIGHT", 2, 0)
    loadingDots:SetJustifyH("LEFT")
    loadingDots:SetText("")
    f.loadingDots = loadingDots

    -- Button row: STANDARD / SKIP / CANCEL, raised off the bottom border
    -- so the SKIP footer below them stays inside the frame.
    local BTN_W, BTN_H, BTN_GAP = 84, 22, 6
    local function MakeButton(label, anchorX)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(BTN_W, BTN_H)
        b:SetText(label)
        b:SetPoint("BOTTOM", f, "BOTTOM", anchorX, 34)
        return b
    end
    local rowStride = BTN_W + BTN_GAP
    f.standardBtn = MakeButton("STANDARD", -rowStride)
    f.skipBtn     = MakeButton("SKIP", 0)
    f.cancelBtn   = MakeButton("CANCEL", rowStride)

    f.standardBtn:SetScript("OnClick", function()
        f:Hide()
        RR:LoadCurrentRaid()
    end)
    f.cancelBtn:SetScript("OnClick", function()
        f:Hide()
        RR:UnloadCurrentRaid()
    end)
    f.skipBtn:SetScript("OnClick", function()
        f:Hide()
        RR:LoadCurrentRaid("skip")
    end)

    -- Footer beneath SKIP, standard small font (retro is unreadable this
    -- small). Shows the disabled reason; hidden when SKIP is enabled.
    local skipFooter = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    skipFooter:SetPoint("TOP", f.skipBtn, "BOTTOM", 0, -1)
    skipFooter:SetJustifyH("CENTER")
    f.skipFooter = skipFooter

    f:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    UI._loadDialogFrame = f
    return f
end

-- Show the load dialog for the current raid. raidName is the display
-- string; the SKIP state is resolved from the live raid + difficulty.
--
-- SKIP has three states:
--   enabled              -- skip route authored AND unlocked at the
--                           current difficulty
--   disabled + "N/A"     -- this raid has no skip shortcut
--   disabled + "locked"  -- route authored but the player hasn't
--                           unlocked the skip here
-- "N/A" wins when both apply (no skip exists, so unlock state is moot).
function UI.ShowLoadDialog(raidName)
    local f = UI._GetOrCreateLoadDialog()
    local raid = RR.currentRaid
    local diff = RR.state and RR.state.currentDifficultyID

    f.raidName:SetText(raidName or (raid and raid.name) or "?")
    f.loading:SetText(f.loadBase)
    f.loadingDots:SetText("")

    -- Animate the trailing dots while shown. OnUpdate runs on the frame
    -- (FontStrings have no OnUpdate); it writes only the dots FontString,
    -- leaving "LOADING" fixed in place.
    f._dotElapsed = 0
    f._dotCount = 0
    f:SetScript("OnUpdate", function(self, elapsed)
        self._dotElapsed = (self._dotElapsed or 0) + elapsed
        if self._dotElapsed < 0.4 then return end
        self._dotElapsed = 0
        self._dotCount = ((self._dotCount or 0) + 1) % 4
        self.loadingDots:SetText(string.rep(".", self._dotCount))
    end)

    -- Resolve SKIP state.
    local hasRoute = RR:RaidHasSkipRoute(raid)
    local unlocked = hasRoute and RR:IsRaidSkipAvailableAtDifficulty(raid, diff)
    if hasRoute and unlocked then
        f.skipBtn:Enable()
        f.skipFooter:SetText(raid.skipToBoss or "")
    else
        f.skipBtn:Disable()
        if not hasRoute then
            f.skipFooter:SetText("N/A")
        elseif not RR:RaidSkipIsCascading(raid) then
            -- Non-cascading (achievement-gated) skips are Mythic-only.
            f.skipFooter:SetText("Mythic only")
        else
            f.skipFooter:SetText("locked")
        end
    end

    f:Show()
end

function UI.HideLoadDialog()
    if UI._loadDialogFrame then UI._loadDialogFrame:Hide() end
end

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
--                 Bosses with N achievements produce N rows; the boss name
--                 repeats so the column stays easy to scan.
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
local ACH_CELL_TODO   = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14|t"
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
    -- GetStringHeight, which is lazy after SetFont): call SetFont first
    -- with the measurement font, then SetText, then read GetStringWidth.
    -- Hidden so it never appears on screen.
    f.measureFS = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    f.measureFS:Hide()

    -- Legend below the table. Two FontStrings: meta-key on the left,
    -- soloable color key on the right. Splitting them lets the soloable
    -- key anchor to BOTTOMRIGHT independently of the meta-key text width.
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
                -- UIPanelButtonTemplate's chrome sits low in its SetSize box,
                -- so the visible button reads bottom-heavy if anchored at y.
                -- The +2 nudges it to the row's visual center.
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

    -- Live refresh on achievement events. Debounced 50ms to collapse
    -- CRITERIA_UPDATE bursts. Refresh only fires when the window is shown.
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

-- "[!] view special note" pulse driver. Advances encounterPulsePhase through
-- 0..15 every 0.1s (1.6s round trip) and calls UI.Update so the [!] glyph
-- re-renders at the new brightness. Purely cosmetic. Runs at 0.1s (not the 1s
-- heartbeat) so the breathing reads as smooth, and only when the panel is
-- allowed, a raid is loaded, and the encounter section is collapsed.
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
