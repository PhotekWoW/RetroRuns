-------------------------------------------------------------------------------
-- RetroRuns -- Core.lua
-- Namespace, DB lifecycle, event hub, slash commands, shared utilities.
-- No UI frame references. No navigation logic.
-------------------------------------------------------------------------------

local ADDON_NAME = "RetroRuns"
local VERSION    = "1.10.1"

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
        completedSegments     = {},   -- [stepIndex][segIndex] = true
        visitedMapIDs         = {},   -- [mapID] = true; mapIDs the player has been on this lockout
        stepVisitedMapIDs     = {},   -- [mapID] = true; mapIDs visited since current step became active. Reset on step change.
        activeStep            = nil,
        testMode              = false,
        manualTargetBossIndex = nil,
        loadedRaidKey         = nil,
        lastSeenRaidKey       = nil,
        lastUnsupportedRaid   = nil,
        currentDifficultyID   = nil,
        currentDifficultyName = nil,
        isReloadingUi         = false, -- captured from PLAYER_ENTERING_WORLD
        zoneLog               = {},   -- ring buffer of zone-change debug lines, viewable via /rr zonelog
        -- Last mapID observed by the strict-activeSeg heartbeat poll
        -- (Core.lua's 1Hz ticker, AdvanceStrictActiveSeg trigger). The
        -- poll only fires AdvanceStrictActiveSeg when nowMapID differs
        -- from this baseline, so it must be kept in sync with the
        -- seed's playerMapID; otherwise a step transition that seeds at
        -- mapID X with the poll's last-seen mapID at Y can immediately
        -- fire a spurious advance on the next tick when the poll
        -- "discovers" the X->Y delta even though the player never
        -- moved. SeedStrictActiveSeg writes here when it seeds.
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
        -- minimized: when true, the main panel renders as a tiny title-bar
        -- only (logo + RETRO RUNS text + minimize/close buttons), with all
        -- body fields and footer action buttons hidden. Toggled via the
        -- minimize button left of the close X. Persists across /reload
        -- (unlike showPanel, which is force-reset to false on init so the
        -- panel always starts hidden after a reload).
        minimized    = false,
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
--- /rr zonelog to open a copyable window.
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

--- Detect which navigation tier is active for the current addon load
--- state. Returns one of:
---
---   "routing"  -- A full step-by-step routing addon is loaded
---                 (currently: AzerothWaypoint, Zygor with pathfinding
---                 enabled, or Mapzeroth). Click drops the player into
---                 that addon's GPS UI with a planned route. AWP is
---                 included here even though it's a meta-router rather
---                 than a planner itself: it presents a queue/arrow
---                 UI for routes regardless of which backend is doing
---                 the planning, so from the user's perspective the
---                 click experience is the same as a direct routing
---                 addon. AWP without a backend installed degrades to
---                 a single-pin presentation, same as Zygor without
---                 pathfinding -- treated as the correct degradation.
---   "waypoint" -- No routing addon, but a waypoint provider is
---                 available (TomTom, or Blizzard native as universal
---                 fallback). Click sets a single waypoint at the
---                 destination -- one arrow, no step-by-step.
---
--- The UI uses this to gate the entrance-button visual state (full-
--- color when "routing", muted when "waypoint") and the legend copy.
--- NavigateToEntrance uses the same precedence order at click time,
--- so detection and dispatch stay in lock-step.
---
--- Detection is reevaluated on each call so the result reflects the
--- current addon-load state -- a /reload after the user installs or
--- enables a routing addon picks up the change.
---
--- Zygor wins ties over Mapzeroth when both are installed but AWP is
--- not. Zygor is a paid premium subscription with a more polished
--- routing experience (no separate window required, integrated
--- arrow+travel-mode UI). A user who pays for Zygor will expect that
--- experience to take precedence; Mapzeroth is the recommended FREE
--- fallback path for users without a Zygor sub. The legend below
--- names Mapzeroth specifically as the install recommendation since
--- it's the free option. When AWP is present it wins over both --
--- AWP would be orchestrating one of them itself, so calling them
--- directly would skip AWP's UI surface entirely.
---
--- Zygor detection is presence-only -- we don't try to verify the
--- license is current or that ZGV.db.profile.pathfinding is enabled.
--- A Zygor user with a lapsed subscription or pathfinding turned off
--- gets a single arrow instead of a route, which is the correct
--- degradation -- it matches what would happen with /zygor goto.
function RR:GetNavTier()
    if _G.AzerothWaypointNS
        and type(_G.AzerothWaypointNS.RequestManualRoute) == "function" then
        return "routing"
    end
    if _G.ZygorGuidesViewer
        and _G.ZygorGuidesViewer.Pointer
        and _G.ZygorGuidesViewer.Pointer.SetWaypoint then
        return "routing"
    end
    if _G.Mapzeroth and _G.Mapzeroth.FindRoute then
        return "routing"
    end
    return "waypoint"
end

--- Route the player to the entrance of a raid.
---
--- Five-tier preference order:
---   1. AzerothWaypoint installed: hand off to NS.RequestManualRoute.
---      AWP is a meta-router that orchestrates one of Farstrider /
---      Mapzeroth / Zygor / direct underneath, plus its own arrow and
---      queue UI. Calling AWP directly (rather than relying on its
---      TomTom hook to silently intercept us) makes our route appear
---      in AWP's queue with proper RetroRuns attribution and bypasses
---      the hook-adoption path that the user's allowlist setting
---      doesn't cover. Goes first because AWP would be orchestrating
---      the lower-tier addons itself; calling them directly when AWP
---      is present would skip AWP's UI surface entirely. We register
---      RetroRuns as a known external waypoint source at PLAYER_LOGIN
---      so AWP attributes adopted routes to us by name.
---   2. Zygor installed (no AWP): hand off to ZGV.Pointer:SetWaypoint
---      with findpath=true, which triggers Zygor's LibRover pathfinder
---      and renders the resulting route in Zygor's own arrow + travel-
---      mode UI. Step-by-step experience for paid users. Requires
---      ZGV.db.profile.pathfinding to be enabled (Zygor's "Travel
---      Mode" setting); if disabled, the call falls back to a single
---      arrow at the destination, same degradation /zygor goto would
---      produce. Zygor takes precedence over Mapzeroth because it's
---      the premium product and a paying Zygor user expects that
---      experience to win.
---   3. Mapzeroth installed (no AWP, no Zygor): hand off directly to
---      its FindRoute API with our entrance coords. Mapzeroth runs
---      Dijkstra over its curated travel graph (portals, flight paths,
---      hearthstones, mage teleports, class abilities, toys, items)
---      and presents the player with a multi-step route in its own
---      GPS navigator and route execution frame. Handles cross-
---      continent, faction filtering, attunement gating, holiday-only
---      portals -- the whole problem space. Free install; the legend
---      below recommends it specifically when no routing addon is
---      loaded.
---   4. TomTom installed (none of the above): drop a single waypoint
---      at the entrance with from = "RetroRuns" tag. Single-arrow
---      experience that works in-zone and silently hides cross-
---      continent (TomTom's hardcoded behavior).
---   5. None of the above: Blizzard native C_Map.SetUserWaypoint with
---      super-tracker arrow. Universal fallback. The Blizzard arrow
---      cheerfully points cross-continent, so this is actually
---      better than TomTom-direct for cross-continent guidance.
---
--- The detection precedence here mirrors GetNavTier(). Tiers 1, 2,
--- and 3 fall under GetNavTier()'s "routing" return (AWP is a router
--- whether or not it has a backend installed -- AWP without a backend
--- still produces queue UI and pin presentation, just no multi-leg
--- planning); tiers 4 and 5 fall under "waypoint". Zygor wins ties
--- over Mapzeroth when both are installed and AWP is absent (see
--- GetNavTier rationale).
---
--- An earlier iteration tried to drive multi-step routing ourselves
--- via FarstriderLib + a position-watching ticker. The map-graph edge
--- cases (city vs zone mapID mismatches, attunement gating, dragon-
--- riding altitude considerations, phasing) made it a tar pit. We
--- chose to be a good ecosystem citizen instead: hand off to
--- dedicated routing addons when present, drop a plain waypoint when
--- not.
---
--- Entrance accessor. Looks like a one-liner today, but kept as a named
--- accessor so callers don't reach into raid struct internals -- if the
--- entrance schema ever changes again (e.g. multi-portal raids, instanced-
--- city entrance disambiguation), there's a single chokepoint to update
--- rather than a grep-and-replace across UI/Core read sites.
---
--- Faction-asymmetric raids (currently only BfD) are handled at a higher
--- level: `GetSupportedRaid` consults `RetroRuns_DataHorde[instanceID]`
--- first for Horde characters and falls back to the shared
--- `RetroRuns_Data[instanceID]` table when no Horde-specific file exists.
--- By the time a raid object reaches this accessor, faction dispatch has
--- already happened, so the entrance field is simply `raid.entrance` --
--- whichever side's table we read from.
function RR:GetRaidEntrance(raid)
    if not raid then return nil end
    return raid.entrance
end

--- Returns one of "awp" / "zygor" / "mapzeroth" / "tomtom" /
--- "blizzard" / nil to indicate which branch ran. The UI uses this to
--- surface branch-specific feedback (e.g. a transient "waypoint set"
--- toast on the silent Blizzard-native path, since that branch
--- otherwise has no visible signal beyond the pin appearing on the
--- map).
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

    -- Cancel any in-progress route before starting a new one. Avoids
    -- stale waypoints when the user clicks a different raid back-to-back.
    -- (Mapzeroth handles route replacement internally via BeginRoute-
    -- Navigation; Zygor handles it via the cleartype=true flag we pass
    -- on each call; AWP handles it via RequestManualRoute supplanting
    -- whatever manual route was previously active -- so none of those
    -- need explicit teardown. The TomTom and Blizzard paths do need
    -- active cleanup -- handled in CancelNavRoute below.)
    self:CancelNavRoute()

    local title = ("RetroRuns: %s entrance"):format(raid.name or "raid")

    -- AWP tier: AzerothWaypoint is a meta-router that orchestrates one of
    -- Farstrider / Mapzeroth / Zygor / direct, plus its own arrow and queue
    -- UI. When AWP is installed, it's the user's deliberate choice for
    -- routing presentation -- so we hand off to it directly via its
    -- documented public route-request API rather than calling TomTom and
    -- relying on AWP's hook to silently intercept us. Direct call surfaces
    -- our route in AWP's queue with proper RetroRuns attribution (paired
    -- with the RegisterExternalWaypointSource call at PLAYER_LOGIN), and
    -- works regardless of whether the user has TomTom installed at all.
    -- Goes ABOVE Zygor/Mapzeroth in the cascade because AWP would be
    -- orchestrating those itself; calling them directly when AWP is
    -- present would skip AWP's UI surface entirely. If RequestManualRoute
    -- returns false (AWP declined to adopt -- e.g. routing disabled in
    -- AWP settings), we fall through to the Zygor/Mapzeroth/TomTom/
    -- Blizzard tiers as a safety net.
    if _G.AzerothWaypointNS
        and type(_G.AzerothWaypointNS.RequestManualRoute) == "function"
    then
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            e.mapID, e.x, e.y, title, nil, nil)
        if ok and routed then
            self.state.activeRoute = { raid = raid, awpRoute = true }
            return "awp"
        end
    end

    if _G.ZygorGuidesViewer
        and _G.ZygorGuidesViewer.Pointer
        and _G.ZygorGuidesViewer.Pointer.SetWaypoint then
        -- Mirrors the data table that ZGV.Pointer:SetWaypointByCommand-
        -- Line builds for /zygor goto -- exactly the same payload Zygor
        -- itself constructs for its own user-facing waypoint command.
        -- The findpath=true flag is what triggers LibRover routing
        -- (gated by ZGV.db.profile.pathfinding); without it Zygor would
        -- just show a single arrow.
        _G.ZygorGuidesViewer.Pointer:SetWaypoint(e.mapID, e.x, e.y, {
            findpath    = true,
            type        = "manual",
            cleartype   = true,
            title       = title,
            onminimap   = "always",
            overworld   = true,
            showonedge  = true,
        }, true)
        self.state.activeRoute = { raid = raid, zygorRoute = true }
        return "zygor"
    end

    if _G.Mapzeroth and _G.Mapzeroth.FindRoute then
        _G.Mapzeroth:FindRoute("_WAYPOINT_DESTINATION", {
            mapID  = e.mapID,
            x      = e.x,
            y      = e.y,
            name   = title,
            source = "retroruns",
        })
        self.state.activeRoute = { raid = raid, mapzerothRoute = true }
        return "mapzeroth"
    end

    if TomTom and TomTom.AddWaypoint then
        local uid = TomTom:AddWaypoint(e.mapID, e.x, e.y, {
            title  = title,
            from   = "RetroRuns",
            silent = true,
            crazy  = true,
        })
        self.state.activeRoute = { raid = raid, tomtomWaypoint = uid }
        return "tomtom"
    end

    if C_Map and C_Map.SetUserWaypoint and UiMapPoint then
        local point = UiMapPoint.CreateFromCoordinates(e.mapID, e.x, e.y)
        C_Map.SetUserWaypoint(point)
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
        self.state.activeRoute = { raid = raid, blizzardWaypoint = true }
        return "blizzard"
    end

    self:Print("No supported waypoint API available.")
    return nil
