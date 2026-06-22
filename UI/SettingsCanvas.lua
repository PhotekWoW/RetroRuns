local RR = RetroRuns
local UI = RR.UI

-- RetroRuns settings, hosted in Options > AddOns as a canvas category. Left
-- nav rail of tabs (General / Appearance / Toaster); the right pane shows
-- the selected tab's controls. Controls use standard Blizzard templates bound
-- directly to RetroRunsDB. Canvas categories carry no native "Defaults"
-- button, so the footer Reset button is the only reset control.

if not (Settings and Settings.RegisterCanvasLayoutCategory) then
    function UI.OpenSettings() end
    return
end

-- ---- Layout system -------------------------------------------------------
local PANEL_WIDTH   = 620
local PANEL_HEIGHT  = 560
local NAV_W         = 150     -- left tab rail width
local NAV_TOP       = -64     -- first tab y (below the title)
local TAB_H         = 30
local TAB_GAP       = 4
local CONTENT_X     = NAV_W + 28   -- right pane content left edge
local CONTENT_W     = PANEL_WIDTH - CONTENT_X - 24
local ROW_GAP       = 8
local SECTION_TOP   = -6      -- first control y within a page (raised to sit
                             -- closer to the title without colliding)
local CHECK_H       = 26
local LABELED_H     = 44

-- RetroRuns identity palette and fonts.
local COLOR_PINK    = { 0.95, 0.35, 0.78 }
local COLOR_CYAN    = { 0.30, 0.80, 1.00 }
local COLOR_LABEL   = { 1.00, 1.00, 1.00 }
local COLOR_DIM     = { 0.62, 0.62, 0.62 }
local RETRO_FONT    = "Interface\\AddOns\\RetroRuns\\Media\\Fonts\\04B_03.TTF"
local CONTROL_FONT_SIZE = 15   -- shared label size for all settings controls

local ICON_BUG      = "Interface\\AddOns\\RetroRuns\\Media\\BugIcon"
local ICON_CHAT     = "Interface\\AddOns\\RetroRuns\\Media\\ChatIcon"
local URL_GITHUB    = "https://github.com/PhotekWoW/RetroRuns/issues"
local URL_CURSE     = "https://www.curseforge.com/wow/addons/retroruns/comments"
local URL_DISCORD   = "https://discord.gg/achievements"

local panel = CreateFrame("Frame", "RetroRunsSettingsCanvas", UIParent)
panel:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
panel:Hide()
-- Closing the settings panel always re-locks the toast position: the green
-- drag overlay is a settings-time affordance and shouldn't linger on screen.
-- Persist the locked state so the Lock checkbox reflects it on reopen.
panel:HookScript("OnHide", function()
    if RR.SetSetting then RR:SetSetting("toasterLocked", true) end
    if RR.LockToasterAnchor then RR:LockToasterAnchor() end
    if RR._toasterLootSummaryReset then RR._toasterLootSummaryReset() end
end)

local function ApplyPanel()
    if UI.ApplySettings then UI.ApplySettings() end
end

local controls = {}   -- every control, for refresh-on-show and reset

-- ---- Title (RETRO + RUNS, brand two-tone) --------------------------------
local titleRetro = panel:CreateFontString(nil, "ARTWORK")
titleRetro:SetFont(RETRO_FONT, 22, "OUTLINE")
titleRetro:SetPoint("TOPLEFT", 24, -20)
titleRetro:SetText("RETRO")
titleRetro:SetTextColor(unpack(COLOR_PINK))
titleRetro:SetShadowOffset(1, -1)
titleRetro:SetShadowColor(0, 0, 0, 1)

local titleRuns = panel:CreateFontString(nil, "ARTWORK")
titleRuns:SetFont(RETRO_FONT, 22, "OUTLINE")
titleRuns:SetPoint("LEFT", titleRetro, "RIGHT", 2, 0)
titleRuns:SetText("RUNS")
titleRuns:SetTextColor(unpack(COLOR_CYAN))
titleRuns:SetShadowOffset(1, -1)
titleRuns:SetShadowColor(0, 0, 0, 1)

-- "by Photek" credit trailing the wordmark, smaller and dim so it reads
-- as a subtitle rather than competing with the brand.
local titleBy = panel:CreateFontString(nil, "ARTWORK")
titleBy:SetFont(RETRO_FONT, 12, "OUTLINE")
titleBy:SetPoint("LEFT", titleRuns, "RIGHT", 6, -2)
titleBy:SetText("by Photek")
titleBy:SetTextColor(unpack(COLOR_DIM))
titleBy:SetShadowOffset(1, -1)
titleBy:SetShadowColor(0, 0, 0, 1)

-- Vertical divider between the nav rail and the content pane.
local railDivider = panel:CreateTexture(nil, "ARTWORK")
railDivider:SetColorTexture(COLOR_CYAN[1], COLOR_CYAN[2], COLOR_CYAN[3], 0.25)
railDivider:SetWidth(1)
railDivider:SetPoint("TOPLEFT", NAV_W + 8, NAV_TOP - 2)
railDivider:SetPoint("BOTTOMLEFT", NAV_W + 8, 48)

-- ---- Pages ---------------------------------------------------------------
-- Each tab has a page frame filling the content pane. Only the selected one
-- shows. A per-page cursor tracks layout as controls are added to it.
local pages = {}
local pageCursor = {}

