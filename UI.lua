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
local BODY_FONT  = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local TITLE_SIZE = 20

local C_PINK   = { 0.95, 0.35, 0.78 }
local C_BLUE   = { 0.30, 0.80, 1.00 }
local C_LABEL  = "7CFC00"   -- section label colour (green)

-- Known teleporter node names -- highlighted orange in travel text
local TRAVEL_NODES = {
    "Ephemeral Plains Alpha",
    "Ephemeral Plains Omega",
    "Genesis Cradle Alpha",
    "Domination's Grasp",
    "The Grand Design",
    "The Endless Foundry",
}

-------------------------------------------------------------------------------
-- Font helper
-------------------------------------------------------------------------------

local function SafeSetFont(fs, path, size, flags)
    if not fs then return end
    if not (path and fs:SetFont(path, size, flags or "")) then
        fs:SetFont(BODY_FONT, size, flags or "")
    end
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
    local scale    = self:GetEffectiveScale()
    local pscale   = UIParent:GetEffectiveScale()
    local x = (cx * scale - pcx * pscale) / pscale
    local y = (cy * scale - pcy * pscale) / pscale
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
panel.logo:SetSize(34, 34)
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
    -- Also close the standalone transmog browser if it's open. The two
    -- windows are conceptually a single experience: closing the main panel
    -- should leave nothing of RetroRuns visible.
    if tmogWindow and tmogWindow:IsShown() then
        browserState.active = false
        tmogWindow:Hide()
    end
end)

-- Test-mode label
panel.mode = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.mode:SetPoint("TOPRIGHT", -34, -14)
panel.mode:SetText("")

-- Map button
panel.mapBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
panel.mapBtn:SetSize(60, 20)
panel.mapBtn:SetPoint("TOPRIGHT", -36, -36)
panel.mapBtn:SetText("Map")
panel.mapBtn:SetScript("OnClick", function() RR:ShowCurrentMapForStep() end)

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