end

--- Drop a waypoint at a Covenant Sanctum's Mythic Nathrian Weaponsmith.
--- Mirrors NavigateToEntrance's cascade (AWP -> Zygor -> Mapzeroth ->
--- TomTom -> Blizzard) but reads target coords from raid.weaponVendors
--- keyed by covenantID (C_Covenants.GetActiveCovenantID return value).
---
--- Specific to Castle Nathria, where the Tmog detail pane surfaces a
--- "Redeem at <covenant> vendor" hint when viewing a boss that drops
--- weapon tokens. The Flight button next to that hint calls into here.
---
--- Returns the same tier string NavigateToEntrance does ("awp", "zygor",
--- "mapzeroth", "tomtom", "blizzard") or nil on failure -- caller uses
--- this for the same toast-popup branching.
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

    -- Clear any in-progress route before starting a new one (same
    -- rationale as NavigateToEntrance -- avoids stale waypoints when
    -- the user clicks between the entrance and sanctum buttons back-
    -- to-back).
    self:CancelNavRoute()

    local title = ("RetroRuns: %s (%s vendor)"):format(
        vendor.vendorName or "Sanctum", vendor.covenantName or "covenant")

    if _G.AzerothWaypointNS
        and type(_G.AzerothWaypointNS.RequestManualRoute) == "function"
    then
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            vendor.vendorMapID, vendor.x, vendor.y, title, nil, nil)
        if ok and routed then
            self.state.activeRoute = { raid = raid, awpRoute = true }
            return "awp"
        end
    end

    if _G.ZygorGuidesViewer
        and _G.ZygorGuidesViewer.Pointer
        and _G.ZygorGuidesViewer.Pointer.SetWaypoint then
        _G.ZygorGuidesViewer.Pointer:SetWaypoint(vendor.vendorMapID,
            vendor.x, vendor.y, {
                findpath    = true,
                type        = "manual",
                cleartype   = true,
                title       = title,
                onminimap   = "always",
                overworld   = true,
                showonedge  = true,
            }, true)
        self.state.activeRoute = { raid = raid, zygorRoute = true }
        return "zygor"
    end

    if _G.Mapzeroth and _G.Mapzeroth.FindRoute then
        _G.Mapzeroth:FindRoute("_WAYPOINT_DESTINATION", {
            mapID  = vendor.vendorMapID,
            x      = vendor.x,
            y      = vendor.y,
            name   = title,
            source = "retroruns",
        })
        self.state.activeRoute = { raid = raid, mapzerothRoute = true }
        return "mapzeroth"
    end

    if TomTom and TomTom.AddWaypoint then
        local uid = TomTom:AddWaypoint(vendor.vendorMapID, vendor.x, vendor.y, {
            title  = title,
            from   = "RetroRuns",
            silent = true,
            crazy  = true,
        })
        self.state.activeRoute = { raid = raid, tomtomWaypoint = uid }
        return "tomtom"
    end

    if C_Map and C_Map.SetUserWaypoint and UiMapPoint then
        local point = UiMapPoint.CreateFromCoordinates(
            vendor.vendorMapID, vendor.x, vendor.y)
        C_Map.SetUserWaypoint(point)
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
        self.state.activeRoute = { raid = raid, blizzardWaypoint = true }
        return "blizzard"
    end

    self:Print("No supported waypoint API available.")
    return nil
end

--- Cancel the active nav route, if any. Behavior depends on which
--- backend was used to start the route:
---   * TomTom: removes the waypoint we set.
---   * Blizzard: clears the user waypoint.
---   * AWP: no-op. RequestManualRoute supplants whatever manual route
---     was previously active on each call, so back-to-back entrance
---     clicks replace cleanly. Like the Zygor and Mapzeroth cases,
---     `/rr cancelnav` clears our internal activeRoute marker but
---     AWP's queue/arrow keeps showing the prior route until it's
---     replaced or the user dismisses it manually.
---   * Mapzeroth: no-op. Mapzeroth manages its own route lifecycle
---     and replaces the active route on the next FindRoute call;
---     there is no separate cancel API needed for back-to-back
---     entrance clicks. (`/rr cancelnav` will clear our internal
---     activeRoute marker but Mapzeroth's GPS frame keeps showing
---     the prior route until it's replaced or the user dismisses
---     it manually.)
---   * Zygor: no-op. The cleartype=true flag we pass to ZGV.Pointer:
---     SetWaypoint on every call automatically clears prior manual
---     waypoints, so back-to-back entrance clicks replace cleanly.
---     Same caveat as Mapzeroth -- Zygor's arrow stays on screen
---     until the route is replaced or the user dismisses it.
--- Safe to call when there's no active route -- no-op in that case.
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

    -- route.awpRoute / route.mapzerothRoute / route.zygorRoute: no
    -- cleanup needed. AWP supplants the prior manual route on each
    -- RequestManualRoute call; Mapzeroth handles replacement via its
    -- internal BeginRouteNavigation; Zygor handles it via cleartype=
    -- true on every Pointer:SetWaypoint call.

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
-- Called once on ADDON_LOADED. Prints warnings for malformed raid data so
-- errors surface immediately rather than causing silent misbehaviour later.
-------------------------------------------------------------------------------

--- Walk all loaded raid data and produce a list of structural issues.
--- Each issue is a table with `severity` ("error" | "warn"), `raid` (the
--- raid display name or instanceID), and `msg` (human-readable detail).
---
--- Used by two consumers:
---   * Addon-load debug pass: filters to severity=="error" and prints
---     each via RR:Debug (no-op unless /rr debug is on).
---   * `/rr lintroute`: shows ALL issues (errors + warnings) in a copy
---     window, on-demand.
---
--- @param scopeFilter string?  When set, only lint raids whose name
---        contains this substring (case-insensitive). nil = all raids.
--- @return table   List of {severity, raid, msg} tables, in walk order.
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
                    for si, seg in ipairs(step.segments) do
                        if not seg.mapID then
                            add("error", raidLabel,
                                sp .. (" segment %d missing mapID"):format(si))
                        end
                        if not seg.kind then
                            add("error", raidLabel,
                                sp .. (" segment %d missing kind"):format(si))
                        end

                        -- Consecutive-duplicate mapID check: two segs
                        -- in a row with the same mapID is almost
                        -- always a copy-paste oversight. Legitimate
                        -- cases exist (a path that crosses an area,
                        -- exits, then re-enters) but are rare enough
                        -- that flagging gives signal worth checking.
                        if seg.mapID and prevMapID == seg.mapID then
                            add("warn", raidLabel,
                                sp .. (" segments %d and %d have the same mapID %d (intentional? or copy-paste?)"):format(
                                    si - 1, si, seg.mapID))
                        end
                        prevMapID = seg.mapID
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
    RetroRunsDB.showPanel = false

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

-- Returns per-difficulty kill counts for the current raid as
--   { [difficultyID] = { complete = N, total = M } }
-- for difficultyIDs 17 (LFR), 14 (Normal), 15 (Heroic), 16 (Mythic).
--
-- Reads via C_RaidLocks.IsEncounterComplete which queries the same
-- saved-instance cache that GetSavedInstanceInfo reads from but with
-- a per-encounter-per-difficulty API surface (no need to walk every
-- saved instance and parse out matching encounters by hand).
--
-- IsEncounterComplete needs `dungeonEncounterID` (runtime encounter
-- instance ID), not the `journalEncounterID` we store in our boss
-- data. We bridge by walking EJ_GetEncounterInfoByIndex once per
-- call (cheap; raids have ~8-12 encounters) and matching on
-- journalEncounterID.
--
-- Returns nil if no current raid loaded, no journalInstanceID known,
-- or the IsEncounterComplete API is unavailable (older clients).
-- Difficulties that the raid doesn't support (e.g. older raids
-- without LFR/Mythic) get total=0; caller decides how to render.
-- Cache for journalEncounterID -> dungeonEncounterID maps, keyed by
-- journalInstanceID. Walking EJ_GetEncounterInfoByIndex is moderately
-- expensive (server-cache lookup + per-encounter call) and the result
-- is stable for the entire WoW session, so we memoize. Cleared only
-- on /reload (since the cache lives in module-level state, not in
-- SavedVariables).
--
-- Two non-obvious requirements, both confirmed by in-game diagnostic:
--
--   1. EJ_GetEncounterInfoByIndex(i, journalInstanceID) without a
--      prior EJ_SelectInstance call silently returns nothing on
--      modern clients. The two-arg form used to work standalone; it
--      now requires the EJ to have the instance pre-selected. We
--      call EJ_SelectInstance before the walk and restore whatever
--      was previously selected so the user's open EJ view doesn't
--      yank sideways. Side-effect minimization: this only runs on
--      cache misses, which is one call per raid per session.
--
--   2. The previous version cached the result unconditionally,
--      including empty-map results. If the API ever returned nothing
--      (e.g. before the fix above, or due to a transient server-
--      cache miss), the empty {} would be cached permanently for
--      the session and every subsequent call would short-circuit
--      to it. Now: only cache non-empty results. An empty result
--      goes to the caller for THIS call but isn't memoized, so the
--      next call retries the API.
local ejMapCache = {}