local function NewPage()
    local p = CreateFrame("Frame", nil, panel)
    p:SetPoint("TOPLEFT", CONTENT_X, NAV_TOP)
    p:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 48)
    p:Hide()
    pages[#pages + 1] = p
    pageCursor[p] = SECTION_TOP
    return p
end

-- ---- Control builders (operate on a given page) --------------------------

local function AddCheckbox(page, label, tooltip, indent, getValue, setValue)
    local cb = CreateFrame("CheckButton", nil, page, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", indent or 0, pageCursor[page])
    cb.Text:SetText(label)
    -- Use the RetroRuns 04B_03 font so this matches the rest of the panel
    -- (the stock template font reads as generic Blizzard, out of place here).
    cb.Text:SetFont(RETRO_FONT, CONTROL_FONT_SIZE, "OUTLINE")
    cb.Text:SetTextColor(unpack(COLOR_LABEL))
    cb.Text:SetShadowOffset(1, -1)
    cb.Text:SetShadowColor(0, 0, 0, 1)
    if tooltip then
        cb.tooltipText = label
        cb.tooltipRequirement = tooltip
    end
    cb:SetScript("OnClick", function(self) setValue(self:GetChecked() and true or false) end)
    cb.RR_Refresh = function(self) self:SetChecked(getValue()) end
    controls[#controls + 1] = cb
    pageCursor[page] = pageCursor[page] - CHECK_H
    return cb
end

local function AddSlider(page, label, minV, maxV, step, getValue, setValue, formatValue)
    local container = CreateFrame("Frame", nil, page)
    container:SetSize(CONTENT_W, LABELED_H)
    container:SetPoint("TOPLEFT", 0, pageCursor[page])

    local title = container:CreateFontString(nil, "ARTWORK")
    title:SetFont(RETRO_FONT, CONTROL_FONT_SIZE, "OUTLINE")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetTextColor(unpack(COLOR_LABEL))
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 2, -18)
    slider:SetWidth(CONTENT_W - 8)
    slider:SetMinMaxValues(minV, maxV)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    if slider.Low  then slider.Low:SetText("")  end
    if slider.High then slider.High:SetText("") end
    if slider.Text then slider.Text:SetText("") end

    local function refreshTitle(v) title:SetText(label .. ": " .. formatValue(v)) end
    slider:SetScript("OnValueChanged", function(_, value)
        value = math.floor((value / step) + 0.5) * step
        setValue(value)
        refreshTitle(value)
    end)
    container.RR_Refresh = function()
        local v = getValue()
        slider:SetValue(v)
        refreshTitle(v)
    end
    controls[#controls + 1] = container
    container.slider = slider   -- exposed so callers can enable/disable it
    pageCursor[page] = pageCursor[page] - (LABELED_H + ROW_GAP)
    return container
end

local function AddDropdown(page, label, options, getValue, setValue)
    local container = CreateFrame("Frame", nil, page)
    container:SetSize(CONTENT_W, LABELED_H)
    container:SetPoint("TOPLEFT", 0, pageCursor[page])

    local title = container:CreateFontString(nil, "ARTWORK")
    title:SetFont(RETRO_FONT, CONTROL_FONT_SIZE, "OUTLINE")
    title:SetPoint("TOPLEFT", 4, 0)
    title:SetText(label)
    title:SetTextColor(unpack(COLOR_LABEL))
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    local dd = CreateFrame("DropdownButton", nil, container, "WowStyle1DropdownTemplate")
    dd:SetPoint("TOPLEFT", 0, -18)
    dd:SetWidth(CONTENT_W - 8)

    local function IsSelected(value) return getValue() == value end
    local function SetSelected(value) setValue(value) end
    dd:SetupMenu(function(_, rootDescription)
        for _, opt in ipairs(options) do
            rootDescription:CreateRadio(opt.text, IsSelected, SetSelected, opt.value)
        end
    end)
    container.RR_Refresh = function()
        if dd.GenerateMenu then dd:GenerateMenu() end
    end
    controls[#controls + 1] = container
    pageCursor[page] = pageCursor[page] - (LABELED_H + ROW_GAP)
    return container
end

-- ---- Footer buttons ------------------------------------------------------

local function MakeTextButton(label, x, y, width, onClick)
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(width or 160, 24)
    btn:SetPoint("BOTTOMLEFT", x, y)
    btn:SetText(label)
    btn:SetScript("OnClick", onClick)
    return btn
end

-- ---- Build the three pages -----------------------------------------------

local pageGeneral, pageAppearance, pageToaster, pageCustomize, pageWhatsNew, pageHelp =
    NewPage(), NewPage(), NewPage(), NewPage(), NewPage(), NewPage()

-- General (was "Behavior")
AddDropdown(pageGeneral, "On Login Show RetroRuns", {
        { value = "minimized", text = "Open minimized" },
        { value = "full",      text = "Open full" },
        { value = "hidden",    text = "Don't open" },
    },
    function() return RR:GetSetting("launchMode", "minimized") end,
    function(v) RR:SetSetting("launchMode", v) end)

AddDropdown(pageGeneral, "Boss Progress Display", {
        { value = "rr", text = "Kill Order (Default)" },
        { value = "ej", text = "Blizzard Journal Order" },
    },
    function() return RR:GetSetting("bossOrderMode", "rr") end,
    function(v) RR:SetSetting("bossOrderMode", v); if UI.Update then UI.Update() end end)

AddCheckbox(pageGeneral, "Minimap Button", "Show the RetroRuns button on the minimap.", 0,
    function() return RR:GetSetting("showMinimap") ~= false end,
    function(v)
        RR:SetSetting("showMinimap", v)
        if RR.minimapButton then
            if v then RR.minimapButton:Show() else RR.minimapButton:Hide() end
        end
    end)

-- Appearance
-- Font Size max is RR.FONT_SIZE_MAX (the size the fixed-width frame fits).
AddSlider(pageAppearance, "Font Size", 10, RR.FONT_SIZE_MAX or 14, 1,
    function() return RR:GetSetting("fontSize", 12) end,
    function(v)
        RR:SetSetting("fontSize", v)
        if UI.InvalidateIdleListCache then UI.InvalidateIdleListCache() end
        if UI.InvalidateAchievementsCache then UI.InvalidateAchievementsCache() end
        ApplyPanel()
    end,
    function(v) return tostring(v) end)

AddSlider(pageAppearance, "Window Scale", 80, 130, 5,
    function() return math.floor((RR:GetSetting("windowScale", 1.0) * 100) + 0.5) end,
    function(v)
        RR:SetSetting("windowScale", v / 100)
        if UI.InvalidateIdleListCache then UI.InvalidateIdleListCache() end
        ApplyPanel()
    end,
    function(v) return string.format("%.2fx", v / 100) end)

AddSlider(pageAppearance, "Panel Opacity", 20, 100, 5,
    function() return math.floor((RR:GetSetting("panelOpacity", 1.0) * 100) + 0.5) end,
    function(v) RR:SetSetting("panelOpacity", v / 100); ApplyPanel() end,
    function(v) return string.format("%d%%", v) end)

AddDropdown(pageAppearance, "Body Font", {
        { value = "standard", text = "Friz Quadrata (Default)" },
        { value = "retro",    text = "04B_03" },
        { value = "vt323",    text = "VT323" },
    },
    function() return RR:GetSetting("bodyFontStyle", "standard") end,
    function(v)
        RR:SetSetting("bodyFontStyle", v)
        -- Re-font the body surfaces; the Tmog window needs a forced refresh.
        if UI.InvalidateIdleListCache then UI.InvalidateIdleListCache() end
        if UI.InvalidateAchievementsCache then UI.InvalidateAchievementsCache() end
        ApplyPanel()
        if UI.RefreshTmogWindowIfShown then UI.RefreshTmogWindowIfShown() end
    end)

-- Toaster
-- A read-only Status line states the live truth (Active / Off / Travel to a
-- Supported Raid). Below it, an Enable | Disable button pair sets the toast
-- preference, followed by indented On | Off sub-preferences (Loot Summary,
-- Hide Blizzard Boss Banner, Coin SFX). The selected button in each pair is
-- underlined to signal it is the active choice (and that these are clickable).
local RefreshToasterControls   -- forward declaration (defined below)
local COLOR_AMBER    = { 1.00, 0.55, 0.20 }   -- "travel to a supported raid"
local COLOR_GREEN    = { 0.40, 0.90, 0.45 }   -- "active"
local COLOR_RED      = { 0.95, 0.35, 0.35 }   -- "manually disabled"
local SEG_FONT_SIZE  = 15
local SUB_INDENT     = 18
local VALUE_X = 240   -- page-relative x for the value column. Sized to clear
                      -- the widest label, "Hide Blizzard Boss Banner:" at 15pt
                      -- with its sub-indent. NOT offset by CONTENT_X since
                      -- controls anchor within the page, whose origin is
                      -- already at CONTENT_X)

-- Tagline header for the Toaster tab.
do
    local tagline = pageToaster:CreateFontString(nil, "ARTWORK")
    tagline:SetFont(RETRO_FONT, 17, "OUTLINE")
    tagline:SetPoint("TOPLEFT", 0, pageCursor[pageToaster])
    tagline:SetText("Toast what matters. Silence everything else.")
    tagline:SetTextColor(unpack(COLOR_CYAN))
    tagline:SetShadowOffset(1, -1); tagline:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageToaster] = pageCursor[pageToaster] - (17 + 8)

    local subline = pageToaster:CreateFontString(nil, "ARTWORK")
    subline:SetFont(RETRO_FONT, 12, "OUTLINE")
    subline:SetPoint("TOPLEFT", 0, pageCursor[pageToaster])
    subline:SetText("Filter Blizzard Native Loot / Tmog Notifications")
    subline:SetTextColor(unpack(COLOR_PINK))
    subline:SetShadowOffset(1, -1); subline:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageToaster] = pageCursor[pageToaster] - (12 + 8)

    -- Horizontal divider separating the tagline from the controls below.
    local div = pageToaster:CreateTexture(nil, "ARTWORK")
    div:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\divider-line")
    div:SetVertexColor(COLOR_PINK[1], COLOR_PINK[2], COLOR_PINK[3], 0.55)
    div:SetHeight(6)
    div:SetPoint("TOPLEFT", 0, pageCursor[pageToaster])
    div:SetPoint("TOPRIGHT", pageToaster, "TOPRIGHT", -8, pageCursor[pageToaster])
    if div.SetTexelSnappingBias then
        div:SetTexelSnappingBias(0)
        div:SetSnapToPixelGrid(false)
    end

    local gem = pageToaster:CreateTexture(nil, "OVERLAY")
    gem:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\divider-gem")
    gem:SetSize(14, 14)
    gem:SetPoint("CENTER", div, "CENTER", 0, 0)
    if gem.SetTexelSnappingBias then
        gem:SetTexelSnappingBias(0)
        gem:SetSnapToPixelGrid(false)
    end

    pageCursor[pageToaster] = pageCursor[pageToaster] - 14
end

-- Read-only Status line: "Status:" + a state word set by Refresh.
local statusArrow, statusValue
local ARROW_TEX = "Interface\\AddOns\\RetroRuns\\Media\\ArrowDown"
do
    local lbl = pageToaster:CreateFontString(nil, "ARTWORK")
    lbl:SetFont(RETRO_FONT, SEG_FONT_SIZE, "OUTLINE")
    lbl:SetPoint("TOPLEFT", 0, pageCursor[pageToaster])
    lbl:SetText("Active Status:")
    lbl:SetTextColor(unpack(COLOR_LABEL))
    lbl:SetShadowOffset(1, -1); lbl:SetShadowColor(0, 0, 0, 1)

    -- Arrow as a texture (Unicode arrow glyphs do not render in our fonts).
    -- White-authored money-frame arrows tint cleanly via SetVertexColor; the
    -- texture is swapped up/down and colored per-state in Refresh.
    statusArrow = pageToaster:CreateTexture(nil, "ARTWORK")
    statusArrow:SetSize(12, 12)
    statusArrow:SetTexture(ARROW_TEX)   -- white asset; tinted per-state below
    statusArrow:SetPoint("TOPLEFT", VALUE_X, pageCursor[pageToaster] - 2)

    -- Status text stays in the retro font to match the rest of the panel.
    statusValue = pageToaster:CreateFontString(nil, "ARTWORK")
    statusValue:SetFont(RETRO_FONT, SEG_FONT_SIZE, "OUTLINE")
    statusValue:SetPoint("LEFT", statusArrow, "RIGHT", 5, 0)
    statusValue:SetShadowOffset(1, -1); statusValue:SetShadowColor(0, 0, 0, 1)

    pageCursor[pageToaster] = pageCursor[pageToaster] - (CHECK_H + 4)
end


-- A pair of clickable text buttons (e.g. Enable | Disable). The selected one is
-- cyan + underlined; the other is gray. getValue returns the current bool;
-- setValue(bool) writes it. trueLabel/falseLabel are the words shown.
local function AddButtonPair(label, indent, trueLabel, falseLabel, getValue, setValue)
    local rowY = pageCursor[pageToaster]

    local lbl = pageToaster:CreateFontString(nil, "ARTWORK")
    lbl:SetFont(RETRO_FONT, SEG_FONT_SIZE, "OUTLINE")
    lbl:SetPoint("TOPLEFT", indent or 0, rowY)
    lbl:SetText(label)
    lbl:SetTextColor(unpack(COLOR_LABEL))
    lbl:SetShadowOffset(1, -1); lbl:SetShadowColor(0, 0, 0, 1)

    local function MakeBtn(text, value)
        local btn = CreateFrame("Button", nil, pageToaster)
        local fs = btn:CreateFontString(nil, "ARTWORK")
        fs:SetFont(RETRO_FONT, SEG_FONT_SIZE, "OUTLINE")
        fs:SetText(text)
        fs:SetShadowOffset(1, -1); fs:SetShadowColor(0, 0, 0, 1)
        btn.fs = fs
        -- Size the button from the rendered string metrics and anchor the text
        -- inside it. Sizing the button off its own child fontstring collapses
        -- to zero width unless the fontstring carries an external anchor, which
        -- only the leading button has; this gives every button a real rect.
        btn:SetSize(math.max(1, fs:GetStringWidth()), SEG_FONT_SIZE + 4)
        fs:SetPoint("TOPLEFT", btn, "TOPLEFT")
        -- Underline; shown only when selected.
        local ul = btn:CreateTexture(nil, "ARTWORK")
        ul:SetColorTexture(COLOR_CYAN[1], COLOR_CYAN[2], COLOR_CYAN[3], 1)
        ul:SetHeight(1)
        ul:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
        ul:SetPoint("TOPRIGHT", fs, "BOTTOMRIGHT", 0, -2)
        ul:Hide()
        btn.underline = ul
        -- OnClick is wired below (MakeClick) so it can respect the operable gate.
        return btn
    end

    local trueBtn = MakeBtn(trueLabel, true)
    trueBtn:SetPoint("TOPLEFT", pageToaster, "TOPLEFT", VALUE_X, rowY)

    local sep = pageToaster:CreateFontString(nil, "ARTWORK")
    sep:SetFont(RETRO_FONT, SEG_FONT_SIZE, "OUTLINE")
    sep:SetText("|")
    sep:SetPoint("LEFT", trueBtn, "RIGHT", 6, 0)
    sep:SetTextColor(unpack(COLOR_DIM))

    local falseBtn = MakeBtn(falseLabel, false)
    falseBtn:SetPoint("LEFT", sep, "RIGHT", 6, 0)

    pageCursor[pageToaster] = pageCursor[pageToaster] - (CHECK_H + 4)

    local row = {}
    local operable = true   -- when false, clicks are ignored and both dim

    local function MakeClick(value)
        return function()
            if not operable then return end
            setValue(value)
            if RefreshToasterControls then RefreshToasterControls() end
        end
    end
    trueBtn:SetScript("OnClick", MakeClick(true))
    falseBtn:SetScript("OnClick", MakeClick(false))

    -- isOperable defaults true; pass false to lock the pair (e.g. Coin SFX when
    -- Toaster is disabled). Selected button still underlines so the stored
    -- choice stays visible, just muted.
    function row.Refresh(isOperable)
        operable = (isOperable ~= false)
        local on = getValue()
        local selColor = operable and COLOR_CYAN or COLOR_DIM
        trueBtn.fs:SetTextColor(unpack(on and selColor or COLOR_DIM))
        falseBtn.fs:SetTextColor(unpack((not on) and selColor or COLOR_DIM))
        trueBtn.underline:SetShown(on)
        falseBtn.underline:SetShown(not on)
        -- Mute the underline color when locked. SetColorTexture needs an explicit
        -- alpha; the COLOR_* tables carry only RGB, so pass 1 or it renders clear.
        local ur, ug, ub = unpack(operable and COLOR_CYAN or COLOR_DIM)
        trueBtn.underline:SetColorTexture(ur, ug, ub, 1)
        falseBtn.underline:SetColorTexture(ur, ug, ub, 1)
    end

    return row
end

local enableRow = AddButtonPair("Toaster:", 0, "Enable", "Disable",
    function() return RR:GetSetting("toasterEnabled", false) ~= false end,
    function(v) if RR.SetToaster then RR:SetToaster(v) end end)

local lootSummaryRow = AddButtonPair("Loot Summary:", SUB_INDENT, "On", "Off",
    function() return RR:GetSetting("toasterLootSummary", true) ~= false end,
    function(v) RR:SetSetting("toasterLootSummary", v) end)

-- Stored value means "suppress Blizzard's banner": On = hidden. Default on
-- (true) so the banner is hidden whenever the Toaster is active. Toggling it
-- live re-reconciles the suppression immediately.
local bannerRow = AddButtonPair("Hide Blizzard Boss Banner:", SUB_INDENT, "On", "Off",
    function() return RR:GetSetting("toasterHideBossBanner", true) ~= false end,
    function(v)
        RR:SetSetting("toasterHideBossBanner", v)
        if RR._RefreshToasterBannerSuppression then RR._RefreshToasterBannerSuppression() end
    end)

local soundRow = AddButtonPair("Coin SFX:", SUB_INDENT, "On", "Off",
    function() return RR:GetSetting("toasterSound", true) ~= false end,
    function(v) RR:SetSetting("toasterSound", v) end)

-- Spacing + divider separating the controls above from the preview below.
do
    pageCursor[pageToaster] = pageCursor[pageToaster] - 10

    local div = pageToaster:CreateTexture(nil, "ARTWORK")
    div:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\divider-line")
    div:SetVertexColor(COLOR_PINK[1], COLOR_PINK[2], COLOR_PINK[3], 0.55)
    div:SetHeight(6)
    div:SetPoint("TOPLEFT", 0, pageCursor[pageToaster])
    div:SetPoint("TOPRIGHT", pageToaster, "TOPRIGHT", -8, pageCursor[pageToaster])
    if div.SetTexelSnappingBias then
        div:SetTexelSnappingBias(0)
        div:SetSnapToPixelGrid(false)
    end

    local gem = pageToaster:CreateTexture(nil, "OVERLAY")
    gem:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\divider-gem")
    gem:SetSize(14, 14)
    gem:SetPoint("CENTER", div, "CENTER", 0, 0)
    if gem.SetTexelSnappingBias then
        gem:SetTexelSnappingBias(0)
        gem:SetSnapToPixelGrid(false)
    end

    pageCursor[pageToaster] = pageCursor[pageToaster] - 44
end

-- ---- Live toast preview --------------------------------------------------
-- A real (non-functional) sample batch rendered with the actual toast code, so
-- it always reflects the current look. A Play button replays the reveal. The
-- toast stack sits on the left; the two feature notes and the loot summary
-- preview stack in the right column.
do
    -- The whole preview region lives in one scaled-down container; layout math
    -- inside uses a container-local cursor, and the page cursor advances by the
    -- container's scaled height afterward.
    local PREVIEW_SCALE = 0.75
    pageCursor[pageToaster] = pageCursor[pageToaster] - 2 * (CHECK_H + 4)
    local container = CreateFrame("Frame", nil, pageToaster)
    container:SetScale(PREVIEW_SCALE)
    -- Width is divided by scale so the scaled frame still spans the page width.
    container:SetPoint("TOPLEFT", 0, pageCursor[pageToaster])
    container:SetWidth((CONTENT_W) / PREVIEW_SCALE)
    local cy = 0   -- container-local cursor (descends from the top)

    local lbl = container:CreateFontString(nil, "ARTWORK")
    lbl:SetFont(RETRO_FONT, CONTROL_FONT_SIZE, "OUTLINE")
    lbl:SetPoint("TOPLEFT", 0, cy)
    lbl:SetText("Toaster Preview")
    lbl:SetTextColor(unpack(COLOR_LABEL))
    lbl:SetShadowOffset(1, -1); lbl:SetShadowColor(0, 0, 0, 1)

    -- Host frame the sample batch is anchored within. Three toasts at 0.55
    -- scale stacked with small gaps.
    local host = CreateFrame("Frame", nil, container)
    host:SetSize(220, 200)

    if RR.BuildPreviewBatch then
        local group = RR:BuildPreviewBatch(host)

        -- Play button sits just right of the "Preview:" label.
        local play = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        play:SetSize(60, 20)
        play:SetPoint("LEFT", lbl, "RIGHT", 10, 0)
        play:SetText("Play")

        -- The right column holds three stacked text blocks at x=248: the
        -- "Toasts only pop" note, the "Everything else" note, and the loot
        -- summary preview. The toast stack occupies the left column.
        local RIGHT_X    = 248
        local NOTE_W     = 200
        local SUMMARY_X  = 248
        local NOTE2_X, NOTE2_W = 248, 200

        -- "Toasts only pop" note, top of the right column. Narrow width wraps it
        -- to a few lines beside the toast stack.
        local noteTop = cy - 30
        local note = container:CreateFontString(nil, "ARTWORK")
        note:SetFont(RETRO_FONT, 16, "OUTLINE")
        note:SetPoint("TOPLEFT", RIGHT_X, noteTop)
        note:SetWidth(NOTE_W)
        note:SetJustifyH("LEFT")
        note:SetText("Toasts only pop for new appearances or special loot.")
        note:SetTextColor(unpack(COLOR_PINK))
        note:SetShadowOffset(1, -1); note:SetShadowColor(0, 0, 0, 1)

        -- Toast stack, left column, below the Preview/Play row.
        cy = cy - 30
        local toastTop = cy
        host:SetPoint("TOPLEFT", 8, cy)

        -- Three toasts at 0.55 scale (96px tall each) need ~178px stacked.
        cy = cy - 178

        local bottomTop = toastTop - 84

        -- "Everything else" note, below the first note in the right column.
        local note2 = container:CreateFontString(nil, "ARTWORK")
        note2:SetFont(RETRO_FONT, 16, "OUTLINE")
        note2:SetPoint("TOPLEFT", NOTE2_X, bottomTop)
        note2:SetWidth(NOTE2_W)
        note2:SetJustifyH("LEFT")
        note2:SetText("Everything else prints to chat in a summary.")
        note2:SetTextColor(unpack(COLOR_PINK))
        note2:SetShadowOffset(1, -1); note2:SetShadowColor(0, 0, 0, 1)

        -- Loot summary preview, below the second note.
        local summaryTop = bottomTop - 52
        local summaryHdr = container:CreateFontString(nil, "ARTWORK")
        summaryHdr:SetFont(RETRO_FONT, CONTROL_FONT_SIZE, "OUTLINE")
        summaryHdr:SetPoint("TOPLEFT", SUMMARY_X, summaryTop)
        summaryHdr:SetText("Loot Summary Preview (in Chat)")
        summaryHdr:SetTextColor(unpack(COLOR_LABEL))
        summaryHdr:SetShadowOffset(1, -1); summaryHdr:SetShadowColor(0, 0, 0, 1)

        -- The summary line (always shown, carries the [view] link), then the
        -- "From that kill:" expansion that [view] reveals. Both are single
        -- lines with word-wrap off so [view] stays inline.
        local PREFIX = "|cff4DCCFFR|cffF259C7R|r|cff7f7f7f:|r "
        local summaryRow = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        summaryRow:SetJustifyH("LEFT")
        summaryRow:SetPoint("TOPLEFT", summaryHdr, "BOTTOMLEFT", 0, -8)
        summaryRow:SetWordWrap(false)

        local expRows = {}
        local function buildExpRow(i, anchorTo)
            local cl = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            cl:SetJustifyH("LEFT")
            cl:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -4)
            cl:SetWordWrap(false)
            cl:Hide()
            expRows[i] = cl
            return cl
        end

        local function ResolveChatRows()
            summaryRow:SetText(PREFIX .. group:GetSummaryLine())
            local rows = group:GetExpansionRows()
            for j, text in ipairs(rows) do
                if expRows[j] then expRows[j]:SetText(PREFIX .. text) end
            end
        end

        local expansionRows = select(1, group:GetExpansionRows())
        local prev = summaryRow
        for i = 1, #expansionRows do
            prev = buildExpRow(i, prev)
        end
        ResolveChatRows()

        local shownOnce = false
        local function ShowExpansion()
            if shownOnce then return end   -- one-way reveal; ignore re-clicks
            shownOnce = true
            -- Cascade the rows in one-by-one, matching the live feature where
            -- ShowVendorList prints each line in sequence. Stagger via per-row
            -- timers; FontStrings can't OnUpdate, so use stock UIFrameFadeIn.
            for i, cl in ipairs(expRows) do
                cl:SetAlpha(0)
                cl:Show()
                C_Timer.After((i - 1) * 0.10, function()
                    UIFrameFadeIn(cl, 0.12, 0, 1)
                end)
            end
        end
        local function HideExpansion()
            shownOnce = false
            for _, cl in ipairs(expRows) do cl:Hide() end
        end
        -- Expose so closing the settings window resets this preview to its
        -- collapsed (pre-[view]-click) state, matching how it looks on open.
        RR._toasterLootSummaryReset = HideExpansion

        -- The page handles the preview's [view] link locally (reveal once),
        -- instead of routing to chat. Pattern mirrors the in-raid panel's
        -- hyperlink handlers. Link scheme matches the live one: addon:RetroRuns:vg:N.
        container:SetHyperlinksEnabled(true)
        container:SetScript("OnHyperlinkClick", function(_, link)
            if link and link:match("^addon:RetroRuns:vg:") then
                ShowExpansion()
            end
        end)

        -- Re-resolve names when the client returns item info (handles the
        -- first-open uncached case where names showed as "item:NNNN").
        local waiter = CreateFrame("Frame")
        waiter:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        waiter:SetScript("OnEvent", function() ResolveChatRows() end)

        -- Play replays the toast reveal and re-collapses the expansion so the
        -- [view] click is demonstrable again, then cascades the summary in.
        play:SetScript("OnClick", function()
            if group.PlayReveal then group:PlayReveal() end
            HideExpansion()
            summaryRow:SetAlpha(0)
            C_Timer.After(1.0, function() UIFrameFadeIn(summaryRow, 0.15, 0, 1) end)
        end)

        -- Container bottom is the loot summary preview's bottom: header plus
        -- the summary line plus the expansion rows (~15px each).
        local total = 1 + #expansionRows
        cy = summaryTop - 18 - (total * 15)
    else
        cy = cy - 30
        host:SetPoint("TOPLEFT", 8, cy)
        cy = cy - 178
    end

    -- Size the container to the content it holds, then advance the PAGE cursor
    -- by the container's *scaled* height so anything below it (the divider and
    -- bottom-anchored disclaimer) accounts for the shrink.
    local localHeight = -cy
    container:SetHeight(localHeight)
    pageCursor[pageToaster] = pageCursor[pageToaster] - (localHeight * PREVIEW_SCALE)
