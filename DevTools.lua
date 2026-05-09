-------------------------------------------------------------------------------
-- DevTools.lua -- floating dev-tool launcher window
-------------------------------------------------------------------------------
-- A small always-on-top frame that surfaces the dev-tool commands the
-- author runs frequently during raid bring-ups (recorder Start/Stop, EJ
-- capture, raid loot capture, tmog verify), plus a live zone/sub-zone/
-- mapID readout so coords and map context are always visible without
-- needing /rr status every few seconds.
--
-- Currently wired up: Record Start, Record Stop. The other tool buttons
-- exist as visible-but-disabled placeholders so the panel layout stays
-- stable as more buttons get implemented over time.
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
    -- Tool buttons. Layout: 2-column grid below the readout block.
    -- Wired-up buttons are enabled; not-yet-implemented buttons render
    -- visibly disabled so the layout stays stable as more land.
    -- ─────────────────────────────────────────────────────────────────
    local function MakeButton(label, x, y, enabled, onClick)
        local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        btn:SetSize(120, 22)
        btn:SetPoint("TOPLEFT", x, y)
        btn:SetText(label)
        if enabled then
            btn:SetScript("OnClick", onClick)
        else
            btn:Disable()
        end
        return btn
    end

    -- Row 1: data-capture commands. Both wired through the slash dispatch
    -- since the underlying handlers expect the dispatch's arg-parsing
    -- convention (and tmogverify in particular is a large inline block,
    -- not a callable function).
    MakeButton("EJ Capture", 14, -120, true, function()
        SlashCmdList["RETRORUNS"]("ej")
    end)
    MakeButton("Raid Capture", 146, -120, true, function()
        SlashCmdList["RETRORUNS"]("raidcapture")
    end)

    -- Row 2: live toggles. Labels update dynamically based on the
    -- underlying state (RR.recorder.active / RR:IsYellDebugActive()).
    -- Tracked on the frame so the ticker can refresh their text.
    f.recordButton = MakeButton("Record Start", 14, -148, true, function()
        if RR.recorder and RR.recorder.active then
            RR:StopRecording()
        else
            RR:StartRecording()
        end
        RefreshReadout()    -- repaint immediately for snappy feedback
    end)

    f.yellButton = MakeButton("YellDebug Start", 146, -148, true, function()
        if RR:IsYellDebugActive() then
            RR:YellDebugStop()
        else
            RR:YellDebugStart()
        end
        RefreshReadout()    -- repaint immediately for snappy feedback
    end)

    -- Row 3: verification + manual-stamp safety net.
    --
    -- Mark Destination: manually triggers AutoStampCurrent on the in-
    -- progress segment when neither ENCOUNTER_END nor PLAYER_CONTROL_
    -- GAINED fires at the destination. Use cases:
    --   * intermediate non-boss locations (e.g. "stand on the
    --     Conclave platform pre-pull")
    --   * seamless portal/door transitions that don't take control
    --     from the player
    --   * mid-zone destinations like "stand at the orb" that have no
    --     Blizzard event tied to them
    -- The auto-stamp system catches boss kills and forced-flight
    -- transitions automatically; this button covers the rest.
    -- Disabled when recording is not active.
    MakeButton("Tmog Verify", 14, -176, true, function()
        SlashCmdList["RETRORUNS"]("tmogverify")
    end)
    f.markDestButton = MakeButton("Mark Destination", 146, -176, true, function()
        RR:RecorderMarkDestination()
    end)

    -- Row 4: Reload + Session Log. Two buttons side-by-side matching
    -- the row 1-3 grid (left at x=14, right at x=146).
    --
    -- Session Log: opens a copy window showing the verbose recorder
    -- session log -- every Click, Event, AutoStamp, Queue, Consume,
    -- SegCut, etc. with timestamps. Persisted to RetroRunsDB so it
    -- survives /reload. Use for diagnosing "why didn't auto-stamp fire
    -- here" or "what happened between sessions" questions. Always
    -- enabled (the log accumulates across sessions; can review even
    -- when not actively recording).
    MakeButton("Reload", 14, -210, true, function()
        ReloadUI()
    end)
    MakeButton("Session Log", 146, -210, true, function()
        RR:ShowRecorderSessionLog()
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

    -- Toggle-button labels. Reflect current state so the button always
    -- shows the action that will fire on the NEXT click.
    if devtoolsFrame and devtoolsFrame.recordButton then
        local active = RR.recorder and RR.recorder.active
        devtoolsFrame.recordButton:SetText(active and "Record Stop" or "Record Start")
    end
    if devtoolsFrame and devtoolsFrame.yellButton then
        local active = RR:IsYellDebugActive()
        devtoolsFrame.yellButton:SetText(active and "YellDebug Stop" or "YellDebug Start")
    end
    if devtoolsFrame and devtoolsFrame.markDestButton then
        -- Mark Destination only makes sense while recording is active --
        -- it stamps metadata onto the in-progress segment. Disable when
        -- inactive so a click doesn't fire a "no current segment" toast.
        local recActive = RR.recorder and RR.recorder.active
        if recActive then
            devtoolsFrame.markDestButton:Enable()
        else
            devtoolsFrame.markDestButton:Disable()
        end
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
