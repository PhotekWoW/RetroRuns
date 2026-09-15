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

-- One gap between every labelled section of the in-instance body -- travel
-- pane, Boss Encounter, Achievements, Special Loot, Transmog Needed, Boss
-- Progress. They read as peers, so they sit at equal distances; the chain
-- had drifted to 8/4/4/8/12. On the UI table because the file sits at Lua
-- 5.1's 200-local ceiling.
UI.PANEL_SECTION_GAP = 8

-- Title font. The 04B_03 pixel face covers ASCII only, so localized
-- strings rendered in it must stay accent-free; locale files word their
-- title-context entries accordingly.
local TITLE_FONT = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\04B_03.TTF"
-- VT323: monospaced terminal-style body font.
local VT323_FONT = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\VT323.ttf"
local BODY_FONT  = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local TITLE_SIZE = 24

-- Body font metadata. sizeFactor scales each font to match FRIZQT's
-- visual density at the same nominal size. charset declares the font's
-- glyph coverage (from its actual cmap): "ascii" = ASCII only, "latin" =
-- full Latin incl. accents/eszett/cedilla but no Cyrillic or CJK. The
-- client's standard font (nil charset) always covers its own language.
local BODY_FONT_INFO = {
    standard = { path = BODY_FONT,  sizeFactor = 1.00 },
    retro    = { path = TITLE_FONT, sizeFactor = 1.00, charset = "ascii" },
    vt323    = { path = VT323_FONT, sizeFactor = 1.30, charset = "latin" },
}

-- Locale -> minimum charset the body font must cover. Anything not
-- listed (Cyrillic, CJK, future locales) requires the client's own
-- standard font.
local ASCII_LOCALES = { enUS = true, enGB = true }
local LATIN_LOCALES = {
    enUS = true, enGB = true, esES = true, esMX = true, deDE = true,
    frFR = true, itIT = true, ptBR = true, ptPT = true,
}

-- True when a bodyFontStyle covers every character the addon will draw. Two
-- languages are in play: addon text follows RR.activeLocaleCode, while item and
-- boss names arrive in the client's language.
local function FontStyleSupportsLocale(style)
    local charset = BODY_FONT_INFO[style] and BODY_FONT_INFO[style].charset
    if not charset then return true end   -- standard font: always
    local function covers(locale)
        if not locale then return true end
        if charset == "ascii" then return ASCII_LOCALES[locale] == true end
        if charset == "latin" then return LATIN_LOCALES[locale] == true end
        return false
    end
    return covers(GetLocale())
        and covers(RetroRuns and RetroRuns.activeLocaleCode)
end

-- Exposed for the settings canvas (graying out incompatible choices).
function RetroRuns:FontStyleSupportsLocale(style)
    return FontStyleSupportsLocale(style)
end

local C_PINK   = { 0.95, 0.35, 0.78 }
local C_BLUE   = { 0.30, 0.80, 1.00 }
local C_PINK_HEX = "f259c7"  -- C_PINK as a text-escape hex (RETRO pink)
local C_LABEL  = "4DCCFF"   -- section label color (cyan, the RUNS wordmark blue)

-- Idle-list pill-row leading spacers: fixed-width inline textures that
-- reserve exact pixel widths at the head of a pill string. The pill text,
-- the plane anchor, and the chevron measurement all read these.
--
-- Blizzard's blank Spacer texture, NOT a raid-target star tinted black. The
-- escape's color arguments end at r:g:b -- there is no alpha slot -- so a
-- "0:0:0" spacer is opaque BLACK. It hides against a solid panel and shows
-- as a dark diamond the moment panel opacity is turned down.
--   PILL_SUBLINE_INDENT  16px: indents the pill row so it reads as a sub-line
--                        under the raid name.
--   PILL_PLANE_GUTTER    18px: the column the nav plane sits in, at the head of
--                        the row after the sub-line indent.
RR.PILL_SUBLINE_INDENT = "|TInterface\\Common\\Spacer:10:16|t"
-- Height 10, NOT 14. These spacers reserve WIDTH; their height is inert
-- visually but not structurally -- an inline texture taller than the line
-- stretches the FontString, and AutoSize budgets the idle list at one
-- body-font line per row. At 14 every dungeon row (all of which carry this
-- gutter) ran ~2px over budget, and fifteen of them ate the reserve that
-- holds the legend divider clear of the list. Keep any blank spacer at or
-- under the body font size.
RR.PILL_PLANE_GUTTER   = "|TInterface\\Common\\Spacer:10:18|t"

-- The same transparent spacer at an arbitrary width, for indenting a row's
-- own leading edge (grouped dungeon wings). Width must be whole: a
-- fractional one renders at an unpredictable rounded width.
--
-- NOT for lining columns up ACROSS rows -- that is a widget-layout problem
-- and padding a string will not do it. See visual-recipes.
function RR.PillSpacer(width)
    return ("|TInterface\\Common\\Spacer:10:%d|t")
        :format(math.max(1, math.floor(width)))
end

-- Known teleporter node names -- highlighted orange in travel text
-------------------------------------------------------------------------------
-- Font helper
-------------------------------------------------------------------------------

-- SetFont RAISES on a failed font load rather than returning false, and a
-- replaced client font can fail transiently. Each attempt is pcall-wrapped
-- with a font OBJECT as the floor, which a bad file on disk cannot defeat.
local function SafeSetFont(fs, path, size, flags)
    if not fs then return end
    flags = flags or ""
    local ok = path and pcall(fs.SetFont, fs, path, size, flags)
    if ok then return end
    if path ~= BODY_FONT then
        ok = pcall(fs.SetFont, fs, BODY_FONT, size, flags)
        if ok then return end
    end
    fs:SetFontObject("GameFontNormal")
end
-- Published for modules that load after UI.lua (SettingsCanvas) and for
-- deferred code in earlier-loading modules (Toaster): one hardened font
-- setter for the whole addon.
RR.SafeSetFont = SafeSetFont

-- Resolves bodyFontStyle to a {path, sizeFactor} entry, defaulting to
-- standard. A style that can't render the client's language also falls back,
-- but the saved preference is kept for a client whose language it does cover.
local function GetBodyFontInfo()
    local style = (RetroRuns and RetroRuns.GetSetting)
        and RetroRuns:GetSetting("bodyFontStyle", "standard")
        or "standard"
    if not FontStyleSupportsLocale(style) then
        style = "standard"
    end
    return BODY_FONT_INFO[style] or BODY_FONT_INFO.standard
end

-- Returns the body-text font path. Chrome (titles, action buttons)
-- uses 04B_03 directly via TITLE_FONT.
local function GetBodyFont()
    return GetBodyFontInfo().path
end

-- Font for chrome text that may carry localized content. The pixel title font
-- covers ASCII only, so non-English clients get the client default instead.
-- Anything showing a translated string routes through here.
function RetroRuns:GetChromeFont()
    if ASCII_LOCALES[GetLocale()] == true then
        return TITLE_FONT
    end
    return BODY_FONT
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

-- Every persist of the panel's position goes through here, tagged with the
-- code path that asked. Two shipped users report the panel drifting back to
-- a default corner between logins, and the write sites are the suspects:
-- a drag is user intent, but the minimize/maximize/AutoSize resizes ALSO
-- persist a recomputed offset, so any pass that runs while the frame is not
-- yet at its restored position can overwrite the real one. `/rr panelpos`
-- prints the trace; it is kept regardless of the debug setting because the
-- users who can reproduce this are not running debug builds.
UI._panelPosTrace = {}
function UI.SavePanelOffset(source, x, y)
    -- Drop no-op writes. Kept from when AutoSize persisted a 1px
    -- oscillation forever; only a drag writes now, but a cheap guard on a
    -- SavedVariables write is worth keeping.
    local newX = x and math.floor(x + 0.5) or nil
    local newY = y and math.floor(y + 0.5) or nil
    local curX = RR:GetSetting("panelAnchorX", 0)
    local curY = RR:GetSetting("panelAnchorY", 0)
    if (newX == nil or newX == curX) and (newY == nil or newY == curY) then
        return
    end
    if newX then RR:SetSetting("panelAnchorX", newX) end
    if newY then RR:SetSetting("panelAnchorY", newY) end
    RR:SetSetting("panelAnchorSet", true)
    local entry = ("%s x=%s y=%s (top=%s left=%s w=%.0f h=%.0f min=%s)"):format(
        source,
        newX or "-", newY or "-",
        panel and panel:GetTop() and ("%.0f"):format(panel:GetTop()) or "nil",
        panel and panel:GetLeft() and ("%.0f"):format(panel:GetLeft()) or "nil",
        panel and panel:GetWidth() or 0, panel and panel:GetHeight() or 0,
        tostring(RR:GetSetting("minimized")))
    table.insert(UI._panelPosTrace, entry)
    -- Ring: the interesting window is the login sequence, not an hour of play.
    if #UI._panelPosTrace > 40 then table.remove(UI._panelPosTrace, 1) end
end
-- A drag owns the panel's position while in progress; the layout pass would
-- otherwise re-anchor from the saved offsets and snap it back. isBeingDragged
-- gates every geometry write, and the re-fit runs once at drag stop.
panel:SetScript("OnDragStart", function(self)
    self.isBeingDragged = true
    self:StartMoving()
end)
panel:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    self.isBeingDragged = nil
    -- The client flags a named movable frame user-placed on drag start and
    -- then stores its position per character. Clearing it keeps persistence in
    -- our account-wide settings.
    self:SetUserPlaced(false)
    -- Normalize to a TOPLEFT anchor and store that. Top-left is
    -- size-invariant, so a later resize moves nothing and a restore cannot
    -- be wrong about how tall the frame happened to be.
    local left, top = RR.TopLeftOffsets(self)
    if left and top then
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
        UI.SavePanelOffset("drag", left, top)
    end
    -- Any layout pass skipped while the drag was in progress runs now,
    -- against the freshly saved offsets.
    if UI.ApplyMinimizedState then UI.ApplyMinimizedState() end
end)
-- If the panel is hidden mid-drag (e.g. the show-panel setting flips),
-- OnDragStop never fires for it, so clear the flag here or the layout
-- pass would stay disabled after the panel reappears.
panel:HookScript("OnHide", function(self)
    self.isBeingDragged = nil
end)

-- Forward declarations for auxiliary windows (assigned further down).
local tmogWindow
local browserState
local skipsWindow
local achievementsWindow
local achState
local RefreshIdleList
local PositionLegendDivider

-- Frame border via the engine's edgeFile nine-slice: a filmstrip of 8 slices
-- (four edges, four corners) the engine repeats at any frame size.
-- SetTextureSliceMargins silently no-ops on this client.
local PANEL_EDGE_SIZE_FULL      = 26
local PANEL_EDGE_SIZE_MINIMIZED = 14

local function PanelBackdrop(edgeSize)
    return {
        bgFile   = "Interface\\AddOns\\RetroRuns\\Media\\Panel\\panel-bg",
        edgeFile = "Interface\\AddOns\\RetroRuns\\Media\\Panel\\panel-edge",
        tile = true, tileSize = 64,
        edgeSize = edgeSize,
        insets = { left = 7, right = 7, top = 7, bottom = 7 },
    }
end

panel:SetBackdrop(PanelBackdrop(PANEL_EDGE_SIZE_FULL))
panel:SetBackdropColor(1, 1, 1, RR:GetSetting("panelOpacity", 1.0))
panel:SetBackdropBorderColor(1, 1, 1, 1)

-- Re-applies the backdrop at a smaller edgeSize while minimized. There is no
-- edgeSize-only setter, so the whole backdrop is re-set and the border and
-- background colors are restored right after.
--
-- Bespoke minimized-bar art: fixed left cap (with a gap in its top line for
-- the wordmark), tiled center, fixed right cap. Source art is 104px padded to
-- 128, so V runs 0..0.8125. Shown only while minimized.
panel.minbarLeft   = panel:CreateTexture(nil, "BORDER")
panel.minbarCenter = panel:CreateTexture(nil, "BORDER")
panel.minbarRight  = panel:CreateTexture(nil, "BORDER")
for _, key in ipairs({ "minbarLeft", "minbarCenter", "minbarRight" }) do
    local suffix = key == "minbarLeft" and "left"
                or key == "minbarCenter" and "center" or "right"
    panel[key]:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\minbar-" .. suffix)
    -- Source art is 104px tall in a 128px (power-of-two) texture, so V runs
    -- 0..0.8125; trim the padding here.
    panel[key]:SetTexCoord(0, 1, 0, 104 / 128)
    panel[key]:Hide()
end

-- Notch: bar backing floating one sublevel above the slices, breaking the top
-- border line behind the raid-name label so it reads as set into the border.
-- Movable, since raid names vary in width. V trimmed to 0..9/16.
panel.minbarNotch = panel:CreateTexture(nil, "BORDER", nil, 1)
panel.minbarNotch:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\minbar-notch")
panel.minbarNotch:SetTexCoord(0, 1, 0, 9 / 16)
panel.minbarNotch:Hide()

-- Lay the three slices across the panel: caps pinned to each end at fixed
-- width, center filling the gap between them. Called when the minimized bar
-- art is active; the pieces track the panel's current width/height. On the UI
-- table (not a file local) to stay under Lua's 200-local-per-chunk ceiling.
-- On-screen width of each minimized-bar end cap.
UI.MINBAR_CAP_W = 40

function UI.LayoutMinbarArt()
    local capW = UI.MINBAR_CAP_W
    panel.minbarLeft:ClearAllPoints()
    panel.minbarLeft:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    panel.minbarLeft:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    panel.minbarLeft:SetWidth(capW)

    panel.minbarRight:ClearAllPoints()
    panel.minbarRight:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    panel.minbarRight:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    panel.minbarRight:SetWidth(capW)

    panel.minbarCenter:ClearAllPoints()
    panel.minbarCenter:SetPoint("TOPLEFT", panel.minbarLeft, "TOPRIGHT", 0, 0)
    panel.minbarCenter:SetPoint("BOTTOMRIGHT", panel.minbarRight, "BOTTOMLEFT", 0, 0)

    -- Notch under the top-line target string (boss label + count): track its
    -- current width with a little open line on each side. Hidden when there's
    -- no string to mount.
    local topLineStr = panel.titleRaidName
    if topLineStr and topLineStr:IsShown() and (topLineStr:GetStringWidth() or 0) > 0 then
        local notchPad = 4   -- open line past the string, screen px each side
        panel.minbarNotch:ClearAllPoints()
        panel.minbarNotch:SetPoint("TOP", panel, "TOP", 0, 0)
        panel.minbarNotch:SetPoint("LEFT", topLineStr, "LEFT", -notchPad, 0)
        panel.minbarNotch:SetPoint("RIGHT", topLineStr, "RIGHT", notchPad, 0)
        panel.minbarNotch:SetHeight(4.5)
        panel.minbarNotch:Show()
    else
        panel.minbarNotch:Hide()
    end
end

local function ApplyBorderArtForState(minimized)
    -- The bespoke minimized art is used only for the two-row (route active)
    -- bar; the plain single-row minimized bar and the expanded panel both use
    -- the shared edgeFile frame. Decide which is active here.
    local useMinbarArt = minimized and UI.MinimizedBarRouteActive()
    if useMinbarArt then
        -- Hide the edgeFile frame (transparent border/bg) and show the slices.
        panel:SetBackdrop(PanelBackdrop(PANEL_EDGE_SIZE_MINIMIZED))
        panel:SetBackdropColor(0, 0, 0, 0)
        panel:SetBackdropBorderColor(0, 0, 0, 0)
        UI.LayoutMinbarArt()
        panel.minbarLeft:Show()
        panel.minbarCenter:Show()
        panel.minbarRight:Show()
    else
        panel.minbarLeft:Hide()
        panel.minbarCenter:Hide()
        panel.minbarRight:Hide()
        panel.minbarNotch:Hide()
        local edgeSize = minimized and PANEL_EDGE_SIZE_MINIMIZED
                                    or PANEL_EDGE_SIZE_FULL
        panel:SetBackdrop(PanelBackdrop(edgeSize))
        panel:SetBackdropColor(1, 1, 1, RR:GetSetting("panelOpacity", 1.0))
        panel:SetBackdropBorderColor(1, 1, 1, 1)
    end
    UI.UpdateAmbientArt()
end

-- Key art drawn faintly beneath the panel content while an instance of that
-- expansion is loaded. One texture per expansion; absent means none.
UI.AMBIENT_ART = {
    ["Classic"]           = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-Classic",
    ["Burning Crusade"]   = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-TBC",
    ["Cataclysm"]         = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-Cata",
    ["Wrath of the Lich King"] = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-WotLK",
    ["Mists of Pandaria"] = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-MoP",
    ["Warlords of Draenor"] = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-WoD",
    ["Legion"]            = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-Legion",
    ["Battle for Azeroth"] = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-BfA",
    ["Shadowlands"]       = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-SL",
    ["Dragonflight"]      = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelArt-DF",
}
-- Source shapes, width over height. The shipped textures hold a 3:4 crop
-- squashed onto a square and are drawn back at 3:4, so the block runs
-- from the panel's top edge down to the footer, with its lower part
-- fading out to make a floor there. Width follows the panel width; the
-- height is clipped to wherever the footer sits in the current layout.
UI.AMBIENT_ART_ASPECT  = 0.75
UI.AMBIENT_ART_ALPHA   = 0.2       -- on the idle list
UI.AMBIENT_ART_ALPHA_INSTANCE = 0.07 -- under an instance's denser text
UI.AMBIENT_ART_SOLID   = 0.7       -- fraction of the block above the floor fade
UI.AMBIENT_ART_CEILING = 0.2       -- fraction of the block fading in at the top
UI.AMBIENT_ART_TOP     = 48        -- below the title row
UI.AMBIENT_ART_STRIPS  = 36        -- fade steps below the solid part
UI.AMBIENT_ART_CEILING_STRIPS = 18 -- fade steps above it

-- Small textures drawn additively over an expansion's art and pulsed by
-- an animation, any number per picture. Each box is that texture's place
-- in the picture as fractions of its width and height; `pace` scales the
-- pulse length and `low` the resting brightness as a share of the peak.
UI.AMBIENT_ART_GLOW = {
    ["Warlords of Draenor"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-WoD",
            left  = 737 / 1086, right  = 865 / 1086,
            top   = 246 / 1448, bottom = 310 / 1448,
            low   = 0.6,
        },
    },
    ["Mists of Pandaria"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-MoP",
            left  = 914 / 1086, right  = 1042 / 1086,
            top   = 174 / 1448, bottom = 302 / 1448,
            low   = 0.6,
            pace  = 2.0,
        },
    },
    ["Dragonflight"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-DF",
            left  = 577 / 1086, right  = 705 / 1086,
            top   = 357 / 1448, bottom = 421 / 1448,
        },
    },
    ["Cataclysm"] = {
        -- The picture is a 923x1231 window of the source at (100, 200).
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-Cata",
            left  = 345 / 923, right  = 473 / 923,
            top   = 247 / 1231, bottom = 311 / 1231,
        },
    },
    ["Classic"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-Classic",
            left  = 630 / 1086, right  = 758 / 1086,
            top   = 206 / 1448, bottom = 270 / 1448,
        },
    },
    ["Shadowlands"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-SL",
            left  = 641 / 1086, right  = 769 / 1086,
            top   = 85 / 1448, bottom = 149 / 1448,
        },
    },
    ["Legion"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-Legion-L",
            left  = 598 / 1086, right  = 726 / 1086,
            top   = 191 / 1448, bottom = 319 / 1448,
        },
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-Legion-R",
            left  = 881 / 1086, right  = 1009 / 1086,
            top   = 243 / 1448, bottom = 371 / 1448,
            pace  = 1.3,
        },
    },
    ["Burning Crusade"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-TBC",
            left  = 713 / 1086, right  = 841 / 1086,
            top   = 187 / 1448, bottom = 251 / 1448,
        },
    },
    ["Wrath of the Lich King"] = {
        {
            file  = "Interface\\AddOns\\RetroRuns\\Media\\Art\\PanelGlow-WotLK",
            left  = 713 / 1086, right  = 841 / 1086,
            top   = 151 / 1448, bottom = 215 / 1448,
        },
    },
}
UI.AMBIENT_GLOW_LOW  = 0.45
UI.AMBIENT_GLOW_PACE = 1.0
UI.AMBIENT_ART_INSET   = 7         -- past the border's transparent margin

-- Which expansion the panel is showing: the loaded instance's, or on the
-- idle list the one section the player has open.
function UI.AmbientArtExpansion()
    local raid = RR.currentRaid
    if raid and raid.expansion then return raid.expansion end
    local expanded = RR.state and RR.state.expandedExpansions
    if type(expanded) ~= "table" then return nil end
    for expansionName, isOpen in pairs(expanded) do
        if isOpen then return expansionName end
    end
    return nil
end

function UI.UpdateAmbientArt()
    local expansionName = UI.AmbientArtExpansion()
    local file = expansionName and UI.AMBIENT_ART[expansionName]
    local glowSpec = expansionName and UI.AMBIENT_ART_GLOW[expansionName]
    local artAlpha = RR.currentRaid and UI.AMBIENT_ART_ALPHA_INSTANCE or UI.AMBIENT_ART_ALPHA
    local solid, strips = panel.ambientArt, panel.ambientArtStrips
    local ceiling = panel.ambientArtCeiling
    if not file or UI.IsMinimized() then
        if solid then solid:Hide() end
        for _, strip in ipairs(strips or {}) do strip:Hide() end
        for _, strip in ipairs(ceiling or {}) do strip:Hide() end
        UI.UpdateAmbientGlow(nil)
        return
    end
    local inset = UI.AMBIENT_ART_INSET
    if not solid then
        -- Top BACKGROUND sublevel: above the backdrop fill, below content.
        -- The block is a stack: ceiling strips fading in under the title
        -- row, the solid part, then floor strips fading out above the
        -- footer, so the picture dissolves into the backdrop at both ends.
        local function NewStrip(above)
            local strip = panel:CreateTexture(nil, "BACKGROUND", nil, 7)
            if above then
                strip:SetPoint("TOPLEFT", above, "BOTTOMLEFT", 0, 0)
                strip:SetPoint("TOPRIGHT", above, "BOTTOMRIGHT", 0, 0)
            else
                strip:SetPoint("TOPLEFT", panel, "TOPLEFT", inset, -UI.AMBIENT_ART_TOP)
                strip:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -inset, -UI.AMBIENT_ART_TOP)
            end
            strip:SetTexelSnappingBias(0)
            strip:SetSnapToPixelGrid(false)
            return strip
        end
        ceiling = {}
        local above = nil
        for _ = 1, UI.AMBIENT_ART_CEILING_STRIPS do
            above = NewStrip(above)
            table.insert(ceiling, above)
        end
        panel.ambientArtCeiling = ceiling
        solid = NewStrip(above)
        panel.ambientArt = solid
        strips = {}
        above = solid
        for _ = 1, UI.AMBIENT_ART_STRIPS do
            above = NewStrip(above)
            table.insert(strips, above)
        end
        panel.ambientArtStrips = strips
    end
    if solid.file ~= file then
        solid:SetTexture(file)
        for _, strip in ipairs(strips) do strip:SetTexture(file) end
        for _, strip in ipairs(ceiling) do strip:SetTexture(file) end
        solid.file = file
    end

    -- The block is as wide as the panel and as tall as the source's shape
    -- allows, then clipped to the footer: the legend divider on the idle
    -- list, the button row inside an instance. The clipped part of the
    -- source is its bottom, which the fade would have hidden anyway.
    local blockWidth = (panel:GetWidth() or 0) - 2 * inset
    if blockWidth <= 0 then UI.UpdateAmbientGlow(nil) return end
    local left, right, top, bottom = 0, 1, 0, 1
    local fullHeight = blockWidth / UI.AMBIENT_ART_ASPECT
    local floorElement = (panel.legendDivider and panel.legendDivider:IsShown())
        and panel.legendDivider or panel.mapBtn
    local panelTop = panel:GetTop()
    local floorTop = floorElement and floorElement:GetTop()
    local blockHeight = fullHeight
    if panelTop and floorTop then
        local room = panelTop - floorTop - UI.AMBIENT_ART_TOP - 4
        if room > 0 and room < blockHeight then blockHeight = room end
    end
    bottom = top + (bottom - top) * (blockHeight / fullHeight)

    local alpha = artAlpha * RR:GetSetting("panelOpacity", 1.0)
    local ceilingFraction = UI.AMBIENT_ART_CEILING
    local ceilingCount  = #ceiling
    local ceilingHeight = blockHeight * ceilingFraction / ceilingCount
    local ceilingSpan   = (bottom - top) * ceilingFraction / ceilingCount
    for index, strip in ipairs(ceiling) do
        local stripTop = top + ceilingSpan * (index - 1)
        strip:SetHeight(ceilingHeight)
        strip:SetTexCoord(left, right, stripTop, stripTop + ceilingSpan)
        strip:SetAlpha(alpha * (index - 0.5) / ceilingCount)
        strip:Show()
    end

    local solidFraction = UI.AMBIENT_ART_SOLID
    local solidStart = top + (bottom - top) * ceilingFraction
    local split = top + (bottom - top) * solidFraction
    solid:SetHeight(blockHeight * (solidFraction - ceilingFraction))
    solid:SetTexCoord(left, right, solidStart, split)
    solid:SetAlpha(alpha)
    solid:Show()

    local stripCount  = #strips
    local stripHeight = blockHeight * (1 - solidFraction) / stripCount
    local stripSpan   = (bottom - split) / stripCount
    for index, strip in ipairs(strips) do
        local stripTop = split + stripSpan * (index - 1)
        strip:SetHeight(stripHeight)
        strip:SetTexCoord(left, right, stripTop, stripTop + stripSpan)
        -- Linear to the floor; anything steeper vanishes at panel alpha.
        local remaining = 1 - (index - 0.5) / stripCount
        strip:SetAlpha(alpha * remaining)
        strip:Show()
    end

    local ceilingDepth = ceilingFraction * blockHeight / fullHeight
    UI.UpdateAmbientGlow(glowSpec, blockWidth, fullHeight, blockHeight, alpha, ceilingDepth)
end

-- The pulsing glows over the art block: one pooled texture per entry in
-- the expansion's glow list, placed against the top of the picture, with
-- the pulse peaking at the art's own alpha at that height.
function UI.NewAmbientGlow()
    local glow = panel:CreateTexture(nil, "BACKGROUND", nil, 7)
    glow:SetBlendMode("ADD")
    glow:SetTexelSnappingBias(0)
    glow:SetSnapToPixelGrid(false)
    local anim = glow:CreateAnimationGroup()
    anim:SetLooping("REPEAT")
    local rise = anim:CreateAnimation("Alpha")
    rise:SetOrder(1)
    rise:SetSmoothing("IN_OUT")
    local fall = anim:CreateAnimation("Alpha")
    fall:SetOrder(2)
    fall:SetSmoothing("IN_OUT")
    glow.anim, glow.rise, glow.fall = anim, rise, fall
    return glow
end

function UI.UpdateAmbientGlow(specs, blockWidth, fullHeight, blockHeight, alpha, ceilingDepth)
    local pool = panel.ambientArtGlows
    if not pool then
        pool = {}
        panel.ambientArtGlows = pool
    end
    local used = 0
    for _, spec in ipairs(specs or {}) do
        if spec.bottom * fullHeight <= blockHeight then
            used = used + 1
            local glow = pool[used]
            if not glow then
                glow = UI.NewAmbientGlow()
                pool[used] = glow
            end
            if glow.file ~= spec.file then
                glow:SetTexture(spec.file)
                glow.file = spec.file
            end
            local anchor = panel.ambientArtCeiling[1]
            glow:ClearAllPoints()
            glow:SetPoint("TOPLEFT", anchor, "TOPLEFT",
                spec.left * blockWidth, -spec.top * fullHeight)
            glow:SetSize((spec.right - spec.left) * blockWidth,
                (spec.bottom - spec.top) * fullHeight)

            local center = (spec.top + spec.bottom) / 2
            local fade = ceilingDepth > 0 and math.min(1, center / ceilingDepth) or 1
            local peak = alpha * fade
            local low  = peak * (spec.low or UI.AMBIENT_GLOW_LOW)
            local pace = spec.pace or UI.AMBIENT_GLOW_PACE
            glow.rise:SetDuration(2.0 * pace)
            glow.fall:SetDuration(2.6 * pace)
            glow.rise:SetFromAlpha(low)
            glow.rise:SetToAlpha(peak)
            glow.fall:SetFromAlpha(peak)
            glow.fall:SetToAlpha(low)
            glow:SetAlpha(low)
            glow:Show()
            if not glow.anim:IsPlaying() then glow.anim:Play() end
        end
    end
    for index = used + 1, #pool do
        pool[index].anim:Stop()
        pool[index]:Hide()
    end
end

-- Enables hyperlink clicks so achievement links in the encounter FontString
-- work. Also intercepts a custom "retroruns:zygor_arrow" link from the
-- entrance legend's arrow-disabled warning, which enables Zygor's setting and
-- re-renders the legend.
panel:SetHyperlinksEnabled(true)
panel:SetScript("OnHyperlinkClick", function(_, link, text, button)
    -- The travel note carries a {skip} link on an optional boss. Its
    -- FontString belongs to the panel, so the click surfaces here rather
    -- than on the encounter header's own handler.
    local skipBossIndex = link and link:match("^rrskip:(%d+)$")
    if skipBossIndex then
        if UI.ConfirmSkipBoss then
            UI.ConfirmSkipBoss(tonumber(skipBossIndex))
        end
        return
    end
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
-- Logo object retained but hidden; the title bar shows the "RETRO RUNS"
-- wordmark instead. Sized to sit as a peer to the 12pt title text.
panel.logo:SetSize(24, 24)
panel.logo:SetPoint("TOPLEFT", PAD_LEFT - 4, -10 - FRAME_INSET_Y)
panel.logo:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\LogoSquare")
panel.logo:Hide()

-- Title (two FontStrings, split only at color boundary). Anchored to the
-- panel's top-left now that the logo is hidden.
panel.titleRetro = panel:CreateFontString(nil, "OVERLAY")
panel.titleRetro:SetPoint("TOPLEFT", PAD_LEFT + 8, -12 - FRAME_INSET_Y)
SafeSetFont(panel.titleRetro, BODY_FONT, 12, "OUTLINE")
panel.titleRetro:SetText("RETRO")
panel.titleRetro:SetTextColor(unpack(C_PINK))
panel.titleRetro:SetShadowOffset(1, -1)
panel.titleRetro:SetShadowColor(0, 0, 0, 1)

panel.titleRuns = panel:CreateFontString(nil, "OVERLAY")
panel.titleRuns:SetPoint("LEFT", panel.titleRetro, "RIGHT", 0, 0)
SafeSetFont(panel.titleRuns, BODY_FONT, 12, "OUTLINE")
panel.titleRuns:SetText("RUNS")
panel.titleRuns:SetTextColor(unpack(C_BLUE))
panel.titleRuns:SetShadowOffset(1, -1)
panel.titleRuns:SetShadowColor(0, 0, 0, 1)

-- Minimized-bar top-line target string: the current boss label plus the
-- route's kill count, straddling the top frame line at the right end. Hidden
-- unless a route is active.
panel.titleRaidName = panel:CreateFontString(nil, "OVERLAY")
SafeSetFont(panel.titleRaidName, BODY_FONT, 12, "OUTLINE")
panel.titleRaidName:SetText("")
panel.titleRaidName:SetTextColor(1, 1, 1)
panel.titleRaidName:SetShadowOffset(1, -1)
panel.titleRaidName:SetShadowColor(0, 0, 0, 1)
panel.titleRaidName:Hide()

-- Minimized-bar next-step note: the single body row while a route is active,
-- showing the active segment's short instruction. White so it reads as content
-- distinct from the pink/blue brand letters. Hidden by default;
-- ApplyTitleLayoutForState shows it (and collapses the wordmark to "RR") only
-- when minimized with an active route note to display.
panel.titleMinNote = panel:CreateFontString(nil, "OVERLAY")
panel.titleMinNote:SetPoint("LEFT", panel.titleRuns, "RIGHT", 6, 0)
SafeSetFont(panel.titleMinNote, BODY_FONT, 14, "OUTLINE")
panel.titleMinNote:SetText("")
panel.titleMinNote:SetTextColor(1, 1, 1)
panel.titleMinNote:SetShadowOffset(1, -1)
panel.titleMinNote:SetShadowColor(0, 0, 0, 1)
panel.titleMinNote:Hide()

-- Close button. Custom 24x24 frame (not Blizzard's UIPanelCloseButton,
-- whose 32x32 frame and fixed red-X can't be themed) using the retro
-- neon CloseIcon texture. Hover brightens via vertex color. Shared by the
-- main panel and every auxiliary window, so all five wear one X.
-- Sets a dropdown bar's text. The template fills the bar from the selected
-- entry; the override keeps the bar on the plain name where the entries
-- carry count suffixes.
function UI.SetDropdownText(dropdown, text)
    if dropdown.OverrideText then
        dropdown:OverrideText(text)
    elseif dropdown.Text and dropdown.Text.SetText then
        dropdown.Text:SetText(text)
    end
end

-- The dropdown font: the small highlight face, one point larger. Built once
-- and shared by every bar and menu entry.
function UI.DropdownFont()
    if UI._dropdownFont then return UI._dropdownFont end
    local font = CreateFont("RetroRunsDropdownFont")
    font:SetFontObject(GameFontHighlightSmall)
    local path, size, flags = GameFontHighlightSmall:GetFont()
    if path and size then
        SafeSetFont(font, path, size + 1, flags or "")
    end
    UI._dropdownFont = font
    return font
end

-- The dropdown arrow: a bare triangle in the panel's pink, in place of the
-- template's boxed button. The template repaints the arrow from its mouse
-- and state handlers, so the same look is reapplied after each of them.
UI.DROPDOWN_ARROW_ATLAS = "common-dropdown-c-button-hover-arrow"
UI.DROPDOWN_ARROW_COLOR = C_PINK
UI.DROPDOWN_BAR_ATLAS   = "common-dropdown-textholder"

function UI.ApplyDropdownArrow(dropdown)
    local arrow = dropdown.Arrow
    if not (arrow and arrow.SetAtlas) then return end
    arrow:SetAtlas(UI.DROPDOWN_ARROW_ATLAS, true)
    arrow:SetDesaturated(true)
    local color = UI.DROPDOWN_ARROW_COLOR
    arrow:SetVertexColor(color[1], color[2], color[3])
    arrow:ClearAllPoints()
    arrow:SetPoint("RIGHT", dropdown, "RIGHT", -6, 0)
    -- The bar itself keeps its idle art under the mouse as well.
    if dropdown.Background and dropdown.Background.SetAtlas then
        dropdown.Background:SetAtlas(UI.DROPDOWN_BAR_ATLAS)
    end
    local highlight = dropdown.GetHighlightTexture and dropdown:GetHighlightTexture()
    if highlight then highlight:SetAlpha(0) end
end

-- House styling for a dropdown bar: the shared font and the house arrow.
function UI.StyleDropdown(dropdown)
    if dropdown.Text and dropdown.Text.SetFontObject then
        dropdown.Text:SetFontObject(UI.DropdownFont())
    end
    UI.ApplyDropdownArrow(dropdown)
    for _, script in ipairs({ "OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp",
                              "OnShow", "OnEnable", "OnDisable" }) do
        if dropdown:HasScript(script) then
            dropdown:HookScript(script, UI.ApplyDropdownArrow)
        end
    end
    -- The template echoes the bar's text as a tooltip on mouseover.
    dropdown:HookScript("OnEnter", function(self)
        if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
    end)
end

-- A menu entry in the same small font as the bar it drops from.
function UI.MenuRadio(rootDescription, text, isSelected, setSelected)
    local radio = rootDescription:CreateRadio(text, isSelected, setSelected)
    if radio and radio.AddInitializer then
        radio:AddInitializer(function(button)
            local label = button.fontString or button.Text
            if label and label.SetFontObject then
                label:SetFontObject(UI.DropdownFont())
            end
        end)
    end
    return radio
end

function UI.MakeRetroCloseButton(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(24, 24)
    local tex = button:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\CloseIcon")
    tex:SetAllPoints(button)
    button._tex = tex
    button:SetScript("OnEnter", function(self) self._tex:SetVertexColor(1.4, 1.4, 1.4) end)
    button:SetScript("OnLeave", function(self) self._tex:SetVertexColor(1, 1, 1) end)
    return button
end

panel.closeButton = UI.MakeRetroCloseButton(panel)
panel.closeButton:SetPoint("TOPRIGHT", -10 - FRAME_INSET_X, -4 - FRAME_INSET_Y)
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
    tex:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\MinimizeIcon")
    tex:SetAllPoints(panel.minimizeButton)
    panel.minimizeButton._tex = tex
    panel.minimizeButton:SetScript("OnEnter", function(self) self._tex:SetVertexColor(1.4, 1.4, 1.4) end)
    panel.minimizeButton:SetScript("OnLeave", function(self) self._tex:SetVertexColor(1, 1, 1) end)
end
-- (OnClick handler wired further below, after UI.SetMinimized exists.)

-- Shared sparkle for the search magnifying glasses: a small star that
-- twinkles on the lens every few seconds, brand blue against the pink
-- glass. Fields on the button, not locals: this file sits at the
-- 200-local ceiling.
function UI.AttachSearchSparkle(button)
    button.sparkle = button:CreateTexture(nil, "OVERLAY")
    button.sparkle:SetTexture("Interface\\Cooldown\\star4")
    button.sparkle:SetBlendMode("ADD")
    button.sparkle:SetVertexColor(0.30, 0.80, 1.00)
    button.sparkle:SetSize(12, 12)
    button.sparkle:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 2)
    button.sparkle:SetAlpha(0)
    button.sparkleAnim = button.sparkle:CreateAnimationGroup()
    button.sparkleAnim:SetLooping("REPEAT")
    button.sparkleIn = button.sparkleAnim:CreateAnimation("Alpha")
    button.sparkleIn:SetOrder(1)
    button.sparkleIn:SetDuration(0.3)
    button.sparkleIn:SetFromAlpha(0)
    button.sparkleIn:SetToAlpha(0.9)
    button.sparkleSpin = button.sparkleAnim:CreateAnimation("Rotation")
    button.sparkleSpin:SetOrder(1)
    button.sparkleSpin:SetDuration(1.1)
    button.sparkleSpin:SetDegrees(90)
    button.sparkleOut = button.sparkleAnim:CreateAnimation("Alpha")
    button.sparkleOut:SetOrder(2)
    button.sparkleOut:SetDuration(0.8)
    button.sparkleOut:SetFromAlpha(0.9)
    button.sparkleOut:SetToAlpha(0)
    button.sparkleOut:SetEndDelay(3.2)
    button.sparkleAnim:Play()
end

-- Raid/dungeon search shortcut on the minimized bar. Shown only while the
-- bar is idle or run-complete -- the states whose expanded panel renders
-- the instance list this search lands on. The appearance search lives on
-- the transmog browser's own glass.
panel.searchButton = CreateFrame("Button", nil, panel)
panel.searchButton:SetSize(24, 24)
panel.searchButton:SetNormalTexture("Interface\\Common\\UI-Searchbox-Icon")
panel.searchButton:SetHighlightTexture("Interface\\Common\\UI-Searchbox-Icon", "ADD")
do
    local tex = panel.searchButton:GetNormalTexture()
    if tex then tex:SetVertexColor(0.95, 0.35, 0.78) end
end
UI.AttachSearchSparkle(panel.searchButton)
panel.searchButton:Hide()
-- Which search a magnifying glass opens. Inside a loaded instance the
-- player is looking at its loot, so the glass searches appearances; with
-- no instance loaded the panel is showing the instance list and the glass
-- searches that.
-- The panel is showing the instance list rather than guiding a run: either
-- no instance is loaded, or the run in the loaded one is finished. Two
-- surfaces read this -- which search the glass opens, and which status the
-- footer's center slot carries.
function UI.IsShowingInstanceList()
    if not RR.currentRaid then return true end
    if RR.IsActiveRouteComplete and RR:IsActiveRouteComplete() then
        return true
    end
    return false
end

function UI.SearchOpensTransmog()
    return not UI.IsShowingInstanceList()
end

panel.searchButton:SetScript("OnClick", function()
    -- Search opens on the bar itself; picking a result is what expands
    -- the panel to show the landed row, or opens the browser on it. A
    -- second click closes it.
    if panel.idleSearchBox:IsShown() then
        UI.CloseIdleSearch()
    elseif UI.OpenIdleSearch then
        UI.OpenIdleSearch(UI.SearchOpensTransmog() and "tmog" or "instance")
    end
end)

-- Raid/dungeon search on the expanded idle panel: a glass left of the
-- minimize button. Scope is the instance list only; a result flips the
-- RAID | DUNGEON mode, expands the owning expansion (and wing group),
-- and flashes the landed row.
panel.idleSearchButton = CreateFrame("Button", nil, panel)
panel.idleSearchButton:SetSize(24, 24)
panel.idleSearchButton:SetNormalTexture("Interface\\Common\\UI-Searchbox-Icon")
panel.idleSearchButton:SetHighlightTexture("Interface\\Common\\UI-Searchbox-Icon", "ADD")
do
    local tex = panel.idleSearchButton:GetNormalTexture()
    if tex then tex:SetVertexColor(0.95, 0.35, 0.78) end
end
UI.AttachSearchSparkle(panel.idleSearchButton)
panel.idleSearchButton:Hide()

panel.idleSearchBox = CreateFrame("EditBox", "RetroRunsIdleSearchBox",
    panel, "InputBoxTemplate")
panel.idleSearchBox:SetAutoFocus(false)
panel.idleSearchBox:SetSize(160, 20)
panel.idleSearchBox:SetPoint("TOPRIGHT", panel.idleSearchButton,
    "BOTTOMRIGHT", 0, -6)
panel.idleSearchBox:SetFrameLevel(panel:GetFrameLevel() + 40)
panel.idleSearchBox:SetMaxLetters(60)
-- Dim placeholder naming the scope; clears as soon as anything is typed.
panel.idleSearchBox.hint = panel.idleSearchBox:CreateFontString(nil,
    "OVERLAY", "GameFontDisableSmall")
panel.idleSearchBox.hint:SetPoint("LEFT", 2, 0)
panel.idleSearchBox.hint:SetText(RR.L["Search for an instance"])
panel.idleSearchBox:Hide()

panel.idleSearchResults = CreateFrame("Frame", nil, panel, "BackdropTemplate")
panel.idleSearchResults:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
panel.idleSearchResults:SetBackdropColor(0.05, 0.05, 0.05, 0.97)
panel.idleSearchResults:SetPoint("TOPLEFT", panel.idleSearchBox,
    "BOTTOMLEFT", -6, -2)
panel.idleSearchResults:SetFrameLevel(panel:GetFrameLevel() + 40)
panel.idleSearchResults:EnableMouse(true)
panel.idleSearchResults:Hide()
panel.idleSearchFoot = panel.idleSearchResults:CreateFontString(nil,
    "OVERLAY", "GameFontDisableSmall")
panel.idleSearchFoot:SetJustifyH("LEFT")
panel.idleSearchFoot:Hide()

do
    local RESULT_MAX = 8
    local RESULT_ROW_H = 16
    local RESULT_PAD = 8
    local rowButtons = {}

    function UI.CloseIdleSearch()
        panel.idleSearchBox:SetText("")
        panel.idleSearchBox:ClearFocus()
        panel.idleSearchBox:Hide()
        panel.idleSearchResults:Hide()
    end

    function UI.OpenIdleSearch(mode)
        -- One box serves two scopes: the instance list when idle, and
        -- appearances while a run is live. The hint names which is active.
        panel.searchMode = (mode == "tmog") and "tmog" or "instance"
        panel.idleSearchBox.hint:SetText(panel.searchMode == "tmog"
            and RR.L["Search for Tmog"] or RR.L["Search for an instance"])
        -- The box's left edge starts under the live glass -- the bar's
        -- when minimized, the idle panel's otherwise -- and hangs below
        -- the title row instead of crossing the divider.
        panel.idleSearchBox:ClearAllPoints()
        if UI.IsMinimized and UI.IsMinimized() then
            panel.idleSearchBox:SetPoint("TOPLEFT", panel.searchButton,
                "BOTTOMLEFT", 0, -8)
        else
            panel.idleSearchBox:SetPoint("TOPLEFT", panel.idleSearchButton,
                "BOTTOMLEFT", 0, -8)
        end
        panel.idleSearchBox:Show()
        panel.idleSearchBox:SetFocus()
    end

    -- Instance-list search: raids and dungeons by name, localized or
    -- authored. No per-item scope -- that search belongs to the browser.
    function UI.QueryInstanceSearch(query, maxResults)
        if not query or query:len() < 2 then return nil, 0 end
        local needle = query:lower()
        local matches = {}
        local expansionsSeen = {}
        local function consider(instance)
            if not (instance and instance.instanceID
                    and instance.instanceID > 0) then return end
            expansionsSeen[instance.expansion or ""] = true
            local localized = RR:GetLocalizedRaidName(instance)
                or instance.name or ""
            local expKey = instance.expansion or ""
            local expLocalized = RR.L[expKey] or expKey
            if localized:lower():find(needle, 1, true)
                or (instance.name or ""):lower():find(needle, 1, true)
                or expLocalized:lower():find(needle, 1, true)
                or expKey:lower():find(needle, 1, true) then
                table.insert(matches, {
                    raid = instance,
                    display = ("%s |cff9d9d9d(%s)|r"):format(localized,
                        RR.L[instance.expansion or "Unknown"]),
                })
            end
        end
        for _, raid in pairs(RetroRuns_Data or {}) do
            if raid.instanceID and raid.instanceID > 0 then
                consider(RR:GetRaidByInstanceID(raid.instanceID) or raid)
            end
        end
        for _, dungeon in pairs(RetroRuns_DungeonData or {}) do
            consider(dungeon)
        end
        table.sort(matches, function(a, b) return a.display < b.display end)
        -- An expansion whose own name matches leads the list: picking it
        -- opens that whole section rather than one instance. Cyan, the
        -- idle list's expansion-header color.
        local combined = {}
        for expKey in pairs(expansionsSeen) do
            local expName = RR.L[expKey] or expKey
            if expKey ~= "" and (expName:lower():find(needle, 1, true)
                or expKey:lower():find(needle, 1, true)) then
                table.insert(combined, { expansion = expKey,
                    display = ("|cff00ffff%s|r"):format(expName) })
            end
        end
        table.sort(combined, function(a, b) return a.display < b.display end)
        for _, entry in ipairs(matches) do
            table.insert(combined, entry)
        end
        local overflow = 0
        if #combined > maxResults then
            overflow = #combined - maxResults
            for i = #combined, maxResults + 1, -1 do combined[i] = nil end
        end
        return combined, overflow
    end

    -- Fading band over the row a search landed on, the transmog band's
    -- shape on the idle list. Built lazily: the shared flash constants
    -- are defined further down the file.
    function UI.FlashIdleListRow(raid)
        if not raid then return end
        if not panel.idleSearchFlash then
            panel.idleSearchFlash = panel:CreateTexture(nil, "ARTWORK")
            panel.idleSearchFlash:SetColorTexture(UI.FLASH_BAND_R,
                UI.FLASH_BAND_G, UI.FLASH_BAND_B, UI.FLASH_BAND_ALPHA)
            panel.idleSearchFlash:Hide()
            panel.idleSearchFlashFade =
                panel.idleSearchFlash:CreateAnimationGroup()
            panel.idleSearchFlashAlpha =
                panel.idleSearchFlashFade:CreateAnimation("Alpha")
            panel.idleSearchFlashAlpha:SetFromAlpha(1)
            panel.idleSearchFlashAlpha:SetToAlpha(0)
            panel.idleSearchFlashAlpha:SetStartDelay(UI.FLASH_FADE_DELAY)
            panel.idleSearchFlashAlpha:SetDuration(UI.FLASH_FADE_DURATION)
            panel.idleSearchFlashFade:SetScript("OnFinished", function()
                panel.idleSearchFlash:Hide()
            end)
        end
        for _, fs in ipairs(panel.idleListLines) do
            if fs._searchInstanceID == raid.instanceID and fs:IsShown() then
                panel.idleSearchFlash:ClearAllPoints()
                panel.idleSearchFlash:SetPoint("TOPLEFT", fs, "TOPLEFT", -2, 2)
                panel.idleSearchFlash:SetPoint("BOTTOMRIGHT", fs,
                    "BOTTOMLEFT", BODY_WIDTH, -2)
                panel.idleSearchFlash:Show()
                panel.idleSearchFlashFade:Stop()
                panel.idleSearchFlashFade:Play()
                return
            end
        end
    end

    -- A dungeon routed since the account last opened its expansion
    -- brightens from the unsupported gray to white the first time the
    -- expansion is opened, then stays white. Rows are rewritten in place
    -- from a template carrying one color slot.
    UI.REVEAL_DELAY = 1.0
    UI.REVEAL_DURATION = 1.5
    UI.REVEAL_FROM = 0x8a

    -- Current hex for a row mid-reveal; nil once it has settled (or never
    -- started). Expired entries drop out of the state table here.
    function UI.RevealHex(instance)
        local reveals = RR.state and RR.state.rowReveals
        local key = instance and instance.journalInstanceID
        local start = reveals and key and reveals[key]
        if not start then return nil end
        local t = (GetTime() - start - UI.REVEAL_DELAY) / UI.REVEAL_DURATION
        if t >= 1 then
            reveals[key] = nil
            return nil
        end
        if t < 0 then t = 0 end
        local v = math.floor(UI.REVEAL_FROM + (0xff - UI.REVEAL_FROM) * t + 0.5)
        return ("%02x%02x%02x"):format(v, v, v)
    end

    function UI.BeginRowReveal(instances)
        RR.state = RR.state or {}
        RR.state.rowReveals = RR.state.rowReveals or {}
        local now = GetTime()
        for _, instance in ipairs(instances) do
            RR.state.rowReveals[instance.journalInstanceID] = now
        end
        if UI.revealTicker then return end
        UI.revealTicker = C_Timer.NewTicker(0.03, function()
            for _, fs in ipairs(panel.idleListLines or {}) do
                if fs._revealTemplate and fs:IsShown() then
                    local hex = UI.RevealHex(fs._revealInstance)
                    fs:SetText(fs._revealTemplate:format(hex or "ffffff"))
                    if not hex then fs._revealTemplate = nil end
                end
            end
            -- Rows that never rendered (panel hidden) still expire.
            for key, start in pairs(RR.state.rowReveals) do
                if GetTime() - start >= UI.REVEAL_DELAY + UI.REVEAL_DURATION then
                    RR.state.rowReveals[key] = nil
                end
            end
            if not next(RR.state.rowReveals) then
                UI.revealTicker:Cancel()
                UI.revealTicker = nil
            end
        end)
    end

    function UI.SelectIdleSearchResult(entry)
        RR.state = RR.state or {}
        -- A jump REPLACES the expand state rather than adding to it, so
        -- consecutive searches leave one section open, not a trail.
        if entry.expansion then
            -- The expansion itself was picked: open that section in the
            -- current RAID | DUNGEON mode.
            RR.state.expandedExpansions = { [entry.expansion] = true }
            RR.state.expandedDungeonGroups = {}
            UI.CloseIdleSearch()
            UI.InvalidateIdleListCache()
            UI.SetMinimized(false)
            return
        end
        RR.state.idleListMode =
            (entry.raid.kind == "dungeon") and "dungeon" or "raid"
        RR.state.expandedExpansions =
            { [entry.raid.expansion or "Unknown"] = true }
        RR.state.expandedDungeonGroups = {}
        -- A wing lives under its group heading; open that too. Keyed on
        -- the authored name, matching the list builder.
        local heading = (entry.raid.name or ""):match("^(.-) %- ")
        if heading then
            RR.state.expandedDungeonGroups[heading] = true
        end
        UI.CloseIdleSearch()
        UI.InvalidateIdleListCache()
        -- The canonical repaint: expands the panel when the search came
        -- from the bar, and runs the full Update -- list, layout, and
        -- AutoSize -- so rows land measured, not colliding.
        UI.SetMinimized(false)
        UI.FlashIdleListRow(entry.raid)
    end

    -- Picking dispatches on the mode the query ran under: an instance
    -- result moves the idle list, an appearance result opens the browser
    -- on that row.
    local function SelectResult(entry)
        if not entry then return end
        if panel.searchMode == "tmog" then
            UI.CloseIdleSearch()
            UI.JumpToTmogEntry(entry)
        else
            UI.SelectIdleSearchResult(entry)
        end
    end

    local function GetResultButton(idx)
        local btn = rowButtons[idx]
        if btn then return btn end
        btn = CreateFrame("Button", nil, panel.idleSearchResults)
        btn:SetHeight(RESULT_ROW_H)
        btn:SetPoint("TOPLEFT", panel.idleSearchResults, "TOPLEFT",
            RESULT_PAD, -RESULT_PAD - (idx - 1) * RESULT_ROW_H)
        btn:SetPoint("RIGHT", panel.idleSearchResults, "RIGHT",
            -RESULT_PAD, 0)
        btn.text = btn:CreateFontString(nil, "OVERLAY",
            "GameFontHighlightSmall")
        btn.text:SetPoint("LEFT", 0, 0)
        btn.text:SetJustifyH("LEFT")
        btn.hl = btn:CreateTexture(nil, "HIGHLIGHT")
        btn.hl:SetAllPoints()
        btn.hl:SetColorTexture(1, 1, 1, 0.08)
        btn:SetScript("OnClick", function(self)
            SelectResult(self.entry)
        end)
        rowButtons[idx] = btn
        return btn
    end

    local function UpdateResults()
        local query = panel.idleSearchBox:GetText()
        local matches, overflow
        if panel.searchMode == "tmog" then
            matches, overflow = UI.QueryTmogSearch(query, RESULT_MAX)
        else
            matches, overflow = UI.QueryInstanceSearch(query, RESULT_MAX)
        end
        for _, btn in ipairs(rowButtons) do
            btn:Hide()
            btn.entry = nil
        end
        panel.idleSearchFoot:Hide()
        if not matches then
            panel.idleSearchResults:Hide()
            return
        end
        local widest, shown = 0, 0
        for idx, entry in ipairs(matches) do
            local btn = GetResultButton(idx)
            btn.entry = entry
            btn.text:SetText(entry.display)
            btn:Show()
            local w = btn.text:GetStringWidth() or 0
            if w > widest then widest = w end
            shown = idx
        end
        local lines = shown
        local footText
        if shown == 0 then
            footText = RR.L["No matches."]
        elseif overflow > 0 then
            footText = (RR.L["+%d more"]):format(overflow)
        end
        if footText then
            panel.idleSearchFoot:SetText(footText)
            panel.idleSearchFoot:ClearAllPoints()
            panel.idleSearchFoot:SetPoint("TOPLEFT", panel.idleSearchResults,
                "TOPLEFT", RESULT_PAD, -RESULT_PAD - shown * RESULT_ROW_H)
            panel.idleSearchFoot:Show()
            local w = panel.idleSearchFoot:GetStringWidth() or 0
            if w > widest then widest = w end
            lines = lines + 1
        end
        panel.idleSearchResults:SetSize(
            math.min(360, math.max(panel.idleSearchBox:GetWidth() + 12,
                widest + RESULT_PAD * 2 + 4)),
            lines * RESULT_ROW_H + RESULT_PAD * 2)
        panel.idleSearchResults:Show()
    end

    panel.idleSearchBox:SetScript("OnTextChanged", function(self, userInput)
        -- Unconditional: a programmatic SetText("") has to restore the hint
        -- just as typing has to clear it.
        self.hint:SetShown(self:GetText() == "")
        if userInput then UpdateResults() end
    end)
    panel.idleSearchBox:SetScript("OnEscapePressed", UI.CloseIdleSearch)
    panel.idleSearchBox:SetScript("OnEnterPressed", function()
        local firstBtn = rowButtons[1]
        if firstBtn and firstBtn:IsShown() and firstBtn.entry then
            SelectResult(firstBtn.entry)
        end
    end)
end

panel.idleSearchButton:SetScript("OnClick", function()
    if panel.idleSearchBox:IsShown() then
        UI.CloseIdleSearch()
    else
        UI.OpenIdleSearch(UI.SearchOpensTransmog() and "tmog" or "instance")
    end
end)
panel.idleSearchButton:SetScript("OnEnter", function(self)
    -- Nothing to hint once the box is open: the tooltip anchors right,
    -- straight over the box the click just revealed, and covers what the
    -- player is typing into.
    if panel.idleSearchBox and panel.idleSearchBox:IsShown() then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(RR.L["Search"], 1, 1, 1)
    GameTooltip:Show()
end)
panel.idleSearchButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Test-mode label, positioned to clear both the close X and the
-- minimize button.
panel.mode = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.mode:SetPoint("TOPRIGHT", -56 - FRAME_INSET_X, -14 - FRAME_INSET_Y)
panel.mode:SetText("")
SafeSetFont(panel.mode, TITLE_FONT, 9, "OUTLINE")
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

-- Instance name and its pill row are CENTERED under the wordmark rather
-- than left-aligned with the body. Spans the full panel width so the text
-- centers on the frame, not on a column inset from it.
panel.raid = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
panel.raid:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -30 - FRAME_INSET_Y)
panel.raid:SetWidth(PANEL_W)
panel.raid:SetJustifyH("CENTER")

-- LFR wing subline, shown only in a wing (populated in UI.Update). Its own
-- FontString so it can run 4pt smaller than the raid name; an empty string
-- collapses to zero height, so when not in a wing the pills row (anchored
-- below it) sits directly under the raid name as before. Sized at raid-font
-- minus 4 in UI.Update, where the live raid font size is readable.
panel.wingLine = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
panel.wingLine:SetPoint("TOPLEFT", panel.raid, "BOTTOMLEFT", 0, -2)
panel.wingLine:SetWidth(PANEL_W)
panel.wingLine:SetJustifyH("CENTER")
panel.wingLine:SetText("")

-- Per-difficulty kill-count pills row. Active difficulty in white,
-- others in gray. Format: "[ LFR x/y | N x/y | H x/y | M x/y ]".
panel.pills = AddField(panel.wingLine, "TOPLEFT", "BOTTOMLEFT", -2, PANEL_W, "GameFontNormalSmall")
panel.pills:SetJustifyH("CENTER")

-- Lockout tooltip for every raid's pill row, keyed by difficultyModel. Raids
-- with no model field use independent. The lock glyph marks a committed-out
-- pill separately.
RR.LockoutTipByModel = {
    single = {
        label = RR.L["Single difficulty"],
        gloss = RR.L["One difficulty, one weekly lockout"],
    },
    shared = {
        label = RR.L["Shared lockout"],
        gloss = RR.L["One difficulty per week"],
    },
    sharedLfr = {
        label = RR.L["Shared lockout (LFR separate)"],
        gloss = RR.L["LFR + one difficulty per week"],
    },
    independent = {
        label = RR.L["Independent lockouts"],
        gloss = RR.L["Each difficulty has its own weekly lockout"],
    },
    -- difficultyLocked keeps the shared label, but its own gloss: the week
    -- locks to a difficulty while the two sizes stay interchangeable, so
    -- remaining bosses can be killed at either size. Its own entry rather
    -- than an alias of shared, since sizesShared and sizesHeroic raids do
    -- NOT work that way and must not inherit the size wording.
    difficultyLocked = {
        label = RR.L["Shared lockout"],
        gloss = RR.L["One difficulty per week; 10 and 25 share it"],
    },
}
-- The Wrath size models split by lockout shape: sizes takes the independent
-- wording, sizesShared and sizesHeroic take the shared wording.
RR.LockoutTipByModel.sizes            = RR.LockoutTipByModel.independent
RR.LockoutTipByModel.sizesHeroic      = RR.LockoutTipByModel.shared
RR.LockoutTipByModel.sizesShared      = RR.LockoutTipByModel.shared
-- Dungeons: one wording for both appearance shapes. Normal 5-mans never
-- save an instance, so only Heroic and Mythic pill.
RR.LockoutTipByModel.dungeon = {
    label = RR.L["Dungeon lockouts"],
    gloss = RR.L["Heroic resets daily, Mythic weekly. Normal never locks."],
}
RR.LockoutTipByModel.dungeonBinary = RR.LockoutTipByModel.dungeon
RR.LockoutTipByModel.dungeonTiered = RR.LockoutTipByModel.dungeon
function RR:GetLockoutTooltipInfo(model)
    return self.LockoutTipByModel[model or "independent"]
end

-- Hover region over the pills row: FontStrings can't take mouse scripts, so a
-- sibling frame carries the lockout tooltip. Armed for every loaded raid, with
-- the model stored on the frame so hover picks the right lines.
panel.pillsHover = CreateFrame("Frame", nil, panel)
panel.pillsHover:SetPoint("TOPLEFT", panel.pills, "TOPLEFT", 0, 0)
panel.pillsHover:SetPoint("BOTTOM", panel.pills, "BOTTOM", 0, 0)
panel.pillsHover:SetWidth(1)
panel.pillsHover:EnableMouse(true)
panel.pillsHover._lockoutTip = false
panel.pillsHover._lockoutModel = nil
panel.pillsHover:SetScript("OnEnter", function(self)
    if not self._lockoutTip then return end
    local tipInfo = RR:GetLockoutTooltipInfo(self._lockoutModel)
    if not tipInfo then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(tipInfo.label, 1, 1, 1, true)
    GameTooltip:AddLine(tipInfo.gloss, 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end)
panel.pillsHover:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Body content resumes at the left margin. The pills row above it is
-- CENTERED in a full-width FontString, so chaining TOPLEFT off it would
-- inherit the panel's edge as the left column and drag every field below
-- -- prompt, travel pane, encounter block, list -- out past the frame.
-- Vertical from the pills, horizontal from the panel.
panel.progress  = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
panel.progress:SetPoint("TOP",  panel.pills, "BOTTOM", 0, -6)
panel.progress:SetPoint("LEFT", panel, "LEFT", PAD_LEFT, 0)
panel.progress:SetWidth(BODY_WIDTH)
panel.progress:SetJustifyH("LEFT")
panel.next      = AddField(panel.progress, "TOPLEFT", "BOTTOMLEFT", -8,  BODY_WIDTH, "GameFontNormal")
-- Run-complete exit shortcut. Sits below panel.next with a slightly
-- larger gap than the usual -8/-12 so there's a little breathing room
-- under the "Run complete!" banner. Smaller font than the banner (see
-- targets table). Only populated when the loaded raid authors an exitNote.
panel.exitNote  = AddField(panel.next,     "TOPLEFT", "BOTTOMLEFT", -13, BODY_WIDTH, "GameFontNormalSmall")
-- A boss the route never visits, and what is still owed there. Its own
-- field: it is a separate thought from the exit shortcut above it, and
-- one FontString would run the two sentences together.
panel.exitNoteExtra = AddField(panel.exitNote, "TOPLEFT", "BOTTOMLEFT", -8, BODY_WIDTH, "GameFontNormalSmall")
-- Skip-run comeback line, shown between the banner and the exit note. Its
-- own field so the exit note stays the bottom of the block.
panel.skipReturn = AddField(panel.next,    "TOPLEFT", "BOTTOMLEFT", -13, BODY_WIDTH, "GameFontNormalSmall")
-- Skip-run caveat, its own field because a FontString carries ONE font size
-- and this line renders two points under the comeback line it follows.
panel.skipNote  = AddField(panel.skipReturn, "TOPLEFT", "BOTTOMLEFT", -6, BODY_WIDTH - 12, "GameFontNormalSmall")
panel.skipNote:SetPoint("TOPLEFT", panel.skipReturn, "BOTTOMLEFT", 12, -6)
panel.travel    = AddField(panel.next,     "TOPLEFT", "BOTTOMLEFT", -12, BODY_WIDTH)

-- Boss Encounter section: .header (Button, toggles the soloTip),
-- .achievements and .specialLoot (hyperlink-enabled Frames). Splitting the
-- toggle target from the hyperlink targets avoids click competition.
panel.encounter = CreateFrame("Frame", nil, panel)
panel.encounter:SetPoint("TOPLEFT", panel.travel, "BOTTOMLEFT", 0, -UI.PANEL_SECTION_GAP)
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
    -- A click landing on the note's {skip} link fires BOTH this and
    -- OnHyperlinkClick, and their order is not guaranteed. Deferring one
    -- frame lets the link handler raise its flag either way, so the note
    -- does not collapse out from under the confirmation.
    C_Timer.After(0, function()
        if panel.encounter.skipLinkClicked then
            panel.encounter.skipLinkClicked = nil
            return
        end
        local now = RR:GetSetting("encounterExpanded")
        RR:SetSetting("encounterExpanded", not now)
        UI.Update()
    end)
end)

-- The expanded note carries a {skip} link on optional bosses. Hyperlinks
-- ride the same frame as the toggle here (unlike the achievements and
-- special-loot sub-widgets, which are link-only), so the flag above is what
-- keeps the two apart.
panel.encounter.header:SetHyperlinksEnabled(true)
panel.encounter.header:SetScript("OnHyperlinkClick", function(_, link)
    local bossIndex = link and link:match("^rrskip:(%d+)$")
    if not bossIndex then return end
    panel.encounter.skipLinkClicked = true
    UI.ConfirmSkipBoss(tonumber(bossIndex))
end)

-- Skip control for an optional boss, sharing the header's row. Its own
-- Button rather than part of the header's click area, so toggling the note
-- and bypassing the boss never compete for one click -- the same split the
-- hyperlink sub-widgets use.
panel.encounter.skip = CreateFrame("Button", nil, panel.encounter)
panel.encounter.skip:SetSize(1, 14)
panel.encounter.skip:SetFrameLevel(panel.encounter.header:GetFrameLevel() + 2)
panel.encounter.skip.label = panel.encounter.skip:CreateFontString(
    nil, "OVERLAY", "GameFontHighlightSmall")
panel.encounter.skip.label:SetPoint("TOPLEFT", 0, 0)
panel.encounter.skip.label:SetJustifyH("LEFT")
panel.encounter.skip:RegisterForClicks("LeftButtonUp")
panel.encounter.skip:SetScript("OnClick", function(self)
    if not self.bossIndex then return end
    UI.ConfirmSkipBoss(self.bossIndex)
end)
panel.encounter.skip:Hide()

-- Achievements sub-widget: hyperlinks-only, no toggle.
panel.encounter.achievements = CreateFrame("Frame", nil, panel.encounter)
panel.encounter.achievements:SetPoint("TOPLEFT", panel.encounter.header, "BOTTOMLEFT", 0, -UI.PANEL_SECTION_GAP)
panel.encounter.achievements:SetSize(BODY_WIDTH, 1)
panel.encounter.achievements.label = panel.encounter.achievements:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.encounter.achievements.label:SetPoint("TOPLEFT", 0, 0)
panel.encounter.achievements.label:SetWidth(BODY_WIDTH)
panel.encounter.achievements.label:SetJustifyH("LEFT")
panel.encounter.achievements.label:SetWordWrap(true)
panel.encounter.achievements.label:SetNonSpaceWrap(true)
panel.encounter.achievements:SetHyperlinksEnabled(true)
panel.encounter.achievements:SetScript("OnHyperlinkClick", function(_, link, text, button)
    -- The "None" row on bosses without achievements opens the
    -- achievements window, the same destination a real achievement
    -- link resolves to.
    if link == "rrachui" then
        if not AchievementFrame then AchievementFrame_LoadUI() end
        ToggleAchievementFrame()
        return
    end
    SetItemRef(link, text, button)
end)

-- Special loot sub-widget: hyperlinks-only, no toggle.
panel.encounter.specialLoot = CreateFrame("Frame", nil, panel.encounter)
panel.encounter.specialLoot:SetPoint("TOPLEFT", panel.encounter.achievements, "BOTTOMLEFT", 0, -UI.PANEL_SECTION_GAP)
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
    -- Which instance table the browser reads: "raid" (RetroRuns_Data,
    -- keyed by instance map id) or "dungeon" (RetroRuns_DungeonData,
    -- keyed by journalInstanceID).
    instanceKind = "raid",
    active    = false,
    -- Which class's class-gated loot the browser is showing: a class ID,
    -- 0 for "all classes", or nil for "the class being played". Runtime
    -- only, deliberately NOT a saved setting -- see ActiveClassFilter.
    classFilter = nil,
}

-- Transmog summary button (mouseover opens popup)
panel.transmog = CreateFrame("Button", nil, panel)
-- Tmog hover: OnEnter on either the summary line or the popup cancels a
-- pending hide, OnLeave on either schedules one. The grace lets the user
-- travel between them and reach dropdowns that pop outside the popup.
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
        local window = tmogWindow
        if not window or not window:IsShown() then return end
        -- Don't hide if the cursor ended up over the popup or summary.
        if window:IsMouseOver() then return end
        if panel.transmog:IsMouseOver() then return end
        window:Hide()
    end)
end

panel.transmog:SetPoint("TOPLEFT", panel.encounter, "BOTTOMLEFT", 0, -UI.PANEL_SECTION_GAP)
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
    UI.PointBrowserAtCurrentInstance()
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
-- Cyan like the other section labels; the template's own color is yellow.
panel.listHeader:SetTextColor(C_BLUE[1], C_BLUE[2], C_BLUE[3])

panel.list = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
panel.list:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, -8)
panel.list:SetWidth(BODY_WIDTH)
panel.list:SetJustifyH("LEFT")
panel.list:SetJustifyV("TOP")

-- Pool of Buttons for the expand/collapse toggles in the idle and
-- run-complete lists. Created lazily, hidden and kept for reuse. Buttons
-- rather than FontString hyperlinks: hyperlinks lose the first click to the
-- panel's other hit targets.
panel.expansionToggleButtons = {}
panel.expansionToggleButtonPool = {}

-- Entrance-navigation buttons, one per raid with entrance data, anchored to
-- the right of the raid-name FontString. Same lazy-create, recycle-per-refresh
-- lifecycle as the expansion toggles.
panel.entranceButtons = {}
panel.entranceButtonPool = {}

-- Borrow a Button from the pool, creating one if empty. Returned blank and
-- hidden; callers configure and Show().
--
-- The button OWNS its glyph rather than overlaying one drawn in the list
-- text, so the two cannot desync.
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

-- Applies the expanded/collapsed texture set, kept separate from positioning
-- so a click handler can swap textures without re-anchoring.
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

-- Anchors a toggle Button to the LEFT of its header FontString, sized to the
-- current font height. Moving with the rendered widget avoids the drift a
-- computed y-offset accumulates.
local function PositionExpansionToggleButton(btn, parentFS, expanded)
    local fontSize = RR:GetSetting("fontSize", 12)
    -- Square button at font-size dimensions so the glyph scales with
    -- the user's text size setting and stays visually proportional to
    -- the expansion name beside it.
    btn:SetSize(fontSize, fontSize)
    SetToggleButtonTextures(btn, expanded)
    btn:ClearAllPoints()
    -- The header text carries leading-space padding so the button has room
    -- without overlapping. Vertical alignment follows the anchor pair.
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
    -- Authored white so it can be vertex-tinted, same as the other icons.
    -- Alpha carries the routing-vs-waypoint tier, set in RefreshIdleList.
    btn:SetNormalTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\PlaneIcon")
    local nt = btn:GetNormalTexture()
    if nt then nt:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 1) end
    -- Highlight: same texture in ADD blend for a brighten-on-hover feel.
    btn:SetHighlightTexture(
        "Interface\\AddOns\\RetroRuns\\Media\\Icons\\PlaneIcon", "ADD")
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

local function PositionEntranceButton(btn, parentFS, inset)
    local fontSize = RR:GetSetting("fontSize", 12)
    -- Taxi icon at 1.4x the toggle-button size. Anchored at a fixed left inset
    -- on the pill-row FontString so every plane lands in one vertical column.
    local size = math.floor(fontSize * 1.4)
    btn:SetSize(size, size)
    btn:ClearAllPoints()
    -- +17 = the 16px sub-line indent + 1px into the plane gutter. A wing
    -- row passes its own inset, which lands its plane under the first
    -- letter of the heading above it.
    btn:SetPoint("LEFT", parentFS, "LEFT", inset or 17, 0)
end

-- Frameless toast: a single FontString fade-in/hold/fade-out near
-- the clicked button. Used to confirm silent waypoint paths
-- (Blizzard/TomTom) where nothing else in the panel acknowledges
-- the click. Drives alpha manually via C_Timer.NewTicker.
local function ShowWaypointToast(anchorFrame, text, rowFS, rowRight, openRight)
    if not anchorFrame or not text then return end

    -- One frame for the life of the session; a click while a toast is
    -- still fading restarts it in place.
    local toast = UI.waypointToast
    if not toast then
        toast = CreateFrame("Frame", nil, UIParent)
        toast:SetFrameStrata("TOOLTIP")  -- above the addon panel
        toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        UI.waypointToast = toast
    end
    if toast.ticker then
        toast.ticker:Cancel()
        toast.ticker = nil
    end
    toast:SetSize(180, 18)

    local fs = toast.text
    fs:ClearAllPoints()
    fs:SetText("|cffffd700" .. text .. "|r")  -- gold for friendly notice

    toast:ClearAllPoints()
    if rowFS then
        -- Idle-list rows open the toast RIGHTWARD, past the row's last
        -- difficulty pill. Their plane sits in the left gutter, where a
        -- leftward toast clips off-screen with the panel near the left
        -- edge of the display. Width follows the text so the toast ends
        -- with the message. rowRight is where the row's content actually
        -- ends: a dungeon row's pills live in their own cell past the
        -- name, so the name's width lands the toast on top of them.
        fs:SetJustifyH("LEFT")
        fs:SetPoint("LEFT", toast, "LEFT", 0, 0)
        toast:SetWidth(math.max(1, fs:GetStringWidth()))
        toast:SetPoint("LEFT", rowFS, "LEFT",
            (rowRight or rowFS:GetStringWidth() or 0) + 10, 0)
    elseif openRight then
        -- A button sitting at the END of a line of prose has no room to its
        -- left -- a leftward toast lands on top of the sentence. Open away
        -- from the text instead.
        fs:SetJustifyH("LEFT")
        fs:SetPoint("LEFT", toast, "LEFT", 0, 0)
        toast:SetWidth(math.max(1, fs:GetStringWidth()))
        toast:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)
    else
        -- Everywhere else the toast opens LEFTWARD off the clicked button,
        -- which has open space on that side.
        fs:SetJustifyH("RIGHT")
        fs:SetPoint("RIGHT", toast, "RIGHT", 0, 0)
        toast:SetPoint("RIGHT", anchorFrame, "LEFT", -6, 0)
    end

    toast:SetAlpha(0)  -- start invisible
    toast:Show()

    -- Manual alpha schedule: 0.10s fade-in, 1.50s hold, 0.60s fade-out.
    local FADE_IN_TICKS  = 2
    local HOLD_TICKS     = 30
    local FADE_OUT_TICKS = 12
    local TOTAL_TICKS    = FADE_IN_TICKS + HOLD_TICKS + FADE_OUT_TICKS

    local tickIndex = 0
    toast.ticker = C_Timer.NewTicker(0.05, function()
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
            if toast.ticker then toast.ticker:Cancel() end
            toast.ticker = nil
            toast:Hide()
        end
    end, TOTAL_TICKS)
end

-- ShowNavChooser is wrapped in a do/end block and scoped to the panel
-- table. The navChooser singleton lives as an upvalue inside the block;
-- the function is reachable as panel.ShowNavChooser.
do
    local navChooser  -- the singleton frame, lazily created
    -- rowFS is the idle-list pill row the plane belongs to, rowRight the
    -- offset from its left edge where the row's content ends. Together they
    -- anchor the toast past the row's last difficulty pill.
    function panel.ShowNavChooser(anchorFrame, raid, rowFS, rowRight)
        if not anchorFrame or not raid then return end

        -- Waypoints cannot be placed from inside an instance, so say so
        -- rather than routing into silence -- the same guard the browser's
        -- travel plane uses. The run-complete panel shows the idle list
        -- while the player is still zoned in, so its planes land here.
        if IsInInstance and IsInInstance() then
            ShowWaypointToast(anchorFrame, RR.L["Zone out first"], rowFS,
                rowRight)
            return
        end

        -- The chooser exists to pick between the LFR queue NPC and the
        -- physical entrance. A raid with no LFR wings has only the entrance,
        -- so there's nothing to choose -- navigate straight there and skip
        -- the popup entirely.
        if raid.lfrWings == nil then
            local result = RR:NavigateToEntrance(raid)
            if result and not result.planner then
                ShowWaypointToast(anchorFrame, RR.L["Waypoint set"], rowFS,
                    rowRight)
            end
            return
        end

        -- Lazy construction of the singleton frame + its two option buttons.
        if not navChooser then
            local chooserFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            chooserFrame:SetFrameStrata("DIALOG")
            chooserFrame:EnableMouse(true)  -- swallow clicks on the chooser body
            -- Thin tooltip-style border (not the heavy ornamented panel
            -- edge, which overwhelms a small popup). Tinted to a flat
            -- pink/blue midpoint so the border reads as a blend of the two
            -- option colors. Backdrop border takes ONE color (no gradient),
            -- so the midpoint blend is the "gradient" within engine limits.
            chooserFrame:SetBackdrop({
                bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 12,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            chooserFrame:SetBackdropColor(0.02, 0.03, 0.05, 0.96)
            local BR = (C_PINK[1] + C_BLUE[1]) / 2
            local BG = (C_PINK[2] + C_BLUE[2]) / 2
            local BB = (C_PINK[3] + C_BLUE[3]) / 2
            chooserFrame:SetBackdropBorderColor(BR, BG, BB, 1)
            chooserFrame:Hide()

            -- "Navigate to:" header row inside the frame (not floating above
            -- it), so the popup is self-contained and clears the list text in
            -- any open direction.
            local title = chooserFrame:CreateFontString(nil, "OVERLAY")
            SetBodyFont(title, math.max(9, RR:GetSetting("fontSize", 12) - 2), "")
            title:SetText(RR.L["Navigate to:"])
            title:SetTextColor(0.54, 0.58, 0.64, 1)  -- muted gray
            title:SetPoint("TOPLEFT", chooserFrame, "TOPLEFT", 5, -4)
            chooserFrame.title = title
            local titleH = (title:GetStringHeight() or 10) + 4  -- header band height

            local PAD_X, PAD_Y = 14, 7

            -- Build one horizontal option cell with a colored label. The
            -- cell auto-sizes to its label plus horizontal padding; onClick
            -- is wired per-show (closes over the current raid).
            local function makeOption(labelText, color)
                local optionButton = CreateFrame("Button", nil, chooserFrame)
                optionButton:RegisterForClicks("LeftButtonUp")
                local fs = optionButton:CreateFontString(nil, "OVERLAY")
                SetBodyFont(fs, RR:GetSetting("fontSize", 12), "")
                fs:SetText(labelText)
                fs:SetTextColor(color[1], color[2], color[3], 1)
                fs:SetPoint("CENTER", optionButton, "CENTER", 0, 0)
                optionButton.label = fs
                -- Cell width = label width + side padding; height = label
                -- height + vertical padding. Measured after SetText.
                local buttonWidth = (fs:GetStringWidth() or 20) + PAD_X * 2
                local buttonHeight = (fs:GetStringHeight() or 12) + PAD_Y * 2
                optionButton:SetSize(buttonWidth, buttonHeight)
                -- Hover highlight tinted to the option color.
                local hl = optionButton:CreateTexture(nil, "HIGHLIGHT")
                hl:SetAllPoints(optionButton)
                hl:SetColorTexture(color[1], color[2], color[3], 0.18)
                return optionButton
            end

            -- Horizontal layout: [ LFR | STD ], LFR left (matches the pill
            -- order where LFR is leftmost).
            chooserFrame.lfrButton = makeOption("LFR", C_PINK)
            chooserFrame.stdButton = makeOption("STD", C_BLUE)

            -- 1px vertical divider between the two cells.
            local divider = chooserFrame:CreateTexture(nil, "OVERLAY")
            divider:SetColorTexture(BR, BG, BB, 0.8)
            chooserFrame.divider = divider

            -- Anchor cells side by side, BELOW the title header band.
            chooserFrame.lfrButton:SetPoint("TOPLEFT", chooserFrame, "TOPLEFT", 3, -(3 + titleH))
            divider:SetPoint("TOPLEFT", chooserFrame.lfrButton, "TOPRIGHT", 0, 0)
            divider:SetWidth(1)
            divider:SetPoint("BOTTOMLEFT", chooserFrame.lfrButton, "BOTTOMRIGHT", 0, 0)
            chooserFrame.stdButton:SetPoint("TOPLEFT", divider, "TOPRIGHT", 0, 0)

            -- Frame sizes to the title band + the two cells + the 1px divider
            -- + 3px inset on each side. Heights match (same font), so use
            -- lfr's height.
            local cellH = select(2, chooserFrame.lfrButton:GetSize())
            local totalW = select(1, chooserFrame.lfrButton:GetSize())
                         + 1
                         + select(1, chooserFrame.stdButton:GetSize())
                         + 6  -- 3px inset each side
            chooserFrame:SetSize(totalW, cellH + 6 + titleH)

            -- Global mouse-catcher: a full-screen transparent button BEHIND
            -- the chooser that closes it when the player clicks elsewhere.
            local catcher = CreateFrame("Button", nil, UIParent)
            catcher:SetFrameStrata("DIALOG")
            catcher:SetFrameLevel(math.max(0, (chooserFrame:GetFrameLevel() or 1) - 1))
            catcher:SetAllPoints(UIParent)
            catcher:RegisterForClicks("AnyUp")
            catcher:Hide()
            catcher:SetScript("OnClick", function()
                chooserFrame:Hide()
            end)
            chooserFrame.catcher = catcher
            chooserFrame:SetScript("OnHide", function() catcher:Hide() end)

            navChooser = chooserFrame
        end

        local chooser = navChooser

        -- Per-show wiring: each option closes over THIS raid. The nav calls
        -- mirror the prior inline behavior (toast on no-planner branch).
        chooser.stdButton:SetScript("OnClick", function(self)
            chooser:Hide()
            local result = RR:NavigateToEntrance(raid)
            if result and not result.planner then
                ShowWaypointToast(self, RR.L["Waypoint set"])
            end
        end)
        chooser.lfrButton:SetScript("OnClick", function(self)
            chooser:Hide()
            local result = RR:NavigateToLFRNPC(raid.expansion)
            if result and not result.planner then
                ShowWaypointToast(self, RR.L["Waypoint set"])
            end
        end)

        -- Open the chooser vertically off the clicked plane: upward by
        -- default, downward for raids near the top of the panel.
        chooser:ClearAllPoints()
        local anchorTop = anchorFrame:GetTop()
        local panelTop  = panel:GetTop()
        -- Flip downward within ~80px of the panel top (the reference is the
        -- panel, not the screen, since the panel is draggable).
        local openDown = anchorTop and panelTop
            and (panelTop - anchorTop) < 80
        if openDown then
            chooser:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", -2, -4)
        else
            chooser:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", -2, 4)
        end
        chooser.catcher:Show()
        chooser:Show()
        chooser:Raise()
        -- Level the catcher exactly one below the chooser AFTER the raise,
        -- so the catcher always sits behind the chooser body (and the
        -- chooser's option buttons receive their clicks first). Setting
        -- this at construction is insufficient because Raise() changes the
        -- chooser's level at show time without moving the catcher.
        chooser.catcher:SetFrameLevel(math.max(0, (chooser:GetFrameLevel() or 1) - 1))
    end
end


-- ---------------------------------------------------------------------------
-- Per-line FontString pool for the supported-raids list; one widget per line
-- so toggle Buttons can anchor to it. Legend rows sit in a parallel array so
-- AutoSize excludes them from the list-height budget.
-- ---------------------------------------------------------------------------
panel.idleListLines        = {}
panel.idleListLegendLines  = {}
panel.idleListLinePool     = {}
-- Dungeon rows' pill column: a second cell per row at a shared x-offset.
panel.idlePillCells        = {}
panel.idlePillCellPool     = {}

-- Divider above the idle-list legend block. Created once, repositioned and
-- shown per refresh. The line is a white alpha-mask tinted in code, with
-- texel snapping disabled to keep the edge crisp.
panel.legendDivider = panel:CreateTexture(nil, "ARTWORK")
panel.legendDivider:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\divider-line")
panel.legendDivider:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 0.55)
panel.legendDivider:SetHeight(6)
if panel.legendDivider.SetTexelSnappingBias then
    panel.legendDivider:SetTexelSnappingBias(0)
    panel.legendDivider:SetSnapToPixelGrid(false)
end
panel.legendDivider:Hide()

-- Cyan gem centered on the divider line.
panel.legendDividerGem = panel:CreateTexture(nil, "OVERLAY")
panel.legendDividerGem:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\divider-gem")
panel.legendDividerGem:SetSize(14, 14)
panel.legendDividerGem:SetPoint("CENTER", panel.legendDivider, "CENTER", 0, 0)
if panel.legendDividerGem.SetTexelSnappingBias then
    panel.legendDividerGem:SetTexelSnappingBias(0)
    panel.legendDividerGem:SetSnapToPixelGrid(false)
end
panel.legendDividerGem:Hide()

-- Divider under the title wordmark. Same line texture and pink as the
-- legend divider, lighter and gemless -- it separates the header from the
-- body rather than heading a section of its own. Width and placement come
-- from the wordmark at layout time, since both follow the title font.
panel.titleDivider = panel:CreateTexture(nil, "ARTWORK")
panel.titleDivider:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\divider-line")
panel.titleDivider:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 0.55)
panel.titleDivider:SetHeight(6)
if panel.titleDivider.SetTexelSnappingBias then
    panel.titleDivider:SetTexelSnappingBias(0)
    panel.titleDivider:SetSnapToPixelGrid(false)
end
panel.titleDivider:Hide()

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

-- Second cell on a dungeon row, holding its lockout pills at a fixed
-- x-offset so the pill column is straight across every row. Cross-row
-- alignment is a widget-layout problem, never a string-padding one --
-- padding inside one FontString lands each row within a pixel or two of
-- the last and reads crooked at every font size.
function UI.AcquireIdlePillCell()
    local cell = table.remove(panel.idlePillCellPool)
    if cell then return cell end
    cell = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cell:SetJustifyH("LEFT")
    return cell
end

function UI.ReleaseIdlePillCells()
    for _, cell in ipairs(panel.idlePillCells) do
        cell:Hide()
        cell:ClearAllPoints()
        cell:SetText("")
        table.insert(panel.idlePillCellPool, cell)
    end
    wipe(panel.idlePillCells)
end

-- Return all currently-active line FontStrings to the pool. Hides them
-- and clears their anchors so a fresh layout pass starts cleanly.
local function ReleaseIdleListLines()
    for _, fs in ipairs(panel.idleListLines) do
        fs:Hide()
        fs:ClearAllPoints()
        fs:SetText("")
        -- Clear the spacer sentinel, or a recycled FontString carries it
        -- into an unrelated row on the next render.
        fs._nextGap = nil
        table.insert(panel.idleListLinePool, fs)
    end
    wipe(panel.idleListLines)
    -- Belongs to the rows just released; a stale value would inflate the
    -- next height reserve for a list that no longer has those gaps.
    panel._idleListExtraGapPx = 0
    panel._idleLegendRows = 0
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

-- Boss Progress checklist pool, same architecture as the idle-list pool.
-- Parallel rather than shared: the two surfaces have different lifecycles and
-- release triggers.
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
    -- The hover regions anchor to these lines, so they die with them --
    -- here rather than at each teardown site, which is how a pool of
    -- overlays drifts out of step with the rows it covers.
    UI.ReleaseProgressHoverFrames()
end

-- Hover regions for checklist rows carrying an advisory. FontStrings take
-- no mouse scripts, so such a row gets an invisible mouse-enabled frame on
-- top, pooled in lockstep with the line FontStrings. Only rows that have
-- something to say get one, so the rest of the list stays inert.
panel.progressHoverFrames    = {}
panel.progressHoverFramePool = {}

function UI.AcquireProgressHoverFrame()
    local hoverFrame = table.remove(panel.progressHoverFramePool)
    if hoverFrame then return hoverFrame end
    hoverFrame = CreateFrame("Frame", nil, panel)
    hoverFrame:SetFrameLevel((panel:GetFrameLevel() or 0) + 8)
    hoverFrame:EnableMouse(true)
    -- Same mouseover band the pill rows use: with checklist rows two
    -- points apart, the band says which row the tooltip belongs to.
    local highlight = hoverFrame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.4)
    hoverFrame:SetScript("OnEnter", function(self)
        if not self._note then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(UI.CAUTION_GLYPH .. " " .. self._note,
            UI.CAUTION_R, UI.CAUTION_G, UI.CAUTION_B, true)
        GameTooltip:Show()
    end)
    hoverFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return hoverFrame
end

function UI.ReleaseProgressHoverFrames()
    for _, hoverFrame in ipairs(panel.progressHoverFrames) do
        hoverFrame:Hide()
        hoverFrame:ClearAllPoints()
        hoverFrame._note = nil
        table.insert(panel.progressHoverFramePool, hoverFrame)
    end
    wipe(panel.progressHoverFrames)
end

-- Lays the per-boss kill checklist under panel.listHeader, which the
-- caller has already anchored and captioned. Rendered as per-line
-- FontStrings rather than one multi-line FontString, matching the
-- idle-list architecture: per-row hover regions anchor to their own line
-- and cannot drift. panel.list (the legacy multi-line FontString)
-- stays empty; these own all rendering.
--
-- Shared by the routed in-progress view and by an instance with no route
-- at all -- GetProgressLines needs no active step, falling back to the
-- journal's boss order and leaving every row unmarked until it is killed.
function UI.RenderBossProgressList()
    panel.list:SetText("")
    ReleaseProgressListLines()
    local progressFontSize = RR:GetSetting("fontSize", 12)
    local previousLine
    local lines, notes = RR:GetProgressLines()
    for lineNumber, lineText in ipairs(lines) do
        local fs = AcquireProgressListLine()
        SetBodyFont(fs, progressFontSize, "")
        fs:SetText(lineText or "")
        fs:ClearAllPoints()
        if previousLine then
            fs:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", 0, -2)
        else
            fs:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, -8)
        end
        fs:Show()
        table.insert(panel.progressListLines, fs)
        -- Bounded to the rendered text, not the field width, so the
        -- highlight band stops where the row's name stops.
        local note = notes and notes[lineNumber]
        if note then
            local hoverFrame = UI.AcquireProgressHoverFrame()
            hoverFrame._note = note
            hoverFrame:ClearAllPoints()
            hoverFrame:SetPoint("TOPLEFT", fs, "TOPLEFT", 0, 0)
            hoverFrame:SetPoint("BOTTOMRIGHT", fs, "BOTTOMLEFT",
                fs:GetStringWidth() or 0, 0)
            hoverFrame:Show()
            table.insert(panel.progressHoverFrames, hoverFrame)
        end
        previousLine = fs
    end
end

-- Idle-list pillRow hover regions. FontStrings can't take mouse
-- scripts, so locked-out pill rows get an invisible mouse-enabled frame
-- on top to surface the shared-lockout tooltip. Pooled and recycled in
-- lockstep with the line FontStrings (same lifecycle as the toggle /
-- entrance button pools).
panel.pillHoverFrames    = {}
panel.pillHoverFramePool = {}
-- The dungeon list's NEW tag: a FontString of its own, so it can sit
-- smaller than the header it follows (one FontString holds one size).
panel.newTagLabels       = {}
panel.newTagLabelPool    = {}
UI.NEW_TAG_SIZE_DROP = 3

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

-- Under-development marker: the client's own alert glyph, and the amber
-- the toaster arrow uses for "enabled but not live here". Amber rather
-- than red -- the dungeon works for browsing and travel today, it just
-- has no route yet. A DialogFrame asset, so it carries no icon border
-- and needs no texcoord crop.
-- Caution glyph and its amber, shared by every advisory line a row's
-- tooltip can carry. The under-development marker is one of them.
UI.CAUTION_GLYPH = "|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:12:12|t"
UI.CAUTION_R, UI.CAUTION_G, UI.CAUTION_B = 1.00, 0.55, 0.20
UI.DEV_MARKER_GLYPH = UI.CAUTION_GLYPH
UI.DEV_MARKER_R, UI.DEV_MARKER_G, UI.DEV_MARKER_B =
    UI.CAUTION_R, UI.CAUTION_G, UI.CAUTION_B

local function AcquirePillHoverFrame()
    local hoverFrame = table.remove(panel.pillHoverFramePool)
    if hoverFrame then return hoverFrame end
    hoverFrame = CreateFrame("Frame", nil, panel)
    -- +8, deliberately BELOW the +10 clickables that share the pill row
    -- (entrance plane button, wing chevrons): the lockout tooltip is
    -- passive info and must never intercept clicks meant for buttons.
    hoverFrame:SetFrameLevel((panel:GetFrameLevel() or 0) + 8)
    hoverFrame:EnableMouse(true)
    -- Row highlight on mouseover. With rows one line apart and tooltips
    -- differing row to row, the band says which row the tooltip is for.
    -- HIGHLIGHT-layer textures show and hide with the mouse on their own,
    -- so this needs no script and follows the frame wherever it is placed.
    local highlight = hoverFrame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.4)
    hoverFrame:SetScript("OnEnter", function(self)
        -- Only ask when this frame actually carries a model:
        -- GetLockoutTooltipInfo defaults a nil model to "independent", so
        -- asking with nil hands back a lockout gloss for a row that has
        -- nothing to do with lockouts (the Timewalking marker).
        local tipInfo = self._lockoutModel
            and RR:GetLockoutTooltipInfo(self._lockoutModel) or nil
        if not tipInfo and not self._underDevelopment
            and not self._timewalking and not self._seasonal then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        -- Timewalking rows carry no lockout model, so this is the whole
        -- tooltip there rather than a line above one.
        if self._timewalking then
            local days, month, day, hour, minute = RR:GetTimewalkingEnd()
            local line = RR.L["Timewalking"]
            if month and day then
                -- The client's own date formatter where it exists, so the
                -- order suits the locale rather than being hardcoded.
                local when = (FormatShortDate and FormatShortDate(day, month))
                    or ("%d/%d"):format(month, day)
                if hour then
                    -- The event closes mid-morning, not at midnight, so the
                    -- hour is the difference between "today" and "gone".
                    when = ("%s %s"):format(when,
                        (GameTime_GetFormattedTime
                         and GameTime_GetFormattedTime(hour, minute or 0, true))
                        or ("%02d:%02d"):format(hour, minute or 0))
                end
                line = (RR.L["Timewalking until %s"]):format(when)
            end
            GameTooltip:AddLine(line, 1, 1, 1, true)
            if days then
                local r, g, b = 0.4, 0.9, 0.45
                if days <= UI.TIMEWALKING_DAYS_LAST then
                    r, g, b = 0.95, 0.35, 0.35
                elseif days <= UI.TIMEWALKING_DAYS_SOON then
                    r, g, b = 1.00, 0.82, 0.20
                end
                GameTooltip:AddLine(
                    (RR.L["%d day(s) remaining"]):format(days), r, g, b, true)
            end
        end
        -- The seasonal note takes the slot the Timewalking block takes on
        -- a TW row. The two are not expected to coincide -- a dungeon in
        -- the live Mythic+ pool is not usually the Timewalking week -- but
        -- both render if one ever does.
        if self._seasonal then
            if self._timewalking then
                GameTooltip:AddLine(" ")
            end
            GameTooltip:AddLine(
                UI.CAUTION_GLYPH .. " " .. RR.L["Seasonal M+ Dungeon"],
                UI.CAUTION_R, UI.CAUTION_G, UI.CAUTION_B, true)
        end
        -- Why the row reads gray. Leads, because that is what the pointer
        -- is asking about; the lockout gloss under it describes the pills.
        if self._underDevelopment then
            -- A breath between it and any block above, when there is one;
            -- alone it stays the top line.
            if self._timewalking or self._seasonal then
                GameTooltip:AddLine(" ")
            end
            GameTooltip:AddLine(
                UI.DEV_MARKER_GLYPH .. " " .. RR.L["UNDER DEVELOPMENT"],
                UI.DEV_MARKER_R, UI.DEV_MARKER_G, UI.DEV_MARKER_B, true)
        end
        if tipInfo then
            GameTooltip:AddLine(tipInfo.label, 1, 1, 1, true)
            GameTooltip:AddLine(tipInfo.gloss, 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    end)
    hoverFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if GameTooltipText then
            GameTooltipTextLeft1:SetFontObject(GameTooltipText)
        end
    end)
    return hoverFrame
end

local function ReleasePillHoverFrames()
    for _, hoverFrame in ipairs(panel.pillHoverFrames) do
        hoverFrame:Hide()
        hoverFrame:ClearAllPoints()
        table.insert(panel.pillHoverFramePool, hoverFrame)
    end
    wipe(panel.pillHoverFrames)
end

function UI.AcquireNewTagLabel()
    local label = table.remove(panel.newTagLabelPool)
    if not label then
        label = panel:CreateFontString(nil, "OVERLAY")
    end
    table.insert(panel.newTagLabels, label)
    return label
end

function UI.ReleaseNewTagLabels()
    for _, label in ipairs(panel.newTagLabels) do
        label:Hide()
        label:ClearAllPoints()
        table.insert(panel.newTagLabelPool, label)
    end
    wipe(panel.newTagLabels)
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

    -- Two pre-oriented white triangle textures swapped by SetWingChevron, not
    -- runtime SetRotation -- rotation bleeds the texture past its bounds.
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
            and "Interface\\AddOns\\RetroRuns\\Media\\Icons\\TriDown"
            or  "Interface\\AddOns\\RetroRuns\\Media\\Icons\\TriRight"
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

    -- Strikethrough over a dead boss's name. The FontString left-anchors at
    -- the row edge but the name is indented, so the indent's width is measured
    -- and the line spans only the name.
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
        if ff then SafeSetFont(mfs, ff, fsz or fontSize, ffl or "") end
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
-- reserves space for both.
panel.credit = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.credit:SetPoint("BOTTOMLEFT", PAD_LEFT, 8 + FRAME_INSET_Y)
panel.credit:SetText("")
-- Footer credit: standard font, locked at construction (footer doesn't
-- scale with the user's font slider).
SafeSetFont(panel.credit, BODY_FONT, 10, "")

-- Right-side footer cluster: a clickable bracketed version link. A pulsing
-- yellow [!] sits just left of the version until the player clicks it
-- (account-wide, dropped on first click). The pulse reuses the same driver
-- as the encounter-card [!].
panel.version = CreateFrame("Button", nil, panel)
panel.version:SetSize(70, 14)
panel.version:SetPoint("BOTTOMRIGHT", -PAD_RIGHT, 8 + FRAME_INSET_Y)
panel.version.glyph = panel.version:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.version.glyph:SetPoint("BOTTOMRIGHT", panel.version, "BOTTOMRIGHT", 0, 0)
panel.version.glyph:SetText("|cff7faaff[v" .. RetroRuns.VERSION .. "]|r")
-- Footer version glyph: standard font, locked at construction (footer
-- doesn't scale with the user's font slider).
SafeSetFont(panel.version.glyph, BODY_FONT, 10, "")
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
    -- the [!] pulse. The flag is checked when rendering the marker
    -- (see the pulse driver at the bottom of UI.lua).
    if RetroRunsDB then
        RetroRunsDB.whatsNewSeenVersion = RetroRuns.VERSION
    end
    -- Immediately clear the marker so the [!] disappears even before
    -- the next ticker tick.
    if panel.whatsNewLabel then
        panel.whatsNewLabel:SetText("")
    end
    if UI.OpenSettingsToWhatsNew then UI.OpenSettingsToWhatsNew() end
end)

-- New-version [!] marker, sitting just left of the version glyph. Carries
-- only the bracketed exclamation (blank when dismissed); the pulse driver
-- at the bottom of this file rewrites it every ~100ms.
panel.whatsNewLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
panel.whatsNewLabel:SetPoint("BOTTOMRIGHT", panel.version, "BOTTOMLEFT", -4, 0)
panel.whatsNewLabel:SetText("")
-- Locked font like the rest of the footer (no scaling). The pulse ticker
-- rewrites this FontString's text every ~100ms via SetText; SetText
-- preserves the font, so a single SetFont here sticks for the addon's life.
SafeSetFont(panel.whatsNewLabel, BODY_FONT, 10, "")

-- Centered footer status: "Toaster:" + a colored arrow glyph mirroring the
-- settings panel's Active Status (green up = active, amber down = travel to a
-- supported raid, red down = disabled). At-a-glance state without opening
-- settings. Locked font like the rest of the footer (no scaling). The label +
-- arrow are grouped in a container so the pair centers as a unit on the row.
panel.toastStatus = CreateFrame("Button", nil, panel)
panel.toastStatus:SetSize(120, 14)
panel.toastStatus:SetPoint("BOTTOM", 0, 8 + FRAME_INSET_Y)
do
    local toastStatus = panel.toastStatus
    toastStatus.label = toastStatus:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    SafeSetFont(toastStatus.label, BODY_FONT, 10, "")
    toastStatus.label:SetText(RR.L["Toaster:"])
    toastStatus.label:SetTextColor(0.62, 0.62, 0.62)

    toastStatus.arrow = toastStatus:CreateTexture(nil, "OVERLAY")
    toastStatus.arrow:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\ArrowDown")
    toastStatus.arrow:SetSize(10, 10)

    -- Center the label+arrow pair as a group on the footer's bottom baseline.
    toastStatus.Layout = function()
        local lw = toastStatus.label:GetStringWidth() or 0
        local gap, aw = 4, 10
        local total = lw + gap + aw
        toastStatus.label:ClearAllPoints()
        toastStatus.label:SetPoint("BOTTOMLEFT", toastStatus, "BOTTOM", -total / 2, 0)
        toastStatus.arrow:ClearAllPoints()
        toastStatus.arrow:SetPoint("BOTTOMLEFT", toastStatus.label, "BOTTOMRIGHT", gap, 0)
        -- Tighten the click target to the rendered width so it doesn't capture
        -- clicks across the whole footer.
        toastStatus:SetWidth(total + 8)
    end
    toastStatus.Layout()

    -- Clickable shortcut into the Toaster settings tab. Brighten the label
    -- on hover to signal it's interactive (the arrow keeps its state color).
    toastStatus:SetScript("OnEnter", function() toastStatus.label:SetTextColor(0.95, 0.95, 0.95) end)
    toastStatus:SetScript("OnLeave", function() toastStatus.label:SetTextColor(0.62, 0.62, 0.62) end)
    toastStatus:SetScript("OnClick", function()
        if UI.OpenSettingsToToaster then UI.OpenSettingsToToaster() end
    end)

    -- Initial state matches the disabled default (red, down). The lifecycle
    -- reconcile repaints with the live state at login and on every raid
    -- enter/leave and toggle thereafter.
    toastStatus.arrow:SetRotation(0)
    toastStatus.arrow:SetVertexColor(0.95, 0.35, 0.35)
end

-- The footer's center slot, second occupant: how many instances this account
-- has entered against the hourly cap, plus how long until the oldest slot
-- frees. Shares the slot with the Toaster arrow and takes it whenever the
-- panel is showing the instance list -- the arrow can only read "not in a
-- supported raid" there, while the cap is exactly what decides whether the
-- next run on that list can start. The count is every instance, raids
-- included, because the game's cap is.
panel.instanceLimit = CreateFrame("Frame", nil, panel)
panel.instanceLimit:SetSize(160, 14)
panel.instanceLimit:SetPoint("BOTTOM", 0, 8 + FRAME_INSET_Y)
do
    local instanceLimit = panel.instanceLimit
    instanceLimit.label = instanceLimit:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    SafeSetFont(instanceLimit.label, BODY_FONT, 10, "")
    instanceLimit.label:SetText(RR.L["Instance Limit:"])
    instanceLimit.label:SetTextColor(0.62, 0.62, 0.62)

    instanceLimit.value = instanceLimit:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    SafeSetFont(instanceLimit.value, BODY_FONT, 10, "")

    -- Center the label+value pair as a group, the way the Toaster pair does.
    -- Called on every repaint because the value's width changes with the
    -- count and the minutes.
    instanceLimit.Layout = function()
        local labelWidth = instanceLimit.label:GetStringWidth() or 0
        local valueWidth = instanceLimit.value:GetStringWidth() or 0
        local gap = 4
        local total = labelWidth + gap + valueWidth
        instanceLimit.label:ClearAllPoints()
        instanceLimit.label:SetPoint("BOTTOMLEFT", instanceLimit, "BOTTOM", -total / 2, 0)
        instanceLimit.value:ClearAllPoints()
        instanceLimit.value:SetPoint("BOTTOMLEFT", instanceLimit.label, "BOTTOMRIGHT", gap, 0)
        instanceLimit:SetWidth(total + 8)
    end
    instanceLimit:Hide()
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
local BUTTON_Y   = 26 + FRAME_INSET_Y   -- pixels up from the panel's bottom edge (incl. frame inset).
                                        -- The hover footnote sits above the row, so this also sets its
                                        -- clearance from the content above; the credit row below tops
                                        -- out near y=20, leaving ~6px under the buttons.

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
    tex:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\" .. icon)
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

panel.mapBtn = MakeActionButton("Map", RR.L["Map"], "MapIcon.tga",
    START_X,
    -- Second click closes, matching the other action buttons.
    -- ShowCurrentMapForStep stays show-only: it targets a specific uiMap and
    -- is the open half, not a toggle.
    function()
        if WorldMapFrame and WorldMapFrame:IsShown() then
            ToggleWorldMap()
        else
            RR:ShowCurrentMapForStep()
        end
    end)

panel.achievesBtn = MakeActionButton("Achieves", RR.L["Achieves"], "TrophyIcon.tga",
    START_X + (BUTTON_W + BUTTON_GAP) * 1,
    function()
        -- When in a supported raid, default the dropdowns to that raid
        -- before opening (so the user sees their actual context rather
        -- than the last-browsed selection). Out of a raid, fall through
        -- to the preserved last-browsed state. Mirrors the tmog button.
        if RR.currentRaid then
            achState.instanceKind = (RR.currentRaid.kind == "dungeon")
                and "dungeon" or "raid"
            achState.expansion = RR.currentRaid.expansion
            achState.raidKey   = UI.BrowserKeyOf(RR.currentRaid)
        end
        UI.ToggleAchievementsWindow()
    end)

-- Center seat of the five, where the eye lands first.
panel.tmogBtn = MakeActionButton("Tmog", RR.L["Tmog"], "HangerIcon.tga",
    START_X + (BUTTON_W + BUTTON_GAP) * 2,
    function()
        -- When in a supported raid, default the browser to that raid +
        -- current boss before opening (so the user sees their actual
        -- context rather than the last-browsed selection). Out of a
        -- raid, fall through to the preserved last-browsed state.
        UI.PointBrowserAtCurrentInstance()
        UI.ToggleTransmogBrowser()
    end)

panel.skipsBtn = MakeActionButton("Skips", RR.L["Skips"], "SkipIcon.tga",
    START_X + (BUTTON_W + BUTTON_GAP) * 3,
    function() UI.ToggleSkipsWindow() end)

panel.settingsBtn = MakeActionButton("Settings", RR.L["Settings"], "SettingsIcon.tga",
    START_X + (BUTTON_W + BUTTON_GAP) * 4,
    function() UI.ToggleSettings() end)

-------------------------------------------------------------------------------
-- ApplySettings + auto-sizing
--
-- After font and scale are applied, the frame measures its content and
-- re-fits, so no font size can overflow it. Called after any change that
-- affects rendered size; safe to call frequently.
-------------------------------------------------------------------------------

-- Extra breathing room reserved below the last top-down widget. The main
-- panel needs room for the bottom stack (button row ~y=28-50, credit/
-- version ~y=8) plus a visual gap above the buttons separating them
-- from the dynamic content above. ~60px covers the layout with margin.
local POPUP_CONTENT_CEILING  = 900  -- transmog popup max height (tall enough
                                    -- for the longest list -- Ra-den, ToT,
                                    -- 41 items -- without overflow)
local POPUP_CONTENT_MIN      = 240  -- transmog popup min height
-- Width bounds live on the UI table: the file is at Lua 5.1's 200-local
-- ceiling, so new file-level locals are not an option here.
UI.POPUP_DESIGN_W            = 440  -- transmog popup width floor: the layout's
                                    -- design width, sized around English rows
UI.POPUP_MAX_W               = 700  -- transmog popup width ceiling: rows wider
                                    -- than this wrap instead of growing the
                                    -- frame further

-- Attention flash, shared by the transmog search-jump band and the
-- achievements current-boss band: a bright tinted band that holds, then
-- fades to nothing. A persistent marker (scroll position there, the
-- accent bar here) carries the location after the band is gone.
UI.FLASH_BAND_R, UI.FLASH_BAND_G, UI.FLASH_BAND_B = 0.30, 0.80, 1.00
UI.FLASH_BAND_ALPHA    = 0.28
UI.FLASH_FADE_DELAY    = 1.5
UI.FLASH_FADE_DURATION = 3.5


-- Sets a FontString's effective font + text safely and forces layout so
-- GetStringHeight/Width return updated values on the next frame.
-- (WoW font metrics are recomputed on the next render tick normally; we
-- can force the recomputation by poking SetWidth.)
local function ForceFontRelayout(fs)
    if not fs then return end
    local currentWidth = fs:GetWidth()
    if currentWidth and currentWidth > 0 then fs:SetWidth(currentWidth) end
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
    -- The top-line target string shows localized boss and raid names, so it
    -- routes through the chrome font: the pixel title font covers ASCII only
    -- and renders accented characters as boxes. English clients keep the
    -- pixel font.
    SafeSetFont(panel.titleRaidName, RR:GetChromeFont(), TITLE_SIZE, "OUTLINE")

    local bump = RR:GetSetting("fontSize", 12) - 12
    -- { widget, baseSize, flags, useBodyFontStyle? }. The 4th element routes
    -- the font through GetBodyFont so the entry follows the user's
    -- bodyFontStyle; without it the entry stays on BODY_FONT.
    --
    -- Only panel BODY widgets belong here. Header and footer chrome, the
    -- version glyph and the action buttons stay on their construction fonts.
    local targets = {
        { panel.raid,       14, "",        true },
        { panel.pills,      11, "",        true },
        { panel.progress,   14, "OUTLINE", true },
        { panel.next,       14, "OUTLINE", true },
        { panel.exitNote,   11, "",        true },
        { panel.exitNoteExtra, 11, "",     true },
        { panel.skipReturn, 11, "",        true },
        { panel.skipNote,    9, "",        true },
        { panel.travel,     12, "",        true },
        { panel.encounter.header.label,       12, "", true },
        { panel.encounter.achievements.label, 12, "", true },
        { panel.encounter.specialLoot.label,  12, "", true },
        { panel.transmog.label, 12, "",    true },
        { panel.listHeader, 12, "OUTLINE", true },
        { panel.list,       12, "",        true },
    }
    -- ForceFontRelayout pokes the layout system so AutoSize can read a bumped
    -- font's height on the same frame. It is HARMFUL for content-sized
    -- FontStrings, which it pins to the old font's extent -- those go here.
    -- Currently empty; every target has an explicit width or stable anchoring.
    local skipRelayout = {}
    for _, t in ipairs(targets) do
        -- Body-toggle widgets take GetBodyFont and the active font's
        -- sizeFactor, plus a 1px shadow -- pixel fonts antialias to partial
        -- opacity at non-integer sizes and read as dim without it.
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

    -- The popup isn't parented to panel, so it doesn't inherit SetScale.
    -- The settings panel deliberately stays at 1.0x: it is the surface being
    -- dragged while the scale slider moves.
    if tmogWindow then
        tmogWindow:SetScale(scale)
        -- Row-pooled: the loot rows sit at computed x/y offsets, so a font
        -- change needs a full RefreshContent to re-measure and reposition
        -- them. Gated on the layout inputs actually changing -- rebuilding
        -- every heartbeat tick would churn the rows once per second.
        if tmogWindow:IsShown() and tmogWindow.RefreshContent then
            local fontSize  = RR:GetSetting("fontSize", 12)
            local fontStyle = RR:GetSetting("bodyFontStyle", "standard")
            if tmogWindow._lastScale ~= scale
               or tmogWindow._lastFontSize ~= fontSize
               or tmogWindow._lastFontStyle ~= fontStyle then
                tmogWindow._lastScale = scale
                tmogWindow._lastFontSize = fontSize
                tmogWindow._lastFontStyle = fontStyle
                tmogWindow:RefreshContent()
            end
        end
    end

    -- The skips window's rows sit at fixed y-offsets, so a font change needs
    -- a RefreshContent to reposition them. Gate that on scale or font size
    -- ACTUALLY changing: rebuilding every tick recycles the toggle buttons
    -- out from under in-flight clicks. Expand state also resets on a
    -- raid-context change, keyed on instanceID so it stays discrete.
    if skipsWindow then
        skipsWindow:SetScale(scale)

        -- Tracked even while the window is closed: otherwise expands made
        -- before closing reappear on reopen because the reset never fired.
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
            -- Rebuild on a layout-input change or a flagged raid transition.
            -- Font FAMILY counts as an input: changing it without changing
            -- size still needs the rows to pick up the new font.
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
    -- Row-pooled like skips, so font size and family change row spacing.
    -- Gated on those inputs rather than refreshing every tick, which would eat
    -- row interactions.
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

    -- Substitutes the alpha channel only, reading each window's live backdrop
    -- RGB rather than hardcoding it. Text stays full-opacity.
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
    UI.UpdateAmbientArt()
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
-- Minimized mode renders the panel as a title-bar only, with body fields and
-- footer buttons hidden. Persists via the `minimized` setting. Height is fixed
-- at MINIMIZED_PANEL_H and AutoSize is a no-op while minimized. The top edge
-- stays put across the resize, so the panel grows downward.

-- Height of the minimized panel. 44 rather than the ~50 the content needs:
-- the logo overhangs the bottom edge by design, which reads less cramped.
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
        panel.exitNote, panel.exitNoteExtra, panel.skipReturn, panel.skipNote,
        panel.listHeader, panel.list,
        panel.credit, panel.version, panel.whatsNewLabel,
        panel.mapBtn, panel.tmogBtn, panel.achievesBtn,
        panel.skipsBtn, panel.settingsBtn,
        panel.actionFootnote,
    }
    return list
end

-- Shows or hides every body and footer element, including the dynamic
-- FontString arrays. Pool tables hold already-hidden frames and are skipped.
local function ApplyBodyVisibility(visible)
    for _, fs in ipairs(GetBodyAndFooterElements()) do
        if fs then
            if visible then fs:Show() else fs:Hide() end
        end
    end

    -- The footer's center slot has two occupants sharing one anchor -- the
    -- Toaster arrow and the instance counter -- so exactly one may ever be
    -- shown. They are deliberately NOT in the inventory above: it shows
    -- everything it holds, which drew both on top of each other. Visibility
    -- for the pair belongs to UI.RefreshFooterStatus alone.
    if visible then
        if UI.RefreshFooterStatus then UI.RefreshFooterStatus() end
    else
        if panel.toastStatus   then panel.toastStatus:Hide()   end
        if panel.instanceLimit then panel.instanceLimit:Hide() end
    end
    for _, fs in ipairs(panel.idleListLines or {}) do
        if visible then fs:Show() else fs:Hide() end
    end
    for _, cell in ipairs(panel.idlePillCells or {}) do
        if visible then cell:Show() else cell:Hide() end
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
    for _, hoverFrame in ipairs(panel.pillHoverFrames or {}) do
        if visible then hoverFrame:Show() else hoverFrame:Hide() end
    end
    if panel.pillsHover then
        if visible then panel.pillsHover:Show() else panel.pillsHover:Hide() end
    end
    -- Hide-only: the idle-mode toggle line belongs to the plain-idle
    -- branch of UI.Update, which is the only code that shows it.
    -- Re-showing it here would leak it into non-idle states.
    if panel.idleModeLine and not visible then
        panel.idleModeLine.SetShown(false)
    end
end

-- Update the minimize button's texture based on current minimized state.
-- MinimizeIcon shows when expanded (click to minimize); MaximizeIcon
-- shows when minimized (click to expand). Swaps the single _tex texture.
local function UpdateMinimizeIcon()
    if not panel.minimizeButton or not panel.minimizeButton._tex then return end
    local tex
    if UI.IsMinimized() then
        tex = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\MaximizeIcon"
    else
        tex = "Interface\\AddOns\\RetroRuns\\Media\\Icons\\MinimizeIcon"
    end
    panel.minimizeButton._tex:SetTexture(tex)
end

-- Panel width for the title-bar content alone. Measured at apply time rather
-- than baked in, since the title's width depends on font face and flags.

-- Scale applied to the title wordmark and the title-row buttons. Used both
-- when laying out the row and when computing the bar width from the title's
-- string width, so it lives as one named value rather than a repeated literal.
local TITLE_SCALE = 0.83

-- When the minimized bar shows a next-step note, the wordmark becomes a small
-- "RetroRuns" title tab that straddles the top frame line (half above, half
-- below), and the note takes the wordmark's old far-left spot. This is the
-- tab's scale relative to the base title scale; 0.5 reads as a compact label
-- against the 24pt title font.
local RR_TITLE_TAB_SCALE = 0.5
-- The completion banner replaces the boss label on the top line. It is the
-- whole message at that point rather than one of two paired readouts, so it
-- runs a step larger than the tab scale.
UI.RR_TITLE_BANNER_SCALE = 0.62

-- Route-active minimized-bar edge clearances, screen px. Shared between the
-- layout function and the width computation, and registered against the left
-- cap's baked line gap, so they live as named values.
-- On the UI table, not file locals, to stay under the 200-local ceiling here.
UI.MINBAR_EDGE_PX = 8        -- left clearance for the "RR" tab, which straddles the frame
-- The body row sits INSIDE the frame, so it needs to clear the left cap's
-- border art rather than straddle it like the tab above.
UI.MINBAR_BODY_EDGE_PX = 16
UI.MINBAR_RAID_EDGE_PX = 10  -- right clearance for the raid-name label

-- Width of the minimized bar, from the title's rendered STRING width rather
-- than live screen edges -- those can resolve transiently wrong while layout
-- is mid-flight on an unrelated event.
local function ComputeMinimizedPanelW()
    if not panel.titleRetro or not panel.titleRuns then return nil end
    local retroW = panel.titleRetro:GetStringWidth()
    if not retroW or retroW <= 0 then
        -- Text not yet rendered (e.g. first call after a fresh reload);
        -- caller falls back to MINIMIZED_PANEL_W_FALLBACK for one frame.
        return nil
    end
    -- titleRuns is hidden on the route-active bar (the "RR" tab is a single
    -- string in titleRetro); only require its width when it's actually shown.
    local runsW = 0
    if panel.titleRuns:IsShown() then
        runsW = panel.titleRuns:GetStringWidth()
        if not runsW or runsW <= 0 then return nil end
    end
    -- Layout from the panel right edge for the text rows:
    --   close + minimize + search buttons occupy ~82px inside the right edge
    --   (the close button clears the curved corner at 12px, the minimize and
    --   search buttons continue leftward at 30-unit centers), and a 12px gap
    --   keeps the text clear of them.
    local rightSideWidth   = 82
    local titleToButtonGap = 12
    if panel.titleMinNote and panel.titleMinNote:IsShown() then
        -- Route-active bar: the wider of two constraints. String widths are
        -- pre-scale, so multiply by effective scale for screen px.
        --   top line: "RR" tab left, boss label + count right, open line between.
        --   body row: the minNote, left-anchored, clearing the buttons.
        local tabScale      = TITLE_SCALE * RR_TITLE_TAB_SCALE
        local edge          = UI.MINBAR_EDGE_PX
        local topLineGapMin = 24
        local raidW = (panel.titleRaidName and panel.titleRaidName:IsShown())
                      and (panel.titleRaidName:GetStringWidth() or 0) or 0
        -- The right-hand top-line string runs at the banner scale on a
        -- completed run and the tab scale otherwise; measure it at whichever
        -- it is actually using, or the bar under-measures and clips it.
        local raidScale = (panel.titleRaidName and panel.titleRaidName:GetScale())
                          or tabScale
        local needed = edge + (retroW + runsW) * tabScale + topLineGapMin
                       + raidW * raidScale + UI.MINBAR_RAID_EDGE_PX
        local noteW = panel.titleMinNote:GetStringWidth() or 0
        local noteRow = UI.MINBAR_BODY_EDGE_PX + noteW * TITLE_SCALE
                        + titleToButtonGap + rightSideWidth
        if noteRow > needed then needed = noteRow end
        return math.ceil(needed)
    end
    -- Single-row bar (no route): the full wordmark at PAD_LEFT, buttons at
    -- the right.
    local titleRightLocal = PAD_LEFT + (retroW + runsW) * TITLE_SCALE
    return math.ceil(titleRightLocal + titleToButtonGap + rightSideWidth)
end

-- Fallback for when the text isn't rendered yet after a reload. The next
-- heartbeat re-measures within a second.
local MINIMIZED_PANEL_W_FALLBACK = 240

-- Applies height and visibility for whatever the minimized setting currently
-- says, so it also serves restore-time after /reload. Runs on every refresh
-- and deliberately does not short-circuit: RefreshIdleList acquires new
-- FontStrings later in the same update that must inherit the current state.
--
-- Positions the wordmark and top-right buttons: top-anchored when expanded,
-- vertically centered in the short bar when minimized.
--
-- Route-active form needs a minNote plus a boss count and current target from
-- the active route. It draws the bespoke frame art with the "RR" tab and the
-- boss label on the top line, and the minNote as the body row. A completed run
-- uses the same two-row form for its banner and exit line.
function UI.MinimizedBarRouteActive()
    if RR.IsActiveRouteComplete and RR:IsActiveRouteComplete() then
        return true
    end
    local minNote = RR.GetActiveMinNote and RR:GetActiveMinNote() or nil
    if not (minNote and minNote ~= "") then return false end
    local _, total = RR:GetActiveRouteProgress()
    local targetName = RR:GetActiveTargetName()
    return total > 0 and targetName ~= nil
end

local function ApplyTitleLayoutForState(minimized)
    if minimized then
        -- Shrink via SetScale (not SetFont/SetSize): scaling shrinks the glyph
        -- AND the bounding box together, so the RETRO/RUNS spacing stays tight
        -- and the close button's X actually shrinks (SetSize leaves the template
        -- X glyph full-size). TITLE_SCALE = roughly 10pt-equivalent for the
        -- 12pt title and ~10% off the buttons.
        local titleScale = TITLE_SCALE
        panel.titleRetro:SetScale(titleScale)
        panel.titleRuns:SetScale(titleScale)
        panel.titleRaidName:SetScale(titleScale)
        panel.titleMinNote:SetScale(titleScale)
        panel.closeButton:SetScale(titleScale)
        panel.minimizeButton:SetScale(titleScale)

        -- A non-nil GetActiveMinNote is the signal that per-segment data
        -- exists; only then does the wordmark collapse to "RR".
        local minNote = RR.GetActiveMinNote and RR:GetActiveMinNote() or nil
        local showNote = minNote and minNote ~= ""

        -- Run complete: no active step, so no minNote, but the player still
        -- needs the way out. The note row carries the short exit form, which
        -- always resolves (a raid with no authored exit says so plainly),
        -- and the top line carries the completion banner in place of the
        -- boss label, which has no target to point at.
        local completeBanner
        if not showNote
            and RR.IsActiveRouteComplete and RR:IsActiveRouteComplete() then
            if RR:GetActiveWing() then
                completeBanner = RR.L["|cff00ff00LFR Wing Complete!|r"]
            elseif (RR.state and RR.state.activeRouteVariant == "skip")
                or (RR.ActiveRouteSkippedOptionalBoss
                    and RR:ActiveRouteSkippedOptionalBoss()) then
                completeBanner = RR.L["|cff00ff00Skip Run Complete!|r"]
            else
                -- Neutral wording: the bar reads the same on a raid and
                -- on a dungeon, and matches the main panel's banner for
                -- the same event. The two branches above are raid-only.
                completeBanner = RR.L["|cff00ff00Run complete!|r"]
            end
            minNote = "|cfff259c7" .. RR.L["Exit:"] .. "|r "
                .. (RR.GetActiveMinExitNote and RR:GetActiveMinExitNote() or "")
            showNote = true
        end
        if showNote then
            -- Route active. Top frame line: the "RR" tab at the left end and the
            -- boss label + count at the right end, both straddling the line. The
            -- single body row shows the minNote. The tab is one string with the
            -- pink/blue split inline; two abutted strings leave an outline gap
            -- between the letters at this size.
            panel.titleRetro:SetText(("|cff%sR|r|cff4dccffR|r"):format(C_PINK_HEX))
            panel.titleRuns:SetText("")
            panel.titleRuns:Hide()
            panel.titleRetro:SetScale(titleScale * RR_TITLE_TAB_SCALE)

            -- Boss label plus its place in the route's kill order. The
            -- position takes brand blue rather than gray: at tab scale a dim
            -- gray gets swallowed by the black outline.
            local pos, total = RR:GetActiveTargetPosition()
            local label = RR:GetActiveTargetLabel()
            local posColor = "|cff4dccff"
            if completeBanner then
                -- Run complete: the top line carries the completion banner in
                -- place of the boss label, which has no target to point at.
                panel.titleRaidName:SetText(completeBanner)
            elseif pos and total then
                panel.titleRaidName:SetText(
                    ("%s %s%d/%d|r"):format(label or "", posColor, pos, total))
            else
                panel.titleRaidName:SetText(label or "")
            end
            panel.titleRaidName:SetScale(titleScale
                * (completeBanner and UI.RR_TITLE_BANNER_SCALE or RR_TITLE_TAB_SCALE))
            panel.titleRaidName:Show()

            panel.titleMinNote:SetText(minNote)
            panel.titleMinNote:Show()
        else
            panel.titleRetro:SetText("RETRO")
            panel.titleRuns:SetText("RUNS")
            panel.titleRuns:Show()
            panel.titleRaidName:SetText("")
            panel.titleRaidName:Hide()
            panel.titleMinNote:SetText("")
            panel.titleMinNote:Hide()
        end

        -- No route: the wordmark centers on the bar. Route active: the "RR"
        -- tab and the boss label straddle the top frame line at either end,
        -- with the minNote as the body row.
        --
        -- SetPoint offsets are in the anchored string's OWN effective scale --
        -- top-line strings divide by s * RR_TITLE_TAB_SCALE, the minNote by s.
        local tabScale  = titleScale * RR_TITLE_TAB_SCALE
        -- Buttons sit inside the bar's curved right corner. The right end cap's
        -- border arc occupies the rightmost few screen px of the frame, so the
        -- close button (the rightmost control) needs enough clearance that its
        -- glyph and glow don't tuck under the curve. 12px clears the arc with a
        -- small margin.
        local btnEdge   = 12 / titleScale
        panel.titleRetro:ClearAllPoints()
        panel.titleRaidName:ClearAllPoints()
        panel.titleMinNote:ClearAllPoints()
        if showNote then
            local edgePx = UI.MINBAR_EDGE_PX  -- left clearance, screen px
            -- "RR" tab: half out of the frame, aligned to the left clearance
            -- (registered against the left cap's baked line gap).
            panel.titleRetro:SetPoint("LEFT", panel, "TOPLEFT", edgePx / tabScale, 0)
            -- Boss label + count at the right end of the top line. The notch
            -- texture (laid out in LayoutMinbarArt) breaks the border line
            -- behind it.
            local rightScale = titleScale
                * (completeBanner and UI.RR_TITLE_BANNER_SCALE or RR_TITLE_TAB_SCALE)
            panel.titleRaidName:SetPoint("RIGHT", panel, "TOPRIGHT",
                -(UI.MINBAR_RAID_EDGE_PX) / rightScale, 0)
            -- minNote: single body row, centered in the bar height. Inside the
            -- frame, so it takes the wider body clearance.
            panel.titleMinNote:SetPoint("LEFT", panel, "LEFT",
                UI.MINBAR_BODY_EDGE_PX / titleScale, 0)
        else
            panel.titleRetro:SetPoint("LEFT", panel, "LEFT", 20 / titleScale, 0)
            -- Restore the note's creation-time chain anchor (unused while
            -- hidden, but keeps the layout coherent if text is set before the
            -- next layout pass).
            panel.titleMinNote:SetPoint("LEFT", panel.titleRuns, "RIGHT", 6, 0)
        end
        panel.closeButton:ClearAllPoints()
        panel.closeButton:SetPoint("RIGHT", panel, "RIGHT", -btnEdge, 0)
        -- Center the minimize button on the close button's CENTER so the two sit
        -- at exactly the same height. Both are 24px frames; the x-offset tucks
        -- them together with a small gap. Buttons anchor to the bar's vertical
        -- center (RIGHT = mid-height). The search shortcut continues the row
        -- leftward at the same spacing, minimized-bar only.
        panel.minimizeButton:ClearAllPoints()
        panel.minimizeButton:SetPoint("CENTER", panel.closeButton, "CENTER", -30, 0)
        panel.searchButton:SetScale(titleScale)
        panel.searchButton:ClearAllPoints()
        panel.searchButton:SetPoint("CENTER", panel.minimizeButton, "CENTER", -30, 0)
        panel.searchButton:Show()
        panel.idleSearchButton:Hide()
        -- The bar has no body to divide off.
        panel.titleDivider:Hide()
    else
        -- Expanded panel: same compact scale as the minimized bar, and the
        -- title row placed at the SAME distance from the top border as the
        -- minimized bar (where the title centers in MINIMIZED_PANEL_H). This
        -- keeps the title-to-top-border gap identical between the two states.
        local titleScale = TITLE_SCALE
        panel.titleRetro:SetScale(titleScale)
        panel.titleRuns:SetScale(titleScale)
        panel.titleRaidName:SetScale(titleScale)
        panel.titleMinNote:SetScale(titleScale)
        panel.closeButton:SetScale(titleScale)
        panel.minimizeButton:SetScale(titleScale)
        -- Expanded panel always shows the full wordmark; the top-line target
        -- string and the next-step note are minimized-bar-only affordances, so
        -- restore "RETRO RUNS" and hide both.
        panel.titleRetro:SetText("RETRO")
        panel.titleRuns:SetText("RUNS")
        panel.titleRuns:Show()
        panel.titleRaidName:SetText("")
        panel.titleRaidName:Hide()
        panel.titleMinNote:SetText("")
        panel.titleMinNote:Hide()
        local expandedRowCenterY = -26
        panel.closeButton:ClearAllPoints()
        panel.closeButton:SetPoint("RIGHT", panel, "TOPRIGHT", (-22) / titleScale, expandedRowCenterY / titleScale)
        panel.minimizeButton:ClearAllPoints()
        panel.minimizeButton:SetPoint("CENTER", panel.closeButton, "CENTER", -30, 0)
        panel.searchButton:Hide()
        panel.idleSearchButton:SetScale(titleScale)
        panel.idleSearchButton:ClearAllPoints()
        -- Dropped 2px, the same compensation the browser and achievements
        -- glasses carry: UI-Searchbox-Icon's glyph sits high in its box, so
        -- a true CENTER against the square close/minimize art reads high and
        -- crowds the top border.
        panel.idleSearchButton:SetPoint("CENTER", panel.minimizeButton,
            "CENTER", -30, -2)
        -- Hidden while a run is being guided. The glass changes what it
        -- searches with the panel's state -- appearances inside a loaded
        -- instance, the instance list otherwise -- and one button with two
        -- targets is a coin flip for the player. It returns as soon as the
        -- panel is showing the instance list again.
        if UI.IsShowingInstanceList() then
            panel.idleSearchButton:Show()
        else
            panel.idleSearchButton:Hide()
            if UI.CloseIdleSearch then UI.CloseIdleSearch() end
        end
        -- Title: centered on the panel, vertical center matched to the
        -- button row center. RETRO and RUNS are two chained FontStrings,
        -- so the pair is measured and the head placed half the run to the
        -- left of center. Offsets are in the anchored string's own scaled
        -- space, hence the divisions.
        panel.titleRetro:ClearAllPoints()
        local wordmarkWidth = (panel.titleRetro:GetStringWidth() or 0)
            + (panel.titleRuns:GetStringWidth() or 0)
        local titleLeft = (PANEL_W / titleScale - wordmarkWidth) / 2
        -- The pixel wordmark's glyph box sits high in its line, so it
        -- reads as hugging the top border on the shared row center. Drop
        -- it a couple of pixels; the buttons keep the true center.
        local titleDrop = 3
        -- Never let a long localized wordmark run under the button
        -- cluster; fall back to the old left margin instead.
        if titleLeft < PAD_LEFT / titleScale then
            titleLeft = PAD_LEFT / titleScale
        end
        panel.titleRetro:SetPoint("LEFT", panel, "TOPLEFT", titleLeft,
            (expandedRowCenterY - titleDrop) / titleScale)

        -- Divider tucked under the wordmark, overhanging it by about a
        -- fifth of its width at each end so it reads as underlining the
        -- title rather than boxing it.
        -- Everything here is PANEL space: the wordmark's own width and
        -- height are in its scaled space, so both are multiplied up, and
        -- the divider anchors to the panel rather than to the scaled
        -- title -- an offset against a scaled anchor is measured in that
        -- anchor's space and drifts as the scale changes.
        local wordmarkHeight = (panel.titleRetro:GetStringHeight() or 12)
            * titleScale
        panel.titleDivider:ClearAllPoints()
        panel.titleDivider:SetWidth(math.max(1,
            math.ceil(wordmarkWidth * titleScale * 1.55)))
        panel.titleDivider:SetPoint("CENTER", panel, "TOPLEFT", PANEL_W / 2,
            expandedRowCenterY - titleDrop - wordmarkHeight / 2 - 3)
        panel.titleDivider:Show()
    end
end

function UI.ApplyMinimizedState()
    local minimized = UI.IsMinimized()
    UpdateMinimizeIcon()
    ApplyBodyVisibility(not minimized)
    -- Title layout first: the border art's notch is laid out against the
    -- raid-name label, so the label's text and visibility must be current
    -- before LayoutMinbarArt runs.
    ApplyTitleLayoutForState(minimized)
    ApplyBorderArtForState(minimized)

    if minimized then
        -- Pin both edges: SetHeight and SetWidth on a CENTER-anchored frame
        -- each redistribute their delta equally, so the panel would otherwise
        -- jump in two directions.
        local oldH = panel:GetHeight() or MINIMIZED_PANEL_H
        local oldW = panel:GetWidth() or PANEL_W
        -- The route-active bar is single-row too now (the boss label and count
        -- ride the top frame line, not a second body row), so the height is
        -- always the single-row height.
        local newH = MINIMIZED_PANEL_H
        local newW = ComputeMinimizedPanelW() or MINIMIZED_PANEL_W_FALLBACK
        local heightChanged = math.abs(newH - oldH) > 0.5
        local widthChanged  = math.abs(newW - oldW) > 0.5
        -- Geometry writes are skipped mid-drag (see the OnDragStart note).
        -- The panel is anchored TOPLEFT, so shrinking it holds that corner
        -- with no re-anchor and nothing to persist: the saved anchor stays
        -- the user's drag, whatever size the panel happens to be.
        if (heightChanged or widthChanged) and not panel.isBeingDragged then
            if heightChanged then panel:SetHeight(newH) end
            if widthChanged  then panel:SetWidth(newW)  end
        end
        -- If both dimensions are already at minimized values (steady-
        -- state per-heartbeat call after minimize completed), skip
        -- the resize entirely to keep the per-tick cost bounded.
    else
        -- Symmetric to the minimize path's LEFT-pin, so the panel grows back
        -- rightward from its current left edge rather than from center.
        local oldW = panel:GetWidth() or PANEL_W
        -- Geometry writes are skipped mid-drag (see the OnDragStart note).
        -- TOPLEFT-anchored: growing back to full width extends rightward
        -- from the pinned corner on its own.
        if math.abs(PANEL_W - oldW) > 0.5 and not panel.isBeingDragged then
            panel:SetWidth(PANEL_W)
        end
        -- Falling through to AutoSize handles the maximize-side height
        -- resize. AutoSize does the same TOP-PIN math when the height
        -- changes, so the visual top-edge stability still applies.
        UI.AutoSize()
    end
end

-- Public toggle, used by the minimize button. Runs a full UI.Update after the
-- flip so idle-state visibility is re-asserted -- otherwise elements that
-- should stay hidden flicker until the next heartbeat.
function UI.SetMinimized(value)
    -- A state flip re-anchors the search under the other glass; close it
    -- rather than leaving a box tied to a hidden button.
    if UI.CloseIdleSearch then UI.CloseIdleSearch() end
    RR:SetSetting("minimized", value and true or false)
    UI.Update()
end

-- Shared open/close toggle for the minimap button and the slash command. Both
-- are explicit "show me the panel" actions, so the open path always fully
-- expands regardless of launchMode or the minimized setting.
function UI.TogglePanelExpanded()
    -- A panel the instance gate is holding closed counts as closed here:
    -- the click means "open it", and the gate yields to that until the
    -- player leaves the instance.
    local panelVisible = RetroRunsUI and RetroRunsUI:IsShown()
    if RR:GetSetting("showPanel") and panelVisible then
        RR:SetSetting("showPanel", false)
        if RetroRunsUI then RetroRunsUI:Hide() end
    else
        RR:SetSetting("showPanel", true)
        RR.state.panelOpenedByHand = true
        -- In a raid with nothing loaded yet, adopt the current raid so the
        -- panel shows its route rather than the idle credit.
        if RR.currentRaid and not RR.state.loadedRaidKey then
            RR.state.loadedRaidKey = RR:GetRaidContextKey()
        end
        -- Force expanded. SetMinimized repaints via UI.Update, so when it
        -- runs no separate RefreshAll is needed; otherwise refresh here.
        if UI.IsMinimized() then
            UI.SetMinimized(false)
        else
            RR:RefreshAll()
        end
    end
end

-- Wire up the minimize button's OnClick now that SetMinimized exists.
panel.minimizeButton:SetScript("OnClick", function()
    UI.SetMinimized(not UI.IsMinimized())
end)


-- Resizes the main panel (and ancillary frames) to fit their current
-- content. Safe to call at any time; idempotent.
function UI.AutoSize()
    -- While minimized the panel's height is pinned by ApplyMinimizedState,
    -- so the panel resize below is skipped -- but not the transmog-popup
    -- sizing at the bottom: the minimized bar's search button opens the
    -- browser with the panel still minimized, and an early return here
    -- left that window unsized, colliding content with its legend footer.
    local panelHeightPinned = UI.IsMinimized()

    -- Bottom of the layout is whichever pool is non-empty -- in-raid
    -- boss-progress lines, or idle supported-raids list.
    local fontSize   = RR:GetSetting("fontSize", 12)
    -- Per-row advance is fontHeight + the 2px gap the rows are laid out at.
    -- Any extra padding here multiplies across every row.
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
                      + (panel._idleListExtraGapPx or 0)
                      + 8  -- top spacing under listHeader
        listH = math.max(listH, idleH)
        hasContent = true
    end

    -- Skip the panel resize/re-anchor entirely while the panel is being
    -- dragged (see the OnDragStart note) or minimized; the drag-stop
    -- handler and ApplyMinimizedState re-run the layout pass. The
    -- transmog-popup sizing below is unaffected -- it never writes panel
    -- geometry.
    if hasContent and not panel.isBeingDragged and not panelHeightPinned then
        -- Footer reserve: the action button row, plus the legend block in
        -- idle mode. Measured from LEGEND_BOTTOM_OFFSET, not the button-row
        -- top -- the gap between them is what the list would overlap into.
        local buttonsTopFromBottom = BUTTON_Y + BUTTON_H  -- BUTTON_Y includes frame inset
        local isInRaidMode         = #panel.progressListLines > 0
        local footerReserve
        if isInRaidMode then
            -- In-raid reserve: button row plus a footnote line above it.
            local FOOTNOTE_RESERVE = GetBodyFontSize(10) + 12
            footerReserve = buttonsTopFromBottom + FOOTNOTE_RESERVE
        else
            -- Mirrors RefreshIdleList's legend constants: up to 3 rows
            -- worst-case, each a legend-size row plus padding, with gaps
            -- between and a cushion above the topmost.
            local LEGEND_BOTTOM_OFFSET = BUTTON_Y + BUTTON_H + 12  -- BUTTON_Y includes frame inset
            local LEGEND_INTER_GAP     = 4
            -- Band between the last row and the legend, holding the
            -- divider. The RENDERED band measures ~10px wider than this:
            -- the reserve rounds the legend up to whole rows while the
            -- block itself renders shorter, and the slack lands above it.
            -- Tuned against the measured band, not the nominal one.
            -- FLOOR: must exceed the divider gem's 14px height, or the gem
            -- has nowhere to sit. idle_layout_harness pins that.
            local LEGEND_TOP_CUSHION   = 16
            -- The entrance row carries the plane glyph at the same size as
            -- the real plane buttons (1.4x the BODY font), which is taller
            -- than a legend-font line and stretches that FontString. Reserve
            -- the larger of the two, or the block overruns its band -- by
            -- more the further up the font slider goes.
            local legendLineHeight     = math.max(
                GetBodyFontSize(10) + 4,
                math.floor(RR:GetSetting("fontSize", 12) * 1.4))
            -- Reserve for the legend rows actually present (0-3) rather than a
            -- fixed worst-case 3 -- reserving 3 when fewer show left a big empty
            -- band above the footer in the idle view.
            -- Counted per rendered row, not per FontString: the entrance rows
            -- carry a label and a value string each, and counting strings
            -- reserved a phantom third row on the dungeon list.
            local legendRows           = panel._idleLegendRows
                                         or #(panel.idleListLegendLines or {})
            if legendRows > 3 then legendRows = 3 end
            if legendRows < 1 then
                -- NOTHING renders down there: the collapsed expansion list
                -- carries neither a skip nor an entrance legend. The old
                -- floor of 1 reserved a row and its cushion for a block that
                -- never drew, which is the empty band between the last
                -- expansion and the action buttons. PositionLegendDivider is
                -- already guarded on the same count, so no divider is being
                -- reserved for either.
                footerReserve = LEGEND_BOTTOM_OFFSET
            else
                local legendBlockHeight = legendRows * legendLineHeight
                                        + math.max(0, legendRows - 1) * LEGEND_INTER_GAP
                footerReserve = LEGEND_BOTTOM_OFFSET + legendBlockHeight
                                + LEGEND_TOP_CUSHION
            end
        end

        local parentTop      = panel:GetTop()
        local listHeaderBot  = panel.listHeader and panel.listHeader:GetBottom()
        if parentTop and listHeaderBot then
            -- GetTop/GetBottom/GetHeight and SetHeight all work in the
            -- FRAME's own scaled space, so only maxH needs converting --
            -- UIParent's effective scale differs.
            local scale          = panel:GetScale() or 1
            local topToListTop   = (parentTop - listHeaderBot) + 4
            local desired        = topToListTop + listH + footerReserve
            local screenH        = UIParent:GetHeight() or 900
            local maxH           = (screenH * 0.9) / scale
            local minH           = 240
            -- Rounded, and only applied past a full pixel of change. The
            -- height feeds back into itself: `desired` is measured from
            -- panel:GetTop() minus a child's GetBottom(), so the panel's own
            -- height is an input to the height it asks for. With sub-pixel
            -- error it never settles, and the center moves half a pixel on
            -- every layout pass. Integer heights plus a 1px deadband stop it;
            -- a genuine 1px difference is not worth a re-anchor anyway.
            local newH = math.max(minH, math.min(maxH, desired))
            newH = math.floor(newH + 0.5)

            local oldH = panel:GetHeight() or newH
            if math.abs(newH - oldH) < 1.5 then
                newH = oldH or newH
            else
                panel:SetHeight(newH)
                UI.UpdateAmbientArt()
            end
            -- No re-anchor: a TOPLEFT-anchored frame grows downward from a
            -- fixed top edge, which is exactly what the old CENTER maths
            -- was reconstructing by hand -- and what fed the height back
            -- into itself as an oscillation.
        end
    end

    -- Now that the panel height (and thus the bottom-pinned legend's screen
    -- position) is final, place the divider at the midpoint between the last
    -- raid row and the legend top. Guarded internally for the no-legend case;
    -- skipped while minimized, where the legend is hidden with the body.
    if PositionLegendDivider and not panelHeightPinned then
        PositionLegendDivider()
    end
    -- The art's floor follows the divider, so it is laid out after it.
    UI.UpdateAmbientArt()

    -- TRANSMOG POPUP -------------------------------------------------------
    -- The scroll CHILD takes the full content height so everything is
    -- reachable; the POPUP takes chrome + a capped viewport + the legend
    -- footer. Content under the cap shows no scrollbar. Width and content
    -- height come from the row layout pass in RefreshContent, which is
    -- the only code that touches the row widgets; this block just fits
    -- the frame and the scroll viewport around the stored geometry.
    if tmogWindow and tmogWindow.tmogContentH then
        local scroll = tmogWindow.contentScroll
        local child  = tmogWindow.contentChild

        local popupFontSize     = RR:GetSetting("fontSize", 12)
        local renderedSize = math.max(8, popupFontSize - 1)
        local popupLineHeight   = GetBodyFontSize(renderedSize) + 0.5

        if scroll then
            scroll:ClearAllPoints()
            -- Two single-axis anchors, vertical from the dropdown stack and
            -- horizontal from the content margin, so neither depends on
            -- GetTop/GetBottom -- which can be nil mid-layout.
            local margin = tmogWindow.contentMargin or 22
            scroll:SetPoint("TOP",  tmogWindow.ddClass, "BOTTOM", 0, -10)
            scroll:SetPoint("LEFT", tmogWindow, "LEFT", margin, 0)
            local popupW = tmogWindow:GetWidth() or UI.POPUP_DESIGN_W
            scroll:SetWidth(math.max(1, popupW - margin - 28))
        end

        local contentH = tmogWindow.tmogContentH

        -- Color legend footer: its line count (2, or 3 where a faction-pair
        -- line is present), an 8px gap above it, plus the divider band
        -- (6px line + its 6px clearance).
        local legendH = (tmogWindow.legendLineCount or 2) * popupLineHeight
                        + 8 + 12

        -- Popup chrome: top close-button reserve + dropdown stack (five
        -- dropdowns anchored BOTTOMLEFT +4 overlap by 4px each, so 5*32-12)
        -- + gap below dropdowns + bottom margin.
        local chromeTop = 32 + (5 * 32 - 12) + 10
        local chromeBot = 14                        -- bottom margin under legend

        -- Maximum content viewport: whatever the ceiling leaves after chrome
        -- and the legend footer. Content taller than this scrolls.
        local maxViewport = POPUP_CONTENT_CEILING - chromeTop - chromeBot - legendH
        if maxViewport < popupLineHeight then maxViewport = popupLineHeight end
        local viewportH = math.min(contentH, maxViewport)

        local desired = chromeTop + viewportH + legendH + chromeBot
        local clamped = math.max(POPUP_CONTENT_MIN,
                                 math.min(POPUP_CONTENT_CEILING, desired))
        tmogWindow:SetHeight(clamped)

        -- Now set the heights: scroll viewport to EXACTLY viewportH, child to
        -- EXACTLY contentH (the measured content). When the content fits
        -- (contentH <= viewportH) these are equal and the scroll range is
        -- precisely zero, so no scrollbar appears.
        if scroll and child then
            scroll:SetHeight(math.max(1, viewportH))
            child:SetHeight(math.max(1, contentH))

            -- The layout decides scrollability, not GetVerticalScrollRange,
            -- which can hold a phantom couple of pixels when the viewport,
            -- child and content rects are identical.
            tmogWindow.tmogContentScrollable = contentH > (viewportH + 0.5)

            -- Recompute the scroll child rect so the engine's range reflects
            -- the sizes just set instead of a stale layout.
            if scroll.UpdateScrollChildRect then
                scroll:UpdateScrollChildRect()
            end

            -- The template shows its scrollbar unconditionally, so the OnShow
            -- guard and the OnScrollRangeChanged hook together cover its
            -- deferred re-show paths.
            if tmogWindow.EnsureTmogBarGuard then tmogWindow.EnsureTmogBarGuard() end
            local bar = tmogWindow.ResolveTmogScrollBar
                        and tmogWindow.ResolveTmogScrollBar()
            if bar then
                local range = scroll:GetVerticalScrollRange() or 0
                if tmogWindow.tmogContentScrollable and range > 1 then
                    bar:Show()
                else
                    bar:Hide()
                    if scroll.SetVerticalScroll then scroll:SetVerticalScroll(0) end
                end
            end
        end
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

local C_ORANGE = RR.C_ORANGE

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

-- Colorizes difficulty words in a tip, context-free and on word boundaries.
-- Words already inside a |c...|r span are left alone, so a caret-marked
-- ^Mythic^ keeps the author's orange.
--
-- Match order is longest-first. English words are always present; the client's
-- own difficulty names are merged in so translated notes colorize too. Built
-- lazily once per session.
function UI.GetDifficultyColorWords()
    if UI._difficultyColorWords then return UI._difficultyColorWords end

    local colors = {}
    local order  = {}
    for _, word in ipairs(DIFFICULTY_COLOR_ORDER) do
        colors[word] = DIFFICULTY_COLORS[word]
        order[#order + 1] = word
    end

    -- Client-localized names: 17 = Raid Finder, 14/15/16 = N/H/M, 3/4/5/6
    -- the Wrath sizes ("10 Player" etc.). The sizes reuse the Normal color
    -- (plain 10/25) and the Heroic color (heroic 10/25) so the palette
    -- stays at four. On an English client the 14/15/16/17 names duplicate
    -- the list above and are skipped.
    if GetDifficultyInfo then
        local byDifficultyID = {
            [17] = DIFFICULTY_COLORS["Raid Finder"],
            [3]  = DIFFICULTY_COLORS["Normal"],
            [4]  = DIFFICULTY_COLORS["Normal"],
            [5]  = DIFFICULTY_COLORS["Heroic"],
            [6]  = DIFFICULTY_COLORS["Heroic"],
            [14] = DIFFICULTY_COLORS["Normal"],
            [15] = DIFFICULTY_COLORS["Heroic"],
            [16] = DIFFICULTY_COLORS["Mythic"],
        }
        for difficultyID, color in pairs(byDifficultyID) do
            local localizedName = GetDifficultyInfo(difficultyID)
            if localizedName and localizedName ~= ""
               and not colors[localizedName] then
                colors[localizedName] = color
                order[#order + 1] = localizedName
            end
        end
    end

    -- Longest first, so multi-word names match before any word they contain.
    table.sort(order, function(a, b) return #a > #b end)

    UI._difficultyColorWords = { colors = colors, order = order }
    return UI._difficultyColorWords
end

local function ColorizeDifficulties(text)
    if not text or text == "" then return text end
    local words = UI.GetDifficultyColorWords()
    local function colorizePlain(plainText)
        for _, word in ipairs(words.order) do
            local color = words.colors[word]
            if color then
                -- Frontier patterns act as word boundaries over letters AND
                -- digits, which difficulty names need ("10 Player"). Each is
                -- applied only when that edge is a word character; a
                -- punctuation edge already delimits. Localized names are
                -- escaped so they read as literal text.
                local pattern = word:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
                if word:find("^%w") then pattern = "%f[%w]" .. pattern end
                if word:find("%w$") then pattern = pattern .. "%f[%W]" end
                plainText = plainText:gsub(
                    pattern,
                    ("|c%s%s|r"):format(color, word))
            end
        end
        return plainText
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

-- Wraps ^caret^-marked spans in the orange color code. Unmatched carets are
-- stripped silently rather than producing broken color codes.
local function HighlightNames(text)
    if not text or text == "" then return text end
    text = text:gsub("%^([^%^]+)%^", function(span)
        -- A caret span is a proper noun. Place names have locale entries and
        -- render translated; boss and NPC names usually don't and keep their
        -- source form.
        local localized = (RR.L and RR.L[span]) or span
        -- A name the game records under two forms is stored with both,
        -- separated by a vertical bar, so a routing gate can accept either.
        -- Prose shows one name, so render the first.
        local firstForm = string.match(localized, "^([^|]+)|")
        return OrangeText(firstForm or localized)
    end)
    -- Strip any stragglers (unmatched carets) so they don't render.
    text = text:gsub("%^", "")
    text = ColorizeDifficulties(text)
    return text
end


-- Text matching follows the player's physical location, not the world map's
-- displayed mapID, which can be stale. Map RENDERING does use worldMapID.
local function GetBestMapForStep(step)
    if not step then return nil end
    return C_Map and C_Map.GetBestMapForUnit
        and C_Map.GetBestMapForUnit("player")
end
-- Exposed on the UI namespace so out-of-file callers can use the same
-- map-resolution logic the renderer uses, rather than reimplementing it.
UI.GetBestMapForStep = GetBestMapForStep

-- Per-difficulty pill row: [ LFR 0/8 | N 8/8 | H 0/8 | M 0/8 ]. Green when a
-- difficulty is fully cleared, yellow for the player's current one, gray
-- otherwise -- complete trumps active. Empty string when no kill data.
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

    -- Short label per display bucket. LFR is absent by design -- the pill row
    -- covers Normal and up. 3/4/5/6 are the Wrath sizes, each its own bucket.
    local BUCKET_LABEL = {
        [3] = "10N", [4] = "25N", [5] = "10H", [6] = "25H",
        [14] = "N", [15] = "H", [16] = "M",
    }

    -- Order matches typical Blizzard UI: easiest -> hardest. Built from
    -- the raid's difficulty model so shared-lockout raids show N | H and
    -- independent raids show N | H | M without a per-model branch here.
    local PILLS = {}
    for _, bucket in ipairs(RR:GetDisplayBuckets(raid)) do
        local label = BUCKET_LABEL[bucket]
        if label then
            table.insert(PILLS, { id = bucket, label = label })
        end
    end

    -- Shared lockout: the committed mode's shared-lockout sibling
    -- (Normal/Heroic, or 10/25 on Wrath raids) is locked for the week. Lock glyph marks it (no
    -- recolor; see the idle builder for why color alone won't read here).
    -- Every sibling the shared lockout blocks, not just one: a four-member
    -- group (Wrath sizesHeroic) locks three pills off a single commit.
    local lockedBuckets = {}
    for _, bucket in ipairs(RR:GetLockedOutBuckets(raid, counts) or {}) do
        lockedBuckets[bucket] = true
    end
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
        local count = counts[p.id]
        if count then
            local hex
            if count.total > 0 and count.complete == count.total then
                hex = COMPLETE_HEX
            elseif p.id == activeDiff then
                hex = ACTIVE_HEX
            else
                hex = PENDING_HEX
            end
            local lock = lockedBuckets[p.id] and LOCK_GLYPH or ""
            if p.label then
                table.insert(parts, ("|cff%s%s %d/%d|r%s"):format(
                    hex, p.label, count.complete, count.total, lock))
            else
                -- Flexible with no committed difficulty yet: count only, no
                -- N/H letter (asserting either would be inaccurate).
                table.insert(parts, ("|cff%s%d/%d|r%s"):format(
                    hex, count.complete, count.total, lock))
            end
        end
    end

    if #parts == 0 then return "" end

    local sep = "|cff555555 | |r"
    local bracketOpen = "|cff777777[ |r"
    local text = bracketOpen
        .. table.concat(parts, sep)
        .. "|cff777777 ]|r"
    return text
end

-- Last-rendered travel text, returned verbatim while RR.state.inEncounter so
-- the pane freezes for a fight. Mid-fight platform changes report mapIDs that
-- don't match the pre-pull segment. Cleared on ENCOUNTER_END.
local lastTravelText = nil

-- Last picker-output we logged. Used to suppress heartbeat-tick spam:
-- the picker is called every UI.Update tick (1Hz) and we only want to
-- log when the returned text actually changes. First-call always logs
-- (lastLoggedTravelText starts nil, any returned text differs).
local lastLoggedTravelText = nil

-- Pulse phase for the "[!] view special note" glyph. Cycles 0..15 every 0.1s.
-- Static at full brightness when the section is expanded or there is no
-- soloTip. Cosmetic only.
local encounterPulsePhase = 0
local ENCOUNTER_PULSE_STEPS = 16

-- Cosine-modulated yellow, built once at load so the render is one lookup.
-- Cosine rather than linear stepping is what makes the breathing read as
-- organic; base 0.85 + amplitude 0.15 keeps the glyph visible at every phase.
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

-- {skip} becomes a magenta [Skip] link on an optional boss and plain text
-- otherwise, so a line never advertises a control the player has no way to
-- use. Shared by the travel note and the encounter line. On the UI table
-- rather than a local: this file is at the 200-local ceiling.
function UI.ApplySkipToken(text, step)
    if not text or not text:find("{skip}", 1, true) then return text end
    local word = RR.L["Skip"]
    if step and step.optional then
        -- Bracketed like the header control, so the word reads as the same
        -- button rather than emphasis.
        word = ("|Hrrskip:%d|h|cffF259C7[%s]|r|h"):format(step.bossIndex or 0, word)
    end
    return (text:gsub("{skip}", word))
end

local function BuildTravelText(step)
    local prefix = ("|cff%s%s|r "):format(C_LABEL, RR.L["Traveling:"])
    if not step then return prefix .. "|cff888888" .. RR.L["N/A"] .. "|r" end

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
        local note = RR:ResolveSegNote(seg, "note")
        if note then
            return prefix .. UI.ApplySkipToken(HighlightNames(RR.L[note]), step)
        end
        if step.travelText then
            return prefix
                .. UI.ApplySkipToken(HighlightNames(RR.L[step.travelText]), step)
        end
        return prefix .. "|cff888888" .. RR.L["Open the map and select a section to see directions."] .. "|r"
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
                stripped = RR.Utf8SafeTruncate(stripped, 197) .. "..."
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
-- default "Standard Nuke" tip.
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
    if not boss then return "" end
    if not boss.achievements or #boss.achievements == 0 then
        -- Keep the section visible so every boss pane has the same
        -- shape; the row is clickable and opens the achievements
        -- window like a real achievement link would.
        -- On the label's own line: a one-word answer does not earn a
        -- wrap, and the block reads as a single statement.
        return ("|cff%s%s|r |Hrrachui|h|cff888888%s|r|h"):format(
            C_LABEL, RR.L["Achievements:"], RR.L["N/A"])
    end
    local lines = { ("|cff%s%s|r"):format(C_LABEL, RR.L["Achievements:"]) }

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
        local tag   = ach.meta and (" " .. RR.L["(Meta)"]) or ""

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

            -- Color codes don't nest -- the inner one wins -- so a completed
            -- achievement's own wrapper has to be stripped before re-wrapping
            -- gray. The |H...|h payload survives, so the link stays clickable.
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

-- Returns headerLine, achBlock, specialBlock, clickable, headerPulsing.
-- headerPulsing is true only for the collapsed custom-note form, and the pulse
-- ticker reads it to refresh the header label alone.
--
-- Composition, top to bottom:
--   1. "Boss Encounter:" line -- Standard, the collapsed note link, or the
--      expanded soloTip.
--   2. Achievements block, always rendered.
--   3. Special Loot block, always rendered.
local function BuildEncounterText(step)
    local prefix = ("|cff%s%s|r "):format(C_LABEL, RR.L["Boss Encounter:"])
    if not step then return prefix .. "|cff888888" .. RR.L["N/A"] .. "|r", false end
    local boss = RR:GetBossByIndex(step.bossIndex)

    local hasCustom = HasCustomEncounterNote(boss, step)

    -- Compose the Boss Encounter line based on state.
    local headerLine
    local clickable
    local headerPulsing = false
    if not hasCustom then
        headerLine = prefix .. "|cff888888" .. RR.L["Standard"] .. "|r"
        clickable  = false
    elseif not RR:GetSetting("encounterExpanded") then
        -- Yellow [!] marks a boss with a custom soloTip; the link stays gray
        -- so the glyph does the attention work. Drops away when expanded.
        local pulseColor = ENCOUNTER_PULSE_COLORS[encounterPulsePhase] or "|cffffff00"
        headerLine = prefix .. pulseColor .. "[!]|r |cff888888" .. RR.L["view special note"] .. "|r"
        clickable  = true
        headerPulsing = true
    else
        local tip = RR.L[(boss and boss.soloTip) or step.soloTip or ""]
        tip = UI.ApplySkipToken(HighlightNames(tip), step)
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

    return headerLine, achBlock, specialBlock, clickable, headerPulsing
end

-- Slots that have no transmog value -- excluded from display entirely.
-- Keyed on the authored slot strings from the data files, which are English
-- in every locale: the loot generators write them from the numeric item
-- InventoryType, not from client text.
local TRANSMOG_EXCLUDED_SLOTS = {
    ["Neck"]           = true,
    ["Finger"]         = true,
    ["Trinket"]        = true,
    ["Non-equippable"] = true,
    ["Unknown"]        = true,
}

-- Difficulty display order and labels
-- LFR, then the Wrath sizes (10/25 x Normal/Heroic), then Normal, Heroic,
-- Mythic. The two families never appear on the same item, so only the
-- within-family order shows.
local DIFF_ORDER  = { 17, 3, 4, 5, 6, 14, 15, 16, 24, 33 }
local DIFF_LETTER = {
    [17] = "LFR",
    [3]  = "10N",
    [4]  = "25N",
    [5]  = "10H",
    [6]  = "25H",
    [14] = "N",
    [15] = "H",
    [16] = "M",
    -- Timewalking buckets (24 dungeon, 33 raid). Browser-only: the panel
    -- and idle pill builders keep their own label maps without these, so
    -- no lockout or progress pill ever shows a TW column.
    [24] = "TW",
    [33] = "TW",
}

-- Full names used in the "Current difficulty: <name>" header line. The
-- Wrath size difficulties take the client's own names via
-- GetDifficultyInfo ("10 Player" etc.), already localized on every
-- client.
local DIFF_NAME = {
    [17] = RR.L["LFR"],
    [3]  = (GetDifficultyInfo and GetDifficultyInfo(3)) or "10 Player",
    [4]  = (GetDifficultyInfo and GetDifficultyInfo(4)) or "25 Player",
    [5]  = (GetDifficultyInfo and GetDifficultyInfo(5)) or "10 Player (Heroic)",
    [6]  = (GetDifficultyInfo and GetDifficultyInfo(6)) or "25 Player (Heroic)",
    [14] = RR.L["Normal"],
    [15] = RR.L["Heroic"],
    [16] = RR.L["Mythic"],
}

-- Four-state colors for difficulty dots:
--   COLLECTED -> you have this exact source learned
--   SHARED    -> you have the same appearance from a DIFFERENT item
--                (tier recolor, world drop, etc.)
--   ACTIVE    -> uncollected everywhere, and this is your current difficulty
--   INACTIVE  -> uncollected everywhere, and this is a different difficulty
local DOT_COLLECTED   = "ff00ff00"   -- bright green
local DOT_SHARED      = "ffbf9000"   -- amber / gold
local DOT_ACTIVE      = "ffffffff"   -- white
local DOT_INACTIVE    = "ff555555"   -- dim gray

-- Name color for a row with nothing left to farm. A muted take on
-- COLLECTED, so the row agrees with its own strip. Deliberately NOT gray:
-- gray is INACTIVE's "not collected", and the same tone on a name carried
-- the opposite meaning to the one the legend prints. Lives on the UI table
-- because the file's chunk is at the 200-local ceiling.
UI.NAME_DONE = "ff4d8a4d"   -- muted green

-- Class ID (1-13) -> the uppercase token RAID_CLASS_COLORS and
-- LOCALIZED_CLASS_NAMES_MALE key on, from GetClassInfo's second return.
--
-- Do NOT build this from CLASS_SORT_ORDER. That is a display-order list, not
-- ID-indexed, and using it as a lookup mislabels every tier row.
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

-- Requests an item whose name is not cached yet and repaints the collection
-- views once it lands, at most once per item per session.
UI.twinNameLoadsRequested = {}
function UI.RepaintWhenItemNamed(itemID)
    if not itemID or UI.twinNameLoadsRequested[itemID] then return end
    if not (Item and Item.CreateFromItemID) then return end
    UI.twinNameLoadsRequested[itemID] = true
    local pending = Item:CreateFromItemID(itemID)
    if pending:IsItemEmpty() then return end
    pending:ContinueOnItemLoad(function()
        UI.collectionGeneration = UI.collectionGeneration + 1
        if UI.twinRepaintPending then return end
        UI.twinRepaintPending = true
        C_Timer.After(0.05, function()
            UI.twinRepaintPending = nil
            UI.RefreshTmogWindowIfShown()
            if RR.RefreshAll then RR:RefreshAll() end
        end)
    end)
end

-- True when the appearance is collected via any source. Iterated with `pairs`:
-- GetAllAppearanceSources is not always a contiguous array, and `ipairs` would
-- stop at the first gap. The second result is true when an owned source is
-- a same-named twin of the row's item: Blizzard re-issues legacy drops
-- under new item ids, and owning the twin is owning this row.
local function HasAppearanceViaAnySource(appearanceID, ownName, ownItemID)
    if not appearanceID or not C_TransmogCollection then return false end
    local sourceIDs = C_TransmogCollection.GetAllAppearanceSources(appearanceID)
    if not sourceIDs then return false end
    local owned = false
    for _, srcID in pairs(sourceIDs) do
        if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(srcID) == true then
            owned = true
            if C_TransmogCollection.GetSourceInfo then
                local info = C_TransmogCollection.GetSourceInfo(srcID)
                if ownName and ownName ~= "" then
                    if info and info.name == ownName then
                        return true, true
                    end
                    if info and (not info.name or info.name == "") then
                        UI.RepaintWhenItemNamed(info.itemID)
                    end
                elseif ownItemID then
                    UI.RepaintWhenItemNamed(ownItemID)
                end
            end
        end
    end
    return owned, false
end

-- Account-wide "does the player already own this look", by source: the
-- source's own state counts, and so does any sibling source sharing the
-- appearance. On the UI table for the map overlay's collected-rare filter.
function UI.IsSourceLookCollected(sourceID)
    if HasSource(sourceID) then return true end
    local info = C_TransmogCollection
        and C_TransmogCollection.GetAppearanceInfoBySource
        and C_TransmogCollection.GetAppearanceInfoBySource(sourceID)
    return HasAppearanceViaAnySource(info and info.appearanceID)
end

-- Returns the appearance ID (visual ID) for an item by its itemID.
-- Collapses to the Normal-difficulty appearance, so callers wanting a
-- specific difficulty's look want GetAppearanceIDForSource instead. Used as
-- the fallback when a per-source lookup returns nil.
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

-- "collected" (this exact source), "shared" (the appearance via another
-- source), or "missing".
--
-- Tries GetSourceInfo(sourceID) FIRST so each per-difficulty dot checks its
-- OWN appearance -- tier variants share one itemID, and the itemID path would
-- light every dot the moment Normal was learned. Falls back to the itemID path
-- when GetSourceInfo returns nil.
local function CollectionStateForSource(sourceID, itemID)
    if not sourceID then return "missing" end
    if HasSource(sourceID) then return "collected" end
    local appearanceID = GetAppearanceIDForSource(sourceID)
                      or GetAppearanceIDForItem(itemID)
    if appearanceID then
        local ownInfo = C_TransmogCollection.GetSourceInfo
            and C_TransmogCollection.GetSourceInfo(sourceID)
        local owned, viaTwin = HasAppearanceViaAnySource(appearanceID,
            ownInfo and ownInfo.name, ownInfo and ownInfo.itemID or itemID)
        if viaTwin then return "collected" end
        if owned then return "shared" end
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

-- Exposed on RR so the diagnostic commands share the UI's render-time logic
-- rather than reimplementing and drifting from it.
--
-- Wrath size pairs and the label a folded pair prints. A row carrying both
-- difficulties of a pair that resolve to one appearance says the same thing
-- twice, so it folds to the bare size. Wrath-only.
UI.WRATH_SIZE_PAIRS = {
    { normal = 3, heroic = 5, label = "10" },
    { normal = 4, heroic = 6, label = "25" },
}

-- True when the folded pill anchored at anchorDiffID stands for
-- activeDiff -- i.e. activeDiff is the heroic half that the fold absorbed.
-- The anchor itself is handled by the plain `diffID == activeDiff` test.
function UI.FoldAbsorbsDifficulty(item, anchorDiffID, activeDiff)
    if not activeDiff then return false end
    for _, pair in ipairs(UI.WRATH_SIZE_PAIRS) do
        if pair.normal == anchorDiffID then
            return pair.heroic == activeDiff
        end
    end
    return false
end

-- { [diffID] = label } for the difficulties whose label changes, plus the set
-- the fold absorbs. Only folds when both difficulties are present AND resolve
-- to one appearance, so recolor pairs keep their own labels. Mixed labels on a
-- partly-folded row are correct.
function UI.FoldedSizeLabels(item)
    if not item or not item.sources then return nil, nil end
    local labels, skip
    for _, pair in ipairs(UI.WRATH_SIZE_PAIRS) do
        local normalSource = item.sources[pair.normal]
        local heroicSource = item.sources[pair.heroic]
        if normalSource and heroicSource then
            local foldable = (normalSource == heroicSource)
            if not foldable then
                local normalAppearance = GetAppearanceIDForSource(normalSource)
                local heroicAppearance = GetAppearanceIDForSource(heroicSource)
                -- Cold cache (nil) must NOT fold: an unresolved pair would
                -- collapse two genuinely different looks into one pill. The
                -- next refresh after the cache warms folds it correctly.
                foldable = (normalAppearance ~= nil)
                    and (normalAppearance == heroicAppearance)
            end
            if foldable then
                labels = labels or {}
                skip   = skip or {}
                labels[pair.normal] = pair.label
                skip[pair.heroic]   = true
            end
        end
    end
    return labels, skip
end

RR.CollectionStateForSource = CollectionStateForSource
RR.FallbackStateForItem     = FallbackStateForItem

-- "binary" (all sources are one appearance) or "perdiff" (one appearance per
-- difficulty). Nil when the item has no sources.
--
-- Binary is expressed two ways: one sourceID cloned across difficulty keys, or
-- distinct sourceIDs resolving to the same visualID. Falls through to perdiff
-- on a cold cache and reclassifies once it warms.
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

    if bucketCount >= 2 then
        if uniqueCount == 1 then
            return "binary"
        end
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

-- The state of a binary item, folded across every source keeping the strongest
-- result: collected > shared > missing. Shared by the browser's binary row and
-- the main-panel summary counter so they cannot disagree.
function RR.BinaryFoldedState(item)
    if not item.sources then
        return FallbackStateForItem(item.id)
    end
    local best = "missing"
    for _, s in pairs(item.sources) do
        local st = CollectionStateForSource(s, item.id)
        if st == "collected" then
            return "collected"
        elseif st == "shared" then
            best = "shared"
        end
    end
    return best
end

-- Folded state of a row's opposite-faction twin (`item.mirror`): its own
-- appearance, owned by its own item, folded across its buckets the same way
-- a binary row folds.
function RR.MirrorFoldedState(item)
    local mirror = item.mirror
    if not mirror or not mirror.sources then return "missing" end
    local best = "missing"
    for _, s in pairs(mirror.sources) do
        local st = CollectionStateForSource(s, mirror.id)
        if st == "collected" then
            return "collected"
        elseif st == "shared" then
            best = "shared"
        end
    end
    return best
end

-- True when nothing on this row is left to farm: every populated bucket is in
-- the collected state. Shared does not count. A binary item folds instead,
-- since owning any one source collects its single appearance.
function RR.ItemFullyCollected(item)
    -- A vendor upgrade is a second appearance on the same row, so the row
    -- is only done once it is collected too.
    if item.upgrade and item.upgrade.source
       and CollectionStateForSource(item.upgrade.source, item.id) ~= "collected" then
        return false
    end
    -- The other faction's twin is likewise its own appearance on the row.
    if item.mirror and RR.MirrorFoldedState(item) ~= "collected" then
        return false
    end
    if ItemShape(item) == "binary" then
        return RR.BinaryFoldedState(item) == "collected"
    end
    if not item.sources then
        return FallbackStateForItem(item.id) == "collected"
    end
    for _, s in pairs(item.sources) do
        if CollectionStateForSource(s, item.id) ~= "collected" then
            return false
        end
    end
    return true
end

RR.ItemShape        = ItemShape

-------------------------------------------------------------------------------
-- Special Loot: mount / pet / toy / decor collection state
--
-- Non-equippable collectibles that don't participate in transmog, carried on
-- each boss as `specialLoot = { { id, kind, name, ... }, ... }`. State is a
-- boolean, with no per-difficulty columns.
--
-- Housing ("decor") calls are all defensive: the C_HousingCatalog APIs landed
-- in 11.2.7, and the branch silently no-ops on earlier clients.
-------------------------------------------------------------------------------

-- Kind labels and colors for the "(Mount)" / "(Pet)" / "(Toy)" / "(Decor)"
-- tag in each row. Chosen to visually distinguish the four kinds without
-- clashing with class colors or achievement yellow.
local SPECIAL_KIND_LABEL = {
    mount      = RR.L["Mount"],
    pet        = RR.L["Pet"],
    toy        = RR.L["Toy"],
    decor      = RR.L["Decor"],
    manuscript = RR.L["Manuscript"],
    illusion   = RR.L["Illusion"],
    musicroll  = RR.L["Music Roll"],
}
local SPECIAL_KIND_COLOR = {
    mount      = "ff8080ff",   -- light blue
    pet        = "ffff80ff",   -- light magenta
    toy        = "ffffcc66",   -- light amber
    decor      = "ffd4a373",   -- warm cream/tan (evokes housing/home)
    manuscript = "ff7fffd4",   -- aquamarine (evokes dragonriding sky/scale)
    illusion   = "ffc8a2ff",   -- pale violet (evokes arcane weapon-enchant glow)
    musicroll  = "ffff9e80",   -- warm coral (evokes a warm jukebox glow)
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

    elseif item.kind == "manuscript" or item.kind == "musicroll" then
        -- A consumable unlock item is gone once used, so the durable check
        -- is the hidden quest flag it sets. Per-character by design. Prefer
        -- the namespaced C_QuestLog form, falling back to the global.
        if not item.questID then return "missing" end
        local fn = (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted)
                   or IsQuestFlaggedCompleted
        if not fn or not item.questID then return "missing" end
        return fn(item.questID) and "collected" or "missing"

    elseif item.kind == "illusion" then
        -- Weapon-enchant illusions are tracked by sourceID (not itemID).
        -- Iterate C_TransmogCollection.GetIllusions() and match by source.
        if not item.sourceID then return "missing" end
        if not C_TransmogCollection or not C_TransmogCollection.GetIllusions then
            return "missing"
        end
        local list = C_TransmogCollection.GetIllusions()
        if type(list) ~= "table" then return "missing" end
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

        local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(
            1, decorID, true)
        if not info then return "missing" end

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

-- The Special Loot section for a boss, or nil to emit no header. Rows are
-- "* <ItemLink> (Mount)", colored by collection state, falling back to a
-- plain name on a cold GetItemInfo cache.
--
-- Assigns to the forward-declared local rather than declaring a new one, so
-- BuildEncounterText can close over the name.
BuildSpecialLootSection = function(boss)
    if not boss or not boss.specialLoot or #boss.specialLoot == 0 then
        return nil
    end

    local lines = { ("|cff%s%s|r"):format(C_LABEL, RR.L["Special Loot:"]) }
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
                local count = C_Item.GetItemCount(ing.id, false) or 0
                local has   = count > 0
                ingredientHeld[idx] = has
                if has then held = held + 1 end
            end

            -- "Ready to trade" shares the partial glyph with "in progress":
            -- both mean work remains. Only owning the mount flips the row
            -- green. The text suffix separates the two partial sub-states.
            local parenSuffix
            local stateColor, stateGlyph
            if held == total then
                stateColor, stateGlyph = SPECIAL_PARTIAL,     SPECIAL_GLYPH_PARTIAL
                parenSuffix = (RR.L["Mount -- %d/%d necks, ready to trade!"]):format(held, total)
            elseif held > 0 then
                stateColor, stateGlyph = SPECIAL_PARTIAL,     SPECIAL_GLYPH_PARTIAL
                parenSuffix = (RR.L["Mount -- %d/%d necks in bags"]):format(held, total)
            else
                stateColor, stateGlyph = SPECIAL_UNCOLLECTED, SPECIAL_GLYPH_UNCOLLECTED
                parenSuffix = (RR.L["Mount -- %d/%d necks in bags"]):format(held, total)
            end

            local kindColor  = SPECIAL_KIND_COLOR[item.kind] or "ffaaaaaa"
            local _, itemLink = C_Item.GetItemInfo(item.id)
            local display    = itemLink or item.name or (RR.L["Item "]..tostring(item.id))

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
                local _, ingLink = C_Item.GetItemInfo(ing.id)
                local ingDisplay = ingLink or ing.name or (RR.L["Item "]..tostring(ing.id))
                local ingSuffix  = has and RR.L["in bags"] or RR.L["not in bags"]
                table.insert(lines,
                    ("    |cff777777[ |r|c%s%s|r|cff777777 ]|r %s |cffaaaaaa(%s)|r"):format(
                        ingColor, ingGlyph, ingDisplay, ingSuffix))
            end

            -- Shown only once every ingredient is in bags, which is when the
            -- player can act on the location.
            if item.barter.at and held == total then
                table.insert(lines,
                    ("    |cffaaaaaa" .. RR.L["Trade at %s."] .. "|r"):format(item.barter.at))
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
            local _, itemLink = C_Item.GetItemInfo(item.id)
            local display = itemLink or item.name or (RR.L["Item "]..tostring(item.id))

            local kindLabel = SPECIAL_KIND_LABEL[item.kind] or item.kind or "?"
            local kindColor = SPECIAL_KIND_COLOR[item.kind] or "ffaaaaaa"

            -- "(Pet)", or "(Pet, Mythic only)" with the restriction in brand
            -- pink -- epic purple is the item link's own color and blurs into
            -- the name. Spliced inside the kindColor wrapper so the parens
            -- keep the kind's color.
            local kindInner = kindLabel
            if item.mythicOnly then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["Mythic only"] .. "|r|c" .. kindColor
            elseif item.lfrOnly then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["LFR only"] .. "|r|c" .. kindColor
            elseif item.normalHeroicOnly then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["Normal/Heroic only"] .. "|r|c" .. kindColor
            elseif item.heroicOnly then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["Heroic only"] .. "|r|c" .. kindColor
            elseif item.heroic25Only then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["25 Player Heroic only"] .. "|r|c" .. kindColor
            elseif item.size10Only then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["10 Player only"] .. "|r|c" .. kindColor
            elseif item.size25Only then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["25 Player only"] .. "|r|c" .. kindColor
            elseif item.hardModeOnly then
                kindInner = kindLabel .. ", |r|cffF259C7" .. RR.L["Hard mode only"] .. "|r|c" .. kindColor
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

-- Visibility filter for the transmog popup. Two independent class fields gate
-- a row: `classes` for tier TOKEN rows (hidden for non-matching classes unless
-- "show all" is on), and `equipClasses` for armor-class restrictions, filtered
-- the same way but driving no tier label.
--
-- The active filter is a class ID, 0 for all classes, or nil for whatever
-- the Default Transmog Filter setting says. Deliberately RUNTIME state, never
-- saved: it is a temporary view, and persisting it left every browser on
-- every character stuck on whatever class was picked once.
local function ActiveClassFilter()
    local _, _, playerClassID = UnitClass("player")
    local sel = browserState.classFilter
    if sel == 0 then return nil end          -- explicit "all classes"
    if type(sel) == "number" and sel >= 1 and sel <= 13 then
        return sel
    end
    -- Unset / invalid: the Default Transmog Filter setting decides.
    if RR:GetSetting("tmogDefaultClassFilter", "mine") == "all" then
        return nil
    end
    return playerClassID
end

-- Which class a row should label itself with when its `classes` list serves
-- more than one: the class being viewed if the filter names one of them,
-- else the played class when the row serves it, else the row's first entry.
-- Taking the first unconditionally made Vault of Archavon's and Baradin
-- Hold's three-class cloth and mail sets read as whichever class happened
-- to sort lowest, regardless of the dropdown.
function UI.PreferredRowClassID(classList, playerClassID)
    if not classList or #classList == 0 then return nil end
    if #classList == 1 then return classList[1] end
    local activeFilter = ActiveClassFilter()
    for _, classID in ipairs(classList) do
        if classID == activeFilter then return classID end
    end
    for _, classID in ipairs(classList) do
        if classID == playerClassID then return classID end
    end
    return classList[1]
end

-- The player's own class ID. The main-panel summary counts against this
-- rather than ActiveClassFilter so it always reflects what THIS character
-- can collect in the raid they're standing in -- independent of whatever
-- class the browser's dropdown is currently previewing.
function RR.PlayerClassID()
    local _, _, classID = UnitClass("player")
    return classID
end

-- True when the class being viewed wears NOTHING among a list's
-- equipClasses rows. Appearance learning ignores class restriction
-- (live-verified in Vault of Archavon), so for such a class the wear filter
-- would blank a list of appearances it can genuinely collect -- Baradin
-- Hold is all equipClasses, and a Monk filtering to Monk would see an
-- empty raid. The walks compute this once per list and ItemIsForPlayer
-- reads it, letting every row through instead.
UI._equipGateExempt = false
function UI.EquipGateExemptFor(lootList, filterClass)
    if not filterClass or not lootList then return false end
    local sawGated = false
    for _, item in ipairs(lootList) do
        if item.equipClasses then
            sawGated = true
            for _, classID in ipairs(item.equipClasses) do
                if classID == filterClass then return false end
            end
        end
    end
    return sawGated
end

local function ItemIsForPlayer(item, classOverride)
    local gate = item.classes
    if not gate and not UI._equipGateExempt then
        gate = item.equipClasses
    end
    if not gate then return true end
    local filterClass = classOverride or ActiveClassFilter()
    if not filterClass then return true end   -- "all classes" selected
    for _, cid in ipairs(gate) do
        if cid == filterClass then return true end
    end
    return false
end

-- Is an item a display candidate for the transmog popup? classOverride forces
-- a class gate, used by the main-panel summary so it always reflects the
-- player's own class. includeOtherFaction admits opposite-faction rows -- the
-- browser passes it, the summary counters do not.
local function ItemIsTransmogCandidate(item, classOverride, includeOtherFaction)
    -- Special-loot entries (pets, mounts, toys, illusions, manuscripts,
    -- decor) carry a `kind` and belong in the boss specialLoot list, which
    -- the core UI surfaces separately. They have no equip slot and no
    -- per-difficulty appearance sources, so they must never appear in the
    -- transmog browser regardless of which array they were authored into.
    if item.kind then return false end
    -- Timewalking-only drops are not walk-in farmable, which is the whole
    -- premise; they neither display nor count.
    if item.timewalkingOnly then return false end
    if TRANSMOG_EXCLUDED_SLOTS[item.slot] then return false end
    -- Faction-locked rows (Trial of the Crusader drops per-faction item
    -- variants from the same encounter) can't be looted by this character,
    -- but the game grants the opposite faction's appearance when its mirror
    -- drops, so they are collectible and worth tracking. The browser shows
    -- them in their own block; everywhere else they stay hidden.
    if not includeOtherFaction
        and item.faction and item.faction ~= UnitFactionGroup("player") then
        return false
    end
    if not ItemIsForPlayer(item, classOverride) then return false end
    return true
end

-- True for a row that belongs to the other faction: lootable only on a
-- character of that faction, collectible here only through the grant its
-- mirror carries.
local function ItemIsOtherFaction(item)
    return item.faction ~= nil and item.faction ~= UnitFactionGroup("player")
end

-- The source a row is reachable through at a difficulty. A Timewalking
-- reprint that shares the walk-in look rides the row as twSource: it makes
-- the row count in a Timewalking run without earning a pill of its own.
function UI.SourceAt(item, diffID)
    if not item or not item.sources then return nil end
    local src = item.sources[diffID]
    if src == nil and diffID == 24 then src = item.twSource end
    return src
end

-- The "active" (current in-game) difficulty, folded to its display
-- bucket so it lines up with the 14/15/16/17 keys the source data uses.
-- Under a size-folding model a live size variant (e.g. 25-player Heroic)
-- folds to its Heroic bucket; under the independent model the id is returned
-- unchanged. Used to choose the white vs gray dot color in the browser.
local function ActiveDifficulty()
    -- "Current difficulty" only means something for the instance the player
    -- is standing in. While the browser builds another instance's detail,
    -- this returns nil and every white current-difficulty highlight falls
    -- through to gray (all consumers already guard nil).
    if UI._suppressActiveDifficulty then return nil end
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
    -- Buckets come from the raid's difficulty model, not a fixed list. An era
    -- on 3/4/5/6 matches nothing in the modern set, so every row fell through
    -- to the item-level check below, which cannot see one difficulty being
    -- owned through another item and reports the row plain "collected".
    local summaryBuckets = RR:GetDisplayBuckets(RR.currentRaid)
        or DIFFS_FOR_SUMMARY
    for _, diffID in ipairs(summaryBuckets) do
        local src = item.sources[diffID]
        if src then
            hasAnyBucket = true
            local collectionState = CollectionStateForSource(src, item.id)
            if collectionState == "missing" then
                hasMissing = true
            elseif collectionState == "shared" then
                hasShared = true
            end
        end
    end
    -- The vendor-upgrade appearance counts toward the row's summary, so a
    -- row with the drop collected but the upgrade missing still reports
    -- as incomplete to the section counters.
    if item.upgrade and item.upgrade.source then
        hasAnyBucket = true
        local upgradeState = CollectionStateForSource(item.upgrade.source, item.id)
        if upgradeState == "missing" then
            hasMissing = true
        elseif upgradeState == "shared" then
            hasShared = true
        end
    end
    -- The opposite-faction twin counts the same way.
    if item.mirror then
        hasAnyBucket = true
        local mirrorState = RR.MirrorFoldedState(item)
        if mirrorState == "missing" then
            hasMissing = true
        elseif mirrorState == "shared" then
            hasShared = true
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

-- Row-level counterpart to the difficulty pills, using their own colors so a
-- name can never disagree with the strip beside it:
--   done here                    -> NAME_DONE (a muted COLLECTED)
--   owned through another item   -> SHARED    (gold)
--   something to collect now     -> ACTIVE    (white)
--   what is left drops elsewhere -> INACTIVE  (gray)
-- A row with no per-difficulty data reads as available rather than dimming
-- something we cannot place. Lives on the UI table; the chunk is at the
-- 200-local ceiling.
function UI.RowNameColor(item)
    if RR.ItemFullyCollected and RR.ItemFullyCollected(item) then
        return UI.NAME_DONE
    end
    -- Nothing left to farm anywhere: the look is already owned through a
    -- different item. Gold, matching its own pills and the legend's "via
    -- another item". Gray would claim it drops at some other difficulty and
    -- white would send the player to collect it, and both are false.
    if ItemSummaryState(item) == "shared" then return DOT_SHARED end
    if not item.sources then return DOT_ACTIVE end
    local activeDiff = ActiveDifficulty()
    if activeDiff then
        local src = UI.SourceAt(item, activeDiff)
        if src and CollectionStateForSource(src, item.id) == "missing" then
            return DOT_ACTIVE
        end
        -- A vendor upgrade is a second appearance on the row, obtainable at
        -- its own difficulty.
        local upgrade = item.upgrade
        if upgrade and upgrade.source and upgrade.difficulty == activeDiff
           and CollectionStateForSource(upgrade.source, item.id) == "missing" then
            return DOT_ACTIVE
        end
        -- So is the opposite-faction twin, at its own difficulties. Without
        -- this the row reads gray whenever the near half is already owned
        -- through another item -- claiming nothing is available here while
        -- the twin beside it is still missing and still dropping.
        local mirror = item.mirror
        if mirror and mirror.sources and mirror.sources[activeDiff]
           and CollectionStateForSource(mirror.sources[activeDiff], mirror.id)
               == "missing" then
            return DOT_ACTIVE
        end
    end
    return DOT_INACTIVE
end

-------------------------------------------------------------------------------
-- Summary builder (main panel)
-------------------------------------------------------------------------------

-- Count items where the specified difficulty bucket is missing/shared.
-- Returns (needed, shared, total). Only counts items that HAVE a source
-- for the given difficulty; items with no source for that difficulty
-- (some raids have fewer variants) are skipped entirely, not counted.
-- Every sourceID carried on the raid's own boss rows. A trash row whose
-- sources all live on a boss row too is CROSS-LISTED -- shown in both
-- places, counted once, on the boss side. SourceID is the key on purpose:
-- appearance-level folding across rows would collapse genuinely distinct
-- farmables (the SoO gloves lesson).
function UI.BossCarriedSourceSet(raid)
    local carriedSources = {}
    for _, boss in ipairs((raid and raid.bosses) or {}) do
        for _, item in ipairs(boss.loot or {}) do
            for _, sourceID in pairs(item.sources or {}) do
                carriedSources[sourceID] = true
            end
        end
    end
    return carriedSources
end

-- True when the trash row's every source is boss-carried, so the counters
-- skip it and the boss row keeps the tally.
function UI.TrashRowIsBossCarried(item, carriedSources)
    if not item.sources then return false end
    local sawSource = false
    for _, sourceID in pairs(item.sources) do
        sawSource = true
        if not carriedSources[sourceID] then return false end
    end
    return sawSource
end

local function CountBossLootForDifficulty(boss, diffID, classOverride)
    if not boss or not boss.loot or #boss.loot == 0 then return nil end
    if not diffID then return nil end
    UI._equipGateExempt = UI.EquipGateExemptFor(boss.loot,
        classOverride or ActiveClassFilter())
    local needed, shared, total = 0, 0, 0
    for _, item in ipairs(boss.loot) do
        if ItemIsTransmogCandidate(item, classOverride) then
            local shape = ItemShape(item)
            if shape == "binary" then
                -- Binary item: one appearance across all its difficulty
                -- sources. Count it once on this difficulty line only if it
                -- is reachable here (has a source at diffID), classified by
                -- the folded per-item state rather than this difficulty's
                -- source in isolation -- so an item collected via Heroic
                -- reads collected under Normal too, matching the browser.
                if UI.SourceAt(item, diffID) then
                    total = total + 1
                    local foldedState = RR.BinaryFoldedState(item)
                    if foldedState == "missing" then
                        needed = needed + 1
                    elseif foldedState == "shared" then
                        shared = shared + 1
                    end
                    -- The opposite-faction twin is a second appearance
                    -- collectible from the same drop, so it counts on the
                    -- difficulty lines it is reachable at.
                    if item.mirror and item.mirror.sources
                       and item.mirror.sources[diffID] then
                        total = total + 1
                        local mirrorState = RR.MirrorFoldedState(item)
                        if mirrorState == "missing" then
                            needed = needed + 1
                        elseif mirrorState == "shared" then
                            shared = shared + 1
                        end
                    end
                end
            else
                -- Perdiff (distinct appearance per difficulty) or single
                -- source: evaluate this difficulty's source on its own, so
                -- each difficulty's recolor is counted under its own line.
                local src = UI.SourceAt(item, diffID)
                if src then
                    total = total + 1
                    local collectionState = CollectionStateForSource(src, item.id)
                    if collectionState == "missing" then
                        needed = needed + 1
                    elseif collectionState == "shared" then
                        shared = shared + 1
                    end
                elseif not item.sources then
                    total = total + 1
                    local fallbackState = FallbackStateForItem(item.id)
                    if fallbackState == "missing" then
                        needed = needed + 1
                    elseif fallbackState == "shared" then
                        shared = shared + 1
                    end
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
local function CountBossLootAcrossDifficulties(boss, diffIDs, classOverride)
    if not boss or not boss.loot or #boss.loot == 0 then return nil end
    UI._equipGateExempt = UI.EquipGateExemptFor(boss.loot,
        classOverride or ActiveClassFilter())
    local needed, shared, total = 0, 0, 0
    for _, item in ipairs(boss.loot) do
        if ItemIsTransmogCandidate(item, classOverride) then
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
                        local collectionState = CollectionStateForSource(src, item.id)
                        if collectionState == "missing" then
                            hasMissing = true
                        elseif collectionState == "shared" then
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
                local fallbackState = FallbackStateForItem(item.id)
                if fallbackState == "missing" then
                    needed = needed + 1
                elseif fallbackState == "shared" then
                    shared = shared + 1
                end
            end
        end
    end
    if total == 0 then return nil end
    return needed, shared, total
end

-- Aggregate needed / shared / total across a boss's loot, for the dropdown
-- "(have/total)" badges.
--
-- With an active difficulty this is the slice for that difficulty alone,
-- matching the panel summary. Without one, it rolls up across difficulties:
-- missing if any bucket is missing, else shared if any is shared.
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
    UI._equipGateExempt = UI.EquipGateExemptFor(boss.loot, ActiveClassFilter())
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

-- Appearances from ONE boss this character has yet to collect, across
-- every difficulty the row carries. Exposed on RR so the exit note can
-- say how much is still owed at a boss the route does not visit.
--
-- Nil when the boss offers this character nothing countable at all -- the
-- class filter or an equip gate leaving no candidate. That is not the same
-- as owning every appearance, and a caller must not report it as such.
function RR:BossAppearancesStillNeeded(boss)
    return (CountBossLoot(boss))
end


-- Formats (needed, shared) as "Missing (N) Shared (N)", green at 0 and orange
-- above. Both zero returns a single green "Complete" token instead.
local function FormatStatsFragment(needed, shared)
    if needed == 0 and shared == 0 then
        return "|cff00ff00" .. RR.L["Complete"] .. "|r"
    end
    local missingColor = (needed == 0) and "ff00ff00" or "ffff9900"
    local sharedColor  = (shared == 0) and "ff00ff00" or "ffff9900"
    return (RR.L["Missing"] .. " |c%s(%d)|r " .. RR.L["Shared"] .. " |c%s(%d)|r"):format(
        missingColor, needed, sharedColor, shared)
end

-- Main-panel transmog summary: header plus per-difficulty Missing/Shared
-- counts, collapsing to "All appearances collected!" when every difficulty is
-- done.
--
-- The generation counter is bumped whenever the collection changes; the cached
-- summary keys on it so a new appearance invalidates without recounting every
-- panel refresh.
UI.collectionGeneration = 0
do
    local collectionWatcher = CreateFrame("Frame")
    collectionWatcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
    collectionWatcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")
    collectionWatcher:RegisterEvent("TRANSMOG_COLLECTION_UPDATED")
    collectionWatcher:SetScript("OnEvent", function()
        UI.collectionGeneration = UI.collectionGeneration + 1
    end)
end

function UI.BuildTransmogSummaryUncached(step)
    if not step then return nil end
    local boss = RR:GetBossByIndex(step.bossIndex)
    if not boss then return nil end

    -- The browse hint rides the header itself so the affordance is visible
    -- without reading to the end of the count lines.
    local clickHnt = "|cff888888" .. RR.L["[click to browse]"] .. "|r"
    local header   = ("|cff%s%s|r %s"):format(
        C_LABEL, RR.L["Transmog Needed:"], clickHnt)
    local activeID = ActiveDifficulty()

    -- A boss that drops nothing with an appearance KEEPS its section and
    -- says so, rather than disappearing and leaving the panel to close up
    -- around a slot the player expects to find. No browse hint on this
    -- one: there is nothing on the other side of the click.
    if not boss.loot or #boss.loot == 0 then
        return ("|cff%s%s|r %s"):format(C_LABEL, RR.L["Transmog Needed:"],
            "|cff9d9d9d" .. RR.L["None available"] .. "|r")
    end

    -- Buckets to summarize come from the raid's difficulty model, not a
    -- fixed list, so era-specific bucket IDs (Cataclysm's 3/4/5/6) are
    -- counted instead of silently skipped.
    local summaryBuckets = RR:GetDisplayBuckets(RR.currentRaid)
        or DIFFS_FOR_SUMMARY

    -- A single-bucket raid makes the Current-vs-Other split redundant, so the
    -- summary collapses to one rollup line. Per-item differences still show in
    -- the loot rows.
    if #summaryBuckets <= 1 then
        local n, s, t = CountBossLootAcrossDifficulties(boss, DIFFS_FOR_SUMMARY, RR.PlayerClassID())
        if not t then return nil end
        if n == 0 and s == 0 then
            return header .. "\n|cffF259C7" .. RR.L["All appearances collected!"] .. "|r"
        end
        return header .. "\n- " .. FormatStatsFragment(n, s)
    end

    -- Compute the current-difficulty counts (if active difficulty known).
    local curNeeded, curShared, curTotal
    if activeID then
        curNeeded, curShared, curTotal = CountBossLootForDifficulty(boss, activeID, RR.PlayerClassID())
    end

    -- Compute the other-difficulties counts (rollup of the non-active).
    local otherIDs = {}
    for _, diffID in ipairs(summaryBuckets) do
        if diffID ~= activeID then
            table.insert(otherIDs, diffID)
        end
    end
    local othNeeded, othShared, othTotal = CountBossLootAcrossDifficulties(boss, otherIDs, RR.PlayerClassID())

    -- Edge case: active difficulty not set / not tracked. Fall back to
    -- a cross-all-difficulties single-line rollup.
    if not activeID or not curTotal then
        local n, s, t = CountBossLootAcrossDifficulties(boss, summaryBuckets, RR.PlayerClassID())
        if not t then return nil end
        if n == 0 and s == 0 then
            return header .. "\n|cffF259C7" .. RR.L["All appearances collected!"] .. "|r"
        end
        return header .. "\n- " .. FormatStatsFragment(n, s)
    end

    -- Both counts computed. Is everything done across the board?
    local curDone = (curNeeded == 0 and curShared == 0)
    local othDone = (not othTotal) or (othNeeded == 0 and othShared == 0)
    if curDone and othDone then
        return header .. "\n|cffF259C7" .. RR.L["All appearances collected!"] .. "|r"
    end

    -- Header + two dash lines, matching the Achievements section format.
    -- Each line renders either Missing/Shared counts or "Complete".
    -- Click hint always on the last (Other difficulties) line.
    local diffName = DIFF_LETTER[activeID] or DIFF_NAME[activeID]
        or tostring(activeID)
    local line1 = ("- %s (|cff%s%s|r): %s"):format(
        RR.L["Current"], C_PINK_HEX, diffName, FormatStatsFragment(curNeeded, curShared))
    local othFrag = othTotal
        and FormatStatsFragment(othNeeded, othShared)
        or "|cff00ff00Complete|r"
    local line2 = ("- %s: %s"):format(RR.L["Other difficulties"], othFrag)
    return header .. "\n" .. line1 .. "\n" .. line2
end

-- Cached front for the summary. Counting is pure: it depends only on
-- the boss, the shown difficulty, the player's class (fixed), and
-- collection state -- so the result is reused until any of those
-- change. Boss and difficulty are in the key; collection changes bump
-- UI.collectionGeneration; nil results cache like any other.
local function BuildTransmogSummary(step)
    if not step then return nil end
    local cacheKey = tostring(RR.state.loadedRaidKey or "?")
        .. ":" .. tostring(step.bossIndex or "?")
        .. ":" .. tostring(ActiveDifficulty() or "?")
        .. ":" .. tostring(UI.collectionGeneration)
    local cache = UI.tmogSummaryCache
    if cache and cache.key == cacheKey then
        return cache.text
    end
    local summaryText = UI.BuildTransmogSummaryUncached(step)
    UI.tmogSummaryCache = { key = cacheKey, text = summaryText }
    return summaryText
end

-------------------------------------------------------------------------------
-- Per-difficulty dot row builder
-------------------------------------------------------------------------------

-- Per-item loot row builder. Binary rows render one bracketed state;
-- per-difficulty rows render the `[ LFR | N | H | M ]` strip. The literal pipe
-- is escaped `||`, since WoW reads `|r` as a color reset.
-------------------------------------------------------------------------------

-- Binary-indicator glyphs, reusing the ReadyCheck textures the rest of the
-- addon uses. Shared takes a grayscale check tinted gold, since the native
-- green one can't shift color.
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

-- True for a row whose sources all live in the 10/25-player size
-- difficulties (3/4/5/6) and span more than one of them: a single
-- appearance dropping on several sizes. On the UI table rather than a
-- file-level local (the chunk is at Lua's local ceiling).
-- A row carrying a Timewalking bucket must render the per-difficulty
-- letter strip even when its sources fold to one appearance (they nearly
-- always do -- TW drops are reprints), or the TW pill never appears: the
-- binary shape would swallow it. The Dreambinder fold, deliberately
-- bypassed.
function UI.HasTimewalkingBucket(item)
    return item and item.sources
        and (item.sources[24] ~= nil or item.sources[33] ~= nil) or false
end

function UI.IsMergedSizeDifficultyRow(item)
    if not item or not item.sources then return false end
    local bucketCount = 0
    for diffID in pairs(item.sources) do
        if diffID ~= 3 and diffID ~= 4 and diffID ~= 5 and diffID ~= 6 then
            return false
        end
        bucketCount = bucketCount + 1
    end
    return bucketCount >= 2
end

-- Renders a binary-shape row: "[ <glyph> ]" bracket with the glyph colored
-- per state. Single sourceID drives a single CollectionStateForSource call.
-- Falls back to FallbackStateForItem when sources is nil/empty so an entry
-- missing that field renders safely instead of crashing BinaryStateRendering.
local function BuildBinaryRow(item)
    local debugEnabled = RR:GetSetting("debug")
    -- One appearance across all difficulty sources. State is folded across
    -- every source (strongest wins: collected > shared > missing) via the
    -- shared helper the summary counter also uses, so the row and the
    -- main-panel count can never disagree on a binary item.
    local state = RR.BinaryFoldedState(item)

    -- One sourceID cloned across every bucket means the strip letters can
    -- never differ in any way -- not even by collection path, since there is
    -- only one source to collect. Trash rows are the shipped case. The strip
    -- would be pure repetition, so these render the plain binary glyph below.
    local clonedSingleSource
    do
        local uniqueSources = {}
        local uniqueCount = 0
        for _, src in pairs(item.sources or {}) do
            if not uniqueSources[src] then
                uniqueSources[src] = true
                uniqueCount = uniqueCount + 1
            end
        end
        clonedSingleSource = (uniqueCount == 1)
    end

    -- Merged size-difficulty rows render as a letter strip like any other
    -- multi-difficulty row, so the row itself says which sizes drop it.
    -- Every letter takes the folded state: owning any one size's source
    -- collects the appearance everywhere, so the strip never splits colors.
    -- When nothing is collected, the current difficulty's letter highlights
    -- white and the rest dim, matching the per-difficulty strips.
    if UI.IsMergedSizeDifficultyRow(item) and not clonedSingleSource then
        local activeDiff = ActiveDifficulty()
        -- Fold N/H pairs that share one appearance down to the bare size,
        -- so "10N || 10H" (two pills that can never differ) reads "10".
        local foldedLabels, foldedSkip = UI.FoldedSizeLabels(item)
        local inner = {}
        for _, diffID in ipairs(DIFF_ORDER) do
            if item.sources[diffID] and not (foldedSkip and foldedSkip[diffID]) then
                local color
                if state == "collected" then
                    color = DOT_COLLECTED
                elseif state == "shared" then
                    color = DOT_SHARED
                elseif diffID == activeDiff
                    or (foldedLabels and foldedLabels[diffID]
                        and UI.FoldAbsorbsDifficulty(item, diffID, activeDiff)) then
                    -- A folded pill highlights white when EITHER of its
                    -- difficulties is the current one, since it stands for
                    -- both.
                    color = DOT_ACTIVE
                else
                    color = DOT_INACTIVE
                end
                local label = (foldedLabels and foldedLabels[diffID])
                    or DIFF_LETTER[diffID]
                table.insert(inner, ("|c%s%s|r"):format(color, label))
            end
        end
        if debugEnabled then
            RR._dotTrace = RR._dotTrace or {}
            RR._dotTrace[item.id] = ("item=%s (id=%d) shape=binary(size-merged) state=%s"):format(
                item.name or "?", item.id or 0, state)
        end
        local sep = "|cff555555 || |r"
        return "|cff777777[ |r" .. table.concat(inner, sep) .. "|cff777777 ]|r"
    end

    local color, glyph = BinaryStateRendering(state)

    if debugEnabled then
        RR._dotTrace = RR._dotTrace or {}
        RR._dotTrace[item.id] = ("item=%s (id=%d) shape=binary state=%s -> %s"):format(
            item.name or "?", item.id or 0, state, color)
    end

    return ("|cff777777[ |r|c%s%s|r|cff777777 ]|r"):format(color, glyph)
end

-- The "[ LFR | N | H | M ]" strip, each letter colored by its own
-- difficulty's state. The separator is authored "||" and renders as one pipe.
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

    -- A perdiff row can still carry ONE folded pair alongside a genuine
    -- recolor pair (10N/10H sharing a look while 25N/25H are recolors).
    -- Fold only the sharing pair; the recolor pills keep their own labels
    -- and their own per-source states.
    local foldedLabels, foldedSkip = UI.FoldedSizeLabels(item)
    for _, diffID in ipairs(DIFF_ORDER) do
        local src = item.sources and item.sources[diffID]
        if foldedSkip and foldedSkip[diffID] then src = nil end
        -- Skip empty buckets. WoD-era split-loot-table raids have items
        -- with only 1 bucket ({[17]} for LFR pool) or 3 buckets ({[14],
        -- [15], [16]} for N/H/M pool); rendering iterates only over
        -- the diffs the item actually drops at.
        if src then
            local letter = (foldedLabels and foldedLabels[diffID])
                or DIFF_LETTER[diffID]
            local color

            local state = CollectionStateForSource(src, item.id)

            if state == "collected" then
                color = DOT_COLLECTED
            elseif state == "shared" then
                color = DOT_SHARED
            elseif diffID == activeDiff
                or (foldedLabels and foldedLabels[diffID]
                    and UI.FoldAbsorbsDifficulty(item, diffID, activeDiff)) then
                color = DOT_ACTIVE
            else
                color = DOT_INACTIVE
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
                    diffID, letter, tostring(src), state, color, detail))
            end

            table.insert(inner, ("|c%s%s|r"):format(color, letter))
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

-- Texture escapes ignore |c coloring, so chain dots are tinted through the
-- extended markup's RGB arguments -- the same route the gold
-- shared-checkmark takes. Lives on the UI table rather than as a file-level
-- local: UI.lua's main chunk sits at Lua 5.1's 200-local ceiling.
UI.UPGRADE_PILL_RGB = {
    [DOT_COLLECTED] = "0:255:0",
    [DOT_SHARED]    = "191:144:0",
    [DOT_ACTIVE]    = "255:255:255",
    [DOT_INACTIVE]  = "136:136:136",
}
-- Spec icons for a tier piece, so a player can see which loot spec the
-- token will actually hand them -- a piece serving one spec needs a
-- respec before the token is consumed, one serving all of them does not.
--
-- Resolved live rather than from db2: ItemSpecOverride covers well under
-- a fifth of the tier items, and the game fills the rest from ItemSpec's
-- stat rules. The API answers only for the played class and returns nil
-- otherwise, which is why the icons simply do not render when the browser
-- is pointed at somebody else's tier.
function UI.SpecIconsForItem(itemID)
    if not itemID or not C_Item or not C_Item.GetItemSpecInfo then return nil end
    if not GetSpecializationInfoByID then return nil end
    local specs = C_Item.GetItemSpecInfo(itemID)
    if not specs or #specs == 0 then return nil end
    table.sort(specs)   -- ascending specID is the in-game spec order
    local icons = {}
    for _, specID in ipairs(specs) do
        local icon = select(4, GetSpecializationInfoByID(specID))
        if icon then
            table.insert(icons, ("|T%s:12:12|t"):format(icon))
        end
    end
    if #icons == 0 then return nil end
    return table.concat(icons)
end

-- Progression dot, for rows whose appearances form an upgrade chain. Same
-- vertex-tinted texture the skips window uses; a typographic bullet is a
-- missing glyph in the pixel fonts.
function UI.ProgressDotGlyph(color)
    return ("|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\StatusDot:10:10:0:0:64:64:0:64:0:64:%s|t")
        :format(UI.UPGRADE_PILL_RGB[color] or UI.UPGRADE_PILL_RGB[DOT_INACTIVE])
end
-- The faction-pair caption's words: the two faction names, the viewing
-- player's own first. The dots and the '=' are placed by the layout pass,
-- which is the only place the bracket and separator widths of a real row's
-- indicator can be measured. Returns nil when the client cannot name them.
function UI.FactionPairLegendText()
    local faction  = UnitFactionGroup and UnitFactionGroup("player")
    local nearName = (faction == "Horde") and FACTION_HORDE or FACTION_ALLIANCE
    local farName  = (faction == "Horde") and FACTION_ALLIANCE or FACTION_HORDE
    if not (nearName and farName) then return nil end
    return ("|cff888888" .. RR.L["%s & %s"] .. "|r"):format(nearName, farName)
end

-- Maps a source's collection state to its pill color. `activeFor` is the
-- difficulty at which the step becomes obtainable, so an out-of-reach step
-- reads gray rather than white.
function UI.ChainStepColor(state, activeFor)
    if state == "collected" then return DOT_COLLECTED end
    if state == "shared"    then return DOT_SHARED end
    if activeFor == nil or ActiveDifficulty() == activeFor then
        return DOT_ACTIVE
    end
    return DOT_INACTIVE
end
function UI.BuildUpgradeRow(item)
    local upgrade = item.upgrade

    -- Rows carrying `baseLook` render their whole chain as dots, one per
    -- step, left to right. The base dot is INFORMATIONAL ONLY -- it is
    -- never counted, because for most pieces that appearance is already
    -- a row of its own elsewhere, and `shared` does not satisfy a counter,
    -- so counting it would leave the row permanently incomplete.
    if item.baseLook and item.baseLook.source then
        local steps = {
            UI.ChainStepColor(
                CollectionStateForSource(item.baseLook.source, item.id), nil),
            UI.ChainStepColor(RR.BinaryFoldedState(item), nil),
            UI.ChainStepColor(
                CollectionStateForSource(upgrade.source, item.id),
                upgrade.difficulty),
        }
        local dots = {}
        for _, color in ipairs(steps) do
            table.insert(dots, UI.ProgressDotGlyph(color))
        end
        local chainSep = "|cff555555 || |r"
        return "|cff777777[ |r" .. table.concat(dots, chainSep) .. "|cff777777 ]|r"
    end
    -- Two-step chain, same dots as everywhere else: the drop folded to one
    -- state, then the vendor upgrade with its own collection state.
    -- The drop dot is white only while the difficulty being run drops
    -- it, gray otherwise -- the same rule a faction-pair half follows.
    local steps = {
        UI.MirrorHalfDotColor(
            UI.MirrorHalfState(RR.BinaryFoldedState(item), item.sources)),
        UI.ChainStepColor(
            CollectionStateForSource(upgrade.source, item.id),
            upgrade.difficulty),
    }
    local dots = {}
    for _, color in ipairs(steps) do
        table.insert(dots, UI.ProgressDotGlyph(color))
    end
    local sep = "|cff555555 || |r"
    return "|cff777777[ |r" .. table.concat(dots, sep) .. "|cff777777 ]|r"
end

-- A faction pair renders as two dots, the viewing player's faction first,
-- matching the order the composed name prints the two versions in.
-- Which of the four states one half of a faction pair is in: its own folded
-- collection state, plus -- when nothing is collected -- whether that half
-- actually drops at the difficulty being run. Single source for the half's
-- dot AND its name, so the two can never disagree.
function UI.MirrorHalfState(foldedState, sources)
    if foldedState == "collected" or foldedState == "shared" then
        return foldedState
    end
    local activeDiff = ActiveDifficulty()
    if activeDiff and sources and sources[activeDiff] then return "active" end
    return "inactive"
end

-- Dot color for a half's state.
function UI.MirrorHalfDotColor(halfState)
    if halfState == "collected" then return DOT_COLLECTED end
    if halfState == "shared"    then return DOT_SHARED end
    if halfState == "active"    then return DOT_ACTIVE end
    return DOT_INACTIVE
end

-- Name color for a half's state. Same four states, but a finished half
-- takes the muted done-green a finished row's name takes rather than the
-- dot's full-brightness green.
function UI.MirrorHalfNameColor(halfState)
    if halfState == "collected" then return UI.NAME_DONE end
    return UI.MirrorHalfDotColor(halfState)
end

function UI.BuildMirrorRow(item)
    local primaryDot = UI.ProgressDotGlyph(UI.MirrorHalfDotColor(
        UI.MirrorHalfState(RR.BinaryFoldedState(item), item.sources)))
    local mirrorDot = UI.ProgressDotGlyph(UI.MirrorHalfDotColor(
        UI.MirrorHalfState(RR.MirrorFoldedState(item),
            item.mirror and item.mirror.sources)))
    local first, second = primaryDot, mirrorDot
    if UnitFactionGroup and UnitFactionGroup("player") == "Horde" then
        first, second = mirrorDot, primaryDot
    end
    local sep = "|cff555555 || |r"
    return "|cff777777[ |r" .. first .. sep .. second .. "|cff777777 ]|r"
end

-- Splits a faction pair's two names into the words they share and the words
-- that differ, so each half can be colored separately. Returns
-- (prefix, leadFirst, leadSecond, suffix). The two names differ only in some
-- leading or trailing words depending on locale ("Kel'Thuzad's Gloves of
-- Conquest" leads in English; French shares the front instead). leadFirst is
-- nil when the names are identical, in which case prefix holds the whole
-- name; prefix or suffix is "" when nothing is shared on that side.
function UI.SplitPairedName(firstName, secondName)
    if firstName == secondName then return firstName, nil, nil, "" end
    local firstWords, secondWords = {}, {}
    for word in firstName:gmatch("%S+") do table.insert(firstWords, word) end
    for word in secondName:gmatch("%S+") do table.insert(secondWords, word) end
    local sharedTail = 0
    while sharedTail < #firstWords and sharedTail < #secondWords
        and firstWords[#firstWords - sharedTail]
            == secondWords[#secondWords - sharedTail] do
        sharedTail = sharedTail + 1
    end
    if sharedTail > 0 then
        local leadA = table.concat(firstWords, " ", 1, #firstWords - sharedTail)
        local leadB = table.concat(secondWords, " ", 1, #secondWords - sharedTail)
        if leadA ~= "" and leadB ~= "" then
            return "", leadA, leadB,
                table.concat(firstWords, " ", #firstWords - sharedTail + 1)
        end
    end
    local sharedHead = 0
    while sharedHead < #firstWords and sharedHead < #secondWords
        and firstWords[sharedHead + 1] == secondWords[sharedHead + 1] do
        sharedHead = sharedHead + 1
    end
    if sharedHead > 0 then
        local tailA = table.concat(firstWords, " ", sharedHead + 1)
        local tailB = table.concat(secondWords, " ", sharedHead + 1)
        if tailA ~= "" and tailB ~= "" then
            return table.concat(firstWords, " ", 1, sharedHead),
                tailA, tailB, ""
        end
    end
    return "", firstName, secondName, ""
end

-- A faction pair's name, each half in its own half's color and the shared
-- words in the row's summary color, so every colored element on the row
-- agrees with the dot above it. Returns a fully colored string: color codes
-- do not nest, so the caller must not wrap this again.
function UI.BuildPairedNameText(nearName, farName, nearColor, farColor,
                                sharedColor)
    local prefix, leadNear, leadFar, suffix =
        UI.SplitPairedName(nearName, farName)
    if not leadNear then
        return ("|c%s%s|r"):format(sharedColor, prefix)
    end
    local parts = {}
    if prefix ~= "" then
        table.insert(parts, ("|c%s%s|r"):format(sharedColor, prefix))
    end
    table.insert(parts, ("|c%s%s|r"):format(nearColor, leadNear))
    table.insert(parts, ("|c%s/|r"):format(sharedColor))
    table.insert(parts, ("|c%s%s|r"):format(farColor, leadFar))
    if suffix ~= "" then
        table.insert(parts, ("|c%s%s|r"):format(sharedColor, suffix))
    end
    return table.concat(parts, " ")
end

-- Shape-aware dispatcher. Picks the renderer based on the item's sourceID
-- uniqueness count. BuildDotRow is retained as the public name so any
-- existing callers continue to work.
local function BuildDotRow(item)
    if item.upgrade and item.upgrade.source then
        return UI.BuildUpgradeRow(item)
    elseif item.mirror then
        return UI.BuildMirrorRow(item)
    elseif ItemShape(item) == "binary"
        and not UI.HasTimewalkingBucket(item) then
        -- TW reprints share their base row's appearance, so shape folds
        -- them to binary -- which would swallow the TW pill. Same bypass
        -- as the partition; the per-diff renderer draws [ N | TW ].
        return BuildBinaryRow(item)
    else
        return BuildPerDiffRow(item)
    end
end

-------------------------------------------------------------------------------
-- List dividers
-------------------------------------------------------------------------------

UI.DIVIDER_LINE_H  = 6     -- the asset's drawn height
UI.DIVIDER_GEM_SIZE = 14
UI.DIVIDER_SUBGEM_SIZE = 10  -- sub-divider gems, so nesting reads at a glance
UI.DIVIDER_GAP     = 8     -- clearance between a label, its gems and the lines
UI.DIVIDER_ABOVE   = 8     -- cushion over the divider row
UI.DIVIDER_BELOW   = 4     -- cushion under it

-- Horizontal insets inside the transmog popup. The TEXT column is
-- asymmetric on purpose -- the right side reserves scrollbar width while the
-- left takes the ordinary margin -- so a rule that simply spans its parent
-- column lands off the frame's center. Every horizontal rule therefore
-- insets by RULE from BOTH edges and centers on the frame itself.
UI.TMOG_MARGIN_L     = 22  -- body and legend text, left edge
UI.TMOG_LEGEND_PAD_R = 14  -- legend text, right edge
UI.TMOG_RULE_INSET   = 28  -- both edges, every horizontal rule (= scrollbar width)
-- The faction-pair caption spaces its two dots with a spacer texture where
-- a real row has the text " | ". Measured widths get the two within a pixel
-- or two, but an inline texture and a run of glyphs do not carry the same
-- side bearing, and nothing measurable accounts for the rest. Eyeballed
-- against the rows above at font size 12; nudge it if a very different
-- body size ever drifts them apart again.
UI.PAIRKEY_DOT_NUDGE = 2

-- One divider: two line halves, two gems and a label. The titled form sets
-- a gem either side of the words; the plain form centers one gem on an
-- unbroken line. The halves stay off the pixel grid -- a snapped line this
-- thin can round away to nothing at fractional scales.
function UI.MakeListDivider(parent)
    local divider = {}
    local function MakeLine()
        local line = parent:CreateTexture(nil, "ARTWORK")
        line:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\divider-line")
        line:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 0.55)
        line:SetHeight(UI.DIVIDER_LINE_H)
        if line.SetTexelSnappingBias then
            line:SetTexelSnappingBias(0)
            line:SetSnapToPixelGrid(false)
        end
        line:Hide()
        return line
    end
    divider.left  = MakeLine()
    divider.right = MakeLine()

    local function MakeGem()
        local gem = parent:CreateTexture(nil, "OVERLAY")
        gem:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\divider-gem")
        gem:SetSize(UI.DIVIDER_GEM_SIZE, UI.DIVIDER_GEM_SIZE)
        if gem.SetTexelSnappingBias then
            gem:SetTexelSnappingBias(0)
            gem:SetSnapToPixelGrid(false)
        end
        gem:Hide()
        return gem
    end
    divider.gemLeft  = MakeGem()
    divider.gemRight = MakeGem()

    divider.label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    divider.label:SetJustifyH("LEFT")
    divider.label:SetJustifyV("TOP")
    divider.label:SetWordWrap(false)
    divider.label:Hide()
    return divider
end

-- Places one divider across `width` with its line centered on `rowH`.
-- Returns the total height consumed, cushions included. An empty label
-- yields the gem form: one unbroken line with the gem centered on it.
-- `leftX` shifts the rule right of the content column's own left edge, so it
-- can inset equally from both frame edges even though the column does not.
function UI.PlaceListDivider(divider, anchor, topY, leftX, width, rowH,
                             labelText, labelW, subtle)
    local y      = topY - UI.DIVIDER_ABOVE
    divider.left:SetAlpha(1)
    divider.right:SetAlpha(1)
    local lineY  = y - math.floor((rowH - UI.DIVIDER_LINE_H) / 2)
    -- Gems stand taller than the line, so they hang evenly above and below it.
    local gemY   = lineY
        + math.floor((UI.DIVIDER_GEM_SIZE - UI.DIVIDER_LINE_H) / 2)
    divider.left:ClearAllPoints()
    divider.left:SetPoint("TOPLEFT", anchor, "TOPLEFT", leftX, lineY)

    if labelText and labelText ~= "" then
        -- Gem, words, gem centers as one cluster inside the span; the line
        -- halves run from it out to either end.
        local gemW      = UI.DIVIDER_GEM_SIZE
        local clusterW  = (gemW + UI.DIVIDER_GAP) * 2 + labelW
        local clusterX  = leftX + math.floor((width - clusterW) / 2)
        local labelX    = clusterX + gemW + UI.DIVIDER_GAP
        local rightGemX = labelX + labelW + UI.DIVIDER_GAP
        local rightX    = clusterX + clusterW + UI.DIVIDER_GAP

        divider.left:SetWidth(math.max(1, clusterX - UI.DIVIDER_GAP - leftX))
        divider.left:Show()
        divider.right:ClearAllPoints()
        divider.right:SetPoint("TOPLEFT", anchor, "TOPLEFT", rightX, lineY)
        divider.right:SetWidth(math.max(1, leftX + width - rightX))
        divider.right:Show()

        divider.gemLeft:ClearAllPoints()
        divider.gemLeft:SetPoint("TOPLEFT", anchor, "TOPLEFT", clusterX, gemY)
        divider.gemLeft:Show()
        divider.gemRight:ClearAllPoints()
        divider.gemRight:SetPoint("TOPLEFT", anchor, "TOPLEFT", rightGemX, gemY)
        divider.gemRight:Show()

        divider.label:ClearAllPoints()
        divider.label:SetPoint("TOPLEFT", anchor, "TOPLEFT", labelX, y)
        divider.label:SetText(labelText)
        divider.label:Show()
    elseif subtle then
        -- A quiet rule: a short centered line, dimmed, and no gem. It marks
        -- a break without reading as another titled section.
        local shortW = math.max(1, math.floor(width * 0.45))
        divider.left:ClearAllPoints()
        divider.left:SetPoint("TOPLEFT", anchor, "TOPLEFT",
            leftX + math.floor((width - shortW) / 2), lineY)
        divider.left:SetWidth(shortW)
        divider.left:SetAlpha(0.35)
        divider.left:Show()
        divider.right:Hide()
        divider.label:Hide()
        divider.gemLeft:Hide()
        divider.gemRight:Hide()
    else
        divider.left:SetWidth(math.max(1, width))
        divider.left:Show()
        divider.right:Hide()
        divider.label:Hide()
        divider.gemRight:Hide()
        divider.gemLeft:ClearAllPoints()
        divider.gemLeft:SetPoint("CENTER", divider.left, "CENTER", 0, 0)
        divider.gemLeft:Show()
    end
    if subtle then
        -- Height actually consumed: the drop to the rule, the rule itself,
        -- then the cushion under it. Returning only the two cushions left
        -- the next element sitting on top of the line.
        return UI.DIVIDER_ABOVE
            + math.floor((rowH - UI.DIVIDER_LINE_H) / 2)
            + UI.DIVIDER_LINE_H + UI.DIVIDER_BELOW
    end
    return UI.DIVIDER_ABOVE + rowH + UI.DIVIDER_BELOW
end

function UI.HideListDivider(divider)
    divider.left:Hide()
    divider.right:Hide()
    divider.gemLeft:Hide()
    divider.gemRight:Hide()
    divider.label:Hide()
end

-------------------------------------------------------------------------------
-- Full-detail popup builder
-------------------------------------------------------------------------------

-- Token families: the class IDs each token serves plus its slot type, for
-- weapon-token rows that don't flow through the armor-tier pipeline. Keyed on
-- the first word of the token's localized name.
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

-- Builds the vendor hint line for the Tmog popup: Castle Nathria's
-- covenant-keyed Sanctum weapon vendor, or a raid's static
-- token-redemption vendor (tokenVendors). Returns (text, raid, covID,
-- vendorInfo, vendorKind); covID is nil for token vendors. text is nil
-- when the selected boss drops no redeemable tokens. The Flight button
-- anchors to this FontString.
-- An item's clickable link, or a purple-bracketed name when the client has
-- not cached it yet. On the UI table rather than a local: UI.lua's main
-- chunk sits at Lua 5.1's 200-local ceiling.
function UI.ItemLinkFor(itemID)
    if not itemID then return "" end
    local _, itemLink = C_Item.GetItemInfo(itemID)
    if itemLink then return itemLink end
    return ("|cffa335ee[%s]|r"):format(C_Item.GetItemInfo(itemID) or RR.L["(item)"])
end

local function BuildSanctumLine(raid, boss)
    -- Legacy-wing hint. Belongs to the INSTANCE rather than a boss, so it
    -- resolves ahead of the boss guard below. Its block emits the sanctum
    -- marker row, which is what places this line and its travel plane.
    --
    -- The destination rides its own last line rather than sitting inline
    -- where the prose names it: the paragraph wraps, and a wrapped
    -- FontString cannot report where any line but the last one ends, so an
    -- inline plane would land at the unwrapped width -- far off the right
    -- edge. Same shape the omnitoken hint uses for the same reason.
    if raid and raid.legacyNote and raid.legacyNote.text then
        local note = raid.legacyNote
        -- HighlightNames so ^caret^ spans render as names rather than
        -- showing their literal carets, the same as any authored note.
        local body = RR.L[note.text]
        if note.itemID then
            body = body:gsub("{item}", UI.ItemLinkFor(note.itemID))
        end
        if note.itemID2 then
            body = body:gsub("{item2}", UI.ItemLinkFor(note.itemID2))
        end
        if note.emphasis then
            local phrase = RR.L[note.emphasis]
            body = body:gsub(phrase:gsub("%p", "%%%0"),
                ("|cff%s%s|r|cff9d9d9d"):format(C_LABEL, phrase), 1)
        end
        body = HighlightNames(body)
        local travel = note.travel
        if not (travel and travel.mapID and travel.x and travel.y) then
            return ("|cff9d9d9d%s|r"):format(body), raid, nil, nil, "legacy", nil
        end
        local placeLine = (RR.L["|cff888888  -> |r|cffffffff%s|r|cff888888 -- |r|cffffffff%s|r"])
            :format(RR.L[travel.vendorName or ""], RR.L[travel.zoneSub or ""])
        return ("|cff9d9d9d%s|r\n%s"):format(body, placeLine), raid, nil, nil,
            "legacy", {
                buttonOnLastLine = true,
                buttonLineText   = placeLine,
                travel = { mapID = travel.mapID, x = travel.x, y = travel.y,
                           vendorName = travel.vendorName, zoneSub = travel.zoneSub },
            }
    end
    if not raid or not boss then return nil end

    -- Omnitokens: a boss drop that buys ANY tier slot rather than one
    -- piece. The appearances it can become are already tracked on their own
    -- rows, so the hint says the token exists, says it is not tracked, and
    -- points at whoever takes it. The prose wraps, so the destination sits
    -- on its own last line and the travel plane anchors there.
    if boss.omniToken then
        local omni = boss.omniToken
        local spot = RR:ResolveFactionBlock(omni)
        if spot then
            local body = RR.L[omni.text or ""]
            if omni.itemID then
                body = body:gsub("{item}", UI.ItemLinkFor(omni.itemID))
            end
            -- {tokens} names a FAMILY rather than one item, so it takes the
            -- epic color a link would carry without pretending to be one.
            -- Color codes do not nest: close the body's gray, run the phrase,
            -- then reopen gray for the rest of the sentence.
            if omni.tokenLabel then
                body = body:gsub("{tokens}", "|r|cffa335ee"
                    .. RR.L[omni.tokenLabel] .. "|r|cff9d9d9d")
            end
            local placeLine = (RR.L["|cff888888  -> |r|cffffffff%s|r|cff888888 -- |r|cffffffff%s|r"])
                :format(RR.L[spot.vendorName or ""],
                        RR.L[spot.zoneSub or spot.zoneMain or ""])
            local hintInfo
            if spot.mapID and spot.x and spot.y then
                hintInfo = {
                    buttonOnLastLine = true,
                    buttonLineText   = placeLine,
                    travel = { mapID = spot.mapID, x = spot.x, y = spot.y,
                               vendorName = spot.vendorName,
                               zoneSub = spot.zoneSub },
                }
            end
            return ("|cff9d9d9d%s|r\n%s"):format(body, placeLine),
                raid, nil, spot, "omni", hintInfo
        end
    end

    -- Static token-redemption vendors (Icecrown Citadel, Firelands,
    -- Siege of Orgrimmar). `bosses` limits the hint to the bosses that
    -- drop the turn-in item; absent means every boss.
    if raid.tokenVendors then
        local showForBoss = true
        if raid.tokenVendors.bosses then
            showForBoss = false
            for _, gatedIndex in ipairs(raid.tokenVendors.bosses) do
                if gatedIndex == boss.index then
                    showForBoss = true
                    break
                end
            end
        end
        local vendorInfo = showForBoss and RR:GetTokenVendor(raid)
        -- Static list: one bullet per spot, no per-character resolution.
        -- Used where a single vendor keeps several spawns.
        if vendorInfo and vendorInfo.locations then
            local rowFormat = RR.L["|cff888888     * %s: |r|cffffffff%s|r"]
            local subFormat = RR.L["|cff888888        * |r%s"]
            local lines = { ("|cff888888  -> %s|r"):format(
                RR.L[vendorInfo.heading or "Redeem Tier Tokens at:"]) }
            -- A spot with sub-bullets needs the heading set off from them,
            -- or the whole block reads as one undifferentiated list.
            if vendorInfo.locations[1] and vendorInfo.locations[1].byClass then
                table.insert(lines, "")
            end
            local hintInfo
            local emittedAnySpot = false
            local lastSpotHeadingLine = 0
            for _, spot in ipairs(vendorInfo.locations) do
                -- A spot may name the bosses whose tokens it takes, so a
                -- boss dropping only one kind of token shows only that
                -- half. Without it the hint contradicts the tier rows above
                -- it, which are already split the same way.
                local spotHere = true
                if spot.bosses then
                    spotHere = false
                    for _, gatedIndex in ipairs(spot.bosses) do
                        if gatedIndex == boss.index then
                            spotHere = true
                            break
                        end
                    end
                end
                if spotHere then
                local detail = RR.L[spot.vendorName or ""]
                -- A spot whose token and materials differ per class carries
                -- a byClass table. It follows the class dropdown for the
                -- same reason the ICC hint does -- the rows above it are
                -- class-filtered, so a hint naming another class's
                -- materials would contradict them.
                local classSpot = spot
                if spot.byClass then
                    local _, _, playedID = UnitClass("player")
                    classSpot = spot.byClass[ActiveClassFilter() or playedID or 0]
                end
                -- A class with no entry has no set from THIS spot, so the
                -- spot drops out rather than the whole hint: a sibling spot
                -- may be open to every class, as the weapon turn-ins are.
                -- When every spot filters out, the bare-heading guard below
                -- still hides the hint entirely.
                if classSpot then
                -- {item} takes a real item link. The link carries its own
                -- quality color, and color codes do not nest, so close the
                -- row's white before it and reopen after -- otherwise the
                -- link's trailing |r ends the row color early and whatever
                -- follows renders in the default tone.
                if classSpot.itemID then
                    local _, itemLink = C_Item.GetItemInfo(classSpot.itemID)
                    if not itemLink then
                        local fallbackName = C_Item.GetItemInfo(classSpot.itemID)
                            or RR.L["(item)"]
                        itemLink = ("|cffa335ee[%s]|r"):format(fallbackName)
                    end
                    detail = detail:gsub("{item}",
                        "|r" .. itemLink .. "|cffffffff")
                end
                -- A spot that follows a block of sub-bullets gets a blank
                -- line, or that block's materials run straight into the next
                -- spot's heading and the two read as one list. Plain
                -- one-line spots stack without the gap.
                if emittedAnySpot and #lines > lastSpotHeadingLine then
                    table.insert(lines, "")
                end
                emittedAnySpot = true
                table.insert(lines, rowFormat:format(
                    RR.L[spot.place or ""], detail))
                lastSpotHeadingLine = #lines
                -- Anchor the travel button to the SPOT'S OWN row, captured
                -- before any sub-bullets push it up the list -- measuring
                -- after them would hang the plane off the last material.
                local spotLineIndex, spotLineText = #lines, lines[#lines]
                -- A spot carrying a cost breakdown lists it as indented
                -- sub-bullets under its own line: what reputation gates it,
                -- the token, and the materials. Item links localize
                -- themselves and carry their own quality color, so the
                -- sub-rows stay uncolored around them.
                -- The faction differs per raid, so the label is built around
                -- the id the data carries. The client localizes the faction
                -- name itself, leaving only the frame around it to translate.
                if classSpot.repStanding and vendorInfo.repFactionID then
                    local factionData = C_Reputation
                        and C_Reputation.GetFactionDataByID
                        and C_Reputation.GetFactionDataByID(vendorInfo.repFactionID)
                    local factionName = (factionData and factionData.name)
                        or (GetFactionInfoByID
                            and GetFactionInfoByID(vendorInfo.repFactionID))
                    -- Standing indices are Blizzard's own: 4 Neutral through
                    -- 8 Exalted. Both halves of the line come from the client,
                    -- so only the frame around them carries a locale entry.
                    local standingLabel =
                        _G["FACTION_STANDING_LABEL" .. classSpot.repStanding]
                    if factionName and standingLabel then
                        table.insert(lines, subFormat:format(
                            (RR.L["%s Reputation"]):format(factionName)
                            .. " = " .. standingLabel))
                    end
                end
                if classSpot.token then
                    -- Every AQ20 turn-in takes exactly one token, so the
                    -- count is fixed rather than data-driven; it is written
                    -- out anyway to match the idol and scarab rows.
                    table.insert(lines, subFormat:format(
                        ("1x %s"):format(UI.ItemLinkFor(classSpot.token))))
                end
                -- Materials, one sub-bullet per entry. An entry is a list of
                -- { itemID, count } pairs; two in one entry share a line
                -- joined with " + ", so a turn-in's paired scarab stacks read
                -- as one cost rather than two separate ones.
                if classSpot.mats then
                    for _, matLine in ipairs(classSpot.mats) do
                        local matParts = {}
                        for _, mat in ipairs(matLine) do
                            table.insert(matParts, ("%dx %s"):format(
                                mat[2], UI.ItemLinkFor(mat[1])))
                        end
                        if matParts[1] then
                            table.insert(lines, subFormat:format(
                                table.concat(matParts, " + ")))
                        end
                    end
                end
                -- The plane rides whichever spot a waypoint can reach.
                if spot.mapID and spot.x and spot.y and not hintInfo then
                    hintInfo = {
                        buttonLineIndex = spotLineIndex - 1,   -- 0-based
                        buttonLineText  = spotLineText,
                        travel = { mapID = spot.mapID, x = spot.x, y = spot.y,
                                   vendorName = spot.vendorName,
                                   zoneSub = spot.zoneSub },
                    }
                end
                end
                end
            end
            -- Every spot filtered out leaves a bare heading, which reads as
            -- a broken hint rather than an absent one.
            if #lines <= 2 then return nil end
            return table.concat(lines, "\n"), raid, nil, vendorInfo, "token",
                hintInfo
        end
        if vendorInfo and vendorInfo.classVendors then
            -- Raids whose tokens redeem in more than one place list each
            -- spot on its own line under a shared heading, naming the
            -- vendor that serves THIS character: by class inside the
            -- raid, by armor type at the city merchants.
            -- Armor subclass each class wears: 1 Cloth, 2 Leather,
            -- 3 Mail, 4 Plate. Built here rather than at file scope --
            -- UI.lua's main chunk sits at Lua 5.1's 200-local ceiling.
            local ARMOR_SUBCLASS_BY_CLASS = {
                [1] = 4, [2] = 4, [3] = 3, [4] = 2, [5] = 1, [6] = 4,
                [7] = 3, [8] = 1, [9] = 1, [10] = 2, [11] = 2, [12] = 2,
                [13] = 3,
            }
            -- The hint follows the class dropdown, like every other
            -- class-gated element in the window -- otherwise the rows and
            -- the vendor under them can name different classes. "All
            -- classes" has no single vendor, so it falls back to the class
            -- being played (which is also the dropdown's own default).
            local playedName, playedToken, playedID = UnitClass("player")
            local classID = ActiveClassFilter() or playedID
            local classToken = CLASS_ID_TO_TOKEN[classID] or playedToken
            local className = (classID == playedID) and playedName
                              or ClassNameForID(classID)
            -- The class name carries its own class color, the same read
            -- the tier tags use.
            if className and classToken and RAID_CLASS_COLORS
               and RAID_CLASS_COLORS[classToken]
               and RAID_CLASS_COLORS[classToken].colorStr then
                className = ("|c%s%s|r"):format(
                    RAID_CLASS_COLORS[classToken].colorStr, className)
            end
            local classVendor = vendorInfo.classVendors[classID or 0]
            if type(classVendor) == "table" then
                local faction = UnitFactionGroup and UnitFactionGroup("player")
                classVendor = (faction == "Alliance")
                    and classVendor.alliance or classVendor.horde
            end
            -- Classes that postdate the raid's tier have no vendor and no
            -- tier to redeem, so the hint stays hidden for them.
            if not classVendor then return nil end

            local armorSubclass = ARMOR_SUBCLASS_BY_CLASS[classID or 0]
            local armorEntry = armorSubclass
                and vendorInfo.armorVendors[armorSubclass]
            local armorVendor = armorEntry and armorEntry.vendorName
            local armorLabel = armorSubclass and GetItemSubClassInfo
                and GetItemSubClassInfo(LE_ITEM_CLASS_ARMOR or 4, armorSubclass)

            -- The trailing field arrives pre-colored (class color for the
            -- class name, white for the armor type), so the format leaves
            -- it alone -- color codes do not nest.
            local rowFormat = RR.L["|cff888888     * %s: |r|cffffffff%s|r|cff888888 for |r%s"]
            local lines = { ("|cff888888  -> %s|r"):format(
                RR.L[vendorInfo.heading or "Redeem Tier Tokens at:"]) }
            table.insert(lines, rowFormat:format(
                RR.L[vendorInfo.classVendorPlace or ""],
                RR.L[classVendor], className or ""))
            local hintInfo
            if armorVendor and armorLabel then
                table.insert(lines, rowFormat:format(
                    RR.L[vendorInfo.armorVendorPlace or ""],
                    RR.L[armorVendor],
                    ("|cffffffff%s|r"):format(armorLabel)))
                -- The travel button rides the city line -- the in-raid
                -- vendor cannot be routed to (see insideRaid).
                if armorEntry.mapID and armorEntry.x and armorEntry.y then
                    hintInfo = {
                        buttonLineIndex = #lines - 1,   -- 0-based
                        buttonLineText  = lines[#lines],
                        travel = { mapID = armorEntry.mapID,
                                   x = armorEntry.x, y = armorEntry.y,
                                   vendorName = armorVendor,
                                   zoneSub = armorEntry.zoneSub },
                    }
                end
            end
            return table.concat(lines, "\n"), raid, nil, vendorInfo, "token",
                hintInfo
        end
        if vendorInfo and vendorInfo.vendorName then
            local text
            if vendorInfo.zoneSub then
                text = (RR.L["|cff888888  -> Redeem tokens at |r|cffffffff%s|r|cff888888: |r|cffffffff%s|r|cff888888 (|r|cffffffff%s|r|cff888888)|r"]):format(
                    RR.L[vendorInfo.vendorName],
                    RR.L[vendorInfo.zoneMain],
                    RR.L[vendorInfo.zoneSub])
            else
                text = (RR.L["|cff888888  -> Redeem tokens at |r|cffffffff%s|r|cff888888: |r|cffffffff%s|r"]):format(
                    RR.L[vendorInfo.vendorName],
                    RR.L[vendorInfo.zoneMain])
            end
            return text, raid, nil, vendorInfo, "token"
        end
        return nil
    end

    if not raid.weaponVendors then return nil end
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
        text = (RR.L["|cff888888  -> Redeem at |r|c%s%s|r|cff888888 vendor: |r|c%s%s|r|cff888888 (|r|cffffffff%s|r|cff888888)|r"]):format(
            cc, RR.L[vendorInfo.covenantName],
            cc, RR.L[vendorInfo.zoneMain],
            RR.L[vendorInfo.zoneSub])
    else
        text = RR.L["|cffff9333  -> No covenant detected|r|cff888888 -- align to redeem weapon tokens.|r"]
    end
    return text, raid, covID, vendorInfo, "covenant"
end

-- Renders the transmog detail body. Accepts {boss=...} or {bossIndex=N}.
BuildTransmogDetail = function(stepOrCtx)
    local boss
    if stepOrCtx and stepOrCtx.boss then
        boss = stepOrCtx.boss
    elseif stepOrCtx and stepOrCtx.bossIndex then
        boss = RR:GetBossByIndex(stepOrCtx.bossIndex)
    end
    if not boss then
        return { mainRows = { { kind = "text",
            text = RR.L["This boss doesn't drop any appearances."] } } }
    end
    -- A boss with no loot still renders the instance-level sections --
    -- trash, wings, faction gear belong to the dungeon, not to whichever
    -- boss the dropdown happens to sit on.
    local bossLoot = boss.loot or {}

    -- Reset per-render caches so we pick up collection changes between pops.
    appearanceIDCache = {}
    sourceAppearanceIDCache = {}

    -- Suppress the current-difficulty white highlight while building a
    -- detail for an instance the player is NOT standing in. Cleared at the
    -- return below; row text is built inside this function, so the flag's
    -- scope covers every row.
    UI._suppressActiveDifficulty = not (RR.currentRaid and RR.currentRaid.bosses
        and RR.currentRaid.bosses[boss.index] == boss)

    -- Rows whose display name collides with another in this boss's loot -- the
    -- paired Warglaives of Azzinoth are the case: one main-hand, one off-hand,
    -- both named "Warglaive of Azzinoth". Marked so FormatItemCells appends an
    -- equip-slot tag that tells them apart.
    -- Keyed on the name the PLAYER sees, not the authored one. Two rows can
    -- carry distinct authored names and still collide once the client name
    -- replaces them: Antorus ships Scythe of the Unmaker "(Blue)" and
    -- "(Red)", two appearances that share one client name, so an
    -- authored-name scan saw no duplicate and the browser drew the same
    -- row twice.
    local function ShownName(item)
        local clientName = item.id and GetItemInfo and C_Item.GetItemInfo(item.id)
        if clientName and clientName ~= "" then return clientName end
        return item.name
    end
    -- Same-named siblings, and whether their SLOTS actually differ. A
    -- difficulty pair (one Normal row, one Heroic row, different item ids,
    -- one name) shares a slot, so appending it disambiguates nothing and
    -- just tags every row in the instance with its own slot.
    local nameSeen, duplicateNames, nameSlots, slotVaries = {}, {}, {}, {}
    for _, dupItem in ipairs(bossLoot) do
        local shown = ShownName(dupItem)
        if shown then
            if nameSeen[shown] then duplicateNames[shown] = true end
            nameSeen[shown] = true
            local seenSlot = nameSlots[shown]
            if seenSlot == nil then
                nameSlots[shown] = dupItem.slot or false
            elseif seenSlot ~= (dupItem.slot or false) then
                slotVaries[shown] = true
            end
        end
    end

    UI._equipGateExempt = UI.EquipGateExemptFor(bossLoot, ActiveClassFilter())
    local candidates = {}
    for _, item in ipairs(bossLoot) do
        if ItemIsTransmogCandidate(item, nil, true) then
            table.insert(candidates, item)
        end
    end

    -- Structured rows, laid into pooled widgets by the browser's layout
    -- pass. Kinds: "item" (three-cell loot row), "text" (full-width
    -- wrapping line), "note" (wrapping sub-line indented to the name
    -- column), "blank" (one-line gap).
    local mainRows = {}
    if #candidates == 0 then
        table.insert(mainRows, { kind = "text",
            text = RR.L["This boss doesn't drop any appearances."] })
    end

    -- Compact top line: just the player's current difficulty. Resolved here,
    -- INSERTED at the end of this build: the named-set block prepends its
    -- rows to position 1, and inserting the line this early left it shoved
    -- below the set rows on every boss carrying one.
    local activeDiff  = ActiveDifficulty()
    local activeName  = activeDiff and DIFF_NAME[activeDiff]

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

    -- The display name FormatItemCells will render: client-localized once
    -- the item cache answers, the stored name until it does. A translated
    -- client used to get an ellipsis here rather than English; the stored
    -- name reads better than punctuation, measures the column honestly on
    -- first paint, and the request below shortens the window it shows for.
    local function RowDisplayName(item)
        local displayName = item.name
        if item.id and GetItemInfo then
            local clientName = C_Item.GetItemInfo(item.id)
            if clientName and clientName ~= "" then
                displayName = clientName
            elseif C_Item and C_Item.RequestLoadItemDataByID then
                C_Item.RequestLoadItemDataByID(item.id)
            end
        end
        return displayName
    end

    -- Legendary-quality rows render as their own block under the regular
    -- loot. The quality read mirrors the orange-name check in
    -- FormatItemCells, so the block and the color always agree.
    local function IsLegendaryRow(item)
        local quality = item.id and GetItemInfo
            and select(3, C_Item.GetItemInfo(item.id))
        return quality == 5
    end

    -- Buckets candidates by shape: binary first, then perdiff sorted by
    -- bucket count ascending then name, so shorter strips read at the top.
    --
    -- Hard-mode-only and opposite-faction drops leave the shape grouping
    -- entirely and render as their own blocks -- both are gates on the run or
    -- the character, and interleaving them would imply a standard clear
    -- reaches them.
    local binaryItems    = {}
    local perDiffItems   = {}
    local hardModeItems  = {}
    local taggedItems    = {}
    local setItems       = {}
    local otherFactionItems = {}
    for _, item in ipairs(candidates) do
        if ItemIsOtherFaction(item) then
            table.insert(otherFactionItems, item)
        elseif item.setName then
            -- Named-set pieces (Dungeon Set 1) render as their own titled
            -- block at the top of the loot, where a tier block would sit --
            -- same intent, its own name.
            table.insert(setItems, item)
        elseif item.tag then
            -- Rows sharing an authored `tag` (King Gordok's Tribute chest)
            -- render as their own titled section rather than interleaved
            -- with the boss's ordinary drops.
            table.insert(taggedItems, item)
        elseif item.hardModeOnly then
            table.insert(hardModeItems, item)
        elseif ItemShape(item) == "binary"
            and not UI.IsMergedSizeDifficultyRow(item)
            and not UI.HasTimewalkingBucket(item)
            and not item.upgrade then
            -- Merged size-difficulty rows are binary in state but render as
            -- letter strips, so they group with the per-difficulty rows and
            -- take the same bucket-signature clustering.
            table.insert(binaryItems, item)
        else
            table.insert(perDiffItems, item)
        end
    end
    local function bucketCount(item)
        -- Counts RENDERED pills, not raw sources: a Wrath N/H pair that
        -- shares one appearance folds to a single pill, so a folded
        -- {10N,10H} row shows one pill and must sort with the other
        -- one-pill rows rather than with the two-pill recolors it happens
        -- to share a source count with.
        local _, foldedSkip = UI.FoldedSizeLabels(item)
        local sourceCount = 0
        for diffID in pairs(item.sources or {}) do
            if not (foldedSkip and foldedSkip[diffID]) then
                sourceCount = sourceCount + 1
            end
        end
        return sourceCount
    end
    -- Clusters same-count items by their actual difficulties rather than
    -- alphabetically, so a split-loot boss doesn't mix Normal-only rows into
    -- the Raid Finder pool. Folded-away buckets are excluded: the signature
    -- must describe the strip the player sees.
    -- The difficulties a row actually drops at, BEFORE size folding. Rows
    -- group by this rather than by their rendered strip, so a row whose
    -- 10N and 10H share one appearance (rendered "[ 10 ]") sits with the
    -- other 10-player rows instead of forming a block of its own.
    local function rawSignature(item)
        local ids = {}
        for diffID in pairs(item.sources or {}) do
            ids[#ids + 1] = diffID
        end
        table.sort(ids)
        return table.concat(ids, ",")
    end
    local function rawCount(item)
        local total = 0
        for _ in pairs(item.sources or {}) do total = total + 1 end
        return total
    end
    -- Binary rows sort by class then name, so class-gated binary gear clusters
    -- under "show all" instead of interleaving. Rows with no class info sort
    -- together at the top. Key is the lowest class ID in the row's set.
    local function classKey(item)
        local set = item.classes or item.equipClasses
        if not set or #set == 0 then return 0 end
        local lo = set[1] or 0
        for _, cid in ipairs(set) do
            if cid < lo then lo = cid end
        end
        return lo
    end
    table.sort(binaryItems, function(a, b)
        local ka, kb = classKey(a), classKey(b)
        if ka ~= kb then return ka < kb end
        return (a.name or "") < (b.name or "")
    end)
    -- Tier rows sort as a block above regular gear, by class ID then name.
    -- Explicit rather than relying on tier's bucket signature differing, which
    -- only clustered on some raids by coincidence.
    -- The section holds both halves of a raid's token economy: class tier,
    -- gated by `classes`, and token rewards open to every class, which name
    -- the token they redeem from instead.
    local function isTier(item)
        return (item.classes and #item.classes > 0) or item.tokenReward ~= nil
    end
    table.sort(hardModeItems, function(a, b)
        local ka, kb = classKey(a), classKey(b)
        if ka ~= kb then return ka < kb end
        return (a.name or "") < (b.name or "")
    end)
    local function CompareRegularRows(a, b)
        local ta, tb = isTier(a), isTier(b)
        if ta ~= tb then return ta end           -- tier block first
        if ta then
            -- The player's own class tier leads the block; token rewards any
            -- class can take follow it, grouped by the token they come from.
            local ra = a.classes and 0 or 1
            local rb = b.classes and 0 or 1
            if ra ~= rb then return ra < rb end
            if not a.classes then
                local wa = a.tokenReward or ""
                local wb = b.tokenReward or ""
                if wa ~= wb then return wa < wb end
                return (a.name or "") < (b.name or "")
            end
            -- Class ID, then difficulty signature, then name. Signature before
            -- name is what makes the blank-line grouping yield one block per
            -- difficulty rather than fragmenting on some raids.
            local ka = a.classes[1] or 0
            local kb = b.classes[1] or 0
            if ka ~= kb then return ka < kb end
            local sa, sb = rawSignature(a), rawSignature(b)
            if sa ~= sb then return sa < sb end
            return (a.name or "") < (b.name or "")
        end
        -- Within regular gear: group by the difficulties the row drops at,
        -- fewest first. Inside a group, rows whose appearance is shared
        -- across those difficulties (one folded pill) lead, since they read
        -- as the simplest case of that section.
        local ca, cb = rawCount(a), rawCount(b)
        if ca ~= cb then return ca < cb end
        local sa, sb = rawSignature(a), rawSignature(b)
        if sa ~= sb then return sa < sb end
        local pa, pb = bucketCount(a), bucketCount(b)
        if pa ~= pb then return pa < pb end
        return (a.name or "") < (b.name or "")
    end
    table.sort(perDiffItems, CompareRegularRows)
    -- The faction block takes the same ordering, so it reads like the main
    -- list rather than like a differently-sorted appendix.
    table.sort(otherFactionItems, CompareRegularRows)
    table.sort(taggedItems, CompareRegularRows)
    table.sort(setItems, CompareRegularRows)

    -- Legendaries leave both shape groups and render as their own block
    -- under the regular loot, separated by a blank line. Extraction runs
    -- after the sorts so the survivors keep their order.
    local legendaryItems = {}
    local function ExtractLegendaries(list)
        local kept = {}
        for _, item in ipairs(list) do
            if IsLegendaryRow(item) then
                table.insert(legendaryItems, item)
            else
                table.insert(kept, item)
            end
        end
        return kept
    end
    binaryItems  = ExtractLegendaries(binaryItems)
    perDiffItems = ExtractLegendaries(perDiffItems)
    table.sort(legendaryItems, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    -- Whether this view emits a faction pair, for the legend footer. MUST be
    -- declared before FormatItemCells, which sets it: a local declared after
    -- a function is not in that function's scope, so the assignment would
    -- silently create a global and this would stay false.
    local viewHasFactionPair = false

    -- Helper: format one item's row as three cells -- the state indicator
    -- (dot row or pill strip), the colored name, and the trailing tags
    -- (bind state, class label, slot disambiguator, availability gates).
    -- The layout pass renders each cell as its own FontString, so rows in
    -- an alignment group share column x-offsets by construction.
    local function FormatItemCells(item)
        local itemDisplayName = RowDisplayName(item)
        local nameText
        local tagParts = {}

        -- Bind state leads the tag run. Only trash-drop rows carry `bind`
        -- today; boss loot omits it because every boss drop binds on
        -- pickup and a tag on every row would be noise. Rendered in the
        -- same neutral tone for both values -- the label carries the
        -- meaning, and the class tags that follow it are availability
        -- gates that should keep the louder colors.
        if item.bind then
            -- Branched on literals rather than looked up through the raw
            -- field: the locale audit scrapes RR.L keys as they appear in
            -- source, so a dynamic key would ship untranslated without any
            -- gate noticing.
            local bindLabel
            if item.bind == "BoE" then
                bindLabel = RR.L["BoE"]
            elseif item.bind == "BoP" then
                bindLabel = RR.L["BoP"]
            end
            if bindLabel then
                -- The tag takes the item's quality color -- epic purple until
                -- the item cache answers, which is also every trash row today.
                local qualityEscape = "|cffa335ee"
                local itemQuality = item.id and GetItemInfo
                    and select(3, C_Item.GetItemInfo(item.id))
                local qualityColor = itemQuality and ITEM_QUALITY_COLORS
                    and ITEM_QUALITY_COLORS[itemQuality]
                if qualityColor and qualityColor.hex then
                    qualityEscape = qualityColor.hex
                end
                table.insert(tagParts, ("|cffffffff(|r%s%s|r|cffffffff)|r"):format(
                    qualityEscape, bindLabel))
            end
        end
        -- The name takes the same states the difficulty pills use, so the
        -- row reads as one thing. Only this base color is substituted:
        -- legendary orange and the tier and restriction suffixes keep their
        -- own colors.
        local baseNameColor = UI.RowNameColor(item)
        -- A faction pair prints both versions' names as one row, the viewing
        -- player's faction first, and EACH NAME CARRIES ITS OWN HALF'S COLOR
        -- so it matches the dot above it -- a pair whose near half is owned
        -- elsewhere and whose far half is missing reads gold / gray, not one
        -- summary color for both. Pre-colored, so the branches below must
        -- not wrap it again. The twin's localized name needs its own
        -- GetItemInfo; the data name is the cold-cache fallback.
        local pairedNameText
        if item.mirror then
            -- The legend's faction-pair line keys off this: set where a pair
            -- is actually emitted, not from the raid's data, so a pair
            -- filtered out by the class dropdown does not advertise itself.
            viewHasFactionPair = true
            local mirrorName = item.mirror.name
            if GetItemInfo and item.mirror.id then
                local clientName = C_Item.GetItemInfo(item.mirror.id)
                if clientName and clientName ~= "" then
                    mirrorName = clientName
                end
            end
            local nearColor = UI.MirrorHalfNameColor(UI.MirrorHalfState(
                RR.BinaryFoldedState(item), item.sources))
            local farColor = UI.MirrorHalfNameColor(UI.MirrorHalfState(
                RR.MirrorFoldedState(item), item.mirror.sources))
            local nearName = itemDisplayName
            local farName = mirrorName
            if UnitFactionGroup and UnitFactionGroup("player") == "Horde" then
                nearName, farName = farName, nearName
                nearColor, farColor = farColor, nearColor
            end
            pairedNameText = UI.BuildPairedNameText(
                nearName, farName, nearColor, farColor, baseNameColor)
            itemDisplayName = nearName .. " / " .. farName
        end
        if item.classes then
            -- Pick the right class name + color for the label. A row serving
            -- SEVERAL classes takes the one being viewed, not just its first:
            -- Vault of Archavon and Baradin Hold ship cloth and mail sets
            -- shared by three classes, so a Mage browsing a Priest/Mage/
            -- Warlock piece read "(Priest Tier)" whatever the filter said.
            local rowClassID = UI.PreferredRowClassID(item.classes, playerClassID)
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
                local classColor = RAID_CLASS_COLORS[classToken]
                if classColor.colorStr then classHex = classColor.colorStr end
            end

            nameText = pairedNameText
                or ("|c%s%s|r"):format(baseNameColor, itemDisplayName)
            if className then
                -- The spec icons ride inside the tier tag, so the row reads
                -- "(Priest Tier <icons>)". Two format keys rather than one
                -- with an empty slot, so no locale carries a stray gap when
                -- the icons are unavailable.
                -- Icons resolve for the PLAYED class only, so on a row being
                -- viewed as somebody else's class they would show the played
                -- class's specs under another class's label. Suppress rather
                -- than mislabel.
                local specIcons = (rowClassID == playerClassID)
                    and UI.SpecIconsForItem(item.id) or nil
                -- White parentheses around the class-colored label, the
                -- same frame the "(<Class>)" suffix uses.
                local tierInner
                if specIcons then
                    tierInner = (RR.L["%s Tier %s"]):format(className, specIcons)
                else
                    tierInner = (RR.L["%s Tier"]):format(className)
                end
                table.insert(tagParts,
                    ("|cffffffff(|r|c%s%s|r|cffffffff)|r"):format(
                        classHex, tierInner))
            end
        else
            -- Non-tier rows render in white by default, in legendary
            -- orange when the item's GetItemInfo quality reports as
            -- legendary (quality enum 5). Matches Blizzard's own
            -- legendary text color so the row reads as legendary at
            -- a glance, not as a plain drop.
            local nameColor = baseNameColor
            if item.id and GetItemInfo then
                local quality = select(3, C_Item.GetItemInfo(item.id))
                if quality == 5 then
                    nameColor = "ffff8000"
                end
            end
            nameText = pairedNameText
                or ("|c%s%s|r"):format(nameColor, itemDisplayName)

            -- Class-restricted non-tier items always render for everyone with
            -- a "(<Class>)" suffix, unlike tier rows which are filtered
            -- out. Players want to see a hard-gated legendary exists.
            if item.restrictedToClass then
                local rcID    = item.restrictedToClass
                local rcName  = (rcID == playerClassID and playerClassName)
                                or ClassNameForID(rcID)
                local rcToken = (rcID == playerClassID and playerClassToken)
                                or CLASS_ID_TO_TOKEN[rcID]
                if rcName then
                    local rcHex = "ffff8000"  -- fallback: orange
                    if rcToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[rcToken] then
                        local classColor = RAID_CLASS_COLORS[rcToken]
                        if classColor.colorStr then rcHex = classColor.colorStr end
                    end
                    -- "(|cAARRGGBB<ClassName>|r)" -- the class name is
                    -- colored; the parens stay in the default text color
                    -- so the suffix reads as a normal-toned tag. The class
                    -- name comes from the client, so the tag needs no
                    -- locale entry.
                    table.insert(tagParts, ("|cffffffff(|r|c%s%s|r|cffffffff)|r"):format(
                        rcHex, rcName))
                end
            end

            -- Acquisition tags. `rareNpc` marks a drop held by one named
            -- rare spawn rather than the zone's trash pool; `tag` is a
            -- short authored label for anything else (Dire Maul's Tribute
            -- chest). Gold, so the tag reads as "special acquisition"
            -- against the white class parens.
            if item.rareNpc then
                -- Label gold, npc name white: color codes do not nest, so
                -- the name closes gold and reopens it after itself.
                table.insert(tagParts, ("|cffffd100(%s)|r"):format(
                    (RR.L["Rare: %s"]):format(
                        "|cffffffff" .. RR.L[item.rareNpc] .. "|r|cffffd100")))
            end
            if item.bossNpc then
                -- Same shape as the rare tag: label gold, name white. Color
                -- codes do not nest, so the name closes gold and reopens it.
                table.insert(tagParts, ("|cffffd100(%s)|r"):format(
                    (RR.L["Boss: %s"]):format(
                        "|cffffffff" .. RR.L[item.bossNpc] .. "|r|cffffd100")))
            end
            -- A summoned encounter: nothing roams, so neither Rare nor
            -- Boss is honest. Same two-tone shape as both.
            if item.eventNpc then
                table.insert(tagParts, ("|cffffd100(%s)|r"):format(
                    (RR.L["Event: %s"]):format(
                        "|cffffffff" .. RR.L[item.eventNpc] .. "|r|cffffd100")))
            end
            -- `tag` renders as a gold suffix on TRASH rows, where there is
            -- no titled section to name the acquisition. Boss-loot tag rows
            -- partition into their own section instead, so the suffix would
            -- repeat the header there and is suppressed.
            if item.tag and not UI._inTaggedSection then
                -- Typed like the rare/boss/event tags: a bare source name
                -- read as a mystery ("Sothos & Jarien"). "From:" covers the
                -- whole remaining family -- named trash mobs and lootable
                -- objects alike.
                table.insert(tagParts, ("|cffffd100(%s)|r"):format(
                    (RR.L["From: %s"]):format(
                        "|cffffffff" .. RR.L[item.tag] .. "|r|cffffd100")))
            end

            -- Wearable-class tag, always: these rows show for every class
            -- (the appearance is collectible regardless), so the tag is
            -- what says who actually equips the piece.
            if item.equipClasses then
                local classTags = {}
                for _, ecID in ipairs(item.equipClasses) do
                    local ecName  = (ecID == playerClassID and playerClassName)
                                    or ClassNameForID(ecID)
                    local ecToken = (ecID == playerClassID and playerClassToken)
                                    or CLASS_ID_TO_TOKEN[ecID]
                    if ecName then
                        local ecHex = "ffff8000"
                        if ecToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[ecToken] then
                            local classColor = RAID_CLASS_COLORS[ecToken]
                            if classColor.colorStr then ecHex = classColor.colorStr end
                        end
                        table.insert(classTags, ("|c%s%s|r"):format(ecHex, ecName))
                    end
                end
                if #classTags > 0 then
                    table.insert(tagParts, ("|cffffffff(|r%s|cffffffff)|r"):format(
                        table.concat(classTags, "|cffffffff, |r")))
                end
            end

            -- `tokenReward` carries no row tag. It groups the row into the
            -- tier section and sorts it beside the others from the same
            -- token; a per-row label would be a form no other row tag uses.
        end

        -- Same-named siblings (the two Warglaives of Azzinoth) get their
        -- equip slot appended so main-hand and off-hand read distinctly.
        -- Blizzard's INVTYPE_* globals are already localized; item.slot is the
        -- cold-cache fallback. Neutral tone, like the bind tag.
        local shownName = ShownName(item)
        if shownName and duplicateNames[shownName] then
            -- The authored disambiguator wins where the data carries one the
            -- client name drops: the two Scythes share a client name AND a
            -- slot, so the equip-slot tag cannot separate them.
            local tagLabel
            if item.name and item.name ~= shownName then
                tagLabel = item.name:match("%(([^()]+)%)%s*$")
            end
            if not tagLabel then
                if item.id and GetItemInfo then
                    local equipLoc = select(9, C_Item.GetItemInfo(item.id))
                    if equipLoc and equipLoc ~= "" then tagLabel = _G[equipLoc] end
                end
                -- Only when the slot is what tells the siblings apart.
                if not slotVaries[shownName] then tagLabel = nil end
                tagLabel = tagLabel or (slotVaries[shownName] and item.slot)
            end
            if tagLabel and tagLabel ~= "" then
                table.insert(tagParts, ("|cffffffff(|r|cff9d9d9d%s|r|cffffffff)|r"):format(
                    tagLabel))
            end
        end

        -- Neither hard-mode nor opposite-faction drops carry a per-row tag:
        -- each kind renders inside its own section, under a header that
        -- already names the condition ("Hard Mode", "Horde Appearances"),
        -- so a tag on every line said it twice.

        -- Bind-on-equip rows only, while this source is uncollected. A
        -- BoP drop grants its appearance at loot, so a marker could only
        -- sit beside a collected row; a BoE can be carried for weeks
        -- unowned. `shared` rows qualify too: the look is known through
        -- another item, but equipping the carried piece is what collects
        -- this source and completes the row. Stays at the end of the run:
        -- it is an alert about the player's bags, not a property of the item.
        if item.bind == "BoE" or item.bagAlert then
            local carriedState = ItemSummaryState(item)
            -- `bagAlert` rows (Zul'Farrak's combinable sword halves) show
            -- the suffix whenever carried: the half stays combine material
            -- even after its own appearance is collected.
            if (item.bagAlert
                    or carriedState == "missing" or carriedState == "shared")
                and GetItemCount and (C_Item.GetItemCount(item.id, false) or 0) > 0 then
                table.insert(tagParts, ("|cffffffff(|r|cff4dccff%s|r|cffffffff)|r"):format(
                    RR.L["in your bags!"]))
            end
        end
        return BuildDotRow(item), nameText, table.concat(tagParts, " ")
    end

    -- Emits one loot row, plus its acquisitionNote sub-line when the item
    -- has one (legendaries gated behind a quest-starter, vendor-exchange
    -- unlocks). The note renders as a wrapping row indented to the name
    -- column, in dim gray so it reads as commentary. `isTierRow` picks which
    -- of the list's two column pairs the row lays out against.
    local function EmitItemRow(rowsOut, item, isTierRow)
        local indicatorText, nameText, tagsText = FormatItemCells(item)
        table.insert(rowsOut, { kind = "item", indicator = indicatorText,
            name = nameText, tags = tagsText, isTier = isTierRow,
            itemID = item.id })
        if item.acquisitionNote then
            -- Rows that share a note (a legendary pair) show it once, under
            -- the last of them, rather than once per row.
            local noteText = ("|cff888888%s|r"):format(RR.L[item.acquisitionNote])
            for index = #rowsOut, 1, -1 do
                local row = rowsOut[index]
                if row.kind == "note" and row.text == noteText then
                    table.remove(rowsOut, index)
                    break
                end
            end
            table.insert(rowsOut, { kind = "note", text = noteText })
        end
    end

    -- Tier leads the list, whatever shape its rows take. Tier used to sort
    -- to the front of each shape group SEPARATELY, so a binary-shape epic
    -- rendered above a per-difficulty tier row -- and therefore above the
    -- TIER / TOKENS divider, which is inserted at the first tier row.
    -- Splitting here also makes the tier block contiguous by construction,
    -- which is what lets the dividers draw at all.
    local function SplitTierRows(list)
        local tierPart, lootPart = {}, {}
        for _, item in ipairs(list) do
            if isTier(item) then
                table.insert(tierPart, item)
            else
                table.insert(lootPart, item)
            end
        end
        return tierPart, lootPart
    end
    local binaryTier,  binaryLoot  = SplitTierRows(binaryItems)
    local perDiffTier, perDiffLoot = SplitTierRows(perDiffItems)

    -- A class break only earns its place when some class has more than one
    -- tier row to bind. Where every class carries a single row (direct-drop
    -- tier), the break falls between every row and doubles the block height.
    -- Class tier only. Token rewards are tier-section rows carrying no class,
    -- so they neither group by one nor count toward the break rule.
    local tierRows = {}
    for _, item in ipairs(binaryTier)  do table.insert(tierRows, item) end
    for _, item in ipairs(perDiffTier) do table.insert(tierRows, item) end
    local tierRowsPerClass, anyTierClassGrouped = {}, false
    for _, item in ipairs(tierRows) do
        if item.classes then
            local classID = item.classes[1] or 0
            tierRowsPerClass[classID] = (tierRowsPerClass[classID] or 0) + 1
            if tierRowsPerClass[classID] > 1 then anyTierClassGrouped = true end
        end
    end

    -- Tier block, both shapes, binary first so the shorter strips lead.
    local lastTierClass
    for _, item in ipairs(tierRows) do
        local tierClass = item.classes and item.classes[1] or nil
        -- Tier breaks on CLASS, not on difficulty: one class's 10 and 25
        -- pieces are a single player's set and read as one block.
        if anyTierClassGrouped and lastTierClass and tierClass ~= lastTierClass then
            table.insert(mainRows, { kind = "blank" })
        end
        lastTierClass = tierClass
        EmitItemRow(mainRows, item, true)
    end

    -- Ordinary loot, binary shape first, then per-difficulty.
    for _, item in ipairs(binaryLoot) do
        EmitItemRow(mainRows, item, false)
    end

    -- Blank-line separator between groups, but only if both groups have
    -- content (otherwise we'd emit a trailing blank line for no reason).
    if #binaryLoot > 0 and #perDiffLoot > 0 then
        table.insert(mainRows, { kind = "blank" })
    end

    -- Emit per-difficulty group. Items are pre-sorted by bucket count
    -- ascending, then by bucket signature, so groups separate by both shape
    -- and difficulty: for WoD split-loot bosses the single-bucket Normal-only
    -- ({[14]}) items and the Raid Finder ({[17]}) pool each get their own
    -- block with a blank line between, then the 3-bucket N/H/M items, then
    -- any full 4-bucket items -- no explicit sub-headers needed.
    local lastSignature
    for _, item in ipairs(perDiffLoot) do
        -- Separated on the raw difficulty set, so a folded row joins the
        -- section it shares difficulties with rather than starting one.
        local sig = rawSignature(item)
        if lastSignature and sig ~= lastSignature then
            table.insert(mainRows, { kind = "blank" })
        end
        lastSignature = sig
        EmitItemRow(mainRows, item, false)
    end

    -- Legendary block last, a blank line clear of the regular loot.
    if #legendaryItems > 0 then
        if #binaryItems > 0 or #perDiffItems > 0 then
            table.insert(mainRows, { kind = "blank" })
        end
        for _, item in ipairs(legendaryItems) do
            EmitItemRow(mainRows, item)
        end
    end

    -- Hard-mode-only and opposite-faction rows render as their own
    -- collapsible sections (same widget shape as the trash section), so
    -- their rows are built here and handed back.
    --
    -- Each section aligns within ITSELF: it is measured as its own render
    -- list, so an expanding section cannot shift the main list's columns.
    local function BuildSectionRows(items)
        if #items == 0 then return nil end
        local sectionRows = {}
        for _, item in ipairs(items) do
            EmitItemRow(sectionRows, item, isTier(item))
        end
        return sectionRows
    end

    -- The other faction's TIER rows mirror this faction's piece for piece, so
    -- they belong beside the tier block. Its ordinary drops do not mirror
    -- anything, so they stay at the foot with the rest of the loot.
    local factionTierItems, factionLootItems = {}, {}
    for _, item in ipairs(otherFactionItems) do
        if isTier(item) then
            table.insert(factionTierItems, item)
        else
            table.insert(factionLootItems, item)
        end
    end

    local hardModeRows    = BuildSectionRows(hardModeItems)
    UI._inTaggedSection = true
    local taggedRows      = BuildSectionRows(taggedItems)
    UI._inTaggedSection = nil
    local taggedLabel     = taggedItems[1] and taggedItems[1].tag or nil
    -- The section's explanatory prose collapses with it, below the rows --
    -- the pattern the trash section's placement established.
    if taggedRows and #taggedRows > 0 and boss.tagNote then
        table.insert(taggedRows, { kind = "blank" })
        table.insert(taggedRows, { kind = "text", soft = true,
            text = ("|cff9d9d9d%s|r"):format(RR.L[boss.tagNote]) })
    end
    local factionTierRows = BuildSectionRows(factionTierItems)
    local factionRows     = BuildSectionRows(factionLootItems)

    -- Weapon-token section (Castle Nathria, Sanctum of Domination).
    -- Tokens are covenant-partitioned in ways the data doesn't capture,
    -- so each slot renders as 3-state (none/some/all) rather than an
    -- inaccurate X/N ratio.
    local raid = RR.currentRaid
    -- Browser may display a non-current raid; resolve raid from boss. BOTH
    -- instance tables, or a browsed dungeon falls through to whatever
    -- instance is currently loaded and renders ITS trash section -- the
    -- first dungeon trash data made every dungeon show one raid's rows.
    if not raid or (raid.bosses and raid.bosses[boss.index] ~= boss) then
        local resolved
        for _, tbl in ipairs({ RetroRuns_Data, RetroRuns_DungeonData }) do
            for _, r in pairs(tbl or {}) do
                if r.bosses then
                    for _, b in ipairs(r.bosses) do
                        if b == boss then resolved = r; break end
                    end
                end
                if resolved then break end
            end
            if resolved then break end
        end
        if resolved then raid = resolved end
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
                local tokenName = (C_Item.GetItemInfo(tokenID))
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

        -- Class-list suffix for a slot's class set, each name in its class
        -- color. Collapses to "All classes" when the set covers every class
        -- with weapon access at that slot.
        local function FormatClassList(classSet, slotLabel)
            local ids = {}
            for cid in pairs(classSet) do table.insert(ids, cid) end
            table.sort(ids)
            local allCount = (slotLabel == "Main-Hand") and 13 or 9
            if #ids >= allCount then
                return RR.L["All classes"]
            end
            local parts = {}
            for _, cid in ipairs(ids) do
                local classInfoName = GetClassInfo and GetClassInfo(cid)
                if classInfoName then
                    local hex
                    local token = CLASS_ID_TO_TOKEN[cid]
                    if token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token] then
                        local classColor = RAID_CLASS_COLORS[token]
                        if classColor.colorStr then hex = classColor.colorStr end
                    end
                    if hex then
                        table.insert(parts, ("|c%s%s|r"):format(hex, classInfoName))
                    else
                        table.insert(parts, classInfoName)
                    end
                end
            end
            return table.concat(parts, " / ")
        end

        local tokenRows = {}
        for _, slot in ipairs(slotOrder) do
            local classSet = slotClasses[slot]
            if classSet and next(classSet) then
                local label = (RR.L["%s Weapon Token: %s"]):format(
                    RR.L[slot], FormatClassList(classSet, slot))
                table.insert(tokenRows, ("|cffffffff%s|r"):format(label))
            end
        end

        if #tokenRows > 0 then
            -- Token lines lead the list, flagged as tier rows so the block
            -- below draws them under TIER / TOKENS with the redemption hint
            -- and closes them with LOOT, the shape every tier boss has.
            for offset = #tokenRows, 1, -1 do
                table.insert(mainRows, 1,
                    { kind = "text", text = tokenRows[offset], isTier = true })
            end

            -- Vendor hint line is rendered separately as its own
            -- FontString below the main text, with a Flight button
            -- anchored to it (see BuildSanctumLine and the
            -- sanctumLine widget on tmogWindow). Skipped here.
        end
    end

    -- Raid trash is held once at raid level and shown under whichever boss is
    -- selected. It renders as its own collapsible section below the main rows
    -- in the browser, so the section's rows and collected/total counts are
    -- built here (where the row helpers are in scope) and handed back.
    local trashSectionRows, trashCollected, trashTotal
    if raid and raid.trashLoot and #raid.trashLoot > 0 then
        UI._equipGateExempt = UI.EquipGateExemptFor(raid.trashLoot,
            ActiveClassFilter())
        local trashItems = {}
        for _, item in ipairs(raid.trashLoot) do
            if ItemIsTransmogCandidate(item, nil, true) then
                table.insert(trashItems, item)
            end
        end
        if #trashItems > 0 then
            -- Bundled by acquisition: rows held by one named rare, event,
            -- boss or object mechanism sit together, a blank line between
            -- bundles, plain pool trash leading -- the legacy section's
            -- grouping shape. One slot-sorted pass scattered the source
            -- tags through the list.
            local plainTrash, groupOrder, groupsByKey = {}, {}, {}
            for _, item in ipairs(trashItems) do
                local key = item.rareNpc or item.eventNpc or item.bossNpc
                    or item.tag
                if key then
                    if not groupsByKey[key] then
                        groupsByKey[key] = {}
                        groupOrder[#groupOrder + 1] = key
                    end
                    table.insert(groupsByKey[key], item)
                else
                    table.insert(plainTrash, item)
                end
            end
            table.sort(groupOrder)
            trashSectionRows = {}
            -- Cross-listed rows render but do not count; the boss row they
            -- duplicate keeps the tally.
            local bossCarried = UI.BossCarriedSourceSet(raid)
            trashCollected, trashTotal = 0, 0
            for _, item in ipairs(trashItems) do
                if not UI.TrashRowIsBossCarried(item, bossCarried) then
                    trashTotal = trashTotal + 1
                end
            end
            local function EmitTrashRow(item)
                EmitItemRow(trashSectionRows, item)
                if UI.TrashRowIsBossCarried(item, bossCarried) then return end
                local state = ItemSummaryState(item)
                if state ~= "missing" and state ~= "shared" then
                    trashCollected = trashCollected + 1
                end
            end
            -- Within a bundle the shape split still applies: single-glyph
            -- binary rows first, per-difficulty strips after (a blank
            -- between shapes only in the plain bundle, where both runs can
            -- be long). An upgrade row is binary in source count but
            -- renders as a strip, so it groups with the pilled rows.
            local emittedAny = false
            local function EmitTrashBundle(items, blankBetweenShapes)
                local binaryRows, pilledRows = {}, {}
                for _, item in ipairs(items) do
                    if ItemShape(item) == "binary" and not item.upgrade then
                        table.insert(binaryRows, item)
                    else
                        table.insert(pilledRows, item)
                    end
                end
                if #binaryRows + #pilledRows == 0 then return end
                table.sort(binaryRows, CompareRegularRows)
                table.sort(pilledRows, CompareRegularRows)
                if emittedAny then
                    table.insert(trashSectionRows, { kind = "blank" })
                end
                for _, item in ipairs(binaryRows) do EmitTrashRow(item) end
                if blankBetweenShapes and #binaryRows > 0
                    and #pilledRows > 0 then
                    table.insert(trashSectionRows, { kind = "blank" })
                end
                for _, item in ipairs(pilledRows) do EmitTrashRow(item) end
                emittedAny = true
            end
            EmitTrashBundle(plainTrash, true)
            for _, key in ipairs(groupOrder) do
                EmitTrashBundle(groupsByKey[key], false)
            end

            -- Legend for the upgrade chain, under the rows it explains.
            -- {dot} takes the same dot the rows use, dimmed, and {item}
            -- resolves to a real item link.
            if raid.trashNote and raid.trashNote.text then
                local noteText = RR.L[raid.trashNote.text]
                noteText = noteText:gsub("{dot}",
                    UI.ProgressDotGlyph(DOT_INACTIVE))
                noteText = noteText:gsub("{pad}",
                    "|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\StatusDot:10:10:0:0:64:64:0:2:0:2|t")
                if raid.trashNote.itemID then
                    local _, itemLink = C_Item.GetItemInfo(raid.trashNote.itemID)
                    if not itemLink then
                        local fallbackName = C_Item.GetItemInfo(raid.trashNote.itemID)
                            or RR.L["(item)"]
                        itemLink = ("|cffa335ee[%s]|r"):format(fallbackName)
                    end
                    noteText = noteText:gsub("{item}", itemLink)
                end
                table.insert(trashSectionRows, { kind = "blank" })
                table.insert(trashSectionRows, { kind = "text", soft = true,
                    text = ("|cff9d9d9d%s|r"):format(noteText) })
            end
            -- Raids whose redemption belongs to trash rather than tier put
            -- the vendor hint at the foot of this section.
            if raid.tokenVendors and raid.tokenVendors.below == "trash" then
                table.insert(trashSectionRows, { kind = "sanctum" })
            end
        end
    end

    -- Appearances obtainable only in a legacy version of this instance.
    -- Instance-scoped like trash rather than hung off a boss, because the
    -- bosses that drop them do not exist in the modern layout. The sanctum
    -- marker at the foot is what draws the access hint and its travel plane.
    local legacySectionRows, legacyCollected, legacyTotal
    if raid and raid.legacyLoot and #raid.legacyLoot > 0 then
        UI._equipGateExempt = UI.EquipGateExemptFor(raid.legacyLoot,
            ActiveClassFilter())
        local legacyItems = {}
        for _, item in ipairs(raid.legacyLoot) do
            if ItemIsTransmogCandidate(item, nil, true) then
                table.insert(legacyItems, item)
            end
        end
        if #legacyItems > 0 then
            legacySectionRows = {}
            -- Counted by item id, not by row: a piece that drops in more
            -- than one wing is listed under each, and the count is of
            -- appearances to collect.
            legacyCollected, legacyTotal = 0, 0
            local legacyCounted, legacyCountedOwned = {}, {}
            for _, item in ipairs(legacyItems) do
                local key = item.id or item
                if not legacyCounted[key] then
                    legacyCounted[key] = true
                    legacyTotal = legacyTotal + 1
                end
            end
            -- Grouped by the wing the appearance actually drops in, each
            -- under its own divider, because the wings are separate instances
            -- a player enters one at a time. Within a wing, boss drops lead
            -- and rare-spawn drops follow: the two are found completely
            -- differently and each row already names its own source.
            local function EmitLegacyRow(item)
                EmitItemRow(legacySectionRows, item)
                local state = ItemSummaryState(item)
                if state ~= "missing" and state ~= "shared" then
                    local key = item.id or item
                    if not legacyCountedOwned[key] then
                        legacyCountedOwned[key] = true
                        legacyCollected = legacyCollected + 1
                    end
                end
            end
            local wingOrder, byWing = {}, {}
            for _, item in ipairs(legacyItems) do
                local wing = item.legacyWing or ""
                if not byWing[wing] then
                    byWing[wing] = { boss = {}, rare = {}, trash = {} }
                    wingOrder[#wingOrder + 1] = wing
                end
                local bucket = byWing[wing]
                local target = bucket.trash
                if item.rareNpc then
                    target = bucket.rare
                elseif item.bossNpc then
                    target = bucket.boss
                end
                table.insert(target, item)
            end
            for index, wing in ipairs(wingOrder) do
                local bucket = byWing[wing]
                if wing ~= "" then
                    -- No blank ahead of it: PlaceListDivider already puts a
                    -- cushion above the rule, and stacking a blank row on top
                    -- of that left a visible hole between wings.
                    table.insert(legacySectionRows,
                        { kind = "divider", label = wing })
                end
                -- Boss drops grouped per boss, a blank line between groups,
                -- so a wing with several bosses reads as several short lists
                -- rather than one run of rows that all name a different boss.
                local bossOrder, byBoss = {}, {}
                for _, item in ipairs(bucket.boss) do
                    local who = item.bossNpc or ""
                    if not byBoss[who] then
                        byBoss[who] = {}
                        bossOrder[#bossOrder + 1] = who
                    end
                    table.insert(byBoss[who], item)
                end
                table.sort(bossOrder)
                local emitted = false
                for _, who in ipairs(bossOrder) do
                    if emitted then
                        table.insert(legacySectionRows, { kind = "blank" })
                    end
                    for _, item in ipairs(byBoss[who]) do EmitLegacyRow(item) end
                    emitted = true
                end
                if emitted and #bucket.rare > 0 then
                    table.insert(legacySectionRows, { kind = "blank" })
                end
                for _, item in ipairs(bucket.rare) do EmitLegacyRow(item) end
                -- Anything with no boss and no rare behind it is trash, and
                -- takes its own divider so it is not read as a boss drop.
                if #bucket.trash > 0 then
                    table.insert(legacySectionRows,
                        { kind = "divider", label = "Trash" })
                    for _, item in ipairs(bucket.trash) do EmitLegacyRow(item) end
                end
            end
            if raid.legacyNote and raid.legacyNote.text then
                -- Unlabelled divider: the hint explains the whole block, not
                -- the rows immediately above it, so it needs separating from
                -- them without a heading of its own.
                table.insert(legacySectionRows,
                    { kind = "divider", subtle = true })
                table.insert(legacySectionRows, { kind = "sanctum" })
            end
        end
    end

    -- Optional per-boss footnote: { text = ..., itemID = N }, where {item}
    -- becomes a WoW item link. Prose that belongs under a boss but names no
    -- destination -- anything pointing at a vendor is an omniToken instead.
    if boss.tmogFootnote then
        -- Renders a single footnote entry to gray text. Returns the formatted
        -- string, or nil if the entry produces no usable text.
        -- `itemID` fills {item}. A footnote naming SEVERAL items takes
        -- `itemIDs` and numbered {item1}/{item2} tokens instead: a
        -- translation can then reorder the sentence without the links
        -- swapping, which a repeated {item} could not survive.
        -- UI.ItemLinkFor carries its own cold-cache fallback.
        local function RenderFootnoteEntry(entry)
            if type(entry) ~= "table" then return nil end
            local text = RR.L[entry.text or ""]
            if entry.itemID then
                text = text:gsub("{item}", UI.ItemLinkFor(entry.itemID))
            end
            for index, itemID in ipairs(entry.itemIDs or {}) do
                text = text:gsub("{item" .. index .. "}",
                    UI.ItemLinkFor(itemID))
            end
            return text
        end

        for _, entry in ipairs({ boss.tmogFootnote }) do
            local footnoteText = RenderFootnoteEntry(entry)
            if footnoteText and footnoteText ~= "" then
                table.insert(mainRows, { kind = "blank" })
                -- Footnotes are prose: they wrap at whatever width the
                -- loot rows set rather than widening the popup to fit.
                table.insert(mainRows, { kind = "text", soft = true,
                    text = ("|cff9d9d9d%s|r"):format(footnoteText) })
            end
        end
    end

    -- The redemption hint belongs with the tier it explains, so it renders
    -- directly under the last tier row rather than at the foot of the
    -- list. Raids with no tier rows leave the marker out and the hint
    -- falls back to the end of the list.
    local placeUnderTrash = raid and raid.tokenVendors
                            and raid.tokenVendors.below == "trash"
    local firstTierIndex, lastTierIndex
    for index, row in ipairs(mainRows) do
        if row.isTier then
            if not firstTierIndex then firstTierIndex = index end
            lastTierIndex = index
        end
    end
    -- Tier sorts to the front of its shape group, so the block is normally
    -- unbroken. A raid carrying tier in both shape groups would put loot
    -- between the halves, and an opening divider there would enclose rows
    -- it does not describe, so it only draws over an unbroken block.
    local tierContiguous = firstTierIndex ~= nil
    if firstTierIndex then
        for index = firstTierIndex, lastTierIndex do
            local row = mainRows[index]
            if row.kind == "item" and not row.isTier then
                tierContiguous = false
                break
            end
        end
    end
    -- Anything after the tier block needs the closing divider; a boss whose
    -- list ends on tier would otherwise trail one.
    local tierHasFollowers = lastTierIndex and #mainRows > lastTierIndex
    local tierInfoRows
    if lastTierIndex then
        -- Legend for the chain dots, then the vendor hint. Both fold into a
        -- collapsible "Tier / Token Info" subsection, collapsed by default:
        -- on the token-turn-in raids the full hint stands taller than the
        -- rows it explains.
        tierInfoRows = {}
        if raid and raid.tierNote and raid.tierNote.text then
            local noteText = RR.L[raid.tierNote.text]
            noteText = noteText:gsub("{dot}", UI.ProgressDotGlyph(DOT_INACTIVE))
            -- {pad} is a dot-width blank (a transparent corner of the dot
            -- texture) so the words start in one column on every line.
            noteText = noteText:gsub("{pad}",
                "|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\StatusDot:10:10:0:0:64:64:0:2:0:2|t")
            if raid.tierNote.itemID then
                local _, itemLink = C_Item.GetItemInfo(raid.tierNote.itemID)
                if itemLink then noteText = noteText:gsub("{item}", itemLink) end
            end
            for _, link in ipairs(raid.tierNote.links or {}) do
                -- Follows the class the rows above are showing, which is
                -- the browser's class filter when one is set.
                local itemID = (link.byClass and link.byClass[ActiveClassFilter()])
                    or link.default
                local _, itemLink = C_Item.GetItemInfo(itemID)
                local shown = itemLink or ("[" .. RR.L[link.name] .. "]")
                noteText = noteText:gsub(link.token:gsub("%p", "%%%0"),
                    (shown:gsub("%%", "%%%%")))
            end
            table.insert(tierInfoRows, { kind = "text", soft = true,
                text = ("|cff9d9d9d%s|r"):format(noteText) })
        end
        -- A block of token lines with no tier rows (Denathrius) has one
        -- redemption line to show, so it stays in view instead of folding
        -- into the subsection.
        local tierHasItems = false
        for index = firstTierIndex, lastTierIndex do
            if mainRows[index].kind == "item" then tierHasItems = true; break end
        end
        local afterTier = {}
        if not placeUnderTrash then
            if tierHasItems then
                table.insert(tierInfoRows, { kind = "sanctum" })
            else
                table.insert(afterTier, { kind = "sanctum" })
            end
        end
        -- A boss's own tier line (Dragon Soul's "any Raid Finder token"
        -- bosses) sits directly under its tier rows, always visible.
        if boss.tierNote then
            table.insert(afterTier, { kind = "blank" })
            table.insert(afterTier, { kind = "text", soft = true,
                text = ("|cff9d9d9d%s|r"):format(RR.L[boss.tierNote]) })
        end
        -- The shape line closes the tier list, directly under the rows it
        -- describes. The color legend footer is a screen away past the
        -- whole loot list, too far to decode a dot pair up here.
        if viewHasFactionPair then
            local pairLabel = UI.FactionPairLegendText()
            if pairLabel then
                -- Carried as an item row so it inherits the tier block's
                -- column offsets; pairKey tells the layout to draw it as a
                -- caption rather than a row.
                table.insert(afterTier, { kind = "item", isTier = true,
                    pairKey = true, indicator = "", name = pairLabel,
                    tags = "" })
            end
        end
        if #tierInfoRows > 0 then
            -- The layout pass draws the subsection header here, and the
            -- rows under it only while expanded. Emitted even when the only
            -- content is the sanctum marker -- whether that line has text
            -- is known only at render time, and the header draws nothing
            -- when it turns out empty.
            table.insert(afterTier, { kind = "tierinfo" })
        end
        -- Only the other faction's TIER rows ride up here; its ordinary
        -- drops keep the foot-of-list section. Bosses with no tier leave
        -- the marker out and the rows fall back to the foot.
        if factionTierRows and #factionTierRows > 0 then
            table.insert(afterTier,
                { kind = "section", section = "factiontier" })
        end
        -- Closes the tier block under its legend and opens the ordinary
        -- drops, so they stop reading as more of the note.
        if tierHasFollowers then
            table.insert(afterTier, { kind = "divider", label = "LOOT" })
        end
        for offset = #afterTier, 1, -1 do
            table.insert(mainRows, lastTierIndex + 1, afterTier[offset])
        end
        -- Inserted last: it sits below lastTierIndex, so the offsets above
        -- are already spent.
        if tierContiguous then
            table.insert(mainRows, firstTierIndex,
                { kind = "divider", label = "TIER / TOKENS" })
        end
    elseif boss.tierNote then
        -- No tier rows of its own, but a tier line to show: it opens the
        -- list under the same divider the rows would have.
        local noteRows = {
            { kind = "divider", label = "TIER / TOKENS" },
            { kind = "text", soft = true,
              text = ("|cff9d9d9d%s|r"):format(RR.L[boss.tierNote]) },
        }
        if #mainRows > 0 then
            table.insert(noteRows, { kind = "divider", label = "LOOT" })
        end
        for offset = #noteRows, 1, -1 do
            table.insert(mainRows, 1, noteRows[offset])
        end
    end

    -- Named-set block: titled divider carrying the set's own name, rows
    -- prepended ahead of everything (the position the tier block owns on
    -- raids). setRows is nil for a set-less boss, per BuildSectionRows.
    local setRows = BuildSectionRows(setItems)
    if setRows and #setRows > 0 then
        -- Through RR.L like every other authored label: the raw field
        -- rendered English on all nine translated clients.
        local setLabel = RR.L[setItems[1].setName]
        -- Closes the set block the way "LOOT" closes the tier block on
        -- raids, so the plain drops stop reading as more of the set. Only
        -- when followers exist; mainRows still holds just the loot here,
        -- the difficulty line is prepended after this block.
        if #mainRows > 0 then
            table.insert(mainRows, 1, { kind = "divider", label = "LOOT" })
        end
        for offset = #setRows, 1, -1 do
            table.insert(mainRows, 1, setRows[offset])
        end
        table.insert(mainRows, 1, { kind = "divider", label = setLabel })
    end

    -- The difficulty line claims the top only after every prepend is done.
    if activeName then
        table.insert(mainRows, 1, { kind = "blank" })
        table.insert(mainRows, 1, { kind = "text",
            text = ("|cff888888" .. RR.L["Current difficulty: %s"] .. "|r"):format(activeName) })
    end

    UI._suppressActiveDifficulty = nil
    return {
        mainRows       = mainRows,
        tierInfoRows   = tierInfoRows,
        trashRows      = trashSectionRows,
        trashCollected = trashCollected,
        trashTotal     = trashTotal,
        legacyRows      = legacySectionRows,
        legacyCollected = legacyCollected,
        legacyTotal     = legacyTotal,
        legacyLabel     = raid and raid.legacyLabel or nil,
        hardModeRows   = hardModeRows,
        taggedRows     = taggedRows,
        taggedLabel    = taggedLabel,
        factionTierRows = factionTierRows,
        factionRows    = factionRows,
    }
end

-- Color legend rendered as the bottom-most line in the Tmog window. The
-- dot colors mean the same thing whether or not the player is in a
-- supported raid, so it sits below the per-boss content and the
-- weapon-token redemption hint (when present), as a global footer.
local function BuildTmogLegendText()
    local text =
        ("|c%s" .. RR.L["green"] .. "|r|cff888888 = " .. RR.L["collected"]
            .. "      |r|c%s" .. RR.L["gold"] .. "|r|cff888888 = "
            .. RR.L["via another item"] .. "|r\n"):format(
            DOT_COLLECTED, DOT_SHARED)
     .. ("|c%s" .. RR.L["white"] .. "|r|cff888888 = "
            .. RR.L["needed (current difficulty)"] .. "  |r|c%s"
            .. RR.L["gray"] .. "|r|cff888888 = " .. RR.L["not collected"]
            .. "|r"):format(
            DOT_ACTIVE, DOT_INACTIVE)
    return text, 2
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
-- Exposed for BuildSkipsRows so the Skips window sorts raids by
-- expansion (newest first) rather than alphabetically.
RR.EXPANSION_ORDER_NEWEST_FIRST = EXPANSION_ORDER_NEWEST_FIRST

-- Shared raid-ordering comparator. Parses a raid's `patch` field
-- (e.g. "10.2", "9.2.5") into a list of integers, then compares
-- lexicographically with the larger value winning -- so 10.2 > 10.1.0,
-- 9.2.5 > 9.2, etc. Raids missing a patch field sort last (the
-- patchKey returns { -1 } as a sentinel). Ties break alphabetically
-- by name so output is deterministic across reloads.
local function patchKey(raid)
    local patch = raid.patch
    if not patch then return { -1 } end
    local parts = {}
    for n in patch:gmatch("(%d+)") do
        table.insert(parts, tonumber(n) or 0)
    end
    if #parts == 0 then return { -1 } end
    return parts
end
local function patchDescending(a, b)
    local ka, kb = patchKey(a), patchKey(b)
    local partCount = math.max(#ka, #kb)
    for i = 1, partCount do
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
-- On the UI table: UI.lua's main chunk sits at Lua 5.1's 200-local ceiling.
UI.EnumerateInstances = function(kind)
    local source = (kind == "dungeon") and RetroRuns_DungeonData
                   or RetroRuns_Data
    local byExpansion = {}
    for _, raid in pairs(source or {}) do
        -- Skip incomplete entries (instanceID = 0); they have no resolved
        -- journal IDs and would render as all-dash pills.
        if raid.instanceID and raid.instanceID > 0 then
            local exp = raid.expansion or RR.L["Unknown"]
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

local function EnumerateRaids()
    return UI.EnumerateInstances("raid")
end

-- The key a browser entry is stored under: raids by instance map id,
-- dungeons by journalInstanceID (wings share maps).
UI.BrowserKeyOf = function(entry)
    if entry.kind == "dungeon" then return entry.journalInstanceID end
    return entry.instanceID
end

-- Aims the browser at the instance the player is standing in, on the boss
-- they are most likely to care about. Kind-aware in both halves: dungeons
-- key by journalInstanceID where raids key by instance map id, and their
-- boss comes from the encounter last pulled rather than from a routing
-- step, since an unrouted instance has no step to read. A no-op outside a
-- supported instance, which leaves the last-browsed selection alone.
function UI.PointBrowserAtCurrentInstance()
    local instance = RR.currentRaid
    if not instance then return end
    browserState.instanceKind = (instance.kind == "dungeon")
        and "dungeon" or "raid"
    browserState.expansion = instance.expansion
    browserState.raidKey   = UI.BrowserKeyOf(instance)
    local step = RR.state and RR.state.activeStep
    local bossIndex = (step and step.bossIndex)
        or (RR.state and RR.state.lastEncounterBossIndex)
    -- Nothing pulled yet this session (a reload mid-run lands here, since
    -- the remembered encounter does not survive one): fall back to the
    -- first boss still standing, which is where the player is headed.
    if not bossIndex and RR.state and RR.state.bossesKilled then
        for _, boss in ipairs(instance.bosses or {}) do
            if not RR.state.bossesKilled[boss.index] then
                bossIndex = boss.index
                break
            end
        end
    end
    if bossIndex then
        browserState.bossIndex = bossIndex
    end
end

-- Resolve an instance from an explicit kind + key. Raids key by instance
-- map id, dungeons by journalInstanceID (wings share maps), so the kind has
-- to travel with the key. Windows keep their own selection state, hence the
-- explicit kind rather than reading any one window's.
UI.InstanceByKindKey = function(kind, key)
    if not key then return nil end
    if kind == "dungeon" then
        return RR:GetDungeonByKey(key)
    end
    return RR:GetRaidByInstanceID(key)
end

-- Kind-aware resolve for browserState.raidKey.
UI.BrowserInstanceByKey = function(key)
    return UI.InstanceByKindKey(browserState.instanceKind, key)
end

-- Flat name index over both instance tables for the browser's search box:
-- one entry per expansion, instance, boss, and loot row, each carrying the
-- dropdown selection that reaches it. Built once per session on first use;
-- the data tables never change after load. Item entries index the authored
-- name; expansion, instance, and boss entries index the localized and
-- authored names.
UI.BuildTmogSearchIndex = function()
    if UI._tmogSearchIndex then return UI._tmogSearchIndex end
    local index = {}
    local function Add(rank, label, context, searchText, entry)
        entry.rank       = rank
        entry.label      = label
        entry.labelLower = label:lower()
        entry.display = context
            and (label .. " |cff888888-- " .. context .. "|r")
            or label
        entry.search  = searchText:lower()
        index[#index + 1] = entry
    end
    for _, instanceKind in ipairs({ "raid", "dungeon" }) do
        local kindLabel = (instanceKind == "dungeon")
            and RR.L["Dungeons"] or RR.L["Raids"]
        local byExpansion = UI.EnumerateInstances(instanceKind)
        for expansionName, instances in pairs(byExpansion) do
            if instances[1] then
                Add(0, RR.L[expansionName], kindLabel,
                    RR.L[expansionName] .. " " .. expansionName,
                    { instanceKind = instanceKind,
                      expansion = expansionName,
                      key = UI.BrowserKeyOf(instances[1]), bossIndex = 1 })
            end
            for _, instance in ipairs(instances) do
                local key = UI.BrowserKeyOf(instance)
                local instanceName = RR:GetLocalizedRaidName(instance)
                                     or instance.name or "?"
                Add(1, instanceName, RR.L[expansionName],
                    instanceName .. " " .. (instance.name or ""),
                    { instanceKind = instanceKind, expansion = expansionName,
                      key = key, bossIndex = 1 })
                for bossIndex, boss in ipairs(instance.bosses or {}) do
                    local bossName = RR:GetLocalizedBossName(boss)
                                     or boss.name or "?"
                    Add(2, bossName, instanceName,
                        bossName .. " " .. (boss.name or ""),
                        { instanceKind = instanceKind,
                          expansion = expansionName, key = key,
                          bossIndex = bossIndex })
                    for _, item in ipairs(boss.loot or {}) do
                        if item.name then
                            Add(3, item.name,
                                bossName .. ", " .. instanceName, item.name,
                                { instanceKind = instanceKind,
                                  expansion = expansionName, key = key,
                                  bossIndex = bossIndex, itemID = item.id,
                                  itemClasses = item.classes,
                                  itemEquipClasses = item.equipClasses,
                                  section = (item.hardModeOnly and "hardmode")
                                      or (item.faction and "faction")
                                      or nil })
                        end
                    end
                end
                local trashLabel = (RR.L["Trash Drops:"]):gsub("[:：]%s*$", "")
                -- Named rares, events and map markers search like bosses
                -- and land on the trash section that lists their drops.
                local namedSeen = {}
                local function AddNamed(name, context)
                    if not name or namedSeen[name] then return end
                    namedSeen[name] = true
                    local shown = RR.L[name]
                    Add(2, shown, context .. ", " .. instanceName,
                        shown .. " " .. name,
                        { instanceKind = instanceKind,
                          expansion = expansionName, key = key,
                          bossIndex = 1, section = "trash" })
                end
                for _, item in ipairs(instance.trashLoot or {}) do
                    AddNamed(item.rareNpc, RR.L["Rare"])
                    AddNamed(item.eventNpc, RR.L["Event"])
                    AddNamed(item.tag, RR.L["Trash Drops:"]:gsub("[:：]%s*$", ""))
                end
                for _, poi in ipairs(instance.pois or {}) do
                    AddNamed(poi.rareNpc, RR.L["Rare"])
                    AddNamed(poi.mapLabel, RR.L["Map marker"])
                end
                for _, item in ipairs(instance.trashLoot or {}) do
                    if item.name then
                        Add(3, item.name,
                            trashLabel .. ", " .. instanceName, item.name,
                            { instanceKind = instanceKind,
                              expansion = expansionName, key = key,
                              bossIndex = 1, itemID = item.id,
                              itemClasses = item.classes,
                              itemEquipClasses = item.equipClasses,
                              section = "trash" })
                    end
                end
            end
        end
    end
    UI._tmogSearchIndex = index
    return index
end

-- Case-insensitive substring query against the index. Returns up to
-- maxResults entries plus the count left off, or nil when the query is
-- under two characters. Ordered by match closeness first -- an exact name
-- beats a prefix beats a mid-name hit -- then expansions, instances,
-- bosses, items, then name.
UI.QueryTmogSearch = function(query, maxResults)
    query = (query or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if #query < 2 then return nil end
    local matches = {}
    for _, entry in ipairs(UI.BuildTmogSearchIndex()) do
        local position = entry.search:find(query, 1, true)
        if position then
            entry.matchQuality = (entry.labelLower == query and 3)
                or (position == 1 and 2) or 1
            matches[#matches + 1] = entry
        end
    end
    table.sort(matches, function(a, b)
        if a.matchQuality ~= b.matchQuality then
            return a.matchQuality > b.matchQuality
        end
        if a.rank ~= b.rank then return a.rank < b.rank end
        return a.label < b.label
    end)
    local overflow = 0
    if #matches > maxResults then
        overflow = #matches - maxResults
        for extraIndex = #matches, maxResults + 1, -1 do
            matches[extraIndex] = nil
        end
    end
    return matches, overflow
end

local function GetBrowserSelection()
    local raid = browserState.raidKey and UI.BrowserInstanceByKey(browserState.raidKey)
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
        instanceKind = browserState.instanceKind,
    })
end

local function EnsureBrowserDefaults()
    local byExpansion, expansions = UI.EnumerateInstances(browserState.instanceKind)
    if #expansions == 0 then return end

    -- First-priority defaults: load from SavedVariables if present. Validate
    -- that the saved raid still exists in RetroRuns_Data (the user might
    -- have removed a raid's data file since their last session).
    local saved = not browserState.raidKey and RR:GetSetting("browserSelection") or nil
    if saved then
        -- Restore the kind FIRST: the key only validates against the table
        -- that kind selects (a saved dungeon key is not in the raid table).
        local savedKind = saved.instanceKind or "raid"
        local entry
        if saved.raidKey then
            entry = (savedKind == "dungeon")
                and RR:GetDungeonByKey(saved.raidKey)
                or RR:GetRaidByInstanceID(saved.raidKey)
        end
        if entry then
            browserState.instanceKind = savedKind
            browserState.raidKey   = saved.raidKey
            browserState.expansion = saved.expansion or entry.expansion
            browserState.bossIndex = saved.bossIndex or 1
        end
    end

    if not browserState.raidKey and browserState.instanceKind == "raid" then
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
    local raid = browserState.raidKey and UI.BrowserInstanceByKey(browserState.raidKey)
    if not raid or not raid.bosses then return end
    for _, boss in ipairs(raid.bosses) do
        if boss.loot then
            for _, item in ipairs(boss.loot) do
                if item.id then C_Item.GetItemInfo(item.id) end
            end
        end
        if boss.specialLoot then
            for _, item in ipairs(boss.specialLoot) do
                if item.id then C_Item.GetItemInfo(item.id) end
            end
        end
        -- Footnote and omnitoken items live outside loot/specialLoot but
        -- still render as links, so they warm here too.
        if boss.tmogFootnote then
            if boss.tmogFootnote.itemID then
                C_Item.GetItemInfo(boss.tmogFootnote.itemID)
            end
            for _, itemID in ipairs(boss.tmogFootnote.itemIDs or {}) do
                C_Item.GetItemInfo(itemID)
            end
        end
        if boss.omniToken and boss.omniToken.itemID then
            C_Item.GetItemInfo(boss.omniToken.itemID)
        end
    end
end

-- GET_ITEM_INFO_RECEIVED fires once per item as WoW resolves async lookups, so
-- a cold cache means hundreds in succession. Coalesced to one repaint per
-- ~100ms, and only while the browser is visible.
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

    local tmogFrame = CreateFrame("Frame", "RetroRunsTmogWindow", UIParent, "BackdropTemplate")
    -- Initial size matches POPUP_CONTENT_MIN (240) rather than a guess like
    -- 460. AutoSize will grow the frame to fit actual content on first
    -- refresh; starting small means the first visible state after Show()
    -- is either correct or mid-growth, not a visible shrink-to-fit.
    tmogFrame:SetSize(UI.POPUP_DESIGN_W, POPUP_CONTENT_MIN)
    tmogFrame:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    -- Initial opacity reflects the user's saved setting so the first
    -- frame painted matches subsequent ApplySettings passes. Lazy
    -- windows construct after SavedVariables is loaded (user-action
    -- triggered), so reading the saved value here is safe.
    tmogFrame:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    tmogFrame:SetPoint("TOPLEFT", panel, "TOPRIGHT", 6, 0)
    tmogFrame:SetMovable(true)
    tmogFrame:EnableMouse(true)
    tmogFrame:RegisterForDrag("LeftButton")
    tmogFrame:SetScript("OnDragStart", tmogFrame.StartMoving)
    tmogFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Re-anchor by the top-left corner so a later expand/collapse grows
        -- the window downward from a fixed top, not outward from its center.
        local left, top = self:GetLeft(), self:GetTop()
        if left and top then
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
        end
    end)
    tmogFrame:SetClampedToScreen(true)
    tmogFrame:Hide()

    tmogFrame:HookScript("OnEnter", CancelTmogHide)
    tmogFrame:HookScript("OnLeave", ScheduleTmogHide)

    -- Hyperlink handlers: makes item links inside the loot rows (the
    -- tmogFootnote's item links) clickable. Same pattern used by
    -- panel.encounter for Special Loot links. SetItemRef is Blizzard's
    -- global router that opens the appropriate frame for each link type
    -- (item -> tooltip, achievement -> achievement frame, etc.) and is a
    -- no-op on link types it doesn't recognize, so safe as a catch-all.
    tmogFrame:SetHyperlinksEnabled(true)
    tmogFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        SetItemRef(link, text, button)
    end)
    tmogFrame:SetScript("OnHyperlinkEnter", function(self, link)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    tmogFrame:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

    local title = tmogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -10)
    title:SetText(RR.L["|cffF259C7RETRO|r|cff4DCCFFRUNS|r  Transmog"])
    SafeSetFont(title, RR:GetChromeFont(), 16, "")
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local closeBtn = UI.MakeRetroCloseButton(tmogFrame)
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function()
        browserState.active = false
        tmogFrame:Hide()
    end)

    -- The class filter is a view for as long as the browser is open, never a
    -- preference. Clearing on hide sends the next open back to the Default
    -- Transmog Filter setting.
    tmogFrame:HookScript("OnHide", function()
        browserState.classFilter = nil
        if tmogFrame.RefreshClassDropdown then
            tmogFrame:RefreshClassDropdown()
        end
    end)

    -- Three cascading dropdowns, Expansion / Raid / Boss, each resetting its
    -- successors when changed. `labelText` puts a caption to the bar's left.
    local function MakeDD(name, width, parent, labelText)
        local dd = CreateFrame("DropdownButton", "RetroRuns" .. name .. "DD", parent,
                               "WowStyle1DropdownTemplate")
        dd:SetWidth(width)
        UI.StyleDropdown(dd)
        if labelText then
            local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            lbl:SetText(labelText)
            -- Right-justified so every caption sits the same distance from its
            -- bar. Left-justified inside a fixed-width box, a short caption
            -- ("Exp:") drifts far from its bar while a long one hugs it.
            lbl:SetJustifyH("RIGHT")
            dd.label = lbl
        end
        return dd
    end

    -- Caption column on the left, bars to its right. Labels are left-aligned
    -- starting at LABEL_LEFT; bars are sized to fit the longest real content
    -- (Exp/Class are the narrow "1" slots, Raid/Boss the wider "2" slots) so
    -- there's no dead space inside the bar after the text.
    local LABEL_LEFT = 14   -- left margin where captions start
    local LABEL_GAP  = 4    -- gap between the caption column and the bars
    -- Measure the widest caption so the column is exactly as wide as it needs
    -- to be (a guessed fixed width either clipped "Class:" or left a gap).
    local capMeasure = tmogFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    capMeasure:Hide()
    local LABEL_W = 0
    for _, cap in ipairs({ RR.L["Exp:"], RR.L["Type:"], RR.L["Inst:"], RR.L["Boss:"], RR.L["Class:"] }) do
        capMeasure:SetText(cap)
        local textWidth = capMeasure:GetStringWidth() or 0
        if textWidth > LABEL_W then LABEL_W = textWidth end
    end
    LABEL_W = math.ceil(LABEL_W)
    -- The bar's frame edge is its visible edge.
    local DD_INSET   = 0

    local ddExp  = MakeDD("Expansion", 110, tmogFrame, RR.L["Exp:"])
    -- Raids-or-dungeons switch. Sits under the expansion bar so the
    -- cascade reads Exp -> Type -> Raid -> Boss -> Class.
    local ddType = MakeDD("InstanceKind", 110, tmogFrame, RR.L["Type:"])
    local ddRaid = MakeDD("Raid",      185, tmogFrame, RR.L["Inst:"])
    local ddBoss = MakeDD("Boss",      185, tmogFrame, RR.L["Boss:"])

    -- Bars: stacked, each stepped slightly right of the one above so the
    -- left edges cascade top-to-bottom. Exp anchors to the frame; Raid,
    -- Boss, and Class each inset by DD_STEP from their predecessor.
    local barVisibleLeft = LABEL_LEFT + LABEL_W + LABEL_GAP
    local barLeft = barVisibleLeft - DD_INSET
    local DD_STEP = 5
    ddExp:SetPoint("TOPLEFT",  tmogFrame,     "TOPLEFT",     barLeft, -32)
    ddType:SetPoint("TOPLEFT", ddExp, "BOTTOMLEFT",  DD_STEP,  -2)
    ddRaid:SetPoint("TOPLEFT", ddType, "BOTTOMLEFT", DD_STEP,  -2)
    ddBoss:SetPoint("TOPLEFT", ddRaid, "BOTTOMLEFT", DD_STEP,  -2)

    -- Labels: anchored to each bar's own left edge with a fixed gap, so
    -- they cascade rightward in step with the indented bars.
    local function anchorLabel(dd)
        if not dd.label then return end
        dd.label:ClearAllPoints()
        dd.label:SetPoint("RIGHT", dd, "LEFT", DD_INSET - LABEL_GAP, 0)
        dd.label:SetWidth(LABEL_W)
    end
    anchorLabel(ddExp); anchorLabel(ddType); anchorLabel(ddRaid); anchorLabel(ddBoss)

    tmogFrame.ddExp, tmogFrame.ddRaid, tmogFrame.ddBoss = ddExp, ddRaid, ddBoss
    tmogFrame.ddType = ddType
    -- Left margin where below-dropdown content (loot list, legend, scroll
    -- region) aligns. Independent of the dropdowns' indented left edge.
    tmogFrame.contentMargin = 22

    -- Chooses which class's class-gated loot the browser shows: every class by
    -- localized name in its class color, plus "All classes". Defaults to the
    -- class being played.
    local ddClass = MakeDD("Class", 110, tmogFrame, RR.L["Class:"])
    ddClass:SetPoint("TOPLEFT", ddBoss, "BOTTOMLEFT", DD_STEP, -2)
    anchorLabel(ddClass)
    tmogFrame.ddClass = ddClass

    -- Search: a magnifying-glass button after the title toggles a floating
    -- input over the dropdown stack. Matches expansion, item, boss, and
    -- instance names across raids and dungeons; picking a result drives
    -- the dropdowns to it.
    do
        local searchIcon = CreateFrame("Button", nil, tmogFrame)
        searchIcon:SetSize(20, 20)
        -- Dropped 2px: the title's glyphs sit low in their box, so a true
        -- LEFT-RIGHT center reads high next to them.
        searchIcon:SetPoint("LEFT", title, "RIGHT", 6, -2)
        searchIcon:SetNormalTexture("Interface\\Common\\UI-Searchbox-Icon")
        searchIcon:SetHighlightTexture("Interface\\Common\\UI-Searchbox-Icon",
            "ADD")
        local iconTexture = searchIcon:GetNormalTexture()
        if iconTexture then
            iconTexture:SetVertexColor(0.95, 0.35, 0.78)
        end
        UI.AttachSearchSparkle(searchIcon)
        tmogFrame.searchIcon = searchIcon

        local searchBox = CreateFrame("EditBox", "RetroRunsTmogSearchBox",
            tmogFrame, "InputBoxTemplate")
        searchBox:SetAutoFocus(false)
        searchBox:SetSize(160, 20)
        -- On the title bar, right of the glass. The input template's left
        -- texture extends ~8px past the frame, so the gap is authored wide.
        searchBox:SetPoint("LEFT", searchIcon, "RIGHT", 12, 2)
        searchBox:SetFrameLevel(tmogFrame:GetFrameLevel() + 40)
        searchBox:SetMaxLetters(60)
        -- Dim placeholder naming the scope; clears as soon as anything is
        -- typed.
        searchBox.hint = searchBox:CreateFontString(nil, "OVERLAY",
            "GameFontDisableSmall")
        searchBox.hint:SetPoint("LEFT", 2, 0)
        searchBox.hint:SetText(RR.L["Search for Tmog"])
        searchBox:Hide()
        searchBox:HookScript("OnEnter", CancelTmogHide)
        searchBox:HookScript("OnLeave", ScheduleTmogHide)
        tmogFrame.searchBox = searchBox

        local function CloseSearch()
            searchBox:SetText("")
            searchBox:ClearFocus()
            searchBox:Hide()
            tmogFrame.searchResults:Hide()
        end
        searchIcon:SetScript("OnClick", function()
            if searchBox:IsShown() then
                CloseSearch()
            else
                searchBox:Show()
                searchBox:SetFocus()
            end
        end)
        searchIcon:SetScript("OnEnter", function(self)
            CancelTmogHide()
            -- Suppressed once the box is open; see the minimized bar's copy.
            if searchBox:IsShown() then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(RR.L["Search"], 1, 1, 1)
            GameTooltip:Show()
        end)
        searchIcon:SetScript("OnLeave", function()
            GameTooltip:Hide()
            ScheduleTmogHide()
        end)

        -- Result list floats over the content region, dropdown-style.
        local results = CreateFrame("Frame", nil, tmogFrame,
            "BackdropTemplate")
        results:SetBackdrop({
            bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        results:SetBackdropColor(0.05, 0.05, 0.05, 0.97)
        results:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -6, -2)
        results:SetFrameLevel(tmogFrame:GetFrameLevel() + 40)
        results:EnableMouse(true)
        results:Hide()
        results:HookScript("OnEnter", CancelTmogHide)
        results:HookScript("OnLeave", ScheduleTmogHide)
        tmogFrame.searchResults = results

        local RESULT_MAX = 8
        local RESULT_ROW_H = 16
        local RESULT_PAD = 8
        local rowButtons = {}
        -- One trailing line serves both the overflow count and the
        -- no-matches state.
        local footLine = results:CreateFontString(nil, "OVERLAY",
            "GameFontDisableSmall")
        footLine:SetJustifyH("LEFT")
        footLine:Hide()

        local function SelectSearchResult(entry)
            browserState.instanceKind = entry.instanceKind
            browserState.expansion    = entry.expansion
            browserState.raidKey      = entry.key
            browserState.bossIndex    = entry.bossIndex or 1
            -- A result inside a collapsed section opens that section, so
            -- the row the jump lands on is actually visible.
            if entry.section == "trash" then
                tmogFrame._trashExpanded = true
            elseif entry.section == "legacy" then
                tmogFrame._legacyExpanded = true
            elseif entry.section == "hardmode" then
                tmogFrame._hardmodeExpanded = true
            elseif entry.section == "faction" then
                tmogFrame._factionExpanded = true
                tmogFrame._factionTierExpanded = true
            end
            -- A class-gated result switches the class filter when the
            -- current view would hide it. Equip-gated rows skip the switch
            -- when the viewed class wears nothing in the target list --
            -- the exemption already shows every row there.
            local classGate = entry.itemClasses or entry.itemEquipClasses
            if classGate then
                local filterClass = ActiveClassFilter()
                local rowVisible = not filterClass
                if filterClass then
                    for _, classID in ipairs(classGate) do
                        if classID == filterClass then
                            rowVisible = true
                            break
                        end
                    end
                end
                if not rowVisible and entry.itemEquipClasses
                   and not entry.itemClasses then
                    local instance = UI.BrowserInstanceByKey(entry.key)
                    local lootList
                    if entry.section == "trash" then
                        lootList = instance and instance.trashLoot
                    else
                        local boss = instance and instance.bosses
                                     and instance.bosses[entry.bossIndex]
                        lootList = boss and boss.loot
                    end
                    if UI.EquipGateExemptFor(lootList, filterClass) then
                        rowVisible = true
                    end
                end
                if not rowVisible then
                    browserState.classFilter = classGate[1]
                end
            end
            tmogFrame._searchHighlight = entry.itemID
                and { itemID = entry.itemID } or nil
            CloseSearch()
            tmogFrame:RefreshAll()
        end
        -- The panel's in-run search lands a picked result here, so a jump
        -- from either glass takes the same path.
        tmogFrame.SelectSearchEntry = SelectSearchResult

        local function GetResultButton(idx)
            local btn = rowButtons[idx]
            if btn then return btn end
            btn = CreateFrame("Button", nil, results)
            btn:SetHeight(RESULT_ROW_H)
            btn:SetPoint("TOPLEFT", results, "TOPLEFT", RESULT_PAD,
                -RESULT_PAD - (idx - 1) * RESULT_ROW_H)
            btn:SetPoint("RIGHT", results, "RIGHT", -RESULT_PAD, 0)
            local btnText = btn:CreateFontString(nil, "OVERLAY",
                "GameFontHighlightSmall")
            btnText:SetPoint("LEFT", 0, 0)
            btnText:SetJustifyH("LEFT")
            btn.text = btnText
            local highlightTex = btn:CreateTexture(nil, "HIGHLIGHT")
            highlightTex:SetAllPoints()
            highlightTex:SetColorTexture(1, 1, 1, 0.08)
            btn:SetScript("OnClick", function(self)
                if self.entry then SelectSearchResult(self.entry) end
            end)
            btn:HookScript("OnEnter", CancelTmogHide)
            btn:HookScript("OnLeave", ScheduleTmogHide)
            rowButtons[idx] = btn
            return btn
        end

        local function UpdateSearchResults()
            local matches, overflow =
                UI.QueryTmogSearch(searchBox:GetText(), RESULT_MAX)
            for _, btn in ipairs(rowButtons) do
                btn:Hide()
                btn.entry = nil
            end
            footLine:Hide()
            if not matches then
                results:Hide()
                return
            end
            local widest = 0
            local shown = 0
            for idx, entry in ipairs(matches) do
                local btn = GetResultButton(idx)
                btn.entry = entry
                btn.text:SetText(entry.display)
                btn:Show()
                local textWidth = btn.text:GetStringWidth() or 0
                if textWidth > widest then widest = textWidth end
                shown = idx
            end
            local lines = shown
            local footText
            if shown == 0 then
                footText = RR.L["No matches."]
            elseif overflow > 0 then
                footText = (RR.L["+%d more"]):format(overflow)
            end
            if footText then
                footLine:SetText(footText)
                footLine:ClearAllPoints()
                footLine:SetPoint("TOPLEFT", results, "TOPLEFT", RESULT_PAD,
                    -RESULT_PAD - shown * RESULT_ROW_H)
                footLine:Show()
                local textWidth = footLine:GetStringWidth() or 0
                if textWidth > widest then widest = textWidth end
                lines = lines + 1
            end
            results:SetSize(
                math.min(360, math.max(searchBox:GetWidth() + 12,
                    widest + RESULT_PAD * 2 + 4)),
                lines * RESULT_ROW_H + RESULT_PAD * 2)
            results:Show()
        end

        searchBox:SetScript("OnTextChanged", function(self, userInput)
            -- Unconditional, for the same reason as the instance search.
            self.hint:SetShown(self:GetText() == "")
            if userInput then UpdateSearchResults() end
        end)
        searchBox:SetScript("OnEscapePressed", CloseSearch)
        searchBox:SetScript("OnEnterPressed", function()
            local firstBtn = rowButtons[1]
            if firstBtn and firstBtn:IsShown() and firstBtn.entry then
                SelectSearchResult(firstBtn.entry)
            end
        end)
        tmogFrame:HookScript("OnHide", function()
            CloseSearch()
            tmogFrame._searchHighlight = nil
            if tmogFrame.searchHighlightBand then
                tmogFrame.searchHighlightBand:Hide()
            end
        end)
    end

    -- Sizes each dropdown bar by MEASURING its widest candidate with a hidden
    -- FontString at the dropdown's own font, plus padding. Expansion measures
    -- against the full expansion-order constant, including expansions with no
    -- data yet. Re-runnable on every RefreshDropdowns.
    local measureFS = tmogFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    measureFS:Hide()
    -- Measure at the bar's own font so the fit survives a template change.
    if ddExp.Text and ddExp.Text.GetFontObject and ddExp.Text:GetFontObject() then
        measureFS:SetFontObject(ddExp.Text:GetFontObject())
    end
    local function widestStringWidth(strings)
        local maxW = 0
        for _, s in ipairs(strings) do
            measureFS:SetText(s or "")
            local textWidth = measureFS:GetStringWidth() or 0
            if textWidth > maxW then maxW = textWidth end
        end
        return maxW
    end

    tmogFrame.SizeDropdownsToContent = function(self)
        -- ARROW_PAD covers the bar's arrow plus its inner text margins, so
        -- the arrow never overlaps the longest string.
        local ARROW_PAD = 34

        -- Measured once per session. The Encounter Journal walk below is
        -- too slow for the script time limit in combat, so a combat
        -- measurement uses the authored names and is redone out of combat.
        local widths = self._dropdownWidths
        if widths and not widths.provisional then
            ddRaid:SetWidth(widths.wide)
            ddBoss:SetWidth(widths.wide)
            ddExp:SetWidth(widths.narrow)
            ddClass:SetWidth(widths.narrow)
            return
        end
        local inCombat = InCombatLockdown and InCombatLockdown() or false

        -- Expansion: full constant list (future names included), measured
        -- as displayed -- the dropdown renders localized names where the
        -- locale carries them.
        local localizedExpansions = {}
        for i, expansionName in ipairs(EXPANSION_ORDER_NEWEST_FIRST) do
            localizedExpansions[i] = RR.L[expansionName]
        end
        local expW = widestStringWidth(localizedExpansions)

        -- Raid + Boss: every current raid and boss name.
        local raidNames, bossNames = {}, {}
        for _, dataTable in ipairs({ RetroRuns_Data, RetroRuns_DungeonData }) do
            for _, raid in pairs(dataTable or {}) do
                if raid.instanceID and raid.instanceID > 0 then
                    raidNames[#raidNames + 1] = RR:GetLocalizedRaidName(raid) or ""
                    for _, boss in ipairs(raid.bosses or {}) do
                        bossNames[#bossNames + 1] = inCombat and boss.name
                            or RR:GetLocalizedBossName(boss) or ""
                    end
                end
            end
        end
        local raidW = widestStringWidth(raidNames)
        local bossW = widestStringWidth(bossNames)

        -- Class: localized class names plus the "All classes" entry.
        local classNames = { RR.L["All classes"] }
        for classID = 1, 13 do
            if CLASS_ID_TO_TOKEN[classID] then
                classNames[#classNames + 1] = ClassNameForID(classID) or ""
            end
        end
        local classW = widestStringWidth(classNames)

        -- Pair the widths so the layout stays tidy: Raid and Boss share the
        -- wider of the two (the "2" slots), Exp and Class share the wider of
        -- those two (the "1" slots). This keeps clean uniform pairs while
        -- still fitting the longest content in each pair -- ragged per-bar
        -- widths would look messy.
        local wide   = math.ceil(math.max(raidW, bossW)) + ARROW_PAD
        local narrow = math.ceil(math.max(expW, classW)) + ARROW_PAD
        self._dropdownWidths = { wide = wide, narrow = narrow,
                                 provisional = inCombat }
        ddRaid:SetWidth(wide)
        ddBoss:SetWidth(wide)
        ddExp:SetWidth(narrow)
        ddClass:SetWidth(narrow)
    end

    -- Class display order for the dropdown: ascending class ID, matching the
    -- by-class sort used in the loot list. Only IDs that resolve to a real
    -- class token are shown (so the list stays correct across game versions).
    local CLASS_FILTER_ORDER = {}
    for classID = 1, 13 do
        if CLASS_ID_TO_TOKEN[classID] then
            CLASS_FILTER_ORDER[#CLASS_FILTER_ORDER + 1] = classID
        end
    end

    -- Localized, class-colored label for a class ID. Falls back to a plain
    -- name (or the raw ID) if color/localization tables aren't ready.
    local function ClassFilterLabel(classID)
        local name  = ClassNameForID(classID) or tostring(classID)
        local token = CLASS_ID_TO_TOKEN[classID]
        local hex   = "ffffffff"
        if token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token] then
            local classColor = RAID_CLASS_COLORS[token]
            if classColor.colorStr then hex = classColor.colorStr end
        end
        return ("|c%s%s|r"):format(hex, name)
    end

    tmogFrame.RefreshClassDropdown = function(self)
        local active = ActiveClassFilter()   -- nil = all classes
        ddClass:SetupMenu(function(_, rootDescription)
            -- "All classes" first.
            UI.MenuRadio(rootDescription, RR.L["All classes"],
                function() return ActiveClassFilter() == nil end,
                function()
                    browserState.classFilter = 0
                    if tmogFrame.RefreshAll then tmogFrame:RefreshAll() end
                end)
            for _, classID in ipairs(CLASS_FILTER_ORDER) do
                UI.MenuRadio(rootDescription, ClassFilterLabel(classID),
                    function() return ActiveClassFilter() == classID end,
                    function()
                        browserState.classFilter = classID
                        if tmogFrame.RefreshAll then tmogFrame:RefreshAll() end
                    end)
            end
        end)
        if active == nil then
            UI.SetDropdownText(ddClass, RR.L["All classes"])
        else
            UI.SetDropdownText(ddClass, ClassFilterLabel(active))
        end
    end

    -- Scrollable content region. The per-boss appearance list can run long
    -- (a full class's worth of shared-armor sets, or every class's gear when
    -- "show all" is on), past any sane fixed height. A ScrollFrame holds the
    -- content + sanctum line so the list scrolls; the color legend below is a
    -- FIXED footer on the popup itself, so it never scrolls out of view.
    -- Pattern mirrors the What's New page in SettingsCanvas.
    local scroll = CreateFrame("ScrollFrame", "RetroRunsTmogScroll", tmogFrame,
                               "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOP",  ddClass, "BOTTOM", 0, -10)
    scroll:SetPoint("LEFT", tmogFrame, "LEFT", 22, 0)
    -- Initial size is a placeholder; AutoSize clears these points and re-sizes
    -- the scroll region every layout pass (TOP from the dropdown stack, LEFT
    -- from the frame's content margin, explicit width and height = exactly the
    -- content viewport, so range is zero when content fits). -28 right inset
    -- leaves room for the scrollbar.
    scroll:SetPoint("BOTTOMRIGHT", tmogFrame, "BOTTOMRIGHT", -28, 40)
    scroll:HookScript("OnEnter", CancelTmogHide)
    scroll:HookScript("OnLeave", ScheduleTmogHide)
    tmogFrame.contentScroll = scroll

    -- Resolve this scroll's scrollbar across client versions. Older clients
    -- expose it as the global "<name>ScrollBar"; modern (10.x+) ones attach
    -- it as a `.ScrollBar` child on the ScrollFrame. Return whichever exists.
    local function ResolveScrollBar()
        return scroll.ScrollBar or _G["RetroRunsTmogScrollScrollBar"]
    end
    tmogFrame.ResolveTmogScrollBar = ResolveScrollBar

    -- Persistent guard that re-hides the scrollbar whenever there is no range.
    -- The template re-shows it from several internal paths, any of which can
    -- fire a frame after the layout pass hides it. Installed lazily, since the
    -- bar may not exist until the template finishes setup.
    local barGuardInstalled = false
    local function EnsureBarGuard()
        if barGuardInstalled then return end
        local bar = ResolveScrollBar()
        if not bar then return end
        bar:HookScript("OnShow", function(self)
            local range = scroll:GetVerticalScrollRange() or 0
            if not tmogFrame.tmogContentScrollable or range <= 1 then
                self:Hide()
            end
        end)
        barGuardInstalled = true
    end
    tmogFrame.EnsureTmogBarGuard = EnsureBarGuard

    -- Also react to the range-changed event directly: when the range drops to
    -- zero (switching from a long boss list to a short one), hide the bar and
    -- snap to top; when real range appears on genuinely scrollable content,
    -- show it. Visibility requires the layout's scrollability decision to
    -- agree -- the reported range alone can hold a small phantom value on
    -- content that fits.
    scroll:HookScript("OnScrollRangeChanged", function(self)
        EnsureBarGuard()
        local bar = ResolveScrollBar()
        if not bar then return end
        local range = self:GetVerticalScrollRange() or 0
        if tmogFrame.tmogContentScrollable and range > 1 then
            bar:Show()
        else
            bar:Hide()
            if self.SetVerticalScroll then self:SetVerticalScroll(0) end
        end
    end)

    local scrollChild = CreateFrame("Frame", "RetroRunsTmogScrollChild", scroll)
    scrollChild:SetSize(10, 10)   -- real size set per layout pass
    scroll:SetScrollChild(scrollChild)
    tmogFrame.contentChild = scrollChild

    -- Search-jump highlight: a fading band behind the loot row a search
    -- result landed on. The layout pass positions it; the fade clears it.
    do
        local band = scrollChild:CreateTexture(nil, "BACKGROUND")
        band:SetColorTexture(UI.FLASH_BAND_R, UI.FLASH_BAND_G,
            UI.FLASH_BAND_B, UI.FLASH_BAND_ALPHA)
        band:Hide()
        tmogFrame.searchHighlightBand = band
        local fade = band:CreateAnimationGroup()
        local fadeAlpha = fade:CreateAnimation("Alpha")
        fadeAlpha:SetFromAlpha(1)
        fadeAlpha:SetToAlpha(0)
        fadeAlpha:SetStartDelay(UI.FLASH_FADE_DELAY)
        fadeAlpha:SetDuration(UI.FLASH_FADE_DURATION)
        fade:SetScript("OnFinished", function()
            band:Hide()
            tmogFrame._searchHighlight = nil
        end)
        tmogFrame.searchHighlightFade = fade
    end

    -- The loot rows and sanctum line render into the scroll
    -- child, so item/achievement link clicks route through the child's
    -- hyperlink scripts, not the popup's. Mirror the popup's handlers here
    -- so links inside the scrolled content stay clickable.
    scrollChild:SetHyperlinksEnabled(true)
    scrollChild:SetScript("OnHyperlinkClick", function(_, link, linkText, button)
        SetItemRef(link, linkText, button)
    end)
    scrollChild:SetScript("OnHyperlinkEnter", function(self, link)
        CancelTmogHide()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    scrollChild:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
        ScheduleTmogHide()
    end)
    scrollChild:HookScript("OnEnter", CancelTmogHide)
    scrollChild:HookScript("OnLeave", ScheduleTmogHide)

    -- The loot lists render as pooled per-row widgets inside the scroll
    -- child: each item row is three cell FontStrings (state indicator,
    -- name, trailing tags) at computed column x-offsets, and text rows
    -- (difficulty line, token lines, footnotes, acquisition notes) take a
    -- full-width wrapping FontString. Same architecture as the
    -- Achievements window's row table, so columns line up by construction
    -- at any font or scale. Slots are reused across refreshes by index.
    local tmogRowPool = {}
    local function GetTmogRowSlot(idx)
        local slot = tmogRowPool[idx]
        if slot then return slot end
        slot = {}
        local function MakeCell(wrap)
            local cell = scrollChild:CreateFontString(nil, "OVERLAY",
                "GameFontHighlightSmall")
            cell:SetJustifyH("LEFT")
            cell:SetJustifyV("TOP")
            cell:SetWordWrap(wrap)
            cell:Hide()
            return cell
        end
        slot.indicator = MakeCell(false)
        slot.name      = MakeCell(false)
        slot.tags      = MakeCell(false)
        slot.wide      = MakeCell(true)
        tmogRowPool[idx] = slot
        return slot
    end
    local function HideTmogRowSlots()
        for _, slot in ipairs(tmogRowPool) do
            slot.indicator:Hide()
            slot.name:Hide()
            slot.tags:Hide()
            slot.wide:Hide()
        end
    end

    -- Dividers pool separately from the row cells: a list holds two or three
    -- of them against dozens of rows, so pairing each row slot with textures
    -- it will never draw wastes them.
    local tmogDividerPool = {}
    local function GetTmogDivider(idx)
        local divider = tmogDividerPool[idx]
        if not divider then
            divider = UI.MakeListDivider(scrollChild)
            tmogDividerPool[idx] = divider
        end
        return divider
    end
    local function HideTmogDividers()
        for _, divider in ipairs(tmogDividerPool) do
            UI.HideListDivider(divider)
        end
    end

    -- Hidden, unanchored FontString for measuring row cells at their
    -- natural (unwrapped) width. The layout pass applies the content font
    -- to it each refresh, so measurements always match what renders.
    local lineMeasure = tmogFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    lineMeasure:Hide()
    tmogFrame.lineMeasure = lineMeasure

    -- Sanctum vendor line, inside the scroll child so it travels with the
    -- content. Positioned by the layout pass below the main rows. Hidden
    -- when BuildSanctumLine returns nil.
    local sanctumLine = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sanctumLine:SetJustifyH("LEFT")
    sanctumLine:SetJustifyV("TOP")
    sanctumLine:SetWordWrap(true)
    sanctumLine:Hide()
    tmogFrame.sanctumLine = sanctumLine

    -- Raid trash-drops section: a collapsible header ("Trash Drops (N/M)")
    -- over pooled rows, inside the scroll child so they travel with the
    -- content. Positioned by the layout pass; the +/- toggle reuses the
    -- idle-list wing-expander helpers. Starts collapsed on every open (reset in
    -- UI.OpenTransmogBrowser).
    local trashHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    trashHeader:SetJustifyH("LEFT")
    trashHeader:SetJustifyV("TOP")
    trashHeader:Hide()
    tmogFrame.trashHeader = trashHeader

    local trashToggle = CreateFrame("Button", nil, scrollChild)
    trashToggle:RegisterForClicks("LeftButtonUp")
    trashToggle:SetFrameLevel((scrollChild:GetFrameLevel() or 0) + 10)
    -- Pink chevron glyph, same asset pair the LFR wing expanders use. Set up
    -- as _chevronTex/_chevronHL so panel.SetWingChevron drives the swap.
    local trashChevron = trashToggle:CreateTexture(nil, "ARTWORK")
    trashChevron:SetAllPoints(trashToggle)
    trashToggle._chevronTex = trashChevron
    local trashChevronHL = trashToggle:CreateTexture(nil, "HIGHLIGHT")
    trashChevronHL:SetAllPoints(trashToggle)
    trashChevronHL:SetVertexColor(1, 1, 1, 0.3)
    trashToggle._chevronHL = trashChevronHL
    trashToggle:Hide()
    trashToggle:HookScript("OnEnter", CancelTmogHide)
    trashToggle:HookScript("OnLeave", ScheduleTmogHide)
    trashToggle:SetScript("OnClick", function()
        tmogFrame._trashExpanded = not tmogFrame._trashExpanded
        tmogFrame:RefreshContent()
    end)
    tmogFrame.trashToggle = trashToggle

    -- Legacy-wing section. Same collapsible shape as Trash Drops, with a
    -- data-authored label instead of a fixed one.
    local legacyHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    legacyHeader:SetJustifyH("LEFT")
    legacyHeader:SetJustifyV("TOP")
    legacyHeader:Hide()
    tmogFrame.legacyHeader = legacyHeader

    local legacyToggle = CreateFrame("Button", nil, scrollChild)
    legacyToggle:RegisterForClicks("LeftButtonUp")
    legacyToggle:SetFrameLevel((scrollChild:GetFrameLevel() or 0) + 10)
    local legacyChevron = legacyToggle:CreateTexture(nil, "ARTWORK")
    legacyChevron:SetAllPoints(legacyToggle)
    legacyToggle._chevronTex = legacyChevron
    local legacyChevronHL = legacyToggle:CreateTexture(nil, "HIGHLIGHT")
    legacyChevronHL:SetAllPoints(legacyToggle)
    legacyChevronHL:SetVertexColor(1, 1, 1, 0.3)
    legacyToggle._chevronHL = legacyChevronHL
    legacyToggle:Hide()
    legacyToggle:HookScript("OnEnter", CancelTmogHide)
    legacyToggle:HookScript("OnLeave", ScheduleTmogHide)
    legacyToggle:SetScript("OnClick", function()
        tmogFrame._legacyExpanded = not tmogFrame._legacyExpanded
        tmogFrame:RefreshContent()
    end)
    tmogFrame.legacyToggle = legacyToggle

    -- "Tier / Token Info" subsection toggle: the same chevron pair, riding
    -- the gem divider that heads the subsection instead of a text header.
    local tierInfoToggle = CreateFrame("Button", nil, scrollChild)
    tierInfoToggle:RegisterForClicks("LeftButtonUp")
    tierInfoToggle:SetFrameLevel((scrollChild:GetFrameLevel() or 0) + 10)
    -- The button spans the whole header row as the hit area; the chevron
    -- textures are positioned beside the label at draw time rather than
    -- stretched across the button.
    local tierInfoChevron = tierInfoToggle:CreateTexture(nil, "ARTWORK")
    tierInfoToggle._chevronTex = tierInfoChevron
    local tierInfoChevronHL = tierInfoToggle:CreateTexture(nil, "HIGHLIGHT")
    tierInfoChevronHL:SetVertexColor(1, 1, 1, 0.3)
    tierInfoToggle._chevronHL = tierInfoChevronHL
    tierInfoToggle:Hide()
    tierInfoToggle:HookScript("OnEnter", CancelTmogHide)
    tierInfoToggle:HookScript("OnLeave", ScheduleTmogHide)
    tierInfoToggle:SetScript("OnClick", function()
        tmogFrame._tierInfoExpanded = not tmogFrame._tierInfoExpanded
        tmogFrame:RefreshContent()
    end)
    tmogFrame.tierInfoToggle = tierInfoToggle

    -- The subsection's own divider, styled as a SUB-divider once here: the
    -- rule and gems take RETRO cyan against the section dividers' pink,
    -- with smaller gems and a shorter rule. Collapsed it sits directly
    -- above the LOOT divider, and two same-colored gem rules stacked read
    -- as siblings. A dedicated widget rather than the shared pool, so the
    -- styling cannot leak onto the section dividers through reuse.
    local tierInfoDivider = UI.MakeListDivider(scrollChild)
    tierInfoDivider.left:SetVertexColor(C_BLUE[1], C_BLUE[2], C_BLUE[3], 0.45)
    tierInfoDivider.right:SetVertexColor(C_BLUE[1], C_BLUE[2], C_BLUE[3], 0.45)
    tierInfoDivider.gemLeft:SetVertexColor(C_BLUE[1], C_BLUE[2], C_BLUE[3], 1)
    tierInfoDivider.gemRight:SetVertexColor(C_BLUE[1], C_BLUE[2], C_BLUE[3], 1)
    tierInfoDivider.gemLeft:SetSize(UI.DIVIDER_SUBGEM_SIZE, UI.DIVIDER_SUBGEM_SIZE)
    tierInfoDivider.gemRight:SetSize(UI.DIVIDER_SUBGEM_SIZE, UI.DIVIDER_SUBGEM_SIZE)
    tmogFrame.tierInfoDivider = tierInfoDivider

    -- Boss-scoped collapsible sections: hard-mode-only rows and
    -- opposite-faction rows, same widget shape as the trash section.
    -- Headers are positioned by the layout pass, which chains whichever
    -- sections are visible for the selected boss.
    local function MakeSectionWidgets(flagKey)
        local header = scrollChild:CreateFontString(nil, "OVERLAY",
            "GameFontHighlightSmall")
        header:SetJustifyH("LEFT")
        header:SetJustifyV("TOP")
        header:Hide()
        local toggle = CreateFrame("Button", nil, scrollChild)
        toggle:RegisterForClicks("LeftButtonUp")
        toggle:SetFrameLevel((scrollChild:GetFrameLevel() or 0) + 10)
        local chevron = toggle:CreateTexture(nil, "ARTWORK")
        chevron:SetAllPoints(toggle)
        toggle._chevronTex = chevron
        local chevronHL = toggle:CreateTexture(nil, "HIGHLIGHT")
        chevronHL:SetAllPoints(toggle)
        chevronHL:SetVertexColor(1, 1, 1, 0.3)
        toggle._chevronHL = chevronHL
        toggle:Hide()
        toggle:HookScript("OnEnter", CancelTmogHide)
        toggle:HookScript("OnLeave", ScheduleTmogHide)
        toggle:SetScript("OnClick", function()
            tmogFrame[flagKey] = not tmogFrame[flagKey]
            tmogFrame:RefreshContent()
        end)
        return header, toggle
    end
    tmogFrame.hardmodeHeader, tmogFrame.hardmodeToggle =
        MakeSectionWidgets("_hardmodeExpanded")
    tmogFrame.taggedHeader, tmogFrame.taggedToggle =
        MakeSectionWidgets("_taggedExpanded")
    -- The opposite faction gets two sections: its tier beside the tier
    -- block, its ordinary drops at the foot. Separate widgets and separate
    -- expand flags, so folding one does not fold the other.
    tmogFrame.factionTierHeader, tmogFrame.factionTierToggle =
        MakeSectionWidgets("_factionTierExpanded")
    tmogFrame.factionHeader, tmogFrame.factionToggle =
        MakeSectionWidgets("_factionExpanded")

    -- Color legend. FIXED footer on the popup (NOT in the scroll child), so
    -- it stays pinned at the bottom while the content above it scrolls.
    -- Anchored to the popup's bottom in the layout pass.
    -- Divider above the legend, same white alpha-mask line and cyan gem the
    -- idle list and settings pages use. Fixed to the popup, not the scroll
    -- child, so it stays with the legend footer.
    local legendDivider = tmogFrame:CreateTexture(nil, "ARTWORK")
    legendDivider:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\divider-line")
    legendDivider:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 0.55)
    legendDivider:SetHeight(6)
    if legendDivider.SetTexelSnappingBias then
        legendDivider:SetTexelSnappingBias(0)
        legendDivider:SetSnapToPixelGrid(false)
    end
    tmogFrame.legendDivider = legendDivider

    local legendDividerGem = tmogFrame:CreateTexture(nil, "OVERLAY")
    legendDividerGem:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Panel\\divider-gem")
    legendDividerGem:SetSize(14, 14)
    legendDividerGem:SetPoint("CENTER", legendDivider, "CENTER", 0, 0)
    if legendDividerGem.SetTexelSnappingBias then
        legendDividerGem:SetTexelSnappingBias(0)
        legendDividerGem:SetSnapToPixelGrid(false)
    end
    tmogFrame.legendDividerGem = legendDividerGem

    local legendLine = tmogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    legendLine:SetPoint("BOTTOMLEFT",  tmogFrame, "BOTTOMLEFT",
        UI.TMOG_MARGIN_L, 12)
    legendLine:SetPoint("BOTTOMRIGHT", tmogFrame, "BOTTOMRIGHT",
        -UI.TMOG_LEGEND_PAD_R, 12)
    -- Vertical position comes from the legend text; the horizontal span is
    -- corrected off the text's own insets to RULE either side, so the gem
    -- lands on the frame's center rather than the text column's.
    legendDivider:SetPoint("BOTTOMLEFT",  legendLine, "TOPLEFT",
        UI.TMOG_RULE_INSET - UI.TMOG_MARGIN_L, 6)
    legendDivider:SetPoint("BOTTOMRIGHT", legendLine, "TOPRIGHT",
        UI.TMOG_LEGEND_PAD_R - UI.TMOG_RULE_INSET, 6)
    legendLine:SetJustifyH("LEFT")
    legendLine:SetJustifyV("TOP")
    legendLine:SetWordWrap(true)
    tmogFrame.legendLine = legendLine

    -- Anchored against the sanctum line's RENDERED width (GetStringWidth, not
    -- the FontString's frame width, which spans the popup) and parented to the
    -- scroll child so it travels with the line. Shown only when the player's
    -- covenant has a vendor with concrete coords.
    local sanctumBtn = CreateFrame("Button", nil, scrollChild)
    sanctumBtn:RegisterForClicks("LeftButtonUp")
    sanctumBtn:SetFrameLevel((scrollChild:GetFrameLevel() or 0) + 10)
    sanctumBtn:SetNormalTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\PlaneIcon")
    local planeTexture = sanctumBtn:GetNormalTexture()
    if planeTexture then
        planeTexture:SetVertexColor(C_PINK[1], C_PINK[2], C_PINK[3], 1)
    end
    sanctumBtn:SetHighlightTexture(
        "Interface\\AddOns\\RetroRuns\\Media\\Icons\\PlaneIcon", "ADD")
    sanctumBtn:Hide()
    sanctumBtn:HookScript("OnEnter", CancelTmogHide)
    sanctumBtn:HookScript("OnLeave", ScheduleTmogHide)
    tmogFrame.sanctumButton = sanctumBtn

    tmogWindow = tmogFrame

    -- Dropdown initializers (defined after tmogFrame exists so they can reference it).
    tmogFrame.RefreshDropdowns = function(self)
        EnsureBrowserDefaults()
        local byExp, expList = UI.EnumerateInstances(browserState.instanceKind)

        -- Type dropdown: raids or dungeons. Switching resets the selection
        -- into the new table; the expansion carries over when it exists
        -- there, otherwise falls to the first with content.
        ddType:SetupMenu(function(_, rootDescription)
            for _, kindEntry in ipairs({ { "raid", RR.L["Raids"] },
                                         { "dungeon", RR.L["Dungeons"] } }) do
                local kindValue, kindLabel = kindEntry[1], kindEntry[2]
                UI.MenuRadio(rootDescription, kindLabel,
                function() return browserState.instanceKind == kindValue end,
                function()
                    if browserState.instanceKind == kindValue then return end
                    browserState.instanceKind = kindValue
                    -- Select straight into the new table. A cleared key
                    -- reads as first-open to EnsureBrowserDefaults, which
                    -- would restore the saved selection and silently undo
                    -- the switch.
                    local newByExp, newExpList = UI.EnumerateInstances(kindValue)
                    if not newByExp[browserState.expansion] then
                        browserState.expansion = newExpList[1]
                    end
                    local first = newByExp[browserState.expansion]
                                  and newByExp[browserState.expansion][1]
                    browserState.raidKey   = first and UI.BrowserKeyOf(first) or nil
                    browserState.bossIndex = 1
                    SaveBrowserState()
                    tmogFrame:RefreshAll()
                end)
            end
        end)
        UI.SetDropdownText(ddType,
            browserState.instanceKind == "dungeon" and RR.L["Dungeons"] or RR.L["Raids"])

        -- Expansion dropdown
        ddExp:SetupMenu(function(_, rootDescription)
            for _, expName in ipairs(expList) do
                UI.MenuRadio(rootDescription, RR.L[expName],
                function() return expName == browserState.expansion end,
                function()
                    if browserState.expansion == expName then return end
                    browserState.expansion = expName
                    -- Pick first raid + first boss in the new expansion.
                    local first = byExp[expName] and byExp[expName][1]
                    browserState.raidKey   = first and UI.BrowserKeyOf(first) or nil
                    browserState.bossIndex = 1
                    tmogFrame:RefreshAll()
                end)
            end
        end)
        UI.SetDropdownText(ddExp, RR.L[browserState.expansion or "(none)"])

        -- Raid dropdown (within current expansion)
        ddRaid:SetupMenu(function(_, rootDescription)
            local raids = byExp[browserState.expansion] or {}
            for _, raid in ipairs(raids) do
                local entryKey = UI.BrowserKeyOf(raid)
                UI.MenuRadio(rootDescription,
                    RR:GetLocalizedRaidName(raid) or "?",
                    function() return entryKey == browserState.raidKey end,
                    function()
                        if browserState.raidKey == entryKey then return end
                        browserState.raidKey   = entryKey
                        browserState.bossIndex = 1
                        tmogFrame:RefreshAll()
                    end)
            end
        end)
        local raidName = "(none)"
        local selRaid = browserState.raidKey and UI.BrowserInstanceByKey(browserState.raidKey)
        if selRaid then raidName = RR:GetLocalizedRaidName(selRaid) or "?" end
        UI.SetDropdownText(ddRaid, raidName)

        -- Boss dropdown (within current raid)
        ddBoss:SetupMenu(function(_, rootDescription)
            local raid = browserState.raidKey and UI.BrowserInstanceByKey(browserState.raidKey)
            if not raid or not raid.bosses then return end
            for idx, boss in ipairs(raid.bosses) do
                UI.MenuRadio(rootDescription,
                    RR:GetLocalizedBossName(boss) or ("Boss " .. idx),
                    function() return idx == browserState.bossIndex end,
                    function()
                        if browserState.bossIndex == idx then return end
                        browserState.bossIndex = idx
                        UI.SetDropdownText(ddBoss, RR:GetLocalizedBossName(boss) or ("Boss " .. idx))
                        tmogFrame:RefreshContent()
                    end)
            end
        end)
        local bossName = "(none)"
        local _, selBoss = GetBrowserSelection()
        if selBoss then bossName = RR:GetLocalizedBossName(selBoss) or "?" end
        UI.SetDropdownText(ddBoss, bossName)

        -- Fit the bars to their content (measured, not guessed).
        if self.SizeDropdownsToContent then self:SizeDropdownsToContent() end
    end

    -- Lays the structured rows from BuildTransmogDetail into the pooled
    -- row widgets, positions the sanctum line and the collapsible section
    -- headers at absolute offsets in the scroll child, and stores the
    -- finished content height for AutoSize's viewport math. Runs once per
    -- RefreshContent; AutoSize never touches the row widgets, so
    -- heartbeat ticks cannot churn them out from under a click.
    local function LayoutTmogContent(self, detail, fontSize)
        local renderedSize = math.max(8, fontSize - 1)
        local measure = self.lineMeasure
        SetBodyFont(measure, renderedSize, "")
        local function MeasureText(rowText)
            measure:SetText(rowText or "")
            return measure:GetStringWidth() or 0
        end

        -- Row pitch: one rendered line of the body font. The space width
        -- probes as a difference of two measurements -- GetStringWidth of
        -- a whitespace-only string is 0 (FontStrings trim it).
        measure:SetText("Xg")
        local rowH = math.ceil(measure:GetStringHeight() or 0)
        if rowH < 1 then rowH = math.ceil(GetBodyFontSize(renderedSize)) + 2 end
        local spaceW = MeasureText("x x") - MeasureText("xx")
        if spaceW < 1 then spaceW = 3 end
        local nameGap = 2 * spaceW   -- indicator column -> name column
        local tagGap  = spaceW       -- name column -> tag column

        -- Section specs, in render order. The trash header carries its
        -- collected/total counter: yellow while anything is missing,
        -- collected-green at 100%.
        local trashHeaderText
        if detail.trashRows then
            local trashLabel = (RR.L["Trash Drops:"]):gsub("[:：]%s*$", "")
            if (detail.trashTotal or 0) > 0 then
                local trashCountHex = ((detail.trashCollected or 0) >= detail.trashTotal)
                    and "00ff00" or "ffd100"
                trashHeaderText = ("|cff%s%s|r |cff%s(%d/%d)|r"):format(
                    C_LABEL, trashLabel, trashCountHex,
                    detail.trashCollected or 0, detail.trashTotal)
            else
                -- Every row here is cross-listed and counted on its boss,
                -- so the header keeps its name and drops the counter.
                trashHeaderText = ("|cff%s%s|r"):format(C_LABEL, trashLabel)
            end
        end
        -- Same counter treatment as trash, over the instance's own label.
        local legacyHeaderText
        if detail.legacyRows and (detail.legacyTotal or 0) > 0
           and detail.legacyLabel then
            local legacyCountHex = ((detail.legacyCollected or 0) >= detail.legacyTotal)
                and "00ff00" or "ffd100"
            legacyHeaderText = ("|cff%s%s|r |cff%s(%d/%d)|r"):format(
                C_LABEL, RR.L[detail.legacyLabel], legacyCountHex,
                detail.legacyCollected or 0, detail.legacyTotal)
        end
        local factionLabel = (UnitFactionGroup
                and UnitFactionGroup("player") == "Alliance")
            and RR.L["Horde Appearances"] or RR.L["Alliance Appearances"]
        -- `key` lets a section be claimed by a marker row in the main list
        -- and drawn there instead of here at the foot.
        local sections = {
            { key = "hardmode",
              header = self.hardmodeHeader, toggle = self.hardmodeToggle,
              flag = "_hardmodeExpanded", rows = detail.hardModeRows,
              label = ("|cff%s%s|r"):format(C_LABEL, RR.L["Hard Mode"]) },
            { key = "tagged",
              header = self.taggedHeader, toggle = self.taggedToggle,
              flag = "_taggedExpanded", rows = detail.taggedRows,
              label = ("|cff%s%s|r"):format(C_LABEL,
                  RR.L[detail.taggedLabel or ""]) },
            { key = "factiontier",
              header = self.factionTierHeader, toggle = self.factionTierToggle,
              flag = "_factionTierExpanded", rows = detail.factionTierRows,
              label = ("|cff%s%s|r"):format(C_LABEL, factionLabel) },
            { key = "faction",
              header = self.factionHeader, toggle = self.factionToggle,
              flag = "_factionExpanded", rows = detail.factionRows,
              label = ("|cff%s%s|r"):format(C_LABEL, factionLabel) },
            { key = "trash",
              header = self.trashHeader, toggle = self.trashToggle,
              flag = "_trashExpanded", rows = detail.trashRows,
              label = trashHeaderText },
            { key = "legacy",
              header = self.legacyHeader, toggle = self.legacyToggle,
              flag = "_legacyExpanded", rows = detail.legacyRows,
              label = legacyHeaderText },
        }

        -- Measure pass over the lists that will actually render (a
        -- collapsed section contributes only its header). Rows in an
        -- alignment group take the group's widest indicator and name, so
        -- the whole group's tag column lands at one x-offset.
        local renderLists = { detail.mainRows or {} }
        for _, section in ipairs(sections) do
            if section.rows and #section.rows > 0 and section.label
               and self[section.flag] then
                table.insert(renderLists, section.rows)
            end
        end
        local maxRowW = 0
        -- Two column pairs per render list, one for the tier block and one for
        -- the loot below it. Every row in a block takes the same name and tag
        -- offsets, so tags form one straight column whatever class set a row
        -- carries. Tier and loot measure apart because the divider already
        -- reads them as separate tables: a single long loot name would
        -- otherwise push every tier tag far right of its own short names.
        -- Each section is its own render list, so expanding one cannot shift
        -- the others -- the measure pass only walks expanded sections.
        for _, rows in ipairs(renderLists) do
            local tierIndicatorW, tierNameW = 0, 0
            local lootIndicatorW, lootNameW = 0, 0
            for _, row in ipairs(rows) do
                if row.kind == "item" then
                    row.indicatorW = MeasureText(row.indicator)
                    row.nameW      = MeasureText(row.name)
                    row.tagsW      = (row.tags and row.tags ~= "")
                                     and MeasureText(row.tags) or 0
                    -- Every item row is measured, because the pass below
                    -- reads these widths unguarded. The caption borrows the
                    -- columns, so it alone is kept out of the maxima.
                    if not row.pairKey then
                        if row.isTier then
                            if row.indicatorW > tierIndicatorW then
                                tierIndicatorW = row.indicatorW
                            end
                            if row.nameW > tierNameW then
                                tierNameW = row.nameW
                            end
                        else
                            if row.indicatorW > lootIndicatorW then
                                lootIndicatorW = row.indicatorW
                            end
                            if row.nameW > lootNameW then
                                lootNameW = row.nameW
                            end
                        end
                    end
                elseif row.kind == "text" and not row.soft then
                    -- Prose rows (footnotes, acquisition notes) are
                    -- excluded: they wrap to the width the loot rows
                    -- set instead of stretching the popup to fit.
                    local rowWidth = MeasureText(row.text)
                    if rowWidth > maxRowW then maxRowW = rowWidth end
                end
            end
            for _, row in ipairs(rows) do
                if row.kind == "item" then
                    row.colIndicatorW = row.isTier and tierIndicatorW or lootIndicatorW
                    row.colNameW      = row.isTier and tierNameW or lootNameW
                    local rowWidth = row.colIndicatorW + nameGap + row.colNameW
                    if row.tagsW > 0 then
                        rowWidth = rowWidth + tagGap + row.tagsW
                    end
                    if rowWidth > maxRowW then maxRowW = rowWidth end
                end
            end
        end
        for _, section in ipairs(sections) do
            if section.rows and #section.rows > 0 and section.label then
                local headerWidth = MeasureText(section.label)
                if headerWidth > maxRowW then maxRowW = headerWidth end
            end
        end
        if self.sanctumLine:IsShown() then
            -- Measured per line: a multi-location hint carries newlines,
            -- and the column has to fit the widest of them.
            --
            -- A hint anchored to its last line is prose PLUS a destination.
            -- Measuring the prose stretched the popup to a whole
            -- paragraph's width, so only the destination line is measured
            -- there; the sentence wraps to the width the loot rows set,
            -- which is the treatment footnote rows already get.
            local sanctumWidth = 0
            local wrapProse = self._sanctumHint
                              and self._sanctumHint.buttonOnLastLine
            local hintLines = {}
            for hintLine in ((self.sanctumLine:GetText() or "")
                    .. "\n"):gmatch("(.-)\n") do
                table.insert(hintLines, hintLine)
            end
            for index, hintLine in ipairs(hintLines) do
                if not wrapProse or index == #hintLines then
                    local lineWidth = MeasureText(hintLine)
                    if lineWidth > sanctumWidth then
                        sanctumWidth = lineWidth
                    end
                end
            end
            -- The vendor travel button sits 4px past the line's text;
            -- reserve its width so the button never lands under the
            -- scrollbar gutter.
            if self.sanctumButton and self.sanctumButton:IsShown() then
                sanctumWidth = sanctumWidth + math.floor(fontSize * 1.4) + 4
            end
            if sanctumWidth > maxRowW then maxRowW = sanctumWidth end
        end

        -- Width first: the design width is a floor, and wrapping rows
        -- need the final viewport width before their heights can be read.
        local margin = self.contentMargin or 22
        local popupW = math.max(UI.POPUP_DESIGN_W,
            math.min(UI.POPUP_MAX_W, math.ceil(maxRowW) + margin + 28 + 2))
        self:SetWidth(popupW)
        local viewportW = math.max(1, popupW - margin - 28)
        self.contentChild:SetWidth(viewportW)
        -- Rules inset by RULE from BOTH frame edges, so they center on the
        -- frame rather than on this column (whose right side is the wider
        -- of the two, reserving scrollbar width).
        local ruleLeft = math.max(0, UI.TMOG_RULE_INSET - margin)
        local ruleW    = math.max(1, viewportW - ruleLeft)

        -- Layout walk: rows render top-down from y = 0 in the scroll
        -- child. Item rows are one line each; text and note rows wrap to
        -- the viewport and take their measured height.
        HideTmogRowSlots()
        self.tierInfoToggle:Hide()
        UI.HideListDivider(self.tierInfoDivider)
        HideTmogDividers()
        local y = 0
        local slotIdx = 0
        local dividerIdx = 0
        local lastNameX = nameGap
        local sanctumPlaced = false
        self._searchHighlightY = nil
        -- Positions the vendor hint (and its travel button) at the current
        -- y. Called from the "sanctum" marker row when the raid has tier,
        -- otherwise after the list.
        local function PlaceSanctumLine()
            if not self.sanctumLine:IsShown() then return end
            y = y - (self._sanctumNeedsGap and rowH or 2)
            local hintTop = y
            self.sanctumLine:ClearAllPoints()
            self.sanctumLine:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, y)
            self.sanctumLine:SetWidth(viewportW)
            local sanctumHeight = self.sanctumLine:GetStringHeight() or 0
            y = y - math.max(rowH, math.ceil(sanctumHeight))

            -- Travel button. A multi-line hint puts it at the end of the
            -- one line that names a routable destination; a single-line
            -- hint keeps the old end-of-line placement.
            local hint = self._sanctumHint
            if self.sanctumButton:IsShown() then
                local btnSize = self.sanctumButton:GetWidth() or rowH
                local lineIndex = (hint and hint.buttonLineIndex) or 0
                local lineText = (hint and hint.buttonLineText)
                    or self.sanctumLine:GetText()
                -- A hint whose earlier lines WRAP cannot be indexed from
                -- the top: lineIndex counts logical lines, the layout needs
                -- rendered ones. Anything anchored to the final line is
                -- measured from the bottom of the block instead, which holds
                -- however much the prose above it wrapped.
                self.sanctumButton:ClearAllPoints()
                if hint and hint.buttonOnLastLine then
                    -- Anchored to the string's own BOTTOM. Deriving the last
                    -- line's top from the block height assumed every rendered
                    -- line was exactly rowH tall, which floated the plane
                    -- above the text it belongs to once the prose wrapped.
                    -- The plane is taller than a line, so it hangs half its
                    -- excess below the baseline to sit centerd on it.
                    self.sanctumButton:SetPoint("BOTTOMLEFT", self.sanctumLine,
                        "BOTTOMLEFT", MeasureText(lineText) + 4,
                        math.floor((rowH - btnSize) / 2))
                else
                    local lineTop = hintTop - lineIndex * rowH
                    self.sanctumButton:SetPoint("TOPLEFT", scrollChild, "TOPLEFT",
                        MeasureText(lineText) + 4,
                        lineTop - math.floor((rowH - btnSize) / 2))
                end
            end
            sanctumPlaced = true
        end
        -- Forward declaration: a marker row inside EmitRows draws a section,
        -- and a section draws its own rows back through EmitRows.
        local DrawSection
        local placedSections = {}
        local function EmitRows(rows)
            for _, row in ipairs(rows) do
                if row.kind == "sanctum" then
                    PlaceSanctumLine()
                elseif row.kind == "section" then
                    for _, section in ipairs(sections) do
                        if section.key == row.section
                           and section.rows and #section.rows > 0
                           and section.label then
                            DrawSection(section)
                            placedSections[section.key] = true
                        end
                    end
                elseif row.kind == "blank" then
                    y = y - rowH
                elseif row.kind == "divider" then
                    dividerIdx = dividerIdx + 1
                    local divider = GetTmogDivider(dividerIdx)
                    local labelText = row.label and RR.L[row.label] or nil
                    if labelText then
                        SetBodyFont(divider.label, renderedSize, "")
                        labelText = ("|cff%s%s|r"):format(C_PINK_HEX, labelText)
                    end
                    y = y - UI.PlaceListDivider(divider, scrollChild, y,
                        ruleLeft, ruleW, rowH, labelText,
                        MeasureText(labelText), row.subtle)
                elseif row.kind == "tierinfo" then
                    -- Collapsible "Tier / Token Info" subsection: a titled
                    -- gem divider one font step smaller than the section
                    -- dividers, with the chevron riding just past the words.
                    -- Draws nothing when the only would-be content is a
                    -- vendor line that resolved empty for this boss.
                    local hasContent = false
                    for _, infoRow in ipairs(detail.tierInfoRows or {}) do
                        if infoRow.kind == "sanctum" then
                            if self.sanctumLine:IsShown() then hasContent = true end
                        else
                            hasContent = true
                        end
                    end
                    if hasContent then
                        local divider = self.tierInfoDivider
                        local headerSize = math.max(9, renderedSize - 2)
                        SetBodyFont(divider.label, headerSize, "")
                        local labelText = ("|cff4dccff%s|r"):format(
                            RR.L["Redemption Info"])
                        divider.label:SetText(labelText)
                        local textW = math.ceil(divider.label:GetStringWidth() or 0)
                        -- Sub-divider: the rule spans ~60% of the section
                        -- rules' width, centered, and the cluster reserves
                        -- chevron room so the right gem clears it.
                        local subW    = math.floor(ruleW * 0.6)
                        local subLeft = ruleLeft + math.floor((ruleW - subW) / 2)
                        local headerTop = y
                        y = y - UI.PlaceListDivider(divider, scrollChild, y,
                            subLeft, subW, rowH, labelText,
                            textW + 4 + headerSize)
                        -- Placement centered the gems for the full-size
                        -- asset; drop the smaller ones back onto the line.
                        local gemDrop = math.floor(
                            (UI.DIVIDER_GEM_SIZE - UI.DIVIDER_SUBGEM_SIZE) / 2)
                        for _, gem in ipairs({ divider.gemLeft, divider.gemRight }) do
                            local pt, rel, relPt, gx, gy = gem:GetPoint(1)
                            gem:SetPoint(pt, rel, relPt, gx, gy - gemDrop)
                        end
                        -- The whole header row is the hit area; the chevron
                        -- textures sit beside the words.
                        local toggle = self.tierInfoToggle
                        toggle:ClearAllPoints()
                        toggle:SetPoint("TOPLEFT", scrollChild, "TOPLEFT",
                            subLeft, headerTop - UI.DIVIDER_ABOVE)
                        toggle:SetSize(subW, rowH)
                        panel.SetWingChevron(toggle, self._tierInfoExpanded)
                        for _, chevron in ipairs({ toggle._chevronTex,
                                                   toggle._chevronHL }) do
                            chevron:ClearAllPoints()
                            chevron:SetSize(headerSize, headerSize)
                            chevron:SetPoint("LEFT", divider.label, "RIGHT", 4, 0)
                        end
                        toggle:Show()
                        if self._tierInfoExpanded then
                            EmitRows(detail.tierInfoRows)
                        end
                    end
                elseif row.kind == "item" then
                    slotIdx = slotIdx + 1
                    local slot = GetTmogRowSlot(slotIdx)
                    local nameX = (row.colIndicatorW or row.indicatorW) + nameGap
                    local tagsX = nameX + (row.colNameW or row.nameW) + tagGap
                    local indicatorText, tagsText = row.indicator, row.tags
                    local indicatorX, drawTags = 0, (row.tagsW or 0) > 0
                    if row.pairKey then
                        -- A real row's indicator reads "[ dot | dot ]", so the
                        -- dots sit a bracket in and a separator apart. The
                        -- caption draws no brackets, so it offsets by those
                        -- measured widths instead -- exact at any font size.
                        -- The "=" hangs in the indicator/name gap so the words
                        -- still begin on the name column.
                        local dotGlyph = UI.ProgressDotGlyph(DOT_INACTIVE)
                        -- Both widths probe as a difference against a
                        -- sentinel: GetStringWidth drops leading and
                        -- trailing spaces, so measuring "[ " or " || "
                        -- directly loses the very spaces being measured.
                        local sepW = math.max(1, math.floor(
                            MeasureText("x || x") - MeasureText("xx") + 0.5)
                            + UI.PAIRKEY_DOT_NUDGE)
                        indicatorText = dotGlyph
                            -- Texture escape takes HEIGHT then WIDTH.
                            -- Height stays 1: a spacer taller than the
                            -- line stretches the row.
                            .. ("|TInterface\\Common\\Spacer:1:%d|t")
                                :format(sepW)
                            .. dotGlyph
                        indicatorX = math.floor(
                            MeasureText("[ x") - MeasureText("x") + 0.5)
                        tagsText   = "|cff888888=|r"
                        tagsX      = nameX - MeasureText("=") - spaceW
                        drawTags   = true
                    end
                    SetBodyFont(slot.indicator, renderedSize, "")
                    slot.indicator:SetText(indicatorText)
                    slot.indicator:ClearAllPoints()
                    slot.indicator:SetPoint("TOPLEFT", scrollChild, "TOPLEFT",
                        indicatorX, y)
                    slot.indicator:Show()
                    SetBodyFont(slot.name, renderedSize, "")
                    slot.name:SetText(row.name)
                    slot.name:ClearAllPoints()
                    slot.name:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", nameX, y)
                    slot.name:Show()
                    if drawTags then
                        SetBodyFont(slot.tags, renderedSize, "")
                        slot.tags:SetText(tagsText)
                        slot.tags:ClearAllPoints()
                        slot.tags:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", tagsX, y)
                        slot.tags:Show()
                    end
                    if self._searchHighlight
                       and row.itemID == self._searchHighlight.itemID then
                        self._searchHighlightY = y
                    end
                    lastNameX = nameX
                    y = y - rowH
                elseif row.kind == "text" or row.kind == "note" then
                    slotIdx = slotIdx + 1
                    local slot = GetTmogRowSlot(slotIdx)
                    -- Notes indent to the name column of the row above.
                    local rowX = (row.kind == "note") and lastNameX or 0
                    SetBodyFont(slot.wide, renderedSize, "")
                    slot.wide:SetText(row.text)
                    slot.wide:ClearAllPoints()
                    slot.wide:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", rowX, y)
                    slot.wide:SetWidth(math.max(1, viewportW - rowX))
                    slot.wide:Show()
                    local wrappedHeight = slot.wide:GetStringHeight() or 0
                    y = y - math.max(rowH, math.ceil(wrappedHeight))
                end
            end
        end
        DrawSection = function(section)
            y = y - 10
            SetBodyFont(section.header, renderedSize, "")
            section.header:SetText(section.label)
            section.header:ClearAllPoints()
            section.header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, y)
            section.header:Show()
            section.toggle:SetSize(fontSize, fontSize)
            section.toggle:ClearAllPoints()
            section.toggle:SetPoint("LEFT", section.header, "LEFT",
                MeasureText(section.label) + 4, 0)
            panel.SetWingChevron(section.toggle, self[section.flag])
            section.toggle:Show()
            y = y - rowH
            if self[section.flag] then
                y = y - 2
                EmitRows(section.rows)
            end
        end

        -- Does any list carry a placement marker? If so the hint belongs
        -- where that marker sits, and must NOT also be emitted here --
        -- placing it twice left a gap above the section it was destined
        -- for, and showed it above a collapsed section.
        local hasSanctumMarker = false
        for _, rows in ipairs({ detail.mainRows or {},
                                detail.tierInfoRows or {},
                                detail.trashRows or {},
                                detail.hardModeRows or {},
                                detail.factionTierRows or {},
                                detail.factionRows or {},
                                -- Every list that can carry the marker has to
                                -- be here. A list left out reads as "no marker
                                -- anywhere", and the hint is then placed by the
                                -- fallback below -- above the sections rather
                                -- than under the block that owns it.
                                detail.legacyRows or {} }) do
            for _, row in ipairs(rows) do
                if row.kind == "sanctum" then hasSanctumMarker = true end
            end
        end

        EmitRows(detail.mainRows or {})

        -- Raids with no marker at all keep the old spot, below the list.
        if not sanctumPlaced and not hasSanctumMarker then PlaceSanctumLine() end

        -- Collapsible sections: header (plus chevron toggle just past its
        -- text), then the section's rows when expanded.
        for _, section in ipairs(sections) do
            if placedSections[section.key] then
                -- Already drawn inline, where its marker sat.
            elseif section.rows and #section.rows > 0 and section.label then
                DrawSection(section)
            else
                section.header:Hide()
                section.header:SetText("")
                section.toggle:Hide()
            end
        end

        -- The marker's section is collapsed, so its hint stays hidden with
        -- the rows it explains rather than floating above them.
        if not sanctumPlaced and hasSanctumMarker then
            self.sanctumLine:Hide()
            self.sanctumButton:Hide()
        end

        -- Search-jump highlight band, re-placed on every layout while
        -- active so async name fills cannot strand it on the wrong row.
        -- The scroll snaps to the row once, on the first layout after the
        -- jump; repaints leave the player's scroll position alone.
        local searchHit = self._searchHighlight
        local band = self.searchHighlightBand
        if band then
            if searchHit and self._searchHighlightY then
                band:ClearAllPoints()
                band:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0,
                    self._searchHighlightY)
                band:SetSize(viewportW, rowH)
                band:Show()
                if not searchHit.played then
                    searchHit.played = true
                    self._searchScrollTarget = -self._searchHighlightY
                    self.searchHighlightFade:Play()
                end
            else
                band:Hide()
            end
        end

        self.tmogContentH = -y
    end

    tmogFrame.RefreshContent = function(self)
        local raid, boss = GetBrowserSelection()
        local detail
        if boss then
            detail = BuildTransmogDetail({ boss = boss })
        else
            detail = { mainRows = { { kind = "text",
                text = RR.L["Select an instance and boss."] } } }
        end
        local fontSize = RR:GetSetting("fontSize", 12)
        -- Record the layout inputs this render used, so the heartbeat's
        -- rebuild gate in ApplySettings only fires on a real change.
        self._lastScale     = RR:GetSetting("windowScale", 1.0)
        self._lastFontSize  = fontSize
        self._lastFontStyle = RR:GetSetting("bodyFontStyle", "standard")

        -- A nil return hides both widgets. Text without vendorInfo means no
        -- covenant: the line shows, the Flight button doesn't.
        local sanctumText, sanctumRaid, sanctumCovID, sanctumVendor,
            sanctumKind, sanctumHint = BuildSanctumLine(raid, boss)
        -- A multi-line hint anchors its travel button to one specific
        -- line; the layout pass reads these back.
        self._sanctumHint = sanctumHint
        -- The covenant hint continues the weapon-token heading above it, so
        -- it sits tight; a token-vendor hint follows the loot list and needs
        -- a blank line to read as its own note.
        self._sanctumNeedsGap = (sanctumKind == "token"
                                 or sanctumKind == "omni")
        if sanctumText then
            SetBodyFont(sanctumLine, fontSize - 1, "")
            sanctumLine:SetText(sanctumText)
            sanctumLine:Show()
            -- A vendor standing inside the instance gets no travel button:
            -- waypoint providers cannot target an instance map, so the
            -- button could never route anywhere. Those raids carry a global
            -- map POI instead. A multi-line hint shows the button only when
            -- one of its lines names a routable destination.
            local routable = sanctumVendor and not sanctumVendor.insideRaid
            if sanctumHint and sanctumHint.travel then routable = true end
            if routable then
                -- Positioned by the layout pass, which knows each hint
                -- line's height and rendered width.
                local btnSize = math.floor(fontSize * 1.4)
                sanctumBtn:SetSize(btnSize, btnSize)
                sanctumBtn:SetScript("OnClick", function(selfBtn)
                    -- Waypoints cannot be placed from inside an instance,
                    -- so say so rather than routing into silence.
                    if IsInInstance and IsInInstance() then
                        ShowWaypointToast(selfBtn, RR.L["Zone out first"], nil, nil, true)
                        return
                    end
                    if sanctumHint and sanctumHint.travel then
                        -- Per-armor-type merchant: the browser resolved
                        -- which one from the class being viewed.
                        local target = sanctumHint.travel
                        RR:NavigateToDestination(target.mapID, target.x,
                            target.y,
                            (RR.L["RetroRuns: %s"]):format(
                                RR.L[target.vendorName or ""]),
                            sanctumRaid)
                    elseif sanctumKind == "token" then
                        RR:NavigateToTokenVendor(sanctumRaid)
                    else
                        RR:NavigateToSanctum(sanctumRaid, sanctumCovID)
                    end
                end)
                sanctumBtn:SetScript("OnEnter", function(selfBtn)
                    CancelTmogHide()
                    GameTooltip:SetOwner(selfBtn, "ANCHOR_RIGHT")
                    -- A hint can carry its own destination with no vendor
                    -- block behind it (the legacy-wing note names an object,
                    -- not a merchant), so every sanctumVendor read is guarded.
                    local hintTravel = sanctumHint and sanctumHint.travel
                    local travelName = (hintTravel and hintTravel.vendorName)
                        or (sanctumVendor and sanctumVendor.vendorName)
                    GameTooltip:SetText(
                        (RR.L["Travel to %s"]):format(
                            (travelName and RR.L[travelName])
                                or RR.L["Sanctum vendor"]),
                        1, 1, 1)
                    local spotSub = (hintTravel and hintTravel.zoneSub)
                        or (sanctumVendor and sanctumVendor.zoneSub)
                    local zoneMain = sanctumVendor
                        and RR.L[sanctumVendor.zoneMain or ""] or nil
                    local tooltipSpot
                    if spotSub and zoneMain and zoneMain ~= "" then
                        tooltipSpot = ("%s -- %s"):format(RR.L[spotSub], zoneMain)
                    else
                        tooltipSpot = (spotSub and RR.L[spotSub]) or zoneMain
                    end
                    if tooltipSpot and tooltipSpot ~= "" then
                        GameTooltip:AddLine(tooltipSpot, 0.7, 0.7, 0.7, true)
                    end
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

        -- Lay the structured rows into the pooled widgets. The sanctum
        -- line's shown state is already final, so the layout can measure
        -- and position it with the section headers.
        LayoutTmogContent(self, detail, fontSize)

        -- Legend: always rendered, text refreshed here. Position is fixed
        -- (a footer pinned to the popup bottom at construction), so it does
        -- not get re-anchored per boss -- it stays put while the content
        -- above it scrolls.
        SetBodyFont(legendLine, fontSize - 1, "")
        local legendText, legendLines =
            BuildTmogLegendText()
        legendLine:SetText(legendText)
        -- The popup sizer reserves the footer from this, so it must be set
        -- before AutoSize runs at the end of this function.
        self.legendLineCount = legendLines

        -- Refreshed here rather than in RefreshAll: the boss dropdown calls
        -- RefreshContent only, so this is what keeps the control correct on a
        -- boss-by-boss stepthrough.
        if self.RefreshClassDropdown then
            self:RefreshClassDropdown()
        end
        if self.RefreshClassDropdownEnabled then
            self:RefreshClassDropdownEnabled()
        end
        -- Fit the popup around the freshly laid-out content.
        UI.AutoSize()

        -- Bring a search-jump's row into view, roughly a third down the
        -- viewport. Runs after AutoSize so the scroll geometry is final.
        if self._searchScrollTarget then
            local scrollFrame = self.contentScroll
            if scrollFrame then
                local viewH = scrollFrame:GetHeight() or 0
                local maxScroll = math.max(0,
                    (self.tmogContentH or 0) - viewH)
                scrollFrame:SetVerticalScroll(math.max(0,
                    math.min(maxScroll,
                        self._searchScrollTarget - viewH / 3)))
            end
            self._searchScrollTarget = nil
        end
    end

    tmogFrame.RefreshAll = function(self)
        WarmBrowserItemCache()
        self:RefreshDropdowns()
        self:RefreshContent()
        SaveBrowserState()
    end

    -- The "show all class tier" checkbox and the class dropdown are both
    -- grayed on bosses with no class-gated loot, so the player sees that the
    -- control doesn't apply rather than clicking into a no-op.
    --
    -- Class-gated means tier tokens in tierSets.tokenSources, OR any row
    -- carrying `classes` or `equipClasses` -- both are hidden for off-class
    -- players, so the toggle has to be live for them too.
    tmogFrame.RefreshClassDropdownEnabled = function(self)
        local raid, boss = GetBrowserSelection()
        local hasClassFiltered = false
        if raid and boss then
            -- Test what the dropdown actually changes: rows it gates, and a
            -- redemption hint whose cost differs per class. Dropping a tier
            -- token does NOT imply either -- Temple's Imperial Qiraji weapon
            -- tokens and Castle Nathria's weapon pools serve every class, so
            -- rows and hint read the same whichever class is picked.
            if boss.loot then
                for _, item in ipairs(boss.loot) do
                    if item.classes or item.equipClasses then
                        hasClassFiltered = true
                        break
                    end
                end
            end
            local vendorInfo = raid.tokenVendors
            if not hasClassFiltered and vendorInfo and vendorInfo.locations then
                local raidGateOpen = true
                if vendorInfo.bosses then
                    raidGateOpen = false
                    for _, gatedIndex in ipairs(vendorInfo.bosses) do
                        if gatedIndex == boss.index then
                            raidGateOpen = true
                            break
                        end
                    end
                end
                if raidGateOpen then
                    for _, spot in ipairs(vendorInfo.locations) do
                        local spotHere = not spot.bosses
                        if spot.bosses then
                            for _, gatedIndex in ipairs(spot.bosses) do
                                if gatedIndex == boss.index then
                                    spotHere = true
                                    break
                                end
                            end
                        end
                        if spotHere and spot.byClass then
                            hasClassFiltered = true
                            break
                        end
                    end
                end
            end
        end
        if hasClassFiltered then
            ddClass:SetEnabled(true)
            ddClass:SetAlpha(1.0)
            if ddClass.label then ddClass.label:SetAlpha(1.0) end
        else
            ddClass:SetEnabled(false)
            ddClass:SetAlpha(0.45)
            if ddClass.label then ddClass.label:SetAlpha(0.45) end
            -- Replace the class name with an explicit unavailable marker so a
            -- disabled bar doesn't read as a still-selectable class. Runs
            -- after RefreshClassDropdown sets the name, so this wins.
            UI.SetDropdownText(ddClass, "N/A")
        end
    end

    -- Realtime collection-state refresh, debounced 50ms. The per-render
    -- appearance cache (in BuildTransmogDetail) auto-clears on next render.
    tmogFrame:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
    tmogFrame:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")
    tmogFrame:RegisterEvent("TRANSMOG_COLLECTION_UPDATED")
    -- Bind-on-equip trash rows carry an in-bags marker, so a loot or a sale
    -- has to repaint the window too. BAG_UPDATE_DELAYED rather than
    -- BAG_UPDATE: the latter fires once per bag on a single loot, and the
    -- debounce below would still let a five-bag character queue five
    -- refreshes.
    tmogFrame:RegisterEvent("BAG_UPDATE_DELAYED")

    local refreshPending = false
    tmogFrame:SetScript("OnEvent", function(self)
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

    return tmogFrame
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

-- Repaint the footer's center slot. While a run is being guided it carries
-- the "Toaster:" arrow -- green up = active (enabled + in a supported raid),
-- amber down = enabled but not in a supported raid, red down = disabled,
-- mirroring the settings panel's Active Status so both surfaces agree. On
-- the instance list it carries the hourly instance-limit counter instead.
-- Safe to call any time.
function UI.RefreshFooterStatus()
    local toastStatus   = panel.toastStatus
    local instanceLimit = panel.instanceLimit
    if not toastStatus or not toastStatus.arrow then return end

    -- There is no footer on the minimized bar. This runs on the heartbeat,
    -- so without the guard it shows the slot back over the bar every tick
    -- no matter what the minimize path hid.
    if UI.IsMinimized and UI.IsMinimized() then
        if instanceLimit then instanceLimit:Hide() end
        toastStatus:Hide()
        return
    end

    if instanceLimit and UI.IsShowingInstanceList and UI.IsShowingInstanceList() then
        toastStatus:Hide()
        local usedCount, freeSeconds, capLimit = RR:GetInstanceUseCount()
        -- Urgency colors the count on the headroom left, not on the count
        -- itself, so the reading matches the run-complete reset reminder.
        local remainingCount = math.max(0, capLimit - usedCount)
        local countColor = (remainingCount >= 5 and "|cff00ff00")
            or (remainingCount >= 2 and "|cffffff00")
            or "|cffff0000"
        -- No entries means nothing to expire, so the parenthetical drops
        -- rather than rendering a reset for a clock that is not running.
        local valueText = ("%s%d|r|cff9d9d9d/%d|r")
            :format(countColor, usedCount, capLimit)
        if freeSeconds then
            valueText = valueText .. ("|cff9d9d9d (%dm)|r")
                :format(math.ceil(freeSeconds / 60))
        end
        instanceLimit.value:SetText(valueText)
        instanceLimit.Layout()
        instanceLimit:Show()
        return
    end

    if instanceLimit then instanceLimit:Hide() end
    toastStatus:Show()
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
    toastStatus.arrow:SetRotation(up and math.pi or 0)       -- asset points down natively
    toastStatus.arrow:SetVertexColor(color[1], color[2], color[3])
end

-- Public entry point for "/rr tmog" and any other "open the browser from
-- anywhere" callers. Opens the popup in BROWSE mode: it stays until the
-- user clicks the close button; the grace-timer auto-hide doesn't apply.
function UI.OpenTransmogBrowser()
    -- The first paint asks the collection API about every row it draws,
    -- and in combat those answers arrive slowly enough to trip the script
    -- time limit. Hold the open until combat ends and finish it then.
    if InCombatLockdown and InCombatLockdown() then
        if not UI._tmogOpenAfterCombat then
            UI._tmogOpenAfterCombat = {  }
            RR:Print(RR.L["Browse locked in combat"])
            if not UI._tmogCombatFrame then
                UI._tmogCombatFrame = CreateFrame("Frame")
                UI._tmogCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
                UI._tmogCombatFrame:SetScript("OnEvent", function()
                    local pending = UI._tmogOpenAfterCombat
                    UI._tmogOpenAfterCombat = nil
                    if pending then UI.OpenTransmogBrowser(unpack(pending)) end
                end)
            end
        end
        return
    end
    -- Mutex with other auxiliary windows. See UI.OpenSkipsWindow for
    -- rationale.
    if skipsWindow and skipsWindow:IsShown() then skipsWindow:Hide() end
    if achievementsWindow and achievementsWindow:IsShown() then achievementsWindow:Hide() end

    local window = GetOrCreateTmogWindow()
    browserState.active = true
    CancelTmogHide()
    -- Apply current scale before showing so the first visible state matches
    -- the user's saved windowScale rather than rendering at the frame's
    -- construction-time default of 1.0. Skips and achievements apply scale
    -- at their open sites the same way.
    local scale = RR:GetSetting("windowScale", 1.0)
    window:SetScale(scale)
    -- Collapsible sections always open collapsed.
    window._trashExpanded = false
    window._legacyExpanded = false
    window._tierInfoExpanded = false
    window._hardmodeExpanded = false
    window._taggedExpanded = false
    window._factionTierExpanded = false
    window._factionExpanded = false
    window:RefreshAll()
    window:Show()
    -- One more AutoSize after Show so the first visible frame is already at
    -- the final size. Otherwise the initial creation's SetSize(440, MIN)
    -- briefly shows through before the AutoSize inside RefreshAll's height
    -- takes effect.
    UI.AutoSize()
end

--- Opens the browser on a picked search entry. The panel's in-run search
--- hands its result here; the browser's own search selects in place.
function UI.JumpToTmogEntry(entry)
    if not entry then return end
    UI.OpenTransmogBrowser()
    if tmogWindow and tmogWindow.SelectSearchEntry then
        tmogWindow.SelectSearchEntry(entry)
    end
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
    local function add(line) table.insert(lines, line or "") end

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
        local windowHeight     = w:GetHeight() or 0
        local sh    = (w.GetStringHeight and w:GetStringHeight()) or -1
        add(("  %s [%s]: height=%.1f  stringHeight=%.1f  top=%.1f  bottom=%.1f"):format(
            label, shown, windowHeight, sh, top, bot))
    end

    widgetSummary("sanctumLine", sanctumLine)
    widgetSummary("legendLine",  legendLine)

    -- Mirror the AutoSize height calculation so we can compare against
    -- actual. Content height comes from the row layout pass; AutoSize
    -- adds chrome, viewport cap and the legend footer around it.
    local fontSize     = RR:GetSetting("fontSize", 12)
    local renderedSize = math.max(8, fontSize - 1)
    local bodySize     = GetBodyFontSize and GetBodyFontSize(renderedSize) or renderedSize
    local lineHeight   = bodySize + 0.5
    local contentH     = tmogWindow.tmogContentH or 0
    local legendH = 2 * lineHeight + 8

    local chrome = 32 + (5 * 32 - 12) + 10 + 14
    local desired = chrome + contentH + legendH

    add("")
    add("AutoSize math:")
    add(("  fontSize=%d  bodySize=%d  lineHeight=%d"):format(
        fontSize, bodySize, lineHeight))
    add(("  contentH (row layout) = %d"):format(contentH))
    add(("  legendH = %d"):format(legendH))
    add(("  chrome = 32 + 88 + 10 + 14 = %d"):format(chrome))
    add(("  desired = chrome + contentH + legendH = %d"):format(desired))
    add(("  set frame height = %.1f"):format(fH))

    -- Geometry comparison: where does the last visible widget actually
    -- end vs where the frame ends?
    -- Legend is anchored under sanctumLine when sanctum shows;
    -- legend is still the lowest widget either way.
    local lastBot = legendLine and legendLine:GetBottom()
    if lastBot and fBot then
        local gap = lastBot - fBot
        add("")
        add(("Visible gap below legend = %.1f px"):format(gap))
        add("  (positive = blank space below legend, negative = legend clipped past frame)")
    end

    -- Scroll region runtime state: the actual values driving whether the
    -- scrollbar shows. The scrollbar appears whenever GetVerticalScrollRange
    -- > 0, which is child height minus scroll viewport height. If range is
    -- nonzero on a short list, either the child is taller than the viewport
    -- (height mismatch) or the range is stale from a prior layout.
    local scroll = tmogWindow.contentScroll
    local child  = tmogWindow.contentChild
    add("")
    add("Scroll region:")
    if scroll then
        local sH = scroll:GetHeight() or 0
        local sW = scroll:GetWidth() or 0
        local range = (scroll.GetVerticalScrollRange and scroll:GetVerticalScrollRange()) or -1
        local vScroll = (scroll.GetVerticalScroll and scroll:GetVerticalScroll()) or -1
        add(("  scroll: height=%.1f  width=%.1f"):format(sH, sW))
        add(("  scroll: verticalScrollRange=%.1f  verticalScroll=%.1f"):format(range, vScroll))
    else
        add("  scroll: nil")
    end
    if child then
        add(("  child: height=%.1f  width=%.1f"):format(
            child:GetHeight() or 0, child:GetWidth() or 0))
    else
        add("  child: nil")
    end
    -- Which scrollbar object exists, and is it shown?
    local barChild  = scroll and scroll.ScrollBar
    local barGlobal = _G["RetroRunsTmogScrollScrollBar"]
    add(("  scrollbar via .ScrollBar child: %s%s"):format(
        barChild and "EXISTS" or "nil",
        barChild and (barChild:IsShown() and " (shown)" or " (hidden)") or ""))
    add(("  scrollbar via global name:      %s%s"):format(
        barGlobal and "EXISTS" or "nil",
        barGlobal and (barGlobal:IsShown() and " (shown)" or " (hidden)") or ""))
    -- Report the content height the bar decision used.
    add(("  (row-layout contentH=%d -- compare to child.height above)"):format(contentH))

    RR:ShowCopyWindow("tmogsize", table.concat(lines, "\n"))
end

-- ----------------------------------------------------------------------------
-- Shared raid-skip presentation, used by both the idle list and the skips
-- window so the glyph rules cannot diverge.
-- ----------------------------------------------------------------------------

-- Skip-unlocked marker: yellow raid-target star, same texture used for
-- Fyrakk's portal POI. Gold means the skip is unlocked on this account.
local SKIP_MARKER_LED      = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12|t"
-- Row variants: the idle-list raid rows render at the body font (12+),
-- the legend at LEGEND_FONT_SIZE (10), so the same texture px reads
-- larger on the rows. These row markers are sized down to land at the
-- legend star's apparent size at the default font.
local SKIP_MARKER_ROW      = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:10|t"
local SKIP_MARKER_ROW_DIM  = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:10:0:0:64:64:0:64:0:64:80:80:80|t"
local SKIP_MARKER_ROW_NONE = "|TInterface\\Common\\Spacer:10:10|t"
-- Current-season marker for a dungeon row, in the column the raid rows
-- give their skip star: a clock face -- a solid white disc with its hands
-- cut out, so the panel shows through them. Drawn in the texture's own
-- white; the source is authored white at 64x64, so a trailing r:g:b
-- triple can tint it later without re-authoring. Hands are deliberately
-- heavy for the size -- see Media/Icons/ClockIcon.tga's generator.
-- Timewalking's marker: an hourglass, its own art rather than a second use
-- of the seasonal clock. Kept as its own constant so the two can never be
-- changed by one edit.
-- The 0:-2 is a y offset dropping the glyph onto the text baseline; with
-- no offset an inline texture rides high against the line it sits in.
UI.TIMEWALKING_MARKER_GLYPH = "|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\HourglassIcon:12:12:0:-1|t"
-- Width the marker occupies at the end of a header string, for placing the
-- hover region over the glyph rather than over the whole heading.
UI.TIMEWALKING_MARKER_W = 13

-- The "TW" or "M+" tag trailing an instance's name, as text at the row's
-- own size. TW at the current urgency tint; TW wins a row that is both,
-- since the week is the perishable half and the Mythic+ season outlives
-- it by months. A tag rather than the hourglass: the hourglass belongs to
-- the expansion header, and a live week would otherwise stack seven of
-- them down one column. Empty where a row earns neither.
function UI.InstanceTagText(instance)
    if instance and RR:IsTimewalkingLive(instance) then
        local days = RR:GetTimewalkingEnd()
        local hex = UI.TIMEWALKING_TINT_OK_HEX
        if days and days <= UI.TIMEWALKING_DAYS_LAST then
            hex = UI.TIMEWALKING_TINT_LAST_HEX
        elseif days and days <= UI.TIMEWALKING_DAYS_SOON then
            hex = UI.TIMEWALKING_TINT_SOON_HEX
        end
        return "  |cff" .. hex .. "TW|r"
    elseif instance and RR:IsSeasonalDungeon(instance) then
        return "  |cffffd100M+|r"
    end
    return ""
end
-- Width the slot adds ahead of the plane gutter: the 24px tag plus 2px of
-- breathing room. The plane button anchors at a FIXED inset on the row, so
-- the same number moves the plane over -- keep the two in step through
-- this constant.

-- A raid row's Timewalking tag, trailing the name with a gap, while the
-- raid's week is live; nothing otherwise. Raid rows reserve no slot.

-- Urgency tint: many appearances are Timewalking-only, so how much of the
-- week is left is real information, not decoration. The asset is white, so
-- the trailing R:G:B tints it (same mechanism as PlaneIcon / StatusDot).
-- Thresholds are in DAYS REMAINING and the event runs about a week.
UI.TIMEWALKING_TINT_OK    = "0:255:0"
UI.TIMEWALKING_TINT_SOON  = "255:255:0"
UI.TIMEWALKING_TINT_LAST  = "255:0:0"
UI.TIMEWALKING_TINT_OK_HEX   = "00ff00"   -- the same three, for text
UI.TIMEWALKING_TINT_SOON_HEX = "ffff00"
UI.TIMEWALKING_TINT_LAST_HEX = "ff0000"
UI.TIMEWALKING_DAYS_SOON  = 3        -- at or under this, amber
UI.TIMEWALKING_DAYS_LAST  = 1        -- at or under this, red

-- The marker at the urgency for `days` remaining; plain white when the end
-- date could not be read, so an unknown never reads as urgent.
function UI.TimewalkingMarker(days)
    if not days then return UI.TIMEWALKING_MARKER_GLYPH end
    local tint = UI.TIMEWALKING_TINT_OK
    if days <= UI.TIMEWALKING_DAYS_LAST then
        tint = UI.TIMEWALKING_TINT_LAST
    elseif days <= UI.TIMEWALKING_DAYS_SOON then
        tint = UI.TIMEWALKING_TINT_SOON
    end
    return ("|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\HourglassIcon:12:12:0:-1:64:64:0:64:0:64:%s|t")
        :format(tint)
end
-- Inline texture marker matching the entrance-navigation buttons (the
-- custom PlaneIcon, tinted RETRO pink via the extended texture-markup
-- RGB params 242,89,199 = the 0.95/0.35/0.78 brand pink scaled to 0-255).
-- The full-texture coords (0:64:0:64) plus trailing R:G:B tint the white
-- silhouette without cropping it.
--
-- Sized off the body font the same way PositionEntranceButton sizes the
-- real buttons, so the legend's plane and the planes it explains are the
-- same size at any font setting. NOT the legend's own smaller font: the
-- point of the line is that this glyph is that button.
local function EntranceMarker()
    local size = math.floor(RR:GetSetting("fontSize", 12) * 1.4)
    return ("|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\PlaneIcon:%d:%d:0:0:64:64:0:64:0:64:242:89:199|t")
        :format(size, size)
end

-- Skip-legend footer line. Explains the gold star; dim and invisible
-- variants don't need explicit legend coverage.
local IDLE_SKIP_LEGEND =
    "|cff9d9d9d" .. SKIP_MARKER_LED .. " = " .. RR.L["skip unlocked -- check Skips for details"] .. "|r"

-- Dungeon-list counterpart, in the slot the skip legend takes for raids.
-- Footer legend below the supported-raids list. Two lines:
--   Routing: <Zygor|Mapzeroth|None> [with AWP Orchestration]
--   Waypoint: <TomTom|Native> [with 3D Overlay from <names>]
-- Rebuilt on every render so a /reload picks up newly installed addons.
local function BuildEntranceLegend()
    local LIT_HEX  = "ffffff"  -- active provider names
    local LBL_HEX  = "9d9d9d"  -- labels, connectors, prepositions
    local WARN_HEX = "ff4040"  -- soft-warning text (Zygor arrow off)

    local function lit(text) return ("|cff%s%s|r"):format(LIT_HEX, text) end
    local function lbl(text) return ("|cff%s%s|r"):format(LBL_HEX, text) end
    local function warn(text) return ("|cff%s%s|r"):format(WARN_HEX, text) end

    local awpInst       = RR:IsAWPInstalled()
    local zygorInst     = RR:IsZygorInstalled()
    local mapzerothInst = RR:IsMapzerothInstalled()
    local wuiInst       = RR:IsWUIInstalled()
    local tomtomInst    = RR:IsTomTomInstalled()

    -- ROUTING line. Zygor wins ties over Mapzeroth, matching the dispatch
    -- cascade. Zygor installed with its waypoint arrow turned off still wins
    -- the dispatch but produces nothing visible, so that soft-fail is
    -- surfaced here as a clickable warning that turns the setting back on.
    local routingActive
    if zygorInst then
        routingActive = lit("Zygor")
        if not RR:IsZygorArrowEnabled() then
            routingActive = routingActive .. " " .. warn(
                "|Hretroruns:zygor_arrow|h" .. RR.L["[Waypoint Arrow Disabled - Click to Enable]"] .. "|h")
        end
    elseif mapzerothInst then
        routingActive = lit("Mapzeroth")
    else
        routingActive = lit(RR.L["None"])
    end

    -- AWP Orchestration tail: ONLY when AWP is installed AND a backend
    -- is active. AWP-without-backend has nothing to orchestrate; no
    -- tail in that case.
    local routingTail = ""
    if awpInst and (zygorInst or mapzerothInst) then
        routingTail = lbl(RR.L[" with "]) .. lit("AWP Orchestration")
    end

    -- WAYPOINT line. TomTom or Blizzard Native -- exactly one
    -- describes which addon drops the destination arrow. Native is
    -- the universal fallback.
    local waypointActive = tomtomInst and lit("TomTom") or lit(RR.L["Native"])

    -- OVERLAY tail. AWP and WUI as peers; either, both, or neither
    -- can be active. Tail entirely omitted when neither is installed.
    local overlayTail = ""
    if awpInst and wuiInst then
        overlayTail = lbl(RR.L[" with 3D Overlay from "])
            .. lit("AWP") .. lbl(RR.L[" and "]) .. lit("WUI")
    elseif awpInst then
        overlayTail = lbl(RR.L[" with 3D Overlay from "]) .. lit("AWP")
    elseif wuiInst then
        overlayTail = lbl(RR.L[" with 3D Overlay from "]) .. lit("WUI")
    end

    -- Two rows, each a label half and a data half, rendered as TWO
    -- FontStrings: proportional label widths mean concatenated text never
    -- column-aligns.
    return {
        { withMarker = true,  label = lbl(RR.L["Routing: "]),  data = routingActive  .. routingTail },
        { withMarker = false, label = lbl(RR.L["Waypoint: "]), data = waypointActive .. overlayTail },
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

-- English-default column offsets. Difficulty names are far wider in some
-- languages, so the window measures its own headers on creation and widens
-- both the column pitch and the frame; every consumer reads
-- window.colNormalX / colHeroicX / colMythicX / contentWidth, and these
-- constants are only the floor.
--
-- Column order is Mythic / Heroic / Normal left to right.
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

-- Clear space demanded between two neighboring column headers, and
-- between the leftmost header and the info-button column.
local SKIPS_COL_HEADER_GAP = 12

-- Per-row vertical spacing. Driven by font size at refresh time; this
-- is the multiplier (rendered line-height = fontSize * SKIPS_LINE_GAP).
local SKIPS_LINE_GAP       = 1.7

-- Moves the divider up into the row band so the text reads as centered between
-- two dividers -- the FontString's internal top-padding shifts its visual
-- midpoint upward.
local SKIPS_ROW_DIVIDER_INSET = 5

-- Difficulty-cell glyphs, reusing the ReadyCheck check/X vocabulary at a
-- native 14x14 so column widths stay even.
--
-- Skips cells paint a severity ramp instead: gray N/A, white locked, green
-- unlocked. Vertex-tinted StatusDot textures rather than a typographic
-- bullet, which renders as a missing glyph in pixel fonts.
local function StatusDotGlyph(r, g, b)
    return ("|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\StatusDot:10:10:0:0:64:64:0:64:0:64:%d:%d:%d|t"):format(r, g, b)
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
            .. "|cff9d9d9d" .. RR.L["Requires Patch 11.0.5 or later."] .. "|r" })
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
            local exp = resolved.expansion or RR.L["Unknown"]
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

    -- Session-scoped expand state, separate from the idle list's so the two
    -- collapse independently. true = expanded, false/nil = collapsed.
    --
    -- Single-expand accordion, and nothing ever auto-opens -- that is what
    -- keeps the clicked +/- button under the cursor across a refresh.
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

                -- Multi-chain raids render as one row with two glyphs per
                -- cell, centered on the column midline. Each chain cascades
                -- independently and takes its own ceiling.
                local perChain = RR:GetSkipChainCeilings(raid)
                local isMultiChain = perChain and #perChain > 1

                if isMultiChain then
                    local function cellsForChain(chain)
                        local mCell, hCell, nCell
                        if cascading then
                            mCell = chain.ceiling and chain.ceiling >= 16 or false
                            hCell = chain.ceiling and chain.ceiling >= 15 or false
                            nCell = chain.ceiling and chain.ceiling >= 14 or false
                        else
                            mCell = chain.ceiling == 16
                            hCell = "na"
                            nCell = "na"
                        end
                        return mCell, hCell, nCell
                    end
                    local m1, h1, n1 = cellsForChain(perChain[1])
                    local m2, h2, n2 = cellsForChain(perChain[2])
                    table.insert(expRows, {
                        kind    = "raidRow",
                        name    = RR:GetLocalizedRaidName(raid) or "?",
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
                        name   = RR:GetLocalizedRaidName(raid) or "?",
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
    -- Pixel-grid snapping can collapse a 1px line to zero pixel rows at
    -- fractional effective scales, leaving scattered rows with no
    -- divider. Unsnapped, the line antialiases instead of vanishing.
    if slot.divider.SetTexelSnappingBias then
        slot.divider:SetTexelSnappingBias(0)
        slot.divider:SetSnapToPixelGrid(false)
    end

    -- Active-raid band + left accent bar. Same shape and shared flash as
    -- the achievements window's current-boss band: a BORDER-layer tint
    -- spanning the row's width that shows bright and fades out, plus a
    -- 3px-wide solid cyan vertical bar at the left edge that stays as
    -- the persistent marker. Shown on the raidRow whose instanceID
    -- matches RR.currentRaid (i.e., the player is in that raid right now).
    slot.highlight = parent:CreateTexture(nil, "BORDER")
    slot.highlight:SetColorTexture(UI.FLASH_BAND_R, UI.FLASH_BAND_G,
        UI.FLASH_BAND_B, UI.FLASH_BAND_ALPHA)
    slot.highlightFade = slot.highlight:CreateAnimationGroup()
    local highlightAlpha = slot.highlightFade:CreateAnimation("Alpha")
    highlightAlpha:SetFromAlpha(1)
    highlightAlpha:SetToAlpha(0)
    highlightAlpha:SetStartDelay(UI.FLASH_FADE_DELAY)
    highlightAlpha:SetDuration(UI.FLASH_FADE_DURATION)
    local highlightTexture = slot.highlight
    slot.highlightFade:SetScript("OnFinished", function()
        highlightTexture:Hide()
    end)
    slot.accent = parent:CreateTexture(nil, "BORDER")
    slot.accent:SetColorTexture(0.45, 0.80, 1.0, 1.0)
    slot.accent:SetWidth(3)

    -- "[i]" button, shown only on rows whose raid has skipTrigger text. A
    -- Button with a child FontString; the glyph IS the visual, and hover
    -- tints the FontString. Bracketed ASCII because Unicode info glyphs are
    -- outside FRIZQT's coverage and render as boxes.
    slot.infoBtn = CreateFrame("Button", nil, parent)
    slot.infoBtn:SetSize(28, 16)
    -- Fires on DOWN, not UP: the parent window is draggable, so a press plus
    -- a cursor jiggle on a button this small reads as a drag-start on the
    -- window instead.
    slot.infoBtn:RegisterForClicks("AnyDown")
    -- Negative insets EXPAND the hit area past the button's bounds, keeping
    -- the target snappy at high UI scale without changing it visually.
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
    local window = skipsWindow
    if not window then return end

    HideAllSkipsSlots()
    ReleaseSkipsToggleButtons()

    -- Active-raid band flash: re-arms when the current raid changes (and
    -- on window open, which clears the key). Same bookkeeping as the
    -- achievements window's current-boss flash.
    local flashKey = RR.currentRaid and RR.currentRaid.instanceID or nil
    local flashRestart = false
    if window._raidFlashKey ~= flashKey then
        window._raidFlashKey = flashKey
        window._raidFlashUntil = flashKey
            and (GetTime() + UI.FLASH_FADE_DELAY + UI.FLASH_FADE_DURATION)
            or 0
        flashRestart = flashKey ~= nil
    end
    local flashActive = (window._raidFlashUntil or 0) > GetTime()

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
    if window.colHeaderM then
        SetBodyFont(window.colHeaderM, rowFontSize, "")
        SetBodyFont(window.colHeaderH, rowFontSize, "")
        SetBodyFont(window.colHeaderN, rowFontSize, "")
    end

    for i, row in ipairs(rows) do
        local slot = GetSkipsRowSlot(window, i)

        if row.kind == "expansionHeader" then
            SetBodyFont(slot.expHeader, rowFontSize, "")
            -- Four leading spaces reserve room for the toggle glyph anchored
            -- at the FontString's LEFT. Two overlapped the first letter.
            slot.expHeader:SetText(("    |cff00ffff%s|r"):format(RR.L[row.text]))
            slot.expHeader:ClearAllPoints()
            slot.expHeader:SetPoint("TOPLEFT", window, "TOPLEFT", SKIPS_COL_NAME_X, y)
            slot.expHeader:Show()

            -- Toggle button: square at the font height, anchored to the
            -- LEFT of the header FontString so it tracks the text with no
            -- line-stride drift (identical to PositionExpansionToggleButton
            -- in the idle list). Click flips collapse state and rebuilds.
            local exp = row.text
            local shown = row.expanded
            local btn = AcquireSkipsToggleButton(window)
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
            -- Headers take a tighter pitch than content rows, so a collapsed
            -- list reads as a compact stack. The full lineHeight is only needed
            -- where the highlight and divider bands do.
            y = y - headerPitch

        elseif row.kind == "raidRow" then
            SetBodyFont(slot.name, rowFontSize, "")
            slot.name:SetText("|cffffffff  " .. row.name .. "|r")
            slot.name:ClearAllPoints()
            slot.name:SetPoint("TOPLEFT", window, "TOPLEFT", SKIPS_COL_NAME_X, y)
            slot.name:SetWidth(SKIPS_COL_INFO_X - SKIPS_COL_NAME_X - 8)
            slot.name:Show()

            -- Active-raid band, compared by instanceID rather than table
            -- reference so the faction-specific BfD tables both match.
            -- The band only shows during the flash window and fades out;
            -- the accent bar stays as the persistent marker.
            if RR.currentRaid and row.raidRef
               and row.raidRef.instanceID == RR.currentRaid.instanceID then
                if flashActive then
                    slot.highlight:ClearAllPoints()
                    slot.highlight:SetPoint("TOPLEFT",     window, "TOPLEFT",  4,  y + 2)
                    slot.highlight:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -4, y - lineHeight + 4)
                    slot.highlight:Show()
                    -- A mid-fade rebuild keeps a running animation;
                    -- restart on a new flash, or when this slot's
                    -- animation is not the one carrying it (rebuilds can
                    -- move the row to another pooled slot).
                    if flashRestart or not slot.highlightFade:IsPlaying() then
                        slot.highlightFade:Stop()
                        slot.highlightFade:Play()
                    end
                end

                slot.accent:ClearAllPoints()
                slot.accent:SetPoint("TOPLEFT",    window, "TOPLEFT", 4, y + 2)
                slot.accent:SetPoint("BOTTOMLEFT", window, "TOPLEFT", 4, y - lineHeight + 4)
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
                -- Anchored to the window, not the row FontString, so the hit
                -- rect shares a coord grid with the other clickable children.
                -- The y nudge aligns the button glyph with the row name, which
                -- sits higher in its line-box.
                slot.infoBtn:SetPoint("TOPLEFT", window, "TOPLEFT",
                    SKIPS_COL_INFO_X - 14, y + 2)
                slot.infoBtn:SetFrameLevel(window:GetFrameLevel() + 2)
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
            local function cellText(cellValue)
                if cellValue == "na" then return SKIPS_CELL_NA end
                if cellValue == "?" then return SKIPS_CELL_UNKNOWN end
                if cellValue then
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
                slot.cellM:SetPoint("TOP", window, "TOPLEFT", (window.colMythicX or SKIPS_COL_MYTHIC_X) - pairOffset, y)
                SetBodyFont(slot.cellM2, rowFontSize, "")
                slot.cellM2:SetText(cellText(row.mythic2))
                slot.cellM2:ClearAllPoints()
                slot.cellM2:SetPoint("TOP", window, "TOPLEFT", (window.colMythicX or SKIPS_COL_MYTHIC_X) + pairOffset, y)
                slot.cellM2:Show()
            else
                slot.cellM:SetPoint("TOP", window, "TOPLEFT", window.colMythicX or SKIPS_COL_MYTHIC_X, y)
            end
            slot.cellM:Show()

            SetBodyFont(slot.cellH, rowFontSize, "")
            slot.cellH:SetText(cellText(row.heroic))
            slot.cellH:ClearAllPoints()
            if row.heroic2 ~= nil then
                slot.cellH:SetPoint("TOP", window, "TOPLEFT", (window.colHeroicX or SKIPS_COL_HEROIC_X) - pairOffset, y)
                SetBodyFont(slot.cellH2, rowFontSize, "")
                slot.cellH2:SetText(cellText(row.heroic2))
                slot.cellH2:ClearAllPoints()
                slot.cellH2:SetPoint("TOP", window, "TOPLEFT", (window.colHeroicX or SKIPS_COL_HEROIC_X) + pairOffset, y)
                slot.cellH2:Show()
            else
                slot.cellH:SetPoint("TOP", window, "TOPLEFT", window.colHeroicX or SKIPS_COL_HEROIC_X, y)
            end
            slot.cellH:Show()

            SetBodyFont(slot.cellN, rowFontSize, "")
            slot.cellN:SetText(cellText(row.normal))
            slot.cellN:ClearAllPoints()
            if row.normal2 ~= nil then
                slot.cellN:SetPoint("TOP", window, "TOPLEFT", (window.colNormalX or SKIPS_COL_NORMAL_X) - pairOffset, y)
                SetBodyFont(slot.cellN2, rowFontSize, "")
                slot.cellN2:SetText(cellText(row.normal2))
                slot.cellN2:ClearAllPoints()
                slot.cellN2:SetPoint("TOP", window, "TOPLEFT", (window.colNormalX or SKIPS_COL_NORMAL_X) + pairOffset, y)
                slot.cellN2:Show()
            else
                slot.cellN:SetPoint("TOP", window, "TOPLEFT", window.colNormalX or SKIPS_COL_NORMAL_X, y)
            end
            slot.cellN:Show()

            -- Row divider, inset from each frame edge so it frames the table
            -- rather than running edge-to-edge.
            slot.divider:ClearAllPoints()
            slot.divider:SetPoint("TOPLEFT",  window, "TOPLEFT",  SKIPS_COL_NAME_X, y - lineHeight + SKIPS_ROW_DIVIDER_INSET)
            slot.divider:SetPoint("TOPRIGHT", window, "TOPRIGHT", -14, y - lineHeight + SKIPS_ROW_DIVIDER_INSET)
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
            slot.name:SetPoint("TOPLEFT", window, "TOPLEFT", SKIPS_COL_NAME_X, y)
            slot.name:SetWidth((window.contentWidth or SKIPS_WINDOW_WIDTH) - SKIPS_COL_NAME_X - 14)
            slot.name:Show()
            y = y - (lineHeight * 3)
        end
    end

    -- Position the disclaimer below the last row, with a small gap.
    if window.disclaimer then
        SetBodyFont(window.disclaimer, fontSize - 1, "")
        window.disclaimer:ClearAllPoints()
        window.disclaimer:SetPoint("TOPLEFT", window, "TOPLEFT", SKIPS_COL_NAME_X, y - 8)
        window.disclaimer:SetPoint("TOPRIGHT", window, "TOPRIGHT", -14, y - 8)
    end

    -- Compute total height: |y| (negative offset to last row) + disclaimer
    -- height + bottom margin.
    local lastY = math.abs(y)
    local disclaimerH = window.disclaimer and window.disclaimer:GetStringHeight() or 0
    local desired = lastY + 14 + disclaimerH + 14
    local clamped = math.max(SKIPS_WINDOW_MIN_HEIGHT,
                             math.min(SKIPS_WINDOW_MAX_HEIGHT, desired))

    -- Top-pin: re-anchor TOPLEFT to the captured screen position so the
    -- window grows downward and a dragged position survives. A bare SetHeight
    -- on a CENTER-anchored frame splits the delta and moves the +/- buttons
    -- out from under the cursor.
    local oldTop  = window:GetTop()
    local oldLeft = window:GetLeft()
    window:SetHeight(clamped)
    if oldTop and oldLeft then
        window:ClearAllPoints()
        window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", oldLeft, oldTop)
    end
end

GetOrCreateSkipsWindow = function()
    if skipsWindow then return skipsWindow end

    local skipsFrame = CreateFrame("Frame", "RetroRunsSkipsWindow", UIParent, "BackdropTemplate")
    -- Initial height matches MIN; RefreshSkipsContent grows it on first show.
    skipsFrame:SetSize(SKIPS_WINDOW_WIDTH, SKIPS_WINDOW_MIN_HEIGHT)
    skipsFrame:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    skipsFrame:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    -- Anchor to the right of the main panel, same as Tmog.
    skipsFrame:SetPoint("TOPLEFT", panel, "TOPRIGHT", 6, 0)
    skipsFrame:SetMovable(true)
    skipsFrame:EnableMouse(true)
    skipsFrame:RegisterForDrag("LeftButton")
    skipsFrame:SetScript("OnDragStart", skipsFrame.StartMoving)
    skipsFrame:SetScript("OnDragStop",  skipsFrame.StopMovingOrSizing)
    skipsFrame:SetClampedToScreen(true)
    skipsFrame:SetFrameStrata("HIGH")
    skipsFrame:Hide()

    -- The skip-detail frame is conceptually a child of this window (it
    -- opens from a row's [ i ] button). Hide it whenever this window
    -- hides, so it doesn't linger after the Skips window is closed or
    -- mutexed away by another auxiliary window.
    skipsFrame:HookScript("OnHide", function() UI.HideSkipDetail() end)

    local title = skipsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -10)
    title:SetText(RR.L["|cffF259C7RETRO|r|cff4DCCFFRUNS|r  Raid Skips"])
    SafeSetFont(title, RR:GetChromeFont(), 16, "")
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local closeBtn = UI.MakeRetroCloseButton(skipsFrame)
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() skipsFrame:Hide() end)

    -- Static column headers. Sit at y=-32, just below the title bar.
    -- These are persistent (not pool-managed) since they never change.
    local function MakeColHeader(x, text)
        local fs = skipsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOP", skipsFrame, "TOPLEFT", x, -32)
        fs:SetJustifyH("CENTER")
        fs:SetText("|cffaaaaaa" .. text .. "|r")
        return fs
    end
    skipsFrame.colHeaderN = MakeColHeader(SKIPS_COL_NORMAL_X, RR.L["Normal"])
    skipsFrame.colHeaderH = MakeColHeader(SKIPS_COL_HEROIC_X, RR.L["Heroic"])
    skipsFrame.colHeaderM = MakeColHeader(SKIPS_COL_MYTHIC_X, RR.L["Mythic"])

    -- Fit the columns to the translated headers. The headers are centered
    -- on their column, so two neighbors collide once the pitch drops below
    -- half of each one's width plus a gap. Widen the pitch to the worst
    -- neighboring pair, then widen the frame to match. English and Spanish
    -- measure under the default pitch and come out unchanged.
    local widthN = skipsFrame.colHeaderN:GetStringWidth() or 0
    local widthH = skipsFrame.colHeaderH:GetStringWidth() or 0
    local widthM = skipsFrame.colHeaderM:GetStringWidth() or 0
    local pitch = math.max(
        SKIPS_COL_HEROIC_X - SKIPS_COL_NORMAL_X,
        (widthN + widthH) / 2 + SKIPS_COL_HEADER_GAP,
        (widthH + widthM) / 2 + SKIPS_COL_HEADER_GAP)
    pitch = math.ceil(pitch)

    -- The leftmost header must also clear the info-button column.
    local normalX = math.max(SKIPS_COL_NORMAL_X,
        math.ceil(SKIPS_COL_INFO_X + widthN / 2 + SKIPS_COL_HEADER_GAP))
    skipsFrame.colNormalX = normalX
    skipsFrame.colHeroicX = normalX + pitch
    skipsFrame.colMythicX = normalX + pitch * 2
    skipsFrame.contentWidth = math.max(SKIPS_WINDOW_WIDTH,
        math.ceil(skipsFrame.colMythicX + widthM / 2 + SKIPS_COL_NAME_X))

    skipsFrame.colHeaderH:SetPoint("TOP", skipsFrame, "TOPLEFT", skipsFrame.colHeroicX, -32)
    skipsFrame.colHeaderM:SetPoint("TOP", skipsFrame, "TOPLEFT", skipsFrame.colMythicX, -32)
    if normalX ~= SKIPS_COL_NORMAL_X then
        skipsFrame.colHeaderN:SetPoint("TOP", skipsFrame, "TOPLEFT", normalX, -32)
    end
    skipsFrame:SetWidth(skipsFrame.contentWidth)

    -- Disclaimer at the bottom. Anchored dynamically by RefreshSkipsContent
    -- after the last row, so no fixed position here.
    -- Footer legend: the four cell-dot states plus the info-button note.
    -- Dots reuse the cell glyph constants so the key always matches what
    -- the rows paint. The "?" unknown state is intentionally omitted.
    local disclaimer = skipsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    disclaimer:SetJustifyH("LEFT")
    disclaimer:SetWordWrap(true)
    disclaimer:SetText(
        SKIPS_CELL_NA       .. " |cff9d9d9d" .. RR.L["N/A"] .. "|r    "
     .. SKIPS_CELL_LOCKED   .. " |cff9d9d9d" .. RR.L["Locked"] .. "|r    "
     .. SKIPS_CELL_UNLOCKED .. " |cff9d9d9d" .. RR.L["Unlocked"] .. "|r")
    skipsFrame.disclaimer = disclaimer

    skipsFrame.RefreshContent = RefreshSkipsContent

    -- Live refresh on a skip-quest turn-in. Without this the window only
    -- rebuilds when it is opened, so a skip earned while it was on screen
    -- kept showing Locked until the player closed and reopened it.
    --
    -- QUEST_TURNED_IN fires before the account-wide flag
    -- IsQuestFlaggedCompletedOnAccount reports the completion, so a single
    -- refresh on the event can read the old value and change nothing. The
    -- retries cover that lag the same way the kill-sync path does; they are
    -- cheap because each is one table walk over a handful of quest IDs, and
    -- they only run while the window is shown.
    skipsFrame:RegisterEvent("QUEST_TURNED_IN")
    skipsFrame:SetScript("OnEvent", function(self)
        if not self:IsShown() then return end
        for _, delay in ipairs({ 0.1, 0.5, 1.5 }) do
            C_Timer.After(delay, function()
                if self:IsShown() and self.RefreshContent then
                    self:RefreshContent()
                end
            end)
        end
    end)

    skipsWindow = skipsFrame
    return skipsFrame
end

function UI.OpenSkipsWindow()
    -- Auxiliary windows (skips, tmog, achievements) all anchor to the
    -- same point at the main panel's right edge, so showing two at once
    -- produces visual overlap. Mutex them: opening any auxiliary window
    -- hides the others. The user can still toggle between them with
    -- their respective action-row buttons.
    if tmogWindow and tmogWindow:IsShown() then tmogWindow:Hide() end
    if achievementsWindow and achievementsWindow:IsShown() then achievementsWindow:Hide() end

    local window = GetOrCreateSkipsWindow()

    -- Snap to the current raid: opening the window while in a supported
    -- raid expands that raid's expansion section. Seeded only here, at
    -- open time, so the accordion still governs subsequent toggles.
    if RR.currentRaid and RR.currentRaid.expansion then
        RR.state = RR.state or {}
        RR.state.skipsExpandedExpansions = { [RR.currentRaid.expansion] = true }
        -- Mark the raid context as seen so the settings heartbeat doesn't
        -- treat the new window's nil _lastRaidKey as a transition.
        window._lastRaidKey = RR.currentRaid.instanceID
    end

    -- Apply current settings (scale + font) before refreshing so the
    -- first visible state already matches the user's settings rather
    -- than rendering at default and then snapping to settings.
    local scale = RR:GetSetting("windowScale", 1.0)
    window:SetScale(scale)
    -- Re-arm the active-raid band flash: every open gets the flash even
    -- when the raid has not changed since the last one.
    window._raidFlashKey = nil
    RefreshSkipsContent()
    window:Show()
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
-- Renders RR.WhatsNew into one color-coded string for the Settings tab.
-- Wrapped in do/end to keep its locals out of UI.lua's top-level scope, which
-- is near Lua 5.1's 200-local ceiling.
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
        -- popup heading + footer Note: convention), date in muted gray.
        table.insert(lines, ("|cffF259C7v%s|r   |cff9d9d9d%s|r"):format(
            entry.version or "?", entry.date or ""))
        for _, section in ipairs(entry.sections or {}) do
            pushBlank()
            -- Subheader (Added / Fixed / Changed / Removed). Gold to
            -- match the "Note:" / "Reward:" / "Title:" label color
            -- used elsewhere in the addon.
            table.insert(lines, ("|cffffd200%s|r"):format(RR.L[section.heading or ""]))
            for _, bullet in ipairs(section.bullets or {}) do
                -- Render **bold** spans as bright-white inline color.
                -- The CHANGELOG voice puts the lead-in headline-style
                -- phrase in **bold** before the supporting prose, so
                -- bright-white-on-gray gives the same visual emphasis.
                local rendered = RR.L[bullet]:gsub("%*%*(.-)%*%*",
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



-- Per-raid pill row for the idle list. Same shape as the in-raid row, but
-- colored by each pill's OWN lockout state: green cleared, amber partial,
-- gray untouched, dim "-" where the difficulty doesn't apply.
local function BuildIdleListPills(raid)
    local counts = RR:GetPerDifficultyKillCountsForRaid(raid)
    if not counts then return "" end

    -- Build from the raid's difficulty model so shared-lockout raids show
    -- N | H and independent raids show N | H | M without a per-model branch. LFR (17)
    -- is intentionally absent from the label map, matching the in-raid
    -- pill row -- LFR sources live in the transmog browser. 3/4/5/6 are
    -- the Wrath size difficulties, kept as their own buckets because each
    -- size has its own loot table.
    local BUCKET_LABEL = {
        [3] = "10N", [4] = "25N", [5] = "10H", [6] = "25H",
        [14] = "N", [15] = "H", [16] = "M",
    }
    local PILLS = {}
    for _, bucket in ipairs(RR:GetDisplayBuckets(raid)) do
        local label = BUCKET_LABEL[bucket]
        -- Dungeon Normal never locks, so its pill could only ever read
        -- fresh; dungeons pill their lockout difficulties (Heroic daily,
        -- Mythic weekly), and a Normal-only dungeon carries no pill row.
        if raid.kind == "dungeon" and bucket == 14 then
            label = nil
        end
        if label then
            table.insert(PILLS, { id = bucket, label = label })
        end
    end
    if #PILLS == 0 then return "" end

    -- No alpha byte here, or it leaks as visible characters before the label.
    local CLEARED  = "00ff00"  -- matches SPECIAL_COLLECTED RGB
    local PARTIAL  = "ff9333"  -- matches SPECIAL_PARTIAL RGB
    local FRESH    = "888888"  -- matches SPECIAL_UNCOLLECTED RGB
    local INACTIVE = "555555"  -- doesn't apply

    -- Shared lockout: once a mode is committed for the week, its
    -- shared-lockout sibling (Normal/Heroic, or 10/25) is unreachable. Mark that sibling with a lock
    -- glyph (no recolor -- an untouched pill is already gray, so color
    -- alone couldn't distinguish "locked this week" from "not yet done").
    -- Every sibling the shared lockout blocks, not just one: a four-member
    -- group (Wrath sizesHeroic) locks three pills off a single commit.
    local lockedBuckets = {}
    for _, bucket in ipairs(RR:GetLockedOutBuckets(raid, counts) or {}) do
        lockedBuckets[bucket] = true
    end
    -- yOffset drops the icon onto the text baseline; trailing RGB tints it
    -- gold (the LFG lock is the locked-out marker).
    local LOCK_GLYPH = " |TInterface\\PetBattles\\PetBattle-LockIcon:12:12:0:0|t"

    -- LFR pill first, matching the in-raid row. Sourced from the lockout
    -- bitfield rather than C_RaidLocks, and shown only for raids with wing
    -- data. It sits in its own bracket group, which reserves an inner slot so
    -- the wing chevron can sit inside the bracket.
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
            and "|TInterface\\Common\\Spacer:10:11|t"
            or ""
        lfrSegment = ("|cff777777[ |r%s%s|cff777777 ]|r"):format(
            lfrToken, chevronSlot)
    end

    local parts = {}
    for _, p in ipairs(PILLS) do
        local count = counts[p.id]
        local label = p.label
        local lock = lockedBuckets[p.id] and LOCK_GLYPH or ""

        if count and count.total > 0 then
            local hex
            if count.complete >= count.total then
                hex = CLEARED
            elseif count.complete > 0 then
                hex = PARTIAL
            else
                hex = FRESH
            end
            if label then
                table.insert(parts, ("|cff%s%s %d/%d|r%s"):format(
                    hex, label, count.complete, count.total, lock))
            else
                -- Flexible, no committed difficulty yet: count only.
                table.insert(parts, ("|cff%s%d/%d|r%s"):format(
                    hex, count.complete, count.total, lock))
            end
        else
            if label then
                table.insert(parts, ("|cff%s%s -|r%s"):format(INACTIVE, label, lock))
            else
                table.insert(parts, ("|cff%s-|r%s"):format(INACTIVE, lock))
            end
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

-- Structured rows for RefreshIdleList to render: expansionHeader, raidName,
-- pillRow, spacer, skipLegend, emptyMessage.
--
-- Splitting data from rendering is what lets RefreshIdleList anchor toggle
-- Buttons to their header FontStrings instead of computing line offsets.
local function BuildIdleListRows()
    -- Which instance list the picker shows, from the header sentence's
    -- RAID | DUNGEON toggle. Session-scoped, raids on a fresh login.
    local dungeonMode = (RR.state and RR.state.idleListMode) == "dungeon"

    local byExpansion = {}
    if dungeonMode then
        for _, dungeon in pairs(RetroRuns_DungeonData or {}) do
            if dungeon.instanceID and dungeon.instanceID > 0 then
                local exp = dungeon.expansion or RR.L["Unknown"]
                byExpansion[exp] = byExpansion[exp] or {}
                table.insert(byExpansion[exp], dungeon)
            end
        end
    else
        for _, raid in pairs(RetroRuns_Data or {}) do
            -- Skip incomplete entries (instanceID = 0). These have no resolved
            -- journal IDs yet, so they'd render as a raid with all-dash pills
            -- (journalEncounterID = 0 resolves to no encounter, detectable bosses
            -- = 0, and the pill renderer takes the "doesn't apply" branch).
            if raid.instanceID and raid.instanceID > 0 then
                -- Horde players use the Horde-specific table where one exists, or
                -- the pill row counts kills against Alliance encounter IDs the
                -- Horde kills never registered against.
                local resolved = RR:GetRaidByInstanceID(raid.instanceID) or raid
                local exp = resolved.expansion or RR.L["Unknown"]
                byExpansion[exp] = byExpansion[exp] or {}
                table.insert(byExpansion[exp], resolved)
            end
        end
    end

    -- Session-scoped expand state, SHARED by both modes: the expansion is
    -- what the player is thinking about, and the toggle only picks which of
    -- its instances to see. Flipping to dungeons with Shadowlands open
    -- lands on Shadowlands dungeons, not wherever the dungeon list happened
    -- to be left. Default = collapsed (no entry means "use the default"),
    -- and RR.state is empty on a fresh /reload or login, so every expansion
    -- starts collapsed each session.
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
        local name  = RR:GetLocalizedRaidName(raid) or "??"

        -- One marker per skip chain: gold unlocked, dim locked, transparent
        -- where no skip mechanic exists (which still reserves the column).
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

        -- Skip marker (a 6px spacer pads it to the pill row's 16px
        -- indent), plane gutter, name: the name starts where the pills
        -- below it start, and every plane shares one column. A live
        -- Timewalking tag trails the name for that week only.
        local label = ("%s|TInterface\\Common\\Spacer:10:6|t%s  |cffffffff%s|r%s")
            :format(leading, RR.PILL_PLANE_GUTTER, name, UI.InstanceTagText(raid))

        anyRaidShown = true
        local raidHasPlane = (RR:GetRaidEntrance(raid) ~= nil)
        if raidHasPlane then
            anyEntranceShown = true
        end
        table.insert(rows, { kind = "raidName", text = label, raid = raid,
            hasPlane = raidHasPlane,
            planeInset = 17 })
        local pills = BuildIdleListPills(raid)
        if pills ~= "" then
            -- Raids with LFR wing data get a wing-expand chevron on the pill
            -- row, positioned in RefreshIdleList.
            local hasWings = raid.lfrWings ~= nil
            -- Pill row text: sub-line indent and a blank plane-gutter
            -- width, the same prefix as the name row, so the pills start
            -- under the name. The wing chevron measures this same prefix.
            local rowIndent = RR.PILL_SUBLINE_INDENT .. RR.PILL_PLANE_GUTTER .. "  "
            table.insert(rows, {
                kind = "pillRow",
                text = rowIndent .. pills,
                raid = raid,
                hasWings = hasWings,
            })

            -- Wing rows inject below the pill: a header per wing with its own
            -- chevron, and the open wing's bosses one per row. Only one wing
            -- per raid is open at a time.
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

    -- A dungeon is ONE row: nav plane, name, then its lockout pills on the
    -- same line. Raids need a pill sub-line because they carry up to four
    -- pills over a boss count in double digits; a dungeon carries at most
    -- two (Heroic daily, Mythic weekly -- Normal never locks), so a second
    -- line would spend a whole row on a handful of characters. Halves the
    -- tallest lists: TBC and Wrath run 16 dungeons each.
    -- No skip-marker column -- dungeons have no skip mechanic -- so a
    -- dungeons view lights the entrance legend only.
    -- Multi-wing dungeons collapse under one heading. `wingOf` is the
    -- heading a dungeon belongs to (nil when it stands alone), and a wing
    -- row indents so its own plane sits under the FIRST LETTER of that
    -- heading -- the sub-line indent plus the plane gutter plus the two
    -- spaces the heading's name starts after.
    local WING_INDENT = 38

    local function emitDungeon(dungeon, wingOf)
        local name = RR:GetLocalizedRaidName(dungeon) or "??"
        -- Under a heading, the row carries only the part that differs.
        -- Stripped from the LOCALIZED name so the wing reads in the
        -- player's language; a locale that separates the two parts some
        -- other way keeps the full name, which is correct if wordier.
        if wingOf then
            name = name:match("^.- %- (.+)$") or name
        end
        local hasPlane = (RR:GetRaidEntrance(dungeon) ~= nil)
        if hasPlane then
            anyEntranceShown = true
        end
        -- Routed dungeons read white; the rest stay gray. Every dungeon
        -- lists for browsing and entrance navigation from day one, and
        -- routing arrives in phases, so the color says which ones can be
        -- run start to finish today.
        local isRouted = RR:InstanceHasRouting(dungeon)
        -- A Timewalking or current-season Mythic+ tag trails the name.
        -- Both are runtime-detected, so they follow their rotations with
        -- no data update.
        local leading = RR.PILL_SUBLINE_INDENT
        if wingOf then
            leading = leading .. RR.PillSpacer(WING_INDENT - 16)
        end
        local revealHex = isRouted and UI.RevealHex(dungeon) or nil
        local revealTemplate
        if revealHex then
            revealTemplate = (leading .. RR.PILL_PLANE_GUTTER .. "  |cff%s"
                .. name:gsub("%%", "%%%%") .. "|r"
                .. UI.InstanceTagText(dungeon):gsub("%%", "%%%%"))
        end
        table.insert(rows, {
            kind = "raidName",
            text = (leading .. RR.PILL_PLANE_GUTTER .. "  |cff%s%s|r%s")
                :format(revealHex or (isRouted and "ffffff" or "8a8a8a"), name,
                        UI.InstanceTagText(dungeon)),
            revealTemplate = revealTemplate,
            -- Rendered into its own cell at a shared x, not appended here:
            -- the pill column has to line up ACROSS rows.
            pillText = BuildIdleListPills(dungeon),
            raid = dungeon,
            hasPlane = hasPlane,
            -- 17 is PositionEntranceButton's own default, the raid rows'.
            planeInset = (wingOf and (WING_INDENT + 1) or 17),
        })
    end

    -- Heading for a set of wings: a toggle where a dungeon row keeps its
    -- plane, and the shared part of the name. Reads white when any wing
    -- below it is routed, matching the rule a single dungeon row follows.
    local function emitDungeonGroup(groupName, members)
        local anyRouted = false
        for _, member in ipairs(members) do
            if RR:InstanceHasRouting(member) then anyRouted = true break end
        end
        local groupExpanded = (RR.state and RR.state.expandedDungeonGroups
            and RR.state.expandedDungeonGroups[groupName]) == true
        -- The heading reads in the client's own words: the wings' journal
        -- names are already localized, and the shared half of one is the
        -- heading. No locale entry to keep -- the game translates these
        -- zone names itself, and a hand-kept copy could only go stale or
        -- disagree with what the player sees everywhere else. Falls back
        -- to the authored prefix if a locale separates the halves some
        -- other way.
        local localizedFull = RR:GetLocalizedRaidName(members[1]) or groupName
        local heading = localizedFull:match("^(.-) %- ") or groupName
        table.insert(rows, {
            kind = "dungeonGroup",
            groupName = groupName,
            expanded = groupExpanded,
            -- The same column the member rows put their planes in, so the
            -- expander lands under the planes rather than beside them.
            planeInset = 17,
            text = (RR.PILL_SUBLINE_INDENT
                .. RR.PILL_PLANE_GUTTER .. "  |cff%s%s|r")
                :format(anyRouted and "ffffff" or "8a8a8a", heading),
        })
        if groupExpanded then
            for _, member in ipairs(members) do
                emitDungeon(member, groupName)
            end
        end
    end

    -- Render an expansion's header. The toggle button (acquired and
    -- positioned by RefreshIdleList) anchors to the row's FontString;
    -- the row's text starts with leading-space padding so the button
    -- has visual room without overlapping the text.
    local function emitExpansion(exp, instances)
        table.sort(instances, patchDescending)
        table.insert(rows, {
            kind     = "expansionHeader",
            exp      = exp,
            expanded = isExpanded(exp),
            -- Routed dungeons the account has not opened this expansion
            -- for since they shipped; the header wears NEW until then.
            newInstances = dungeonMode and RR:UnseenRoutedDungeons(instances) or nil,
        })
        if isExpanded(exp) then
            if dungeonMode then
                -- Wings of one dungeon fold under a single heading. Keyed
                -- on the AUTHORED name, which is stable across locales,
                -- and only when two or more share a prefix -- a lone
                -- "X - Y" dungeon is not worth a heading of its own.
                local wingsOf, headingOrder = {}, {}
                for _, instance in ipairs(instances) do
                    local heading = instance.name:match("^(.-) %- ")
                                    or instance.name
                    if not wingsOf[heading] then
                        wingsOf[heading] = {}
                        headingOrder[#headingOrder + 1] = heading
                    end
                    table.insert(wingsOf[heading], instance)
                end
                for _, heading in ipairs(headingOrder) do
                    local members = wingsOf[heading]
                    if #members > 1 then
                        emitDungeonGroup(heading, members)
                    else
                        emitDungeon(members[1])
                    end
                end
            else
                for _, instance in ipairs(instances) do
                    emitRaid(instance)
                end
            end
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
        table.insert(rows, { kind = "emptyMessage", text = RR.L["|cff9d9d9d(no instance data loaded)|r"] })
    end

    -- The skip legend shows whenever any raid line is rendered, since every
    -- visible raid carries a star. Both legends render in a separate
    -- bottom-up pass so they pin above the action row at any list length.
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
    -- The expansion header's Timewalking hourglass is composed at render
    -- time, not carried in row text, so the live week and its remaining
    -- days must be part of the key or a late-arriving answer never paints.
    table.insert(parts, ("tw:%s:%s"):format(
        tostring(RR:GetActiveTimewalkingExpansion()),
        tostring(RR:GetTimewalkingEnd())))
    for i, row in ipairs(rows) do
        -- kind + text covers most rows; expansionHeader adds expanded
        -- flag (toggle glyph state); raidName / pillRow include their
        -- rendered text which captures kill counts via the pill string.
        local rowKind = row.kind or "?"
        local rowText = row.text or ""
        local expandedFlag = (row.expanded == true) and "1" or "0"
        local exp = row.exp or ""
        -- Wing rows carry no .text; serialize their content so expand/
        -- collapse and any kill-state change re-fingerprints (and re-renders).
        if rowKind == "wingHeader" and row.wing then
            local wing = row.wing
            rowText = ("%s|%d/%d|%s|%s"):format(
                wing.name or "", wing.complete or 0, wing.total or 0,
                wing.unmapped and "u" or "m",
                row.wingOpen and "o" or "c")
        elseif rowKind == "wingBoss" and row.boss then
            local boss = row.boss
            local kill = (boss.killed == true) and "1"
                or (boss.killed == false and "0" or "x")
            rowText = ("%s|%s|%s"):format(boss.name or "", kill,
                row.unmapped and "u" or "m")
        end
        -- A wing heading's open/closed state rides `expanded` like an
        -- expansion header's, and its identity is the heading name.
        if rowKind == "dungeonGroup" then
            exp = row.groupName or ""
        end
        parts[i] = ("%s|%s|%s|%s"):format(rowKind, expandedFlag, exp, rowText)
    end
    -- Salt with the list mode: a RAID | DUNGEON flip with every expansion
    -- collapsed produces identical header rows, and an unsalted match
    -- would skip the re-render that repaints the toggle's own state.
    return ((RR.state and RR.state.idleListMode) or "raid")
        .. "\n" .. table.concat(parts, "\n")
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
        RR.state.expandedDungeonGroups = {}
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
    UI.ReleaseIdlePillCells()
    ReleaseExpansionToggleButtons()
    ReleaseEntranceButtons()
    ReleasePillHoverFrames()
    UI.ReleaseNewTagLabels()
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

    -- Pill column for dungeon rows: one x-offset shared by every row,
    -- taken from the widest name actually on screen so the column sits as
    -- far left as the longest name allows. Measured with a hidden
    -- FontString at the render font, before any row is laid out.
    local pillColumnX = 0
    if not panel._idleMeasureFS then
        panel._idleMeasureFS = panel:CreateFontString(nil, "ARTWORK")
        panel._idleMeasureFS:Hide()
    end
    local measureFS = panel._idleMeasureFS
    SetBodyFont(measureFS, fontSize, "")
    local widestPill = 0
    for _, row in ipairs(rows) do
        if row.pillText and row.pillText ~= "" then
            measureFS:SetText(row.text or "")
            local nameWidth = measureFS:GetStringWidth() or 0
            if nameWidth > pillColumnX then pillColumnX = nameWidth end
            measureFS:SetText(row.pillText)
            local pillWidth = measureFS:GetStringWidth() or 0
            if pillWidth > widestPill then widestPill = pillWidth end
        end
    end
    if pillColumnX > 0 then
        pillColumnX = math.ceil(pillColumnX) + 12
        -- Never push the column so far right that the pills leave the
        -- panel; the longest name yields rather than the pills clipping.
        local lastFitting = BODY_WIDTH - widestPill
        if pillColumnX > lastFitting then
            pillColumnX = math.max(0, lastFitting)
        end
    end

    local prev = nil  -- previous FontString, for anchor chaining
    -- Running total of pixels the applied row gaps exceed ROW_GAP by.
    local extraSpacerGapPx = 0
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
                -- toggle button glyph anchored at LEFT. A trailing marker
                -- when this expansion's Timewalking week is the live one --
                -- trailing so the toggle and the name hold their column on
                -- every other week.
                -- Called inline rather than hoisted to a local: the
                -- engine caches the answer for 30s, only a dozen headers
                -- render, and UI.lua sits at the 200-local ceiling.
                local twMark, twDays = "", nil
                if row.exp == RR:GetActiveTimewalkingExpansion() then
                    twDays = RR:GetTimewalkingEnd()
                    twMark = " " .. UI.TimewalkingMarker(twDays)
                end
                local newMark, newLabel = "", nil
                if row.newInstances then
                    newLabel = UI.AcquireNewTagLabel()
                    SetBodyFont(newLabel, fontSize - UI.NEW_TAG_SIZE_DROP, "")
                    newLabel:SetText("|cffF259C7NEW|r")
                    fs:SetText(("    |cff00ffff%s|r  "):format(RR.L[row.exp]))
                    local nameWidth = fs:GetStringWidth() or 0
                    newLabel:ClearAllPoints()
                    newLabel:SetPoint("BOTTOMLEFT", fs, "BOTTOMLEFT", nameWidth, 1)
                    newLabel:Show()
                    newMark = "  " .. RR.PillSpacer(newLabel:GetStringWidth() or 0)
                end
                fs:SetText(("    |cff00ffff%s|r%s%s")
                    :format(RR.L[row.exp], newMark, twMark))
                -- Hover the GLYPH, not the heading: the marker sits at the
                -- end of the string, so the region is the last few pixels
                -- of the rendered width. Measured after SetText or the
                -- width is a frame behind.
                if twMark ~= "" then
                    local hoverFrame = AcquirePillHoverFrame()
                    local textWidth = fs:GetStringWidth() or 0
                    hoverFrame:ClearAllPoints()
                    hoverFrame:SetPoint("TOPLEFT", fs, "TOPLEFT",
                        textWidth - UI.TIMEWALKING_MARKER_W, 0)
                    hoverFrame:SetPoint("BOTTOMRIGHT", fs, "BOTTOMLEFT",
                        textWidth, 0)
                    hoverFrame:Show()
                    hoverFrame._lockoutModel = nil
                    hoverFrame._underDevelopment = nil
                    hoverFrame._seasonal = nil
                    hoverFrame._timewalking = true
                    hoverFrame._timewalkingDays = twDays
                    table.insert(panel.pillHoverFrames, hoverFrame)
                end
            elseif row.kind == "wingHeader" then
                -- Wing header: "WingName (n/N)", one level under the pill row.
                -- Green when fully cleared, gray otherwise. An unmapped wing
                -- appends a small gray flag. Leads with the sub-line indent so
                -- it sits under the pill row, then its own spaces step further.
                local wing = row.wing
                local hex = (wing.total > 0 and wing.complete >= wing.total)
                    and "00ff00" or "888888"
                local marker = wing.unmapped and " |cff888888*|r" or ""
                fs:SetText((RR.PILL_SUBLINE_INDENT .. "        |cff%s%s|r |cff9d9d9d(%d/%d)|r%s"):format(
                    hex, wing.name, wing.complete or 0, wing.total or 0, marker))
            elseif row.kind == "wingBoss" then
                -- One boss per line, a further level under the wing header.
                -- Dead = faded gray; alive = white; unmapped wing's bosses
                -- render neutral lavender. Leads with the sub-line indent like
                -- the wing header.
                local boss = row.boss
                local hex
                if row.unmapped then
                    hex = "b9a3d6"       -- pending (per-boss state unknown)
                elseif boss.killed then
                    hex = "6f6f6f"       -- dead, faded
                else
                    hex = "ffffff"       -- alive
                end
                fs:SetText((RR.PILL_SUBLINE_INDENT .. "            |cff%s%s|r"):format(hex, boss.name))
            else
                -- raidName / pillRow / emptyMessage all carry pre-built
                -- text strings.
                fs:SetText(row.text or "")
            end

            -- Search-jump target: the flash finds this row by instance.
            fs._searchInstanceID = row.raid and row.raid.instanceID or nil
            fs._revealTemplate = row.revealTemplate
            fs._revealInstance = row.revealTemplate and row.raid or nil

            -- Anchor: top of the list for the first row, BOTTOMLEFT of
            -- the previous row otherwise. The previous row may have set
            -- _nextGap (if a spacer preceded this row); use that gap
            -- instead of the default ROW_GAP.
            fs:ClearAllPoints()
            if prev then
                local gap = prev._nextGap or ROW_GAP
                prev._nextGap = nil
                -- AutoSize reserves height assuming every row advances by
                -- ROW_GAP. A spacer gap is wider, and spacers get no
                -- FontString of their own, so the surplus is invisible to a
                -- row count. Bank it here, where the gap is actually applied,
                -- for AutoSize to add to its reserve.
                extraSpacerGapPx = extraSpacerGapPx + (gap - ROW_GAP)
                fs:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -gap)
            else
                fs:SetPoint("TOPLEFT", panel.listHeader, "BOTTOMLEFT", 0, -8)
            end
            fs:Show()

            -- Every pill row gets an invisible hover frame on top so the
            -- lockout-info tooltip can fire (the FontString itself can't
            -- take mouse events). The tooltip names the raid's lockout
            -- system (shared / LFR-split / independent), which applies to
            -- the whole row, LFR pill included -- so the overlay covers the
            -- full rendered pill string.
            -- Dungeon pills: their own cell at the shared column x, so the
            -- column is straight by construction at any font or scale.
            if row.pillText and row.pillText ~= "" then
                local pillCell = UI.AcquireIdlePillCell()
                SetBodyFont(pillCell, fontSize, "")
                pillCell:SetText(row.pillText)
                pillCell:ClearAllPoints()
                pillCell:SetPoint("LEFT", fs, "LEFT", pillColumnX, 0)
                pillCell:Show()
                table.insert(panel.idlePillCells, pillCell)
            end

            -- Where the row's rendered content ends, measured from the
            -- name's left edge. A dungeon row's pills sit in their own cell
            -- past the name, so anything anchoring to the row's right edge
            -- has to reach the column rather than stopping at the name's
            -- width. Read by the hover region and by the travel toast.
            local rowContentRight = fs:GetStringWidth() or 0
            if row.pillText and row.pillText ~= "" then
                rowContentRight = pillColumnX + widestPill
            end

            local needsDevTip = (row.raid ~= nil
                and row.raid.kind == "dungeon"
                and not RR:InstanceHasRouting(row.raid)) or false
            if row.kind == "pillRow" or row.raid ~= nil
                or (row.pillText and row.pillText ~= "") then
                local hoverFrame = AcquirePillHoverFrame()
                hoverFrame:ClearAllPoints()
                hoverFrame:SetPoint("TOPLEFT", fs, "TOPLEFT", 0, 0)
                hoverFrame:SetPoint("BOTTOMRIGHT", fs, "BOTTOMLEFT",
                    rowContentRight, 0)
                hoverFrame:Show()
                hoverFrame._lockoutModel =
                    row.raid and (row.raid.difficultyModel or "independent") or nil
                -- Dungeons ship for browsing first and gain routing in
                -- phases; the gray name says so and this says why. Raids
                -- are all routed, so the flag is dungeon-only rather than
                -- a general has-no-routing test.
                hoverFrame._underDevelopment = needsDevTip or nil
                -- A row wearing a tag leads its tooltip with that tag's
                -- line; the lockout gloss follows under it.
                hoverFrame._timewalking =
                    (row.raid and RR:IsTimewalkingLive(row.raid)) or nil
                hoverFrame._seasonal =
                    (row.raid and RR:IsSeasonalDungeon(row.raid)) or nil
                table.insert(panel.pillHoverFrames, hoverFrame)
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
                local glyphSize = math.floor(fontSize * 0.83)
                btn:SetSize(glyphSize, glyphSize)
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
                if ff then SafeSetFont(mfs, ff, fsz or fontSize, ffl or "") end
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
                local glyphSize = math.floor(fontSize * 0.71)
                btn:SetSize(glyphSize, glyphSize)
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
                local newInstances = row.newInstances
                btn:SetScript("OnClick", function()
                    -- Opening the expansion is what counts as seeing its
                    -- new dungeons; the NEW tag goes with this click.
                    if newInstances then
                        RR:MarkRoutedDungeonsSeen(newInstances)
                        UI.BeginRowReveal(newInstances)
                    end
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

            -- Wing heading: the same toggle an expansion header uses, but
            -- sitting in the column a dungeon row gives its plane.
            -- Independent per heading rather than an accordion -- a set of
            -- wings is short, and closing one to open another would fight
            -- the reason they were folded up in the first place.
            if row.kind == "dungeonGroup" then
                local btn = AcquireExpansionToggleButton()
                PositionExpansionToggleButton(btn, fs, row.expanded)
                btn:ClearAllPoints()
                -- Centered on the member rows' plane column: same inset
                -- they use, plus half the difference in glyph size (a
                -- plane is 1.4x the toggle), so the two share an axis.
                local planeSize = math.floor(fontSize * 1.4)
                btn:SetPoint("LEFT", fs, "LEFT",
                    (row.planeInset or 17)
                        + math.floor((planeSize - fontSize) / 2), 0)
                local groupName = row.groupName
                btn:SetScript("OnClick", function()
                    RR.state = RR.state or {}
                    RR.state.expandedDungeonGroups =
                        RR.state.expandedDungeonGroups or {}
                    local isOpen = RR.state.expandedDungeonGroups[groupName]
                    RR.state.expandedDungeonGroups[groupName] =
                        (not isOpen) or nil
                    if RR.UI and RR.UI.Update then RR.UI.Update() end
                end)
                btn:Show()
                table.insert(panel.expansionToggleButtons, btn)
            end

            -- Nav button at a fixed left inset so every plane lands in one
            -- vertical column, on the name row for raids and dungeons
            -- alike (marked by hasPlane). Clicking opens
            -- the LFR/Standard chooser, which navigates straight to the
            -- entrance when there are no wings to choose between -- every
            -- dungeon takes that path. Alpha: full-color when any nav
            -- provider above bare-Blizzard is installed, muted otherwise.
            if row.hasPlane and row.raid and RR:GetRaidEntrance(row.raid) then
                local btn = AcquireEntranceButton()
                PositionEntranceButton(btn, fs, row.planeInset)
                local raid = row.raid
                local anyProviderInstalled = RR:IsAWPInstalled()
                    or RR:IsZygorInstalled()
                    or RR:IsMapzerothInstalled()
                    or RR:IsWUIInstalled()
                    or RR:IsTomTomInstalled()
                btn:SetAlpha(anyProviderInstalled and 1.0 or 0.4)
                local rowFS, rowRight = fs, rowContentRight
                btn:SetScript("OnClick", function(self)
                    panel.ShowNavChooser(self, raid, rowFS, rowRight)
                end)
                btn:Show()
                table.insert(panel.entranceButtons, btn)
            end

            table.insert(panel.idleListLines, fs)
            prev = fs
        end
    end

    panel._idleListExtraGapPx = extraSpacerGapPx

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
            panel._idleLegendRows = (panel._idleLegendRows or 0) + 1
            fs:ClearAllPoints()
            if lastLegendTopFS then
                fs:SetPoint("BOTTOMLEFT", lastLegendTopFS, "TOPLEFT", 0, LEGEND_INTER_GAP)
            else
                fs:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD_LEFT, LEGEND_BOTTOM_OFFSET)
            end
            fs:Show()
            table.insert(panel.idleListLegendLines, fs)
            topFS = fs

        elseif row.kind == "entranceLegend" then
            -- Two FontStrings per row (label + data) so the data column aligns
            -- despite proportional-font label widths. Labels chain upward
            -- against each other; each data string anchors to its own label at
            -- a fixed offset. Rendered bottom-up so each anchor target exists.
            local entranceRows = BuildEntranceLegend()
            panel._idleLegendRows = (panel._idleLegendRows or 0) + #entranceRows
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
            local placedRows = {}
            local labelRightMax = 0
            for j = #entranceRows, 1, -1 do
                local rowSpec = entranceRows[j]
                -- LABEL FontString
                local labelFS = AcquireIdleListLine()
                SetBodyFont(labelFS, LEGEND_FONT_SIZE, "")
                if rowSpec.withMarker then
                    labelFS:SetText("|cff9d9d9d" .. EntranceMarker() .. " = |r" .. rowSpec.label)
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

                -- Data FontStrings are placed after ALL labels exist
                -- (second pass below): the shared data column must
                -- clear the widest rendered label, and label widths
                -- vary by locale, so this pass only tracks the running
                -- maximum of each label's right edge (left offset +
                -- rendered string width).
                local labelRight = xOffsetFor(rowSpec) + labelFS:GetStringWidth()
                if labelRight > labelRightMax then labelRightMax = labelRight end
                table.insert(placedRows, { labelFS = labelFS, spec = rowSpec })

                if not bottomFS then bottomFS = labelFS end
                topFS = labelFS
                prevLabelFS = labelFS
                prevSpec = rowSpec
            end

            -- DATA FontStrings -- one shared x column so the provider
            -- names align vertically across rows. The column sits at
            -- the fixed design position OR just past the widest label,
            -- whichever is farther right: labels wider than the design
            -- width (localized "Waypoint: ") push the column out
            -- instead of being overdrawn. Each row anchors relative to
            -- its own label, compensating that row's indent, so the
            -- shared column holds regardless of the row-1 marker
            -- prefix. The Y matches the label for a shared baseline.
            local dataColumnX = LEGEND_DATA_COLUMN
            if labelRightMax + 8 > dataColumnX then
                dataColumnX = labelRightMax + 8
            end
            for _, placed in ipairs(placedRows) do
                local dataFS = AcquireIdleListLine()
                SetBodyFont(dataFS, LEGEND_FONT_SIZE, "")
                dataFS:SetText(placed.spec.data)
                dataFS:ClearAllPoints()
                dataFS:SetPoint("LEFT", placed.labelFS, "LEFT",
                    dataColumnX - xOffsetFor(placed.spec), 0)
                dataFS:Show()
                table.insert(panel.idleListLegendLines, dataFS)
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
    -- Centerd in the band between the last row and the legend, so the
    -- clearance above the rule matches the clearance below it. A fixed
    -- distance from the row held the gap above steady across lists but left
    -- the gap below to whatever the footer reserve had going spare, which
    -- ran about twice as wide.
    --
    -- Anchored by its CENTER so the rule's visual center lands on the
    -- target; anchoring by TOPLEFT hangs the rule and its taller gem below
    -- by half their height (the off-center bug).
    -- Screen Y grows upward, so the midpoint of the two edges is the
    -- symmetric point, and it stays between them however tight the band
    -- gets on a long list.
    local mid = (rowBottom + legendTop) / 2
    local dyFromRow = rowBottom - mid               -- downward distance from the row bottom to the rule
    panel.legendDivider:ClearAllPoints()
    panel.legendDivider:SetPoint("CENTER", lastList, "BOTTOMLEFT", BODY_WIDTH / 2, -dyFromRow)
    panel.legendDivider:SetWidth(BODY_WIDTH)
    panel.legendDivider:Show()
    if panel.legendDividerGem then panel.legendDividerGem:Show() end
end

-------------------------------------------------------------------------------
-- Main update
-------------------------------------------------------------------------------

-- Idle header sentence with the RAID | DUNGEON mode toggle embedded at its
-- %s slot, switching which instance list the idle picker shows. Same look
-- as the settings Enable | Disable pairs: the selected word cyan with a
-- 1px magenta underline, the other dim. Built once; laid out and refreshed per
-- idle render.
function UI.EnsureIdleModeLine()
    if panel.idleModeLine then return panel.idleModeLine end
    local line = {}
    local pattern = RR.L["Choose a %s to begin."]
    local prefixText, suffixText = pattern:match("^(.-)%%s(.*)$")
    if not prefixText then prefixText, suffixText = pattern, "" end

    -- The sentence's own spaces around %s are dropped: a FontString
    -- trims a trailing space from its width but renders a leading one, so
    -- keeping them would gap one side of the toggle by nothing and the
    -- other by a font-dependent advance. Layout spaces both sides itself.
    line.prefix = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line.prefix:SetText((prefixText:gsub("%s+$", "")))
    line.suffix = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line.suffix:SetText((suffixText:gsub("^%s+", "")))
    line.sep = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line.sep:SetText("|")
    line.sep:SetTextColor(0.62, 0.62, 0.62)

    local function MakeWord(word)
        local btn = CreateFrame("Button", nil, panel)
        local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetText(word)
        fs:SetPoint("TOPLEFT", btn, "TOPLEFT")
        btn.fs = fs
        -- Magenta underline under the selected word, one PHYSICAL pixel
        -- tall. Texel snapping off and pixel-grid snapping off: a hairline
        -- at a fractional coordinate can round away to nothing at some UI
        -- scales, and this line sits at chained (fractional) anchors. Height
        -- is re-applied in Layout so a scale change does not leave it stale.
        local underline = btn:CreateTexture(nil, "ARTWORK")
        underline:SetColorTexture(C_PINK[1], C_PINK[2], C_PINK[3], 1)
        underline:SetHeight(1 / (underline:GetEffectiveScale() or 1))
        if underline.SetTexelSnappingBias then
            underline:SetTexelSnappingBias(0)
            underline:SetSnapToPixelGrid(false)
        end
        underline:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
        underline:SetPoint("TOPRIGHT", fs, "BOTTOMRIGHT", 0, -2)
        underline:Hide()
        btn.underline = underline
        return btn
    end
    line.raidBtn    = MakeWord(RR.L["RAID"])
    line.dungeonBtn = MakeWord(RR.L["DUNGEON"])

    local function SetMode(mode)
        RR.state = RR.state or {}
        if RR.state.idleListMode == mode then return end
        RR.state.idleListMode = mode
        UI.InvalidateIdleListCache()
        UI.Update()
    end
    line.raidBtn:SetScript("OnClick", function() SetMode("raid") end)
    line.dungeonBtn:SetScript("OnClick", function() SetMode("dungeon") end)

    -- Selected word cyan + underlined, the other dim. Mirrors the settings
    -- pair's Refresh.
    line.Refresh = function()
        local dungeonMode = (RR.state and RR.state.idleListMode) == "dungeon"
        local function paint(btn, selected)
            if selected then
                btn.fs:SetTextColor(0.30, 0.80, 1.00)
            else
                btn.fs:SetTextColor(0.62, 0.62, 0.62)
            end
            btn.underline:SetShown(selected)
        end
        paint(line.raidBtn, not dungeonMode)
        paint(line.dungeonBtn, dungeonMode)
    end

    -- Fonts the pieces at the current body size and chains them from the
    -- (empty) progress FontString's top-left, so the sentence sits exactly
    -- where the old one-string prompt rendered.
    line.Layout = function(fontSize)
        for _, fs in ipairs({ line.prefix, line.suffix, line.sep,
                              line.raidBtn.fs, line.dungeonBtn.fs }) do
            SetBodyFont(fs, fontSize, "")
        end
        for _, btn in ipairs({ line.raidBtn, line.dungeonBtn }) do
            btn:SetSize(math.max(1, btn.fs:GetStringWidth() or 1),
                (btn.fs:GetStringHeight() or fontSize) + 4)
            btn.underline:SetHeight(1 / (btn.underline:GetEffectiveScale() or 1))
        end
        -- Word gap either side of the toggle, separator gap either side
        -- of the bar. Both scale off the body size, which the font slider
        -- drives -- at a fixed value the glyphs grow and the words close
        -- on the bar. Both resolve to the tuned 4 and 6 at size 12.
        local wordGap = math.max(1, math.floor(fontSize * 4 / 12 + 0.5))
        local sepGap  = math.max(1, math.floor(fontSize * 6 / 12 + 0.5))
        -- A locale can open or close the sentence on %s. An absent piece
        -- takes no gap, or the run leads with a stray indent.
        local headGap = ((line.prefix:GetText() or "") ~= "") and wordGap or 0
        local tailGap = ((line.suffix:GetText() or "") ~= "") and wordGap or 0
        -- Every piece TOP-anchors to the previous one. All five render
        -- the same font at the same size, so aligned tops mean aligned
        -- baselines -- LEFT-chaining centered the taller button boxes on
        -- the text line and floated the toggle words a few pixels high.
        -- Centered on the body column: the pieces are five separate
        -- widgets, so the run is measured and the head offset by half the
        -- slack. Gaps are counted at the same values the anchors use
        -- below, or the centering drifts by their total.
        local runWidth = (line.prefix:GetStringWidth() or 0)
            + headGap + (line.raidBtn.fs:GetStringWidth() or 0)
            + sepGap + (line.sep:GetStringWidth() or 0)
            + sepGap + (line.dungeonBtn.fs:GetStringWidth() or 0)
            + tailGap + (line.suffix:GetStringWidth() or 0)
        local centerOffset = math.max(0,
            math.floor((BODY_WIDTH - runWidth) / 2))

        line.prefix:ClearAllPoints()
        line.prefix:SetPoint("TOPLEFT", panel.progress, "TOPLEFT",
            centerOffset, 0)
        line.raidBtn:ClearAllPoints()
        line.raidBtn:SetPoint("TOPLEFT", line.prefix, "TOPRIGHT", headGap, 0)
        -- Equal gaps either side of the bar's box read centered on screen.
        line.sep:ClearAllPoints()
        line.sep:SetPoint("TOPLEFT", line.raidBtn, "TOPRIGHT", sepGap, 0)
        line.dungeonBtn:ClearAllPoints()
        line.dungeonBtn:SetPoint("TOPLEFT", line.sep, "TOPRIGHT", sepGap, 0)
        line.suffix:ClearAllPoints()
        line.suffix:SetPoint("TOPLEFT", line.dungeonBtn, "TOPRIGHT", tailGap, 0)
    end

    line.SetShown = function(shown)
        for _, widget in ipairs({ line.prefix, line.suffix, line.sep,
                                  line.raidBtn, line.dungeonBtn }) do
            widget:SetShown(shown)
        end
    end

    panel.idleModeLine = line
    return line
end

function UI.Update()
    if not RetroRunsDB or not RR:IsPanelAllowed() then
        panel:Hide()
        return
    end

    -- The idle-mode toggle line only belongs to the plain-idle branch
    -- below; every other state hides it before rendering.
    if panel.idleModeLine then panel.idleModeLine.SetShown(false) end

    panel:Show()
    UI.ApplySettings()
    UI.UpdateAmbientArt()

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
            routeLabel = "|cff00ffff" .. RR.L["Skip"] .. "|r"
        else
            routeLabel = "|cff00ff00" .. RR.L["Full"] .. "|r"
        end
        panel.credit:SetText(RR.L["|cff9d9d9dRoute:|r "] .. routeLabel)
    else
        panel.credit:SetText(RR.L["Created by |cff4DCCFFPhotek|r"])
    end


    if raid and loaded then
        -- Raid name only; kill state lives in the pills row below. A trailing
        -- star marks a difficulty at or below the account's skip ceiling.
        --
        -- Faction marker for raids with per-faction data; symmetric raids get
        -- none.
        local raidLabel = ((raid.kind == "dungeon") and RR.L["Dungeon: "]
            or RR.L["Raid: "]) .. (RR:GetLocalizedRaidName(raid) or raid.name)
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
                SafeSetFont(panel.wingLine, rfFont, rfSize - 2, rfFlags)
            end
            local WING_ARROW = "|TInterface\\ChatFrame\\ChatFrameExpandArrow:10:10:0:0:32:32:0:32:0:32:242:89:199|t"
            local wingName = RR:GetCurrentWingName() or wing.name
            panel.wingLine:SetText(
                "  " .. WING_ARROW ..
                " |cff9d9d9d" .. RR.L["LFR Wing:"] .. "|r |cffF259C7" .. wingName .. "|r")
        else
            panel.wingLine:SetText("")
        end
        local pillsText = BuildPillsText()
        panel.pills:SetText(pillsText)
        -- Arm the lockout-info tooltip for every loaded raid: it names the
        -- raid's lockout system (shared / LFR-split / independent), which is
        -- useful before any kill commits a difficulty, not only when the
        -- lock glyph shows. Covers the whole pill row -- the info applies to
        -- every pill in it, LFR included.
        if panel.pillsHover then
            panel.pillsHover._lockoutTip = true
            panel.pillsHover._lockoutModel = raid.difficultyModel
            panel.pillsHover:ClearAllPoints()
            -- The pill row is centered in a full-width FontString, so the
            -- text starts well right of the string's own left edge; the
            -- hover region has to follow the text, not the frame.
            local pillsTextW = panel.pills:GetStringWidth() or 0
            local pillsInset = math.max(0,
                ((panel.pills:GetWidth() or pillsTextW) - pillsTextW) / 2)
            panel.pillsHover:SetPoint("TOPLEFT", panel.pills, "TOPLEFT",
                pillsInset, 0)
            panel.pillsHover:SetPoint("BOTTOM", panel.pills, "BOTTOM", 0, 0)
            panel.pillsHover:SetWidth(pillsTextW + 2)
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
            -- LFR wings have different boss subsets and paths than the routing
            -- data is authored for, so the panel shows one message in place of
            -- routing. The action button row stays visible.
            local wingName = RR:GetCurrentWingName()
            if wingName then
                panel.next:SetText(("|cffffffff" .. RR.L["LFR routing for"] .. " |r|cffF259C7%s|r|cffffffff " .. RR.L["isn't supported yet."] .. "|r"):format(wingName))
            else
                panel.next:SetText(RR.L["|cffffffffLFR routing isn't supported yet.|r"])
            end
            panel.travel:SetText("")
            panel.exitNote:SetText("")
            panel.exitNote:Hide()
            panel.exitNoteExtra:SetText("")
            panel.exitNoteExtra:Hide()
            panel.skipReturn:SetText("")
            panel.skipReturn:Hide()
            panel.skipNote:SetText("")
            panel.skipNote:Hide()
            panel.encounter.headerPulsing = false
            panel.encounter.header.label:SetText("")
            panel.encounter.header.clickable = false
            panel.encounter.skip:Hide()
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
            -- Optional bosses name themselves as such on the header row.
            -- Appended outside the name so no color code has to nest.
            local optionalTag = (boss and RR.IsBossOptional
                and RR:IsBossOptional(boss.index))
                and (" |cff808080" .. RR.L["(optional)"] .. "|r") or ""
            panel.next:SetText(RR.L["|cffffffffBoss:|r "]
                .. ((boss and RR:GetLocalizedBossName(boss)) or RR.L["Unknown"])
                .. optionalTag)
            panel.travel:SetText(BuildTravelText(step))
            panel.exitNote:SetText("")
            panel.exitNote:Hide()
            panel.exitNoteExtra:SetText("")
            panel.exitNoteExtra:Hide()
            panel.skipReturn:SetText("")
            panel.skipReturn:Hide()
            panel.skipNote:SetText("")
            panel.skipNote:Hide()
            local headerText, achText, specialText, encClickable,
                  headerPulsing = BuildEncounterText(step)

            -- Header sub-widget: shows the Boss Encounter line; OnClick
            -- toggles soloTip expand/collapse when clickable is true.
            -- headerPulsing tells the [!] pulse ticker it may refresh
            -- this label's text in place between full updates.
            panel.encounter.headerPulsing = headerPulsing
            panel.encounter.header.label:SetText(headerText or "")
            panel.encounter.header.clickable = encClickable
            panel.encounter.header:EnableMouse(encClickable)
            local headerH = math.max(14, panel.encounter.header.label:GetStringHeight())
            panel.encounter.header:SetHeight(headerH)

            -- Skip control, inline after the header text. Only while the
            -- note is collapsed: expanded, the header wraps the whole
            -- soloTip and there is no predictable end-of-line to sit after.
            local skipBtn = panel.encounter.skip
            local skipBoss = step and RR.IsBossOptional
                and RR:IsBossOptional(step.bossIndex)
                and not RR:GetSetting("encounterExpanded")
            if skipBoss then
                skipBtn.bossIndex = step.bossIndex
                SetBodyFont(skipBtn.label, RR:GetSetting("fontSize", 12), "")
                -- Leading space rather than a pixel gap: the header text
                -- ends flush, so one space is exactly one space at any
                -- font size.
                skipBtn.label:SetText(" |cffaaaaaa" .. RR.L["or"]
                    .. "|r |cffF259C7[" .. RR.L["Skip Boss"] .. "]|r")
                skipBtn:SetSize(math.max(1, skipBtn.label:GetStringWidth()), headerH)
                skipBtn:ClearAllPoints()
                skipBtn:SetPoint("TOPLEFT", panel.encounter.header, "TOPLEFT",
                    panel.encounter.header.label:GetStringWidth(), 0)
                skipBtn:Show()
            else
                skipBtn.bossIndex = nil
                skipBtn:Hide()
            end

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
            -- Only children that actually render are counted, each with one
            -- section gap ahead of it. Counting a hidden child's 1px
            -- placeholder AND its gap left dead space at the wrapper's
            -- foot, which read as a wider gap above the transmog line.
            local totalH = headerH
            if panel.encounter.achievements:IsShown() then
                totalH = totalH + UI.PANEL_SECTION_GAP
                       + (panel.encounter.achievements:GetHeight() or 1)
            end
            if panel.encounter.specialLoot:IsShown() then
                totalH = totalH + UI.PANEL_SECTION_GAP
                       + (panel.encounter.specialLoot:GetHeight() or 1)
            end
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

            -- In-progress state: "Boss Progress" over the per-boss kill
            -- checklist, anchored under the last VISIBLE widget above it.
            -- A boss that drops nothing with an appearance (Zul'Farrak's
            -- Theka the Martyr) produces no transmog summary, and a hidden
            -- FontString keeps its reserved height and position -- always
            -- anchoring to it left a band of empty panel above the list.
            panel.listHeader:ClearAllPoints()
            panel.listHeader:SetPoint("TOPLEFT",
                panel.transmog:IsShown() and panel.transmog or panel.encounter,
                "BOTTOMLEFT", 0, -UI.PANEL_SECTION_GAP)
            if RR.state.testMode then
                panel.listHeader:SetText(RR.L["Boss Progress  |cffffff00[ TEST MODE ]|r"])
            else
                panel.listHeader:SetText(RR.L["Boss Progress"])
            end
            UI.RenderBossProgressList()
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
            -- Completion keys off IsActiveRouteComplete, not a step-count
            -- comparison, so a skip route with fewer steps than bosses still
            -- reaches complete on its last boss. An unauthored route returns
            -- false, keeping the "not yet captured" state for bring-ups.
            local routeComplete = RR.IsActiveRouteComplete and RR:IsActiveRouteComplete()
            local isSkip = (RR.state and RR.state.activeRouteVariant == "skip")
                or (RR.ActiveRouteSkippedOptionalBoss
                    and RR:ActiveRouteSkippedOptionalBoss())

            -- Run-complete state: every boss in the active route cleared.
            -- Drops the Travel line, re-anchors listHeader under the exit
            -- note (or panel.next when there's no exit note), and shows the
            -- idle per-raid pill list instead of the boss checklist.
            -- Uncaptured-raid state (routeComplete=false) uses the same
            -- layout with different text.
            if routeComplete then
                if RR:GetActiveWing() then
                    panel.next:SetText(RR.L["|cff00ff00LFR Wing Complete!|r"])
                elseif isSkip then
                    panel.next:SetText(RR.L["|cff00ff00Skip Run Complete!|r"])
                else
                    panel.next:SetText(RR.L["|cff00ff00Run complete!|r"])
                end
                -- Optional per-raid exit note, shown below the banner with an
                -- inline exit glyph. Wing-aware selection lives in the engine
                -- (GetActiveExitNote) so the minimized bar shows the same note.
                local exitNote = RR:GetActiveExitNote()
                local exitFontSize = RR:GetSetting("fontSize", 12)
                -- A skip run ends with a boss still alive, so the block under
                -- the banner invites the player back and says plainly that
                -- routing stays down for the rest of the lockout. The caveat
                -- rides its own field: two points down and indented, which
                -- one FontString cannot express.
                -- A lockout-less run ends ready to be run again. A skipped
                -- one can also end that way -- dungeons carry optional
                -- bosses now -- so the two compose rather than excluding
                -- each other, and the routing caveat gives way to the reset
                -- reminder there: it names a lockout the instance does not
                -- have, and a reset brings routing back.
                local lockoutlessDungeon = RR.currentRaid
                    and RR.currentRaid.kind == "dungeon"
                    and not RR:GetCurrentLockoutId()
                if isSkip or lockoutlessDungeon then
                    local returnLines = {}
                    if isSkip and not (RR.SkippedBossesUnreturnable
                        and RR:SkippedBossesUnreturnable()) then
                        returnLines[#returnLines + 1] =
                            RR.L["Feel free to return and kill any bosses you skipped!"]
                    end
                    if lockoutlessDungeon then
                        -- The game's own menu term rides a caret span,
                        -- localized by the client.
                        local resetTerm = "^"
                            .. (RESET_INSTANCES or "Reset all instances") .. "^"
                        returnLines[#returnLines + 1] =
                            (RR.L["Want to run it again? Zone out and %s."]):format(resetTerm)
                    end
                    panel.skipReturn:SetText(HighlightNames(
                        table.concat(returnLines, " ")))
                    panel.skipReturn:SetTextColor(1, 1, 1)
                    SetBodyFont(panel.skipReturn, exitFontSize, "")
                    panel.skipReturn:Show()

                    -- The cap itself lives in the footer counter, which is
                    -- on screen here too; repeating it under the banner said
                    -- the same number twice.
                    if lockoutlessDungeon then
                        panel.skipNote:SetText("")
                        panel.skipNote:Hide()
                    else
                        panel.skipNote:SetText("|cff9d9d9d"
                            .. RR.L["Note: Routing will not be available on this lockout"]
                            .. "|r")
                        SetBodyFont(panel.skipNote, math.max(8, exitFontSize - 2), "")
                        panel.skipNote:Show()
                    end
                else
                    panel.skipReturn:SetText("")
                    panel.skipReturn:Hide()
                    panel.skipNote:SetText("")
                    panel.skipNote:Hide()
                end
                if exitNote and exitNote ~= "" then
                    local exitGlyphSize = exitFontSize + 3
                    panel.exitNote:SetText(
                        ("|TInterface\\AddOns\\RetroRuns\\Media\\Icons\\ExitIcon:%d:%d:0:-1:64:64:0:64:0:64:242:89:199|t ")
                            :format(exitGlyphSize, exitGlyphSize) ..
                        "|cfff259c7" .. RR.L["Exit Note:"] .. "|r "
                        .. HighlightNames(exitNote))
                    panel.exitNote:SetTextColor(1, 1, 1)
                    SetBodyFont(panel.exitNote, exitFontSize, "")
                    panel.exitNote:Show()
                else
                    panel.exitNote:SetText("")
                    panel.exitNote:Hide()
                end
                -- The exit note closes the block, so on a skip run it moves
                -- below the caveat and dedents back to the block's left edge.
                panel.exitNote:ClearAllPoints()
                if panel.skipNote:IsShown() then
                    panel.exitNote:SetPoint("TOPLEFT", panel.skipNote, "BOTTOMLEFT", -12, -13)
                elseif panel.skipReturn:IsShown() then
                    panel.exitNote:SetPoint("TOPLEFT", panel.skipReturn, "BOTTOMLEFT", 0, -13)
                else
                    panel.exitNote:SetPoint("TOPLEFT", panel.next, "BOTTOMLEFT", 0, -13)
                end
                -- Below the exit note, on its own line: the boss the route
                -- never sent the player to, and what is left to collect
                -- there. Hangs off panel.exitNote, so it follows wherever
                -- the note moved to.
                local exitExtra = RR.GetExitNoteExtra and RR:GetExitNoteExtra()
                if exitExtra and exitExtra ~= "" then
                    -- Orange "Note:" label, the way the exit note above it
                    -- carries its own magenta one, so the two lines read as
                    -- a pair of labelled notes rather than a run-on.
                    panel.exitNoteExtra:SetText(
                        OrangeText(RR.L["Note:"]) .. " "
                        .. HighlightNames(exitExtra))
                    panel.exitNoteExtra:SetTextColor(1, 1, 1)
                    SetBodyFont(panel.exitNoteExtra, exitFontSize, "")
                    panel.exitNoteExtra:Show()
                else
                    panel.exitNoteExtra:SetText("")
                    panel.exitNoteExtra:Hide()
                end
            else
                -- Dungeons list and load before their routes exist, by
                -- design -- browsing, the toaster and boss progress all
                -- work meanwhile -- so they say so rather than reading as
                -- missing data.
                if raid.kind == "dungeon" then
                    panel.next:SetText(("|cffff9333%s|r"):format(
                        (RR.L["%s is under development."]):format(
                            RR:GetLocalizedRaidName(raid) or raid.name)))
                else
                    panel.next:SetText(RR.L["|cffff9333Routing data not yet captured for this instance.|r"])
                end
                panel.exitNote:SetText("")
                panel.exitNote:Hide()
                panel.exitNoteExtra:SetText("")
                panel.exitNoteExtra:Hide()
                panel.skipReturn:SetText("")
                panel.skipReturn:Hide()
                panel.skipNote:SetText("")
                panel.skipNote:Hide()
            end
            panel.travel:SetText("")
            panel.encounter.headerPulsing = false
            panel.encounter.header.label:SetText("")
            panel.encounter.header.clickable = false
            panel.encounter.skip:Hide()
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

            -- Hang off the LOWEST block that actually rendered. skipNote
            -- is not always the bottom of its pair: a lockout-less dungeon
            -- shows the comeback line with no note under it, and skipping
            -- straight to panel.next there drew the list over that line.
            -- skipNote carries a 12px indent of its own, hence the -12.
            panel.listHeader:ClearAllPoints()
            if panel.exitNoteExtra:IsShown() then
                panel.listHeader:SetPoint("TOPLEFT", panel.exitNoteExtra, "BOTTOMLEFT", 0, -12)
            elseif panel.exitNote:IsShown() then
                panel.listHeader:SetPoint("TOPLEFT", panel.exitNote, "BOTTOMLEFT", 0, -12)
            elseif panel.skipNote:IsShown() then
                panel.listHeader:SetPoint("TOPLEFT", panel.skipNote, "BOTTOMLEFT", -12, -12)
            elseif panel.skipReturn:IsShown() then
                panel.listHeader:SetPoint("TOPLEFT", panel.skipReturn, "BOTTOMLEFT", 0, -12)
            else
                panel.listHeader:SetPoint("TOPLEFT", panel.next, "BOTTOMLEFT", 0, -12)
            end
            if not routeComplete then
                -- Standing in an instance that has no route at all. The
                -- run is not over, so offering somewhere to go next would
                -- be wrong; the kill checklist is what the player is
                -- actually doing.
                panel.listHeader:SetText(RR.L["Boss Progress"])
                ReleaseIdleListLines()
                UI.ReleaseIdlePillCells()
                ReleaseExpansionToggleButtons()
                ReleaseEntranceButtons()
                panel.ReleaseWingStrikes()
                panel.ReleaseWingToggleButtons()
                UI.RenderBossProgressList()
            else
                panel.listHeader:SetText(RR.L["|cff9d9d9dWhere to next:|r"])
                ReleaseProgressListLines()
                -- Suggest more of what was just finished: a completed
                -- dungeon offers dungeons, not the raid list. The toggle
                -- is not on screen in this state, so the list has to pick
                -- the sensible side itself; the choice carries into the
                -- idle picker, where the toggle can change it.
                if raid then
                    RR.state = RR.state or {}
                    RR.state.idleListMode = (raid.kind == "dungeon")
                        and "dungeon" or "raid"
                end
                RefreshIdleList()
            end
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
            panel.next:SetText(RR.L["Type |cffffffff/rr|r to load navigation."])
        else
            -- Single line: the prompt sentence with the RAID | DUNGEON
            -- mode toggle embedded where its %s sits. The progress
            -- FontString stays empty and only lends its anchor point.
            panel.progress:SetText("")
            local modeLine = UI.EnsureIdleModeLine()
            modeLine.Layout(RR:GetSetting("fontSize", 12))
            modeLine.Refresh()
            -- The minimized bar shows no body content; the line would
            -- otherwise float outside it.
            modeLine.SetShown(not UI.IsMinimized())
            panel.next:SetText("")
        end

        panel.travel:SetText("")
        panel.exitNote:SetText("")
        panel.exitNote:Hide()
        panel.exitNoteExtra:SetText("")
        panel.exitNoteExtra:Hide()
        panel.skipReturn:SetText("")
        panel.skipReturn:Hide()
        panel.skipNote:SetText("")
        panel.skipNote:Hide()
        panel.encounter.headerPulsing = false
        panel.encounter.header.label:SetText("")
        panel.encounter.header.clickable = false
        panel.encounter.skip:Hide()
        panel.encounter.header:EnableMouse(false)
        panel.encounter.achievements.label:SetText("")
        panel.encounter.achievements:Hide()
        panel.encounter.specialLoot.label:SetText("")
        panel.encounter.specialLoot:Hide()
        panel.transmog:SetText("")
        panel.transmog:EnableMouse(false)
        -- Re-anchor listHeader directly below the prompt line so the
        -- supported list sits tight against it. The intermediate widgets
        -- (next, travel, encounter, transmog) are all empty in idle state
        -- but their anchor offsets still accumulate as visible gap, hence
        -- this re-anchor. When the mode-toggle sentence is shown, the
        -- progress FontString is empty (zero height), so the anchor comes
        -- from the sentence's prefix instead -- the extra 4px clears the
        -- toggle words' underline.
        panel.listHeader:ClearAllPoints()
        if panel.idleModeLine and panel.idleModeLine.prefix:IsShown() then
            -- Two single-axis anchors: vertical from the prompt line,
            -- horizontal from the body column. The prompt is CENTERED, so
            -- taking both from it would indent the whole list by half the
            -- prompt's slack.
            panel.listHeader:SetPoint("TOP",
                panel.idleModeLine.prefix, "BOTTOM", 0, -12)
            panel.listHeader:SetPoint("LEFT", panel.progress, "LEFT", 0, 0)
        else
            panel.listHeader:SetPoint("TOPLEFT", panel.progress, "BOTTOMLEFT", 0, -8)
        end
        -- The prompt above already says what the list is; a second
        -- heading only repeated it. Emptied rather than removed: the
        -- list anchors to it, and the in-raid branch still captions it.
        panel.listHeader:SetText("")
        RefreshIdleList()
        -- Hide rather than mouse-disable: a disabled Button still occupies
        -- layout space, and siblings at the same Z-level interfere with mouse
        -- dispatch. Hide() removes them from the layout pass so the toggle
        -- Buttons get clean clicks.
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
-- Confirmation for bypassing an optional boss. The choice lasts the whole
-- lockout and has no in-panel undo, so it asks first.
StaticPopupDialogs["RETRORUNS_SKIP_BOSS"] = {
    text         = RR.L["Skip %s for this lockout?\n\nThe route will continue past this boss."],
    button1      = YES or RR.L["Yes"],
    button2      = NO or RR.L["No"],
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    -- preferredIndex 3 sidesteps the RAID_WARNING taint chain.
    preferredIndex = 3,
    OnAccept = function(_, data)
        if data and data.bossIndex then
            RR:SetBossSkipped(data.bossIndex, true)
            UI.Update()
        end
    end,
}

-- Shared entry point for both skip controls (the header button and the
-- {skip} link inside the note), so they cannot drift apart.
function UI.ConfirmSkipBoss(bossIndex)
    if not bossIndex or not RR:IsBossOptional(bossIndex) then return end
    local boss = RR:GetBossByIndex(bossIndex)
    local bossName = (boss and RR:GetLocalizedBossName(boss)) or RR.L["Unknown"]
    -- Say why rather than opening a confirmation that would fail: from here
    -- the route has nowhere to send them once this step is gone.
    if not RR:CanSkipBoss(bossIndex) then
        RR:Print(RR.L["Cannot skip from here -- keep going until the route reaches the next boss."])
        return
    end
    StaticPopup_Show("RETRORUNS_SKIP_BOSS", bossName, nil,
        { bossIndex = bossIndex })
end

StaticPopupDialogs["RETRORUNS_WOWHEAD_URL"] = {
    text         = RR.L["%s\n|cffffd200%s|r\n\nWowhead URL (Ctrl+C to copy):"],
    button1      = OKAY or RR.L["Okay"],
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
    text         = RR.L["Comments and feedback\n\nCurseForge URL (Ctrl+C to copy):"],
    button1      = OKAY or RR.L["Okay"],
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
    text         = RR.L["Report a bug\n\nGitHub Issues URL (Ctrl+C to copy):"],
    button1      = OKAY or RR.L["Okay"],
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
    text         = RR.L["Known Hangout\n\nDiscord invite URL (Ctrl+C to copy):"],
    button1      = OKAY or RR.L["Okay"],
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

UI.URL_GITHUB_ISSUES = "https://github.com/PhotekWoW/RetroRuns/issues"

-- A footer line reading "Please [Report] <something>!", where [Report] is a
-- real button opening the same copy-URL popup the Settings page's bug link
-- uses. Built from ONE locale string carrying a %s, so a translator gets a
-- whole sentence and can move the button anywhere in it; the format is split
-- at the %s and the three pieces chain right-to-left from the caller's
-- anchor. Returns the table so the caller can font and position it.
function UI.CreateReportLine(parent, formatKey, tooltipKey)
    local line = {}
    local prefixText, suffixText = RR.L[formatKey]:match("^(.-)%%s(.*)$")
    if not prefixText then prefixText, suffixText = RR.L[formatKey], "" end

    line.suffix = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line.suffix:SetText("|cff9d9d9d" .. suffixText .. "|r")

    line.button = CreateFrame("Button", nil, parent)
    line.button:RegisterForClicks("LeftButtonUp")
    line.label = line.button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line.label:SetPoint("CENTER")
    line.label:SetText("|cff" .. C_PINK_HEX .. RR.L["[Report]"] .. "|r")

    line.prefix = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line.prefix:SetText("|cff9d9d9d" .. prefixText .. "|r")

    line.button:SetScript("OnClick", function()
        StaticPopup_Show("RETRORUNS_BUG_URL", nil, nil,
            { url = UI.URL_GITHUB_ISSUES })
    end)
    line.button:SetScript("OnEnter", function(self)
        line.label:SetText("|cffffffff" .. RR.L["[Report]"] .. "|r")
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(RR.L[tooltipKey], 1, 1, 1)
        GameTooltip:Show()
    end)
    line.button:SetScript("OnLeave", function()
        line.label:SetText("|cff" .. C_PINK_HEX .. RR.L["[Report]"] .. "|r")
        GameTooltip:Hide()
    end)
    return line
end

-- Fonts the three pieces and chains them from a bottom corner. Split out
-- from creation so a refresh can re-apply the player's font size without
-- rebuilding the widgets. `align` is "LEFT" or "RIGHT" (default): a
-- right-aligned line chains leftward from the right edge, a left-aligned one
-- chains rightward from the left.
function UI.LayoutReportLine(line, fontSize, anchorFrame, xOffset, yOffset, align)
    SetBodyFont(line.prefix, fontSize, "")
    SetBodyFont(line.label,  fontSize, "")
    SetBodyFont(line.suffix, fontSize, "")

    line.button:SetSize((line.label:GetStringWidth() or 40) + 2,
                        (line.label:GetStringHeight() or fontSize) + 4)
    line.prefix:ClearAllPoints()
    line.button:ClearAllPoints()
    line.suffix:ClearAllPoints()

    if align == "LEFT" then
        line.prefix:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMLEFT",
            xOffset, yOffset)
        line.button:SetPoint("LEFT", line.prefix, "RIGHT", 0, 0)
        line.suffix:SetPoint("LEFT", line.button, "RIGHT", 0, 0)
    else
        line.suffix:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT",
            xOffset, yOffset)
        line.button:SetPoint("RIGHT", line.suffix, "LEFT", 0, 0)
        line.prefix:SetPoint("RIGHT", line.button, "LEFT", 0, 0)
    end
end

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

    local detailFrame = CreateFrame("Frame", "RetroRunsSkipDetailFrame", UIParent, "BackdropTemplate")
    detailFrame:SetSize(312, 120)  -- placeholder; ShowSkipDetail sizes to content
    detailFrame:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    detailFrame:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    detailFrame:SetFrameStrata("DIALOG")  -- above the Skips window it spawns from
    detailFrame:SetMovable(true)
    detailFrame:EnableMouse(true)
    detailFrame:SetClampedToScreen(true)
    detailFrame:RegisterForDrag("LeftButton")
    detailFrame:SetScript("OnDragStart", detailFrame.StartMoving)
    detailFrame:SetScript("OnDragStop", detailFrame.StopMovingOrSizing)
    detailFrame:Hide()

    -- Title: "Skip:" in retro pink, then the raid name. Left-aligned,
    -- anchored top-left with a 16px inset.
    local title = detailFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetJustifyH("LEFT")
    title:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", 16, -14)
    detailFrame.titleText = title

    -- Body: the labeled detail lines. Anchored below the title; width is
    -- set per-show once the content width is measured.
    local body = detailFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetJustifyH("LEFT")
    body:SetWordWrap(true)
    body:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", 16, -40)
    detailFrame.bodyText = body

    local closeBtn = UI.MakeRetroCloseButton(detailFrame)
    closeBtn:SetPoint("TOPRIGHT", detailFrame, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() detailFrame:Hide() end)

    -- Hyperlink routing on the body FontString's parent frame. Quest
    -- links open the Wowhead URL StaticPopup; native achievement links
    -- fall through to SetItemRef (opens the in-game Achievement frame).
    -- Because this frame is not a StaticPopup, spawning the URL popup
    -- doesn't relayout or move it.
    detailFrame:SetHyperlinksEnabled(true)
    detailFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local questID = link and link:match("^RR_quest:(%d+)$")
        if questID then
            local raid = detailFrame.rrRaid
            UI.ShowWowheadQuestPopup(tonumber(questID),
                (raid and RR:GetLocalizedRaidName(raid)) or "?",
                (raid and raid.skipTrigger and raid.skipTrigger.questName
                    and RR.L[raid.skipTrigger.questName])
                    or (RR.L["Quest "] .. questID))
            return
        end
        SetItemRef(link, text, button)
    end)
    detailFrame:SetScript("OnHyperlinkEnter", function(self2, link)
        -- In-game tooltip for native achievement links on hover. RR_quest
        -- links carry no resolvable tooltip, so skip them.
        if link and link:match("^RR_quest:") then return end
        GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    detailFrame:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

    -- Hidden tag for the [ i ]-button toggle: which raid is currently
    -- displayed. Cleared on hide.
    detailFrame:SetScript("OnHide", function(self) self.rrSkipRaidID = nil end)

    skipDetailFrame = detailFrame
    return detailFrame
end

-- Populate and show the skip-detail frame for a raid, positioned at the
-- cursor. Mirrors the old StaticPopup body-build verbatim.
function UI.ShowSkipDetail(raid)
    local detailFrame  = GetOrCreateSkipDetailFrame()
    local fs = detailFrame.bodyText

    detailFrame.rrRaid = raid
    detailFrame.titleText:SetText(RR.L["|cffF259C7Skip:|r "] .. ((raid and RR:GetLocalizedRaidName(raid)) or "?"))

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
            return ("|cff9d9d9d" .. RR.L["%s Detection:"] .. "|r %s"):format(label, value)
        end

        -- Header line: the human-readable name of the unlock, type-
        -- specific but parallel in form. Garrosh has no single name, so
        -- its panel goes straight to the Detection rows.
        if trig.questName and trig.questName ~= "" then
            table.insert(lines, "|cff9d9d9d" .. RR.L["Quest:"] .. "|r " .. RR.L[trig.questName])
        elseif trig.achievementName and trig.achievementName ~= "" then
            table.insert(lines, "|cff9d9d9d" .. RR.L["Achievement:"] .. "|r " .. RR.L[trig.achievementName])
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
                local chainLabel = (chain.label and RR.L[chain.label])
                                   or RR.L["Skip"]
                local qname = names[chain.label]
                local header = ("|cff9d9d9d" .. RR.L["%s Detection:"] .. "|r"):format(chainLabel)
                if qname and qname ~= "" then
                    header = header .. (" |cffaaaaaa(%s)|r"):format(RR.L[qname])
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
            if lm then table.insert(lines, detectionLine(RR.L["Mythic"], lm)) end
            if lh then table.insert(lines, detectionLine(RR.L["Heroic"], lh)) end
            if ln then table.insert(lines, detectionLine(RR.L["Normal"], ln)) end
        elseif raid and raid.skipAchievement then
            -- Achievement-gated skip (BfD). Mythic-only.
            local sa = raid.skipAchievement
            if sa.mythic then
                table.insert(lines, detectionLine(RR.L["Mythic"], achievementLink(sa.mythic)))
            end
        elseif raid and raid.skipGarrosh then
            -- Account-wide scroll skip (SoO). Detection sources by
            -- difficulty: the Mythic achievement, the faction Heroic
            -- achievements, and the per-character Normal kill statistics.
            local sg = raid.skipGarrosh
            if sg.mythicAchievement then
                table.insert(lines, detectionLine(RR.L["Mythic"], achievementLink(sg.mythicAchievement)))
            end
            if sg.heroicAchievements and #sg.heroicAchievements > 0 then
                local achParts = {}
                for _, achID in ipairs(sg.heroicAchievements) do
                    table.insert(achParts, achievementLink(achID))
                end
                -- The faction-alternative achievements (Conqueror /
                -- Liberator) are mutually exclusive -- only one applies
                -- per character -- so join them with "or".
                table.insert(lines, detectionLine(RR.L["Heroic"],
                    table.concat(achParts, " |cffaaaaaa" .. RR.L["or"] .. "|r ")))
            end
            if sg.normalStatistics and #sg.normalStatistics > 0 then
                local statParts = {}
                for _, statID in ipairs(sg.normalStatistics) do
                    table.insert(statParts, ("%d"):format(statID))
                end
                table.insert(lines, detectionLine(RR.L["Normal"],
                    "|cffaaaaaa"
                    .. (RR.L["Statistic Check on Normal Kills (This Char) - ID %s"])
                        :format(table.concat(statParts, ", "))
                    .. "|r"))
            end
        end

        if trig.details and trig.details ~= "" then
            -- Swap the legend tokens for the same glyphs the difficulty
            -- columns render, so a note's legend reads against its marks.
            -- Raids without these tokens are unaffected (gsub no-ops).
            -- The textures are written as literals here; they must stay in
            -- sync with the SKIPS_CELL_UNLOCKED / _LOCKED / _UNKNOWN
            -- definitions.
            local detailText = RR.L[trig.details]
                :gsub("{check}", "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t")
                :gsub("{x}", "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14:0:-2|t")
                :gsub("{unknown}", "|TInterface\\RaidFrame\\ReadyCheck-Waiting:14:14|t")
            table.insert(lines,
                "|cff9d9d9d" .. RR.L["Skip Details:"] .. "|r " .. HighlightNames(detailText))
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
            local textWidth = fs:GetStringWidth() or 0
            if textWidth > widest then widest = textWidth end
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
        detailFrame:SetWidth(bodyW + 2 * INSET)

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
        local titleH = detailFrame.titleText:GetStringHeight() or 16
        local bodyH  = fs:GetStringHeight() or 0
        detailFrame:SetHeight(20 + titleH + 10 + bodyH + 18)

        -- Tag the frame with the raid's instanceID so the [ i ] button
        -- can recognize "already open for this raid" and toggle closed.
        detailFrame.rrSkipRaidID = raid and raid.instanceID or nil
    end

    -- Apply the user's window scale before positioning so the cursor
    -- math below uses the frame's final effective scale (mismatched
    -- scale would offset the anchor by the scale factor).
    detailFrame:SetScale(RR:GetSetting("windowScale", 1.0))

    -- Position at the cursor, hanging down-and-right of the click point
    -- so the [ i ] button stays uncovered. GetCursorPosition returns
    -- UIParent-space pixels; divide by the frame's own effective scale
    -- so the anchor lands at the cursor regardless of windowScale. Clamp
    -- so popups near a screen edge slide back into view.
    local mx, my = GetCursorPosition()
    local effScale = detailFrame:GetEffectiveScale() or 1
    detailFrame:ClearAllPoints()
    if mx and my and effScale > 0 then
        detailFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
            mx / effScale + 16, my / effScale - 16)
    else
        detailFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    detailFrame:Show()
    detailFrame:Raise()
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

    local LOAD_DIALOG_BASE = RR.L["SELECT ROUTE"]

    local loadDialog = CreateFrame("Frame", "RetroRunsLoadDialog", UIParent, "BackdropTemplate")
    loadDialog.loadBase = LOAD_DIALOG_BASE
    loadDialog:SetSize(340, 175)
    -- Height for a single-line raid name; ShowLoadDialog grows the frame
    -- when the name wraps so the prompt and buttons keep their spacing.
    loadDialog.baseHeight = 175
    loadDialog:SetBackdrop(PanelBackdrop(PANEL_EDGE_SIZE_FULL))
    loadDialog:SetBackdropColor(1, 1, 1, RR:GetSetting("panelOpacity", 1.0))
    loadDialog:SetBackdropBorderColor(1, 1, 1, 1)
    loadDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    loadDialog:SetPoint("CENTER", UIParent, "CENTER", 0, 240)
    loadDialog:EnableMouse(true)
    loadDialog:SetClampedToScreen(true)

    -- RETRORUNS wordmark, retro font, two-tone like the panel title.
    -- Larger than the raid name below it. Pulled in from the top border.
    local brand = loadDialog:CreateFontString(nil, "OVERLAY")
    SafeSetFont(brand, TITLE_FONT, 22, "OUTLINE")
    brand:SetPoint("TOP", loadDialog, "TOP", 0, -24)
    brand:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r")
    loadDialog.brand = brand

    -- Raid name (replaces "Route data found for:"), smaller than the
    -- wordmark above. Carries a localized string, so it takes the chrome
    -- font here as well as in ShowLoadDialog -- the pixel face covers
    -- ASCII only, and this font is what the frame renders with until the
    -- first populate.
    local raidName = loadDialog:CreateFontString(nil, "OVERLAY")
    SafeSetFont(raidName, RR:GetChromeFont(), 16, "")
    raidName:SetPoint("TOP", brand, "BOTTOM", 0, -14)
    raidName:SetWidth(300)
    raidName:SetWordWrap(true)
    raidName:SetJustifyH("CENTER")
    raidName:SetTextColor(1, 1, 0)
    loadDialog.raidName = raidName

    -- Difficulty, on its own line under the raid name and a step smaller so
    -- the name reads as the heading. A separate FontString rather than a
    -- second line of the name: one FontString renders at one size, and these
    -- two want different ones. Sits flush under the name (no extra offset),
    -- so when no difficulty is showing its empty string collapses to zero
    -- height and the spacing below matches a name-only title exactly.
    -- Localized like the name, so it takes the chrome font here too.
    local difficultyLine = loadDialog:CreateFontString(nil, "OVERLAY")
    SafeSetFont(difficultyLine, RR:GetChromeFont(), 13, "")
    difficultyLine:SetPoint("TOP", raidName, "BOTTOM", 0, 0)
    difficultyLine:SetWidth(300)
    difficultyLine:SetWordWrap(true)
    difficultyLine:SetJustifyH("CENTER")
    difficultyLine:SetTextColor(1, 1, 0)
    loadDialog.difficultyLine = difficultyLine

    -- SELECT ROUTE prompt, centered. Its text is a translated string and is
    -- set right here at creation, so it must use the chrome font from the
    -- start rather than the ASCII-only pixel face.
    local loading = loadDialog:CreateFontString(nil, "OVERLAY")
    SafeSetFont(loading, RR:GetChromeFont(), 14, "")
    loading:SetPoint("TOP", difficultyLine, "BOTTOM", 0, -14)
    loading:SetJustifyH("CENTER")
    loading:SetText(LOAD_DIALOG_BASE)
    loadDialog.loading = loading

    -- Button row: FULL / SKIP, centered as a pair. Each uses custom neon
    -- textures (the word is baked into the art) for all four button
    -- states; the engine swaps them automatically on hover/press/disable.
    -- Cancel is handled by the close [X] in the top-right corner.
    local BTN_W, BTN_H, BTN_GAP = 140, 36, 4
    local MEDIA = "Interface\\AddOns\\RetroRuns\\Media\\Buttons\\"
    local function MakeTextureButton(baseName, anchorX)
        local choiceButton = CreateFrame("Button", nil, loadDialog)
        choiceButton:SetSize(BTN_W, BTN_H)
        choiceButton:SetPoint("BOTTOM", loadDialog, "BOTTOM", anchorX, 30)

        choiceButton:SetNormalTexture(MEDIA .. baseName)
        choiceButton:SetPushedTexture(MEDIA .. baseName .. "_Pushed")
        choiceButton:SetDisabledTexture(MEDIA .. baseName .. "_Disabled")
        -- Highlight overlays the current state on hover. BLEND (not ADD)
        -- since these are full opaque buttons, not glow-only deltas.
        choiceButton:SetHighlightTexture(MEDIA .. baseName .. "_Highlight", "BLEND")

        -- The hover highlight overlay sits above the pushed texture and
        -- masks it; hide the highlight on press so the pushed art shows,
        -- restore it on release.
        choiceButton:SetScript("OnMouseDown", function(self)
            if self:IsEnabled() then
                local hl = self:GetHighlightTexture()
                if hl then hl:Hide() end
            end
        end)
        choiceButton:SetScript("OnMouseUp", function(self)
            local hl = self:GetHighlightTexture()
            if hl then hl:Show() end
        end)
        return choiceButton
    end
    local halfStride = (BTN_W + BTN_GAP) / 2
    loadDialog.fullBtn = MakeTextureButton("FullButton", -halfStride)
    loadDialog.skipBtn = MakeTextureButton("SkipButton", halfStride)

    -- The button words are baked into the art in English. When the locale
    -- table translates them, a small translated word sits just above the
    -- button (outer-aligned, tinted to the button's neon color) and shows
    -- only while that button is hovered. English clients (and any locale
    -- keeping the English word) get nothing.
    local SUB_LABEL_SIZE = 8   -- native pixel-font size, renders crisp
    local SUB_LABEL_GAP  = 3   -- px between label baseline and button top
    local function AddTranslatedSubLabel(button, englishWord, colorHex, outerSide)
        local translated = RR.L[englishWord]
        if translated == englishWord then return end
        local label = button:CreateFontString(nil, "OVERLAY")
        SafeSetFont(label, RR:GetChromeFont(), SUB_LABEL_SIZE, "")
        if outerSide == "LEFT" then
            label:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 4, SUB_LABEL_GAP)
        else
            label:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", -4, SUB_LABEL_GAP)
        end
        label:SetText(("|c%s%s|r"):format(colorHex, translated))
        label:Hide()
        -- The label occupies the band directly above the button, which is
        -- where the SELECT ROUTE prompt lands on a two-line title. Reserve
        -- its height in the frame so the two never share a line: the prompt
        -- is anchored down from the title and the buttons up from the frame
        -- bottom, so a taller frame is what separates them. Only locales
        -- that translate the button words pay the extra height.
        loadDialog.subLabelClearance = SUB_LABEL_SIZE + SUB_LABEL_GAP + 6
        -- Hover-only. Motion scripts stay live on a disabled button so a
        -- locked SKIP still reveals its translation on hover.
        button:SetMotionScriptsWhileDisabled(true)
        button:HookScript("OnEnter", function() label:Show() end)
        button:HookScript("OnLeave", function() label:Hide() end)
    end
    AddTranslatedSubLabel(loadDialog.fullBtn, "FULL", "ff4dccff", "LEFT")
    AddTranslatedSubLabel(loadDialog.skipBtn, "SKIP", "fff259c7", "RIGHT")

    -- Enable/disable the button; the engine swaps to the disabled texture
    -- automatically, so this is just the state toggle. (Kept as a helper so
    -- ShowLoadDialog's call sites stay readable.)
    loadDialog.SetButtonEnabled = function(btn, enabled)
        if enabled then btn:Enable() else btn:Disable() end
    end

    loadDialog.fullBtn:SetScript("OnClick", function()
        loadDialog:Hide()
        -- Explicit "standard" overrides any persisted variant; a bare call
        -- would keep the restored one (the silent-reload path).
        RR:LoadCurrentRaid("standard")
    end)
    loadDialog.skipBtn:SetScript("OnClick", function()
        loadDialog:Hide()
        RR:LoadCurrentRaid("skip")
    end)

    -- Footer beneath SKIP, standard small font (retro is unreadable this
    -- small). Shows the disabled reason; hidden when SKIP is enabled.
    local skipFooter = loadDialog:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    skipFooter:SetPoint("TOP", loadDialog.skipBtn, "BOTTOM", 0, 3)
    skipFooter:SetJustifyH("CENTER")
    loadDialog.skipFooter = skipFooter

    -- "Continue?" hint, re-anchored at show time under whichever button
    -- matches the route the player already selected this lockout (before
    -- the first kill, when the picker re-prompts). Blank otherwise.
    local continueHint = loadDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    continueHint:SetJustifyH("CENTER")
    continueHint:SetTextColor(0.4, 1, 0.4)
    continueHint:SetText("")
    loadDialog.continueHint = continueHint

    -- Close [X], matching the main panel: themed CloseIcon texture, hover
    -- brightens. Closing cancels the load (same as the old CANCEL button).
    local closeBtn = CreateFrame("Button", nil, loadDialog)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", -10 - FRAME_INSET_X, -4 - FRAME_INSET_Y)
    do
        local tex = closeBtn:CreateTexture(nil, "OVERLAY")
        tex:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\Icons\\CloseIcon")
        tex:SetAllPoints(closeBtn)
        closeBtn._tex = tex
        closeBtn:SetScript("OnEnter", function(self) self._tex:SetVertexColor(1.4, 1.4, 1.4) end)
        closeBtn:SetScript("OnLeave", function(self) self._tex:SetVertexColor(1, 1, 1) end)
    end
    closeBtn:SetScript("OnClick", function()
        loadDialog:Hide()
        RR:UnloadCurrentRaid()
    end)
    loadDialog.closeBtn = closeBtn

    loadDialog:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- CreateFrame yields a SHOWN frame. Without this the dialog appears the
    -- instant it is built, before ShowLoadDialog has filled in the raid name
    -- or re-fonted anything -- an empty name line above a prompt still in
    -- whatever font creation left. ShowLoadDialog calls Show() itself.
    loadDialog:Hide()

    UI._loadDialogFrame = loadDialog
    return loadDialog
end

-- The load dialog for the current raid. SKIP is enabled, disabled "N/A" (no
-- skip exists), or disabled "locked" (authored but not unlocked here). N/A
-- wins when both apply.
function UI.ShowLoadDialog(raidName)
    local dialog = UI._GetOrCreateLoadDialog()
    local raid = RR.currentRaid
    local diff = RR.state and RR.state.currentDifficultyID

    -- Title and prompt take the client default on non-English clients even
    -- when a given string happens to be all-ASCII, so they match the rest of
    -- the localized UI. The wordmark stays in the pixel font either way.
    local titleName = raidName or (raid and RR:GetLocalizedRaidName(raid)) or "?"
    -- The difficulty renders on its own line, in its own smaller FontString,
    -- rather than running on after the raid name where it used to wrap
    -- mid-phrase ("Trial of the Crusader (10 / Player (Heroic))"). Taken from
    -- the raid and live difficulty directly; the passed-in composite string
    -- stays the fallback for the case where no raid is loaded yet.
    local difficultyName = RR.state and RR.state.currentDifficultyName
    if raid and difficultyName and difficultyName ~= "" then
        titleName = RR:GetLocalizedRaidName(raid)
    else
        difficultyName = nil
    end
    SafeSetFont(dialog.raidName, RR:GetChromeFont(), 16, "")
    SafeSetFont(dialog.difficultyLine, RR:GetChromeFont(), 13, "")
    SafeSetFont(dialog.loading, RR:GetChromeFont(), 14, "")
    dialog.raidName:SetText(titleName)
    dialog.difficultyLine:SetText(difficultyName or "")
    dialog.loading:SetText(dialog.loadBase)

    -- A long raid name can wrap past one line, and the difficulty line adds
    -- its own height when present. The buttons anchor to the frame bottom, so
    -- a fixed height would let either push the prompt into the button row.
    -- Grow the frame by the name's overflow past one line, whatever the
    -- difficulty line occupies (zero when it is empty), and the hover
    -- sub-label band on locales that translate the button words.
    local nameLineHeight = dialog.raidName:GetLineHeight() or 15
    local nameTextHeight = dialog.raidName:GetStringHeight() or nameLineHeight
    local difficultyHeight = dialog.difficultyLine:GetStringHeight() or 0
    dialog:SetHeight(dialog.baseHeight
        + math.max(0, nameTextHeight - nameLineHeight)
        + difficultyHeight
        + (dialog.subLabelClearance or 0))

    -- Resolve SKIP state. Gate on the chain the authored route targets:
    -- a raid with multiple skip chains (HFC: Iskar + Mannoroth) but one
    -- authored route must enable SKIP only when THAT route's chain is
    -- unlocked, not when any chain is.
    -- Whether to surface the "Continue?" resume hint: a route was already
    -- selected this lockout but no boss is dead yet (the picker is
    -- re-prompting and the player can still switch).
    local savedVariant = RR.GetPersistedRouteVariant and RR:GetPersistedRouteVariant()
    local showContinue = savedVariant
        and not (RR.HasAnyKillThisLockout and RR:HasAnyKillThisLockout())
    local hasRoute = RR:RaidHasSkipRoute(raid)
    local unlocked = hasRoute and RR:IsRouteTargetSkipAvailableAtDifficulty(raid, diff)
    -- Only treat SKIP as the route being resumed when it's actually
    -- clickable here. If the persisted variant is "skip" but the skip is
    -- locked at this difficulty, fall back to the FULL-side hint so we
    -- don't label a disabled button "Continue?".
    local resumeIsSkip = showContinue and savedVariant == "skip" and unlocked
    -- FULL is always a valid choice; ensure it's enabled and full-color
    -- (it may have been left desaturated from a prior disabled state).
    dialog.SetButtonEnabled(dialog.fullBtn, true)
    if hasRoute and unlocked then
        dialog.SetButtonEnabled(dialog.skipBtn, true)
        -- When SKIP is the route being resumed, the footer becomes the
        -- "Continue?" hint (replacing the boss name) so it lands in the
        -- footer slot rather than stacking onto the frame border below it.
        dialog.skipFooter:SetText(resumeIsSkip and RR.L["Continue?"]
            or (RR:GetLocalizedSkipTargetName(raid) or ""))
    else
        dialog.SetButtonEnabled(dialog.skipBtn, false)
        if not hasRoute then
            dialog.skipFooter:SetText(RR.L["N/A"])
        elseif not RR:RaidSkipIsCascading(raid) then
            -- Non-cascading (achievement-gated) skips are Mythic-only.
            dialog.skipFooter:SetText(RR.L["Mythic only"])
        else
            dialog.skipFooter:SetText(RR.L["locked"])
        end
    end
    -- Color the footer green while it's serving as the Continue? hint,
    -- matching the FULL-side hint; otherwise the default disabled gray.
    if resumeIsSkip then
        dialog.skipFooter:SetTextColor(0.4, 1, 0.4)
    else
        dialog.skipFooter:SetTextColor(0.5, 0.5, 0.5)
    end

    -- FULL-side "Continue?" sits under the FULL button. (The SKIP-side
    -- case is handled in the footer above.)
    dialog.continueHint:ClearAllPoints()
    dialog.continueHint:SetText("")
    if showContinue and savedVariant ~= "skip" then
        dialog.continueHint:SetPoint("TOP", dialog.fullBtn, "BOTTOM", 0, 3)
        dialog.continueHint:SetText(RR.L["Continue?"])
    end

    dialog:Show()
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
    achievementName = achievementName or (RR.L["Achievement "] .. achievementID)
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
    questName = questName or (RR.L["Quest "] .. questID)
    StaticPopup_Show("RETRORUNS_WOWHEAD_URL",
                     raidName, questName, { url = url })
end


-- Structured rows for the achievements window's row pool. Kinds:
--   "glory"   raid-level meta header, always first, one per gloryMetas entry
--   "spacer"  half a row of vertical space
--   "header"  static column labels
--   "achRow"  one achievement. Bosses with N produce N rows and repeat the
--             boss name; raid-wide entries follow with a dash in that column.
local function BuildAchievementRows(raid)
    local rows = {}
    if not raid then return rows end

    -- 1. Glory meta headers (when present). A raid carries either a
    --    gloryMetas list (paired 10/25 glories) or a single gloryMeta.
    local metas = raid.gloryMetas
        or (raid.gloryMeta and { raid.gloryMeta })
        or {}
    for _, meta in ipairs(metas) do
        if meta.id then
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
                name          = mName or meta.name or (RR.L["Glory ID "] .. meta.id),
                completed     = mCompleted,
                done          = done,
                total         = total,
                rewardSpellID = meta.rewardMountSpellID,
                rewardItemID  = meta.rewardItemID,
                rewardName    = meta.rewardName,
                rewardTitle   = meta.rewardTitle,
                rewardRemoved = meta.rewardRemoved,
            })
        end
    end
    if #rows > 0 then
        table.insert(rows, { kind = "spacer" })
    end

    -- 2. Column header row. Held back until the achievement rows are known:
    --    an instance with nothing tracked shows a sentence instead of column
    --    headers over an empty body, and a lone header is worse than none.
    local headerIndex = #rows + 1

    -- 3. Per-boss rows in encounter order. Bosses with multiple achievements
    --    expand to multiple rows (one per achievement); bosses with none
    --    produce nothing.
    if raid.bosses then
        for _, boss in ipairs(raid.bosses) do
            local bossName = RR:GetLocalizedBossName(boss) or "?"
            for _, ach in ipairs(boss.achievements or {}) do
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

    -- 4. Raid-wide achievements, after the boss rows. No boss attribution;
    --    the boss column renders a dash.
    for _, ach in ipairs(raid.raidAchievements or {}) do
        local _, aName, _, aCompleted = GetAchievementInfo(ach.id)
        table.insert(rows, {
            kind            = "achRow",
            bossName        = "-",
            raidWide        = true,
            achievementID   = ach.id,
            achievementName = aName or ach.name or ("ID " .. ach.id),
            completed       = aCompleted,
            soloable        = ach.soloable,
            meta            = ach.meta,
        })
    end

    for index = headerIndex, #rows do
        if rows[index].kind == "achRow" then
            table.insert(rows, headerIndex, { kind = "header" })
            break
        end
    end

    return rows
end

-- Short-circuits RefreshContent when nothing has changed. Without it the
-- heartbeat hides every row's buttons each tick and eats clicks whose
-- mouse-up would have landed after. Same pattern as lastIdleListFingerprint.
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
        local rowKind = row.kind or "?"
        if rowKind == "glory" then
            parts[i] = ("G|%s|%s|%s|%s|%s"):format(
                tostring(row.id), tostring(row.name),
                tostring(row.completed),
                tostring(row.done), tostring(row.total))
        elseif rowKind == "achRow" then
            parts[i] = ("A|%s|%s|%s|%s|%s|%s"):format(
                tostring(row.bossName), tostring(row.achievementID),
                tostring(row.achievementName), tostring(row.completed),
                tostring(row.soloable), tostring(row.meta))
        else
            -- spacer, header: no per-row state beyond kind
            parts[i] = rowKind
        end
    end
    parts[#parts + 1] = "CB|" .. tostring(currentBossName or "")
    return table.concat(parts, "\n")
end

-- Initialize achState with empty fields. Filled by EnsureAchDefaults() on
-- first open, then maintained by dropdown clicks. Only Expansion and
-- Raid are user-selectable (the window uses a full-raid table).
achState = {
    expansion = nil,
    raidKey   = nil,
    -- Which instance table the window reads, same vocabulary as
    -- browserState. Held separately so the two windows can sit on
    -- different instances at once.
    instanceKind = "raid",
}

-- Pick sensible default selection on first open. Mirrors EnsureBrowserDefaults
-- but writes to achState so the tmog browser's selection isn't disturbed.
-- Defaults: current raid if the player is in one, else the first raid in the
-- newest expansion that has data.
local function EnsureAchDefaults()
    -- Prefer the instance the player is standing in, dungeon or raid, and
    -- adopt its kind so the Type dropdown opens on the right table.
    if not achState.raidKey and RR.currentRaid then
        achState.instanceKind = (RR.currentRaid.kind == "dungeon")
            and "dungeon" or "raid"
        achState.raidKey   = UI.BrowserKeyOf(RR.currentRaid)
        achState.expansion = RR.currentRaid.expansion
    end

    local byExpansion, expansions = UI.EnumerateInstances(achState.instanceKind)
    if #expansions == 0 then return end

    -- Fall back to the first instance in the first expansion.
    if not achState.expansion or not byExpansion[achState.expansion] then
        achState.expansion = expansions[1]
    end
    if not achState.raidKey then
        local firstInstance = byExpansion[achState.expansion]
                              and byExpansion[achState.expansion][1]
        if firstInstance then
            achState.raidKey = UI.BrowserKeyOf(firstInstance)
        end
    end
end

-- Flat name index over both instance tables for the achievements window's
-- search box: one entry per expansion, instance, glory, glory reward,
-- achievement, and boss that carries one, each holding the selection that
-- reaches it. Achievement and glory names come from the client, so they
-- index localized with the authored name alongside in the search text.
-- Dropped when the client's achievement list arrives, since those names
-- read empty before it does.
UI.BuildAchSearchIndex = function()
    if UI._achSearchIndex then return UI._achSearchIndex end
    local index = {}
    local function Add(rank, label, context, searchText, entry)
        entry.rank       = rank
        entry.label      = label
        entry.labelLower = label:lower()
        entry.display = context
            and (label .. " |cff888888-- " .. context .. "|r")
            or label
        entry.search = searchText:lower()
        index[#index + 1] = entry
    end
    for _, instanceKind in ipairs({ "raid", "dungeon" }) do
        local kindLabel = (instanceKind == "dungeon")
            and RR.L["Dungeons"] or RR.L["Raids"]
        local byExpansion = UI.EnumerateInstances(instanceKind)
        for expansionName, instances in pairs(byExpansion) do
            if instances[1] then
                Add(0, RR.L[expansionName], kindLabel,
                    RR.L[expansionName] .. " " .. expansionName,
                    { instanceKind = instanceKind, expansion = expansionName,
                      key = UI.BrowserKeyOf(instances[1]) })
            end
            for _, instance in ipairs(instances) do
                local key = UI.BrowserKeyOf(instance)
                local instanceName = RR:GetLocalizedRaidName(instance)
                                     or instance.name or "?"
                Add(1, instanceName, RR.L[expansionName],
                    instanceName .. " " .. (instance.name or ""),
                    { instanceKind = instanceKind, expansion = expansionName,
                      key = key })

                local metas = instance.gloryMetas
                    or (instance.gloryMeta and { instance.gloryMeta })
                    or {}
                for _, meta in ipairs(metas) do
                    if meta.id then
                        local _, gloryName = GetAchievementInfo(meta.id)
                        gloryName = gloryName or meta.name
                                    or (RR.L["Glory ID "] .. meta.id)
                        Add(2, gloryName, instanceName,
                            gloryName .. " " .. (meta.name or ""),
                            { instanceKind = instanceKind,
                              expansion = expansionName, key = key,
                              gloryID = meta.id })

                        -- The mount, item or title a glory grants. Players
                        -- hunt these by name more often than by the meta's,
                        -- so the reward earns a result of its own pointing
                        -- at the same glory block. One entry, not three:
                        -- the mount spell and the item that teaches it are
                        -- the same reward under two names.
                        local mountName
                        if meta.rewardMountSpellID and C_Spell
                           and C_Spell.GetSpellInfo then
                            local info =
                                C_Spell.GetSpellInfo(meta.rewardMountSpellID)
                            if type(info) == "table" then
                                mountName = info.name
                            end
                        end
                        local rewardLabel = (meta.rewardName
                            and RR.L[meta.rewardName]) or mountName
                        if rewardLabel then
                            local rewardSearch = rewardLabel
                                .. " " .. (meta.rewardName or "")
                                .. " " .. (mountName or "")
                                .. " " .. (meta.rewardTitle or "")
                                .. " " .. (meta.rewardTitle
                                           and RR.L[meta.rewardTitle] or "")
                            Add(2, rewardLabel, gloryName, rewardSearch,
                                { instanceKind = instanceKind,
                                  expansion = expansionName, key = key,
                                  gloryID = meta.id })
                        end
                    end
                end

                for _, boss in ipairs(instance.bosses or {}) do
                    local bossName = RR:GetLocalizedBossName(boss)
                                     or boss.name or "?"
                    local bossHasRows = false
                    for _, ach in ipairs(boss.achievements or {}) do
                        bossHasRows = true
                        local _, achName = GetAchievementInfo(ach.id)
                        achName = achName or ach.name or ("ID " .. ach.id)
                        Add(3, achName, bossName .. ", " .. instanceName,
                            achName .. " " .. (ach.name or ""),
                            { instanceKind = instanceKind,
                              expansion = expansionName, key = key,
                              achievementID = ach.id, bossName = bossName })
                    end
                    -- A boss with nothing tracked renders no row, so
                    -- indexing its name would land the window on an
                    -- instance with nothing to show for the match.
                    if bossHasRows then
                        Add(4, bossName, instanceName,
                            bossName .. " " .. (boss.name or ""),
                            { instanceKind = instanceKind,
                              expansion = expansionName, key = key,
                              bossName = bossName })
                    end
                end

                for _, ach in ipairs(instance.raidAchievements or {}) do
                    local _, achName = GetAchievementInfo(ach.id)
                    achName = achName or ach.name or ("ID " .. ach.id)
                    Add(3, achName, instanceName,
                        achName .. " " .. (ach.name or ""),
                        { instanceKind = instanceKind,
                          expansion = expansionName, key = key,
                          achievementID = ach.id })
                end
            end
        end
    end
    UI._achSearchIndex = index
    return index
end

-- Case-insensitive substring query against the index. Returns up to
-- maxResults entries plus the count left off, or nil when the query is
-- under two characters. Ordered by match closeness first, then expansions,
-- instances, glories, achievements, bosses, then name. Same shape as
-- UI.QueryTmogSearch.
UI.QueryAchSearch = function(query, maxResults)
    query = (query or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if #query < 2 then return nil end
    local matches = {}
    for _, entry in ipairs(UI.BuildAchSearchIndex()) do
        local position = entry.search:find(query, 1, true)
        if position then
            entry.matchQuality = (entry.labelLower == query and 3)
                or (position == 1 and 2) or 1
            matches[#matches + 1] = entry
        end
    end
    table.sort(matches, function(a, b)
        if a.matchQuality ~= b.matchQuality then
            return a.matchQuality > b.matchQuality
        end
        if a.rank ~= b.rank then return a.rank < b.rank end
        return a.label < b.label
    end)
    local overflow = 0
    if #matches > maxResults then
        overflow = #matches - maxResults
        for extraIndex = #matches, maxResults + 1, -1 do
            matches[extraIndex] = nil
        end
    end
    return matches, overflow
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
-- Narrower floor for an instance with nothing tracked: there are no row
-- columns to hold, so the frame sizes to the empty note rather than
-- reserving a table's worth of width around a sentence. On the UI table
-- because the file sits at Lua 5.1's 200-local ceiling.
UI.ACH_EMPTY_WINDOW_WIDTH    = 400
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

-- Soloable star: "yes" green, "kinda" orange, "no" red, nil gray. The gray
-- star still renders for a missing field, since no marker at all would be
-- ambiguous. Leading space is folded in.
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
    -- Pixel-grid snapping can collapse a 1px line to zero pixel rows at
    -- fractional effective scales, leaving scattered rows with no
    -- divider. Unsnapped, the line antialiases instead of vanishing.
    if slot.divider.SetTexelSnappingBias then
        slot.divider:SetTexelSnappingBias(0)
        slot.divider:SetSnapToPixelGrid(false)
    end

    -- "Current boss" band: the shared attention flash -- bright on
    -- arrival, then a slow fade to nothing, with the left-edge accent
    -- bar staying as the persistent marker. BORDER draw layer (not
    -- BACKGROUND) so both render ABOVE the frame's own backdrop -- with
    -- BACKGROUND, the panel's opaque chrome was occluding the tint and
    -- the band was only visible when window opacity was turned down.
    -- BORDER still sits below ARTWORK (dividers) and OVERLAY (text), so
    -- the band reads as a tint BEHIND the row's content.
    slot.highlight = parent:CreateTexture(nil, "BORDER")
    slot.highlight:SetColorTexture(UI.FLASH_BAND_R, UI.FLASH_BAND_G,
        UI.FLASH_BAND_B, UI.FLASH_BAND_ALPHA)
    slot.highlightFade = slot.highlight:CreateAnimationGroup()
    local highlightAlpha = slot.highlightFade:CreateAnimation("Alpha")
    highlightAlpha:SetFromAlpha(1)
    highlightAlpha:SetToAlpha(0)
    highlightAlpha:SetStartDelay(UI.FLASH_FADE_DELAY)
    highlightAlpha:SetDuration(UI.FLASH_FADE_DURATION)
    local highlightTexture = slot.highlight
    slot.highlightFade:SetScript("OnFinished", function()
        highlightTexture:Hide()
    end)
    slot.accent = parent:CreateTexture(nil, "BORDER")
    slot.accent:SetColorTexture(0.45, 0.80, 1.0, 1.0)
    slot.accent:SetWidth(3)
    -- The bar breathes while it marks the current boss: a bounced alpha
    -- swing whose 1.6s round trip matches the [!] pulse on the main panel.
    slot.accentPulse = slot.accent:CreateAnimationGroup()
    slot.accentPulse:SetLooping("BOUNCE")
    local accentAlpha = slot.accentPulse:CreateAnimation("Alpha")
    accentAlpha:SetFromAlpha(1.0)
    accentAlpha:SetToAlpha(0.35)
    accentAlpha:SetDuration(0.8)
    accentAlpha:SetSmoothing("IN_OUT")

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
        if slot.accentPulse then slot.accentPulse:Stop() end
    end
end

GetOrCreateAchievementsWindow = function()
    if achievementsWindow then return achievementsWindow end

    local achFrame = CreateFrame("Frame", "RetroRunsAchievementsWindow", UIParent, "BackdropTemplate")
    achFrame:SetSize(ACH_WINDOW_WIDTH, ACH_WINDOW_MIN_HEIGHT)
    achFrame:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    achFrame:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))
    achFrame:SetPoint("TOPLEFT", panel, "TOPRIGHT", 6, 0)
    achFrame:SetMovable(true)
    achFrame:EnableMouse(true)
    achFrame:RegisterForDrag("LeftButton")
    achFrame:SetScript("OnDragStart", achFrame.StartMoving)
    achFrame:SetScript("OnDragStop",  achFrame.StopMovingOrSizing)
    achFrame:SetClampedToScreen(true)
    achFrame:SetFrameStrata("HIGH")
    achFrame:Hide()

    -- Hyperlink router: achievement and item links use SetItemRef as
    -- usual. Custom RR_wowhead: links would no longer reach this handler
    -- (the per-row Button is the new entry point), but the prefix check
    -- is left in for forward compatibility / safety.
    achFrame:SetHyperlinksEnabled(true)
    achFrame:SetScript("OnHyperlinkClick", function(_, link, text, button)
        local achID = link and link:match("^RR_wowhead:(%d+)$")
        if achID then
            UI.ShowWowheadPopup(tonumber(achID))
            return
        end
        SetItemRef(link, text, button)
    end)
    achFrame:SetScript("OnHyperlinkEnter", function(self, link)
        if link and link:match("^RR_wowhead:") then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    achFrame:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

    -- Title plate
    local title = achFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -10)
    title:SetText(RR.L["|cffF259C7RETRO|r|cff4DCCFFRUNS|r  Achievements"])
    SafeSetFont(title, RR:GetChromeFont(), 16, "")
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local closeBtn = UI.MakeRetroCloseButton(achFrame)
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() achFrame:Hide() end)
    achFrame.closeBtn = closeBtn

    -- Two cascading dropdowns: Expansion / Raid. Boss-level selection
    -- was removed when the window switched to a full-raid table view --
    -- all bosses for the selected raid render simultaneously. Layout
    -- mirrors the transmog browser: a measured caption column ("Exp:"/
    -- "Raid:") on the left, bars to its right, selected-value text
    -- left-justified, and bar widths sized to the longest content.
    local function MakeDD(name, width, parent, labelText)
        local dd = CreateFrame("DropdownButton", "RetroRunsAch" .. name .. "DD", parent,
                               "WowStyle1DropdownTemplate")
        dd:SetWidth(width)
        UI.StyleDropdown(dd)
        if labelText then
            local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            lbl:SetText(labelText)
            lbl:SetJustifyH("RIGHT")
            dd.label = lbl
        end
        return dd
    end

    -- Caption column on the left, bars to its right. Measure the widest
    -- caption so the column is exactly as wide as it needs to be.
    local LABEL_LEFT = 14   -- left margin where captions start
    local LABEL_GAP  = 4    -- gap between the caption column and the bars
    -- Measure against the same caption set as the transmog browser
    -- ("Exp:"/"Raid:"/"Boss:"/"Class:") even though this window only renders
    -- Exp and Raid, so the caption column -- and therefore the gap between
    -- the caption and the bar -- lines up exactly with the browser.
    local capMeasure = achFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    capMeasure:Hide()
    local LABEL_W = 0
    for _, cap in ipairs({ RR.L["Exp:"], RR.L["Type:"], RR.L["Inst:"], RR.L["Boss:"], RR.L["Class:"] }) do
        capMeasure:SetText(cap)
        local textWidth = capMeasure:GetStringWidth() or 0
        if textWidth > LABEL_W then LABEL_W = textWidth end
    end
    LABEL_W = math.ceil(LABEL_W)
    -- The bar's frame edge is its visible edge.
    local DD_INSET = 0

    local ddExp  = MakeDD("Expansion", 140, achFrame, RR.L["Exp:"])
    local ddType = MakeDD("InstanceKind", 140, achFrame, RR.L["Type:"])
    local ddRaid = MakeDD("Raid",      220, achFrame, RR.L["Inst:"])

    -- Bars: stacked. Visible left edge sits just right of the caption column;
    -- subtract DD_INSET so the frame's offset lands the visible bar there.
    -- Order matches the transmog browser: Exp -> Type -> Raid.
    -- Each bar steps slightly right of the one above so the left edges
    -- cascade top-to-bottom, matching the transmog browser.
    local barVisibleLeft = LABEL_LEFT + LABEL_W + LABEL_GAP
    local barLeft = barVisibleLeft - DD_INSET
    local DD_STEP = 5
    ddExp:SetPoint("TOPLEFT",  achFrame, "TOPLEFT",    barLeft, -32)
    ddType:SetPoint("TOPLEFT", ddExp,  "BOTTOMLEFT", DD_STEP,  -2)
    ddRaid:SetPoint("TOPLEFT", ddType, "BOTTOMLEFT", DD_STEP,  -2)

    -- Labels: anchored to each bar's own left edge so they cascade in step
    -- with the indented bars, rather than sitting in one fixed column.
    local function anchorLabel(dd)
        if not dd.label then return end
        dd.label:ClearAllPoints()
        dd.label:SetPoint("RIGHT", dd, "LEFT", DD_INSET - LABEL_GAP, 0)
        dd.label:SetWidth(LABEL_W)
    end
    anchorLabel(ddExp); anchorLabel(ddType); anchorLabel(ddRaid)

    achFrame.ddExp, achFrame.ddRaid = ddExp, ddRaid
    achFrame.ddType = ddType

    -- Search: a magnifying glass after the title toggles a floating input
    -- over the dropdown stack. Matches expansion, instance, glory, reward,
    -- achievement and boss names across raids and dungeons; picking a
    -- result drives the dropdowns to it and lands on the row. Same shape as
    -- the transmog browser's, minus its hover-grace timers -- this window
    -- has none.
    do
        local searchIcon = CreateFrame("Button", nil, achFrame)
        searchIcon:SetSize(20, 20)
        -- Dropped 2px: the title's glyphs sit low in their box, so a true
        -- LEFT-RIGHT center reads high next to them.
        searchIcon:SetPoint("LEFT", title, "RIGHT", 6, -2)
        searchIcon:SetNormalTexture("Interface\\Common\\UI-Searchbox-Icon")
        searchIcon:SetHighlightTexture("Interface\\Common\\UI-Searchbox-Icon",
            "ADD")
        local iconTexture = searchIcon:GetNormalTexture()
        if iconTexture then
            iconTexture:SetVertexColor(0.95, 0.35, 0.78)
        end
        UI.AttachSearchSparkle(searchIcon)
        achFrame.searchIcon = searchIcon

        local searchBox = CreateFrame("EditBox", "RetroRunsAchSearchBox",
            achFrame, "InputBoxTemplate")
        searchBox:SetAutoFocus(false)
        searchBox:SetHeight(20)
        -- On the title bar, right of the glass, and stretched to the close
        -- button rather than given a fixed width -- at 180 the right edge
        -- floated and ran under the X. Both of InputBoxTemplate's end
        -- textures extend ~8px past the frame, so both gaps are authored
        -- wide: 12 clears the glass on the left, 10 clears the X.
        searchBox:SetPoint("LEFT", searchIcon, "RIGHT", 12, 2)
        searchBox:SetPoint("RIGHT", achFrame.closeBtn, "LEFT", -10, 0)
        searchBox:SetFrameLevel(achFrame:GetFrameLevel() + 40)
        searchBox:SetMaxLetters(60)
        searchBox.hint = searchBox:CreateFontString(nil, "OVERLAY",
            "GameFontDisableSmall")
        searchBox.hint:SetPoint("LEFT", 2, 0)
        searchBox.hint:SetText(RR.L["Search achievements"])
        searchBox:Hide()
        achFrame.searchBox = searchBox

        local function CloseSearch()
            searchBox:SetText("")
            searchBox:ClearFocus()
            searchBox:Hide()
            achFrame.searchResults:Hide()
        end
        achFrame.CloseSearch = CloseSearch

        searchIcon:SetScript("OnClick", function()
            if searchBox:IsShown() then
                CloseSearch()
            else
                searchBox:Show()
                searchBox:SetFocus()
            end
        end)
        searchIcon:SetScript("OnEnter", function(self)
            -- Suppressed once the box is open; see the minimized bar's copy.
            if searchBox:IsShown() then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(RR.L["Search"], 1, 1, 1)
            GameTooltip:Show()
        end)
        searchIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

        local results = CreateFrame("Frame", nil, achFrame, "BackdropTemplate")
        results:SetBackdrop({
            bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        results:SetBackdropColor(0.05, 0.05, 0.05, 0.97)
        results:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -6, -2)
        results:SetFrameLevel(achFrame:GetFrameLevel() + 40)
        results:EnableMouse(true)
        results:Hide()
        achFrame.searchResults = results

        local RESULT_MAX = 8
        local RESULT_ROW_H = 16
        local RESULT_PAD = 8
        local rowButtons = {}
        local footLine = results:CreateFontString(nil, "OVERLAY",
            "GameFontDisableSmall")
        footLine:SetJustifyH("LEFT")
        footLine:Hide()

        -- Drive the dropdowns to the entry's instance and mark the row it
        -- named, which RefreshContent scrolls to and flashes. The cache has
        -- to be invalidated even when the instance does not change: a hit in
        -- the instance already on screen produces identical rows, and the
        -- fingerprint short-circuit would skip the render that does the
        -- landing.
        local function SelectSearchResult(entry)
            if not entry then return end
            achState.instanceKind = entry.instanceKind
            achState.expansion    = entry.expansion
            achState.raidKey      = entry.key
            achFrame._searchTarget = (entry.achievementID or entry.gloryID
                or entry.bossName) and {
                    achievementID = entry.achievementID,
                    gloryID       = entry.gloryID,
                    bossName      = entry.bossName,
                } or nil
            CloseSearch()
            UI.InvalidateAchievementsCache()
            achFrame:RefreshAll()
        end

        local function GetResultButton(idx)
            local btn = rowButtons[idx]
            if btn then return btn end
            btn = CreateFrame("Button", nil, results)
            btn:SetHeight(RESULT_ROW_H)
            btn:SetPoint("TOPLEFT", results, "TOPLEFT", RESULT_PAD,
                -RESULT_PAD - (idx - 1) * RESULT_ROW_H)
            btn:SetPoint("RIGHT", results, "RIGHT", -RESULT_PAD, 0)
            local btnText = btn:CreateFontString(nil, "OVERLAY",
                "GameFontHighlightSmall")
            btnText:SetPoint("LEFT", 0, 0)
            btnText:SetJustifyH("LEFT")
            btn.text = btnText
            local highlightTex = btn:CreateTexture(nil, "HIGHLIGHT")
            highlightTex:SetAllPoints()
            highlightTex:SetColorTexture(1, 1, 1, 0.08)
            btn:SetScript("OnClick", function(self)
                if self.entry then SelectSearchResult(self.entry) end
            end)
            rowButtons[idx] = btn
            return btn
        end

        local function UpdateSearchResults()
            local matches, overflow =
                UI.QueryAchSearch(searchBox:GetText(), RESULT_MAX)
            for _, btn in ipairs(rowButtons) do
                btn:Hide()
                btn.entry = nil
            end
            footLine:Hide()
            if not matches then
                results:Hide()
                return
            end
            local widest = 0
            local shown = 0
            for idx, entry in ipairs(matches) do
                local btn = GetResultButton(idx)
                btn.entry = entry
                btn.text:SetText(entry.display)
                btn:Show()
                local textWidth = btn.text:GetStringWidth() or 0
                if textWidth > widest then widest = textWidth end
                shown = idx
            end
            local lines = shown
            local footText
            if shown == 0 then
                footText = RR.L["No matches."]
            elseif overflow > 0 then
                footText = (RR.L["+%d more"]):format(overflow)
            end
            if footText then
                footLine:SetText(footText)
                footLine:ClearAllPoints()
                footLine:SetPoint("TOPLEFT", results, "TOPLEFT", RESULT_PAD,
                    -RESULT_PAD - shown * RESULT_ROW_H)
                footLine:Show()
                local textWidth = footLine:GetStringWidth() or 0
                if textWidth > widest then widest = textWidth end
                lines = lines + 1
            end
            results:SetSize(
                math.min(400, math.max(searchBox:GetWidth() + 12,
                    widest + RESULT_PAD * 2 + 4)),
                lines * RESULT_ROW_H + RESULT_PAD * 2)
            results:Show()
        end

        searchBox:SetScript("OnTextChanged", function(self, userInput)
            self.hint:SetShown(self:GetText() == "")
            if userInput then UpdateSearchResults() end
        end)
        searchBox:SetScript("OnEscapePressed", CloseSearch)
        searchBox:SetScript("OnEnterPressed", function()
            local firstBtn = rowButtons[1]
            if firstBtn and firstBtn:IsShown() and firstBtn.entry then
                SelectSearchResult(firstBtn.entry)
            end
        end)
        achFrame:HookScript("OnHide", function()
            CloseSearch()
            achFrame._searchTarget = nil
            if achFrame.searchFlash then achFrame.searchFlash:Hide() end
        end)
    end

    -- Size the bars to their content, matching the transmog browser's rule:
    -- each bar fits its longest string plus room for the arrow. Exp uses the
    -- expansion list; Raid uses every current raid name.
    local function widestAchStringWidth(strings)
        local maxW = 0
        for _, s in ipairs(strings) do
            capMeasure:SetText(s)
            local textWidth = capMeasure:GetStringWidth() or 0
            if textWidth > maxW then maxW = textWidth end
        end
        return maxW
    end
    achFrame.SizeDropdownsToContent = function(self)
        local ARROW_PAD = 34
        -- Measure at the bar's own font so the fit survives a template change.
        if ddExp.Text and ddExp.Text.GetFontObject and ddExp.Text:GetFontObject() then
            capMeasure:SetFontObject(ddExp.Text:GetFontObject())
        end
        local expW = widestAchStringWidth(EXPANSION_ORDER_NEWEST_FIRST)
        -- Measured across BOTH tables so the bar does not resize when the
        -- Type dropdown switches; dungeon names run longer than raid names.
        local instanceNames = {}
        for _, source in ipairs({ RetroRuns_Data, RetroRuns_DungeonData }) do
            for _, instance in pairs(source or {}) do
                if instance.instanceID and instance.instanceID > 0 then
                    instanceNames[#instanceNames + 1] =
                        RR:GetLocalizedRaidName(instance) or ""
                end
            end
        end
        local raidW = widestAchStringWidth(instanceNames)
        local typeW = widestAchStringWidth({ RR.L["Raids"], RR.L["Dungeons"] })
        ddExp:SetWidth(math.ceil(expW)  + ARROW_PAD)
        ddType:SetWidth(math.ceil(typeW) + ARROW_PAD)
        ddRaid:SetWidth(math.ceil(raidW) + ARROW_PAD)
    end

    -- Scrollable row region. Wrath-era raids carry enough achievements
    -- (per-boss 10/25 pairs plus two glories) that the row table can
    -- outgrow any screen-safe window height; rows render into a
    -- ScrollFrame child so overflow scrolls instead of spilling past the
    -- frame edge. The legend stays a fixed footer on the window itself.
    -- Pattern mirrors the transmog popup's content scroll, including the
    -- scrollbar guard against the template re-showing the bar at zero
    -- range.
    local rowScroll = CreateFrame("ScrollFrame", "RetroRunsAchScroll",
                                  achFrame, "UIPanelScrollFrameTemplate")
    rowScroll:SetPoint("TOPLEFT", achFrame, "TOPLEFT", 0, -1)
    rowScroll:SetSize(10, 10)   -- real geometry set per layout pass
    achFrame.rowScroll = rowScroll

    local function ResolveAchScrollBar()
        return rowScroll.ScrollBar or _G["RetroRunsAchScrollScrollBar"]
    end
    local achBarGuardInstalled = false
    local function EnsureAchBarGuard()
        if achBarGuardInstalled then return end
        local bar = ResolveAchScrollBar()
        if not bar then return end
        bar:HookScript("OnShow", function(self)
            local range = rowScroll:GetVerticalScrollRange() or 0
            if not achFrame.rowsScrollable or range <= 1 then
                self:Hide()
            end
        end)
        achBarGuardInstalled = true
    end
    rowScroll:HookScript("OnScrollRangeChanged", function(self)
        EnsureAchBarGuard()
        local bar = ResolveAchScrollBar()
        if not bar then return end
        local range = self:GetVerticalScrollRange() or 0
        if achFrame.rowsScrollable and range > 1 then
            bar:Show()
        else
            bar:Hide()
            if self.SetVerticalScroll then self:SetVerticalScroll(0) end
        end
    end)

    local rowContent = CreateFrame("Frame", "RetroRunsAchScrollChild", rowScroll)
    rowContent:SetSize(10, 10)   -- real size set per layout pass
    rowScroll:SetScrollChild(rowContent)
    achFrame.rowContent = rowContent

    -- Band flashed over the row a search landed on. Lives on the scroll
    -- child so it travels with the rows, and on BORDER for the same reason
    -- the current-boss band does: above the backdrop, below the text.
    achFrame.searchFlash = rowContent:CreateTexture(nil, "BORDER")
    achFrame.searchFlash:SetColorTexture(UI.FLASH_BAND_R, UI.FLASH_BAND_G,
        UI.FLASH_BAND_B, UI.FLASH_BAND_ALPHA)
    achFrame.searchFlash:Hide()
    achFrame.searchFlashFade = achFrame.searchFlash:CreateAnimationGroup()
    do
        local flashAlpha = achFrame.searchFlashFade:CreateAnimation("Alpha")
        flashAlpha:SetFromAlpha(1)
        flashAlpha:SetToAlpha(0)
        flashAlpha:SetStartDelay(UI.FLASH_FADE_DELAY)
        flashAlpha:SetDuration(UI.FLASH_FADE_DURATION)
        local flashTexture = achFrame.searchFlash
        achFrame.searchFlashFade:SetScript("OnFinished", function()
            flashTexture:Hide()
        end)
    end

    -- Row content carries achievement/item links, so mirror the window's
    -- hyperlink handlers on the scroll child; link mouse events fire on
    -- the frame owning the FontString, which is now the child.
    rowContent:SetHyperlinksEnabled(true)
    rowContent:SetScript("OnHyperlinkClick", function(_, link, text, button)
        SetItemRef(link, text, button)
    end)
    rowContent:SetScript("OnHyperlinkEnter", function(self, link)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    rowContent:SetScript("OnHyperlinkLeave", function() GameTooltip:Hide() end)

    -- Glory header sections (above the column-header row), one slot per
    -- glory in the raid's list. Each slot is a gloryLine (name + status),
    -- a rewardLine, and a titleLine; slots are created lazily and reused
    -- across raid switches. titleLine renders only when the Glory rewards
    -- a title (e.g. "the Tomb Raider").
    achFrame.gloryPool = {}
    achFrame.GetGlorySlot = function(self, idx)
        local pool = self.gloryPool
        if pool[idx] then return pool[idx] end
        local slot = {}
        slot.gloryLine = rowContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        slot.gloryLine:SetJustifyH("LEFT")
        slot.gloryLine:SetWordWrap(false)
        slot.rewardLine = rowContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        slot.rewardLine:SetJustifyH("LEFT")
        slot.rewardLine:SetWordWrap(false)
        slot.titleLine = rowContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        slot.titleLine:SetJustifyH("LEFT")
        slot.titleLine:SetWordWrap(false)
        pool[idx] = slot
        return slot
    end

    -- Column-header FontStrings. Persistent (positioned by RefreshContent
    -- below the glory block) and shown for every non-empty raid render.
    -- They live on the scroll child so long tables scroll them with the
    -- rows.
    achFrame.hdrStatus = rowContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    achFrame.hdrStatus:SetJustifyH("CENTER")
    achFrame.hdrStatus:SetText(RR.L["|cff4DCCFFStatus|r"])

    achFrame.hdrAch = rowContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    achFrame.hdrAch:SetJustifyH("LEFT")
    achFrame.hdrAch:SetText(RR.L["|cff4DCCFFAchievement|r"])

    achFrame.hdrBoss = rowContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    achFrame.hdrBoss:SetJustifyH("LEFT")
    achFrame.hdrBoss:SetText(RR.L["|cff4DCCFFBoss|r"])

    achFrame.hdrWowhead = rowContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    achFrame.hdrWowhead:SetJustifyH("CENTER")
    achFrame.hdrWowhead:SetText(RR.L["|cffff8000Wowhead|r"])

    -- Hidden measurement FontString used by RefreshContent to query the
    -- rendered width of each row's text BEFORE laying it out, so columns
    -- and the overall window can auto-size to fit the widest content.
    -- GetStringWidth is synchronous after SetText/SetFont (unlike
    -- GetStringHeight, which is lazy after SetFont): call SetFont first
    -- with the measurement font, then SetText, then read GetStringWidth.
    -- Hidden so it never appears on screen.
    achFrame.measureFS = achFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    achFrame.measureFS:Hide()

    -- The meta key sits with the rows, not in the footer: it is parented to
    -- the row content and anchored to the achievement column, so its diamond
    -- lands directly under the diamonds in the rows above it.
    achFrame.metaKey = achFrame.rowContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    achFrame.metaKey:SetJustifyH("LEFT")
    achFrame.metaKey:SetText(
        "|cff9d9d9d|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t = "
        .. RR.L["meta criteria"] .. "|r"
    )

    -- Footer: soloable color key on the left, the report line on the right.
    --
    -- Star colors match GetSoloableStar() exactly:
    --   green  = soloable (any class)
    --   orange = soloable with class-specific abilities ("kinda")
    --   red    = not soloable
    --   gray   = not yet evaluated
    achFrame.legendLeft = achFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    achFrame.legendLeft:SetJustifyH("LEFT")
    achFrame.legendLeft:SetText(
        "|cff9d9d9d" .. RR.L["Soloable: "] .. "|r|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:0:255:0|t|cff9d9d9d " .. RR.L["yes"] .. "  |r"
        .. "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:255:136:0|t|cff9d9d9d " .. RR.L["kinda"] .. "  |r"
        .. "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:8:8:0:0:64:64:0:64:0:64:255:51:51|t|cff9d9d9d " .. RR.L["no"] .. "|r"
    )

    achFrame.reportLine = UI.CreateReportLine(
        achFrame, "Please %s outdated solo grades!", "Report a bug (GitHub)")

    -- Shown in place of the table when the selected instance has no tracked
    -- achievements at all, so the window never presents column headers over
    -- an empty body.
    achFrame.emptyNote = achFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    achFrame.emptyNote:SetJustifyH("CENTER")
    achFrame.emptyNote:SetText(
        "|cffffffff" .. RR.L["Nothing to track here."] .. "|r\n\n"
        .. "|cff9d9d9d" .. RR.L["We don't track kill / instance completion achievements unless they are tied to a Meta achievement."] .. "|r"
    )
    achFrame.emptyNote:Hide()

    achievementsWindow = achFrame

    -- ----- Dropdown initializers -----
    achFrame.RefreshDropdowns = function(self)
        EnsureAchDefaults()
        local byExp, expList = UI.EnumerateInstances(achState.instanceKind)

        ddExp:SetupMenu(function(_, rootDescription)
            for _, expName in ipairs(expList) do
                UI.MenuRadio(rootDescription, RR.L[expName],
                    function() return expName == achState.expansion end,
                    function()
                        if achState.expansion == expName then return end
                        achState.expansion = expName
                        local first = byExp[expName] and byExp[expName][1]
                        achState.raidKey = first and UI.BrowserKeyOf(first) or nil
                        achFrame:RefreshAll()
                    end)
            end
        end)
        UI.SetDropdownText(ddExp, RR.L[achState.expansion or "(none)"])

        -- Raids or dungeons. Switching selects straight into the new table
        -- rather than clearing the key, which EnsureAchDefaults would read
        -- as first-open and undo by restoring the current instance.
        ddType:SetupMenu(function(_, rootDescription)
            for _, kindEntry in ipairs({ { "raid", RR.L["Raids"] },
                                         { "dungeon", RR.L["Dungeons"] } }) do
                local kindValue, kindLabel = kindEntry[1], kindEntry[2]
                UI.MenuRadio(rootDescription, kindLabel,
                function() return achState.instanceKind == kindValue end,
                function()
                    if achState.instanceKind == kindValue then return end
                    achState.instanceKind = kindValue
                    local newByExp, newExpList = UI.EnumerateInstances(kindValue)
                    if not newByExp[achState.expansion] then
                        achState.expansion = newExpList[1]
                    end
                    local first = newByExp[achState.expansion]
                                  and newByExp[achState.expansion][1]
                    achState.raidKey = first and UI.BrowserKeyOf(first) or nil
                    achFrame:RefreshAll()
                end)
            end
        end)
        UI.SetDropdownText(ddType,
            achState.instanceKind == "dungeon" and RR.L["Dungeons"] or RR.L["Raids"])

        ddRaid:SetupMenu(function(_, rootDescription)
            local instances = byExp[achState.expansion] or {}
            for _, instance in ipairs(instances) do
                local entryKey = UI.BrowserKeyOf(instance)
                UI.MenuRadio(rootDescription, RR:GetLocalizedRaidName(instance) or "?",
                    function() return entryKey == achState.raidKey end,
                    function()
                        if achState.raidKey == entryKey then return end
                        achState.raidKey = entryKey
                        -- RefreshAll so the bar text updates with the content.
                        achFrame:RefreshAll()
                    end)
            end
        end)
        local raidName = "(none)"
        local selRaid = UI.InstanceByKindKey(achState.instanceKind, achState.raidKey)
        if selRaid then raidName = RR:GetLocalizedRaidName(selRaid) or "?" end
        UI.SetDropdownText(ddRaid, raidName)
    end

    -- ----- Row-table refresh -----
    -- Rebuilds the table content, positions all row widgets, sizes the
    -- window. Same shape as RefreshSkipsContent.
    achFrame.RefreshContent = function(self)
        if self.SizeDropdownsToContent then self:SizeDropdownsToContent() end
        local raid = UI.InstanceByKindKey(achState.instanceKind, achState.raidKey)
        local rows = BuildAchievementRows(raid)

        -- An instance with nothing tracked gets a sentence instead of a
        -- header row over an empty body. Glory blocks count as content, so
        -- the test is for achievement rows specifically.
        local hasAchievements = false
        for _, row in ipairs(rows) do
            if row.kind == "achRow" then hasAchievements = true; break end
        end

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
                if boss then currentBossName = RR:GetLocalizedBossName(boss) end
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
        if fp == lastAchRowsFingerprint and achFrame.hdrStatus:IsShown() then
            return
        end
        lastAchRowsFingerprint = fp

        -- Current-boss band flash: re-arms when the current boss changes
        -- (and on window open, which clears the key). While the flash
        -- window is open the band shows and fades; after it expires,
        -- re-renders leave only the accent bar.
        local flashRestart = false
        if achFrame._bossFlashKey ~= currentBossName then
            achFrame._bossFlashKey = currentBossName
            achFrame._bossFlashUntil = currentBossName
                and (GetTime() + UI.FLASH_FADE_DELAY + UI.FLASH_FADE_DURATION)
                or 0
            flashRestart = currentBossName ~= nil
        end
        local flashActive = (achFrame._bossFlashUntil or 0) > GetTime()

        HideAllAchSlots()

        -- Defensively hide the persistent header FontStrings too. They get
        -- :Show()'d again when the "header" row renders below, which is
        -- always for non-empty raids -- but if a future code path renders
        -- a raid with no rows, hiding here ensures the previous raid's
        -- headers don't leak through visually.
        for _, glorySlot in pairs(achFrame.gloryPool) do
            glorySlot.gloryLine:Hide()
            glorySlot.rewardLine:Hide()
            glorySlot.titleLine:Hide()
        end
        achFrame.hdrStatus:Hide()
        achFrame.hdrAch:Hide()
        achFrame.hdrBoss:Hide()
        achFrame.hdrWowhead:Hide()

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

        local widestAch  = MeasureWidth(achFrame.measureFS, RR.L["Achievement"])  -- start with header width
        local widestBoss = MeasureWidth(achFrame.measureFS, RR.L["Boss"])
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
                local achW = MeasureWidth(achFrame.measureFS, achText)
                if achW > widestAch then widestAch = achW end

                local bossW = MeasureWidth(achFrame.measureFS, row.bossName)
                if bossW > widestBoss then widestBoss = bossW end
            end
        end

        -- Per-column padding: extra px beyond the widest content. Keeps
        -- adjacent columns from feeling crowded.
        local COL_PADDING = 14

        -- Resolve column widths -- max(measured + padding, min-constant).
        local colNameW = math.max(widestAch  + COL_PADDING, ACH_COL_NAME_W)
        local colBossW = math.max(widestBoss + COL_PADDING, ACH_COL_BOSS_W)

        -- The status header is centered on its column while the achievement
        -- column is left-anchored, so a status word wider than twice the gap
        -- between them runs into the achievement heading. Push the name
        -- column right when that happens; English sits just inside the
        -- default, and longer translations need the room.
        local statusHalf = MeasureWidth(achFrame.measureFS,
            RR.L["|cff4DCCFFStatus|r"]) / 2
        local colNameX = ACH_COL_NAME_X
        if ACH_COL_STATUS_X + statusHalf > colNameX then
            colNameX = math.ceil(ACH_COL_STATUS_X + statusHalf + 10)
        end

        -- Boss column starts after the achievement column ends.
        local colBossX = colNameX + colNameW + 6

        -- Window width: status column + ach column + boss column +
        -- Wowhead column (button + inset on each side) + left margin,
        -- plus a permanently reserved scrollbar gutter on the right so
        -- the column layout is identical whether or not the current
        -- raid's rows overflow.
        local ACH_SCROLLBAR_GUTTER = 28
        local wowheadColumnW = ACH_WOWHEAD_BTN_W + ACH_WOWHEAD_RIGHT_INSET + 20
        local windowW = colBossX + colBossW + wowheadColumnW
        -- An instance whose table is entirely empty REPLACES that width
        -- rather than taking the wider of the two. The measured value is
        -- built from the column MINIMUMS (245 + 150 + the Wowhead column),
        -- which stand at ~537 even with nothing to put in them, so a
        -- max() against a narrower floor could never take effect. Guarded
        -- on glory rows too: a dungeon can carry a Glory block with no
        -- achievement rows under it, and that block needs the full width.
        local hasAnyRow = hasAchievements
        if not hasAnyRow then
            for _, row in ipairs(rows) do
                if row.kind ~= "spacer" and row.kind ~= "header" then
                    hasAnyRow = true
                    break
                end
            end
        end
        if hasAnyRow then
            windowW = math.max(windowW, ACH_WINDOW_WIDTH)
        else
            windowW = UI.ACH_EMPTY_WINDOW_WIDTH
        end

        -- Width ratchets for the session: switching raids never narrows
        -- the frame, it only widens when a raid's measured need exceeds
        -- the current width. The transmog popup reads as stable because
        -- its width is constant and only its bottom edge moves; a
        -- measured layout can't fix one width for every raid and
        -- locale, so monotone width is the equivalent. Content spans
        -- the full ratcheted width (the Wowhead column keeps hugging
        -- the right edge) since rows anchor to the row parent's edges.
        -- The empty state stands outside the ratchet: it has no columns to
        -- hold stable, and keeping a table's width around one sentence is
        -- waste the ratchet was never meant to cause. It neither reads nor
        -- feeds sessionMaxWidth, so returning to a real table restores the
        -- widest width the session has needed.
        if hasAnyRow then
            achFrame.sessionMaxWidth = math.max(
                achFrame.sessionMaxWidth or 0, windowW)
            windowW = achFrame.sessionMaxWidth
        end
        achFrame:SetWidth(windowW + ACH_SCROLLBAR_GUTTER)

        -- The scroll viewport starts below the dropdown stack (title +
        -- two dropdowns) and rows render into its child from y = 0; the
        -- child is exactly windowW wide so every row anchor below sees
        -- the same geometry the pre-scroll layout used.
        local DROPDOWNS_BOTTOM = 32 + 3 * 32 + 4
        local rowParent = achFrame.rowContent
        rowParent:SetWidth(windowW)
        local y = 0

        -- Where a search result landed, filled in by whichever row matches
        -- as the rows lay out. Read once the scroll geometry is known.
        local searchTarget = achFrame._searchTarget
        local searchHitY, searchHitH = nil, nil

        -- Glory headers (name + reward line each), one block per glory
        -- in the raid's list. Hidden if absent.
        local rowsStart = 1
        local gloryIndex = 0
        while rows[rowsStart] and rows[rowsStart].kind == "glory" do
            local gloryRow = rows[rowsStart]
            gloryIndex = gloryIndex + 1
            local glorySlot = achFrame:GetGlorySlot(gloryIndex)

            -- A glory or reward hit lands on the glory's own name line.
            if searchTarget and searchTarget.gloryID == gloryRow.id then
                searchHitY, searchHitH = y, fontSize + 6
            end

            -- Status fragment: "[ ✓ ]" if completed, "n/N" otherwise.
            -- Gold for the progress count to match the encounter section.
            local statusFrag
            if gloryRow.completed then
                statusFrag = ("|cff777777[ |r|cff00ff00%s|r|cff777777 ]|r"):format(ACH_CELL_DONE)
            else
                statusFrag = ("|cffffd200%d/%d|r"):format(gloryRow.done or 0, gloryRow.total or 0)
            end

            local link = GetAchievementLink and GetAchievementLink(gloryRow.id) or gloryRow.name
            if gloryRow.completed and link ~= gloryRow.name then
                link = link:gsub("^|cff%x%x%x%x%x%x", ""):gsub("|r$", "")
                link = ("|cff888888%s|r"):format(link)
            end
            SetBodyFont(glorySlot.gloryLine, fontSize + 2, "")
            glorySlot.gloryLine:SetText(("%s   %s"):format(link, statusFrag))
            glorySlot.gloryLine:ClearAllPoints()
            glorySlot.gloryLine:SetPoint("TOPLEFT", rowParent, "TOPLEFT", 14, y)
            glorySlot.gloryLine:SetPoint("TOPRIGHT", rowParent, "TOPRIGHT", -14, y)
            glorySlot.gloryLine:Show()
            y = y - (fontSize + 6)

            -- Reward line: the resolved spell/item link, or the plain
            -- reward name. Rewards removed from the game (the Wrath glory
            -- proto-drakes) carry the client's own "No Longer Available"
            -- wording after the name, already localized. A glory with no
            -- reward at all shows no reward line.
            local rewardText
            if gloryRow.rewardSpellID and C_Spell and C_Spell.GetSpellLink then
                rewardText = C_Spell.GetSpellLink(gloryRow.rewardSpellID)
            end
            if not rewardText and gloryRow.rewardItemID then
                local _, itemLink = C_Item.GetItemInfo(gloryRow.rewardItemID)
                rewardText = itemLink
            end
            if not rewardText and gloryRow.rewardName then
                rewardText = ("|cffffffff%s|r"):format(RR.L[gloryRow.rewardName])
            end
            if rewardText and gloryRow.rewardRemoved then
                rewardText = rewardText
                    .. (" |cff9d9d9d(%s)|r"):format(NO_LONGER_AVAILABLE
                        or "No Longer Available")
            end

            if rewardText then
                SetBodyFont(glorySlot.rewardLine, rowFontSize, "")
                glorySlot.rewardLine:SetText(("|cff9d9d9d" .. RR.L["Reward:"] .. "|r %s"):format(rewardText))
                glorySlot.rewardLine:ClearAllPoints()
                glorySlot.rewardLine:SetPoint("TOPLEFT", rowParent, "TOPLEFT", 14, y)
                glorySlot.rewardLine:SetPoint("TOPRIGHT", rowParent, "TOPRIGHT", -14, y)
                glorySlot.rewardLine:Show()
                y = y - lineHeight
            else
                glorySlot.rewardLine:Hide()
            end

            -- Title line. Some Glory metas (Tomb, etc.) award a character
            -- title in addition to the mount/pet. Rendered as a plain
            -- informational line below the reward; no collection-state
            -- query since the title-knowledge API surface is awkward and
            -- the value to the player is just knowing it exists.
            if gloryRow.rewardTitle then
                SetBodyFont(glorySlot.titleLine, rowFontSize, "")
                glorySlot.titleLine:SetText(("|cff9d9d9d" .. RR.L["Title:"] .. "|r |cffffffff%s|r"):format(RR.L[gloryRow.rewardTitle]))
                glorySlot.titleLine:ClearAllPoints()
                glorySlot.titleLine:SetPoint("TOPLEFT", rowParent, "TOPLEFT", 14, y)
                glorySlot.titleLine:SetPoint("TOPRIGHT", rowParent, "TOPRIGHT", -14, y)
                glorySlot.titleLine:Show()
                y = y - lineHeight
            else
                glorySlot.titleLine:Hide()
            end

            -- Advance past this glory row; the spacer row that follows
            -- the block still applies its half-line gap in the data-row
            -- loop below.
            rowsStart = rowsStart + 1
        end
        -- Hide glory slots beyond this raid's count (pool reuse across
        -- raid switches).
        for extraIndex = gloryIndex + 1, #achFrame.gloryPool do
            local extraSlot = achFrame.gloryPool[extraIndex]
            extraSlot.gloryLine:Hide()
            extraSlot.rewardLine:Hide()
            extraSlot.titleLine:Hide()
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
                SetBodyFont(achFrame.hdrStatus, rowFontSize, "")
                achFrame.hdrStatus:ClearAllPoints()
                achFrame.hdrStatus:SetPoint("TOP", rowParent, "TOPLEFT", ACH_COL_STATUS_X, y)
                achFrame.hdrStatus:Show()

                SetBodyFont(achFrame.hdrAch, rowFontSize, "")
                achFrame.hdrAch:ClearAllPoints()
                achFrame.hdrAch:SetPoint("TOPLEFT", rowParent, "TOPLEFT", colNameX, y)
                achFrame.hdrAch:Show()

                SetBodyFont(achFrame.hdrBoss, rowFontSize, "")
                achFrame.hdrBoss:ClearAllPoints()
                achFrame.hdrBoss:SetPoint("TOPLEFT", rowParent, "TOPLEFT", colBossX, y)
                achFrame.hdrBoss:Show()

                SetBodyFont(achFrame.hdrWowhead, rowFontSize, "")
                achFrame.hdrWowhead:ClearAllPoints()
                -- CENTER-anchor the header at the button center so the
                -- label reads as a column header for the buttons below.
                achFrame.hdrWowhead:SetPoint("TOP", rowParent, "TOPRIGHT", ACH_WOWHEAD_CENTER_X, y)
                achFrame.hdrWowhead:Show()

                y = y - lineHeight

            elseif row.kind == "achRow" then
                local slot = GetAchRowSlot(rowParent, i)

                -- An achievement hit lands on its own row; a boss hit lands
                -- on the first row that boss carries, which is where the
                -- reader looks for it.
                if searchTarget and not searchHitY then
                    if searchTarget.achievementID == row.achievementID
                       or (not searchTarget.achievementID
                           and searchTarget.bossName
                           and searchTarget.bossName == row.bossName) then
                        searchHitY, searchHitH = y, lineHeight
                    end
                end

                -- Current-boss band + left accent bar. The textures span
                -- from this row's top (y) down to the bottom of its
                -- vertical band (y - lineHeight). Insets match the divider
                -- inset so the band visually frames within the table
                -- bounds rather than running edge-to-edge. The band only
                -- shows during the flash window and fades out; the accent
                -- bar stays as the persistent marker.
                if currentBossName and row.bossName == currentBossName then
                    if flashActive then
                        slot.highlight:ClearAllPoints()
                        slot.highlight:SetPoint("TOPLEFT",     rowParent, "TOPLEFT",  14, y + 1)
                        slot.highlight:SetPoint("BOTTOMRIGHT", rowParent, "TOPRIGHT", -14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                        slot.highlight:Show()
                        -- A mid-fade re-render keeps a running animation;
                        -- restart only on a new flash, or when this slot's
                        -- animation is not the one carrying it.
                        if flashRestart or not slot.highlightFade:IsPlaying() then
                            slot.highlightFade:Stop()
                            slot.highlightFade:Play()
                        end
                    end

                    slot.accent:ClearAllPoints()
                    slot.accent:SetPoint("TOPLEFT",    rowParent, "TOPLEFT", 14, y + 1)
                    slot.accent:SetPoint("BOTTOMLEFT", rowParent, "TOPLEFT", 14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                    slot.accent:Show()
                    if not slot.accentPulse:IsPlaying() then
                        slot.accentPulse:Play()
                    end
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
                slot.status:SetPoint("TOP", rowParent, "TOPLEFT", ACH_COL_STATUS_X, y)
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
                slot.ach:SetPoint("TOPLEFT", rowParent, "TOPLEFT", colNameX, y)
                slot.ach:Show()

                -- Boss cell.
                SetBodyFont(slot.boss, rowFontSize, "")
                -- Raid-wide achievements carry no boss; the cell shows a
                -- dim dash instead of a name.
                if row.raidWide then
                    slot.boss:SetText("|cff777777-|r")
                else
                    slot.boss:SetText(("|cffcccccc%s|r"):format(row.bossName))
                end
                slot.boss:SetWidth(colBossW)
                slot.boss:ClearAllPoints()
                slot.boss:SetPoint("TOPLEFT", rowParent, "TOPLEFT", colBossX, y)
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
                slot.wowhead:SetPoint("TOPRIGHT", rowParent, "TOPRIGHT", -ACH_WOWHEAD_RIGHT_INSET, y + 2)
                slot.wowhead:Show()

                -- Subtle row divider. Anchored using ACH_ROW_BOTTOM_INSET
                -- so it sits tight against the text from below rather
                -- than at the bottom of the full lineHeight band. The
                -- comment value (5px above nominal row bottom) is set
                -- once at the constant; tune there.
                slot.divider:ClearAllPoints()
                slot.divider:SetPoint("TOPLEFT",  rowParent, "TOPLEFT",  14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                slot.divider:SetPoint("TOPRIGHT", rowParent, "TOPRIGHT", -14, y - lineHeight + ACH_ROW_BOTTOM_INSET)
                slot.divider:Show()

                y = y - lineHeight
            end
        end

        -- Meta key: its own row directly under the last achievement, at the
        -- achievement column's X so its diamond lines up with the diamonds
        -- in the rows above. It belongs to the content, not the footer, so
        -- it scrolls with the table. With no achievements there is nothing
        -- for it to key, so it stays hidden rather than sitting alone.
        if hasAchievements then
            SetBodyFont(achFrame.metaKey, fontSize - 1, "")
            achFrame.metaKey:ClearAllPoints()
            achFrame.metaKey:SetPoint("TOPLEFT", rowParent, "TOPLEFT", colNameX, y - 4)
            achFrame.metaKey:Show()
            y = y - lineHeight
        else
            achFrame.metaKey:Hide()
        end

        -- Empty state: centered in the row viewport, where the table would
        -- have been.
        if hasAchievements then
            achFrame.emptyNote:Hide()
        else
            -- Anchored to the FRAME, not the scroll child. The child is
            -- windowW and the frame is windowW + the scrollbar gutter, so
            -- centering on the child sits half a gutter left of true center.
            -- Inset well past the table margins so the sentence wraps into
            -- a readable block. Run to the frame edges it reads as one long
            -- line and makes the window look sized around it, when the
            -- width actually comes from the row columns.
            SetBodyFont(achFrame.emptyNote, fontSize, "")
            local noteInset = math.max(20,
                math.floor(((achFrame:GetWidth() or 510) - 330) / 2))
            achFrame.emptyNote:ClearAllPoints()
            achFrame.emptyNote:SetPoint("TOPLEFT", achFrame, "TOPLEFT",
                noteInset, -DROPDOWNS_BOTTOM + y - 12)
            achFrame.emptyNote:SetPoint("TOPRIGHT", achFrame, "TOPRIGHT",
                -noteInset, -DROPDOWNS_BOTTOM + y - 12)
            achFrame.emptyNote:Show()
            y = y - (achFrame.emptyNote:GetStringHeight() or fontSize) - 24
        end

        -- Footer: pinned to the frame bottom so it never scrolls out of
        -- view with a long table. Soloable key left, report line right.
        SetBodyFont(achFrame.legendLeft, fontSize - 1, "")
        achFrame.legendLeft:ClearAllPoints()
        achFrame.legendLeft:SetPoint("BOTTOMLEFT", achFrame, "BOTTOMLEFT", 14, 12)

        UI.LayoutReportLine(achFrame.reportLine, fontSize - 1, achFrame, -14, 12)

        local legendH = math.max(
            achFrame.legendLeft:GetStringHeight() or fontSize,
            achFrame.reportLine.suffix:GetStringHeight() or fontSize
        )

        -- Height: chrome (title + dropdowns) + rows + legend footer,
        -- capped at the screen-safe maximum. When the rows outgrow the
        -- cap they scroll inside the viewport instead of spilling past
        -- the frame edge.
        local contentH   = math.abs(y) + 4
        local legendBand = legendH + 12 + 10
        local desired = DROPDOWNS_BOTTOM + contentH + legendBand
        local clamped = math.max(ACH_WINDOW_MIN_HEIGHT,
                                 math.min(ACH_WINDOW_MAX_HEIGHT, desired))
        achFrame:SetHeight(clamped)

        local viewportH = clamped - DROPDOWNS_BOTTOM - legendBand
        rowParent:SetHeight(contentH)
        local rowScroll = achFrame.rowScroll
        -- Set BEFORE the resize. SetSize is what fires OnScrollRangeChanged,
        -- and that handler reads rowsScrollable -- so assigning it afterwards
        -- let the handler see the PREVIOUS render's value and leave the bar
        -- up on a short table that followed a long one.
        achFrame.rowsScrollable = contentH > viewportH + 1
        rowScroll:ClearAllPoints()
        rowScroll:SetPoint("TOPLEFT", achFrame, "TOPLEFT", 0, -DROPDOWNS_BOTTOM)
        rowScroll:SetSize(windowW, viewportH)
        if not achFrame.rowsScrollable then
            if rowScroll.SetVerticalScroll then rowScroll:SetVerticalScroll(0) end
            local bar = ResolveAchScrollBar()
            if bar then bar:Hide() end
        end

        -- Search landing. Cleared unconditionally, so a target that matched
        -- no row (an instance whose rows changed under it) does not sit
        -- waiting to flash on some later, unrelated render.
        achFrame._searchTarget = nil
        if searchHitY then
            -- y runs negative down the content, so -y is the row's distance
            -- from the top. Center it in the viewport where there is room to,
            -- and clamp so short tables do not scroll past their end.
            if achFrame.rowsScrollable and rowScroll.SetVerticalScroll then
                local target = -searchHitY - (viewportH - searchHitH) / 2
                local maxScroll = math.max(0, contentH - viewportH)
                rowScroll:SetVerticalScroll(
                    math.max(0, math.min(maxScroll, target)))
            end
            achFrame.searchFlash:ClearAllPoints()
            achFrame.searchFlash:SetPoint("TOPLEFT", rowParent, "TOPLEFT",
                14, searchHitY + 1)
            achFrame.searchFlash:SetPoint("BOTTOMRIGHT", rowParent, "TOPRIGHT",
                -14, searchHitY - searchHitH + ACH_ROW_BOTTOM_INSET)
            achFrame.searchFlash:Show()
            achFrame.searchFlashFade:Stop()
            achFrame.searchFlashFade:Play()
        end
    end

    achFrame.RefreshAll = function(self)
        self:RefreshDropdowns()
        self:RefreshContent()
    end

    -- Live refresh on achievement events. Debounced 50ms to collapse
    -- CRITERIA_UPDATE bursts. Refresh only fires when the window is shown.
    achFrame:RegisterEvent("ACHIEVEMENT_EARNED")
    achFrame:RegisterEvent("CRITERIA_UPDATE")
    achFrame:RegisterEvent("RECEIVED_ACHIEVEMENT_LIST")

    local refreshPending = false
    achFrame:SetScript("OnEvent", function(self, event)
        -- The index caches achievement and glory names, which read empty
        -- before the client's list lands. Drop it so the next search
        -- rebuilds against real names.
        if event == "RECEIVED_ACHIEVEMENT_LIST" then
            UI._achSearchIndex = nil
        end
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

    return achFrame
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

    local window = GetOrCreateAchievementsWindow()
    -- Apply current settings (scale + font) before refreshing so the first
    -- visible state already matches the user's settings rather than
    -- rendering at default and then snapping to settings.
    local scale = RR:GetSetting("windowScale", 1.0)
    window:SetScale(scale)
    -- Re-arm the current-boss band flash: every open gets the flash even
    -- when the boss has not changed since the last one. The fingerprint
    -- cache must go with it, or the unchanged-rows short-circuit skips
    -- the render that restarts the animation.
    window._bossFlashKey = nil
    UI.InvalidateAchievementsCache()
    window:RefreshAll()
    window:Show()
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
-- The shared phase advances on its own, so every reader -- both [!]
-- glyphs, the map ring and labels, the toaster glow -- keeps breathing
-- whether or not the main panel's glyph is showing.
C_Timer.NewTicker(0.1, function()
    encounterPulsePhase = (encounterPulsePhase + 1) % ENCOUNTER_PULSE_STEPS
end)

C_Timer.NewTicker(0.1, function()
    -- Cheap exit if there's nothing to display the pulse on.
    if not RR:IsPanelAllowed() or not panel:IsShown() then return end
    if not RR.currentRaid then return end
    if RR.state.loadedRaidKey ~= RR:GetRaidContextKey() then return end
    if RR:GetSetting("encounterExpanded") then return end

    -- Refresh the header label alone. Content updates are the
    -- heartbeat ticker's job; this only restyles the [!] glyph, so a
    -- single SetText on the header keeps the animation off the panel
    -- rebuild path.
    if panel.encounter and panel.encounter.headerPulsing
        and panel.encounter.header and panel.encounter.header.label then
        local pulseColor = ENCOUNTER_PULSE_COLORS[encounterPulsePhase] or "|cffffff00"
        panel.encounter.header.label:SetText(
            ("|cff%s%s|r "):format(C_LABEL, RR.L["Boss Encounter:"])
            .. pulseColor .. "[!]|r |cffaaaaaa" .. RR.L["view special note"] .. "|r")
    end
end)

-- Footer new-version [!]. Shares encounterPulsePhase so both pulses breathe
-- in sync, and rewrites in place rather than calling UI.Update. Dismissed
-- while RetroRunsDB.whatsNewSeenVersion matches the current VERSION.
C_Timer.NewTicker(0.1, function()
    if not RR:IsPanelAllowed() or not panel:IsShown() then return end
    if not panel.whatsNewLabel then return end
    -- Dismissed for this version: the click handler already blanked the
    -- label, and the label is born blank, so there is nothing to rewrite.
    if RetroRunsDB and RetroRunsDB.whatsNewSeenVersion == RetroRuns.VERSION then
        return
    end
    local pulseColor = ENCOUNTER_PULSE_COLORS[encounterPulsePhase] or "|cffffff00"
    panel.whatsNewLabel:SetText(pulseColor .. "[!]|r")
end)