end

-- Disclaimer pinned to the panel's footer band, level with the bug/chat
-- icons, so it sits below the page content rather than within it. A persistent
-- flashing [!] glyph at its left draws the eye -- the same breathing-yellow
-- treatment as the main UI's "What's New?" indicator, but always on: a standing
-- caution rather than a dismissable notice.
do
    local disclaimer = panel:CreateFontString(nil, "ARTWORK")
    disclaimer:SetFont(RETRO_FONT, 12, "OUTLINE")
    -- Confined to the right content pane, bottom-aligned to the footer icon
    -- baseline so long text wraps upward within the footer band.
    disclaimer:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", CONTENT_X + 16, 16)
    disclaimer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -12, 16)
    disclaimer:SetJustifyH("LEFT")
    disclaimer:SetText("Other addons with custom loot toast/chat notifications may produce duplicates. Examples: LS: Toasts, AllTheThings, etc.")
    disclaimer:SetTextColor(0.6, 0.6, 0.6)
    disclaimer:SetShadowOffset(1, -1); disclaimer:SetShadowColor(0, 0, 0, 1)

    -- [!] rides the top line of the disclaimer, in the gutter.
    local flash = panel:CreateFontString(nil, "ARTWORK")
    flash:SetFont(RETRO_FONT, 14, "OUTLINE")
    flash:SetPoint("TOPRIGHT", disclaimer, "TOPLEFT", -4, 0)
    flash:SetText("[!]")
    flash:SetTextColor(1, 1, 0)
    flash:SetShadowOffset(1, -1); flash:SetShadowColor(0, 0, 0, 1)

    -- Panel children, so show only on the Toaster tab.
    panel.RR_ToasterDisclaimer = disclaimer
    panel.RR_ToasterDisclaimerFlash = flash
    local function UpdateDisclaimerVisibility()
        local onToaster = pageToaster:IsShown()
        disclaimer:SetShown(onToaster)
        flash:SetShown(onToaster)
    end
    panel.RR_UpdateDisclaimerVisibility = UpdateDisclaimerVisibility
    UpdateDisclaimerVisibility()
