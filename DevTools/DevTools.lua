-------------------------------------------------------------------------------
-- DevTools.lua -- floating dev-tool launcher window
-------------------------------------------------------------------------------
-- A small always-on-top frame surfacing the dev-tool commands the author
-- runs frequently, plus a live zone/sub-zone/mapID/coords readout so map
-- context is always visible without needing /rr status every few seconds.
--
-- Button groups:
--   * Diag: consolidated dump (RetroEngine state + zone log + session log
--           in one copy window)
--   * Bring-up:  Tmog Verify, Raid Capture
--   * Recorder:  DialogDebug (toggles on/off, label reflects state)
--   * Utility:   Reload
--
-- Toggle with /rr devtools. Position persists via RetroRunsDB.devtools.
-------------------------------------------------------------------------------

local RR = RetroRuns

local devtoolsFrame
local readoutText      -- live zone/subZone/mapID/coords text
local tickerHandle     -- C_Timer.NewTicker handle while panel is shown
local RefreshReadout   -- forward declaration; defined below GetOrCreateDevToolsFrame

local PANEL_W = 280
local PANEL_H = 260

-- Build the frame on first toggle. Subsequent toggles just show/hide.
local function GetOrCreateDevToolsFrame()
    if devtoolsFrame then return devtoolsFrame end

    local f = CreateFrame("Frame", "RetroRunsDevToolsFrame", UIParent, "BackdropTemplate")
    f:SetSize(PANEL_W, PANEL_H)
    f:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.03, 0.03, 0.03, RR:GetSetting("panelOpacity", 1.0))

    -- Restore saved position; otherwise center on screen.
    local saved = RetroRunsDB and RetroRunsDB.devtools
    if saved and saved.point and saved.x and saved.y then
        f:SetPoint(saved.point, UIParent, saved.point, saved.x, saved.y)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Persist position. Save the panel's effective scale-divisor
        -- offsets in the same shape the skips window uses.
        RetroRunsDB = RetroRunsDB or {}
        RetroRunsDB.devtools = RetroRunsDB.devtools or {}
        local point, _, _, x, y = self:GetPoint(1)
        RetroRunsDB.devtools.point = point
        RetroRunsDB.devtools.x = x
        RetroRunsDB.devtools.y = y
    end)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f:Hide()

    -- Title bar.
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -10)
    title:SetText("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  DevTools")

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- ─────────────────────────────────────────────────────────────────
    -- Live readout block (zone / subZone / mapID / coords / status)
    -- ─────────────────────────────────────────────────────────────────
    local readoutHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    readoutHeader:SetPoint("TOPLEFT", 14, -34)
    readoutHeader:SetText("|cffaaaaaaCurrent location|r")

    readoutText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    readoutText:SetPoint("TOPLEFT", 14, -50)
    readoutText:SetJustifyH("LEFT")
    readoutText:SetWidth(PANEL_W - 28)
    readoutText:SetText("(updating...)")

    -- ─────────────────────────────────────────────────────────────────
    -- Tool buttons. Layout: 2-column grid for the per-workflow tools,
    -- with a full-width Reload at the bottom since it's the most-
    -- frequently-clicked utility action across every workflow.
    -- ─────────────────────────────────────────────────────────────────
    local function MakeButton(label, x, y, width, onClick)
        local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        btn:SetSize(width, 22)
        btn:SetPoint("TOPLEFT", x, y)
        btn:SetText(label)
        btn:SetScript("OnClick", onClick)
        return btn
    end

    local COL_W = 120          -- grid column width
    local L_X   = 14           -- left column X
    local R_X   = 146          -- right column X
    local FULL_W = PANEL_W - 28 -- full-width row width

    -- Row 1: full-width Diag. One-click consolidated copy window with
    -- RetroEngine state + zone log + session log. Capture state at
    -- each step transition; paste into the session log for analysis.
    MakeButton("Diag", L_X, -120, FULL_W, function()
        SlashCmdList["RETRORUNS"]("diag")
    end)

    -- Row 2: bring-up tools. Tmog Verify catches data-integrity issues
    -- before ship; Raid Capture kicks off the full tier+loot harvest
    -- for a newly-supported raid.
    MakeButton("Tmog Verify", L_X, -148, COL_W, function()
        SlashCmdList["RETRORUNS"]("tmogverify")
    end)
    MakeButton("Raid Capture", R_X, -148, COL_W, function()
        SlashCmdList["RETRORUNS"]("raidcapture")
    end)

    -- Row 3: DialogDebug toggle. Label updates dynamically based on
    -- RR:IsDialogDebugActive(); tracked on the frame so the ticker can
    -- refresh its text. Full-width because the toggle nature warrants
    -- the visual prominence; it's the recorder's main signal-capture
    -- knob during bring-up of a new raid's dialog triggers.
    f.dialogButton = MakeButton("DialogDebug Start", L_X, -176, FULL_W, function()
        if RR:IsDialogDebugActive() then
            RR:DialogDebugStop()
        else
            RR:DialogDebugStart()
        end
        RefreshReadout()
    end)

    -- Row 4: full-width Reload. Most-clicked action in any workflow --
    -- promoted to its own row to make it the easiest target.
    MakeButton("Reload", L_X, -210, FULL_W, function()
        ReloadUI()
    end)

    devtoolsFrame = f
    return f
