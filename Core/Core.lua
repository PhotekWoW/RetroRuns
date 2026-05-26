-------------------------------------------------------------------------------
-- RetroRuns -- Core.lua
-- Namespace, DB lifecycle, event hub, slash commands, shared utilities.
-- No UI frame references. No navigation logic.
-------------------------------------------------------------------------------

local ADDON_NAME = "RetroRuns"
local VERSION    = "1.11.0"

-------------------------------------------------------------------------------
-- Namespace
-------------------------------------------------------------------------------

RetroRuns = {
    VERSION = VERSION,
    frame   = CreateFrame("Frame"),

    currentRaid = nil,

    -- Runtime state -- never written to SavedVariables
    state = {
        bossesKilled          = {},   -- [bossIndex] = true
        activeStep            = nil,
        testMode              = false,
        manualTargetBossIndex = nil,
        loadedRaidKey         = nil,
        lastSeenRaidKey       = nil,
        lastUnsupportedRaid   = nil,
        currentDifficultyID   = nil,
        currentDifficultyName = nil,
        isReloadingUi         = false, -- captured from PLAYER_ENTERING_WORLD
        zoneLog               = {},   -- ring buffer of zone-change debug lines, viewable via /rr diag
        -- Last mapID seen by the strict-activeSeg heartbeat poll. Kept in
        -- sync with the seeder so a step transition can't trigger a
        -- phantom advance on the next tick.
        lastPolledMapID       = nil,
    },

    -- SavedVariable defaults; user values are preserved via MergeDefaults
    defaults = {
        showPanel    = false,
        debug        = false,
        windowScale  = 1.0,
        fontSize     = 12,
        panelOpacity = 1.0,
        panelX       = 0,
        panelY       = 0,
        settingsX    = 290,
        settingsY    = 60,
        -- Compact title-bar mode (toggled via the minimize button).
        -- Persists across /reload.
        minimized    = false,
        -- launchMode: what to show on load. Values:
        --   "hidden"    - panel closed
        --   "minimized" - compact title bar (default)
        --   "full"      - fully expanded
        -- Clicking "Load" on the in-raid prompt always opens fully.
        launchMode   = "minimized",
        -- bodyFontStyle: font for panel body text. Values:
        --   "standard" - WoW's Friz Quadrata (default)
        --   "retro"    - 04B_03 pixel font
        --   "vt323"    - VT323 terminal-style
        -- Frame headers + action buttons stay 04B_03 regardless.
        bodyFontStyle = "standard",
    },
}

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Utilities (shared across all modules via the RR namespace)
-------------------------------------------------------------------------------

--- Deep-merge src into dst, filling only nil keys.
local function MergeDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            MergeDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

--- Strip leading/trailing whitespace.
function RR.Trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

--- Prefixed chat output.
function RR:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff7fbfffRetroRuns:|r " .. tostring(msg))
end

--- Debug output (only when the debug setting is enabled).
function RR:Debug(msg)
    if self:GetSetting("debug") then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cffaaaaaa[RR Debug]|r " .. tostring(msg))
    end
end

--- Append a line to the in-memory zone-change log. Bounded ring buffer so
--- a long session doesn't accumulate unbounded memory. View with
--- /rr diag (zone log appears in the consolidated dump).
function RR:ZoneLog(msg)
    local buf = self.state.zoneLog
    table.insert(buf, ("[%s] %s"):format(date("%H:%M:%S"), tostring(msg)))
    -- Buffer cap: 1000 entries. Bumped from 200 in v1.7 because the 1Hz
    -- heartbeat tick logger (when /rr debug is on) produced 60 entries/min,
    -- exhausting a 200-entry buffer in ~3 minutes and pushing useful HLC-
    -- fire entries out before they could be reviewed. 1000 covers ~16 min
    -- of continuous debug-mode heartbeat plus headroom for actual events.
    while #buf > 1000 do table.remove(buf, 1) end
end

--- Per-provider installation checks. Each of the six waypoint providers
--- in our cascade has its own detection signature; centralizing the
--- checks here keeps GetNavTier, the cascade in NavigateToEntrance /
--- NavigateToSanctum, and the legend renderer in UI.lua in lock-step.
--- If any one drifts, the wrong pill lights or the wrong branch fires.
function RR:IsAWPInstalled()
    return _G.AzerothWaypointNS
        and type(_G.AzerothWaypointNS.RequestManualRoute) == "function"
        or false
end

function RR:IsZygorInstalled()
    return _G.ZygorGuidesViewer
        and _G.ZygorGuidesViewer.Pointer
        and _G.ZygorGuidesViewer.Pointer.SetWaypoint
        and true or false
end

--- Zygor's waypoint arrow is gated by a user setting. When disabled,
--- Zygor's SetWaypoint silently no-ops -- this predicate lets the UI
--- warn the user. Couples to ZGV.db.profile.arrowshow; renames in a
--- future Zygor release degrade silently to "enabled."
function RR:IsZygorArrowEnabled()
    local zgv = _G.ZygorGuidesViewer
    if not zgv then return false end
    if zgv.db and zgv.db.profile and zgv.db.profile.arrowshow ~= nil then
        return zgv.db.profile.arrowshow == true
    end
    return true
end

function RR:IsMapzerothInstalled()
    return (_G.Mapzeroth and _G.Mapzeroth.FindRoute) and true or false
end

--- Waypoint UI (AdaptiveX). Polished in-world arrow that rides on top
--- of Blizzard's C_SuperTrack.
function RR:IsWUIInstalled()
    return _G.WaypointUIAPI
        and _G.WaypointUIAPI.Navigation
        and type(_G.WaypointUIAPI.Navigation.NewUserNavigation) == "function"
        or false
end

function RR:IsTomTomInstalled()
    return (_G.TomTom and _G.TomTom.AddWaypoint) and true or false
end

function RR:IsBlizzardWaypointAvailable()
    return (C_Map and C_Map.SetUserWaypoint and _G.UiMapPoint) and true or false
end

--- Returns the navigation tier we'd dispatch through right now:
---   "routing"  - a step-by-step planner is loaded (AWP, Zygor, Mapzeroth)
---   "waypoint" - only a waypoint provider available (TomTom or Blizzard)
--- Re-evaluated on every call so a fresh /reload picks up newly-loaded
--- addons. Used by the UI to gate the entrance-button visual state.
function RR:GetNavTier()
    if self:IsAWPInstalled()       then return "routing" end
    if self:IsZygorInstalled()     then return "routing" end
    if self:IsMapzerothInstalled() then return "routing" end
    return "waypoint"
end

--- Route the player to the entrance of a raid.
---
--- Two-slot dispatch:
---   ROUTING SLOT: AWP -> Zygor -> Mapzeroth (one wins).
---   WAYPOINT SLOT: WUI -> TomTom -> Blizzard fallback.
--- Both slots can fire on one click (e.g. Zygor route + WUI overlay).
--- The Blizzard fallback only fires if neither slot produced a UI.
function RR:GetRaidEntrance(raid)
    if not raid then return nil end
    return raid.entrance
end

--- Returns a struct describing which slot(s) fired:
---     { routing = "awp"|"zygor"|"mapzeroth"|nil,
---       waypoint = "wui"|"tomtom"|"blizzard"|nil }
--- The UI uses this to surface branch-specific feedback (e.g. the
--- "waypoint set" toast for silent-at-click providers). Returns nil
--- entirely on failure (no entrance data, no providers available).
function RR:NavigateToEntrance(raid)
    local e = self:GetRaidEntrance(raid)
    if not raid or not e then
        self:Print("No entrance data for that raid.")
        return nil
    end
    if not e.mapID or not e.x or not e.y then
        self:Print("Entrance data is incomplete.")
        return nil
    end

    -- Clear any in-progress route before starting a new one.
    self:CancelNavRoute()

    local title = ("RetroRuns: %s entrance"):format(raid.name or "raid")
    local result = { planner = nil, arrow = nil, overlays = {} }

    -- PLANNER ROLE: AWP-with-backend > Zygor > Mapzeroth. One wins.
    local hasBackend = self:IsZygorInstalled() or self:IsMapzerothInstalled()
    if self:IsAWPInstalled() and hasBackend then
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            e.mapID, e.x, e.y, title, nil, nil)
        if ok and routed then
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.awpRoute = true
            result.planner = "awp"
        end
    end

    if not result.planner and self:IsZygorInstalled() then
        -- Mirrors Zygor's own /zygor goto payload. findpath=true gates
        -- multi-leg routing (otherwise just an arrow).
        _G.ZygorGuidesViewer.Pointer:SetWaypoint(e.mapID, e.x, e.y, {
            findpath    = true,
            type        = "manual",
            cleartype   = true,
            title       = title,
            onminimap   = "always",
            overworld   = true,
            showonedge  = true,
        }, true)
        self.state.activeRoute = self.state.activeRoute or { raid = raid }
        self.state.activeRoute.raid = raid
        self.state.activeRoute.zygorRoute = true
        result.planner = "zygor"
    end

    if not result.planner and self:IsMapzerothInstalled() then
        _G.Mapzeroth:FindRoute("_WAYPOINT_DESTINATION", {
            mapID  = e.mapID,
            x      = e.x,
            y      = e.y,
            name   = title,
            source = "retroruns",
        })
        self.state.activeRoute = self.state.activeRoute or { raid = raid }
        self.state.activeRoute.raid = raid
        self.state.activeRoute.mapzerothRoute = true
        result.planner = "mapzeroth"
    end

    -- ARROW ROLE: TomTom > Blizzard. Suppressed if a planner fired
    -- (planner provides its own arrow).
    if not result.planner then
        if self:IsTomTomInstalled() then
            local uid = TomTom:AddWaypoint(e.mapID, e.x, e.y, {
                title  = title,
                from   = "RetroRuns",
                silent = true,
                crazy  = true,
            })
            -- Force SetCrazyArrow explicitly -- the AddWaypoint flag
            -- doesn't reliably render the arrow on some 12.0 configs.
            if uid and TomTom.SetCrazyArrow then
                TomTom:SetCrazyArrow(uid, TomTom.profile and TomTom.profile.arrow
                    and TomTom.profile.arrow.arrival or 0, title)
            end
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.tomtomWaypoint = uid
            result.arrow = "tomtom"

        elseif self:IsBlizzardWaypointAvailable() then
            local point = UiMapPoint.CreateFromCoordinates(e.mapID, e.x, e.y)
            C_Map.SetUserWaypoint(point)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.blizzardWaypoint = true
            result.arrow = "blizzard"
        end
    end

    -- OVERLAY ROLE: AWP (when not already-fired as planner) + WUI
    -- (always fires when installed). Both can layer simultaneously.
    if self:IsAWPInstalled() and result.planner ~= "awp" then
        -- AWP without a backend still queues the destination as a
        -- single-pin overlay.
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            e.mapID, e.x, e.y, title, nil, nil)
        if ok and routed then
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.awpOverlay = true
            table.insert(result.overlays, "awp")
        end
    end

    if self:IsWUIInstalled() then
        -- WUI uses 0-100 coords; scale our 0-1 values on the way in.
        _G.WaypointUIAPI.Navigation.NewUserNavigation(title, e.mapID, e.x * 100, e.y * 100)
        self.state.activeRoute = self.state.activeRoute or { raid = raid }
        self.state.activeRoute.raid = raid
        self.state.activeRoute.wuiRoute = true
        table.insert(result.overlays, "wui")
    end

    if not result.planner and not result.arrow and #result.overlays == 0 then
        self:Print("No supported waypoint API available.")
        return nil
    end
    return result
end

--- Drop a waypoint at a Covenant Sanctum weapon vendor (Castle
--- Nathria). Same three-role dispatch as NavigateToEntrance.
function RR:NavigateToSanctum(raid, covID)
    if not raid or not raid.weaponVendors or not covID then
        self:Print("No sanctum vendor data available.")
        return nil
    end
    local vendor = raid.weaponVendors[covID]
    if not vendor or not vendor.vendorMapID or not vendor.x or not vendor.y then
        self:Print("Sanctum vendor data is incomplete.")
        return nil
    end

    -- Clear any in-progress route before starting a new one.
    self:CancelNavRoute()

    local title = ("RetroRuns: %s (%s vendor)"):format(
        vendor.vendorName or "Sanctum", vendor.covenantName or "covenant")
    local result = { planner = nil, arrow = nil, overlays = {} }
    local mapID, x, y = vendor.vendorMapID, vendor.x, vendor.y

    -- PLANNER ROLE --------------------------------------------------------
    local hasBackend = self:IsZygorInstalled() or self:IsMapzerothInstalled()
    if self:IsAWPInstalled() and hasBackend then
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            mapID, x, y, title, nil, nil)
        if ok and routed then
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.awpRoute = true
            result.planner = "awp"
        end
    end

    if not result.planner and self:IsZygorInstalled() then
        _G.ZygorGuidesViewer.Pointer:SetWaypoint(mapID, x, y, {
            findpath    = true,
            type        = "manual",
            cleartype   = true,
            title       = title,
            onminimap   = "always",
            overworld   = true,
            showonedge  = true,
        }, true)
        self.state.activeRoute = self.state.activeRoute or { raid = raid }
        self.state.activeRoute.raid = raid
        self.state.activeRoute.zygorRoute = true
        result.planner = "zygor"
    end

    if not result.planner and self:IsMapzerothInstalled() then
        _G.Mapzeroth:FindRoute("_WAYPOINT_DESTINATION", {
            mapID  = mapID, x = x, y = y, name = title, source = "retroruns",
        })
        self.state.activeRoute = self.state.activeRoute or { raid = raid }
        self.state.activeRoute.raid = raid
        self.state.activeRoute.mapzerothRoute = true
        result.planner = "mapzeroth"
    end

    -- ARROW ROLE ----------------------------------------------------------
    if not result.planner then
        if self:IsTomTomInstalled() then
            local uid = TomTom:AddWaypoint(mapID, x, y, {
                title  = title,
                from   = "RetroRuns",
                silent = true,
                crazy  = true,
            })
            if uid and TomTom.SetCrazyArrow then
                TomTom:SetCrazyArrow(uid, TomTom.profile and TomTom.profile.arrow
                    and TomTom.profile.arrow.arrival or 0, title)
            end
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.tomtomWaypoint = uid
            result.arrow = "tomtom"

        elseif self:IsBlizzardWaypointAvailable() then
            local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
            C_Map.SetUserWaypoint(point)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.blizzardWaypoint = true
            result.arrow = "blizzard"
        end
    end

    -- OVERLAY ROLE --------------------------------------------------------
    if self:IsAWPInstalled() and result.planner ~= "awp" then
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            mapID, x, y, title, nil, nil)
        if ok and routed then
            self.state.activeRoute = self.state.activeRoute or { raid = raid }
            self.state.activeRoute.raid = raid
            self.state.activeRoute.awpOverlay = true
            table.insert(result.overlays, "awp")
        end
    end

    if self:IsWUIInstalled() then
        _G.WaypointUIAPI.Navigation.NewUserNavigation(title, mapID, x * 100, y * 100)
        self.state.activeRoute = self.state.activeRoute or { raid = raid }
        self.state.activeRoute.raid = raid
        self.state.activeRoute.wuiRoute = true
        table.insert(result.overlays, "wui")
    end

    if not result.planner and not result.arrow and #result.overlays == 0 then
        self:Print("No supported waypoint API available.")
        return nil
    end
    return result
end

--- Cancel the active nav route, if any. TomTom + Blizzard waypoints
--- get explicit cleanup; the planner addons (AWP, Zygor, Mapzeroth)
--- replace their own routes on the next call so no teardown is needed.
function RR:CancelNavRoute()
    local route = self.state.activeRoute
    if not route then return end

    if route.tomtomWaypoint and TomTom and TomTom.RemoveWaypoint then
        if TomTom:IsValidWaypoint(route.tomtomWaypoint) then
            TomTom:RemoveWaypoint(route.tomtomWaypoint)
        end
    end

    if route.blizzardWaypoint and C_Map and C_Map.ClearUserWaypoint then
        C_Map.ClearUserWaypoint()
    end

    self.state.activeRoute = nil
end

--- Normalise a name for fuzzy matching:
--- lowercase, strip punctuation, collapse whitespace.
function RR:NormalizeName(name)
    if not name then return nil end
    name = name:lower()
    name = name:gsub("[\226\128\152\226\128\153'\96]", "") -- curly + straight apostrophes
    name = name:gsub("[^%w%s%-]", "")
    name = name:gsub("%s+", " ")
    name = name:match("^%s*(.-)%s*$")
    return name
end

--- Safe field accessor -- returns nil instead of erroring on bad data.
--- Usage: RR.Get(step, "segments", 1, "mapID")
function RR.Get(tbl, ...)
    local cur = tbl
    for _, key in ipairs({ ... }) do
        if type(cur) ~= "table" then return nil end
        cur = cur[key]
    end
    return cur
end

--- Read a single key from RetroRunsDB with a fallback default.
-- Nil-safe: returns `default` if RetroRunsDB is not yet initialized.
-- Use instead of bare `RetroRunsDB and RetroRunsDB.foo or default` patterns.
function RR:GetSetting(key, default)
    if not RetroRunsDB then return default end
    local v = RetroRunsDB[key]
    if v == nil then return default end
    return v
end

--- Write a single key to RetroRunsDB.
-- Nil-safe: lazily initializes RetroRunsDB if it doesn't exist yet.
-- Use instead of bare `RetroRunsDB = RetroRunsDB or {}; RetroRunsDB.foo = v`
-- patterns scattered throughout the codebase.
function RR:SetSetting(key, value)
    RetroRunsDB = RetroRunsDB or {}
    RetroRunsDB[key] = value
end

-------------------------------------------------------------------------------
-- Data validation
-------------------------------------------------------------------------------