end

-- ---- Customize submenu page ----------------------------------------------
-- Indented under Toaster in the nav rail. Settings flow from the top; the
-- ratio-correct live mockup is pinned to the bottom of the page so it stays
-- put as more controls are added above it.
do
    local tagline = pageCustomize:CreateFontString(nil, "ARTWORK")
    tagline:SetFont(RETRO_FONT, 17, "OUTLINE")
    tagline:SetPoint("TOPLEFT", 0, pageCursor[pageCustomize])
    tagline:SetText("Customize Toaster")
    tagline:SetTextColor(unpack(COLOR_CYAN))
    tagline:SetShadowOffset(1, -1); tagline:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageCustomize] = pageCursor[pageCustomize] - (17 + 8)

    local subline = pageCustomize:CreateFontString(nil, "ARTWORK")
    subline:SetFont(RETRO_FONT, 12, "OUTLINE")
    subline:SetPoint("TOPLEFT", 0, pageCursor[pageCustomize])
    subline:SetText("Size, Position & Preview")
    subline:SetTextColor(unpack(COLOR_PINK))
    subline:SetShadowOffset(1, -1); subline:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageCustomize] = pageCursor[pageCustomize] - (12 + 8)

    local div = pageCustomize:CreateTexture(nil, "ARTWORK")
    div:SetColorTexture(COLOR_CYAN[1], COLOR_CYAN[2], COLOR_CYAN[3], 0.25)
    div:SetHeight(1)
    div:SetPoint("TOPLEFT", 0, pageCursor[pageCustomize])
    div:SetPoint("TOPRIGHT", pageCustomize, "TOPRIGHT", -8, pageCursor[pageCustomize])
    pageCursor[pageCustomize] = pageCursor[pageCustomize] - 14

    -- Toast scale (toasterScale, 0.5-1.5). Updates the mockup and live toasts.
    AddSlider(pageCustomize, "Toast Scale", 50, 150, 5,
        function() return math.floor((RR:GetSetting("toasterScale", 1.0) * 100) + 0.5) end,
        function(v)
            RR:SetSetting("toasterScale", v / 100)
            if RR._toasterMock then RR._toasterMock:SetToastScale(v / 100) end
            if RR.ApplyToasterScale then RR:ApplyToasterScale() end
        end,
        function(v) return v .. "%" end)

    -- Toast duration (seconds, 1.5..8.0). Grayed while "remain until clicked"
    -- is on.
    local durationSlider = AddSlider(pageCustomize, "Toast Duration", 1.5, 8.0, 0.5,
        function() return RR:GetSetting("toasterDuration", 3.0) end,
        function(v) RR:SetSetting("toasterDuration", v) end,
        function(v) return ("%.1fs"):format(v) end)

    -- Keep toasts up until clicked; grays the duration slider when on.
    local function ApplyDurationSliderState()
        local stay = RR:GetSetting("toasterStayUntilClick", false)
        if durationSlider and durationSlider.slider then
            if stay then durationSlider.slider:Disable()
            else durationSlider.slider:Enable() end
            durationSlider:SetAlpha(stay and 0.4 or 1.0)
        end
    end

    local stayCheck = AddCheckbox(pageCustomize, "Toasts remain visible until clicked",
        "When enabled, toasts stay on screen until you click them to dismiss.", 0,
        function() return RR:GetSetting("toasterStayUntilClick", false) end,
        function(v)
            RR:SetSetting("toasterStayUntilClick", v)
            ApplyDurationSliderState()
        end)
    -- Sync the slider's grayed state whenever the page refreshes (e.g. reopen
    -- or reset), not just on click.
    local prevStayRefresh = stayCheck.RR_Refresh
    stayCheck.RR_Refresh = function(self)
        if prevStayRefresh then prevStayRefresh(self) end
        ApplyDurationSliderState()
    end
    -- Reset Position: return the toasts to the default panel-anchored spot,
    -- clearing any custom dragged position. Anchored to the page via the
    -- cursor (MakeTextButton positions on the panel, so re-anchor it here).
    pageCursor[pageCustomize] = pageCursor[pageCustomize] - 6
    local resetPosBtn = MakeTextButton("Reset Position", 0, 0, 140, function()
        if RR.ResetToasterAnchor then RR:ResetToasterAnchor() end
    end)
    resetPosBtn:SetParent(pageCustomize)
    resetPosBtn:ClearAllPoints()
    resetPosBtn:SetPoint("TOPLEFT", 0, pageCursor[pageCustomize])
    pageCursor[pageCustomize] = pageCursor[pageCustomize] - 28

    -- Live mockup pinned to the bottom of the page (stays put as settings grow
    -- above it). Its "Live Preview:" label sits just above it.
    if RR.BuildToasterMockup then
        local MOCK_SCALE = 0.5
        local mockH = 460 * MOCK_SCALE

        local mock = RR:BuildToasterMockup(pageCustomize, MOCK_SCALE)
        mock.frame:SetPoint("BOTTOMLEFT", pageCustomize, "BOTTOMLEFT", 8, 8)
        RR._toasterMock = mock   -- handle for live updates as controls change

        local lbl = pageCustomize:CreateFontString(nil, "ARTWORK")
        lbl:SetFont(RETRO_FONT, CONTROL_FONT_SIZE, "OUTLINE")
        lbl:SetPoint("BOTTOMLEFT", mock.frame, "TOPLEFT", -8, 6)
        lbl:SetText("Live Preview:")
        lbl:SetTextColor(unpack(COLOR_LABEL))
        lbl:SetShadowOffset(1, -1); lbl:SetShadowColor(0, 0, 0, 1)
    end