local function GetEJMapForJournalInstance(journalInstanceID)
    if not journalInstanceID or journalInstanceID == 0 then return nil end
    local cached = ejMapCache[journalInstanceID]
    if cached then return cached end

    -- Save the EJ's currently-selected instance so we can put it
    -- back. EJ_GetSelectedInstance returns nil if nothing is
    -- selected; in that case we just don't restore.
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

    -- Difficulties: 17=LFR, 14=Normal, 15=Heroic, 16=Mythic. These are
    -- the modern raid difficulty IDs; older raids may not have valid
    -- kill data on all four. IsEncounterComplete handles the "doesn't
    -- apply" case by returning false, so the count stays 0.
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

    -- Active-difficulty special case: ENCOUNTER_END marks bossesKilled
    -- immediately, but the saved-instance cache that IsEncounterComplete
    -- reads from updates asynchronously (server pushes a new snapshot
    -- via UPDATE_INSTANCE_INFO some time after the kill). To make pills
    -- update in real time when the player kills a boss, the active-
    -- difficulty count uses whichever value is HIGHER -- our in-memory
    -- bossesKilled or the cache. Only applied to the currently-loaded
    -- raid + active difficulty, since for other raids we have no local
    -- kill state.
    --
    -- This fallback used to live in GetPerDifficultyKillCounts() (the
    -- no-arg "current raid" wrapper), which meant the header pill saw
    -- the immediate update but the "Where to next" panel's per-raid
    -- pills (which call this function directly per-raid) lagged until
    -- UPDATE_INSTANCE_INFO arrived. Moving it down to the shared getter
    -- keeps both render paths consistent.
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
    -- The bossesKilled-vs-cache fallback now lives inside
    -- GetPerDifficultyKillCountsForRaid (it applies whenever the queried
    -- raid is the current raid), so this wrapper is now a thin
    -- convenience for callers that don't have a raid handle.
    return self:GetPerDifficultyKillCountsForRaid(self.currentRaid)
end

-- Raid-skip account-wide unlock detection.
--
-- Per Patch 11.0.5, raid-skip quest unlocks became account-wide -- but
-- the per-character `IsQuestFlaggedCompleted(questID)` API does NOT
-- reflect that account-wide state. Use
-- `C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID)` instead, which
-- returns true if ANY character on the account has completed the quest.
--
-- Quest flags do NOT backfill: completing the Mythic skip quest on one
-- character sets the Mythic flag true on the account but leaves the
-- Heroic and Normal flags false. The cascade that lets you USE the skip
-- on lower difficulties happens at the in-game skip NPC level. The
-- cascade is downward-only -- completing X unlocks X and every easier
-- difficulty, but never anything harder. So:
--
--   * Mythic completed   -> skip available at Normal, Heroic, Mythic
--   * Heroic completed   -> skip available at Normal, Heroic
--   * Normal completed   -> skip available at Normal only
--   * Nothing completed  -> skip not available
--
-- Reading this off the API: the HIGHEST flag-true difficulty is the
-- ceiling. We don't need to OR all three to answer "is the skip
-- available?" -- if any flag is true, we know at minimum that
-- difficulty is unlocked, and (by cascade) every difficulty below.
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
-- per-lockout state (like completedSegments) on lockout reset.
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

-- Restore from persisted SavedVariable IF the lockout matches. Wipes
-- persisted state if the lockout has changed (weekly reset since last
-- save) so stale segment marks don't survive into a fresh lockout.
--
-- Schema: RetroRunsDB.completedSegments[instanceID] = {
--     lockoutId = <number>,
--     segments  = { [stepIndex] = { [segIndex] = true } },
-- }
--
-- Old (pre-0.6.1) schema was just the segments table directly under the
-- instanceID key. We migrate transparently: if the persisted value
-- doesn't have a lockoutId field, we treat it as stale and wipe (a
-- conservative call -- migration could preserve it, but we have no way
-- to know if the user's current lockout matches the unrecorded one).
function RR:RestorePersistedSegments()
    wipe(self.state.completedSegments)
    wipe(self.state.visitedMapIDs)

    if not self.currentRaid then return end
    local currentLockoutId = self:GetCurrentLockoutId()

    -- Restore completedSegments (existing behavior).
    if RetroRunsDB and RetroRunsDB.completedSegments then
        local store = RetroRunsDB.completedSegments[self.currentRaid.instanceID]
        if store then
            -- Old-schema record (no segments field) OR lockoutId mismatch:
            -- persistence is stale (different lockout, or pre-0.6.1 schema),
            -- wipe it. Initial-login wipe in PEW handles cross-WoW-session
            -- staleness; this guard handles the smaller case where a /reload
            -- happens AFTER the weekly reset rolled the lockout.
            if not store.lockoutId or store.lockoutId ~= currentLockoutId then
                RetroRunsDB.completedSegments[self.currentRaid.instanceID] = nil
            elseif store.segments then
                for stepIndex, segs in pairs(store.segments) do
                    self.state.completedSegments[stepIndex] = {}
                    for segIndex, v in pairs(segs) do
                        self.state.completedSegments[stepIndex][segIndex] = v
                    end
                end
            end
        end
    end

    -- Restore visitedMapIDs (same lockout-scoped pattern as
    -- completedSegments). Used by the seg-picker's revealAfterMapVisit
    -- gate; without restoration, /reload mid-route loses visit history
    -- and gates that should be unlocked re-lock erroneously.
    if RetroRunsDB and RetroRunsDB.visitedMapIDs then
        local store = RetroRunsDB.visitedMapIDs[self.currentRaid.instanceID]
        if store then
            if not store.lockoutId or store.lockoutId ~= currentLockoutId then
                RetroRunsDB.visitedMapIDs[self.currentRaid.instanceID] = nil
            elseif store.mapIDs then
                for mapID, v in pairs(store.mapIDs) do
                    self.state.visitedMapIDs[mapID] = v
                end
            end
        end
    end

    -- Stage the per-step visited tables for OnActiveStepChanged to
    -- consume when the next step activates. We can't restore directly
    -- into self.state.stepVisitedMapIDs here because we don't yet
    -- know which step will be active -- ComputeNextStep runs after
    -- this. Same lockout-scoped pattern as the others.
    self.state.persistedStepVisited = nil
    if RetroRunsDB and RetroRunsDB.stepVisitedMapIDs then
        local store = RetroRunsDB.stepVisitedMapIDs[self.currentRaid.instanceID]
        if store then
            if not store.lockoutId or store.lockoutId ~= currentLockoutId then
                RetroRunsDB.stepVisitedMapIDs[self.currentRaid.instanceID] = nil
            elseif store.byStep then
                self.state.persistedStepVisited = store.byStep
            end
        end
    end
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
    self:ResetStrictAdvanceGuard()
    self:SyncFromSavedRaidInfo(true)   -- request fresh server data
    self:RestorePersistedSegments()
    self:RestorePersistedStrictActiveSeg()
    self:ComputeNextStep()
    self:RefreshAll()
end