--- Walks all raid data and returns a list of issues. Each is
--- { severity = "error"|"warn", raid = displayName, msg = detail }.
--- Consumed by the addon-load lint pass (errors only) and /rr lintroute
--- (everything). scopeFilter limits the walk to a name substring.
local function CollectRaidDataIssues(scopeFilter)
    local issues = {}
    local function add(severity, raid, msg)
        table.insert(issues, { severity = severity, raid = raid, msg = msg })
    end

    if not RetroRuns_Data then
        add("error", "(global)", "RetroRuns_Data is nil -- no raid data loaded")
        return issues
    end

    -- Strings flagged in raid.maps[] that mean "this name has not been
    -- in-game-verified." Linted as warnings so they don't block a run
    -- but are easy to find for follow-up verification.
    local UNVERIFIED_MAP_MARKERS = { "??", "unverified", "inferred" }
    local function looksUnverified(s)
        if type(s) ~= "string" then return false end
        local lower = s:lower()
        for _, marker in ipairs(UNVERIFIED_MAP_MARKERS) do
            if lower:find(marker, 1, true) then return true end
        end
        return false
    end

    local function matchesScope(raidName)
        if not scopeFilter or scopeFilter == "" then return true end
        if type(raidName) ~= "string" then return false end
        return raidName:lower():find(scopeFilter:lower(), 1, true) ~= nil
    end

    -- Single-table validator. Called once for the shared table and once
    -- for the Horde-specific table (which holds parallel raid data for
    -- faction-asymmetric raids; currently only BfD).
    local function validateTable(tbl, tableLabel)
        if type(tbl) ~= "table" then return end
        for instanceID, raid in pairs(tbl) do
            local raidName = raid.name or ("?@" .. tostring(instanceID))
            -- For faction-asymmetric raids, distinguish in the report
            -- so a BfD-Horde-specific issue is recognizable.
            local raidLabel = raidName
            if tableLabel == "DataHorde" then
                raidLabel = raidName .. " (Horde)"
            end

            -- Apply scope filter: skip raids whose name (or
            -- faction-disambiguated label) doesn't match the filter.
            -- A nil/empty filter matches everything, handled inside
            -- matchesScope.
            if matchesScope(raidName) or matchesScope(raidLabel) then

            if not raid.instanceID then
                add("error", raidLabel, "missing instanceID")
            end
            if type(raid.bosses) ~= "table" or #raid.bosses == 0 then
                add("error", raidLabel, "missing or empty bosses table")
            end
            if type(raid.routing) ~= "table" or #raid.routing == 0 then
                add("error", raidLabel, "missing or empty routing table")
            end

            -- Build a set of valid boss indices for cross-checking,
            -- and validate specialLoot while we're at it.
            local validBossIndices = {}
            local VALID_SPECIAL_KINDS = { mount = true, pet = true, toy = true, decor = true, manuscript = true, illusion = true }
            for _, boss in ipairs(raid.bosses or {}) do
                if not boss.index then
                    add("error", raidLabel, "boss missing index field")
                elseif not boss.name then
                    add("error", raidLabel, ("boss #%s missing name"):format(tostring(boss.index)))
                else
                    validBossIndices[boss.index] = true
                end

                if boss.specialLoot ~= nil then
                    if type(boss.specialLoot) ~= "table" then
                        add("error", raidLabel,
                            ("boss #%s specialLoot must be a table"):format(tostring(boss.index)))
                    else
                        for si, item in ipairs(boss.specialLoot) do
                            local bp = ("boss #%s specialLoot[%d]:"):format(
                                tostring(boss.index), si)
                            if not item.id then
                                add("error", raidLabel, bp .. " missing id")
                            end
                            if not item.kind then
                                add("error", raidLabel,
                                    bp .. " missing kind (mount|pet|toy|decor|manuscript|illusion)")
                            elseif not VALID_SPECIAL_KINDS[item.kind] then
                                add("error", raidLabel,
                                    bp .. (" unrecognized kind '%s' (expected mount|pet|toy|decor|manuscript|illusion)"):format(
                                        tostring(item.kind)))
                            end
                            -- kind=illusion needs a sourceID for the
                            -- C_TransmogCollection.GetIllusionSourceInfo
                            -- lookup (item.id is the itemID, separate
                            -- from the illusion's visual sourceID).
                            -- Lint the missing-sourceID case so author
                            -- doesn't ship without the validation hook.
                            if item.kind == "illusion" and not item.sourceID then
                                add("error", raidLabel,
                                    bp .. " kind=illusion requires sourceID field for transmog API validation")
                            end
                        end
                    end
                end
            end

            -- Maps-table linting: warn on entries flagged unverified
            -- (matches "??", "unverified", or "inferred" anywhere in
            -- the value). These are intentional placeholders awaiting
            -- in-game verification, but we want them visible so they
            -- don't get forgotten.
            if type(raid.maps) == "table" then
                for mapID, mapName in pairs(raid.maps) do
                    if looksUnverified(mapName) then
                        add("warn", raidLabel,
                            ("maps[%s] = %q is flagged unverified"):format(
                                tostring(mapID), tostring(mapName)))
                    end
                end
            end

            -- Schema validation. Every raid is on the RetroEngine; segs
            -- declare their gates via `when`, `after`, and `triggeredBy`.

            for i, step in ipairs(raid.routing or {}) do
                local sp = "step " .. i .. ":"
                if not step.bossIndex then
                    add("error", raidLabel, sp .. " missing bossIndex")
                elseif not validBossIndices[step.bossIndex] then
                    add("error", raidLabel,
                        sp .. (" bossIndex %d has no matching boss"):format(step.bossIndex))
                end
                if not step.requires then
                    add("error", raidLabel, sp .. " missing requires table (use {} for none)")
                else
                    for _, req in ipairs(step.requires) do
                        if not validBossIndices[req] then
                            add("error", raidLabel,
                                sp .. (" requires unknown bossIndex %d"):format(req))
                        end
                    end
                end
                if not step.segments or #step.segments == 0 then
                    add("error", raidLabel, sp .. " has no segments")
                else
                    local prevMapID = nil
                    local numSegs = #step.segments
                    for si, seg in ipairs(step.segments) do
                        local segMapID

                        -- when.mapID is required.
                        if not seg.when then
                            add("error", raidLabel,
                                sp .. (" segment %d missing when table"):format(si))
                        elseif not seg.when.mapID then
                            add("error", raidLabel,
                                sp .. (" segment %d when.mapID missing"):format(si))
                        else
                            segMapID = seg.when.mapID
                        end

                        -- Bare mapID/subZone are stale schema leftovers
                        -- that should be stripped from data.
                        if seg.mapID then
                            add("warn", raidLabel,
                                sp .. (" segment %d has bare mapID field (strip from data)"):format(si))
                        end
                        if seg.mapID and seg.when and seg.when.mapID
                            and seg.mapID ~= seg.when.mapID
                        then
                            add("error", raidLabel,
                                sp .. (" segment %d bare mapID=%d but when.mapID=%d (disagree)"):format(
                                    si, seg.mapID, seg.when.mapID))
                        end
                        if seg.subZone then
                            add("warn", raidLabel,
                                sp .. (" segment %d has bare subZone field (strip from data)"):format(si))
                        end

                        -- Dropped fields from the legacy schema. Flag any
                        -- raid data that still carries them.
                        if seg.requiresSubZone then
                            add("error", raidLabel,
                                sp .. (" segment %d has requiresSubZone (use when.subZone)"):format(si))
                        end
                        if seg.revealAfter then
                            add("error", raidLabel,
                                sp .. (" segment %d has revealAfter (use after)"):format(si))
                        end
                        if seg.advanceOn then
                            add("error", raidLabel,
                                sp .. (" segment %d has advanceOn (use triggeredBy)"):format(si))
                        end
                        if seg.gateBySubZone then
                            add("warn", raidLabel,
                                sp .. (" segment %d has gateBySubZone (unused field; remove)"):format(si))
                        end
                        if seg.revealAfterMapVisit then
                            add("warn", raidLabel,
                                sp .. (" segment %d has revealAfterMapVisit (unused field; remove)"):format(si))
                        end

                        -- kind: must be "path" or "poi".
                        if seg.kind == "teleport" or seg.kind == "kill" then
                            add("error", raidLabel,
                                sp .. (" segment %d kind=%q is no longer supported (use \"path\")"):format(si, seg.kind))
                        elseif seg.kind and seg.kind ~= "path" and seg.kind ~= "poi" then
                            add("error", raidLabel,
                                sp .. (" segment %d kind=%q invalid (expected \"path\" or \"poi\")"):format(si, tostring(seg.kind)))
                        end
                        -- triggeredBy shape:
                        if seg.triggeredBy then
                            if type(seg.triggeredBy) ~= "table" then
                                add("error", raidLabel,
                                    sp .. (" segment %d triggeredBy must be a table"):format(si))
                            elseif seg.triggeredBy.yell then
                                local y = seg.triggeredBy.yell
                                if type(y) ~= "table" then
                                    add("error", raidLabel,
                                        sp .. (" segment %d triggeredBy.yell must be a table"):format(si))
                                else
                                    if not y.npc then
                                        add("error", raidLabel,
                                            sp .. (" segment %d triggeredBy.yell missing npc field"):format(si))
                                    end
                                    if not y.match then
                                        add("error", raidLabel,
                                            sp .. (" segment %d triggeredBy.yell missing match field"):format(si))
                                    end
                                end
                            else
                                -- triggeredBy with no known sub-key (e.g. just empty {})
                                add("warn", raidLabel,
                                    sp .. (" segment %d triggeredBy has no recognized sub-key (expected yell)"):format(si))
                            end
                        end
                        -- after must reference valid seg indices in same step:
                        if seg.after then
                            if type(seg.after) ~= "table" then
                                add("error", raidLabel,
                                    sp .. (" segment %d after must be a table of seg indices"):format(si))
                            else
                                for _, prereqIdx in ipairs(seg.after) do
                                    if type(prereqIdx) ~= "number"
                                        or prereqIdx < 1 or prereqIdx > numSegs
                                    then
                                        add("error", raidLabel,
                                            sp .. (" segment %d after references invalid seg index %s (step has %d segs)"):format(
                                                si, tostring(prereqIdx), numSegs))
                                    elseif prereqIdx >= si then
                                        add("error", raidLabel,
                                            sp .. (" segment %d after references seg %d which is not earlier in step"):format(si, prereqIdx))
                                    end
                                end
                            end
                        end

                        -- Consecutive-duplicate mapID check: two segs
                        -- in a row with the same mapID is almost
                        -- always a copy-paste oversight. Legitimate
                        -- cases exist (a path that crosses an area,
                        -- exits, then re-enters) but are rare enough
                        -- that flagging gives signal worth checking.
                        if segMapID and prevMapID == segMapID then
                            add("warn", raidLabel,
                                sp .. (" segments %d and %d have the same mapID %d (intentional? or copy-paste?)"):format(
                                    si - 1, si, segMapID))
                        end
                        prevMapID = segMapID
                    end
                end
            end

            end -- if matchesScope
        end
    end

    validateTable(RetroRuns_Data,      "Data")
    validateTable(RetroRuns_DataHorde, "DataHorde")
    return issues
end

-- Wrapper preserving the old load-time API: walk all raids, surface
-- only ERROR-severity issues via RR:Debug (chat output gated by
-- /rr debug). Warnings (unverified maps, subZone-not-in-maps,
-- duplicate-consecutive mapIDs) are intentionally omitted here --
-- they're not malformed data, just things worth checking, and they
-- belong in /rr lintroute output where they can be reviewed
-- deliberately rather than every login.
local function ValidateRaidData()
    local issues = CollectRaidDataIssues(nil)
    for _, issue in ipairs(issues) do
        if issue.severity == "error" then
            RR:Debug(("Data[%s]: %s"):format(issue.raid, issue.msg))
        end
    end
end

--- Public on-demand linter. Walks all raid data, formats every
--- issue (errors AND warnings) as a categorized report, and opens
--- a copy window. With an optional scope substring (e.g. "Aberrus"),
--- limits the report to raids whose name contains that substring
--- (case-insensitive).
---
--- @param scopeFilter string?  Optional raid-name substring filter.
function RR:LintRoute(scopeFilter)
    local issues = CollectRaidDataIssues(scopeFilter)

    local errors, warns = {}, {}
    for _, issue in ipairs(issues) do
        if issue.severity == "error" then
            table.insert(errors, issue)
        else
            table.insert(warns, issue)
        end
    end

    local out = {}
    local function add(s) table.insert(out, s) end

    add("RetroRuns -- Route Lint Report")
    if scopeFilter and scopeFilter ~= "" then
        add(("Scope: raids matching %q"):format(scopeFilter))
    else
        add("Scope: all loaded raids")
    end
    add(("Errors: %d   Warnings: %d"):format(#errors, #warns))
    add("")

    if #errors == 0 and #warns == 0 then
        add("No issues found.")
    else
        if #errors > 0 then
            add("=== ERRORS ===")
            for _, issue in ipairs(errors) do
                add(("  [%s] %s"):format(issue.raid, issue.msg))
            end
            add("")
        end
        if #warns > 0 then
            add("=== WARNINGS ===")
            for _, issue in ipairs(warns) do
                add(("  [%s] %s"):format(issue.raid, issue.msg))
            end
            add("")
        end
    end

    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaRoute Lint Report|r",
        table.concat(out, "\n"))
    self:Print(("Lint complete: %d errors, %d warnings. Copy window opened."):format(
        #errors, #warns))
end

-------------------------------------------------------------------------------
-- SavedVariable lifecycle
-------------------------------------------------------------------------------

function RR:InitializeDB()
    RetroRunsDB = RetroRunsDB or {}
    MergeDefaults(RetroRunsDB, self.defaults)

    -- Apply launchMode to set the panel's load-time visibility. Three
    -- modes, see defaults.launchMode for full rationale:
    --   "hidden"    -> panel closed
    --   "minimized" -> panel open, in minimized title-bar mode
    --   "full"      -> panel open, fully expanded
    -- Anything unrecognized falls through to "minimized" (the default).
    -- This replaces the pre-1.10.2 unconditional force-to-hidden behavior;
    -- existing users get "minimized" on first load post-upgrade via the
    -- MergeDefaults call above seeding launchMode for the first time.
    local launchMode = RetroRunsDB.launchMode
    if launchMode == "hidden" then
        RetroRunsDB.showPanel = false
    elseif launchMode == "full" then
        RetroRunsDB.showPanel = true
        RetroRunsDB.minimized = false
    else
        RetroRunsDB.showPanel = true
        RetroRunsDB.minimized = true
    end

    -- Restore recorder session log from persistent storage so /reload
    -- mid-recording doesn't lose diagnostic context. Recorder state
    -- itself (active, current, segments, stampLog) intentionally does
    -- NOT survive reload -- those are per-session-attempt and should
    -- start clean on each addon load. Only the long-lived log is
    -- restored for cross-reload diagnostic continuity.
    --
    -- Scoped per character: each character has its own bucket so an
    -- alt's debug session doesn't pollute the main's diagnostic view.
    -- Old single-flat-list shape (pre per-character) is discarded on
    -- first load -- the array marker is RetroRunsDB.recorderSessionLog[1]
    -- being a non-nil table; character keys never index as integers.
    if RetroRunsDB.recorderSessionLog
        and RetroRunsDB.recorderSessionLog[1] ~= nil then
        RetroRunsDB.recorderSessionLog = nil
    end
    if self.recorder then
        local bucket = RetroRunsDB.recorderSessionLog
                   and RetroRunsDB.recorderSessionLog[self:GetCharacterKey()]
        if bucket then
            self.recorder.sessionLog = bucket
        end
    end
    -- Restore pending auto-stamp event (queued ENCOUNTER_END or
    -- PLAYER_CONTROL_GAINED that fired while recording was inactive).
    -- Persisted in QueuePendingEvent; cleared in ConsumePendingEvent
    -- and ResetRecording. Survives /reload so a queued event isn't
    -- silently lost when the user reloads between queue and the next
    -- StartRecording. Stored as time() epoch seconds, so the staleness
    -- check in ConsumePendingEvent stays valid across reloads.
    if RetroRunsDB.recorderPendingEvent and self.recorder then
        self.recorder.pendingEvent = RetroRunsDB.recorderPendingEvent
    end

    -- Persist zone log across /reload. RR.state.zoneLog is aliased to
    -- RetroRunsDB.zoneLog so existing read/write paths continue to
    -- work unchanged; the underlying storage is now SavedVariable-
    -- backed. This survives /reload (critical for diagnosing reload-
    -- related bugs where the events leading up to the reload are
    -- exactly what you need to see) and gets wiped on initial login
    -- via the PEW handler.
    -- Buffer cap of 1000 entries still enforced in RR:ZoneLog.
    RetroRunsDB.zoneLog = RetroRunsDB.zoneLog or {}
    self.state.zoneLog = RetroRunsDB.zoneLog
end

function RR:RestorePanelPosition()
    if RetroRunsUI then
        RetroRunsUI:ClearAllPoints()
        RetroRunsUI:SetPoint(
            "CENTER", UIParent, "CENTER",
            self:GetSetting("panelX", 0),
            self:GetSetting("panelY", 0))
    end
end

-------------------------------------------------------------------------------
-- Instance detection
-------------------------------------------------------------------------------

function RR:GetCurrentInstanceInfo()
    local name, instanceType, difficultyID, difficultyName,
          _, _, _, instanceID = GetInstanceInfo()
    return {
        name           = name,
        instanceType   = instanceType,
        difficultyID   = difficultyID,
        difficultyName = difficultyName,
        instanceID     = instanceID,
    }
end

function RR:GetRaidContextKey(raid, info)
    raid = raid or self.currentRaid
    info = info or self:GetCurrentInstanceInfo()
    if not raid or not info then return nil end
    return tostring(raid.instanceID or info.instanceID or "?")
           .. ":" .. tostring(info.difficultyID or 0)
end

function RR:GetRaidDisplayName()
    if not self.currentRaid then return nil end
    local diff = self.state.currentDifficultyName
    if diff and diff ~= "" then
        return ("%s (%s)"):format(self.currentRaid.name, diff)
    end
    return self.currentRaid.name
end

-- Per-difficulty kill counts for a raid:
--   { [difficultyID] = { complete = N, total = M } }
-- where IDs are 17 (LFR), 14 (Normal), 15 (Heroic), 16 (Mythic).
-- Reads via C_RaidLocks.IsEncounterComplete; bridges from our
-- journalEncounterIDs to dungeonEncounterIDs via the EJ map.
-- Returns nil if no current raid or no journalInstanceID. Unsupported
-- difficulties get total=0; caller decides how to render.

-- Cache journalEncounterID -> dungeonEncounterID per journalInstanceID.
-- Stable for the session; cleared on /reload.
local ejMapCache = {}

local function GetEJMapForJournalInstance(journalInstanceID)
    if not journalInstanceID or journalInstanceID == 0 then return nil end
    local cached = ejMapCache[journalInstanceID]
    if cached then return cached end

    -- Save the currently-selected EJ instance so we can restore it.
    local prevInst = EJ_GetSelectedInstance and EJ_GetSelectedInstance() or nil
    if EJ_SelectInstance then
        EJ_SelectInstance(journalInstanceID)
    end

    local jeToDe = {}
    local count  = 0
    local i = 1
    while true do
        local _, _, je, _, _, _, de = EJ_GetEncounterInfoByIndex(i, journalInstanceID)
        if not je then break end
        if de then
            jeToDe[je] = de
            count = count + 1
        end
        i = i + 1
    end

    -- Restore the prior selection so an open EJ window doesn't snap
    -- to whichever raid we just queried. Skip the restore if there
    -- was no prior selection.
    if prevInst and EJ_SelectInstance then
        EJ_SelectInstance(prevInst)
    end

    -- Only memoize non-empty results. Empty would mean the API was
    -- still warming up or the precondition wasn't satisfied; we want
    -- the next call to retry, not to lock in the empty result for
    -- the rest of the session.
    if count > 0 then
        ejMapCache[journalInstanceID] = jeToDe
    end
    return jeToDe
end

-- Expose on the RR namespace so other files (Navigation.lua's
-- locale-independent ENCOUNTER_END resolver) can build the same
-- journalEncounterID -> dungeonEncounterID lookup without
-- duplicating the EJ_SelectInstance dance.
function RR:GetEJMapForJournalInstance(journalInstanceID)
    return GetEJMapForJournalInstance(journalInstanceID)
end

-- Compute per-difficulty kill counts for ANY raid (not just the
-- currently-loaded one). Used by both the in-raid pill row and the
-- idle-state supported-raids list.
--
-- For the currently-loaded raid (active difficulty in particular), the
-- caller is responsible for the MAX-with-bossesKilled trick that lets
-- ENCOUNTER_END register kills before the saved-instance cache catches
-- up. This function reads PURELY from cache; no live state.
function RR:GetPerDifficultyKillCountsForRaid(raid)
    if not raid then return nil end
    if not C_RaidLocks or not C_RaidLocks.IsEncounterComplete then return nil end

    local journalInstanceID = raid.journalInstanceID
    local instanceID        = raid.instanceID
    if not journalInstanceID or not instanceID then return nil end

    local jeToDe = GetEJMapForJournalInstance(journalInstanceID)
    if not jeToDe then return nil end

    -- 17=LFR, 14=Normal, 15=Heroic, 16=Mythic.
    local difficulties = { 17, 14, 15, 16 }
    local result = {}
    local total  = 0
    for _, b in ipairs(raid.bosses or {}) do
        local de = jeToDe[b.journalEncounterID]
        if de then total = total + 1 end
    end
    for _, dID in ipairs(difficulties) do
        local complete = 0
        for _, b in ipairs(raid.bosses or {}) do
            local de = jeToDe[b.journalEncounterID]
            if de and C_RaidLocks.IsEncounterComplete(instanceID, de, dID) then
                complete = complete + 1
            end
        end
        result[dID] = { complete = complete, total = total }
    end

    -- The instance cache updates asynchronously after a kill -- use
    -- in-memory bossesKilled as a floor for the active difficulty so
    -- pills update immediately on kill.
    if self.currentRaid and raid == self.currentRaid then
        local activeDifficulty = self.state.currentDifficultyID
        if activeDifficulty and result[activeDifficulty] then
            local localCount = 0
            for _, b in ipairs(raid.bosses or {}) do
                if self.state.bossesKilled[b.index] then
                    localCount = localCount + 1
                end
            end
            if localCount > result[activeDifficulty].complete then
                result[activeDifficulty].complete = localCount
            end
        end
    end

    return result
end

function RR:GetPerDifficultyKillCounts()
    if not self.currentRaid then return nil end
    return self:GetPerDifficultyKillCountsForRaid(self.currentRaid)
end

-- Raid-skip unlock detection. Skip quests are account-wide as of
-- Patch 11.0.5 (use IsQuestFlaggedCompletedOnAccount, not the
-- per-character flag). Quest flags don't backfill -- completing the
-- Mythic skip sets the Mythic flag true but leaves Heroic/Normal
-- false. The in-game cascade lets a higher-difficulty unlock be used
-- at lower difficulties, so the highest flag-true difficulty is the
-- ceiling.
-- The walk from highest to lowest gives us the ceiling directly.

-- Normalize raid.skipQuests into an array of chain descriptors. Returns
-- nil if the raid has no skipQuests configured.
--
-- The schema supports two shapes:
--
--   Single-chain (legacy, most raids):
--     skipQuests = { normal = N, heroic = H, mythic = M }
--
--   Multi-chain (Antorus and any future raid with parallel skip chains):
--     skipQuests = {
--         { label = "Imonar",   normal = N1, heroic = H1, mythic = M1 },
--         { label = "Aggramar", normal = N2, heroic = H2, mythic = M2 },
--     }
--
-- This helper detects which shape is in use and returns the multi-chain
-- form in both cases -- the legacy single-chain raids are wrapped as a
-- one-element array with no label. Downstream consumers always iterate
-- the array and can assume the normalized shape.
--
-- Shape detection: in the multi-chain shape, indices [1] / [2] / ...
-- exist and are tables. In the legacy shape, raid.skipQuests.normal /
-- heroic / mythic exist directly.
local function NormalizeSkipChains(raid)
    if not raid or not raid.skipQuests then return nil end
    local sq = raid.skipQuests
    -- Multi-chain shape: numeric-indexed array of chain tables.
    if sq[1] and type(sq[1]) == "table" then
        return sq
    end
    -- Legacy single-chain shape: wrap as one-element array. Preserve
    -- whatever fields are present; missing fields stay nil (the chain
    -- accessor handles that).
    return { { normal = sq.normal, heroic = sq.heroic, mythic = sq.mythic } }
end

-- Returns the ceiling (highest unlocked difficulty ID) for one chain
-- descriptor. Returns nil if no flag in the chain is set or the quest-
-- log API isn't available. Difficulty IDs match GetRaidSkipUnlockedCeiling:
-- 16 = Mythic, 15 = Heroic, 14 = Normal.
local function CeilingForChain(chain)
    if not chain then return nil end
    local fn = C_QuestLog and C_QuestLog.IsQuestFlaggedCompletedOnAccount
    if not fn then return nil end
    if chain.mythic and fn(chain.mythic) then return 16 end
    if chain.heroic and fn(chain.heroic) then return 15 end
    if chain.normal and fn(chain.normal) then return 14 end
    return nil
end

-- Returns a normalized array of per-chain ceiling descriptors:
--   { { label = "...", ceiling = 16 | 15 | 14 | nil }, ... }
-- One entry per chain in raid.skipQuests. Single-chain raids return a
-- one-element array; the legacy shape's lack of a label means
-- result[1].label is nil. Returns nil if the raid has no skipQuests
-- (use skipAchievement-aware accessors for that case).
function RR:GetSkipChainCeilings(raid)
    local chains = NormalizeSkipChains(raid)
    if not chains then return nil end
    local out = {}
    for _, chain in ipairs(chains) do
        table.insert(out, { label = chain.label, ceiling = CeilingForChain(chain) })
    end
    return out
end

-- Returns the highest difficulty for which the skip is unlocked on the
-- account, or nil if no flag is set or the raid has neither skipQuests
-- nor skipAchievement configured. Returned values are WoW raid difficulty
-- IDs:
--   16 = Mythic, 15 = Heroic, 14 = Normal.
-- LFR (17) is intentionally excluded -- LFR raids don't have skip quests.
--
-- Two skip-mechanism schemas are recognized:
--   * skipQuests: standard post-Shadowlands quest-flag cascade. Per
--     difficulty, with downward cascade (mythic implies heroic implies
--     normal) handled by the consumer (IsRaidSkipAvailableAtDifficulty).
--     May be single-chain (most raids) or multi-chain (Antorus); see
--     NormalizeSkipChains for the shape detection.
--   * skipAchievement: BfD-only sibling field. Mythic-only, gated by an
--     achievement ID. The achievement's per-account "completed" boolean
--     is the 4th return of GetAchievementInfo (since 11.0.5, this is
--     account-wide for any cross-realm earned achievement).
--
-- For multi-chain raids, returns the MAX ceiling across all chains. The
-- ceiling-per-chain detail (needed by the Skips UI to render two rows)
-- lives in GetSkipChainCeilings.
function RR:GetRaidSkipUnlockedCeiling(raid)
    if not raid then return nil end

    -- Standard quest-flag cascade.
    if raid.skipQuests then
        local perChain = self:GetSkipChainCeilings(raid)
        if not perChain then return nil end
        local maxCeiling
        for _, c in ipairs(perChain) do
            if c.ceiling and (not maxCeiling or c.ceiling > maxCeiling) then
                maxCeiling = c.ceiling
            end
        end
        return maxCeiling
    end

    -- BfD-only achievement-gated skip. Mythic-only -- the cascade-down
    -- rule does NOT apply here. Caller must consult RaidSkipIsCascading
    -- (or equivalent) before assuming downward unlock.
    if raid.skipAchievement and raid.skipAchievement.mythic then
        if GetAchievementInfo then
            local _, _, _, completed = GetAchievementInfo(raid.skipAchievement.mythic)
            if completed then return 16 end
        end
        return nil
    end

    return nil
end

-- True iff the raid's skip mechanic uses the standard cascade-down rule
-- (completing X unlocks X and every easier difficulty). False for
-- achievement-gated skips, which only unlock the exact difficulty named.
function RR:RaidSkipIsCascading(raid)
    if not raid then return false end
    if raid.skipQuests then return true end
    if raid.skipAchievement then return false end
    return false
end

-- Returns true if the skip is available at the given difficulty,
-- accounting for the downward cascade rule (completing X unlocks
-- everything <= X). difficultyID should be one of the raid difficulty
-- IDs: 14 (Normal), 15 (Heroic), 16 (Mythic). For LFR or any other
-- non-skip-eligible difficulty, returns false.
function RR:IsRaidSkipAvailableAtDifficulty(raid, difficultyID)
    if not difficultyID then return false end
    -- Skip system is Normal/Heroic/Mythic only.
    if difficultyID < 14 or difficultyID > 16 then return false end
    local ceiling = self:GetRaidSkipUnlockedCeiling(raid)
    if not ceiling then return false end
    -- Non-cascading skips (BfD-only achievement-gated) only unlock the
    -- exact difficulty matching the ceiling -- the standard "everything
    -- below the ceiling is also unlocked" rule does not apply.
    if not self:RaidSkipIsCascading(raid) then
        return difficultyID == ceiling
    end
    return difficultyID <= ceiling
end

-- Binary "is this raid's skip unlocked at any difficulty?" Convenience
-- wrapper for callers that just want to know whether to surface the
-- skip-marker affordance. Mostly equivalent to "does
-- GetRaidSkipUnlockedCeiling return non-nil" but keeps the call site
-- self-documenting.
function RR:HasRaidSkipUnlocked(raid)
    return self:GetRaidSkipUnlockedCeiling(raid) ~= nil
end

-- Looks up the data table for the raid the player is currently inside.
-- For most raids (faction-symmetric) the data lives at
-- RetroRuns_Data[instanceID] and that's all there is to it.
--
-- BfD is faction-asymmetric: bosses 1-3 differ in journalEncounterIDs
-- and display names, the boss-2/3 order is swapped, the entrance is in a
-- different city/zone, and the routing path through the raid is entirely
-- different. Rather than parameterizing every field, we ship Horde data
-- as a parallel file (`BattleOfDazaralorHorde.lua`) that registers under
-- a separate global `RetroRuns_DataHorde[instanceID]`. This lookup
-- consults that table first when the player is Horde, falling through to
-- the shared `RetroRuns_Data` table when no Horde-specific data exists
-- (the case for the other 9 raids and for Alliance / Neutral characters).
--
-- Faction read per-call via UnitFactionGroup; cheap C-side string lookup,
-- no caching needed. Pandaren on Wandering Isle return "Neutral" -- they
-- can't enter the raid anyway, but the fall-through to RetroRuns_Data
-- means the panel still surfaces the Alliance-side data so they're not
-- looking at an empty panel pre-faction-pick.
function RR:GetSupportedRaid()
    local info = self:GetCurrentInstanceInfo()
    if info.instanceType ~= "raid" then return nil end

    local faction = UnitFactionGroup("player")
    if faction == "Horde" and RetroRuns_DataHorde then
        if RetroRuns_DataHorde[info.instanceID] then
            return RetroRuns_DataHorde[info.instanceID]
        end
        if info.name then
            local needle = self:NormalizeName(info.name)
            for _, raid in pairs(RetroRuns_DataHorde) do
                if raid.instanceID ~= 0
                    and self:NormalizeName(raid.name) == needle
                then
                    return raid
                end
            end
        end
        -- No Horde-specific data for this raid; fall through to the
        -- shared Alliance/symmetric table below.
    end

    if RetroRuns_Data then
        if RetroRuns_Data[info.instanceID] then
            return RetroRuns_Data[info.instanceID]
        end
        if info.name then
            local needle = self:NormalizeName(info.name)
            for _, raid in pairs(RetroRuns_Data) do
                if raid.instanceID ~= 0
                    and self:NormalizeName(raid.name) == needle
                then
                    return raid
                end
            end
        end
    end
    return nil
end

-- Browser-context faction-aware lookup. Same dispatch shape as
-- GetSupportedRaid (above) but takes an explicit instanceID rather than
-- reading the player's current zone. Used by the Tmog and Achievements
-- browsers, which let the user select a raid by name without having to
-- be zoned into it. Returns nil if the instanceID isn't registered in
-- either table.
function RR:GetRaidByInstanceID(instanceID)
    if not instanceID then return nil end
    local faction = UnitFactionGroup("player")
    if faction == "Horde"
        and RetroRuns_DataHorde
        and RetroRuns_DataHorde[instanceID]
    then
        return RetroRuns_DataHorde[instanceID]
    end
    return RetroRuns_Data and RetroRuns_Data[instanceID] or nil
end

-------------------------------------------------------------------------------
-- Raid load / unload
-------------------------------------------------------------------------------

-- Walk GetNumSavedInstances and return the lockoutId for the currently-
-- loaded raid (matching instanceID + active difficulty). Returns nil if no
-- saved instance matches -- usually means a fresh lockout with no kills yet.
--
-- The lockoutId is unique per-lockout: when the weekly reset rolls a new
-- lockout, the lockoutId changes, even if instanceID and difficulty are
-- the same. That's what makes it the right key for invalidating persisted
-- per-lockout state (like routingProgress) on lockout reset.
function RR:GetCurrentLockoutId()
    if not self.currentRaid then return nil end
    if not self.state.currentDifficultyID then return nil end

    local numSaved = GetNumSavedInstances()
    for i = 1, numSaved do
        local _, lockoutId, _, difficultyId, _, _, _, isRaid,
              _, _, _, _, _, instanceID = GetSavedInstanceInfo(i)
        if isRaid
            and instanceID   == self.currentRaid.instanceID
            and difficultyId == self.state.currentDifficultyID then
            return lockoutId
        end
    end
    return nil
end

-- Single canonical "go to real raid state" routine. Wipes any test-mode
-- or stale state, syncs bossesKilled from the saved-instance cache,
-- restores persisted segments (if the lockout still matches), recomputes
-- the active step, and fires a UI refresh.
--
-- Called from LoadCurrentRaid (after raid context change) and from
-- DisableTestMode (after exiting /rr test). Both contexts need exactly
-- the same state-rebuild sequence.
function RR:RestoreRealRaidState()
    self:ClearBossState()
    self:SyncFromSavedRaidInfo(true)   -- request fresh server data
    self:RestorePersistedProgress()
    self:ComputeNextStep()
    self:RefreshAll()
end

function RR:LoadCurrentRaid()
    if not self.currentRaid then return end
    self.state.loadedRaidKey = self:GetRaidContextKey()

    self:RestorePersistedProgress()

    -- Force the panel to fully-expanded mode (visible + un-minimized)
    -- regardless of the user's launchMode setting. Clicking "Load" on
    -- the in-raid popup is an explicit engagement signal -- the user
    -- wants to see the navigation surface for this raid, not a tiny
    -- title-bar or a hidden panel. SetSetting writes showPanel/minimized
    -- to the saved variable; SetMinimized additionally triggers a full
    -- UI.Update so body-content visibility flips synchronously rather
    -- than waiting for the next heartbeat tick.
    self:SetSetting("showPanel", true)
    if RR.UI and RR.UI.SetMinimized then
        RR.UI.SetMinimized(false)
    end
    self:RefreshAll()
end

function RR:UnloadCurrentRaid()
    self.state.loadedRaidKey = nil
    self:RefreshAll()
end

StaticPopupDialogs["RETRORUNS_LOAD_RAID"] = {
    text = "|cffF259C7RETRO|r|cff4DCCFFRUNS|r\n\n"
        .. "Route data found for:\n|cffffff00%s|r\n\n"
        .. "Load navigation?\n\n"
        .. "|cffc0c0c0This addon is in early development.\nPlease report bugs if you encounter issues!|r",
    button1        = "Load",
    button2        = "Not Now",
    OnAccept       = function() RetroRuns:LoadCurrentRaid() end,
    OnCancel       = function() RetroRuns:UnloadCurrentRaid() end,
    OnShow         = function(self)
        if self.text then self.text:SetJustifyH("CENTER") end
    end,
    timeout        = 0,
    whileDead      = true,
    hideOnEscape   = true,
    preferredIndex = 3,
}

function RR:HandleLocationChange()
    local info = self:GetCurrentInstanceInfo()

    if info.instanceType ~= "raid" then
        self.currentRaid                 = nil
        self.state.lastSeenRaidKey       = nil
        self.state.currentDifficultyID   = nil
        self.state.currentDifficultyName = nil
        self.state.lastUnsupportedRaid   = nil
        self.state.lastPlayerMapID       = nil
        self:UnloadCurrentRaid()
        return
    end

    -- Zone-change segment completion. When the player leaves a mapID, mark
    -- the earliest incomplete segment of the active step that matches the
    -- mapID they just left as complete. This is the only segment-completion
    -- mechanism that works inside raid instances, since Blizzard restricts
    -- C_Map.GetPlayerMapPosition to nil there (see Recorder.lua's preamble).
    -- Disambiguates the case where a step has multiple segments on the
    -- same mapID separated by a detour through another mapID -- e.g.
    -- Terros's path traverses Vault Approach (2122) twice with a Primal
    -- Convergence (2124) crossing in between. Without this, the renderer's
    -- earliest-incomplete-on-current-mapID picker would surface seg 2
    -- ("toward Convergence") even after the player has come back through
    -- Convergence and is heading toward seg 4 ("to Terros").
    local currentMapID = C_Map and C_Map.GetBestMapForUnit and
                         C_Map.GetBestMapForUnit("player")
    local previousMapID = self.state.lastPlayerMapID

    -- Helper: resolve mapID -> sub-zone name from the active raid's
    -- maps table, falling back to the raw ID if no name is registered.
    local mapName = function(id)
        if not id then return "(none)" end
        local raidMaps = self.currentRaid and self.currentRaid.maps
        local n = raidMaps and raidMaps[id]
        if n then return ("%s (%d)"):format(n, id) end
        return ("mapID %d"):format(id)
    end
    local zoneText    = (GetZoneText and GetZoneText())       or ""
    local subZoneText = (GetSubZoneText and GetSubZoneText()) or ""
    local minimapText = (GetMinimapZoneText and GetMinimapZoneText()) or ""
    self:ZoneLog(("HLC fired. prev=%s curr=%s | zone=%q subZone=%q minimap=%q")
        :format(mapName(previousMapID), mapName(currentMapID),
                zoneText, subZoneText, minimapText))

    if currentMapID and previousMapID and currentMapID ~= previousMapID then
        self:AdvanceProgress("zone")
    end

    -- Same-mapID subZone change. The RetroEngine handles segs gated on
    -- when.subZone (EP step 3 seg 2 "Halls of the Chosen" is the
    -- canonical case): player /reloads on mapID 1513 with the parent
    -- subZone, then the subZone updates to "Halls of the Chosen"
    -- without a mapID change. Without this call, the seeder's
    -- location-match-at-seed time misses the gate and progress stays
    -- stuck at the pre-gate seg. Self-gated internally (no-op if no
    -- advance is computed), so cheap for raids whose segs never use
    -- when.subZone gating.
    if currentMapID and previousMapID and currentMapID == previousMapID then
        self:AdvanceProgress("zone")
    end

    if currentMapID then
        self.state.lastPlayerMapID = currentMapID
    end

    local supported = self:GetSupportedRaid()
    if supported then
        self.currentRaid                 = supported
        self.state.currentDifficultyID   = info.difficultyID
        self.state.currentDifficultyName = info.difficultyName

        -- Warm GetItemInfo cache for every loot item in this raid.
        -- Cheap one-shot pass (~150 items per raid). Each call is
        -- async: if the item isn't cached, GetItemInfo returns nil
        -- but queues a fetch; the second call for the same itemID
        -- returns the cached record. The tmog browser's legendary-
        -- quality detection (UI.lua FormatItemRow) reads
        -- GetItemInfo's quality field, which on first cold-cache
        -- access returns nil -- causing legendary items to render
        -- white the first time the popup opens. Warming here
        -- ensures quality is populated by the time the user opens
        -- the popup. Also primes other paths that read item info
        -- (special-loot rendering, slash-command status output).
        if GetItemInfo and supported.bosses then
            for _, boss in ipairs(supported.bosses) do
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
            end
        end

        local key = self:GetRaidContextKey(supported, info)
        if self.state.lastSeenRaidKey ~= key then
            -- New raid context (different raid, or same raid but
            -- different difficulty). Wipe in-memory bossesKilled before
            -- showing the load popup, otherwise the new raid would
            -- inherit kill marks from the previous raid -- bossIndex-
            -- keyed without raid scoping, so they collide.
            -- SyncFromSavedRaidInfo's removal-rejection guard (defeats
            -- saved-instance cache hiccups mid-session) would otherwise
            -- refuse to clear the stale data when the new raid's cache
            -- reports no kills.
            wipe(self.state.bossesKilled)
            self.state.lastSeenRaidKey = key
            self.state.loadedRaidKey   = nil
            self:SetSetting("showPanel", false)
            if RetroRunsUI then RetroRunsUI:Hide() end
            StaticPopup_Show("RETRORUNS_LOAD_RAID",
                self:GetRaidDisplayName() or supported.name)
        elseif self.state.loadedRaidKey == key then
            self:RefreshAll()
        end
    else
        -- Player has left all raids (or zoned to a non-raid map).
        -- Same wipe rationale as the new-raid branch above: in-memory
        -- raid state is bossIndex-keyed without raid scoping, so it
        -- must be cleared when the player leaves so the next raid
        -- they enter starts with a clean baseline.
        wipe(self.state.bossesKilled)
        self.currentRaid                 = nil
        self.state.loadedRaidKey         = nil
        self.state.currentDifficultyID   = nil
        self.state.currentDifficultyName = nil
        if info.name and self.state.lastUnsupportedRaid ~= info.name then
            self.state.lastUnsupportedRaid = info.name
            self:Print(info.name .. " is not supported yet.")
        end
    end
end

-------------------------------------------------------------------------------
-- Global refresh
-------------------------------------------------------------------------------

function RR:RefreshAll()
    if self.currentRaid then
        local changed = self:SyncFromSavedRaidInfo(true)   -- request fresh server data
        self:ZoneLog(("RefreshAll: changed=%s"):format(tostring(changed)))
        -- If the sync detected no kill-state change, skip the UI.Update
        -- and MapOverlay refresh -- there is nothing new to render. This
        -- avoids panel-flicker on every zone-change event in raid
        -- instances where most events don't represent meaningful state
        -- transitions (sub-zone toggles, periodic UPDATE_INSTANCE_INFO,
        -- etc.). When real state changes happen (boss kill via
        -- ENCOUNTER_END, saved-instance reset between sessions, etc.)
        -- the sync returns true and the UI updates normally.
        if changed == false then return end
    else
        self.state.activeStep = nil
    end
    self:ZoneLog("RefreshAll: calling UI.Update + MapOverlay:Refresh")
    RR.UI.Update()
    if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
end

-------------------------------------------------------------------------------
-- Test-mode helpers
-------------------------------------------------------------------------------

function RR:ResetTestState()
    self:ClearBossState()
    self.state.testMode             = true
    self.state.manualTargetBossIndex = nil
    self:ComputeNextStep()
end

function RR:DisableTestMode()
    self.state.testMode             = false
    self.state.manualTargetBossIndex = nil
    -- Wipe any fake test-mode state and rebuild from real lockout.
    -- Without this, exiting test mode left the panel showing the
    -- accumulated test-mode kills/segments rather than reality.
    -- testMode must be set to false BEFORE this call -- SyncFromSavedRaidInfo
    -- short-circuits when testMode is true.
    self:RestoreRealRaidState()
end

function RR:SimulateKillNext()
    if not self.currentRaid then
        self:Print("No supported raid detected.")
        return
    end
    if not self.state.testMode then
        self.state.testMode = true
        self:ClearBossState()
        self:ComputeNextStep()
    end
    local step = self.state.activeStep or self:ComputeNextStep()
    if not step then self:Print("No available next step.") ; return end
    local boss = self:GetBossByIndex(step.bossIndex)
    self:MarkBossKilled(boss)
    self:ComputeNextStep()
    self:Print("Simulated kill: " .. (boss and boss.name or "Unknown"))
    RR.UI.Update()
    if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
end

-------------------------------------------------------------------------------
-- Manual kill overrides  (/rr kill, /rr unkill)
-------------------------------------------------------------------------------

function RR:ManualKill(input)
    if not self.currentRaid then
        self:Print("No raid loaded.")
        return
    end
    local boss = self:ResolveBoss(input)
    if not boss then
        self:Print(("No boss matched '%s'."):format(input))
        return
    end
    self:MarkBossKilled(boss)
    self:ComputeNextStep()
    self:Print(("Marked killed: %s"):format(boss.name))
    RR.UI.Update()
    if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
end

function RR:ManualUnkill(input)
    if not self.currentRaid then
        self:Print("No raid loaded.")
        return
    end
    local boss = self:ResolveBoss(input)
    if not boss then
        self:Print(("No boss matched '%s'."):format(input))
        return
    end
    self.state.bossesKilled[boss.index] = nil
    self:ComputeNextStep()
    self:Print(("Marked alive: %s"):format(boss.name))
    RR.UI.Update()
    if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
end

-- Print a one-shot summary of the current state to a copy window.
-- Useful for quickly checking what raid is loaded, what step you're on,
-- and which bosses have been marked killed, without having to open the
-- UI. Pasteable for sharing during debugging.
function RR:PrintStatus()
    local lines = {}
    local function add(s) table.insert(lines, s) end

    if not self.currentRaid then
        add("Raid: (none loaded)")
        add("Open a supported raid to load state.")
        RR:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaastatus|r",
            table.concat(lines, "\n"))
        self:Print("Status window opened.  (no raid loaded)")
        return
    end

    local raid = self.currentRaid
    local key  = self:GetRaidContextKey()
    local loaded = self.state.loadedRaidKey == key

    add(("Raid: %s%s"):format(
        raid.name,
        loaded and "" or "  (state not loaded -- key mismatch)"))

    -- Instance IDs. Helpful when verifying that a new raid's skeleton
    -- has the right instanceID / journalInstanceID at first zone-in.
    -- If liveInstanceID differs from raid.instanceID, the popup still
    -- fired (so something matched) but only through a fallback -- worth
    -- investigating before continuing a new-raid build.
    local _, _, _, _, _, _, _, liveInstanceID = GetInstanceInfo()
    local idLine = ("IDs: instanceID=%s"):format(tostring(raid.instanceID))
    if liveInstanceID and liveInstanceID ~= raid.instanceID then
        idLine = idLine .. ("  (LIVE=%d -- mismatch!)"):format(liveInstanceID)
    end
    if raid.journalInstanceID then
        idLine = idLine .. ("  journalInstanceID=%d"):format(raid.journalInstanceID)
    end
    add(idLine)

    -- Live map(s). Shows both the player's resolved mapID and -- if
    -- different -- the world-map-frame's current selection. Prefers
    -- the raid.maps hand-authored sub-zone name, since Blizzard's
    -- GetMapInfo API returns the parent raid name for sub-zones in
    -- raids like Sanctum and isn't useful here. Flags any mapID not
    -- yet in raid.maps so we know which sub-zones still need to be
    -- declared as routes get recorded.
    local function FormatMapLine(label, mapID)
        local info     = C_Map.GetMapInfo(mapID)
        local apiName  = (info and info.name) or "?"
        local known    = raid.maps and raid.maps[mapID]
        local display  = known or apiName
        local line = ("%s mapID: %d  \"%s\""):format(label, mapID, display)
        if known and apiName ~= known then
            line = line .. ("  (GetMapInfo returns \"%s\")"):format(apiName)
        elseif not known then
            line = line .. "  (not in raid.maps yet)"
        end
        return line
    end

    local playerMapID = C_Map and C_Map.GetBestMapForUnit
                        and C_Map.GetBestMapForUnit("player")
    if playerMapID then
        add(FormatMapLine("Player", playerMapID))
    end
    local worldMapID = WorldMapFrame and WorldMapFrame:GetMapID()
    if worldMapID and worldMapID ~= playerMapID then
        add(FormatMapLine("WorldMap", worldMapID))
    end

    -- Live zone/sub-zone strings. These are independent of mapID --
    -- e.g. mapID 2120 covers "The Elemental Conclave" but the player's
    -- live sub-zone string can flicker to "" mid-walk inside that
    -- mapID. Flicker can drive UI re-renders that the kill-state path
    -- doesn't surface, so showing both here makes /rr status useful
    -- for sub-zone-driven debugging.
    local zone    = (GetZoneText and GetZoneText())       or ""
    local subZone = (GetSubZoneText and GetSubZoneText()) or ""
    if zone == "" then zone = "<empty>" end
    if subZone == "" then subZone = "<empty>" end
    add(("Zone: %q  SubZone: %q"):format(zone, subZone))

    -- Step. activeStep is the routing-entry TABLE (set by ComputeNextStep
    -- from raid.routing). Pull the step index and title off it directly --
    -- no need to re-scan routing[] for the matching entry.
    local step = self.state.activeStep or self:ComputeNextStep()
    if step then
        if step.title then
            add(("Step: %d -- %s"):format(step.step or 0, step.title))
        else
            add(("Step: %d"):format(step.step or 0))
        end
    else
        add("Step: (none -- raid complete?)")
    end

    -- Kill summary.
    local bosses = raid.bosses or {}
    local killed = 0
    for _, b in ipairs(bosses) do
        if self.state.bossesKilled[b.index] then killed = killed + 1 end
    end
    add(("Kills: %d / %d"):format(killed, #bosses))

    -- Per-boss kill marks.
    for _, b in ipairs(bosses) do
        local mark = self.state.bossesKilled[b.index] and "[x]" or "[ ]"
        add(("  %s %d. %s"):format(mark, b.index, b.name))
    end

    RR:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaastatus|r",
        table.concat(lines, "\n"))
    self:Print(("Status window opened.  %s | Kills: %d/%d"):format(
        raid.name, killed, #bosses))
end

-------------------------------------------------------------------------------
-- Yell-debug diagnostic (dev-only; not user-facing)
--
-- One-shot capture tool for designing the v1.2 yell-trigger framework.
-- Encounter scripts often emit chat-channel events (CHAT_MSG_MONSTER_YELL,
-- CHAT_MSG_MONSTER_SAY, CHAT_MSG_RAID_BOSS_EMOTE) at gating moments --
-- e.g. after the player clicks an Eternal Palace orb, an NPC yells a
-- voiceline that's the only reliable signal the gate has been opened.
-- This module captures every such event (across all three channels) into
-- a dedicated buffer for later paste-back, with real-time chat
-- confirmation so the player sees the capture happen the moment the
-- yell fires (one-shot mechanics like the Ashvane orbs only emit their
-- yell once per reset, so silent failure would mean re-clearing the raid).
--
-- Lifecycle: explicitly armed via /rr yelldebug start (zero perf cost
-- otherwise -- events are only registered while armed). Disarmed via
-- /rr yelldebug stop, which dumps to a copy window for paste-back.
-------------------------------------------------------------------------------

local yellDebug = {
    active = false,
    frame  = nil,        -- created lazily on first start
    buffer = nil,        -- session-fresh table, never evicted while active
}

--- Format an event capture as a human-readable multi-line block. All
--- chat-message events deliver up to 13 args (text, playerName, lang,
--- channel, target, flags, ..., guid). We capture every non-nil arg
--- so the postprocess step can pick which fields the framework needs.
---
--- Patch 12.0.0 (Midnight) introduced "secret values" -- chat payloads
--- from inside active boss encounters can be secret-tainted, in which
--- case tainted code (us) cannot perform comparisons (`v ~= ""`) or
--- boolean tests on them without crashing. We use issecretvalue() to
--- skip secret args entirely; they get a "(secret)" placeholder in
--- the dump so the player still sees that something fired but knows
--- the content was protected by the engagement-script taint system.
local function FormatYellCapture(event, ...)
    local lines = {}
    table.insert(lines, ("[%s] %s"):format(date("%H:%M:%S"), tostring(event)))
    local args = { ... }
    for i = 1, select("#", ...) do
        local v = args[i]
        -- Secret-tainted values cannot be compared or boolean-tested
        -- by tainted code (Patch 12.0.0). Check with issecretvalue()
        -- BEFORE any comparison; if secret, render as a placeholder
        -- and skip the empty-string check entirely. The global
        -- `issecretvalue` exists from 12.0.0 onward; guard with a
        -- nil check for back-compat with older client versions
        -- (which don't have secret values, so the v ~= "" path is
        -- still safe there).
        if issecretvalue and issecretvalue(v) then
            table.insert(lines, "  arg" .. i .. " = (secret -- protected by encounter-script taint)")
        elseif v ~= nil and v ~= "" then
            table.insert(lines, "  arg" .. i .. " = " .. tostring(v))
        end
    end
    return table.concat(lines, "\n")
end

--- Brief one-line in-chat confirmation. Critical reliability signal:
--- if this line doesn't appear in chat within ~1s of the orb click,
--- the player knows the capture failed and can stop / restart before
--- continuing the run. Without this, we'd only know at end-of-session
--- via the dump -- by which point the one-shot mechanic is spent.
---
--- Built with concatenation rather than :format() because yell text
--- (especially boss flavor lines and rendered spell names) can contain
--- literal `%` characters that would be misinterpreted as format
--- specifiers and crash. Concatenation with tostring() is bulletproof
--- for arbitrary input.
---
--- Same secret-value handling as FormatYellCapture: if speaker or
--- text is secret-tainted (mid-encounter chat from boss scripts), we
--- substitute a "(secret)" placeholder so the line still surfaces in
--- chat without doing forbidden comparison ops.
local function PrintYellConfirmation(event, text, speaker)
    local ev = tostring(event):gsub("^CHAT_MSG_", "")
    local speakerStr = (issecretvalue and issecretvalue(speaker)) and "(secret)" or tostring(speaker or "?")
    local textStr    = (issecretvalue and issecretvalue(text))    and "(secret)" or tostring(text    or "?")
    RR:Print("|cff00ff88[YellDebug]|r " .. ev
        .. " from |cffffff00" .. speakerStr .. "|r: "
        .. textStr)
end

local function YellEventHandler(_, event, ...)
    if not yellDebug.active then return end
    if not yellDebug.buffer then return end  -- defensive; shouldn't happen
    -- pcall wrap: chat-event payloads include arbitrary text from any
    -- NPC in earshot, including special characters that historically
    -- caused issues with formatters. A crash here would interrupt the
    -- player's run with WoW's error frame, which is especially bad
    -- during one-shot mechanics. Log any failure to ZoneLog for later
    -- diagnosis, then move on. The buffer + chat-confirmation paths
    -- below are the only places that touch arbitrary input; if they
    -- fail, the whole capture for THIS yell is lost but YellDebug
    -- stays armed and ready for the next one.
    local args = { event, ... }
    local ok, err = pcall(function()
        table.insert(yellDebug.buffer, FormatYellCapture(unpack(args)))
        -- arg1 = text, arg2 = sender name across all three CHAT_MSG_MONSTER_*
        -- and CHAT_MSG_RAID_BOSS_EMOTE events (consistent API surface).
        local text   = args[2]
        local sender = args[3]
        PrintYellConfirmation(event, text, sender)
    end)
    if not ok then
        RR:ZoneLog("[YellDebug] handler crash: " .. tostring(err))
    end
end

function RR:YellDebugStart()
    if yellDebug.active then
        self:Print("|cff00ff88[YellDebug]|r already armed. /rr yelldebug stop to disarm.")
        return
    end
    if not yellDebug.frame then
        yellDebug.frame = CreateFrame("Frame")
        yellDebug.frame:SetScript("OnEvent", YellEventHandler)
    end
    yellDebug.buffer = {}
    yellDebug.frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    yellDebug.frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    yellDebug.frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    yellDebug.active = true
    self:Print("|cff00ff88[YellDebug]|r ARMED. Capturing MONSTER_YELL, MONSTER_SAY, RAID_BOSS_EMOTE.")
    self:Print("|cff00ff88[YellDebug]|r Each capture will print a confirmation line below. /rr yelldebug stop to dump.")
end

function RR:YellDebugStop()
    if not yellDebug.active then
        self:Print("|cff00ff88[YellDebug]|r not armed. /rr yelldebug start to begin capture.")
        return
    end
    yellDebug.frame:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
    yellDebug.frame:UnregisterEvent("CHAT_MSG_MONSTER_SAY")
    yellDebug.frame:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    yellDebug.active = false
    local count = #yellDebug.buffer
    self:Print(("|cff00ff88[YellDebug]|r DISARMED. Captured %d event(s). Opening dump window..."):format(count))
    local dump
    if count == 0 then
        dump = "(no events captured during this session)"
    else
        dump = table.concat(yellDebug.buffer, "\n\n")
    end
    self:ShowCopyWindow("RetroRuns -- YellDebug capture", dump)
    yellDebug.buffer = nil  -- free memory; new buffer on next start
end

-- Read-only accessor for DevTools. The yellDebug table is file-local
-- so external modules can't read .active directly.
function RR:IsYellDebugActive()
    return yellDebug.active == true
end

-------------------------------------------------------------------------------
-- VerifyOneRaid: run the tmogverify pipeline (E1-E7 + special-loot checks +
-- async EJ-driven coverage pass) on a single raid table. Async because the
-- coverage pass requires driving the EJ at each difficulty per boss.
--
-- Parameters:
--   raid    : a raid entry from RetroRuns_Data (must have .bosses, .journalInstanceID)
--   opts    : {
--       verbose = bool,  -- emit per-boss + per-item [OK]/[ERR] rows (default true)
--       banner  = bool,  -- emit "warming..." / "starting coverage..." Print() lines
--                          to chat (default true; turn off in batch mode to keep
--                          chat quiet during /rr tmogverifyall)
--   }
--   onDone  : function(lines, T) callback. lines is the accumulated output
--             text (array of strings ready for table.concat). T is the counter
--             table tallying findings.
--
-- Extracted from the /rr tmogverify dispatcher branch in v1.10.0 so the same
-- pipeline can be reused by /rr tmogverifyall without code duplication. See
-- the tmogverify docblock above the dispatcher for the per-check semantics.
-------------------------------------------------------------------------------
function RR:VerifyOneRaid(raid, opts, onDone)
    opts = opts or {}
    local verbose = opts.verbose
    if verbose == nil then verbose = true end
    if not raid or not raid.bosses then
        if onDone then onDone({}, {}) end
        return
    end

    -- Cache-warm pass, same rationale as tmogaudit: GetSourceInfo
    -- and friends depend on item data being loaded. Walking the
    -- whole raid cold can under-report.
    for _, boss in ipairs(raid.bosses) do
        if boss.loot then
            for _, it in ipairs(boss.loot) do
                if it.id then GetItemInfo(it.id) end
            end
        end
        if boss.specialLoot then
            for _, it in ipairs(boss.specialLoot) do
                if it.id then GetItemInfo(it.id) end
            end
        end
    end

    if opts and opts.banner then RR:Print("tmogverify: warming item cache, please wait 1s...") end

    C_Timer.After(1.0, function()
        local lines = {}
        local function add(s) table.insert(lines, s) end

        -- Aggregate counters reported at the end. Each finding
        -- bumps one bucket; a clean item bumps `ok`.
        local T = {
            ok              = 0,   -- item had no findings
            fatal_nil       = 0,   -- source returned nil via every API we tried
            item_mismatch   = 0,   -- E2: sourceID's itemID disagrees with our item.id
            coverage_gap    = 0,   -- E6: EJ exposes more sourceIDs for this item-at-this-diff than we shipped
            missing_item    = 0,   -- E7: EJ exposes an item at this boss that's not in our data
            -- E4: source-duplication shape classification (descriptive,
            -- not error-severity -- binary and perdiff are both fine).
            shape_binary    = 0,   -- 1 unique source cloned across 2+ buckets (single-variant item)
            shape_perdiff   = 0,   -- N unique sources in N buckets (per-difficulty item)
            shape_partial   = 0,   -- 2-3 unique sources in 4 buckets (WRN: half-harvested?)
            shape_outlier   = 0,   -- E3 visualID: 3+1 pattern (one bucket odd one out)
            shape_mixed     = 0,   -- E3 visualID: 2+2 / 2+1+1 mixed
            no_visual       = 0,   -- E3: could not resolve visualID at all
            special_kind_mismatch = 0, -- S2
            special_item_unknown  = 0, -- S1
        }
        local DIFFS = { 17, 14, 15, 16 }
        local DIFF_NAME = { [17]="LFR", [14]="N", [15]="H", [16]="M" }

        if verbose then add(("tmogverify: raid=%s"):format(tostring(raid.name or "?"))) end
        if verbose then add("Data-integrity check: every sourceID in the data file is") end
        if verbose then add("validated against the live Blizzard API.") end
        add("")
        if verbose then add("Severity tags:") end
        if verbose then add("  [ERR] definite data bug -- fix before next release") end
        if verbose then add("  [WRN] suspicious, may be legit -- manual review") end
        if verbose then add("  [--] informational (shape/structure notes)") end
        add("")

        for _, boss in ipairs(raid.bosses) do
            if verbose then
                add(("=== Boss %d: %s ==="):format(
                boss.index or 0, boss.name or "?"))
            end

            -- Regular loot
            if boss.loot and #boss.loot > 0 then
                -- Sort alphabetically so the dump is stable across
                -- runs (matches tmogaudit's ordering).
                local sorted = {}
                for _, it in ipairs(boss.loot) do
                    table.insert(sorted, it)
                end
                table.sort(sorted, function(a, b)
                    return (a.name or "") < (b.name or "")
                end)

                for _, item in ipairs(sorted) do
                    local findings = {}

                    -- Walk each difficulty bucket. Collect the
                    -- sourceID, the API's reported itemID, and the
                    -- resolved visualID for each. Fan out into per-
                    -- bucket checks first; shape/dedup checks happen
                    -- once we have all 4.
                    local perBucket = {}  -- [diffID] = {src, apiItemID, visualID, apiNil}
                    for _, diffID in ipairs(DIFFS) do
                        local src = item.sources and item.sources[diffID]
                        if src then
                            local info = C_TransmogCollection.GetSourceInfo(src)
                            local apiItemID, visualID, apiNil
                            if info then
                                apiItemID = info.itemID
                            end
                            -- Resolve visualID via the proven
                            -- GetAppearanceInfoBySource path (the
                            -- struct field on GetSourceInfo is
                            -- unreliable on retail -- UI.lua notes
                            -- this in detail).
                            if C_TransmogCollection.GetAppearanceInfoBySource then
                                local ai = C_TransmogCollection.GetAppearanceInfoBySource(src)
                                if ai then visualID = ai.appearanceID end
                            end
                            -- Fallback: GetAppearanceSourceInfo
                            -- positional (2nd return = visualID).
                            -- Useful for cross-class tier where
                            -- GetAppearanceInfoBySource sometimes
                            -- returns nil but the positional API
                            -- still resolves.
                            if not visualID and C_TransmogCollection.GetAppearanceSourceInfo then
                                local _, v = C_TransmogCollection.GetAppearanceSourceInfo(src)
                                visualID = v
                            end
                            apiNil = (not info) and (not visualID)
                            perBucket[diffID] = {
                                src = src, apiItemID = apiItemID,
                                visualID = visualID, apiNil = apiNil,
                            }
                        end
                    end

                    -- [E1] Fatal-nil per bucket.
                    for _, diffID in ipairs(DIFFS) do
                        local b = perBucket[diffID]
                        if b and b.apiNil then
                            table.insert(findings, ("[ERR] %s src=%d: API returned nil (invalid sourceID?)"):format(
                                DIFF_NAME[diffID], b.src))
                            T.fatal_nil = T.fatal_nil + 1
                        end
                    end

                    -- [E2] itemID mismatch per bucket.
                    -- apiItemID==nil while visualID is non-nil is
                    -- tolerable (GetSourceInfo can be nil for cross-
                    -- class items while the positional API still
                    -- works). Only flag when we got an apiItemID
                    -- and it's wrong.
                    for _, diffID in ipairs(DIFFS) do
                        local b = perBucket[diffID]
                        if b and b.apiItemID and b.apiItemID ~= item.id then
                            table.insert(findings, ("[ERR] %s src=%d: API itemID=%d, expected %d"):format(
                                DIFF_NAME[diffID], b.src, b.apiItemID, item.id))
                            T.item_mismatch = T.item_mismatch + 1
                        end
                    end

                    -- [E4] Source-duplication shape analysis.
                    --
                    -- Duplicate sourceIDs across difficulty buckets
                    -- are NOT automatically a bug -- they're the
                    -- established encoding for single-variant items
                    -- (binary shape in UI.lua terms). UI.lua's
                    -- BuildDotRow detects 1-unique-source items via
                    -- CountUniqueSources and renders them as a single
                    -- bracketed `[ check ]` indicator rather than a
                    -- 4-dot strip. So an item with `{L=X, N=X, H=X,
                    -- M=X}` is intentional, not broken.
                    --
                    -- The real red flag is PARTIAL duplication:
                    -- 2 or 3 unique sources across 4 buckets. That
                    -- pattern suggests a harvest that half-resolved
                    -- (known example: Rae'shalare,
                    -- {L=new, N=old, H=old, M=old}, because ATT
                    -- stores it as bonusID variants that our batch
                    -- rewrite didn't handle). Flag as WRN for manual
                    -- review; most cases will be legit documented
                    -- exceptions but new occurrences deserve a look.
                    local srcCounts = {}  -- src -> count
                    local uniqueCount = 0
                    local totalBuckets = 0
                    for _, diffID in ipairs(DIFFS) do
                        local b = perBucket[diffID]
                        if b then
                            totalBuckets = totalBuckets + 1
                            if not srcCounts[b.src] then
                                srcCounts[b.src] = 0
                                uniqueCount = uniqueCount + 1
                            end
                            srcCounts[b.src] = srcCounts[b.src] + 1
                        end
                    end

                    local shapeTag
                    if totalBuckets == 0 then
                        -- No sources at all. Handled by E1 already.
                        shapeTag = "empty"
                    elseif uniqueCount == 1 and totalBuckets >= 2 then
                        -- Binary shape: one source cloned across
                        -- buckets. Intentional; the UI renders this
                        -- as a single bracketed indicator.
                        shapeTag = "binary"
                        T.shape_binary = (T.shape_binary or 0) + 1
                    elseif uniqueCount == totalBuckets and totalBuckets >= 2 then
                        -- Full per-difficulty shape.
                        shapeTag = "perdiff"
                        T.shape_perdiff = (T.shape_perdiff or 0) + 1
                    else
                        -- Partial: 2 or 3 unique sources. Suspicious.
                        shapeTag = "partial"
                        T.shape_partial = (T.shape_partial or 0) + 1
                        -- Build a compact description of which
                        -- buckets share which source.
                        local clusters = {}  -- src -> list of diff names
                        for _, diffID in ipairs(DIFFS) do
                            local b = perBucket[diffID]
                            if b then
                                clusters[b.src] = clusters[b.src] or {}
                                table.insert(clusters[b.src], DIFF_NAME[diffID])
                            end
                        end
                        local parts = {}
                        for src, diffs in pairs(clusters) do
                            table.insert(parts, ("src=%d->{%s}"):format(
                                src, table.concat(diffs, ",")))
                        end
                        table.sort(parts)
                        table.insert(findings, ("[WRN] partial source duplication (%d unique across %d buckets): %s"):format(
                            uniqueCount, totalBuckets, table.concat(parts, " ")))
                    end

                    -- [E3] visualID shape analysis.
                    -- Count visualID frequencies across buckets. Use
                    -- only buckets we have data for (all 4 if item
                    -- has full sources; fewer otherwise).
                    local vCounts = {}       -- visualID -> count
                    local vDistinct = 0       -- number of unique visualIDs
                    local vTotal = 0         -- number of buckets with a visualID
                    local vMissing = 0       -- buckets with src but no resolvable visual
                    for _, diffID in ipairs(DIFFS) do
                        local b = perBucket[diffID]
                        if b then
                            if b.visualID then
                                if not vCounts[b.visualID] then
                                    vDistinct = vDistinct + 1
                                    vCounts[b.visualID] = 0
                                end
                                vCounts[b.visualID] = vCounts[b.visualID] + 1
                                vTotal = vTotal + 1
                            else
                                vMissing = vMissing + 1
                            end
                        end
                    end

                    if vMissing > 0 then
                        table.insert(findings, ("[WRN] %d bucket(s) have a sourceID but no resolvable visualID"):format(vMissing))
                        T.no_visual = T.no_visual + vMissing
                    end

                    -- Describe the shape.
                    if vTotal >= 2 then
                        if vDistinct == 1 then
                            -- All buckets share one visualID (Sepulcher-shape). Clean.
                        elseif vDistinct == vTotal then
                            -- All buckets have distinct visualIDs (Sanctum-shape). Clean.
                        else
                            -- Mixed. Figure out the pattern.
                            -- Common suspicious case: 3 match + 1 odd one out.
                            local maxCount = 0
                            local maxVisual
                            for v, c in pairs(vCounts) do
                                if c > maxCount then
                                    maxCount = c
                                    maxVisual = v
                                end
                            end
                            if vTotal == 4 and maxCount == 3 then
                                -- Find the outlier bucket.
                                local outlier
                                for _, diffID in ipairs(DIFFS) do
                                    local b = perBucket[diffID]
                                    if b and b.visualID and b.visualID ~= maxVisual then
                                        outlier = diffID
                                        break
                                    end
                                end
                                table.insert(findings, ("[WRN] shape outlier: 3 buckets visualID=%d, %s bucket differs (visualID=%d)"):format(
                                    maxVisual,
                                    outlier and DIFF_NAME[outlier] or "?",
                                    outlier and perBucket[outlier].visualID or 0))
                                T.shape_outlier = T.shape_outlier + 1
                            else
                                -- Build a compact "visualID=count" summary.
                                local parts = {}
                                for v, c in pairs(vCounts) do
                                    table.insert(parts, ("%d=%dx"):format(v, c))
                                end
                                table.sort(parts)
                                table.insert(findings, ("[WRN] shape mixed (%d unique visualIDs across %d buckets): %s"):format(
                                    vDistinct, vTotal, table.concat(parts, " ")))
                                T.shape_mixed = T.shape_mixed + 1
                            end
                        end
                    end

                    -- Per-item row. Always emit one line so the
                    -- output is greppable by itemID, even for
                    -- clean items.
                    local classTag = ""
                    if item.classes and item.classes[1] then
                        classTag = (" (tier classID=%d)"):format(item.classes[1])
                    end
                    if #findings == 0 then
                        if verbose then
                            add(("  [OK]  %-7d  %s%s"):format(
                            item.id, item.name or "?", classTag))
                        end
                        T.ok = T.ok + 1
                    else
                        add(("        %-7d  %s%s"):format(
                            item.id, item.name or "?", classTag))
                        for _, f in ipairs(findings) do
                            add(("           %s"):format(f))
                        end
                    end
                end
            else
                if verbose then add("  (no regular loot)") end
            end

            -- Special loot
            if boss.specialLoot and #boss.specialLoot > 0 then
                add("")
                if verbose then add("  -- Special Loot --") end
                local sortedSp = {}
                for _, it in ipairs(boss.specialLoot) do
                    table.insert(sortedSp, it)
                end
                table.sort(sortedSp, function(a, b)
                    return (a.name or "") < (b.name or "")
                end)
                for _, sp in ipairs(sortedSp) do
                    local findings = {}
                    -- [S1] itemID resolves?
                    local itemName = sp.id and GetItemInfo(sp.id)
                    if not itemName then
                        table.insert(findings, ("[WRN] GetItemInfo(%d) returned nil (cache cold or invalid itemID?)"):format(sp.id or 0))
                        T.special_item_unknown = T.special_item_unknown + 1
                    end
                    -- [S2] kind-vs-API sanity.
                    if sp.kind == "mount" then
                        local ok = C_MountJournal
                            and C_MountJournal.GetMountFromItem
                            and C_MountJournal.GetMountFromItem(sp.id)
                        if not ok then
                            table.insert(findings, ("[ERR] kind=mount but C_MountJournal.GetMountFromItem(%d) returned nil"):format(sp.id or 0))
                            T.special_kind_mismatch = T.special_kind_mismatch + 1
                        end
                    elseif sp.kind == "pet" then
                        local ok = C_PetJournal
                            and C_PetJournal.GetPetInfoByItemID
                            and C_PetJournal.GetPetInfoByItemID(sp.id)
                        if not ok then
                            table.insert(findings, ("[ERR] kind=pet but C_PetJournal.GetPetInfoByItemID(%d) returned nil"):format(sp.id or 0))
                            T.special_kind_mismatch = T.special_kind_mismatch + 1
                        end
                    elseif sp.kind == "toy" then
                        local ok = C_ToyBox
                            and C_ToyBox.GetToyInfo
                            and C_ToyBox.GetToyInfo(sp.id)
                        if not ok then
                            table.insert(findings, ("[WRN] kind=toy but C_ToyBox.GetToyInfo(%d) returned nil (or cold cache)"):format(sp.id or 0))
                            T.special_kind_mismatch = T.special_kind_mismatch + 1
                        end
                    elseif sp.kind == "illusion" then
                        -- For illusions, item.id is the itemID
                        -- (used by GetItemInfo for name/icon)
                        -- and item.sourceID is the illusion's
                        -- visual source identifier (separate
                        -- ID space). Validate against
                        -- C_TransmogCollection.GetIllusionInfo
                        -- which takes sourceID and returns the
                        -- TransmogIllusionInfo struct (visualID,
                        -- isCollected, sourceID, icon, etc.).
                        --
                        -- Earlier Wowpedia docs referenced a
                        -- GetIllusionSourceInfo function, but
                        -- that doesn't exist on the live 11.x
                        -- client (verified by /api search and
                        -- direct call attempts during v1.7 EN
                        -- bring-up). GetIllusionInfo is the
                        -- canonical name now.
                        if not sp.sourceID then
                            table.insert(findings, "[ERR] kind=illusion missing sourceID field")
                            T.special_kind_mismatch = T.special_kind_mismatch + 1
                        else
                            local info = nil
                            if C_TransmogCollection and C_TransmogCollection.GetIllusionInfo then
                                info = C_TransmogCollection.GetIllusionInfo(sp.sourceID)
                            end
                            if not info then
                                table.insert(findings, ("[ERR] kind=illusion but C_TransmogCollection.GetIllusionInfo(%d) returned nil"):format(sp.sourceID))
                                T.special_kind_mismatch = T.special_kind_mismatch + 1
                            end
                        end
                    end
                    local mythicTag = sp.mythicOnly and " [Mythic only]" or ""
                    if #findings == 0 then
                        if verbose then
                            add(("  [OK]  %-7d  (%s) %s%s"):format(
                            sp.id or 0, sp.kind or "?",
                            sp.name or "?", mythicTag))
                        end
                    else
                        add(("        %-7d  (%s) %s%s"):format(
                            sp.id or 0, sp.kind or "?",
                            sp.name or "?", mythicTag))
                        for _, f in ipairs(findings) do
                            add(("           %s"):format(f))
                        end
                    end
                end
            end
            add("")
        end

        -- ---------------------------------------------------------
        -- Coverage pass (E6 / E7): drive the EJ at each difficulty
        -- per boss, compare the EJ-exposed sourceIDs and items
        -- against what we shipped. Async because each
        -- EJ_SelectEncounter requires a settle wait. See the
        -- E6/E7 entries in the docblock above for full rationale.
        -- ---------------------------------------------------------
        if verbose then
            add("=== Coverage Pass (E6 / E7) ===")
            add("Driving the EJ at every difficulty and comparing exposed")
            add("sourceIDs + items against shipped data. This catches the")
            add("harvester-skip class of bug that E1-E4 cannot see.")
            add("")
        end

        if opts and opts.banner then
            RR:Print(("tmogverify: starting coverage pass (~%ds, %d boss(es))..."):format(
                (#raid.bosses) * 4, #raid.bosses))
        end

        local DIFFS_LIST = { 17, 14, 15, 16 }
        local bossIdx    = 0

        local function FinishSummary()
            add("=== Summary ===")
            add(("Clean items:              %d"):format(T.ok))
            add("")
            add("Shape distribution (informational, not errors):")
            add(("  binary (1 unique src):         %d"):format(T.shape_binary))
            add(("  per-difficulty (N unique):     %d"):format(T.shape_perdiff))
            add(("  partial (2-3 unique, WRN):     %d"):format(T.shape_partial))
            add("")
            add("Findings:")
            add(("  [ERR] API-nil buckets:         %d"):format(T.fatal_nil))
            add(("  [ERR] itemID mismatches:       %d"):format(T.item_mismatch))
            add(("  [ERR] coverage gaps (E6):      %d"):format(T.coverage_gap))
            add(("  [ERR] missing items (E7):      %d"):format(T.missing_item))
            add(("  [ERR] special kind mismatches: %d"):format(T.special_kind_mismatch))
            add(("  [WRN] shape outliers (3+1):    %d"):format(T.shape_outlier))
            add(("  [WRN] shape mixed (2+2/2+1+1): %d"):format(T.shape_mixed))
            add(("  [WRN] buckets w/o visualID:    %d"):format(T.no_visual))
            add(("  [WRN] special item unknown:    %d"):format(T.special_item_unknown))
            add("")
            add("Interpretation:")
            add("  ERR = actionable data bug. Investigate each row and")
            add("        correct the data file.")
            add("  WRN = may be legit (e.g. class-restricted visibility")
            add("        for cross-class tier; cold cache for toys;")
            add("        documented bonusID items like Rae'shalare /")
            add("        Edge of Night for Sanctum). Run /rr tmogverify")
            add("        again after warming by opening the tmog browser")
            add("        once; remaining WRNs need a look.")
            add("  E6 / E7 require driving the EJ at each difficulty;")
            add("        E6 catches items where EJ exposes sourceIDs we")
            add("        didn't ship (harvester missed sources). E7")
            add("        catches items present in EJ loot but absent")
            add("        from our data.")
            add("  Binary-shape items are rendered by the UI as a single")
            add("  bracketed indicator (not a 4-dot strip); the cloned-")
            add("  across-buckets encoding in the data file is the")
            add("  established convention for single-variant items.")

            RetroRunsDebug = RetroRunsDebug or {}
            RetroRunsDebug.tmogverify = table.concat(lines, "\n")

            -- Driver mode: caller passed an onDone callback (e.g.
            -- tmogverifyall). Hand results off via callback and let
            -- the caller own presentation. Otherwise (single-raid
            -- /rr tmogverify), open the copy window ourselves.
            if onDone then
                onDone(lines, T)
            else
                RR:ShowCopyWindow(
                    ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: tmogverify|r"),
                    table.concat(lines, "\n"))
                RR:Print("tmogverify complete. Copy window opened.")
            end
        end

        local function ProcessNextBoss()
            bossIdx = bossIdx + 1
            if bossIdx > #raid.bosses then
                FinishSummary()
                return
            end

            local boss = raid.bosses[bossIdx]
            local journalID = boss.journalEncounterID
            if not journalID or not boss.loot or #boss.loot == 0 then
                -- Nothing to coverage-check.
                if opts and opts.progress then
                    RR:Print(("    boss %d/%d %s: skipped (no loot)"):format(
                        bossIdx, #raid.bosses, boss.name or "?"))
                end
                C_Timer.After(0, ProcessNextBoss)
                return
            end

            if opts and opts.progress then
                RR:Print(("    boss %d/%d %s..."):format(
                    bossIdx, #raid.bosses, boss.name or "?"))
            end

            -- Build lookup: shipped sourceIDs per (itemID, diffID).
            -- (itemID, diffID) -> shipped sourceID.
            local shippedByKey = {}
            -- itemID -> our row reference (for name lookup, e7 detection).
            local shippedByItem = {}
            for _, it in ipairs(boss.loot) do
                shippedByItem[it.id] = it
                if it.sources then
                    for _, d in ipairs(DIFFS_LIST) do
                        local src = it.sources[d]
                        if src then
                            shippedByKey[it.id .. ":" .. d] = src
                        end
                    end
                end
            end

            -- EJ-exposed data: (itemID, diffID) -> srcID, and a set
            -- of all itemIDs seen across all difficulties.
            local ejByKey   = {}
            local ejByItem  = {}

            local diffIdx = 0
            local function NextDiff()
                diffIdx = diffIdx + 1
                if diffIdx > #DIFFS_LIST then
                    -- Done with this boss's 4 passes. Compare and
                    -- accumulate E6 / E7 findings.
                    local bossHeader = ("--- E6/E7 for Boss %d: %s ---"):format(
                        boss.index or 0, boss.name or "?")
                    local bossFindings = {}

                    -- E6: for each item/diff we shipped, did EJ
                    -- expose a different sourceID? (Mismatch = our
                    -- sourceID is wrong.) AND: for each item/diff
                    -- EJ exposes a sourceID for, did we ship one?
                    -- (Missing per-diff bucket = harvester gap.)
                    for _, it in ipairs(boss.loot) do
                        for _, d in ipairs(DIFFS_LIST) do
                            local key      = it.id .. ":" .. d
                            local shipped  = shippedByKey[key]
                            local ejSrc    = ejByKey[key]
                            if ejSrc and not shipped then
                                table.insert(bossFindings, ("[ERR] E6 %d %s %s: EJ exposes src=%d but our [%d] bucket is empty"):format(
                                    it.id, DIFF_NAME[d] or tostring(d), it.name or "?", ejSrc, d))
                                T.coverage_gap = T.coverage_gap + 1
                            elseif ejSrc and shipped and ejSrc ~= shipped then
                                table.insert(bossFindings, ("[ERR] E6 %d %s %s: EJ exposes src=%d, we shipped src=%d"):format(
                                    it.id, DIFF_NAME[d] or tostring(d), it.name or "?", ejSrc, shipped))
                                T.coverage_gap = T.coverage_gap + 1
                            end
                        end
                    end

                    -- E7: items EJ exposes for this boss at any
                    -- difficulty that aren't in our data at all.
                    for itemID, _ in pairs(ejByItem) do
                        if not shippedByItem[itemID] then
                            local name = GetItemInfo(itemID) or "?"
                            table.insert(bossFindings, ("[ERR] E7 %d %s: EJ exposes this item, not in our data"):format(
                                itemID, name))
                            T.missing_item = T.missing_item + 1
                        end
                    end

                    if #bossFindings > 0 then
                        add(bossHeader)
                        for _, f in ipairs(bossFindings) do
                            add("  " .. f)
                        end
                        add("")
                    end

                    C_Timer.After(0, ProcessNextBoss)
                    return
                end

                local diffID = DIFFS_LIST[diffIdx]
                EJ_SetDifficulty(diffID)
                EJ_SelectInstance(raid.journalInstanceID or 0)
                EJ_ResetLootFilter()
                C_Timer.After(0.2, function()
                    pcall(EJ_SelectEncounter, journalID)
                    if C_EncounterJournal and C_EncounterJournal.ResetSlotFilter then
                        C_EncounterJournal.ResetSlotFilter()
                    end
                    EJ_SetDifficulty(diffID)

                    RR:WaitForEJLootSettled(1000, 10000, function(numLoot)
                        for i = 1, numLoot do
                            local info = C_EncounterJournal.GetLootInfoByIndex(i)
                            if info and info.itemID and info.encounterID == journalID then
                                -- Filter to transmog-eligible items.
                                -- C_TransmogCollection.GetItemInfo(itemID)
                                -- returns nil for quest items, relics,
                                -- crafting materials, etc. -- we'd
                                -- false-positive E7 on every quest item
                                -- the EJ exposes if we didn't filter.
                                local hasAppearance = false
                                if info.itemID then
                                    local apID = C_TransmogCollection.GetItemInfo(info.itemID)
                                    hasAppearance = (apID ~= nil)
                                end

                                if hasAppearance then
                                    ejByItem[info.itemID] = true

                                    -- Resolve per-difficulty sourceID
                                    -- via the link form (carries the
                                    -- itemContext bonus needed for the
                                    -- right per-difficulty variant).
                                    -- Some EJ rows have nil .link --
                                    -- guard before calling.
                                    if info.link then
                                        local _, srcID = C_TransmogCollection.GetItemInfo(info.link)
                                        if srcID then
                                            ejByKey[info.itemID .. ":" .. diffID] = srcID
                                        end
                                    end
                                end
                            end
                        end
                        C_Timer.After(0.2, NextDiff)
                    end)
                end)
            end

            NextDiff()
        end

        ProcessNextBoss()
    end) -- C_Timer.After callback closer
end




-------------------------------------------------------------------------------
-- Slash commands
-------------------------------------------------------------------------------

SLASH_RETRORUNS1 = "/retroruns"
SLASH_RETRORUNS2 = "/rr"

SlashCmdList["RETRORUNS"] = function(input)
    local msg  = RR.Trim(input):lower()
    local args = {}
    for word in msg:gmatch("%S+") do table.insert(args, word) end
    local cmd  = args[1] or ""
    local rest = RR.Trim(msg:sub(#cmd + 1))

    if cmd == "" or cmd == "toggle" then
        local newShown = not RR:GetSetting("showPanel")
        RR:SetSetting("showPanel", newShown)
        if newShown then
            if RR.currentRaid and not RR.state.loadedRaidKey then
                RR.state.loadedRaidKey = RR:GetRaidContextKey()
            end
            RR:RefreshAll()
        elseif RetroRunsUI then
            RetroRunsUI:Hide()
        end

    elseif cmd == "show" then
        RR:SetSetting("showPanel", true)
        if RR.currentRaid then
            RR.state.loadedRaidKey = RR:GetRaidContextKey()
        end
        RR:RefreshAll()

    elseif cmd == "hide" then
        RR:SetSetting("showPanel", false)
        if RetroRunsUI then RetroRunsUI:Hide() end

    elseif cmd == "settings" then
        RR.UI.ToggleSettings()

    elseif cmd == "sessionlog" then
        -- Open the recorder session log copy window. Defaults to
        -- showing entries for the current raid only (so debugging an
        -- issue in one raid isn't cluttered by entries from a prior
        -- run in a different raid). Pass `all` to see every entry
        -- across raids.
        local showAll = (args[2] == "all")
        RR:ShowRecorderSessionLog(showAll)

    elseif cmd == "lintroute" then
        -- On-demand structural lint of all loaded raid data. Reports
        -- errors (malformed required fields, broken cross-refs) and
        -- warnings (unverified maps[] entries, segment subZones not
        -- present in maps[], consecutive-duplicate mapIDs). Optional
        -- second arg filters to raids whose name contains that
        -- substring, e.g. `/rr lintroute Aberrus`.
        local scope = args[2]
        RR:LintRoute(scope)

    elseif cmd == "diag" then
        -- Consolidated diagnostic dump: RetroEngine state + zone log +
        -- session log, all in one copy window. Use this when filing
        -- a bug report or comparing state across reloads.
        RR:DiagDump()

    elseif cmd == "mapicons" then
        -- Dev: dump the currently-viewed world map's Blizzard icons
        -- (zone-transition exits + POIs) with their exact normalized
        -- coords. Use when authoring a highlightCircle / POI seg whose
        -- target is a Blizzard map icon -- reads the coord straight
        -- from the API instead of trying to shift-click the icon
        -- (which Blizzard's click handler usually eats first).
        RR:DumpMapIcons()

    elseif cmd == "reset" then
        -- Preserve "transient toggle" state across reset. Reset is about
        -- restoring appearance/positioning settings (font, scale, panel
        -- coords, settings coords) -- it should NOT yank the main panel
        -- closed if the user happens to have it open, and it should not
        -- silently flip debug mode off for a power user who turned it on.
        --
        -- Without this, the reset cascade goes:
        --   showPanel <- false (default)
        --   RefreshAll -> UI.Update -> IsPanelAllowed returns false -> panel:Hide()
        -- ...which is surprising when the user clicks Reset to Default
        -- ON the settings panel: they expect to see the changes apply,
        -- not have the parent panel disappear.
        local preservedShowPanel = RR:GetSetting("showPanel")
        local preservedDebug     = RR:GetSetting("debug")
        -- Bulk reset stays direct: this IS the implementation of the
        -- defaults-restore semantics, not a regular setting access.
        for k, v in pairs(RR.defaults) do RetroRunsDB[k] = v end
        if preservedShowPanel ~= nil then RR:SetSetting("showPanel", preservedShowPanel) end
        if preservedDebug     ~= nil then RR:SetSetting("debug",     preservedDebug)     end
        RR:RestorePanelPosition()
        if RetroRunsSettingsFrame and RetroRunsSettingsFrame.RestorePosition then
            RetroRunsSettingsFrame:RestorePosition()
        end
        RR.UI.ApplySettings()
        RR.UI.SyncSettingsControls()
        RR:RefreshAll()
        RR:Print("Settings reset to defaults.")

    elseif cmd == "refresh" then
        RR.state.testMode = false
        if RR.currentRaid then
            RR.state.loadedRaidKey = RR:GetRaidContextKey()
        end
        RR:RefreshAll()

    elseif cmd == "debug" then
        local newDebug = not RR:GetSetting("debug")
        RR:SetSetting("debug", newDebug)
        RR:Print("Debug " .. (newDebug and "ON" or "OFF"))

    elseif cmd == "test" then
        RR:ResetTestState()
        RR.UI.Update()
        if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
        RR:Print("Test mode ON -- /rr next to advance, /rr real to exit.")

    elseif cmd == "next" then
        RR:SimulateKillNext()

    elseif cmd == "real" then
        RR:DisableTestMode()
        RR:Print("Returned to live raid state.")

    elseif cmd == "resetsegments" then
        -- Clear persisted routing-progress state for the CURRENT raid.
        -- Use when a backtrack or other quirk has left progress advanced
        -- past a seg that shouldn't yet be complete -- the renderer then
        -- surfaces the wrong segment's note. Scoped to the current raid;
        -- other raids' persisted progress is preserved.
        --
        -- Also clears the in-memory zonelog ring buffer. Resetting
        -- progress is almost always done as part of a diagnostic
        -- session, where the next thing the user wants to see is a
        -- clean zonelog showing only the events triggered by the
        -- post-reset walk -- not the stale entries from before the
        -- reset. Wiping the zonelog here removes the manual mental
        -- timestamp-filtering step.
        if not RR.currentRaid then
            RR:Print("No raid loaded. Zone into a supported raid first.")
        else
            RR.state.progress      = {}
            RR.state.triggersFired = {}
            if RetroRunsDB and RetroRunsDB.routingProgress then
                RetroRunsDB.routingProgress[RR.currentRaid.instanceID] = nil
            end
            wipe(RR.state.zoneLog)
            if RR.state.activeStep then
                RR:SeedProgress(RR.state.activeStep)
            end
            RR.UI.Update()
            if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
            RR:Print(("Routing progress cleared for %s. (zonelog also wiped)"):format(RR.currentRaid.name))
        end

    elseif cmd == "kill" then
        if rest == "" then
            RR:Print("Usage: /rr kill <boss name>")
        else
            RR:ManualKill(rest)
        end

    elseif cmd == "unkill" then
        if rest == "" then
            RR:Print("Usage: /rr unkill <boss name>")
        else
            RR:ManualUnkill(rest)
        end

    elseif cmd == "ej" then
        RR:HarvestDiagnose()

    elseif cmd == "raidcapture" then
        RR:RaidCapture()

    elseif cmd == "weaponharvest" then
        RR:HarvestWeaponPools()

    elseif cmd == "vendorscan" then
        RR:ScanMerchantFrame()

    elseif cmd == "tmog" then
        RR.UI.ToggleTransmogBrowser()

    elseif cmd == "skips" then
        -- Open the raid-skip status window. Read-only display of which
        -- raid skips are unlocked on this account, with cascade-aware
        -- per-raid available-difficulty annotations. See
        -- UI.OpenSkipsWindow for the rendering.
        RR.UI.ToggleSkipsWindow()

    elseif cmd == "devtools" then
        RR:ToggleDevTools()

    elseif cmd == "tmogsrc" then
        RR:DebugTransmogSources()

    elseif cmd == "tmogtrace" then
        -- Shows the trace of what BuildDotRow decided for the last-rendered
        -- transmog popup. Requires /rr debug to be ON before opening the
        -- popup. Output goes to the copyable window.
        if not RR:GetSetting("debug") then
            RR:Print("Enable debug first: /rr debug, then open the transmog popup, then try again.")
        elseif not RR._dotTrace or next(RR._dotTrace) == nil then
            RR:Print("No dot-row trace captured. Open the transmog popup (mouseover) with debug on, then try again.")
        else
            local lines = {}
            for _, trace in pairs(RR._dotTrace) do
                table.insert(lines, trace)
                table.insert(lines, "")
            end
            RR:ShowCopyWindow(
                "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: dot-row trace|r",
                table.concat(lines, "\n"))
            RR:Print("Trace window opened.")
        end

    elseif cmd == "tmogtest" then
        -- Probe a single itemID through the full shared-state pipeline.
        -- Output is shown in a copyable window (RR:ShowCopyWindow) AND
        -- stashed at RetroRunsDebug.tmogtest. Chat gets only a one-liner.
        local id = tonumber(rest)
        if not id then
            RR:Print("Usage: /rr tmogtest <itemID>  (e.g. 189776 for Girdle)")
        else
            RetroRunsDebug = RetroRunsDebug or {}
            local lines = {}
            local function add(s) table.insert(lines, s) end

            add(("tmogtest itemID=%d"):format(id))

            local apID, primarySrc = C_TransmogCollection.GetItemInfo(id)
            add(("  GetItemInfo -> appearanceID=%s  primarySourceID=%s"):format(
                tostring(apID), tostring(primarySrc)))

            local probe = {
                itemID         = id,
                appearanceID   = apID,
                primarySourceID = primarySrc,
                timestamp      = time(),
            }

            if primarySrc then
                local hasPrimary = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(primarySrc)
                probe.hasPrimarySource = hasPrimary
                add(("  PlayerHasTransmogItemModifiedAppearance(%d) = %s"):format(
                    primarySrc, tostring(hasPrimary)))
            end

            if apID then
                local all = C_TransmogCollection.GetAllAppearanceSources(apID)
                probe.allAppearanceSourcesRaw = all
                if not all then
                    add("  GetAllAppearanceSources returned nil")
                else
                    local pairsCount, ipairsCount = 0, 0
                    for _ in pairs(all)  do pairsCount  = pairsCount  + 1 end
                    for _ in ipairs(all) do ipairsCount = ipairsCount + 1 end
                    probe.pairsCount  = pairsCount
                    probe.ipairsCount = ipairsCount
                    add(("  GetAllAppearanceSources(%d): pairs=%d ipairs=%d"):format(
                        apID, pairsCount, ipairsCount))

                    probe.sources = {}
                    local anyKnown = false
                    for k, src in pairs(all) do
                        local known  = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(src)
                        local info   = C_TransmogCollection.GetSourceInfo(src)
                        local entry  = {
                            key        = k,
                            sourceID   = src,
                            known      = known,
                            itemID     = info and info.itemID,
                            itemLink   = info and info.itemLink,
                            modID      = info and info.itemModID,
                            category   = info and info.categoryID,
                            sourceType = info and info.sourceType,
                        }
                        table.insert(probe.sources, entry)
                        if known then anyKnown = true end
                        add(("    [%s] src=%d itemID=%s modID=%s known=%s"):format(
                            tostring(k), src,
                            tostring(entry.itemID), tostring(entry.modID),
                            tostring(known)))
                        if entry.itemLink then
                            add(("        link=%s"):format(entry.itemLink))
                        end
                    end
                    probe.anyKnown = anyKnown
                    add(("  => any known = %s"):format(tostring(anyKnown)))
                end
            end

            if primarySrc and C_TransmogCollection.GetAppearanceInfoBySource then
                local info = C_TransmogCollection.GetAppearanceInfoBySource(primarySrc)
                probe.appearanceInfoBySource = info
                if info then
                    local parts = {}
                    for k, v in pairs(info) do
                        parts[#parts+1] = ("%s=%s"):format(k, tostring(v))
                    end
                    table.sort(parts)
                    add("  GetAppearanceInfoBySource: { " .. table.concat(parts, ", ") .. " }")
                else
                    add("  GetAppearanceInfoBySource returned nil")
                end
            end

            RetroRunsDebug = RetroRunsDebug or {}
            RetroRunsDebug.tmogtest = probe
            local body = table.concat(lines, "\n")
            RR:ShowCopyWindow(
                ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: tmogtest %d|r"):format(id),
                body)
            RR:Print(("tmogtest %d complete. Copy window opened."):format(id))
        end

    elseif cmd == "srctest" then
        -- Probe a single sourceID. Companion to tmogtest, which takes an
        -- itemID; this one takes a sourceID (itemModifiedAppearanceID)
        -- directly. Useful for diagnosing per-difficulty tier rows where
        -- we need to know what appearanceID a specific difficulty variant
        -- resolves to, and whether its appearance's source graph includes
        -- any sources the player has learned.
        --
        -- Tries THREE different appearance-resolution APIs per sourceID
        -- because they have different behaviors wrt uncollected sources:
        --   GetSourceInfo -> itemAppearanceID  (struct field -- observed
        --       to return nil for this field even on collected sources
        --       in 11.0.x; avoid)
        --   GetAppearanceInfoBySource -> .appearanceID  (struct field --
        --       works for collected sources at least; unclear for
        --       uncollected)
        --   GetAppearanceSourceInfo -> visualID  (2nd positional return
        --       -- documented to work across class boundaries, our best
        --       candidate for uncollected variants)
        local src = tonumber(rest)
        if not src then
            RR:Print("Usage: /rr srctest <sourceID>  (e.g. 166189 for Amice of the Empyrean Normal)")
        else
            local lines = {}
            local function add(s) table.insert(lines, s) end
            add(("srctest sourceID=%d"):format(src))

            local info = C_TransmogCollection.GetSourceInfo(src)
            if not info then
                add("  GetSourceInfo returned nil (source may be invalid, or")
                add("  restricted for this character class)")
            else
                add(("  GetSourceInfo: itemID=%s itemAppearanceID=%s modID=%s"):format(
                    tostring(info.itemID), tostring(info.itemAppearanceID),
                    tostring(info.itemModID)))
                if info.itemLink then
                    add(("    link=%s"):format(info.itemLink))
                end
            end

            -- Alternative #1: GetAppearanceInfoBySource
            if C_TransmogCollection.GetAppearanceInfoBySource then
                local ainfo = C_TransmogCollection.GetAppearanceInfoBySource(src)
                if ainfo then
                    add(("  GetAppearanceInfoBySource: appearanceID=%s sourceIsCollected=%s appearanceIsCollected=%s"):format(
                        tostring(ainfo.appearanceID),
                        tostring(ainfo.sourceIsCollected),
                        tostring(ainfo.appearanceIsCollected)))
                else
                    add("  GetAppearanceInfoBySource returned nil")
                end
            end

            -- Alternative #2: GetAppearanceSourceInfo (positional returns)
            if C_TransmogCollection.GetAppearanceSourceInfo then
                local categoryID, visualID, canEnchant, icon, isCollected =
                    C_TransmogCollection.GetAppearanceSourceInfo(src)
                add(("  GetAppearanceSourceInfo: visualID=%s categoryID=%s isCollected=%s"):format(
                    tostring(visualID), tostring(categoryID), tostring(isCollected)))
            end

            -- Pick the first non-nil appearanceID we found and show its
            -- shared-source graph -- this is what our render-path check
            -- would see.
            local apID =
                (info and info.itemAppearanceID)
                or (C_TransmogCollection.GetAppearanceInfoBySource
                    and (C_TransmogCollection.GetAppearanceInfoBySource(src) or {}).appearanceID)
                or (C_TransmogCollection.GetAppearanceSourceInfo
                    and select(2, C_TransmogCollection.GetAppearanceSourceInfo(src)))

            if apID then
                add(("  -- Resolved appearanceID = %d --"):format(apID))
                local all = C_TransmogCollection.GetAllAppearanceSources(apID)
                if not all then
                    add(("  GetAllAppearanceSources(%d) returned nil"):format(apID))
                else
                    local count = 0
                    for _ in pairs(all) do count = count + 1 end
                    add(("  GetAllAppearanceSources(%d): %d sources"):format(apID, count))
                    for k, sid in pairs(all) do
                        local sinfo = C_TransmogCollection.GetSourceInfo(sid)
                        local known = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sid)
                        add(("    [%s] src=%d itemID=%s modID=%s known=%s"):format(
                            tostring(k), sid,
                            tostring(sinfo and sinfo.itemID),
                            tostring(sinfo and sinfo.itemModID),
                            tostring(known)))
                    end
                end
            else
                add("  -- Could not resolve an appearanceID via any API --")
            end

            local hasDirect = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(src)
            add(("  PlayerHasTransmogItemModifiedAppearance(%d) = %s"):format(
                src, tostring(hasDirect)))

            RR:ShowCopyWindow(
                ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: srctest %d|r"):format(src),
                table.concat(lines, "\n"))
            RR:Print(("srctest %d complete. Copy window opened."):format(src))
        end

    elseif cmd == "ejprobe" then
        -- Dump everything EJ knows about the currently-selected encounter's
        -- loot. Used for "why doesn't /rr harvest see this item?" diagnosis.
        -- Optional needle itemID highlights a specific item and probes
        -- additional EJ paths if the iteration didn't find it.
        RR:EjProbe(args[2])

    elseif cmd == "tierprobe" then
        -- Dump what C_TransmogSets returns for a given tier itemID.
        -- Read-only diagnostic. Used for "why is the harvester writing
        -- the wrong sourceIDs in this tier row?" diagnosis.
        RR:TierProbe(args[2])

    elseif cmd == "specialtest" then
        -- Probe a single itemID against every special-loot detection API
        -- (mount / pet / toy / decor). Diagnoses the Mythic-sweep path:
        -- if the harvester fails to detect 190768 (Jailer's mount), run
        -- /rr specialtest 190768 to see which APIs respond on this client.
        local id = tonumber(args[2])
        if not id then
            RR:Print("Usage: /rr specialtest <itemID>  (e.g. 190768 for Zereth Overseer Cypher)")
        else
            local lines = {}
            local function add(s) table.insert(lines, s) end

            add(("specialtest itemID=%d"):format(id))

            -- GetItemInfo snapshot (name + equipLoc). The equipLoc is
            -- key -- an item with non-empty equipLoc won't hit the
            -- specialLoot detection branch in CollectEncounterLoot.
            local name, link, _, _, _, _, _, _, equipLoc = GetItemInfo(id)
            add(("GetItemInfo: name=%s equipLoc=%q link=%s"):format(
                tostring(name), tostring(equipLoc or ""), tostring(link)))

            -- Mount
            if C_MountJournal then
                if C_MountJournal.GetMountFromItem then
                    local mountID = C_MountJournal.GetMountFromItem(id)
                    add(("C_MountJournal.GetMountFromItem: %s"):format(tostring(mountID)))
                    if mountID and C_MountJournal.GetMountInfoByID then
                        local _, _, _, _, _, _, _, _, _, _, isCollected =
                            C_MountJournal.GetMountInfoByID(mountID)
                        add(("  GetMountInfoByID: isCollected=%s"):format(tostring(isCollected)))
                    end
                else
                    add("C_MountJournal.GetMountFromItem: (function missing)")
                end
            else
                add("C_MountJournal: (table missing)")
            end

            -- Pet
            if C_PetJournal and C_PetJournal.GetPetInfoByItemID then
                local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(id))
                add(("C_PetJournal.GetPetInfoByItemID: speciesID=%s"):format(tostring(speciesID)))
                if speciesID and C_PetJournal.GetNumCollectedInfo then
                    -- Capture all return values (docs say numCollected, limit
                    -- but we accept any shape to surface what the API really
                    -- returns on this client).
                    local r1, r2, r3 = C_PetJournal.GetNumCollectedInfo(speciesID)
                    add(("  GetNumCollectedInfo(%d): r1=%s r2=%s r3=%s"):format(
                        speciesID, tostring(r1), tostring(r2), tostring(r3)))
                end
            else
                add("C_PetJournal.GetPetInfoByItemID: (function missing)")
            end

            -- Toy
            if C_ToyBox and C_ToyBox.GetToyInfo then
                local toyItemID = C_ToyBox.GetToyInfo(id)
                add(("C_ToyBox.GetToyInfo: toyItemID=%s"):format(tostring(toyItemID)))
            else
                add("C_ToyBox.GetToyInfo: (function missing)")
            end
            if PlayerHasToy then
                add(("PlayerHasToy: %s"):format(tostring(PlayerHasToy(id))))
            end

            -- Decor
            if C_HousingCatalog then
                if C_HousingCatalog.GetCatalogEntryInfoByItem then
                    local ok, entry = pcall(
                        C_HousingCatalog.GetCatalogEntryInfoByItem, id)
                    if ok then
                        add(("C_HousingCatalog.GetCatalogEntryInfoByItem: entry=%s (type %s)"):format(
                            tostring(entry), type(entry)))
                        if type(entry) == "table" then
                            for k, v in pairs(entry) do
                                add(("    .%s = %s"):format(tostring(k), tostring(v)))
                            end
                        end
                    else
                        add("C_HousingCatalog.GetCatalogEntryInfoByItem: pcall failed")
                    end
                else
                    add("C_HousingCatalog.GetCatalogEntryInfoByItem: (function missing)")
                end
            else
                add("C_HousingCatalog: (table missing -- expected on pre-11.2.7 clients)")
            end

            RetroRunsDebug = RetroRunsDebug or {}
            RetroRunsDebug.specialtest = table.concat(lines, "\n")

            RR:ShowCopyWindow(
                ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: specialtest %d|r"):format(id),
                table.concat(lines, "\n"))
            RR:Print(("specialtest %d complete. Copy window opened."):format(id))
        end

    elseif cmd == "dottest" then
        -- Per-dot rendering diagnostic.
        --
        -- For a given itemID, walks the 4 difficulty buckets and for each
        -- one reports: the sourceID, whether HasSource is true, the
        -- appearanceID resolved from the sourceID, whether any source
        -- under that appearance is known, and the final state label
        -- (collected / shared / missing) that drives the dot color.
        --
        -- This tells you authoritatively why a given dot rendered green,
        -- gold, or gray. Use when a dot's color doesn't match intuition
        -- (e.g. "I've never done Fatescribe on LFR, why is the LFR dot
        -- highlighted?" -- answer is usually: another Sanctum item at
        -- the same difficulty shares the same appearance, and you have
        -- THAT source collected).
        --
        -- Usage: /rr dottest <itemID>
        local id = tonumber(rest)
        if not id then
            RR:Print("Usage: /rr dottest <itemID>  (e.g. /rr dottest 186340 for Conjunction-Forged Chainmail)")
        else
            -- Look up the item in the currently-loaded raid data file
            -- so we can use our real sourceID mapping (not a fresh API
            -- probe). This mirrors exactly what the UI would use at
            -- render time -- the point is to debug the render, not the
            -- data layer.
            local raid = RR.currentRaid
            local itemRow
            if raid and raid.bosses then
                for _, b in ipairs(raid.bosses) do
                    if b.loot then
                        for _, it in ipairs(b.loot) do
                            if it.id == id then itemRow = it; break end
                        end
                    end
                    if itemRow then break end
                end
            end
            local lines = {}
            local function add(s) table.insert(lines, s) end
            add(("dottest itemID=%d"):format(id))
            if not itemRow then
                add("  (item not found in currently-loaded raid data)")
                add("  Zone into a supported raid first, then rerun.")
                RR:ShowCopyWindow(
                    ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: dottest %d|r"):format(id),
                    table.concat(lines, "\n"))
                return
            end
            add(("  name: %s"):format(itemRow.name or "?"))
            add(("  sources: %s"):format(
                itemRow.sources and "yes" or "MISSING"))
            if not itemRow.sources then
                RR:ShowCopyWindow(
                    ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: dottest %d|r"):format(id),
                    table.concat(lines, "\n"))
                return
            end
            local DIFFS = { {17,"LFR"}, {14,"Normal"}, {15,"Heroic"}, {16,"Mythic"} }
            for _, d in ipairs(DIFFS) do
                local diffID, diffName = d[1], d[2]
                local srcID = itemRow.sources[diffID]
                if not srcID then
                    add(("  [%s %d]: (no source in data)"):format(diffName, diffID))
                else
                    local hasSrc = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(srcID)
                    local info   = C_TransmogCollection.GetSourceInfo(srcID)
                    local apID   = info and (info.appearanceID or info.itemAppearanceID)
                    if not apID and C_TransmogCollection.GetAppearanceInfoBySource then
                        local ai = C_TransmogCollection.GetAppearanceInfoBySource(srcID)
                        apID = ai and ai.appearanceID
                    end
                    local anyKnown = false
                    local siblingCount = 0
                    local knownSiblings = {}
                    if apID then
                        local sibs = C_TransmogCollection.GetAllAppearanceSources(apID)
                        if sibs then
                            for _, sibID in pairs(sibs) do
                                siblingCount = siblingCount + 1
                                if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sibID) then
                                    anyKnown = true
                                    local sibInfo = C_TransmogCollection.GetSourceInfo(sibID)
                                    table.insert(knownSiblings,
                                        ("%d (itemID=%s)"):format(sibID,
                                            tostring(sibInfo and sibInfo.itemID)))
                                end
                            end
                        end
                    end
                    local state
                    if hasSrc then
                        state = "collected"
                    elseif anyKnown then
                        state = "SHARED"
                    else
                        state = "missing"
                    end
                    add(("  [%s %d]: src=%d  hasSrc=%s  apID=%s  anyKnown=%s  -> %s"):format(
                        diffName, diffID, srcID,
                        tostring(hasSrc), tostring(apID), tostring(anyKnown),
                        state))
                    add(("    siblings under apID %s: %d total"):format(
                        tostring(apID), siblingCount))
                    if #knownSiblings > 0 then
                        for _, ks in ipairs(knownSiblings) do
                            add(("      known sibling: src=%s"):format(ks))
                        end
                    end
                end
            end
            RetroRunsDebug = RetroRunsDebug or {}
            RetroRunsDebug.dottest = table.concat(lines, "\n")
            RR:ShowCopyWindow(
                ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: dottest %d|r"):format(id),
                table.concat(lines, "\n"))
            RR:Print(("dottest %d complete."):format(id))
        end

    elseif cmd == "tmogaudit" then
        -- Full-raid transmog audit.
        --
        -- Walks every loot item + specialLoot entry in the currently-loaded
        -- raid. For each regular loot item, emits a 4-column row showing
        -- per-difficulty state (collected / shared / missing) and the
        -- sourceID that drove the decision. For each special-loot item,
        -- emits a single-state row (collected / missing) with kind label.
        --
        -- Output is grouped per boss. Each row uses the same state logic
        -- the UI uses at render time (RR.CollectionStateForSource for
        -- loot, RR.SpecialCollectionStateForItem for mounts/pets/toys/
        -- decor). If the audit state disagrees with what you see in-game
        -- at the Adventure Journal, that's a bug to file. If they agree
        -- but the UI on the Tmog panel disagrees with both, the UI render
        -- path is the bug.
        --
        -- Tier items render inline with the loot items (they have a
        -- `classes = {classID}` field in the raid data; no separate tier
        -- section in this dump since they use the same state resolution).
        --
        -- Usage:
        --   /rr tmogaudit               -- audit currently-loaded raid
        --   /rr tmogaudit <substring>   -- audit a raid by name from
        --                                  anywhere (works outside the
        --                                  instance; transmog API doesn't
        --                                  care about zone).
        local nameQuery = rest and rest ~= "" and rest:lower() or nil
        local raid

        if nameQuery then
            -- Look up a raid by substring against RetroRuns_Data. The data
            -- table is keyed by instanceID; iterate values and match `.name`.
            local matches = {}
            if RetroRuns_Data then
                for _, r in pairs(RetroRuns_Data) do
                    if r and r.name and r.name:lower():find(nameQuery, 1, true) then
                        table.insert(matches, r)
                    end
                end
            end
            if #matches == 0 then
                RR:Print(("No supported raid matches %q. Try part of the name."):format(nameQuery))
                RR:Print("Supported raids:")
                if RetroRuns_Data then
                    for _, r in pairs(RetroRuns_Data) do
                        if r and r.name then
                            RR:Print(("  %s"):format(r.name))
                        end
                    end
                end
                raid = nil
            elseif #matches > 1 then
                RR:Print(("Ambiguous match for %q, matched %d raids:"):format(
                    nameQuery, #matches))
                for _, r in ipairs(matches) do
                    RR:Print(("  %s"):format(r.name))
                end
                RR:Print("Narrow the query and retry.")
                raid = nil
            else
                raid = matches[1]
            end
        else
            raid = RR.currentRaid
        end

        if not raid or not raid.bosses then
            if not nameQuery then
                RR:Print("No raid loaded. Zone into a supported raid, or use:")
                RR:Print("  /rr tmogaudit <raid name substring>")
            end
        elseif not RR.CollectionStateForSource then
            RR:Print("UI state helpers not available (UI.lua not loaded?)")
        else
            -- CACHE-WARM PASS.
            --
            -- GetItemInfo returns nil on a cold cache for items the client
            -- hasn't seen this session. When it returns nil,
            -- GetPetInfoByItemID also returns nil (it depends on item data),
            -- which causes the special-loot audit branch to fall through to
            -- "missing" state for every pet the client hasn't cached yet.
            --
            -- The UI doesn't hit this because by the time you browse the
            -- Tmog panel manually, you've mouse-hovered or otherwise queried
            -- enough items to warm the cache. But the audit runs dozens of
            -- cold queries back-to-back on first invocation.
            --
            -- Fix: request-load every itemID in the raid upfront, then wait
            -- a second (GET_ITEM_INFO_RECEIVED events resolve within a few
            -- hundred ms for items that exist in the client's data files)
            -- before rendering the audit.
            for _, boss in ipairs(raid.bosses) do
                if boss.loot then
                    for _, it in ipairs(boss.loot) do
                        if it.id then GetItemInfo(it.id) end
                    end
                end
                if boss.specialLoot then
                    for _, it in ipairs(boss.specialLoot) do
                        if it.id then GetItemInfo(it.id) end
                    end
                end
            end

            RR:Print("tmogaudit: warming item cache, please wait 1s...")

            C_Timer.After(1.0, function()
            local lines = {}
            local function add(s) table.insert(lines, s) end

            add(("tmogaudit: raid=%s"):format(tostring(raid.name or "?")))
            add("Key:")
            add("  C = collected (you have this exact sourceID)")
            add("  S = shared    (you have the appearance via a different sourceID)")
            add("  - = missing   (you don't have the appearance at all)")
            add("  ? = no source in data (missing/unmapped difficulty bucket)")
            add("")
            add("Row layout: <state4>  src=<L>,<N>,<H>,<M>  itemID  name")
            add("Compare against Adventure Journal -> <boss> -> each item.")
            add("Enable 'Show all class tier' in the EJ to see all tier variants.")
            add("")

            local DIFFS = { 17, 14, 15, 16 }
            local STATE_CHAR = { collected = "C", shared = "S", missing = "-" }
            local totals = { collected = 0, shared = 0, missing = 0, no_src = 0 }
            local specialTotals = { collected = 0, missing = 0 }

            for _, boss in ipairs(raid.bosses) do
                local bossHeader = ("=== Boss %d: %s ==="):format(
                    boss.index or 0, boss.name or "?")
                add(bossHeader)

                -- Regular loot
                if boss.loot and #boss.loot > 0 then
                    -- Sort alphabetically so audit order is stable and
                    -- matches roughly what the Tmog panel shows (which
                    -- alpha-sorts within shape buckets).
                    local sorted = {}
                    for _, it in ipairs(boss.loot) do
                        table.insert(sorted, it)
                    end
                    table.sort(sorted, function(a, b)
                        return (a.name or "") < (b.name or "")
                    end)

                    for _, item in ipairs(sorted) do
                        local stateChars  = {}
                        local srcParts    = {}
                        for _, diffID in ipairs(DIFFS) do
                            local src = item.sources and item.sources[diffID]
                            if src then
                                local state = RR.CollectionStateForSource(src, item.id)
                                table.insert(stateChars, STATE_CHAR[state] or "?")
                                table.insert(srcParts, tostring(src))
                                totals[state] = (totals[state] or 0) + 1
                            else
                                table.insert(stateChars, "?")
                                table.insert(srcParts, "-")
                                totals.no_src = totals.no_src + 1
                            end
                        end
                        local classTag = ""
                        if item.classes and item.classes[1] then
                            classTag = (" (tier classID=%d)"):format(item.classes[1])
                        end
                        add(("  %s  src=%s  %-7d  %s%s"):format(
                            table.concat(stateChars, ""),
                            table.concat(srcParts, ","),
                            item.id,
                            item.name or "?",
                            classTag))
                    end
                else
                    add("  (no regular loot)")
                end

                -- Special loot
                if boss.specialLoot and #boss.specialLoot > 0 and
                   RR.SpecialCollectionStateForItem then
                    add("")
                    add("  -- Special Loot --")
                    local sortedSp = {}
                    for _, it in ipairs(boss.specialLoot) do
                        table.insert(sortedSp, it)
                    end
                    table.sort(sortedSp, function(a, b)
                        return (a.name or "") < (b.name or "")
                    end)
                    for _, sp in ipairs(sortedSp) do
                        local state = RR.SpecialCollectionStateForItem(sp)
                        local ch = STATE_CHAR[state] or "?"
                        specialTotals[state] = (specialTotals[state] or 0) + 1
                        local mythicTag = sp.mythicOnly and " [Mythic only]" or ""
                        add(("  [%s]  %-7d  (%s) %s%s"):format(
                            ch, sp.id or 0, sp.kind or "?",
                            sp.name or "?", mythicTag))
                    end
                end
                add("")
            end

            -- Summary
            add("=== Summary ===")
            add(("Loot (per-diff totals across all items/difficulties):"))
            add(("  collected:        %d"):format(totals.collected))
            add(("  shared (amber):   %d"):format(totals.shared))
            add(("  missing (gray):   %d"):format(totals.missing))
            add(("  no source data:   %d"):format(totals.no_src))
            add(("Special Loot:"))
            add(("  collected:        %d"):format(specialTotals.collected))
            add(("  missing:          %d"):format(specialTotals.missing))

            RetroRunsDebug = RetroRunsDebug or {}
            RetroRunsDebug.tmogaudit = table.concat(lines, "\n")

            RR:ShowCopyWindow(
                ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: tmogaudit|r"),
                table.concat(lines, "\n"))
            RR:Print("tmogaudit complete. Copy window opened.")
            end) -- C_Timer.After callback closer
        end

    elseif cmd == "tmogverify" then
        -- Full-raid transmog DATA-INTEGRITY audit.
        --
        -- Companion to /rr tmogaudit. Where tmogaudit asks "does my UI's
        -- state logic match the API for each sourceID?" (a collection-
        -- correctness check), tmogverify asks "is each sourceID in our
        -- data the CORRECT sourceID for the (item, difficulty) bucket it
        -- lives in?" (a data-correctness check).
        --
        -- The distinction matters: if our data file has the Heroic sourceID
        -- written into the Normal bucket, tmogaudit will happily report
        -- the state of whatever sourceID is there -- and the UI will
        -- cheerfully paint a dot. Neither catches that the bucket is
        -- MIS-ASSIGNED. tmogverify catches that class of bug by cross-
        -- checking each sourceID's metadata (itemID it belongs to,
        -- visualID it resolves to, modID if the API reports it) against
        -- what we expect from its position in the data.
        --
        -- Checks per sourceID:
        --   [E1] GetSourceInfo(src) returns non-nil. Nil can mean
        --        class-restricted visibility (expected for cross-class tier)
        --        or invalid sourceID (data bug). We fall through to
        --        GetAppearanceInfoBySource for the class-restricted case
        --        and only flag FATAL_NIL if BOTH return nil.
        --   [E2] The source's itemID equals our item.id. Mismatch = the
        --        sourceID is attached to the wrong item in our data.
        --   [E3] Resolve the source's visualID (via
        --        GetAppearanceInfoBySource). Collect all 4 buckets'
        --        visualIDs for the item and sanity-check the shape:
        --          all 4 equal  -> Sepulcher-shape (single visual family),
        --                          normal.
        --          all 4 distinct -> Sanctum-shape (per-difficulty
        --                            visuals), normal.
        --          3+1         -> one outlier: suspicious, likely a
        --                         mis-assigned bucket.
        --          other mix   -> inconsistent shape: flag for manual
        --                         review.
        --   [E4] Source-duplication shape analysis. Duplicate sourceIDs
        --        across buckets are NOT automatically a bug -- they're how
        --        the data file encodes "binary shape" (single-variant
        --        items like Gavel of the First Arbiter or Edge of Night,
        --        which genuinely have one sourceID shared across all
        --        difficulties in the game itself). UI.lua's BuildDotRow
        --        detects these via CountUniqueSources and renders them as
        --        a single bracketed `[ check ]` indicator rather than a
        --        4-dot strip. Classification:
        --          1 unique source  -> binary shape (expected; informational)
        --          N unique (N=buckets) -> perdiff shape (expected; informational)
        --          2-3 unique        -> PARTIAL (WRN): harvest may have
        --                               half-resolved. Rae'shalare is a
        --                               known instance (bonusID variants
        --                               ATT stores differently than modID).
        --   [E5] Retired (was: difficulty-bucket mismatch via itemContext).
        --        The check depended on GetSourceInfo(src).itemLink, which
        --        is nil in tmogverify's runtime context across every shipped
        --        raid (audited 2026-05-15). Removed in v1.10.x rather than
        --        kept as silent no-op. Patch-boundary bucket-assignment
        --        regressions are now caught by the offline
        --        wago_loot_audit.py pipeline against db2; in-game, E3
        --        visualID shape outliers catch the same class of bug
        --        indirectly when a misbucketed variant has a different
        --        visual.
        --
        -- Coverage checks (require driving the EJ at each difficulty;
        -- async pass that runs after the per-row metadata checks):
        --   [E6] Coverage gap: EJ exposes more sourceIDs for this item at
        --        this difficulty than we shipped. Catches the harvester-
        --        skip class of bug (Antorus pre-v1.10.0): the harvester's
        --        fast path returned one sourceID, the EJ-sweep would
        --        have caught 4, the gate skipped the sweep, we shipped
        --        binary. Without this check, tmogverify on binary-shape
        --        data is clean but uninformative -- E1-E4 all pass on
        --        valid binary data even when the items SHOULD be per-
        --        difficulty.
        --   [E7] Missing item: EJ exposes an item at this boss that's not
        --        in our data file at all. Indicates a boss whose loot
        --        table was never fully harvested, or an item added by
        --        Blizzard post-harvest. Cross-difficulty: only flagged
        --        if missing at every difficulty (so a Mythic-only item
        --        that's also exposed at Normal won't false-positive).
        --
        -- Special-loot checks (kind = mount/pet/toy/decor):
        --   [S1] itemID resolves via GetItemInfo (non-nil name).
        --   [S2] kind tag agrees with the appropriate collection API:
        --          mount -> C_MountJournal.GetMountFromItem(itemID) non-nil
        --          pet   -> C_PetJournal.GetPetInfoByItemID(itemID) non-nil
        --          toy   -> C_ToyBox.GetToyInfo(itemID) non-nil
        --          decor -> no reliable API; only E1 checked
        --
        -- Output is grouped per boss. Each issue is flagged with a severity
        -- tag (ERROR / WARN / OK). A summary at the end tallies each class
        -- of finding.
        --
        -- Usage:
        --   /rr tmogverify               -- currently-loaded raid
        --   /rr tmogverify <substring>   -- any raid by name from anywhere
        local nameQuery = rest and rest ~= "" and rest:lower() or nil
        local raid

        if nameQuery then
            local matches = {}
            if RetroRuns_Data then
                for _, r in pairs(RetroRuns_Data) do
                    if r and r.name and r.name:lower():find(nameQuery, 1, true) then
                        table.insert(matches, r)
                    end
                end
            end
            if #matches == 0 then
                RR:Print(("No supported raid matches %q."):format(nameQuery))
                if RetroRuns_Data then
                    RR:Print("Supported raids:")
                    for _, r in pairs(RetroRuns_Data) do
                        if r and r.name then RR:Print(("  %s"):format(r.name)) end
                    end
                end
                raid = nil
            elseif #matches > 1 then
                RR:Print(("Ambiguous match for %q:"):format(nameQuery))
                for _, r in ipairs(matches) do RR:Print(("  %s"):format(r.name)) end
                raid = nil
            else
                raid = matches[1]
            end
        else
            raid = RR.currentRaid
        end

        if not raid or not raid.bosses then
            if not nameQuery then
                RR:Print("No raid loaded. Zone into a supported raid, or use:")
                RR:Print("  /rr tmogverify <raid name substring>")
            end
        else
            -- The verification body has been extracted into RR:VerifyOneRaid
            -- (see Core.lua just above the dispatcher). The dispatcher's job
            -- here is just to resolve which raid to verify and render the
            -- result. Cache-warm + the 1s wait both live inside VerifyOneRaid.
            RR:VerifyOneRaid(raid, { verbose = true, banner = true }, function(lines, T)
                RetroRunsDebug = RetroRunsDebug or {}
                RetroRunsDebug.tmogverify = table.concat(lines, "\n")
                RR:ShowCopyWindow(
                    ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: tmogverify|r"),
                    table.concat(lines, "\n"))
                RR:Print("tmogverify complete. Copy window opened.")
            end)
        end
    elseif cmd == "tmogverifyall" then
        -- Cross-raid audit: run tmogverify on every supported raid in
        -- RetroRuns_Data, sequentially, and produce one compact summary
        -- per raid in a single copy-window.
        --
        -- Compact-then-drill workflow: this command surfaces which raids
        -- have findings; if any raid has non-zero ERR or WRN counters, the
        -- STATUS line directs the user to re-run `/rr tmogverify <name>`
        -- on that specific raid to see the per-item detail.
        --
        -- Cost: ~8s per boss typical (4 difficulties x ~2s typical
        -- WaitForEJLootSettled), worst case ~40s/boss when every wait
        -- hits its 10s ceiling. A typical 14-raid / ~120-boss sweep
        -- takes ~15-20 minutes; worst case approaches an hour. Per-
        -- boss progress prints fire on chat during the sweep to make
        -- it obvious work is proceeding.
        --
        -- All raids verify from anywhere; the EJ-sweep uses
        -- EJ_SelectInstance(journalInstanceID) which does not require the
        -- player to physically be in the raid.
        if not RetroRuns_Data then
            RR:Print("tmogverifyall: RetroRuns_Data is not loaded.")
        else
            -- Collect the list of supported raids in a stable order.
            local raids = {}
            for _, r in pairs(RetroRuns_Data) do
                if r and r.bosses and r.name then
                    table.insert(raids, r)
                end
            end
            table.sort(raids, function(a, b) return a.name < b.name end)

            if #raids == 0 then
                RR:Print("tmogverifyall: no supported raids found in RetroRuns_Data.")
            else
                -- Wall-time estimate: per boss the coverage pass walks 4
                -- difficulties, each gated on WaitForEJLootSettled (up to
                -- 10s timeout; typical ~1-2s). Realistic average ~8s/boss.
                -- Worst case ~40s/boss if every wait times out.
                local totalBosses = 0
                for _, r in ipairs(raids) do
                    totalBosses = totalBosses + #r.bosses
                end
                local estSeconds = totalBosses * 8
                RR:Print(("tmogverifyall: %d raid(s), %d total bosses. Estimated wall-time ~%d minutes (worst case ~%d)."):format(
                    #raids, totalBosses,
                    math.ceil(estSeconds / 60),
                    math.ceil(totalBosses * 40 / 60)))
                RR:Print("Progress prints per boss; results land in a copy window at the end.")

                -- Accumulator for the final report.
                local report = {}
                local function reportAdd(s) table.insert(report, s) end
                reportAdd(("tmogverifyall: %d raid(s)"):format(#raids))
                reportAdd("Cross-raid audit. Per-raid summary follows; STATUS=clean")
                reportAdd("means no findings. STATUS=needs-review means at least one")
                reportAdd("error or warning fired; re-run `/rr tmogverify <name>` on")
                reportAdd("that raid for actionable per-item detail.")
                reportAdd("")

                local raidIdx = 0
                local function ProcessNextRaid()
                    raidIdx = raidIdx + 1
                    if raidIdx > #raids then
                        -- Done. Show consolidated copy window.
                        RetroRunsDebug = RetroRunsDebug or {}
                        RetroRunsDebug.tmogverifyall = table.concat(report, "\n")
                        RR:ShowCopyWindow(
                            ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: tmogverifyall|r"),
                            table.concat(report, "\n"))
                        RR:Print("tmogverifyall complete. Copy window opened.")
                        return
                    end

                    local raid = raids[raidIdx]
                    RR:Print(("  [%d/%d] %s..."):format(raidIdx, #raids, raid.name))

                    RR:VerifyOneRaid(raid, { verbose = false, banner = false, progress = true }, function(_, T)
                        -- Build compact summary for this raid.
                        local errCount = (T.fatal_nil or 0)
                                       + (T.item_mismatch or 0)
                                       + (T.coverage_gap or 0)
                                       + (T.missing_item or 0)
                                       + (T.special_kind_mismatch or 0)
                        local wrnCount = (T.shape_outlier or 0)
                                       + (T.shape_mixed or 0)
                                       + (T.no_visual or 0)
                                       + (T.special_item_unknown or 0)
                                       + (T.shape_partial or 0)
                        local status   = (errCount == 0 and wrnCount == 0)
                                         and "clean"
                                         or  ("needs-review (`/rr tmogverify " .. raid.name .. "`)")
                        local totalItems = (T.ok or 0) + errCount

                        reportAdd(("=== %s (journalInstanceID=%s) ==="):format(
                            raid.name, tostring(raid.journalInstanceID or "?")))
                        reportAdd(("  Items: %d (binary=%d, per-diff=%d, partial=%d)"):format(
                            totalItems, T.shape_binary or 0, T.shape_perdiff or 0, T.shape_partial or 0))
                        reportAdd(("  Findings: %d ERR / %d WRN"):format(errCount, wrnCount))
                        reportAdd(("    fatal_nil=%d, item_mismatch=%d"):format(
                            T.fatal_nil or 0, T.item_mismatch or 0))
                        reportAdd(("    coverage_gap=%d (E6), missing_item=%d (E7)"):format(
                            T.coverage_gap or 0, T.missing_item or 0))
                        reportAdd(("  STATUS: %s"):format(status))
                        reportAdd("")

                        -- Yield to the engine briefly between raids; otherwise
                        -- the cumulative EJ work in a single tick may run up
                        -- against UI responsiveness limits.
                        C_Timer.After(0.5, ProcessNextRaid)
                    end)
                end

                ProcessNextRaid()
            end
        end
    elseif cmd == "ejdiff" then
        -- Diagnose the EJ's loot visibility per difficulty.
        --
        -- Walks the given boss (by journalEncounterID) at LFR / N / H / M,
        -- reporting how many loot items the EJ returns at each difficulty
        -- and whether a specific probe itemID shows up. Useful for
        -- confirming whether EJ_SetDifficulty actually filters loot from
        -- outside the instance, or whether the EJ is gated by your
        -- physical zoned-into difficulty.
        --
        -- Usage: /rr ejdiff <journalEncounterID> [probeItemID]
        --        /rr ejdiff <journalEncounterID> list
        -- Example: /rr ejdiff 2464 190768   (Jailer + Zereth Overseer mount)
        --          /rr ejdiff 2441 list     (Sylvanas; dump full per-difficulty loot)
        local encID = tonumber(args[2])
        local listMode = args[3] == "list"
        local probeID = not listMode and tonumber(args[3]) or nil
        if not encID then
            RR:Print("Usage: /rr ejdiff <journalEncounterID> [probeItemID | list]")
            RR:Print("  (The Jailer's encounterID is 2464; mount probe ID is 190768)")
        else
            local lines = {}
            local function add(s) table.insert(lines, s) end

            local instName, instID
            do
                local _, _, _, _, _, iID = EJ_GetEncounterInfo(encID)
                instID = iID
                if instID then
                    instName = EJ_GetInstanceInfo(instID)
                end
            end
            add(("ejdiff encID=%d  instanceID=%s  instance=%s"):format(
                encID, tostring(instID), tostring(instName)))
            if probeID then
                add(("probe itemID=%d"):format(probeID))
            end

            local DIFFS = { {17,"LFR"}, {14,"Normal"}, {15,"Heroic"}, {16,"Mythic"} }

            -- Run each difficulty sequentially with a short delay between.
            -- Because EJ_GetNumLoot is synchronous-after-EJ_SelectEncounter,
            -- we wait ~1.5s per difficulty to absorb any loot-data-received
            -- late events. This is a diagnostic; not optimized for speed.
            local idx = 0
            local function Next()
                idx = idx + 1
                if idx > #DIFFS then
                    add("done.")
                    RetroRunsDebug = RetroRunsDebug or {}
                    RetroRunsDebug.ejdiff = table.concat(lines, "\n")
                    RR:ShowCopyWindow(
                        ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: ejdiff %d|r"):format(encID),
                        table.concat(lines, "\n"))
                    RR:Print("ejdiff complete. Copy window opened.")
                    return
                end
                local diffID, diffName = DIFFS[idx][1], DIFFS[idx][2]
                EJ_SetDifficulty(diffID)
                if instID then EJ_SelectInstance(instID) end
                EJ_ResetLootFilter()
                C_Timer.After(0.3, function()
                    pcall(EJ_SelectEncounter, encID)
                    EJ_SetDifficulty(diffID)
                    C_Timer.After(1.5, function()
                        local n = EJ_GetNumLoot() or 0
                        if listMode then
                            add(("  %-6s (%d): %d items"):format(diffName, diffID, n))
                            for i = 1, n do
                                local info = C_EncounterJournal.GetLootInfoByIndex(i)
                                if info then
                                    add(("    itemID=%-7s name=%s"):format(
                                        tostring(info.itemID), tostring(info.name)))
                                end
                            end
                            Next()
                            return
                        end
                        local probeFound = false
                        local probeHasEquipLoc
                        for i = 1, n do
                            local info = C_EncounterJournal.GetLootInfoByIndex(i)
                            if info and info.itemID == probeID then
                                probeFound = true
                                local _, _, _, _, _, _, _, _, equipLoc =
                                    GetItemInfo(info.itemID)
                                probeHasEquipLoc = equipLoc
                                break
                            end
                        end
                        if probeID then
                            add(("  %-6s (%d): %d items; probe %d found=%s equipLoc=%q"):format(
                                diffName, diffID, n, probeID,
                                tostring(probeFound),
                                tostring(probeHasEquipLoc or "")))
                        else
                            add(("  %-6s (%d): %d items"):format(diffName, diffID, n))
                        end
                        Next()
                    end)
                end)
            end
            Next()
        end

    elseif cmd == "record" then
        local sub = args[2] or ""
        if     sub == "start"  then RR:StartRecording()
        elseif sub == "stop"   then RR:StopRecording()
        elseif sub == "dump"   then RR:DumpRecording()
        elseif sub == "reset"  then RR:ResetRecording()
        elseif sub == "status" then RR:RecordingStatus()
        elseif sub == "break"  then RR:RecordBreak()
        elseif sub == "tp"     then
            local dest = RR.Trim(rest:sub(3))   -- strip "tp"
            if dest == "" then
                RR:Print("Usage: /rr record tp <destination name>")
            else
                RR:RecordTeleport(dest)
            end
        elseif sub == "note" then
            local note = RR.Trim(rest:sub(5))   -- strip "note"
            if note == "" then
                RR:Print("Usage: /rr record note <text>")
            else
                RR:RecordSetNote(note)
            end
        else
            RR:Print("Record: /rr record [start|stop|dump|reset|status|break|tp <dest>|note <text>]")
        end

    elseif cmd == "yelldebug" then
        local sub = args[2] or ""
        if     sub == "start" then RR:YellDebugStart()
        elseif sub == "stop"  then RR:YellDebugStop()
        else
            RR:Print("YellDebug: /rr yelldebug [start|stop]  (capture chat-channel yells for diagnosis)")
        end

    elseif cmd == "cancelnav" then
        if RR.state.activeRoute then
            RR:CancelNavRoute()
            RR:Print("Navigation cancelled.")
        else
            RR:Print("No active navigation route.")
        end

    elseif cmd == "status" then
        RR:PrintStatus()

    else
        -- Help text. Default output is a short user-facing list; dev /
        -- diagnostic commands are hidden behind `/rr help dev` to keep
        -- the normal help from overwhelming alpha testers who might
        -- otherwise poke at record / harvest / kill / test and corrupt
        -- their state.
        local subcmd = args[2] or ""
        if subcmd == "dev" then
            RR:Print("RetroRuns dev / maintainer commands:")
            RR:Print("  /rr  debug                       (toggle verbose logging)")
            RR:Print("  /rr  test | next | real          (test-mode stepping)")
            RR:Print("  /rr  resetsegments               (clear persisted segment state)")
            RR:Print("  /rr  kill <name> | unkill <name> (manual kill-state override)")
            RR:Print("  /rr  record [start|stop|dump|reset|status|break|tp <dest>|note <text>]")
            RR:Print("  /rr  sessionlog [all]            (recorder session log; omit `all` for current-raid only)")
            RR:Print("  /rr  lintroute [raid name]       (structural lint of raid routing data)")
            RR:Print("  /rr  diag                        (consolidated engine + zonelog + sessionlog)")
            RR:Print("  /rr  mapicons                    (dump exact coords of every Blizzard icon on the visible map)")
            RR:Print("  /rr  raidcapture                 (full new-raid tier + loot harvest)")
            RR:Print("  /rr  weaponharvest               (harvest CN weapon-token pools)")
            RR:Print("  /rr  vendorscan                  (scan open merchant frame for items+costs)")
            RR:Print("  /rr  tmogtest <itemID>           (transmog diagnostic)")
            RR:Print("  /rr  ejprobe [itemID]            (dump EJ loot for selected encounter)")
            RR:Print("  /rr  tierprobe <itemID>          (dump C_TransmogSets sources for a tier itemID)")
            RR:Print("  /rr  srctest <sourceID>          (transmog source diagnostic)")
            RR:Print("  /rr  specialtest <itemID>        (special-loot API probe)")
            RR:Print("  /rr  dottest <itemID>            (per-diff dot state probe)")
            RR:Print("  /rr  tmogaudit [raid name]       (full-raid tmog audit dump)")
            RR:Print("  /rr  tmogverify [raid name]      (full-raid data-integrity audit)")
            RR:Print("  /rr  tmogverifyall               (run tmogverify across every shipped raid)")
            RR:Print("  /rr  ejdiff <encID> [itemID]     (EJ per-difficulty probe)")
            RR:Print("  /rr  tmogsrc | tmogtrace         (transmog internals)")
            RR:Print("  /rr  ej                          (EJ + instance-info dump for bring-up)")
            RR:Print("  /rr  yelldebug [start|stop]      (capture chat-channel yells for diagnosis)")
            RR:Print("  /rr  devtools                    (toggle the DevTools panel)")
            RR:Print("  /rr  cancelnav                   (cancel an active entrance-navigation route)")
            RR:Print("  /rr  reset | refresh             (reset settings to defaults | re-render the main panel)")
        else
            RR:Print("RetroRuns commands:")
            RR:Print("  /rr                  (toggle main panel)")
            RR:Print("  /rr  show | hide     (show / hide main panel)")
            RR:Print("  /rr  status          (current raid, step, kill state)")
            RR:Print("  /rr  tmog            (open transmog browser)")
            RR:Print("  /rr  skips           (account-wide raid skip status)")
            RR:Print("  /rr  settings        (open settings window)")
        end
    end
end

-------------------------------------------------------------------------------
-- Event handler
-------------------------------------------------------------------------------

RR.frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... == ADDON_NAME then
            RR:InitializeDB()
            if RR:GetSetting("debug") then ValidateRaidData() end
            C_Timer.After(0, function()
                RR:RestorePanelPosition()
                RR:InitMinimapButton()
                RR:InitYellTriggers()
                RR:RefreshAll()
            end)
        end

    elseif event == "PLAYER_LOGIN" then
        -- One-line load banner. Fires once per session (including /reload)
        -- after all addons have initialized. Useful for alpha testers:
        -- gives them the current build number for bug reports, and a
        -- pointer to the help command for discoverability. 2s delay to
        -- avoid clashing with Blizzard's own startup chat spam.
        C_Timer.After(2.0, function()
            RR:Print(("|cffaaaaaav%s loaded. Type |r|cffffffff/rr help|r|cffaaaaaa for commands.|r"):format(
                VERSION))
        end)

        -- Register RetroRuns as a known external waypoint source with
        -- AzerothWaypoint, so that when AWP adopts our route it attributes
        -- it to RetroRuns in its UI (display name, queue presentation)
        -- instead of the generic-unknown-addon path. The stackMatches
        -- string is the lowercased Lua filename AWP looks for in the
        -- call stack; it must end up matching ours exactly when AWP
        -- inspects debugstack(). transient=true is the right semantic
        -- for our entrance-button waypoints -- short-lived per-click
        -- destinations that shouldn't displace AWP's persistent manual
        -- queue. Guarded on the API existing so older AWP versions (or
        -- AWP not installed at all) silently no-op. AWP's own README
        -- documents the API as the integration entry point for partner
        -- addons; SilverDragon and RareScanner are the existing examples.
        if _G.AzerothWaypointNS
            and type(_G.AzerothWaypointNS.RegisterExternalWaypointSource) == "function"
        then
            _G.AzerothWaypointNS.RegisterExternalWaypointSource("retroruns", {
                displayName  = "RetroRuns",
                stackMatches = { "retroruns\\core.lua" },
                transient    = true,
                iconKey      = "retroruns",
            })
        end

        -- Reset the encounter-note expand state to collapsed at session
        -- start. The setting controls whether the "Boss Encounter:" line
        -- shows the full soloTip text or the "view special note" link;
        -- it's session-scoped because users expect collapsed-by-default
        -- on each fresh login/reload, and the prior persistent behaviour
        -- could surface long soloTip text unexpectedly when the user
        -- arrived at a boss they hadn't intentionally expanded.
        RR:SetSetting("encounterExpanded", false)

        -- Warm GetItemInfo cache for every tier-token itemID in every
        -- loaded raid. Queues an async fetch per itemID so subsequent
        -- calls (from the transmog popup's weapon-tokens section) can
        -- resolve names/links without a cold-cache miss. Cheap: 12
        -- entries per tokenized raid, fires once on login.
        if RetroRuns_Data and GetItemInfo then
            for _, raid in pairs(RetroRuns_Data) do
                local ts = raid.tierSets and raid.tierSets.tokenSources
                if ts then
                    for tokenID in pairs(ts) do
                        GetItemInfo(tokenID)
                    end
                end
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        RR.state.isReloadingUi = isReloadingUi and true or false
        RR:ZoneLog(("PEW: isInitialLogin=%s isReloadingUi=%s"):format(
            tostring(isInitialLogin), tostring(isReloadingUi)))

        -- On initial login (not /reload), wipe the persisted zone log
        -- so stale entries from prior sessions don't carry forward.
        -- /reload preserves it; a full quit doesn't.
        if isInitialLogin and RetroRunsDB then
            if RetroRunsDB.zoneLog then wipe(RetroRunsDB.zoneLog) end
            -- One-shot cleanup of orphan keys from pre-consolidation
            -- builds. These tables are never read or written anymore;
            -- niling them here reclaims SavedVar space for upgrading
            -- users without affecting fresh installs. The keys never
            -- come back, so the cleanup is effectively idempotent.
            RetroRunsDB.completedSegments  = nil
            RetroRunsDB.visitedMapIDs      = nil
            RetroRunsDB.stepVisitedMapIDs  = nil
            RR:ZoneLog("PEW: initial login -- wiped zone log")
        end

        C_Timer.After(1.0, function() RR:HandleLocationChange() end)

    elseif event == "ZONE_CHANGED_NEW_AREA"
        or event == "ZONE_CHANGED"
        or event == "ZONE_CHANGED_INDOORS" then
        -- _NEW_AREA covers major zone transitions; the other two cover
        -- sub-zone moves within a zone (needed for Vault's named
        -- sub-zones, etc).
        RR:ZoneLog(event .. " event fired")
        C_Timer.After(0.5, function() RR:HandleLocationChange() end)

    elseif event == "UPDATE_INSTANCE_INFO" then
        if not RR.state.testMode
            and RR.currentRaid
            and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
            local changed = RR:SyncFromSavedRaidInfo(false)  -- data already fresh from server push
            RR:ZoneLog(("UPDATE_INSTANCE_INFO handler: changed=%s"):format(tostring(changed)))
            if changed ~= false then
                RR:ZoneLog("UPDATE_INSTANCE_INFO handler: calling UI.Update + MapOverlay:Refresh")
                RR.UI.Update()
                if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
            end
        end

    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, _, _, success = ...

        RR:ZoneLog(("ENCOUNTER_END fired: id=%s name=%q success=%s testMode=%s loadedKey=%s currentKey=%s")
            :format(tostring(encounterID), tostring(encounterName), tostring(success),
                    tostring(RR.state.testMode),
                    tostring(RR.state.loadedRaidKey),
                    tostring(RR:GetRaidContextKey())))

        -- Clear the encounter-active flag regardless of success so the
        -- travel pane unfreezes whether the kill happened, the group
        -- wiped, or the boss reset. Set in ENCOUNTER_START below; read
        -- by BuildTravelText to freeze rendering during the fight.
        RR.state.inEncounter = false

        if not RR.state.testMode
            and RR.currentRaid
            and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
            if success == 1 then
                -- Prefer the locale-independent ID-based path. The
                -- name-based path is kept as a fallback so raids with
                -- incomplete journalEncounterID coverage in the data
                -- still resolve. On non-English clients the name path
                -- can't match (boss.name is English in our data), so
                -- the ID path is the only thing that lets Boss Progress
                -- update in real time. UPDATE_INSTANCE_INFO will still
                -- eventually update the saved-instance cache, but only
                -- the ID path is real-time.
                if not RR:MarkBossKilledByEncounterID(encounterID) then
                    RR:MarkBossKilledByEncounterName(encounterName)
                end
                RR.UI.Update()
                if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
            else
                -- Wipe / reset: still re-render so the travel pane
                -- snaps back to the live (non-frozen) text.
                RR.UI.Update()
            end
        end

    elseif event == "ENCOUNTER_START" then
        -- Set encounter-active flag so the travel pane freezes its
        -- text for the duration of the fight. The pre-pull text stays
        -- visible (e.g. "Approach the boss to start the encounter")
        -- through phase transitions and intermissions; ENCOUNTER_END
        -- above clears the flag and triggers a re-render that picks
        -- up the next step's seg[1] note (e.g. for Tindral->Fyrakk:
        -- "After killing Tindral, mount up and fly into the fire
        -- portal..."). This intentionally avoids surfacing stale
        -- mid-fight directions when the engine reports a different
        -- mapID for phase 2 platforms (Tindral Northern Boughs,
        -- Smolderon's bridge, Fyrakk's transit).
        RR.state.inEncounter = true
        if RR.UI and RR.UI.Update then RR.UI.Update() end

    elseif event == "GET_ITEM_INFO_RECEIVED" then
        -- WoW resolved an asynchronous GetItemInfo request -- the
        -- item's name, quality, link, and other fields are now live
        -- in the cache. Repaint the Tmog browser if it's open so
        -- newly-resolved items render correctly without the user
        -- having to close and reopen the dropdown.
        --
        -- A full raid easily contains 100+ items. On a fresh login,
        -- opening the browser kicks off many GetItemInfo calls, each
        -- of which fires this event when its async fetch completes.
        -- Refreshing immediately on every event would chain hundreds
        -- of redraws back-to-back. Coalesce instead: when an event
        -- arrives, schedule a single redraw 0.1s out and drop further
        -- events that arrive in the meantime. The result is one
        -- repaint per ~100ms burst of cache fills, which is fast
        -- enough that the user sees items resolve smoothly.
        if RR.UI and RR.UI.RequestBrowserRefresh then
            RR.UI.RequestBrowserRefresh()
        end

    end
end)

RR.frame:RegisterEvent("ADDON_LOADED")
RR.frame:RegisterEvent("PLAYER_LOGIN")
RR.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
RR.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
RR.frame:RegisterEvent("ZONE_CHANGED")
RR.frame:RegisterEvent("ZONE_CHANGED_INDOORS")
RR.frame:RegisterEvent("UPDATE_INSTANCE_INFO")
RR.frame:RegisterEvent("ENCOUNTER_END")
RR.frame:RegisterEvent("ENCOUNTER_START")
RR.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

-------------------------------------------------------------------------------
-- Tickers
-------------------------------------------------------------------------------

-- UI heartbeat. Fires once per second while in a loaded raid; calls
-- UI.Update unconditionally. Heartbeat is logged to ZoneLog only when
-- explicitly requested via /rr debug -- otherwise it would flood the
-- log buffer (60 entries per minute) and push useful entries out.
local heartbeatTicks = 0
C_Timer.NewTicker(1.0, function()
    if RR.currentRaid
        and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
        heartbeatTicks = heartbeatTicks + 1
        if RR:GetSetting("debug") then
            RR:ZoneLog(("HEARTBEAT tick #%d: calling UI.Update"):format(heartbeatTicks))
        end
        RR.UI.Update()
        if WorldMapFrame and WorldMapFrame:IsShown() and RetroRunsMapOverlay then
            RetroRunsMapOverlay:Refresh()
        end

        -- Heartbeat mapID-change poll. Closes a gap in Blizzard's event
        -- timing: some elevator and flight transitions don't fire
        -- ZONE_CHANGED events at the exact moment the mapID changes.
        -- For example, BfD's Loa's Sanctum (1354) -> Walk of Kings (1356)
        -- elevator only fires ZONE_CHANGED_INDOORS for the sub-zone
        -- change, while C_Map.GetBestMapForUnit still reports 1354 at
        -- that moment; the actual mapID transition happens mid-elevator
        -- with no event accompanying it. Without this poll the engine
        -- would miss those transitions.
        if C_Map and C_Map.GetBestMapForUnit then
            local nowMapID = C_Map.GetBestMapForUnit("player")
            if nowMapID and nowMapID ~= RR.state.lastPolledMapID then
                RR.state.lastPolledMapID = nowMapID
                RR:AdvanceProgress("heartbeat")
            end
        end
    end
end)