end

-- ---- What's New page -----------------------------------------------------
-- Renders the same release-notes body as the main-panel "What's New?" popup,
-- from the shared RR.WhatsNew data (via UI.BuildWhatsNewBody). Scrollable, so
-- the full last-N release set fits regardless of length.
do
    local tagline = pageWhatsNew:CreateFontString(nil, "ARTWORK")
    tagline:SetFont(RETRO_FONT, 17, "OUTLINE")
    tagline:SetPoint("TOPLEFT", 0, pageCursor[pageWhatsNew])
    tagline:SetText("What's New")
    tagline:SetTextColor(unpack(COLOR_CYAN))
    tagline:SetShadowOffset(1, -1); tagline:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageWhatsNew] = pageCursor[pageWhatsNew] - (17 + 8)

    local div = pageWhatsNew:CreateTexture(nil, "ARTWORK")
    div:SetColorTexture(COLOR_CYAN[1], COLOR_CYAN[2], COLOR_CYAN[3], 0.25)
    div:SetHeight(1)
    div:SetPoint("TOPLEFT", 0, pageCursor[pageWhatsNew])
    div:SetPoint("TOPRIGHT", pageWhatsNew, "TOPRIGHT", -8, pageCursor[pageWhatsNew])
    pageCursor[pageWhatsNew] = pageCursor[pageWhatsNew] - 14

    -- Scrollable body: ScrollFrame fills the page, scrollChild holds the
    -- wrapped notes. -22 right inset leaves room for the scrollbar.
    local scroll = CreateFrame("ScrollFrame", nil, pageWhatsNew, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, pageCursor[pageWhatsNew])
    scroll:SetPoint("BOTTOMRIGHT", pageWhatsNew, "BOTTOMRIGHT", -22, 0)

    local scrollChild = CreateFrame("Frame", nil, scroll)
    scrollChild:SetSize(CONTENT_W - 22, 1)
    scroll:SetScrollChild(scrollChild)

    local body = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
    body:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetWordWrap(true)
    body:SetSpacing(2)

    -- Render the body lazily on show: RR.WhatsNew is static at load, but
    -- building on show keeps this in step with the popup and lets the
    -- scrollChild size to the rendered height after fonts are ready.
    local function RefreshWhatsNew()
        if not (UI and UI.BuildWhatsNewBody) then return end
        body:SetText(UI.BuildWhatsNewBody())
        local h = body:GetStringHeight() or 0
        scrollChild:SetHeight(math.max(1, h))
    end
    pageWhatsNew:HookScript("OnShow", RefreshWhatsNew)
    -- Also build once now in case the page is the first shown before any
    -- OnShow fires through the tab path.
    RefreshWhatsNew()