end

-- Refresh the live readout. Called by the ticker while panel is shown,
-- and eagerly after each toggle-button click for snappy UI feedback.
RefreshReadout = function()
    if not readoutText then return end

    local zone     = GetZoneText() or "?"
    local subZone  = GetSubZoneText() or ""
    local mapID    = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or 0

    local x, y = 0, 0
    if mapID and mapID > 0 and C_Map and C_Map.GetPlayerMapPosition then
        local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then x, y = pos:GetXY() end
    end

    -- Multi-line readout. Coords are normalized 0-1 (matches recorder
    -- output format). Show as percentages for human readability since
    -- that's how TomTom/dropdown reads them.
    local lines = {
        ("|cffaaaaaaZone:|r %s"):format(zone),
        ("|cffaaaaaaSubzone:|r %s"):format(subZone ~= "" and subZone or "|cff666666(none)|r"),
        ("|cffaaaaaaMapID:|r %s"):format(tostring(mapID)),
        ("|cffaaaaaaCoords:|r %.1f, %.1f"):format(x * 100, y * 100),
    }
    readoutText:SetText(table.concat(lines, "\n"))

    -- DialogDebug toggle button: reflect current state so the button
    -- always shows the action that will fire on the NEXT click.
    if devtoolsFrame and devtoolsFrame.dialogButton then
        local active = RR:IsDialogDebugActive()
        devtoolsFrame.dialogButton:SetText(active and "DialogDebug Stop" or "DialogDebug Start")
    end
end

-- Public API: toggle the panel.
function RR:ToggleDevTools()
    local f = GetOrCreateDevToolsFrame()
    if f:IsShown() then
        f:Hide()
        if tickerHandle then
            tickerHandle:Cancel()
            tickerHandle = nil
        end
    else
        f:Show()
        RefreshReadout()                                -- paint immediately
        tickerHandle = C_Timer.NewTicker(0.5, RefreshReadout)
    end
end

-- /rr mapicons: dumps the exact normalized coords of every Blizzard map
-- link (zone-transition arrows, exits) and POI (boss icons, vendors,
-- etc.) on the currently-VIEWED world map. Workaround for the
-- shift-click-recording friction where clicking directly on top of a
-- Blizzard icon often gets eaten by Blizzard's icon click handler
-- before the recorder hook sees it. With this probe the icon's exact
-- coord comes straight from the API and goes into the routing seg --
-- no clicking required.
function RR:DumpMapIcons()
    local mapID = WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    if not mapID then
        self:Print("Open the world map first, then run /rr mapicons.")
        return
    end

    local lines = {}
    local function add(s) lines[#lines+1] = s end

    add(("Map icons for currently-viewed mapID %d"):format(mapID))
    add("")

    add("-- Map links (zone-transition arrows, exits) --")
    local links = (C_Map and C_Map.GetMapLinksForMap and C_Map.GetMapLinksForMap(mapID)) or {}
    if #links == 0 then
        add("  (none)")
    else
        for i, link in ipairs(links) do
            local x = (link.position and link.position.x) or -1
            local y = (link.position and link.position.y) or -1
            local linked = link.linkedUiMapID or 0
            local name   = (link.name ~= "" and link.name) or "(unnamed)"
            add(("  [%d] %s -> mapID=%d at { %.3f, %.3f }"):format(i, name, linked, x, y))
        end
    end
    add("")

    add("-- Map POIs (bosses, treasures, vendors, etc.) --")
    local pois = (C_Map and C_Map.GetMapPOIs and C_Map.GetMapPOIs(mapID)) or {}
    if #pois == 0 then
        add("  (none)")
    else
        for i, poi in ipairs(pois) do
            local x = (poi.position and poi.position.x) or -1
            local y = (poi.position and poi.position.y) or -1
            local name = (poi.name and poi.name ~= "" and poi.name) or "(unnamed)"
            local pid  = poi.areaPoiID or "?"
            add(("  [%d] %s at { %.3f, %.3f } areaPoiID=%s"):format(i, name, x, y, tostring(pid)))
        end
    end

    self:ShowCopyWindow(("Map icons for mapID %d"):format(mapID),
        table.concat(lines, "\n"))
end