-- Boss Encounter section. Was a plain FontString; converted 2026-04-25
-- to a Button so the section can be clicked to expand/collapse the
-- soloTip and Achievements content. Default state is collapsed for
-- bosses with custom notes (player clicks to view); for bosses with
-- no custom note ("Standard Nuke" or empty), the line reads "Standard"
-- and isn't clickable. Single global expand/collapse state stored in
-- RetroRunsDB.encounterExpanded -- one click affects all bosses.
panel.encounter = CreateFrame("Button", nil, panel)
panel.encounter:SetPoint("TOPLEFT", panel.travel, "BOTTOMLEFT", 0, -8)
panel.encounter:SetSize(BODY_WIDTH, 14)
panel.encounter.label = panel.encounter:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.encounter.label:SetPoint("TOPLEFT", 0, 0)
panel.encounter.label:SetWidth(BODY_WIDTH)
panel.encounter.label:SetJustifyH("LEFT")
panel.encounter.label:SetWordWrap(true)
panel.encounter.label:SetNonSpaceWrap(true)
-- Proxy SetText/GetHeight to the label for compatibility with anchor
-- callers (panel.transmog anchors to panel.encounter's BOTTOMLEFT).
panel.encounter.SetText   = function(self, t) self.label:SetText(t) end
panel.encounter.GetHeight = function(self) return self.label:GetHeight() end

-- Hover and click. Hover effect (gold tint) only applies when the
-- button is currently in clickable state (custom note exists) -- this
-- is signalled by panel.encounter.clickable being set true by the
-- render path. When false, hover is a no-op. Click toggles the
-- global expand/collapse state and forces a UI refresh.
--
-- Hyperlinks (achievements) need their own routing because converting
-- panel.encounter from a plain FontString to a Button broke the
-- bubble-to-panel path the achievement-click handler used to rely on.
-- The Button now owns hyperlinks directly via SetHyperlinksEnabled +
-- an OnHyperlinkClick script that routes to SetItemRef. A flag
-- (clickFromLink) is set when a hyperlink is clicked and consumed by
-- OnClick so the expand/collapse toggle doesn't also fire. WoW dispatches
-- OnHyperlinkClick before OnClick, which is what makes the flag pattern
-- work.
panel.encounter.clickable = false
panel.encounter:SetHyperlinksEnabled(true)
panel.encounter:SetScript("OnHyperlinkClick", function(self, link, text, button)
    self.clickFromLink = true
    SetItemRef(link, text, button)
end)
panel.encounter:SetScript("OnEnter", function(self)
    if self.clickable then
        self.label:SetTextColor(1.0, 0.85, 0.0, 1.0)
    end
end)
panel.encounter:SetScript("OnLeave", function(self)
    self.label:SetTextColor(1.0, 1.0, 1.0, 1.0)
end)
panel.encounter:RegisterForClicks("LeftButtonUp")
panel.encounter:SetScript("OnClick", function(self)
    if self.clickFromLink then
        self.clickFromLink = nil
        return
    end
    if not self.clickable then return end
    local now = RR:GetSetting("encounterExpanded")
    RR:SetSetting("encounterExpanded", not now)
    UI.Update()
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

-- Footer (two rows):
--   Bottom row: "Created by Photek" on the left, version on the right,
--               anchored 8px up from the panel's bottom edge.
--   Top row:    "/rr - Toggle  |  /rr settings  |  /rr reset  |  /rr tmog"
--               anchored above the credit row with a 4px gap. Because it
--               anchors relative to the credit row rather than an absolute
--               offset from the panel bottom, the two rows never overlap
--               regardless of font size.
panel.credit = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.credit:SetPoint("BOTTOMLEFT", PAD_LEFT, 8)
panel.credit:SetText("Created by |cff4DCCFFPhotek|r")

panel.version = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.version:SetPoint("BOTTOMRIGHT", -PAD_RIGHT, 8)
panel.version:SetText("v" .. RetroRuns.VERSION)

panel.footer = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.footer:SetPoint("BOTTOMLEFT",  panel.credit,  "TOPLEFT",  0, 4)
panel.footer:SetPoint("BOTTOMRIGHT", panel.version, "TOPRIGHT", 0, 4)
panel.footer:SetJustifyH("LEFT")
panel.footer:SetText("/rr - Toggle  |  /rr settings  |  /rr reset  |  /rr tmog")

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
-- panel needs room for the footer stack (slash commands ~y=22, credit/version
-- ~y=8, each ~12px tall) plus a visual gap between the list and the footer.
local PANEL_FOOTER_RESERVE   = 56   -- pixels
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
    local targets = {
        { panel.mode,       11, "OUTLINE" },
        { panel.raid,       14, ""        },
        { panel.pills,      11, ""        },
        { panel.progress,   14, "OUTLINE" },
        { panel.next,       14, "OUTLINE" },
        { panel.travel,     12, ""        },
        { panel.encounter.label, 12, ""    },
        { panel.transmog.label, 12, ""    },
        { panel.listHeader, 12, "OUTLINE" },
        { panel.list,       12, ""        },
        { panel.footer,     10, ""        },
        { panel.credit,     10, ""        },
        { panel.version,    10, ""        },
    }
    for _, t in ipairs(targets) do
        SafeSetFont(t[1], BODY_FONT, math.max(8, t[2] + bump), t[3])
        ForceFontRelayout(t[1])
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
            tmogWindow.contentText:SetFont(STANDARD_TEXT_FONT, fontSize - 1, "")
        end
    end
    -- (intentionally no scale applied to settingsFrame)

    -- Re-fit the panel + auxiliary frames now that fonts and scale changed.
    -- AutoSize computes heights from line counts (not GetStringHeight) so a
    -- single synchronous pass is sufficient -- no deferred re-measure pass
    -- needed, which eliminates the visible pop-in flicker.
    UI.AutoSize()
end

-- Resizes the main panel (and ancillary frames) to fit their current
-- content. Safe to call at any time; idempotent.
function UI.AutoSize()
    -- MAIN PANEL -----------------------------------------------------------
    -- The top-down layout ends at panel.list. Rather than asking WoW for
    -- the rendered height (which is lazy and causes a pop-in flicker), we
    -- compute it deterministically from text line count + font size, plus
    -- each fixed-height widget above the list.
    if panel.list and panel.list:GetText() then
        local fontSize   = RR:GetSetting("fontSize", 12)
        local lineHeight = fontSize + 4

        local listText = panel.list:GetText() or ""
        local lines = 1
        for _ in listText:gmatch("\n") do lines = lines + 1 end
        local listH = lines * lineHeight

        -- Footer reserve is now dynamic -- it must fit two footer rows
        -- (slash commands + credit line) both at the current font size.
        -- Footer uses a 10pt font (GameFontDisableSmall + bump), which is
        -- smaller than body lines but still grows with the user's setting.
        local footerFontSize = math.max(8, 10 + (fontSize - 12))
        local footerReserve  = (2 * (footerFontSize + 4))  -- two rows
                             + 4                            -- gap between rows
                             + 8                            -- bottom margin
                             + 8                            -- gap above row 1

        local parentTop      = panel:GetTop()
        local listHeaderBot  = panel.listHeader and panel.listHeader:GetBottom()
        if parentTop and listHeaderBot then
            -- COORDINATE-SYSTEM NOTE (corrected 2026-04-21, third time
            -- through this code; getting it right is harder than it
            -- looks):
            --
            -- Per Wowpedia "UI scaling": GetTop/GetBottom/GetHeight all
            -- return values in the FRAME's own scaled coordinate system,
            -- which is also what SetHeight expects. So `parentTop`,
            -- `listHeaderBot`, `listH` (built from fontSize, which lives
            -- in panel's coord system), and `footerReserve` are all in
            -- the SAME coordinate system. `desired = sum of those` is
            -- directly usable as `panel:SetHeight(desired)`. NO division
            -- by scale.
            --
            -- The only place a scale conversion IS needed is for `maxH`:
            -- screenH comes from UIParent (a different frame, different
            -- effective scale), so converting it to panel's coord system
            -- requires dividing by panel:GetScale(). That conversion was
            -- correct in the original code and remains correct here.
            --
            -- HISTORY: v0.3.5 attempted a fix that moved the `/scale`
            -- from `desired` onto `topToListTop` -- this was less wrong
            -- than the original but still wrong. v0.3.x (this fix)
            -- removes the spurious `/scale` from `desired` entirely.
            -- At scale 1.3, the original code undersized the panel by
            -- ~24%; the v0.3.5 attempt undersized by ~5%; this version
            -- sizes correctly.
            local scale          = panel:GetScale() or 1
            local topToListTop   = (parentTop - listHeaderBot) + 4
            local desired        = topToListTop + listH + footerReserve
            local screenH        = UIParent:GetHeight() or 900
            local maxH           = (screenH * 0.9) / scale
            local minH           = 360
            panel:SetHeight(math.max(minH, math.min(maxH, desired)))
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
        -- height, so effective line height is ~fontSize + 4.
        local lineHeight = fontSize + 4
        local textH      = lines * lineHeight

        -- Popup chrome: dropdown stack + title bar + margins.
        local chrome = 32      -- title bar
                     + 3 * 32  -- three dropdowns
                     + 10      -- gap between dropdowns and text
                     + 14      -- bottom margin
        local desired = chrome + textH
        local clamped = math.max(POPUP_CONTENT_MIN,
                                 math.min(POPUP_CONTENT_CEILING, desired))
        tmogWindow:SetHeight(clamped)
    end

    -- SETTINGS PANEL -------------------------------------------------------
    -- Frame height hugs the last control + margin. Only a handful of
    -- widgets; measuring the lowest is sufficient.
    if settingsFrame then
        local lowestBottom = 0
        for _, child in ipairs({ settingsFrame.fontSlider,
                                  settingsFrame.scaleSlider,
                                  settingsFrame.minimapCheck }) do
            if child then
                local y = ContentBottomY(settingsFrame, child)
                if y > lowestBottom then lowestBottom = y end
            end
        end
        if lowestBottom > 0 then
            settingsFrame:SetHeight(lowestBottom + 24)
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
    f:SetSize(300, 210)
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
        local scale    = self:GetEffectiveScale()
        local pscale   = UIParent:GetEffectiveScale()
        local x = (cx * scale - pcx * pscale) / pscale
        local y = (cy * scale - pcy * pscale) / pscale
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
    f.title:SetText("RetroRuns Settings")

    f.versionLabel = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.versionLabel:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -4)
    f.versionLabel:SetText("v" .. RetroRuns.VERSION)

    f.closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeButton:SetPoint("TOPRIGHT", -4, -4)

    -- Build a slider with a configurable label that includes the current
    -- value. The label updates live during drag (via OnValueChanged hooked
    -- below) and on initial display (via RefreshLabel called here + on
    -- SyncSettingsControls when the settings panel is shown).
    --
    -- `formatValue` (optional) maps the raw slider value to the string shown
    -- in the label. Defaults to integer rounding. Used by the scale slider
    -- to convert its 80-130 internal range to a "1.00x"-style display.
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
        s:RefreshLabel()  -- initial render before any value change
        return s
    end

    f.fontSlider  = MakeSlider("RetroRunsFontSlider",  "Font Size",    10, 18,  1, f.versionLabel, -24)
    f.scaleSlider = MakeSlider("RetroRunsScaleSlider", "Window Scale", 80, 130, 5, f.fontSlider, -34,
        function(v)
            -- Slider stores 80-130 (a percentage * 100); display as "1.00x"
            -- so the user sees the actual multiplier they've set, not the
            -- internal storage representation.
            return ("%.2fx"):format(v / 100)
        end)
    f.scaleSlider.Low:SetText("0.8")
    f.scaleSlider.High:SetText("1.3")

    local function MakeCheckbox(label, anchorWidget, offsetY, getter, setter)
        local cb = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", anchorWidget, "BOTTOMLEFT", 0, offsetY)
        cb.Text:SetText(label)
        cb:SetScript("OnClick", function(self)
            setter(self:GetChecked())
            UI.ApplySettings()
        end)
        cb.Sync = function(self) self:SetChecked(getter()) end
        return cb
    end

    f.minimapCheck = MakeCheckbox(
        "Show minimap button",
        f.scaleSlider, -28,
        -- showMinimap default is true; only an explicit `false` hides.
        function() return RR:GetSetting("showMinimap") ~= false end,
        function(val)
            RR:SetSetting("showMinimap", val)
            if RR.minimapButton then
                if val then RR.minimapButton:Show()
                else RR.minimapButton:Hide() end
            end
        end)

    f.resetButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.resetButton:SetSize(120, 22)
    f.resetButton:SetPoint("BOTTOMLEFT", 14, 12)
    f.resetButton:SetText("Reset to Default")
    f.resetButton:SetScript("OnClick", function()
        SlashCmdList["RETRORUNS"]("reset")
    end)

    f.fontSlider:SetScript("OnValueChanged", function(self, value)
        if not RetroRunsDB then return end
        RR:SetSetting("fontSize", math.floor(value + 0.5))
        self:RefreshLabel()
        UI.ApplySettings()
    end)

    f.scaleSlider:SetScript("OnValueChanged", function(self, value)
        if not RetroRunsDB then return end
        RR:SetSetting("windowScale", value / 100)
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
    -- SetValue only fires OnValueChanged if the value actually changes, so
    -- on first sync (slider at construction-time min, DB matches) the label
    -- wouldn't update. Force a refresh to cover that edge case.
    settingsFrame.fontSlider:RefreshLabel()
    settingsFrame.scaleSlider:RefreshLabel()
    settingsFrame.minimapCheck:Sync()
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

-- Build a case-insensitive Lua pattern from a literal string. Lua's
-- `string.gsub` is case-sensitive and has no flag to disable that. The
-- idiomatic workaround is to expand each ASCII letter into a `[Aa]` class
-- so the pattern matches both cases.
--
-- Why we need this: data-file notes often write boss names lowercased
-- after a preposition ("walk to the Tarragrue"), but our boss-name
-- registry stores the canonical form ("The Tarragrue"). A case-sensitive
-- gsub of "The Tarragrue" against "the Tarragrue" misses entirely. The
-- fallback to alias-based highlighting is also blocked because
-- "Tarragrue" is a substring of the full name (substring-skip rule, see
-- below). Net result: no highlighting at all for that mention.
--
-- Also escapes Lua pattern magic characters (.()%+-*?[^$) so names like
-- "Soulrender Dormazain" or future raids' "Sun King's Salvation" pattern-
-- match literally rather than treating their punctuation as metacharacters.
--
-- Side effect: the replacement uses the canonical-cased form, so a note
-- written as "to the Tarragrue" renders as "to The Tarragrue" with orange
-- highlight. Mildly weird mid-sentence capitalization but acceptable for
-- the gain of not having to think about case in every note.
local PATTERN_MAGIC = "[%(%)%.%%%+%-%*%?%[%]%^%$]"
local function CaseInsensitivePattern(s)
    -- 1. Escape Lua pattern magic characters
    local escaped = s:gsub(PATTERN_MAGIC, "%%%1")
    -- 2. Replace each ASCII letter with a [Aa]-style class
    local pattern = escaped:gsub("%a", function(letter)
        return "[" .. letter:lower() .. letter:upper() .. "]"
    end)
    return pattern
end

local function HighlightNames(text)
    if not text or text == "" then return text end

    -- Transport locations
    for _, name in ipairs(TRAVEL_NODES) do
        text = text:gsub(CaseInsensitivePattern(name), OrangeText(name))
    end

    -- Boss names from current raid
    if RR.currentRaid and RR.currentRaid.bosses then
        for _, boss in ipairs(RR.currentRaid.bosses) do
            if boss.name and #boss.name > 3 then
                -- Capture the substitution count from gsub. We need it
                -- below to decide whether the alias loop is safe to run.
                local newText, fullMatched = text:gsub(
                    CaseInsensitivePattern(boss.name),
                    OrangeText(boss.name))
                text = newText
                -- Also highlight common aliases. The alias gsub can cause
                -- DOUBLE-WRAP if it matches inside text already wrapped by
                -- the full-name gsub above -- that breaks WoW's color codes
                -- (`|r` resets to default rather than popping a stack, so
                -- the inner close-code leaves the tail of the name
                -- uncolored). Example: "Fatescribe Roh-Kalo" wrapped, then
                -- "Fatescribe" alias re-wraps inside it -> " Roh-Kalo"
                -- renders uncolored.
                --
                -- Old defense: skip any alias that's a substring of the
                -- full name. That defense was too aggressive -- it also
                -- blocked legitimate alias-only mentions like "follow the
                -- path to Eye of the Jailer" (no leading "The"), where
                -- the full-name gsub doesn't fire and the alias is the
                -- only chance to highlight.
                --
                -- Smarter rule: skip aliases ONLY if the full-name gsub
                -- actually performed at least one substitution in this
                -- text (`fullMatched > 0`). If the full name didn't appear
                -- in this text at all, the alias has no double-wrap risk
                -- and is safe to apply.
                --
                -- Trade-off: if a single text contains BOTH the full name
                -- AND a standalone alias usage (e.g. "Kill Fatescribe
                -- Roh-Kalo, then Fatescribe will respawn"), the standalone
                -- usage stays unwrapped. Acceptable: contrived case, much
                -- rarer than the alias-only or full-name-only cases.
                if boss.aliases and fullMatched == 0 then
                    for _, alias in ipairs(boss.aliases) do
                        if #alias > 3 then
                            text = text:gsub(
                                CaseInsensitivePattern(alias),
                                OrangeText(alias))
                        end
                    end
                end
            end
        end
    end

    -- Map/zone names from current raid
    if RR.currentRaid and RR.currentRaid.maps then
        for _, mapName in pairs(RR.currentRaid.maps) do
            if mapName and #mapName > 3 then
                text = text:gsub(CaseInsensitivePattern(mapName), OrangeText(mapName))
            end
        end
    end

    -- Difficulty words (LFR/Normal/Heroic/Mythic) get Blizzard's standard
    -- item-quality colors. Done LAST so other highlighters can't swallow
    -- these words first.
    text = ColorizeDifficulties(text)

    return text
end

local function GetBestMapForStep(step)
    if not step then return nil end
    local playerMapID = C_Map and C_Map.GetBestMapForUnit and
                        C_Map.GetBestMapForUnit("player")
    local worldMapID  = WorldMapFrame and WorldMapFrame:GetMapID()
    for _, mapID in ipairs({ playerMapID, worldMapID }) do
        if mapID then
            if step.segments then
                for _, seg in ipairs(step.segments) do
                    if seg.mapID == mapID then return mapID end
                end
            elseif step.mapID == mapID then
                return mapID
            end
        end
    end
    return playerMapID or worldMapID
end

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

local function BuildTravelText(step)
    local prefix = ("|cff%sTraveling:|r "):format(C_LABEL)
    if not step then return prefix .. "N/A" end
    local mapID = GetBestMapForStep(step)
    if step.segments and mapID then
        local relevant = RR:GetRelevantSegmentsForMap(step, mapID)
        for _, seg in ipairs(relevant) do
            if seg.note then return prefix .. HighlightNames(seg.note) end
        end
        for _, seg in ipairs(step.segments) do
            if seg.mapID == mapID and seg.note then
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
    -- No segment matches the current map (e.g. player is at the instance entrance
    -- after resuming a run). Fall back to the first segment note so there is always
    -- some useful direction shown rather than N/A.
    if step.segments and step.segments[1] and step.segments[1].note then
        return prefix .. "|cff888888(Open map for directions)|r  "
            .. HighlightNames(step.segments[1].note)
    end
    return prefix .. "|cff888888Open the map and select a section to see directions.|r"
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
--      the encounter expand state. Achievements were previously
--      bundled with the encounter expand toggle; decoupled 2026-04-25
--      so each section can have its own collapse behaviour later.
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
        headerLine = prefix .. "|cffaaaaaaview special note|r"
        clickable  = true
    else
        local tip = (boss and boss.soloTip) or step.soloTip or ""
        tip = tip:gsub("%.$", "")
        tip = HighlightNames(tip)
        headerLine = prefix .. tip
        clickable  = true
    end

    -- Achievements + Special Loot render unconditionally below.
    local lines = { headerLine }
    local achBlock = BuildAchievementsBlock(boss)
    if achBlock ~= "" then
        table.insert(lines, "")
        table.insert(lines, achBlock)
    end
    if boss then
        local special = BuildSpecialLootSection(boss)
        if special then
            table.insert(lines, "")
            table.insert(lines, special)
        end
    end

    return table.concat(lines, "\n"), clickable
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
}
local SPECIAL_KIND_COLOR = {
    mount      = "ff8080ff",   -- light blue
    pet        = "ffff80ff",   -- light magenta
    toy        = "ffffcc66",   -- light amber
    decor      = "ffd4a373",   -- warm cream/tan (evokes housing/home)
    manuscript = "ff7fffd4",   -- aquamarine (evokes dragonriding sky/scale)
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
-- item.kind. Each API path here is documented in HANDOFF Section 6 under
-- the Special Loot design sketch.
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

    elseif item.kind == "decor" then
        -- C_HousingCatalog landed in 11.2.7 (Dec 2025). On earlier
        -- clients, or if the API is unavailable for any reason, we
        -- return "missing" so the UI still renders but never claims
        -- collected -- safer than crashing or silently omitting the row.
        --
        -- Two candidate function names surfaced during research:
        -- `IsItemOwned(catalogEntryID)` (LobeHub skill snippet) and
        -- `IsDecorCollected(...)` (Housing Decor Guide addon changelog).
        -- The public wiki is incomplete. We try both defensively via
        -- pcall and accept whichever responds with a boolean.
        if not C_HousingCatalog then return "missing" end

        -- Resolve the catalog entry for this itemID. The canonical call
        -- per our research is GetCatalogEntryInfoByItem.
        local entry
        if C_HousingCatalog.GetCatalogEntryInfoByItem then
            local ok, result = pcall(
                C_HousingCatalog.GetCatalogEntryInfoByItem, item.id)
            if ok then entry = result end
        end
        if not entry then return "missing" end

        -- Entry may be a struct (likely) or a scalar catalogID (possible
        -- given the inconsistent docs). Handle both. If it's a struct,
        -- prefer an explicit `isCollected`/`isOwned` field if present.
        if type(entry) == "table" then
            if entry.isCollected ~= nil then
                return entry.isCollected and "collected" or "missing"
            end
            if entry.isOwned ~= nil then
                return entry.isOwned and "collected" or "missing"
            end
            -- Fall back to probing by catalog ID, if we can extract one.
            local catID = entry.catalogEntryID or entry.decorID or entry.id
            if catID and C_HousingCatalog.IsItemOwned then
                local ok, owned = pcall(C_HousingCatalog.IsItemOwned, catID)
                if ok and owned ~= nil then
                    return owned and "collected" or "missing"
                end
            end
            if catID and C_HousingCatalog.IsDecorCollected then
                local ok, owned = pcall(C_HousingCatalog.IsDecorCollected, catID)
                if ok and owned ~= nil then
                    return owned and "collected" or "missing"
                end
            end
        elseif type(entry) == "number" then
            -- Scalar catalog ID form. Probe both ownership-check names.
            if C_HousingCatalog.IsItemOwned then
                local ok, owned = pcall(C_HousingCatalog.IsItemOwned, entry)
                if ok and owned ~= nil then
                    return owned and "collected" or "missing"
                end
            end
            if C_HousingCatalog.IsDecorCollected then
                local ok, owned = pcall(C_HousingCatalog.IsDecorCollected, entry)
                if ok and owned ~= nil then
                    return owned and "collected" or "missing"
                end
            end
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
            -- "(Pet, Mythic only)" with the restriction in the Blizzard
            -- mythic quality color (ffa335ee = purple) so the gate is
            -- scannable at a glance. The colored suffix is spliced
            -- inside the kindColor wrapper so the parens themselves stay
            -- the kind's color.
            local kindInner = kindLabel
            if item.mythicOnly then
                -- Close kindColor, insert mythic-purple "Mythic only",
                -- reopen kindColor for the closing paren. The comma
                -- stays in kindColor so the parenthetical reads as one
                -- visually-connected group.
                kindInner = kindLabel .. ", |r|cffa335eeMythic only|r|c" .. kindColor
            end

            -- Bracketed state indicator goes BEFORE the name, matching the
            -- visual language of the transmog section's per-difficulty dot
            -- row: "|cff777777[ |r" ... "|cff777777 ]|r" with a glyph
            -- inside. Collected = green check texture (Blizzard ReadyCheck
            -- icon); uncollected = gray letter "X". See the glyph constants
            -- above for why we don't use Unicode U+2713 / U+2717.
            -- We CAN'T wrap the item name with a color because itemLinks
            -- embed their own |cff<quality>...|r code for item rarity, and
            -- WoW's color codes don't nest -- the inner code wins. Keeping
            -- the state indicator as a separate prefix preserves the link's
            -- native quality color.
            table.insert(lines,
                ("|cff777777[ |r|c%s%s|r|cff777777 ]|r %s |c%s(%s)|r"):format(
                    stateColor, stateGlyph, display, kindColor, kindInner))
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
-- LFR/N/H sources. Switched to strict per-difficulty rollup 2026-04-21.
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
            return header .. " |cff00ff00All appearances collected!|r"
        end
        return header .. "\n- " .. FormatStatsFragment(n, s) .. "  " .. clickHnt
    end

    -- Both counts computed. Is everything done across the board?
    local curDone = (curNeeded == 0 and curShared == 0)
    local othDone = (not othTotal) or (othNeeded == 0 and othShared == 0)
    if curDone and othDone then
        return header .. " |cff00ff00All appearances collected!|r"
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
-- Sanctum's actual distribution (from 2026-04-20 ATT-driven rewrite):
-- 96 per-difficulty items, 1 binary (Edge of Night), 1 partial
-- (Rae'shalare, stored in ATT as bonusID variants our batch rewrite
-- didn't handle -- left under-modeled, renders sensibly). Sylvanas's
-- loot is per-difficulty despite earlier notes suggesting otherwise.
-- Future raids auto-dispatch without per-boss flags.
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
-- via the |T...:14:14|t markup, while single text characters ("X", "+")
-- are narrower in WoW's default font (Friz Quadrata QT). To keep brackets
-- visually aligned across rows, the text glyphs are padded with extra
-- spaces so "[ X ]" and "[ + ]" occupy the same horizontal space as the
-- "[ check-texture ]" row. The padding is part of the glyph string so the
-- color-wrapper code doesn't need to know about it.
--
-- VERTICAL-CENTERING NOTE: Friz Quadrata QT renders "~" near the top of
-- the line box (tilde sits high in most fonts), making "[ ~ ]" look
-- top-aligned inside the bracket. "+" sits mid-line-height just like "X",
-- so the two text glyphs line up with each other and with the centered
-- texture.
local BINARY_GLYPH_COLLECTED = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local BINARY_GLYPH_SHARED    = " + "
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
            nameText = ("|cffffffff%s|r"):format(item.name)
        end
        return ("%s  %s"):format(BuildDotRow(item), nameText)
    end

    -- Emit binary-shape group first.
    for _, item in ipairs(binaryItems) do
        table.insert(lines, FormatItemRow(item))
    end

    -- Blank-line separator between groups, but only if both groups have
    -- content (otherwise we'd emit a trailing blank line for no reason).
    if #binaryItems > 0 and #perDiffItems > 0 then
        table.insert(lines, "")
    end

    -- Emit per-difficulty group.
    for _, item in ipairs(perDiffItems) do
        table.insert(lines, FormatItemRow(item))
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
    --   about specific collection math. See HANDOFF for the full
    --   investigation trail (2026-04-22 session, multiple vendorscan
    --   rounds across Kyrian + Necrolord covenants).
    --
    -- Row shape:
    --   Main-Hand Weapons:   [some collected]
    --   Off-Hand Weapons:    [all collected]
    --     -> Redeem tokens at your Kyrian weapon vendor in Bastion (Elysian Hold)
    --
    -- No-covenant fallback:
    --     -> No covenant detected -- align with a covenant to redeem
    --       weapon tokens.
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

            -- Vendor hint line. Covenant detection via C_Covenants (same
            -- pattern /rr vendorscan uses). If no covenant is active,
            -- emit a covenant-agnostic nudge instead.
            --
            -- Rendering:
            --   Covenant name + zoneMain are in the covenant's theme
            --   color (Kyrian blue, Venthyr red, Night Fae purple,
            --   Necrolord green -- see Data/CastleNathria.lua
            --   weaponVendors). zoneSub (Elysian Hold, Sinfall, etc.)
            --   stays white for visual contrast. Static framing text
            --   ("-> Visit your", "weapon vendor in", parens) in soft
            --   gray so the named pieces stand out.
            --
            -- Arrow: plain "->" ASCII rather than U+2192 "→" because
            -- WoW's default UI font (Friz Quadrata QT) doesn't carry
            -- a glyph for U+2192 -- it renders as an empty box. Same
            -- constraint that forced the ReadyCheck textures elsewhere
            -- (see HANDOFF trap list).
            local covID = 0
            if C_Covenants and C_Covenants.GetActiveCovenantID then
                covID = C_Covenants.GetActiveCovenantID() or 0
            end
            local vendors = raid.weaponVendors
            local vendorInfo = vendors and vendors[covID]
            if vendorInfo then
                local cc = vendorInfo.covenantColor or "ffffffff"
                table.insert(lines,
                    ("|cff888888  -> Redeem tokens at your |r|c%s%s|r|cff888888 weapon vendor in |r|c%s%s|r|cff888888 (|r|cffffffff%s|r|cff888888)|r"):format(
                        cc, vendorInfo.covenantName,
                        cc, vendorInfo.zoneMain,
                        vendorInfo.zoneSub))
            else
                table.insert(lines,
                    "|cffff9333  -> No covenant detected|r|cff888888 -- align with a covenant to redeem weapon tokens.|r")
            end
        end
    end

    -- Optional per-boss footnote. Used to surface collectible context that
    -- doesn't fit the existing schema -- e.g., Sarkareth's Void-Touched
    -- Curio omnitoken, which exchanges for any tier slot and so doesn't
    -- fit the fixed-slot tokenSources mapping. The footnote tells the
    -- player "yes there's more here, just not in the format the dots/
    -- checkbox represent." Rendered in light grey above the color legend
    -- (close enough to the loot list to read as commentary on it; the
    -- legend stays at the very bottom as the visual anchor).
    --
    -- The schema accepts two forms:
    --   string                   -- rendered as-is, embedded WoW markup OK
    --   { text=..., itemID=N }   -- {item} placeholder substituted with
    --                               GetItemInfo(itemID)'s real WoW item
    --                               link (clickable, hover-tooltips, shift-
    --                               clickable into chat). Cold-cache fallback
    --                               to a colored static name if GetItemInfo
    --                               returns nil before the cache warms.
    if boss.tmogFootnote then
        local footnoteText
        if type(boss.tmogFootnote) == "table" then
            local f = boss.tmogFootnote
            local sub
            if f.itemID then
                local _, itemLink = GetItemInfo(f.itemID)
                sub = itemLink   -- nil on cold cache; fallback below
            end
            if not sub then
                -- Cold-cache fallback: render a bracketed colored name in
                -- the WoW-link visual style. Loses clickability for this
                -- one render, but text won't be empty/broken. Subsequent
                -- renders (after the client warms the item-info cache)
                -- will produce a real link.
                local fallbackName = (f.itemID and GetItemInfo(f.itemID))
                                     or "(item)"
                sub = ("|cffa335ee[%s]|r"):format(fallbackName)
            end
            footnoteText = (f.text or ""):gsub("{item}", sub)
        else
            footnoteText = boss.tmogFootnote
        end
        if footnoteText and footnoteText ~= "" then
            table.insert(lines, "")
            table.insert(lines, ("|cff9d9d9d%s|r"):format(footnoteText))
        end
    end

    -- Legend at the bottom. Covers both shapes: the binary bracket's
    -- three states (collected/shared/missing) use the same color palette
    -- as the per-difficulty dots, and "white = needed now" only applies
    -- to the per-difficulty strip (binary rows don't track current
    -- difficulty since the appearance doesn't vary).
    if activeName then
        table.insert(lines, "")
        table.insert(lines,
            ("|c%sgreen|r|cff888888 = collected      |r|c%sgold|r|cff888888 = via another item|r"):format(
                DOT_COLLECTED, DOT_SHARED))
        table.insert(lines,
            ("|c%swhite|r|cff888888 = needed (current difficulty)  |r|c%sgray|r|cff888888 = not collected|r"):format(
                DOT_ACTIVE, DOT_INACTIVE))
    end

    return table.concat(lines, "\n")
end

-------------------------------------------------------------------------------
-- Transmog browser: data enumeration
-------------------------------------------------------------------------------

-- Browser selection state is forward-declared near the top of this file so
-- early handlers on panel.transmog can close over it. See the declaration
-- of `browserState` up there.

-- Expansion ordering used by the transmog browser's dropdown. Ascending
-- (oldest first) so Classic, BC, Wrath... appear in the order players
-- would progress through them chronologically. Compare with
-- EXPANSION_ORDER_NEWEST_FIRST below, used by the idle-state supported-
-- raids list (which benefits from newest-first since that's what most
-- players care about at a glance).
local EXPANSION_ORDER_ASCENDING = {
    "Classic", "Burning Crusade", "Wrath of the Lich King",
    "Cataclysm", "Mists of Pandaria", "Warlords of Draenor",
    "Legion", "Battle for Azeroth", "Shadowlands", "Dragonflight",
    "The War Within", "Midnight",
}

-- Gather all loaded raids grouped by expansion. Called fresh each time a
-- dropdown opens so newly-added raid data files appear without a reload.
local function EnumerateRaids()
    local byExpansion = {}
    for _, raid in pairs(RetroRuns_Data or {}) do
        local exp = raid.expansion or "Unknown"
        byExpansion[exp] = byExpansion[exp] or {}
        table.insert(byExpansion[exp], raid)
    end
    for _, raids in pairs(byExpansion) do
        table.sort(raids, function(a, b) return (a.name or "") < (b.name or "") end)
    end
    local expansions = {}
    local seen = {}
    for _, e in ipairs(EXPANSION_ORDER_ASCENDING) do
        if byExpansion[e] then
            table.insert(expansions, e)
            seen[e] = true
        end
    end
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

-- Display helper: "(7/9)" with have = total - needed.
local function FormatCountSuffix(needed, _, total)
    if not total or total == 0 then return "" end
    local have = total - needed
    return (" (%d/%d)"):format(have, total)
end

local function GetBrowserSelection()
    local raid = browserState.raidKey and RetroRuns_Data
                 and RetroRuns_Data[browserState.raidKey]
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
        if saved.raidKey and RetroRuns_Data[saved.raidKey] then
            browserState.raidKey   = saved.raidKey
            browserState.expansion = saved.expansion
                                     or RetroRuns_Data[saved.raidKey].expansion
            browserState.bossIndex = saved.bossIndex or 1
        end
    end

    if not browserState.raidKey then
        local currentID = RR.currentRaid and RR.currentRaid.instanceID
        if currentID and RetroRuns_Data[currentID] then
            browserState.raidKey   = currentID
            browserState.expansion = RetroRuns_Data[currentID].expansion
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
    f:SetBackdropColor(0.03, 0.03, 0.03, 0.95)
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
        local selRaid = browserState.raidKey and RetroRuns_Data[browserState.raidKey]
        if selRaid then raidName = selRaid.name or "?" end
        UIDropDownMenu_SetText(ddRaid, raidName)

        -- Boss dropdown (within current raid)
        UIDropDownMenu_Initialize(ddBoss, function()
            local raid = browserState.raidKey and RetroRuns_Data[browserState.raidKey]
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
        local _, boss = GetBrowserSelection()
        local detail = boss and BuildTransmogDetail({ boss = boss })
                              or "Select a raid and boss."
        text:SetText(detail or "")
        local fontSize = RR:GetSetting("fontSize", 12)
        text:SetFont(STANDARD_TEXT_FONT, fontSize - 1, "")
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



-- Idle-state list of supported raids, derived from RetroRuns_Data so
-- new raid additions auto-appear (no manual list maintenance). Groups
-- by expansion, alphabetizes within each expansion. Falls back to a
-- single empty-list line if nothing is loaded yet.
local IDLE_FOOTER =
    "|cff9d9d9dDesigned for max-level characters running legacy content.|r"

-- Expansion display order for the idle-state supported-raids list. Newest
-- first (matches Blizzard's EJ ordering on the expansion-selector). See
-- EXPANSION_ORDER_ASCENDING above for the browser dropdown's ordering.
local EXPANSION_ORDER_NEWEST_FIRST = {
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

-- Build the per-raid pill row for the idle-state list. Same shape as the
-- in-raid pill row, but each pill is colored by its OWN lockout state
-- rather than active-difficulty highlighting:
--   green  = fully cleared this lockout (nothing to farm until reset)
--   amber  = partial kills (still farmable, knows what's left)
--   gray   = no kills / fresh lockout / never entered
--   dim "-" = difficulty doesn't apply to this raid (rare; some legacy
--             raids predate certain difficulties)
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
                hex, p.label, c.complete, c.total))
        else
            table.insert(parts, ("|cff%s%s -|r"):format(INACTIVE, p.label))
        end
    end
    if #parts == 0 then return "" end

    local sep = "|cff555555 | |r"
    return "|cff777777[ |r"
        .. table.concat(parts, sep)
        .. "|cff777777 ]|r"
end

local function BuildIdleListText()
    local byExpansion = {}
    for _, raid in pairs(RetroRuns_Data or {}) do
        local exp = raid.expansion or "Unknown"
        byExpansion[exp] = byExpansion[exp] or {}
        table.insert(byExpansion[exp], raid)
    end

    local lines = {}
    local function emitRaid(raid)
        local name = raid.name or "??"
        table.insert(lines, ("|cffffffff* %s|r"):format(name))
        local pills = BuildIdleListPills(raid)
        if pills ~= "" then
            -- Indent the pill row two spaces under the raid name so the
            -- visual hierarchy is clear: name on the bullet line,
            -- lockout summary on the sub-line.
            table.insert(lines, "  " .. pills)
        end
    end

    -- Emit known expansions in canonical order
    for _, exp in ipairs(EXPANSION_ORDER_NEWEST_FIRST) do
        if byExpansion[exp] then
            table.sort(byExpansion[exp], function(a, b)
                return (a.name or "") < (b.name or "")
            end)
            table.insert(lines, ("|cffffff00%s|r"):format(exp))
            for _, raid in ipairs(byExpansion[exp]) do emitRaid(raid) end
            table.insert(lines, "")
            byExpansion[exp] = nil
        end
    end
    -- Anything left over (unknown/new expansion) goes at the end
    for exp, raids in pairs(byExpansion) do
        table.sort(raids, function(a, b) return (a.name or "") < (b.name or "") end)
        table.insert(lines, ("|cffffff00%s|r"):format(exp))
        for _, raid in ipairs(raids) do emitRaid(raid) end
        table.insert(lines, "")
    end

    if #lines == 0 then
        table.insert(lines, "|cff9d9d9d(no raid data loaded)|r")
        table.insert(lines, "")
    end

    table.insert(lines, IDLE_FOOTER)
    return table.concat(lines, "\n")
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
        panel.raid:SetText("Raid: " .. raid.name)
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
            local num  = RR:GetDisplayBossNumber(step, boss)
            panel.next:SetText(("Boss #%d: %s"):format(
                num, boss and boss.name or "Unknown"))
            panel.travel:SetText(BuildTravelText(step))
            local encText, encClickable = BuildEncounterText(step)
            panel.encounter:SetText(encText)
            panel.encounter.clickable = encClickable
            panel.encounter:EnableMouse(encClickable)
            -- Size the click frame to match rendered text height (same
            -- pattern used by panel.transmog below). Without this, the
            -- hit area stays at the 14px construction default and a
            -- multi-line expanded soloTip's lower lines wouldn't be
            -- clickable.
            panel.encounter:SetHeight(math.max(14, panel.encounter.label:GetStringHeight()))
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
            panel.list:SetText(table.concat(RR:GetProgressLines(), "\n"))
        else
            -- Run-complete state. The user has cleared every boss in
            -- this lockout. Layout goal: tight, informative, points at
            -- "what to do next." Per Photek 2026-04-26:
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
            panel.next:SetText("|cff00ff00Run complete!|r")
            panel.travel:SetText("")
            panel.encounter:SetText("")
            panel.encounter.clickable = false
            panel.encounter:EnableMouse(false)
            panel.transmog:SetText("")
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
            panel.list:SetText(BuildIdleListText())
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
        panel.encounter:SetText("")
        panel.encounter.clickable = false
        panel.encounter:EnableMouse(false)
        panel.transmog:SetText("")
        -- Don't Hide() the transmog wrapper here -- panel.listHeader
        -- normally anchors to its bottom-left, so hiding it would orphan
        -- that anchor. Empty text + EnableMouse(false) keeps the layout
        -- intact while making the invisible wrapper non-interactive.
        panel.transmog:EnableMouse(false)
        -- Re-anchor listHeader directly below "Travel to..." (panel.progress)
        -- so the supported-raids list sits tight against the prompt.
        -- The intermediate widgets (next, travel, encounter, transmog)
        -- are all empty in idle state but their anchor offsets still
        -- accumulate as visible gap, hence this re-anchor.
        panel.listHeader:ClearAllPoints()
        panel.listHeader:SetPoint("TOPLEFT", panel.progress, "BOTTOMLEFT", 0, -8)
        panel.listHeader:SetText("|cff9d9d9dCurrently supported:|r")
        panel.list:SetText(BuildIdleListText())
        panel.mapBtn:Disable()
        panel.mapBtn:SetAlpha(0.45)
    end

    -- Content size can change significantly between states (in-raid vs idle,
    -- different boss counts, longer strings). Re-fit after content is set.
    UI.AutoSize()
end