end

-- ---- Help page -----------------------------------------------------------
-- Command reference (mirrors the user-facing `/rr help` output verbatim) and
-- the GitHub / CurseForge links (same copy-URL popups as the footer icons).
do
    local tagline = pageHelp:CreateFontString(nil, "ARTWORK")
    tagline:SetFont(RETRO_FONT, 17, "OUTLINE")
    tagline:SetPoint("TOPLEFT", 0, pageCursor[pageHelp])
    tagline:SetText("Help")
    tagline:SetTextColor(unpack(COLOR_CYAN))
    tagline:SetShadowOffset(1, -1); tagline:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageHelp] = pageCursor[pageHelp] - (17 + 8)

    local div = pageHelp:CreateTexture(nil, "ARTWORK")
    div:SetColorTexture(COLOR_CYAN[1], COLOR_CYAN[2], COLOR_CYAN[3], 0.25)
    div:SetHeight(1)
    div:SetPoint("TOPLEFT", 0, pageCursor[pageHelp])
    div:SetPoint("TOPRIGHT", pageHelp, "TOPRIGHT", -8, pageCursor[pageHelp])
    pageCursor[pageHelp] = pageCursor[pageHelp] - 14

    -- Author credit + Discord, at the top of the page.
    local credit = pageHelp:CreateFontString(nil, "ARTWORK")
    credit:SetFont(RETRO_FONT, 12, "OUTLINE")
    credit:SetPoint("TOPLEFT", 0, pageCursor[pageHelp])
    credit:SetText("|cffF259C7Author:|r |cffffffffPhotek|r")
    credit:SetShadowOffset(1, -1); credit:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageHelp] = pageCursor[pageHelp] - (12 + 6)

    local hangout = pageHelp:CreateFontString(nil, "ARTWORK")
    hangout:SetFont(RETRO_FONT, 12, "OUTLINE")
    hangout:SetPoint("TOPLEFT", 8, pageCursor[pageHelp])
    hangout:SetText("Known Hangout:")
    hangout:SetTextColor(unpack(COLOR_CYAN))
    hangout:SetShadowOffset(1, -1); hangout:SetShadowColor(0, 0, 0, 1)

    -- Clickable URL: white text with a Button overlay (FontStrings can't
    -- take clicks). Click opens the copy-URL popup, same as the link rows.
    local urlFS = pageHelp:CreateFontString(nil, "ARTWORK")
    urlFS:SetFont(RETRO_FONT, 12, "OUTLINE")
    urlFS:SetPoint("LEFT", hangout, "RIGHT", 6, 0)
    urlFS:SetText(URL_DISCORD)
    urlFS:SetTextColor(1, 1, 1)
    urlFS:SetShadowOffset(1, -1); urlFS:SetShadowColor(0, 0, 0, 1)

    local urlBtn = CreateFrame("Button", nil, pageHelp)
    urlBtn:SetPoint("TOPLEFT", urlFS, "TOPLEFT", 0, 2)
    urlBtn:SetPoint("BOTTOMRIGHT", urlFS, "BOTTOMRIGHT", 0, -2)
    urlBtn:SetScript("OnClick", function()
        StaticPopup_Show("RETRORUNS_DISCORD_URL", nil, nil, { url = URL_DISCORD })
    end)
    urlBtn:SetScript("OnEnter", function(self)
        urlFS:SetTextColor(unpack(COLOR_CYAN))
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Copy the Discord invite", 1, 1, 1)
        GameTooltip:Show()
    end)
    urlBtn:SetScript("OnLeave", function()
        urlFS:SetTextColor(1, 1, 1)
        GameTooltip:Hide()
    end)
    pageCursor[pageHelp] = pageCursor[pageHelp] - (12 + 12)

    -- Section: Commands -----------------------------------------------------
    local cmdHeader = pageHelp:CreateFontString(nil, "ARTWORK")
    cmdHeader:SetFont(RETRO_FONT, 13, "OUTLINE")
    cmdHeader:SetPoint("TOPLEFT", 0, pageCursor[pageHelp])
    cmdHeader:SetText("Commands")
    cmdHeader:SetTextColor(unpack(COLOR_PINK))
    cmdHeader:SetShadowOffset(1, -1); cmdHeader:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageHelp] = pageCursor[pageHelp] - (13 + 8)

    -- Command reference rows. Text is verbatim from the user-facing
    -- `/rr help` output in Core.lua -- keep the two in sync if either
    -- changes. The command token renders in cyan, its description in dim
    -- gray at a fixed column so descriptions line up.
    local CMD_COL  = 120  -- x-offset of the description column from the cmd
    local CMD_ROW_H = 12 + 6
    local commands = {
        { "/rr",            "toggle main panel" },
        { "/rr status",     "current raid, step, kill state" },
        { "/rr tmog",       "open transmog browser" },
        { "/rr skips",      "account-wide raid skip status" },
        { "/rr settings",   "open settings window" },
    }
    for _, entry in ipairs(commands) do
        local cmd = pageHelp:CreateFontString(nil, "ARTWORK")
        cmd:SetFont(RETRO_FONT, 12, "OUTLINE")
        cmd:SetPoint("TOPLEFT", 8, pageCursor[pageHelp])
        cmd:SetText(entry[1])
        cmd:SetTextColor(unpack(COLOR_CYAN))
        cmd:SetShadowOffset(1, -1); cmd:SetShadowColor(0, 0, 0, 1)

        local desc = pageHelp:CreateFontString(nil, "ARTWORK")
        desc:SetFont(RETRO_FONT, 12, "OUTLINE")
        desc:SetPoint("TOPLEFT", 8 + CMD_COL, pageCursor[pageHelp])
        desc:SetText(entry[2])
        desc:SetTextColor(unpack(COLOR_DIM))
        desc:SetShadowOffset(1, -1); desc:SetShadowColor(0, 0, 0, 1)

        pageCursor[pageHelp] = pageCursor[pageHelp] - CMD_ROW_H
    end

    pageCursor[pageHelp] = pageCursor[pageHelp] - 10

    -- Section: Links --------------------------------------------------------
    local linkHeader = pageHelp:CreateFontString(nil, "ARTWORK")
    linkHeader:SetFont(RETRO_FONT, 13, "OUTLINE")
    linkHeader:SetPoint("TOPLEFT", 0, pageCursor[pageHelp])
    linkHeader:SetText("Links")
    linkHeader:SetTextColor(unpack(COLOR_PINK))
    linkHeader:SetShadowOffset(1, -1); linkHeader:SetShadowColor(0, 0, 0, 1)
    pageCursor[pageHelp] = pageCursor[pageHelp] - (13 + 12)

    -- Each link row: a tinted icon button (opens a copy-URL popup) with a cyan
    -- label. Only the icon is clickable.
    local LINK_ICON   = 26
    local LINK_ROW_H  = LINK_ICON + 12
    local LINK_LABEL_X = 8 + LINK_ICON + 12  -- icon left pad + icon + gap

    -- helper: build one icon+label link row at the current page cursor.
    local function MakeLinkRow(texture, color, label, popupKey, url, tooltip)
        local rowY = pageCursor[pageHelp]

        local icon = CreateFrame("Button", nil, pageHelp)
        icon:SetSize(LINK_ICON, LINK_ICON)
        icon:SetPoint("TOPLEFT", 8, rowY)
        icon:SetNormalTexture(texture)
        icon:SetHighlightTexture(texture)
        local normal = icon:GetNormalTexture()
        if normal then normal:SetVertexColor(color[1], color[2], color[3]) end
        local hl = icon:GetHighlightTexture()
        if hl then hl:SetVertexColor(color[1], color[2], color[3]); hl:SetAlpha(0.4) end

        local fs = pageHelp:CreateFontString(nil, "ARTWORK")
        fs:SetFont(RETRO_FONT, 13, "OUTLINE")
        -- Vertically center the label against the icon (icon spans rowY down
        -- to rowY-LINK_ICON; the label baseline sits at the icon's middle).
        fs:SetPoint("LEFT", icon, "RIGHT", 12, 0)
        fs:SetText(label)
        fs:SetTextColor(unpack(COLOR_CYAN))
        fs:SetShadowOffset(1, -1); fs:SetShadowColor(0, 0, 0, 1)

        local function open()
            StaticPopup_Show(popupKey, nil, nil, { url = url })
        end
        -- Icon hover brightens the label as a visual cue that the row is a
        -- link, even though only the icon takes the click.
        icon:SetScript("OnClick", open)
        icon:SetScript("OnEnter", function(self)
            fs:SetTextColor(1, 1, 1)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(tooltip, 1, 1, 1)
            GameTooltip:Show()
        end)
        icon:SetScript("OnLeave", function()
            fs:SetTextColor(unpack(COLOR_CYAN))
            GameTooltip:Hide()
        end)

        pageCursor[pageHelp] = pageCursor[pageHelp] - LINK_ROW_H
    end

    MakeLinkRow(ICON_CHAT, COLOR_CYAN, "Curseforge - Leave a comment",
        "RETRORUNS_CHAT_URL", URL_CURSE, "Comments and feedback (CurseForge)")
    MakeLinkRow(ICON_BUG, COLOR_PINK, "Github - Report a bug",
        "RETRORUNS_BUG_URL", URL_GITHUB, "Report a bug (GitHub)")
end

-- ---- Left nav tab rail ---------------------------------------------------

local tabs = {}
local selectedIndex = 1

local function SelectTab(index)
    selectedIndex = index
    for i, tab in ipairs(tabs) do
        local isSel = (i == index)
        pages[i]:SetShown(isSel)
        if isSel then
            tab.label:SetTextColor(unpack(COLOR_CYAN))
            tab.selMark:Show()
        else
            tab.label:SetTextColor(unpack(COLOR_LABEL))
            tab.selMark:Hide()
        end
    end
    -- The Toaster disclaimer + [!] glyph live in the panel footer (not on a
    -- page), so toggle them with the Toaster tab here.
    if panel.RR_UpdateDisclaimerVisibility then
        panel.RR_UpdateDisclaimerVisibility()
    end
end

local function MakeTab(index, text, page, withStatusDot, indented, yOffset)
    local tab = CreateFrame("Button", nil, panel)
    tab:SetSize(NAV_W - 16, TAB_H)
    -- yOffset nudges a tab off its even-spacing slot (positive = up). Used to
    -- pull the indented submenu tighter under its parent than the normal gap.
    tab:SetPoint("TOPLEFT", 16, NAV_TOP - (index - 1) * (TAB_H + TAB_GAP) + (yOffset or 0))

    local label = tab:CreateFontString(nil, "ARTWORK")
    label:SetFont(RETRO_FONT, 13, "OUTLINE")
    -- Submenu entries are indented so they read as a child of the tab above.
    label:SetPoint("LEFT", indented and 22 or 8, 0)
    label:SetText(text)
    label:SetTextColor(unpack(COLOR_LABEL))
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    tab.label = label

    -- Selected marker: a small cyan bar on the left edge of the active tab.
    local selMark = tab:CreateTexture(nil, "ARTWORK")
    selMark:SetColorTexture(unpack(COLOR_CYAN))
    selMark:SetSize(3, TAB_H - 8)
    selMark:SetPoint("LEFT", 0, 0)
    selMark:Hide()
    tab.selMark = selMark

    -- Optional at-a-glance status dot at the tab's right edge (tinted by the
    -- owning tab's refresh logic). Used by the Toaster tab so the live
    -- state reads without opening the tab.
    if withStatusDot then
        local dot = tab:CreateTexture(nil, "ARTWORK")
        dot:SetTexture("Interface\\AddOns\\RetroRuns\\Media\\StatusDot")
        dot:SetSize(9, 9)
        dot:SetPoint("RIGHT", -8, 0)
        tab.statusDot = dot
    end

    local hover = tab:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 1, 1, 0.08)

    tab:SetScript("OnClick", function() SelectTab(index) end)
    tabs[index] = tab
    return tab