function RR:LoadCurrentRaid()
    if not self.currentRaid then return end
    self.state.loadedRaidKey = self:GetRaidContextKey()

    self:RestorePersistedSegments()
    self:RestorePersistedStrictActiveSeg()

    self:SetSetting("showPanel", true)
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

    -- Visit tracking: record the player's mapID into the in-memory
    -- visited-set AND persist to RetroRunsDB for /reload survival.
    -- Used by the seg-picker's `revealAfterMapVisit` gate (Navigation.lua),
    -- which gates a seg's display on the player having physically
    -- reached a specific mapID at some point during the current lockout.
    --
    -- Necessary because subZone-string gates (`requiresSubZone`) can be
    -- ambiguous when the same subZone string appears at multiple
    -- mapIDs along a route -- e.g. BfD's "Dazar'alor" subZone fires
    -- briefly on mapID 1352 mid-gryphon-flight AND at the post-Tandred
    -- destination on the same mapID. mapID-visit-history disambiguates
    -- these cleanly: the destination case happens AFTER the player has
    -- visited mapID 875 (the ship), the transit case happens BEFORE.
    --
    -- Persisted scoped by raid instanceID + lockoutId, same shape as
    -- completedSegments. RestorePersistedSegments handles the wipe-on-
    -- lockout-roll case for both.
    if currentMapID and self.currentRaid and self.currentRaid.instanceID then
        local wasNew = not self.state.stepVisitedMapIDs[currentMapID]
        self.state.visitedMapIDs[currentMapID] = true
        self.state.stepVisitedMapIDs[currentMapID] = true
        if wasNew then
            self:ZoneLog(("  -> stepVisitedMapIDs += %d (now: %s)"):format(
                currentMapID,
                (function()
                    local keys = {}
                    for k in pairs(self.state.stepVisitedMapIDs) do
                        table.insert(keys, tostring(k))
                    end
                    table.sort(keys)
                    return table.concat(keys, ", ")
                end)()))
        end
        local lockoutId = self:GetCurrentLockoutId()
        if lockoutId and RetroRunsDB then
            RetroRunsDB.visitedMapIDs = RetroRunsDB.visitedMapIDs or {}
            local store = RetroRunsDB.visitedMapIDs[self.currentRaid.instanceID]
            if not store or store.lockoutId ~= lockoutId then
                store = { lockoutId = lockoutId, mapIDs = {} }
                RetroRunsDB.visitedMapIDs[self.currentRaid.instanceID] = store
            end
            store.mapIDs[currentMapID] = true

            -- Persist stepVisitedMapIDs scoped by active step index.
            -- Survives /reload mid-step. Without this, the picker's
            -- strict-sequential cap loses its history on reload and
            -- falls back to seg 1's note even when the player has
            -- progressed deep into a step. Same lockoutId-scoped
            -- shape as completedSegments / visitedMapIDs.
            local activeStep = self.state.activeStep
            local activeStepIndex = activeStep and (activeStep.step or activeStep.priority)
            if activeStepIndex then
                RetroRunsDB.stepVisitedMapIDs = RetroRunsDB.stepVisitedMapIDs or {}
                local stepStore = RetroRunsDB.stepVisitedMapIDs[self.currentRaid.instanceID]
                if not stepStore or stepStore.lockoutId ~= lockoutId then
                    stepStore = { lockoutId = lockoutId, byStep = {} }
                    RetroRunsDB.stepVisitedMapIDs[self.currentRaid.instanceID] = stepStore
                end
                stepStore.byStep[activeStepIndex] = stepStore.byStep[activeStepIndex] or {}
                stepStore.byStep[activeStepIndex][currentMapID] = true
            end
        end
    end

    -- Helper: resolve mapID -> sub-zone name from the active raid's
    -- maps table, falling back to the raw ID if no name is registered.
    local mapName = function(id)
        if not id then return "(none)" end
        local raidMaps = self.currentRaid and self.currentRaid.maps
        local n = raidMaps and raidMaps[id]
        if n then return ("%s (%d)"):format(n, id) end
        return ("mapID %d"):format(id)
    end
    -- DEBUG (remove once segment-completion is verified working):
    local zoneText    = (GetZoneText and GetZoneText())       or ""
    local subZoneText = (GetSubZoneText and GetSubZoneText()) or ""
    local minimapText = (GetMinimapZoneText and GetMinimapZoneText()) or ""
    self:ZoneLog(("HLC fired. prev=%s curr=%s | zone=%q subZone=%q minimap=%q")
        :format(mapName(previousMapID), mapName(currentMapID),
                zoneText, subZoneText, minimapText))

    -- Helper: does this seg's `requiresSubZone` (if any) match the
    -- player's current sub-zone? Used by both the cross-mapID and the
    -- deferred-within-mapID completion paths below.
    --
    -- Why this exists: WoW's GetSubZoneText() can return the parent
    -- raid name ("The Eternal Palace") during transit through unnamed
    -- portions of a sub-zone map -- e.g. swimming through the
    -- underwater corridor between Sivara's Dais and the named "Halls
    -- of the Chosen" interior, both of which live on mapID 1513. The
    -- mapID transition (1512 -> 1513) fires the moment the player
    -- crosses into the underwater portion, but the player isn't
    -- semantically "in Halls of the Chosen" yet -- they're still
    -- transiting. requiresSubZone defers seg-completion until the
    -- sub-zone actually matches.
    --
    -- Opt-in only: segments without requiresSubZone behave exactly
    -- as before (no sub-zone check). This keeps the change surgical
    -- to the segments that need it.
    local function subZoneRequirementMet(seg)
        if not seg or not seg.requiresSubZone then return true end
        return seg.requiresSubZone == subZoneText
    end

    if currentMapID and previousMapID and currentMapID ~= previousMapID then
        local step = self.state.activeStep
        if step and step.segments then
            local stepIndex = step.step or step.priority or 0
            self:ZoneLog(("mapID changed; active step=%s, looking for forward seg %s -> %s")
                :format(tostring(stepIndex),
                        mapName(previousMapID), mapName(currentMapID)))
            -- Route-aware segment-completion. Marks seg N complete only
            -- if seg N's mapID matches the previous mapID AND seg N+1's
            -- mapID matches the new mapID. This is the "did the player
            -- legitimately progress from seg N to seg N+1" check. It
            -- defeats two failure modes the simpler "mark first
            -- incomplete on previous mapID" rule had:
            --   1. Backtracks. Walking 2124->2122 after already
            --      progressing through seg 2 (mapID 2122) used to
            --      over-mark seg 4 (also 2122). With this rule, the
            --      backtrack only matches if seg 2's successor (seg 3)
            --      has mapID currentMapID; seg 4's successor doesn't
            --      exist, so seg 4 never gets marked here.
            --   2. Same-mapID multi-segment ordering. The simpler rule
            --      always picked the earliest incomplete; this rule
            --      requires both endpoints to align with the route
            --      sequence, so it picks the right one or none.
            -- The LAST segment of any step never matches this rule
            -- (no successor to check against). It gets marked by
            -- ENCOUNTER_END for the boss instead.
            --
            -- Sub-zone gating (v1.2): if seg N+1 has requiresSubZone,
            -- the player must already be in that sub-zone for the
            -- completion to fire. If they're not (e.g. mid-transit
            -- through a parent-zone-fallback portion), the completion
            -- is deferred to the second loop below, which fires on
            -- sub-zone-change events.
            --
            -- ORDERING NOTE: this completion loop runs BEFORE
            -- AdvanceStrictActiveSeg (below) so the strict advancer
            -- sees updated completedSegments state. Critical for the
            -- gate-seg case: AdvanceStrictActiveSeg refuses to advance
            -- past an uncompleted gate seg (advanceOn predicate), and
            -- the cross-mapID transit IS what completes that gate seg.
            -- If the strict advancer ran first, it would see the gate
            -- uncompleted, short-circuit, and the activeSeg pointer
            -- would never advance past the gate.
            for segIndex, seg in ipairs(step.segments) do
                local completed = self:IsSegmentCompleted(stepIndex, segIndex)
                local segSubZone = seg.subZone or "(none)"
                self:ZoneLog(("  seg %d: %s subZone=%q completed=%s")
                    :format(segIndex, mapName(seg.mapID),
                            segSubZone, tostring(completed)))
                if seg.mapID == previousMapID and not completed then
                    local nextSeg = step.segments[segIndex + 1]
                    if nextSeg and nextSeg.mapID == currentMapID then
                        if subZoneRequirementMet(nextSeg) then
                            self:ZoneLog(("  -> marking seg %d complete (next seg's mapID matches)")
                                :format(segIndex))
                            self:MarkSegmentCompleted(stepIndex, segIndex)
                            break
                        else
                            self:ZoneLog(("  -> deferring seg %d completion: next seg requiresSubZone=%q, current=%q")
                                :format(segIndex, nextSeg.requiresSubZone, subZoneText))
                        end
                    end
                end
            end
        else
            self:ZoneLog("mapID changed but no active step or no segments")
        end

        -- Strict-activeSeg advancement hook (v1.6+, generalized in
        -- v1.7): for raids opting in via useStrictActiveSegPicker,
        -- the activeSeg-based picker advances on mapID transitions.
        -- The function itself is predicated internally via
        -- UsesStrictActiveSegPicker, so this hook is a no-op for
        -- legacy raids. See Data/StrictPicker.lua for the model.
        -- Runs AFTER the cross-mapID completion loop so gate-seg
        -- completion is visible to the advancer's gate-respect check.
        self:AdvanceStrictActiveSeg(currentMapID)
    end

    -- Deferred-completion path: fires on sub-zone change WITHIN the
    -- same mapID (mapID unchanged since last HLC, but ZONE_CHANGED or
    -- ZONE_CHANGED_INDOORS fired due to the player crossing into a
    -- newly-named sub-zone). Catches the case where the cross-mapID
    -- loop above deferred a completion because of requiresSubZone --
    -- once the sub-zone finally matches, fire the deferral.
    --
    -- Detection without persistent "deferred" state: walk segments
    -- looking for pairs where seg N's mapID differs from currentMapID
    -- AND seg N+1's mapID matches currentMapID AND seg N+1 has
    -- requiresSubZone matching the current sub-zone AND seg N is
    -- still incomplete. Implies the player is in the post-transition
    -- mapID with the right sub-zone, and the prior seg is what should
    -- have completed at the original mapID transition.
    if currentMapID and previousMapID and currentMapID == previousMapID then
        local step = self.state.activeStep
        if step and step.segments then
            local stepIndex = step.step or step.priority or 0
            for segIndex, seg in ipairs(step.segments) do
                local completed = self:IsSegmentCompleted(stepIndex, segIndex)
                if not completed then
                    local nextSeg = step.segments[segIndex + 1]
                    if nextSeg
                        and nextSeg.mapID == currentMapID
                        and seg.mapID ~= currentMapID
                        and nextSeg.requiresSubZone
                        and nextSeg.requiresSubZone == subZoneText
                    then
                        self:ZoneLog(("  -> deferred-fire: marking seg %d complete (subZone=%q now matches)")
                            :format(segIndex, subZoneText))
                        self:MarkSegmentCompleted(stepIndex, segIndex)
                        break
                    end
                end
            end
        end
    end

    -- SubZone-trigger advancement (segments with advanceOn=subZone).
    -- Independent from the requiresSubZone / deferred-completion path
    -- above: requiresSubZone gates a PRIOR seg's completion on subZone
    -- match (the seg you're leaving needs subZone to be right before
    -- being marked complete). advanceOn=subZone is the inverse: it
    -- triggers advancement TO a seg whose mapID matches the player's
    -- but isn't reachable via mapID-change advancement because the
    -- previous seg shares the mapID. Imonar's warframe-fly seg 2
    -- (mapID 909, no subZone) -> seg 3 (mapID 909, subZone "Broken
    -- Cliffs") is the canonical case.
    --
    -- Called unconditionally; the function self-gates on "is there
    -- an active step with an advanceOn=subZone seg matching the
    -- current subZone?" so the call is cheap for raids/steps without
    -- this pattern.
    self:CheckSubZoneTriggers(subZoneText)

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
            -- different difficulty). Wipe in-memory raid state before
            -- showing the load popup, otherwise the new raid would
            -- inherit bossesKilled and completedSegments from the
            -- previous raid -- which are bossIndex-keyed without raid
            -- scoping, so they collide. SyncFromSavedRaidInfo's
            -- removal-rejection guard (defeats saved-instance cache
            -- hiccups mid-session) would otherwise refuse to clear
            -- the stale data when the new raid's cache reports no
            -- kills.
            --
            -- This wipes IN-MEMORY state only -- SavedVariable
            -- (RetroRunsDB.completedSegments) persists across raid
            -- contexts and is restored in LoadCurrentRaid for the
            -- raid the user opts into via the popup.
            wipe(self.state.bossesKilled)
            wipe(self.state.completedSegments)
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
        wipe(self.state.completedSegments)
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
    wipe(self.state.completedSegments)
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
        wipe(self.state.completedSegments)
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
-- TravelDebug: snapshot of the inputs the travel-pane renderer uses to
-- pick which segment's note to display. Read-only diagnostic, opens a
-- copy window with the result.
--
-- For each step (active step plus any candidate next-steps), prints:
--   - playerMapID  (what C_Map.GetBestMapForUnit("player") returns)
--   - worldMapID   (what WorldMapFrame:GetMapID() returns -- only when
--                   the world map is open)
--   - chosenMapID  (what UI.GetBestMapForStep returns -- the mapID the
--                   renderer would compare segments against)
--   - segments     (per-seg mapID, has-note, completed-flag)
--
-- Used for "why is the travel pane showing the wrong segment's note?"
-- diagnosis. The renderer matches segments against chosenMapID; if no
-- segment's mapID matches it, the renderer falls back to the seg[1]
-- note prefixed with "(Open map for directions)". This dump exposes
-- the inputs so the cause is obvious from one snapshot.
-------------------------------------------------------------------------------
function RR:TravelDebug()
    local out = {}
    local function add(s) table.insert(out, s or "") end

    add("traveldebug: snapshot of travel-pane renderer state")
    add("")

    -- Raw inputs (independent of any specific step)
    local playerMapID = C_Map and C_Map.GetBestMapForUnit
                        and C_Map.GetBestMapForUnit("player")
    local worldMapID
    if WorldMapFrame and WorldMapFrame.GetMapID then
        worldMapID = WorldMapFrame:GetMapID()
    end
    add(("Raw inputs:"))
    add(("  C_Map.GetBestMapForUnit(\"player\")  = %s"):format(tostring(playerMapID)))
    add(("  WorldMapFrame:GetMapID()             = %s  <-- this is what the map renderer uses"):format(
        tostring(worldMapID)))
    add("")

    -- World map open / visible state
    local mapOpen = WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()
    add(("WorldMapFrame visible: %s"):format(tostring(mapOpen)))
    add("")

    if not self.currentRaid then
        add("No raid loaded.")
        self:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr traveldebug|r",
            table.concat(out, "\n"))
        return
    end

    add(("Raid: %s"):format(self.currentRaid.name or "?"))

    -- Active step (what the renderer is currently displaying)
    local active = self.state and self.state.activeStep
    if not active then
        add("activeStep: nil")
    else
        add(("activeStep: step=%s title=%q"):format(
            tostring(active.step), active.title or ""))
    end
    add("")

    -- Iterate every step in the raid's routing array. For each, dump
    -- what mapID the renderer would pick if that step were active, and
    -- the per-segment table. The active step is flagged with "*".
    local routing = self.currentRaid.routing
    if not routing or #routing == 0 then
        add("No routing data for this raid.")
    else
        for _, step in ipairs(routing) do
            local marker = (active and active.step == step.step) and "* " or "  "
            local chosenMapID
            if RR.UI and RR.UI.GetBestMapForStep then
                chosenMapID = RR.UI.GetBestMapForStep(step)
            end
            add(("%sstep=%s priority=%s bossIndex=%s title=%q"):format(
                marker,
                tostring(step.step),
                tostring(step.priority),
                tostring(step.bossIndex),
                step.title or "?"))
            add(("    chosenMapID = %s  (used by travel-pane text)"):format(tostring(chosenMapID)))
            -- The MAP RENDERER uses worldMapID, not chosenMapID. Show
            -- which seg(s) would draw on the currently-open world map.
            if worldMapID then
                local relevant = self:GetRelevantSegmentsForMap(step, worldMapID)
                if #relevant > 0 then
                    local segIdxs = {}
                    for i, seg in ipairs(step.segments) do
                        for _, r in ipairs(relevant) do
                            if r == seg then table.insert(segIdxs, tostring(i)) end
                        end
                    end
                    add(("    map renderer would draw seg(s) [%s] on world map %s"):format(
                        table.concat(segIdxs, ","), tostring(worldMapID)))
                else
                    add(("    map renderer: no segs match world map %s"):format(
                        tostring(worldMapID)))
                end
            end
            if step.segments then
                for i, seg in ipairs(step.segments) do
                    local completed = self:IsSegmentCompleted(step.step or 0, i)
                    local matches = (chosenMapID == seg.mapID) and " <-- matches chosen" or ""
                    add(("    seg %d: mapID=%s kind=%-9s note=%s completed=%-5s%s"):format(
                        i,
                        tostring(seg.mapID),
                        tostring(seg.kind or "path"),
                        seg.note and "yes" or "no ",
                        tostring(completed),
                        matches))
                end
            else
                add("    (no segments)")
            end
            add("")
        end
    end

    add("Legend: chosenMapID is what the renderer compares segment mapIDs against.")
    add("If no segment's mapID matches, the renderer falls back to seg[1]'s note")
    add("with an \"(Open map for directions)\" prefix.")

    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr traveldebug|r",
        table.concat(out, "\n"))
    self:Print("traveldebug snapshot opened.")
