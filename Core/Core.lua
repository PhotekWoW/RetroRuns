-------------------------------------------------------------------------------
-- RetroRuns -- Core.lua
-- Namespace, DB lifecycle, event hub, slash commands, shared utilities.
-- No UI frame references. No navigation logic.
-------------------------------------------------------------------------------

local ADDON_NAME = "RetroRuns"
local VERSION    = "2.0.1"

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
        -- Set true once UPDATE_INSTANCE_INFO has fired, meaning the async
        -- saved-instance data (GetSavedInstanceInfo / GetCurrentLockoutId)
        -- has been delivered at least once. The load decision defers only
        -- while this is false; after the data has had its chance to arrive,
        -- a still-nil lockout is treated as a genuinely fresh lockout and
        -- the dialog is shown rather than deferring forever.
        instanceInfoSeen      = false,
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
        -- bossOrderMode: ordering of the Boss Progress list. Values:
        --   "rr" - the route order this addon walks (default)
        --   "ej" - the in-game Encounter Journal order
        bossOrderMode = "rr",
        -- toasterEnabled: master switch for the Toaster feature. When on,
        -- toasts auto-activate in supported raids and deactivate elsewhere.
        -- Default OFF -- the feature is opt-in; users enable it in Settings.
        toasterEnabled = false,
        -- toasterDuration: seconds a toast stays at full opacity before fading.
        -- User-adjustable in Customize (1.5..8.0). Floor keeps a two-line name
        -- readable.
        toasterDuration = 3.0,
        -- toasterStayUntilClick: when true, toasts never auto-fade -- they hold
        -- until the user clicks them to dismiss. Overrides toasterDuration.
        toasterStayUntilClick = false,
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
        "|cff4DCCFFR|cffF259C7R|r|cff7f7f7f:|r " .. tostring(msg))
end

-- Queue a chat line to print after the login version banner. Prints
-- immediately once the banner has fired; before that, holds the line so
-- ShowLoginBanner can flush the queue in order behind the banner.
RR._bannerShown = false
RR._bannerQueue = {}
function RR:PrintAfterBanner(msg)
    if self._bannerShown then
        self:Print(msg)
    else
        table.insert(self._bannerQueue, msg)
    end
end

-- Print the login banner, then flush anything queued behind it. Called
-- from the PLAYER_LOGIN handler's timer.
function RR:ShowLoginBanner()
    self:Print(("|cffaaaaaav%s loaded. Type |r|cffffffff/rr help|r|cffaaaaaa for commands.|r"):format(VERSION))
    self._bannerShown = true
    for _, msg in ipairs(self._bannerQueue) do
        self:Print(msg)
    end
    wipe(self._bannerQueue)
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
    -- Buffer cap: 1000 entries. With /rr debug on, the 1Hz heartbeat logger
    -- adds ~60 entries/min, so 1000 covers ~16 min of continuous debug output
    -- plus headroom for actual events before old lines roll off.
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