end

MakeTab(1, "General",     pageGeneral)
MakeTab(2, "Appearance",  pageAppearance)
local toasterTab = MakeTab(3, "Toaster", pageToaster, true)
-- Customize is indented and pulled up tight under Toaster (smaller gap than
-- the even slot). Help follows, shifted up by the same amount so the gap
-- below Customize reads as a normal tab gap rather than a double gap.
MakeTab(4, "Customize",   pageCustomize, false, true, 10)
MakeTab(5, "What's New",  pageWhatsNew,  false, false, 10)
MakeTab(6, "Help",        pageHelp,      false, false, 10)

-- ---- Footer: reset + feedback icons --------------------------------------
local RESET_DEFAULTS = {
    fontSize = 12, windowScale = 1.0, panelOpacity = 1.0,
    bodyFontStyle = "standard", launchMode = "minimized", bossOrderMode = "rr",
    showMinimap = true, toasterEnabled = false, toasterLootSummary = true,
    toasterScale = 1.0, toasterLocked = true, toasterAnchor = nil,
    toasterDuration = 3.0, toasterStayUntilClick = false,
    toasterHideBossBanner = true,
}

-- Reconcile the Toaster tab: the read-only Status word reflects live truth,
-- and the two button pairs reflect their stored preferences.
RefreshToasterControls = function()
    local inRaid  = RR.currentRaid ~= nil
    local enabled = RR:GetSetting("toasterEnabled", false) ~= false

    -- Resolve the live state once: color + (for the in-panel arrow) direction
    -- and label. Both the in-panel Active Status row and the at-a-glance tab dot
    -- use the same color so they never disagree.
    local stateColor, arrowUp, labelText
    if not enabled then
        stateColor, arrowUp, labelText = COLOR_RED,   false, "MANUALLY DISABLED"
    elseif inRaid then
        stateColor, arrowUp, labelText = COLOR_GREEN,  true, "ACTIVE"
    else
        stateColor, arrowUp, labelText = COLOR_AMBER, false, "Travel to a Supported Raid"
    end

    if statusValue then
        statusArrow:SetRotation(arrowUp and math.pi or 0)   -- asset points down
        statusArrow:SetVertexColor(unpack(stateColor))
        statusArrow:Show()
        statusValue:SetText(labelText)
        statusValue:SetTextColor(unpack(stateColor))
    end

    -- At-a-glance dot on the Toaster tab (visible without opening the tab).
    if toasterTab and toasterTab.statusDot then
        toasterTab.statusDot:SetVertexColor(unpack(stateColor))
    end

    if enableRow then enableRow.Refresh(true) end
    -- Sub-rows are operable only when the Toaster is enabled.
    if lootSummaryRow  then lootSummaryRow.Refresh(enabled) end
    if soundRow  then soundRow.Refresh(enabled) end
    if bannerRow then bannerRow.Refresh(enabled) end