end

-------------------------------------------------------------------------------
-- Toggle-probe diagnostic (dev-only; not user-facing)
--
-- Diagnoses the "Run complete!" + button click bug: in that state the
-- expansion-toggle "+" buttons in the supported-raids list go dead to
-- clicks (work fine in idle state). The fix path needs to identify
-- whether something is intercepting clicks or whether the buttons
-- themselves are misconfigured.
--
-- This probe dumps everything needed to identify the culprit:
--   1. Each panel.expansionToggleButtons[i] -- IsShown / IsMouseEnabled /
--      OnClick script set / FrameLevel / anchor point / size
--   2. Body-element frames that could overlap (encounter, transmog, list,
--      listHeader, etc.) -- IsShown / IsMouseEnabled / FrameLevel / size
--   3. GetMouseFocus() at the moment the probe runs -- so the user can
--      hover a + glyph and run /rr toggleprobe to see what frame the
--      mouse is actually over (the toggle button, or something else?)
--
-- Output goes to ShowCopyWindow. Run via /rr toggleprobe.
-------------------------------------------------------------------------------
function RR:ToggleProbe()
    local out = {}
    local function add(s) table.insert(out, s or "") end

    add("toggleprobe: expansion-toggle button + intercepting-frame state")
    add("Hover the + glyph BEFORE running this for GetMouseFocus to be useful.")
    add("")

    -- Resolve panel via UI namespace's known reference
    local panel = _G.RetroRunsMainFrame
    if not panel then
        add("ERROR: _G.RetroRunsMainFrame not found.")
        self:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr toggleprobe|r",
            table.concat(out, "\n"))
        return
    end

    add(("Panel: shown=%s, FrameLevel=%s, strata=%s"):format(
        tostring(panel:IsShown()),
        tostring(panel:GetFrameLevel()),
        tostring((panel.GetFrameStrata and panel:GetFrameStrata()) or "n/a")))
    do
        local pL, pB = panel:GetLeft(), panel:GetBottom()
        local pW, pH = panel:GetWidth() or 0, panel:GetHeight() or 0
        if pL and pB then
            add(("Panel screen: L%.0f B%.0f W%.0f H%.0f (top=%.0f, right=%.0f)"):format(
                pL, pB, pW, pH, pB + pH, pL + pW))
        end
    end
    -- Cursor position. If the user hovered a + before running the probe,
    -- this tells us exactly where on screen the mouse was, which we can
    -- cross-reference against the toggle buttons' screen rectangles to
    -- see whether the click hit area is where the visible glyph is.
    if GetCursorPosition then
        local cx, cy = GetCursorPosition()
        if cx and cy then
            local scale = UIParent and UIParent:GetEffectiveScale() or 1
            add(("Cursor: raw=(%d,%d) UIParent-scaled=(%.0f,%.0f)"):format(
                cx, cy, cx / scale, cy / scale))
        end
    end
    add("")

    -- Section 1: Expansion toggle buttons
    add("=== panel.expansionToggleButtons ===")
    local toggles = panel.expansionToggleButtons or {}
    add(("Count: %d"):format(#toggles))
    for i, btn in ipairs(toggles) do
        local pt, relTo, relPt, x, y = btn:GetPoint(1)
        local relName = "?"
        if relTo and relTo.GetName then relName = relTo:GetName() or "(unnamed)" end
        if relTo and not (relTo.GetName and relTo:GetName()) then
            local rl, rb, rw, rh = relTo:GetLeft(), relTo:GetBottom(),
                                   relTo:GetWidth() or 0, relTo:GetHeight() or 0
            if rl and rb then
                relName = ("FS(L=%.0f B=%.0f W=%.0f H=%.0f)"):format(
                    rl, rb, rw, rh)
            else
                relName = "FS(off-screen-or-nil-coords)"
            end
        end
        local hasOnClick     = (btn:GetScript("OnClick")     ~= nil)
        local hasOnMouseDown = (btn:GetScript("OnMouseDown") ~= nil)
        local hasOnMouseUp   = (btn:GetScript("OnMouseUp")   ~= nil)
        local hasOnEnter     = (btn:GetScript("OnEnter")     ~= nil)
        local isEnabled      = btn.IsEnabled and btn:IsEnabled()
        local L, B = btn:GetLeft(), btn:GetBottom()
        local W, H = btn:GetWidth() or 0, btn:GetHeight() or 0
        local screenInfo
        if L and B then
            screenInfo = ("screen=L%.0f,B%.0f,W%.0f,H%.0f (top=%.0f,right=%.0f)"):format(
                L, B, W, H, B + H, L + W)
        else
            screenInfo = "screen=NIL-COORDS"
        end
        local strata = (btn.GetFrameStrata and btn:GetFrameStrata()) or "n/a"
        -- GetButtonState: "NORMAL" / "PUSHED" / "DISABLED"
        local btnState = "n/a"
        if btn.GetButtonState then btnState = btn:GetButtonState() end
        -- GetRegisteredClickTypes returns nil on older clients; use pcall
        -- to defensively check whether it's available. Fall back to a
        -- reasonable label if not.
        local regClicks = "?"
        if btn.GetRegisteredClickTypes then
            local ok, rc = pcall(btn.GetRegisteredClickTypes, btn)
            if ok and rc then regClicks = tostring(rc) end
        end
        add(("  [%d] shown=%s mouse=%s enabled=%s state=%s onclick=%s mdn=%s mup=%s onent=%s strata=%s level=%s regClicks=%s"):format(
            i,
            tostring(btn:IsShown()),
            tostring(btn:IsMouseEnabled()),
            tostring(isEnabled),
            btnState,
            tostring(hasOnClick),
            tostring(hasOnMouseDown),
            tostring(hasOnMouseUp),
            tostring(hasOnEnter),
            strata,
            tostring(btn:GetFrameLevel()),
            regClicks))
        add(("       anchor=%s->%s:%s(%g,%g)"):format(
            tostring(pt), relName, tostring(relPt), x or 0, y or 0))
        add(("       %s"):format(screenInfo))
    end
    add("")

    -- Section 1.5: All Frame children of the panel, sorted by FrameLevel.
    -- If there's an invisible overlay frame at FrameLevel >= 11 covering
    -- the button area but with mouse=true and no visible texture, it
    -- would intercept clicks while leaving hover/push textures on the
    -- button below untouched (since those track screen mouse position
    -- directly via the button's enter/leave region scripts, not via
    -- click dispatch).
    add("=== Panel child Frames (by FrameLevel descending) ===")
    -- Build a reverse-lookup table mapping known panel members to a
    -- human-readable name. When we walk panel:GetChildren() we'll
    -- check each child against this table and surface the friendly
    -- name. Helps identify the "unnamed" 392x1 button that only
    -- exists in run-complete state.
    local memberName = {
        [panel.closeButton or 0]    = "panel.closeButton",
        [panel.minimizeButton or 0] = "panel.minimizeButton",
        [panel.encounter or 0]      = "panel.encounter",
        [panel.transmog or 0]       = "panel.transmog",
        [panel.mapBtn or 0]         = "panel.mapBtn",
        [panel.tmogBtn or 0]        = "panel.tmogBtn",
        [panel.achievesBtn or 0]    = "panel.achievesBtn",
        [panel.skipsBtn or 0]       = "panel.skipsBtn",
        [panel.settingsBtn or 0]    = "panel.settingsBtn",
    }
    -- Also tag every active expansion-toggle and entrance button
    for i, b in ipairs(panel.expansionToggleButtons or {}) do
        memberName[b] = ("toggle[%d]"):format(i)
    end
    for i, b in ipairs(panel.entranceButtons or {}) do
        memberName[b] = ("entrance[%d]"):format(i)
    end
    -- And pool entries (these are inactive but still parented to panel)
    for i, b in ipairs(panel.expansionToggleButtonPool or {}) do
        memberName[b] = ("togglePool[%d]"):format(i)
    end
    for i, b in ipairs(panel.entranceButtonPool or {}) do
        memberName[b] = ("entrancePool[%d]"):format(i)
    end

    local children = { panel:GetChildren() }
    local childList = {}
    for _, c in ipairs(children) do
        if c.GetFrameLevel then
            table.insert(childList, {
                tag = memberName[c] or "(unidentified)",
                level = c:GetFrameLevel(),
                shown = c:IsShown(),
                mouse = c.IsMouseEnabled and c:IsMouseEnabled() or false,
                L = c:GetLeft(), B = c:GetBottom(),
                W = c:GetWidth() or 0, H = c:GetHeight() or 0,
                otype = (c.GetObjectType and c:GetObjectType()) or "?",
                frame = c,
            })
        end
    end
    table.sort(childList, function(a, b) return a.level > b.level end)
    add(("Total children: %d"):format(#childList))
    for _, c in ipairs(childList) do
        local screen = "no-coords"
        if c.L and c.B then
            screen = ("L%.0f,B%.0f,W%.0f,H%.0f"):format(c.L, c.B, c.W, c.H)
        end
        add(("  level=%-3d type=%-8s shown=%-5s mouse=%-5s %s   <- %s"):format(
            c.level, c.otype,
            tostring(c.shown), tostring(c.mouse), screen, c.tag))
    end
    add("")

    -- Section 2: Potentially intercepting body frames. Anything that's a
    -- Button child of panel and could overlap the toggle button area is
    -- a candidate. We list known suspects explicitly with their full state.
    add("=== Potentially intercepting body frames ===")
    local suspects = {
        { name = "panel.encounter",  frame = panel.encounter  },
        { name = "panel.transmog",   frame = panel.transmog   },
        { name = "panel.next",       frame = panel.next       },
        { name = "panel.travel",     frame = panel.travel     },
        { name = "panel.progress",   frame = panel.progress   },
        { name = "panel.raid",       frame = panel.raid       },
        { name = "panel.pills",      frame = panel.pills      },
        { name = "panel.listHeader", frame = panel.listHeader },
        { name = "panel.list",       frame = panel.list       },
    }
    for _, s in ipairs(suspects) do
        local f = s.frame
        if not f then
            add(("  %s: nil"):format(s.name))
        else
            local mouseEnabled = "n/a"
            if f.IsMouseEnabled then
                mouseEnabled = tostring(f:IsMouseEnabled())
            end
            local frameLevel = "n/a"
            if f.GetFrameLevel then
                frameLevel = tostring(f:GetFrameLevel())
            end
            add(("  %s: shown=%s mouse=%s level=%s size=%dx%d"):format(
                s.name,
                tostring(f:IsShown()),
                mouseEnabled,
                frameLevel,
                math.floor((f.GetWidth and f:GetWidth()) or 0),
                math.floor((f.GetHeight and f:GetHeight()) or 0)))
        end
    end
    add("")

    -- Section 2.5: State + render-path diagnostic. The OnClick handler
    -- writes to RR.state.expandedExpansions; BuildIdleListRows reads
    -- from it. Dump the current state so we can see (a) whether clicks
    -- are landing on the state at all, and (b) what state the render
    -- path is seeing.
    add("=== RR.state.expandedExpansions ===")
    local exp = RR.state and RR.state.expandedExpansions
    if not exp then
        add("  RR.state.expandedExpansions is nil or RR.state is nil")
    elseif next(exp) == nil then
        add("  {} (empty -- no expansion is currently marked expanded)")
    else
        for k, v in pairs(exp) do
            add(("  [%s] = %s"):format(tostring(k), tostring(v)))
        end
    end
    add("")

    -- Section 3: GetMouseFocus -- what frame is the mouse over right now?
    add("=== GetMouseFocus() at probe time ===")
    local focus = GetMouseFocus and GetMouseFocus()
    if not focus then
        add("  GetMouseFocus() returned nil. (No frame under cursor, or cursor")
        add("  over a non-mouse-enabled area. Hover a + glyph first, then run")
        add("  /rr toggleprobe again.)")
    else
        local focusName = (focus.GetName and focus:GetName()) or "(unnamed)"
        add(("  Focus frame name: %s"):format(focusName))
        add(("  Focus frame type: %s"):format(focus.GetObjectType and focus:GetObjectType() or "?"))
        if focus.GetFrameLevel then
            add(("  Focus frame level: %s"):format(tostring(focus:GetFrameLevel())))
        end
        -- Check if focus is one of our toggle buttons
        local matchedToggle = false
        for i, btn in ipairs(toggles) do
            if focus == btn then
                add(("  -> Focus IS panel.expansionToggleButtons[%d] (the toggle button itself)"):format(i))
                matchedToggle = true
                break
            end
        end
        if not matchedToggle then
            -- Check known suspects
            for _, s in ipairs(suspects) do
                if focus == s.frame then
                    add(("  -> Focus is %s (intercepting the click)"):format(s.name))
                    break
                end
            end
        end
        -- Walk parent chain so we see frame hierarchy context
        add("  Parent chain:")
        local p = focus.GetParent and focus:GetParent()
        local depth = 0
        while p and depth < 10 do
            local pname = (p.GetName and p:GetName()) or "(unnamed)"
            add(("    -> %s"):format(pname))
            p = p.GetParent and p:GetParent()
            depth = depth + 1
        end
    end

    self:ShowCopyWindow(
        "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaa/rr toggleprobe|r",
        table.concat(out, "\n"))
    self:Print("toggleprobe snapshot opened.")
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
            bucket_mismatch = 0,   -- E5: sourceID lives in wrong difficulty slot per its itemLink's itemContext
            coverage_gap    = 0,   -- E6: EJ exposes more sourceIDs for this item-at-this-diff than we shipped
            missing_item    = 0,   -- E7: EJ exposes an item at this boss that's not in our data
            e5_checked      = 0,   -- diagnostic: how many bucket slots actually got the E5 itemContext check
            e5_skipped      = 0,   -- diagnostic: how many slots E5 skipped (no link, or unknown context)
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
                    local perBucket = {}  -- [diffID] = {src, apiItemID, visualID, apiNil, itemLink}
                    for _, diffID in ipairs(DIFFS) do
                        local src = item.sources and item.sources[diffID]
                        if src then
                            local info = C_TransmogCollection.GetSourceInfo(src)
                            local apiItemID, visualID, apiNil, itemLink
                            if info then
                                apiItemID = info.itemID
                                itemLink  = info.itemLink
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
                                itemLink = itemLink,
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

                    -- [E5] Difficulty-bucket mismatch via itemContext.
                    --
                    -- Each EJ-generated item link carries an
                    -- itemContext value (the 12th option in the
                    -- hyperlink). The harvester uses this as its
                    -- primary signal to decide which difficulty
                    -- bucket a sourceID belongs to. So if a source
                    -- in our `[16]=N` (Mythic) slot has an itemLink
                    -- whose itemContext maps to LFR, that's a
                    -- bucket-assignment bug -- the source is in
                    -- the wrong slot.
                    --
                    -- Caveats:
                    --  - Only checked when info.itemLink was non-nil
                    --    AND ParseItemContextFromLink yielded a
                    --    recognized context. Items with no link
                    --    or context=0 (UNKNOWN) get skipped silently
                    --    -- not actionable, just unverifiable.
                    --  - Some items legitimately have ambiguous
                    --    itemContexts (very old raids may use modID
                    --    instead). Those skip silently rather than
                    --    flag false positives.
                    if RR.ParseItemContextFromLink and RR.ITEM_CONTEXT_TO_DIFFICULTY then
                        for _, diffID in ipairs(DIFFS) do
                            local b = perBucket[diffID]
                            if b and b.itemLink then
                                local ctx = RR.ParseItemContextFromLink(b.itemLink)
                                local apiDiff = RR.ITEM_CONTEXT_TO_DIFFICULTY[ctx]
                                if apiDiff then
                                    T.e5_checked = T.e5_checked + 1
                                    if apiDiff ~= diffID then
                                        table.insert(findings, ("[ERR] %s src=%d: itemContext=%d says difficulty=%s, but lives in %s slot"):format(
                                            DIFF_NAME[diffID], b.src, ctx,
                                            DIFF_NAME[apiDiff] or tostring(apiDiff),
                                            DIFF_NAME[diffID]))
                                        T.bucket_mismatch = (T.bucket_mismatch or 0) + 1
                                    end
                                else
                                    T.e5_skipped = T.e5_skipped + 1
                                end
                            elseif b then
                                T.e5_skipped = T.e5_skipped + 1
                            end
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
            add("harvester-skip class of bug that E1-E5 cannot see.")
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
            add(("  [ERR] bucket-slot mismatches:  %d (E5 checked %d slot(s), skipped %d)"):format(
                T.bucket_mismatch, T.e5_checked, T.e5_skipped))
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
            add("  E5 'checked N, skipped M': checked = itemContext was")
            add("        present and decoded; skipped = no itemLink or")
            add("        unknown context. A clean bucket_mismatch=0 with")
            add("        e5_checked=0 means E5 never had data to verify")
            add("        against (binary-shape items can't trigger E5).")
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

    elseif cmd == "pickerstate" then
        -- Diagnostic dump of strict-activeSeg picker state. Use when the
        -- travel pane shows "Open the map..." fallback in a raid that
        -- opted in via useStrictActiveSegPicker -- typically caused by
        -- activeSeg pointing past end of step.segments, or by the
        -- picker dispatch not routing to StrictPicker for some reason.
        local lines = {}
        local function add(s) lines[#lines + 1] = s end
        local raid = RR.currentRaid
        add("== Strict-activeSeg Picker State ==")
        add(("currentRaid: %s (instanceID=%s)"):format(
            tostring(raid and raid.name or "(none)"),
            tostring(raid and raid.instanceID or "(none)")))
        add(("UsesStrictActiveSegPicker: %s"):format(
            tostring(RR:UsesStrictActiveSegPicker())))
        add(("playerMapID (real-time): %s"):format(
            tostring(C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or "(api missing)")))
        add(("state.lastPlayerMapID:    %s"):format(tostring(RR.state and RR.state.lastPlayerMapID)))
        local s = RR.state and RR.state.activeStep
        if s then
            add("")
            add(("activeStep: step=%s priority=%s title=%q"):format(
                tostring(s.step), tostring(s.priority), tostring(s.title)))
            local stepIndex = s.step or s.priority or 0
            local activeSeg = RR:GetStrictActiveSeg(stepIndex)
            add(("activeSeg for step %d: %d"):format(stepIndex, activeSeg))
            if s.segments then
                add(("step.segments: %d entries"):format(#s.segments))
                for i, seg in ipairs(s.segments) do
                    local notePreview = seg.note and seg.note:sub(1, 60) or "(no note)"
                    add(("  seg %d: mapID=%s note=%q"):format(i, tostring(seg.mapID), notePreview))
                end
                local pickedSeg = RR:PickStrictNoteSeg(s, RR.state.lastPlayerMapID)
                if pickedSeg then
                    add(("PickStrictNoteSeg returned: seg with mapID=%s, note=%q"):format(
                        tostring(pickedSeg.mapID),
                        tostring(pickedSeg.note and pickedSeg.note:sub(1, 60) or "(no note)")))
                else
                    add("PickStrictNoteSeg returned: nil")
                end
            else
                add("step.segments: NIL")
            end
        else
            add("activeStep: (none)")
        end
        add("")
        add("== Persisted strictActiveSeg ==")
        if RetroRunsDB and RetroRunsDB.strictActiveSeg then
            for instID, instStore in pairs(RetroRunsDB.strictActiveSeg) do
                add(("instanceID %s:"):format(tostring(instID)))
                -- Pre-faction-scoped legacy shape (lockoutId/activeSegs at
                -- top level). Printed for diagnostic visibility but new
                -- writes will migrate this away.
                if instStore.lockoutId ~= nil or instStore.activeSegs ~= nil then
                    add(("  [LEGACY pre-faction shape] lockoutId=%s"):format(
                        tostring(instStore.lockoutId)))
                    if instStore.activeSegs then
                        for stepIdx, seg in pairs(instStore.activeSegs) do
                            add(("    step %d activeSeg = %d"):format(stepIdx, seg))
                        end
                    end
                else
                    for faction, factionStore in pairs(instStore) do
                        add(("  [%s] lockoutId=%s"):format(
                            tostring(faction), tostring(factionStore.lockoutId)))
                        if factionStore.activeSegs then
                            for stepIdx, seg in pairs(factionStore.activeSegs) do
                                add(("    step %d activeSeg = %d"):format(stepIdx, seg))
                            end
                        end
                    end
                end
            end
        else
            add("(empty)")
        end
        RR:ShowCopyWindow("RetroRuns -- Strict-activeSeg Picker State", table.concat(lines, "\n"))

    elseif cmd == "zonelog" then
        -- Diagnostic dump of the in-memory zone-change log. Used to
        -- investigate segment-completion behavior on cross-mapID
        -- transitions inside raid instances.
        local buf = RR.state.zoneLog or {}
        if #buf == 0 then
            RR:Print("Zone log is empty. Move between sub-zones to populate it.")
        else
            RR:ShowCopyWindow("RetroRuns -- Zone Log",
                table.concat(buf, "\n"))
        end

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
        -- Clear persisted segment-completion state for the CURRENT raid.
        -- Use when a backtrack or other quirk has left a segment marked
        -- complete that shouldn't be -- the renderer's "earliest
        -- incomplete on current mapID" picker then surfaces the wrong
        -- segment (or nothing at all if all segs on a mapID get marked
        -- complete). Scoped to the current raid; other raids' persisted
        -- segment state is preserved.
        --
        -- Also clears the in-memory zonelog ring buffer. Resetting
        -- segments is almost always done as part of a diagnostic
        -- session, where the next thing the user wants to see is a
        -- clean zonelog showing only the events triggered by the
        -- post-reset walk -- not the stale entries from before the
        -- reset. Wiping the zonelog here removes the manual mental
        -- timestamp-filtering step.
        if not RR.currentRaid then
            RR:Print("No raid loaded. Zone into a supported raid first.")
        else
            wipe(RR.state.completedSegments)
            if RetroRunsDB and RetroRunsDB.completedSegments then
                RetroRunsDB.completedSegments[RR.currentRaid.instanceID] = nil
            end
            wipe(RR.state.zoneLog)
            RR.UI.Update()
            if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
            RR:Print(("Segment state cleared for %s. (zonelog also wiped)"):format(RR.currentRaid.name))
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

    elseif cmd == "probelockout" then
        -- Probe GetSavedInstanceEncounterInfo's return shape on retail.
        -- Wowpedia documents the signature as:
        --   bossName, fileDataID, isKilled, unknown4 = GetSavedInstanceEncounterInfo(i, e)
        -- but labels the 4th return as "unknown4". This probe dumps all
        -- four returns for every encounter of every saved instance so we
        -- can verify whether unknown4 is the dungeonEncounterID (which
        -- would let us close the lockout-cache locale-independence gap)
        -- or something else entirely.
        --
        -- For currently-loaded raid context: we also cross-reference
        -- each unknown4 value against the EJ map (journalEncounterID ->
        -- dungeonEncounterID) for the same raid. A match across all
        -- encounters confirms unknown4 IS the dungeonEncounterID.
        --
        -- Output: ShowCopyWindow, since chat truncation would shred the
        -- per-encounter table.
        local lines = {}
        local function add(s) table.insert(lines, s) end

        add("probelockout: dumping all four returns of GetSavedInstanceEncounterInfo")
        add("for every saved instance, for every encounter.")
        add("")
        add("Wowpedia signature:")
        add("  bossName, fileDataID, isKilled, unknown4 = GetSavedInstanceEncounterInfo(i, e)")
        add("")
        add("Goal: identify what 'unknown4' actually contains. If it matches")
        add("the dungeonEncounterID (cross-referenced with the EJ map for")
        add("the currently-loaded raid), we can use it as the primary kill-")
        add("resolution key in SyncFromSavedRaidInfo and close the locale-")
        add("independence gap that bit us on Eonar.")
        add("")

        local numSaved = GetNumSavedInstances() or 0
        add(("GetNumSavedInstances() = %d"):format(numSaved))
        add("")

        if numSaved == 0 then
            add("No saved instances. Zone into a raid and complete at least one")
            add("boss to populate the lockout cache, then re-run this probe.")
        else
            -- Build EJ map for the currently-loaded raid (if any) for
            -- cross-referencing unknown4 values.
            local jeToDe, deToJe
            if RR.currentRaid and RR.currentRaid.journalInstanceID then
                jeToDe = RR:GetEJMapForJournalInstance(RR.currentRaid.journalInstanceID)
                if jeToDe then
                    deToJe = {}
                    for je, de in pairs(jeToDe) do
                        deToJe[de] = je
                    end
                    add(("EJ map for currently-loaded raid '%s' (journalInstanceID=%d):"):format(
                        RR.currentRaid.name or "?",
                        RR.currentRaid.journalInstanceID))
                    -- Sort journalEncounterIDs by boss index for stable output
                    local rows = {}
                    for _, b in ipairs(RR.currentRaid.bosses or {}) do
                        if b.journalEncounterID and jeToDe[b.journalEncounterID] then
                            table.insert(rows, {
                                idx = b.index or 0,
                                name = b.name or "?",
                                je   = b.journalEncounterID,
                                de   = jeToDe[b.journalEncounterID],
                            })
                        end
                    end
                    table.sort(rows, function(a, b) return a.idx < b.idx end)
                    for _, r in ipairs(rows) do
                        add(("  [%d] %s: journalEncounterID=%d -> dungeonEncounterID=%d"):format(
                            r.idx, r.name, r.je, r.de))
                    end
                    add("")
                end
            else
                add("No currently-loaded raid; skipping EJ cross-reference.")
                add("Re-run from inside a supported raid for a complete check.")
                add("")
            end

            for i = 1, numSaved do
                local name, _, _, difficultyId, _, _, _, isRaid,
                      _, difficultyName, numEncounters, _, _, instanceID = GetSavedInstanceInfo(i)
                add(("=== Saved instance %d ==="):format(i))
                add(("  name=%s"):format(tostring(name)))
                add(("  instanceID=%s  difficultyId=%s  difficultyName=%s"):format(
                    tostring(instanceID), tostring(difficultyId), tostring(difficultyName)))
                add(("  isRaid=%s  numEncounters=%s"):format(
                    tostring(isRaid), tostring(numEncounters)))

                if numEncounters and numEncounters > 0 then
                    for e = 1, numEncounters do
                        -- Capture ALL returns (Lua's variadic select is the
                        -- safest way; we don't know how many returns the
                        -- current client actually emits).
                        local r1, r2, r3, r4, r5, r6 = GetSavedInstanceEncounterInfo(i, e)
                        local crossRef = ""
                        if deToJe and type(r4) == "number" then
                            local je = deToJe[r4]
                            if je then
                                crossRef = (" [unknown4 matches dungeonEncounterID for journalEncounterID=%d]"):format(je)
                            else
                                crossRef = " [unknown4 not in EJ map for current raid]"
                            end
                        elseif deToJe then
                            crossRef = (" [unknown4 type=%s, not numeric]"):format(type(r4))
                        end
                        add(("  enc[%d]: bossName=%q  fileDataID=%s  isKilled=%s  unknown4=%s%s"):format(
                            e,
                            tostring(r1),
                            tostring(r2),
                            tostring(r3),
                            tostring(r4),
                            crossRef))
                        -- Defensive: capture r5/r6 in case the client emits
                        -- additional returns we don't know about.
                        if r5 ~= nil or r6 ~= nil then
                            add(("            extra returns: r5=%s  r6=%s"):format(
                                tostring(r5), tostring(r6)))
                        end
                    end
                end
                add("")
            end
        end

        add("=== Probe complete ===")
        add("")
        add("Interpretation:")
        add("  If 'unknown4 matches dungeonEncounterID...' fires for every")
        add("  encounter of the currently-loaded raid, then unknown4 IS the")
        add("  dungeonEncounterID and SyncFromSavedRaidInfo can use it as")
        add("  the primary kill-match key (with name as fallback).")
        add("")
        add("  If unknown4 is nil or otherwise unrelated, we stick with")
        add("  name-based matching plus aliases for known event-name")
        add("  mismatches (Eonar pattern).")

        RetroRunsDebug = RetroRunsDebug or {}
        RetroRunsDebug.probelockout = table.concat(lines, "\n")
        RR:ShowCopyWindow(
            ("|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaDebug: probelockout|r"),
            table.concat(lines, "\n"))
        RR:Print("probelockout complete. Copy window opened.")

    elseif cmd == "traveldebug" then
        -- Snapshot of the inputs the travel-pane renderer is using right
        -- now: player mapID, world-map mapID, the mapID the renderer
        -- would actually pick (GetBestMapForStep), and per-segment state
        -- (mapID, has-note, completed). Used to diagnose "why is the
        -- travel pane showing the wrong segment's note?" One-shot dump
        -- rather than per-update, so chat doesn't get spammed.
        RR:TravelDebug()

    elseif cmd == "toggleprobe" then
        -- Diagnostic for the run-complete-state dead-toggle-button bug.
        -- Dumps each expansion-toggle button's state, every body frame
        -- that could be intercepting clicks, and GetMouseFocus() at
        -- probe time so the user can hover the + glyph and see what
        -- frame is actually under the cursor.
        RR:ToggleProbe()

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
        --   [E5] Difficulty-bucket mismatch via itemContext. Each sourceID's
        --        live itemLink carries an itemContext (the 12th option in
        --        the hyperlink) that names which difficulty it was
        --        generated at. If the source in our `[16]=N` (Mythic) slot
        --        has an itemLink whose itemContext maps to LFR, the source
        --        is in the wrong bucket. Added post-v1.0.1 LFR/Mythic-swap
        --        incident. Only fires when the data is per-difficulty
        --        shape -- binary-shape items have identical sourceIDs
        --        across all buckets and trigger no mismatch by design.
        --
        -- Coverage checks (require driving the EJ at each difficulty;
        -- async pass that runs after the per-row metadata checks):
        --   [E6] Coverage gap: EJ exposes more sourceIDs for this item at
        --        this difficulty than we shipped. Catches the harvester-
        --        skip class of bug (Antorus pre-v1.10.0): the harvester's
        --        fast path returned one sourceID, the EJ-sweep would
        --        have caught 4, the gate skipped the sweep, we shipped
        --        binary. Without this check, tmogverify on binary-shape
        --        data is clean but uninformative -- E1-E5 all pass on
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
                                       + (T.bucket_mismatch or 0)
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
                        reportAdd(("    fatal_nil=%d, item_mismatch=%d, bucket_mismatch=%d"):format(
                            T.fatal_nil or 0, T.item_mismatch or 0, T.bucket_mismatch or 0))
                        reportAdd(("    coverage_gap=%d (E6), missing_item=%d (E7)"):format(
                            T.coverage_gap or 0, T.missing_item or 0))
                        reportAdd(("  E5: checked=%d, skipped=%d"):format(
                            T.e5_checked or 0, T.e5_skipped or 0))
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
            RR:Print("YellDebug: /rr yelldebug [start|stop]  (dev diagnostic for v1.2 yell-trigger framework)")
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
            RR:Print("  /rr  raidcapture                 (full new-raid tier + loot harvest)")
            RR:Print("  /rr  weaponharvest               (harvest CN weapon-token pools)")
            RR:Print("  /rr  vendorscan                  (scan open merchant frame for items+costs)")
            RR:Print("  /rr  tmogtest <itemID>           (transmog diagnostic)")
            RR:Print("  /rr  ejprobe [itemID]            (dump EJ loot for selected encounter)")
            RR:Print("  /rr  tierprobe <itemID>          (dump C_TransmogSets sources for a tier itemID)")
            RR:Print("  /rr  traveldebug                 (snapshot of travel-pane renderer state)")
            RR:Print("  /rr  srctest <sourceID>          (transmog source diagnostic)")
            RR:Print("  /rr  specialtest <itemID>        (special-loot API probe)")
            RR:Print("  /rr  dottest <itemID>            (per-diff dot state probe)")
            RR:Print("  /rr  tmogaudit [raid name]       (full-raid tmog audit dump)")
            RR:Print("  /rr  tmogverify [raid name]      (full-raid data-integrity audit)")
            RR:Print("  /rr  ejdiff <encID> [itemID]     (EJ per-difficulty probe)")
            RR:Print("  /rr  tmogsrc | tmogtrace         (transmog internals)")
            RR:Print("  /rr  ej                          (open Blizzard Encounter Journal)")
            RR:Print("  /rr  yelldebug [start|stop]      (capture chat-channel yells -- v1.2 framework prep)")
        else
            RR:Print("RetroRuns commands:")
            RR:Print("  /rr                  (toggle main panel)")
            RR:Print("  /rr  show | hide     (show / hide main panel)")
            RR:Print("  /rr  status          (current raid, step, kill state)")
            RR:Print("  /rr  tmog            (open transmog browser)")
            RR:Print("  /rr  skips           (account-wide raid skip status)")
            RR:Print("  /rr  settings        (open settings window)")
            RR:Print("  /rr  reset           (reset panel position & settings)")
            RR:Print("  /rr  refresh         (re-render the main panel)")
            RR:Print("  /rr  cancelnav       (cancel an active entrance-navigation route)")
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

        -- On initial login (new WoW process, not a /reload), wipe
        -- persisted walk progress entirely. Walk progress is session-
        -- scoped working memory: it lasts as long as the WoW process
        -- (so /reload preserves it) but doesn't carry across full
        -- logout/relaunch. This prevents stale segment marks from a
        -- prior session showing up as "already walked" on a new login.
        --
        -- stepVisitedMapIDs is wiped alongside completedSegments because
        -- it has the same semantics: "what mapIDs has the player physically
        -- reached during the active step?" The strict-sequential picker cap
        -- consults this set, and a stale set carries the prior session's
        -- "I reached seg 4's mapID" signal across a logout, which makes the
        -- cap permit seg 4 mid-flight when the player retries the step
        -- post-logout. Canonical case: BfD Mekkatorque step 7 with the
        -- 1357 -> [transit 1352] -> 875 -> 1367 -> 1352 gryphon route, on
        -- second attempt this lockout. Without this wipe, all four mapIDs
        -- are pre-loaded into the visit set at step-activation time, the
        -- cap stays maxed, and seg 4's "go downstairs..." note flashes
        -- mid-flight on 1352 -- the exact bug the cap was designed to fix.
        if isInitialLogin and RetroRunsDB then
            RetroRunsDB.completedSegments = {}
            RetroRunsDB.stepVisitedMapIDs = {}
            RR:ZoneLog("PEW: initial login -- wiped persisted segments and step visit history")
        end

        C_Timer.After(1.0, function() RR:HandleLocationChange() end)

    elseif event == "ZONE_CHANGED_NEW_AREA"
        or event == "ZONE_CHANGED"
        or event == "ZONE_CHANGED_INDOORS" then
        -- ZONE_CHANGED_NEW_AREA fires for major zone transitions (entering
        -- or leaving the raid instance itself). ZONE_CHANGED and
        -- ZONE_CHANGED_INDOORS fire for sub-zone transitions within the
        -- current zone -- which is what we need to detect movement
        -- between Vault's sub-zones (Primal Bulwark, Vault Approach,
        -- etc.) since they're sub-zones of the parent raid map, not
        -- distinct zones. One of these also fires when the minimap text
        -- changes (sub-sub-zones like Quarry of Infusion) -- the
        -- separate MINIMAP_ZONE_CHANGED event was removed in patch 2.4.0.
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

-- Teleport-arrival and kill-gate advancement. Both are position-based
-- checks on the same cadence: teleport arrival marks a teleport segment
-- complete when the player arrives at the next segment's start, kill-gate
-- advancement marks a kill segment complete when the player arrives at
-- that segment's endpoint (typically the miniboss pull spot).
C_Timer.NewTicker(0.5, function()
    if RR.currentRaid and RR.state.loadedRaidKey and RR.state.activeStep then
        RR:CheckTeleportArrivalAdvance()
        RR:CheckKillAdvance()
    end
end)

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

        -- Strict-activeSeg mapID-change poll. Closes a gap in
        -- Blizzard's event timing: some elevator and flight
        -- transitions don't fire ZONE_CHANGED events at the exact
        -- moment the mapID changes. For example, BfD's Loa's
        -- Sanctum (1354) -> Walk of Kings (1356) elevator only fires
        -- ZONE_CHANGED_INDOORS for the sub-zone change, while
        -- C_Map.GetBestMapForUnit still reports 1354 at that
        -- moment; the actual mapID transition to 1356 happens
        -- mid-elevator with no event accompanying it. Without this
        -- poll, AdvanceStrictActiveSeg never gets called for those
        -- transitions and the activeSeg pointer stays stuck.
        --
        -- Why polling is acceptable here: the strict-activeSeg
        -- picker is the only consumer of mapID changes for raids
        -- using it; missing a poll cycle (1 second resolution) is
        -- fine for note-display latency. Other consumers (recorder,
        -- segment-completion in raids using the layered-gate
        -- picker) still use the event-driven HLC path.
        --
        -- AdvanceStrictActiveSeg is predicated internally via
        -- UsesStrictActiveSegPicker, so this poll is safe to run
        -- unconditionally -- it's a no-op for raids that don't
        -- opt in.
        --
        -- RR.state.lastPolledMapID (not a module-local) is the
        -- baseline so SeedStrictActiveSeg can re-sync it on step
        -- transitions. Without that sync, post-ENCOUNTER_END map
        -- flicker (e.g. Antorus Eonar success: player's mapID
        -- briefly resolves 913->909 around the kill) can fire a
        -- spurious advance from seg 1 to seg 2 even though the
        -- player hasn't clicked the orb to return to Antorus yet.
        if C_Map and C_Map.GetBestMapForUnit then
            local nowMapID = C_Map.GetBestMapForUnit("player")
            if nowMapID and nowMapID ~= RR.state.lastPolledMapID then
                RR.state.lastPolledMapID = nowMapID
                RR:AdvanceStrictActiveSeg(nowMapID)
            end
        end
    end
end)