--- Shared destination dispatch. Drops a waypoint at (mapID, x, y) across
--- the full provider stack and returns a struct describing which slot(s)
--- fired:
---     { planner = "awp"|"zygor"|"mapzeroth"|nil,
---       arrow   = "tomtom"|"blizzard"|nil,
---       overlays = { ... } }
--- Roles:
---   PLANNER: AWP-with-backend > Zygor > Mapzeroth (one wins).
---   ARROW:   TomTom > Blizzard (suppressed if a planner fired).
---   OVERLAY: AWP-without-backend + WUI (both can layer).
--- routeContext is stashed onto state.activeRoute so a later cancel can
--- tear the right thing down; pass the raid for entrance/sanctum routes,
--- or nil for destinations with no raid association (e.g. a city NPC).
--- Returns nil (and prints) when no provider produced any UI.
---
--- This is the single dispatch core for NavigateToEntrance,
--- NavigateToSanctum, and NavigateToLFRNPC -- previously each of those
--- carried its own copy of this ~120-line block.
function RR:NavigateToDestination(mapID, x, y, title, routeContext)
    if not mapID or not x or not y then
        self:Print("Destination data is incomplete.")
        return nil
    end

    -- Clear any in-progress route before starting a new one.
    self:CancelNavRoute()

    local result = { planner = nil, arrow = nil, overlays = {} }

    local function markRoute(field, value)
        self.state.activeRoute = self.state.activeRoute or { raid = routeContext }
        self.state.activeRoute.raid = routeContext
        self.state.activeRoute[field] = value
    end

    -- PLANNER ROLE: AWP-with-backend > Zygor > Mapzeroth. One wins.
    local hasBackend = self:IsZygorInstalled() or self:IsMapzerothInstalled()
    if self:IsAWPInstalled() and hasBackend then
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            mapID, x, y, title, nil, nil)
        if ok and routed then
            markRoute("awpRoute", true)
            result.planner = "awp"
        end
    end

    if not result.planner and self:IsZygorInstalled() then
        -- Mirrors Zygor's own /zygor goto payload. findpath=true gates
        -- multi-leg routing (otherwise just an arrow).
        _G.ZygorGuidesViewer.Pointer:SetWaypoint(mapID, x, y, {
            findpath    = true,
            type        = "manual",
            cleartype   = true,
            title       = title,
            onminimap   = "always",
            overworld   = true,
            showonedge  = true,
        }, true)
        markRoute("zygorRoute", true)
        result.planner = "zygor"
    end

    if not result.planner and self:IsMapzerothInstalled() then
        _G.Mapzeroth:FindRoute("_WAYPOINT_DESTINATION", {
            mapID  = mapID,
            x      = x,
            y      = y,
            name   = title,
            source = "retroruns",
        })
        markRoute("mapzerothRoute", true)
        result.planner = "mapzeroth"
    end

    -- ARROW ROLE: TomTom > Blizzard. Suppressed if a planner fired
    -- (planner provides its own arrow).
    if not result.planner then
        if self:IsTomTomInstalled() then
            local uid = TomTom:AddWaypoint(mapID, x, y, {
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
            markRoute("tomtomWaypoint", uid)
            result.arrow = "tomtom"

        elseif self:IsBlizzardWaypointAvailable() then
            local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
            C_Map.SetUserWaypoint(point)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
            markRoute("blizzardWaypoint", true)
            result.arrow = "blizzard"
        end
    end

    -- OVERLAY ROLE: AWP (when not already-fired as planner) + WUI
    -- (always fires when installed). Both can layer simultaneously.
    if self:IsAWPInstalled() and result.planner ~= "awp" then
        local ok, routed = pcall(_G.AzerothWaypointNS.RequestManualRoute,
            mapID, x, y, title, nil, nil)
        if ok and routed then
            markRoute("awpOverlay", true)
            table.insert(result.overlays, "awp")
        end
    end

    if self:IsWUIInstalled() then
        -- WUI uses 0-100 coords; scale our 0-1 values on the way in.
        _G.WaypointUIAPI.Navigation.NewUserNavigation(title, mapID, x * 100, y * 100)
        markRoute("wuiRoute", true)
        table.insert(result.overlays, "wui")
    end

    if not result.planner and not result.arrow and #result.overlays == 0 then
        self:Print("No supported waypoint API available.")
        return nil
    end
    return result
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

    local title = ("RetroRuns: %s entrance"):format(raid.name or "raid")
    return self:NavigateToDestination(e.mapID, e.x, e.y, title, raid)
end

--- Drop a waypoint at a Covenant Sanctum weapon vendor (Castle
--- Nathria). Routes through the shared NavigateToDestination dispatch.
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

    local title = ("RetroRuns: %s (%s vendor)"):format(
        vendor.vendorName or "Sanctum", vendor.covenantName or "covenant")
    return self:NavigateToDestination(vendor.vendorMapID, vendor.x, vendor.y, title, raid)
end

--- Per-expansion Raid Finder queueing NPCs. After an expansion passes,
--- Blizzard adds a dedicated NPC whose gossip places a solo-eligible LFR
--- queue request; talking to that NPC is the only way to queue legacy LFR
--- solo (the Group Finder won't fill the wing otherwise). This table maps
--- each supported expansion to its NPC so the idle list can route the
--- player there. Keyed by the canonical expansion names used in raid
--- data (raid.expansion) and EXPANSION_ORDER_NEWEST_FIRST.
---
--- Battle for Azeroth has a faction split (Kiku for Alliance, Eppu for
--- Horde); that entry carries an alliance/horde sub-table and the nav
--- picks by UnitFactionGroup. All others are faction-neutral.
---
--- COORDINATE STATUS: most entries carry in-game-verified coords. Any
--- entry still pending a capture pass keeps an `unverified = true` flag,
--- read by the nav so it routes to the right zone center but warns it's
--- approximate. Do not treat unverified coords as final.
RR.LFR_QUEUE_NPCS = {
    ["Dragonflight"] = {
        npcName = "Luka Ferad",
        zone    = "Valdrakken, Seat of the Aspects",
        mapID   = 2112, x = 0.584, y = 0.356,
    },
    ["Shadowlands"] = {
        npcName = "Ta'elfar",
        zone    = "Oribos, The Enclave",
        mapID   = 1670, x = 0.416, y = 0.708,
    },
    ["Battle for Azeroth"] = {
        alliance = {
            npcName = "Kiku",
            zone    = "Boralus, Snug Harbor Inn",
            mapID   = 1161, x = 0.740, y = 0.136,
        },
        horde = {
            npcName = "Eppu",
            zone    = "Dazar'alor, Hall of Chroniclers",
            mapID   = 1164, x = 0.686, y = 0.304,
        },
    },
    ["Legion"] = {
        npcName = "Archmage Timear",
        zone    = "Dalaran (Legion), outside the Violet Hold",
        mapID   = 627, x = 0.637, y = 0.553,
    },
    ["Warlords of Draenor"] = {
        -- Seer Kazal stands outside the Town Hall in both Garrisons, but
        -- the Garrison map differs by faction (Lunarfall vs Frostwall),
        -- so the entry is faction-split. Alliance (Lunarfall, 582) is
        -- verified in-game; Horde (Frostwall) awaits a capture on a Horde
        -- character and falls through to the text instruction until then.
        alliance = {
            npcName = "Seer Kazal",
            zone    = "Your Garrison (Lunarfall), outside the Town Hall",
            mapID   = 582, x = 0.333, y = 0.374,
        },
        horde = {
            npcName = "Seer Kazal",
            zone    = "Your Garrison (Frostwall), outside the Town Hall",
            mapID   = 0, x = 0.50, y = 0.50, unverified = true,
        },
    },
    ["Mists of Pandaria"] = {
        npcName = "Lorewalker Han",
        zone    = "Mogu'shan Palace, Seat of Knowledge",
        mapID   = 1530, x = 0.837, y = 0.281,
    },
}

--- Resolve the LFR queue-NPC entry for an expansion, applying the BfA
--- faction split. Returns the NPC table (with npcName/zone/mapID/x/y/
--- unverified) or nil if the expansion has no queue NPC.
function RR:GetLFRQueueNPC(expansion)
    local entry = expansion and RR.LFR_QUEUE_NPCS[expansion]
    if not entry then return nil end
    -- Faction-split entries (BfA) carry alliance/horde sub-tables.
    if entry.alliance or entry.horde then
        local faction = UnitFactionGroup("player")
        if faction == "Horde" then
            return entry.horde
        else
            return entry.alliance
        end
    end
    return entry
end

--- Drop a waypoint at an expansion's LFR queueing NPC. Routes through the
--- shared NavigateToDestination dispatch. No raid association (the NPC is
--- per-expansion), so routeContext is nil. Warns when the destination
--- coords are still unverified placeholders.
function RR:NavigateToLFRNPC(expansion)
    local npc = self:GetLFRQueueNPC(expansion)
    if not npc then
        self:Print("No LFR queue NPC known for that expansion.")
        return nil
    end
    if not npc.mapID or npc.mapID == 0 or not npc.x or not npc.y then
        -- A zero mapID means the destination isn't routable yet (e.g.
        -- the Garrison, whose mapID varies by faction/building tier and
        -- isn't captured). Tell the player where to go in text instead.
        self:Print(("LFR queue: talk to %s (%s)."):format(
            npc.npcName or "the queue NPC", npc.zone or "see guide"))
        return nil
    end

    local title = ("RetroRuns: %s (LFR queue)"):format(npc.npcName or "queue NPC")
    local result = self:NavigateToDestination(npc.mapID, npc.x, npc.y, title, nil)
    if result and npc.unverified then
        self:Print(("Note: %s's location is approximate -- look nearby (%s)."):format(
            npc.npcName or "the NPC", npc.zone or ""))
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
-- Largest font size the fixed-width panel renders without the widest pill row
-- overflowing the body width. Clamped at read time (below), not just the
-- slider max, so an out-of-range saved value is pulled back into range.
RR.FONT_SIZE_MAX = 14

function RR:GetSetting(key, default)
    if not RetroRunsDB then return default end
    local v = RetroRunsDB[key]
    if v == nil then return default end
    if key == "fontSize" and type(v) == "number" and v > RR.FONT_SIZE_MAX then
        return RR.FONT_SIZE_MAX
    end
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
                            elseif seg.triggeredBy.dialog then
                                local dialog = seg.triggeredBy.dialog
                                if type(dialog) ~= "table" then
                                    add("error", raidLabel,
                                        sp .. (" segment %d triggeredBy.dialog must be a table"):format(si))
                                else
                                    if not dialog.npc then
                                        add("error", raidLabel,
                                            sp .. (" segment %d triggeredBy.dialog missing npc field"):format(si))
                                    end
                                    if not dialog.match then
                                        add("error", raidLabel,
                                            sp .. (" segment %d triggeredBy.dialog missing match field"):format(si))
                                    end
                                end
                            else
                                -- triggeredBy with no known sub-key (e.g. just empty {})
                                add("warn", raidLabel,
                                    sp .. (" segment %d triggeredBy has no recognized sub-key (expected dialog)"):format(si))
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

    -- Save the currently-selected EJ instance and difficulty so we can
    -- restore both. The difficulty must be forced to a value the instance
    -- actually exposes before walking encounters: EJ_GetEncounterInfoByIndex
    -- returns nothing when the journal's difficulty filter is left on one the
    -- instance doesn't offer (legacy raids predate Mythic, so a stale Mythic
    -- filter yields zero rows). Normal (14) exists for every raid, and the
    -- journalEncounterID -> dungeonEncounterID map is identical across
    -- difficulties, so forcing it here is safe and difficulty-independent.
    local prevInst = EJ_GetSelectedInstance and EJ_GetSelectedInstance() or nil
    local prevDiff = EJ_GetDifficulty and EJ_GetDifficulty() or nil
    if EJ_SetDifficulty then
        EJ_SetDifficulty(14)
    end
    if EJ_SelectInstance then
        EJ_SelectInstance(journalInstanceID)
    end

    local journalToDungeonEnc = {}
    local count  = 0
    local i = 1
    while true do
        local _, _, journalEncID, _, _, _, dungeonEncID = EJ_GetEncounterInfoByIndex(i, journalInstanceID)
        if not journalEncID then break end
        if dungeonEncID then
            journalToDungeonEnc[journalEncID] = dungeonEncID
            count = count + 1
        end
        i = i + 1
    end

    -- Restore the prior selection and difficulty so an open EJ window
    -- doesn't snap to whichever raid we just queried or change its filter.
    -- Skip each restore if there was no prior value.
    if prevInst and EJ_SelectInstance then
        EJ_SelectInstance(prevInst)
    end
    if prevDiff and EJ_SetDifficulty then
        EJ_SetDifficulty(prevDiff)
    end

    -- Only memoize non-empty results. Empty would mean the API was
    -- still warming up or the precondition wasn't satisfied; we want
    -- the next call to retry, not to lock in the empty result for
    -- the rest of the session.
    if count > 0 then
        ejMapCache[journalInstanceID] = journalToDungeonEnc
    end
    return journalToDungeonEnc
end

-- Expose on the RR namespace so other files (Navigation.lua's
-- locale-independent ENCOUNTER_END resolver) can build the same
-- journalEncounterID -> dungeonEncounterID lookup without
-- duplicating the EJ_SelectInstance dance.
function RR:GetEJMapForJournalInstance(journalInstanceID)
    return GetEJMapForJournalInstance(journalInstanceID)
end

-- Difficulty models.
--
-- Most raids RetroRuns covers use the modern scheme: one difficulty ID
-- per tier, Normal/Heroic/Mythic plus Raid Finder, and the loot data
-- keys its sources by those same IDs (14/15/16/17). For those raids the
-- bucket IDs and the live difficulty IDs are one and the same.
--
-- Mists-of-Pandaria raids are different. They predate Mythic and split
-- Normal and Heroic by raid size, so the game hands back four separate
-- raid difficulties -- 10-player Normal (3), 25-player Normal (4),
-- 10-player Heroic (5), 25-player Heroic (6) -- plus Raid Finder (7).
-- The loot and appearances are identical across size, so we fold the
-- two sizes into a single Normal and a single Heroic. Each model below
-- lists the live difficulty IDs the game can report and the display
-- bucket each one folds into. Display buckets reuse the modern IDs
-- (17=LFR, 14=Normal, 15=Heroic) so the loot browser and source data
-- speak one language regardless of era.
--
-- A raid opts into a model with `difficultyModel` in its data file;
-- absent means "modern".
local DIFFICULTY_MODELS = {
    modern = {
        -- live id -> display bucket (identity)
        fold    = { [17] = 17, [14] = 14, [15] = 15, [16] = 16 },
        -- display buckets in pill / browser order
        buckets = { 17, 14, 15, 16 },
    },
    mop = {
        -- 7=LFR, 3/4=Normal (10/25), 5/6=Heroic (10/25)
        fold    = { [7] = 17, [3] = 14, [4] = 14, [5] = 15, [6] = 15 },
        buckets = { 17, 14, 15 },
    },
}

-- Resolve a raid's difficulty model, defaulting to modern.
function RR:GetDifficultyModel(raid)
    local key = raid and raid.difficultyModel or "modern"
    return DIFFICULTY_MODELS[key] or DIFFICULTY_MODELS.modern
end

-- Fold a live difficulty ID (what GetInstanceInfo / GetSavedInstanceInfo
-- report) into the display bucket for a raid. Returns the id unchanged
-- if the raid's model doesn't remap it.
function RR:FoldDifficulty(raid, liveDifficultyID)
    if not liveDifficultyID then return liveDifficultyID end
    local model = self:GetDifficultyModel(raid)
    return model.fold[liveDifficultyID] or liveDifficultyID
end

-- True when a raw saved-instance difficulty is a Raid Finder difficulty.
-- GetSavedInstanceInfo reports the raw live id, so modern LFR shows 17 but
-- Mists LFR shows 7. The all-saved-instances scans (lockout-bit reads, the
-- idle pill counts) key by raid name and have no raid object at the compare
-- point, so they can't fold per-raid -- this accepts any raw id that folds to
-- 17 under some model. A raw `== 17` test misses Mists LFR lockouts entirely.
local LFR_SAVED_DIFFICULTIES
function RR:IsLFRSavedDifficulty(rawDifficultyID)
    if not rawDifficultyID then return false end
    if not LFR_SAVED_DIFFICULTIES then
        LFR_SAVED_DIFFICULTIES = {}
        for _, model in pairs(DIFFICULTY_MODELS) do
            for rawID, bucket in pairs(model.fold) do
                if bucket == 17 then LFR_SAVED_DIFFICULTIES[rawID] = true end
            end
        end
    end
    return LFR_SAVED_DIFFICULTIES[rawDifficultyID] == true
end

-- True when the player is in a Raid Finder instance of the current raid.
-- Folds the live difficulty to a display bucket first, so it catches both
-- the modern LFR id (17) and the Mists-era LFR id (7, which folds to 17).
-- A raw `== 17` test misses Mists LFR and would let the full N/H/M route
-- render in an LFR wing (wrong boss subset, wrong path). Use this everywhere
-- LFR needs gating -- the load popup and the panel render both rely on it.
function RR:IsInLFR()
    local diff = self.state and self.state.currentDifficultyID
    if not diff then return false end
    return self:FoldDifficulty(self.currentRaid, diff) == 17
end

-- The current LFR wing's lfgDungeonID, or nil. GetInstanceInfo's 10th return
-- identifies the wing (confirmed: it's per-wing and unique, unlike instanceID).
-- Single live read; the wing-name and wing-route resolvers both build on this.
function RR:GetCurrentLfgDungeonID()
    if not GetInstanceInfo then return nil end
    local lfgDungeonID = select(10, GetInstanceInfo())
    if not lfgDungeonID or lfgDungeonID == 0 then return nil end
    return lfgDungeonID
end

-- Display name of the current LFR wing, or nil if unavailable. LFR splits a
-- raid into wings; GetLFGDungeonInfo resolves the lfgDungeonID to a localized
-- name (e.g. "The Leeching Vaults"). The numeric id is the stable key; this
-- name is for display only. Returns nil when there's no id or the lookup fails,
-- so callers can fall back to a generic message.
function RR:GetCurrentWingName()
    local lfgDungeonID = self:GetCurrentLfgDungeonID()
    if not lfgDungeonID then return nil end
    if not GetLFGDungeonInfo then return nil end
    local name = GetLFGDungeonInfo(lfgDungeonID)
    if name and name ~= "" then return name end
    return nil
end

-- Resolve the lfrWings entry for the wing the player is currently in, or nil.
-- Each wing route is keyed by lfgDungeonID under raid.lfrWings. A wing can be
-- queueable under more than one lfgDungeonID (e.g. size/seasonal variants of
-- the same physical wing); the duplicates are stored as { aliasOf = <id> }
-- and dereferenced here so one authored route serves every id that points at
-- it. Returns nil when not in LFR, the raid has no lfrWings, or no entry
-- matches the current id -- callers then fall back to the unsupported message.
function RR:GetActiveWing()
    local raid = self.currentRaid
    if not raid or not raid.lfrWings then return nil end
    if not self:IsInLFR() then return nil end
    local id = self:GetCurrentLfgDungeonID()
    if not id then return nil end
    local wing = raid.lfrWings[id]
    if not wing then return nil end
    if wing.aliasOf then
        wing = raid.lfrWings[wing.aliasOf]
    end
    return wing
end

-- Is a boss available at a given DISPLAY bucket (14/15/16/17)?
--
-- Most bosses exist at every difficulty their raid offers, so the default
-- (no `availableDifficulties` field) is "available everywhere" -> true.
-- A boss that only exists at certain difficulties (e.g. Ra-den in Throne
-- of Thunder is Heroic-only) declares `availableDifficulties = { 15 }`;
-- this returns true only when the queried bucket is in that list.
--
-- bucket is a display bucket, not a live difficulty ID -- callers that
-- hold a live ID should FoldDifficulty it first.
function RR:BossAvailableInBucket(boss, bucket)
    if not boss then return false end
    local allowed = boss.availableDifficulties
    if not allowed then return true end  -- unrestricted: exists everywhere
    for _, b in ipairs(allowed) do
        if b == bucket then return true end
    end
    return false
end

-- Compute per-difficulty kill counts for ANY raid (not just the
-- currently-loaded one). Used by both the in-raid pill row and the
-- idle-state supported-raids list.
--
-- For the currently-loaded raid (active difficulty in particular), the
-- caller is responsible for the MAX-with-bossesKilled trick that lets
-- ENCOUNTER_END register kills before the saved-instance cache catches
-- up. This function reads PURELY from cache; no live state.
--
-- Results are keyed by DISPLAY bucket (17/14/15/16), not by the live
-- difficulty IDs. Under the Mists model, a boss counts as cleared on a
-- bucket if it was killed at EITHER size that folds into it -- killing
-- Stone Guard at 10-player Normal marks the Normal bucket complete even
-- if you never touched 25-player.
function RR:GetPerDifficultyKillCountsForRaid(raid)
    if not raid then return nil end
    if not C_RaidLocks or not C_RaidLocks.IsEncounterComplete then return nil end

    local journalInstanceID = raid.journalInstanceID
    local instanceID        = raid.instanceID
    if not journalInstanceID or not instanceID then return nil end

    local journalToDungeonEnc = GetEJMapForJournalInstance(journalInstanceID)
    if not journalToDungeonEnc then return nil end

    local model = self:GetDifficultyModel(raid)
    local result = {}

    -- Group the live difficulty IDs by the display bucket they fold into,
    -- so we can ask "is this boss done on Normal?" by checking every size
    -- that maps to Normal.
    local liveIdsForBucket = {}
    for liveId, bucket in pairs(model.fold) do
        liveIdsForBucket[bucket] = liveIdsForBucket[bucket] or {}
        table.insert(liveIdsForBucket[bucket], liveId)
    end

    for _, bucket in ipairs(model.buckets) do
        local complete = 0
        local total    = 0
        for _, b in ipairs(raid.bosses or {}) do
            -- A boss counts toward a bucket's TOTAL if it exists at that
            -- difficulty (BossAvailableInBucket) -- independent of whether
            -- the Encounter Journal exposes a dungeonEncounterID for it.
            -- This matters for hidden bonus bosses: Ra-den is a real Heroic
            -- encounter but the EJ doesn't index him, so journalToDungeonEnc
            -- has no entry. Gating the total on the ID (as before) silently
            -- dropped him from the Heroic denominator, showing H 12 instead
            -- of 13.
            if self:BossAvailableInBucket(b, bucket) then
                total = total + 1
                -- Completion is checked through the lockout API, which
                -- needs the dungeonEncounterID. When the EJ doesn't expose
                -- one (hidden boss), use an explicit dungeonEncounterID from
                -- the data if present (Ra-den), so lockout-based completion
                -- still resolves on the idle list. Failing both, the
                -- in-memory bossesKilled floor below credits the active run.
                local dungeonEncID = journalToDungeonEnc[b.journalEncounterID]
                    or b.dungeonEncounterID
                if dungeonEncID then
                    for _, liveId in ipairs(liveIdsForBucket[bucket] or {}) do
                        if C_RaidLocks.IsEncounterComplete(instanceID, dungeonEncID, liveId) then
                            complete = complete + 1
                            break
                        end
                    end
                end
            end
        end
        result[bucket] = { complete = complete, total = total }
    end

    -- The instance cache updates asynchronously after a kill -- use
    -- in-memory bossesKilled as a floor for the active difficulty so
    -- pills update immediately on kill. The active difficulty is a live
    -- ID (e.g. a Mists size variant), so fold it to its display bucket
    -- before applying the floor.
    if self.currentRaid and raid == self.currentRaid then
        local activeBucket = self:FoldDifficulty(raid, self.state.currentDifficultyID)
        if activeBucket and result[activeBucket] then
            local localCount = 0
            for _, b in ipairs(raid.bosses or {}) do
                -- Only count toward the active bucket if the boss exists
                -- there -- mirrors the per-bucket total above so the floor
                -- can't push complete past total.
                if self.state.bossesKilled[b.index]
                    and self:BossAvailableInBucket(b, activeBucket) then
                    localCount = localCount + 1
                end
            end
            if localCount > result[activeBucket].complete then
                result[activeBucket].complete = localCount
            end
        end
    end

    return result
end

function RR:GetPerDifficultyKillCounts()
    if not self.currentRaid then return nil end
    return self:GetPerDifficultyKillCountsForRaid(self.currentRaid)
end

-- LFR kill count for a raid, as { complete = n, total = N }, or nil if the
-- raid has no LFR wing data. Unlike the Normal/Heroic/Mythic buckets (which
-- read C_RaidLocks.IsEncounterComplete), LFR completion is not exposed by that
-- API for legacy raids -- the reliable source is the per-boss bitfield encoded
-- in the LFR lockout hyperlink. We read it the same way /rr lfrwing does:
-- RequestRaidInfo, find this raid's difficulty-17 saved instance, pull the
-- bitfield from GetSavedInstanceChatLink, and count set bits (each = one boss
-- looted this lockout). The denominator N is the number of distinct bosses
-- across all of the raid's LFR wings.

-- Build (and briefly cache) a map of normalized-raid-name -> set-bit count for
-- every difficulty-17 (LFR) saved instance. One saved-instance scan covers all
-- LFR lockouts at once, so the idle list (which asks per raid, for many raids)
-- pays a single scan per refresh rather than one per raid. The scan runs
-- RequestRaidInfo + a GetNumSavedInstances walk, too heavy for every render
-- tick, so the result is cached for a few seconds; kills still surface within
-- that short window.
--
-- The cache stores BOTH the set-bit count (byName) and the set-bit POSITIONS
-- (posByName, a { [pos]=true } set per raid) so the per-wing progress expander
-- can mask a wing's lockoutBits against the live positions without a second
-- scan. byName is kept as a convenience for callers that only need the total.
function RR:GetLFRLockoutCounts()
    local now = GetTime and GetTime() or 0
    local cache = self._lfrCountCache
    if cache and (now - (cache.t or 0)) < 3 then
        return cache.byName, cache.posByName
    end

    if RequestRaidInfo then RequestRaidInfo() end
    local byName = {}
    local posByName = {}
    local nSaved = GetNumSavedInstances and GetNumSavedInstances() or 0
    for i = 1, nSaved do
        local sName, _, sReset, sDiff, sLocked = GetSavedInstanceInfo(i)
        -- Only count ACTIVE lockouts. GetSavedInstanceInfo keeps expired
        -- entries in the table after a weekly reset with their old kill bits
        -- intact (locked=false, reset=0), so parsing the bitfield blindly
        -- reports last week's kills forever. The N/H/M pills avoid this by
        -- reading C_RaidLocks (which correctly reports not-locked post-reset);
        -- the LFR pill reads this bitfield, so it must drop dead lockouts
        -- itself. An active lockout has locked=true and a positive reset.
        if self:IsLFRSavedDifficulty(sDiff) and sLocked and (sReset or 0) > 0 then
            local link = GetSavedInstanceChatLink and GetSavedInstanceChatLink(i)
            local bits = link and tonumber(link:match(":(%d+)|h"))
            local killed = 0
            local setPos = {}
            local x, pos = bits or 0, 1
            while x > 0 do
                if x % 2 == 1 then killed = killed + 1; setPos[pos] = true end
                x = math.floor(x / 2)
                pos = pos + 1
            end
            local key = self:NormalizeName(sName)
            if key then
                byName[key] = killed
                posByName[key] = setPos
            end
        end
    end

    self._lfrCountCache = { byName = byName, posByName = posByName, t = now }
    return byName, posByName
end

function RR:GetLFRKillCountForRaid(raid)
    if not raid or not raid.lfrWings then return nil end

    -- N: distinct boss indices across every wing.
    local seen, total = {}, 0
    for _, wing in pairs(raid.lfrWings) do
        for _, bi in ipairs(wing.bosses or {}) do
            if not seen[bi] then seen[bi] = true; total = total + 1 end
        end
    end
    if total == 0 then return nil end

    -- n: distinct bosses killed, summed from the per-wing progress (which
    -- bit-tests each boss individually). This avoids double-counting raids
    -- whose lockout sets more than one bit per boss -- e.g. Battle of
    -- Dazar'alor's faction-mirrored encounters set two bits each, so a raw
    -- set-bit count would over-report. Summing per-boss kills keeps this
    -- count consistent with the per-wing expander. Absent a lockout (not
    -- saved this week) every wing reports 0, a valid "0/N" state.
    local complete = 0
    local wings = self:GetWingProgressForRaid(raid)
    if wings then
        for _, w in ipairs(wings) do
            complete = complete + (w.complete or 0)
        end
    end

    return { complete = complete, total = total }
end

function RR:GetLFRKillCount()
    if not self.currentRaid then return nil end
    return self:GetLFRKillCountForRaid(self.currentRaid)
end

-- Per-wing LFR progress for the idle-list wing expander. Returns an ordered
-- list of wings, each:
--   {
--     key       = lfgDungeonID,
--     name      = wing name,
--     complete  = bosses killed in this wing,
--     total     = bosses in this wing,
--     unmapped  = true when the wing's per-boss bits aren't known (only its
--                 bit-SET as a group is) -- count is real, per-boss state is not,
--     bosses    = { { index, name, killed (bool or nil if unmapped) }, ... },
--   }
-- For a mapped wing (lockoutBits present) each boss's killed state comes from
-- testing its bit against the live set positions. For an unmapped wing
-- (lockoutBitSet present instead -- the group of bits without per-boss
-- assignment), the wing-level count is the number of those group bits currently
-- set (a real number), but per-boss killed is left nil so the UI can render the
-- names neutrally and flag the wing as pending a capture.
-- Returns nil if the raid has no lfrWings.
function RR:GetWingProgressForRaid(raid)
    if not raid or not raid.lfrWings then return nil end

    local _, posByName = self:GetLFRLockoutCounts()
    local key = self:NormalizeName(raid.name)
    local setPos = (key and posByName and posByName[key]) or {}

    -- Resolve a boss index to its display name via the raid's bosses[] table.
    local function bossName(index)
        local b = raid.bosses and raid.bosses[index]
        return (b and b.name) or ("Boss " .. tostring(index))
    end

    -- Collect wings into a stable order. lfrWings is keyed by lfgDungeonID
    -- (numeric), so sort by key for a deterministic top-to-bottom order.
    local wingKeys = {}
    for k in pairs(raid.lfrWings) do wingKeys[#wingKeys + 1] = k end
    table.sort(wingKeys)

    local out = {}
    for _, wkey in ipairs(wingKeys) do
        local wing = raid.lfrWings[wkey]
        local bosses = wing.bosses or {}
        local entry = {
            key   = wkey,
            name  = wing.name or "Wing",
            total = #bosses,
            bosses = {},
        }

        if wing.lockoutBits then
            -- Mapped wing: per-boss state from each boss's bit.
            local complete = 0
            for _, bi in ipairs(bosses) do
                local bit = wing.lockoutBits[bi]
                local killed = (bit ~= nil) and (setPos[bit] == true) or false
                if killed then complete = complete + 1 end
                entry.bosses[#entry.bosses + 1] =
                    { index = bi, name = bossName(bi), killed = killed }
            end
            entry.complete = complete
            entry.unmapped = false
        else
            -- Unmapped wing: count how many of the wing's group bits are set
            -- (real wing-level progress) but leave per-boss state nil. The
            -- group of bits lives in wing.lockoutBitSet (a flat list of bit
            -- positions). Absent even that, fall back to 0 and still flag.
            local groupSet = wing.lockoutBitSet or {}
            local complete = 0
            for _, bit in ipairs(groupSet) do
                if setPos[bit] then complete = complete + 1 end
            end
            for _, bi in ipairs(bosses) do
                entry.bosses[#entry.bosses + 1] =
                    { index = bi, name = bossName(bi), killed = nil }
            end
            entry.complete = complete
            entry.unmapped = true
        end

        out[#out + 1] = entry
    end

    return out
end

-- Return the set bit positions (1-indexed) of a raid's LFR lockout bitfield as
-- a { [pos] = true } set, plus the raw bits value. Used by the per-boss bit
-- capture logger below to diff which bit a just-killed boss set. Reads live
-- (no cache) since the capture needs the exact post-kill state. Returns nil if
-- no difficulty-17 lockout for the raid is found.
function RR:GetLFRSetBits(raid)
    if not raid then return nil end
    if RequestRaidInfo then RequestRaidInfo() end
    local wantName = self:NormalizeName(raid.name)
    local nSaved = GetNumSavedInstances and GetNumSavedInstances() or 0
    for i = 1, nSaved do
        local sName, _, _, sDiff = GetSavedInstanceInfo(i)
        if self:IsLFRSavedDifficulty(sDiff) and wantName and self:NormalizeName(sName) == wantName then
            local link = GetSavedInstanceChatLink and GetSavedInstanceChatLink(i)
            local bits = link and tonumber(link:match(":(%d+)|h"))
            if not bits then return nil end
            local setPos = {}
            local x, pos = bits, 1
            while x > 0 do
                if x % 2 == 1 then setPos[pos] = true end
                x = math.floor(x / 2)
                pos = pos + 1
            end
            return setPos, bits
        end
    end
    return nil
end

-- Per-boss LFR lockout-bit capture (dev aid for S7). When an LFR boss is
-- killed, the raid's lockout bitfield gains exactly one set bit -- the bit that
-- identifies that boss. The bit order is its own id space (not boss index, not
-- encounter-API order), so the only way to learn boss->bit is to watch which
-- bit appears per kill. This records that automatically on each LFR kill so the
-- mapping can be gathered during normal farming without manual probing, and
-- survives /reload (stored in RetroRunsDebug). Dump with `/rr lfrbits`.
--
-- The lockout API lags the kill by a second or two, so the read is deferred.
-- Each entry: { raid, boss, bit, t }. Diffing is against the prior reading we
-- recorded, so two kills before a refresh would show two new bits on the second
-- read -- run is best with one kill registering at a time, which a normal clear
-- naturally produces.
function RR:CaptureLFRBitForKill(encounterName)
    local raid = self.currentRaid
    if not raid or not self:IsInLFR() then return end

    -- Read the lockout and try to attribute exactly one newly-set bit to this
    -- kill. The bit can register late when a boss dies very fast (or bugs), so
    -- a single fixed-delay read sometimes sees no new bit yet -- and if we
    -- logged that "none" AND snapshotted the (still-stale) set, the late bit
    -- would later show up lumped with the NEXT kill's bit as "ambiguous".
    -- Instead, retry the read a few times on a "none" result and only commit a
    -- log entry + snapshot once a bit appears (or we genuinely exhaust the
    -- retries). attempt counts up; delays are spaced to cover a slow push.
    local DELAYS = { 2.5, 1.5, 2.0, 3.0 }   -- cumulative ~9s of retry budget

    local function tryCapture(attempt)
        local setPos = self:GetLFRSetBits(raid)
        if not setPos then return end

        RetroRunsDebug = RetroRunsDebug or {}
        RetroRunsDebug.lfrBitLog = RetroRunsDebug.lfrBitLog or {}
        local log = RetroRunsDebug.lfrBitLog

        -- Recover the last-known set from the most recent log entry for this
        -- raid (so it persists across reloads), defaulting to empty.
        local prevSet = {}
        for i = #log, 1, -1 do
            if log[i].raid == raid.name and log[i].snapshot then
                prevSet = log[i].snapshot
                break
            end
        end

        -- Which bits are newly set since the last committed snapshot.
        local newBits = {}
        for pos in pairs(setPos) do
            if not prevSet[pos] then newBits[#newBits + 1] = pos end
        end
        table.sort(newBits)

        -- No new bit yet and retries remain: the bit is probably still
        -- propagating from a fast kill. Wait and re-read WITHOUT writing a log
        -- entry or snapshot, so we don't strand the late bit for the next kill.
        if #newBits == 0 and attempt < #DELAYS then
            C_Timer.After(DELAYS[attempt + 1], function() tryCapture(attempt + 1) end)
            return
        end

        -- Commit. Snapshot the current full set so the next kill diffs against
        -- it. (On exhausted retries newBits may still be empty -- that's a real
        -- "no bit" the log should surface, not silently swallow.)
        local snapshot = {}
        for pos in pairs(setPos) do snapshot[pos] = true end

        log[#log + 1] = {
            raid     = raid.name,
            boss     = encounterName or "(unknown)",
            bit      = (#newBits == 1) and newBits[1]
                        or (#newBits == 0 and "none (no new bit -- already killed? or API lag)")
                        or ("ambiguous: {" .. table.concat(newBits, ",") .. "} -- multiple new bits since last capture"),
            t        = date and date("%H:%M:%S") or "",
            snapshot = snapshot,
        }
    end

    C_Timer.After(DELAYS[1], function() tryCapture(1) end)
end

-- Mists raids share one lockout across Normal and Heroic: killing a boss
-- on one mode commits the ID to that mode for the week, so the other mode
-- is unreachable until reset. Given the per-bucket counts, return the
-- display bucket that is locked OUT this lockout -- the Normal/Heroic
-- sibling of whichever one already has a kill. Returns nil when nothing
-- is committed yet (both zero), when both somehow show kills, or for any
-- raid that isn't on the shared-lockout model. Callers use this to mark
-- the locked pill; it does not change counts or gate anything.
function RR:GetLockedOutBucket(raid, counts)
    if not raid or not counts then return nil end
    if (raid.difficultyModel or "modern") ~= "mop" then return nil end

    local nDone = counts[14] and counts[14].complete > 0
    local hDone = counts[15] and counts[15].complete > 0
    if nDone and not hDone then return 15 end
    if hDone and not nDone then return 14 end
    return nil
end

-- Diagnostic for stale-lockout contamination. Dumps GetSavedInstanceInfo
-- for every saved instance, with C_RaidLocks.IsEncounterComplete probed
-- per encounter for any raids we have data for. Looking for: expired
-- entries (locked=false) where C_RaidLocks still returns true, which
-- would mean the API surface is letting stale data leak into pill
-- displays and bossesKilled.
function RR:LockProbe()
    if RequestRaidInfo then RequestRaidInfo() end

    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    local n = GetNumSavedInstances and GetNumSavedInstances() or 0
    add(("GetNumSavedInstances() = %d"):format(n))
    add("")

    if n == 0 then
        add("(no saved instances; nothing to dump)")
        self:ShowCopyWindow("LockProbe", table.concat(lines, "\n"))
        return
    end

    for i = 1, n do
        local name, id, reset, difficultyId, locked, extended,
              instanceIDMostSig, isRaid, maxPlayers, difficultyName,
              numEncounters, encounterProgress, extendDisabled,
              instanceID = GetSavedInstanceInfo(i)

        add(("[%d] %s"):format(i, tostring(name)))
        add(("    instanceID=%s  difficultyId=%s (%s)  isRaid=%s")
            :format(tostring(instanceID), tostring(difficultyId),
                    tostring(difficultyName), tostring(isRaid)))
        add(("    locked=%s  extended=%s  reset=%ss  progress=%s/%s")
            :format(tostring(locked), tostring(extended),
                    tostring(reset),
                    tostring(encounterProgress), tostring(numEncounters)))

        if numEncounters and numEncounters > 0 then
            for e = 1, numEncounters do
                local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, e)
                add(("      saved enc %d: %s  isKilled=%s")
                    :format(e, tostring(bossName), tostring(isKilled)))
            end
        end

        -- LFR (difficulty 17) detail: this is the exact data the idle LFR
        -- pill is built from. Dump the raw chat link, what our :(%d+)|h
        -- capture pulls out of it, and how that decodes to a kill count +
        -- set-bit positions -- plus the NormalizeName key the pill matches on.
        if self:IsLFRSavedDifficulty(difficultyId) then
            local link = GetSavedInstanceChatLink and GetSavedInstanceChatLink(i)
            add(("    [LFR] NormalizeName key = %q"):format(tostring(self:NormalizeName(name))))
            add(("    [LFR] raw chatLink = %s"):format(tostring(link)))
            local capture = link and link:match(":(%d+)|h")
            add(("    [LFR] :(%%d+)|h capture = %s"):format(tostring(capture)))
            local bits = link and tonumber(link:match(":(%d+)|h"))
            local killed, setPos = 0, {}
            local x, pos = bits or 0, 1
            while x > 0 do
                if x % 2 == 1 then killed = killed + 1; setPos[#setPos + 1] = pos end
                x = math.floor(x / 2)
                pos = pos + 1
            end
            add(("    [LFR] decoded bits = %s  -> killed = %d  setBitPositions = {%s}  (bit positions, NOT boss indices)")
                :format(tostring(bits), killed, table.concat(setPos, ",")))
        end

        if isRaid and RetroRuns_Data and RetroRuns_Data[instanceID]
            and C_RaidLocks and C_RaidLocks.IsEncounterComplete then
            local raid = RetroRuns_Data[instanceID]
            local journalToDungeonEnc = self:GetEJMapForJournalInstance(raid.journalInstanceID)
            if journalToDungeonEnc and next(journalToDungeonEnc) then
                add(("    C_RaidLocks.IsEncounterComplete(%s, <dungeonEncID>, %s):")
                    :format(tostring(instanceID), tostring(difficultyId)))
                for _, b in ipairs(raid.bosses or {}) do
                    local dungeonEncID = journalToDungeonEnc[b.journalEncounterID]
                    if dungeonEncID then
                        local r = C_RaidLocks.IsEncounterComplete(
                            instanceID, dungeonEncID, difficultyId)
                        add(("      %s (dungeonEncID=%s): %s")
                            :format(tostring(b.name), tostring(dungeonEncID),
                                    tostring(r)))
                    end
                end
            end
        end
        add("")
    end

    self:ShowCopyWindow("LockProbe", table.concat(lines, "\n"))
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
-- Detection for the Siege of Orgrimmar Garrosh skip (raid.skipGarrosh).
-- Returns true if the account has unlocked the skip. Two arms, OR'd:
--
--   * statistics: any of the per-difficulty Garrosh kill statistics
--     reading > 0. Covers LFR / Flexible / Normal / Heroic kills. The
--     in-game "--" (no kills) reads as a non-number, so tonumber()..or 0
--     treats it as zero.
--
--   * mythicAchievement: the Mythic Garrosh achievement completed (4th
--     return of GetAchievementInfo, account-wide). Covers Mythic kills,
--     which the kill statistics do not track.
-- Per-difficulty skip state for the Siege of Orgrimmar Garrosh scroll.
-- The scroll is account-wide and difficulty-agnostic: one Garrosh kill
-- on any character at any difficulty unlocks it everywhere. But the
-- client has no single account-wide "any kill" signal, so we infer the
-- state per difficulty from the strongest proof available, four tiers,
-- most-conclusive first:
--
--   Tier 1  Mythic Garrosh achievement (account-wide) completed
--           -> proof of a kill; cascades down. M / H / N all unlocked.
--   Tier 2  either faction's Heroic-or-higher kill achievement
--           (Conqueror = Alliance, Liberator = Horde; both account-wide)
--           completed, no Mythic -> H / N unlocked, M not confirmed.
--   Tier 3  any per-difficulty kill statistic > 0. Statistics are
--           CHARACTER-scoped, so this only confirms the *current*
--           character killed Garrosh -- but a kill is a kill, so the
--           account-wide skip is genuinely unlocked. N unlocked; H/M
--           not confirmed (no achievement to prove the difficulty).
--   Tier 4  nothing proven. The skip may still be unlocked by a kill on
--           another character that left no account-wide trace we can
--           read, so Normal is "unknown" (?) rather than a hard locked;
--           H / M stay not-confirmed.
--
-- Cell values match the Skips renderer's vocabulary:
--   true  = unlocked (green check)
--   false = not confirmed (red X)
--   "?"   = unknown (waiting glyph)
--
-- Returns mythic, heroic, normal.
-- Per-difficulty skip state for the Siege of Orgrimmar Garrosh scroll.
-- The scroll unlocks account-wide on a Garrosh kill, but the client has
-- no single account-wide "any kill" signal, so we grade each difficulty
-- from the strongest proof available, most-conclusive first:
--
--   Tier 1  Mythic Garrosh achievement (account-wide) completed
--           -> Mythic / Heroic / Normal all unlocked.
--   Tier 2  either faction's Heroic-or-higher kill achievement
--           (Conqueror = Alliance, Liberator = Horde; both account-wide)
--           completed, no Mythic -> Heroic + Normal unlocked, Mythic
--           locked.
--   Tier 3  a Normal-difficulty kill statistic > 0, no achievement.
--           Statistics are CHARACTER-scoped, so this confirms only the
--           current character's Normal kill -> Normal unlocked, Heroic
--           and Mythic locked.
--   Tier 4  nothing proven -> Heroic + Mythic locked, Normal unknown
--           ("?"), since a kill on another character may have unlocked
--           the scroll without leaving a trace we can read here.
--
-- Cell values match the Skips renderer's vocabulary:
--   true  = unlocked (green check)
--   false = locked (red X)
--   "?"   = unknown (waiting glyph)
--
-- Returns mythic, heroic, normal.
local function GarroshSkipStates(cfg)
    if not cfg then return false, false, "?" end

    local function achDone(id)
        if not id or not GetAchievementInfo then return false end
        local _, _, _, completed = GetAchievementInfo(id)
        return completed and true or false
    end

    -- Tier 1: Mythic achievement.
    if achDone(cfg.mythicAchievement) then
        return true, true, true
    end

    -- Tier 2: either faction's Heroic-or-higher kill achievement.
    if cfg.heroicAchievements then
        for _, id in ipairs(cfg.heroicAchievements) do
            if achDone(id) then
                return false, true, true
            end
        end
    end

    -- Tier 3: a Normal-difficulty kill statistic > 0 (current character).
    if cfg.normalStatistics and GetStatistic then
        for _, statID in ipairs(cfg.normalStatistics) do
            -- GetStatistic can return a boolean (not a count) when stats
            -- data isn't loaded yet, so only a string/number is a real
            -- reading. The in-game "--" (no kills) is a non-numeric
            -- string -> tonumber nil -> 0.
            local raw = GetStatistic(statID)
            local t = type(raw)
            if (t == "number" or t == "string") and (tonumber(raw) or 0) > 0 then
                return false, false, true
            end
        end
    end

    -- Tier 4: nothing proven.
    return false, false, "?"
end

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

    -- Siege of Orgrimmar's "Scroll of Past Deeds" skip. Per-difficulty
    -- state lives in GarroshSkipStates; for the single-value ceiling
    -- consumers (idle-list marker, IsRaidSkipAvailableAtDifficulty) we
    -- collapse to a ceiling: the highest difficulty whose cell is a
    -- confirmed unlock. "?" (unknown) does not count as unlocked here --
    -- the marker should reflect what we can prove, and availability
    -- checks shouldn't assert a skip we haven't confirmed.
    if raid.skipGarrosh then
        local m, h, n = GarroshSkipStates(raid.skipGarrosh)
        if m == true then return 16 end
        if h == true then return 15 end
        if n == true then return 14 end
        return nil
    end

    return nil
end

-- Public accessor for the Siege of Orgrimmar per-difficulty skip cells.
-- Returns mythic, heroic, normal as true / false / "?" (see
-- GarroshSkipStates). Returns nil if the raid has no skipGarrosh config,
-- so callers can fall back to the ceiling-based rendering used by every
-- other skip mechanism.
function RR:GetGarroshSkipStates(raid)
    if not raid or not raid.skipGarrosh then return nil end
    return GarroshSkipStates(raid.skipGarrosh)
end

-- True iff the raid's skip mechanic uses the standard cascade-down rule
-- (completing X unlocks X and every easier difficulty). False for
-- achievement-gated skips, which only unlock the exact difficulty named.
function RR:RaidSkipIsCascading(raid)
    if not raid then return false end
    if raid.skipQuests then return true end
    if raid.skipAchievement then return false end
    -- Garrosh scroll: once unlocked it applies at every difficulty the
    -- player can enter, so the downward cascade from its Mythic ceiling
    -- is the correct model.
    if raid.skipGarrosh then return true end
    return false
end

-- True iff the raid has any skip mechanic configured (regardless of
-- whether it's currently unlocked). Single gate for the UI sites that
-- decide whether to surface the skip column / detail row at all, so a
-- new mechanism only has to be added here rather than at every call
-- site.
function RR:RaidHasSkipMechanic(raid)
    if not raid then return false end
    return (raid.skipQuests ~= nil)
        or (raid.skipAchievement ~= nil)
        or (raid.skipGarrosh ~= nil)
end

-- True if a skip route has been authored for this raid. Independent of
-- whether the player has unlocked the skip -- this is content
-- availability, not unlock state. Drives the "Routed" cell color in the
-- Skips window. Routes are added raid by raid; raids without one return
-- false and their unlocked cells stay green.
function RR:RaidHasSkipRoute(raid)
    return raid ~= nil and raid.skipRoute ~= nil
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

-- Ceiling for the specific skip chain the raid's authored route targets,
-- matched by skipToBoss against each chain's label. Falls back to the
-- max-across-all-chains ceiling (GetRaidSkipUnlockedCeiling) when the raid
-- has no skipToBoss, a single chain, or no chain label matches skipToBoss.
function RR:GetRouteTargetSkipCeiling(raid)
    if not raid then return nil end
    -- Only multi-chain quest skips have the ambiguity; others are single-target.
    if not raid.skipQuests then return self:GetRaidSkipUnlockedCeiling(raid) end

    local perChain = self:GetSkipChainCeilings(raid)
    if not perChain then return nil end

    local target = raid.skipToBoss
    if target then
        for _, c in ipairs(perChain) do
            if c.label == target then return c.ceiling end
        end
    end

    local maxCeiling
    for _, c in ipairs(perChain) do
        if c.ceiling and (not maxCeiling or c.ceiling > maxCeiling) then
            maxCeiling = c.ceiling
        end
    end
    return maxCeiling
end

-- Like IsRaidSkipAvailableAtDifficulty, but gated on the chain the
-- authored route targets (via GetRouteTargetSkipCeiling) rather than any
-- unlocked chain. Used by the load dialog's single SKIP button.
function RR:IsRouteTargetSkipAvailableAtDifficulty(raid, difficultyID)
    if not difficultyID then return false end
    if difficultyID < 14 or difficultyID > 16 then return false end
    local ceiling = self:GetRouteTargetSkipCeiling(raid)
    if not ceiling then return false end
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

-- True if the player has killed at least one boss in the current raid's
-- active lockout. Reads encounterProgress (12th return of
-- GetSavedInstanceInfo) for the matching instanceID + difficulty. A
-- lockout id alone does not imply a kill, so this gates "committed."
function RR:HasAnyKillThisLockout()
    if not self.currentRaid or not self.currentRaid.instanceID then return false end
    if not self.state.currentDifficultyID then return false end

    local numSaved = GetNumSavedInstances()
    for i = 1, numSaved do
        local _, _, _, difficultyId, _, _, _, isRaid,
              _, _, _, encounterProgress, _,
              instanceID = GetSavedInstanceInfo(i)
        if isRaid
            and instanceID   == self.currentRaid.instanceID
            and difficultyId == self.state.currentDifficultyID then
            return (encounterProgress or 0) > 0
        end
    end
    return false
end

-- Kill count for the current raid's active lockout, as killed, total.
-- Reads encounterProgress (12th) and numEncounters (11th) from
-- GetSavedInstanceInfo for the matching instanceID + difficulty. Returns
-- 0, 0 when the raid isn't saved (no lockout row yet). Used for the
-- "Lockout in Progress (n/N)" resume line.
function RR:GetCurrentLockoutKillCount()
    if not self.currentRaid or not self.currentRaid.instanceID then return 0, 0 end
    if not self.state.currentDifficultyID then return 0, 0 end

    local numSaved = GetNumSavedInstances()
    for i = 1, numSaved do
        local _, _, _, difficultyId, _, _, _, isRaid,
              _, _, numEncounters, encounterProgress, _,
              instanceID = GetSavedInstanceInfo(i)
        if isRaid
            and instanceID   == self.currentRaid.instanceID
            and difficultyId == self.state.currentDifficultyID then
            return (encounterProgress or 0), (numEncounters or 0)
        end
    end
    return 0, 0
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

function RR:LoadCurrentRaid(variant)
    if not self.currentRaid then return end
    self.state.loadedRaidKey = self:GetRaidContextKey()

    -- Restore persisted progress first. This also pulls the saved route
    -- variant into state.activeRouteVariant when one exists for this
    -- lockout, so a silent reload (no explicit variant arg) keeps running
    -- the route the player chose.
    self:RestorePersistedProgress()

    -- Variant resolution:
    --   explicit arg ("skip"/"standard") -- the player is choosing on the
    --     load dialog; honor and persist it.
    --   no arg -- programmatic load (e.g. silent reload restore); keep the
    --     variant restored above, defaulting to "standard" if none saved.
    if variant ~= nil then
        self.state.activeRouteVariant = (variant == "skip") and "skip" or "standard"
        self:PersistRouteVariant(self.state.activeRouteVariant)
    else
        if not self.state.activeRouteVariant then
            self.state.activeRouteVariant = "standard"
        end
        self:PersistRouteVariant(self.state.activeRouteVariant)
    end

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
    self.state.activeRouteVariant = nil
    self:RefreshAll()
end

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
        -- The load dialog is a custom frame (not a StaticPopup), so it
        -- isn't auto-dismissed on zone change; hide it explicitly when
        -- the player leaves the raid.
        if RR.UI and RR.UI.HideLoadDialog then
            RR.UI.HideLoadDialog()
        end
        -- Reconcile Toaster here too: this branch returns early (before the
        -- end-of-function reconcile), so leaving a raid would otherwise leave
        -- the toast active. currentRaid is now nil, so this deactivates it.
        if self.RefreshToasterLifecycle then
            self:RefreshToasterLifecycle()
        end
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
            -- Saved-instance data (GetSavedInstanceInfo) arrives async after
            -- RequestRaidInfo. On a fresh zone-in HandleLocationChange can
            -- run before it's ready, so GetCurrentLockoutId() returns nil and
            -- HasPersistedProgressForCurrentLockout() can't see a committed
            -- run -- which would wrongly show the load dialog for a raid the
            -- player already loaded this lockout. If we have a saved progress
            -- store for this raid+faction but can't yet confirm the lockout,
            -- defer: don't set lastSeenRaidKey, don't prompt. UPDATE_INSTANCE_
            -- INFO re-drives HandleLocationChange once the data lands, and we
            -- decide then with a valid lockout. A raid with no saved store is
            -- genuinely fresh -- prompt immediately, nothing to defer for.
            if self:HasSavedRouteStore()
                and not self:GetCurrentLockoutId()
                and not self.state.instanceInfoSeen then
                return
            end

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

            if self:HasPersistedProgressForCurrentLockout()
               and self:HasAnyKillThisLockout() then
                -- Committed (a route loaded AND a boss dead): restore the
                -- persisted route silently instead of re-prompting.
                self.state.loadedRaidKey = key
                self:LoadCurrentRaid()
                -- Confirm the resumed route in chat (no dialog showed it).
                local saved = self:GetPersistedRouteVariant()
                local routeWord = (saved == "skip") and "SKIP" or "FULL"
                local killed, total = self:GetCurrentLockoutKillCount()
                self:PrintAfterBanner(("%s Lockout in Progress (%d/%d).")
                    :format(self:GetRaidDisplayName() or supported.name,
                            killed, total))
                self:PrintAfterBanner(("Resuming %s route."):format(routeWord))
            elseif self:IsInLFR() then
                -- LFR has no supported route -- neither variant applies, since
                -- the routing data is authored for the full N/H/M layout and
                -- LFR splits the raid into wings. Skip the standard/skip
                -- variant dialog (asking the player to choose between two
                -- routes that both resolve to "unsupported" is backwards) and
                -- load the panel directly. The panel's LFR guard then shows the
                -- "routing not supported for LFR" message in place of routing.
                self.state.loadedRaidKey = key
                self:LoadCurrentRaid()
            else
                self.state.loadedRaidKey = nil
                self:SetSetting("showPanel", false)
                if RetroRunsUI then RetroRunsUI:Hide() end
                if RR.UI and RR.UI.ShowLoadDialog then
                    RR.UI.ShowLoadDialog(self:GetRaidDisplayName() or supported.name)
                end
            end
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
        self.state.instanceInfoSeen      = false
        self.state.currentDifficultyID   = nil
        self.state.currentDifficultyName = nil
        if info.name and self.state.lastUnsupportedRaid ~= info.name then
            self.state.lastUnsupportedRaid = info.name
            self:Print(info.name .. " is not supported yet.")
        end
    end

    -- currentRaid is now resolved for this location (a supported raid, or nil).
    -- Reconcile the Toaster lifecycle here so it activates/deactivates in
    -- step with supported-raid state on every location change -- not just on
    -- PLAYER_ENTERING_WORLD. This is the single point where currentRaid is set
    -- or cleared, so it's the right place to keep the toast scoped to raids we
    -- support.
    if self.RefreshToasterLifecycle then
        self:RefreshToasterLifecycle()
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

    -- Live location block. Useful both inside a raid (cross-check
    -- player coords against routing seg points) and outside one
    -- (verify an entrance icon lands you at the saved coords during
    -- new-raid bring-up). Printed before any raid-specific output.
    local playerMapID = C_Map and C_Map.GetBestMapForUnit
                        and C_Map.GetBestMapForUnit("player")
    local px, py
    if playerMapID and playerMapID > 0 and C_Map.GetPlayerMapPosition then
        local pos = C_Map.GetPlayerMapPosition(playerMapID, "player")
        if pos then px, py = pos:GetXY() end
    end
    local liveZone    = (GetZoneText    and GetZoneText())    or ""
    local liveSubZone = (GetSubZoneText and GetSubZoneText()) or ""
    if liveZone    == "" then liveZone    = "<empty>" end
    if liveSubZone == "" then liveSubZone = "<empty>" end

    if px and py then
        add(("Live: mapID=%s  coords=%.1f, %.1f  zone=%q  subZone=%q"):format(
            tostring(playerMapID or "?"), px * 100, py * 100, liveZone, liveSubZone))
    else
        add(("Live: mapID=%s  coords=(unavailable)  zone=%q  subZone=%q"):format(
            tostring(playerMapID or "?"), liveZone, liveSubZone))
    end

    -- WorldMap mapID: the ID of the map currently shown in the world-map
    -- frame. The route-line overlay draws against THIS value (not the player
    -- mapID above), and the two can differ -- on the SoO Galakras bridge the
    -- player mapID and the open map's ID disagreed, which is why a line can
    -- look "missing" while actually drawing on the other map. Surfacing it
    -- here makes line-placement debugging key off the value the overlay uses.
    local worldMapID = WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    add(("WorldMap mapID: %s%s"):format(
        tostring(worldMapID or "(map closed)"),
        (worldMapID and self.currentRaid and self.currentRaid.maps
            and self.currentRaid.maps[worldMapID])
            and ("  %q"):format(self.currentRaid.maps[worldMapID]) or ""))

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

    -- Entrance from data file. Printed verbatim so a bring-up step
    -- can read this and confirm the saved entrance matches where the
    -- player actually zones in. Coords stored in normalized 0-1 form
    -- in raid.entrance; displayed here as percentages to match the
    -- live coords line above for direct comparison.
    if raid.entrance then
        local e = raid.entrance
        add(("Entrance (data): mapID=%s  coords=%.1f, %.1f  subZone=%q"):format(
            tostring(e.mapID or "?"),
            (e.x or 0) * 100, (e.y or 0) * 100,
            e.subZone or ""))
    end

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
    add(("Zone: %q  SubZone: %q"):format(liveZone, liveSubZone))

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
-- Dialog-debug diagnostic (dev-only; not user-facing)
--
-- One-shot capture tool for designing dialog-trigger framework data.
-- Encounter scripts often emit chat-channel events (CHAT_MSG_MONSTER_YELL,
-- CHAT_MSG_MONSTER_SAY, CHAT_MSG_RAID_BOSS_EMOTE) at gating moments --
-- e.g. after the player clicks an Eternal Palace orb, an NPC speaks a
-- voiceline that's the only reliable signal the gate has been opened.
-- This module captures every such event (across all three channels) into
-- a dedicated buffer for later paste-back, with real-time chat
-- confirmation so the player sees the capture happen the moment the
-- event fires (one-shot mechanics like the Ashvane orbs only emit their
-- dialog once per reset, so silent failure would mean re-clearing the raid).
--
-- Lifecycle: explicitly armed via /rr dialogdebug start (zero perf cost
-- otherwise -- events are only registered while armed). Disarmed via
-- /rr dialogdebug stop, which dumps to a copy window for paste-back.
-------------------------------------------------------------------------------

local dialogDebug = {
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
local function FormatDialogCapture(event, ...)
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
--- Built with concatenation rather than :format() because dialog text
--- (especially boss flavor lines and rendered spell names) can contain
--- literal `%` characters that would be misinterpreted as format
--- specifiers and crash. Concatenation with tostring() is bulletproof
--- for arbitrary input.
---
--- Same secret-value handling as FormatDialogCapture: if speaker or
--- text is secret-tainted (mid-encounter chat from boss scripts), we
--- substitute a "(secret)" placeholder so the line still surfaces in
--- chat without doing forbidden comparison ops.
local function PrintDialogConfirmation(event, text, speaker)
    local ev = tostring(event):gsub("^CHAT_MSG_", "")
    local speakerStr = (issecretvalue and issecretvalue(speaker)) and "(secret)" or tostring(speaker or "?")
    local textStr    = (issecretvalue and issecretvalue(text))    and "(secret)" or tostring(text    or "?")
    RR:Print("|cff00ff88[DialogDebug]|r " .. ev
        .. " from |cffffff00" .. speakerStr .. "|r: "
        .. textStr)
end

local function DialogEventHandler(_, event, ...)
    if not dialogDebug.active then return end
    if not dialogDebug.buffer then return end  -- defensive; shouldn't happen
    -- pcall wrap: chat-event payloads include arbitrary text from any
    -- NPC in earshot, including special characters that historically
    -- caused issues with formatters. A crash here would interrupt the
    -- player's run with WoW's error frame, which is especially bad
    -- during one-shot mechanics. Log any failure to ZoneLog for later
    -- diagnosis, then move on. The buffer + chat-confirmation paths
    -- below are the only places that touch arbitrary input; if they
    -- fail, the whole capture for THIS event is lost but DialogDebug
    -- stays armed and ready for the next one.
    local args = { event, ... }
    local ok, err = pcall(function()
        table.insert(dialogDebug.buffer, FormatDialogCapture(unpack(args)))
        -- arg1 = text, arg2 = sender name across all three CHAT_MSG_MONSTER_*
        -- and CHAT_MSG_RAID_BOSS_EMOTE events (consistent API surface).
        local text   = args[2]
        local sender = args[3]
        PrintDialogConfirmation(event, text, sender)
    end)
    if not ok then
        RR:ZoneLog("[DialogDebug] handler crash: " .. tostring(err))
    end
end

function RR:DialogDebugStart()
    if dialogDebug.active then
        self:Print("|cff00ff88[DialogDebug]|r already armed. /rr dialogdebug stop to disarm.")
        return
    end
    if not dialogDebug.frame then
        dialogDebug.frame = CreateFrame("Frame")
        dialogDebug.frame:SetScript("OnEvent", DialogEventHandler)
    end
    dialogDebug.buffer = {}
    dialogDebug.frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    dialogDebug.frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    dialogDebug.frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    dialogDebug.active = true
    self:Print("|cff00ff88[DialogDebug]|r ARMED. Capturing MONSTER_YELL, MONSTER_SAY, RAID_BOSS_EMOTE.")
    self:Print("|cff00ff88[DialogDebug]|r Each capture will print a confirmation line below. /rr dialogdebug stop to dump.")
end

function RR:DialogDebugStop()
    if not dialogDebug.active then
        self:Print("|cff00ff88[DialogDebug]|r not armed. /rr dialogdebug start to begin capture.")
        return
    end
    dialogDebug.frame:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
    dialogDebug.frame:UnregisterEvent("CHAT_MSG_MONSTER_SAY")
    dialogDebug.frame:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    dialogDebug.active = false
    local count = #dialogDebug.buffer
    self:Print(("|cff00ff88[DialogDebug]|r DISARMED. Captured %d event(s). Opening dump window..."):format(count))
    local dump
    if count == 0 then
        dump = "(no events captured during this session)"
    else
        dump = table.concat(dialogDebug.buffer, "\n\n")
    end
    self:ShowCopyWindow("RetroRuns -- DialogDebug capture", dump)
    dialogDebug.buffer = nil  -- free memory; new buffer on next start
end

-- Read-only accessor for DevTools. The dialogDebug table is file-local
-- so external modules can't read .active directly.
function RR:IsDialogDebugActive()
    return dialogDebug.active == true
end

-------------------------------------------------------------------------------
-- LootProbe: discovery tool for the Toaster intercept feature.
--
-- The native loot popups (the center-screen "you received" toasts) are driven
-- by a set of events the AlertFrame listens for. Which event fires depends on
-- the TYPE of drop (regular gear vs mount vs pet vs transmog source), not on
-- the expansion of the raid -- legacy solo drops come through the current
-- client's delivery path regardless of which raid they're from. This probe
-- arms a listener on the candidate event set and logs every fire with its
-- full payload, so the suppress/replace lists can be built against what the
-- live client actually emits rather than guessed.
--
-- Arm with /rr lootprobe start, loot a mix of drops in a legacy raid, then
-- /rr lootprobe stop to dump the capture to a copy window.
local lootProbe = { active = false, frame = nil, buffer = nil }

-- Candidate events: the delivery/notification events that produce a native
-- toast. Captured together so a single boss-loot pass shows which one(s)
-- fire for each drop type.
local LOOTPROBE_EVENTS = {
    "SHOW_LOOT_TOAST",
    "SHOW_LOOT_TOAST_UPGRADE",
    "SHOW_LOOT_TOAST_LEGENDARY_LOOTED",
    "SHOW_PVP_FACTION_LOOT_TOAST",
    "LOOT_ITEM_ROLL_WON",
    "NEW_MOUNT_ADDED",
    "NEW_PET_ADDED",
    "NEW_TOY_ADDED",
    "TRANSMOG_COLLECTION_SOURCE_ADDED",
    "TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED",
    "CHAT_MSG_LOOT",
}

local function FormatLootCapture(event, ...)
    local n = select("#", ...)
    local parts = {}
    for i = 1, n do
        local v = select(i, ...)
        parts[i] = ("arg%d=%s"):format(i, tostring(v))
    end
    local stamp = date("%H:%M:%S")
    if n == 0 then
        return ("[%s] %s  (no args)"):format(stamp, event)
    end
    return ("[%s] %s\n    %s"):format(stamp, event, table.concat(parts, "\n    "))
end

local function LootEventHandler(_, event, ...)
    if not lootProbe.active then return end
    lootProbe.buffer[#lootProbe.buffer + 1] = FormatLootCapture(event, ...)
    -- Lightweight confirmation so Photek sees captures land live without
    -- having to stop the probe; full payload goes to the dump window.
    RR:Print(("|cff00ff88[LootProbe]|r %s (%d arg(s))"):format(event, select("#", ...)))
end

function RR:LootProbeStart()
    if lootProbe.active then
        self:Print("|cff00ff88[LootProbe]|r already armed. /rr lootprobe stop to disarm.")
        return
    end
    if not lootProbe.frame then
        lootProbe.frame = CreateFrame("Frame")
        lootProbe.frame:SetScript("OnEvent", LootEventHandler)
    end
    lootProbe.buffer = {}
    for _, ev in ipairs(LOOTPROBE_EVENTS) do
        -- pcall: a few candidates may not exist on every client build; an
        -- unknown event name errors on RegisterEvent. Skip those quietly.
        pcall(lootProbe.frame.RegisterEvent, lootProbe.frame, ev)
    end
    lootProbe.active = true
    self:Print(("|cff00ff88[LootProbe]|r ARMED. Listening for %d loot/toast events."):format(#LOOTPROBE_EVENTS))
    self:Print("|cff00ff88[LootProbe]|r Loot a mix of drops (gear, mount, pet, transmog), then /rr lootprobe stop.")
end

function RR:LootProbeStop()
    if not lootProbe.active then
        self:Print("|cff00ff88[LootProbe]|r not armed. /rr lootprobe start to begin capture.")
        return
    end
    for _, ev in ipairs(LOOTPROBE_EVENTS) do
        pcall(lootProbe.frame.UnregisterEvent, lootProbe.frame, ev)
    end
    lootProbe.active = false
    local count = #lootProbe.buffer
    self:Print(("|cff00ff88[LootProbe]|r DISARMED. Captured %d event(s). Opening dump window..."):format(count))
    local dump
    if count == 0 then
        dump = "(no events captured during this session)"
    else
        dump = table.concat(lootProbe.buffer, "\n\n")
    end
    self:ShowCopyWindow("RetroRuns -- LootProbe capture", dump)
    lootProbe.buffer = nil
end

function RR:IsLootProbeActive()
    return lootProbe.active == true
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
-- Shared by /rr tmogverify and /rr tmogverifyall. See the tmogverify docblock
-- above the dispatcher for the per-check semantics.
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
        -- Difficulty buckets to check. Mists raids have no Mythic, so
        -- driving difficulty 16 just wastes a settle-timeout per boss and
        -- checks a bucket the data never carries. The mop model also
        -- stores a separate itemID per tier (see the E2 note below), so
        -- the per-item checks need to know which model they're in.
        local isMop = (raid.difficultyModel == "mop")
        local DIFFS = isMop and { 17, 14, 15 } or { 17, 14, 15, 16 }
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

                    -- Resolve the row's canonical appearanceID via
                    -- GetItemInfo. Used by [E2] below to recognize the
                    -- shared-appearance case (multiple items pointing at the
                    -- same visual). WoD-era loot routinely shares one
                    -- appearanceID across 5+ items via per-difficulty modIDs
                    -- and LFR-only shared pieces. The runtime appearance check
                    -- the Tmog browser uses treats all sources of an appearance
                    -- as interchangeable, so match that here rather than
                    -- requiring the bucket's source to own the row's itemID.
                    local rowAppearanceID
                    if C_TransmogCollection and C_TransmogCollection.GetItemInfo then
                        rowAppearanceID = C_TransmogCollection.GetItemInfo(item.id)
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
                    --
                    -- Shared-appearance exception: if the source's
                    -- visualID matches the row's canonical
                    -- appearanceID, the source IS a valid source for
                    -- this row's appearance even though the API says
                    -- it "belongs to" a different itemID. This shape
                    -- shows up routinely in WoD raids (one appearance
                    -- spans several items via per-difficulty modIDs +
                    -- LFR shared cloaks) and the runtime
                    -- appearance-collection check considers all such
                    -- sources interchangeable. Only flag when the
                    -- itemID AND the visualID both diverge.
                    for _, diffID in ipairs(DIFFS) do
                        local b = perBucket[diffID]
                        if b and b.apiItemID and b.apiItemID ~= item.id then
                            -- Mists model: a piece exists as three
                            -- separate itemIDs (Normal / Heroic / LFR),
                            -- and the row deliberately carries only the
                            -- Normal itemID while storing each tier's
                            -- own sourceID. So a bucket source belonging
                            -- to a different itemID is EXPECTED here --
                            -- it's the tier-sibling item, not a wrong
                            -- source. db2 cross-reference (the mop loot
                            -- audit) already confirms these per tier;
                            -- the live check that still matters is E1
                            -- (does the source resolve at all), which
                            -- runs above. So skip the equality assertion
                            -- for mop raids.
                            local sharedAppearance =
                                rowAppearanceID and b.visualID
                                and b.visualID == rowAppearanceID
                            if not sharedAppearance and not isMop then
                                table.insert(findings, ("[ERR] %s src=%d: API itemID=%d, expected %d"):format(
                                    DIFF_NAME[diffID], b.src, b.apiItemID, item.id))
                                T.item_mismatch = T.item_mismatch + 1
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
                    -- The real red flag is PARTIAL duplication: 2 or 3 unique
                    -- sources across 4 buckets. One known case is Rae'shalare,
                    -- {L=new, N=old, H=old, M=old}, where ATT stores it as
                    -- bonusID variants. Flag as WRN for manual review; most are
                    -- legitimate documented exceptions, but new ones deserve a
                    -- look.
                    local srcCounts = {}  -- src -> count
                    local visualSet = {}  -- visualID -> true (for same-visual detection)
                    local uniqueCount = 0
                    local uniqueVisualCount = 0
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
                            if b.visualID and not visualSet[b.visualID] then
                                visualSet[b.visualID] = true
                                uniqueVisualCount = uniqueVisualCount + 1
                            end
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
                    elseif uniqueVisualCount == 1 and totalBuckets >= 2 then
                        -- Binary-by-visual: different sourceIDs across
                        -- buckets, but they all resolve to the same
                        -- visualID (Blackrock Foundry's "The Black Hand"
                        -- pattern: sourceIDs 62893/62895 both -> visual
                        -- 23383). From the player's perspective this is
                        -- a single appearance; from the API's it's
                        -- multiple acquisition paths. The UI's
                        -- CollectionStateForSource handles the
                        -- equivalence correctly (any-known check), so
                        -- we recognize it here too instead of flagging
                        -- a spurious "partial source duplication" WRN.
                        shapeTag = "binary"
                        T.shape_binary = (T.shape_binary or 0) + 1
                    elseif uniqueCount == totalBuckets and totalBuckets >= 2 then
                        -- Full per-difficulty shape.
                        shapeTag = "perdiff"
                        T.shape_perdiff = (T.shape_perdiff or 0) + 1
                    elseif raid.splitLootTables and totalBuckets == 1 and perBucket[17] then
                        -- WoD LFR pool: only [17] populated. Renders as
                        -- a single "[ LFR ]" bracket.
                        shapeTag = "lfr-pool"
                        T.shape_perdiff = (T.shape_perdiff or 0) + 1
                    elseif raid.splitLootTables and totalBuckets == 3
                           and perBucket[14] and perBucket[15] and perBucket[16]
                           and uniqueCount == 3 then
                        -- WoD N/H/M pool: [14],[15],[16] populated with
                        -- distinct per-difficulty sources. Renders as
                        -- "[ N | H | M ]".
                        shapeTag = "nhm-pool"
                        T.shape_perdiff = (T.shape_perdiff or 0) + 1
                    elseif totalBuckets == 4
                           and perBucket[14] and perBucket[15]
                           and perBucket[16] and perBucket[17]
                           and uniqueCount == 3
                           and perBucket[14].src == perBucket[15].src then
                        -- Normal+Heroic shared-appearance shape. Siege of
                        -- Orgrimmar-era gear carries one appearance at modID 0
                        -- that covers BOTH Normal and Heroic, with distinct
                        -- Mythic (modID 3) and LFR (modID 4) appearances. That
                        -- yields four populated buckets but only three unique
                        -- sources, with [14] and [15] sharing. The UI's
                        -- collection check handles the shared source correctly;
                        -- this is the intended encoding, not a partial gap.
                        shapeTag = "nh-shared"
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
                                -- Mists model: each tier (Normal /
                                -- Heroic / LFR) is its own appearance,
                                -- and tiers often pair up (e.g. Normal
                                -- and LFR share one visual while Heroic
                                -- differs), giving "2 visuals across 3
                                -- buckets". That's the expected shape
                                -- for this era, not a half-resolved
                                -- outlier, so don't warn for mop raids.
                                -- The nh-shared shape (Siege-era N+H
                                -- sharing one appearance) is likewise
                                -- expected, not a defect.
                                if not isMop and shapeTag ~= "nh-shared" then
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
                    local mythicTag = sp.mythicOnly and " [Mythic only]"
                        or (sp.lfrOnly and " [LFR only]")
                        or (sp.normalHeroicOnly and " [Normal/Heroic only]")
                        or ""
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
            add("Driving the live journal at each difficulty and comparing")
            add("the sources + appearances it exposes against shipped data.")
            add("E6 flags sources the journal shows that we don't ship in")
            add("that bucket; E7 flags appearances the journal exposes that")
            add("we ship nowhere. Catches gaps the per-item pass can't see.")
            add("")
        end

        -- Coverage pass drives the live Encounter Journal at each
        -- difficulty and reads back the loot it exposes. Two distinct
        -- ID spaces are in play:
        --   * DIFFS_LIST  -- the DISPLAY buckets we compare against
        --                    (what the data file keys sources by).
        --   * ejDriveIDs  -- the LIVE difficulty IDs we actually set on
        --                    the journal via EJ_SetDifficulty.
        -- For modern raids these coincide (14/15/16/17 are both the live
        -- IDs and the buckets). For Mists they don't: the live journal
        -- only responds to 3/4/5/6/7, and each folds into a bucket
        -- (3,4 -> 14 Normal; 5,6 -> 15 Heroic; 7 -> 17 LFR). Driving the
        -- modern IDs against a MoP raid exposed nothing AND timed out on
        -- the non-existent Mythic pass -- the cause of the apparent hang.
        local DIFFS_LIST = isMop and { 17, 14, 15 } or { 17, 14, 15, 16 }
        local model      = RR:GetDifficultyModel(raid)
        local ejDriveIDs
        if isMop then
            -- Drive the live IDs (fold keys), sorted for determinism.
            ejDriveIDs = {}
            for liveID in pairs(model.fold) do
                table.insert(ejDriveIDs, liveID)
            end
            table.sort(ejDriveIDs)
        else
            ejDriveIDs = DIFFS_LIST
        end

        if opts and opts.banner then
            RR:Print(("tmogverify: starting coverage pass (~%ds, %d boss(es))..."):format(
                (#raid.bosses) * #ejDriveIDs, #raid.bosses))
        end

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
            add("  E6 / E7 drive the journal at each difficulty;")
            add("        E6 flags a source the journal exposes that we")
            add("        don't ship in that bucket. E7 flags an appearance")
            add("        the journal exposes that we ship nowhere.")
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

            -- Shipped lookups. Two shapes:
            --   shippedSrcByBucket[bucket] = { [sourceID]=item, ... }
            --     -- every source we ship, grouped by display bucket.
            --   shippedAppearance[visualID] = true
            --     -- every appearance we ship anywhere for this boss,
            --        used by E7 to decide "did we miss this look?".
            -- Keying by source (not itemID) is what makes this correct
            -- for the Mists model, where one piece spans three itemIDs
            -- but each tier is just another source in a bucket.
            local shippedSrcByBucket = {}
            local shippedAppearance  = {}
            for _, d in ipairs(DIFFS_LIST) do shippedSrcByBucket[d] = {} end
            for _, it in ipairs(boss.loot) do
                if it.sources then
                    for _, d in ipairs(DIFFS_LIST) do
                        local src = it.sources[d]
                        if src then
                            shippedSrcByBucket[d][src] = it
                            -- Record the appearance this source carries.
                            if C_TransmogCollection
                               and C_TransmogCollection.GetAppearanceInfoBySource then
                                local ai = C_TransmogCollection.GetAppearanceInfoBySource(src)
                                if ai and ai.appearanceID then
                                    shippedAppearance[ai.appearanceID] = true
                                end
                            end
                        end
                    end
                end
            end

            -- EJ-exposed data, keyed by display bucket:
            --   ejSrcByBucket[bucket] = { [sourceID]=itemID, ... }
            -- plus the appearance each exposed source carries, so E7 can
            -- ask "is this look shipped anywhere" rather than matching by
            -- itemID (which differs per tier under the Mists model).
            local ejSrcByBucket    = {}
            local ejAppearance     = {}   -- visualID -> { itemID, bucket }
            for _, d in ipairs(DIFFS_LIST) do ejSrcByBucket[d] = {} end

            local diffIdx = 0
            local function NextDiff()
                diffIdx = diffIdx + 1
                if diffIdx > #ejDriveIDs then
                    -- All difficulty passes for this boss are done.
                    -- Compare exposed sources/appearances against shipped
                    -- data and accumulate E6 / E7 findings.
                    local bossHeader = ("--- E6/E7 for Boss %d: %s ---"):format(
                        boss.index or 0, boss.name or "?")
                    local bossFindings = {}

                    -- E6: per display bucket, compare the SET of sources
                    -- the EJ exposed against the set we shipped.
                    --   * EJ exposed a source we don't ship in that
                    --     bucket -> coverage gap (we missed a source).
                    --   * We ship a source the EJ never exposed for that
                    --     bucket -> suspicious (source may be wrong or
                    --     belong elsewhere).
                    -- Source-keyed, so it's correct regardless of how
                    -- many itemIDs a piece spans (the Mists multi-itemID
                    -- model included).
                    for _, d in ipairs(DIFFS_LIST) do
                        local shippedSet = shippedSrcByBucket[d] or {}
                        local ejSet      = ejSrcByBucket[d] or {}
                        for ejSrc, ejItemID in pairs(ejSet) do
                            if not shippedSet[ejSrc] then
                                local nm = GetItemInfo(ejItemID) or "?"
                                table.insert(bossFindings, ("[ERR] E6 %s %s: EJ exposes src=%d (item %d), not in our [%s] bucket"):format(
                                    DIFF_NAME[d] or tostring(d), nm, ejSrc, ejItemID, DIFF_NAME[d] or tostring(d)))
                                T.coverage_gap = T.coverage_gap + 1
                            end
                        end
                        for shSrc, it in pairs(shippedSet) do
                            if not ejSet[shSrc] then
                                -- N/H shared-appearance: Siege-era gear ships
                                -- one source in BOTH Normal [14] and Heroic
                                -- [15]. When the EJ is driven to one of those
                                -- difficulties it exposes the shared source
                                -- under the other bucket, so a strict
                                -- per-bucket match misses it. If the source
                                -- shows up in the EJ set for the paired
                                -- bucket, it's covered, not a gap.
                                local paired = (d == 14 and 15) or (d == 15 and 14) or nil
                                local pairedCovered = paired
                                    and ejSrcByBucket[paired]
                                    and ejSrcByBucket[paired][shSrc]
                                if not pairedCovered then
                                    table.insert(bossFindings, ("[WRN] E6 %s %s: we ship src=%d but EJ didn't expose it in this bucket"):format(
                                        DIFF_NAME[d] or tostring(d), it.name or "?", shSrc))
                                -- Counted as a soft coverage note, not a
                                -- hard gap -- EJ occasionally omits a
                                -- source on a cold cache. Keep it
                                -- visible but uncounted to avoid muddying
                                -- the ERR total. (Intentionally no T bump.)
                                end
                            end
                        end
                    end

                    -- E7: an appearance the EJ exposes for this boss that
                    -- we ship NOWHERE (no bucket, no tier). Matching by
                    -- appearance (visualID) instead of itemID is what
                    -- makes this correct under the Mists model: a tier's
                    -- itemID differs from our row id, but if we ship that
                    -- look in any bucket, it's covered.
                    for visualID, meta in pairs(ejAppearance) do
                        if not shippedAppearance[visualID] then
                            local nm = GetItemInfo(meta.itemID) or "?"
                            table.insert(bossFindings, ("[ERR] E7 visual=%d (item %d %s): EJ exposes this appearance, not in our data"):format(
                                visualID, meta.itemID, nm))
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

                local diffID = ejDriveIDs[diffIdx]
                -- Fold the live difficulty into the display bucket the
                -- data file keys against (identity for modern raids;
                -- 3/4->14, 5/6->15, 7->17 for Mists).
                local bucket = RR:FoldDifficulty(raid, diffID)
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

                                if hasAppearance and info.link and bucket then
                                    -- Resolve per-difficulty sourceID via
                                    -- the link form (carries the
                                    -- itemContext bonus needed for the
                                    -- right per-difficulty variant).
                                    local _, srcID = C_TransmogCollection.GetItemInfo(info.link)
                                    if srcID then
                                        ejSrcByBucket[bucket] = ejSrcByBucket[bucket] or {}
                                        ejSrcByBucket[bucket][srcID] = info.itemID
                                        -- Record the appearance this
                                        -- source carries, for E7's
                                        -- by-appearance "did we miss this
                                        -- look" check.
                                        if C_TransmogCollection.GetAppearanceInfoBySource then
                                            local ai = C_TransmogCollection.GetAppearanceInfoBySource(srcID)
                                            if ai and ai.appearanceID
                                               and not ejAppearance[ai.appearanceID] then
                                                ejAppearance[ai.appearanceID] = {
                                                    itemID = info.itemID,
                                                    bucket = bucket,
                                                }
                                            end
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

    if cmd == "" then
        -- Always opens the full panel; same toggle as the minimap button.
        RR.UI.TogglePanelExpanded()

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

    elseif cmd == "lfrbits" then
        -- Dev: dump the per-boss LFR lockout-bit capture log (S7 aid). Each
        -- LFR boss kill auto-records which lockout bit it set; this shows the
        -- accumulated boss->bit mapping. Pass `clear` to reset the log before a
        -- fresh capture run (e.g. at reset, to map a raid from scratch).
        if args[2] == "clear" then
            RetroRunsDebug = RetroRunsDebug or {}
            RetroRunsDebug.lfrBitLog = {}
            RR:Print("LFR bit capture log cleared.")
        else
            local log = (RetroRunsDebug and RetroRunsDebug.lfrBitLog) or {}
            local lines = {}
            local function add(s) lines[#lines + 1] = s end
            add("LFR per-boss lockout-bit capture log")
            add("(each entry = one LFR kill; 'bit' is the lockout bit that kill set)")
            add("")
            if #log == 0 then
                add("(empty -- kill LFR bosses to populate; `/rr lfrbits clear` to reset)")
            else
                for i = 1, #log do
                    local e = log[i]
                    add(("%s  %s  ->  bit %s   [%s]"):format(
                        tostring(e.t), tostring(e.boss), tostring(e.bit), tostring(e.raid)))
                end
            end
            RR:ShowCopyWindow("LFR Bit Capture", table.concat(lines, "\n"))
        end

    elseif cmd == "lfrwing" then
        -- Dev: collect everything needed to author an LFR wing route, in one
        -- command. Run while standing in the LFR wing. Dumps the live
        -- lfgDungeonID (the wing key), wing name, current mapID, raid context,
        -- and the raid's LFR lockout bitfield (which bosses read as killed),
        -- plus a paste-ready lfrWings[<id>] skeleton seeded with the live key.
        RR:LfrWingProbe()

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

    elseif cmd == "lockprobe" then
        RR:LockProbe()

    elseif cmd == "garroshskip" then
        -- Discovery probe for the Siege of Orgrimmar Garrosh skip. Dumps
        -- the per-difficulty Garrosh kill statistics (ID + value), their
        -- sum, and the completed flag of the Mythic Garrosh achievement,
        -- then prints the OR'd unlock verdict. Used to confirm the
        -- statistic IDs and account-wide behavior before codifying.
        RR:GarroshSkipProbe()

    elseif cmd == "raidcapture" then
        RR:RaidCapture()

    elseif cmd == "weaponharvest" then
        RR:HarvestWeaponPools()

    elseif cmd == "vendorscan" then
        RR:ScanMerchantFrame()

    elseif cmd == "tmog" then
        RR.UI.ToggleTransmogBrowser()

    elseif cmd == "tmogsize" then
        -- Diagnostic: dump the tmog popup's sizing geometry. Tmog window
        -- must be open first; select the boss to measure before running.
        -- Used for "why is there blank space at the bottom of the tmog
        -- popup?" / "why does the legend clip past the frame bottom?"
        -- investigations.
        RR.UI.DumpTmogSize()

    elseif cmd == "skips" then
        -- Open the raid-skip status window. Read-only display of which
        -- raid skips are unlocked on this account, with cascade-aware
        -- per-raid available-difficulty annotations. See
        -- UI.OpenSkipsWindow for the rendering.
        RR.UI.ToggleSkipsWindow()

    elseif cmd == "devtools" or cmd == "dt" then
        RR:ToggleDevTools()

    elseif cmd == "firedialog" then
        -- Test hook: inject a synthetic NPC-dialog event into the same path
        -- a real boss emote/yell would take, so dialog-gated routing (e.g.
        -- the Megaera bell mechanic) can be tested on demand without waiting
        -- for the live event or a fresh lockout. Case-sensitive: pulls the
        -- text from the RAW input (not the lowercased copy) because dialog
        -- matches are exact-substring. Sender is left empty, matching how
        -- boss-rise emotes actually arrive (text-only triggers).
        --   Usage: /rr firedialog Megaera rises from the mists!
        local rawRest = RR.Trim(input:sub(#cmd + 1))
        if rawRest == "" then
            RR:Print("Usage: /rr firedialog <dialog text>  (simulates a speakerless raid emote through the real dialog handler)")
        else
            RR:Print("|cff00ff88[firedialog]|r simulating speakerless emote: " .. rawRest)
            -- Route through the real handler (no sender), so this exercises
            -- the same guard + dispatch a live CHAT_MSG_RAID_BOSS_EMOTE hits
            -- -- not a direct AdvanceProgress call that skips the handler.
            RR:SimulateDialogEvent(rawRest, nil)
        end

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
        -- loot. Diagnoses why a given item isn't being picked up from the EJ.
        -- Optional needle itemID highlights a specific item and probes
        -- additional EJ paths if the iteration didn't find it.
        RR:EjProbe(args[2])

    elseif cmd == "tierprobe" then
        -- Dump what C_TransmogSets returns for a given tier itemID.
        -- Read-only diagnostic for tracking down wrong sourceIDs in a tier row.
        RR:TierProbe(args[2])

    elseif cmd == "specialtest" then
        -- Probe a single itemID against every special-loot detection API
        -- (mount / pet / toy / decor). Diagnoses the Mythic-sweep path:
        -- if a known mount like 190768 (Jailer's) isn't detected, run
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
                        local mythicTag = sp.mythicOnly and " [Mythic only]"
                            or (sp.lfrOnly and " [LFR only]")
                            or (sp.normalHeroicOnly and " [Normal/Heroic only]")
                            or ""
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
        --          2-3 unique        -> PARTIAL (WRN): source data may have
        --                               half-resolved. Rae'shalare is a
        --                               known instance (bonusID variants
        --                               ATT stores differently than modID).
        --   [E5] Retired (was: difficulty-bucket mismatch via itemContext).
        --        The check depended on GetSourceInfo(src).itemLink, which is
        --        nil in this runtime context across every shipped raid. E3
        --        visualID shape outliers catch the same class of bug indirectly
        --        when a misbucketed variant has a different visual.
        --
        -- Coverage checks (require driving the EJ at each difficulty;
        -- async pass that runs after the per-row metadata checks):
        --   [E6] Coverage gap: EJ exposes more sourceIDs for this item at
        --        this difficulty than the data file ships. Without this check,
        --        E1-E4 all pass on valid binary data even when the items
        --        should be per-difficulty, so the verify is clean but
        --        uninformative.
        --   [E7] Missing item: EJ exposes an item at this boss that's not in
        --        the data file at all. Indicates a boss whose loot table is
        --        incomplete, or an item Blizzard added later. Cross-difficulty:
        --        only flagged if missing at every difficulty (so a Mythic-only
        --        item also exposed at Normal won't false-positive).
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
            RR:VerifyOneRaid(raid, { verbose = true, banner = true, progress = true }, function(lines, T)
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

    elseif cmd == "dialogdebug" then
        local sub = args[2] or ""
        if     sub == "start" then RR:DialogDebugStart()
        elseif sub == "stop"  then RR:DialogDebugStop()
        else
            RR:Print("DialogDebug: /rr dialogdebug [start|stop]  (capture chat-channel NPC dialog for diagnosis)")
        end

    elseif cmd == "lootprobe" then
        local sub = args[2] or ""
        if     sub == "start" then RR:LootProbeStart()
        elseif sub == "stop"  then RR:LootProbeStop()
        else
            RR:Print("LootProbe: /rr lootprobe [start|stop]  (capture loot/toast events to build the suppress list)")
        end

    elseif cmd == "toaster" then
        local sub = args[2] or ""
        if     sub == "on"    then RR:EnableToaster()
        elseif sub == "off"   then RR:DisableToaster()
        elseif sub == "debug" then RR:ToasterDebug()
        else                       RR:ToggleToaster()
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
        -- Help text. Default output is a short user-facing list; dev and
        -- diagnostic commands are hidden behind `/rr help dev` so the normal
        -- help stays focused on what players actually use.
        local subcmd = args[2] or ""
        if subcmd == "dev" then
            RR:Print("RetroRuns dev commands:")
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
            RR:Print("  /rr  dialogdebug [start|stop]    (capture chat-channel NPC dialog for diagnosis)")
            RR:Print("  /rr  devtools (or dt)             (toggle the DevTools panel)")
            RR:Print("  /rr  cancelnav                   (cancel an active entrance-navigation route)")
            RR:Print("  /rr  reset | refresh             (reset settings to defaults | re-render the main panel)")
        else
            RR:Print("RetroRuns commands:")
            RR:Print("  /rr                  (toggle main panel)")
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
                RR:InitDialogTriggers()
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
            RR:ShowLoginBanner()
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
        RR.state.instanceInfoSeen = true
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
        elseif not RR.state.testMode
            and RR.currentRaid
            and not RR.state.loadedRaidKey then
            -- In a supported raid but no route loaded yet. This fires when
            -- the load decision was deferred at zone-in because saved-
            -- instance data wasn't ready (lockout unreadable). Now that the
            -- data has landed, re-run the location handler so it can decide
            -- prompt-vs-silent-restore with a valid lockout.
            RR:ZoneLog("UPDATE_INSTANCE_INFO handler: re-driving deferred load decision")
            RR:HandleLocationChange()
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

        -- Dev aid (S7): on a successful LFR boss kill, record which lockout
        -- bit the kill set, so the per-boss bit map can be gathered during
        -- normal farming. No-op outside LFR. Runs independent of the testMode
        -- gating below so it captures on real runs.
        if success == 1 then
            RR:CaptureLFRBitForKill(encounterName)
        end

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