end

local function RefreshAllControls()
    for _, c in ipairs(controls) do
        if c.RR_Refresh then c:RR_Refresh() end
    end
    RefreshToasterControls()
end

local function ResetRetroRuns()
    -- Preserve the Toaster on/off state: resetting everything else shouldn't
    -- silently switch off a feature the player is actively using.
    local toasterWasEnabled = RR:GetSetting("toasterEnabled", false)

    for key, value in pairs(RESET_DEFAULTS) do RR:SetSetting(key, value) end
    RR:SetSetting("toasterEnabled", toasterWasEnabled)

    ApplyPanel()
    if UI.Update then UI.Update() end
    if RR.minimapButton then
        if RESET_DEFAULTS.showMinimap then RR.minimapButton:Show() else RR.minimapButton:Hide() end
    end
    if RR._toasterMock then RR._toasterMock:SetToastScale(RESET_DEFAULTS.toasterScale) end
    if RR.ApplyToasterScale then RR:ApplyToasterScale() end
    -- Position lock: clear any custom anchor and re-lock (hides the overlay).
    if RR.ResetToasterAnchor then RR:ResetToasterAnchor() end
    if RR.LockToasterAnchor then RR:LockToasterAnchor() end
    RefreshAllControls()
end

local resetButton = MakeTextButton("Reset to Defaults", 24, 16, 160, ResetRetroRuns)
-- Move Reset up to the title row, right-aligned, so it shares the band with
-- the RETRO RUNS wordmark instead of sitting in the footer.
resetButton:ClearAllPoints()
resetButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -24, -20)

-- "Lock toasts" checkbox on the Customize tab. Checked = locked (default);
-- unchecking surfaces the drag overlay to reposition the toasts.
local lockCheck = CreateFrame("CheckButton", nil, pageCustomize, "InterfaceOptionsCheckButtonTemplate")
lockCheck:SetPoint("TOPRIGHT", pageCustomize, "TOPRIGHT", -8, -4)
lockCheck.Text:SetText("Lock toasts")
lockCheck.Text:SetFont(RETRO_FONT, CONTROL_FONT_SIZE, "OUTLINE")
lockCheck.Text:SetTextColor(unpack(COLOR_LABEL))
lockCheck.Text:SetShadowOffset(1, -1)
lockCheck.Text:SetShadowColor(0, 0, 0, 1)
-- Label to the left of the box.
lockCheck.Text:ClearAllPoints()
lockCheck.Text:SetPoint("RIGHT", lockCheck, "LEFT", -4, 0)
lockCheck.tooltipText = "Lock toasts"
lockCheck.tooltipRequirement = "Uncheck to drag the toasts to a new spot, then re-check to lock."
lockCheck:SetScript("OnClick", function(self)
    local locked = self:GetChecked() and true or false
    RR:SetSetting("toasterLocked", locked)
    if locked then
        if RR.LockToasterAnchor then RR:LockToasterAnchor() end
    else
        if RR.UnlockToasterAnchor then RR:UnlockToasterAnchor() end
    end
end)
lockCheck.RR_Refresh = function(self) self:SetChecked(RR:GetSetting("toasterLocked", true)) end
controls[#controls + 1] = lockCheck

panel:SetScript("OnShow", function()
    RefreshAllControls()
    SelectTab(selectedIndex)
end)

-- Public hook: re-evaluate the Toaster control state. Called from the
-- lifecycle reconcile so that if settings is open when the player enters or
-- leaves a supported raid, the master checkbox enables/grays in step. Cheap
-- and safe to call when the panel is hidden.
function UI.RefreshSettingsToasterState()
    if panel:IsShown() then
        RefreshToasterControls()
    end
end

SelectTab(1)

-- ---- Register ------------------------------------------------------------
local category = Settings.RegisterCanvasLayoutCategory(panel, "RetroRuns")
Settings.RegisterAddOnCategory(category)

function UI.OpenSettings()
    if Settings.OpenToCategory then
        Settings.OpenToCategory(category:GetID())
    end
    -- Always land on the first (General) tab. Without this, the panel reopens
    -- to whatever sub-tab was last selected -- so after using the Toaster
    -- shortcut once, the plain settings button would keep reopening on Toaster.
    SelectTab(1)
end

-- Open settings straight to the Toaster tab. Used by the main panel's
-- footer status, which is clickable as a shortcut to the Toaster controls.
function UI.OpenSettingsToToaster()
    UI.OpenSettings()
    SelectTab(3)
end

-- Open settings straight to the What's New tab. Used by the main panel's
-- footer "What's New?" link (replaces the old standalone popup window).
function UI.OpenSettingsToWhatsNew()
    UI.OpenSettings()
    SelectTab(5)
end
